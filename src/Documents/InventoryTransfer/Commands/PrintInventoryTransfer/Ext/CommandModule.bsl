
&AtClient
Procedure CommandProcessing(CommandParameter, CommandExecuteParameters)
	//{{_PRINT_WIZARD(InPhiếuĐiềuChuyểnKho)
	Spreadsheet = New SpreadsheetDocument;
	InPhiếuĐiềuChuyểnKho(Spreadsheet, CommandParameter);

	Spreadsheet.ShowGrid = False;
	Spreadsheet.Protection = False;
	Spreadsheet.ReadOnly = False;
	Spreadsheet.ShowHeaders = False;
	Spreadsheet.Show();
	//}}
EndProcedure

&AtServer
Procedure InPhiếuĐiềuChuyểnKho(Spreadsheet, CommandParameter)
	Documents.InventoryTransfer.InPhiếuĐiềuChuyểnKho(Spreadsheet, CommandParameter);
EndProcedure
