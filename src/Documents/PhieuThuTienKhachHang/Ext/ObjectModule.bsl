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

Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	If DataExchange.Load Then
		Return;
	EndIf;
	
	// Kiem tra phan quyen SoD khi ghi so
	If WriteMode = DocumentWriteMode.Posting Then
		PhanQuyenBaoMatServer.KiemTraQuyenChungTu(ThisObject, "GhiSo");
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
	
	SoDuAR = QuanLyVongDoiChungTuServer.LaySoDuARTheoChungTu(PhapNhan, DoiTac, ChungTuGoc, New PointInTime(Date, Ref));
	If SoTien > SoDuAR Then
		Cancel = True;
		Msg = New UserMessage;
		Msg.Text = NStr("vi = 'Số tiền thu vượt quá số dư phải thu còn lại của chứng từ gốc!'; en = 'Receipt amount exceeds remaining AR balance of source document!'");
		Msg.SetData(ThisObject);
		Msg.Message();
		Return;
	EndIf;
	
	// 2. Xac dinh Tai khoan No (Tien VND -> TK 1121; Ngoai te -> TK 1122)
	IsNgoaiTe = False;
	If ValueIsFilled(TienTe) Then
		Try
			If TrimAll(Upper(TienTe.Code)) <> "VND" Then
				IsNgoaiTe = True;
			EndIf;
		Except
			If TrimAll(Upper(String(TienTe))) <> "VND" And TrimAll(String(TienTe)) <> "" Then
				IsNgoaiTe = True;
			EndIf;
		EndTry;
	EndIf;
	
	If IsNgoaiTe Or SoTienNgoaiTe > 0 Then
		AccountDr = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1122"); // Tien gui ngan hang Ngoai te
	Else
		AccountDr = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1121"); // Tien gui ngan hang VND
	EndIf;
	
	// 3. Xac dinh Tai khoan Co (Noi bo Vingroup -> TK 1312; Ngoai tap doan -> TK 1311)
	IsNoiBo = False;
	If ValueIsFilled(DoiTac) Then
		Try
			If DoiTac.LaBenLienKet Then
				IsNoiBo = True;
			ElsIf DoiTac.LoaiDoiTac = Enums.LoaiDoiTac.NoiBoVingroup Or DoiTac.LoaiDoiTac = Enums.LoaiDoiTac.NoiBoTapDoan Then
				IsNoiBo = True;
			EndIf;
		Except
		EndTry;
	EndIf;
	
	If IsNoiBo Then
		AccountCr = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1312"); // Phai thu khach hang noi bo Vingroup
	Else
		AccountCr = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1311"); // Phai thu khach hang ngoai
	EndIf;
	
	// -------------------------------------------------------------------------
	// 4. Ghi Sổ Tích Lũy CongNoPhaiThu (AR Subledger)
	//    - Loai ghi so: Expense (Giam so du cong no phai thu)
	//    - ChungTuGoc: Gan tham chieu BienBanNghiemThuGiaiDoan de tat toan theo dot
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
		WriteLogEvent("Posting.PhieuThuTienKhachHang", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
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
	If ValueIsFilled(DoiTacRef) Then
		Try
			If DoiTacRef.LaBenLienKet Then
				Return ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1312");
			ElsIf DoiTacRef.LoaiDoiTac = Enums.LoaiDoiTac.NoiBoVingroup Or DoiTacRef.LoaiDoiTac = Enums.LoaiDoiTac.NoiBoTapDoan Then
				Return ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1312");
			EndIf;
		Except
		EndTry;
	EndIf;
	Return ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1311");
EndFunction

// Ham ho tro xac dinh tai khoan tien gui theo loai tien te
Function LayTaiKhoanTienGuiTheoTienTe(Val TienTeRef, Val SoTienNgoaiTeVal = 0) Export
	If ValueIsFilled(TienTeRef) Then
		Try
			If TrimAll(Upper(TienTeRef.Code)) <> "VND" Then
				Return ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1122");
			EndIf;
		Except
			If TrimAll(Upper(String(TienTeRef))) <> "VND" And TrimAll(String(TienTeRef)) <> "" Then
				Return ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1122");
			EndIf;
		EndTry;
	EndIf;
	If SoTienNgoaiTeVal > 0 Then
		Return ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1122");
	EndIf;
	Return ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1121");
EndFunction

#EndRegion
