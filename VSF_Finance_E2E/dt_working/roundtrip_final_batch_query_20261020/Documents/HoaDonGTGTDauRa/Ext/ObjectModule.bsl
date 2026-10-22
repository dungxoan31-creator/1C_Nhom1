// Document: HoaDonGTGTDauRa
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL / Managed Application)
// Chuc nang: Quan ly Hoa don GTGT dien tu dau ra co ma cua CQT (ND 123/2020 & TT 78/2021)
//            P0.1 Invariant: Ghi tang nghia vu thue VAT 20tr tren ca Subledger & GL:
//            - Sổ cái SoCaiKeToan: No TK 1312 (hoac 1311) / Co TK 33311: 20.000.000 VND
//            - Sổ tích lũy CongNoPhaiThu (Receipt): 20.000.000 VND (ChungTuGoc = BienBanNghiemThuGiaiDoan)

#Region EventHandlers

Procedure Filling(FillingData, FillingText, StandardProcessing)
	If Not ValueIsFilled(Date) Then
		Date = CurrentSessionDate();
	EndIf;
	If IsBlankString(NguoiLap) Then
		NguoiLap = UserName();
	EndIf;
	If Not ValueIsFilled(PhapNhan) Then
		PhapNhan = Catalogs.PhapNhan.FindByCode("PN-VSF");
	EndIf;
	If Not ValueIsFilled(TrangThaiHDDT) Then
		TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.DuThao;
	EndIf;
	If Not ValueIsFilled(NgayHoaDon) Then
		NgayHoaDon = BegOfDay(CurrentSessionDate());
	EndIf;
	If ThueSuatVAT = 0 Then
		ThueSuatVAT = ThueGTGTClientServer.TyLeVATApDungTheoNgay(NgayHoaDon, ApDungGiamThueGTGT);
	EndIf;
	
	// Kế thừa dữ liệu từ Biên bản nghiệm thu giai đoạn (BasedOn)
	If TypeOf(FillingData) = Type("DocumentRef.BienBanNghiemThuGiaiDoan") Then
		BienBanNghiemThu = FillingData;
		PhapNhan = FillingData.PhapNhan;
		DoiTac = FillingData.DoiTac;
		HopDong = FillingData.HopDong;
		ApDungGiamThueGTGT = FillingData.ApDungGiamThueGTGT;
		TienChuaThue = FillingData.GiaTriNghiemThuChuaVAT;
		ThueSuatVAT = FillingData.TyLeVAT;
		TienThueVAT = FillingData.TienVAT;
		TongTienThanhToan = FillingData.TongGiaTri;
		DienGiai = StrTemplate("Xuất hóa đơn GTGT theo Biên bản nghiệm thu %1", FillingData.Number);
		If ValueIsFilled(DoiTac) Then
			MaSoThueNguoiMua = DoiTac.MaSoThue;
			DiaChiNguoiMua = DoiTac.DiaChi;
		EndIf;
	EndIf;
EndProcedure

Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	// [FIX B31] Huy ghi so: chi KTT/CFO va khong con chung tu khac tham chieu
	If WriteMode = DocumentWriteMode.UndoPosting Then
		QuanLyVongDoiChungTuServer.XuLyHuyGhiSo(ThisObject, Cancel);
		Return;
	EndIf;
	
	// [FIX B28] Nguoi lap do he thong ghi nhan, khong nhap tay
	QuanLyVongDoiChungTuServer.GanNguoiLapKhiTaoMoi(ThisObject, "NguoiLap");
	
	QuanLyVongDoiChungTuServer.KiemTraTrangThaiVaQuyen(ThisObject, WriteMode, PostingMode, Cancel);
	QuanLyVongDoiChungTuServer.KiemTraChuyenTrangThai(ThisObject, TrangThaiHDDT, UserName(), WriteMode);
	
	// Tự động điền MST và Địa chỉ từ thông tin Đối tác nếu trên Hóa đơn đang để trống
	If IsBlankString(MaSoThueNguoiMua) And ValueIsFilled(DoiTac) Then
		MaSoThueNguoiMua = DoiTac.MaSoThue;
	EndIf;
	If IsBlankString(DiaChiNguoiMua) And ValueIsFilled(DoiTac) Then
		DiaChiNguoiMua = DoiTac.DiaChi;
	EndIf;

	// Hoa don theo BBNT phai giu nguyen can cu tinh thue da duoc phe duyet tren chung tu nguon.
	If ValueIsFilled(BienBanNghiemThu) Then
		Acceptance = BienBanNghiemThu.GetObject();
		If Acceptance.DeletionMark Then
			Cancel = True;
			QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject,
				NStr("vi = 'Không thể dùng Biên bản nghiệm thu đã đánh dấu xóa để lập hóa đơn.'; en = 'A deleted acceptance certificate cannot be used as an invoice source.'"), "BienBanNghiemThu");
			Return;
		EndIf;
		ApDungGiamThueGTGT = Acceptance.ApDungGiamThueGTGT;
		TienChuaThue = Acceptance.GiaTriNghiemThuChuaVAT;
		ThueSuatVAT = Acceptance.TyLeVAT;
		TienThueVAT = Acceptance.TienVAT;
		TongTienThanhToan = Acceptance.TongGiaTri;
	ElsIf ApDungGiamThueGTGT Then
		ThueSuatVAT = ThueGTGTClientServer.TyLeVATApDungTheoNgay(NgayHoaDon, True);
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
	If ValueIsFilled(NgayHoaDon) And BegOfDay(NgayHoaDon) > BegOfDay(CurrentSessionDate()) Then
		Cancel = True;
		Msg = New UserMessage;
		Msg.Text = NStr("vi = 'Ngày hóa đơn không được lớn hơn ngày hiện tại!'; en = 'Invoice date cannot be in the future!'");
		Msg.Field = "NgayHoaDon";
		Msg.SetData(ThisObject);
		Msg.Message();
	EndIf;

	// [FIX B02] Luon tinh lai tien thue VAT theo thue suat hien tai (truoc day chi tinh khi VAT = 0,
	// nen doi thue suat sau lan luu dau thi VAT/Tong bi giu gia tri cu -> so chi tiet lech So cai)
	If TienChuaThue > 0 And ThueSuatVAT >= 0 Then
		TienThueVAT = Round(TienChuaThue * ThueSuatVAT / 100, 2);
	EndIf;
	
	// [FIX B02] Luon tinh lai tong tien thanh toan = tien chua thue + VAT
	If TienChuaThue > 0 Or TienThueVAT > 0 Then
		TongTienThanhToan = TienChuaThue + TienThueVAT;
	EndIf;
	
	// [FIX B29] Truoc day hoa don chua co trang thai bi tu gan "Da phat hanh" khi ghi so -> bo qua buoc ky so.
	// Nay bat buoc phai di qua Cho ky so -> Da phat hanh (do nguoi duyet thuc hien) roi moi ghi so.
	If WriteMode = DocumentWriteMode.Posting
		And TrangThaiHDDT <> Enums.TrangThaiHoaDonDienTu.DaPhatHanh Then
		Cancel = True;
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject,
			NStr("vi = 'Chỉ hóa đơn đã phát hành mới được ghi sổ. Hóa đơn đã hủy, điều chỉnh hoặc thay thế cần xử lý bằng chứng từ phù hợp.'; en = 'Only an issued invoice can be posted. Cancelled, adjusted, or replaced invoices require the corresponding correction document.'"), "TrangThaiHDDT");
	ElsIf Not ValueIsFilled(TrangThaiHDDT) Then
		TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.DuThao;
	EndIf;
EndProcedure

Procedure Posting(Cancel, Mode)
	// Rebuild owned movements even when the same object instance is reposted.
	RegisterRecords.CongNoPhaiThu.Clear();
	RegisterRecords.SoCaiKeToan.Clear();
	// [FIX B01] Danh dau ghi de NGAY SAU Clear(), TRUOC moi lenh Return: neu hoa don chuyen sang
	// trang thai khong ghi so thi tap ban ghi rong duoc ghi xuong, xoa but toan AR/VAT cu (Quy tac P2 / #std603).
	// Truoc day 2 dong nay nam sau cac lenh Return nen huy hoa don roi ghi so lai van con but toan cu.
	RegisterRecords.CongNoPhaiThu.Write = True;
	RegisterRecords.SoCaiKeToan.Write = True;
	If TrangThaiHDDT <> Enums.TrangThaiHoaDonDienTu.DaPhatHanh Then
		Cancel = True;
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject,
			NStr("vi = 'Chỉ hóa đơn đã phát hành mới được ghi sổ. Hóa đơn đã hủy, điều chỉnh hoặc thay thế cần xử lý bằng chứng từ phù hợp.'; en = 'Only an issued invoice can be posted. Cancelled, adjusted, or replaced invoices require the corresponding correction document.'"), "TrangThaiHDDT");
		Return;
	EndIf;
	
	PhanQuyenBaoMatServer.KiemTraMakerChecker(NguoiLap, NguoiDuyet, UserName());
	PhanQuyenBaoMatServer.KiemTraQuyenChungTu(ThisObject, "GhiSo", UserName());
	QuanLyVongDoiChungTuServer.KiemTraChuyenTrangThai(ThisObject, TrangThaiHDDT, UserName(), DocumentWriteMode.Posting);
	
	// [FIX B02] Tong thanh toan phai bang tien chua thue + VAT
	If Not ValueIsFilled(BienBanNghiemThu) And TongTienThanhToan <> TienChuaThue + TienThueVAT Then
		Cancel = True;
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject, StrTemplate(
			NStr("vi = 'Tổng tiền thanh toán (%1) phải bằng Tiền chưa thuế (%2) + Tiền thuế GTGT (%3)!'; en = 'Total (%1) must equal net amount (%2) + VAT (%3)!'"),
			TongTienThanhToan, TienChuaThue, TienThueVAT), "TongTienThanhToan");
		Return;
	EndIf;
	If Not ValueIsFilled(BienBanNghiemThu) And TienChuaThue <= 0 Then
		Cancel = True;
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject,
			NStr("vi = 'Hóa đơn xuất trực tiếp phải có Tiền chưa thuế lớn hơn 0!'; en = 'Direct invoice must have a positive net amount!'"), "TienChuaThue");
		Return;
	EndIf;
	
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
		Acceptance = BienBanNghiemThu.GetObject();
		If Acceptance.DeletionMark Or Not Acceptance.Posted Then
			Cancel = True;
			QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject,
				NStr("vi = 'Chỉ được ghi sổ hóa đơn từ Biên bản nghiệm thu chưa bị hủy và đã ghi sổ.'; en = 'An invoice can be posted only from an active, posted acceptance certificate.'"), "BienBanNghiemThu");
			Return;
		EndIf;
		// =========================================================================
		// LUỒNG 1: Có BBNT - Cơ chế chuyển dịch công nợ (Debt Transfer)
		// Phạm vi demo: 1 Biên bản nghiệm thu -> 1 Hóa đơn GTGT đầu ra
		// 1. Tất toán dứt điểm công nợ tạm tính của BBNT (Expense = Giá trị trước thuế)
		// 2. Chuyển dịch toàn bộ công nợ chính thức sang Hóa đơn GTGT (Receipt = Tổng tiền gồm VAT)
		// 3. Biến động ròng sổ phụ = Receipt(TongTien) - Expense(GiaTriChuaVAT) = TienThueVAT
		//    khớp 100% với biến động Sổ cái TK 1311 (Nợ 1311: TienThueVAT)
		// =========================================================================
		
		// 1. Xuất giảm toàn bộ nợ BBNT
		RecordAR_Clear = RegisterRecords.CongNoPhaiThu.Add();
		RecordAR_Clear.RecordType = AccumulationRecordType.Expense;
		RecordAR_Clear.Period = Date;
		RecordAR_Clear.PhapNhan = PhapNhan;
		RecordAR_Clear.DoiTac = DoiTac;
		RecordAR_Clear.HopDong = HopDong;
		RecordAR_Clear.ChungTuGoc = BienBanNghiemThu;
		RecordAR_Clear.SoTien = BienBanNghiemThu.GiaTriNghiemThuChuaVAT;
		RecordAR_Clear.SoTienNgoaiTe = 0;

		// 2. Tăng công nợ chính thức sang Hóa đơn GTGT
		RecordAR_New = RegisterRecords.CongNoPhaiThu.Add();
		RecordAR_New.RecordType = AccumulationRecordType.Receipt;
		RecordAR_New.Period = Date;
		RecordAR_New.PhapNhan = PhapNhan;
		RecordAR_New.DoiTac = DoiTac;
		RecordAR_New.HopDong = HopDong;
		RecordAR_New.ChungTuGoc = Ref;
		RecordAR_New.SoTien = TongTienThanhToan;
		RecordAR_New.SoTienNgoaiTe = 0;

		// 3. Bút toán thuế đầu ra chỉ phát sinh khi số thuế lớn hơn 0.
		// Kể cả VAT 0%, hai chuyển động AR bên trên vẫn phải chuyển số dư từ BBNT sang hóa đơn.
		If TienThueVAT > 0 Then
			RecordGL = RegisterRecords.SoCaiKeToan.Add();
			RecordGL.Period = Date;
			RecordGL.AccountDr = TKCongNo;
			RecordGL.AccountCr = TKThueVAT;
			RecordGL.DoiTacNo = DoiTac;
			RecordGL.HopDongNo = HopDong;
			RecordGL.PhapNhan = PhapNhan;
			RecordGL.TienTe = RefTienTe;
			RecordGL.ChungTuGoc = Ref;
			RecordGL.TyGia = 1;
			RecordGL.SoTien = TienThueVAT;
			
			If Not IsBlankString(DienGiai) Then
				RecordGL.DienGiai = DienGiai;
			Else
				RecordGL.DienGiai = StrTemplate("Thuế GTGT đầu ra theo HĐ %1 ký hiệu %2 (Chuyển dịch công nợ BBNT -> HĐ)", SoHoaDon, KyHieu);
			EndIf;
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
	// [FIX B03/B39] Truoc day: Try ... Except EndTry nuot loi va so sanh cap No = Co tu dung nen khong bao gio
	// phat hien lech. Nay doi chieu that su so chi tiet CongNoPhaiThu voi So cai TK 131x; lech thi huy ghi so.
	QuanLyVongDoiChungTuServer.KiemTraKhopGLVaSoPhu(ThisObject, "AR", Cancel);
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
