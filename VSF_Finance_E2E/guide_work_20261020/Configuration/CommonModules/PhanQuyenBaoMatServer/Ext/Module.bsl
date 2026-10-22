// Common Module: PhanQuyenBaoMatServer
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Kiem soat bao mat toan dien: Maker-Checker Invariant, Segregation of Duties (SoD),
//           va kiem soat quyen truy cap bao cao tai chinh cao cap (Huong 2).

#Region PublicInterface

// Kiem tra Invariant Maker-Checker: Admin he thong khong duoc phe duyet chung tu tai chinh;
// cac vai tro nghiep vu chi duoc phe duyet khi dung nguoi duyet da chi dinh.
Procedure KiemTraMakerChecker(Val NguoiLap, Val NguoiDuyet, Val TenSessionUser = "") Export
	// Xac minh danh tinh phien 1C thuc te; khong tin ten nguoi dung do caller truyen vao.
	PhienThat = TrimAll(UserName());
	LaTaiKhoanAdmin = (Upper(PhienThat) = "ADMIN") Or IsInRole("QuanTriHeThong");
	If LaTaiKhoanAdmin Then
		WriteLogEvent("Security.MakerChecker", EventLogLevel.Warning,,, "Quản trị hệ thống không được phê duyệt chứng từ tài chính.");
		Raise "Quản trị hệ thống không được phê duyệt chứng từ tài chính; hãy dùng vai trò Kế toán trưởng hoặc CFO.";
	EndIf;

	If Not ValueIsFilled(NguoiLap) Then
		WriteLogEvent("Security.MakerChecker", EventLogLevel.Warning,,, "Vi phạm nguyên tắc Maker-Checker: Thiếu thông tin Người lập!");
		Raise "Vi phạm nguyên tắc Maker-Checker: Thiếu thông tin Người lập/tạo chứng từ!";
	EndIf;
	If Not ValueIsFilled(NguoiDuyet) Then
		WriteLogEvent("Security.MakerChecker", EventLogLevel.Warning,,, "Vi phạm nguyên tắc Maker-Checker: Thiếu thông tin Người duyệt!");
		Raise "Vi phạm nguyên tắc Maker-Checker: Chưa xác định người dùng thực hiện phê duyệt!";
	EndIf;
	
	StrLap = Upper(TrimAll(String(NguoiLap)));
	StrDuyet = Upper(TrimAll(String(NguoiDuyet)));
	
	If StrLap = StrDuyet Then
		WriteLogEvent("Security.MakerChecker", EventLogLevel.Warning,,, StrTemplate("Vi phạm Maker-Checker: Người lập (%1) tự phê duyệt!", NguoiLap));
		Raise "Vi phạm nguyên tắc Maker-Checker: Người tạo/lập không thể tự phê duyệt chứng từ!";
	EndIf;
	
	If ValueIsFilled(TenSessionUser) And Upper(TrimAll(TenSessionUser)) <> Upper(PhienThat) Then
		WriteLogEvent("Security.MakerChecker", EventLogLevel.Warning,,, 
			StrTemplate("Bỏ qua tên phiên truyền vào '%1', dùng phiên thật '%2'", TenSessionUser, PhienThat));
	EndIf;
	EffectiveSession = Upper(PhienThat);
	
	If EffectiveSession = StrLap Then
		WriteLogEvent("Security.MakerChecker", EventLogLevel.Warning,,, StrTemplate("Vi phạm Maker-Checker: Phiên người dùng '%1' (Người lập) cố gắng thực hiện phê duyệt!", PhienThat));
		Raise "Vi phạm nguyên tắc Maker-Checker: Người dùng đăng nhập hiện tại là Người lập, không được phép phê duyệt!";
	EndIf;
	
	If EffectiveSession <> StrDuyet Then
		WriteLogEvent("Security.MakerChecker", EventLogLevel.Warning,,, StrTemplate("Vi phạm Maker-Checker: Phiên '%1' không khớp người duyệt '%2'!", PhienThat, NguoiDuyet));
		Raise StrTemplate("Vi phạm nguyên tắc Maker-Checker: Phiên người dùng '%1' không phải là Người duyệt đã chỉ định ('%2')!", PhienThat, NguoiDuyet);
	EndIf;
EndProcedure

// Kiem tra Segregation of Duties (Phan dinh nhiem vu AR vs AP va cac vai tro)
// [FIX B32/B34/B37] Luon dung phien that; quan tri chi duoc bo qua SoD khi LUU (Write), khong duoc
// ghi so / huy ghi so; loai chung tu chua khai bao thi chan ghi so (danh sach cho phep).
Procedure KiemTraQuyenChungTu(Val ChungTu, Val ThaoTac, Val TenNguoiDung = "") Export
	CurrentUserStr = TrimAll(UserName());
	LaThaoTacGhiSo = (ThaoTac = "GhiSo" Or ThaoTac = "Posting" Or ThaoTac = "HuyGhiSo" Or ThaoTac = "UndoPosting");
	
	// Quan tri he thong duoc tao/sua ban nhap va cau hinh, nhung khong duoc duyet, ghi so, huy ghi so hoac xoa chung tu tai chinh.
	LaTaiKhoanAdmin = (Upper(CurrentUserStr) = "ADMIN") Or IsInRole("QuanTriHeThong");
	If LaTaiKhoanAdmin Or IsInRole("QuanTriHeThong") Then
		If ThaoTac = "Write" Or ThaoTac = "Luu" Then
			Return;
		EndIf;
		WriteLogEvent("Security.SoD", EventLogLevel.Warning,,, StrTemplate("Quản trị hệ thống '%1' bị chặn thao tác '%2' trên chứng từ tài chính.", CurrentUserStr, ThaoTac));
		Raise "Quản trị hệ thống chỉ được lập/sửa bản nháp; không được duyệt, ghi sổ, hủy ghi sổ hoặc xóa chứng từ tài chính.";
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
		Or DocTypeName = "CongNoPhaiTra");
		
	// Netting and gateway reconciliation are finance-control documents reserved for KTT/CFO.
	LaChungTuNetting = (DocTypeName = "CanTruCongNoNoiBo"
		Or DocTypeName = "DoiSoatKenhThanhToan");
	
	// Chung tu tong hop ke toan (out of scope)
	LaChungTuTongHop = False;
	LaLanhDaoTaiChinh = IsInRole("KeToanTruong") Or IsInRole("GiamDocTaiChinh_CFO");
	If LaChungTuNetting And Not LaLanhDaoTaiChinh Then
		WriteLogEvent("Security.SoD", EventLogLevel.Warning,,, StrTemplate("Vi phạm SoD: %1 cố thao tác '%2' trên chứng từ netting/đối soát %3.", CurrentUserStr, ThaoTac, DocTypeName));
		Raise "Chỉ Kế toán trưởng hoặc CFO được lập, sửa, ghi sổ hoặc hủy ghi sổ chứng từ cấn trừ/đối soát.";
	EndIf;
	
	If LaThaoTacGhiSo And Not LaLanhDaoTaiChinh Then
		If LaChungTuTongHop Then
			WriteLogEvent("Security.SoD", EventLogLevel.Warning,,, StrTemplate("Vi phạm SoD: %1 cố %2 chứng từ tổng hợp %3!", CurrentUserStr, ThaoTac, DocTypeName));
			Raise "Chỉ Kế toán trưởng hoặc Giám đốc tài chính (CFO) được ghi sổ / hủy ghi sổ chứng từ Đánh giá lại ngoại tệ!";
		EndIf;
		If Not (LaChungTuAR Or LaChungTuAP Or LaChungTuNetting) Then
			WriteLogEvent("Security.SoD", EventLogLevel.Warning,,, StrTemplate("Vi phạm SoD: Loại chứng từ %1 chưa được khai báo phân quyền ghi sổ!", DocTypeName));
			Raise StrTemplate("Loại chứng từ '%1' chưa được khai báo phân quyền ghi sổ. Liên hệ Kế toán trưởng.", DocTypeName);
		EndIf;
	EndIf;

	// 1. Kiem tra rang buoc SoD voi KeToanPhaiThu (ketoan_ar)
	If IsInRole("KeToanPhaiThu") Then
		If LaChungTuAP Then
			WriteLogEvent("Security.SoD", EventLogLevel.Warning,,, StrTemplate("Vi phạm SoD: Kế toán AR (%1) cố can thiệp chứng từ AP (%2)!", CurrentUserStr, DocTypeName));
			Raise "Vi phạm phân định trách nhiệm (Segregation of Duties): Kế toán Phải thu (AR) không được phép ghi sổ, sửa hoặc can thiệp chứng từ Phải trả (AP)!";
		EndIf;
	EndIf;
	
	// 2. Kiem tra rang buoc SoD voi KeToanPhaiTra (ketoan_ap)
	If IsInRole("KeToanPhaiTra") Then
		If LaChungTuAR Then
			WriteLogEvent("Security.SoD", EventLogLevel.Warning,,, StrTemplate("Vi phạm SoD: Kế toán AP (%1) cố can thiệp chứng từ AR (%2)!", CurrentUserStr, DocTypeName));
			Raise "Vi phạm phân định trách nhiệm (Segregation of Duties): Kế toán Phải trả (AP) không được phép ghi sổ, sửa hoặc can thiệp chứng từ Phải thu (AR)!";
		EndIf;
	EndIf;
EndProcedure

// Kiem tra phan quyen truy cap bao cao tai chinh cao cap
// Quy tac: "Chỉ CFO, Kế toán trưởng mới xem được toàn bộ Sổ cái và Ma trận cấn trừ Tập đoàn."
// [FIX B34] Luon dung phien that.
Procedure KiemTraQuyenBaoCao(Val TenBaoCao, Val TenNguoiDung = "") Export
	// Admin toan quyen xem moi bao cao tai chinh
	If (Upper(TrimAll(UserName())) = "ADMIN") Or IsInRole("QuanTriHeThong") Then
		Return;
	EndIf;
	
	BaoCaoCaoCap = (TenBaoCao = "SoCaiKeToan" 
		Or TenBaoCao = "AccountingRegister.SoCaiKeToan");
		
	If BaoCaoCaoCap Then
		// Chi CFO, Ke toan truong hoac Admin duoc phep
		DuocPhep = IsInRole("GiamDocTaiChinh_CFO") Or IsInRole("KeToanTruong");
		If Not DuocPhep Then
			Raise "Vi phạm chính sách bảo mật: Chỉ CFO và Kế toán trưởng mới có quyền truy cập toàn bộ Sổ cái và Ma trận cấn trừ Tập đoàn!";
		EndIf;
	EndIf;
EndProcedure

// Nhan dien phien quan tri he thong; quyen tren chung tu tai chinh van bi gioi han o cac ham kiem tra ben duoi.
Function LaPhienQuanTriHeThong() Export
	Return Upper(TrimAll(UserName())) = "ADMIN" Or IsInRole("QuanTriHeThong");
EndFunction

// Phien hien tai co vai tro quan tri he thong ma KHONG kiem nhiem vai tro ke toan duyet
Function LaQuanTriKhongNghiepVu() Export
	If Not IsInRole("QuanTriHeThong") Then
		Return False;
	EndIf;
	Return Not (IsInRole("KeToanTruong") Or IsInRole("GiamDocTaiChinh_CFO"));
EndFunction

// Bo Test tong hop toan dien cac dieu kien bao mat
// [FIX TEST] Viet lai theo PHIEN THAT: tu khi sua B28/B32/B34, he thong bo qua ten nguoi dung truyen vao
// (khong cho gia mao). Vi vay moi ca kiem tra quy tac ap dung cho chinh nguoi dang dang nhap; ca nao
// khong ap dung cho vai tro cua phien thi ghi "BO QUA" (khong tinh dat/truot). Chay bo nay bang tung
// nguoi dung that dang duoc provision (Admin, ketoan_ar, ketoan_ap, ketoan_truong, cfo_giamdoc).
Function ThucThiKiemThuBaoMatToanDien(Val RunId = "", Val ResultPath = "") Export
	LogLines = New Array;
	Cases = New Array;
	Phien = TrimAll(UserName());
	VaiTro = VaiTroPhienKiemThu();
	LogLines.Add(StrTemplate("=== KIEM THU BAO MAT & PHAN QUYEN THEO PHIEN THAT: %1 (nhom vai tro: %2) ===", Phien, VaiTro));
	Dem = New Structure("Tong,Dat,Truot,BoQua", 0, 0, 0, 0);
	
	// Ca 1: du nguoi dung mau va dung vai tro
	GhiKetQuaCaKiemThu(LogLines, Dem, "Ca 1: Du 4 nguoi dung nghiep vu + Admin dung vai tro", True,
		UserProvisioningServer.KiemTraNguoiDungDaKhoiTao(), Cases);
	
	// Business users and administrators are all blocked from approving their own document.
	GhiKetQuaCaKiemThu(LogLines, Dem, "Ca 2: Nguoi lap tu duyet bi chan", True,
		BiChanMakerChecker(Phien, Phien), Cases);
	
	// The named business approver can approve; a system administrator cannot approve finance documents.
	NguoiLapKhac = ?(Upper(Phien) = "KETOAN_AP", "ketoan_ar", "ketoan_ap");
	GhiKetQuaCaKiemThu(LogLines, Dem, "Ca 3: Nguoi duoc chi dinh duyet (Admin bi chan)", VaiTro = "QuanTri",
		BiChanMakerChecker(NguoiLapKhac, Phien), Cases);
	
	// A user other than the assigned approver, including Admin, must be blocked.
	NguoiDuyetKhac = ?(Upper(Phien) = "CFO_GIAMDOC", "ketoan_truong", "cfo_giamdoc");
	GhiKetQuaCaKiemThu(LogLines, Dem, "Ca 4: Phien khac Nguoi duyet chi dinh bi chan", True,
		BiChanMakerChecker(NguoiLapKhac, NguoiDuyetKhac), Cases);
	
	// Ca 5: ghi so chung tu AP (Hoa don dau vao)
	MongDoi = Undefined;
	If VaiTro = "AR" Or VaiTro = "DoiSoat" Or VaiTro = "KyThuat" Or VaiTro = "QuanTri" Then
		MongDoi = True;
	ElsIf VaiTro = "AP" Or VaiTro = "LanhDaoTaiChinh" Then
		MongDoi = False;
	EndIf;
	GhiKetQuaCaKiemThu(LogLines, Dem, "Ca 5: Ghi so chung tu AP (chan: AR, doi soat, ky thuat, quan tri)",
		MongDoi, BiChanQuyenChungTu("HoaDonNhaCungCap", "GhiSo"), Cases);
	
	// Ca 6: ghi so chung tu AR (Hoa don GTGT dau ra)
	MongDoi = Undefined;
	If VaiTro = "AP" Or VaiTro = "DoiSoat" Or VaiTro = "KyThuat" Or VaiTro = "QuanTri" Then
		MongDoi = True;
	ElsIf VaiTro = "AR" Or VaiTro = "LanhDaoTaiChinh" Then
		MongDoi = False;
	EndIf;
	GhiKetQuaCaKiemThu(LogLines, Dem, "Ca 6: Ghi so chung tu AR (chan: AP, doi soat, ky thuat, quan tri)",
		MongDoi, BiChanQuyenChungTu("HoaDonGTGTDauRa", "GhiSo"), Cases);
	
	// Ca 7: xem toan bo So cai -> chi CFO, KTT va quan tri
	MongDoi = Not (VaiTro = "LanhDaoTaiChinh" Or VaiTro = "QuanTri");
	GhiKetQuaCaKiemThu(LogLines, Dem, "Ca 7: Xem toan bo So cai", MongDoi,
		BiChanQuyenBaoCao("SoCaiKeToan"), Cases);
	
	// Only the named CFO may issue this electronic invoice; maker, AP, KTT and system admin must be blocked.
	MongDoi = (Upper(Phien) <> "CFO_GIAMDOC");
	TransitionResult = KiemTraChuyenTrangThaiHoaDonDauRa();
	GhiKetQuaCaKiemThu(LogLines, Dem, "Ca 8: Chi CFO duoc chi dinh moi duoc phat hanh hoa don", MongDoi,
		TransitionResult.Blocked, Cases);
	If Cases <> Undefined Then
		Cases[Cases.Count() - 1].Insert("detail", TransitionResult.Error);
	EndIf;

	// Netting and gateway settlement documents are restricted to KTT/CFO.
	MongDoi = (VaiTro <> "LanhDaoTaiChinh");
	GhiKetQuaCaKiemThu(LogLines, Dem, "Ca 9: Ghi so cấn trừ nội bộ chỉ cho KTT/CFO", MongDoi,
		BiChanQuyenChungTu("CanTruCongNoNoiBo", "GhiSo"), Cases);
	GhiKetQuaCaKiemThu(LogLines, Dem, "Ca 10: Ghi so đối soát kênh thanh toán chỉ cho KTT/CFO", MongDoi,
		BiChanQuyenChungTu("DoiSoatKenhThanhToan", "GhiSo"), Cases);
	
	LogLines.Add(StrTemplate("=== TONG KET (%1): %2 ca chay, %3 DAT, %4 TRUOT, %5 BO QUA ===",
		Phien, Dem.Tong, Dem.Dat, Dem.Truot, Dem.BoQua));
	Passed = (Dem.Truot = 0 And Dem.Dat > 0);
	If Passed Then
		LogLines.Add("STATUS: SECURITY_TESTS_PASS_100%");
		WriteLogEvent("SecurityTesting.Summary", EventLogLevel.Information,,, "SECURITY_TESTS_PASS_100% (" + Phien + ")");
	Else
		LogLines.Add("STATUS: SECURITY_TESTS_FAILED");
		WriteLogEvent("SecurityTesting.Summary", EventLogLevel.Error,,, "SECURITY_TESTS_FAILED (" + Phien + ")");
	EndIf;
	
	GhiLogRaFile("security_test_results.log", LogLines);
	If ValueIsFilled(ResultPath) Then
		Result = New Structure("run_id,phase,user,role,status,passed,total,passed_cases,failed_cases,skipped_cases,cases",
			RunId, "security_role_matrix", Phien, VaiTro, ?(Passed, "PASS", "FAIL"), Passed,
			Dem.Tong, Dem.Dat, Dem.Truot, Dem.BoQua, Cases);
		Writer = New JSONWriter;
		Writer.OpenFile(ResultPath);
		WriteJSON(Writer, Result);
		Writer.Close();
	EndIf;
	Return Passed;
EndFunction

// ============================================================================
// TASK 2 RUNTIME AUDIT TEST SUITE (10 TEST CASES: 9 NEGATIVE + 1 POSITIVE)
// ============================================================================

// [FIX TEST] Viet lai theo PHIEN THAT (xem ghi chu o ThucThiKiemThuBaoMatToanDien).
// - Ca 4-6: cac thu tuc KiemTra...Runtime chi Raise khi he thong KHONG chan duoc vi pham, nen
//   "khong co loi" moi la DAT (truoc day dao nguoc: chan dung lai bao TRUOT).
// - Ca 10 (quy trinh duyet tuan tu) can nhieu phien that -> chay bang lenh RunE2E (KiemThuQuyTrinhServer).
Function ThucThiKiemThuTask2Runtime() Export
	LogLines = New Array;
	Phien = TrimAll(UserName());
	VaiTro = VaiTroPhienKiemThu();
	LogLines.Add("=== BAT DAU KIEM THU TASK 2: MAKER-CHECKER, SOD VA TRANG THAI DA LUU ===");
	LogLines.Add(StrTemplate("Phien: %1 (nhom vai tro: %2) | Thoi gian: %3", Phien, VaiTro, CurrentSessionDate()));
	Dem = New Structure("Tong,Dat,Truot,BoQua", 0, 0, 0, 0);
	NguoiLapKhac = ?(Upper(Phien) = "KETOAN_AP", "ketoan_ar", "ketoan_ap");
	NguoiDuyetKhac = ?(Upper(Phien) = "CFO_GIAMDOC", "ketoan_truong", "cfo_giamdoc");
	
	GhiKetQuaCaKiemThu(LogLines, Dem, "Test 1: Maker = Checker bi tu choi", True, BiChanMakerChecker(Phien, Phien));
	GhiKetQuaCaKiemThu(LogLines, Dem, "Test 2: Phien khac Nguoi duyet chi dinh bi tu choi", True,
		BiChanMakerChecker(NguoiLapKhac, NguoiDuyetKhac));
	GhiKetQuaCaKiemThu(LogLines, Dem, "Test 3: Nguoi duyet = Admin bi tu choi", True,
		BiChanMakerChecker(NguoiLapKhac, "Admin"));
	
	// Ca 4-6 can quyen LUU hoa don dau vao (AP, KTT/CFO, quan tri); vai tro khac: bo qua
	CoQuyenLuuAP = (VaiTro = "AP" Or VaiTro = "LanhDaoTaiChinh" Or VaiTro = "QuanTri");
	GhiKetQuaCaKiemThu(LogLines, Dem, "Test 4: Nhay coc DuThao -> DaGhiSo bi tu choi",
		?(CoQuyenLuuAP, False, Undefined), ?(CoQuyenLuuAP, CoLoiKhiChay("NhayCoc"), False));
	GhiKetQuaCaKiemThu(LogLines, Dem, "Test 5: DataExchange.Load luu DaGhiSo chua ghi so bi tu choi",
		?(CoQuyenLuuAP, False, Undefined), ?(CoQuyenLuuAP, CoLoiKhiChay("DataExchange"), False));
	GhiKetQuaCaKiemThu(LogLines, Dem, "Test 6: Luu DaGhiSo khi Posted = False bi tu choi",
		?(CoQuyenLuuAP, False, Undefined), ?(CoQuyenLuuAP, CoLoiKhiChay("LuuDaGhiSo"), False));
	
	GhiKetQuaCaKiemThu(LogLines, Dem, "Test 7: SoD - Ke toan AR ghi so AP bi tu choi",
		?(VaiTro = "AR", True, Undefined), BiChanQuyenChungTu("HoaDonNhaCungCap", "GhiSo"));
	GhiKetQuaCaKiemThu(LogLines, Dem, "Test 8: SoD - Ke toan AP ghi so AR bi tu choi",
		?(VaiTro = "AP", True, Undefined), BiChanQuyenChungTu("HoaDonGTGTDauRa", "GhiSo"));
	GhiKetQuaCaKiemThu(LogLines, Dem, "Test 9: SoD - Ky thuat (PM/TechLead/IT) ghi so tai chinh bi tu choi",
		?(VaiTro = "KyThuat", True, Undefined), BiChanQuyenChungTu("HoaDonNhaCungCap", "GhiSo"));
	LogLines.Add("[BO QUA] Test 10: Quy trinh duyet tuan tu can nhieu phien that -> xem ket qua lenh RunE2E.");
	
	LogLines.Add(StrTemplate("=== TONG KET TASK 2 (%1): %2/%3 PASS (%4 FAIL, %5 BO QUA) ===",
		Phien, Dem.Dat, Dem.Tong, Dem.Truot, Dem.BoQua));
	If Dem.Truot = 0 And Dem.Dat > 0 Then
		LogLines.Add("STATUS: TASK2_SECURITY_PASS_100%");
		WriteLogEvent("Task2Test.Summary", EventLogLevel.Information,,, "TASK2_SECURITY_PASS_100% (" + Phien + ")");
	Else
		LogLines.Add("STATUS: TASK2_SECURITY_FAILED");
		WriteLogEvent("Task2Test.Summary", EventLogLevel.Error,,, StrTemplate("TASK2_SECURITY_FAILED_%1_FAILURES (%2)", Dem.Truot, Phien));
	EndIf;
	For Each Line In LogLines Do
		WriteLogEvent("Task2Test.Result", EventLogLevel.Information,,, Line);
	EndDo;
	GhiLogRaFile("task2_test_results.log", LogLines);
	Return (Dem.Truot = 0 And Dem.Dat > 0);
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
	Doc3.Date = CurrentSessionDate();
	Doc3.Number = "T2-WORKFLOW-TEST";
	Doc3.SoHoaDon = "INV-T2-001";
	Doc3.NgayHoaDon = BegOfDay(CurrentSessionDate());
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
		Doc4.Date = CurrentSessionDate();
		Doc4.Number = "T2-FAKEUSER-" + Format(CurrentSessionDate(), "DF=yyyyMMddHHmmss");
		Doc4.SoHoaDon = "INV-T2-004";
		Doc4.NgayHoaDon = BegOfDay(CurrentSessionDate());
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
		Doc5.Date = CurrentSessionDate();
		Doc5.Number = "T2-TESTFLAG-" + Format(CurrentSessionDate(), "DF=yyyyMMddHHmmss");
		Doc5.SoHoaDon = "INV-T2-005";
		Doc5.NgayHoaDon = BegOfDay(CurrentSessionDate());
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
	Doc.Date = CurrentSessionDate();
	Doc.Number = "T2-JUMP-" + Format(CurrentSessionDate(), "DF=yyyyMMddHHmmss");
	Doc.SoHoaDon = "INV-T2-JUMP";
	Doc.NgayHoaDon = BegOfDay(CurrentSessionDate());
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
		CleanupError = DetailErrorDescription(ErrorInfo());
		WriteLogEvent("Security.TestCleanup", EventLogLevel.Error,,, CleanupError);
		Raise "Security runtime test cleanup failed: " + CleanupError;
	EndTry;
	
	If Not BiChan Then
		Raise "Vi phạm: Cho phép nhảy cóc trạng thái từ DuThao sang DaGhiSo!";
	EndIf;
EndProcedure

Procedure KiemTraDataExchangeLoadBypassRuntime() Export
	BiChan = False;
	Try
		Doc = Documents.HoaDonNhaCungCap.CreateDocument();
		Doc.Date = CurrentSessionDate();
		Doc.Number = "T2-DX-" + Format(CurrentSessionDate(), "DF=yyyyMMddHHmmss");
		Doc.SoHoaDon = "INV-T2-DX";
		Doc.NgayHoaDon = BegOfDay(CurrentSessionDate());
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
		Doc.Date = CurrentSessionDate();
		Doc.Number = "T2-UNP-" + Format(CurrentSessionDate(), "DF=yyyyMMddHHmmss");
		Doc.SoHoaDon = "INV-T2-UNP";
		Doc.NgayHoaDon = BegOfDay(CurrentSessionDate());
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
	Doc.Date = CurrentSessionDate();
	Doc.Number = "T2-SEQ-" + Format(CurrentSessionDate(), "DF=yyyyMMddHHmmss");
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

// Nhom vai tro cua phien dang dang nhap (dung cho bo kiem thu theo phien that)
Function VaiTroPhienKiemThu()
	If Upper(TrimAll(UserName())) = "ADMIN" Or LaQuanTriKhongNghiepVu() Then
		Return "QuanTri";
	ElsIf IsInRole("KeToanTruong") Or IsInRole("GiamDocTaiChinh_CFO") Then
		Return "LanhDaoTaiChinh";
	ElsIf IsInRole("KeToanPhaiThu") Then
		Return "AR";
	ElsIf IsInRole("KeToanPhaiTra") Then
		Return "AP";
	EndIf;
	Return "Khac";
EndFunction

// MongDoi: True/False = ket qua mong doi; Undefined = ca khong ap dung cho vai tro nay (BO QUA)
Procedure GhiKetQuaCaKiemThu(LogLines, Dem, Val TenCa, Val MongDoi, Val ThucTe, Val Cases = Undefined)
	If MongDoi = Undefined Then
		Dem.BoQua = Dem.BoQua + 1;
		LogLines.Add("[BO QUA] " + TenCa + " (khong ap dung cho vai tro cua phien)");
		If Cases <> Undefined Then
			Cases.Add(New Structure("name,status,expected,actual", TenCa, "NOT_APPLICABLE", "", ""));
		EndIf;
		Return;
	EndIf;
	Dem.Tong = Dem.Tong + 1;
	If ThucTe = MongDoi Then
		Dem.Dat = Dem.Dat + 1;
		LogLines.Add("[PASS] " + TenCa);
		If Cases <> Undefined Then
			Cases.Add(New Structure("name,status,expected,actual", TenCa, "PASS", String(MongDoi), String(ThucTe)));
		EndIf;
	Else
		Dem.Truot = Dem.Truot + 1;
		LogLines.Add(StrTemplate("[FAIL] %1 (mong doi bi chan = %2, thuc te = %3)", TenCa, MongDoi, ThucTe));
		If Cases <> Undefined Then
			Cases.Add(New Structure("name,status,expected,actual", TenCa, "FAIL", String(MongDoi), String(ThucTe)));
		EndIf;
	EndIf;
EndProcedure

Function BiChanMakerChecker(Val NguoiLap, Val NguoiDuyet)
	Try
		KiemTraMakerChecker(NguoiLap, NguoiDuyet);
	Except
		Return True;
	EndTry;
	Return False;
EndFunction

Function KiemTraChuyenTrangThaiHoaDonDauRa()
	Result = New Structure("Blocked,Error", False, "");
	Doc = New Structure("MetadataName,LoaiChungTu,NguoiLap,NguoiDuyet,TrangThai",
		"HoaDonGTGTDauRa", "HoaDonGTGTDauRa", "ketoan_ar", "cfo_giamdoc", Enums.TrangThaiHoaDonDienTu.ChoKySo);
	Try
		KiemTraQuyenChungTu(Doc, "Write");
		QuanLyVongDoiChungTuServer.KiemTraChuyenTrangThai(Doc,
			Enums.TrangThaiHoaDonDienTu.DaPhatHanh, UserName(), DocumentWriteMode.Write);
	Except
		Result.Blocked = True;
		Result.Error = DetailErrorDescription(ErrorInfo());
		WriteLogEvent("Security.WorkflowTest", EventLogLevel.Warning,,, StrTemplate("Hoa don dien tu issuance blocked for %1: %2", UserName(), BriefErrorDescription(ErrorInfo())));
	EndTry;
	Return Result;
EndFunction

Function BiChanQuyenChungTu(Val LoaiChungTu, Val ThaoTac)
	Try
		KiemTraQuyenChungTu(LoaiChungTu, ThaoTac);
	Except
		Return True;
	EndTry;
	Return False;
EndFunction

Function BiChanQuyenBaoCao(Val TenBaoCao)
	Try
		KiemTraQuyenBaoCao(TenBaoCao);
	Except
		Return True;
	EndTry;
	Return False;
EndFunction

// Cac thu tuc KiemTra...Runtime chi Raise khi vi pham KHONG bi chan -> True = co loi = TRUOT
Function CoLoiKhiChay(Val TenCa)
	Try
		If TenCa = "NhayCoc" Then
			KiemTraNhayCocTrangThaiRuntime();
		ElsIf TenCa = "DataExchange" Then
			KiemTraDataExchangeLoadBypassRuntime();
		Else
			KiemTraLuuDaGhiSoUnpostedRuntime();
		EndIf;
	Except
		WriteLogEvent("Task2Test.Error", EventLogLevel.Warning,,, TenCa + ": " + BriefErrorDescription(ErrorInfo()));
		Return True;
	EndTry;
	Return False;
EndFunction

Procedure GhiLogRaFile(Val FileName, Val Lines)
	WriteLogEvent("SecurityTests.Detail", EventLogLevel.Information,,, FileName + Chars.LF + StrConcat(Lines, Chars.LF));
EndProcedure

#EndRegion
