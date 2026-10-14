// Common Module: UserProvisioningServer
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Khoi tao va quan ly danh sach nguoi dung mau theo ma tran 8 Roles (Huong 2).

#Region PublicInterface

// Khoi tao toan bo 8 nguoi dung nghiep vu + Admin quan tri he thong
Procedure KhoiTaoDanhSachNguoiDung() Export
	DanhSachNguoiDung = DanhSachNguoiDungChuan();
	
	LogLines = New Array;
	LogLines.Add("=== BAT DAU KHOI TAO NGUOI DUNG VA MA TRAN PHAN QUYEN VSF ===");
	
	TongSo = 0;
	DaTaoMoi = 0;
	DaCapNhat = 0;
	
	For Each Item In DanhSachNguoiDung Do
		TongSo = TongSo + 1;
		
		User = InfoBaseUsers.FindByName(Item.Name);
		LaTaoMoi = (User = Undefined);
		If LaTaoMoi Then
			User = InfoBaseUsers.CreateUser();
			DaTaoMoi = DaTaoMoi + 1;
		Else
			DaCapNhat = DaCapNhat + 1;
		EndIf;
		
		User.Name = Item.Name;
		User.FullName = Item.FullName;
		User.Roles.Clear();
		RoleMD = Metadata.Roles.Find(Item.RoleName);
		If RoleMD <> Undefined Then
			User.Roles.Add(RoleMD);
		Else
			Raise "Khong tim thay Role trong Metadata: " + Item.RoleName;
		EndIf;
		
		PassDuocDat = Item.Password;
		Try
			User.Password = Item.Password;
			User.Write();
		Except
			// Fallback danh cho ban dao tao 1C Training Edition (License constraint: chi cho phep empty password)
			User.Password = "";
			User.Write();
			PassDuocDat = "<trong (Training Edition)>";
		EndTry;
		
		MsgLog = StrTemplate("[%1] %2: %3 | Role: %4 | Pass: %5", 
			?(LaTaoMoi, "TAO MOI", "CAP NHAT"), Item.Name, Item.FullName, Item.RoleName, PassDuocDat);
		LogLines.Add(MsgLog);
		WriteLogEvent("UserProvisioning.Success", EventLogLevel.Information,,, MsgLog);
	EndDo;
	
	LogLines.Add(StrTemplate("=== HOAN TAT KHOI TAO: Tong: %1, Tao moi: %2, Cap nhat: %3 ===", TongSo, DaTaoMoi, DaCapNhat));
	
	GhiLogRaFile("setup_sample_users.log", LogLines);
EndProcedure

// Kiem tra danh sach nguoi dung da duoc khoi tao day du va dung role
Function KiemTraNguoiDungDaKhoiTao() Export
	DanhSachNguoiDung = DanhSachNguoiDungChuan();
	LogLines = New Array;
	LogLines.Add("=== KIEM TRA DANH SACH NGUOI DUNG TRONG CSDL ===");
	
	TatCaHopLe = True;
	
	For Each Item In DanhSachNguoiDung Do
		User = InfoBaseUsers.FindByName(Item.Name);
		If User = Undefined Then
			TatCaHopLe = False;
			MsgFail = StrTemplate("[THAT BAI] Khong tim thay nguoi dung: %1", Item.Name);
			LogLines.Add(MsgFail);
			WriteLogEvent("UserProvisioning.Verify", EventLogLevel.Error,,, MsgFail);
		Else
			CoDungRole = False;
			For Each R In User.Roles Do
				If R.Name = Item.RoleName Then
					CoDungRole = True;
					Break;
				EndIf;
			EndDo;
			
			If CoDungRole Then
				MsgPass = StrTemplate("[THANH CONG] %1 (%2) -> Role: %3 [HOP LE]", Item.Name, Item.FullName, Item.RoleName);
				LogLines.Add(MsgPass);
				WriteLogEvent("UserProvisioning.Verify", EventLogLevel.Information,,, MsgPass);
			Else
				TatCaHopLe = False;
				MsgFailRole = StrTemplate("[THAT BAI] %1 khong co Role: %2", Item.Name, Item.RoleName);
				LogLines.Add(MsgFailRole);
				WriteLogEvent("UserProvisioning.Verify", EventLogLevel.Error,,, MsgFailRole);
			EndIf;
		EndIf;
	EndDo;
	
	If TatCaHopLe Then
		LogLines.Add("KET QUA: 100% NGUOI DUNG VA ROLE HOP LE CHUAN XAC!");
		LogLines.Add("VERIFY_USERS_PASS_100%");
		WriteLogEvent("UserProvisioning.Verify", EventLogLevel.Information,,, "VERIFY_USERS_PASS_100%");
	Else
		LogLines.Add("KET QUA: CO LOI TRONG DANH SACH NGUOI DUNG!");
	EndIf;
	
	GhiLogRaFile("verify_sample_users.log", LogLines);
	Return TatCaHopLe;
EndFunction

// Danh sach dinh nghia chuan 8 nguoi dung mau + 1 Admin quan tri
Function DanhSachNguoiDungChuan() Export
	DanhSach = New Array;
	
	// 0. Quản trị hệ thống
	DanhSach.Add(New Structure("Name,FullName,Password,RoleName", 
		"Admin", "Quản trị hệ thống VSF", "Vsf@2026!Secure", "QuanTriHeThong"));
		
	// 1. Kế toán Phải thu (AR)
	DanhSach.Add(New Structure("Name,FullName,Password,RoleName", 
		"ketoan_ar", "Kế toán Phải thu (AR)", "Vsf@2026!Secure", "KeToanPhaiThu"));
		
	// 2. Kế toán Phải trả (AP)
	DanhSach.Add(New Structure("Name,FullName,Password,RoleName", 
		"ketoan_ap", "Kế toán Phải trả (AP)", "Vsf@2026!Secure", "KeToanPhaiTra"));
		
	// 3. Chuyên viên Đối soát & Netting
	DanhSach.Add(New Structure("Name,FullName,Password,RoleName", 
		"chuyenvien_doisoat", "Chuyên viên Đối soát & Netting", "Vsf@2026!Secure", "ChuyenVienDoiSoatTapDoan"));
		
	// 4. Giám đốc Tài chính / CFO
	DanhSach.Add(New Structure("Name,FullName,Password,RoleName", 
		"cfo_giamdoc", "Giám đốc Tài chính / CFO", "Vsf@2026!Secure", "GiamDocTaiChinh_CFO"));
		
	// 5. Kế toán trưởng
	DanhSach.Add(New Structure("Name,FullName,Password,RoleName", 
		"ketoan_truong", "Kế toán trưởng", "Vsf@2026!Secure", "KeToanTruong"));
		
	// 6. Quản lý dự án CNTT (PM)
	DanhSach.Add(New Structure("Name,FullName,Password,RoleName", 
		"pm_duan", "Quản lý dự án CNTT (PM)", "Vsf@2026!Secure", "ProjectManager_QuanLyDuAn"));
		
	// 7. Trưởng nhóm Kỹ thuật (TechLead)
	DanhSach.Add(New Structure("Name,FullName,Password,RoleName", 
		"techlead_kythuat", "Trưởng nhóm Kỹ thuật (TechLead)", "Vsf@2026!Secure", "TechLead_KiemTraKyThuat"));
		
	// 8. Giám đốc Hạ tầng CNTT (IT Director)
	DanhSach.Add(New Structure("Name,FullName,Password,RoleName", 
		"it_director", "Giám đốc Hạ tầng CNTT (IT Director)", "Vsf@2026!Secure", "ITDirector_GiamDocHaTang"));
		
	Return DanhSach;
EndFunction

#EndRegion

#Region PrivateHelpers

Procedure GhiLogRaFile(Val FileName, Val Lines)
	Try
		DocDir = "C:\Users\Dung\Documents\1C_Enterprise\";
		FilePath = DocDir + FileName;
		Writer = New TextWriter(FilePath, "UTF-8");
		For Each Line In Lines Do
			Writer.WriteLine(Line);
		EndDo;
		Writer.Close();
	Except
	EndTry;
EndProcedure

#EndRegion
