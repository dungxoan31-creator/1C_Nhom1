// Module BangDieuKhienServer
// Cung cap cac ham truy van va tong hop chi so KPI cho Trang Chu Dashboard

Function LayDuLieuTongQuan(Val KyBaoCao = "ThangNay") Export
	
	KetQua = New Structure;
	KetQua.Insert("TongDoanhThu", 0);
	KetQua.Insert("SoHoaDonBan", 0);
	KetQua.Insert("NoPhaiThu", 0);
	KetQua.Insert("NoPhaiThuQuaHan", 0);
	KetQua.Insert("NoPhaiTra", 0);
	KetQua.Insert("NoPhaiTraDenHan", 0);
	KetQua.Insert("TienKhaDung", 0);
	KetQua.Insert("TopNoQuaHan", New Array);
	KetQua.Insert("TopChungTuChoDuyet", New Array);
	KetQua.Insert("BieuDoDoanhThu", New Array);
	KetQua.Insert("BieuDoTuoiNo", New Array);
	
	ThoiDiemBaoCao = CurrentDate();
	DauNgayBaoCao = Date(Year(ThoiDiemBaoCao), Month(ThoiDiemBaoCao), Day(ThoiDiemBaoCao));
	DauNgayMai = DauNgayBaoCao + 86400;
	If KyBaoCao = "ThangNay" Then
		DauKyBaoCao = Date(Year(ThoiDiemBaoCao), Month(ThoiDiemBaoCao), 1);
	ElsIf KyBaoCao = "QuyNay" Then
		ThangDauQuy = Int((Month(ThoiDiemBaoCao) - 1) / 3) * 3 + 1;
		DauKyBaoCao = Date(Year(ThoiDiemBaoCao), ThangDauQuy, 1);
	ElsIf KyBaoCao = "NamNay" Then
		DauKyBaoCao = Date(Year(ThoiDiemBaoCao), 1, 1);
	Else
		Raise NStr("vi = 'Kỳ báo cáo không hợp lệ. Chỉ chấp nhận ThangNay, QuyNay hoặc NamNay.'; en = 'Unsupported report period. Use ThangNay, QuyNay, or NamNay.'");
	EndIf;
	
	// 1. Doanh thu la doanh thu thuan da ghi nhan tren TK 5113; so hoa don dem theo chung tu da ghi so.
	TruyVanDoanhThu = New Query;
	TruyVanDoanhThu.Text =
		"SELECT
		|	COUNT(HoaDon.Ref) AS SoHoaDon
		|FROM
		|	Document.HoaDonGTGTDauRa AS HoaDon
		|WHERE
		|	HoaDon.Posted = TRUE
		|	AND HoaDon.DeletionMark = FALSE
		|	AND HoaDon.Date >= &DauKy
		|	AND HoaDon.Date <= &CuoiKy";
	TruyVanDoanhThu.SetParameter("DauKy", DauKyBaoCao);
	TruyVanDoanhThu.SetParameter("CuoiKy", ThoiDiemBaoCao);
	BangDoanhThu = TruyVanDoanhThu.Execute().Unload();
	If BangDoanhThu.Count() > 0 Then
		If BangDoanhThu[0].SoHoaDon <> Null Then
			KetQua.SoHoaDonBan = BangDoanhThu[0].SoHoaDon;
		EndIf;
	EndIf;
	
	TaiKhoanDoanhThu = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("5113");
	If Not ValueIsFilled(TaiKhoanDoanhThu) Then
		Raise NStr("vi = 'Không tìm thấy tài khoản doanh thu 5113.'; en = 'Revenue account 5113 was not found.'");
	EndIf;
	TruyVanDoanhThuSoCai = New Query;
	TruyVanDoanhThuSoCai.Text =
		"SELECT
		|	SUM(CASE WHEN Entry.AccountCr = &TaiKhoanDoanhThu THEN Entry.SoTien ELSE 0 END)
		|    - SUM(CASE WHEN Entry.AccountDr = &TaiKhoanDoanhThu THEN Entry.SoTien ELSE 0 END) AS TongDoanhThu
		|FROM
		|	AccountingRegister.SoCaiKeToan AS Entry
		|WHERE
		|	Entry.Active = TRUE
		|    AND (Entry.AccountCr = &TaiKhoanDoanhThu OR Entry.AccountDr = &TaiKhoanDoanhThu)
		|    AND Entry.Period >= &DauKy
		|    AND Entry.Period <= &CuoiKy";
	TruyVanDoanhThuSoCai.SetParameter("TaiKhoanDoanhThu", TaiKhoanDoanhThu);
	TruyVanDoanhThuSoCai.SetParameter("DauKy", DauKyBaoCao);
	TruyVanDoanhThuSoCai.SetParameter("CuoiKy", ThoiDiemBaoCao);
	BangDoanhThuSoCai = TruyVanDoanhThuSoCai.Execute().Unload();
	If BangDoanhThuSoCai.Count() > 0 And BangDoanhThuSoCai[0].TongDoanhThu <> Null Then
		KetQua.TongDoanhThu = BangDoanhThuSoCai[0].TongDoanhThu;
	EndIf;
	
	// 2. Batch-load 6 monthly periods once; keep database queries outside the month loop.
	DuLieuBieuDo = New Array;
	For ThangLui = 0 To 5 Do
		ThangCanLay = Month(ThoiDiemBaoCao) - (5 - ThangLui);
		NamCanLay = Year(ThoiDiemBaoCao);
		While ThangCanLay <= 0 Do
			ThangCanLay = ThangCanLay + 12;
			NamCanLay = NamCanLay - 1;
		EndDo;
		DauThang = Date(NamCanLay, ThangCanLay, 1);
		If ThangCanLay = 12 Then
			DauThangSau = Date(NamCanLay + 1, 1, 1);
		Else
			DauThangSau = Date(NamCanLay, ThangCanLay + 1, 1);
		EndIf;
		CuoiThangBaoCao = DauThangSau - 1;
		If CuoiThangBaoCao > ThoiDiemBaoCao Then
			CuoiThangBaoCao = ThoiDiemBaoCao;
		EndIf;
		DuLieuBieuDo.Add(New Structure("DauThang,Ky,CuoiThang,DoanhThu,TienThu",
			DauThang, Format(DauThang, "DF=MM/yyyy"), CuoiThangBaoCao, 0, 0));
	EndDo;

	DauThangBieuDo = DuLieuBieuDo[0].DauThang;
	TruyVanDoanhThuThang = New Query;
	TruyVanDoanhThuThang.Text =
		"SELECT
		|    BEGINOFPERIOD(Entry.Period, MONTH) AS Thang,
		|    SUM(CASE WHEN Entry.AccountCr = &TaiKhoanDoanhThu THEN Entry.SoTien ELSE 0 END)
		|        - SUM(CASE WHEN Entry.AccountDr = &TaiKhoanDoanhThu THEN Entry.SoTien ELSE 0 END) AS DoanhThu
		|FROM
		|    AccountingRegister.SoCaiKeToan AS Entry
		|WHERE
		|    Entry.Active = TRUE
		|    AND (Entry.AccountCr = &TaiKhoanDoanhThu OR Entry.AccountDr = &TaiKhoanDoanhThu)
		|    AND Entry.Period >= &DauThang
		|    AND Entry.Period <= &ThoiDiemBaoCao
		|GROUP BY
		|    BEGINOFPERIOD(Entry.Period, MONTH)";
	TruyVanDoanhThuThang.SetParameter("TaiKhoanDoanhThu", TaiKhoanDoanhThu);
	TruyVanDoanhThuThang.SetParameter("DauThang", DauThangBieuDo);
	TruyVanDoanhThuThang.SetParameter("ThoiDiemBaoCao", ThoiDiemBaoCao);
	BangDoanhThuThang = TruyVanDoanhThuThang.Execute().Unload();
	For Each DongDoanhThuThang In BangDoanhThuThang Do
		For IndexThang = 0 To DuLieuBieuDo.Count() - 1 Do
			If DuLieuBieuDo[IndexThang].DauThang = DongDoanhThuThang.Thang Then
				If DongDoanhThuThang.DoanhThu <> Null Then
					DuLieuBieuDo[IndexThang].DoanhThu = DongDoanhThuThang.DoanhThu;
				EndIf;
				Break;
			EndIf;
		EndDo;
	EndDo;

	TruyVanTienThuThang = New Query;
	TruyVanTienThuThang.Text =
		"SELECT
		|    BEGINOFPERIOD(PhieuThu.Date, MONTH) AS Thang,
		|    SUM(PhieuThu.SoTien) AS TienThu
		|FROM
		|    Document.PhieuThuTienKhachHang AS PhieuThu
		|WHERE
		|    PhieuThu.Posted = TRUE
		|    AND PhieuThu.DeletionMark = FALSE
		|    AND PhieuThu.Date >= &DauThang
		|    AND PhieuThu.Date <= &ThoiDiemBaoCao
		|GROUP BY
		|    BEGINOFPERIOD(PhieuThu.Date, MONTH)";
	TruyVanTienThuThang.SetParameter("DauThang", DauThangBieuDo);
	TruyVanTienThuThang.SetParameter("ThoiDiemBaoCao", ThoiDiemBaoCao);
	BangTienThuThang = TruyVanTienThuThang.Execute().Unload();
	For Each DongTienThuThang In BangTienThuThang Do
		For IndexThang = 0 To DuLieuBieuDo.Count() - 1 Do
			If DuLieuBieuDo[IndexThang].DauThang = DongTienThuThang.Thang Then
				If DongTienThuThang.TienThu <> Null Then
					DuLieuBieuDo[IndexThang].TienThu = DongTienThuThang.TienThu;
				EndIf;
				Break;
			EndIf;
		EndDo;
	EndDo;

	For Each DuLieuThang In DuLieuBieuDo Do
		KetQua.BieuDoDoanhThu.Add(New Structure("Ky,DoanhThu,TienThu",
			DuLieuThang.Ky, DuLieuThang.DoanhThu, DuLieuThang.TienThu));
	EndDo;
// 3. So du cong no AR/AP va tien kha dung lay tu cac so balance.
	TruyVanAR = New Query;
	TruyVanAR.Text =
		"SELECT
		|	SUM(AR.SoTienBalance) AS TongNoPhaiThu
		|FROM
		|	AccumulationRegister.CongNoPhaiThu.Balance AS AR";
	BangAR = TruyVanAR.Execute().Unload();
	If BangAR.Count() > 0 And BangAR[0].TongNoPhaiThu <> Null Then
		KetQua.NoPhaiThu = BangAR[0].TongNoPhaiThu;
	EndIf;
	
	TruyVanAP = New Query;
	TruyVanAP.Text =
		"SELECT
		|	SUM(AP.SoTienBalance) AS TongNoPhaiTra
		|FROM
		|	AccumulationRegister.CongNoPhaiTra.Balance AS AP";
	BangAP = TruyVanAP.Execute().Unload();
	If BangAP.Count() > 0 And BangAP[0].TongNoPhaiTra <> Null Then
		KetQua.NoPhaiTra = BangAP[0].TongNoPhaiTra;
	EndIf;
	
	TruyVanTien = New Query;
	TruyVanTien.Text =
		"SELECT
		|	SUM(Tien.SoTienBalance) AS TongTienKhaDung
		|FROM
		|	AccumulationRegister.DongTien.Balance AS Tien";
	BangTien = TruyVanTien.Execute().Unload();
	If BangTien.Count() > 0 And BangTien[0].TongTienKhaDung <> Null Then
		KetQua.TienKhaDung = BangTien[0].TongTienKhaDung;
	EndIf;
	
	// 3. Tuoi no AR theo chung tu goc va dieu khoan thanh toan cua hop dong.
	// Bao gom ca so du dang theo BBNT va so du da chuyen sang hoa don GTGT.
	TruyVanChiTietAR = New Query;
	TruyVanChiTietAR.Text =
		"SELECT
		|	Mo.DoiTac AS DoiTac,
		|	Mo.MaDoiTac AS MaDoiTac,
		|	Mo.TenDoiTac AS TenDoiTac,
		|	Mo.NgayChungTu AS NgayChungTu,
		|	Mo.HanThanhToanNgay AS HanThanhToanNgay,
		|	Mo.SoDuNo AS SoDuNo
		|FROM
		|	(SELECT
		|		AR.DoiTac AS DoiTac,
		|		PartnerRow.Code AS MaDoiTac,
		|		PartnerRow.Description AS TenDoiTac,
		|		BBNT.Date AS NgayChungTu,
		|		ContractRow.HanThanhToanNgay AS HanThanhToanNgay,
		|		AR.SoTienBalance AS SoDuNo
		|	FROM
		|		AccumulationRegister.CongNoPhaiThu.Balance AS AR
		|		INNER JOIN Document.BienBanNghiemThuGiaiDoan AS BBNT
		|		ON AR.ChungTuGoc = BBNT.Ref
		|		INNER JOIN Catalog.HopDong AS ContractRow
		|		ON AR.HopDong = ContractRow.Ref
		|		INNER JOIN Catalog.DoiTac AS PartnerRow
		|		ON AR.DoiTac = PartnerRow.Ref
		|	WHERE
		|		AR.SoTienBalance > 0
		|		AND BBNT.Posted = TRUE
		|		AND BBNT.DeletionMark = FALSE
		|
		|	UNION ALL
		|
		|	SELECT
		|		AR.DoiTac AS DoiTac,
		|		PartnerRow.Code AS MaDoiTac,
		|		PartnerRow.Description AS TenDoiTac,
		|		HoaDon.Date AS NgayChungTu,
		|		ContractRow.HanThanhToanNgay AS HanThanhToanNgay,
		|		AR.SoTienBalance AS SoDuNo
		|	FROM
		|		AccumulationRegister.CongNoPhaiThu.Balance AS AR
		|		INNER JOIN Document.HoaDonGTGTDauRa AS HoaDon
		|		ON AR.ChungTuGoc = HoaDon.Ref
		|		INNER JOIN Catalog.HopDong AS ContractRow
		|		ON AR.HopDong = ContractRow.Ref
		|		INNER JOIN Catalog.DoiTac AS PartnerRow
		|		ON AR.DoiTac = PartnerRow.Ref
		|	WHERE
		|		AR.SoTienBalance > 0
		|		AND HoaDon.Posted = TRUE
		|		AND HoaDon.DeletionMark = FALSE) AS Mo
		|WHERE
		|	Mo.SoDuNo > 0";
	BangChiTietAR = TruyVanChiTietAR.Execute().Unload();
	TongARDuong = 0;
	DanhSachTopAR = New Array;
	BieuDoTuoiNo = New Array;
	BieuDoTuoiNo.Add(New Structure("Nhom,SoTien", "TrongHan", 0));
	BieuDoTuoiNo.Add(New Structure("Nhom,SoTien", "QuaHan1Den30", 0));
	BieuDoTuoiNo.Add(New Structure("Nhom,SoTien", "QuaHan31Den60", 0));
	BieuDoTuoiNo.Add(New Structure("Nhom,SoTien", "QuaHan61Den90", 0));
	BieuDoTuoiNo.Add(New Structure("Nhom,SoTien", "QuaHanTren90", 0));
	For Each DongAR In BangChiTietAR Do
		TongARDuong = TongARDuong + DongAR.SoDuNo;
		NgayHoaDon = Date(Year(DongAR.NgayChungTu), Month(DongAR.NgayChungTu), Day(DongAR.NgayChungTu));
		NgayDenHan = NgayHoaDon + (Max(0, DongAR.HanThanhToanNgay) * 86400);
		If NgayDenHan < DauNgayBaoCao Then
			SoNgayQuaHan = Int((DauNgayBaoCao - NgayDenHan) / 86400);
			KetQua.NoPhaiThuQuaHan = KetQua.NoPhaiThuQuaHan + DongAR.SoDuNo;
			If SoNgayQuaHan <= 30 Then
				BieuDoTuoiNo[1].SoTien = BieuDoTuoiNo[1].SoTien + DongAR.SoDuNo;
			ElsIf SoNgayQuaHan <= 60 Then
				BieuDoTuoiNo[2].SoTien = BieuDoTuoiNo[2].SoTien + DongAR.SoDuNo;
			ElsIf SoNgayQuaHan <= 90 Then
				BieuDoTuoiNo[3].SoTien = BieuDoTuoiNo[3].SoTien + DongAR.SoDuNo;
			Else
				BieuDoTuoiNo[4].SoTien = BieuDoTuoiNo[4].SoTien + DongAR.SoDuNo;
			EndIf;
			
			ItemAR = New Structure;
			ItemAR.Insert("TenDoiTac", DongAR.TenDoiTac);
			ItemAR.Insert("MaDoiTac", DongAR.MaDoiTac);
			ItemAR.Insert("SoDuNo", DongAR.SoDuNo);
			ItemAR.Insert("SoNgayQuaHan", SoNgayQuaHan);
			ViTriTop = 0;
			While ViTriTop < DanhSachTopAR.Count() And ViTriTop < 5 Do
				If DanhSachTopAR[ViTriTop].SoDuNo < ItemAR.SoDuNo Then
					Break;
				EndIf;
				ViTriTop = ViTriTop + 1;
			EndDo;
			If ViTriTop < 5 Then
				DanhSachTopAR.Insert(ViTriTop, ItemAR);
				If DanhSachTopAR.Count() > 5 Then
					DanhSachTopAR.Delete(5);
				EndIf;
			EndIf;
		Else
			BieuDoTuoiNo[0].SoTien = BieuDoTuoiNo[0].SoTien + DongAR.SoDuNo;
		EndIf;
	EndDo;
	KetQua.TopNoQuaHan = DanhSachTopAR;
	KetQua.BieuDoTuoiNo = BieuDoTuoiNo;
	
	// 4. Khoan AP den han la cac khoan con phai tra co ngay den han khong sau ngay bao cao.
	TruyVanChiTietAP = New Query;
	TruyVanChiTietAP.Text =
		"SELECT
		|	AP.SoTienBalance AS SoDuNo,
		|	HoaDon.Date AS NgayChungTu,
		|	ContractRow.HanThanhToanNgay AS HanThanhToanNgay
		|FROM
		|	AccumulationRegister.CongNoPhaiTra.Balance AS AP
		|	INNER JOIN Document.HoaDonNhaCungCap AS HoaDon
		|	ON AP.ChungTuGoc = HoaDon.Ref
		|	INNER JOIN Catalog.HopDong AS ContractRow
		|	ON AP.HopDong = ContractRow.Ref
		|WHERE
		|	AP.SoTienBalance > 0
		|	AND HoaDon.Posted = TRUE
		|	AND HoaDon.DeletionMark = FALSE";
	BangChiTietAP = TruyVanChiTietAP.Execute().Unload();
	For Each DongAP In BangChiTietAP Do
		NgayHoaDonAP = Date(Year(DongAP.NgayChungTu), Month(DongAP.NgayChungTu), Day(DongAP.NgayChungTu));
		NgayDenHanAP = NgayHoaDonAP + (Max(0, DongAP.HanThanhToanNgay) * 86400);
		If NgayDenHanAP < DauNgayMai Then
			KetQua.NoPhaiTraDenHan = KetQua.NoPhaiTraDenHan + DongAP.SoDuNo;
		EndIf;
	EndDo;
	
	// 5. Tong hop cac chung tu dang cho xu ly theo trang thai workflow, loai tru ban nhap/tu choi.
	TrangThaiAP = New Array;
	TrangThaiAP.Add(Enums.TrangThaiHoaDonAP.ChoDuyetKyThuat);
	TrangThaiAP.Add(Enums.TrangThaiHoaDonAP.ChoDuyetPM);
	TrangThaiAP.Add(Enums.TrangThaiHoaDonAP.ChoDuyetITDirector);
	TrangThaiAP.Add(Enums.TrangThaiHoaDonAP.ChoDuyetCFO);
	TrangThaiAP.Add(Enums.TrangThaiHoaDonAP.ChoKeToanTruongDuyet);
	TrangThaiUNC = New Array;
	TrangThaiUNC.Add(Enums.TrangThaiLenhThanhToan.ChoDuyet);
	TrangThaiUNC.Add(Enums.TrangThaiLenhThanhToan.DaDuyet);
	TrangThaiUNC.Add(Enums.TrangThaiLenhThanhToan.DaGuiNganHang);
	TruyVanChoDuyet = New Query;
	TruyVanChoDuyet.Text =
		"SELECT TOP 5
		|	HD.LoaiChungTu AS LoaiChungTu,
		|	HD.TenLoaiChungTu AS TenLoaiChungTu,
		|	HD.SoChungTu AS SoChungTu,
		|	HD.NgayChungTu AS NgayChungTu,
		|	HD.SoTien AS SoTien
		|FROM
		|	(SELECT
		|		""HoaDonGTGTDauRa"" AS LoaiChungTu,
		|		""Hóa đơn GTGT đầu ra"" AS TenLoaiChungTu,
		|		HD_AR.Number AS SoChungTu,
		|		HD_AR.Date AS NgayChungTu,
		|		HD_AR.TongTienThanhToan AS SoTien
		|	FROM
		|		Document.HoaDonGTGTDauRa AS HD_AR
		|	WHERE
		|		HD_AR.Posted = FALSE
		|		AND HD_AR.DeletionMark = FALSE
		|		AND HD_AR.TrangThaiHDDT = VALUE(Enum.TrangThaiHoaDonDienTu.ChoKySo)
		|
		|	UNION ALL
		|
		|	SELECT
		|		""HoaDonNhaCungCap"" AS LoaiChungTu,
		|		""Hóa đơn NCC"" AS TenLoaiChungTu,
		|		HD_AP.Number AS SoChungTu,
		|		HD_AP.Date AS NgayChungTu,
		|		HD_AP.TongTien AS SoTien
		|	FROM
		|		Document.HoaDonNhaCungCap AS HD_AP
		|	WHERE
		|		HD_AP.Posted = FALSE
		|		AND HD_AP.DeletionMark = FALSE
		|		AND HD_AP.TrangThai IN (&TrangThaiAP)
		|
		|	UNION ALL
		|
		|	SELECT
		|		""UyNhiemChi"" AS LoaiChungTu,
		|		""Ủy nhiệm chi"" AS TenLoaiChungTu,
		|		UNC.Number AS SoChungTu,
		|		UNC.Date AS NgayChungTu,
		|		UNC.SoTien AS SoTien
		|	FROM
		|		Document.UyNhiemChi AS UNC
		|	WHERE
		|		UNC.Posted = FALSE
		|		AND UNC.DeletionMark = FALSE
		|		AND UNC.TrangThai IN (&TrangThaiUNC)) AS HD
		|ORDER BY
		|	HD.NgayChungTu DESC";
	TruyVanChoDuyet.SetParameter("TrangThaiAP", TrangThaiAP);
	TruyVanChoDuyet.SetParameter("TrangThaiUNC", TrangThaiUNC);
	BangChoDuyet = TruyVanChoDuyet.Execute().Unload();
	DanhSachChoDuyet = New Array;
	For Each Dong In BangChoDuyet Do
		ItemDoc = New Structure;
		ItemDoc.Insert("LoaiChungTu", Dong.LoaiChungTu);
		ItemDoc.Insert("TenLoaiChungTu", Dong.TenLoaiChungTu);
		ItemDoc.Insert("SoChungTu", Dong.SoChungTu);
		ItemDoc.Insert("NgayChungTu", Format(Dong.NgayChungTu, "DF=dd/MM/yyyy"));
		ItemDoc.Insert("SoTien", Dong.SoTien);
		DanhSachChoDuyet.Add(ItemDoc);
	EndDo;
	KetQua.TopChungTuChoDuyet = DanhSachChoDuyet;
	
	// 6. Serialize the result for the managed UI.
	GhiJSON = New JSONWriter;
	GhiJSON.SetString();
	WriteJSON(GhiJSON, KetQua);
	Return GhiJSON.Close();

EndFunction

// [FIX FONT] Chuyen moi ky tu ngoai ASCII trong HTML thanh ma an toan de hien thi dung tren ca Windows va Mac
// (Windows co the doc noi dung UTF-8 cua o HTML theo bang ma ANSI -> loi font "HÃ³a Ä‘Æ¡n").
// - Ngoai <script>/<style>: &#N;   - Trong <script>: \uXXXX   - Trong <style>: \XXXX (dau cach ket thuc)
Function ChuyenHTMLSangASCII(Val NoiDung) Export
	If IsBlankString(NoiDung) Then
		Return NoiDung;
	EndIf;
	Phan = New Array;
	DoDai = StrLen(NoiDung);
	VungLower = Lower(NoiDung);
	CheDo = 0; // 0 = HTML, 1 = script, 2 = style
	DauDoan = 1;
	i = 1;
	While i <= DoDai Do
		Ma = CharCode(NoiDung, i);
		If Ma = 60 Then // "<"
			If CheDo = 0 And Mid(VungLower, i, 7) = "<script" Then
				CheDo = 1;
			ElsIf CheDo = 0 And Mid(VungLower, i, 6) = "<style" Then
				CheDo = 2;
			ElsIf CheDo = 1 And Mid(VungLower, i, 9) = "</script>" Then
				CheDo = 0;
			ElsIf CheDo = 2 And Mid(VungLower, i, 8) = "</style>" Then
				CheDo = 0;
			EndIf;
			i = i + 1;
			Continue;
		EndIf;
		If Ma < 128 Then
			i = i + 1;
			Continue;
		EndIf;
		If i > DauDoan Then
			Phan.Add(Mid(NoiDung, DauDoan, i - DauDoan));
		EndIf;
		SoKyTu = 1;
		MaDayDu = Ma;
		If Ma >= 55296 And Ma <= 56319 And i < DoDai Then
			MaSau = CharCode(NoiDung, i + 1);
			If MaSau >= 56320 And MaSau <= 57343 Then
				MaDayDu = 65536 + (Ma - 55296) * 1024 + (MaSau - 56320);
				SoKyTu = 2;
			EndIf;
		EndIf;
		If CheDo = 1 Then
			For k = 0 To SoKyTu - 1 Do
				Phan.Add("\u" + MaHex4(CharCode(NoiDung, i + k)));
			EndDo;
		ElsIf CheDo = 2 Then
			Phan.Add("\" + MaHex4(MaDayDu) + " ");
		Else
			Phan.Add("&#" + Format(MaDayDu, "NG=0") + ";");
		EndIf;
		i = i + SoKyTu;
		DauDoan = i;
	EndDo;
	If DauDoan <= DoDai Then
		Phan.Add(Mid(NoiDung, DauDoan));
	EndIf;
	Return StrConcat(Phan);
EndFunction

Function MaHex4(Val So)
	KyTuHex = "0123456789ABCDEF";
	KetQua = "";
	While So > 0 Or StrLen(KetQua) < 4 Do
		KetQua = Mid(KyTuHex, So % 16 + 1, 1) + KetQua;
		So = Int(So / 16);
	EndDo;
	Return KetQua;
EndFunction
