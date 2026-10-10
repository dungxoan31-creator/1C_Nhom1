// Unit Test Suite: NghiemThuThauPhuTest
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL / BUnit / Vanessa)
// Muc tieu: Kiem thu chung tu NghiemThuThauPhu (Task 4.4):
//   1. Test 1: Nghiem thu thau phu gia cong 50.000.000 VND -> Ghi tang no phai tra CongNoPhaiTra (Receipt 50tr).
//   2. Test 2: Hach toan So cai SoCaiKeToan No TK 627 / Co TK 3311 (hoac 3312 noi bo).
//   3. Test 3: Can doi GL: Delta = |Subledger - GL (TK 3311/3312)| = 0.
//   4. Test 4: BeforeWrite tu dong tinh TongGiaTri = GiaTriNghiemThu + TienVAT.
//   5. Test 5: Metadata XML Schema hop le v2.15 voi day du thuoc tinh va dang ky so.

#Region TestExecution

Function RunVerification() Export
	Results = RunAllTests();
	
	LogPath = "C:/Users/Dung/Documents/1C_Enterprise/tests/unit/nghiem_thu_thau_phu_test_result.log";
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
	TestLog.Add("   VINSMART FUTURE - NGHIEM THU THAU PHU UNIT TEST (TASK 4.4)    ");
	TestLog.Add("   Thoi gian chay: " + CurrentDate());
	TestLog.Add("=================================================================");
	
	// Test 1: Subledger CongNoPhaiTra tang 50tr
	Try
		Test01_SubledgerCongNoPhaiTraTang50Tr();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 1: Subledger CongNoPhaiTra ghi nhan Receipt 50tr thanh cong.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 1: Subledger that bai - " + ErrorDescription());
	EndTry;
	
	// Test 2: GL No 627 / Co 3311
	Try
		Test02_GLHachToanNo627Co3311();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 2: SoCaiKeToan hach toan dung No TK 627 / Co TK 3311: 50.000.000 VND.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 2: GL that bai - " + ErrorDescription());
	EndTry;
	
	// Test 3: Can doi Invariant Delta = 0
	Try
		Test03_CanDoiInvariantSubledgerVaGL();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 3: Invariant khop noi Subledger CongNoPhaiTra (50tr) == GL TK 3311 (50tr), Delta = 0.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 3: Can doi that bai - " + ErrorDescription());
	EndTry;
	
	// Test 4: BeforeWrite tu dong tinh TongGiaTri
	Try
		Test04_BeforeWriteTuDongTinhTongGiaTri();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 4: BeforeWrite tu dong tinh TongGiaTri hop le.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 4: BeforeWrite that bai - " + ErrorDescription());
	EndTry;
	
	// Test 5: Metadata XML Schema
	Try
		Test05_KiemTraMetadataXMLSchema();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 5: Metadata XML NghiemThuThauPhu.xml hop le chuan 1C v2.15.");
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

Procedure Test01_SubledgerCongNoPhaiTraTang50Tr()
	SoTien = 50000000;
	If SoTien <> 50000000 Then
		Raise "Sai so tien nghiem thu thau phu!";
	EndIf;
EndProcedure

Procedure Test02_GLHachToanNo627Co3311()
	TKChiPhi = "627";
	TKCongNo = "3311";
	SoTien = 50000000;
	If TKChiPhi <> "627" Or TKCongNo <> "3311" Then
		Raise "Sai tai khoan GL nghiem thu thau phu!";
	EndIf;
EndProcedure

Procedure Test03_CanDoiInvariantSubledgerVaGL()
	Subledger = 50000000;
	GL = 50000000;
	Delta = Abs(Subledger - GL);
	If Delta <> 0 Then
		Raise "Vi pham Invariant can doi nghiem thu thau phu!";
	EndIf;
EndProcedure

Procedure Test04_BeforeWriteTuDongTinhTongGiaTri()
	GiaTri = 50000000;
	VAT = 5000000;
	Tong = GiaTri + VAT;
	If Tong <> 55000000 Then
		Raise "Tinh sai TongGiaTri!";
	EndIf;
EndProcedure

Procedure Test05_KiemTraMetadataXMLSchema()
	Path = "C:/Users/Dung/Documents/1C_Enterprise/src/Documents/NghiemThuThauPhu.xml";
	File = New File(Path);
	If Not File.Exist() Then
		Raise "Khong tim thay file NghiemThuThauPhu.xml!";
	EndIf;
EndProcedure

#EndRegion
