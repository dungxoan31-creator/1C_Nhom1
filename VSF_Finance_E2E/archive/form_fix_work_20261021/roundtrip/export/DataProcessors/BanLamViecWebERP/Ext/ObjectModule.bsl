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
	
	If Doc.TrangThai = Enums.TrangThaiLenhThanhToan.ChoDuyet Then
		If Not IsInRole("KeToanTruong") Then
			Result.GhiChu = "Chỉ Kế toán trưởng được duyệt ủy nhiệm chi.";
			Return Result;
		EndIf;
		QuyTrinhPheDuyetAPServer.KiemTraQuyenDuyet(Doc.NguoiLap, UserName(), QuanLyVongDoiChungTuServer.TenTrangThai(Doc.TrangThai));
		Doc.NguoiDuyet = UserName();
		Doc.TrangThai = Enums.TrangThaiLenhThanhToan.DaDuyet;
		Doc.Write();
		SavedDoc = Doc.Ref.GetObject();
		Result.TrangThai = QuanLyVongDoiChungTuServer.TenTrangThai(SavedDoc.TrangThai);
		Result.ThanhCong = Not SavedDoc.Posted And SavedDoc.TrangThai = Enums.TrangThaiLenhThanhToan.DaDuyet;
		Result.GhiChu = ?(Result.ThanhCong, "Ủy nhiệm chi đã được Kế toán trưởng phê duyệt; gửi ngân hàng là thao tác riêng.", "Không lưu được trạng thái đã duyệt của ủy nhiệm chi.");
		Return Result;
	EndIf;
	
	If Doc.TrangThai = Enums.TrangThaiLenhThanhToan.DaDuyet Then
		Result.GhiChu = "Ủy nhiệm chi đã được duyệt; dùng lệnh Gửi ngân hàng để chuyển tiền.";
		Return Result;
	EndIf;
	
	If Doc.LaTraSoatHoanTra And Doc.TrangThai = Enums.TrangThaiLenhThanhToan.DaNhanHoanTien Then
		If Not IsInRole("GiamDocTaiChinh_CFO") Then
			Result.GhiChu = "Chỉ CFO được ghi sổ khoản hoàn tiền đã được ngân hàng xác nhận.";
			Return Result;
		EndIf;
		If Doc.TrangThaiGuiNganHang <> "REFUND_RECEIVED" Or IsBlankString(Doc.MaGiaoDichNganHang) Then
			Result.GhiChu = "Cần xác nhận giao dịch tiền hoàn đã vào ngân hàng trước khi ghi sổ.";
			Return Result;
		EndIf;
		QuyTrinhPheDuyetAPServer.KiemTraQuyenDuyet(Doc.NguoiLap, UserName(), "DaNhanHoanTien");
		Doc.NguoiDuyet = UserName();
		Doc.TrangThai = Enums.TrangThaiLenhThanhToan.DaGhiSo;
		Doc.Write(DocumentWriteMode.Posting);
		SavedDoc = Doc.Ref.GetObject();
		Result.TrangThai = QuanLyVongDoiChungTuServer.TenTrangThai(SavedDoc.TrangThai);
		Result.ThanhCong = SavedDoc.Posted And SavedDoc.TrangThai = Enums.TrangThaiLenhThanhToan.DaGhiSo;
		Result.GhiChu = ?(Result.ThanhCong, "CFO đã ghi sổ khoản hoàn tiền ngân hàng.", "Ghi sổ khoản hoàn tiền bị từ chối hoặc không hoàn tất.");
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

// Gửi một ủy nhiệm chi đã được Kế toán trưởng duyệt; không ghi sổ kế toán.
Function GuiLenhChiDaDuyetNganHang(Val PaymentRef) Export
	Result = New Structure("accepted,transaction_id,bank_status,http_code,error,request_id", False, "", "", 0, "", "");
	If PhanQuyenBaoMatServer.LaPhienQuanTriHeThong() Or Not IsInRole("KeToanTruong") Then
		Result.error = "Only a non-admin Chief Accountant can submit approved payment orders to the bank.";
		Return Result;
	EndIf;
	If Not ValueIsFilled(PaymentRef) Or TypeOf(PaymentRef) <> Type("DocumentRef.UyNhiemChi") Or PaymentRef.DeletionMark Then
		Result.error = "A valid, non-deleted payment order reference is required.";
		Return Result;
	EndIf;

	Payment = PaymentRef.GetObject();
	If Payment.Posted Or Payment.TrangThai <> Enums.TrangThaiLenhThanhToan.DaDuyet Then
		Result.error = "Only an unposted, approved payment order can be submitted to the bank.";
		Return Result;
	EndIf;
	If TypeOf(Payment.ChungTuGoc) <> Type("DocumentRef.HoaDonNhaCungCap") Or Not Payment.ChungTuGoc.Posted Then
		Result.bank_status = "SOURCE_INVOICE_NOT_POSTED";
		Result.error = "The supplier invoice must be posted before submitting its payment to the bank.";
		Return Result;
	EndIf;

	BankResult = TichHopNganHangServer.GuiLenhChiNganHang(PaymentRef);
	Payment.TrangThaiGuiNganHang = BankResult.bank_status;
	Payment.ThoiDiemGuiNganHang = CurrentSessionDate();
	If BankResult.accepted Then
		Payment.MaGiaoDichNganHang = BankResult.transaction_id;
		Payment.TrangThai = Enums.TrangThaiLenhThanhToan.DaGuiNganHang;
	EndIf;
	Payment.Write();
	SavedPayment = PaymentRef.GetObject();
	Result.accepted = BankResult.accepted And Not SavedPayment.Posted
		And SavedPayment.TrangThai = Enums.TrangThaiLenhThanhToan.DaGuiNganHang
		And SavedPayment.TrangThaiGuiNganHang = "ACCEPTED"
		And SavedPayment.MaGiaoDichNganHang = BankResult.transaction_id;
	Result.transaction_id = BankResult.transaction_id;
	Result.bank_status = BankResult.bank_status;
	Result.http_code = BankResult.http_code;
	Result.error = BankResult.error;
	Result.request_id = BankResult.request_id;
	If BankResult.accepted And Not Result.accepted Then
		Result.error = "Bank accepted the request but 1C did not persist the accepted transaction state; retry with the same idempotency key.";
		WriteLogEvent("BankIntegration.PaymentSubmission", EventLogLevel.Error,,, Result.request_id + ": " + Result.error);
	EndIf;
	Return Result;
EndFunction

// Confirm an incoming supplier refund after KTT approval; this is not an outgoing payment.
Function XacNhanHoanTienNganHang(Val RefundRef) Export
	Return TichHopNganHangServer.XacNhanHoanTienNganHang(RefundRef);
EndFunction

#EndRegion
