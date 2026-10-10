// Document: CanTruCongNoNoiBo
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Xu ly su kien ghi so chung tu can tru cong no noi bo (Task 6.1):
//           - Maker-Checker: Nguoi lap khong duoc tu duyet
//           - Chi ghi so khi TrangThai = "DaGhiSo" hoac "DaDuyet"
//           - Ghi giam no phai thu tren AccumulationRegister.CongNoPhaiThu (Expense)
//           - Ghi giam no phai tra tren AccumulationRegister.CongNoPhaiTra (Expense)
//           - Ghi so cai SoCaiKeToan:
//             + Truong hop truc tiep: No TK 3312 / Co TK 1312
//             + Truong hop bac cau da ben: No TK 3312 / Co TK 1388 va No TK 1388 / Co TK 1312
//           - Kiem tra Invariant can doi Delta = 0

#Region EventHandlers

Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	If DataExchange.Load Then
		Return;
	EndIf;
	
	// Kiem tra Maker-Checker: Chan tuyet doi nguoi lap tu duyet
	If ValueIsFilled(NguoiLap) And ValueIsFilled(NguoiDuyet) And NguoiLap = NguoiDuyet Then
		Cancel = True;
		Raise "CẤM TUYỆT ĐỐI: Người lập chứng từ cấn trừ không được phép tự phê duyệt!";
		Return;
	EndIf;
	
	If Not ValueIsFilled(TrangThai) Then
		TrangThai = "DuThao";
	EndIf;
EndProcedure

Procedure Posting(Cancel, Mode)
	// Chi ghi so khi da duyet hoac da ghi so
	If TrangThai <> "DaDuyet" And TrangThai <> "DaGhiSo" Then
		RegisterRecords.CongNoPhaiThu.Write = False;
		RegisterRecords.CongNoPhaiTra.Write = False;
		RegisterRecords.SoCaiKeToan.Write = False;
		Return;
	EndIf;
	
	// Kiem tra hop le
	If Not ValueIsFilled(PhapNhan) Then
		Cancel = True;
		Raise "Trường 'Pháp nhân' chưa được điền!";
		Return;
	EndIf;
	If Not ValueIsFilled(DoiTacNoiBo) Then
		Cancel = True;
		Raise "Trường 'Đối tác nội bộ' chưa được điền!";
		Return;
	EndIf;
	If SoTienCanTru <= 0 Then
		Cancel = True;
		Raise "Số tiền cấn trừ phải lớn hơn 0!";
		Return;
	EndIf;
	
	NgayHachToan = BegOfDay(Date);
	
	// 1. Ghi giam no phai thu tren CongNoPhaiThu (Expense)
	RegisterRecords.CongNoPhaiThu.Write = True;
	RecAR = RegisterRecords.CongNoPhaiThu.Add();
	RecAR.RecordType = AccumulationRecordType.Expense;
	RecAR.Period = NgayHachToan;
	RecAR.PhapNhan = PhapNhan;
	RecAR.DoiTac = DoiTacNoiBo;
	RecAR.HopDong = HopDongAR;
	RecAR.SoTien = SoTienCanTru;
	
	// 2. Ghi giam no phai tra tren CongNoPhaiTra (Expense)
	RegisterRecords.CongNoPhaiTra.Write = True;
	RecAP = RegisterRecords.CongNoPhaiTra.Add();
	RecAP.RecordType = AccumulationRecordType.Expense;
	RecAP.Period = NgayHachToan;
	RecAP.PhapNhan = PhapNhan;
	RecAP.DoiTac = DoiTacNoiBo;
	RecAP.HopDong = HopDongAP;
	RecAP.SoTien = SoTienCanTru;
	
	// 3. Ghi so cai SoCaiKeToan
	RegisterRecords.SoCaiKeToan.Write = True;
	
	TK3312 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("3312");
	TK1312 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1312");
	TK1388 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1388");
	
	If LaCanTruBacCau Then
		// Can tru bac cau da ben qua TK 1388
		// But toan 1: Giam AP: No 3312 / Co 1388
		Row1 = RegisterRecords.SoCaiKeToan.Add();
		Row1.Period = NgayHachToan;
		Row1.AccountDr = TK3312;
		Row1.AccountCr = TK1388;
		Row1.Amount = SoTienCanTru;
		Row1.Description = StrTemplate("Cấn trừ nợ phải trả nội bộ qua TK trung gian theo lệnh %1", Number);
		Row1.PhapNhan = PhapNhan;
		Row1.DoiTac = DoiTacNoiBo;
		Row1.HopDong = HopDongAP;
		
		// But toan 2: Giam AR: No 1388 / Co 1312
		Row2 = RegisterRecords.SoCaiKeToan.Add();
		Row2.Period = NgayHachToan;
		Row2.AccountDr = TK1388;
		Row2.AccountCr = TK1312;
		Row2.Amount = SoTienCanTru;
		Row2.Description = StrTemplate("Cấn trừ nợ phải thu nội bộ qua TK trung gian theo lệnh %1", Number);
		Row2.PhapNhan = PhapNhan;
		Row2.DoiTac = DoiTacNoiBo;
		Row2.HopDong = HopDongAR;
	Else
		// Can tru tay doi truc tiep: No TK 3312 / Co TK 1312
		Row1 = RegisterRecords.SoCaiKeToan.Add();
		Row1.Period = NgayHachToan;
		Row1.AccountDr = TK3312;
		Row1.AccountCr = TK1312;
		Row1.Amount = SoTienCanTru;
		Row1.Description = StrTemplate("Cấn trừ công nợ nội bộ 2 bên theo chứng từ %1", Number);
		Row1.PhapNhan = PhapNhan;
		Row1.DoiTac = DoiTacNoiBo;
	EndIf;
	
	// Invariant Check
	QuanLyVongDoiChungTuServer.KiemTraCanDoiSoCai(RegisterRecords.SoCaiKeToan);
	
	TrangThai = "DaGhiSo";
EndProcedure

#EndRegion
