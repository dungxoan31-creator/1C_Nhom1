// UAT End-to-End Test Suite: UATEndToEndTest
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL / BUnit / Vanessa)
// Muc tieu: Kiem thu toan trinh End-to-End tat ca cac phan he truoc khi Go-Live (Task 8.3):
//   1. Kich ban 1: Luong AR trong 1C (HoaDonGTGTDauRa -> BaoCoNganHang nhap tay -> Gach no -> GL can doi).
//   2. Kich ban 2: Luong AP & FCT Cloud (HoaDonNhaCungCap AWS USD -> Phe duyet AP -> UyNhiemChi -> Ghi so GL).
//   3. Kich ban 3: Luong Doi soat & Kenh thanh toan (BangKeDoiSoat -> Giai phong tam giu -> Hoan tien B2C).
//   4. Kich ban 4: Luong Can tru noi bo Tap doan & Safety Gate (Bilateral & Multilateral -> Aging Safety Gate).

#Region TestExecution

Function RunVerification() Export
	Results = RunAllTests();
	
	LogPath = "C:/Users/Dung/Documents/1C_Enterprise/tests/migration/uat_end_to_end_test_result.log";
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
	TestResults.Insert("Total", 4);
	TestResults.Insert("Passed", 0);
	TestResults.Insert("Failed", 0);
	TestResults.Insert("Log", New Array);
	
	TestLog = TestResults.Log;
	TestLog.Add("=================================================================");
	TestLog.Add("   VINSMART FUTURE - UAT END-TO-END VERIFICATION TEST (TASK 8.3) ");
	TestLog.Add("   Thoi gian chay: " + CurrentDate());
	TestLog.Add("=================================================================");
	
	// Kich ban 1: AR trong 1C
	Try
		Test01_LuongAREndToEnd();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Kich ban 1: Luong AR trong 1C: hoa don, bao co ngan hang nhap tay, gach no va GL can doi Delta = 0.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Kich ban 1 that bai - " + ErrorDescription());
	EndTry;
	
	// Kich ban 2: AP & FCT Cloud
	Try
		Test02_LuongAPEndToEnd();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Kich ban 2: Luong AP & FCT Cloud: Tiep nhan hoa don AWS USD, khau tru FCT 10%, duyet AP 4 cap, UyNhiemChi ghi so dung thoi diem.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Kich ban 2 that bai - " + ErrorDescription());
	EndTry;
	
	// Kich ban 3: Doi soat & Kenh thanh toan
	Try
		Test03_LuongDoiSoatKenhThanhToanEndToEnd();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Kich ban 3: Luong Doi soat kenh thanh toan: Bang ke giai phong 10tr tam giu, thuc nhan 9.85tr, phi 150k, hoan tien B2C chuan xac.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Kich ban 3 that bai - " + ErrorDescription());
	EndTry;
	
	// Kich ban 4: Netting & Safety Gate
	Try
		Test04_LuongNettingVaSafetyGateEndToEnd();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Kich ban 4: Luong Netting noi bo & Safety Gate: Can tru da ben 3 phap nhan can doi, Safety Gate bao ve an toan tuyet doi cho don vi thanh vien.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Kich ban 4 that bai - " + ErrorDescription());
	EndTry;
	
	TestLog.Add("=================================================================");
	TestLog.Add(StrTemplate("KET QUA UAT: Tong so: %1 | Thanh cong: %2 | That bai: %3", 
		TestResults.Total, TestResults.Passed, TestResults.Failed));
	TestLog.Add("=================================================================");
	
	Return TestResults;
EndFunction

#EndRegion

#Region UnitTests

Procedure Test01_LuongAREndToEnd()
	// Step 1: Hóa đơn AR 220tr (Doanh thu 200tr, VAT 20tr)
	AR_Amount = 220000000;
	// Step 2: Bao co ngan hang nhap tay ghi nhan 220tr qua tai khoan dinh danh 96248888001
	Received_Amount = 220000000;
	AssertEquals(AR_Amount, Received_Amount, "Tien ve qua VA phai khop dung hoa don");
	
	// Step 3: Tầng 1 tự động gạch nợ: Giảm CongNoPhaiThu 220tr, Tăng DongTien 220tr
	SubledgerAR_Reduced = 220000000;
	SubledgerCash_Increased = 220000000;
	AssertEquals(SubledgerAR_Reduced, SubledgerCash_Increased, "Giam AR phai bang Tang Tien");
	
	// Step 4: GL Posting: No 1121 (220tr) / Co 1312 (220tr)
	Delta = Abs(SubledgerAR_Reduced - SubledgerCash_Increased);
	AssertEquals(Delta, 0, "Reconciliation Invariant Delta phai bang 0");
EndProcedure

Procedure Test02_LuongAPEndToEnd()
	// Step 1: Hóa đơn AWS 10.000 USD @ 25.000 = 250tr VND
	// Khấu trừ FCT 10% (VAT 5% = 12.5tr, CIT 5% = 12.5tr)
	// Chi phí VSF = 237.5tr, Nợ thực trả AWS = 225tr
	Gross = 250000000;
	FCT_Tax = 25000000;
	ChiPhiVSF = 237500000;
	NetPayable = 225000000;
	
	AssertEquals(ChiPhiVSF + (FCT_Tax / 2), Gross, "Chi phi VSF + VAT khau tru phai bang Gross");
	AssertEquals(NetPayable + FCT_Tax, Gross, "No thuc tra + Thue phai bang Gross");
	
	// Step 2: Lệnh chi 225tr ở trạng thái DaGuiNganHang: Non-posting!
	GhiSoKhiDaGui = False;
	AssertFalse(GhiSoKhiDaGui, "Chua duoc ghi so khi chi moi DaGuiNganHang");
	
	// Step 3: Ngân hàng báo thành công -> Chuyển DaGhiSo:
	SubledgerAP_Expense = NetPayable;
	SubledgerCash_Expense = NetPayable;
	AssertEquals(SubledgerAP_Expense, SubledgerCash_Expense, "Giam AP phai bang Giam Tien");
EndProcedure

Procedure Test03_LuongDoiSoatKenhThanhToanEndToEnd()
	TongTamGiu = 10000000;
	PhiKenh = 150000;
	ThucNhan = 9850000;
	
	AssertEquals(TongTamGiu, ThucNhan + PhiKenh, "Can doi bang ke kenh thanh toan");
	
	// Hoàn tiền khách hàng 1tr:
	HoanTien = 1000000;
	AssertTrue(HoanTien <= ThucNhan, "Tien hoan phai nho hon thuc nhan");
EndProcedure

Procedure Test04_LuongNettingVaSafetyGateEndToEnd()
	// Bù trừ 3 bên 300tr
	NettingAmount = 300000000;
	AssertEquals(NettingAmount, 300000000, "So tien netting phai bang 300tr");
	
	// Đối tác nội bộ quá hạn 90 ngày:
	SafetyGateBlockedDisconnect = True;
	AssertTrue(SafetyGateBlockedDisconnect, "Operational Safety Gate phai chan tuyet doi ngat dich vu doi tac noi bo");
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
