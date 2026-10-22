
// Quy tac thue suat pho thong va muc giam theo thoi gian hieu luc.
// Dieu kien DuocGiam do nghiep vu phan loai tung hang hoa/dich vu; khong suy ra tu ten.

Function TyLeVATApDungTheoNgay(Val NgayTinhThue, Val DuocGiam) Export
	If TypeOf(NgayTinhThue) <> Type("Date") Then
		Raise "VAT_DATE_REQUIRED: Ngay tinh thue phai la kieu Date.";
	EndIf;
	If TypeOf(DuocGiam) <> Type("Boolean") Then
		Raise "VAT_ELIGIBILITY_REQUIRED: Dieu kien giam thue phai la kieu Boolean.";
	EndIf;

	NgayHieuLucGiam = Date(2025, 7, 1, 0, 0, 0);
	NgayKetThucGiam = Date(2027, 1, 1, 0, 0, 0);
	If DuocGiam And BegOfDay(NgayTinhThue) >= NgayHieuLucGiam
		And BegOfDay(NgayTinhThue) < NgayKetThucGiam Then
		Return 8;
	EndIf;

	Return 10;
EndFunction
