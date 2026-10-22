// Common Module: QuanLyVongDoiChungTuServer
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Quan ly vong doi chung tu va kiem soat Maker-Checker tap trung (P0.4 & P1.3)

// Centralized logging helpers for client modules
Procedure GhiNhatKyInfo(Val EventName, Val Comment) Export
	WriteLogEvent(EventName, EventLogLevel.Information,,, Comment);
EndProcedure

Procedure GhiNhatKyError(Val EventName, Val Comment) Export
	WriteLogEvent(EventName, EventLogLevel.Error,,, Comment);
EndProcedure

#Region PublicInterface

Procedure KiemTraChoPhepSinhDuLieuMau(Val ExpectedRole = "QuanTriHeThong", Val AdditionalRole = "") Export
	HasRequiredRole = IsInRole(ExpectedRole);
	If ValueIsFilled(AdditionalRole) Then
		HasRequiredRole = HasRequiredRole Or IsInRole(AdditionalRole);
	EndIf;
	If InfoBaseUsers.GetUsers().Count() > 0 And Not HasRequiredRole Then
		Raise "SEED_FORBIDDEN: authenticated session does not have an allowed seed role.";
	EndIf;
EndProcedure

// Danh tinh nguoi dung va quyen han luon duoc xac thuc 100% tu phien he thong UserName()

// Lay trang thai va co Posted da luu trong CSDL
// Current availability under the same key lock as netting; exclude this
// recorder's old movements on repost. Historical PointInTime is retained
// in the interface only: later committed receipts must reduce availability.
Function LaySoDuARTheoChungTu(Val PN, Val Partner, Val SourceDoc, Val HistoricalPoint = Undefined, Val OwnRecorder = Undefined) Export
	Contract = SourceDoc.HopDong;
	LockObj = New DataLock;
	ARLockKey = LockObj.Add("AccumulationRegister.CongNoPhaiThu");
	ARLockKey.Mode = DataLockMode.Exclusive;
	ARLockKey.SetValue("PhapNhan", PN);
	ARLockKey.SetValue("DoiTac", Partner);
	ARLockKey.SetValue("HopDong", Contract);
	ARLockKey.SetValue("ChungTuGoc", SourceDoc);
	LockObj.Lock();
	Q = New Query("SELECT ISNULL(SUM(SoTienBalance), 0) AS Amount
		|FROM AccumulationRegister.CongNoPhaiThu.Balance(,
		| PhapNhan = &PN AND DoiTac = &Partner AND HopDong = &Contract AND ChungTuGoc = &Source)");
	Q.SetParameter("PN", PN);
	Q.SetParameter("Partner", Partner);
	Q.SetParameter("Contract", Contract);
	Q.SetParameter("Source", SourceDoc);
	Available = Q.Execute().Unload()[0].Amount;
	If ValueIsFilled(OwnRecorder) Then
		Old = AccumulationRegisters.CongNoPhaiThu.CreateRecordSet();
		Old.Filter.Recorder.Set(OwnRecorder);
		Old.Read();
		For Each R In Old Do
			If R.Active And R.PhapNhan = PN And R.DoiTac = Partner And R.HopDong = Contract And R.ChungTuGoc = SourceDoc Then
				Available = Available - ?(R.RecordType = AccumulationRecordType.Receipt, R.SoTien, -R.SoTien);
			EndIf;
		EndDo;
	EndIf;
	Return Available;
EndFunction

Function LayTrangThaiDaLuu(DocObject) Export
	Result = New Structure("DaLuu, TrangThai, Posted", False, "", False);
	If TypeOf(DocObject) = Type("Structure") Then
		If DocObject.Property("TrangThai") Then
			Result.TrangThai = TenTrangThai(DocObject.TrangThai);
			Result.DaLuu = ValueIsFilled(DocObject.TrangThai);
		EndIf;
		If DocObject.Property("Posted") Then Result.Posted = DocObject.Posted; EndIf;
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
		// [FIX B29] So sanh theo ten gia tri Enum (XMLString), khong theo synonym hien thi
		Result.TrangThai = TenTrangThai(Sel.TrangThai);
		Result.Posted = Sel.Posted;
	EndIf;
	Return Result;
EndFunction

// [FIX B29] Chuan hoa trang thai ve ten gia tri (vi du "DaGhiSo") de so sanh on dinh,
// khong phu thuoc ngon ngu giao dien hay Synonym cua Enum.
Function TenTrangThai(Val GiaTri) Export
	If GiaTri = Undefined Or GiaTri = Null Then
		Return "";
	EndIf;
	If TypeOf(GiaTri) = Type("String") Then
		Return ChuanHoaTenTrangThaiChuoi(GiaTri);
	EndIf;
	If Not ValueIsFilled(GiaTri) Then
		Return "";
	EndIf;
	Try
		Return XMLString(GiaTri);
	Except
		Return ChuanHoaTenTrangThaiChuoi(String(GiaTri));
	EndTry;
EndFunction

Function ChuanHoaTenTrangThaiChuoi(Val Chuoi)
	S = TrimAll(Chuoi);
	BangQuyDoi = New Map;
	BangQuyDoi.Insert("Mới tạo", "MoiTao");
	BangQuyDoi.Insert("Draft", "DuThao");
	BangQuyDoi.Insert("Dự thảo", "DuThao");
	BangQuyDoi.Insert("Chờ duyệt", "ChoDuyet");
	BangQuyDoi.Insert("Đã duyệt", "DaDuyet");
	BangQuyDoi.Insert("Đã phê duyệt", "DaPheDuyet");
	BangQuyDoi.Insert("Chờ duyệt nội bộ", "ChoDuyetNoiBo");
	BangQuyDoi.Insert("Đã duyệt nội bộ", "DaDuyetNoiBo");
	BangQuyDoi.Insert("Đã ghi sổ", "DaGhiSo");
	BangQuyDoi.Insert("Đã cấn trừ", "DaCanTru");
	BangQuyDoi.Insert("Từ chối", "TuChoi");
	BangQuyDoi.Insert("Hủy bỏ", "HuyBo");
	BangQuyDoi.Insert("Đã đối soát", "DaDoiSoat");
	BangQuyDoi.Insert("Hoàn tất", "HoanTat");
	BangQuyDoi.Insert("Đã hoàn tiền", "DaHoanTien");
	BangQuyDoi.Insert("Đã nhận hoàn tiền", "DaNhanHoanTien");
	BangQuyDoi.Insert("Chờ cấn trừ", "ChoCanTru");
	BangQuyDoi.Insert("Chờ tập đoàn duyệt", "ChoTapDoanDuyet");
	BangQuyDoi.Insert("Đã tất toán", "DaTatToan");
	QuyDoi = BangQuyDoi.Get(S);
	Return ?(QuyDoi = Undefined, S, QuyDoi);
EndFunction

// [FIX B29] Nhom quy trinh cua tung loai chung tu (dung cho bang chuyen trang thai hop le)
Function NhomQuyTrinhChungTu(Val DocObject)
	TenLoai = "";
	If TypeOf(DocObject) = Type("Structure") Then
		If DocObject.Property("LoaiChungTu") Then
			TenLoai = DocObject.LoaiChungTu;
		EndIf;
	Else
		Try
			TenLoai = DocObject.Metadata().Name;
		Except
			TenLoai = "";
		EndTry;
	EndIf;
	If TenLoai = "BienBanNghiemThuGiaiDoan" Then
		Return "NghiemThuAR";
	ElsIf TenLoai = "HoaDonNhaCungCap" Then
		Return "HoaDonAP";
	ElsIf TenLoai = "UyNhiemChi" Then
		LaHoanTien = False;
		Try
			LaHoanTien = DocObject.LaTraSoatHoanTra;
		Except
			LaHoanTien = False;
		EndTry;
		Return ?(LaHoanTien, "HoanTienAP", "LenhChi");
	ElsIf TenLoai = "HoaDonGTGTDauRa" Then
		Return "HoaDonDienTu";
	ElsIf TenLoai = "PhieuThuTienKhachHang" Then
		Return "LenhThu";
	EndIf;
	Return "Chung";
EndFunction

// [FIX B29] Danh sach CHO PHEP (whitelist): voi moi trang thai moi, liet ke cac trang thai
// da luu trong CSDL ma tu do duoc phep chuyen sang. "MoiTao" = chung tu chua tung duoc luu.
// Tra ve Undefined neu trang thai moi khong co trong bang (khong rang buoc them).
Function TrangThaiTruocHopLe(Val NhomQuyTrinh, Val TrangThaiMoi)
	B = New Map;
	If NhomQuyTrinh = "NghiemThuAR" Then
		B.Insert("DuThao", "MoiTao,ChoDuyetNoiBo,DaDuyetNoiBo");
		B.Insert("ChoDuyetNoiBo", "MoiTao,DuThao,DaDuyetNoiBo");
		B.Insert("DaDuyetNoiBo", "ChoDuyetNoiBo,ChoDoiTacKy");
		B.Insert("ChoDoiTacKy", "DaDuyetNoiBo");
		B.Insert("DaGhiSo", "DaDuyetNoiBo,ChoDoiTacKy");
		B.Insert("DaThanhToanMotPhan", "DaGhiSo,DaTatToan,TranhChap");
		B.Insert("DaTatToan", "DaGhiSo,DaThanhToanMotPhan,TranhChap");
		B.Insert("TranhChap", "DaGhiSo,DaThanhToanMotPhan,DaTatToan");
	ElsIf NhomQuyTrinh = "HoaDonAP" Then
		B.Insert("DuThao", "MoiTao,TuChoi");
		B.Insert("ChoKeToanTruongDuyet", "MoiTao,DuThao");
		B.Insert("ChoDuyetCFO", "ChoKeToanTruongDuyet");
		B.Insert("DaGhiSo", "ChoKeToanTruongDuyet,ChoDuyetCFO");
		B.Insert("TuChoi", "ChoKeToanTruongDuyet,ChoDuyetCFO");
	ElsIf NhomQuyTrinh = "NghiemThuAP" Then
		B.Insert("DuThao", "MoiTao,TuChoi");
		B.Insert("ChoKeToanAP", "MoiTao,DuThao");
		B.Insert("DaGhiSo", "ChoKeToanAP");
		B.Insert("TuChoi", "ChoKeToanAP");
	ElsIf NhomQuyTrinh = "LenhChi" Then
		B.Insert("DuThao", "MoiTao,ChoDuyet,TuChoi");
		B.Insert("ChoDuyet", "MoiTao,DuThao,TuChoi");
		B.Insert("DaDuyet", "ChoDuyet");
		B.Insert("DaGuiNganHang", "DaDuyet");
		B.Insert("DaGhiSo", "DaGuiNganHang");
		B.Insert("TuChoi", "ChoDuyet,DaDuyet,DaGuiNganHang");
		B.Insert("HuyBo", "MoiTao,DuThao,ChoDuyet,DaDuyet,TuChoi");
	ElsIf NhomQuyTrinh = "HoanTienAP" Then
		B.Insert("DuThao", "MoiTao,ChoDuyet,TuChoi");
		B.Insert("ChoDuyet", "MoiTao,DuThao,TuChoi");
		B.Insert("DaDuyet", "ChoDuyet");
		B.Insert("DaNhanHoanTien", "DaDuyet");
		B.Insert("DaGhiSo", "DaNhanHoanTien");
		B.Insert("TuChoi", "ChoDuyet,DaDuyet");
		B.Insert("HuyBo", "MoiTao,DuThao,ChoDuyet,DaDuyet,TuChoi");
	ElsIf NhomQuyTrinh = "DuyetDonGian" Then
		B.Insert("DuThao", "MoiTao,ChoDuyet,TuChoi");
		B.Insert("ChoDuyet", "MoiTao,DuThao,TuChoi");
		B.Insert("DaDuyet", "ChoDuyet");
		B.Insert("DaGhiSo", "DaDuyet");
		B.Insert("TuChoi", "ChoDuyet,DaDuyet");
		B.Insert("HuyBo", "MoiTao,DuThao,ChoDuyet,DaDuyet,TuChoi");
	ElsIf NhomQuyTrinh = "HoaDonDienTu" Then
		B.Insert("DuThao", "MoiTao");
		B.Insert("ChoKySo", "MoiTao,DuThao");
		B.Insert("DaPhatHanh", "ChoKySo");
		B.Insert("DaDieuChinh", "DaPhatHanh");
		B.Insert("DaThayThe", "DaPhatHanh");
		B.Insert("DaHuy", "DuThao,ChoKySo,DaPhatHanh");
	ElsIf NhomQuyTrinh = "TrangThaiChuoi" Then
		B.Insert("DuThao", "MoiTao,ChoDuyet,TuChoi");
		B.Insert("ChoDuyet", "MoiTao,DuThao,TuChoi");
		B.Insert("ChoDuyetNoiBo", "MoiTao,DuThao,TuChoi");
		B.Insert("ChoTapDoanDuyet", "ChoDuyetNoiBo");
		B.Insert("DaDuyet", "ChoDuyet,ChoDuyetNoiBo,ChoTapDoanDuyet");
		B.Insert("ChoCanTru", "DaDuyet,ChoTapDoanDuyet");
		B.Insert("DaDoiSoat", "DaDuyet");
		B.Insert("DaGhiSo", "DaDuyet,DaDoiSoat");
		B.Insert("DaCanTru", "DaDuyet,ChoCanTru");
		B.Insert("DaHoanTien", "DaDuyet");
		B.Insert("HoanTat", "DaDuyet,DaDoiSoat");
		B.Insert("DaTatToan", "DaCanTru");
		B.Insert("TuChoi", "ChoDuyet,ChoDuyetNoiBo,ChoTapDoanDuyet,DaDuyet,DaDoiSoat");
		B.Insert("HuyBo", "MoiTao,DuThao,ChoDuyet,ChoDuyetNoiBo,ChoTapDoanDuyet,DaDuyet,TuChoi");
	Else
		// Nhom chung (vi du Structure trong kiem thu): chi rang buoc cac trang thai ghi so cuoi cung.
		DaDuyetChung = "DaDuyet,DaPheDuyet,DaDuyetNoiBo,DaDoiSoat,DaGuiNganHang,ChoKeToanAP,ChoCanTru";
		B.Insert("DaGhiSo", DaDuyetChung);
		B.Insert("DaCanTru", DaDuyetChung);
	EndIf;
	Return B.Get(TrangThaiMoi);
EndFunction

// [FIX B08/M13] Voi chung tu co TrangThai kieu chuoi: chi chap nhan cac gia tri da khai bao.
Procedure KiemTraGiaTriTrangThaiChuoi(Val TrangThaiMoi)
	HopLe = ",DuThao,ChoDuyet,ChoDuyetNoiBo,ChoTapDoanDuyet,DaDuyet,DaNhanHoanTien,ChoCanTru,DaDoiSoat,DaGhiSo,DaCanTru,DaHoanTien,HoanTat,DaTatToan,TuChoi,HuyBo,";
	If ValueIsFilled(TrangThaiMoi) And StrFind(HopLe, "," + TrangThaiMoi + ",") = 0 Then
		Raise StrTemplate("Trạng thái '%1' không hợp lệ! Chỉ được chọn một trong: Dự thảo, Chờ duyệt, Đã duyệt, Đã nhận hoàn tiền, Đã đối soát, Đã ghi sổ, Đã cấn trừ, Đã hoàn tiền, Hoàn tất, Từ chối, Hủy bỏ.", TrangThaiMoi);
	EndIf;
EndProcedure

// Kiem tra hop nhat quyen va trang thai cho moi loai chung tu
Procedure KiemTraTrangThaiVaQuyen(DocObject, Val WriteMode, Val PostingMode, Cancel) Export
	// Enforce cross-domain write permissions before draft/import early returns.
	PhanQuyenBaoMatServer.KiemTraQuyenChungTu(DocObject, "Write", UserName());
	// [FIX B29] Lay ten gia tri trang thai (Enum name) thay vi chuoi hien thi / Metadata().Name
	TrangThaiStr = "";
	If TypeOf(DocObject) = Type("Structure") Then
		If DocObject.Property("TrangThai") Then
			TrangThaiStr = TenTrangThai(DocObject.TrangThai);
		ElsIf DocObject.Property("TrangThaiHDDT") Then
			TrangThaiStr = TenTrangThai(DocObject.TrangThaiHDDT);
		EndIf;
	Else
		DocAttributes = DocObject.Metadata().Attributes;
		If DocAttributes.Find("TrangThai") <> Undefined Then
			TrangThaiStr = TenTrangThai(DocObject.TrangThai);
		ElsIf DocAttributes.Find("TrangThaiHDDT") <> Undefined Then
			TrangThaiStr = TenTrangThai(DocObject.TrangThaiHDDT);
		EndIf;
	EndIf;
	
	LaDaGhiSo = (TrangThaiStr = "DaGhiSo");
	LaDaCanTru = (TrangThaiStr = "DaCanTru");
	LaDaPheDuyet = (TrangThaiStr = "DaPheDuyet" Or TrangThaiStr = "DaDuyet");
	
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
		Or (WriteMode <> DocumentWriteMode.UndoPosting And (LaDaPheDuyet Or LaDaGhiSo Or LaDaCanTru Or TrangThaiStr = "DaDuyetNoiBo"));
		
	If LaPheDuyetHoacGhiSo Then
		NguoiLap = Undefined;
		NguoiDuyet = Undefined;
		If TypeOf(DocObject) = Type("Structure") Then
			If DocObject.Property("NguoiLap") Then
				NguoiLap = DocObject.NguoiLap;
			ElsIf DocObject.Property("NguoiTao") Then
				NguoiLap = DocObject.NguoiTao;
			EndIf;
			If DocObject.Property("NguoiDuyet") Then
				NguoiDuyet = DocObject.NguoiDuyet;
			EndIf;
		Else
			DocAttributes = DocObject.Metadata().Attributes;
			If DocAttributes.Find("NguoiLap") <> Undefined Then
				NguoiLap = DocObject.NguoiLap;
			ElsIf DocAttributes.Find("NguoiTao") <> Undefined Then
				NguoiLap = DocObject.NguoiTao;
			EndIf;
			If DocAttributes.Find("NguoiDuyet") <> Undefined Then
				NguoiDuyet = DocObject.NguoiDuyet;
			EndIf;
		EndIf;
		
		// Bat buoc ca NguoiLap va NguoiDuyet phai co gia tri hop le (Fail-Closed, khong dung Or)
		If Not ValueIsFilled(NguoiLap) Then
			WriteLogEvent("Security.MakerChecker", EventLogLevel.Warning,,, "Thiếu Người lập/tạo chứng từ!");
			Raise "Vi phạm nguyên tắc Maker-Checker: Thiếu thông tin Người lập chứng từ!";
		EndIf;
		If Not ValueIsFilled(NguoiDuyet) Then
			WriteLogEvent("Security.MakerChecker", EventLogLevel.Warning,,, "Thiếu Người duyệt chứng từ!");
			Raise "Vi phạm nguyên tắc Maker-Checker: Thiếu thông tin Người duyệt chứng từ!";
		EndIf;
		
		UyQuyenGhiSoSauAdmin = False;
		If WriteMode = DocumentWriteMode.Posting
			And Upper(TrimAll(String(NguoiDuyet))) = "ADMIN"
			And (DocObject.Metadata().Name = "BienBanNghiemThuGiaiDoan" Or DocObject.Metadata().Name = "HoaDonGTGTDauRa") Then
			TrangThaiDaLuuChoUyQuyen = LayTrangThaiDaLuu(DocObject);
			TrangThaiCheckerDaLuu = "DaDuyetNoiBo";
			If DocObject.Metadata().Name = "HoaDonGTGTDauRa" Then
				TrangThaiCheckerDaLuu = "DaPhatHanh";
			EndIf;
			UyQuyenGhiSoSauAdmin = TrangThaiDaLuuChoUyQuyen.DaLuu
				And TenTrangThai(TrangThaiDaLuuChoUyQuyen.TrangThai) = TrangThaiCheckerDaLuu;
		EndIf;
		If UyQuyenGhiSoSauAdmin Then
			PhanQuyenBaoMatServer.KiemTraNguoiDuyetSauAdmin(DocObject);
		Else
			PhanQuyenBaoMatServer.KiemTraMakerChecker(NguoiLap, NguoiDuyet, SessionUser);
		EndIf;
		
		If WriteMode = DocumentWriteMode.Posting Then
			PhanQuyenBaoMatServer.KiemTraQuyenChungTu(DocObject, "GhiSo", SessionUser);
		EndIf;
	EndIf;
	
	KiemTraChuyenTrangThai(DocObject, TrangThaiStr, SessionUser, WriteMode);
EndProcedure

// Kiem tra chuyen trang thai chung tu theo nguyen tac Maker-Checker
// [FIX B29] Dung danh sach CHO PHEP (whitelist) thay vi danh sach cam; so sanh theo ten Enum.
Procedure KiemTraChuyenTrangThai(ChungTuRef, TrangThaiMoi, CurrentUser, Val WriteMode = Undefined) Export
	// [FIX B34] Danh tinh luon lay tu phien that, khong tin tham so truyen vao
	SessionUser = UserName();
	
	AuthorVal = Undefined;
	DaLuuInfo = LayTrangThaiDaLuu(ChungTuRef);
	TrangThaiHienTai = ?(DaLuuInfo.DaLuu, DaLuuInfo.TrangThai, "MoiTao");
	If Not ValueIsFilled(TrangThaiHienTai) Then
		TrangThaiHienTai = "MoiTao";
	EndIf;
	
	If TypeOf(ChungTuRef) = Type("Structure") Then
		If ChungTuRef.Property("Author") Then
			AuthorVal = ChungTuRef.Author;
		ElsIf ChungTuRef.Property("NguoiLap") Then
			AuthorVal = ChungTuRef.NguoiLap;
		ElsIf ChungTuRef.Property("NguoiTao") Then
			AuthorVal = ChungTuRef.NguoiTao;
		EndIf;
		If ChungTuRef.Property("NguoiDuyet") Then
			ApproverVal = ChungTuRef.NguoiDuyet;
			HasApproverField = True;
		EndIf;
	Else
		Try
			AuthorVal = ChungTuRef.NguoiLap;
		Except
			Try
				AuthorVal = ChungTuRef.NguoiTao;
			Except
				Try
					AuthorVal = ChungTuRef.NguoiDeNghi;
				Except
					AuthorVal = Undefined;
				EndTry;
			EndTry;
		EndTry;
		Try
			If ChungTuRef.Metadata().Attributes.Find("NguoiDuyet") <> Undefined Then
				ApproverVal = ChungTuRef.NguoiDuyet;
				HasApproverField = True;
			EndIf;
		Except
			HasApproverField = False;
		EndTry;
	EndIf;
	
	AuthorStr = TrimAll(String(AuthorVal));
	TrangThaiMoiStr = TenTrangThai(TrangThaiMoi);
	NhomQuyTrinh = NhomQuyTrinhChungTu(ChungTuRef);
	
	If NhomQuyTrinh = "TrangThaiChuoi" Then
		KiemTraGiaTriTrangThaiChuoi(TrangThaiMoiStr);
	EndIf;
	
	CoThayDoi = (TrangThaiMoiStr <> TrangThaiHienTai) And ValueIsFilled(TrangThaiMoiStr);
	LaAdmin = PhanQuyenBaoMatServer.LaPhienQuanTriHeThong();
	LaAdminCheckerDuocChiDinh = False;
	If LaAdmin And HasApproverField And Upper(TrimAll(String(ApproverVal))) = "ADMIN" Then
		TenLoaiChungTu = "";
		If TypeOf(ChungTuRef) = Type("Structure") Then
			If ChungTuRef.Property("MetadataName") Then
				TenLoaiChungTu = ChungTuRef.MetadataName;
			EndIf;
		Else
			Try
				TenLoaiChungTu = ChungTuRef.Metadata().Name;
			Except
				TenLoaiChungTu = "";
			EndTry;
		EndIf;
		LaChungTuARCanAdminChecker = (TenLoaiChungTu = "BienBanNghiemThuGiaiDoan" Or TenLoaiChungTu = "HoaDonGTGTDauRa");
		LaAdminCheckerDuocChiDinh = LaChungTuARCanAdminChecker
			And ((TrangThaiMoiStr = "DaDuyetNoiBo" And TrangThaiHienTai = "ChoDuyetNoiBo")
				Or (TrangThaiMoiStr = "DaPhatHanh" And TrangThaiHienTai = "ChoKySo"));
	EndIf;
	If LaAdmin And Not LaAdminCheckerDuocChiDinh And ((CoThayDoi And ((TrangThaiHienTai <> "MoiTao" And TrangThaiHienTai <> "DuThao") Or TrangThaiMoiStr <> "DuThao"))
		Or (DaLuuInfo.DaLuu And TrangThaiHienTai <> "MoiTao" And TrangThaiHienTai <> "DuThao")) Then
		WriteLogEvent("Security.SoD", EventLogLevel.Warning,,, StrTemplate("Phiên quản trị '%1' bị chặn chuyển trạng thái chứng từ tài chính từ '%2' sang '%3'.", SessionUser, TrangThaiHienTai, TrangThaiMoiStr));
		Raise "Quản trị hệ thống chỉ được lưu bản nháp; không được gửi duyệt, phê duyệt, phát hành, ghi sổ hoặc chuyển trạng thái chứng từ tài chính.";
	EndIf;
	
	// 1. Chặn Maker tự phê duyệt: người lập chỉ được lưu nháp / gửi duyệt / hủy, không được đẩy trạng thái đi tiếp
	NguoiLapDuocPhep = ",MoiTao,DuThao,ChoDuyet,ChoDuyetNoiBo,ChoDuyetKyThuat,ChoKySo,HuyBo,";
	If NhomQuyTrinh = "NghiemThuAP" Then
		NguoiLapDuocPhep = NguoiLapDuocPhep + "ChoKeToanAP,"; // buoc gui duyet cua nghiem thu thau phu
	ElsIf NhomQuyTrinh = "HoaDonAP" Then
		NguoiLapDuocPhep = NguoiLapDuocPhep + "ChoKeToanTruongDuyet,"; // gửi hóa đơn lên hàng đợi KTT, không phải tự phê duyệt
	EndIf;
	LaPhienNguoiLap = ValueIsFilled(AuthorStr) And Upper(SessionUser) = Upper(AuthorStr);
	If CoThayDoi And LaPhienNguoiLap And Not LaAdmin Then
		If StrFind(NguoiLapDuocPhep, "," + TrangThaiMoiStr + ",") = 0 Then
			WriteLogEvent("Security.MakerChecker", EventLogLevel.Warning,,, 
				StrTemplate("Người lập '%1' cố gắng tự chuyển trạng thái sang %2!", AuthorStr, TrangThaiMoiStr));
			Raise StrTemplate("Vi phạm nguyên tắc Maker-Checker: Người lập không thể tự chuyển chứng từ sang trạng thái '%1'!", TrangThaiMoiStr);
		EndIf;
	EndIf;
	// 1b. Người lập không được sửa nội dung (số tiền...) khi chứng từ đã rời khỏi tay mình (đã gửi duyệt / đang duyệt)
	If LaPhienNguoiLap And Not LaAdmin And DaLuuInfo.DaLuu And WriteMode <> DocumentWriteMode.UndoPosting
		And StrFind(NguoiLapDuocPhep, "," + TrangThaiHienTai + ",") = 0 Then
		WriteLogEvent("Security.MakerChecker", EventLogLevel.Warning,,, 
			StrTemplate("Người lập '%1' cố sửa chứng từ đang ở trạng thái %2", AuthorStr, TrangThaiHienTai));
		Raise StrTemplate("Người lập không được sửa chứng từ đã chuyển sang bước duyệt (trạng thái hiện tại: '%1')!", TrangThaiHienTai);
	EndIf;
	
	// 2. Chặn sửa trực tiếp trạng thái trên chứng từ đã ghi sổ: chỉ được đổi qua Ghi sổ lại hoặc Hủy ghi sổ
	// (đặt trước bước whitelist để thông báo đúng bản chất lỗi)
	If DaLuuInfo.Posted And CoThayDoi
		And WriteMode <> DocumentWriteMode.Posting And WriteMode <> DocumentWriteMode.UndoPosting Then
		WriteLogEvent("Workflow.DirectStateEdit", EventLogLevel.Warning,,, 
			StrTemplate("Từ chối sửa trực tiếp trạng thái từ %1 sang %2 trên chứng từ đã ghi sổ!", TrangThaiHienTai, TrangThaiMoiStr));
		Raise StrTemplate("CẤM SỬA TRỰC TIẾP: Chứng từ đã ghi sổ không được phép sửa trực tiếp trạng thái (từ '%1' sang '%2') khi chưa hủy ghi sổ!", TrangThaiHienTai, TrangThaiMoiStr);
	EndIf;
	
	// 3. Danh sách cho phép (whitelist) chuyển trạng thái
	LaTrangThaiCuoiChuaGhiSo = (TrangThaiHienTai = "DaGhiSo" Or TrangThaiHienTai = "DaCanTru"
		Or TrangThaiHienTai = "DaHoanTien" Or TrangThaiHienTai = "HoanTat") And Not DaLuuInfo.Posted;
	If CoThayDoi And WriteMode <> DocumentWriteMode.UndoPosting And Not LaTrangThaiCuoiChuaGhiSo Then
		DanhSachTruoc = TrangThaiTruocHopLe(NhomQuyTrinh, TrangThaiMoiStr);
		If DanhSachTruoc <> Undefined And StrFind("," + DanhSachTruoc + ",", "," + TrangThaiHienTai + ",") = 0 Then
			WriteLogEvent("Workflow.InvalidTransition", EventLogLevel.Warning,,, 
				StrTemplate("Chuyển trạng thái bất hợp lệ từ %1 sang %2!", TrangThaiHienTai, TrangThaiMoiStr));
			Raise StrTemplate("Quy trình phê duyệt không hợp lệ: không được chuyển từ trạng thái '%1' (đã lưu) sang '%2'. Chỉ được chuyển sang '%2' từ: %3.", 
				TrangThaiHienTai, TrangThaiMoiStr, DanhSachTruoc);
		EndIf;
	EndIf;
	
	// Any transition beyond maker-controlled draft/submission states must be done by the assigned checker.
	If CoThayDoi And HasApproverField And StrFind(NguoiLapDuocPhep, "," + TrangThaiMoiStr + ",") = 0 Then
		PhanQuyenBaoMatServer.KiemTraMakerChecker(AuthorVal, ApproverVal, SessionUser);
	EndIf;
EndProcedure

// [FIX B28] Nguoi lap luon do he thong gan bang phien dang nhap khi tao moi, va khong duoc sua ve sau.
//   TenTruong - ten thuoc tinh nguoi lap tren chung tu ("NguoiLap", "NguoiTao", "NguoiDeNghi").
Procedure GanNguoiLapKhiTaoMoi(DocObject, Val TenTruong = "NguoiLap") Export
	If DocObject.DataExchange.Load Then
		Return;
	EndIf;
	PhienHienTai = UserName();
	If DocObject.IsNew() Then
		DocObject[TenTruong] = PhienHienTai;
		Return;
	EndIf;
	
	Query = New Query;
	Query.Text = StrTemplate("SELECT Doc.%1 AS NguoiLap FROM %2 AS Doc WHERE Doc.Ref = &Ref",
		TenTruong, DocObject.Metadata().FullName());
	Query.SetParameter("Ref", DocObject.Ref);
	Sel = Query.Execute().Select();
	GiaTriDaLuu = "";
	If Sel.Next() Then
		GiaTriDaLuu = TrimAll(Sel.NguoiLap);
	EndIf;
	
	If ValueIsFilled(GiaTriDaLuu) Then
		If Upper(TrimAll(DocObject[TenTruong])) <> Upper(GiaTriDaLuu) Then
			WriteLogEvent("Security.MakerChecker", EventLogLevel.Warning,,, 
				StrTemplate("Từ chối sửa Người lập từ '%1' sang '%2' trên %3", GiaTriDaLuu, DocObject[TenTruong], DocObject.Ref));
			Raise StrTemplate("Không được sửa Người lập chứng từ (đang là '%1'). Người lập do hệ thống tự ghi nhận khi tạo chứng từ.", GiaTriDaLuu);
		EndIf;
	ElsIf Not ValueIsFilled(DocObject[TenTruong]) And Not DocObject.Posted Then
		// Chung tu nhap cu chua co nguoi lap: ghi nhan nguoi dang luu la nguoi lap.
		// Chung tu DA GHI SO cu thieu nguoi lap thi KHONG tu gan (neu gan, nguoi ghi so lai se thanh "nguoi lap"
		// va bi Maker-Checker chan); can bo sung Nguoi lap that (chay migration) truoc khi ghi so lai.
		DocObject[TenTruong] = PhienHienTai;
	EndIf;
EndProcedure

// [FIX B31] Xu ly huy ghi so: chi Ke toan truong / CFO duoc huy, khong duoc huy khi da co chung tu khac
// tham chieu, va dua trang thai ve buoc NGAY TRUOC ghi so (vi du "Da duyet", "Cho ke toan AP") de tranh ket
// o trang thai "Da ghi so" ma Posted = False. Ghi so lai van phai qua Maker-Checker (nguoi ghi so = Nguoi duyet).
// (Lech so voi plan: plan de xuat ve "Cho duyet"; nhom can chot - xem docs/06_LOG_SUA_LOI.md.)
//   TrangThaiSauHuy - gia tri trang thai gan lai sau khi huy (Enum hoac chuoi); Undefined = giu nguyen.
Procedure XuLyHuyGhiSo(DocObject, Cancel, Val TrangThaiSauHuy = Undefined, Val TenTruongTrangThai = "TrangThai") Export
	If DocObject.DataExchange.Load Then
		Return;
	EndIf;
	// Khong cho sua Nguoi lap trong lan huy ghi so (tranh: huy ghi so + doi nguoi lap -> tu duyet khi ghi so lai)
	For Each TenTruongNguoiLap In StrSplit("NguoiLap,NguoiTao,NguoiDeNghi", ",") Do
		If DocObject.Metadata().Attributes.Find(TenTruongNguoiLap) <> Undefined Then
			GanNguoiLapKhiTaoMoi(DocObject, TenTruongNguoiLap);
			Break;
		EndIf;
	EndDo;
	
	If Not (IsInRole("KeToanTruong") Or IsInRole("GiamDocTaiChinh_CFO")) Then
		WriteLogEvent("Security.UndoPosting", EventLogLevel.Warning,,, 
			StrTemplate("Người dùng '%1' không có quyền hủy ghi sổ %2", UserName(), DocObject.Ref));
		Cancel = True;
		Msg = New UserMessage;
		Msg.Text = NStr("vi = 'Chỉ Kế toán trưởng hoặc Giám đốc tài chính (CFO) được hủy ghi sổ chứng từ đã ghi sổ!'; en = 'Only the Chief Accountant or CFO can unpost a posted document!'");
		Msg.SetData(DocObject);
		Msg.Message();
		Return;
	EndIf;
	PhanQuyenBaoMatServer.KiemTraQuyenChungTu(DocObject, "HuyGhiSo", UserName());
	
	DanhSach = DanhSachChungTuPhuThuoc(DocObject.Ref);
	If DanhSach.Count() > 0 Then
		Cancel = True;
		Msg = New UserMessage;
		Msg.Text = StrTemplate(NStr("vi = 'Không thể hủy ghi sổ: còn %1 chứng từ khác đã ghi sổ đang tham chiếu tới chứng từ này (%2). Hãy hủy các chứng từ đó trước.'; en = 'Cannot unpost: %1 other posted documents reference this document (%2). Unpost them first.'"),
			DanhSach.Count(), StrConcat(DanhSach, "; "));
		Msg.SetData(DocObject);
		Msg.Message();
		Return;
	EndIf;
	
	If TrangThaiSauHuy <> Undefined Then
		DocObject[TenTruongTrangThai] = TrangThaiSauHuy;
	EndIf;
EndProcedure

// Danh sach (toi da 5) chung tu da ghi so khac co movement tham chieu ChungTuGoc = Ref
Function DanhSachChungTuPhuThuoc(Val Ref) Export
	KetQua = New Array;
	Query = New Query;
	Query.Text = 
		"SELECT
		|	AR.Recorder AS Recorder
		|FROM
		|	AccumulationRegister.CongNoPhaiThu AS AR
		|WHERE
		|	AR.ChungTuGoc = &Ref
		|	AND AR.Recorder <> &Ref
		|	AND AR.Active
		|
		|UNION
		|
		|SELECT
		|	AP.Recorder
		|FROM
		|	AccumulationRegister.CongNoPhaiTra AS AP
		|WHERE
		|	AP.ChungTuGoc = &Ref
		|	AND AP.Recorder <> &Ref
		|	AND AP.Active";
	Query.SetParameter("Ref", Ref);
	Sel = Query.Execute().Select();
	While Sel.Next() And KetQua.Count() < 5 Do
		KetQua.Add(String(Sel.Recorder));
	EndDo;
	If KetQua.Count() < 5 And TypeOf(Ref) = Type("DocumentRef.UyNhiemChi") Then
		// But toan hoan tra UNC tham chieu UNC goc qua thuoc tinh ChungTuGoc
		QueryHT = New Query;
		QueryHT.Text = 
			"SELECT TOP 5
			|	UNC.Ref AS Ref
			|FROM
			|	Document.UyNhiemChi AS UNC
			|WHERE
			|	UNC.ChungTuGoc = &Ref
			|	AND UNC.Ref <> &Ref
			|	AND UNC.Posted";
		QueryHT.SetParameter("Ref", Ref);
		SelHT = QueryHT.Execute().Select();
		While SelHT.Next() And KetQua.Count() < 5 Do
			KetQua.Add(String(SelHT.Ref));
		EndDo;
	EndIf;
	Return KetQua;
EndFunction

// [FIX B39/B02/B05/B17] Doi chieu that su so phu cong no voi So cai trong RegisterRecords cua chung tu:
//   AR: bien dong No - Co cua cac TK bat dau bang "131" phai bang Receipt - Expense cua CongNoPhaiThu.
//   AP: bien dong Co - No cua cac TK bat dau bang "331" phai bang Receipt - Expense cua CongNoPhaiTra.
// Tra ve True neu khop; neu lech: Cancel = True va thong bao cho nguoi dung.
Function KiemTraKhopGLVaSoPhu(DocObject, Val LoaiCongNo, Cancel) Export
	If LoaiCongNo = "AR" Then
		TienTo = "131";
		SoPhu = DocObject.RegisterRecords.CongNoPhaiThu;
	Else
		TienTo = "331";
		SoPhu = DocObject.RegisterRecords.CongNoPhaiTra;
	EndIf;
	
	BienDongGL = 0;
	For Each Dong In DocObject.RegisterRecords.SoCaiKeToan Do
		If Not ValueIsFilled(Dong.AccountDr) Or Not ValueIsFilled(Dong.AccountCr) Then
			Cancel = True;
			ThongBaoLoiChungTu(DocObject, NStr("vi = 'Bút toán sổ cái thiếu Tài khoản Nợ hoặc Tài khoản Có (kiểm tra danh mục tài khoản).'; en = 'GL entry is missing the debit or credit account.'"));
			Return False;
		EndIf;
		If Dong.SoTien <= 0 Then
			Cancel = True;
			ThongBaoLoiChungTu(DocObject, StrTemplate(NStr("vi = 'Số tiền bút toán sổ cái phải lớn hơn 0 (thực tế: %1).'; en = 'GL entry amount must be greater than 0 (actual: %1).'"), Dong.SoTien));
			Return False;
		EndIf;
		MaNo = Dong.AccountDr.Code;
		MaCo = Dong.AccountCr.Code;
		If StrStartsWith(MaNo, TienTo) Then
			BienDongGL = BienDongGL + ?(LoaiCongNo = "AR", Dong.SoTien, -Dong.SoTien);
		EndIf;
		If StrStartsWith(MaCo, TienTo) Then
			BienDongGL = BienDongGL + ?(LoaiCongNo = "AR", -Dong.SoTien, Dong.SoTien);
		EndIf;
	EndDo;
	
	BienDongSoPhu = 0;
	For Each Dong In SoPhu Do
		BienDongSoPhu = BienDongSoPhu + ?(Dong.RecordType = AccumulationRecordType.Receipt, Dong.SoTien, -Dong.SoTien);
	EndDo;
	
	If Round(BienDongGL, 2) <> Round(BienDongSoPhu, 2) Then
		Cancel = True;
		ThongBaoLoiChungTu(DocObject, StrTemplate(NStr("vi = 'Sổ chi tiết công nợ lệch Sổ cái: sổ chi tiết thay đổi %1, sổ cái TK %2 thay đổi %3. Kiểm tra lại tổng tiền, tiền thuế và tiền trước thuế trên chứng từ.'; en = 'Subledger does not match GL: subledger %1, GL account %2 change %3.'"),
			Format(BienDongSoPhu, "NFD=2; NG=3,0"), TienTo, Format(BienDongGL, "NFD=2; NG=3,0")));
		Return False;
	EndIf;
	Return True;
EndFunction

Procedure ThongBaoLoiChungTu(DocObject, Val NoiDung, Val TenTruong = "") Export
	Msg = New UserMessage;
	Msg.Text = NoiDung;
	If ValueIsFilled(TenTruong) Then
		Msg.Field = TenTruong;
	EndIf;
	Msg.SetData(DocObject);
	Msg.Message();
	WriteLogEvent("Posting.Validation", EventLogLevel.Warning,,, StrTemplate("%1: %2", DocObject.Ref, NoiDung));
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

#Region RuntimeIntegrityAndLifecycle

Function KiemThuDoiSoatDocLapMismatchRuntime() Export
	Cases = New Array;
	TransactionStarted = False;
	Try
		Baseline = KiemTraDoiSoatDocLapGLVaSoPhu(CurrentSessionDate());
		If Not Baseline.HopLe Or Baseline.Exceptions.Count() <> 0 Then
			Raise StrTemplate("GL/subledger baseline is not clean: AR=%1, AP=%2, Bank=%3, exceptions=%4.",
				Baseline.DeltaAR, Baseline.DeltaAP, Baseline.DeltaBank, Baseline.Exceptions.Count());
		EndIf;
		Cases.Add(New Structure("name,passed", "CleanBaseline", True));

		RecorderRef = LayChungTuPostedMoiNhat("HoaDonGTGTDauRa");
		If Not ValueIsFilled(RecorderRef) Then
			Raise "Integrity negative test requires a posted sales VAT invoice.";
		EndIf;

		Q_GL = New Query;
		Q_GL.Text =
			"SELECT TOP 1
			| GL.PhapNhan AS PhapNhan,
			| GL.TienTe AS TienTe
			|FROM
			| AccountingRegister.SoCaiKeToan AS GL
			|WHERE
			| GL.Recorder = &Recorder
			| AND (GL.AccountDr.Code IN (""131"", ""1311"", ""1312"")
			| OR GL.AccountCr.Code IN (""131"", ""1311"", ""1312""))";
		Q_GL.SetParameter("Recorder", RecorderRef);
		LockDimensions = Q_GL.Execute().Unload();
		If LockDimensions.Count() = 0 Then
			Raise StrTemplate("Posted AR invoice %1 has no GL receivable movement to corrupt for the negative test.", RecorderRef);
		EndIf;

		BeginTransaction();
		TransactionStarted = True;
		GLDataLock = New DataLock;
		GLKey = GLDataLock.Add("AccountingRegister.SoCaiKeToan");
		GLKey.Mode = DataLockMode.Exclusive;
		GLKey.SetValue("PhapNhan", LockDimensions[0].PhapNhan);
		GLKey.SetValue("TienTe", LockDimensions[0].TienTe);
		GLDataLock.Lock();

		GLRecords = AccountingRegisters.SoCaiKeToan.CreateRecordSet();
		GLRecords.Filter.Recorder.Set(RecorderRef);
		GLRecords.Read();
		ChangedMovement = False;
		For Each GLRecord In GLRecords Do
			If GLRecord.AccountDr.Code = "131" Or GLRecord.AccountDr.Code = "1311" Or GLRecord.AccountDr.Code = "1312"
				Or GLRecord.AccountCr.Code = "131" Or GLRecord.AccountCr.Code = "1311" Or GLRecord.AccountCr.Code = "1312" Then
				GLRecord.SoTien = GLRecord.SoTien + 1;
				ChangedMovement = True;
				Break;
			EndIf;
		EndDo;
		If Not ChangedMovement Then
			Raise StrTemplate("Posted AR invoice %1 has no editable GL receivable movement.", RecorderRef);
		EndIf;
		GLRecords.Write(True);

		Corrupted = KiemTraDoiSoatDocLapGLVaSoPhu(CurrentSessionDate());
		If Corrupted.HopLe Or Corrupted.Exceptions.Count() = 0 Then
			Raise "GL/subledger reconciliation failed to detect the one-VND mismatch in the real accounting register.";
		EndIf;
		DetectedARDelta = Corrupted.DeltaAR <> 0;
		DetectedRecorderMismatch = False;
		For Each Ex In Corrupted.Exceptions Do
			If Ex.LoaiLoi = "AR_GL_Sub_DocMismatch" And Ex.Recorder = RecorderRef Then
				DetectedRecorderMismatch = True;
			EndIf;
		EndDo;
		If Not DetectedARDelta Or Not DetectedRecorderMismatch Then
			Raise StrTemplate("GL/subledger reconciliation did not report expected AR and recorder mismatch (DeltaAR=%1, RecorderMismatch=%2).",
				Corrupted.DeltaAR, DetectedRecorderMismatch);
		EndIf;
		Cases.Add(New Structure("name,passed", "DetectsRealOneVNDGLSubledgerMismatch", True));

		RollbackTransaction();
		TransactionStarted = False;
		Restored = KiemTraDoiSoatDocLapGLVaSoPhu(CurrentSessionDate());
		If Not Restored.HopLe Or Restored.Exceptions.Count() <> 0
			Or Restored.DeltaAR <> 0 Or Restored.DeltaAP <> 0 Or Restored.DeltaBank <> 0 Then
			Raise StrTemplate("Rollback did not restore a clean GL/subledger state: AR=%1, AP=%2, Bank=%3, exceptions=%4.",
				Restored.DeltaAR, Restored.DeltaAP, Restored.DeltaBank, Restored.Exceptions.Count());
		EndIf;
		Cases.Add(New Structure("name,passed", "RollbackRestoresGLSubledgerIntegrity", True));
	Except
		If TransactionStarted And TransactionActive() Then
			RollbackTransaction();
		EndIf;
		Raise;
	EndTry;

	Return Cases;
EndFunction
Function KiemThuChuTrinhGhiSoRuntime() Export
	LogLines = New Array;
	LogLines.Add("=================================================================");
	LogLines.Add("   KIEM THU RUNTIME: CHU TRINH GHI SO (POST -> UNPOST -> REPOST) ");
	LogLines.Add("   Thoi gian bat dau: " + CurrentSessionDate());
	LogLines.Add("=================================================================");
	
	DanhSachThuTuHuy = New Array;
	DanhSachThuTuGhiLai = New Array;
	TongDocPass = 0;
	ZeroResidualPass = True;
	RepostParityPass = True;
	RollbackPass = True;
	TongDocCanTest = 0;
	
	Try
		SessionUser = Upper(TrimAll(UserName()));
		If SessionUser = "CFO_GIAMDOC" Then
			LifecycleRef = Documents.PhieuThuTienKhachHang.FindByNumber("E2E-PT-NT001", Date(2026, 10, 20, 14, 0, 0));
			LifecycleType = "PhieuThuTienKhachHang";
		ElsIf SessionUser = "KETOAN_TRUONG" Then
			LifecycleRef = Documents.CanTruCongNoNoiBo.FindByNumber("E2E-NET-001", Date(2026, 10, 20, 11, 0, 0));
			LifecycleType = "CanTruCongNoNoiBo";
		Else
			Raise "Posting lifecycle regression requires the assigned KTT or CFO session.";
		EndIf;
		If Not ValueIsFilled(LifecycleRef) Or Not LifecycleRef.Posted Then
			Raise StrTemplate("The assigned-approver lifecycle fixture is missing or unposted: %1.", LifecycleType);
		EndIf;
		LifecycleDoc = LifecycleRef.GetObject();
		If Upper(TrimAll(String(LifecycleDoc.NguoiDuyet))) <> SessionUser Then
			Raise StrTemplate("Lifecycle fixture %1 is assigned to %2, not the active approver %3.",
				LifecycleRef, LifecycleDoc.NguoiDuyet, UserName());
		EndIf;
		DanhSachThuTuHuy.Add(New Structure("type,ref", LifecycleType, LifecycleRef));
		DanhSachThuTuGhiLai.Add(New Structure("type,ref", LifecycleType, LifecycleRef));
		DanhSachRefChungTu = New Array;
		DanhSachRefChungTu.Add(LifecycleRef);
		TongDocCanTest = 1;
		DauVanBanDau = LayDauVanMovementsTheoDanhSach(DanhSachRefChungTu);
		TrangThaiBanDau = DauVanBanDau.Get(LifecycleRef);
		DanhSachThuTuHuy[0].Insert("original_movements", TrangThaiBanDau.Signature);
		DanhSachThuTuHuy[0].Insert("original_gl_count", TrangThaiBanDau.GLCount);
		DanhSachThuTuGhiLai[0].Insert("original_movements", TrangThaiBanDau.Signature);
		DanhSachThuTuGhiLai[0].Insert("original_gl_count", TrangThaiBanDau.GLCount);
		If TrangThaiBanDau.GLCount = 0 Then Raise StrTemplate("Lifecycle prerequisite has no GL movement: %1.", LifecycleRef); EndIf;
		LogLines.Add(StrTemplate("[*] Assigned-approver fixture selected: %1 (%2; approver=%3)", LifecycleType, LifecycleRef, LifecycleDoc.NguoiDuyet));
		BeginTransaction();
		For Each Entry In DanhSachThuTuHuy Do
			DocObj = Entry.ref.GetObject();
			DocObj.Write(DocumentWriteMode.UndoPosting);
		EndDo;
		DauVanSauHuy = LayDauVanMovementsTheoDanhSach(DanhSachRefChungTu);
		For Each Entry In DanhSachThuTuHuy Do
			SavedDoc = Entry.ref.GetObject();
			TrangThaiSauHuy = DauVanSauHuy.Get(Entry.ref);
			If SavedDoc.Posted Or TrangThaiSauHuy.TotalCount <> 0 Then
				ZeroResidualPass = False;
				Raise StrTemplate("Unposting left state or register movements for %1.", Entry.type);
			EndIf;
			LogLines.Add(StrTemplate("  [UNPOST] %1: zero movements verified", Entry.type));
		EndDo;
		For Each Entry In DanhSachThuTuGhiLai Do
			DocObj = Entry.ref.GetObject();
			If Entry.type = "BienBanNghiemThuGiaiDoan" Then
				DocObj.TrangThai = Enums.TrangThaiNghiemThuAR.DaDuyetNoiBo;
			ElsIf Entry.type = "HoaDonGTGTDauRa" Then
				DocObj.TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.DaPhatHanh;
			ElsIf Entry.type = "HoaDonNhaCungCap" Then
				DocObj.TrangThai = Enums.TrangThaiHoaDonAP.DaGhiSo;
			ElsIf Entry.type = "UyNhiemChi" Then
				DocObj.TrangThai = Enums.TrangThaiLenhThanhToan.DaGhiSo;
			EndIf;
			DocObj.Write(DocumentWriteMode.Posting);
			TongDocPass = TongDocPass + 1;
		EndDo;
		DauVanSauGhiLai = LayDauVanMovementsTheoDanhSach(DanhSachRefChungTu);
		For Each Entry In DanhSachThuTuGhiLai Do
			SavedDoc = Entry.ref.GetObject();
			TrangThaiSauGhiLai = DauVanSauGhiLai.Get(Entry.ref);
			If Not SavedDoc.Posted Or TrangThaiSauGhiLai.GLCount <> Entry.original_gl_count
				Or TrangThaiSauGhiLai.Signature <> Entry.original_movements Then
				RepostParityPass = False;
				Raise StrTemplate("Repost movements do not match the original rows for %1.", Entry.ref);
			EndIf;
			LogLines.Add(StrTemplate("  [REPOST] %1: %2 GL rows and all register rows match", Entry.type, TrangThaiSauGhiLai.GLCount));
		EndDo;
		RollbackTransaction();
		DauVanSauRollback = LayDauVanMovementsTheoDanhSach(DanhSachRefChungTu);
		For Each Entry In DanhSachThuTuHuy Do
			SavedDoc = Entry.ref.GetObject();
			TrangThaiSauRollback = DauVanSauRollback.Get(Entry.ref);
			If Not SavedDoc.Posted Or TrangThaiSauRollback.Signature <> Entry.original_movements Then
				RollbackPass = False;
				Raise StrTemplate("Rollback did not restore original posted state and movements for %1.", Entry.ref);
			EndIf;
		EndDo;
		LogLines.Add("  [ROLLBACK] Original posted states and movements restored");
	Except
		If TransactionActive() Then RollbackTransaction(); EndIf;
		RollbackPass = False;
		LogLines.Add(StrTemplate("[FAIL] Posting lifecycle exception: %1", DetailErrorDescription(ErrorInfo())));
	EndTry;
	
	// 4. Kiem tra doi soat doc lap toan bo GL vs Subledgers
	LogLines.Add("-----------------------------------------------------------------");
	LogLines.Add("   DOI SOAT DOC LAP GL VS SO PHU (AR / AP / NGAN HANG)          ");
	LogLines.Add("-----------------------------------------------------------------");
	DoiSoatKQ = KiemTraDoiSoatDocLapGLVaSoPhu();
	GLSubledgerPass = False;
	If DoiSoatKQ.HopLe And DoiSoatKQ.DeltaAR = 0 And DoiSoatKQ.DeltaAP = 0 And DoiSoatKQ.DeltaBank = 0 Then
		GLSubledgerPass = True;
		LogLines.Add(StrTemplate("  [PASS] GL vs Subledger: Delta AR = %1, Delta AP = %2, Delta Bank = %3 (GL_SUBLEDGER_DELTA_ZERO)", 
			DoiSoatKQ.DeltaAR, DoiSoatKQ.DeltaAP, DoiSoatKQ.DeltaBank));
	Else
		LogLines.Add(StrTemplate("  [FAIL] GL vs Subledger lech: Delta AR = %1, Delta AP = %2, Delta Bank = %3", 
			DoiSoatKQ.DeltaAR, DoiSoatKQ.DeltaAP, DoiSoatKQ.DeltaBank));
	EndIf;
	
	LogLines.Add("=================================================================");
	If TongDocPass = TongDocCanTest And ZeroResidualPass And RepostParityPass And RollbackPass And GLSubledgerPass Then
		LogLines.Add(">> XAC NHAN: POSTING_LIFECYCLE_ALL_PASS (100% DAT CHUAN RUNTIME)");
		LogLines.Add(">> MARKER: ZERO_RESIDUAL_VERIFIED");
		LogLines.Add(">> MARKER: REPOST_PARITY_VERIFIED");
		LogLines.Add(">> MARKER: TRANSACTION_ROLLBACK_VERIFIED");
		LogLines.Add(">> MARKER: GL_SUBLEDGER_DELTA_ZERO");
	Else
		LogLines.Add(">> XAC NHAN: POSTING_LIFECYCLE_FAIL");
	EndIf;
	LogLines.Add("=================================================================");
	
	// Results are returned to the per-run JSON writer; no shared log file.
	
	WriteLogEvent("PostingLifecycle.Runtime", EventLogLevel.Information,,, 
		StrTemplate("Posting Lifecycle Test: %1/%2 docs passed, ZeroResidual=%3, RepostParity=%4, GLSubledger=%5", 
			TongDocPass, TongDocCanTest, ZeroResidualPass, RepostParityPass, GLSubledgerPass));
	Cases = New Array;
	Cases.Add(New Structure("name,passed,error", "ZeroResidual", ZeroResidualPass And TongDocPass = TongDocCanTest, ?(ZeroResidualPass And TongDocPass = TongDocCanTest, "", StrConcat(LogLines, Chars.LF))));
	Cases.Add(New Structure("name,passed,error", "RepostParity", RepostParityPass And TongDocPass = TongDocCanTest, ?(RepostParityPass And TongDocPass = TongDocCanTest, "", StrConcat(LogLines, Chars.LF))));
	Cases.Add(New Structure("name,passed,error", "TransactionRollback", RollbackPass, ?(RollbackPass, "", StrConcat(LogLines, Chars.LF))));
	Cases.Add(New Structure("name,passed,error", "GLSubledger", GLSubledgerPass, ?(GLSubledgerPass, "", StrConcat(LogLines, Chars.LF))));
	Return Cases;
EndFunction

Function LayChungTuPostedMoiNhat(Val LoaiChungTu, Val DieuKienThem = "") Export
	Query = New Query("SELECT TOP 1 Ref FROM Document." + LoaiChungTu + " WHERE Posted = TRUE" + DieuKienThem + " ORDER BY Date DESC");
	Selection = Query.Execute().Unload();
	If Selection.Count() = 0 Then Return Undefined; EndIf;
	Return Selection[0].Ref;
EndFunction

Function LayDauVanMovements(DocRef, CountOnly = False) Export
	DanhSachChungTu = New Array;
	DanhSachChungTu.Add(DocRef);
	TrangThai = LayDauVanMovementsTheoDanhSach(DanhSachChungTu).Get(DocRef);
	If CountOnly Then
		Return String(TrangThai.GLCount) + ";" + String(TrangThai.ARCount) + ";" + String(TrangThai.APCount) + ";" + String(TrangThai.CashCount) + ";";
	EndIf;
	Return TrangThai.Signature;
EndFunction
Function LayDauVanMovementsTheoDanhSach(DanhSachChungTu)
	KetQua = New Map;
	If DanhSachChungTu.Count() = 0 Then
		Return KetQua;
	EndIf;

	Q_GL = New Query("SELECT * FROM AccountingRegister.SoCaiKeToan WHERE Recorder IN (&Recorders) ORDER BY Recorder, LineNumber");
	Q_GL.SetParameter("Recorders", DanhSachChungTu);
	BangGL = Q_GL.Execute().Unload();
	Q_AR = New Query("SELECT * FROM AccumulationRegister.CongNoPhaiThu WHERE Recorder IN (&Recorders) ORDER BY Recorder, LineNumber");
	Q_AR.SetParameter("Recorders", DanhSachChungTu);
	BangAR = Q_AR.Execute().Unload();
	Q_AP = New Query("SELECT * FROM AccumulationRegister.CongNoPhaiTra WHERE Recorder IN (&Recorders) ORDER BY Recorder, LineNumber");
	Q_AP.SetParameter("Recorders", DanhSachChungTu);
	BangAP = Q_AP.Execute().Unload();
	Q_Cash = New Query("SELECT * FROM AccumulationRegister.DongTien WHERE Recorder IN (&Recorders) ORDER BY Recorder, LineNumber");
	Q_Cash.SetParameter("Recorders", DanhSachChungTu);
	BangCash = Q_Cash.Execute().Unload();

	For Each DocRef In DanhSachChungTu Do
		DongGL = BangGL.Copy(New Structure("Recorder", DocRef));
		DongAR = BangAR.Copy(New Structure("Recorder", DocRef));
		DongAP = BangAP.Copy(New Structure("Recorder", DocRef));
		DongCash = BangCash.Copy(New Structure("Recorder", DocRef));
		Signature = ValueToStringInternal(New Structure("GL,AR,AP,Cash",
			ValueToStringInternal(DongGL), ValueToStringInternal(DongAR),
			ValueToStringInternal(DongAP), ValueToStringInternal(DongCash)));
		KetQua.Insert(DocRef, New Structure("Signature,GLCount,ARCount,APCount,CashCount,TotalCount",
			Signature, DongGL.Count(), DongAR.Count(), DongAP.Count(), DongCash.Count(),
			DongGL.Count() + DongAR.Count() + DongAP.Count() + DongCash.Count()));
	EndDo;
	Return KetQua;
EndFunction

#EndRegion

#EndRegion


