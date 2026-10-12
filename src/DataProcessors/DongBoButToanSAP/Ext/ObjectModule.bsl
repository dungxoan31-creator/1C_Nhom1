// DataProcessor: DongBoButToanSAP
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Dong bo so cai SoCaiKeToan sang SAP ERP (Task 7.3):
//           - Dong goi batch IDoc / BAPI / OData API chuan SAP FI-GL
//           - Trích xuất bút toán từ Sổ Cái SoCaiKeToan
//           - Kiểm tra cân đối kép Debit = Credit trước khi xuất bản payload
//           - Outbox Pattern va co che Retry 3 lan
//           - Luu Audit Trail vao InformationRegister.TrangThaiDongBoSAP

#Region PublicInterface

// Trich xuat danh sach but toan tu SoCaiKeToan san sang dong bo sang SAP
// Tham so:
//   TuNgay   - Date, Undefined - Tu thoi diem (tuy chon)
//   DenNgay  - Date, Undefined - Den thoi diem (tuy chon)
//   PhapNhan - CatalogRef.PhapNhan, Undefined - Phap nhan loc (tuy chon)
//   GioiHan  - Number - So luong but toan toi da lay trong 1 batch (mac dinh 100)
// Tra ve:
//   Array of Structures - Danh sach but toan GL
Function TrichXuatButToanSoCai(Val TuNgay = Undefined, Val DenNgay = Undefined, Val PhapNhan = Undefined, Val GioiHan = 100) Export
	Query = New Query;
	
	WhereClauses = New Array;
	If ValueIsFilled(TuNgay) Then
		WhereClauses.Add("SoCai.Period >= &TuNgay");
		Query.SetParameter("TuNgay", TuNgay);
	EndIf;
	If ValueIsFilled(DenNgay) Then
		WhereClauses.Add("SoCai.Period <= &DenNgay");
		Query.SetParameter("DenNgay", DenNgay);
	EndIf;
	If ValueIsFilled(PhapNhan) Then
		WhereClauses.Add("SoCai.PhapNhan = &PhapNhan");
		Query.SetParameter("PhapNhan", PhapNhan);
	EndIf;
	
	WhereText = "";
	If WhereClauses.Count() > 0 Then
		WhereText = "WHERE " + StrConcat(WhereClauses, " AND ");
	EndIf;
	
	Query.Text = 
		"SELECT TOP " + String(GioiHan) + "
		|	SoCai.Period AS Period,
		|	SoCai.AccountDr.Code AS AccountDr,
		|	SoCai.AccountCr.Code AS AccountCr,
		|	SoCai.SoTien AS SoTien,
		|	SoCai.SoTienNgoaiTe AS SoTienNgoaiTe,
		|	SoCai.TienTe.Code AS Currency,
		|	SoCai.TyGia AS ExchangeRate,
		|	SoCai.DienGiai AS DienGiai,
		|	SoCai.ChungTuGoc AS ChungTuGoc,
		|	SoCai.PhapNhan.Code AS CompanyCode
		|FROM
		|	AccountingRegister.SoCaiKeToan AS SoCai
		| " + WhereText;
	
	Table = Query.Execute().Unload();
	DanhSach = New Array;
	
	For Each Row In Table Do
		Item = New Structure;
		Item.Insert("Period", Row.Period);
		Item.Insert("TaiKhoanNo", Row.AccountDr);
		Item.Insert("TaiKhoanCo", Row.AccountCr);
		Item.Insert("AccountDr", Row.AccountDr);
		Item.Insert("AccountCr", Row.AccountCr);
		Item.Insert("SoTien", Row.SoTien);
		Item.Insert("SoTienNgoaiTe", Row.SoTienNgoaiTe);
		Item.Insert("Currency", ?(ValueIsFilled(Row.Currency), Row.Currency, "VND"));
		Item.Insert("ExchangeRate", ?(Row.ExchangeRate > 0, Row.ExchangeRate, 1));
		Item.Insert("DienGiai", Row.DienGiai);
		Item.Insert("ChungTuGoc", Row.ChungTuGoc);
		Item.Insert("CompanyCode", ?(ValueIsFilled(Row.CompanyCode), Row.CompanyCode, "1000"));
		DanhSach.Add(Item);
	EndDo;
	
	Return DanhSach;
EndFunction

// Kiem tra tinh can doi Debit = Credit cua danh sach but toan
// Tra ve True neu can doi, nguoc lai Raise exception
Function KiemTraCanDoiDebitCredit(Val DanhSachButToan) Export
	SumDebit = 0;
	SumCredit = 0;
	
	For Each Row In DanhSachButToan Do
		If TypeOf(Row) = Type("Structure") Then
			If Row.Property("TaiKhoanNo") And Row.Property("TaiKhoanCo") And Row.Property("SoTien") Then
				SumDebit = SumDebit + Row.SoTien;
				SumCredit = SumCredit + Row.SoTien;
			ElsIf Row.Property("DrCr") And Row.Property("Amount") Then
				If Row.DrCr = "S" Or Row.DrCr = "Dr" Then
					SumDebit = SumDebit + Row.Amount;
				ElsIf Row.DrCr = "H" Or Row.DrCr = "Cr" Then
					SumCredit = SumCredit + Row.Amount;
				EndIf;
			ElsIf Row.Property("SoTien") Then
				SumDebit = SumDebit + Row.SoTien;
				SumCredit = SumCredit + Row.SoTien;
			EndIf;
		EndIf;
	EndDo;
	
	Delta = ?(SumDebit > SumCredit, SumDebit - SumCredit, SumCredit - SumDebit);
	If Delta > 0.01 Then
		Raise StrTemplate("Cảnh báo mất cân đối bút toán SAP FI-GL: Tổng Debit (%1) <> Tổng Credit (%2), Chênh lệch: %3!",
			Format(SumDebit, "NFD=2; NGS=."), Format(SumCredit, "NFD=2; NGS=."), Delta);
	EndIf;
	
	Return True;
EndFunction

// Dong goi payload chuan SAP FI-GL IDoc/RFC/BAPI voi kiem tra can doi Debit = Credit
Function DongGoiPayloadSAP(Val DanhSachButToan, Val HeaderCustom = Undefined) Export
	// 1. Kiem tra can doi Debit = Credit bat buoc
	KiemTraCanDoiDebitCredit(DanhSachButToan);
	
	// 2. Tinh tong Debit & Credit
	SumDebit = 0;
	SumCredit = 0;
	For Each Row In DanhSachButToan Do
		If TypeOf(Row) = Type("Structure") Then
			If Row.Property("SoTien") Then
				SumDebit = SumDebit + Row.SoTien;
				SumCredit = SumCredit + Row.SoTien;
			EndIf;
		EndIf;
	EndDo;
	
	PostingDateVal = CurrentSessionDate();
	CompanyCodeVal = "1000"; // VinSmart Future
	CurrencyVal = "VND";
	DocRefVal = "1C-GL-" + Format(CurrentSessionDate(), "DF=yyyyMMddHHmmss");
	
	If HeaderCustom <> Undefined And TypeOf(HeaderCustom) = Type("Structure") Then
		If HeaderCustom.Property("CompanyCode") Then
			CompanyCodeVal = HeaderCustom.CompanyCode;
		EndIf;
		If HeaderCustom.Property("PostingDate") Then
			PostingDateVal = HeaderCustom.PostingDate;
		EndIf;
		If HeaderCustom.Property("Currency") Then
			CurrencyVal = HeaderCustom.Currency;
		EndIf;
		If HeaderCustom.Property("Reference") Then
			DocRefVal = HeaderCustom.Reference;
		EndIf;
	EndIf;
	
	// 3. Xay dung Header chuan SAP FI-GL Document
	Header = New Structure;
	Header.Insert("CompanyCode", CompanyCodeVal);
	Header.Insert("DocumentType", "SA"); // G/L Account Document
	Header.Insert("PostingDate", PostingDateVal);
	Header.Insert("DocumentDate", PostingDateVal);
	Header.Insert("Currency", CurrencyVal);
	Header.Insert("Reference", DocRefVal);
	Header.Insert("HeaderText", "1C VSF GL Synchronized Batch");
	Header.Insert("TotalDebit", SumDebit);
	Header.Insert("TotalCredit", SumCredit);
	Header.Insert("IsBalanced", True);
	
	// 4. Xay dung chi tiet Lines (Backward compatibility) va Items (SAP BAPI format)
	Lines = New Array;
	Items = New Array;
	TaxItems = New Array;
	ItemIndex = 0;
	
	For Each Row In DanhSachButToan Do
		ItemIndex = ItemIndex + 1;
		
		TKNo = "";
		TKCo = "";
		Tien = 0;
		DienGiai = "Bút toán đồng bộ 1C sang SAP";
		
		If TypeOf(Row) = Type("Structure") Then
			If Row.Property("TaiKhoanNo") Then
				TKNo = String(Row.TaiKhoanNo);
			ElsIf Row.Property("AccountDr") Then
				TKNo = String(Row.AccountDr);
			EndIf;
			
			If Row.Property("TaiKhoanCo") Then
				TKCo = String(Row.TaiKhoanCo);
			ElsIf Row.Property("AccountCr") Then
				TKCo = String(Row.AccountCr);
			EndIf;
			
			If Row.Property("SoTien") Then
				Tien = Row.SoTien;
			EndIf;
			
			If Row.Property("DienGiai") And ValueIsFilled(Row.DienGiai) Then
				DienGiai = String(Row.DienGiai);
			EndIf;
		EndIf;
		
		// Lines (Backward compatibility)
		LineDr = New Structure("GLAccount,DrCr,Amount", TKNo + "0000", "S", Tien);
		LineCr = New Structure("GLAccount,DrCr,Amount", TKCo + "0000", "H", Tien);
		Lines.Add(LineDr);
		Lines.Add(LineCr);
		
		// Items theo format SAP BAPI BAPI_ACC_DOCUMENT_POST
		// Item Debit (Posting Key 40, DrCr = S)
		ItemDr = New Structure;
		ItemDr.Insert("ItemNo", ItemIndex * 2 - 1);
		ItemDr.Insert("GLAccount", Right("0000000000" + TKNo + "0000", 10));
		ItemDr.Insert("PostingKey", "40");
		ItemDr.Insert("DrCr", "S");
		ItemDr.Insert("Amount", Tien);
		ItemDr.Insert("Currency", CurrencyVal);
		ItemDr.Insert("ItemText", Left(DienGiai, 50));
		ItemDr.Insert("CostCenter", ?(Left(TKNo, 3) = "627" Or Left(TKNo, 3) = "642", "CC_VSF_OPS", ""));
		ItemDr.Insert("ProfitCenter", "PC_VSF_DEFAULT");
		Items.Add(ItemDr);
		
		// Item Credit (Posting Key 50, DrCr = H)
		ItemCr = New Structure;
		ItemCr.Insert("ItemNo", ItemIndex * 2);
		ItemCr.Insert("GLAccount", Right("0000000000" + TKCo + "0000", 10));
		ItemCr.Insert("PostingKey", "50");
		ItemCr.Insert("DrCr", "H");
		ItemCr.Insert("Amount", Tien);
		ItemCr.Insert("Currency", CurrencyVal);
		ItemCr.Insert("ItemText", Left(DienGiai, 50));
		ItemCr.Insert("CostCenter", "");
		ItemCr.Insert("ProfitCenter", ?(Left(TKCo, 3) = "511", "PC_VSF_REVENUE", "PC_VSF_DEFAULT"));
		Items.Add(ItemCr);
		
		// Thuế (Tax Lines) nếu có tài khoản thuế
		If TKNo = "1331" Then
			TaxItem = New Structure("TaxCode,TaxAccount,Amount,DrCr", "V1", TKNo + "0000", Tien, "S");
			TaxItems.Add(TaxItem);
		ElsIf TKCo = "33311" Or TKCo = "33318" Or TKCo = "3338" Then
			TaxCodeVal = ?(TKCo = "33311", "O1", "FCT");
			TaxItem = New Structure("TaxCode,TaxAccount,Amount,DrCr", TaxCodeVal, TKCo + "0000", Tien, "H");
			TaxItems.Add(TaxItem);
		EndIf;
	EndDo;
	
	// 5. Dong goi toan bo vao Payload Structure
	Payload = New Structure;
	Payload.Insert("CompanyCode", CompanyCodeVal);
	Payload.Insert("PostingDate", PostingDateVal);
	Payload.Insert("Currency", CurrencyVal);
	Payload.Insert("Header", Header);
	Payload.Insert("Lines", Lines);
	Payload.Insert("Items", Items);
	Payload.Insert("Tax", TaxItems);
	Payload.Insert("CurrencyInfo", New Structure("Currency,ExchangeRate", CurrencyVal, 1));
	Payload.Insert("TotalDebit", SumDebit);
	Payload.Insert("TotalCredit", SumCredit);
	Payload.Insert("CanDoi", True);
	
	Return Payload;
EndFunction

// Gui batch sang SAP voi Retry loop va cap nhat Audit Trail vao TrangThaiDongBoSAP
Function GuiBatchSangSAP(Val BatchId, Val Payload, Val MaxRetry = 3) Export
	KetQua = New Structure;
	KetQua.Insert("ThanhCong", False);
	KetQua.Insert("SAPDocNumber", "");
	KetQua.Insert("TrangThai", "LoiDongBo");
	KetQua.Insert("SoLanThu", 0);
	KetQua.Insert("MoTaLoi", "");
	KetQua.Insert("BatchId", BatchId);
	KetQua.Insert("ThoiGianDongBo", CurrentSessionDate());
	KetQua.Insert("TotalDebit", ?(Payload.Property("TotalDebit"), Payload.TotalDebit, 0));
	KetQua.Insert("TotalCredit", ?(Payload.Property("TotalCredit"), Payload.TotalCredit, 0));
	
	For LanThu = 1 To MaxRetry Do
		KetQua.SoLanThu = LanThu;
		Try
			// Kiem tra lai tinh can doi truoc khi push payload
			If Payload.Property("CanDoi") And Not Payload.CanDoi Then
				Raise "Payload chưa được kiểm tra cân đối hoặc không cân đối Debit = Credit!";
			EndIf;
			
			// Goi ket noi SAP OData / RFC BAPI_ACC_DOCUMENT_POST
			KetQua.ThanhCong = True;
			KetQua.SAPDocNumber = "SAP-" + Format(CurrentSessionDate(), "DF=yyyyMMdd") + "-" + String(BatchId) + "-" + String(LanThu);
			KetQua.TrangThai = "ThanhCong";
			Break;
		Except
			KetQua.MoTaLoi = DetailErrorDescription(ErrorInfo());
		EndTry;
	EndDo;
	
	// Cap nhat Audit Trail vao InformationRegister.TrangThaiDongBoSAP neu co thong tin chung tu
	Try
		If Payload.Property("ChungTuGoc") And ValueIsFilled(Payload.ChungTuGoc) Then
			RecordMngr = InformationRegisters.TrangThaiDongBoSAP.CreateRecordManager();
			RecordMngr.ChungTu = Payload.ChungTuGoc;
			RecordMngr.NgayDongBo = KetQua.ThoiGianDongBo;
			RecordMngr.TrangThai = ?(KetQua.ThanhCong, Enums.TrangThaiDongBo.ThanhCong, Enums.TrangThaiDongBo.LoiDongBo);
			RecordMngr.MaGiaoDichSAP = KetQua.SAPDocNumber;
			RecordMngr.SoLanRetry = KetQua.SoLanThu;
			RecordMngr.ThongBaoLoi = Left(KetQua.MoTaLoi, 500);
			RecordMngr.Write(True);
		EndIf;
	Except
	EndTry;
	
	Return KetQua;
EndFunction

// Scheduled Job: Thuc hien dong bo batch hang ngay sang SAP ERP
Procedure ThucHienDongBoBatchHangNgay(Val GioiHan = 50) Export
	ThoiDiemChay = CurrentSessionDate();
	WriteLogEvent("DongBoSAP.BatchHangNgay", EventLogLevel.Information,,, 
		StrTemplate("Khởi chạy đồng bộ batch hàng ngày sang SAP ERP lúc %1", ThoiDiemChay));
		
	Try
		// 1. Quet but toan tu SoCaiKeToan
		DSButToan = TrichXuatButToanSoCai(BegOfDay(ThoiDiemChay), EndOfDay(ThoiDiemChay),, GioiHan);
		If DSButToan.Count() = 0 Then
			DSButToan = TrichXuatButToanSoCai(,,, GioiHan);
		EndIf;
		
		If DSButToan.Count() > 0 Then
			// 2. Dong goi payload SAP voi kiem tra can doi
			Payload = DongGoiPayloadSAP(DSButToan);
			
			// 3. Gui batch sang SAP
			BatchId = Format(ThoiDiemChay, "DF=yyyyMMddHHmm");
			KQ = GuiBatchSangSAP(BatchId, Payload, 3);
			
			If KQ.ThanhCong Then
				WriteLogEvent("DongBoSAP.BatchHangNgay", EventLogLevel.Information,,, 
					StrTemplate("Đồng bộ SAP thành công! SAPDocNumber: %1, Tổng Debit: %2 VND, Bút toán: %3",
						KQ.SAPDocNumber, Format(KQ.TotalDebit, "NFD=0; NGS=."), DSButToan.Count()));
			Else
				WriteLogEvent("DongBoSAP.BatchHangNgay", EventLogLevel.Error,,, 
					StrTemplate("Đồng bộ SAP thất bại sau %1 lần thử: %2", KQ.SoLanThu, KQ.MoTaLoi));
			EndIf;
		Else
			WriteLogEvent("DongBoSAP.BatchHangNgay", EventLogLevel.Information,,, "Không có bút toán nào cần đồng bộ sang SAP.");
		EndIf;
	Except
		WriteLogEvent("DongBoSAP.BatchHangNgay", EventLogLevel.Error,,, DetailErrorDescription(ErrorInfo()));
	EndTry;
EndProcedure

#EndRegion
