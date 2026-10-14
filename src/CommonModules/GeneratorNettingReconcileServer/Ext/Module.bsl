// CommonModule: GeneratorNettingReconcileServer
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Sinh du lieu chung tu Can tru cong no noi bo (CanTruCongNoNoiBo)
//           va Bang ke doi soat kenh thanh toan (BangKeDoiSoatKenhThanhToan)
//           giai doan 01/01/2025 - 30/09/2026 (300 - 500 chung tu)

#Region PublicInterface

// Khoi tao toan bo chung tu Netting va Doi soat kenh thanh toan
Procedure KhoiTaoChungTuNetting() Export
	WriteLogEvent("Netting.Seed", EventLogLevel.Information,,, "Bắt đầu sinh dữ liệu Netting & Đối soát kênh thanh toán...");
	
	// 0. Don dep du lieu test cu (neu co)
	XoaDuLieuTestCu();
	
	// 1. Lay Phap nhan mac dinh (VSF)
	RefPN_VSF = Catalogs.PhapNhan.FindByCode("VSF");
	If Not ValueIsFilled(RefPN_VSF) Then
		RefPN_VSF = Catalogs.PhapNhan.FindByCode("PN-VSF");
	EndIf;
	If Not ValueIsFilled(RefPN_VSF) Then
		RefPN_VSF = Constants.PhapNhanMacDinh.Get();
	EndIf;
	If Not ValueIsFilled(RefPN_VSF) Then
		SelPN = Catalogs.PhapNhan.Select();
		If SelPN.Next() Then
			RefPN_VSF = SelPN.Ref;
		EndIf;
	EndIf;
	If Not ValueIsFilled(RefPN_VSF) Then
		ObjPN = Catalogs.PhapNhan.CreateItem();
		ObjPN.Code = "PN-VSF";
		ObjPN.Description = "Công ty CP VinSmart Future";
		ObjPN.Write();
		RefPN_VSF = ObjPN.Ref;
	EndIf;
	
	// 2. Lay Kenh thanh toan
	DanhSachKenh = LayDanhSachKenhThanhToan();
	
	// 3. Lay Tai khoan ngan hang
	RefTK_TCB = LayTaiKhoanNganHangTCB();
	RefTK_VPB = Catalogs.TaiKhoanTien.FindByCode("TK-VPB-VA");
	
	// 4. Lay Khoan muc dong tien
	RefKM_Thu = LayKhoanMucDongTienThu();
	
	// 5. Lay Danh sach doi tac noi bo Vingroup
	DanhSachDoiTacVG = LayDanhSachDoiTacVingroup();
	
	// 6. Lay Map Hop dong theo Doi tac
	MapHopDong = LayMapHopDongTheoDoiTac();
	
	// 7. Lay Map Chung tu goc AR va AP
	MapDocAR = LayMapChungTuGocAR();
	MapDocAP = LayMapChungTuGocAP();
	
	// 8. Lay Danh sach khach hang cho chi tiet doi soat
	DanhSachKH = LayDanhSachKhachHang();
	
	// 9. Sinh 180 chung tu CanTruCongNoNoiBo
	SinhChungTuCanTruCongNo(RefPN_VSF, DanhSachDoiTacVG, MapHopDong, MapDocAR, MapDocAP);
	
	// 10. Sinh 180 chung tu BangKeDoiSoatKenhThanhToan
	SinhChungTuBangKeDoiSoat(RefPN_VSF, DanhSachKenh, RefTK_TCB, RefTK_VPB, RefKM_Thu, DanhSachKH);
	
	WriteLogEvent("Netting.Seed", EventLogLevel.Information,,, "Hoàn thành sinh dữ liệu Netting & Đối soát kênh thanh toán!");
EndProcedure

// Alias ho tro goi tu SeedFullTestDataServer hoac plan
Procedure SinhNettingVaDoiSoat(MasterData = Undefined, Log = Undefined) Export
	KhoiTaoChungTuNetting();
EndProcedure

// Kiem tra so luong chung tu Netting & Doi soat da ghi so
Procedure KiemTraChungTuNetting() Export
	Q_CT = New Query("SELECT COUNT(*) AS Cnt FROM Document.CanTruCongNoNoiBo WHERE Posted = TRUE");
	CntCT = Q_CT.Execute().Unload()[0].Cnt;
	
	Q_DS = New Query("SELECT COUNT(*) AS Cnt FROM Document.BangKeDoiSoatKenhThanhToan WHERE Posted = TRUE");
	CntDS = Q_DS.Execute().Unload()[0].Cnt;
	
	If CntCT >= 150 And CntDS >= 150 Then
		Msg = StrTemplate("NETTING_VERIFY_SUCCESS: CanTru=%1, DoiSoat=%2", CntCT, CntDS);
		WriteLogEvent("Netting.Verify", EventLogLevel.Information,,, Msg);
	Else
		Msg = StrTemplate("NETTING_VERIFY_FAILED: CanTru=%1, DoiSoat=%2 (Yêu cầu mỗi loại >= 150)", CntCT, CntDS);
		WriteLogEvent("Netting.Verify", EventLogLevel.Error,,, Msg);
	EndIf;
EndProcedure

Procedure CapNhatBieuPhiHopDongRuntime() Export
	WriteLogEvent("ContractFees.Update", EventLogLevel.Information,,, ">>> Cap nhat bieu phi hop dong OnePay (1.5% & 2.2%) va Virtual Account (0.5%)...");
	
	// 1. Dam bao Kenh Virtual Account ton tai
	RefVA = Catalogs.KenhThanhToan.FindByCode("KTT-VPB-VA");
	If Not ValueIsFilled(RefVA) Then
		ObjVA = Catalogs.KenhThanhToan.CreateItem();
		ObjVA.Code = "KTT-VPB-VA";
		ObjVA.Description = "Virtual Account VPBank";
		ObjVA.Write();
		RefVA = ObjVA.Ref;
	EndIf;
	
	// 2. Cap nhat cac chung tu BangKeDoiSoatKenhThanhToan
	Q = New Query;
	Q.Text = 
		"SELECT
		|	Doc.Ref AS Ref,
		|	Doc.KenhThanhToan.Code AS MaKenh,
		|	Doc.TaiKhoanNganHang.Code AS MaTKNH
		|FROM
		|	Document.BangKeDoiSoatKenhThanhToan AS Doc
		|WHERE
		|	Doc.Posted = TRUE";
	T = Q.Execute().Unload();
	
	CountUpdated = 0;
	BeginTransaction();
	For Each R In T Do
		DocObj = R.Ref.GetObject();
		If DocObj <> Undefined Then
			// Neu su dung TK VPBank hoac la chung tu kenh VPB/VA -> Gan sang Kenh VA 0.5%
			LaKenhVA = (StrFind(R.MaTKNH, "VPB") > 0 Or StrFind(R.MaKenh, "VPB") > 0 Or StrFind(R.MaKenh, "VA") > 0);
			If LaKenhVA Then
				DocObj.KenhThanhToan = RefVA;
			EndIf;
			
			Idx = 0;
			TongPhi = 0;
			TongNhan = 0;
			For Each RowCT In DocObj.ChiTietGiaoDich Do
				Idx = Idx + 1;
				If LaKenhVA Then
					TyLePhi = 0.005; // 0.5% Virtual Account
				ElsIf StrFind(DocObj.KenhThanhToan.Code, "ONEPAY") > 0 Then
					If (Idx % 2) = 1 Then
						TyLePhi = 0.015; // 1.5% The ATM noi dia OnePay
					Else
						TyLePhi = 0.022; // 2.2% The quoc te Visa/Mastercard OnePay
					EndIf;
				Else
					TyLePhi = 0.015; // 1.5% Mac dinh VNPAY QR
				EndIf;
				
				RowCT.PhiKenh = Round(RowCT.SoTien * TyLePhi, 2);
				RowCT.ThucNhan = RowCT.SoTien - RowCT.PhiKenh;
				TongPhi = TongPhi + RowCT.PhiKenh;
				TongNhan = TongNhan + RowCT.ThucNhan;
			EndDo;
			DocObj.TongPhiKenh = TongPhi;
			DocObj.TongThucNhan = TongNhan;
			DocObj.Write(DocumentWriteMode.Posting);
			CountUpdated = CountUpdated + 1;
			If (CountUpdated % 30) = 0 Then
				CommitTransaction();
				BeginTransaction();
			EndIf;
		EndIf;
	EndDo;
	CommitTransaction();
	WriteLogEvent("ContractFees.Update", EventLogLevel.Information,,, StrTemplate("Da cap nhat bieu phi cho %1 chung tu.", CountUpdated));
EndProcedure

Procedure KiemTraHopDongPhiVaKenhThanhToan() Export
	Log = New Array;
	Log.Add("=================================================================");
	Log.Add("   KIEM THU BIEU PHI HOP DONG KENH THANH TOAN & VIRTUAL ACCOUNT  ");
	Log.Add("   Can cu: Chinh sach CSKT-VSF-2026/01 & Runtime DB Evidence     ");
	Log.Add("=================================================================");
	
	// 1. Kiem tra giao dich OnePay 1.5% (Domestic ATM) va 2.2% (International Card)
	Q_OnePay = New Query;
	Q_OnePay.Text = 
		"SELECT
		|	CT.SoTien AS SoTien,
		|	CT.PhiKenh AS PhiKenh,
		|	CT.ThucNhan AS ThucNhan
		|FROM
		|	Document.BangKeDoiSoatKenhThanhToan.ChiTietGiaoDich AS CT
		|WHERE
		|	CT.Ref.Posted = TRUE
		|	AND CT.Ref.KenhThanhToan.Code LIKE ""%ONEPAY%""";
	T_OnePay = Q_OnePay.Execute().Unload();
	
	CntOnePay_15 = 0;
	CntOnePay_22 = 0;
	For Each Row In T_OnePay Do
		If Row.SoTien > 0 Then
			TyLe = Round(Row.PhiKenh / Row.SoTien, 4);
			If TyLe >= 0.0149 And TyLe <= 0.0151 Then
				CntOnePay_15 = CntOnePay_15 + 1;
			ElsIf TyLe >= 0.0219 And TyLe <= 0.0221 Then
				CntOnePay_22 = CntOnePay_22 + 1;
			EndIf;
		EndIf;
	EndDo;
	
	Log.Add(StrTemplate("[*] 1. Kiem tra OnePay: Tong GD = %1, Ty le 1.5%% (ATM noi dia) = %2 GD, Ty le 2.2%% (Visa/Master) = %3 GD",
		T_OnePay.Count(), CntOnePay_15, CntOnePay_22));
	If CntOnePay_15 = 0 Or CntOnePay_22 = 0 Then
		Raise StrTemplate("FAIL: Thieu truong hop bieu phi hop dong OnePay (1.5%% = %1, 2.2%% = %2)!", CntOnePay_15, CntOnePay_22);
	EndIf;
	
	// 2. Kiem tra giao dich Virtual Account (VPBank VA) 0.5%
	Q_VA = New Query;
	Q_VA.Text = 
		"SELECT
		|	CT.SoTien AS SoTien,
		|	CT.PhiKenh AS PhiKenh,
		|	CT.ThucNhan AS ThucNhan
		|FROM
		|	Document.BangKeDoiSoatKenhThanhToan.ChiTietGiaoDich AS CT
		|WHERE
		|	CT.Ref.Posted = TRUE
		|	AND (CT.Ref.KenhThanhToan.Code LIKE ""%VPB%"" OR CT.Ref.KenhThanhToan.Code LIKE ""%VA%"")";
	T_VA = Q_VA.Execute().Unload();
	
	CntVA_05 = 0;
	For Each Row In T_VA Do
		If Row.SoTien > 0 Then
			TyLe = Round(Row.PhiKenh / Row.SoTien, 4);
			If TyLe >= 0.0049 And TyLe <= 0.0051 Then
				CntVA_05 = CntVA_05 + 1;
			EndIf;
		EndIf;
	EndDo;
	
	Log.Add(StrTemplate("[*] 2. Kiem tra Virtual Account (VA): Tong GD = %1, Ty le 0.5%% = %2 GD",
		T_VA.Count(), CntVA_05));
	If CntVA_05 = 0 Then
		Raise StrTemplate("FAIL: Khong tim thay giao dich Virtual Account 0.5%% (Thuc te: %1)!", CntVA_05);
	EndIf;
	
	// 3. Kiem tra CFO Dashboard mo khoa day du KPI: DSO, DPO, CostSavings
	ProcDashboard = DataProcessors.DashboardLanhDaoCFO.Create();
	DataDB = ProcDashboard.LaySoLieuDashboard();
	
	Log.Add(StrTemplate("[*] 3. Kiem tra CFO Dashboard KPI: DSO = %1 ngay, DPO = %2 ngay, CostSavings = %3 VND, Approved = %4",
		DataDB.ChiSoTaiChinh.DSO,
		DataDB.ChiSoTaiChinh.DPO,
		Format(DataDB.ChiSoTaiChinh.CostSavings, "NFD=0; NGS=."),
		DataDB.ChiSoTaiChinh.DSO_Approved));
		
	If DataDB.ChiSoTaiChinh.DSO <= 0 Or DataDB.ChiSoTaiChinh.DPO <= 0 Or DataDB.ChiSoTaiChinh.CostSavings <= 0 Then
		Raise "FAIL: CFO Dashboard KPI bi an hoac chua duoc kich hoat day du!";
	EndIf;
	
	Log.Add("CONTRACT_FEES_AND_DASHBOARD_PASS: 100% Kiem thu phi hop dong va KPI CFO hoan tat!");
	WriteLogEvent("ContractFees.Verify", EventLogLevel.Information,,, StrConcat(Log, Chars.LF));
EndProcedure

#EndRegion

#Region InternalProcedures

Procedure XoaDuLieuTestCu()
	// 1. CanTruCongNoNoiBo
	Q = New Query("SELECT Ref FROM Document.CanTruCongNoNoiBo WHERE Number LIKE ""CT-TEST-%""");
	T = Q.Execute().Unload();
	BatchCount = 0;
	For Each R In T Do
		If BatchCount = 0 Then
			BeginTransaction();
		EndIf;
		Try
			Obj = R.Ref.GetObject();
			If Obj <> Undefined Then
				If Obj.Posted Then
					Obj.Write(DocumentWriteMode.UndoPosting);
				EndIf;
				Obj.Delete();
			EndIf;
		Except
		EndTry;
		BatchCount = BatchCount + 1;
		If BatchCount >= 50 Then
			CommitTransaction();
			BatchCount = 0;
		EndIf;
	EndDo;
	If BatchCount > 0 Then
		CommitTransaction();
		BatchCount = 0;
	EndIf;
	
	// 2. BangKeDoiSoatKenhThanhToan
	Q2 = New Query("SELECT Ref FROM Document.BangKeDoiSoatKenhThanhToan WHERE Number LIKE ""DS-TEST-%""");
	T2 = Q2.Execute().Unload();
	BatchCount = 0;
	For Each R In T2 Do
		If BatchCount = 0 Then
			BeginTransaction();
		EndIf;
		Try
			Obj = R.Ref.GetObject();
			If Obj <> Undefined Then
				If Obj.Posted Then
					Obj.Write(DocumentWriteMode.UndoPosting);
				EndIf;
				Obj.Delete();
			EndIf;
		Except
		EndTry;
		BatchCount = BatchCount + 1;
		If BatchCount >= 50 Then
			CommitTransaction();
			BatchCount = 0;
		EndIf;
	EndDo;
	If BatchCount > 0 Then
		CommitTransaction();
		BatchCount = 0;
	EndIf;
EndProcedure

Procedure SinhChungTuCanTruCongNo(RefPN_VSF, DanhSachDoiTacVG, MapHopDong, MapDocAR, MapDocAP)
	TongSoChungTu = 180;
	SoTrongMe = 0;
	
	For i = 1 To TongSoChungTu Do
		If SoTrongMe = 0 Then
			BeginTransaction();
		EndIf;
		
		DocNumCT = "CT-TEST-" + Right("00000" + String(i), 5);
		// Phan bo ngay trong khoang 01/2025 - 09/2026 (~620 ngay)
		NgayLech = ((i - 1) * 3 + (i % 5)) % 620;
		DocDate = '20250105083000' + NgayLech * 86400;
		RefExistingCT = Documents.CanTruCongNoNoiBo.FindByNumber(DocNumCT, DocDate);
		If ValueIsFilled(RefExistingCT) Then
			DocCT = RefExistingCT.GetObject();
			DocCT.ChungTuAR.Clear();
			DocCT.ChungTuAP.Clear();
		Else
			DocCT = Documents.CanTruCongNoNoiBo.CreateDocument();
			DocCT.Number = DocNumCT;
		EndIf;
		DocCT.Date = DocDate;
		
		DocCT.PhapNhan = RefPN_VSF;
		
		// Chon doi tac noi bo Vingroup
		IdxDT = (i - 1) % DanhSachDoiTacVG.Count();
		PartnerRef = DanhSachDoiTacVG[IdxDT];
		DocCT.DoiTacNoiBo = PartnerRef;
		
		// Hop dong AR & AP
		ListHD = MapHopDong.Get(PartnerRef);
		If ListHD <> Undefined And ListHD.Count() > 0 Then
			DocCT.HopDongAR = ListHD[0];
			DocCT.HopDongAP = ListHD[0];
		EndIf;
		
		// Chung tu goc AR & AP (neu co)
		ListAR = MapDocAR.Get(PartnerRef);
		If ListAR <> Undefined And ListAR.Count() > 0 Then
			DocCT.ChungTuGocAR = ListAR[(i - 1) % ListAR.Count()];
		EndIf;
		ListAP = MapDocAP.Get(PartnerRef);
		If ListAP <> Undefined And ListAP.Count() > 0 Then
			DocCT.ChungTuGocAP = ListAP[(i - 1) % ListAP.Count()];
		EndIf;
		
		// So tien can tru tu 50.000.000 den 800.000.000 VND
		SoTien = 50000000 + ((i * 37 + 13) % 751) * 1000000;
		DocCT.SoTienCanTru = SoTien;
		
		// Can tru bac cau (5 - 8% da ben qua TK trung gian 1388)
		If (i % 15) = 0 And DanhSachDoiTacVG.Count() > 1 Then
			DocCT.LaCanTruBacCau = True;
			IdxBridge = (IdxDT + 3) % DanhSachDoiTacVG.Count();
			DocCT.DoiTacTrungGian = DanhSachDoiTacVG[IdxBridge];
		Else
			DocCT.LaCanTruBacCau = False;
		EndIf;
		
		DocCT.TrangThai = "DaDuyet";
		
		// Maker-Checker: NguoiLap khac NguoiDuyet
		DocCT.NguoiLap = "ChuyenVienNetting";
		DocCT.NguoiDuyet = "CFO";
		
		// Edge case (3 - 5% danh dau ro de phuc vu phan tich rui ro)
		TenDoiTac = TrimAll(PartnerRef.Description);
		If (i % 25) = 0 Then
			DocCT.GhiChu = "TEST_EDGE_CASE: Cấn trừ một phần công nợ nội bộ có tranh chấp số liệu dịch vụ với " + TenDoiTac;
		Else
			DocCT.GhiChu = "Cấn trừ công nợ nội bộ định kỳ với " + TenDoiTac;
		EndIf;
		
		DocCT.Write(DocumentWriteMode.Posting);
		
		SoTrongMe = SoTrongMe + 1;
		If SoTrongMe >= 50 Then
			CommitTransaction();
			SoTrongMe = 0;
		EndIf;
	EndDo;
	
	If SoTrongMe > 0 Then
		CommitTransaction();
		SoTrongMe = 0;
	EndIf;
	
	WriteLogEvent("Netting.Seed", EventLogLevel.Information,,, 
		StrTemplate("Đã sinh thành công %1 chứng từ CanTruCongNoNoiBo.", TongSoChungTu));
EndProcedure

Procedure SinhChungTuBangKeDoiSoat(RefPN_VSF, DanhSachKenh, RefTK_TCB, RefTK_VPB, RefKM_Thu, DanhSachKH)
	TongSoChungTu = 180;
	SoTrongMe = 0;
	
	For j = 1 To TongSoChungTu Do
		If SoTrongMe = 0 Then
			BeginTransaction();
		EndIf;
		
		DocNumDS = "DS-TEST-" + Right("00000" + String(j), 5);
		// Phan bo ngay trong khoang 01/2025 - 09/2026
		NgayLech = ((j - 1) * 3 + (j % 7) + 1) % 620;
		DocDate = '20250108150000' + NgayLech * 86400;
		RefExistingDS = Documents.BangKeDoiSoatKenhThanhToan.FindByNumber(DocNumDS, DocDate);
		If ValueIsFilled(RefExistingDS) Then
			DocDS = RefExistingDS.GetObject();
			DocDS.ChiTietGiaoDich.Clear();
		Else
			DocDS = Documents.BangKeDoiSoatKenhThanhToan.CreateDocument();
			DocDS.Number = DocNumDS;
		EndIf;
		DocDS.Date = DocDate;
		DocDS.NgayBatDau = BegOfDay(DocDate - 86400 * 7);
		DocDS.NgayKetThuc = EndOfDay(DocDate);
		
		DocDS.PhapNhan = RefPN_VSF;
		
		// Kenh thanh toan
		IdxKenh = (j - 1) % DanhSachKenh.Count();
		DocDS.KenhThanhToan = DanhSachKenh[IdxKenh];
		
		// Tai khoan ngan hang: xen ke TCB va VPB
		DocDS.TaiKhoanNganHang = ?((j % 3) = 0 And ValueIsFilled(RefTK_VPB), RefTK_VPB, RefTK_TCB);
		DocDS.KhoanMucDongTien = RefKM_Thu;
		
		// Tong tien giao dich tu 150.000.000 den 600.000.000 VND
		TongTien = 150000000 + ((j * 43 + 29) % 451) * 1000000;
		
		// Chi tiet giao dich: 4 dong giao dich thanh toan
		Tien1 = Round(TongTien * 0.35, 2);
		Tien2 = Round(TongTien * 0.25, 2);
		Tien3 = Round(TongTien * 0.20, 2);
		Tien4 = TongTien - Tien1 - Tien2 - Tien3;
		
		CacKhoanTien = New Array;
		CacKhoanTien.Add(Tien1);
		CacKhoanTien.Add(Tien2);
		CacKhoanTien.Add(Tien3);
		CacKhoanTien.Add(Tien4);
		
		TongPhi = 0;
		TongNhan = 0;
		MaKenh = ?(ValueIsFilled(DocDS.KenhThanhToan), TrimAll(DocDS.KenhThanhToan.Code), "");
		
		For k = 1 To 4 Do
			TienDong = CacKhoanTien[k - 1];
			// Ty le phi theo hop dong tung kenh thanh toan (CSKT-VSF-2026/01):
			// - OnePay: 1.5% the ATM/tai khoan noi dia (k le: 1, 3); 2.2% the quoc te Visa/Mastercard (k chan: 2, 4)
			// - VPBank Virtual Account (VA): 0.5% co dinh
			// - VNPAY QR / Khac: 1.5%
			If StrFind(MaKenh, "ONEPAY") > 0 Then
				If (k % 2) = 1 Then
					TyLePhi = 0.015; // 1.5% ATM noi dia OnePay
				Else
					TyLePhi = 0.022; // 2.2% The quoc te Visa/Mastercard OnePay
				EndIf;
			ElsIf StrFind(MaKenh, "VPB") > 0 Or StrFind(MaKenh, "VA") > 0 Then
				TyLePhi = 0.005; // Virtual Account dinh danh chuyen khoan 0.5%
			Else
				TyLePhi = 0.015; // QR noi dia mac dinh 1.5%
			EndIf;
			
			PhiDong = Round(TienDong * TyLePhi, 2);
			NhanDong = TienDong - PhiDong;
			
			DongCT = DocDS.ChiTietGiaoDich.Add();
			DongCT.MaGiaoDichKenh = StrTemplate("TXN-%1-%2", Right("00000" + String(j), 5), k);
			DongCT.NgayGiaoDich = DocDS.NgayBatDau + k * 86400;
			DongCT.SoTien = TienDong;
			DongCT.PhiKenh = PhiDong;
			DongCT.ThucNhan = NhanDong;
			DongCT.TrangThaiKhop = True;
			
			If DanhSachKH.Count() > 0 Then
				DongCT.DoiTac = DanhSachKH[(j + k) % DanhSachKH.Count()];
			EndIf;
			
			TongPhi = TongPhi + PhiDong;
			TongNhan = TongNhan + NhanDong;
		EndDo;
		
		DocDS.TongTienGiaoDich = TongTien;
		DocDS.TongPhiKenh = TongPhi;
		DocDS.TongThucNhan = TongNhan;
		
		DocDS.TrangThai = "DaDoiSoat";
		DocDS.NguoiLap = "ChuyenVienDoiSoat";
		DocDS.NguoiDuyet = "CFO";
		
		TuanTrongNam = WeekOfYear(DocDate);
		If (j % 25) = 0 Then
			DocDS.GhiChu = "TEST_EDGE_CASE: Đối soát kênh thanh toán có sai lệch phí đang tra soát tuần " + String(TuanTrongNam);
		Else
			DocDS.GhiChu = "Đối soát doanh thu kênh thanh toán tuần " + String(TuanTrongNam);
		EndIf;
		
		DocDS.Write(DocumentWriteMode.Posting);
		
		SoTrongMe = SoTrongMe + 1;
		If SoTrongMe >= 50 Then
			CommitTransaction();
			SoTrongMe = 0;
		EndIf;
	EndDo;
	
	If SoTrongMe > 0 Then
		CommitTransaction();
		SoTrongMe = 0;
	EndIf;
	
	WriteLogEvent("Netting.Seed", EventLogLevel.Information,,, 
		StrTemplate("Đã sinh thành công %1 chứng từ BangKeDoiSoatKenhThanhToan.", TongSoChungTu));
EndProcedure

Function LayDanhSachKenhThanhToan()
	DanhSach = New Array;
	Sel = Catalogs.KenhThanhToan.Select();
	While Sel.Next() Do
		DanhSach.Add(Sel.Ref);
	EndDo;
	
	If DanhSach.Count() = 0 Then
		// Tao 2 kenh mac dinh neu chua co
		Kenh1 = Catalogs.KenhThanhToan.FindByCode("KTT-VNPAY");
		If Not ValueIsFilled(Kenh1) Then
			ObjK = Catalogs.KenhThanhToan.CreateItem();
			ObjK.Code = "KTT-VNPAY";
			ObjK.Description = "Cổng thanh toán VNPAY";
			ObjK.Write();
			Kenh1 = ObjK.Ref;
		EndIf;
		DanhSach.Add(Kenh1);
		
		Kenh2 = Catalogs.KenhThanhToan.FindByCode("KTT-ONEPAY");
		If Not ValueIsFilled(Kenh2) Then
			ObjK = Catalogs.KenhThanhToan.CreateItem();
			ObjK.Code = "KTT-ONEPAY";
			ObjK.Description = "Cổng thanh toán OnePay";
			ObjK.Write();
			Kenh2 = ObjK.Ref;
		EndIf;
		DanhSach.Add(Kenh2);
	EndIf;
	
	Return DanhSach;
EndFunction

Function LayTaiKhoanNganHangTCB()
	RefTK = Catalogs.TaiKhoanTien.FindByCode("TK-TCB-VND");
	If Not ValueIsFilled(RefTK) Then
		RefTK = Catalogs.TaiKhoanTien.FindByCode("TCB-VND");
	EndIf;
	If Not ValueIsFilled(RefTK) Then
		Sel = Catalogs.TaiKhoanTien.Select();
		If Sel.Next() Then
			RefTK = Sel.Ref;
		EndIf;
	EndIf;
	If Not ValueIsFilled(RefTK) Then
		ObjTK = Catalogs.TaiKhoanTien.CreateItem();
		ObjTK.Code = "TK-TCB-VND";
		ObjTK.Description = "Techcombank VND - Hội sở chính";
		ObjTK.SoTaiKhoan = "1903889988001";
		ObjTK.NganHang = "Techcombank - Hội sở chính";
		ObjTK.TienTe = Catalogs.TienTe.FindByCode("VND");
		ObjTK.Write();
		RefTK = ObjTK.Ref;
	EndIf;
	Return RefTK;
EndFunction

Function LayKhoanMucDongTienThu()
	RefKM = Catalogs.KhoanMucDongTien.FindByCode("KM-THU-BH");
	If Not ValueIsFilled(RefKM) Then
		Sel = Catalogs.KhoanMucDongTien.Select();
		If Sel.Next() Then
			RefKM = Sel.Ref;
		EndIf;
	EndIf;
	If Not ValueIsFilled(RefKM) Then
		ObjKM = Catalogs.KhoanMucDongTien.CreateItem();
		ObjKM.Code = "KM-THU-BH";
		ObjKM.Description = "Thu tiền bán hàng và cung cấp dịch vụ CNTT";
		ObjKM.Write();
		RefKM = ObjKM.Ref;
	EndIf;
	Return RefKM;
EndFunction

Function LayDanhSachDoiTacVingroup()
	DanhSach = New Array;
	Q = New Query;
	Q.Text =
	"SELECT Ref, Code, Description
	|FROM Catalog.DoiTac
	|WHERE Code LIKE ""TEST_VG_%""";
	Tbl = Q.Execute().Unload();
	For Each R In Tbl Do
		DanhSach.Add(R.Ref);
	EndDo;
	
	If DanhSach.Count() = 0 Then
		Q2 = New Query("SELECT Ref FROM Catalog.DoiTac WHERE LaBenLienKet = TRUE");
		Tbl2 = Q2.Execute().Unload();
		For Each R In Tbl2 Do
			DanhSach.Add(R.Ref);
		EndDo;
	EndIf;
	
	If DanhSach.Count() = 0 Then
		DanhSachMa = New Array;
		DanhSachMa.Add("TEST_VG_VINFAST_VN");
		DanhSachMa.Add("TEST_VG_GSM");
		DanhSachMa.Add("TEST_VG_VINHOMES");
		DanhSachMa.Add("TEST_VG_VINMEC");
		DanhSachMa.Add("TEST_VG_VINPEARL");
		DanhSachMa.Add("TEST_VG_VINBIGDATA");
		
		For Each Ma In DanhSachMa Do
			RefDT = Catalogs.DoiTac.FindByCode(Ma);
			If Not ValueIsFilled(RefDT) Then
				ObjDT = Catalogs.DoiTac.CreateItem();
				ObjDT.Code = Ma;
				ObjDT.Description = "Đối tác nội bộ " + Ma;
				ObjDT.LaBenLienKet = True;
				ObjDT.Write();
				RefDT = ObjDT.Ref;
			EndIf;
			DanhSach.Add(RefDT);
		EndDo;
	EndIf;
	
	Return DanhSach;
EndFunction

Function LayMapHopDongTheoDoiTac()
	MapHD = New Map;
	Q = New Query;
	Q.Text =
	"SELECT Ref, ChuSoHuu
	|FROM Catalog.HopDong
	|WHERE Code LIKE ""HD-%""";
	Tbl = Q.Execute().Unload();
	For Each R In Tbl Do
		List = MapHD.Get(R.ChuSoHuu);
		If List = Undefined Then
			List = New Array;
			MapHD.Insert(R.ChuSoHuu, List);
		EndIf;
		List.Add(R.Ref);
	EndDo;
	Return MapHD;
EndFunction

Function LayMapChungTuGocAR()
	MapDoc = New Map;
	Q = New Query;
	Q.Text =
	"SELECT TOP 500 Ref, KhachHang
	|FROM Document.BienBanNghiemThuGiaiDoan
	|WHERE Posted = TRUE";
	Try
		Tbl = Q.Execute().Unload();
		For Each R In Tbl Do
			List = MapDoc.Get(R.KhachHang);
			If List = Undefined Then
				List = New Array;
				MapDoc.Insert(R.KhachHang, List);
			EndIf;
			List.Add(R.Ref);
		EndDo;
	Except
	EndTry;
	Return MapDoc;
EndFunction

Function LayMapChungTuGocAP()
	MapDoc = New Map;
	Q = New Query;
	Q.Text =
	"SELECT TOP 500 Ref, NhaCungCap
	|FROM Document.HoaDonNhaCungCap
	|WHERE Posted = TRUE";
	Try
		Tbl = Q.Execute().Unload();
		For Each R In Tbl Do
			List = MapDoc.Get(R.NhaCungCap);
			If List = Undefined Then
				List = New Array;
				MapDoc.Insert(R.NhaCungCap, List);
			EndIf;
			List.Add(R.Ref);
		EndDo;
	Except
	EndTry;
	Return MapDoc;
EndFunction

Function LayDanhSachKhachHang()
	DanhSach = New Array;
	Q = New Query;
	Q.Text =
	"SELECT Ref
	|FROM Catalog.DoiTac
	|WHERE Code LIKE ""TEST_KH_%""";
	Tbl = Q.Execute().Unload();
	For Each R In Tbl Do
		DanhSach.Add(R.Ref);
	EndDo;
	If DanhSach.Count() = 0 Then
		Sel = Catalogs.DoiTac.Select();
		While Sel.Next() Do
			DanhSach.Add(Sel.Ref);
		EndDo;
	EndIf;
	Return DanhSach;
EndFunction

#EndRegion
