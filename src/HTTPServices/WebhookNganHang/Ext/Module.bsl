// HTTP Service: WebhookNganHang
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Tiep nhan Webhook bien dong so du tu Core Banking, Idempotency nguyen tu (Task 5.1).

#Region EventHandlers

Function WebhookPOST(Request)
	// 1. Doc header Idempotency-Key
	Headers = Request.Headers;
	IdempotencyKey = "";
	For Each HeaderItem In Headers Do
		If Upper(HeaderItem.Key) = "X-IDEMPOTENCY-KEY" Then
			IdempotencyKey = HeaderItem.Value;
			Break;
		EndIf;
	EndDo;
	
	BodyString = Request.GetBodyAsString();
	
	// Parse JSON Payload
	JsonReader = New JSONReader;
	JsonReader.SetString(BodyString);
	PayloadData = Undefined;
	Try
		PayloadData = ReadJSON(JsonReader);
	Except
		Response = New HTTPServiceResponse(400);
		Response.SetBodyFromString("Invalid JSON payload");
		Return Response;
	EndTry;
	JsonReader.Close();
	
	If IsBlankString(IdempotencyKey) And TypeOf(PayloadData) = Type("Structure") Then
		If PayloadData.Property("IdempotencyKey") Then
			IdempotencyKey = PayloadData.IdempotencyKey;
		EndIf;
	EndIf;
	
	If IsBlankString(IdempotencyKey) Then
		Response = New HTTPServiceResponse(400);
		Response.SetBodyFromString("Missing Idempotency-Key");
		Return Response;
	EndIf;
	
	// Tinh PayloadHash don gian
	PayloadHash = String(StrLen(BodyString)) + "_" + Left(BodyString, 20);
	If TypeOf(PayloadData) = Type("Structure") And PayloadData.Property("PayloadHash") Then
		PayloadHash = PayloadData.PayloadHash;
	EndIf;
	
	// 2. Kiem tra Idempotency tren InformationRegister.LichSuGiaoDichNganHang
	Query = New Query;
	Query.Text = 
		"SELECT
		|	Reg.IdempotencyKey,
		|	Reg.PayloadHash,
		|	Reg.TrangThaiXuLy
		|FROM
		|	InformationRegister.LichSuGiaoDichNganHang AS Reg
		|WHERE
		|	Reg.IdempotencyKey = &IdempotencyKey";
	Query.SetParameter("IdempotencyKey", IdempotencyKey);
	
	Result = Query.Execute().Unload();
	If Result.Count() > 0 Then
		ExistingRow = Result[0];
		If ExistingRow.PayloadHash = PayloadHash Then
			// Trung key + trung hash -> 200 OK (Already Processed)
			Response = New HTTPServiceResponse(200);
			Response.SetBodyFromString("Already Processed");
			Return Response;
		Else
			// Trung key + khac hash -> 409 Conflict
			Response = New HTTPServiceResponse(409);
			Response.SetBodyFromString("Conflict: Idempotency payload mismatch");
			Return Response;
		EndIf;
	EndIf;
	
	// 3. Xu ly Atomic Transaction
	BeginTransaction();
	Try
		// Ghi so LichSuGiaoDichNganHang
		RecordManager = InformationRegisters.LichSuGiaoDichNganHang.CreateRecordManager();
		RecordManager.IdempotencyKey = IdempotencyKey;
		RecordManager.PayloadHash = PayloadHash;
		RecordManager.MaGiaoDichNganHang = ?(PayloadData.Property("MaGiaoDich"), PayloadData.MaGiaoDich, IdempotencyKey);
		RecordManager.NgayGiaoDich = CurrentSessionDate();
		RecordManager.SoTien = ?(PayloadData.Property("SoTien"), PayloadData.SoTien, 0);
		RecordManager.TrangThaiXuLy = "ThanhCong";
		RecordManager.Write(True);
		
		// Tao chung tu BaoCoNganHang
		DocObj = Documents.BaoCoNganHang.CreateDocument();
		DocObj.Date = CurrentSessionDate();
		DocObj.NgayGiaoDich = CurrentSessionDate();
		DocObj.MaGiaoDichNganHang = RecordManager.MaGiaoDichNganHang;
		DocObj.SoTien = RecordManager.SoTien;
		
		If PayloadData.Property("NoiDung") Then
			DocObj.NoiDungChuyenKhoan = PayloadData.NoiDung;
		EndIf;
		If PayloadData.Property("VirtualAccount") Then
			DocObj.VirtualAccount = PayloadData.VirtualAccount;
		EndIf;
		
		// Kiem tra khop Tang 1 (Virtual Account)
		If Not IsBlankString(DocObj.VirtualAccount) Then
			// Tra cuu Virtual Account tren Catalog.TaiKhoanAo
			QueryVA = New Query;
			QueryVA.Text = 
				"SELECT
				|	Cat.Owner AS DoiTac,
				|	Cat.HopDong AS HopDong
				|FROM
				|	Catalog.TaiKhoanAo AS Cat
				|WHERE
				|	Cat.SoTaiKhoanAo = &VA";
			QueryVA.SetParameter("VA", DocObj.VirtualAccount);
			ResVA = QueryVA.Execute().Unload();
			
			If ResVA.Count() > 0 Then
				DocObj.DoiTacKhop = ResVA[0].DoiTac;
				DocObj.TuDongGhiSo = True;
				DocObj.TrangThai = "DaDoiSoat";
				DocObj.Write(DocumentWriteMode.Posting);
			Else
				DocObj.TrangThai = "ChoDoiSoat";
				DocObj.Write(DocumentWriteMode.Write);
			EndIf;
		Else
			DocObj.TrangThai = "ChoDoiSoat";
			DocObj.Write(DocumentWriteMode.Write);
		EndIf;
		
		CommitTransaction();
	Except
		RollbackTransaction();
		Response = New HTTPServiceResponse(500);
		Response.SetBodyFromString("Internal Server Error: " + ErrorDescription());
		Return Response;
	EndTry;
	
	Response = New HTTPServiceResponse(200);
	Response.SetBodyFromString("Success");
	Return Response;
EndFunction

#EndRegion
