// Form Module: FormPheDuyetHangLoat

#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	NapDanhSachChoDuyet();
EndProcedure

#EndRegion

#Region FormCommandsEventHandlers

&AtClient
Procedure CmdLamMoi(Command)
	NapDanhSachChoDuyetAtServer();
	ShowUserNotification("Làm mới danh sách", , "Đã cập nhật danh sách chứng từ chờ duyệt.", PictureLib.Information);
EndProcedure

&AtClient
Procedure CmdChonTatCa(Command)
	For Each Row In BangChungTuChoDuyet Do
		Row.Chon = True;
	EndDo;
EndProcedure

&AtClient
Procedure CmdBoChonTatCa(Command)
	For Each Row In BangChungTuChoDuyet Do
		Row.Chon = False;
	EndDo;
EndProcedure

&AtClient
Procedure CmdPheDuyetHangLoat(Command)
	DanhSachDuocChon = New Array;
	For Each Row In BangChungTuChoDuyet Do
		If Row.Chon Then
			DanhSachDuocChon.Add(Row.ChungTu);
		EndIf;
	EndDo;
	
	If DanhSachDuocChon.Count() = 0 Then
		ShowUserNotification("Cảnh báo", , "Vui lòng tích chọn ít nhất 1 chứng từ để phê duyệt.", PictureLib.Warning);
		Return;
	EndIf;
	
	KetQua = ThucHienPheDuyetHangLoatAtServer(DanhSachDuocChon);
	
	ThongBao = StrTemplate("Phê duyệt hoàn tất: %1 thành công, %2 thất bại.", KetQua.ThanhCong, KetQua.ThatBai);
	ShowUserNotification("Kết quả phê duyệt", , ThongBao, PictureLib.Information);
	
	NapDanhSachChoDuyetAtServer();
EndProcedure

#EndRegion

#Region Private

&AtServer
Procedure NapDanhSachChoDuyet()
	BangChungTuChoDuyet.Clear();
	
	DanhSach = DataProcessors.BanLamViecWebERP.LayDanhSachChoPheDuyet();
	For Each Item In DanhSach Do
		NewRow = BangChungTuChoDuyet.Add();
		NewRow.Chon = True;
		NewRow.ChungTu = Item.ChungTu;
		NewRow.LoaiChungTu = Item.LoaiChungTu;
		NewRow.TenLoaiChungTu = Item.TenLoaiChungTu;
		NewRow.SoChungTu = Item.SoChungTu;
		NewRow.NgayChungTu = Item.NgayChungTu;
		NewRow.DoiTac = Item.DoiTac;
		NewRow.SoTien = Item.SoTien;
		NewRow.TrangThai = Item.TrangThai;
	EndDo;
EndProcedure

&AtServer
Procedure NapDanhSachChoDuyetAtServer()
	NapDanhSachChoDuyet();
EndProcedure

&AtServer
Function ThucHienPheDuyetHangLoatAtServer(Val DanhSachChungTu)
	DPObj = FormAttributeToValue("Object");
	KetQua = DPObj.PheDuyetHangLoat(DanhSachChungTu);
	Return KetQua;
EndFunction

#EndRegion
