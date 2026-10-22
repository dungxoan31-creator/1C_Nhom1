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
	ElsIf StrFind(Href, "finance_guide") > 0 Then
		StandardProcessing = False;
		OpenForm("DataProcessor.HuongDanQuyTrinhTaiChinh.Form.FormHuongDanQuyTrinhTaiChinh");
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
		OpenValue = Mid(Href, StrFind(Href, "open=") + 5);
		DelimiterPosition = StrFind(OpenValue, "&number=");
		If DelimiterPosition > 0 Then
			DocType = Left(OpenValue, DelimiterPosition - 1);
			DocNumber = Mid(OpenValue, DelimiterPosition + 8);
			If Not IsBlankString(DocType) And Not IsBlankString(DocNumber) Then
				Try
					DocumentRef = FindDashboardDocumentAtServer(DocType, DocNumber);
					If ValueIsFilled(DocumentRef) Then
						OpenForm("Document." + DocType + ".ObjectForm", New Structure("Key", DocumentRef));
					Else
						ShowUserNotification("Không tìm thấy chứng từ", , "Số chứng từ " + DocNumber + " không còn tồn tại.", PictureLib.Information);
					EndIf;
				Except
					ShowUserNotification("Không thể mở chứng từ", , DetailErrorDescription(ErrorInfo()), PictureLib.Information);
				EndTry;
			EndIf;
		EndIf;
	ElsIf StrFind(Href, "report_aging=") > 0 Then
		StandardProcessing = False;
		Bucket = Mid(Href, StrFind(Href, "report_aging=") + 13);
		Bucket = Left(Bucket, ?(StrFind(Bucket, "&") > 0, StrFind(Bucket, "&") - 1, StrLen(Bucket)));
		If Bucket = "TrongHan" Or Bucket = "QuaHan1Den30" Or Bucket = "QuaHan31Den60"
			Or Bucket = "QuaHan61Den90" Or Bucket = "QuaHanTren90" Or Bucket = "ChuaXacDinhHan" Then
			Try
				ReportParameters = New Structure("NgayChot, LoaiCongNo, NhomTuoiNo", CurrentDate(), "AR", Bucket);
				OpenForm("Report.BaoCaoTuoiNo.Form.ReportForm", ReportParameters);
			Except
				ShowUserNotification("Không thể mở báo cáo tuổi nợ", , DetailErrorDescription(ErrorInfo()), PictureLib.Information);
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
	NoiDungHTML = BangDieuKhienServer.ChuyenHTMLSangASCII(NoiDungHTML);
EndProcedure

&AtServer
Procedure CapNhatDuLieuDashboardAtServer()
	CapNhatDuLieuDashboard();
EndProcedure

&AtServer
Function FindDashboardDocumentAtServer(Val DocType, Val DocNumber)
	AllowedTypes = New Array;
	AllowedTypes.Add("BienBanNghiemThuGiaiDoan");
	AllowedTypes.Add("HoaDonGTGTDauRa");
	AllowedTypes.Add("HoaDonNhaCungCap");
	AllowedTypes.Add("PhieuThuTienKhachHang");
	AllowedTypes.Add("UyNhiemChi");
	AllowedTypes.Add("CanTruCongNoNoiBo");
	AllowedTypes.Add("DoiSoatKenhThanhToan");
	If AllowedTypes.Find(DocType) = Undefined Then
		Return Undefined;
	EndIf;
	Query = New Query;
	Query.Text = "SELECT TOP 1 Doc.Ref AS Ref FROM Document." + DocType + " AS Doc WHERE Doc.Number = &Number";
	Query.SetParameter("Number", DocNumber);
	Selection = Query.Execute().Select();
	If Selection.Next() Then
		Return Selection.Ref;
	EndIf;
	Return Undefined;
EndFunction

#EndRegion
