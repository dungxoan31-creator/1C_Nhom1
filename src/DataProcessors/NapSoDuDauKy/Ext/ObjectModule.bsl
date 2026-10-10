// DataProcessor: NapSoDuDauKy
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Nap so du dau ky AR, AP va DongTien (Task 8.1):
//           - Nap AccumulationRegister.CongNoPhaiThu va GL TK 1311/1312
//           - Nap AccumulationRegister.CongNoPhaiTra va GL TK 3311/3312
//           - Nap AccumulationRegister.DongTien song te VND va Ngoai te & GL TK 1121/1122
//           - Doi ung TK 000, dam bao can doi Delta = 0

#Region PublicInterface

Procedure NapSoDuAR(Val PhapNhan, Val DoiTac, Val HopDong, Val SoTien, Val NgayChot) Export
	// Subledger AR: Receipt
	RecordAR = AccumulationRegisters.CongNoPhaiThu.CreateRecordSet();
	// Nap so du Subledger
	
	// SoCaiKeToan: No TK 1312 (hoac 1311) / Co TK 000
EndProcedure

Procedure NapSoDuAP(Val PhapNhan, Val DoiTac, Val HopDong, Val SoTien, Val NgayChot) Export
	// Subledger AP: Receipt
	RecordAP = AccumulationRegisters.CongNoPhaiTra.CreateRecordSet();
	
	// SoCaiKeToan: No TK 000 / Co TK 3311 (hoac 3312)
EndProcedure

Procedure NapSoDuDongTien(Val PhapNhan, Val TaiKhoanTien, Val TienTe, Val SoTienVND, Val SoTienNgoaiTe, Val NgayChot) Export
	// Subledger DongTien: Receipt dual currency
EndProcedure

#EndRegion
