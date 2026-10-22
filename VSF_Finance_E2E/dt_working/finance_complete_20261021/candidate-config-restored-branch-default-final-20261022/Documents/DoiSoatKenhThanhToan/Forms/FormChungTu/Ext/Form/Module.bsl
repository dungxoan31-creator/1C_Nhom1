#Region FormEventHandlers

&AtClient
Procedure OnOpen(Cancel)
	If Not ValueIsFilled(CsvDelimiter) Then CsvDelimiter = ","; EndIf;
	If Not ValueIsFilled(CsvDecimalSeparator) Then CsvDecimalSeparator = "."; EndIf;
	If Not ValueIsFilled(CsvThousandsSeparator) Then CsvThousandsSeparator = ","; EndIf;
	If Not ValueIsFilled(CsvColumnExternalId) Then CsvColumnExternalId = "ExternalId"; EndIf;
	If Not ValueIsFilled(CsvColumnTransactionDate) Then CsvColumnTransactionDate = "TransactionDate"; EndIf;
	If Not ValueIsFilled(CsvColumnInvoiceNumber) Then CsvColumnInvoiceNumber = "InvoiceNumber"; EndIf;
	If Not ValueIsFilled(CsvColumnMemo) Then CsvColumnMemo = "Memo"; EndIf;
	If Not ValueIsFilled(CsvColumnGross) Then CsvColumnGross = "Gross"; EndIf;
	If Not ValueIsFilled(CsvColumnFee) Then CsvColumnFee = "Fee"; EndIf;
	If Not ValueIsFilled(CsvColumnNet) Then CsvColumnNet = "Net"; EndIf;
	If Not ValueIsFilled(CsvColumnCurrency) Then CsvColumnCurrency = "Currency"; EndIf;
EndProcedure

#EndRegion

#Region FormCommands

&AtClient
Procedure ChonTepCSV(Command)
	CSVDialog = New FileDialog(FileDialogMode.Open);
	CSVDialog.Title = "Select a bank or payment gateway CSV statement";
	CSVDialog.Filter = "CSV files (*.csv)|*.csv|All files (*.*)|*.*";
	CSVDialog.Multiselect = False;
	CSVDialog.Show(New NotifyDescription("CSVFileSelected", ThisForm));
EndProcedure

&AtClient
Procedure CSVFileSelected(SelectedFiles, AdditionalParameters) Export
	If Not ValueIsFilled(SelectedFiles) Or SelectedFiles.Count() = 0 Then Return; EndIf;
	CsvFileName = SelectedFiles[0];
	CSVTextDocument = New TextDocument;
	Try
		CSVTextDocument.Read(CsvFileName);
		CsvText = CSVTextDocument.GetText();
		CsvPreviewSummary = "CSV loaded. Review the column mapping and click Preview.";
	Except
		CsvText = "";
		CsvPreviewSummary = "CSV could not be read: " + BriefErrorDescription(ErrorInfo());
	EndTry;
EndProcedure

&AtClient
Procedure XemTruocCSV(Command)
	If StrLen(CsvText) = 0 Then
		CsvPreviewSummary = "Choose a CSV file before previewing.";
		Return;
	EndIf;
	PreviewCSVAtServer();
EndProcedure

&AtServer
Procedure PreviewCSVAtServer()
	ColumnMap = New Structure;
	If StrLen(TrimAll(CsvColumnExternalId)) > 0 Then ColumnMap.Insert("ExternalId", TrimAll(CsvColumnExternalId)); EndIf;
	ColumnMap.Insert("TransactionDate", TrimAll(CsvColumnTransactionDate));
	If StrLen(TrimAll(CsvColumnInvoiceNumber)) > 0 Then ColumnMap.Insert("InvoiceNumber", TrimAll(CsvColumnInvoiceNumber)); EndIf;
	ColumnMap.Insert("Memo", TrimAll(CsvColumnMemo));
	ColumnMap.Insert("Gross", TrimAll(CsvColumnGross));
	ColumnMap.Insert("Fee", TrimAll(CsvColumnFee));
	ColumnMap.Insert("Net", TrimAll(CsvColumnNet));
	ColumnMap.Insert("Currency", TrimAll(CsvColumnCurrency));

	ParseResult = NhapSaoKeCsvServer.ParseCSVRows(CsvText, ColumnMap, CsvDelimiter, CsvDecimalSeparator, CsvThousandsSeparator);
	Объект.GiaoDichSaoKe.Clear();
	ValidCount = 0;
	ErrorCount = 0;
	DuplicateCount = 0;
	UnmatchedCount = 0;
	PN = Объект.PhapNhan;
	CashAccount = Объект.TaiKhoanTien;
	Channel = Объект.KenhThanhToan;

	For Each ParsedRow In ParseResult.Rows Do
		Line = Объект.GiaoDichSaoKe.Add();
		Line.ExternalId = ParsedRow.ExternalId;
		Line.InvoiceNumber = ParsedRow.InvoiceNumber;
		Line.NgayGiaoDich = ParsedRow.TransactionDate;
		Line.DienGiaiDong = ParsedRow.Memo;
		Line.Gross = ParsedRow.Gross;
		Line.Phi = ParsedRow.Fee;
		Line.Net = ParsedRow.Net;
		Line.SoTienGhep = 0;
		Line.TrangThaiDong = ParsedRow.Status;
		Line.LyDoChan = ParsedRow.Reason;

		CurrencyRef = Catalogs.TienTe.FindByCode(ParsedRow.Currency);
		Line.TienTeDong = CurrencyRef;
		If ParsedRow.Status = "Invalid" Or ParsedRow.Status = "Duplicate" Then
			If ParsedRow.Status = "Duplicate" Then DuplicateCount = DuplicateCount + 1; Else ErrorCount = ErrorCount + 1; EndIf;
			Continue;
		EndIf;
		If Not ValueIsFilled(CurrencyRef) Then
			Line.TrangThaiDong = "Invalid";
			Line.LyDoChan = "Unknown currency code: " + ParsedRow.Currency;
			ErrorCount = ErrorCount + 1;
			Continue;
		EndIf;
		If Not ValueIsFilled(PN) Or Not ValueIsFilled(CashAccount) Or StrLen(TrimAll(Channel)) = 0 Then
			Line.TrangThaiDong = "Invalid";
			Line.LyDoChan = "Set legal entity, bank account, and payment channel before previewing.";
			ErrorCount = ErrorCount + 1;
			Continue;
		EndIf;
		Line.KhoaGiaoDich = NhapSaoKeCsvServer.CreateTransactionKey(PN, CashAccount, Channel, ParsedRow.ExternalId, ParsedRow.TransactionDate, CurrencyRef, ParsedRow.Gross, ParsedRow.Memo);
		If StrLen(Line.KhoaGiaoDich) = 0 Then
			Line.TrangThaiDong = "Invalid";
			Line.LyDoChan = "Could not create a stable transaction identity.";
			ErrorCount = ErrorCount + 1;
			Continue;
		EndIf;
		If CurrencyRef.Code <> "VND" Or CurrencyRef <> Объект.TienTe Or CashAccount.TienTe <> CurrencyRef Then
			Line.TrangThaiDong = "Invalid";
			Line.LyDoChan = "Only VND statement rows matching the selected bank account are supported.";
			ErrorCount = ErrorCount + 1;
			Continue;
		EndIf;
		If IsStatementKeyAlreadyPosted(PN, CashAccount, Channel, Line.KhoaGiaoDich) Then
			Line.TrangThaiDong = "Duplicate";
			Line.LyDoChan = "This transaction key was already posted in another reconciliation.";
			DuplicateCount = DuplicateCount + 1;
			Continue;
		EndIf;
		For Each EarlierLine In Объект.GiaoDichSaoKe Do
			If EarlierLine.LineNumber < Line.LineNumber And EarlierLine.KhoaGiaoDich = Line.KhoaGiaoDich Then
				Line.TrangThaiDong = "Duplicate";
				Line.LyDoChan = "Duplicate transaction fingerprint in this file.";
				Break;
			EndIf;
		EndDo;
		If Line.TrangThaiDong = "Duplicate" Then
			DuplicateCount = DuplicateCount + 1;
			Continue;
		EndIf;

		If StrLen(TrimAll(Line.InvoiceNumber)) > 0 Then
			InvoiceRef = FindIssuedInvoiceByNumber(Line.InvoiceNumber);
			If ValueIsFilled(InvoiceRef) Then
				Line.HoaDonAR = InvoiceRef;
				Line.TrangThaiDong = "GoiY";
				Line.LyDoChan = "Invoice number from CSV is a suggestion. Check the invoice and click Confirm AR match.";
			Else
				Line.TrangThaiDong = "ChuaGhep";
				Line.LyDoChan = "No issued AR invoice matched the source invoice number; select one manually.";
			EndIf;
		Else
			Line.TrangThaiDong = "ChuaGhep";
			Line.LyDoChan = "Select an issued AR invoice; amount-only matching is not used.";
		EndIf;
		ValidCount = ValidCount + 1;
		UnmatchedCount = UnmatchedCount + 1;
	EndDo;

	GrossTotal = 0;
	FeeTotal = 0;
	NetTotal = 0;
	For Each ValidLine In Объект.GiaoDichSaoKe Do
		If ValidLine.TrangThaiDong = "GoiY" Or ValidLine.TrangThaiDong = "ChuaGhep" Then
			GrossTotal = GrossTotal + ValidLine.Gross;
			FeeTotal = FeeTotal + ValidLine.Phi;
			NetTotal = NetTotal + ValidLine.Net;
		EndIf;
	EndDo;
	Объект.TongTienGiaoDich = GrossTotal;
	Объект.TongPhi = FeeTotal;
	Объект.TongTienThucNhan = NetTotal;
	If ParseResult.Errors.Count() > 0 Then
		FirstError = ParseResult.Errors[0];
		CsvPreviewSummary = StrTemplate("Rows: %1 valid, %2 invalid, %3 duplicates, %4 unmatched. CSV line %5 (%6): %7",
			ValidCount, ErrorCount, DuplicateCount, UnmatchedCount, FirstError.LineNumber, FirstError.FieldName, FirstError.Message);
	Else
		CsvPreviewSummary = StrTemplate("Rows: %1 valid, %2 invalid, %3 duplicates, %4 unmatched. Confirm each invoice match before posting.",
			ValidCount, ErrorCount, DuplicateCount, UnmatchedCount);
	EndIf;
EndProcedure

&AtClient
Procedure GhepHoaDonAR(Command)
	ConfirmARMatchesAtServer();
EndProcedure

&AtServer
Procedure ConfirmARMatchesAtServer()
	ConfirmedCount = 0;
	BlockedCount = 0;
	For Each Line In Объект.GiaoDichSaoKe Do
		Line.SoTienGhep = 0;
		If Line.TrangThaiDong = "Invalid" Or Line.TrangThaiDong = "Duplicate" Then
			BlockedCount = BlockedCount + 1;
			Continue;
		EndIf;
		Reason = ValidateARMatch(Line, False);
		If StrLen(Reason) > 0 Then
			Line.TrangThaiDong = "ChuaGhep";
			Line.LyDoChan = Reason;
			BlockedCount = BlockedCount + 1;
			Continue;
		EndIf;
		Line.SoTienGhep = Line.Gross;
		Line.TrangThaiDong = "DaGhep";
		Line.LyDoChan = "Confirmed against an issued invoice with an open balance.";
		ConfirmedCount = ConfirmedCount + 1;
	EndDo;
	CsvPreviewSummary = StrTemplate("AR matches confirmed: %1. Rows still blocked or unmatched: %2. Posting checks all balances again.", ConfirmedCount, BlockedCount);
EndProcedure

&AtClient
Procedure CsvLineInvoiceOnChange(Element)
	CurrentLine = Items.GiaoDichSaoKe.CurrentData;
	If CurrentLine <> Undefined Then
		CurrentLine.SoTienGhep = 0;
		CurrentLine.TrangThaiDong = "ChuaXacNhan";
		CurrentLine.LyDoChan = "Invoice selection changed. Confirm the match again.";
	EndIf;
EndProcedure

#EndRegion

#Region ServerHelpers

&AtServerNoContext
Function IsStatementKeyAlreadyPosted(Val LegalEntity, Val CashAccount, Val Channel, Val TransactionKey)
	Query = New Query(
		"SELECT TOP 1 KhoaGiaoDich
		|FROM InformationRegister.GiaoDichSaoKeDaNhap
		|WHERE PhapNhan = &PN AND TaiKhoanTien = &Cash AND KenhThanhToan = &Channel AND KhoaGiaoDich = &Key");
	Query.SetParameter("PN", LegalEntity);
	Query.SetParameter("Cash", CashAccount);
	Query.SetParameter("Channel", Channel);
	Query.SetParameter("Key", TransactionKey);
	Return Not Query.Execute().IsEmpty();
EndFunction

&AtServerNoContext
Function FindIssuedInvoiceByNumber(Val InvoiceNumber)
	Query = New Query(
		"SELECT TOP 1 Ref
		|FROM Document.HoaDonGTGTDauRa
		|WHERE Number = &InvoiceNumber AND Posted AND TrangThaiHDDT = VALUE(Enum.TrangThaiHoaDonDienTu.DaPhatHanh)");
	Query.SetParameter("InvoiceNumber", InvoiceNumber);
	Rows = Query.Execute().Unload();
	If Rows.Count() = 0 Then Return Undefined; EndIf;
	Return Rows[0].Ref;
EndFunction

&AtServerNoContext
Function GetAROpenBalance(Val Invoice)
	Query = New Query(
		"SELECT ISNULL(SUM(SoTienBalance), 0) AS Balance
		|FROM AccumulationRegister.CongNoPhaiThu.Balance(,
		| PhapNhan = &PN AND DoiTac = &Partner AND HopDong = &Contract AND ChungTuGoc = &Source)");
	Query.SetParameter("PN", Invoice.PhapNhan);
	Query.SetParameter("Partner", Invoice.DoiTac);
	Query.SetParameter("Contract", Invoice.HopDong);
	Query.SetParameter("Source", Invoice.Ref);
	Return Query.Execute().Unload()[0].Balance;
EndFunction

&AtServer
Function ValidateARMatch(Val Line, Val ForPosting)
	If Not ValueIsFilled(Line.HoaDonAR) Then Return "Select an issued AR invoice."; EndIf;
	If Line.Gross <= 0 Or Line.Fee < 0 Or Line.Net <= 0 Or Round(Line.Gross, 2) <> Round(Line.Fee + Line.Net, 2) Then
		Return "Gross must equal fee plus net; gross and net must be positive.";
	EndIf;
	If Line.SoTienGhep > 0 And Round(Line.SoTienGhep, 2) <> Round(Line.Gross, 2) Then
		Return "Matched amount must equal this transaction gross amount.";
	EndIf;
	If Line.TienTeDong.Code <> "VND" Or Line.TienTeDong <> Объект.TienTe Then Return "Statement and document currencies must both be VND."; EndIf;
	Invoice = Line.HoaDonAR.GetObject();
	If Invoice.DeletionMark Or Not Invoice.Posted Or Invoice.TrangThaiHDDT <> Enums.TrangThaiHoaDonDienTu.DaPhatHanh Then
		Return "Only an active, posted, issued AR invoice can be matched.";
	EndIf;
	If Invoice.PhapNhan <> Объект.PhapNhan Then Return "Invoice legal entity differs from the statement."; EndIf;
	If Invoice.TienTe <> Line.TienTeDong Then Return "Invoice currency differs from the statement."; EndIf;
	If Not ValueIsFilled(Invoice.HopDong) Or Not ValueIsFilled(Invoice.DoiTac) Then Return "Invoice must have a partner and contract."; EndIf;
	OpenBalance = GetAROpenBalance(Invoice);
	If OpenBalance <= 0 Then Return "Invoice has no positive outstanding AR balance."; EndIf;
	If Line.Gross > OpenBalance Then Return StrTemplate("Gross %1 exceeds invoice open balance %2.", Line.Gross, OpenBalance); EndIf;
	Return "";
EndFunction

#EndRegion

#Region ExistingCommands

&AtClient
Procedure OpenRegisterRecords(Command)
	Items.Pages.CurrentPage = Items.Find("RegisterRecordsTab");
EndProcedure

#EndRegion
