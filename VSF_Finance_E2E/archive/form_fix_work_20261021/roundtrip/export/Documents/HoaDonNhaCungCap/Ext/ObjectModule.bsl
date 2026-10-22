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
	If Not ValueIsFilled(TrangThai) Then
		TrangThai = Enums.TrangThaiHoaDonAP.DuThao;
	EndIf;
	If Not ValueIsFilled(NgayHoaDon) Then
		NgayHoaDon = BegOfDay(CurrentSessionDate());
	EndIf;
	If Not ValueIsFilled(TienTe) Then
		TienTe = Catalogs.TienTe.FindByCode("VND");
	EndIf;
EndProcedure

Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	// [FIX B31] Huy ghi so: chi KTT/CFO, khong con chung tu phu thuoc; tra ve buoc "Cho Kế toán trưởng duyệt"
	If WriteMode = DocumentWriteMode.UndoPosting Then
		QuanLyVongDoiChungTuServer.XuLyHuyGhiSo(ThisObject, Cancel, Enums.TrangThaiHoaDonAP.ChoKeToanTruongDuyet);
		Return;
	EndIf;
	
	// [FIX B28] Nguoi lap do he thong ghi nhan, khong nhap tay
	QuanLyVongDoiChungTuServer.GanNguoiLapKhiTaoMoi(ThisObject, "NguoiLap");
	
	QuanLyVongDoiChungTuServer.KiemTraTrangThaiVaQuyen(ThisObject, WriteMode, PostingMode, Cancel);
	QuanLyVongDoiChungTuServer.KiemTraChuyenTrangThai(ThisObject, TrangThai, UserName(), WriteMode);
	
	// Kiem tra phan quyen duyet 3 cap va nguong CFO 500tr
	If Not DataExchange.Load Then
		TrangThaiCu = QuanLyVongDoiChungTuServer.LayTrangThaiDaLuu(ThisObject).TrangThai;
		TrangThaiMoi = QuanLyVongDoiChungTuServer.TenTrangThai(TrangThai);
		If TrangThaiCu <> TrangThaiMoi And ValueIsFilled(TrangThaiCu) Then
			QuyTrinhPheDuyetAPServer.KiemTraBuocDuyetAP(TrangThaiCu, TrangThaiMoi, TongTien, NguoiLap);
		EndIf;
	EndIf;
	
	If Not ValueIsFilled(TienTe) Then
		TienTe = Catalogs.TienTe.FindByCode("VND");
	EndIf;
	If Not ValueIsFilled(NgayHoaDon) Then
		NgayHoaDon = BegOfDay(Date);
	EndIf;
	If ValueIsFilled(TienTe) And TrimAll(Upper(String(TienTe.Code))) = "VND" Then
		TyGia = 1;
		TongTienNgoaiTe = 0;
	Else
		If TyGia <= 0 Then
			TyGia = LayTyGiaHachToanTheoNgay(TienTe, NgayHoaDon);
		EndIf;
		If TyGia <= 0 Then
			Raise StrTemplate("AP invoice FX rate is missing for %1 on %2.", TienTe.Code, NgayHoaDon);
		EndIf;
	EndIf;
	
	// Tu dong tinh TongTien quy doi ra VND neu nguoi dung nhap so ngoai te
	If TongTien = 0 And TongTienNgoaiTe > 0 And TyGia > 0 Then
		TongTien = Round(TongTienNgoaiTe * TyGia, 0);
	EndIf;
	// [FIX B17] Neu chi nhap tien dich vu + VAT thi tu tinh tong
	If TongTien = 0 And TienDichVu > 0 Then
		TongTien = TienDichVu + TienThueVAT;
	EndIf;
	If TrimAll(Upper(String(TienTe.Code))) <> "VND" Then
		If TongTien = 0 And TongTienNgoaiTe > 0 Then
			TongTien = Round(TongTienNgoaiTe * TyGia, 0);
		EndIf;
		If TongTienNgoaiTe <= 0 And TongTien > 0 Then
			TongTienNgoaiTe = Round(TongTien / TyGia, 2);
		EndIf;
		If TongTien <= 0 Or TongTienNgoaiTe <= 0
			Or (TongTien - Round(TongTienNgoaiTe * TyGia, 0)) > 1
			Or (TongTien - Round(TongTienNgoaiTe * TyGia, 0)) < -1 Then
			Raise "AP foreign-currency amount and VND carrying amount do not reconcile to the invoice rate.";
		EndIf;
	EndIf;
	If TienThueVAT < 0 Or (TongTien > 0 And TienThueVAT >= TongTien) Then
		Cancel = True;
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject,
			NStr("vi = 'Tiền thuế GTGT không được âm và phải nhỏ hơn Tổng tiền hóa đơn!'; en = 'VAT amount must be between 0 and the invoice total!'"), "TienThueVAT");
		Return;
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
			// [FIX B17] Luon tinh lai tien dich vu tu Tong - VAT de So cai (Co 331) = So chi tiet (TongTien)
			TienDichVu = TongTien - TienThueVAT;
			ChiPhiVSF = TienDichVu;
			NoThucTraNCC = TongTien;
		EndIf;
	EndIf;
EndProcedure

Procedure Posting(Cancel, Mode)
	// Rebuild owned movements even when the same object instance is reposted.
	RegisterRecords.CongNoPhaiTra.Clear();
	RegisterRecords.SoCaiKeToan.Clear();
	// Kiem tra Maker-Checker va SoD khi ghi so (100% dua tren phien UserName() that)
	PhanQuyenBaoMatServer.KiemTraMakerChecker(NguoiLap, NguoiDuyet, UserName());
	PhanQuyenBaoMatServer.KiemTraQuyenChungTu(ThisObject, "GhiSo", UserName());
	QuanLyVongDoiChungTuServer.KiemTraChuyenTrangThai(ThisObject, TrangThai, UserName(), DocumentWriteMode.Posting);
	
	If TrangThai <> Enums.TrangThaiHoaDonAP.DaGhiSo Then
		Cancel = True;
		Msg = New UserMessage;
		Msg.Text = NStr("vi = 'Hóa đơn nhà cung cấp chỉ được ghi sổ sau khi hoàn tất phê duyệt AP!'; en = 'Vendor invoice can only be posted after AP approval!'");
		Msg.SetData(ThisObject);
		Msg.Field = "TrangThai";
		Msg.Message();
		Return;
	EndIf;

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
		Msg.Text = NStr("vi = 'Trường Nhà cung cấp chưa được điền!'; en = 'Vendor is required!'");
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
	If TongTien <= 0 Then
		HasError = True;
		Msg = New UserMessage;
		Msg.Text = NStr("vi = 'Tổng tiền hóa đơn phải lớn hơn 0!'; en = 'Invoice total must be greater than 0!'");
		Msg.SetData(ThisObject);
		Msg.Field = "TongTien";
		Msg.Message();
	EndIf;
	
	If HasError Then
		Cancel = True;
		Return;
	EndIf;
	
	// 2. Xac dinh tai khoan ke toan
	LaNoiBo = DoiTac.LaBenLienKet;
	LaNgoaiTe = (TongTienNgoaiTe > 0) Or (ValueIsFilled(TienTe) And TrimAll(Upper(String(TienTe.Code))) <> "VND");
	If LaNoiBo Then
		MaTKCongNo = "3312";
	ElsIf LaNgoaiTe Then
		MaTKCongNo = "3313";
	Else
		MaTKCongNo = "3311";
	EndIf;
	TKCongNo = ChartsOfAccounts.HeThongTaiKhoan.FindByCode(MaTKCongNo);
	If Not ValueIsFilled(TKCongNo) Then
		TKCongNo = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("3311");
	EndIf;
	
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
	
	If TongTienNgoaiTe > 0 Then
		If CoKhauTruFCT And TongTien > 0 Then
			RecordAP.SoTienNgoaiTe = Round(TongTienNgoaiTe * (NoThucTraNCC / TongTien), 2);
		Else
			RecordAP.SoTienNgoaiTe = TongTienNgoaiTe;
		EndIf;
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
		Row1.DienGiai = StrTemplate("Chi phí dịch vụ Cloud AWS (Net) - HĐ %1 (250tr đã gồm thuế; NCC nhận 225tr; FCT 25tr - giả định demo)", SoHoaDon);
		Row1.PhapNhan = PhapNhan;
		Row1.TienTe = TienTe;
		Row1.ChungTuGoc = Ref;
		Row1.TyGia = ?(TyGia > 0, TyGia, 1);
		If TongTienNgoaiTe > 0 And TyGia > 0 Then
			Row1.SoTienNgoaiTe = Round(NoThucTraNCC / TyGia, 2);
		EndIf;
		
		// But toan 2: Thue TNDN nha thau tinh vao chi phi VSF
		// No TK 627 / Co TK 3338: TienThueTNDNNhaThau (12.5tr)
		// Tong No TK 627 = 225tr + 12.5tr = 237.5tr (ChiPhiVSF)
		Row2 = RegisterRecords.SoCaiKeToan.Add();
		Row2.Period = Date;
		Row2.AccountDr = TKChiPhi;
		Row2.AccountCr = TKThueTNDNNhaThau;
		Row2.SoTien = TienThueTNDNNhaThau;
		Row2.DienGiai = StrTemplate("Thuế TNDN nhà thầu tính vào chi phí VSF - HĐ %1 (giả định demo)", SoHoaDon);
		Row2.PhapNhan = PhapNhan;
		Row2.TienTe = TienTe;
		Row2.ChungTuGoc = Ref;
		Row2.TyGia = ?(TyGia > 0, TyGia, 1);
		If TongTienNgoaiTe > 0 And TyGia > 0 Then
			Row2.SoTienNgoaiTe = Round(TienThueTNDNNhaThau / TyGia, 2);
		EndIf;
		
		// But toan 3: Thue VAT nha thau duoc khau tru dau vao
		// No TK 1331 / Co TK 33318: TienThueVATNhaThau (12.5tr)
		// Ghi chú: Giả định demo; điều kiện khấu trừ thực tế cần chứng từ nộp thuế KBNN (Phase 2)
		Row3 = RegisterRecords.SoCaiKeToan.Add();
		Row3.Period = Date;
		Row3.AccountDr = TKThueVATDauVao;
		Row3.AccountCr = TKThueVATNhaThau;
		Row3.SoTien = TienThueVATNhaThau;
		Row3.DienGiai = StrTemplate("Thuế GTGT nhà thầu khấu trừ đầu vào - HĐ %1 (giả định demo - Phase 1)", SoHoaDon);
		Row3.PhapNhan = PhapNhan;
		Row3.TienTe = TienTe;
		Row3.ChungTuGoc = Ref;
		Row3.TyGia = ?(TyGia > 0, TyGia, 1);
		If TongTienNgoaiTe > 0 And TyGia > 0 Then
			Row3.SoTienNgoaiTe = Round(TienThueVATNhaThau / TyGia, 2);
		EndIf;
	Else
		// Khong co FCT
		// But toan 1: Chi phi dich vu (No 627 / Co 3311 hoac 3312)
		TienChiPhi = TongTien - TienThueVAT; // [FIX B17] khop voi so chi tiet = TongTien
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
			Row1.SoTienNgoaiTe = Round(TienChiPhi / TyGia, 2);
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
				Row2.SoTienNgoaiTe = Round(TienThueVAT / TyGia, 2);
			EndIf;
		EndIf;
	EndIf;
	
	// 5. Kiem tra can doi tong the So cai
	For Each Entry In RegisterRecords.SoCaiKeToan Do
		If Entry.AccountCr = TKCongNo Then
			Entry.DoiTacCo = DoiTac;
			Entry.HopDongCo = HopDong;
		EndIf;
	EndDo;
	// [FIX B03/B17/B39] Doi chieu that su so chi tiet AP voi So cai TK 331x; loi phai bao cho nguoi dung
	If Not QuanLyVongDoiChungTuServer.KiemTraKhopGLVaSoPhu(ThisObject, "AP", Cancel) Then
		Return;
	EndIf;
	Try
		QuanLyVongDoiChungTuServer.KiemTraCanDoiSoCai(RegisterRecords.SoCaiKeToan);
	Except
		Cancel = True;
		QuanLyVongDoiChungTuServer.ThongBaoLoiChungTu(ThisObject, BriefErrorDescription(ErrorInfo()));
	EndTry;
EndProcedure

#EndRegion

#Region PublicLogic

Function LayTyGiaHachToanTheoNgay(Val TienTeRef, Val RateDate)
	If TrimAll(Upper(String(TienTeRef.Code))) = "VND" Then
		Return 1;
	EndIf;
	Query = New Query(
		"SELECT TOP 1 Rates.TyGiaHachToan AS TyGia
		|FROM InformationRegister.TyGiaHoiDoai.SliceLast(&RateDate, TienTe = &TienTe) AS Rates");
	Query.SetParameter("RateDate", RateDate);
	Query.SetParameter("TienTe", TienTeRef);
	Rows = Query.Execute().Unload();
	If Rows.Count() = 0 Or Rows[0].TyGia <= 0 Then
		Raise StrTemplate("No accounting exchange rate is configured for %1 on %2.", TienTeRef.Code, RateDate);
	EndIf;
	Return Rows[0].TyGia;
EndFunction

#EndRegion
