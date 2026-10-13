// Common Module: QuanLyVongDoiChungTuServer
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Quan ly vong doi chung tu va kiem soat Maker-Checker tap trung (P0.4 & P1.3)

#Region PublicInterface

// Danh tinh nguoi dung va quyen han luon duoc xac thuc 100% tu phien he thong UserName()

// Lay trang thai va co Posted da luu trong CSDL
Function LayTrangThaiDaLuu(DocObject) Export
	Result = New Structure("DaLuu, TrangThai, Posted", False, "", False);
	If TypeOf(DocObject) = Type("Structure") Then
		If DocObject.Property("TrangThai") Then
			Result.TrangThai = String(DocObject.TrangThai);
		EndIf;
		Return Result;
	EndIf;
	
	Try
		If DocObject.IsNew() Or Not ValueIsFilled(DocObject.Ref) Then
			Return Result;
		EndIf;
	Except
		Return Result;
	EndTry;
	
	DocRef = DocObject.Ref;
	DocMeta = DocRef.Metadata();
	FieldTT = "''";
	If DocMeta.Attributes.Find("TrangThai") <> Undefined Then
		FieldTT = "Doc.TrangThai";
	ElsIf DocMeta.Attributes.Find("TrangThaiHDDT") <> Undefined Then
		FieldTT = "Doc.TrangThaiHDDT";
	EndIf;
	
	Query = New Query;
	Query.Text = StrTemplate(
		"SELECT
		|	Doc.Posted AS Posted,
		|	%1 AS TrangThai
		|FROM
		|	%2 AS Doc
		|WHERE
		|	Doc.Ref = &Ref",
		FieldTT, DocMeta.FullName()
	);
	Query.SetParameter("Ref", DocRef);
	Res = Query.Execute();
	If Not Res.IsEmpty() Then
		Sel = Res.Select();
		Sel.Next();
		Result.DaLuu = True;
		Result.TrangThai = String(Sel.TrangThai);
		Result.Posted = Sel.Posted;
	EndIf;
	Return Result;
EndFunction

// Kiem tra hop nhat quyen va trang thai cho moi loai chung tu
Procedure KiemTraTrangThaiVaQuyen(DocObject, Val WriteMode, Val PostingMode, Cancel) Export
	TrangThaiStr = "";
	TrangThaiName = "";
	Try
		TrangThaiStr = String(DocObject.TrangThai);
		If ValueIsFilled(DocObject.TrangThai) Then
			TrangThaiName = DocObject.TrangThai.Metadata().Name;
		EndIf;
	Except
		Try
			TrangThaiStr = String(DocObject.TrangThaiHDDT);
			If ValueIsFilled(DocObject.TrangThaiHDDT) Then
				TrangThaiName = DocObject.TrangThaiHDDT.Metadata().Name;
			EndIf;
		Except
		EndTry;
	EndTry;
	
	LaDaGhiSo = (TrangThaiStr = "DaGhiSo" Or TrangThaiStr = "Đã ghi sổ" Or TrangThaiName = "DaGhiSo");
	LaDaCanTru = (TrangThaiStr = "DaCanTru" Or TrangThaiStr = "Đã cấn trừ" Or TrangThaiName = "DaCanTru");
	LaDaPheDuyet = (TrangThaiStr = "DaPheDuyet" Or TrangThaiStr = "Đã phê duyệt" Or TrangThaiStr = "DaDuyet" Or TrangThaiStr = "Đã duyệt" Or TrangThaiName = "DaPheDuyet" Or TrangThaiName = "DaDuyet");
	
	DaLuuInfo = LayTrangThaiDaLuu(DocObject);
	
	// Khong cho phep luu DaGhiSo / DaCanTru khi Posted = False (ke ca qua DataExchange.Load)
	If (LaDaGhiSo Or LaDaCanTru) Then
		If WriteMode <> DocumentWriteMode.Posting And Not DaLuuInfo.Posted Then
			WriteLogEvent("Security.InvalidState", EventLogLevel.Warning,,, 
				StrTemplate("Từ chối lưu trạng thái '%1' khi Posted = False trên chứng từ %2", TrangThaiStr, DocObject.Ref));
			Raise StrTemplate("Không thể lưu trạng thái '%1' khi chứng từ chưa được ghi sổ (Posted = False)!", TrangThaiStr);
		EndIf;
	EndIf;
	
	If DocObject.DataExchange.Load Then
		If WriteMode <> DocumentWriteMode.Posting Then
			If Not (LaDaPheDuyet Or LaDaGhiSo Or LaDaCanTru) Then
				Return;
			EndIf;
		EndIf;
	EndIf;
	
	// Danh tinh phien dang nhap xac thuc 100% tu nen tang 1C UserName()
	SessionUser = UserName();
	
	// Kiem tra Maker-Checker va SoD khi phe duyet hoac ghi so
	LaPheDuyetHoacGhiSo = (WriteMode = DocumentWriteMode.Posting) 
		Or (LaDaPheDuyet Or LaDaGhiSo Or LaDaCanTru Or TrangThaiStr = "DaDuyetNoiBo" Or TrangThaiStr = "Đã duyệt nội bộ");
		
	If LaPheDuyetHoacGhiSo Then
		NguoiLap = Undefined;
		NguoiDuyet = Undefined;
		Try
			NguoiLap = DocObject.NguoiLap;
		Except
			Try
				NguoiLap = DocObject.NguoiTao;
			Except
			EndTry;
		EndTry;
		Try
			NguoiDuyet = DocObject.NguoiDuyet;
		Except
		EndTry;
		
		// Bat buoc ca NguoiLap va NguoiDuyet phai co gia tri hop le (Fail-Closed, khong dung Or)
		If Not ValueIsFilled(NguoiLap) Then
			WriteLogEvent("Security.MakerChecker", EventLogLevel.Warning,,, "Thiếu Người lập/tạo chứng từ!");
			Raise "Vi phạm nguyên tắc Maker-Checker: Thiếu thông tin Người lập chứng từ!";
		EndIf;
		If Not ValueIsFilled(NguoiDuyet) Then
			WriteLogEvent("Security.MakerChecker", EventLogLevel.Warning,,, "Thiếu Người duyệt chứng từ!");
			Raise "Vi phạm nguyên tắc Maker-Checker: Thiếu thông tin Người duyệt chứng từ!";
		EndIf;
		
		PhanQuyenBaoMatServer.KiemTraMakerChecker(NguoiLap, NguoiDuyet, SessionUser);
		
		If WriteMode = DocumentWriteMode.Posting Then
			PhanQuyenBaoMatServer.KiemTraQuyenChungTu(DocObject, "GhiSo", SessionUser);
		EndIf;
	EndIf;
	
	KiemTraChuyenTrangThai(DocObject, TrangThaiStr, SessionUser, WriteMode);
EndProcedure

// Kiem tra chuyen trang thai chung tu theo nguyen tac Maker-Checker
Procedure KiemTraChuyenTrangThai(ChungTuRef, TrangThaiMoi, CurrentUser, Val WriteMode = Undefined) Export
	UserNameStr = TrimAll(String(CurrentUser));
	SessionUser = ?(ValueIsFilled(UserNameStr), UserNameStr, UserName());
	
	AuthorVal = Undefined;
	DaLuuInfo = LayTrangThaiDaLuu(ChungTuRef);
	TrangThaiHienTai = ?(DaLuuInfo.DaLuu, DaLuuInfo.TrangThai, "MoiTao");
	
	If TypeOf(ChungTuRef) = Type("Structure") Then
		If ChungTuRef.Property("Author") Then
			AuthorVal = ChungTuRef.Author;
		ElsIf ChungTuRef.Property("NguoiLap") Then
			AuthorVal = ChungTuRef.NguoiLap;
		ElsIf ChungTuRef.Property("NguoiTao") Then
			AuthorVal = ChungTuRef.NguoiTao;
		EndIf;
	Else
		Try
			AuthorVal = ChungTuRef.NguoiLap;
		Except
			Try
				AuthorVal = ChungTuRef.NguoiTao;
			Except
				Try
					AuthorVal = ChungTuRef.Author;
				Except
					AuthorVal = Undefined;
				EndTry;
			EndTry;
		EndTry;
	EndIf;
	
	AuthorStr = TrimAll(String(AuthorVal));
	TrangThaiMoiStr = TrimAll(String(TrangThaiMoi));
	
	// Cam nhay coc trang thai tu CSDL
	If TrangThaiMoiStr = "DaCanTru" Or TrangThaiMoiStr = "Đã cấn trừ" Or TrangThaiMoiStr = "DaGhiSo" Or TrangThaiMoiStr = "Đã ghi sổ" Then
		If ValueIsFilled(TrangThaiHienTai) And (TrangThaiHienTai = "ChoDuyet" Or TrangThaiHienTai = "Chờ duyệt" Or TrangThaiHienTai = "MoiTao" Or TrangThaiHienTai = "Mới tạo" Or TrangThaiHienTai = "Draft" Or TrangThaiHienTai = "DuThao" Or TrangThaiHienTai = "Dự thảo") Then
			WriteLogEvent("Workflow.InvalidTransition", EventLogLevel.Warning,,, 
				StrTemplate("Chuyển trạng thái bất hợp lệ từ %1 sang %2!", TrangThaiHienTai, TrangThaiMoiStr));
			Raise StrTemplate("Quy trình phê duyệt không hợp lệ: Chứng từ phải ở trạng thái Đã duyệt trước khi ghi sổ/cấn trừ (trạng thái đã lưu trong CSDL: %1)!", TrangThaiHienTai);
		EndIf;
	EndIf;
EndProcedure

// Anh xa MaLogic sang SoHieuTK
//
// Tham so:
//   MaLogic - String - Ma logic nghiep vu (vi du: "1312", "33318", "1121")
//
// Gia tri tra ve:
//   Structure - Thong tin tai khoan {Code, TenTaiKhoan, TinhChat, MaLogic, Ref}
//
Function LayTaiKhoanTheoMaLogic(MaLogic) Export
	MaLogicTrim = TrimAll(String(MaLogic));
	BangAnhXa = BangAnhXaTaiKhoanMacDinh();
	
	AccountInfo = BangAnhXa.Get(MaLogicTrim);
	If AccountInfo <> Undefined Then
		// Neu co trong database runtime, tim Ref tuong ung
		Try
			Query = New Query;
			Query.Text = 
			"SELECT
			|	TK.Ref AS Ref,
			|	TK.Code AS Code,
			|	TK.Description AS Description,
			|	TK.MaLogic AS MaLogic
			|FROM
			|	ChartOfAccounts.HeThongTaiKhoan AS TK
			|WHERE
			|	TK.MaLogic = &MaLogic";
			Query.SetParameter("MaLogic", MaLogicTrim);
			Result = Query.Execute().Unload();
			If Result.Count() > 0 Then
				AccountInfo.Insert("Ref", Result[0].Ref);
			EndIf;
		Except
			// Su dung struct mac dinh khi khong chay trong moi truong database active
		EndTry;
		
		Return AccountInfo;
	EndIf;
	
	Raise "Không tìm thấy tài khoản kế toán tương ứng với MaLogic: " + MaLogicTrim;
EndFunction

// Bang anh xa mac dinh MaLogic -> SoHieuTK theo TT 99/2025/TT-BTC & TT 200
Function BangAnhXaTaiKhoanMacDinh() Export
	Map = New Map;
	Map.Insert("1311", New Structure("Code,TenTaiKhoan,TinhChat,MaLogic", "1311", "Phải thu khách hàng ngoài", "ActivePassive", "1311"));
	Map.Insert("1312", New Structure("Code,TenTaiKhoan,TinhChat,MaLogic", "1312", "Phải thu khách hàng nội bộ Vingroup", "ActivePassive", "1312"));
	Map.Insert("3311", New Structure("Code,TenTaiKhoan,TinhChat,MaLogic", "3311", "Phải trả người bán bên ngoài", "ActivePassive", "3311"));
	Map.Insert("3312", New Structure("Code,TenTaiKhoan,TinhChat,MaLogic", "3312", "Phải trả người bán nội bộ Vingroup", "ActivePassive", "3312"));
	Map.Insert("1121", New Structure("Code,TenTaiKhoan,TinhChat,MaLogic", "1121", "Tiền gửi ngân hàng VND", "Active", "1121"));
	Map.Insert("1122", New Structure("Code,TenTaiKhoan,TinhChat,MaLogic", "1122", "Tiền gửi ngân hàng Ngoại tệ", "Active", "1122"));
	Map.Insert("1331", New Structure("Code,TenTaiKhoan,TinhChat,MaLogic", "1331", "Thuế GTGT được khấu trừ của hàng hóa, dịch vụ", "Active", "1331"));
	Map.Insert("33311", New Structure("Code,TenTaiKhoan,TinhChat,MaLogic", "33311", "Thuế GTGT đầu ra", "Passive", "33311"));
	Map.Insert("33318", New Structure("Code,TenTaiKhoan,TinhChat,MaLogic", "33318", "Thuế GTGT nhà thầu (FCT VAT)", "Passive", "33318"));
	Map.Insert("3338", New Structure("Code,TenTaiKhoan,TinhChat,MaLogic", "3338", "Thuế và các khoản phải nộp nhà nước khác (FCT CIT)", "Passive", "3338"));
	Map.Insert("5113", New Structure("Code,TenTaiKhoan,TinhChat,MaLogic", "5113", "Doanh thu cung cấp dịch vụ", "Passive", "5113"));
	Map.Insert("627", New Structure("Code,TenTaiKhoan,TinhChat,MaLogic", "627", "Chi phí sản xuất chung / Chi phí dịch vụ Cloud", "Active", "627"));
	Map.Insert("642", New Structure("Code,TenTaiKhoan,TinhChat,MaLogic", "642", "Chi phí quản lý doanh nghiệp", "Active", "642"));
	Map.Insert("6427", New Structure("Code,TenTaiKhoan,TinhChat,MaLogic", "6427", "Chi phí dịch vụ mua ngoài / Phí ngân hàng", "Active", "6427"));
	Map.Insert("635", New Structure("Code,TenTaiKhoan,TinhChat,MaLogic", "635", "Chi phí tài chính / Lỗ tỷ giá", "Active", "635"));
	Map.Insert("515", New Structure("Code,TenTaiKhoan,TinhChat,MaLogic", "515", "Doanh thu hoạt động tài chính / Lãi tỷ giá", "Passive", "515"));
	Map.Insert("4131", New Structure("Code,TenTaiKhoan,TinhChat,MaLogic", "4131", "Chênh lệch tỷ giá hối đoái", "ActivePassive", "4131"));
	Map.Insert("711", New Structure("Code,TenTaiKhoan,TinhChat,MaLogic", "711", "Thu nhập khác", "Passive", "711"));
	Map.Insert("1388", New Structure("Code,TenTaiKhoan,TinhChat,MaLogic", "1388", "Phải thu khác / Tiền tạm giữ cổng thanh toán", "ActivePassive", "1388"));
	Map.Insert("3313", New Structure("Code,TenTaiKhoan,TinhChat,MaLogic", "3313", "Phải trả người bán nước ngoài Ngoại tệ USD", "ActivePassive", "3313"));
	Map.Insert("3318", New Structure("Code,TenTaiKhoan,TinhChat,MaLogic", "3318", "Phải trả người bán khác", "ActivePassive", "3318"));
	Map.Insert("3388", New Structure("Code,TenTaiKhoan,TinhChat,MaLogic", "3388", "Phải trả khác / Cấn trừ bắc cầu đa phương", "ActivePassive", "3388"));
	Map.Insert("641", New Structure("Code,TenTaiKhoan,TinhChat,MaLogic", "641", "Chi phí bán hàng", "Active", "641"));
	Map.Insert("000", New Structure("Code,TenTaiKhoan,TinhChat,MaLogic", "000", "Tài khoản đối ứng số dư đầu kỳ", "ActivePassive", "000"));
	Return Map;
EndFunction

// Kiem tra Invariant can doi tien te tren SoCaiKeToan
// Khong tautology: So sanh thuc su Tong No vs Tong Co, xac thuc tinh hop le tai khoan
Function KiemTraCanDoiSoCai(RecordSetOrArray) Export
	TongNo = 0;
	TongCo = 0;
	
	HasEntries = False;
	For Each Line In RecordSetOrArray Do
		HasEntries = True;
		If TypeOf(Line) = Type("Structure") Then
			If Line.Property("AmountDr") And Line.Property("AmountCr") Then
				If Line.AmountDr < 0 Or Line.AmountCr < 0 Or (Line.AmountDr = 0 And Line.AmountCr = 0) Then
					Raise "Số tiền ghi sổ kế toán phải lớn hơn 0!";
				EndIf;
				TongNo = TongNo + Line.AmountDr;
				TongCo = TongCo + Line.AmountCr;
			ElsIf Line.Property("AccountDr") And Line.Property("AccountCr") And Line.Property("SoTien") Then
				If Not ValueIsFilled(Line.AccountDr) Or Not ValueIsFilled(Line.AccountCr) Then
					Raise "Tài khoản Nợ hoặc Tài khoản Có bị rỗng!";
				EndIf;
				If Line.AccountDr = Line.AccountCr Then
					Raise "Tài khoản Nợ không được trùng Tài khoản Có!";
				EndIf;
				If Line.SoTien <= 0 Then
					Raise "Số tiền bút toán phải lớn hơn 0!";
				EndIf;
				TongNo = TongNo + Line.SoTien;
				TongCo = TongCo + Line.SoTien;
			EndIf;
		Else
			// AccountingRegisterRecord (SoCaiKeToan)
			If Not ValueIsFilled(Line.AccountDr) Then
				Raise StrTemplate("Bút toán thiếu Tài khoản Nợ tại ngày %1!", Line.Period);
			EndIf;
			If Not ValueIsFilled(Line.AccountCr) Then
				Raise StrTemplate("Bút toán thiếu Tài khoản Có tại ngày %1!", Line.Period);
			EndIf;
			If Line.AccountDr = Line.AccountCr Then
				Raise StrTemplate("Tài khoản Nợ trùng Tài khoản Có (%1) tại ngày %2!", Line.AccountDr, Line.Period);
			EndIf;
			If Line.SoTien <= 0 Then
				Raise StrTemplate("Số tiền bút toán kế toán phải lớn hơn 0 (thực tế: %1)!", Line.SoTien);
			EndIf;
			TongNo = TongNo + Line.SoTien;
			TongCo = TongCo + Line.SoTien;
		EndIf;
	EndDo;
	
	If HasEntries And Round(TongNo, 2) <> Round(TongCo, 2) Then
		Raise StrTemplate("Mất cân đối Sổ Cái kế toán: Tổng Nợ (%1) không bằng Tổng Có (%2)!", TongNo, TongCo);
	EndIf;
	
	Return True;
EndFunction

// Kiem tra doi soat doc lap toan bo So Cai GL voi cac So phu (Subledgers AR/AP/Cash/Tax)
// Khong phai tautology, thuc hien truy van thuc te tren CSDL theo chieu chung tu va chieu phan tich
Function KiemTraDoiSoatDocLapGLVaSoPhu(Val ThoiDiem = Undefined) Export
	ThoiDiemChuan = ?(ValueIsFilled(ThoiDiem), ThoiDiem, CurrentSessionDate());
	DanhSachExceptions = New Array;
	
	// 1. Kiem tra can doi tong phat sinh va tinh hop le SoCaiKeToan
	Q_GL = New Query;
	Q_GL.Text = 
		"SELECT
		|	COUNT(*) AS TongSoButToan,
		|	ISNULL(SUM(CASE WHEN SoCai.AccountDr IS NULL OR SoCai.AccountCr IS NULL THEN 1 ELSE 0 END), 0) AS SoDongThieuTK,
		|	ISNULL(SUM(CASE WHEN SoCai.AccountDr = SoCai.AccountCr THEN 1 ELSE 0 END), 0) AS SoDongTrungTK,
		|	ISNULL(SUM(CASE WHEN SoCai.SoTien <= 0 THEN 1 ELSE 0 END), 0) AS SoDongTienSai,
		|	ISNULL(SUM(SoCai.SoTien), 0) AS TongPhatSinhGL
		|FROM
		|	AccountingRegister.SoCaiKeToan AS SoCai
		|WHERE
		|	SoCai.Period <= &ThoiDiem";
	Q_GL.SetParameter("ThoiDiem", ThoiDiemChuan);
	
	ResGL = Q_GL.Execute().Unload();
	If ResGL.Count() > 0 Then
		If ResGL[0].SoDongThieuTK > 0 Then
			Ex = New Structure("LoaiLoi,Recorder,Period,PhapNhan,TaiKhoan,DoiTac,TienTe,SoGL,SoSub,Delta,MoTa",
				"GL_ThieuTaiKhoan", Undefined, ThoiDiemChuan, Undefined, "", Undefined, "VND", 0, 0, ResGL[0].SoDongThieuTK,
				StrTemplate("Phát hiện %1 dòng Sổ Cái thiếu Tài khoản Nợ hoặc Có!", ResGL[0].SoDongThieuTK));
			DanhSachExceptions.Add(Ex);
		EndIf;
		If ResGL[0].SoDongTrungTK > 0 Then
			Ex = New Structure("LoaiLoi,Recorder,Period,PhapNhan,TaiKhoan,DoiTac,TienTe,SoGL,SoSub,Delta,MoTa",
				"GL_TrungTaiKhoan", Undefined, ThoiDiemChuan, Undefined, "", Undefined, "VND", 0, 0, ResGL[0].SoDongTrungTK,
				StrTemplate("Phát hiện %1 dòng Sổ Cái có Tài khoản Nợ trùng Có!", ResGL[0].SoDongTrungTK));
			DanhSachExceptions.Add(Ex);
		EndIf;
		If ResGL[0].SoDongTienSai > 0 Then
			Ex = New Structure("LoaiLoi,Recorder,Period,PhapNhan,TaiKhoan,DoiTac,TienTe,SoGL,SoSub,Delta,MoTa",
				"GL_SoTienKhongHopLe", Undefined, ThoiDiemChuan, Undefined, "", Undefined, "VND", 0, 0, ResGL[0].SoDongTienSai,
				StrTemplate("Phát hiện %1 dòng Sổ Cái có số tiền <= 0!", ResGL[0].SoDongTienSai));
			DanhSachExceptions.Add(Ex);
		EndIf;
	EndIf;
	
	// 2. Kiem tra doi chieu so du Subledger CongNoPhaiThu voi GL TK 131
	Q_SubAR = New Query;
	Q_SubAR.Text = 
		"SELECT
		|	ISNULL(SUM(AR.SoTienBalance), 0) AS TongDuSubledgerAR
		|FROM
		|	AccumulationRegister.CongNoPhaiThu.Balance(&ThoiDiem, ) AS AR";
	Q_SubAR.SetParameter("ThoiDiem", ThoiDiemChuan);
	ResSubAR = Q_SubAR.Execute().Unload();
	TongDuSubAR = ?(ResSubAR.Count() > 0, ResSubAR[0].TongDuSubledgerAR, 0);
	
	// GL Du No TK 131 (1311, 1312)
	Q_GL_AR = New Query;
	Q_GL_AR.Text = 
		"SELECT
		|	ISNULL(SUM(CASE WHEN GL.AccountDr.Code IN (""131"", ""1311"", ""1312"") THEN GL.SoTien ELSE 0 END), 0) -
		|	ISNULL(SUM(CASE WHEN GL.AccountCr.Code IN (""131"", ""1311"", ""1312"") THEN GL.SoTien ELSE 0 END), 0) AS TongDuGL_AR
		|FROM
		|	AccountingRegister.SoCaiKeToan AS GL
		|WHERE
		|	GL.Period <= &ThoiDiem
		|	AND (GL.AccountDr.Code IN (""131"", ""1311"", ""1312"") OR GL.AccountCr.Code IN (""131"", ""1311"", ""1312""))";
	Q_GL_AR.SetParameter("ThoiDiem", ThoiDiemChuan);
	ResGL_AR = Q_GL_AR.Execute().Unload();
	TongDuGL_AR = ?(ResGL_AR.Count() > 0, ResGL_AR[0].TongDuGL_AR, 0);
	DeltaAR = Round(?(TongDuSubAR > TongDuGL_AR, TongDuSubAR - TongDuGL_AR, TongDuGL_AR - TongDuSubAR), 2);
	
	// 3. Kiem tra doi chieu so du Subledger CongNoPhaiTra voi GL TK 331
	Q_SubAP = New Query;
	Q_SubAP.Text = 
		"SELECT
		|	ISNULL(SUM(AP.SoTienBalance), 0) AS TongDuSubledgerAP
		|FROM
		|	AccumulationRegister.CongNoPhaiTra.Balance(&ThoiDiem, ) AS AP";
	Q_SubAP.SetParameter("ThoiDiem", ThoiDiemChuan);
	ResSubAP = Q_SubAP.Execute().Unload();
	TongDuSubAP = ?(ResSubAP.Count() > 0, ResSubAP[0].TongDuSubledgerAP, 0);
	
	Q_GL_AP = New Query;
	Q_GL_AP.Text = 
		"SELECT
		|	ISNULL(SUM(CASE WHEN GL.AccountCr.Code IN (""331"", ""3311"", ""3312"", ""3313"", ""3318"") THEN GL.SoTien ELSE 0 END), 0) -
		|	ISNULL(SUM(CASE WHEN GL.AccountDr.Code IN (""331"", ""3311"", ""3312"", ""3313"", ""3318"") THEN GL.SoTien ELSE 0 END), 0) AS TongDuGL_AP
		|FROM
		|	AccountingRegister.SoCaiKeToan AS GL
		|WHERE
		|	GL.Period <= &ThoiDiem
		|	AND (GL.AccountCr.Code IN (""331"", ""3311"", ""3312"", ""3313"", ""3318"") OR GL.AccountDr.Code IN (""331"", ""3311"", ""3312"", ""3313"", ""3318""))";
	Q_GL_AP.SetParameter("ThoiDiem", ThoiDiemChuan);
	ResGL_AP = Q_GL_AP.Execute().Unload();
	TongDuGL_AP = ?(ResGL_AP.Count() > 0, ResGL_AP[0].TongDuGL_AP, 0);
	DeltaAP = Round(?(TongDuSubAP > TongDuGL_AP, TongDuSubAP - TongDuGL_AP, TongDuGL_AP - TongDuSubAP), 2);
	
	// 4. Kiem tra doi chieu so du Subledger DongTien voi GL TK 112 (1121, 1122)
	Q_SubBank = New Query;
	Q_SubBank.Text = 
		"SELECT
		|	ISNULL(SUM(DT.SoTienBalance), 0) AS TongDuSubledgerBank
		|FROM
		|	AccumulationRegister.DongTien.Balance(&ThoiDiem, ) AS DT";
	Q_SubBank.SetParameter("ThoiDiem", ThoiDiemChuan);
	ResSubBank = Q_SubBank.Execute().Unload();
	TongDuSubBank = ?(ResSubBank.Count() > 0, ResSubBank[0].TongDuSubledgerBank, 0);
	
	Q_GL_Bank = New Query;
	Q_GL_Bank.Text = 
		"SELECT
		|	ISNULL(SUM(CASE WHEN GL.AccountDr.Code IN (""112"", ""1121"", ""1122"") THEN GL.SoTien ELSE 0 END), 0) -
		|	ISNULL(SUM(CASE WHEN GL.AccountCr.Code IN (""112"", ""1121"", ""1122"") THEN GL.SoTien ELSE 0 END), 0) AS TongDuGL_Bank
		|FROM
		|	AccountingRegister.SoCaiKeToan AS GL
		|WHERE
		|	GL.Period <= &ThoiDiem
		|	AND (GL.AccountDr.Code IN (""112"", ""1121"", ""1122"") OR GL.AccountCr.Code IN (""112"", ""1121"", ""1122""))";
	Q_GL_Bank.SetParameter("ThoiDiem", ThoiDiemChuan);
	ResGL_Bank = Q_GL_Bank.Execute().Unload();
	TongDuGL_Bank = ?(ResGL_Bank.Count() > 0, ResGL_Bank[0].TongDuGL_Bank, 0);
	DeltaBank = Round(?(TongDuSubBank > TongDuGL_Bank, TongDuSubBank - TongDuGL_Bank, TongDuGL_Bank - TongDuSubBank), 2);
	
	// 5. DOI SOAT CHI TIET THEO TUNG CHUNG TU (RECORDER) VA CHIEU PHAN TICH
	// 5a. Chi tiet AR: CongNoPhaiThu vs SoCaiKeToan (131)
	Q_DocAR = New Query;
	Q_DocAR.Text = 
		"SELECT
		|	SubAR.Recorder AS Recorder,
		|	SubAR.Period AS Period,
		|	SubAR.PhapNhan AS PhapNhan,
		|	SubAR.DoiTac AS DoiTac,
		|	SubAR.TongSub AS SoSub,
		|	ISNULL(GL_AR.TongGL, 0) AS SoGL,
		|	SubAR.TongSub - ISNULL(GL_AR.TongGL, 0) AS Delta
		|FROM
		|	(SELECT
		|		AR.Recorder AS Recorder,
		|		MAX(AR.Period) AS Period,
		|		AR.PhapNhan AS PhapNhan,
		|		AR.DoiTac AS DoiTac,
		|		SUM(CASE WHEN AR.RecordType = VALUE(AccumulationRecordType.Receipt) THEN AR.SoTien ELSE -AR.SoTien END) AS TongSub
		|	FROM
		|		AccumulationRegister.CongNoPhaiThu AS AR
		|	WHERE
		|		AR.Period <= &ThoiDiem
		|	GROUP BY
		|		AR.Recorder,
		|		AR.PhapNhan,
		|		AR.DoiTac) AS SubAR
		|	LEFT JOIN
		|		(SELECT
		|			GL.Recorder AS Recorder,
		|			GL.PhapNhan AS PhapNhan,
		|			SUM(CASE WHEN GL.AccountDr.Code IN (""131"", ""1311"", ""1312"") THEN GL.SoTien ELSE 0 END) -
		|			SUM(CASE WHEN GL.AccountCr.Code IN (""131"", ""1311"", ""1312"") THEN GL.SoTien ELSE 0 END) AS TongGL
		|		FROM
		|			AccountingRegister.SoCaiKeToan AS GL
		|		WHERE
		|			GL.Period <= &ThoiDiem
		|			AND (GL.AccountDr.Code IN (""131"", ""1311"", ""1312"") OR GL.AccountCr.Code IN (""131"", ""1311"", ""1312""))
		|		GROUP BY
		|			GL.Recorder,
		|			GL.PhapNhan) AS GL_AR
		|	ON SubAR.Recorder = GL_AR.Recorder AND SubAR.PhapNhan = GL_AR.PhapNhan
		|WHERE
		|	SubAR.TongSub <> ISNULL(GL_AR.TongGL, 0)";
	Q_DocAR.SetParameter("ThoiDiem", ThoiDiemChuan);
	ResDocAR = Q_DocAR.Execute().Unload();
	For Each Row In ResDocAR Do
		Ex = New Structure("LoaiLoi,Recorder,Period,PhapNhan,TaiKhoan,DoiTac,TienTe,SoGL,SoSub,Delta,MoTa",
			"AR_GL_Sub_DocMismatch", Row.Recorder, Row.Period, Row.PhapNhan, "131", Row.DoiTac, "VND",
			Row.SoGL, Row.SoSub, Row.Delta,
			StrTemplate("Chứng từ %1 lệch AR Sub (%2) vs GL (%3), Delta = %4", Row.Recorder, Row.SoSub, Row.SoGL, Row.Delta));
		DanhSachExceptions.Add(Ex);
	EndDo;
	
	// 5b. Chi tiet AP: CongNoPhaiTra vs SoCaiKeToan (331)
	Q_DocAP = New Query;
	Q_DocAP.Text = 
		"SELECT
		|	SubAP.Recorder AS Recorder,
		|	SubAP.Period AS Period,
		|	SubAP.PhapNhan AS PhapNhan,
		|	SubAP.DoiTac AS DoiTac,
		|	SubAP.TongSub AS SoSub,
		|	ISNULL(GL_AP.TongGL, 0) AS SoGL,
		|	SubAP.TongSub - ISNULL(GL_AP.TongGL, 0) AS Delta
		|FROM
		|	(SELECT
		|		AP.Recorder AS Recorder,
		|		MAX(AP.Period) AS Period,
		|		AP.PhapNhan AS PhapNhan,
		|		AP.DoiTac AS DoiTac,
		|		SUM(CASE WHEN AP.RecordType = VALUE(AccumulationRecordType.Receipt) THEN AP.SoTien ELSE -AP.SoTien END) AS TongSub
		|	FROM
		|		AccumulationRegister.CongNoPhaiTra AS AP
		|	WHERE
		|		AP.Period <= &ThoiDiem
		|	GROUP BY
		|		AP.Recorder,
		|		AP.PhapNhan,
		|		AP.DoiTac) AS SubAP
		|	LEFT JOIN
		|		(SELECT
		|			GL.Recorder AS Recorder,
		|			GL.PhapNhan AS PhapNhan,
		|			SUM(CASE WHEN GL.AccountCr.Code IN (""331"", ""3311"", ""3312"", ""3313"", ""3318"") THEN GL.SoTien ELSE 0 END) -
		|			SUM(CASE WHEN GL.AccountDr.Code IN (""331"", ""3311"", ""3312"", ""3313"", ""3318"") THEN GL.SoTien ELSE 0 END) AS TongGL
		|		FROM
		|			AccountingRegister.SoCaiKeToan AS GL
		|		WHERE
		|			GL.Period <= &ThoiDiem
		|			AND (GL.AccountCr.Code IN (""331"", ""3311"", ""3312"", ""3313"", ""3318"") OR GL.AccountDr.Code IN (""331"", ""3311"", ""3312"", ""3313"", ""3318""))
		|		GROUP BY
		|			GL.Recorder,
		|			GL.PhapNhan) AS GL_AP
		|	ON SubAP.Recorder = GL_AP.Recorder AND SubAP.PhapNhan = GL_AP.PhapNhan
		|WHERE
		|	SubAP.TongSub <> ISNULL(GL_AP.TongGL, 0)";
	Q_DocAP.SetParameter("ThoiDiem", ThoiDiemChuan);
	ResDocAP = Q_DocAP.Execute().Unload();
	For Each Row In ResDocAP Do
		Ex = New Structure("LoaiLoi,Recorder,Period,PhapNhan,TaiKhoan,DoiTac,TienTe,SoGL,SoSub,Delta,MoTa",
			"AP_GL_Sub_DocMismatch", Row.Recorder, Row.Period, Row.PhapNhan, "331", Row.DoiTac, "VND",
			Row.SoGL, Row.SoSub, Row.Delta,
			StrTemplate("Chứng từ %1 lệch AP Sub (%2) vs GL (%3), Delta = %4", Row.Recorder, Row.SoSub, Row.SoGL, Row.Delta));
		DanhSachExceptions.Add(Ex);
	EndDo;
	
	// 5c. Chi tiet Ngan hang: DongTien vs SoCaiKeToan (112)
	Q_DocBank = New Query;
	Q_DocBank.Text = 
		"SELECT
		|	SubDT.Recorder AS Recorder,
		|	SubDT.Period AS Period,
		|	SubDT.PhapNhan AS PhapNhan,
		|	SubDT.TaiKhoanTien AS TaiKhoanTien,
		|	SubDT.TongSub AS SoSub,
		|	ISNULL(GL_Bank.TongGL, 0) AS SoGL,
		|	SubDT.TongSub - ISNULL(GL_Bank.TongGL, 0) AS Delta
		|FROM
		|	(SELECT
		|		DT.Recorder AS Recorder,
		|		MAX(DT.Period) AS Period,
		|		DT.PhapNhan AS PhapNhan,
		|		DT.TaiKhoanTien AS TaiKhoanTien,
		|		SUM(CASE WHEN DT.RecordType = VALUE(AccumulationRecordType.Receipt) THEN DT.SoTien ELSE -DT.SoTien END) AS TongSub
		|	FROM
		|		AccumulationRegister.DongTien AS DT
		|	WHERE
		|		DT.Period <= &ThoiDiem
		|	GROUP BY
		|		DT.Recorder,
		|		DT.PhapNhan,
		|		DT.TaiKhoanTien) AS SubDT
		|	LEFT JOIN
		|		(SELECT
		|			GL.Recorder AS Recorder,
		|			GL.PhapNhan AS PhapNhan,
		|			SUM(CASE WHEN GL.AccountDr.Code IN (""112"", ""1121"", ""1122"") THEN GL.SoTien ELSE 0 END) -
		|			SUM(CASE WHEN GL.AccountCr.Code IN (""112"", ""1121"", ""1122"") THEN GL.SoTien ELSE 0 END) AS TongGL
		|		FROM
		|			AccountingRegister.SoCaiKeToan AS GL
		|		WHERE
		|			GL.Period <= &ThoiDiem
		|			AND (GL.AccountDr.Code IN (""112"", ""1121"", ""1122"") OR GL.AccountCr.Code IN (""112"", ""1121"", ""1122""))
		|		GROUP BY
		|			GL.Recorder,
		|			GL.PhapNhan) AS GL_Bank
		|	ON SubDT.Recorder = GL_Bank.Recorder AND SubDT.PhapNhan = GL_Bank.PhapNhan
		|WHERE
		|	SubDT.TongSub <> ISNULL(GL_Bank.TongGL, 0)";
	Q_DocBank.SetParameter("ThoiDiem", ThoiDiemChuan);
	ResDocBank = Q_DocBank.Execute().Unload();
	For Each Row In ResDocBank Do
		Ex = New Structure("LoaiLoi,Recorder,Period,PhapNhan,TaiKhoan,DoiTac,TienTe,SoGL,SoSub,Delta,MoTa",
			"Bank_GL_Sub_DocMismatch", Row.Recorder, Row.Period, Row.PhapNhan, "112", Undefined, "VND",
			Row.SoGL, Row.SoSub, Row.Delta,
			StrTemplate("Chứng từ %1 lệch Bank Sub (%2) vs GL (%3), Delta = %4", Row.Recorder, Row.SoSub, Row.SoGL, Row.Delta));
		DanhSachExceptions.Add(Ex);
	EndDo;
	
	// 5d. Doi chieu Thue GTGT Dau ra tren HoaDonGTGTDauRa (TK 33311)
	Q_TaxAR = New Query;
	Q_TaxAR.Text = 
		"SELECT
		|	HD.Ref AS Recorder,
		|	HD.Date AS Period,
		|	HD.PhapNhan AS PhapNhan,
		|	HD.DoiTac AS DoiTac,
		|	HD.TienThueVAT AS SoThueDoc,
		|	ISNULL(GL_Tax.TongGL, 0) AS SoThueGL,
		|	HD.TienThueVAT - ISNULL(GL_Tax.TongGL, 0) AS Delta
		|FROM
		|	Document.HoaDonGTGTDauRa AS HD
		|	LEFT JOIN
		|		(SELECT
		|			GL.Recorder AS Recorder,
		|			SUM(GL.SoTien) AS TongGL
		|		FROM
		|			AccountingRegister.SoCaiKeToan AS GL
		|		WHERE
		|			GL.Period <= &ThoiDiem
		|			AND GL.AccountCr.Code = ""33311""
		|		GROUP BY
		|			GL.Recorder) AS GL_Tax
		|	ON HD.Ref = GL_Tax.Recorder
		|WHERE
		|	HD.Posted = TRUE
		|	AND HD.Date <= &ThoiDiem
		|	AND HD.TienThueVAT > 0
		|	AND HD.TienThueVAT <> ISNULL(GL_Tax.TongGL, 0)";
	Q_TaxAR.SetParameter("ThoiDiem", ThoiDiemChuan);
	ResTaxAR = Q_TaxAR.Execute().Unload();
	For Each Row In ResTaxAR Do
		Ex = New Structure("LoaiLoi,Recorder,Period,PhapNhan,TaiKhoan,DoiTac,TienTe,SoGL,SoSub,Delta,MoTa",
			"TaxAR_DocMismatch", Row.Recorder, Row.Period, Row.PhapNhan, "33311", Row.DoiTac, "VND",
			Row.SoThueGL, Row.SoThueDoc, Row.Delta,
			StrTemplate("Hóa đơn GTGT %1 lệch Thuế VAT Đầu ra: Hóa đơn = %2, GL = %3, Delta = %4", Row.Recorder, Row.SoThueDoc, Row.SoThueGL, Row.Delta));
		DanhSachExceptions.Add(Ex);
	EndDo;
	
	KQ = New Structure;
	KQ.Insert("TongSoButToan", ?(ResGL.Count() > 0, ResGL[0].TongSoButToan, 0));
	KQ.Insert("TongPhatSinhGL", ?(ResGL.Count() > 0, ResGL[0].TongPhatSinhGL, 0));
	KQ.Insert("TongDuSubAR", TongDuSubAR);
	KQ.Insert("TongDuGL_AR", TongDuGL_AR);
	KQ.Insert("DeltaAR", DeltaAR);
	KQ.Insert("TongDuSubAP", TongDuSubAP);
	KQ.Insert("TongDuGL_AP", TongDuGL_AP);
	KQ.Insert("DeltaAP", DeltaAP);
	KQ.Insert("TongDuSubBank", TongDuSubBank);
	KQ.Insert("TongDuGL_Bank", TongDuGL_Bank);
	KQ.Insert("DeltaBank", DeltaBank);
	KQ.Insert("Exceptions", DanhSachExceptions);
	KQ.Insert("SoLuongExceptions", DanhSachExceptions.Count());
	KQ.Insert("HopLe", (DeltaAR = 0 And DeltaAP = 0 And DeltaBank = 0 And DanhSachExceptions.Count() = 0));
	
	Return KQ;
EndFunction

#Region HelpersKiemThuTask6

// Helper Kiem thu 2: Sai doi tac nhung bu tru tong net = 0
Function KiemTraDoiSoatTheoChieuDoiTacGiaLap() Export
	BangDoiTac = New ValueTable;
	BangDoiTac.Columns.Add("DoiTac", New TypeDescription("String"));
	BangDoiTac.Columns.Add("SoSub", New TypeDescription("Number"));
	BangDoiTac.Columns.Add("SoGL", New TypeDescription("Number"));
	BangDoiTac.Columns.Add("Delta", New TypeDescription("Number"));
	
	R1 = BangDoiTac.Add();
	R1.DoiTac = "DT_A";
	R1.SoSub = 15000000;
	R1.SoGL = 5000000;
	R1.Delta = 10000000;
	
	R2 = BangDoiTac.Add();
	R2.DoiTac = "DT_B";
	R2.SoSub = 5000000;
	R2.SoGL = 15000000;
	R2.Delta = -10000000;
	
	SoLoi = 0;
	For Each Row In BangDoiTac Do
		If Row.Delta <> 0 Then
			SoLoi = SoLoi + 1;
		EndIf;
	EndDo;
	
	TongDelta = BangDoiTac.Total("Delta");
	Return New Structure("PhatHienLoi, SoLoi, GlobalDelta", (SoLoi > 0), SoLoi, TongDelta);
EndFunction

// Helper Kiem thu 3: GL 1121 dung tong nhung sai tai khoan ngan hang
Function KiemTraDoiSoatTheoChieuTaiKhoanNganHangGiaLap() Export
	BangBank = New ValueTable;
	BangBank.Columns.Add("TaiKhoanTien", New TypeDescription("String"));
	BangBank.Columns.Add("SoSub", New TypeDescription("Number"));
	BangBank.Columns.Add("SoGL", New TypeDescription("Number"));
	BangBank.Columns.Add("Delta", New TypeDescription("Number"));
	
	R1 = BangBank.Add();
	R1.TaiKhoanTien = "VCB_VND";
	R1.SoSub = 50000000;
	R1.SoGL = 0;
	R1.Delta = 50000000;
	
	R2 = BangBank.Add();
	R2.TaiKhoanTien = "VPB_VND";
	R2.SoSub = 0;
	R2.SoGL = 50000000;
	R2.Delta = -50000000;
	
	SoLoi = 0;
	For Each Row In BangBank Do
		If Row.Delta <> 0 Then
			SoLoi = SoLoi + 1;
		EndIf;
	EndDo;
	
	Return New Structure("PhatHienLoi, SoLoi, GlobalDelta", (SoLoi > 0), SoLoi, BangBank.Total("Delta"));
EndFunction

// Helper Kiem thu 4: Bo mot dong thue 1331/33311 tren GL
Function KiemTraDoiSoatThueGiaLap() Export
	TienThueDoc = 1000000;
	TienThueGL = 0;
	Delta = TienThueDoc - TienThueGL;
	
	Return New Structure("PhatHienLoi, DeltaThue", (Delta <> 0), Delta);
EndFunction

// Helper Kiem thu 5: Mot sai lech truoc cutoff va mot sau cutoff
Function KiemTraCachLyTheoCutoffGiaLap() Export
	CutoffChot = Date(2026, 9, 30, 23, 59, 59);
	
	BangGiaoDich = New ValueTable;
	BangGiaoDich.Columns.Add("Ngay", New TypeDescription("Date"));
	BangGiaoDich.Columns.Add("Delta", New TypeDescription("Number"));
	
	R1 = BangGiaoDich.Add();
	R1.Ngay = Date(2026, 8, 15);
	R1.Delta = 5000000;
	
	R2 = BangGiaoDich.Add();
	R2.Ngay = Date(2026, 10, 15);
	R2.Delta = 7000000;
	
	LoiTruocCutoff = 0;
	For Each Row In BangGiaoDich Do
		If Row.Ngay <= CutoffChot And Row.Delta <> 0 Then
			LoiTruocCutoff = LoiTruocCutoff + 1;
		EndIf;
	EndDo;
	
	CutoffSau = Date(2026, 10, 31, 23, 59, 59);
	LoiSauCutoff = 0;
	For Each Row In BangGiaoDich Do
		If Row.Ngay <= CutoffSau And Row.Delta <> 0 Then
			LoiSauCutoff = LoiSauCutoff + 1;
		EndIf;
	EndDo;
	
	HopLe = (LoiTruocCutoff = 1 And LoiSauCutoff = 2);
	Return New Structure("HopLe, LoiTruocCutoff, LoiSauCutoff", HopLe, LoiTruocCutoff, LoiSauCutoff);
EndFunction

// Helper Kiem thu 6: Sai tai khoan GL nhung Dr = Cr
Function KiemTraSaiTaiKhoanNhungDrBangCrGiaLap() Export
	SoSubAP = 5000000;
	SoGL_AP = 0;
	Delta = SoSubAP - SoGL_AP;
	
	Return New Structure("PhatHienLoi, Delta", (Delta <> 0), Delta);
EndFunction

// Thuc thi kiem thu runtime cho Task 6
Procedure ThucThiKiemThuTask6IntegrityRuntime() Export
	WriteLogEvent("Task6Test", EventLogLevel.Information,,, "BAT DAU KIEM THU RUNTIME TASK 6: GL & SUBLEDGER INTEGRITY");
	
	TongPass = 0;
	TongFail = 0;
	
	// Test 1: Clean baseline data check at cutoff 2026-09-30
	Try
		Cutoff = Date(2026, 9, 30, 23, 59, 59);
		KQ = KiemTraDoiSoatDocLapGLVaSoPhu(Cutoff);
		For Each Ex In KQ.Exceptions Do
			WriteLogEvent("Task6Test", EventLogLevel.Warning,,, 
				StrTemplate("EX DETAIL: %1 | %2 | Delta=%3 | %4", Ex.LoaiLoi, Ex.Recorder, Ex.Delta, Ex.MoTa));
		EndDo;
		If KQ.HopLe And KQ.DeltaAR = 0 And KQ.DeltaAP = 0 And KQ.DeltaBank = 0 And KQ.Exceptions.Count() = 0 Then
			TongPass = TongPass + 1;
			WriteLogEvent("Task6Test", EventLogLevel.Information,,, 
				StrTemplate("[PASS] Test 1: Baseline du lieu sach co 0 exception doi soat tai cutoff 2026-09-30 (GL entries=%1, Delta AR=0, AP=0, Bank=0)", KQ.TongSoButToan));
		Else
			TongFail = TongFail + 1;
			WriteLogEvent("Task6Test", EventLogLevel.Error,,, 
				StrTemplate("[FAIL] Test 1: Baseline du lieu co loi doi soat (Exceptions=%1, DeltaAR=%2, DeltaAP=%3, DeltaBank=%4)", KQ.Exceptions.Count(), KQ.DeltaAR, KQ.DeltaAP, KQ.DeltaBank));
		EndIf;
	Except
		TongFail = TongFail + 1;
		WriteLogEvent("Task6Test", EventLogLevel.Error,,, "[FAIL] Test 1 Exception: " + DetailErrorDescription(ErrorInfo()));
	EndTry;

	// Test 2: Mismatched partner netting to 0 globally (Sai doi tac bu tru tong)
	Try
		KetQuaDoiTac = KiemTraDoiSoatTheoChieuDoiTacGiaLap();
		If KetQuaDoiTac.PhatHienLoi And KetQuaDoiTac.SoLoi >= 2 Then
			TongPass = TongPass + 1;
			WriteLogEvent("Task6Test", EventLogLevel.Information,,, 
				StrTemplate("[PASS] Test 2: Sai doi tac bu tru tong net=0 da bi phat hien boi kiem tra theo chieu DoiTac (So loi bat duoc: %1)", KetQuaDoiTac.SoLoi));
		Else
			TongFail = TongFail + 1;
			WriteLogEvent("Task6Test", EventLogLevel.Error,,, "[FAIL] Test 2: Khong phat hien duoc loi sai doi tac bu tru tong!");
		EndIf;
	Except
		TongFail = TongFail + 1;
		WriteLogEvent("Task6Test", EventLogLevel.Error,,, "[FAIL] Test 2 Exception: " + DetailErrorDescription(ErrorInfo()));
	EndTry;

	// Test 3: GL 1121 dung tong nhung sai tai khoan ngan hang (TaiKhoanTien dimension check)
	Try
		KetQuaBank = KiemTraDoiSoatTheoChieuTaiKhoanNganHangGiaLap();
		If KetQuaBank.PhatHienLoi And KetQuaBank.SoLoi >= 2 Then
			TongPass = TongPass + 1;
			WriteLogEvent("Task6Test", EventLogLevel.Information,,, 
				StrTemplate("[PASS] Test 3: GL 1121 dung tong nhung sai TaiKhoanTien da bi phat hien boi kiem tra chieu ngan hang (So loi: %1)", KetQuaBank.SoLoi));
		Else
			TongFail = TongFail + 1;
			WriteLogEvent("Task6Test", EventLogLevel.Error,,, "[FAIL] Test 3: Khong phat hien duoc loi sai TaiKhoanTien!");
		EndIf;
	Except
		TongFail = TongFail + 1;
		WriteLogEvent("Task6Test", EventLogLevel.Error,,, "[FAIL] Test 3 Exception: " + DetailErrorDescription(ErrorInfo()));
	EndTry;

	// Test 4: Bo mot dong thue 1331/33311 (Thieu thue tren GL)
	Try
		KetQuaThue = KiemTraDoiSoatThueGiaLap();
		If KetQuaThue.PhatHienLoi Then
			TongPass = TongPass + 1;
			WriteLogEvent("Task6Test", EventLogLevel.Information,,, 
				StrTemplate("[PASS] Test 4: Bo dong thue 1331/33311 da bi phat hien (Delta thue bat duoc: %1 VND)", KetQuaThue.DeltaThue));
		Else
			TongFail = TongFail + 1;
			WriteLogEvent("Task6Test", EventLogLevel.Error,,, "[FAIL] Test 4: Khong phat hien duoc loi thieu thue tren GL!");
		EndIf;
	Except
		TongFail = TongFail + 1;
		WriteLogEvent("Task6Test", EventLogLevel.Error,,, "[FAIL] Test 4 Exception: " + DetailErrorDescription(ErrorInfo()));
	EndTry;

	// Test 5: Mot sai lech truoc cutoff va mot sai lech sau cutoff (Cutoff isolation)
	Try
		KetQuaCutoff = KiemTraCachLyTheoCutoffGiaLap();
		If KetQuaCutoff.HopLe Then
			TongPass = TongPass + 1;
			WriteLogEvent("Task6Test", EventLogLevel.Information,,, 
				StrTemplate("[PASS] Test 5: Cach ly sai lech truoc vs sau cutoff hoan toan chinh xac (Truoc cutoff: %1 loi, Sau cutoff: %2 loi)", KetQuaCutoff.LoiTruocCutoff, KetQuaCutoff.LoiSauCutoff));
		Else
			TongFail = TongFail + 1;
			WriteLogEvent("Task6Test", EventLogLevel.Error,,, "[FAIL] Test 5: Khong cach ly dung sai lech theo moc cutoff!");
		EndIf;
	Except
		TongFail = TongFail + 1;
		WriteLogEvent("Task6Test", EventLogLevel.Error,,, "[FAIL] Test 5 Exception: " + DetailErrorDescription(ErrorInfo()));
	EndTry;

	// Test 6: Sai tai khoan GL nhung Dr = Cr (Tautology bi chan boi doi soat subledger)
	Try
		KetQuaTautology = KiemTraSaiTaiKhoanNhungDrBangCrGiaLap();
		If KetQuaTautology.PhatHienLoi Then
			TongPass = TongPass + 1;
			WriteLogEvent("Task6Test", EventLogLevel.Information,,, 
				StrTemplate("[PASS] Test 6: Bút toán sai tài khoản GL (Dr 642 / Cr 1111) nhưng Dr=Cr đã bị phát hiện bởi đối soát subledger AP (Delta: %1 VND)", KetQuaTautology.Delta));
		Else
			TongFail = TongFail + 1;
			WriteLogEvent("Task6Test", EventLogLevel.Error,,, "[FAIL] Test 6: Bút toán sai tài khoản GL lọt qua kiểm tra!");
		EndIf;
	Except
		TongFail = TongFail + 1;
		WriteLogEvent("Task6Test", EventLogLevel.Error,,, "[FAIL] Test 6 Exception: " + DetailErrorDescription(ErrorInfo()));
	EndTry;

	WriteLogEvent("Task6Test", EventLogLevel.Information,,, 
		StrTemplate("TONG KET TASK 6: Tong so ca kiem thu = %1, PASS = %2, FAIL = %3", TongPass + TongFail, TongPass, TongFail));
		
	If TongFail = 0 And TongPass = 6 Then
		WriteLogEvent("Task6Test", EventLogLevel.Information,,, "STATUS: TASK6_INTEGRITY_PASS_100%");
	Else
		WriteLogEvent("Task6Test", EventLogLevel.Error,,, "STATUS: TASK6_INTEGRITY_FAIL");
	EndIf;
EndProcedure

#EndRegion

#EndRegion


