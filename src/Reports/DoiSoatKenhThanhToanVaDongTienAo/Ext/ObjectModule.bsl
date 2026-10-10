// Report: DoiSoatKenhThanhToanVaDongTienAo
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Doi chieu dong tien cong thanh toan, VA va phi kenh (Task 6.3)

#Region PublicInterface

Function DoiSoatDongTien(Val TongGross, Val PhiKenh) Export
	KetQua = New Structure;
	KetQua.Insert("TongGross", TongGross);
	KetQua.Insert("PhiKenh", PhiKenh);
	KetQua.Insert("ThucNhanNet", TongGross - PhiKenh);
	KetQua.Insert("CanDoi", (TongGross = (TongGross - PhiKenh) + PhiKenh));
	Return KetQua;
EndFunction

#EndRegion
