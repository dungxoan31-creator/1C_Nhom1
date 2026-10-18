// Unit Test Suite: TranhChapSauGhiSoTest
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL / BUnit / Vanessa)
// Muc tieu: Kiem thu xu ly tranh chap sau ghi so & dieu chinh giam cong no (Task 3.3):
//   1. Test 1: Invariant P0.3 - Luong tranh chap SLA giam 20tr (da gom VAT) sau khi da nghiem thu va xuat HD.
//              - BB Nghiem thu: 200tr (No 1312 / Co 5113, Subledger Receipt 200tr).
//              - Hoa don GTGT: 20tr VAT (No 1312 / Co 33311, Subledger Receipt 20tr). Tong no: 220tr.
//              - Phat sinh bien ban thoa thuan giam 20tr SLA (da gom VAT).
//              - Hoa don dieu chinh DaDieuChinh: Non-posting (0 GL, 0 Subledger).
//              - DieuChinhCongNo: Ghi so duy nhat:
//                + GL: No 5113: 18.181.818, No 33311: 1.818.182 / Co 1312: 20.000.000 VND.
//                + Subledger CongNoPhaiThu: Expense 20.000.000 VND.
//              - Regression Assert P0.3: Tong Co TK 1312 dung 20tr, khong bi ghi trung 21.818.182 VND!
//              - Du no Subledger con lai: 200.000.000 VND.
//              - Du no GL TK 1312 con lai: 200.000.000 VND.
//              - Delta Variance = 0 VND tuyet doi!
//   2. Test 2: Dieu chinh cong no doi tac ngoai tap doan (LaBenLienKet = False) -> Co TK 1311: 20tr.
//   3. Test 3: Anti-Double-Crediting & Invariant HoaDonGTGTDauRa DaDieuChinh la Non-posting.
//   4. Test 4: Logic BeforeWrite tu dong boc tach Doanh thu thuan giam (18.181.818) va VAT giam (1.818.182).
//   5. Test 5: Kiem tra tinh toan ven Metadata XML Schema cua Document DieuChinhCongNo (version 2.15).

#Region TestExecution

Function RunVerification() Export
	Results = RunAllTests();
	
	LogPath = "C:/Users/Dung/Documents/1C_Enterprise/tests/unit/tranh_chap_sau_ghi_so_test_result.log";
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
	TestLog.Add("   VINSMART FUTURE - TRANH CHAP SAU GHI SO UNIT TEST (TASK 3.3)  ");
	TestLog.Add("   Thoi gian chay: " + CurrentDate());
	TestLog.Add("=================================================================");
	
	// Test 1: Invariant P0.3 - DieuChinhCongNo ghi so duy nhat, giam 20tr (No 5113, No 33311 / Co 1312)
	Try
		Test01_DieuChinhCongNoGhiSoDuyNhatVaKiemTraInvariantP03();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 1: Invariant P0.3 - DieuChinhCongNo ghi so duy nhat, Subledger (200tr) == GL 1312 (200tr), Delta = 0.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 1: Invariant P0.3 that bai - " + ErrorDescription());
	EndTry;
	
	// Test 2: Doi tac ngoai tap doan ghi Co TK 1311
	Try
		Test02_DoiTacNgoaiHachToanCoTK1311();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 2: Doi tac ngoai (LaBenLienKet = False) hach toan dung Co TK 1311 (20tr), du no con 200tr.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 2: Hach toan DoiTac ngoai that bai - " + ErrorDescription());
	EndTry;
	
	// Test 3: Anti-Double-Crediting & Non-posting tren HoaDonGTGTDauRa DaDieuChinh
	Try
		Test03_AntiDoubleCreditingVaHoaDonDaDieuChinhNonPosting();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 3: Anti-Double-Crediting - Hoa don DaDieuChinh la Non-posting, khong bi doi Co 1312 thanh 21.818.182 VND.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 3: Anti-Double-Crediting that bai - " + ErrorDescription());
	EndTry;
	
	// Test 4: BeforeWrite tu dong boc tach doanh thu va VAT giam
	Try
		Test04_TuDongBocTachDoanhThuVaThueVAT();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 4: BeforeWrite tu dong boc tach Doanh thu (18.181.818) va Thue VAT (1.818.182) tu Tong giam 20tr.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 4: Tu dong boc tach BeforeWrite that bai - " + ErrorDescription());
	EndTry;
	
	// Test 5: Kiem tra Schema Metadata XML DieuChinhCongNo.xml
	Try
		Test05_KiemTraSchemaVaMetadataDieuChinhCongNo();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 5: Metadata XML DieuChinhCongNo.xml hop le v2.15 voi day du thuoc tinh va dang ky 2 so.");
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
// Test 1: Invariant P0.3 - Luong tranh chap sau ghi so & DieuChinhCongNo ghi so duy nhat
//   - Buoc 1: Nghiem thu ban dau (Task 3.1):
//             + Doanh thu thuan: 200.000.000 VND (No 1312 / Co 5113)
//             + Subledger CongNoPhaiThu: Receipt = 200.000.000 VND
//   - Buoc 2: Xuat hoa don GTGT dau ra (Task 3.2):
//             + VAT 10%: 20.000.000 VND (No 1312 / Co 33311)
//             + Subledger CongNoPhaiThu: Receipt = 20.000.000 VND
//             ==> Tong cong no ban dau: Subledger = 220tr, GL 1312 = 220tr.
//   - Buoc 3: Tranh chap vi pham SLA giam 20.000.000 VND (da gom VAT):
//             + Hoa don dieu chinh dien tu TrangThaiHDDT = DaDieuChinh -> Non-posting (0 GL, 0 Subledger)
//             + Chung tu DieuChinhCongNo ghi so duy nhat:
//               * GL SoCaiKeToan (But toan gop compound):
//                 - Dong 1: No TK 5113: 18.181.818 VND / Co TK 1312: 18.181.818 VND
//                 - Dong 2: No TK 33311: 1.818.182 VND / Co TK 1312: 1.818.182 VND
//                 => Tong phat sinh Co TK 1312 dung bang 20.000.000 VND!
//               * Subledger CongNoPhaiThu:
//                 - Expense: 20.000.000 VND (ChungTuGoc = BienBanNghiemThu)
//   - Buoc 4: Assert Invariants:
//             + Tong Phat sinh Co TK 1312 tu dieu chinh = 20.000.000 VND (tuyet doi khong phai 21.818.182 VND).
//             + Du no Subledger CongNoPhaiThu con lai: 220tr - 20tr = 200.000.000 VND.
//             + Du no SoCaiKeToan TK 1312 con lai: 220tr - 20tr = 200.000.000 VND.
//             + Delta Variance = |200tr - 200tr| = 0 VND tuyet doi!
// -----------------------------------------------------------------------------
Procedure Test01_DieuChinhCongNoGhiSoDuyNhatVaKiemTraInvariantP03() Export
	// 1. Khoi tao Master Data cho doi tac noi bo Vingroup
	DataMock = KhoiTaoDuLieuMau(True); // Noi bo = True -> TK 1312
	RefPhapNhan = DataMock.PhapNhan;
	RefDoiTac = DataMock.DoiTac;
	RefHopDong = DataMock.HopDong;
	RefTienTe = DataMock.TienTe;
	RefBienBan = DataMock.BienBanNghiemThu;
	
	SubledgerAR = TaoBangMoPhongSubledgerAR();
	SoCaiGL = TaoBangMoPhongSoCaiGL();
	
	// 2. Buoc 1: Nghiem thu 200.000.000 VND (Task 3.1)
	MoPhongGhiSoNghiemThu(SubledgerAR, SoCaiGL, RefPhapNhan, RefDoiTac, RefHopDong, RefBienBan, RefTienTe, 200000000, "1312");
	
	// 3. Buoc 2: Hoa don GTGT 20.000.000 VND (Task 3.2)
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
	MoPhongGhiSoHoaDonDauRa(SubledgerAR, SoCaiGL, InvoiceMock);
	
	// Kiem tra cong no truoc khi dieu chinh: dung 220tr
	DuAR_TruocDieuChinh = TinhSoDuSubledgerAR(SubledgerAR, RefHopDong, RefBienBan);
	DuGL1312_TruocDieuChinh = TinhSoDuNoSoCaiGL(SoCaiGL, "1312");
	AssertEquals(220000000, DuAR_TruocDieuChinh, "Cong no AR truoc dieu chinh phai la 220.000.000 VND");
	AssertEquals(220000000, DuGL1312_TruocDieuChinh, "Du no GL 1312 truoc dieu chinh phai la 220.000.000 VND");
	
	// 4. Buoc 3: Phat sinh tranh chap & Hoa don dieu chinh (DaDieuChinh) la Non-posting
	AdjInvoiceMock = New Structure;
	AdjInvoiceMock.Insert("Ref", "HDGTGT-2026-ADJ-01");
	AdjInvoiceMock.Insert("PhapNhan", RefPhapNhan);
	AdjInvoiceMock.Insert("DoiTac", RefDoiTac);
	AdjInvoiceMock.Insert("HopDong", RefHopDong);
	AdjInvoiceMock.Insert("BienBanNghiemThu", RefBienBan);
	AdjInvoiceMock.Insert("SoHoaDon", "00000002");
	AdjInvoiceMock.Insert("KyHieu", "1C26TVSF");
	AdjInvoiceMock.Insert("NgayHoaDon", Date(2026, 10, 12, 9, 0, 0));
	AdjInvoiceMock.Insert("TienChuaThue", -18181818);
	AdjInvoiceMock.Insert("ThueSuatVAT", 10);
	AdjInvoiceMock.Insert("TienThueVAT", -1818182);
	AdjInvoiceMock.Insert("TongTienThanhToan", -20000000);
	AdjInvoiceMock.Insert("TrangThaiHDDT", "DaDieuChinh"); // NON-POSTING
	AdjInvoiceMock.Insert("MaCQT", "M-CQT-2026-ADJ");
	AdjInvoiceMock.Insert("DienGiai", "Hoa don dieu chinh giam theo bien ban thoa thuan SLA");
	
	ButToanHDAdj = MoPhongGhiSoHoaDonDauRa(SubledgerAR, SoCaiGL, AdjInvoiceMock);
	AssertEquals(0, ButToanHDAdj.GLRecords.Count(), "Hoa don DaDieuChinh phai la Non-posting (0 GL records)");
	AssertEquals(0, ButToanHDAdj.ARRecords.Count(), "Hoa don DaDieuChinh phai la Non-posting (0 AR records)");
	
	// 5. Buoc 4: Lap va ghi so chung tu DieuChinhCongNo
	AdjustmentDoc = New Structure;
	AdjustmentDoc.Insert("Ref", "DCCN-2026-0001");
	AdjustmentDoc.Insert("PhapNhan", RefPhapNhan);
	AdjustmentDoc.Insert("DoiTac", RefDoiTac);
	AdjustmentDoc.Insert("HopDong", RefHopDong);
	AdjustmentDoc.Insert("BienBanNghiemThu", RefBienBan);
	AdjustmentDoc.Insert("HoaDonDieuChinh", AdjInvoiceMock.Ref);
	AdjustmentDoc.Insert("SoVanBanThoaThuan", "VBTT-SLA-2026/01");
	AdjustmentDoc.Insert("NgayVanBan", Date(2026, 10, 12));
	AdjustmentDoc.Insert("LyDoDieuChinh", "Phat vi pham cam ket chat luong SLA Cloud thang 10/2026");
	AdjustmentDoc.Insert("ThueSuatVAT", 10);
	AdjustmentDoc.Insert("TongTienGiam", 20000000);
	AdjustmentDoc.Insert("GiamDoanhThu", 18181818);
	AdjustmentDoc.Insert("GiamThueVAT", 1818182);
	AdjustmentDoc.Insert("TrangThai", "DaGhiSo");
	AdjustmentDoc.Insert("DienGiai", "Giam tru cong no theo bien ban thoa thuan SLA");
	
	ButToanDCCN = MoPhongGhiSoDieuChinhCongNo(SubledgerAR, SoCaiGL, AdjustmentDoc);
	
	// 6. Assertions chi tiet
	// a. Sổ cái SoCaiKeToan có 2 dòng bút toán gộp
	AssertEquals(2, ButToanDCCN.GLRecords.Count(), "DieuChinhCongNo phai sinh dung 2 dong but toan GL (Doanh thu & Thue VAT)");
	
	GL1 = ButToanDCCN.GLRecords[0];
	AssertEquals("5113", GL1.AccountDr, "Dong 1 GL: Tai khoan No phai la TK 5113 (Doanh thu thuan giam)");
	AssertEquals("1312", GL1.AccountCr, "Dong 1 GL: Tai khoan Co phai la TK 1312 (Noi bo Vingroup)");
	AssertEquals(18181818, GL1.SoTien, "Dong 1 GL: So tien giam doanh thu phai la 18.181.818 VND");
	AssertEquals(RefBienBan, GL1.ChungTuGoc, "Dong 1 GL: ChungTuGoc phai la BienBanNghiemThu");
	
	GL2 = ButToanDCCN.GLRecords[1];
	AssertEquals("33311", GL2.AccountDr, "Dong 2 GL: Tai khoan No phai la TK 33311 (Thue VAT giam)");
	AssertEquals("1312", GL2.AccountCr, "Dong 2 GL: Tai khoan Co phai la TK 1312 (Noi bo Vingroup)");
	AssertEquals(1818182, GL2.SoTien, "Dong 2 GL: So tien giam thue VAT phai la 1.818.182 VND");
	AssertEquals(RefBienBan, GL2.ChungTuGoc, "Dong 2 GL: ChungTuGoc phai la BienBanNghiemThu");
	
	// b. Regression Assert: Tong phat sinh Co TK 1312 cua dot dieu chinh dung bang 20.000.000 VND
	TongPhatSinhCoTK1312_DotDieuChinh = GL1.SoTien + GL2.SoTien;
	AssertEquals(20000000, TongPhatSinhCoTK1312_DotDieuChinh, 
		"REGRESSION ASSERT: Tong phat sinh Co TK 1312 cua dot dieu chinh phai dung 20.000.000 VND, khong bi doi thanh 21.818.182 VND!");
	
	// c. Sổ tích lũy CongNoPhaiThu ghi nhận Expense 20.000.000 VND
	AssertEquals(1, ButToanDCCN.ARRecords.Count(), "DieuChinhCongNo phai sinh dung 1 dong tren Subledger CongNoPhaiThu");
	AR1 = ButToanDCCN.ARRecords[0];
	AssertEquals("Expense", AR1.RecordType, "Subledger AR loai ghi so phai la Expense (Giam so du)");
	AssertEquals(20000000, AR1.SoTien, "Subledger AR so tien giam phai la 20.000.000 VND");
	AssertEquals(RefBienBan, AR1.ChungTuGoc, "Subledger AR ChungTuGoc bat buoc phai la BienBanNghiemThu");
	
	// d. Kiem tra so du sau dieu chinh & Invariant Reconciliation
	DuAR_SauDieuChinh = TinhSoDuSubledgerAR(SubledgerAR, RefHopDong, RefBienBan);
	DuGL1312_SauDieuChinh = TinhSoDuNoSoCaiGL(SoCaiGL, "1312") - TinhSoDuCoSoCaiGL(SoCaiGL, "1312");
	
	AssertEquals(200000000, DuAR_SauDieuChinh, "Du no Subledger AR sau dieu chinh con lai phai dung 200.000.000 VND");
	AssertEquals(200000000, DuGL1312_SauDieuChinh, "Du no SoCaiKeToan TK 1312 sau dieu chinh con lai phai dung 200.000.000 VND");
	
	DeltaVariance = Abs(DuAR_SauDieuChinh - DuGL1312_SauDieuChinh);
	AssertEquals(0, DeltaVariance, "Invariant P0.3: Delta Variance sau dieu chinh phai bang 0 tuyet doi!");
EndProcedure

// -----------------------------------------------------------------------------
// Test 2: DoiTac ngoai Vingroup (LaBenLienKet = False)
//   - Hach toan No 5113: 18.181.818, No 33311: 1.818.182 / Co TK 1311: 20.000.000 VND
//   - Subledger AR va GL TK 1311 deu con lai 200.000.000 VND, Delta = 0
// -----------------------------------------------------------------------------
Procedure Test02_DoiTacNgoaiHachToanCoTK1311() Export
	DataMock = KhoiTaoDuLieuMau(False); // Doi tac ben ngoai -> TK 1311
	
	SubledgerAR = TaoBangMoPhongSubledgerAR();
	SoCaiGL = TaoBangMoPhongSoCaiGL();
	
	// Nghiem thu 200tr (No 1311 / Co 5113)
	MoPhongGhiSoNghiemThu(SubledgerAR, SoCaiGL, DataMock.PhapNhan, DataMock.DoiTac, 
		DataMock.HopDong, DataMock.BienBanNghiemThu, DataMock.TienTe, 200000000, "1311");
	
	// Hoa don 20tr VAT (No 1311 / Co 33311)
	InvoiceMock = New Structure;
	InvoiceMock.Insert("Ref", "HDGTGT-EXT-01");
	InvoiceMock.Insert("PhapNhan", DataMock.PhapNhan);
	InvoiceMock.Insert("DoiTac", DataMock.DoiTac);
	InvoiceMock.Insert("HopDong", DataMock.HopDong);
	InvoiceMock.Insert("BienBanNghiemThu", DataMock.BienBanNghiemThu);
	InvoiceMock.Insert("SoHoaDon", "00000003");
	InvoiceMock.Insert("KyHieu", "1C26TVSF");
	InvoiceMock.Insert("NgayHoaDon", Date(2026, 10, 10, 11, 0, 0));
	InvoiceMock.Insert("TienChuaThue", 200000000);
	InvoiceMock.Insert("ThueSuatVAT", 10);
	InvoiceMock.Insert("TienThueVAT", 20000000);
	InvoiceMock.Insert("TongTienThanhToan", 220000000);
	InvoiceMock.Insert("TrangThaiHDDT", "DaPhatHanh");
	InvoiceMock.Insert("MaCQT", "M-CQT-EXT-01");
	InvoiceMock.Insert("DienGiai", "Thue GTGT dau ra doi tac ngoai");
	MoPhongGhiSoHoaDonDauRa(SubledgerAR, SoCaiGL, InvoiceMock);
	
	// DieuChinhCongNo giam 20tr
	AdjDoc = New Structure;
	AdjDoc.Insert("Ref", "DCCN-EXT-01");
	AdjDoc.Insert("PhapNhan", DataMock.PhapNhan);
	AdjDoc.Insert("DoiTac", DataMock.DoiTac);
	AdjDoc.Insert("HopDong", DataMock.HopDong);
	AdjDoc.Insert("BienBanNghiemThu", DataMock.BienBanNghiemThu);
	AdjDoc.Insert("HoaDonDieuChinh", "HDGTGT-EXT-ADJ");
	AdjDoc.Insert("SoVanBanThoaThuan", "VBTT-EXT/01");
	AdjDoc.Insert("NgayVanBan", Date(2026, 10, 12));
	AdjDoc.Insert("LyDoDieuChinh", "Giam tru gia dich vu ngoai tap doan");
	AdjDoc.Insert("ThueSuatVAT", 10);
	AdjDoc.Insert("TongTienGiam", 20000000);
	AdjDoc.Insert("GiamDoanhThu", 18181818);
	AdjDoc.Insert("GiamThueVAT", 1818182);
	AdjDoc.Insert("TrangThai", "DaGhiSo");
	AdjDoc.Insert("DienGiai", "Giam tru cong no khach hang ngoai");
	
	ButToan = MoPhongGhiSoDieuChinhCongNo(SubledgerAR, SoCaiGL, AdjDoc);
	
	GL1 = ButToan.GLRecords[0];
	GL2 = ButToan.GLRecords[1];
	AssertEquals("1311", GL1.AccountCr, "Doi tac ngoai phai hach toan Co vao TK 1311 tren dong 1");
	AssertEquals("1311", GL2.AccountCr, "Doi tac ngoai phai hach toan Co vao TK 1311 tren dong 2");
	
	DuAR = TinhSoDuSubledgerAR(SubledgerAR, DataMock.HopDong, DataMock.BienBanNghiemThu);
	DuGL1311 = TinhSoDuNoSoCaiGL(SoCaiGL, "1311") - TinhSoDuCoSoCaiGL(SoCaiGL, "1311");
	
	AssertEquals(200000000, DuAR, "Du no Subledger AR doi tac ngoai con 200tr");
	AssertEquals(200000000, DuGL1311, "Du no SoCaiKeToan TK 1311 doi tac ngoai con 200tr");
	AssertEquals(0, Abs(DuAR - DuGL1311), "Delta Variance doi tac ngoai phai bang 0");
EndProcedure

// -----------------------------------------------------------------------------
// Test 3: Anti-Double-Crediting & Invariant HoaDonGTGTDauRa DaDieuChinh Non-posting
//   - Neu ca HoaDonGTGTDauRa va DieuChinhCongNo cung ghi Co 1312, tong Co se bi doi len 21.818.182đ hoac 40tr.
//   - Chung minh rang: HoaDonGTGTDauRa o trang thai DaDieuChinh khong bao gio sinh but toan.
// -----------------------------------------------------------------------------
Procedure Test03_AntiDoubleCreditingVaHoaDonDaDieuChinhNonPosting() Export
	DataMock = KhoiTaoDuLieuMau(True);
	SubledgerAR = TaoBangMoPhongSubledgerAR();
	SoCaiGL = TaoBangMoPhongSoCaiGL();
	
	// Khoi tao ban dau: 220tr
	MoPhongGhiSoNghiemThu(SubledgerAR, SoCaiGL, DataMock.PhapNhan, DataMock.DoiTac, 
		DataMock.HopDong, DataMock.BienBanNghiemThu, DataMock.TienTe, 200000000, "1312");
	
	InvoiceMock = New Structure;
	InvoiceMock.Insert("Ref", "HDGTGT-ORIG");
	InvoiceMock.Insert("PhapNhan", DataMock.PhapNhan);
	InvoiceMock.Insert("DoiTac", DataMock.DoiTac);
	InvoiceMock.Insert("HopDong", DataMock.HopDong);
	InvoiceMock.Insert("BienBanNghiemThu", DataMock.BienBanNghiemThu);
	InvoiceMock.Insert("SoHoaDon", "00000005");
	InvoiceMock.Insert("KyHieu", "1C26TVSF");
	InvoiceMock.Insert("NgayHoaDon", Date(2026, 10, 10));
	InvoiceMock.Insert("TienChuaThue", 200000000);
	InvoiceMock.Insert("ThueSuatVAT", 10);
	InvoiceMock.Insert("TienThueVAT", 20000000);
	InvoiceMock.Insert("TongTienThanhToan", 220000000);
	InvoiceMock.Insert("TrangThaiHDDT", "DaPhatHanh");
	InvoiceMock.Insert("MaCQT", "M-CQT-05");
	InvoiceMock.Insert("DienGiai", "HD goc");
	MoPhongGhiSoHoaDonDauRa(SubledgerAR, SoCaiGL, InvoiceMock);
	
	// 1. Thu ghi so hoa don dieu chinh
	InvoiceAdj = New Structure;
	InvoiceAdj.Insert("Ref", "HDGTGT-ADJ");
	InvoiceAdj.Insert("PhapNhan", DataMock.PhapNhan);
	InvoiceAdj.Insert("DoiTac", DataMock.DoiTac);
	InvoiceAdj.Insert("HopDong", DataMock.HopDong);
	InvoiceAdj.Insert("BienBanNghiemThu", DataMock.BienBanNghiemThu);
	InvoiceAdj.Insert("SoHoaDon", "00000006");
	InvoiceAdj.Insert("KyHieu", "1C26TVSF");
	InvoiceAdj.Insert("NgayHoaDon", Date(2026, 10, 12));
	InvoiceAdj.Insert("TienChuaThue", -18181818);
	InvoiceAdj.Insert("ThueSuatVAT", 10);
	InvoiceAdj.Insert("TienThueVAT", -1818182);
	InvoiceAdj.Insert("TongTienThanhToan", -20000000);
	InvoiceAdj.Insert("TrangThaiHDDT", "DaDieuChinh"); // NON-POSTING
	InvoiceAdj.Insert("MaCQT", "M-CQT-06");
	InvoiceAdj.Insert("DienGiai", "HD dieu chinh");
	
	ButToanAdj = MoPhongGhiSoHoaDonDauRa(SubledgerAR, SoCaiGL, InvoiceAdj);
	AssertEquals(0, ButToanAdj.GLRecords.Count(), "Hoa don DaDieuChinh khong duoc phep sinh GL");
	AssertEquals(0, ButToanAdj.ARRecords.Count(), "Hoa don DaDieuChinh khong duoc phep sinh AR");
	
	// 2. Ghi so DieuChinhCongNo
	AdjDoc = New Structure;
	AdjDoc.Insert("Ref", "DCCN-ANTI-DC");
	AdjDoc.Insert("PhapNhan", DataMock.PhapNhan);
	AdjDoc.Insert("DoiTac", DataMock.DoiTac);
	AdjDoc.Insert("HopDong", DataMock.HopDong);
	AdjDoc.Insert("BienBanNghiemThu", DataMock.BienBanNghiemThu);
	AdjDoc.Insert("HoaDonDieuChinh", InvoiceAdj.Ref);
	AdjDoc.Insert("SoVanBanThoaThuan", "VBTT-ANTI");
	AdjDoc.Insert("NgayVanBan", Date(2026, 10, 12));
	AdjDoc.Insert("LyDoDieuChinh", "Kiem tra anti double crediting");
	AdjDoc.Insert("ThueSuatVAT", 10);
	AdjDoc.Insert("TongTienGiam", 20000000);
	AdjDoc.Insert("GiamDoanhThu", 18181818);
	AdjDoc.Insert("GiamThueVAT", 1818182);
	AdjDoc.Insert("TrangThai", "DaGhiSo");
	AdjDoc.Insert("DienGiai", "Dieu chinh duy nhat");
	MoPhongGhiSoDieuChinhCongNo(SubledgerAR, SoCaiGL, AdjDoc);
	
	// 3. Kiem tra tong phat sinh Co TK 1312
	TongPhatSinhCo1312 = TinhSoDuCoSoCaiGL(SoCaiGL, "1312");
	AssertEquals(20000000, TongPhatSinhCo1312, "Tong phat sinh Co TK 1312 phai dung 20tr, khong bi Double-Crediting");
	AssertFalse(TongPhatSinhCo1312 = 21818182, "LOI NGIEM TRONG: Tong phat sinh Co 1312 bi ghi trung thanh 21.818.182 VND!");
	AssertFalse(TongPhatSinhCo1312 = 40000000, "LOI NGIEM TRONG: Tong phat sinh Co 1312 bi ghi trung thanh 40.000.000 VND!");
EndProcedure

// -----------------------------------------------------------------------------
// Test 4: Logic BeforeWrite tu dong boc tach doanh thu va thue VAT giam
// -----------------------------------------------------------------------------
Procedure Test04_TuDongBocTachDoanhThuVaThueVAT() Export
	// Case 4a: Nhap TongTienGiam = 20.000.000, ThueSuatVAT = 10, chua nhap GiamDoanhThu va GiamThueVAT
	DocTest1 = New Structure;
	DocTest1.Insert("TongTienGiam", 20000000);
	DocTest1.Insert("ThueSuatVAT", 10);
	DocTest1.Insert("GiamDoanhThu", 0);
	DocTest1.Insert("GiamThueVAT", 0);
	DocTest1.Insert("TrangThai", "");
	
	XuLyBeforeWriteDieuChinhCongNo(DocTest1);
	
	AssertEquals(18181818, DocTest1.GiamDoanhThu, "GiamDoanhThu phai tu dong tinh: Round(20tr / 1.1, 0) = 18.181.818 VND");
	AssertEquals(1818182, DocTest1.GiamThueVAT, "GiamThueVAT phai tu dong tinh: 20tr - 18.181.818 = 1.818.182 VND");
	AssertEquals(20000000, DocTest1.GiamDoanhThu + DocTest1.GiamThueVAT, "Tong hai phan phai khop 100% TongTienGiam");
	AssertEquals("DaGhiSo", DocTest1.TrangThai, "TrangThai mac dinh phai la DaGhiSo");
	
	// Case 4b: Thue suat 8% theo Nghi quyet 204/2025/QH15
	DocTest2 = New Structure;
	DocTest2.Insert("TongTienGiam", 20000000);
	DocTest2.Insert("ThueSuatVAT", 8);
	DocTest2.Insert("GiamDoanhThu", 0);
	DocTest2.Insert("GiamThueVAT", 0);
	DocTest2.Insert("TrangThai", "");
	
	XuLyBeforeWriteDieuChinhCongNo(DocTest2);
	
	// 20tr / 1.08 = 18.518.518,52 -> 18.518.519 VND
	AssertEquals(18518519, DocTest2.GiamDoanhThu, "Thue suat 8%: GiamDoanhThu = Round(20tr / 1.08, 0) = 18.518.519 VND");
	AssertEquals(1481481, DocTest2.GiamThueVAT, "Thue suat 8%: GiamThueVAT = 20tr - 18.518.519 = 1.481.481 VND");
	AssertEquals(20000000, DocTest2.GiamDoanhThu + DocTest2.GiamThueVAT, "Thue suat 8%: Tong cong phai dung 20.000.000 VND");
EndProcedure

// -----------------------------------------------------------------------------
// Test 5: Kiem tra Schema va Metadata XML cua DieuChinhCongNo.xml
// -----------------------------------------------------------------------------
Procedure Test05_KiemTraSchemaVaMetadataDieuChinhCongNo() Export
	FilePath = "C:/Users/Dung/Documents/1C_Enterprise/src/Documents/DieuChinhCongNo.xml";
	
	FileOnDisk = New File(FilePath);
	AssertTrue(FileOnDisk.Exists(), "File src/Documents/DieuChinhCongNo.xml bat buoc phai ton tai");
	
	TextR = New TextReader(FilePath, TextEncoding.UTF8);
	XmlContent = TextR.Read();
	TextR.Close();
	
	// 1. Kiem tra Document Metadata version 2.15
	AssertTrue(StrFind(XmlContent, "version=""2.15""") > 0, "Metadata XML phai la version 2.15");
	AssertTrue(StrFind(XmlContent, "<Name>DieuChinhCongNo</Name>") > 0, "Ten Document phai la DieuChinhCongNo");
	
	// 2. Kiem tra cac thuoc tinh bat buoc
	CacThuocTinh = New Array;
	CacThuocTinh.Add("PhapNhan");
	CacThuocTinh.Add("DoiTac");
	CacThuocTinh.Add("HopDong");
	CacThuocTinh.Add("BienBanNghiemThu");
	CacThuocTinh.Add("HoaDonDieuChinh");
	CacThuocTinh.Add("SoVanBanThoaThuan");
	CacThuocTinh.Add("NgayVanBan");
	CacThuocTinh.Add("LyDoDieuChinh");
	CacThuocTinh.Add("ThueSuatVAT");
	CacThuocTinh.Add("GiamDoanhThu");
	CacThuocTinh.Add("GiamThueVAT");
	CacThuocTinh.Add("TongTienGiam");
	CacThuocTinh.Add("TrangThai");
	CacThuocTinh.Add("DienGiai");
	
	For Each TT In CacThuocTinh Do
		AssertTrue(StrFind(XmlContent, "<Name>" + TT + "</Name>") > 0, 
			StrTemplate("Thuoc tinh '%1' phai duoc dinh nghia trong DieuChinhCongNo.xml", TT));
	EndDo;
	
	// 3. Kiem tra RegisterRecords
	AssertTrue(StrFind(XmlContent, "AccumulationRegister.CongNoPhaiThu") > 0, 
		"DieuChinhCongNo phai dang ky so AccumulationRegister.CongNoPhaiThu");
	AssertTrue(StrFind(XmlContent, "AccountingRegister.SoCaiKeToan") > 0, 
		"DieuChinhCongNo phai dang ky so AccountingRegister.SoCaiKeToan");
	AssertTrue(StrFind(XmlContent, "<Posting>Allow</Posting>") > 0, 
		"DieuChinhCongNo phai cho phep ghi so (Posting = Allow)");
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

Function MoPhongGhiSoDieuChinhCongNo(SubledgerAR, SoCaiGL, AdjDoc)
	Result = New Structure("ARRecords,GLRecords", New Array, New Array);
	
	// Xac dinh TK Cong no: DoiTac la ben lien ket -> 1312, nguoc lai -> 1311
	TKCongNo = "1311";
	If TypeOf(AdjDoc.DoiTac) = Type("Structure") And AdjDoc.DoiTac.Property("LaBenLienKet") Then
		If AdjDoc.DoiTac.LaBenLienKet Then
			TKCongNo = "1312";
		EndIf;
	EndIf;
	
	// 1. Ghi Sổ tích lũy CongNoPhaiThu (Expense / Giảm số dư: ChungTuGoc = BienBanNghiemThu)
	ARRec = New Structure;
	ARRec.Insert("RecordType", "Expense");
	ARRec.Insert("PhapNhan", AdjDoc.PhapNhan);
	ARRec.Insert("DoiTac", AdjDoc.DoiTac);
	ARRec.Insert("HopDong", AdjDoc.HopDong);
	ARRec.Insert("ChungTuGoc", AdjDoc.BienBanNghiemThu);
	ARRec.Insert("SoTien", AdjDoc.TongTienGiam);
	SubledgerAR.Add(ARRec);
	Result.ARRecords.Add(ARRec);
	
	// 2. Ghi Sổ cái SoCaiKeToan: Gộp 1 bút toán kép duy nhất gồm 2 dòng phát sinh Có TKCongNo
	// Dong 1: No TK 5113 / Co TKCongNo (Giam doanh thu thuan)
	GLRec1 = New Structure;
	GLRec1.Insert("PhapNhan", AdjDoc.PhapNhan);
	GLRec1.Insert("TienTe", "VND");
	GLRec1.Insert("AccountDr", "5113");
	GLRec1.Insert("AccountCr", TKCongNo);
	GLRec1.Insert("ChungTuGoc", AdjDoc.BienBanNghiemThu);
	GLRec1.Insert("SoTien", AdjDoc.GiamDoanhThu);
	GLRec1.Insert("DienGiai", AdjDoc.DienGiai);
	SoCaiGL.Add(GLRec1);
	Result.GLRecords.Add(GLRec1);
	
	// Dong 2: No TK 33311 / Co TKCongNo (Giam thue GTGT)
	GLRec2 = New Structure;
	GLRec2.Insert("PhapNhan", AdjDoc.PhapNhan);
	GLRec2.Insert("TienTe", "VND");
	GLRec2.Insert("AccountDr", "33311");
	GLRec2.Insert("AccountCr", TKCongNo);
	GLRec2.Insert("ChungTuGoc", AdjDoc.BienBanNghiemThu);
	GLRec2.Insert("SoTien", AdjDoc.GiamThueVAT);
	GLRec2.Insert("DienGiai", AdjDoc.DienGiai);
	SoCaiGL.Add(GLRec2);
	Result.GLRecords.Add(GLRec2);
	
	Return Result;
EndFunction

Procedure XuLyBeforeWriteDieuChinhCongNo(Doc)
	If Doc.ThueSuatVAT = 0 Then
		Doc.ThueSuatVAT = 10;
	EndIf;
	
	If Doc.TongTienGiam > 0 Then
		If Doc.GiamDoanhThu = 0 Then
			TyLeHeSo = 1 + Doc.ThueSuatVAT / 100;
			Doc.GiamDoanhThu = Round(Doc.TongTienGiam / TyLeHeSo, 0);
		EndIf;
		If Doc.GiamThueVAT = 0 Then
			Doc.GiamThueVAT = Doc.TongTienGiam - Doc.GiamDoanhThu;
		EndIf;
	ElsIf Doc.GiamDoanhThu > 0 Then
		If Doc.GiamThueVAT = 0 Then
			Doc.GiamThueVAT = Round(Doc.GiamDoanhThu * Doc.ThueSuatVAT / 100, 0);
		EndIf;
		Doc.TongTienGiam = Doc.GiamDoanhThu + Doc.GiamThueVAT;
	EndIf;
	
	If IsBlankString(Doc.TrangThai) Then
		Doc.TrangThai = "DaGhiSo";
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
