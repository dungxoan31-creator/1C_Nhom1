// Document: NghiemThuThauPhu
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Xu ly su kien ghi so (Posting) nghiem thu thau phu gia cong/outsource (Task 4.4):
//           - Ghi So cai SoCaiKeToan: No TK 627 / Co TK 3311 (hoac 3312 noi bo Vingroup)
//           - Ghi So tich luy CongNoPhaiTra (Receipt) tang no phai tra thau phu

#Region EventHandlers

Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	PhanQuyenBaoMatServer.KiemTraQuyenChungTu(ThisObject, "Write", UserName());
	If WriteMode = DocumentWriteMode.Posting Then
		PhanQuyenBaoMatServer.KiemTraQuyenChungTu(ThisObject, "GhiSo", UserName());
	EndIf;
	If DataExchange.Load Then
		Return;
	EndIf;
	
	If Not ValueIsFilled(NgayNghiemThu) Then
		NgayNghiemThu = BegOfDay(Date);
	EndIf;
	
	If TongGiaTri = 0 And GiaTriNghiemThu > 0 Then
		TongGiaTri = GiaTriNghiemThu + TienVAT;
	EndIf;
EndProcedure

Procedure Posting(Cancel, Mode)
	// Rebuild owned movements even when the same object instance is reposted.
	RegisterRecords.CongNoPhaiTra.Clear();
	RegisterRecords.SoCaiKeToan.Clear();
	// 1. Kiem tra rang buoc bat buoc
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
		Msg.Text = NStr("vi = 'Trường Thầu phụ chưa được điền!'; en = 'Subcontractor is required!'");
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
	If GiaTriNghiemThu <= 0 And TongGiaTri <= 0 Then
		HasError = True;
		Msg = New UserMessage;
		Msg.Text = NStr("vi = 'Giá trị nghiệm thu phải lớn hơn 0!'; en = 'Acceptance amount must be greater than 0!'");
		Msg.SetData(ThisObject);
		Msg.Field = "GiaTriNghiemThu";
		Msg.Message();
	EndIf;
	
	If HasError Then
		Cancel = True;
		Return;
	EndIf;
	
	SoTienGhiSo = ?(TongGiaTri > 0, TongGiaTri, GiaTriNghiemThu);
	
	// 2. Xac dinh tai khoan ke toan
	LaNoiBo = DoiTac.LaBenLienKet;
	MaTKCongNo = ?(LaNoiBo, "3312", "3311");
	TKCongNo = ChartsOfAccounts.HeThongTaiKhoan.FindByCode(MaTKCongNo);
	TKChiPhi = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("627");
	TKThueVAT = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1331");
	
	// 3. Ghi So tich luy CongNoPhaiTra (Receipt)
	RegisterRecords.CongNoPhaiTra.Write = True;
	RecordAP = RegisterRecords.CongNoPhaiTra.Add();
	RecordAP.RecordType = AccumulationRecordType.Receipt;
	RecordAP.Period = Date;
	RecordAP.PhapNhan = PhapNhan;
	RecordAP.DoiTac = DoiTac;
	RecordAP.HopDong = HopDong;
	RecordAP.ChungTuGoc = Ref;
	RecordAP.SoTien = SoTienGhiSo;
	RecordAP.SoTienNgoaiTe = 0;
	
	// 4. Ghi So cai SoCaiKeToan
	RegisterRecords.SoCaiKeToan.Write = True;
	
	RefVND = Catalogs.TienTe.FindByCode("VND");
	If TienVAT > 0 Then
		// No 627 / Co 3311: GiaTriNghiemThu
		Row1 = RegisterRecords.SoCaiKeToan.Add();
		Row1.Period = Date;
		Row1.AccountDr = TKChiPhi;
		Row1.AccountCr = TKCongNo;
		Row1.SoTien = GiaTriNghiemThu;
		Row1.DienGiai = StrTemplate("Chi phí nghiệm thu thầu phụ %1", Number);
		Row1.PhapNhan = PhapNhan;
		Row1.TienTe = RefVND;
		Row1.ChungTuGoc = Ref;
		Row1.TyGia = 1;
		
		// No 1331 / Co 3311: TienVAT
		Row2 = RegisterRecords.SoCaiKeToan.Add();
		Row2.Period = Date;
		Row2.AccountDr = TKThueVAT;
		Row2.AccountCr = TKCongNo;
		Row2.SoTien = TienVAT;
		Row2.DienGiai = StrTemplate("Thuế VAT nghiệm thu thầu phụ %1", Number);
		Row2.PhapNhan = PhapNhan;
		Row2.TienTe = RefVND;
		Row2.ChungTuGoc = Ref;
		Row2.TyGia = 1;
	Else
		// No 627 / Co 3311: SoTienGhiSo
		Row1 = RegisterRecords.SoCaiKeToan.Add();
		Row1.Period = Date;
		Row1.AccountDr = TKChiPhi;
		Row1.AccountCr = TKCongNo;
		Row1.SoTien = SoTienGhiSo;
		Row1.DienGiai = StrTemplate("Chi phí nghiệm thu thầu phụ %1", Number);
		Row1.PhapNhan = PhapNhan;
		Row1.TienTe = RefVND;
		Row1.ChungTuGoc = Ref;
		Row1.TyGia = 1;
	EndIf;
	
	Try
		QuanLyVongDoiChungTuServer.KiemTraCanDoiSoCai(RegisterRecords.SoCaiKeToan);
	Except
		Cancel = True;
		WriteLogEvent("Posting.NghiemThuThauPhu", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
	EndTry;
EndProcedure

#EndRegion
