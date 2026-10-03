Procedure BeforeStart(Cancel)
	TextW = New TextWriter("C:/Users/Dung/Documents/1C_Enterprise/start_breadcrumb.txt", TextEncoding.UTF8);
	TextW.WriteLine("BeforeStart entered, LaunchParam: " + LaunchParameter);
	TextW.Close();

	If LaunchParameter = "RunDoD" Then
		RunVerification();
		Cancel = True;
	EndIf;
EndProcedure

Procedure OnStart()
	TextW = New TextWriter("C:/Users/Dung/Documents/1C_Enterprise/start_breadcrumb.txt", TextEncoding.UTF8);
	TextW.WriteLine("OnStart entered, LaunchParam: " + LaunchParameter);
	TextW.Close();

	If LaunchParameter = "RunDoD" Then
		RunVerification();
		Exit(False);
	EndIf;
EndProcedure
