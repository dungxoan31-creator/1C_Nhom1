Procedure BeforeStart(Cancel)
	ClientApplication.SetCaption(NStr("vi = 'VINSMART FUTURE - Hệ Thống Tài Chính & Kế Toán (VSF)'; en = 'VINSMART FUTURE - Finance & Accounting System (VSF)'"));
EndProcedure

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
	ElsIf LaunchParameter = "SeedMasterData" Then
		GeneratorMasterDataServer.KhoiTaoMasterDataToanDien();
		Exit(False);
	ElsIf LaunchParameter = "VerifyMasterData" Then
		GeneratorMasterDataServer.KiemTraMasterData();
		Exit(False);
	EndIf;
EndProcedure
