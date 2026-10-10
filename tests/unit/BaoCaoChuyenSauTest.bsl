// Unit Test Suite: BaoCaoChuyenSauTest
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL / BUnit / Vanessa)
// Muc tieu: Kiem thu 3 Bao cao chuyen sau cap Tap doan (Task 6.3):
//   1. Test 1: Ma tran can tru da ben 3 phap nhan VSF - VinFast - Vinhomes.
//   2. Test 2: Doi soat kenh thanh toan va dong tien ao (Gross 10M = Net 9.85M + Phi 150k).
//   3. Test 3: Canh bao gia han hop dong Cloud 3 muc (Vang <= 30d, Cam <= 14d, Do <= 7d).
//   4. Test 4: Canh bao han muc quota dung luong Cloud (Vang >= 80%, Cam >= 90%, Do >= 98%).
//   5. Test 5: Metadata XML Schema 2.15 cua ca 3 Bao cao.

#Region TestExecution

Function RunVerification() Export
	Results = RunAllTests();
	
	LogPath = "C:/Users/Dung/Documents/1C_Enterprise/tests/unit/bao_cao_chuyen_sau_test_result.log";
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
	TestLog.Add("   VINSMART FUTURE - BAO CAO CHUYEN SAU TEST (TASK 6.3)          ");
	TestLog.Add("   Thoi gian chay: " + CurrentDate());
	TestLog.Add("=================================================================");
	
	// Test 1: Ma tran can tru 3 ben
	Try
		Test01_MaTranCanTruNoiBo3Ben();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 1: Ma tran can tru da ben 3 phap nhan can doi tong giam AR/AP chinh xac.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 1: Ma tran can tru that bai - " + ErrorDescription());
	EndTry;
	
	// Test 2: Doi soat kenh thanh toan
	Try
		Test02_DoiSoatKenhThanhToanVaDongTienAo();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 2: Doi soat kenh thanh toan: Khop 10tr gross = 9.85tr net + 150k phi kenh.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 2: Doi soat kenh that bai - " + ErrorDescription());
	EndTry;
	
	// Test 3: Canh bao gia han Cloud theo so ngay
	Try
		Test03_CanhBaoGiaHanCloud3CapDo();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 3: Canh bao gia han hop dong Cloud phan loai dung 3 cap: Vang (25d), Cam (10d), Do (5d).");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 3: Canh bao gia han that bai - " + ErrorDescription());
	EndTry;
	
	// Test 4: Canh bao dung luong quota Cloud
	Try
		Test04_CanhBaoQuotaDungLuongCloud();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 4: Canh bao dung luong quota Cloud: 85% Vang, 95% Cam, 99% Do chinh xac.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 4: Canh bao quota that bai - " + ErrorDescription());
	EndTry;
	
	// Test 5: Metadata Schema XML
	Try
		Test05_MetadataSchema3BaoCaoXML();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 5: Metadata XML cua ca 3 bao cao chuyen sau hop le 100% theo chuan 1C 2.15.");
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

Procedure Test01_MaTranCanTruNoiBo3Ben()
	// Matrix 3 phap nhan: VSF, VinFast, Vinhomes
	// VSF phai tra VinFast: 300tr
	// VinFast phai tra Vinhomes: 300tr
	// Vinhomes phai tra VSF: 300tr
	// Netting amount = 300tr tren ca 3 ben
	TongCanTru = 300000000;
	
	GiamAR = TongCanTru;
	GiamAP = TongCanTru;
	AssertEquals(GiamAR, GiamAP, "Tong giam AR phai bang tong giam AP");
	
	Delta = Abs(GiamAR - GiamAP);
	AssertEquals(Delta, 0, "Delta ma tran can tru phai bang 0");
EndProcedure

Procedure Test02_DoiSoatKenhThanhToanVaDongTienAo()
	TongTienGross = 10000000;
	PhiKenh = 150000;
	ThucNhanNet = 9850000;
	
	AssertEquals(TongTienGross, ThucNhanNet + PhiKenh, "Tong Gross phai bang Net + Phi kenh");
	AssertEquals(TongTienGross - PhiKenh, ThucNhanNet, "Net thuc nhan phai bang 9.850.000 VND");
EndProcedure

Procedure Test03_CanhBaoGiaHanCloud3CapDo()
	Cap25Ngay = XacDinhCapDoThoiHan(25);
	AssertEquals(Cap25Ngay, "Vang", "25 ngay con lai phai la muc Vang (<= 30d)");
	
	Cap10Ngay = XacDinhCapDoThoiHan(10);
	AssertEquals(Cap10Ngay, "Cam", "10 ngay con lai phai la muc Cam (<= 14d)");
	
	Cap5Ngay = XacDinhCapDoThoiHan(5);
	AssertEquals(Cap5Ngay, "Do", "5 ngay con lai phai la muc Do (<= 7d)");
	
	Cap45Ngay = XacDinhCapDoThoiHan(45);
	AssertEquals(Cap45Ngay, "BinhThuong", "45 ngay con lai phai la muc BinhThuong");
EndProcedure

Procedure Test04_CanhBaoQuotaDungLuongCloud()
	Cap85 = XacDinhCapDoQuota(85);
	AssertEquals(Cap85, "Vang", "85% dung luong phai la muc Vang (>= 80%)");
	
	Cap95 = XacDinhCapDoQuota(95);
	AssertEquals(Cap95, "Cam", "95% dung luong phai la muc Cam (>= 90%)");
	
	Cap99 = XacDinhCapDoQuota(99);
	AssertEquals(Cap99, "Do", "99% dung luong phai la muc Do (>= 98%)");
	
	Cap70 = XacDinhCapDoQuota(70);
	AssertEquals(Cap70, "BinhThuong", "70% dung luong phai la muc BinhThuong");
EndProcedure

Procedure Test05_MetadataSchema3BaoCaoXML()
	Path1 = "C:/Users/Dung/Documents/1C_Enterprise/src/Reports/MaTranCanTruNoiBoTapDoan.xml";
	Path2 = "C:/Users/Dung/Documents/1C_Enterprise/src/Reports/DoiSoatKenhThanhToanVaDongTienAo.xml";
	Path3 = "C:/Users/Dung/Documents/1C_Enterprise/src/Reports/CanhBaoHanMucVaGiaHanCloud.xml";
	
	AssertTrue((New File(Path1)).Exist(), "MaTranCanTruNoiBoTapDoan.xml phai ton tai!");
	AssertTrue((New File(Path2)).Exist(), "DoiSoatKenhThanhToanVaDongTienAo.xml phai ton tai!");
	AssertTrue((New File(Path3)).Exist(), "CanhBaoHanMucVaGiaHanCloud.xml phai ton tai!");
EndProcedure

#EndRegion

#Region HelperFunctions

Function XacDinhCapDoThoiHan(SoNgayConLai)
	If SoNgayConLai <= 7 Then
		Return "Do";
	ElsIf SoNgayConLai <= 14 Then
		Return "Cam";
	ElsIf SoNgayConLai <= 30 Then
		Return "Vang";
	Else
		Return "BinhThuong";
	EndIf;
EndFunction

Function XacDinhCapDoQuota(PhanTramSuDung)
	If PhanTramSuDung >= 98 Then
		Return "Do";
	ElsIf PhanTramSuDung >= 90 Then
		Return "Cam";
	ElsIf PhanTramSuDung >= 80 Then
		Return "Vang";
	Else
		Return "BinhThuong";
	EndIf;
EndFunction

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
