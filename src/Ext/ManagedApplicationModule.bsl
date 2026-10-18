Procedure BeforeStart(Cancel)
	ClientApplication.SetCaption(NStr("vi = 'VINSMART FUTURE - Hệ Thống Tài Chính & Kế Toán (VSF)'; en = 'VINSMART FUTURE - Finance & Accounting System (VSF)'"));
EndProcedure

Procedure OnStart()
	ParamParts = StrSplit(LaunchParameter, ";");
	Cmd = ?(ParamParts.Count() > 0, TrimAll(ParamParts[0]), LaunchParameter);
	
	Try
		QuanLyVongDoiChungTuServer.GhiNhatKyInfo("App.OnStart", "Command: " + Cmd);
	Except
	EndTry;
	
	If IsBlankString(Cmd) Then
		OpenForm("DataProcessor.BanLamViecWebERP.Form.FormBanLamViec");
	ElsIf Cmd = "RunSeedBoundaries" Then
		If ParamParts.Count() <> 3 Then Raise "Boundaries require command;run_id;result_path"; EndIf;
		SeedBoundaryTestsServer.RunBoundaries(ParamParts[1], ParamParts[2]);
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
		Try
			QuanLyVongDoiChungTuServer.GhiNhatKyInfo("UserLogin.Success", "Dang nhap thanh cong: " + UserName());
		Except
		EndTry;
		Exit(False);
	EndIf;
EndProcedure
