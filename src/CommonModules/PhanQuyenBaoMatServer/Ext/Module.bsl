// Common Module: PhanQuyenBaoMatServer
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Kiem soat bao mat toan dien: Maker-Checker Invariant, Segregation of Duties (SoD),
//           va kiem soat quyen truy cap bao cao tai chinh cao cap (Huong 2).

#Region PublicInterface

// Kiem tra Invariant Maker-Checker: Nguoi lap khong duoc phep tu duyet
Procedure KiemTraMakerChecker(Val NguoiLap, Val NguoiDuyet) Export
	If Not ValueIsFilled(NguoiLap) Then
		Raise "Vi phạm nguyên tắc Maker-Checker: Thiếu thông tin Người lập/tạo chứng từ!";
	EndIf;
	If Not ValueIsFilled(NguoiDuyet) Then
		Raise "Vi phạm nguyên tắc Maker-Checker: Chưa xác định người dùng thực hiện phê duyệt!";
	EndIf;
	
	StrLap = TrimAll(String(NguoiLap));
	StrDuyet = TrimAll(String(NguoiDuyet));
	
	If StrLap = StrDuyet Then
		Raise "Vi phạm nguyên tắc Maker-Checker: Người tạo/lập không thể tự phê duyệt chứng từ!";
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
			Raise "Vi phạm phân định trách nhiệm (Segregation of Duties): Kế toán Phải thu (AR) không được phép ghi sổ, sửa hoặc can thiệp chứng từ Phải trả (AP)!";
		EndIf;
	EndIf;
	
	// 2. Kiem tra rang buoc SoD voi KeToanPhaiTra (ketoan_ap)
	If CurrentUserStr = "ketoan_ap" Or NguoiDungCoRole(CurrentUserStr, "KeToanPhaiTra") Then
		If LaChungTuAR Then
			Raise "Vi phạm phân định trách nhiệm (Segregation of Duties): Kế toán Phải trả (AP) không được phép ghi sổ, sửa hoặc can thiệp chứng từ Phải thu (AR)!";
		EndIf;
	EndIf;
	
	// 3. Chuyen vien doi soat khong duoc truc tiep xuat chung tu AR/AP ma phai thong qua chung tu netting
	If CurrentUserStr = "chuyenvien_doisoat" Or NguoiDungCoRole(CurrentUserStr, "ChuyenVienDoiSoatTapDoan") Then
		If ThaoTac = "GhiSo" And (LaChungTuAR Or LaChungTuAP) And Not LaChungTuNetting Then
			Raise "Chuyên viên Đối soát chỉ có quyền thao tác trên Chứng từ Cấn trừ và Bảng kê đối soát!";
		EndIf;
	EndIf;
	
	// 4. Cac vai tro ky thuat (PM, TechLead, IT Director) khong duoc phep ghi so tai chinh
	If CurrentUserStr = "pm_duan" Or CurrentUserStr = "techlead_kythuat" Or CurrentUserStr = "it_director"
		Or NguoiDungCoRole(CurrentUserStr, "ProjectManager_QuanLyDuAn") 
		Or NguoiDungCoRole(CurrentUserStr, "TechLead_KiemTraKyThuat") 
		Or NguoiDungCoRole(CurrentUserStr, "ITDirector_GiamDocHaTang") Then
		
		If ThaoTac = "GhiSo" Or ThaoTac = "Posting" Then
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
		KiemTraMakerChecker("ketoan_ap", "ketoan_truong");
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
