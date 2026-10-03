
Procedure Posting(Cancel, Mode)
	//{{__REGISTER_REGISTERRECORDS_WIZARD
	// This fragment was built by the wizard.
	// Warning! All manually made changes will be lost next time you use the wizard.

	// register PriceHistory
	RegisterRecords.PriceHistory.Write = True;
	For Each CurRowProducts In Products Do
		Record = RegisterRecords.PriceHistory.Add();
		Record.Period = ValidDate;
		Record.Product = CurRowProducts.Product;
		Record.Price = CurRowProducts.Price;
	EndDo;

	//}}__REGISTER_REGISTERRECORDS_WIZARD
EndProcedure
