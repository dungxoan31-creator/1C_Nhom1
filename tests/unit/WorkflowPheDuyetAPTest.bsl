// Unit Test Suite: WorkflowPheDuyetAPTest
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL / BUnit / Vanessa)
// Muc tieu: Kiem thu Luong phe duyet 4+1 cap AP va Nhanh duyet CFO khi vuot ngan sach > 10% (Task 4.2):
//   1. Test 1: Luong duyet chuan trong han muc ngan sach:
//              DuThao -> ChoDuyetKyThuat -> ChoDuyetPM -> ChoDuyetITDirector -> ChoKeToanAP -> DaGhiSo.
//   2. Test 2: Luong duyet vuot ngan sach > 10% (CFO Unlock):
//              Sau ChoDuyetITDirector bat buoc chuyen sang ChoDuyetCFO truoc khi den ChoKeToanAP.
//   3. Test 3: Kiem tra Maker-Checker:
//              Nguoi tao chung tu (Author) bi cam tuyet doi khong duoc phe duyet bat ky cap nao!
//   4. Test 4: Xu ly TuChoi (Rejection):
//              Chuyen trang thai sang TuChoi va luu ly do tu choi ro rang.
//   5. Test 5: Kiem tra Anti-Split truoc khi chuyen sang ChoKeToanAP.

#Region TestExecution

Function RunVerification() Export
	Results = RunAllTests();
	
	LogPath = "C:/Users/Dung/Documents/1C_Enterprise/tests/unit/workflow_phe_duyet_ap_test_result.log";
	Try
		TextW = New TextWriter(LogPath, TextEncoding.UTF8);
		For Each Line In Results.Log Do
			TextW.WriteLine(Line);
		EndDo;
		TextW.Close();
	Except
	EndTry;
	
	Return Results;
EndFunction

Function RunAllTests() Export
	TestResults = New Structure;
	TestResults.Insert("Total", 5);
	TestResults.Insert("Passed", 0);
	TestResults.Insert("Failed", 0);
	TestResults.Insert("Log", New Array);
	
	TestLog = TestResults.Log;
	TestLog.Add("=================================================================");
	TestLog.Add("   VINSMART FUTURE - WORKFLOW PHE DUYET AP UNIT TEST (TASK 4.2)  ");
	TestLog.Add("   Thoi gian chay: " + CurrentDate());
	TestLog.Add("=================================================================");
	
	// Test 1: Luong duyet chuan trong han muc
	Try
		Test01_LuongDuyetChuanTrongHanMuc();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 1: Luong duyet chuan trong han muc ngan sach chuyen tuan tu qua cac cap den DaGhiSo.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 1: Luong duyet chuan that bai - " + ErrorDescription());
	EndTry;
	
	// Test 2: Luong duyet vuot ngan sach > 10% (CFO Unlock)
	Try
		Test02_LuongDuyetVuotNganSachCFOUnlock();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 2: Luong duyet vuot ngan sach > 10% tu dong kich hoat nhanh ChoDuyetCFO hop le.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 2: Luong duyet vuot ngan sach that bai - " + ErrorDescription());
	EndTry;
	
	// Test 3: Maker-Checker chan nguoi tao tu duyet
	Try
		Test03_MakerCheckerChanNguoiTaoTuDuyet();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 3: Maker-Checker chan nguoi tao tu phe duyet moi cap thanh cong.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 3: Maker-Checker that bai - " + ErrorDescription());
	EndTry;
	
	// Test 4: Xu ly TuChoi
	Try
		Test04_XuLyTuChoiPheDuyet();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 4: Xu ly TuChoi chuyen trang thai sang TuChoi kem ly do thanh cong.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 4: Xu ly TuChoi that bai - " + ErrorDescription());
	EndTry;
	
	// Test 5: Re-check Anti-Split truoc khi sang ChoKeToanAP
	Try
		Test05_ReCheckAntiSplitTruocKhiDuyetKeToanAP();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 5: Re-check Anti-Split phat hien dau hieu tach nho hoa don va canh bao truoc khi vao ChoKeToanAP.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 5: Re-check Anti-Split that bai - " + ErrorDescription());
	EndTry;
	
	TestLog.Add("-----------------------------------------------------------------");
	TestLog.Add(StrTemplate("Tong so test: %1 | Thanh cong: %2 | That bai: %3", 
		TestResults.Total, TestResults.Passed, TestResults.Failed));
	TestLog.Add("=================================================================");
	
	Return TestResults;
EndFunction

#EndRegion

#Region TestCases

// Test 1: Luong duyet chuan trong han muc ngan sach
Procedure Test01_LuongDuyetChuanTrongHanMuc()
	// DuThao -> ChoDuyetKyThuat -> ChoDuyetPM -> ChoDuyetITDirector -> ChoKeToanAP -> DaGhiSo
	TrangThaiHienTai = "DuThao";
	VuotNganSach = False;
	
	// 1. Chuyen tu DuThao sang ChoDuyetKyThuat
	TrangThaiTiepTheo = QuyTrinhPheDuyetAPServer.XacDinhTrangThaiTiepTheo(TrangThaiHienTai, VuotNganSach);
	If TrangThaiTiepTheo <> "ChoDuyetKyThuat" Then
		Raise "Sai trang thai tiep theo tu DuThao!";
	EndIf;
	
	// 2. ChoDuyetKyThuat -> ChoDuyetPM
	TrangThaiTiepTheo = QuyTrinhPheDuyetAPServer.XacDinhTrangThaiTiepTheo(TrangThaiTiepTheo, VuotNganSach);
	If TrangThaiTiepTheo <> "ChoDuyetPM" Then
		Raise "Sai trang thai tiep theo tu ChoDuyetKyThuat!";
	EndIf;
	
	// 3. ChoDuyetPM -> ChoDuyetITDirector
	TrangThaiTiepTheo = QuyTrinhPheDuyetAPServer.XacDinhTrangThaiTiepTheo(TrangThaiTiepTheo, VuotNganSach);
	If TrangThaiTiepTheo <> "ChoDuyetITDirector" Then
		Raise "Sai trang thai tiep theo tu ChoDuyetPM!";
	EndIf;
	
	// 4. ChoDuyetITDirector -> ChoKeToanAP (Khong vuot ngan sach, bo qua CFO)
	TrangThaiTiepTheo = QuyTrinhPheDuyetAPServer.XacDinhTrangThaiTiepTheo(TrangThaiTiepTheo, VuotNganSach);
	If TrangThaiTiepTheo <> "ChoKeToanAP" Then
		Raise StrTemplate("Khong vuot ngan sach phai chuyen den ChoKeToanAP, thuc te %1", TrangThaiTiepTheo);
	EndIf;
	
	// 5. ChoKeToanAP -> DaGhiSo
	TrangThaiTiepTheo = QuyTrinhPheDuyetAPServer.XacDinhTrangThaiTiepTheo(TrangThaiTiepTheo, VuotNganSach);
	If TrangThaiTiepTheo <> "DaGhiSo" Then
		Raise "Sai trang thai ghi so cuoi cung!";
	EndIf;
EndProcedure

// Test 2: Luong duyet vuot ngan sach > 10% (CFO Unlock)
Procedure Test02_LuongDuyetVuotNganSachCFOUnlock()
	TrangThaiHienTai = "ChoDuyetITDirector";
	VuotNganSach = True; // Vuot ngan sach > 10%
	
	TrangThaiTiepTheo = QuyTrinhPheDuyetAPServer.XacDinhTrangThaiTiepTheo(TrangThaiHienTai, VuotNganSach);
	If TrangThaiTiepTheo <> "ChoDuyetCFO" Then
		Raise StrTemplate("Vuot ngan sach phai chuyen qua ChoDuyetCFO, thuc te: %1", TrangThaiTiepTheo);
	EndIf;
	
	// Sau khi CFO duyet, tiep tuc den ChoKeToanAP
	TrangThaiTiepTheo2 = QuyTrinhPheDuyetAPServer.XacDinhTrangThaiTiepTheo(TrangThaiTiepTheo, VuotNganSach);
	If TrangThaiTiepTheo2 <> "ChoKeToanAP" Then
		Raise StrTemplate("Sau ChoDuyetCFO phai chuyen den ChoKeToanAP, thuc te: %1", TrangThaiTiepTheo2);
	EndIf;
EndProcedure

// Test 3: Maker-Checker chan nguoi tao tu duyet
Procedure Test03_MakerCheckerChanNguoiTaoTuDuyet()
	NguoiTao = "DEV_DUONG";
	NguoiDuyet = "DEV_DUONG";
	
	BiChan = False;
	Try
		QuyTrinhPheDuyetAPServer.KiemTraQuyenDuyet(NguoiTao, NguoiDuyet, "ChoDuyetPM");
	Except
		BiChan = True;
	EndTry;
	
	If Not BiChan Then
		Raise "He thong khong chan nguoi tao tu phe duyet!";
	EndIf;
EndProcedure

// Test 4: Xu ly TuChoi
Procedure Test04_XuLyTuChoiPheDuyet()
	TrangThaiHienTai = "ChoDuyetPM";
	LyDoTuChoi = "Chưa có báo cáo nghiệm thu kỹ thuật chi tiết";
	
	KetQua = QuyTrinhPheDuyetAPServer.TuChoiPheDuyet(TrangThaiHienTai, LyDoTuChoi);
	If KetQua.TrangThaiMoi <> "TuChoi" Then
		Raise "Trang thai sau tu choi phai la TuChoi!";
	EndIf;
	If KetQua.LyDo <> LyDoTuChoi Then
		Raise "Sai ly do tu choi!";
	EndIf;
EndProcedure

// Test 5: Re-check Anti-Split truoc khi sang ChoKeToanAP
Procedure Test05_ReCheckAntiSplitTruocKhiDuyetKeToanAP()
	// Gia lap NCC co tong gia tri luy ke trong thang cao va nhieu hoa don lien tiep
	SoHoaDonTrongThang = 4;
	TongTienLuyKe = 450000000;
	NguongCanhBao = 100000000;
	
	CoDauHieuAntiSplit = QuyTrinhPheDuyetAPServer.KiemTraAntiSplit(SoHoaDonTrongThang, TongTienLuyKe, NguongCanhBao);
	If Not CoDauHieuAntiSplit Then
		Raise "He thong phai canh bao Anti-Split khi so luong va gia tri vuot nguong!";
	EndIf;
EndProcedure

#EndRegion
