// Common Module: QuyTrinhPheDuyetAPServer
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Xu ly luong chuyen trang thai 4+1 cap AP, nhanh CFO unlock va Maker-Checker (Task 4.2).

#Region PublicInterface

// Xac dinh trang thai tiep theo trong luong phe duyet AP 4+1 cap
//
// Tham so:
//   TrangThaiHienTai - String, EnumRef.TrangThaiHoaDonAP - Trang thai hien tai cua chung tu
//   VuotNganSach     - Boolean                          - True neu chi tieu vuot ngan sach > 10%
//
// Gia tri tra ve:
//   String - Ten trang thai tiep theo
Function XacDinhTrangThaiTiepTheo(Val TrangThaiHienTai, Val VuotNganSach = False) Export
	TrangThaiStr = TrimAll(String(TrangThaiHienTai));
	
	If TrangThaiStr = "DuThao" Or TrangThaiStr = "Dự thảo" Then
		Return "ChoDuyetKyThuat";
		
	ElsIf TrangThaiStr = "ChoDuyetKyThuat" Or TrangThaiStr = "Chờ duyệt kỹ thuật" Then
		Return "ChoDuyetPM";
		
	ElsIf TrangThaiStr = "ChoDuyetPM" Or TrangThaiStr = "Chờ duyệt PM" Then
		Return "ChoDuyetITDirector";
		
	ElsIf TrangThaiStr = "ChoDuyetITDirector" Or TrangThaiStr = "Chờ duyệt IT Director" Then
		If VuotNganSach Then
			// Nhanh CFO Special Unlock khi vuot ngan sach > 10%
			Return "ChoDuyetCFO";
		Else
			Return "ChoKeToanAP";
		EndIf;
		
	ElsIf TrangThaiStr = "ChoDuyetCFO" Or TrangThaiStr = "Chờ duyệt CFO" Then
		Return "ChoKeToanAP";
		
	ElsIf TrangThaiStr = "ChoKeToanAP" Or TrangThaiStr = "Chờ kế toán AP" Then
		Return "DaGhiSo";
		
	Else
		Return TrangThaiStr;
	EndIf;
EndFunction

// Kiem tra rang buoc Maker-Checker va phan quyen phe duyet
//
// Tham so:
//   NguoiTao           - String, CatalogRef.NguoiDung - Nguoi lap chung tu
//   NguoiDuyet         - String, CatalogRef.NguoiDung - Nguoi thuc hien thao tac duyet
//   TrangThaiDangDuyet - String                       - Cap trang thai dang thuc hien duyet
Procedure KiemTraQuyenDuyet(Val NguoiTao, Val NguoiDuyet, Val TrangThaiDangDuyet) Export
	// 1. CÂM TUYỆT ĐỐI Maker-Checker
	If String(NguoiTao) = String(NguoiDuyet) Then
		Raise "Vi phạm nguyên tắc Maker-Checker: Người tạo không thể tự phê duyệt chứng từ!";
	EndIf;
	
	// 2. Kiem tra nguoi duyet hop le
	If Not ValueIsFilled(NguoiDuyet) Then
		Raise "Chưa xác định người dùng thực hiện phê duyệt!";
	EndIf;
EndProcedure

// Xu ly tu choi phe duyet chung tu AP
//
// Tham so:
//   TrangThaiHienTai - String - Trang thai hien tai truoc khi bi tu choi
//   LyDoTuChoi       - String - Ly do tu choi
//
// Gia tri tra ve:
//   Structure: TrangThaiMoi, TrangThaiTruocDo, LyDo, ThoiDiem
Function TuChoiPheDuyet(Val TrangThaiHienTai, Val LyDoTuChoi) Export
	If Not ValueIsFilled(LyDoTuChoi) Then
		Raise "Bắt buộc phải nhập lý do từ chối phê duyệt!";
	EndIf;
	
	KetQua = New Structure;
	KetQua.Insert("TrangThaiMoi", Enums.TrangThaiHoaDonAP.TuChoi);
	KetQua.Insert("TrangThaiTruocDo", TrangThaiHienTai);
	KetQua.Insert("LyDo", TrimAll(LyDoTuChoi));
	KetQua.Insert("ThoiDiem", CurrentSessionDate());
	
	Return KetQua;
EndFunction

// Kiem tra dau hieu chia nho hoa don (Anti-Split) truoc khi vao buoc Ke toan AP
//
// Tham so:
//   SoHoaDonTrongThang - Number - So luong hoa don phat sinh trong thang cua NCC
//   TongTienLuyKe      - Number - Tong gia tri cac hoa don trong thang
//   NguongCanhBao      - Number - Nguong kiem soat chi tieu
//
// Gia tri tra ve:
//   Boolean - True neu co dau hieu chia nho hoa don
Function KiemTraAntiSplit(Val SoHoaDonTrongThang, Val TongTienLuyKe, Val NguongCanhBao = 100000000) Export
	If SoHoaDonTrongThang >= 3 And TongTienLuyKe >= NguongCanhBao Then
		Return True;
	EndIf;
	Return False;
EndFunction

#EndRegion
