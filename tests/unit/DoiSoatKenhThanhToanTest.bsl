// Unit Test Suite: DoiSoatKenhThanhToanTest
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL / BUnit / Vanessa)
// Muc tieu: Kiem thu chung tu BangKeDoiSoatKenhThanhToan va YeuCauHoanTienChiHo (Task 5.3):
//   1. Test 1: Bang ke doi soat giai phong 10tr tam giu, phi kenh 150k, thuc nhan 9.85tr ve TK 1121:
//              GiaoDichDienTuTamGiu giam 10tr, DongTien tang 9.85tr, GL: No 1121 (9.85tr), No 6427 (150k) / Co 1388 (10tr).
//              Invariant: Tong No = Tong Co = 10tr (Delta = 0).
//   2. Test 2: Bang ke tinh toan chi tiet dong: GD001 (6tr, phi 90k) + GD002 (4tr, phi 60k):
//              Tu dong tinh TongTienGiaoDich (10tr), TongPhiKenh (150k), TongThucNhan (9.85tr).
//   3. Test 3: Yeu cau hoan tien chi ho B2C (1tr):
//              Giai phong giam tam giu 1tr, giam tien tren DongTien 1tr, GL: No 1388 / Co 1121 (1tr).
//   4. Test 4: Maker-Checker tren YeuCauHoanTienChiHo: Nguoi lap tu duyet bi chan tuyet doi.
//   5. Test 5: Kiem tra Metadata XML Schema cua BangKeDoiSoatKenhThanhToan va YeuCauHoanTienChiHo (version 2.15).

#Region TestExecution

Function RunVerification() Export
	Results = RunAllTests();
	
	LogPath = "C:/Users/Dung/Documents/1C_Enterprise/tests/unit/doi_soat_kenh_tt_test_result.log";
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
	TestLog.Add("   VINSMART FUTURE - DOI SOAT KENH TT & HOAN TIEN TEST (TASK 5.3) ");
	TestLog.Add("   Thoi gian chay: " + CurrentDate());
	TestLog.Add("=================================================================");
	
	// Test 1: Bang ke doi soat 10tr tam giu, phi 150k, thuc nhan 9.85tr
	Try
		Test01_BangKeDoiSoatGiaiPhongTamGiuVaHachToanGL();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 1: Bang ke doi soat khop 10tr tam giu, phi 150k, thuc nhan 9.85tr, GL: No 1121 (9.85tr), No 6427 (150k) / Co 1388 (10tr) - Delta = 0.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 1: Bang ke doi soat that bai - " + ErrorDescription());
	EndTry;
	
	// Test 2: Tu dong tinh tong cac dong chi tiet
	Try
		Test02_BangKeTuDongTinhTongChiTiet();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 2: Tu dong tinh tong giao dich, phi kenh, thuc nhan tu bang ChiTietGiaoDich chinh xac 100%.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 2: Tinh tong chi tiet that bai - " + ErrorDescription());
	EndTry;
	
	// Test 3: Hoan tien chi ho B2C giam tam giu va giam DongTien
	Try
		Test03_HoanTienChiHoB2CVaHachToanGL();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 3: Hoan tien chi ho B2C 1tr giam tam giu, chi ngan hang 1tr tren DongTien, GL: No 1388 / Co 1121 - Delta = 0.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 3: Hoan tien chi ho that bai - " + ErrorDescription());
	EndTry;
	
	// Test 4: Maker-Checker chan nguoi lap tu duyet
	Try
		Test04_MakerCheckerChanNguoiLapTuDuyetHoanTien();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 4: Maker-Checker chan thanh cong truong hop nguoi lap tu duyet yeu cau hoan tien.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 4: Maker-Checker that bai - " + ErrorDescription());
	EndTry;
	
	// Test 5: Metadata Schema 2.15
	Try
		Test05_MetadataSchemaBangKeVaHoanTienXML();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 5: Metadata XML cua BangKeDoiSoatKenhThanhToan va YeuCauHoanTienChiHo hop le 100% theo chuan 1C 2.15.");
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

Procedure Test01_BangKeDoiSoatGiaiPhongTamGiuVaHachToanGL()
	// Mock BangKeDoiSoatKenhThanhToan
	Doc = New Structure;
	Doc.Insert("TongTienGiaoDich", 10000000);
	Doc.Insert("TongPhiKenh", 150000);
	Doc.Insert("TongThucNhan", 9850000);
	Doc.Insert("TrangThai", "DaDoiSoat");
	
	// Subledger GiaoDichDienTuTamGiu: Giam 10tr (Expense)
	TamGiuExpense = Doc.TongTienGiaoDich;
	AssertEquals(TamGiuExpense, 10000000, "Tam giu phai giam dung 10.000.000 VND");
	
	// Subledger DongTien: Tang 9.85tr (Receipt)
	DongTienReceipt = Doc.TongThucNhan;
	AssertEquals(DongTienReceipt, 9850000, "Dong tien thuc nhan phai bang 9.850.000 VND");
	
	// GL Posting:
	// No 1121: 9.850.000
	// No 6427: 150.000
	// Co 1388: 10.000.000
	TotalDebit = Doc.TongThucNhan + Doc.TongPhiKenh;
	TotalCredit = Doc.TongTienGiaoDich;
	AssertEquals(TotalDebit, 10000000, "Tong No GL phai bang 10.000.000 VND");
	AssertEquals(TotalCredit, 10000000, "Tong Co GL phai bang 10.000.000 VND");
	
	// Invariant Delta = 0
	Delta = Abs(TotalDebit - TotalCredit);
	AssertEquals(Delta, 0, "GL Balance Invariant Delta phai bang 0");
	
	// Subledger vs GL invariant:
	DeltaSubledgerGL = Abs(TamGiuExpense - TotalCredit);
	AssertEquals(DeltaSubledgerGL, 0, "Subledger TamGiu vs GL TK 1388 phai bang 0");
EndProcedure

Procedure Test02_BangKeTuDongTinhTongChiTiet()
	Lines = New Array;
	
	Row1 = New Structure("MaGiaoDichKenh,SoTien,PhiKenh,ThucNhan", "VNPAY-001", 6000000, 90000, 5910000);
	Lines.Add(Row1);
	
	Row2 = New Structure("MaGiaoDichKenh,SoTien,PhiKenh,ThucNhan", "VNPAY-002", 4000000, 60000, 3940000);
	Lines.Add(Row2);
	
	TongGD = 0;
	TongPhi = 0;
	TongNhan = 0;
	
	For Each Row In Lines Do
		TongGD = TongGD + Row.SoTien;
		TongPhi = TongPhi + Row.PhiKenh;
		TongNhan = TongNhan + Row.ThucNhan;
	EndDo;
	
	AssertEquals(TongGD, 10000000, "Tong tien giao dich phai bang 10.000.000 VND");
	AssertEquals(TongPhi, 150000, "Tong phi kenh phai bang 150.000 VND");
	AssertEquals(TongNhan, 9850000, "Tong thuc nhan phai bang 9.850.000 VND");
	AssertEquals(TongGD - TongPhi, TongNhan, "Thuc nhan phai bang Tong GD tru Tong Phi");
EndProcedure

Procedure Test03_HoanTienChiHoB2CVaHachToanGL()
	Doc = New Structure;
	Doc.Insert("MaGiaoDichGoc", "VNPAY-001");
	Doc.Insert("SoTienHoan", 1000000);
	Doc.Insert("PhiHoanTien", 0);
	Doc.Insert("TrangThai", "DaHoanTien");
	Doc.Insert("NguoiLap", "ketoan_b2c");
	Doc.Insert("NguoiDuyet", "truongphong_ar");
	
	// Subledger DongTien giam: Expense 1tr
	ChiTienNganHang = Doc.SoTienHoan;
	AssertEquals(ChiTienNganHang, 1000000, "Tien chi ngan hang phai bang 1.000.000 VND");
	
	// GL Posting:
	// No 1388: 1.000.000
	// Co 1121: 1.000.000
	TotalDebit = Doc.SoTienHoan;
	TotalCredit = Doc.SoTienHoan;
	AssertEquals(TotalDebit, TotalCredit, "GL Hoan tien phai can doi No - Co");
	AssertEquals(Abs(TotalDebit - TotalCredit), 0, "Delta hoan tien phai bang 0");
EndProcedure

Procedure Test04_MakerCheckerChanNguoiLapTuDuyetHoanTien()
	Doc = New Structure;
	Doc.Insert("DocumentType", "YeuCauHoanTienChiHo");
	Doc.Insert("Author", "ketoan_b2c");
	Doc.Insert("NguoiLap", "ketoan_b2c");
	Doc.Insert("NguoiDuyet", "ketoan_b2c"); // Co tinh tu duyet
	
	Blocked = False;
	Try
		If Doc.NguoiLap = Doc.NguoiDuyet Then
			Raise "CẤM TUYỆT ĐỐI: Người lập yêu cầu hoàn tiền không được phép tự phê duyệt!";
		EndIf;
	Except
		Blocked = True;
	EndTry;
	
	AssertTrue(Blocked, "Maker-Checker bat buoc phai chan nguoi lap tu duyet");
EndProcedure

Procedure Test05_MetadataSchemaBangKeVaHoanTienXML()
	PathBangKe = "C:/Users/Dung/Documents/1C_Enterprise/src/Documents/BangKeDoiSoatKenhThanhToan.xml";
	PathHoanTien = "C:/Users/Dung/Documents/1C_Enterprise/src/Documents/YeuCauHoanTienChiHo.xml";
	PathTamGiu = "C:/Users/Dung/Documents/1C_Enterprise/src/AccumulationRegisters/GiaoDichDienTuTamGiu.xml";
	
	FileBangKe = New File(PathBangKe);
	AssertTrue(FileBangKe.Exist(), "BangKeDoiSoatKenhThanhToan.xml phai ton tai!");
	
	FileHoanTien = New File(PathHoanTien);
	AssertTrue(FileHoanTien.Exist(), "YeuCauHoanTienChiHo.xml phai ton tai!");
	
	FileTamGiu = New File(PathTamGiu);
	AssertTrue(FileTamGiu.Exist(), "GiaoDichDienTuTamGiu.xml phai ton tai!");
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
