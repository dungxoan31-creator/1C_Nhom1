Procedure SessionParametersSetting(RequiredParameters)
	// Initialize the sole branch scope on demand. The session module runs in
	// privileged mode so users cannot widen their own branch assignment.
	If RequiredParameters <> Undefined And RequiredParameters.Find("CurrentBranch") = Undefined Then
		Return;
	EndIf;

	CurrentBranch = Catalogs.ChiNhanh.EmptyRef();
	CurrentUserName = UserName();
	If Not IsBlankString(CurrentUserName) Then
		Query = New Query(
			"SELECT TOP 2
			|   ChiNhanh
			|FROM
			|   InformationRegister.PhanQuyenChiNhanh
			|WHERE
			|   NguoiDung = &NguoiDung
			|ORDER BY
			|   ChiNhanh");
		Query.SetParameter("NguoiDung", CurrentUserName);
		Assignments = Query.Execute().Unload();
		If Assignments.Count() > 1 Then
			Raise StrTemplate("User %1 has more than one branch assignment; configure a single branch before starting this session.", CurrentUserName);
		EndIf;
		If Assignments.Count() = 1 Then
			CurrentBranch = Assignments[0].ChiNhanh;
		EndIf;
	EndIf;

	SessionParameters.CurrentBranch = CurrentBranch;
EndProcedure
