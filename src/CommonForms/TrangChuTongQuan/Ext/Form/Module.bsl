// Form Module: TrangChuTongQuan

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	CapNhatDuLieuDashboard();
EndProcedure

&AtServer
Procedure CapNhatDuLieuDashboard()
	TemplateObj = GetCommonTemplate("MauHTMLTrangChu");
	HTMLTemplate = TemplateObj.GetText();
	
	ChuoiJSON = BangDieuKhienServer.LayDuLieuTongQuan("ThangNay");
	
	// Tiêm dữ liệu JSON trực tiếp vào HTML template
	ScriptInjection = "<script>document.addEventListener('DOMContentLoaded', function() { updateDashboardData(" + ChuoiJSON + "); });</script>";
	NoiDungHTML = StrReplace(HTMLTemplate, "</body>", ScriptInjection + "</body>");
EndProcedure

&AtClient
Procedure TruongHTMLDashboardOnClick(Item, EventData, StandardProcessing)
	If EventData <> Undefined And EventData.Href <> Undefined Then
		Href = EventData.Href;
		If StrFind(Href, "vsmart://action=refresh") > 0 Then
			StandardProcessing = False;
			CapNhatDuLieuDashboardAtServer();
		EndIf;
	EndIf;
EndProcedure

&AtServer
Procedure CapNhatDuLieuDashboardAtServer()
	CapNhatDuLieuDashboard();
EndProcedure
