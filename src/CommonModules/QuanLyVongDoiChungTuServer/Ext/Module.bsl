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
	
	// 1. Cho phep tai khoan he thong SA_BankingIntegration (tu dong ghi so BaoCoNganHang) bypass kiem tra nguoi dung
	UserNameStr = TrimAll(String(CurrentUser));
	If UserNameStr = "SA_BankingIntegration" Then
		Return;
	EndIf;
	
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
	
	// Neu khong co thong tin nguoi tao (chua xac dinh duoc author), tiep tuc
	If Not ValueIsFilled(AuthorVal) Then
		Return;
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
	Map.Insert("000", New Structure("Code,TenTaiKhoan,TinhChat,MaLogic", "000", "Tài khoản đối ứng số dư đầu kỳ", "ActivePassive", "000"));
	Return Map;
EndFunction

// Kiem tra Invariant can doi tien te tren SoCaiKeToan
// Invariant: Tong phat sinh No = Tong phat sinh Co (Delta Dr - Delta Cr = 0)
Function KiemTraCanDoiSoCai(RecordSetOrArray) Export
	TongNo = 0;
	TongCo = 0;
	
	For Each Line In RecordSetOrArray Do
		If TypeOf(Line) = Type("Structure") Then
			If Line.Property("AmountDr") And Line.Property("AmountCr") Then
				TongNo = TongNo + Line.AmountDr;
				TongCo = TongCo + Line.AmountCr;
			ElsIf Line.Property("SoTienNo") And Line.Property("SoTienCo") Then
				TongNo = TongNo + Line.SoTienNo;
				TongCo = TongCo + Line.SoTienCo;
			ElsIf Line.Property("AccountDr") And Line.Property("AccountCr") And Line.Property("SoTien") Then
				TongNo = TongNo + Line.SoTien;
				TongCo = TongCo + Line.SoTien;
			ElsIf Line.Property("SoTien") Then
				If Line.Property("LoaiPhatSinh") Then
					If Line.LoaiPhatSinh = "No" Or Line.LoaiPhatSinh = "Dr" Then
						TongNo = TongNo + Line.SoTien;
					ElsIf Line.LoaiPhatSinh = "Co" Or Line.LoaiPhatSinh = "Cr" Then
						TongCo = TongCo + Line.SoTien;
					EndIf;
				EndIf;
			EndIf;
		Else
			// AccountingRegisterRecord (so cai correspondence Dr/Cr)
			Try
				TienLine = Line.SoTien;
				TongNo = TongNo + TienLine;
				TongCo = TongCo + TienLine;
			Except
			EndTry;
		EndIf;
	EndDo;
	
	Variance = TongNo - TongCo;
	If Variance <> 0 Then
		Raise StrTemplate("Vi phạm Invariant cân đối tiền tệ Sổ cái: Tổng Nợ (%1) khác Tổng Có (%2), Chênh lệch: %3!", 
			TongNo, TongCo, Variance);
	EndIf;
	
	Return True;
EndFunction

// Thu tuc chay Scheduled Job dong bo SAP hang ngay
Procedure ThucHienDongBoBatchHangNgay() Export
	Processor = DataProcessors.DongBoButToanSAP.Create();
	Processor.ThucHienDongBoBatchHangNgay();
EndProcedure

#EndRegion
