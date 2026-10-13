// Unit Test Suite: ChartOfAccountsTest
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL / BUnit / Vanessa)
// Muc tieu: Kiem thu HeThongTaiKhoan (Anh xa MaLogic -> SoHieuTK), Invariant can doi SoCaiKeToan (Sum Dr = Sum Cr),
//           va Maker-Checker Rule tap trung tren QuanLyVongDoiChungTuServer (Task 1.3).

#Region TestExecution

Function RunAllTests() Export
	TestResults = New Structure;
	TestResults.Insert("Total", 4);
	TestResults.Insert("Passed", 0);
	TestResults.Insert("Failed", 0);
	TestResults.Insert("Log", New Array);
	
	TestLog = TestResults.Log;
	TestLog.Add("=================================================================");
	TestLog.Add("   VINSMART FUTURE - CHART OF ACCOUNTS & GL UNIT TEST (TASK 1.3) ");
	TestLog.Add("   Thoi gian chay: " + CurrentDate());
	TestLog.Add("=================================================================");
	
	// Test 1: Anh xa thanh cong MaLogic = "1312" (AR Noi bo) va MaLogic = "33318" (Thue VAT Nha thau)
	Try
		Test01_AnhXaMaLogicSangSoHieuTK();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 1: Anh xa MaLogic -> SoHieuTK thanh cong (1312 AR Noi bo, 33318 FCT VAT).");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 1: Anh xa MaLogic that bai - " + ErrorDescription());
	EndTry;
	
	// Test 2: Invariant can doi tien te Sum Dr = Sum Cr tren ban ghi SoCaiKeToan
	Try
		Test02_InvariantCanDoiTienTeSoCaiKeToan();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 2: Invariant can doi tien te Sum Dr = Sum Cr xac thuc thanh cong.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 2: Invariant can doi SoCaiKeToan that bai - " + ErrorDescription());
	EndTry;
	
	// Test 3: Maker-Checker chan nguoi tao tu ky duyet (ke ca Admin)
	Try
		Test03_MakerCheckerChanNguoiTaoTuKyDuyet();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 3: Maker-Checker chan nguoi tao tu ky duyet (khong ngoai le Admin), bypass SA thanh cong.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 3: Maker-Checker kiem soat tu duyet that bai - " + ErrorDescription());
	EndTry;
	
	// Test 4: Maker-Checker cam tuyet doi nguoi tao ky lenh chi tien UyNhiemChi
	Try
		Test04_MakerCheckerCamTuyetDoiUyNhiemChi();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 4: Maker-Checker cam tuyet doi nguoi tao ky lenh chi UyNhiemChi thanh cong.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 4: Cam tuyet doi lenh chi UyNhiemChi that bai - " + ErrorDescription());
	EndTry;
	
	TestLog.Add("-----------------------------------------------------------------");
	TestLog.Add(StrTemplate("Tong so test: %1 | Thanh cong: %2 | That bai: %3", 
		TestResults.Total, TestResults.Passed, TestResults.Failed));
	TestLog.Add("=================================================================");
	
	Return TestResults;
EndFunction

#EndRegion

#Region TestCases

// Test 1: Anh xa thanh cong MaLogic sang SoHieuTK
// - MaLogic = "1312" -> TK 1312 (Phai thu khach hang noi bo Vingroup)
// - MaLogic = "33318" -> TK 33318 (Thue VAT Nha thau - FCT VAT)
Procedure Test01_AnhXaMaLogicSangSoHieuTK() Export
	// 1a. Kiem tra MaLogic "1312" (AR Noi bo Vingroup)
	Acc1312 = QuanLyVongDoiChungTuServer.LayTaiKhoanTheoMaLogic("1312");
	AssertTrue(Acc1312 <> Undefined, "Tai khoan MaLogic 1312 phai ton tai");
	AssertEquals("1312", Acc1312.Code, "So hieu tai khoan cua MaLogic 1312 phai la '1312'");
	AssertTrue(StrFind(Lower(Acc1312.TenTaiKhoan), "nội bộ") > 0 Or StrFind(Lower(Acc1312.TenTaiKhoan), "noi bo") > 0, 
		"Ten tai khoan 1312 phai mo ta 'noi bo'");
	AssertEquals("ActivePassive", Acc1312.TinhChat, "Tinh chat tai khoan 1312 phai la ActivePassive (Luong tinh)");
	
	// 1b. Kiem tra MaLogic "33318" (Thue GTGT Nha thau nuoc ngoai - FCT VAT)
	Acc33318 = QuanLyVongDoiChungTuServer.LayTaiKhoanTheoMaLogic("33318");
	AssertTrue(Acc33318 <> Undefined, "Tai khoan MaLogic 33318 phai ton tai");
	AssertEquals("33318", Acc33318.Code, "So hieu tai khoan cua MaLogic 33318 phai la '33318'");
	AssertTrue(StrFind(Lower(Acc33318.TenTaiKhoan), "nhà thầu") > 0 Or StrFind(Lower(Acc33318.TenTaiKhoan), "nha thau") > 0, 
		"Ten tai khoan 33318 phai mo ta thue nha thau");
	AssertEquals("Passive", Acc33318.TinhChat, "Tinh chat tai khoan 33318 phai la Passive (Nguon von)");
	
	// 1c. Kiem tra cac MaLogic cot loi khac trong danh muc 18 tai khoan
	Acc1121 = QuanLyVongDoiChungTuServer.LayTaiKhoanTheoMaLogic("1121");
	AssertEquals("1121", Acc1121.Code, "So hieu tai khoan 1121 phai la '1121'");
	AssertEquals("Active", Acc1121.TinhChat, "Tinh chat tai khoan 1121 phai la Active (Tai san)");
	
	Acc3311 = QuanLyVongDoiChungTuServer.LayTaiKhoanTheoMaLogic("3311");
	AssertEquals("3311", Acc3311.Code, "So hieu tai khoan 3311 phai la '3311'");
	
	Acc5113 = QuanLyVongDoiChungTuServer.LayTaiKhoanTheoMaLogic("5113");
	AssertEquals("5113", Acc5113.Code, "So hieu tai khoan 5113 phai la '5113'");
	
	Acc627 = QuanLyVongDoiChungTuServer.LayTaiKhoanTheoMaLogic("627");
	AssertEquals("627", Acc627.Code, "So hieu tai khoan 627 phai la '627'");
	
	// Kiem tra cac tai khoan quan tri va ngoai te moi them
	Acc3313 = QuanLyVongDoiChungTuServer.LayTaiKhoanTheoMaLogic("3313");
	AssertEquals("3313", Acc3313.Code, "So hieu tai khoan 3313 phai la '3313'");
	
	Acc3318 = QuanLyVongDoiChungTuServer.LayTaiKhoanTheoMaLogic("3318");
	AssertEquals("3318", Acc3318.Code, "So hieu tai khoan 3318 phai la '3318'");
	
	Acc3388 = QuanLyVongDoiChungTuServer.LayTaiKhoanTheoMaLogic("3388");
	AssertEquals("3388", Acc3388.Code, "So hieu tai khoan 3388 phai la '3388'");
	
	Acc641 = QuanLyVongDoiChungTuServer.LayTaiKhoanTheoMaLogic("641");
	AssertEquals("641", Acc641.Code, "So hieu tai khoan 641 phai la '641'");
	
	// 1d. Kiem tra MaLogic khong hop le -> phai nem loi
	ErrorThrown = False;
	Try
		QuanLyVongDoiChungTuServer.LayTaiKhoanTheoMaLogic("MA_KHONG_TON_TAI_9999");
	Except
		ErrorThrown = True;
	EndTry;
	AssertTrue(ErrorThrown, "Lay tai khoan voi MaLogic khong ton tai phai nem ngoai le");
EndProcedure

// Test 2: Invariant can doi tien te Sum Dr = Sum Cr tren ban ghi SoCaiKeToan
Procedure Test02_InvariantCanDoiTienTeSoCaiKeToan() Export
	// Case 2a: But toan don can doi: No 1312 / Co 5113: 200,000,000 VND
	EntriesBalanced = New Array;
	Entry1 = New Structure("AccountDr,AccountCr,SoTien,AmountDr,AmountCr,LoaiPhatSinh", "1312", "5113", 200000000, 200000000, 200000000, "");
	EntriesBalanced.Add(Entry1);
	
	Result1 = QuanLyVongDoiChungTuServer.KiemTraCanDoiSoCai(EntriesBalanced);
	AssertTrue(Result1, "But toan can doi phai thoa man Invariant");
	
	// Case 2b: But toan phuc hop FCT Gross 250,000,000 VND (HoaDonNhaCungCap AWS Cloud)
	// No 627: 237.5tr, No 1331: 12.5tr / Co 3311: 225tr, Co 33318: 12.5tr, Co 3338: 12.5tr
	EntriesFCT = New Array;
	EntriesFCT.Add(New Structure("AmountDr,AmountCr", 237500000, 0)); // No 627
	EntriesFCT.Add(New Structure("AmountDr,AmountCr", 12500000, 0));  // No 1331
	EntriesFCT.Add(New Structure("AmountDr,AmountCr", 0, 225000000)); // Co 3311
	EntriesFCT.Add(New Structure("AmountDr,AmountCr", 0, 12500000));  // Co 33318
	EntriesFCT.Add(New Structure("AmountDr,AmountCr", 0, 12500000));  // Co 3338
	
	Result2 = QuanLyVongDoiChungTuServer.KiemTraCanDoiSoCai(EntriesFCT);
	AssertTrue(Result2, "But toan FCT can doi (Tong No 250tr = Tong Co 250tr) phai thoa man Invariant");
	
	// Case 2c: But toan mat can doi (No 200,000,000 / Co 190,000,000) -> Phai nem loi
	EntriesUnbalanced = New Array;
	EntriesUnbalanced.Add(New Structure("AmountDr,AmountCr", 200000000, 0));
	EntriesUnbalanced.Add(New Structure("AmountDr,AmountCr", 0, 190000000));
	
	ErrorThrown = False;
	ErrorText = "";
	Try
		QuanLyVongDoiChungTuServer.KiemTraCanDoiSoCai(EntriesUnbalanced);
	Except
		ErrorThrown = True;
		ErrorText = ErrorDescription();
	EndTry;
	
	AssertTrue(ErrorThrown, "But toan lech tien te phai bi phat hien va nem loi vi pham Invariant");
	AssertTrue(StrFind(ErrorText, "Invariant") > 0 Or StrFind(ErrorText, "cân đối") > 0 Or StrFind(ErrorText, "can doi") > 0, 
		"Thong diep loi phai canh bao vi pham Invariant can doi tien te");
EndProcedure

// Test 3: Maker-Checker chan nguoi tao tu ky duyet (ke ca Admin)
Procedure Test03_MakerCheckerChanNguoiTaoTuKyDuyet() Export
	// Case 3a: Nguoi dung thuong NguyenVanA lap chung tu BienBanNghiemThu, co tinh tu phe duyet
	DocMock1 = New Structure;
	DocMock1.Insert("Author", "NguyenVanA");
	DocMock1.Insert("DocumentType", "BienBanNghiemThuGiaiDoan");
	DocMock1.Insert("Number", "BB-001");
	
	ErrorOccurred = False;
	ErrorMessage = "";
	Try
		QuanLyVongDoiChungTuServer.KiemTraChuyenTrangThai(DocMock1, "DaDuyetNoiBo", "NguyenVanA");
	Except
		ErrorOccurred = True;
		ErrorMessage = ErrorDescription();
	EndTry;
	
	AssertTrue(ErrorOccurred, "Nguoi tao (NguyenVanA) TUYET DOI KHONG duoc phep tu phe duyet chung tu cua minh");
	AssertTrue(StrFind(ErrorMessage, "Maker-Checker") > 0 Or StrFind(ErrorMessage, "Người tạo không thể tự phê duyệt") > 0,
		"Thong bao loi phai nhac toi nguyen tac Maker-Checker");
	
	// Case 3b: Admin he thong lap chung tu va co tinh tu duyet -> CUNG PHAI BI CHAN (Khong ngoai le Admin)
	DocAdmin = New Structure;
	DocAdmin.Insert("Author", "Admin");
	DocAdmin.Insert("DocumentType", "HoaDonGTGTDauRa");
	DocAdmin.Insert("Number", "HD-001");
	
	ErrorAdminOccurred = False;
	Try
		QuanLyVongDoiChungTuServer.KiemTraChuyenTrangThai(DocAdmin, "DaPhatHanh", "Admin");
	Except
		ErrorAdminOccurred = True;
	EndTry;
	
	AssertTrue(ErrorAdminOccurred, "Admin he thong CUNG KHONG duoc phep tu phe duyet chung tu do chinh minh lap");
	
	// Case 3c: Nguoi duyet khac (Maker != Checker) -> Cho phep thanh cong
	ApprovedSuccess = True;
	Try
		QuanLyVongDoiChungTuServer.KiemTraChuyenTrangThai(DocMock1, "DaDuyetNoiBo", "KeToanTruong");
	Except
		ApprovedSuccess = False;
	EndTry;
	AssertTrue(ApprovedSuccess, "Nguoi duyet khac voi nguoi tao phai duoc phep thuc hien phe duyet");
	
EndProcedure

// Test 4: Maker-Checker cam tuyet doi nguoi tao ky lenh chi tien UyNhiemChi
Procedure Test04_MakerCheckerCamTuyetDoiUyNhiemChi() Export
	// Case 4a: Nguoi lap lenh chi tien co tinh ky duyet lenh chi cua chinh minh
	DocUNC = New Structure;
	DocUNC.Insert("Author", "KeToanAP_Hung");
	DocUNC.Insert("DocumentType", "UyNhiemChi");
	DocUNC.Insert("Number", "UNC-2026-0001");
	
	ErrorOccurred = False;
	ErrorMessage = "";
	Try
		QuanLyVongDoiChungTuServer.KiemTraChuyenTrangThai(DocUNC, "DaDuyet", "KeToanAP_Hung");
	Except
		ErrorOccurred = True;
		ErrorMessage = ErrorDescription();
	EndTry;
	
	AssertTrue(ErrorOccurred, "Nguoi lap UyNhiemChi phai bi chan tuyet doi khi tham gia phe duyet");
	AssertTrue(StrFind(ErrorMessage, "CẤM TUYỆT ĐỐI") > 0 Or StrFind(ErrorMessage, "lệnh chi tiền") > 0 Or StrFind(ErrorMessage, "lenh chi") > 0,
		"Thong diep loi phai neu ro: 'CẤM TUYỆT ĐỐI: Người lập lệnh chi tiền không được phép tham gia phê duyệt!'");
	
	// Case 4b: CFO lap UyNhiemChi va tu ky duyet -> Cung bi chan tuyet doi
	DocUNC_CFO = New Structure;
	DocUNC_CFO.Insert("Author", "CFO_Director");
	DocUNC_CFO.Insert("DocumentType", "UyNhiemChi");
	DocUNC_CFO.Insert("Number", "UNC-2026-0002");
	
	ErrorCFO = False;
	Try
		QuanLyVongDoiChungTuServer.KiemTraChuyenTrangThai(DocUNC_CFO, "DaDuyet", "CFO_Director");
	Except
		ErrorCFO = True;
	EndTry;
	AssertTrue(ErrorCFO, "Cap lanh dao (CFO) neu tu lap UyNhiemChi cung khong duoc tu duyet");
	
	// Case 4c: Nguoi lap la KeToanAP_Hung, nguoi phe duyet la CFO_Director -> Thanh cong
	ApprovalValid = True;
	Try
		QuanLyVongDoiChungTuServer.KiemTraChuyenTrangThai(DocUNC, "DaDuyet", "CFO_Director");
	Except
		ApprovalValid = False;
	EndTry;
	AssertTrue(ApprovalValid, "Nguoi duyet doc lap (CFO) phai phe duyet thanh cong lenh chi hop le");
EndProcedure

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
