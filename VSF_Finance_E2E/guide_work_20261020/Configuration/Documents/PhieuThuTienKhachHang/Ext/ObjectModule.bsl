// Document: PhieuThuTienKhachHang
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL / Managed Application)
// Chuc nang: Thu tien thanh toan tu khach hang va doi tac noi bo Vingroup (Task 3.4):
//            - Sổ cái SoCaiKeToan:
//              + Nợ TK 1121 (Tien gui ngan hang VND) hoac TK 1122 (Tien gui Ngoai te)
//              + Có TK 1312 (Khach hang noi bo Vingroup) hoac TK 1311 (Khach hang ngoai)
//            - Sổ tích lũy CongNoPhaiThu:
//              + RecordType: Expense (Giam cong no phai thu theo ChungTuGoc nghiem thu)
//              + Dua so du no cua chung tu goc ve 0 khi thanh toan du (Tat toan toan phan).
//            - Sổ tích lũy DongTien:
//              + RecordType: Receipt (Tang so du tien tai khoan ngan hang / quy tien mat).

#Region EventHandlers

Procedure Filling(FillingData, FillingText, StandardProcessing)
	If Not ValueIsFilled(Date) Then
		Date = CurrentSessionDate();
	EndIf;
	If IsBlankString(NguoiLap) Then
		NguoiLap = UserName();
	EndIf;
	If Not ValueIsFilled(PhapNhan) Then
		PhapNhan = Catalogs.PhapNhan.FindByCode("PN-VSF");
	EndIf;
	If Not ValueIsFilled(NgayThu) Then
		NgayThu = BegOfDay(CurrentSessionDate());
	EndIf;
	If Not ValueIsFilled(TienTe) Then
		TienTe = Catalogs.TienTe.FindByCode("VND");
	EndIf;
	// Kế thừa dữ liệu từ Hóa đơn GTGT đầu ra hoặc Biên bản nghiệm thu (BasedOn)
	If TypeOf(FillingData) = Type("DocumentRef.HoaDonGTGTDauRa") Then
		ChungTuGoc = FillingData;
		PhapNhan = FillingData.PhapNhan;
		DoiTac = FillingData.DoiTac;
		HopDong = FillingData.HopDong;
		SoTien = FillingData.TongTienThanhToan;
		TienTe = FillingData.TienTe;
		SoTienNgoaiTe = FillingData.TongTienNgoaiTe;
		TyGia = 0;
		DienGiai = StrTemplate("Thu tiền theo Hóa đơn GTGT %1", FillingData.SoHoaDon);
	ElsIf TypeOf(FillingData) = Type("DocumentRef.BienBanNghiemThuGiaiDoan") Then
		ChungTuGoc = FillingData;
		PhapNhan = FillingData.PhapNhan;
		DoiTac = FillingData.DoiTac;
		HopDong = FillingData.HopDong;
		SoTien = FillingData.TongGiaTri;
		DienGiai = StrTemplate("Thu tiền theo Biên bản nghiệm thu %1", FillingData.Number);
	EndIf;
EndProcedure

Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	// [FIX B31] Huy ghi so phieu thu (lam tang lai cong no): chi KTT/CFO
	If WriteMode = DocumentWriteMode.UndoPosting Then
		QuanLyVongDoiChungTuServer.XuLyHuyGhiSo(ThisObject, Cancel);
		Return;
	EndIf;
	
	// [FIX B10/B28] Phieu thu lam giam cong no: Nguoi lap do he thong ghi nhan
	QuanLyVongDoiChungTuServer.GanNguoiLapKhiTaoMoi(ThisObject, "NguoiLap");
	
	PhanQuyenBaoMatServer.KiemTraQuyenChungTu(ThisObject, "Write", UserName());
	If WriteMode = DocumentWriteMode.Posting Then
		PhanQuyenBaoMatServer.KiemTraQuyenChungTu(ThisObject, "GhiSo", UserName());
	EndIf;
	If DataExchange.Load Then
		Return;
	EndIf;
	
	// Mac dinh NgayThu neu chua nhap
	If Not ValueIsFilled(NgayThu) Then
		NgayThu = BegOfDay(Date);
	EndIf;
	
	If Not ValueIsFilled(TienTe) Then
		If TypeOf(ChungTuGoc) = Type("DocumentRef.HoaDonGTGTDauRa") Then
			TienTe = ChungTuGoc.TienTe;
		Else
			TienTe = Catalogs.TienTe.FindByCode("VND");
		EndIf;
	EndIf;
	If TrimAll(Upper(String(TienTe.Code))) = "VND" Then
		TyGia = 1;
		SoTienNgoaiTe = 0;
	Else
		If TyGia <= 0 Then
			TyGia = LayTyGiaHachToanTheoNgay(TienTe, NgayThu);
		EndIf;
		If SoTienNgoaiTe <= 0 And SoTien > 0 And TyGia > 0 Then
			SoTienNgoaiTe = Round(SoTien / TyGia, 2);
		EndIf;
		If SoTien <= 0 And SoTienNgoaiTe > 0 And TyGia > 0 Then
			SoTien = Round(SoTienNgoaiTe * TyGia, 2);
		EndIf;
	EndIf;
EndProcedure

Procedure Posting(Cancel, Mode)
	// Rebuild owned movements even when the same object instance is reposted.
	RegisterRecords.CongNoPhaiThu.Clear();
	RegisterRecords.DongTien.Clear();
	RegisterRecords.SoCaiKeToan.Clear();
	// [FIX B10] Phieu thu giam cong no phai thu: bat buoc Maker-Checker (nguoi ghi so = Nguoi duyet, khac Nguoi lap)
	PhanQuyenBaoMatServer.KiemTraMakerChecker(NguoiLap, NguoiDuyet, UserName());
	// 1. Kiem tra tinh day du cua cac truong du lieu bat buoc
	If Not ValueIsFilled(PhapNhan) Or Not ValueIsFilled(DoiTac) Or Not ValueIsFilled(HopDong) Or Not ValueIsFilled(ChungTuGoc) Or Not ValueIsFilled(TaiKhoanTien) Or Not ValueIsFilled(TienTe) Then
		Cancel = True;
		Msg = New UserMessage;
		Msg.Text = NStr("vi = 'Thiếu thông tin bắt buộc: Pháp nhân, Đối tác, Hợp đồng, Tài khoản tiền hoặc Tiền tệ!'; en = 'Mandatory attributes missing: Legal Entity, Counterparty, Contract, Cash Account, or Currency!'");
		Msg.SetData(ThisObject);
		Msg.Message();
		Return;
	EndIf;
	
	IsForeignCurrency = TrimAll(Upper(String(TienTe.Code))) <> "VND";
	If IsForeignCurrency Then
		If TypeOf(ChungTuGoc) <> Type("DocumentRef.HoaDonGTGTDauRa")
			Or Not ValueIsFilled(ChungTuGoc.TienTe)
			Or ChungTuGoc.TienTe <> TienTe Then
			Raise "Foreign-currency receipt must settle an issued invoice in the same currency.";
		EndIf;
		If TyGia <= 0 Or SoTienNgoaiTe <= 0 Then
			Raise "Foreign-currency receipt requires a positive registered exchange rate and foreign amount.";
		EndIf;
		If (SoTien - Round(SoTienNgoaiTe * TyGia, 2)) > 1
			Or (SoTien - Round(SoTienNgoaiTe * TyGia, 2)) < -1 Then
			Raise "Foreign-currency receipt VND cash amount does not reconcile to foreign amount and receipt rate.";
		EndIf;
	ElsIf SoTienNgoaiTe <> 0 Then
		Raise "VND receipts must not carry a foreign-currency amount.";
	EndIf;

	// Kiem tra so tien thu phai > 0
	If SoTien <= 0 Then
		Cancel = True;
		Msg = New UserMessage;
		Msg.Text = NStr("vi = 'Số tiền thu phải lớn hơn 0!'; en = 'Payment amount must be greater than 0!'");
		Msg.SetData(ThisObject);
		Msg.Message();
		Return;
	EndIf;

	// Xoa record cu de tinh so du chinh xac khi repost
	RegisterRecords.CongNoPhaiThu.Write = True;
	RegisterRecords.CongNoPhaiThu.Clear();
	
	SoDuAR = QuanLyVongDoiChungTuServer.LaySoDuARTheoChungTu(PhapNhan, DoiTac, ChungTuGoc, New PointInTime(Date, Ref), Ref);
	SoTienGhiSoAR = SoTien;
	SoTienThucThu = SoTien;
	If IsForeignCurrency Then
		Q_FXBalance = New Query(
			"SELECT ISNULL(SUM(SoTienNgoaiTeBalance), 0) AS ForeignBalance
			|FROM AccumulationRegister.CongNoPhaiThu.Balance(,
			|   PhapNhan = &PN AND DoiTac = &Partner AND HopDong = &Contract AND ChungTuGoc = &Source)");
		Q_FXBalance.SetParameter("PN", PhapNhan);
		Q_FXBalance.SetParameter("Partner", DoiTac);
		Q_FXBalance.SetParameter("Contract", HopDong);
		Q_FXBalance.SetParameter("Source", ChungTuGoc);
		ForeignBalance = Q_FXBalance.Execute().Unload()[0].ForeignBalance;
		If SoTienNgoaiTe > ForeignBalance Then
			Cancel = True;
			Msg = New UserMessage;
			Msg.Text = NStr("vi = 'Số tiền ngoại tệ thu vượt quá dư nợ nguyên tệ còn lại của hóa đơn.'; en = 'Foreign receipt exceeds the remaining foreign-currency invoice balance.'");
			Msg.SetData(ThisObject);
			Msg.Message();
			Return;
		EndIf;
		If SoTienNgoaiTe >= ForeignBalance Then
			SoTienGhiSoAR = SoDuAR;
		Else
			SoTienGhiSoAR = Round(SoDuAR * SoTienNgoaiTe / ForeignBalance, 2);
		EndIf;
		SoTienThucThu = Round(SoTienNgoaiTe * TyGia, 2);
	ElsIf SoTien > SoDuAR Then
		Cancel = True;
		Msg = New UserMessage;
		Msg.Text = NStr("vi = 'Số tiền thu vượt quá số dư phải thu còn lại của chứng từ gốc!'; en = 'Receipt amount exceeds remaining AR balance of source document!'");
		Msg.SetData(ThisObject);
		Msg.Message();
		Return;
	EndIf;
	If Not ValueIsFilled(TaiKhoanTien.TienTe) Or TaiKhoanTien.TienTe <> TienTe Then
		Raise "Receipt currency must match the receiving bank account currency.";
	EndIf;
	
	// 2. Xac dinh Tai khoan No (Tien VND -> TK 1121; Ngoai te -> TK 1122)
	AccountDr = LayTaiKhoanTienGuiTheoTienTe(TienTe, SoTienNgoaiTe);
	
	// 3. Xac dinh Tai khoan Co (Noi bo Vingroup -> TK 1312; Ngoai tap doan -> TK 1311)
	AccountCr = LayTaiKhoanCongNoTheoDoiTac(DoiTac);
	
	// -------------------------------------------------------------------------
	// 4. Ghi Sổ Tích Lũy CongNoPhaiThu (AR Subledger)
	//    - Loai ghi so: Expense (Giam so du cong no phai thu)
	//    - ChungTuGoc: Tham chiếu BienBanNghiemThuGiaiDoan hoặc HoaDonGTGTDauRa để tất toán công nợ AR
	// -------------------------------------------------------------------------
	RegisterRecords.CongNoPhaiThu.Write = True;
	RecordAR = RegisterRecords.CongNoPhaiThu.Add();
	RecordAR.RecordType = AccumulationRecordType.Expense;
	RecordAR.Period = Date;
	RecordAR.PhapNhan = PhapNhan;
	RecordAR.DoiTac = DoiTac;
	RecordAR.HopDong = HopDong;
	RecordAR.ChungTuGoc = ChungTuGoc;
	RecordAR.SoTien = SoTienGhiSoAR;
	RecordAR.SoTienNgoaiTe = SoTienNgoaiTe;
	
	// -------------------------------------------------------------------------
	// 5. Ghi Sổ Tích Lũy DongTien (Cash Flow Subledger)
	//    - Loai ghi so: Receipt (Tang so du tien trong tai khoan ngan hang / quy)
	// -------------------------------------------------------------------------
	RegisterRecords.DongTien.Write = True;
	RecordCF = RegisterRecords.DongTien.Add();
	RecordCF.RecordType = AccumulationRecordType.Receipt;
	RecordCF.Period = Date;
	RecordCF.PhapNhan = PhapNhan;
	RecordCF.TaiKhoanTien = TaiKhoanTien;
	RecordCF.TienTe = TienTe;
	RecordCF.KhoanMucDongTien = KhoanMucDongTien;
	RecordCF.SoTien = SoTienThucThu;
	RecordCF.SoTienNgoaiTe = SoTienNgoaiTe;
	
	// -------------------------------------------------------------------------
	// 6. Ghi Sổ Cái Kế Toán SoCaiKeToan (General Ledger)
	//    - But toan kep: No TK 1121 (hoac 1122) / Co TK 1312 (hoac 1311)
	//    - ChungTuGoc = ChungTuGoc (BienBanNghiemThuGiaiDoan)
	// -------------------------------------------------------------------------
	RegisterRecords.SoCaiKeToan.Write = True;
	NoiDungDienGiai = DienGiai;
	If Not ValueIsFilled(NoiDungDienGiai) Then
		NoiDungDienGiai = StrTemplate("Thu tiền khách hàng %1 theo chứng từ %2", DoiTac, Number);
	EndIf;
	If Not IsForeignCurrency Then
		RecordGL = RegisterRecords.SoCaiKeToan.Add();
		RecordGL.Period = Date;
		RecordGL.AccountDr = AccountDr;
		RecordGL.AccountCr = AccountCr;
		RecordGL.PhapNhan = PhapNhan;
		RecordGL.TienTe = TienTe;
		RecordGL.ChungTuGoc = ChungTuGoc;
		RecordGL.TyGia = 1;
		RecordGL.SoTien = SoTienThucThu;
		RecordGL.DienGiai = Left(NoiDungDienGiai, 250);
	Else
		CurrencyBookRate = SoTienGhiSoAR / SoTienNgoaiTe;
		If SoTienThucThu >= SoTienGhiSoAR Then
			RecordGL = RegisterRecords.SoCaiKeToan.Add();
			RecordGL.Period = Date;
			RecordGL.AccountDr = AccountDr;
			RecordGL.AccountCr = AccountCr;
			RecordGL.PhapNhan = PhapNhan;
			RecordGL.TienTe = TienTe;
			RecordGL.ChungTuGoc = ChungTuGoc;
			RecordGL.TyGia = CurrencyBookRate;
			RecordGL.SoTien = SoTienGhiSoAR;
			RecordGL.SoTienNgoaiTe = SoTienNgoaiTe;
			RecordGL.DienGiai = Left(NoiDungDienGiai, 250);
			If SoTienThucThu > SoTienGhiSoAR Then
				FXGain = RegisterRecords.SoCaiKeToan.Add();
				FXGain.Period = Date;
				FXGain.AccountDr = AccountDr;
				FXGain.AccountCr = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("515");
				FXGain.PhapNhan = PhapNhan;
				FXGain.TienTe = Catalogs.TienTe.FindByCode("VND");
				FXGain.ChungTuGoc = ChungTuGoc;
				FXGain.TyGia = 1;
				FXGain.SoTien = SoTienThucThu - SoTienGhiSoAR;
				FXGain.DienGiai = StrTemplate("Lãi tỷ giá thực hiện thu tiền theo chứng từ %1", ChungTuGoc);
			EndIf;
		Else
			RecordGL = RegisterRecords.SoCaiKeToan.Add();
			RecordGL.Period = Date;
			RecordGL.AccountDr = AccountDr;
			RecordGL.AccountCr = AccountCr;
			RecordGL.PhapNhan = PhapNhan;
			RecordGL.TienTe = TienTe;
			RecordGL.ChungTuGoc = ChungTuGoc;
			RecordGL.TyGia = TyGia;
			RecordGL.SoTien = SoTienThucThu;
			RecordGL.SoTienNgoaiTe = SoTienNgoaiTe;
			RecordGL.DienGiai = Left(NoiDungDienGiai, 250);
			FXLoss = RegisterRecords.SoCaiKeToan.Add();
			FXLoss.Period = Date;
			FXLoss.AccountDr = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("635");
			FXLoss.AccountCr = AccountCr;
			FXLoss.PhapNhan = PhapNhan;
			FXLoss.TienTe = Catalogs.TienTe.FindByCode("VND");
			FXLoss.ChungTuGoc = ChungTuGoc;
			FXLoss.TyGia = 1;
			FXLoss.SoTien = SoTienGhiSoAR - SoTienThucThu;
			FXLoss.DienGiai = StrTemplate("Lỗ tỷ giá thực hiện thu tiền theo chứng từ %1", ChungTuGoc);
		EndIf;
	EndIf;
	
	// -------------------------------------------------------------------------
	// 7. Kiem tra Invariant can doi SoCai GL (Sum Dr = Sum Cr)
	// -------------------------------------------------------------------------
	Try
		EntriesGL = New Array;
		EntriesGL.Add(New Structure("AmountDr,AmountCr", SoTien, SoTien));
		QuanLyVongDoiChungTuServer.KiemTraCanDoiSoCai(EntriesGL);
	Except
		Cancel = True;
		// [FIX B03] Bao loi cho nguoi dung thay vi chi ghi log
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject, BriefErrorDescription(ErrorInfo()));
	EndTry;
EndProcedure

Procedure UndoPosting(Cancel)
	// Ghi nhan co che xoa tu dong AutoDeleteOnUnpost
	RegisterRecords.CongNoPhaiThu.Write = True;
	RegisterRecords.DongTien.Write = True;
	RegisterRecords.SoCaiKeToan.Write = True;
EndProcedure

#EndRegion

#Region PublicLogic

// Ham ho tro xac dinh tai khoan cong no theo tinh chat doi tac
Function LayTaiKhoanCongNoTheoDoiTac(Val DoiTacRef) Export
	If Not ValueIsFilled(DoiTacRef) Or TypeOf(DoiTacRef) <> Type("CatalogRef.DoiTac") Then
		Raise "Không thể xác định tài khoản công nợ: đối tác phải là tham chiếu Catalog.DoiTac hợp lệ.";
	EndIf;
	If DoiTacRef.LaBenLienKet
		Or DoiTacRef.LoaiDoiTac = Enums.LoaiDoiTac.NoiBoVingroup
		Or DoiTacRef.LoaiDoiTac = Enums.LoaiDoiTac.NoiBoTapDoan Then
		Return ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1312");
	EndIf;
	Return ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1311");
EndFunction

Function LayTyGiaHachToanTheoNgay(Val TienTeRef, Val RateDate)
	If TrimAll(Upper(String(TienTeRef.Code))) = "VND" Then
		Return 1;
	EndIf;
	Query = New Query(
		"SELECT TOP 1 Rates.TyGiaHachToan AS TyGia
		|FROM InformationRegister.TyGiaHoiDoai.SliceLast(&RateDate, TienTe = &TienTe) AS Rates");
	Query.SetParameter("RateDate", RateDate);
	Query.SetParameter("TienTe", TienTeRef);
	Rows = Query.Execute().Unload();
	If Rows.Count() = 0 Or Rows[0].TyGia <= 0 Then
		Raise StrTemplate("No accounting exchange rate is configured for %1 on %2.", TienTeRef.Code, RateDate);
	EndIf;
	Return Rows[0].TyGia;
EndFunction

// Ham ho tro xac dinh tai khoan tien gui theo loai tien te
Function LayTaiKhoanTienGuiTheoTienTe(Val TienTeRef, Val SoTienNgoaiTeVal = 0) Export
	MaTienTe = "";
	If ValueIsFilled(TienTeRef) Then
		If TypeOf(TienTeRef) = Type("CatalogRef.TienTe") Then
			MaTienTe = TrimAll(Upper(TienTeRef.Code));
		ElsIf TypeOf(TienTeRef) = Type("String") Then
			MaTienTe = TrimAll(Upper(TienTeRef));
		Else
			Raise "Không thể xác định tài khoản tiền gửi: loại tiền phải là CatalogRef.TienTe hoặc mã tiền tệ.";
		EndIf;
	EndIf;
	If SoTienNgoaiTeVal > 0 Or (MaTienTe <> "" And MaTienTe <> "VND") Then
		Return ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1122");
	EndIf;
	If MaTienTe = "" Then
		Raise "Không thể xác định tài khoản tiền gửi: thiếu tiền tệ và số tiền ngoại tệ.";
	EndIf;
	Return ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1121");
EndFunction

#EndRegion
