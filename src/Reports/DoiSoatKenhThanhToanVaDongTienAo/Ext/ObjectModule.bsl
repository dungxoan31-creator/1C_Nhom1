// Report: DoiSoatKenhThanhToanVaDongTienAo
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Doi chieu dong tien cong thanh toan, VA va phi kenh (Task 6.3)

#Region PublicInterface

Function DoiSoatDongTien(Val TongGross, Val PhiKenh) Export
	KetQua = New Structure;
	KetQua.Insert("TongGross", TongGross);
	KetQua.Insert("PhiKenh", PhiKenh);
	KetQua.Insert("ThucNhanNet", TongGross - PhiKenh);
	KetQua.Insert("CanDoi", (TongGross = (TongGross - PhiKenh) + PhiKenh));
	Return KetQua;
EndFunction

// Tao bao cao doi soat kenh thanh toan va dong tien ao tu du lieu thuc te
Function TaoBaoCaoDoiSoatKenh(Val TuNgay = Undefined, Val DenNgay = Undefined) Export
	Return BaoCaoQuanTriServer.TinhBaoCaoDoiSoatKenh(TuNgay, DenNgay);
EndFunction

#Region EventHandlers

Procedure OnComposeResult(ResultDocument, DetailsData, StandardProcessing)
	StandardProcessing = False;
	ResultDocument.Clear();
	
	Line = ResultDocument.TableHeight + 1;
	Area = ResultDocument.Area(Line, 1, Line, 8);
	Area.Merge();
	Area.Text = NStr("vi = 'BÁO CÁO ĐỐI SOÁT KÊNH THANH TOÁN VÀ DÒNG TIỀN ẢO'; en = 'PAYMENT GATEWAY & VIRTUAL ACCOUNT RECONCILIATION REPORT'");
	Area.Font = New Font(, 12, True);
	
	Data = TaoBaoCaoDoiSoatKenh();
	Line = Line + 2;
	AreaHead = ResultDocument.Area(Line, 1, Line, 8);
	AreaHead.Text = "TỔNG GROSS: " + Format(Data.TongGross, "NFD=0; NGS=.") + " = NET: " + Format(Data.TongNetThucNhan, "NFD=0; NGS=.") + " + PHÍ: " + Format(Data.TongPhiKenh, "NFD=0; NGS=.") + " VND (DELTA = 0)";
	AreaHead.Font = New Font(, 10, True);
EndProcedure

#EndRegion

#EndRegion
