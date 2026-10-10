Procedure OnStart()
	If LaunchParameter = "SeedFullTestData" Then
		SeedFullTestDataServer.ThucThiNapFullTestData();
		Exit(False);
	ElsIf LaunchParameter = "VerifyFullTestData" Then
		SeedFullTestDataServer.KiemTraDuLieuDaNap();
		Exit(False);
	ElsIf LaunchParameter = "SeedCleanMasterData" Then
		SeedDataCleanServer.ThucThiNapMasterData();
		Exit(False);
	EndIf;
EndProcedure
