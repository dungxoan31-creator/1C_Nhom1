// Document: BienBanNghiemThuGiaiDoan
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Xu ly su kien ghi so (Posting) bien ban nghiem thu giai doan dich vu CNTT (Task 3.1):
//           - Kiem tra dieu kien trang thai: Chi cho phep ghi so khi TrangThai = DaGhiSo hoac DaDuyetNoiBo.
//             Khi duoc ghi so tu trang thai DaDuyetNoiBo, tu dong chuyen sang DaGhiSo.
//           - Ghi So cai SoCaiKeToan:
//             + No TK 1312 (Doi tac noi bo Vingroup) hoac No TK 1311 (Doi tac ngoai)
//             + Co TK 5113 (Doanh thu cung cap dich vu CNTT)
//             + So tien = GiaTriNghiemThuChuaVAT (200.000.000 VND)
//           - Ghi So tich luy CongNoPhaiThu:
//             + RecordType: Receipt (Tang cong no phai thu)
//             + So tien = GiaTriNghiemThuChuaVAT (200.000.000 VND)
//           - P0.1 Invariant: CHUA phat sinh thue VAT dau ra o buoc nghiem thu (se phat sinh o Task 3.2).

#Region EventHandlers

Procedure Filling(FillingData, FillingText, StandardProcessing)
	If Not ValueIsFilled(Date) Then
		Date = CurrentSessionDate();
	EndIf;
	If IsBlankString(NguoiTao) Then
		NguoiTao = UserName();
	EndIf;
	If Not ValueIsFilled(PhapNhan) Then
		PhapNhan = QuanLyVongDoiChungTuServer.LayPhapNhanMacDinhTheoChiNhanhHienHanh();
	EndIf;
	If Not ValueIsFilled(TrangThai) Then
		TrangThai = Enums.TrangThaiNghiemThuAR.DuThao;
	EndIf;
	If Not ValueIsFilled(NgayNghiemThu) Then
		NgayNghiemThu = BegOfDay(CurrentSessionDate());
	EndIf;
	If ApDungGiamThueGTGT Then
		TyLeVAT = ThueGTGTClientServer.TyLeVATApDungTheoNgay(NgayNghiemThu, True);
	ElsIf TyLeVAT = 0 Then
		TyLeVAT = ThueGTGTClientServer.TyLeVATApDungTheoNgay(NgayNghiemThu, False);
	EndIf;
EndProcedure

Procedure ValidateRequiredFieldsForWrite(Cancel)
	If Not ValueIsFilled(PhapNhan) Then
		Cancel = True;
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject,
			NStr("vi = 'Thiếu thông tin bắt buộc: Pháp nhân.'; en = 'Required information is missing: Legal entity.'"), "PhapNhan");
		Return;
	EndIf;
	If Not ValueIsFilled(DoiTac) Then
		Cancel = True;
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject,
			NStr("vi = 'Thiếu thông tin bắt buộc: Đối tác.'; en = 'Required information is missing: Counterparty.'"), "DoiTac");
		Return;
	EndIf;
	If Not ValueIsFilled(HopDong) Then
		Cancel = True;
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject,
			NStr("vi = 'Thiếu thông tin bắt buộc: Hợp đồng.'; en = 'Required information is missing: Contract.'"), "HopDong");
		Return;
	EndIf;
	If HopDong.ChuSoHuu <> DoiTac Then
		Cancel = True;
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject,
			NStr("vi = 'Hợp đồng không thuộc Đối tác đã chọn.'; en = 'The selected contract does not belong to the selected counterparty.'"), "HopDong");
		Return;
	EndIf;
	If HopDong.PhapNhan <> PhapNhan Then
		Cancel = True;
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject,
			NStr("vi = 'Hợp đồng không thuộc Pháp nhân đã chọn.'; en = 'The selected contract does not belong to the selected legal entity.'"), "HopDong");
		Return;
	EndIf;
	If GiaTriNghiemThuChuaVAT <= 0 Then
		Cancel = True;
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject,
			NStr("vi = 'Giá trị nghiệm thu chưa VAT phải lớn hơn 0.'; en = 'The pre-VAT acceptance amount must be greater than zero.'"), "GiaTriNghiemThuChuaVAT");
		Return;
	EndIf;
EndProcedure

Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	// Materialize the assigned branch on the document row so 1C can evaluate
	// the INSERT restriction without a reference traversal.
	If ValueIsFilled(PhapNhan) Then
		LegalEntityBranch = PhapNhan.ChiNhanh;
		If Not ValueIsFilled(LegalEntityBranch) Then
			Raise "Pháp nhân của chứng từ chưa được gán chi nhánh.";
		EndIf;
		If ValueIsFilled(ChiNhanh) And ChiNhanh <> LegalEntityBranch Then
			Raise "Chi nhánh chứng từ không khớp chi nhánh của pháp nhân.";
		EndIf;
		If Upper(TrimAll(UserName())) <> "ADMIN" And Not IsInRole("QuanTriHeThong")
			And SessionParameters.CurrentBranch <> LegalEntityBranch Then
			Raise StrTemplate("Người dùng %1 không được lập chứng từ cho chi nhánh %2.", UserName(), LegalEntityBranch.Code);
		EndIf;
		ChiNhanh = LegalEntityBranch;
	EndIf;

	// tra trang thai ve "Da duyet noi bo" (tranh ket o trang thai DaGhiSo ma Posted = False)
	If WriteMode = DocumentWriteMode.UndoPosting Then
		QuanLyVongDoiChungTuServer.XuLyHuyGhiSo(ThisObject, Cancel, Enums.TrangThaiNghiemThuAR.DaDuyetNoiBo);
		Return;
	EndIf;
	If Not DataExchange.Load And WriteMode = DocumentWriteMode.Write Then
		ValidateRequiredFieldsForWrite(Cancel);
		If Cancel Then Return; EndIf;
	EndIf;
	
	// [FIX B28] Nguoi tao do he thong ghi nhan, khong nhap tay
	QuanLyVongDoiChungTuServer.GanNguoiLapKhiTaoMoi(ThisObject, "NguoiTao");
	If ValueIsFilled(NguoiDuyet) Then
		PheDuyetDaCapServer.KiemTraNguoiDuyetHopLe(ThisObject, UserName());
	EndIf;
	
	QuanLyVongDoiChungTuServer.KiemTraTrangThaiVaQuyen(ThisObject, WriteMode, PostingMode, Cancel);
	QuanLyVongDoiChungTuServer.KiemTraChuyenTrangThai(ThisObject, TrangThai, UserName(), WriteMode);
	If Not ValueIsFilled(NgayNghiemThu) Then
		NgayNghiemThu = BegOfDay(Date);
	EndIf;
	
	// Ap dung dung muc giam theo ngay nghiem thu; tinh lai VAT va tong de tranh so lieu cu.
	If GiaTriNghiemThuChuaVAT > 0 Then
		If ApDungGiamThueGTGT Then
			TyLeVAT = ThueGTGTClientServer.TyLeVATApDungTheoNgay(NgayNghiemThu, True);
		EndIf;
		TienVAT = Round(GiaTriNghiemThuChuaVAT * TyLeVAT / 100, 2);
		TongGiaTri = GiaTriNghiemThuChuaVAT + TienVAT;
	EndIf;
	
	// Cap nhat trang thai DaGhiSo trong BeforeWrite de luu vao CSDL
	If WriteMode = DocumentWriteMode.Posting Then
		If TrangThai = Enums.TrangThaiNghiemThuAR.DaDuyetNoiBo Then
			TrangThai = Enums.TrangThaiNghiemThuAR.DaGhiSo;
		EndIf;
	EndIf;
EndProcedure

Procedure Posting(Cancel, Mode)
	// Rebuild owned movements even when the same object instance is reposted.
	RegisterRecords.CongNoPhaiThu.Clear();
	RegisterRecords.SoCaiKeToan.Clear();
	// Bat buoc kiem tra Maker-Checker va SoD khi ghi so (100% dua tren phien UserName() that)
	If Upper(TrimAll(String(NguoiDuyet))) = "ADMIN" Then
		PhanQuyenBaoMatServer.KiemTraNguoiDuyetSauAdmin(ThisObject);
	Else
		PhanQuyenBaoMatServer.KiemTraMakerChecker(NguoiTao, NguoiDuyet, UserName());
	EndIf;
	PhanQuyenBaoMatServer.KiemTraQuyenChungTu(ThisObject, "GhiSo", UserName());
	QuanLyVongDoiChungTuServer.KiemTraChuyenTrangThai(ThisObject, TrangThai, UserName(), DocumentWriteMode.Posting);
	
	// 1. Kiem tra trang thai chung tu
	TrangThaiDaGhiSo = Enums.TrangThaiNghiemThuAR.DaGhiSo;
	TrangThaiDaDuyet = Enums.TrangThaiNghiemThuAR.DaDuyetNoiBo;
	
	If TrangThai <> TrangThaiDaGhiSo And TrangThai <> TrangThaiDaDuyet Then
		Cancel = True;
		Msg = New UserMessage;
		Msg.Text = StrTemplate(NStr("vi = 'Chứng từ nghiệm thu %1 chưa đủ điều kiện ghi sổ! Chỉ ghi sổ khi ở trạng thái Đã duyệt nội bộ hoặc Đã ghi sổ. Trạng thái hiện tại: %2'; en = 'Acceptance certificate %1 not eligible for posting! Current status: %2'"),
			Number, TrangThai);
		Msg.SetData(ThisObject);
		Msg.Field = "TrangThai";
		Msg.Message();
		Return;
	EndIf;

	// Metadata FillChecking does not protect programmatic Write(Posting) calls.
	// Recheck required dimensions before creating any subledger or GL movements.
	ValidateRequiredFieldsForWrite(Cancel);
	If Cancel Then Return; EndIf;
	
	// Xac dinh so tien ghi so doanh thu thuan
	SoTienDoanhThu = GiaTriNghiemThuChuaVAT;
	
	// 2. Ghi Sổ tích lũy Công nợ phải thu (AccumulationRegister.CongNoPhaiThu - Receipt)
	RegisterRecords.CongNoPhaiThu.LockForUpdate = True;
	RegisterRecords.CongNoPhaiThu.Write = True;
	RegisterRecords.SoCaiKeToan.LockForUpdate = True;
	RegisterRecords.SoCaiKeToan.Write = True;
	
	RecordAR = RegisterRecords.CongNoPhaiThu.Add();
	RecordAR.RecordType = AccumulationRecordType.Receipt;
	RecordAR.Period = Date;
	RecordAR.PhapNhan = PhapNhan;
	RecordAR.DoiTac = DoiTac;
	RecordAR.HopDong = HopDong;
	RecordAR.ChungTuGoc = Ref;
	RecordAR.SoTien = SoTienDoanhThu;
	RecordAR.SoTienNgoaiTe = 0;
	
	// 3. Ghi Sổ cái kế toán (AccountingRegister.SoCaiKeToan)
	RegisterRecords.SoCaiKeToan.Write = True;
	
	// Xac dinh Tai khoan No theo tinh chat doi tac:
	// - Doi tac noi bo Vingroup (LaBenLienKet = True hoac LoaiDoiTac = NoiBoVingroup / NoiBoTapDoan) -> TK 1312
	// - Doi tac ngoai tap doan -> TK 1311
	IsNoiBo = False;
	If ValueIsFilled(DoiTac) Then
		If DoiTac.LaBenLienKet Then
			IsNoiBo = True;
		ElsIf DoiTac.LoaiDoiTac = Enums.LoaiDoiTac.NoiBoVingroup Or DoiTac.LoaiDoiTac = Enums.LoaiDoiTac.NoiBoTapDoan Then
			IsNoiBo = True;
		EndIf;
	EndIf;
	
	If IsNoiBo Then
		AccountDr = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1312");
	Else
		AccountDr = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1311");
	EndIf;
	
	AccountCr = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("5113");
	
	RecordGL = RegisterRecords.SoCaiKeToan.Add();
	RecordGL.Period = Date;
	RecordGL.AccountDr = AccountDr;
	RecordGL.AccountCr = AccountCr;
	RecordGL.DoiTacNo = DoiTac;
	RecordGL.HopDongNo = HopDong;
	RecordGL.SoTien = SoTienDoanhThu;
	RecordGL.PhapNhan = PhapNhan;
	RecordGL.ChungTuGoc = Ref;
	
	// Gan dong tien thanh toan
	If ValueIsFilled(HopDong) And ValueIsFilled(HopDong.DongTienThanhToan) Then
		RecordGL.TienTe = HopDong.DongTienThanhToan;
	ElsIf ValueIsFilled(Catalogs.TienTe.FindByCode("VND")) Then
		RecordGL.TienTe = Catalogs.TienTe.FindByCode("VND");
	EndIf;
	
	NoiDungDienGiai = DienGiai;
	If Not ValueIsFilled(NoiDungDienGiai) Then
		NoiDungDienGiai = StrTemplate("Ghi nhận doanh thu thuần nghiệm thu giai đoạn %1", Number);
	EndIf;
	RecordGL.DienGiai = Left(NoiDungDienGiai, 250);
	
	// 4. Kiem tra can doi SoCaiKeToan (GL Invariant: Sum Dr = Sum Cr)
	Try
		EntriesGL = New Array;
		EntriesGL.Add(New Structure("AmountDr,AmountCr", SoTienDoanhThu, SoTienDoanhThu));
		QuanLyVongDoiChungTuServer.KiemTraCanDoiSoCai(EntriesGL);
	Except
		Cancel = True;
		// [FIX B03] Bao loi cho nguoi dung thay vi chi ghi log
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject, BriefErrorDescription(ErrorInfo()));
	EndTry;
EndProcedure

Procedure UndoPosting(Cancel)
	// He thong 1C tu dong xoa cac ban ghi so theo co che AutoDeleteOnUnpost.
	// Kiem tra quyen va chung tu phu thuoc da thuc hien trong BeforeWrite (WriteMode = UndoPosting).
EndProcedure

#EndRegion
