
Procedure InPhiếuĐiềuChuyểnKho(Spreadsheet, Ref) Export
	//{{_PRINT_WIZARD(InPhiếuĐiềuChuyểnKho)
	Template = Documents.InventoryTransfer.GetTemplate("PrintInventoryTransfer");
	Query = New Query;
	Query.Text =
	"SELECT
	|	InventoryTransfer.Date,
	|	InventoryTransfer.WarehouseReceiper,
	|	InventoryTransfer.WarehouseSender,
	|	InventoryTransfer.ReceivingStaff,
	|	InventoryTransfer.Products.(
	|		LineNumber,
	|		Product,
	|		Unit,
	|		Quantity
	|	)
	|FROM
	|	Document.InventoryTransfer AS InventoryTransfer
	|WHERE
	|	InventoryTransfer.Ref IN (&Ref)";
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
