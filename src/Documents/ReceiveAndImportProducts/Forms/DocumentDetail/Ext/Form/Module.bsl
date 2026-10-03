
&AtClient
Procedure ProductsProductOnChange(Item)
	// Insert handler content.                 
//	DòngHiệnTại= Items.Products.CurrentData;  
//	DòngHiệnTại.ĐơnVịTính = FillUnit(DòngHiệnTại.Product);
	TabularSectionRow = Items.Products.CurrentData; 
	TabularSectionRow.Price = FillPrice(TabularSectionRow.Product);
	TabularSectionRow.Unit = FillUnit(TabularSectionRow.Product);
EndProcedure

&AtServer
Function FillPrice (CurProduct)
	
	Filter = New Structure("Product",CurProduct);
	FoundProduct = InformationRegisters.PriceHistory.GetLast(Object.Date, Filter);
	Return FoundProduct.Price;
EndFunction
&AtServer
Function FillUnit ( CurProduct )
	Return CurProduct.Unit;
EndFunction

&AtClient
Procedure ProductsQuantityOnChange(Item)
	// Insert handler content. 
	//DòngHiệnTại= Items.Products.CurrentData;
	//CalculateAmount(DòngHiệnTại);   
	TabularSectionRow = Items.Products.CurrentData;
	CalculateAmount(TabularSectionRow);
EndProcedure           


&AtClient
Procedure ProductsPriceOnChange(Item)
	// Insert handler content.     
	//DòngHiệnTại= Items.Products.CurrentData;
	//CalculateAmount(DòngHiệnTại);  
	TabularSectionRow = Items.Products.CurrentData;
	CalculateAmount(TabularSectionRow);
	
EndProcedure    

&AtClient
Procedure CalculateAmount(CurRow)
	CurRow.Amount = CurRow.Quantity * CurRow.Price;
	Object.Total = Object.Products.Total("Amount");
EndProcedure
