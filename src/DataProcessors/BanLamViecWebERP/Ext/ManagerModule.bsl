#Region Public

// Lấy dữ liệu tổng hợp cho màn hình Cockpit điều hành Web ERP
//
// Tham số:
//   KyBaoCao - Chuỗi: "ThangNay", "QuyNay", "NamNay"
//
// Giá trị trả về:
//   Cấu trúc: Dữ liệu tài chính, biểu đồ SVG và danh sách công việc ưu tiên
//
Function LayDuLieuCockpit(Val KyBaoCao = "ThangNay") Export
	
	DuLieuTongHop = BangDieuKhienServer.LayDuLieuTongQuan(KyBaoCao);
	Return DuLieuTongHop;
	
EndFunction

// Lấy danh sách chứng từ đang chờ soát xét và chờ phê duyệt (Maker-Checker)
//
// Giá trị trả về:
//   Mảng các Cấu trúc chứa thông tin chứng từ chờ duyệt
//
Function LayDanhSachChoPheDuyet() Export
	
	DanhSach = New Array;
	
	// Truy vấn các hóa đơn nhà cung cấp đang chờ duyệt
	TruyVanAP = New Query;
	TruyVanAP.Text = 
		"SELECT TOP 20
		|	Doc.Ref AS ChungTu,
		|	Doc.Number AS SoChungTu,
		|	Doc.Date AS NgayChungTu,
		|	""HoaDonNhaCungCap"" AS LoaiChungTu,
		|	""Hóa đơn NCC"" AS TenLoaiChungTu,
		|	Doc.DoiTac.Description AS DoiTac,
		|	Doc.TongTienThanhToan AS SoTien,
		|	Doc.TrangThaiPheDuyet AS TrangThai
		|FROM
		|	Document.HoaDonNhaCungCap AS Doc
		|WHERE
		|	Doc.TrangThaiPheDuyet = VALUE(Enum.TrangThaiHoaDonAP.ChoPheDuyet)
		|	OR Doc.TrangThaiPheDuyet = VALUE(Enum.TrangThaiHoaDonAP.ChoSoatXet)
		|ORDER BY
		|	Doc.Date DESC";
		
	KetQuaAP = TruyVanAP.Execute();
	ChonAP = KetQuaAP.Choose();
	While ChonAP.Next() Do
		Dong = New Structure;
		Dong.Insert("ChungTu", ChonAP.ChungTu);
		Dong.Insert("SoChungTu", ChonAP.SoChungTu);
		Dong.Insert("NgayChungTu", ChonAP.NgayChungTu);
		Dong.Insert("LoaiChungTu", ChonAP.LoaiChungTu);
		Dong.Insert("TenLoaiChungTu", ChonAP.TenLoaiChungTu);
		Dong.Insert("DoiTac", ChonAP.DoiTac);
		Dong.Insert("SoTien", ChonAP.SoTien);
		Dong.Insert("TrangThai", String(ChonAP.TrangThai));
		DanhSach.Add(Dong);
	EndDo;
	
	// Truy vấn các Ủy nhiệm chi đang chờ duyệt
	TruyVanUNC = New Query;
	TruyVanUNC.Text = 
		"SELECT TOP 20
		|	Doc.Ref AS ChungTu,
		|	Doc.Number AS SoChungTu,
		|	Doc.Date AS NgayChungTu,
		|	""UyNhiemChi"" AS LoaiChungTu,
		|	""Ủy nhiệm chi"" AS TenLoaiChungTu,
		|	Doc.NguoiThuHuong.Description AS DoiTac,
		|	Doc.TongTienThanhToan AS SoTien,
		|	Doc.TrangThaiThanhToan AS TrangThai
		|FROM
		|	Document.UyNhiemChi AS Doc
		|WHERE
		|	Doc.TrangThaiThanhToan = VALUE(Enum.TrangThaiLenhThanhToan.ChoPheDuyet)
		|	OR Doc.TrangThaiThanhToan = VALUE(Enum.TrangThaiLenhThanhToan.ChoKiemSoat)
		|ORDER BY
		|	Doc.Date DESC";
		
	KetQuaUNC = TruyVanUNC.Execute();
	ChonUNC = KetQuaUNC.Choose();
	While ChonUNC.Next() Do
		Dong = New Structure;
		Dong.Insert("ChungTu", ChonUNC.ChungTu);
		Dong.Insert("SoChungTu", ChonUNC.SoChungTu);
		Dong.Insert("NgayChungTu", ChonUNC.NgayChungTu);
		Dong.Insert("LoaiChungTu", ChonUNC.LoaiChungTu);
		Dong.Insert("TenLoaiChungTu", ChonUNC.TenLoaiChungTu);
		Dong.Insert("DoiTac", ChonUNC.DoiTac);
		Dong.Insert("SoTien", ChonUNC.SoTien);
		Dong.Insert("TrangThai", String(ChonUNC.TrangThai));
		DanhSach.Add(Dong);
	EndDo;
	
	Return DanhSach;
	
EndFunction

#EndRegion
