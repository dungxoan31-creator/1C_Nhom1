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

#Region EventHandlers

Procedure OnComposeResult(ResultDocument, DetailsData, StandardProcessing)
	StandardProcessing = False;
	ResultDocument.Clear();
	
	Line = ResultDocument.TableHeight + 1;
	Area = ResultDocument.Area(Line, 1, Line, 6);
	Area.Merge();
	Area.Text = NStr("vi = 'BÁO CÁO ĐỐI SOÁT KÊNH THANH TOÁN VÀ DÒNG TIỀN ẢO'; en = 'PAYMENT GATEWAY & VIRTUAL ACCOUNT RECONCILIATION REPORT'");
	Area.Font = New Font(, 12, True);
EndProcedure

#EndRegion

#EndRegion
