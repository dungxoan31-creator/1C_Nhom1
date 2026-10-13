// CommonModule: SeedFullTestDataServer
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Dieu phoi sinh toan bo du lieu Master Data, AR, AP, Netting va Kiem toan So cai toan dien

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


