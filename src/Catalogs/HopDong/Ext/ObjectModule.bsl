Procedure BeforeWrite(Cancel)
	// Rang buoc mac dinh Net 30: neu HanThanhToanNgay <= 0 thi tu gan = 30
	If HanThanhToanNgay <= 0 Then
		HanThanhToanNgay = 30;
	EndIf;
EndProcedure
