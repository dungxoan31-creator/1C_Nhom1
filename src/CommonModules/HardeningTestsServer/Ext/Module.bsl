// Runtime regression tests; execute only on an isolated UAT infobase.
Function KiemThuAnToanSeed() Export
	KiemTraMoiTruongUAT();
	Cases = New Array;
	BeforeCounts = DemChungTuAR();
	Blocked = False;
	ErrorText = "";
	Blocked = True;
	For Index = 1 To 6 Do
		OneBlocked = False;
		Try
			If Index = 1 Then
				GeneratorARServer.KhoiTaoChungTuAR();
			ElsIf Index = 2 Then
				GeneratorAPServer.KhoiTaoChungTuAP();
			ElsIf Index = 3 Then
				GeneratorNettingReconcileServer.KhoiTaoChungTuNetting();
			ElsIf Index = 4 Then
				GeneratorMasterDataServer.KhoiTaoMasterDataToanDien();
			ElsIf Index = 5 Then
				SeedDataCleanServer.ThucThiNapMasterData();
			Else
				SeedFullTestDataServer.ThucThiNapFullTestData();
			EndIf;
		Except
			ErrorText = ErrorDescription();
			OneBlocked = StrFind(ErrorText, "SEED_DISABLED") > 0;
		EndTry;
		Blocked = Blocked And OneBlocked;
	EndDo;
	AfterCounts = DemChungTuAR();
	Cases.Add(New Structure("name,passed,error", "SeedSafety",
		Blocked And BeforeCounts = AfterCounts,
		?(Blocked And BeforeCounts = AfterCounts, "", "Seed must fail before any write: " + ErrorText)));
	Return Cases;
EndFunction

Function KiemThuTrangThai() Export
	KiemTraMoiTruongUAT();
	Cases = New Array;
	PostedGuard = False;
	LoadGuard = False;
	MakerGuard = False;
	DraftImport = False;
	AdjustmentImport = False;
	RequestImport = False;
	RefundImport = False;
	ErrorText = "";
	Try
		Q = New Query("SELECT TOP 1 Ref FROM Document.CanTruCongNoNoiBo WHERE Posted = TRUE");
		T = Q.Execute().Unload();
		If T.Count() = 0 Then
			Raise "Missing posted netting fixture";
		EndIf;
		Doc = T[0].Ref.GetObject();
		Doc.TrangThai = "DuThao";
		Try
			Doc.Write(DocumentWriteMode.Write);
		Except
			PostedGuard = StrFind(ErrorDescription(), "CẤM SỬA TRỰC TIẾP") > 0;
		EndTry;
		Doc = Documents.UyNhiemChi.CreateDocument();
		Doc.Date = CurrentSessionDate();
		Doc.TrangThai = Enums.TrangThaiLenhThanhToan.DaGhiSo;
		Doc.DataExchange.Load = True;
		Try
			Doc.Write(DocumentWriteMode.Write);
		Except
			LoadGuard = StrFind(ErrorDescription(), "Posted = False") > 0;
		EndTry;
		Doc = Documents.HoaDonNhaCungCap.CreateDocument();
		Doc.Date = CurrentSessionDate();
		Doc.NguoiLap = UserName();
		Doc.NguoiDuyet = UserName();
		Doc.TrangThai = Enums.TrangThaiHoaDonAP.ChoKeToanAP;
		Try
			Doc.Write(DocumentWriteMode.Posting);
		Except
			MakerGuard = StrFind(ErrorDescription(), "Người tạo/lập không thể tự phê duyệt") > 0;
		EndTry;
		Doc = Documents.HoaDonNhaCungCap.CreateDocument();
		Doc.Date = CurrentSessionDate();
		Doc.TrangThai = Enums.TrangThaiHoaDonAP.DuThao;
		Doc.DataExchange.Load = True;
		Doc.Write(DocumentWriteMode.Write);
		DraftImport = ValueIsFilled(Doc.Ref) And Not Doc.Posted;
		Doc.Delete();
		Doc = Documents.DieuChinhCongNo.CreateDocument();
		Doc.Date = CurrentSessionDate();
		Doc.TrangThai = Enums.TrangThaiNghiemThuAR.DaGhiSo;
		Doc.DataExchange.Load = True;
		Try
			Doc.Write(DocumentWriteMode.Write);
			Doc.Delete();
		Except
			AdjustmentImport = StrFind(ErrorDescription(), "Posted = False") > 0;
		EndTry;
		Doc = Documents.DeNghiThanhToanDichVu.CreateDocument();
		Doc.Date = CurrentSessionDate();
		Doc.NguoiDeNghi = UserName();
		Doc.NguoiDuyet = UserName();
		Doc.TrangThai = Enums.TrangThaiLenhThanhToan.DaDuyet;
		Doc.DataExchange.Load = True;
		Try
			Doc.Write(DocumentWriteMode.Write);
			Doc.Delete();
		Except
			RequestImport = True;
		EndTry;
		Doc = Documents.YeuCauHoanTienChiHo.CreateDocument();
		Doc.Date = CurrentSessionDate();
		Doc.NguoiLap = UserName();
		Doc.NguoiDuyet = UserName();
		Doc.TrangThai = "DaDuyet";
		Doc.DataExchange.Load = True;
		Try
			Doc.Write(DocumentWriteMode.Write);
			Doc.Delete();
		Except
			RefundImport = True;
		EndTry;
	Except
		ErrorText = ErrorDescription();
	EndTry;
	ReconciliationMakerGuard = KiemThuTuDuyetBangKe();
	Passed = PostedGuard And LoadGuard And MakerGuard And DraftImport
		And AdjustmentImport And RequestImport And RefundImport And ReconciliationMakerGuard;
	Cases.Add(New Structure("name,passed,error", "StateGuard", Passed,
		?(Passed, "", StrTemplate("Posted=%1 Load=%2 Maker=%3 Draft=%4 Adjustment=%5 Request=%6 Refund=%7 ReconciliationMaker=%8 %9",
			PostedGuard, LoadGuard, MakerGuard, DraftImport, AdjustmentImport, RequestImport, RefundImport, ReconciliationMakerGuard, ErrorText))));
	Return Cases;
EndFunction

Function KiemThuTuDuyetBangKe()
	Denied = False;
	Try
		BeginTransaction();
		Q = New Query("SELECT TOP 1 Ref FROM Catalog.HopDong WHERE DongTienThanhToan.Code = ""VND"" AND NOT DeletionMark ORDER BY Ref");
		Contract = Q.Execute().Unload()[0].Ref;
		Doc = Documents.BangKeDoiSoatKenhThanhToan.CreateDocument();
		Doc.Number = "MC-" + Left(String(New UUID), 10);
		Doc.Date = CurrentSessionDate();
		Doc.PhapNhan = Contract.PhapNhan;
		Doc.TaiKhoanNganHang = Catalogs.TaiKhoanTien.FindByCode("TK-TCB-VND");
		Doc.KenhThanhToan = Catalogs.KenhThanhToan.FindByCode("KTT-ONEPAY");
		Doc.NguoiLap = UserName();
		Doc.NguoiDuyet = UserName();
		Doc.TrangThai = "DaDoiSoat";
		Doc.TongTienGiaoDich = 100;
		Doc.TongPhiKenh = 1;
		Doc.TongThucNhan = 99;
		Detail = Doc.ChiTietGiaoDich.Add();
		Detail.MaGiaoDichKenh = Doc.Number;
		Detail.NgayGiaoDich = Doc.Date;
		Detail.SoTien = 100;
		Detail.PhiKenh = 1;
		Detail.ThucNhan = 99;
		Detail.DoiTac = Contract.ChuSoHuu;
		Detail.HopDong = Contract;
		Doc.DataExchange.Load = True;
		Try
			Doc.Write(DocumentWriteMode.Posting);
		Except
			Denied = StrFind(ErrorDescription(), "Maker-Checker") > 0;
		EndTry;
		RollbackTransaction();
	Except
		If TransactionActive() Then RollbackTransaction(); EndIf;
	EndTry;
	Return Denied;
EndFunction

Function KiemThuDonVi() Export
	KiemTraMoiTruongUAT();
	Cases = New Array;
	ErrorText = "";
	Passed = False;
	Try
		Passed = PhanQuyenBaoMatServer.ThucThiKiemThuBaoMatToanDien();
	Except
		ErrorText = ErrorDescription();
	EndTry;
	Cases.Add(New Structure("name,passed,error", "SecurityAndSoD", Passed, ?(Passed, "", "Security suite failed. " + ErrorText)));
	Try
		Result = QuanLyVongDoiChungTuServer.KiemTraDoiSoatDocLapGLVaSoPhu();
		Passed = Result.HopLe And Result.DeltaAR = 0 And Result.DeltaAP = 0 And Result.DeltaBank = 0;
		ErrorText = StrTemplate("Delta AR=%1 AP=%2 Bank=%3", Result.DeltaAR, Result.DeltaAP, Result.DeltaBank);
	Except
		Passed = False;
		ErrorText = ErrorDescription();
	EndTry;
	Cases.Add(New Structure("name,passed,error", "GLSubledger", Passed, ?(Passed, "", ErrorText)));
	Return Cases;
EndFunction

Function KiemThuHardening() Export
	Cases = KiemThuAnToanSeed();
	For Each R In KiemThuGiaoDichSeed() Do Cases.Add(R); EndDo;
	For Each R In KiemThuTrangThai() Do Cases.Add(R); EndDo;
	Return Cases;
EndFunction

Function KiemTraBangChungDocLap(CommandName, OutputPath) Export
	KiemTraMoiTruongUAT();
	Cases = New Array;
	Passed = False;
	ErrorText = "";
	Try
		If CommandName = "VerifyGLAnalyticKeys" Then
			Passed = SeedFullTestDataServer.KiemTraGLAnalyticKeysServer();
			If Not Passed Then XuatChieuThieuGL(OutputPath + ".diagnostics.json"); EndIf;
			If Not Passed Then ErrorText = "GL is empty or partner/contract analytic keys are missing."; EndIf;
		ElsIf CommandName = "VerifyContractFees" Then
			GeneratorNettingReconcileServer.KiemTraHopDongPhiVaKenhThanhToan();
			Passed = True;
		ElsIf CommandName = "ExportTrialBalanceEvidence" Then
			Evidence = BaoCaoQuanTriServer.XuatOperationalTrialBalanceEvidenceServer(OutputPath + ".evidence.json");
			Passed = Evidence.TrialBalance.CanDoi And Evidence.Reconciliation.HopLe
				And Evidence.Reconciliation.DeltaAR = 0 And Evidence.Reconciliation.DeltaAP = 0
				And Evidence.Reconciliation.DeltaBank = 0;
			If Not Passed Then ErrorText = "Exported trial balance/subledger reconciliation has nonzero deltas."; EndIf;
		Else
			Raise "Unsupported evidence command";
		EndIf;
	Except
		ErrorText = ErrorDescription();
	EndTry;
	Cases.Add(New Structure("name,passed,error", CommandName, Passed, ?(Passed, "", ErrorText)));
	Return Cases;
EndFunction

Procedure XuatChieuThieuGL(OutputPath)
	Q = New Query(
		"SELECT SC.Recorder, SC.LineNumber, SC.AccountDr.Code AS Debit,
		| SC.AccountCr.Code AS Credit, SC.DoiTacNo, SC.DoiTacCo, SC.HopDongNo, SC.HopDongCo
		| FROM AccountingRegister.SoCaiKeToan AS SC
		| WHERE (SC.AccountDr.Code IN (""1311"", ""1312"", ""1388"", ""3311"", ""3312"", ""3313"", ""3388"")
		| AND (SC.DoiTacNo = VALUE(Catalog.DoiTac.EmptyRef) OR SC.HopDongNo = VALUE(Catalog.HopDong.EmptyRef)))
		| OR (SC.AccountCr.Code IN (""1311"", ""1312"", ""1388"", ""3311"", ""3312"", ""3313"", ""3388"")
		| AND (SC.DoiTacCo = VALUE(Catalog.DoiTac.EmptyRef) OR SC.HopDongCo = VALUE(Catalog.HopDong.EmptyRef)))
		| ORDER BY SC.Recorder, SC.LineNumber");
	Rows = New Array;
	For Each R In Q.Execute().Unload() Do
		Rows.Add(New Structure("document,line,debit,credit,partner_debit,partner_credit,contract_debit,contract_credit",
			String(R.Recorder), R.LineNumber, R.Debit, R.Credit,
			String(R.DoiTacNo), String(R.DoiTacCo), String(R.HopDongNo), String(R.HopDongCo)));
	EndDo;
	Writer = New JSONWriter;
	Writer.OpenFile(OutputPath);
	WriteJSON(Writer, Rows);
	Writer.Close();
EndProcedure

Function KiemThuGiaoDichSeed() Export
	KiemTraMoiTruongUAT();
	Cases = New Array;
	SavedFlag = Constants.ChoPhepSinhDuLieuMau.Get();
	ErrorText = "";
	Try
		Constants.ChoPhepSinhDuLieuMau.Set(True);
		Q = New Query("SELECT COUNT(*) AS Cnt FROM AccountingRegister.SoCaiKeToan");
		BeforeCount = Q.Execute().Unload()[0].Cnt;
		Try
			GeneratorNettingReconcileServer.KhoiTaoChungTuNetting();
		Except
			ErrorText = ErrorDescription();
		EndTry;
		LeakedTransaction = TransactionActive();
		If LeakedTransaction Then RollbackTransaction(); EndIf;
		AfterCount = Q.Execute().Unload()[0].Cnt;
		Constants.ChoPhepSinhDuLieuMau.Set(SavedFlag);
	Except
		If TransactionActive() Then RollbackTransaction(); EndIf;
		Constants.ChoPhepSinhDuLieuMau.Set(SavedFlag);
		Raise;
	EndTry;
	Passed = StrFind(ErrorText, "SEED_NUMBER_COLLISION") > 0
		And Not LeakedTransaction And BeforeCount = AfterCount;
	Cases.Add(New Structure("name,passed,error", "SeedTransactions", Passed,
		?(Passed, "", "Collision must rollback and close transaction. Leak=" + String(LeakedTransaction) + "; " + ErrorText)));
	Return Cases;
EndFunction

Function DemChungTuAR()
	Counts = "";
	For Each DocName In StrSplit("BienBanNghiemThuGiaiDoan,HoaDonGTGTDauRa,BaoCoNganHang,PhieuThuTienKhachHang", ",") Do
		Q = New Query("SELECT COUNT(*) AS Cnt FROM Document." + DocName);
		Counts = Counts + DocName + ":" + String(Q.Execute().Unload()[0].Cnt) + ";";
		Q = New Query("SELECT * FROM Document." + DocName + " ORDER BY Ref");
		Counts = Counts + ValueToStringInternal(Q.Execute().Unload()) + ";";
	EndDo;
	Return Counts;
EndFunction

Procedure KiemTraMoiTruongUAT() Export
	Connection = Lower(StrReplace(InfoBaseConnectionString(), "\", "/"));
	If StrFind(Connection, "/scratch/uat/") = 0 Or StrFind(Connection, "infobase_fulldata") > 0 Then
		Raise "UAT_ONLY: regression tests require an isolated scratch/uat infobase.";
	EndIf;
EndProcedure

Function KiemThuQuyenNguoiDung() Export
	KiemTraMoiTruongUAT();
	Cases = New Array;
	Roles = New Map;
	Roles.Insert("Admin", "QuanTriHeThong");
	Roles.Insert("ketoan_ar", "KeToanPhaiThu");
	Roles.Insert("ketoan_ap", "KeToanPhaiTra");
	Roles.Insert("chuyenvien_doisoat", "ChuyenVienDoiSoatTapDoan");
	Roles.Insert("ketoan_truong", "KeToanTruong");
	Roles.Insert("cfo_giamdoc", "GiamDocTaiChinh_CFO");
	ExpectedRole = Roles.Get(UserName());
	CorrectRole = ExpectedRole <> Undefined And IsInRole(ExpectedRole);
	Cases.Add(New Structure("name,passed,error", "ActualRole", CorrectRole, ?(CorrectRole, "", "Authenticated session has wrong role")));
	BoundaryDenied = False;
	ErrorText = "";
	BeginTransaction();
	Try
		If UserName() = "ketoan_ap" Then
			Doc = Documents.HoaDonGTGTDauRa.CreateDocument();
		Else
			Doc = Documents.HoaDonNhaCungCap.CreateDocument();
			Doc.TrangThai = Enums.TrangThaiHoaDonAP.DuThao;
		EndIf;
		Doc.Date = CurrentSessionDate();
		Doc.NguoiLap = UserName();
		Doc.NguoiDuyet = UserName();
		If UserName() = "ketoan_ar" Or UserName() = "ketoan_ap" Or UserName() = "chuyenvien_doisoat" Then
			Doc.Write(DocumentWriteMode.Write);
		Else
			Doc.Write(DocumentWriteMode.Posting);
		EndIf;
	Except
		ErrorText = ErrorDescription();
		If UserName() = "ketoan_ar" Or UserName() = "ketoan_ap" Then
			BoundaryDenied = StrFind(ErrorText, "Segregation of Duties") > 0;
		ElsIf UserName() = "chuyenvien_doisoat" Then
			BoundaryDenied = StrFind(ErrorText, "Chuyên viên Đối soát") > 0;
		Else
			BoundaryDenied = StrFind(ErrorText, "Người tạo/lập không thể tự phê duyệt") > 0;
		EndIf;
	EndTry;
	If TransactionActive() Then RollbackTransaction(); EndIf;
	Cases.Add(New Structure("name,passed,error", "PermissionBoundary", BoundaryDenied,
		?(BoundaryDenied, "", "Actual document write was not rejected by the expected permission boundary: " + ErrorText)));
	Return Cases;
EndFunction

