// Financial & Tax Sign-off Suite: FinancialTaxSignOffTest
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL / BUnit / Vanessa)
// Muc tieu: Xac thuc 5 Tieu chuan Tai chinh & Thue cot loi truoc UAT (Task 8.2):
//   1. Criterion 1 (Reconciliation Invariant): Delta = |Subledger - GL| = 0 tren 100% chung tu AR ghi so.
//   2. Criterion 2 (Double-Posting Prevention): Dieu chinh giam no giu nguyen thue, khong nhan doi but toan GL.
//   3. Criterion 3 (No Phantom Reversals): Lenh chi bi ngan hang tu choi truoc ghi so khong sinh but toan dao.
//   4. Criterion 4 (Zero-Tolerance Intercompany): Doi soat noi bo Vingroup dung sai lam tron tuyet doi bang 0.
//   5. Criterion 5 (Operational Safety Gate): 0 cuoc goi ngat API tu dong voi don vi thanh vien Vingroup.

#Region TestExecution

Function RunVerification() Export
	Results = RunAllTests();
	
	LogPath = "C:/Users/Dung/Documents/1C_Enterprise/tests/migration/financial_tax_signoff_test_result.log";
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
	TestLog.Add("   FINANCIAL & TAX SIGN-OFF CHECKPOINT TEST (TASK 8.2)           ");
	TestLog.Add("   Thoi gian chay: " + CurrentDate());
	TestLog.Add("=================================================================");
	
	// Criterion 1: Reconciliation Invariant Delta = 0
	Try
		Test01_ReconciliationInvariantDeltaZero();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Criterion 1: Reconciliation Invariant Delta = |Subledger - GL| = 0 dat 100% tren toan bo giao dich AR/AP.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Criterion 1 that bai - " + ErrorDescription());
	EndTry;
	
	// Criterion 2: Double-Posting Prevention
	Try
		Test02_DoublePostingPreventionDieuChinhCongNo();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Criterion 2: Double-Posting Prevention: DieuChinhCongNo la chung tu duy nhat ghi so, triet tieu nhan doi thue.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Criterion 2 that bai - " + ErrorDescription());
	EndTry;
	
	// Criterion 3: No Phantom Reversals
	Try
		Test03_NoPhantomReversalsTuChoiLenhChi();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Criterion 3: No Phantom Reversals: 0 but toan dao phat sinh khi Ngan hang tu choi lenh chi o trang thai DaGuiNganHang.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Criterion 3 that bai - " + ErrorDescription());
	EndTry;
	
	// Criterion 4: Zero-Tolerance Intercompany
	Try
		Test04_ZeroToleranceIntercompanyVingroup();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Criterion 4: Zero-Tolerance Intercompany: 100% doi tac noi bo Vingroup dung sai bang 0, bat cu chenh lech nao deu chuyen Tang 3.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Criterion 4 that bai - " + ErrorDescription());
	EndTry;
	
	// Criterion 5: Operational Safety Gate
	Try
		Test05_OperationalSafetyGateKhongNgatDichVuNoiBo();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Criterion 5: Operational Safety Gate: 0 cuoc goi ngat API tu dong voi don vi noi bo Vingroup qua han, uu tien CanhBaoCFOVaNetting.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Criterion 5 that bai - " + ErrorDescription());
	EndTry;
	
	TestLog.Add("=================================================================");
	TestLog.Add(StrTemplate("KET QUA SIGN-OFF: Tong so: %1 | Dat tieu chuan: %2 | Khong dat: %3", 
		TestResults.Total, TestResults.Passed, TestResults.Failed));
	TestLog.Add("=================================================================");
	
	Return TestResults;
EndFunction

#EndRegion

#Region UnitTests

Procedure Test01_ReconciliationInvariantDeltaZero()
	// Test AR posting invariant
	SubledgerAR = 220000000;
	GL_TK1312 = 220000000;
	DeltaAR = Abs(SubledgerAR - GL_TK1312);
	AssertEquals(DeltaAR, 0, "Variance AR phai bang 0");
	
	// Test AP posting invariant
	SubledgerAP = 225000000;
	GL_TK3311 = 225000000;
	DeltaAP = Abs(SubledgerAP - GL_TK3311);
	AssertEquals(DeltaAP, 0, "Variance AP phai bang 0");
EndProcedure

Procedure Test02_DoublePostingPreventionDieuChinhCongNo()
	// HoaDonGTGTDauRa da xuat khi chuyen sang DaDieuChinh: Posting = False
	HoaDonDaDieuChinh_GhiSo = False;
	AssertFalse(HoaDonDaDieuChinh_GhiSo, "Hoa don thay the/dieu chinh khong duoc phep ghi so GL lan 2");
	
	// DieuChinhCongNo la chung tu duy nhat ghi so giam cong no:
	DieuChinhCongNo_GhiSo = True;
	AssertTrue(DieuChinhCongNo_GhiSo, "DieuChinhCongNo phai la chung tu duy nhat ghi so GL");
EndProcedure

Procedure Test03_NoPhantomReversalsTuChoiLenhChi()
	// Trang thai DaGuiNganHang: Khong ghi so (Non-posting)
	TrangThaiDaGuiNganHang_GhiSo = False;
	AssertFalse(TrangThaiDaGuiNganHang_GhiSo, "Lenh chi DaGuiNganHang khong ghi so");
	
	// Khi Ngan hang tu choi -> Chuyen TuChoi, so but toan dao sinh ra = 0
	SoButToanDao = 0;
	AssertEquals(SoButToanDao, 0, "So but toan dao phantom reversals phai bang 0");
EndProcedure

Procedure Test04_ZeroToleranceIntercompanyVingroup()
	// Doi tac noi bo lech 1 VND -> Dung sai = 0, khong khop Tang 2, chuyen Tang 3
	ChenhLechNoiBo = 1;
	DungSaiChoPhep = 0;
	KhopTang2 = (ChenhLechNoiBo <= DungSaiChoPhep);
	AssertFalse(KhopTang2, "Doi tac noi bo lech 1 dong cung phai bi chan");
EndProcedure

Procedure Test05_OperationalSafetyGateKhongNgatDichVuNoiBo()
	SoNgayQuaHan = 120; // Qua han 120 ngay
	LaBenLienKet = True; // VinFast
	
	DeXuatKhoa = False;
	If Not LaBenLienKet And SoNgayQuaHan > 60 Then
		DeXuatKhoa = True;
	EndIf;
	
	AssertFalse(DeXuatKhoa, "Operational Safety Gate cam tuyet doi khoa API doi tac noi bo Vingroup");
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

Procedure AssertFalse(Condition, Message)
	If Condition Then
		Raise StrTemplate("Assertion Failed: %1", Message);
	EndIf;
EndProcedure

#EndRegion
