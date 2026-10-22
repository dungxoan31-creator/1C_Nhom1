// Common Module: QuyTrinhPheDuyetAPServer
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Xu ly luong phe duyet 3 cap AP (DuThao -> ChoKeToanTruongDuyet -> DaGhiSo / ChoDuyetCFO -> DaGhiSo) va Maker-Checker.

#Region PublicInterface

// Xac dinh trang thai tiep theo trong luong phe duyet AP 3 cap theo nguong CFO 500tr
//
// Tham so:
//   TrangThaiHienTai - String, EnumRef.TrangThaiHoaDonAP - Trang thai hien tai cua chung tu
//   TongTien         - Number                          - Tong gia tri hoa don (VND)
//
// Gia tri tra ve:
//   String - Ten trang thai tiep theo
Function XacDinhTrangThaiTiepTheo(Val TrangThaiHienTai, Val TongTien = 0) Export
	TrangThaiStr = TrimAll(String(TrangThaiHienTai));
	NguongCFO = Constants.NguongPheDuyetChiTienCFO.Get();
	If NguongCFO <= 0 Then
		NguongCFO = 500000000;
	EndIf;
	
	If TrangThaiStr = "DuThao" Or TrangThaiStr = "Dự thảo" Then
		Return "ChoKeToanTruongDuyet";
		
	ElsIf TrangThaiStr = "ChoKeToanTruongDuyet" Or TrangThaiStr = "Chờ Kế toán trưởng duyệt" Then
		If TongTien > NguongCFO Then
			// Vượt ngưỡng 500tr: KTT soát xét hợp lệ và chuyển tiếp lên CFO duyệt
			Return "ChoDuyetCFO";
		Else
			// <= 500tr: KTT phê duyệt và ghi sổ trực tiếp
			Return "DaGhiSo";
		EndIf;
		
	ElsIf TrangThaiStr = "ChoDuyetCFO" Or TrangThaiStr = "Chờ CFO duyệt" Then
		Return "DaGhiSo";
		
	Else
		Return TrangThaiStr;
	EndIf;
EndFunction

// Kiem tra rang buoc Maker-Checker va phan quyen phe duyet
//
// Tham so:
//   NguoiTao           - String, CatalogRef.NguoiDung - Nguoi lap chung tu
//   NguoiDuyet         - String, CatalogRef.NguoiDung - Nguoi thuc hien thao tac duyet
//   TrangThaiDangDuyet - String                       - Cap trang thai dang thuc hien duyet
Procedure KiemTraQuyenDuyet(Val NguoiTao, Val NguoiDuyet, Val TrangThaiDangDuyet) Export
	If PhanQuyenBaoMatServer.LaPhienQuanTriHeThong() Then
		WriteLogEvent("Security.APApproval", EventLogLevel.Warning,,, "Quản trị hệ thống không được phê duyệt chứng từ tài chính AP.");
		Raise "Quản trị hệ thống không được phê duyệt chứng từ tài chính AP; hãy dùng vai trò Kế toán trưởng hoặc CFO.";
	EndIf;
	
	// 1. CÂM TUYỆT ĐỐI Maker-Checker
	If String(NguoiTao) = String(NguoiDuyet) Then
		Raise "Vi phạm nguyên tắc Maker-Checker: Người tạo không thể tự phê duyệt chứng từ!";
	EndIf;
	
	// 2. Kiem tra nguoi duyet hop le
	If Not ValueIsFilled(NguoiDuyet) Then
		Raise "Chưa xác định người dùng thực hiện phê duyệt!";
	EndIf;
EndProcedure

// Xu ly tu choi phe duyet chung tu AP
//
// Tham so:
//   TrangThaiHienTai - String - Trang thai hien tai truoc khi bi tu choi
//   LyDoTuChoi       - String - Ly do tu choi
//
// Gia tri tra ve:
//   Structure: TrangThaiMoi, TrangThaiTruocDo, LyDo, ThoiDiem
Function TuChoiPheDuyet(Val TrangThaiHienTai, Val LyDoTuChoi) Export
	If Not ValueIsFilled(LyDoTuChoi) Then
		Raise "Bắt buộc phải nhập lý do từ chối phê duyệt!";
	EndIf;
	
	KetQua = New Structure;
	KetQua.Insert("TrangThaiMoi", Enums.TrangThaiHoaDonAP.TuChoi);
	KetQua.Insert("TrangThaiTruocDo", TrangThaiHienTai);
	KetQua.Insert("LyDo", TrimAll(LyDoTuChoi));
	KetQua.Insert("ThoiDiem", CurrentSessionDate());
	
	Return KetQua;
EndFunction

// Kiem tra dau hieu chia nho hoa don (Anti-Split) truoc khi vao buoc Ke toan AP
//
// Tham so:
//   SoHoaDonTrongThang - Number - So luong hoa don phat sinh trong thang cua NCC
//   TongTienLuyKe      - Number - Tong gia tri cac hoa don trong thang
//   NguongCanhBao      - Number - Nguong kiem soat chi tieu
//
// Gia tri tra ve:
//   Boolean - True neu co dau hieu chia nho hoa don
Function KiemTraAntiSplit(Val SoHoaDonTrongThang, Val TongTienLuyKe, Val NguongCanhBao = 100000000) Export
	If SoHoaDonTrongThang >= 3 And TongTienLuyKe >= NguongCanhBao Then
		Return True;
	EndIf;
	Return False;
EndFunction

// Kiem tra vai tro cua nguoi thuc hien tung buoc duyet hoa don AP (3 cap).
// Duoc goi tu HoaDonNhaCungCap.BeforeWrite moi khi trang thai thay doi.
//   TrangThaiCu, TrangThaiMoi - ten gia tri Enum.TrangThaiHoaDonAP
//   TongTien                  - tong gia tri hoa don can duyet
//   NguoiLap                  - nguoi lap hoa don (khong duoc tu day buoc duyet)
Procedure KiemTraBuocDuyetAP(Val TrangThaiCu, Val TrangThaiMoi, Val TongTien, Val NguoiLap) Export
	If TrangThaiCu = TrangThaiMoi Then
		Return;
	EndIf;
	
	If PhanQuyenBaoMatServer.LaPhienQuanTriHeThong() Then
		WriteLogEvent("Security.APApproval", EventLogLevel.Warning,,, "Quản trị hệ thống không được chuyển trạng thái phê duyệt chứng từ AP.");
		Raise "Quản trị hệ thống không được phê duyệt chứng từ tài chính AP.";
	EndIf;
	
	NguoiDungHienTai = UserName();
	
	// 1. Maker-Checker: Nguoi lap chi duoc gui duyet hoac dua ve nhap
	LaBuocCuaNguoiLap = (TrangThaiMoi = "DuThao" Or TrangThaiMoi = "ChoKeToanTruongDuyet");
	If Not LaBuocCuaNguoiLap And ValueIsFilled(NguoiLap) And Upper(TrimAll(NguoiLap)) = Upper(TrimAll(NguoiDungHienTai)) Then
		Raise "Vi phạm nguyên tắc Maker-Checker: Người lập hóa đơn không được tự duyệt các bước tiếp theo!";
	EndIf;
	
	NguongCFO = Constants.NguongPheDuyetChiTienCFO.Get();
	If NguongCFO <= 0 Then
		NguongCFO = 500000000;
	EndIf;
	
	// 2. Chặn KTT duyệt thẳng nếu vượt ngưỡng 500tr
	If TrangThaiCu = "ChoKeToanTruongDuyet" And TrangThaiMoi = "DaGhiSo" And TongTien > NguongCFO Then
		Raise StrTemplate("Hóa đơn có giá trị %1 VND vượt ngưỡng 500.000.000 VND, bắt buộc phải qua bước duyệt của Giám đốc tài chính (CFO)!", Format(TongTien, "NFD=0; NG=3,0"));
	EndIf;
	
	// 3. Phân quyền vai trò thực hiện từng bước
	VaiTroCan = "";
	If TrangThaiCu = "ChoKeToanTruongDuyet" Then
		VaiTroCan = "KeToanTruong";
	ElsIf TrangThaiCu = "ChoDuyetCFO" Then
		VaiTroCan = "GiamDocTaiChinh_CFO";
	ElsIf TrangThaiCu = "DuThao" Then
		VaiTroCan = "KeToanPhaiTra,KeToanTruong";
	EndIf;
	
	If Not ValueIsFilled(VaiTroCan) Then
		Return;
	EndIf;
	
	For Each TenVaiTro In StrSplit(VaiTroCan, ",") Do
		If IsInRole(TenVaiTro) Then
			Return;
		EndIf;
	EndDo;
	
	WriteLogEvent("Security.APApproval", EventLogLevel.Warning,,, 
		StrTemplate("%1 không có vai trò duyệt bước %2 -> %3", NguoiDungHienTai, TrangThaiCu, TrangThaiMoi));
	Raise StrTemplate("Bạn không có thẩm quyền duyệt bước '%1'. Vai trò được phép: %2.", TrangThaiCu, VaiTroCan);
EndProcedure

// Hoa don co bat buoc qua buoc CFO khong (neu TongTien > 500tr)
Function HoaDonCanDuyetCFO(Val PhapNhan, Val DoiTac, Val SoTien, Val ThoiDiem = Undefined, Val LoaiTruRef = Undefined) Export
	NguongCFO = Constants.NguongPheDuyetChiTienCFO.Get();
	If NguongCFO <= 0 Then
		NguongCFO = 500000000;
	EndIf;
	Return (Number(SoTien) > NguongCFO);
EndFunction

#EndRegion
