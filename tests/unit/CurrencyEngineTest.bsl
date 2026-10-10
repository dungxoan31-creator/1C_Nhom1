// Unit Test Suite: CurrencyEngineTest
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL / BUnit / Vanessa)
// Muc tieu: Kiem thu Thu vien QuanLyTyGiaVaNgoaiTeServer (Task 2.3):
//           1. Test 1 (So du ngoai te 0): Tra ve ty gia hach toan tu InformationRegister.TyGiaHoiDoai (25.350).
//           2. Test 2 (Nhap USD lan 1): 10.000 USD ty gia 25.000 -> Ty gia BQGQ = 25.000.
//           3. Test 3 (Nhap USD lan 2): 10.000 USD ty gia 25.500 -> Tong du 20.000 USD, 505tr VND -> Ty gia BQGQ = 25.250.
//           4. Test 4 (Xuat USD): Xuat 5.000 USD tra no AWS -> Quy doi 126.250.000 VND, ty gia BQGQ giu nguyen 25.250.
//           5. Test 5 (Phan lap da phap nhan): VSF Corp (25.000) va VSF Software (26.000) khong bi hoa tron so du.

#Region TestExecution

Function RunVerification() Export
	Results = RunAllTests();
	
	LogPath = "C:/Users/Dung/Documents/1C_Enterprise/tests/unit/currency_engine_test_result.log";
	TextW = New TextWriter(LogPath, TextEncoding.UTF8);
	For Each Line In Results.Log Do
		TextW.WriteLine(Line);
	EndDo;
	TextW.Close();
	
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
	TestLog.Add("   VINSMART FUTURE - CURRENCY ENGINE UNIT TEST (TASK 2.3)        ");
	TestLog.Add("   Thoi gian chay: " + CurrentDate());
	TestLog.Add("=================================================================");
	
	// Test 1: So du ngoai te 0 -> Tra ve ty gia hach toan tu TyGiaHoiDoai
	Try
		Test01_SoDuNgoaiTeZeroTraVeTyGiaHachToan();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 1: So du USD = 0 -> Tra ve ty gia hach toan tu TyGiaHoiDoai (25.350 VND/USD).");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 1: Xu ly so du 0 that bai - " + ErrorDescription());
	EndTry;
	
	// Test 2: Nhap USD lan 1 -> Ty gia BQGQ = 25.000
	Try
		Test02_NhapUSDLan1TinhTyGiaBQGQ();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 2: Nhap lan 1 (10.000 USD gia 25.000) -> Ty gia BQGQ tra ve dung 25.000 VND/USD.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 2: Nhap USD lan 1 that bai - " + ErrorDescription());
	EndTry;
	
	// Test 3: Nhap USD lan 2 -> Ty gia BQGQ di dong = 25.250
	Try
		Test03_NhapUSDLan2TinhTyGiaBQGQDiDong();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 3: Nhap lan 2 (10.000 USD gia 25.500) -> Ty gia BQGQ di dong dung 25.250 VND/USD.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 3: Nhap USD lan 2 that bai - " + ErrorDescription());
	EndTry;
	
	// Test 4: Xuat 5.000 USD tra no AWS -> Quy doi 126.250.000 VND, ty gia BQGQ giu nguyen 25.250
	Try
		Test04_XuatUSDTinhTyGiaVaQuyDoiVND();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 4: Xuat 5.000 USD AWS -> Quy doi dung 126.250.000 VND, du sau xuat giu ty gia 25.250.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 4: Xuat USD quy doi that bai - " + ErrorDescription());
	EndTry;
	
	// Test 5: Phan lap da phap nhan VSF Corp va VSF Software
	Try
		Test05_PhanLapDaPhapNhanTyGiaKhongHoaTron();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 5: Phan lap da phap nhan -> VSF Corp (25.000) va VSF Software (26.000) khong hoa tron.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 5: Phan lap da phap nhan that bai - " + ErrorDescription());
	EndTry;
	
	TestLog.Add("-----------------------------------------------------------------");
	TestLog.Add(StrTemplate("Tong so test: %1 | Thanh cong: %2 | That bai: %3", 
		TestResults.Total, TestResults.Passed, TestResults.Failed));
	TestLog.Add("=================================================================");
	
	Return TestResults;
EndFunction

#EndRegion

#Region TestCases

// -----------------------------------------------------------------------------
// Test 1: Tai khoan USD chua co so du -> Tra ve ty gia hach toan tu TyGiaHoiDoai (vi du 25.350)
// -----------------------------------------------------------------------------
Procedure Test01_SoDuNgoaiTeZeroTraVeTyGiaHachToan() Export
	// 1. Khoi tao hoac lay thong tin Master Data
	RefUSD = LayHoacTaoTienTe("USD", "Do la My");
	RefPN = LayHoacTaoPhapNhan("PN-VSF-CORP", "Cong ty Co phan VinSmart Future");
	RefTK = LayHoacTaoTaiKhoanTien("TK-USD-TEST01", "Tai khoan USD Test 01", RefUSD);
	
	NgayGiaoDich = Date(2026, 10, 10, 9, 0, 0);
	TyGiaHachToanChuan = 25350.0000;
	
	// 2. Ghi nhan ty gia hach toan vao InformationRegister.TyGiaHoiDoai
	GhiTyGiaHoiDoai(NgayGiaoDich, RefUSD, 25200, 25500, TyGiaHachToanChuan);
	
	// 3. Kiem tra ham LayTyGiaHachToanHieuLuc
	RateHachToan = QuanLyTyGiaVaNgoaiTeServer.LayTyGiaHachToanHieuLuc(RefUSD, NgayGiaoDich);
	AssertEquals(TyGiaHachToanChuan, RateHachToan, 
		"LayTyGiaHachToanHieuLuc phai tra ve ty gia 25.350 tu TyGiaHoiDoai");
	
	// 4. Kiem tra TinhTyGiaXuatQuyBQGQ khi chua co so du ngoai te (So du = 0)
	// Dam bao xoa moi so du mo phong cua tai khoan nay neu co
	QuanLyTyGiaVaNgoaiTeServer.DatSoDuMoPhong(RefPN, RefTK, RefUSD, 0, 0);
	
	RateBQGQ = QuanLyTyGiaVaNgoaiTeServer.TinhTyGiaXuatQuyBQGQ(RefPN, RefTK, RefUSD, NgayGiaoDich);
	AssertEquals(TyGiaHachToanChuan, RateBQGQ, 
		"Khi so du ngoai te = 0, TinhTyGiaXuatQuyBQGQ phai tu dong tra cuu ty gia hach toan (25.350)");
EndProcedure

// -----------------------------------------------------------------------------
// Test 2: Nhap USD lan 1: Nhap 10.000 USD ty gia 25.000 (250tr VND) -> Ty gia BQGQ = 25.000
// -----------------------------------------------------------------------------
Procedure Test02_NhapUSDLan1TinhTyGiaBQGQ() Export
	RefUSD = LayHoacTaoTienTe("USD", "Do la My");
	RefPN = LayHoacTaoPhapNhan("PN-VSF-CORP", "Cong ty Co phan VinSmart Future");
	RefTK = LayHoacTaoTaiKhoanTien("TK-USD-TEST02", "Tai khoan USD Test 02", RefUSD);
	
	ThoiDiem1 = Date(2026, 10, 10, 10, 0, 0);
	
	// Ghi nhan so du lan 1: 10.000 USD va 250.000.000 VND
	SoDuVND = 250000000;
	SoDuUSD = 10000;
	QuanLyTyGiaVaNgoaiTeServer.DatSoDuMoPhong(RefPN, RefTK, RefUSD, SoDuVND, SoDuUSD);
	
	RateBQGQ = QuanLyTyGiaVaNgoaiTeServer.TinhTyGiaXuatQuyBQGQ(RefPN, RefTK, RefUSD, ThoiDiem1);
	AssertEquals(25000, RateBQGQ, 
		"Ty gia BQGQ sau nhap lan 1 phai bang 250.000.000 / 10.000 = 25.000 VND/USD");
EndProcedure

// -----------------------------------------------------------------------------
// Test 3: Nhap USD lan 2: Nhap tiep 10.000 USD ty gia 25.500 (255tr VND)
//         -> Tong du: 20.000 USD, 505tr VND -> Ty gia BQGQ = 505.000.000 / 20.000 = 25.250 VND/USD
// -----------------------------------------------------------------------------
Procedure Test03_NhapUSDLan2TinhTyGiaBQGQDiDong() Export
	RefUSD = LayHoacTaoTienTe("USD", "Do la My");
	RefPN = LayHoacTaoPhapNhan("PN-VSF-CORP", "Cong ty Co phan VinSmart Future");
	RefTK = LayHoacTaoTaiKhoanTien("TK-USD-TEST03", "Tai khoan USD Test 03", RefUSD);
	
	ThoiDiem2 = Date(2026, 10, 10, 12, 0, 0);
	
	// Tong so du luy ke sau lan 2: 250tr + 255tr = 505tr VND; 10k + 10k = 20k USD
	TongDuVND = 250000000 + 255000000; // 505,000,000 VND
	TongDuUSD = 10000 + 10000;         // 20,000 USD
	QuanLyTyGiaVaNgoaiTeServer.DatSoDuMoPhong(RefPN, RefTK, RefUSD, TongDuVND, TongDuUSD);
	
	RateBQGQ = QuanLyTyGiaVaNgoaiTeServer.TinhTyGiaXuatQuyBQGQ(RefPN, RefTK, RefUSD, ThoiDiem2);
	AssertEquals(25250, RateBQGQ, 
		"Ty gia BQGQ di dong sau lan 2 phai bang 505.000.000 / 20.000 = 25.250 VND/USD");
EndProcedure

// -----------------------------------------------------------------------------
// Test 4: Xuat USD: Xuat 5.000 USD tra no AWS -> Quy doi ghi nhan theo dung ty gia BQGQ 25.250 = 126.250.000 VND.
//         Du sau xuat: 15.000 USD va 378.750.000 VND (ty gia BQGQ giu nguyen 25.250).
// -----------------------------------------------------------------------------
Procedure Test04_XuatUSDTinhTyGiaVaQuyDoiVND() Export
	RefUSD = LayHoacTaoTienTe("USD", "Do la My");
	RefPN = LayHoacTaoPhapNhan("PN-VSF-CORP", "Cong ty Co phan VinSmart Future");
	RefTK = LayHoacTaoTaiKhoanTien("TK-USD-TEST04", "Tai khoan USD Test 04", RefUSD);
	
	ThoiDiemTruocXuat = Date(2026, 10, 10, 13, 0, 0);
	ThoiDiemSauXuat   = Date(2026, 10, 10, 14, 0, 0);
	
	// So du truoc khi xuat (ke thua tu ket qua 2 lan nhap: 20.000 USD, 505.000.000 VND)
	DuVNDTruocXuat = 505000000;
	DuUSDTruocXuat = 20000;
	QuanLyTyGiaVaNgoaiTeServer.DatSoDuMoPhong(RefPN, RefTK, RefUSD, DuVNDTruocXuat, DuUSDTruocXuat);
	
	// 1. Tinh ty gia BQGQ tai thoi diem xuat quy
	RateBQGQ = QuanLyTyGiaVaNgoaiTeServer.TinhTyGiaXuatQuyBQGQ(RefPN, RefTK, RefUSD, ThoiDiemTruocXuat);
	AssertEquals(25250, RateBQGQ, "Ty gia BQGQ xuat quy phai la 25.250");
	
	// 2. Quy doi so tien xuat 5.000 USD sang VND
	SoTienXuatUSD = 5000;
	SoTienQuyDoiVND = QuanLyTyGiaVaNgoaiTeServer.QuyDoiNgoaiTeSangVND(SoTienXuatUSD, RateBQGQ);
	AssertEquals(126250000, SoTienQuyDoiVND, 
		"Quy doi 5.000 USD theo ty gia 25.250 phai dung bang 126.250.000 VND");
	
	// 3. Cap nhat so du sau khi xuat quy
	DuVNDSauXuat = DuVNDTruocXuat - SoTienQuyDoiVND; // 378,750,000 VND
	DuUSDSauXuat = DuUSDTruocXuat - SoTienXuatUSD;   // 15,000 USD
	AssertEquals(378750000, DuVNDSauXuat, "Du VND sau xuat phai la 378.750.000 VND");
	AssertEquals(15000, DuUSDSauXuat, "Du USD sau xuat phai la 15.000 USD");
	
	QuanLyTyGiaVaNgoaiTeServer.DatSoDuMoPhong(RefPN, RefTK, RefUSD, DuVNDSauXuat, DuUSDSauXuat);
	
	// 4. Kiem tra ty gia BQGQ sau xuat quy van phai giu nguyen 25.250
	RateBQGQSauXuat = QuanLyTyGiaVaNgoaiTeServer.TinhTyGiaXuatQuyBQGQ(RefPN, RefTK, RefUSD, ThoiDiemSauXuat);
	AssertEquals(25250, RateBQGQSauXuat, 
		"Ty gia BQGQ sau xuat phai giu nguyen 25.250 (378.750.000 / 15.000 = 25.250)");
EndProcedure

// -----------------------------------------------------------------------------
// Test 5: Phan lap da phap nhan: VSF Corp (10.000 USD gia 25.000); VSF Software (10.000 USD gia 26.000).
//         Khi tinh ty gia BQGQ cho VSF Corp, ket qua bat buoc la 25.000, khong bi hoa tron so du cua VSF Software.
// -----------------------------------------------------------------------------
Procedure Test05_PhanLapDaPhapNhanTyGiaKhongHoaTron() Export
	RefUSD = LayHoacTaoTienTe("USD", "Do la My");
	
	// 2 Phap nhan rieng biet
	RefPN_Corp = LayHoacTaoPhapNhan("PN-VSF-CORP", "Cong ty Co phan VinSmart Future");
	RefPN_Soft = LayHoacTaoPhapNhan("PN-VSF-SOFT", "Cong ty Phan mem VinSmart Future Software");
	
	// Tai khoan tien cua tung phap nhan
	RefTK_Corp = LayHoacTaoTaiKhoanTien("TK-USD-CORP", "Tai khoan USD VSF Corp", RefUSD);
	RefTK_Soft = LayHoacTaoTaiKhoanTien("TK-USD-SOFT", "Tai khoan USD VSF Software", RefUSD);
	
	ThoiDiemKiemTra = Date(2026, 10, 10, 16, 0, 0);
	
	// Ghi nhan so du rieng biet cho 2 phap nhan
	// VSF Corp: 10.000 USD ty gia 25.000 = 250.000.000 VND
	QuanLyTyGiaVaNgoaiTeServer.DatSoDuMoPhong(RefPN_Corp, RefTK_Corp, RefUSD, 250000000, 10000);
	
	// VSF Software: 10.000 USD ty gia 26.000 = 260.000.000 VND
	QuanLyTyGiaVaNgoaiTeServer.DatSoDuMoPhong(RefPN_Soft, RefTK_Soft, RefUSD, 260000000, 10000);
	
	// 1. Tinh ty gia BQGQ cho VSF Corp -> Bat buoc la 25.000
	RateCorp = QuanLyTyGiaVaNgoaiTeServer.TinhTyGiaXuatQuyBQGQ(RefPN_Corp, RefTK_Corp, RefUSD, ThoiDiemKiemTra);
	AssertEquals(25000, RateCorp, 
		"Ty gia BQGQ cua VSF Corp phai bang dung 25.000 VND/USD, khong duoc lan so du cua VSF Software");
	
	// 2. Tinh ty gia BQGQ cho VSF Software -> Bat buoc la 26.000
	RateSoft = QuanLyTyGiaVaNgoaiTeServer.TinhTyGiaXuatQuyBQGQ(RefPN_Soft, RefTK_Soft, RefUSD, ThoiDiemKiemTra);
	AssertEquals(26000, RateSoft, 
		"Ty gia BQGQ cua VSF Software phai bang dung 26.000 VND/USD, khong duoc lan so du cua VSF Corp");
EndProcedure

#EndRegion

#Region HelperFunctions

Function LayHoacTaoTienTe(Code, Description)
	Try
		Found = Catalogs.TienTe.FindByCode(Code);
		If ValueIsFilled(Found) Then
			Return Found;
		EndIf;
		Obj = Catalogs.TienTe.CreateItem();
		Obj.Code = Code;
		Obj.Description = Description;
		Obj.Write();
		Return Obj.Ref;
	Except
		// Mock structure neu runtime khong truy cap duoc truc tiep database
		Res = New Structure;
		Res.Insert("Code", Code);
		Res.Insert("Description", Description);
		Return Res;
	EndTry;
EndFunction

Function LayHoacTaoPhapNhan(Code, Description)
	Try
		Found = Catalogs.PhapNhan.FindByCode(Code);
		If ValueIsFilled(Found) Then
			Return Found;
		EndIf;
		Obj = Catalogs.PhapNhan.CreateItem();
		Obj.Code = Code;
		Obj.Description = Description;
		Obj.Write();
		Return Obj.Ref;
	Except
		Res = New Structure;
		Res.Insert("Code", Code);
		Res.Insert("Description", Description);
		Return Res;
	EndTry;
EndFunction

Function LayHoacTaoTaiKhoanTien(Code, Description, RefTienTe)
	Try
		Found = Catalogs.TaiKhoanTien.FindByCode(Code);
		If ValueIsFilled(Found) Then
			Return Found;
		EndIf;
		Obj = Catalogs.TaiKhoanTien.CreateItem();
		Obj.Code = Code;
		Obj.Description = Description;
		Obj.SoTaiKhoan = Code;
		Obj.NganHang = "Techcombank Hoi So";
		If TypeOf(RefTienTe) = Type("CatalogRef.TienTe") Then
			Obj.TienTe = RefTienTe;
		EndIf;
		Obj.Write();
		Return Obj.Ref;
	Except
		Res = New Structure;
		Res.Insert("Code", Code);
		Res.Insert("Description", Description);
		Res.Insert("TienTe", RefTienTe);
		Return Res;
	EndTry;
EndFunction

Procedure GhiTyGiaHoiDoai(PeriodDate, RefTienTe, TyGiaMua, TyGiaBan, TyGiaHachToan)
	Try
		RecordMgr = InformationRegisters.TyGiaHoiDoai.CreateRecordManager();
		RecordMgr.Period = BegOfDay(PeriodDate);
		If TypeOf(RefTienTe) = Type("CatalogRef.TienTe") Then
			RecordMgr.TienTe = RefTienTe;
		EndIf;
		RecordMgr.TyGiaMua = TyGiaMua;
		RecordMgr.TyGiaBan = TyGiaBan;
		RecordMgr.TyGiaHachToan = TyGiaHachToan;
		RecordMgr.Write(True);
	Except
		// Neu khong ghi duoc truc tiep vao Database do context mock
		If TypeOf(RefTienTe) = Type("Structure") Then
			RefTienTe.Insert("TyGiaHachToan", TyGiaHachToan);
		EndIf;
	EndTry;
EndProcedure

#EndRegion

#Region AssertHelpers

Procedure AssertTrue(Condition, Message)
	If Not Condition Then
		Raise "ASSERT FAILED: " + Message;
	EndIf;
EndProcedure

Procedure AssertFalse(Condition, Message)
	If Condition Then
		Raise "ASSERT FAILED: " + Message;
	EndIf;
EndProcedure

Procedure AssertEquals(Expected, Actual, Message)
	If Expected <> Actual Then
		Raise StrTemplate("ASSERT FAILED: %1 (Ky vong: %2, Thuc te: %3)", Message, Expected, Actual);
	EndIf;
EndProcedure

#EndRegion
