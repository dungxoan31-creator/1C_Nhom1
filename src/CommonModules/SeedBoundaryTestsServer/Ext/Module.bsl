// /C RunSeedBoundaries;run_id;result_path
// SUPPLEMENTARY ATOMIC AR workflow only. Does not verify legacy batch-50 commits.
// Four committed draft canaries remain on the disposable clone for inspection.

Function RunBoundaries(Val RunId, Val ResultPath) Export
	SeedWorkflowServer.RequireMaker("ar");
	ValidateResultPath(RunId, ResultPath);
	If TransactionActive() Then Raise "BOUNDARY_REQUIRES_NO_OUTER_TRANSACTION"; EndIf;
	Cases = New Array;
	AllPassed = True;
	ResultFile = New File(ResultPath);
	For Each IndexText In StrSplit("1,49,50,51", ",") Do
		Index = Number(IndexText);
		Passed = False;
		ErrorText = "";
		Try
			CheckBoundary(RunId, ResultFile.Path, Index);
			Passed = True;
		Except
			ErrorText = DetailErrorDescription(ErrorInfo());
			If TransactionActive() Then RollbackTransaction(); EndIf;
		EndTry;
		AllPassed = AllPassed And Passed;
		Cases.Add(New Structure("name,passed,error", "Boundary" + IndexText, Passed, ErrorText));
	EndDo;
	Result = New Structure("run_id,status,cases", RunId, ?(AllPassed, "PASS", "FAIL"), Cases);
	Writer = New JSONWriter;
	Writer.OpenFile(ResultPath);
	WriteJSON(Writer, Result);
	Writer.Close();
	Return Result;
EndFunction

Procedure CheckBoundary(Val RunId, Val ResultDirectory, Val CollisionIndex)
	CaseUUID = Lower(StrReplace(String(New UUID), "-", ""));
	MonthIndex = Int((CollisionIndex - 1) / 5) + 1;
	Offset = (CollisionIndex - 1) % 5;
	// Exact generator order: BB1, HD1, BB2, HD2, BC1.
	Names = StrSplit("BienBanNghiemThuGiaiDoan,HoaDonGTGTDauRa,BienBanNghiemThuGiaiDoan,HoaDonGTGTDauRa,BaoCoNganHang", ",");
	DocumentName = Names[Offset];
	ItemIndex = ?(Offset = 2 Or Offset = 3, 2, 1);
	DayNumber = ?(Offset = 4, 5, ?(Offset = 1 Or Offset = 3, 3, 2));
	Tag = "SEED_BOUNDARY:" + RunId + ":" + String(CollisionIndex) + ":" + CaseUUID;
	GLBeforeFixture = GLCount();
	BeginTransaction();
	Try
		Canary = SeedWorkflowServer.NewSample(DocumentName, CaseUUID, MonthIndex, ItemIndex, DayNumber);
		FillCanary(Canary, Offset);
		Canary.DienGiai = Tag;
		Refs = New Array;
		SeedWorkflowServer.SavePending(Canary, Refs);
		CommitTransaction();
	Except
		If TransactionActive() Then RollbackTransaction(); EndIf;
		Raise;
	EndTry;
	CanaryRef = Canary.Ref;
	CanaryBefore = CanaryFingerprint(DocumentName, CanaryRef);
	ARBefore = ARFingerprint();
	GLBefore = GLCount();
	If GLBefore <> GLBeforeFixture Then Raise "BOUNDARY_CANARY_CREATED_GL"; EndIf;
	OutputPath = ResultDirectory + CaseUUID + "-ar.json";
	ManifestPath = ResultDirectory + CaseUUID + "-ar.manifest.json";
	// Use the actual production workflow, with its own transaction and normal number check.
	Result = SeedWorkflowServer.RunPhase(CaseUUID, OutputPath, "ar", ManifestPath);
	LeakedTransaction = TransactionActive();
	If LeakedTransaction Then
		RollbackTransaction();
		Raise "BOUNDARY_TRANSACTION_LEAK";
	EndIf;
	If Result.run_id <> CaseUUID Or Result.status <> "FAIL" Or Result.cases.Count() <> 1 Then Raise "BOUNDARY_EXPECTED_WORKFLOW_FAILURE"; EndIf;
	CaseResult = Result.cases[0];
	If CaseResult.name <> "ar" Or CaseResult.passed Or StrFind(CaseResult.error, "SEED_NUMBER_COLLISION") = 0 Then
		Raise "BOUNDARY_WRONG_FAILURE: " + CaseResult.error;
	EndIf;
	If ARFingerprint() <> ARBefore Then Raise "BOUNDARY_AR_RECORDS_CHANGED: " + String(CollisionIndex); EndIf;
	If GLCount() <> GLBefore Then Raise "BOUNDARY_GL_COUNT_CHANGED"; EndIf;
	If CanaryFingerprint(DocumentName, CanaryRef) <> CanaryBefore Then Raise "BOUNDARY_CANARY_CONTENT_CHANGED"; EndIf;
	Persisted = CanaryRef.GetObject();
	If Persisted = Undefined Or Persisted.Ref <> CanaryRef Or Persisted.Posted Or Persisted.DeletionMark Or Persisted.DienGiai <> Tag Then
		Raise "BOUNDARY_CANARY_NOT_INTACT";
	EndIf;
	ManifestFile = New File(ManifestPath);
	If ManifestFile.Exist() Then Raise "BOUNDARY_FAILED_RUN_PUBLISHED_MANIFEST"; EndIf;
EndProcedure

Procedure FillCanary(Doc, Val Offset)
	PN = SeedWorkflowServer.RequiredCatalog("PhapNhan", "PN-VSF");
	Partner = SeedWorkflowServer.RequiredCatalog("DoiTac", ?(Offset = 0 Or Offset = 1, "DT-VIC", "DT-FPT"));
	Contract = SeedWorkflowServer.PartnerContract(Partner);
	Doc.PhapNhan = PN;
	Name = Doc.Metadata().Name;
	If Name = "HoaDonGTGTDauRa" Or Name = "BaoCoNganHang" Then
		// Use an existing real AR source for the committed draft's required references.
		Q = New Query("SELECT TOP 1 Ref, DoiTac, HopDong FROM Document.BienBanNghiemThuGiaiDoan WHERE PhapNhan = &PN AND DeletionMark = FALSE ORDER BY Ref");
		Q.SetParameter("PN", PN);
		Sources = Q.Execute().Unload();
		If Sources.Count() = 0 Then Raise "BOUNDARY_EXISTING_AR_SOURCE_REQUIRED"; EndIf;
		Source = Sources[0];
		Partner = Source.DoiTac;
		Contract = Source.HopDong;
	EndIf;
	If Name = "BaoCoNganHang" Then
		Doc.TaiKhoanTien = SeedWorkflowServer.RequiredCatalog("TaiKhoanTien", "TK-TCB-VND");
		Doc.DoiTacKhop = Partner;
		Doc.ChungTuKhop = Source.Ref;
		Doc.SoTien = 1;
		Doc.NgayGiaoDich = Doc.Date;
		Doc.MaGiaoDichNganHang = Doc.Number;
		Doc.TuDongGhiSo = False;
	Else
		Doc.DoiTac = Partner;
		Doc.HopDong = Contract;
		If Name = "BienBanNghiemThuGiaiDoan" Then
			Doc.GiaTriNghiemThuChuaVAT = 1;
			Doc.NgayNghiemThu = BegOfDay(Doc.Date);
		Else
			Doc.BienBanNghiemThu = Source.Ref;
			Doc.SoHoaDon = Doc.Number;
			Doc.NgayHoaDon = BegOfDay(Doc.Date);
			Doc.TienChuaThue = 1;
			Doc.TongTienThanhToan = 1;
		EndIf;
	EndIf;
EndProcedure

Function ARFingerprint()
	Result = "";
	// Includes every persisted record, not just canary/sample prefixes or current drafts.
	For Each Name In StrSplit("BienBanNghiemThuGiaiDoan,HoaDonGTGTDauRa,BaoCoNganHang,PhieuThuTienKhachHang,DieuChinhCongNo", ",") Do
		Q = New Query("SELECT * FROM Document." + Name + " ORDER BY Ref");
		Rows = Q.Execute().Unload();
		Result = Result + Name + ":" + String(Rows.Count()) + ":" + ValueToStringInternal(Rows);
		For Each Section In Metadata.Documents[Name].TabularSections Do
			Q = New Query("SELECT * FROM Document." + Name + "." + Section.Name + " ORDER BY Ref, LineNumber");
			Result = Result + Section.Name + ":" + ValueToStringInternal(Q.Execute().Unload());
		EndDo;
	EndDo;
	Return Result;
EndFunction

Function CanaryFingerprint(Val Name, Val CanaryRef)
	Q = New Query("SELECT * FROM Document." + Name + " WHERE Ref = &Canary");
	Q.SetParameter("Canary", CanaryRef);
	Rows = Q.Execute().Unload();
	If Rows.Count() <> 1 Then Raise "BOUNDARY_CANARY_MISSING"; EndIf;
	Return ValueToStringInternal(Rows);
EndFunction

Function GLCount()
	Q = New Query("SELECT COUNT(*) AS Cnt FROM AccountingRegister.SoCaiKeToan");
	Return Q.Execute().Unload()[0].Cnt;
EndFunction

Procedure ValidateResultPath(Val RunId, Val ResultPath)
	If StrLen(RunId) <> 32 Then Raise "BOUNDARY_INVALID_RUN_ID"; EndIf;
	For Index = 1 To StrLen(RunId) Do
		If StrFind("0123456789abcdef", Mid(RunId, Index, 1)) = 0 Then Raise "BOUNDARY_INVALID_RUN_ID"; EndIf;
	EndDo;
	Connection = StrReplace(InfoBaseConnectionString(), "\", "/");
	Start = StrFind(Lower(Connection), "file=""");
	If Start = 0 Then Raise "BOUNDARY_FILE_CLONE_REQUIRED"; EndIf;
	Tail = Mid(Connection, Start + 6);
	Finish = StrFind(Tail, """");
	If Finish = 0 Then Raise "BOUNDARY_INVALID_CONNECTION"; EndIf;
	IB = Left(Tail, Finish - 1);
	While Right(IB, 1) = "/" Do IB = Left(IB, StrLen(IB) - 1); EndDo;
	If Right(Lower(IB), 3) <> "/ib" Then Raise "BOUNDARY_FILE_CLONE_REQUIRED"; EndIf;
	ExpectedPath = Left(IB, StrLen(IB) - 3) + "/results/" + RunId + "-boundaries.json";
	If Lower(StrReplace(ResultPath, "\", "/")) <> Lower(ExpectedPath) Then Raise "BOUNDARY_INVALID_RESULT_PATH"; EndIf;
	ResultFile = New File(ResultPath);
	If ResultFile.Exist() Then Raise "BOUNDARY_RESULT_EXISTS"; EndIf;
EndProcedure
