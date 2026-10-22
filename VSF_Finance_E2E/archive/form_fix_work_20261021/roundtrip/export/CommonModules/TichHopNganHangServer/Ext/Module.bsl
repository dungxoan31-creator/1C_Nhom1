// Server-side HTTP adapter for outbound bank payment orders.
// Bank-specific authentication/signatures belong in a provider adapter; secrets are not stored here.

#Region Public

Function GuiLenhChiNganHang(Val PaymentRef) Export
	Result = New Structure("accepted,transaction_id,bank_status,http_code,error,request_id",
		False, "", "", 0, "", "");
	If Not ValueIsFilled(PaymentRef) Or TypeOf(PaymentRef) <> Type("DocumentRef.UyNhiemChi") Then
		Result.error = "A valid payment order reference is required.";
		Return Result;
	EndIf;

	Payment = PaymentRef.GetObject();
	If Payment.TrangThaiGuiNganHang = "ACCEPTED" And Not IsBlankString(Payment.MaGiaoDichNganHang) Then
		Result.accepted = True;
		Result.transaction_id = Payment.MaGiaoDichNganHang;
		Result.bank_status = Payment.TrangThaiGuiNganHang;
		Result.request_id = String(PaymentRef.UUID());
		Return Result;
	EndIf;
	If Payment.Posted Then
		Result.error = "A posted payment order cannot be submitted again.";
		Return Result;
	EndIf;
	If Payment.TrangThai <> Enums.TrangThaiLenhThanhToan.DaDuyet
		And Payment.TrangThai <> Enums.TrangThaiLenhThanhToan.DaGuiNganHang Then
		Result.error = "Only an approved payment order can be submitted to the bank.";
		Return Result;
	EndIf;
	If TypeOf(Payment.ChungTuGoc) <> Type("DocumentRef.HoaDonNhaCungCap") Or Not Payment.ChungTuGoc.Posted Then
		Result.error = "A bank payment requires a posted supplier invoice as its source document.";
		Return Result;
	EndIf;
	If Payment.DoiTac <> Payment.ChungTuGoc.DoiTac Or Payment.HopDong <> Payment.ChungTuGoc.HopDong
		Or Payment.PhapNhan <> Payment.ChungTuGoc.PhapNhan Or Payment.TienTe <> Payment.ChungTuGoc.TienTe Then
		Result.error = "Payment counterparty, contract, legal entity, and currency must match the posted supplier invoice.";
		Return Result;
	EndIf;
	If Not ValueIsFilled(Payment.TaiKhoanTien) Or Payment.TaiKhoanTien.DeletionMark
		Or Payment.TaiKhoanTien.TienTe <> Payment.TienTe Then
		Result.error = "The paying bank account is missing, deleted, or has a different currency.";
		Return Result;
	EndIf;
	If Payment.SoTien <= 0 Or IsBlankString(Payment.DoiTac.SoTaiKhoanNganHang)
		Or IsBlankString(Payment.DoiTac.TenNganHang) Then
		Result.error = "Positive payment amount and supplier bank details are required.";
		Return Result;
	EndIf;
	APBalanceQuery = New Query(
		"SELECT
		| ISNULL(SUM(SoTienBalance), 0) AS OpenVnd,
		| ISNULL(SUM(SoTienNgoaiTeBalance), 0) AS OpenForeign
		|FROM AccumulationRegister.CongNoPhaiTra.Balance(,
		| PhapNhan = &LegalEntity AND DoiTac = &Vendor AND HopDong = &Contract AND ChungTuGoc = &Invoice)");
	APBalanceQuery.SetParameter("LegalEntity", Payment.PhapNhan);
	APBalanceQuery.SetParameter("Vendor", Payment.DoiTac);
	APBalanceQuery.SetParameter("Contract", Payment.HopDong);
	APBalanceQuery.SetParameter("Invoice", Payment.ChungTuGoc);
	APBalance = APBalanceQuery.Execute().Unload()[0];
	If TrimAll(Upper(String(Payment.TienTe.Code))) = "VND" Then
		If Payment.SoTien > APBalance.OpenVnd Then
			Result.error = "Payment amount exceeds the remaining VND payable balance.";
			Result.bank_status = "PAYABLE_BALANCE_REJECTED";
			Return Result;
		EndIf;
	ElsIf Payment.SoTienNgoaiTe <= 0 Or Payment.SoTienNgoaiTe > APBalance.OpenForeign Then
		Result.error = "Foreign payment amount exceeds the remaining original-currency payable balance.";
		Result.bank_status = "PAYABLE_BALANCE_REJECTED";
		Return Result;
	EndIf;
	BankAccount = Payment.TaiKhoanTien;
	Host = TrimAll(BankAccount.BankApiHost);
	Path = TrimAll(BankAccount.BankApiPath);
	Port = BankAccount.BankApiPort;
	TimeoutSeconds = BankAccount.BankApiTimeoutSeconds;
	If IsBlankString(Host) Or IsBlankString(Path) Or Port <= 0 Then
		Result.error = "The bank HTTP endpoint is not configured on the paying account.";
		Result.bank_status = "NOT_CONFIGURED";
		Return Result;
	EndIf;
	If Left(Path, 1) <> "/" Then Path = "/" + Path; EndIf;
	If TimeoutSeconds <= 0 Then TimeoutSeconds = 10; EndIf;
	RequestId = String(PaymentRef.UUID());
	Result.request_id = RequestId;

	Payload = New Structure;
	Payload.Insert("requestId", RequestId);
	Payload.Insert("clientReference", Payment.Number);
	Payload.Insert("currency", Payment.TienTe.Code);
	Payload.Insert("amountVnd", Payment.SoTien);
	Payload.Insert("amountForeign", Payment.SoTienNgoaiTe);
	Payload.Insert("payerAccount", BankAccount.SoTaiKhoan);
	Payload.Insert("beneficiaryName", Payment.DoiTac.Description);
	Payload.Insert("beneficiaryAccount", Payment.DoiTac.SoTaiKhoanNganHang);
	Payload.Insert("beneficiaryBank", Payment.DoiTac.TenNganHang);
	Payload.Insert("purpose", Payment.DienGiai);

	Writer = New JSONWriter;
	Writer.SetString();
	WriteJSON(Writer, Payload);
	RequestBody = Writer.Close();

	Try
		If BankAccount.BankApiUseTLS Then
			SecureConnection = New OpenSSLSecureConnection();
			Connection = New HTTPConnection(Host, Port, , , , TimeoutSeconds, SecureConnection);
		Else
			Connection = New HTTPConnection(Host, Port, , , , TimeoutSeconds);
		EndIf;
		RequestHeaders = New Map;
		RequestHeaders.Insert("Accept", "application/json");
		RequestHeaders.Insert("Content-Type", "application/json; charset=utf-8");
		RequestHeaders.Insert("Idempotency-Key", RequestId);
		Request = New HTTPRequest(Path, RequestHeaders);
		Request.SetBodyFromString(RequestBody, TextEncoding.UTF8, ByteOrderMarkUsage.DontUse);
		Response = Connection.Post(Request);
		Result.http_code = Response.StatusCode;
		ResponseBody = Response.GetBodyAsString("UTF-8");
		If Response.StatusCode < 200 Or Response.StatusCode >= 300 Then
			Result.bank_status = "HTTP_REJECTED";
			Result.error = StrTemplate("Bank gateway returned HTTP %1.", Response.StatusCode);
			WriteLogEvent("BankIntegration.PaymentSubmission", EventLogLevel.Error,,, RequestId + ": " + Result.error);
			Return Result;
		EndIf;

		Reader = New JSONReader;
		Reader.SetString(ResponseBody);
		BankResponse = ReadJSON(Reader);
		Reader.Close();
		If TypeOf(BankResponse) <> Type("Structure") Then
			Result.bank_status = "INVALID_RESPONSE";
			Result.error = "Bank gateway response is not a JSON object.";
			Return Result;
		EndIf;
		BankStatus = "";
		TransactionId = "";
		If Not BankResponse.Property("status", BankStatus)
			Or Not BankResponse.Property("transactionId", TransactionId) Then
			Result.bank_status = "INVALID_RESPONSE";
			Result.error = "Bank gateway response is missing status or transactionId.";
			WriteLogEvent("BankIntegration.PaymentSubmission", EventLogLevel.Error,,, RequestId + ": " + Result.error);
			Return Result;
		EndIf;
		Result.bank_status = Upper(TrimAll(String(BankStatus)));
		Result.transaction_id = TrimAll(String(TransactionId));
		If Result.bank_status <> "ACCEPTED" Or IsBlankString(Result.transaction_id) Then
			Result.error = "Bank gateway did not confirm acceptance with a transaction identifier.";
			WriteLogEvent("BankIntegration.PaymentSubmission", EventLogLevel.Error,,, RequestId + ": " + Result.error);
			Return Result;
		EndIf;

		Result.accepted = True;
	Except
		Result.bank_status = "TRANSPORT_ERROR";
		Result.error = DetailErrorDescription(ErrorInfo());
		WriteLogEvent("BankIntegration.PaymentSubmission", EventLogLevel.Error,,, RequestId + ": " + Result.error);
	EndTry;
	Return Result;
EndFunction

// Confirm an incoming full supplier refund against the bank's transaction feed.
// Refund receipts are credits to the company bank account; they are never sent as outgoing payments.
Function XacNhanHoanTienNganHang(Val RefundRef) Export
	Result = New Structure("accepted,transaction_id,bank_status,http_code,error,request_id",
		False, "", "", 0, "", "");
	If PhanQuyenBaoMatServer.LaPhienQuanTriHeThong() Or Not IsInRole("GiamDocTaiChinh_CFO") Then
		Result.error = "Only a non-admin CFO can confirm an incoming supplier refund.";
		Return Result;
	EndIf;
	If Not ValueIsFilled(RefundRef) Or TypeOf(RefundRef) <> Type("DocumentRef.UyNhiemChi") Or RefundRef.DeletionMark Then
		Result.error = "A valid, non-deleted refund document reference is required.";
		Return Result;
	EndIf;

	Refund = RefundRef.GetObject();
	If Not Refund.LaTraSoatHoanTra Or Refund.Posted Then
		Result.error = "Only an unposted refund/reversal document can be confirmed.";
		Return Result;
	EndIf;
	If Refund.TrangThai = Enums.TrangThaiLenhThanhToan.DaNhanHoanTien
		And Refund.TrangThaiGuiNganHang = "REFUND_RECEIVED" And Not IsBlankString(Refund.MaGiaoDichNganHang) Then
		Result.accepted = True;
		Result.transaction_id = Refund.MaGiaoDichNganHang;
		Result.bank_status = Refund.TrangThaiGuiNganHang;
		Result.request_id = String(Refund.ChungTuGoc.UUID());
		Return Result;
	EndIf;
	If Refund.TrangThai <> Enums.TrangThaiLenhThanhToan.DaDuyet Then
		Result.error = "A refund must be approved by the Chief Accountant before bank confirmation.";
		Return Result;
	EndIf;
	If TypeOf(Refund.ChungTuGoc) <> Type("DocumentRef.UyNhiemChi") Or Not Refund.ChungTuGoc.Posted
		Or Refund.ChungTuGoc.LaTraSoatHoanTra Then
		Result.error = "Refund confirmation requires the posted original supplier payment.";
		Return Result;
	EndIf;

	OriginalPayment = Refund.ChungTuGoc.GetObject();
	If OriginalPayment.TrangThaiGuiNganHang <> "ACCEPTED" Or IsBlankString(OriginalPayment.MaGiaoDichNganHang) Then
		Result.error = "The original payment must have a confirmed bank transaction before a refund can be matched.";
		Return Result;
	EndIf;
	If Refund.PhapNhan <> OriginalPayment.PhapNhan Or Refund.DoiTac <> OriginalPayment.DoiTac
		Or Refund.HopDong <> OriginalPayment.HopDong Or Refund.TaiKhoanTien <> OriginalPayment.TaiKhoanTien
		Or Refund.TienTe <> OriginalPayment.TienTe Or Refund.SoTien <> OriginalPayment.SoTien
		Or Refund.SoTienNgoaiTe <> OriginalPayment.SoTienNgoaiTe Then
		Result.error = "Refund legal entity, vendor, contract, bank account, currency, and full amount must match the original payment.";
		Return Result;
	EndIf;
	DuplicateQuery = New Query(
		"SELECT TOP 1 Ref FROM Document.UyNhiemChi
		|WHERE LaTraSoatHoanTra = TRUE AND ChungTuGoc = &OriginalPayment AND Ref <> &CurrentRefund AND Posted = TRUE");
	DuplicateQuery.SetParameter("OriginalPayment", Refund.ChungTuGoc);
	DuplicateQuery.SetParameter("CurrentRefund", RefundRef);
	If Not DuplicateQuery.Execute().IsEmpty() Then
		Result.bank_status = "DUPLICATE_REFUND";
		Result.error = "The original payment already has a posted refund.";
		Return Result;
	EndIf;

	BankAccount = Refund.TaiKhoanTien;
	Host = TrimAll(BankAccount.BankApiHost);
	Path = TrimAll(BankAccount.BankRefundConfirmationPath);
	Port = BankAccount.BankApiPort;
	TimeoutSeconds = BankAccount.BankApiTimeoutSeconds;
	If IsBlankString(Host) Or IsBlankString(Path) Or Port <= 0 Then
		Result.error = "The bank refund confirmation endpoint is not configured on the paying account.";
		Result.bank_status = "NOT_CONFIGURED";
		Return Result;
	EndIf;
	If Left(Path, 1) <> "/" Then Path = "/" + Path; EndIf;
	If TimeoutSeconds <= 0 Then TimeoutSeconds = 10; EndIf;

	// A single original payment can be fully refunded once. Use the original payment UUID
	// as the idempotency key so duplicate refund documents bind to the same bank credit.
	RequestId = String(Refund.ChungTuGoc.UUID());
	Result.request_id = RequestId;
	Payload = New Structure;
	Payload.Insert("operation", "confirm_supplier_refund_receipt");
	Payload.Insert("requestId", RequestId);
	Payload.Insert("refundReference", Refund.Number);
	Payload.Insert("sourcePaymentReference", OriginalPayment.Number);
	Payload.Insert("sourceBankTransactionId", OriginalPayment.MaGiaoDichNganHang);
	Payload.Insert("currency", Refund.TienTe.Code);
	Payload.Insert("amountVnd", Refund.SoTien);
	Payload.Insert("amountForeign", Refund.SoTienNgoaiTe);
	Payload.Insert("payerAccount", BankAccount.SoTaiKhoan);
	Payload.Insert("beneficiaryAccount", Refund.DoiTac.SoTaiKhoanNganHang);
	Writer = New JSONWriter;
	Writer.SetString();
	WriteJSON(Writer, Payload);
	RequestBody = Writer.Close();

	Try
		If BankAccount.BankApiUseTLS Then
			SecureConnection = New OpenSSLSecureConnection();
			Connection = New HTTPConnection(Host, Port, , , , TimeoutSeconds, SecureConnection);
		Else
			Connection = New HTTPConnection(Host, Port, , , , TimeoutSeconds);
		EndIf;
		RequestHeaders = New Map;
		RequestHeaders.Insert("Accept", "application/json");
		RequestHeaders.Insert("Content-Type", "application/json; charset=utf-8");
		RequestHeaders.Insert("Idempotency-Key", RequestId);
		Request = New HTTPRequest(Path, RequestHeaders);
		Request.SetBodyFromString(RequestBody, TextEncoding.UTF8, ByteOrderMarkUsage.DontUse);
		Response = Connection.Post(Request);
		Result.http_code = Response.StatusCode;
		ResponseBody = Response.GetBodyAsString("UTF-8");
		If Response.StatusCode < 200 Or Response.StatusCode >= 300 Then
			Result.bank_status = "HTTP_REJECTED";
			Result.error = StrTemplate("Bank gateway rejected refund confirmation with HTTP %1.", Response.StatusCode);
			WriteLogEvent("BankIntegration.RefundConfirmation", EventLogLevel.Error,,, RequestId + ": " + Result.error);
			Return Result;
		EndIf;
		Reader = New JSONReader;
		Reader.SetString(ResponseBody);
		BankResponse = ReadJSON(Reader);
		Reader.Close();
		If TypeOf(BankResponse) <> Type("Structure") Then
			Result.bank_status = "INVALID_RESPONSE";
			Result.error = "Bank refund confirmation response is not a JSON object.";
			Return Result;
		EndIf;
		BankStatus = "";
		TransactionId = "";
		If Not BankResponse.Property("status", BankStatus) Or Not BankResponse.Property("transactionId", TransactionId) Then
			Result.bank_status = "INVALID_RESPONSE";
			Result.error = "Bank refund confirmation response is missing status or transactionId.";
			WriteLogEvent("BankIntegration.RefundConfirmation", EventLogLevel.Error,,, RequestId + ": " + Result.error);
			Return Result;
		EndIf;
		Result.bank_status = Upper(TrimAll(String(BankStatus)));
		Result.transaction_id = TrimAll(String(TransactionId));
		If Result.bank_status <> "REFUND_RECEIVED" Or IsBlankString(Result.transaction_id) Then
			Result.error = "Bank did not confirm a credited refund transaction.";
			WriteLogEvent("BankIntegration.RefundConfirmation", EventLogLevel.Error,,, RequestId + ": " + Result.error);
			Return Result;
		EndIf;

		// The incoming bank confirmation is the CFO-controlled checker step after KTT approval.
		// Assign the real session user before saving so the central Maker-Checker guard
		// authorizes this transition and the following posting retains the CFO checker.
		ChiefAccountant = Refund.NguoiDuyet;
		Refund.NguoiDuyet = UserName();
		Refund.TrangThaiGuiNganHang = Result.bank_status;
		Refund.MaGiaoDichNganHang = Result.transaction_id;
		Refund.ThoiDiemGuiNganHang = CurrentSessionDate();
		Refund.TrangThai = Enums.TrangThaiLenhThanhToan.DaNhanHoanTien;
		Refund.Write();
		SavedRefund = RefundRef.GetObject();
		If SavedRefund.TrangThai <> Enums.TrangThaiLenhThanhToan.DaNhanHoanTien
			Or SavedRefund.TrangThaiGuiNganHang <> "REFUND_RECEIVED" Then
			Result.error = "Bank receipt was confirmed but the refund workflow state did not persist.";
			WriteLogEvent("BankIntegration.RefundConfirmation", EventLogLevel.Error,,, RequestId + ": " + Result.error);
			Return Result;
		EndIf;
		Result.accepted = True;
		WriteLogEvent("BankIntegration.RefundConfirmation", EventLogLevel.Information,,, StrTemplate(
			"%1: KTT=%2; CFO=%3; bank transaction=%4", RequestId, ChiefAccountant, UserName(), Result.transaction_id));
	Except
		Result.bank_status = "TRANSPORT_OR_PERSISTENCE_ERROR";
		Result.error = DetailErrorDescription(ErrorInfo());
		WriteLogEvent("BankIntegration.RefundConfirmation", EventLogLevel.Error,,, RequestId + ": " + Result.error);
	EndTry;
	Return Result;
EndFunction

#EndRegion
