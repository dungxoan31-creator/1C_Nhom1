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
	If DataExchange.Load Then
		Return;
	EndIf;
	
	// Kiem tra Maker-Checker chan nguoi lap tu duyet
	If ValueIsFilled(NguoiLap) And ValueIsFilled(NguoiDuyet) And NguoiLap = NguoiDuyet Then
		Cancel = True;
		Raise "CẤM TUYỆT ĐỐI: Người lập yêu cầu hoàn tiền không được phép tự phê duyệt!";
		Return;
	EndIf;
	
	If Not ValueIsFilled(TrangThai) Then
		TrangThai = "ChoDuyet";
	EndIf;
EndProcedure

Procedure Posting(Cancel, Mode)
	// Chi ghi so khi da duyet hoac da hoan tien
	If TrangThai <> "DaDuyet" And TrangThai <> "DaHoanTien" Then
		RegisterRecords.GiaoDichDienTuTamGiu.Write = False;
		RegisterRecords.DongTien.Write = False;
		RegisterRecords.SoCaiKeToan.Write = False;
		Return;
	EndIf;
	
	// Kiem tra truong bat buoc
	If Not ValueIsFilled(PhapNhan) Then
		Cancel = True;
		Raise "Trường 'Pháp nhân' chưa được điền!";
		Return;
	EndIf;
	If Not ValueIsFilled(TaiKhoanNganHangChi) Then
		Cancel = True;
		Raise "Trường 'Tài khoản ngân hàng chi' chưa được điền!";
		Return;
	EndIf;
	If SoTienHoan <= 0 Then
		Cancel = True;
		Raise "Số tiền hoàn phải lớn hơn 0!";
		Return;
	EndIf;
	
	NgayHachToan = BegOfDay(Date);
	
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
	RecDT.SoTien = SoTienHoan + PhiHoanTien;
	
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
	Row1.Amount = SoTienHoan;
	Row1.Description = StrTemplate("Hoàn tiền cho khách hàng theo giao dịch %1: %2", MaGiaoDichGoc, LyDoHoanTien);
	Row1.PhapNhan = PhapNhan;
	Row1.DoiTac = DoiTac;
	Row1.HopDong = HopDong;
	
	// But toan 2: Phi hoan tien neu co
	If PhiHoanTien > 0 Then
		Row2 = RegisterRecords.SoCaiKeToan.Add();
		Row2.Period = NgayHachToan;
		Row2.AccountDr = TK6427;
		Row2.AccountCr = TK1121;
		Row2.Amount = PhiHoanTien;
		Row2.Description = StrTemplate("Phí xử lý hoàn tiền giao dịch %1", MaGiaoDichGoc);
		Row2.PhapNhan = PhapNhan;
	EndIf;
	
	// Invariant Check
	QuanLyVongDoiChungTuServer.KiemTraCanDoiSoCai(RegisterRecords.SoCaiKeToan);
	
	TrangThai = "DaHoanTien";
EndProcedure

#EndRegion
