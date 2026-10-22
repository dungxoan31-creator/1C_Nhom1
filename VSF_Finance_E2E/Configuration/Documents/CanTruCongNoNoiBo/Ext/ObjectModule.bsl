#Region EventHandlers

Procedure Filling(FillingData, FillingText, StandardProcessing)
	If Not ValueIsFilled(Date) Then
		Date = CurrentSessionDate();
	EndIf;
	If IsBlankString(NguoiLap) Then
		NguoiLap = UserName();
	EndIf;
	If Not ValueIsFilled(PhapNhan) Then
		PhapNhan = QuanLyVongDoiChungTuServer.LayPhapNhanMacDinhTheoChiNhanhHienHanh();
	EndIf;
EndProcedure

Procedure ValidateRequiredFieldsForWrite(Cancel)
	If Not ValueIsFilled(PhapNhan) Then
		Cancel = True;
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject,
			NStr("vi = 'Thiếu thông tin bắt buộc: Pháp nhân.'; en = 'Required information is missing: Legal entity.'"), "PhapNhan");
		Return;
	EndIf;
	If Not ValueIsFilled(DoiTac) Then
		Cancel = True;
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject,
			NStr("vi = 'Thiếu thông tin bắt buộc: Đối tác.'; en = 'Required information is missing: Counterparty.'"), "DoiTac");
		Return;
	EndIf;
	If Not ValueIsFilled(ChungTuAR) Then
		Cancel = True;
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject,
			NStr("vi = 'Thiếu thông tin bắt buộc: Chứng từ công nợ AR.'; en = 'Required information is missing: AR source document.'"), "ChungTuAR");
		Return;
	EndIf;
	If Not ValueIsFilled(ChungTuAP) Then
		Cancel = True;
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject,
			NStr("vi = 'Thiếu thông tin bắt buộc: Chứng từ công nợ AP.'; en = 'Required information is missing: AP source document.'"), "ChungTuAP");
		Return;
	EndIf;
	If SoTien <= 0 Then
		Cancel = True;
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject,
			NStr("vi = 'Số tiền cấn trừ phải lớn hơn 0.'; en = 'The netting amount must be greater than zero.'"), "SoTien");
		Return;
	EndIf;
	If TypeOf(ChungTuAP) <> Type("DocumentRef.HoaDonNhaCungCap") Then
		Cancel = True;
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject,
			NStr("vi = 'Chứng từ AP phải là hóa đơn nhà cung cấp.'; en = 'The AP source must be a supplier invoice.'"), "ChungTuAP");
		Return;
	EndIf;
	If TypeOf(ChungTuAR) <> Type("DocumentRef.BienBanNghiemThuGiaiDoan")
		And TypeOf(ChungTuAR) <> Type("DocumentRef.HoaDonGTGTDauRa") Then
		Cancel = True;
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject,
			NStr("vi = 'Chứng từ AR phải là biên bản nghiệm thu hoặc hóa đơn GTGT đầu ra.'; en = 'The AR source must be an acceptance certificate or an output VAT invoice.'"), "ChungTuAR");
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
	If WriteMode = DocumentWriteMode.Write Then
		ValidateRequiredFieldsForWrite(Cancel);
	EndIf;
EndProcedure

Procedure Posting(Cancel, Mode)
	RegisterRecords.CongNoPhaiThu.Clear();
	RegisterRecords.CongNoPhaiTra.Clear();
	RegisterRecords.SoCaiKeToan.Clear();

	If Not ValueIsFilled(PhapNhan) Or Not ValueIsFilled(DoiTac)
		Or Not ValueIsFilled(ChungTuAR) Or Not ValueIsFilled(ChungTuAP) Then
		TuChoiGhiSo(Cancel, "Thiếu Pháp nhân, Đối tác hoặc chứng từ công nợ AR/AP.");
		Return;
	EndIf;
	If SoTien <= 0 Then
		TuChoiGhiSo(Cancel, "Số tiền cấn trừ phải lớn hơn 0.");
		Return;
	EndIf;
	If Not DoiTac.LaBenLienKet Then
		TuChoiGhiSo(Cancel, "Cấn trừ nội bộ chỉ áp dụng cho đối tác liên kết.");
		Return;
	EndIf;
	If Not ChungTuAR.Posted Or ChungTuAR.DeletionMark
		Or Not ChungTuAP.Posted Or ChungTuAP.DeletionMark Then
		TuChoiGhiSo(Cancel, "Chứng từ AR và AP phải đang ghi sổ và chưa đánh dấu xóa.");
		Return;
	EndIf;
	If TypeOf(ChungTuAP) <> Type("DocumentRef.HoaDonNhaCungCap") Then
		TuChoiGhiSo(Cancel, "Chứng từ AP phải là Hóa đơn nhà cung cấp đã ghi sổ.");
		Return;
	EndIf;
	If TypeOf(ChungTuAR) <> Type("DocumentRef.BienBanNghiemThuGiaiDoan")
		And TypeOf(ChungTuAR) <> Type("DocumentRef.HoaDonGTGTDauRa") Then
		TuChoiGhiSo(Cancel, "Chứng từ AR phải là Biên bản nghiệm thu hoặc Hóa đơn GTGT đầu ra.");
		Return;
	EndIf;

	ARSource = ChungTuAR.GetObject();
	APSource = ChungTuAP.GetObject();
	If ARSource.PhapNhan <> PhapNhan Or ARSource.DoiTac <> DoiTac
		Or APSource.PhapNhan <> PhapNhan Or APSource.DoiTac <> DoiTac Then
		TuChoiGhiSo(Cancel, "Pháp nhân và đối tác trên hai chứng từ gốc phải trùng với chứng từ cấn trừ.");
		Return;
	EndIf;
	If Not ValueIsFilled(ARSource.HopDong) Or Not ValueIsFilled(APSource.HopDong) Then
		TuChoiGhiSo(Cancel, "Hai chứng từ gốc phải có hợp đồng công nợ.");
		Return;
	EndIf;
	If Not ValueIsFilled(APSource.TienTe) Then
		TuChoiGhiSo(Cancel, "Hóa đơn AP thiếu tiền tệ.");
		Return;
	EndIf;
	If Upper(TrimAll(APSource.TienTe.Code)) <> "VND" Then
		TuChoiGhiSo(Cancel, "Cấn trừ hiện chỉ hỗ trợ công nợ VND; khoản ngoại tệ cần xử lý chênh lệch tỷ giá riêng.");
		Return;
	EndIf;

	// Lock both exact open-item keys in a stable AR-then-AP order before checking balances.
	LockObject = New DataLock;
	ARLock = LockObject.Add("AccumulationRegister.CongNoPhaiThu");
	ARLock.SetValue("PhapNhan", PhapNhan);
	ARLock.SetValue("DoiTac", DoiTac);
	ARLock.SetValue("HopDong", ARSource.HopDong);
	ARLock.SetValue("ChungTuGoc", ChungTuAR);
	APLock = LockObject.Add("AccumulationRegister.CongNoPhaiTra");
	APLock.SetValue("PhapNhan", PhapNhan);
	APLock.SetValue("DoiTac", DoiTac);
	APLock.SetValue("HopDong", APSource.HopDong);
	APLock.SetValue("ChungTuGoc", ChungTuAP);
	LockObject.Lock();

	AtPoint = New PointInTime(Date, Ref);
	ARBalance = LaySoDuAR(PhapNhan, DoiTac, ARSource.HopDong, ChungTuAR, AtPoint);
	APBalance = LaySoDuAP(PhapNhan, DoiTac, APSource.HopDong, ChungTuAP, AtPoint);
	MaxNetting = ARBalance;
	If APBalance < MaxNetting Then
		MaxNetting = APBalance;
	EndIf;
	If MaxNetting <= 0 Or SoTien > MaxNetting Then
		TuChoiGhiSo(Cancel, StrTemplate("Số tiền cấn trừ %1 vượt quá số dư nhỏ nhất AR/AP là %2 VND.", SoTien, MaxNetting));
		Return;
	EndIf;

	AccountDr = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("3312");
	AccountCr = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1312");
	VND = Catalogs.TienTe.FindByCode("VND");
	If Not ValueIsFilled(AccountDr) Or Not ValueIsFilled(AccountCr) Or Not ValueIsFilled(VND) Then
		TuChoiGhiSo(Cancel, "Thiếu tài khoản 3312, 1312 hoặc tiền tệ VND trong master data.");
		Return;
	EndIf;

	RegisterRecords.CongNoPhaiThu.LockForUpdate = True;
	RegisterRecords.CongNoPhaiThu.Write = True;
	RegisterRecords.CongNoPhaiTra.LockForUpdate = True;
	RegisterRecords.CongNoPhaiTra.Write = True;
	RegisterRecords.SoCaiKeToan.LockForUpdate = True;
	RegisterRecords.SoCaiKeToan.Write = True;

	ARMovement = RegisterRecords.CongNoPhaiThu.Add();
	ARMovement.RecordType = AccumulationRecordType.Expense;
	ARMovement.Period = Date;
	ARMovement.PhapNhan = PhapNhan;
	ARMovement.DoiTac = DoiTac;
	ARMovement.HopDong = ARSource.HopDong;
	ARMovement.ChungTuGoc = ChungTuAR;
	ARMovement.SoTien = SoTien;
	ARMovement.SoTienNgoaiTe = 0;

	APMovement = RegisterRecords.CongNoPhaiTra.Add();
	APMovement.RecordType = AccumulationRecordType.Expense;
	APMovement.Period = Date;
	APMovement.PhapNhan = PhapNhan;
	APMovement.DoiTac = DoiTac;
	APMovement.HopDong = APSource.HopDong;
	APMovement.ChungTuGoc = ChungTuAP;
	APMovement.SoTien = SoTien;
	APMovement.SoTienNgoaiTe = 0;

	GL = RegisterRecords.SoCaiKeToan.Add();
	GL.Period = Date;
	GL.AccountDr = AccountDr;
	GL.AccountCr = AccountCr;
	GL.PhapNhan = PhapNhan;
	GL.TienTe = VND;
	GL.SoTien = SoTien;
	GL.SoTienNgoaiTe = 0;
	GL.TyGia = 1;
	GL.ChungTuGoc = Ref;
	GL.DoiTacNo = DoiTac;
	GL.HopDongNo = APSource.HopDong;
	GL.ChungTuGocNo = ChungTuAP;
	GL.DoiTacCo = DoiTac;
	GL.HopDongCo = ARSource.HopDong;
	GL.ChungTuGocCo = ChungTuAR;
	GL.DienGiai = Left(?(IsBlankString(DienGiai), "Cấn trừ công nợ nội bộ AR/AP", DienGiai), 250);

	Try
		Entries = New Array;
		Entries.Add(New Structure("AmountDr,AmountCr", SoTien, SoTien));
		QuanLyVongDoiChungTuServer.KiemTraCanDoiSoCai(Entries);
	Except
		Cancel = True;
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject, BriefErrorDescription(ErrorInfo()));
		Return;
	EndTry;
	NguoiDuyet = UserName();
	WriteLogEvent("Netting.Post", EventLogLevel.Information,,, StrTemplate("%1 cấn trừ %2 VND giữa AR %3 và AP %4.", UserName(), SoTien, ChungTuAR, ChungTuAP));
EndProcedure

Procedure UndoPosting(Cancel)
	RegisterRecords.CongNoPhaiThu.Write = True;
	RegisterRecords.CongNoPhaiTra.Write = True;
	RegisterRecords.SoCaiKeToan.Write = True;
	WriteLogEvent("Netting.UndoPosting", EventLogLevel.Warning,,, StrTemplate("%1 hủy ghi sổ chứng từ cấn trừ %2.", UserName(), Number));
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

Function LaySoDuAR(Val PN, Val Partner, Val Contract, Val Source, Val AtPoint)
	Q = New Query(
		"SELECT ISNULL(SUM(SoTienBalance), 0) AS Balance
		|FROM AccumulationRegister.CongNoPhaiThu.Balance(&AtPoint,
		| PhapNhan = &PN AND DoiTac = &Partner AND HopDong = &Contract AND ChungTuGoc = &Source)");
	Q.SetParameter("AtPoint", AtPoint);
	Q.SetParameter("PN", PN);
	Q.SetParameter("Partner", Partner);
	Q.SetParameter("Contract", Contract);
	Q.SetParameter("Source", Source);
	Return Q.Execute().Unload()[0].Balance;
EndFunction

Function LaySoDuAP(Val PN, Val Partner, Val Contract, Val Source, Val AtPoint)
	Q = New Query(
		"SELECT ISNULL(SUM(SoTienBalance), 0) AS Balance
		|FROM AccumulationRegister.CongNoPhaiTra.Balance(&AtPoint,
		| PhapNhan = &PN AND DoiTac = &Partner AND HopDong = &Contract AND ChungTuGoc = &Source)");
	Q.SetParameter("AtPoint", AtPoint);
	Q.SetParameter("PN", PN);
	Q.SetParameter("Partner", Partner);
	Q.SetParameter("Contract", Contract);
	Q.SetParameter("Source", Source);
	Return Q.Execute().Unload()[0].Balance;
EndFunction

#EndRegion
