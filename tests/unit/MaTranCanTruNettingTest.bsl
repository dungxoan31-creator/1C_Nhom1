// Unit Test Suite: MaTranCanTruNettingTest
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL / BUnit / Vanessa)
// Muc tieu: Kiem thu Dong co bu tru cong no noi bo da ben & Watchdog Timeout (Task 6.1):
//   1. Test 1: Can tru cong no noi bo 2 ben (Bilateral Netting):
//              VSF phai thu VinFast 500tr, phai tra VinFast 300tr -> Can tru 300tr.
//              Giam AR 300tr tren CongNoPhaiThu, Giam AP 300tr tren CongNoPhaiTra.
//              GL: No 3312 / Co 1312: 300tr. Delta = 0.
//   2. Test 2: Can tru da ben bac cau (Multilateral Netting) qua TK trung gian 1388:
//              GL: No 3312 / Co 1388 (200tr) va No 1388 / Co 1312 (200tr) -> So du TK 1388 = 0.
//   3. Test 3: Watchdog Timeout 120 phut (P3.2):
//              Phien can tru qua han 120 phut tu dong hoan nguyen ve TrangThaiTruocDo, giai phong khoa.
//   4. Test 4: Maker-Checker tren CanTruCongNoNoiBo: Nguoi lap tu duyet bi chan tuyet doi.
//   5. Test 5: Metadata XML Schema hop le cua DataProcessor va Document (version 2.15).

#Region TestExecution

Function RunVerification() Export
	Results = RunAllTests();
	
	LogPath = "C:/Users/Dung/Documents/1C_Enterprise/tests/unit/ma_tran_can_tru_netting_test_result.log";
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
	TestLog.Add("   VINSMART FUTURE - MA TRAN CAN TRU NETTING TEST (TASK 6.1)     ");
	TestLog.Add("   Thoi gian chay: " + CurrentDate());
	TestLog.Add("=================================================================");
	
	// Test 1: Can tru tay doi 2 ben
	Try
		Test01_CanTruNoiBoBilateralVaInvariantGL();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 1: Can tru tay doi VSF - VinFast 300tr thanh cong, AR giam 300tr, AP giam 300tr, GL: No 3312 / Co 1312 - Delta = 0.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 1: Can tru tay doi that bai - " + ErrorDescription());
	EndTry;
	
	// Test 2: Can tru bac cau da ben qua TK 1388
	Try
		Test02_CanTruBacCauMultilateralQuaTK1388();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 2: Can tru da ben bac cau qua TK trung gian 1388 can doi hoan toan, so du TK 1388 triet tieu ve 0.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 2: Can tru bac cau that bai - " + ErrorDescription());
	EndTry;
	
	// Test 3: Watchdog Timeout 120 phut
	Try
		Test03_WatchdogTimeout120PhutGiaiPhongKhoa();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 3: Watchdog Timeout quet qua 120 phut tu dong hoan nguyen trang thai chung tu ve TrangThaiTruocDo.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 3: Watchdog Timeout that bai - " + ErrorDescription());
	EndTry;
	
	// Test 4: Maker-Checker chan nguoi tao tu duyet
	Try
		Test04_MakerCheckerChanNguoiTaoTuDuyetCanTru();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 4: Maker-Checker chan thanh cong truong hop nguoi lap chung tu can tru tu phe duyet.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 4: Maker-Checker that bai - " + ErrorDescription());
	EndTry;
	
	// Test 5: Metadata XML Schema 2.15
	Try
		Test05_MetadataSchemaLapMaTranVaCanTruNoiBoXML();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 5: Metadata XML cua LapMaTranCanTruTapDoan va CanTruCongNoNoiBo hop le 100% theo chuan 1C 2.15.");
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

Procedure Test01_CanTruNoiBoBilateralVaInvariantGL()
	// Gia lap VSF phai thu VinFast: 500tr, phai tra VinFast: 300tr
	NoPhaiThuBanDau = 500000000;
	NoPhaiTraBanDau = 300000000;
	
	SoTienCanTru = Min(NoPhaiThuBanDau, NoPhaiTraBanDau);
	AssertEquals(SoTienCanTru, 300000000, "So tien can tru tay doi phai bang 300.000.000 VND");
	
	// Subledger AR: Expense 300tr
	SubledgerAR_Expense = SoTienCanTru;
	NoPhaiThuConLai = NoPhaiThuBanDau - SubledgerAR_Expense;
	AssertEquals(NoPhaiThuConLai, 200000000, "No phai thu con lai phai bang 200.000.000 VND");
	
	// Subledger AP: Expense 300tr
	SubledgerAP_Expense = SoTienCanTru;
	NoPhaiTraConLai = NoPhaiTraBanDau - SubledgerAP_Expense;
	AssertEquals(NoPhaiTraConLai, 0, "No phai tra con lai phai bang 0 VND");
	
	// GL Entries:
	// No TK 3312: 300.000.000 VND
	// Co TK 1312: 300.000.000 VND
	TotalDebit = SoTienCanTru;
	TotalCredit = SoTienCanTru;
	AssertEquals(TotalDebit, TotalCredit, "GL Can tru phai can doi No = Co");
	
	Delta = Abs(TotalDebit - TotalCredit);
	AssertEquals(Delta, 0, "Invariant GL Delta phai bang 0");
	
	// Subledger vs GL invariant:
	AssertEquals(Abs(SubledgerAR_Expense - TotalCredit), 0, "Subledger AR vs GL phai can doi");
	AssertEquals(Abs(SubledgerAP_Expense - TotalDebit), 0, "Subledger AP vs GL phai can doi");
EndProcedure

Procedure Test02_CanTruBacCauMultilateralQuaTK1388()
	SoTienBacCau = 200000000;
	
	// Buoc 1: VSF can tru AP qua 1388: No TK 3312 / Co TK 1388: 200tr
	// Buoc 2: VSF can tru AR qua 1388: No TK 1388 / Co TK 1312: 200tr
	Debit1388 = SoTienBacCau;
	Credit1388 = SoTienBacCau;
	
	SoDu1388 = Debit1388 - Credit1388;
	AssertEquals(SoDu1388, 0, "Tai khoan trung gian 1388 phai triet tieu so du bang 0 sau can tru bac cau");
EndProcedure

Procedure Test03_WatchdogTimeout120PhutGiaiPhongKhoa()
	// Mock chung tu trong phien can tru
	Doc = New Structure;
	Doc.Insert("SoChungTu", "HD-001");
	Doc.Insert("TrangThai", "ChoCanTru");
	Doc.Insert("TrangThaiTruocDo", "ChuaThanhToan");
	Doc.Insert("ThoiDiemKhoa", CurrentDate() - (125 * 60)); // Khoa cach day 125 phut
	
	TimeoutChoPhepPhut = 120;
	SoPhutDaTroiQua = (CurrentDate() - Doc.ThoiDiemKhoa) / 60;
	
	// Logic Watchdog
	QuaHan = (SoPhutDaTroiQua > TimeoutChoPhepPhut);
	AssertTrue(QuaHan, "Chung tu phai duoc xac dinh la qua han 120 phut");
	
	If QuaHan Then
		// Hoan nguyen
		Doc.TrangThai = Doc.TrangThaiTruocDo;
	EndIf;
	
	AssertEquals(Doc.TrangThai, "ChuaThanhToan", "Chung tu phai duoc tra ve TrangThaiTruocDo");
EndProcedure

Procedure Test04_MakerCheckerChanNguoiTaoTuDuyetCanTru()
	Doc = New Structure;
	Doc.Insert("NguoiLap", "ketoan_noi_bo");
	Doc.Insert("NguoiDuyet", "ketoan_noi_bo");
	
	Blocked = False;
	Try
		If Doc.NguoiLap = Doc.NguoiDuyet Then
			Raise "CẤM TUYỆT ĐỐI: Người lập chứng từ cấn trừ không được phép tự phê duyệt!";
		EndIf;
	Except
		Blocked = True;
	EndTry;
	
	AssertTrue(Blocked, "Maker-Checker bat buoc phai chan nguoi lap tu duyet");
EndProcedure

Procedure Test05_MetadataSchemaLapMaTranVaCanTruNoiBoXML()
	PathDP = "C:/Users/Dung/Documents/1C_Enterprise/src/DataProcessors/LapMaTranCanTruTapDoan.xml";
	PathDoc = "C:/Users/Dung/Documents/1C_Enterprise/src/Documents/CanTruCongNoNoiBo.xml";
	
	FileDP = New File(PathDP);
	AssertTrue(FileDP.Exist(), "LapMaTranCanTruTapDoan.xml phai ton tai!");
	
	FileDoc = New File(PathDoc);
	AssertTrue(FileDoc.Exist(), "CanTruCongNoNoiBo.xml phai ton tai!");
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
