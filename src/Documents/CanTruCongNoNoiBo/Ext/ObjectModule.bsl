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
	QuanLyVongDoiChungTuServer.KiemTraTrangThaiVaQuyen(ThisObject, WriteMode, PostingMode, Cancel);
	
	If WriteMode = DocumentWriteMode.Posting Then
		If TrangThai <> "DaDuyet" And TrangThai <> "DaGhiSo" And TrangThai <> "DaCanTru" Then
			Cancel = True;
			Raise "CẤM GHI SỔ: Chứng từ cấn trừ công nợ phải ở trạng thái 'Đã duyệt' mới được phép ghi sổ!";
		EndIf;
		TrangThai = "DaCanTru";
	Else
		If Not ValueIsFilled(TrangThai) Then
			TrangThai = "DuThao";
		EndIf;
	EndIf;
EndProcedure

Procedure Posting(Cancel, Mode)
	// Xac thuc bao mat Maker-Checker & SoD truoc khi ghi so (100% dua tren phien UserName() that)
	PhanQuyenBaoMatServer.KiemTraMakerChecker(NguoiLap, NguoiDuyet, UserName());
	PhanQuyenBaoMatServer.KiemTraQuyenChungTu(ThisObject, "GhiSo", UserName());
	QuanLyVongDoiChungTuServer.KiemTraChuyenTrangThai(ThisObject, TrangThai, UserName(), DocumentWriteMode.Posting);
	
	RegisterRecords.CongNoPhaiThu.Write = True;
	RegisterRecords.CongNoPhaiTra.Write = True;
	RegisterRecords.SoCaiKeToan.Write = True;
	
	If TrangThai <> "DaDuyet" And TrangThai <> "DaGhiSo" And TrangThai <> "DaCanTru" Then
		Return;
	EndIf;
	
	// 1. Kiem tra hop le du lieu bat buoc
	If Not ValueIsFilled(PhapNhan) Then
		Raise "Trường Pháp nhân chưa được điền!";
	EndIf;
	If Not ValueIsFilled(DoiTacNoiBo) Then
		Raise "Trường Đối tác nội bộ chưa được điền!";
	EndIf;
	If SoTienCanTru <= 0 Then
		Raise "Số tiền cấn trừ phải lớn hơn 0!";
	EndIf;
	
	// Bắt buộc phải có cặp chứng từ gốc AR và AP
	If Not ValueIsFilled(ChungTuGocAR) Then
		Raise "LỖI CẤN TRỪ: Bắt buộc phải chọn Chứng từ gốc AR (Hóa đơn hoặc Biên bản nghiệm thu cần cấn trừ)!";
	EndIf;
	If Not ValueIsFilled(ChungTuGocAP) Then
		Raise "LỖI CẤN TRỪ: Bắt buộc phải chọn Chứng từ gốc AP (Hóa đơn NCC hoặc nghiệm thu thầu phụ cần cấn trừ)!";
	EndIf;
	
	DoiTacAP = ?(LaCanTruBacCau And ValueIsFilled(DoiTacTrungGian), DoiTacTrungGian, DoiTacNoiBo);
	
	// Kiem tra rang buoc can tru bac cau / da ben
	If LaCanTruBacCau Then
		If Not ValueIsFilled(DoiTacTrungGian) Then
			Raise "Cấn trừ bắc cầu bắt buộc phải có Đối tác trung gian!";
		ElsIf DoiTacTrungGian = DoiTacNoiBo Then
			Raise "Đối tác trung gian phải khác đối tác nội bộ trong cấn trừ bắc cầu!";
		EndIf;
		If Not ValueIsFilled(SoVanBanThoaThuan) Then
			Raise "LỖI CẤN TRỪ BẮC CẦU: Cấn trừ đa bên/bắc cầu bắt buộc phải có Số văn bản thỏa thuận / Hồ sơ phê duyệt ba bên hợp pháp!";
		EndIf;
	EndIf;
	
	// 2. Kiem tra tinh nhat quan cua doi tac va hop dong tren chung tu goc
	HopDongAR_Chuan = HopDongAR;
	If Not ValueIsFilled(HopDongAR_Chuan) Then
		Try HopDongAR_Chuan = ChungTuGocAR.HopDong; Except EndTry;
	EndIf;
	If ValueIsFilled(HopDongAR) Then
		Try
			If ValueIsFilled(ChungTuGocAR.HopDong) And ChungTuGocAR.HopDong <> HopDongAR Then
				Raise "LỖI CẤN TRỪ: Hợp đồng AR không khớp với hợp đồng trên chứng từ gốc AR!";
			EndIf;
		Except
			Raise;
		EndTry;
	EndIf;
	
	HopDongAP_Chuan = HopDongAP;
	If Not ValueIsFilled(HopDongAP_Chuan) Then
		Try HopDongAP_Chuan = ChungTuGocAP.HopDong; Except EndTry;
	EndIf;
	If ValueIsFilled(HopDongAP) Then
		Try
			If ValueIsFilled(ChungTuGocAP.HopDong) And ChungTuGocAP.HopDong <> HopDongAP Then
				Raise "LỖI CẤN TRỪ: Hợp đồng AP không khớp với hợp đồng trên chứng từ gốc AP!";
			EndIf;
		Except
			Raise;
		EndTry;
	EndIf;
	
	Try
		If ValueIsFilled(ChungTuGocAR.DoiTac) And ChungTuGocAR.DoiTac <> DoiTacNoiBo Then
			Raise "LỖI CẤN TRỪ: Đối tác nội bộ không khớp với đối tác trên chứng từ gốc AR!";
		EndIf;
	Except
		Raise;
	EndTry;
	Try
		If ValueIsFilled(ChungTuGocAP.DoiTac) And ChungTuGocAP.DoiTac <> DoiTacAP Then
			Raise "LỖI CẤN TRỪ: Đối tác AP không khớp với đối tác trên chứng từ gốc AP!";
		EndIf;
	Except
		Raise;
	EndTry;
	
	// 2.1 Kiem tra dong nhat loai tien te giua AR va AP
	TienTeAR = Undefined;
	Try
		If ValueIsFilled(ChungTuGocAR.TienTe) Then
			TienTeAR = ChungTuGocAR.TienTe;
		EndIf;
	Except
	EndTry;
	If Not ValueIsFilled(TienTeAR) Then
		If ValueIsFilled(HopDongAR_Chuan) And ValueIsFilled(HopDongAR_Chuan.DongTienThanhToan) Then
			TienTeAR = HopDongAR_Chuan.DongTienThanhToan;
		Else
			TienTeAR = Catalogs.TienTe.FindByCode("VND");
		EndIf;
	EndIf;
	
	TienTeAP = Undefined;
	Try
		If ValueIsFilled(ChungTuGocAP.TienTe) Then
			TienTeAP = ChungTuGocAP.TienTe;
		EndIf;
	Except
	EndTry;
	If Not ValueIsFilled(TienTeAP) Then
		If ValueIsFilled(HopDongAP_Chuan) And ValueIsFilled(HopDongAP_Chuan.DongTienThanhToan) Then
			TienTeAP = HopDongAP_Chuan.DongTienThanhToan;
		Else
			TienTeAP = Catalogs.TienTe.FindByCode("VND");
		EndIf;
	EndIf;
	
	If TienTeAR <> TienTeAP Then
		Raise StrTemplate("LỖI CẤN TRỪ: Không đồng nhất loại tiền tệ giữa AR (%1) và AP (%2)!", TienTeAR, TienTeAP);
	EndIf;
	
	If Not ValueIsFilled(TienTe) Then
		TienTe = TienTeAR;
	ElsIf TienTe <> TienTeAR Then
		Raise StrTemplate("LỖI CẤN TRỪ: Loại tiền trên chứng từ (%1) không khớp với tiền tệ công nợ (%2)!", TienTe, TienTeAR);
	EndIf;
	
	// 3. Concurrency Lock: Native 1C DataLock de ngan chan race condition hai phien cung can tru mot khoan
	LockObj = New DataLock;
	
	LockAR = LockObj.Add("AccumulationRegister.CongNoPhaiThu");
	LockAR.Mode = DataLockMode.Exclusive;
	LockAR.SetValue("PhapNhan", PhapNhan);
	LockAR.SetValue("DoiTac", DoiTacNoiBo);
	LockAR.SetValue("ChungTuGoc", ChungTuGocAR);
	
	LockAP = LockObj.Add("AccumulationRegister.CongNoPhaiTra");
	LockAP.Mode = DataLockMode.Exclusive;
	LockAP.SetValue("PhapNhan", PhapNhan);
	LockAP.SetValue("DoiTac", DoiTacAP);
	LockAP.SetValue("ChungTuGoc", ChungTuGocAP);
	
	LockObj.Lock();
	
	// 4. Kiem tra so du kha dung tai thoi diem ghi so co loc TienTe
	ThoiDiemKiemTra = New Boundary(PointInTime(), BoundaryType.Excluding);
	
	// Doc so du AR theo dung khoa phan tich va tien te
	Q_AR = New Query(
		"SELECT ISNULL(SUM(Balance.SoTienBalance), 0) AS SoDu,
		|       ISNULL(SUM(Balance.SoTienNgoaiTeBalance), 0) AS SoDuNgoaiTe
		|FROM AccumulationRegister.CongNoPhaiThu.Balance(&ThoiDiem, 
		|    PhapNhan = &PhapNhan 
		|    AND DoiTac = &DoiTac 
		|    AND ChungTuGoc = &ChungTuGoc
		|    AND (HopDong.DongTienThanhToan = &TienTe OR &LaVND)) AS Balance");
	Q_AR.SetParameter("ThoiDiem", ThoiDiemKiemTra);
	Q_AR.SetParameter("PhapNhan", PhapNhan);
	Q_AR.SetParameter("DoiTac", DoiTacNoiBo);
	Q_AR.SetParameter("ChungTuGoc", ChungTuGocAR);
	Q_AR.SetParameter("TienTe", TienTe);
	Q_AR.SetParameter("LaVND", (TienTe = Catalogs.TienTe.FindByCode("VND")));
	ResAR = Q_AR.Execute().Unload();
	SoDuAR = ?(ResAR.Count() > 0, ?(TienTe = Catalogs.TienTe.FindByCode("VND"), ResAR[0].SoDu, ResAR[0].SoDuNgoaiTe), 0);
	If SoDuAR = 0 And ResAR.Count() > 0 And ResAR[0].SoDu > 0 Then
		SoDuAR = ResAR[0].SoDu;
	EndIf;
	
	If SoDuAR <= 0 Then
		Raise StrTemplate("LỖI CẤN TRỪ AR: Số dư nợ phải thu khả dụng bằng 0 hoặc âm (%1) tại thời điểm ghi sổ!", SoDuAR);
	EndIf;
	If SoDuAR < SoTienCanTru Then
		Raise StrTemplate("LỖI CẤN TRỪ AR: Số tiền cấn trừ (%1) vượt quá số dư nợ phải thu khả dụng (%2) tại thời điểm ghi sổ!", 
			Format(SoTienCanTru, "NFD=0; NGS=."), Format(SoDuAR, "NFD=0; NGS=."));
	EndIf;
	
	// Doc so du AP theo dung khoa phan tich va tien te
	Q_AP = New Query(
		"SELECT ISNULL(SUM(Balance.SoTienBalance), 0) AS SoDu,
		|       ISNULL(SUM(Balance.SoTienNgoaiTeBalance), 0) AS SoDuNgoaiTe
		|FROM AccumulationRegister.CongNoPhaiTra.Balance(&ThoiDiem, 
		|    PhapNhan = &PhapNhan 
		|    AND DoiTac = &DoiTac 
		|    AND ChungTuGoc = &ChungTuGoc
		|    AND (HopDong.DongTienThanhToan = &TienTe OR &LaVND)) AS Balance");
	Q_AP.SetParameter("ThoiDiem", ThoiDiemKiemTra);
	Q_AP.SetParameter("PhapNhan", PhapNhan);
	Q_AP.SetParameter("DoiTac", DoiTacAP);
	Q_AP.SetParameter("ChungTuGoc", ChungTuGocAP);
	Q_AP.SetParameter("TienTe", TienTe);
	Q_AP.SetParameter("LaVND", (TienTe = Catalogs.TienTe.FindByCode("VND")));
	ResAP = Q_AP.Execute().Unload();
	SoDuAP = ?(ResAP.Count() > 0, ?(TienTe = Catalogs.TienTe.FindByCode("VND"), ResAP[0].SoDu, ResAP[0].SoDuNgoaiTe), 0);
	If SoDuAP = 0 And ResAP.Count() > 0 And ResAP[0].SoDu > 0 Then
		SoDuAP = ResAP[0].SoDu;
	EndIf;
	
	If SoDuAP <= 0 Then
		Raise StrTemplate("LỖI CẤN TRỪ AP: Số dư nợ phải trả khả dụng bằng 0 hoặc âm (%1) tại thời điểm ghi sổ!", SoDuAP);
	EndIf;
	If SoDuAP < SoTienCanTru Then
		Raise StrTemplate("LỖI CẤN TRỪ AP: Số tiền cấn trừ (%1) vượt quá số dư nợ phải trả khả dụng (%2) tại thời điểm ghi sổ!", 
			Format(SoTienCanTru, "NFD=0; NGS=."), Format(SoDuAP, "NFD=0; NGS=."));
	EndIf;
	
	// 5. Ghi so phu (Expense)
	NgayHachToan = BegOfDay(Date);
	
	// Ghi giam no phai thu tren CongNoPhaiThu (Expense)
	RecAR = RegisterRecords.CongNoPhaiThu.Add();
	RecAR.RecordType = AccumulationRecordType.Expense;
	RecAR.Period = NgayHachToan;
	RecAR.PhapNhan = PhapNhan;
	RecAR.DoiTac = DoiTacNoiBo;
	RecAR.HopDong = HopDongAR_Chuan;
	RecAR.ChungTuGoc = ChungTuGocAR;
	RecAR.SoTien = SoTienCanTru;
	
	// Ghi giam no phai tra tren CongNoPhaiTra (Expense)
	RecAP = RegisterRecords.CongNoPhaiTra.Add();
	RecAP.RecordType = AccumulationRecordType.Expense;
	RecAP.Period = NgayHachToan;
	RecAP.PhapNhan = PhapNhan;
	RecAP.DoiTac = DoiTacAP;
	RecAP.HopDong = HopDongAP_Chuan;
	RecAP.ChungTuGoc = ChungTuGocAP;
	RecAP.SoTien = SoTienCanTru;
	
	// 6. Ghi so cai SoCaiKeToan
	TK3312 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("3312");
	TK1312 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1312");
	TK1388 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1388");
	
	TyGiaHachToan = 1;
	If TienTe <> Catalogs.TienTe.FindByCode("VND") Then
		Try
			TyGiaHachToan = QuanLyTyGiaVaNgoaiTeServer.LayTyGiaHienHanh(TienTe, BegOfDay(Date));
		Except
			TyGiaHachToan = 1;
		EndTry;
		If TyGiaHachToan <= 0 Then TyGiaHachToan = 1; EndIf;
	EndIf;
	
	If LaCanTruBacCau Then
		// Can tru bac cau da ben qua TK trung gian 1388 co can cu van ban thoa thuan
		// But toan 1: Giam AP: No 3312 / Co 1388
		Row1 = RegisterRecords.SoCaiKeToan.Add();
		Row1.Period = NgayHachToan;
		Row1.AccountDr = TK3312;
		Row1.AccountCr = TK1388;
		Row1.SoTien = SoTienCanTru;
		Row1.DienGiai = StrTemplate("Cấn trừ nợ AP qua TK trung gian 1388 theo VBTT %1 (Lệnh %2)", SoVanBanThoaThuan, Number);
		Row1.PhapNhan = PhapNhan;
		Row1.TienTe = TienTe;
		Row1.ChungTuGoc = Ref;
		Row1.TyGia = TyGiaHachToan;
		Row1.DoiTacCo = DoiTacAP;
		Row1.HopDongCo = HopDongAP_Chuan;
		
		// But toan 2: Giam AR: No 1388 / Co 1312
		Row2 = RegisterRecords.SoCaiKeToan.Add();
		Row2.Period = NgayHachToan;
		Row2.AccountDr = TK1388;
		Row2.AccountCr = TK1312;
		Row2.SoTien = SoTienCanTru;
		Row2.DienGiai = StrTemplate("Cấn trừ nợ AR qua TK trung gian 1388 theo VBTT %1 (Lệnh %2)", SoVanBanThoaThuan, Number);
		Row2.PhapNhan = PhapNhan;
		Row2.TienTe = TienTe;
		Row2.ChungTuGoc = Ref;
		Row2.TyGia = TyGiaHachToan;
		Row2.DoiTacCo = DoiTacNoiBo;
		Row2.HopDongCo = HopDongAR_Chuan;
	Else
		// Can tru song phuong truc tiep: No TK 3312 / Co TK 1312
		Row1 = RegisterRecords.SoCaiKeToan.Add();
		Row1.Period = NgayHachToan;
		Row1.AccountDr = TK3312;
		Row1.AccountCr = TK1312;
		Row1.SoTien = SoTienCanTru;
		Row1.DienGiai = StrTemplate("Cấn trừ công nợ nội bộ song phương theo chứng từ %1", Number);
		Row1.PhapNhan = PhapNhan;
		Row1.TienTe = TienTe;
		Row1.ChungTuGoc = Ref;
		Row1.TyGia = TyGiaHachToan;
		Row1.DoiTacNo = DoiTacAP;
		Row1.HopDongNo = HopDongAP_Chuan;
		Row1.DoiTacCo = DoiTacNoiBo;
		Row1.HopDongCo = HopDongAR_Chuan;
	EndIf;
	
	// Invariant Check
	Try
		QuanLyVongDoiChungTuServer.KiemTraCanDoiSoCai(RegisterRecords.SoCaiKeToan);
	Except
		Cancel = True;
		WriteLogEvent("Posting.CanTruCongNoNoiBo", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		Raise;
	EndTry;
EndProcedure

#EndRegion
