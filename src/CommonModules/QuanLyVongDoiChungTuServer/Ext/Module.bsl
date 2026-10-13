// Common Module: QuanLyVongDoiChungTuServer
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Quan ly vong doi chung tu va kiem soat Maker-Checker tap trung (P0.4 & P1.3)

#Region PublicInterface

// So du phai thu con lai cua mot chung tu goc tai thoi diem chi dinh.
Function LaySoDuARTheoChungTu(Val PhapNhan, Val DoiTac, Val ChungTuGoc, Val ThoiDiem) Export
	Query = New Query;
	Query.Text =
		"SELECT
		|	ISNULL(SUM(AR.SoTienBalance), 0) AS SoDuAR
		|FROM
		|	AccumulationRegister.CongNoPhaiThu.Balance(&ThoiDiem,
		|		PhapNhan = &PhapNhan
		|		AND DoiTac = &DoiTac
		|		AND ChungTuGoc = &ChungTuGoc) AS AR";
	Query.SetParameter("ThoiDiem", ThoiDiem);
	Query.SetParameter("PhapNhan", PhapNhan);
	Query.SetParameter("DoiTac", DoiTac);
	Query.SetParameter("ChungTuGoc", ChungTuGoc);
	Selection = Query.Execute().Select();
	If Selection.Next() Then
		Return Selection.SoDuAR;
	EndIf;
	Return 0;
EndFunction

// Kiem tra chuyen trang thai chung tu theo nguyen tac Maker-Checker
// 
// Tham so:
//   ChungTuRef    - DocumentRef, Structure - Chung tu can chuyen trang thai
//   TrangThaiMoi  - EnumRef, String        - Trang thai moi can chuyen den
//   CurrentUser   - String, CatalogRef     - Nguoi dung thuc hien thao tac phe duyet
//
Procedure KiemTraChuyenTrangThai(ChungTuRef, TrangThaiMoi, CurrentUser) Export
	
	UserNameStr = TrimAll(String(CurrentUser));
	
	// Xac dinh nguoi lap chung tu (Author)
	AuthorVal = Undefined;
	If TypeOf(ChungTuRef) = Type("Structure") Then
		If ChungTuRef.Property("Author") Then
			AuthorVal = ChungTuRef.Author;
		ElsIf ChungTuRef.Property("NguoiTao") Then
			AuthorVal = ChungTuRef.NguoiTao;
		EndIf;
	Else
		// DocumentRef hoac DocumentObject
		Try
			AuthorVal = ChungTuRef.Author;
		Except
			Try
				AuthorVal = ChungTuRef.NguoiTao;
			Except
				AuthorVal = Undefined;
			EndTry;
		EndTry;
	EndIf;
	
	AuthorStr = TrimAll(String(AuthorVal));
	
	// Bat buoc phai co thong tin nguoi tao khi phe duyet / ghi so
	If Not ValueIsFilled(AuthorVal) Then
		Raise "Vi phạm nguyên tắc Maker-Checker: Không thể phê duyệt/ghi sổ chứng từ khi thiếu thông tin Người lập (Author)!";
	EndIf;
	
	// Xac dinh loai chung tu co phai la UyNhiemChi hay khong
	IsUyNhiemChi = False;
	If TypeOf(ChungTuRef) = Type("Structure") Then
		If ChungTuRef.Property("DocumentType") And ChungTuRef.DocumentType = "UyNhiemChi" Then
			IsUyNhiemChi = True;
		ElsIf ChungTuRef.Property("MetadataName") And ChungTuRef.MetadataName = "UyNhiemChi" Then
			IsUyNhiemChi = True;
		EndIf;
	Else
		DocTypeName = "";
		Try
			DocTypeName = ChungTuRef.Metadata().Name;
		Except
			DocTypeName = String(TypeOf(ChungTuRef));
		EndTry;
		
		If DocTypeName = "UyNhiemChi" Or StrFind(DocTypeName, "DocumentRef.UyNhiemChi") > 0 Then
			IsUyNhiemChi = True;
		EndIf;
	EndIf;
	
	// 2. CAM TUYET DOI voi lenh chi tien UyNhiemChi: Nguoi lap khong duoc phep tham gia phe duyet
	If IsUyNhiemChi And AuthorStr = UserNameStr Then
		Raise "CẤM TUYỆT ĐỐI: Người lập lệnh chi tiền không được phép tham gia phê duyệt!";
	EndIf;
	
	// 3. Cam nguoi tao tu duyet (Maker-Checker, khong ngoai le Admin)
	If AuthorStr = UserNameStr Then
		Raise "Vi phạm nguyên tắc Maker-Checker: Người tạo không thể tự phê duyệt chứng từ!";
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
// Invariant: Tai khoan hop le, So tien > 0, Tai khoan No <> Tai khoan Co
Function KiemTraCanDoiSoCai(RecordSetOrArray) Export
	TongNo = 0;
	TongCo = 0;
	
	For Each Line In RecordSetOrArray Do
		If TypeOf(Line) = Type("Structure") Then
			If Line.Property("AmountDr") And Line.Property("AmountCr") Then
				If Line.AmountDr <= 0 Or Line.AmountCr <= 0 Then
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
	
	Return True;
EndFunction

// Kiem tra doi soat doc lap toan bo So Cai GL voi cac So phu (Subledgers AR/AP/Cash)
// Khong phai tautology, thuc hien truy van truc tiep tren CSDL
Function KiemTraDoiSoatDocLapGLVaSoPhu(Val ThoiDiem = Undefined) Export
	ThoiDiemChuan = ?(ValueIsFilled(ThoiDiem), ThoiDiem, CurrentSessionDate());
	
	// 1. Kiem tra can doi tong phat sinh So Cai SoCaiKeToan
	Q_GL = New Query;
	Q_GL.Text = 
		"SELECT
		|	COUNT(*) AS TongSoButToan,
		|	ISNULL(SUM(CASE WHEN SoCai.AccountDr IS NULL OR SoCai.AccountCr IS NULL THEN 1 ELSE 0 END), 0) AS SoDongThieuTK,
		|	ISNULL(SUM(CASE WHEN SoCai.AccountDr = SoCai.AccountCr THEN 1 ELSE 0 END), 0) AS SoDongTrungTK,
		|	ISNULL(SUM(CASE WHEN SoCai.SoTien <= 0 THEN 1 ELSE 0 END), 0) AS SoDongTienSai,
		|	ISNULL(SUM(SoCai.SoTien), 0) AS TongPhatSinhGL
		|FROM
		|	AccountingRegister.SoCaiKeToan AS SoCai";
	
	ResGL = Q_GL.Execute().Unload();
	If ResGL.Count() > 0 Then
		If ResGL[0].SoDongThieuTK > 0 Then
			Raise StrTemplate("Phát hiện %1 dòng Sổ Cái thiếu Tài khoản Nợ hoặc Có!", ResGL[0].SoDongThieuTK);
		EndIf;
		If ResGL[0].SoDongTrungTK > 0 Then
			Raise StrTemplate("Phát hiện %1 dòng Sổ Cái có Tài khoản Nợ trùng Có!", ResGL[0].SoDongTrungTK);
		EndIf;
		If ResGL[0].SoDongTienSai > 0 Then
			Raise StrTemplate("Phát hiện %1 dòng Sổ Cái có số tiền <= 0!", ResGL[0].SoDongTienSai);
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
	
	KQ = New Structure;
	KQ.Insert("TongSoButToan", ?(ResGL.Count() > 0, ResGL[0].TongSoButToan, 0));
	KQ.Insert("TongPhatSinhGL", ?(ResGL.Count() > 0, ResGL[0].TongPhatSinhGL, 0));
	KQ.Insert("TongDuSubAR", TongDuSubAR);
	KQ.Insert("TongDuGL_AR", TongDuGL_AR);
	KQ.Insert("DeltaAR", DeltaAR);
	KQ.Insert("TongDuSubAP", TongDuSubAP);
	KQ.Insert("TongDuGL_AP", TongDuGL_AP);
	KQ.Insert("DeltaAP", DeltaAP);
	KQ.Insert("HopLe", (DeltaAR = 0 And DeltaAP = 0));
	
	Return KQ;
EndFunction

#EndRegion

