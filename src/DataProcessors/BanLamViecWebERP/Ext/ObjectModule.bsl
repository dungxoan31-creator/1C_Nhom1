#Region Public

// Thực hiện phê duyệt Maker-Checker hàng loạt cho danh sách chứng từ đã chọn
//
// Tham số:
//   DanhSachChungTu - Mảng: Danh sách Reference các chứng từ cần phê duyệt
//
// Giá trị trả về:
//   Cấu trúc: {ThanhCong: Number, ThatBai: Number, ChiTiet: Mảng}
//
Function PheDuyetHangLoat(Val DanhSachChungTu) Export
	
	KetQua = New Structure;
	KetQua.Insert("ThanhCong", 0);
	KetQua.Insert("ThatBai", 0);
	
	ChiTiet = New Array;
	
	For Each RefChungTu In DanhSachChungTu Do
		ItemInfo = New Structure;
		ItemInfo.Insert("ChungTu", RefChungTu);
		
		Try
			// Gọi hàm xử lý phê duyệt từ module PheDuyetDaCapServer
			DaDuyet = PheDuyetDaCapServer.PheDuyetChungTu(RefChungTu);
			If DaDuyet Then
				KetQua.ThanhCong = KetQua.ThanhCong + 1;
				ItemInfo.Insert("TrangThai", "ThanhCong");
				ItemInfo.Insert("GhiChu", "Đã phê duyệt và ghi sổ thành công.");
			Else
				KetQua.ThatBai = KetQua.ThatBai + 1;
				ItemInfo.Insert("TrangThai", "ThatBai");
				ItemInfo.Insert("GhiChu", "Không đủ điều kiện phê duyệt hoặc phân quyền không hợp lệ.");
			EndIf;
		Except
			KetQua.ThatBai = KetQua.ThatBai + 1;
			ItemInfo.Insert("TrangThai", "Loi");
			ItemInfo.Insert("GhiChu", BriefErrorDescription(ErrorInfo()));
		EndTry;
		
		ChiTiet.Add(ItemInfo);
	EndDo;
	
	KetQua.Insert("ChiTiet", ChiTiet);
	Return KetQua;
	
EndFunction

#EndRegion
