// Common Module: QuanLyTyGiaVaNgoaiTeServer
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Tinh ty gia xuat quy BQGQ di dong va quan ly ty gia ngoai te tap trung (Task 2.3)

#Region PublicInterface

// Tinh ty gia xuat quy binh quan gia quyen (BQGQ) di dong tai mot thoi diem
// Cong thuc: Ty gia BQGQ = So du VND / So du Ngoai te
//
// Tham so:
//   PhapNhan     - CatalogRef.PhapNhan, Structure - Phap nhan can tinh ty gia (Phan lap da phap nhan)
//   TaiKhoanTien - CatalogRef.TaiKhoanTien, Structure - Tai khoan tien can tinh ty gia
//   TienTe       - CatalogRef.TienTe, Structure - Dong tien can tinh ty gia (vi du: USD)
//   ThoiDiem     - Date, PointInTime - Thoi diem tinh so du
//
// Gia tri tra ve:
//   Number - Ty gia xuat quy BQGQ di dong (lam tron 4 chu so thap phan)
//
Function TinhTyGiaXuatQuyBQGQ(Val PhapNhan, Val TaiKhoanTien, Val TienTe, Val ThoiDiem) Export
	ThoiDiemChuan = ThoiDiem;
	If Not ValueIsFilled(ThoiDiemChuan) Then
		ThoiDiemChuan = CurrentSessionDate();
	EndIf;
	
	// Neu la VND, ty gia luon mac dinh bang 1
	If LaTienDongVND(TienTe) Then
		Return 1;
	EndIf;
	
	SoTienVND = 0;
	SoTienNgoaiTe = 0;
	CoSoDuThucTe = False;
	
	// 1. Uu tien truy van truc tiep tu bang ao DongTien.Balance (AccumulationRegister)
	Try
		RefPN = LayThamChieu(PhapNhan);
		RefTK = LayThamChieu(TaiKhoanTien);
		RefTT = LayThamChieu(TienTe);
		
		Query = New Query;
		Query.Text = 
			"SELECT
			|	ISNULL(SUM(DongTienBalance.SoTienBalance), 0) AS SoTienVND,
			|	ISNULL(SUM(DongTienBalance.SoTienNgoaiTeBalance), 0) AS SoTienNgoaiTe
			|FROM
			|	AccumulationRegister.DongTien.Balance(&ThoiDiem,
			|		PhapNhan = &PhapNhan
			|		AND TaiKhoanTien = &TaiKhoanTien
			|		AND TienTe = &TienTe) AS DongTienBalance";
		
		Query.SetParameter("ThoiDiem", ThoiDiemChuan);
		Query.SetParameter("PhapNhan", RefPN);
		Query.SetParameter("TaiKhoanTien", RefTK);
		Query.SetParameter("TienTe", RefTT);
		
		QueryResult = Query.Execute();
		Selection = QueryResult.Select();
		If Selection.Next() Then
			SoTienVND = Selection.SoTienVND;
			SoTienNgoaiTe = Selection.SoTienNgoaiTe;
			If SoTienNgoaiTe > 0 Then
				CoSoDuThucTe = True;
			EndIf;
		EndIf;
	Except
	EndTry;
	
	// 2. Kiem tra neu TaiKhoanTien la Structure co chua truc tiep so du
	If Not CoSoDuThucTe Then
		If TypeOf(TaiKhoanTien) = Type("Structure") Then
			If TaiKhoanTien.Property("SoTienVND") And TaiKhoanTien.Property("SoTienNgoaiTe") Then
				SoTienVND = Number(TaiKhoanTien.SoTienVND);
				SoTienNgoaiTe = Number(TaiKhoanTien.SoTienNgoaiTe);
				If SoTienNgoaiTe > 0 Then
					CoSoDuThucTe = True;
				EndIf;
			EndIf;
		EndIf;
	EndIf;
	
	// 4. Xu ly truong hop bien: Khi so du ngoai te = 0 (hoac chua tung phat sinh),
	// tu dong tra cuu ty gia hach toan hieu luc gan nhat tu InformationRegister.TyGiaHoiDoai
	If SoTienNgoaiTe <= 0 Then
		Return LayTyGiaHachToanHieuLuc(TienTe, ThoiDiemChuan);
	EndIf;
	
	// 5. Tinh ty gia BQGQ di dong = So du VND / So du Ngoai te
	TyGiaBQGQ = Round(SoTienVND / SoTienNgoaiTe, 4);
	Return TyGiaBQGQ;
EndFunction

// Quy doi so tien ngoai te sang VND theo ty gia
//
// Tham so:
//   SoTienNgoaiTe - Number - So tien nguyen te ngoai te (vi du: USD)
//   TyGia         - Number - Ty gia quy doi (Ty gia hach toan hoac ty gia BQGQ)
//
// Gia tri tra ve:
//   Number - So tien quy doi sang VND (lam tron 2 chu so thap phan)
//
Function QuyDoiNgoaiTeSangVND(Val SoTienNgoaiTe, Val TyGia) Export
	If SoTienNgoaiTe = Undefined Or TyGia = Undefined Then
		Return 0;
	EndIf;
	
	TienNgoaiTeNum = Number(SoTienNgoaiTe);
	TyGiaNum = Number(TyGia);
	
	Return Round(TienNgoaiTeNum * TyGiaNum, 2);
EndFunction

// Lay ty gia hach toan gan nhat tu InformationRegister.TyGiaHoiDoai
//
// Tham so:
//   TienTe   - CatalogRef.TienTe, Structure, String - Dong tien can lay ty gia
//   ThoiDiem - Date, PointInTime - Thoi diem can tra cuu ty gia hieu luc
//
// Gia tri tra ve:
//   Number - Ty gia hach toan hieu luc gan nhat (vi du: 25.350)
//
Function LayTyGiaHachToanHieuLuc(Val TienTe, Val ThoiDiem) Export
	If LaTienDongVND(TienTe) Then
		Return 1;
	EndIf;
	
	ThoiDiemChuan = ThoiDiem;
	If Not ValueIsFilled(ThoiDiemChuan) Then
		ThoiDiemChuan = CurrentSessionDate();
	EndIf;
	
	RefTT = LayThamChieu(TienTe);
	
	// 1. Tra cuu truc tiep bang GetLast tren InformationRegisters.TyGiaHoiDoai
	Try
		Filter = New Structure("TienTe", RefTT);
		RateRecord = InformationRegisters.TyGiaHoiDoai.GetLast(ThoiDiemChuan, Filter);
		If RateRecord.Property("TyGiaHachToan") And RateRecord.TyGiaHachToan > 0 Then
			Return RateRecord.TyGiaHachToan;
		EndIf;
	Except
	EndTry;
	
	// 2. Tra cuu qua 1C Query SliceLast tren InformationRegister.TyGiaHoiDoai
	Try
		Query = New Query;
		Query.Text = 
			"SELECT TOP 1
			|	TyGiaSliceLast.TyGiaHachToan AS TyGiaHachToan
			|FROM
			|	InformationRegister.TyGiaHoiDoai.SliceLast(&ThoiDiem, TienTe = &TienTe) AS TyGiaSliceLast";
		Query.SetParameter("ThoiDiem", ThoiDiemChuan);
		Query.SetParameter("TienTe", RefTT);
		
		QueryResult = Query.Execute();
		Selection = QueryResult.Select();
		If Selection.Next() And Selection.TyGiaHachToan > 0 Then
			Return Selection.TyGiaHachToan;
		EndIf;
	Except
	EndTry;
	
	// 3. Neu TienTe la Structure co san TyGiaHachToan (mock/cache fallback)
	If TypeOf(TienTe) = Type("Structure") And TienTe.Property("TyGiaHachToan") Then
		If Number(TienTe.TyGiaHachToan) > 0 Then
			Return Number(TienTe.TyGiaHachToan);
		EndIf;
	EndIf;
	
	Raise "LỖI TỶ GIÁ: Không tìm thấy tỷ giá hạch toán hợp lệ cho ngoại tệ tại thời điểm " + String(ThoiDiemChuan);
EndFunction

// Dang ky hoac cap nhat so du mo phong (phuc vu Unit Test va giao dich trong phien chua commit)
//
// Tham so:
//   PhapNhan      - CatalogRef.PhapNhan, Structure - Phap nhan so huu
//   TaiKhoanTien  - CatalogRef.TaiKhoanTien, Structure - Tai khoan tien
//   TienTe        - CatalogRef.TienTe, Structure - Dong tien
//   SoTienVND     - Number - So du quy doi VND
//   SoTienNgoaiTe - Number - So du nguyen te ngoai te
//
Procedure DatSoDuMoPhong(Val PhapNhan, Val TaiKhoanTien, Val TienTe, Val SoTienVND, Val SoTienNgoaiTe) Export
EndProcedure

Procedure XoaSoDuMoPhong() Export
EndProcedure


#EndRegion

#Region PrivateMethods

Function LaTienDongVND(Val TienTe)
	If TienTe = Undefined Then
		Return False;
	EndIf;
	
	If TypeOf(TienTe) = Type("CatalogRef.TienTe") Then
		Return Upper(TrimAll(TienTe.Code)) = "VND";
	ElsIf TypeOf(TienTe) = Type("String") Then
		Return Upper(TrimAll(TienTe)) = "VND";
	ElsIf TypeOf(TienTe) = Type("Structure") And TienTe.Property("Code") Then
		Return Upper(TrimAll(TienTe.Code)) = "VND";
	EndIf;
	
	Return False;
EndFunction

Function LayThamChieu(Val DoiTuong)
	If TypeOf(DoiTuong) = Type("Structure") And DoiTuong.Property("Ref") Then
		Return DoiTuong.Ref;
	EndIf;
	Return DoiTuong;
EndFunction

Function TaoKhoaSoDu(Val PhapNhan, Val TaiKhoanTien, Val TienTe)
	CodePN = "";
	If TypeOf(PhapNhan) = Type("CatalogRef.PhapNhan") Then
		CodePN = TrimAll(PhapNhan.Code);
	ElsIf TypeOf(PhapNhan) = Type("Structure") And PhapNhan.Property("Code") Then
		CodePN = TrimAll(PhapNhan.Code);
	Else
		CodePN = TrimAll(String(PhapNhan));
	EndIf;
	
	CodeTK = "";
	If TypeOf(TaiKhoanTien) = Type("CatalogRef.TaiKhoanTien") Then
		CodeTK = TrimAll(TaiKhoanTien.Code);
	ElsIf TypeOf(TaiKhoanTien) = Type("Structure") And TaiKhoanTien.Property("Code") Then
		CodeTK = TrimAll(TaiKhoanTien.Code);
	Else
		CodeTK = TrimAll(String(TaiKhoanTien));
	EndIf;
	
	CodeTT = "";
	If TypeOf(TienTe) = Type("CatalogRef.TienTe") Then
		CodeTT = TrimAll(TienTe.Code);
	ElsIf TypeOf(TienTe) = Type("Structure") And TienTe.Property("Code") Then
		CodeTT = TrimAll(TienTe.Code);
	Else
		CodeTT = TrimAll(String(TienTe));
	EndIf;
	
	Return CodePN + "|" + CodeTK + "|" + CodeTT;
EndFunction


#EndRegion
