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
	NgayThucHien = ?(ValueIsFilled(NgayChot), NgayChot, CurrentSessionDate());
	WriteLogEvent("NapSoDuDauKy.AR", EventLogLevel.Information,,, 
		StrTemplate("Nạp số dư AR: Pháp nhân %1, Đối tác %2, Hợp đồng %3, Số tiền %4 tại ngày %5", 
			PhapNhan, DoiTac, HopDong, SoTien, NgayThucHien));
EndProcedure

Procedure NapSoDuAP(Val PhapNhan, Val DoiTac, Val HopDong, Val SoTien, Val NgayChot) Export
	NgayThucHien = ?(ValueIsFilled(NgayChot), NgayChot, CurrentSessionDate());
	WriteLogEvent("NapSoDuDauKy.AP", EventLogLevel.Information,,, 
		StrTemplate("Nạp số dư AP: Pháp nhân %1, Đối tác %2, Hợp đồng %3, Số tiền %4 tại ngày %5", 
			PhapNhan, DoiTac, HopDong, SoTien, NgayThucHien));
EndProcedure

Procedure NapSoDuDongTien(Val PhapNhan, Val TaiKhoanTien, Val TienTe, Val SoTienVND, Val SoTienNgoaiTe, Val NgayChot) Export
	NgayThucHien = ?(ValueIsFilled(NgayChot), NgayChot, CurrentSessionDate());
	WriteLogEvent("NapSoDuDauKy.DongTien", EventLogLevel.Information,,, 
		StrTemplate("Nạp số dư Dòng tiền: Pháp nhân %1, TK Tiền %2, Tiền tệ %3, Số tiền VND %4, Ngoại tệ %5 tại ngày %6", 
			PhapNhan, TaiKhoanTien, TienTe, SoTienVND, SoTienNgoaiTe, NgayThucHien));
EndProcedure

#EndRegion
