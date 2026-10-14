// Document: DanhGiaLaiNgoaiTe
// Du an: VinSmart Future - AR & AP Management Platform (VSF)
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Chuc nang: Danh gia lai cac khoan muc tien te co goc ngoai te cuoi ky (TK 1122, TK 3313)
//            Hach toan SoCaiKeToan qua TK 4131 va ket chuyen sang TK 515 / TK 635 triet tieu TK 4131 ve 0.
//            Cap nhat gia tri VND tren so phu DongTien / CongNoPhaiTra ma giu nguyen so du ngoai te (USD Delta = 0).

#Region EventHandlers

Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	QuanLyVongDoiChungTuServer.KiemTraTrangThaiVaQuyen(ThisObject, WriteMode, PostingMode, Cancel);
	QuanLyVongDoiChungTuServer.KiemTraChuyenTrangThai(ThisObject, TrangThai, UserName(), WriteMode);
	
	If Not ValueIsFilled(NgayChot) Then
		NgayChot = EndOfDay(Date);
	Else
		NgayChot = EndOfDay(NgayChot);
	EndIf;
	
	If Not ValueIsFilled(TienTe) Then
		TienTe = Catalogs.TienTe.FindByCode("USD");
	EndIf;
	
	// Phan biet nhat quan Chuan muc ke toan ap dung theo nam tai chinh:
	// Theo quy dinh cua Bo Tai chinh: TT 99/2025/TT-BTC ap dung cho nam tai chinh bat dau tu hoac sau 01/01/2026.
	// Voi nam tai chinh chuan (01/01 - 31/12), ngay bat dau nam tai chinh la ngay 01/01 cua nam chot.
	NgayBatDauNamTaiChinh = Date(Year(NgayChot), 1, 1);
	If NgayBatDauNamTaiChinh >= Date(2026, 1, 1) Then
		ChuanMucKeToan = "TT99/2025/TT-BTC";
	Else
		ChuanMucKeToan = "TT200/2014/TT-BTC";
	EndIf;
	
	If WriteMode = DocumentWriteMode.Posting Then
		If TyGiaDanhGia <= 0 Then
			Cancel = True;
			Raise "Lỗi ghi sổ: Tỷ giá đánh giá lại ngoại tệ bắt buộc phải lớn hơn 0, không được suy đoán tỷ giá!";
		EndIf;
	EndIf;
EndProcedure

Procedure Posting(Cancel, Mode)
	// Rebuild owned movements even when the same object instance is reposted.
	RegisterRecords.CongNoPhaiTra.Clear();
	RegisterRecords.DongTien.Clear();
	RegisterRecords.SoCaiKeToan.Clear();
	PhanQuyenBaoMatServer.KiemTraMakerChecker(NguoiLap, NguoiDuyet, UserName());
	PhanQuyenBaoMatServer.KiemTraQuyenChungTu(ThisObject, "GhiSo", UserName());
	QuanLyVongDoiChungTuServer.KiemTraChuyenTrangThai(ThisObject, TrangThai, UserName(), DocumentWriteMode.Posting);
	
	RegisterRecords.SoCaiKeToan.Write = True;
	RegisterRecords.DongTien.Write = True;
	RegisterRecords.CongNoPhaiTra.Write = True;
	
	RefPN = PhapNhan;
	RefTT = TienTe;
	
	TK1122 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1122");
	TK3313 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("3313");
	TK4131 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("4131");
	TK515 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("515");
	TK635 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("635");
	
	BoundaryNgayChot = New Boundary(NgayChot, BoundaryType.Including);
	
	// Same global order as payment/netting: AR -> AP -> cash -> GL.
	// AP's currency is a HopDong attribute, not a register dimension. Lock all
	// DoiTac/HopDong/ChungTuGoc for this entity BEFORE discovering balances,
	// including zero/new keys. Cash groups all accounts and KhoanMucDongTien.
	// ponytail: entity-wide AP lock; narrow only with a stable currency dimension.
	Try
		LockAP = New DataLock;
		KeyAP = LockAP.Add("AccumulationRegister.CongNoPhaiTra");
		KeyAP.Mode = DataLockMode.Exclusive;
		KeyAP.SetValue("PhapNhan", RefPN);
		LockAP.Lock();
		LockCash = New DataLock;
		KeyCash = LockCash.Add("AccumulationRegister.DongTien");
		KeyCash.Mode = DataLockMode.Exclusive;
		KeyCash.SetValue("PhapNhan", RefPN);
		KeyCash.SetValue("TienTe", RefTT);
		LockCash.Lock();
	Except
		Cancel = True;
		Raise "Lỗi đánh giá lại: Không lấy được khóa số dư; giao dịch phải thử lại. " + DetailErrorDescription(ErrorInfo());
	EndTry;

	// Exclude previous movements of this recorder on repost, under the locks.
	// All writes remain in the platform posting transaction until it commits.
	RegisterRecords.CongNoPhaiTra.Clear();
	RegisterRecords.CongNoPhaiTra.Write();
	RegisterRecords.DongTien.Clear();
	RegisterRecords.DongTien.Write();

	// 1. Danh gia lai Tien gui ngan hang Ngoai te (TK 1122 / DongTien) cho MOI tai khoan ngan hang
	Q_Bank = New Query;
	Q_Bank.Text = 
		"SELECT
		|	DT.TaiKhoanTien AS TaiKhoanTien,
		|	ISNULL(SUM(DT.SoTienBalance), 0) AS SoTienVND,
		|	ISNULL(SUM(DT.SoTienNgoaiTeBalance), 0) AS SoTienUSD
		|FROM
		|	AccumulationRegister.DongTien.Balance(&NgayChot,
		|		PhapNhan = &PhapNhan AND TienTe = &TienTe) AS DT
		|GROUP BY
		|	DT.TaiKhoanTien";
	Q_Bank.SetParameter("NgayChot", BoundaryNgayChot);
	Q_Bank.SetParameter("PhapNhan", RefPN);
	Q_Bank.SetParameter("TienTe", RefTT);
	ResBank = Q_Bank.Execute().Unload();
	
	TongLai = 0;
	TongLo = 0;
	
	For Each RowBank In ResBank Do
		If RowBank.SoTienUSD = 0 Then
			Continue;
		EndIf;
		
		GiaTriMoiVND_Bank = Round(RowBank.SoTienUSD * TyGiaDanhGia, 2);
		ChenhLechBank = GiaTriMoiVND_Bank - RowBank.SoTienVND;
		
		If ChenhLechBank > 0 Then
			// Tang gia tri tien: Lai FX -> No 1122 / Co 4131
			Entry = RegisterRecords.SoCaiKeToan.Add();
			Entry.Period = Date;
			Entry.AccountDr = TK1122;
			Entry.AccountCr = TK4131;
			Entry.PhapNhan = RefPN;
			Entry.TienTe = RefTT;
			Entry.SoTien = ChenhLechBank;
			Entry.SoTienNgoaiTe = 0;
			Entry.DienGiai = StrTemplate("Đánh giá lại tiền gửi USD TK %1 cuối kỳ (Tỷ giá: %2) - Lãi FX", RowBank.TaiKhoanTien, TyGiaDanhGia);
			Entry.TaiKhoanTien = RowBank.TaiKhoanTien;
			Entry.TaiKhoanTienNo = RowBank.TaiKhoanTien;
			TongLai = TongLai + ChenhLechBank;
			
			// So phu DongTien: VND tang, USD giu nguyen (Delta USD = 0)
			RecDT = RegisterRecords.DongTien.AddReceipt();
			RecDT.Period = Date;
			RecDT.PhapNhan = RefPN;
			RecDT.TaiKhoanTien = RowBank.TaiKhoanTien;
			RecDT.TienTe = RefTT;
			RecDT.SoTien = ChenhLechBank;
			RecDT.SoTienNgoaiTe = 0;
		ElsIf ChenhLechBank < 0 Then
			// Giam gia tri tien: Lo FX -> No 4131 / Co 1122
			Entry = RegisterRecords.SoCaiKeToan.Add();
			Entry.Period = Date;
			Entry.AccountDr = TK4131;
			Entry.AccountCr = TK1122;
			Entry.PhapNhan = RefPN;
			Entry.TienTe = RefTT;
			Entry.SoTien = -ChenhLechBank;
			Entry.SoTienNgoaiTe = 0;
			Entry.DienGiai = StrTemplate("Đánh giá lại tiền gửi USD TK %1 cuối kỳ (Tỷ giá: %2) - Lỗ FX", RowBank.TaiKhoanTien, TyGiaDanhGia);
			Entry.TaiKhoanTien = RowBank.TaiKhoanTien;
			Entry.TaiKhoanTienCo = RowBank.TaiKhoanTien;
			TongLo = TongLo + (-ChenhLechBank);
			
			// So phu DongTien: VND giam, USD giu nguyen (Delta USD = 0)
			RecDT = RegisterRecords.DongTien.AddExpense();
			RecDT.Period = Date;
			RecDT.PhapNhan = RefPN;
			RecDT.TaiKhoanTien = RowBank.TaiKhoanTien;
			RecDT.TienTe = RefTT;
			RecDT.SoTien = -ChenhLechBank;
			RecDT.SoTienNgoaiTe = 0;
		EndIf;
	EndDo;
	
	// 2. Danh gia lai Cong no phai tra USD (TK 3313 / CongNoPhaiTra) cho MOI doi tac / hop dong
	Q_AP = New Query;
	Q_AP.Text = 
		"SELECT
		|	AP.DoiTac AS DoiTac,
		|	AP.HopDong AS HopDong,
		|	AP.ChungTuGoc AS ChungTuGoc,
		|	ISNULL(SUM(AP.SoTienBalance), 0) AS SoTienVND,
		|	ISNULL(SUM(AP.SoTienNgoaiTeBalance), 0) AS SoTienUSD
		|FROM
		|	AccumulationRegister.CongNoPhaiTra.Balance(&NgayChot,
		|		PhapNhan = &PhapNhan AND HopDong.DongTienThanhToan = &TienTe) AS AP
		|GROUP BY
		|	AP.DoiTac, AP.HopDong, AP.ChungTuGoc";
	Q_AP.SetParameter("NgayChot", BoundaryNgayChot);
	Q_AP.SetParameter("PhapNhan", RefPN);
	Q_AP.SetParameter("TienTe", RefTT);
	ResAP = Q_AP.Execute().Unload();
	
	For Each RowAP In ResAP Do
		If RowAP.SoTienUSD = 0 Then
			Continue;
		EndIf;
		
		GiaTriMoiVND_AP = Round(RowAP.SoTienUSD * TyGiaDanhGia, 2);
		ChenhLechAP = GiaTriMoiVND_AP - RowAP.SoTienVND;
		
		If ChenhLechAP > 0 Then
			// No tang: Lo FX -> No 4131 / Co 3313
			Entry = RegisterRecords.SoCaiKeToan.Add();
			Entry.Period = Date;
			Entry.AccountDr = TK4131;
			Entry.AccountCr = TK3313;
			Entry.PhapNhan = RefPN;
			Entry.TienTe = RefTT;
			Entry.SoTien = ChenhLechAP;
			Entry.SoTienNgoaiTe = 0;
			Entry.DienGiai = StrTemplate("Đánh giá lại công nợ phải trả USD %1 cuối kỳ (Tỷ giá: %2) - Lỗ FX", RowAP.DoiTac, TyGiaDanhGia);
			Entry.DoiTac = RowAP.DoiTac;
			Entry.HopDong = RowAP.HopDong;
			Entry.ChungTuGoc = RowAP.ChungTuGoc;
			Entry.DoiTacCo = RowAP.DoiTac;
			Entry.HopDongCo = RowAP.HopDong;
			Entry.ChungTuGocCo = RowAP.ChungTuGoc;
			TongLo = TongLo + ChenhLechAP;
			
			// So phu CongNoPhaiTra: No VND tang, USD giu nguyen
			RecAP = RegisterRecords.CongNoPhaiTra.AddReceipt();
			RecAP.Period = Date;
			RecAP.PhapNhan = RefPN;
			RecAP.DoiTac = RowAP.DoiTac;
			RecAP.HopDong = RowAP.HopDong;
			RecAP.ChungTuGoc = RowAP.ChungTuGoc;
			RecAP.SoTien = ChenhLechAP;
			RecAP.SoTienNgoaiTe = 0;
		ElsIf ChenhLechAP < 0 Then
			// No giam: Lai FX -> No 3313 / Co 4131
			Entry = RegisterRecords.SoCaiKeToan.Add();
			Entry.Period = Date;
			Entry.AccountDr = TK3313;
			Entry.AccountCr = TK4131;
			Entry.PhapNhan = RefPN;
			Entry.TienTe = RefTT;
			Entry.SoTien = -ChenhLechAP;
			Entry.SoTienNgoaiTe = 0;
			Entry.DienGiai = StrTemplate("Đánh giá lại công nợ phải trả USD %1 cuối kỳ (Tỷ giá: %2) - Lãi FX", RowAP.DoiTac, TyGiaDanhGia);
			Entry.DoiTac = RowAP.DoiTac;
			Entry.HopDong = RowAP.HopDong;
			Entry.ChungTuGoc = RowAP.ChungTuGoc;
			Entry.DoiTacNo = RowAP.DoiTac;
			Entry.HopDongNo = RowAP.HopDong;
			Entry.ChungTuGocNo = RowAP.ChungTuGoc;
			TongLai = TongLai + (-ChenhLechAP);
			
			// So phu CongNoPhaiTra: No VND giam, USD giu nguyen
			RecAP = RegisterRecords.CongNoPhaiTra.AddExpense();
			RecAP.Period = Date;
			RecAP.PhapNhan = RefPN;
			RecAP.DoiTac = RowAP.DoiTac;
			RecAP.HopDong = RowAP.HopDong;
			RecAP.ChungTuGoc = RowAP.ChungTuGoc;
			RecAP.SoTien = -ChenhLechAP;
			RecAP.SoTienNgoaiTe = 0;
		EndIf;
	EndDo;
	
	// 3. Ket chuyen tai khoan 4131 sang TK 515 hoac TK 635 de triet tieu so du TK 4131 ve 0
	If TongLai > TongLo Then
		NetLai = TongLai - TongLo;
		Entry = RegisterRecords.SoCaiKeToan.Add();
		Entry.Period = Date;
		Entry.AccountDr = TK4131;
		Entry.AccountCr = TK515;
		Entry.PhapNhan = RefPN;
		Entry.TienTe = RefTT;
		Entry.SoTien = NetLai;
		Entry.SoTienNgoaiTe = 0;
		Entry.DienGiai = "Kết chuyển lãi chênh lệch tỷ giá cuối kỳ (4131 -> 515)";
	ElsIf TongLo > TongLai Then
		NetLo = TongLo - TongLai;
		Entry = RegisterRecords.SoCaiKeToan.Add();
		Entry.Period = Date;
		Entry.AccountDr = TK635;
		Entry.AccountCr = TK4131;
		Entry.PhapNhan = RefPN;
		Entry.TienTe = RefTT;
		Entry.SoTien = NetLo;
		Entry.SoTienNgoaiTe = 0;
		Entry.DienGiai = "Kết chuyển lỗ chênh lệch tỷ giá cuối kỳ (635 -> 4131)";
	EndIf;
	
	TongLai515 = TongLai;
	TongLo635 = TongLo;
	
	// 4. Kiem tra can doi va triet tieu so du TK 4131 tren chung tu
	TongNo4131 = 0;
	TongCo4131 = 0;
	For Each RowGL In RegisterRecords.SoCaiKeToan Do
		If RowGL.AccountDr = TK4131 Then
			TongNo4131 = TongNo4131 + RowGL.SoTien;
		EndIf;
		If RowGL.AccountCr = TK4131 Then
			TongCo4131 = TongCo4131 + RowGL.SoTien;
		EndIf;
	EndDo;
	
	If TongNo4131 <> TongCo4131 Then
		Cancel = True;
		Raise StrTemplate("Lỗi hạch toán: Số dư TK 4131 không triệt tiêu về 0 (Nợ 4131: %1, Có 4131: %2)!", TongNo4131, TongCo4131);
	EndIf;
EndProcedure

#EndRegion
