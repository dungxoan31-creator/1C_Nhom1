// CommonModule: GeneratorMasterDataServer
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Sinh khoi luong lon Master Data DoiTac (P&L Vingroup tai cau truc 2026, KH ngoai, NCC),
//           DuAn (4 Khoi + BO), DichVuCNTT (90+ dich vu), HopDong va TyGia

#Region PublicInterface

Procedure KhoiTaoMasterDataToanDien() Export
	QuanLyVongDoiChungTuServer.KiemTraChoPhepSinhDuLieuMau("QuanTriHeThong", "GiamDocTaiChinh_CFO");
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
	If Not ValueIsFilled(RefVND) Then
		ObjVND = Catalogs.TienTe.CreateItem();
		ObjVND.Code = "VND";
		ObjVND.Description = "Việt Nam Đồng";
		ObjVND.MaTienTe = "VND";
		ObjVND.TenDayDu = "Việt Nam Đồng";
		ObjVND.Write();
		RefVND = ObjVND.Ref;
	EndIf;
	
	RefUSD = Catalogs.TienTe.FindByCode("USD");
	If Not ValueIsFilled(RefUSD) Then
		ObjUSD = Catalogs.TienTe.CreateItem();
		ObjUSD.Code = "USD";
		ObjUSD.Description = "Đô la Mỹ";
		ObjUSD.MaTienTe = "USD";
		ObjUSD.TenDayDu = "Đô la Mỹ";
		ObjUSD.Write();
		RefUSD = ObjUSD.Ref;
	EndIf;

	Try
		BeginTransaction();
		// 0. Don dep du lieu TEST cu neu co
	// Seed uses a fresh disposable clone; existing records are retained.

		// 0.1. Khoi tao cac tai khoan ke toan con thieu (3313, 3318, 3388, 641)
		KhoiTaoHeThongTaiKhoanTT200();

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
	Q_TK = New Query("SELECT COUNT(*) AS Cnt FROM ChartOfAccounts.HeThongTaiKhoan");
	CntTK = Q_TK.Execute().Unload()[0].Cnt;

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
	
	If CntTK >= 240 And CntDT >= 200 And CntVG >= 15 And CntHD >= 200 And CntDA >= 25 And CntDV >= 70 And CntTG >= 600 Then
		Msg = StrTemplate("MASTER_DATA_VERIFY_SUCCESS: TaiKhoanTT200=%1, DoiTac=%2, DoiTacVingroup=%3, HopDong=%4, DuAnKhoi=%5, DichVuCNTT=%6, TyGiaHoiDoai=%7", 
			CntTK, CntDT, CntVG, CntHD, CntDA, CntDV, CntTG);
		WriteLogEvent("MasterData.Verify", EventLogLevel.Information,,, Msg);
	Else
		Msg = StrTemplate("MASTER_DATA_VERIFY_FAILED: TaiKhoanTT200=%1, DoiTac=%2, DoiTacVingroup=%3, HopDong=%4, DuAnKhoi=%5, DichVuCNTT=%6, TyGiaHoiDoai=%7", 
			CntTK, CntDT, CntVG, CntHD, CntDA, CntDV, CntTG);
		WriteLogEvent("MasterData.Verify", EventLogLevel.Error,,, Msg);
	EndIf;
EndProcedure

Procedure BaoCaoThongKeTaiKhoan(FilePath) Export
	Q = New Query;
	Q.Text = 
	"SELECT
	|	COUNT(*) AS TotalCount,
	|	SUM(CASE WHEN TK.Parent = VALUE(ChartOfAccounts.HeThongTaiKhoan.EmptyRef) THEN 1 ELSE 0 END) AS Level1Count,
	|	SUM(CASE WHEN TK.Parent <> VALUE(ChartOfAccounts.HeThongTaiKhoan.EmptyRef) AND TK.Parent.Parent = VALUE(ChartOfAccounts.HeThongTaiKhoan.EmptyRef) THEN 1 ELSE 0 END) AS Level2Count,
	|	SUM(CASE WHEN TK.Parent.Parent <> VALUE(ChartOfAccounts.HeThongTaiKhoan.EmptyRef) THEN 1 ELSE 0 END) AS Level3Count
	|FROM
	|	ChartOfAccounts.HeThongTaiKhoan AS TK";
	Res = Q.Execute().Unload();
	
	Total = ?(Res.Count() > 0, Res[0].TotalCount, 0);
	L1 = ?(Res.Count() > 0, Res[0].Level1Count, 0);
	L2 = ?(Res.Count() > 0, Res[0].Level2Count, 0);
	L3 = ?(Res.Count() > 0, Res[0].Level3Count, 0);
	
	Writer = New TextWriter(FilePath, TextEncoding.UTF8);
	Writer.WriteLine(StrTemplate("TOTAL=%1,L1=%2,L2=%3,L3=%4", Total, L1, L2, L3));
	
	KeyCodes = "1121,1122,1311,1312,1331,3311,3312,3313,3318,33311,33318,3338,5113,627,6427,000";
	CodeArr = StrSplit(KeyCodes, ",");
	For Each CodeItem In CodeArr Do
		RefAcc = ChartsOfAccounts.HeThongTaiKhoan.FindByCode(CodeItem);
		Writer.WriteLine(StrTemplate("ACCOUNT:%1;EXISTS=%2;DESC=%3;PARENT=%4", 
			CodeItem, ValueIsFilled(RefAcc), ?(ValueIsFilled(RefAcc), RefAcc.Description, ""), ?(ValueIsFilled(RefAcc) And ValueIsFilled(RefAcc.Parent), RefAcc.Parent.Code, "")));
	EndDo;
	Writer.Close();
EndProcedure

#EndRegion

#Region InternalProcedures

// Bulk cleanup removed: restore a fresh UAT clone instead.

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
		
		// Chọn đồng tiền theo loại đối tác, không suy ra từ tiền tố mã.
		// TEST_NCC_VN_xxx là nhà cung cấp trong nước và phải dùng VND.
		IsUSD = (SelDT.LoaiDoiTac = Enums.LoaiDoiTac.NhaCungCapCloud);
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
		Else
			// Các hợp đồng TEST_ đã được seed bằng quy tắc tiền tệ cũ cần được đồng bộ.
			ObjHD = RefHD.GetObject();
			If ObjHD.DongTienThanhToan <> CurrencyRef Then
				ObjHD.DongTienThanhToan = CurrencyRef;
				ObjHD.Write();
			EndIf;
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
	KhoiTaoHeThongTaiKhoanTT200();
EndProcedure

#EndRegion

#Region ChartOfAccountsTT200

// Khoi tao he thong tai khoan ke toan theo TT 200/2014/TT-BTC
Procedure KhoiTaoHeThongTaiKhoanTT200() Export
	QuanLyVongDoiChungTuServer.KiemTraChoPhepSinhDuLieuMau("QuanTriHeThong", "GiamDocTaiChinh_CFO");
	
	DS1 = New Array;
	NapDanhSachTaiKhoanCap1(DS1);
	GhiDanhSachTaiKhoan(DS1);
	
	DS2 = New Array;
	NapDanhSachTaiKhoanCap2(DS2);
	GhiDanhSachTaiKhoan(DS2);
	
	DS3 = New Array;
	NapDanhSachTaiKhoanCap3(DS3);
	GhiDanhSachTaiKhoan(DS3);
	
	WriteLogEvent("Account.Init", EventLogLevel.Information,,, "Khởi tạo thành công 243 tài khoản kế toán theo TT 200/2014/TT-BTC!");
EndProcedure

Procedure ThemTK(DS, Code, Name, TinhChat, ParentCode = "")
	DS.Add(New Structure("Code,Name,Type,ParentCode", Code, Name, TinhChat, ParentCode));
EndProcedure

Procedure GhiDanhSachTaiKhoan(DS)
	For Each Item In DS Do
		RefAcc = ChartsOfAccounts.HeThongTaiKhoan.FindByCode(Item.Code);
		If ValueIsFilled(RefAcc) Then
			ObjAcc = RefAcc.GetObject();
		Else
			ObjAcc = ChartsOfAccounts.HeThongTaiKhoan.CreateAccount();
			ObjAcc.Code = Item.Code;
		EndIf;
		ObjAcc.Description = Item.Name;
		If Item.Type = "Active" Then
			ObjAcc.Type = AccountType.Active;
		ElsIf Item.Type = "Passive" Then
			ObjAcc.Type = AccountType.Passive;
		Else
			ObjAcc.Type = AccountType.ActivePassive;
		EndIf;
		ObjAcc.MaLogic = Item.Code;
		ObjAcc.TenTaiKhoan = Item.Name;
		ObjAcc.TinhChat = Item.Type;
		If ValueIsFilled(Item.ParentCode) Then
			RefParent = ChartsOfAccounts.HeThongTaiKhoan.FindByCode(Item.ParentCode);
			If ValueIsFilled(RefParent) Then
				ObjAcc.Parent = RefParent;
			EndIf;
		Else
			ObjAcc.Parent = Undefined;
		EndIf;
		ObjAcc.Write();
	EndDo;
EndProcedure

Procedure NapDanhSachTaiKhoanCap1(DS)
	ThemTK(DS, "000", "Tài khoản đối ứng số dư ban đầu", "ActivePassive");
	ThemTK(DS, "111", "Tiền mặt", "Active");
	ThemTK(DS, "112", "Tiền gửi Ngân hàng", "Active");
	ThemTK(DS, "113", "Tiền đang chuyển", "Active");
	ThemTK(DS, "121", "Chứng khoán kinh doanh", "Active");
	ThemTK(DS, "128", "Đầu tư nắm giữ đến ngày đáo hạn", "Active");
	ThemTK(DS, "131", "Phải thu của khách hàng", "ActivePassive");
	ThemTK(DS, "133", "Thuế GTGT được khấu trừ", "Active");
	ThemTK(DS, "136", "Phải thu nội bộ", "ActivePassive");
	ThemTK(DS, "138", "Phải thu khác", "ActivePassive");
	ThemTK(DS, "141", "Tạm ứng", "Active");
	ThemTK(DS, "151", "Hàng mua đang đi đường", "Active");
	ThemTK(DS, "152", "Nguyên liệu, vật liệu", "Active");
	ThemTK(DS, "153", "Công cụ, dụng cụ", "Active");
	ThemTK(DS, "154", "Chi phí sản xuất, kinh doanh dở dang", "Active");
	ThemTK(DS, "155", "Thành phẩm", "Active");
	ThemTK(DS, "156", "Hàng hóa", "Active");
	ThemTK(DS, "157", "Hàng gửi đi bán", "Active");
	ThemTK(DS, "158", "Hàng hoá kho bảo thuế", "Active");
	ThemTK(DS, "161", "Chi sự nghiệp", "Active");
	ThemTK(DS, "171", "Giao dịch mua bán lại trái phiếu chính phủ", "Active");
	ThemTK(DS, "211", "Tài sản cố định hữu hình", "Active");
	ThemTK(DS, "212", "Tài sản cố định thuê tài chính", "Active");
	ThemTK(DS, "213", "Tài sản cố định vô hình", "Active");
	ThemTK(DS, "214", "Hao mòn tài sản cố định", "Passive");
	ThemTK(DS, "217", "Bất động sản đầu tư", "Active");
	ThemTK(DS, "221", "Đầu tư vào công ty con", "Active");
	ThemTK(DS, "222", "Đầu tư vào công ty liên doanh, liên kết", "Active");
	ThemTK(DS, "228", "Đầu tư khác", "Active");
	ThemTK(DS, "229", "Dự phòng tổn thất tài sản", "Passive");
	ThemTK(DS, "241", "Xây dựng cơ bản dở dang", "Active");
	ThemTK(DS, "242", "Chi phí trả trước", "Active");
	ThemTK(DS, "243", "Tài sản thuế thu nhập hoãn lại", "Active");
	ThemTK(DS, "244", "Cầm cố, thế chấp, ký quỹ, ký cược", "Active");
	ThemTK(DS, "331", "Phải trả cho người bán", "ActivePassive");
	ThemTK(DS, "333", "Thuế và các khoản phải nộp Nhà nước", "ActivePassive");
	ThemTK(DS, "334", "Phải trả người lao động", "ActivePassive");
	ThemTK(DS, "335", "Chi phí phải trả", "Passive");
	ThemTK(DS, "336", "Phải trả nội bộ", "ActivePassive");
	ThemTK(DS, "337", "Thanh toán theo tiến độ kế hoạch hợp đồng xây dựng", "Passive");
	ThemTK(DS, "338", "Phải trả, phải nộp khác", "ActivePassive");
	ThemTK(DS, "341", "Vay và nợ thuê tài chính", "Passive");
	ThemTK(DS, "343", "Trái phiếu phát hành", "Passive");
	ThemTK(DS, "344", "Nhận ký quỹ, ký cược", "Passive");
	ThemTK(DS, "347", "Thuế thu nhập hoãn lại phải trả", "Passive");
	ThemTK(DS, "352", "Dự phòng phải trả", "Passive");
	ThemTK(DS, "353", "Quỹ khen thưởng phúc lợi", "Passive");
	ThemTK(DS, "356", "Quỹ phát triển khoa học và công nghệ", "Passive");
	ThemTK(DS, "357", "Quỹ bình ổn giá", "Passive");
	ThemTK(DS, "411", "Vốn đầu tư của chủ sở hữu", "Passive");
	ThemTK(DS, "412", "Chênh lệch đánh giá lại tài sản", "ActivePassive");
	ThemTK(DS, "413", "Chênh lệch tỷ giá hối đoái", "ActivePassive");
	ThemTK(DS, "414", "Quỹ đầu tư phát triển", "Passive");
	ThemTK(DS, "417", "Quỹ hỗ trợ sắp xếp doanh nghiệp", "Passive");
	ThemTK(DS, "418", "Các quỹ khác thuộc vốn chủ sở hữu", "Passive");
	ThemTK(DS, "419", "Cổ phiếu quỹ", "Active");
	ThemTK(DS, "421", "Lợi nhuận sau thuế chưa phân phối", "ActivePassive");
	ThemTK(DS, "441", "Nguồn vốn đầu tư xây dựng cơ bản", "Passive");
	ThemTK(DS, "461", "Nguồn kinh phí sự nghiệp", "Passive");
	ThemTK(DS, "466", "Nguồn kinh phí đã hình thành TSCĐ", "Passive");
	ThemTK(DS, "511", "Doanh thu bán hàng và cung cấp dịch vụ", "Passive");
	ThemTK(DS, "515", "Doanh thu hoạt động tài chính", "Passive");
	ThemTK(DS, "521", "Các khoản giảm trừ doanh thu", "Active");
	ThemTK(DS, "611", "Mua hàng", "Active");
	ThemTK(DS, "621", "Chi phí nguyên liệu, vật liệu trực tiếp", "Active");
	ThemTK(DS, "622", "Chi phí nhân công trực tiếp", "Active");
	ThemTK(DS, "623", "Chi phí sử dụng máy thi công", "Active");
	ThemTK(DS, "627", "Chi phí sản xuất chung", "Active");
	ThemTK(DS, "631", "Giá thành sản xuất", "Active");
	ThemTK(DS, "632", "Giá vốn hàng bán", "Active");
	ThemTK(DS, "635", "Chi phí tài chính", "Active");
	ThemTK(DS, "641", "Chi phí bán hàng", "Active");
	ThemTK(DS, "642", "Chi phí quản lý doanh nghiệp", "Active");
	ThemTK(DS, "711", "Thu nhập khác", "Passive");
	ThemTK(DS, "811", "Chi phí khác", "Active");
	ThemTK(DS, "821", "Chi phí thuế thu nhập doanh nghiệp", "Active");
	ThemTK(DS, "911", "Xác định kết quả kinh doanh", "ActivePassive");
EndProcedure

Procedure NapDanhSachTaiKhoanCap2(DS)
	ThemTK(DS, "1111", "Tiền Việt Nam", "Active", "111");
	ThemTK(DS, "1112", "Ngoại tệ", "Active", "111");
	ThemTK(DS, "1113", "Vàng tiền tệ", "Active", "111");
	ThemTK(DS, "1121", "Tiền Việt Nam", "Active", "112");
	ThemTK(DS, "1122", "Ngoại tệ", "Active", "112");
	ThemTK(DS, "1123", "Vàng tiền tệ", "Active", "112");
	ThemTK(DS, "1131", "Tiền Việt Nam", "Active", "113");
	ThemTK(DS, "1132", "Ngoại tệ", "Active", "113");
	ThemTK(DS, "1211", "Cổ phiếu", "Active", "121");
	ThemTK(DS, "1212", "Trái phiếu", "Active", "121");
	ThemTK(DS, "1218", "Chứng khoán và công cụ tài chính khác", "Active", "121");
	ThemTK(DS, "1281", "Tiền gửi có kỳ hạn", "Active", "128");
	ThemTK(DS, "1282", "Trái phiếu", "Active", "128");
	ThemTK(DS, "1283", "Cho vay", "Active", "128");
	ThemTK(DS, "1288", "Các khoản đầu tư khác nắm giữ đến ngày đáo hạn", "Active", "128");
	ThemTK(DS, "1311", "Phải thu của khách hàng bên ngoài", "ActivePassive", "131");
	ThemTK(DS, "1312", "Phải thu của khách hàng nội bộ Vingroup", "ActivePassive", "131");
	ThemTK(DS, "1331", "Thuế GTGT được khấu trừ của hàng hóa, dịch vụ", "Active", "133");
	ThemTK(DS, "1332", "Thuế GTGT được khấu trừ của TSCĐ", "Active", "133");
	ThemTK(DS, "1361", "Vốn kinh doanh ở các đơn vị trực thuộc", "ActivePassive", "136");
	ThemTK(DS, "1362", "Phải thu nội bộ về chênh lệch tỷ giá", "ActivePassive", "136");
	ThemTK(DS, "1363", "Phải thu nội bộ về chi phí đi vay đủ điều kiện được vốn hoá", "ActivePassive", "136");
	ThemTK(DS, "1368", "Phải thu nội bộ khác", "ActivePassive", "136");
	ThemTK(DS, "1381", "Tài sản thiếu chờ xử lý", "ActivePassive", "138");
	ThemTK(DS, "1385", "Phải thu về cổ phần hoá", "ActivePassive", "138");
	ThemTK(DS, "1388", "Phải thu khác", "ActivePassive", "138");
	ThemTK(DS, "1531", "Công cụ, dụng cụ", "Active", "153");
	ThemTK(DS, "1532", "Bao bì luân chuyển", "Active", "153");
	ThemTK(DS, "1533", "Đồ dùng cho thuê", "Active", "153");
	ThemTK(DS, "1534", "Thiết bị, phụ tùng thay thế", "Active", "153");
	ThemTK(DS, "1551", "Thành phẩm nhập kho", "Active", "155");
	ThemTK(DS, "1557", "Thành phẩm bất động sản", "Active", "155");
	ThemTK(DS, "1561", "Giá mua hàng hóa", "Active", "156");
	ThemTK(DS, "1562", "Chi phí thu mua hàng hóa", "Active", "156");
	ThemTK(DS, "1567", "Hàng hóa bất động sản", "Active", "156");
	ThemTK(DS, "1611", "Chi sự nghiệp năm trước", "Active", "161");
	ThemTK(DS, "1612", "Chi sự nghiệp năm nay", "Active", "161");
	ThemTK(DS, "2111", "Nhà cửa, vật kiến trúc", "Active", "211");
	ThemTK(DS, "2112", "Máy móc, thiết bị", "Active", "211");
	ThemTK(DS, "2113", "Phương tiện vận tải, truyền dẫn", "Active", "211");
	ThemTK(DS, "2114", "Thiết bị, dụng cụ quản lý", "Active", "211");
	ThemTK(DS, "2115", "Cây lâu năm, súc vật làm việc và cho sản phẩm", "Active", "211");
	ThemTK(DS, "2118", "TSCĐ khác", "Active", "211");
	ThemTK(DS, "2121", "TSCĐ hữu hình thuê tài chính.", "Active", "212");
	ThemTK(DS, "2122", "TSCĐ vô hình thuê tài chính.", "Active", "212");
	ThemTK(DS, "2131", "Quyền sử dụng đất", "Active", "213");
	ThemTK(DS, "2132", "Quyền phát hành", "Active", "213");
	ThemTK(DS, "2133", "Bản quyền, bằng sáng chế", "Active", "213");
	ThemTK(DS, "2134", "Nhãn hiệu, tên thương mại", "Active", "213");
	ThemTK(DS, "2135", "Chương trình phần mềm", "Active", "213");
	ThemTK(DS, "2136", "Giấy phép và giấy phép nhượng quyền", "Active", "213");
	ThemTK(DS, "2138", "TSCĐ vô hình khác", "Active", "213");
	ThemTK(DS, "2141", "Hao mòn TSCĐ hữu hình", "Passive", "214");
	ThemTK(DS, "2142", "Hao mòn TSCĐ thuê tài chính", "Passive", "214");
	ThemTK(DS, "2143", "Hao mòn TSCĐ vô hình", "Passive", "214");
	ThemTK(DS, "2147", "Hao mòn bất động sản đầu tư", "Passive", "214");
	ThemTK(DS, "2281", "Đầu tư góp vốn vào đơn vị khác", "Active", "228");
	ThemTK(DS, "2288", "Đầu tư khác", "Active", "228");
	ThemTK(DS, "2291", "Dự phòng giảm giá chứng khoán kinh doanh", "Passive", "229");
	ThemTK(DS, "2292", "Dự phòng tổn thất đầu tư vào đơn vị khác", "Passive", "229");
	ThemTK(DS, "2293", "Dự phòng phải thu khó đòi", "Passive", "229");
	ThemTK(DS, "2294", "Dự phòng giảm giá hàng tồn kho", "Passive", "229");
	ThemTK(DS, "2411", "Mua sắm TSCĐ", "Active", "241");
	ThemTK(DS, "2412", "Xây dựng cơ bản", "Active", "241");
	ThemTK(DS, "2413", "Sửa chữa lớn TSCĐ", "Active", "241");
	ThemTK(DS, "3311", "Phải trả cho người bán bên ngoài", "ActivePassive", "331");
	ThemTK(DS, "3312", "Phải trả cho người bán nội bộ Vingroup", "ActivePassive", "331");
	ThemTK(DS, "3313", "Phải trả người bán nước ngoài (Ngoại tệ USD)", "ActivePassive", "331");
	ThemTK(DS, "3318", "Phải trả người bán khác", "ActivePassive", "331");
	ThemTK(DS, "3331", "Thuế giá trị gia tăng phải nộp", "Passive", "333");
	ThemTK(DS, "3332", "Thuế tiêu thụ đặc biệt", "Passive", "333");
	ThemTK(DS, "3333", "Thuế xuất, nhập khẩu", "Passive", "333");
	ThemTK(DS, "3334", "Thuế thu nhập doanh nghiệp", "Passive", "333");
	ThemTK(DS, "3335", "Thuế thu nhập cá nhân", "Passive", "333");
	ThemTK(DS, "3336", "Thuế tài nguyên", "Passive", "333");
	ThemTK(DS, "3337", "Thuế nhà đất, tiền thuê đất", "Passive", "333");
	ThemTK(DS, "3338", "Thuế bảo vệ môi trường và các loại thuế khác", "Passive", "333");
	ThemTK(DS, "3339", "Phí, lệ phí và các khoản phải nộp khác", "Passive", "333");
	ThemTK(DS, "3341", "Phải trả công nhân viên", "ActivePassive", "334");
	ThemTK(DS, "3348", "Phải trả người lao động khác", "ActivePassive", "334");
	ThemTK(DS, "3361", "Phải trả nội bộ về vốn kinh doanh", "ActivePassive", "336");
	ThemTK(DS, "3362", "Phải trả nội bộ về chênh lệch tỷ giá", "ActivePassive", "336");
	ThemTK(DS, "3363", "Phải trả nội bộ về chi phí đi vay đủ điều kiện được vốn hoá", "ActivePassive", "336");
	ThemTK(DS, "3368", "Phải trả nội bộ khác", "ActivePassive", "336");
	ThemTK(DS, "3381", "Tài sản thừa chờ giải quyết", "ActivePassive", "338");
	ThemTK(DS, "3382", "Kinh phí công đoàn", "ActivePassive", "338");
	ThemTK(DS, "3383", "Bảo hiểm xã hội", "ActivePassive", "338");
	ThemTK(DS, "3384", "Bảo hiểm y tế", "ActivePassive", "338");
	ThemTK(DS, "3385", "Phải trả về cổ phần hoá", "ActivePassive", "338");
	ThemTK(DS, "3386", "Bảo hiểm thất nghiệp", "ActivePassive", "338");
	ThemTK(DS, "3387", "Doanh thu chưa thực hiện", "ActivePassive", "338");
	ThemTK(DS, "3388", "Phải trả, phải nộp khác", "ActivePassive", "338");
	ThemTK(DS, "3411", "Các khoản đi vay", "Passive", "341");
	ThemTK(DS, "3412", "Nợ thuê tài chính", "Passive", "341");
	ThemTK(DS, "3431", "Trái phiếu thường", "Passive", "343");
	ThemTK(DS, "3432", "Trái phiếu chuyển đổi", "Passive", "343");
	ThemTK(DS, "3521", "Dự phòng bảo hành sản phẩm hàng hóa", "Passive", "352");
	ThemTK(DS, "3522", "Dự phòng bảo hành công trình xây dựng", "Passive", "352");
	ThemTK(DS, "3523", "Dự phòng tái cơ cấu doanh nghiệp", "Passive", "352");
	ThemTK(DS, "3524", "Dự phòng phải trả khác", "Passive", "352");
	ThemTK(DS, "3531", "Quỹ khen thưởng", "Passive", "353");
	ThemTK(DS, "3532", "Quỹ phúc lợi", "Passive", "353");
	ThemTK(DS, "3533", "Quỹ phúc lợi đã hình thành TSCĐ", "Passive", "353");
	ThemTK(DS, "3534", "Quỹ thưởng ban quản lý điều hành công ty", "Passive", "353");
	ThemTK(DS, "3561", "Quỹ phát triển khoa học và công nghệ", "Passive", "356");
	ThemTK(DS, "3562", "Quỹ phát triển khoa học và công nghệ đã hình thành TSCĐ", "Passive", "356");
	ThemTK(DS, "4111", "Vốn góp của chủ sở hữu", "Passive", "411");
	ThemTK(DS, "4112", "Thặng dư vốn cổ phần", "Passive", "411");
	ThemTK(DS, "4113", "Quyền chọn chuyển đổi trái phiếu", "Passive", "411");
	ThemTK(DS, "4118", "Vốn khác", "Passive", "411");
	ThemTK(DS, "4131", "Chênh lệch tỷ giá do đánh giá lại các khoản mục tiền tệ có gốc ngoại tệ", "ActivePassive", "413");
	ThemTK(DS, "4132", "Chênh lệch tỷ giá hối đoái trong giai đoạn trước hoạt động", "ActivePassive", "413");
	ThemTK(DS, "4211", "Lợi nhuận sau thuế chưa phân phối năm trước", "ActivePassive", "421");
	ThemTK(DS, "4212", "Lợi nhuận sau thuế chưa phân phối năm nay", "ActivePassive", "421");
	ThemTK(DS, "4611", "Nguồn kinh phí sự nghiệp năm trước", "Passive", "461");
	ThemTK(DS, "4612", "Nguồn kinh phí sự nghiệp năm nay", "Passive", "461");
	ThemTK(DS, "5111", "Doanh thu bán hàng hóa", "Passive", "511");
	ThemTK(DS, "5112", "Doanh thu bán các thành phẩm", "Passive", "511");
	ThemTK(DS, "5113", "Doanh thu cung cấp dịch vụ", "Passive", "511");
	ThemTK(DS, "5114", "Doanh thu trợ cấp, trợ giá", "Passive", "511");
	ThemTK(DS, "5117", "Doanh thu kinh doanh bất động sản đầu tư", "Passive", "511");
	ThemTK(DS, "5118", "Doanh thu khác", "Passive", "511");
	ThemTK(DS, "5211", "Chiết khấu thương mại", "Active", "521");
	ThemTK(DS, "5212", "Hàng bán bị trả lại", "Active", "521");
	ThemTK(DS, "5213", "Giảm giá hàng bán", "Active", "521");
	ThemTK(DS, "6111", "Mua nguyên liệu, vật liệu", "Active", "611");
	ThemTK(DS, "6112", "Mua hàng hóa", "Active", "611");
	ThemTK(DS, "6231", "Chi phí nhân công", "Active", "623");
	ThemTK(DS, "6232", "Chi phí nguyên, vật liệu", "Active", "623");
	ThemTK(DS, "6233", "Chi phí dụng cụ sản xuất", "Active", "623");
	ThemTK(DS, "6234", "Chi phí khấu hao máy thi công", "Active", "623");
	ThemTK(DS, "6237", "Chi phí dịch vụ mua ngoài", "Active", "623");
	ThemTK(DS, "6238", "Chi phí bằng tiền khác", "Active", "623");
	ThemTK(DS, "6271", "Chi phí nhân viên phân xưởng", "Active", "627");
	ThemTK(DS, "6272", "Chi phí nguyên, vật liệu", "Active", "627");
	ThemTK(DS, "6273", "Chi phí dụng cụ sản xuất", "Active", "627");
	ThemTK(DS, "6274", "Chi phí khấu hao TSCĐ", "Active", "627");
	ThemTK(DS, "6277", "Chi phí dịch vụ mua ngoài", "Active", "627");
	ThemTK(DS, "6278", "Chi phí bằng tiền khác", "Active", "627");
	ThemTK(DS, "6411", "Chi phí nhân viên", "Active", "641");
	ThemTK(DS, "6412", "Chi phí nguyên vật liệu, bao bì", "Active", "641");
	ThemTK(DS, "6413", "Chi phí dụng cụ, đồ dùng", "Active", "641");
	ThemTK(DS, "6414", "Chi phí khấu hao TSCĐ", "Active", "641");
	ThemTK(DS, "6415", "Chi phí bảo hành", "Active", "641");
	ThemTK(DS, "6417", "Chi phí dịch vụ mua ngoài", "Active", "641");
	ThemTK(DS, "6418", "Chi phí bằng tiền khác", "Active", "641");
	ThemTK(DS, "6421", "Chi phí nhân viên quản lý", "Active", "642");
	ThemTK(DS, "6422", "Chi phí vật liệu quản lý", "Active", "642");
	ThemTK(DS, "6423", "Chi phí đồ dùng văn phòng", "Active", "642");
	ThemTK(DS, "6424", "Chi phí khấu hao TSCĐ", "Active", "642");
	ThemTK(DS, "6425", "Thuế, phí và lệ phí", "Active", "642");
	ThemTK(DS, "6426", "Chi phí dự phòng", "Active", "642");
	ThemTK(DS, "6427", "Chi phí dịch vụ mua ngoài", "Active", "642");
	ThemTK(DS, "6428", "Chi phí bằng tiền khác", "Active", "642");
	ThemTK(DS, "8211", "Chi phí thuế TNDN hiện hành", "Active", "821");
	ThemTK(DS, "8212", "Chi phí thuế TNDN hoãn lại", "Active", "821");
EndProcedure

Procedure NapDanhSachTaiKhoanCap3(DS)
	ThemTK(DS, "33311", "Thuế GTGT đầu ra", "Passive", "3331");
	ThemTK(DS, "33312", "Thuế GTGT hàng nhập khẩu", "Passive", "3331");
	ThemTK(DS, "33318", "Thuế GTGT nhà thầu nước ngoài (FCT VAT)", "Passive", "3331");
	ThemTK(DS, "33381", "Thuế bảo vệ môi trường", "Passive", "3338");
	ThemTK(DS, "33382", "Các loại thuế khác", "Passive", "3338");
	ThemTK(DS, "34311", "Mệnh giá", "Passive", "3431");
	ThemTK(DS, "34312", "Chiết khấu trái phiếu", "Passive", "3431");
	ThemTK(DS, "34313", "Phụ trội trái phiếu", "Passive", "3431");
	ThemTK(DS, "41111", "Cổ phiếu phổ thông có quyền biểu quyết", "Passive", "4111");
	ThemTK(DS, "41112", "Cổ phiếu ưu đãi", "Passive", "4111");
EndProcedure

#EndRegion
