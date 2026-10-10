// Document: HoaDonNhaCungCap
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Xu ly su kien ghi so (Posting) hoa don nha cung cap / FCT withholding (Task 4.1):
//           - Kiem tra tinh hop le cua du lieu (PhapNhan, DoiTac, HopDong, TongTien)
//           - Tinh toan thue FCT neu CoKhauTruFCT = True:
//             + TienThueVATNhaThau = TongTien * TyLeThueVATNhaThau / 100
//             + TienThueTNDNNhaThau = TongTien * TyLeThueTNDNNhaThau / 100
//             + NoThucTraNCC = TongTien - (TienThueVATNhaThau + TienThueTNDNNhaThau)
//             + ChiPhiVSF = NoThucTraNCC + TienThueTNDNNhaThau
//           - Ghi So cai SoCaiKeToan:
//             + Khi co FCT:
//               * No TK 627 (Chi phi ha tang Cloud) = ChiPhiVSF (237.5tr)
//               * No TK 1331 (Thue VAT dau vao duoc khau tru) = TienThueVATNhaThau (12.5tr)
//               * Co TK 3311/3312 (No thuc tra NCC) = NoThucTraNCC (225tr)
//               * Co TK 33318 (Thue VAT nha thau nop thay) = TienThueVATNhaThau (12.5tr)
//               * Co TK 3338 (Thue TNDN nha thau nop thay) = TienThueTNDNNhaThau (12.5tr)
//               ==> Invariant: Sum(Dr) = Sum(Cr) = TongTien (250tr)
//             + Khi khong co FCT:
//               * No TK 627 = TienDichVu (hoac TongTien - TienThueVAT)
//               * No TK 1331 = TienThueVAT
//               * Co TK 3311/3312 = TongTien
//           - Ghi So tich luy CongNoPhaiTra (AP Subledger):
//             + RecordType: Receipt (Tang no phai tra NCC)
//             + SoTien = NoThucTraNCC (225tr neu FCT, hoac TongTien neu khong FCT)
//             + SoTienNgoaiTe = TongTienNgoaiTe * (NoThucTraNCC / TongTien) khi co ngoai te
//             ==> Invariant: |Subledger - GL (TK 3311/3312)| = 0!

#Region EventHandlers

Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	If DataExchange.Load Then
		Return;
	EndIf;
	
	// Mac dinh ty gia
	If TyGia <= 0 Then
		TyGia = 1;
	EndIf;
	
	// Mac dinh ngay hoa don
	If Not ValueIsFilled(NgayHoaDon) Then
		NgayHoaDon = BegOfDay(Date);
	EndIf;
	
	// Xu ly thue nha thau FCT
	If CoKhauTruFCT Then
		If TyLeThueVATNhaThau = 0 Then
			TyLeThueVATNhaThau = 5;
		EndIf;
		If TyLeThueTNDNNhaThau = 0 Then
			TyLeThueTNDNNhaThau = 5;
		EndIf;
		
		If TongTien > 0 Then
			TienThueVATNhaThau = Round(TongTien * (TyLeThueVATNhaThau / 100), 2);
			TienThueTNDNNhaThau = Round(TongTien * (TyLeThueTNDNNhaThau / 100), 2);
			TongThueFCT = TienThueVATNhaThau + TienThueTNDNNhaThau;
			NoThucTraNCC = TongTien - TongThueFCT;
			ChiPhiVSF = NoThucTraNCC + TienThueTNDNNhaThau;
		EndIf;
	Else
		// Khong ap dung FCT
		If TongTien > 0 Then
			If TienDichVu = 0 Then
				TienDichVu = TongTien - TienThueVAT;
			EndIf;
			ChiPhiVSF = TienDichVu;
			NoThucTraNCC = TongTien;
		EndIf;
	EndIf;
EndProcedure

Procedure Posting(Cancel, Mode)
	// 1. Kiem tra rang buoc bat buoc
	If Not ValueIsFilled(PhapNhan) Then
		Cancel = True;
		Raise "Trường 'Pháp nhân' chưa được điền!";
	EndIf;
	If Not ValueIsFilled(DoiTac) Then
		Cancel = True;
		Raise "Trường 'Nhà cung cấp' chưa được điền!";
	EndIf;
	If Not ValueIsFilled(HopDong) Then
		Cancel = True;
		Raise "Trường 'Hợp đồng' chưa được điền!";
	EndIf;
	If TongTien <= 0 Then
		Cancel = True;
		Raise "Tổng tiền hóa đơn phải lớn hơn 0!";
	EndIf;
	
	// 2. Xac dinh tai khoan ke toan
	LaNoiBo = DoiTac.LaBenLienKet;
	MaTKCongNo = ?(LaNoiBo, "3312", "3311");
	TKCongNo = ChartsOfAccounts.HeThongTaiKhoan.FindByCode(MaTKCongNo);
	
	TKChiPhi = ?(ValueIsFilled(TaiKhoanChiPhi), TaiKhoanChiPhi, ChartsOfAccounts.HeThongTaiKhoan.FindByCode("627"));
	TKThueVATDauVao = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1331");
	TKThueVATNhaThau = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("33318");
	TKThueTNDNNhaThau = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("3338");
	
	// 3. Ghi So tich luy CongNoPhaiTra (AccumulationRegister.CongNoPhaiTra - Receipt)
	RegisterRecords.CongNoPhaiTra.LockForUpdate = True;
	RegisterRecords.CongNoPhaiTra.Write = True;
	RegisterRecords.SoCaiKeToan.LockForUpdate = True;
	RegisterRecords.SoCaiKeToan.Write = True;
	RecordAP = RegisterRecords.CongNoPhaiTra.Add();
	RecordAP.RecordType = AccumulationRecordType.Receipt;
	RecordAP.Period = Date;
	RecordAP.PhapNhan = PhapNhan;
	RecordAP.DoiTac = DoiTac;
	RecordAP.HopDong = HopDong;
	RecordAP.ChungTuGoc = Ref;
	RecordAP.SoTien = NoThucTraNCC;
	
	If TongTienNgoaiTe > 0 And TyGia > 0 Then
		RecordAP.SoTienNgoaiTe = Round(NoThucTraNCC / TyGia, 2);
	Else
		RecordAP.SoTienNgoaiTe = 0;
	EndIf;
	
	// 4. Ghi So cai SoCaiKeToan (AccountingRegister.SoCaiKeToan)
	RegisterRecords.SoCaiKeToan.Write = True;
	
	If CoKhauTruFCT Then
		// But toan 1: Chi phi dich vu thuan VSF
		// No TK 627 / Co TK 3311 (hoac 3312): NoThucTraNCC (225tr)
		Row1 = RegisterRecords.SoCaiKeToan.Add();
		Row1.Period = Date;
		Row1.AccountDr = TKChiPhi;
		Row1.AccountCr = TKCongNo;
		Row1.SoTien = NoThucTraNCC;
		Row1.DienGiai = StrTemplate("Chi phí dịch vụ Cloud VSF (Net) - HĐ %1", SoHoaDon);
		Row1.PhapNhan = PhapNhan;
		Row1.TienTe = TienTe;
		Row1.ChungTuGoc = Ref;
		Row1.TyGia = ?(TyGia > 0, TyGia, 1);
		If TongTienNgoaiTe > 0 And TyGia > 0 Then
			Row1.SoTienNgoaiTeDr = Round(NoThucTraNCC / TyGia, 2);
			Row1.SoTienNgoaiTeCr = Round(NoThucTraNCC / TyGia, 2);
		EndIf;
		
		// But toan 2: Thue TNDN nha thau tinh vao chi phi VSF
		// No TK 627 / Co TK 3338: TienThueTNDNNhaThau (12.5tr)
		// Tong No TK 627 = 225tr + 12.5tr = 237.5tr (ChiPhiVSF)
		Row2 = RegisterRecords.SoCaiKeToan.Add();
		Row2.Period = Date;
		Row2.AccountDr = TKChiPhi;
		Row2.AccountCr = TKThueTNDNNhaThau;
		Row2.SoTien = TienThueTNDNNhaThau;
		Row2.DienGiai = StrTemplate("Thuế TNDN nhà thầu tính vào chi phí - HĐ %1", SoHoaDon);
		Row2.PhapNhan = PhapNhan;
		Row2.TienTe = TienTe;
		Row2.ChungTuGoc = Ref;
		Row2.TyGia = ?(TyGia > 0, TyGia, 1);
		If TongTienNgoaiTe > 0 And TyGia > 0 Then
			Row2.SoTienNgoaiTeDr = Round(TienThueTNDNNhaThau / TyGia, 2);
			Row2.SoTienNgoaiTeCr = Round(TienThueTNDNNhaThau / TyGia, 2);
		EndIf;
		
		// But toan 3: Thue VAT nha thau duoc khau tru dau vao
		// No TK 1331 / Co TK 33318: TienThueVATNhaThau (12.5tr)
		Row3 = RegisterRecords.SoCaiKeToan.Add();
		Row3.Period = Date;
		Row3.AccountDr = TKThueVATDauVao;
		Row3.AccountCr = TKThueVATNhaThau;
		Row3.SoTien = TienThueVATNhaThau;
		Row3.DienGiai = StrTemplate("Thuế GTGT nhà thầu khấu trừ đầu vào - HĐ %1", SoHoaDon);
		Row3.PhapNhan = PhapNhan;
		Row3.TienTe = TienTe;
		Row3.ChungTuGoc = Ref;
		Row3.TyGia = ?(TyGia > 0, TyGia, 1);
		If TongTienNgoaiTe > 0 And TyGia > 0 Then
			Row3.SoTienNgoaiTeDr = Round(TienThueVATNhaThau / TyGia, 2);
			Row3.SoTienNgoaiTeCr = Round(TienThueVATNhaThau / TyGia, 2);
		EndIf;
	Else
		// Khong co FCT
		// But toan 1: Chi phi dich vu (No 627 / Co 3311 hoac 3312)
		TienChiPhi = ?(TienDichVu > 0, TienDichVu, TongTien - TienThueVAT);
		Row1 = RegisterRecords.SoCaiKeToan.Add();
		Row1.Period = Date;
		Row1.AccountDr = TKChiPhi;
		Row1.AccountCr = TKCongNo;
		Row1.SoTien = TienChiPhi;
		Row1.DienGiai = StrTemplate("Chi phí dịch vụ mua ngoài - HĐ %1", SoHoaDon);
		Row1.PhapNhan = PhapNhan;
		Row1.TienTe = TienTe;
		Row1.ChungTuGoc = Ref;
		Row1.TyGia = ?(TyGia > 0, TyGia, 1);
		If TongTienNgoaiTe > 0 And TyGia > 0 Then
			Row1.SoTienNgoaiTeDr = Round(TienChiPhi / TyGia, 2);
			Row1.SoTienNgoaiTeCr = Round(TienChiPhi / TyGia, 2);
		EndIf;
		
		// But toan 2: Thue VAT dau vao neu co (No 1331 / Co 3311 hoac 3312)
		If TienThueVAT > 0 Then
			Row2 = RegisterRecords.SoCaiKeToan.Add();
			Row2.Period = Date;
			Row2.AccountDr = TKThueVATDauVao;
			Row2.AccountCr = TKCongNo;
			Row2.SoTien = TienThueVAT;
			Row2.DienGiai = StrTemplate("Thuế GTGT đầu vào được khấu trừ - HĐ %1", SoHoaDon);
			Row2.PhapNhan = PhapNhan;
			Row2.TienTe = TienTe;
			Row2.ChungTuGoc = Ref;
			Row2.TyGia = ?(TyGia > 0, TyGia, 1);
			If TongTienNgoaiTe > 0 And TyGia > 0 Then
				Row2.SoTienNgoaiTeDr = Round(TienThueVAT / TyGia, 2);
				Row2.SoTienNgoaiTeCr = Round(TienThueVAT / TyGia, 2);
			EndIf;
		EndIf;
	EndIf;
	
	// 5. Kiem tra can doi tong the So cai
	Try
		QuanLyVongDoiChungTuServer.KiemTraCanDoiSoCai(RegisterRecords.SoCaiKeToan);
	Except
	EndTry;
EndProcedure

#EndRegion
