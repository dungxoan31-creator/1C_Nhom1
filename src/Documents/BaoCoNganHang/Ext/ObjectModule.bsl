// Document: BaoCoNganHang
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Xu ly su kien ghi so (Posting) Bao co ngan hang, tu dong giam AR va tang DongTien (Task 5.1).

#Region EventHandlers

Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	If DataExchange.Load Then
		Return;
	EndIf;
	
	If Not ValueIsFilled(NgayGiaoDich) Then
		NgayGiaoDich = Date;
	EndIf;
	
	If Not ValueIsFilled(PhapNhan) Then
		PhapNhan = Catalogs.PhapNhan.FindByCode("VSF_CORP");
	EndIf;
	
	If Not ValueIsFilled(TaiKhoanTien) Then
		TaiKhoanTien = Catalogs.TaiKhoanTien.FindByCode("TK-TCB-VND");
	EndIf;
EndProcedure

Procedure Posting(Cancel, Mode)
	// Chi ghi so khi da xac dinh doi tac va du dieu kien ghi so
	If SoTien <= 0 Then
		Cancel = True;
		Raise "Số tiền báo có phải lớn hơn 0!";
	EndIf;
	
	// 1. Xac dinh tai khoan ke toan
	LaNoiBo = ?(ValueIsFilled(DoiTacKhop), DoiTacKhop.LaBenLienKet, False);
	MaTKCongNo = ?(LaNoiBo, "1312", "1311");
	TKCongNo = ChartsOfAccounts.HeThongTaiKhoan.FindByCode(MaTKCongNo);
	TKTien = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1121");
	
	// 2. Ghi So tich luy CongNoPhaiThu (Expense - Giam AR)
	RegisterRecords.CongNoPhaiThu.Write = True;
	RecordAR = RegisterRecords.CongNoPhaiThu.Add();
	RecordAR.RecordType = AccumulationRecordType.Expense;
	RecordAR.Period = Date;
	RecordAR.PhapNhan = PhapNhan;
	RecordAR.DoiTac = DoiTacKhop;
	RecordAR.ChungTuGoc = ChungTuKhop;
	RecordAR.SoTien = SoTien;
	RecordAR.SoTienNgoaiTe = 0;
	
	// 3. Ghi So tich luy DongTien (Receipt - Tang tien ngan hang)
	RegisterRecords.DongTien.Write = True;
	RecordDT = RegisterRecords.DongTien.Add();
	RecordDT.RecordType = AccumulationRecordType.Receipt;
	RecordDT.Period = Date;
	RecordDT.PhapNhan = PhapNhan;
	RecordDT.TaiKhoanTien = TaiKhoanTien;
	RecordDT.SoTien = SoTien;
	RecordDT.SoTienNgoaiTe = 0;
	
	// 4. Ghi So cai SoCaiKeToan (No 1121 / Co 1311 hoac 1312)
	RegisterRecords.SoCaiKeToan.Write = True;
	Row1 = RegisterRecords.SoCaiKeToan.Add();
	Row1.Period = Date;
	Row1.AccountDr = TKTien;
	Row1.AccountCr = TKCongNo;
	Row1.Amount = SoTien;
	Row1.Description = StrTemplate("Báo có ngân hàng tiền về - Mã GD %1", MaGiaoDichNganHang);
	Row1.PhapNhan = PhapNhan;
	Row1.DoiTac = DoiTacKhop;
	Row1.ChungTuGoc = ChungTuKhop;
	
	QuanLyVongDoiChungTuServer.KiemTraCanDoiSoCai(RegisterRecords.SoCaiKeToan);
EndProcedure

#EndRegion
