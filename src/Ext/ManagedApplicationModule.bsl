Procedure BeforeStart(Cancel)
	If LaunchParameter = "RunDoD" Then
		APVerification.RunVerification();
		Cancel = True;
	EndIf;
EndProcedure

Procedure OnStart()
	If LaunchParameter = "RunDoD" Then
		APVerification.RunVerification();
		Exit(False);
	EndIf;
EndProcedure
