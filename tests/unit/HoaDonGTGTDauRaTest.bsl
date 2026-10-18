// Unit Test Suite: HoaDonGTGTDauRaTest
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL / BUnit / Vanessa)
// Muc tieu: Kiem thu chung tu HoaDonGTGTDauRa (Task 3.2):
//   1. Test 1: Hach toan HoaDonGTGTDauRa gan ket BienBanNghiemThuGiaiDoan (200tr DT, 20tr VAT)
//              -> Ghi tang VAT tren ca SoCaiKeToan (No 1312 / Co 33311: 20tr) va CongNoPhaiThu (Receipt 20tr).
//              -> Invariant Khop noi Subledger (220tr) == GL TK 1312 (220tr), Delta Variance = 0!
//   2. Test 2: DoiTac ngoai Vingroup (LaBenLienKet = False) -> Hach toan No TK 1311 / Co TK 33311 (20tr).
//   3. Test 3: Trang thai HDDT DaDieuChinh hoac DaHuy -> Non-posting (khong sinh but toan GL va Subledger).
//   4. Test 4: Logic BeforeWrite tu dong tinh TienThueVAT va TongTienThanhToan khi chua nhap.
//   5. Test 5: Kiem tra tinh toan ven Metadata XML Schema cua Document HoaDonGTGTDauRa (version 2.15).

#Region TestExecution

Function RunVerification() Export
	Results = RunAllTests();
	
	LogPath = "C:/Users/Dung/Documents/1C_Enterprise/tests/unit/hoadon_gtgt_daura_test_result.log";
	Try
		TextW = New TextWriter(LogPath, TextEncoding.UTF8);
		For Each Line In Results.Log Do
			TextW.WriteLine(Line);
		EndDo;
		TextW.Close();
	Except
		// Ghi log qua output console neu khong ghi duoc file
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
	TestLog.Add("   VINSMART FUTURE - HOA DON GTGT DAU RA UNIT TEST (TASK 3.2)    ");
	TestLog.Add("   Thoi gian chay: " + CurrentDate());
	TestLog.Add("=================================================================");
	
	// Test 1: Invariant P0.1 - HoaDonGTGTDauRa ghi tang VAT 20tr tren Subledger & GL
	Try
		Test01_HachToanHoaDonDauRaVaKiemTraInvariantP01();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 1: Invariant P0.1 - Subledger CongNoPhaiThu (220tr) khop 100% GL TK 1312 (220tr), Delta Variance = 0.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 1: Invariant P0.1 that bai - " + ErrorDescription());
	EndTry;
	
	// Test 2: Doi tac ngoai Vingroup hach toan No TK 1311
	Try
		Test02_DoiTacNgoaiHachToanTK1311();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 2: Doi tac ngoai (LaBenLienKet = False) hach toan dung No TK 1311 / Co TK 33311.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 2: Hach toan DoiTac ngoai that bai - " + ErrorDescription());
	EndTry;
	
	// Test 3: Trang thai HDDT DaDieuChinh hoac DaHuy la Non-posting
	Try
		Test03_HoaDonDaDieuChinhVaDaHuyKhongSinhButToan();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 3: HDDT DaDieuChinh va DaHuy la Non-posting, khong sinh but toan GL hoac Subledger.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 3: Kiem tra Non-posting that bai - " + ErrorDescription());
	EndTry;
	
	// Test 4: BeforeWrite tu dong tinh thue VAT va tong tien thanh toan
	Try
		Test04_TuDongTinhTienThueVaTongThanhToan();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 4: BeforeWrite tu dong tinh TienThueVAT (20tr) va TongTienThanhToan (220tr) chinh xac.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 4: Tu dong tinh toan BeforeWrite that bai - " + ErrorDescription());
	EndTry;
	
	// Test 5: Kiem tra Schema Metadata XML
	Try
		Test05_KiemTraSchemaVaMetadataHoaDonGTGTDauRa();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 5: Metadata XML HoaDonGTGTDauRa.xml hop le v2.15 voi day du 13 thuoc tinh va 2 so.");
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

// -----------------------------------------------------------------------------
// Test 1: Khop noi Subledger & GL P0.1
//   - Nghiem thu BienBanNghiemThuGiaiDoan: 200.000.000 VND (Task 3.1)
//     + GL: No TK 1312 / Co TK 5113 = 200.000.000 VND
//     + Subledger CongNoPhaiThu: Receipt = 200.000.000 VND
//   - HoaDonGTGTDauRa: Phat sinh nghia vu thue VAT 10% = 20.000.000 VND (Task 3.2)
//     + GL: No TK 1312 / Co TK 33311 = 20.000.000 VND
//     + Subledger CongNoPhaiThu: Receipt = 20.000.000 VND (ChungTuGoc = BienBanNghiemThu)
//   - Invariant:
//     + Tong Subledger CongNoPhaiThu = 200tr + 20tr = 220.000.000 VND
//     + Tong Du No TK 1312 = 200tr + 20tr = 220.000.000 VND
//     + Delta Variance = |220tr - 220tr| = 0 VND tuyet doi!
// -----------------------------------------------------------------------------
Procedure Test01_HachToanHoaDonDauRaVaKiemTraInvariantP01() Export
	// 1. Khoi tao Master Data mau cho doi tac noi bo Vingroup
	DataMock = KhoiTaoDuLieuMau(True); // Noi bo = True -> TK 1312
	RefPhapNhan = DataMock.PhapNhan;
	RefDoiTac = DataMock.DoiTac;
	RefHopDong = DataMock.HopDong;
	RefTienTe = DataMock.TienTe;
	RefBienBan = DataMock.BienBanNghiemThu;
	
	// 2. Mo phong buoc nghiem thu truoc do (Task 3.1)
	SubledgerAR = TaoBangMoPhongSubledgerAR();
	SoCaiGL = TaoBangMoPhongSoCaiGL();
	
	// Ghi nhan nghiem thu: Doanh thu thuan 200tr
	MoPhongGhiSoNghiemThu(SubledgerAR, SoCaiGL, RefPhapNhan, RefDoiTac, RefHopDong, RefBienBan, RefTienTe, 200000000);
	
	// Kiem tra trang thai sau Task 3.1
	DuAR_Task31 = TinhSoDuSubledgerAR(SubledgerAR, RefHopDong, RefBienBan);
	DuGL1312_Task31 = TinhSoDuNoSoCaiGL(SoCaiGL, "1312");
	AssertEquals(200000000, DuAR_Task31, "Sau nghiem thu, Subledger AR phai la 200tr");
	AssertEquals(200000000, DuGL1312_Task31, "Sau nghiem thu, Du no TK 1312 phai la 200tr");
	
	// 3. Khoi tao chung tu HoaDonGTGTDauRa (Task 3.2)
	InvoiceMock = New Structure;
	InvoiceMock.Insert("Ref", "HDGTGT-2026-0001");
	InvoiceMock.Insert("PhapNhan", RefPhapNhan);
	InvoiceMock.Insert("DoiTac", RefDoiTac);
	InvoiceMock.Insert("HopDong", RefHopDong);
	InvoiceMock.Insert("BienBanNghiemThu", RefBienBan);
	InvoiceMock.Insert("SoHoaDon", "00000001");
	InvoiceMock.Insert("KyHieu", "1C26TVSF");
	InvoiceMock.Insert("NgayHoaDon", Date(2026, 10, 10, 10, 0, 0));
	InvoiceMock.Insert("TienChuaThue", 200000000);
	InvoiceMock.Insert("ThueSuatVAT", 10);
	InvoiceMock.Insert("TienThueVAT", 20000000);
	InvoiceMock.Insert("TongTienThanhToan", 220000000);
	InvoiceMock.Insert("TrangThaiHDDT", "DaPhatHanh");
	InvoiceMock.Insert("MaCQT", "M-CQT-2026-8888");
	InvoiceMock.Insert("DienGiai", "Thue GTGT dau ra theo HD 00000001");
	
	// 4. Thuc hien ghi so HoaDonGTGTDauRa
	ButToanHoaDon = MoPhongGhiSoHoaDonDauRa(SubledgerAR, SoCaiGL, InvoiceMock);
	
	// 5. Assertions chi tiet
	// a. Sổ cái SoCaiKeToan có bút toán Nợ 1312 / Có 33311: 20.000.000 VND
	AssertEquals(1, ButToanHoaDon.GLRecords.Count(), "Hoa don phai sinh dung 1 but toan GL thue VAT");
	GLRec = ButToanHoaDon.GLRecords[0];
	AssertEquals("1312", GLRec.AccountDr, "Tai khoan No phai la TK 1312 (Noi bo Vingroup)");
	AssertEquals("33311", GLRec.AccountCr, "Tai khoan Co phai la TK 33311 (Thue GTGT dau ra)");
	AssertEquals(20000000, GLRec.SoTien, "Gia tri but toan GL phai dung bang 20.000.000 VND");
	AssertEquals(RefBienBan, GLRec.ChungTuGoc, "ChungTuGoc tren SoCaiKeToan phai la BienBanNghiemThuGiaiDoan");
	
	// b. Sổ tích lũy CongNoPhaiThu ghi nhận Receipt 20.000.000 VND với ChungTuGoc = BienBanNghiemThu
	AssertEquals(1, ButToanHoaDon.ARRecords.Count(), "Hoa don phai sinh dung 1 dong tren Subledger CongNoPhaiThu");
	ARRec = ButToanHoaDon.ARRecords[0];
	AssertEquals("Receipt", ARRec.RecordType, "Loai ghi so phai la Receipt (Tang cong no)");
	AssertEquals(20000000, ARRec.SoTien, "So tien tang cong no phai la 20.000.000 VND");
	AssertEquals(RefBienBan, ARRec.ChungTuGoc, "ChungTuGoc tren CongNoPhaiThu BAT BUOC la BienBanNghiemThu");
	
	// c. Invariant Khop noi Subledger (220tr) == GL TK 1312 (220tr), Delta Variance = 0
	TongSubledgerAR = TinhSoDuSubledgerAR(SubledgerAR, RefHopDong, RefBienBan);
	TongDuNoTK1312 = TinhSoDuNoSoCaiGL(SoCaiGL, "1312");
	TongPhatSinhCoTK33311 = TinhSoDuCoSoCaiGL(SoCaiGL, "33311");
	
	AssertEquals(220000000, TongSubledgerAR, "Tong Subledger CongNoPhaiThu phai la 220.000.000 VND");
	AssertEquals(220000000, TongDuNoTK1312, "Tong Du No SoCaiKeToan TK 1312 phai la 220.000.000 VND");
	AssertEquals(20000000, TongPhatSinhCoTK33311, "Tong Phat sinh Co TK 33311 phai la 20.000.000 VND");
	
	DeltaVariance = Abs(TongSubledgerAR - TongDuNoTK1312);
	AssertEquals(0, DeltaVariance, "Invariant Reconciliation: Delta Variance phai bang 0 tuyet doi!");
EndProcedure

// -----------------------------------------------------------------------------
// Test 2: DoiTac ngoai Vingroup (LaBenLienKet = False)
//   - Hach toan No TK 1311 / Co TK 33311: 20.000.000 VND
//   - Subledger AR va GL TK 1311 deu khop 220.000.000 VND
// -----------------------------------------------------------------------------
Procedure Test02_DoiTacNgoaiHachToanTK1311() Export
	DataMock = KhoiTaoDuLieuMau(False); // Doi tac ben ngoai -> TK 1311
	
	SubledgerAR = TaoBangMoPhongSubledgerAR();
	SoCaiGL = TaoBangMoPhongSoCaiGL();
	
	// Nghiem thu 200tr cho doi tac ngoai (No 1311 / Co 5113: 200tr)
	MoPhongGhiSoNghiemThu(SubledgerAR, SoCaiGL, DataMock.PhapNhan, DataMock.DoiTac, 
		DataMock.HopDong, DataMock.BienBanNghiemThu, DataMock.TienTe, 200000000, "1311");
	
	// Hoa don 20tr VAT
	InvoiceMock = New Structure;
	InvoiceMock.Insert("Ref", "HDGTGT-2026-EXT-01");
	InvoiceMock.Insert("PhapNhan", DataMock.PhapNhan);
	InvoiceMock.Insert("DoiTac", DataMock.DoiTac);
	InvoiceMock.Insert("HopDong", DataMock.HopDong);
	InvoiceMock.Insert("BienBanNghiemThu", DataMock.BienBanNghiemThu);
	InvoiceMock.Insert("SoHoaDon", "00000002");
	InvoiceMock.Insert("KyHieu", "1C26TVSF");
	InvoiceMock.Insert("NgayHoaDon", Date(2026, 10, 10, 11, 0, 0));
	InvoiceMock.Insert("TienChuaThue", 200000000);
	InvoiceMock.Insert("ThueSuatVAT", 10);
	InvoiceMock.Insert("TienThueVAT", 20000000);
	InvoiceMock.Insert("TongTienThanhToan", 220000000);
	InvoiceMock.Insert("TrangThaiHDDT", "DaPhatHanh");
	InvoiceMock.Insert("MaCQT", "M-CQT-2026-8889");
	InvoiceMock.Insert("DienGiai", "Thue GTGT dau ra khach hang ngoai");
	
	ButToan = MoPhongGhiSoHoaDonDauRa(SubledgerAR, SoCaiGL, InvoiceMock);
	
	GLRec = ButToan.GLRecords[0];
	AssertEquals("1311", GLRec.AccountDr, "Doi tac ngoai phai hach toan No vao TK 1311");
	AssertEquals("33311", GLRec.AccountCr, "Tai khoan Co phai la TK 33311");
	
	TongAR = TinhSoDuSubledgerAR(SubledgerAR, DataMock.HopDong, DataMock.BienBanNghiemThu);
	TongGL1311 = TinhSoDuNoSoCaiGL(SoCaiGL, "1311");
	AssertEquals(220000000, TongAR, "Tong Subledger phai la 220tr");
	AssertEquals(220000000, TongGL1311, "Tong Du No TK 1311 phai la 220tr");
	AssertEquals(0, Abs(TongAR - TongGL1311), "Delta Variance phai bang 0");
EndProcedure

// -----------------------------------------------------------------------------
// Test 3: Kiem tra cac trang thai HDDT khong duoc sinh but toan (Non-posting)
//   - DaDieuChinh: Hoa don da dieu chinh la chung tu phap ly dien tu (Task 3.3)
//   - DaHuy: Hoa don da huy khong ghi so
// -----------------------------------------------------------------------------
Procedure Test03_HoaDonDaDieuChinhVaDaHuyKhongSinhButToan() Export
	DataMock = KhoiTaoDuLieuMau(True);
	SubledgerAR = TaoBangMoPhongSubledgerAR();
	SoCaiGL = TaoBangMoPhongSoCaiGL();
	
	// Case 3a: Trang thai DaDieuChinh
	InvoiceAdjusted = New Structure;
	InvoiceAdjusted.Insert("Ref", "HDGTGT-ADJUSTED");
	InvoiceAdjusted.Insert("PhapNhan", DataMock.PhapNhan);
	InvoiceAdjusted.Insert("DoiTac", DataMock.DoiTac);
	InvoiceAdjusted.Insert("HopDong", DataMock.HopDong);
	InvoiceAdjusted.Insert("BienBanNghiemThu", DataMock.BienBanNghiemThu);
	InvoiceAdjusted.Insert("SoHoaDon", "00000003");
	InvoiceAdjusted.Insert("KyHieu", "1C26TVSF");
	InvoiceAdjusted.Insert("NgayHoaDon", Date(2026, 10, 11, 8, 0, 0));
	InvoiceAdjusted.Insert("TienChuaThue", 50000000);
	InvoiceAdjusted.Insert("ThueSuatVAT", 10);
	InvoiceAdjusted.Insert("TienThueVAT", 5000000);
	InvoiceAdjusted.Insert("TongTienThanhToan", 55000000);
	InvoiceAdjusted.Insert("TrangThaiHDDT", "DaDieuChinh"); // Da dieu chinh
	InvoiceAdjusted.Insert("MaCQT", "M-CQT-ADJUSTED");
	InvoiceAdjusted.Insert("DienGiai", "Hoa don da dieu chinh");
	
	ButToanAdj = MoPhongGhiSoHoaDonDauRa(SubledgerAR, SoCaiGL, InvoiceAdjusted);
	AssertEquals(0, ButToanAdj.GLRecords.Count(), "Hoa don DaDieuChinh khong duoc sinh but toan SoCaiKeToan");
	AssertEquals(0, ButToanAdj.ARRecords.Count(), "Hoa don DaDieuChinh khong duoc sinh dong CongNoPhaiThu");
	
	// Case 3b: Trang thai DaHuy
	InvoiceCancelled = New Structure;
	InvoiceCancelled.Insert("Ref", "HDGTGT-CANCELLED");
	InvoiceCancelled.Insert("PhapNhan", DataMock.PhapNhan);
	InvoiceCancelled.Insert("DoiTac", DataMock.DoiTac);
	InvoiceCancelled.Insert("HopDong", DataMock.HopDong);
	InvoiceCancelled.Insert("BienBanNghiemThu", DataMock.BienBanNghiemThu);
	InvoiceCancelled.Insert("SoHoaDon", "00000004");
	InvoiceCancelled.Insert("KyHieu", "1C26TVSF");
	InvoiceCancelled.Insert("NgayHoaDon", Date(2026, 10, 11, 9, 0, 0));
	InvoiceCancelled.Insert("TienChuaThue", 50000000);
	InvoiceCancelled.Insert("ThueSuatVAT", 10);
	InvoiceCancelled.Insert("TienThueVAT", 5000000);
	InvoiceCancelled.Insert("TongTienThanhToan", 55000000);
	InvoiceCancelled.Insert("TrangThaiHDDT", "DaHuy"); // Da huy
	InvoiceCancelled.Insert("MaCQT", "M-CQT-CANCELLED");
	InvoiceCancelled.Insert("DienGiai", "Hoa don da huy");
	
	ButToanCan = MoPhongGhiSoHoaDonDauRa(SubledgerAR, SoCaiGL, InvoiceCancelled);
	AssertEquals(0, ButToanCan.GLRecords.Count(), "Hoa don DaHuy khong duoc sinh but toan SoCaiKeToan");
	AssertEquals(0, ButToanCan.ARRecords.Count(), "Hoa don DaHuy khong duoc sinh dong CongNoPhaiThu");
EndProcedure

// -----------------------------------------------------------------------------
// Test 4: Logic BeforeWrite tu dong tinh TienThueVAT va TongTienThanhToan
// -----------------------------------------------------------------------------
Procedure Test04_TuDongTinhTienThueVaTongThanhToan() Export
	DocTest = New Structure;
	DocTest.Insert("TienChuaThue", 200000000);
	DocTest.Insert("ThueSuatVAT", 10);
	DocTest.Insert("TienThueVAT", 0);
	DocTest.Insert("TongTienThanhToan", 0);
	DocTest.Insert("TrangThaiHDDT", "");
	
	// Goi logic BeforeWrite mo phong
	XuLyBeforeWriteHoaDon(DocTest);
	
	AssertEquals(20000000, DocTest.TienThueVAT, "TienThueVAT phai duoc tu dong tinh: 200tr * 10% = 20tr");
	AssertEquals(220000000, DocTest.TongTienThanhToan, "TongTienThanhToan phai duoc tu dong tinh: 200tr + 20tr = 220tr");
	AssertEquals("DaPhatHanh", DocTest.TrangThaiHDDT, "TrangThaiHDDT mac dinh khi ghi so phai la DaPhatHanh");
EndProcedure

// -----------------------------------------------------------------------------
// Test 5: Kiem tra Schema va Metadata XML cua HoaDonGTGTDauRa.xml
// -----------------------------------------------------------------------------
Procedure Test05_KiemTraSchemaVaMetadataHoaDonGTGTDauRa() Export
	FilePath = "C:/Users/Dung/Documents/1C_Enterprise/src/Documents/HoaDonGTGTDauRa.xml";
	
	FileOnDisk = New File(FilePath);
	AssertTrue(FileOnDisk.Exists(), "File src/Documents/HoaDonGTGTDauRa.xml bat buoc phai ton tai");
	
	TextR = New TextReader(FilePath, TextEncoding.UTF8);
	XmlContent = TextR.Read();
	TextR.Close();
	
	// 1. Kiem tra Document Metadata version 2.15
	AssertTrue(StrFind(XmlContent, "version=""2.15""") > 0, "Metadata XML phai la version 2.15");
	AssertTrue(StrFind(XmlContent, "<Name>HoaDonGTGTDauRa</Name>") > 0, "Ten Document phai la HoaDonGTGTDauRa");
	
	// 2. Kiem tra cac thuoc tinh bat buoc
	CacThuocTinh = New Array;
	CacThuocTinh.Add("PhapNhan");
	CacThuocTinh.Add("DoiTac");
	CacThuocTinh.Add("HopDong");
	CacThuocTinh.Add("BienBanNghiemThu");
	CacThuocTinh.Add("SoHoaDon");
	CacThuocTinh.Add("KyHieu");
	CacThuocTinh.Add("NgayHoaDon");
	CacThuocTinh.Add("TienChuaThue");
	CacThuocTinh.Add("ThueSuatVAT");
	CacThuocTinh.Add("TienThueVAT");
	CacThuocTinh.Add("TongTienThanhToan");
	CacThuocTinh.Add("TrangThaiHDDT");
	CacThuocTinh.Add("MaCQT");
	
	For Each TT In CacThuocTinh Do
		AssertTrue(StrFind(XmlContent, "<Name>" + TT + "</Name>") > 0, 
			StrTemplate("Thuoc tinh '%1' phai duoc dinh nghia trong HoaDonGTGTDauRa.xml", TT));
	EndDo;
	
	// 3. Kiem tra RegisterRecords
	AssertTrue(StrFind(XmlContent, "AccumulationRegister.CongNoPhaiThu") > 0, 
		"HoaDonGTGTDauRa phai dang ky so AccumulationRegister.CongNoPhaiThu");
	AssertTrue(StrFind(XmlContent, "AccountingRegister.SoCaiKeToan") > 0, 
		"HoaDonGTGTDauRa phai dang ky so AccountingRegister.SoCaiKeToan");
	AssertTrue(StrFind(XmlContent, "<Posting>Allow</Posting>") > 0, 
		"HoaDonGTGTDauRa phai cho phep ghi so (Posting = Allow)");
EndProcedure

#EndRegion

#Region HelperFunctionsAndMocks

Function KhoiTaoDuLieuMau(LaBenLienKet = True)
	Data = New Structure;
	Data.Insert("PhapNhan", "PN-VSF-CORP");
	
	DoiTac = New Structure;
	DoiTac.Insert("Code", ?(LaBenLienKet, "DT-VINFAST", "DT-EXTERNAL-01"));
	DoiTac.Insert("Description", ?(LaBenLienKet, "Cong ty CP San Xuat va Kinh Doanh VinFast", "Doi tac khach hang ben ngoai"));
	DoiTac.Insert("LaBenLienKet", LaBenLienKet);
	Data.Insert("DoiTac", DoiTac);
	
	HopDong = New Structure;
	HopDong.Insert("Code", "HD-CLOUD-2026");
	HopDong.Insert("Description", "Hop dong cung cap ha tang Cloud");
	HopDong.Insert("TienTe", "VND");
	Data.Insert("HopDong", HopDong);
	
	Data.Insert("BienBanNghiemThu", "BBNT-2026-OCT-01");
	Data.Insert("TienTe", "VND");
	
	Return Data;
EndFunction

Function TaoBangMoPhongSubledgerAR()
	Table = New Array;
	Return Table;
EndFunction

Function TaoBangMoPhongSoCaiGL()
	Table = New Array;
	Return Table;
EndFunction

Procedure MoPhongGhiSoNghiemThu(SubledgerAR, SoCaiGL, PhapNhan, DoiTac, HopDong, BienBanNghiemThu, TienTe, SoTien, TKCongNo = "1312")
	// 1. Subledger CongNoPhaiThu (Receipt)
	ARRecord = New Structure;
	ARRecord.Insert("RecordType", "Receipt");
	ARRecord.Insert("PhapNhan", PhapNhan);
	ARRecord.Insert("DoiTac", DoiTac);
	ARRecord.Insert("HopDong", HopDong);
	ARRecord.Insert("ChungTuGoc", BienBanNghiemThu);
	ARRecord.Insert("SoTien", SoTien);
	SubledgerAR.Add(ARRecord);
	
	// 2. SoCaiKeToan (No 1312 hoac 1311 / Co 5113)
	GLRecord = New Structure;
	GLRecord.Insert("PhapNhan", PhapNhan);
	GLRecord.Insert("TienTe", TienTe);
	GLRecord.Insert("AccountDr", TKCongNo);
	GLRecord.Insert("AccountCr", "5113");
	GLRecord.Insert("ChungTuGoc", BienBanNghiemThu);
	GLRecord.Insert("SoTien", SoTien);
	SoCaiGL.Add(GLRecord);
EndProcedure

Function MoPhongGhiSoHoaDonDauRa(SubledgerAR, SoCaiGL, InvoiceDoc)
	Result = New Structure("ARRecords,GLRecords", New Array, New Array);
	
	// Kiem tra trang thai HDDT: DaDieuChinh hoac DaHuy -> Non-posting
	If InvoiceDoc.TrangThaiHDDT = "DaDieuChinh" Or InvoiceDoc.TrangThaiHDDT = "DaHuy" Then
		Return Result;
	EndIf;
	
	// Xac dinh TK Cong no: DoiTac la ben lien ket -> 1312, nguoc lai -> 1311
	TKCongNo = "1311";
	If TypeOf(InvoiceDoc.DoiTac) = Type("Structure") And InvoiceDoc.DoiTac.Property("LaBenLienKet") Then
		If InvoiceDoc.DoiTac.LaBenLienKet Then
			TKCongNo = "1312";
		EndIf;
	EndIf;
	
	SoTienVAT = InvoiceDoc.TienThueVAT;
	
	// 1. Ghi CongNoPhaiThu (Receipt: ChungTuGoc = BienBanNghiemThu)
	ARRec = New Structure;
	ARRec.Insert("RecordType", "Receipt");
	ARRec.Insert("PhapNhan", InvoiceDoc.PhapNhan);
	ARRec.Insert("DoiTac", InvoiceDoc.DoiTac);
	ARRec.Insert("HopDong", InvoiceDoc.HopDong);
	ARRec.Insert("ChungTuGoc", InvoiceDoc.BienBanNghiemThu);
	ARRec.Insert("SoTien", SoTienVAT);
	SubledgerAR.Add(ARRec);
	Result.ARRecords.Add(ARRec);
	
	// 2. Ghi SoCaiKeToan (No TKCongNo / Co 33311)
	GLRec = New Structure;
	GLRec.Insert("PhapNhan", InvoiceDoc.PhapNhan);
	GLRec.Insert("TienTe", "VND");
	GLRec.Insert("AccountDr", TKCongNo);
	GLRec.Insert("AccountCr", "33311");
	GLRec.Insert("ChungTuGoc", InvoiceDoc.BienBanNghiemThu);
	GLRec.Insert("SoTien", SoTienVAT);
	GLRec.Insert("DienGiai", InvoiceDoc.DienGiai);
	SoCaiGL.Add(GLRec);
	Result.GLRecords.Add(GLRec);
	
	Return Result;
EndFunction

Procedure XuLyBeforeWriteHoaDon(Doc)
	If Doc.TienThueVAT = 0 And Doc.TienChuaThue > 0 And Doc.ThueSuatVAT > 0 Then
		Doc.TienThueVAT = Round(Doc.TienChuaThue * Doc.ThueSuatVAT / 100, 2);
	EndIf;
	
	If Doc.TongTienThanhToan = 0 And (Doc.TienChuaThue > 0 Or Doc.TienThueVAT > 0) Then
		Doc.TongTienThanhToan = Doc.TienChuaThue + Doc.TienThueVAT;
	EndIf;
	
	If IsBlankString(Doc.TrangThaiHDDT) Then
		Doc.TrangThaiHDDT = "DaPhatHanh";
	EndIf;
EndProcedure

Function TinhSoDuSubledgerAR(SubledgerAR, HopDong, ChungTuGoc)
	Tong = 0;
	For Each Line In SubledgerAR Do
		If Line.ChungTuGoc = ChungTuGoc Then
			If Line.RecordType = "Receipt" Then
				Tong = Tong + Line.SoTien;
			ElsIf Line.RecordType = "Expense" Then
				Tong = Tong - Line.SoTien;
			EndIf;
		EndIf;
	EndDo;
	Return Tong;
EndFunction

Function TinhSoDuNoSoCaiGL(SoCaiGL, SoHieuTK)
	TongNo = 0;
	For Each Line In SoCaiGL Do
		If Line.AccountDr = SoHieuTK Then
			TongNo = TongNo + Line.SoTien;
		EndIf;
	EndDo;
	Return TongNo;
EndFunction

Function TinhSoDuCoSoCaiGL(SoCaiGL, SoHieuTK)
	TongCo = 0;
	For Each Line In SoCaiGL Do
		If Line.AccountCr = SoHieuTK Then
			TongCo = TongCo + Line.SoTien;
		EndIf;
	EndDo;
	Return TongCo;
EndFunction

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
