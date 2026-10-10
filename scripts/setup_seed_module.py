import os
import uuid

def uid():
    return str(uuid.uuid4())

def setup_seed_module():
    cm_dir = "src/CommonModules"
    os.makedirs(os.path.join(cm_dir, "SeedDataCleanServer", "Ext"), exist_ok=True)

    cm_xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<MetaDataObject xmlns="http://v8.1c.ru/8.3/MDClasses" xmlns:app="http://v8.1c.ru/8.2/managed-application/core" xmlns:cfg="http://v8.1c.ru/8.1/data/enterprise/current-config" xmlns:cmi="http://v8.1c.ru/8.2/managed-application/cmi" xmlns:ent="http://v8.1c.ru/8.1/data/enterprise" xmlns:lf="http://v8.1c.ru/8.2/managed-application/logform" xmlns:style="http://v8.1c.ru/8.1/data/ui/style" xmlns:sys="http://v8.1c.ru/8.1/data/ui/fonts/system" xmlns:v8="http://v8.1c.ru/8.1/data/core" xmlns:v8ui="http://v8.1c.ru/8.1/data/ui" xmlns:web="http://v8.1c.ru/8.1/data/ui/colors/web" xmlns:win="http://v8.1c.ru/8.1/data/ui/colors/windows" xmlns:xen="http://v8.1c.ru/8.3/xcf/enums" xmlns:xpr="http://v8.1c.ru/8.3/xcf/predef" xmlns:xr="http://v8.1c.ru/8.3/xcf/readable" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.15">
\t<CommonModule uuid="{uid()}">
\t\t<Properties>
\t\t\t<Name>SeedDataCleanServer</Name>
\t\t\t<Synonym>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>vi</v8:lang>
\t\t\t\t\t<v8:content>Khởi tạo dữ liệu nền tảng</v8:content>
\t\t\t\t</v8:item>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t<v8:content>Clean Master Data Seeder</v8:content>
\t\t\t\t</v8:item>
\t\t\t</Synonym>
\t\t\t<Comment>Tự động nạp danh mục nền tảng, hằng số và người dùng Admin cho Infobase</Comment>
\t\t\t<Global>false</Global>
\t\t\t<ClientManagedApplication>false</ClientManagedApplication>
\t\t\t<Server>true</Server>
\t\t\t<ExternalConnection>false</ExternalConnection>
\t\t\t<ClientOrdinaryApplication>false</ClientOrdinaryApplication>
\t\t\t<ServerCall>true</ServerCall>
\t\t\t<Privileged>true</Privileged>
\t\t\t<ReturnValuesReuse>DontUse</ReturnValuesReuse>
\t\t</Properties>
\t\t</CommonModule>
</MetaDataObject>"""

    with open(os.path.join(cm_dir, "SeedDataCleanServer.xml"), "w", encoding="utf-8") as f:
        f.write(cm_xml)

    bsl = """// CommonModule: SeedDataCleanServer
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
	RefDT_AWS = NapDoiTac("DT-AWS", "Amazon Web Services Inc. (AWS)", Enums.LoaiDoiTac.NhaCungCap, False, True, "AWS-US-987654", Log);
	RefDT_QCOM = NapDoiTac("DT-QCOM", "Qualcomm Technologies Inc.", Enums.LoaiDoiTac.NhaCungCap, False, False, "QCOM-US-112233", Log);
	RefDT_VTS = NapDoiTac("DT-VTS", "Tong Cong ty Giai phap Doanh nghiep Viettel", Enums.LoaiDoiTac.KhachHangVaNhaCungCap, False, True, "0100109106", Log);
	RefDT_FPT = NapDoiTac("DT-FPT", "Cong ty Co phan Vien thong FPT (FPT Telecom)", Enums.LoaiDoiTac.KhachHangVaNhaCungCap, False, True, "0101778163", Log);
	RefDT_VIC = NapDoiTac("DT-VIC", "Tap doan Vingroup - CTCP", Enums.LoaiDoiTac.KhachHangVaNhaCungCap, True, True, "0101245486", Log);
	RefDT_VFS = NapDoiTac("DT-VFS", "Cong ty Co phan VinFast", Enums.LoaiDoiTac.KhachHangVaNhaCungCap, True, True, "0108926276", Log);
	RefDT_B2C = NapDoiTac("DT-B2C", "Khach hang ca nhan thanh toan truc tuyen B2C", Enums.LoaiDoiTac.KhachHang, False, True, "B2C-RETAIL", Log);
	
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
	NapKenhThanhToan("KTT-VNPAY", "Cong thanh toan VNPAY (QR / Noi dia)", 1.5, Log);
	NapKenhThanhToan("KTT-ONEPAY", "Cong thanh toan OnePay (Visa / Mastercard)", 2.2, Log);
	
	// 9. Dich vu CNTT
	NapDichVuCNTT("DV-AWS-EC2", "Dich vu May chu ao EC2 & Co so du lieu RDS Cloud", Log);
	NapDichVuCNTT("DV-AWS-S3", "Dich vu Luu tru dam may S3 Storage", Log);
	NapDichVuCNTT("DV-AI-INFER", "Dich vu He thong tinh toan AI Inference Server", Log);
	
	// 10. Du an
	NapDuAn("DA-SMARTLIFE", "Du an He sinh thai Thiet bi Thong minh VinSmart SmartLife", Log);
	NapDuAn("DA-AUTONOMOUS", "Du an Nen tang Tro ly Lai xe Thong minh ADAS", Log);
	
	// 11. Khoan muc dong tien
	NapKhoanMucDongTien("KM-THU-BH", "Thu tien ban hang va cung cap dich vu CNTT", Enums.HuongDongTien.Thu, Log);
	NapKhoanMucDongTien("KM-CHI-CLOUD", "Chi tra chi phi dich vu ha tang dam may Cloud", Enums.HuongDongTien.Chi, Log);
	NapKhoanMucDongTien("KM-CHI-THUE", "Chi nop thue nha thau FCT va thue GTGT", Enums.HuongDongTien.Chi, Log);
	NapKhoanMucDongTien("KM-CHI-PHI-NH", "Chi tra phi dich vu ngan hang va cong thanh toan", Enums.HuongDongTien.Chi, Log);
	
	// 12. Hang so he thong (Constants)
	ThiLapHangSo(RefPN_VSF, Log);
	
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
	RegRecord.TyGia = TyGia;
	RegRecord.SoLuong = 1;
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

Function NapDoiTac(Val Code, Val Ten, Val Loai, Val LaLienKet, Val ThueTT, Val MST, Log)
	Obj = Catalogs.DoiTac.FindByCode(Code);
	If Obj.IsEmpty() Then
		Item = Catalogs.DoiTac.CreateItem();
		Item.Code = Code;
		Item.Description = Ten;
		Item.LoaiDoiTac = Loai;
		Item.LaBenLienKet = LaLienKet;
		Item.DaDangKyThueTrucTiep = ThueTT;
		Item.MaSoThue = MST;
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

Procedure NapKenhThanhToan(Val Code, Val Ten, Val Phi, Log)
	Obj = Catalogs.KenhThanhToan.FindByCode(Code);
	If Obj.IsEmpty() Then
		Item = Catalogs.KenhThanhToan.CreateItem();
		Item.Code = Code;
		Item.Description = Ten;
		Item.TyLePhi = Phi;
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
		Item.Write();
		Log.Add("[+] Tao DichVuCNTT: " + Code);
	Else
		Log.Add("[.] DichVuCNTT da ton tai: " + Code);
	EndIf;
EndProcedure

Procedure NapDuAn(Val Code, Val Ten, Log)
	Obj = Catalogs.DuAn.FindByCode(Code);
	If Obj.IsEmpty() Then
		Item = Catalogs.DuAn.CreateItem();
		Item.Code = Code;
		Item.Description = Ten;
		Item.Write();
		Log.Add("[+] Tao DuAn: " + Code);
	Else
		Log.Add("[.] DuAn da ton tai: " + Code);
	EndIf;
EndProcedure

Procedure NapKhoanMucDongTien(Val Code, Val Ten, Val Huong, Log)
	Obj = Catalogs.KhoanMucDongTien.FindByCode(Code);
	If Obj.IsEmpty() Then
		Item = Catalogs.KhoanMucDongTien.CreateItem();
		Item.Code = Code;
		Item.Description = Ten;
		Item.HuongDongTien = Huong;
		Item.Write();
		Log.Add("[+] Tao KhoanMucDongTien: " + Code);
	Else
		Log.Add("[.] KhoanMucDongTien da ton tai: " + Code);
	EndIf;
EndProcedure

Procedure ThiLapHangSo(Val PhapNhanMacDinhRef, Log)
	Try
		Constants.PhapNhanMacDinh.Set(PhapNhanMacDinhRef);
		Constants.NguongPheDuyetChiTienCFO.Set(50000000);
		Constants.TuDongDongBoSAP.Set(True);
		Constants.NguongThanhToanKhongDungTienMat.Set(20000000);
		Constants.SoLuongHoaDonFIFOMax.Set(50);
		Constants.GiaTriFIFOMax.Set(5000000000);
		Constants.TimeoutChoCanTruPhut.Set(60);
		Constants.CanhBaoCloudMucVang.Set(80);
		Constants.CanhBaoCloudMucCam.Set(90);
		Constants.CanhBaoCloudMucDo.Set(100);
		Log.Add("[+] Thiet lap thanh cong cac Hang so he thong (PhapNhanMacDinh, NguongCFO=50tr, TuDongSAP=True, CanhBaoCloud).");
	Except
		Log.Add("[!] Loi thiet lap hang so: " + ErrorDescription());
	EndTry;
EndProcedure

Procedure TaoNguoiDungAdmin(Log)
	// 1. Tao User Admin neu chua co
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
		
		// Gan tat ca cac quyen Role
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
"""

    with open(os.path.join(cm_dir, "SeedDataCleanServer", "Ext", "Module.bsl"), "w", encoding="utf-8") as f:
        f.write(bsl)
    print("Generated src/CommonModules/SeedDataCleanServer/Ext/Module.bsl")

    # Update Configuration.xml
    with open("src/Configuration.xml", "r", encoding="utf-8") as f:
        cfg = f.read()

    tag = "<CommonModule>SeedDataCleanServer</CommonModule>"
    if tag not in cfg:
        cfg = cfg.replace("<CommonModule>CatalogsCoreTest</CommonModule>\n", f"<CommonModule>CatalogsCoreTest</CommonModule>\n\t\t\t{tag}\n")
        with open("src/Configuration.xml", "w", encoding="utf-8") as f:
            f.write(cfg)
        print("Updated src/Configuration.xml with SeedDataCleanServer!")

    # Update ManagedApplicationModule.bsl
    mam_bsl = """Procedure OnStart()
	If LaunchParameter = "SeedCleanMasterData" Then
		SeedDataCleanServer.ThucThiNapMasterData();
		Exit(False);
	ElsIf LaunchParameter = "RunUnitTests" Then
		CatalogsCoreTest.RunVerification();
		EnumsConstantsTest.RunVerification();
		Exit(False);
	ElsIf LaunchParameter = "RunEnumsConstantsTests" Then
		EnumsConstantsTest.RunVerification();
		Exit(False);
	EndIf;
EndProcedure
"""
    with open("src/Ext/ManagedApplicationModule.bsl", "w", encoding="utf-8") as f:
        f.write(mam_bsl)
    print("Updated src/Ext/ManagedApplicationModule.bsl successfully!")

if __name__ == "__main__":
    setup_seed_module()
