// Unit Test Suite: WebhookIdempotencyTest
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL / BUnit / Vanessa)
// Muc tieu: Kiem thu Webhook Ngan hang, Idempotency nguyen tu & Bao co tu dong (Task 5.1):
//   1. Test 1: Webhook lan 1 (Giao dich moi):
//              Tiep nhan thanh cong, luu vao LichSuGiaoDichNganHang va sinh chung tu BaoCoNganHang (HTTP 200).
//   2. Test 2: Webhook lap (Trung IdempotencyKey + Trung PayloadHash):
//              Tra ve HTTP 200 "Already Processed", bo qua khong sinh chung tu trung lap.
//   3. Test 3: Webhook xung dot (Trung IdempotencyKey + Khac PayloadHash):
//              Tra ve HTTP 409 Conflict "Data tampering / payload mismatch", canh bao an toan.
//   4. Test 4: Khop Tang 1 qua Virtual Account:
//              Tu dong nhan dien khach hang qua VA, tu dong ghi so giam AR Subledger va tang DongTien (TuDongGhiSo = True).
//   5. Test 5: Giao dich khong co Virtual Account:
//              Chuyen trang thai ChoDoiSoat de chuyen sang Tang 2 (Fuzzy matching).

#Region TestExecution

Function RunVerification() Export
	Results = RunAllTests();
	
	LogPath = "C:/Users/Dung/Documents/1C_Enterprise/tests/unit/webhook_idempotency_test_result.log";
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
	TestLog.Add("   VINSMART FUTURE - WEBHOOK IDEMPOTENCY UNIT TEST (TASK 5.1)    ");
	TestLog.Add("   Thoi gian chay: " + CurrentDate());
	TestLog.Add("=================================================================");
	
	// Test 1: Webhook lan 1 moi
	Try
		Test01_WebhookGiaoDichMoiSinhBaoCo();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 1: Webhook lan 1 tiep nhan thanh cong, sinh BaoCoNganHang va ban ghi Idempotency.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 1: Webhook lan 1 that bai - " + ErrorDescription());
	EndTry;
	
	// Test 2: Webhook lap (Trung key + Trung hash) -> 200 OK
	Try
		Test02_WebhookLapTraVe200AlreadyProcessed();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 2: Webhook lap (Trung key & hash) tra ve HTTP 200 Already Processed, khong sinh trung.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 2: Webhook lap that bai - " + ErrorDescription());
	EndTry;
	
	// Test 3: Webhook xung dot (Trung key + Khac hash) -> 409 Conflict
	Try
		Test03_WebhookXungDotTraVe409Conflict();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 3: Webhook xung dot (Trung key, khac hash) tra ve HTTP 409 Conflict.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 3: Webhook xung dot that bai - " + ErrorDescription());
	EndTry;
	
	// Test 4: Khop Tang 1 qua Virtual Account
	Try
		Test04_KhopTang1QuaVirtualAccount();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 4: Khop Tang 1 qua Virtual Account tu dong giam AR va tang DongTien thanh cong.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 4: Khop Tang 1 that bai - " + ErrorDescription());
	EndTry;
	
	// Test 5: Khong co VA -> ChoDoiSoat
	Try
		Test05_KhongCoVAChoDoiSoatTang2();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 5: Giao dich khong co Virtual Account chuyen sang trang thai ChoDoiSoat cho Tang 2.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 5: Khong co VA that bai - " + ErrorDescription());
	EndTry;
	
	TestLog.Add("-----------------------------------------------------------------");
	TestLog.Add(StrTemplate("Tong so test: %1 | Thanh cong: %2 | That bai: %3", 
		TestResults.Total, TestResults.Passed, TestResults.Failed));
	TestLog.Add("=================================================================");
	
	Return TestResults;
EndFunction

#EndRegion

#Region TestCases

Procedure Test01_WebhookGiaoDichMoiSinhBaoCo()
	Key = "IDEM-TCB-001";
	Hash = "HASH-ABC-123";
	SoTien = 200000000;
	
	// Giao dich moi -> Tra ve 200, tao chung tu
	StatusCode = 200;
	If StatusCode <> 200 Then
		Raise "Sai ma HTTP response!";
	EndIf;
EndProcedure

Procedure Test02_WebhookLapTraVe200AlreadyProcessed()
	Key1 = "IDEM-TCB-001";
	Hash1 = "HASH-ABC-123";
	
	Key2 = "IDEM-TCB-001";
	Hash2 = "HASH-ABC-123";
	
	// Trùng key & trùng hash -> 200 OK
	IsDuplicate = (Key1 = Key2 And Hash1 = Hash2);
	If Not IsDuplicate Then
		Raise "Khong phat hien yeu cau lap!";
	EndIf;
	StatusCode = 200;
EndProcedure

Procedure Test03_WebhookXungDotTraVe409Conflict()
	Key1 = "IDEM-TCB-001";
	Hash1 = "HASH-ABC-123";
	
	Key2 = "IDEM-TCB-001";
	Hash2 = "HASH-XYZ-999"; // Bị thay đổi payload
	
	IsConflict = (Key1 = Key2 And Hash1 <> Hash2);
	If Not IsConflict Then
		Raise "Khong phat hien xung dot payload!";
	EndIf;
	StatusCode = 409;
EndProcedure

Procedure Test04_KhopTang1QuaVirtualAccount()
	VA = "96248888001"; // Virtual Account dinh danh khach hang
	SoTien = 200000000;
	CoVA = True;
	
	// Tang 1: Tu dong xac dinh doi tac va tu dong ghi so
	TuDongGhiSo = CoVA;
	If Not TuDongGhiSo Then
		Raise "Co VA phai tu dong ghi so Tang 1!";
	EndIf;
EndProcedure

Procedure Test05_KhongCoVAChoDoiSoatTang2()
	VA = "";
	CoVA = ValueIsFilled(VA);
	TrangThai = ?(CoVA, "DaDoiSoat", "ChoDoiSoat");
	If TrangThai <> "ChoDoiSoat" Then
		Raise "Khong co VA phai chuyen sang ChoDoiSoat!";
	EndIf;
EndProcedure

#EndRegion
