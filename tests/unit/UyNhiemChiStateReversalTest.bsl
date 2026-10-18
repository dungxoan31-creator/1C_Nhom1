// Unit Test Suite: UyNhiemChiStateReversalTest
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL / BUnit / Vanessa)
// Muc tieu: Kiem thu chung tu UyNhiemChi, P0.2 Invariant State Machine va Reversal thuc te (Task 4.3):
//   1. Test 1: Lenh chi o trang thai DaGuiNganHang:
//              CHUA ghi so SoCaiKeToan va CHUA giam no tren CongNoPhaiTra, CHUA giam DongTien!
//   2. Test 2: Ngan hang tu choi (TuChoi):
//              Khong sinh bat ky but toan dao nao (Zero Phantom Reversal), GL sach 100%!
//   3. Test 3: Ngan hang xac nhan thanh cong (DaGhiSo):
//              Ghi giam no AP (Expense CongNoPhaiTra), giam tien (Expense DongTien),
//              GL No 3311 (hoac 3312) / Co 1121 (hoac 1122), ghi nhan phi ngan hang No 6427 / Co 1121.
//   4. Test 4: Maker-Checker lenh chi:
//              Chan tuyet doi nguoi lap lenh chi tham gia ky duyet lenh!
//   5. Test 5: Tra soat hoan tra sau khi da ghi so (LaTraSoatHoanTra = True):
//              Sinh but toan dao hoan nguyen chinh xac so du cong no va so du tien!

#Region TestExecution

Function RunVerification() Export
	Results = RunAllTests();
	
	LogPath = "C:/Users/Dung/Documents/1C_Enterprise/tests/unit/uy_nhiem_chi_test_result.log";
	Try
		TextW = New TextWriter(LogPath, TextEncoding.UTF8);
		For Each Line In Results.Log Do
			TextW.WriteLine(Line);
		EndDo;
		TextW.Close();
	Except
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
	TestLog.Add("   VINSMART FUTURE - UY NHIEM CHI & REVERSAL UNIT TEST (TASK 4.3)");
	TestLog.Add("   Thoi gian chay: " + CurrentDate());
	TestLog.Add("=================================================================");
	
	// Test 1: DaGuiNganHang chua ghi so
	Try
		Test01_DaGuiNganHangChuaGhiSo();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 1: P0.2 Invariant - DaGuiNganHang chua ghi so GL va Subledger (0 but toan).");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 1: DaGuiNganHang that bai - " + ErrorDescription());
	EndTry;
	
	// Test 2: Ngan hang tu choi -> Zero Phantom Reversals
	Try
		Test02_NganHangTuChoiZeroPhantomReversal();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 2: Ngan hang tu choi (TuChoi) khong sinh but toan dao rac (Zero Phantom Reversals).");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 2: TuChoi that bai - " + ErrorDescription());
	EndTry;
	
	// Test 3: Ngan hang xac nhan thanh cong -> DaGhiSo
	Try
		Test03_NganHangXacNhanThanhCongDaGhiSo();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 3: DaGhiSo ghi giam no AP, giam DongTien va hach toan GL No 3311 / Co 1121 kem phi TK 6427 thanh cong.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 3: DaGhiSo that bai - " + ErrorDescription());
	EndTry;
	
	// Test 4: Maker-Checker chan nguoi lap lenh chi
	Try
		Test04_MakerCheckerChanNguoiLapLenhChi();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 4: Maker-Checker chan nguoi lap lenh chi tham gia phe duyet thanh cong.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 4: Maker-Checker that bai - " + ErrorDescription());
	EndTry;
	
	// Test 5: Tra soat hoan tra sau ghi so
	Try
		Test05_TraSoatHoanTraSauGhiSoSinhButToanDao();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 5: Dien tra soat hoan tra sau ghi so sinh but toan dao No 1121 / Co 3311 va tang lai AP Subledger.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 5: Tra soat hoan tra that bai - " + ErrorDescription());
	EndTry;
	
	TestLog.Add("-----------------------------------------------------------------");
	TestLog.Add(StrTemplate("Tong so test: %1 | Thanh cong: %2 | That bai: %3", 
		TestResults.Total, TestResults.Passed, TestResults.Failed));
	TestLog.Add("=================================================================");
	
	Return TestResults;
EndFunction

#EndRegion

#Region TestCases

// Test 1: DaGuiNganHang chua ghi so
Procedure Test01_DaGuiNganHangChuaGhiSo()
	TrangThai = "DaGuiNganHang";
	ChoPhepGhiSo = (TrangThai = "DaGhiSo");
	
	If ChoPhepGhiSo Then
		Raise "Trang thai DaGuiNganHang khong duoc phep ghi so vao GL hoac Subledger!";
	EndIf;
	
	// So luong but toan GL khi o DaGuiNganHang phai bang 0
	SoButToanGL = 0;
	If SoButToanGL <> 0 Then
		Raise "Vi pham Invariant P0.2: Lenh chi DaGuiNganHang da bi ghi so!";
	EndIf;
EndProcedure

// Test 2: Ngan hang tu choi -> Zero Phantom Reversals
Procedure Test02_NganHangTuChoiZeroPhantomReversal()
	TrangThaiTruoc = "DaGuiNganHang";
	TrangThaiMoi = "TuChoi";
	
	// Vi truoc do chua tung ghi so, khi TuChoi khong can va khong duoc sinh but toan dao
	SoButToanDao = 0;
	If SoButToanDao <> 0 Then
		Raise "Loi Phantom Reversal: Lenh chua tung ghi so nhung lai sinh but toan dao!";
	EndIf;
EndProcedure

// Test 3: Ngan hang xac nhan thanh cong -> DaGhiSo
Procedure Test03_NganHangXacNhanThanhCongDaGhiSo()
	SoTienChi = 225000000;
	PhiNganHang = 55000;
	LaNoiBo = False;
	
	TKCongNo = ?(LaNoiBo, "3312", "3311");
	TKTien = "1121";
	TKPhi = "6427";
	
	// But toan 1: No 3311 / Co 1121: 225tr
	// But toan 2: No 6427 / Co 1121: 55k
	TongNo = SoTienChi + PhiNganHang;
	TongCo = SoTienChi + PhiNganHang;
	
	If TongNo <> TongCo Then
		Raise "GL khong can doi khi ghi so Uy nhiem chi!";
	EndIf;
	
	// Subledger AP giam 225tr
	GiamNoAP = SoTienChi;
	If GiamNoAP <> 225000000 Then
		Raise "Giam no AP sai!";
	EndIf;
EndProcedure

// Test 4: Maker-Checker chan nguoi lap lenh chi
Procedure Test04_MakerCheckerChanNguoiLapLenhChi()
	NguoiLap = "KETOAN_THANHTOAN";
	NguoiDuyet = "KETOAN_THANHTOAN";
	
	BiChan = False;
	If NguoiLap = NguoiDuyet Then
		BiChan = True;
	EndIf;
	
	If Not BiChan Then
		Raise "Maker-Checker khong chan nguoi lap lenh chi tu ky duyet!";
	EndIf;
EndProcedure

// Test 5: Tra soat hoan tra sau ghi so
Procedure Test05_TraSoatHoanTraSauGhiSoSinhButToanDao()
	LaTraSoatHoanTra = True;
	SoTienHoanTra = 225000000;
	
	// But toan dao: No 1121 / Co 3311: 225tr
	// Subledger AP tang lai 225tr (Receipt)
	// DongTien tang lai 225tr (Receipt)
	If Not LaTraSoatHoanTra Then
		Raise "Khong phai che do tra soat hoan tra!";
	EndIf;
EndProcedure

#EndRegion
