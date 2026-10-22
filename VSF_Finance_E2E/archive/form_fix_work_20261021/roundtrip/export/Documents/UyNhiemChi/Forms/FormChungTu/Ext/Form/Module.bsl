// Form Module: UyNhiemChi

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
	CapNhatQuyenGuiNganHang();
EndProcedure

&AtClient
Procedure AfterWrite(WriteParameters)
	CapNhatHTMLHeaderAtServer();
	ShowUserNotification("Chi tiền thành công", , "Ủy nhiệm chi " + Object.Number + " đã được ghi nhận.", PictureLib.Information);
EndProcedure

#EndRegion

#Region FormHeaderItemsEventHandlers

&AtClient
Procedure SoTienOnChange(Item)
	CapNhatHTMLHeaderAtServer();
EndProcedure

&AtClient
Procedure CmdXemChungTuLienQuan(Command)
	ThongTinLienQuan = "Chuỗi chứng từ: Hóa đơn nhà cung cấp -> Ủy nhiệm chi " + Object.Number;
	ShowUserNotification("Chứng từ liên quan", , ThongTinLienQuan, PictureLib.Information);
EndProcedure

&AtClient
Procedure GuiLenhChiNganHang(Command)
	BankResult = GuiLenhChiNganHangAtServer();
	If BankResult.accepted Then
		ThongBao = "Ngân hàng đã xác nhận giao dịch " + BankResult.transaction_id + ".";
		ShowUserNotification("Gửi lệnh chi thành công", , ThongBao, PictureLib.Information);
	Else
		ShowUserNotification("Chưa gửi được lệnh chi", , BankResult.error, PictureLib.Information);
	EndIf;
	CapNhatHTMLHeaderAtServer();
	CapNhatQuyenGuiNganHangAtServer();
EndProcedure

&AtClient
Procedure XacNhanHoanTienNganHang(Command)
	BankResult = XacNhanHoanTienNganHangAtServer();
	If BankResult.accepted Then
		ThongBao = "Ngân hàng xác nhận khoản hoàn tiền " + BankResult.transaction_id + ".";
		ShowUserNotification("Đã xác nhận tiền hoàn", , ThongBao, PictureLib.Information);
	Else
		ShowUserNotification("Chưa xác nhận được tiền hoàn", , BankResult.error, PictureLib.Information);
	EndIf;
	CapNhatHTMLHeaderAtServer();
	CapNhatQuyenGuiNganHangAtServer();
EndProcedure

#EndRegion

#Region Private

&AtServer
Procedure CapNhatHTMLHeaderAtServer()
	CapNhatHTMLHeader();
EndProcedure

&AtServer
Function GuiLenhChiNganHangAtServer()
	Workspace = DataProcessors.BanLamViecWebERP.Create();
	BankResult = Workspace.GuiLenhChiDaDuyetNganHang(Object.Ref);
	CurrentPayment = Object.Ref.GetObject();
	Object.TrangThai = CurrentPayment.TrangThai;
	Object.TrangThaiGuiNganHang = CurrentPayment.TrangThaiGuiNganHang;
	Object.ThoiDiemGuiNganHang = CurrentPayment.ThoiDiemGuiNganHang;
	Object.MaGiaoDichNganHang = CurrentPayment.MaGiaoDichNganHang;
	Return BankResult;
EndFunction

&AtServer
Function XacNhanHoanTienNganHangAtServer()
	Workspace = DataProcessors.BanLamViecWebERP.Create();
	BankResult = Workspace.XacNhanHoanTienNganHang(Object.Ref);
	CurrentRefund = Object.Ref.GetObject();
	Object.TrangThai = CurrentRefund.TrangThai;
	Object.NguoiDuyet = CurrentRefund.NguoiDuyet;
	Object.TrangThaiGuiNganHang = CurrentRefund.TrangThaiGuiNganHang;
	Object.ThoiDiemGuiNganHang = CurrentRefund.ThoiDiemGuiNganHang;
	Object.MaGiaoDichNganHang = CurrentRefund.MaGiaoDichNganHang;
	Return BankResult;
EndFunction

&AtServer
Procedure CapNhatQuyenGuiNganHangAtServer()
	CapNhatQuyenGuiNganHang();
EndProcedure

&AtServer
Procedure CapNhatQuyenGuiNganHang()
	CanSendToBank = False;
	If Not Object.LaTraSoatHoanTra And TypeOf(Object.ChungTuGoc) = Type("DocumentRef.HoaDonNhaCungCap") Then
		CanSendToBank = Object.ChungTuGoc.Posted;
	EndIf;
	Items.CmdGuiLenhChiNganHang.Visible = Not Object.Posted
		And Object.TrangThai = Enums.TrangThaiLenhThanhToan.DaDuyet
		And IsInRole("KeToanTruong") And CanSendToBank;
	CanConfirmRefund = False;
	If Object.LaTraSoatHoanTra And TypeOf(Object.ChungTuGoc) = Type("DocumentRef.UyNhiemChi") Then
		CanConfirmRefund = Object.ChungTuGoc.Posted
			And Object.ChungTuGoc.TrangThaiGuiNganHang = "ACCEPTED"
			And Not IsBlankString(Object.ChungTuGoc.MaGiaoDichNganHang);
	EndIf;
	Items.CmdXacNhanHoanTienNganHang.Visible = Not Object.Posted
		And Object.TrangThai = Enums.TrangThaiLenhThanhToan.DaDuyet
		And Object.TrangThaiGuiNganHang <> "REFUND_RECEIVED"
		And IsInRole("GiamDocTaiChinh_CFO") And CanConfirmRefund;
EndProcedure

&AtServer
Procedure CapNhatHTMLHeader()
	TrangThaiText = "BẢN NHÁP";
	TrangThaiColor = "#F57F17";
	TrangThaiBg = "#FFF8E1";
	StepIndex = 1;
	CapNhatQuyenGuiNganHang();
	
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
		If Object.TrangThai = Enums.TrangThaiLenhThanhToan.ChoDuyet Then
			TrangThaiText = "CHỜ DUYỆT";
			TrangThaiColor = "#E65100";
			TrangThaiBg = "#FFF3E0";
			StepIndex = 2;
		ElsIf Object.TrangThai = Enums.TrangThaiLenhThanhToan.DaDuyet Or Object.TrangThai = Enums.TrangThaiLenhThanhToan.DaGuiNganHang Then
			TrangThaiText = "ĐÃ DUYỆT / GỬI NH";
			TrangThaiColor = "#1565C0";
			TrangThaiBg = "#E3F2FD";
			StepIndex = 3;
		ElsIf Object.TrangThai = Enums.TrangThaiLenhThanhToan.TuChoi Then
			TrangThaiText = "TỪ CHỐI";
			TrangThaiColor = "#C62828";
			TrangThaiBg = "#FFEBEE";
			StepIndex = 0;
		EndIf;
	EndIf;
	
	TongTienStr = Format(Object.SoTien, "NFD=0; NGS='.'; NG=3") + " VND";
	
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
		"<div class='doc-title'>Ủy Nhiệm Chi: " + Object.Number + " &nbsp;<span class='badge'>" + TrangThaiText + "</span></div>" +
		"<div style='font-size:12px;color:#64748B;margin-top:2px;'>Ngày: " + Format(Object.Date, "DF=dd/MM/yyyy") + "</div>" +
		"</div>" +
		"<div>" +
		"<div class='amount-lbl'>TỔNG TIỀN CHI NGÂN HÀNG</div>" +
		"<div class='amount-val'>" + TongTienStr + "</div>" +
		"</div>" +
		"</div>" +
		"<div class='stepper WorkflowStepper'>" +
		"<span class='" + Step1Class + "'>① Lập lệnh chi</span>" +
		"<span class='step-arrow'>➔</span>" +
		"<span class='" + Step2Class + "'>② Kiểm soát tài chính</span>" +
		"<span class='step-arrow'>➔</span>" +
		"<span class='" + Step3Class + "'>③ CFO duyệt chi</span>" +
		"<span class='step-arrow'>➔</span>" +
		"<span class='" + Step4Class + "'>④ Đã ghi sổ</span>" +
		"</div>" +
		"</body></html>";
	NoiDungHTMLHeader = BangDieuKhienServer.ChuyenHTMLSangASCII(NoiDungHTMLHeader);
EndProcedure

#EndRegion
