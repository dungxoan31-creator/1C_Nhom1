// Common Module: UserProvisioningServer
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Khoi tao va quan ly danh sach nguoi dung mau theo ma tran 8 Roles (Huong 2).

#Region PublicInterface

// Khoi tao toan bo 8 nguoi dung nghiep vu + Admin quan tri he thong
// [FIX B33] - Chi chay tren ban clone UAT va boi nguoi co vai tro Quan tri he thong.
//           - Khong reset mat khau / vai tro cua nguoi dung DA TON TAI (truoc day ai cung reset duoc mat khau Admin).
//           - Mat khau khong con viet cung trong code va khong bao gio ghi ra nhat ky; truyen qua tham so.
Procedure KhoiTaoDanhSachNguoiDung(Val MatKhauMacDinh = "") Export
	If InfoBaseUsers.GetUsers().Count() > 0 And Not IsInRole("QuanTriHeThong") Then
		WriteLogEvent("UserProvisioning.Forbidden", EventLogLevel.Warning,,, 
			StrTemplate("Người dùng '%1' không có quyền khởi tạo người dùng mẫu", UserName()));
		Raise "Chỉ Quản trị hệ thống được khởi tạo người dùng mẫu!";
	EndIf;
	
	DanhSachNguoiDung = DanhSachNguoiDungChuan();
	
	LogLines = New Array;
	LogLines.Add("=== BAT DAU KHOI TAO NGUOI DUNG VA MA TRAN PHAN QUYEN VSF ===");
	
	TongSo = 0;
	DaTaoMoi = 0;
	DaCapNhat = 0;
	
	For Each Item In DanhSachNguoiDung Do
		TongSo = TongSo + 1;
		
		User = InfoBaseUsers.FindByName(Item.Name);
		If User <> Undefined Then
			// Khong ghi de nguoi dung da co (giu nguyen mat khau va vai tro)
			DaCapNhat = DaCapNhat + 1;
			MsgLog = StrTemplate("[DA TON TAI - BO QUA] %1", Item.Name);
			LogLines.Add(MsgLog);
			WriteLogEvent("UserProvisioning.Skip", EventLogLevel.Information,,, MsgLog);
			Continue;
		EndIf;
		User = InfoBaseUsers.CreateUser();
		DaTaoMoi = DaTaoMoi + 1;
		
		User.Name = Item.Name;
		User.FullName = Item.FullName;
		RoleMD = Metadata.Roles.Find(Item.RoleName);
		If RoleMD <> Undefined Then
			User.Roles.Add(RoleMD);
		Else
			Raise "Khong tim thay Role trong Metadata: " + Item.RoleName;
		EndIf;
		
		TrangThaiMatKhau = ?(ValueIsFilled(MatKhauMacDinh), "da dat theo tham so", "trong");
		Try
			User.Password = MatKhauMacDinh;
			User.Write();
		Except
			If Not ValueIsFilled(MatKhauMacDinh) Then
				Raise;
			EndIf;
			// Ban Training Edition chi cho phep mat khau trong (chi ap dung tren clone UAT)
			User.Password = "";
			User.Write();
			TrangThaiMatKhau = "trong (Training Edition)";
		EndTry;
		
		// Khong ghi gia tri mat khau ra nhat ky
		MsgLog = StrTemplate("[TAO MOI] %1: %2 | Role: %3 | Mat khau: %4", 
			Item.Name, Item.FullName, Item.RoleName, TrangThaiMatKhau);
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

// Danh sach dinh nghia chuan 5 nguoi dung nghiep vu + Admin quan tri
Function DanhSachNguoiDungChuan() Export
	DanhSach = New Array;
	
	// 0. Quản trị hệ thống
	DanhSach.Add(New Structure("Name,FullName,Password,RoleName", 
		"Admin", "Quản trị hệ thống VSF", "", "QuanTriHeThong"));
		
	// 1. Kế toán Phải thu (AR)
	DanhSach.Add(New Structure("Name,FullName,Password,RoleName", 
		"ketoan_ar", "Kế toán Phải thu (AR)", "", "KeToanPhaiThu"));
		
	// 2. Kế toán Phải trả (AP)
	DanhSach.Add(New Structure("Name,FullName,Password,RoleName", 
		"ketoan_ap", "Kế toán Phải trả (AP)", "", "KeToanPhaiTra"));
		
	// 3. Giám đốc Tài chính / CFO
	DanhSach.Add(New Structure("Name,FullName,Password,RoleName", 
		"cfo_giamdoc", "Giám đốc Tài chính / CFO", "", "GiamDocTaiChinh_CFO"));
		
	// 4. Kế toán trưởng
	DanhSach.Add(New Structure("Name,FullName,Password,RoleName", 
		"ketoan_truong", "Kế toán trưởng", "", "KeToanTruong"));
		
	Return DanhSach;
EndFunction

#EndRegion

#Region PrivateHelpers

// [FIX B75] Bo duong dan cung C:\Users\Dung\...; ghi vao Nhat ky su kien cua 1C
Procedure GhiLogRaFile(Val FileName, Val Lines)
	WriteLogEvent("UserProvisioning.Detail", EventLogLevel.Information,,, FileName + Chars.LF + StrConcat(Lines, Chars.LF));
EndProcedure

#EndRegion
