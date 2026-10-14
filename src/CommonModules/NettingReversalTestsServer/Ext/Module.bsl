// Native characterization, sequential only; not evidence of simultaneous sessions.
// Parent registers this module and routes four strings to this entry function.
// prepare-ar: real ketoan_ar; prepare: real ketoan_ap; characterize: real ketoan_truong.
// Fixture JSON input: {"run_id":"..."}. Use only a disposable snapshot clone.
Function RunNettingReversalCharacterization(Val RunID, Val ResultPath, Val Phase, Val FixturePath) Export
	Cases = New Array;
	Status = "PASS";
	Try
		HardeningTestsServer.KiemTraMoiTruongUAT();
		If Phase <> "prepare-ar" And Phase <> "prepare" And Phase <> "characterize" Then
			Raise "CHARACTERIZATION_PHASE: expected prepare-ar, prepare or characterize";
		EndIf;
		ExpectedUser = ?(Phase = "prepare-ar", "ketoan_ar", ?(Phase = "prepare", "ketoan_ap", "ketoan_truong"));
		If UserName() <> ExpectedUser Then
			Raise "CHARACTERIZATION_USER: real maker/checker session required";
		EndIf;
		Fixture = ReadFileJSON(FixturePath);
		If Fixture.run_id <> RunID Then
			Raise "CHARACTERIZATION_STALE: fixture run ID differs";
		EndIf;
		If Phase = "prepare-ar" Then
			PrepareARFixture(Fixture);
			WriteFileJSON(FixturePath, Fixture);
			Cases.Add(New Structure("name,passed,error", "prepare-ar", True, ""));
		ElsIf Phase = "prepare" Then
			PrepareFixture(Fixture);
			WriteFileJSON(FixturePath, Fixture);
			Cases.Add(New Structure("name,passed,error", "prepare", True, ""));
		Else
			ApproveFixture(Fixture);
			For Each Name In StrSplit("backdated_netting,netting_repost,foreign_units,current_ap_exhausted,current_ar_exhausted,duplicate_reversal", ",") Do
				Cases.Add(CharacterizeCase(Fixture, Name));
			EndDo;
		EndIf;
	Except
		ErrorText = DetailErrorDescription(ErrorInfo());
		Status = ?(StrFind(ErrorText, "CHARACTERIZATION_NO_FIXTURE") > 0, "NOT_RUN", "FAIL");
		Cases.Add(New Structure("name,passed,error", Phase, False, ErrorText));
	EndTry;
	For Each CaseResult In Cases Do
		If Not CaseResult.passed And Status = "PASS" Then Status = "FAIL"; EndIf;
	EndDo;
	Result = New Structure("run_id,status,cases", RunID, Status, Cases);
	WriteFileJSON(ResultPath, Result);
	Return Result;
EndFunction

Procedure PrepareARFixture(Fixture)
	// The snapshot has VND-only AR. Create a real AR maker's USD acceptance
	// draft using the existing USD AP entity, partner and contract.
	Q = New Query("SELECT TOP 1 Ref AS AP, PhapNhan AS PN, DoiTac AS Partner, HopDong AS Contract
		|FROM Document.HoaDonNhaCungCap
		|WHERE Posted AND NOT DeletionMark
		| AND TienTe = &USD AND HopDong.DongTienThanhToan = &USD
		|ORDER BY Ref");
	Q.SetParameter("USD", Catalogs.TienTe.FindByCode("USD"));
	Rows = Q.Execute().Unload();
	If Rows.Count() = 0 Then
		Raise "CHARACTERIZATION_NO_FIXTURE: need existing posted USD AP contract";
	EndIf;
	Row = Rows[0];
	BeginTransaction();
	Try
		Doc = Documents.BienBanNghiemThuGiaiDoan.CreateDocument();
		Doc.Number = "NR-" + Left(Fixture.run_id, 8) + "-1";
		Doc.Date = CurrentSessionDate();
		Doc.PhapNhan = Row.PN;
		Doc.DoiTac = Row.Partner;
		Doc.HopDong = Row.Contract;
		Doc.GiaTriNghiemThuChuaVAT = 1000000;
		Doc.DienGiai = "USD netting characterization " + Fixture.run_id;
		Doc.NguoiTao = UserName();
		Doc.TrangThai = Enums.TrangThaiNghiemThuAR.DuThao;
		Doc.Write(DocumentWriteMode.Write);
		Doc.TrangThai = Enums.TrangThaiNghiemThuAR.ChoDuyetNoiBo;
		Doc.Write(DocumentWriteMode.Write);
		Fixture.Insert("usd_ar", String(Doc.Ref.UUID()));
		Fixture.Insert("usd_ap", String(Row.AP.UUID()));
		CommitTransaction();
	Except
		RollbackTransaction();
		Raise;
	EndTry;
EndProcedure

Procedure PrepareFixture(Fixture)
	Fixture.Insert("docs", New Array);
	BeginTransaction();
	Try
		For Each CurrencyCode In StrSplit("VND,USD", ",") Do
			// Pick one source at a time; joining all AR/AP invoices by entity
			// creates millions of candidate pairs before TOP 1 can select a row.
			Q = New Query("SELECT TOP 1 Ref AS AR, PhapNhan AS PN
				|FROM Document.HoaDonGTGTDauRa
				|WHERE Posted AND NOT DeletionMark
				| AND HopDong.DongTienThanhToan = &Currency
				|ORDER BY Ref");
			Q.SetParameter("Currency", Catalogs.TienTe.FindByCode(CurrencyCode));
			If CurrencyCode = "USD" Then
				ARRef = Documents.BienBanNghiemThuGiaiDoan.GetRef(New UUID(Fixture.usd_ar));
				If ARRef.Posted Or ARRef.NguoiTao <> "ketoan_ar"
					Or ARRef.TrangThai <> Enums.TrangThaiNghiemThuAR.ChoDuyetNoiBo
					Or ARRef.HopDong.DongTienThanhToan <> Catalogs.TienTe.FindByCode("USD") Then
					Raise "CHARACTERIZATION_STATE: expected real AR maker's pending USD draft";
				EndIf;
				ARSource = New Structure("AR,PN", ARRef, ARRef.PhapNhan);
			Else
				Rows = Q.Execute().Unload();
				If Rows.Count() = 0 Then
					Raise "CHARACTERIZATION_NO_FIXTURE: need posted AR for " + CurrencyCode;
				EndIf;
				ARSource = Rows[0];
			EndIf;
			Q.Text = "SELECT TOP 1 Ref AS AP
				|FROM Document.HoaDonNhaCungCap
				|WHERE Posted AND NOT DeletionMark AND PhapNhan = &PN
				| AND TienTe = &Currency AND HopDong.DongTienThanhToan = &Currency
				| AND (&AnyAP OR Ref = &ChosenAP)
				|ORDER BY Ref";
			Q.SetParameter("PN", ARSource.PN);
			Q.SetParameter("AnyAP", CurrencyCode = "VND");
			Q.SetParameter("ChosenAP", Documents.HoaDonNhaCungCap.GetRef(New UUID(Fixture.usd_ap)));
			Rows = Q.Execute().Unload();
			If Rows.Count() = 0 Then
				Raise "CHARACTERIZATION_NO_FIXTURE: need posted AP in selected AR entity for " + CurrencyCode;
			EndIf;
			APSource = Rows[0].AP;
			Q.Text = "SELECT TOP 1 Cash.TaiKhoanTien AS Bank
				|FROM AccumulationRegister.DongTien.Balance(,
				| PhapNhan = &PN AND TienTe = &VND AND TaiKhoanTien.TienTe = &VND) AS Cash
				|GROUP BY Cash.TaiKhoanTien
				|HAVING SUM(Cash.SoTienBalance) >= 100
				|ORDER BY Cash.TaiKhoanTien";
			Q.SetParameter("VND", Catalogs.TienTe.FindByCode("VND"));
			Bank = Catalogs.TaiKhoanTien.EmptyRef();
			If CurrencyCode = "VND" Then
				Rows = Q.Execute().Unload();
				If Rows.Count() = 0 Then
					Raise "CHARACTERIZATION_NO_FIXTURE: need funded VND bank in selected AR/AP entity for " + CurrencyCode;
				EndIf;
				Bank = Rows[0].Bank;
			EndIf;
			Row = New Structure("AR,AP,Bank", ARSource.AR, APSource, Bank);
			Q.Text = "SELECT MAX(Period) AS Latest FROM (
				| SELECT Period FROM AccumulationRegister.CongNoPhaiThu WHERE PhapNhan = &PN
				| UNION ALL SELECT Period FROM AccumulationRegister.CongNoPhaiTra WHERE PhapNhan = &PN
				| UNION ALL SELECT Period FROM AccumulationRegister.DongTien WHERE PhapNhan = &PN) AS Movements";
			Q.SetParameter("PN", Row.AP.PhapNhan);
			Latest = Q.Execute().Unload()[0].Latest;
			TestDate = CurrentSessionDate();
			If ValueIsFilled(Latest) And Latest > TestDate Then TestDate = Latest; EndIf;
			TestDate = BegOfDay(TestDate) + 86400 + 43200;
			Netting = Documents.CanTruCongNoNoiBo.CreateDocument();
			Netting.Number = "NR-" + Left(Fixture.run_id, 8) + ?(CurrencyCode = "VND", "-2", "-6");
			Netting.Date = TestDate;
			Netting.PhapNhan = Row.AP.PhapNhan;
			Netting.DoiTacNoiBo = Row.AR.DoiTac;
			Netting.HopDongAR = Row.AR.HopDong;
			Netting.HopDongAP = Row.AP.HopDong;
			Netting.ChungTuGocAR = Row.AR;
			Netting.ChungTuGocAP = Row.AP;
			Netting.TienTe = Catalogs.TienTe.FindByCode(CurrencyCode);
			Netting.SoTienCanTru = ?(CurrencyCode = "VND", 60, 600000);
			Netting.LaCanTruBacCau = Row.AR.DoiTac <> Row.AP.DoiTac;
			If Netting.LaCanTruBacCau Then
				Netting.DoiTacTrungGian = Row.AP.DoiTac;
				Netting.SoVanBanThoaThuan = "CHARACTERIZATION " + Fixture.run_id;
			EndIf;
			SavePending(Netting, True);
			Fixture.Insert(Lower(CurrencyCode) + "_netting", String(Netting.Ref.UUID()));
			Fixture.docs.Add(New Structure("kind,id", "netting", String(Netting.Ref.UUID())));
			If CurrencyCode = "VND" Then
				Payment = Documents.UyNhiemChi.CreateDocument();
				Payment.Number = "NR-" + Left(Fixture.run_id, 8) + "-3";
				Payment.Date = TestDate + 86400;
				Payment.PhapNhan = Row.AP.PhapNhan;
				Payment.DoiTac = Row.AP.DoiTac;
				Payment.HopDong = Row.AP.HopDong;
				Payment.ChungTuGoc = Row.AP;
				Payment.TaiKhoanTien = Row.Bank;
				Payment.TienTe = Catalogs.TienTe.FindByCode("VND");
				Payment.SoTien = 60;
				Payment.TyGia = 1;
				SavePending(Payment, False);
				Fixture.Insert("payment", String(Payment.Ref.UUID()));
				Fixture.docs.Add(New Structure("kind,id", "payment", String(Payment.Ref.UUID())));
				Fixture.Insert("reversals", New Array);
				For Index = 1 To 2 Do
					Reversal = Documents.UyNhiemChi.CreateDocument();
					Reversal.Number = "NR-" + Left(Fixture.run_id, 8) + "-" + String(Index + 3);
					FillPropertyValues(Reversal, Payment, "PhapNhan,DoiTac,HopDong,TaiKhoanTien,TienTe,SoTien,TyGia");
					Reversal.Date = Payment.Date + Index * 86400;
					Reversal.ChungTuGoc = Payment.Ref;
					Reversal.LaTraSoatHoanTra = True;
					SavePending(Reversal, False);
					Fixture.reversals.Add(String(Reversal.Ref.UUID()));
					Fixture.docs.Add(New Structure("kind,id", "payment", String(Reversal.Ref.UUID())));
				EndDo;
			EndIf;
		EndDo;
		CommitTransaction();
	Except
		RollbackTransaction();
		Raise;
	EndTry;
EndProcedure

Procedure SavePending(Doc, IsNetting)
	Doc.NguoiLap = UserName();
	Doc.TrangThai = ?(IsNetting, "DuThao", Enums.TrangThaiLenhThanhToan.DuThao);
	Doc.Write(DocumentWriteMode.Write);
	Doc.TrangThai = ?(IsNetting, "ChoDuyet", Enums.TrangThaiLenhThanhToan.ChoDuyet);
	Doc.Write(DocumentWriteMode.Write);
EndProcedure

Procedure ApproveFixture(Fixture)
	BeginTransaction();
	Try
		ARDoc = Documents.BienBanNghiemThuGiaiDoan.GetRef(New UUID(Fixture.usd_ar)).GetObject();
		If ARDoc.Posted Or ARDoc.NguoiTao <> "ketoan_ar"
			Or (ARDoc.TrangThai <> Enums.TrangThaiNghiemThuAR.ChoDuyetNoiBo
				And ARDoc.TrangThai <> Enums.TrangThaiNghiemThuAR.DaDuyetNoiBo) Then
			Raise "CHARACTERIZATION_STATE: expected real AR maker's unposted USD acceptance";
		EndIf;
		ARDoc.NguoiDuyet = UserName();
		ARDoc.TrangThai = Enums.TrangThaiNghiemThuAR.DaDuyetNoiBo;
		ARDoc.Write(DocumentWriteMode.Write);
		For Each Item In Fixture.docs Do
			DocRef = ?(Item.kind = "netting", Documents.CanTruCongNoNoiBo.GetRef(New UUID(Item.id)),
				Documents.UyNhiemChi.GetRef(New UUID(Item.id)));
			Doc = DocRef.GetObject();
			If Doc.Posted Or Doc.NguoiLap <> "ketoan_ap" Then
				Raise "CHARACTERIZATION_STATE: expected real maker's unposted document";
			EndIf;
			Doc.NguoiDuyet = UserName();
			Doc.TrangThai = ?(Item.kind = "netting", "DaDuyet", Enums.TrangThaiLenhThanhToan.DaDuyet);
			Doc.Write(DocumentWriteMode.Write);
		EndDo;
		CommitTransaction();
	Except
		RollbackTransaction();
		Raise;
	EndTry;
EndProcedure

Function CharacterizeCase(Fixture, Name)
	ExpectedError = "";
	Passed = False;
	ErrorText = "";
	BeginTransaction();
	Try
		NettingID = ?(Name = "foreign_units", Fixture.usd_netting, Fixture.vnd_netting);
		Netting = Documents.CanTruCongNoNoiBo.GetRef(New UUID(NettingID)).GetObject();
		Amount = ?(Name = "foreign_units", 1000000, 100);
		Foreign = ?(Name = "foreign_units", 1, 0);
		// Exact literal balances are fixture writes to real register record sets.
		// Every case rolls them back along with all posting/reposting writes.
		SetBalance("CongNoPhaiThu", Netting.ChungTuGocAR, Netting.Date - 43200, Amount, Foreign);
		SetBalance("CongNoPhaiTra", Netting.ChungTuGocAP, Netting.Date - 43200, Amount, Foreign);
		Payment = Documents.UyNhiemChi.GetRef(New UUID(Fixture.payment)).GetObject();
		If Name = "backdated_netting" Or Name = "current_ap_exhausted" Or Name = "duplicate_reversal" Then
			If Name = "current_ap_exhausted" Then Payment.SoTien = 100; EndIf;
			Payment.TrangThai = Enums.TrangThaiLenhThanhToan.DaGhiSo;
			Payment.Write(DocumentWriteMode.Posting);
		EndIf;
		If Name = "duplicate_reversal" Then
			AssertMovement("CongNoPhaiTra", Payment.Ref, 60, AccumulationRecordType.Expense);
			AssertMovement("DongTien", Payment.Ref, 60, AccumulationRecordType.Expense);
			Reversal = Documents.UyNhiemChi.GetRef(New UUID(Fixture.reversals[0])).GetObject();
			Reversal.TrangThai = Enums.TrangThaiLenhThanhToan.DaGhiSo;
			Reversal.Write(DocumentWriteMode.Posting);
			AssertMovement("CongNoPhaiTra", Reversal.Ref, 60, AccumulationRecordType.Receipt);
			AssertMovement("DongTien", Reversal.Ref, 60, AccumulationRecordType.Receipt);
			Reversal.Write(DocumentWriteMode.Posting);
			AssertMovement("CongNoPhaiTra", Reversal.Ref, 60, AccumulationRecordType.Receipt);
			AssertMovement("DongTien", Reversal.Ref, 60, AccumulationRecordType.Receipt);
			Reversal = Documents.UyNhiemChi.GetRef(New UUID(Fixture.reversals[1])).GetObject();
			Reversal.TrangThai = Enums.TrangThaiLenhThanhToan.DaGhiSo;
			ExpectedError = "Chống hoàn trả 2 lần";
			Reversal.Write(DocumentWriteMode.Posting);
		Else
			If Name = "current_ar_exhausted" Then
				SetBalance("CongNoPhaiThu", Netting.ChungTuGocAR, Payment.Date, 0, 0);
			EndIf;
			If Name = "current_ap_exhausted" Then ExpectedError = "LỖI CẤN TRỪ AP"; EndIf;
			If Name = "current_ar_exhausted" Then ExpectedError = "LỖI CẤN TRỪ AR"; EndIf;
			Netting.Write(DocumentWriteMode.Posting);
			ExpectedAmount = ?(Name = "backdated_netting", 40, ?(Name = "foreign_units", 600000, 60));
			AssertNetting(Netting, Amount, ?(Name = "backdated_netting", 40, Amount), ExpectedAmount, Foreign);
			If Name = "netting_repost" Or Name = "backdated_netting" Then
				Netting.Write(DocumentWriteMode.Posting);
				AssertNetting(Netting, Amount, ?(Name = "backdated_netting", 40, Amount), ExpectedAmount, Foreign);
				Netting.SoTienCanTru = 30;
				Netting.Write(DocumentWriteMode.Posting);
				AssertNetting(Netting, Amount, ?(Name = "backdated_netting", 40, Amount), 30, Foreign);
			EndIf;
		EndIf;
		If ExpectedError <> "" Then Raise "CHARACTERIZATION_ASSERT: expected balance/duplicate rejection"; EndIf;
		Passed = True;
	Except
		ErrorText = DetailErrorDescription(ErrorInfo());
		Passed = ExpectedError <> "" And StrFind(ErrorText, ExpectedError) > 0;
	EndTry;
	RollbackTransaction();
	Return New Structure("name,passed,error", Name, Passed, ?(Passed, "", ErrorText));
EndFunction

Procedure AssertNetting(Doc, BeforeAR, BeforeAP, Amount, Foreign)
	AR = CurrentBalance("CongNoPhaiThu", Doc.ChungTuGocAR);
	AP = CurrentBalance("CongNoPhaiTra", Doc.ChungTuGocAP);
	If Doc.SoTienCanTru <> Amount Or AR.VND <> BeforeAR - Amount Or AP.VND <> BeforeAP - Amount
		Or AR.USD <> Foreign Or AP.USD <> Foreign Then
		Raise StrTemplate("CHARACTERIZATION_ASSERT: amount=%1 expected=%2; AR VND=%3 expected=%4 foreign=%5; AP VND=%6 expected=%7 foreign=%8; expected foreign=%9",
			Doc.SoTienCanTru, Amount, AR.VND, BeforeAR - Amount, AR.USD, AP.VND, BeforeAP - Amount, AP.USD, Foreign);
	EndIf;
	AssertMovement("CongNoPhaiThu", Doc.Ref, Amount, AccumulationRecordType.Expense);
	AssertMovement("CongNoPhaiTra", Doc.Ref, Amount, AccumulationRecordType.Expense);
	Q = New Query("SELECT COUNT(*) AS Rows, ISNULL(SUM(GL.SoTien), 0) AS Amount,
		| ISNULL(SUM(GL.SoTienNgoaiTe), 0) AS ForeignAmount,
		| ISNULL(SUM(CASE WHEN GL.AccountDr.Code = ""3312"" THEN GL.SoTien ELSE 0 END), 0) AS APDebit,
		| ISNULL(SUM(CASE WHEN GL.AccountCr.Code = ""1312"" THEN GL.SoTien ELSE 0 END), 0) AS ARCredit,
		| ISNULL(SUM(CASE WHEN GL.AccountDr.Code = ""1388"" THEN GL.SoTien ELSE 0 END), 0) AS BridgeDebit,
		| ISNULL(SUM(CASE WHEN GL.AccountCr.Code = ""1388"" THEN GL.SoTien ELSE 0 END), 0) AS BridgeCredit
		|FROM AccountingRegister.SoCaiKeToan AS GL WHERE GL.Recorder = &Doc");
	Q.SetParameter("Doc", Doc.Ref);
	GL = Q.Execute().Unload()[0];
	ExpectedRows = ?(Doc.LaCanTruBacCau, 2, 1);
	ExpectedBridge = ?(Doc.LaCanTruBacCau, Amount, 0);
	If GL.Rows <> ExpectedRows Or GL.Amount <> Amount * ExpectedRows Or GL.ForeignAmount <> 0
		Or GL.APDebit <> Amount Or GL.ARCredit <> Amount
		Or GL.BridgeDebit <> ExpectedBridge Or GL.BridgeCredit <> ExpectedBridge Then
		Raise StrTemplate("CHARACTERIZATION_ASSERT: netting GL rows=%1 expected=%2; sum=%3 expected=%4; APDebit=%5 ARCredit=%6 BridgeDebit=%7 BridgeCredit=%8 foreign=%9",
			GL.Rows, ExpectedRows, GL.Amount, Amount * ExpectedRows, GL.APDebit, GL.ARCredit, GL.BridgeDebit, GL.BridgeCredit, GL.ForeignAmount);
	EndIf;
EndProcedure

Procedure AssertMovement(RegisterName, DocRef, Amount, ExpectedType)
	Q = New Query("SELECT COUNT(*) AS Rows, ISNULL(SUM(SoTien), 0) AS Amount,
		| ISNULL(SUM(SoTienNgoaiTe), 0) AS ForeignAmount,
		| ISNULL(SUM(CASE WHEN RecordType = &ExpectedType THEN 1 ELSE 0 END), 0) AS DirectionRows,
		| ISNULL(SUM(CASE WHEN RecordType = VALUE(AccumulationRecordType.Expense) THEN -SoTien ELSE SoTien END), 0) AS SignedAmount,
		| ISNULL(SUM(CASE WHEN RecordType = VALUE(AccumulationRecordType.Expense) THEN -SoTienNgoaiTe ELSE SoTienNgoaiTe END), 0) AS SignedForeignAmount
		|FROM AccumulationRegister." + RegisterName + " WHERE Recorder = &Doc");
	Q.SetParameter("Doc", DocRef);
	Q.SetParameter("ExpectedType", ExpectedType);
	Row = Q.Execute().Unload()[0];
	ExpectedSigned = ?(ExpectedType = AccumulationRecordType.Expense, -Amount, Amount);
	If Row.Rows <> 1 Or Row.DirectionRows <> 1 Or Row.Amount <> Amount Or Row.SignedAmount <> ExpectedSigned
		Or Row.ForeignAmount <> 0 Or Row.SignedForeignAmount <> 0 Then
		Raise "CHARACTERIZATION_ASSERT: " + RegisterName + " recorder=" + String(DocRef)
			+ StrTemplate(" rows=%1 expected=1; direction rows=%2 expected=1; raw VND=%3 expected=%4; signed VND=%5 expected=%6; raw foreign=%7 signed foreign=%8 expected=0",
				Row.Rows, Row.DirectionRows, Row.Amount, Amount, Row.SignedAmount, ExpectedSigned, Row.ForeignAmount, Row.SignedForeignAmount);
	EndIf;
EndProcedure

Function CurrentBalance(RegisterName, Invoice)
	Q = New Query("SELECT ISNULL(SUM(SoTienBalance), 0) AS VND,
		| ISNULL(SUM(SoTienNgoaiTeBalance), 0) AS USD
		|FROM AccumulationRegister." + RegisterName + ".Balance(,
		| PhapNhan = &PN AND DoiTac = &Partner AND HopDong = &Contract AND ChungTuGoc = &Invoice)");
	Q.SetParameter("PN", Invoice.PhapNhan);
	Q.SetParameter("Partner", Invoice.DoiTac);
	Q.SetParameter("Contract", Invoice.HopDong);
	Q.SetParameter("Invoice", Invoice);
	Return Q.Execute().Unload()[0];
EndFunction

Procedure SetBalance(RegisterName, Invoice, Period, VND, USD)
	Balance = CurrentBalance(RegisterName, Invoice);
	Records = AccumulationRegisters[RegisterName].CreateRecordSet();
	Records.Filter.Recorder.Set(Invoice);
	Records.Read();
	Record = Records.Add();
	Record.Period = Period;
	Record.RecordType = AccumulationRecordType.Receipt;
	Record.PhapNhan = Invoice.PhapNhan;
	Record.DoiTac = Invoice.DoiTac;
	Record.HopDong = Invoice.HopDong;
	Record.ChungTuGoc = Invoice;
	Record.SoTien = VND - Balance.VND;
	Record.SoTienNgoaiTe = USD - Balance.USD;
	Records.Write();
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
