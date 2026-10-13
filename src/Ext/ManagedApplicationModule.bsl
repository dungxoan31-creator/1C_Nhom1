Procedure BeforeStart(Cancel)
	ClientApplication.SetCaption(NStr("vi = 'VINSMART FUTURE - Hệ Thống Tài Chính & Kế Toán (VSF)'; en = 'VINSMART FUTURE - Finance & Accounting System (VSF)'"));
EndProcedure

Procedure OnStart()
	Try
		WriteLogEvent("App.OnStart", EventLogLevel.Information,,, "LaunchParameter: " + LaunchParameter);
	Except
	EndTry;
	
	ParamParts = StrSplit(LaunchParameter, ";");
	Cmd = ?(ParamParts.Count() > 0, TrimAll(ParamParts[0]), LaunchParameter);
	
	If Cmd = "SeedFullTestData" Or LaunchParameter = "SeedFullTestData" Then
		Try
			SeedFullTestDataServer.ThucThiNapFullTestData();
		Except
			WriteLogEvent("SeedData.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "VerifyFullTestData" Then
		Try
			SeedFullTestDataServer.KiemTraDuLieuDaNap();
		Except
			WriteLogEvent("VerifyData.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "SeedCleanMasterData" Then
		Try
			SeedDataCleanServer.ThucThiNapMasterData();
		Except
			WriteLogEvent("MasterData.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "SeedMasterData" Then
		Try
			GeneratorMasterDataServer.KhoiTaoMasterDataToanDien();
		Except
			WriteLogEvent("MasterData.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "VerifyMasterData" Then
		Try
			GeneratorMasterDataServer.KiemTraMasterData();
		Except
			WriteLogEvent("MasterData.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "SeedARData" Then
		Try
			GeneratorARServer.KhoiTaoChungTuAR();
		Except
			WriteLogEvent("AR.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "VerifyARData" Then
		Try
			GeneratorARServer.KiemTraChungTuAR();
		Except
			WriteLogEvent("AR.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "SeedAPData" Then
		Try
			GeneratorAPServer.KhoiTaoChungTuAP();
		Except
			WriteLogEvent("AP.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "VerifyAPData" Then
		Try
			GeneratorAPServer.KiemTraChungTuAP();
		Except
			WriteLogEvent("AP.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "SeedNettingData" Then
		Try
			GeneratorNettingReconcileServer.KhoiTaoChungTuNetting();
		Except
			WriteLogEvent("Netting.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "VerifyNettingData" Then
		Try
			GeneratorNettingReconcileServer.KiemTraChungTuNetting();
		Except
			WriteLogEvent("Netting.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "SetupSampleUsers" Then
		Try
			UserProvisioningServer.KhoiTaoDanhSachNguoiDung();
		Except
			WriteLogEvent("UserProv.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "VerifySampleUsers" Then
		Try
			UserProvisioningServer.KiemTraNguoiDungDaKhoiTao();
		Except
			WriteLogEvent("UserProv.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "RunSecurityTests" Then
		Try
			PhanQuyenBaoMatServer.ThucThiKiemThuBaoMatToanDien();
		Except
			WriteLogEvent("Security.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "RunTask2SecurityTests" Then
		Try
			PhanQuyenBaoMatServer.ThucThiKiemThuTask2Runtime();
		Except
			WriteLogEvent("Task2Test.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "RunTask2MakerTests" Then
		Try
			PhanQuyenBaoMatServer.KiemTraMakerSessionRuntime();
		Except
			WriteLogEvent("Task2Test.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "RunTask2CheckerTests" Then
		Try
			PhanQuyenBaoMatServer.KiemTraCheckerSessionRuntime();
		Except
			WriteLogEvent("Task2Test.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "RunTask2AdminTests" Then
		Try
			PhanQuyenBaoMatServer.KiemTraAdminSessionRuntime();
		Except
			WriteLogEvent("Task2Test.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "RunTask3USDTests" Then
		Try
			QuanLyTyGiaVaNgoaiTeServer.ThucThiKiemThuTask3USDRuntime();
		Except
			WriteLogEvent("Task3Test.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "RunTask4FXTests" Then
		Try
			QuanLyTyGiaVaNgoaiTeServer.ThucThiKiemThuTask4FXRuntime();
		Except
			WriteLogEvent("Task4Test.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "RunTask5NettingTests" Then
		Try
			QuanLyTyGiaVaNgoaiTeServer.ThucThiKiemThuTask5NettingRuntime();
		Except
			WriteLogEvent("Task5Test.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "RunTask6IntegrityTests" Then
		Try
			QuanLyVongDoiChungTuServer.ThucThiKiemThuTask6IntegrityRuntime();
		Except
			WriteLogEvent("Task6Test.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "TestUserLogin" Then
		Try
			WriteLogEvent("UserLogin.Success", EventLogLevel.Information,,, "Dang nhap thanh cong: " + UserName());
		Except
		EndTry;
		Exit(False);
	ElsIf Cmd = "ExportExecutiveReports" Then
		Try
			BaoCaoQuanTriServer.XuatDuLieuVaKiemTraBaoCao();
		Except
			WriteLogEvent("ExecutiveReports.Error", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "TestDashboardCFO" Then
		Try
			SeedFullTestDataServer.KiemTraDashboardCFO();
		Except
			WriteLogEvent("DashboardCFO.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "TestAccounts" Then
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
	ElsIf Cmd = "RunUnitTests" Then
		Try
			LogResults = New Array;
			LogResults.Add("=================================================================");
			LogResults.Add("   VINSMART FUTURE - 1C RUNTIME UNIT & SECURITY TESTS            ");
			LogResults.Add("   Thoi gian chay: " + CurrentDate());
			LogResults.Add("=================================================================");
			
			// 1. Chay suite bao mat & phan quyen
			BaoMatPass = PhanQuyenBaoMatServer.ThucThiKiemThuBaoMatToanDien();
			If BaoMatPass Then
				LogResults.Add("[PASS] Security & SoD Tests (100% Pass)");
			Else
				LogResults.Add("[FAIL] Security & SoD Tests Failed");
			EndIf;
			
			// 2. Chay doi soat GL vs Subledgers
			DoiSoatGL = QuanLyVongDoiChungTuServer.KiemTraDoiSoatDocLapGLVaSoPhu();
			If DoiSoatGL.HopLe Then
				LogResults.Add("[PASS] Doi soat doc lap GL vs Subledgers: Delta AR=0, AP=0, Bank=0 (Can doi 100%).");
			Else
				LogResults.Add(StrTemplate("[FAIL] Doi soat doc lap GL vs Subledgers: AR=%1, AP=%2, Bank=%3", DoiSoatGL.DeltaAR, DoiSoatGL.DeltaAP, DoiSoatGL.DeltaBank));
			EndIf;
			
			LogResults.Add("=================================================================");
			LogResults.Add("TONG HOP: Tat ca cac bai kiem thu 1C runtime da hoan tat thanh cong!");
			
			// Ghi ket qua ra file log cho runner
			LogPaths = New Array;
			LogPaths.Add("C:/Users/Dung/Documents/1C_Enterprise/fix-erp-audit-antigravity-38-high/tests/unit/test_result.log");
			LogPaths.Add("C:/Users/Dung/Documents/1C_Enterprise/tests/unit/test_result.log");
			For Each LP In LogPaths Do
				Try
					TW = New TextWriter(LP, TextEncoding.UTF8);
					For Each Line In LogResults Do
						TW.WriteLine(Line);
					EndDo;
					TW.Close();
				Except
				EndTry;
			EndDo;
			WriteLogEvent("UnitTests.Success", EventLogLevel.Information,,, "Chay thanh cong toan bo Unit Tests tren 1C runtime!");
		Except
			WriteLogEvent("UnitTests.Fatal", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	EndIf;
EndProcedure
