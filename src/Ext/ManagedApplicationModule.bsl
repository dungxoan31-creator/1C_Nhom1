Procedure OnStart()
	If LaunchParameter = "SeedCleanMasterData" Then
		SeedDataCleanServer.ThucThiNapMasterData();
		Exit(False);
	ElsIf LaunchParameter = "RunUnitTests" Then
		CatalogsCoreTest.RunVerification();
		EnumsConstantsTest.RunVerification();
		Exit(False);
	ElsIf LaunchParameter = "RunEnumsConstantsTests" Then
		EnumsConstantsTest.RunVerification();
		Exit(False);
	EndIf;
EndProcedure
