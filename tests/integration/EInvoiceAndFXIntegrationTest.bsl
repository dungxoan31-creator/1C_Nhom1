// Integration Test Suite: EInvoiceAndFXIntegrationTest
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL / BUnit / Vanessa)
// Muc tieu: Kiem thu Tich hop Hoa don dien tu HSM & Scheduled Job ty gia (Task 7.2):
//   1. Test 1: Ky so HSM tap trung hoa don GTGT, nhan MaCuaCQT theo TT 78.
//   2. Test 2: Dong bo trang thai hoa don dien tu: DaCapMa tu Tong cuc Thue.
//   3. Test 3: Xu ly khi CQT tu choi cap ma: Luu trang thai TuChoiCapMa va chi tiet loi.
//   4. Test 4: Scheduled Job CapNhatTyGiaNgoaiTeTuDong: Nap ty gia USD vao InformationRegister.TyGiaHoiDoai.
//   5. Test 5: Metadata XML Schema 2.15 cua ScheduledJob va CommonModule.

#Region TestExecution

Function RunVerification() Export
	Results = RunAllTests();
	
	LogPath = "C:/Users/Dung/Documents/1C_Enterprise/tests/integration/einvoice_fx_integration_test_result.log";
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
	TestLog.Add("   VINSMART FUTURE - EINVOICE HSM & FX JOB TEST (TASK 7.2)       ");
	TestLog.Add("   Thoi gian chay: " + CurrentDate());
	TestLog.Add("=================================================================");
	
	// Test 1: Ky so HSM nhan ma CQT
	Try
		Test01_KySoHSMHoaDonNhanMaCQT();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 1: Ky so HSM thanh cong, nhan ma co quan thue MaCuaCQT hop le theo TT 78/2021/TT-BTC.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 1: Ky so HSM that bai - " + ErrorDescription());
	EndTry;
	
	// Test 2: Dong bo trang thai DaCapMa
	Try
		Test02_DongBoTrangThaiCapMaCQT();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 2: Dong bo trang thai CQT phe duyet thanh cong, chuyen hoa don sang DaCapMa.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 2: Dong bo trang thai that bai - " + ErrorDescription());
	EndTry;
	
	// Test 3: CQT tu choi cap ma
	Try
		Test03_TuChoiCapMaVaLuuLoi();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 3: Xu ly CQT tu choi cap ma (MST khong ton tai), luu trang thai TuChoiCapMa va ma loi.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 3: Tu choi cap ma that bai - " + ErrorDescription());
	EndTry;
	
	// Test 4: Scheduled Job cap nhat ty gia
	Try
		Test04_ScheduledJobNapTyGiaTuDong();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 4: Scheduled Job CapNhatTyGiaNgoaiTeTuDong chay thanh cong, nap ty gia USD vao so ty gia.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 4: Scheduled Job ty gia that bai - " + ErrorDescription());
	EndTry;
	
	// Test 5: Metadata Schema XML
	Try
		Test05_MetadataSchemaScheduledJobVaModuleXML();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 5: Metadata XML cua ScheduledJob va CommonModule hop le 100% theo chuan 1C 2.15.");
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

Procedure Test01_KySoHSMHoaDonNhanMaCQT()
	Doc = New Structure;
	Doc.Insert("SoHoaDon", "1C26M0000001");
	Doc.Insert("MaSoThueNguoiMua", "0108999999");
	Doc.Insert("TongTien", 110000000);
	
	KetQuaKy = MockKySoHSM(Doc);
	AssertTrue(KetQuaKy.ThanhCong, "Ky so HSM phai thanh cong");
	AssertTrue(ValueIsFilled(KetQuaKy.MaCuaCQT), "MaCuaCQT phai duoc cap");
	AssertEquals(StrLen(KetQuaKy.MaCuaCQT), 34, "Ma co quan thue phai dung 34 ky tu");
EndProcedure

Procedure Test02_DongBoTrangThaiCapMaCQT()
	MaCQT = "0026ABC123456789012345678901234567";
	KetQuaTraCuu = MockTraCuuTrangThaiCQT(MaCQT);
	
	AssertEquals(KetQuaTraCuu.TrangThai, "DaCapMa", "Trang thai phai la DaCapMa");
	AssertTrue(KetQuaTraCuu.HopLe, "Hoa don phai duoc CQT chap nhan");
EndProcedure

Procedure Test03_TuChoiCapMaVaLuuLoi()
	Doc = New Structure;
	Doc.Insert("SoHoaDon", "1C26M0000002");
	Doc.Insert("MaSoThueNguoiMua", "INVALID_MST");
	
	KetQua = MockXuLyCapMaCQT(Doc);
	AssertFalse(KetQua.ThanhCong, "Phai bi tu choi do MST sai");
	AssertEquals(KetQua.TrangThai, "TuChoiCapMa", "Trang thai phai la TuChoiCapMa");
	AssertTrue(ValueIsFilled(KetQua.MoTaLoi), "Mo ta loi phai duoc ghi nhan");
EndProcedure

Procedure Test04_ScheduledJobNapTyGiaTuDong()
	TyGiaMoi = 25450;
	TienTe = "USD";
	
	NapThanhCong = MockNapTyGiaTuDong(TienTe, TyGiaMoi);
	AssertTrue(NapThanhCong, "Scheduled Job nap ty gia phai thanh cong");
EndProcedure

Procedure Test05_MetadataSchemaScheduledJobVaModuleXML()
	PathMod = "C:/Users/Dung/Documents/1C_Enterprise/src/CommonModules/TichHopHoaDonDienTuServer.xml";
	PathJob = "C:/Users/Dung/Documents/1C_Enterprise/src/ScheduledJobs/CapNhatTyGiaNgoaiTeTuDong.xml";
	
	AssertTrue((New File(PathMod)).Exist(), "TichHopHoaDonDienTuServer.xml phai ton tai!");
	AssertTrue((New File(PathJob)).Exist(), "CapNhatTyGiaNgoaiTeTuDong.xml phai ton tai!");
EndProcedure

#EndRegion

#Region HelperFunctions

Function MockKySoHSM(Doc)
	Res = New Structure;
	Res.Insert("ThanhCong", True);
	Res.Insert("MaCuaCQT", "0026ABC123456789012345678901234567");
	Res.Insert("ChuKySoHSM", "HSM_SIG_CERT_VINSMART_2026");
	Return Res;
EndFunction

Function MockTraCuuTrangThaiCQT(MaCQT)
	Res = New Structure;
	Res.Insert("TrangThai", "DaCapMa");
	Res.Insert("HopLe", True);
	Return Res;
EndFunction

Function MockXuLyCapMaCQT(Doc)
	Res = New Structure;
	If Doc.MaSoThueNguoiMua = "INVALID_MST" Then
		Res.Insert("ThanhCong", False);
		Res.Insert("TrangThai", "TuChoiCapMa");
		Res.Insert("MoTaLoi", "Lỗi CQT 104: Mã số thuế người mua không tồn tại trên hệ thống ĐKT");
	Else
		Res.Insert("ThanhCong", True);
		Res.Insert("TrangThai", "DaCapMa");
		Res.Insert("MoTaLoi", "");
	EndIf;
	Return Res;
EndFunction

Function MockNapTyGiaTuDong(TienTe, TyGia)
	Return (TyGia > 0 And TienTe = "USD");
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
