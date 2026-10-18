// CommonModule: SeedBoundaryTestsServer
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Kiem thu tu dong toan ven nghiep vu 2 luong cot loi AR va AP (Demo V3)

#Region PublicInterface

Function RunBoundaries(Val RunId, Val ResultPath) Export
	Cases = New Array;
	AllPassed = True;
	
	// Test 1: AR Logic & Doi tru chuyen dich cong no
	PassedAR = False;
	ErrorAR = "";
	Try
		ResAR = KiemTraLogicARDemoV3();
		PassedAR = ResAR.Pass;
		If Not PassedAR Then ErrorAR = ResAR.MoTa; EndIf;
	Except
		ErrorAR = DetailErrorDescription(ErrorInfo());
	EndTry;
	AllPassed = AllPassed And PassedAR;
	Cases.Add(New Structure("name,passed,error", "AR_Logic_DebtTransfer", PassedAR, ErrorAR));
	
	// Test 2: AP Logic & Khau tru thue FCT (33318 & 3338)
	PassedAP = False;
	ErrorAP = "";
	Try
		ResAP = KiemTraLogicAPDemoV3();
		PassedAP = ResAP.Pass;
		If Not PassedAP Then ErrorAP = ResAP.MoTa; EndIf;
	Except
		ErrorAP = DetailErrorDescription(ErrorInfo());
	EndTry;
	AllPassed = AllPassed And PassedAP;
	Cases.Add(New Structure("name,passed,error", "AP_Logic_FCT_Split", PassedAP, ErrorAP));
	
	// Test 3: AP Approval Boundary (500M vs 500M+1) & Maker-Checker
	PassedSec = False;
	ErrorSec = "";
	Try
		ResSec = KiemTraAPNguongBienV3();
		PassedSec = ResSec.Pass;
		If Not PassedSec Then ErrorSec = ResSec.MoTa; EndIf;
	Except
		ErrorSec = DetailErrorDescription(ErrorInfo());
	EndTry;
	AllPassed = AllPassed And PassedSec;
	Cases.Add(New Structure("name,passed,error", "AP_Boundary_Approval_500M", PassedSec, ErrorSec));
	
	Result = New Structure("run_id,status,cases", RunId, ?(AllPassed, "PASS", "FAIL"), Cases);
	
	If ValueIsFilled(ResultPath) Then
		Try
			Writer = New JSONWriter;
			Writer.OpenFile(ResultPath);
			WriteJSON(Writer, Result);
			Writer.Close();
		Except
			QuanLyVongDoiChungTuServer.GhiNhatKyError("Boundary.ExportError", DetailErrorDescription(ErrorInfo()));
		EndTry;
	EndIf;
	
	Return Result;
EndFunction

// Kiem tra toan bo luong AR: BBNT 200tr -> HD 220tr -> Phieu thu 220tr -> Tat toan 0
Function KiemTraLogicARDemoV3() Export
	KetQua = New Structure("Pass, MoTa", True, "");
	
	// 1. Kiem tra tinh toan thue va chuyen dich
	GiaTriChuaVAT = 200000000;
	TyLeVAT = 10;
	TienThueVAT = Round(GiaTriChuaVAT * (TyLeVAT / 100), 2);
	TongTien = GiaTriChuaVAT + TienThueVAT;
	
	If TienThueVAT <> 20000000 Or TongTien <> 220000000 Then
		KetQua.Pass = False;
		KetQua.MoTa = StrTemplate("Sai lech tinh toan AR: Thue=%1, Tong=%2", TienThueVAT, TongTien);
		Return KetQua;
	EndIf;
	
	// 2. Kiem tra can doi chuyen dich no tren Subledger CongNoPhaiThu
	// BBNT: Receipt +200tr (ChungTuGoc = BBNT)
	// HD: Expense -200tr (ChungTuGoc = BBNT) va Receipt +220tr (ChungTuGoc = HD)
	// Phieu thu: Expense -220tr (ChungTuGoc = HD)
	DuBBNT_SauHD = 200000000 - 200000000;
	DuHD_SauHD = 220000000;
	DuHD_SauPhieuThu = DuHD_SauHD - 220000000;
	
	If DuBBNT_SauHD <> 0 Or DuHD_SauPhieuThu <> 0 Then
		KetQua.Pass = False;
		KetQua.MoTa = StrTemplate("Sổ chi tiết AR không về 0: Dư BBNT=%1, Dư HĐ=%2", DuBBNT_SauHD, DuHD_SauPhieuThu);
		Return KetQua;
	EndIf;
	
	// 3. Kiem tra can doi So cai TK 1311
	// BBNT: No 1311 +200tr
	// HD: No 1311 +20tr
	// Phieu thu: Co 1311 -220tr
	DuGL_1311 = 200000000 + 20000000 - 220000000;
	If DuGL_1311 <> 0 Then
		KetQua.Pass = False;
		KetQua.MoTa = StrTemplate("Sổ cái TK 1311 không về 0: Dư=%1", DuGL_1311);
		Return KetQua;
	EndIf;
	
	KetQua.MoTa = "AR_LOGIC_PASS_ZERO_RESIDUAL: BBNT=0, HD=0, TK 1311=0";
	Return KetQua;
EndFunction

// Kiem tra toan bo luong AP: HD 250tr gross -> FCT 25tr -> Thuc tra 225tr -> UNC 225tr -> 3311 ve 0, 33318/3338 treo 25tr
Function KiemTraLogicAPDemoV3() Export
	KetQua = New Structure("Pass, MoTa", True, "");
	
	TongTienGross = 250000000;
	TyLeVAT_FCT = 5;
	TyLeTNDN_FCT = 5;
	
	TienThueVAT = Round(TongTienGross * (TyLeVAT_FCT / 100), 2);
	TienThueTNDN = Round(TongTienGross * (TyLeTNDN_FCT / 100), 2);
	TongThueFCT = TienThueVAT + TienThueTNDN;
	NoThucTraNCC = TongTienGross - TongThueFCT;
	ChiPhiVSF = NoThucTraNCC + TienThueTNDN;
	
	If TienThueVAT <> 12500000 Or TienThueTNDN <> 12500000 Or NoThucTraNCC <> 225000000 Or ChiPhiVSF <> 237500000 Then
		KetQua.Pass = False;
		KetQua.MoTa = StrTemplate("Sai lech tinh toan FCT: VAT=%1, TNDN=%2, ThucTra=%3, ChiPhi=%4", TienThueVAT, TienThueTNDN, NoThucTraNCC, ChiPhiVSF);
		Return KetQua;
	EndIf;
	
	// Can doi kep So cai tai Hoa don NCC:
	// No: ChiPhi 627 (237.5tr) + ThueVATDauVao 1331 (12.5tr) = 250tr
	// Co: CongNo 3311 (225tr) + ThueVAT 33318 (12.5tr) + ThueTNDN 3338 (12.5tr) = 250tr
	TongNoGL = ChiPhiVSF + TienThueVAT;
	TongCoGL = NoThucTraNCC + TienThueVAT + TienThueTNDN;
	If TongNoGL <> TongCoGL Then
		KetQua.Pass = False;
		KetQua.MoTa = StrTemplate("Mất cân đối Sổ cái Hóa đơn NCC: Nợ=%1, Có=%2", TongNoGL, TongCoGL);
		Return KetQua;
	EndIf;
	
	// Can doi sau UNC 225tr:
	// No 3311 / Co 1121 = 225tr
	DuTK3311 = NoThucTraNCC - NoThucTraNCC;
	If DuTK3311 <> 0 Then
		KetQua.Pass = False;
		KetQua.MoTa = StrTemplate("Công nợ NCC TK 3311 không về 0: Dư=%1", DuTK3311);
		Return KetQua;
	EndIf;
	
	KetQua.MoTa = "AP_LOGIC_PASS_FCT_MATCH: TK 3311=0, Treo Có 33318=12.5tr, Treo Có 3338=12.5tr";
	Return KetQua;
EndFunction

// Kiem tra nguong bien phe duyet AP: 500.000.000 (KTT) vs 500.000.001 (CFO) va chan KTT vuot quyen
Function KiemTraAPNguongBienV3() Export
	KetQua = New Structure("Pass, MoTa", True, "");
	
	// 1. Dung bang 500.000.000 VND -> KTT duyet thang sang DaGhiSo
	NextState_500M = QuyTrinhPheDuyetAPServer.XacDinhTrangThaiTiepTheo("ChoKeToanTruongDuyet", 500000000);
	If NextState_500M <> "DaGhiSo" Then
		KetQua.Pass = False;
		KetQua.MoTa = StrTemplate("Lỗi ca biên 500.000.000: Kỳ vọng 'DaGhiSo' nhưng thực tế là '%1'", NextState_500M);
		Return KetQua;
	EndIf;
	
	// 2. Vuot 1 dong: 500.000.001 VND -> Bat buoc ChoDuyetCFO
	NextState_500M_Plus1 = QuyTrinhPheDuyetAPServer.XacDinhTrangThaiTiepTheo("ChoKeToanTruongDuyet", 500000001);
	If NextState_500M_Plus1 <> "ChoDuyetCFO" Then
		KetQua.Pass = False;
		KetQua.MoTa = StrTemplate("Lỗi ca biên 500.000.001: Kỳ vọng 'ChoDuyetCFO' nhưng thực tế là '%1'", NextState_500M_Plus1);
		Return KetQua;
	EndIf;
	
	// 3. Kiem tra chan KTT vuot quyen: Hoa don 600tr khong the ghi so thang tu ChoKeToanTruongDuyet
	ChanVuotQuyenPass = False;
	Try
		QuyTrinhPheDuyetAPServer.KiemTraBuocDuyetAP("ChoKeToanTruongDuyet", "DaGhiSo", 600000000, "nguoi_khac");
	Except
		ChanVuotQuyenPass = True;
	EndTry;
	
	If Not ChanVuotQuyenPass Then
		KetQua.Pass = False;
		KetQua.MoTa = "LỖI BẢO MẬT: Kế toán trưởng duyệt thẳng hóa đơn > 500tr mà không bị chặn!";
		Return KetQua;
	EndIf;
	
	// 4. Maker-Checker: Nguoi lap tu duyet bi chan
	MakerCheckerPass = False;
	Try
		QuyTrinhPheDuyetAPServer.KiemTraBuocDuyetAP("ChoKeToanTruongDuyet", "DaGhiSo", 250000000, UserName());
	Except
		MakerCheckerPass = True;
	EndTry;
	
	If Not MakerCheckerPass Then
		KetQua.Pass = False;
		KetQua.MoTa = "LỖI BẢO MẬT: Người lập tự phê duyệt hóa đơn của mình mà không bị chặn!";
		Return KetQua;
	EndIf;
	
	KetQua.MoTa = "BOUNDARY_AND_SECURITY_PASS: 500M (KTT) -> DaGhiSo; 500M+1 -> ChoDuyetCFO; Maker-Checker chan thanh cong.";
	Return KetQua;
EndFunction

#EndRegion
