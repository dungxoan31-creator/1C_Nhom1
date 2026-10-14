// Document: BaoCoNganHang
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Xu ly su kien ghi so (Posting) Bao co ngan hang, tu dong giam AR va tang DongTien (Task 5.1).

#Region EventHandlers

Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	QuanLyVongDoiChungTuServer.KiemTraTrangThaiVaQuyen(ThisObject, WriteMode, PostingMode, Cancel);
	QuanLyVongDoiChungTuServer.KiemTraChuyenTrangThai(ThisObject, TrangThai, UserName(), WriteMode);
	
	If Not ValueIsFilled(NgayGiaoDich) Then
		NgayGiaoDich = Date;
	EndIf;
	
	If Not ValueIsFilled(PhapNhan) Then
		PhapNhan = Catalogs.PhapNhan.FindByCode("PN-VSF");
	EndIf;
	
	If Not ValueIsFilled(TaiKhoanTien) Then
		TaiKhoanTien = Catalogs.TaiKhoanTien.FindByCode("TK-TCB-VND");
	EndIf;
EndProcedure

Procedure Posting(Cancel, Mode)
	PhanQuyenBaoMatServer.KiemTraMakerChecker(NguoiLap, NguoiDuyet, UserName());
	PhanQuyenBaoMatServer.KiemTraQuyenChungTu(ThisObject, "GhiSo", UserName());
	QuanLyVongDoiChungTuServer.KiemTraChuyenTrangThai(ThisObject, TrangThai, UserName(), DocumentWriteMode.Posting);
	
	If TrangThai <> "DaDoiSoat" Or Not ValueIsFilled(DoiTacKhop) Or Not ValueIsFilled(ChungTuKhop) Then
		Cancel = True;
		Msg = New UserMessage;
		Msg.Text = NStr("vi = 'Chưa đối soát được giao dịch với đối tác và chứng từ AR!'; en = 'Transaction not yet reconciled with counterparty and AR document!'");
		Msg.SetData(ThisObject);
		Msg.Message();
		Return;
	EndIf;

	If Not ChungTuKhop.Posted Then
		Cancel = True;
		Msg = New UserMessage;
		Msg.Text = NStr("vi = 'Chứng từ AR được đối soát chưa được ghi sổ!'; en = 'Reconciled AR document is not yet posted!'");
		Msg.SetData(ThisObject);
		Msg.Message();
		Return;
	EndIf;

	// Chi ghi so khi da xac dinh doi tac va du dieu kien ghi so
	If SoTien <= 0 Then
		Cancel = True;
		Msg = New UserMessage;
		Msg.Text = NStr("vi = 'Số tiền báo có phải lớn hơn 0!'; en = 'Credit advice amount must be greater than 0!'");
		Msg.SetData(ThisObject);
		Msg.Field = "SoTien";
		Msg.Message();
		Return;
	EndIf;
	
	// Xoa record set cu truoc khi check so du
	RegisterRecords.CongNoPhaiThu.Write = True;
	RegisterRecords.CongNoPhaiThu.Clear();
	
	SoDuAR = QuanLyVongDoiChungTuServer.LaySoDuARTheoChungTu(PhapNhan, DoiTacKhop, ChungTuKhop, New PointInTime(Date, Ref));
	If SoTien > SoDuAR Then
		Cancel = True;
		Msg = New UserMessage;
		Msg.Text = NStr("vi = 'Số tiền báo có vượt quá số dư phải thu còn lại của chứng từ!'; en = 'Credit amount exceeds remaining AR balance of source document!'");
		Msg.SetData(ThisObject);
		Msg.Field = "SoTien";
		Msg.Message();
		Return;
	EndIf;

	// 1. Xac dinh tai khoan ke toan
	LaNoiBo = ?(ValueIsFilled(DoiTacKhop), DoiTacKhop.LaBenLienKet, False);
	MaTKCongNo = ?(LaNoiBo, "1312", "1311");
	TKCongNo = ChartsOfAccounts.HeThongTaiKhoan.FindByCode(MaTKCongNo);
	TKTien = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1121");
	TienTeVND = Catalogs.TienTe.FindByCode("VND");
	
	HopDongKhop = Catalogs.HopDong.EmptyRef();
	If ValueIsFilled(ChungTuKhop) Then
		Try
			HopDongKhop = ChungTuKhop.HopDong;
		Except
		EndTry;
	EndIf;
	
	// 2. Ghi So tich luy CongNoPhaiThu (Expense - Giam AR)
	RegisterRecords.CongNoPhaiThu.Write = True;
	RecordAR = RegisterRecords.CongNoPhaiThu.Add();
	RecordAR.RecordType = AccumulationRecordType.Expense;
	RecordAR.Period = Date;
	RecordAR.PhapNhan = PhapNhan;
	RecordAR.DoiTac = DoiTacKhop;
	RecordAR.HopDong = HopDongKhop;
	RecordAR.ChungTuGoc = ChungTuKhop;
	RecordAR.SoTien = SoTien;
	RecordAR.SoTienNgoaiTe = 0;
	
	// 3. Ghi So tich luy DongTien (Receipt - Tang tien ngan hang)
	RegisterRecords.DongTien.Write = True;
	RecordDT = RegisterRecords.DongTien.Add();
	RecordDT.RecordType = AccumulationRecordType.Receipt;
	RecordDT.Period = Date;
	RecordDT.PhapNhan = PhapNhan;
	RecordDT.TaiKhoanTien = TaiKhoanTien;
	RecordDT.KhoanMucDongTien = Catalogs.KhoanMucDongTien.FindByCode("KM-01");
	RecordDT.TienTe = TienTeVND;
	RecordDT.SoTien = SoTien;
	RecordDT.SoTienNgoaiTe = 0;
	
	// 4. Ghi So cai SoCaiKeToan (No 1121 / Co 1311 hoac 1312)
	RegisterRecords.SoCaiKeToan.Write = True;
	Row1 = RegisterRecords.SoCaiKeToan.Add();
	Row1.Period = Date;
	Row1.AccountDr = TKTien;
	Row1.AccountCr = TKCongNo;
	Row1.SoTien = SoTien;
	Row1.DienGiai = StrTemplate("Báo có ngân hàng tiền về - Mã GD %1", MaGiaoDichNganHang);
	Row1.PhapNhan = PhapNhan;
	Row1.TienTe = TienTeVND;
	Row1.ChungTuGoc = ChungTuKhop;
	Row1.TaiKhoanTienNo = TaiKhoanTien;
	Row1.DoiTacCo = DoiTacKhop;
	Row1.HopDongCo = HopDongKhop;
	Row1.ChungTuGocCo = ChungTuKhop;
	Row1.TyGia = 1;
	
	Try
		EntriesGL = New Array;
		EntriesGL.Add(New Structure("AmountDr,AmountCr", SoTien, SoTien));
		QuanLyVongDoiChungTuServer.KiemTraCanDoiSoCai(EntriesGL);
	Except
		Cancel = True;
		WriteLogEvent("Posting.BaoCoNganHang", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
	EndTry;
EndProcedure

#EndRegion
