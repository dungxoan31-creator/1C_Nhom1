// CommonModule: GeneratorAPServer
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Sinh khoi luong lon chung tu nghiep vu AP (Hoa don nha cung cap & Uy nhiem chi)
//           cho giai doan tu 01/01/2025 den 30/09/2026 (21 thang, ~2,000 - 2,800 chung tu)

#Region PublicInterface

// Prepare deterministic AP seed documents under the real maker/approver accounts.
Procedure KhoiTaoChungTuAP(Val GeneratePayments = False, Val Stage = "PrepareInvoices") Export
	If Stage = "MasterData" Or Stage = "PostHighInvoicesCFO" Then
		If Not IsInRole("GiamDocTaiChinh_CFO") Then Raise "AP master-data and high-value posting stages require the CFO role."; EndIf;
	ElsIf Stage = "PrepareInvoices" Then
		If Not IsInRole("KeToanPhaiTra") Then Raise "AP invoice preparation requires the AP role."; EndIf;
	ElsIf Stage = "ApproveInvoicesKTT" Then
		If Not IsInRole("KeToanTruong") Then Raise "AP approval stage requires the chief accountant role."; EndIf;
	Else
		Raise "Unknown AP seed stage: " + Stage;
	EndIf;
	If GeneratePayments Then Raise "Bulk AP seed only creates invoices; use the approved payment E2E flow to create and post payments."; EndIf;
	WriteLogEvent("AP.Seed", EventLogLevel.Information,,, ">>> Bắt đầu KhoiTaoChungTuAP...");
	
	// 1. Lay thong tin Phap nhan mac dinh VSF
	RefPN_VSF = Catalogs.PhapNhan.FindByCode("PN-VSF");
	If Not ValueIsFilled(RefPN_VSF) Then
		RefPN_VSF = Catalogs.PhapNhan.FindByCode("VSF");
	EndIf;
	If Not ValueIsFilled(RefPN_VSF) Then
		Q_PN = New Query("SELECT TOP 1 Ref FROM Catalog.PhapNhan");
		T_PN = Q_PN.Execute().Unload();
		If T_PN.Count() > 0 Then
			RefPN_VSF = T_PN[0].Ref;
		EndIf;
	EndIf;
	
	// 2. Lay thong tin Tien te VND & USD
	RefVND = Catalogs.TienTe.FindByCode("VND");
	RefUSD = Catalogs.TienTe.FindByCode("USD");
	
	// 3. Lay thong tin Tai khoan tien Techcombank VND & Vietcombank USD
	RefTK_TCB = Catalogs.TaiKhoanTien.FindByCode("TK-TCB-VND");
	If Not ValueIsFilled(RefTK_TCB) Then
		ObjTK = Catalogs.TaiKhoanTien.CreateItem();
		ObjTK.Code = "TK-TCB-VND";
		ObjTK.Description = "Techcombank VND - Hoi so chinh";
		ObjTK.SoTaiKhoan = "1903889988001";
		ObjTK.NganHang = "Techcombank - Hoi so chinh";
		ObjTK.TienTe = RefVND;
		ObjTK.Write();
		RefTK_TCB = ObjTK.Ref;
	EndIf;
	If RefTK_TCB.Code <> "TK-TCB-VND" Then Raise "Bank account code was truncated; expected TK-TCB-VND."; EndIf;
	
	RefTK_VCB = Catalogs.TaiKhoanTien.FindByCode("TK-VCB-USD");
	If Not ValueIsFilled(RefTK_VCB) Then
		ObjTK = Catalogs.TaiKhoanTien.CreateItem();
		ObjTK.Code = "TK-VCB-USD";
		ObjTK.Description = "Vietcombank USD - So giao dich";
		ObjTK.SoTaiKhoan = "0011004455667";
		ObjTK.NganHang = "Vietcombank - So giao dich 1";
		ObjTK.TienTe = RefUSD;
		ObjTK.Write();
		RefTK_VCB = ObjTK.Ref;
	EndIf;
	If RefTK_VCB.Code <> "TK-VCB-USD" Then Raise "Bank account code was truncated; expected TK-VCB-USD."; EndIf;
	
	// 4. Lay Tai khoan chi phi va Khoan muc dong tien
	RefTK_627 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("627");
	RefKM_Chi = Catalogs.KhoanMucDongTien.FindByCode("KM-CHI-CLOUD");
	If Not ValueIsFilled(RefKM_Chi) Then
		ObjKM = Catalogs.KhoanMucDongTien.CreateItem();
		ObjKM.Code = "KM-CHI-CLOUD";
		ObjKM.Description = "Chi phí dịch vụ Cloud và nhà cung cấp quốc tế";
		ObjKM.LoaiDongTien = "Chi";
		ObjKM.Write();
		RefKM_Chi = ObjKM.Ref;
	EndIf;
	
	// 5. Lay danh sach Nha cung cap tu Catalog.DoiTac (ma TEST_NCC_%)
	QueryNCC = New Query;
	QueryNCC.Text = 
		"SELECT
		|	DoiTac.Ref AS Ref,
		|	DoiTac.Code AS Code,
		|	DoiTac.Description AS Description,
		|	DoiTac.LaBenLienKet AS LaBenLienKet
		|FROM
		|	Catalog.DoiTac AS DoiTac
		|WHERE
		|	DoiTac.Code LIKE ""TEST_NCC_%""
		|ORDER BY
		|	DoiTac.Code";
	
	BangNCC = QueryNCC.Execute().Unload();
	If BangNCC.Count() = 0 Then
		WriteLogEvent("AP.Seed", EventLogLevel.Error,,, "Không tìm thấy Nhà cung cấp nào với mã TEST_NCC_%!");
		Return;
	EndIf;
	
	ListUSD = New Array;
	ListVND = New Array;
	
	For Each RowNCC In BangNCC Do
		If Left(RowNCC.Code, 11) = "TEST_NCC_VN" Then
			ListVND.Add(RowNCC);
		Else
			ListUSD.Add(RowNCC);
		EndIf;
	EndDo;
	If Stage = "MasterData" Then
		WriteLogEvent("AP.Seed", EventLogLevel.Information,,, "AP seed master data is ready.");
		Return;
	ElsIf Stage = "ApproveInvoicesKTT" Then
		ApproveAPSeedInvoicesKTT();
		Return;
	ElsIf Stage = "PostHighInvoicesCFO" Then
		PostHighAPSeedInvoicesCFO();
		Return;
	EndIf;
	
	If ListUSD.Count() = 0 Then
		ListUSD = BangNCC;
	EndIf;
	If ListVND.Count() = 0 Then
		ListVND = BangNCC;
	EndIf;
	
	// 6. Lay va tao bo sung Hop dong cho tung Nha cung cap
	QueryHD = New Query;
	QueryHD.Text = 
		"SELECT
		|	HopDong.Ref AS Ref,
		|	HopDong.ChuSoHuu AS ChuSoHuu
		|FROM
		|	Catalog.HopDong AS HopDong
		|WHERE
		|	HopDong.ChuSoHuu.Code LIKE ""TEST_NCC_%""";
	
	BangHD = QueryHD.Execute().Unload();
	MapHD = New Map;
	For Each RowHD In BangHD Do
		MapHD.Insert(RowHD.ChuSoHuu, RowHD.Ref);
	EndDo;
	
	For Each RowNCC In BangNCC Do
		If MapHD.Get(RowNCC.Ref) = Undefined Then
			IsUSD = (Left(RowNCC.Code, 11) <> "TEST_NCC_VN");
			HDCode = "HD-" + TrimAll(RowNCC.Code) + "-2025";
			RefHD = Catalogs.HopDong.FindByCode(HDCode);
			If Not ValueIsFilled(RefHD) Then
				ObjHD = Catalogs.HopDong.CreateItem();
				ObjHD.Code = HDCode;
				ObjHD.Description = "Hợp đồng dịch vụ - " + RowNCC.Description;
				ObjHD.PhapNhan = RefPN_VSF;
				ObjHD.ChuSoHuu = RowNCC.Ref;
				ObjHD.DongTienThanhToan = ?(IsUSD, RefUSD, RefVND);
				ObjHD.HanThanhToanNgay = 30;
				ObjHD.GrossUpThue = False;
				ObjHD.Write();
				RefHD = ObjHD.Ref;
			EndIf;
			MapHD.Insert(RowNCC.Ref, RefHD);
		EndIf;
	EndDo;
	
	// 7. Don dep du lieu AP cu neu co de dam bao tinh idempotent
	// Seed uses a fresh disposable clone; existing records are retained.
	If Stage = "MasterData" Then
		WriteLogEvent("AP.Seed", EventLogLevel.Information,,, "AP seed master data is ready.");
		Return;
	ElsIf Stage = "ApproveInvoicesKTT" Then
		ApproveAPSeedInvoicesKTT();
		Return;
	ElsIf Stage = "PostHighInvoicesCFO" Then
		PostHighAPSeedInvoicesCFO();
		Return;
	ElsIf Stage <> "PrepareInvoices" Then
		Raise "Unknown AP seed stage: " + Stage;
	EndIf;
	
	// 8. Vong lap sinh du lieu AP tu thang 01/2025 den 09/2026 (21 thang)
	IdxUSD = 0;
	IdxVND = 0;
	TotalHD = 0;
	TotalUNC = 0;
	DocBatchCount = 0;
	InTransaction = False;
	
	Try
		BeginTransaction();
		InTransaction = True;
		For MonthNum = 1 To 21 Do
			If MonthNum <= 12 Then
				CurYear = 2025;
				CurMonth = MonthNum;
			Else
				CurYear = 2026;
				CurMonth = MonthNum - 12;
			EndIf;
			
			// Moi thang sinh 60 hoa don (21 thang x 60 = 1,260 hoa don NCC)
			For InvIdx = 1 To 60 Do
				IsUSD = (InvIdx <= 15);
				If IsUSD Then
					Partner = ListUSD[IdxUSD % ListUSD.Count()];
					IdxUSD = IdxUSD + 1;
				Else
					Partner = ListVND[IdxVND % ListVND.Count()];
					IdxVND = IdxVND + 1;
				EndIf;
				
				ContractRef = MapHD.Get(Partner.Ref);
				
				DayVal = 1 + ((InvIdx * 3) % 27);
				HourVal = 8 + (InvIdx % 10);
				MinVal = (InvIdx * 7) % 60;
				DocDate = Date(CurYear, CurMonth, DayVal, HourVal, MinVal, 0);
				
				// 8.1. Tao Hoa don nha cung cap
				DocNumHD = "HD" + Format(DocDate, "DF=yyyyMM") + Right("0000" + String(InvIdx), 4);
				RefExistingHD = Documents.HoaDonNhaCungCap.FindByNumber(DocNumHD, DocDate);
				If ValueIsFilled(RefExistingHD) Then
					Raise "SEED_NUMBER_COLLISION: " + String(RefExistingHD);
				Else
					DocHD = Documents.HoaDonNhaCungCap.CreateDocument();
					DocHD.Number = DocNumHD;
				EndIf;
				DocHD.Date = DocDate;
				DocHD.NgayHoaDon = BegOfDay(DocDate);
				DocHD.SoHoaDon = "INV-" + TrimAll(Partner.Code) + "-" + Format(DocDate, "DF=yyyyMM") + "-" + Right("000" + String(InvIdx), 3);
				DocHD.PhapNhan = RefPN_VSF;
				DocHD.DoiTac = Partner.Ref;
				DocHD.HopDong = ContractRef;
				DocHD.NguoiDuyet = "ketoan_truong";
				DocHD.TaiKhoanChiPhi = RefTK_627;
				DocHD.CoKhauTruFCT = False;
				
				If IsUSD Then
					DocHD.TienTe = RefUSD;
					BaseUSD = 1500 + ((InvIdx * 733 + MonthNum * 1109) % 40000);
					Rate = 25400;
					DocHD.TyGia = Rate;
					DocHD.TongTienNgoaiTe = BaseUSD;
					DocHD.TongTien = Round(DocHD.TongTienNgoaiTe * DocHD.TyGia, 2);
					DocHD.TienDichVu = DocHD.TongTien;
					DocHD.TienThueVAT = 0;
					DocHD.ChiPhiVSF = DocHD.TongTien;
					DocHD.NoThucTraNCC = DocHD.TongTien;
				Else
					DocHD.TienTe = RefVND;
					DocHD.TyGia = 1;
					DocHD.TongTienNgoaiTe = 0;
					VNDDichVu = 15000000 + ((InvIdx * 7919 + MonthNum * 13579) % 450) * 1000000;
					DocHD.TienDichVu = VNDDichVu;
					DocHD.TienThueVAT = Round(VNDDichVu * 0.1, 2);
					DocHD.TongTien = DocHD.TienDichVu + DocHD.TienThueVAT;
					DocHD.ChiPhiVSF = DocHD.TienDichVu;
					DocHD.NoThucTraNCC = DocHD.TongTien;
				EndIf;
				
				DocHD.TrangThai = Enums.TrangThaiHoaDonAP.DuThao;
				DocHD.DienGiai = "Hóa đơn chi phí hạ tầng/dịch vụ CNTT từ NCC " + Partner.Description;
				DocHD.Write();
				DocHD.TrangThai = Enums.TrangThaiHoaDonAP.ChoKeToanTruongDuyet;
				DocHD.Write();
				If DocHD.NguoiLap <> UserName() Or DocHD.TrangThai <> Enums.TrangThaiHoaDonAP.ChoKeToanTruongDuyet Then
					Raise "AP invoice draft maker or KTT queue state was not captured from the authenticated session.";
				EndIf;
				TotalHD = TotalHD + 1;
				
				DocBatchCount = DocBatchCount + 1;
				If DocBatchCount >= 50 Then
					CommitTransaction();
					InTransaction = False;
					BeginTransaction();
					InTransaction = True;
					DocBatchCount = 0;
				EndIf;
				
				// 8.2. Tao Uy nhiem chi theo ty le tuoi no chuan doanh nghiep:
				// Thang 1-16 (16 thang): 59/60 hoa don duoc chi tra (1 hoa don tranh chap/giu lai >90d)
				// Thang 17 (05/2026): 58/60 hoa don duoc chi tra (2 hoa don >90d -> tong >90d = 18 hoa don)
				// Thang 18 (06/2026): 56/60 hoa don duoc chi tra (4 hoa don qua han 61-90d)
				// Thang 19 (07/2026): 52/60 hoa don duoc chi tra (8 hoa don qua han 31-60d)
				// Thang 20 (08/2026): 48/60 hoa don duoc chi tra (12 hoa don qua han 1-30d)
				// Thang 21 (09/2026): 30/60 hoa don duoc chi tra (30 hoa don trong han)
				PaidAPCount = 59;
				If MonthNum <= 16 Then
					PaidAPCount = 59;
				ElsIf MonthNum = 17 Then
					PaidAPCount = 58;
				ElsIf MonthNum = 18 Then
					PaidAPCount = 56;
				ElsIf MonthNum = 19 Then
					PaidAPCount = 52;
				ElsIf MonthNum = 20 Then
					PaidAPCount = 48;
				Else
					PaidAPCount = 30;
				EndIf;
				
				If GeneratePayments And InvIdx <= PaidAPCount Then
					PayDate = DocHD.Date + 86400 * 10;
					DocNumUNC = "UNC" + Format(DocDate, "DF=yyyyMM") + Right("0000" + String(InvIdx), 4);
					RefExistingUNC = Documents.UyNhiemChi.FindByNumber(DocNumUNC, PayDate);
					If ValueIsFilled(RefExistingUNC) Then
						Raise "SEED_NUMBER_COLLISION: " + String(RefExistingUNC);
					Else
						DocUNC = Documents.UyNhiemChi.CreateDocument();
						DocUNC.Number = DocNumUNC;
					EndIf;
					DocUNC.Date = PayDate;
					DocUNC.NgayLap = PayDate;
					DocUNC.NgayGhiSo = PayDate;
					DocUNC.PhapNhan = RefPN_VSF;
					DocUNC.DoiTac = Partner.Ref;
					DocUNC.HopDong = ContractRef;
					DocUNC.ChungTuGoc = DocHD.Ref;
					DocUNC.TaiKhoanTien = ?(DocHD.TienTe = RefUSD, RefTK_VCB, RefTK_TCB);
					DocUNC.KhoanMucDongTien = RefKM_Chi;
					DocUNC.TienTe = DocHD.TienTe;
					DocUNC.TyGia = DocHD.TyGia;
					DocUNC.SoTien = DocHD.TongTien;
					DocUNC.SoTienNgoaiTe = DocHD.TongTienNgoaiTe;
					DocUNC.PhiNganHang = 5500;
					DocUNC.TrangThai = Enums.TrangThaiLenhThanhToan.DaGhiSo;
					DocUNC.NguoiLap = "ketoan_ap";
					DocUNC.NguoiDuyet = "cfo_giamdoc";
					DocUNC.DienGiai = "Thanh toán hóa đơn NCC " + DocHD.Number;
					DocUNC.Write(DocumentWriteMode.Posting);
					TotalUNC = TotalUNC + 1;
					
					DocBatchCount = DocBatchCount + 1;
					If DocBatchCount >= 50 Then
						CommitTransaction();
						InTransaction = False;
						BeginTransaction();
						InTransaction = True;
						DocBatchCount = 0;
					EndIf;
				EndIf;
			EndDo;
		EndDo;
		
		If InTransaction Then
			CommitTransaction();
			InTransaction = False;
		EndIf;
		
		MsgSuccess = StrTemplate("Khởi tạo AP thành công: HoaDonNCC=%1, UyNhiemChi=%2 (Tổng cộng %3 chứng từ)",
			TotalHD, TotalUNC, TotalHD + TotalUNC);
		WriteLogEvent("AP.Seed", EventLogLevel.Information,,, MsgSuccess);
	Except
		If InTransaction Then
			RollbackTransaction();
			InTransaction = False;
		EndIf;
		WriteLogEvent("AP.Seed", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		Raise;
	EndTry;
EndProcedure

Procedure ApproveAPSeedInvoicesKTT()
	Threshold = Constants.NguongPheDuyetChiTienCFO.Get();
	If Threshold <= 0 Then Threshold = 500000000; EndIf;
	Q = New Query;
	Q.Text = "SELECT Ref FROM Document.HoaDonNhaCungCap WHERE Number LIKE ""HD20%"" AND Posted = FALSE ORDER BY Date, Number";
	Rows = Q.Execute().Select();
	BatchCount = 0; InTransaction = False;
	Try
		BeginTransaction(); InTransaction = True;
		While Rows.Next() Do
			Doc = Rows.Ref.GetObject();
			If Doc.NguoiLap <> "ketoan_ap" Or Doc.TrangThai <> Enums.TrangThaiHoaDonAP.ChoKeToanTruongDuyet Then
				Raise "AP invoice is not a submitted AP maker document: " + Doc.Number;
			EndIf;
			Doc.NguoiDuyet = UserName();
			If Doc.TongTien > Threshold Then
				Doc.TrangThai = Enums.TrangThaiHoaDonAP.ChoDuyetCFO;
				Doc.Write();
			Else
				Doc.TrangThai = Enums.TrangThaiHoaDonAP.DaGhiSo;
				Doc.Write(DocumentWriteMode.Posting);
				If Not Doc.Posted Then Raise "KTT failed to post AP invoice " + Doc.Number; EndIf;
			EndIf;
			BatchCount = BatchCount + 1;
			If BatchCount % 50 = 0 Then CommitTransaction(); InTransaction = False; BeginTransaction(); InTransaction = True; EndIf;
		EndDo;
		CommitTransaction(); InTransaction = False;
	Except
		If InTransaction Then RollbackTransaction(); InTransaction = False; EndIf;
		Raise;
	EndTry;
EndProcedure

Procedure PostHighAPSeedInvoicesCFO()
	Threshold = Constants.NguongPheDuyetChiTienCFO.Get();
	If Threshold <= 0 Then Threshold = 500000000; EndIf;
	Q = New Query;
	Q.Text = "SELECT Ref FROM Document.HoaDonNhaCungCap WHERE Number LIKE ""HD20%"" AND Posted = FALSE ORDER BY Date, Number";
	Rows = Q.Execute().Select();
	BatchCount = 0; InTransaction = False;
	Try
		BeginTransaction(); InTransaction = True;
		While Rows.Next() Do
			Doc = Rows.Ref.GetObject();
			If Doc.TongTien <= Threshold Then
				Continue;
			EndIf;
			If Doc.NguoiLap <> "ketoan_ap" Or Doc.NguoiDuyet <> "ketoan_truong"
				Or Doc.TrangThai <> Enums.TrangThaiHoaDonAP.ChoDuyetCFO Then
				Raise "High-value AP invoice is not in the CFO approval queue: " + Doc.Number;
			EndIf;
			Doc.NguoiDuyet = UserName();
			Doc.TrangThai = Enums.TrangThaiHoaDonAP.DaGhiSo;
			Doc.Write(DocumentWriteMode.Posting);
			If Not Doc.Posted Then Raise "CFO failed to post high-value AP invoice " + Doc.Number; EndIf;
			BatchCount = BatchCount + 1;
			If BatchCount % 50 = 0 Then CommitTransaction(); InTransaction = False; BeginTransaction(); InTransaction = True; EndIf;
		EndDo;
		CommitTransaction(); InTransaction = False;
	Except
		If InTransaction Then RollbackTransaction(); InTransaction = False; EndIf;
		Raise;
	EndTry;
EndProcedure

// Kiem tra xac minh so luong chung tu AP da duoc ghi so
Procedure KiemTraChungTuAP() Export
	Q_HD = New Query("SELECT COUNT(*) AS Cnt FROM Document.HoaDonNhaCungCap WHERE Posted = TRUE");
	CntHD = Q_HD.Execute().Unload()[0].Cnt;
	
	Q_UNC = New Query("SELECT COUNT(*) AS Cnt FROM Document.UyNhiemChi WHERE Posted = TRUE");
	CntUNC = Q_UNC.Execute().Unload()[0].Cnt;
	
	If CntHD >= 1000 And CntUNC >= 1000 Then
		WriteLogEvent("AP.Verify", EventLogLevel.Information,,, "AP_VERIFY_SUCCESS: HoaDonNCC=" + CntHD + ", UyNhiemChi=" + CntUNC);
	Else
		WriteLogEvent("AP.Verify", EventLogLevel.Error,,, "AP_VERIFY_FAILED: HoaDonNCC=" + CntHD + ", UyNhiemChi=" + CntUNC);
	EndIf;
EndProcedure

#EndRegion

#Region InternalProcedures

// Don dep cac chung tu AP cu neu co de dam bao tinh idempotent
// Bulk cleanup removed: restore a fresh UAT clone instead.

#EndRegion


