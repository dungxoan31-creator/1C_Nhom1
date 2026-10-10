Procedure BeforeWrite(Cancel)
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
			Raise "Số tài khoản ảo đã được cấp phát cho đối tác khác!";
		EndIf;
	EndIf;
EndProcedure
