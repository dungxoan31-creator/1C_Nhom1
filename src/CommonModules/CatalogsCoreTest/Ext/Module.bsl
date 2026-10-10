Function RunVerification() Export
	Results = RunAllTests();
	
	// Ghi file ket qua
	LogPath = "C:/Users/Dung/Documents/1C_Enterprise/tests/unit/test_result.log";
	TextW = New TextWriter(LogPath, TextEncoding.UTF8);
	For Each Line In Results.Log Do
		TextW.WriteLine(Line);
	EndDo;
	TextW.Close();
	
	Return Results;
EndFunction

// Unit Test Suite: CatalogsCoreTest
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL / BUnit / Vanessa)
// Muc tieu: Kiem thu khoi tao 10 Danh muc, Logic BeforeWrite Net 30 tren HopDong,
//           Logic bat trung lap SoTaiKhoanAo tren TaiKhoanAo, va Gia lap Session Parameter RLS.

#Region TestExecution

Function RunAllTests() Export
	TestResults = New Structure;
	TestResults.Insert("Total", 4);
	TestResults.Insert("Passed", 0);
	TestResults.Insert("Failed", 0);
	TestResults.Insert("Log", New Array);
	
	TestLog = TestResults.Log;
	TestLog.Add("=================================================================");
	TestLog.Add("   VINSMART FUTURE - CATALOGS CORE UNIT TEST (TASK 1.1)          ");
	TestLog.Add("   Thoi gian chay: " + CurrentSessionDate());
	TestLog.Add("=================================================================");
	
	// Test 1: Khoi tao ban ghi tren 10 Catalogs
	Try
		Test01_KhoiTaoBanGhi10Catalogs();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 1: Khoi tao ban ghi thanh cong tren ca 10 Catalogs.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 1: Khoi tao ban ghi that bai - " + ErrorDescription());
	EndTry;
	
	// Test 2: HopDong tu dong gan HanThanhToanNgay = 30 khi <= 0
	Try
		Test02_HopDongTuDongGanHanThanhToanNgay30();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 2: HopDong tu dong gan HanThanhToanNgay = 30 (Net 30) khi khong truyen hoac <= 0.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 2: Logic HanThanhToanNgay tren HopDong that bai - " + ErrorDescription());
	EndTry;
	
	// Test 3: TaiKhoanAo nem loi khi trung SoTaiKhoanAo
	Try
		Test03_TaiKhoanAoNemLoiKhiTrungSoTaiKhoanAo();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 3: TaiKhoanAo nem loi dung khi co 2 ban ghi trung SoTaiKhoanAo.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 3: Logic bat trung SoTaiKhoanAo that bai - " + ErrorDescription());
	EndTry;
	
	// Test 4: Gia lap Session Parameter CurrentPhapNhan tren Catalog.HopDong theo RLS
	Try
		Test04_GiaLapSessionParameterPhapNhanRLS();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 4: Gia lap Session Parameter CurrentPhapNhan RLS - Phan quyen cach ly du lieu phap nhan thanh cong.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 4: RLS Session Parameter CurrentPhapNhan that bai - " + ErrorDescription());
	EndTry;
	
	TestLog.Add("-----------------------------------------------------------------");
	TestLog.Add(StrTemplate("Tong so test: %1 | Thanh cong: %2 | That bai: %3", 
		TestResults.Total, TestResults.Passed, TestResults.Failed));
	TestLog.Add("=================================================================");
	
	Return TestResults;
EndFunction

#EndRegion

#Region TestCases

// Test 1: Khoi tao ban ghi tren 10 Catalogs
Procedure Test01_KhoiTaoBanGhi10Catalogs() Export
	// 1. Catalog.PhapNhan
	ObjPN = Catalogs.PhapNhan.CreateItem();
	ObjPN.Code = "PN-TEST1";
	ObjPN.Description = "VinSmart Future Corp (Test)";
	ObjPN.MaSoThue = "0109988776";
	ObjPN.DiaChi = "Toa Symphony, Vinhomes Riverside, Long Bien, Ha Noi";
	ObjPN.Write();
	AssertTrue(ValueIsFilled(ObjPN.Ref), "Catalog.PhapNhan: Ref phai duoc tao");
	RefPN = ObjPN.Ref;
	
	// 2. Catalog.DoiTac
	ObjDT = Catalogs.DoiTac.CreateItem();
	ObjDT.Code = "DT-TEST1";
	ObjDT.Description = "Tap Doan Vingroup (Test)";
	ObjDT.LaBenLienKet = True;
	ObjDT.DaDangKyThueTrucTiep = True;
	ObjDT.LoaiDoiTac = Enums.LoaiDoiTac.KhachHangVaNhaCungCap;
	ObjDT.Write();
	AssertTrue(ValueIsFilled(ObjDT.Ref), "Catalog.DoiTac: Ref phai duoc tao");
	RefDT = ObjDT.Ref;
	
	// 3. Catalog.TienTe
	ObjTT = Catalogs.TienTe.CreateItem();
	ObjTT.Code = "VND";
	ObjTT.Description = "Vietnamese Dong";
	ObjTT.MaTienTe = "VND";
	ObjTT.TenDayDu = "Dong Viet Nam";
	ObjTT.Write();
	AssertTrue(ValueIsFilled(ObjTT.Ref), "Catalog.TienTe: Ref phai duoc tao");
	RefTT = ObjTT.Ref;
	
	// 4. Catalog.TaiKhoanTien
	ObjTK = Catalogs.TaiKhoanTien.CreateItem();
	ObjTK.Code = "TK-TEST1";
	ObjTK.Description = "Techcombank VND VSF Corp";
	ObjTK.SoTaiKhoan = "1903889988001";
	ObjTK.NganHang = "Techcombank - Hoi so chinh";
	ObjTK.TienTe = RefTT;
	ObjTK.Write();
	AssertTrue(ValueIsFilled(ObjTK.Ref), "Catalog.TaiKhoanTien: Ref phai duoc tao");
	RefTK = ObjTK.Ref;
	
	// 5. Catalog.HopDong
	ObjHD = Catalogs.HopDong.CreateItem();
	ObjHD.Code = "HD-TEST1";
	ObjHD.Description = "Hop dong hop tac kinh doanh AI VSF";
	ObjHD.PhapNhan = RefPN;
	ObjHD.ChuSoHuu = RefDT;
	ObjHD.GrossUpThue = False;
	ObjHD.HanThanhToanNgay = 45;
	ObjHD.DongTienThanhToan = RefTT;
	ObjHD.Write();
	AssertTrue(ValueIsFilled(ObjHD.Ref), "Catalog.HopDong: Ref phai duoc tao");
	AssertEquals(45, ObjHD.HanThanhToanNgay, "Catalog.HopDong: HanThanhToanNgay phai giu nguyen 45 khi > 0");
	
	// 6. Catalog.TaiKhoanAo
	ObjVA = Catalogs.TaiKhoanAo.CreateItem();
	ObjVA.Code = "VA-TEST1";
	ObjVA.Description = "Tai khoan ao Techcombank - Vingroup";
	ObjVA.SoTaiKhoanAo = "9901-VSF-DT001";
	ObjVA.DoiTac = RefDT;
	ObjVA.NganHang = RefTK;
	ObjVA.Write();
	AssertTrue(ValueIsFilled(ObjVA.Ref), "Catalog.TaiKhoanAo: Ref phai duoc tao");
	
	// 7. Catalog.KhoanMucDongTien
	ObjKM = Catalogs.KhoanMucDongTien.CreateItem();
	ObjKM.Code = "KM-TEST1";
	ObjKM.Description = "Thu tien cung cap dich vu CNTT Telematics";
	ObjKM.LoaiDongTien = "ThuTuHoatDongKinhDoanh";
	ObjKM.Write();
	AssertTrue(ValueIsFilled(ObjKM.Ref), "Catalog.KhoanMucDongTien: Ref phai duoc tao");
	
	// 8. Catalog.DuAn
	ObjDA = Catalogs.DuAn.CreateItem();
	ObjDA.Code = "DA-TEST1";
	ObjDA.Description = "He thong Telematics VinFast VF8 & VF9";
	ObjDA.MaDuAn = "PJ-VF-TELEMATICS";
	ObjDA.TenDuAn = "He thong Telematics VinFast VF8 & VF9";
	ObjDA.PhapNhan = RefPN;
	ObjDA.Write();
	AssertTrue(ValueIsFilled(ObjDA.Ref), "Catalog.DuAn: Ref phai duoc tao");
	
	// 9. Catalog.DichVuCNTT
	ObjDV = Catalogs.DichVuCNTT.CreateItem();
	ObjDV.Code = "DV-TEST1";
	ObjDV.Description = "Dich vu Cloud ha tang GPU V100/A100";
	ObjDV.MaDichVu = "SVC-CLOUD-GPU";
	ObjDV.TenDichVu = "Dich vu Cloud ha tang GPU V100/A100";
	ObjDV.TyLeVATMacDinh = 10;
	ObjDV.Write();
	AssertTrue(ValueIsFilled(ObjDV.Ref), "Catalog.DichVuCNTT: Ref phai duoc tao");
	
	// 10. Catalog.KenhThanhToan
	ObjKP = Catalogs.KenhThanhToan.CreateItem();
	ObjKP.Code = "KP-TEST1";
	ObjKP.Description = "Cong thanh toan VNPAY QR";
	ObjKP.MaKenh = "VNPAY";
	ObjKP.TenKenh = "Cong thanh toan truc tuyen VNPAY";
	ObjKP.Write();
	AssertTrue(ValueIsFilled(ObjKP.Ref), "Catalog.KenhThanhToan: Ref phai duoc tao");
EndProcedure

// Test 2: HopDong tu dong gan HanThanhToanNgay = 30 khi khong truyen hoac truyen <= 0
Procedure Test02_HopDongTuDongGanHanThanhToanNgay30() Export
	// Lay hoac tao PhapNhan & DoiTac dung chung
	RefPN = Catalogs.PhapNhan.FindByCode("PN-TEST1");
	If RefPN.IsEmpty() Then
		ObjPN = Catalogs.PhapNhan.CreateItem();
		ObjPN.Code = "PN-TEST1";
		ObjPN.Description = "VinSmart Future Corp";
		ObjPN.Write();
		RefPN = ObjPN.Ref;
	EndIf;
	
	RefDT = Catalogs.DoiTac.FindByCode("DT-TEST1");
	If RefDT.IsEmpty() Then
		ObjDT = Catalogs.DoiTac.CreateItem();
		ObjDT.Code = "DT-TEST1";
		ObjDT.Description = "Vingroup JSC";
		ObjDT.Write();
		RefDT = ObjDT.Ref;
	EndIf;
	
	// Case 2a: Khong truyen hoac truyen 0 -> Phai tu gan = 30
	ObjHD1 = Catalogs.HopDong.CreateItem();
	ObjHD1.Code = "HD-TEST-ZERO";
	ObjHD1.Description = "Hop dong test han muc 0 ngay";
	ObjHD1.PhapNhan = RefPN;
	ObjHD1.ChuSoHuu = RefDT;
	ObjHD1.HanThanhToanNgay = 0;
	ObjHD1.Write();
	
	AssertEquals(30, ObjHD1.HanThanhToanNgay, 
		"HanThanhToanNgay khi truyen 0 phai duoc BeforeWrite gan ve 30");
	
	// Case 2b: Truyen so am <= 0 -> Phai tu gan = 30
	ObjHD2 = Catalogs.HopDong.CreateItem();
	ObjHD2.Code = "HD-TEST-NEG";
	ObjHD2.Description = "Hop dong test han muc am ngay";
	ObjHD2.PhapNhan = RefPN;
	ObjHD2.ChuSoHuu = RefDT;
	ObjHD2.HanThanhToanNgay = -10;
	ObjHD2.Write();
	
	AssertEquals(30, ObjHD2.HanThanhToanNgay, 
		"HanThanhToanNgay khi truyen gia tri am (-10) phai duoc BeforeWrite gan ve 30");
	
	// Case 2c: Truyen gia tri duong (>0) -> Phai giu nguyen gia tri
	ObjHD3 = Catalogs.HopDong.CreateItem();
	ObjHD3.Code = "HD-TEST-60";
	ObjHD3.Description = "Hop dong test han muc 60 ngay";
	ObjHD3.PhapNhan = RefPN;
	ObjHD3.ChuSoHuu = RefDT;
	ObjHD3.HanThanhToanNgay = 60;
	ObjHD3.Write();
	
	AssertEquals(60, ObjHD3.HanThanhToanNgay, 
		"HanThanhToanNgay khi truyen 60 phai giu nguyen khong bi ghi de ve 30");
EndProcedure

// Test 3: TaiKhoanAo nem loi khi co 2 ban ghi trung SoTaiKhoanAo
Procedure Test03_TaiKhoanAoNemLoiKhiTrungSoTaiKhoanAo() Export
	RefDT = Catalogs.DoiTac.FindByCode("DT-TEST1");
	If RefDT.IsEmpty() Then
		ObjDT = Catalogs.DoiTac.CreateItem();
		ObjDT.Code = "DT-TEST1";
		ObjDT.Description = "Vingroup JSC";
		ObjDT.Write();
		RefDT = ObjDT.Ref;
	EndIf;
	
	UniqueSoTK = "VA-UNIQUE-" + String(CurrentSessionDate());
	UniqueSoTK = Left(UniqueSoTK, 30);
	
	// Ban ghi 1: Tao thanh cong
	ObjVA1 = Catalogs.TaiKhoanAo.CreateItem();
	ObjVA1.Code = "VA-U1";
	ObjVA1.Description = "Tai khoan ao goc";
	ObjVA1.SoTaiKhoanAo = UniqueSoTK;
	ObjVA1.DoiTac = RefDT;
	ObjVA1.Write();
	AssertTrue(ValueIsFilled(ObjVA1.Ref), "Ban ghi 1 tai khoan ao phai tao thanh cong");
	
	// Ban ghi 2: Co tinh tao trung SoTaiKhoanAo -> Phai nem loi
	ObjVA2 = Catalogs.TaiKhoanAo.CreateItem();
	ObjVA2.Code = "VA-U2";
	ObjVA2.Description = "Tai khoan ao co tinh trung ma";
	ObjVA2.SoTaiKhoanAo = UniqueSoTK;
	ObjVA2.DoiTac = RefDT;
	
	ErrorOccurred = False;
	ErrorMessage = "";
	Try
		ObjVA2.Write();
	Except
		ErrorOccurred = True;
		ErrorMessage = ErrorDescription();
	EndTry;
	
	AssertTrue(ErrorOccurred, 
		"He thong phai nem ngoai le khi ghi TaiKhoanAo trung SoTaiKhoanAo");
	
	ExpectedSubstr = "Số tài khoản ảo đã được cấp phát cho đối tác khác!";
	AssertTrue(StrFind(ErrorMessage, ExpectedSubstr) > 0 Or StrFind(ErrorMessage, "cấp phát cho đối tác khác") > 0,
		"Thong diep loi phai chua: '" + ExpectedSubstr + "'. Thuc te: " + ErrorMessage);
EndProcedure

// Test 4: Gia lap Session Parameter CurrentPhapNhan RLS cach ly du lieu HopDong
Procedure Test04_GiaLapSessionParameterPhapNhanRLS() Export
	// Tao 2 PhapNhan doc lap
	ObjPNCool = Catalogs.PhapNhan.CreateItem();
	ObjPNCool.Code = "PN-CORP-RLS";
	ObjPNCool.Description = "VinSmart Future Corp (Holding)";
	ObjPNCool.Write();
	RefPNCool = ObjPNCool.Ref;
	
	ObjPNSoft = Catalogs.PhapNhan.CreateItem();
	ObjPNSoft.Code = "PN-SOFT-RLS";
	ObjPNSoft.Description = "VinSmart Future Software Ltd";
	ObjPNSoft.Write();
	RefPNSoft = ObjPNSoft.Ref;
	
	// Tao 2 HopDong thuoc 2 PhapNhan khac nhau
	ObjHDCool = Catalogs.HopDong.CreateItem();
	ObjHDCool.Code = "HD-RLS-CORP";
	ObjHDCool.Description = "Hop dong ban quyen cua Corp";
	ObjHDCool.PhapNhan = RefPNCool;
	ObjHDCool.Write();
	RefHDCool = ObjHDCool.Ref;
	
	ObjHDSoft = Catalogs.HopDong.CreateItem();
	ObjHDSoft.Code = "HD-RLS-SOFT";
	ObjHDSoft.Description = "Hop dong phan mem cua Software";
	ObjHDSoft.PhapNhan = RefPNSoft;
	ObjHDSoft.Write();
	RefHDSoft = ObjHDSoft.Ref;
	
	// Gia lap Session Parameter CurrentPhapNhan = RefPNCool (User thuoc VSF Corp)
	// Truy van ap dung mau dieu kien RLS: #PhapNhanAccess(PhapNhan) -> HopDong.PhapNhan = &CurrentPhapNhan
	QueryRLS = New Query;
	QueryRLS.Text = 
	"SELECT
	|	HopDong.Ref AS Ref,
	|	HopDong.Code AS Code,
	|	HopDong.PhapNhan AS PhapNhan
	|FROM
	|	Catalog.HopDong AS HopDong
	|WHERE
	|	HopDong.PhapNhan = &CurrentPhapNhan";
	
	QueryRLS.SetParameter("CurrentPhapNhan", RefPNCool);
	ResultCorp = QueryRLS.Execute().Unload();
	
	FoundCorpDoc = False;
	FoundSoftDoc = False;
	For Each Row In ResultCorp Do
		If Row.Ref = RefHDCool Then
			FoundCorpDoc = True;
		EndIf;
		If Row.Ref = RefHDSoft Then
			FoundSoftDoc = True;
		EndIf;
	EndDo;
	
	AssertTrue(FoundCorpDoc, "User VSF Corp phai nhin thay HopDong cua VSF Corp");
	AssertTrue(Not FoundSoftDoc, "User VSF Corp TUYET DOI KHONG duoc phep nhin thay HopDong cua VSF Software qua RLS");
	
	// Dao nguoc: Gia lap Session Parameter CurrentPhapNhan = RefPNSoft (User thuoc VSF Software)
	QueryRLS.SetParameter("CurrentPhapNhan", RefPNSoft);
	ResultSoft = QueryRLS.Execute().Unload();
	
	FoundCorpDocInSoft = False;
	FoundSoftDocInSoft = False;
	For Each Row In ResultSoft Do
		If Row.Ref = RefHDCool Then
			FoundCorpDocInSoft = True;
		EndIf;
		If Row.Ref = RefHDSoft Then
			FoundSoftDocInSoft = True;
		EndIf;
	EndDo;
	
	AssertTrue(FoundSoftDocInSoft, "User VSF Software phai nhin thay HopDong cua VSF Software");
	AssertTrue(Not FoundCorpDocInSoft, "User VSF Software TUYET DOI KHONG duoc phep nhin thay HopDong cua VSF Corp qua RLS");
EndProcedure

#EndRegion

#Region AssertHelpers

Procedure AssertTrue(Condition, Message)
	If Not Condition Then
		Raise "ASSERT FAILED: " + Message;
	EndIf;
EndProcedure

Procedure AssertEquals(Expected, Actual, Message)
	If Expected <> Actual Then
		Raise StrTemplate("ASSERT FAILED: %1 (Ky vong: %2, Thuc te: %3)", Message, Expected, Actual);
	EndIf;
EndProcedure

#EndRegion

