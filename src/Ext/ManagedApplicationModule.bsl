Procedure BeforeStart(Cancel)
	ClientApplication.SetCaption(NStr("vi = 'VINSMART FUTURE - Hệ Thống Tài Chính & Kế Toán (VSF)'; en = 'VINSMART FUTURE - Finance & Accounting System (VSF)'"));
EndProcedure

Procedure OnStart()
	Try
		WriteLogEvent("App.OnStart", EventLogLevel.Information,,, "LaunchParameter: " + LaunchParameter);
	Except
	EndTry;
	If LaunchParameter = "SeedFullTestData" Then
		Try
			SeedFullTestDataServer.ThucThiNapFullTestData();
		Except
			WriteLogEvent("SeedData.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf LaunchParameter = "VerifyFullTestData" Then
		Try
			SeedFullTestDataServer.KiemTraDuLieuDaNap();
		Except
			WriteLogEvent("VerifyData.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf LaunchParameter = "SeedCleanMasterData" Then
		Try
			SeedDataCleanServer.ThucThiNapMasterData();
		Except
			WriteLogEvent("MasterData.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf LaunchParameter = "SeedMasterData" Then
		Try
			GeneratorMasterDataServer.KhoiTaoMasterDataToanDien();
		Except
			WriteLogEvent("MasterData.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf LaunchParameter = "VerifyMasterData" Then
		Try
			GeneratorMasterDataServer.KiemTraMasterData();
		Except
			WriteLogEvent("MasterData.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf LaunchParameter = "SeedARData" Then
		Try
			GeneratorARServer.KhoiTaoChungTuAR();
		Except
			WriteLogEvent("AR.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf LaunchParameter = "VerifyARData" Then
		Try
			GeneratorARServer.KiemTraChungTuAR();
		Except
			WriteLogEvent("AR.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf LaunchParameter = "SeedAPData" Then
		Try
			GeneratorAPServer.KhoiTaoChungTuAP();
		Except
			WriteLogEvent("AP.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf LaunchParameter = "VerifyAPData" Then
		Try
			GeneratorAPServer.KiemTraChungTuAP();
		Except
			WriteLogEvent("AP.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf LaunchParameter = "SeedNettingData" Then
		Try
			GeneratorNettingReconcileServer.KhoiTaoChungTuNetting();
		Except
			WriteLogEvent("Netting.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf LaunchParameter = "VerifyNettingData" Then
		Try
			GeneratorNettingReconcileServer.KiemTraChungTuNetting();
		Except
			WriteLogEvent("Netting.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf LaunchParameter = "SetupSampleUsers" Then
		Try
			UserProvisioningServer.KhoiTaoDanhSachNguoiDung();
		Except
			WriteLogEvent("UserProv.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf LaunchParameter = "VerifySampleUsers" Then
		Try
			UserProvisioningServer.KiemTraNguoiDungDaKhoiTao();
		Except
			WriteLogEvent("UserProv.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf LaunchParameter = "RunSecurityTests" Then
		Try
			PhanQuyenBaoMatServer.ThucThiKiemThuBaoMatToanDien();
		Except
			WriteLogEvent("Security.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
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
	ElsIf LaunchParameter = "TestAccounts" Then
		Try
			Q = New Query("SELECT Code, Description, PredefinedDataName FROM ChartOfAccounts.HeThongTaiKhoan");
			T = Q.Execute().Unload();
			For Each R In T Do
				WriteLogEvent("Account.List", EventLogLevel.Information,,, "Acc: " + R.Code + " - " + R.Description + " (Predef: " + R.PredefinedDataName + ")");
			EndDo;
		Except
			WriteLogEvent("Account.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	EndIf;
EndProcedure
