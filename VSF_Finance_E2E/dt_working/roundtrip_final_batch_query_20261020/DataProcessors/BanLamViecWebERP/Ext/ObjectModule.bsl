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
			If Not ValueIsFilled(RefChungTu) Or RefChungTu.DeletionMark Then
				KetQua.ThatBai = KetQua.ThatBai + 1;
				ItemInfo.Insert("TrangThai", "ThatBai");
				ItemInfo.Insert("GhiChu", "Chứng từ không tồn tại hoặc đã bị đánh dấu xóa.");
			ElsIf TypeOf(RefChungTu) = Type("DocumentRef.HoaDonNhaCungCap") Then
				XuLy = DuyetHoaDonAPHangLoat(RefChungTu.GetObject());
				If XuLy.ThanhCong Then
					KetQua.ThanhCong = KetQua.ThanhCong + 1;
					ItemInfo.Insert("TrangThai", "ThanhCong");
				Else
					KetQua.ThatBai = KetQua.ThatBai + 1;
					ItemInfo.Insert("TrangThai", "ThatBai");
				EndIf;
				ItemInfo.Insert("GhiChu", XuLy.GhiChu);
				ItemInfo.Insert("TrangThaiChungTu", XuLy.TrangThai);
			ElsIf TypeOf(RefChungTu) = Type("DocumentRef.UyNhiemChi") Then
				XuLy = DuyetUyNhiemChiHangLoat(RefChungTu.GetObject());
				If XuLy.ThanhCong Then
					KetQua.ThanhCong = KetQua.ThanhCong + 1;
					ItemInfo.Insert("TrangThai", "ThanhCong");
				Else
					KetQua.ThatBai = KetQua.ThatBai + 1;
					ItemInfo.Insert("TrangThai", "ThatBai");
				EndIf;
				ItemInfo.Insert("GhiChu", XuLy.GhiChu);
				ItemInfo.Insert("TrangThaiChungTu", XuLy.TrangThai);
			Else
				KetQua.ThatBai = KetQua.ThatBai + 1;
				ItemInfo.Insert("TrangThai", "ThatBai");
				ItemInfo.Insert("GhiChu", "Loại chứng từ không được hỗ trợ trong hàng đợi phê duyệt.");
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

Function DuyetHoaDonAPHangLoat(Doc)
	Result = New Structure("ThanhCong,GhiChu,TrangThai", False, "", QuanLyVongDoiChungTuServer.TenTrangThai(Doc.TrangThai));
	LaAdmin = PhanQuyenBaoMatServer.LaPhienQuanTriHeThong();
	If LaAdmin Then
		Result.GhiChu = "Quản trị hệ thống không được phê duyệt chứng từ tài chính.";
		Return Result;
	EndIf;
	If Doc.Posted Then
		Result.GhiChu = "Hóa đơn đã ghi sổ; không còn là chứng từ chờ duyệt.";
		Return Result;
	EndIf;
	
	If Doc.TrangThai = Enums.TrangThaiHoaDonAP.ChoKeToanTruongDuyet Then
		If Not IsInRole("KeToanTruong") Then
			Result.GhiChu = "Chỉ Kế toán trưởng được xử lý hóa đơn đang chờ Kế toán trưởng duyệt.";
			Return Result;
		EndIf;
		QuyTrinhPheDuyetAPServer.KiemTraQuyenDuyet(Doc.NguoiLap, UserName(), "ChoKeToanTruongDuyet");
		Doc.NguoiDuyet = UserName();
		NguongCFO = Constants.NguongPheDuyetChiTienCFO.Get();
		If NguongCFO <= 0 Then NguongCFO = 500000000; EndIf;
		If Doc.TongTien > NguongCFO Then
			Doc.TrangThai = Enums.TrangThaiHoaDonAP.ChoDuyetCFO;
			Doc.Write();
			SavedDoc = Doc.Ref.GetObject();
			Result.TrangThai = QuanLyVongDoiChungTuServer.TenTrangThai(SavedDoc.TrangThai);
			Result.ThanhCong = Not SavedDoc.Posted And SavedDoc.TrangThai = Enums.TrangThaiHoaDonAP.ChoDuyetCFO;
			Result.GhiChu = ?(Result.ThanhCong, "Đã chuyển hóa đơn sang hàng đợi CFO theo ngưỡng phê duyệt.", "Không lưu được trạng thái chuyển CFO.");
		Else
			Doc.TrangThai = Enums.TrangThaiHoaDonAP.DaGhiSo;
			Doc.Write(DocumentWriteMode.Posting);
			SavedDoc = Doc.Ref.GetObject();
			Result.TrangThai = QuanLyVongDoiChungTuServer.TenTrangThai(SavedDoc.TrangThai);
			Result.ThanhCong = SavedDoc.Posted And SavedDoc.TrangThai = Enums.TrangThaiHoaDonAP.DaGhiSo;
			Result.GhiChu = ?(Result.ThanhCong, "Đã duyệt và ghi sổ hóa đơn trong hạn mức Kế toán trưởng.", "Ghi sổ hóa đơn bị từ chối hoặc không hoàn tất.");
		EndIf;
		Return Result;
	EndIf;
	
	If Doc.TrangThai = Enums.TrangThaiHoaDonAP.ChoDuyetCFO Then
		If Not IsInRole("GiamDocTaiChinh_CFO") Then
			Result.GhiChu = "Chỉ CFO được xử lý hóa đơn đang chờ CFO duyệt.";
			Return Result;
		EndIf;
		QuyTrinhPheDuyetAPServer.KiemTraQuyenDuyet(Doc.NguoiLap, UserName(), "ChoDuyetCFO");
		Doc.NguoiDuyet = UserName();
		Doc.TrangThai = Enums.TrangThaiHoaDonAP.DaGhiSo;
		Doc.Write(DocumentWriteMode.Posting);
		SavedDoc = Doc.Ref.GetObject();
		Result.TrangThai = QuanLyVongDoiChungTuServer.TenTrangThai(SavedDoc.TrangThai);
		Result.ThanhCong = SavedDoc.Posted And SavedDoc.TrangThai = Enums.TrangThaiHoaDonAP.DaGhiSo;
		Result.GhiChu = ?(Result.ThanhCong, "CFO đã duyệt và ghi sổ hóa đơn.", "Ghi sổ hóa đơn bị từ chối hoặc không hoàn tất.");
		Return Result;
	EndIf;
	
	Result.GhiChu = "Trạng thái hóa đơn không đủ điều kiện phê duyệt hàng loạt.";
	Return Result;
EndFunction

Function DuyetUyNhiemChiHangLoat(Doc)
	Result = New Structure("ThanhCong,GhiChu,TrangThai", False, "", QuanLyVongDoiChungTuServer.TenTrangThai(Doc.TrangThai));
	LaAdmin = PhanQuyenBaoMatServer.LaPhienQuanTriHeThong();
	If LaAdmin Then
		Result.GhiChu = "Quản trị hệ thống không được phê duyệt chứng từ tài chính.";
		Return Result;
	EndIf;
	If Doc.Posted Then
		Result.GhiChu = "Ủy nhiệm chi đã ghi sổ; không còn là chứng từ chờ xử lý.";
		Return Result;
	EndIf;
	
	If Doc.TrangThai = Enums.TrangThaiLenhThanhToan.ChoDuyet Or Doc.TrangThai = Enums.TrangThaiLenhThanhToan.DaDuyet Then
		If Not IsInRole("KeToanTruong") Then
			Result.GhiChu = "Chỉ Kế toán trưởng được duyệt hoặc chuyển ủy nhiệm chi sang ngân hàng.";
			Return Result;
		EndIf;
		QuyTrinhPheDuyetAPServer.KiemTraQuyenDuyet(Doc.NguoiLap, UserName(), QuanLyVongDoiChungTuServer.TenTrangThai(Doc.TrangThai));
		Doc.NguoiDuyet = UserName();
		If Doc.TrangThai = Enums.TrangThaiLenhThanhToan.ChoDuyet Then
			Doc.TrangThai = Enums.TrangThaiLenhThanhToan.DaDuyet;
			Doc.Write();
			SavedDoc = Doc.Ref.GetObject();
			If SavedDoc.Posted Or SavedDoc.TrangThai <> Enums.TrangThaiLenhThanhToan.DaDuyet Then
				Result.GhiChu = "Không lưu được bước Đã duyệt của ủy nhiệm chi.";
				Return Result;
			EndIf;
			Doc = SavedDoc;
		EndIf;
		Doc.TrangThai = Enums.TrangThaiLenhThanhToan.DaGuiNganHang;
		Doc.Write();
		SavedDoc = Doc.Ref.GetObject();
		Result.TrangThai = QuanLyVongDoiChungTuServer.TenTrangThai(SavedDoc.TrangThai);
		Result.ThanhCong = Not SavedDoc.Posted And SavedDoc.TrangThai = Enums.TrangThaiLenhThanhToan.DaGuiNganHang;
		Result.GhiChu = ?(Result.ThanhCong, "Đã duyệt và chuyển ủy nhiệm chi sang trạng thái Đã gửi ngân hàng.", "Không lưu được trạng thái gửi ngân hàng.");
		Return Result;
	EndIf;
	
	If Doc.TrangThai = Enums.TrangThaiLenhThanhToan.DaGuiNganHang Then
		If Not IsInRole("GiamDocTaiChinh_CFO") Then
			Result.GhiChu = "Chỉ CFO được ghi sổ ủy nhiệm chi đã gửi ngân hàng.";
			Return Result;
		EndIf;
		QuyTrinhPheDuyetAPServer.KiemTraQuyenDuyet(Doc.NguoiLap, UserName(), "DaGuiNganHang");
		Doc.NguoiDuyet = UserName();
		Doc.TrangThai = Enums.TrangThaiLenhThanhToan.DaGhiSo;
		Doc.Write(DocumentWriteMode.Posting);
		SavedDoc = Doc.Ref.GetObject();
		Result.TrangThai = QuanLyVongDoiChungTuServer.TenTrangThai(SavedDoc.TrangThai);
		Result.ThanhCong = SavedDoc.Posted And SavedDoc.TrangThai = Enums.TrangThaiLenhThanhToan.DaGhiSo;
		Result.GhiChu = ?(Result.ThanhCong, "CFO đã ghi sổ ủy nhiệm chi.", "Ghi sổ ủy nhiệm chi bị từ chối hoặc không hoàn tất.");
		Return Result;
	EndIf;
	
	Result.GhiChu = "Trạng thái ủy nhiệm chi không đủ điều kiện phê duyệt hàng loạt.";
	Return Result;
EndFunction

#EndRegion
