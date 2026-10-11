// CommonModule: GeneratorAPServer
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Sinh khoi luong lon chung tu nghiep vu AP (Hoa don nha cung cap & Uy nhiem chi)
//           cho giai doan tu 01/01/2025 den 30/09/2026 (21 thang, ~2,000 - 2,800 chung tu)

#Region PublicInterface

// Sinh toan bo chung tu nghiep vu AP (Hoa don NCC va Uy nhiem chi)
Procedure KhoiTaoChungTuAP() Export
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
	
	// 4. Lay Tai khoan chi phi va Khoan muc dong tien
	RefTK_627 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("627");
	RefKM_Chi = Catalogs.KhoanMucDongTien.FindByCode("KM-CHI-CLOUD");
	
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
	XoaDuLieuAPCu();
	
	// 8. Vong lap sinh du lieu AP tu thang 01/2025 den 09/2026 (21 thang)
	IdxUSD = 0;
	IdxVND = 0;
	TotalHD = 0;
	TotalUNC = 0;
	DocBatchCount = 0;
	InTransaction = False;
	
	BeginTransaction();
	InTransaction = True;
	
	Try
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
				DocHD = Documents.HoaDonNhaCungCap.CreateDocument();
				DocHD.Number = "HD" + Format(DocDate, "DF=yyyyMM") + Right("0000" + String(InvIdx), 4);
				DocHD.Date = DocDate;
				DocHD.NgayHoaDon = BegOfDay(DocDate);
				DocHD.SoHoaDon = "INV-" + TrimAll(Partner.Code) + "-" + Format(DocDate, "DF=yyyyMM") + "-" + Right("000" + String(InvIdx), 3);
				DocHD.PhapNhan = RefPN_VSF;
				DocHD.DoiTac = Partner.Ref;
				DocHD.HopDong = ContractRef;
				DocHD.TaiKhoanChiPhi = RefTK_627;
				DocHD.CoKhauTruFCT = False;
				
				If IsUSD Then
					DocHD.TienTe = RefUSD;
					BaseUSD = 1500 + ((InvIdx * 733 + MonthNum * 1109) % 40000);
					DocHD.TongTienNgoaiTe = BaseUSD;
					Rate = QuanLyTyGiaVaNgoaiTeServer.LayTyGiaHachToanHieuLuc(RefUSD, BegOfDay(DocDate));
					If Rate <= 1 Then
						Rate = 25400;
					EndIf;
					DocHD.TyGia = Rate;
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
				
				DocHD.TrangThai = Enums.TrangThaiHoaDonAP.DaGhiSo;
				DocHD.DienGiai = "Hóa đơn chi phí hạ tầng/dịch vụ CNTT từ NCC " + Partner.Description;
				DocHD.Write(DocumentWriteMode.Posting);
				TotalHD = TotalHD + 1;
				
				DocBatchCount = DocBatchCount + 1;
				If DocBatchCount >= 50 Then
					CommitTransaction();
					BeginTransaction();
					DocBatchCount = 0;
				EndIf;
				
				// 8.2. Tao Uy nhiem chi (50 tren 60 hoa don moi thang -> 21 thang x 50 = 1,050 UNC)
				If InvIdx <= 50 Then
					PayDate = DocHD.Date + 86400 * 10;
					DocUNC = Documents.UyNhiemChi.CreateDocument();
					DocUNC.Number = "UNC" + Format(DocDate, "DF=yyyyMM") + Right("0000" + String(InvIdx), 4);
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
					DocUNC.NguoiLap = "KeToanAP";
					DocUNC.NguoiDuyet = "CFO";
					DocUNC.DienGiai = "Thanh toán hóa đơn NCC " + DocHD.Number;
					DocUNC.Write(DocumentWriteMode.Posting);
					TotalUNC = TotalUNC + 1;
					
					DocBatchCount = DocBatchCount + 1;
					If DocBatchCount >= 50 Then
						CommitTransaction();
						BeginTransaction();
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
Procedure XoaDuLieuAPCu()
	Q_UNC = New Query("SELECT Ref FROM Document.UyNhiemChi WHERE DoiTac.Code LIKE ""TEST_NCC_%""");
	T_UNC = Q_UNC.Execute().Unload();
	If T_UNC.Count() > 0 Then
		BatchCount = 0;
		BeginTransaction();
		For Each Row In T_UNC Do
			Try
				Obj = Row.Ref.GetObject();
				If Obj <> Undefined Then
					If Obj.Posted Then
						Obj.Write(DocumentWriteMode.UndoPosting);
					EndIf;
					Obj.Delete();
					BatchCount = BatchCount + 1;
					If BatchCount >= 50 Then
						CommitTransaction();
						BeginTransaction();
						BatchCount = 0;
					EndIf;
				EndIf;
			Except
			EndTry;
		EndDo;
		CommitTransaction();
	EndIf;
	
	Q_HD = New Query("SELECT Ref FROM Document.HoaDonNhaCungCap WHERE DoiTac.Code LIKE ""TEST_NCC_%""");
	T_HD = Q_HD.Execute().Unload();
	If T_HD.Count() > 0 Then
		BatchCount = 0;
		BeginTransaction();
		For Each Row In T_HD Do
			Try
				Obj = Row.Ref.GetObject();
				If Obj <> Undefined Then
					If Obj.Posted Then
						Obj.Write(DocumentWriteMode.UndoPosting);
					EndIf;
					Obj.Delete();
					BatchCount = BatchCount + 1;
					If BatchCount >= 50 Then
						CommitTransaction();
						BeginTransaction();
						BatchCount = 0;
					EndIf;
				EndIf;
			Except
			EndTry;
		EndDo;
		CommitTransaction();
	EndIf;
EndProcedure

#EndRegion
