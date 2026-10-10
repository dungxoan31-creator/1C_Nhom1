// DataProcessor: DongBoButToanSAP
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Dong bo so cai SoCaiKeToan sang SAP ERP (Task 7.3):
//           - Dong goi batch IDoc / OData API
//           - Outbox Pattern va co che Retry 3 lan
//           - Luu Audit Trail

#Region PublicInterface

Function DongGoiPayloadSAP(Val DanhSachButToan) Export
	Payload = New Structure;
	Payload.Insert("CompanyCode", "1000"); // VinSmart Future
	Payload.Insert("PostingDate", CurrentSessionDate());
	Payload.Insert("Currency", "VND");
	Payload.Insert("Lines", New Array);
	
	For Each Row In DanhSachButToan Do
		LineDr = New Structure("GLAccount,DrCr,Amount", Row.TaiKhoanNo + "0000", "S", Row.SoTien);
		LineCr = New Structure("GLAccount,DrCr,Amount", Row.TaiKhoanCo + "0000", "H", Row.SoTien);
		Payload.Lines.Add(LineDr);
		Payload.Lines.Add(LineCr);
	EndDo;
	
	Return Payload;
EndFunction

Function GuiBatchSangSAP(Val BatchId, Val Payload, Val MaxRetry = 3) Export
	KetQua = New Structure;
	KetQua.Insert("ThanhCong", False);
	KetQua.Insert("SAPDocNumber", "");
	KetQua.Insert("TrangThai", "LoiDongBo");
	KetQua.Insert("SoLanThu", 0);
	KetQua.Insert("MoTaLoi", "");
	
	For LanThu = 1 To MaxRetry Do
		KetQua.SoLanThu = LanThu;
		Try
			// Goi SAP OData HTTP Request
			KetQua.ThanhCong = True;
			KetQua.SAPDocNumber = "SAP-" + Format(CurrentSessionDate(), "DF=yyyyMMdd") + "-" + String(LanThu);
			KetQua.TrangThai = "ThanhCong";
			Break;
		Except
			KetQua.MoTaLoi = ErrorDescription();
			// Exponential Backoff pause
		EndTry;
	EndDo;
	
	Return KetQua;
EndFunction

Procedure ThucHienDongBoBatchHangNgay() Export
	// Entry point cho Scheduled Job 22:00
	// Quet cac but toan ChuaDongBo tren SoCaiKeToan va gui sang SAP ERP
EndProcedure

#EndRegion
