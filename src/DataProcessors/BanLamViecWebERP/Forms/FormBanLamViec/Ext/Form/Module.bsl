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
	If EventData <> Undefined And EventData.Href <> Undefined Then
		Href = EventData.Href;
		If StrFind(Href, "vsmart://action=refresh") > 0 Then
			StandardProcessing = False;
			CapNhatDuLieuDashboardAtServer();
			ShowUserNotification("Làm mới thành công", , "Dữ liệu Dashboard đã được cập nhật mới nhất.", PictureLib.Information);
		ElsIf StrFind(Href, "vsmart://action=batch_approve") > 0 Then
			StandardProcessing = False;
			OpenForm("DataProcessor.BanLamViecWebERP.Form.FormPheDuyetHangLoat");
		ElsIf StrFind(Href, "vsmart://action=new_ar_invoice") > 0 Then
			StandardProcessing = False;
			OpenForm("Document.HoaDonGTGTDauRa.ObjectForm");
		ElsIf StrFind(Href, "vsmart://action=new_payment_order") > 0 Then
			StandardProcessing = False;
			OpenForm("Document.UyNhiemChi.ObjectForm");
		EndIf;
	EndIf;
EndProcedure

#EndRegion

#Region Private

&AtServer
Procedure CapNhatDuLieuDashboard()
	TemplateObj = GetCommonTemplate("MauHTMLTrangChu");
	HTMLTemplate = TemplateObj.GetText();
	
	ChuoiJSON = BangDieuKhienServer.LayDuLieuTongQuan("ThangNay");
	
	ScriptInjection = "<script>document.addEventListener('DOMContentLoaded', function() { if (typeof updateDashboardData === 'function') { updateDashboardData(" + ChuoiJSON + "); } });</script>";
	NoiDungHTML = StrReplace(HTMLTemplate, "</body>", ScriptInjection + "</body>");
EndProcedure

&AtServer
Procedure CapNhatDuLieuDashboardAtServer()
	CapNhatDuLieuDashboard();
EndProcedure

#EndRegion
