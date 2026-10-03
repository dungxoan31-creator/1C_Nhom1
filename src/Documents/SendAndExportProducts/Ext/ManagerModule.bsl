
Procedure Print(Spreadsheet, Ref) Export
	//{{_PRINT_WIZARD(Print)
	Template = Documents.SendAndExportProducts.GetTemplate("Print");
	Query = New Query;
	Query.Text =
	"SELECT
	|	SendAndExportProducts.Date,
	|	SendAndExportProducts.Warehouse,
	|	SendAndExportProducts.Customer,
	|	SendAndExportProducts.Number,
	|	SendAndExportProducts.Staff,
	|	SendAndExportProducts.Total,
	|	SendAndExportProducts.Products.(
	|		LineNumber,
	|		Product,
	|		Unit,
	|		Quantity,
	|		Price,
	|		Amount
	|	)
	|FROM
	|	Document.SendAndExportProducts AS SendAndExportProducts
	|WHERE
	|	SendAndExportProducts.Ref IN (&Ref)";
	Query.Parameters.Insert("Ref", Ref);
	Selection = Query.Execute().Select();

	AreaCaption = Template.GetArea("Caption");
	Header = Template.GetArea("Header");
	AreaBảngMặtHàngHeader = Template.GetArea("BảngMặtHàngHeader");
	AreaBảngMặtHàng = Template.GetArea("BảngMặtHàng");
	Footer = Template.GetArea("Footer");

	Spreadsheet.Clear();

	InsertPageBreak = False;
	While Selection.Next() Do
		If InsertPageBreak Then
			Spreadsheet.PutHorizontalPageBreak();
		EndIf;

		Spreadsheet.Put(AreaCaption);

		Header.Parameters.Fill(Selection);
		Spreadsheet.Put(Header, Selection.Level());

		Spreadsheet.Put(AreaBảngMặtHàngHeader);
		SelectionBảngMặtHàng = Selection.Products.Select();
		While SelectionBảngMặtHàng.Next() Do
			AreaBảngMặtHàng.Parameters.Fill(SelectionBảngMặtHàng);
			Spreadsheet.Put(AreaBảngMặtHàng, SelectionBảngMặtHàng.Level());
		EndDo;

		Footer.Parameters.Fill(Selection);
		Spreadsheet.Put(Footer);

		InsertPageBreak = True;
	EndDo;
	//}}
EndProcedure
