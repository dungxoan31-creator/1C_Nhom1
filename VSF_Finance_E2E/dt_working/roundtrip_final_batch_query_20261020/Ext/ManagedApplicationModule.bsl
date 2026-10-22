Procedure BeforeStart(Cancel)
	ClientApplication.SetCaption(NStr("vi = 'VINSMART FUTURE - Hệ Thống Tài Chính & Kế Toán (VSF)'; en = 'VINSMART FUTURE - Finance & Accounting System (VSF)'"));
EndProcedure

Procedure OnStart()
	ParamParts = StrSplit(LaunchParameter, ";");
	Cmd = ?(ParamParts.Count() > 0, TrimAll(ParamParts[0]), LaunchParameter);
	
	If IsBlankString(Cmd) Then
		QuanLyVongDoiChungTuServer.GhiNhatKyInfo("App.OnStart", "Interactive UI startup");
		OpenForm("DataProcessor.BanLamViecWebERP.Form.FormBanLamViec");
	ElsIf Cmd = "RunSeedBoundaries" Then
		If ParamParts.Count() <> 3 Then Raise "Boundaries require command;run_id;result_path"; EndIf;
		SeedBoundaryTestsServer.RunBoundaries(ParamParts[1], ParamParts[2]);
		Exit(False);
		Return;
	ElsIf Cmd = "RunPostingStateInvariants" Then
		If ParamParts.Count() <> 3 Then Raise "Posting state invariants require command;run_id;result_path"; EndIf;
		SeedBoundaryTestsServer.RunPostingStateInvariantTests(ParamParts[1], ParamParts[2]);
		Exit(False);
		Return;
	ElsIf Cmd = "RunFinanceE2E" Then
		If ParamParts.Count() <> 4 Then Raise "Finance E2E requires command;phase;run_id;result_path"; EndIf;
		SeedBoundaryTestsServer.RunFinanceE2EPhase(ParamParts[1], ParamParts[2], ParamParts[3]);
		Exit(False);
		Return;
	ElsIf Cmd = "RunAPSeedRegression" Then
		If ParamParts.Count() <> 3 Then Raise "AP seed regression requires command;run_id;result_path"; EndIf;
		SeedBoundaryTestsServer.RunAPSeedRegression(ParamParts[1], ParamParts[2]);
		Exit(False);
		Return;
	ElsIf Cmd = "RunAPSeedMasterData" Then
		If ParamParts.Count() <> 3 Then Raise "AP seed master data requires command;run_id;result_path"; EndIf;
		SeedBoundaryTestsServer.RunAPSeedMasterData(ParamParts[1], ParamParts[2]);
		Exit(False);
		Return;
	ElsIf Cmd = "RunAPSeedStage" Then
		If ParamParts.Count() <> 4 Then Raise "AP seed stage requires command;stage;run_id;result_path"; EndIf;
		SeedBoundaryTestsServer.RunAPSeedStage(ParamParts[1], ParamParts[2], ParamParts[3]);
		Exit(False);
		Return;
	ElsIf Cmd = "RunARSeedRegression" Then
		If ParamParts.Count() <> 3 Then Raise "AR seed regression requires command;run_id;result_path"; EndIf;
		SeedBoundaryTestsServer.RunARSeedRegression(ParamParts[1], ParamParts[2]);
		Exit(False);
		Return;
	ElsIf Cmd = "RunARSeedMasterData" Then
		If ParamParts.Count() <> 3 Then Raise "AR seed master data requires command;run_id;result_path"; EndIf;
		SeedBoundaryTestsServer.RunARSeedMasterData(ParamParts[1], ParamParts[2]);
		Exit(False);
		Return;
	ElsIf Cmd = "RunARSeedStage" Then
		If ParamParts.Count() <> 4 Then Raise "AR seed stage requires command;stage;run_id;result_path"; EndIf;
		SeedBoundaryTestsServer.RunARSeedStage(ParamParts[1], ParamParts[2], ParamParts[3]);
		Exit(False);
		Return;
	ElsIf Cmd = "RunPostingLifecycle" Then
		If ParamParts.Count() <> 3 Then Raise "Posting lifecycle regression requires command;run_id;result_path"; EndIf;
		SeedBoundaryTestsServer.RunPostingLifecycleRegression(ParamParts[1], ParamParts[2]);
		Exit(False);
		Return;
	ElsIf Cmd = "RunGLSubledgerIntegrity" Then
		If ParamParts.Count() <> 3 Then Raise "GL/subledger integrity regression requires command;run_id;result_path"; EndIf;
		SeedBoundaryTestsServer.RunGLSubledgerIntegrityRegression(ParamParts[1], ParamParts[2]);
		Exit(False);
		Return;
	ElsIf Cmd = "RunAPInvoiceLifecycle" Then
		If ParamParts.Count() <> 3 Then Raise "AP invoice lifecycle regression requires command;run_id;result_path"; EndIf;
		SeedBoundaryTestsServer.RunAPInvoicePostingLifecycleRegression(ParamParts[1], ParamParts[2]);
		Exit(False);
		Return;
	ElsIf Cmd = "RunSecurityRoleMatrix" Then
		If ParamParts.Count() <> 3 Then Raise "Security role matrix requires command;run_id;result_path"; EndIf;
		PhanQuyenBaoMatServer.ThucThiKiemThuBaoMatToanDien(ParamParts[1], ParamParts[2]);
		Exit(False);
		Return;
	ElsIf Cmd = "RunARBalanceLockHolder" Then
		If ParamParts.Count() <> 5 Then Raise "AR lock holder requires command;source_invoice;ready_path;release_path;result_path"; EndIf;
		SeedBoundaryTestsServer.RunARBalanceLockHolder(ParamParts[1], ParamParts[2], ParamParts[3], ParamParts[4]);
		Exit(False);
		Return;
	ElsIf Cmd = "PostConcurrentARReceipt" Then
		If ParamParts.Count() <> 5 Then Raise "Concurrent AR receipt requires command;receipt_number;attempt_path;result_path;expected_outcome"; EndIf;
		SeedBoundaryTestsServer.PostConcurrentARReceipt(ParamParts[1], ParamParts[2], ParamParts[3], ParamParts[4]);
		Exit(False);
		Return;
	ElsIf Cmd = "RunARLockConcurrencyBackground" Then
		If ParamParts.Count() <> 11 Then Raise "Background concurrency test requires command and 10 parameters."; EndIf;
		SeedBoundaryTestsServer.RunARLockConcurrencyInBackground(ParamParts[1], ParamParts[2], ParamParts[3], ParamParts[4], ParamParts[5], ParamParts[6], ParamParts[7], ParamParts[8], ParamParts[9], ParamParts[10]);
		Exit(False);
		Return;
	ElsIf Cmd = "ImportCOATT200" Then
		Try
			GeneratorMasterDataServer.KhoiTaoHeThongTaiKhoanTT200();
		Except
			QuanLyVongDoiChungTuServer.GhiNhatKyError("COA.Fatal", DetailErrorDescription(ErrorInfo()));
		EndTry;
		Exit(False);
	ElsIf Cmd = "ReportCOAStats" Then
		If ParamParts.Count() >= 2 Then
			Try
				GeneratorMasterDataServer.BaoCaoThongKeTaiKhoan(ParamParts[1]);
			Except
				QuanLyVongDoiChungTuServer.GhiNhatKyError("COA.ReportError", DetailErrorDescription(ErrorInfo()));
			EndTry;
		EndIf;
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
			ARSeedStage = ?(ParamParts.Count() > 1, ParamParts[1], "PrepareAcceptances");
			GeneratorARServer.KhoiTaoChungTuAR(ARSeedStage);
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
			APSeedStage = ?(ParamParts.Count() > 1, ParamParts[1], "PrepareInvoices");
			GeneratorAPServer.KhoiTaoChungTuAP(False, APSeedStage);
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
	ElsIf Cmd = "SetupSampleUsers" Then
		Try
			UserProvisioningServer.KhoiTaoDanhSachNguoiDung(?(ParamParts.Count() > 1, ParamParts[1], ""));
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
	ElsIf Cmd = "TestUserLogin" Then
		QuanLyVongDoiChungTuServer.GhiNhatKyInfo("UserLogin.Success", "Dang nhap thanh cong: " + UserName());
		Exit(False);
	EndIf;
EndProcedure
