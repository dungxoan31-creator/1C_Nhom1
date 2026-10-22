// Form Module: HoaDonNhaCungCap

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

&AtServer
Procedure ThietLapTrangThaiForm()
	If Object.Posted Then
		ReadOnly = True;
	EndIf;
	Items.Number.ReadOnly = True;
	If Items.Find("TongTien") <> Undefined Then
		Items.TongTien.ReadOnly = True;
	EndIf;
	If Items.Find("TienThueVAT") <> Undefined Then
		Items.TienThueVAT.ReadOnly = True;
	EndIf;
EndProcedure

&AtClient
Procedure AfterWrite(WriteParameters)
	CapNhatHTMLHeaderAtServer();
	ShowUserNotification("Lưu hóa đơn mua vào", , "Hóa đơn NCC " + Object.Number + " đã được ghi nhận.", PictureLib.Information);
EndProcedure

#EndRegion

#Region FormHeaderItemsEventHandlers

&AtClient
Procedure TienDichVuOnChange(Item)
	TinhLaiTongClient();
EndProcedure

&AtClient
Procedure CmdXemChungTuLienQuan(Command)
	ThongTinLienQuan = "Chuỗi chứng từ: Hợp đồng mua -> Hóa đơn NCC " + Object.Number + " -> Ủy nhiệm chi thanh toán";
	ShowUserNotification("Chứng từ liên quan", , ThongTinLienQuan, PictureLib.Information);
EndProcedure

#EndRegion

#Region Private

&AtClient
Procedure TinhLaiTongClient()
	// Tính toán số học nhẹ trực tiếp tại Client theo chuẩn 1C #std629
	Object.TienThueVAT = Object.TienDichVu * 0.1;
	Object.TongTien = Object.TienDichVu + Object.TienThueVAT;
	CapNhatHTMLHeaderAtServer();
EndProcedure

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
		If Object.TrangThai = Enums.TrangThaiHoaDonAP.ChoDuyetCFO Then
			TrangThaiText = "CHỜ CFO DUYỆT";
			TrangThaiColor = "#B71C1C";
			TrangThaiBg = "#FFEBEE";
			StepIndex = 3;
		ElsIf Object.TrangThai = Enums.TrangThaiHoaDonAP.ChoKeToanTruongDuyet Then
			TrangThaiText = "CHỜ KTT DUYỆT";
			TrangThaiColor = "#C2185B";
			TrangThaiBg = "#FCE4EC";
			StepIndex = 3;
		ElsIf Object.TrangThai = Enums.TrangThaiHoaDonAP.ChoDuyetITDirector Then
			TrangThaiText = "CHỜ IT DIR DUYỆT";
			TrangThaiColor = "#7B1FA2";
			TrangThaiBg = "#F3E5F5";
			StepIndex = 2;
		ElsIf Object.TrangThai = Enums.TrangThaiHoaDonAP.ChoDuyetPM Then
			TrangThaiText = "CHỜ PM DUYỆT";
			TrangThaiColor = "#E65100";
			TrangThaiBg = "#FFF3E0";
			StepIndex = 2;
		ElsIf Object.TrangThai = Enums.TrangThaiHoaDonAP.ChoDuyetKyThuat Then
			TrangThaiText = "CHỜ DUYỆT KỸ THUẬT";
			TrangThaiColor = "#F57C00";
			TrangThaiBg = "#FFF8E1";
			StepIndex = 2;
		ElsIf Object.TrangThai = Enums.TrangThaiHoaDonAP.TuChoi Then
			TrangThaiText = "TỪ CHỐI";
			TrangThaiColor = "#C62828";
			TrangThaiBg = "#FFEBEE";
			StepIndex = 0;
		EndIf;
	EndIf;
	
	TongTienStr = Format(Object.TongTien, "NFD=0; NGS='.'; NG=3") + " VND";
	
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
		"<div class='doc-title'>Hóa Đơn Nhà Cung Cấp: " + Object.Number + " &nbsp;<span class='badge'>" + TrangThaiText + "</span></div>" +
		"<div style='font-size:12px;color:#64748B;margin-top:2px;'>Ngày: " + Format(Object.Date, "DF=dd/MM/yyyy") + "</div>" +
		"</div>" +
		"<div>" +
		"<div class='amount-lbl'>TỔNG THANH TOÁN AP</div>" +
		"<div class='amount-val'>" + TongTienStr + "</div>" +
		"</div>" +
		"</div>" +
		"<div class='stepper WorkflowStepper'>" +
		"<span class='" + Step1Class + "'>① Tiếp nhận nháp</span>" +
		"<span class='step-arrow'>➔</span>" +
		"<span class='" + Step2Class + "'>② Kế toán AP soát xét</span>" +
		"<span class='step-arrow'>➔</span>" +
		"<span class='" + Step3Class + "'>③ CFO phê duyệt chi</span>" +
		"<span class='step-arrow'>➔</span>" +
		"<span class='" + Step4Class + "'>④ Đã ghi sổ</span>" +
		"</div>" +
		"</body></html>";
	NoiDungHTMLHeader = BangDieuKhienServer.ChuyenHTMLSangASCII(NoiDungHTMLHeader);
EndProcedure

#EndRegion
