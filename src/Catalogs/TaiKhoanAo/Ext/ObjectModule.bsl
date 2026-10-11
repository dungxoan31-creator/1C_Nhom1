Procedure BeforeWrite(Cancel)
	If DataExchange.Load Then
		Return;
	EndIf;
	
	// Bat trung lap ma SoTaiKhoanAo (Unique constraint)
	If ValueIsFilled(SoTaiKhoanAo) Then
		Query = New Query;
		Query.Text = 
		"SELECT TOP 1
		|	TaiKhoanAo.Ref AS Ref
		|FROM
		|	Catalog.TaiKhoanAo AS TaiKhoanAo
		|WHERE
		|	TaiKhoanAo.SoTaiKhoanAo = &SoTaiKhoanAo
		|	AND TaiKhoanAo.Ref <> &Ref";
		
		Query.SetParameter("SoTaiKhoanAo", SoTaiKhoanAo);
		Query.SetParameter("Ref", Ref);
		
		QueryResult = Query.Execute();
		If Not QueryResult.IsEmpty() Then
			Cancel = True;
			Msg = New UserMessage;
			Msg.Text = NStr("vi = 'Số tài khoản ảo đã được cấp phát cho đối tác khác!'; en = 'Virtual account number already assigned to another counterparty!'");
			Msg.SetData(ThisObject);
			Msg.Field = "SoTaiKhoanAo";
			Msg.Message();
			Return;
		EndIf;
	EndIf;
EndProcedure
