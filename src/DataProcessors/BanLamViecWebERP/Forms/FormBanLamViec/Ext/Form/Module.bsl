// Form Module: FormBanLamViec

#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	CapNhatDuLieuDashboard();
EndProcedure

#EndRegion

#Region FormHeaderItemsEventHandlers

&AtClient
Procedure TruongHTMLCockpitOnClick(Item, EventData, StandardProcessing)
	If EventData = Undefined Then Return; EndIf;
	Href = ?(EventData.Href <> Undefined, EventData.Href, ?(EventData.Anchor <> Undefined, EventData.Anchor, ""));
	
	If StrFind(Href, "action=refresh") > 0 Or StrFind(Href, "refresh") > 0 Then
		StandardProcessing = False;
		CapNhatDuLieuDashboardAtServer();
		ShowUserNotification("Làm mới thành công", , "Dữ liệu Dashboard đã được cập nhật mới nhất.", PictureLib.Information);
	ElsIf StrFind(Href, "batch_approve") > 0 Then
		StandardProcessing = False;
		OpenForm("DataProcessor.BanLamViecWebERP.Form.FormPheDuyetHangLoat");
	ElsIf StrFind(Href, "new_ar_invoice") > 0 Or StrFind(Href, "Document.HoaDonGTGTDauRa") > 0 Then
		StandardProcessing = False;
		OpenForm("Document.HoaDonGTGTDauRa.ObjectForm");
	ElsIf StrFind(Href, "new_ap_invoice") > 0 Or StrFind(Href, "Document.HoaDonNhaCungCap") > 0 Then
		StandardProcessing = False;
		OpenForm("Document.HoaDonNhaCungCap.ObjectForm");
	ElsIf StrFind(Href, "new_payment_order") > 0 Or StrFind(Href, "Document.UyNhiemChi") > 0 Then
		StandardProcessing = False;
		OpenForm("Document.UyNhiemChi.ObjectForm");
	ElsIf StrFind(Href, "new_receipt") > 0 Or StrFind(Href, "Document.PhieuThuTienKhachHang") > 0 Then
		StandardProcessing = False;
		OpenForm("Document.PhieuThuTienKhachHang.ObjectForm");
	ElsIf StrFind(Href, "Document.BienBanNghiemThuGiaiDoan") > 0 Then
		StandardProcessing = False;
		OpenForm("Document.BienBanNghiemThuGiaiDoan.ObjectForm");
	ElsIf StrFind(Href, "open=") > 0 Then
		StandardProcessing = False;
		DocType = Mid(Href, StrFind(Href, "open=") + 5);
		If Not IsBlankString(DocType) Then
			Try
				OpenForm("Document." + DocType + ".ListForm");
			Except
			EndTry;
		EndIf;
	EndIf;
EndProcedure

#EndRegion

#Region Private

&AtServer
Procedure CapNhatDuLieuDashboard()
	TemplateObj = GetCommonTemplate("MauHTMLTrangChu");
	HTMLTemplate = TemplateObj.GetText();
	
	Try
		ChuoiJSON = BangDieuKhienServer.LayDuLieuTongQuan("ThangNay");
	Except
		ChuoiJSON = "{}";
	EndTry;
	
	ScriptInjection = 
		Chars.LF + "<script>" + Chars.LF +
		"try {" + Chars.LF +
		"    var _dashData = " + ChuoiJSON + ";" + Chars.LF +
		"    if (typeof updateDashboardData === 'function') { updateDashboardData(_dashData); }" + Chars.LF +
		"} catch(e) {}" + Chars.LF +
		"window.onload = function() {" + Chars.LF +
		"    try { if (typeof updateDashboardData === 'function') { updateDashboardData(" + ChuoiJSON + "); } } catch(e) {}" + Chars.LF +
		"};" + Chars.LF +
		"</script>" + Chars.LF;
	
	NoiDungHTML = StrReplace(HTMLTemplate, "</body>", ScriptInjection + "</body>");
EndProcedure

&AtServer
Procedure CapNhatDuLieuDashboardAtServer()
	CapNhatDuLieuDashboard();
EndProcedure

#EndRegion
