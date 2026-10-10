// Unit Test Suite: PheDuyetDaCapTest
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL / BUnit / Vanessa)
// Muc tieu: Kiem thu PheDuyetDaCapServer (Task 2.4 - Anti-Split Quet Hoa Don & Luong Phe Duyet 4+1 Cap):
//   1. Test 1: Phan cap phe duyet co ban 4 cap theo so tien (<= 100tr, <= 500tr, <= 2 ty, > 2 ty)
//   2. Test 2: Anti-Split: Quet hoa don cung thang cung NCC va tu dong leo thang cap duyet
//   3. Test 3: Anti-Split: Tong luy ke vuot nguong 2 ty leo thang len TongGiamDoc
//   4. Test 4: Phan lap du lieu hoa don doc lap theo thang duong lich va theo doi tac
//   5. Test 5: Nhanh phe duyet dac biet +1: CFO Unlock khi vuot ngan sach > 10% tren KeHoachChiTien

#Region TestExecution

Function RunAllTests() Export
	TestResults = New Structure;
	TestResults.Insert("Total", 5);
	TestResults.Insert("Passed", 0);
	TestResults.Insert("Failed", 0);
	TestResults.Insert("Log", New Array);
	
	TestLog = TestResults.Log;
	TestLog.Add("=================================================================");
	TestLog.Add("   VINSMART FUTURE - AP APPROVAL & ANTI-SPLIT TEST (TASK 2.4)   ");
	TestLog.Add("   Thoi gian chay: " + CurrentDate());
	TestLog.Add("=================================================================");
	
	// Test 1: Phan cap co ban (80tr -> TBP, 250tr -> KTT, 1.2 ty -> GDK, 3.5 ty -> TGD)
	Try
		Test01_PhanCapPheDuyetCoBanTheoSoTien();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 1: Phan cap phe duyet 4 cap theo gia tri hoa don co ban thanh cong.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 1: Phan cap co ban that bai - " + ErrorDescription());
	EndTry;
	
	// Test 2: Anti-Split leo thang cap duyet (300tr -> KTT; them 250tr luy ke 550tr -> Leo thang GDK)
	Try
		Test02_AntiSplitLeoThangCapDuyet();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 2: Anti-Split phat hien chia nho hoa don va leo thang len GiamDocKhoi thanh cong.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 2: Anti-Split leo thang cap duyet that bai - " + ErrorDescription());
	EndTry;
	
	// Test 3: Anti-Split vuot 2 ty (Luy ke 1.8 ty + 300tr = 2.1 ty -> Leo thang TongGiamDoc)
	Try
		Test03_AntiSplitVuotHaiTyLeoThangTongGiamDoc();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 3: Anti-Split luy ke vuot 2 ty tu dong leo thang len TongGiamDoc thanh cong.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 3: Anti-Split vuot 2 ty that bai - " + ErrorDescription());
	EndTry;
	
	// Test 4: Phan lap doi tac va thang khac nhau
	Try
		Test04_PhanLapDoiTacVaThangKhacNhau();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 4: Phan lap luy ke theo thang duong lich va theo doi tac chinh xac.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 4: Phan lap doi tac va thang that bai - " + ErrorDescription());
	EndTry;
	
	// Test 5: Nhanh CFO Unlock khi vuot ngan sach > 10%
	Try
		Test05_NhanhPheDuyetCFOVuotNganSach10PhanTram();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 5: Nhanh phe duyet dac biet CFO Unlock khi vuot ngan sach > 10% thanh cong.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 5: Nhanh CFO Unlock that bai - " + ErrorDescription());
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
// Test 1: Quy tac phan cap phe duyet 4 cap theo gia tri hoa don / de nghi chi
//   - Cap 1 (TruongBoPhan): Gia tri <= 100.000.000 VND
//   - Cap 2 (KeToanTruong): Gia tri > 100.000.000 VND va <= 500.000.000 VND
//   - Cap 3 (GiamDocKhoi):  Gia tri > 500.000.000 VND va <= 2.000.000.000 VND
//   - Cap 4 (TongGiamDoc):  Gia tri > 2.000.000.000 VND
// -----------------------------------------------------------------------------
Procedure Test01_PhanCapPheDuyetCoBanTheoSoTien() Export
	// 1a. Kiem tra cac gia tri khao sat trong brief
	Cap80tr = PheDuyetDaCapServer.XacDinhCapPheDuyetTheoSoTien(80000000);
	AssertEquals("TruongBoPhan", Cap80tr, "80tr phai duoc phe duyet boi TruongBoPhan");
	
	Cap250tr = PheDuyetDaCapServer.XacDinhCapPheDuyetTheoSoTien(250000000);
	AssertEquals("KeToanTruong", Cap250tr, "250tr phai duoc phe duyet boi KeToanTruong");
	
	Cap1Ty2 = PheDuyetDaCapServer.XacDinhCapPheDuyetTheoSoTien(1200000000);
	AssertEquals("GiamDocKhoi", Cap1Ty2, "1.2 ty phai duoc phe duyet boi GiamDocKhoi");
	
	Cap3Ty5 = PheDuyetDaCapServer.XacDinhCapPheDuyetTheoSoTien(3500000000);
	AssertEquals("TongGiamDoc", Cap3Ty5, "3.5 ty phai duoc phe duyet boi TongGiamDoc");
	
	// 1b. Kiem tra cac diem moc ranh gioi (Boundary values)
	AssertEquals("TruongBoPhan", PheDuyetDaCapServer.XacDinhCapPheDuyetTheoSoTien(100000000), 
		"Dung 100tr phai thuoc cap TruongBoPhan");
	AssertEquals("KeToanTruong", PheDuyetDaCapServer.XacDinhCapPheDuyetTheoSoTien(100000001), 
		"100tr + 1 VND phai chuyen len cap KeToanTruong");
	AssertEquals("KeToanTruong", PheDuyetDaCapServer.XacDinhCapPheDuyetTheoSoTien(500000000), 
		"Dung 500tr phai thuoc cap KeToanTruong");
	AssertEquals("GiamDocKhoi", PheDuyetDaCapServer.XacDinhCapPheDuyetTheoSoTien(500000001), 
		"500tr + 1 VND phai chuyen len cap GiamDocKhoi");
	AssertEquals("GiamDocKhoi", PheDuyetDaCapServer.XacDinhCapPheDuyetTheoSoTien(2000000000), 
		"Dung 2 ty phai thuoc cap GiamDocKhoi");
	AssertEquals("TongGiamDoc", PheDuyetDaCapServer.XacDinhCapPheDuyetTheoSoTien(2000000001), 
		"2 ty + 1 VND phai chuyen len cap TongGiamDoc");
EndProcedure

// -----------------------------------------------------------------------------
// Test 2: Co che phat hien gian lan Anti-Split (Lach han muc)
//   - Hoa don 1 = 300tr trong thang -> KeToanTruong duyet
//   - Hoa don 2 = 250tr cung thang cho cung NCC -> Luy ke = 550tr > 500tr
//     -> Tu dong LEO THANG len GiamDocKhoi phe duyet (thay vi chi KTT)
// -----------------------------------------------------------------------------
Procedure Test02_AntiSplitLeoThangCapDuyet() Export
	PheDuyetDaCapServer.XoaDuLieuLuyKeMoPhong();
	
	PhapNhan = "PN-VSF-CORP";
	DoiTacAWS = "DT-AWS";
	NgayHD1 = Date(2026, 10, 5, 9, 0, 0);
	NgayHD2 = Date(2026, 10, 12, 14, 0, 0);
	
	// Buoc 1: Hoa don 1 = 300tr (chua co luy ke truoc do)
	CapHD1 = PheDuyetDaCapServer.XacDinhCapPheDuyetHoaDon(PhapNhan, DoiTacAWS, 300000000, NgayHD1);
	AssertEquals("KeToanTruong", CapHD1, "Hoa don 1 (300tr) phai do KeToanTruong phe duyet");
	
	// Dang ky Hoa don 1 vao he thong
	PheDuyetDaCapServer.DangKyHoaDon(PhapNhan, DoiTacAWS, 300000000, NgayHD1, "HD-AWS-001");
	
	// Buoc 2: Kiem tra tong luy ke truoc khi xac dinh cap duyet cho Hoa don 2
	LuyKeTruocHD2 = PheDuyetDaCapServer.TinhTongLuyKeTrongThang(PhapNhan, DoiTacAWS, NgayHD2);
	AssertEquals(300000000, LuyKeTruocHD2, "Luy ke truoc hoa don 2 phai la 300tr");
	
	// Buoc 3: Hoa don 2 = 250tr cung thang cho cung doi tac AWS
	// Neu danh gia rieng le: 250tr chi yeu cau KeToanTruong
	CapDocLapHD2 = PheDuyetDaCapServer.XacDinhCapPheDuyetTheoSoTien(250000000);
	AssertEquals("KeToanTruong", CapDocLapHD2, "Rieng le 250tr chi can cap KeToanTruong");
	
	// Nho co Anti-Split: Tong luy ke = 300tr + 250tr = 550tr > 500tr -> Phai leo thang len GiamDocKhoi!
	CapHD2 = PheDuyetDaCapServer.XacDinhCapPheDuyetHoaDon(PhapNhan, DoiTacAWS, 250000000, NgayHD2);
	AssertEquals("GiamDocKhoi", CapHD2, 
		"Anti-Split: Hoa don 2 (250tr) tong luy ke thang 550tr > 500tr phai LEO THANG len GiamDocKhoi");
EndProcedure

// -----------------------------------------------------------------------------
// Test 3: Anti-Split vuot nguong 2 ty leo thang TongGiamDoc
//   - Luy ke truoc do = 1.8 ty
//   - Hoa don moi = 300tr -> Tong luy ke = 2.1 ty > 2 ty -> Leo thang len TongGiamDoc
// -----------------------------------------------------------------------------
Procedure Test03_AntiSplitVuotHaiTyLeoThangTongGiamDoc() Export
	PheDuyetDaCapServer.XoaDuLieuLuyKeMoPhong();
	
	PhapNhan = "PN-VSF-CORP";
	DoiTacAWS = "DT-AWS";
	NgayGoc = Date(2026, 10, 10, 8, 30, 0);
	NgayMoi = Date(2026, 10, 20, 15, 0, 0);
	
	// Buoc 1: Dang ky cac hoa don truoc do trong thang voi tong 1.8 ty
	PheDuyetDaCapServer.DangKyHoaDon(PhapNhan, DoiTacAWS, 1800000000, NgayGoc, "HD-AWS-PREV");
	
	LuyKeTruoc = PheDuyetDaCapServer.TinhTongLuyKeTrongThang(PhapNhan, DoiTacAWS, NgayMoi);
	AssertEquals(1800000000, LuyKeTruoc, "Luy ke truoc do trong thang phai la 1.8 ty");
	
	// Buoc 2: Hoa don moi 300tr phat sinh cung thang
	// Don le: 300tr chi can KeToanTruong
	CapDonLe = PheDuyetDaCapServer.XacDinhCapPheDuyetTheoSoTien(300000000);
	AssertEquals("KeToanTruong", CapDonLe, "Gia tri don le 300tr chi thuoc cap KeToanTruong");
	
	// Tong luy ke = 1.8 ty + 300tr = 2.1 ty > 2 ty -> Tu dong leo thang len TongGiamDoc
	CapMoi = PheDuyetDaCapServer.XacDinhCapPheDuyetHoaDon(PhapNhan, DoiTacAWS, 300000000, NgayMoi);
	AssertEquals("TongGiamDoc", CapMoi, 
		"Anti-Split: Tong luy ke 2.1 ty > 2 ty phai LEO THANG len TongGiamDoc");
EndProcedure

// -----------------------------------------------------------------------------
// Test 4: Phan lap doi tac va thang khac nhau
//   - Hoa don thang truoc khong bi cong don vao thang nay
//   - Hoa don cua NCC khac khong lam anh huong den NCC hien tai
// -----------------------------------------------------------------------------
Procedure Test04_PhanLapDoiTacVaThangKhacNhau() Export
	PheDuyetDaCapServer.XoaDuLieuLuyKeMoPhong();
	
	PhapNhan = "PN-VSF-CORP";
	DoiTacAWS = "DT-AWS";
	DoiTacMS = "DT-MICROSOFT";
	
	NgayThang9 = Date(2026, 9, 25, 10, 0, 0);
	NgayThang10_1 = Date(2026, 10, 5, 11, 0, 0);
	NgayThang10_2 = Date(2026, 10, 15, 16, 0, 0);
	
	// 1. Dang ky hoa don thang 9 cho AWS: 400tr (Thang truoc)
	PheDuyetDaCapServer.DangKyHoaDon(PhapNhan, DoiTacAWS, 400000000, NgayThang9, "HD-AWS-SEP");
	
	// 2. Dang ky hoa don thang 10 cho Microsoft: 450tr (Doi tac khac)
	PheDuyetDaCapServer.DangKyHoaDon(PhapNhan, DoiTacMS, 450000000, NgayThang10_1, "HD-MS-OCT");
	
	// 3. Kiem tra luy ke thang 10 cua AWS:
	// Khong bi cong 400tr cua thang 9, khong bi cong 450tr cua Microsoft -> Phai bang 0!
	LuyKeAWS_Thang10 = PheDuyetDaCapServer.TinhTongLuyKeTrongThang(PhapNhan, DoiTacAWS, NgayThang10_2);
	AssertEquals(0, LuyKeAWS_Thang10, 
		"AWS thang 10 khong bi cong don boi hoa don thang 9 hoac boi NCC khac");
	
	// 4. Hoa don moi AWS trong thang 10 = 200tr:
	// Neu bi cong don sai se vuot 500tr va leo thang GDK.
	// Vi phan lap chuan nen tong chi la 200tr -> Giu nguyen cap KeToanTruong!
	CapAWS_Thang10 = PheDuyetDaCapServer.XacDinhCapPheDuyetHoaDon(PhapNhan, DoiTacAWS, 200000000, NgayThang10_2);
	AssertEquals("KeToanTruong", CapAWS_Thang10, 
		"Hoa don 200tr thang 10 cua AWS phai giu dung cap KeToanTruong vi duoc phan lap");
	
	// 5. Kiem tra luy ke cua Microsoft trong thang 10: dung 450tr
	LuyKeMS_Thang10 = PheDuyetDaCapServer.TinhTongLuyKeTrongThang(PhapNhan, DoiTacMS, NgayThang10_2);
	AssertEquals(450000000, LuyKeMS_Thang10, 
		"Microsoft thang 10 phai ghi nhan dung 450tr");
EndProcedure

// -----------------------------------------------------------------------------
// Test 5: Nhanh phe duyet dac biet +1 (CFO Special Unlock) khi vuot ngan sach > 10%
//   - Case 5a: Ngan sach = 100tr, da duyet = 95tr. Hoa don moi = 16tr
//     -> Tong = 111tr > 110tr (110% ngan sach) -> YeuCauDuyetCFO = True
//   - Case 5b: Ngan sach = 100tr, da duyet = 80tr. Hoa don moi = 25tr
//     -> Tong = 105tr <= 110tr (<= 110% ngan sach) -> YeuCauDuyetCFO = False
// -----------------------------------------------------------------------------
Procedure Test05_NhanhPheDuyetCFOVuotNganSach10PhanTram() Export
	PhapNhan = "PN-VSF-CORP";
	DuAnCloud = "DA-ERP-CLOUD";
	KhoanMucCloud = "KM-HA-CLOUD";
	ThoiDiemChi = Date(2026, 10, 15, 10, 0, 0);
	
	// Case 5a: Ngan sach = 100tr, Da duyet = 95tr
	PheDuyetDaCapServer.DatNganSachMoPhong(PhapNhan, DuAnCloud, KhoanMucCloud, 
		BegOfMonth(ThoiDiemChi), 100000000, 95000000, 0);
	
	// Hoa don moi 16tr -> Tong sau chi = 95tr + 16tr = 111tr > 110tr (110%)
	YeuCauCFO_1 = PheDuyetDaCapServer.KiemTraYeuCauDuyetCFO(PhapNhan, DuAnCloud, KhoanMucCloud, ThoiDiemChi, 16000000);
	AssertTrue(YeuCauCFO_1, 
		"Tong 111tr > 110tr (vuot > 10% ngan sach 100tr) -> Bat buoc co phe duyet bo sung cua CFO");
	
	// Case 5b: Ngan sach = 100tr, Da duyet = 80tr
	PheDuyetDaCapServer.DatNganSachMoPhong(PhapNhan, DuAnCloud, KhoanMucCloud, 
		BegOfMonth(ThoiDiemChi), 100000000, 80000000, 0);
	
	// Hoa don moi 25tr -> Tong sau chi = 80tr + 25tr = 105tr <= 110tr (110%)
	YeuCauCFO_2 = PheDuyetDaCapServer.KiemTraYeuCauDuyetCFO(PhapNhan, DuAnCloud, KhoanMucCloud, ThoiDiemChi, 25000000);
	AssertFalse(YeuCauCFO_2, 
		"Tong 105tr <= 110tr (khong vuot qua 10% ngan sach 100tr) -> Khong yeu cau CFO phe duyet");
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
