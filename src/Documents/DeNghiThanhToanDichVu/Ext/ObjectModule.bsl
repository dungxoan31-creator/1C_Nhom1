// Document: DeNghiThanhToanDichVu
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Chung tu de nghi thanh toan noi bo ket noi kiem tra ngan sach chi tieu (Task 4.4).

#Region EventHandlers

Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	If DataExchange.Load Then
		Return;
	EndIf;
	
	// 1. Kiem tra Maker-Checker
	If ValueIsFilled(NguoiDeNghi) And ValueIsFilled(NguoiDuyet) And NguoiDeNghi = NguoiDuyet Then
		Cancel = True;
		Msg = New UserMessage;
		Msg.Text = NStr("vi = 'Vi phạm nguyên tắc Maker-Checker: Người đề nghị không thể tự phê duyệt!'; en = 'Maker-Checker violation: Requisitioner cannot approve their own request!'");
		Msg.SetData(ThisObject);
		Msg.Field = "NguoiDuyet";
		Msg.Message();
		Return;
	EndIf;
	
	// 2. Kiem tra han thanh toan
	If Not ValueIsFilled(HanThanhToan) Then
		HanThanhToan = BegOfDay(Date) + 30 * 86400; // Net 30 mac dinh
	EndIf;
EndProcedure

Procedure Posting(Cancel, Mode)
	// Chung tu quy trinh noi bo; phe duyet phai duoc hoan tat truoc khi ghi.
	TrangThaiDaDuyet = Enums.TrangThaiLenhThanhToan.DaDuyet;
	If TrangThai <> TrangThaiDaDuyet Then
		Cancel = True;
		Msg = New UserMessage;
		Msg.Text = NStr("vi = 'Chỉ được ghi sổ đề nghị thanh toán sau khi đã được phê duyệt!'; en = 'Payment requisition can only be posted after approval!'");
		Msg.SetData(ThisObject);
		Msg.Field = "TrangThai";
		Msg.Message();
	EndIf;
EndProcedure

#EndRegion
