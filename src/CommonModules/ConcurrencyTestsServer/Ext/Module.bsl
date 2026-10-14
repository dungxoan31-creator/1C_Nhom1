// Task 4. Parent registers this module and routes exactly four string arguments:
// /C RunConcurrentPosting;run_id;result_path;worker_id;fixture_ref
// fixture_ref = absolute JSON path. Worker IDs: prepare, approve, 1, 2, verify.
// prepare runs as the real ketoan_ap; every other phase as real ketoan_truong.
// Uses existing open USD invoices/cash in a full-data snapshot clone, never seeds.
// No fake session identity, DataExchange.Load, privileged mode or production hooks.

Function RunConcurrentPosting(Val RunID, Val ResultPath, Val WorkerID, Val FixtureRef) Export
	Cases = New Array;
	Status = "PASS";
	CaseName = ?(WorkerID = "1" Or WorkerID = "2", "worker", WorkerID);
	Scenario = "payment";
	Try
		Connection = Lower(InfoBaseConnectionString());
		If StrFind(Connection, "infobase_fulldata") > 0
			Or (StrFind(Connection, "clone") = 0 And StrFind(Connection, "uat") = 0) Then
			Raise "CONCURRENCY_TEST_UNSAFE: disposable clone connection required";
		EndIf;
		ExpectedUser = ?(WorkerID = "prepare", "ketoan_ap", "ketoan_truong");
		If UserName() <> ExpectedUser Then
			Raise "CONCURRENCY_TEST_USER: authenticate the real maker/checker account";
		EndIf;
		Fixture = ReadFileJSON(FixtureRef);
		Scenario = Fixture.scenario;
		If Fixture.run_id <> RunID Then
			Raise "CONCURRENCY_TEST_STALE: fixture run ID differs";
		EndIf;
		If Fixture.scenario <> "payment" And Fixture.scenario <> "revaluation" Then
			Raise "CONCURRENCY_TEST_SCENARIO: unsupported scenario";
		EndIf;
		If WorkerID = "prepare" Then
			PrepareFixture(Fixture, FixtureRef);
		Else
			If WorkerID = "approve" Then
				ApproveFixture(Fixture);
			ElsIf WorkerID = "1" Or WorkerID = "2" Then
				PostWorker(Fixture, FixtureRef, WorkerID);
			ElsIf WorkerID = "verify" Then
				VerifyFixture(Fixture, Cases);
			Else
				Raise "CONCURRENCY_TEST_WORKER: unsupported worker ID";
			EndIf;
		EndIf;
		If WorkerID <> "verify" Then
			Cases.Add(New Structure("name,passed,error", CaseName, True, ""));
		EndIf;
	Except
		ErrorText = DetailErrorDescription(ErrorInfo());
		Status = ?(StrFind(ErrorText, "CONCURRENCY_TEST_NO_FIXTURE") > 0, "NOT_RUN", "FAIL");
		Cases.Clear();
		If WorkerID = "verify" Then
			For Each Name In VerificationNames(Scenario) Do
				Cases.Add(New Structure("name,passed,error", Name, False, ErrorText));
			EndDo;
		Else
			Cases.Add(New Structure("name,passed,error", CaseName, False, ErrorText));
		EndIf;
	EndTry;
	For Each CaseResult In Cases Do
		If Not CaseResult.passed And Status = "PASS" Then
			Status = "FAIL";
		EndIf;
	EndDo;
	Result = New Structure("run_id,status,cases", RunID, Status, Cases);
	WriteFileJSON(ResultPath, Result);
	Return Result;
EndFunction

Procedure PrepareFixture(Fixture, FixturePath)
	Q = New Query(
		"SELECT TOP 1 AP.PhapNhan AS PN, AP.DoiTac AS Partner, AP.HopDong AS Contract,
		| AP.ChungTuGoc AS Invoice, Cash.TaiKhoanTien AS Bank,
		| AP.SoTienBalance AS APVND, AP.SoTienNgoaiTeBalance AS APUSD,
		| Cash.VND AS BankVND, Cash.USD AS BankUSD
		|FROM AccumulationRegister.CongNoPhaiTra.Balance(,
		| HopDong.DongTienThanhToan.Code = ""USD"") AS AP
		| INNER JOIN Document.HoaDonNhaCungCap AS Invoice
		| ON AP.ChungTuGoc = Invoice.Ref
		| INNER JOIN (SELECT DT.PhapNhan AS PN, DT.TaiKhoanTien AS TaiKhoanTien,
		| SUM(DT.SoTienBalance) AS VND, SUM(DT.SoTienNgoaiTeBalance) AS USD
		| FROM AccumulationRegister.DongTien.Balance(, TienTe.Code = ""USD"") AS DT
		| GROUP BY DT.PhapNhan, DT.TaiKhoanTien) AS Cash
		| ON AP.PhapNhan = Cash.PN
		|WHERE Invoice.Posted AND NOT Invoice.DeletionMark
		| AND AP.SoTienBalance > 0 AND AP.SoTienNgoaiTeBalance >= 10
		| AND Cash.VND > 0 AND Cash.USD >= 10 AND Cash.TaiKhoanTien.TienTe.Code = ""USD""
		|ORDER BY AP.ChungTuGoc, Cash.TaiKhoanTien");
	Rows = Q.Execute().Unload();
	If Rows.Count() = 0 Then
		Raise "CONCURRENCY_TEST_NO_FIXTURE: snapshot needs open USD AP and funded USD bank in the same entity";
	EndIf;
	Row = Rows[0];
	Fixture.Insert("pn", String(Row.PN.UUID()));
	Fixture.Insert("invoice", String(Row.Invoice.UUID()));
	Fixture.Insert("bank", String(Row.Bank.UUID()));
	Fixture.Insert("ap_vnd", Row.APVND);
	Fixture.Insert("ap_usd", Row.APUSD);
	Fixture.Insert("bank_vnd", Row.BankVND);
	Fixture.Insert("bank_usd", Row.BankUSD);
	// Each request is affordable alone; together they exceed AP or bank capacity.
	Fixture.Insert("amount_usd", Round(Min(Row.APUSD, Row.BankUSD) * 0.6, 2));
	// Force a nonzero FX delta on every repetition; a zero-work revaluation
	// cannot provide evidence that duplicate adjustments were prevented.
	Fixture.Insert("rate", Round(Row.APVND / Row.APUSD, 4) + 100);
	Fixture.Insert("before", SnapshotTotals(Fixture));
	Fixture.Insert("docs", New Array);
	// Put test documents after every snapshot movement, including future-dated
	// seed records. Both revaluations then have the same inclusive cutoff.
	Q.Text = "SELECT MAX(Period) AS Latest FROM (
		| SELECT Period FROM AccumulationRegister.CongNoPhaiTra WHERE PhapNhan = &PN
		| UNION ALL SELECT Period FROM AccumulationRegister.DongTien WHERE PhapNhan = &PN) AS Movements";
	Q.SetParameter("PN", Row.PN);
	Latest = Q.Execute().Unload()[0].Latest;
	TestDate = CurrentSessionDate();
	If ValueIsFilled(Latest) And Latest > TestDate Then
		TestDate = Latest;
	EndIf;
	TestDate = BegOfDay(TestDate) + 43200;
	BeginTransaction();
	Try
		For Index = 1 To 2 Do
			Doc = ?(Fixture.scenario = "payment", Documents.UyNhiemChi.CreateDocument(),
				Documents.DanhGiaLaiNgoaiTe.CreateDocument());
			// Later-position winner/earlier-position loser exposes PointInTime exclusion.
			Doc.Date = EndOfDay(TestDate) + 1 + ?(Index = 1, 1, 0);
			Doc.PhapNhan = Row.PN;
			Doc.TienTe = Catalogs.TienTe.FindByCode("USD");
			Doc.NguoiLap = UserName();
			Doc.TrangThai = Enums.TrangThaiLenhThanhToan.DuThao;
			If Fixture.scenario = "payment" Then
				Doc.DoiTac = Row.Partner;
				Doc.HopDong = Row.Contract;
				Doc.ChungTuGoc = Row.Invoice;
				Doc.TaiKhoanTien = Row.Bank;
				Doc.SoTienNgoaiTe = Fixture.amount_usd;
				Doc.TyGia = Row.APVND / Row.APUSD;
				Doc.SoTien = Round(Fixture.amount_usd * Doc.TyGia, 0);
				Doc.DienGiai = "Concurrent posting regression " + Fixture.run_id;
			Else
				Doc.NgayChot = EndOfDay(Doc.Date);
				Doc.TyGiaDanhGia = Fixture.rate;
			EndIf;
			Doc.Write(DocumentWriteMode.Write);
			Doc.TrangThai = Enums.TrangThaiLenhThanhToan.ChoDuyet;
			Doc.Write(DocumentWriteMode.Write);
			Fixture.docs.Add(String(Doc.Ref.UUID()));
		EndDo;
		CommitTransaction();
	Except
		RollbackTransaction();
		Raise;
	EndTry;
	WriteFileJSON(FixturePath, Fixture);
EndProcedure

Procedure ApproveFixture(Fixture)
	BeginTransaction();
	Try
		For Index = 0 To 1 Do
			Doc = FixtureDocument(Fixture, Index).GetObject();
			If Doc.NguoiLap <> "ketoan_ap" Or Doc.Posted
				Or Doc.TrangThai <> Enums.TrangThaiLenhThanhToan.ChoDuyet Then
				Raise "CONCURRENCY_TEST_STATE: expected a pending document created by the real maker";
			EndIf;
			Doc.NguoiDuyet = UserName();
			Doc.TrangThai = Enums.TrangThaiLenhThanhToan.DaDuyet;
			Doc.Write(DocumentWriteMode.Write);
		EndDo;
		CommitTransaction();
	Except
		RollbackTransaction();
		Raise;
	EndTry;
EndProcedure

Procedure PostWorker(Fixture, FixturePath, WorkerID)
	// Load both objects before worker 1 takes write locks. In file mode even
	// reading another document can otherwise wait on the held transaction.
	Doc = FixtureDocument(Fixture, Number(WorkerID) - 1).GetObject();
	Doc.TrangThai = Enums.TrangThaiLenhThanhToan.DaGhiSo;
	Signal = New Structure("run_id,connection,user", Fixture.run_id, InfoBaseConnectionNumber(), UserName());
	WriteFileJSON(FixturePath + ".ready" + WorkerID, Signal);
	WaitSignal(FixturePath + ".go" + WorkerID, Fixture.run_id);
	WriteFileJSON(FixturePath + ".attempt" + WorkerID, Signal);
	BeginTransaction();
	Try
		Doc.Write(DocumentWriteMode.Posting);
		If WorkerID = "1" Then
			WriteFileJSON(FixturePath + ".held1", Signal);
			WaitSignal(FixturePath + ".release1", Fixture.run_id);
		EndIf;
		CommitTransaction();
	Except
		ErrorText = DetailErrorDescription(ErrorInfo());
		RollbackTransaction();
		// Only an explicit balance rejection is an expected losing payment.
		If WorkerID <> "2" Or Fixture.scenario <> "payment"
			Or StrFind(ErrorText, "CONCURRENCY_OVERDRAW") = 0 Then
			Raise;
		EndIf;
	EndTry;
EndProcedure

Procedure VerifyFixture(Fixture, Cases)
	Doc1 = FixtureDocument(Fixture, 0);
	Doc2 = FixtureDocument(Fixture, 1);
	If Fixture.scenario = "payment" Then
		AddCase(Cases, "one_payment", Doc1.Posted And Not Doc2.Posted,
			"Exactly worker 1 must commit; worker 2 must reject the overdraw");
		Invoice = Documents.HoaDonNhaCungCap.GetRef(New UUID(Fixture.invoice));
		Q = New Query("SELECT ISNULL(SUM(SoTienBalance), 0) AS VND,
			| ISNULL(SUM(SoTienNgoaiTeBalance), 0) AS USD
			|FROM AccumulationRegister.CongNoPhaiTra.Balance(,
			| PhapNhan = &PN AND DoiTac = &Partner AND HopDong = &Contract AND ChungTuGoc = &Invoice)");
		Q.SetParameter("PN", Invoice.PhapNhan);
		Q.SetParameter("Partner", Invoice.DoiTac);
		Q.SetParameter("Contract", Invoice.HopDong);
		Q.SetParameter("Invoice", Invoice);
		AP = Q.Execute().Unload()[0];
		Q.Text = "SELECT ISNULL(SUM(SoTienBalance), 0) AS VND,
			| ISNULL(SUM(SoTienNgoaiTeBalance), 0) AS USD
			|FROM AccumulationRegister.DongTien.Balance(,
			| PhapNhan = &PN AND TaiKhoanTien = &Bank AND TienTe = &Currency)";
		Q.SetParameter("Bank", Catalogs.TaiKhoanTien.GetRef(New UUID(Fixture.bank)));
		Q.SetParameter("Currency", Catalogs.TienTe.FindByCode("USD"));
		Bank = Q.Execute().Unload()[0];
		AddCase(Cases, "no_overdraw", AP.VND >= 0 And Bank.VND >= 0
			And AP.USD = Fixture.ap_usd - Fixture.amount_usd
			And Bank.USD = Fixture.bank_usd - Fixture.amount_usd,
			"Final current balances must contain exactly one payment, with no negative resources");
		APMovement = MovementTotals("AccumulationRegister.CongNoPhaiTra", Doc1);
		BankMovement = MovementTotals("AccumulationRegister.DongTien", Doc1);
		Q.Text = "SELECT ISNULL(SUM(CASE WHEN GL.AccountDr.Code = ""3313""
			| OR GL.AccountDr.Code = ""3312"" OR GL.AccountDr.Code = ""3311"" THEN GL.SoTien ELSE 0 END), 0) AS AP,
			| ISNULL(SUM(CASE WHEN GL.AccountCr.Code = ""1122"" THEN GL.SoTien ELSE 0 END), 0) AS Bank
			|FROM AccountingRegister.SoCaiKeToan AS GL WHERE GL.Recorder = &Doc";
		Q.SetParameter("Doc", Doc1);
		GL = Q.Execute().Unload()[0];
		AddCase(Cases, "payment_ledger", APMovement.rows = 1 And BankMovement.rows = 1
			And APMovement.usd = Fixture.amount_usd And BankMovement.usd = Fixture.amount_usd
			And APMovement.vnd = Fixture.ap_vnd - AP.VND And BankMovement.vnd = Fixture.bank_vnd - Bank.VND
			And GL.AP = APMovement.vnd And GL.Bank = BankMovement.vnd,
			"Payment GL and AP/cash movements must reconcile to actual balance reductions");
		AddCase(Cases, "loser_rollback", EmptyMovements(Doc2), "Rejected payment must leave no GL/AP/cash movements");
	Else
		After = SnapshotTotals(Fixture);
		Before = Fixture.before;
		// Legacy snapshot has negative groups; FX must reach the exact targets
		// without changing foreign currency, not repair historic balances.
		AddCase(Cases, "revaluation_balances", Doc1.Posted And Doc2.Posted And After.at_target
			And (After.nonnegative Or Not Before.nonnegative)
			And After.bank_usd = Before.bank_usd And After.ap_usd = Before.ap_usd
			And After.bank_vnd = Before.target_bank And After.ap_vnd = Before.target_ap,
			"All grouped balances must reach independent targets without changing foreign currency: " + ValueToStringInternal(After));
		APMovement = MovementTotals("AccumulationRegister.CongNoPhaiTra", Doc1, True);
		BankMovement = MovementTotals("AccumulationRegister.DongTien", Doc1, True);
		GLMovement = MovementTotals("AccountingRegister.SoCaiKeToan", Doc1);
		AddCase(Cases, "revaluation_ledger", APMovement.vnd = After.ap_vnd - Before.ap_vnd
			And BankMovement.vnd = After.bank_vnd - Before.bank_vnd
			And APMovement.usd = 0 And BankMovement.usd = 0
			And GLMovement.rows > 0 And GLMovement.vnd = Before.expected_gl,
			"FX GL must equal the independent baseline delta and match signed AP/cash movements");
		AddCase(Cases, "no_duplicate_fx", EmptyMovements(Doc2), "Same-rate competing revaluation must produce zero duplicate FX movements");
	EndIf;
EndProcedure

Function SnapshotTotals(Fixture)
	Result = New Structure("bank_vnd,bank_usd,ap_vnd,ap_usd,target_bank,target_ap,expected_gl,at_target,nonnegative",
		0, 0, 0, 0, 0, 0, 0, True, True);
	Gain = 0;
	Loss = 0;
	For Each Kind In StrSplit("bank,ap", ",") Do
		Q = New Query;
		If Kind = "bank" Then
			Q.Text = "SELECT SUM(SoTienBalance) AS VND, SUM(SoTienNgoaiTeBalance) AS USD
				|FROM AccumulationRegister.DongTien.Balance(, PhapNhan = &PN AND TienTe = &Currency)
				|GROUP BY TaiKhoanTien";
		Else
			Q.Text = "SELECT SUM(SoTienBalance) AS VND, SUM(SoTienNgoaiTeBalance) AS USD
				|FROM AccumulationRegister.CongNoPhaiTra.Balance(, PhapNhan = &PN AND HopDong.DongTienThanhToan = &Currency)
				|GROUP BY DoiTac, HopDong, ChungTuGoc";
		EndIf;
		Q.SetParameter("PN", Catalogs.PhapNhan.GetRef(New UUID(Fixture.pn)));
		Q.SetParameter("Currency", Catalogs.TienTe.FindByCode("USD"));
		For Each Row In Q.Execute().Unload() Do
			Target = ?(Row.USD = 0, Row.VND, Round(Row.USD * Fixture.rate, 2));
			Delta = Target - Row.VND;
			Result[Kind + "_vnd"] = Result[Kind + "_vnd"] + Row.VND;
			Result[Kind + "_usd"] = Result[Kind + "_usd"] + Row.USD;
			Result["target_" + Kind] = Result["target_" + Kind] + Target;
			Result.at_target = Result.at_target And Delta = 0;
			Result.nonnegative = Result.nonnegative And Row.VND >= 0 And Row.USD >= 0;
			Result.expected_gl = Result.expected_gl + Max(Delta, -Delta);
			SignedGain = ?(Kind = "bank", Delta, -Delta);
			Gain = Gain + Max(SignedGain, 0);
			Loss = Loss + Max(-SignedGain, 0);
		EndDo;
	EndDo;
	Result.expected_gl = Result.expected_gl + Max(Gain - Loss, Loss - Gain);
	Return Result;
EndFunction

Function MovementTotals(RegisterName, DocRef, Val Signed = False)
	MoneyExpression = "SoTien";
	If Signed Then
		MoneyExpression = "CASE WHEN RecordType = VALUE(AccumulationRecordType.Expense) THEN -SoTien ELSE SoTien END";
	EndIf;
	Q = New Query("SELECT COUNT(*) AS rows, ISNULL(SUM(" + MoneyExpression + "), 0) AS vnd,
		| ISNULL(SUM(SoTienNgoaiTe), 0) AS usd FROM " + RegisterName + " WHERE Recorder = &Doc");
	Q.SetParameter("Doc", DocRef);
	Row = Q.Execute().Unload()[0];
	Return New Structure("rows,vnd,usd", Row.rows, Row.vnd, Row.usd);
EndFunction

Function EmptyMovements(DocRef)
	Return MovementTotals("AccumulationRegister.CongNoPhaiTra", DocRef).rows = 0
		And MovementTotals("AccumulationRegister.DongTien", DocRef).rows = 0
		And MovementTotals("AccountingRegister.SoCaiKeToan", DocRef).rows = 0;
EndFunction

Function FixtureDocument(Fixture, Index)
	If Fixture.scenario = "payment" Then
		Return Documents.UyNhiemChi.GetRef(New UUID(Fixture.docs[Index]));
	EndIf;
	Return Documents.DanhGiaLaiNgoaiTe.GetRef(New UUID(Fixture.docs[Index]));
EndFunction

Function VerificationNames(Scenario)
	Return StrSplit(?(Scenario = "payment", "one_payment,no_overdraw,payment_ledger,loser_rollback",
		"revaluation_balances,revaluation_ledger,no_duplicate_fx"), ",");
EndFunction

Procedure AddCase(Cases, Name, Passed, ErrorText)
	Cases.Add(New Structure("name,passed,error", Name, Passed, ?(Passed, "", ErrorText)));
EndProcedure

Procedure WaitSignal(Path, RunID)
	// Test utility only. Bounded polling avoids unavailable/nonportable Sleep APIs.
	Deadline = CurrentDate() + 30;
	SignalFile = New File(Path);
	While CurrentDate() < Deadline Do
		If SignalFile.Exist() Then
			Signal = ReadFileJSON(Path);
			If Signal.run_id <> RunID Then
				Raise "CONCURRENCY_TEST_STALE: rendezvous run ID differs";
			EndIf;
			Return;
		EndIf;
	EndDo;
	Raise "CONCURRENCY_TEST_TIMEOUT: rendezvous timed out: " + Path;
EndProcedure

Function ReadFileJSON(Path)
	Reader = New JSONReader;
	Reader.OpenFile(Path);
	Result = ReadJSON(Reader);
	Reader.Close();
	Return Result;
EndFunction

Procedure WriteFileJSON(Path, Value)
	Writer = New JSONWriter;
	Writer.OpenFile(Path);
	WriteJSON(Writer, Value);
	Writer.Close();
EndProcedure
