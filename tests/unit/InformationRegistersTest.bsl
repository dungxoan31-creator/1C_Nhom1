// Unit Test Suite: InformationRegistersTest
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL / BUnit / Vanessa)
// Muc tieu: Kiem thu 3 So Thong Tin (Information Registers):
//   1. InformationRegister.TyGiaHoiDoai (Periodic: Day)
//   2. InformationRegister.KeHoachChiTien (4 chieu: Thang, DuAn, KhoanMucDongTien, PhapNhan)
//   4. InformationRegister.HanMucVaChanXuatDichVu (PhapNhan, DoiTac, HopDong)

#Region TestExecution

Function RunAllTests() Export
	TestResults = New Structure;
	TestResults.Insert("Total", 3);
	TestResults.Insert("Passed", 0);
	TestResults.Insert("Failed", 0);
	TestResults.Insert("Log", New Array);
	
	TestLog = TestResults.Log;
	TestLog.Add("=================================================================");
	TestLog.Add("   VINSMART FUTURE - INFORMATION REGISTERS UNIT TEST (TASK 2.2)  ");
	TestLog.Add("   Thoi gian chay: " + CurrentDate());
	TestLog.Add("=================================================================");
	
	// Test 1: Ghi nhan ty gia hoi doai USD theo ngay tren TyGiaHoiDoai
	Try
		Test01_GhiNhanTyGiaHoiDoaiUSDTheoNgay();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 1: Ghi nhan ty gia hoi doai USD theo ngay (Day periodicity) thanh cong.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 1: Ghi nhan ty gia hoi doai that bai - " + ErrorDescription());
	EndTry;
	
	// Test 2: Ghi nhan ngan sach 4 chieu chi tieu KeHoachChiTien
	Try
		Test02_GhiNhanNganSachChiTien4Chieu();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 2: Ghi nhan ngan sach 4 chieu chi tieu tren KeHoachChiTien thanh cong.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 2: Ghi nhan ngan sach KeHoachChiTien that bai - " + ErrorDescription());
	EndTry;
	
	// Test 4: Han muc va chan xuat dich vu (HanMucVaChanXuatDichVu)
	Try
		Test04_HanMucVaChanXuatDichVu();
		TestResults.Passed = TestResults.Passed + 1;
		TestLog.Add("[PASS] Test 4: Ghi nhan han muc cong no va chan xuat dich vu thanh cong.");
	Except
		TestResults.Failed = TestResults.Failed + 1;
		TestLog.Add("[FAIL] Test 4: Han muc va chan xuat dich vu that bai - " + ErrorDescription());
	EndTry;
	
	TestLog.Add("-----------------------------------------------------------------");
	TestLog.Add(StrTemplate("Tong so test: %1 | Thanh cong: %2 | That bai: %3", 
		TestResults.Total, TestResults.Passed, TestResults.Failed));
	TestLog.Add("=================================================================");
	
	Return TestResults;
EndFunction

#EndRegion

#Region TestCases

// Test 1: Ghi nhan ty gia hoi doai USD theo ngay tren InformationRegister.TyGiaHoiDoai
Procedure Test01_GhiNhanTyGiaHoiDoaiUSDTheoNgay() Export
	// 1. Chuan bi tien te USD
	RefUSD = LayHoacTaoTienTe("USD", "Do la My");
	
	NgayTyGia = Date(2026, 10, 10, 0, 0, 0);
	TyGiaMuaChuan = 25200.0000;
	TyGiaBanChuan = 25500.0000;
	TyGiaHachToanChuan = 25350.0000;
	
	// 2. Ghi nhan ban ghi ty gia
	RecordMgr = InformationRegisters.TyGiaHoiDoai.CreateRecordManager();
	RecordMgr.Period = NgayTyGia;
	RecordMgr.TienTe = RefUSD;
	RecordMgr.TyGiaMua = TyGiaMuaChuan;
	RecordMgr.TyGiaBan = TyGiaBanChuan;
	RecordMgr.TyGiaHachToan = TyGiaHachToanChuan;
	RecordMgr.Write(True); // Replace existing
	
	// 3. Doc lai ban ghi bang RecordKey
	KeyStructure = New Structure;
	KeyStructure.Insert("Period", NgayTyGia);
	KeyStructure.Insert("TienTe", RefUSD);
	RecordKey = InformationRegisters.TyGiaHoiDoai.CreateRecordKey(KeyStructure);
	
	ReadMgr = InformationRegisters.TyGiaHoiDoai.CreateRecordManager();
	ReadMgr.Period = NgayTyGia;
	ReadMgr.TienTe = RefUSD;
	ReadMgr.Read();
	
	AssertTrue(ReadMgr.Selected(), "Ban ghi TyGiaHoiDoai phai ton tai sau khi ghi");
	AssertEquals(TyGiaMuaChuan, ReadMgr.TyGiaMua, "Ty gia mua phai khop gia tri 25200");
	AssertEquals(TyGiaBanChuan, ReadMgr.TyGiaBan, "Ty gia ban phai khop gia tri 25500");
	AssertEquals(TyGiaHachToanChuan, ReadMgr.TyGiaHachToan, "Ty gia hach toan phai khop gia tri 25350");
	
	// 4. Kiem tra bang ao GetLast (SliceLast) vao ngay tiep theo
	NgayHomSau = Date(2026, 10, 11, 12, 0, 0);
	FilterStructure = New Structure("TienTe", RefUSD);
	SliceLastResult = InformationRegisters.TyGiaHoiDoai.GetLast(NgayHomSau, FilterStructure);
	
	AssertEquals(TyGiaHachToanChuan, SliceLastResult.TyGiaHachToan, 
		"SliceLast vao ngay tiep theo phai lay dung ty gia hach toan hieu luc gan nhat");
EndProcedure

// Test 2: Ghi nhan ngan sach 4 chieu chi tieu tren InformationRegister.KeHoachChiTien
Procedure Test02_GhiNhanNganSachChiTien4Chieu() Export
	// 1. Chuan bi 4 dimensions
	NgayThang = BegOfMonth(Date(2026, 10, 15));
	RefDuAn = LayHoacTaoDuAn("DA-ERP-CLOUD", "Trien khai ERP Cloud VinSmart");
	RefKhoanMuc = LayHoacTaoKhoanMucDongTien("KM-HA-CLOUD", "Chi phi thue Cloud ha tang");
	RefPhapNhan = LayHoacTaoPhapNhan("PN-VSF-CORP", "Cong ty Co phan VinSmart Future");
	
	NganSach = 1000000000.00; // 1 ty VND
	DaDuyet = 350000000.00;   // 350 trieu VND
	ThucChi = 200000000.00;   // 200 trieu VND
	
	// 2. Ghi vao KeHoachChiTien qua RecordManager
	RecordMgr = InformationRegisters.KeHoachChiTien.CreateRecordManager();
	RecordMgr.Thang = NgayThang;
	RecordMgr.DuAn = RefDuAn;
	RecordMgr.KhoanMucDongTien = RefKhoanMuc;
	RecordMgr.PhapNhan = RefPhapNhan;
	RecordMgr.SoTienNganSach = NganSach;
	RecordMgr.SoTienDaDuyet = DaDuyet;
	RecordMgr.SoTienThucChi = ThucChi;
	RecordMgr.Write(True);
	
	// 3. Doc lai ban ghi
	ReadMgr = InformationRegisters.KeHoachChiTien.CreateRecordManager();
	ReadMgr.Thang = NgayThang;
	ReadMgr.DuAn = RefDuAn;
	ReadMgr.KhoanMucDongTien = RefKhoanMuc;
	ReadMgr.PhapNhan = RefPhapNhan;
	ReadMgr.Read();
	
	AssertTrue(ReadMgr.Selected(), "Ban ghi KeHoachChiTien 4 chieu phai ton tai");
	AssertEquals(NganSach, ReadMgr.SoTienNganSach, "SoTienNganSach phai khop 1,000,000,000");
	AssertEquals(DaDuyet, ReadMgr.SoTienDaDuyet, "SoTienDaDuyet phai khop 350,000,000");
	AssertEquals(ThucChi, ReadMgr.SoTienThucChi, "SoTienThucChi phai khop 200,000,000");
	
	// 4. Kiem tra cach ly chieu PhapNhan khac
	RefPhapNhanKhac = LayHoacTaoPhapNhan("PN-VSF-SOFT", "Cong ty Phan Mem VinSmart Future");
	ReadMgrKhac = InformationRegisters.KeHoachChiTien.CreateRecordManager();
	ReadMgrKhac.Thang = NgayThang;
	ReadMgrKhac.DuAn = RefDuAn;
	ReadMgrKhac.KhoanMucDongTien = RefKhoanMuc;
	ReadMgrKhac.PhapNhan = RefPhapNhanKhac;
	ReadMgrKhac.Read();
	AssertFalse(ReadMgrKhac.Selected(), "Khong the ton tai ban ghi tren PhapNhan khac khi chua tao");
EndProcedure

// Test 4: Han muc va chan xuat dich vu (InformationRegister.HanMucVaChanXuatDichVu)
Procedure Test04_HanMucVaChanXuatDichVu() Export
	RefPN = LayHoacTaoPhapNhan("PN-VSF-04", "VinSmart Future Corp 04");
	RefDT = LayHoacTaoDoiTac("DT-VSF-04", "Doi Tac 04");
	RefHD = LayHoacTaoHopDong("HD-VSF-04", RefPN, RefDT);
	
	HanMuc = 500000000.00;
	TrangThaiKhoa = True;
	LyDoKhoa = "Vuot han muc cong no cho phep";
	
	// Ghi ban ghi
	RecordMgr = InformationRegisters.HanMucVaChanXuatDichVu.CreateRecordManager();
	RecordMgr.PhapNhan = RefPN;
	RecordMgr.DoiTac = RefDT;
	RecordMgr.HopDong = RefHD;
	RecordMgr.HanMucCongNo = HanMuc;
	RecordMgr.TrangThaiKhoa = TrangThaiKhoa;
	RecordMgr.LyDoKhoa = LyDoKhoa;
	RecordMgr.Write(True);
	
	// Doc lai
	ReadMgr = InformationRegisters.HanMucVaChanXuatDichVu.CreateRecordManager();
	ReadMgr.PhapNhan = RefPN;
	ReadMgr.DoiTac = RefDT;
	ReadMgr.HopDong = RefHD;
	ReadMgr.Read();
	
	AssertTrue(ReadMgr.Selected(), "Ban ghi HanMucVaChanXuatDichVu phai ton tai");
	AssertEquals(HanMuc, ReadMgr.HanMucCongNo, "Han muc cong no phai la 500,000,000");
	AssertEquals(True, ReadMgr.TrangThaiKhoa, "Trang thai khoa phai la True");
	AssertEquals(LyDoKhoa, ReadMgr.LyDoKhoa, "Ly do khoa phai khop");
	
	// Test Operational Safety Gate: Cam khoa dich vu doi voi Doi tac lien quan
	RefDTLienQuan = LayHoacTaoDoiTac("DT-VINFAST-LQ", "VinFast Auto Ltd - Ben lien quan");
	ObjDTLQ = RefDTLienQuan.GetObject();
	ObjDTLQ.LaBenLienKet = True;
	ObjDTLQ.Write();
	
	RefHDLQ = LayHoacTaoHopDong("HD-VINFAST-LQ", RefPN, RefDTLienQuan);
	
	RecordMgrLQ = InformationRegisters.HanMucVaChanXuatDichVu.CreateRecordManager();
	RecordMgrLQ.PhapNhan = RefPN;
	RecordMgrLQ.DoiTac = RefDTLienQuan;
	RecordMgrLQ.HopDong = RefHDLQ;
	RecordMgrLQ.HanMucCongNo = 1000000000.00;
	RecordMgrLQ.TrangThaiKhoa = True; // Co y khoa dich vu ben lien quan -> phai bi chan
	RecordMgrLQ.LyDoKhoa = "Thu nghiem khoa ben lien quan";
	
	DaBatLoi = False;
	Try
		RecordMgrLQ.Write(True);
	Except
		DaBatLoi = True;
	EndTry;
	AssertTrue(DaBatLoi, "Operational Safety Gate phai chan khong cho khoa dich vu ben lien quan (LaBenLienKet = True)");
EndProcedure


#EndRegion

#Region HelperFunctions

Function LayHoacTaoTienTe(Code, Description)
	Found = Catalogs.TienTe.FindByCode(Code);
	If ValueIsFilled(Found) Then
		Return Found;
	EndIf;
	Obj = Catalogs.TienTe.CreateItem();
	Obj.Code = Code;
	Obj.Description = Description;
	Obj.Write();
	Return Obj.Ref;
EndFunction

Function LayHoacTaoDuAn(Code, Description)
	Found = Catalogs.DuAn.FindByCode(Code);
	If ValueIsFilled(Found) Then
		Return Found;
	EndIf;
	Obj = Catalogs.DuAn.CreateItem();
	Obj.Code = Code;
	Obj.Description = Description;
	Obj.Write();
	Return Obj.Ref;
EndFunction

Function LayHoacTaoKhoanMucDongTien(Code, Description)
	Found = Catalogs.KhoanMucDongTien.FindByCode(Code);
	If ValueIsFilled(Found) Then
		Return Found;
	EndIf;
	Obj = Catalogs.KhoanMucDongTien.CreateItem();
	Obj.Code = Code;
	Obj.Description = Description;
	Obj.Write();
	Return Obj.Ref;
EndFunction

Function LayHoacTaoPhapNhan(Code, Description)
	Found = Catalogs.PhapNhan.FindByCode(Code);
	If ValueIsFilled(Found) Then
		Return Found;
	EndIf;
	Obj = Catalogs.PhapNhan.CreateItem();
	Obj.Code = Code;
	Obj.Description = Description;
	Obj.Write();
	Return Obj.Ref;
EndFunction

Function LayHoacTaoDoiTac(Code, Description)
	Found = Catalogs.DoiTac.FindByCode(Code);
	If ValueIsFilled(Found) Then
		Return Found;
	EndIf;
	Obj = Catalogs.DoiTac.CreateItem();
	Obj.Code = Code;
	Obj.Description = Description;
	Obj.Write();
	Return Obj.Ref;
EndFunction

Function LayHoacTaoHopDong(Code, RefPN, RefDT)
	Found = Catalogs.HopDong.FindByCode(Code);
	If ValueIsFilled(Found) Then
		Return Found;
	EndIf;
	Obj = Catalogs.HopDong.CreateItem();
	Obj.Code = Code;
	Obj.Description = "Hop dong " + Code;
	Obj.PhapNhan = RefPN;
	Obj.ChuSoHuu = RefDT;
	Obj.HanThanhToanNgay = 30;
	Obj.Write();
	Return Obj.Ref;
EndFunction

#EndRegion

#Region AssertHelpers

Procedure AssertTrue(Condition, Message)
	If Not Condition Then
		Raise "ASSERT FAILED: " + Message;
	EndIf;
EndProcedure

Procedure AssertFalse(Condition, Message)
	If Condition Then
		Raise "ASSERT FAILED: " + Message;
	EndIf;
EndProcedure

Procedure AssertEquals(Expected, Actual, Message)
	If Expected <> Actual Then
		Raise StrTemplate("ASSERT FAILED: %1 (Ky vong: %2, Thuc te: %3)", Message, Expected, Actual);
	EndIf;
EndProcedure

#EndRegion
