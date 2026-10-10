// Report: BaoCaoTuoiNoPhanTachNoiBo
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Phan tich tuoi no AR/AP va ap dung Operational Safety Gate (Task 6.2):
//           - Tinh toan tuoi no theo DueDate: TrongHan, 1-30, 31-60, >60 ngay
//           - Operational Safety Gate: Khach ngoai qua han > 60 ngay -> DeXuatKhoaDichVu
//           - Doi tac noi bo Vingroup qua han: CAM TUYET DOI tu dong ngat API/Cloud, chuyen sang CanhBaoCFOVaNetting

#Region PublicInterface

// Ham xac dinh nhom tuoi no theo so ngay qua han
Function LayNhomTuoiNo(Val SoNgayQuaHan) Export
	If SoNgayQuaHan <= 0 Then
		Return "TrongHan";
	ElsIf SoNgayQuaHan <= 30 Then
		Return "QuaHan1_30";
	ElsIf SoNgayQuaHan <= 60 Then
		Return "QuaHan31_60";
	Else
		Return "QuaHanTren60";
	EndIf;
EndFunction

// Xu ly kiem tra Operational Safety Gate
Function KiemTraOperationalSafetyGate(Val LaBenLienKet, Val SoNgayQuaHan) Export
	KetQua = New Structure;
	KetQua.Insert("DeXuatKhoaDichVu", False);
	KetQua.Insert("CamKhoaDichVu", False);
	KetQua.Insert("TrangThaiXuLy", "BinhThuong");
	
	If LaBenLienKet Then
		// OPERATIONAL SAFETY GATE: Cam tuyet doi tu dong khoa dich vu doi tac noi bo Vingroup
		KetQua.CamKhoaDichVu = True;
		KetQua.DeXuatKhoaDichVu = False;
		If SoNgayQuaHan > 60 Then
			KetQua.TrangThaiXuLy = "CanhBaoCFOVaNetting";
		ElsIf SoNgayQuaHan > 0 Then
			KetQua.TrangThaiXuLy = "DoiChieuNoiBo";
		EndIf;
	Else
		// Khach hang ngoai tap doan
		If SoNgayQuaHan > 60 Then
			KetQua.DeXuatKhoaDichVu = True;
			KetQua.TrangThaiXuLy = "KhoaDichVuAPI";
		ElsIf SoNgayQuaHan > 30 Then
			KetQua.TrangThaiXuLy = "NhacNo";
		ElsIf SoNgayQuaHan > 0 Then
			KetQua.TrangThaiXuLy = "CanhBaoSom";
		EndIf;
	EndIf;
	
	Return KetQua;
EndFunction

// Phan tich va tinh tong du no theo tung bucket
Function PhanTichTuoiNoDanhSach(DanhSachKhoanNo) Export
	KetQua = New Structure;
	KetQua.Insert("TongTrongHan", 0);
	KetQua.Insert("TongQuaHan1_30", 0);
	KetQua.Insert("TongQuaHan31_60", 0);
	KetQua.Insert("TongQuaHanTren60", 0);
	KetQua.Insert("TongDuNo", 0);
	
	For Each Row In DanhSachKhoanNo Do
		Nhom = LayNhomTuoiNo(Row.NgayQuaHan);
		If Nhom = "TrongHan" Then
			KetQua.TongTrongHan = KetQua.TongTrongHan + Row.SoTien;
		ElsIf Nhom = "QuaHan1_30" Then
			KetQua.TongQuaHan1_30 = KetQua.TongQuaHan1_30 + Row.SoTien;
		ElsIf Nhom = "QuaHan31_60" Then
			KetQua.TongQuaHan31_60 = KetQua.TongQuaHan31_60 + Row.SoTien;
		ElsIf Nhom = "QuaHanTren60" Then
			KetQua.TongQuaHanTren60 = KetQua.TongQuaHanTren60 + Row.SoTien;
		EndIf;
	EndDo;
	
	KetQua.TongDuNo = KetQua.TongTrongHan + KetQua.TongQuaHan1_30 + KetQua.TongQuaHan31_60 + KetQua.TongQuaHanTren60;
	Return KetQua;
EndFunction

#EndRegion
