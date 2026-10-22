// Form Module: BienBanNghiemThuGiaiDoan FormDanhSach

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
