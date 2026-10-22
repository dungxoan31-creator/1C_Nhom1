// CommonModule: GeneratorARServer
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Sinh chu trinh chung tu AR (Nghiem thu, Hoa don GTGT dau ra, Bao co ngan hang, Phieu thu tien)
//           Giai doan: 01/01/2025 - 30/09/2026 (21 thang)
//           Quy mo: 1,200 - 1,500 bo nghiem thu & hoa don, 800 - 1,000 chung tu thu tien

#Region PublicInterface

// Fixture documents are created and posted in real maker/checker sessions.
// Invoke the Prepare* stages as ketoan_ar, AR acceptance/invoice posting as ketoan_truong,
// and customer receipt posting as cfo_giamdoc.
Procedure KhoiTaoChungTuAR(Val Stage = "PrepareAcceptances") Export
	If Stage = "PostAcceptances" Or Stage = "PostInvoices" Then
		If Not IsInRole("KeToanTruong") Then Raise "AR acceptance/invoice seed posting stages require the Chief Accountant role."; EndIf;
	ElsIf Stage = "PostReceipts" Then
		If Not IsInRole("GiamDocTaiChinh_CFO") Then Raise "AR seed posting stages require the CFO role."; EndIf;
	ElsIf Stage = "PrepareAcceptances" Or Stage = "PrepareInvoices" Or Stage = "PrepareReceipts" Then
		If Not IsInRole("KeToanPhaiThu") Then Raise "AR seed preparation stages require the AR role."; EndIf;
	Else
		Raise "Unknown AR seed stage: " + Stage;
	EndIf;

	If Stage = "PostAcceptances" Then
		PostARSeedAcceptances();
		Return;
	ElsIf Stage = "PrepareInvoices" Then
		PrepareARSeedInvoices();
		Return;
	ElsIf Stage = "PostInvoices" Then
		PostARSeedInvoices();
		Return;
	ElsIf Stage = "PrepareReceipts" Then
		PrepareARSeedReceipts();
		Return;
	ElsIf Stage = "PostReceipts" Then
		PostARSeedReceipts();
		Return;
	EndIf;

	RefPN_VSF = LayPhapNhanVSF();
	RefVND = LayTienTe("VND", "Việt Nam Đồng");
	DanhSachVG = LayDanhSachDoiTac("TEST_VG", RefPN_VSF, RefVND);
	DanhSachKH = LayDanhSachDoiTac("TEST_KH", RefPN_VSF, RefVND);
	If DanhSachVG.Count() = 0 Or DanhSachKH.Count() = 0 Then
		Raise "Thiếu Master Data đối tác TEST_VG hoặc TEST_KH!";
	EndIf;

	BaseAmountsVG = New Array;
	BaseAmountsVG.Add(350000000); BaseAmountsVG.Add(600000000); BaseAmountsVG.Add(950000000);
	BaseAmountsVG.Add(1400000000); BaseAmountsVG.Add(1850000000); BaseAmountsVG.Add(2300000000);
	BaseAmountsVG.Add(2800000000); BaseAmountsVG.Add(3400000000); BaseAmountsVG.Add(4100000000);
	BaseAmountsKH = New Array;
	BaseAmountsKH.Add(80000000); BaseAmountsKH.Add(130000000); BaseAmountsKH.Add(190000000);
	BaseAmountsKH.Add(250000000); BaseAmountsKH.Add(310000000); BaseAmountsKH.Add(360000000);
	BaseAmountsKH.Add(420000000); BaseAmountsKH.Add(490000000); BaseAmountsKH.Add(550000000);

	BatchCount = 0;
	InTransaction = False;
	Try
		BeginTransaction();
		InTransaction = True;
		For MonthIdx = 1 To 21 Do
			If MonthIdx <= 12 Then Y = 2025; M = MonthIdx; Else Y = 2026; M = MonthIdx - 12; EndIf;
			YearSuffix = Right(Format(Y, "NG=0"), 2);
			For SetIdx = 1 To 60 Do
				GlobalDocIndex = (MonthIdx - 1) * 60 + SetIdx;
				IsVG = SetIdx <= 18;
				If IsVG Then
					PartnerIndex = ((MonthIdx - 1) * 7 + (SetIdx - 1)) % DanhSachVG.Count();
					PartnerInfo = DanhSachVG[PartnerIndex];
					AmtIndex = (SetIdx + MonthIdx) % BaseAmountsVG.Count();
					PreVatAmount = BaseAmountsVG[AmtIndex] + ((SetIdx - 1) * 5000000);
				Else
					PartnerIndex = ((MonthIdx - 1) * 11 + (SetIdx - 19)) % DanhSachKH.Count();
					PartnerInfo = DanhSachKH[PartnerIndex];
					AmtIndex = (SetIdx + MonthIdx) % BaseAmountsKH.Count();
					PreVatAmount = BaseAmountsKH[AmtIndex] + ((SetIdx - 19) * 1000000);
				EndIf;
				DayVal = 1 + Int((SetIdx - 1) * 27 / 60);
				HourVal = 8 + (SetIdx % 9);
				MinVal = (SetIdx * 7) % 60;
				DocDate = Date(Y, M, DayVal, HourVal, MinVal, 0);
				VatRate = ThueGTGTClientServer.TyLeVATApDungTheoNgay(DocDate, True);
				VatAmount = Round(PreVatAmount * VatRate / 100, 2);
				DocNumBB = "BB-" + YearSuffix + "-" + DinhDangSo(GlobalDocIndex, 6);
				If ValueIsFilled(Documents.BienBanNghiemThuGiaiDoan.FindByNumber(DocNumBB, DocDate)) Then
					Raise "SEED_NUMBER_COLLISION: " + DocNumBB;
				EndIf;
				DocBB = Documents.BienBanNghiemThuGiaiDoan.CreateDocument();
				DocBB.Number = DocNumBB;
				DocBB.Date = DocDate;
				DocBB.PhapNhan = RefPN_VSF;
				DocBB.DoiTac = PartnerInfo.DoiTac;
				DocBB.HopDong = PartnerInfo.HopDong;
				DocBB.ApDungGiamThueGTGT = True;
				DocBB.GiaTriNghiemThuChuaVAT = PreVatAmount;
				DocBB.TyLeVAT = VatRate;
				DocBB.TienVAT = VatAmount;
				DocBB.TongGiaTri = PreVatAmount + VatAmount;
				DocBB.NguoiDuyet = "ketoan_truong";
				DocBB.NgayNghiemThu = BegOfDay(DocDate);
				DocBB.DienGiai = StrTemplate("Nghiệm thu dịch vụ CNTT & Nền tảng số kỳ %1/%2 - Đối tác %3",
					DinhDangSo(M, 2), Format(Y, "NG=0"), PartnerInfo.TenDoiTac);
				DocBB.TrangThai = Enums.TrangThaiNghiemThuAR.DuThao;
				DocBB.Write();
				DocBB.TrangThai = Enums.TrangThaiNghiemThuAR.ChoDuyetNoiBo;
				DocBB.Write();
				If DocBB.NguoiTao <> UserName() Then Raise "AR acceptance maker was not captured from the authenticated session."; EndIf;
				BatchCount = BatchCount + 1;
				If BatchCount >= 50 Then
					CommitTransaction(); InTransaction = False; BeginTransaction(); InTransaction = True; BatchCount = 0;
				EndIf;
			EndDo;
		EndDo;
		CommitTransaction(); InTransaction = False;
		WriteLogEvent("AR.Seed", EventLogLevel.Information,,, "Created 1,260 acceptance drafts as the authenticated AR maker.");
	Except
		If InTransaction Then RollbackTransaction(); InTransaction = False; EndIf;
		WriteLogEvent("AR.Seed", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		Raise;
	EndTry;
EndProcedure

Procedure PostARSeedAcceptances()
	Q = New Query("SELECT Ref FROM Document.BienBanNghiemThuGiaiDoan WHERE Number LIKE ""BB-%"" AND Posted = FALSE ORDER BY Date, Number");
	Rows = Q.Execute().Select();
	BatchCount = 0; InTransaction = False;
	Try
		BeginTransaction(); InTransaction = True;
		While Rows.Next() Do
			Doc = Rows.Ref.GetObject();
			If Doc.NguoiTao <> "ketoan_ar" Or Doc.TrangThai <> Enums.TrangThaiNghiemThuAR.ChoDuyetNoiBo Then
				Raise "Acceptance is not a valid submitted AR maker document: " + Doc.Number;
			EndIf;
			Doc.TrangThai = Enums.TrangThaiNghiemThuAR.DaDuyetNoiBo;
			Doc.NguoiDuyet = UserName();
			Doc.Write();
			Doc.Write(DocumentWriteMode.Posting);
			If Not Doc.Posted Then Raise "CFO failed to post acceptance " + Doc.Number; EndIf;
			BatchCount = BatchCount + 1;
			If BatchCount % 50 = 0 Then CommitTransaction(); InTransaction = False; BeginTransaction(); InTransaction = True; EndIf;
		EndDo;
		CommitTransaction(); InTransaction = False;
	Except
		If InTransaction Then RollbackTransaction(); InTransaction = False; EndIf;
		Raise;
	EndTry;
EndProcedure

Procedure PrepareARSeedInvoices()
	Q = New Query("SELECT Ref FROM Document.BienBanNghiemThuGiaiDoan WHERE Number LIKE ""BB-%"" AND Posted = TRUE ORDER BY Date, Number");
	Rows = Q.Execute().Select();
	BatchCount = 0; InTransaction = False;
	Try
		BeginTransaction(); InTransaction = True;
		While Rows.Next() Do
			Acceptance = Rows.Ref.GetObject();
			If Acceptance.NguoiTao <> UserName() And Acceptance.NguoiTao <> "ketoan_ar" Then
				Raise "Acceptance maker is not the designated AR user: " + Acceptance.Number;
			EndIf;
			DocNumber = "HD-" + Mid(Acceptance.Number, 4, 2) + "-" + Right(Acceptance.Number, 6);
			InvoiceDate = Acceptance.Date + 3600;
			If ValueIsFilled(Documents.HoaDonGTGTDauRa.FindByNumber(DocNumber, InvoiceDate)) Then
				Raise "SEED_NUMBER_COLLISION: " + DocNumber;
			EndIf;
			Doc = Documents.HoaDonGTGTDauRa.CreateDocument();
			Doc.Number = DocNumber;
			Doc.Date = InvoiceDate;
			Doc.SoHoaDon = DinhDangSo(Number(Right(Acceptance.Number, 6)), 7);
			Doc.KyHieu = "1C" + Mid(Acceptance.Number, 4, 2) + "TVN";
			Doc.PhapNhan = Acceptance.PhapNhan;
			Doc.DoiTac = Acceptance.DoiTac;
			Doc.HopDong = Acceptance.HopDong;
			Doc.BienBanNghiemThu = Rows.Ref;
			Doc.ApDungGiamThueGTGT = Acceptance.ApDungGiamThueGTGT;
			Doc.NgayHoaDon = BegOfDay(Acceptance.Date);
			Doc.TienChuaThue = Acceptance.GiaTriNghiemThuChuaVAT;
			Doc.ThueSuatVAT = Acceptance.TyLeVAT;
			Doc.TienThueVAT = Acceptance.TienVAT;
			Doc.TongTienThanhToan = Acceptance.TongGiaTri;
			Doc.MaCQT = "CQT-" + Mid(Acceptance.Number, 4, 2) + "-" + DinhDangSo(Number(Right(Acceptance.Number, 6)), 7);
			Doc.NguoiDuyet = "ketoan_truong";
			Doc.DienGiai = "Hóa đơn GTGT dịch vụ CNTT theo BB nghiệm thu " + Acceptance.Number;
			Doc.TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.DuThao;
			Doc.Write();
			Doc.TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.ChoKySo;
			Doc.Write();
			If Doc.NguoiLap <> UserName() Then Raise "AR invoice maker was not captured from the authenticated session."; EndIf;
			BatchCount = BatchCount + 1;
			If BatchCount % 50 = 0 Then CommitTransaction(); InTransaction = False; BeginTransaction(); InTransaction = True; EndIf;
		EndDo;
		CommitTransaction(); InTransaction = False;
	Except
		If InTransaction Then RollbackTransaction(); InTransaction = False; EndIf;
		Raise;
	EndTry;
EndProcedure

Procedure PostARSeedInvoices()
	Q = New Query("SELECT Ref FROM Document.HoaDonGTGTDauRa WHERE Number LIKE ""HD-%"" AND Posted = FALSE ORDER BY Date, Number");
	Rows = Q.Execute().Select();
	BatchCount = 0; InTransaction = False;
	Try
		BeginTransaction(); InTransaction = True;
		While Rows.Next() Do
			Doc = Rows.Ref.GetObject();
			If Doc.NguoiLap <> "ketoan_ar" Or Doc.TrangThaiHDDT <> Enums.TrangThaiHoaDonDienTu.ChoKySo
				Or Not ValueIsFilled(Doc.BienBanNghiemThu) Or Not Doc.BienBanNghiemThu.Posted Then
				Raise "Invoice is not a valid submitted AR document: " + Doc.Number;
			EndIf;
			Doc.TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.DaPhatHanh;
			Doc.NguoiDuyet = UserName();
			Doc.Write(DocumentWriteMode.Posting);
			If Not Doc.Posted Then Raise "CFO failed to issue invoice " + Doc.Number; EndIf;
			BatchCount = BatchCount + 1;
			If BatchCount % 50 = 0 Then CommitTransaction(); InTransaction = False; BeginTransaction(); InTransaction = True; EndIf;
		EndDo;
		CommitTransaction(); InTransaction = False;
	Except
		If InTransaction Then RollbackTransaction(); InTransaction = False; EndIf;
		Raise;
	EndTry;
EndProcedure

Procedure PrepareARSeedReceipts()
	RefVND = Catalogs.TienTe.FindByCode("VND");
	RefBank = LayTaiKhoanTienTCB(RefVND);
	RefCashCategory = LayKhoanMucDongTien();
	Q = New Query("SELECT Ref FROM Document.HoaDonGTGTDauRa WHERE Number LIKE ""HD-%"" AND Posted = TRUE ORDER BY Date, Number");
	Rows = Q.Execute().Select();
	GlobalPTIndex = 0; BatchCount = 0; InTransaction = False;
	Try
		BeginTransaction(); InTransaction = True;
		While Rows.Next() Do
			Invoice = Rows.Ref.GetObject();
			GlobalDocIndex = Number(Right(Invoice.Number, 6));
			MonthIdx = Int((GlobalDocIndex - 1) / 60) + 1;
			SetIdx = ((GlobalDocIndex - 1) % 60) + 1;
			If MonthIdx <= 16 Then PaidCountInMonth = 59; ElsIf MonthIdx = 17 Then PaidCountInMonth = 58;
			ElsIf MonthIdx = 18 Then PaidCountInMonth = 52; ElsIf MonthIdx = 19 Then PaidCountInMonth = 46;
			ElsIf MonthIdx = 20 Then PaidCountInMonth = 40; Else PaidCountInMonth = 22; EndIf;
			If SetIdx <= 18 Then
				PaidVGCount = ?(MonthIdx <= 16, 18, ?(MonthIdx <= 18, 17, ?(MonthIdx = 19, 16, ?(MonthIdx = 20, 15, 8))));
				IsPaid = SetIdx <= PaidVGCount;
			Else
				PaidVGCount = ?(MonthIdx <= 16, 18, ?(MonthIdx <= 18, 17, ?(MonthIdx = 19, 16, ?(MonthIdx = 20, 15, 8))));
				IsPaid = (SetIdx - 18) <= (PaidCountInMonth - PaidVGCount);
			EndIf;
			If Not IsPaid Then Continue; EndIf;
			GlobalPTIndex = GlobalPTIndex + 1;
			PayDate = Invoice.Date + 86400 * 5;
			MinVal = (SetIdx * 7) % 60;
			If PayDate > Date(2026, 9, 30, 18, 0, 0) Then PayDate = Date(2026, 9, 30, 16, MinVal, 0); EndIf;
			YearSuffix = Mid(Invoice.Number, 4, 2);
			DocNumber = "PT-" + YearSuffix + "-" + DinhDangSo(GlobalPTIndex, 6);
			If ValueIsFilled(Documents.PhieuThuTienKhachHang.FindByNumber(DocNumber, PayDate)) Then
				Raise "SEED_NUMBER_COLLISION: " + DocNumber;
			EndIf;
			Doc = Documents.PhieuThuTienKhachHang.CreateDocument();
			Doc.Number = DocNumber;
			Doc.Date = PayDate;
			Doc.PhapNhan = Invoice.PhapNhan;
			Doc.NguoiDuyet = "cfo_giamdoc";
			Doc.DoiTac = Invoice.DoiTac;
			Doc.HopDong = Invoice.HopDong;
			Doc.ChungTuGoc = Rows.Ref;
			Doc.KhoanMucDongTien = RefCashCategory;
			Doc.NgayThu = BegOfDay(PayDate);
			Doc.DienGiai = "Thu tiền khách hàng theo Hóa đơn GTGT " + Invoice.Number;
			Doc.TaiKhoanTien = RefBank;
			Doc.TienTe = RefVND;
			Doc.TyGia = 1;
			Doc.SoTien = Invoice.TongTienThanhToan;
			Doc.SoTienNgoaiTe = 0;
			Doc.Write();
			If Doc.NguoiLap <> UserName() Then Raise "Receipt maker was not captured from the authenticated session."; EndIf;
			BatchCount = BatchCount + 1;
			If BatchCount % 50 = 0 Then CommitTransaction(); InTransaction = False; BeginTransaction(); InTransaction = True; EndIf;
		EndDo;
		CommitTransaction(); InTransaction = False;
	Except
		If InTransaction Then RollbackTransaction(); InTransaction = False; EndIf;
		Raise;
	EndTry;
EndProcedure

Procedure PostARSeedReceipts()
	Q = New Query("SELECT Ref FROM Document.PhieuThuTienKhachHang WHERE Number LIKE ""PT-%"" AND Posted = FALSE ORDER BY Date, Number");
	Rows = Q.Execute().Select();
	BatchCount = 0; InTransaction = False;
	Try
		BeginTransaction(); InTransaction = True;
		While Rows.Next() Do
			Doc = Rows.Ref.GetObject();
			If Doc.NguoiLap <> "ketoan_ar" Or Doc.NguoiDuyet <> UserName()
				Or Not ValueIsFilled(Doc.ChungTuGoc) Or Not Doc.ChungTuGoc.Posted Then
				Raise "Receipt is not a valid AR draft or its source invoice is not posted: " + Doc.Number;
			EndIf;
			Doc.Write(DocumentWriteMode.Posting);
			If Not Doc.Posted Then Raise "CFO failed to post receipt " + Doc.Number; EndIf;
			BatchCount = BatchCount + 1;
			If BatchCount % 50 = 0 Then CommitTransaction(); InTransaction = False; BeginTransaction(); InTransaction = True; EndIf;
		EndDo;
		CommitTransaction(); InTransaction = False;
	Except
		If InTransaction Then RollbackTransaction(); InTransaction = False; EndIf;
		Raise;
	EndTry;
EndProcedure

// Kiem tra so luong va tinh toan ven cua day chuyen chung tu AR da nap
Procedure KiemTraChungTuAR() Export
	CntBB = DemChungTuDaGhiSo("BienBanNghiemThuGiaiDoan");
	CntHD = DemChungTuDaGhiSo("HoaDonGTGTDauRa");
	CntPT = DemChungTuDaGhiSo("PhieuThuTienKhachHang");
	
	If CntBB >= 1200 And CntHD >= 1200 And CntPT >= 800 Then
		Msg = "AR_VERIFY_SUCCESS: BienBan=" + Format(CntBB, "NG=0") + ", HoaDon=" + Format(CntHD, "NG=0") + ", PhieuThu=" + Format(CntPT, "NG=0");
		WriteLogEvent("AR.Verify", EventLogLevel.Information,,, Msg);
	Else
		Msg = "AR_VERIFY_FAILED: BienBan=" + Format(CntBB, "NG=0") + ", HoaDon=" + Format(CntHD, "NG=0") + ", PhieuThu=" + Format(CntPT, "NG=0");
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
	If RefTK.Code <> "TK-TCB-VND" Then Raise "Bank account code was truncated; expected TK-TCB-VND."; EndIf;
	Return RefTK;
EndFunction

// Lay hoac khoi tao TaiKhoanTien Vietcombank USD
Function LayTaiKhoanTienVCB(RefUSD)
	RefTK = Catalogs.TaiKhoanTien.FindByCode("TK-VCB-USD");
	If Not ValueIsFilled(RefTK) Then
		RefTK = Catalogs.TaiKhoanTien.FindByCode("VCB-USD");
	EndIf;
	If Not ValueIsFilled(RefTK) Then
		ObjTK = Catalogs.TaiKhoanTien.CreateItem();
		ObjTK.Code = "TK-VCB-USD";
		ObjTK.Description = "Vietcombank USD - So Giao Dich";
		ObjTK.SoTaiKhoan = "0011004455667";
		ObjTK.NganHang = "Vietcombank - So Giao Dich";
		ObjTK.TienTe = RefUSD;
		ObjTK.Write();
		RefTK = ObjTK.Ref;
	EndIf;
	If RefTK.Code <> "TK-VCB-USD" Then Raise "Bank account code was truncated; expected TK-VCB-USD."; EndIf;
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
	
	PartnerRefs = New Array;
	ExpectedContractCodes = New Array;
	ExpectedCodeByPartner = New Map;
	For Each PartnerRow In TableDT Do
		ExpectedCode = "HD-" + TrimAll(PartnerRow.MaDoiTac) + "-2025";
		PartnerRefs.Add(PartnerRow.DoiTac);
		ExpectedContractCodes.Add(ExpectedCode);
		ExpectedCodeByPartner.Insert(PartnerRow.DoiTac, ExpectedCode);
	EndDo;
	
	ContractsByPartner = New Map;
	ContractsByCode = New Map;
	If PartnerRefs.Count() > 0 Then
		ContractsQuery = New Query;
		ContractsQuery.Text =
			"SELECT
			|	Contract.Ref AS Ref,
			|	Contract.ChuSoHuu AS ChuSoHuu,
			|	Contract.Code AS Code
			|FROM
			|	Catalog.HopDong AS Contract
			|WHERE
			|	Contract.ChuSoHuu IN (&Partners)
			|	OR Contract.Code IN (&ExpectedCodes)
			|ORDER BY
			|	Contract.Code";
		ContractsQuery.SetParameter("Partners", PartnerRefs);
		ContractsQuery.SetParameter("ExpectedCodes", ExpectedContractCodes);
		For Each ContractRow In ContractsQuery.Execute().Unload() Do
			If ContractsByPartner.Get(ContractRow.ChuSoHuu) = Undefined Then
				ContractsByPartner.Insert(ContractRow.ChuSoHuu, ContractRow.Ref);
			EndIf;
			If ContractsByCode.Get(ContractRow.Code) = Undefined Then
				ContractsByCode.Insert(ContractRow.Code, ContractRow.Ref);
			EndIf;
		EndDo;
	EndIf;
	
	Result = New Array;
	For Each RowDT In TableDT Do
		RefHD = ContractsByPartner.Get(RowDT.DoiTac);
		If RefHD = Undefined Then
			ExpectedCode = ExpectedCodeByPartner.Get(RowDT.DoiTac);
			RefHD = ContractsByCode.Get(ExpectedCode);
		EndIf;
		If RefHD = Undefined Then
			ObjHD = Catalogs.HopDong.CreateItem();
			ObjHD.Code = ExpectedCodeByPartner.Get(RowDT.DoiTac);
			ObjHD.Description = "Hợp đồng dịch vụ 2025 - " + RowDT.TenDoiTac;
			ObjHD.PhapNhan = RefPN_VSF;
			ObjHD.ChuSoHuu = RowDT.DoiTac;
			ObjHD.DongTienThanhToan = RefVND;
			ObjHD.HanThanhToanNgay = ?(RowDT.LaBenLienKet, 60, 30);
			ObjHD.Write();
			RefHD = ObjHD.Ref;
			ContractsByPartner.Insert(RowDT.DoiTac, RefHD);
			ContractsByCode.Insert(ExpectedCodeByPartner.Get(RowDT.DoiTac), RefHD);
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
// Bulk cleanup removed: restore a fresh UAT clone instead.

#EndRegion


