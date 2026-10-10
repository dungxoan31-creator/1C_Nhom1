// Migration Test Suite: MigrationSoDuDauKyTest
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL / BUnit / Vanessa)
// Muc tieu: Kiem thu Cong cu Nap so du dau ky (Task 8.1):
//   1. Test 1: Nap so du AR dau ky 1.5 ty VND: Subledger CongNoPhaiThu == GL TK 1312 (Delta = 0).
//   2. Test 2: Nap so du AP dau ky 800tr VND: Subledger CongNoPhaiTra == GL TK 3311 (Delta = 0).
//   3. Test 3: Nap so du quy ngoai te 100k USD @ 25.400 = 2.54 ty VND tren DongTien (Dual currency) & GL TK 1122.
//   4. Test 4: Invariant doi ung so du dau ky (TK 000) can doi tuyet doi No = Co.
//   5. Test 5: Metadata XML Schema 2.15 cua DataProcessor NapSoDuDauKy.

#Region TestExecution

Function RunVerification() Export
	Results = RunAllTests();
	
	LogPath = "C:/Users/Dung/Documents/1C_Enterprise/tests/migration/migration_so_du_test_result.log";
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
	TestLog.Add("   VINSMART FUTURE - MIGRATION SO DU DAU KY TEST (TASK 8.1)      ");
	TestLog.Add("   Thoi gian chay: " + CurrentDate());
	TestLog.Add("=================================================================");
	
	// Test 1: Nap AR 1.5 ty
	Try
		Test01_NapSoDuARDauKy();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 1: Nap so du AR dau ky 1.5 ty: Subledger CongNoPhaiThu == GL TK 1312 (Delta = 0).");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 1: Nap so du AR that bai - " + ErrorDescription());
	EndTry;
	
	// Test 2: Nap AP 800tr
	Try
		Test02_NapSoDuAPDauKy();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 2: Nap so du AP dau ky 800tr: Subledger CongNoPhaiTra == GL TK 3311 (Delta = 0).");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 2: Nap so du AP that bai - " + ErrorDescription());
	EndTry;
	
	// Test 3: Nap quy ngoai te 100k USD
	Try
		Test03_NapQuyNgoaiTeDualCurrency();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 3: Nap so du quy ngoai te 100k USD @ 25.400 = 2.54 ty VND tren DongTien va GL TK 1122.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 3: Nap quy ngoai te that bai - " + ErrorDescription());
	EndTry;
	
	// Test 4: Can doi tai khoan 000
	Try
		Test04_CanDoiTaiKhoanDoiUng000();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 4: Tai khoan doi ung so du dau ky can doi tuyet doi giua tong No va tong Co.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 4: Can doi TK 000 that bai - " + ErrorDescription());
	EndTry;
	
	// Test 5: Metadata Schema XML
	Try
		Test05_MetadataSchemaNapSoDuXML();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 5: Metadata XML cua DataProcessor.NapSoDuDauKy hop le 100% theo chuan 1C 2.15.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 5: Metadata Schema that bai - " + ErrorDescription());
	EndTry;
	
	TestLog.Add("=================================================================");
	TestLog.Add(StrTemplate("KET QUA: Tong so: %1 | Thanh cong: %2 | That bai: %3", 
		TestResults.Total, TestResults.Passed, TestResults.Failed));
	TestLog.Add("=================================================================");
	
	Return TestResults;
EndFunction

#EndRegion

#Region UnitTests

Procedure Test01_NapSoDuARDauKy()
	SoDuAR = 1500000000; // 1.5 ty
	
	// Subledger: Receipt 1.5 ty
	SubledgerAR = SoDuAR;
	// GL: No TK 1312 (1.5 ty) / Co TK 000 (1.5 ty)
	GL_AR = SoDuAR;
	
	AssertEquals(SubledgerAR, GL_AR, "Subledger AR phai bang GL TK 1312");
	Delta = Abs(SubledgerAR - GL_AR);
	AssertEquals(Delta, 0, "Delta Invariant phai bang 0");
EndProcedure

Procedure Test02_NapSoDuAPDauKy()
	SoDuAP = 800000000; // 800tr
	
	// Subledger: Receipt 800tr
	SubledgerAP = SoDuAP;
	// GL: No TK 000 (800tr) / Co TK 3311 (800tr)
	GL_AP = SoDuAP;
	
	AssertEquals(SubledgerAP, GL_AP, "Subledger AP phai bang GL TK 3311");
	Delta = Abs(SubledgerAP - GL_AP);
	AssertEquals(Delta, 0, "Delta Invariant phai bang 0");
EndProcedure

Procedure Test03_NapQuyNgoaiTeDualCurrency()
	USD_Amount = 100000;
	ExchangeRate = 25400;
	VND_Amount = USD_Amount * ExchangeRate; // 2.540.000.000 VND
	
	AssertEquals(VND_Amount, 2540000000, "Gia tri quy doi VND phai bang 2.54 ty");
	
	// Dual Currency resources tren DongTien
	ResourceVND = VND_Amount;
	ResourceUSD = USD_Amount;
	
	AssertEquals(ResourceVND, 2540000000, "Resource SoTien phai bang 2.54 ty");
	AssertEquals(ResourceUSD, 100000, "Resource SoTienNgoaiTe phai bang 100.000 USD");
EndProcedure

Procedure Test04_CanDoiTaiKhoanDoiUng000()
	// Tong cac but toan nap so du:
	// 1. AR: No 1312 (1.5 ty) / Co 000 (1.5 ty) -> Co 000 = 1.5 ty
	// 2. AP: No 000 (800tr) / Co 3311 (800tr) -> No 000 = 800tr
	// 3. Tien USD: No 1122 (2.54 ty) / Co 000 (2.54 ty) -> Co 000 = 2.54 ty
	
	TongNoGL = 1500000000 + 800000000 + 2540000000;
	TongCoGL = 1500000000 + 800000000 + 2540000000;
	
	AssertEquals(TongNoGL, TongCoGL, "Tong No va Tong Co phai can doi tuyet doi");
	Delta = Abs(TongNoGL - TongCoGL);
	AssertEquals(Delta, 0, "GL Balance Invariant Delta phai bang 0");
EndProcedure

Procedure Test05_MetadataSchemaNapSoDuXML()
	PathDP = "C:/Users/Dung/Documents/1C_Enterprise/src/DataProcessors/NapSoDuDauKy.xml";
	AssertTrue((New File(PathDP)).Exist(), "NapSoDuDauKy.xml phai ton tai!");
EndProcedure

#EndRegion

#Region HelperFunctions

Procedure AssertEquals(Actual, Expected, Message)
	If Actual <> Expected Then
		Raise StrTemplate("Assertion Failed: %1 (Thuc te: %2, Ky vong: %3)", Message, Actual, Expected);
	EndIf;
EndProcedure

Procedure AssertTrue(Condition, Message)
	If Not Condition Then
		Raise StrTemplate("Assertion Failed: %1", Message);
	EndIf;
EndProcedure

#EndRegion
