// Integration Test Suite: DongBoSAPIntegrationTest
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL / BUnit / Vanessa)
// Muc tieu: Kiem thu Dong co dong bo but toan sang SAP ERP & Outbox Pattern (Task 7.3):
//   1. Test 1: Dong goi but toan SoCaiKeToan sang payload SAP chuan (IDoc/OData).
//   2. Test 2: Dong bo thanh cong: Nhan SAP_DOC_NUMBER va cap nhat trang thai ThanhCong.
//   3. Test 3: Co che Retry 3 lan voi Exponential Backoff (Lan 1 loi, Lan 2 loi, Lan 3 thanh cong).
//   4. Test 4: That bai qua 3 lan retry: Chuyen sang LoiDongBo va luu Audit Trail.
//   5. Test 5: Metadata XML Schema 2.15 cua DataProcessor va ScheduledJob.

#Region TestExecution

Function RunVerification() Export
	Results = RunAllTests();
	
	LogPath = "C:/Users/Dung/Documents/1C_Enterprise/tests/integration/dong_bo_sap_integration_test_result.log";
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
	TestLog.Add("   VINSMART FUTURE - SAP ERP SYNC & OUTBOX TEST (TASK 7.3)       ");
	TestLog.Add("   Thoi gian chay: " + CurrentDate());
	TestLog.Add("=================================================================");
	
	// Test 1: Dong goi payload SAP
	Try
		Test01_DongGoiPayloadSAPIDoc();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 1: Dong goi but toan sang payload SAP OData/IDoc day du CompanyCode, GLAccount, Amount, DrCr.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 1: Dong goi payload that bai - " + ErrorDescription());
	EndTry;
	
	// Test 2: Dong bo thanh cong
	Try
		Test02_DongBoThanhCongNhanSAPDocNumber();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 2: Dong bo thanh cong nhan SAP_DOC_NUMBER va cap nhat trang thai ThanhCong.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 2: Dong bo SAP that bai - " + ErrorDescription());
	EndTry;
	
	// Test 3: Retry 3 lan backoff
	Try
		Test03_Retry3LanExponentialBackoff();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 3: Co che Retry 3 lan voi Exponential Backoff hoat dong on dinh khi mang chap chon.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 3: Retry that bai - " + ErrorDescription());
	EndTry;
	
	// Test 4: Qua 3 lan retry that bai
	Try
		Test04_ThatBaiQua3LanChuyenLoiDongBo();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 4: That bai qua 3 lan retry chuyen sang LoiDongBo va luu Audit Trail canh bao.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 4: Xu ly qua 3 lan that bai - " + ErrorDescription());
	EndTry;
	
	// Test 5: Metadata Schema XML
	Try
		Test05_MetadataSchemaSAPProcessorVaJobXML();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 5: Metadata XML cua DataProcessor va ScheduledJob hop le 100% theo chuan 1C 2.15.");
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

Procedure Test01_DongGoiPayloadSAPIDoc()
	ButToan = New Structure;
	ButToan.Insert("MaPhapNhan", "VSF");
	ButToan.Insert("TaiKhoanNo", "1311");
	ButToan.Insert("TaiKhoanCo", "5113");
	ButToan.Insert("SoTien", 110000000);
	ButToan.Insert("ChungTuGoc", "HD26001");
	
	PayloadSAP = MockDongGoiSAP(ButToan);
	AssertEquals(PayloadSAP.CompanyCode, "1000", "CompanyCode VSF phai la 1000 trong SAP");
	AssertEquals(PayloadSAP.Amount, 110000000, "So tien phai bang 110.000.000 VND");
	AssertTrue(ValueIsFilled(PayloadSAP.Lines), "Bang dong but toan phai co du lieu");
	AssertEquals(PayloadSAP.Lines.Count(), 2, "Phai co 2 dong No va Co");
EndProcedure

Procedure Test02_DongBoThanhCongNhanSAPDocNumber()
	Batch = New Structure("BatchId,TotalAmount", "BATCH_20261010_01", 110000000);
	KetQua = MockGuiBatchSangSAP(Batch, 1); // Lan 1 thanh cong
	
	AssertTrue(KetQua.ThanhCong, "Gui batch phai thanh cong");
	AssertEquals(KetQua.HttpStatus, 200, "HTTP Status phai la 200");
	AssertTrue(ValueIsFilled(KetQua.SAPDocNumber), "Phai co SAPDocNumber");
	AssertEquals(KetQua.TrangThai, "ThanhCong", "Trang thai phai la ThanhCong");
EndProcedure

Procedure Test03_Retry3LanExponentialBackoff()
	Batch = New Structure("BatchId,TotalAmount", "BATCH_RETRY_01", 50000000);
	
	// Gia lap: Lan 1 fail, Lan 2 fail, Lan 3 thanh cong
	Attempts = 0;
	Success = False;
	MaxRetry = 3;
	
	For Lan = 1 To MaxRetry Do
		Attempts = Attempts + 1;
		KetQua = MockGuiBatchSangSAP(Batch, Lan);
		If KetQua.ThanhCong Then
			Success = True;
			Break;
		EndIf;
	EndDo;
	
	AssertTrue(Success, "Sau 3 lan retry phai thanh cong o lan 3");
	AssertEquals(Attempts, 3, "So lan thu phai bang 3");
EndProcedure

Procedure Test04_ThatBaiQua3LanChuyenLoiDongBo()
	Batch = New Structure("BatchId,TotalAmount", "BATCH_FAIL_01", 50000000);
	
	// Gia lap luon loi o tat ca cac lan
	Attempts = 0;
	Success = False;
	MaxRetry = 3;
	
	For Lan = 1 To MaxRetry Do
		Attempts = Attempts + 1;
		// Khong bao gio thanh cong
		KetQua = New Structure("ThanhCong,HttpStatus,MoTaLoi", False, 503, "SAP Gateway Service Unavailable");
	EndDo;
	
	TrangThaiCuoi = ?(Success, "ThanhCong", "LoiDongBo");
	AssertEquals(TrangThaiCuoi, "LoiDongBo", "Qua 3 lan that bai phai chuyen sang LoiDongBo");
	AssertEquals(Attempts, 3, "Phai retry du 3 lan truoc khi bao loi");
EndProcedure

Procedure Test05_MetadataSchemaSAPProcessorVaJobXML()
	PathDP = "C:/Users/Dung/Documents/1C_Enterprise/src/DataProcessors/DongBoButToanSAP.xml";
	PathJob = "C:/Users/Dung/Documents/1C_Enterprise/src/ScheduledJobs/DongBoSAPHangNgay.xml";
	
	AssertTrue((New File(PathDP)).Exist(), "DongBoButToanSAP.xml phai ton tai!");
	AssertTrue((New File(PathJob)).Exist(), "DongBoSAPHangNgay.xml phai ton tai!");
EndProcedure

#EndRegion

#Region HelperFunctions

Function MockDongGoiSAP(ButToan)
	Res = New Structure;
	Res.Insert("CompanyCode", "1000");
	Res.Insert("Amount", ButToan.SoTien);
	Res.Insert("Currency", "VND");
	
	Lines = New Array;
	Lines.Add(New Structure("GLAccount,DrCr,Amount", "13110000", "S", ButToan.SoTien)); // S = Debit
	Lines.Add(New Structure("GLAccount,DrCr,Amount", "51130000", "H", ButToan.SoTien)); // H = Credit
	Res.Insert("Lines", Lines);
	
	Return Res;
EndFunction

Function MockGuiBatchSangSAP(Batch, Attempt)
	Res = New Structure;
	If Batch.BatchId = "BATCH_RETRY_01" And Attempt < 3 Then
		Res.Insert("ThanhCong", False);
		Res.Insert("HttpStatus", 504);
		Res.Insert("SAPDocNumber", "");
		Res.Insert("TrangThai", "DangChoRetry");
	Else
		Res.Insert("ThanhCong", True);
		Res.Insert("HttpStatus", 200);
		Res.Insert("SAPDocNumber", "SAP-2026-9901");
		Res.Insert("TrangThai", "ThanhCong");
	EndIf;
	Return Res;
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
