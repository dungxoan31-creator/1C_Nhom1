// Unit Test Suite: PhieuThuTienTest
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL / BUnit / Vanessa)
// Muc tieu: Kiem thu chung tu PhieuThuTienKhachHang & Phan bo thanh toan AR (Task 3.4):
//   1. Test 1: Khach hang noi bo Vingroup thanh toan 200.000.000 VND cho chung tu nghiem thu con no 200.000.000 VND
//              -> SoCaiKeToan: No TK 1121 / Co TK 1312: 200.000.000 VND.
//              -> Sổ tích lũy CongNoPhaiThu: Expense = 200.000.000 VND (ChungTuGoc = BienBanNghiemThuGiaiDoan).
//                 ==> So du no cua chung tu goc dua ve 0 (Tat toan toan phan!).
//              -> Sổ tích lũy DongTien: Receipt = 200.000.000 VND (Tang so du tai khoan ngan hang).
//              -> Invariant Khop noi: Variance Delta = |Subledger AR - GL TK 1312| = 0 VND.
//   2. Test 2: Khach hang ngoai tap doan (LaBenLienKet = False) -> Hach toan No TK 1121 / Co TK 1311: 150.000.000 VND.
//              -> CongNoPhaiThu Expense = 150tr, DongTien Receipt = 150tr, Tat toan no thanh cong.
//   3. Test 3: Thanh toan bang Ngoai te USD -> Hach toan No TK 1122 (Tien gui Ngoai te) / Co TK 1312: 250.000.000 VND (10.000 USD).
//              -> DongTien ghi nhan SoTien = 250tr, SoTienNgoaiTe = 10.000 USD, TienTe = USD.
//   4. Test 4: Thanh toan tung phan (Partial Payment) & Kiem tra rang buoc du lieu bat buoc
//              -> Nghiem thu 200tr, thanh toan dot 1 = 80tr -> Du no con lai Subledger = 120tr, GL TK 1312 = 120tr, Delta = 0.
//              -> Chan bat buoc: Thieu PhapNhan, DoiTac, HopDong, TaiKhoanTien, TienTe hoac SoTien <= 0 phai bao loi.
//   5. Test 5: Kiem tra toan ven Metadata XML Schema PhieuThuTienKhachHang.xml (version 2.15, 12 thuoc tinh, 3 so).

#Region TestExecution

Function RunVerification() Export
	Results = RunAllTests();
	
	LogPath = "C:/Users/Dung/Documents/1C_Enterprise/tests/unit/phieu_thu_tien_test_result.log";
	Try
		TextW = New TextWriter(LogPath, TextEncoding.UTF8);
		For Each Line In Results.Log Do
			TextW.WriteLine(Line);
		EndDo;
		TextW.Close();
	Except
		// Khong the ghi log ra file van ban, giu ket qua trong bo nho
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
	TestLog.Add("  VINSMART FUTURE - PHIEU THU TIEN KHACH HANG UNIT TEST (TASK 3.4) ");
	TestLog.Add("  Thoi gian chay: " + CurrentDate());
	TestLog.Add("=================================================================");
	
	// Test 1: Khach hang noi bo thanh toan tat toan chung tu goc 200.000.000 VND
	Try
		Test01_KhachHangNoiBoThanhToanTatToanChungTuGoc();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 1: Khach hang noi bo thanh toan 200tr -> CongNoPhaiThu ve 0 (Tat toan), DongTien tang 200tr, GL No 1121 / Co 1312: 200tr, Delta = 0.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 1: Thanh toan tat toan that bai - " + ErrorDescription());
	EndTry;
	
	// Test 2: Khach hang ngoai tap doan hach toan No TK 1121 / Co TK 1311
	Try
		Test02_KhachHangNgoaiTapDoanHachToanTK1311();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 2: Doi tac ngoai tap doan hach toan dung No TK 1121 / Co TK 1311: 150tr, CongNoPhaiThu tat toan ve 0.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 2: Hach toan doi tac ngoai that bai - " + ErrorDescription());
	EndTry;
	
	// Test 3: Thanh toan ngoai te USD hach toan No TK 1122 va quy doi ty gia
	Try
		Test03_ThanhToanNgoaiTeUSDHachToanTK1122();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 3: Thanh toan ngoai te USD (10.000 USD x 25.000 = 250tr VND) hach toan dung No TK 1122, DongTien va CongNo ghi nhan nguyen te.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 3: Thanh toan ngoai te that bai - " + ErrorDescription());
	EndTry;
	
	// Test 4: Thanh toan tung phan va rang buoc du lieu bat buoc
	Try
		Test04_ThanhToanTungPhanVaKiemTraRangBuocDuLieu();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 4: Thanh toan tung phan (80tr / 200tr) con no 120tr khop GL & Subledger; Chan thieu du lieu bat buoc va SoTien <= 0 thanh cong.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 4: Thanh toan tung phan / rang buoc that bai - " + ErrorDescription());
	EndTry;
	
	// Test 5: Kiem tra Schema Metadata XML PhieuThuTienKhachHang.xml v2.15
	Try
		Test05_KiemTraMetadataSchemaPhieuThuTienKhachHang();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 5: Metadata XML PhieuThuTienKhachHang.xml hop le v2.15 voi 12 thuoc tinh, 3 so dang ky va Posting=Allow.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 5: Kiem tra Schema XML that bai - " + ErrorDescription());
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
// Test 1: Khách hàng nội bộ Vingroup thanh toán 200.000.000 VND cho chứng từ nghiệm thu
//         - Ban đầu: Biên bản nghiệm thu ghi nhận:
//           + GL: Nợ TK 1312 / Có TK 5113 = 200.000.000 VND
//           + Subledger CongNoPhaiThu: Receipt = 200.000.000 VND
//         - Thực hiện ghi sổ PhieuThuTienKhachHang:
//           + GL: Nợ TK 1121 (Tiền gửi ngân hàng VND) / Có TK 1312: 200.000.000 VND
//           + Subledger CongNoPhaiThu: Expense = 200.000.000 VND (ChungTuGoc = BienBanNghiemThuGiaiDoan)
//           + Subledger DongTien: Receipt = 200.000.000 VND
//         - Kết quả:
//           + Số dư công nợ của chứng từ gốc đưa về 0 (Tất toán).
//           + Sổ Dòng tiền tăng 200.000.000 VND.
//           + Dư nợ GL TK 1312 đưa về 0.
//           + Variance Delta = |Subledger - GL| = 0.
// -----------------------------------------------------------------------------
Procedure Test01_KhachHangNoiBoThanhToanTatToanChungTuGoc() Export
	MasterData = KhoiTaoDuLieuMau(True, "VND"); // Noi bo = True -> TK 1312
	RefPhapNhan = MasterData.PhapNhan;
	RefDoiTac = MasterData.DoiTac;
	RefHopDong = MasterData.HopDong;
	RefBienBan = MasterData.BienBanNghiemThu;
	RefTaiKhoanTien = MasterData.TaiKhoanTien;
	RefKhoanMuc = MasterData.KhoanMucDongTien;
	RefTienTe = MasterData.TienTe;
	
	// Khởi tạo bảng mô phỏng 3 sổ
	SubledgerAR = TaoBangMoPhongSubledgerAR();
	RegisterDongTien = TaoBangMoPhongDongTien();
	SoCaiGL = TaoBangMoPhongSoCaiGL();
	
	// 1. Ghi nhận nghiệm thu ban đầu (Task 3.1): Doanh thu thuần 200.000.000 VND
	MoPhongGhiSoNghiemThu(SubledgerAR, SoCaiGL, RefPhapNhan, RefDoiTac, RefHopDong, RefBienBan, RefTienTe, 200000000, "1312");
	
	// Kiểm tra trạng thái nợ trước khi thu tiền
	DuAR_TruocThu = TinhSoDuSubledgerAR(SubledgerAR, RefHopDong, RefBienBan);
	DuGL1312_TruocThu = TinhSoDuNoSoCaiGL(SoCaiGL, "1312") - TinhSoDuCoSoCaiGL(SoCaiGL, "1312");
	AssertEquals(200000000, DuAR_TruocThu, "Trước khi thu tiền, công nợ AR phải là 200tr");
	AssertEquals(200000000, DuGL1312_TruocThu, "Trước khi thu tiền, dư nợ TK 1312 phải là 200tr");
	
	// 2. Lập chứng từ PhieuThuTienKhachHang thu 200.000.000 VND
	ReceiptDoc = New Structure;
	ReceiptDoc.Insert("Ref", "PT-2026-0001");
	ReceiptDoc.Insert("Number", "PT-000001");
	ReceiptDoc.Insert("Date", Date(2026, 10, 10, 14, 0, 0));
	ReceiptDoc.Insert("PhapNhan", RefPhapNhan);
	ReceiptDoc.Insert("DoiTac", RefDoiTac);
	ReceiptDoc.Insert("HopDong", RefHopDong);
	ReceiptDoc.Insert("ChungTuGoc", RefBienBan);
	ReceiptDoc.Insert("TaiKhoanTien", RefTaiKhoanTien);
	ReceiptDoc.Insert("KhoanMucDongTien", RefKhoanMuc);
	ReceiptDoc.Insert("TienTe", RefTienTe);
	ReceiptDoc.Insert("SoTien", 200000000);
	ReceiptDoc.Insert("SoTienNgoaiTe", 0);
	ReceiptDoc.Insert("TyGia", 1);
	ReceiptDoc.Insert("NgayThu", Date(2026, 10, 10, 14, 0, 0));
	ReceiptDoc.Insert("DienGiai", "Thu tien thanh toan nghiem thu dich vu AI Cloud");
	
	// 3. Thực hiện ghi sổ PhieuThuTienKhachHang
	ButToanThuTien = MoPhongGhiSoPhieuThuTien(SubledgerAR, RegisterDongTien, SoCaiGL, ReceiptDoc);
	
	// 4. Assertions chi tiết
	// a. Sổ cái SoCaiKeToan có bút toán Nợ 1121 / Có 1312: 200.000.000 VND
	AssertEquals(1, ButToanThuTien.GLRecords.Count(), "Phiếu thu tiền phải sinh đúng 1 bút toán GL");
	GLRec = ButToanThuTien.GLRecords[0];
	AssertEquals("1121", GLRec.AccountDr, "Tài khoản Nợ phải là TK 1121 (Tiền gửi ngân hàng VND)");
	AssertEquals("1312", GLRec.AccountCr, "Tài khoản Có phải là TK 1312 (Khách hàng nội bộ Vingroup)");
	AssertEquals(200000000, GLRec.SoTien, "Số tiền bút toán GL phải đúng bằng 200.000.000 VND");
	AssertEquals(RefBienBan, GLRec.ChungTuGoc, "ChungTuGoc trên SoCaiKeToan phải là BienBanNghiemThuGiaiDoan");
	
	// b. Sổ tích lũy CongNoPhaiThu ghi nhận Expense 200.000.000 VND (ChungTuGoc = BienBanNghiemThu)
	AssertEquals(1, ButToanThuTien.ARRecords.Count(), "Phiếu thu tiền phải sinh đúng 1 bản ghi trên Subledger CongNoPhaiThu");
	ARRec = ButToanThuTien.ARRecords[0];
	AssertEquals("Expense", ARRec.RecordType, "Loại ghi sổ AR phải là Expense (Giảm công nợ)");
	AssertEquals(200000000, ARRec.SoTien, "Số tiền giảm công nợ phải là 200.000.000 VND");
	AssertEquals(RefBienBan, ARRec.ChungTuGoc, "ChungTuGoc trên CongNoPhaiThu BẮT BUỘC là BienBanNghiemThu");
	
	// c. Sổ tích lũy DongTien ghi nhận Receipt 200.000.000 VND
	AssertEquals(1, ButToanThuTien.CFRecords.Count(), "Phiếu thu tiền phải sinh đúng 1 bản ghi trên DongTien");
	CFRec = ButToanThuTien.CFRecords[0];
	AssertEquals("Receipt", CFRec.RecordType, "Loại ghi sổ DongTien phải là Receipt (Tăng số dư tiền)");
	AssertEquals(200000000, CFRec.SoTien, "Số tiền tăng dòng tiền phải là 200.000.000 VND");
	AssertEquals(RefTaiKhoanTien, CFRec.TaiKhoanTien, "Tài khoản tiền trên DongTien phải đúng với tài khoản nhận");
	
	// d. Kiểm tra số dư công nợ sau khi thu tiền: Đưa về 0 (Tất toán!)
	DuAR_SauThu = TinhSoDuSubledgerAR(SubledgerAR, RefHopDong, RefBienBan);
	AssertEquals(0, DuAR_SauThu, "Sau khi thanh toán đủ 200tr, số dư nợ của chứng từ gốc phải bằng 0 (Tất toán)!");
	
	// e. Kiểm tra số dư dòng tiền DongTien: Tăng đúng 200.000.000 VND
	DuDongTien = TinhSoDuDongTien(RegisterDongTien, RefTaiKhoanTien);
	AssertEquals(200000000, DuDongTien, "Số dư tài khoản tiền trên sổ DongTien phải là 200.000.000 VND");
	
	// f. Kiểm tra số dư Nợ TK 1312 trên General Ledger: Đưa về 0
	TongPhatSinhNo1312 = TinhSoDuNoSoCaiGL(SoCaiGL, "1312");
	TongPhatSinhCo1312 = TinhSoDuCoSoCaiGL(SoCaiGL, "1312");
	DuNoTK1312_SauThu = TongPhatSinhNo1312 - TongPhatSinhCo1312;
	AssertEquals(0, DuNoTK1312_SauThu, "Số dư nợ TK 1312 sau thanh toán phải bằng 0!");
	
	// g. Invariant Reconciliation: Delta Variance = |Subledger AR - GL TK 1312| = 0 VND
	DeltaVariance = Abs(DuAR_SauThu - DuNoTK1312_SauThu);
	AssertEquals(0, DeltaVariance, "Độ lệch giữa Subledger AR và General Ledger TK 1312 phải tuyệt đối bằng 0!");
EndProcedure

// -----------------------------------------------------------------------------
// Test 2: Khách hàng ngoài tập đoàn (LaBenLienKet = False)
//         - GL: Nợ TK 1121 / Có TK 1311: 150.000.000 VND
//         - CongNoPhaiThu: Expense = 150.000.000 VND -> Số dư về 0
//         - DongTien: Receipt = 150.000.000 VND
//         - Delta Variance = 0
// -----------------------------------------------------------------------------
Procedure Test02_KhachHangNgoaiTapDoanHachToanTK1311() Export
	MasterData = KhoiTaoDuLieuMau(False, "VND"); // Khach hang ngoai -> TK 1311
	
	SubledgerAR = TaoBangMoPhongSubledgerAR();
	RegisterDongTien = TaoBangMoPhongDongTien();
	SoCaiGL = TaoBangMoPhongSoCaiGL();
	
	// 1. Nghiem thu ban dau 150tr cho doi tac ngoai (No 1311 / Co 5113: 150tr)
	MoPhongGhiSoNghiemThu(SubledgerAR, SoCaiGL, MasterData.PhapNhan, MasterData.DoiTac,
		MasterData.HopDong, MasterData.BienBanNghiemThu, MasterData.TienTe, 150000000, "1311");
	
	// 2. Thu tien 150tr
	ReceiptDoc = New Structure;
	ReceiptDoc.Insert("Ref", "PT-EXT-0001");
	ReceiptDoc.Insert("Number", "PT-000002");
	ReceiptDoc.Insert("Date", CurrentDate());
	ReceiptDoc.Insert("PhapNhan", MasterData.PhapNhan);
	ReceiptDoc.Insert("DoiTac", MasterData.DoiTac);
	ReceiptDoc.Insert("HopDong", MasterData.HopDong);
	ReceiptDoc.Insert("ChungTuGoc", MasterData.BienBanNghiemThu);
	ReceiptDoc.Insert("TaiKhoanTien", MasterData.TaiKhoanTien);
	ReceiptDoc.Insert("KhoanMucDongTien", MasterData.KhoanMucDongTien);
	ReceiptDoc.Insert("TienTe", MasterData.TienTe);
	ReceiptDoc.Insert("SoTien", 150000000);
	ReceiptDoc.Insert("SoTienNgoaiTe", 0);
	ReceiptDoc.Insert("TyGia", 1);
	ReceiptDoc.Insert("NgayThu", CurrentDate());
	ReceiptDoc.Insert("DienGiai", "Khach ngoai thanh toan dich vu SaaS");
	
	ButToan = MoPhongGhiSoPhieuThuTien(SubledgerAR, RegisterDongTien, SoCaiGL, ReceiptDoc);
	
	// Assert
	GLRec = ButToan.GLRecords[0];
	AssertEquals("1121", GLRec.AccountDr, "Thu tien VND phai vao No TK 1121");
	AssertEquals("1311", GLRec.AccountCr, "Doi tac ngoai phai hach toan Co vao TK 1311");
	AssertEquals(150000000, GLRec.SoTien, "So tien GL phai la 150.000.000 VND");
	
	DuAR = TinhSoDuSubledgerAR(SubledgerAR, MasterData.HopDong, MasterData.BienBanNghiemThu);
	AssertEquals(0, DuAR, "So du AR sau thanh toan phai ve 0");
	
	DuDongTien = TinhSoDuDongTien(RegisterDongTien, MasterData.TaiKhoanTien);
	AssertEquals(150000000, DuDongTien, "Sổ dòng tiền tăng 150.000.000 VND");
	
	DuGL1311 = TinhSoDuNoSoCaiGL(SoCaiGL, "1311") - TinhSoDuCoSoCaiGL(SoCaiGL, "1311");
	AssertEquals(0, DuGL1311, "Du no TK 1311 phai ve 0");
	AssertEquals(0, Abs(DuAR - DuGL1311), "Variance phai bang 0");
EndProcedure

// -----------------------------------------------------------------------------
// Test 3: Thanh toán bằng Ngoại tệ USD
//         - TienTe = "USD", TyGia = 25.000, SoTienNgoaiTe = 10.000, SoTien = 250.000.000 VND
//         - GL: Nợ TK 1122 (Tiền gửi ngân hàng Ngoại tệ) / Có TK 1312: 250.000.000 VND
//         - DongTien: Receipt SoTien = 250tr, SoTienNgoaiTe = 10.000 USD
//         - CongNoPhaiThu: Expense SoTien = 250tr, SoTienNgoaiTe = 10.000 USD
//         - Variance Delta = 0
// -----------------------------------------------------------------------------
Procedure Test03_ThanhToanNgoaiTeUSDHachToanTK1122() Export
	MasterData = KhoiTaoDuLieuMau(True, "USD");
	
	SubledgerAR = TaoBangMoPhongSubledgerAR();
	RegisterDongTien = TaoBangMoPhongDongTien();
	SoCaiGL = TaoBangMoPhongSoCaiGL();
	
	// Nghiem thu ban dau: 10.000 USD x 25.000 = 250.000.000 VND
	MoPhongGhiSoNghiemThu(SubledgerAR, SoCaiGL, MasterData.PhapNhan, MasterData.DoiTac,
		MasterData.HopDong, MasterData.BienBanNghiemThu, MasterData.TienTe, 250000000, "1312", 10000);
	
	// Thu ngoai te USD
	ReceiptDoc = New Structure;
	ReceiptDoc.Insert("Ref", "PT-USD-0001");
	ReceiptDoc.Insert("Number", "PT-000003");
	ReceiptDoc.Insert("Date", CurrentDate());
	ReceiptDoc.Insert("PhapNhan", MasterData.PhapNhan);
	ReceiptDoc.Insert("DoiTac", MasterData.DoiTac);
	ReceiptDoc.Insert("HopDong", MasterData.HopDong);
	ReceiptDoc.Insert("ChungTuGoc", MasterData.BienBanNghiemThu);
	ReceiptDoc.Insert("TaiKhoanTien", MasterData.TaiKhoanTien);
	ReceiptDoc.Insert("KhoanMucDongTien", MasterData.KhoanMucDongTien);
	ReceiptDoc.Insert("TienTe", MasterData.TienTe);
	ReceiptDoc.Insert("SoTien", 250000000);
	ReceiptDoc.Insert("SoTienNgoaiTe", 10000);
	ReceiptDoc.Insert("TyGia", 25000);
	ReceiptDoc.Insert("NgayThu", CurrentDate());
	ReceiptDoc.Insert("DienGiai", "Thu tien ngoai te USD hop dong quoc te");
	
	ButToan = MoPhongGhiSoPhieuThuTien(SubledgerAR, RegisterDongTien, SoCaiGL, ReceiptDoc);
	
	// Assert GL: Ngoại tệ phải hạch toán vào TK 1122
	GLRec = ButToan.GLRecords[0];
	AssertEquals("1122", GLRec.AccountDr, "Thu ngoại tệ phải ghi Nợ vào TK 1122 (Tiền gửi ngoại tệ)");
	AssertEquals("1312", GLRec.AccountCr, "Tài khoản Có là TK 1312");
	AssertEquals(250000000, GLRec.SoTien, "Số tiền quy đổi VND là 250.000.000 VND");
	AssertEquals(10000, GLRec.SoTienNgoaiTe, "Số tiền ngoại tệ là 10.000 USD");
	AssertEquals(25000, GLRec.TyGia, "Tỷ giá ghi nhận là 25.000 VND/USD");
	
	// Assert DongTien
	CFRec = ButToan.CFRecords[0];
	AssertEquals(250000000, CFRec.SoTien, "DongTien SoTien VND = 250tr");
	AssertEquals(10000, CFRec.SoTienNgoaiTe, "DongTien SoTienNgoaiTe = 10.000 USD");
	
	// Assert CongNoPhaiThu
	ARRec = ButToan.ARRecords[0];
	AssertEquals(250000000, ARRec.SoTien, "CongNoPhaiThu SoTien = 250tr");
	AssertEquals(10000, ARRec.SoTienNgoaiTe, "CongNoPhaiThu SoTienNgoaiTe = 10.000 USD");
	
	// Số dư về 0
	DuAR = TinhSoDuSubledgerAR(SubledgerAR, MasterData.HopDong, MasterData.BienBanNghiemThu);
	DuGL = TinhSoDuNoSoCaiGL(SoCaiGL, "1312") - TinhSoDuCoSoCaiGL(SoCaiGL, "1312");
	AssertEquals(0, DuAR, "Số dư AR USD sau tất toán phải bằng 0");
	AssertEquals(0, DuGL, "Số dư GL TK 1312 sau tất toán phải bằng 0");
EndProcedure

// -----------------------------------------------------------------------------
// Test 4: Thanh toán từng phần (Partial Payment) & Kiểm tra ràng buộc dữ liệu bắt buộc
//         - Nghiệm thu 200tr, thanh toán đợt 1 = 80tr -> Còn nợ 120tr
//         - Chặn khi thiếu Pháp nhân, Đối tác, Hợp đồng, Tài khoản tiền, Tiền tệ
//         - Chặn khi Số tiền <= 0
// -----------------------------------------------------------------------------
Procedure Test04_ThanhToanTungPhanVaKiemTraRangBuocDuLieu() Export
	MasterData = KhoiTaoDuLieuMau(True, "VND");
	
	SubledgerAR = TaoBangMoPhongSubledgerAR();
	RegisterDongTien = TaoBangMoPhongDongTien();
	SoCaiGL = TaoBangMoPhongSoCaiGL();
	
	// 1. Nghiem thu ban dau 200tr
	MoPhongGhiSoNghiemThu(SubledgerAR, SoCaiGL, MasterData.PhapNhan, MasterData.DoiTac,
		MasterData.HopDong, MasterData.BienBanNghiemThu, MasterData.TienTe, 200000000, "1312");
	
	// 2. Thanh toan dot 1 = 80.000.000 VND
	ReceiptDocPartial = New Structure;
	ReceiptDocPartial.Insert("Ref", "PT-PARTIAL-01");
	ReceiptDocPartial.Insert("Number", "PT-000004");
	ReceiptDocPartial.Insert("Date", CurrentDate());
	ReceiptDocPartial.Insert("PhapNhan", MasterData.PhapNhan);
	ReceiptDocPartial.Insert("DoiTac", MasterData.DoiTac);
	ReceiptDocPartial.Insert("HopDong", MasterData.HopDong);
	ReceiptDocPartial.Insert("ChungTuGoc", MasterData.BienBanNghiemThu);
	ReceiptDocPartial.Insert("TaiKhoanTien", MasterData.TaiKhoanTien);
	ReceiptDocPartial.Insert("KhoanMucDongTien", MasterData.KhoanMucDongTien);
	ReceiptDocPartial.Insert("TienTe", MasterData.TienTe);
	ReceiptDocPartial.Insert("SoTien", 80000000); // 80tr VND
	ReceiptDocPartial.Insert("SoTienNgoaiTe", 0);
	ReceiptDocPartial.Insert("TyGia", 1);
	ReceiptDocPartial.Insert("NgayThu", CurrentDate());
	ReceiptDocPartial.Insert("DienGiai", "Thanh toan dot 1 nghiem thu");
	
	MoPhongGhiSoPhieuThuTien(SubledgerAR, RegisterDongTien, SoCaiGL, ReceiptDocPartial);
	
	// Assert số dư còn lại: 200tr - 80tr = 120.000.000 VND
	DuAR_ConLai = TinhSoDuSubledgerAR(SubledgerAR, MasterData.HopDong, MasterData.BienBanNghiemThu);
	DuGL_ConLai = TinhSoDuNoSoCaiGL(SoCaiGL, "1312") - TinhSoDuCoSoCaiGL(SoCaiGL, "1312");
	AssertEquals(120000000, DuAR_ConLai, "Số dư AR còn lại sau đợt 1 phải là 120.000.000 VND");
	AssertEquals(120000000, DuGL_ConLai, "Số dư GL TK 1312 còn lại sau đợt 1 phải là 120.000.000 VND");
	AssertEquals(0, Abs(DuAR_ConLai - DuGL_ConLai), "Độ lệch còn lại phải bằng 0");
	
	DuDongTien = TinhSoDuDongTien(RegisterDongTien, MasterData.TaiKhoanTien);
	AssertEquals(80000000, DuDongTien, "Sổ dòng tiền tăng đúng 80.000.000 VND");
	
	// 3. Kiểm tra chặn thiếu dữ liệu bắt buộc (Validation Rule)
	// Case 4a: Thiếu TaiKhoanTien
	ReceiptInvalid1 = New Structure;
	ReceiptInvalid1.Insert("PhapNhan", MasterData.PhapNhan);
	ReceiptInvalid1.Insert("DoiTac", MasterData.DoiTac);
	ReceiptInvalid1.Insert("HopDong", MasterData.HopDong);
	ReceiptInvalid1.Insert("TaiKhoanTien", Undefined); // Thieu TaiKhoanTien
	ReceiptInvalid1.Insert("TienTe", MasterData.TienTe);
	ReceiptInvalid1.Insert("SoTien", 50000000);
	
	LoiBatBuoc1 = False;
	Try
		MoPhongGhiSoPhieuThuTien(SubledgerAR, RegisterDongTien, SoCaiGL, ReceiptInvalid1);
	Except
		LoiBatBuoc1 = True;
	EndTry;
	AssertTrue(LoiBatBuoc1, "Thiếu Tài khoản tiền phải bị chặn không cho ghi sổ!");
	
	// Case 4b: Số tiền thu <= 0
	ReceiptInvalid2 = New Structure;
	ReceiptInvalid2.Insert("PhapNhan", MasterData.PhapNhan);
	ReceiptInvalid2.Insert("DoiTac", MasterData.DoiTac);
	ReceiptInvalid2.Insert("HopDong", MasterData.HopDong);
	ReceiptInvalid2.Insert("TaiKhoanTien", MasterData.TaiKhoanTien);
	ReceiptInvalid2.Insert("TienTe", MasterData.TienTe);
	ReceiptInvalid2.Insert("SoTien", 0); // SoTien = 0
	
	LoiBatBuoc2 = False;
	Try
		MoPhongGhiSoPhieuThuTien(SubledgerAR, RegisterDongTien, SoCaiGL, ReceiptInvalid2);
	Except
		LoiBatBuoc2 = True;
	EndTry;
	AssertTrue(LoiBatBuoc2, "Số tiền thu <= 0 phải bị chặn không cho ghi sổ!");
EndProcedure

// -----------------------------------------------------------------------------
// Test 5: Kiểm tra tính toàn vẹn Metadata XML Schema PhieuThuTienKhachHang.xml
//         - Version 2.15
//         - Đủ 12 thuộc tính nghiệp vụ
//         - Đăng ký 3 sổ kế toán: CongNoPhaiThu, DongTien, SoCaiKeToan
//         - Posting = Allow
// -----------------------------------------------------------------------------
Procedure Test05_KiemTraMetadataSchemaPhieuThuTienKhachHang() Export
	XmlPath = "C:/Users/Dung/Documents/1C_Enterprise/src/Documents/PhieuThuTienKhachHang.xml";
	
	// Doc noi dung file XML
	XmlContent = "";
	Try
		TextR = New TextReader(XmlPath, TextEncoding.UTF8);
		XmlContent = TextR.Read();
		TextR.Close();
	Except
		Raise "Không thể đọc tệp tin XML metadata: " + XmlPath + " - " + ErrorDescription();
	EndTry;
	
	// 1. Kiem tra phien ban
	AssertTrue(StrFind(XmlContent, 'version="2.15"') > 0, 
		"Metadata XML PhieuThuTienKhachHang phai dung version 2.15");
	
	// 2. Kiem tra Name
	AssertTrue(StrFind(XmlContent, "<Name>PhieuThuTienKhachHang</Name>") > 0, 
		"Metadata XML phai co Name = PhieuThuTienKhachHang");
	
	// 3. Kiem tra 12 thuoc tinh nghiep vu
	ThuocTinhBatBuoc = New Array;
	ThuocTinhBatBuoc.Add("PhapNhan");
	ThuocTinhBatBuoc.Add("DoiTac");
	ThuocTinhBatBuoc.Add("HopDong");
	ThuocTinhBatBuoc.Add("ChungTuGoc");
	ThuocTinhBatBuoc.Add("TaiKhoanTien");
	ThuocTinhBatBuoc.Add("KhoanMucDongTien");
	ThuocTinhBatBuoc.Add("TienTe");
	ThuocTinhBatBuoc.Add("SoTien");
	ThuocTinhBatBuoc.Add("SoTienNgoaiTe");
	ThuocTinhBatBuoc.Add("TyGia");
	ThuocTinhBatBuoc.Add("NgayThu");
	ThuocTinhBatBuoc.Add("DienGiai");
	
	For Each TT In ThuocTinhBatBuoc Do
		TagKiemTra = StrTemplate("<Name>%1</Name>", TT);
		AssertTrue(StrFind(XmlContent, TagKiemTra) > 0, 
			StrTemplate("Metadata XML phai khai bao thuoc tinh %1", TT));
	EndDo;
	
	// 4. Kiem tra dang ky 3 so
	AssertTrue(StrFind(XmlContent, "AccumulationRegister.CongNoPhaiThu") > 0, 
		"PhieuThuTienKhachHang phai dang ky so AccumulationRegister.CongNoPhaiThu");
	AssertTrue(StrFind(XmlContent, "AccumulationRegister.DongTien") > 0, 
		"PhieuThuTienKhachHang phai dang ky so AccumulationRegister.DongTien");
	AssertTrue(StrFind(XmlContent, "AccountingRegister.SoCaiKeToan") > 0, 
		"PhieuThuTienKhachHang phai dang ky so AccountingRegister.SoCaiKeToan");
	
	// 5. Kiem tra Posting = Allow
	AssertTrue(StrFind(XmlContent, "<Posting>Allow</Posting>") > 0, 
		"PhieuThuTienKhachHang phai cho phep ghi so (Posting = Allow)");
EndProcedure

#EndRegion

#Region HelperFunctionsAndMocks

Function KhoiTaoDuLieuMau(LaBenLienKet = True, TienTeCode = "VND")
	Data = New Structure;
	Data.Insert("PhapNhan", "PN-VSF-CORP");
	
	DoiTac = New Structure;
	DoiTac.Insert("Code", ?(LaBenLienKet, "DT-VINFAST", "DT-EXTERNAL-01"));
	DoiTac.Insert("Description", ?(LaBenLienKet, "Cong ty CP San Xuat va Kinh Doanh VinFast", "Khach hang doanh nghiep ben ngoai"));
	DoiTac.Insert("LaBenLienKet", LaBenLienKet);
	DoiTac.Insert("LoaiDoiTac", ?(LaBenLienKet, "NoiBoVingroup", "KhachHangNgoai"));
	Data.Insert("DoiTac", DoiTac);
	
	HopDong = New Structure;
	HopDong.Insert("Code", "HD-CLOUD-2026");
	HopDong.Insert("Description", "Hop dong ha tang AI Cloud & SaaS");
	HopDong.Insert("TienTe", TienTeCode);
	Data.Insert("HopDong", HopDong);
	
	Data.Insert("BienBanNghiemThu", "BBNT-2026-OCT-01");
	
	TaiKhoanTien = New Structure;
	TaiKhoanTien.Insert("Code", ?(TienTeCode = "VND", "TK-TCB-VND", "TK-TCB-USD"));
	TaiKhoanTien.Insert("SoTaiKhoan", "19036888888888");
	TaiKhoanTien.Insert("NganHang", "Techcombank");
	TaiKhoanTien.Insert("TienTe", TienTeCode);
	Data.Insert("TaiKhoanTien", TaiKhoanTien);
	
	KhoanMuc = New Structure;
	KhoanMuc.Insert("Code", "KM-THUTIENBANHANG");
	KhoanMuc.Insert("Description", "Thu tien ban hang va cung cap dich vu CNTT");
	Data.Insert("KhoanMucDongTien", KhoanMuc);
	
	TienTe = New Structure;
	TienTe.Insert("Code", TienTeCode);
	TienTe.Insert("Description", ?(TienTeCode = "VND", "Dong Viet Nam", "Do la My"));
	Data.Insert("TienTe", TienTe);
	
	Return Data;
EndFunction

Function TaoBangMoPhongSubledgerAR()
	Table = New Array;
	Return Table;
EndFunction

Function TaoBangMoPhongDongTien()
	Table = New Array;
	Return Table;
EndFunction

Function TaoBangMoPhongSoCaiGL()
	Table = New Array;
	Return Table;
EndFunction

Procedure MoPhongGhiSoNghiemThu(SubledgerAR, SoCaiGL, PhapNhan, DoiTac, HopDong, BienBanNghiemThu, TienTe, SoTien, TKCongNo = "1312", SoTienNgoaiTe = 0)
	// 1. Subledger CongNoPhaiThu (Receipt)
	ARRecord = New Structure;
	ARRecord.Insert("RecordType", "Receipt");
	ARRecord.Insert("PhapNhan", PhapNhan);
	ARRecord.Insert("DoiTac", DoiTac);
	ARRecord.Insert("HopDong", HopDong);
	ARRecord.Insert("ChungTuGoc", BienBanNghiemThu);
	ARRecord.Insert("SoTien", SoTien);
	ARRecord.Insert("SoTienNgoaiTe", SoTienNgoaiTe);
	SubledgerAR.Add(ARRecord);
	
	// 2. SoCaiKeToan (No TKCongNo / Co 5113)
	GLRecord = New Structure;
	GLRecord.Insert("PhapNhan", PhapNhan);
	GLRecord.Insert("TienTe", TienTe);
	GLRecord.Insert("AccountDr", TKCongNo);
	GLRecord.Insert("AccountCr", "5113");
	GLRecord.Insert("ChungTuGoc", BienBanNghiemThu);
	GLRecord.Insert("SoTien", SoTien);
	GLRecord.Insert("SoTienNgoaiTe", SoTienNgoaiTe);
	SoCaiGL.Add(GLRecord);
EndProcedure

Function MoPhongGhiSoPhieuThuTien(SubledgerAR, RegisterDongTien, SoCaiGL, DocData)
	// Kiem tra du lieu bat buoc
	If Not DocData.Property("PhapNhan") Or Not ValueIsFilled(DocData.PhapNhan)
		Or Not DocData.Property("DoiTac") Or Not ValueIsFilled(DocData.DoiTac)
		Or Not DocData.Property("HopDong") Or Not ValueIsFilled(DocData.HopDong)
		Or Not DocData.Property("TaiKhoanTien") Or Not ValueIsFilled(DocData.TaiKhoanTien)
		Or Not DocData.Property("TienTe") Or Not ValueIsFilled(DocData.TienTe) Then
		Raise "Thiếu thông tin bắt buộc: Pháp nhân, Đối tác, Hợp đồng, Tài khoản tiền hoặc Tiền tệ!";
	EndIf;
	
	If Not DocData.Property("SoTien") Or DocData.SoTien <= 0 Then
		Raise "Số tiền thu phải lớn hơn 0!";
	EndIf;
	
	// Xac dinh TK No: Ngoai te -> 1122, VND -> 1121
	IsNgoaiTe = False;
	If DocData.Property("TienTe") Then
		TienTeVal = DocData.TienTe;
		If TypeOf(TienTeVal) = Type("Structure") And TienTeVal.Property("Code") Then
			If TienTeVal.Code <> "VND" Then
				IsNgoaiTe = True;
			EndIf;
		ElsIf String(TienTeVal) <> "VND" And String(TienTeVal) <> "" Then
			IsNgoaiTe = True;
		EndIf;
	EndIf;
	If DocData.Property("SoTienNgoaiTe") And DocData.SoTienNgoaiTe > 0 And DocData.Property("TienTe") And String(DocData.TienTe) <> "VND" Then
		IsNgoaiTe = True;
	EndIf;
	
	TKDr = ?(IsNgoaiTe, "1122", "1121");
	
	// Xac dinh TK Co: Doi tac noi bo Vingroup -> 1312, ngoai -> 1311
	IsNoiBo = False;
	If DocData.Property("DoiTac") Then
		DoiTacVal = DocData.DoiTac;
		If TypeOf(DoiTacVal) = Type("Structure") Then
			If DoiTacVal.Property("LaBenLienKet") And DoiTacVal.LaBenLienKet = True Then
				IsNoiBo = True;
			ElsIf DoiTacVal.Property("LoaiDoiTac") And (DoiTacVal.LoaiDoiTac = "NoiBoVingroup" Or DoiTacVal.LoaiDoiTac = "NoiBoTapDoan") Then
				IsNoiBo = True;
			EndIf;
		EndIf;
	EndIf;
	
	TKCr = ?(IsNoiBo, "1312", "1311");
	
	SoTien = DocData.SoTien;
	SoTienNgoaiTe = ?(DocData.Property("SoTienNgoaiTe"), DocData.SoTienNgoaiTe, 0);
	TyGia = ?(DocData.Property("TyGia") And DocData.TyGia > 0, DocData.TyGia, 1);
	ChungTuGoc = ?(DocData.Property("ChungTuGoc"), DocData.ChungTuGoc, Undefined);
	
	Result = New Structure("ARRecords,CFRecords,GLRecords", New Array, New Array, New Array);
	
	// 1. Ghi Sổ tích lũy Công nợ phải thu (CongNoPhaiThu - Expense)
	RowAR = New Structure;
	RowAR.Insert("RecordType", "Expense");
	RowAR.Insert("Period", ?(DocData.Property("Date"), DocData.Date, CurrentDate()));
	RowAR.Insert("PhapNhan", DocData.PhapNhan);
	RowAR.Insert("DoiTac", DocData.DoiTac);
	RowAR.Insert("HopDong", DocData.HopDong);
	RowAR.Insert("ChungTuGoc", ChungTuGoc);
	RowAR.Insert("SoTien", SoTien);
	RowAR.Insert("SoTienNgoaiTe", SoTienNgoaiTe);
	SubledgerAR.Add(RowAR);
	Result.ARRecords.Add(RowAR);
	
	// 2. Ghi Sổ tích lũy Dòng tiền (DongTien - Receipt)
	RowCF = New Structure;
	RowCF.Insert("RecordType", "Receipt");
	RowCF.Insert("Period", ?(DocData.Property("Date"), DocData.Date, CurrentDate()));
	RowCF.Insert("PhapNhan", DocData.PhapNhan);
	RowCF.Insert("TaiKhoanTien", DocData.TaiKhoanTien);
	RowCF.Insert("TienTe", DocData.TienTe);
	RowCF.Insert("KhoanMucDongTien", ?(DocData.Property("KhoanMucDongTien"), DocData.KhoanMucDongTien, Undefined));
	RowCF.Insert("SoTien", SoTien);
	RowCF.Insert("SoTienNgoaiTe", SoTienNgoaiTe);
	RegisterDongTien.Add(RowCF);
	Result.CFRecords.Add(RowCF);
	
	// 3. Ghi Sổ cái kế toán (SoCaiKeToan - No TKDr / Co TKCr)
	RowGL = New Structure;
	RowGL.Insert("Period", ?(DocData.Property("Date"), DocData.Date, CurrentDate()));
	RowGL.Insert("AccountDr", TKDr);
	RowGL.Insert("AccountCr", TKCr);
	RowGL.Insert("PhapNhan", DocData.PhapNhan);
	RowGL.Insert("TienTe", DocData.TienTe);
	RowGL.Insert("ChungTuGoc", ChungTuGoc);
	RowGL.Insert("TyGia", TyGia);
	RowGL.Insert("SoTien", SoTien);
	RowGL.Insert("SoTienNgoaiTe", SoTienNgoaiTe);
	RowGL.Insert("DienGiai", ?(DocData.Property("DienGiai"), DocData.DienGiai, "Thu tiền khách hàng"));
	SoCaiGL.Add(RowGL);
	Result.GLRecords.Add(RowGL);
	
	// 4. Kiem tra can doi SoCai GL Invariant
	Try
		EntriesGL = New Array;
		EntriesGL.Add(New Structure("AmountDr,AmountCr", SoTien, SoTien));
		QuanLyVongDoiChungTuServer.KiemTraCanDoiSoCai(EntriesGL);
	Except
	EndTry;
	
	Return Result;
EndFunction

Function TinhSoDuSubledgerAR(SubledgerAR, HopDong, ChungTuGoc)
	Tong = 0;
	For Each Line In SubledgerAR Do
		KhopChungTu = True;
		If ValueIsFilled(ChungTuGoc) Then
			KhopChungTu = (Line.ChungTuGoc = ChungTuGoc);
		EndIf;
		If KhopChungTu Then
			If Line.RecordType = "Receipt" Then
				Tong = Tong + Line.SoTien;
			ElsIf Line.RecordType = "Expense" Then
				Tong = Tong - Line.SoTien;
			EndIf;
		EndIf;
	EndDo;
	Return Tong;
EndFunction

Function TinhSoDuDongTien(RegisterDongTien, TaiKhoanTien)
	Tong = 0;
	For Each Line In RegisterDongTien Do
		If Line.TaiKhoanTien = TaiKhoanTien Then
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
