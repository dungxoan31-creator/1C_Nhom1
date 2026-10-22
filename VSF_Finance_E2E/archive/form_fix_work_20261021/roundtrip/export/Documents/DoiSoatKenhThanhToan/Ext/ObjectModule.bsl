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
	If Not ValueIsFilled(TienTe) Then
		TienTe = Catalogs.TienTe.FindByCode("VND");
	EndIf;
	If IsBlankString(KenhThanhToan) Then
		KenhThanhToan = "VNPAY";
	EndIf;
EndProcedure

Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	If WriteMode = DocumentWriteMode.UndoPosting Then
		PhanQuyenBaoMatServer.KiemTraQuyenChungTu(ThisObject, "HuyGhiSo", UserName());
		Return;
	EndIf;
	If DataExchange.Load Then
		Return;
	EndIf;
	If IsBlankString(NguoiLap) Then
		NguoiLap = UserName();
	EndIf;
	If WriteMode = DocumentWriteMode.Posting Then
		PhanQuyenBaoMatServer.KiemTraQuyenChungTu(ThisObject, "GhiSo", UserName());
	Else
		PhanQuyenBaoMatServer.KiemTraQuyenChungTu(ThisObject, "Write", UserName());
	EndIf;
EndProcedure

Procedure Posting(Cancel, Mode)
	RegisterRecords.DongTien.Clear();
	RegisterRecords.SoCaiKeToan.Clear();
	If Not ValueIsFilled(PhapNhan) Or Not ValueIsFilled(DoiTacTrungGian)
		Or Not ValueIsFilled(TaiKhoanTien) Or Not ValueIsFilled(KhoanMucDongTien) Or Not ValueIsFilled(TienTe) Then
		TuChoiGhiSo(Cancel, "Thiếu Pháp nhân, đơn vị trung gian, tài khoản tiền, khoản mục dòng tiền hoặc tiền tệ.");
		Return;
	EndIf;
	NormalizedChannel = Upper(TrimAll(KenhThanhToan));
	If NormalizedChannel <> "VNPAY" And NormalizedChannel <> "ONEPAY" Then
		TuChoiGhiSo(Cancel, "Kênh thanh toán phải là VNPAY hoặc OnePay.");
		Return;
	EndIf;
	If TongTienGiaoDich <= 0 Or TongPhi < 0 Or TongTienThucNhan <= 0 Then
		TuChoiGhiSo(Cancel, "Tổng giao dịch và tiền thực nhận phải lớn hơn 0; phí không được âm.");
		Return;
	EndIf;
	If Round(TongTienGiaoDich, 2) <> Round(TongTienThucNhan + TongPhi, 2) Then
		TuChoiGhiSo(Cancel, StrTemplate("Đối soát không cân: Gross %1 phải bằng Net %2 cộng Fee %3.", TongTienGiaoDich, TongTienThucNhan, TongPhi));
		Return;
	EndIf;
	If Upper(TrimAll(TienTe.Code)) <> "VND" Or TaiKhoanTien.TienTe <> TienTe Then
		TuChoiGhiSo(Cancel, "Đối soát hiện chỉ hỗ trợ tài khoản ngân hàng VND cùng tiền tệ chứng từ.");
		Return;
	EndIf;
	If KhoanMucDongTien.LoaiDongTien <> "Thu" Then
		TuChoiGhiSo(Cancel, "Khoản mục dòng tiền phải thuộc loại Thu.");
		Return;
	EndIf;

	LockObject = New DataLock;
	CashLock = LockObject.Add("AccumulationRegister.DongTien");
	CashLock.SetValue("PhapNhan", PhapNhan);
	CashLock.SetValue("TaiKhoanTien", TaiKhoanTien);
	CashLock.SetValue("TienTe", TienTe);
	CashLock.SetValue("KhoanMucDongTien", KhoanMucDongTien);
	LockObject.Lock();

	AccountCash = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1121");
	AccountFee = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("6427");
	AccountClearing = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1388");
	If Not ValueIsFilled(AccountCash) Or Not ValueIsFilled(AccountFee) Or Not ValueIsFilled(AccountClearing) Then
		TuChoiGhiSo(Cancel, "Thiếu tài khoản kế toán 1121, 6427 hoặc 1388.");
		Return;
	EndIf;

	RegisterRecords.DongTien.LockForUpdate = True;
	RegisterRecords.DongTien.Write = True;
	RegisterRecords.SoCaiKeToan.LockForUpdate = True;
	RegisterRecords.SoCaiKeToan.Write = True;
	CashMovement = RegisterRecords.DongTien.Add();
	CashMovement.RecordType = AccumulationRecordType.Receipt;
	CashMovement.Period = Date;
	CashMovement.PhapNhan = PhapNhan;
	CashMovement.TaiKhoanTien = TaiKhoanTien;
	CashMovement.TienTe = TienTe;
	CashMovement.KhoanMucDongTien = KhoanMucDongTien;
	CashMovement.SoTien = TongTienThucNhan;
	CashMovement.SoTienNgoaiTe = 0;

	NetEntry = RegisterRecords.SoCaiKeToan.Add();
	NetEntry.Period = Date;
	NetEntry.AccountDr = AccountCash;
	NetEntry.AccountCr = AccountClearing;
	NetEntry.PhapNhan = PhapNhan;
	NetEntry.TienTe = TienTe;
	NetEntry.SoTien = TongTienThucNhan;
	NetEntry.SoTienNgoaiTe = 0;
	NetEntry.TyGia = 1;
	NetEntry.ChungTuGoc = Ref;
	NetEntry.TaiKhoanTien = TaiKhoanTien;
	NetEntry.TaiKhoanTienNo = TaiKhoanTien;
	NetEntry.DoiTacCo = DoiTacTrungGian;
	NetEntry.ChungTuGocCo = Ref;
	NetEntry.DienGiai = Left(StrTemplate("%1 - tiền thực nhận qua %2", DienGiai, KenhThanhToan), 250);

	If TongPhi > 0 Then
		FeeEntry = RegisterRecords.SoCaiKeToan.Add();
		FeeEntry.Period = Date;
		FeeEntry.AccountDr = AccountFee;
		FeeEntry.AccountCr = AccountClearing;
		FeeEntry.PhapNhan = PhapNhan;
		FeeEntry.TienTe = TienTe;
		FeeEntry.SoTien = TongPhi;
		FeeEntry.SoTienNgoaiTe = 0;
		FeeEntry.TyGia = 1;
		FeeEntry.ChungTuGoc = Ref;
		FeeEntry.DoiTacCo = DoiTacTrungGian;
		FeeEntry.ChungTuGocCo = Ref;
		FeeEntry.DienGiai = Left(StrTemplate("Phí kênh thanh toán %1", KenhThanhToan), 250);
	EndIf;

	Try
		QuanLyVongDoiChungTuServer.KiemTraCanDoiSoCai(RegisterRecords.SoCaiKeToan);
	Except
		Cancel = True;
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject, BriefErrorDescription(ErrorInfo()));
		Return;
	EndTry;
	NguoiDuyet = UserName();
	WriteLogEvent("PaymentReconciliation.Post", EventLogLevel.Information,,, StrTemplate("%1 ghi nhận %2: Gross=%3, Fee=%4, Net=%5.", UserName(), KenhThanhToan, TongTienGiaoDich, TongPhi, TongTienThucNhan));
EndProcedure

Procedure UndoPosting(Cancel)
	RegisterRecords.DongTien.Write = True;
	RegisterRecords.SoCaiKeToan.Write = True;
	WriteLogEvent("PaymentReconciliation.UndoPosting", EventLogLevel.Warning,,, StrTemplate("%1 hủy ghi sổ đối soát %2.", UserName(), Number));
EndProcedure

#EndRegion

#Region InternalFunctions

Procedure TuChoiGhiSo(Cancel, Val NoiDung)
	Cancel = True;
	Msg = New UserMessage;
	Msg.Text = NoiDung;
	Msg.SetData(ThisObject);
	Msg.Message();
EndProcedure

#EndRegion
