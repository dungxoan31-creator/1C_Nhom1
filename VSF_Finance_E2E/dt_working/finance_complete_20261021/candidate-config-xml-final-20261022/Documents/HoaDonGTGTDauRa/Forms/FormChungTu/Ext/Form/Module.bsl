// Form Module: HoaDonGTGTDauRa

#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	CapNhatHTMLHeader();
	ThietLapTrangThaiForm();
EndProcedure

&AtServer
Procedure OnReadAtServer(CurrentObject)
	CapNhatHTMLHeader();
	ThietLapTrangThaiForm();
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	CapNhatDanhSachNguoiDuyet();
EndProcedure

&AtServer
Procedure ThietLapTrangThaiForm()
	If Object.Posted Then
		ReadOnly = True;
	EndIf;
	Items.Number.ReadOnly = True;
	If Items.Find("TongTienThanhToan") <> Undefined Then
		Items.TongTienThanhToan.ReadOnly = True;
	EndIf;
	If Items.Find("TienThueVAT") <> Undefined Then
		Items.TienThueVAT.ReadOnly = True;
	EndIf;
	If Items.Find("ApDungGiamThueGTGT") <> Undefined Then
		Items.ApDungGiamThueGTGT.ReadOnly = ValueIsFilled(Object.BienBanNghiemThu);
	EndIf;
EndProcedure

&AtClient
Procedure AfterWrite(WriteParameters)
	CapNhatHTMLHeaderAtServer();
	ShowUserNotification("Lưu hóa đơn thành công", , "Hóa đơn GTGT đầu ra " + Object.Number + " đã được ghi nhận.", PictureLib.Information);
EndProcedure

#EndRegion

#Region FormHeaderItemsEventHandlers

&AtClient
Procedure TienChuaThueOnChange(Item)
	TinhLaiTongClient();
EndProcedure

&AtClient
Procedure BienBanNghiemThuOnChange(Item)
	CapNhatTheoBienBanNghiemThu();
	CapNhatDanhSachNguoiDuyet();
EndProcedure

&AtClient
Procedure ApDungGiamThueGTGTOnChange(Item)
	If Not ValueIsFilled(Object.BienBanNghiemThu) Then
		Object.ThueSuatVAT = ThueGTGTClientServer.TyLeVATApDungTheoNgay(Object.NgayHoaDon, Object.ApDungGiamThueGTGT);
	EndIf;
	TinhLaiTongClient();
EndProcedure

&AtClient
Procedure CmdXemChungTuLienQuan(Command)
	ThongTinLienQuan = "Chuỗi chứng từ: Hợp đồng -> Hóa đơn GTGT " + Object.Number + " -> Phiếu thu tiền khách hàng";
	ShowUserNotification("Chứng từ liên quan", , ThongTinLienQuan, PictureLib.Information);
EndProcedure

#EndRegion

#Region Private

&AtClient
Procedure TinhLaiTongClient()
	// Tính toán số học nhẹ trực tiếp tại Client theo chuẩn 1C #std629
	Object.TienThueVAT = Round(Object.TienChuaThue * Object.ThueSuatVAT / 100, 2);
	Object.TongTienThanhToan = Object.TienChuaThue + Object.TienThueVAT;
	CapNhatHTMLHeaderAtServer();
	CapNhatDanhSachNguoiDuyet();
EndProcedure

&AtServer
Procedure CapNhatTheoBienBanNghiemThu()
	If Not ValueIsFilled(Object.BienBanNghiemThu) Then
		Return;
	EndIf;

	BienBan = Object.BienBanNghiemThu.GetObject();
	If BienBan.DeletionMark Then
		Raise "Không thể lập hóa đơn từ Biên bản nghiệm thu đã đánh dấu xóa.";
	EndIf;

	Object.PhapNhan = BienBan.PhapNhan;
	Object.DoiTac = BienBan.DoiTac;
	Object.HopDong = BienBan.HopDong;
	Object.ApDungGiamThueGTGT = BienBan.ApDungGiamThueGTGT;
	Object.TienChuaThue = BienBan.GiaTriNghiemThuChuaVAT;
	Object.ThueSuatVAT = BienBan.TyLeVAT;
	Object.TienThueVAT = BienBan.TienVAT;
	Object.TongTienThanhToan = BienBan.TongGiaTri;
	If Not ValueIsFilled(Object.NgayHoaDon) Then
		Object.NgayHoaDon = BienBan.NgayNghiemThu;
	EndIf;
	Object.DienGiai = StrTemplate("Xuất hóa đơn GTGT theo Biên bản nghiệm thu %1", BienBan.Number);

	If ValueIsFilled(Object.DoiTac) Then
		Object.MaSoThueNguoiMua = Object.DoiTac.MaSoThue;
		Object.DiaChiNguoiMua = Object.DoiTac.DiaChi;
	EndIf;

	CapNhatHTMLHeader();
EndProcedure


&AtClient
Procedure CapNhatDanhSachNguoiDuyet()
	If Items.Find("NguoiDuyet") = Undefined Then
		Return;
	EndIf;

	DanhSachNguoiDung = LayDanhSachNguoiDuyetAtServer();
	Items.NguoiDuyet.ChoiceList.Clear();
	For Each TenNguoiDung In DanhSachNguoiDung Do
		If TenNguoiDung = "ketoan_truong" Then
			Items.NguoiDuyet.ChoiceList.Add(TenNguoiDung, "Kế toán trưởng (ketoan_truong)");
		ElsIf TenNguoiDung = "Admin" Then
			Items.NguoiDuyet.ChoiceList.Add(TenNguoiDung, "Quản trị (Admin)");
		ElsIf TenNguoiDung = "cfo_giamdoc" Then
			Items.NguoiDuyet.ChoiceList.Add(TenNguoiDung, "Giám đốc tài chính / CFO (cfo_giamdoc)");
		EndIf;
	EndDo;
EndProcedure

&AtServer
Function LayDanhSachNguoiDuyetAtServer()
	Return PheDuyetDaCapServer.LayDanhSachNguoiDuyet("HoaDonGTGTDauRa", Object.TongTienThanhToan);
EndFunction

&AtServer
Procedure CapNhatHTMLHeaderAtServer()
	CapNhatHTMLHeader();
EndProcedure

&AtServer
Procedure CapNhatHTMLHeader()
	TrangThaiText = "BẢN NHÁP";
	TrangThaiColor = "#F57F17";
	TrangThaiBg = "#FFF8E1";
	StepIndex = 1;
	
	If Object.DeletionMark Then
		TrangThaiText = "ĐÃ HỦY";
		TrangThaiColor = "#546E7A";
		TrangThaiBg = "#ECEFF1";
		StepIndex = 0;
	ElsIf Object.Posted Then
		TrangThaiText = "ĐÃ GHI SỔ";
		TrangThaiColor = "#2E7D32";
		TrangThaiBg = "#E8F5E9";
		StepIndex = 4;
	Else
		// Bản nháp đã lưu
		If Not Object.Ref.IsEmpty() Then
			TrangThaiText = "CHỜ DUYỆT";
			TrangThaiColor = "#E65100";
			TrangThaiBg = "#FFF3E0";
			StepIndex = 2;
		EndIf;
	EndIf;
	
	TongTienStr = Format(Object.TongTienThanhToan, "NFD=0; NGS='.'; NG=3") + " VND";
	
	Step1Class = ?(StepIndex >= 1, "step-done", "step-pending");
	Step2Class = ?(StepIndex >= 2, "step-done", "step-pending");
	Step3Class = ?(StepIndex >= 3, "step-done", "step-pending");
	Step4Class = ?(StepIndex >= 4, "step-done", "step-pending");
	
	NoiDungHTMLHeader = 
		"<!DOCTYPE html><html><head><meta charset='utf-8'/><style>" +
		"body { margin: 0; padding: 12px 18px; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #FFFFFF; border-bottom: 2px solid #EA0B2A; }" +
		".header-top { display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px; }" +
		".doc-title { font-size: 16px; font-weight: 700; color: #0F172A; display: flex; align-items: center; gap: 8px; }" +
		".badge { display: inline-block; padding: 4px 10px; border-radius: 12px; font-size: 11px; font-weight: 700; background: " + TrangThaiBg + "; color: " + TrangThaiColor + "; }" +
		".amount-val { font-size: 18px; font-weight: 800; color: #EA0B2A; text-align: right; }" +
		".amount-lbl { font-size: 11px; color: #64748B; text-align: right; }" +
		".stepper { display: flex; align-items: center; gap: 6px; font-size: 11px; font-weight: 600; padding: 6px 10px; background: #F8FAFC; border-radius: 8px; border: 1px solid #E2E8F0; }" +
		".step-done { color: #10B981; }" +
		".step-pending { color: #94A3B8; }" +
		".step-arrow { color: #CBD5E1; }" +
		"</style></head><body>" +
		"<div class='header-top'>" +
		"<div>" +
		"<div class='doc-title'>Hóa Đơn GTGT Đầu Ra: " + Object.Number + " &nbsp;<span class='badge'>" + TrangThaiText + "</span></div>" +
		"<div style='font-size:12px;color:#64748B;margin-top:2px;'>Ngày: " + Format(Object.Date, "DF=dd/MM/yyyy") + "</div>" +
		"</div>" +
		"<div>" +
		"<div class='amount-lbl'>TỔNG TIỀN THANH TOÁN</div>" +
		"<div class='amount-val'>" + TongTienStr + "</div>" +
		"</div>" +
		"</div>" +
		"<div class='stepper WorkflowStepper'>" +
		"<span class='" + Step1Class + "'>① Lập nháp</span>" +
		"<span class='step-arrow'>➔</span>" +
		"<span class='" + Step2Class + "'>② Kế toán soát xét</span>" +
		"<span class='step-arrow'>➔</span>" +
		"<span class='" + Step3Class + "'>③ Ký phát hành HĐĐT</span>" +
		"<span class='step-arrow'>➔</span>" +
		"<span class='" + Step4Class + "'>④ Đã ghi sổ</span>" +
		"</div>" +
		"</body></html>";
	NoiDungHTMLHeader = BangDieuKhienServer.ChuyenHTMLSangASCII(NoiDungHTMLHeader);
EndProcedure

#EndRegion


&AtClient
Procedure OpenRegisterRecords(Command)
	Items.Pages.CurrentPage = Items.Find("RegisterRecordsTab");
EndProcedure


