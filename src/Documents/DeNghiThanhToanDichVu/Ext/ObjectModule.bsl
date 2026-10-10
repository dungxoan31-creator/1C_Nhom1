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
		Raise "Vi phạm nguyên tắc Maker-Checker: Người đề nghị không thể tự phê duyệt!";
		Return;
	EndIf;
	
	// 2. Kiem tra han thanh toan
	If Not ValueIsFilled(HanThanhToan) Then
		HanThanhToan = BegOfDay(Date) + 30 * 86400; // Net 30 mac dinh
	EndIf;
EndProcedure

Procedure Posting(Cancel, Mode)
	// Chung tu de nghi thanh toan la chung tu quy trinh noi bo (Non-accounting posting)
	// Hoan tat phe duyet cho phep can cu lap UyNhiemChi
	TrangThaiDaDuyet = Enums.TrangThaiLenhThanhToan.DaDuyet;
	If TrangThai <> TrangThaiDaDuyet Then
		TrangThai = TrangThaiDaDuyet;
	EndIf;
EndProcedure

#EndRegion
