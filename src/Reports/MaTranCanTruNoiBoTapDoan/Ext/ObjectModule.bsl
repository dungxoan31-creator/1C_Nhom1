// Report: MaTranCanTruNoiBoTapDoan
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Truc quan hoa ma tran bu tru cong no noi bo da ben (Task 6.3)

#Region PublicInterface

Function TinhMaTranBuTru(DanhSachDoiTac, DanhSachAR, DanhSachAP) Export
	KetQua = New Structure;
	KetQua.Insert("TongCanTru", 0);
	KetQua.Insert("ChiTietCanTru", New Array);
	
	// Tinh tong can tru can bang giua cac don vi
	TongAR = 0;
	TongAP = 0;
	For Each Item In DanhSachAR Do
		TongAR = TongAR + Item.SoTien;
	EndDo;
	For Each Item In DanhSachAP Do
		TongAP = TongAP + Item.SoTien;
	EndDo;
	
	KetQua.TongCanTru = Min(TongAR, TongAP);
	Return KetQua;
EndFunction

// Tao bao cao ma tran can tru cong no noi bo tap doan tu du lieu thuc te
Function TaoBaoCaoMaTranNetting(Val TuNgay = Undefined, Val DenNgay = Undefined) Export
	Return BaoCaoQuanTriServer.TinhBaoCaoMaTranNetting(TuNgay, DenNgay);
EndFunction

#Region EventHandlers

Procedure OnComposeResult(ResultDocument, DetailsData, StandardProcessing)
	StandardProcessing = False;
	ResultDocument.Clear();
	
	Line = ResultDocument.TableHeight + 1;
	Area = ResultDocument.Area(Line, 1, Line, 8);
	Area.Merge();
	Area.Text = NStr("vi = 'MA TRẬN CẤN TRỪ CÔNG NỢ NỘI BỘ TẬP ĐOÀN'; en = 'INTERCOMPANY NETTING MATRIX REPORT'");
	Area.Font = New Font(, 12, True);
	
	Data = TaoBaoCaoMaTranNetting();
	Line = Line + 2;
	AreaHead = ResultDocument.Area(Line, 1, Line, 8);
	AreaHead.Text = "TỔNG GIÁ TRỊ CẤN TRỪ: " + Format(Data.TongGiaTriCanTru, "NFD=0; NGS=.") + " VND (DELTA = 0)";
	AreaHead.Font = New Font(, 10, True);
EndProcedure

#EndRegion

#EndRegion
