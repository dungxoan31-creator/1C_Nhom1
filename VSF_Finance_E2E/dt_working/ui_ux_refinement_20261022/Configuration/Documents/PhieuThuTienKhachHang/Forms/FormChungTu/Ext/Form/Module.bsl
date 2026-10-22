// Form Module: PhieuThuTienKhachHang

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
EndProcedure

&AtClient
Procedure AfterWrite(WriteParameters)
	CapNhatHTMLHeaderAtServer();
	ShowUserNotification("Thu tiền thành công", , "Phiếu thu tiền " + Object.Number + " đã được ghi nhận.", PictureLib.Information);
EndProcedure

#EndRegion

#Region FormHeaderItemsEventHandlers

&AtClient
Procedure SoTienOnChange(Item)
	CapNhatNgoaiTeTheoSoTienAtServer();
	CapNhatHTMLHeaderAtServer();
EndProcedure

&AtClient
Procedure ChungTuGocOnChange(Item)
	NapTheoChungTuGocAtServer();
	CapNhatHTMLHeaderAtServer();
EndProcedure

&AtClient
Procedure TienTeOnChange(Item)
	CapNhatTheoTienTeAtServer();
	CapNhatHTMLHeaderAtServer();
EndProcedure

&AtClient
Procedure TyGiaOnChange(Item)
	CapNhatSoTienTheoNgoaiTeAtServer();
	CapNhatHTMLHeaderAtServer();
EndProcedure

&AtClient
Procedure SoTienNgoaiTeOnChange(Item)
	CapNhatSoTienTheoNgoaiTeAtServer();
	CapNhatHTMLHeaderAtServer();
EndProcedure

&AtClient
Procedure CmdXemChungTuLienQuan(Command)
	ThongTinLienQuan = "Chuỗi chứng từ: Hóa đơn GTGT đầu ra -> Phiếu thu tiền " + Object.Number;
	ShowUserNotification("Chứng từ liên quan", , ThongTinLienQuan, PictureLib.Information);
EndProcedure

#EndRegion

#Region Private

&AtServer
Procedure NapTheoChungTuGocAtServer()
	If Not ValueIsFilled(Object.ChungTuGoc) Then
		Return;
	EndIf;

	If TypeOf(Object.ChungTuGoc) = Type("DocumentRef.HoaDonGTGTDauRa") Then
		Source = Object.ChungTuGoc.GetObject();
		Object.PhapNhan = Source.PhapNhan;
		Object.DoiTac = Source.DoiTac;
		Object.HopDong = Source.HopDong;
		Object.SoTien = Source.TongTienThanhToan;
		Object.TienTe = Source.TienTe;
		Object.SoTienNgoaiTe = Source.TongTienNgoaiTe;
		Object.TyGia = 0;
	ElsIf TypeOf(Object.ChungTuGoc) = Type("DocumentRef.BienBanNghiemThuGiaiDoan") Then
		Source = Object.ChungTuGoc.GetObject();
		Object.PhapNhan = Source.PhapNhan;
		Object.DoiTac = Source.DoiTac;
		Object.HopDong = Source.HopDong;
		Object.SoTien = Source.TongGiaTri;
		Object.TienTe = Catalogs.TienTe.FindByCode("VND");
		Object.SoTienNgoaiTe = 0;
		Object.TyGia = 1;
	EndIf;
EndProcedure

&AtServer
Procedure CapNhatTheoTienTeAtServer()
	If Not ValueIsFilled(Object.TienTe) Then
		Return;
	EndIf;
	If TrimAll(Upper(String(Object.TienTe.Code))) = "VND" Then
		Object.TyGia = 1;
		Object.SoTienNgoaiTe = 0;
	ElsIf Object.SoTienNgoaiTe > 0 And Object.TyGia > 0 Then
		Object.SoTien = Round(Object.SoTienNgoaiTe * Object.TyGia, 2);
	EndIf;
EndProcedure

&AtServer
Procedure CapNhatSoTienTheoNgoaiTeAtServer()
	If ValueIsFilled(Object.TienTe) And TrimAll(Upper(String(Object.TienTe.Code))) <> "VND"
		And Object.SoTienNgoaiTe > 0 And Object.TyGia > 0 Then
		Object.SoTien = Round(Object.SoTienNgoaiTe * Object.TyGia, 2);
	EndIf;
EndProcedure

&AtServer
Procedure CapNhatNgoaiTeTheoSoTienAtServer()
	If ValueIsFilled(Object.TienTe) And TrimAll(Upper(String(Object.TienTe.Code))) <> "VND"
		And Object.SoTien > 0 And Object.TyGia > 0 Then
		Object.SoTienNgoaiTe = Round(Object.SoTien / Object.TyGia, 2);
	EndIf;
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
		If Not Object.Ref.IsEmpty() Then
			TrangThaiText = "CHỜ THỦ QUỸ";
			TrangThaiColor = "#1565C0";
			TrangThaiBg = "#E3F2FD";
			StepIndex = 2;
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
		"<div class='doc-title'>Phiếu Thu Tiền Khách Hàng: " + Object.Number + " &nbsp;<span class='badge'>" + TrangThaiText + "</span></div>" +
		"<div style='font-size:12px;color:#64748B;margin-top:2px;'>Ngày: " + Format(Object.Date, "DF=dd/MM/yyyy") + "</div>" +
		"</div>" +
		"<div>" +
		"<div class='amount-lbl'>SỐ TIỀN THU AR</div>" +
		"<div class='amount-val'>" + TongTienStr + "</div>" +
		"</div>" +
		"</div>" +
		"<div class='stepper WorkflowStepper'>" +
		"<span class='" + Step1Class + "'>① Lập phiếu thu</span>" +
		"<span class='step-arrow'>➔</span>" +
		"<span class='" + Step2Class + "'>② Thủ quỹ xác nhận</span>" +
		"<span class='step-arrow'>➔</span>" +
		"<span class='" + Step3Class + "'>③ Kế toán ghi nhận</span>" +
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


