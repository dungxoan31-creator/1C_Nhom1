
&AtClient
Procedure CommandProcessing(CommandParameter, CommandExecuteParameters)
	//{{_PRINT_WIZARD(InPhiếuNhậpKho)
	Spreadsheet = New SpreadsheetDocument;
	InPhiếuNhậpKho(Spreadsheet, CommandParameter);

	Spreadsheet.ShowGrid = False;
	Spreadsheet.Protection = False;
	Spreadsheet.ReadOnly = False;
	Spreadsheet.ShowHeaders = False;
	Spreadsheet.Show();
	//}}
EndProcedure

&AtServer
Procedure InPhiếuNhậpKho(Spreadsheet, CommandParameter)
	Documents.ReceiveAndImportProducts.InPhiếuNhậpKho(Spreadsheet, CommandParameter);
EndProcedure
