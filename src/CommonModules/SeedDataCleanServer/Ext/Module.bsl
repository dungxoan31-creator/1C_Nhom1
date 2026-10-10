// CommonModule: SeedDataCleanServer
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Khoi tao Master Data sach, Hang so va Tai khoan Admin

Procedure ThucThiNapMasterData() Export
	Log = New Array;
	Log.Add("=== BAT DAU NAP MASTER DATA SACH VA NGUOI DUNG ADMIN ===");
	
	// 1. Tien te (VND, USD, EUR)
	RefVND = NapTienTe("VND", "Dong Viet Nam", "VND", Log);
	RefUSD = NapTienTe("USD", "US Dollar", "USD", Log);
	RefEUR = NapTienTe("EUR", "Euro", "EUR", Log);
	
	// 2. Ty gia hoi doai
	NapTyGia(RefUSD, 25400, Log);
	NapTyGia(RefEUR, 27500, Log);
	
	// 3. Phap nhan
	RefPN_VSF = NapPhapNhan("PN-VSF", "Cong ty Co phan VinSmart Future", "0109988776", "Toa Symphony, Vinhomes Riverside, Long Bien, Ha Noi", Log);
	RefPN_VIC = NapPhapNhan("PN-VIC", "Tap doan Vingroup - CTCP", "0101245486", "So 7 Bang Lang 1, Vinhomes Riverside, Long Bien, Ha Noi", Log);
	RefPN_VFS = NapPhapNhan("PN-VFS", "Cong ty Co phan VinFast", "0108926276", "Khu Kinh te Dinh Vu - Cat Hai, Hai Phong", Log);
	
	// 4. Doi tac
	RefDT_AWS = NapDoiTac("DT-AWS", "Amazon Web Services Inc. (AWS)", Enums.LoaiDoiTac.NhaCungCap, False, True, Log);
	RefDT_QCOM = NapDoiTac("DT-QCOM", "Qualcomm Technologies Inc.", Enums.LoaiDoiTac.NhaCungCap, False, False, Log);
	RefDT_VTS = NapDoiTac("DT-VTS", "Tong Cong ty Giai phap Doanh nghiep Viettel", Enums.LoaiDoiTac.KhachHangVaNhaCungCap, False, True, Log);
	RefDT_FPT = NapDoiTac("DT-FPT", "Cong ty Co phan Vien thong FPT (FPT Telecom)", Enums.LoaiDoiTac.KhachHangVaNhaCungCap, False, True, Log);
	RefDT_VIC = NapDoiTac("DT-VIC", "Tap doan Vingroup - CTCP", Enums.LoaiDoiTac.KhachHangVaNhaCungCap, True, True, Log);
	RefDT_VFS = NapDoiTac("DT-VFS", "Cong ty Co phan VinFast", Enums.LoaiDoiTac.KhachHangVaNhaCungCap, True, True, Log);
	RefDT_B2C = NapDoiTac("DT-B2C", "Khach hang ca nhan thanh toan truc tuyen B2C", Enums.LoaiDoiTac.KhachHang, False, True, Log);
	
	// 5. Tai khoan tien (Ngan hang)
	RefTK_TCB = NapTaiKhoanTien("TK-TCB-VND", "Techcombank VND - Hoi so chinh", "1903889988001", "Techcombank - Hoi so chinh", RefVND, Log);
	RefTK_VCB = NapTaiKhoanTien("TK-VCB-USD", "Vietcombank USD - So giao dich", "0011004455667", "Vietcombank - So giao dich 1", RefUSD, Log);
	RefTK_VPB = NapTaiKhoanTien("TK-VPB-VA", "VPBank Chuyen thu Virtual Account", "198899776655", "VPBank - CN Ha Noi", RefVND, Log);
	
	// 6. Tai khoan ao (Virtual Accounts)
	NapTaiKhoanAo("VA-TCB-FPT", "Tai khoan ao TCB - FPT Telecom", "9901-VSF-FPT001", RefDT_FPT, RefTK_TCB, Log);
	NapTaiKhoanAo("VA-TCB-VIC", "Tai khoan ao TCB - Vingroup", "9901-VSF-VIC001", RefDT_VIC, RefTK_TCB, Log);
	NapTaiKhoanAo("VA-VPB-VTS", "Tai khoan ao VPB - Viettel", "96248888001", RefDT_VTS, RefTK_VPB, Log);
	
	// 7. Hop dong
	NapHopDong("HD-AWS-2026", "Hop dong Cloud Services AWS 2026 (Net 30)", RefPN_VSF, RefDT_AWS, RefUSD, 30, False, Log);
	NapHopDong("HD-QCOM-2026", "Hop dong Chipset Qualcomm 2026 (Net 45)", RefPN_VSF, RefDT_QCOM, RefUSD, 45, False, Log);
	NapHopDong("HD-VFS-2026", "Hop dong Cung cap giai phap AI VinFast (Net 30)", RefPN_VSF, RefDT_VFS, RefVND, 30, False, Log);
	NapHopDong("HD-VIC-2026", "Hop dong Dich vu Chuyen doi so Vingroup (Net 30)", RefPN_VSF, RefDT_VIC, RefVND, 30, False, Log);
	NapHopDong("HD-FPT-2026", "Hop dong Trien khai he thong FPT Telecom (Net 30)", RefPN_VSF, RefDT_FPT, RefVND, 30, False, Log);
	
	// 8. Kenh thanh toan
	NapKenhThanhToan("KTT-VNPAY", "Cong thanh toan VNPAY", Log);
	NapKenhThanhToan("KTT-ONEPAY", "Cong thanh toan OnePay", Log);
	
	// 9. Dich vu CNTT
	NapDichVuCNTT("DV-AWS-EC2", "Dich vu May chu ao EC2 va Co so du lieu RDS Cloud", Log);
	NapDichVuCNTT("DV-AWS-S3", "Dich vu Luu tru dam may S3 Storage", Log);
	NapDichVuCNTT("DV-AI-INFER", "Dich vu He thong tinh toan AI Inference Server", Log);
	
	// 10. Du an
	NapDuAn("DA-SMARTLIFE", "Du an He sinh thai Thiet bi Thong minh VinSmart SmartLife", RefPN_VSF, Log);
	NapDuAn("DA-AUTONOMOUS", "Du an Nen tang Tro ly Lai xe Thong minh ADAS", RefPN_VSF, Log);
	
	// 11. Khoan muc dong tien
	NapKhoanMucDongTien("KM-THU-BH", "Thu tien ban hang va cung cap dich vu CNTT", "DongTienVao", Log);
	NapKhoanMucDongTien("KM-CHI-CLOUD", "Chi tra chi phi dich vu ha tang dam may Cloud", "DongTienRa", Log);
	NapKhoanMucDongTien("KM-CHI-THUE", "Chi nop thue nha thau FCT va thue GTGT", "DongTienRa", Log);
	NapKhoanMucDongTien("KM-CHI-PHI-NH", "Chi tra phi dich vu ngan hang va cong thanh toan", "DongTienRa", Log);
	
	// 12. Hang so he thong (Constants)
	ThiLapHangSo("PN-VSF", Log);
	
	// 13. Nguoi dung Admin va Ke toan
	TaoNguoiDungAdmin(Log);
	
	Log.Add("=== HOAN TAT NAP TOAN BO MASTER DATA SACH VA NGUOI DUNG! ===");
	
	// Ghi log ra file
	LogPath = "C:/Users/Dung/Documents/1C_Enterprise/seed_clean_data.log";
	Try
		TW = New TextWriter(LogPath, TextEncoding.UTF8);
		For Each L In Log Do
			TW.WriteLine(L);
		EndDo;
		TW.Close();
	Except
	EndTry;
EndProcedure

Function NapTienTe(Val Code, Val Ten, Val MaISO, Log)
	Obj = Catalogs.TienTe.FindByCode(Code);
	If Obj.IsEmpty() Then
		Item = Catalogs.TienTe.CreateItem();
		Item.Code = Code;
		Item.Description = Ten;
		Item.MaTienTe = MaISO;
		Item.TenDayDu = Ten;
		Item.Write();
		Log.Add("[+] Tao TienTe: " + Code + " - " + Ten);
		Return Item.Ref;
	Else
		Log.Add("[.] TienTe da ton tai: " + Code);
		Return Obj;
	EndIf;
EndFunction

Procedure NapTyGia(Val TienTeRef, Val TyGia, Log)
	RegRecord = InformationRegisters.TyGiaHoiDoai.CreateRecordManager();
	RegRecord.Period = BegOfDay(CurrentDate());
	RegRecord.TienTe = TienTeRef;
	RegRecord.TyGiaMua = TyGia;
	RegRecord.TyGiaBan = TyGia;
	RegRecord.TyGiaHachToan = TyGia;
	Try
		RegRecord.Write(True);
		Log.Add("[+] Cap nhat Ty gia: " + TienTeRef + " = " + TyGia);
	Except
		Log.Add("[!] Loi cap nhat ty gia: " + ErrorDescription());
	EndTry;
EndProcedure

Function NapPhapNhan(Val Code, Val Ten, Val MST, Val DiaChi, Log)
	Obj = Catalogs.PhapNhan.FindByCode(Code);
	If Obj.IsEmpty() Then
		Item = Catalogs.PhapNhan.CreateItem();
		Item.Code = Code;
		Item.Description = Ten;
		Item.MaSoThue = MST;
		Item.DiaChi = DiaChi;
		Item.Write();
		Log.Add("[+] Tao PhapNhan: " + Code + " - " + Ten);
		Return Item.Ref;
	Else
		Log.Add("[.] PhapNhan da ton tai: " + Code);
		Return Obj;
	EndIf;
EndFunction

Function NapDoiTac(Val Code, Val Ten, Val Loai, Val LaLienKet, Val ThueTT, Log)
	Obj = Catalogs.DoiTac.FindByCode(Code);
	If Obj.IsEmpty() Then
		Item = Catalogs.DoiTac.CreateItem();
		Item.Code = Code;
		Item.Description = Ten;
		Item.LoaiDoiTac = Loai;
		Item.LaBenLienKet = LaLienKet;
		Item.DaDangKyThueTrucTiep = ThueTT;
		Item.Write();
		Log.Add("[+] Tao DoiTac: " + Code + " - " + Ten);
		Return Item.Ref;
	Else
		Log.Add("[.] DoiTac da ton tai: " + Code);
		Return Obj;
	EndIf;
EndFunction

Function NapTaiKhoanTien(Val Code, Val Ten, Val SoTK, Val NganHang, Val TienTeRef, Log)
	Obj = Catalogs.TaiKhoanTien.FindByCode(Code);
	If Obj.IsEmpty() Then
		Item = Catalogs.TaiKhoanTien.CreateItem();
		Item.Code = Code;
		Item.Description = Ten;
		Item.SoTaiKhoan = SoTK;
		Item.NganHang = NganHang;
		Item.TienTe = TienTeRef;
		Item.Write();
		Log.Add("[+] Tao TaiKhoanTien: " + Code + " - " + SoTK);
		Return Item.Ref;
	Else
		Log.Add("[.] TaiKhoanTien da ton tai: " + Code);
		Return Obj;
	EndIf;
EndFunction

Procedure NapTaiKhoanAo(Val Code, Val Ten, Val SoVA, Val DoiTacRef, Val NganHangRef, Log)
	Obj = Catalogs.TaiKhoanAo.FindByCode(Code);
	If Obj.IsEmpty() Then
		Item = Catalogs.TaiKhoanAo.CreateItem();
		Item.Code = Code;
		Item.Description = Ten;
		Item.SoTaiKhoanAo = SoVA;
		Item.DoiTac = DoiTacRef;
		Item.NganHang = NganHangRef;
		Item.Write();
		Log.Add("[+] Tao TaiKhoanAo: " + Code + " - " + SoVA);
	Else
		Log.Add("[.] TaiKhoanAo da ton tai: " + Code);
	EndIf;
EndProcedure

Procedure NapHopDong(Val Code, Val Ten, Val PhapNhanRef, Val DoiTacRef, Val TienTeRef, Val HanNgay, Val GrossUp, Log)
	Obj = Catalogs.HopDong.FindByCode(Code);
	If Obj.IsEmpty() Then
		Item = Catalogs.HopDong.CreateItem();
		Item.Code = Code;
		Item.Description = Ten;
		Item.PhapNhan = PhapNhanRef;
		Item.ChuSoHuu = DoiTacRef;
		Item.DongTienThanhToan = TienTeRef;
		Item.HanThanhToanNgay = HanNgay;
		Item.GrossUpThue = GrossUp;
		Item.Write();
		Log.Add("[+] Tao HopDong: " + Code + " - " + Ten);
	Else
		Log.Add("[.] HopDong da ton tai: " + Code);
	EndIf;
EndProcedure

Procedure NapKenhThanhToan(Val Code, Val Ten, Log)
	Obj = Catalogs.KenhThanhToan.FindByCode(Code);
	If Obj.IsEmpty() Then
		Item = Catalogs.KenhThanhToan.CreateItem();
		Item.Code = Code;
		Item.Description = Ten;
		Item.MaKenh = Code;
		Item.TenKenh = Ten;
		Item.Write();
		Log.Add("[+] Tao KenhThanhToan: " + Code);
	Else
		Log.Add("[.] KenhThanhToan da ton tai: " + Code);
	EndIf;
EndProcedure

Procedure NapDichVuCNTT(Val Code, Val Ten, Log)
	Obj = Catalogs.DichVuCNTT.FindByCode(Code);
	If Obj.IsEmpty() Then
		Item = Catalogs.DichVuCNTT.CreateItem();
		Item.Code = Code;
		Item.Description = Ten;
		Item.MaDichVu = Code;
		Item.TenDichVu = Ten;
		Item.TyLeVATMacDinh = 10;
		Item.Write();
		Log.Add("[+] Tao DichVuCNTT: " + Code);
	Else
		Log.Add("[.] DichVuCNTT da ton tai: " + Code);
	EndIf;
EndProcedure

Procedure NapDuAn(Val Code, Val Ten, Val PhapNhanRef, Log)
	Obj = Catalogs.DuAn.FindByCode(Code);
	If Obj.IsEmpty() Then
		Item = Catalogs.DuAn.CreateItem();
		Item.Code = Code;
		Item.Description = Ten;
		Item.MaDuAn = Code;
		Item.TenDuAn = Ten;
		Item.PhapNhan = PhapNhanRef;
		Item.Write();
		Log.Add("[+] Tao DuAn: " + Code);
	Else
		Log.Add("[.] DuAn da ton tai: " + Code);
	EndIf;
EndProcedure

Procedure NapKhoanMucDongTien(Val Code, Val Ten, Val Loai, Log)
	Obj = Catalogs.KhoanMucDongTien.FindByCode(Code);
	If Obj.IsEmpty() Then
		Item = Catalogs.KhoanMucDongTien.CreateItem();
		Item.Code = Code;
		Item.Description = Ten;
		Item.LoaiDongTien = Loai;
		Item.Write();
		Log.Add("[+] Tao KhoanMucDongTien: " + Code);
	Else
		Log.Add("[.] KhoanMucDongTien da ton tai: " + Code);
	EndIf;
EndProcedure

Procedure ThiLapHangSo(Val PhapNhanCode, Log)
	Try
		Constants.PhapNhanMacDinh.Set(PhapNhanCode);
		Constants.NguongPheDuyetChiTienCFO.Set(50000000);
		Constants.TuDongDongBoSAP.Set(True);
		Constants.NguongThanhToanKhongDungTienMat.Set(20000000);
		Constants.SoLuongHoaDonFIFOMax.Set(50);
		Constants.GiaTriFIFOMax.Set(5000000000);
		Constants.TimeoutChoCanTruPhut.Set(60);
		Constants.CanhBaoCloudMucVang.Set(80);
		Constants.CanhBaoCloudMucCam.Set(90);
		Constants.CanhBaoCloudMucDo.Set(100);
		Constants.TaiKhoanPhiNganHang.Set("6425");
		Constants.TaiKhoanTrungGianCanTru.Set("1388");
		Log.Add("[+] Thiet lap thanh cong tat ca 12 Hang so he thong!");
	Except
		Log.Add("[!] Loi thiet lap hang so: " + ErrorDescription());
	EndTry;
EndProcedure

Procedure TaoNguoiDungAdmin(Log)
	AdminUser = Undefined;
	For Each U In InfoBaseUsers.GetUsers() Do
		If Upper(U.Name) = "ADMIN" Then
			AdminUser = U;
			Break;
		EndIf;
	EndDo;
	
	If AdminUser = Undefined Then
		AdminUser = InfoBaseUsers.CreateUser();
		AdminUser.Name = "Admin";
		AdminUser.FullName = "Quan tri vien He thong (Administrator)";
		AdminUser.StandardAuthentication = True;
		AdminUser.Password = "";
		AdminUser.ShowInList = True;
		
		For Each R In Metadata.Roles Do
			AdminUser.Roles.Add(R);
		EndDo;
		
		Try
			AdminUser.Write();
			Log.Add("[+] Tao thanh cong nguoi dung Admin (Toan quyen QuanTriHeThong, khong mat khau).");
		Except
			Log.Add("[!] Khong the tao nguoi dung Admin: " + ErrorDescription());
		EndTry;
	Else
		Log.Add("[.] Nguoi dung Admin da ton tai san.");
	EndIf;
EndProcedure
