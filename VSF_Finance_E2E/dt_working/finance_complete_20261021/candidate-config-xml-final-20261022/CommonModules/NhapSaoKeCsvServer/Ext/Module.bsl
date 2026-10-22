
// Nhập sao kê CSV có ánh xạ cột tường minh và chuẩn hóa giao dịch trước khi ghi sổ.

Function ParseCSVRows(Val CSVText, Val ColumnMap, Val Delimiter, Val DecimalSeparator, Val ThousandsSeparator) Export
	Rows = New ValueTable;
	Rows.Columns.Add("LineNumber");
	Rows.Columns.Add("ExternalId");
	Rows.Columns.Add("TransactionDate");
	Rows.Columns.Add("InvoiceNumber");
	Rows.Columns.Add("Memo");
	Rows.Columns.Add("Currency");
	Rows.Columns.Add("Gross");
	Rows.Columns.Add("Fee");
	Rows.Columns.Add("Net");
	Rows.Columns.Add("Status");
	Rows.Columns.Add("Reason");
	Errors = New ValueTable;
	Errors.Columns.Add("LineNumber");
	Errors.Columns.Add("FieldName");
	Errors.Columns.Add("Message");
	Result = New Structure("Rows,Errors", Rows, Errors);

	If StrLen(Delimiter) <> 1 Then
		AddCSVError(Errors, 1, "Delimiter", "Delimiter must contain exactly one character.");
		Return Result;
	EndIf;
	If StrLen(DecimalSeparator) <> 1 Then
		AddCSVError(Errors, 1, "DecimalSeparator", "Decimal separator must contain exactly one character.");
		Return Result;
	EndIf;
	If StrLen(ThousandsSeparator) > 1 Or DecimalSeparator = ThousandsSeparator Then
		AddCSVError(Errors, 1, "ThousandsSeparator", "Thousands and decimal separators must be distinct single characters.");
		Return Result;
	EndIf;

	ParsedRecords = ParseCSVRecords(CSVText, Delimiter);
	If ParsedRecords.UnclosedQuote Then
		AddCSVError(Errors, ParsedRecords.LastLine, "CSV", "CSV text ends inside a quoted field.");
		Return Result;
	EndIf;
	If ParsedRecords.Rows.Count() < 2 Then
		AddCSVError(Errors, 1, "CSV", "CSV must contain a header and at least one data row.");
		Return Result;
	EndIf;

	HeaderRecord = ParsedRecords.Rows[0];
	HeaderCells = HeaderRecord.Cells;
	For Index = 0 To HeaderCells.Count() - 1 Do
		For OtherIndex = 0 To Index - 1 Do
			If Upper(TrimAll(HeaderCells[Index])) = Upper(TrimAll(HeaderCells[OtherIndex])) Then
				AddCSVError(Errors, HeaderRecord.LineNumber, "Header", "Duplicate CSV header: " + HeaderCells[Index]);
				Return Result;
			EndIf;
		EndDo;
	EndDo;

	HeaderIndices = New Structure;
	RequiredFields = New Array;
	RequiredFields.Add("TransactionDate");
	RequiredFields.Add("Memo");
	RequiredFields.Add("Currency");
	RequiredFields.Add("Gross");
	RequiredFields.Add("Fee");
	RequiredFields.Add("Net");
	HasMissingHeader = False;
	For Each FieldName In RequiredFields Do
		HeaderName = "";
		If Not ColumnMap.Property(FieldName, HeaderName) Or StrLen(TrimAll(HeaderName)) = 0 Then
			AddCSVError(Errors, 1, FieldName, "A source header mapping is required.");
			HasMissingHeader = True;
			Continue;
		EndIf;
		HeaderIndex = FindCSVHeaderIndex(HeaderCells, HeaderName);
		If HeaderIndex < 0 Then
			AddCSVError(Errors, 1, FieldName, "Mapped CSV header was not found: " + HeaderName);
			HasMissingHeader = True;
			Continue;
		EndIf;
		HeaderIndices.Insert(FieldName, HeaderIndex);
	EndDo;

	OptionalFields = New Array;
	OptionalFields.Add("ExternalId");
	OptionalFields.Add("InvoiceNumber");
	For Each FieldName In OptionalFields Do
		HeaderName = "";
		If ColumnMap.Property(FieldName, HeaderName) And StrLen(TrimAll(HeaderName)) > 0 Then
			HeaderIndex = FindCSVHeaderIndex(HeaderCells, HeaderName);
			If HeaderIndex < 0 Then
				AddCSVError(Errors, 1, FieldName, "Mapped optional CSV header was not found: " + HeaderName);
				HasMissingHeader = True;
			Else
				HeaderIndices.Insert(FieldName, HeaderIndex);
			EndIf;
		EndIf;
	EndDo;
	If HasMissingHeader Then
		Return Result;
	EndIf;

	SeenExternalIds = New Array;
	For RecordIndex = 1 To ParsedRecords.Rows.Count() - 1 Do
		SourceRecord = ParsedRecords.Rows[RecordIndex];
		Cells = SourceRecord.Cells;
		If Cells.Count() = 1 And StrLen(TrimAll(Cells[0])) = 0 Then
			Continue;
		EndIf;
		Row = Rows.Add();
		Row.LineNumber = SourceRecord.LineNumber;
		Row.ExternalId = GetMappedCSVValue(Cells, HeaderIndices, "ExternalId");
		Row.InvoiceNumber = GetMappedCSVValue(Cells, HeaderIndices, "InvoiceNumber");
		Row.Memo = TrimAll(GetMappedCSVValue(Cells, HeaderIndices, "Memo"));
		Row.Currency = Upper(TrimAll(GetMappedCSVValue(Cells, HeaderIndices, "Currency")));
		Row.Status = "Valid";
		Row.Reason = "";

		DateIsValid = False;
		Row.TransactionDate = ParseCSVDate(GetMappedCSVValue(Cells, HeaderIndices, "TransactionDate"), DateIsValid);
		If Not DateIsValid Then
			MarkCSVRowError(Row, Errors, "TransactionDate", "Invalid date. Use YYYY-MM-DD or DD/MM/YYYY.");
		EndIf;
		GrossIsValid = False;
		Row.Gross = ParseCSVAmount(GetMappedCSVValue(Cells, HeaderIndices, "Gross"), DecimalSeparator, ThousandsSeparator, GrossIsValid);
		If Not GrossIsValid Then
			MarkCSVRowError(Row, Errors, "Gross", "Invalid gross amount for the selected number separators.");
		EndIf;
		FeeIsValid = False;
		Row.Fee = ParseCSVAmount(GetMappedCSVValue(Cells, HeaderIndices, "Fee"), DecimalSeparator, ThousandsSeparator, FeeIsValid);
		If Not FeeIsValid Then
			MarkCSVRowError(Row, Errors, "Fee", "Invalid fee amount for the selected number separators.");
		EndIf;
		NetIsValid = False;
		Row.Net = ParseCSVAmount(GetMappedCSVValue(Cells, HeaderIndices, "Net"), DecimalSeparator, ThousandsSeparator, NetIsValid);
		If Not NetIsValid Then
			MarkCSVRowError(Row, Errors, "Net", "Invalid net amount for the selected number separators.");
		EndIf;

		If GrossIsValid And FeeIsValid And NetIsValid Then
			If Row.Gross <= 0 Or Row.Fee < 0 Or Row.Net <= 0 Or Round(Row.Gross, 2) <> Round(Row.Fee + Row.Net, 2) Then
				MarkCSVRowError(Row, Errors, "Gross", "Gross must be positive and equal fee plus net; fee cannot be negative.");
			EndIf;
		EndIf;
		If StrLen(Row.Currency) = 0 Then
			MarkCSVRowError(Row, Errors, "Currency", "Currency is required.");
		EndIf;
		If StrLen(Row.Memo) = 0 Then
			MarkCSVRowError(Row, Errors, "Memo", "Transaction memo is required for matching and audit.");
		EndIf;

		If StrLen(TrimAll(Row.ExternalId)) > 0 Then
			NormalizedId = Upper(TrimAll(Row.ExternalId));
			For Each SeenId In SeenExternalIds Do
				If SeenId = NormalizedId Then
					Row.Status = "Duplicate";
					MarkCSVRowError(Row, Errors, "ExternalId", "Duplicate external transaction ID in this file: " + Row.ExternalId);
					Break;
				EndIf;
			EndDo;
			SeenExternalIds.Add(NormalizedId);
		EndIf;
	EndDo;
	Return Result;
EndFunction

Function CreateTransactionKey(Val LegalEntity, Val CashAccount, Val Channel, Val ExternalId, Val TransactionDate, Val Currency, Val Amount, Val NormalizedMemo) Export
	If Not ValueIsFilled(LegalEntity) Or Not ValueIsFilled(CashAccount) Or Not ValueIsFilled(Currency)
		Or StrLen(TrimAll(Channel)) = 0 Or Not ValueIsFilled(TransactionDate) Or Amount <= 0 Then
		Return "";
	EndIf;

	Identity = "";
	If StrLen(TrimAll(ExternalId)) > 0 Then
		Identity = "EXTERNAL|" + Upper(TrimAll(ExternalId));
	Else
		DateKey = String(Year(TransactionDate)) + Right("0" + String(Month(TransactionDate)), 2) + Right("0" + String(Day(TransactionDate)), 2);
		AmountCents = String(Round(Amount * 100, 0));
		Identity = "FINGERPRINT|" + Upper(TrimAll(LegalEntity.Code)) + "|" + Upper(TrimAll(CashAccount.Code))
			+ "|" + Upper(TrimAll(Channel)) + "|" + DateKey + "|" + Upper(TrimAll(Currency.Code))
			+ "|" + AmountCents + "|" + Upper(TrimAll(NormalizedMemo));
	EndIf;
	Hash = New DataHashing(HashFunction.SHA256);
	Hash.Append(Identity);
	Return "V1" + Base64String(Hash.HashSum);
EndFunction

Function ParseCSVRecords(Val CSVText, Val Delimiter)
	Records = New ValueTable;
	Records.Columns.Add("LineNumber");
	Records.Columns.Add("Cells");
	If StrLen(CSVText) > 0 And Mid(CSVText, 1, 1) = Char(65279) Then
		CSVText = Mid(CSVText, 2);
	EndIf;
	QuoteCharacter = """";
	CurrentRows = New Array;
	CurrentField = "";
	InQuotes = False;
	PhysicalLine = 1;
	RecordStartLine = 1;
	Position = 1;
	TextLength = StrLen(CSVText);
	While Position <= TextLength Do
		CurrentCharacter = Mid(CSVText, Position, 1);
		If InQuotes Then
			If CurrentCharacter = QuoteCharacter Then
				If Position < TextLength And Mid(CSVText, Position + 1, 1) = QuoteCharacter Then
					CurrentField = CurrentField + QuoteCharacter;
					Position = Position + 1;
				Else
					InQuotes = False;
				EndIf;
			ElsIf CurrentCharacter = Char(13) Or CurrentCharacter = Char(10) Then
				CurrentField = CurrentField + Char(10);
				If CurrentCharacter = Char(13) And Position < TextLength And Mid(CSVText, Position + 1, 1) = Char(10) Then
					Position = Position + 1;
				EndIf;
				PhysicalLine = PhysicalLine + 1;
			Else
				CurrentField = CurrentField + CurrentCharacter;
			EndIf;
		ElsIf CurrentCharacter = QuoteCharacter Then
			InQuotes = True;
		ElsIf CurrentCharacter = Delimiter Then
			CurrentRows.Add(CurrentField);
			CurrentField = "";
		ElsIf CurrentCharacter = Char(13) Or CurrentCharacter = Char(10) Then
			CurrentRows.Add(CurrentField);
			If Not (CurrentRows.Count() = 1 And StrLen(TrimAll(CurrentRows[0])) = 0) Then
				Record = Records.Add();
				Record.LineNumber = RecordStartLine;
				Record.Cells = CurrentRows;
			EndIf;
			CurrentRows = New Array;
			CurrentField = "";
			If CurrentCharacter = Char(13) And Position < TextLength And Mid(CSVText, Position + 1, 1) = Char(10) Then
				Position = Position + 1;
			EndIf;
			PhysicalLine = PhysicalLine + 1;
			RecordStartLine = PhysicalLine;
		Else
			CurrentField = CurrentField + CurrentCharacter;
		EndIf;
		Position = Position + 1;
	EndDo;
	If CurrentRows.Count() > 0 Or StrLen(CurrentField) > 0 Then
		CurrentRows.Add(CurrentField);
		If Not (CurrentRows.Count() = 1 And StrLen(TrimAll(CurrentRows[0])) = 0) Then
			Record = Records.Add();
			Record.LineNumber = RecordStartLine;
			Record.Cells = CurrentRows;
		EndIf;
	EndIf;
	Return New Structure("Rows,UnclosedQuote,LastLine", Records, InQuotes, PhysicalLine);
EndFunction

Function FindCSVHeaderIndex(Val HeaderCells, Val HeaderName)
	For Index = 0 To HeaderCells.Count() - 1 Do
		If Upper(TrimAll(HeaderCells[Index])) = Upper(TrimAll(HeaderName)) Then
			Return Index;
		EndIf;
	EndDo;
	Return -1;
EndFunction

Function GetMappedCSVValue(Val Cells, Val HeaderIndices, Val FieldName)
	Index = -1;
	If Not HeaderIndices.Property(FieldName, Index) Or Index < 0 Or Index >= Cells.Count() Then
		Return "";
	EndIf;
	Return TrimAll(Cells[Index]);
EndFunction

Function ParseCSVAmount(Val SourceText, Val DecimalSeparator, Val ThousandsSeparator, AmountIsValid)
	AmountIsValid = False;
	AmountText = TrimAll(SourceText);
	If StrLen(AmountText) = 0 Then
		Return 0;
	EndIf;
	If StrLen(ThousandsSeparator) = 1 And StrFind(AmountText, ThousandsSeparator) > 0 Then
		DecimalPosition = StrFind(AmountText, DecimalSeparator);
		IntegerText = AmountText;
		If DecimalPosition > 0 Then
			IntegerText = Left(AmountText, DecimalPosition - 1);
			FractionText = Mid(AmountText, DecimalPosition + 1);
			If StrFind(FractionText, ThousandsSeparator) > 0 Then Return 0; EndIf;
		EndIf;
		Groups = StrSplit(IntegerText, ThousandsSeparator);
		If Groups.Count() < 2 Or StrLen(Groups[0]) < 1 Or StrLen(Groups[0]) > 3 Then Return 0; EndIf;
		For GroupIndex = 1 To Groups.Count() - 1 Do
			If StrLen(Groups[GroupIndex]) <> 3 Then Return 0; EndIf;
		EndDo;
		AmountText = StrReplace(AmountText, ThousandsSeparator, "");
	EndIf;
	Whole = 0;
	Fraction = 0;
	FractionDigits = 0;
	DecimalSeen = False;
	For Position = 1 To StrLen(AmountText) Do
		CurrentCharacter = Mid(AmountText, Position, 1);
		If CurrentCharacter = DecimalSeparator Then
			If DecimalSeen Then
				Return 0;
			EndIf;
			DecimalSeen = True;
			Continue;
		EndIf;
		If StrFind("0123456789", CurrentCharacter) = 0 Then
			Return 0;
		EndIf;
		Digit = Number(CurrentCharacter);
		If DecimalSeen Then
			FractionDigits = FractionDigits + 1;
			If FractionDigits > 2 Then
				Return 0;
			EndIf;
			Fraction = Fraction * 10 + Digit;
		Else
			Whole = Whole * 10 + Digit;
		EndIf;
	EndDo;
	If FractionDigits = 1 Then
		Fraction = Fraction * 10;
	EndIf;
	AmountIsValid = True;
	Return Whole + Fraction / 100;
EndFunction

Function ParseCSVDate(Val SourceText, DateIsValid)
	DateIsValid = False;
	DateText = TrimAll(SourceText);
	Separator = "";
	If StrFind(DateText, "-") > 0 Then
		Separator = "-";
	ElsIf StrFind(DateText, "/") > 0 Then
		Separator = "/";
	ElsIf StrFind(DateText, ".") > 0 Then
		Separator = ".";
	Else
		Return Undefined;
	EndIf;
	Parts = StrSplit(DateText, Separator);
	If Parts.Count() <> 3 Then
		Return Undefined;
	EndIf;
	First = ParseCSVInteger(Parts[0]);
	Second = ParseCSVInteger(Parts[1]);
	Third = ParseCSVInteger(Parts[2]);
	If First = Undefined Or Second = Undefined Or Third = Undefined Then
		Return Undefined;
	EndIf;
	If StrLen(Parts[0]) = 4 Then
		YearValue = First;
		MonthValue = Second;
		DayValue = Third;
	Else
		DayValue = First;
		MonthValue = Second;
		YearValue = Third;
	EndIf;
	If YearValue < 1 Or MonthValue < 1 Or MonthValue > 12 Or DayValue < 1 Or DayValue > 31 Then
		Return Undefined;
	EndIf;
	Try
		DateValue = Date(YearValue, MonthValue, DayValue);
	Except
		Return Undefined;
	EndTry;
	If Year(DateValue) <> YearValue Or Month(DateValue) <> MonthValue Or Day(DateValue) <> DayValue Then Return Undefined; EndIf;
	DateIsValid = True;
	Return DateValue;
EndFunction

Function ParseCSVInteger(Val TextValue)
	ValueText = TrimAll(TextValue);
	If StrLen(ValueText) = 0 Then
		Return Undefined;
	EndIf;
	Result = 0;
	For Position = 1 To StrLen(ValueText) Do
		DigitText = Mid(ValueText, Position, 1);
		If StrFind("0123456789", DigitText) = 0 Then
			Return Undefined;
		EndIf;
		Result = Result * 10 + Number(DigitText);
	EndDo;
	Return Result;
EndFunction

Procedure MarkCSVRowError(Row, Errors, FieldName, MessageText)
	If Row.Status <> "Duplicate" Then
		Row.Status = "Invalid";
	EndIf;
	If StrLen(Row.Reason) > 0 Then
		Row.Reason = Row.Reason + " ";
	EndIf;
	Row.Reason = Row.Reason + MessageText;
	AddCSVError(Errors, Row.LineNumber, FieldName, MessageText);
EndProcedure

Procedure AddCSVError(Errors, LineNumber, FieldName, MessageText)
	ErrorRow = Errors.Add();
	ErrorRow.LineNumber = LineNumber;
	ErrorRow.FieldName = FieldName;
	ErrorRow.Message = MessageText;
EndProcedure
