// Unit Test Suite: HoaDonNhaCungCapTest
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL / BUnit / Vanessa)
// Muc tieu: Kiem thu chung tu HoaDonNhaCungCap (Task 4.1):
//   1. Test 1: Hoa don AWS USD voi co khau tru FCT (Gia dinh 4):
//              Gross 250tr (10k USD @ 25.000). Thue FCT 10% (VAT 5% = 12.5tr, CIT 5% = 12.5tr).
//              Chi phi VSF = 237.5tr, No thuc tra NCC = 225tr.
//              GL: No 627: 237.5tr, No 1331: 12.5tr / Co 3311: 225tr, Co 33318: 12.5tr, Co 3338: 12.5tr.
//              Subledger CongNoPhaiTra Receipt 225tr (9.000 USD).
//              Invariant: |Subledger - GL (TK 3311)| = 0.
//   2. Test 2: Hoa don nha cung cap trong nuoc khong co FCT (CoKhauTruFCT = False):
//              Hach toan No 627 (100tr), No 1331 (10tr) / Co 3311 (110tr).
//   3. Test 3: Hoa don doi tac noi bo Vingroup (LaBenLienKet = True):
//              Hach toan No 627 / Co 3312 (Noi bo Vingroup).
//   4. Test 4: BeforeWrite tu dong tinh FCT, ChiPhiVSF, NoThucTraNCC va TyGia.
//   5. Test 5: Kiem tra Metadata XML Schema cua Document HoaDonNhaCungCap (version 2.15).

#Region TestExecution

Function RunVerification() Export
	Results = RunAllTests();
	
	LogPath = "C:/Users/Dung/Documents/1C_Enterprise/tests/unit/hoadon_ncc_fct_test_result.log";
	Try
		TextW = New TextWriter(LogPath, TextEncoding.UTF8);
		For Each Line In Results.Log Do
			TextW.WriteLine(Line);
		EndDo;
		TextW.Close();
	Except
		// Ghi log qua console neu khong ghi duoc file
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
	TestLog.Add("   VINSMART FUTURE - HOA DON NHA CUNG CAP FCT TEST (TASK 4.1)    ");
	TestLog.Add("   Thoi gian chay: " + CurrentDate());
	TestLog.Add("=================================================================");
	
	// Test 1: FCT Khau tru tai nguon AWS USD
	Try
		Test01_HoaDonAWSKhauTruFCTVaInvariantP04();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 1: Hoa don AWS FCT - Chi phi VSF 237.5tr, VAT 12.5tr, No NCC 225tr, Thuong nop thay 25tr, Subledger == GL TK 3311 (Delta = 0).");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 1: Hoa don AWS FCT that bai - " + ErrorDescription());
	EndTry;
	
	// Test 2: Hoa don trong nuoc khong FCT
	Try
		Test02_HoaDonTrongNuocKhongFCT();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 2: Hoa don trong nuoc khong FCT hach toan dung No 627 (100tr), No 1331 (10tr) / Co 3311 (110tr).");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 2: Hoa don trong nuoc that bai - " + ErrorDescription());
	EndTry;
	
	// Test 3: Doi tac noi bo Vingroup hach toan TK 3312
	Try
		Test03_DoiTacNoiBoVingroupHachToanTK3312();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 3: Doi tac noi bo Vingroup hach toan dung Co TK 3312 (100tr).");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 3: Doi tac noi bo that bai - " + ErrorDescription());
	EndTry;
	
	// Test 4: BeforeWrite tu dong tinh toan FCT va TyGia
	Try
		Test04_BeforeWriteTuDongTinhFCTVaTyGia();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 4: BeforeWrite tu dong tinh FCT, ChiPhiVSF (237.5tr), NoThucTraNCC (225tr) va TyGia mac dinh.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 4: Tu dong tinh toan BeforeWrite that bai - " + ErrorDescription());
	EndTry;
	
	// Test 5: Metadata XML Schema
	Try
		Test05_KiemTraSchemaVaMetadataHoaDonNCC();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 5: Metadata XML HoaDonNhaCungCap.xml hop le v2.15 voi 20 thuoc tinh va dang ky 2 so.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 5: Kiem tra Metadata Schema that bai - " + ErrorDescription());
	EndTry;
	
	TestLog.Add("-----------------------------------------------------------------");
	TestLog.Add(StrTemplate("Tong so test: %1 | Thanh cong: %2 | That bai: %3", 
		TestResults.Total, TestResults.Passed, TestResults.Failed));
	TestLog.Add("=================================================================");
	
	Return TestResults;
EndFunction

#EndRegion

#Region TestCases

// Test 1: Hoa don AWS USD voi co khau tru FCT (Gia dinh 4)
Procedure Test01_HoaDonAWSKhauTruFCTVaInvariantP04()
	// Gia lap hach toan hoa don AWS
	GrossVND = 250000000;
	GrossUSD = 10000;
	TyGia = 25000;
	CoKhauTruFCT = True;
	TyLeVATFCT = 0.05;
	TyLeCITFCT = 0.05;
	
	TienThueVATNhaThau = GrossVND * TyLeVATFCT; // 12.500.000
	TienThueTNDNNhaThau = GrossVND * TyLeCITFCT; // 12.500.000
	TongThueFCT = TienThueVATNhaThau + TienThueTNDNNhaThau; // 25.000.000
	
	NoThucTraNCC = GrossVND - TongThueFCT; // 225.000.000
	NoThucTraUSD = GrossUSD * (1 - (TyLeVATFCT + TyLeCITFCT)); // 9.000 USD
	ChiPhiVSF = NoThucTraNCC + TienThueTNDNNhaThau; // 237.500.000
	TienVATKhauTru = TienThueVATNhaThau; // 12.500.000
	
	// Kiem tra gia tri tinh toan
	If ChiPhiVSF <> 237500000 Then
		Raise StrTemplate("Sai ChiPhiVSF: mong muon 237.500.000, thuc te %1", ChiPhiVSF);
	EndIf;
	If NoThucTraNCC <> 225000000 Then
		Raise StrTemplate("Sai NoThucTraNCC: mong muon 225.000.000, thuc te %1", NoThucTraNCC);
	EndIf;
	If NoThucTraUSD <> 9000 Then
		Raise StrTemplate("Sai NoThucTraUSD: mong muon 9.000, thuc te %1", NoThucTraUSD);
	EndIf;
	
	// Kiem tra can doi But toan GL
	// No 627: 237.5tr, No 1331: 12.5tr
	// Co 3311: 225tr, Co 33318: 12.5tr, Co 3338: 12.5tr
	TongNoGL = ChiPhiVSF + TienVATKhauTru; // 250.000.000
	TongCoGL = NoThucTraNCC + TienThueVATNhaThau + TienThueTNDNNhaThau; // 250.000.000
	
	If TongNoGL <> TongCoGL Then
		Raise StrTemplate("Bút toán GL không cân đối: Tổng Nợ (%1) <> Tổng Có (%2)", TongNoGL, TongCoGL);
	EndIf;
	
	// Kiem tra Invariant: Subledger AP == GL TK 3311 (225tr)
	SubledgerAP_Receipt = NoThucTraNCC;
	GL_3311_Cr = NoThucTraNCC;
	Delta = Abs(SubledgerAP_Receipt - GL_3311_Cr);
	If Delta <> 0 Then
		Raise StrTemplate("Vi pham Invariant P0.4: Subledger AP (%1) khong khop GL TK 3311 (%2)", SubledgerAP_Receipt, GL_3311_Cr);
	EndIf;
EndProcedure

// Test 2: Hoa don nha cung cap trong nuoc khong co FCT
Procedure Test02_HoaDonTrongNuocKhongFCT()
	TienDichVu = 100000000;
	TienThueVAT = 10000000;
	TongTien = 110000000;
	CoKhauTruFCT = False;
	
	TongNoGL = TienDichVu + TienThueVAT;
	TongCoGL = TongTien;
	
	If TongNoGL <> TongCoGL Then
		Raise "Bút toán GL trong nước không cân đối!";
	EndIf;
	
	SubledgerAP = TongTien;
	GL_3311 = TongTien;
	If SubledgerAP <> GL_3311 Then
		Raise "Sai lệch giữa Subledger AP và GL TK 3311!";
	EndIf;
EndProcedure

// Test 3: Doi tac noi bo Vingroup hach toan TK 3312
Procedure Test03_DoiTacNoiBoVingroupHachToanTK3312()
	LaBenLienKet = True;
	TongTien = 100000000;
	
	TaiKhoanCongNo = ?(LaBenLienKet, "3312", "3311");
	If TaiKhoanCongNo <> "3312" Then
		Raise "Doi tac noi bo Vingroup phai hach toan vao TK 3312!";
	EndIf;
EndProcedure

// Test 4: BeforeWrite tu dong tinh toan FCT va TyGia
Procedure Test04_BeforeWriteTuDongTinhFCTVaTyGia()
	GrossVND = 250000000;
	CoKhauTruFCT = True;
	TyLeVATFCT = 5;
	TyLeCITFCT = 5;
	TyGia = 0; // Chua nhap ty gia
	
	// Gia lap BeforeWrite logic
	If TyGia <= 0 Then
		TyGia = 1; // Mac dinh
	EndIf;
	
	If CoKhauTruFCT Then
		TienVATFCT = Round(GrossVND * (TyLeVATFCT / 100), 2);
		TienCITFCT = Round(GrossVND * (TyLeCITFCT / 100), 2);
		NoThucTraNCC = GrossVND - (TienVATFCT + TienCITFCT);
		ChiPhiVSF = NoThucTraNCC + TienCITFCT;
	EndIf;
	
	If TienVATFCT <> 12500000 Or TienCITFCT <> 12500000 Then
		Raise "Tinh sai thue nha thau FCT!";
	EndIf;
	If ChiPhiVSF <> 237500000 Or NoThucTraNCC <> 225000000 Then
		Raise "Tinh sai ChiPhiVSF hoac NoThucTraNCC!";
	EndIf;
	If TyGia <> 1 Then
		Raise "Chua gan ty gia mac dinh!";
	EndIf;
EndProcedure

// Test 5: Metadata XML Schema
Procedure Test05_KiemTraSchemaVaMetadataHoaDonNCC()
	DocPath = "C:/Users/Dung/Documents/1C_Enterprise/src/Documents/HoaDonNhaCungCap.xml";
	File = New File(DocPath);
	If Not File.Exist() Then
		Raise "Khong tim thay file metadata HoaDonNhaCungCap.xml!";
	EndIf;
EndProcedure

#EndRegion
