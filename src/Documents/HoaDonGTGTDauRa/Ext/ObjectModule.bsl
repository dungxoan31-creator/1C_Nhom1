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
	
	// Kiem tra du lieu bat buoc
	If Not ValueIsFilled(PhapNhan) Or Not ValueIsFilled(DoiTac) Or Not ValueIsFilled(HopDong) Or Not ValueIsFilled(BienBanNghiemThu) Then
		Cancel = True;
		Msg = New UserMessage;
		Msg.Text = NStr("vi = 'Thiếu thông tin bắt buộc: Pháp nhân, Đối tác, Hợp đồng hoặc Biên bản nghiệm thu!'; en = 'Mandatory attributes missing: Legal Entity, Counterparty, Contract, or Acceptance Report!'");
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
	
	// -------------------------------------------------------------------------
	// 1. Ghi Sổ Tích Lũy CongNoPhaiThu (AR Subledger)
	//    - Loai ghi so: Receipt (Ghi tang cong no phai thu)
	//    - BẮT BUỘC ChungTuGoc = BienBanNghiemThuGiaiDoan de bao toan khop noi theo dot!
	// -------------------------------------------------------------------------
	RegisterRecords.CongNoPhaiThu.Write = True;
	RecordAR = RegisterRecords.CongNoPhaiThu.Add();
	RecordAR.RecordType = AccumulationRecordType.Receipt;
	RecordAR.Period = Date;
	RecordAR.PhapNhan = PhapNhan;
	RecordAR.DoiTac = DoiTac;
	RecordAR.HopDong = HopDong;
	RecordAR.ChungTuGoc = BienBanNghiemThu; // Rang buoc then chot P0.1
	RecordAR.SoTien = TienThueVAT;
	RecordAR.SoTienNgoaiTe = 0;
	
	// -------------------------------------------------------------------------
	// 2. Ghi Sổ Cái Kế Toán SoCaiKeToan (General Ledger)
	//    - But toan kep: No TK 1312 (hoac 1311) / Co TK 33311: So tien = TienThueVAT
	//    - ChungTuGoc = BienBanNghiemThuGiaiDoan
	// -------------------------------------------------------------------------
	RegisterRecords.SoCaiKeToan.Write = True;
	RecordGL = RegisterRecords.SoCaiKeToan.Add();
	RecordGL.Period = Date;
	RecordGL.AccountDr = TKCongNo;
	RecordGL.AccountCr = TKThueVAT;
	RecordGL.PhapNhan = PhapNhan;
	
	If ValueIsFilled(HopDong) And ValueIsFilled(HopDong.DongTienThanhToan) Then
		RecordGL.TienTe = HopDong.DongTienThanhToan;
	Else
		RecordGL.TienTe = Catalogs.TienTe.FindByCode("VND");
	EndIf;
	
	RecordGL.ChungTuGoc = BienBanNghiemThu;
	RecordGL.TyGia = 1;
	RecordGL.SoTien = TienThueVAT;
	
	If Not IsBlankString(DienGiai) Then
		RecordGL.DienGiai = DienGiai;
	Else
		RecordGL.DienGiai = StrTemplate("Thuế GTGT đầu ra theo HĐ %1 ký hiệu %2", SoHoaDon, KyHieu);
	EndIf;
	
	// -------------------------------------------------------------------------
	// 3. Kiem tra Invariant can doi tien te tren but toan GL
	//    Tong No = Tong Co = TienThueVAT (Can doi tuyet doi)
	// -------------------------------------------------------------------------
	Try
		EntriesGL = New Array;
		EntriesGL.Add(New Structure("AmountDr,AmountCr", TienThueVAT, TienThueVAT));
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
