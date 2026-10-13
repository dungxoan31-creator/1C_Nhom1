// CommonModule: GeneratorMasterDataServer
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Sinh khoi luong lon Master Data DoiTac (P&L Vingroup tai cau truc 2026, KH ngoai, NCC),
//           DuAn (4 Khoi + BO), DichVuCNTT (90+ dich vu), HopDong va TyGia

#Region PublicInterface

Procedure KhoiTaoMasterDataToanDien() Export
	RefPN_VSF = Catalogs.PhapNhan.FindByCode("PN-VSF");
	If Not ValueIsFilled(RefPN_VSF) Then
		ObjPN = Catalogs.PhapNhan.CreateItem();
		ObjPN.Code = "PN-VSF";
		ObjPN.Description = "Công ty CP VinSmart Future";
		ObjPN.MaSoThue = "0108999888";
		ObjPN.DiaChi = "Tòa nhà Symphony, Chu Huy Mân, Long Biên, Hà Nội";
		ObjPN.Write();
		RefPN_VSF = ObjPN.Ref;
	EndIf;
	
	RefVND = Catalogs.TienTe.FindByCode("VND");
	RefUSD = Catalogs.TienTe.FindByCode("USD");

	BeginTransaction();
	Try
		// 0. Don dep du lieu TEST cu neu co
		XoaDuLieuTestCu();

		// 0.1. Khoi tao cac tai khoan ke toan con thieu (3313, 3318, 3388, 641)
		KhoiTaoCacTaiKhoanConThieu();

		// 1. Khoi tao 28 Bo phan / Du an (4 Khoi kinh doanh + Khoi BO) trong Catalog.DuAn
		KhoiTaoCacKhoiVaDuAn(RefPN_VSF);

		// 2. Khoi tao 90+ Dich vu CNTT / San pham VSF trong Catalog.DichVuCNTT
		KhoiTaoDichVuCNTT();

		// 3. Khoi tao Danh muc Doi tac (P&L Vingroup, Khach hang ngoai, NCC Quoc te USD, NCC Trong nuoc)
		KhoiTaoDoiTacVaP_L();

		// 4. Khoi tao Hop dong khung gan voi cac Doi tac (ChuSoHuu)
		KhoiTaoHopDong(RefPN_VSF, RefVND, RefUSD);

		// 5. Khoi tao Ty gia USD tu 01/01/2025 den 30/09/2026 (638 ngay)
		KhoiTaoTyGiaUSD(RefUSD);

		CommitTransaction();
		WriteLogEvent("MasterData.Seed", EventLogLevel.Information,,, "Khởi tạo Master Data thành công toàn diện!");
	Except
		RollbackTransaction();
		WriteLogEvent("MasterData.Seed", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		Raise;
	EndTry;
EndProcedure

Procedure KiemTraMasterData() Export
	Q_DT = New Query("SELECT COUNT(*) AS Cnt FROM Catalog.DoiTac WHERE Code LIKE ""TEST_%""");
	CntDT = Q_DT.Execute().Unload()[0].Cnt;
	
	Q_VG = New Query("SELECT COUNT(*) AS Cnt FROM Catalog.DoiTac WHERE Code LIKE ""TEST_VG_%"" AND LaBenLienKet = TRUE");
	CntVG = Q_VG.Execute().Unload()[0].Cnt;
	
	Q_HD = New Query("SELECT COUNT(*) AS Cnt FROM Catalog.HopDong WHERE Code LIKE ""HD-%""");
	CntHD = Q_HD.Execute().Unload()[0].Cnt;

	Q_DA = New Query("SELECT COUNT(*) AS Cnt FROM Catalog.DuAn WHERE Code LIKE ""DA_%""");
	CntDA = Q_DA.Execute().Unload()[0].Cnt;

	Q_DV = New Query("SELECT COUNT(*) AS Cnt FROM Catalog.DichVuCNTT WHERE Code LIKE ""DV_%"" OR Code LIKE ""CP_%""");
	CntDV = Q_DV.Execute().Unload()[0].Cnt;
	
	Q_TG = New Query("SELECT COUNT(*) AS Cnt FROM InformationRegister.TyGiaHoiDoai");
	CntTG = Q_TG.Execute().Unload()[0].Cnt;
	
	If CntDT >= 200 And CntVG >= 15 And CntHD >= 200 And CntDA >= 25 And CntDV >= 70 And CntTG >= 600 Then
		Msg = StrTemplate("MASTER_DATA_VERIFY_SUCCESS: DoiTac=%1, DoiTacVingroup=%2, HopDong=%3, DuAnKhoi=%4, DichVuCNTT=%5, TyGiaHoiDoai=%6", 
			CntDT, CntVG, CntHD, CntDA, CntDV, CntTG);
		WriteLogEvent("MasterData.Verify", EventLogLevel.Information,,, Msg);
	Else
		Msg = StrTemplate("MASTER_DATA_VERIFY_FAILED: DoiTac=%1, DoiTacVingroup=%2, HopDong=%3, DuAnKhoi=%4, DichVuCNTT=%5, TyGiaHoiDoai=%6", 
			CntDT, CntVG, CntHD, CntDA, CntDV, CntTG);
		WriteLogEvent("MasterData.Verify", EventLogLevel.Error,,, Msg);
	EndIf;
EndProcedure

#EndRegion

#Region InternalProcedures

Procedure XoaDuLieuTestCu()
	Q = New Query("SELECT Ref FROM Catalog.HopDong WHERE Code LIKE ""HD-%""");
	T = Q.Execute().Unload();
	For Each R In T Do
		Try
			R.Ref.GetObject().Delete();
		Except
		EndTry;
	EndDo;
	
	Q = New Query("SELECT Ref FROM Catalog.DoiTac WHERE Code LIKE ""TEST_%""");
	T = Q.Execute().Unload();
	For Each R In T Do
		Try
			R.Ref.GetObject().Delete();
		Except
		EndTry;
	EndDo;
EndProcedure

Procedure KhoiTaoCacKhoiVaDuAn(RefPN_VSF)
	CacKhoi = New Array;
	// Khoi I - Nen tang, Du lieu, AI
	CacKhoi.Add(New Structure("Code,Name", "DA_K1_NENTANG", "Khối I - Nền tảng số V-App Core"));
	CacKhoi.Add(New Structure("Code,Name", "DA_K1_DULIEU", "Khối I - Hồ dữ liệu & Big Data"));
	CacKhoi.Add(New Structure("Code,Name", "DA_K1_BACHKHOA_BAO", "Khối I - Bách khoa toàn thư & Báo điện tử"));
	CacKhoi.Add(New Structure("Code,Name", "DA_K1_NENTANG_MOHINH", "Khối I - Nền tảng & Mô hình AI lớn (LLM)"));
	CacKhoi.Add(New Structure("Code,Name", "DA_K1_AI_THIETBI", "Khối I - AI Thiết bị & IoT Thông minh"));
	CacKhoi.Add(New Structure("Code,Name", "DA_K1_AI_OPEN_PLATFORM", "Khối I - AI Platform Mở (API Hub)"));
	CacKhoi.Add(New Structure("Code,Name", "DA_K1_NCSP_UIUX", "Khối I - Trung tâm NCSP & Thiết kế UIUX"));

	// Khoi II - He sinh thai so
	CacKhoi.Add(New Structure("Code,Name", "DA_K2_FINTECH", "Khối II - Cổng thanh toán & Ví điện tử Fintech"));
	CacKhoi.Add(New Structure("Code,Name", "DA_K2_TMDT_QUANGCAO", "Khối II - Sàn Thương mại điện tử & Ads Network"));
	CacKhoi.Add(New Structure("Code,Name", "DA_K2_CHAT", "Khối II - Ứng dụng Chat nội bộ & Khách hàng"));
	CacKhoi.Add(New Structure("Code,Name", "DA_K2_XE_SERVICES", "Khối II - Nền tảng Dịch vụ Xe & Connected Car"));
	CacKhoi.Add(New Structure("Code,Name", "DA_K2_YTE", "Khối II - Nền tảng Chuyển đổi số Y tế (Vinmec)"));
	CacKhoi.Add(New Structure("Code,Name", "DA_K2_GIAODUC", "Khối II - Nền tảng Giáo dục thông minh (VinUni)"));

	// Khoi III - Cong nghiep, Ha tang
	CacKhoi.Add(New Structure("Code,Name", "DA_K3_HATANG", "Khối III - Hạ tầng Data Center & Cloud"));
	CacKhoi.Add(New Structure("Code,Name", "DA_K3_TRUYENDAN_DOINGOAI", "Khối III - Mạng Truyền dẫn & Kết nối Đối ngoại"));
	CacKhoi.Add(New Structure("Code,Name", "DA_K3_BDS_SMARTCITY", "Khối III - Nền tảng Smart City & IoT Đô thị"));
	CacKhoi.Add(New Structure("Code,Name", "DA_K3_PM_DUNGCHUNG", "Khối III - Phần mềm Dùng chung & Công ty Mới"));
	CacKhoi.Add(New Structure("Code,Name", "DA_K3_PM_SANXUAT", "Khối III - Vận hành Phần mềm Sản xuất (VinFast)"));

	// Khoi IV - Kinh doanh, Van hanh, Du lich, BDS, CSKH
	CacKhoi.Add(New Structure("Code,Name", "DA_K4_BDS_BANLE", "Khối IV - Giải pháp Bán lẻ & TTTM (Vincom)"));
	CacKhoi.Add(New Structure("Code,Name", "DA_K4_DULICH_KHACHSAN", "Khối IV - Nền tảng Du lịch - Khách sạn (Vinpearl)"));
	CacKhoi.Add(New Structure("Code,Name", "DA_K4_KD_VANHANH", "Khối IV - Vận hành Dịch vụ Khách hàng VinClub"));
	CacKhoi.Add(New Structure("Code,Name", "DA_K4_CSKH_GLOBAL", "Khối IV - Trung tâm CSKH Toàn cầu (Contact Center)"));

	// Khoi Ho tro (BO - Cost Centers)
	CacKhoi.Add(New Structure("Code,Name", "DA_BO_QUANTRICHUNG", "Khối BO - Quản trị chung & Văn phòng Ban Giám đốc"));
	CacKhoi.Add(New Structure("Code,Name", "DA_BO_TUYENDUNG", "Khối BO - Trung tâm Tuyển dụng & Thu hút Nhân tài"));
	CacKhoi.Add(New Structure("Code,Name", "DA_BO_HR", "Khối BO - Nhân sự & Đào tạo (HRS, HRBP)"));
	CacKhoi.Add(New Structure("Code,Name", "DA_BO_HANHCHINH", "Khối BO - Quản trị Hành chính & Cơ sở vật chất"));
	CacKhoi.Add(New Structure("Code,Name", "DA_BO_TCKT", "Khối BO - Ban Tài chính & Kế toán"));
	CacKhoi.Add(New Structure("Code,Name", "DA_BO_PHAPCHE", "Khối BO - Ban Pháp chế & Sở hữu trí tuệ"));
	CacKhoi.Add(New Structure("Code,Name", "DA_BO_THANHTRA", "Khối BO - Ban Thanh tra & Kiểm soát tuân thủ"));

	For Each Item In CacKhoi Do
		Ref = Catalogs.DuAn.FindByCode(Item.Code);
		If Not ValueIsFilled(Ref) Then
			Obj = Catalogs.DuAn.CreateItem();
			Obj.Code = Item.Code;
			Obj.Description = Item.Name;
			Obj.MaDuAn = Item.Code;
			Obj.TenDuAn = Item.Name;
			Obj.PhapNhan = RefPN_VSF;
			Obj.Write();
		EndIf;
	EndDo;
EndProcedure

Procedure KhoiTaoDichVuCNTT()
	DSDichVu = New Array;
	// Doanh thu ban ra (AR)
	DSDichVu.Add(New Structure("Code,Name,VAT", "DV_VAPP_DEV", "Phí phát triển tính năng Siêu ứng dụng V-App", 10));
	DSDichVu.Add(New Structure("Code,Name,VAT", "DV_VAPP_OPS", "Phí vận hành định kỳ Siêu ứng dụng V-App", 10));
	DSDichVu.Add(New Structure("Code,Name,VAT", "DV_TMDT_COM", "Phí hoa hồng giao dịch sàn Thương mại điện tử", 10));
	DSDichVu.Add(New Structure("Code,Name,VAT", "DV_TMDT_SELLER", "Phí gói dịch vụ hỗ trợ Seller sàn TMĐT", 10));
	DSDichVu.Add(New Structure("Code,Name,VAT", "DV_ADS_BANNER", "Doanh thu quảng cáo Banner hiển thị trên V-App", 10));
	DSDichVu.Add(New Structure("Code,Name,VAT", "DV_ADS_SEARCH", "Doanh thu quảng cáo từ khóa tìm kiếm TMĐT", 10));
	DSDichVu.Add(New Structure("Code,Name,VAT", "DV_VINCLUB_LOYALTY", "Phí nền tảng khách hàng thân thiết VinClub", 10));
	DSDichVu.Add(New Structure("Code,Name,VAT", "DV_CHAT_LICENSE", "Bản quyền ứng dụng Chat doanh nghiệp nội bộ", 10));
	DSDichVu.Add(New Structure("Code,Name,VAT", "DV_AI_API_TOKEN", "Gói sử dụng API AI Platform Mở (10M Tokens)", 10));
	DSDichVu.Add(New Structure("Code,Name,VAT", "DV_AI_MODEL_CUSTOM", "Dịch vụ huấn luyện mô hình AI riêng biệt", 10));
	DSDichVu.Add(New Structure("Code,Name,VAT", "DV_BIGDATA_ANALYTICS", "Dịch vụ phân tích dữ liệu hành vi người dùng", 10));
	DSDichVu.Add(New Structure("Code,Name,VAT", "DV_CSKH_TICKET", "Phí xử lý yêu cầu CSKH Contact Center (theo Ticket)", 10));
	DSDichVu.Add(New Structure("Code,Name,VAT", "DV_CSKH_AGENT", "Giờ công nhân sự CSKH Toàn cầu cao cấp", 10));
	DSDichVu.Add(New Structure("Code,Name,VAT", "DV_CLOUD_HOSTING", "Dịch vụ thuê máy chủ Cloud nội bộ VSF", 10));
	DSDichVu.Add(New Structure("Code,Name,VAT", "DV_CAMERA_AI_DEVICE", "Thiết bị Camera AI giám sát đô thị thông minh", 10));
	DSDichVu.Add(New Structure("Code,Name,VAT", "DV_EDGE_AI_BOX", "Thiết bị xử lý tính toán biên Edge AI Box v2", 10));
	DSDichVu.Add(New Structure("Code,Name,VAT", "DV_SMART_CAR_ADAS", "Bản quyền phần mềm xe thông minh ADAS cho VinFast", 10));
	DSDichVu.Add(New Structure("Code,Name,VAT", "DV_MES_VINFAST_OPS", "Vận hành hệ thống điều hành sản xuất MES Nhà máy Hải Phòng", 10));
	DSDichVu.Add(New Structure("Code,Name,VAT", "DV_HIS_VINMEC_OPS", "Vận hành hệ thống quản lý bệnh viện thông minh Vinmec", 10));
	DSDichVu.Add(New Structure("Code,Name,VAT", "DV_PMS_VINPEARL_OPS", "Vận hành hệ thống quản trị khách sạn PMS Vinpearl", 10));
	DSDichVu.Add(New Structure("Code,Name,VAT", "DV_SMARTCITY_VINHOMES", "Dịch vụ vận hành nền tảng Smart City Vinhomes", 10));
	DSDichVu.Add(New Structure("Code,Name,VAT", "DV_LMS_VINUNI_OPS", "Hệ thống quản lý học tập trực tuyến LMS VinUni", 10));
	DSDichVu.Add(New Structure("Code,Name,VAT", "DV_XANHSM_DISPATCH", "Nền tảng điều phối xe và thuật toán đón trả GSM", 10));

	// Chi phi mua vao (AP)
	DSDichVu.Add(New Structure("Code,Name,VAT", "CP_AWS_CLOUD_USD", "Thuê máy chủ đám mây AWS Cloud quốc tế (USD)", 0));
	DSDichVu.Add(New Structure("Code,Name,VAT", "CP_MS_AZURE_USD", "Thuê dịch vụ điện toán đám mây Microsoft Azure (USD)", 0));
	DSDichVu.Add(New Structure("Code,Name,VAT", "CP_GCP_AI_USD", "Dịch vụ hạ tầng huấn luyện AI Google Cloud (USD)", 0));
	DSDichVu.Add(New Structure("Code,Name,VAT", "CP_QUALCOMM_LIC_USD", "Bản quyền chip và công nghệ kết nối Qualcomm (USD)", 0));
	DSDichVu.Add(New Structure("Code,Name,VAT", "CP_SAP_LICENSE_USD", "Bản quyền giải pháp SAP ERP doanh nghiệp (USD)", 0));
	DSDichVu.Add(New Structure("Code,Name,VAT", "CP_ORACLE_DB_USD", "Bản quyền hệ quản trị CSDL Oracle Enterprise (USD)", 0));
	DSDichVu.Add(New Structure("Code,Name,VAT", "CP_VIETTEL_IDC", "Thuê chỗ đặt máy chủ Colocation Viettel IDC Hà Nội", 10));
	DSDichVu.Add(New Structure("Code,Name,VAT", "CP_FPT_BANDWIDTH", "Thuê kênh truyền dẫn Internet băng thông cao FPT", 10));
	DSDichVu.Add(New Structure("Code,Name,VAT", "CP_OUTSOURCE_DEV_FPT", "Thuê ngoài nhân sự lập trình Backend/Frontend FPT", 10));
	DSDichVu.Add(New Structure("Code,Name,VAT", "CP_OUTSOURCE_TEST_CMC", "Thuê ngoài kiểm thử phần mềm chuyên nghiệp CMC", 10));
	DSDichVu.Add(New Structure("Code,Name,VAT", "CP_THUE_VP_HANOI", "Thuê diện tích văn phòng làm việc Trụ sở Hà Nội", 10));
	DSDichVu.Add(New Structure("Code,Name,VAT", "CP_THUE_VP_DONGKHOI", "Thuê văn phòng chi nhánh TP.HCM KV Đồng Khởi", 10));
	DSDichVu.Add(New Structure("Code,Name,VAT", "CP_THUE_VP_HAIPHONG", "Thuê văn phòng chi nhánh Hải Phòng KV Cát Hải", 10));
	DSDichVu.Add(New Structure("Code,Name,VAT", "CP_THUE_VP_HATINH", "Thuê văn phòng chi nhánh Hà Tĩnh KV Vũng Áng", 10));
	DSDichVu.Add(New Structure("Code,Name,VAT", "CP_GSM_VEHICLE", "Thuê xe dịch vụ đưa đón cán bộ nhân viên GSM Xanh SM", 10));
	DSDichVu.Add(New Structure("Code,Name,VAT", "CP_VINMEC_HEALTH", "Khám sức khỏe định kỳ cán bộ nhân viên tại Vinmec", 0));
	DSDichVu.Add(New Structure("Code,Name,VAT", "CP_TUYENDUNG_HRS", "Dịch vụ đăng tin và săn đầu người tuyển dụng HRS", 10));
	DSDichVu.Add(New Structure("Code,Name,VAT", "CP_DAOTAO_AI_SPEC", "Khóa đào tạo chuyên sâu Kỹ sư AI & Cloud Architecture", 0));
	DSDichVu.Add(New Structure("Code,Name,VAT", "CP_THIETBI_SERVER_DELL", "Mua sắm máy chủ trung tâm dữ liệu Dell PowerEdge R750", 10));
	DSDichVu.Add(New Structure("Code,Name,VAT", "CP_THIETBI_SWITCH_CISCO", "Thiết bị mạng chuyển mạch Core Switch Cisco Nexus", 10));

	// Bo sung them 40 dich vu phu tro de dat tong cong >85 dich vu
	For i = 1 To 45 Do
		CodeDV = "DV_SUB_" + Right("000" + String(i), 3);
		NameDV = "Dịch vụ Phụ trợ Kỹ thuật & Tích hợp Module số " + String(i);
		DSDichVu.Add(New Structure("Code,Name,VAT", CodeDV, NameDV, 10));
	EndDo;

	For Each Item In DSDichVu Do
		Ref = Catalogs.DichVuCNTT.FindByCode(Item.Code);
		If Not ValueIsFilled(Ref) Then
			Obj = Catalogs.DichVuCNTT.CreateItem();
			Obj.Code = Item.Code;
			Obj.Description = Item.Name;
			Obj.MaDichVu = Item.Code;
			Obj.TenDichVu = Item.Name;
			Obj.TyLeVATMacDinh = Item.VAT;
			Obj.Write();
		EndIf;
	EndDo;
EndProcedure

Procedure KhoiTaoDoiTacVaP_L()
	// 1. Nhóm 1 – P&L lớn Vingroup (VinFast tai cau truc 2026, Vinhomes, Vinmec, GSM, Vinpearl...)
	DanhSachNhom1 = New Array;
	DanhSachNhom1.Add(New Structure("Code,Name", "TEST_VG_VINFAST_VN", "CTCP VinFast Việt Nam (Pháp nhân mới sau tách)"));
	DanhSachNhom1.Add(New Structure("Code,Name", "TEST_VG_VINFAST_PROD", "Công ty TNHH SX & KD VinFast (Pháp nhân cũ còn công nợ)"));
	DanhSachNhom1.Add(New Structure("Code,Name", "TEST_VG_VINFAST_TRADING", "Công ty TNHH Kinh doanh & Phân phối VinFast Trading"));
	DanhSachNhom1.Add(New Structure("Code,Name", "TEST_VG_VINHOMES", "Công ty CP Vinhomes"));
	DanhSachNhom1.Add(New Structure("Code,Name", "TEST_VG_VINPEARL", "Công ty CP Vinpearl"));
	DanhSachNhom1.Add(New Structure("Code,Name", "TEST_VG_VINWONDERS", "Công ty CP VinWonders"));
	DanhSachNhom1.Add(New Structure("Code,Name", "TEST_VG_VINMEC", "Công ty CP Bệnh viện ĐKQT Vinmec"));
	DanhSachNhom1.Add(New Structure("Code,Name", "TEST_VG_GSM", "Công ty CP Di chuyển Xanh và Thông minh GSM (Xanh SM)"));
	DanhSachNhom1.Add(New Structure("Code,Name", "TEST_VG_VGREEN", "Công ty CP Phát triển Trạm sạc Toàn cầu V-Green"));
	DanhSachNhom1.Add(New Structure("Code,Name", "TEST_VG_VINCOM_RETAIL", "Công ty CP Vincom Retail"));
	DanhSachNhom1.Add(New Structure("Code,Name", "TEST_VG_VINUNI", "Trường Đại học VinUni"));
	DanhSachNhom1.Add(New Structure("Code,Name", "TEST_VG_VINSCHOOL", "Hệ thống Giáo dục Vinschool"));

	For Each Item In DanhSachNhom1 Do
		TaoDoiTac(Item.Code, Item.Name, True, Enums.LoaiDoiTac.NoiBoVingroup);
	EndDo;

	// 2. Nhóm 2 – P&L cong nghe, dich vu vua va nho
	DanhSachNhom2 = New Array;
	DanhSachNhom2.Add(New Structure("Code,Name", "TEST_VG_VINES", "Công ty CP Giải pháp Năng lượng VinES"));
	DanhSachNhom2.Add(New Structure("Code,Name", "TEST_VG_VINBIGDATA", "Công ty CP VinBigdata"));
	DanhSachNhom2.Add(New Structure("Code,Name", "TEST_VG_VINAI", "Viện Trí tuệ Nhân tạo VinAI"));
	DanhSachNhom2.Add(New Structure("Code,Name", "TEST_VG_VINBRAIN", "Công ty CP VinBrain"));
	DanhSachNhom2.Add(New Structure("Code,Name", "TEST_VG_VINCSS", "Công ty Dịch vụ An ninh mạng VinCSS"));
	DanhSachNhom2.Add(New Structure("Code,Name", "TEST_VG_VINCLUB", "Chương trình Khách hàng thân thiết VinClub"));
	DanhSachNhom2.Add(New Structure("Code,Name", "TEST_VG_VHIZ", "Khu công nghiệp Vinhomes Industrial Zone"));
	DanhSachNhom2.Add(New Structure("Code,Name", "TEST_VG_VINROBOTICS", "Công ty Nghiên cứu và Phát triển VinRobotics"));
	DanhSachNhom2.Add(New Structure("Code,Name", "TEST_VG_VINBUS", "Công ty TNHH Vận tải Sinh thái VinBus"));

	For Each Item In DanhSachNhom2 Do
		TaoDoiTac(Item.Code, Item.Name, True, Enums.LoaiDoiTac.NoiBoVingroup);
	EndDo;

	// 3. Nhóm 3 – To chuc phi loi nhuan & Cong ty me Vingroup
	DanhSachNhom3 = New Array;
	DanhSachNhom3.Add(New Structure("Code,Name", "TEST_VG_VINFUTURE", "Quỹ VinFuture"));
	DanhSachNhom3.Add(New Structure("Code,Name", "TEST_VG_THIENTAM", "Quỹ Thiện Tâm"));
	DanhSachNhom3.Add(New Structure("Code,Name", "TEST_VG_VIC", "Tập đoàn Vingroup - Công ty CP (Công ty mẹ)"));

	For Each Item In DanhSachNhom3 Do
		TaoDoiTac(Item.Code, Item.Name, True, Enums.LoaiDoiTac.NoiBoVingroup);
	EndDo;

	// 4. ~105 Khach hang ngoai tap doan (Sellers TMDT, Nha quang cao, Doanh nghiep ngoai)
	For i = 1 To 25 Do
		Code = "TEST_KH_SELLER_" + Right("00" + String(i), 2);
		Name = "Đối tác Seller Sàn TMĐT V-App Shop " + String(i);
		TaoDoiTac(Code, Name, False, Enums.LoaiDoiTac.KhachHangNgoai);
	EndDo;

	For i = 1 To 15 Do
		Code = "TEST_KH_ADS_" + Right("00" + String(i), 2);
		Name = "Nhà quảng cáo Brand Agency Digital " + String(i);
		TaoDoiTac(Code, Name, False, Enums.LoaiDoiTac.KhachHangNgoai);
	EndDo;

	For i = 1 To 65 Do
		Code = "TEST_KH_CORP_" + Right("00" + String(i), 2);
		Name = "Khách hàng Doanh nghiệp Công nghệ Ngoài " + String(i);
		TaoDoiTac(Code, Name, False, Enums.LoaiDoiTac.KhachHangNgoai);
	EndDo;

	// 5. 20 Nha cung cap Quoc te (USD)
	DanhSachNCC_USD = New Array;
	DanhSachNCC_USD.Add(New Structure("Code,Name", "TEST_NCC_AWS", "Amazon Web Services Inc"));
	DanhSachNCC_USD.Add(New Structure("Code,Name", "TEST_NCC_MICROSOFT", "Microsoft Operations Pte Ltd"));
	DanhSachNCC_USD.Add(New Structure("Code,Name", "TEST_NCC_QUALCOMM", "Qualcomm Technologies Inc"));
	DanhSachNCC_USD.Add(New Structure("Code,Name", "TEST_NCC_GOOGLE", "Google Cloud Asia Pacific"));
	DanhSachNCC_USD.Add(New Structure("Code,Name", "TEST_NCC_ORACLE", "Oracle Corporation APAC"));
	DanhSachNCC_USD.Add(New Structure("Code,Name", "TEST_NCC_SAP", "SAP Asia Pte Ltd"));
	DanhSachNCC_USD.Add(New Structure("Code,Name", "TEST_NCC_IBM", "IBM Singapore Pte Ltd"));
	DanhSachNCC_USD.Add(New Structure("Code,Name", "TEST_NCC_CISCO", "Cisco Systems International"));
	DanhSachNCC_USD.Add(New Structure("Code,Name", "TEST_NCC_DELL", "Dell Global B.V."));
	DanhSachNCC_USD.Add(New Structure("Code,Name", "TEST_NCC_HP", "HP PPS Asia Pte Ltd"));
	DanhSachNCC_USD.Add(New Structure("Code,Name", "TEST_NCC_NVIDIA", "NVIDIA Corporation APAC"));
	DanhSachNCC_USD.Add(New Structure("Code,Name", "TEST_NCC_INTEL", "Intel Semiconductor US"));
	DanhSachNCC_USD.Add(New Structure("Code,Name", "TEST_NCC_REDHAT", "Red Hat Asia Pacific"));
	DanhSachNCC_USD.Add(New Structure("Code,Name", "TEST_NCC_VMWARE", "VMware International"));
	DanhSachNCC_USD.Add(New Structure("Code,Name", "TEST_NCC_SNOWFLAKE", "Snowflake Inc APAC"));
	DanhSachNCC_USD.Add(New Structure("Code,Name", "TEST_NCC_DATABRICKS", "Databricks Operations"));
	DanhSachNCC_USD.Add(New Structure("Code,Name", "TEST_NCC_CLOUDFLARE", "Cloudflare Network US"));
	DanhSachNCC_USD.Add(New Structure("Code,Name", "TEST_NCC_ATLASSIAN", "Atlassian Pty Ltd"));
	DanhSachNCC_USD.Add(New Structure("Code,Name", "TEST_NCC_ZOOM", "Zoom Video Communications"));
	DanhSachNCC_USD.Add(New Structure("Code,Name", "TEST_NCC_SALESFORCE", "Salesforce Tech Singapore"));

	For Each ItemUSD In DanhSachNCC_USD Do
		TaoDoiTac(ItemUSD.Code, ItemUSD.Name, False, Enums.LoaiDoiTac.NhaCungCapCloud);
	EndDo;

	// 6. ~100 Nha cung cap Trong nuoc (VND)
	For i = 1 To 100 Do
		Code = "TEST_NCC_VN_" + Right("000" + String(i), 3);
		Name = "Nhà cung cấp Dịch vụ & Hạ tầng số " + String(i);
		TaoDoiTac(Code, Name, False, Enums.LoaiDoiTac.NhaCungCap);
	EndDo;
EndProcedure

Procedure KhoiTaoHopDong(RefPN_VSF, RefVND, RefUSD)
	SelDT = Catalogs.DoiTac.Select();
	While SelDT.Next() Do
		CodeDT = SelDT.Code;
		If Left(CodeDT, 5) <> "TEST_" Then
			Continue;
		EndIf;
		
		IsUSD = (Left(CodeDT, 9) = "TEST_NCC_");
		CurrencyRef = ?(IsUSD, RefUSD, RefVND);
		
		HDCode = "HD-" + TrimAll(CodeDT) + "-2025";
		RefHD = Catalogs.HopDong.FindByCode(HDCode);
		If Not ValueIsFilled(RefHD) Then
			ObjHD = Catalogs.HopDong.CreateItem();
			ObjHD.Code = HDCode;
			ObjHD.Description = "Hợp đồng dịch vụ 2025 - " + SelDT.Description;
			ObjHD.PhapNhan = RefPN_VSF;
			ObjHD.ChuSoHuu = SelDT.Ref;
			ObjHD.DongTienThanhToan = CurrencyRef;
			ObjHD.HanThanhToanNgay = ?(SelDT.LaBenLienKet, 60, 30);
			ObjHD.GrossUpThue = False;
			ObjHD.Write();
		EndIf;
	EndDo;
EndProcedure

Procedure KhoiTaoTyGiaUSD(RefUSD)
	CurDate = '20250101';
	EndDate = '20260930';
	BaseRate = 24850;
	DayStep = 1;
	
	RecordSetFX = InformationRegisters.TyGiaHoiDoai.CreateRecordSet();
	RecordSetFX.Filter.TienTe.Set(RefUSD);
	While CurDate <= EndDate Do
		DayOffset = DayOfYear(CurDate);
		DeltaRate = (DayOffset % 70) * 11 + (DayStep % 5) * 5;
		RateVal = BaseRate + DeltaRate;
		
		NewRec = RecordSetFX.Add();
		NewRec.Period = CurDate;
		NewRec.TienTe = RefUSD;
		NewRec.TyGiaHachToan = RateVal;
		NewRec.TyGiaMua = RateVal - 20;
		NewRec.TyGiaBan = RateVal + 20;
		
		CurDate = CurDate + 86400;
		DayStep = DayStep + 1;
	EndDo;
	RecordSetFX.Write(True);
EndProcedure

Procedure TaoDoiTac(Code, Name, LaBenLienKet, LoaiDoiTac)
	RefDT = Catalogs.DoiTac.FindByCode(Code);
	If Not ValueIsFilled(RefDT) Then
		ObjDT = Catalogs.DoiTac.CreateItem();
		ObjDT.Code = Code;
		ObjDT.Description = Name;
		ObjDT.LaBenLienKet = LaBenLienKet;
		ObjDT.LoaiDoiTac = LoaiDoiTac;
		ObjDT.DaDangKyThueTrucTiep = False;
		ObjDT.Write();
	EndIf;
EndProcedure

Procedure KhoiTaoCacTaiKhoanConThieu() Export
	DanhSachTK = New Array;
	DanhSachTK.Add(New Structure("Code,Description,Type", "3313", "Phải trả người bán nước ngoài (Ngoại tệ USD)", AccountType.ActivePassive));
	DanhSachTK.Add(New Structure("Code,Description,Type", "3318", "Phải trả người bán khác", AccountType.ActivePassive));
	DanhSachTK.Add(New Structure("Code,Description,Type", "3388", "Phải trả khác (Cấn trừ bắc cầu)", AccountType.ActivePassive));
	DanhSachTK.Add(New Structure("Code,Description,Type", "641", "Chi phí bán hàng", AccountType.Active));
	
	For Each Item In DanhSachTK Do
		RefAcc = ChartsOfAccounts.HeThongTaiKhoan.FindByCode(Item.Code);
		If Not ValueIsFilled(RefAcc) Then
			ObjAcc = ChartsOfAccounts.HeThongTaiKhoan.CreateAccount();
			ObjAcc.Code = Item.Code;
			ObjAcc.Description = Item.Description;
			ObjAcc.Type = Item.Type;
			ObjAcc.Write();
			WriteLogEvent("Account.Init", EventLogLevel.Information,,, "Đã khởi tạo tài khoản mới: " + Item.Code + " - " + Item.Description);
		EndIf;
	EndDo;
EndProcedure

#EndRegion
