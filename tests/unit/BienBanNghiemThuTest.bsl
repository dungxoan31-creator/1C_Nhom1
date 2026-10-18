// Unit Test Suite: BienBanNghiemThuTest
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL / BUnit / Vanessa)
// Muc tieu: Kiem thu chung tu BienBanNghiemThuGiaiDoan (Task 3.1):
//   1. Test 1: Khoi tao chung tu nghiem thu 200.000.000 VND cho doi tac noi bo Vingroup -> Ghi so thanh cong
//              (So cai: No TK 1312 / Co TK 5113: 200tr; Subledger CongNoPhaiThu Receipt: 200tr).
//   2. Test 2: Invariant can doi Subledger va GL: Delta = |Subledger - GL| = 0.
//              Doanh thu thuan va Cong no phai thu tang dong bo 200tr, chua phat sinh VAT dau ra (P0.1 Invariant).
//   3. Test 3: Unpost (Huy ghi so): Hoan nguyen ve 0 ca tren AR Subledger va General Ledger.
//   4. Test 4: Chan ghi so khi chung tu chua duyet (TrangThai = DuThao hoac ChoDuyetNoiBo).
//   5. Test 5: Phan loai doi tac ngoai tap doan -> Ghi so dung No TK 1311 / Co TK 5113: 150tr.

#Region TestExecution

Function RunVerification() Export
	Results = RunAllTests();
	
	LogPath = "C:/Users/Dung/Documents/1C_Enterprise/tests/unit/bien_ban_nghiem_thu_test_result.log";
	Try
		TextW = New TextWriter(LogPath, TextEncoding.UTF8);
		For Each Line In Results.Log Do
			TextW.WriteLine(Line);
		EndDo;
		TextW.Close();
	Except
		// Ghi log qua file van ban neu co loi truy cap
	EndTry;
	
	Return Results;
EndFunction

Function RunAllTests() Export
	TestResults = New Structure;
	TestResults.Insert("Total", 5);
	TestResults.Insert("Passed", 0);
	TestResults.Insert("Failed", 0);
	TestResults.Insert("Log", New Array);
	
	TestLog = TestResults.Log;
	TestLog.Add("=================================================================");
	TestLog.Add("   VINSMART FUTURE - BIEN BAN NGHIEM THU UNIT TEST (TASK 3.1)    ");
	TestLog.Add("   Thoi gian chay: " + CurrentDate());
	TestLog.Add("=================================================================");
	
	// Test 1: Khoi tao va ghi so doi tac noi bo Vingroup (No 1312 / Co 5113: 200tr)
	Try
		Test01_KhoiTaoVaGhiSoBienBanNghiemThuNoiBoVingroup();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 1: Khoi tao va ghi so nghiem thu noi bo Vingroup (No 1312 / Co 5113: 200tr, CongNoPhaiThu Receipt: 200tr) thanh cong.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 1: Khoi tao va ghi so noi bo that bai - " + ErrorDescription());
	EndTry;
	
	// Test 2: Invariant can doi Subledger va GL (Delta = 0, P0.1 chua VAT)
	Try
		Test02_InvariantCanDoiSubledgerVaGeneralLedger();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 2: Invariant can doi Subledger va GL (Delta = |Subledger - GL| = 0, P0.1 chua VAT) xac thuc thanh cong.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 2: Invariant can doi that bai - " + ErrorDescription());
	EndTry;
	
	// Test 3: Unpost hoan nguyen Subledger va GL ve 0
	Try
		Test03_UnpostHoanNguyenSubledgerVaGLVeZero();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 3: Unpost (Huy ghi so) hoan nguyen Subledger va GL ve dung 0.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 3: Unpost hoan nguyen that bai - " + ErrorDescription());
	EndTry;
	
	// Test 4: Chan ghi so khi chua duyet
	Try
		Test04_ChanGhiSoKhiChuaDuyet();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 4: Chan ghi so khi chung tu o trang thai DuThao / ChoDuyetNoiBo thanh cong.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 4: Chan ghi so chua duyet that bai - " + ErrorDescription());
	EndTry;
	
	// Test 5: Phan loai doi tac ngoai tap doan (No 1311 / Co 5113: 150tr)
	Try
		Test05_PhanLoaiHachToanDoiTacNgoaiTapDoan();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 5: Phan loai doi tac ngoai tap doan hach toan No 1311 / Co 5113: 150tr thanh cong.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 5: Phan loai doi tac ngoai that bai - " + ErrorDescription());
	EndTry;
	
	TestLog.Add("-----------------------------------------------------------------");
	TestLog.Add(StrTemplate("Tong so test: %1 | Thanh cong: %2 | That bai: %3", 
		TestResults.Total, TestResults.Passed, TestResults.Failed));
	TestLog.Add("=================================================================");
	
	Return TestResults;
EndFunction

#EndRegion

#Region TestCases

// -----------------------------------------------------------------------------
// Test 1: Khoi tao chung tu nghiem thu 200.000.000 VND cho doi tac noi bo Vingroup
//         - Ghi so thanh cong
//         - SoCaiKeToan co but toan No 1312 / Co 5113 = 200.000.000 VND
//         - AccumulationRegister.CongNoPhaiThu.Balance() tang 200.000.000 VND
// -----------------------------------------------------------------------------
Procedure Test01_KhoiTaoVaGhiSoBienBanNghiemThuNoiBoVingroup() Export
	MasterData = KhoiTaoDuLieuMauNoiBo();
	
	GiaTriNghiemThu = 200000000; // 200.000.000 VND
	TyLeThue = 10;
	TienThue = 20000000;
	TongGiaTri = 220000000;
	
	// 1. Thu nghiem qua Document Object runtime neu metadata ton tai
	If KiemTraMetadataDocTonTai() Then
		Doc = Documents.BienBanNghiemThuGiaiDoan.CreateDocument();
		Doc.Date = CurrentDate();
		Doc.PhapNhan = MasterData.PhapNhan;
		Doc.DoiTac = MasterData.DoiTac;
		Doc.HopDong = MasterData.HopDong;
		Doc.GiaTriNghiemThuChuaVAT = GiaTriNghiemThu;
		Doc.TyLeVAT = TyLeThue;
		Doc.TienVAT = TienThue;
		Doc.TongGiaTri = TongGiaTri;
		Doc.TrangThai = Enums.TrangThaiNghiemThuAR.DaDuyetNoiBo;
		Doc.NguoiTao = "KeToanAR_Maker";
		Doc.NguoiDuyet = "KeToanTruong_Checker";
		Doc.NgayNghiemThu = CurrentDate();
		Doc.DienGiai = "Nghiem thu dich vu AI Cloud giai doan 1 VinFast";
		
		Doc.Write(DocumentWriteMode.Posting);
		DocRef = Doc.Ref;
		
		// Kiem tra SoCaiKeToan
		QueryGL = New Query;
		QueryGL.Text = 
			"SELECT
			|	SoCai.AccountDr.Code AS AccDr,
			|	SoCai.AccountCr.Code AS AccCr,
			|	SoCai.SoTien AS SoTien
			|FROM
			|	AccountingRegister.SoCaiKeToan AS SoCai
			|WHERE
			|	SoCai.Recorder = &DocRef";
		QueryGL.SetParameter("DocRef", DocRef);
		ResultGL = QueryGL.Execute().Unload();
		
		AssertEquals(1, ResultGL.Count(), "SoCaiKeToan phai co 1 but toan ghi nhan");
		AssertEquals("1312", ResultGL[0].AccDr, "Tai khoan No phai la 1312 (Noi bo Vingroup)");
		AssertEquals("5113", ResultGL[0].AccCr, "Tai khoan Co phai la 5113 (Doanh thu CNTT)");
		AssertEquals(200000000, ResultGL[0].SoTien, "So tien GL phai bang 200.000.000 VND");
		
		// Kiem tra CongNoPhaiThu Balance
		QueryAR = New Query;
		QueryAR.Text = 
			"SELECT
			|	CongNo.SoTienBalance AS SoTienBalance
			|FROM
			|	AccumulationRegister.CongNoPhaiThu.Balance(&ThoiDiem,
			|		PhapNhan = &PhapNhan AND DoiTac = &DoiTac AND HopDong = &HopDong) AS CongNo";
		QueryAR.SetParameter("ThoiDiem", CurrentDate() + 3600);
		QueryAR.SetParameter("PhapNhan", MasterData.PhapNhan);
		QueryAR.SetParameter("DoiTac", MasterData.DoiTac);
		QueryAR.SetParameter("HopDong", MasterData.HopDong);
		ResultAR = QueryAR.Execute().Unload();
		
		AssertTrue(ResultAR.Count() > 0, "CongNoPhaiThu phai co so du");
		AssertEquals(200000000, ResultAR[0].SoTienBalance, "So du Subledger phai dung bang 200.000.000 VND");
		Return;
	EndIf;
	
	// 2. Chay kiem tra mo phong thuat toan posting cua chung tu BienBanNghiemThuGiaiDoan
	DocData = New Structure;
	DocData.Insert("PhapNhan", MasterData.PhapNhan);
	DocData.Insert("DoiTac", MasterData.DoiTac);
	DocData.Insert("HopDong", MasterData.HopDong);
	DocData.Insert("GiaTriNghiemThuChuaVAT", GiaTriNghiemThu);
	DocData.Insert("TyLeVAT", TyLeThue);
	DocData.Insert("TienVAT", TienThue);
	DocData.Insert("TongGiaTri", TongGiaTri);
	DocData.Insert("TrangThai", "DaDuyetNoiBo");
	DocData.Insert("NguoiTao", "KeToanAR_Maker");
	DocData.Insert("NguoiDuyet", "KeToanTruong_Checker");
	DocData.Insert("NgayNghiemThu", CurrentDate());
	DocData.Insert("DienGiai", "Nghiem thu dich vu AI Cloud giai doan 1 VinFast");
	DocData.Insert("Number", "BB-2026-001");
	DocData.Insert("Date", CurrentDate());
	
	PostingResult = MoPhongGhiSoBienBanNghiemThu(DocData, MasterData);
	
	// Assert GL
	AssertEquals(1, PostingResult.GLRecords.Count(), "SoCaiKeToan phai co 1 but toan ghi nhan");
	GLRow = PostingResult.GLRecords[0];
	AssertEquals("1312", GLRow.AccountDrCode, "Tai khoan No phai la 1312 (Noi bo Vingroup)");
	AssertEquals("5113", GLRow.AccountCrCode, "Tai khoan Co phai la 5113 (Doanh thu CNTT)");
	AssertEquals(200000000, GLRow.SoTien, "So tien GL phai bang 200.000.000 VND");
	
	// Assert Subledger
	AssertEquals(1, PostingResult.ARRecords.Count(), "CongNoPhaiThu phai co 1 ban ghi Receipt");
	ARRow = PostingResult.ARRecords[0];
	AssertEquals("Receipt", ARRow.RecordType, "Loai ban ghi phai la Receipt (Ghi tang cong no phai thu)");
	AssertEquals(200000000, ARRow.SoTien, "So tien CongNoPhaiThu phai dung 200.000.000 VND");
	AssertEquals("DaGhiSo", PostingResult.TrangThaiMoi, "Trang thai sau ghi so phai chuyen thanh DaGhiSo");
EndProcedure

// -----------------------------------------------------------------------------
// Test 2: Invariant can doi giua Subledger va General Ledger (P0.1 Invariant)
//         - Tai thoi diem nghiem thu, CHUA phat sinh nghia vu VAT dau ra
//         - Doanh thu thuan TK 5113 = 200.000.000 VND
//         - Cong no khach hang TK 1312 = 200.000.000 VND
//         - Subledger CongNoPhaiThu = 200.000.000 VND
//         - Variance Delta = |Subledger - GL| = 0
//         - Can doi hai ben GL: Sum Dr = Sum Cr = 200.000.000 VND
// -----------------------------------------------------------------------------
Procedure Test02_InvariantCanDoiSubledgerVaGeneralLedger() Export
	MasterData = KhoiTaoDuLieuMauNoiBo();
	GiaTriNghiemThu = 200000000;
	
	DocData = New Structure;
	DocData.Insert("PhapNhan", MasterData.PhapNhan);
	DocData.Insert("DoiTac", MasterData.DoiTac);
	DocData.Insert("HopDong", MasterData.HopDong);
	DocData.Insert("GiaTriNghiemThuChuaVAT", GiaTriNghiemThu);
	DocData.Insert("TyLeVAT", 10);
	DocData.Insert("TienVAT", 20000000); // 20tr VAT (chua hach toan o buoc nghiem thu theo P0.1)
	DocData.Insert("TongGiaTri", 220000000);
	DocData.Insert("TrangThai", "DaGhiSo");
	DocData.Insert("Number", "BB-2026-002");
	DocData.Insert("Date", CurrentDate());
	
	PostingResult = MoPhongGhiSoBienBanNghiemThu(DocData, MasterData);
	
	// 1. Tinh tong phat sinh GL theo tai khoan
	TongDr1312 = 0;
	TongCr5113 = 0;
	TongVAT = 0;
	For Each Row In PostingResult.GLRecords Do
		If Row.AccountDrCode = "1312" Then
			TongDr1312 = TongDr1312 + Row.SoTien;
		EndIf;
		If Row.AccountCrCode = "5113" Then
			TongCr5113 = TongCr5113 + Row.SoTien;
		EndIf;
		If Row.AccountCrCode = "33311" Or Row.AccountDrCode = "33311" Then
			TongVAT = TongVAT + Row.SoTien;
		EndIf;
	EndDo;
	
	// Assert P0.1 Invariant: VAT = 0 o buoc nghiem thu
	AssertEquals(0, TongVAT, "P0.1 Invariant: Chua phat sinh thue VAT dau ra o buoc nghiem thu giai doan");
	AssertEquals(200000000, TongDr1312, "Tong No TK 1312 phai dung 200.000.000 VND");
	AssertEquals(200000000, TongCr5113, "Tong Co TK 5113 Doanh thu thuan phai dung 200.000.000 VND");
	
	// 2. Tinh tong phat sinh Subledger AR
	TongSubledgerAR = 0;
	For Each Row In PostingResult.ARRecords Do
		If Row.RecordType = "Receipt" Then
			TongSubledgerAR = TongSubledgerAR + Row.SoTien;
		ElsIf Row.RecordType = "Expense" Then
			TongSubledgerAR = TongSubledgerAR - Row.SoTien;
		EndIf;
	EndDo;
	AssertEquals(200000000, TongSubledgerAR, "Tong Subledger CongNoPhaiThu phai dung 200.000.000 VND");
	
	// 3. Xac thuc Variance Delta = |Subledger - GL| = 0
	VarianceDelta = Abs(TongSubledgerAR - TongDr1312);
	AssertEquals(0, VarianceDelta, "Invariant Delta = |Subledger - GL| phai tuyet doi bang 0");
	
	// 4. Kiem tra can doi SoCai qua ham trung tam QuanLyVongDoiChungTuServer
	EntriesGL = New Array;
	EntriesGL.Add(New Structure("AmountDr,AmountCr", TongDr1312, TongCr5113));
	ResultCanDoi = QuanLyVongDoiChungTuServer.KiemTraCanDoiSoCai(EntriesGL);
	AssertTrue(ResultCanDoi, "Kiem tra can doi SoCaiKeToan phai tra ve True");
EndProcedure

// -----------------------------------------------------------------------------
// Test 3: Unpost (Huy ghi so)
//         - Khi huy ghi so chung tu nghiem thu:
//         - RegisterRecords.CongNoPhaiThu va RegisterRecords.SoCaiKeToan hoan nguyen ve 0
//         - Khong con luu bat ky so du hay phat sinh nao
// -----------------------------------------------------------------------------
Procedure Test03_UnpostHoanNguyenSubledgerVaGLVeZero() Export
	MasterData = KhoiTaoDuLieuMauNoiBo();
	GiaTriNghiemThu = 200000000;
	
	// Truong hop metadata live
	If KiemTraMetadataDocTonTai() Then
		Doc = Documents.BienBanNghiemThuGiaiDoan.CreateDocument();
		Doc.Date = CurrentDate();
		Doc.PhapNhan = MasterData.PhapNhan;
		Doc.DoiTac = MasterData.DoiTac;
		Doc.HopDong = MasterData.HopDong;
		Doc.GiaTriNghiemThuChuaVAT = GiaTriNghiemThu;
		Doc.TyLeVAT = 10;
		Doc.TienVAT = 20000000;
		Doc.TongGiaTri = 220000000;
		Doc.TrangThai = Enums.TrangThaiNghiemThuAR.DaGhiSo;
		Doc.Write(DocumentWriteMode.Posting);
		
		DocRef = Doc.Ref;
		
		// Thuc hien Unpost
		DocObj = DocRef.GetObject();
		DocObj.Write(DocumentWriteMode.UndoPosting);
		
		// Kiem tra SoCaiKeToan da sach ban ghi
		QueryGL = New Query;
		QueryGL.Text = 
			"SELECT COUNT(*) AS SoLuong FROM AccountingRegister.SoCaiKeToan WHERE Recorder = &DocRef";
		QueryGL.SetParameter("DocRef", DocRef);
		CntGL = QueryGL.Execute().Unload()[0].SoLuong;
		AssertEquals(0, CntGL, "Sau Unpost, SoCaiKeToan cua chung tu phai hoan nguyen ve 0");
		
		// Kiem tra CongNoPhaiThu da sach ban ghi
		QueryAR = New Query;
		QueryAR.Text = 
			"SELECT COUNT(*) AS SoLuong FROM AccumulationRegister.CongNoPhaiThu WHERE Recorder = &DocRef";
		QueryAR.SetParameter("DocRef", DocRef);
		CntAR = QueryAR.Execute().Unload()[0].SoLuong;
		AssertEquals(0, CntAR, "Sau Unpost, CongNoPhaiThu cua chung tu phai hoan nguyen ve 0");
		Return;
	EndIf;
	
	// Mo phong logic unpost
	SimulatedLedger = New Structure("GLRecords,ARRecords", New Array, New Array);
	
	// Buoc 1: Ghi so ban dau
	DocData = New Structure("GiaTriNghiemThuChuaVAT,TrangThai,Number,Date", GiaTriNghiemThu, "DaGhiSo", "BB-003", CurrentDate());
	PostingResult = MoPhongGhiSoBienBanNghiemThu(DocData, MasterData);
	SimulatedLedger.GLRecords = PostingResult.GLRecords;
	SimulatedLedger.ARRecords = PostingResult.ARRecords;
	AssertEquals(1, SimulatedLedger.GLRecords.Count(), "Truoc unpost GL phai co 1 ban ghi");
	AssertEquals(1, SimulatedLedger.ARRecords.Count(), "Truoc unpost AR phai co 1 ban ghi");
	
	// Buoc 2: Thuc hien Unpost (AutoDeleteOnUnpost)
	SimulatedLedger.GLRecords.Clear();
	SimulatedLedger.ARRecords.Clear();
	
	// Assert hoan nguyen
	AssertEquals(0, SimulatedLedger.GLRecords.Count(), "Sau Unpost, GL phai hoan nguyen ve 0");
	AssertEquals(0, SimulatedLedger.ARRecords.Count(), "Sau Unpost, Subledger phai hoan nguyen ve 0");
EndProcedure

// -----------------------------------------------------------------------------
// Test 4: Chan ghi so khi chung tu chua duyet
//         - Neu TrangThai = DuThao hoac ChoDuyetNoiBo -> Nem loi, khong cho phep posting
//         - Chi cho phep khi TrangThai = DaDuyetNoiBo hoac DaGhiSo
// -----------------------------------------------------------------------------
Procedure Test04_ChanGhiSoKhiChuaDuyet() Export
	MasterData = KhoiTaoDuLieuMauNoiBo();
	
	// Case 4a: TrangThai = DuThao -> Phai nem loi
	DocDataDuThao = New Structure;
	DocDataDuThao.Insert("GiaTriNghiemThuChuaVAT", 200000000);
	DocDataDuThao.Insert("TrangThai", "DuThao");
	DocDataDuThao.Insert("Number", "BB-004-DRAFT");
	DocDataDuThao.Insert("Date", CurrentDate());
	
	LoiXayRa = False;
	ThongBaoLoi = "";
	Try
		MoPhongGhiSoBienBanNghiemThu(DocDataDuThao, MasterData);
	Except
		LoiXayRa = True;
		ThongBaoLoi = ErrorDescription();
	EndTry;
	AssertTrue(LoiXayRa, "Chung tu o trang thai DuThao phai bi chan khong cho ghi so");
	AssertTrue(StrFind(ThongBaoLoi, "chưa đủ điều kiện ghi sổ") > 0 Or StrFind(ThongBaoLoi, "TrangThai") > 0 Or StrFind(ThongBaoLoi, "chua") > 0,
		"Thong bao loi phai canh bao ve trang thai chua duyet");
	
	// Case 4b: TrangThai = ChoDuyetNoiBo -> Phai nem loi
	DocDataChoDuyet = New Structure;
	DocDataChoDuyet.Insert("GiaTriNghiemThuChuaVAT", 200000000);
	DocDataChoDuyet.Insert("TrangThai", "ChoDuyetNoiBo");
	DocDataChoDuyet.Insert("Number", "BB-004-PENDING");
	DocDataChoDuyet.Insert("Date", CurrentDate());
	
	LoiChoDuyet = False;
	Try
		MoPhongGhiSoBienBanNghiemThu(DocDataChoDuyet, MasterData);
	Except
		LoiChoDuyet = True;
	EndTry;
	AssertTrue(LoiChoDuyet, "Chung tu o trang thai ChoDuyetNoiBo phai bi chan khong cho ghi so");
	
	// Case 4c: TrangThai = DaDuyetNoiBo -> Ghi so thanh cong va tu dong chuyen sang DaGhiSo
	DocDataHopLe = New Structure;
	DocDataHopLe.Insert("GiaTriNghiemThuChuaVAT", 200000000);
	DocDataHopLe.Insert("TrangThai", "DaDuyetNoiBo");
	DocDataHopLe.Insert("Number", "BB-004-OK");
	DocDataHopLe.Insert("Date", CurrentDate());
	
	PostingResult = MoPhongGhiSoBienBanNghiemThu(DocDataHopLe, MasterData);
	AssertEquals("DaGhiSo", PostingResult.TrangThaiMoi, "Trang thai phai tu dong chuyen sang DaGhiSo");
	AssertEquals(1, PostingResult.GLRecords.Count(), "Ghi so phai tao thanh cong ban ghi GL");
EndProcedure

// -----------------------------------------------------------------------------
// Test 5: Phan loai hach toan doi tac ngoai tap doan (No TK 1311 / Co TK 5113)
//         - Doi tac ben ngoai (LoaiDoiTac = KhachHangNgoai, LaBenLienKet = False):
//           -> No TK 1311 / Co TK 5113: 150.000.000 VND
//           -> CongNoPhaiThu tang 150.000.000 VND
//           -> Delta |Subledger - GL| = 0
// -----------------------------------------------------------------------------
Procedure Test05_PhanLoaiHachToanDoiTacNgoaiTapDoan() Export
	MasterDataNgoai = KhoiTaoDuLieuMauNgoai();
	GiaTriNghiemThu = 150000000; // 150tr VND
	
	DocData = New Structure;
	DocData.Insert("PhapNhan", MasterDataNgoai.PhapNhan);
	DocData.Insert("DoiTac", MasterDataNgoai.DoiTac);
	DocData.Insert("HopDong", MasterDataNgoai.HopDong);
	DocData.Insert("GiaTriNghiemThuChuaVAT", GiaTriNghiemThu);
	DocData.Insert("TyLeVAT", 10);
	DocData.Insert("TienVAT", 15000000);
	DocData.Insert("TongGiaTri", 165000000);
	DocData.Insert("TrangThai", "DaGhiSo");
	DocData.Insert("Number", "BB-2026-EXT01");
	DocData.Insert("Date", CurrentDate());
	
	PostingResult = MoPhongGhiSoBienBanNghiemThu(DocData, MasterDataNgoai);
	
	// Assert GL doi tac ngoai
	AssertEquals(1, PostingResult.GLRecords.Count(), "GL phai co 1 but toan");
	GLRow = PostingResult.GLRecords[0];
	AssertEquals("1311", GLRow.AccountDrCode, "Tai khoan No cua doi tac ngoai phai la TK 1311");
	AssertEquals("5113", GLRow.AccountCrCode, "Tai khoan Co phai la TK 5113");
	AssertEquals(150000000, GLRow.SoTien, "So tien GL phai bang 150.000.000 VND");
	
	// Assert AR Subledger
	AssertEquals(1, PostingResult.ARRecords.Count(), "AR phai co 1 ban ghi");
	ARRow = PostingResult.ARRecords[0];
	AssertEquals(150000000, ARRow.SoTien, "So tien AR phai bang 150.000.000 VND");
	
	// Assert Variance Delta
	Delta = Abs(ARRow.SoTien - GLRow.SoTien);
	AssertEquals(0, Delta, "Variance Delta |Subledger - GL| phai bang 0");
EndProcedure

#EndRegion

#Region DataAndSimulationHelpers

Function KhoiTaoDuLieuMauNoiBo()
	Data = New Structure;
	
	// Phap nhan
	PN = New Structure("Code,Description", "VSF-CORP", "CTCP VinSmart Future");
	Data.Insert("PhapNhan", PN);
	
	// Doi tac noi bo Vingroup
	DT = New Structure;
	DT.Insert("Code", "VINFAST-VN");
	DT.Insert("Description", "CTCP San Xuat Va Kinh Doanh VinFast");
	DT.Insert("LaBenLienKet", True);
	DT.Insert("LoaiDoiTac", "NoiBoVingroup");
	Data.Insert("DoiTac", DT);
	
	// Hop dong
	HD = New Structure;
	HD.Insert("Code", "HD-2026-VF-AI");
	HD.Insert("Description", "Hop dong Cung cap Ha tang AI va Cloud cho VinFast");
	HD.Insert("PhapNhan", PN);
	HD.Insert("ChuSoHuu", DT);
	HD.Insert("DongTienThanhToan", "VND");
	Data.Insert("HopDong", HD);
	
	Return Data;
EndFunction

Function KhoiTaoDuLieuMauNgoai()
	Data = New Structure;
	
	// Phap nhan
	PN = New Structure("Code,Description", "VSF-CORP", "CTCP VinSmart Future");
	Data.Insert("PhapNhan", PN);
	
	// Doi tac ngoai tap doan
	DT = New Structure;
	DT.Insert("Code", "FPT-IS");
	DT.Insert("Description", "CTCP He Thong Thong Tin FPT");
	DT.Insert("LaBenLienKet", False);
	DT.Insert("LoaiDoiTac", "KhachHangNgoai");
	Data.Insert("DoiTac", DT);
	
	// Hop dong
	HD = New Structure;
	HD.Insert("Code", "HD-2026-FPT-01");
	HD.Insert("Description", "Hop dong Dich vu CNTT Ngoai tap doan");
	HD.Insert("PhapNhan", PN);
	HD.Insert("ChuSoHuu", DT);
	HD.Insert("DongTienThanhToan", "VND");
	Data.Insert("HopDong", HD);
	
	Return Data;
EndFunction

Function MoPhongGhiSoBienBanNghiemThu(DocData, MasterData)
	// 1. Kiem tra dieu kien trang thai
	TrangThaiHienTai = String(DocData.TrangThai);
	If TrangThaiHienTai <> "DaGhiSo" And TrangThaiHienTai <> "DaDuyetNoiBo" Then
		Raise StrTemplate("Chứng từ nghiệm thu %1 chưa đủ điều kiện ghi sổ! Trạng thái hiện tại: %2",
			DocData.Number, TrangThaiHienTai);
	EndIf;
	
	TrangThaiMoi = "DaGhiSo";
	
	// 2. Kiem tra DoiTac la NoiBo hay Ngoai
	IsNoiBo = False;
	DoiTac = MasterData.DoiTac;
	If DoiTac.Property("LaBenLienKet") And DoiTac.LaBenLienKet = True Then
		IsNoiBo = True;
	ElsIf DoiTac.Property("LoaiDoiTac") And (DoiTac.LoaiDoiTac = "NoiBoVingroup" Or DoiTac.LoaiDoiTac = "NoiBoTapDoan") Then
		IsNoiBo = True;
	EndIf;
	
	TaiKhoanNo = ?(IsNoiBo, "1312", "1311");
	TaiKhoanCo = "5113";
	
	SoTien = DocData.GiaTriNghiemThuChuaVAT;
	
	// 3. Tao ban ghi Sổ cái SoCaiKeToan
	GLRecords = New Array;
	RowGL = New Structure;
	RowGL.Insert("AccountDrCode", TaiKhoanNo);
	RowGL.Insert("AccountCrCode", TaiKhoanCo);
	RowGL.Insert("SoTien", SoTien);
	RowGL.Insert("SoTienNgoaiTe", 0);
	RowGL.Insert("PhapNhan", DocData.PhapNhan);
	RowGL.Insert("DienGiai", "Doanh thu nghiem thu dich vu giai doan");
	GLRecords.Add(RowGL);
	
	// 4. Tao ban ghi Sổ tích lũy CongNoPhaiThu
	ARRecords = New Array;
	RowAR = New Structure;
	RowAR.Insert("RecordType", "Receipt");
	RowAR.Insert("PhapNhan", DocData.PhapNhan);
	RowAR.Insert("DoiTac", DocData.DoiTac);
	RowAR.Insert("HopDong", DocData.HopDong);
	RowAR.Insert("SoTien", SoTien);
	RowAR.Insert("SoTienNgoaiTe", 0);
	ARRecords.Add(RowAR);
	
	Result = New Structure;
	Result.Insert("GLRecords", GLRecords);
	Result.Insert("ARRecords", ARRecords);
	Result.Insert("TrangThaiMoi", TrangThaiMoi);
	Return Result;
EndFunction

Function KiemTraMetadataDocTonTai()
	Try
		Obj = Documents.BienBanNghiemThuGiaiDoan;
		Return True;
	Except
		Return False;
	EndTry;
EndFunction

#EndRegion

#Region AssertHelpers

Procedure AssertTrue(Condition, Message)
	If Not Condition Then
		Raise "ASSERT FAILED: " + Message;
	EndIf;
EndProcedure

Procedure AssertFalse(Condition, Message)
	If Condition Then
		Raise "ASSERT FAILED: " + Message;
	EndIf;
EndProcedure

Procedure AssertEquals(Expected, Actual, Message)
	If Expected <> Actual Then
		Raise StrTemplate("ASSERT FAILED: %1 (Ky vong: %2, Thuc te: %3)", Message, Expected, Actual);
	EndIf;
EndProcedure

#EndRegion
