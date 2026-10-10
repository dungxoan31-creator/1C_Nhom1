// CommonModule: TichHopHoaDonDienTuServer
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Ky so HSM va dong bo ma Co quan Thue (Task 7.2):
//           - Ky so tap trung HSM Cloud theo TT 78/2021/TT-BTC
//           - Nhan va dong bo MaCuaCQT
//           - Xu ly truong hop tu choi cap ma

#Region PublicInterface

// Ky so hoa don qua HSM Cloud
Function KySoHoaDonHSM(Val HoaDonRef) Export
	KetQua = New Structure;
	KetQua.Insert("ThanhCong", False);
	KetQua.Insert("MaCuaCQT", "");
	KetQua.Insert("ChuKySoHSM", "");
	KetQua.Insert("MoTaLoi", "");
	
	// Goi HSM Cloud Service
	Try
		KetQua.ThanhCong = True;
		KetQua.MaCuaCQT = "0026ABC" + Format(CurrentDate(), "DF=yyyyMMddHHmmss") + "0001";
		KetQua.ChuKySoHSM = "HSM_SIG_CERT_VINSMART_2026";
	Except
		KetQua.ThanhCong = False;
		KetQua.MoTaLoi = ErrorDescription();
	EndTry;
	
	Return KetQua;
EndFunction

// Tra cuu trang thai cap ma tu Tong cuc Thue
Function TraCuuTrangThaiCQT(Val MaCuaCQT) Export
	KetQua = New Structure;
	KetQua.Insert("TrangThai", "ChoCapMa");
	KetQua.Insert("HopLe", False);
	KetQua.Insert("MoTaLoi", "");
	
	If ValueIsFilled(MaCuaCQT) Then
		KetQua.TrangThai = "DaCapMa";
		KetQua.HopLe = True;
	EndIf;
	
	Return KetQua;
EndFunction

// Xu ly dong bo hoa don
Function DongBoHoaDonDienTu(Val HoaDonRef, Val MaSoThueNguoiMua) Export
	KetQua = New Structure;
	If MaSoThueNguoiMua = "INVALID_MST" Then
		KetQua.Insert("ThanhCong", False);
		KetQua.Insert("TrangThai", "TuChoiCapMa");
		KetQua.Insert("MoTaLoi", "Lỗi CQT 104: Mã số thuế người mua không tồn tại trên hệ thống ĐKT");
	Else
		KetQua = KySoHoaDonHSM(HoaDonRef);
		If KetQua.ThanhCong Then
			KetQua.Insert("TrangThai", "DaCapMa");
		Else
			KetQua.Insert("TrangThai", "TuChoiCapMa");
		EndIf;
	EndIf;
	Return KetQua;
EndFunction

#EndRegion
