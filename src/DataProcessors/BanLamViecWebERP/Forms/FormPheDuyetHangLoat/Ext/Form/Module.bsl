// Form Module: FormPheDuyetHangLoat

#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	TaoGiaoDienPheDuyetHTML();
EndProcedure

#EndRegion

#Region FormHeaderItemsEventHandlers

&AtClient
Procedure TruongHTMLPheDuyetOnClick(Item, EventData, StandardProcessing)
	If EventData = Undefined Then Return; EndIf;
	Href = ?(EventData.Href <> Undefined, EventData.Href, ?(EventData.Anchor <> Undefined, EventData.Anchor, ""));
	
	If StrFind(Href, "approve-all") > 0 Then
		StandardProcessing = False;
		KetQua = ThucHienPheDuyetTatCaAtServer();
		ThongBao = StrTemplate("Phê duyệt hoàn tất: %1 thành công, %2 thất bại.", KetQua.ThanhCong, KetQua.ThatBai);
		ShowUserNotification("Kết quả phê duyệt Maker-Checker", , ThongBao, PictureLib.Information);
		TaoGiaoDienPheDuyetHTML();
	ElsIf StrFind(Href, "refresh") > 0 Then
		StandardProcessing = False;
		TaoGiaoDienPheDuyetHTML();
		ShowUserNotification("Làm mới danh sách", , "Đã cập nhật danh sách chờ duyệt.", PictureLib.Information);
	ElsIf StrFind(Href, "e1cib/data/") > 0 Then
		StandardProcessing = False;
		GotoURL(Href);
	EndIf;
EndProcedure

#EndRegion

#Region Private

&AtServer
Function ThucHienPheDuyetTatCaAtServer()
	DanhSach = DataProcessors.BanLamViecWebERP.LayDanhSachChoPheDuyet();
	DanhSachChungTu = New Array;
	For Each Item In DanhSach Do
		DanhSachChungTu.Add(Item.ChungTu);
	EndDo;
	
	DPObj = FormAttributeToValue("Object");
	KetQua = DPObj.PheDuyetHangLoat(DanhSachChungTu);
	Return KetQua;
EndFunction

&AtServer
Procedure TaoGiaoDienPheDuyetHTML()
	DanhSach = DataProcessors.BanLamViecWebERP.LayDanhSachChoPheDuyet();
	
	RowsHTML = "";
	SoLuong = 0;
	TongTien = 0;
	
	For Each Item In DanhSach Do
		SoLuong = SoLuong + 1;
		TongTien = TongTien + Item.SoTien;
		URL = GetURL(Item.ChungTu);
		SoTienStr = Format(Item.SoTien, "NFD=0; NGS='.'; NG=3") + " VND";
		NgayStr = Format(Item.NgayChungTu, "DF=dd/MM/yyyy");
		
		RowsHTML = RowsHTML + 
			"<tr>" +
			"<td style='padding:10px 14px;border-bottom:1px solid #E2E8F0;font-weight:600;'>" + Item.TenLoaiChungTu + "</td>" +
			"<td style='padding:10px 14px;border-bottom:1px solid #E2E8F0;'><a href='" + URL + "' style='color:#EA0B2A;text-decoration:none;font-weight:700;'>" + Item.SoChungTu + "</a></td>" +
			"<td style='padding:10px 14px;border-bottom:1px solid #E2E8F0;color:#64748B;'>" + NgayStr + "</td>" +
			"<td style='padding:10px 14px;border-bottom:1px solid #E2E8F0;font-weight:600;color:#1E293B;'>" + Item.DoiTac + "</td>" +
			"<td style='padding:10px 14px;border-bottom:1px solid #E2E8F0;text-align:right;font-weight:700;color:#0F172A;'>" + SoTienStr + "</td>" +
			"<td style='padding:10px 14px;border-bottom:1px solid #E2E8F0;text-align:center;'><span style='background:#FFF3E0;color:#E65100;padding:4px 10px;border-radius:12px;font-size:11px;font-weight:700;'>⏳ " + Item.TrangThai + "</span></td>" +
			"</tr>";
	EndDo;
	
	If SoLuong = 0 Then
		RowsHTML = "<tr><td colspan='6' style='text-align:center;padding:36px;color:#64748B;font-size:14px;'>🎉 Không có chứng từ nào đang chờ phê duyệt. Toàn bộ hệ thống đã được đồng bộ!</td></tr>";
	EndIf;
	
	TongTienStr = Format(TongTien, "NFD=0; NGS='.'; NG=3") + " VND";
	
	NoiDungHTML = 
		"<!DOCTYPE html><html><head><meta charset='utf-8'/><style>" +
		"body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #F8FAFC; margin: 0; padding: 24px; color: #1E293B; }" +
		".card { background: #FFFFFF; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); border: 1px solid #E2E8F0; overflow: hidden; }" +
		".header { display: flex; justify-content: space-between; align-items: center; padding: 20px 24px; border-bottom: 1px solid #E2E8F0; background: #FFFFFF; }" +
		".title { font-size: 18px; font-weight: 800; color: #0F172A; display: flex; align-items: center; gap: 10px; }" +
		".summary { display: flex; gap: 20px; font-size: 13px; color: #64748B; }" +
		".summary b { color: #0F172A; font-weight: 700; }" +
		".btn-approve { display: inline-flex; align-items: center; gap: 6px; padding: 10px 20px; background: #EA0B2A; color: #FFFFFF; text-decoration: none; border-radius: 8px; font-weight: 700; font-size: 13px; box-shadow: 0 2px 4px rgba(234,11,42,0.25); cursor: pointer; }" +
		".btn-refresh { display: inline-flex; align-items: center; gap: 6px; padding: 10px 16px; background: #F1F5F9; color: #334155; text-decoration: none; border-radius: 8px; font-weight: 600; font-size: 13px; cursor: pointer; }" +
		"table { width: 100%; border-collapse: collapse; font-size: 13px; }" +
		"th { background: #F8FAFC; text-align: left; padding: 12px 14px; font-weight: 700; color: #475569; border-bottom: 2px solid #E2E8F0; font-size: 12px; text-transform: uppercase; letter-spacing: 0.5px; }" +
		"</style></head><body>" +
		"<div class='card'>" +
		"<div class='header'>" +
		"<div>" +
		"<div class='title'>⚡ Bàn Duyệt Maker-Checker Hàng Loạt</div>" +
		"<div class='summary' style='margin-top:6px;'>Đang chờ duyệt: <b>" + SoLuong + " chứng từ</b> | Tổng giá trị: <b style='color:#EA0B2A;'>" + TongTienStr + "</b></div>" +
		"</div>" +
		"<div style='display:flex;gap:10px;'>" +
		"<a href='vinsmart:action:refresh' class='btn-refresh'>🔄 Làm mới</a>" +
		"<a href='vinsmart:action:approve-all' class='btn-approve'>✓ Phê duyệt toàn bộ</a>" +
		"</div>" +
		"</div>" +
		"<table>" +
		"<thead><tr>" +
		"<th>Loại chứng từ</th><th>Số chứng từ</th><th>Ngày</th><th>Đối tác</th><th style='text-align:right;'>Số tiền</th><th style='text-align:center;'>Trạng thái</th>" +
		"</tr></thead>" +
		"<tbody>" +
		RowsHTML +
		"</tbody></table>" +
		"</div></body></html>";
EndProcedure

#EndRegion
