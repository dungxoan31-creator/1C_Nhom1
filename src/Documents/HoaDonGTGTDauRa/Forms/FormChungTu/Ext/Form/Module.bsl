// Form Module: HoaDonGTGTDauRa

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	CapNhatHTMLHeader();
EndProcedure

&AtClient
Procedure TienChuaThueOnChange(Item)
	TinhLaiTong();
EndProcedure

&AtServer
Procedure TinhLaiTong()
	Object.TienThueVAT = Object.TienChuaThue * 0.1;
	Object.TongTienThanhToan = Object.TienChuaThue + Object.TienThueVAT;
	CapNhatHTMLHeader();
EndProcedure

&AtServer
Procedure CapNhatHTMLHeader()
	TrangThaiText = "CHUA GHI SO";
	TrangThaiColor = "#EF4444";
	TrangThaiBg = "#FEF2F2";
	If Object.Ref.IsEmpty() Then
		TrangThaiText = "BAN NHAP MOI";
		TrangThaiColor = "#F59E0B";
		TrangThaiBg = "#FFFBEB";
	ElsIf Object.Posted Then
		TrangThaiText = "DA GHI SO";
		TrangThaiColor = "#10B981";
		TrangThaiBg = "#ECFDF5";
	EndIf;
	
	TongTienStr = Format(Object.TongTienThanhToan, "NFD=0; NGS='.'; NG=3") + " VND";
	
	NoiDungHTMLHeader = 
		"<!DOCTYPE html><html><head><meta charset='utf-8'/><style>" +
		"body { margin: 0; padding: 12px; font-family: -apple-system, sans-serif; background: #FFFFFF; border-bottom: 2px solid #EA0B2A; display: flex; justify-content: space-between; align-items: center; }" +
		".doc-title { font-size: 16px; font-weight: 700; color: #0F172A; }" +
		".doc-sub { font-size: 12px; color: #64748B; margin-top: 4px; }" +
		".badge { display: inline-block; padding: 4px 10px; border-radius: 12px; font-size: 11px; font-weight: 700; background: " + TrangThaiBg + "; color: " + TrangThaiColor + "; }" +
		".amount-box { text-align: right; }" +
		".amount-val { font-size: 18px; font-weight: 800; color: #EA0B2A; }" +
		".amount-lbl { font-size: 11px; color: #64748B; }" +
		"</style></head><body>" +
		"<div>" +
		"<div class='doc-title'>Hoa Don GTGT Dau Ra: " + Object.Number + "</div>" +
		"<div class='doc-sub'>Ngay: " + Format(Object.Date, "DF=dd/MM/yyyy") + " &nbsp; <span class='badge'>" + TrangThaiText + "</span></div>" +
		"</div>" +
		"<div class='amount-box'>" +
		"<div class='amount-lbl'>TONG THANH TOAN</div>" +
		"<div class='amount-val'>" + TongTienStr + "</div>" +
		"</div>" +
		"</body></html>";
EndProcedure
