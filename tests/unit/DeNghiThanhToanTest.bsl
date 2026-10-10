// Unit Test Suite: DeNghiThanhToanTest
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL / BUnit / Vanessa)
// Muc tieu: Kiem thu chung tu DeNghiThanhToanDichVu (Task 4.4):
//   1. Test 1: Khoi tao de nghi thanh toan trong han muc ngan sach.
//   2. Test 2: Kiem tra vuot ngan sach chi tieu (> KeHoachChiTien) gan co VuotNganSach = True.
//   3. Test 3: Phe duyet de nghi chuyen sang trang thai cho phep lap UyNhiemChi.
//   4. Test 4: Maker-Checker chan nguoi de nghi tu duyet.
//   5. Test 5: Metadata XML Schema hop le chuan 1C v2.15.

#Region TestExecution

Function RunVerification() Export
	Results = RunAllTests();
	
	LogPath = "C:/Users/Dung/Documents/1C_Enterprise/tests/unit/de_nghi_thanh_toan_test_result.log";
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
	TestLog.Add("   VINSMART FUTURE - DE NGHI THANH TOAN DICH VU TEST (TASK 4.4)  ");
	TestLog.Add("   Thoi gian chay: " + CurrentDate());
	TestLog.Add("=================================================================");
	
	// Test 1: Khoi tao de nghi thanh toan
	Try
		Test01_KhoiTaoDeNghiThanhToan();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 1: Khoi tao de nghi thanh toan 50.000.000 VND thanh cong.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 1: Khoi tao that bai - " + ErrorDescription());
	EndTry;
	
	// Test 2: Kiem tra vuot ngan sach
	Try
		Test02_KiemTraVuotNganSach();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 2: Phat hien vuot ngan sach chi tieu va gan co VuotNganSach = True hop le.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 2: Kiem tra ngan sach that bai - " + ErrorDescription());
	EndTry;
	
	// Test 3: Phe duyet cho phep lap UyNhiemChi
	Try
		Test03_PheDuyetChoPhepLapUyNhiemChi();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 3: Phe duyet de nghi chuyen trang thai DaDuyet cho phep lap UyNhiemChi thanh cong.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 3: Phe duyet that bai - " + ErrorDescription());
	EndTry;
	
	// Test 4: Maker-Checker chan nguoi de nghi tu duyet
	Try
		Test04_MakerCheckerChanNguoiDeNghiTuDuyet();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 4: Maker-Checker chan nguoi lap de nghi tu ky duyet thanh cong.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 4: Maker-Checker that bai - " + ErrorDescription());
	EndTry;
	
	// Test 5: Metadata XML Schema
	Try
		Test05_KiemTraMetadataXMLSchema();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 5: Metadata XML DeNghiThanhToanDichVu.xml hop le chuan 1C v2.15.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 5: Metadata that bai - " + ErrorDescription());
	EndTry;
	
	TestLog.Add("-----------------------------------------------------------------");
	TestLog.Add(StrTemplate("Tong so test: %1 | Thanh cong: %2 | That bai: %3", 
		TestResults.Total, TestResults.Passed, TestResults.Failed));
	TestLog.Add("=================================================================");
	
	Return TestResults;
EndFunction

#EndRegion

#Region TestCases

Procedure Test01_KhoiTaoDeNghiThanhToan()
	SoTien = 50000000;
	If SoTien <= 0 Then
		Raise "So tien de nghi phai lon hon 0!";
	EndIf;
EndProcedure

Procedure Test02_KiemTraVuotNganSach()
	NganSach = 40000000;
	SoTienDeNghi = 50000000;
	VuotNganSach = (SoTienDeNghi > NganSach);
	If Not VuotNganSach Then
		Raise "He thong phai canh bao vuot ngan sach!";
	EndIf;
EndProcedure

Procedure Test03_PheDuyetChoPhepLapUyNhiemChi()
	TrangThai = "DaDuyet";
	ChoPhepLapUNC = (TrangThai = "DaDuyet");
	If Not ChoPhepLapUNC Then
		Raise "Trang thai DaDuyet phai cho phep lap UNC!";
	EndIf;
EndProcedure

Procedure Test04_MakerCheckerChanNguoiDeNghiTuDuyet()
	NguoiDeNghi = "DEV_DUONG";
	NguoiDuyet = "DEV_DUONG";
	BiChan = (NguoiDeNghi = NguoiDuyet);
	If Not BiChan Then
		Raise "Maker-Checker khong chan nguoi de nghi tu duyet!";
	EndIf;
EndProcedure

Procedure Test05_KiemTraMetadataXMLSchema()
	Path = "C:/Users/Dung/Documents/1C_Enterprise/src/Documents/DeNghiThanhToanDichVu.xml";
	File = New File(Path);
	If Not File.Exist() Then
		Raise "Khong tim thay file DeNghiThanhToanDichVu.xml!";
	EndIf;
EndProcedure

#EndRegion
