Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	// Default CashFlowItem from Contract if empty
	If Not ValueIsFilled(CashFlowItem) And ValueIsFilled(Contract) And ValueIsFilled(Contract.DefaultCashFlowItem) Then
		CashFlowItem = Contract.DefaultCashFlowItem;
	EndIf;
EndProcedure

Procedure Posting(Cancel, Mode)
	RegisterRecords.AccountsPayable.Write = True;
	RegisterRecords.GeneralLedger.Write = True;

	TotalAllocated = 0;

	// 1. Phân bổ thanh toán cho các hóa đơn được chỉ định
	For Each Row In PaymentAllocation Do
		If Row.AllocatedAmount > 0 Then
			TotalAllocated = TotalAllocated + Row.AllocatedAmount;
			
			// Giảm nợ cho từng hóa đơn cụ thể (Partial Payment hoặc Full Payment)
			Record = RegisterRecords.AccountsPayable.Add();
			Record.RecordType = AccumulationRecordType.Expense;
			Record.Period = Date;
			Record.Company = "VinSmart Future";
			Record.Counterparty = Counterparty;
			Record.Contract = Contract;
			Record.Invoice = Row.Invoice;
			Record.Amount = Row.AllocatedAmount;
		EndIf;
	EndDo;

	// 2. Nếu thanh toán vượt quá số phân bổ hoặc không phân bổ -> Khoản chưa phân bổ (Unallocated Payment / Prepayment)
	UnallocatedAmount = PaymentAmount - TotalAllocated;
	If UnallocatedAmount > 0 Then
		Record = RegisterRecords.AccountsPayable.Add();
		Record.RecordType = AccumulationRecordType.Expense;
		Record.Period = Date;
		Record.Company = "VinSmart Future";
		Record.Counterparty = Counterparty;
		Record.Contract = Contract;
		Record.Invoice = Undefined; // Đánh dấu khoản chưa phân bổ
		Record.Amount = UnallocatedAmount;
	EndIf;

	// 3. Hạch toán Sổ cái Kế toán: Nợ TK 331 (Phải trả NCC), Có TK 112 (Ngân hàng) hoặc TK 111 (Tiền mặt)
	CrAccount = ChartsOfAccounts.Main.BankDeposits;
	If ValueIsFilled(Account) And ValueIsFilled(Account.AccountType) And Account.AccountType = Enums.CashAccountTypes.Cash Then
		CrAccount = ChartsOfAccounts.Main.Cash;
	EndIf;

	GLRecord = RegisterRecords.GeneralLedger.Add();
	GLRecord.Period = Date;
	GLRecord.AccountDr = ChartsOfAccounts.Main.AccountsPayable;
	GLRecord.AccountCr = CrAccount;
	GLRecord.Amount = PaymentAmount;
EndProcedure
