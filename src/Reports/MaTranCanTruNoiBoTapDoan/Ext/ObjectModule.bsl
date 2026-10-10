// Report: MaTranCanTruNoiBoTapDoan
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Truc quan hoa ma tran bu tru cong no noi bo da ben (Task 6.3)

#Region PublicInterface

Function TinhMaTranBuTru(DanhSachDoiTac, DanhSachAR, DanhSachAP) Export
	KetQua = New Structure;
	KetQua.Insert("TongCanTru", 0);
	KetQua.Insert("ChiTietCanTru", New Array);
	
	// Tinh tong can tru can bang giua cac don vi
	TongAR = 0;
	TongAP = 0;
	For Each Item In DanhSachAR Do
		TongAR = TongAR + Item.SoTien;
	EndDo;
	For Each Item In DanhSachAP Do
		TongAP = TongAP + Item.SoTien;
	EndDo;
	
	KetQua.TongCanTru = Min(TongAR, TongAP);
	Return KetQua;
EndFunction

#EndRegion
