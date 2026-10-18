// Document: UyNhiemChi
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Xu ly su kien ghi so (Posting) Uy nhiem chi theo P0.2 Invariant State Machine (Task 4.3):
//           - Kiem tra Maker-Checker: Nguoi lap khong duoc tu duyet
//           - Khi chua o DaGhiSo (DuThao, ChoDuyet, DaDuyet, DaGuiNganHang, TuChoi, HuyBo):
//             KHONG GHI SO GL VA SUBLEDGER (Non-posting, Zero Phantom Reversals)
//           - Khi DaGhiSo:
//             + Ghi giam no AP tren CongNoPhaiTra (Expense)
//             + Ghi giam tien tren DongTien (Expense)
//             + Ghi SoCaiKeToan: No 3311 (hoac 3312) / Co 1121 (hoac 1122); Phi ngan hang No 6427 / Co 1121
//           - Khi LaTraSoatHoanTra = True:
//             + Sinh but toan dao hoan nguyen cong no va dong tien (No 1121 / Co 3311)

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
	If Not ValueIsFilled(NgayLap) Then
		NgayLap = BegOfDay(CurrentSessionDate());
	EndIf;
	If Not ValueIsFilled(NgayGhiSo) Then
		NgayGhiSo = BegOfDay(CurrentSessionDate());
	EndIf;
	If Not ValueIsFilled(TrangThai) Then
		TrangThai = Enums.TrangThaiLenhThanhToan.DuThao;
	EndIf;
	If Not ValueIsFilled(TienTe) Then
		TienTe = Catalogs.TienTe.FindByCode("VND");
	EndIf;
	If TyGia = 0 Then
		TyGia = 1;
	EndIf;
	
	// Kế thừa dữ liệu từ Hóa đơn nhà cung cấp (BasedOn)
	If TypeOf(FillingData) = Type("DocumentRef.HoaDonNhaCungCap") Then
		ChungTuGoc = FillingData;
		PhapNhan = FillingData.PhapNhan;
		DoiTac = FillingData.DoiTac;
		HopDong = FillingData.HopDong;
		SoTien = FillingData.TongTien;
		DienGiai = StrTemplate("Thanh toán tiền theo Hóa đơn nhà cung cấp %1", FillingData.SoHoaDon);
	EndIf;
EndProcedure

Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	// [FIX B31] Huy ghi so: chi KTT/CFO, khong con chung tu phu thuoc; tra ve "Da gui ngan hang"
	If WriteMode = DocumentWriteMode.UndoPosting Then
		QuanLyVongDoiChungTuServer.XuLyHuyGhiSo(ThisObject, Cancel, Enums.TrangThaiLenhThanhToan.DaGuiNganHang);
		Return;
	EndIf;
	
	// [FIX B28] Nguoi lap do he thong ghi nhan, khong nhap tay
	QuanLyVongDoiChungTuServer.GanNguoiLapKhiTaoMoi(ThisObject, "NguoiLap");
	
	QuanLyVongDoiChungTuServer.KiemTraTrangThaiVaQuyen(ThisObject, WriteMode, PostingMode, Cancel);
	QuanLyVongDoiChungTuServer.KiemTraChuyenTrangThai(ThisObject, TrangThai, UserName(), WriteMode);
	
	// 2. Mac dinh ngay lap
	If Not ValueIsFilled(NgayLap) Then
		NgayLap = BegOfDay(Date);
	EndIf;
	
	// Mac dinh ty gia VND
	If Not ValueIsFilled(TienTe) Or TrimAll(Upper(String(TienTe.Code))) = "VND" Then
		TyGia = 1;
	EndIf;
	
	If SoTien <= 0 And SoTienNgoaiTe > 0 And TyGia > 0 Then
		SoTien = Round(SoTienNgoaiTe * TyGia, 0);
	EndIf;
EndProcedure

Procedure Posting(Cancel, Mode)
	// Xac thuc bao mat Maker-Checker & SoD truoc khi ghi so (100% dua tren phien UserName() that)
	PhanQuyenBaoMatServer.KiemTraMakerChecker(NguoiLap, NguoiDuyet, UserName());
	PhanQuyenBaoMatServer.KiemTraQuyenChungTu(ThisObject, "GhiSo", UserName());
	QuanLyVongDoiChungTuServer.KiemTraChuyenTrangThai(ThisObject, TrangThai, UserName(), DocumentWriteMode.Posting);
	
	// 1. Kiem tra P0.2 Invariant State Machine:
	// Xoa movement cu neu trang thai khong con la DaGhiSo (Quy tac P2 / #std603)
	RegisterRecords.CongNoPhaiTra.Write = True;
	RegisterRecords.DongTien.Write = True;
	RegisterRecords.SoCaiKeToan.Write = True;
	// Rebuild cached record sets on every write, including reversal reposts.
	RegisterRecords.CongNoPhaiTra.Clear();
	RegisterRecords.DongTien.Clear();
	RegisterRecords.SoCaiKeToan.Clear();
	
	TrangThaiDaGhiSo = Enums.TrangThaiLenhThanhToan.DaGhiSo;
	
	If TrangThai <> TrangThaiDaGhiSo Then
		// KHONG GHI SO GL VA SUBLEDGER! (Ghi de record set rong de xoa movement cu neu co)
		Return;
	EndIf;
	
	// 2. Kiem tra cac truong bat buoc khi da ghi so
	If Not ValueIsFilled(PhapNhan) Then
		Raise "Trường Pháp nhân chưa được điền!";
	EndIf;
	If Not ValueIsFilled(DoiTac) Then
		Raise "Trường Nhà cung cấp chưa được điền!";
	EndIf;
	If Not ValueIsFilled(HopDong) Then
		Raise "Trường Hợp đồng chưa được điền!";
	EndIf;
	
	If LaTraSoatHoanTra And ValueIsFilled(ChungTuGoc) And TyGia <= 0 Then
		Try
			TyGia = ChungTuGoc.TyGia;
		Except
		EndTry;
	EndIf;
	
	LaNgoaiTe = (SoTienNgoaiTe > 0) Or (ValueIsFilled(TienTe) And TrimAll(Upper(String(TienTe.Code))) <> "VND");
	
	If LaNgoaiTe Then
		If TyGia <= 0 Then
			Raise "Lỗi ghi sổ: Thanh toán ngoại tệ bắt buộc phải có Tỷ giá lớn hơn 0, không được suy đoán tỷ giá!";
		EndIf;
		If SoTienNgoaiTe <= 0 Then
			Raise "Lỗi ghi sổ: Thanh toán ngoại tệ bắt buộc Số tiền ngoại tệ phải lớn hơn 0!";
		EndIf;
		If SoTien <= 0 And TyGia > 0 Then
			SoTien = Round(SoTienNgoaiTe * TyGia, 0);
		EndIf;
		If SoTien <= 0 Then
			Raise "Lỗi ghi sổ: Số tiền (VND) thực chi/quy đổi phải lớn hơn 0!";
		EndIf;
	Else
		If SoTien <= 0 Then
			Raise "Lỗi ghi sổ: Số tiền lệnh chi phải lớn hơn 0!";
		EndIf;
	EndIf;
	
	// 3. Xac dinh tai khoan ke toan
	LaNoiBo = DoiTac.LaBenLienKet;
	LaNgoaiTe = (SoTienNgoaiTe > 0) Or (ValueIsFilled(TienTe) And TrimAll(Upper(String(TienTe.Code))) <> "VND");
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
	
	LaNgoaiTe = (SoTienNgoaiTe > 0);
	
	// Xac dinh tai khoan ngan hang: 1121 (VND) hay 1122 (USD)
	MaTKTien = "1121";
	If ValueIsFilled(TaiKhoanTien) Then
		If ValueIsFilled(TaiKhoanTien.TienTe) And TrimAll(Upper(String(TaiKhoanTien.TienTe.Code))) = "USD" Then
			MaTKTien = "1122";
		ElsIf TrimAll(Upper(String(TaiKhoanTien.Code))) = "TK-VCB-USD" Then
			MaTKTien = "1122";
		Else
			MaTKTien = "1121";
		EndIf;
	ElsIf LaNgoaiTe And (SoTien <= 0 Or (ValueIsFilled(TienTe) And TrimAll(Upper(String(TienTe.Code))) = "USD" And TyGia <= 1)) Then
		MaTKTien = "1122";
	EndIf;
	
	TKTien = ChartsOfAccounts.HeThongTaiKhoan.FindByCode(MaTKTien);
	If Not ValueIsFilled(TKTien) Then
		TKTien = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1121");
	EndIf;
	TKPhiNganHang = Constants.TaiKhoanPhiNganHang.Get();
	If Not ValueIsFilled(TKPhiNganHang) Then
		TKPhiNganHang = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("6427");
	EndIf;
	TienTeVND = Catalogs.TienTe.FindByCode("VND");
	
	NgayHachToan = ?(ValueIsFilled(NgayGhiSo), NgayGhiSo, Date);
	
	// 4. Truong hop Tra soat hoan tra sau ghi so (Reversal)
	If LaTraSoatHoanTra Then
		If Not ValueIsFilled(ChungTuGoc) Then
			Raise "Lỗi tra soát hoàn trả: Bắt buộc phải tham chiếu đến Chứng từ gốc (Lệnh chi cũ cần đảo)!";
		EndIf;
		
		// Both reversal documents lock the same original payment Ref before
		// checking duplicates; normal-payment balance locks are never reached here.
		LockOriginalPayment = New DataLock;
		OriginalPaymentKey = LockOriginalPayment.Add("Document.UyNhiemChi");
		OriginalPaymentKey.Mode = DataLockMode.Exclusive;
		OriginalPaymentKey.SetValue("Ref", ChungTuGoc);
		LockOriginalPayment.Lock();

		// Chống hoàn hai lần cùng Ref
		Q_DupRev = New Query(
			"SELECT TOP 1 Ref FROM Document.UyNhiemChi 
			|WHERE LaTraSoatHoanTra = TRUE AND ChungTuGoc = &ChungTuGoc AND Ref <> &CurrentRef AND Posted = TRUE");
		Q_DupRev.SetParameter("ChungTuGoc", ChungTuGoc);
		Q_DupRev.SetParameter("CurrentRef", Ref);
		If Not Q_DupRev.Execute().IsEmpty() Then
			Raise StrTemplate("Lỗi tra soát hoàn trả: Lệnh chi gốc %1 đã được hoàn trả trước đó! Chống hoàn trả 2 lần cùng chứng từ!", ChungTuGoc);
		EndIf;
		
		// Doc but toan goc tren SoCaiKeToan de dao chinh xac 100%
		Q_Orig = New Query(
			"SELECT
			|	SoCai.AccountDr AS AccountDr,
			|	SoCai.AccountCr AS AccountCr,
			|	SoCai.SoTien AS SoTien,
			|	SoCai.SoTienNgoaiTe AS SoTienNgoaiTe,
			|	SoCai.TienTe AS TienTe,
			|	SoCai.TyGia AS TyGia,
			|	SoCai.DoiTacNo AS DoiTacNo,
			|	SoCai.DoiTacCo AS DoiTacCo,
			|	SoCai.HopDongNo AS HopDongNo,
			|	SoCai.HopDongCo AS HopDongCo,
			|	SoCai.ChungTuGocNo AS ChungTuGocNo,
			|	SoCai.ChungTuGocCo AS ChungTuGocCo,
			|	SoCai.TaiKhoanTienNo AS TaiKhoanTienNo,
			|	SoCai.TaiKhoanTienCo AS TaiKhoanTienCo
			|FROM
			|	AccountingRegister.SoCaiKeToan AS SoCai
			|WHERE
			|	SoCai.Recorder = &RefOrig");
		Q_Orig.SetParameter("RefOrig", ChungTuGoc);
		T_Orig = Q_Orig.Execute().Unload();
		
		If T_Orig.Count() = 0 Then
			Raise "Lỗi tra soát hoàn trả: Không tìm thấy bút toán gốc của chứng từ cần đảo trên Sổ cái!";
		EndIf;
		
		RegisterRecords.SoCaiKeToan.Write = True;
		For Each RowOrig In T_Orig Do
			RowRev = RegisterRecords.SoCaiKeToan.Add();
			RowRev.Period = NgayHachToan;
			RowRev.AccountDr = RowOrig.AccountCr; // Dao nguoc Dr <-> Cr
			RowRev.AccountCr = RowOrig.AccountDr;
			RowRev.SoTien = RowOrig.SoTien;
			RowRev.DienGiai = StrTemplate("Hoàn trả tiền theo tra soát lệnh chi %1", Number);
			RowRev.PhapNhan = PhapNhan;
			RowRev.TienTe = RowOrig.TienTe;
			RowRev.ChungTuGoc = ChungTuGoc;
			RowRev.DoiTacNo = RowOrig.DoiTacCo;
			RowRev.DoiTacCo = RowOrig.DoiTacNo;
			RowRev.HopDongNo = RowOrig.HopDongCo;
			RowRev.HopDongCo = RowOrig.HopDongNo;
			RowRev.ChungTuGocNo = RowOrig.ChungTuGocCo;
			RowRev.ChungTuGocCo = RowOrig.ChungTuGocNo;
			RowRev.TaiKhoanTienNo = RowOrig.TaiKhoanTienCo;
			RowRev.TaiKhoanTienCo = RowOrig.TaiKhoanTienNo;
			RowRev.TyGia = RowOrig.TyGia;
			RowRev.SoTienNgoaiTe = RowOrig.SoTienNgoaiTe;
		EndDo;
		
		// Doc va dao nguoc CongNoPhaiTra (Receipt)
		Q_APOrig = New Query(
			"SELECT
			|	ISNULL(SUM(SoTien), 0) AS SoTien,
			|	ISNULL(SUM(SoTienNgoaiTe), 0) AS SoTienNgoaiTe
			|FROM
			|	AccumulationRegister.CongNoPhaiTra
			|WHERE
			|	Recorder = &RefOrig AND RecordType = VALUE(AccumulationRecordType.Expense)");
		Q_APOrig.SetParameter("RefOrig", ChungTuGoc);
		ResAPOrig = Q_APOrig.Execute().Unload();
		
		TienAPGoc = ?(ResAPOrig.Count() > 0, ResAPOrig[0].SoTien, SoTien);
		TienAPNgoaiTeGoc = ?(ResAPOrig.Count() > 0, ResAPOrig[0].SoTienNgoaiTe, SoTienNgoaiTe);
		
		RegisterRecords.CongNoPhaiTra.Write = True;
		RecordAP = RegisterRecords.CongNoPhaiTra.Add();
		RecordAP.RecordType = AccumulationRecordType.Receipt;
		RecordAP.Period = NgayHachToan;
		RecordAP.PhapNhan = PhapNhan;
		RecordAP.DoiTac = DoiTac;
		RecordAP.HopDong = HopDong;
		RecordAP.ChungTuGoc = ChungTuGoc;
		RecordAP.SoTien = TienAPGoc;
		RecordAP.SoTienNgoaiTe = TienAPNgoaiTeGoc;
		
		// Doc va dao nguoc DongTien (Receipt)
		Q_DTOrig = New Query(
			"SELECT
			|	ISNULL(SUM(SoTien), 0) AS SoTien,
			|	ISNULL(SUM(SoTienNgoaiTe), 0) AS SoTienNgoaiTe
			|FROM
			|	AccumulationRegister.DongTien
			|WHERE
			|	Recorder = &RefOrig AND RecordType = VALUE(AccumulationRecordType.Expense)");
		Q_DTOrig.SetParameter("RefOrig", ChungTuGoc);
		ResDTOrig = Q_DTOrig.Execute().Unload();
		
		TienDTGoc = ?(ResDTOrig.Count() > 0, ResDTOrig[0].SoTien, SoTien);
		TienDTNgoaiTeGoc = ?(ResDTOrig.Count() > 0, ResDTOrig[0].SoTienNgoaiTe, SoTienNgoaiTe);
		
		RegisterRecords.DongTien.Write = True;
		RecordDT = RegisterRecords.DongTien.Add();
		RecordDT.RecordType = AccumulationRecordType.Receipt;
		RecordDT.Period = NgayHachToan;
		RecordDT.PhapNhan = PhapNhan;
		RecordDT.TaiKhoanTien = TaiKhoanTien;
		RecordDT.KhoanMucDongTien = KhoanMucDongTien;
		RecordDT.TienTe = TienTe;
		RecordDT.SoTien = TienDTGoc;
		RecordDT.SoTienNgoaiTe = TienDTNgoaiTeGoc;
		
		Try
			QuanLyVongDoiChungTuServer.KiemTraCanDoiSoCai(RegisterRecords.SoCaiKeToan);
		Except
			Cancel = True;
			WriteLogEvent("Posting.UyNhiemChi", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
			Raise;
		EndTry;
		Return;
	EndIf;
	
	// 5. Truong hop chi tien binh thuong (Normal Payment)
	SoTienThucTra = SoTien;
	SoTienGhiSoAP = SoTien;
	ChenhLech = 0;
	CoChenhLechTyGia = False;
	TyGiaHoaDon = TyGia;
	
	If Not ValueIsFilled(ChungTuGoc) Then
		Raise "Lỗi thanh toán: Bắt buộc có chứng từ gốc để kiểm tra số dư công nợ khả dụng!";
	EndIf;
	If Not ValueIsFilled(TaiKhoanTien) Then
		Raise "Lỗi thanh toán: Bắt buộc có tài khoản tiền để kiểm tra số dư khả dụng!";
	EndIf;

	// Resolve the fee source before taking any balance locks.
	TaiKhoanTienPhi = Catalogs.TaiKhoanTien.EmptyRef();
	If PhiNganHang > 0 Then
		If MaTKTien = "1121" Then
			TaiKhoanTienPhi = TaiKhoanTien;
		Else
			Q_TK_VND = New Query(
				"SELECT TOP 1 Ref FROM Catalog.TaiKhoanTien
				|WHERE TienTe.Code = ""VND"" AND DeletionMark = FALSE ORDER BY Ref");
			T_TK_VND = Q_TK_VND.Execute().Unload();
			If T_TK_VND.Count() > 0 Then
				TaiKhoanTienPhi = T_TK_VND[0].Ref;
			EndIf;
		EndIf;
		If Not ValueIsFilled(TaiKhoanTienPhi) Then
			Raise "Lỗi thanh toán: Phí chuyển tiền VND bắt buộc phải có tài khoản tiền VND để hạch toán!";
		EndIf;
	EndIf;

	// Global order: CongNoPhaiThu -> CongNoPhaiTra -> DongTien -> GL.
	// AP uses every balance dimension. Cash aggregates all KhoanMucDongTien,
	// so that dimension must remain a wildcard, including on an empty balance.
	CurrencyCash = ?(MaTKTien = "1122", TienTe, TienTeVND);
	CashKeys = New ValueTable;
	CashKeys.Columns.Add("Key");
	CashKeys.Columns.Add("TaiKhoanTien");
	CashKeys.Columns.Add("TienTe");
	CashKey = CashKeys.Add();
	CashKey.Key = String(TaiKhoanTien.UUID()) + String(CurrencyCash.UUID());
	CashKey.TaiKhoanTien = TaiKhoanTien;
	CashKey.TienTe = CurrencyCash;
	If PhiNganHang > 0 And (TaiKhoanTienPhi <> TaiKhoanTien Or CurrencyCash <> TienTeVND) Then
		CashKey = CashKeys.Add();
		CashKey.Key = String(TaiKhoanTienPhi.UUID()) + String(TienTeVND.UUID());
		CashKey.TaiKhoanTien = TaiKhoanTienPhi;
		CashKey.TienTe = TienTeVND;
	EndIf;
	CashKeys.Sort("Key");
	Try
		LockAP = New DataLock;
		KeyAP = LockAP.Add("AccumulationRegister.CongNoPhaiTra");
		KeyAP.Mode = DataLockMode.Exclusive;
		KeyAP.SetValue("PhapNhan", PhapNhan);
		KeyAP.SetValue("DoiTac", DoiTac);
		KeyAP.SetValue("HopDong", HopDong);
		KeyAP.SetValue("ChungTuGoc", ChungTuGoc);
		LockAP.Lock();
		For Each CashKey In CashKeys Do
			LockCash = New DataLock;
			KeyCash = LockCash.Add("AccumulationRegister.DongTien");
			KeyCash.Mode = DataLockMode.Exclusive;
			KeyCash.SetValue("PhapNhan", PhapNhan);
			KeyCash.SetValue("TaiKhoanTien", CashKey.TaiKhoanTien);
			KeyCash.SetValue("TienTe", CashKey.TienTe);
			LockCash.Lock();
		EndDo;
	Except
		Cancel = True;
		Raise "Lỗi thanh toán: Không lấy được khóa số dư; giao dịch phải thử lại. " + DetailErrorDescription(ErrorInfo());
	EndTry;

	// Current totals include every committed competing document, even one whose
	// Date/Ref sorts after this payment. Remove only this recorder for reposting;
	// posting transaction rolls these writes back if any later check fails.
	RegisterRecords.CongNoPhaiTra.Clear();
	RegisterRecords.CongNoPhaiTra.Write();
	RegisterRecords.DongTien.Clear();
	RegisterRecords.DongTien.Write();

	If LaNgoaiTe Then
		If Not ValueIsFilled(ChungTuGoc) Then
			Raise "Lỗi thanh toán ngoại tệ: Bắt buộc phải có hóa đơn gốc (ChungTuGoc) để xác định tỷ giá ghi sổ nợ AP!";
		EndIf;
		
		// 1. Lay so du cong no phai tra thuc te tu so phu CongNoPhaiTra (da tinh ca danh gia lai truoc do neu co)
		Q_AP_Bal = New Query(
			"SELECT
			|	ISNULL(SUM(SoTienBalance), 0) AS SoTienVND,
			|	ISNULL(SUM(SoTienNgoaiTeBalance), 0) AS SoTienUSD
			|FROM
			|	AccumulationRegister.CongNoPhaiTra.Balance(,
			|		PhapNhan = &PhapNhan AND DoiTac = &DoiTac AND HopDong = &HopDong AND ChungTuGoc = &ChungTuGoc)");
		Q_AP_Bal.SetParameter("PhapNhan", PhapNhan);
		Q_AP_Bal.SetParameter("DoiTac", DoiTac);
		Q_AP_Bal.SetParameter("HopDong", HopDong);
		Q_AP_Bal.SetParameter("ChungTuGoc", ChungTuGoc);
		T_AP_Bal = Q_AP_Bal.Execute().Unload();
		
		SoDuUSD_AP = ?(T_AP_Bal.Count() > 0, T_AP_Bal[0].SoTienUSD, 0);
		SoDuVND_AP = ?(T_AP_Bal.Count() > 0, T_AP_Bal[0].SoTienVND, 0);
		
		If SoDuUSD_AP <= 0 Or SoDuVND_AP <= 0 Then
			Raise StrTemplate("CONCURRENCY_OVERDRAW: Không tìm thấy số dư công nợ phải trả USD mở cho hóa đơn %1!", ChungTuGoc);
		EndIf;
		
		If SoTienNgoaiTe > SoDuUSD_AP Then
			Raise StrTemplate("CONCURRENCY_OVERDRAW: Số tiền ngoại tệ thanh toán (%1 USD) vượt quá số dư nợ còn lại (%2 USD)!", SoTienNgoaiTe, SoDuUSD_AP);
		EndIf;
		
		// Ty gia ghi so no AP
		TyGiaHoaDon = SoDuVND_AP / SoDuUSD_AP;
		
		// Neu tat toan toan bo USD con lai: lay toan bo VND con lai de tranh sai lech lam tron
		If SoTienNgoaiTe >= SoDuUSD_AP Then
			SoTienGhiSoAP = SoDuVND_AP;
		Else
			TyLeAP = SoTienNgoaiTe / SoDuUSD_AP;
			SoTienGhiSoAP = Round(SoDuVND_AP * TyLeAP, 0);
		EndIf;
		
		If MaTKTien = "1121" Then
			// TRUONG HOP A: Thanh toan tu tai khoan VND (1121)
			If SoTien > 0 Then
				SoTienThucTra = SoTien;
			ElsIf TyGia > 0 Then
				SoTienThucTra = Round(SoTienNgoaiTe * TyGia, 0);
			Else
				Raise "Lỗi thanh toán: Thiếu số tiền VND thực trừ hoặc tỷ giá thanh toán hợp lệ!";
			EndIf;
			
			ChenhLech = SoTienThucTra - SoTienGhiSoAP;
			If ChenhLech <> 0 Then
				CoChenhLechTyGia = True;
			EndIf;
		Else
			// TRUONG HOP B: Thanh toan bang USD co san trong tai khoan 1122
			// Lay gia tri ghi so thuc te tu so phu DongTien (Fail-Closed, khong dung AdditionalProperties hay fallback)
			Q_Bank_Bal = New Query(
				"SELECT
				|	ISNULL(SUM(SoTienBalance), 0) AS SoTienVND,
				|	ISNULL(SUM(SoTienNgoaiTeBalance), 0) AS SoTienUSD
				|FROM
				|	AccumulationRegister.DongTien.Balance(,
				|		PhapNhan = &PhapNhan AND TaiKhoanTien = &TaiKhoanTien AND TienTe = &TienTe)");
			Q_Bank_Bal.SetParameter("PhapNhan", PhapNhan);
			Q_Bank_Bal.SetParameter("TaiKhoanTien", TaiKhoanTien);
			Q_Bank_Bal.SetParameter("TienTe", TienTe);
			T_Bank_Bal = Q_Bank_Bal.Execute().Unload();
			
			SoDuUSD_Bank = ?(T_Bank_Bal.Count() > 0, T_Bank_Bal[0].SoTienUSD, 0);
			SoDuVND_Bank = ?(T_Bank_Bal.Count() > 0, T_Bank_Bal[0].SoTienVND, 0);
			
			If SoDuUSD_Bank <= 0 Or SoDuVND_Bank <= 0 Then
				Raise StrTemplate("CONCURRENCY_OVERDRAW: Tài khoản USD 1122 (%1) không có số dư ghi sổ để xuất quỹ!", TaiKhoanTien);
			EndIf;
			
			If SoTienNgoaiTe > SoDuUSD_Bank Then
				Raise StrTemplate("CONCURRENCY_OVERDRAW: Số tiền xuất quỹ (%1 USD) vượt quá số dư tài khoản 1122 (%2 USD)!", SoTienNgoaiTe, SoDuUSD_Bank);
			EndIf;
			
			If SoTienNgoaiTe >= SoDuUSD_Bank Then
				SoTienThucTra = SoDuVND_Bank;
			Else
				TyGiaXuat1122 = SoDuVND_Bank / SoDuUSD_Bank;
				SoTienThucTra = Round(SoTienNgoaiTe * TyGiaXuat1122, 0);
			EndIf;
			
			ChenhLech = SoTienThucTra - SoTienGhiSoAP;
			If ChenhLech <> 0 Then
				CoChenhLechTyGia = True;
			EndIf;
		EndIf;
	Else
		// Thanh toan VND
		If SoTien <= 0 Then
			Raise "Số tiền lệnh chi VND phải lớn hơn 0!";
		EndIf;
		SoTienGhiSoAP = SoTien;
		SoTienThucTra = SoTien;
		ChenhLech = 0;
		CoChenhLechTyGia = False;
		Q_AP_VND = New Query(
			"SELECT ISNULL(SUM(SoTienBalance), 0) AS SoDu
			|FROM AccumulationRegister.CongNoPhaiTra.Balance(,
			| PhapNhan = &PN AND DoiTac = &Partner AND HopDong = &Contract AND ChungTuGoc = &Invoice)");
		Q_AP_VND.SetParameter("PN", PhapNhan);
		Q_AP_VND.SetParameter("Partner", DoiTac);
		Q_AP_VND.SetParameter("Contract", HopDong);
		Q_AP_VND.SetParameter("Invoice", ChungTuGoc);
		If Q_AP_VND.Execute().Unload()[0].SoDu < SoTienGhiSoAP Then
			Raise "CONCURRENCY_OVERDRAW: Số tiền thanh toán vượt số dư công nợ VND còn lại!";
		EndIf;
	EndIf;
	
	// Check the main cash debit and fee together if they share the same key.
	For Each CashKey In CashKeys Do
		RequiredCash = ?(CashKey.TaiKhoanTien = TaiKhoanTien And CashKey.TienTe = CurrencyCash, SoTienThucTra, 0);
		If PhiNganHang > 0 And CashKey.TaiKhoanTien = TaiKhoanTienPhi And CashKey.TienTe = TienTeVND Then
			RequiredCash = RequiredCash + PhiNganHang;
		EndIf;
		Q_Cash = New Query(
			"SELECT ISNULL(SUM(SoTienBalance), 0) AS SoDu
			|FROM AccumulationRegister.DongTien.Balance(,
			| PhapNhan = &PN AND TaiKhoanTien = &Bank AND TienTe = &Currency)");
		Q_Cash.SetParameter("PN", PhapNhan);
		Q_Cash.SetParameter("Bank", CashKey.TaiKhoanTien);
		Q_Cash.SetParameter("Currency", CashKey.TienTe);
		If Q_Cash.Execute().Unload()[0].SoDu < RequiredCash Then
			Raise "CONCURRENCY_OVERDRAW: Số tiền thực chi và phí vượt số dư tài khoản tiền còn lại!";
		EndIf;
	EndDo;

	// Ghi giam no AP tren CongNoPhaiTra (Expense) theo gia tri ghi so hoa don
	RegisterRecords.CongNoPhaiTra.Write = True;
	RecordAP = RegisterRecords.CongNoPhaiTra.Add();
	RecordAP.RecordType = AccumulationRecordType.Expense;
	RecordAP.Period = NgayHachToan;
	RecordAP.PhapNhan = PhapNhan;
	RecordAP.DoiTac = DoiTac;
	RecordAP.HopDong = HopDong;
	RecordAP.ChungTuGoc = ?(ValueIsFilled(ChungTuGoc), ChungTuGoc, Ref);
	RecordAP.SoTien = SoTienGhiSoAP;
	RecordAP.SoTienNgoaiTe = SoTienNgoaiTe;
	
	// Ghi giam tien tren DongTien (Expense) theo so tien thuc chi tu ngan hang
	RegisterRecords.DongTien.Write = True;
	RecordDT = RegisterRecords.DongTien.Add();
	RecordDT.RecordType = AccumulationRecordType.Expense;
	RecordDT.Period = NgayHachToan;
	RecordDT.PhapNhan = PhapNhan;
	RecordDT.TaiKhoanTien = TaiKhoanTien;
	RecordDT.KhoanMucDongTien = KhoanMucDongTien;
	RecordDT.TienTe = ?(MaTKTien = "1122", TienTe, TienTeVND);
	RecordDT.SoTien = SoTienThucTra;
	RecordDT.SoTienNgoaiTe = ?(MaTKTien = "1122", SoTienNgoaiTe, 0);
	
	// Ghi So cai SoCaiKeToan
	RegisterRecords.SoCaiKeToan.Write = True;
	
	If Not CoChenhLechTyGia Then
		Row1 = RegisterRecords.SoCaiKeToan.Add();
		Row1.Period = NgayHachToan;
		Row1.AccountDr = TKCongNo;
		Row1.AccountCr = TKTien;
		Row1.SoTien = SoTienThucTra;
		Row1.DienGiai = StrTemplate("Thanh toán tiền cho NCC theo UNC %1", Number);
		Row1.PhapNhan = PhapNhan;
		Row1.TienTe = TienTe;
		Row1.ChungTuGoc = ChungTuGoc;
		Row1.DoiTacNo = DoiTac;
		Row1.HopDongNo = HopDong;
		Row1.ChungTuGocNo = RecordAP.ChungTuGoc;
		Row1.TaiKhoanTienCo = TaiKhoanTien;
		Row1.TyGia = ?(TyGia > 0, TyGia, 1);
		If SoTienNgoaiTe > 0 Then
			Row1.SoTienNgoaiTe = SoTienNgoaiTe;
		EndIf;
	ElsIf ChenhLech > 0 Then
		// LO TY GIA (Vi du: No goc 2.5m, thuc tra 2.6m, lo FX 0.1m)
		// But toan 1: Giam no AP theo ty gia hoa don: No TK 331 / Co TKTien = SoTienGhiSoAP (2.5m)
		Row1 = RegisterRecords.SoCaiKeToan.Add();
		Row1.Period = NgayHachToan;
		Row1.AccountDr = TKCongNo;
		Row1.AccountCr = TKTien;
		Row1.SoTien = SoTienGhiSoAP;
		Row1.DienGiai = StrTemplate("Thanh toán nợ gốc NCC theo UNC %1 (tỷ giá gốc)", Number);
		Row1.PhapNhan = PhapNhan;
		Row1.TienTe = TienTe;
		Row1.ChungTuGoc = ChungTuGoc;
		Row1.DoiTacNo = DoiTac;
		Row1.HopDongNo = HopDong;
		Row1.ChungTuGocNo = RecordAP.ChungTuGoc;
		Row1.TaiKhoanTienCo = TaiKhoanTien;
		Row1.TyGia = TyGiaHoaDon;
		Row1.SoTienNgoaiTe = SoTienNgoaiTe;
		
		// But toan FX: Lo ty gia thuc hien: No TK 635 / Co TKTien = ChenhLech (0.1m)
		// Tong Co TKTien = 2.5m + 0.1m = 2.6m (SoTienThucTra)
		TK635 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("635");
		RowFX = RegisterRecords.SoCaiKeToan.Add();
		RowFX.Period = NgayHachToan;
		RowFX.AccountDr = TK635;
		RowFX.AccountCr = TKTien;
		RowFX.SoTien = ChenhLech;
		RowFX.DienGiai = StrTemplate("Lỗ tỷ giá thực hiện thanh toán UNC %1", Number);
		RowFX.PhapNhan = PhapNhan;
		RowFX.TienTe = TienTeVND;
		RowFX.ChungTuGoc = Ref;
		RowFX.TaiKhoanTienCo = TaiKhoanTien;
		RowFX.TyGia = 1;
	Else
		// LAI TY GIA (Vi du: No goc 2.5m, tien xuat quy 2.48m, lai FX 0.02m)
		// But toan 1: No TK 331 / Co TKTien = SoTienThucTra (2.48m)
		Row1 = RegisterRecords.SoCaiKeToan.Add();
		Row1.Period = NgayHachToan;
		Row1.AccountDr = TKCongNo;
		Row1.AccountCr = TKTien;
		Row1.SoTien = SoTienThucTra;
		Row1.DienGiai = StrTemplate("Thanh toán tiền cho NCC theo UNC %1", Number);
		Row1.PhapNhan = PhapNhan;
		Row1.TienTe = TienTe;
		Row1.ChungTuGoc = ChungTuGoc;
		Row1.DoiTacNo = DoiTac;
		Row1.HopDongNo = HopDong;
		Row1.ChungTuGocNo = RecordAP.ChungTuGoc;
		Row1.TaiKhoanTienCo = TaiKhoanTien;
		Row1.TyGia = ?(TyGia > 0, TyGia, 1);
		Row1.SoTienNgoaiTe = SoTienNgoaiTe;
		
		// But toan FX: Lai ty gia thuc hien: No TK 331 / Co TK 515 = -ChenhLech (0.02m)
		// Tong No TK 331 = 2.48m + 0.02m = 2.50m (bang dung gia tri no goc SoTienGhiSoAP)
		TK515 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("515");
		RowFX = RegisterRecords.SoCaiKeToan.Add();
		RowFX.Period = NgayHachToan;
		RowFX.AccountDr = TKCongNo;
		RowFX.AccountCr = TK515;
		RowFX.SoTien = -ChenhLech;
		RowFX.DienGiai = StrTemplate("Lãi tỷ giá thực hiện thanh toán UNC %1", Number);
		RowFX.PhapNhan = PhapNhan;
		RowFX.TienTe = TienTeVND;
		RowFX.ChungTuGoc = Ref;
		RowFX.DoiTacNo = DoiTac;
		RowFX.HopDongNo = HopDong;
		RowFX.ChungTuGocNo = RecordAP.ChungTuGoc;
		RowFX.TyGia = 1;
	EndIf;
	
	// But toan 2: Phi chuyen tien ngan hang (No 6427 / Co 1121) neu co
	If PhiNganHang > 0 Then
		// [FIX B21] Phi luon tru tu tai khoan VND (TaiKhoanTienPhi) nen So cai phai ghi Co 1121,
		// khong ghi Co 1122 (lam lech So cai 1122 voi so chi tiet tien cua tai khoan ngoai te).
		TKCoPhi = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1121");
		
		Row2 = RegisterRecords.SoCaiKeToan.Add();
		Row2.Period = NgayHachToan;
		Row2.AccountDr = TKPhiNganHang;
		Row2.AccountCr = TKCoPhi;
		Row2.SoTien = PhiNganHang;
		Row2.DienGiai = StrTemplate("Phí chuyển tiền ngân hàng UNC %1", Number);
		Row2.PhapNhan = PhapNhan;
		Row2.TienTe = TienTeVND;
		Row2.ChungTuGoc = ChungTuGoc;
		Row2.TyGia = 1;
		
		// Ghi them dong giam phi tren DongTien
		// Xac dinh tai khoan tien VND nguon cho phi (Fail-closed: khong ghi VND len so USD 1122)
		// Fee source was resolved, locked and checked before any balance reads.
		
		RecordFee = RegisterRecords.DongTien.Add();
		RecordFee.RecordType = AccumulationRecordType.Expense;
		RecordFee.Period = NgayHachToan;
		RecordFee.PhapNhan = PhapNhan;
		RecordFee.TaiKhoanTien = TaiKhoanTienPhi;
		Row2.TaiKhoanTienCo = TaiKhoanTienPhi;
		RecordFee.KhoanMucDongTien = KhoanMucDongTien;
		RecordFee.TienTe = TienTeVND;
		RecordFee.SoTien = PhiNganHang;
		RecordFee.SoTienNgoaiTe = 0;
	EndIf;
	
	Try
		QuanLyVongDoiChungTuServer.KiemTraCanDoiSoCai(RegisterRecords.SoCaiKeToan);
	Except
		Cancel = True;
		WriteLogEvent("Posting.UyNhiemChi", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
		Raise;
	EndTry;
EndProcedure

#EndRegion
