// Form Module: UyNhiemChi FormDanhSach

#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	BoLocKy = "TatCa";
	BoLocTrangThai = "TatCa";
EndProcedure

#EndRegion

#Region FormHeaderItemsEventHandlers

&AtClient
Procedure BoLocKyOnChange(Item)
	ApDungBoLocAtServer();
EndProcedure

&AtClient
Procedure BoLocTrangThaiOnChange(Item)
	ApDungBoLocAtServer();
EndProcedure

&AtClient
Procedure BoLocDoiTacOnChange(Item)
	ApDungBoLocAtServer();
EndProcedure

#EndRegion

#Region Private

&AtServer
Procedure ApDungBoLocAtServer()
	// Tối ưu hóa điều kiện lọc trên DynamicList theo chuẩn 1C #std657
	DanhSach.SettingsComposer.FixedSettings.Filter.Items.Clear();
	
	// Apply the selected period to the document date. Capture the session date
	// once so a request crossing midnight cannot produce mismatched boundaries.
	NgayHienTai = CurrentSessionDate();
	NgayBatDau = Undefined;
	NgayKetThuc = Undefined;
	If BoLocKy = "HomNay" Then
		NgayBatDau = BegOfDay(NgayHienTai);
		NgayKetThuc = EndOfDay(NgayHienTai);
	ElsIf BoLocKy = "ThangNay" Then
		NgayBatDau = BegOfMonth(NgayHienTai);
		NgayKetThuc = EndOfMonth(NgayHienTai);
	ElsIf BoLocKy = "QuyNay" Then
		NgayBatDau = BegOfQuarter(NgayHienTai);
		NgayKetThuc = EndOfQuarter(NgayHienTai);
	EndIf;
	If ValueIsFilled(NgayBatDau) Then
		ItemFilter = DanhSach.SettingsComposer.FixedSettings.Filter.Items.Add(Type("DataCompositionFilterItem"));
		ItemFilter.LeftValue = New DataCompositionField("Date");
		ItemFilter.ComparisonType = DataCompositionComparisonType.GreaterOrEqual;
		ItemFilter.RightValue = NgayBatDau;
		ItemFilter.Use = True;

		ItemFilter = DanhSach.SettingsComposer.FixedSettings.Filter.Items.Add(Type("DataCompositionFilterItem"));
		ItemFilter.LeftValue = New DataCompositionField("Date");
		ItemFilter.ComparisonType = DataCompositionComparisonType.LessOrEqual;
		ItemFilter.RightValue = NgayKetThuc;
		ItemFilter.Use = True;
	EndIf;
	
	// Lọc trạng thái
	If BoLocTrangThai = "DaGhiSo" Then
		ItemFilter = DanhSach.SettingsComposer.FixedSettings.Filter.Items.Add(Type("DataCompositionFilterItem"));
		ItemFilter.LeftValue = New DataCompositionField("Posted");
		ItemFilter.ComparisonType = DataCompositionComparisonType.Equal;
		ItemFilter.RightValue = True;
		ItemFilter.Use = True;
	ElsIf BoLocTrangThai = "BanNhap" Then
		ItemFilter = DanhSach.SettingsComposer.FixedSettings.Filter.Items.Add(Type("DataCompositionFilterItem"));
		ItemFilter.LeftValue = New DataCompositionField("Posted");
		ItemFilter.ComparisonType = DataCompositionComparisonType.Equal;
		ItemFilter.RightValue = False;
		ItemFilter.Use = True;
	ElsIf BoLocTrangThai = "DaHuy" Then
		ItemFilter = DanhSach.SettingsComposer.FixedSettings.Filter.Items.Add(Type("DataCompositionFilterItem"));
		ItemFilter.LeftValue = New DataCompositionField("DeletionMark");
		ItemFilter.ComparisonType = DataCompositionComparisonType.Equal;
		ItemFilter.RightValue = True;
		ItemFilter.Use = True;
	EndIf;
	
	// Lọc đối tác
	If ValueIsFilled(BoLocDoiTac) Then
		ItemFilter = DanhSach.SettingsComposer.FixedSettings.Filter.Items.Add(Type("DataCompositionFilterItem"));
		ItemFilter.LeftValue = New DataCompositionField("DoiTac");
		ItemFilter.ComparisonType = DataCompositionComparisonType.Equal;
		ItemFilter.RightValue = BoLocDoiTac;
		ItemFilter.Use = True;
	EndIf;
EndProcedure

#EndRegion
