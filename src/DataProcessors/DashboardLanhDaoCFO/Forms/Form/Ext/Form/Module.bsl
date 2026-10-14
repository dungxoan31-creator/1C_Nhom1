&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	NapDuLieuDashboard();
EndProcedure

&AtClient
Procedure LamMoiAtClient(Command)
	NapDuLieuDashboardServer();
EndProcedure

&AtServer
Procedure NapDuLieuDashboardServer()
	NapDuLieuDashboard();
EndProcedure

&AtServer
Procedure NapDuLieuDashboard()
	TrangDashboardHTML = BaoCaoQuanTriServer.SinhHTMLDashboardLanhDaoCFO();
EndProcedure
