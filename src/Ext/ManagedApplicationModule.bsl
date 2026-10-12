Procedure BeforeStart(Cancel)
	ClientApplication.SetCaption(NStr("vi = 'VINSMART FUTURE - Hệ Thống Tài Chính & Kế Toán (VSF)'; en = 'VINSMART FUTURE - Finance & Accounting System (VSF)'"));
EndProcedure

Procedure OnStart()
	Try
		WriteLogEvent("App.OnStart", EventLogLevel.Information,,, "LaunchParameter: " + LaunchParameter);
	Except
	EndTry;
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
	ElsIf LaunchParameter = "SetupSampleUsers" Then
		UserProvisioningServer.KhoiTaoDanhSachNguoiDung();
		Exit(False);
	ElsIf LaunchParameter = "VerifySampleUsers" Then
		UserProvisioningServer.KiemTraNguoiDungDaKhoiTao();
		Exit(False);
	ElsIf LaunchParameter = "RunSecurityTests" Then
		PhanQuyenBaoMatServer.ThucThiKiemThuBaoMatToanDien();
		Exit(False);
	ElsIf LaunchParameter = "TestUserLogin" Then
		Try
			WriteLogEvent("UserLogin.Success", EventLogLevel.Information,,, "Dang nhap thanh cong: " + UserName());
		Except
		EndTry;
		Exit(False);
	ElsIf LaunchParameter = "ExportExecutiveReports" Then
		Try
			BaoCaoQuanTriServer.XuatDuLieuVaKiemTraBaoCao();
		Except
			WriteLogEvent("ExecutiveReports.Error", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf LaunchParameter = "TestDashboardCFO" Then
		Try
			SeedFullTestDataServer.KiemTraDashboardCFO();
		Except
			WriteLogEvent("DashboardCFO.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	EndIf;
EndProcedure
