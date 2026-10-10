Procedure OnStart()
	If LaunchParameter = "RunUnitTests" Then
		CatalogsCoreTest.RunVerification();
		EnumsConstantsTest.RunVerification();
		Exit(False);
	ElsIf LaunchParameter = "RunEnumsConstantsTests" Then
		EnumsConstantsTest.RunVerification();
		Exit(False);
	EndIf;
EndProcedure
