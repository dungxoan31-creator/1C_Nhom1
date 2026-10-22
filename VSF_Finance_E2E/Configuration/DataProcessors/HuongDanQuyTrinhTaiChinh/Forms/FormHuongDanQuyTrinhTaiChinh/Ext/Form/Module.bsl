#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	TemplateObject = GetCommonTemplate("MauHTMLHuongDanQuyTrinhTaiChinh");
	NoiDungHTML = BangDieuKhienServer.ChuyenHTMLSangASCII(TemplateObject.GetText());
EndProcedure

&AtClient
Procedure TruongHTMLHuongDanOnClick(Item, EventData, StandardProcessing)
	If EventData = Undefined Then Return; EndIf;
	Href = ?(EventData.Href <> Undefined, EventData.Href, ?(EventData.Anchor <> Undefined, EventData.Anchor, ""));
	If StrFind(Href, "route=") = 0 Then Return; EndIf;
	StandardProcessing = False;

	If Href = "route=AR" Then
		OpenForm("Document.BienBanNghiemThuGiaiDoan.ObjectForm");
	ElsIf Href = "route=ARInvoice" Then
		OpenForm("Document.HoaDonGTGTDauRa.ObjectForm");
	ElsIf Href = "route=ARReceipt" Then
		OpenForm("Document.PhieuThuTienKhachHang.ObjectForm");
	ElsIf Href = "route=AP" Then
		OpenForm("Document.HoaDonNhaCungCap.ObjectForm");
	ElsIf Href = "route=APPayment" Then
		OpenForm("Document.UyNhiemChi.ObjectForm");
	ElsIf Href = "route=CanTru" Then
		OpenForm("Document.CanTruCongNoNoiBo.ObjectForm");
	ElsIf Href = "route=DoiSoatCSV" Then
		OpenForm("Document.DoiSoatKenhThanhToan.ObjectForm");
	ElsIf Href = "route=TaiKhoanVaChuyenDongSo" Or Href = "route=ReportAR" Then
		OpenForm("Report.SoChiTietCongNoAR.Form.ReportForm");
	ElsIf Href = "route=ReportAP" Then
		OpenForm("Report.SoChiTietCongNoAP.Form.ReportForm");
	ElsIf Href = "route=ReportAging" Then
		OpenForm("Report.BaoCaoTuoiNo.Form.ReportForm");
	Else
		ShowUserNotification("Liên kết hướng dẫn", , "Đường dẫn này không thuộc danh sách chức năng tài chính được phép mở.", PictureLib.Information);
	EndIf;
EndProcedure

#EndRegion
