Procedure BeforeWrite(Cancel, Replacement)
	For Each Record In ThisObject Do
		If Record.TrangThaiKhoa Then
			If ValueIsFilled(Record.DoiTac) And Record.DoiTac.LaBenLienKet Then
				Cancel = True;
				Raise "OPERATIONAL SAFETY GATE VIOLATION: Nghiem cam khoa dich vu doi voi Doi tac thuoc he sinh thai noi bo tap doan / ben lien quan (" + String(Record.DoiTac) + ")!";
			EndIf;
		EndIf;
	EndDo;
EndProcedure
