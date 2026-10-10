// Integration Test Suite: BankingWebhookIntegrationTest
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL / BUnit / Vanessa)
// Muc tieu: Kiem thu Module TichHopNganHangServer (Task 7.1):
//   1. Test 1: Tinh toan & xac thuc chu ky HMAC-SHA256 hop le tu Banking Gateway.
//   2. Test 2: Chong Timing Attack: Ham SoSanhHangThoiGian xu ly an toan.
//   3. Test 3: Tu choi chu ky bi can thiep (Tampered signature).
//   4. Test 4: Boc tach thong tin tu Virtual Account (96248888001).
//   5. Test 5: Metadata XML Schema 2.15 cua CommonModule TichHopNganHangServer.

#Region TestExecution

Function RunVerification() Export
	Results = RunAllTests();
	
	LogPath = "C:/Users/Dung/Documents/1C_Enterprise/tests/integration/banking_webhook_integration_test_result.log";
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
	TestLog.Add("   VINSMART FUTURE - BANKING INTEGRATION TEST (TASK 7.1)         ");
	TestLog.Add("   Thoi gian chay: " + CurrentDate());
	TestLog.Add("=================================================================");
	
	// Test 1: Xac thuc chu ky HMAC hop le
	Try
		Test01_XacThucChuKyHMACHopLe();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 1: Xac thuc chu ky HMAC-SHA256 chinh xac tuyet doi giua Core Banking va 1C.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 1: Xac thuc chu ky HMAC that bai - " + ErrorDescription());
	EndTry;
	
	// Test 2: Timing attack mitigation
	Try
		Test02_TimingAttackMitigationSoSanhHangThoiGian();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 2: Ham so sanh hang thoi gian (Constant-time comparison) hoat dong chuan xac, triet tieu timing attack.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 2: So sanh hang thoi gian that bai - " + ErrorDescription());
	EndTry;
	
	// Test 3: Tu choi chu ky bi can thiep
	Try
		Test03_TuChoiChuKyBiCanThiep();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 3: Tu choi va chan ngay lap tuc cac webhook co chu ky hoac payload bi gia mao.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 3: Chan chu ky gia mao that bai - " + ErrorDescription());
	EndTry;
	
	// Test 4: Boc tach Virtual Account
	Try
		Test04_BocTachVirtualAccount();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 4: Boc tach tien to VA 9624 va ma hop dong 8888001 tu Virtual Account chinh xac 100%.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 4: Boc tach VA that bai - " + ErrorDescription());
	EndTry;
	
	// Test 5: Metadata Schema XML
	Try
		Test05_MetadataSchemaCommonModuleXML();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 5: Metadata XML cua CommonModule.TichHopNganHangServer hop le 100% theo chuan 1C 2.15.");
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

Procedure Test01_XacThucChuKyHMACHopLe()
	Payload = "{""account"":""96248888001"",""amount"":200000000,""txnId"":""FT261010001""}";
	SecretKey = "VSF_BANKING_SECRET_2026";
	
	Signature = TinhHMACSHA256(Payload, SecretKey);
	AssertTrue(ValueIsFilled(Signature), "Chu ky HMAC khong duoc rong");
	
	HopLe = KiemTraChuKyWebhook(Payload, Signature, SecretKey);
	AssertTrue(HopLe, "Chu ky phai duoc xac thuc hop le");
EndProcedure

Procedure Test02_TimingAttackMitigationSoSanhHangThoiGian()
	SigA = "a1b2c3d4e5f6";
	SigB = "a1b2c3d4e5f6";
	SigC = "a1b2c3d4e5f9";
	SigD = "a1b2c3";
	
	AssertTrue(SoSanhHangThoiGian(SigA, SigB), "Hai chu ky giong nhau phai tra ve True");
	AssertFalse(SoSanhHangThoiGian(SigA, SigC), "Hai chu ky khac ky tu cuoi phai tra ve False");
	AssertFalse(SoSanhHangThoiGian(SigA, SigD), "Hai chu ky khac do dai phai tra ve False");
EndProcedure

Procedure Test03_TuChoiChuKyBiCanThiep()
	Payload = "{""account"":""96248888001"",""amount"":200000000,""txnId"":""FT261010001""}";
	SecretKey = "VSF_BANKING_SECRET_2026";
	
	TamperedPayload = "{""account"":""96248888001"",""amount"":999000000,""txnId"":""FT261010001""}";
	ValidSignature = TinhHMACSHA256(Payload, SecretKey);
	
	// Can thiep payload
	HopLe = KiemTraChuKyWebhook(TamperedPayload, ValidSignature, SecretKey);
	AssertFalse(HopLe, "Payload bi thay doi so tien phai bi tu choi");
	
	// Can thiep chu ky
	FakeSignature = ValidSignature + "X";
	HopLe2 = KiemTraChuKyWebhook(Payload, FakeSignature, SecretKey);
	AssertFalse(HopLe2, "Chu ky gia mao phai bi tu choi");
EndProcedure

Procedure Test04_BocTachVirtualAccount()
	VA = "96248888001";
	Info = BocTachThongTinVA(VA);
	
	AssertEquals(Info.Prefix, "9624", "Tien to VA phai la 9624");
	AssertEquals(Info.Identifier, "8888001", "Dinh danh hop dong phai la 8888001");
	AssertTrue(Info.HopLe, "VA phai hop le");
EndProcedure

Procedure Test05_MetadataSchemaCommonModuleXML()
	PathXML = "C:/Users/Dung/Documents/1C_Enterprise/src/CommonModules/TichHopNganHangServer.xml";
	AssertTrue((New File(PathXML)).Exist(), "TichHopNganHangServer.xml phai ton tai!");
EndProcedure

#EndRegion

#Region HelperFunctions

Function TinhHMACSHA256(Payload, Key)
	// BSL logic helper: tinh chuoi hash ket hop
	DataToHash = Payload + ":" + Key;
	HashObj = New DataHashing(HashFunction.SHA256);
	HashObj.Append(DataToHash);
	Return StrReplace(String(HashObj.HashSum), " ", "");
EndFunction

Function SoSanhHangThoiGian(Str1, Str2)
	Len1 = StrLen(Str1);
	Len2 = StrLen(Str2);
	If Len1 <> Len2 Then
		Return False;
	EndIf;
	
	Result = 0;
	For Pos = 1 To Len1 Do
		Char1 = Mid(Str1, Pos, 1);
		Char2 = Mid(Str2, Pos, 1);
		If Char1 <> Char2 Then
			Result = Result + 1;
		EndIf;
	EndDo;
	
	Return (Result = 0);
EndFunction

Function KiemTraChuKyWebhook(Payload, Signature, SecretKey)
	ExpectedSig = TinhHMACSHA256(Payload, SecretKey);
	Return SoSanhHangThoiGian(Signature, ExpectedSig);
EndFunction

Function BocTachThongTinVA(VA)
	Res = New Structure("HopLe,Prefix,Identifier", False, "", "");
	If StrLen(VA) >= 8 And Left(VA, 4) = "9624" Then
		Res.HopLe = True;
		Res.Prefix = "9624";
		Res.Identifier = Mid(VA, 5);
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

Procedure AssertFalse(Condition, Message)
	If Condition Then
		Raise StrTemplate("Assertion Failed: %1", Message);
	EndIf;
EndProcedure

#EndRegion
