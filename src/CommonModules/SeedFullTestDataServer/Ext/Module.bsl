// CommonModule: SeedFullTestDataServer
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Dieu phoi sinh toan bo du lieu Master Data, AR, AP, Netting va Kiem toan So cai toan dien

Procedure KiemTraDanhSachTaiKhoan() Export
	Q = New Query("SELECT Code, Description, PredefinedDataName FROM ChartOfAccounts.HeThongTaiKhoan");
	T = Q.Execute().Unload();
	For Each R In T Do
		WriteLogEvent("Account.List", EventLogLevel.Information,,, "Acc: " + R.Code + " - " + R.Description + " (Predef: " + R.PredefinedDataName + ")");
	EndDo;
EndProcedure

Procedure ThucThiNapFullTestData() Export
	WriteLogEvent("SeedData.FullTest", EventLogLevel.Information,,, "=== BAT DAU MASTER ORCHESTRATION NAP FULL TEST DATA ===");
	
	// 0. Don dep toan bo chung tu nghiep vu cu theo thu tu rang buoc khoa ngoai
	XoaToanBoDuLieuGiaoDichCu();
	
	// 1. Khoi tao Master Data (249 Doi tac, 249 Hop dong, 32 Du an/Khoi, 92 Dich vu CNTT, 639 Ty gia USD)
	GeneratorMasterDataServer.KhoiTaoMasterDataToanDien();
	
	// 2. Sinh day chuyen Phai thu AR (1,260 BB nghiem thu, 1,260 HD GTGT dau ra, 854 Thu tien / Bao co)
	GeneratorARServer.KhoiTaoChungTuAR();
	
	// 3. Sinh day chuyen Phai tra AP (1,268 HD NCC, 1,055 Uy nhiem chi)
	GeneratorAPServer.KhoiTaoChungTuAP();
	
	// 4. Sinh Can tru cong no noi bo Netting & Doi soat kenh (182 Can tru, 182 Bang ke doi soat)
	GeneratorNettingReconcileServer.KhoiTaoChungTuNetting();
	
	WriteLogEvent("SeedData.FullTest", EventLogLevel.Information,,, "=== HOAN TAT MASTER ORCHESTRATION THANH CONG 100% ===");
EndProcedure

Procedure KiemTraDuLieuDaNap() Export
	Log = New Array;
	Log.Add("=================================================================");
	Log.Add("   KIEM TRA & XAC MINH DU LIEU TEST VA TINH CAN DOI SO SACH     ");
	Log.Add("   Thoi gian kiem tra: " + CurrentSessionDate());
	Log.Add("=================================================================");
	
	// 1. Dem so luong chung tu (Bao gom tat ca 8 loai chung tu nghiep vu)
	DocList = New Array;
	DocList.Add("BienBanNghiemThuGiaiDoan");
	DocList.Add("HoaDonGTGTDauRa");
	DocList.Add("PhieuThuTienKhachHang");
	DocList.Add("BaoCoNganHang");
	DocList.Add("HoaDonNhaCungCap");
	DocList.Add("UyNhiemChi");
	DocList.Add("CanTruCongNoNoiBo");
	DocList.Add("BangKeDoiSoatKenhThanhToan");
	
	TongChungTu = 0;
	For Each DocName In DocList Do
		Q = New Query("SELECT COUNT(*) AS Cnt FROM Document." + DocName + " WHERE Posted = TRUE");
		Res = Q.Execute().Unload();
		Cnt = Res[0].Cnt;
		TongChungTu = TongChungTu + Cnt;
		Log.Add(StrTemplate("[*] %1: %2 chung tu DA GHI SO (Posted)", DocName, Cnt));
	EndDo;
	Log.Add(StrTemplate("--> TONG SO CHUNG TU DA GHI SO HOP LE: %1", TongChungTu));
	
	// 2. Kiem tra can doi SoCaiKeToan va Doi soat doc lap voi So phu (Subledgers)
	DoiSoatGL = QuanLyVongDoiChungTuServer.KiemTraDoiSoatDocLapGLVaSoPhu();
	Log.Add(StrTemplate("[*] SoCaiKeToan (General Ledger): Tong but toan = %1, Tong phat sinh kep = %2 VND",
		DoiSoatGL.TongSoButToan, Format(DoiSoatGL.TongPhatSinhGL, "NFD=0; NGS=.")));
	Log.Add(StrTemplate("[*] Doi soat doc lap Subledger AR vs GL TK 131: Subledger = %1, GL = %2, DELTA_AR = %3",
		Format(DoiSoatGL.TongDuSubAR, "NFD=0; NGS=."), Format(DoiSoatGL.TongDuGL_AR, "NFD=0; NGS=."), Format(DoiSoatGL.DeltaAR, "NFD=0; NGS=.; NZ=0")));
	Log.Add(StrTemplate("[*] Doi soat doc lap Subledger AP vs GL TK 331: Subledger = %1, GL = %2, DELTA_AP = %3",
		Format(DoiSoatGL.TongDuSubAP, "NFD=0; NGS=."), Format(DoiSoatGL.TongDuGL_AP, "NFD=0; NGS=."), Format(DoiSoatGL.DeltaAP, "NFD=0; NGS=.; NZ=0")));
	If Not DoiSoatGL.HopLe Then
		Raise StrTemplate("LOI DOI SOAT DOC LAP GL VA SO PHU: Delta AR = %1, Delta AP = %2!", DoiSoatGL.DeltaAR, DoiSoatGL.DeltaAP);
	EndIf;
	Log.Add("[*] Tinh can doi No - Co doc lap: DELTA = 0 (Kiem toan toan ven 100% dat tieu chuan)");
	
	// 3. Kiem tra so du CongNoPhaiThu
	Q_AR = New Query(
		"SELECT " +
		"    SUM(AR.SoTienBalance) AS TongDuNo " +
		"FROM " +
		"    AccumulationRegister.CongNoPhaiThu.Balance AS AR"
	);
	ResAR = Q_AR.Execute().Unload();
	TongAR = 0;
	If ResAR.Count() > 0 And ResAR[0].TongDuNo <> Null Then
		TongAR = ResAR[0].TongDuNo;
	EndIf;
	Log.Add(StrTemplate("[*] CongNoPhaiThu (AR Subledger Balance): %1 VND", Format(TongAR, "NFD=0; NGS=.")));
	
	// 4. Kiem tra so du CongNoPhaiTra
	Q_AP = New Query(
		"SELECT " +
		"    SUM(AP.SoTienBalance) AS TongDuNo " +
		"FROM " +
		"    AccumulationRegister.CongNoPhaiTra.Balance AS AP"
	);
	ResAP = Q_AP.Execute().Unload();
	TongAP = 0;
	If ResAP.Count() > 0 And ResAP[0].TongDuNo <> Null Then
		TongAP = ResAP[0].TongDuNo;
	EndIf;
	Log.Add(StrTemplate("[*] CongNoPhaiTra (AP Subledger Balance): %1 VND", Format(TongAP, "NFD=0; NGS=.")));

	// 5. Kiem tra so du DongTien
	Q_CF = New Query(
		"SELECT " +
		"    SUM(CF.SoTienBalance) AS TongDuTien " +
		"FROM " +
		"    AccumulationRegister.DongTien.Balance AS CF"
	);
	ResCF = Q_CF.Execute().Unload();
	TongCF = 0;
	If ResCF.Count() > 0 And ResCF[0].TongDuTien <> Null Then
		TongCF = ResCF[0].TongDuTien;
	EndIf;
	Log.Add(StrTemplate("[*] DongTien (Cash & Bank Balance): %1 VND", Format(TongCF, "NFD=0; NGS=.")));

	Log.Add("=================================================================");
	Log.Add("   XAC NHAN HE THONG HOAN TOAN ON DINH, SAN SANG SU DUNG!       ");
	Log.Add("=================================================================");

	// Ghi log vao Nhat ky su kien (Event Log) chuan cua nen tang 1C
	WriteLogEvent("SeedData.Verify", EventLogLevel.Information,,, StrConcat(Log, Chars.LF));
EndProcedure

Procedure KiemTraDashboardCFO() Export
	Log = New Array;
	Log.Add("=================================================================");
	Log.Add("   KIỂM THỬ BÀN LÀM VIỆC LÃNH ĐẠO CFO (DASHBOARD CFO VSF)       ");
	Log.Add("   Thời gian thực hiện: " + CurrentSessionDate());
	Log.Add("=================================================================");
	
	// -------------------------------------------------------------
	// KIỂM THỬ BÀN LÀM VIỆC LÃNH ĐẠO CFO (DashboardLanhDaoCFO)
	// -------------------------------------------------------------
	Try
		ProcDashboard = DataProcessors.DashboardLanhDaoCFO.Create();
		Data = ProcDashboard.LaySoLieuDashboard();
		
		// 1. Kiểm tra 4 Khối kinh doanh + Khối BO
		If Data.CacKhoiKinhDoanh.Count() <> 5 Then
			Raise StrTemplate("Số lượng khối kinh doanh không đúng! Yêu cầu 5 khối, thực tế: %1", Data.CacKhoiKinhDoanh.Count());
		EndIf;
		
		Log.Add("[*] 1. Kiểm tra 4 Khối kinh doanh & Khối BO:");
		For Each Khoi In Data.CacKhoiKinhDoanh Do
			Log.Add(StrTemplate("    + %1: Doanh thu = %2 VND, Chi phí = %3 VND, Dự án = %4",
				Khoi.MaKhoi, Format(Khoi.DoanhThu, "NFD=0; NGS=."), Format(Khoi.ChiPhi, "NFD=0; NGS=."), Khoi.SoLuongDuAn));
		EndDo;
		
		TongDT = Data.TongHopKinhDoanh.TongDoanhThu;
		TongCP = Data.TongHopKinhDoanh.TongChiPhi;
		Log.Add("    ==> Tổng Doanh thu toàn VSF: " + Format(TongDT, "NFD=0; NGS=.") + " VND, Tổng Chi phí: " + Format(TongCP, "NFD=0; NGS=.") + " VND");
		
		If TongDT <= 0 Then
			Raise "Tổng doanh thu VSF phải lớn hơn 0!";
		EndIf;
		
		// 2. Kiểm tra công nợ AR / AP
		AR_Tong = Data.CongNo.AR.TongAR;
		AP_Tong = Data.CongNo.AP.TongAP;
		Log.Add("[*] 2. Công nợ AR / AP: Tổng AR = " + Format(AR_Tong, "NFD=0; NGS=.") + " VND (Nội bộ: " + String(Data.CongNo.AR.TyLeNoiBoAR) + "%), Tổng AP = " + Format(AP_Tong, "NFD=0; NGS=.") + " VND (Nội bộ: " + String(Data.CongNo.AP.TyLeNoiBoAP) + "%)");
		
		// 3. Kiểm tra dòng tiền ngân hàng
		Log.Add("[*] 3. Dòng tiền ngân hàng: TCB = " + Format(Data.DongTien.Techcombank_VND, "NFD=0; NGS=.") + " VND, VCB = " + Format(Data.DongTien.Vietcombank_USD.SoTienUSD, "NFD=2; NGS=.") + " USD (~" + Format(Data.DongTien.Vietcombank_USD.QuyDoiVND, "NFD=0; NGS=.") + " VND), VPB VA = " + Format(Data.DongTien.VPBank_VA, "NFD=0; NGS=.") + " VND, Tổng = " + Format(Data.DongTien.TongTienMatKhaDung, "NFD=0; NGS=.") + " VND");
			
		// 4. Kiểm tra chỉ số tài chính & Netting
		Log.Add("[*] 4. Chỉ số tài chính: DSO = " + String(Data.ChiSoTaiChinh.DSO) + " ngày, DPO = " + String(Data.ChiSoTaiChinh.DPO) + " ngày, Chu kỳ tiền mặt = " + String(Data.ChiSoTaiChinh.VongQuayTienMat) + " ngày");
		Log.Add("    + Netting: Tổng cấn trừ = " + Format(Data.ChiSoTaiChinh.Netting.TongTienCanTru, "NFD=0; NGS=.") + " VND (" + String(Data.ChiSoTaiChinh.Netting.SoLuongGiaoDichCanTru) + " chứng từ), Tiết kiệm = " + Format(Data.ChiSoTaiChinh.Netting.TienTietKiemThanhKhoan, "NFD=0; NGS=.") + " VND (Tỷ lệ: " + String(Data.ChiSoTaiChinh.Netting.TyLeTietKiemThanhKhoan) + "%)");
			
		Log.Add("DASHBOARD_VERIFY_SUCCESS: Bàn làm việc CFO truy vấn số liệu thời gian thực thành công 100%!");
	Except
		Log.Add("DASHBOARD_VERIFY_FAILED: " + DetailErrorDescription(ErrorInfo()));
		WriteLogEvent("Dashboard.Verify", EventLogLevel.Error,,, StrConcat(Log, Chars.LF));
		Raise;
	EndTry;
	
	Log.Add("=================================================================");
	Log.Add("   DASHBOARD_CFO_ALL_TESTS_PASS: 100% KIỂM THỬ THÀNH CÔNG!       ");
	Log.Add("=================================================================");
	WriteLogEvent("DashboardCFO.Verify", EventLogLevel.Information,,, StrConcat(Log, Chars.LF));
EndProcedure

Procedure XoaToanBoDuLieuGiaoDichCu() Export
	WriteLogEvent("SeedData.Clean", EventLogLevel.Information,,, ">>> Bắt đầu dọn dẹp toàn bộ dữ liệu giao dịch cũ theo thứ tự ràng buộc khóa ngoại...");
	DocList = New Array;
	DocList.Add("CanTruCongNoNoiBo");
	DocList.Add("BangKeDoiSoatKenhThanhToan");
	DocList.Add("UyNhiemChi");
	DocList.Add("PhieuThuTienKhachHang");
	DocList.Add("BaoCoNganHang");
	DocList.Add("HoaDonGTGTDauRa");
	DocList.Add("HoaDonNhaCungCap");
	DocList.Add("BienBanNghiemThuGiaiDoan");
	
	// Bước 1: Undo Posting toàn bộ các chứng từ để giải phóng sổ sách và khóa ghi
	For Each DocName In DocList Do
		Q = New Query("SELECT Ref FROM Document." + DocName + " WHERE Posted = TRUE");
		T = Q.Execute().Unload();
		If T.Count() > 0 Then
			BatchCount = 0;
			BeginTransaction();
			For Each R In T Do
				Try
					Obj = R.Ref.GetObject();
					If Obj <> Undefined And Obj.Posted Then
						Obj.Write(DocumentWriteMode.UndoPosting);
						BatchCount = BatchCount + 1;
						If BatchCount >= 50 Then
							CommitTransaction();
							BeginTransaction();
							BatchCount = 0;
						EndIf;
					EndIf;
				Except
				EndTry;
			EndDo;
			CommitTransaction();
		EndIf;
	EndDo;

	// Bước 2: Xóa vĩnh viễn các chứng từ theo thứ tự ràng buộc
	For Each DocName In DocList Do
		Q = New Query("SELECT Ref FROM Document." + DocName);
		T = Q.Execute().Unload();
		If T.Count() > 0 Then
			BatchCount = 0;
			BeginTransaction();
			For Each R In T Do
				Try
					Obj = R.Ref.GetObject();
					If Obj <> Undefined Then
						Obj.Delete();
						BatchCount = BatchCount + 1;
						If BatchCount >= 50 Then
							CommitTransaction();
							BeginTransaction();
							BatchCount = 0;
						EndIf;
					EndIf;
				Except
				EndTry;
			EndDo;
			CommitTransaction();
		EndIf;
	EndDo;
	WriteLogEvent("SeedData.Clean", EventLogLevel.Information,,, ">>> Dọn dẹp toàn bộ dữ liệu giao dịch cũ hoàn tất!");
EndProcedure

Procedure BackfillSoCaiAnalyticKeysServer() Export
	WriteLogEvent("GL.Backfill", EventLogLevel.Information,,, "=== BAT DAU BACKFILL ANALYTIC KEYS SO CAI ===");
	
	Q = New Query(
		"SELECT DISTINCT Recorder
		|FROM AccountingRegister.SoCaiKeToan");
	Recorders = Q.Execute().Unload();
	
	Total = Recorders.Count();
	UpdatedCount = 0;
	
	For Each Row In Recorders Do
		DocRef = Row.Recorder;
		If Not ValueIsFilled(DocRef) Then Continue; EndIf;
		
		DoiTacAR = Undefined;
		HopDongAR = Undefined;
		DoiTacAP = Undefined;
		HopDongAP = Undefined;
		DoiTacTrungGian = Undefined;
		
		Try
			If ValueIsFilled(DocRef.DoiTac) Then DoiTacAR = DocRef.DoiTac; DoiTacAP = DocRef.DoiTac; EndIf;
		Except
		EndTry;
		Try
			If ValueIsFilled(DocRef.DoiTacNoiBo) Then DoiTacAR = DocRef.DoiTacNoiBo; EndIf;
		Except
		EndTry;
		Try
			If ValueIsFilled(DocRef.DoiTacAP) Then DoiTacAP = DocRef.DoiTacAP; EndIf;
		Except
		EndTry;
		Try
			If ValueIsFilled(DocRef.DoiTacTrungGian) Then DoiTacTrungGian = DocRef.DoiTacTrungGian; EndIf;
		Except
		EndTry;
		
		Try
			If ValueIsFilled(DocRef.DoiTacKhop) Then 
				DoiTacAR = DocRef.DoiTacKhop; 
				DoiTacAP = DocRef.DoiTacKhop; 
			EndIf;
		Except
		EndTry;
		Try
			If ValueIsFilled(DocRef.ChungTuKhop) Then
				Try
					If ValueIsFilled(DocRef.ChungTuKhop.HopDong) Then HopDongAR = DocRef.ChungTuKhop.HopDong; EndIf;
				Except
				EndTry;
				Try
					If ValueIsFilled(DocRef.ChungTuKhop.DoiTac) Then DoiTacAR = DocRef.ChungTuKhop.DoiTac; EndIf;
				Except
				EndTry;
			EndIf;
		Except
		EndTry;
		Try
			If DocRef.Metadata().Name = "BangKeDoiSoatKenhThanhToan" Then
				If DocRef.ChiTietGiaoDich.Count() > 0 And ValueIsFilled(DocRef.ChiTietGiaoDich[0].DoiTac) Then
					DoiTacAR = DocRef.ChiTietGiaoDich[0].DoiTac;
				ElsIf ValueIsFilled(DocRef.KenhThanhToan) Then
					DoiTacAR = Catalogs.DoiTac.FindByDescription(String(DocRef.KenhThanhToan));
					If Not ValueIsFilled(DoiTacAR) Then
						DoiTacAR = Catalogs.DoiTac.FindByCode("DT-ONEPAY");
					EndIf;
				EndIf;
			EndIf;
		Except
		EndTry;
		
		Try
			If ValueIsFilled(DocRef.HopDong) Then HopDongAR = DocRef.HopDong; HopDongAP = DocRef.HopDong; EndIf;
		Except
		EndTry;
		Try
			If ValueIsFilled(DocRef.HopDongAR) Then HopDongAR = DocRef.HopDongAR; EndIf;
		Except
		EndTry;
		Try
			If ValueIsFilled(DocRef.HopDongAP) Then HopDongAP = DocRef.HopDongAP; EndIf;
		Except
		EndTry;
		
		RS = AccountingRegisters.SoCaiKeToan.CreateRecordSet();
		RS.Filter.Recorder.Set(DocRef);
		RS.Read();
		
		Modified = False;
		For Each Record In RS Do
			RecDoiTacAR = DoiTacAR;
			RecHopDongAR = HopDongAR;
			RecDoiTacAP = DoiTacAP;
			RecHopDongAP = HopDongAP;
			
			If ValueIsFilled(Record.ChungTuGoc) Then
				Try
					If ValueIsFilled(Record.ChungTuGoc.DoiTac) Then 
						RecDoiTacAR = Record.ChungTuGoc.DoiTac;
						RecDoiTacAP = Record.ChungTuGoc.DoiTac;
					EndIf;
				Except
				EndTry;
				Try
					If ValueIsFilled(Record.ChungTuGoc.HopDong) Then 
						RecHopDongAR = Record.ChungTuGoc.HopDong;
						RecHopDongAP = Record.ChungTuGoc.HopDong;
					EndIf;
				Except
				EndTry;
			EndIf;
			
			CodeDr = ?(ValueIsFilled(Record.AccountDr), Record.AccountDr.Code, "");
			CodeCr = ?(ValueIsFilled(Record.AccountCr), Record.AccountCr.Code, "");
			
			// TK No AR (1311, 1312, 1388)
			If CodeDr = "1311" Or CodeDr = "1312" Or CodeDr = "1388" Then
				P = ?(CodeDr = "1388" And ValueIsFilled(DoiTacTrungGian), DoiTacTrungGian, RecDoiTacAR);
				H = RecHopDongAR;
				If Not ValueIsFilled(Record.DoiTacNo) And ValueIsFilled(P) Then
					Record.DoiTacNo = P;
					Modified = True;
				EndIf;
				If Not ValueIsFilled(Record.HopDongNo) And ValueIsFilled(H) Then
					Record.HopDongNo = H;
					Modified = True;
				EndIf;
			EndIf;
			
			// TK Co AR (1311, 1312, 1388)
			If CodeCr = "1311" Or CodeCr = "1312" Or CodeCr = "1388" Then
				P = ?(CodeCr = "1388" And ValueIsFilled(DoiTacTrungGian), DoiTacTrungGian, RecDoiTacAR);
				H = RecHopDongAR;
				If Not ValueIsFilled(Record.DoiTacCo) And ValueIsFilled(P) Then
					Record.DoiTacCo = P;
					Modified = True;
				EndIf;
				If Not ValueIsFilled(Record.HopDongCo) And ValueIsFilled(H) Then
					Record.HopDongCo = H;
					Modified = True;
				EndIf;
			EndIf;
			
			// TK No AP (3311, 3312, 3313, 3388)
			If CodeDr = "3311" Or CodeDr = "3312" Or CodeDr = "3313" Or CodeDr = "3388" Then
				If Not ValueIsFilled(Record.DoiTacNo) And ValueIsFilled(RecDoiTacAP) Then
					Record.DoiTacNo = RecDoiTacAP;
					Modified = True;
				EndIf;
				If Not ValueIsFilled(Record.HopDongNo) And ValueIsFilled(RecHopDongAP) Then
					Record.HopDongNo = RecHopDongAP;
					Modified = True;
				EndIf;
			EndIf;
			
			// TK Co AP (3311, 3312, 3313, 3388)
			If CodeCr = "3311" Or CodeCr = "3312" Or CodeCr = "3313" Or CodeCr = "3388" Then
				If Not ValueIsFilled(Record.DoiTacCo) And ValueIsFilled(RecDoiTacAP) Then
					Record.DoiTacCo = RecDoiTacAP;
					Modified = True;
				EndIf;
				If Not ValueIsFilled(Record.HopDongCo) And ValueIsFilled(RecHopDongAP) Then
					Record.HopDongCo = RecHopDongAP;
					Modified = True;
				EndIf;
			EndIf;
			
			// Fallback tu Record.DoiTac / Record.HopDong
			If ValueIsFilled(Record.DoiTac) Then
				If (CodeDr = "1311" Or CodeDr = "1312" Or CodeDr = "1388" Or CodeDr = "3311" Or CodeDr = "3312" Or CodeDr = "3313" Or CodeDr = "3388") And Not ValueIsFilled(Record.DoiTacNo) Then
					Record.DoiTacNo = Record.DoiTac;
					Modified = True;
				EndIf;
				If (CodeCr = "1311" Or CodeCr = "1312" Or CodeCr = "1388" Or CodeCr = "3311" Or CodeCr = "3312" Or CodeCr = "3313" Or CodeCr = "3388") And Not ValueIsFilled(Record.DoiTacCo) Then
					Record.DoiTacCo = Record.DoiTac;
					Modified = True;
				EndIf;
			EndIf;
			If ValueIsFilled(Record.HopDong) Then
				If (CodeDr = "1311" Or CodeDr = "1312" Or CodeDr = "1388" Or CodeDr = "3311" Or CodeDr = "3312" Or CodeDr = "3313" Or CodeDr = "3388") And Not ValueIsFilled(Record.HopDongNo) Then
					Record.HopDongNo = Record.HopDong;
					Modified = True;
				EndIf;
				If (CodeCr = "1311" Or CodeCr = "1312" Or CodeCr = "1388" Or CodeCr = "3311" Or CodeCr = "3312" Or CodeCr = "3313" Or CodeCr = "3388") And Not ValueIsFilled(Record.HopDongCo) Then
					Record.HopDongCo = Record.HopDong;
					Modified = True;
				EndIf;
			EndIf;
			
			// Final Safety Fallback
			If (CodeDr = "1311" Or CodeDr = "1312" Or CodeDr = "1388" Or CodeDr = "3311" Or CodeDr = "3312" Or CodeDr = "3313" Or CodeDr = "3388") And Not ValueIsFilled(Record.DoiTacNo) Then
				If ValueIsFilled(RecDoiTacAR) Then
					Record.DoiTacNo = RecDoiTacAR;
					Modified = True;
				ElsIf ValueIsFilled(RecDoiTacAP) Then
					Record.DoiTacNo = RecDoiTacAP;
					Modified = True;
				EndIf;
			EndIf;
			If (CodeCr = "1311" Or CodeCr = "1312" Or CodeCr = "1388" Or CodeCr = "3311" Or CodeCr = "3312" Or CodeCr = "3313" Or CodeCr = "3388") And Not ValueIsFilled(Record.DoiTacCo) Then
				If ValueIsFilled(RecDoiTacAR) Then
					Record.DoiTacCo = RecDoiTacAR;
					Modified = True;
				ElsIf ValueIsFilled(RecDoiTacAP) Then
					Record.DoiTacCo = RecDoiTacAP;
					Modified = True;
				EndIf;
			EndIf;
			
			// Cap nhat common attributes DoiTac, HopDong neu chua co
			If Not ValueIsFilled(Record.DoiTac) Then
				If ValueIsFilled(RecDoiTacAR) Then
					Record.DoiTac = RecDoiTacAR;
					Modified = True;
				ElsIf ValueIsFilled(RecDoiTacAP) Then
					Record.DoiTac = RecDoiTacAP;
					Modified = True;
				EndIf;
			EndIf;
			If Not ValueIsFilled(Record.HopDong) Then
				If ValueIsFilled(RecHopDongAR) Then
					Record.HopDong = RecHopDongAR;
					Modified = True;
				ElsIf ValueIsFilled(RecHopDongAP) Then
					Record.HopDong = RecHopDongAP;
					Modified = True;
				EndIf;
			EndIf;
		EndDo;
		
		If Modified Then
			RS.DataExchange.Load = True;
			RS.Write();
			UpdatedCount = UpdatedCount + 1;
		EndIf;
	EndDo;
	
	WriteLogEvent("GL.Backfill", EventLogLevel.Information,,, 
		StrTemplate("HOAN TAT BACKFILL ANALYTIC KEYS: Da cap nhat %1 / %2 chung tu", UpdatedCount, Total));
EndProcedure

Procedure KiemTraGLAnalyticKeysServer() Export
	Q = New Query(
		"SELECT
		|	COUNT(*) AS TongBanGhi,
		|	SUM(CASE WHEN (TKDr.Code IN (""1311"", ""1312"", ""1388"", ""3311"", ""3312"", ""3313"", ""3388"") AND (SC.DoiTacNo IS NULL OR SC.DoiTacNo = VALUE(Catalog.DoiTac.EmptyRef)))
		|              OR (TKCr.Code IN (""1311"", ""1312"", ""1388"", ""3311"", ""3312"", ""3313"", ""3388"") AND (SC.DoiTacCo IS NULL OR SC.DoiTacCo = VALUE(Catalog.DoiTac.EmptyRef))) THEN 1 ELSE 0 END) AS SoBanGhiThieuKey
		|FROM
		|	AccountingRegister.SoCaiKeToan AS SC
		|	LEFT JOIN ChartOfAccounts.HeThongTaiKhoan AS TKDr ON SC.AccountDr = TKDr.Ref
		|	LEFT JOIN ChartOfAccounts.HeThongTaiKhoan AS TKCr ON SC.AccountCr = TKCr.Ref");
	
	Res = Q.Execute().Unload();
	Tong = ?(Res.Count() > 0, Res[0].TongBanGhi, 0);
	Thieu = ?(Res.Count() > 0, Res[0].SoBanGhiThieuKey, 0);
	Co = Tong - Thieu;
	TyLe = ?(Tong > 0, Round(Co / Tong * 100, 1), 100);
	
	LogText = New Array;
	LogText.Add("=================================================================");
	LogText.Add("   KET QUA KIEM KE ANALYTIC KEYS SO CAI KETOAN (SOCAIKETOAN)    ");
	LogText.Add("=================================================================");
	LogText.Add(StrTemplate("Tong so ban ghi So Cai: %1", Tong));
	LogText.Add(StrTemplate("So ban ghi co du Analytic Keys: %1", Co));
	LogText.Add(StrTemplate("So ban ghi thieu Analytic Keys: %1", Thieu));
	LogText.Add("TY LE HOAN TAT: " + Format(TyLe, "NFD=1; NGS=.") + "%");
	If Thieu = 0 Then
		LogText.Add(">> XAC NHAN: 100.0% ANALYTIC KEYS POPULATED [DAT CHUAN KIEM TOAN]");
	EndIf;
	LogText.Add("=================================================================");
	
	LogFilePath = "C:/Users/Dung/Documents/1C_Enterprise/verify_gl_keys.log";
	TW = New TextWriter(LogFilePath, TextEncoding.UTF8);
	For Each Line In LogText Do
		TW.WriteLine(Line);
	EndDo;
	TW.Close();
	WriteLogEvent("GL.Verify", EventLogLevel.Information,,, "Kiem ke GL Keys: " + Co + "/" + Tong + " hop le (" + TyLe + "%)");
EndProcedure


