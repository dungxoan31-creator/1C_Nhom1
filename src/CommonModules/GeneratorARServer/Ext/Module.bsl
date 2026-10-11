// CommonModule: GeneratorARServer
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Sinh chu trinh chung tu AR (Nghiem thu, Hoa don GTGT dau ra, Bao co ngan hang, Phieu thu tien)
//           Giai doan: 01/01/2025 - 30/09/2026 (21 thang)
//           Quy mo: 1,200 - 1,500 bo nghiem thu & hoa don, 800 - 1,000 chung tu thu tien

#Region PublicInterface

// Khoi tao day chuyen chung tu AR toan dien tu 01/2025 den 09/2026
Procedure KhoiTaoChungTuAR() Export
	RefPN_VSF = LayPhapNhanVSF();
	RefVND = LayTienTe("VND", "Việt Nam Đồng");
	RefTK_TCB = LayTaiKhoanTienTCB(RefVND);
	RefKM_01 = LayKhoanMucDongTien();
	
	// Xoa du lieu AR cu neu co de dam bao tinh idempotent
	XoaDuLieuARCu();
	
	DanhSachVG = LayDanhSachDoiTac("TEST_VG", RefPN_VSF, RefVND);
	DanhSachKH = LayDanhSachDoiTac("TEST_KH", RefPN_VSF, RefVND);
	
	If DanhSachVG.Count() = 0 Or DanhSachKH.Count() = 0 Then
		WriteLogEvent("AR.Seed", EventLogLevel.Error,,, "Không tìm thấy danh sách đối tác TEST_VG hoặc TEST_KH để sinh chứng từ AR!");
		Raise "Thiếu Master Data đối tác TEST_VG hoặc TEST_KH!";
	EndIf;
	
	// Cac muc gia nghiem thu dinh san theo yeu cau
	BaseAmountsVG = New Array;
	BaseAmountsVG.Add(250000000);
	BaseAmountsVG.Add(450000000);
	BaseAmountsVG.Add(700000000);
	BaseAmountsVG.Add(1200000000);
	BaseAmountsVG.Add(1800000000);
	BaseAmountsVG.Add(2500000000);
	BaseAmountsVG.Add(3200000000);
	BaseAmountsVG.Add(4100000000);
	BaseAmountsVG.Add(4800000000);
	
	BaseAmountsKH = New Array;
	BaseAmountsKH.Add(15000000);
	BaseAmountsKH.Add(30000000);
	BaseAmountsKH.Add(55000000);
	BaseAmountsKH.Add(85000000);
	BaseAmountsKH.Add(120000000);
	BaseAmountsKH.Add(165000000);
	BaseAmountsKH.Add(210000000);
	BaseAmountsKH.Add(260000000);
	BaseAmountsKH.Add(290000000);
	
	GlobalDocIndex = 0;
	GlobalBCIndex = 0;
	GlobalPTIndex = 0;
	BatchDocCount = 0;
	IsInTransaction = False;
	
	BeginTransaction();
	IsInTransaction = True;
	
	Try
		// Vong lap 21 thang tu 01/2025 den 09/2026
		For MonthIdx = 1 To 21 Do
			If MonthIdx <= 12 Then
				Y = 2025;
				M = MonthIdx;
			Else
				Y = 2026;
				M = MonthIdx - 12;
			EndIf;
			YearSuffix = Right(Format(Y, "NG=0"), 2);
			
			// Phan bo ty le thanh toan theo tuoi no tai thoi diem 30/09/2026:
			// Thang 1-14: 57 bo tra tien (3 bo qua han >90 ngay)
			// Thang 15-17: 18 bo tra tien (42 bo qua han 61-90 ngay)
			// Thang 18-19: 15 bo tra tien (45 bo qua han 31-60 ngay)
			// Thang 20-21: 10 bo tra tien (50 bo qua han 1-30 ngay)
			If MonthIdx <= 14 Then
				PaidCountInMonth = 57;
				PaidVGCount = 18;
			ElsIf MonthIdx <= 17 Then
				PaidCountInMonth = 18;
				PaidVGCount = 10;
			ElsIf MonthIdx <= 19 Then
				PaidCountInMonth = 15;
				PaidVGCount = 8;
			Else
				PaidCountInMonth = 10;
				PaidVGCount = 5;
			EndIf;
			
			// Moi thang sinh dung 60 bo chung tu (tong 21 thang = 1,260 bo)
			For SetIdx = 1 To 60 Do
				GlobalDocIndex = GlobalDocIndex + 1;
				
				IsVG = (SetIdx <= 18);
				If IsVG Then
					PartnerIndex = ((MonthIdx - 1) * 7 + (SetIdx - 1)) % DanhSachVG.Count();
					PartnerInfo = DanhSachVG[PartnerIndex];
					AmtIndex = (SetIdx + MonthIdx) % BaseAmountsVG.Count();
					PreVatAmount = BaseAmountsVG[AmtIndex] + ((SetIdx - 1) * 5000000);
					IsPaid = (SetIdx <= PaidVGCount);
				Else
					PartnerIndex = ((MonthIdx - 1) * 11 + (SetIdx - 19)) % DanhSachKH.Count();
					PartnerInfo = DanhSachKH[PartnerIndex];
					AmtIndex = (SetIdx + MonthIdx) % BaseAmountsKH.Count();
					PreVatAmount = BaseAmountsKH[AmtIndex] + ((SetIdx - 19) * 1000000);
					IsPaid = (SetIdx <= PaidCountInMonth);
				EndIf;
				
				DayVal = 1 + Int((SetIdx - 1) * 27 / 60);
				HourVal = 8 + (SetIdx % 9);
				MinVal = (SetIdx * 7) % 60;
				DocDate = Date(Y, M, DayVal, HourVal, MinVal, 0);
				
				VatAmount = Round(PreVatAmount * 0.1, 2);
				TotalAmount = PreVatAmount + VatAmount;
				
				// -------------------------------------------------------------
				// 1. BienBanNghiemThuGiaiDoan
				// -------------------------------------------------------------
				DocBB = Documents.BienBanNghiemThuGiaiDoan.CreateDocument();
				DocBB.Date = DocDate;
				DocBB.Number = "BB-" + YearSuffix + "-" + DinhDangSo(GlobalDocIndex, 6);
				DocBB.PhapNhan = RefPN_VSF;
				DocBB.DoiTac = PartnerInfo.DoiTac;
				DocBB.HopDong = PartnerInfo.HopDong;
				DocBB.GiaTriNghiemThuChuaVAT = PreVatAmount;
				DocBB.TyLeVAT = 10;
				DocBB.TienVAT = VatAmount;
				DocBB.TongGiaTri = TotalAmount;
				DocBB.TrangThai = Enums.TrangThaiNghiemThuAR.DaDuyetNoiBo;
				DocBB.NguoiTao = "KeToanAR";
				DocBB.NguoiDuyet = "CFO";
				DocBB.NgayNghiemThu = BegOfDay(DocDate);
				DocBB.DienGiai = StrTemplate("Nghiệm thu dịch vụ CNTT & Nền tảng số kỳ %1/%2 - Đối tác %3",
					DinhDangSo(M, 2), Format(Y, "NG=0"), PartnerInfo.TenDoiTac);
				DocBB.Write(DocumentWriteMode.Posting);
				BatchDocCount = BatchDocCount + 1;
				
				// -------------------------------------------------------------
				// 2. HoaDonGTGTDauRa
				// -------------------------------------------------------------
				DocHD = Documents.HoaDonGTGTDauRa.CreateDocument();
				DocHD.Date = DocDate + 3600;
				DocHD.Number = "HD-" + YearSuffix + "-" + DinhDangSo(GlobalDocIndex, 6);
				DocHD.SoHoaDon = DinhDangSo(GlobalDocIndex, 7);
				DocHD.KyHieu = "1C" + YearSuffix + "TVN";
				DocHD.PhapNhan = RefPN_VSF;
				DocHD.DoiTac = PartnerInfo.DoiTac;
				DocHD.HopDong = PartnerInfo.HopDong;
				DocHD.BienBanNghiemThu = DocBB.Ref;
				DocHD.NgayHoaDon = BegOfDay(DocDate);
				DocHD.TienChuaThue = PreVatAmount;
				DocHD.ThueSuatVAT = 10;
				DocHD.TienThueVAT = VatAmount;
				DocHD.TongTienThanhToan = TotalAmount;
				DocHD.TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.DaPhatHanh;
				DocHD.MaCQT = "CQT-" + YearSuffix + "-" + DinhDangSo(GlobalDocIndex, 7);
				DocHD.DienGiai = "Hóa đơn GTGT dịch vụ CNTT theo BB nghiệm thu " + DocBB.Number;
				DocHD.Write(DocumentWriteMode.Posting);
				BatchDocCount = BatchDocCount + 1;
				
				// -------------------------------------------------------------
				// 3. Chung tu Thu tien (Thanh toan)
				// -------------------------------------------------------------
				If IsPaid Then
					If IsVG Then
						GlobalBCIndex = GlobalBCIndex + 1;
						PayDate = DocDate + 86400 * 20;
						If PayDate > Date(2026, 9, 30, 18, 0, 0) Then
							PayDate = Date(2026, 9, 30, 17, MinVal, 0);
						EndIf;
						
						DocBC = Documents.BaoCoNganHang.CreateDocument();
						DocBC.Date = PayDate;
						DocBC.Number = "BC-" + YearSuffix + "-" + DinhDangSo(GlobalBCIndex, 6);
						DocBC.PhapNhan = RefPN_VSF;
						DocBC.TaiKhoanTien = RefTK_TCB;
						DocBC.SoTien = TotalAmount;
						DocBC.NgayGiaoDich = PayDate;
						DocBC.MaGiaoDichNganHang = "TCB-" + YearSuffix + "-" + DinhDangSo(GlobalBCIndex, 6);
						DocBC.NoiDungChuyenKhoan = "Thanh toán công nợ theo BB " + DocBB.Number;
						DocBC.DoiTacKhop = PartnerInfo.DoiTac;
						DocBC.ChungTuKhop = DocBB.Ref;
						DocBC.TuDongGhiSo = True;
						DocBC.TrangThai = "DaDoiSoat";
						DocBC.DienGiai = "Báo có Techcombank khớp tự động với " + DocBB.Number;
						DocBC.Write(DocumentWriteMode.Posting);
						BatchDocCount = BatchDocCount + 1;
					Else
						GlobalPTIndex = GlobalPTIndex + 1;
						PayDate = DocDate + 86400 * 15;
						If PayDate > Date(2026, 9, 30, 18, 0, 0) Then
							PayDate = Date(2026, 9, 30, 16, MinVal, 0);
						EndIf;
						
						DocPT = Documents.PhieuThuTienKhachHang.CreateDocument();
						DocPT.Date = PayDate;
						DocPT.Number = "PT-" + YearSuffix + "-" + DinhDangSo(GlobalPTIndex, 6);
						DocPT.PhapNhan = RefPN_VSF;
						DocPT.DoiTac = PartnerInfo.DoiTac;
						DocPT.HopDong = PartnerInfo.HopDong;
						DocPT.ChungTuGoc = DocBB.Ref;
						DocPT.TaiKhoanTien = RefTK_TCB;
						DocPT.TienTe = RefVND;
						DocPT.KhoanMucDongTien = RefKM_01;
						DocPT.SoTien = TotalAmount;
						DocPT.SoTienNgoaiTe = 0;
						DocPT.TyGia = 1;
						DocPT.NgayThu = BegOfDay(PayDate);
						DocPT.DienGiai = "Thu tiền khách hàng theo BB nghiệm thu " + DocBB.Number;
						DocPT.Write(DocumentWriteMode.Posting);
						BatchDocCount = BatchDocCount + 1;
					EndIf;
				EndIf;
				
				// Phan me giao dich: cu 50 chung tu commit va bat dau me moi
				If BatchDocCount >= 50 Then
					CommitTransaction();
					IsInTransaction = False;
					BeginTransaction();
					IsInTransaction = True;
					BatchDocCount = 0;
				EndIf;
			EndDo;
		EndDo;
		
		If IsInTransaction Then
			CommitTransaction();
			IsInTransaction = False;
		EndIf;
		
		WriteLogEvent("AR.Seed", EventLogLevel.Information,,, "Khởi tạo thành công toàn bộ chứng từ AR!");
	Except
		If IsInTransaction Then
			RollbackTransaction();
			IsInTransaction = False;
		EndIf;
		WriteLogEvent("AR.Seed", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		Raise;
	EndTry;
EndProcedure

// Kiem tra so luong va tinh toan ven cua day chuyen chung tu AR da nap
Procedure KiemTraChungTuAR() Export
	CntBB = DemChungTuDaGhiSo("BienBanNghiemThuGiaiDoan");
	CntHD = DemChungTuDaGhiSo("HoaDonGTGTDauRa");
	CntPT = DemChungTuDaGhiSo("PhieuThuTienKhachHang");
	CntBC = DemChungTuDaGhiSo("BaoCoNganHang");
	CntThu = CntPT + CntBC;
	
	If CntBB >= 1200 And CntHD >= 1200 And CntThu >= 800 Then
		Msg = "AR_VERIFY_SUCCESS: BienBan=" + Format(CntBB, "NG=0") + ", HoaDon=" + Format(CntHD, "NG=0") + ", ThuTien=" + Format(CntThu, "NG=0") + " (PhieuThu=" + Format(CntPT, "NG=0") + ", BaoCo=" + Format(CntBC, "NG=0") + ")";
		WriteLogEvent("AR.Verify", EventLogLevel.Information,,, Msg);
	Else
		Msg = "AR_VERIFY_FAILED: BienBan=" + Format(CntBB, "NG=0") + ", HoaDon=" + Format(CntHD, "NG=0") + ", ThuTien=" + Format(CntThu, "NG=0") + " (PhieuThu=" + Format(CntPT, "NG=0") + ", BaoCo=" + Format(CntBC, "NG=0") + ")";
		WriteLogEvent("AR.Verify", EventLogLevel.Error,,, Msg);
	EndIf;
EndProcedure

#EndRegion

#Region InternalProceduresAndFunctions

// Dinh dang so nguyen thanh chuoi co do dai co dinh kem so 0 o dau (khong co dau phan cach ngan)
Function DinhDangSo(Val Num, Val Len)
	StrNum = Format(Num, "NG=0");
	Prefix = "";
	While StrLen(Prefix) + StrLen(StrNum) < Len Do
		Prefix = Prefix + "0";
	EndDo;
	Return Prefix + StrNum;
EndFunction

// Dem so luong chung tu da ghi so cua mot loai chung tu
Function DemChungTuDaGhiSo(Val DocName)
	Query = New Query;
	Query.Text = "SELECT COUNT(*) AS Cnt FROM Document." + DocName + " WHERE Posted = TRUE";
	Sel = Query.Execute().Select();
	If Sel.Next() Then
		Return Sel.Cnt;
	EndIf;
	Return 0;
EndFunction

// Lay hoac khoi tao PhapNhan VSF
Function LayPhapNhanVSF()
	RefPN = Catalogs.PhapNhan.FindByCode("PN-VSF");
	If Not ValueIsFilled(RefPN) Then
		RefPN = Catalogs.PhapNhan.FindByCode("VSF");
	EndIf;
	If Not ValueIsFilled(RefPN) Then
		ObjPN = Catalogs.PhapNhan.CreateItem();
		ObjPN.Code = "PN-VSF";
		ObjPN.Description = "Công ty CP VinSmart Future";
		ObjPN.MaSoThue = "0108999888";
		ObjPN.DiaChi = "Tòa nhà Symphony, Chu Huy Mân, Long Biên, Hà Nội";
		ObjPN.Write();
		RefPN = ObjPN.Ref;
	EndIf;
	Return RefPN;
EndFunction

// Lay hoac khoi tao TienTe
Function LayTienTe(Code, Desc)
	Ref = Catalogs.TienTe.FindByCode(Code);
	If Not ValueIsFilled(Ref) Then
		Obj = Catalogs.TienTe.CreateItem();
		Obj.Code = Code;
		Obj.Description = Desc;
		Obj.Write();
		Ref = Obj.Ref;
	EndIf;
	Return Ref;
EndFunction

// Lay hoac khoi tao TaiKhoanTien Techcombank
Function LayTaiKhoanTienTCB(RefVND)
	RefTK = Catalogs.TaiKhoanTien.FindByCode("TK-TCB-VND");
	If Not ValueIsFilled(RefTK) Then
		ObjTK = Catalogs.TaiKhoanTien.CreateItem();
		ObjTK.Code = "TK-TCB-VND";
		ObjTK.Description = "Techcombank VND - Hoi so chinh";
		ObjTK.SoTaiKhoan = "1903889988001";
		ObjTK.NganHang = "Techcombank - Hoi so chinh";
		ObjTK.TienTe = RefVND;
		ObjTK.Write();
		RefTK = ObjTK.Ref;
	EndIf;
	Return RefTK;
EndFunction

// Lay hoac khoi tao KhoanMucDongTien KM-01
Function LayKhoanMucDongTien()
	RefKM = Catalogs.KhoanMucDongTien.FindByCode("KM-01");
	If Not ValueIsFilled(RefKM) Then
		ObjKM = Catalogs.KhoanMucDongTien.CreateItem();
		ObjKM.Code = "KM-01";
		ObjKM.Description = "Thu tiền bán hàng và cung cấp dịch vụ";
		ObjKM.LoaiDongTien = "Thu";
		ObjKM.Write();
		RefKM = ObjKM.Ref;
	EndIf;
	Return RefKM;
EndFunction

// Lay danh sach doi tac va hop dong tuong ung
Function LayDanhSachDoiTac(MaPrefix, RefPN_VSF, RefVND)
	Query = New Query;
	Query.Text = 
		"SELECT
		|	DT.Ref AS DoiTac,
		|	DT.Code AS MaDoiTac,
		|	DT.Description AS TenDoiTac,
		|	DT.LaBenLienKet AS LaBenLienKet
		|FROM
		|	Catalog.DoiTac AS DT
		|WHERE
		|	DT.Code LIKE &Prefix
		|ORDER BY
		|	DT.Code";
	Query.SetParameter("Prefix", MaPrefix + "%");
	TableDT = Query.Execute().Unload();
	
	Result = New Array;
	For Each RowDT In TableDT Do
		Q_HD = New Query;
		Q_HD.Text = 
			"SELECT TOP 1
			|	Ref
			|FROM
			|	Catalog.HopDong
			|WHERE
			|	ChuSoHuu = &DoiTac";
		Q_HD.SetParameter("DoiTac", RowDT.DoiTac);
		T_HD = Q_HD.Execute().Unload();
		
		RefHD = Undefined;
		If T_HD.Count() > 0 Then
			RefHD = T_HD[0].Ref;
		Else
			RefHD = Catalogs.HopDong.FindByCode("HD-" + TrimAll(RowDT.MaDoiTac) + "-2025");
			If Not ValueIsFilled(RefHD) Then
				ObjHD = Catalogs.HopDong.CreateItem();
				ObjHD.Code = "HD-" + TrimAll(RowDT.MaDoiTac) + "-2025";
				ObjHD.Description = "Hợp đồng dịch vụ 2025 - " + RowDT.TenDoiTac;
				ObjHD.PhapNhan = RefPN_VSF;
				ObjHD.ChuSoHuu = RowDT.DoiTac;
				ObjHD.DongTienThanhToan = RefVND;
				ObjHD.HanThanhToanNgay = ?(RowDT.LaBenLienKet, 60, 30);
				ObjHD.Write();
				RefHD = ObjHD.Ref;
			EndIf;
		EndIf;
		
		Item = New Structure;
		Item.Insert("DoiTac", RowDT.DoiTac);
		Item.Insert("MaDoiTac", RowDT.MaDoiTac);
		Item.Insert("TenDoiTac", RowDT.TenDoiTac);
		Item.Insert("LaBenLienKet", RowDT.LaBenLienKet);
		Item.Insert("HopDong", RefHD);
		Result.Add(Item);
	EndDo;
	
	Return Result;
EndFunction

// Don dep cac chung tu AR cu neu co
Procedure XoaDuLieuARCu()
	DanhSachDoc = New Array;
	DanhSachDoc.Add("PhieuThuTienKhachHang");
	DanhSachDoc.Add("BaoCoNganHang");
	DanhSachDoc.Add("HoaDonGTGTDauRa");
	DanhSachDoc.Add("BienBanNghiemThuGiaiDoan");
	
	For Each TenDoc In DanhSachDoc Do
		Q = New Query("SELECT Ref FROM Document." + TenDoc);
		T = Q.Execute().Unload();
		If T.Count() > 0 Then
			BeginTransaction();
			DelCount = 0;
			For Each R In T Do
				Try
					Obj = R.Ref.GetObject();
					If Obj <> Undefined Then
						If Obj.Posted Then
							Obj.Write(DocumentWriteMode.UndoPosting);
						EndIf;
						Obj.Delete();
						DelCount = DelCount + 1;
						If DelCount >= 100 Then
							CommitTransaction();
							BeginTransaction();
							DelCount = 0;
						EndIf;
					EndIf;
				Except
				EndTry;
			EndDo;
			CommitTransaction();
		EndIf;
	EndDo;
EndProcedure

#EndRegion
