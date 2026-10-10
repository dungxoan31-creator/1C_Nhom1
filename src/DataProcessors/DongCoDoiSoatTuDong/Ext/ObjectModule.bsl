// DataProcessor: DongCoDoiSoatTuDong
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Xu ly doi soat hoa don Tang 2 (Fuzzy & Dung sai) va Tang 3 (Treo dich danh) (Task 5.2):
//           - Dung sai khach ngoai <= 1.000 VND (hach toan vao TK 711 hoac 635)
//           - Dung sai doi tac noi bo Vingroup TUYET DOI BANG 0 (khong lech du chi 1 dong)

#Region PublicInterface

// Thuc hien doi soat Tang 2
Function ThucHienDoiSoatTang2(Val SoTienNhan, Val SoTienHoaDon, Val LaBenLienKet = False) Export
	ChenhLech = Abs(SoTienNhan - SoTienHoaDon);
	
	KetQua = New Structure;
	KetQua.Insert("ThanhCong", False);
	KetQua.Insert("TrangThai", "ChoDoiSoat");
	KetQua.Insert("ChenhLech", ChenhLech);
	KetQua.Insert("TaiKhoanChenhLech", "");
	
	If LaBenLienKet Then
		// DUNG SAI NOI BO TUYET DOI BANG 0
		If ChenhLech = 0 Then
			KetQua.ThanhCong = True;
			KetQua.TrangThai = "DaDoiSoat";
		Else
			// Bất kỳ chênh lệch nào của nội bộ đều bị đẩy sang Tầng 3
			KetQua.ThanhCong = False;
			KetQua.TrangThai = "ChuyenTang3";
		EndIf;
	Else
		// Khach hang ngoai: Dung sai <= 1.000 VND
		DungSaiToiDa = 1000;
		If ChenhLech <= DungSaiToiDa Then
			KetQua.ThanhCong = True;
			KetQua.TrangThai = "DaDoiSoat";
			If ChenhLech > 0 Then
				KetQua.TaiKhoanChenhLech = ?(SoTienNhan > SoTienHoaDon, "711", "635");
			EndIf;
		Else
			// Lech tren 1.000 VND -> Chuyen sang Tang 3 nghi van
			KetQua.ThanhCong = False;
			KetQua.TrangThai = "NghiVanLechDoiSoat";
		EndIf;
	EndIf;
	
	Return KetQua;
EndFunction

// Thuc hien xu ly Tang 3: Treo co dich danh doi tac
Function ThucHienDoiSoatTang3(Val DoiTac, Val SoTien, Val LaBenLienKet = True) Export
	KetQua = New Structure;
	KetQua.Insert("TrangThai", "NghiVanLechDoiSoat");
	KetQua.Insert("TaiKhoanTreo", ?(LaBenLienKet, "1312", "1311"));
	KetQua.Insert("DoiTac", DoiTac);
	KetQua.Insert("SoTien", SoTien);
	KetQua.Insert("YeuCauDuyetThuCong", True);
	
	Return KetQua;
EndFunction

#EndRegion
