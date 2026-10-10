import os
import uuid

def uid():
    return str(uuid.uuid4())

def setup_full_test_data_module():
    cm_dir = "src/CommonModules"
    os.makedirs(os.path.join(cm_dir, "SeedFullTestDataServer", "Ext"), exist_ok=True)

    cm_xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<MetaDataObject xmlns="http://v8.1c.ru/8.3/MDClasses" xmlns:app="http://v8.1c.ru/8.2/managed-application/core" xmlns:cfg="http://v8.1c.ru/8.1/data/enterprise/current-config" xmlns:cmi="http://v8.1c.ru/8.2/managed-application/cmi" xmlns:ent="http://v8.1c.ru/8.1/data/enterprise" xmlns:lf="http://v8.1c.ru/8.2/managed-application/logform" xmlns:style="http://v8.1c.ru/8.1/data/ui/style" xmlns:sys="http://v8.1c.ru/8.1/data/ui/fonts/system" xmlns:v8="http://v8.1c.ru/8.1/data/core" xmlns:v8ui="http://v8.1c.ru/8.1/data/ui" xmlns:web="http://v8.1c.ru/8.1/data/ui/colors/web" xmlns:win="http://v8.1c.ru/8.1/data/ui/colors/windows" xmlns:xen="http://v8.1c.ru/8.3/xcf/enums" xmlns:xpr="http://v8.1c.ru/8.3/xcf/predef" xmlns:xr="http://v8.1c.ru/8.3/xcf/readable" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.15">
\t<CommonModule uuid="{uid()}">
\t\t<Properties>
\t\t\t<Name>SeedFullTestDataServer</Name>
\t\t\t<Synonym>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>vi</v8:lang>
\t\t\t\t\t<v8:content>Sinh dữ liệu kiểm thử quy mô lớn</v8:content>
\t\t\t\t</v8:item>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t<v8:content>Full Test Data Seeder</v8:content>
\t\t\t\t</v8:item>
\t\t\t</Synonym>
\t\t\t<Comment>Sinh khối lượng lớn chứng từ nghiệp vụ AR, AP, Ngân hàng, Netting để kiểm thử toàn diện</Comment>
\t\t\t<Global>false</Global>
\t\t\t<ClientManagedApplication>false</ClientManagedApplication>
\t\t\t<Server>true</Server>
\t\t\t<ExternalConnection>false</ExternalConnection>
\t\t\t<ClientOrdinaryApplication>false</ClientOrdinaryApplication>
\t\t\t<ServerCall>true</ServerCall>
\t\t\t<Privileged>true</Privileged>
\t\t\t<ReturnValuesReuse>DontUse</ReturnValuesReuse>
\t\t</Properties>
\t</CommonModule>
</MetaDataObject>"""

    with open(os.path.join(cm_dir, "SeedFullTestDataServer.xml"), "w", encoding="utf-8") as f:
        f.write(cm_xml)

    # BSL Module
    bsl = """// CommonModule: SeedFullTestDataServer
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Sinh khoi luong lon chung tu nghiep vu AR, AP, Ngan hang, Doi soat, Netting

Procedure ThucThiNapFullTestData() Export
	Log = New Array;
	Log.Add("=================================================================");
	Log.Add("   BAT DAU SINH KHOI LUONG LON DU LIEU NGHIEP VU TEST TOAN DIEN   ");
	Log.Add("   Thoi gian chay: " + CurrentSessionDate());
	Log.Add("=================================================================");
	
	Now = CurrentSessionDate();
	RefPN = Catalogs.PhapNhan.FindByCode("PN-VSF");
	RefPN_VIC = Catalogs.PhapNhan.FindByCode("PN-VIC");
	RefPN_VFS = Catalogs.PhapNhan.FindByCode("PN-VFS");
	
	RefDT_VIC = Catalogs.DoiTac.FindByCode("DT-VIC");
	RefDT_VFS = Catalogs.DoiTac.FindByCode("DT-VFS");
	RefDT_AWS = Catalogs.DoiTac.FindByCode("DT-AWS");
	RefDT_QCOM = Catalogs.DoiTac.FindByCode("DT-QCOM");
	RefDT_FPT = Catalogs.DoiTac.FindByCode("DT-FPT");
	RefDT_VTS = Catalogs.DoiTac.FindByCode("DT-VTS");
	
	RefHD_VIC = Catalogs.HopDong.FindByCode("HD-VIC-2026");
	RefHD_VFS = Catalogs.HopDong.FindByCode("HD-VFS-2026");
	RefHD_FPT = Catalogs.HopDong.FindByCode("HD-FPT-2026");
	RefHD_AWS = Catalogs.HopDong.FindByCode("HD-AWS-2026");
	RefHD_QCOM = Catalogs.HopDong.FindByCode("HD-QCOM-2026");
	
	RefTK_TCB = Catalogs.TaiKhoanTien.FindByCode("TK-TCB-VND");
	RefTK_VCB = Catalogs.TaiKhoanTien.FindByCode("TK-VCB-USD");
	RefTK_VPB = Catalogs.TaiKhoanTien.FindByCode("TK-VPB-VA");
	
	RefVND = Catalogs.TienTe.FindByCode("VND");
	RefUSD = Catalogs.TienTe.FindByCode("USD");
	
	RefKM_Thu = Catalogs.KhoanMucDongTien.FindByCode("KM-THU-BH");
	RefKM_Chi = Catalogs.KhoanMucDongTien.FindByCode("KM-CHI-CLOUD");
	RefKM_Phi = Catalogs.KhoanMucDongTien.FindByCode("KM-CHI-PHI-NH");
	
	RefKenh_VNPAY = Catalogs.KenhThanhToan.FindByCode("KTT-VNPAY");
	RefKenh_ONEPAY = Catalogs.KenhThanhToan.FindByCode("KTT-ONEPAY");

	// -------------------------------------------------------------
	// 1. PHAN HE AR: 10 BIEN BAN NGHIEM THU & 10 HOA DON GTGT DAU RA
	// -------------------------------------------------------------
	Log.Add("--- 1. Sinh 10 Bien ban nghiem thu & Hoa don GTGT dau ra (AR) ---");
	
	DanhSachAR = New Array;
	DanhSachAR.Add(New Structure("Code,DT,HD,Tien,Days,Note", "BB-VIC-01", RefDT_VIC, RefHD_VIC, 300000000, 95, "Nghiem thu GD1 SmartLife Core (Qua han >90 ngay)"));
	DanhSachAR.Add(New Structure("Code,DT,HD,Tien,Days,Note", "BB-VIC-02", RefDT_VIC, RefHD_VIC, 250000000, 65, "Nghiem thu GD2 Chuyen doi so Vingroup (Qua han 61-90 ngay)"));
	DanhSachAR.Add(New Structure("Code,DT,HD,Tien,Days,Note", "BB-VIC-03", RefDT_VIC, RefHD_VIC, 200000000, 20, "Nghiem thu GD3 Cloud Migration (Trong han)"));
	DanhSachAR.Add(New Structure("Code,DT,HD,Tien,Days,Note", "BB-VFS-01", RefDT_VFS, RefHD_VFS, 400000000, 80, "Nghiem thu GD1 Nen tang xe tu hanh ADAS v1 (Qua han 61-90 ngay)"));
	DanhSachAR.Add(New Structure("Code,DT,HD,Tien,Days,Note", "BB-VFS-02", RefDT_VFS, RefHD_VFS, 350000000, 45, "Nghiem thu GD2 Pin thong minh VinFast (Qua han 31-60 ngay)"));
	DanhSachAR.Add(New Structure("Code,DT,HD,Tien,Days,Note", "BB-VFS-03", RefDT_VFS, RefHD_VFS, 300000000, 15, "Nghiem thu GD3 In-Car Infotainment (Trong han)"));
	DanhSachAR.Add(New Structure("Code,DT,HD,Tien,Days,Note", "BB-FPT-01", RefDT_FPT, RefHD_FPT, 180000000, 85, "Nghiem thu Tong dai AI FPT Telecom (Qua han 61-90 ngay)"));
	DanhSachAR.Add(New Structure("Code,DT,HD,Tien,Days,Note", "BB-FPT-02", RefDT_FPT, RefHD_FPT, 220000000, 35, "Nghiem thu Ha tang CDN FPT Telecom (Qua han 31-60 ngay)"));
	DanhSachAR.Add(New Structure("Code,DT,HD,Tien,Days,Note", "BB-VTS-01", RefDT_VTS, RefHD_VIC, 210000000, 50, "Nghiem thu Toi uu mang 5G AI Viettel (Qua han 31-60 ngay)"));
	DanhSachAR.Add(New Structure("Code,DT,HD,Tien,Days,Note", "BB-VTS-02", RefDT_VTS, RefHD_VIC, 190000000, 10, "Nghiem thu Trung tam giam sat Viettel (Trong han)"));
	
	BienBanRefs = New Map;
	HoaDonARRefs = New Map;
	
	Idx = 1;
	For Each ItemAR In DanhSachAR Do
		DocDate = Now - ItemAR.Days * 86400;
		
		// Tao BienBanNghiemThuGiaiDoan
		BB = Documents.BienBanNghiemThuGiaiDoan.CreateDocument();
		BB.Number = "BB" + Format(Idx, "ND=4; NLZ=");
		BB.Date = DocDate;
		BB.PhapNhan = RefPN;
		BB.DoiTac = ItemAR.DT;
		BB.HopDong = ItemAR.HD;
		BB.GiaTriNghiemThuChuaVAT = ItemAR.Tien;
		BB.TyLeVAT = 10;
		BB.TienVAT = Round(ItemAR.Tien * 0.1, 2);
		BB.TongGiaTri = ItemAR.Tien + BB.TienVAT;
		BB.TrangThai = Enums.TrangThaiNghiemThuAR.DaDuyetNoiBo;
		BB.NgayNghiemThu = BegOfDay(DocDate);
		BB.DienGiai = ItemAR.Note;
		BB.NguoiTao = "KeToanAR";
		BB.NguoiDuyet = "CFO";
		BB.Write(DocumentWriteMode.Posting);
		BienBanRefs.Insert(ItemAR.Code, BB.Ref);
		
		// Tao HoaDonGTGTDauRa
		HD = Documents.HoaDonGTGTDauRa.CreateDocument();
		HD.Number = "HD26E" + Format(Idx, "ND=7; NLZ=");
		HD.Date = DocDate + 3600;
		HD.PhapNhan = RefPN;
		HD.DoiTac = ItemAR.DT;
		HD.HopDong = ItemAR.HD;
		HD.BienBanNghiemThu = BB.Ref;
		HD.SoHoaDon = "HD26E" + Format(Idx, "ND=7; NLZ=");
		HD.KyHieu = "1C26TVE";
		HD.NgayHoaDon = BegOfDay(DocDate);
		HD.TienChuaThue = ItemAR.Tien;
		HD.ThueSuatVAT = 10;
		HD.TienThueVAT = Round(ItemAR.Tien * 0.1, 2);
		HD.TongTienThanhToan = ItemAR.Tien + HD.TienThueVAT;
		HD.TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.DaPhatHanh;
		HD.MaCQT = "CQT-2026-" + Format(Idx, "ND=8; NLZ=");
		HD.DienGiai = "Hoa don GTGT dien tu cho " + ItemAR.Note;
		HD.Write(DocumentWriteMode.Posting);
		HoaDonARRefs.Insert(ItemAR.Code, HD.Ref);
		
		Log.Add(StrTemplate("[+] AR %1: Nghiem thu %2 tr + VAT 10%% -> Hoa don %3 (Ngay: %4)", 
			ItemAR.Code, ItemAR.Tien / 1000000, HD.Number, Format(DocDate, "DF=dd/MM/yyyy")));
		Idx = Idx + 1;
	EndDo;

	// -------------------------------------------------------------
	// 2. PHAN HE AR: 6 PHIEU THU TIEN KHACH HANG
	// -------------------------------------------------------------
	Log.Add("--- 2. Sinh 6 Phieu thu tien khach hang (AR Settlements) ---");
	
	DanhSachThu = New Array;
	DanhSachThu.Add(New Structure("Code,BBCode,DT,HD,TK,Tien,Days,Note", "PT-01", "BB-VIC-01", RefDT_VIC, RefHD_VIC, RefTK_TCB, 250000000, 60, "Vingroup thanh toan dot 1 qua VA TCB"));
	DanhSachThu.Add(New Structure("Code,BBCode,DT,HD,TK,Tien,Days,Note", "PT-02", "BB-FPT-01", RefDT_FPT, RefHD_FPT, RefTK_TCB, 198000000, 48, "FPT tat toan hop dong qua VA TCB"));
	DanhSachThu.Add(New Structure("Code,BBCode,DT,HD,TK,Tien,Days,Note", "PT-03", "BB-VFS-01", RefDT_VFS, RefHD_VFS, RefTK_VPB, 300000000, 40, "VinFast thanh toan GD1 qua VA VPB"));
	DanhSachThu.Add(New Structure("Code,BBCode,DT,HD,TK,Tien,Days,Note", "PT-04", "BB-VIC-02", RefDT_VIC, RefHD_VIC, RefTK_TCB, 150000000, 30, "Vingroup thanh toan dot 2 qua VA TCB"));
	DanhSachThu.Add(New Structure("Code,BBCode,DT,HD,TK,Tien,Days,Note", "PT-05", "BB-VTS-01", RefDT_VTS, RefHD_VIC, RefTK_VPB, 200000000, 22, "Viettel thanh toan qua VA VPB"));
	DanhSachThu.Add(New Structure("Code,BBCode,DT,HD,TK,Tien,Days,Note", "PT-06", "BB-VFS-02", RefDT_VFS, RefHD_VFS, RefTK_VPB, 150000000, 8, "VinFast thanh toan dot 1 GD2 qua VA VPB"));
	
	IdxPT = 1;
	For Each ItemThu In DanhSachThu Do
		DocDate = Now - ItemThu.Days * 86400;
		PT = Documents.PhieuThuTienKhachHang.CreateDocument();
		PT.Number = "PT" + Format(IdxPT, "ND=4; NLZ=");
		PT.Date = DocDate;
		PT.PhapNhan = RefPN;
		PT.DoiTac = ItemThu.DT;
		PT.HopDong = ItemThu.HD;
		PT.ChungTuGoc = BienBanRefs.Get(ItemThu.BBCode);
		PT.TaiKhoanTien = ItemThu.TK;
		PT.KhoanMucDongTien = RefKM_Thu;
		PT.TienTe = RefVND;
		PT.SoTien = ItemThu.Tien;
		PT.TyGia = 1;
		PT.NgayThu = BegOfDay(DocDate);
		PT.DienGiai = ItemThu.Note;
		PT.Write(DocumentWriteMode.Posting);
		
		Log.Add(StrTemplate("[+] PhieuThu %1: Thu %2 tr tu %3 (Ngay: %4)", 
			PT.Number, ItemThu.Tien / 1000000, ItemThu.DT.Description, Format(DocDate, "DF=dd/MM/yyyy")));
		IdxPT = IdxPT + 1;
	EndDo;

	// -------------------------------------------------------------
	// 3. PHAN HE AP: 8 HOA DON NHA CUNG CAP (AWS, QUALCOMM, VINFAST, FPT)
	// -------------------------------------------------------------
	Log.Add("--- 3. Sinh 8 Hoa don nha cung cap (AP Invoices with FCT) ---");
	
	DanhSachAP = New Array;
	// AWS USD: Co FCT 10%
	DanhSachAP.Add(New Structure("Code,DT,HD,USD,VNDRate,FCT,Days,Note", "AP-AWS-01", RefDT_AWS, RefHD_AWS, 12000, 25400, True, 80, "AWS Cloud Services Thang 7/2026 (12k USD, FCT 10%)"));
	DanhSachAP.Add(New Structure("Code,DT,HD,USD,VNDRate,FCT,Days,Note", "AP-AWS-02", RefDT_AWS, RefHD_AWS, 15000, 25400, True, 52, "AWS Cloud Services Thang 8/2026 (15k USD, FCT 10%)"));
	DanhSachAP.Add(New Structure("Code,DT,HD,USD,VNDRate,FCT,Days,Note", "AP-AWS-03", RefDT_AWS, RefHD_AWS, 18000, 25400, True, 18, "AWS Cloud Services Thang 9/2026 (18k USD, FCT 10%)"));
	// Qualcomm USD: Khong FCT
	DanhSachAP.Add(New Structure("Code,DT,HD,USD,VNDRate,FCT,Days,Note", "AP-QCOM-01", RefDT_QCOM, RefHD_QCOM, 10000, 25400, False, 70, "Qualcomm Snapdragon AI Chipset License (10k USD)"));
	DanhSachAP.Add(New Structure("Code,DT,HD,USD,VNDRate,FCT,Days,Note", "AP-QCOM-02", RefDT_QCOM, RefHD_QCOM, 8000, 25400, False, 28, "Qualcomm 5G Modem Royalty (8k USD)"));
	// Trong nuoc VND: VinFast noi bo & FPT ngoai
	DanhSachAP.Add(New Structure("Code,DT,HD,USD,VNDRate,FCT,Days,Note", "AP-VFS-01", RefDT_VFS, RefHD_VFS, 0, 1, False, 60, "VinFast - Thue san bai va tram thu nghiem xe AI (80tr VND)"));
	DanhSachAP.Add(New Structure("Code,DT,HD,USD,VNDRate,FCT,Days,Note", "AP-FPT-01", RefDT_FPT, RefHD_FPT, 0, 1, False, 42, "FPT Telecom - Thue kenh truyen so lieu chuyen dung (45tr VND)"));
	DanhSachAP.Add(New Structure("Code,DT,HD,USD,VNDRate,FCT,Days,Note", "AP-FPT-02", RefDT_FPT, RefHD_FPT, 0, 1, False, 12, "FPT Telecom - Thue cho dat may chu Data Center (55tr VND)"));
	
	HoaDonAPRefs = New Map;
	IdxAP = 1;
	For Each ItemAP In DanhSachAP Do
		DocDate = Now - ItemAP.Days * 86400;
		HDNCC = Documents.HoaDonNhaCungCap.CreateDocument();
		HDNCC.Number = "AP" + Format(IdxAP, "ND=4; NLZ=");
		HDNCC.Date = DocDate;
		HDNCC.PhapNhan = RefPN;
		HDNCC.DoiTac = ItemAP.DT;
		HDNCC.HopDong = ItemAP.HD;
		HDNCC.SoHoaDon = "INV-2026-" + Format(IdxAP, "ND=5; NLZ=");
		HDNCC.NgayHoaDon = BegOfDay(DocDate);
		
		If ItemAP.USD > 0 Then
			HDNCC.TienTe = RefUSD;
			HDNCC.TyGia = ItemAP.VNDRate;
			HDNCC.TongTienNgoaiTe = ItemAP.USD;
			HDNCC.TongTien = ItemAP.USD * ItemAP.VNDRate;
			HDNCC.TienDichVu = HDNCC.TongTien;
			HDNCC.CoKhauTruFCT = ItemAP.FCT;
			If ItemAP.FCT Then
				HDNCC.TyLeThueVATNhaThau = 5;
				HDNCC.TyLeThueTNDNNhaThau = 5;
				HDNCC.TienThueVATNhaThau = Round(HDNCC.TongTien * 0.05, 2);
				HDNCC.TienThueTNDNNhaThau = Round(HDNCC.TongTien * 0.05, 2);
				HDNCC.NoThucTraNCC = HDNCC.TongTien - (HDNCC.TienThueVATNhaThau + HDNCC.TienThueTNDNNhaThau);
				HDNCC.ChiPhiVSF = HDNCC.NoThucTraNCC + HDNCC.TienThueTNDNNhaThau;
			Else
				HDNCC.NoThucTraNCC = HDNCC.TongTien;
				HDNCC.ChiPhiVSF = HDNCC.TongTien;
			EndIf;
		Else
			// VND
			HDNCC.TienTe = RefVND;
			HDNCC.TyGia = 1;
			If ItemAP.Code = "AP-VFS-01" Then
				HDNCC.TongTien = 80000000;
			ElsIf ItemAP.Code = "AP-FPT-01" Then
				HDNCC.TongTien = 45000000;
			Else
				HDNCC.TongTien = 55000000;
			EndIf;
			HDNCC.TongTienNgoaiTe = 0;
			HDNCC.TienDichVu = HDNCC.TongTien;
			HDNCC.NoThucTraNCC = HDNCC.TongTien;
			HDNCC.ChiPhiVSF = HDNCC.TongTien;
			HDNCC.CoKhauTruFCT = False;
		EndIf;
		
		HDNCC.TrangThai = Enums.TrangThaiHoaDonAP.DaGhiSo;
		HDNCC.TaiKhoanChiPhi = ChartsOfAccounts.HeThongTaiKhoan.TK627;
		HDNCC.DienGiai = ItemAP.Note;
		HDNCC.Write(DocumentWriteMode.Posting);
		HoaDonAPRefs.Insert(ItemAP.Code, HDNCC.Ref);
		
		Log.Add(StrTemplate("[+] AP %1: Hoa don %2 - %3 tr VND (Thuc tra: %4 tr) (Ngay: %5)", 
			HDNCC.Number, ItemAP.DT.Description, HDNCC.TongTien / 1000000, HDNCC.NoThucTraNCC / 1000000, Format(DocDate, "DF=dd/MM/yyyy")));
		IdxAP = IdxAP + 1;
	EndDo;

	// -------------------------------------------------------------
	// 4. PHAN HE AP: 5 UY NHIEM CHI THANH TOAN NHA CUNG CAP
	// -------------------------------------------------------------
	Log.Add("--- 4. Sinh 5 Uy nhiem chi thanh toan (AP Bank Payments) ---");
	
	DanhSachUNC = New Array;
	DanhSachUNC.Add(New Structure("Code,APCode,DT,HD,TK,USD,Rate,VND,Phi,Days,Note", "UNC-01", "AP-AWS-01", RefDT_AWS, RefHD_AWS, RefTK_VCB, 10800, 25400, 274320000, 150000, 55, "Thanh toan tat toan AP-AWS-01 qua VCB USD"));
	DanhSachUNC.Add(New Structure("Code,APCode,DT,HD,TK,USD,Rate,VND,Phi,Days,Note", "UNC-02", "AP-QCOM-01", RefDT_QCOM, RefHD_QCOM, RefTK_VCB, 10000, 25400, 254000000, 200000, 45, "Thanh toan AP-QCOM-01 qua VCB USD"));
	DanhSachUNC.Add(New Structure("Code,APCode,DT,HD,TK,USD,Rate,VND,Phi,Days,Note", "UNC-03", "AP-AWS-02", RefDT_AWS, RefHD_AWS, RefTK_VCB, 8000, 25400, 203200000, 150000, 25, "Thanh toan dot 1 AP-AWS-02 qua VCB USD"));
	DanhSachUNC.Add(New Structure("Code,APCode,DT,HD,TK,USD,Rate,VND,Phi,Days,Note", "UNC-04", "AP-FPT-01", RefDT_FPT, RefHD_FPT, RefTK_TCB, 0, 1, 45000000, 22000, 30, "Tat toan AP-FPT-01 qua TCB VND"));
	DanhSachUNC.Add(New Structure("Code,APCode,DT,HD,TK,USD,Rate,VND,Phi,Days,Note", "UNC-05", "AP-VFS-01", RefDT_VFS, RefHD_VFS, RefTK_TCB, 0, 1, 40000000, 0, 15, "Thanh toan dot 1 mat bang VinFast qua TCB VND"));
	
	IdxUNC = 1;
	For Each ItemUNC In DanhSachUNC Do
		DocDate = Now - ItemUNC.Days * 86400;
		UNC = Documents.UyNhiemChi.CreateDocument();
		UNC.Number = "UNC" + Format(IdxUNC, "ND=4; NLZ=");
		UNC.Date = DocDate;
		UNC.PhapNhan = RefPN;
		UNC.DoiTac = ItemUNC.DT;
		UNC.HopDong = ItemUNC.HD;
		UNC.ChungTuGoc = HoaDonAPRefs.Get(ItemUNC.APCode);
		UNC.TaiKhoanTien = ItemUNC.TK;
		UNC.KhoanMucDongTien = RefKM_Chi;
		If ItemUNC.USD > 0 Then
			UNC.TienTe = RefUSD;
			UNC.TyGia = ItemUNC.Rate;
			UNC.SoTienNgoaiTe = ItemUNC.USD;
			UNC.SoTien = ItemUNC.VND;
		Else
			UNC.TienTe = RefVND;
			UNC.TyGia = 1;
			UNC.SoTienNgoaiTe = 0;
			UNC.SoTien = ItemUNC.VND;
		EndIf;
		UNC.PhiNganHang = ItemUNC.Phi;
		UNC.TrangThai = Enums.TrangThaiLenhThanhToan.DaGhiSo;
		UNC.NgayLap = BegOfDay(DocDate);
		UNC.NgayGhiSo = BegOfDay(DocDate);
		UNC.NguoiLap = "KeToanAP";
		UNC.NguoiDuyet = "CFO";
		UNC.DienGiai = ItemUNC.Note;
		UNC.Write(DocumentWriteMode.Posting);
		
		Log.Add(StrTemplate("[+] UyNhiemChi %1: Chi %2 tr cho %3 (Ngay: %4)", 
			UNC.Number, ItemUNC.VND / 1000000, ItemUNC.DT.Description, Format(DocDate, "DF=dd/MM/yyyy")));
		IdxUNC = IdxUNC + 1;
	EndDo;

	// -------------------------------------------------------------
	// 5. PHAN HE NGAN HANG: 2 BANG KE DOI SOAT CONG THANH TOAN
	// -------------------------------------------------------------
	Log.Add("--- 5. Sinh 2 Bang ke doi soat cong thanh toan VNPAY & OnePay ---");
	
	// Bang ke VNPAY
	BK1 = Documents.BangKeDoiSoatKenhThanhToan.CreateDocument();
	BK1.Number = "BK-VNPAY-01";
	BK1.Date = Now - 20 * 86400;
	BK1.PhapNhan = RefPN;
	BK1.KenhThanhToan = RefKenh_VNPAY;
	BK1.TaiKhoanNganHang = RefTK_TCB;
	BK1.KhoanMucDongTien = RefKM_Thu;
	BK1.NgayBatDau = BegOfDay(Now - 30 * 86400);
	BK1.NgayKetThuc = EndOfDay(Now - 20 * 86400);
	BK1.TongTienGiaoDich = 75000000;
	BK1.TongPhiKenh = 1125000;
	BK1.TongThucNhan = 73875000;
	BK1.TrangThai = "DaDoiSoat";
	BK1.NguoiLap = "ChuyenVienDoiSoat";
	BK1.NguoiDuyet = "KeToanTruong";
	BK1.GhiChu = "Doi soat cong VNPAY Ky 2 Thang 9/2026";
	BK1.Write(DocumentWriteMode.Posting);
	Log.Add("[+] BangKe " + BK1.Number + ": Tong 75tr, Phi 1.125tr, Thuc nhan 73.875tr");
	
	// Bang ke OnePay
	BK2 = Documents.BangKeDoiSoatKenhThanhToan.CreateDocument();
	BK2.Number = "BK-ONEPAY-01";
	BK2.Date = Now - 5 * 86400;
	BK2.PhapNhan = RefPN;
	BK2.KenhThanhToan = RefKenh_ONEPAY;
	BK2.TaiKhoanNganHang = RefTK_TCB;
	BK2.KhoanMucDongTien = RefKM_Thu;
	BK2.NgayBatDau = BegOfDay(Now - 15 * 86400);
	BK2.NgayKetThuc = EndOfDay(Now - 5 * 86400);
	BK2.TongTienGiaoDich = 40000000;
	BK2.TongPhiKenh = 880000;
	BK2.TongThucNhan = 39120000;
	BK2.TrangThai = "DaDoiSoat";
	BK2.NguoiLap = "ChuyenVienDoiSoat";
	BK2.NguoiDuyet = "KeToanTruong";
	BK2.GhiChu = "Doi soat cong OnePay The Quoc Te Ky 1 Thang 10/2026";
	BK2.Write(DocumentWriteMode.Posting);
	Log.Add("[+] BangKe " + BK2.Number + ": Tong 40tr, Phi 880k, Thuc nhan 39.120tr");

	// -------------------------------------------------------------
	// 6. PHAN HE NETTING: 2 CHUNG TU CAN TRU CONG NO NOI BO
	// -------------------------------------------------------------
	Log.Add("--- 6. Sinh 2 Chung tu can tru cong no noi bo Tap doan ---");
	
	// Can tru 2 ben VSF - VinFast: 40.000.000 VND
	CT1 = Documents.CanTruCongNoNoiBo.CreateDocument();
	CT1.Number = "CT-BILATERAL-01";
	CT1.Date = Now - 14 * 86400;
	CT1.PhapNhan = RefPN;
	CT1.DoiTacNoiBo = RefDT_VFS;
	CT1.HopDongAR = RefHD_VFS;
	CT1.HopDongAP = RefHD_VFS;
	CT1.ChungTuGocAR = HoaDonARRefs.Get("BB-VFS-01");
	CT1.ChungTuGocAP = HoaDonAPRefs.Get("AP-VFS-01");
	CT1.SoTienCanTru = 40000000;
	CT1.LaCanTruBacCau = False;
	CT1.TrangThai = "DaGhiSo";
	CT1.NguoiLap = "KeToanNoiBo";
	CT1.NguoiDuyet = "CFO";
	CT1.GhiChu = "Can tru song phuong 2 ben VSF ban phan mem & VinFast cho thue mat bang";
	CT1.Write(DocumentWriteMode.Posting);
	Log.Add("[+] CanTru " + CT1.Number + ": Song phuong VSF - VinFast 40tr VND");
	
	// Can tru 3 ben VSF - Vingroup - VinFast: 100.000.000 VND qua TK 1388
	CT2 = Documents.CanTruCongNoNoiBo.CreateDocument();
	CT2.Number = "CT-MULTILATERAL-01";
	CT2.Date = Now - 7 * 86400;
	CT2.PhapNhan = RefPN;
	CT2.DoiTacNoiBo = RefDT_VIC;
	CT2.HopDongAR = RefHD_VIC;
	CT2.HopDongAP = RefHD_VIC;
	CT2.ChungTuGocAR = HoaDonARRefs.Get("BB-VIC-02");
	CT2.ChungTuGocAP = HoaDonAPRefs.Get("AP-VFS-01");
	CT2.SoTienCanTru = 100000000;
	CT2.LaCanTruBacCau = True;
	CT2.DoiTacTrungGian = RefDT_VFS;
	CT2.TrangThai = "DaGhiSo";
	CT2.NguoiLap = "KeToanNoiBo";
	CT2.NguoiDuyet = "CFO";
	CT2.GhiChu = "Can tru da bien 3 ben VSF - Vingroup - VinFast qua TK trung gian 1388";
	CT2.Write(DocumentWriteMode.Posting);
	Log.Add("[+] CanTru " + CT2.Number + ": Da bien 3 ben VSF - Vingroup - VinFast 100tr VND");

	Log.Add("=================================================================");
	Log.Add("   HOAN TAT SINH FULL TEST DATA THANH CONG 100%!                ");
	Log.Add("=================================================================");
	
	LogPath = "C:/Users/Dung/Documents/1C_Enterprise/seed_full_test_data.log";
	Try
		TW = New TextWriter(LogPath, TextEncoding.UTF8);
		For Each L In Log Do
			TW.WriteLine(L);
		EndDo;
		TW.Close();
	Except
	EndTry;
EndProcedure
"""

    with open(os.path.join(cm_dir, "SeedFullTestDataServer", "Ext", "Module.bsl"), "w", encoding="utf-8") as f:
        f.write(bsl)
    print("Generated src/CommonModules/SeedFullTestDataServer/Ext/Module.bsl")

    # Update Configuration.xml
    with open("src/Configuration.xml", "r", encoding="utf-8") as f:
        cfg = f.read()

    tag = "<CommonModule>SeedFullTestDataServer</CommonModule>"
    if tag not in cfg:
        cfg = cfg.replace("<CommonModule>SeedDataCleanServer</CommonModule>\n", f"<CommonModule>SeedDataCleanServer</CommonModule>\n\t\t\t{tag}\n")
        with open("src/Configuration.xml", "w", encoding="utf-8") as f:
            f.write(cfg)
        print("Updated src/Configuration.xml with SeedFullTestDataServer!")

    # Update ManagedApplicationModule.bsl
    mam_bsl = """Procedure OnStart()
	If LaunchParameter = "SeedFullTestData" Then
		SeedFullTestDataServer.ThucThiNapFullTestData();
		Exit(False);
	ElsIf LaunchParameter = "SeedCleanMasterData" Then
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
    setup_full_test_data_module()
