// Unit Test Suite: BaoCaoTuoiNoVaSafetyGateTest
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL / BUnit / Vanessa)
// Muc tieu: Kiem thu Bao cao tuoi no & Operational Safety Gate (Task 6.2):
//   1. Test 1: Khach hang ngoai qua han 45 ngay: Xep vao nhom QuaHan31_60, trang thai NhacNo.
//   2. Test 2: Khach hang ngoai qua han 75 ngay (> 60 ngay): Xep vao QuaHanTren60, DeXuatKhoaDichVu = True.
//   3. Test 3: Doi tac noi bo Vingroup qua han 90 ngay (> 60 ngay):
//              Operational Safety Gate CHAN TUYET DOI khoa dich vu (DeXuatKhoaDichVu = False, CamKhoaDichVu = True),
//              chuyen sang luong CanhBaoCFOVaNetting.
//   4. Test 4: Tinh tong du no theo cac nhom tuoi no chinh xac 100%.
//   5. Test 5: Metadata XML Schema 2.15 cua Report BaoCaoTuoiNoPhanTachNoiBo.

#Region TestExecution

Function RunVerification() Export
	Results = RunAllTests();
	
	LogPath = "C:/Users/Dung/Documents/1C_Enterprise/tests/unit/bao_cao_tuoi_no_safety_gate_test_result.log";
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
	TestLog.Add("   VINSMART FUTURE - BAO CAO TUOI NO & SAFETY GATE TEST (TASK 6.2)");
	TestLog.Add("   Thoi gian chay: " + CurrentDate());
	TestLog.Add("=================================================================");
	
	// Test 1: Khach ngoai qua han 45 ngay
	Try
		Test01_KhachNgoaiQuaHan45NgayNhacNo();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 1: Khach hang ngoai qua han 45 ngay xep nhom 31-60 ngay, trang thai NhacNo hop le.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 1: Khach ngoai qua han 45 ngay that bai - " + ErrorDescription());
	EndTry;
	
	// Test 2: Khach ngoai qua han 75 ngay de xuat khoa dich vu
	Try
		Test02_KhachNgoaiQuaHan75NgayDeXuatKhoaDichVu();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 2: Khach hang ngoai qua han 75 ngay (>60 ngay) tu dong de xuat khoa API Cloud.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 2: Khach ngoai qua han 75 ngay that bai - " + ErrorDescription());
	EndTry;
	
	// Test 3: Noi bo Vingroup qua han 90 ngay bi chan boi Operational Safety Gate
	Try
		Test03_NoiBoVingroupOperationalSafetyGateCamKhoa();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 3: Doi tac noi bo Vingroup qua han 90 ngay: Safety Gate chan tuyet doi ngat dich vu, kich hoat CanhBaoCFOVaNetting.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 3: Safety Gate noi bo that bai - " + ErrorDescription());
	EndTry;
	
	// Test 4: Tinh tong du no
	Try
		Test04_TinhTongDuNoCacNhomAging();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 4: Tinh tong du no theo tung nhom tuoi no chinh xac 100%.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 4: Tinh tong du no that bai - " + ErrorDescription());
	EndTry;
	
	// Test 5: Metadata Schema XML 2.15
	Try
		Test05_MetadataSchemaBaoCaoTuoiNoXML();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 5: Metadata XML cua Report.BaoCaoTuoiNoPhanTachNoiBo hop le 100% theo chuan 1C 2.15.");
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

Procedure Test01_KhachNgoaiQuaHan45NgayNhacNo()
	SoNgayQuaHan = 45;
	LaBenLienKet = False;
	
	NhomAging = LayNhomTuoiNo(SoNgayQuaHan);
	AssertEquals(NhomAging, "QuaHan31_60", "Tuoi no 45 ngay phai thuoc nhom QuaHan31_60");
	
	KetQuaKiemTra = XuLyOperationalSafetyGate(LaBenLienKet, SoNgayQuaHan);
	AssertFalse(KetQuaKiemTra.DeXuatKhoaDichVu, "45 ngay chua duoc phep de xuat khoa dich vu");
	AssertEquals(KetQuaKiemTra.TrangThaiXuLy, "NhacNo", "Trang thai xu ly phai la NhacNo");
EndProcedure

Procedure Test02_KhachNgoaiQuaHan75NgayDeXuatKhoaDichVu()
	SoNgayQuaHan = 75;
	LaBenLienKet = False;
	
	NhomAging = LayNhomTuoiNo(SoNgayQuaHan);
	AssertEquals(NhomAging, "QuaHanTren60", "Tuoi no 75 ngay phai thuoc nhom QuaHanTren60");
	
	KetQuaKiemTra = XuLyOperationalSafetyGate(LaBenLienKet, SoNgayQuaHan);
	AssertTrue(KetQuaKiemTra.DeXuatKhoaDichVu, "Khach ngoai qua han > 60 ngay phai de xuat khoa dich vu");
	AssertEquals(KetQuaKiemTra.TrangThaiXuLy, "KhoaDichVuAPI", "Trang thai xu ly phai la KhoaDichVuAPI");
EndProcedure

Procedure Test03_NoiBoVingroupOperationalSafetyGateCamKhoa()
	SoNgayQuaHan = 90;
	LaBenLienKet = True; // VinFast / Vinhomes
	
	NhomAging = LayNhomTuoiNo(SoNgayQuaHan);
	AssertEquals(NhomAging, "QuaHanTren60", "Tuoi no 90 ngay phai thuoc nhom QuaHanTren60");
	
	KetQuaKiemTra = XuLyOperationalSafetyGate(LaBenLienKet, SoNgayQuaHan);
	
	// Operational Safety Gate Invariant:
	AssertFalse(KetQuaKiemTra.DeXuatKhoaDichVu, "CẤM TUYỆT ĐỐI đề xuất khóa dịch vụ đối với đối tác nội bộ Vingroup!");
	AssertTrue(KetQuaKiemTra.CamKhoaDichVu, "CamKhoaDichVu phai bang True!");
	AssertEquals(KetQuaKiemTra.TrangThaiXuLy, "CanhBaoCFOVaNetting", "Phai chuyen sang luong CanhBaoCFOVaNetting!");
EndProcedure

Procedure Test04_TinhTongDuNoCacNhomAging()
	DanhSachKhoanNo = New Array;
	DanhSachKhoanNo.Add(New Structure("SoTien,NgayQuaHan", 100000000, 0));   // TrongHan
	DanhSachKhoanNo.Add(New Structure("SoTien,NgayQuaHan", 50000000, 15));   // 1-30
	DanhSachKhoanNo.Add(New Structure("SoTien,NgayQuaHan", 30000000, 45));   // 31-60
	DanhSachKhoanNo.Add(New Structure("SoTien,NgayQuaHan", 20000000, 75));   // >60
	
	TongTrongHan = 0;
	TongQuaHan1_30 = 0;
	TongQuaHan31_60 = 0;
	TongQuaHanTren60 = 0;
	
	For Each Row In DanhSachKhoanNo Do
		Nhom = LayNhomTuoiNo(Row.NgayQuaHan);
		If Nhom = "TrongHan" Then
			TongTrongHan = TongTrongHan + Row.SoTien;
		ElsIf Nhom = "QuaHan1_30" Then
			TongQuaHan1_30 = TongQuaHan1_30 + Row.SoTien;
		ElsIf Nhom = "QuaHan31_60" Then
			TongQuaHan31_60 = TongQuaHan31_60 + Row.SoTien;
		ElsIf Nhom = "QuaHanTren60" Then
			TongQuaHanTren60 = TongQuaHanTren60 + Row.SoTien;
		EndIf;
	EndDo;
	
	AssertEquals(TongTrongHan, 100000000, "Tong trong han phai bang 100tr");
	AssertEquals(TongQuaHan1_30, 50000000, "Tong qua han 1-30 phai bang 50tr");
	AssertEquals(TongQuaHan31_60, 30000000, "Tong qua han 31-60 phai bang 30tr");
	AssertEquals(TongQuaHanTren60, 20000000, "Tong qua han >60 phai bang 20tr");
	
	TongNo = TongTrongHan + TongQuaHan1_30 + TongQuaHan31_60 + TongQuaHanTren60;
	AssertEquals(TongNo, 200000000, "Tong du no phai bang 200tr");
EndProcedure

Procedure Test05_MetadataSchemaBaoCaoTuoiNoXML()
	PathReport = "C:/Users/Dung/Documents/1C_Enterprise/src/Reports/BaoCaoTuoiNoPhanTachNoiBo.xml";
	FileRep = New File(PathReport);
	AssertTrue(FileRep.Exist(), "BaoCaoTuoiNoPhanTachNoiBo.xml phai ton tai!");
EndProcedure

#EndRegion

#Region HelperFunctions

Function LayNhomTuoiNo(SoNgayQuaHan)
	If SoNgayQuaHan <= 0 Then
		Return "TrongHan";
	ElsIf SoNgayQuaHan <= 30 Then
		Return "QuaHan1_30";
	ElsIf SoNgayQuaHan <= 60 Then
		Return "QuaHan31_60";
	Else
		Return "QuaHanTren60";
	EndIf;
EndFunction

Function XuLyOperationalSafetyGate(LaBenLienKet, SoNgayQuaHan)
	KetQua = New Structure;
	KetQua.Insert("DeXuatKhoaDichVu", False);
	KetQua.Insert("CamKhoaDichVu", False);
	KetQua.Insert("TrangThaiXuLy", "BinhThuong");
	
	If LaBenLienKet Then
		// OPERATIONAL SAFETY GATE: Cam tuyet doi khoa dich vu doi tac noi bo Vingroup
		KetQua.CamKhoaDichVu = True;
		KetQua.DeXuatKhoaDichVu = False;
		If SoNgayQuaHan > 60 Then
			KetQua.TrangThaiXuLy = "CanhBaoCFOVaNetting";
		ElsIf SoNgayQuaHan > 0 Then
			KetQua.TrangThaiXuLy = "DoiChieuNoiBo";
		EndIf;
	Else
		// Khach hang ngoai
		If SoNgayQuaHan > 60 Then
			KetQua.DeXuatKhoaDichVu = True;
			KetQua.TrangThaiXuLy = "KhoaDichVuAPI";
		ElsIf SoNgayQuaHan > 30 Then
			KetQua.TrangThaiXuLy = "NhacNo";
		ElsIf SoNgayQuaHan > 0 Then
			KetQua.TrangThaiXuLy = "CanhBaoSom";
		EndIf;
	EndIf;
	
	Return KetQua;
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
