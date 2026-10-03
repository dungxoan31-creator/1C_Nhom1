
&AtClient
Procedure ProductsProductOnChange(Item)
	// Insert handler content.           
	TabularSectionRow = Items.Products.CurrentData;      
	// Thực hiện đơn vị tính
	TabularSectionRow.Unit = FillUnit(TabularSectionRow.Product);
	// Thực hiện đơn giá 
	TabularSectionRow.Price = FillPriceProduct(TabularSectionRow.Product);
	
	

EndProcedure

&AtServer
Function FillUnit ( CurProduct )
	Return CurProduct.Unit;
EndFunction
&AtServer
Function FillPriceProduct(CurProduct)
		Filter = New  Structure(" Product", CurProduct);
		FoundProduct = InformationRegisters.PriceHistory.GetLast(Object.Date,Filter);
		Return FoundProduct.Price;
	
EndFunction

&AtClient
Procedure ProductsQuantityOnChange(Item)
	// Insert handler content.      
	TabularSectionRow = Items.Products.CurrentData;
	CalculateAmount(TabularSectionRow);

EndProcedure


&AtClient
Procedure ProductsPriceOnChange(Item)
	// Insert handler content.
	TabularSectionRow = Items.Products.CurrentData;
	CalculateAmount(TabularSectionRow);

EndProcedure

&AtClient
Procedure CalculateAmount(CurRow)
	CurRow.Amount = CurRow.Quantity * CurRow.Price;
	Object.Total = Object.Products.Total("Amount");
EndProcedure

