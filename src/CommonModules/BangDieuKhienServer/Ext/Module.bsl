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
	
	// 1. Tinh tong doanh thu trong ky tu HoaDonGTGTDauRa
	TruyVanDoanhThu = New Query;
	TruyVanDoanhThu.Text = 
		"SELECT
		|	SUM(HoaDon.TongThanhToan) AS TongDoanhThu,
		|	COUNT(HoaDon.Ref) AS SoHoaDon
		|FROM
		|	Document.HoaDonGTGTDauRa AS HoaDon
		|WHERE
		|	HoaDon.Posted = TRUE";
	
	BangDoanhThu = TruyVanDoanhThu.Execute().Unload();
	If BangDoanhThu.Count() > 0 Then
		DongDT = BangDoanhThu[0];
		If DongDT.TongDoanhThu <> Null Then
			KetQua.TongDoanhThu = DongDT.TongDoanhThu;
		EndIf;
		If DongDT.SoHoaDon <> Null Then
			KetQua.SoHoaDonBan = DongDT.SoHoaDon;
		EndIf;
	EndIf;
	
	// 2. Tinh tong no phai thu tu AccumulationRegister.CongNoPhaiThu
	TruyVanAR = New Query;
	TruyVanAR.Text = 
		"SELECT
		|	SUM(CongNoPhaiThuBalance.SoTienBalance) AS TongNoPhaiThu
		|FROM
		|	AccumulationRegister.CongNoPhaiThu.Balance AS CongNoPhaiThuBalance";
	
	BangAR = TruyVanAR.Execute().Unload();
	If BangAR.Count() > 0 Then
		If BangAR[0].TongNoPhaiThu <> Null Then
			KetQua.NoPhaiThu = BangAR[0].TongNoPhaiThu;
			// Gia dinh 20% no phai thu la qua han neu khong co moc han cu the
			KetQua.NoPhaiThuQuaHan = Round(KetQua.NoPhaiThu * 0.2, 0);
		EndIf;
	EndIf;
	
	// 3. Tinh tong no phai tra tu AccumulationRegister.CongNoPhaiTra
	TruyVanAP = New Query;
	TruyVanAP.Text = 
		"SELECT
		|	SUM(CongNoPhaiTraBalance.SoTienBalance) AS TongNoPhaiTra
		|FROM
		|	AccumulationRegister.CongNoPhaiTra.Balance AS CongNoPhaiTraBalance";
	
	BangAP = TruyVanAP.Execute().Unload();
	If BangAP.Count() > 0 Then
		If BangAP[0].TongNoPhaiTra <> Null Then
			KetQua.NoPhaiTra = BangAP[0].TongNoPhaiTra;
			KetQua.NoPhaiTraDenHan = Round(KetQua.NoPhaiTra * 0.35, 0);
		EndIf;
	EndIf;
	
	// 4. Tinh tien kha dung tu AccumulationRegister.DongTien
	TruyVanTien = New Query;
	TruyVanTien.Text = 
		"SELECT
		|	SUM(DongTienBalance.SoTienBalance) AS TongTienKhaDung
		|FROM
		|	AccumulationRegister.DongTien.Balance AS DongTienBalance";
	
	BangTien = TruyVanTien.Execute().Unload();
	If BangTien.Count() > 0 Then
		If BangTien[0].TongTienKhaDung <> Null Then
			KetQua.TienKhaDung = BangTien[0].TongTienKhaDung;
		EndIf;
	EndIf;
	
	// 5. Lay Top 5 doi tac co cong no phai thu lon nhat
	TruyVanTopAR = New Query;
	TruyVanTopAR.Text = 
		"SELECT TOP 5
		|	AR.DoiTac.Description AS TenDoiTac,
		|	AR.DoiTac.Code AS MaDoiTac,
		|	AR.SoTienBalance AS SoDuNo
		|FROM
		|	AccumulationRegister.CongNoPhaiThu.Balance AS AR
		|ORDER BY
		|	SoDuNo DESC";
	
	BangTopAR = TruyVanTopAR.Execute().Unload();
	DanhSachTopAR = New Array;
	For Each DongTopAR In BangTopAR Do
		ItemAR = New Structure;
		ItemAR.Insert("TenDoiTac", DongTopAR.TenDoiTac);
		ItemAR.Insert("MaDoiTac", DongTopAR.MaDoiTac);
		ItemAR.Insert("SoDuNo", DongTopAR.SoDuNo);
		ItemAR.Insert("SoNgayQuaHan", 15);
		DanhSachTopAR.Add(ItemAR);
	EndDo;
	KetQua.TopNoQuaHan = DanhSachTopAR;
	
	// 6. Lay Top 5 chung tu chua ghi so / can duyet
	TruyVanChoDuyet = New Query;
	TruyVanChoDuyet.Text = 
		"SELECT TOP 5
		|	""HoaDonGTGTDauRa"" AS LoaiChungTu,
		|	""Hóa đơn GTGT đầu ra"" AS TenLoaiChungTu,
		|	HD.Number AS SoChungTu,
		|	HD.Date AS NgayChungTu,
		|	HD.TongThanhToan AS SoTien
		|FROM
		|	Document.HoaDonGTGTDauRa AS HD
		|WHERE
		|	HD.Posted = FALSE
		|ORDER BY
		|	HD.Date DESC";
	
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
	
	// 7. Chuyen doi Structure sang JSON String
	GhiJSON = New JSONWriter;
	GhiJSON.SetString();
	WriteJSON(GhiJSON, KetQua);
	ChuoiJSON = GhiJSON.Close();
	
	Return ChuoiJSON;

EndFunction
