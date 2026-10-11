// Report: CanhBaoHanMucVaGiaHanCloud
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Canh bao han muc va thoi han goi Cloud theo 3 cap Vang, Cam, Do (Task 6.3)

#Region PublicInterface

Function XacDinhMucCanhBaoThoiHan(Val SoNgayConLai) Export
	If SoNgayConLai <= 7 Then
		Return "Do";
	ElsIf SoNgayConLai <= 14 Then
		Return "Cam";
	ElsIf SoNgayConLai <= 30 Then
		Return "Vang";
	Else
		Return "BinhThuong";
	EndIf;
EndFunction

Function XacDinhMucCanhBaoQuota(Val PhanTramSuDung) Export
	If PhanTramSuDung >= 98 Then
		Return "Do";
	ElsIf PhanTramSuDung >= 90 Then
		Return "Cam";
	ElsIf PhanTramSuDung >= 80 Then
		Return "Vang";
	Else
		Return "BinhThuong";
	EndIf;
EndFunction

#Region EventHandlers

Procedure OnComposeResult(ResultDocument, DetailsData, StandardProcessing)
	StandardProcessing = False;
	ResultDocument.Clear();
	
	Line = ResultDocument.TableHeight + 1;
	Area = ResultDocument.Area(Line, 1, Line, 6);
	Area.Merge();
	Area.Text = NStr("vi = 'BÁO CÁO CẢNH BÁO HẠN MỨC VÀ GIA HẠN DỊCH VỤ CLOUD'; en = 'CLOUD QUOTA AND RENEWAL ALERT REPORT'");
	Area.Font = New Font(, 12, True);
EndProcedure

#EndRegion

#EndRegion
