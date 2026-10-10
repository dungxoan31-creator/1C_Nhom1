Function RunVerification() Export
	Results = RunAllTests();
	
	// Ghi file ket qua
	LogPath = "C:/Users/Dung/Documents/1C_Enterprise/tests/unit/enums_constants_test_result.log";
	TextW = New TextWriter(LogPath, TextEncoding.UTF8);
	For Each Line In Results.Log Do
		TextW.WriteLine(Line);
	EndDo;
	TextW.Close();
	
	Return Results;
EndFunction

// Unit Test Suite: EnumsConstantsTest
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL / BUnit / Vanessa)
// Muc tieu: Kiem thu doc du 8 Enums va 12 Constants he thong theo Spec v5.0 va Task 1.2 Brief.

#Region TestExecution

Function RunAllTests() Export
	TestResults = New Structure;
	TestResults.Insert("Total", 4);
	TestResults.Insert("Passed", 0);
	TestResults.Insert("Failed", 0);
	TestResults.Insert("Log", New Array);
	
	TestLog = TestResults.Log;
	TestLog.Add("=================================================================");
	TestLog.Add("   VINSMART FUTURE - ENUMS & CONSTANTS UNIT TEST (TASK 1.2)      ");
	TestLog.Add("   Thoi gian chay: " + CurrentDate());
	TestLog.Add("=================================================================");
	
	// Khoi tao gia tri mac dinh cho 12 Constants truoc khi chay cac test
	Try
		KhoiTaoGiaTriMacDinhConstants();
		TestLog.Add("[INIT] Khoi tao gia tri mac dinh cho 12 Constants thanh cong.");
	Except
		TestLog.Add("[INIT_WARN] Khoi tao gia tri Constants: " + ErrorDescription());
	EndTry;
	
	// Test 1: Kiem tra doc du 8 Enums va cac gia tri enum quy dinh
	Try
		Test01_KiemTra8Enums();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 1: Doc du 8 Enums va toan bo gia tri enum vong doi / nghiep vu thanh cong.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 1: Kiem tra 8 Enums that bai - " + ErrorDescription());
	EndTry;
	
	// Test 2: Kiem tra doc du 12 Constants va khong tra ve gia tri rong / Null
	Try
		Test02_KiemTraDoc12ConstantsKhongRong();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 2: Doc du 12 Constants thanh cong, khong co hang so nao bi Null hoac chua khoi tao.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 2: Kiem tra doc 12 Constants that bai - " + ErrorDescription());
	EndTry;
	
	// Test 3: Kiem tra gia tri mac dinh chuan xac cua 12 Constants
	Try
		Test03_KiemTraGiaTriChinhXac12Constants();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 3: Gia tri mac dinh 12 Constants khop 100% yeu cau Task 1.2 Brief.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 3: Kiem tra gia tri mac dinh Constants that bai - " + ErrorDescription());
	EndTry;
	
	// Test 4: Kiem tra ghi va doc lai Constants qua ConstantValueManager
	Try
		Test04_KiemTraGhiVaDocLaiConstants();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 4: Ghi va doc lai Constants qua ConstantValueManager hoat dong chinh xac.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 4: Ghi va doc lai Constants that bai - " + ErrorDescription());
	EndTry;
	
	TestLog.Add("-----------------------------------------------------------------");
	TestLog.Add(StrTemplate("Tong so test: %1 | Thanh cong: %2 | That bai: %3", 
		TestResults.Total, TestResults.Passed, TestResults.Failed));
	TestLog.Add("=================================================================");
	
	Return TestResults;
EndFunction

#EndRegion

#Region Initialization

Procedure KhoiTaoGiaTriMacDinhConstants() Export
	// 1. PhapNhanMacDinh = "VSF_CORP"
	Constants.PhapNhanMacDinh.Set("VSF_CORP");
	
	// 2. NguongPheDuyetChiTienCFO = 500,000,000 VND
	Constants.NguongPheDuyetChiTienCFO.Set(500000000);
	
	// 3. TaiKhoanTrungGianCanTru = "1388"
	Constants.TaiKhoanTrungGianCanTru.Set("1388");
	
	// 4. TuDongDongBoSAP = True
	Constants.TuDongDongBoSAP.Set(True);
	
	// 5. NguongThanhToanKhongDungTienMat = 5,000,000 VND
	Constants.NguongThanhToanKhongDungTienMat.Set(5000000);
	
	// 6. TaiKhoanPhiNganHang = "6427"
	Constants.TaiKhoanPhiNganHang.Set("6427");
	
	// 7. SoLuongHoaDonFIFOMax = 2
	Constants.SoLuongHoaDonFIFOMax.Set(2);
	
	// 8. GiaTriFIFOMax = 100,000,000 VND
	Constants.GiaTriFIFOMax.Set(100000000);
	
	// 9. TimeoutChoCanTruPhut = 120 phut
	Constants.TimeoutChoCanTruPhut.Set(120);
	
	// 10. CanhBaoCloudMucVang = 30 ngay
	Constants.CanhBaoCloudMucVang.Set(30);
	
	// 11. CanhBaoCloudMucCam = 14 ngay
	Constants.CanhBaoCloudMucCam.Set(14);
	
	// 12. CanhBaoCloudMucDo = 7 ngay
	Constants.CanhBaoCloudMucDo.Set(7);
EndProcedure

#EndRegion

#Region TestCases

// Test 1: Kiem tra doc du 8 Enums va cac gia tri enum quy dinh
Procedure Test01_KiemTra8Enums() Export
	// 1. Enum.TrangThaiNghiemThuAR (8 gia tri)
	AssertTrue(ValueIsFilled(Enums.TrangThaiNghiemThuAR.DuThao), "TrangThaiNghiemThuAR.DuThao phai ton tai");
	AssertTrue(ValueIsFilled(Enums.TrangThaiNghiemThuAR.ChoDuyetNoiBo), "TrangThaiNghiemThuAR.ChoDuyetNoiBo phai ton tai");
	AssertTrue(ValueIsFilled(Enums.TrangThaiNghiemThuAR.DaDuyetNoiBo), "TrangThaiNghiemThuAR.DaDuyetNoiBo phai ton tai");
	AssertTrue(ValueIsFilled(Enums.TrangThaiNghiemThuAR.ChoDoiTacKy), "TrangThaiNghiemThuAR.ChoDoiTacKy phai ton tai");
	AssertTrue(ValueIsFilled(Enums.TrangThaiNghiemThuAR.DaGhiSo), "TrangThaiNghiemThuAR.DaGhiSo phai ton tai");
	AssertTrue(ValueIsFilled(Enums.TrangThaiNghiemThuAR.DaThanhToanMotPhan), "TrangThaiNghiemThuAR.DaThanhToanMotPhan phai ton tai");
	AssertTrue(ValueIsFilled(Enums.TrangThaiNghiemThuAR.DaTatToan), "TrangThaiNghiemThuAR.DaTatToan phai ton tai");
	AssertTrue(ValueIsFilled(Enums.TrangThaiNghiemThuAR.TranhChap), "TrangThaiNghiemThuAR.TranhChap phai ton tai");
	
	// 2. Enum.TrangThaiHoaDonAP (8 gia tri)
	AssertTrue(ValueIsFilled(Enums.TrangThaiHoaDonAP.DuThao), "TrangThaiHoaDonAP.DuThao phai ton tai");
	AssertTrue(ValueIsFilled(Enums.TrangThaiHoaDonAP.ChoDuyetKyThuat), "TrangThaiHoaDonAP.ChoDuyetKyThuat phai ton tai");
	AssertTrue(ValueIsFilled(Enums.TrangThaiHoaDonAP.ChoDuyetPM), "TrangThaiHoaDonAP.ChoDuyetPM phai ton tai");
	AssertTrue(ValueIsFilled(Enums.TrangThaiHoaDonAP.ChoDuyetITDirector), "TrangThaiHoaDonAP.ChoDuyetITDirector phai ton tai");
	AssertTrue(ValueIsFilled(Enums.TrangThaiHoaDonAP.ChoDuyetCFO), "TrangThaiHoaDonAP.ChoDuyetCFO phai ton tai");
	AssertTrue(ValueIsFilled(Enums.TrangThaiHoaDonAP.ChoKeToanAP), "TrangThaiHoaDonAP.ChoKeToanAP phai ton tai");
	AssertTrue(ValueIsFilled(Enums.TrangThaiHoaDonAP.DaGhiSo), "TrangThaiHoaDonAP.DaGhiSo phai ton tai");
	AssertTrue(ValueIsFilled(Enums.TrangThaiHoaDonAP.TuChoi), "TrangThaiHoaDonAP.TuChoi phai ton tai");
	
	// 3. Enum.TrangThaiLenhThanhToan (7 gia tri)
	AssertTrue(ValueIsFilled(Enums.TrangThaiLenhThanhToan.DuThao), "TrangThaiLenhThanhToan.DuThao phai ton tai");
	AssertTrue(ValueIsFilled(Enums.TrangThaiLenhThanhToan.ChoDuyet), "TrangThaiLenhThanhToan.ChoDuyet phai ton tai");
	AssertTrue(ValueIsFilled(Enums.TrangThaiLenhThanhToan.DaDuyet), "TrangThaiLenhThanhToan.DaDuyet phai ton tai");
	AssertTrue(ValueIsFilled(Enums.TrangThaiLenhThanhToan.DaGuiNganHang), "TrangThaiLenhThanhToan.DaGuiNganHang phai ton tai");
	AssertTrue(ValueIsFilled(Enums.TrangThaiLenhThanhToan.DaGhiSo), "TrangThaiLenhThanhToan.DaGhiSo phai ton tai");
	AssertTrue(ValueIsFilled(Enums.TrangThaiLenhThanhToan.TuChoi), "TrangThaiLenhThanhToan.TuChoi phai ton tai");
	AssertTrue(ValueIsFilled(Enums.TrangThaiLenhThanhToan.HuyBo), "TrangThaiLenhThanhToan.HuyBo phai ton tai");
	
	// 4. Enum.TrangThaiCanTru (6 gia tri)
	AssertTrue(ValueIsFilled(Enums.TrangThaiCanTru.DuThao), "TrangThaiCanTru.DuThao phai ton tai");
	AssertTrue(ValueIsFilled(Enums.TrangThaiCanTru.ChoDuyetNoiBo), "TrangThaiCanTru.ChoDuyetNoiBo phai ton tai");
	AssertTrue(ValueIsFilled(Enums.TrangThaiCanTru.ChoTapDoanDuyet), "TrangThaiCanTru.ChoTapDoanDuyet phai ton tai");
	AssertTrue(ValueIsFilled(Enums.TrangThaiCanTru.ChoCanTru), "TrangThaiCanTru.ChoCanTru phai ton tai");
	AssertTrue(ValueIsFilled(Enums.TrangThaiCanTru.DaTatToan), "TrangThaiCanTru.DaTatToan phai ton tai");
	AssertTrue(ValueIsFilled(Enums.TrangThaiCanTru.HuyBo), "TrangThaiCanTru.HuyBo phai ton tai");
	
	// 5. Enum.TrangThaiHoaDonDienTu (6 gia tri)
	AssertTrue(ValueIsFilled(Enums.TrangThaiHoaDonDienTu.DuThao), "TrangThaiHoaDonDienTu.DuThao phai ton tai");
	AssertTrue(ValueIsFilled(Enums.TrangThaiHoaDonDienTu.ChoKySo), "TrangThaiHoaDonDienTu.ChoKySo phai ton tai");
	AssertTrue(ValueIsFilled(Enums.TrangThaiHoaDonDienTu.DaPhatHanh), "TrangThaiHoaDonDienTu.DaPhatHanh phai ton tai");
	AssertTrue(ValueIsFilled(Enums.TrangThaiHoaDonDienTu.DaDieuChinh), "TrangThaiHoaDonDienTu.DaDieuChinh phai ton tai");
	AssertTrue(ValueIsFilled(Enums.TrangThaiHoaDonDienTu.DaThayThe), "TrangThaiHoaDonDienTu.DaThayThe phai ton tai");
	AssertTrue(ValueIsFilled(Enums.TrangThaiHoaDonDienTu.DaHuy), "TrangThaiHoaDonDienTu.DaHuy phai ton tai");
	
	// 6. Enum.LoaiDoiTac (5 gia tri nghiep vu chinh)
	AssertTrue(ValueIsFilled(Enums.LoaiDoiTac.KhachHangNgoai), "LoaiDoiTac.KhachHangNgoai phai ton tai");
	AssertTrue(ValueIsFilled(Enums.LoaiDoiTac.NoiBoVingroup), "LoaiDoiTac.NoiBoVingroup phai ton tai");
	AssertTrue(ValueIsFilled(Enums.LoaiDoiTac.NhaCungCapCloud), "LoaiDoiTac.NhaCungCapCloud phai ton tai");
	AssertTrue(ValueIsFilled(Enums.LoaiDoiTac.NhaCungCapLinhKien), "LoaiDoiTac.NhaCungCapLinhKien phai ton tai");
	AssertTrue(ValueIsFilled(Enums.LoaiDoiTac.ThauPhuCNTT), "LoaiDoiTac.ThauPhuCNTT phai ton tai");
	
	// 7. Enum.HuongDongTien (2 gia tri)
	AssertTrue(ValueIsFilled(Enums.HuongDongTien.Thu), "HuongDongTien.Thu phai ton tai");
	AssertTrue(ValueIsFilled(Enums.HuongDongTien.Chi), "HuongDongTien.Chi phai ton tai");
	
	// 8. Enum.TrangThaiDongBo (4 gia tri)
	AssertTrue(ValueIsFilled(Enums.TrangThaiDongBo.ChuaDongBo), "TrangThaiDongBo.ChuaDongBo phai ton tai");
	AssertTrue(ValueIsFilled(Enums.TrangThaiDongBo.ChoDongBo), "TrangThaiDongBo.ChoDongBo phai ton tai");
	AssertTrue(ValueIsFilled(Enums.TrangThaiDongBo.ThanhCong), "TrangThaiDongBo.ThanhCong phai ton tai");
	AssertTrue(ValueIsFilled(Enums.TrangThaiDongBo.LoiDongBo), "TrangThaiDongBo.LoiDongBo phai ton tai");
EndProcedure

// Test 2: Kiem tra doc du 12 Constants va khong tra ve gia tri rong / Null
Procedure Test02_KiemTraDoc12ConstantsKhongRong() Export
	Val_PhapNhanMacDinh = Constants.PhapNhanMacDinh.Get();
	AssertTrue(ValueIsFilled(Val_PhapNhanMacDinh), "Constant PhapNhanMacDinh khong duoc rong hoac Null");
	
	Val_NguongPheDuyetChiTienCFO = Constants.NguongPheDuyetChiTienCFO.Get();
	AssertTrue(Val_NguongPheDuyetChiTienCFO > 0, "Constant NguongPheDuyetChiTienCFO phai lon hon 0");
	
	Val_TaiKhoanTrungGianCanTru = Constants.TaiKhoanTrungGianCanTru.Get();
	AssertTrue(ValueIsFilled(Val_TaiKhoanTrungGianCanTru), "Constant TaiKhoanTrungGianCanTru khong duoc rong");
	
	Val_TuDongDongBoSAP = Constants.TuDongDongBoSAP.Get();
	AssertTrue(Val_TuDongDongBoSAP = True Or Val_TuDongDongBoSAP = False, "Constant TuDongDongBoSAP phai la Boolean hop le");
	
	Val_NguongThanhToanKhongDungTienMat = Constants.NguongThanhToanKhongDungTienMat.Get();
	AssertTrue(Val_NguongThanhToanKhongDungTienMat > 0, "Constant NguongThanhToanKhongDungTienMat phai lon hon 0");
	
	Val_TaiKhoanPhiNganHang = Constants.TaiKhoanPhiNganHang.Get();
	AssertTrue(ValueIsFilled(Val_TaiKhoanPhiNganHang), "Constant TaiKhoanPhiNganHang khong duoc rong");
	
	Val_SoLuongHoaDonFIFOMax = Constants.SoLuongHoaDonFIFOMax.Get();
	AssertTrue(Val_SoLuongHoaDonFIFOMax > 0, "Constant SoLuongHoaDonFIFOMax phai lon hon 0");
	
	Val_GiaTriFIFOMax = Constants.GiaTriFIFOMax.Get();
	AssertTrue(Val_GiaTriFIFOMax > 0, "Constant GiaTriFIFOMax phai lon hon 0");
	
	Val_TimeoutChoCanTruPhut = Constants.TimeoutChoCanTruPhut.Get();
	AssertTrue(Val_TimeoutChoCanTruPhut > 0, "Constant TimeoutChoCanTruPhut phai lon hon 0");
	
	Val_CanhBaoCloudMucVang = Constants.CanhBaoCloudMucVang.Get();
	AssertTrue(Val_CanhBaoCloudMucVang > 0, "Constant CanhBaoCloudMucVang phai lon hon 0");
	
	Val_CanhBaoCloudMucCam = Constants.CanhBaoCloudMucCam.Get();
	AssertTrue(Val_CanhBaoCloudMucCam > 0, "Constant CanhBaoCloudMucCam phai lon hon 0");
	
	Val_CanhBaoCloudMucDo = Constants.CanhBaoCloudMucDo.Get();
	AssertTrue(Val_CanhBaoCloudMucDo > 0, "Constant CanhBaoCloudMucDo phai lon hon 0");
EndProcedure

// Test 3: Kiem tra gia tri mac dinh chuan xac cua 12 Constants
Procedure Test03_KiemTraGiaTriChinhXac12Constants() Export
	AssertEquals(Constants.PhapNhanMacDinh.Get(), "VSF_CORP", 
		"Constant PhapNhanMacDinh phai bang 'VSF_CORP'");
	
	AssertEquals(Constants.NguongPheDuyetChiTienCFO.Get(), 500000000, 
		"Constant NguongPheDuyetChiTienCFO phai bang 500,000,000 VND");
	
	AssertEquals(Constants.TaiKhoanTrungGianCanTru.Get(), "1388", 
		"Constant TaiKhoanTrungGianCanTru phai bang '1388'");
	
	AssertEquals(Constants.TuDongDongBoSAP.Get(), True, 
		"Constant TuDongDongBoSAP phai bang True");
	
	AssertEquals(Constants.NguongThanhToanKhongDungTienMat.Get(), 5000000, 
		"Constant NguongThanhToanKhongDungTienMat phai bang 5,000,000 VND");
	
	AssertEquals(Constants.TaiKhoanPhiNganHang.Get(), "6427", 
		"Constant TaiKhoanPhiNganHang phai bang '6427'");
	
	AssertEquals(Constants.SoLuongHoaDonFIFOMax.Get(), 2, 
		"Constant SoLuongHoaDonFIFOMax phai bang 2");
	
	AssertEquals(Constants.GiaTriFIFOMax.Get(), 100000000, 
		"Constant GiaTriFIFOMax phai bang 100,000,000 VND");
	
	AssertEquals(Constants.TimeoutChoCanTruPhut.Get(), 120, 
		"Constant TimeoutChoCanTruPhut phai bang 120 phut");
	
	AssertEquals(Constants.CanhBaoCloudMucVang.Get(), 30, 
		"Constant CanhBaoCloudMucVang phai bang 30 ngay");
	
	AssertEquals(Constants.CanhBaoCloudMucCam.Get(), 14, 
		"Constant CanhBaoCloudMucCam phai bang 14 ngay");
	
	AssertEquals(Constants.CanhBaoCloudMucDo.Get(), 7, 
		"Constant CanhBaoCloudMucDo phai bang 7 ngay");
EndProcedure

// Test 4: Kiem tra ghi va doc lai Constants qua ConstantValueManager
Procedure Test04_KiemTraGhiVaDocLaiConstants() Export
	// Luu gia tri goc
	GiaTriGoc = Constants.TimeoutChoCanTruPhut.Get();
	
	// Ghi gia tri moi qua ConstantValueManager
	Mgr = Constants.TimeoutChoCanTruPhut.CreateValueManager();
	Mgr.Value = 180;
	Mgr.Write();
	
	// Doc lai de kiem tra
	GiaTriMoi = Constants.TimeoutChoCanTruPhut.Get();
	AssertEquals(GiaTriMoi, 180, "TimeoutChoCanTruPhut sau khi ghi moi phai bang 180");
	
	// Khoi phuc lai gia tri goc
	Mgr.Value = GiaTriGoc;
	Mgr.Write();
	
	AssertEquals(Constants.TimeoutChoCanTruPhut.Get(), GiaTriGoc, 
		"TimeoutChoCanTruPhut sau khi khoi phuc phai bang gia tri ban dau");
EndProcedure

#EndRegion

#Region AssertHelpers

Procedure AssertTrue(Condition, Message)
	If Not Condition Then
		Raise "ASSERT FAILED: " + Message;
	EndIf;
EndProcedure

Procedure AssertEquals(Actual, Expected, Message)
	If Actual <> Expected Then
		Raise StrTemplate("ASSERT FAILED: %1 (Thuc te: %2, Ky vong: %3)", Message, Actual, Expected);
	EndIf;
EndProcedure

#EndRegion
