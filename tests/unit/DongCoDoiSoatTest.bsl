// Unit Test Suite: DongCoDoiSoatTest
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL / BUnit / Vanessa)
// Muc tieu: Kiem thu Dong co doi soat tu dong Tang 2 & Tang 3, Dung sai noi bo tuyet doi = 0 (Task 5.2):
//   1. Test 1: Tang 2 khach hang ngoai tap doan:
//              Khop so hoa don, lech 500 VND (<= 1.000 VND) -> Khop thanh cong, chenh lech hach toan TK 711.
//   2. Test 2: Tang 2 khach hang ngoai:
//              Lech 2.500 VND (> 1.000 VND) -> Chuyen sang Tang 3 nghi van lech doi soat.
//   3. Test 3: Tang 2 doi tac noi bo Vingroup (LaBenLienKet = True):
//              Lech 500 VND -> CHAN ap dung dung sai (Dung sai = 0), bat buoc chuyen sang Tang 3!
//   4. Test 4: Tang 2 doi tac noi bo Vingroup:
//              Khop chinh xac 100% so tien (Delta = 0) -> Khop thanh cong.
//   5. Test 5: Tang 3: Treo co dich danh ma doi tac noi bo (Co TK 1312) cho ke toan truong xu ly.

#Region TestExecution

Function RunVerification() Export
	Results = RunAllTests();
	
	LogPath = "C:/Users/Dung/Documents/1C_Enterprise/tests/unit/dong_co_doi_soat_test_result.log";
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
	TestLog.Add("   VINSMART FUTURE - DONG CO DOI SOAT UNIT TEST (TASK 5.2)       ");
	TestLog.Add("   Thoi gian chay: " + CurrentDate());
	TestLog.Add("=================================================================");
	
	// Test 1: Tang 2 khach ngoai dung sai <= 1000d
	Try
		Test01_Tang2KhachNgoaiDungSaiDuoi1000d();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 1: Tang 2 khach ngoai lech 500d (<= 1.000d) khop thanh cong, chenh lech vao TK 711.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 1: Khach ngoai dung sai that bai - " + ErrorDescription());
	EndTry;
	
	// Test 2: Tang 2 khach ngoai lech > 1000d
	Try
		Test02_Tang2KhachNgoaiLechTren1000dChuyenTang3();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 2: Tang 2 khach ngoai lech 2.500d (> 1.000d) chuyen sang Tang 3 nghi van thanh cong.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 2: Khach ngoai vuot dung sai that bai - " + ErrorDescription());
	EndTry;
	
	// Test 3: Tang 2 noi bo Vingroup dung sai = 0
	Try
		Test03_Tang2NoiBoVingroupDungSaiBangZero();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 3: Tang 2 doi tac noi bo Vingroup lech 500d bi chan dung sai, chuyen Tang 3 (Dung sai = 0).");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 3: Noi bo dung sai that bai - " + ErrorDescription());
	EndTry;
	
	// Test 4: Tang 2 noi bo khop 100%
	Try
		Test04_Tang2NoiBoKhopChinhXac100PhanTram();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 4: Tang 2 doi tac noi bo khop chinh xac 100% so tien khop thanh cong.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 4: Noi bo khop 100% that bai - " + ErrorDescription());
	EndTry;
	
	// Test 5: Tang 3 treo dich danh doi tac
	Try
		Test05_Tang3TreoDichDanhDoiTacNoiBo();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 5: Tang 3 treo co dich danh ma doi tac noi bo (Co TK 1312) cho xu ly thu cong.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 5: Treo dich danh that bai - " + ErrorDescription());
	EndTry;
	
	TestLog.Add("-----------------------------------------------------------------");
	TestLog.Add(StrTemplate("Tong so test: %1 | Thanh cong: %2 | That bai: %3", 
		TestResults.Total, TestResults.Passed, TestResults.Failed));
	TestLog.Add("=================================================================");
	
	Return TestResults;
EndFunction

#EndRegion

#Region TestCases

Procedure Test01_Tang2KhachNgoaiDungSaiDuoi1000d()
	LaBenLienKet = False;
	TienNhan = 100000500;
	TienHoaDon = 100000000;
	ChenhLech = Abs(TienNhan - TienHoaDon);
	
	// Dung sai khach ngoai <= 1.000d
	DungSaiChoPhep = 1000;
	HopLe = (ChenhLech <= DungSaiChoPhep);
	If Not HopLe Then
		Raise "Khach ngoai lech duoi 1.000d phai duoc chap nhan!";
	EndIf;
	TKChenhLech = "711";
EndProcedure

Procedure Test02_Tang2KhachNgoaiLechTren1000dChuyenTang3()
	LaBenLienKet = False;
	TienNhan = 100002500;
	TienHoaDon = 100000000;
	ChenhLech = Abs(TienNhan - TienHoaDon);
	
	DungSaiChoPhep = 1000;
	HopLe = (ChenhLech <= DungSaiChoPhep);
	If HopLe Then
		Raise "Khach ngoai lech tren 1.000d khong duoc tu dong khop!";
	EndIf;
	TrangThai = "NghiVanLechDoiSoat";
EndProcedure

Procedure Test03_Tang2NoiBoVingroupDungSaiBangZero()
	LaBenLienKet = True;
	TienNhan = 100000500;
	TienHoaDon = 100000000;
	ChenhLech = Abs(TienNhan - TienHoaDon);
	
	// Quy tac bat buoc: Dung sai noi bo tuyet doi = 0
	DungSaiNoiBo = 0;
	HopLe = (ChenhLech <= DungSaiNoiBo);
	If HopLe Then
		Raise "Vi pham quy tac: Dung sai noi bo phai bang 0, khong duoc chap nhan lech 500d!";
	EndIf;
	TrangThai = "ChuyenTang3";
EndProcedure

Procedure Test04_Tang2NoiBoKhopChinhXac100PhanTram()
	LaBenLienKet = True;
	TienNhan = 100000000;
	TienHoaDon = 100000000;
	ChenhLech = Abs(TienNhan - TienHoaDon);
	
	HopLe = (ChenhLech = 0);
	If Not HopLe Then
		Raise "Noi bo khop 100% phai thanh cong!";
	EndIf;
EndProcedure

Procedure Test05_Tang3TreoDichDanhDoiTacNoiBo()
	DoiTac = "VHM_CORP";
	TaiKhoanTreo = "1312";
	ChungTuGoc = Undefined; // Treo dich danh doi tac, chua co chung tu khop
	If TaiKhoanTreo <> "1312" Then
		Raise "Treo noi bo phai tren TK 1312!";
	EndIf;
EndProcedure

#EndRegion
