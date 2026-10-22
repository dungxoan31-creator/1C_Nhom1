// Common Module: PheDuyetDaCapServer
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL / XML Metadata Version 2.15)
// Muc tieu: Quy tac phan cap phe duyet 4 cap AP, Anti-Split quet hoa don trong thang,
//           va nhanh phe duyet dac biet +1 CFO Unlock khi vuot ngan sach > 10% (Task 2.4).

Function LayBoNhoMoPhong() Export
	Return New Structure("BangHoaDonMoPhong, BangNganSachMoPhong", New Array, New Map);
EndFunction

#Region PublicInterface

// Xac dinh cap phe duyet co ban dua tren so tien hoa don / de nghi chi
// 
// Tham so:
//   SoTien - Number - Gia tri hoa don hoac de nghi chi (VND)
//
// Gia tri tra ve:
//   String - "TruongBoPhan" (<= 100tr)
//            "KeToanTruong" (> 100tr va <= 500tr)
//            "GiamDocKhoi"  (> 500tr va <= 2 ty)
//            "TongGiamDoc"  (> 2 ty)
//
Function XacDinhCapPheDuyetTheoSoTien(Val SoTien) Export
	If SoTien = Undefined Or SoTien = Null Then
		SoTien = 0;
	EndIf;
	
	SoTienChuan = Number(SoTien);
	
	If SoTienChuan <= 100000000 Then
		Return "TruongBoPhan";
	ElsIf SoTienChuan <= 500000000 Then
		Return "KeToanTruong";
	ElsIf SoTienChuan <= 2000000000 Then
		Return "GiamDocKhoi";
	Else
		Return "TongGiamDoc";
	EndIf;
EndFunction

// Tinh tong gia tri luy ke trong thang cua Nha cung cap de chong chia nho hoa don (Anti-Split)
//
// Tham so:
//   PhapNhan - CatalogRef.PhapNhan, String, Structure - Phap nhan thuc hien chi tra
//   DoiTac   - CatalogRef.DoiTac, String, Structure   - Nha cung cap dich vu
//   ThoiDiem - Date                                    - Thoi diem can xac dinh (mac dinh CurrentSessionDate())
//
// Gia tri tra ve:
//   Number - Tong gia tri cac hoa don trong cung thang duong lich (VND)
//
// [FIX B36] Dem ca hoa don dang cho duyet (chua bi tu choi, chua danh dau xoa), loai tru hoa don hien tai
// (LoaiTruRef) de khong cong 2 lan, va KHONG nuot loi truy van (loi -> dung lai thay vi coi luy ke = 0).
Function TinhTongLuyKeTrongThang(Val PhapNhan, Val DoiTac, Val ThoiDiem, Val LoaiTruRef = Undefined) Export
	ThoiDiemChuan = ?(ValueIsFilled(ThoiDiem), ThoiDiem, CurrentSessionDate());
	DauThang = BegOfMonth(ThoiDiemChuan);
	CuoiThang = EndOfMonth(ThoiDiemChuan);
	
	TongLuyKe = 0;
	
	// Hoa don NCC la nguon duy nhat cho Anti-Split; sổ AP da chua movement cua cung hoa don.
	// 2. Quet tu Document.HoaDonNhaCungCap (neu ton tai trong metadata database)
	If Metadata.Documents.Find("HoaDonNhaCungCap") <> Undefined Then
		QueryDoc = New Query;
		QueryDoc.Text = 
			"SELECT
			|	ISNULL(SUM(Doc.TongTien), 0) AS TongTien
			|FROM
			|	Document.HoaDonNhaCungCap AS Doc
			|WHERE
			|	(Doc.Posted = TRUE
			|		OR Doc.TrangThai <> VALUE(Enum.TrangThaiHoaDonAP.TuChoi) AND NOT Doc.DeletionMark)
			|	AND Doc.Ref <> &LoaiTruRef
			|	AND Doc.Date >= &DauThang
			|	AND Doc.Date <= &CuoiThang
			|	AND Doc.PhapNhan = &PhapNhan
			|	AND Doc.DoiTac = &DoiTac";
		
		ParamPN = LayRefPhapNhan(PhapNhan);
		ParamDT = LayRefDoiTac(DoiTac);
		
		QueryDoc.SetParameter("DauThang", DauThang);
		QueryDoc.SetParameter("CuoiThang", CuoiThang);
		QueryDoc.SetParameter("PhapNhan", ParamPN);
		QueryDoc.SetParameter("DoiTac", ParamDT);
		QueryDoc.SetParameter("LoaiTruRef", ?(ValueIsFilled(LoaiTruRef), LoaiTruRef, Documents.HoaDonNhaCungCap.EmptyRef()));
		
		ResDoc = QueryDoc.Execute().Unload();
		If ResDoc.Count() > 0 Then
			TongLuyKe = TongLuyKe + ResDoc[0].TongTien;
		EndIf;
	EndIf;
	
	// 3. Quet tu kho du lieu luy ke mo phong / kiem thu
	TongMoPhong = TinhTongHoaDonMoPhong(PhapNhan, DoiTac, DauThang, CuoiThang);
	TongLuyKe = TongLuyKe + TongMoPhong;
	
	Return TongLuyKe;
EndFunction

// Xac dinh cap phe duyet cuoi cung cua hoa don sau khi kiem tra co che Anti-Split
//
// Tham so:
//   PhapNhan - CatalogRef.PhapNhan, String, Structure - Phap nhan thuc hien chi tra
//   DoiTac   - CatalogRef.DoiTac, String, Structure   - Nha cung cap dich vu
//   SoTien   - Number                                  - Gia tri hoa don can duyet (VND)
//   ThoiDiem - Date                                    - Thoi diem phat sinh hoa don
//
// Gia tri tra ve:
//   String - Cap phe duyet da duoc leo thang neu tong luy ke vuot nguong cao hon
//
Function XacDinhCapPheDuyetHoaDon(Val PhapNhan, Val DoiTac, Val SoTien, Val ThoiDiem, Val LoaiTruRef = Undefined) Export
	SoTienHoaDon = Number(SoTien);
	ThoiDiemChuan = ?(ValueIsFilled(ThoiDiem), ThoiDiem, CurrentSessionDate());
	
	// 1. Tinh tong luy ke cua NCC trong thang truoc hoa don hien tai
	TongLuyKeTruoc = TinhTongLuyKeTrongThang(PhapNhan, DoiTac, ThoiDiemChuan, LoaiTruRef);
	
	// 2. Tong luy ke sau khi cong don hoa don hien tai
	TongLuyKeSauHoaDon = TongLuyKeTruoc + SoTienHoaDon;
	
	// 3. Cap phe duyet xet tren gia tri don le cua hoa don
	CapTheoSoTien = XacDinhCapPheDuyetTheoSoTien(SoTienHoaDon);
	
	// 4. Cap phe duyet xet tren tong luy ke thang de chong chia nho hoa don (Anti-Split)
	CapTheoLuyKe = XacDinhCapPheDuyetTheoSoTien(TongLuyKeSauHoaDon);
	
	// Quy tac leo thang: Lay cap cao hon giua don le va luy ke
	If LayThuTuCap(CapTheoLuyKe) > LayThuTuCap(CapTheoSoTien) Then
		Return CapTheoLuyKe;
	Else
		Return CapTheoSoTien;
	EndIf;
EndFunction

// Kiem tra dieu kien vuot ngan sach > 10% de yeu cau CFO phe duyet (+1 Special Unlock)
//
// Tham so:
//   PhapNhan          - CatalogRef.PhapNhan, String, Structure          - Phap nhan chi tieu
//   DuAn              - CatalogRef.DuAn, String, Structure              - Du an ap dung
//   KhoanMucDongTien  - CatalogRef.KhoanMucDongTien, String, Structure  - Khoan muc dong tien
//   ThoiDiem          - Date                                            - Thoi diem chi tieu
//   SoTienChi         - Number                                          - So tien de nghi chi trong hoa don (VND)
//
// Gia tri tra ve:
//   Boolean - True neu vuot > 10% ngan sach (bat buoc co chu ky CFO); False neu khong vuot
//
Function KiemTraYeuCauDuyetCFO(Val PhapNhan, Val DuAn, Val KhoanMucDongTien, Val ThoiDiem, Val SoTienChi) Export
	SoTienChiChuan = Number(SoTienChi);
	ThangChuan = BegOfMonth(?(ValueIsFilled(ThoiDiem), ThoiDiem, CurrentSessionDate()));
	
	NganSach = 0;
	DaDuyet = 0;
	ThucChi = 0;
	TimThay = False;
	
	// 1. Truy van tu InformationRegister.KeHoachChiTien trong database runtime
	Try
		If Metadata.InformationRegisters.Find("KeHoachChiTien") <> Undefined Then
			Query = New Query;
			Query.Text = 
				"SELECT TOP 1
				|	KeHoach.SoTienNganSach AS SoTienNganSach,
				|	KeHoach.SoTienDaDuyet AS SoTienDaDuyet,
				|	KeHoach.SoTienThucChi AS SoTienThucChi
				|FROM
				|	InformationRegister.KeHoachChiTien AS KeHoach
				|WHERE
				|	KeHoach.Thang = &Thang
				|	AND KeHoach.DuAn = &DuAn
				|	AND KeHoach.KhoanMucDongTien = &KhoanMucDongTien
				|	AND KeHoach.PhapNhan = &PhapNhan";
			
			ParamPN = LayRefPhapNhan(PhapNhan);
			ParamDA = LayRefDuAn(DuAn);
			ParamKM = LayRefKhoanMucDongTien(KhoanMucDongTien);
			
			Query.SetParameter("Thang", ThangChuan);
			Query.SetParameter("PhapNhan", ParamPN);
			Query.SetParameter("DuAn", ParamDA);
			Query.SetParameter("KhoanMucDongTien", ParamKM);
			
			Result = Query.Execute().Unload();
			If Result.Count() > 0 Then
				NganSach = Number(Result[0].SoTienNganSach);
				DaDuyet = Number(Result[0].SoTienDaDuyet);
				ThucChi = Number(Result[0].SoTienThucChi);
				TimThay = True;
			EndIf;
		EndIf;
	Except
		LookupError = DetailErrorDescription(ErrorInfo());
		WriteLogEvent("Approval.BudgetLookup", EventLogLevel.Error,,, LookupError);
		Raise "Không thể đọc ngân sách để xác định quyền duyệt CFO: " + LookupError;
	EndTry;
	
	// 2. Tra cuu tu bo nho mo phong neu chua tim thay trong database
	Mem = LayBoNhoMoPhong();
	If Not TimThay And Mem.BangNganSachMoPhong.Count() > 0 Then
		Key = TaoKhoaNganSach(PhapNhan, DuAn, KhoanMucDongTien, ThangChuan);
		BudgetInfo = Mem.BangNganSachMoPhong.Get(Key);
		If BudgetInfo <> Undefined Then
			NganSach = Number(BudgetInfo.SoTienNganSach);
			DaDuyet = Number(BudgetInfo.SoTienDaDuyet);
			ThucChi = Number(BudgetInfo.SoTienThucChi);
			TimThay = True;
		EndIf;
	EndIf;
	
	// Neu ngan sach bang 0 hoac am (chua co ngan sach phe duyet)
	If NganSach <= 0 Then
		// Neu co chi tieu ma khong co ngan sach duoc duyet -> Bat buoc CFO duyet
		Return (SoTienChiChuan > 0);
	EndIf;
	
	// Tinh so tien da dung trong thang
	DaSuDung = DaDuyet;
	If ThucChi > DaSuDung Then
		DaSuDung = ThucChi;
	EndIf;
	
	TongChiSauHoaDon = DaSuDung + SoTienChiChuan;
	
	// Nguong 110% ngan sach (vuot > 10% ngan sach)
	NguongChoPhep10PhanTram = NganSach * 1.10;
	
	If TongChiSauHoaDon > NguongChoPhep10PhanTram Then
		Return True;
	Else
		Return False;
	EndIf;
EndFunction

// Lay danh sach tat ca cac cap/role phe duyet can thiet cho hoa don
//
// Tham so:
//   Cac tham so tuong tu XacDinhCapPheDuyetHoaDon kem DuAn va KhoanMucDongTien
//
// Gia tri tra ve:
//   Array - Danh sach ten cap / Role can ky duyet (vi du: ["KeToanTruong", "GiamDocTaiChinh_CFO"])
//
Function LayDanhSachCapPheDuyetHoaDon(Val PhapNhan, Val DoiTac, Val SoTien, Val ThoiDiem, 
	Val DuAn = Undefined, Val KhoanMucDongTien = Undefined) Export
	
	DanhSachCap = New Array;
	
	// 1. Cap phe duyet gia tri hoa don (sau Anti-Split)
	CapChinh = XacDinhCapPheDuyetHoaDon(PhapNhan, DoiTac, SoTien, ThoiDiem);
	DanhSachCap.Add(CapChinh);
	
	// 2. Kiem tra nhanh dac biet CFO neu co thong tin ngan sach
	If DuAn <> Undefined And KhoanMucDongTien <> Undefined Then
		YeuCauCFO = KiemTraYeuCauDuyetCFO(PhapNhan, DuAn, KhoanMucDongTien, ThoiDiem, SoTien);
		// [FIX B36] Vuot ngan sach luon can chu ky CFO, ke ca khi cap chinh la Tong giam doc
		If YeuCauCFO And CapChinh <> "GiamDocTaiChinh_CFO" Then
			DanhSachCap.Add("GiamDocTaiChinh_CFO");
		EndIf;
	EndIf;
	
	Return DanhSachCap;
EndFunction

// Lay cau truc thong tin chi tiet ve quy trinh phe duyet
Function LayThongTinChiTietPheDuyet(Val PhapNhan, Val DoiTac, Val SoTien, Val ThoiDiem,
	Val DuAn = Undefined, Val KhoanMucDongTien = Undefined) Export
	
	SoTienChuan = Number(SoTien);
	ThoiDiemChuan = ?(ValueIsFilled(ThoiDiem), ThoiDiem, CurrentSessionDate());
	
	TongLuyKeTruoc = TinhTongLuyKeTrongThang(PhapNhan, DoiTac, ThoiDiemChuan);
	TongLuyKeSauHoaDon = TongLuyKeTruoc + SoTienChuan;
	
	CapCoBan = XacDinhCapPheDuyetTheoSoTien(SoTienChuan);
	CapCuoiCung = XacDinhCapPheDuyetHoaDon(PhapNhan, DoiTac, SoTienChuan, ThoiDiemChuan);
	DaLeoThang = (LayThuTuCap(CapCuoiCung) > LayThuTuCap(CapCoBan));
	
	YeuCauCFO = False;
	If DuAn <> Undefined And KhoanMucDongTien <> Undefined Then
		YeuCauCFO = KiemTraYeuCauDuyetCFO(PhapNhan, DuAn, KhoanMucDongTien, ThoiDiemChuan, SoTienChuan);
	EndIf;
	
	Result = New Structure;
	Result.Insert("CapCoBan", CapCoBan);
	Result.Insert("CapCuoiCung", CapCuoiCung);
	Result.Insert("DaLeoThang", DaLeoThang);
	Result.Insert("TongLuyKeTruoc", TongLuyKeTruoc);
	Result.Insert("TongLuyKeSauHoaDon", TongLuyKeSauHoaDon);
	Result.Insert("YeuCauDuyetCFO", YeuCauCFO);
	
	If DaLeoThang Then
		Result.Insert("GiaiTrinhLeoThang", 
			StrTemplate("Anti-Split: Lũy kế trong tháng đạt %1 VND (vượt ngưỡng), cấp phê duyệt tự động leo thang từ %2 lên %3.",
				TongLuyKeSauHoaDon, CapCoBan, CapCuoiCung));
	Else
		Result.Insert("GiaiTrinhLeoThang", "");
	EndIf;
	
	Return Result;
EndFunction

#EndRegion

#Region SimulationAndTesting

// Dang ky hoa don vao bo nho mo phong cho unit test va anti-split
Procedure DangKyHoaDon(Val PhapNhan, Val DoiTac, Val SoTien, Val ThoiDiem, Val SoHoaDon = "") Export
	KhoiTaoBoNhoMoPhong();
	
	Record = New Structure;
	Record.Insert("PhapNhan", PhapNhan);
	Record.Insert("DoiTac", DoiTac);
	Record.Insert("SoTien", Number(SoTien));
	Record.Insert("ThoiDiem", ?(ValueIsFilled(ThoiDiem), ThoiDiem, CurrentSessionDate())); // [FIX B36] thieu ThoiDiem lam loi doc
	Record.Insert("SoHoaDon", SoHoaDon);
	Mem = LayBoNhoMoPhong();
	Mem.BangHoaDonMoPhong.Add(Record);
EndProcedure

// Xoa toan bo du lieu hoa don va ngan sach mo phong
Procedure XoaDuLieuLuyKeMoPhong() Export
	Mem = LayBoNhoMoPhong();
	Mem.BangHoaDonMoPhong.Clear();
	Mem.BangNganSachMoPhong.Clear();
EndProcedure

// Thiet lap du lieu ngan sach mo phong cho unit test
Procedure DatNganSachMoPhong(Val PhapNhan, Val DuAn, Val KhoanMucDongTien, Val Thang, 
	Val NganSach, Val DaDuyet = 0, Val ThucChi = 0) Export
	
	Mem = LayBoNhoMoPhong();
	
	Key = TaoKhoaNganSach(PhapNhan, DuAn, KhoanMucDongTien, BegOfMonth(Thang));
	BudgetInfo = New Structure;
	BudgetInfo.Insert("SoTienNganSach", Number(NganSach));
	BudgetInfo.Insert("SoTienDaDuyet", Number(DaDuyet));
	BudgetInfo.Insert("SoTienThucChi", Number(ThucChi));
	
	Mem.BangNganSachMoPhong.Insert(Key, BudgetInfo);
EndProcedure

#EndRegion

#Region PrivateHelpers

Procedure KhoiTaoBoNhoMoPhong()
	LayBoNhoMoPhong();
EndProcedure

Function TinhTongHoaDonMoPhong(Val PhapNhan, Val DoiTac, Val DauThang, Val CuoiThang)
	Mem = LayBoNhoMoPhong();
	
	Tong = 0;
	For Each Record In Mem.BangHoaDonMoPhong Do
		If LaCungDoiTuong(Record.PhapNhan, PhapNhan)
			And LaCungDoiTuong(Record.DoiTac, DoiTac)
			And Record.ThoiDiem >= DauThang 
			And Record.ThoiDiem <= CuoiThang Then
			
			Tong = Tong + Record.SoTien;
		EndIf;
	EndDo;
	
	Return Tong;
EndFunction

Function TaoKhoaNganSach(Val PhapNhan, Val DuAn, Val KhoanMucDongTien, Val Thang)
	StrPN = LayMaDinhDanh(PhapNhan);
	StrDA = LayMaDinhDanh(DuAn);
	StrKM = LayMaDinhDanh(KhoanMucDongTien);
	StrThang = Format(BegOfMonth(Thang), "DF=yyyyMMdd");
	Return StrTemplate("%1_%2_%3_%4", StrPN, StrDA, StrKM, StrThang);
EndFunction

Function LayThuTuCap(Val Cap)
	CapStr = TrimAll(String(Cap));
	If CapStr = "TruongBoPhan" Then
		Return 1;
	ElsIf CapStr = "KeToanTruong" Then
		Return 2;
	ElsIf CapStr = "GiamDocKhoi" Then
		Return 3;
	ElsIf CapStr = "TongGiamDoc" Then
		Return 4;
	ElsIf CapStr = "GiamDocTaiChinh_CFO" Then
		Return 5;
	Else
		Return 0;
	EndIf;
EndFunction

Function LayMaDinhDanh(Val Obj)
	If Obj = Undefined Or Obj = Null Then
		Return "";
	EndIf;
	
	If TypeOf(Obj) = Type("String") Then
		Return TrimAll(Obj);
	ElsIf TypeOf(Obj) = Type("Structure") Then
		If Obj.Property("Code") Then
			Return TrimAll(Obj.Code);
		ElsIf Obj.Property("Ma") Then
			Return TrimAll(Obj.Ma);
		EndIf;
		Return String(Obj);
	Else
		If TypeOf(Obj) <> Type("CatalogRef.PhapNhan")
			And TypeOf(Obj) <> Type("CatalogRef.DoiTac")
			And TypeOf(Obj) <> Type("CatalogRef.DuAn")
			And TypeOf(Obj) <> Type("CatalogRef.KhoanMucDongTien") Then
			Raise "Không hỗ trợ loại dữ liệu khi tạo khóa ngân sách: " + String(TypeOf(Obj));
		EndIf;
		If Not ValueIsFilled(Obj.Code) Then
			Raise "Không thể tạo khóa ngân sách từ tham chiếu danh mục chưa được điền.";
		EndIf;
		Return TrimAll(Obj.Code);
	EndIf;
EndFunction

Function LaCungDoiTuong(Val Obj1, Val Obj2)
	If Obj1 = Obj2 Then
		Return True;
	EndIf;
	
	Str1 = LayMaDinhDanh(Obj1);
	Str2 = LayMaDinhDanh(Obj2);
	
	If Str1 <> "" And Str1 = Str2 Then
		Return True;
	EndIf;
	
	Return False;
EndFunction

Function LayRefPhapNhan(Val PhapNhan)
	If TypeOf(PhapNhan) = Type("CatalogRef.PhapNhan") And ValueIsFilled(PhapNhan) Then
		Return PhapNhan;
	EndIf;
	Code = LayMaDinhDanh(PhapNhan);
	If Code = "" Then Raise "Thiếu mã pháp nhân khi tra cứu ngân sách."; EndIf;
	Ref = Catalogs.PhapNhan.FindByCode(Code);
	If Not ValueIsFilled(Ref) Then Raise "Không tìm thấy pháp nhân theo mã " + Code + "."; EndIf;
	Return Ref;
EndFunction

Function LayRefDoiTac(Val DoiTac)
	If TypeOf(DoiTac) = Type("CatalogRef.DoiTac") And ValueIsFilled(DoiTac) Then
		Return DoiTac;
	EndIf;
	Code = LayMaDinhDanh(DoiTac);
	If Code = "" Then Raise "Thiếu mã đối tác khi tra cứu ngân sách."; EndIf;
	Ref = Catalogs.DoiTac.FindByCode(Code);
	If Not ValueIsFilled(Ref) Then Raise "Không tìm thấy đối tác theo mã " + Code + "."; EndIf;
	Return Ref;
EndFunction

Function LayRefDuAn(Val DuAn)
	If TypeOf(DuAn) = Type("CatalogRef.DuAn") And ValueIsFilled(DuAn) Then
		Return DuAn;
	EndIf;
	Code = LayMaDinhDanh(DuAn);
	If Code = "" Then Raise "Thiếu mã dự án khi tra cứu ngân sách."; EndIf;
	Ref = Catalogs.DuAn.FindByCode(Code);
	If Not ValueIsFilled(Ref) Then Raise "Không tìm thấy dự án theo mã " + Code + "."; EndIf;
	Return Ref;
EndFunction

Function LayRefKhoanMucDongTien(Val KhoanMucDongTien)
	If TypeOf(KhoanMucDongTien) = Type("CatalogRef.KhoanMucDongTien") And ValueIsFilled(KhoanMucDongTien) Then
		Return KhoanMucDongTien;
	EndIf;
	Code = LayMaDinhDanh(KhoanMucDongTien);
	If Code = "" Then Raise "Thiếu mã khoản mục dòng tiền khi tra cứu ngân sách."; EndIf;
	Ref = Catalogs.KhoanMucDongTien.FindByCode(Code);
	If Not ValueIsFilled(Ref) Then Raise "Không tìm thấy khoản mục dòng tiền theo mã " + Code + "."; EndIf;
	Return Ref;
EndFunction

#EndRegion
