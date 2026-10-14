Procedure BeforeStart(Cancel)
	ClientApplication.SetCaption(NStr("vi = 'VINSMART FUTURE - Hệ Thống Tài Chính & Kế Toán (VSF)'; en = 'VINSMART FUTURE - Finance & Accounting System (VSF)'"));
EndProcedure

Procedure OnStart()
	Try
		QuanLyVongDoiChungTuServer.GhiNhatKyInfo("App.OnStart", "LaunchParameter: " + LaunchParameter);
	Except
	EndTry;
	
	ParamParts = StrSplit(LaunchParameter, ";");
	Cmd = ?(ParamParts.Count() > 0, TrimAll(ParamParts[0]), LaunchParameter);
	If Cmd = "RunSeedBoundaries" Then
		If ParamParts.Count() <> 3 Then Raise "Boundaries require command;run_id;result_path"; EndIf;
		SeedBoundaryTestsServer.RunBoundaries(ParamParts[1], ParamParts[2]);
		Exit(False);
		Return;
	EndIf;
	If Cmd = "RunSeedWorkflow" Then
		If ParamParts.Count() <> 5 Then Raise "Seed requires command;run_id;result_path;phase;manifest_path"; EndIf;
		SeedWorkflowServer.RunPhase(ParamParts[1], ParamParts[2], ParamParts[3], ParamParts[4]);
		Exit(False);
		Return;
	EndIf;
	If Cmd = "RunNettingReversal" Then
		If ParamParts.Count() <> 5 Then Raise "Characterization requires command;run_id;result_path;phase;fixture_path"; EndIf;
		HardeningTestsServer.KiemTraMoiTruongUAT();
		NettingReversalTestsServer.RunNettingReversalCharacterization(ParamParts[1], ParamParts[2], ParamParts[3], ParamParts[4]);
		Exit(False);
		Return;
	EndIf;
	If Cmd = "RunConcurrentPosting" Then
		If ParamParts.Count() <> 5 Then
			Raise "Concurrent tests require command;run_id;result_path;worker_id;fixture_path";
		EndIf;
		HardeningTestsServer.KiemTraMoiTruongUAT();
		ConcurrencyTestsServer.RunConcurrentPosting(ParamParts[1], ParamParts[2], ParamParts[3], ParamParts[4]);
		Exit(False);
		Return;
	EndIf;
	If Cmd = "RunSeedSafetyTests" Or Cmd = "RunSeedTransactionTests"
		Or Cmd = "RunHardeningUAT" Or Cmd = "RunUnitTests" Or Cmd = "RunSecurityTests"
		Or Cmd = "RunPostingLifecycleTests" Or Cmd = "RunRBACChecks"
		Or Cmd = "VerifyGLAnalyticKeys" Or Cmd = "VerifyContractFees" Or Cmd = "ExportTrialBalanceEvidence" Then
		If ParamParts.Count() <> 3 Then
			Raise "Tests require command;run_id;result_path";
		EndIf;
		If Cmd = "RunSeedSafetyTests" Then
			Cases = HardeningTestsServer.KiemThuAnToanSeed();
		ElsIf Cmd = "RunSeedTransactionTests" Then
			Cases = HardeningTestsServer.KiemThuGiaoDichSeed();
		ElsIf Cmd = "RunHardeningUAT" Then
			Cases = HardeningTestsServer.KiemThuHardening();
		ElsIf Cmd = "RunPostingLifecycleTests" Then
			HardeningTestsServer.KiemTraMoiTruongUAT();
			Cases = QuanLyVongDoiChungTuServer.KiemThuChuTrinhGhiSoRuntime();
		ElsIf Cmd = "RunRBACChecks" Then
			Cases = HardeningTestsServer.KiemThuQuyenNguoiDung();
		ElsIf Cmd = "VerifyGLAnalyticKeys" Or Cmd = "VerifyContractFees" Or Cmd = "ExportTrialBalanceEvidence" Then
			Cases = HardeningTestsServer.KiemTraBangChungDocLap(Cmd, ParamParts[2]);
		Else
			Cases = HardeningTestsServer.KiemThuDonVi();
			If Cmd = "RunSecurityTests" Then
				Cases.Delete(1);
			EndIf;
		EndIf;
		GhiKetQuaRuntime(ParamParts[1], ParamParts[2], Cases);
		Exit(False);
		Return;
	EndIf;
	
	If Cmd = "SeedFullTestData" Or LaunchParameter = "SeedFullTestData" Then
		Try
			SeedFullTestDataServer.ThucThiNapFullTestData();
		Except
			QuanLyVongDoiChungTuServer.GhiNhatKyError("SeedData.Fatal", DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "VerifyFullTestData" Then
		Try
			SeedFullTestDataServer.KiemTraDuLieuDaNap();
		Except
			QuanLyVongDoiChungTuServer.GhiNhatKyError("VerifyData.Fatal", DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "SeedCleanMasterData" Then
		Try
			SeedDataCleanServer.ThucThiNapMasterData();
		Except
			QuanLyVongDoiChungTuServer.GhiNhatKyError("MasterData.Fatal", DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "SeedMasterData" Then
		Try
			GeneratorMasterDataServer.KhoiTaoMasterDataToanDien();
		Except
			QuanLyVongDoiChungTuServer.GhiNhatKyError("MasterData.Fatal", DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "VerifyMasterData" Then
		Try
			GeneratorMasterDataServer.KiemTraMasterData();
		Except
			QuanLyVongDoiChungTuServer.GhiNhatKyError("MasterData.Fatal", DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "SeedARData" Then
		Try
			GeneratorARServer.KhoiTaoChungTuAR();
		Except
			QuanLyVongDoiChungTuServer.GhiNhatKyError("AR.Fatal", DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "VerifyARData" Then
		Try
			GeneratorARServer.KiemTraChungTuAR();
		Except
			QuanLyVongDoiChungTuServer.GhiNhatKyError("AR.Fatal", DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "SeedAPData" Then
		Try
			GeneratorAPServer.KhoiTaoChungTuAP();
		Except
			QuanLyVongDoiChungTuServer.GhiNhatKyError("AP.Fatal", DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "VerifyAPData" Then
		Try
			GeneratorAPServer.KiemTraChungTuAP();
		Except
			QuanLyVongDoiChungTuServer.GhiNhatKyError("AP.Fatal", DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "SeedNettingData" Then
		Try
			GeneratorNettingReconcileServer.KhoiTaoChungTuNetting();
		Except
			QuanLyVongDoiChungTuServer.GhiNhatKyError("Netting.Fatal", DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "VerifyNettingData" Then
		Try
			GeneratorNettingReconcileServer.KiemTraChungTuNetting();
		Except
			QuanLyVongDoiChungTuServer.GhiNhatKyError("Netting.Fatal", DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "SetupSampleUsers" Then
		Try
			UserProvisioningServer.KhoiTaoDanhSachNguoiDung();
		Except
			QuanLyVongDoiChungTuServer.GhiNhatKyError("UserProv.Fatal", DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "VerifySampleUsers" Then
		Try
			UserProvisioningServer.KiemTraNguoiDungDaKhoiTao();
		Except
			QuanLyVongDoiChungTuServer.GhiNhatKyError("UserProv.Fatal", DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "RunTask2SecurityTests" Then
		Try
			PhanQuyenBaoMatServer.ThucThiKiemThuTask2Runtime();
		Except
			QuanLyVongDoiChungTuServer.GhiNhatKyError("Task2Test.Fatal", DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "RunTask2MakerTests" Then
		Try
			PhanQuyenBaoMatServer.KiemTraMakerSessionRuntime();
		Except
			QuanLyVongDoiChungTuServer.GhiNhatKyError("Task2Test.Fatal", DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "RunTask2CheckerTests" Then
		Try
			PhanQuyenBaoMatServer.KiemTraCheckerSessionRuntime();
		Except
			QuanLyVongDoiChungTuServer.GhiNhatKyError("Task2Test.Fatal", DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "RunTask2AdminTests" Then
		Try
			PhanQuyenBaoMatServer.KiemTraAdminSessionRuntime();
		Except
			QuanLyVongDoiChungTuServer.GhiNhatKyError("Task2Test.Fatal", DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "RunTask3USDTests" Then
		Try
			QuanLyTyGiaVaNgoaiTeServer.ThucThiKiemThuTask3USDRuntime();
		Except
			QuanLyVongDoiChungTuServer.GhiNhatKyError("Task3Test.Fatal", DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "RunTask4FXTests" Then
		Try
			QuanLyTyGiaVaNgoaiTeServer.ThucThiKiemThuTask4FXRuntime();
		Except
			QuanLyVongDoiChungTuServer.GhiNhatKyError("Task4Test.Fatal", DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "RunTask5NettingTests" Then
		Try
			QuanLyTyGiaVaNgoaiTeServer.ThucThiKiemThuTask5NettingRuntime();
		Except
			QuanLyVongDoiChungTuServer.GhiNhatKyError("Task5Test.Fatal", DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "RunTask6IntegrityTests" Then
		Try
			QuanLyVongDoiChungTuServer.ThucThiKiemThuTask6IntegrityRuntime();
		Except
			QuanLyVongDoiChungTuServer.GhiNhatKyError("Task6Test.Fatal", DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "TestUserLogin" Then
		Try
			QuanLyVongDoiChungTuServer.GhiNhatKyInfo("UserLogin.Success", "Dang nhap thanh cong: " + UserName());
		Except
		EndTry;
		Exit(False);
	ElsIf Cmd = "ExportExecutiveReports" Then
		Try
			BaoCaoQuanTriServer.XuatDuLieuVaKiemTraBaoCao();
		Except
			QuanLyVongDoiChungTuServer.GhiNhatKyError("ExecutiveReports.Error", DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "TestDashboardCFO" Then
		Try
			SeedFullTestDataServer.KiemTraDashboardCFO();
		Except
			QuanLyVongDoiChungTuServer.GhiNhatKyError("DashboardCFO.Fatal", DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "BackfillGLAnalyticKeys" Then
		Try
			SeedFullTestDataServer.BackfillSoCaiAnalyticKeysServer();
		Except
			QuanLyVongDoiChungTuServer.GhiNhatKyError("GLBackfill.Fatal", DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "VerifyGLAnalyticKeys" Then
		Try
			SeedFullTestDataServer.KiemTraGLAnalyticKeysServer();
		Except
			QuanLyVongDoiChungTuServer.GhiNhatKyError("GLVerify.Fatal", DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "RunPostingLifecycleTests" Then
		Try
			QuanLyVongDoiChungTuServer.KiemThuChuTrinhGhiSoRuntime();
		Except
			QuanLyVongDoiChungTuServer.GhiNhatKyError("PostingLifecycle.Fatal", DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "ExportTrialBalanceEvidence" Then
		Try
			BaoCaoQuanTriServer.XuatOperationalTrialBalanceEvidenceServer();
		Except
			QuanLyVongDoiChungTuServer.GhiNhatKyError("OperationalEvidence.Fatal", DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "UpdateContractFees" Then
		Try
			GeneratorNettingReconcileServer.CapNhatBieuPhiHopDongRuntime();
		Except
			QuanLyVongDoiChungTuServer.GhiNhatKyError("ContractFees.Fatal", DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "VerifyContractFees" Then
		Try
			GeneratorNettingReconcileServer.KiemTraHopDongPhiVaKenhThanhToan();
		Except
			QuanLyVongDoiChungTuServer.GhiNhatKyError("ContractFees.Fatal", DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "RunUATSecurityProof" Then
		Try
			QuanLyVongDoiChungTuServer.KiemThuUATRollbackConcurrencyServer();
		Except
			QuanLyVongDoiChungTuServer.GhiNhatKyError("UATSecurity.Fatal", DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "TestAccounts" Then
		Try
			SeedFullTestDataServer.KiemTraDanhSachTaiKhoan();
		Except
			QuanLyVongDoiChungTuServer.GhiNhatKyError("Account.Fatal", DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	EndIf;
EndProcedure

Procedure GhiKetQuaRuntime(RunID, OutputPath, Cases)
	AllPassed = Cases.Count() > 0;
	For Each CaseResult In Cases Do
		AllPassed = AllPassed And CaseResult.passed;
	EndDo;
	Result = New Structure("run_id,status,cases", RunID, ?(AllPassed, "PASS", "FAIL"), Cases);
	Writer = New JSONWriter;
	Writer.OpenFile(OutputPath);
	WriteJSON(Writer, Result);
	Writer.Close();
EndProcedure
