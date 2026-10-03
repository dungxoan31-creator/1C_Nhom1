
&AtClient
Procedure ProductsProductOnChange(Item)
	// Insert handler content.    
	TabularSectionRow = Items.Products.CurrentData ;
	TabularSectionRow.Unit = FillUnit(TabularSectionRow.Product )
EndProcedure                                   

&AtServer
Function FillUnit (CurMatHang)
	Return CurMatHang.Unit ;
EndFunction
