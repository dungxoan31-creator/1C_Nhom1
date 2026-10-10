// Document: DieuChinhCongNo
// Du an: VinSmart Future - AR & AP Management
// Nen platform: 1C:Enterprise 8.3 (BSL / Managed Application)
// Chuc nang: Xu ly tranh chap sau ghi so va thoa thuan sai sot theo Nghi dinh 70/2025/ND-CP & ND 123/2020.
//            P0.3 Invariant: Chung tu DieuChinhCongNo la CHUNG TU DUY NHAT sinh but toan ghi so!
//            - Hoa don GTGT dieu chinh (TrangThaiHDDT = DaDieuChinh) la chung tu phap ly dien tu (Non-posting).
//            - So cai SoCaiKeToan (But toan kep gop duy nhat):
//              + No TK 5113: Giam doanh thu thuan (18.181.818 VND tren vi du 20tr da gom VAT)
//              + No TK 33311: Giam thue GTGT dau ra (1.818.182 VND tren vi du 20tr da gom VAT)
//              + Co TK 1312 (hoac 1311): Tong giam cong no dung 20.000.000 VND (tuyet doi khong bi doi thanh 21.818.182 VND).
//            - So tich luy CongNoPhaiThu (Subledger AR):
//              + RecordType: Expense (Giam so du cong no phai thu)
//              + So tien = TongTienGiam (20.000.000 VND)
//              + ChungTuGoc = BienBanNghiemThuGiaiDoan (Bao toan dong bo theo dot nghiem thu goc)

#Region EventHandlers

Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	If DataExchange.Load Then
		Return;
	EndIf;
	
	// Thue suat mac dinh la 10% neu chua nhap
	If ThueSuatVAT = 0 Then
		ThueSuatVAT = 10;
	EndIf;
	
	// Tu dong boc tach Doanh thu giam va Thue VAT giam
	If TongTienGiam > 0 Then
		If GiamDoanhThu = 0 Then
			TyLeHeSo = 1 + ThueSuatVAT / 100;
			GiamDoanhThu = Round(TongTienGiam / TyLeHeSo, 0);
		EndIf;
		If GiamThueVAT = 0 Then
			GiamThueVAT = TongTienGiam - GiamDoanhThu;
		EndIf;
	ElsIf GiamDoanhThu > 0 Then
		If GiamThueVAT = 0 Then
			GiamThueVAT = Round(GiamDoanhThu * ThueSuatVAT / 100, 0);
		EndIf;
		TongTienGiam = GiamDoanhThu + GiamThueVAT;
	EndIf;
	
	// Gan trang thai mac dinh khi ghi so
	If WriteMode = DocumentWriteMode.Posting And Not ValueIsFilled(TrangThai) Then
		TrangThai = Enums.TrangThaiNghiemThuAR.DaGhiSo;
	EndIf;
EndProcedure

Procedure Posting(Cancel, Mode)
	// 1. Kiem tra tinh hop le cua du lieu bat buoc
	If Not ValueIsFilled(PhapNhan) Or Not ValueIsFilled(DoiTac) Or Not ValueIsFilled(HopDong) Or Not ValueIsFilled(BienBanNghiemThu) Then
		Cancel = True;
		MessageText = NStr("vi = 'Thiếu thông tin bắt buộc: Pháp nhân, Đối tác, Hợp đồng hoặc Biên bản nghiệm thu!'; en = 'Mandatory attributes missing: Legal Entity, Counterparty, Contract, or Acceptance Report!'");
		Raise MessageText;
		Return;
	EndIf;
	
	If TongTienGiam <= 0 Then
		Cancel = True;
		MessageText = NStr("vi = 'Tổng tiền giảm công nợ phải lớn hơn 0!'; en = 'Total reduction amount must be greater than 0!'");
		Raise MessageText;
		Return;
	EndIf;
	
	// 2. Xac dinh tai khoan ke toan
	// - DoiTac noi bo Vingroup (LaBenLienKet = True) -> TK 1312
	// - DoiTac ben ngoai (LaBenLienKet = False)     -> TK 1311
	TKCongNo = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1311");
	If ValueIsFilled(DoiTac) And DoiTac.LaBenLienKet Then
		TKCongNo = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1312");
	EndIf;
	
	TKDoanhThu = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("5113");
	TKThueVAT = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("33311");
	
	// Xac dinh dong tien hach toan
	If ValueIsFilled(HopDong) And ValueIsFilled(HopDong.DongTienThanhToan) Then
		TienTeHachToan = HopDong.DongTienThanhToan;
	Else
		TienTeHachToan = Catalogs.TienTe.FindByCode("VND");
	EndIf;
	
	// Noi dung dien giai
	DienGiaiChung = DienGiai;
	If IsBlankString(DienGiaiChung) Then
		If ValueIsFilled(SoVanBanThoaThuan) Then
			DienGiaiChung = StrTemplate("Điều chỉnh giảm công nợ theo VBTT %1", SoVanBanThoaThuan);
		Else
			DienGiaiChung = StrTemplate("Điều chỉnh giảm công nợ chứng từ %1", Number);
		EndIf;
	EndIf;
	
	// -------------------------------------------------------------------------
	// 3. Ghi Sổ Tích Lũy CongNoPhaiThu (AR Subledger)
	//    - Loai ghi so: Expense (Ghi giam so du cong no phai thu)
	//    - BẮT BUỘC ChungTuGoc = BienBanNghiemThu de giam tru dung dot nghiem thu goc!
	// -------------------------------------------------------------------------
	RegisterRecords.CongNoPhaiThu.Write = True;
	RecordAR = RegisterRecords.CongNoPhaiThu.Add();
	RecordAR.RecordType = AccumulationRecordType.Expense;
	RecordAR.Period = Date;
	RecordAR.PhapNhan = PhapNhan;
	RecordAR.DoiTac = DoiTac;
	RecordAR.HopDong = HopDong;
	RecordAR.ChungTuGoc = BienBanNghiemThu; // Rang buoc then chot P0.3
	RecordAR.SoTien = TongTienGiam;
	RecordAR.SoTienNgoaiTe = 0;
	
	// -------------------------------------------------------------------------
	// 4. Ghi Sổ Cái Kế Toán SoCaiKeToan (General Ledger)
	//    - But toan kep gop duy nhat:
	//      * Dong 1: No TK 5113 / Co TKCongNo (1312 hoac 1311): SoTien = GiamDoanhThu
	//      * Dong 2: No TK 33311 / Co TKCongNo (1312 hoac 1311): SoTien = GiamThueVAT
	//    - Tong phat sinh Co TKCongNo = GiamDoanhThu + GiamThueVAT = TongTienGiam!
	// -------------------------------------------------------------------------
	RegisterRecords.SoCaiKeToan.Write = True;
	
	// Dong 1: Giam Doanh thu thuan
	RecordGL1 = RegisterRecords.SoCaiKeToan.Add();
	RecordGL1.Period = Date;
	RecordGL1.AccountDr = TKDoanhThu;
	RecordGL1.AccountCr = TKCongNo;
	RecordGL1.PhapNhan = PhapNhan;
	RecordGL1.TienTe = TienTeHachToan;
	RecordGL1.ChungTuGoc = BienBanNghiemThu;
	RecordGL1.TyGia = 1;
	RecordGL1.SoTien = GiamDoanhThu;
	RecordGL1.SoTienNgoaiTe = 0;
	RecordGL1.DienGiai = DienGiaiChung + " (Giảm doanh thu dịch vụ)";
	
	// Dong 2: Giam Thue GTGT dau ra
	RecordGL2 = RegisterRecords.SoCaiKeToan.Add();
	RecordGL2.Period = Date;
	RecordGL2.AccountDr = TKThueVAT;
	RecordGL2.AccountCr = TKCongNo;
	RecordGL2.PhapNhan = PhapNhan;
	RecordGL2.TienTe = TienTeHachToan;
	RecordGL2.ChungTuGoc = BienBanNghiemThu;
	RecordGL2.TyGia = 1;
	RecordGL2.SoTien = GiamThueVAT;
	RecordGL2.SoTienNgoaiTe = 0;
	RecordGL2.DienGiai = DienGiaiChung + " (Giảm thuế GTGT đầu ra)";
	
	// -------------------------------------------------------------------------
	// 5. Kiem tra can doi he thong (Invariant Checking)
	//    Tong No = Tong Co = TongTienGiam
	// -------------------------------------------------------------------------
	Try
		EntriesGL = New Array;
		EntriesGL.Add(New Structure("AmountDr,AmountCr", GiamDoanhThu, GiamDoanhThu));
		EntriesGL.Add(New Structure("AmountDr,AmountCr", GiamThueVAT, GiamThueVAT));
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

// Ham ho tro lay tai khoan cong no theo phan loai doi tac
Function LayTaiKhoanCongNoTheoDoiTac(Val DoiTacRef) Export
	If ValueIsFilled(DoiTacRef) And DoiTacRef.LaBenLienKet Then
		Return ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1312");
	EndIf;
	Return ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1311");
EndFunction

// Ham ho tro tinh toan boc tach doanh thu va thue VAT tu tong so tien giam
Function TinhToanBocTachGiamGia(Val TongTienGiam, Val ThueSuatVAT = 10) Export
	Result = New Structure("GiamDoanhThu,GiamThueVAT,TongTienGiam", 0, 0, TongTienGiam);
	If TongTienGiam > 0 Then
		TyLeHeSo = 1 + ThueSuatVAT / 100;
		Result.GiamDoanhThu = Round(TongTienGiam / TyLeHeSo, 0);
		Result.GiamThueVAT = TongTienGiam - Result.GiamDoanhThu;
	EndIf;
	Return Result;
EndFunction

#EndRegion
