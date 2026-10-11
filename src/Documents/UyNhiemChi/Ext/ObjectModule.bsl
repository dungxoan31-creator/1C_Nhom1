// Document: UyNhiemChi
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Xu ly su kien ghi so (Posting) Uy nhiem chi theo P0.2 Invariant State Machine (Task 4.3):
//           - Kiem tra Maker-Checker: Nguoi lap khong duoc tu duyet
//           - Khi chua o DaGhiSo (DuThao, ChoDuyet, DaDuyet, DaGuiNganHang, TuChoi, HuyBo):
//             KHONG GHI SO GL VA SUBLEDGER (Non-posting, Zero Phantom Reversals)
//           - Khi DaGhiSo:
//             + Ghi giam no AP tren CongNoPhaiTra (Expense)
//             + Ghi giam tien tren DongTien (Expense)
//             + Ghi SoCaiKeToan: No 3311 (hoac 3312) / Co 1121 (hoac 1122); Phi ngan hang No 6427 / Co 1121
//           - Khi LaTraSoatHoanTra = True:
//             + Sinh but toan dao hoan nguyen cong no va dong tien (No 1121 / Co 3311)

#Region EventHandlers

Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	If DataExchange.Load Then
		Return;
	EndIf;
	
	// 1. Kiem tra Maker-Checker chan nguoi lap tu duyet
	If ValueIsFilled(NguoiLap) And ValueIsFilled(NguoiDuyet) And NguoiLap = NguoiDuyet Then
		Cancel = True;
		Msg = New UserMessage;
		Msg.Text = NStr("vi = 'CẤM TUYỆT ĐỐI: Người lập lệnh chi tiền không được phép tham gia phê duyệt!'; en = 'Maker-Checker violation: Submitter cannot approve their own payment order!'");
		Msg.SetData(ThisObject);
		Msg.Field = "NguoiDuyet";
		Msg.Message();
		Return;
	EndIf;
	
	// 2. Mac dinh ngay lap va ty gia
	If Not ValueIsFilled(NgayLap) Then
		NgayLap = BegOfDay(Date);
	EndIf;
	If TyGia <= 0 Then
		TyGia = 1;
	EndIf;
EndProcedure

Procedure Posting(Cancel, Mode)
	// 1. Kiem tra P0.2 Invariant State Machine:
	// Xoa movement cu neu trang thai khong con la DaGhiSo (Quy tac P2 / #std603)
	RegisterRecords.CongNoPhaiTra.Write = True;
	RegisterRecords.DongTien.Write = True;
	RegisterRecords.SoCaiKeToan.Write = True;
	
	TrangThaiDaGhiSo = Enums.TrangThaiLenhThanhToan.DaGhiSo;
	
	If TrangThai <> TrangThaiDaGhiSo Then
		// KHONG GHI SO GL VA SUBLEDGER! (Ghi de record set rong de xoa movement cu neu co)
		Return;
	EndIf;
	
	// 2. Kiem tra cac truong bat buoc khi da ghi so
	HasError = False;
	If Not ValueIsFilled(PhapNhan) Then
		HasError = True;
		Msg = New UserMessage;
		Msg.Text = NStr("vi = 'Trường Pháp nhân chưa được điền!'; en = 'Legal Entity is required!'");
		Msg.SetData(ThisObject);
		Msg.Field = "PhapNhan";
		Msg.Message();
	EndIf;
	If Not ValueIsFilled(DoiTac) Then
		HasError = True;
		Msg = New UserMessage;
		Msg.Text = NStr("vi = 'Trường Nhà cung cấp chưa được điền!'; en = 'Counterparty is required!'");
		Msg.SetData(ThisObject);
		Msg.Field = "DoiTac";
		Msg.Message();
	EndIf;
	If Not ValueIsFilled(HopDong) Then
		HasError = True;
		Msg = New UserMessage;
		Msg.Text = NStr("vi = 'Trường Hợp đồng chưa được điền!'; en = 'Contract is required!'");
		Msg.SetData(ThisObject);
		Msg.Field = "HopDong";
		Msg.Message();
	EndIf;
	If SoTien <= 0 Then
		HasError = True;
		Msg = New UserMessage;
		Msg.Text = NStr("vi = 'Số tiền lệnh chi phải lớn hơn 0!'; en = 'Payment amount must be greater than 0!'");
		Msg.SetData(ThisObject);
		Msg.Field = "SoTien";
		Msg.Message();
	EndIf;
	
	If HasError Then
		Cancel = True;
		Return;
	EndIf;
	
	// 3. Xac dinh tai khoan ke toan
	LaNoiBo = DoiTac.LaBenLienKet;
	MaTKCongNo = ?(LaNoiBo, "3312", "3311");
	TKCongNo = ChartsOfAccounts.HeThongTaiKhoan.FindByCode(MaTKCongNo);
	
	LaNgoaiTe = (SoTienNgoaiTe > 0);
	MaTKTien = ?(LaNgoaiTe, "1122", "1121");
	TKTien = ChartsOfAccounts.HeThongTaiKhoan.FindByCode(MaTKTien);
	TKPhiNganHang = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("6427");
	
	NgayHachToan = ?(ValueIsFilled(NgayGhiSo), NgayGhiSo, Date);
	
	// 4. Truong hop Tra soat hoan tra sau ghi so (Reversal)
	If LaTraSoatHoanTra Then
		// Ghi tang lai no AP tren CongNoPhaiTra (Receipt)
		RegisterRecords.CongNoPhaiTra.Write = True;
		RecordAP = RegisterRecords.CongNoPhaiTra.Add();
		RecordAP.RecordType = AccumulationRecordType.Receipt;
		RecordAP.Period = NgayHachToan;
		RecordAP.PhapNhan = PhapNhan;
		RecordAP.DoiTac = DoiTac;
		RecordAP.HopDong = HopDong;
		RecordAP.ChungTuGoc = ChungTuGoc;
		RecordAP.SoTien = SoTien;
		RecordAP.SoTienNgoaiTe = SoTienNgoaiTe;
		
		// Ghi tang lai tien tren DongTien (Receipt)
		RegisterRecords.DongTien.Write = True;
		RecordDT = RegisterRecords.DongTien.Add();
		RecordDT.RecordType = AccumulationRecordType.Receipt;
		RecordDT.Period = NgayHachToan;
		RecordDT.PhapNhan = PhapNhan;
		RecordDT.TaiKhoanTien = TaiKhoanTien;
		RecordDT.KhoanMucDongTien = KhoanMucDongTien;
		RecordDT.TienTe = TienTe;
		RecordDT.SoTien = SoTien;
		RecordDT.SoTienNgoaiTe = SoTienNgoaiTe;
		
		// But toan dao tren SoCaiKeToan: No 1121 (hoac 1122) / Co 3311 (hoac 3312)
		RegisterRecords.SoCaiKeToan.Write = True;
		RowRev = RegisterRecords.SoCaiKeToan.Add();
		RowRev.Period = NgayHachToan;
		RowRev.AccountDr = TKTien;
		RowRev.AccountCr = TKCongNo;
		RowRev.SoTien = SoTien;
		RowRev.DienGiai = StrTemplate("Hoàn trả tiền theo tra soát lệnh chi %1", Number);
		RowRev.PhapNhan = PhapNhan;
		RowRev.TienTe = TienTe;
		RowRev.ChungTuGoc = ChungTuGoc;
		RowRev.TyGia = ?(TyGia > 0, TyGia, 1);
		If SoTienNgoaiTe > 0 Then
			RowRev.SoTienNgoaiTe = SoTienNgoaiTe;
		EndIf;
		
		Try
			QuanLyVongDoiChungTuServer.KiemTraCanDoiSoCai(RegisterRecords.SoCaiKeToan);
		Except
			Cancel = True;
			WriteLogEvent("Posting.UyNhiemChi", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		EndTry;
		Return;
	EndIf;
	
	// 5. Truong hop chi tien binh thuong (Normal Payment)
	// Ghi giam no phai tra tren CongNoPhaiTra (Expense)
	RegisterRecords.CongNoPhaiTra.Write = True;
	RecordAP = RegisterRecords.CongNoPhaiTra.Add();
	RecordAP.RecordType = AccumulationRecordType.Expense;
	RecordAP.Period = NgayHachToan;
	RecordAP.PhapNhan = PhapNhan;
	RecordAP.DoiTac = DoiTac;
	RecordAP.HopDong = HopDong;
	RecordAP.ChungTuGoc = ChungTuGoc;
	RecordAP.SoTien = SoTien;
	RecordAP.SoTienNgoaiTe = SoTienNgoaiTe;
	
	// Ghi giam tien tren DongTien (Expense)
	RegisterRecords.DongTien.Write = True;
	RecordDT = RegisterRecords.DongTien.Add();
	RecordDT.RecordType = AccumulationRecordType.Expense;
	RecordDT.Period = NgayHachToan;
	RecordDT.PhapNhan = PhapNhan;
	RecordDT.TaiKhoanTien = TaiKhoanTien;
	RecordDT.KhoanMucDongTien = KhoanMucDongTien;
	RecordDT.TienTe = TienTe;
	RecordDT.SoTien = SoTien;
	RecordDT.SoTienNgoaiTe = SoTienNgoaiTe;
	
	// Ghi So cai SoCaiKeToan
	RegisterRecords.SoCaiKeToan.Write = True;
	
	// But toan 1: Thanh toan no AP (No 3311/3312 / Co 1121/1122)
	Row1 = RegisterRecords.SoCaiKeToan.Add();
	Row1.Period = NgayHachToan;
	Row1.AccountDr = TKCongNo;
	Row1.AccountCr = TKTien;
	Row1.SoTien = SoTien;
	Row1.DienGiai = StrTemplate("Thanh toán tiền cho NCC theo UNC %1", Number);
	Row1.PhapNhan = PhapNhan;
	Row1.TienTe = TienTe;
	Row1.ChungTuGoc = ChungTuGoc;
	Row1.TyGia = ?(TyGia > 0, TyGia, 1);
	If SoTienNgoaiTe > 0 Then
		Row1.SoTienNgoaiTe = SoTienNgoaiTe;
	EndIf;
	
	// But toan 2: Phi chuyen tien ngan hang (No 6427 / Co 1121) neu co
	If PhiNganHang > 0 Then
		TienTeVND = Catalogs.TienTe.FindByCode("VND");
		Row2 = RegisterRecords.SoCaiKeToan.Add();
		Row2.Period = NgayHachToan;
		Row2.AccountDr = TKPhiNganHang;
		Row2.AccountCr = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1121");
		Row2.SoTien = PhiNganHang;
		Row2.DienGiai = StrTemplate("Phí chuyển tiền ngân hàng UNC %1", Number);
		Row2.PhapNhan = PhapNhan;
		Row2.TienTe = TienTeVND;
		Row2.ChungTuGoc = ChungTuGoc;
		Row2.TyGia = 1;
		
		// Ghi them dong giam phi tren DongTien
		RecordFee = RegisterRecords.DongTien.Add();
		RecordFee.RecordType = AccumulationRecordType.Expense;
		RecordFee.Period = NgayHachToan;
		RecordFee.PhapNhan = PhapNhan;
		RecordFee.TaiKhoanTien = TaiKhoanTien;
		RecordFee.KhoanMucDongTien = KhoanMucDongTien;
		RecordFee.TienTe = TienTeVND;
		RecordFee.SoTien = PhiNganHang;
		RecordFee.SoTienNgoaiTe = 0;
	EndIf;
	
	Try
		QuanLyVongDoiChungTuServer.KiemTraCanDoiSoCai(RegisterRecords.SoCaiKeToan);
	Except
		Cancel = True;
		WriteLogEvent("Posting.UyNhiemChi", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
	EndTry;
EndProcedure

#EndRegion
