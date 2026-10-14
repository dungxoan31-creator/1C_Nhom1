// Document: BangKeDoiSoatKenhThanhToan
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Xu ly su kien ghi so Bang ke doi soat kenh thanh toan (Task 5.3):
//           - Tinh toan tong cong cac dong chi tiet (Truoc khi ghi)
//           - Ghi giam so du tren AccumulationRegister.GiaoDichDienTuTamGiu (Expense)
//           - Ghi tang dong tien tren AccumulationRegister.DongTien (Receipt)
//           - Ghi so cai SoCaiKeToan:
//             + No TK 1121: Tong thuc nhan
//             + No TK 6427: Tong phi kenh
//             + Co TK 1388: Tong tien giao dich
//           - Kiem tra Invariant can doi SoCaiKeToan (Delta = 0)

#Region EventHandlers

Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	If DataExchange.Load Then
		Return;
	EndIf;
	
	// Tu dong tinh tong giao dich, phi kenh, thuc nhan tu bang ChiTietGiaoDich neu co
	If ChiTietGiaoDich.Count() > 0 Then
		TongGD = 0;
		TongPhi = 0;
		TongNhan = 0;
		
		For Each Row In ChiTietGiaoDich Do
			If Row.ThucNhan = 0 And Row.SoTien > 0 Then
				Row.ThucNhan = Row.SoTien - Row.PhiKenh;
			EndIf;
			TongGD = TongGD + Row.SoTien;
			TongPhi = TongPhi + Row.PhiKenh;
			TongNhan = TongNhan + Row.ThucNhan;
		EndDo;
		
		TongTienGiaoDich = TongGD;
		TongPhiKenh = TongPhi;
		TongThucNhan = TongNhan;
	Else
		// Neu khong nhap chi tiet thi tu dong can bang ThucNhan = TongTien - PhiKenh
		If TongThucNhan = 0 And TongTienGiaoDich > 0 Then
			TongThucNhan = TongTienGiaoDich - TongPhiKenh;
		EndIf;
	EndIf;
	
	// Cap nhat trang thai HoanTat trong BeforeWrite de luu vao CSDL
	If WriteMode = DocumentWriteMode.Posting Then
		TrangThai = "HoanTat";
	EndIf;
EndProcedure

Procedure Posting(Cancel, Mode)
	// 1. Kiem tra tinh hop le
	HasError = False;
	If Not ValueIsFilled(PhapNhan) Then
		HasError = True;
		Msg = New UserMessage;
		Msg.Text = NStr("vi = 'Trường Pháp nhân chưa được điền!'; en = 'Legal Entity is required!'");
		Msg.SetData(ThisObject);
		Msg.Field = "PhapNhan";
		Msg.Message();
	EndIf;
	If Not ValueIsFilled(KenhThanhToan) Then
		HasError = True;
		Msg = New UserMessage;
		Msg.Text = NStr("vi = 'Trường Kênh thanh toán chưa được điền!'; en = 'Payment Gateway is required!'");
		Msg.SetData(ThisObject);
		Msg.Field = "KenhThanhToan";
		Msg.Message();
	EndIf;
	If Not ValueIsFilled(TaiKhoanNganHang) Then
		HasError = True;
		Msg = New UserMessage;
		Msg.Text = NStr("vi = 'Trường Tài khoản ngân hàng chưa được điền!'; en = 'Bank Account is required!'");
		Msg.SetData(ThisObject);
		Msg.Field = "TaiKhoanNganHang";
		Msg.Message();
	EndIf;
	If TongTienGiaoDich <= 0 Then
		HasError = True;
		Msg = New UserMessage;
		Msg.Text = NStr("vi = 'Tổng tiền giao dịch đối soát phải lớn hơn 0!'; en = 'Reconciliation transaction amount must be greater than 0!'");
		Msg.SetData(ThisObject);
		Msg.Field = "TongTienGiaoDich";
		Msg.Message();
	EndIf;
	
	If HasError Then
		Cancel = True;
		Return;
	EndIf;
	
	NgayHachToan = BegOfDay(Date);
	TienTeVND = Catalogs.TienTe.FindByCode("VND");
	
	// 2. Ghi giam so du tren GiaoDichDienTuTamGiu (Expense)
	RegisterRecords.GiaoDichDienTuTamGiu.Write = True;
	If ChiTietGiaoDich.Count() > 0 Then
		For Each Row In ChiTietGiaoDich Do
			RecTamGiu = RegisterRecords.GiaoDichDienTuTamGiu.Add();
			RecTamGiu.RecordType = AccumulationRecordType.Expense;
			RecTamGiu.Period = NgayHachToan;
			RecTamGiu.PhapNhan = PhapNhan;
			RecTamGiu.KenhThanhToan = KenhThanhToan;
			RecTamGiu.MaGiaoDichKenh = Row.MaGiaoDichKenh;
			RecTamGiu.SoTien = Row.SoTien;
			RecTamGiu.PhiKenh = Row.PhiKenh;
		EndDo;
	Else
		RecTamGiu = RegisterRecords.GiaoDichDienTuTamGiu.Add();
		RecTamGiu.RecordType = AccumulationRecordType.Expense;
		RecTamGiu.Period = NgayHachToan;
		RecTamGiu.PhapNhan = PhapNhan;
		RecTamGiu.KenhThanhToan = KenhThanhToan;
		RecTamGiu.MaGiaoDichKenh = Number;
		RecTamGiu.SoTien = TongTienGiaoDich;
		RecTamGiu.PhiKenh = TongPhiKenh;
	EndIf;
	
	// 3. Ghi tang tien tren DongTien (Receipt)
	RegisterRecords.DongTien.Write = True;
	RecDT = RegisterRecords.DongTien.Add();
	RecDT.RecordType = AccumulationRecordType.Receipt;
	RecDT.Period = NgayHachToan;
	RecDT.PhapNhan = PhapNhan;
	RecDT.TaiKhoanTien = TaiKhoanNganHang;
	RecDT.KhoanMucDongTien = KhoanMucDongTien;
	RecDT.TienTe = TienTeVND;
	RecDT.SoTien = TongThucNhan;
	RecDT.SoTienNgoaiTe = 0;
	
	// 4. Ghi so cai SoCaiKeToan
	RegisterRecords.SoCaiKeToan.Write = True;
	
	TK1121 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1121");
	TK6427 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("6427");
	TK1388 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1388");
	
	// But toan 1: Thuc nhan tien ve ngan hang
	// No 1121 / Co 1388: TongThucNhan
	Row1 = RegisterRecords.SoCaiKeToan.Add();
	Row1.Period = NgayHachToan;
	Row1.AccountDr = TK1121;
	Row1.AccountCr = TK1388;
	Row1.SoTien = TongThucNhan;
	Row1.DienGiai = StrTemplate("Thu tiền cổng thanh toán %1 theo bảng kê %2", KenhThanhToan, Number);
	Row1.PhapNhan = PhapNhan;
	Row1.TienTe = TienTeVND;
	Row1.ChungTuGoc = Ref;
	Row1.TyGia = 1;
	
	// But toan 2: Phi kenh thanh toan
	// No 6427 / Co 1388: TongPhiKenh
	If TongPhiKenh > 0 Then
		Row2 = RegisterRecords.SoCaiKeToan.Add();
		Row2.Period = NgayHachToan;
		Row2.AccountDr = TK6427;
		Row2.AccountCr = TK1388;
		Row2.SoTien = TongPhiKenh;
		Row2.DienGiai = StrTemplate("Phí dịch vụ cổng thanh toán %1 theo bảng kê %2", KenhThanhToan, Number);
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
		WriteLogEvent("Posting.BangKeDoiSoatKenhThanhToan", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
	EndTry;
EndProcedure

#EndRegion
