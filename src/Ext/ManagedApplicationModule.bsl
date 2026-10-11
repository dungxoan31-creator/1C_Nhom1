Procedure BeforeStart(Cancel)
	ClientApplication.SetCaption(NStr("vi = 'VINSMART FUTURE - Hệ Thống Tài Chính & Kế Toán (VSF)'; en = 'VINSMART FUTURE - Finance & Accounting System (VSF)'"));
EndProcedure

Procedure OnStart()
	WriteLogEvent("App.OnStart", EventLogLevel.Information,,, "LaunchParameter: " + LaunchParameter);
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
	ElsIf LaunchParameter = "SeedARData" Then
		GeneratorARServer.KhoiTaoChungTuAR();
		Exit(False);
	ElsIf LaunchParameter = "VerifyARData" Then
		GeneratorARServer.KiemTraChungTuAR();
		Exit(False);
	ElsIf LaunchParameter = "SeedAPData" Then
		GeneratorAPServer.KhoiTaoChungTuAP();
		Exit(False);
	ElsIf LaunchParameter = "VerifyAPData" Then
		GeneratorAPServer.KiemTraChungTuAP();
		Exit(False);
	ElsIf LaunchParameter = "SeedNettingData" Then
		GeneratorNettingReconcileServer.KhoiTaoChungTuNetting();
		Exit(False);
	ElsIf LaunchParameter = "VerifyNettingData" Then
		GeneratorNettingReconcileServer.KiemTraChungTuNetting();
		Exit(False);
	EndIf;
EndProcedure
