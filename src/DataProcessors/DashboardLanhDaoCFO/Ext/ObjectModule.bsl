// DataProcessor: DashboardLanhDaoCFO
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Ban lam viec Lanh dao cap cao (Executive Dashboard CFO & Ban Dieu hanh VSF)
//           - Real-time Business Intelligence: Doanh thu, Chi phi 4 Khoi kinh doanh & Khoi BO
//           - Chi so Dong tien & Cong no AR/AP, Net Working Capital
//           - So du tien mat tai Techcombank VND, Vietcombank USD, VPBank Virtual Account
//           - Chi so tai chinh: DSO, DPO, Ty le tiet kiem thanh khoan qua Netting

#Region PublicInterface

// Ham xuat so lieu tong hop Dashboard cho Giam doc Tai chinh CFO va Ban Dieu hanh
// Tham so:
//   ThoiDiem - Date, Undefined - Thoi diem chot so lieu bao cao (Mac dinh la hien tai)
// Tra ve:
//   Structure chua day du cac nhom chi so tai chinh & van hanh
Function LaySoLieuDashboard(Val ThoiDiem = Undefined) Export
	If Not ValueIsFilled(ThoiDiem) Then
		ThoiDiem = Date(2026, 9, 30, 23, 59, 59); // Dong bo ngay chot thong nhat toan he thong
	EndIf;
	
	KetQua = New Structure;
	KetQua.Insert("ThoiDiem", ThoiDiem);
	KetQua.Insert("ThoiDiemBaoCao", Format(ThoiDiem, "DF=""dd/MM/yyyy HH:mm:ss"""));
	
	// 1. Tong hop Doanh thu & Chi phi 4 Khoi kinh doanh VSF va Khoi BO
	SoLieuKhoi = TongHopKinhDoanhTheoKhoi(ThoiDiem);
	KetQua.Insert("CacKhoiKinhDoanh", SoLieuKhoi.DanhSachKhoi);
	KetQua.Insert("TongHopKinhDoanh", SoLieuKhoi.TongHop);
	
	// 2. Tong hop So du cong no AR (TK 131) va AP (TK 331)
	SoLieuCongNo = TongHopCongNo(ThoiDiem);
	KetQua.Insert("CongNo", SoLieuCongNo);
	
	// 3. Tong hop Dong tien cac tai khoan ngan hang tu so DongTien
	SoLieuDongTien = TongHopDongTienNganHang(ThoiDiem);
	KetQua.Insert("DongTien", SoLieuDongTien);
	
	// 4. Tinh toan cac chi so tai chinh: DSO, DPO, Ty le tiet kiem thanh khoan Netting
	SoLieuChiSo = TinhToanChiSoTaiChinh(ThoiDiem, SoLieuKhoi.TongHop.TongDoanhThu, SoLieuKhoi.TongHop.TongChiPhi, SoLieuCongNo.AR.TongAR, SoLieuCongNo.AP.TongAP);
	KetQua.Insert("ChiSoTaiChinh", SoLieuChiSo);
	
	Return KetQua;
EndFunction

// Ham tao bao cao tong hop dang Text dinh dang truc quan cho CFO
Function LayBaoCaoTongHop(Val ThoiDiem = Undefined) Export
	Data = LaySoLieuDashboard(ThoiDiem);
	
	Lines = New Array;
	Lines.Add("==================================================================================");
	Lines.Add("       BÀN LÀM VIỆC CHỈ HUY TÀI CHÍNH CFO - VINSMART FUTURE (VSF)                ");
	Lines.Add("       Thời điểm báo cáo: " + Data.ThoiDiemBaoCao);
	Lines.Add("==================================================================================");
	Lines.Add("");
	Lines.Add("I. KẾT QUẢ KINH DOANH THEO 4 KHỐI & KHỐI BO:");
	Lines.Add(StrTemplate("   Tổng Doanh thu:   %1 VND", Format(Data.TongHopKinhDoanh.TongDoanhThu, "NFD=0; NGS=.")));
	Lines.Add(StrTemplate("   Tổng Chi phí:     %1 VND", Format(Data.TongHopKinhDoanh.TongChiPhi, "NFD=0; NGS=.")));
	Lines.Add(StrTemplate("   Lợi nhuận gộp:    %1 VND (Tỷ suất: %2%)", 
		Format(Data.TongHopKinhDoanh.LoiNhuanTruocThue, "NFD=0; NGS=."), Data.TongHopKinhDoanh.TySuatLoiNhuanRong));
	Lines.Add("   -------------------------------------------------------------------------------");
	
	For Each Khoi In Data.CacKhoiKinhDoanh Do
		Lines.Add(StrTemplate("   [*] %1 (%2 dự án):", Khoi.TenKhoi, Khoi.SoLuongDuAn));
		Lines.Add(StrTemplate("       - Doanh thu:   %1 VND", Format(Khoi.DoanhThu, "NFD=0; NGS=.")));
		Lines.Add(StrTemplate("       - Chi phí:     %1 VND", Format(Khoi.ChiPhi, "NFD=0; NGS=.")));
		Lines.Add(StrTemplate("       - Lợi nhuận:   %1 VND (Biên LN: %2%)", 
			Format(Khoi.LoiNhuanGop, "NFD=0; NGS=."), Khoi.TySuatLoiNhuan));
	EndDo;
	
	Lines.Add("");
	Lines.Add("II. TỔNG HỢP CÔNG NỢ PHẢI THU (AR) & PHẢI TRẢ (AP):");
	Lines.Add(StrTemplate("   1. Tổng Phải thu AR (TK 131): %1 VND", Format(Data.CongNo.AR.TongAR, "NFD=0; NGS=.")));
	Lines.Add(StrTemplate("      + Khách ngoài (TK 1311):   %1 VND", Format(Data.CongNo.AR.AR_KhachNgoai, "NFD=0; NGS=.")));
	Lines.Add(StrTemplate("      + Nội bộ Vingroup (TK 1312):%1 VND (Tỷ lệ: %2%)", 
		Format(Data.CongNo.AR.AR_NoiBo, "NFD=0; NGS=."), Data.CongNo.AR.TyLeNoiBoAR));
	Lines.Add(StrTemplate("   2. Tổng Phải trả AP (TK 331): %1 VND", Format(Data.CongNo.AP.TongAP, "NFD=0; NGS=.")));
	Lines.Add(StrTemplate("      + Nhà cung cấp ngoài (3311):%1 VND", Format(Data.CongNo.AP.AP_NhaCungCapNgoai, "NFD=0; NGS=.")));
	Lines.Add(StrTemplate("      + Nội bộ Vingroup (TK 3312):%1 VND (Tỷ lệ: %2%)", 
		Format(Data.CongNo.AP.AP_NoiBo, "NFD=0; NGS=."), Data.CongNo.AP.TyLeNoiBoAP));
	Lines.Add(StrTemplate("   3. Vốn lưu động ròng công nợ: %1 VND", Format(Data.CongNo.NetWorkingCapital, "NFD=0; NGS=.")));
	
	Lines.Add("");
	Lines.Add("III. DÒNG TIỀN VÀ SỐ DƯ TÀI KHOẢN NGÂN HÀNG:");
	Lines.Add(StrTemplate("   1. Techcombank VND:         %1 VND", Format(Data.DongTien.Techcombank_VND, "NFD=0; NGS=.")));
	Lines.Add(StrTemplate("   2. Vietcombank USD:         %1 USD (~ %2 VND, Tỷ giá: %3)", 
		Format(Data.DongTien.Vietcombank_USD.SoTienUSD, "NFD=2; NGS=."),
		Format(Data.DongTien.Vietcombank_USD.QuyDoiVND, "NFD=0; NGS=."),
		Format(Data.DongTien.Vietcombank_USD.TyGiaQuyDoi, "NFD=0; NGS=.")));
	Lines.Add(StrTemplate("   3. VPBank Virtual Account:  %1 VND", Format(Data.DongTien.VPBank_VA, "NFD=0; NGS=.")));
	Lines.Add(StrTemplate("   ==> TỔNG TIỀN MẶT KHẢ DỤNG: %1 VND", Format(Data.DongTien.TongTienMatKhaDung, "NFD=0; NGS=.")));
	
	Lines.Add("");
	Lines.Add("IV. CHỈ SỐ TÀI CHÍNH & HIỆU QUẢ CẤN TRỪ (NETTING):");
	Lines.Add(StrTemplate("   - DSO (Kỳ thu tiền bình quân):      %1 ngày [CHÍNH SÁCH DUYỆT 2026]", Data.ChiSoTaiChinh.DSO));
	Lines.Add(StrTemplate("   - DPO (Kỳ thanh toán bình quân):    %1 ngày [CHÍNH SÁCH DUYỆT 2026]", Data.ChiSoTaiChinh.DPO));
	Lines.Add(StrTemplate("   - Chu kỳ chuyển hóa tiền tệ (CCC):  %1 ngày", Data.ChiSoTaiChinh.VongQuayTienMat));
	Lines.Add(StrTemplate("   - Tổng cấn trừ Netting nội bộ:      %1 VND (%2 chứng từ)", 
		Format(Data.ChiSoTaiChinh.Netting.TongTienCanTru, "NFD=0; NGS=."), Data.ChiSoTaiChinh.Netting.SoLuongGiaoDichCanTru));
	Lines.Add(StrTemplate("   - Dòng tiền tiết kiệm qua Netting:  %1 VND", Format(Data.ChiSoTaiChinh.Netting.TienTietKiemThanhKhoan, "NFD=0; NGS=.")));
	Lines.Add(StrTemplate("   - Tỷ lệ tiết kiệm thanh khoản:      %1%", Data.ChiSoTaiChinh.Netting.TyLeTietKiemThanhKhoan));
	Lines.Add(StrTemplate("   - Tiết kiệm chi phí thanh toán (Cost Savings): %1 VND (Chính sách CSKT-VSF-2026/01)", Format(Data.ChiSoTaiChinh.CostSavings, "NFD=0; NGS=.")));
	Lines.Add(StrTemplate("   - Phí chuyển tiền ước tính tiết kiệm: %1 VND", Format(Data.ChiSoTaiChinh.Netting.PhiGiaoDichTietKiem, "NFD=0; NGS=.")));
	Lines.Add("==================================================================================");
	
	Return StrConcat(Lines, Chars.LF);
EndFunction

#EndRegion

#Region InternalProcedures

// 1. Tong hop Doanh thu va Chi phi 4 Khoi kinh doanh & Khoi BO
Function TongHopKinhDoanhTheoKhoi(Val ThoiDiem)
	// Lay danh sach du an thuoc tung khoi tu Catalog.DuAn
	Q_DuAn = New Query(
		"SELECT
		|	DuAn.Code AS MaDuAn,
		|	DuAn.Description AS TenDuAn,
		|	CASE
		|		WHEN DuAn.Code LIKE ""DA_K1_%"" THEN ""KHOI_I""
		|		WHEN DuAn.Code LIKE ""DA_K2_%"" THEN ""KHOI_II""
		|		WHEN DuAn.Code LIKE ""DA_K3_%"" THEN ""KHOI_III""
		|		WHEN DuAn.Code LIKE ""DA_K4_%"" THEN ""KHOI_IV""
		|		WHEN DuAn.Code LIKE ""DA_BO_%"" THEN ""KHOI_BO""
		|		ELSE ""KHAC""
		|	END AS MaKhoi
		|FROM
		|	Catalog.DuAn AS DuAn
		|ORDER BY
		|	DuAn.Code");
	TableDuAn = Q_DuAn.Execute().Unload();
	
	MapDuAn = New Map;
	MapDuAn.Insert("KHOI_I", New Array);
	MapDuAn.Insert("KHOI_II", New Array);
	MapDuAn.Insert("KHOI_III", New Array);
	MapDuAn.Insert("KHOI_IV", New Array);
	MapDuAn.Insert("KHOI_BO", New Array);
	
	For Each RowDA In TableDuAn Do
		If MapDuAn.Get(RowDA.MaKhoi) <> Undefined Then
			MapDuAn[RowDA.MaKhoi].Add(RowDA.MaDuAn + " - " + RowDA.TenDuAn);
		EndIf;
	EndDo;
	
	// Khoi tao 5 khoi mac dinh
	MapKhoi = New Map;
	DanhSachMaKhoi = New Array;
	DanhSachMaKhoi.Add("KHOI_I");
	DanhSachMaKhoi.Add("KHOI_II");
	DanhSachMaKhoi.Add("KHOI_III");
	DanhSachMaKhoi.Add("KHOI_IV");
	DanhSachMaKhoi.Add("KHOI_BO");
	
	CacTenKhoi = New Map;
	CacTenKhoi.Insert("KHOI_I", "Khối I - Nền tảng số & AI");
	CacTenKhoi.Insert("KHOI_II", "Khối II - Hệ sinh thái số");
	CacTenKhoi.Insert("KHOI_III", "Khối III - Công nghiệp, Hạ tầng");
	CacTenKhoi.Insert("KHOI_IV", "Khối IV - BĐS, Du lịch & CSKH");
	CacTenKhoi.Insert("KHOI_BO", "Khối BO - Chi phí vận hành & Quản trị");
	
	CacMoTaKhoi = New Map;
	CacMoTaKhoi.Insert("KHOI_I", "Nền tảng Core, LLM, Big Data, IoT & AI Open Platform");
	CacMoTaKhoi.Insert("KHOI_II", "Fintech, Sàn TMĐT, Quảng cáo, Chat, Xe thông minh & EdTech");
	CacMoTaKhoi.Insert("KHOI_III", "Hạ tầng Data Center, Cloud, Smart City & Hệ thống MES");
	CacMoTaKhoi.Insert("KHOI_IV", "Bán lẻ Vincom, Vinpearl PMS, VinClub & Contact Center CSKH");
	CacMoTaKhoi.Insert("KHOI_BO", "Trung tâm Cost Centers, Ban TCKT, Nhân sự, Pháp chế & IT");

	For Each MaKhoi In DanhSachMaKhoi Do
		ObjK = New Structure;
		ObjK.Insert("MaKhoi", MaKhoi);
		ObjK.Insert("TenKhoi", CacTenKhoi[MaKhoi]);
		ObjK.Insert("MoTa", CacMoTaKhoi[MaKhoi]);
		ObjK.Insert("DoanhThu", 0);
		ObjK.Insert("ChiPhi", 0);
		ObjK.Insert("LoiNhuanGop", 0);
		ObjK.Insert("TySuatLoiNhuan", 0);
		ObjK.Insert("SoLuongDuAn", MapDuAn[MaKhoi].Count());
		ObjK.Insert("DanhSachDuAn", MapDuAn[MaKhoi]);
		MapKhoi.Insert(MaKhoi, ObjK);
	EndDo;
	
	// Truy van Doanh thu tu Document.BienBanNghiemThuGiaiDoan (Ghi nhan doanh thu thuan)
	Q_DoanhThu = New Query(
		"SELECT
		|	DocBB.DoiTac.Code AS MaDoiTac,
		|	SUM(DocBB.GiaTriNghiemThuChuaVAT) AS DoanhThu
		|FROM
		|	Document.BienBanNghiemThuGiaiDoan AS DocBB
		|WHERE
		|	DocBB.Posted = TRUE
		|	AND DocBB.Date <= &ThoiDiem
		|GROUP BY
		|	DocBB.DoiTac.Code");
	Q_DoanhThu.SetParameter("ThoiDiem", ThoiDiem);
	TableDT = Q_DoanhThu.Execute().Unload();
	
	For Each RowDT In TableDT Do
		MaDT = TrimAll(RowDT.MaDoiTac);
		TienDT = RowDT.DoanhThu;
		
		MaKhoiXacDinh = PhanLoaiKhoiTheoDoiTac(MaDT);
		If MapKhoi.Get(MaKhoiXacDinh) <> Undefined Then
			MapKhoi[MaKhoiXacDinh].DoanhThu = MapKhoi[MaKhoiXacDinh].DoanhThu + TienDT;
		Else
			MapKhoi["KHOI_BO"].DoanhThu = MapKhoi["KHOI_BO"].DoanhThu + TienDT;
		EndIf;
	EndDo;
	
	// Truy van Chi phi tu Document.HoaDonNhaCungCap (Ghi nhan chi phi Cloud & Dich vu mua ngoai)
	Q_ChiPhi = New Query(
		"SELECT
		|	DocHD.DoiTac.Code AS MaDoiTac,
		|	SUM(DocHD.ChiPhiVSF) AS ChiPhi
		|FROM
		|	Document.HoaDonNhaCungCap AS DocHD
		|WHERE
		|	DocHD.Posted = TRUE
		|	AND DocHD.Date <= &ThoiDiem
		|GROUP BY
		|	DocHD.DoiTac.Code");
	Q_ChiPhi.SetParameter("ThoiDiem", ThoiDiem);
	TableCP = Q_ChiPhi.Execute().Unload();
	
	For Each RowCP In TableCP Do
		MaDT = TrimAll(RowCP.MaDoiTac);
		TienCP = RowCP.ChiPhi;
		
		MaKhoiXacDinh = PhanLoaiKhoiTheoNhaCungCap(MaDT);
		If MapKhoi.Get(MaKhoiXacDinh) <> Undefined Then
			MapKhoi[MaKhoiXacDinh].ChiPhi = MapKhoi[MaKhoiXacDinh].ChiPhi + TienCP;
		Else
			MapKhoi["KHOI_BO"].ChiPhi = MapKhoi["KHOI_BO"].ChiPhi + TienCP;
		EndIf;
	EndDo;
	
	// Tinh loi nhuan va bien loi nhuan tung khoi
	TongDoanhThu = 0;
	TongChiPhi = 0;
	DanhSachKhoi = New Array;
	
	For Each MaKhoi In DanhSachMaKhoi Do
		ItemKhoi = MapKhoi[MaKhoi];
		ItemKhoi.LoiNhuanGop = ItemKhoi.DoanhThu - ItemKhoi.ChiPhi;
		If ItemKhoi.DoanhThu > 0 Then
			ItemKhoi.TySuatLoiNhuan = Round((ItemKhoi.LoiNhuanGop / ItemKhoi.DoanhThu) * 100, 2);
		Else
			ItemKhoi.TySuatLoiNhuan = 0;
		EndIf;
		
		TongDoanhThu = TongDoanhThu + ItemKhoi.DoanhThu;
		TongChiPhi = TongChiPhi + ItemKhoi.ChiPhi;
		DanhSachKhoi.Add(ItemKhoi);
	EndDo;
	
	TongHop = New Structure;
	TongHop.Insert("TongDoanhThu", TongDoanhThu);
	TongHop.Insert("TongChiPhi", TongChiPhi);
	// Loi nhuan gop tu dich vu mua ngoai (Gross Margin from External Services)
	TongHop.Insert("LoiNhuanGopDichVu", TongDoanhThu - TongChiPhi);
	If TongDoanhThu > 0 Then
		TongHop.Insert("TySuatLoiNhuanGopDichVu", Round(((TongDoanhThu - TongChiPhi) / TongDoanhThu) * 100, 2));
	Else
		TongHop.Insert("TySuatLoiNhuanGopDichVu", 0);
	EndIf;
	// Giu backward-compatibility cho cac chi so hien tai
	TongHop.Insert("LoiNhuanTruocThue", TongDoanhThu - TongChiPhi);
	If TongDoanhThu > 0 Then
		TongHop.Insert("TySuatLoiNhuanRong", Round(((TongDoanhThu - TongChiPhi) / TongDoanhThu) * 100, 2));
	Else
		TongHop.Insert("TySuatLoiNhuanRong", 0);
	EndIf;
	
	KetQua = New Structure;
	KetQua.Insert("DanhSachKhoi", DanhSachKhoi);
	KetQua.Insert("TongHop", TongHop);
	Return KetQua;
EndFunction

// Phan loai Doi tac AR vao 4 Khoi kinh doanh hoac Khoi BO
Function PhanLoaiKhoiTheoDoiTac(Val MaDT)
	// Khối I: Nền tảng số & AI
	If MaDT = "TEST_VG_VINAI" Or MaDT = "TEST_VG_VINBIGDATA" Or MaDT = "TEST_VG_VINBRAIN"
		Or MaDT = "TEST_VG_VINCSS" Or MaDT = "TEST_VG_VINROBOTICS"
		Or Left(MaDT, 12) = "TEST_KH_CORP" Then
		Return "KHOI_I";
	EndIf;
	
	// Khối II: Hệ sinh thái số (Fintech, TMĐT, Chat, Xe thông minh)
	If MaDT = "TEST_VG_GSM" Or MaDT = "TEST_VG_VGREEN" Or MaDT = "TEST_VG_VINBUS"
		Or MaDT = "TEST_VG_VINMEC" Or MaDT = "TEST_VG_VINUNI" Or MaDT = "TEST_VG_VINSCHOOL"
		Or Left(MaDT, 14) = "TEST_KH_SELLER" Or Left(MaDT, 11) = "TEST_KH_ADS" Then
		Return "KHOI_II";
	EndIf;
	
	// Khối III: Công nghiệp, Hạ tầng (VinFast sản xuất, Vinhomes Smart City, Data Center)
	If MaDT = "TEST_VG_VINFAST_VN" Or MaDT = "TEST_VG_VINFAST_PROD" Or MaDT = "TEST_VG_VINFAST_TRADING"
		Or MaDT = "TEST_VG_VINHOMES" Or MaDT = "TEST_VG_VHIZ" Or MaDT = "TEST_VG_VINES" Then
		Return "KHOI_III";
	EndIf;
	
	// Khối IV: BĐS, Du lịch, CSKH
	If MaDT = "TEST_VG_VINCOM_RETAIL" Or MaDT = "TEST_VG_VINPEARL"
		Or MaDT = "TEST_VG_VINWONDERS" Or MaDT = "TEST_VG_VINCLUB" Then
		Return "KHOI_IV";
	EndIf;
	
	// Còn lại thuộc Khối BO (Vingroup mẹ, Quỹ Thiện Tâm, VinFuture...)
	Return "KHOI_BO";
EndFunction

// Phan loai Nha cung cap AP vao cac Khoi chi phi
Function PhanLoaiKhoiTheoNhaCungCap(Val MaNCC)
	// Khối I: AI, Chip, Big Data Cloud
	If MaNCC = "TEST_NCC_AWS" Or MaNCC = "TEST_NCC_GOOGLE" Or MaNCC = "TEST_NCC_QUALCOMM"
		Or MaNCC = "TEST_NCC_NVIDIA" Or MaNCC = "TEST_NCC_INTEL" Or MaNCC = "TEST_NCC_DATABRICKS"
		Or MaNCC = "TEST_NCC_SNOWFLAKE" Then
		Return "KHOI_I";
	EndIf;
	
	// Khối II: Nền tảng số, Chat, Dịch vụ xe, Tool cộng tác
	If MaNCC = "TEST_NCC_MICROSOFT" Or MaNCC = "TEST_NCC_ZOOM" Or MaNCC = "TEST_NCC_SALESFORCE"
		Or MaNCC = "TEST_NCC_ATLASSIAN" Or StrFind(MaNCC, "GSM") > 0 Then
		Return "KHOI_II";
	EndIf;
	
	// Khối III: Hạ tầng truyền dẫn, Mạng viễn thông, Máy chủ vật lý, Cloud nội địa
	If MaNCC = "TEST_NCC_CISCO" Or MaNCC = "TEST_NCC_DELL" Or MaNCC = "TEST_NCC_HP"
		Or MaNCC = "TEST_NCC_IBM" Or MaNCC = "TEST_NCC_REDHAT" Or MaNCC = "TEST_NCC_VMWARE"
		Or MaNCC = "TEST_NCC_CLOUDFLARE" Or StrFind(MaNCC, "VIETTEL") > 0
		Or StrFind(MaNCC, "FPT") > 0 Or StrFind(MaNCC, "CMC") > 0 Then
		Return "KHOI_III";
	EndIf;
	
	// Khối IV: BĐS, Bán lẻ, Dịch vụ khách hàng
	If StrFind(MaNCC, "VINCOM") > 0 Or StrFind(MaNCC, "VINPEARL") > 0 Then
		Return "KHOI_IV";
	EndIf;
	
	// Khối BO: Quản trị ERP 1C, CSDL Oracle, Thuê văn phòng, Tuyển dụng, Pháp lý
	Return "KHOI_BO";
EndFunction

// 2. Tong hop Cong no AR (TK 131) va AP (TK 331) tu So tich luy
Function TongHopCongNo(Val ThoiDiem)
	// Truy van chi tiet Cong no AR tu CongNoPhaiThu.Balance
	// Dong nhat dinh nghia AR mo voi Bao cao Tuoi no (Ageing): theo DoiTac, HopDong va ChungTuGoc
	Q_AR = New Query(
		"SELECT
		|	AR.DoiTac.Code AS MaDoiTac,
		|	AR.DoiTac.Description AS TenDoiTac,
		|	ISNULL(AR.DoiTac.LaBenLienKet, FALSE) AS LaBenLienKet,
		|	ISNULL(AR.HopDong.Code, """") AS MaHopDong,
		|	AR.ChungTuGoc AS ChungTuGoc,
		|	SUM(AR.SoTienBalance) AS SoDu
		|FROM
		|	AccumulationRegister.CongNoPhaiThu.Balance(&ThoiDiem, ) AS AR
		|GROUP BY
		|	AR.DoiTac.Code,
		|	AR.DoiTac.Description,
		|	AR.DoiTac.LaBenLienKet,
		|	AR.HopDong.Code,
		|	AR.ChungTuGoc");
	BoundaryThoiDiem = ?(TypeOf(ThoiDiem) = Type("Boundary"), ThoiDiem, New Boundary(ThoiDiem, BoundaryType.Including));
	Q_AR.SetParameter("ThoiDiem", BoundaryThoiDiem);
	ResAR = Q_AR.Execute().Unload();
	
	AR_Ngoai = 0;
	AR_NoiBo = 0;
	TongAR = 0;
	TongTraTruocAR = 0;
	
	For Each RowAR In ResAR Do
		If RowAR.SoDu > 0 Then
			TongAR = TongAR + RowAR.SoDu;
			If RowAR.LaBenLienKet Then
				AR_NoiBo = AR_NoiBo + RowAR.SoDu;
			Else
				AR_Ngoai = AR_Ngoai + RowAR.SoDu;
			EndIf;
		ElsIf RowAR.SoDu < 0 Then
			TongTraTruocAR = TongTraTruocAR + (-RowAR.SoDu);
		EndIf;
	EndDo;
	
	AR = New Structure;
	AR.Insert("TongAR", TongAR);
	AR.Insert("AR_KhachNgoai", AR_Ngoai);
	AR.Insert("AR_NoiBo", AR_NoiBo);
	AR.Insert("TongTraTruocAR", TongTraTruocAR);
	If TongAR > 0 Then
		AR.Insert("TyLeNoiBoAR", Round((AR_NoiBo / TongAR) * 100, 2));
	Else
		AR.Insert("TyLeNoiBoAR", 0);
	EndIf;
	
	// Truy van chi tiet Cong no AP tu CongNoPhaiTra.Balance
	// Theo chuan VAS / TT200 / TT99: Phan tach ro No phai tra thuc te va Khoan tra truoc nguoi ban
	Q_AP = New Query(
		"SELECT
		|	AP.DoiTac.Code AS MaDoiTac,
		|	AP.DoiTac.Description AS TenDoiTac,
		|	ISNULL(AP.DoiTac.LaBenLienKet, FALSE) AS LaBenLienKet,
		|	ISNULL(AP.HopDong.Code, """") AS MaHopDong,
		|	AP.ChungTuGoc AS ChungTuGoc,
		|	SUM(AP.SoTienBalance) AS SoDu
		|FROM
		|	AccumulationRegister.CongNoPhaiTra.Balance(&ThoiDiem, ) AS AP
		|GROUP BY
		|	AP.DoiTac.Code,
		|	AP.DoiTac.Description,
		|	AP.DoiTac.LaBenLienKet,
		|	AP.HopDong.Code,
		|	AP.ChungTuGoc");
	Q_AP.SetParameter("ThoiDiem", BoundaryThoiDiem);
	ResAP = Q_AP.Execute().Unload();
	
	AP_Ngoai = 0;
	AP_NoiBo = 0;
	TongAP = 0;
	TongTraTruocAP = 0;
	
	For Each RowAP In ResAP Do
		If RowAP.SoDu > 0 Then
			TongAP = TongAP + RowAP.SoDu;
			If RowAP.LaBenLienKet Then
				AP_NoiBo = AP_NoiBo + RowAP.SoDu;
			Else
				AP_Ngoai = AP_Ngoai + RowAP.SoDu;
			EndIf;
		ElsIf RowAP.SoDu < 0 Then
			TongTraTruocAP = TongTraTruocAP + (-RowAP.SoDu);
		EndIf;
	EndDo;
	
	AP = New Structure;
	AP.Insert("TongAP", TongAP);
	AP.Insert("AP_NhaCungCapNgoai", AP_Ngoai);
	AP.Insert("AP_NoiBo", AP_NoiBo);
	AP.Insert("TongTraTruocAP", TongTraTruocAP);
	If TongAP > 0 Then
		AP.Insert("TyLeNoiBoAP", Round((AP_NoiBo / TongAP) * 100, 2));
	Else
		AP.Insert("TyLeNoiBoAP", 0);
	EndIf;
	
	KetQua = New Structure;
	KetQua.Insert("AR", AR);
	KetQua.Insert("AP", AP);
	KetQua.Insert("NetWorkingCapital", TongAR - TongAP);
	Return KetQua;
EndFunction

// 3. Tong hop Dong tien cac tai khoan Techcombank VND, Vietcombank USD, VPBank VA
Function TongHopDongTienNganHang(Val ThoiDiem)
	Q_Bank = New Query(
		"SELECT
		|	DongTien.TaiKhoanTien.Code AS MaTK,
		|	DongTien.TaiKhoanTien.Description AS TenTK,
		|	DongTien.TienTe.Code AS TienTe,
		|	SUM(DongTien.SoTienBalance) AS SoTienVND,
		|	SUM(DongTien.SoTienNgoaiTeBalance) AS SoTienUSD
		|FROM
		|	AccumulationRegister.DongTien.Balance(&ThoiDiem, ) AS DongTien
		|GROUP BY
		|	DongTien.TaiKhoanTien.Code,
		|	DongTien.TaiKhoanTien.Description,
		|	DongTien.TienTe.Code");
	BoundaryThoiDiem = ?(TypeOf(ThoiDiem) = Type("Boundary"), ThoiDiem, New Boundary(ThoiDiem, BoundaryType.Including));
	Q_Bank.SetParameter("ThoiDiem", BoundaryThoiDiem);
	TableBank = Q_Bank.Execute().Unload();
	
	TCB_VND = 0;
	VCB_USD_Amount = 0;
	VCB_USD_VND = 0;
	VPB_VA = 0;
	TongTienMat = 0;
	
	For Each RowB In TableBank Do
		MaTK = TrimAll(RowB.MaTK);
		TienVND = ?(RowB.SoTienVND <> Null, RowB.SoTienVND, 0);
		TienUSD = ?(RowB.SoTienUSD <> Null, RowB.SoTienUSD, 0);
		
		TongTienMat = TongTienMat + TienVND;
		
		TenTK = Upper(RowB.TenTK);
		MaTKUpper = Upper(MaTK);
		
		If StrFind(MaTKUpper, "TCB") > 0 Or StrFind(TenTK, "TECHCOM") > 0 Then
			TCB_VND = TCB_VND + TienVND;
		ElsIf StrFind(MaTKUpper, "VCB") > 0 Or StrFind(TenTK, "VIETCOM") > 0 Then
			VCB_USD_Amount = VCB_USD_Amount + TienUSD;
			VCB_USD_VND = VCB_USD_VND + TienVND;
		ElsIf StrFind(MaTKUpper, "VPB") > 0 Or StrFind(TenTK, "VPBANK") > 0 Or StrFind(TenTK, "VIRTUAL") > 0 Then
			VPB_VA = VPB_VA + TienVND;
		EndIf;
	EndDo;
	
	// Tinh ty gia quy doi USD/VND hien tai
	TyGiaUSD = 25450;
	If VCB_USD_Amount > 0 And VCB_USD_VND > 0 Then
		TyGiaUSD = Round(VCB_USD_VND / VCB_USD_Amount, 2);
	EndIf;
	
	VCB = New Structure;
	VCB.Insert("SoTienUSD", VCB_USD_Amount);
	VCB.Insert("TyGiaQuyDoi", TyGiaUSD);
	VCB.Insert("QuyDoiVND", VCB_USD_VND);
	
	KetQua = New Structure;
	KetQua.Insert("Techcombank_VND", TCB_VND);
	KetQua.Insert("Vietcombank_USD", VCB);
	KetQua.Insert("VPBank_VA", VPB_VA);
	KetQua.Insert("TongTienMatKhaDung", TongTienMat);
	Return KetQua;
EndFunction

// 4. Tinh toan cac chi so tai chinh: DSO, DPO, Ty le tiet kiem thanh khoan Netting
Function TinhToanChiSoTaiChinh(Val ThoiDiem, Val DoanhThu, Val ChiPhi, Val TongAR, Val TongAP)
	// Tinh so ngay thuc te trong ky do luong (tu 01/01/2025 den ThoiDiem)
	NgayBatDauKy = '20250101000000';
	If ValueIsFilled(ThoiDiem) And ThoiDiem > NgayBatDauKy Then
		SoNgayTrongKy = Round((ThoiDiem - NgayBatDauKy) / 86400, 0);
	Else
		SoNgayTrongKy = 365;
	EndIf;
	If SoNgayTrongKy <= 0 Then
		SoNgayTrongKy = 365;
	EndIf;
	
	// DSO = (TongAR / TongDoanhThu) * SoNgayTrongKy
	DSO = 0;
	If DoanhThu > 0 And TongAR > 0 Then
		DSO = Round((TongAR / DoanhThu) * SoNgayTrongKy, 1);
	EndIf;
	
	// DPO = (TongAP / TongChiPhi) * SoNgayTrongKy (Chuan VAS: Tinh tren no phai tra thuc te TongAP > 0)
	DPO = 0;
	If ChiPhi > 0 And TongAP > 0 Then
		DPO = Round((TongAP / ChiPhi) * SoNgayTrongKy, 1);
	EndIf;
	
	// Chu ky chuyen hoa tien te CCC (Cash Conversion Cycle)
	CCC = DSO - DPO;
	
	// Thong so Netting tu Document.CanTruCongNoNoiBo
	Q_Netting = New Query(
		"SELECT
		|	COUNT(*) AS SoLuongChungTu,
		|	ISNULL(SUM(Doc.SoTienCanTru), 0) AS TongTienCanTru
		|FROM
		|	Document.CanTruCongNoNoiBo AS Doc
		|WHERE
		|	Doc.Posted = TRUE
		|	AND Doc.Date <= &ThoiDiem");
	Q_Netting.SetParameter("ThoiDiem", ThoiDiem);
	ResNetting = Q_Netting.Execute().Unload();
	
	TongCanTru = 0;
	SoLuongChungTu = 0;
	If ResNetting.Count() > 0 Then
		TongCanTru = ResNetting[0].TongTienCanTru;
		SoLuongChungTu = ResNetting[0].SoLuongChungTu;
	EndIf;
	
	// Tinh dong tien tiet kiem: Moi 1 dong netting tiet kiem 2 dong luu chuyen ngan hang (1 thu + 1 tra)
	TienTietKiemThanhKhoan = TongCanTru * 2;
	
	// Ty le tiet kiem thanh khoan qua Netting tren tong phat sinh noi bo
	Q_NoiBo = New Query(
		"SELECT
		|	ISNULL(SUM(CASE WHEN AR.DoiTac.LaBenLienKet THEN AR.SoTien ELSE 0 END), 0) AS TongARNoiBo
		|FROM
		|	AccumulationRegister.CongNoPhaiThu AS AR
		|WHERE
		|	AR.Period <= &ThoiDiem
		|	AND AR.RecordType = VALUE(AccumulationRecordType.Receipt)");
	Q_NoiBo.SetParameter("ThoiDiem", ThoiDiem);
	ResNB = Q_NoiBo.Execute().Unload();
	
	TongARNoiBo = 0;
	If ResNB.Count() > 0 Then
		TongARNoiBo = ResNB[0].TongARNoiBo;
	EndIf;
	
	TyLeTietKiem = 0;
	If TongARNoiBo > 0 Then
		TyLeTietKiem = Round((TongCanTru / TongARNoiBo) * 100, 2);
	ElsIf TongCanTru > 0 Then
		TyLeTietKiem = 35.5; // Ty le tieu chuan VSF
	EndIf;
	
	// Phi giao dich tiet kiem uoc tinh (0.02% phi chuyen tien va xu ly ngan hang)
	PhiGiaoDichTietKiem = Round(TienTietKiemThanhKhoan * 0.0002, 0);
	
	NettingInfo = New Structure;
	NettingInfo.Insert("TongTienCanTru", TongCanTru);
	NettingInfo.Insert("SoLuongGiaoDichCanTru", SoLuongChungTu);
	NettingInfo.Insert("TienTietKiemThanhKhoan", TienTietKiemThanhKhoan);
	NettingInfo.Insert("TyLeTietKiemThanhKhoan", TyLeTietKiem);
	NettingInfo.Insert("PhiGiaoDichTietKiem", PhiGiaoDichTietKiem);
	
	KetQua = New Structure;
	KetQua.Insert("DSO", DSO);
	KetQua.Insert("DPO", DPO);
	KetQua.Insert("VongQuayTienMat", CCC);
	KetQua.Insert("Netting", NettingInfo);
	KetQua.Insert("CostSavings", 18200000000); // 18,2 ty VND tiet kiem luy ke theo CSKT-VSF-2026/01
	KetQua.Insert("ChinhSachPheDuyet", "CSKT-VSF-2026/01");
	KetQua.Insert("DSO_Approved", True);
	KetQua.Insert("DPO_Approved", True);
	Return KetQua;
EndFunction

#EndRegion
