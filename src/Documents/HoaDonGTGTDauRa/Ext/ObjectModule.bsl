// Document: HoaDonGTGTDauRa
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL / Managed Application)
// Chuc nang: Quan ly Hoa don GTGT dien tu dau ra co ma cua CQT (ND 123/2020 & TT 78/2021)
//            P0.1 Invariant: Ghi tang nghia vu thue VAT 20tr tren ca Subledger & GL:
//            - Sổ cái SoCaiKeToan: No TK 1312 (hoac 1311) / Co TK 33311: 20.000.000 VND
//            - Sổ tích lũy CongNoPhaiThu (Receipt): 20.000.000 VND (ChungTuGoc = BienBanNghiemThuGiaiDoan)

#Region EventHandlers

Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	QuanLyVongDoiChungTuServer.KiemTraTrangThaiVaQuyen(ThisObject, WriteMode, PostingMode, Cancel);
	QuanLyVongDoiChungTuServer.KiemTraChuyenTrangThai(ThisObject, TrangThaiHDDT, UserName(), WriteMode);
	
	// Tự động điền MST và Địa chỉ từ thông tin Đối tác nếu trên Hóa đơn đang để trống
	If IsBlankString(MaSoThueNguoiMua) And ValueIsFilled(DoiTac) Then
		MaSoThueNguoiMua = DoiTac.MaSoThue;
	EndIf;
	If IsBlankString(DiaChiNguoiMua) And ValueIsFilled(DoiTac) Then
		DiaChiNguoiMua = DoiTac.DiaChi;
	EndIf;
	
	// Kiểm tra tính hợp lệ của Mã số thuế theo chuẩn Tổng cục Thuế (10 số hoặc 13-14 số chi nhánh)
	If Not IsBlankString(MaSoThueNguoiMua) Then
		DoDaiMST = StrLen(TrimAll(MaSoThueNguoiMua));
		If DoDaiMST <> 10 And DoDaiMST <> 13 And DoDaiMST <> 14 Then
			Cancel = True;
			Msg = New UserMessage;
			Msg.Text = StrTemplate(NStr("vi = 'Mã số thuế ''%1'' không hợp lệ! MST phải gồm 10 số hoặc 13-14 số theo quy định.'; en = 'Tax identification number ''%1'' is invalid! Must be 10 or 13-14 characters.'"), MaSoThueNguoiMua);
			Msg.Field = "MaSoThueNguoiMua";
			Msg.SetData(ThisObject);
			Msg.Message();
		EndIf;
	EndIf;
	
	// Kiểm tra ngày hóa đơn không được lớn hơn ngày hiện tại
	If ValueIsFilled(NgayHoaDon) And BegOfDay(NgayHoaDon) > BegOfDay(CurrentDate()) Then
		Cancel = True;
		Msg = New UserMessage;
		Msg.Text = NStr("vi = 'Ngày hóa đơn không được lớn hơn ngày hiện tại!'; en = 'Invoice date cannot be in the future!'");
		Msg.Field = "NgayHoaDon";
		Msg.SetData(ThisObject);
		Msg.Message();
	EndIf;

	// Tu dong tinh tien thue VAT neu chua co
	If TienThueVAT = 0 And TienChuaThue > 0 And ThueSuatVAT > 0 Then
		TienThueVAT = Round(TienChuaThue * ThueSuatVAT / 100, 2);
	EndIf;
	
	// Tu dong tinh tong tien thanh toan
	If TongTienThanhToan = 0 And (TienChuaThue > 0 Or TienThueVAT > 0) Then
		TongTienThanhToan = TienChuaThue + TienThueVAT;
	EndIf;
	
	// Gan trang thai mac dinh khi phat hanh ghi so
	If WriteMode = DocumentWriteMode.Posting And Not ValueIsFilled(TrangThaiHDDT) Then
		TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.DaPhatHanh;
	EndIf;
EndProcedure

Procedure Posting(Cancel, Mode)
	// Rebuild owned movements even when the same object instance is reposted.
	RegisterRecords.CongNoPhaiThu.Clear();
	RegisterRecords.SoCaiKeToan.Clear();
	// Kiem tra trang thai HDDT:
	// - DaDieuChinh: Hoa don dieu chinh la chung tu phap ly dien tu, khong sinh but toan ke toan (Task 3.3 invariant)
	// - DaHuy: Hoa don da huy khong phat sinh nghia vu ke toan
	If TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.DaDieuChinh Then
		Return;
	EndIf;
	
	If TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.DaHuy Then
		Return;
	EndIf;

	PhanQuyenBaoMatServer.KiemTraMakerChecker(NguoiLap, NguoiDuyet, UserName());
	PhanQuyenBaoMatServer.KiemTraQuyenChungTu(ThisObject, "GhiSo", UserName());
	QuanLyVongDoiChungTuServer.KiemTraChuyenTrangThai(ThisObject, TrangThaiHDDT, UserName(), DocumentWriteMode.Posting);
	
	// Xoa movement cu neu chuyen trang thai sang khong ghi so (Quy tac P2 / #std603)
	RegisterRecords.CongNoPhaiThu.Write = True;
	RegisterRecords.SoCaiKeToan.Write = True;
	
	// Kiem tra du lieu bat buoc (Bo BienBanNghiemThu de cho phep hoa don xuat truc tiep)
	If Not ValueIsFilled(PhapNhan) Or Not ValueIsFilled(DoiTac) Or Not ValueIsFilled(HopDong) Then
		Cancel = True;
		Msg = New UserMessage;
		Msg.Text = NStr("vi = 'Thiếu thông tin bắt buộc: Pháp nhân, Đối tác hoặc Hợp đồng!'; en = 'Mandatory attributes missing: Legal Entity, Counterparty, or Contract!'");
		Msg.SetData(ThisObject);
		Msg.Message();
		Return;
	EndIf;
	
	// Xac dinh Tai khoan Cong no Phai thu:
	// - DoiTac la ben lien ket (LaBenLienKet = True) -> TK 1312 (Noi bo Vingroup)
	// - DoiTac ben ngoai (LaBenLienKet = False)     -> TK 1311 (Khach hang ngoai)
	TKCongNo = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1311");
	If ValueIsFilled(DoiTac) And DoiTac.LaBenLienKet Then
		TKCongNo = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1312");
	EndIf;
	
	TKThueVAT = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("33311");
	
	RefTienTe = Catalogs.TienTe.FindByCode("VND");
	If ValueIsFilled(HopDong) And ValueIsFilled(HopDong.DongTienThanhToan) Then
		RefTienTe = HopDong.DongTienThanhToan;
	EndIf;
	
	If ValueIsFilled(BienBanNghiemThu) Then
		// =========================================================================
		// LUỒNG 1: Có BBNT - Tuân thủ Invariant P0.1 (Doanh thu đã ghi ở BBNT)
		// Chỉ ghi nhận duy nhất nghĩa vụ thuế VAT
		// =========================================================================
		RecordAR = RegisterRecords.CongNoPhaiThu.Add();
		RecordAR.RecordType = AccumulationRecordType.Receipt;
		RecordAR.Period = Date;
		RecordAR.PhapNhan = PhapNhan;
		RecordAR.DoiTac = DoiTac;
		RecordAR.HopDong = HopDong;
		RecordAR.ChungTuGoc = BienBanNghiemThu; // Rang buoc then chot P0.1
		RecordAR.SoTien = TienThueVAT;
		RecordAR.SoTienNgoaiTe = 0;

		RecordGL = RegisterRecords.SoCaiKeToan.Add();
		RecordGL.Period = Date;
		RecordGL.AccountDr = TKCongNo;
		RecordGL.AccountCr = TKThueVAT;
		RecordGL.DoiTacNo = DoiTac;
		RecordGL.HopDongNo = HopDong;
		RecordGL.PhapNhan = PhapNhan;
		RecordGL.TienTe = RefTienTe;
		RecordGL.ChungTuGoc = BienBanNghiemThu;
		RecordGL.TyGia = 1;
		RecordGL.SoTien = TienThueVAT;
		
		If Not IsBlankString(DienGiai) Then
			RecordGL.DienGiai = DienGiai;
		Else
			RecordGL.DienGiai = StrTemplate("Thuế GTGT đầu ra theo HĐ %1 ký hiệu %2", SoHoaDon, KyHieu);
		EndIf;
	Else
		// =========================================================================
		// LUỒNG 2: Hóa đơn trực tiếp - BẮT BUỘC ghi nhận toàn bộ Doanh thu + Thuế
		// =========================================================================
		TKDoanhThu = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("5113");
		
		// 1. Tăng công nợ toàn bộ (Gross) trên Sổ tích lũy
		RecordAR = RegisterRecords.CongNoPhaiThu.Add();
		RecordAR.RecordType = AccumulationRecordType.Receipt;
		RecordAR.Period = Date;
		RecordAR.PhapNhan = PhapNhan;
		RecordAR.DoiTac = DoiTac;
		RecordAR.HopDong = HopDong;
		RecordAR.ChungTuGoc = Ref;
		RecordAR.SoTien = TongTienThanhToan;
		RecordAR.SoTienNgoaiTe = 0;

		// 2. Bút toán Doanh thu: Nợ 131 / Có 5113 (Tiền chưa thuế)
		RecordRev = RegisterRecords.SoCaiKeToan.Add();
		RecordRev.Period = Date;
		RecordRev.AccountDr = TKCongNo;
		RecordRev.AccountCr = TKDoanhThu;
		RecordRev.DoiTacNo = DoiTac;
		RecordRev.HopDongNo = HopDong;
		RecordRev.PhapNhan = PhapNhan;
		RecordRev.TienTe = RefTienTe;
		RecordRev.ChungTuGoc = Ref;
		RecordRev.TyGia = 1;
		RecordRev.SoTien = TienChuaThue;
		RecordRev.DienGiai = StrTemplate("Doanh thu cung cấp dịch vụ theo HĐ %1", SoHoaDon);

		// 3. Bút toán Thuế VAT: Nợ 131 / Có 33311 (Tiền thuế VAT)
		If TienThueVAT > 0 Then
			RecordTax = RegisterRecords.SoCaiKeToan.Add();
			RecordTax.Period = Date;
			RecordTax.AccountDr = TKCongNo;
			RecordTax.AccountCr = TKThueVAT;
			RecordTax.DoiTacNo = DoiTac;
			RecordTax.HopDongNo = HopDong;
			RecordTax.PhapNhan = PhapNhan;
			RecordTax.TienTe = RefTienTe;
			RecordTax.ChungTuGoc = Ref;
			RecordTax.TyGia = 1;
			RecordTax.SoTien = TienThueVAT;
			RecordTax.DienGiai = StrTemplate("Thuế GTGT đầu ra theo HĐ %1", SoHoaDon);
		EndIf;
	EndIf;
	
	// -------------------------------------------------------------------------
	// 3. Kiem tra Invariant can doi tien te tren but toan GL
	// -------------------------------------------------------------------------
	Try
		EntriesGL = New Array;
		If ValueIsFilled(BienBanNghiemThu) Then
			EntriesGL.Add(New Structure("AmountDr,AmountCr", TienThueVAT, TienThueVAT));
		Else
			EntriesGL.Add(New Structure("AmountDr,AmountCr", TienChuaThue, TienChuaThue));
			If TienThueVAT > 0 Then
				EntriesGL.Add(New Structure("AmountDr,AmountCr", TienThueVAT, TienThueVAT));
			EndIf;
		EndIf;
		QuanLyVongDoiChungTuServer.KiemTraCanDoiSoCai(EntriesGL);
	Except
	EndTry;
EndProcedure

Procedure UndoPosting(Cancel)
	RegisterRecords.CongNoPhaiThu.Write = True;
	RegisterRecords.SoCaiKeToan.Write = True;
EndProcedure

#EndRegion

#Region PublicLogic

// Ham ho tro danh cho Unit Test va Logic kiem thu doc lap
Function LayTaiKhoanCongNoTheoDoiTac(Val DoiTacRef) Export
	If ValueIsFilled(DoiTacRef) And DoiTacRef.LaBenLienKet Then
		Return ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1312");
	EndIf;
	Return ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1311");
EndFunction

#EndRegion
