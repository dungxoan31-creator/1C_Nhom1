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
	If Not ValueIsFilled(TienTe) Then
		TienTe = Catalogs.TienTe.FindByCode("VND");
	EndIf;
	If IsBlankString(KenhThanhToan) Then
		KenhThanhToan = "VNPAY";
	EndIf;
EndProcedure

Procedure ValidateRequiredFieldsForWrite(Cancel)
	If Not ValueIsFilled(PhapNhan) Then
		Cancel = True;
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject,
			NStr("vi = 'Thiếu thông tin bắt buộc: Pháp nhân.'; en = 'Required information is missing: Legal entity.'"), "PhapNhan");
		Return;
	EndIf;
	If Not ValueIsFilled(DoiTacTrungGian) Then
		Cancel = True;
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject,
			NStr("vi = 'Thiếu thông tin bắt buộc: Đơn vị trung gian.'; en = 'Required information is missing: Payment intermediary.'"), "DoiTacTrungGian");
		Return;
	EndIf;
	If Not ValueIsFilled(TaiKhoanTien) Then
		Cancel = True;
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject,
			NStr("vi = 'Thiếu thông tin bắt buộc: Tài khoản tiền.'; en = 'Required information is missing: Cash account.'"), "TaiKhoanTien");
		Return;
	EndIf;
	If Not ValueIsFilled(KhoanMucDongTien) Then
		Cancel = True;
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject,
			NStr("vi = 'Thiếu thông tin bắt buộc: Khoản mục dòng tiền.'; en = 'Required information is missing: Cash flow item.'"), "KhoanMucDongTien");
		Return;
	EndIf;
	If Not ValueIsFilled(TienTe) Then
		Cancel = True;
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject,
			NStr("vi = 'Thiếu thông tin bắt buộc: Tiền tệ.'; en = 'Required information is missing: Currency.'"), "TienTe");
		Return;
	EndIf;
	If IsBlankString(KenhThanhToan) Then
		Cancel = True;
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject,
			NStr("vi = 'Thiếu thông tin bắt buộc: Kênh thanh toán.'; en = 'Required information is missing: Payment channel.'"), "KenhThanhToan");
		Return;
	EndIf;
	If TongTienGiaoDich <= 0 Then
		Cancel = True;
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject,
			NStr("vi = 'Tổng tiền giao dịch phải lớn hơn 0.'; en = 'The gross transaction amount must be greater than zero.'"), "TongTienGiaoDich");
		Return;
	EndIf;
	If TongPhi < 0 Then
		Cancel = True;
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject,
			NStr("vi = 'Tổng phí không được âm.'; en = 'The fee total cannot be negative.'"), "TongPhi");
		Return;
	EndIf;
	If TongTienThucNhan <= 0 Then
		Cancel = True;
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject,
			NStr("vi = 'Tổng tiền thực nhận phải lớn hơn 0.'; en = 'The net received amount must be greater than zero.'"), "TongTienThucNhan");
		Return;
	EndIf;
	If Round(TongTienGiaoDich, 2) <> Round(TongTienThucNhan + TongPhi, 2) Then
		Cancel = True;
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject,
			NStr("vi = 'Tổng giao dịch phải bằng tổng thực nhận cộng tổng phí.'; en = 'Gross amount must equal net received plus fees.'"), "TongTienGiaoDich");
		Return;
	EndIf;
	If Upper(TrimAll(KenhThanhToan)) <> "VNPAY" And Upper(TrimAll(KenhThanhToan)) <> "ONEPAY" Then
		Cancel = True;
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject,
			NStr("vi = 'Kênh thanh toán phải là VNPAY hoặc OnePay.'; en = 'Payment channel must be VNPAY or OnePay.'"), "KenhThanhToan");
		Return;
	EndIf;
	If Upper(TrimAll(TienTe.Code)) <> "VND" Or TaiKhoanTien.TienTe <> TienTe Then
		Cancel = True;
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject,
			NStr("vi = 'Đối soát hiện chỉ hỗ trợ tài khoản ngân hàng cùng tiền tệ VND.'; en = 'Reconciliation currently requires a VND bank account and document currency.'"), "TienTe");
		Return;
	EndIf;
	If KhoanMucDongTien.LoaiDongTien <> "Thu" Then
		Cancel = True;
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject,
			NStr("vi = 'Khoản mục dòng tiền phải thuộc loại Thu.'; en = 'Cash flow item must be an income item.'"), "KhoanMucDongTien");
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
	RegisterRecords.DongTien.Clear();
	RegisterRecords.SoCaiKeToan.Clear();
	RegisterRecords.CongNoPhaiThu.Clear();
	HasImportedRows = GiaoDichSaoKe.Count() > 0;
	ImportedBatch = Undefined;
	If HasImportedRows Then
		ImportedBatch = PrepareImportedBatch();
		If Not ImportedBatch.Success Then
			TuChoiGhiSo(Cancel, ImportedBatch.Message);
			Return;
		EndIf;
		TongTienGiaoDich = ImportedBatch.Gross;
		TongPhi = ImportedBatch.Fee;
		TongTienThucNhan = ImportedBatch.Net;
	EndIf;

	If Not ValueIsFilled(PhapNhan) Or Not ValueIsFilled(DoiTacTrungGian)
		Or Not ValueIsFilled(TaiKhoanTien) Or Not ValueIsFilled(KhoanMucDongTien) Or Not ValueIsFilled(TienTe) Then
		TuChoiGhiSo(Cancel, "Missing legal entity, payment provider, bank account, cash flow item, or currency.");
		Return;
	EndIf;
	NormalizedChannel = Upper(TrimAll(KenhThanhToan));
	If NormalizedChannel <> "VNPAY" And NormalizedChannel <> "ONEPAY" Then
		TuChoiGhiSo(Cancel, "Payment channel must be VNPAY or OnePay.");
		Return;
	EndIf;
	If TongTienGiaoDich <= 0 Or TongPhi < 0 Or TongTienThucNhan <= 0 Then
		TuChoiGhiSo(Cancel, "Gross and net must be positive; fee cannot be negative.");
		Return;
	EndIf;
	If Round(TongTienGiaoDich, 2) <> Round(TongTienThucNhan + TongPhi, 2) Then
		TuChoiGhiSo(Cancel, StrTemplate("Gross %1 must equal net %2 plus fee %3.", TongTienGiaoDich, TongTienThucNhan, TongPhi));
		Return;
	EndIf;
	If Upper(TrimAll(TienTe.Code)) <> "VND" Or TaiKhoanTien.TienTe <> TienTe Then
		TuChoiGhiSo(Cancel, "Reconciliation requires a VND bank account and document currency.");
		Return;
	EndIf;
	If KhoanMucDongTien.LoaiDongTien <> "Thu" Then
		TuChoiGhiSo(Cancel, "Cash flow item must be an income item.");
		Return;
	EndIf;

	LockObject = New DataLock;
	CashLock = LockObject.Add("AccumulationRegister.DongTien");
	CashLock.SetValue("PhapNhan", PhapNhan);
	CashLock.SetValue("TaiKhoanTien", TaiKhoanTien);
	CashLock.SetValue("TienTe", TienTe);
	CashLock.SetValue("KhoanMucDongTien", KhoanMucDongTien);
	If HasImportedRows Then
		For Each Entry In ImportedBatch.Rows Do
			Line = Entry.Line;
			Invoice = Entry.Invoice;
			StatementLock = LockObject.Add("InformationRegister.GiaoDichSaoKeDaNhap");
			StatementLock.SetValue("PhapNhan", PhapNhan);
			StatementLock.SetValue("TaiKhoanTien", TaiKhoanTien);
			StatementLock.SetValue("KenhThanhToan", NormalizedChannel);
			StatementLock.SetValue("KhoaGiaoDich", Line.KhoaGiaoDich);
			ARLock = LockObject.Add("AccumulationRegister.CongNoPhaiThu");
			ARLock.SetValue("PhapNhan", Invoice.PhapNhan);
			ARLock.SetValue("DoiTac", Invoice.DoiTac);
			ARLock.SetValue("HopDong", Invoice.HopDong);
			ARLock.SetValue("ChungTuGoc", Invoice.Ref);
		EndDo;
	EndIf;
	LockObject.Lock();

	AccountCash = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1121");
	AccountFee = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("6427");
	AccountClearing = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1388");
	If Not ValueIsFilled(AccountCash) Or Not ValueIsFilled(AccountFee) Or Not ValueIsFilled(AccountClearing) Then
		TuChoiGhiSo(Cancel, "Required GL accounts 1121, 6427, or 1388 are missing.");
		Return;
	EndIf;

	If HasImportedRows Then
		BalanceError = ValidateImportedARBalances(ImportedBatch.Rows);
		If StrLen(BalanceError) > 0 Then
			TuChoiGhiSo(Cancel, BalanceError);
			Return;
		EndIf;
		ReservationError = ReserveImportedTransactions(ImportedBatch.Rows, NormalizedChannel);
		If StrLen(ReservationError) > 0 Then
			TuChoiGhiSo(Cancel, ReservationError);
			Return;
		EndIf;
	EndIf;

	RegisterRecords.DongTien.LockForUpdate = True;
	RegisterRecords.DongTien.Write = True;
	RegisterRecords.SoCaiKeToan.LockForUpdate = True;
	RegisterRecords.SoCaiKeToan.Write = True;
	If HasImportedRows Then
		RegisterRecords.CongNoPhaiThu.LockForUpdate = True;
		RegisterRecords.CongNoPhaiThu.Write = True;
		AccountAR = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1311");
		For Each Entry In ImportedBatch.Rows Do
			Line = Entry.Line;
			Invoice = Entry.Invoice;
			CashMovement = RegisterRecords.DongTien.Add();
			CashMovement.RecordType = AccumulationRecordType.Receipt;
			CashMovement.Period = Line.NgayGiaoDich;
			CashMovement.PhapNhan = PhapNhan;
			CashMovement.TaiKhoanTien = TaiKhoanTien;
			CashMovement.TienTe = TienTe;
			CashMovement.KhoanMucDongTien = KhoanMucDongTien;
			CashMovement.SoTien = Line.Net;
			CashMovement.SoTienNgoaiTe = 0;

			NetEntry = RegisterRecords.SoCaiKeToan.Add();
			NetEntry.Period = Line.NgayGiaoDich;
			NetEntry.AccountDr = AccountCash;
			NetEntry.AccountCr = AccountClearing;
			NetEntry.PhapNhan = PhapNhan;
			NetEntry.TienTe = TienTe;
			NetEntry.SoTien = Line.Net;
			NetEntry.SoTienNgoaiTe = 0;
			NetEntry.TyGia = 1;
			NetEntry.ChungTuGoc = Ref;
			NetEntry.TaiKhoanTien = TaiKhoanTien;
			NetEntry.TaiKhoanTienNo = TaiKhoanTien;
			NetEntry.DoiTacCo = DoiTacTrungGian;
			NetEntry.ChungTuGocCo = Ref;
			NetEntry.DienGiai = Left(StrTemplate("%1 - net receipt via %2", Line.DienGiaiDong, NormalizedChannel), 250);

			If Line.Phi > 0 Then
				FeeEntry = RegisterRecords.SoCaiKeToan.Add();
				FeeEntry.Period = Line.NgayGiaoDich;
				FeeEntry.AccountDr = AccountFee;
				FeeEntry.AccountCr = AccountClearing;
				FeeEntry.PhapNhan = PhapNhan;
				FeeEntry.TienTe = TienTe;
				FeeEntry.SoTien = Line.Phi;
				FeeEntry.SoTienNgoaiTe = 0;
				FeeEntry.TyGia = 1;
				FeeEntry.ChungTuGoc = Ref;
				FeeEntry.DoiTacCo = DoiTacTrungGian;
				FeeEntry.ChungTuGocCo = Ref;
				FeeEntry.DienGiai = Left(StrTemplate("Payment channel fee - %1", NormalizedChannel), 250);
			EndIf;

			If Invoice.DoiTac.LaBenLienKet Then
				AccountAR = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1312");
			EndIf;
			ARMovement = RegisterRecords.CongNoPhaiThu.Add();
			ARMovement.RecordType = AccumulationRecordType.Expense;
			ARMovement.Period = Line.NgayGiaoDich;
			ARMovement.PhapNhan = Invoice.PhapNhan;
			ARMovement.DoiTac = Invoice.DoiTac;
			ARMovement.HopDong = Invoice.HopDong;
			ARMovement.ChungTuGoc = Invoice.Ref;
			ARMovement.SoTien = Line.SoTienGhep;
			ARMovement.SoTienNgoaiTe = 0;

			ARSettlement = RegisterRecords.SoCaiKeToan.Add();
			ARSettlement.Period = Line.NgayGiaoDich;
			ARSettlement.AccountDr = AccountClearing;
			ARSettlement.AccountCr = AccountAR;
			ARSettlement.PhapNhan = PhapNhan;
			ARSettlement.TienTe = TienTe;
			ARSettlement.SoTien = Line.SoTienGhep;
			ARSettlement.SoTienNgoaiTe = 0;
			ARSettlement.TyGia = 1;
			ARSettlement.ChungTuGoc = Ref;
			ARSettlement.DoiTacCo = Invoice.DoiTac;
			ARSettlement.HopDongCo = Invoice.HopDong;
			ARSettlement.ChungTuGocCo = Invoice.Ref;
			ARSettlement.DienGiai = Left(StrTemplate("Settlement of issued AR invoice %1 from %2", Invoice.Number, Line.ExternalId), 250);
			AccountAR = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1311");
		EndDo;
	Else
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
		NetEntry.DienGiai = Left(StrTemplate("%1 - net receipt via %2", DienGiai, KenhThanhToan), 250);

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
			FeeEntry.DienGiai = Left(StrTemplate("Payment channel fee %1", KenhThanhToan), 250);
		EndIf;
	EndIf;

	Try
		QuanLyVongDoiChungTuServer.KiemTraCanDoiSoCai(RegisterRecords.SoCaiKeToan);
	Except
		Cancel = True;
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject, BriefErrorDescription(ErrorInfo()));
		Return;
	EndTry;
	NguoiDuyet = UserName();
	WriteLogEvent("PaymentReconciliation.Post", EventLogLevel.Information,,, StrTemplate("%1 recorded %2: Gross=%3, Fee=%4, Net=%5.", UserName(), KenhThanhToan, TongTienGiaoDich, TongPhi, TongTienThucNhan));
EndProcedure
Procedure UndoPosting(Cancel)
	RegisterRecords.DongTien.Write = True;
	RegisterRecords.SoCaiKeToan.Write = True;
	RegisterRecords.CongNoPhaiThu.Write = True;
	Try
		DeactivateImportedTransactions();
	Except
		Raise "Could not release imported statement transaction keys: " + DetailErrorDescription(ErrorInfo());
	EndTry;
	WriteLogEvent("PaymentReconciliation.UndoPosting", EventLogLevel.Warning,,, StrTemplate("%1 reversed reconciliation %2.", UserName(), Number));
EndProcedure
#EndRegion


Function PrepareImportedBatch()
	Result = New Structure("Success,Message,Rows,Gross,Fee,Net", False, "", New Array, 0, 0, 0);
	If GiaoDichSaoKe.Count() = 0 Then
		Result.Message = "Imported statement has no rows.";
		Return Result;
	EndIf;
	For Each Line In GiaoDichSaoKe Do
		If Line.TrangThaiDong <> "DaGhep" Then
			Result.Message = StrTemplate("CSV line %1 is not confirmed for posting (status %2).", Line.LineNumber, Line.TrangThaiDong);
			Return Result;
		EndIf;
		If StrLen(TrimAll(Line.KhoaGiaoDich)) = 0 Or Not ValueIsFilled(Line.NgayGiaoDich) Or Not ValueIsFilled(Line.TienTeDong) Then
			Result.Message = StrTemplate("CSV line %1 is missing its transaction key, date, or currency.", Line.LineNumber);
			Return Result;
		EndIf;
		If Line.Gross <= 0 Or Line.Phi < 0 Or Line.Net <= 0 Or Round(Line.Gross, 2) <> Round(Line.Phi + Line.Net, 2) Then
			Result.Message = StrTemplate("CSV line %1 is unbalanced: gross must equal fee plus net.", Line.LineNumber);
			Return Result;
		EndIf;
		If Round(Line.SoTienGhep, 2) <> Round(Line.Gross, 2) Then
			Result.Message = StrTemplate("CSV line %1 must allocate its full gross amount to one AR invoice.", Line.LineNumber);
			Return Result;
		EndIf;
		If Not ValueIsFilled(Line.HoaDonAR) Then
			Result.Message = StrTemplate("CSV line %1 is unmatched. Select and confirm an issued AR invoice.", Line.LineNumber);
			Return Result;
		EndIf;
		Invoice = Line.HoaDonAR.GetObject();
		If Invoice.DeletionMark Or Not Invoice.Posted Or Invoice.TrangThaiHDDT <> Enums.TrangThaiHoaDonDienTu.DaPhatHanh Then
			Result.Message = StrTemplate("CSV line %1 must match an active, posted, issued AR invoice.", Line.LineNumber);
			Return Result;
		EndIf;
		If Invoice.PhapNhan <> PhapNhan Or Invoice.TienTe <> TienTe Or Line.TienTeDong <> TienTe Then
			Result.Message = StrTemplate("CSV line %1 and its issued invoice must use the document legal entity and VND currency.", Line.LineNumber);
			Return Result;
		EndIf;
		If Not ValueIsFilled(Invoice.DoiTac) Or Not ValueIsFilled(Invoice.HopDong) Then
			Result.Message = StrTemplate("AR invoice on CSV line %1 has no partner or contract.", Line.LineNumber);
			Return Result;
		EndIf;
		For Each EarlierEntry In Result.Rows Do
			If EarlierEntry.Line.KhoaGiaoDich = Line.KhoaGiaoDich Then
				Result.Message = StrTemplate("CSV lines %1 and %2 have the same transaction identity.", EarlierEntry.Line.LineNumber, Line.LineNumber);
				Return Result;
			EndIf;
		EndDo;
		Result.Rows.Add(New Structure("Line,Invoice", Line, Invoice));
		Result.Gross = Result.Gross + Line.Gross;
		Result.Fee = Result.Fee + Line.Phi;
		Result.Net = Result.Net + Line.Net;
	EndDo;
	If Round(Result.Gross, 2) <> Round(Result.Fee + Result.Net, 2) Then
		Result.Message = "Imported statement totals do not balance: gross must equal fee plus net.";
		Return Result;
	EndIf;
	Result.Success = True;
	Return Result;
EndFunction

Function ValidateImportedARBalances(Val ImportedRows)
	Allocations = New ValueTable;
	Allocations.Columns.Add("Invoice");
	Allocations.Columns.Add("OpenBalance");
	Allocations.Columns.Add("Allocated");
	For Each Entry In ImportedRows Do
		Invoice = Entry.Invoice;
		Allocation = Undefined;
		For Each Existing In Allocations Do
			If Existing.Invoice = Invoice.Ref Then
				Allocation = Existing;
				Break;
			EndIf;
		EndDo;
		If Allocation = Undefined Then
			BalanceQuery = New Query(
				"SELECT ISNULL(SUM(SoTienBalance), 0) AS OpenBalance
				|FROM AccumulationRegister.CongNoPhaiThu.Balance(,
				| PhapNhan = &PN AND DoiTac = &Partner AND HopDong = &Contract AND ChungTuGoc = &Source)");
			BalanceQuery.SetParameter("PN", Invoice.PhapNhan);
			BalanceQuery.SetParameter("Partner", Invoice.DoiTac);
			BalanceQuery.SetParameter("Contract", Invoice.HopDong);
			BalanceQuery.SetParameter("Source", Invoice.Ref);
			OpenBalance = BalanceQuery.Execute().Unload()[0].OpenBalance;
			If OpenBalance <= 0 Then Return StrTemplate("Invoice %1 has no positive open AR balance.", Invoice.Number); EndIf;
			Allocation = Allocations.Add();
			Allocation.Invoice = Invoice.Ref;
			Allocation.OpenBalance = OpenBalance;
			Allocation.Allocated = 0;
		EndIf;
		If Entry.Line.SoTienGhep > Allocation.OpenBalance - Allocation.Allocated Then
			Return StrTemplate("CSV line %1 exceeds the remaining open AR balance for invoice %2.", Entry.Line.LineNumber, Invoice.Number);
		EndIf;
		Allocation.Allocated = Allocation.Allocated + Entry.Line.SoTienGhep;
	EndDo;
	Return "";
EndFunction

Function ReserveImportedTransactions(Val ImportedRows, Val NormalizedChannel)
	For Each Entry In ImportedRows Do
		Line = Entry.Line;
		ExistingQuery = New Query(
			"SELECT TOP 1 ChungTu, SoDong
			|FROM InformationRegister.GiaoDichSaoKeDaNhap
			|WHERE PhapNhan = &PN AND TaiKhoanTien = &Cash AND KenhThanhToan = &Channel AND KhoaGiaoDich = &Key");
		ExistingQuery.SetParameter("PN", PhapNhan);
		ExistingQuery.SetParameter("Cash", TaiKhoanTien);
		ExistingQuery.SetParameter("Channel", NormalizedChannel);
		ExistingQuery.SetParameter("Key", Line.KhoaGiaoDich);
		ExistingRows = ExistingQuery.Execute().Unload();
		If ExistingRows.Count() > 0 Then
			If ExistingRows[0].ChungTu <> Ref Then
				Return StrTemplate("CSV line %1 duplicates a transaction already posted by another reconciliation.", Line.LineNumber);
			EndIf;
		EndIf;

		KeySet = InformationRegisters.GiaoDichSaoKeDaNhap.CreateRecordSet();
		KeySet.Filter.PhapNhan.Set(PhapNhan);
		KeySet.Filter.TaiKhoanTien.Set(TaiKhoanTien);
		KeySet.Filter.KenhThanhToan.Set(NormalizedChannel);
		KeySet.Filter.KhoaGiaoDich.Set(Line.KhoaGiaoDich);
		KeySet.Read();
		If KeySet.Count() = 0 Then
			KeyRecord = KeySet.Add();
		Else
			KeyRecord = KeySet[0];
		EndIf;
		KeyRecord.PhapNhan = PhapNhan;
		KeyRecord.TaiKhoanTien = TaiKhoanTien;
		KeyRecord.KenhThanhToan = NormalizedChannel;
		KeyRecord.KhoaGiaoDich = Line.KhoaGiaoDich;
		KeyRecord.ChungTu = Ref;
		KeyRecord.SoDong = Line.LineNumber;
		KeySet.Write(True);
	EndDo;
	Return "";
EndFunction

Procedure DeactivateImportedTransactions()
	KeyQuery = New Query(
		"SELECT PhapNhan, TaiKhoanTien, KenhThanhToan, KhoaGiaoDich
		|FROM InformationRegister.GiaoDichSaoKeDaNhap
		|WHERE ChungTu = &Document");
	KeyQuery.SetParameter("Document", Ref);
	Keys = KeyQuery.Execute().Unload();
	For Each TransactionKeyRow In Keys Do
		KeySet = InformationRegisters.GiaoDichSaoKeDaNhap.CreateRecordSet();
		KeySet.Filter.PhapNhan.Set(TransactionKeyRow.PhapNhan);
		KeySet.Filter.TaiKhoanTien.Set(TransactionKeyRow.TaiKhoanTien);
		KeySet.Filter.KenhThanhToan.Set(TransactionKeyRow.KenhThanhToan);
		KeySet.Filter.KhoaGiaoDich.Set(TransactionKeyRow.KhoaGiaoDich);
		// An empty filtered record set deletes the key from this independent register.
		KeySet.Write();
	EndDo;
EndProcedure
#Region InternalFunctions

Procedure TuChoiGhiSo(Cancel, Val NoiDung)
	Cancel = True;
	Msg = New UserMessage;
	Msg.Text = NoiDung;
	Msg.SetData(ThisObject);
	Msg.Message();
EndProcedure

#EndRegion
