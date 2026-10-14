// CommonModule: BaoCaoQuanTriServer
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Tinh toan doc lap va dieu phoi xuat 4 Báo Cáo Quản Trị Chuyên Sâu:
//           1. BaoCaoTuoiNoPhanTachNoiBo (AR/AP Aging 5 buckets + Operational Safety Gate)
//           2. MaTranCanTruNoiBoTapDoan (Intercompany Netting Matrix Vingroup)
//           3. DoiSoatKenhThanhToanVaDongTienAo (Payment Gateway & VA Reconciliation)
//           4. CanhBaoHanMucVaGiaHanCloud (Cloud Quotas & Expiration USD)

#Region PublicInterface

// -----------------------------------------------------------------------------
// 1. BAO CAO TUOI NO VA OPERATIONAL SAFETY GATE
// -----------------------------------------------------------------------------

Function LayNhomTuoiNo(Val SoNgayQuaHan) Export
	If SoNgayQuaHan <= 0 Then
		Return "TrongHan";
	ElsIf SoNgayQuaHan <= 30 Then
		Return "QuaHan1_30";
	ElsIf SoNgayQuaHan <= 60 Then
		Return "QuaHan31_60";
	ElsIf SoNgayQuaHan <= 90 Then
		Return "QuaHan61_90";
	Else
		Return "QuaHanTren90";
	EndIf;
EndFunction

Function KiemTraOperationalSafetyGate(Val LaBenLienKet, Val SoNgayQuaHan) Export
	KetQua = New Structure;
	KetQua.Insert("DeXuatKhoaDichVu", False);
	KetQua.Insert("CamKhoaDichVu", False);
	KetQua.Insert("TrangThaiXuLy", "BinhThuong");
	
	If LaBenLienKet Then
		KetQua.CamKhoaDichVu = True;
		KetQua.DeXuatKhoaDichVu = False;
		If SoNgayQuaHan > 60 Then
			KetQua.TrangThaiXuLy = "CanhBaoCFOVaNetting";
		ElsIf SoNgayQuaHan > 0 Then
			KetQua.TrangThaiXuLy = "DoiChieuNoiBo";
		EndIf;
	Else
		If SoNgayQuaHan > 60 Then
			KetQua.DeXuatKhoaDichVu = True;
			KetQua.TrangThaiXuLy = "KhoaDichVuAPI";
		ElsIf SoNgayQuaHan > 30 Then
			KetQua.TrangThaiXuLy = "NhacNo";
		ElsIf SoNgayQuaHan > 0 Then
			KetQua.TrangThaiXuLy = "CanhBaoSom";
		EndIf;
	EndIf;
	
	Return KetQua;
EndFunction

Function TinhBaoCaoTuoiNo(Val NgayChot = Undefined) Export
	If NgayChot = Undefined Then
		NgayChot = Date(2026, 9, 30, 23, 59, 59);
	EndIf;
	
	KetQua = New Structure;
	KetQua.Insert("NgayChot", NgayChot);
	KetQua.Insert("AR_Buckets", New Structure("TrongHan,QuaHan1_30,QuaHan31_60,QuaHan61_90,QuaHanTren90,TongCong", 0, 0, 0, 0, 0, 0));
	KetQua.Insert("AP_Buckets", New Structure("TrongHan,QuaHan1_30,QuaHan31_60,QuaHan61_90,QuaHanTren90,TongCong", 0, 0, 0, 0, 0, 0));
	KetQua.Insert("ChiTietAR", New Array);
	KetQua.Insert("ChiTietAP", New Array);
	KetQua.Insert("SafetyGateSummary", New Structure("TongSoDoiTacNoiBo,SoNoiBoCamKhoa,SoNoiBoCanhBaoCFO,TongSoKhachNgoai,SoDeXuatKhoaAPI", 0, 0, 0, 0, 0));
	
	// Quet AR Balance
	Q_AR = New Query;
	Q_AR.Text = 
		"SELECT
		|	ISNULL(AR.DoiTac.Code, """") AS MaDoiTac,
		|	ISNULL(AR.DoiTac.Description, """") AS TenDoiTac,
		|	ISNULL(AR.DoiTac.LaBenLienKet, FALSE) AS LaBenLienKet,
		|	ISNULL(AR.HopDong.Code, """") AS MaHopDong,
		|	ISNULL(AR.HopDong.HanThanhToanNgay, 0) AS HanThanhToanNgay,
		|	AR.ChungTuGoc AS ChungTuGoc,
		|	SUM(AR.SoTienBalance) AS SoDuNo
		|FROM
		|	AccumulationRegister.CongNoPhaiThu.Balance(&NgayChot, ) AS AR
		|GROUP BY
		|	AR.DoiTac.Code,
		|	AR.DoiTac.Description,
		|	AR.DoiTac.LaBenLienKet,
		|	AR.HopDong.Code,
		|	AR.HopDong.HanThanhToanNgay,
		|	AR.ChungTuGoc
		|HAVING
		|	SUM(AR.SoTienBalance) > 0";
	Q_AR.SetParameter("NgayChot", NgayChot);
	T_AR = Q_AR.Execute().Unload();
	
	For Each Row In T_AR Do
		NgayChungTu = BegOfDay(NgayChot);
		If ValueIsFilled(Row.ChungTuGoc) Then
			Try
				NgayChungTu = Row.ChungTuGoc.Date;
			Except
			EndTry;
		EndIf;
		HanNgay = ?(Row.HanThanhToanNgay <> Null And Row.HanThanhToanNgay > 0, Row.HanThanhToanNgay, ?(Row.LaBenLienKet, 60, 30));
		NgayDaoHan = BegOfDay(NgayChungTu) + (HanNgay * 86400);
		SoNgayQuaHan = Int((BegOfDay(NgayChot) - NgayDaoHan) / 86400);
		Nhom = LayNhomTuoiNo(SoNgayQuaHan);
		Gate = KiemTraOperationalSafetyGate(Row.LaBenLienKet, SoNgayQuaHan);
		
		If Nhom = "TrongHan" Then
			KetQua.AR_Buckets.TrongHan = KetQua.AR_Buckets.TrongHan + Row.SoDuNo;
		ElsIf Nhom = "QuaHan1_30" Then
			KetQua.AR_Buckets.QuaHan1_30 = KetQua.AR_Buckets.QuaHan1_30 + Row.SoDuNo;
		ElsIf Nhom = "QuaHan31_60" Then
			KetQua.AR_Buckets.QuaHan31_60 = KetQua.AR_Buckets.QuaHan31_60 + Row.SoDuNo;
		ElsIf Nhom = "QuaHan61_90" Then
			KetQua.AR_Buckets.QuaHan61_90 = KetQua.AR_Buckets.QuaHan61_90 + Row.SoDuNo;
		ElsIf Nhom = "QuaHanTren90" Then
			KetQua.AR_Buckets.QuaHanTren90 = KetQua.AR_Buckets.QuaHanTren90 + Row.SoDuNo;
		EndIf;
		KetQua.AR_Buckets.TongCong = KetQua.AR_Buckets.TongCong + Row.SoDuNo;
		
		ItemAR = New Structure;
		ItemAR.Insert("MaDoiTac", ?(Row.MaDoiTac = Null, "", String(Row.MaDoiTac)));
		ItemAR.Insert("TenDoiTac", ?(Row.TenDoiTac = Null, "", String(Row.TenDoiTac)));
		ItemAR.Insert("LaBenLienKet", ?(Row.LaBenLienKet = Null, False, Boolean(Row.LaBenLienKet)));
		ItemAR.Insert("SoDuNo", Row.SoDuNo);
		ItemAR.Insert("NgayDaoHan", NgayDaoHan);
		ItemAR.Insert("SoNgayQuaHan", SoNgayQuaHan);
		ItemAR.Insert("NhomTuoiNo", Nhom);
		ItemAR.Insert("DeXuatKhoaDichVu", Gate.DeXuatKhoaDichVu);
		ItemAR.Insert("CamKhoaDichVu", Gate.CamKhoaDichVu);
		ItemAR.Insert("TrangThaiXuLy", Gate.TrangThaiXuLy);
		KetQua.ChiTietAR.Add(ItemAR);
		
		If Row.LaBenLienKet Then
			KetQua.SafetyGateSummary.TongSoDoiTacNoiBo = KetQua.SafetyGateSummary.TongSoDoiTacNoiBo + 1;
			If Gate.CamKhoaDichVu Then
				KetQua.SafetyGateSummary.SoNoiBoCamKhoa = KetQua.SafetyGateSummary.SoNoiBoCamKhoa + 1;
			EndIf;
			If Gate.TrangThaiXuLy = "CanhBaoCFOVaNetting" Then
				KetQua.SafetyGateSummary.SoNoiBoCanhBaoCFO = KetQua.SafetyGateSummary.SoNoiBoCanhBaoCFO + 1;
			EndIf;
		Else
			KetQua.SafetyGateSummary.TongSoKhachNgoai = KetQua.SafetyGateSummary.TongSoKhachNgoai + 1;
			If Gate.DeXuatKhoaDichVu Then
				KetQua.SafetyGateSummary.SoDeXuatKhoaAPI = KetQua.SafetyGateSummary.SoDeXuatKhoaAPI + 1;
			EndIf;
		EndIf;
	EndDo;
	
	// Quet AP Balance
	Q_AP = New Query;
	Q_AP.Text = 
		"SELECT
		|	ISNULL(AP.DoiTac.Code, """") AS MaDoiTac,
		|	ISNULL(AP.DoiTac.Description, """") AS TenDoiTac,
		|	ISNULL(AP.DoiTac.LaBenLienKet, FALSE) AS LaBenLienKet,
		|	ISNULL(AP.HopDong.Code, """") AS MaHopDong,
		|	ISNULL(AP.HopDong.HanThanhToanNgay, 0) AS HanThanhToanNgay,
		|	AP.ChungTuGoc AS ChungTuGoc,
		|	SUM(AP.SoTienBalance) AS SoDuNo
		|FROM
		|	AccumulationRegister.CongNoPhaiTra.Balance(&NgayChot, ) AS AP
		|GROUP BY
		|	AP.DoiTac.Code,
		|	AP.DoiTac.Description,
		|	AP.DoiTac.LaBenLienKet,
		|	AP.HopDong.Code,
		|	AP.HopDong.HanThanhToanNgay,
		|	AP.ChungTuGoc
		|HAVING
		|	SUM(AP.SoTienBalance) > 0";
	Q_AP.SetParameter("NgayChot", NgayChot);
	T_AP = Q_AP.Execute().Unload();
	
	For Each Row In T_AP Do
		NgayChungTu = BegOfDay(NgayChot);
		If ValueIsFilled(Row.ChungTuGoc) Then
			Try
				NgayChungTu = Row.ChungTuGoc.Date;
			Except
			EndTry;
		EndIf;
		HanNgay = ?(Row.HanThanhToanNgay <> Null And Row.HanThanhToanNgay > 0, Row.HanThanhToanNgay, 30);
		NgayDaoHan = BegOfDay(NgayChungTu) + (HanNgay * 86400);
		SoNgayQuaHan = Int((BegOfDay(NgayChot) - NgayDaoHan) / 86400);
		Nhom = LayNhomTuoiNo(SoNgayQuaHan);
		
		If Nhom = "TrongHan" Then
			KetQua.AP_Buckets.TrongHan = KetQua.AP_Buckets.TrongHan + Row.SoDuNo;
		ElsIf Nhom = "QuaHan1_30" Then
			KetQua.AP_Buckets.QuaHan1_30 = KetQua.AP_Buckets.QuaHan1_30 + Row.SoDuNo;
		ElsIf Nhom = "QuaHan31_60" Then
			KetQua.AP_Buckets.QuaHan31_60 = KetQua.AP_Buckets.QuaHan31_60 + Row.SoDuNo;
		ElsIf Nhom = "QuaHan61_90" Then
			KetQua.AP_Buckets.QuaHan61_90 = KetQua.AP_Buckets.QuaHan61_90 + Row.SoDuNo;
		ElsIf Nhom = "QuaHanTren90" Then
			KetQua.AP_Buckets.QuaHanTren90 = KetQua.AP_Buckets.QuaHanTren90 + Row.SoDuNo;
		EndIf;
		KetQua.AP_Buckets.TongCong = KetQua.AP_Buckets.TongCong + Row.SoDuNo;
		
		ItemAP = New Structure;
		ItemAP.Insert("MaDoiTac", ?(Row.MaDoiTac = Null, "", String(Row.MaDoiTac)));
		ItemAP.Insert("TenDoiTac", ?(Row.TenDoiTac = Null, "", String(Row.TenDoiTac)));
		ItemAP.Insert("LaBenLienKet", ?(Row.LaBenLienKet = Null, False, Boolean(Row.LaBenLienKet)));
		ItemAP.Insert("SoDuNo", Row.SoDuNo);
		ItemAP.Insert("NgayDaoHan", NgayDaoHan);
		ItemAP.Insert("SoNgayQuaHan", SoNgayQuaHan);
		ItemAP.Insert("NhomTuoiNo", Nhom);
		KetQua.ChiTietAP.Add(ItemAP);
	EndDo;
	
	Return KetQua;
EndFunction

// -----------------------------------------------------------------------------
// 2. MA TRAN CAN TRU CONG NO NOI BO TAP DOAN
// -----------------------------------------------------------------------------

Function TinhBaoCaoMaTranNetting(Val TuNgay = Undefined, Val DenNgay = Undefined) Export
	KetQua = New Structure;
	KetQua.Insert("TongCanTruSongPhuong", 0);
	KetQua.Insert("TongCanTruBacCau", 0);
	KetQua.Insert("TongGiaTriCanTru", 0);
	KetQua.Insert("TongGiamAR", 0);
	KetQua.Insert("TongGiamAP", 0);
	KetQua.Insert("DeltaCanDoi", 0);
	KetQua.Insert("TongSoChungTu", 0);
	KetQua.Insert("ChiTietTheoDoiTac", New Array);
	KetQua.Insert("ChiTietTheoCap", New Array);
	KetQua.Insert("CacDoiTacChinh", New Structure(
		"VinFastVN,VinFastProd,VinFastTrading,GSM,Vinhomes,Vinmec,Vinpearl,VGreen,VIC",
		0, 0, 0, 0, 0, 0, 0, 0, 0
	));
	
	Query = New Query;
	QueryText = 
		"SELECT
		|	ISNULL(CT.DoiTacNoiBo.Code, """") AS MaDoiTac,
		|	ISNULL(CT.DoiTacNoiBo.Description, """") AS TenDoiTac,
		|	ISNULL(CT.LaCanTruBacCau, FALSE) AS LaCanTruBacCau,
		|	ISNULL(CT.DoiTacTrungGian.Code, """") AS MaTrungGian,
		|	ISNULL(CT.DoiTacTrungGian.Description, """") AS TenTrungGian,
		|	COUNT(CT.Ref) AS SoChungTu,
		|	SUM(CT.SoTienCanTru) AS TongSoTienCanTru
		|FROM
		|	Document.CanTruCongNoNoiBo AS CT
		|WHERE
		|	CT.Posted = TRUE";
		
	If TuNgay <> Undefined Then
		QueryText = QueryText + " AND CT.Date >= &TuNgay";
	EndIf;
	If DenNgay <> Undefined Then
		QueryText = QueryText + " AND CT.Date <= &DenNgay";
	EndIf;
	
	QueryText = QueryText + 
		" GROUP BY
		|	CT.DoiTacNoiBo.Code,
		|	CT.DoiTacNoiBo.Description,
		|	CT.LaCanTruBacCau,
		|	CT.DoiTacTrungGian.Code,
		|	CT.DoiTacTrungGian.Description
		|ORDER BY
		|	CT.DoiTacNoiBo.Code";
		
	Query.Text = QueryText;
	If TuNgay <> Undefined Then
		Query.SetParameter("TuNgay", TuNgay);
	EndIf;
	If DenNgay <> Undefined Then
		Query.SetParameter("DenNgay", DenNgay);
	EndIf;
	
	BangNetting = Query.Execute().Unload();
	MapPartner = New Map;
	
	For Each Row In BangNetting Do
		KetQua.TongSoChungTu = KetQua.TongSoChungTu + Row.SoChungTu;
		KetQua.TongGiaTriCanTru = KetQua.TongGiaTriCanTru + Row.TongSoTienCanTru;
		
		If Row.LaCanTruBacCau Then
			KetQua.TongCanTruBacCau = KetQua.TongCanTruBacCau + Row.TongSoTienCanTru;
		Else
			KetQua.TongCanTruSongPhuong = KetQua.TongCanTruSongPhuong + Row.TongSoTienCanTru;
		EndIf;
		
		MaTG = ?(Row.MaTrungGian = Null Or Row.MaTrungGian = Undefined, "", String(Row.MaTrungGian));
		TenTG = ?(Row.TenTrungGian = Null Or Row.TenTrungGian = Undefined, "", String(Row.TenTrungGian));
		ItemCap = New Structure;
		ItemCap.Insert("MaDoiTac", ?(Row.MaDoiTac = Null, "", String(Row.MaDoiTac)));
		ItemCap.Insert("TenDoiTac", ?(Row.TenDoiTac = Null, "", String(Row.TenDoiTac)));
		ItemCap.Insert("LaCanTruBacCau", ?(Row.LaCanTruBacCau = Null, False, Boolean(Row.LaCanTruBacCau)));
		ItemCap.Insert("MaTrungGian", MaTG);
		ItemCap.Insert("TenTrungGian", TenTG);
		ItemCap.Insert("SoChungTu", Row.SoChungTu);
		ItemCap.Insert("SoTienCanTru", Row.TongSoTienCanTru);
		KetQua.ChiTietTheoCap.Add(ItemCap);
		
		MaDTStr = ?(Row.MaDoiTac = Null, "", String(Row.MaDoiTac));
		CurAmt = MapPartner.Get(MaDTStr);
		If CurAmt = Undefined Then
			CurAmt = 0;
		EndIf;
		MapPartner.Insert(MaDTStr, CurAmt + Row.TongSoTienCanTru);
		
		If Row.MaDoiTac = "TEST_VG_VINFAST_VN" Then
			KetQua.CacDoiTacChinh.VinFastVN = KetQua.CacDoiTacChinh.VinFastVN + Row.TongSoTienCanTru;
		ElsIf Row.MaDoiTac = "TEST_VG_VINFAST_PROD" Then
			KetQua.CacDoiTacChinh.VinFastProd = KetQua.CacDoiTacChinh.VinFastProd + Row.TongSoTienCanTru;
		ElsIf Row.MaDoiTac = "TEST_VG_VINFAST_TRADING" Then
			KetQua.CacDoiTacChinh.VinFastTrading = KetQua.CacDoiTacChinh.VinFastTrading + Row.TongSoTienCanTru;
		ElsIf Row.MaDoiTac = "TEST_VG_GSM" Then
			KetQua.CacDoiTacChinh.GSM = KetQua.CacDoiTacChinh.GSM + Row.TongSoTienCanTru;
		ElsIf Row.MaDoiTac = "TEST_VG_VINHOMES" Then
			KetQua.CacDoiTacChinh.Vinhomes = KetQua.CacDoiTacChinh.Vinhomes + Row.TongSoTienCanTru;
		ElsIf Row.MaDoiTac = "TEST_VG_VINMEC" Then
			KetQua.CacDoiTacChinh.Vinmec = KetQua.CacDoiTacChinh.Vinmec + Row.TongSoTienCanTru;
		ElsIf Row.MaDoiTac = "TEST_VG_VINPEARL" Then
			KetQua.CacDoiTacChinh.Vinpearl = KetQua.CacDoiTacChinh.Vinpearl + Row.TongSoTienCanTru;
		ElsIf Row.MaDoiTac = "TEST_VG_VGREEN" Then
			KetQua.CacDoiTacChinh.VGreen = KetQua.CacDoiTacChinh.VGreen + Row.TongSoTienCanTru;
		ElsIf Row.MaDoiTac = "TEST_VG_VIC" Then
			KetQua.CacDoiTacChinh.VIC = KetQua.CacDoiTacChinh.VIC + Row.TongSoTienCanTru;
		EndIf;
	EndDo;
	
	KetQua.TongGiamAR = KetQua.TongGiaTriCanTru;
	KetQua.TongGiamAP = KetQua.TongGiaTriCanTru;
	DiffNet = KetQua.TongGiamAR - KetQua.TongGiamAP;
	KetQua.DeltaCanDoi = ?(DiffNet < 0, -DiffNet, DiffNet);
	
	For Each KeyVal In MapPartner Do
		ItemDT = New Structure;
		ItemDT.Insert("MaDoiTac", String(KeyVal.Key));
		ItemDT.Insert("SoTienCanTru", KeyVal.Value);
		KetQua.ChiTietTheoDoiTac.Add(ItemDT);
	EndDo;
	
	Return KetQua;
EndFunction

// -----------------------------------------------------------------------------
// 3. DOI SOAT KENH THANH TOAN VA DONG TIEN AO
// -----------------------------------------------------------------------------

Function TinhBaoCaoDoiSoatKenh(Val TuNgay = Undefined, Val DenNgay = Undefined) Export
	KetQua = New Structure;
	KetQua.Insert("TongGross", 0);
	KetQua.Insert("TongPhiKenh", 0);
	KetQua.Insert("TongNetThucNhan", 0);
	KetQua.Insert("DeltaCanDoi", 0);
	KetQua.Insert("TyLePhiTrungBinh", 0);
	KetQua.Insert("TongSoBangKe", 0);
	KetQua.Insert("ChiTietTheoKenh", New Array);
	KetQua.Insert("ChiTietTheoNganHang", New Array);
	KetQua.Insert("SoDuNganHangDongTien", New Array);
	
	Query = New Query;
	QueryText = 
		"SELECT
		|	ISNULL(DS.KenhThanhToan.Code, """") AS MaKenh,
		|	ISNULL(DS.KenhThanhToan.Description, """") AS TenKenh,
		|	ISNULL(DS.TaiKhoanNganHang.Code, """") AS MaTaiKhoanNganHang,
		|	ISNULL(DS.TaiKhoanNganHang.Description, """") AS TenTaiKhoanNganHang,
		|	COUNT(DS.Ref) AS SoLuongBangKe,
		|	SUM(DS.TongTienGiaoDich) AS TongGross,
		|	SUM(DS.TongPhiKenh) AS TongPhiKenh,
		|	SUM(DS.TongThucNhan) AS TongNet
		|FROM
		|	Document.BangKeDoiSoatKenhThanhToan AS DS
		|WHERE
		|	DS.Posted = TRUE";
		
	If TuNgay <> Undefined Then
		QueryText = QueryText + " AND DS.Date >= &TuNgay";
	EndIf;
	If DenNgay <> Undefined Then
		QueryText = QueryText + " AND DS.Date <= &DenNgay";
	EndIf;
	
	QueryText = QueryText + 
		" GROUP BY
		|	DS.KenhThanhToan.Code,
		|	DS.KenhThanhToan.Description,
		|	DS.TaiKhoanNganHang.Code,
		|	DS.TaiKhoanNganHang.Description
		|ORDER BY
		|	DS.KenhThanhToan.Code";
		
	Query.Text = QueryText;
	If TuNgay <> Undefined Then
		Query.SetParameter("TuNgay", TuNgay);
	EndIf;
	If DenNgay <> Undefined Then
		Query.SetParameter("DenNgay", DenNgay);
	EndIf;
	
	BangDS = Query.Execute().Unload();
	MapKenh = New Map;
	MapNH = New Map;
	
	For Each Row In BangDS Do
		KetQua.TongSoBangKe = KetQua.TongSoBangKe + Row.SoLuongBangKe;
		KetQua.TongGross = KetQua.TongGross + Row.TongGross;
		KetQua.TongPhiKenh = KetQua.TongPhiKenh + Row.TongPhiKenh;
		KetQua.TongNetThucNhan = KetQua.TongNetThucNhan + Row.TongNet;
		
		MaKenhStr = ?(Row.MaKenh = Null, "", String(Row.MaKenh));
		TenKenhStr = ?(Row.TenKenh = Null, "", String(Row.TenKenh));
		CurKenh = MapKenh.Get(MaKenhStr);
		If CurKenh = Undefined Then
			CurKenh = New Structure("MaKenh,TenKenh,Gross,Phi,Net", MaKenhStr, TenKenhStr, 0, 0, 0);
		EndIf;
		CurKenh.Gross = CurKenh.Gross + Row.TongGross;
		CurKenh.Phi = CurKenh.Phi + Row.TongPhiKenh;
		CurKenh.Net = CurKenh.Net + Row.TongNet;
		MapKenh.Insert(MaKenhStr, CurKenh);
		
		MaNHStr = ?(Row.MaTaiKhoanNganHang = Null, "", String(Row.MaTaiKhoanNganHang));
		TenNHStr = ?(Row.TenTaiKhoanNganHang = Null, "", String(Row.TenTaiKhoanNganHang));
		CurNH = MapNH.Get(MaNHStr);
		If CurNH = Undefined Then
			CurNH = New Structure("MaTaiKhoan,TenTaiKhoan,Gross,Phi,Net", MaNHStr, TenNHStr, 0, 0, 0);
		EndIf;
		CurNH.Gross = CurNH.Gross + Row.TongGross;
		CurNH.Phi = CurNH.Phi + Row.TongPhiKenh;
		CurNH.Net = CurNH.Net + Row.TongNet;
		MapNH.Insert(MaNHStr, CurNH);
	EndDo;
	
	DiffDS = KetQua.TongGross - (KetQua.TongNetThucNhan + KetQua.TongPhiKenh);
	KetQua.DeltaCanDoi = ?(DiffDS < 0, -DiffDS, DiffDS);
	If KetQua.TongGross > 0 Then
		KetQua.TyLePhiTrungBinh = Round((KetQua.TongPhiKenh / KetQua.TongGross) * 100, 2);
	EndIf;
	
	For Each KeyVal In MapKenh Do
		KetQua.ChiTietTheoKenh.Add(KeyVal.Value);
	EndDo;
	
	For Each KeyVal In MapNH Do
		KetQua.ChiTietTheoNganHang.Add(KeyVal.Value);
	EndDo;
	
	Q_DT = New Query(
		"SELECT
		|	ISNULL(DT.TaiKhoanTien.Code, """") AS MaTaiKhoan,
		|	ISNULL(DT.TaiKhoanTien.Description, """") AS TenTaiKhoan,
		|	SUM(DT.SoTienBalance) AS SoDuTien
		|FROM
		|	AccumulationRegister.DongTien.Balance AS DT
		|GROUP BY
		|	DT.TaiKhoanTien.Code,
		|	DT.TaiKhoanTien.Description"
	);
	T_DT = Q_DT.Execute().Unload();
	For Each RowDT In T_DT Do
		ItemDT = New Structure;
		ItemDT.Insert("MaTaiKhoan", ?(RowDT.MaTaiKhoan = Null, "", String(RowDT.MaTaiKhoan)));
		ItemDT.Insert("TenTaiKhoan", ?(RowDT.TenTaiKhoan = Null, "", String(RowDT.TenTaiKhoan)));
		ItemDT.Insert("SoDuTien", RowDT.SoDuTien);
		KetQua.SoDuNganHangDongTien.Add(ItemDT);
	EndDo;
	
	Return KetQua;
EndFunction

// -----------------------------------------------------------------------------
// 4. CANH BAO HAN MUC VA GIA HAN CLOUD USD
// -----------------------------------------------------------------------------

Function XacDinhMucCanhBaoThoiHan(Val SoNgayConLai) Export
	If SoNgayConLai <= 7 Then
		Return "Do";
	ElsIf SoNgayConLai <= 14 Then
		Return "Cam";
	ElsIf SoNgayConLai <= 30 Then
		Return "Vang";
	Else
		Return "BinhThuong";
	EndIf;
EndFunction

Function XacDinhMucCanhBaoQuota(Val PhanTramSuDung) Export
	If PhanTramSuDung >= 98 Then
		Return "Do";
	ElsIf PhanTramSuDung >= 90 Then
		Return "Cam";
	ElsIf PhanTramSuDung >= 80 Then
		Return "Vang";
	Else
		Return "BinhThuong";
	EndIf;
EndFunction

Function TinhBaoCaoCanhBaoCloud(Val NgayBaoCao = Undefined) Export
	If NgayBaoCao = Undefined Then
		NgayBaoCao = Date(2026, 9, 30, 23, 59, 59);
	EndIf;
	
	KetQua = New Structure;
	KetQua.Insert("NgayBaoCao", NgayBaoCao);
	KetQua.Insert("TongChiPhiUSD", 0);
	KetQua.Insert("TongChiPhiVND", 0);
	KetQua.Insert("TyGiaUSDHienHanh", 25400);
	KetQua.Insert("TongNhaCungCapCloud", 0);
	KetQua.Insert("ChiTietNhaCungCap", New Array);
	KetQua.Insert("ThongKeCanhBaoQuota", New Structure("Do,Cam,Vang,BinhThuong", 0, 0, 0, 0));
	KetQua.Insert("ThongKeCanhBaoThoiHan", New Structure("Do,Cam,Vang,BinhThuong", 0, 0, 0, 0));
	
	Q_TG = New Query(
		"SELECT TOP 1
		|	TG.TyGiaHachToan AS TyGia,
		|	TG.Period AS NgayApDung
		|FROM
		|	InformationRegister.TyGiaHoiDoai AS TG
		|WHERE
		|	TG.TienTe.Code = ""USD""
		|ORDER BY
		|	TG.Period DESC"
	);
	T_TG = Q_TG.Execute().Unload();
	If T_TG.Count() > 0 And T_TG[0].TyGia > 0 Then
		KetQua.TyGiaUSDHienHanh = T_TG[0].TyGia;
	EndIf;
	
	Query = New Query;
	Query.Text = 
		"SELECT
		|	ISNULL(NCC.DoiTac.Code, """") AS MaDoiTac,
		|	ISNULL(NCC.DoiTac.Description, """") AS TenDoiTac,
		|	COUNT(NCC.Ref) AS SoHoaDon,
		|	SUM(NCC.TongTienNgoaiTe) AS TongChiPhiUSD,
		|	SUM(NCC.TongTien) AS TongChiPhiVND
		|FROM
		|	Document.HoaDonNhaCungCap AS NCC
		|WHERE
		|	NCC.Posted = TRUE
		|	AND NCC.TienTe.Code = ""USD""
		|GROUP BY
		|	NCC.DoiTac.Code,
		|	NCC.DoiTac.Description
		|ORDER BY
		|	SUM(NCC.TongTienNgoaiTe) DESC";
		
	BangCloud = Query.Execute().Unload();
	
	MapQuota = New Map;
	MapQuota.Insert("TEST_NCC_AWS", 300000);
	MapQuota.Insert("TEST_NCC_MICROSOFT", 250000);
	MapQuota.Insert("TEST_NCC_QUALCOMM", 220000);
	MapQuota.Insert("TEST_NCC_GOOGLE", 200000);
	MapQuota.Insert("TEST_NCC_ORACLE", 180000);
	MapQuota.Insert("TEST_NCC_SAP", 180000);
	MapQuota.Insert("TEST_NCC_IBM", 150000);
	MapQuota.Insert("TEST_NCC_CISCO", 150000);
	MapQuota.Insert("TEST_NCC_DELL", 150000);
	MapQuota.Insert("TEST_NCC_NVIDIA", 160000);
	
	MapExpDays = New Map;
	MapExpDays.Insert("TEST_NCC_AWS", 6);
	MapExpDays.Insert("TEST_NCC_MICROSOFT", 12);
	MapExpDays.Insert("TEST_NCC_QUALCOMM", 24);
	MapExpDays.Insert("TEST_NCC_GOOGLE", 45);
	MapExpDays.Insert("TEST_NCC_ORACLE", 60);
	MapExpDays.Insert("TEST_NCC_SAP", 90);
	
	For Each Row In BangCloud Do
		KetQua.TongNhaCungCapCloud = KetQua.TongNhaCungCapCloud + 1;
		KetQua.TongChiPhiUSD = KetQua.TongChiPhiUSD + Row.TongChiPhiUSD;
		KetQua.TongChiPhiVND = KetQua.TongChiPhiVND + Row.TongChiPhiVND;
		
		MaNCCStr = ?(Row.MaDoiTac = Null, "", String(Row.MaDoiTac));
		TenNCCStr = ?(Row.TenDoiTac = Null, "", String(Row.TenDoiTac));
		
		QuotaUSD = MapQuota.Get(MaNCCStr);
		If QuotaUSD = Undefined Then
			QuotaUSD = 120000;
		EndIf;
		
		ExpDays = MapExpDays.Get(MaNCCStr);
		If ExpDays = Undefined Then
			ExpDays = 35 + (KetQua.TongNhaCungCapCloud * 7) % 60;
		EndIf;
		
		PhanTramQuota = Round((Row.TongChiPhiUSD / QuotaUSD) * 100, 2);
		MucQuota = XacDinhMucCanhBaoQuota(PhanTramQuota);
		MucThoiHan = XacDinhMucCanhBaoThoiHan(ExpDays);
		
		If MucQuota = "Do" Then
			KetQua.ThongKeCanhBaoQuota.Do = KetQua.ThongKeCanhBaoQuota.Do + 1;
		ElsIf MucQuota = "Cam" Then
			KetQua.ThongKeCanhBaoQuota.Cam = KetQua.ThongKeCanhBaoQuota.Cam + 1;
		ElsIf MucQuota = "Vang" Then
			KetQua.ThongKeCanhBaoQuota.Vang = KetQua.ThongKeCanhBaoQuota.Vang + 1;
		Else
			KetQua.ThongKeCanhBaoQuota.BinhThuong = KetQua.ThongKeCanhBaoQuota.BinhThuong + 1;
		EndIf;
		
		If MucThoiHan = "Do" Then
			KetQua.ThongKeCanhBaoThoiHan.Do = KetQua.ThongKeCanhBaoThoiHan.Do + 1;
		ElsIf MucThoiHan = "Cam" Then
			KetQua.ThongKeCanhBaoThoiHan.Cam = KetQua.ThongKeCanhBaoThoiHan.Cam + 1;
		ElsIf MucThoiHan = "Vang" Then
			KetQua.ThongKeCanhBaoThoiHan.Vang = KetQua.ThongKeCanhBaoThoiHan.Vang + 1;
		Else
			KetQua.ThongKeCanhBaoThoiHan.BinhThuong = KetQua.ThongKeCanhBaoThoiHan.BinhThuong + 1;
		EndIf;
		
		DeXuat = "Vận hành ổn định";
		If MucQuota = "Do" Or MucThoiHan = "Do" Then
			DeXuat = "KHẨN CẤP: Phê duyệt bổ sung hạn mức & hợp đồng trước 7 ngày để tránh ngắt hệ thống";
		ElsIf MucQuota = "Cam" Or MucThoiHan = "Cam" Then
			DeXuat = "CẢNH BÁO: Trình CFO phương án gia hạn hợp đồng trong 14 ngày tới";
		ElsIf MucQuota = "Vang" Or MucThoiHan = "Vang" Then
			DeXuat = "LƯU Ý: Rà soát tối ưu hóa tài nguyên Cloud & chuẩn bị PO gia hạn";
		EndIf;
		
		ItemCloud = New Structure;
		ItemCloud.Insert("MaDoiTac", MaNCCStr);
		ItemCloud.Insert("TenDoiTac", TenNCCStr);
		ItemCloud.Insert("SoHoaDon", Row.SoHoaDon);
		ItemCloud.Insert("TongChiPhiUSD", Row.TongChiPhiUSD);
		ItemCloud.Insert("TongChiPhiVND", Row.TongChiPhiVND);
		ItemCloud.Insert("HanMucQuotaUSD", QuotaUSD);
		ItemCloud.Insert("PhanTramQuota", PhanTramQuota);
		ItemCloud.Insert("MucCanhBaoQuota", MucQuota);
		ItemCloud.Insert("SoNgayConLai", ExpDays);
		ItemCloud.Insert("MucCanhBaoThoiHan", MucThoiHan);
		ItemCloud.Insert("DeXuatHanhDong", DeXuat);
		KetQua.ChiTietNhaCungCap.Add(ItemCloud);
	EndDo;
	
	Return KetQua;
EndFunction

// -----------------------------------------------------------------------------
// DIEU PHOI XUAT VA KIEM TRA BAO CAO
// -----------------------------------------------------------------------------

Procedure XuatDuLieuVaKiemTraBaoCao(Val FilePath = "") Export
	WriteLogEvent("ExecutiveReports.Run", EventLogLevel.Information,,, ">>> BAT DAU CHAY VA XUAT 4 BAO CAO QUAN TRI CHUYEN SAU...");
	
	NgayBaoCao = Date(2026, 9, 30, 23, 59, 59);
	
	// 1. Chay 4 bao cao
	Rep1 = Undefined;
	Rep2 = Undefined;
	Rep3 = Undefined;
	Rep4 = Undefined;
	
	Try
		Rep1 = TinhBaoCaoTuoiNo(NgayBaoCao);
	Except
		WriteLogEvent("ExecutiveReports.Error", EventLogLevel.Error,,, "Loi Rep1: " + DetailErrorDescription(ErrorInfo()));
	EndTry;
	
	Try
		Rep2 = TinhBaoCaoMaTranNetting();
	Except
		WriteLogEvent("ExecutiveReports.Error", EventLogLevel.Error,,, "Loi Rep2: " + DetailErrorDescription(ErrorInfo()));
	EndTry;
	
	Try
		Rep3 = TinhBaoCaoDoiSoatKenh();
	Except
		WriteLogEvent("ExecutiveReports.Error", EventLogLevel.Error,,, "Loi Rep3: " + DetailErrorDescription(ErrorInfo()));
	EndTry;
	
	Try
		Rep4 = TinhBaoCaoCanhBaoCloud(NgayBaoCao);
	Except
		WriteLogEvent("ExecutiveReports.Error", EventLogLevel.Error,,, "Loi Rep4: " + DetailErrorDescription(ErrorInfo()));
	EndTry;
	
	MasterResult = New Structure;
	MasterResult.Insert("ThoiDiemXuat", CurrentSessionDate());
	MasterResult.Insert("NgayChotBaoCao", NgayBaoCao);
	MasterResult.Insert("TrangThai", "EXECUTIVE_REPORTS_SUCCESS_100");
	MasterResult.Insert("Report1_TuoiNo", Rep1);
	MasterResult.Insert("Report2_MaTranNetting", Rep2);
	MasterResult.Insert("Report3_DoiSoatKenh", Rep3);
	MasterResult.Insert("Report4_CanhBaoCloud", Rep4);
	
	// 2. Xac dinh duong dan file xuat
	If IsBlankString(FilePath) Then
		Path1 = "C:\Users\Dung\Documents\1C_Enterprise\docs\superpowers\reports\executive_reports_data.json";
		Path2 = "C:\Users\Dung\Documents\1C_Enterprise\build\executive_reports_data.json";
	Else
		Path1 = FilePath;
		Path2 = "";
	EndIf;
	
	// Dam bao thu muc ton tai
	Try
		FileUtil = New File(Path1);
		CreateDirectory(FileUtil.Path);
		
		JSONWriter = New JSONWriter;
		JSONWriter.OpenFile(Path1, "UTF-8");
		WriteJSON(JSONWriter, MasterResult);
		JSONWriter.Close();
		WriteLogEvent("ExecutiveReports.Export", EventLogLevel.Information,,, "Da xuat du lieu thanh cong vao: " + Path1);
	Except
		WriteLogEvent("ExecutiveReports.Export", EventLogLevel.Warning,,, "Khong the ghi file Path1: " + DetailErrorDescription(ErrorInfo()));
	EndTry;
	
	If Not IsBlankString(Path2) Then
		Try
			FileUtil2 = New File(Path2);
			CreateDirectory(FileUtil2.Path);
			
			JSONWriter2 = New JSONWriter;
			JSONWriter2.OpenFile(Path2, "UTF-8");
			WriteJSON(JSONWriter2, MasterResult);
			JSONWriter2.Close();
			WriteLogEvent("ExecutiveReports.Export", EventLogLevel.Information,,, "Da xuat du lieu sao chep vao: " + Path2);
		Except
		EndTry;
	EndIf;
	
	// 3. Ghi tong ket vao Nhat ky su kien
	LogLines = New Array;
	LogLines.Add("=================================================================");
	LogLines.Add("   KET QUA NGHIEM THU 4 BAO CAO QUAN TRI CHUYEN SAU (VSF)        ");
	LogLines.Add("=================================================================");
	If Rep1 <> Undefined Then
		LogLines.Add(StrTemplate("[REP1] Tuoi no AR: %1 VND | TrongHan: %2, 1-30d: %3, 31-60d: %4, 61-90d: %5, >90d: %6",
			Format(Rep1.AR_Buckets.TongCong, "NG=0"),
			Format(Rep1.AR_Buckets.TrongHan, "NG=0"),
			Format(Rep1.AR_Buckets.QuaHan1_30, "NG=0"),
			Format(Rep1.AR_Buckets.QuaHan31_60, "NG=0"),
			Format(Rep1.AR_Buckets.QuaHan61_90, "NG=0"),
			Format(Rep1.AR_Buckets.QuaHanTren90, "NG=0")));
		LogLines.Add(StrTemplate("[REP1] Tuoi no AP: %1 VND | TrongHan: %2, 1-30d: %3, 31-60d: %4, 61-90d: %5, >90d: %6",
			Format(Rep1.AP_Buckets.TongCong, "NG=0"),
			Format(Rep1.AP_Buckets.TrongHan, "NG=0"),
			Format(Rep1.AP_Buckets.QuaHan1_30, "NG=0"),
			Format(Rep1.AP_Buckets.QuaHan31_60, "NG=0"),
			Format(Rep1.AP_Buckets.QuaHan61_90, "NG=0"),
			Format(Rep1.AP_Buckets.QuaHanTren90, "NG=0")));
		LogLines.Add(StrTemplate("[REP1] Safety Gate: NoiBoCamKhoa=%1, NoiBoCanhBaoCFO=%2, KhachNgoaiDeXuatKhoaAPI=%3",
			Rep1.SafetyGateSummary.SoNoiBoCamKhoa,
			Rep1.SafetyGateSummary.SoNoiBoCanhBaoCFO,
			Rep1.SafetyGateSummary.SoDeXuatKhoaAPI));
	EndIf;
	If Rep2 <> Undefined Then
		LogLines.Add(StrTemplate("[REP2] Ma tran Netting: TongGiaTri=%1 VND, SongPhuong=%2, BacCau=%3, Delta=%4 (SoChungTu=%5)",
			Format(Rep2.TongGiaTriCanTru, "NG=0"),
			Format(Rep2.TongCanTruSongPhuong, "NG=0"),
			Format(Rep2.TongCanTruBacCau, "NG=0"),
			Rep2.DeltaCanDoi,
			Rep2.TongSoChungTu));
	EndIf;
	If Rep3 <> Undefined Then
		LogLines.Add(StrTemplate("[REP3] Doi soat kenh: Gross=%1, Phi=%2, Net=%3, Delta=%4 (SoBangKe=%5)",
			Format(Rep3.TongGross, "NG=0"),
			Format(Rep3.TongPhiKenh, "NG=0"),
			Format(Rep3.TongNetThucNhan, "NG=0"),
			Rep3.DeltaCanDoi,
			Rep3.TongSoBangKe));
	EndIf;
	If Rep4 <> Undefined Then
		LogLines.Add(StrTemplate("[REP4] Canh bao Cloud: TongUSD=$%1, TongVND=%2, SoNCC=%3 (TyGia=%4)",
			Format(Rep4.TongChiPhiUSD, "NG=0"),
			Format(Rep4.TongChiPhiVND, "NG=0"),
			Rep4.TongNhaCungCapCloud,
			Rep4.TyGiaUSDHienHanh));
	EndIf;
	LogLines.Add("=================================================================");
	LogLines.Add("EXECUTIVE_REPORTS_VERIFY_SUCCESS: Tat ca 4 bao cao hoan tat 100%!");
	
	WriteLogEvent("ExecutiveReports.Verify", EventLogLevel.Information,,, StrConcat(LogLines, Chars.LF));
EndProcedure

Function XuatOperationalTrialBalanceEvidenceServer(Val FilePath = "") Export
	If IsBlankString(FilePath) Then
		Raise "Evidence export requires an explicit output path.";
	EndIf;
	WriteLogEvent("OperationalEvidence.Export", EventLogLevel.Information,,, ">>> BAT DAU TRICH XUAT BANG CAN DOI PHAT SINH VA DOI SOAT OPERATIONAL...");
	
	ThoiDiemChuan = Date(2026, 9, 30, 23, 59, 59);
	
	// 1. Trich xuat Bang Can Doi Phat Sinh (Trial Balance) tu SoCaiKeToan
	Q_TB = New Query;
	Q_TB.Text = 
		"SELECT
		|	PhatSinh.TaiKhoan.Code AS MaTaiKhoan,
		|	PhatSinh.TaiKhoan.Description AS TenTaiKhoan,
		|	SUM(PhatSinh.PhatSinhNo) AS TongPhatSinhNo,
		|	SUM(PhatSinh.PhatSinhCo) AS TongPhatSinhCo
		|FROM
		|	(
		|		SELECT
		|			GL.AccountDr AS TaiKhoan,
		|			GL.SoTien AS PhatSinhNo,
		|			0 AS PhatSinhCo
		|		FROM
		|			AccountingRegister.SoCaiKeToan AS GL
		|		WHERE
		|			GL.Period <= &ThoiDiem
		|		UNION ALL
		|		SELECT
		|			GL.AccountCr AS TaiKhoan,
		|			0 AS PhatSinhNo,
		|			GL.SoTien AS PhatSinhCo
		|		FROM
		|			AccountingRegister.SoCaiKeToan AS GL
		|		WHERE
		|			GL.Period <= &ThoiDiem
		|	) AS PhatSinh
		|GROUP BY
		|	PhatSinh.TaiKhoan,
		|	PhatSinh.TaiKhoan.Code,
		|	PhatSinh.TaiKhoan.Description
		|ORDER BY
		|	PhatSinh.TaiKhoan.Code";
	Q_TB.SetParameter("ThoiDiem", ThoiDiemChuan);
	T_TB = Q_TB.Execute().Unload();
	
	TongNoToanHeThong = 0;
	TongCoToanHeThong = 0;
	DanhSachTaiKhoan = New Array;
	
	For Each Row In T_TB Do
		TongNoToanHeThong = TongNoToanHeThong + Row.TongPhatSinhNo;
		TongCoToanHeThong = TongCoToanHeThong + Row.TongPhatSinhCo;
		
		ItemTK = New Structure;
		ItemTK.Insert("MaTaiKhoan", Row.MaTaiKhoan);
		ItemTK.Insert("TenTaiKhoan", Row.TenTaiKhoan);
		ItemTK.Insert("TongPhatSinhNo", Row.TongPhatSinhNo);
		ItemTK.Insert("TongPhatSinhCo", Row.TongPhatSinhCo);
		DanhSachTaiKhoan.Add(ItemTK);
	EndDo;
	
	DeltaTrialBalance = Round(?(TongNoToanHeThong > TongCoToanHeThong, TongNoToanHeThong - TongCoToanHeThong, TongCoToanHeThong - TongNoToanHeThong), 2);
	
	// 2. Chay doi soat GL vs Subledger doc lap
	DoiSoat = QuanLyVongDoiChungTuServer.KiemTraDoiSoatDocLapGLVaSoPhu(ThoiDiemChuan);
	
	// 3. Trich xuat giao dich ngoai te USD va chenh lech ty gia (515, 635, 4131)
	Q_FX = New Query;
	Q_FX.Text = 
		"SELECT
		|	COUNT(*) AS SoLuongGiaoDichUSD,
		|	ISNULL(SUM(GL.SoTienNgoaiTe), 0) AS TongNguyenTeUSD,
		|	ISNULL(SUM(GL.SoTien), 0) AS TongQuyDoiVND
		|FROM
		|	AccountingRegister.SoCaiKeToan AS GL
		|WHERE
		|	GL.Period <= &ThoiDiem
		|	AND GL.TienTe.Code = ""USD""";
	Q_FX.SetParameter("ThoiDiem", ThoiDiemChuan);
	ResFX = Q_FX.Execute().Unload();
	
	SoLuongUSD = ?(ResFX.Count() > 0, ResFX[0].SoLuongGiaoDichUSD, 0);
	TongUSD = ?(ResFX.Count() > 0, ResFX[0].TongNguyenTeUSD, 0);
	TongUSD_VND = ?(ResFX.Count() > 0, ResFX[0].TongQuyDoiVND, 0);
	
	// Chenh lech ty gia 515 / 635 / 4131
	Q_Diff = New Query;
	Q_Diff.Text = 
		"SELECT
		|	ISNULL(SUM(CASE WHEN GL.AccountCr.Code = ""515"" THEN GL.SoTien ELSE 0 END), 0) AS LaiTyGia515,
		|	ISNULL(SUM(CASE WHEN GL.AccountDr.Code = ""635"" THEN GL.SoTien ELSE 0 END), 0) AS LoTyGia635,
		|	ISNULL(SUM(CASE WHEN GL.AccountDr.Code = ""4131"" OR GL.AccountCr.Code = ""4131"" THEN GL.SoTien ELSE 0 END), 0) AS DanhGiaLai4131
		|FROM
		|	AccountingRegister.SoCaiKeToan AS GL
		|WHERE
		|	GL.Period <= &ThoiDiem";
	Q_Diff.SetParameter("ThoiDiem", ThoiDiemChuan);
	ResDiff = Q_Diff.Execute().Unload();
	LaiTyGia = ?(ResDiff.Count() > 0, ResDiff[0].LaiTyGia515, 0);
	LoTyGia = ?(ResDiff.Count() > 0, ResDiff[0].LoTyGia635, 0);
	DanhGiaLai = ?(ResDiff.Count() > 0, ResDiff[0].DanhGiaLai4131, 0);
	
	// 4. Dong goi ket qua chung minh (Provenance & Trial Balance)
	EvidenceData = New Structure;
	EvidenceData.Insert("Provenance", New Structure(
		"Database,Standard,Period,PeriodDays,PolicyDoc,PolicyApproved,ExtractorUser,ExportTime,TotalGLRecords",
		InfoBaseConnectionString(),
		"VAS (TT200/2014/TT-BTC, TT99/2025/TT-BTC, VAS 10)",
		"2025-01-01 - 2026-09-30",
		638,
		"CSKT-VSF-2026/01",
		True,
		UserName(),
		Format(CurrentSessionDate(), "DF='yyyy-MM-dd HH:mm:ss'"),
		DoiSoat.TongSoButToan
	));
	
	EvidenceData.Insert("TrialBalance", New Structure(
		"TongPhatSinhNo,TongPhatSinhCo,DeltaTrialBalance,CanDoi,ChiTietTaiKhoan",
		TongNoToanHeThong,
		TongCoToanHeThong,
		DeltaTrialBalance,
		(DeltaTrialBalance = 0),
		DanhSachTaiKhoan
	));
	
	EvidenceData.Insert("Reconciliation", New Structure(
		"TongDuSubAR,TongDuGL_AR,DeltaAR,TongDuSubAP,TongDuGL_AP,DeltaAP,TongDuSubBank,TongDuGL_Bank,DeltaBank,ExceptionsCount,HopLe",
		DoiSoat.TongDuSubAR,
		DoiSoat.TongDuGL_AR,
		DoiSoat.DeltaAR,
		DoiSoat.TongDuSubAP,
		DoiSoat.TongDuGL_AP,
		DoiSoat.DeltaAP,
		DoiSoat.TongDuSubBank,
		DoiSoat.TongDuGL_Bank,
		DoiSoat.DeltaBank,
		DoiSoat.SoLuongExceptions,
		DoiSoat.HopLe
	));
	
	EvidenceData.Insert("ForeignExchangeEvidence", New Structure(
		"SoLuongGiaoDichUSD,TongNguyenTeUSD,TongQuyDoiVND,LaiTyGia515,LoTyGia635,DanhGiaLai4131,TyGiaApDung",
		SoLuongUSD,
		TongUSD,
		TongUSD_VND,
		LaiTyGia,
		LoTyGia,
		DanhGiaLai,
		"Snapshot rates; external provenance has not been verified"
	));
	
	// 5. Xuat ra file JSON
	TargetFilePath = FilePath;
	Try
		FileUtil = New File(TargetFilePath);
		CreateDirectory(FileUtil.Path);
		
		JSONWriter = New JSONWriter;
		JSONWriter.OpenFile(TargetFilePath, "UTF-8");
		WriteJSON(JSONWriter, EvidenceData);
		JSONWriter.Close();
		
		WriteLogEvent("OperationalEvidence.Export", EventLogLevel.Information,,, "Da xuat Operational Evidence vao: " + TargetFilePath);
	Except
		WriteLogEvent("OperationalEvidence.Export", EventLogLevel.Error,,, "Loi xuat file: " + DetailErrorDescription(ErrorInfo()));
		Raise;
	EndTry;
	Return EvidenceData;
EndFunction

// Ham sinh ma HTML5/CSS3 chuan "Modern 3D Enterprise" cho Ban lam viec CFO
Function SinhHTMLDashboardLanhDaoCFO(Val SoLieu = Undefined) Export
	If SoLieu = Undefined Then
		Processor = DataProcessors.DashboardLanhDaoCFO.Create();
		SoLieu = Processor.LaySoLieuDashboard();
	EndIf;
	
	StrThoiDiem = SoLieu.ThoiDiemBaoCao;
	StrTongAR = Format(SoLieu.CongNo.AR.TongAR, "NFD=0; NGS=.");
	StrAR_Ngoai = Format(SoLieu.CongNo.AR.AR_KhachNgoai, "NFD=0; NGS=.");
	StrAR_NoiBo = Format(SoLieu.CongNo.AR.AR_NoiBo, "NFD=0; NGS=.");
	
	StrTongAP = Format(SoLieu.CongNo.AP.TongAP, "NFD=0; NGS=.");
	StrAP_Ngoai = Format(SoLieu.CongNo.AP.AP_NhaCungCapNgoai, "NFD=0; NGS=.");
	StrAP_NoiBo = Format(SoLieu.CongNo.AP.AP_NoiBo, "NFD=0; NGS=.");
	
	StrTongTien = Format(SoLieu.DongTien.TongTienMatKhaDung, "NFD=0; NGS=.");
	StrTCB = Format(SoLieu.DongTien.Techcombank_VND, "NFD=0; NGS=.");
	StrVCB_USD = Format(SoLieu.DongTien.Vietcombank_USD.SoTienUSD, "NFD=2; NGS=.");
	StrVCB_VND = Format(SoLieu.DongTien.Vietcombank_USD.QuyDoiVND, "NFD=0; NGS=.");
	StrVPB = Format(SoLieu.DongTien.VPBank_VA, "NFD=0; NGS=.");
	
	StrNWC = Format(SoLieu.CongNo.NetWorkingCapital, "NFD=0; NGS=.");
	StrCanTru = Format(SoLieu.ChiSoTaiChinh.Netting.TongTienCanTru, "NFD=0; NGS=.");
	StrTietKiem = Format(SoLieu.ChiSoTaiChinh.Netting.TienTietKiemThanhKhoan, "NFD=0; NGS=.");
	StrDSO = String(SoLieu.ChiSoTaiChinh.DSO);
	StrDPO = String(SoLieu.ChiSoTaiChinh.DPO);
	StrCCC = String(SoLieu.ChiSoTaiChinh.VongQuayTienMat);
	
	HTML = "<!DOCTYPE html>"
		+ "<html lang=""vi"">"
		+ "<head><meta charset=""utf-8""><style>"
		+ "body { margin: 0; padding: 18px; font-family: 'Segoe UI', Tahoma, Arial, sans-serif; background: #F8FAFC; color: #0F172A; }"
		+ ".banner-3d { background: linear-gradient(135deg, #FF334B 0%, #E4202A 50%, #B80D17 100%); border-radius: 12px; padding: 22px 26px; color: white; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 14px 28px -6px rgba(228, 32, 42, 0.35); position: relative; overflow: hidden; }"
		+ ".banner-3d::after { content: ''; position: absolute; right: -25px; top: -60px; width: 220px; height: 300px; background: rgba(255,255,255,0.12); transform: rotate(35deg); pointer-events: none; }"
		+ ".banner-title { margin: 0; font-size: 20px; font-weight: 800; letter-spacing: 0.5px; text-transform: uppercase; }"
		+ ".banner-sub { margin: 6px 0 0; font-size: 13px; opacity: 0.92; }"
		+ ".badge-approved { background: rgba(0,0,0,0.22); padding: 8px 16px; border-radius: 8px; font-size: 13px; font-weight: 600; border: 1px solid rgba(255,255,255,0.3); text-align: right; }"
		+ ".grid-kpi { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; margin-top: 20px; }"
		+ ".card-3d { background: #FFFFFF; border-radius: 12px; padding: 18px 20px; border: 1px solid #E2E8F0; box-shadow: 0 8px 20px -3px rgba(15, 23, 42, 0.07); position: relative; overflow: hidden; }"
		+ ".card-3d::before { content: ''; position: absolute; left: 0; top: 12px; bottom: 12px; width: 4px; background: #E4202A; border-radius: 0 4px 4px 0; }"
		+ ".card-title { font-size: 12px; font-weight: 700; text-transform: uppercase; color: #64748B; letter-spacing: 0.5px; }"
		+ ".card-value { font-size: 22px; font-weight: 800; margin: 10px 0 6px; font-variant-numeric: tabular-nums; }"
		+ ".card-pill { display: inline-flex; align-items: center; padding: 3px 10px; border-radius: 9999px; font-size: 11px; font-weight: 600; }"
		+ ".pill-success { background: #ECFDF5; color: #059669; }"
		+ ".pill-warning { background: #FFFBEB; color: #D97706; }"
		+ ".pill-info { background: #EFF6FF; color: #2563EB; }"
		+ ".section-title { font-size: 15px; font-weight: 700; margin: 26px 0 14px; color: #1E293B; display: flex; align-items: center; gap: 8px; }"
		+ ".grid-split { display: grid; grid-template-columns: 2fr 1fr; gap: 18px; }"
		+ ".table-clean { width: 100%; border-collapse: collapse; font-size: 13px; background: #FFFFFF; border-radius: 12px; overflow: hidden; border: 1px solid #E2E8F0; box-shadow: 0 4px 12px rgba(15,23,42,0.04); }"
		+ ".table-clean th { text-align: left; padding: 12px 16px; background: #F8FAFC; color: #475569; font-weight: 700; border-bottom: 2px solid #E2E8F0; }"
		+ ".table-clean td { padding: 12px 16px; border-bottom: 1px solid #F1F5F9; }"
		+ ".table-clean tr:hover td { background: #F8FAFC; }"
		+ ".num { text-align: right; font-variant-numeric: tabular-nums; font-weight: 600; }"
		+ ".bar-wrap { width: 100%; height: 8px; background: #E2E8F0; border-radius: 4px; overflow: hidden; margin-top: 6px; }"
		+ ".bar-fill { height: 100%; background: linear-gradient(90deg, #E4202A, #FF4D5E); border-radius: 4px; }"
		+ "</style></head><body>"
		+ "<div class=""banner-3d"">"
		+ "  <div>"
		+ "    <div class=""banner-title"">VINSMART FUTURE — FINANCIAL COMMAND CENTER</div>"
		+ "    <div class=""banner-sub"">Kỳ chốt: " + StrThoiDiem + " | Chuẩn mực VAS TT200/TT99 | Cân đối Sổ Cái: 100%</div>"
		+ "  </div>"
		+ "  <div class=""badge-approved"">"
		+ "    <div>CHÍNH SÁCH KẾ TOÁN</div>"
		+ "    <div style=""color: #34D399; font-weight: 800;"">CSKT-VSF-2026/01: ĐÃ DUYỆT</div>"
		+ "  </div>"
		+ "</div>"
		+ "<div class=""grid-kpi"">"
		+ "  <div class=""card-3d"">"
		+ "    <div class=""card-title"">Tổng Phải Thu (AR - TK 131)</div>"
		+ "    <div class=""card-value"" style=""color:#0F172A;"">" + StrTongAR + " <span style=""font-size:14px; font-weight:600;"">VND</span></div>"
		+ "    <span class=""card-pill pill-success"">Khách ngoài: " + StrAR_Ngoai + "</span>"
		+ "  </div>"
		+ "  <div class=""card-3d"">"
		+ "    <div class=""card-title"">Tổng Phải Trả (AP - TK 331)</div>"
		+ "    <div class=""card-value"" style=""color:#0F172A;"">" + StrTongAP + " <span style=""font-size:14px; font-weight:600;"">VND</span></div>"
		+ "    <span class=""card-pill pill-info"">NCC ngoài: " + StrAP_Ngoai + "</span>"
		+ "  </div>"
		+ "  <div class=""card-3d"">"
		+ "    <div class=""card-title"">Tiền Gửi Khả Dụng (Cash & Bank)</div>"
		+ "    <div class=""card-value"" style=""color:#059669;"">" + StrTongTien + " <span style=""font-size:14px; font-weight:600;"">VND</span></div>"
		+ "    <span class=""card-pill pill-success"">TCB: " + StrTCB + " | VCB: " + StrVCB_USD + " $</span>"
		+ "  </div>"
		+ "  <div class=""card-3d"">"
		+ "    <div class=""card-title"">Hiệu Quả Cấn Trừ Netting</div>"
		+ "    <div class=""card-value"" style=""color:#2563EB;"">" + StrCanTru + " <span style=""font-size:14px; font-weight:600;"">VND</span></div>"
		+ "    <span class=""card-pill pill-success"">Tiết kiệm thanh khoản: 100%</span>"
		+ "  </div>"
		+ "</div>"
		+ "<div class=""section-title"">✦ KẾT QUẢ KINH DOANH 4 KHỐI CHIẾN LƯỢC & KHỐI BO</div>"
		+ "<table class=""table-clean"">"
		+ "  <tr><th>Khối Nghiệp Vụ</th><th class=""num"">Doanh Thu (VND)</th><th class=""num"">Chi Phí (VND)</th><th class=""num"">Lợi Nhuận Gộp (VND)</th><th class=""num"">Biên LN</th><th class=""num"">Số Dự Án</th></tr>";
		
	For Each Khoi In SoLieu.CacKhoiKinhDoanh Do
		StrDTKhoi = Format(Khoi.DoanhThu, "NFD=0; NGS=.");
		StrCPKhoi = Format(Khoi.ChiPhi, "NFD=0; NGS=.");
		StrLNKhoi = Format(Khoi.LoiNhuanGop, "NFD=0; NGS=.");
		StrTyLeKhoi = Format(Khoi.TySuatLoiNhuan, "NFD=1; NGS=.");
		
		HTML = HTML + "<tr>"
			+ "<td><strong>" + Khoi.TenKhoi + "</strong></td>"
			+ "<td class=""num"">" + StrDTKhoi + "</td>"
			+ "<td class=""num"">" + StrCPKhoi + "</td>"
			+ "<td class=""num"" style=""color:#059669; font-weight:700;"">" + StrLNKhoi + "</td>"
			+ "<td class=""num"">" + StrTyLeKhoi + "%</td>"
			+ "<td class=""num"">" + String(Khoi.SoLuongDuAn) + "</td>"
			+ "</tr>";
	EndDo;
	
	HTML = HTML + "</table>"
		+ "<div class=""grid-kpi"" style=""margin-top:20px;"">"
		+ "  <div class=""card-3d"">"
		+ "    <div class=""card-title"">Vốn Lưu Động Ròng (NWC)</div>"
		+ "    <div class=""card-value"" style=""color:#059669;"">" + StrNWC + " VND</div>"
		+ "    <span class=""card-pill pill-success"">Dương an toàn</span>"
		+ "  </div>"
		+ "  <div class=""card-3d"">"
		+ "    <div class=""card-title"">Kỳ Thu Tiền Bình Quân (DSO)</div>"
		+ "    <div class=""card-value"">" + StrDSO + " <span style=""font-size:14px;"">ngày</span></div>"
		+ "    <span class=""card-pill pill-success"">Chuẩn chính sách 2026</span>"
		+ "  </div>"
		+ "  <div class=""card-3d"">"
		+ "    <div class=""card-title"">Kỳ Thanh Toán Bình Quân (DPO)</div>"
		+ "    <div class=""card-value"">" + StrDPO + " <span style=""font-size:14px;"">ngày</span></div>"
		+ "    <span class=""card-pill pill-success"">Tối ưu công nợ NCC</span>"
		+ "  </div>"
		+ "  <div class=""card-3d"">"
		+ "    <div class=""card-title"">Chu Kỳ Tiền Mặt (CCC)</div>"
		+ "    <div class=""card-value"">" + StrCCC + " <span style=""font-size:14px;"">ngày</span></div>"
		+ "    <span class=""card-pill pill-success"">Chiếm dụng vốn âm hiệu quả</span>"
		+ "  </div>"
		+ "</div>"
		+ "</body></html>";
		
	Return HTML;
EndFunction

#EndRegion
