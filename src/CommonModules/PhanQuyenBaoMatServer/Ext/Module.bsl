// Common Module: PhanQuyenBaoMatServer
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Kiem soat bao mat toan dien: Maker-Checker Invariant, Segregation of Duties (SoD),
//           va kiem soat quyen truy cap bao cao tai chinh cao cap (Huong 2).

#Region PublicInterface

// Kiem tra Invariant Maker-Checker: Nguoi lap khong duoc phep tu duyet
Procedure KiemTraMakerChecker(Val NguoiLap, Val NguoiDuyet, Val TenSessionUser = "") Export
	If Not ValueIsFilled(NguoiLap) Then
		WriteLogEvent("Security.MakerChecker", EventLogLevel.Warning,,, "Vi phạm nguyên tắc Maker-Checker: Thiếu thông tin Người lập!");
		Raise "Vi phạm nguyên tắc Maker-Checker: Thiếu thông tin Người lập/tạo chứng từ!";
	EndIf;
	If Not ValueIsFilled(NguoiDuyet) Then
		WriteLogEvent("Security.MakerChecker", EventLogLevel.Warning,,, "Vi phạm nguyên tắc Maker-Checker: Thiếu thông tin Người duyệt!");
		Raise "Vi phạm nguyên tắc Maker-Checker: Chưa xác định người dùng thực hiện phê duyệt!";
	EndIf;
	
	StrLap = TrimAll(String(NguoiLap));
	StrDuyet = TrimAll(String(NguoiDuyet));
	
	If StrLap = StrDuyet Then
		WriteLogEvent("Security.MakerChecker", EventLogLevel.Warning,,, StrTemplate("Vi phạm Maker-Checker: Người lập (%1) tự phê duyệt!", StrLap));
		Raise "Vi phạm nguyên tắc Maker-Checker: Người tạo/lập không thể tự phê duyệt chứng từ!";
	EndIf;
	
	If StrDuyet = "Admin" Or StrDuyet = "QuanTriHeThong" Then
		WriteLogEvent("Security.MakerChecker", EventLogLevel.Warning,,, "Vi phạm Maker-Checker: Admin kỹ thuật không được tự cấp chữ ký kế toán phê duyệt!");
		Raise "Admin kỹ thuật có thể bảo trì cấu hình nhưng không tự cấp chữ ký kế toán phê duyệt chứng từ tài chính!";
	EndIf;

	// Xac minh danh tinh phien 1C thuc te
	EffectiveSession = ?(ValueIsFilled(TenSessionUser), TrimAll(TenSessionUser), UserName());
	If ValueIsFilled(EffectiveSession) Then
		If EffectiveSession = StrLap Then
			WriteLogEvent("Security.MakerChecker", EventLogLevel.Warning,,, StrTemplate("Vi phạm Maker-Checker: Phiên người dùng '%1' (Người lập) cố gắng thực hiện phê duyệt!", EffectiveSession));
			Raise "Vi phạm nguyên tắc Maker-Checker: Người dùng đăng nhập hiện tại là Người lập, không được phép phê duyệt!";
		EndIf;
		
		If EffectiveSession = "Admin" Then
			WriteLogEvent("Security.MakerChecker", EventLogLevel.Warning,,, "Vi phạm Maker-Checker: Phiên Admin không được phép tự ký duyệt chứng từ tài chính!");
			Raise "Admin kỹ thuật không được phép tự ký duyệt chứng từ tài chính kế toán!";
		EndIf;
		
		If EffectiveSession <> StrDuyet Then
			WriteLogEvent("Security.MakerChecker", EventLogLevel.Warning,,, StrTemplate("Vi phạm Maker-Checker: Phiên '%1' không khớp người duyệt '%2'!", EffectiveSession, StrDuyet));
			Raise StrTemplate("Vi phạm nguyên tắc Maker-Checker: Phiên người dùng '%1' không phải là Người duyệt đã chỉ định ('%2')!", EffectiveSession, StrDuyet);
		EndIf;
	EndIf;
EndProcedure

// Kiem tra Segregation of Duties (Phan dinh nhiem vu AR vs AP va cac vai tro)
Procedure KiemTraQuyenChungTu(Val ChungTu, Val ThaoTac, Val TenNguoiDung = "") Export
	CurrentUserStr = ?(ValueIsFilled(TenNguoiDung), TrimAll(TenNguoiDung), UserName());
	
	// Tai khoan Admin duoc toan quyen ky thuat
	If CurrentUserStr = "Admin" Or NguoiDungCoRole(CurrentUserStr, "QuanTriHeThong") Then
		Return;
	EndIf;
	
	// Xac dinh loai chung tu
	DocTypeName = "";
	If TypeOf(ChungTu) = Type("String") Then
		DocTypeName = ChungTu;
	ElsIf TypeOf(ChungTu) = Type("Structure") Then
		If ChungTu.Property("MetadataName") Then
			DocTypeName = ChungTu.MetadataName;
		ElsIf ChungTu.Property("DocumentType") Then
			DocTypeName = ChungTu.DocumentType;
		EndIf;
	Else
		Try
			DocTypeName = ChungTu.Metadata().Name;
		Except
			DocTypeName = String(TypeOf(ChungTu));
		EndTry;
	EndIf;
	
	// Danh sach chung tu AR
	LaChungTuAR = (DocTypeName = "BienBanNghiemThuGiaiDoan" 
		Or DocTypeName = "HoaDonGTGTDauRa" 
		Or DocTypeName = "PhieuThuTienKhachHang"
		Or DocTypeName = "CongNoPhaiThu");
		
	// Danh sach chung tu AP
	LaChungTuAP = (DocTypeName = "HoaDonNhaCungCap" 
		Or DocTypeName = "UyNhiemChi" 
		Or DocTypeName = "NghiemThuThauPhu" 
		Or DocTypeName = "DeNghiThanhToanDichVu"
		Or DocTypeName = "CongNoPhaiTra");
		
	// Danh sach chung tu Netting / Doi soat
	LaChungTuNetting = (DocTypeName = "CanTruCongNoNoiBo"
		Or DocTypeName = "BangKeDoiSoatKenhThanhToan"
		Or DocTypeName = "YeuCauHoanTienChiHo");

	// 1. Kiem tra rang buoc SoD voi KeToanPhaiThu (ketoan_ar)
	If CurrentUserStr = "ketoan_ar" Or NguoiDungCoRole(CurrentUserStr, "KeToanPhaiThu") Then
		If LaChungTuAP Then
			WriteLogEvent("Security.SoD", EventLogLevel.Warning,,, StrTemplate("Vi phạm SoD: Kế toán AR (%1) cố can thiệp chứng từ AP (%2)!", CurrentUserStr, DocTypeName));
			Raise "Vi phạm phân định trách nhiệm (Segregation of Duties): Kế toán Phải thu (AR) không được phép ghi sổ, sửa hoặc can thiệp chứng từ Phải trả (AP)!";
		EndIf;
	EndIf;
	
	// 2. Kiem tra rang buoc SoD voi KeToanPhaiTra (ketoan_ap)
	If CurrentUserStr = "ketoan_ap" Or NguoiDungCoRole(CurrentUserStr, "KeToanPhaiTra") Then
		If LaChungTuAR Then
			WriteLogEvent("Security.SoD", EventLogLevel.Warning,,, StrTemplate("Vi phạm SoD: Kế toán AP (%1) cố can thiệp chứng từ AR (%2)!", CurrentUserStr, DocTypeName));
			Raise "Vi phạm phân định trách nhiệm (Segregation of Duties): Kế toán Phải trả (AP) không được phép ghi sổ, sửa hoặc can thiệp chứng từ Phải thu (AR)!";
		EndIf;
	EndIf;
	
	// 3. Chuyen vien doi soat khong duoc truc tiep xuat chung tu AR/AP ma phai thong qua chung tu netting
	If CurrentUserStr = "chuyenvien_doisoat" Or NguoiDungCoRole(CurrentUserStr, "ChuyenVienDoiSoatTapDoan") Then
		If ThaoTac = "GhiSo" And (LaChungTuAR Or LaChungTuAP) And Not LaChungTuNetting Then
			WriteLogEvent("Security.SoD", EventLogLevel.Warning,,, StrTemplate("Vi phạm SoD: Chuyên viên đối soát (%1) cố ghi sổ trực tiếp AR/AP (%2)!", CurrentUserStr, DocTypeName));
			Raise "Chuyên viên Đối soát chỉ có quyền thao tác trên Chứng từ Cấn trừ và Bảng kê đối soát!";
		EndIf;
	EndIf;
	
	// 4. Cac vai tro ky thuat (PM, TechLead, IT Director) khong duoc phep ghi so tai chinh
	If CurrentUserStr = "pm_duan" Or CurrentUserStr = "techlead_kythuat" Or CurrentUserStr = "it_director"
		Or NguoiDungCoRole(CurrentUserStr, "ProjectManager_QuanLyDuAn") 
		Or NguoiDungCoRole(CurrentUserStr, "TechLead_KiemTraKyThuat") 
		Or NguoiDungCoRole(CurrentUserStr, "ITDirector_GiamDocHaTang") Then
		
		If ThaoTac = "GhiSo" Or ThaoTac = "Posting" Then
			WriteLogEvent("Security.SoD", EventLogLevel.Warning,,, StrTemplate("Vi phạm SoD: Vai trò kỹ thuật (%1) cố ghi sổ chứng từ kế toán (%2)!", CurrentUserStr, DocTypeName));
			Raise "Nhân sự kỹ thuật và Quản lý dự án không có thẩm quyền ghi sổ chứng từ kế toán!";
		EndIf;
	EndIf;
EndProcedure

// Kiem tra phan quyen truy cap bao cao tai chinh cao cap
// Quy tac: "Chỉ CFO, Kế toán trưởng mới xem được toàn bộ Sổ cái và Ma trận cấn trừ Tập đoàn."
Procedure KiemTraQuyenBaoCao(Val TenBaoCao, Val TenNguoiDung = "") Export
	CurrentUserStr = ?(ValueIsFilled(TenNguoiDung), TrimAll(TenNguoiDung), UserName());
	
	// Admin toan quyen
	If CurrentUserStr = "Admin" Or NguoiDungCoRole(CurrentUserStr, "QuanTriHeThong") Then
		Return;
	EndIf;
	
	BaoCaoCaoCap = (TenBaoCao = "MaTranCanTruNoiBoTapDoan" 
		Or TenBaoCao = "SoCaiKeToan" 
		Or TenBaoCao = "AccountingRegister.SoCaiKeToan"
		Or TenBaoCao = "Report.MaTranCanTruNoiBoTapDoan");
		
	If BaoCaoCaoCap Then
		// Chi CFO, Ke toan truong hoac Admin duoc phep
		DuocPhep = (CurrentUserStr = "cfo_giamdoc" 
			Or CurrentUserStr = "ketoan_truong"
			Or NguoiDungCoRole(CurrentUserStr, "GiamDocTaiChinh_CFO")
			Or NguoiDungCoRole(CurrentUserStr, "KeToanTruong")
			Or NguoiDungCoRole(CurrentUserStr, "QuanTriHeThong"));
			
		If Not DuocPhep Then
			Raise "Vi phạm chính sách bảo mật: Chỉ CFO và Kế toán trưởng mới có quyền truy cập toàn bộ Sổ cái và Ma trận cấn trừ Tập đoàn!";
		EndIf;
	EndIf;
EndProcedure

// Bo Test tong hop toan dien cac dieu kien bao mat
Function ThucThiKiemThuBaoMatToanDien() Export
	LogLines = New Array;
	LogLines.Add("=== BAT DAU KIEM THU BAO MAT & PHAN QUYEN TOAN DIEN (SUITE 8 ROLES) ===");
	
	TongTestCase = 0;
	TestPass = 0;
	TestFail = 0;
	
	// --- TEST 1: Kiem tra su ton tai cua 8 User + Admin ---
	TongTestCase = TongTestCase + 1;
	UsersOK = UserProvisioningServer.KiemTraNguoiDungDaKhoiTao();
	If UsersOK Then
		TestPass = TestPass + 1;
		LogLines.Add("[PASS] Test 1: Khoi tao day du 8 nguoi dung + Admin voi dung Role.");
	Else
		TestFail = TestFail + 1;
		LogLines.Add("[FAIL] Test 1: Danh sach nguoi dung hoac Role khong khop!");
	EndIf;
	
	// --- TEST 2: Maker-Checker Invariant ---
	TongTestCase = TongTestCase + 1;
	MakerCheckerBiChan = False;
	Try
		KiemTraMakerChecker("ketoan_ap", "ketoan_ap");
	Except
		MakerCheckerBiChan = True;
	EndTry;
	
	If MakerCheckerBiChan Then
		TestPass = TestPass + 1;
		LogLines.Add("[PASS] Test 2: Maker-Checker Invariant (Nguoi lap tu duyet bi chan 100%).");
	Else
		TestFail = TestFail + 1;
		LogLines.Add("[FAIL] Test 2: Maker-Checker khong chan nguoi lap tu duyet!");
	EndIf;

	// --- TEST 3: Maker-Checker khi 2 nguoi khac nhau hop le ---
	TongTestCase = TongTestCase + 1;
	MakerCheckerHopLe = True;
	Try
		KiemTraMakerChecker("ketoan_ap", "ketoan_truong", "ketoan_truong");
	Except
		MakerCheckerHopLe = False;
	EndTry;
	
	If MakerCheckerHopLe Then
		TestPass = TestPass + 1;
		LogLines.Add("[PASS] Test 3: Maker-Checker phe duyet hop le (Nguoi lap khac Nguoi duyet).");
	Else
		TestFail = TestFail + 1;
		LogLines.Add("[FAIL] Test 3: Phe duyet hop le bi chan sai sot!");
	EndIf;

	// --- TEST 4: SoD - Kế toán AR ghi sổ AP bị chặn ---
	TongTestCase = TongTestCase + 1;
	ARVaoAPBiChan = False;
	Try
		KiemTraQuyenChungTu("HoaDonNhaCungCap", "GhiSo", "ketoan_ar");
	Except
		ARVaoAPBiChan = True;
	EndTry;
	
	If ARVaoAPBiChan Then
		TestPass = TestPass + 1;
		LogLines.Add("[PASS] Test 4: SoD - Ke toan AR can thiep chung tu AP bi chan tuyet doi.");
	Else
		TestFail = TestFail + 1;
		LogLines.Add("[FAIL] Test 4: SoD long leo, Ke toan AR can thiep duoc chung tu AP!");
	EndIf;

	// --- TEST 5: SoD - Kế toán AP ghi sổ AR bị chặn ---
	TongTestCase = TongTestCase + 1;
	APVaoARBiChan = False;
	Try
		KiemTraQuyenChungTu("HoaDonGTGTDauRa", "GhiSo", "ketoan_ap");
	Except
		APVaoARBiChan = True;
	EndTry;
	
	If APVaoARBiChan Then
		TestPass = TestPass + 1;
		LogLines.Add("[PASS] Test 5: SoD - Ke toan AP can thiep chung tu AR bi chan tuyet doi.");
	Else
		TestFail = TestFail + 1;
		LogLines.Add("[FAIL] Test 5: SoD long leo, Ke toan AP can thiep duoc chung tu AR!");
	EndIf;

	// --- TEST 6: SoD - Thao tác hợp lệ của AR trên AR và AP trên AP ---
	TongTestCase = TongTestCase + 1;
	ChinhQuyenHopLe = True;
	Try
		KiemTraQuyenChungTu("HoaDonGTGTDauRa", "GhiSo", "ketoan_ar");
		KiemTraQuyenChungTu("HoaDonNhaCungCap", "GhiSo", "ketoan_ap");
		KiemTraQuyenChungTu("CanTruCongNoNoiBo", "GhiSo", "chuyenvien_doisoat");
	Except
		ChinhQuyenHopLe = False;
	EndTry;
	
	If ChinhQuyenHopLe Then
		TestPass = TestPass + 1;
		LogLines.Add("[PASS] Test 6: Dung quyen chuyen mon thuc thi chuan xac (AR->AR, AP->AP, Netting->Netting).");
	Else
		TestFail = TestFail + 1;
		LogLines.Add("[FAIL] Test 6: Dung quyen chuyen mon nhung bi chan nham!");
	EndIf;

	// --- TEST 7: Nhân sự kỹ thuật (PM, TechLead) ghi sổ kế toán bị chặn ---
	TongTestCase = TongTestCase + 1;
	KyThuatGhiSoBiChan = False;
	Try
		KiemTraQuyenChungTu("HoaDonNhaCungCap", "GhiSo", "pm_duan");
	Except
		KyThuatGhiSoBiChan = True;
	EndTry;
	
	If KyThuatGhiSoBiChan Then
		TestPass = TestPass + 1;
		LogLines.Add("[PASS] Test 7: Phan dinh ky thuat vs tai chinh (PM khong duoc ghi so ke toan).");
	Else
		TestFail = TestFail + 1;
		LogLines.Add("[FAIL] Test 7: PM ghi so ke toan khong bi chan!");
	EndIf;

	// --- TEST 8: Phân quyền báo cáo - AR/AP truy cập Sổ cái/Ma trận bị chặn ---
	TongTestCase = TongTestCase + 1;
	BaoCaoKhongHopLeBiChan = False;
	Try
		KiemTraQuyenBaoCao("MaTranCanTruNoiBoTapDoan", "ketoan_ar");
	Except
		BaoCaoKhongHopLeBiChan = True;
	EndTry;
	
	If BaoCaoKhongHopLeBiChan Then
		TestPass = TestPass + 1;
		LogLines.Add("[PASS] Test 8: Bao mat bao cao (Ke toan AR khong duoc xem Ma tran can tru Tap doan).");
	Else
		TestFail = TestFail + 1;
		LogLines.Add("[FAIL] Test 8: Ke toan AR xem trai phep Ma tran can tru!");
	EndIf;

	// --- TEST 9: Phân quyền báo cáo - CFO và Kế toán trưởng truy cập Sổ cái/Ma trận thành công ---
	TongTestCase = TongTestCase + 1;
	LanhDaoXemBaoCaoOK = True;
	Try
		KiemTraQuyenBaoCao("MaTranCanTruNoiBoTapDoan", "cfo_giamdoc");
		KiemTraQuyenBaoCao("SoCaiKeToan", "ketoan_truong");
	Except
		LanhDaoXemBaoCaoOK = False;
	EndTry;
	
	If LanhDaoXemBaoCaoOK Then
		TestPass = TestPass + 1;
		LogLines.Add("[PASS] Test 9: CFO va Ke toan truong toan quyen truy cap So cai va Bao cao cap cao.");
	Else
		TestFail = TestFail + 1;
		LogLines.Add("[FAIL] Test 9: CFO hoac Ke toan truong bi chan quyen bao cao!");
	EndIf;

	// Tong ket
	LogLines.Add(StrTemplate("=== TONG KET KIEM THU BAO MAT: %1/%2 PASS (Thanh cong %3 phan tram) ===", 
		TestPass, TongTestCase, Round(TestPass * 100 / TongTestCase, 1)));
	
	If TestPass = TongTestCase Then
		LogLines.Add("STATUS: SECURITY_TESTS_PASS_100%");
		WriteLogEvent("SecurityTesting.Summary", EventLogLevel.Information,,, "SECURITY_TESTS_PASS_100%");
	Else
		LogLines.Add("STATUS: SECURITY_TESTS_FAILED");
		WriteLogEvent("SecurityTesting.Summary", EventLogLevel.Error,,, "SECURITY_TESTS_FAILED");
	EndIf;
	
	GhiLogRaFile("security_test_results.log", LogLines);
	Return (TestPass = TongTestCase);
EndFunction

// ============================================================================
// TASK 2 RUNTIME AUDIT TEST SUITE (10 TEST CASES: 9 NEGATIVE + 1 POSITIVE)
// ============================================================================

Function ThucThiKiemThuTask2Runtime() Export
	LogLines = New Array;
	LogLines.Add("=== BAT DAU KIEM THU TASK 2: MAKER-CHECKER, SOD VA TRANG THAI DA LUU ===");
	LogLines.Add("Thoi gian: " + CurrentDate());
	
	TongTest = 0;
	PassCount = 0;
	FailCount = 0;
	
	// TEST 1 (Am): Maker = Checker (ketoan_ap == ketoan_ap)
	TongTest = TongTest + 1;
	BiChan = False;
	Try
		KiemTraMakerCheckerToanDien("ketoan_ap", "ketoan_ap", "ketoan_truong");
	Except
		BiChan = True;
	EndTry;
	If BiChan Then
		PassCount = PassCount + 1;
		LogLines.Add("[PASS] Test 1: Maker = Checker bi tu choi tuyet doi.");
	Else
		FailCount = FailCount + 1;
		LogLines.Add("[FAIL] Test 1: Maker = Checker khong bi chan!");
	EndIf;
	
	// TEST 2 (Am): Nguoi duyet gia mao (Session user != NguoiDuyet)
	TongTest = TongTest + 1;
	BiChan = False;
	Try
		KiemTraMakerCheckerToanDien("ketoan_ap", "ketoan_truong", "ketoan_ap");
	Except
		BiChan = True;
	EndTry;
	If BiChan Then
		PassCount = PassCount + 1;
		LogLines.Add("[PASS] Test 2: Session user khac NguoiDuyet bi tu choi tuyet doi.");
	Else
		FailCount = FailCount + 1;
		LogLines.Add("[FAIL] Test 2: Cho phep Session user khac NguoiDuyet tu duyet!");
	EndIf;
	
	// TEST 3 (Am): Admin tu duyet / tu ky chung tu tai chinh (NguoiDuyet = 'Admin')
	TongTest = TongTest + 1;
	BiChan = False;
	Try
		KiemTraMakerCheckerToanDien("ketoan_ap", "Admin", "Admin");
	Except
		BiChan = True;
	EndTry;
	If BiChan Then
		PassCount = PassCount + 1;
		LogLines.Add("[PASS] Test 3: Admin ky duyet chung tu tai chinh bi tu choi tuyet doi.");
	Else
		FailCount = FailCount + 1;
		LogLines.Add("[FAIL] Test 3: Admin duoc phep ky duyet chung tu tai chinh!");
	EndIf;
	
	// TEST 4 (Am): Nhay coc trang thai tu DuThao sang DaGhiSo tren chung tu da luu trong CSDL
	TongTest = TongTest + 1;
	BiChan = False;
	Try
		KiemTraNhayCocTrangThaiRuntime();
	Except
		BiChan = True;
	EndTry;
	If BiChan Then
		PassCount = PassCount + 1;
		LogLines.Add("[PASS] Test 4: Nhay coc trang thai tu DuThao sang DaGhiSo bi tu choi.");
	Else
		FailCount = FailCount + 1;
		LogLines.Add("[FAIL] Test 4: Nhay coc trang thai khong bi chan!");
	EndIf;
	
	// TEST 5 (Am): DataExchange.Load bypass luu DaGhiSo ma Posted = False
	TongTest = TongTest + 1;
	BiChan = False;
	Try
		KiemTraDataExchangeLoadBypassRuntime();
	Except
		BiChan = True;
	EndTry;
	If BiChan Then
		PassCount = PassCount + 1;
		LogLines.Add("[PASS] Test 5: DataExchange.Load bypass luu DaGhiSo unposted bi tu choi.");
	Else
		FailCount = FailCount + 1;
		LogLines.Add("[FAIL] Test 5: DataExchange.Load bypass luu DaGhiSo unposted thanh cong!");
	EndIf;
	
	// TEST 6 (Am): Luu trang thai DaGhiSo/DaCanTru voi WriteMode = Write (Posted = False)
	TongTest = TongTest + 1;
	BiChan = False;
	Try
		KiemTraLuuDaGhiSoUnpostedRuntime();
	Except
		BiChan = True;
	EndTry;
	If BiChan Then
		PassCount = PassCount + 1;
		LogLines.Add("[PASS] Test 6: Luu DaGhiSo/DaCanTru voi Posted=False bi tu choi.");
	Else
		FailCount = FailCount + 1;
		LogLines.Add("[FAIL] Test 6: Cho phep luu DaGhiSo/DaCanTru voi Posted=False!");
	EndIf;
	
	// TEST 7 (Am): SoD - Ke toan AR ghi so chung tu AP
	TongTest = TongTest + 1;
	BiChan = False;
	Try
		KiemTraQuyenChungTu("HoaDonNhaCungCap", "GhiSo", "ketoan_ar");
	Except
		BiChan = True;
	EndTry;
	If BiChan Then
		PassCount = PassCount + 1;
		LogLines.Add("[PASS] Test 7: SoD - Ke toan AR ghi so AP bi tu choi.");
	Else
		FailCount = FailCount + 1;
		LogLines.Add("[FAIL] Test 7: SoD - Ke toan AR ghi so AP khong bi chan!");
	EndIf;
	
	// TEST 8 (Am): SoD - Ke toan AP ghi so chung tu AR
	TongTest = TongTest + 1;
	BiChan = False;
	Try
		KiemTraQuyenChungTu("HoaDonGTGTDauRa", "GhiSo", "ketoan_ap");
	Except
		BiChan = True;
	EndTry;
	If BiChan Then
		PassCount = PassCount + 1;
		LogLines.Add("[PASS] Test 8: SoD - Ke toan AP ghi so AR bi tu choi.");
	Else
		FailCount = FailCount + 1;
		LogLines.Add("[FAIL] Test 8: SoD - Ke toan AP ghi so AR khong bi chan!");
	EndIf;
	
	// TEST 9 (Am): SoD - PM / TechLead ghi so tai chinh
	TongTest = TongTest + 1;
	BiChan = False;
	Try
		KiemTraQuyenChungTu("HoaDonNhaCungCap", "GhiSo", "pm_duan");
	Except
		BiChan = True;
	EndTry;
	If BiChan Then
		PassCount = PassCount + 1;
		LogLines.Add("[PASS] Test 9: SoD - PM ghi so tai chinh bi tu choi.");
	Else
		FailCount = FailCount + 1;
		LogLines.Add("[FAIL] Test 9: SoD - PM ghi so tai chinh khong bi chan!");
	EndIf;
	
	// TEST 10 (Duong): Quy trinh tuan tu hop le
	TongTest = TongTest + 1;
	HopLePass = False;
	Try
		KiemTraQuyTrinhTuanTuHopLeRuntime();
		HopLePass = True;
	Except
		ErrDetail = DetailErrorDescription(ErrorInfo());
		WriteLogEvent("Task2Test.Error", EventLogLevel.Warning,,, ErrDetail);
	EndTry;
	If HopLePass Then
		PassCount = PassCount + 1;
		LogLines.Add("[PASS] Test 10: Quy trinh tuan tu hop le thanh cong.");
	Else
		FailCount = FailCount + 1;
		LogLines.Add("[FAIL] Test 10: " + ErrDetail);
	EndIf;
	
	LogLines.Add(StrTemplate("=== TONG KET TASK 2: %1/%2 PASS (%3 FAIL) ===", PassCount, TongTest, FailCount));
	If FailCount = 0 Then
		LogLines.Add("STATUS: TASK2_SECURITY_PASS_100%");
		WriteLogEvent("Task2Test.Summary", EventLogLevel.Information,,, "TASK2_SECURITY_PASS_100%");
	Else
		LogLines.Add("STATUS: TASK2_SECURITY_FAILED");
		WriteLogEvent("Task2Test.Summary", EventLogLevel.Error,,, StrTemplate("TASK2_SECURITY_FAILED_%1_FAILURES", FailCount));
	EndIf;
	
	For Each Line In LogLines Do
		WriteLogEvent("Task2Test.Result", EventLogLevel.Information,,, Line);
	EndDo;
	GhiLogRaFile("task2_test_results.log", LogLines);
	Return (FailCount = 0);
EndFunction

Procedure KiemTraMakerCheckerToanDien(Val NguoiLap, Val NguoiDuyet, Val CurrentSessionUser = "") Export
	KiemTraMakerChecker(NguoiLap, NguoiDuyet, CurrentSessionUser);
EndProcedure

// Dien thong tin du lieu hop le cho hoa don AP test
Procedure DienThongTinAPMau(Doc) Export
	Doc.PhapNhan = Catalogs.PhapNhan.FindByCode("PN-VSF");
	If Not ValueIsFilled(Doc.PhapNhan) Then
		Doc.PhapNhan = Catalogs.PhapNhan.FindByCode("PN_VSF");
	EndIf;
	If Not ValueIsFilled(Doc.PhapNhan) Then
		Q_PN = New Query("SELECT TOP 1 Ref FROM Catalog.PhapNhan");
		T_PN = Q_PN.Execute().Unload();
		If T_PN.Count() > 0 Then
			Doc.PhapNhan = T_PN[0].Ref;
		EndIf;
	EndIf;
	
	Doc.DoiTac = Catalogs.DoiTac.FindByCode("TEST_NCC_AWS");
	If Not ValueIsFilled(Doc.DoiTac) Then
		Doc.DoiTac = Catalogs.DoiTac.FindByCode("NCC_AWS");
	EndIf;
	If Not ValueIsFilled(Doc.DoiTac) Then
		Q_DT = New Query("SELECT TOP 1 Ref FROM Catalog.DoiTac");
		T_DT = Q_DT.Execute().Unload();
		If T_DT.Count() > 0 Then
			Doc.DoiTac = T_DT[0].Ref;
		EndIf;
	EndIf;
	
	Doc.HopDong = Catalogs.HopDong.FindByCode("HD-TEST_NCC_AWS-2025");
	If Not ValueIsFilled(Doc.HopDong) Then
		Doc.HopDong = Catalogs.HopDong.FindByCode("HD_NCC_AWS");
	EndIf;
	If Not ValueIsFilled(Doc.HopDong) Then
		Q_HD = New Query("SELECT TOP 1 Ref FROM Catalog.HopDong WHERE ChuSoHuu = &DoiTac");
		Q_HD.SetParameter("DoiTac", Doc.DoiTac);
		T_HD = Q_HD.Execute().Unload();
		If T_HD.Count() > 0 Then
			Doc.HopDong = T_HD[0].Ref;
		Else
			Q_HD2 = New Query("SELECT TOP 1 Ref FROM Catalog.HopDong");
			T_HD2 = Q_HD2.Execute().Unload();
			If T_HD2.Count() > 0 Then
				Doc.HopDong = T_HD2[0].Ref;
			EndIf;
		EndIf;
	EndIf;
	
	Doc.TienTe = Catalogs.TienTe.FindByCode("VND");
	If Not ValueIsFilled(Doc.TienTe) Then
		Q_TT = New Query("SELECT TOP 1 Ref FROM Catalog.TienTe WHERE Code = &Code");
		Q_TT.SetParameter("Code", "VND");
		T_TT = Q_TT.Execute().Unload();
		If T_TT.Count() > 0 Then
			Doc.TienTe = T_TT[0].Ref;
		EndIf;
	EndIf;
	Doc.TyGia = 1;
EndProcedure

Procedure KiemTraMakerSessionRuntime() Export
	WriteLogEvent("Task2Test.Maker", EventLogLevel.Information,,, "BAT DAU KIEM THU MAKER SESSION: " + UserName());
	
	// Ca 1 (Am): ketoan_ap tu duyet chung tu cua chinh minh
	BiChan1 = False;
	Try
		KiemTraMakerChecker("ketoan_ap", "ketoan_ap", UserName());
	Except
		BiChan1 = True;
	EndTry;
	If Not BiChan1 Then
		Raise "LỖI BẢO MẬT: ketoan_ap tự duyệt chứng từ của chính mình thành công!";
	EndIf;
	WriteLogEvent("Task2Test.Maker", EventLogLevel.Information,,, "[PASS] Test 1: ketoan_ap tu duyet bi tu choi tuyet doi.");
	
	// Ca 2 (Am): ketoan_ap tu y ghi so truc tiep chung tu Chua duyet
	BiChan2 = False;
	Try
		QuanLyVongDoiChungTuServer.KiemTraChuyenTrangThai(New Structure("Author, TrangThai", "ketoan_ap", "DuThao"), "DaGhiSo", UserName(), DocumentWriteMode.Posting);
	Except
		BiChan2 = True;
	EndTry;
	If Not BiChan2 Then
		Raise "LỖI BẢO MẬT: ketoan_ap nhảy cóc trạng thái từ DuThao sang DaGhiSo thành công!";
	EndIf;
	WriteLogEvent("Task2Test.Maker", EventLogLevel.Information,,, "[PASS] Test 2: ketoan_ap nhay coc sang DaGhiSo bi tu choi tuyet doi.");
	
	// Ca 3 (Duong): ketoan_ap lap chung tu hop le o trang thai ChoKeToanAP
	// Xoa chung tu test cu neu co
	Q_Old = New Query("SELECT Ref FROM Document.HoaDonNhaCungCap WHERE Number = &DocNumber");
	Q_Old.SetParameter("DocNumber", "T2-WORKFLOW-TEST");
	T_Old = Q_Old.Execute().Unload();
	For Each R_Old In T_Old Do
		ObjDel = R_Old.Ref.GetObject();
		If ObjDel.Posted Then
			ObjDel.Write(DocumentWriteMode.UndoPosting);
		EndIf;
		ObjDel.Delete();
	EndDo;

	Doc3 = Documents.HoaDonNhaCungCap.CreateDocument();
	Doc3.Date = CurrentDate();
	Doc3.Number = "T2-WORKFLOW-TEST";
	Doc3.SoHoaDon = "INV-T2-001";
	Doc3.NgayHoaDon = BegOfDay(CurrentDate());
	Doc3.NguoiLap = "ketoan_ap";
	Doc3.NguoiDuyet = "ketoan_truong";
	DienThongTinAPMau(Doc3);
	Doc3.TongTien = 15000000;
	Doc3.TrangThai = Enums.TrangThaiHoaDonAP.DuThao;
	Doc3.Write(DocumentWriteMode.Write);
	
	Doc3Obj = Doc3.Ref.GetObject();
	Doc3Obj.TrangThai = Enums.TrangThaiHoaDonAP.ChoKeToanAP;
	Doc3Obj.Write(DocumentWriteMode.Write);
	WriteLogEvent("Task2Test.Maker", EventLogLevel.Information,,, "[PASS] Test 3: ketoan_ap lap va gui ChoKeToanAP thanh cong. Ref=" + String(Doc3.Ref));
	WriteLogEvent("Task2Test.Maker", EventLogLevel.Information,,, "STATUS: TASK2_MAKER_PASS_100%");
EndProcedure

Procedure KiemTraCheckerSessionRuntime() Export
	WriteLogEvent("Task2Test.Checker", EventLogLevel.Information,,, "BAT DAU KIEM THU CHECKER SESSION: " + UserName());
	
	// Checker (ketoan_truong) tim chung tu T2-WORKFLOW-TEST do ketoan_ap lap
	Q = New Query("SELECT TOP 1 Ref FROM Document.HoaDonNhaCungCap WHERE Number = &DocNumber AND Posted = FALSE");
	Q.SetParameter("DocNumber", "T2-WORKFLOW-TEST");
	T = Q.Execute().Unload();
	If T.Count() = 0 Then
		Raise "Không tìm thấy chứng từ T2-WORKFLOW-TEST do maker tạo!";
	EndIf;
	
	DocRef = T[0].Ref;
	DocObj = DocRef.GetObject();
	DocObj.TrangThai = Enums.TrangThaiHoaDonAP.DaGhiSo;
	DocObj.Write(DocumentWriteMode.Posting);
	
	If Not DocObj.Posted Then
		Raise "Checker có quyền nhưng ghi sổ thất bại!";
	EndIf;
	
	// Kiem tra movement duoc tao hop le
	Q_GL = New Query("SELECT COUNT(*) AS Cnt FROM AccountingRegister.SoCaiKeToan WHERE Recorder = &Recorder");
	Q_GL.SetParameter("Recorder", DocRef);
	CntGL = Q_GL.Execute().Unload()[0].Cnt;
	If CntGL = 0 Then
		Raise "Ghi sổ thành công nhưng số movement GL = 0!";
	EndIf;
	
	WriteLogEvent("Task2Test.Checker", EventLogLevel.Information,,, StrTemplate("[PASS] Test 10: Checker (%1) phe duyet va ghi so thanh cong. Movements=%2", UserName(), CntGL));
	
	// Don dep test document (unpost va xoa)
	DocObj.Write(DocumentWriteMode.UndoPosting);
	DocObj.Delete();
	WriteLogEvent("Task2Test.Checker", EventLogLevel.Information,,, "[PASS] Da unpost va don dep sach se test document.");
	WriteLogEvent("Task2Test.Checker", EventLogLevel.Information,,, "STATUS: TASK2_CHECKER_PASS_100%");
EndProcedure

Procedure KiemTraAdminSessionRuntime() Export
	WriteLogEvent("Task2Test.Admin", EventLogLevel.Information,,, "BAT DAU KIEM THU ADMIN SESSION: " + UserName());
	
	// Ca 4 (Am): Admin thu gia mao bang PhienNguoiDungGiaLap = 'ketoan_truong'
	BiChan4 = False;
	Try
		Doc4 = Documents.HoaDonNhaCungCap.CreateDocument();
		Doc4.Date = CurrentDate();
		Doc4.Number = "T2-FAKEUSER-" + Format(CurrentDate(), "DF=yyyyMMddHHmmss");
		Doc4.SoHoaDon = "INV-T2-004";
		Doc4.NgayHoaDon = BegOfDay(CurrentDate());
		Doc4.NguoiLap = "ketoan_ap";
		Doc4.NguoiDuyet = "ketoan_truong";
		DienThongTinAPMau(Doc4);
		Doc4.TongTien = 10000000;
		Doc4.TrangThai = Enums.TrangThaiHoaDonAP.DaGhiSo;
		Doc4.AdditionalProperties.Insert("PhienNguoiDungGiaLap", "ketoan_truong");
		Doc4.Write(DocumentWriteMode.Posting);
	Except
		BiChan4 = True;
	EndTry;
	If Not BiChan4 Then
		Raise "LỖI BẢO MẬT: Admin giả mạo phiên người dùng duyệt thành công!";
	EndIf;
	WriteLogEvent("Task2Test.Admin", EventLogLevel.Information,,, "[PASS] Test 4: Payload gia mao phien nguoi dung bi tu choi tuyet doi.");

	// Ca 5 (Am): Thu dung co CheDoNapTest = True de bypass
	BiChan5 = False;
	Try
		Doc5 = Documents.HoaDonNhaCungCap.CreateDocument();
		Doc5.Date = CurrentDate();
		Doc5.Number = "T2-TESTFLAG-" + Format(CurrentDate(), "DF=yyyyMMddHHmmss");
		Doc5.SoHoaDon = "INV-T2-005";
		Doc5.NgayHoaDon = BegOfDay(CurrentDate());
		Doc5.NguoiLap = "ketoan_ap";
		Doc5.NguoiDuyet = "ketoan_ap";
		DienThongTinAPMau(Doc5);
		Doc5.TongTien = 10000000;
		Doc5.TrangThai = Enums.TrangThaiHoaDonAP.DaGhiSo;
		Doc5.AdditionalProperties.Insert("CheDoNapTest", True);
		Doc5.Write(DocumentWriteMode.Posting);
	Except
		BiChan5 = True;
	EndTry;
	If Not BiChan5 Then
		Raise "LỖI BẢO MẬT: Cờ CheDoNapTest cho phép bypass Maker-Checker!";
	EndIf;
	WriteLogEvent("Task2Test.Admin", EventLogLevel.Information,,, "[PASS] Test 5: Co CheDoNapTest bi vo hieu hoa va bi tu choi tuyet doi.");

	// Ca 6 (Am): DataExchange.Load bypass
	KiemTraDataExchangeLoadBypassRuntime();
	WriteLogEvent("Task2Test.Admin", EventLogLevel.Information,,, "[PASS] Test 6: DataExchange.Load bypass luu DaGhiSo unposted bi tu choi.");

	// Ca 7 (Am): Luu DaGhiSo unposted
	KiemTraLuuDaGhiSoUnpostedRuntime();
	WriteLogEvent("Task2Test.Admin", EventLogLevel.Information,,, "[PASS] Test 7: Luu DaGhiSo unposted bi tu choi.");

	// Ca 8 (Am): Nhay coc trang thai
	KiemTraNhayCocTrangThaiRuntime();
	WriteLogEvent("Task2Test.Admin", EventLogLevel.Information,,, "[PASS] Test 8: Nhay coc trang thai tu DuThao sang DaGhiSo bi tu choi.");

	// Ca 9 (Am): SoD - Ke toan AR ghi so AP
	BiChan9 = False;
	Try
		KiemTraQuyenChungTu("HoaDonNhaCungCap", "GhiSo", "ketoan_ar");
	Except
		BiChan9 = True;
	EndTry;
	If Not BiChan9 Then
		Raise "Lỗi SoD: ketoan_ar được quyền ghi sổ AP!";
	EndIf;
	WriteLogEvent("Task2Test.Admin", EventLogLevel.Information,,, "[PASS] Test 9: SoD - Ke toan AR ghi so AP bi tu choi.");

	WriteLogEvent("Task2Test.Admin", EventLogLevel.Information,,, "STATUS: TASK2_ADMIN_PASS_100%");
EndProcedure

Procedure KiemTraNhayCocTrangThaiRuntime() Export
	Doc = Documents.HoaDonNhaCungCap.CreateDocument();
	Doc.Date = CurrentDate();
	Doc.Number = "T2-JUMP-" + Format(CurrentDate(), "DF=yyyyMMddHHmmss");
	Doc.SoHoaDon = "INV-T2-JUMP";
	Doc.NgayHoaDon = BegOfDay(CurrentDate());
	Doc.NguoiLap = "ketoan_ap";
	Doc.NguoiDuyet = "ketoan_truong";
	DienThongTinAPMau(Doc);
	Doc.TongTien = 50000000;
	Doc.TrangThai = Enums.TrangThaiHoaDonAP.DuThao;
	Doc.Write(DocumentWriteMode.Write);
	
	// Thu nhay coc sang DaGhiSo ma khong qua DaDuyet
	BiChan = False;
	Try
		DocObj = Doc.Ref.GetObject();
		DocObj.TrangThai = Enums.TrangThaiHoaDonAP.DaGhiSo;
		DocObj.Write(DocumentWriteMode.Posting);
	Except
		BiChan = True;
	EndTry;
	
	Try
		Doc.Ref.GetObject().Delete();
	Except
	EndTry;
	
	If Not BiChan Then
		Raise "Vi phạm: Cho phép nhảy cóc trạng thái từ DuThao sang DaGhiSo!";
	EndIf;
EndProcedure

Procedure KiemTraDataExchangeLoadBypassRuntime() Export
	BiChan = False;
	Try
		Doc = Documents.HoaDonNhaCungCap.CreateDocument();
		Doc.Date = CurrentDate();
		Doc.Number = "T2-DX-" + Format(CurrentDate(), "DF=yyyyMMddHHmmss");
		Doc.SoHoaDon = "INV-T2-DX";
		Doc.NgayHoaDon = BegOfDay(CurrentDate());
		Doc.NguoiLap = "ketoan_ap";
		Doc.NguoiDuyet = "ketoan_truong";
		DienThongTinAPMau(Doc);
		Doc.TongTien = 50000000;
		Doc.DataExchange.Load = True;
		Doc.TrangThai = Enums.TrangThaiHoaDonAP.DaGhiSo;
		Doc.Write(DocumentWriteMode.Write);
	Except
		BiChan = True;
	EndTry;
	
	If Not BiChan Then
		Raise "Vi phạm: DataExchange.Load cho phép lưu DaGhiSo khi Posted = False!";
	EndIf;
EndProcedure

Procedure KiemTraLuuDaGhiSoUnpostedRuntime() Export
	BiChan = False;
	Try
		Doc = Documents.HoaDonNhaCungCap.CreateDocument();
		Doc.Date = CurrentDate();
		Doc.Number = "T2-UNP-" + Format(CurrentDate(), "DF=yyyyMMddHHmmss");
		Doc.SoHoaDon = "INV-T2-UNP";
		Doc.NgayHoaDon = BegOfDay(CurrentDate());
		Doc.NguoiLap = "ketoan_ap";
		Doc.NguoiDuyet = "ketoan_truong";
		DienThongTinAPMau(Doc);
		Doc.TongTien = 50000000;
		Doc.TrangThai = Enums.TrangThaiHoaDonAP.DaGhiSo;
		Doc.Write(DocumentWriteMode.Write);
	Except
		BiChan = True;
	EndTry;
	
	If Not BiChan Then
		Raise "Vi phạm: Cho phép lưu DaGhiSo khi Posted = False!";
	EndIf;
EndProcedure

Procedure KiemTraQuyTrinhTuanTuHopLeRuntime() Export
	Doc = Documents.HoaDonNhaCungCap.CreateDocument();
	Doc.Date = CurrentDate();
	Doc.Number = "T2-SEQ-" + Format(CurrentDate(), "DF=yyyyMMddHHmmss");
	Doc.NguoiLap = "ketoan_ap";
	Doc.NguoiDuyet = "ketoan_truong";
	Doc.PhapNhan = Catalogs.PhapNhan.FindByCode("PN-VSF");
	If Not ValueIsFilled(Doc.PhapNhan) Then
		Doc.PhapNhan = Catalogs.PhapNhan.FindByCode("PN_VSF");
	EndIf;
	If Not ValueIsFilled(Doc.PhapNhan) Then
		Q_PN = New Query("SELECT TOP 1 Ref FROM Catalog.PhapNhan");
		T_PN = Q_PN.Execute().Unload();
		If T_PN.Count() > 0 Then
			Doc.PhapNhan = T_PN[0].Ref;
		EndIf;
	EndIf;
	
	Doc.DoiTac = Catalogs.DoiTac.FindByCode("TEST_NCC_AWS");
	If Not ValueIsFilled(Doc.DoiTac) Then
		Doc.DoiTac = Catalogs.DoiTac.FindByCode("NCC_AWS");
	EndIf;
	If Not ValueIsFilled(Doc.DoiTac) Then
		Q_DT = New Query("SELECT TOP 1 Ref FROM Catalog.DoiTac");
		T_DT = Q_DT.Execute().Unload();
		If T_DT.Count() > 0 Then
			Doc.DoiTac = T_DT[0].Ref;
		EndIf;
	EndIf;
	
	Doc.HopDong = Catalogs.HopDong.FindByCode("HD-TEST_NCC_AWS-2025");
	If Not ValueIsFilled(Doc.HopDong) Then
		Doc.HopDong = Catalogs.HopDong.FindByCode("HD_NCC_AWS");
	EndIf;
	If Not ValueIsFilled(Doc.HopDong) Then
		Q_HD = New Query("SELECT TOP 1 Ref FROM Catalog.HopDong WHERE ChuSoHuu = &DoiTac");
		Q_HD.SetParameter("DoiTac", Doc.DoiTac);
		T_HD = Q_HD.Execute().Unload();
		If T_HD.Count() > 0 Then
			Doc.HopDong = T_HD[0].Ref;
		Else
			Q_HD2 = New Query("SELECT TOP 1 Ref FROM Catalog.HopDong");
			T_HD2 = Q_HD2.Execute().Unload();
			If T_HD2.Count() > 0 Then
				Doc.HopDong = T_HD2[0].Ref;
			EndIf;
		EndIf;
	EndIf;
	
	Doc.TienTe = Catalogs.TienTe.FindByCode("VND");
	If Not ValueIsFilled(Doc.TienTe) Then
		Q_TT = New Query("SELECT TOP 1 Ref FROM Catalog.TienTe WHERE Code = 'VND'");
		T_TT = Q_TT.Execute().Unload();
		If T_TT.Count() > 0 Then
			Doc.TienTe = T_TT[0].Ref;
		EndIf;
	EndIf;
	Doc.TyGia = 1;
	Doc.TongTien = 50000000;
	Doc.TrangThai = Enums.TrangThaiHoaDonAP.DuThao;
	
	// 1. Luu DuThao boi ketoan_ap
	Doc.AdditionalProperties.Insert("PhienNguoiDungGiaLap", "ketoan_ap");
	Doc.Write(DocumentWriteMode.Write);
	
	// 2. Chuyen sang ChoKeToanAP
	DocObj = Doc.Ref.GetObject();
	DocObj.AdditionalProperties.Insert("PhienNguoiDungGiaLap", "ketoan_ap");
	DocObj.TrangThai = Enums.TrangThaiHoaDonAP.ChoKeToanAP;
	DocObj.Write(DocumentWriteMode.Write);
	
	// 3. Phe duyet va ghi so boi ketoan_truong
	DocObj2 = Doc.Ref.GetObject();
	DocObj2.AdditionalProperties.Insert("PhienNguoiDungGiaLap", "ketoan_truong");
	DocObj2.TrangThai = Enums.TrangThaiHoaDonAP.DaGhiSo;
	DocObj2.Write(DocumentWriteMode.Posting);
	
	If Not DocObj2.Posted Then
		Raise "Lỗi: Chứng từ hợp lệ nhưng không được ghi sổ!";
	EndIf;
EndProcedure

#EndRegion

#Region PrivateHelpers

Function NguoiDungCoRole(Val TenNguoiDung, Val TenRole)
	If IsBlankString(TenNguoiDung) Then
		Return False;
	EndIf;
	
	// Neu la nguoi dung hien tai cua phien lam viec
	If TenNguoiDung = UserName() Then
		Try
			If IsInRole(TenRole) Then
				Return True;
			EndIf;
		Except
		EndTry;
	EndIf;
	
	// Tra cuu truc tiep trong InfoBaseUsers
	Try
		User = InfoBaseUsers.FindByName(TenNguoiDung);
		If User <> Undefined Then
			For Each R In User.Roles Do
				If R.Name = TenRole Then
					Return True;
				EndIf;
			EndDo;
		EndIf;
	Except
	EndTry;
	
	Return False;
EndFunction

Procedure GhiLogRaFile(Val FileName, Val Lines)
	Try
		DocDir = "C:\Users\Dung\Documents\1C_Enterprise\";
		FilePath = DocDir + FileName;
		Writer = New TextWriter(FilePath, "UTF-8");
		For Each Line In Lines Do
			Writer.WriteLine(Line);
		EndDo;
		Writer.Close();
	Except
	EndTry;
EndProcedure

#EndRegion
