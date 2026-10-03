
Procedure Posting(Cancel, Mode)
	//{{__REGISTER_REGISTERRECORDS_WIZARD
	// This fragment was built by the wizard.
	// Warning! All manually made changes will be lost next time you use the wizard.

	// register Inventory Expense
	RegisterRecords.Inventory.Write = True;
	For Each CurRowProducts In Products Do
		Record = RegisterRecords.Inventory.Add();
		Record.RecordType = AccumulationRecordType.Expense;
		Record.Period = Date;
		Record.Product = CurRowProducts.Product;
		Record.Warehouse = WarehouseSender;
		Record.Quantity = CurRowProducts.Quantity;
	EndDo;

	// register Inventory Receipt
	RegisterRecords.Inventory.Write = True;
	For Each CurRowProducts In Products Do
		Record = RegisterRecords.Inventory.Add();
		Record.RecordType = AccumulationRecordType.Receipt;
		Record.Period = Date;
		Record.Product = CurRowProducts.Product;
		Record.Warehouse = WarehouseReceiper;
		Record.Quantity = CurRowProducts.Quantity;
	EndDo;

	//}}__REGISTER_REGISTERRECORDS_WIZARD
EndProcedure
