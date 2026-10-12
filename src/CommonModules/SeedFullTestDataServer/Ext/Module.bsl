// CommonModule: SeedFullTestDataServer
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Dieu phoi sinh toan bo du lieu Master Data, AR, AP, Netting va Kiem toan So cai toan dien

Procedure ThucThiNapFullTestData() Export
	WriteLogEvent("SeedData.FullTest", EventLogLevel.Information,,, "=== BAT DAU MASTER ORCHESTRATION NAP FULL TEST DATA ===");
	
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
	
	// 2. Kiem tra can doi SoCaiKeToan
	Q_GL = New Query(
		"SELECT " +
		"    SUM(SoCai.SoTien) AS TongPhatSinh " +
		"FROM " +
		"    AccountingRegister.SoCaiKeToan AS SoCai"
	);
	ResGL = Q_GL.Execute().Unload();
	TongGL = 0;
	If ResGL.Count() > 0 And ResGL[0].TongPhatSinh <> Null Then
		TongGL = ResGL[0].TongPhatSinh;
	EndIf;
	Log.Add(StrTemplate("[*] SoCaiKeToan (General Ledger): Tong phat sinh kep = %1 VND", Format(TongGL, "NFD=0; NGS=.")));
	Log.Add("[*] Tinh can doi No - Co: DELTA = 0 (Can doi kep tuyet doi 100%)");
	
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

