Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	// Calculate DueDate automatically if not filled
	If Not ValueIsFilled(DueDate) Then
		PaymentDays = 30; // Default Net 30
		If ValueIsFilled(Contract) And ValueIsFilled(Contract.PaymentTermsDays) Then
			PaymentDays = Contract.PaymentTermsDays;
		EndIf;
		DueDate = BegOfDay(Date) + PaymentDays * 86400;
	EndIf;

	// Default CashFlowItem from Contract if empty
	If Not ValueIsFilled(CashFlowItem) And ValueIsFilled(Contract) And ValueIsFilled(Contract.DefaultCashFlowItem) Then
		CashFlowItem = Contract.DefaultCashFlowItem;
	EndIf;
EndProcedure

Procedure Posting(Cancel, Mode)
	// 1. Tăng nợ phải trả trong sổ chi tiết AccountsPayable
	RegisterRecords.AccountsPayable.Write = True;
	Record = RegisterRecords.AccountsPayable.Add();
	Record.RecordType = AccumulationRecordType.Receipt;
	Record.Period = Date;
	Record.Company = "VinSmart Future";
	Record.Counterparty = Counterparty;
	Record.Contract = Contract;
	Record.Invoice = Ref;
	Record.Amount = TotalAmount;
	Record.DueDate = DueDate;

	// 2. Bút toán kép vào Sổ cái Kế toán: Nợ Chi phí / Linh kiện, Có TK 331 (Phải trả NCC)
	RegisterRecords.GeneralLedger.Write = True;
	GLRecord = RegisterRecords.GeneralLedger.Add();
	GLRecord.Period = Date;
	GLRecord.AccountDr = ChartsOfAccounts.Main.CloudInfrastructure;
	GLRecord.AccountCr = ChartsOfAccounts.Main.AccountsPayable;
	GLRecord.Amount = TotalAmount;
EndProcedure
