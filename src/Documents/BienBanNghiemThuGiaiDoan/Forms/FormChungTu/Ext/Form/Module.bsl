// Form Module: BienBanNghiemThuGiaiDoan

#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	CapNhatHTMLHeader();
EndProcedure

&AtClient
Procedure AfterWrite(WriteParameters)
	CapNhatHTMLHeaderAtServer();
	ShowUserNotification("Lưu biên bản thành công", , "Biên bản nghiệm thu " + Object.Number + " đã được ghi nhận.", PictureLib.Information);
EndProcedure

#EndRegion

#Region FormHeaderItemsEventHandlers

&AtClient
Procedure GiaTriNghiemThuChuaVATOnChange(Item)
	TinhLaiTongClient();
EndProcedure

&AtClient
Procedure TyLeVATOnChange(Item)
	TinhLaiTongClient();
EndProcedure

#EndRegion

#Region Private

&AtClient
Procedure TinhLaiTongClient()
	// Tính toán số học nhẹ trực tiếp tại Client theo chuẩn 1C #std629
	TyLe = ?(Object.TyLeVAT > 0, Object.TyLeVAT / 100, 0.1);
	Object.TienVAT = Object.GiaTriNghiemThuChuaVAT * TyLe;
	Object.TongGiaTri = Object.GiaTriNghiemThuChuaVAT + Object.TienVAT;
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
		// Kiểm tra trạng thái nghiệm thu
		If Object.TrangThai = Enums.TrangThaiNghiemThuAR.DaNghiemThu Then
			TrangThaiText = "ĐÃ NGHIỆM THU";
			TrangThaiColor = "#1565C0";
			TrangThaiBg = "#E3F2FD";
			StepIndex = 3;
		ElsIf Object.TrangThai = Enums.TrangThaiNghiemThuAR.ChoDuyet Then
			TrangThaiText = "CHỜ DUYỆT";
			TrangThaiColor = "#E65100";
			TrangThaiBg = "#FFF3E0";
			StepIndex = 2;
		EndIf;
	EndIf;
	
	TongTienStr = Format(Object.TongGiaTri, "NFD=0; NGS='.'; NG=3") + " VND";
	
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
		"<div class='doc-title'>Biên Bản Nghiệm Thu: " + Object.Number + " &nbsp;<span class='badge'>" + TrangThaiText + "</span></div>" +
		"<div style='font-size:12px;color:#64748B;margin-top:2px;'>Ngày: " + Format(Object.Date, "DF=dd/MM/yyyy") + "</div>" +
		"</div>" +
		"<div>" +
		"<div class='amount-lbl'>TỔNG GIÁ TRỊ NGHIỆM THU</div>" +
		"<div class='amount-val'>" + TongTienStr + "</div>" +
		"</div>" +
		"</div>" +
		"<div class='stepper WorkflowStepper'>" +
		"<span class='" + Step1Class + "'>① Tiếp nhận hồ sơ</span>" +
		"<span class='step-arrow'>➔</span>" +
		"<span class='" + Step2Class + "'>② Soát xét hồ sơ</span>" +
		"<span class='step-arrow'>➔</span>" +
		"<span class='" + Step3Class + "'>③ Nghiệm thu bàn giao</span>" +
		"<span class='step-arrow'>➔</span>" +
		"<span class='" + Step4Class + "'>④ Đã ghi sổ</span>" +
		"</div>" +
		"</body></html>";
EndProcedure

#EndRegion
