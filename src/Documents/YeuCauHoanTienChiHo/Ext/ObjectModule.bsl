// Document: YeuCauHoanTienChiHo
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Xu ly yeu cau hoan tien chi ho cho khach hang B2C (Task 5.3):
//           - Maker-Checker: Nguoi lap khong duoc tu duyet
//           - Chi ghi so khi TrangThai = "DaDuyet" hoac "DaHoanTien"
//           - Ghi giam so du tren AccumulationRegister.GiaoDichDienTuTamGiu
//           - Ghi giam dong tien tren AccumulationRegister.DongTien (Expense)
//           - Ghi so cai SoCaiKeToan:
//             + No TK 1388: So tien hoan
//             + (No TK 6427: Phi hoan tien neu co)
//             + Co TK 1121: Tong tien chi ngan hang
//           - Invariant can doi Delta = 0

#Region EventHandlers

Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	PhanQuyenBaoMatServer.KiemTraQuyenChungTu(ThisObject, "Write", UserName());
	If WriteMode = DocumentWriteMode.Posting Then
		PhanQuyenBaoMatServer.KiemTraQuyenChungTu(ThisObject, "GhiSo", UserName());
	EndIf;
	
	// Kiem tra Maker-Checker chan nguoi lap tu duyet
	If ValueIsFilled(NguoiLap) And ValueIsFilled(NguoiDuyet) And NguoiLap = NguoiDuyet Then
		Cancel = True;
		Msg = New UserMessage;
		Msg.Text = NStr("vi = 'CẤM TUYỆT ĐỐI: Người lập yêu cầu hoàn tiền không được phép tự phê duyệt!'; en = 'Maker-Checker violation: Submitter cannot approve their own refund request!'");
		Msg.SetData(ThisObject);
		Msg.Field = "NguoiDuyet";
		Msg.Message();
		Return;
	EndIf;
	
	If Not ValueIsFilled(TrangThai) Then
		If DataExchange.Load Then Return; EndIf;
		TrangThai = "ChoDuyet";
	EndIf;
	
	// Cap nhat trang thai sang DaHoanTien trong BeforeWrite de luu vao CSDL
	If WriteMode = DocumentWriteMode.Posting Then
		If TrangThai = "DaDuyet" Then
			TrangThai = "DaHoanTien";
		EndIf;
	EndIf;
EndProcedure

Procedure Posting(Cancel, Mode)
	// Rebuild owned movements even when the same object instance is reposted.
	RegisterRecords.GiaoDichDienTuTamGiu.Clear();
	RegisterRecords.DongTien.Clear();
	RegisterRecords.SoCaiKeToan.Clear();
	// Dam bao xoa movement cu neu trang thai khong con hop le de ghi so (#std603)
	RegisterRecords.GiaoDichDienTuTamGiu.Write = True;
	RegisterRecords.DongTien.Write = True;
	RegisterRecords.SoCaiKeToan.Write = True;
	
	// Chi ghi so khi da duyet hoac da hoan tien
	If TrangThai <> "DaDuyet" And TrangThai <> "DaHoanTien" Then
		Return;
	EndIf;
	
	// Kiem tra truong bat buoc
	HasError = False;
	If Not ValueIsFilled(PhapNhan) Then
		HasError = True;
		Msg = New UserMessage;
		Msg.Text = NStr("vi = 'Trường Pháp nhân chưa được điền!'; en = 'Legal Entity is required!'");
		Msg.SetData(ThisObject);
		Msg.Field = "PhapNhan";
		Msg.Message();
	EndIf;
	If Not ValueIsFilled(TaiKhoanNganHangChi) Then
		HasError = True;
		Msg = New UserMessage;
		Msg.Text = NStr("vi = 'Trường Tài khoản ngân hàng chi chưa được điền!'; en = 'Disbursement cash account is required!'");
		Msg.SetData(ThisObject);
		Msg.Field = "TaiKhoanNganHangChi";
		Msg.Message();
	EndIf;
	If SoTienHoan <= 0 Then
		HasError = True;
		Msg = New UserMessage;
		Msg.Text = NStr("vi = 'Số tiền hoàn phải lớn hơn 0!'; en = 'Refund amount must be greater than 0!'");
		Msg.SetData(ThisObject);
		Msg.Field = "SoTienHoan";
		Msg.Message();
	EndIf;
	
	If HasError Then
		Cancel = True;
		Return;
	EndIf;
	
	NgayHachToan = BegOfDay(Date);
	TienTeVND = Catalogs.TienTe.FindByCode("VND");
	
	// 1. Giam so du tren GiaoDichDienTuTamGiu
	RegisterRecords.GiaoDichDienTuTamGiu.Write = True;
	RecTamGiu = RegisterRecords.GiaoDichDienTuTamGiu.Add();
	RecTamGiu.RecordType = AccumulationRecordType.Expense;
	RecTamGiu.Period = NgayHachToan;
	RecTamGiu.PhapNhan = PhapNhan;
	RecTamGiu.KenhThanhToan = KenhThanhToan;
	RecTamGiu.MaGiaoDichKenh = MaGiaoDichGoc;
	RecTamGiu.SoTien = SoTienHoan;
	RecTamGiu.PhiKenh = PhiHoanTien;
	
	// 2. Giam dong tien tren DongTien (Expense)
	RegisterRecords.DongTien.Write = True;
	RecDT = RegisterRecords.DongTien.Add();
	RecDT.RecordType = AccumulationRecordType.Expense;
	RecDT.Period = NgayHachToan;
	RecDT.PhapNhan = PhapNhan;
	RecDT.TaiKhoanTien = TaiKhoanNganHangChi;
	RecDT.KhoanMucDongTien = KhoanMucDongTien;
	RecDT.TienTe = TienTeVND;
	RecDT.SoTien = SoTienHoan + PhiHoanTien;
	RecDT.SoTienNgoaiTe = 0;
	
	// 3. Ghi so cai SoCaiKeToan
	RegisterRecords.SoCaiKeToan.Write = True;
	
	TK1121 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1121");
	TK6427 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("6427");
	TK1388 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1388");
	
	// But toan 1: Hoan tien khach hang
	// No TK 1388 / Co TK 1121: SoTienHoan
	Row1 = RegisterRecords.SoCaiKeToan.Add();
	Row1.Period = NgayHachToan;
	Row1.AccountDr = TK1388;
	Row1.AccountCr = TK1121;
	Row1.SoTien = SoTienHoan;
	Row1.DienGiai = StrTemplate("Hoàn tiền cho khách hàng theo giao dịch %1: %2", MaGiaoDichGoc, LyDoHoanTien);
	Row1.PhapNhan = PhapNhan;
	Row1.TienTe = TienTeVND;
	Row1.ChungTuGoc = Ref;
	Row1.TyGia = 1;
	
	// But toan 2: Phi hoan tien neu co
	If PhiHoanTien > 0 Then
		Row2 = RegisterRecords.SoCaiKeToan.Add();
		Row2.Period = NgayHachToan;
		Row2.AccountDr = TK6427;
		Row2.AccountCr = TK1121;
		Row2.SoTien = PhiHoanTien;
		Row2.DienGiai = StrTemplate("Phí xử lý hoàn tiền giao dịch %1", MaGiaoDichGoc);
		Row2.PhapNhan = PhapNhan;
		Row2.TienTe = TienTeVND;
		Row2.ChungTuGoc = Ref;
		Row2.TyGia = 1;
	EndIf;
	
	// Invariant Check
	Try
		QuanLyVongDoiChungTuServer.KiemTraCanDoiSoCai(RegisterRecords.SoCaiKeToan);
	Except
		Cancel = True;
		WriteLogEvent("Posting.YeuCauHoanTienChiHo", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
	EndTry;
EndProcedure

#EndRegion
