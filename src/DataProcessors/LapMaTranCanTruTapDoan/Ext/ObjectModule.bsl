// DataProcessor: LapMaTranCanTruTapDoan
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Dong co bu tru cong no noi bo da ben & Watchdog Timeout (Task 6.1):
//           - Quet no phai thu va phai tra giua cac don vi noi bo Vingroup
//           - Tinh toan cap can tru (Bilateral) hoac ma tran da ben (Multilateral)
//           - Danh dau trang thai ChoCanTru va luu TrangThaiTruocDo
//           - Watchdog 120 phut: Tuyet doi khong giu lock DB; Tu dong hoan nguyen neu qua han

#Region PublicInterface

// Tinh toan can tru tay doi giua 2 phap nhan
Function TinhCanTruTayDoi(Val NoPhaiThu, Val NoPhaiTra) Export
	KetQua = New Structure;
	KetQua.Insert("SoTienCanTru", Min(NoPhaiThu, NoPhaiTra));
	KetQua.Insert("NoPhaiThuConLai", NoPhaiThu - KetQua.SoTienCanTru);
	KetQua.Insert("NoPhaiTraConLai", NoPhaiTra - KetQua.SoTienCanTru);
	Return KetQua;
EndFunction

// Watchdog Timeout: Quet va giai phong cac chung tu qua han 120 phut
// Tuyet doi khong giu DB locks
Function XuLyWatchdogTimeout(DanhSachChungTuKhoa, Val TimeoutPhut = 120) Export
	SoChungTuGiaiPhong = 0;
	ThoiDiemHienTai = CurrentSessionDate();
	
	For Each Item In DanhSachChungTuKhoa Do
		SoPhutDaTroiQua = (ThoiDiemHienTai - Item.ThoiDiemKhoa) / 60;
		If SoPhutDaTroiQua > TimeoutPhut Then
			// Hoan nguyen trang thai
			Item.TrangThai = Item.TrangThaiTruocDo;
			SoChungTuGiaiPhong = SoChungTuGiaiPhong + 1;
		EndIf;
	EndDo;
	
	Return SoChungTuGiaiPhong;
EndFunction

#EndRegion
