// Form Module: UyNhiemChi

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	CapNhatHTMLHeader();
EndProcedure

&AtServer
Procedure CapNhatHTMLHeader()
	TrangThaiText = "CHƯA GHI SỔ";
	TrangThaiColor = "#EF4444";
	TrangThaiBg = "#FEF2F2";
	If Object.Ref.IsEmpty() Then
		TrangThaiText = "BẢN NHÁP MỚI";
		TrangThaiColor = "#F59E0B";
		TrangThaiBg = "#FFFBEB";
	ElsIf Object.Posted Then
		TrangThaiText = "ĐÃ GHI SỔ";
		TrangThaiColor = "#10B981";
		TrangThaiBg = "#ECFDF5";
	EndIf;
	
	TongTienStr = Format(Object.SoTien, "NFD=0; NGS='.'; NG=3") + " VNĐ";
	
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
		"<div class='doc-title'>Ủy Nhiệm Chi (Bank Payment): " + Object.Number + "</div>" +
		"<div class='doc-sub'>Ngày: " + Format(Object.Date, "DF=dd/MM/yyyy") + " &nbsp; <span class='badge'>" + TrangThaiText + "</span></div>" +
		"</div>" +
		"<div class='amount-box'>" +
		"<div class='amount-lbl'>SỐ TIỀN CHI</div>" +
		"<div class='amount-val'>" + TongTienStr + "</div>" +
		"</div>" +
		"</body></html>";
EndProcedure
