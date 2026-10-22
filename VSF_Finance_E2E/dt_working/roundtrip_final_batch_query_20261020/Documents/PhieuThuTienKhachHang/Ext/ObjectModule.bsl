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
	If TyGia = 0 Then
		TyGia = 1;
	EndIf;
	
	// Kế thừa dữ liệu từ Hóa đơn GTGT đầu ra hoặc Biên bản nghiệm thu (BasedOn)
	If TypeOf(FillingData) = Type("DocumentRef.HoaDonGTGTDauRa") Then
		ChungTuGoc = FillingData;
		PhapNhan = FillingData.PhapNhan;
		DoiTac = FillingData.DoiTac;
		HopDong = FillingData.HopDong;
		SoTien = FillingData.TongTienThanhToan;
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
	
	// Mac dinh TyGia quy doi
	If TyGia <= 0 Then
		TyGia = 1;
	EndIf;
	
	// Tu dong tinh quy doi VND neu co SoTienNgoaiTe ma SoTien = 0
	If SoTien = 0 And SoTienNgoaiTe > 0 And TyGia > 0 Then
		SoTien = Round(SoTienNgoaiTe * TyGia, 2);
	EndIf;
	
	// Tu dong tinh SoTienNgoaiTe neu co SoTien ma chua co SoTienNgoaiTe voi ty gia > 1
	If SoTienNgoaiTe = 0 And SoTien > 0 And TyGia > 1 Then
		SoTienNgoaiTe = Round(SoTien / TyGia, 2);
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
	If SoTien > SoDuAR Then
		Cancel = True;
		Msg = New UserMessage;
		Msg.Text = NStr("vi = 'Số tiền thu vượt quá số dư phải thu còn lại của chứng từ gốc!'; en = 'Receipt amount exceeds remaining AR balance of source document!'");
		Msg.SetData(ThisObject);
		Msg.Message();
		Return;
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
	RecordAR.SoTien = SoTien;
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
	RecordCF.SoTien = SoTien;
	RecordCF.SoTienNgoaiTe = SoTienNgoaiTe;
	
	// -------------------------------------------------------------------------
	// 6. Ghi Sổ Cái Kế Toán SoCaiKeToan (General Ledger)
	//    - But toan kep: No TK 1121 (hoac 1122) / Co TK 1312 (hoac 1311)
	//    - ChungTuGoc = ChungTuGoc (BienBanNghiemThuGiaiDoan)
	// -------------------------------------------------------------------------
	RegisterRecords.SoCaiKeToan.Write = True;
	RecordGL = RegisterRecords.SoCaiKeToan.Add();
	RecordGL.Period = Date;
	RecordGL.AccountDr = AccountDr;
	RecordGL.AccountCr = AccountCr;
	RecordGL.PhapNhan = PhapNhan;
	RecordGL.TienTe = TienTe;
	RecordGL.ChungTuGoc = ChungTuGoc;
	RecordGL.TyGia = ?(TyGia > 0, TyGia, 1);
	RecordGL.SoTien = SoTien;
	If SoTienNgoaiTe > 0 Then
		RecordGL.SoTienNgoaiTe = SoTienNgoaiTe;
	EndIf;
	
	NoiDungDienGiai = DienGiai;
	If Not ValueIsFilled(NoiDungDienGiai) Then
		NoiDungDienGiai = StrTemplate("Thu tiền khách hàng %1 theo chứng từ %2", DoiTac, Number);
	EndIf;
	RecordGL.DienGiai = Left(NoiDungDienGiai, 250);
	
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
