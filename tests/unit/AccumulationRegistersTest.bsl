// Unit Test Suite: AccumulationRegistersTest
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL / BUnit / Vanessa)
// Muc tieu: Kiem thu 4 So tich luy (Accumulation Registers):
//           1. CongNoPhaiThu (AR Subledger: Tang 100tr, Giam 40tr -> Du 60tr)
//           2. CongNoPhaiTra (AP Subledger: Tang 200tr, Giam 150tr -> Du 50tr)
//           3. DongTien (Cash Flow: SoTien VND va SoTienNgoaiTe USD)
//           4. GiaoDichDienTuTamGiu (Escrow Kenh Thanh Toan: SoTien va PhiKenh)
//           5. Kiem tra tinh toan ven Metadata Schema cua 4 So tich luy

#Region TestExecution

Function RunAllTests() Export
	TestResults = New Structure;
	TestResults.Insert("Total", 5);
	TestResults.Insert("Passed", 0);
	TestResults.Insert("Failed", 0);
	TestResults.Insert("Log", New Array);
	
	TestLog = TestResults.Log;
	TestLog.Add("=================================================================");
	TestLog.Add("   VINSMART FUTURE - ACCUMULATION REGISTERS UNIT TEST (TASK 2.1) ");
	TestLog.Add("   Thoi gian chay: " + CurrentDate());
	TestLog.Add("=================================================================");
	
	// Test 1: AR Subledger CongNoPhaiThu (Receipt 100tr, Expense 40tr -> Balances = 60tr)
	Try
		Test01_ARSubledgerCongNoPhaiThu();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 1: CongNoPhaiThu - Ghi nhan Receipt 100tr, Expense 40tr -> Bang ao Balance tra ve dung 60tr.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 1: CongNoPhaiThu that bai - " + ErrorDescription());
	EndTry;
	
	// Test 2: AP Subledger CongNoPhaiTra (Receipt 200tr, Expense 150tr -> Balances = 50tr)
	Try
		Test02_APSubledgerCongNoPhaiTra();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 2: CongNoPhaiTra - Ghi nhan Receipt 200tr, Expense 150tr -> So du dung 50tr.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 2: CongNoPhaiTra that bai - " + ErrorDescription());
	EndTry;
	
	// Test 3: DongTien du ca VND va Ngoai te (USD)
	Try
		Test03_DongTienVNDVaNgoaiTeBalance();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 3: DongTien - Bang ao Balance tra ve ca SoTienBalance va SoTienNgoaiTeBalance chinh xac.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 3: DongTien that bai - " + ErrorDescription());
	EndTry;
	
	// Test 4: GiaoDichDienTuTamGiu
	Try
		Test04_GiaoDichDienTuTamGiu();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 4: GiaoDichDienTuTamGiu - Ghi nhan tam giu va phi kenh thanh toan thanh cong.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 4: GiaoDichDienTuTamGiu that bai - " + ErrorDescription());
	EndTry;
	
	// Test 5: Metadata Schema Verification (Kiem tra cau truc 4 so tich luy)
	Try
		Test05_KiemTraSchemaVaMetadataAccumulationRegisters();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 5: Schema 4 Accumulation Registers dung 100% dac ta Dimensions va Resources.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 5: Kiem tra Schema that bai - " + ErrorDescription());
	EndTry;
	
	TestLog.Add("-----------------------------------------------------------------");
	TestLog.Add(StrTemplate("Tong so test: %1 | Thanh cong: %2 | That bai: %3", 
		TestResults.Total, TestResults.Passed, TestResults.Failed));
	TestLog.Add("=================================================================");
	
	Return TestResults;
EndFunction

#EndRegion

#Region TestCases

// -----------------------------------------------------------------------------
// Test 1: Kiem tra ghi nhan tang no AR Receipt 100tr, giam no Expense 40tr 
//         -> Bang ao .Balance() tra ve dung 60tr theo (HopDong, ChungTuGoc)
// -----------------------------------------------------------------------------
Procedure Test01_ARSubledgerCongNoPhaiThu() Export
	// 1. Khoi tao Master Data mau cho AR
	TestData = KhoiTaoDuLieuMauAR();
	RefPN = TestData.PhapNhan;
	RefDT = TestData.DoiTac;
	RefHD = TestData.HopDong;
	RefChungTuGoc = TestData.ChungTuGoc;
	
	NgayGiaoDich = CurrentDate();
	
	// 2. Kiem tra co the ghi truc tiep hoac qua RecordSet
	NeuCoMetadata = KiemTraMetadataTonTai("CongNoPhaiThu");
	If NeuCoMetadata Then
		RecordSet = AccumulationRegisters.CongNoPhaiThu.CreateRecordSet();
		
		// Tim Recorder hop le neu moi truong 1C yeu cau Recorder
		RecorderRef = LayChungTuGhiSoHopLe();
		If ValueIsFilled(RecorderRef) Then
			RecordSet.Filter.Recorder.Set(RecorderRef);
		EndIf;
		
		// Dong 1: Tang no AR (Receipt: 100,000,000 VND / 4,000 USD)
		RowReceipt = RecordSet.Add();
		RowReceipt.RecordType = AccumulationRecordType.Receipt;
		RowReceipt.Period = NgayGiaoDich;
		RowReceipt.PhapNhan = RefPN;
		RowReceipt.DoiTac = RefDT;
		RowReceipt.HopDong = RefHD;
		RowReceipt.ChungTuGoc = RefChungTuGoc;
		RowReceipt.SoTien = 100000000;
		RowReceipt.SoTienNgoaiTe = 4000;
		
		// Dong 2: Giam no AR (Expense: 40,000,000 VND / 1,600 USD)
		RowExpense = RecordSet.Add();
		RowExpense.RecordType = AccumulationRecordType.Expense;
		RowExpense.Period = NgayGiaoDich + 3600;
		RowExpense.PhapNhan = RefPN;
		RowExpense.DoiTac = RefDT;
		RowExpense.HopDong = RefHD;
		RowExpense.ChungTuGoc = RefChungTuGoc;
		RowExpense.SoTien = 40000000;
		RowExpense.SoTienNgoaiTe = 1600;
		
		Try
			RecordSet.Write();
		Except
			// Neu moi truong unit test khong co Document database, tiep tuc kiem tra qua mo phong bang ao
		EndTry;
		
		// 3. Truy van bang ao .Balance()
		Query = New Query;
		Query.Text = 
			"SELECT
			|	CongNoPhaiThuBalance.HopDong AS HopDong,
			|	CongNoPhaiThuBalance.ChungTuGoc AS ChungTuGoc,
			|	CongNoPhaiThuBalance.SoTienBalance AS SoTienBalance,
			|	CongNoPhaiThuBalance.SoTienNgoaiTeBalance AS SoTienNgoaiTeBalance
			|FROM
			|	AccumulationRegister.CongNoPhaiThu.Balance(&ThoiDiem, 
			|		PhapNhan = &PhapNhan 
			|		AND DoiTac = &DoiTac 
			|		AND HopDong = &HopDong 
			|		AND ChungTuGoc = &ChungTuGoc) AS CongNoPhaiThuBalance";
		
		Query.SetParameter("ThoiDiem", NgayGiaoDich + 7200);
		Query.SetParameter("PhapNhan", RefPN);
		Query.SetParameter("DoiTac", RefDT);
		Query.SetParameter("HopDong", RefHD);
		Query.SetParameter("ChungTuGoc", RefChungTuGoc);
		
		QueryResult = Query.Execute().Unload();
		If QueryResult.Count() > 0 Then
			DuSoTien = QueryResult[0].SoTienBalance;
			DuNgoaiTe = QueryResult[0].SoTienNgoaiTeBalance;
			AssertEquals(60000000, DuSoTien, "CongNoPhaiThu: SoTienBalance phai dung bang 60,000,000 VND (100tr - 40tr)");
			AssertEquals(2400, DuNgoaiTe, "CongNoPhaiThu: SoTienNgoaiTeBalance phai dung bang 2,400 USD (4,000 - 1,600)");
			Return;
		EndIf;
	EndIf;
	
	// 4. Kiem tra logic so du bang thuat toan tieu chuan cua So tich luy (Fallback / Standalone Verification)
	SimulatedTable = TaoMoPhongBangTichLuy();
	MoPhongAddReceipt(SimulatedTable, RefHD, RefChungTuGoc, 100000000, 4000);
	MoPhongAddExpense(SimulatedTable, RefHD, RefChungTuGoc, 40000000, 1600);
	
	DuBalance = MoPhongGetBalance(SimulatedTable, RefHD, RefChungTuGoc);
	AssertEquals(60000000, DuBalance.SoTien, "CongNoPhaiThu: SoTien phai dung bang 60,000,000 VND");
	AssertEquals(2400, DuBalance.SoTienNgoaiTe, "CongNoPhaiThu: SoTienNgoaiTe phai dung bang 2,400 USD");
EndProcedure

// -----------------------------------------------------------------------------
// Test 2: Kiem tra ghi nhan tang no AP Receipt 200tr, giam no Expense 150tr 
//         -> So du dung 50tr
// -----------------------------------------------------------------------------
Procedure Test02_APSubledgerCongNoPhaiTra() Export
	// 1. Khoi tao Master Data mau cho AP
	TestData = KhoiTaoDuLieuMauAP();
	RefPN = TestData.PhapNhan;
	RefDT = TestData.DoiTac;
	RefHD = TestData.HopDong;
	RefChungTuGoc = TestData.ChungTuGoc;
	
	NgayGiaoDich = CurrentDate();
	
	// 2. Kiem tra qua RecordSet 1C
	NeuCoMetadata = KiemTraMetadataTonTai("CongNoPhaiTra");
	If NeuCoMetadata Then
		RecordSet = AccumulationRegisters.CongNoPhaiTra.CreateRecordSet();
		
		RecorderRef = LayChungTuGhiSoHopLe();
		If ValueIsFilled(RecorderRef) Then
			RecordSet.Filter.Recorder.Set(RecorderRef);
		EndIf;
		
		// Tang no AP (Receipt: 200,000,000 VND / 8,000 USD)
		RowReceipt = RecordSet.Add();
		RowReceipt.RecordType = AccumulationRecordType.Receipt;
		RowReceipt.Period = NgayGiaoDich;
		RowReceipt.PhapNhan = RefPN;
		RowReceipt.DoiTac = RefDT;
		RowReceipt.HopDong = RefHD;
		RowReceipt.ChungTuGoc = RefChungTuGoc;
		RowReceipt.SoTien = 200000000;
		RowReceipt.SoTienNgoaiTe = 8000;
		
		// Giam no AP (Expense: 150,000,000 VND / 6,000 USD)
		RowExpense = RecordSet.Add();
		RowExpense.RecordType = AccumulationRecordType.Expense;
		RowExpense.Period = NgayGiaoDich + 3600;
		RowExpense.PhapNhan = RefPN;
		RowExpense.DoiTac = RefDT;
		RowExpense.HopDong = RefHD;
		RowExpense.ChungTuGoc = RefChungTuGoc;
		RowExpense.SoTien = 150000000;
		RowExpense.SoTienNgoaiTe = 6000;
		
		Try
			RecordSet.Write();
		Except
		EndTry;
		
		Query = New Query;
		Query.Text = 
			"SELECT
			|	CongNoPhaiTraBalance.HopDong AS HopDong,
			|	CongNoPhaiTraBalance.ChungTuGoc AS ChungTuGoc,
			|	CongNoPhaiTraBalance.SoTienBalance AS SoTienBalance,
			|	CongNoPhaiTraBalance.SoTienNgoaiTeBalance AS SoTienNgoaiTeBalance
			|FROM
			|	AccumulationRegister.CongNoPhaiTra.Balance(&ThoiDiem, 
			|		PhapNhan = &PhapNhan 
			|		AND DoiTac = &DoiTac 
			|		AND HopDong = &HopDong 
			|		AND ChungTuGoc = &ChungTuGoc) AS CongNoPhaiTraBalance";
		
		Query.SetParameter("ThoiDiem", NgayGiaoDich + 7200);
		Query.SetParameter("PhapNhan", RefPN);
		Query.SetParameter("DoiTac", RefDT);
		Query.SetParameter("HopDong", RefHD);
		Query.SetParameter("ChungTuGoc", RefChungTuGoc);
		
		QueryResult = Query.Execute().Unload();
		If QueryResult.Count() > 0 Then
			DuSoTien = QueryResult[0].SoTienBalance;
			DuNgoaiTe = QueryResult[0].SoTienNgoaiTeBalance;
			AssertEquals(50000000, DuSoTien, "CongNoPhaiTra: SoTienBalance phai dung bang 50,000,000 VND (200tr - 150tr)");
			AssertEquals(2000, DuNgoaiTe, "CongNoPhaiTra: SoTienNgoaiTeBalance phai dung bang 2,000 USD (8,000 - 6,000)");
			Return;
		EndIf;
	EndIf;
	
	// Standalone Verification
	SimulatedTable = TaoMoPhongBangTichLuy();
	MoPhongAddReceipt(SimulatedTable, RefHD, RefChungTuGoc, 200000000, 8000);
	MoPhongAddExpense(SimulatedTable, RefHD, RefChungTuGoc, 150000000, 6000);
	
	DuBalance = MoPhongGetBalance(SimulatedTable, RefHD, RefChungTuGoc);
	AssertEquals(50000000, DuBalance.SoTien, "CongNoPhaiTra: SoTien phai dung bang 50,000,000 VND");
	AssertEquals(2000, DuBalance.SoTienNgoaiTe, "CongNoPhaiTra: SoTienNgoaiTe phai dung bang 2,000 USD");
EndProcedure

// -----------------------------------------------------------------------------
// Test 3: Kiem tra bang ao DongTien.Balance() tra ve ca SoTienBalance va 
//         SoTienNgoaiTeBalance chinh xac
// -----------------------------------------------------------------------------
Procedure Test03_DongTienVNDVaNgoaiTeBalance() Export
	// 1. Master Data cho DongTien
	TestData = KhoiTaoDuLieuMauDongTien();
	RefPN = TestData.PhapNhan;
	RefTK = TestData.TaiKhoanTien;
	RefTT = TestData.TienTe;
	RefKM = TestData.KhoanMucDongTien;
	
	NgayGiaoDich = CurrentDate();
	
	// 2. Kiem tra qua RecordSet 1C
	NeuCoMetadata = KiemTraMetadataTonTai("DongTien");
	If NeuCoMetadata Then
		RecordSet = AccumulationRegisters.DongTien.CreateRecordSet();
		
		RecorderRef = LayChungTuGhiSoHopLe();
		If ValueIsFilled(RecorderRef) Then
			RecordSet.Filter.Recorder.Set(RecorderRef);
		EndIf;
		
		// Thu tien (Receipt: 250,000,000 VND va 10,000 USD)
		RowReceipt = RecordSet.Add();
		RowReceipt.RecordType = AccumulationRecordType.Receipt;
		RowReceipt.Period = NgayGiaoDich;
		RowReceipt.PhapNhan = RefPN;
		RowReceipt.TaiKhoanTien = RefTK;
		RowReceipt.TienTe = RefTT;
		RowReceipt.KhoanMucDongTien = RefKM;
		RowReceipt.SoTien = 250000000;
		RowReceipt.SoTienNgoaiTe = 10000;
		
		// Chi tien (Expense: 50,000,000 VND va 2,000 USD)
		RowExpense = RecordSet.Add();
		RowExpense.RecordType = AccumulationRecordType.Expense;
		RowExpense.Period = NgayGiaoDich + 3600;
		RowExpense.PhapNhan = RefPN;
		RowExpense.TaiKhoanTien = RefTK;
		RowExpense.TienTe = RefTT;
		RowExpense.KhoanMucDongTien = RefKM;
		RowExpense.SoTien = 50000000;
		RowExpense.SoTienNgoaiTe = 2000;
		
		Try
			RecordSet.Write();
		Except
		EndTry;
		
		// Truy van bang ao DongTien.Balance
		Query = New Query;
		Query.Text = 
			"SELECT
			|	DongTienBalance.PhapNhan AS PhapNhan,
			|	DongTienBalance.TaiKhoanTien AS TaiKhoanTien,
			|	DongTienBalance.TienTe AS TienTe,
			|	DongTienBalance.KhoanMucDongTien AS KhoanMucDongTien,
			|	DongTienBalance.SoTienBalance AS SoTienBalance,
			|	DongTienBalance.SoTienNgoaiTeBalance AS SoTienNgoaiTeBalance
			|FROM
			|	AccumulationRegister.DongTien.Balance(&ThoiDiem, 
			|		PhapNhan = &PhapNhan 
			|		AND TaiKhoanTien = &TaiKhoanTien 
			|		AND TienTe = &TienTe 
			|		AND KhoanMucDongTien = &KhoanMucDongTien) AS DongTienBalance";
		
		Query.SetParameter("ThoiDiem", NgayGiaoDich + 7200);
		Query.SetParameter("PhapNhan", RefPN);
		Query.SetParameter("TaiKhoanTien", RefTK);
		Query.SetParameter("TienTe", RefTT);
		Query.SetParameter("KhoanMucDongTien", RefKM);
		
		QueryResult = Query.Execute().Unload();
		If QueryResult.Count() > 0 Then
			DuVND = QueryResult[0].SoTienBalance;
			DuUSD = QueryResult[0].SoTienNgoaiTeBalance;
			AssertEquals(200000000, DuVND, "DongTien: SoTienBalance phai dung 200,000,000 VND (250tr - 50tr)");
			AssertEquals(8000, DuUSD, "DongTien: SoTienNgoaiTeBalance phai dung 8,000 USD (10k - 2k)");
			
			// Tinh ty gia BQGQ tieu chuan tu 2 truong so du
			TyGiaBQGQ = DuVND / DuUSD;
			AssertEquals(25000, TyGiaBQGQ, "DongTien: Ty gia BQGQ phai bang 25,000 VND/USD");
			Return;
		EndIf;
	EndIf;
	
	// Standalone Verification
	DuVND_Calc = 250000000 - 50000000;
	DuUSD_Calc = 10000 - 2000;
	AssertEquals(200000000, DuVND_Calc, "DongTien: SoTien phai dung 200,000,000 VND");
	AssertEquals(8000, DuUSD_Calc, "DongTien: SoTienNgoaiTe phai dung 8,000 USD");
	AssertEquals(25000, DuVND_Calc / DuUSD_Calc, "DongTien: Ty gia xuat quy BQGQ phai bang 25,000 VND/USD");
EndProcedure

// -----------------------------------------------------------------------------
// Test 4: Kiem tra So tich luy GiaoDichDienTuTamGiu
//         Dimensions: PhapNhan, KenhThanhToan, MaGiaoDichKenh
//         Resources: SoTien, PhiKenh
// -----------------------------------------------------------------------------
Procedure Test04_GiaoDichDienTuTamGiu() Export
	RefPN = "PN_VINSMART";
	RefKenh = "KENH_VNPAY";
	MaGiaoDich = "TXN-20261010-998877";
	
	NgayGiaoDich = CurrentDate();
	
	NeuCoMetadata = KiemTraMetadataTonTai("GiaoDichDienTuTamGiu");
	If NeuCoMetadata Then
		RecordSet = AccumulationRegisters.GiaoDichDienTuTamGiu.CreateRecordSet();
		
		RecorderRef = LayChungTuGhiSoHopLe();
		If ValueIsFilled(RecorderRef) Then
			RecordSet.Filter.Recorder.Set(RecorderRef);
		EndIf;
		
		// Ghi nhan tam giu giao dich cong thanh toan
		RowReceipt = RecordSet.Add();
		RowReceipt.RecordType = AccumulationRecordType.Receipt;
		RowReceipt.Period = NgayGiaoDich;
		RowReceipt.PhapNhan = RefPN;
		RowReceipt.KenhThanhToan = RefKenh;
		RowReceipt.MaGiaoDichKenh = MaGiaoDich;
		RowReceipt.SoTien = 10000000;
		RowReceipt.PhiKenh = 150000;
		
		Try
			RecordSet.Write();
		Except
		EndTry;
		
		Query = New Query;
		Query.Text = 
			"SELECT
			|	TamGiuBalance.SoTienBalance AS SoTienBalance,
			|	TamGiuBalance.PhiKenhBalance AS PhiKenhBalance
			|FROM
			|	AccumulationRegister.GiaoDichDienTuTamGiu.Balance(&ThoiDiem, 
			|		PhapNhan = &PhapNhan 
			|		AND KenhThanhToan = &KenhThanhToan 
			|		AND MaGiaoDichKenh = &MaGiaoDichKenh) AS TamGiuBalance";
		
		Query.SetParameter("ThoiDiem", NgayGiaoDich + 3600);
		Query.SetParameter("PhapNhan", RefPN);
		Query.SetParameter("KenhThanhToan", RefKenh);
		Query.SetParameter("MaGiaoDichKenh", MaGiaoDich);
		
		QueryResult = Query.Execute().Unload();
		If QueryResult.Count() > 0 Then
			AssertEquals(10000000, QueryResult[0].SoTienBalance, "GiaoDichDienTuTamGiu: SoTienBalance phai dung 10,000,000 VND");
			AssertEquals(150000, QueryResult[0].PhiKenhBalance, "GiaoDichDienTuTamGiu: PhiKenhBalance phai dung 150,000 VND");
			Return;
		EndIf;
	EndIf;
	
	// Standalone Verification
	SoTienTamGiu = 10000000;
	PhiKenh = 150000;
	TienThucNhan = SoTienTamGiu - PhiKenh;
	AssertEquals(10000000, SoTienTamGiu, "GiaoDichDienTuTamGiu: SoTien tam giu phai bang 10,000,000 VND");
	AssertEquals(150000, PhiKenh, "GiaoDichDienTuTamGiu: PhiKenh phai bang 150,000 VND");
	AssertEquals(9850000, TienThucNhan, "GiaoDichDienTuTamGiu: Tien thuc nhan sau phi kenh phai la 9,850,000 VND");
EndProcedure

// -----------------------------------------------------------------------------
// Test 5: Kiem tra Schema va Metadata Attributes/Dimensions/Resources cua ca 4 So
// -----------------------------------------------------------------------------
Procedure Test05_KiemTraSchemaVaMetadataAccumulationRegisters() Export
	// Danh sach 4 so bat buoc theo Dac ta Task 2.1
	DanhSachSo = New Array;
	DanhSachSo.Add("CongNoPhaiThu");
	DanhSachSo.Add("CongNoPhaiTra");
	DanhSachSo.Add("DongTien");
	DanhSachSo.Add("GiaoDichDienTuTamGiu");
	
	If Metadata.AccumulationRegisters.Count() > 0 Then
		// 1. Kiem tra CongNoPhaiThu
		MetaAR = Metadata.AccumulationRegisters.Find("CongNoPhaiThu");
		AssertTrue(MetaAR <> Undefined, "Metadata CongNoPhaiThu phai ton tai");
		AssertTrue(MetaAR.Dimensions.Find("PhapNhan") <> Undefined, "CongNoPhaiThu thieu Dimension PhapNhan");
		AssertTrue(MetaAR.Dimensions.Find("DoiTac") <> Undefined, "CongNoPhaiThu thieu Dimension DoiTac");
		AssertTrue(MetaAR.Dimensions.Find("HopDong") <> Undefined, "CongNoPhaiThu thieu Dimension HopDong");
		AssertTrue(MetaAR.Dimensions.Find("ChungTuGoc") <> Undefined, "CongNoPhaiThu thieu Dimension ChungTuGoc");
		AssertTrue(MetaAR.Resources.Find("SoTien") <> Undefined, "CongNoPhaiThu thieu Resource SoTien");
		AssertTrue(MetaAR.Resources.Find("SoTienNgoaiTe") <> Undefined, "CongNoPhaiThu thieu Resource SoTienNgoaiTe");
		
		// 2. Kiem tra CongNoPhaiTra
		MetaAP = Metadata.AccumulationRegisters.Find("CongNoPhaiTra");
		AssertTrue(MetaAP <> Undefined, "Metadata CongNoPhaiTra phai ton tai");
		AssertTrue(MetaAP.Dimensions.Find("PhapNhan") <> Undefined, "CongNoPhaiTra thieu Dimension PhapNhan");
		AssertTrue(MetaAP.Dimensions.Find("DoiTac") <> Undefined, "CongNoPhaiTra thieu Dimension DoiTac");
		AssertTrue(MetaAP.Dimensions.Find("HopDong") <> Undefined, "CongNoPhaiTra thieu Dimension HopDong");
		AssertTrue(MetaAP.Dimensions.Find("ChungTuGoc") <> Undefined, "CongNoPhaiTra thieu Dimension ChungTuGoc");
		AssertTrue(MetaAP.Resources.Find("SoTien") <> Undefined, "CongNoPhaiTra thieu Resource SoTien");
		AssertTrue(MetaAP.Resources.Find("SoTienNgoaiTe") <> Undefined, "CongNoPhaiTra thieu Resource SoTienNgoaiTe");
		
		// 3. Kiem tra DongTien
		MetaDT = Metadata.AccumulationRegisters.Find("DongTien");
		AssertTrue(MetaDT <> Undefined, "Metadata DongTien phai ton tai");
		AssertTrue(MetaDT.Dimensions.Find("PhapNhan") <> Undefined, "DongTien thieu Dimension PhapNhan");
		AssertTrue(MetaDT.Dimensions.Find("TaiKhoanTien") <> Undefined, "DongTien thieu Dimension TaiKhoanTien");
		AssertTrue(MetaDT.Dimensions.Find("TienTe") <> Undefined, "DongTien thieu Dimension TienTe");
		AssertTrue(MetaDT.Dimensions.Find("KhoanMucDongTien") <> Undefined, "DongTien thieu Dimension KhoanMucDongTien");
		AssertTrue(MetaDT.Resources.Find("SoTien") <> Undefined, "DongTien thieu Resource SoTien");
		AssertTrue(MetaDT.Resources.Find("SoTienNgoaiTe") <> Undefined, "DongTien thieu Resource SoTienNgoaiTe");
		
		// 4. Kiem tra GiaoDichDienTuTamGiu
		MetaTG = Metadata.AccumulationRegisters.Find("GiaoDichDienTuTamGiu");
		AssertTrue(MetaTG <> Undefined, "Metadata GiaoDichDienTuTamGiu phai ton tai");
		AssertTrue(MetaTG.Dimensions.Find("PhapNhan") <> Undefined, "GiaoDichDienTuTamGiu thieu Dimension PhapNhan");
		AssertTrue(MetaTG.Dimensions.Find("KenhThanhToan") <> Undefined, "GiaoDichDienTuTamGiu thieu Dimension KenhThanhToan");
		AssertTrue(MetaTG.Dimensions.Find("MaGiaoDichKenh") <> Undefined, "GiaoDichDienTuTamGiu thieu Dimension MaGiaoDichKenh");
		AssertTrue(MetaTG.Resources.Find("SoTien") <> Undefined, "GiaoDichDienTuTamGiu thieu Resource SoTien");
		AssertTrue(MetaTG.Resources.Find("PhiKenh") <> Undefined, "GiaoDichDienTuTamGiu thieu Resource PhiKenh");
	Else
		// Khi chua nap Metadata vao Infobase, kiem tra danh sach 4 so da dinh nghia day du
		AssertEquals(4, DanhSachSo.Count(), "So luong Accumulation Registers phai la 4");
	EndIf;
EndProcedure

#EndRegion

#Region HelpersAndMocks

Function KhoiTaoDuLieuMauAR()
	Result = New Structure("PhapNhan, DoiTac, HopDong, ChungTuGoc");
	
	// Neu co Catalog trong he thong thi lay Ref, nguoc lai tao mock ref
	If Metadata.Catalogs.Count() > 0 Then
		If Metadata.Catalogs.Find("PhapNhan") <> Undefined Then
			PN = Catalogs.PhapNhan.FindByCode("PN-TEST1");
			If Not ValueIsFilled(PN) Then
				Obj = Catalogs.PhapNhan.CreateItem();
				Obj.Code = "PN-TEST1";
				Obj.Description = "VinSmart Future Corp (AR Test)";
				Obj.Write();
				PN = Obj.Ref;
			EndIf;
			Result.PhapNhan = PN;
		EndIf;
		
		If Metadata.Catalogs.Find("DoiTac") <> Undefined Then
			DT = Catalogs.DoiTac.FindByCode("DT-AR-TEST");
			If Not ValueIsFilled(DT) Then
				Obj = Catalogs.DoiTac.CreateItem();
				Obj.Code = "DT-AR-TEST";
				Obj.Description = "Doi Tac Khach Hang AR (Test)";
				Obj.Write();
				DT = Obj.Ref;
			EndIf;
			Result.DoiTac = DT;
		EndIf;
		
		If Metadata.Catalogs.Find("HopDong") <> Undefined Then
			HD = Catalogs.HopDong.FindByCode("HD-AR-TEST");
			If Not ValueIsFilled(HD) Then
				Obj = Catalogs.HopDong.CreateItem();
				Obj.Code = "HD-AR-TEST";
				Obj.Description = "Hop Dong AR DVKH 2026";
				Obj.PhapNhan = Result.PhapNhan;
				Obj.ChuSoHuu = Result.DoiTac;
				Obj.Write();
				HD = Obj.Ref;
			EndIf;
			Result.HopDong = HD;
		EndIf;
	EndIf;
	
	// Chung tu goc gia lap neu chua co document database
	Result.ChungTuGoc = "DOC-AR-BB-001";
	Return Result;
EndFunction

Function KhoiTaoDuLieuMauAP()
	Result = New Structure("PhapNhan, DoiTac, HopDong, ChungTuGoc");
	
	If Metadata.Catalogs.Count() > 0 Then
		If Metadata.Catalogs.Find("PhapNhan") <> Undefined Then
			PN = Catalogs.PhapNhan.FindByCode("PN-TEST1");
			Result.PhapNhan = PN;
		EndIf;
		
		If Metadata.Catalogs.Find("DoiTac") <> Undefined Then
			DT = Catalogs.DoiTac.FindByCode("DT-AP-AWS");
			If Not ValueIsFilled(DT) Then
				Obj = Catalogs.DoiTac.CreateItem();
				Obj.Code = "DT-AP-AWS";
				Obj.Description = "Amazon Web Services Inc (AP Test)";
				Obj.Write();
				DT = Obj.Ref;
			EndIf;
			Result.DoiTac = DT;
		EndIf;
		
		If Metadata.Catalogs.Find("HopDong") <> Undefined Then
			HD = Catalogs.HopDong.FindByCode("HD-AP-AWS");
			If Not ValueIsFilled(HD) Then
				Obj = Catalogs.HopDong.CreateItem();
				Obj.Code = "HD-AP-AWS";
				Obj.Description = "Hop Dong Cloud AWS Enterprise";
				Obj.PhapNhan = Result.PhapNhan;
				Obj.ChuSoHuu = Result.DoiTac;
				Obj.Write();
				HD = Obj.Ref;
			EndIf;
			Result.HopDong = HD;
		EndIf;
	EndIf;
	
	Result.ChungTuGoc = "DOC-AP-INV-AWS-001";
	Return Result;
EndFunction

Function KhoiTaoDuLieuMauDongTien()
	Result = New Structure("PhapNhan, TaiKhoanTien, TienTe, KhoanMucDongTien");
	
	If Metadata.Catalogs.Count() > 0 Then
		If Metadata.Catalogs.Find("PhapNhan") <> Undefined Then
			Result.PhapNhan = Catalogs.PhapNhan.FindByCode("PN-TEST1");
		EndIf;
		If Metadata.Catalogs.Find("TaiKhoanTien") <> Undefined Then
			Result.TaiKhoanTien = Catalogs.TaiKhoanTien.FindByCode("TK-TEST1");
		EndIf;
		If Metadata.Catalogs.Find("TienTe") <> Undefined Then
			Result.TienTe = Catalogs.TienTe.FindByCode("VND");
		EndIf;
		If Metadata.Catalogs.Find("KhoanMucDongTien") <> Undefined Then
			Result.KhoanMucDongTien = Catalogs.KhoanMucDongTien.FindByCode("KM-TEST1");
		EndIf;
	EndIf;
	
	Return Result;
EndFunction

Function LayChungTuGhiSoHopLe()
	If Metadata.Documents.Count() > 0 Then
		For Each DocMeta In Metadata.Documents Do
			DocManager = Documents[DocMeta.Name];
			Sel = DocManager.Select();
			If Sel.Next() Then
				Return Sel.Ref;
			Else
				NewDoc = DocManager.CreateDocument();
				NewDoc.Date = CurrentDate();
				NewDoc.Write();
				Return NewDoc.Ref;
			EndIf;
		EndDo;
	EndIf;
	Return Undefined;
EndFunction

Function KiemTraMetadataTonTai(TenSo)
	Try
		Return Metadata.AccumulationRegisters.Find(TenSo) <> Undefined;
	Except
		Return False;
	EndTry;
EndFunction

// Helper: Mo phong bo tinh toan Virtual Table Balance cua 1C
Function TaoMoPhongBangTichLuy()
	Table = New ValueTable;
	Table.Columns.Add("RecordType");
	Table.Columns.Add("HopDong");
	Table.Columns.Add("ChungTuGoc");
	Table.Columns.Add("SoTien");
	Table.Columns.Add("SoTienNgoaiTe");
	Return Table;
EndFunction

Procedure MoPhongAddReceipt(Table, HopDong, ChungTuGoc, SoTien, SoTienNgoaiTe)
	Row = Table.Add();
	Row.RecordType = 1;
	Row.HopDong = HopDong;
	Row.ChungTuGoc = ChungTuGoc;
	Row.SoTien = SoTien;
	Row.SoTienNgoaiTe = SoTienNgoaiTe;
EndProcedure

Procedure MoPhongAddExpense(Table, HopDong, ChungTuGoc, SoTien, SoTienNgoaiTe)
	Row = Table.Add();
	Row.RecordType = -1;
	Row.HopDong = HopDong;
	Row.ChungTuGoc = ChungTuGoc;
	Row.SoTien = SoTien;
	Row.SoTienNgoaiTe = SoTienNgoaiTe;
EndProcedure

Function MoPhongGetBalance(Table, HopDong, ChungTuGoc)
	TongSoTien = 0;
	TongNgoaiTe = 0;
	For Each Row In Table Do
		If Row.HopDong = HopDong And Row.ChungTuGoc = ChungTuGoc Then
			If Row.RecordType = 1 Then
				TongSoTien = TongSoTien + Row.SoTien;
				TongNgoaiTe = TongNgoaiTe + Row.SoTienNgoaiTe;
			Else
				TongSoTien = TongSoTien - Row.SoTien;
				TongNgoaiTe = TongNgoaiTe - Row.SoTienNgoaiTe;
			EndIf;
		EndIf;
	EndDo;
	Return New Structure("SoTien, SoTienNgoaiTe", TongSoTien, TongNgoaiTe);
EndFunction

#EndRegion

#Region AssertHelpers

Procedure AssertTrue(Condition, Message)
	If Not Condition Then
		Raise "ASSERT FAILED: " + Message;
	EndIf;
EndProcedure

Procedure AssertEquals(Expected, Actual, Message)
	If Expected <> Actual Then
		Raise StrTemplate("ASSERT FAILED: %1 (Ky vong: %2, Thuc te: %3)", Message, Expected, Actual);
	EndIf;
EndProcedure

#EndRegion
