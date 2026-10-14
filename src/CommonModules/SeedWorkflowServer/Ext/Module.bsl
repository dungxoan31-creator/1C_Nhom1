// /C RunSeedWorkflow;run_id;result_path;phase;manifest_path
// Ten financial documents per month. No privileged mode or financial Admin writes.

Function RunPhase(Val RunId, Val ResultPath, Val Phase, Val ManifestPath) Export
	ValidatePaths(RunId, ResultPath, Phase, ManifestPath);
	Passed = False;
	ErrorText = "";
	Try
		If Phase = "enable" Or Phase = "restore" Then
			RequireSession("Admin", "QuanTriHeThong", False);
			If Phase = "enable" Then
				ManifestFile = New File(ManifestPath);
				If ManifestFile.Exist() Then Raise "SEED_MANIFEST_EXISTS"; EndIf;
				Snapshot = New Structure("run_id,prior_enabled", RunId, Constants.ChoPhepSinhDuLieuMau.Get());
				WriteFileJSON(ManifestPath, Snapshot);
				Constants.ChoPhepSinhDuLieuMau.Set(True);
			Else
				Snapshot = ReadFileJSON(ManifestPath);
				If Snapshot.Count() <> 2 Or Snapshot.run_id <> RunId Or TypeOf(Snapshot.prior_enabled) <> Type("Boolean") Then
					Raise "SEED_INVALID_FLAG_SNAPSHOT";
				EndIf;
				Constants.ChoPhepSinhDuLieuMau.Set(Snapshot.prior_enabled);
				If Constants.ChoPhepSinhDuLieuMau.Get() <> Snapshot.prior_enabled Then Raise "SEED_FLAG_RESTORE_FAILED"; EndIf;
			EndIf;
		ElsIf Phase = "master" Or Phase = "massive" Or Phase = "clean" Then
			RequireSession("Admin", "QuanTriHeThong");
			SeedDataCleanServer.ThucThiNapMasterData();
			If Phase <> "clean" Then GeneratorMasterDataServer.KhoiTaoMasterDataToanDien(); EndIf;
		Else
			Months = ?(Right(Phase, 6) = "-smoke", 1, 21);
			Domain = StrReplace(Phase, "-smoke", "");
			If Left(Phase, 6) = "check-" Then
				Domain = Mid(Phase, 7);
				RequireSession("ketoan_truong", "KeToanTruong");
				Manifest = ReadManifest(RunId, ManifestPath, Domain);
				BeginTransaction();
				Try
					// Preflight the entire exact list before the first approval/write.
					For Each Item In Manifest.refs Do
						Doc = Reference(Item).GetObject();
						ValidateProducedDocument(Doc, Manifest, False);
					EndDo;
					For Each Item In Manifest.refs Do
						Doc = Reference(Item).GetObject();
						ApproveAndPost(Doc, Manifest);
					EndDo;
					CommitTransaction();
				Except
					If TransactionActive() Then RollbackTransaction(); EndIf;
					Raise;
				EndTry;
			Else
				RequireMaker(Domain);
				ManifestFile = New File(ManifestPath);
				If ManifestFile.Exist() Then Raise "SEED_MANIFEST_EXISTS"; EndIf;
				Refs = New Array;
				BeginTransaction();
				Try
					If Domain = "ar" Then
						GeneratorARServer.SinhMauUAT(Refs, Months, RunId);
					ElsIf Domain = "ap" Then
						GeneratorAPServer.SinhMauUAT(Refs, Months, RunId);
					ElsIf Domain = "netting" Then
						SourceAR = ReadManifest(RunId, SiblingManifest(ManifestPath, RunId, "ar"), "ar");
						SourceAP = ReadManifest(RunId, SiblingManifest(ManifestPath, RunId, "ap"), "ap");
						If SourceAR.months <> Months Or SourceAP.months <> Months Then Raise "SEED_SOURCE_MONTHS"; EndIf;
						GeneratorNettingReconcileServer.SinhMauUAT(Refs, Months, RunId, SourceAR, SourceAP);
					Else
						Raise "SEED_UNKNOWN_PHASE";
					EndIf;
					Manifest = New Structure("run_id,phase,months,maker,checker,refs", RunId, Domain, Months, UserName(), "ketoan_truong", Refs);
					ValidateManifest(Manifest, RunId, Domain);
					For Each Item In Refs Do ValidateProducedDocument(Reference(Item).GetObject(), Manifest, False); EndDo;
					// Publish the exact list before committing; a failed commit yields FAIL and no checker launch.
					WriteFileJSON(ManifestPath, Manifest);
					CommitTransaction();
				Except
					If TransactionActive() Then RollbackTransaction(); EndIf;
					Raise;
				EndTry;
			EndIf;
		EndIf;
		Passed = True;
	Except
		ErrorText = DetailErrorDescription(ErrorInfo());
	EndTry;
	Cases = New Array;
	Cases.Add(New Structure("name,passed,error", Phase, Passed, ErrorText));
	Result = New Structure("run_id,status,cases", RunId, ?(Passed, "PASS", "FAIL"), Cases);
	WriteFileJSON(ResultPath, Result);
	Return Result;
EndFunction

Procedure RequireSession(Val ExpectedUser, Val ExpectedRole, Val CheckFlag = True) Export
	Connection = Lower(StrReplace(InfoBaseConnectionString(), "\", "/"));
	If StrFind(Connection, "/scratch/uat/") = 0 Or StrFind(Connection, "infobase_fulldata") > 0 Then Raise "SEED_DISABLED: clone required"; EndIf;
	If UserName() <> ExpectedUser Or Not IsInRole(ExpectedRole) Then Raise "SEED_FORBIDDEN: actual user/role required"; EndIf;
	If CheckFlag Then QuanLyVongDoiChungTuServer.KiemTraChoPhepSinhDuLieuMau(ExpectedRole); EndIf;
EndProcedure

Procedure RequireMaker(Val Domain) Export
	If Domain = "ar" Then
		RequireSession("ketoan_ar", "KeToanPhaiThu");
	ElsIf Domain = "ap" Then
		RequireSession("ketoan_ap", "KeToanPhaiTra");
	ElsIf Domain = "netting" Then
		RequireSession("chuyenvien_doisoat", "ChuyenVienDoiSoatTapDoan");
	Else
		Raise "SEED_UNKNOWN_DOMAIN";
	EndIf;
EndProcedure

Procedure ValidateMonths(Val Months, Refs, Val RunId) Export
	If (Months <> 1 And Months <> 21) Or Refs = Undefined Or StrLen(RunId) <> 32 Or Not TransactionActive() Then
		Raise "SEED_WORKFLOW_REQUIRED: bounded run and manifest transaction required";
	EndIf;
EndProcedure

Function RequiredCatalog(Val CatalogName, Val Code) Export
	Ref = Catalogs[CatalogName].FindByCode(Code);
	If Not ValueIsFilled(Ref) Then Raise "SEED_MISSING_METADATA: " + CatalogName + "." + Code; EndIf;
	Return Ref;
EndFunction

Function PartnerContract(Val Partner) Export
	Q = New Query("SELECT TOP 1 Ref FROM Catalog.HopDong WHERE ChuSoHuu = &Partner AND DongTienThanhToan.Code = ""VND"" ORDER BY Code");
	Q.SetParameter("Partner", Partner);
	Rows = Q.Execute().Unload();
	If Rows.Count() = 0 Then Raise "SEED_MISSING_VND_CONTRACT"; EndIf;
	Return Rows[0].Ref;
EndFunction

Function NewSample(Val DocumentName, Val RunId, Val MonthIndex, Val ItemIndex, Val DayNumber) Export
	Y = ?(MonthIndex <= 12, 2025, 2026);
	M = ?(MonthIndex <= 12, MonthIndex, MonthIndex - 12);
	DocDate = Date(Y, M, DayNumber, 12, 0, 0);
	Number = "S-" + Left(RunId, 8) + "-" + Right("00" + String(MonthIndex), 2) + String(ItemIndex);
	Existing = Documents[DocumentName].FindByNumber(Number, DocDate);
	If ValueIsFilled(Existing) Then Raise "SEED_NUMBER_COLLISION: " + String(Existing); EndIf;
	Doc = Documents[DocumentName].CreateDocument();
	Doc.Number = Number;
	Doc.Date = DocDate;
	If Doc.Metadata().Attributes.Find("NguoiTao") <> Undefined Then Doc.NguoiTao = UserName(); Else Doc.NguoiLap = UserName(); EndIf;
	Doc.NguoiDuyet = "ketoan_truong";
	If Doc.Metadata().Attributes.Find("DienGiai") <> Undefined Then Doc.DienGiai = "SEED_RUN:" + RunId; Else Doc.GhiChu = "SEED_RUN:" + RunId; EndIf;
	Return Doc;
EndFunction

Procedure SavePending(Doc, Refs) Export
	DocName = Doc.Metadata().Name;
	If DocName = "BienBanNghiemThuGiaiDoan" Then
		Doc.TrangThai = Enums.TrangThaiNghiemThuAR.DuThao;
	ElsIf DocName = "HoaDonGTGTDauRa" Then
		Doc.TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.DuThao;
	ElsIf DocName = "HoaDonNhaCungCap" Then
		Doc.TrangThai = Enums.TrangThaiHoaDonAP.DuThao;
	ElsIf DocName = "UyNhiemChi" Then
		Doc.TrangThai = Enums.TrangThaiLenhThanhToan.DuThao;
	Else
		Doc.TrangThai = "DuThao";
	EndIf;
	Doc.Write(DocumentWriteMode.Write);
	If Doc.Posted Then Raise "SEED_MAKER_POSTED"; EndIf;
	Refs.Add(New Structure("document,uuid", DocName, Lower(String(Doc.Ref.UUID()))));
EndProcedure

Function SiblingManifest(Val ManifestPath, Val RunId, Val Domain)
	FileInfo = New File(ManifestPath);
	Return FileInfo.Path + RunId + "-" + Domain + ".manifest.json";
EndFunction

Function ReadManifest(Val RunId, Val ManifestPath, Val Domain)
	Manifest = ReadFileJSON(ManifestPath);
	ValidateManifest(Manifest, RunId, Domain);
	Return Manifest;
EndFunction

Function DocumentOrder(Val Domain)
	If Domain = "ar" Then Return StrSplit("BienBanNghiemThuGiaiDoan,HoaDonGTGTDauRa,BienBanNghiemThuGiaiDoan,HoaDonGTGTDauRa,BaoCoNganHang", ","); EndIf;
	If Domain = "ap" Then Return StrSplit("HoaDonNhaCungCap,HoaDonNhaCungCap,UyNhiemChi", ","); EndIf;
	If Domain = "netting" Then Return StrSplit("CanTruCongNoNoiBo,BangKeDoiSoatKenhThanhToan", ","); EndIf;
	Raise "SEED_UNKNOWN_DOMAIN";
EndFunction

Procedure ValidateManifest(Manifest, Val RunId, Val Domain)
	Order = DocumentOrder(Domain);
	ExpectedMaker = ?(Domain = "ar", "ketoan_ar", ?(Domain = "ap", "ketoan_ap", "chuyenvien_doisoat"));
	If Manifest.Count() <> 6 Or Manifest.run_id <> RunId Or Manifest.phase <> Domain
		Or Manifest.maker <> ExpectedMaker Or Manifest.checker <> "ketoan_truong"
		Or (Manifest.months <> 1 And Manifest.months <> 21)
		Or Manifest.refs.Count() <> Order.Count() * Manifest.months Then Raise "SEED_INVALID_MANIFEST"; EndIf;
	Seen = New Map;
	Index = 0;
	For Each Item In Manifest.refs Do
		If Item.Count() <> 2 Or Item.document <> Order[Index % Order.Count()] Or Seen.Get(Item.uuid) <> Undefined Then Raise "SEED_INVALID_REFERENCE_LIST"; EndIf;
		Ref = Reference(Item);
		If Not ValueIsFilled(Ref) Then Raise "SEED_INVALID_REFERENCE"; EndIf;
		Seen.Insert(Item.uuid, True);
		Index = Index + 1;
	EndDo;
EndProcedure

Function Reference(Item)
	Return Documents[Item.document].GetRef(New UUID(Item.uuid));
EndFunction

Procedure ValidateProducedDocument(Doc, Manifest, Val ExpectedPosted)
	If Doc = Undefined Or Doc.Posted <> ExpectedPosted Or Doc.DeletionMark Then Raise "SEED_REFERENCE_NOT_IN_EXPECTED_STATE"; EndIf;
	Creator = ?(Doc.Metadata().Attributes.Find("NguoiTao") <> Undefined, Doc.NguoiTao, Doc.NguoiLap);
	Tag = ?(Doc.Metadata().Attributes.Find("DienGiai") <> Undefined, Doc.DienGiai, Doc.GhiChu);
	If Creator <> Manifest.maker Or Doc.NguoiDuyet <> Manifest.checker Or Tag <> "SEED_RUN:" + Manifest.run_id Then Raise "SEED_REFERENCE_IDENTITY_MISMATCH"; EndIf;
	If Not ExpectedPosted Then
		If Doc.Metadata().Attributes.Find("TrangThaiHDDT") <> Undefined Then State = String(Doc.TrangThaiHDDT); Else State = String(Doc.TrangThai); EndIf;
		If State <> "DuThao" And State <> "Dự thảo" Then Raise "SEED_REFERENCE_NOT_DRAFT"; EndIf;
		Q = New Query("SELECT COUNT(*) AS Cnt FROM AccountingRegister.SoCaiKeToan WHERE Recorder = &Recorder");
		Q.SetParameter("Recorder", Doc.Ref);
		If Q.Execute().Unload()[0].Cnt <> 0 Then Raise "SEED_DRAFT_HAS_GL_MOVEMENTS"; EndIf;
	EndIf;
EndProcedure

Function SourceDocument(Manifest, Val DocumentName, Val MonthIndex, Val ItemIndex) Export
	Found = 0;
	For Each Item In Manifest.refs Do
		If Item.document <> DocumentName Then Continue; EndIf;
		Doc = Reference(Item).GetObject();
		ValidateProducedDocument(Doc, Manifest, True);
		DocMonth = (Year(Doc.Date) - 2025) * 12 + Month(Doc.Date);
		If DocMonth = MonthIndex Then
			Found = Found + 1;
			If Found = ItemIndex Then Return Doc.Ref; EndIf;
		EndIf;
	EndDo;
	Raise "SEED_SOURCE_REFERENCE_MISSING";
EndFunction

Procedure ApproveAndPost(Doc, Manifest)
	ValidateProducedDocument(Doc, Manifest, False);
	PhanQuyenBaoMatServer.KiemTraMakerChecker(Manifest.maker, Manifest.checker, UserName());
	Name = Doc.Metadata().Name;
	If Name = "BienBanNghiemThuGiaiDoan" Then
		Doc.TrangThai = Enums.TrangThaiNghiemThuAR.ChoDuyetNoiBo;
		Doc.Write(DocumentWriteMode.Write);
		Doc.TrangThai = Enums.TrangThaiNghiemThuAR.DaDuyetNoiBo;
	ElsIf Name = "HoaDonGTGTDauRa" Then
		Doc.TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.ChoKySo;
		Doc.Write(DocumentWriteMode.Write);
		Doc.TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.DaPhatHanh;
	ElsIf Name = "HoaDonNhaCungCap" Then
		// Persist every enumerated approval stage before final accounting/posting.
		For Each State In StrSplit("ChoDuyetKyThuat,ChoDuyetPM,ChoDuyetITDirector,ChoDuyetCFO,ChoKeToanAP", ",") Do
			Doc.TrangThai = Enums.TrangThaiHoaDonAP[State];
			Doc.Write(DocumentWriteMode.Write);
		EndDo;
		Doc.TrangThai = Enums.TrangThaiHoaDonAP.DaGhiSo;
	ElsIf Name = "UyNhiemChi" Then
		Doc.TrangThai = Enums.TrangThaiLenhThanhToan.ChoDuyet;
		Doc.Write(DocumentWriteMode.Write);
		Doc.TrangThai = Enums.TrangThaiLenhThanhToan.DaDuyet;
		Doc.Write(DocumentWriteMode.Write);
		Doc.TrangThai = Enums.TrangThaiLenhThanhToan.DaGuiNganHang;
		Doc.Write(DocumentWriteMode.Write);
		Doc.TrangThai = Enums.TrangThaiLenhThanhToan.DaGhiSo;
	Else
		Doc.TrangThai = "ChoDuyet";
		Doc.Write(DocumentWriteMode.Write);
		Doc.TrangThai = "DaDuyet";
		Doc.Write(DocumentWriteMode.Write);
		If Name = "BaoCoNganHang" Or Name = "BangKeDoiSoatKenhThanhToan" Then Doc.TrangThai = "DaDoiSoat"; EndIf;
	EndIf;
	If Name <> "HoaDonNhaCungCap" And Name <> "UyNhiemChi" Then Doc.Write(DocumentWriteMode.Write); EndIf;
	Doc.Write(DocumentWriteMode.Posting);
	Persisted = Doc.Ref.GetObject();
	ValidateProducedDocument(Persisted, Manifest, True);
	Q = New Query("SELECT COUNT(*) AS Cnt FROM AccountingRegister.SoCaiKeToan WHERE Recorder = &Recorder");
	Q.SetParameter("Recorder", Doc.Ref);
	If Q.Execute().Unload()[0].Cnt = 0 Then Raise "SEED_POST_HAS_NO_GL_MOVEMENTS"; EndIf;
	ValidateFreshGL(Doc.Ref);
	BeforeMovements = QuanLyVongDoiChungTuServer.LayDauVanMovements(Doc.Ref);
	Doc.Write(DocumentWriteMode.Posting);
	If QuanLyVongDoiChungTuServer.LayDauVanMovements(Doc.Ref) <> BeforeMovements Then
		Raise "SEED_SAME_INSTANCE_REPOST_CHANGED_MOVEMENTS";
	EndIf;
EndProcedure

Procedure ValidateFreshGL(Val Recorder)
	// Only this just-posted document. Legacy missing analytics remain unchanged.
	Q = New Query("SELECT SC.AccountDr.Code AS DebitCode, SC.AccountCr.Code AS CreditCode,
		| SC.DoiTacNo, SC.HopDongNo, SC.DoiTacCo, SC.HopDongCo
		| FROM AccountingRegister.SoCaiKeToan AS SC WHERE SC.Recorder = &Recorder");
	Q.SetParameter("Recorder", Recorder);
	ControlAccounts = StrSplit("1311,1312,3311,3312,3313,1388,3388", ",");
	For Each Entry In Q.Execute().Unload() Do
		If ControlAccounts.Find(TrimAll(Entry.DebitCode)) <> Undefined Then
			If Not ValueIsFilled(Entry.DoiTacNo) Or Not ValueIsFilled(Entry.HopDongNo) Then
				Raise "SEED_FRESH_GL_MISSING_ANALYTICS: debit " + Entry.DebitCode + "; recorder=" + String(Recorder);
			EndIf;
		EndIf;
		If ControlAccounts.Find(TrimAll(Entry.CreditCode)) <> Undefined Then
			If Not ValueIsFilled(Entry.DoiTacCo) Or Not ValueIsFilled(Entry.HopDongCo) Then
				Raise "SEED_FRESH_GL_MISSING_ANALYTICS: credit " + Entry.CreditCode + "; recorder=" + String(Recorder);
			EndIf;
		EndIf;
	EndDo;
EndProcedure

Procedure ValidatePaths(Val RunId, Val ResultPath, Val Phase, Val ManifestPath)
	If StrLen(RunId) <> 32 Then Raise "SEED_INVALID_RUN_ID"; EndIf;
	For Index = 1 To StrLen(RunId) Do
		If StrFind("0123456789abcdef", Mid(RunId, Index, 1)) = 0 Then Raise "SEED_INVALID_RUN_ID"; EndIf;
	EndDo;
	Allowed = StrSplit("enable,restore,master,massive,clean,ar,ap,netting,ar-smoke,ap-smoke,netting-smoke,check-ar,check-ap,check-netting", ",");
	If Allowed.Find(Phase) = Undefined Then Raise "SEED_UNKNOWN_PHASE"; EndIf;
	Connection = StrReplace(InfoBaseConnectionString(), "\", "/");
	If StrFind(Lower(Connection), "/scratch/uat/") = 0 Then Raise "SEED_DISABLED: clone required"; EndIf;
	// Bind evidence to the exact file infobase's sibling results directory.
	Start = StrFind(Lower(Connection), "file=""", SearchDirection.FromBegin);
	If Start = 0 Then Raise "SEED_FILE_CLONE_REQUIRED"; EndIf;
	Tail = Mid(Connection, Start + 6);
	Finish = StrFind(Tail, """");
	If Finish = 0 Then Raise "SEED_INVALID_CONNECTION"; EndIf;
	IBDirectory = Left(Tail, Finish - 1);
	While Right(IBDirectory, 1) = "/" Do IBDirectory = Left(IBDirectory, StrLen(IBDirectory) - 1); EndDo;
	If Right(Lower(IBDirectory), 3) <> "/ib" Then Raise "SEED_FILE_CLONE_REQUIRED"; EndIf;
	EvidenceDirectory = Left(IBDirectory, StrLen(IBDirectory) - 3) + "/results/";
	ExpectedResult = EvidenceDirectory + RunId + "-" + Phase + ".json";
	Domain = StrReplace(StrReplace(Phase, "check-", ""), "-smoke", "");
	If Domain <> "ar" And Domain <> "ap" And Domain <> "netting" Then Domain = "control"; EndIf;
	ExpectedManifest = EvidenceDirectory + RunId + "-" + Domain + ".manifest.json";
	If Lower(StrReplace(ResultPath, "\", "/")) <> Lower(ExpectedResult)
		Or Lower(StrReplace(ManifestPath, "\", "/")) <> Lower(ExpectedManifest) Then Raise "SEED_INVALID_EVIDENCE_PATH"; EndIf;
	ResultFile = New File(ResultPath);
	If ResultFile.Exist() Then Raise "SEED_RESULT_EXISTS"; EndIf;
EndProcedure

Function ReadFileJSON(Val Path)
	Reader = New JSONReader;
	Reader.OpenFile(Path);
	Result = ReadJSON(Reader);
	Reader.Close();
	Return Result;
EndFunction

Procedure WriteFileJSON(Val Path, Data)
	Writer = New JSONWriter;
	Writer.OpenFile(Path);
	WriteJSON(Writer, Data);
	Writer.Close();
EndProcedure
