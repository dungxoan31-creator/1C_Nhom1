// Document: CanTruCongNoNoiBo
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Xu ly su kien ghi so chung tu can tru cong no noi bo (Task 6.1):
//           - Maker-Checker: Nguoi lap khong duoc tu duyet
//           - Chi ghi so khi TrangThai = "DaGhiSo" hoac "DaDuyet"
//           - Ghi giam no phai thu tren AccumulationRegister.CongNoPhaiThu (Expense)
//           - Ghi giam no phai tra tren AccumulationRegister.CongNoPhaiTra (Expense)
//           - Ghi so cai SoCaiKeToan:
//             + Truong hop truc tiep: No TK 3312 / Co TK 1312
//             + Truong hop bac cau da ben: No TK 3312 / Co TK 1388 va No TK 1388 / Co TK 1312
//           - Kiem tra Invariant can doi Delta = 0

#Region EventHandlers

Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	If DataExchange.Load Then
		Return;
	EndIf;
	
	// Kiem tra Maker-Checker va SoD khi phe duyet hoac ghi so
	If WriteMode = DocumentWriteMode.Posting Or TrangThai = "DaDuyet" Or TrangThai = "DaGhiSo" Or TrangThai = "DaCanTru" Then
		PhanQuyenBaoMatServer.KiemTraMakerChecker(NguoiLap, NguoiDuyet);
		PhanQuyenBaoMatServer.KiemTraQuyenChungTu(ThisObject, "GhiSo");
		
		If TrangThai <> "DaDuyet" And TrangThai <> "DaGhiSo" And TrangThai <> "DaCanTru" Then
			Cancel = True;
			Raise "CẤM GHI SỔ: Chứng từ cấn trừ công nợ phải ở trạng thái 'Đã duyệt' mới được phép ghi sổ!";
		EndIf;
		TrangThai = "DaGhiSo";
	Else
		If Not ValueIsFilled(TrangThai) Then
			TrangThai = "DuThao";
		EndIf;
	EndIf;
EndProcedure

Procedure Posting(Cancel, Mode)
	// Xac thuc bao mat Maker-Checker & SoD truoc khi ghi so
	PhanQuyenBaoMatServer.KiemTraMakerChecker(NguoiLap, NguoiDuyet);
	PhanQuyenBaoMatServer.KiemTraQuyenChungTu(ThisObject, "GhiSo");
	
	RegisterRecords.CongNoPhaiThu.Write = True;
	RegisterRecords.CongNoPhaiTra.Write = True;
	RegisterRecords.SoCaiKeToan.Write = True;
	
	If TrangThai <> "DaDuyet" And TrangThai <> "DaGhiSo" And TrangThai <> "DaCanTru" Then
		Return;
	EndIf;
	
	// Kiem tra hop le
	HasError = False;
	If Not ValueIsFilled(PhapNhan) Then
		HasError = True;
		Msg = New UserMessage;
		Msg.Text = NStr("vi = 'Trường Pháp nhân chưa được điền!'; en = 'Legal Entity is required!'");
		Msg.SetData(ThisObject);
		Msg.Field = "PhapNhan";
		Msg.Message();
	EndIf;
	If Not ValueIsFilled(DoiTacNoiBo) Then
		HasError = True;
		Msg = New UserMessage;
		Msg.Text = NStr("vi = 'Trường Đối tác nội bộ chưa được điền!'; en = 'Internal counterparty is required!'");
		Msg.SetData(ThisObject);
		Msg.Field = "DoiTacNoiBo";
		Msg.Message();
	EndIf;
	If SoTienCanTru <= 0 Then
		HasError = True;
		Msg = New UserMessage;
		Msg.Text = NStr("vi = 'Số tiền cấn trừ phải lớn hơn 0!'; en = 'Netting amount must be greater than 0!'");
		Msg.SetData(ThisObject);
		Msg.Field = "SoTienCanTru";
		Msg.Message();
	EndIf;
	
	If HasError Then
		Cancel = True;
		Return;
	EndIf;
	
	// Kiem tra so du kha dung AR va AP truoc khi can tru
	If ValueIsFilled(ChungTuGocAR) Then
		Q_AR = New Query;
		Q_AR.Text = 
			"SELECT ISNULL(SUM(Balance.SoTienBalance), 0) AS SoDu
			|FROM AccumulationRegister.CongNoPhaiThu.Balance(&ThoiDiem, ChungTuGoc = &ChungTuGoc AND PhapNhan = &PhapNhan) AS Balance";
		Q_AR.SetParameter("ThoiDiem", New Boundary(PointInTime(), BoundaryType.Excluding));
		Q_AR.SetParameter("ChungTuGoc", ChungTuGocAR);
		Q_AR.SetParameter("PhapNhan", PhapNhan);
		ResAR = Q_AR.Execute().Unload();
		If ResAR.Count() > 0 And ResAR[0].SoDu > 0 And ResAR[0].SoDu < SoTienCanTru Then
			Raise StrTemplate("LỖI CẤN TRỪ: Số tiền cấn trừ (%1) vượt quá số dư nợ phải thu khả dụng (%2) của chứng từ gốc!", 
				Format(SoTienCanTru, "NFD=0; NGS=."), Format(ResAR[0].SoDu, "NFD=0; NGS=."));
		EndIf;
	EndIf;
	
	If ValueIsFilled(ChungTuGocAP) Then
		Q_AP = New Query;
		Q_AP.Text = 
			"SELECT ISNULL(SUM(Balance.SoTienBalance), 0) AS SoDu
			|FROM AccumulationRegister.CongNoPhaiTra.Balance(&ThoiDiem, ChungTuGoc = &ChungTuGoc AND PhapNhan = &PhapNhan) AS Balance";
		Q_AP.SetParameter("ThoiDiem", New Boundary(PointInTime(), BoundaryType.Excluding));
		Q_AP.SetParameter("ChungTuGoc", ChungTuGocAP);
		Q_AP.SetParameter("PhapNhan", PhapNhan);
		ResAP = Q_AP.Execute().Unload();
		If ResAP.Count() > 0 And ResAP[0].SoDu > 0 And ResAP[0].SoDu < SoTienCanTru Then
			Raise StrTemplate("LỖI CẤN TRỪ: Số tiền cấn trừ (%1) vượt quá số dư nợ phải trả khả dụng (%2) của chứng từ gốc!", 
				Format(SoTienCanTru, "NFD=0; NGS=."), Format(ResAP[0].SoDu, "NFD=0; NGS=."));
		EndIf;
	EndIf;
	
	NgayHachToan = BegOfDay(Date);
	
	// 1. Ghi giam no phai thu tren CongNoPhaiThu (Expense)
	RegisterRecords.CongNoPhaiThu.Write = True;
	RecAR = RegisterRecords.CongNoPhaiThu.Add();
	RecAR.RecordType = AccumulationRecordType.Expense;
	RecAR.Period = NgayHachToan;
	RecAR.PhapNhan = PhapNhan;
	RecAR.DoiTac = DoiTacNoiBo;
	RecAR.HopDong = HopDongAR;
	RecAR.ChungTuGoc = ChungTuGocAR;
	RecAR.SoTien = SoTienCanTru;
	
	// 2. Ghi giam no phai tra tren CongNoPhaiTra (Expense)
	RegisterRecords.CongNoPhaiTra.Write = True;
	RecAP = RegisterRecords.CongNoPhaiTra.Add();
	RecAP.RecordType = AccumulationRecordType.Expense;
	RecAP.Period = NgayHachToan;
	RecAP.PhapNhan = PhapNhan;
	RecAP.DoiTac = ?(LaCanTruBacCau And ValueIsFilled(DoiTacTrungGian), DoiTacTrungGian, DoiTacNoiBo);
	RecAP.HopDong = HopDongAP;
	RecAP.ChungTuGoc = ChungTuGocAP;
	RecAP.SoTien = SoTienCanTru;
	
	// 3. Ghi so cai SoCaiKeToan
	RegisterRecords.SoCaiKeToan.Write = True;
	
	TK3312 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("3312");
	TK1312 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1312");
	TK1388 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1388");
	TK3388 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("3388");
	RefVND = Catalogs.TienTe.FindByCode("VND");
	
	If LaCanTruBacCau Then
		// Can tru bac cau da ben qua TK trung gian 1388 / 3388
		// But toan 1: Giam AP: No 3312 / Co 3388 (Phai tra DoiTacTrungGian)
		Row1 = RegisterRecords.SoCaiKeToan.Add();
		Row1.Period = NgayHachToan;
		Row1.AccountDr = TK3312;
		Row1.AccountCr = ?(ValueIsFilled(TK3388), TK3388, TK1388);
		Row1.SoTien = SoTienCanTru;
		Row1.DienGiai = StrTemplate("Cấn trừ nợ phải trả nội bộ qua TK trung gian theo lệnh %1", Number);
		Row1.PhapNhan = PhapNhan;
		Row1.TienTe = RefVND;
		Row1.ChungTuGoc = Ref;
		Row1.TyGia = 1;
		
		// But toan 2: Giam AR: No 1388 / Co 1312
		Row2 = RegisterRecords.SoCaiKeToan.Add();
		Row2.Period = NgayHachToan;
		Row2.AccountDr = TK1388;
		Row2.AccountCr = TK1312;
		Row2.SoTien = SoTienCanTru;
		Row2.DienGiai = StrTemplate("Cấn trừ nợ phải thu nội bộ qua TK trung gian theo lệnh %1", Number);
		Row2.PhapNhan = PhapNhan;
		Row2.TienTe = RefVND;
		Row2.ChungTuGoc = Ref;
		Row2.TyGia = 1;
	Else
		// Can tru tay doi truc tiep: No TK 3312 / Co TK 1312
		Row1 = RegisterRecords.SoCaiKeToan.Add();
		Row1.Period = NgayHachToan;
		Row1.AccountDr = TK3312;
		Row1.AccountCr = TK1312;
		Row1.SoTien = SoTienCanTru;
		Row1.DienGiai = StrTemplate("Cấn trừ công nợ nội bộ 2 bên theo chứng từ %1", Number);
		Row1.PhapNhan = PhapNhan;
		Row1.TienTe = RefVND;
		Row1.ChungTuGoc = Ref;
		Row1.TyGia = 1;
	EndIf;
	
	// Invariant Check
	Try
		QuanLyVongDoiChungTuServer.KiemTraCanDoiSoCai(RegisterRecords.SoCaiKeToan);
	Except
		Cancel = True;
		WriteLogEvent("Posting.CanTruCongNoNoiBo", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
	EndTry;
EndProcedure

#EndRegion
