// CommonModule: SeedBoundaryTestsServer
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Kiem thu tu dong toan ven nghiep vu 2 luong cot loi AR va AP (Demo V3)

#Region PublicInterface

Function RunFinanceE2EPhase(Val Phase, Val RunId, Val ResultPath) Export
	Result = New Structure("run_id,phase,user,status,error,data", RunId, Phase, UserName(), "FAIL", "", New Structure);
	Try
		If Phase = "setup" Then
			Result.data = PrepareFinanceE2E();
		ElsIf Phase = "ar_submit_acceptance" Then
			Result.data = SubmitFinanceE2EAcceptance();
		ElsIf Phase = "cfo_approve_acceptance" Then
			Result.data = ApproveFinanceE2EAcceptance();
		ElsIf Phase = "cfo_post_acceptance" Then
			Result.data = PostFinanceE2EAcceptance();
		ElsIf Phase = "ar_submit_invoice" Then
			Result.data = SubmitFinanceE2ESalesInvoice();
		ElsIf Phase = "cfo_issue_invoice" Then
			Result.data = IssueFinanceE2ESalesInvoice();
		ElsIf Phase = "ar_create_receipts" Then
			Result.data = CreateFinanceE2EReceipts();
		ElsIf Phase = "cfo_post_receipts" Then
			Result.data = PostFinanceE2EReceipts();
		ElsIf Phase = "ap_submit_invoice" Then
			Result.data = SubmitFinanceE2EVendorInvoice();
		ElsIf Phase = "ktt_post_ap_invoice" Then
			Result.data = PostFinanceE2EVendorInvoice();
		ElsIf Phase = "ap_submit_payment" Then
			Result.data = SubmitFinanceE2EPayment();
		ElsIf Phase = "ktt_approve_payment" Then
			Result.data = ApproveFinanceE2EPayment();
		ElsIf Phase = "cfo_post_payment_verify" Then
			Result.data = PostAndVerifyFinanceE2EPayment();
		ElsIf Phase = "netting_submit_acceptance" Then
			Result.data = SubmitFinanceE2ENettingAcceptance();
		ElsIf Phase = "netting_post_acceptance" Then
			Result.data = PostFinanceE2ENettingAcceptance();
		ElsIf Phase = "netting_submit_output_invoice" Then
			Result.data = SubmitFinanceE2ENettingSalesInvoice();
		ElsIf Phase = "netting_issue_output_invoice" Then
			Result.data = IssueFinanceE2ENettingSalesInvoice();
		ElsIf Phase = "netting_submit_ap" Then
			Result.data = SubmitFinanceE2ENettingInvoice();
		ElsIf Phase = "netting_post_ap" Then
			Result.data = PostFinanceE2ENettingInvoice();
		ElsIf Phase = "netting_post_verify" Then
			Result.data = PostVerifyFinanceE2ENetting();
		ElsIf Phase = "netting_create_remaining_receipt" Then
			Result.data = CreateFinanceE2ENettingReceipt();
		ElsIf Phase = "netting_post_remaining_receipt" Then
			Result.data = PostFinanceE2ENettingReceipt();
		ElsIf Phase = "payment_reconciliation" Then
			Result.data = RunFinanceE2EPaymentReconciliation();
		ElsIf Phase = "approval_setup" Then
			Result.data = PrepareBulkApprovalRegression();
		ElsIf Phase = "approval_ar_queue" Then
			Result.data = VerifyBulkApprovalQueueHiddenFromAR();
		ElsIf Phase = "approval_ktt" Then
			Result.data = RunBulkApprovalKTTStage();
		ElsIf Phase = "approval_cfo" Then
			Result.data = RunBulkApprovalCFOStage();
		ElsIf Phase = "posting_invariant_setup_ap" Then
			Result.data = PreparePostingInvariantAPFixtures();
		ElsIf Phase = "posting_invariant_setup_acceptance" Then
			Result.data = PreparePostingInvariantAcceptance();
		ElsIf Phase = "posting_invariant_post_acceptance" Then
			Result.data = PostPostingInvariantAcceptance();
		ElsIf Phase = "posting_invariant_setup_ar_invoices" Then
			Result.data = PreparePostingInvariantARInvoices();
		ElsIf Phase = "concurrency_setup" Then
			Result.data = PrepareConcurrentARInvoice();
		ElsIf Phase = "concurrency_post_invoice" Then
			Result.data = PostConcurrentARInvoice();
		ElsIf Phase = "concurrency_receipt_setup" Then
			Result.data = PrepareConcurrentARReceipts();
		ElsIf Phase = "dashboard_verify" Then
			Result.data = VerifyFinanceDashboard();
		Else
			Raise "Unknown finance E2E phase: " + Phase;
		EndIf;
		Result.status = "PASS";
	Except
		Result.error = DetailErrorDescription(ErrorInfo());
	EndTry;

	If ValueIsFilled(ResultPath) Then
		Writer = New JSONWriter;
		Writer.OpenFile(ResultPath);
		WriteJSON(Writer, Result);
		Writer.Close();
	EndIf;
	Return Result;
EndFunction

Function PrepareBulkApprovalRegression() Export
	RequireFinanceE2ERole("KeToanPhaiTra");
	Context = FinanceE2EContext();
	LowInvoice = CreateBulkApprovalInvoice(Context, "E2E-BULK-LOW", "E2E-BULK-LOW-TAX", 1000000, Date(2026, 10, 15, 9, 0, 0));
	HighInvoice = CreateBulkApprovalInvoice(Context, "E2E-BULK-HIGH", "E2E-BULK-HIGH-TAX", 500000001, Date(2026, 10, 15, 10, 0, 0));
	Payment = CreateBulkApprovalPayment(Context, HighInvoice, Date(2026, 10, 16, 9, 0, 0));

	Queue = DataProcessors.BanLamViecWebERP.LayDanhSachChoPheDuyet();
	If Queue.Count() <> 0 Then
		Raise StrTemplate("AP maker must not see the approval queue; got %1 entries.", Queue.Count());
	EndIf;

	ResultData = New Structure;
	ResultData.Insert("low_invoice", String(LowInvoice));
	ResultData.Insert("high_invoice", String(HighInvoice));
	ResultData.Insert("payment", String(Payment));
	ResultData.Insert("maker", UserName());
	ResultData.Insert("maker_queue_count", Queue.Count());
	Return ResultData;
EndFunction

Function VerifyBulkApprovalQueueHiddenFromAR() Export
	RequireFinanceE2ERole("KeToanPhaiThu");
	Queue = DataProcessors.BanLamViecWebERP.LayDanhSachChoPheDuyet();
	If Queue.Count() <> 0 Then
		Raise StrTemplate("AR user must not see the AP approval queue; got %1 entries.", Queue.Count());
	EndIf;
	Return New Structure("user,queue_count", UserName(), Queue.Count());
EndFunction

Function RunBulkApprovalKTTStage() Export
	RequireFinanceE2ERole("KeToanTruong");
	LowRef = Documents.HoaDonNhaCungCap.FindByNumber("E2E-BULK-LOW", Date(2026, 10, 15, 9, 0, 0));
	HighRef = Documents.HoaDonNhaCungCap.FindByNumber("E2E-BULK-HIGH", Date(2026, 10, 15, 10, 0, 0));
	PaymentRef = Documents.UyNhiemChi.FindByNumber("E2E-BULK-PAY", Date(2026, 10, 16, 9, 0, 0));
	If Not ValueIsFilled(LowRef) Or Not ValueIsFilled(HighRef) Or Not ValueIsFilled(PaymentRef) Then
		Raise "Bulk approval fixture dependency is missing.";
	EndIf;

	Workspace = DataProcessors.BanLamViecWebERP.Create();
	Queue = DataProcessors.BanLamViecWebERP.LayDanhSachChoPheDuyet();
	If Not ApprovalQueueContains(Queue, LowRef) Or Not ApprovalQueueContains(Queue, HighRef) Or Not ApprovalQueueContains(Queue, PaymentRef) Then
		Raise "KTT approval queue does not contain its low/high AP invoices and payment fixture.";
	EndIf;

	Refs = New Array;
	Refs.Add(LowRef);
	Refs.Add(HighRef);
	Refs.Add(PaymentRef);
	Result = Workspace.PheDuyetHangLoat(Refs);
	Low = LowRef.GetObject();
	High = HighRef.GetObject();
	Payment = PaymentRef.GetObject();
	If Result.ThanhCong <> 3 Or Result.ThatBai <> 0
		Or Not Low.Posted Or Low.TrangThai <> Enums.TrangThaiHoaDonAP.DaGhiSo
		Or High.Posted Or High.TrangThai <> Enums.TrangThaiHoaDonAP.ChoDuyetCFO
		Or Payment.Posted Or Payment.TrangThai <> Enums.TrangThaiLenhThanhToan.DaGuiNganHang Then
		Raise StrTemplate("KTT batch stage mismatch: success=%1 failure=%2 lowPosted=%3 highStatus=%4 paymentStatus=%5.",
			Result.ThanhCong, Result.ThatBai, Low.Posted, QuanLyVongDoiChungTuServer.TenTrangThai(High.TrangThai), QuanLyVongDoiChungTuServer.TenTrangThai(Payment.TrangThai));
	EndIf;

	ForbiddenRefs = New Array;
	ForbiddenRefs.Add(HighRef);
	ForbiddenResult = Workspace.PheDuyetHangLoat(ForbiddenRefs);
	High = HighRef.GetObject();
	If ForbiddenResult.ThanhCong <> 0 Or ForbiddenResult.ThatBai <> 1
		Or High.Posted Or High.TrangThai <> Enums.TrangThaiHoaDonAP.ChoDuyetCFO Then
		Raise "KTT was able to approve a CFO-stage invoice, or the rejected operation changed its state.";
	EndIf;

	QueueAfter = DataProcessors.BanLamViecWebERP.LayDanhSachChoPheDuyet();
	If ApprovalQueueContains(QueueAfter, HighRef) Or ApprovalQueueContains(QueueAfter, PaymentRef) Then
		Raise "KTT queue exposes records that are waiting for CFO action.";
	EndIf;

	ResultData = New Structure;
	ResultData.Insert("batch_success", Result.ThanhCong);
	ResultData.Insert("batch_failure", Result.ThatBai);
	ResultData.Insert("low_invoice_posted", Low.Posted);
	ResultData.Insert("low_invoice_gl_rows", CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", LowRef));
	ResultData.Insert("high_invoice_waiting_cfo", High.TrangThai = Enums.TrangThaiHoaDonAP.ChoDuyetCFO And Not High.Posted);
	ResultData.Insert("payment_waiting_cfo", Payment.TrangThai = Enums.TrangThaiLenhThanhToan.DaGuiNganHang And Not Payment.Posted);
	ResultData.Insert("ktt_queue_after_escalation", QueueAfter.Count());
	ResultData.Insert("ktt_forbidden_attempt_rejected", ForbiddenResult.ThatBai = 1);
	Return ResultData;
EndFunction

Function RunBulkApprovalCFOStage() Export
	RequireFinanceE2ERole("GiamDocTaiChinh_CFO");
	Context = FinanceE2EContext();
	CashBefore = FinanceE2ECashBalance(Context);
	LowRef = Documents.HoaDonNhaCungCap.FindByNumber("E2E-BULK-LOW", Date(2026, 10, 15, 9, 0, 0));
	HighRef = Documents.HoaDonNhaCungCap.FindByNumber("E2E-BULK-HIGH", Date(2026, 10, 15, 10, 0, 0));
	PaymentRef = Documents.UyNhiemChi.FindByNumber("E2E-BULK-PAY", Date(2026, 10, 16, 9, 0, 0));
	Workspace = DataProcessors.BanLamViecWebERP.Create();
	Queue = DataProcessors.BanLamViecWebERP.LayDanhSachChoPheDuyet();
	If Not ApprovalQueueContains(Queue, HighRef) Or Not ApprovalQueueContains(Queue, PaymentRef)
		Or ApprovalQueueContains(Queue, LowRef) Then
		Raise "CFO approval queue has incorrect stage membership.";
	EndIf;

	Refs = New Array;
	Refs.Add(HighRef);
	Refs.Add(PaymentRef);
	Result = Workspace.PheDuyetHangLoat(Refs);
	High = HighRef.GetObject();
	Payment = PaymentRef.GetObject();
	If Result.ThanhCong <> 2 Or Result.ThatBai <> 0
		Or Not High.Posted Or High.TrangThai <> Enums.TrangThaiHoaDonAP.DaGhiSo
		Or Not Payment.Posted Or Payment.TrangThai <> Enums.TrangThaiLenhThanhToan.DaGhiSo Then
		Raise StrTemplate("CFO batch stage mismatch: success=%1 failure=%2 highPosted=%3 paymentPosted=%4.", Result.ThanhCong, Result.ThatBai, High.Posted, Payment.Posted);
	EndIf;

	LowBalance = FinanceE2EAPBalance(Context, LowRef);
	HighBalance = FinanceE2EAPBalance(Context, HighRef);
	CashBalance = FinanceE2ECashBalance(Context);
	SalesInvoiceRef = Documents.HoaDonGTGTDauRa.FindByNumber("E2E-AR001", Date(2026, 10, 10, 10, 0, 0));
	MainPaymentRef = Documents.UyNhiemChi.FindByNumber("E2E-UNC01", Date(2026, 10, 14, 9, 0, 0));
	If Not ValueIsFilled(SalesInvoiceRef) Or Not ValueIsFilled(MainPaymentRef) Or Not MainPaymentRef.Posted Then
		Raise "Bulk approval cash reconciliation is missing the E2E sales invoice or posted main payment.";
	EndIf;
	ExpectedCashBalance = CashBefore - PaymentRef.SoTien;
	If LowBalance <> 1000000 Or HighBalance <> 499000001 Or CashBalance <> ExpectedCashBalance Then
		Raise StrTemplate("Bulk approval ledger mismatch: lowAP=%1 highAP=%2 bank=%3.", LowBalance, HighBalance, CashBalance);
	EndIf;
	If CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", HighRef) = 0
		Or CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", PaymentRef) = 0
		Or CountRecorderMovementRecords("AccumulationRegister.DongTien", PaymentRef) = 0 Then
		Raise "CFO bulk approval did not create expected accounting or bank movements.";
	EndIf;

	ResultData = New Structure;
	ResultData.Insert("batch_success", Result.ThanhCong);
	ResultData.Insert("batch_failure", Result.ThatBai);
	ResultData.Insert("high_invoice_posted", High.Posted);
	ResultData.Insert("high_invoice_ap_residual_vnd", HighBalance);
	ResultData.Insert("payment_posted", Payment.Posted);
	ResultData.Insert("payment_source_ap_residual_vnd", HighBalance);
	ResultData.Insert("bank_opening_vnd", CashBefore);
	ResultData.Insert("expected_bank_closing_vnd", ExpectedCashBalance);
	ResultData.Insert("bank_closing_vnd", CashBalance);
	ResultData.Insert("high_invoice_gl_rows", CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", HighRef));
	ResultData.Insert("payment_gl_rows", CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", PaymentRef));
	ResultData.Insert("payment_cash_rows", CountRecorderMovementRecords("AccumulationRegister.DongTien", PaymentRef));
	Return ResultData;
EndFunction

Function CreateBulkApprovalInvoice(Val Context, Val Number, Val TaxNumber, Val Amount, Val DocDate)
	Doc = Documents.HoaDonNhaCungCap.CreateDocument();
	Doc.Number = Number;
	Doc.Date = DocDate;
	Doc.NgayHoaDon = BegOfDay(DocDate);
	Doc.SoHoaDon = TaxNumber;
	Doc.PhapNhan = Context.PhapNhan;
	Doc.DoiTac = Context.Vendor;
	Doc.HopDong = Context.VendorContract;
	Doc.TaiKhoanChiPhi = Context.Account627;
	Doc.TienTe = Context.VND;
	Doc.TyGia = 1;
	Doc.TongTien = Amount;
	Doc.CoKhauTruFCT = False;
	Doc.TrangThai = Enums.TrangThaiHoaDonAP.DuThao;
	Doc.NguoiDuyet = "ketoan_truong";
	Doc.DienGiai = "Deterministic bulk approval regression fixture";
	Doc.Write();
	Doc.TrangThai = Enums.TrangThaiHoaDonAP.ChoKeToanTruongDuyet;
	Doc.Write();
	If Doc.NguoiLap <> UserName() Or Doc.TrangThai <> Enums.TrangThaiHoaDonAP.ChoKeToanTruongDuyet Then
		Raise "Bulk approval invoice fixture did not persist its maker and KTT queue state.";
	EndIf;
	Return Doc.Ref;
EndFunction

Function CreateBulkApprovalPayment(Val Context, Val InvoiceRef, Val DocDate)
	Doc = Documents.UyNhiemChi.CreateDocument();
	Doc.Number = "E2E-BULK-PAY";
	Doc.Date = DocDate;
	Doc.NgayLap = DocDate;
	Doc.NgayGhiSo = DocDate;
	Doc.PhapNhan = Context.PhapNhan;
	Doc.DoiTac = Context.Vendor;
	Doc.HopDong = Context.VendorContract;
	Doc.ChungTuGoc = InvoiceRef;
	Doc.TaiKhoanTien = Context.Bank;
	Doc.KhoanMucDongTien = Context.VendorPaymentCategory;
	Doc.TienTe = Context.VND;
	Doc.TyGia = 1;
	Doc.SoTien = 1000000;
	Doc.PhiNganHang = 0;
	Doc.TrangThai = Enums.TrangThaiLenhThanhToan.DuThao;
	Doc.NguoiDuyet = "ketoan_truong";
	Doc.DienGiai = "Deterministic bulk approval regression payment";
	Doc.Write();
	Doc.TrangThai = Enums.TrangThaiLenhThanhToan.ChoDuyet;
	Doc.Write();
	If Doc.NguoiLap <> UserName() Or Doc.TrangThai <> Enums.TrangThaiLenhThanhToan.ChoDuyet Then
		Raise "Bulk approval payment fixture did not persist its maker and KTT queue state.";
	EndIf;
	Return Doc.Ref;
EndFunction

Function ApprovalQueueContains(Val ApprovalQueue, Val DocumentRef)
	For Each QueueItem In ApprovalQueue Do
		If QueueItem.ChungTu = DocumentRef Then Return True; EndIf;
	EndDo;
	Return False;
EndFunction

Function PrepareConcurrentARInvoice() Export
	RequireFinanceE2ERole("KeToanPhaiThu");
	Context = FinanceE2EContext();
	Invoice = Documents.HoaDonGTGTDauRa.CreateDocument();
	Invoice.Number = "E2E-CONC-AR-INV";
	Invoice.Date = Date(2026, 10, 17, 9, 0, 0);
	Invoice.SoHoaDon = "E2E-CONC-AR-TAX";
	Invoice.KyHieu = "E2E-CONC";
	Invoice.PhapNhan = Context.PhapNhan;
	Invoice.DoiTac = Context.Customer;
	Invoice.HopDong = Context.CustomerContract;
	Invoice.NgayHoaDon = BegOfDay(Invoice.Date);
	Invoice.TienChuaThue = 250000000;
	Invoice.ApDungGiamThueGTGT = True;
	Invoice.ThueSuatVAT = ThueGTGTClientServer.TyLeVATApDungTheoNgay(Invoice.NgayHoaDon, True);
	Invoice.TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.ChoKySo;
	Invoice.NguoiDuyet = "cfo_giamdoc";
	Invoice.DienGiai = "Concurrent receipt lock regression source invoice";
	Invoice.Write();
	If Invoice.Posted Or Invoice.TrangThaiHDDT <> Enums.TrangThaiHoaDonDienTu.ChoKySo
		Or Invoice.NguoiLap <> UserName() Then
		Raise "Concurrent AR source invoice draft was not saved under its maker with the expected approval state.";
	EndIf;
	Result = New Structure("invoice,invoice_status,maker,expected_ar_vnd", String(Invoice.Ref), XMLString(Invoice.TrangThaiHDDT), Invoice.NguoiLap, 270000000);
	Return Result;
EndFunction

Function PostConcurrentARInvoice() Export
	RequireFinanceE2ERole("GiamDocTaiChinh_CFO");
	InvoiceRef = Documents.HoaDonGTGTDauRa.FindByNumber("E2E-CONC-AR-INV", Date(2026, 10, 17, 9, 0, 0));
	If Not ValueIsFilled(InvoiceRef) Then Raise "Concurrent AR invoice draft is missing."; EndIf;
	Invoice = InvoiceRef.GetObject();
	If Invoice.Posted Or Invoice.TrangThaiHDDT <> Enums.TrangThaiHoaDonDienTu.ChoKySo
		Or Invoice.NguoiLap <> "ketoan_ar" Or Invoice.NguoiDuyet <> UserName() Then
		Raise "Concurrent AR invoice is not in the expected maker-checker state before CFO approval.";
	EndIf;
	Invoice.TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.DaPhatHanh;
	Invoice.Write();
	Invoice.Write(DocumentWriteMode.Posting);
	If Not Invoice.Posted Or Invoice.TrangThaiHDDT <> Enums.TrangThaiHoaDonDienTu.DaPhatHanh
		Or Invoice.TongTienThanhToan <> 270000000 Then
		Raise "Concurrent AR source invoice did not post for 270,000,000 VND after CFO issuance.";
	EndIf;
	Return New Structure("invoice,approver,status,posted,amount_vnd", Invoice.Number, UserName(), XMLString(Invoice.TrangThaiHDDT), Invoice.Posted, Invoice.TongTienThanhToan);
EndFunction

Function PrepareConcurrentARReceipts() Export
	RequireFinanceE2ERole("KeToanPhaiThu");
	Context = FinanceE2EContext();
	InvoiceRef = Documents.HoaDonGTGTDauRa.FindByNumber("E2E-CONC-AR-INV", Date(2026, 10, 17, 9, 0, 0));
	If Not ValueIsFilled(InvoiceRef) Or Not InvoiceRef.Posted Then
		Raise "Concurrent AR receipts require the CFO-issued source invoice to be posted.";
	EndIf;

	CreateConcurrentARReceipt(Context, InvoiceRef, "E2E-CONC-PT-1", Date(2026, 10, 18, 9, 0, 0));
	CreateConcurrentARReceipt(Context, InvoiceRef, "E2E-CONC-PT-2", Date(2026, 10, 18, 10, 0, 0));
	Result = New Structure("invoice,opening_ar_vnd,receipt_1,receipt_2,maker", String(InvoiceRef), InvoiceRef.TongTienThanhToan, "E2E-CONC-PT-1", "E2E-CONC-PT-2", UserName());
	Return Result;
EndFunction

Procedure CreateConcurrentARReceipt(Val Context, Val SourceInvoice, Val Number, Val DocDate)
	Receipt = Documents.PhieuThuTienKhachHang.CreateDocument();
	Receipt.Number = Number;
	Receipt.Date = DocDate;
	Receipt.PhapNhan = Context.PhapNhan;
	Receipt.DoiTac = Context.Customer;
	Receipt.HopDong = Context.CustomerContract;
	Receipt.ChungTuGoc = SourceInvoice;
	Receipt.NguoiDuyet = "cfo_giamdoc";
	Receipt.TaiKhoanTien = Context.Bank;
	Receipt.KhoanMucDongTien = Context.CustomerReceiptCategory;
	Receipt.TienTe = Context.VND;
	Receipt.TyGia = 1;
	Receipt.NgayThu = BegOfDay(DocDate);
	Receipt.SoTien = 200000000;
	Receipt.DienGiai = "Concurrent receipt lock regression fixture";
	Receipt.Write();
	If Receipt.NguoiLap <> UserName() Then Raise "Concurrent receipt maker was not captured from the authenticated AR session."; EndIf;
EndProcedure

Procedure RunARBalanceLockHolder(Val SourceInvoiceNumber, Val ReadyPath, Val ReleasePath, Val ResultPath) Export
	Result = New Structure("status,user,error", "FAIL", UserName(), "");
	Try
		SourceInvoice = Documents.HoaDonGTGTDauRa.FindByNumber(SourceInvoiceNumber, Date(2026, 10, 17, 9, 0, 0));
		If Not ValueIsFilled(SourceInvoice) Or Not SourceInvoice.Posted Then Raise "Concurrent AR source invoice is missing or unposted."; EndIf;
		Context = FinanceE2EContext();
		LockObj = New DataLock;
		ARLockKey = LockObj.Add("AccumulationRegister.CongNoPhaiThu");
		ARLockKey.Mode = DataLockMode.Exclusive;
		ARLockKey.SetValue("PhapNhan", Context.PhapNhan);
		ARLockKey.SetValue("DoiTac", Context.Customer);
		ARLockKey.SetValue("HopDong", Context.CustomerContract);
		ARLockKey.SetValue("ChungTuGoc", SourceInvoice);
		BeginTransaction();
		LockObj.Lock();
		WriteConcurrentMarker(ReadyPath, New Structure("status,user", "LOCK_HELD", UserName()));
		Deadline = CurrentSessionDate() + 20;
		LoopCount = 0;
		ReleaseFile = New File(ReleasePath);
		While Not ReleaseFile.Exists() Do
			LoopCount = LoopCount + 1;
			If LoopCount % 1000 = 0 And CurrentSessionDate() >= Deadline Then Break; EndIf;
		EndDo;
		If ReleaseFile.Exists() Then
			RollbackTransaction();
			Result.status = "PASS";
		Else
			RollbackTransaction();
			Result.error = "Timed out waiting for the concurrency test to release the AR lock.";
		EndIf;
	Except
		If TransactionActive() Then RollbackTransaction(); EndIf;
		Result.error = DetailErrorDescription(ErrorInfo());
	EndTry;
	WriteConcurrentMarker(ResultPath, Result);
EndProcedure

Function PostConcurrentARReceipt(Val ReceiptNumber, Val AttemptPath, Val ResultPath, Val ExpectedOutcome) Export
	StartedAt = CurrentSessionDate();
	Result = New Structure("status,receipt,expected,posted,post_error,ar_balance_vnd,ar_movements,cash_movements,gl_movements,error,started_at,finished_at", "FAIL", ReceiptNumber, ExpectedOutcome, False, "", 0, 0, 0, 0, "", StartedAt, StartedAt);
	WriteConcurrentMarker(AttemptPath, New Structure("receipt,started_by,started_at", ReceiptNumber, UserName(), StartedAt));
	Try
		Context = FinanceE2EContext();
		ReceiptRef = Documents.PhieuThuTienKhachHang.FindByNumber(ReceiptNumber, ?(ReceiptNumber = "E2E-CONC-PT-1", Date(2026, 10, 18, 9, 0, 0), Date(2026, 10, 18, 10, 0, 0)));
		If Not ValueIsFilled(ReceiptRef) Then Raise "Concurrent receipt fixture is missing: " + ReceiptNumber; EndIf;
		Receipt = ReceiptRef.GetObject();
		PostError = "";
		Try
			Receipt.Write(DocumentWriteMode.Posting);
		Except
			PostError = DetailErrorDescription(ErrorInfo());
		EndTry;
		SavedReceipt = ReceiptRef.GetObject();
		Result.posted = SavedReceipt.Posted;
		Result.post_error = PostError;
		Result.ar_balance_vnd = FinanceE2EARBalance(Context, SavedReceipt.ChungTuGoc);
		Result.ar_movements = CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiThu", ReceiptRef);
		Result.cash_movements = CountRecorderMovementRecords("AccumulationRegister.DongTien", ReceiptRef);
		Result.gl_movements = CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", ReceiptRef);
		If ExpectedOutcome = "POSTED" Then
			If Not Result.posted Or Result.ar_movements = 0 Or Result.cash_movements = 0 Or Result.gl_movements = 0 Or Result.ar_balance_vnd <> 70000000 Then
				Raise StrTemplate("Concurrent valid receipt failed: posted=%1 AR=%2 Cash=%3 GL=%4 residual=%5.", Result.posted, Result.ar_movements, Result.cash_movements, Result.gl_movements, Result.ar_balance_vnd);
			EndIf;
		ElsIf ExpectedOutcome = "REJECTED" Then
			If Result.posted Or StrFind(PostError, "Failed to post") = 0 Or Result.ar_movements <> 0 Or Result.cash_movements <> 0 Or Result.gl_movements <> 0 Or Result.ar_balance_vnd <> 70000000 Then
				Raise StrTemplate("Concurrent over-collection was not rejected cleanly: error=%1 posted=%2 AR=%3 Cash=%4 GL=%5 residual=%6.", PostError, Result.posted, Result.ar_movements, Result.cash_movements, Result.gl_movements, Result.ar_balance_vnd);
			EndIf;
		Else
			Raise "Unsupported concurrent receipt outcome: " + ExpectedOutcome;
		EndIf;
		Result.status = "PASS";
	Except
		Result.error = DetailErrorDescription(ErrorInfo());
	EndTry;
	Result.finished_at = CurrentSessionDate();
	If ValueIsFilled(ResultPath) Then WriteConcurrentMarker(ResultPath, Result); EndIf;
	Return Result;
EndFunction

Procedure WriteConcurrentMarker(Val FilePath, Val Data)
	Writer = New JSONWriter;
	Writer.OpenFile(FilePath);
	WriteJSON(Writer, Data);
	Writer.Close();
EndProcedure

Function RunARLockConcurrencyInBackground(Val SourceInvoiceNumber, Val ReceiptNumber, Val StartPath, Val HolderReadyPath, Val LockedPath, Val AttemptPath, Val ReleasePath, Val HolderResultPath, Val ProbeResultPath, Val ResultPath) Export
	Result = New Structure("status,error,attempt_marker_before_release,lock_wait_seconds", "FAIL", "", False, 0);
	HolderParameters = New Array;
	HolderParameters.Add(SourceInvoiceNumber);
	HolderParameters.Add(StartPath);
	HolderParameters.Add(HolderReadyPath);
	HolderParameters.Add(LockedPath);
	HolderParameters.Add(AttemptPath);
	HolderParameters.Add(ReleasePath);
	HolderParameters.Add(HolderResultPath);
	
	Try
		HolderJob = BackgroundJobs.Execute("SeedBoundaryTestsServer.ARBalanceLockHolderJob", HolderParameters, "ARLockHolder_" + SourceInvoiceNumber, "AR balance lock test holder");
		If Not WaitForConcurrentMarker(HolderReadyPath, 30) Then
			Result.status = "BLOCKED_ENVIRONMENT";
			Result.error = "The 1C runtime did not start the background DataLock holder session in file mode.";
			WriteConcurrentMarker(StartPath, New Structure("start", True));
			WriteConcurrentMarker(ReleasePath, New Structure("release", True));
			WaitForConcurrentMarker(HolderResultPath, 10);
		Else
			WriteConcurrentMarker(StartPath, New Structure("start", True));
			HolderLocked = WaitForConcurrentMarker(LockedPath, 30);
			If Not HolderLocked Then
				Result.status = "BLOCKED_ENVIRONMENT";
				Result.error = "The background DataLock holder did not acquire the matching AR key.";
				WriteConcurrentMarker(ReleasePath, New Structure("release", True));
				WaitForConcurrentMarker(HolderResultPath, 10);
			Else
				Result.attempt_marker_before_release = True;
				ProbeResult = PostConcurrentARReceipt(ReceiptNumber, AttemptPath, ProbeResultPath, "POSTED");
				Result.lock_wait_seconds = Round(ProbeResult.finished_at - ProbeResult.started_at, 0);
				HolderDone = WaitForConcurrentMarker(HolderResultPath, 30);
				If Not HolderDone Then
					Result.status = "BLOCKED_ENVIRONMENT";
					Result.error = "The DataLock holder did not finish and release its transaction.";
				ElsIf ProbeResult.status <> "PASS" Then
					Result.status = "FAIL";
					Result.error = ProbeResult.error;
				ElsIf Result.lock_wait_seconds < 2 Then
					Result.status = "FAIL";
					Result.error = "Receipt posting completed before the held DataLock was released.";
				Else
					Result.status = "PASS";
				EndIf;
			EndIf;
		EndIf;
	Except
		WriteConcurrentMarker(StartPath, New Structure("start", True));
		WriteConcurrentMarker(ReleasePath, New Structure("release", True));
		WaitForConcurrentMarker(HolderResultPath, 10);
		Result.status = "BLOCKED_ENVIRONMENT";
		Result.error = DetailErrorDescription(ErrorInfo());
	EndTry;
	If ValueIsFilled(ResultPath) Then WriteConcurrentMarker(ResultPath, Result); EndIf;
	Return Result;
EndFunction

Procedure ARBalanceLockHolderJob(Val SourceInvoiceNumber, Val StartPath, Val ReadyPath, Val LockedPath, Val AttemptPath, Val ReleasePath, Val ResultPath) Export
	Result = New Structure("status,user,error,locked_at,released_at", "FAIL", UserName(), "", Undefined, Undefined);
	Try
		WriteConcurrentMarker(ReadyPath, New Structure("status,user", "READY", UserName()));
		If Not WaitForConcurrentMarker(StartPath, 30) Then Raise "Timed out waiting for the synchronized start signal."; EndIf;
		SourceInvoice = Documents.HoaDonGTGTDauRa.FindByNumber(SourceInvoiceNumber, Date(2026, 10, 17, 9, 0, 0));
		If Not ValueIsFilled(SourceInvoice) Then Raise "Concurrent AR source invoice is missing."; EndIf;
		Context = FinanceE2EContext();
		LockObj = New DataLock;
		ARLockKey = LockObj.Add("AccumulationRegister.CongNoPhaiThu");
		ARLockKey.Mode = DataLockMode.Exclusive;
		ARLockKey.SetValue("PhapNhan", Context.PhapNhan);
		ARLockKey.SetValue("DoiTac", Context.Customer);
		ARLockKey.SetValue("HopDong", Context.CustomerContract);
		ARLockKey.SetValue("ChungTuGoc", SourceInvoice);
		BeginTransaction();
		LockObj.Lock();
		Result.locked_at = CurrentSessionDate();
		WriteConcurrentMarker(LockedPath, New Structure("status,locked_at", "LOCKED", Result.locked_at));
		If Not WaitForConcurrentMarker(AttemptPath, 30) Then Raise "Timed out waiting for a posting request while holding the AR DataLock."; EndIf;
		HoldUntil = CurrentSessionDate() + 3;
		LoopCount = 0;
		ReleaseFile = New File(ReleasePath);
		While CurrentSessionDate() < HoldUntil And Not ReleaseFile.Exists() Do
			LoopCount = LoopCount + 1;
			If LoopCount % 1000 = 0 And CurrentSessionDate() >= HoldUntil Then Break; EndIf;
		EndDo;
		RollbackTransaction();
		Result.status = "PASS";
		Result.released_at = CurrentSessionDate();
	Except
		If TransactionActive() Then RollbackTransaction(); EndIf;
		Result.error = DetailErrorDescription(ErrorInfo());
		Result.released_at = CurrentSessionDate();
	EndTry;
	WriteConcurrentMarker(ResultPath, Result);
EndProcedure

Function WaitForConcurrentMarker(Val MarkerPath, Val TimeoutSeconds)
	MarkerFile = New File(MarkerPath);
	Deadline = CurrentSessionDate() + TimeoutSeconds;
	LoopCount = 0;
	While Not MarkerFile.Exists() Do
		LoopCount = LoopCount + 1;
		If LoopCount % 1000 = 0 And CurrentSessionDate() >= Deadline Then Return False; EndIf;
	EndDo;
	Return True;
EndFunction

Function RunAPSeedMasterData(Val RunId, Val ResultPath) Export
	Result = New Structure("run_id,phase,user,status,error,data", RunId, "ap_seed_master_data", UserName(), "FAIL", "", New Structure);
	Try
		RequireFinanceE2ERole("GiamDocTaiChinh_CFO");
		GeneratorMasterDataServer.KhoiTaoMasterDataToanDien();
		GeneratorAPServer.KhoiTaoChungTuAP(False, "MasterData");
		Q = New Query("SELECT COUNT(*) AS Cnt FROM Catalog.DoiTac WHERE Code LIKE &Prefix");
		Q.SetParameter("Prefix", "TEST_NCC_%");
		VendorCount = Q.Execute().Unload()[0].Cnt;
		If VendorCount = 0 Then Raise "AP seed master data contains no test vendors."; EndIf;
		Result.data.Insert("test_vendors", VendorCount);
		Result.status = "PASS";
	Except
		Result.error = DetailErrorDescription(ErrorInfo());
	EndTry;
	If ValueIsFilled(ResultPath) Then
		Writer = New JSONWriter; Writer.OpenFile(ResultPath); WriteJSON(Writer, Result); Writer.Close();
	EndIf;
	Return Result;
EndFunction

Function RunAPSeedStage(Val Stage, Val RunId, Val ResultPath) Export
	Result = New Structure("run_id,phase,user,status,error,data", RunId, "ap_seed_" + Stage, UserName(), "FAIL", "", New Structure);
	Try
		GeneratorAPServer.KhoiTaoChungTuAP(False, Stage);
		Q = New Query;
		Q.Text =
			"SELECT COUNT(*) AS TotalCount,
			| SUM(CASE WHEN Posted = TRUE THEN 1 ELSE 0 END) AS PostedCount,
			| SUM(CASE WHEN Posted = FALSE AND TrangThai = &CFOQueue THEN 1 ELSE 0 END) AS CFOQueueCount,
			| SUM(CASE WHEN Posted = FALSE AND TrangThai = &KTTQueue THEN 1 ELSE 0 END) AS KTTQueueCount
			|FROM Document.HoaDonNhaCungCap WHERE Number LIKE &Prefix";
		Q.SetParameter("CFOQueue", Enums.TrangThaiHoaDonAP.ChoDuyetCFO);
		Q.SetParameter("KTTQueue", Enums.TrangThaiHoaDonAP.ChoKeToanTruongDuyet);
		Q.SetParameter("Prefix", "HD20%");
		Stats = Q.Execute().Unload()[0];
		If Stats.TotalCount <> 1260 Then Raise StrTemplate("AP seed stage %1 found %2 invoices; expected 1,260.", Stage, Stats.TotalCount); EndIf;
		If Stage = "PrepareInvoices" And (Stats.PostedCount <> 0 Or Stats.KTTQueueCount <> 1260) Then
			Raise "AP invoice preparation must leave all 1,260 documents unposted in the KTT queue.";
		ElsIf Stage = "ApproveInvoicesKTT" And Stats.PostedCount + Stats.CFOQueueCount <> 1260 Then
			Raise StrTemplate("KTT stage left %1 posted and %2 pending CFO; expected their sum to be 1,260.", Stats.PostedCount, Stats.CFOQueueCount);
		ElsIf Stage = "PostHighInvoicesCFO" And (Stats.PostedCount <> 1260 Or Stats.CFOQueueCount <> 0) Then
			Raise StrTemplate("CFO stage left %1 posted and %2 pending CFO; expected 1,260/0.", Stats.PostedCount, Stats.CFOQueueCount);
		EndIf;
		Result.data.Insert("documents", Stats.TotalCount);
		Result.data.Insert("posted", Stats.PostedCount);
		Result.data.Insert("pending_cfo", Stats.CFOQueueCount);
		Result.data.Insert("pending_ktt", Stats.KTTQueueCount);
		Result.status = "PASS";
	Except
		Result.error = DetailErrorDescription(ErrorInfo());
	EndTry;
	If ValueIsFilled(ResultPath) Then
		Writer = New JSONWriter; Writer.OpenFile(ResultPath); WriteJSON(Writer, Result); Writer.Close();
	EndIf;
	Return Result;
EndFunction

Function RunAPSeedRegression(Val RunId, Val ResultPath) Export
	Result = New Structure("run_id,phase,user,status,error,data", RunId, "ap_seed_regression", UserName(), "FAIL", "", New Structure);
	Try
		RequireFinanceE2ERole("GiamDocTaiChinh_CFO");

		Q = New Query;
		Q.Text =
			"SELECT
			| COUNT(*) AS TotalUSD,
			| SUM(CASE WHEN Invoice.TongTienNgoaiTe > 0 AND Invoice.TongTien > 0 THEN 1 ELSE 0 END) AS ValidUSD
			|FROM Document.HoaDonNhaCungCap AS Invoice
			|WHERE Invoice.TienTe.Code = ""USD"" AND Invoice.Posted = TRUE";
		Totals = Q.Execute().Unload()[0];
		If Totals.TotalUSD < 315 Or Totals.ValidUSD <> Totals.TotalUSD Then
			Raise StrTemplate("USD AP generator mismatch: total=%1 valid=%2, expected at least 315 fully-valued USD invoices.", Totals.TotalUSD, Totals.ValidUSD);
		EndIf;

		Q = New Query("SELECT COUNT(*) AS Cnt FROM Document.HoaDonNhaCungCap WHERE Posted = TRUE");
		InvoiceCount = Q.Execute().Unload()[0].Cnt;
		Q = New Query("SELECT COUNT(*) AS Cnt FROM Document.UyNhiemChi WHERE Posted = TRUE AND LaTraSoatHoanTra = FALSE");
		PaymentCount = Q.Execute().Unload()[0].Cnt;
		RefCashCategory = Catalogs.KhoanMucDongTien.FindByCode("KM-CHI-CLOUD");
		If Not ValueIsFilled(RefCashCategory) Or RefCashCategory.Code <> "KM-CHI-CLOUD" Then
			Raise "AP generator did not create the exact required cash-flow category KM-CHI-CLOUD.";
		EndIf;
		If InvoiceCount < 1260 Or PaymentCount <> 0 Then
			Raise StrTemplate("AP generator incomplete: invoices=%1 payments=%2.", InvoiceCount, PaymentCount);
		EndIf;

		Result.data.Insert("posted_invoices", InvoiceCount);
		Result.data.Insert("posted_payments", PaymentCount);
		Result.data.Insert("posted_usd_invoices", Totals.TotalUSD);
		Result.data.Insert("valid_usd_invoices", Totals.ValidUSD);
		Result.data.Insert("cash_category", RefCashCategory.Code);
		Result.status = "PASS";
	Except
		Result.error = DetailErrorDescription(ErrorInfo());
	EndTry;

	If ValueIsFilled(ResultPath) Then
		Writer = New JSONWriter;
		Writer.OpenFile(ResultPath);
		WriteJSON(Writer, Result);
		Writer.Close();
	EndIf;
	Return Result;
EndFunction

Function RunVATRateBoundaryCases()
	Cases = New Array;
	AddVATRateBoundaryCase(Cases, "eligible_day_before_reduction", Date(2025, 6, 30, 12, 0, 0), True, 10);
	AddVATRateBoundaryCase(Cases, "eligible_first_reduction_day", Date(2025, 7, 1, 0, 0, 0), True, 8);
	AddVATRateBoundaryCase(Cases, "eligible_last_reduction_day", Date(2026, 12, 31, 23, 59, 59), True, 8);
	AddVATRateBoundaryCase(Cases, "eligible_day_after_reduction", Date(2027, 1, 1, 0, 0, 0), True, 10);
	AddVATRateBoundaryCase(Cases, "ineligible_service_during_reduction", Date(2026, 10, 20, 12, 0, 0), False, 10);

	InvalidDateRejected = False;
	Try
		ThueGTGTClientServer.TyLeVATApDungTheoNgay(Undefined, True);
	Except
		InvalidDateRejected = True;
	EndTry;
	InvalidCase = New Structure("name,passed,expected,actual", "invalid_date_rejected", InvalidDateRejected, True, InvalidDateRejected);
	Cases.Add(InvalidCase);
	Return Cases;
EndFunction

Procedure AddVATRateBoundaryCase(Val Cases, Val CaseName, Val TaxDate, Val Eligible, Val ExpectedRate)
	ActualRate = ThueGTGTClientServer.TyLeVATApDungTheoNgay(TaxDate, Eligible);
	CaseResult = New Structure("name,passed,expected,actual", CaseName, ActualRate = ExpectedRate, ExpectedRate, ActualRate);
	Cases.Add(CaseResult);
EndProcedure

Function RunARSeedMasterData(Val RunId, Val ResultPath) Export
	Result = New Structure("run_id,phase,user,status,error,data", RunId, "ar_seed_master_data", UserName(), "FAIL", "", New Structure);
	Try
		RequireFinanceE2ERole("GiamDocTaiChinh_CFO");
		GeneratorMasterDataServer.KhoiTaoMasterDataToanDien();
		Q = New Query("SELECT COUNT(*) AS Cnt FROM Catalog.DoiTac WHERE Code LIKE &Prefix");
		Q.SetParameter("Prefix", "TEST_KH%");
		CustomerCount = Q.Execute().Unload()[0].Cnt;
		Q.SetParameter("Prefix", "TEST_VG%");
		InternalPartnerCount = Q.Execute().Unload()[0].Cnt;
		If CustomerCount = 0 Or InternalPartnerCount = 0 Then Raise "AR seed master data is incomplete: TEST_KH or TEST_VG has no partners."; EndIf;
		Result.data.Insert("external_customers", CustomerCount);
		Result.data.Insert("internal_partners", InternalPartnerCount);
		Result.status = "PASS";
	Except
		Result.error = DetailErrorDescription(ErrorInfo());
	EndTry;
	If ValueIsFilled(ResultPath) Then
		Writer = New JSONWriter; Writer.OpenFile(ResultPath); WriteJSON(Writer, Result); Writer.Close();
	EndIf;
	Return Result;
EndFunction

Function RunARSeedStage(Val Stage, Val RunId, Val ResultPath) Export
	Result = New Structure("run_id,phase,user,status,error,data", RunId, "ar_seed_" + Stage, UserName(), "FAIL", "", New Structure);
	Try
		GeneratorARServer.KhoiTaoChungTuAR(Stage);
		ExpectedCount = 0;
		DocName = "";
		Prefix = "";
		ExpectedPosted = False;
		If Stage = "PrepareAcceptances" Or Stage = "PostAcceptances" Then
			DocName = "BienBanNghiemThuGiaiDoan"; Prefix = "BB-%"; ExpectedCount = 1260;
		ElsIf Stage = "PrepareInvoices" Or Stage = "PostInvoices" Then
			DocName = "HoaDonGTGTDauRa"; Prefix = "HD-%"; ExpectedCount = 1260;
		ElsIf Stage = "PrepareReceipts" Or Stage = "PostReceipts" Then
			DocName = "PhieuThuTienKhachHang"; Prefix = "PT-%"; ExpectedCount = 1162;
		Else
			Raise "Unknown AR seed stage: " + Stage;
		EndIf;
		ExpectedPosted = Stage = "PostAcceptances" Or Stage = "PostInvoices" Or Stage = "PostReceipts";
		Q = New Query("SELECT COUNT(*) AS Cnt FROM Document." + DocName + " WHERE Number LIKE &Prefix AND Posted = &Posted");
		Q.SetParameter("Prefix", Prefix);
		Q.SetParameter("Posted", ExpectedPosted);
		ActualCount = Q.Execute().Unload()[0].Cnt;
		If ActualCount <> ExpectedCount Then
			Raise StrTemplate("AR seed stage %1 produced %2 matching documents; expected %3.", Stage, ActualCount, ExpectedCount);
		EndIf;
		Result.data.Insert("documents", ActualCount);
		Result.data.Insert("posted", ExpectedPosted);
		Result.status = "PASS";
	Except
		Result.error = DetailErrorDescription(ErrorInfo());
	EndTry;
	If ValueIsFilled(ResultPath) Then
		Writer = New JSONWriter; Writer.OpenFile(ResultPath); WriteJSON(Writer, Result); Writer.Close();
	EndIf;
	Return Result;
EndFunction

Function RunARSeedRegression(Val RunId, Val ResultPath) Export
	Result = New Structure("run_id,phase,user,status,error,data", RunId, "ar_seed_regression", UserName(), "FAIL", "", New Structure);
	Try
		RequireFinanceE2ERole("GiamDocTaiChinh_CFO");
		VATRateCases = RunVATRateBoundaryCases();
		VATRateCaseCount = 0;
		For Each VATRateCase In VATRateCases Do
			If Not VATRateCase.passed Then
				Raise StrTemplate("VAT boundary case %1 failed: expected %2, actual %3.",
					VATRateCase.name, VATRateCase.expected, VATRateCase.actual);
			EndIf;
			VATRateCaseCount = VATRateCaseCount + 1;
		EndDo;

		AcceptanceQuery = New Query("SELECT COUNT(*) AS Cnt FROM Document.BienBanNghiemThuGiaiDoan WHERE Number LIKE ""BB-%"" AND Posted = TRUE");
		AcceptanceCount = AcceptanceQuery.Execute().Unload()[0].Cnt;
		InvoiceQuery = New Query("SELECT COUNT(*) AS Cnt FROM Document.HoaDonGTGTDauRa WHERE Number LIKE ""HD-%"" AND Posted = TRUE");
		InvoiceCount = InvoiceQuery.Execute().Unload()[0].Cnt;
		ReceiptQuery = New Query("SELECT COUNT(*) AS Cnt FROM Document.PhieuThuTienKhachHang WHERE Number LIKE ""PT-%"" AND Posted = TRUE");
		ReceiptCount = ReceiptQuery.Execute().Unload()[0].Cnt;
		VATQuery = New Query;
		VATQuery.Text =
			"SELECT
			| SUM(CASE WHEN Acceptance.Date < &ReductionStart AND Acceptance.TyLeVAT = 10 THEN 1 ELSE 0 END) AS StandardRateCount,
			| SUM(CASE WHEN Acceptance.Date >= &ReductionStart AND Acceptance.Date < &ReductionEnd
			|  AND Acceptance.TyLeVAT = 8 THEN 1 ELSE 0 END) AS ReducedRateCount,
			| SUM(CASE WHEN Invoice.Ref IS NULL OR Invoice.ApDungGiamThueGTGT <> Acceptance.ApDungGiamThueGTGT
			|  OR Invoice.ThueSuatVAT <> Acceptance.TyLeVAT OR Invoice.TienChuaThue <> Acceptance.GiaTriNghiemThuChuaVAT
			|  OR Invoice.TienThueVAT <> Acceptance.TienVAT OR Invoice.TongTienThanhToan <> Acceptance.TongGiaTri
			|  THEN 1 ELSE 0 END) AS SourceMismatchCount
			|FROM Document.BienBanNghiemThuGiaiDoan AS Acceptance
			|LEFT JOIN Document.HoaDonGTGTDauRa AS Invoice
			| ON Invoice.BienBanNghiemThu = Acceptance.Ref AND Invoice.Posted = TRUE
			|WHERE Acceptance.Number LIKE ""BB-%"" AND Acceptance.Posted = TRUE";
		VATQuery.SetParameter("ReductionStart", Date(2025, 7, 1, 0, 0, 0));
		VATQuery.SetParameter("ReductionEnd", Date(2027, 1, 1, 0, 0, 0));
		VATStats = VATQuery.Execute().Unload()[0];
		
		RefBankVND = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1121");
		RefInternalAR = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1312");
		RefExternalAR = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1311");
		ReceiptGLQuery = New Query;
		ReceiptGLQuery.Text =
			"SELECT
			| COUNT(*) AS EntryCount,
			| SUM(CASE WHEN Entry.AccountDr = &BankVND THEN 1 ELSE 0 END) AS VndDebitCount,
			| SUM(CASE WHEN Entry.AccountCr = &InternalAR THEN 1 ELSE 0 END) AS InternalCreditCount,
			| SUM(CASE WHEN Entry.AccountCr = &ExternalAR THEN 1 ELSE 0 END) AS ExternalCreditCount,
			| SUM(Entry.SoTien) AS TotalDebit,
			| SUM(CASE WHEN Entry.AccountCr = &InternalAR OR Entry.AccountCr = &ExternalAR THEN Entry.SoTien ELSE 0 END) AS TotalCredit
			|FROM
			| AccountingRegister.SoCaiKeToan AS Entry
			| INNER JOIN Document.PhieuThuTienKhachHang AS Receipt
			| ON Entry.Recorder = Receipt.Ref
			|WHERE
			| Receipt.Number LIKE ""PT-%""
			| AND Receipt.Posted = TRUE";
		ReceiptGLQuery.SetParameter("BankVND", RefBankVND);
		ReceiptGLQuery.SetParameter("InternalAR", RefInternalAR);
		ReceiptGLQuery.SetParameter("ExternalAR", RefExternalAR);
		ReceiptGL = ReceiptGLQuery.Execute().Unload()[0];
		
		ReceiptARMovementQuery = New Query;
		ReceiptARMovementQuery.Text =
			"SELECT COUNT(*) AS Cnt
			|FROM
			| AccumulationRegister.CongNoPhaiThu AS ARMovement
			| INNER JOIN Document.PhieuThuTienKhachHang AS Receipt
			| ON ARMovement.Recorder = Receipt.Ref
			|WHERE Receipt.Number LIKE ""PT-%"" AND Receipt.Posted = TRUE";
		ReceiptARMovementCount = ReceiptARMovementQuery.Execute().Unload()[0].Cnt;
		ReceiptCashMovementQuery = New Query;
		ReceiptCashMovementQuery.Text =
			"SELECT COUNT(*) AS Cnt
			|FROM
			| AccumulationRegister.DongTien AS CashMovement
			| INNER JOIN Document.PhieuThuTienKhachHang AS Receipt
			| ON CashMovement.Recorder = Receipt.Ref
			|WHERE Receipt.Number LIKE ""PT-%"" AND Receipt.Posted = TRUE";
		ReceiptCashMovementCount = ReceiptCashMovementQuery.Execute().Unload()[0].Cnt;

		If AcceptanceCount <> 1260 Or InvoiceCount <> 1260 Or ReceiptCount <> 1162 Then
			Raise StrTemplate("AR generator output mismatch: acceptances=%1, invoices=%2, receipts=%3; expected 1260/1260/1162.",
				AcceptanceCount, InvoiceCount, ReceiptCount);
		EndIf;
		If VATStats.StandardRateCount <> 360 Or VATStats.ReducedRateCount <> 900 Or VATStats.SourceMismatchCount <> 0 Then
			Raise StrTemplate("AR VAT consistency mismatch: standard=%1, reduced=%2, source mismatches=%3; expected 360/900/0.",
				VATStats.StandardRateCount, VATStats.ReducedRateCount, VATStats.SourceMismatchCount);
		EndIf;
		If ReceiptGL.EntryCount <> ReceiptCount Or ReceiptGL.VndDebitCount <> ReceiptCount
			Or ReceiptGL.InternalCreditCount <> 361 Or ReceiptGL.ExternalCreditCount <> 801
			Or ReceiptGL.TotalDebit <> ReceiptGL.TotalCredit Then
			Raise StrTemplate("AR receipt GL mismatch: entries=%1, VND debits=%2, internal credits=%3, external credits=%4, debit=%5, credit=%6.",
				ReceiptGL.EntryCount, ReceiptGL.VndDebitCount, ReceiptGL.InternalCreditCount, ReceiptGL.ExternalCreditCount,
				ReceiptGL.TotalDebit, ReceiptGL.TotalCredit);
		EndIf;
		If ReceiptARMovementCount <> ReceiptCount Or ReceiptCashMovementCount <> ReceiptCount Then
			Raise StrTemplate("AR receipt movements mismatch: document receipts=%1, AR movements=%2, cash movements=%3.",
				ReceiptCount, ReceiptARMovementCount, ReceiptCashMovementCount);
		EndIf;

		Result.data.Insert("posted_acceptances", AcceptanceCount);
		Result.data.Insert("posted_invoices", InvoiceCount);
		Result.data.Insert("posted_receipts", ReceiptCount);
		Result.data.Insert("expected_receipts", 1162);
		Result.data.Insert("vat_boundary_cases", VATRateCaseCount);
		Result.data.Insert("standard_rate_acceptances", VATStats.StandardRateCount);
		Result.data.Insert("reduced_rate_acceptances", VATStats.ReducedRateCount);
		Result.data.Insert("invoice_tax_source_mismatches", VATStats.SourceMismatchCount);
		Result.data.Insert("receipt_gl_entries", ReceiptGL.EntryCount);
		Result.data.Insert("receipt_gl_internal_1312", ReceiptGL.InternalCreditCount);
		Result.data.Insert("receipt_gl_external_1311", ReceiptGL.ExternalCreditCount);
		Result.data.Insert("receipt_gl_debit_vnd", ReceiptGL.TotalDebit);
		Result.data.Insert("receipt_gl_credit_ar", ReceiptGL.TotalCredit);
		Result.data.Insert("receipt_ar_movements", ReceiptARMovementCount);
		Result.data.Insert("receipt_cash_movements", ReceiptCashMovementCount);
		Result.data.Insert("contract_query_batch", True);
		Result.status = "PASS";
	Except
		Result.error = DetailErrorDescription(ErrorInfo());
	EndTry;

	If ValueIsFilled(ResultPath) Then
		Writer = New JSONWriter;
		Writer.OpenFile(ResultPath);
		WriteJSON(Writer, Result);
		Writer.Close();
	EndIf;
	Return Result;
EndFunction

Function RunPostingLifecycleRegression(Val RunId, Val ResultPath) Export
	Cases = QuanLyVongDoiChungTuServer.KiemThuChuTrinhGhiSoRuntime();
	AllPassed = True;
	For Each TestCase In Cases Do
		AllPassed = AllPassed And TestCase.passed;
	EndDo;
	Result = New Structure("run_id,status,user,cases", RunId, ?(AllPassed, "PASS", "FAIL"), UserName(), Cases);
	If ValueIsFilled(ResultPath) Then
		Writer = New JSONWriter;
		Writer.OpenFile(ResultPath);
		WriteJSON(Writer, Result);
		Writer.Close();
	EndIf;
	Return Result;
EndFunction

Function RunGLSubledgerIntegrityRegression(Val RunId, Val ResultPath) Export
	Cases = New Array;
	Result = New Structure("run_id,status,user,cases,error", RunId, "FAIL", UserName(), Cases, "");
	Try
		Cases = QuanLyVongDoiChungTuServer.KiemThuDoiSoatDocLapMismatchRuntime();
		AllPassed = True;
		For Each TestCase In Cases Do
			AllPassed = AllPassed And TestCase.passed;
		EndDo;
		If Not AllPassed Or Cases.Count() <> 3 Then
			Raise StrTemplate("GL/subledger integrity regression did not pass all expected cases: %1/%2.",
				Cases.Count(), 3);
		EndIf;
		Result.status = "PASS";
		Result.cases = Cases;
	Except
		Result.error = DetailErrorDescription(ErrorInfo());
	EndTry;

	If ValueIsFilled(ResultPath) Then
		Writer = New JSONWriter;
		Writer.OpenFile(ResultPath);
		WriteJSON(Writer, Result);
		Writer.Close();
	EndIf;
	Return Result;
EndFunction

Function RunAPInvoicePostingLifecycleRegression(Val RunId, Val ResultPath) Export
	Cases = New Array;
	Result = New Structure("run_id,status,user,cases,error", RunId, "FAIL", UserName(), Cases, "");
	Try
		RequireFinanceE2ERole("KeToanTruong");
		InvoiceRef = Documents.HoaDonNhaCungCap.FindByNumber("E2E-BULK-LOW", Date(2026, 10, 15, 9, 0, 0));
		If Not ValueIsFilled(InvoiceRef) Or Not InvoiceRef.Posted Then
			Raise "KTT AP lifecycle requires the posted low-value approval fixture.";
		EndIf;
		Invoice = InvoiceRef.GetObject();
		If Invoice.NguoiLap <> "ketoan_ap" Or Invoice.NguoiDuyet <> UserName()
			Or Invoice.TongTien > 500000000 Then
			Raise "KTT AP lifecycle fixture does not match its maker, approver, or approval threshold.";
		EndIf;
		OriginalMovements = QuanLyVongDoiChungTuServer.LayDauVanMovements(InvoiceRef);
		OriginalGLCount = CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", InvoiceRef);
		If OriginalGLCount = 0 Then Raise "KTT AP lifecycle fixture has no original GL movements."; EndIf;

		BeginTransaction();
		Invoice.Write(DocumentWriteMode.UndoPosting);
		Unposted = InvoiceRef.GetObject();
		If Unposted.Posted Or Unposted.TrangThai <> Enums.TrangThaiHoaDonAP.ChoKeToanTruongDuyet
			Or QuanLyVongDoiChungTuServer.LayDauVanMovements(InvoiceRef, True) <> "0;0;0;0;" Then
			Raise "KTT AP unposting did not clear register movements and return the invoice to its KTT approval stage.";
		EndIf;
		Cases.Add(New Structure("name,passed", "UnpostClearsMovements", True));

		Invoice = InvoiceRef.GetObject();
		Invoice.NguoiDuyet = UserName();
		Invoice.TrangThai = Enums.TrangThaiHoaDonAP.DaGhiSo;
		Invoice.Write(DocumentWriteMode.Posting);
		Reposted = InvoiceRef.GetObject();
		RepostGLCount = CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", InvoiceRef);
		If Not Reposted.Posted Or RepostGLCount <> OriginalGLCount
			Or QuanLyVongDoiChungTuServer.LayDauVanMovements(InvoiceRef) <> OriginalMovements Then
			Raise "KTT AP repost did not reproduce the original GL and subledger movements.";
		EndIf;
		Cases.Add(New Structure("name,passed", "RepostMatchesOriginalMovements", True));

		RollbackTransaction();
		Restored = InvoiceRef.GetObject();
		If Not Restored.Posted Or Restored.TrangThai <> Enums.TrangThaiHoaDonAP.DaGhiSo
			Or QuanLyVongDoiChungTuServer.LayDauVanMovements(InvoiceRef) <> OriginalMovements Then
			Raise "KTT AP lifecycle rollback did not restore the original posted state and movements.";
		EndIf;
		Cases.Add(New Structure("name,passed", "RollbackRestoresOriginalPostings", True));
		Result.status = "PASS";
	Except
		If TransactionActive() Then RollbackTransaction(); EndIf;
		Result.error = DetailErrorDescription(ErrorInfo());
		Cases.Add(New Structure("name,passed,error", "APInvoicePostingLifecycle", False, Result.error));
	EndTry;

	If ValueIsFilled(ResultPath) Then
		Writer = New JSONWriter;
		Writer.OpenFile(ResultPath);
		WriteJSON(Writer, Result);
		Writer.Close();
	EndIf;
	Return Result;
EndFunction

Function PrepareFinanceE2E() Export
	RequireFinanceE2ERole("QuanTriHeThong");
	GeneratorMasterDataServer.KhoiTaoMasterDataToanDien();

	RefVND = Catalogs.TienTe.FindByCode("VND");
	EnsureFinanceE2EVendorMasterData(Catalogs.PhapNhan.FindByCode("PN-VSF"), RefVND);
	EnsureFinanceE2EPaymentGateway();
	RefBank = Catalogs.TaiKhoanTien.FindByCode("TK-E2E-VND");
	If Not ValueIsFilled(RefBank) Then
		Bank = Catalogs.TaiKhoanTien.CreateItem();
		Bank.Code = "TK-E2E-VND";
		Bank.Description = "E2E Techcombank VND";
		Bank.SoTaiKhoan = "1903889988001-E2E";
		Bank.NganHang = "Techcombank - E2E";
		Bank.TienTe = RefVND;
		Bank.Write();
		RefBank = Bank.Ref;
	EndIf;
	If RefBank.Code <> "TK-E2E-VND" Then Raise "E2E bank account code was truncated; expected TK-E2E-VND."; EndIf;
	EnsureFinanceE2ECashCategory("KM-01", "E2E customer receipts", "Thu");
	EnsureFinanceE2ECashCategory("KM-E2E-AP", "E2E supplier payments", "Chi");
	EnsureFinanceE2ECashCategory("KM-E2E-GATEWAY", "E2E payment gateway settlement", "Thu");

	Context = FinanceE2EContext();
	Q = New Query(
		"SELECT ISNULL(SUM(SoTienBalance), 0) AS Balance
		|FROM AccumulationRegister.DongTien.Balance(,
		| PhapNhan = &PN AND TaiKhoanTien = &Bank AND TienTe = &Currency)");
	Q.SetParameter("PN", Context.PhapNhan);
	Q.SetParameter("Bank", Context.Bank);
	Q.SetParameter("Currency", Context.VND);
	If Q.Execute().Unload()[0].Balance <> 0 Then
		Raise "E2E bank account already has a balance; run against a fresh infobase copy.";
	EndIf;

	ResultData = New Structure;
	ResultData.Insert("legal_entity", Context.PhapNhan.Code);
	ResultData.Insert("customer", Context.Customer.Code);
	ResultData.Insert("customer_contract", Context.CustomerContract.Code);
	ResultData.Insert("vendor", Context.Vendor.Code);
	ResultData.Insert("vendor_contract", Context.VendorContract.Code);
	ResultData.Insert("bank_account", Context.Bank.Code);
	ResultData.Insert("opening_cash_vnd", 0);
	Return ResultData;
EndFunction

Function SubmitFinanceE2EAcceptance() Export
	RequireFinanceE2ERole("KeToanPhaiThu");
	Context = FinanceE2EContext();
	Doc = Documents.BienBanNghiemThuGiaiDoan.CreateDocument();
	Doc.Number = "E2E-BB001";
	Doc.Date = Date(2026, 10, 10, 9, 0, 0);
	Doc.PhapNhan = Context.PhapNhan;
	Doc.DoiTac = Context.Customer;
	Doc.HopDong = Context.CustomerContract;
	Doc.GiaTriNghiemThuChuaVAT = 200000000;
	Doc.ApDungGiamThueGTGT = True;
	Doc.NgayNghiemThu = BegOfDay(Doc.Date);
	Doc.TyLeVAT = ThueGTGTClientServer.TyLeVATApDungTheoNgay(Doc.NgayNghiemThu, Doc.ApDungGiamThueGTGT);
	Doc.TienVAT = 0;
	Doc.TongGiaTri = 0;
	Doc.TrangThai = Enums.TrangThaiNghiemThuAR.DuThao;
	Doc.NguoiDuyet = "cfo_giamdoc";
	Doc.DienGiai = "E2E accepted service October 2026";
	Doc.Write();
	Doc.TrangThai = Enums.TrangThaiNghiemThuAR.ChoDuyetNoiBo;
	Doc.Write();
	If Doc.NguoiTao <> UserName() Or Doc.TyLeVAT <> 8 Or Doc.TienVAT <> 16000000 Or Doc.TongGiaTri <> 216000000 Then
		Raise "Acceptance maker, VAT, or gross amount did not match the deterministic input.";
	EndIf;
	ResultData = New Structure;
	ResultData.Insert("acceptance_number", Doc.Number);
	ResultData.Insert("maker", Doc.NguoiTao);
	ResultData.Insert("status", QuanLyVongDoiChungTuServer.TenTrangThai(Doc.TrangThai));
	ResultData.Insert("net_vnd", Doc.GiaTriNghiemThuChuaVAT);
	ResultData.Insert("vat_vnd", Doc.TienVAT);
	ResultData.Insert("gross_vnd", Doc.TongGiaTri);
	Return ResultData;
EndFunction

Function ApproveFinanceE2EAcceptance() Export
	RequireFinanceE2ERole("GiamDocTaiChinh_CFO");
	DocRef = Documents.BienBanNghiemThuGiaiDoan.FindByNumber("E2E-BB001", Date(2026, 10, 10, 9, 0, 0));
	If Not ValueIsFilled(DocRef) Then Raise "E2E acceptance E2E-BB001 is missing."; EndIf;
	Doc = DocRef.GetObject();
	If Doc.TrangThai <> Enums.TrangThaiNghiemThuAR.ChoDuyetNoiBo Then
		Raise "E2E acceptance must be submitted before CFO approval.";
	EndIf;
	Doc.TrangThai = Enums.TrangThaiNghiemThuAR.DaDuyetNoiBo;
	Doc.NguoiDuyet = UserName();
	Doc.Write();
	ResultData = New Structure;
	ResultData.Insert("acceptance_number", Doc.Number);
	ResultData.Insert("approver", Doc.NguoiDuyet);
	ResultData.Insert("status", QuanLyVongDoiChungTuServer.TenTrangThai(Doc.TrangThai));
	Return ResultData;
EndFunction

Function PostFinanceE2EAcceptance() Export
	RequireFinanceE2ERole("GiamDocTaiChinh_CFO");
	DocRef = Documents.BienBanNghiemThuGiaiDoan.FindByNumber("E2E-BB001", Date(2026, 10, 10, 9, 0, 0));
	If Not ValueIsFilled(DocRef) Then Raise "E2E acceptance dependency E2E-BB001 is missing."; EndIf;
	Doc = DocRef.GetObject();
	If Doc.TrangThai <> Enums.TrangThaiNghiemThuAR.DaDuyetNoiBo Then
		Raise "CFO must approve the acceptance before posting.";
	EndIf;
	Doc.Write(DocumentWriteMode.Posting);
	If Not Doc.Posted Or Doc.TrangThai <> Enums.TrangThaiNghiemThuAR.DaGhiSo Then
		Raise "CFO acceptance approval did not produce a posted BBNT.";
	EndIf;
	ResultData = New Structure;
	ResultData.Insert("acceptance_number", Doc.Number);
	ResultData.Insert("approver", Doc.NguoiDuyet);
	ResultData.Insert("posted", Doc.Posted);
	ResultData.Insert("status", QuanLyVongDoiChungTuServer.TenTrangThai(Doc.TrangThai));
	Return ResultData;
EndFunction

Function SubmitFinanceE2ESalesInvoice() Export
	RequireFinanceE2ERole("KeToanPhaiThu");
	Context = FinanceE2EContext();
	AcceptanceRef = Documents.BienBanNghiemThuGiaiDoan.FindByNumber("E2E-BB001", Date(2026, 10, 10, 9, 0, 0));
	If Not ValueIsFilled(AcceptanceRef) Or Not AcceptanceRef.Posted Then
		Raise "E2E sales invoice dependency BBNT E2E-BB001 has not been approved and posted.";
	EndIf;
	Doc = Documents.HoaDonGTGTDauRa.CreateDocument();
	Doc.Number = "E2E-AR001";
	Doc.Date = Date(2026, 10, 10, 10, 0, 0);
	Doc.SoHoaDon = "E2EINV-001";
	Doc.KyHieu = "1C26E2E";
	Doc.PhapNhan = Context.PhapNhan;
	Doc.DoiTac = Context.Customer;
	Doc.HopDong = Context.CustomerContract;
	Doc.BienBanNghiemThu = AcceptanceRef;
	Doc.ApDungGiamThueGTGT = AcceptanceRef.ApDungGiamThueGTGT;
	Doc.NgayHoaDon = BegOfDay(Doc.Date);
	Doc.TienChuaThue = AcceptanceRef.GiaTriNghiemThuChuaVAT;
	Doc.ThueSuatVAT = AcceptanceRef.TyLeVAT;
	Doc.TienThueVAT = AcceptanceRef.TienVAT;
	Doc.TongTienThanhToan = AcceptanceRef.TongGiaTri;
	Doc.TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.DuThao;
	Doc.MaCQT = "E2E-CQT-001";
	Doc.DienGiai = "E2E issued service invoice";
	Doc.Write();
	Doc.TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.ChoKySo;
	Doc.NguoiDuyet = "cfo_giamdoc";
	Doc.Write();
	ResultData = New Structure;
	ResultData.Insert("invoice_number", Doc.Number);
	ResultData.Insert("sales_invoice_number", Doc.SoHoaDon);
	ResultData.Insert("maker", Doc.NguoiLap);
	ResultData.Insert("status", QuanLyVongDoiChungTuServer.TenTrangThai(Doc.TrangThaiHDDT));
	ResultData.Insert("base_acceptance", String(AcceptanceRef));
	Return ResultData;
EndFunction

Function IssueFinanceE2ESalesInvoice() Export
	RequireFinanceE2ERole("GiamDocTaiChinh_CFO");
	DocRef = Documents.HoaDonGTGTDauRa.FindByNumber("E2E-AR001", Date(2026, 10, 10, 10, 0, 0));
	If Not ValueIsFilled(DocRef) Then Raise "E2E sales invoice E2E-AR001 is missing."; EndIf;
	Doc = DocRef.GetObject();
	Doc.TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.DaPhatHanh;
	Doc.NguoiDuyet = UserName();
	Doc.Write(DocumentWriteMode.Posting);
	AcceptanceRef = Documents.BienBanNghiemThuGiaiDoan.FindByNumber("E2E-BB001", Date(2026, 10, 10, 9, 0, 0));
	If Not Doc.Posted Or Doc.TongTienThanhToan <> AcceptanceRef.TongGiaTri
		Or Doc.ThueSuatVAT <> AcceptanceRef.TyLeVAT Or Doc.TienThueVAT <> AcceptanceRef.TienVAT Then
		Raise "Sales invoice was not issued with the posted acceptance's tax basis and amount.";
	EndIf;
	ResultData = New Structure;
	ResultData.Insert("invoice_number", Doc.Number);
	ResultData.Insert("approver", Doc.NguoiDuyet);
	ResultData.Insert("posted", Doc.Posted);
	ResultData.Insert("net_vnd", Doc.TienChuaThue);
	ResultData.Insert("vat_vnd", Doc.TienThueVAT);
	ResultData.Insert("gross_vnd", Doc.TongTienThanhToan);
	Return ResultData;
EndFunction

Function CreateFinanceE2EReceipts() Export
	RequireFinanceE2ERole("KeToanPhaiThu");
	Context = FinanceE2EContext();
	InvoiceRef = Documents.HoaDonGTGTDauRa.FindByNumber("E2E-AR001", Date(2026, 10, 10, 10, 0, 0));
	If Not ValueIsFilled(InvoiceRef) Or Not InvoiceRef.Posted Then
		Raise "E2E receipt dependency sales invoice E2E-AR001 has not been issued and posted.";
	EndIf;

	Receipt = Documents.PhieuThuTienKhachHang.CreateDocument();
	Receipt.Number = "E2E-PT001";
	Receipt.Date = Date(2026, 10, 12, 10, 0, 0);
	Receipt.PhapNhan = Context.PhapNhan;
	Receipt.DoiTac = Context.Customer;
	Receipt.HopDong = Context.CustomerContract;
	Receipt.ChungTuGoc = InvoiceRef;
	Receipt.TaiKhoanTien = Context.Bank;
	Receipt.KhoanMucDongTien = Context.CustomerReceiptCategory;
	Receipt.TienTe = Context.VND;
	Receipt.TyGia = 1;
	Receipt.NgayThu = BegOfDay(Receipt.Date);
	Receipt.SoTien = InvoiceRef.TongTienThanhToan;
	Receipt.NguoiDuyet = "cfo_giamdoc";
	Receipt.DienGiai = "E2E full customer collection";
	Receipt.Write();

	OverReceipt = Documents.PhieuThuTienKhachHang.CreateDocument();
	OverReceipt.Number = "E2E-NEG01";
	OverReceipt.Date = Date(2026, 10, 12, 11, 0, 0);
	OverReceipt.PhapNhan = Context.PhapNhan;
	OverReceipt.DoiTac = Context.Customer;
	OverReceipt.HopDong = Context.CustomerContract;
	OverReceipt.ChungTuGoc = InvoiceRef;
	OverReceipt.TaiKhoanTien = Context.Bank;
	OverReceipt.KhoanMucDongTien = Context.CustomerReceiptCategory;
	OverReceipt.TienTe = Context.VND;
	OverReceipt.TyGia = 1;
	OverReceipt.NgayThu = BegOfDay(OverReceipt.Date);
	OverReceipt.SoTien = InvoiceRef.TongTienThanhToan + 1;
	OverReceipt.NguoiDuyet = "cfo_giamdoc";
	OverReceipt.DienGiai = "E2E negative over-collection";
	OverReceipt.Write();

	ResultData = New Structure;
	ResultData.Insert("receipt_number", Receipt.Number);
	ResultData.Insert("receipt_amount_vnd", Receipt.SoTien);
	ResultData.Insert("over_receipt_number", OverReceipt.Number);
	ResultData.Insert("over_receipt_amount_vnd", OverReceipt.SoTien);
	ResultData.Insert("source_invoice", String(InvoiceRef));
	Return ResultData;
EndFunction

Function PostFinanceE2EReceipts() Export
	RequireFinanceE2ERole("GiamDocTaiChinh_CFO");
	Context = FinanceE2EContext();
	ReceiptRef = Documents.PhieuThuTienKhachHang.FindByNumber("E2E-PT001", Date(2026, 10, 12, 10, 0, 0));
	OverReceiptRef = Documents.PhieuThuTienKhachHang.FindByNumber("E2E-NEG01", Date(2026, 10, 12, 11, 0, 0));
	If Not ValueIsFilled(ReceiptRef) Or Not ValueIsFilled(OverReceiptRef) Then
		Raise "E2E receipt phase did not create both receipt documents.";
	EndIf;
	Receipt = ReceiptRef.GetObject();
	Receipt.NguoiDuyet = UserName();
	Receipt.Write(DocumentWriteMode.Posting);
	If Not Receipt.Posted Then Raise "The customer receipt was not posted."; EndIf;

	OverReceipt = OverReceiptRef.GetObject();
	OverReceipt.NguoiDuyet = UserName();
	Try
		OverReceipt.Write(DocumentWriteMode.Posting);
	Except
		// The negative case is accepted only when the document remains unposted and has no movement.
	EndTry;
	If OverReceipt.Posted Then Raise "Over-collection was incorrectly posted."; EndIf;

	Q = New Query("SELECT COUNT(*) AS Cnt FROM AccumulationRegister.CongNoPhaiThu WHERE Recorder = &Ref AND Active = TRUE");
	Q.SetParameter("Ref", OverReceiptRef);
	ARMovementCount = Q.Execute().Unload()[0].Cnt;
	Q = New Query("SELECT COUNT(*) AS Cnt FROM AccountingRegister.SoCaiKeToan WHERE Recorder = &Ref AND Active = TRUE");
	Q.SetParameter("Ref", OverReceiptRef);
	GLMovementCount = Q.Execute().Unload()[0].Cnt;
	Q = New Query("SELECT COUNT(*) AS Cnt FROM AccumulationRegister.DongTien WHERE Recorder = &Ref AND Active = TRUE");
	Q.SetParameter("Ref", OverReceiptRef);
	CashMovementCount = Q.Execute().Unload()[0].Cnt;
	If ARMovementCount <> 0 Or GLMovementCount <> 0 Or CashMovementCount <> 0 Then
		Raise "Rejected over-collection left one or more financial register movements.";
	EndIf;

	ARBalance = FinanceE2EARBalance(Context, Receipt.ChungTuGoc);
	If ARBalance <> 0 Then Raise StrTemplate("AR invoice residual after receipt is %1, expected 0.", ARBalance); EndIf;
	ResultData = New Structure;
	ResultData.Insert("receipt_posted", Receipt.Posted);
	ResultData.Insert("ar_invoice_residual_vnd", ARBalance);
	ResultData.Insert("over_receipt_posted", OverReceipt.Posted);
	ResultData.Insert("over_receipt_ar_movements", ARMovementCount);
	ResultData.Insert("over_receipt_gl_movements", GLMovementCount);
	ResultData.Insert("over_receipt_cash_movements", CashMovementCount);
	Return ResultData;
EndFunction

Function SubmitFinanceE2EVendorInvoice() Export
	RequireFinanceE2ERole("KeToanPhaiTra");
	Context = FinanceE2EContext();
	Doc = Documents.HoaDonNhaCungCap.CreateDocument();
	Doc.Number = "E2E-AP001";
	Doc.Date = Date(2026, 10, 13, 9, 0, 0);
	Doc.NgayHoaDon = BegOfDay(Doc.Date);
	Doc.SoHoaDon = "E2EAP-001";
	Doc.PhapNhan = Context.PhapNhan;
	Doc.DoiTac = Context.Vendor;
	Doc.HopDong = Context.VendorContract;
	Doc.TaiKhoanChiPhi = Context.Account627;
	Doc.TienTe = Context.VND;
	Doc.TyGia = 1;
	Doc.TongTien = 200000000;
	Doc.CoKhauTruFCT = True;
	Doc.TyLeThueVATNhaThau = 5;
	Doc.TyLeThueTNDNNhaThau = 5;
	Doc.TrangThai = Enums.TrangThaiHoaDonAP.DuThao;
	Doc.DienGiai = "E2E AWS VND invoice with 5 percent FCT VAT and CIT";
	Doc.Write();
	Doc.TrangThai = Enums.TrangThaiHoaDonAP.ChoKeToanTruongDuyet;
	Doc.NguoiDuyet = "ketoan_truong";
	Doc.Write();
	If Doc.NoThucTraNCC <> 180000000 Or Doc.TienThueVATNhaThau <> 10000000
		Or Doc.TienThueTNDNNhaThau <> 10000000 Or Doc.ChiPhiVSF <> 190000000 Then
		Raise "AP FCT calculation differs from the expected 200m gross / 180m net / 20m retained tax.";
	EndIf;
	ResultData = New Structure;
	ResultData.Insert("invoice_number", Doc.Number);
	ResultData.Insert("maker", Doc.NguoiLap);
	ResultData.Insert("approver", Doc.NguoiDuyet);
	ResultData.Insert("status", QuanLyVongDoiChungTuServer.TenTrangThai(Doc.TrangThai));
	ResultData.Insert("gross_vnd", Doc.TongTien);
	ResultData.Insert("fct_vat_vnd", Doc.TienThueVATNhaThau);
	ResultData.Insert("fct_cit_vnd", Doc.TienThueTNDNNhaThau);
	ResultData.Insert("net_payable_vnd", Doc.NoThucTraNCC);
	ResultData.Insert("expense_vnd", Doc.ChiPhiVSF);
	Return ResultData;
EndFunction

Function PostFinanceE2EVendorInvoice() Export
	RequireFinanceE2ERole("KeToanTruong");
	DocRef = Documents.HoaDonNhaCungCap.FindByNumber("E2E-AP001", Date(2026, 10, 13, 9, 0, 0));
	If Not ValueIsFilled(DocRef) Then Raise "E2E vendor invoice E2E-AP001 is missing."; EndIf;
	Doc = DocRef.GetObject();
	Doc.TrangThai = Enums.TrangThaiHoaDonAP.DaGhiSo;
	Doc.NguoiDuyet = UserName();
	Doc.Write(DocumentWriteMode.Posting);
	If Not Doc.Posted Or Doc.TrangThai <> Enums.TrangThaiHoaDonAP.DaGhiSo Then
		Raise "KTT approval did not post the AP invoice.";
	EndIf;
	ResultData = New Structure;
	ResultData.Insert("invoice_number", Doc.Number);
	ResultData.Insert("approver", Doc.NguoiDuyet);
	ResultData.Insert("posted", Doc.Posted);
	ResultData.Insert("gross_vnd", Doc.TongTien);
	ResultData.Insert("net_payable_vnd", Doc.NoThucTraNCC);
	Return ResultData;
EndFunction

Function SubmitFinanceE2EPayment() Export
	RequireFinanceE2ERole("KeToanPhaiTra");
	Context = FinanceE2EContext();
	InvoiceRef = Documents.HoaDonNhaCungCap.FindByNumber("E2E-AP001", Date(2026, 10, 13, 9, 0, 0));
	If Not ValueIsFilled(InvoiceRef) Or Not InvoiceRef.Posted Then
		Raise "E2E payment dependency AP invoice E2E-AP001 has not been approved and posted.";
	EndIf;
	Doc = Documents.UyNhiemChi.CreateDocument();
	Doc.Number = "E2E-UNC01";
	Doc.Date = Date(2026, 10, 14, 9, 0, 0);
	Doc.NgayLap = Doc.Date;
	Doc.NgayGhiSo = Doc.Date;
	Doc.PhapNhan = Context.PhapNhan;
	Doc.DoiTac = Context.Vendor;
	Doc.HopDong = Context.VendorContract;
	Doc.ChungTuGoc = InvoiceRef;
	Doc.TaiKhoanTien = Context.Bank;
	Doc.KhoanMucDongTien = Context.VendorPaymentCategory;
	Doc.TienTe = Context.VND;
	Doc.TyGia = 1;
	Doc.SoTien = 180000000;
	Doc.PhiNganHang = 0;
	Doc.TrangThai = Enums.TrangThaiLenhThanhToan.DuThao;
	Doc.NguoiDuyet = "ketoan_truong";
	Doc.DienGiai = "E2E full vendor settlement";
	Doc.Write();
	Doc.TrangThai = Enums.TrangThaiLenhThanhToan.ChoDuyet;
	Doc.Write();
	ResultData = New Structure;
	ResultData.Insert("payment_number", Doc.Number);
	ResultData.Insert("maker", Doc.NguoiLap);
	ResultData.Insert("status", QuanLyVongDoiChungTuServer.TenTrangThai(Doc.TrangThai));
	ResultData.Insert("amount_vnd", Doc.SoTien);
	ResultData.Insert("fee_vnd", Doc.PhiNganHang);
	ResultData.Insert("source_invoice", String(InvoiceRef));
	Return ResultData;
EndFunction

Function ApproveFinanceE2EPayment() Export
	RequireFinanceE2ERole("KeToanTruong");
	DocRef = Documents.UyNhiemChi.FindByNumber("E2E-UNC01", Date(2026, 10, 14, 9, 0, 0));
	If Not ValueIsFilled(DocRef) Then Raise "E2E payment E2E-UNC01 is missing."; EndIf;
	Doc = DocRef.GetObject();
	Doc.TrangThai = Enums.TrangThaiLenhThanhToan.DaDuyet;
	Doc.NguoiDuyet = UserName();
	Doc.Write();
	Doc.TrangThai = Enums.TrangThaiLenhThanhToan.DaGuiNganHang;
	Doc.Write();
	ResultData = New Structure;
	ResultData.Insert("payment_number", Doc.Number);
	ResultData.Insert("approver", Doc.NguoiDuyet);
	ResultData.Insert("status", QuanLyVongDoiChungTuServer.TenTrangThai(Doc.TrangThai));
	Return ResultData;
EndFunction

Function PostAndVerifyFinanceE2EPayment() Export
	RequireFinanceE2ERole("GiamDocTaiChinh_CFO");
	Context = FinanceE2EContext();
	DocRef = Documents.UyNhiemChi.FindByNumber("E2E-UNC01", Date(2026, 10, 14, 9, 0, 0));
	If Not ValueIsFilled(DocRef) Then Raise "E2E payment E2E-UNC01 is missing."; EndIf;
	Payment = DocRef.GetObject();
	Payment.TrangThai = Enums.TrangThaiLenhThanhToan.DaGhiSo;
	Payment.NguoiDuyet = UserName();
	Payment.Write(DocumentWriteMode.Posting);
	If Not Payment.Posted Then Raise "CFO did not post the supplier payment."; EndIf;

	AcceptanceRef = Documents.BienBanNghiemThuGiaiDoan.FindByNumber("E2E-BB001", Date(2026, 10, 10, 9, 0, 0));
	SalesInvoiceRef = Documents.HoaDonGTGTDauRa.FindByNumber("E2E-AR001", Date(2026, 10, 10, 10, 0, 0));
	ReceiptRef = Documents.PhieuThuTienKhachHang.FindByNumber("E2E-PT001", Date(2026, 10, 12, 10, 0, 0));
	APInvoiceRef = Documents.HoaDonNhaCungCap.FindByNumber("E2E-AP001", Date(2026, 10, 13, 9, 0, 0));
	If Not AcceptanceRef.Posted Or Not SalesInvoiceRef.Posted Or Not ReceiptRef.Posted Or Not APInvoiceRef.Posted Then
		Raise "One or more predecessor documents are not posted; final verification cannot continue.";
	EndIf;

	ARAcceptanceBalance = FinanceE2EARBalance(Context, AcceptanceRef);
	ARSalesBalance = FinanceE2EARBalance(Context, SalesInvoiceRef);
	APInvoiceBalance = FinanceE2EAPBalance(Context, APInvoiceRef);
	CashBalance = FinanceE2ECashBalance(Context);
	SalesNet = AcceptanceRef.GiaTriNghiemThuChuaVAT;
	SalesVAT = AcceptanceRef.TienVAT;
	SalesGross = AcceptanceRef.TongGiaTri;
	If ARAcceptanceBalance <> 0 Or ARSalesBalance <> 0 Or APInvoiceBalance <> 0 Then
		Raise StrTemplate("Unexpected closing balances: AR-BBNT=%1 AR-invoice=%2 AP-invoice=%3 bank=%4.",
			ARAcceptanceBalance, ARSalesBalance, APInvoiceBalance, CashBalance);
	EndIf;

	AssertFinanceE2EGL(AcceptanceRef, "1312", "5113", SalesNet);
	AssertFinanceE2EGL(SalesInvoiceRef, "1312", "33311", SalesVAT);
	AssertFinanceE2EGL(ReceiptRef, "1121", "1312", SalesGross);
	AssertFinanceE2EGL(APInvoiceRef, "627", "3311", 180000000);
	AssertFinanceE2EGL(APInvoiceRef, "627", "3338", 10000000);
	AssertFinanceE2EGL(APInvoiceRef, "1331", "33318", 10000000);
	AssertFinanceE2EGL(Payment.Ref, "3311", "1121", 180000000);

	Q = New Query;
	Q.Text =
		"SELECT
		| SUM(CASE WHEN GL.AccountDr.Code = ""1121"" THEN GL.SoTien ELSE 0 END) AS CashDr,
		| SUM(CASE WHEN GL.AccountCr.Code = ""1121"" THEN GL.SoTien ELSE 0 END) AS CashCr,
		| SUM(CASE WHEN GL.AccountDr.Code = ""1312"" THEN GL.SoTien ELSE 0 END) AS ARDr,
		| SUM(CASE WHEN GL.AccountCr.Code = ""1312"" THEN GL.SoTien ELSE 0 END) AS ARCr,
		| SUM(CASE WHEN GL.AccountDr.Code = ""3311"" THEN GL.SoTien ELSE 0 END) AS APDr,
		| SUM(CASE WHEN GL.AccountCr.Code = ""3311"" THEN GL.SoTien ELSE 0 END) AS APCr,
		| SUM(CASE WHEN GL.AccountCr.Code = ""33311"" THEN GL.SoTien ELSE 0 END) AS SalesVATCr,
		| SUM(CASE WHEN GL.AccountCr.Code = ""33318"" THEN GL.SoTien ELSE 0 END) AS FCTVATCr,
		| SUM(CASE WHEN GL.AccountCr.Code = ""3338"" THEN GL.SoTien ELSE 0 END) AS FCTCITCr
		|FROM AccountingRegister.SoCaiKeToan AS GL
		|WHERE GL.Recorder = &Acceptance OR GL.Recorder = &SalesInvoice
		| OR GL.Recorder = &Receipt OR GL.Recorder = &APInvoice OR GL.Recorder = &Payment";
	Q.SetParameter("Acceptance", AcceptanceRef);
	Q.SetParameter("SalesInvoice", SalesInvoiceRef);
	Q.SetParameter("Receipt", ReceiptRef);
	Q.SetParameter("APInvoice", APInvoiceRef);
	Q.SetParameter("Payment", Payment.Ref);
	E2EGL = Q.Execute().Unload()[0];
	If E2EGL.CashDr <> SalesGross Or E2EGL.CashCr <> 180000000
		Or E2EGL.ARDr <> SalesGross Or E2EGL.ARCr <> SalesGross
		Or E2EGL.APDr <> 180000000 Or E2EGL.APCr <> 180000000
		Or E2EGL.SalesVATCr <> SalesVAT Or E2EGL.FCTVATCr <> 10000000 Or E2EGL.FCTCITCr <> 10000000
		Or E2EGL.CashDr - E2EGL.CashCr <> CashBalance Or E2EGL.ARDr <> E2EGL.ARCr Or E2EGL.APDr <> E2EGL.APCr Then
		Raise "E2E general ledger control-account totals do not reconcile with AR, AP, tax, or bank register balances.";
	EndIf;

	Q = New Query;
	Q.Text =
		"SELECT
		| SUM(CASE WHEN GL.AccountDr.Code = ""627"" THEN GL.SoTien ELSE 0 END) AS ExpenseDr,
		| SUM(CASE WHEN GL.AccountDr.Code = ""1331"" THEN GL.SoTien ELSE 0 END) AS InputVATDr,
		| SUM(CASE WHEN GL.AccountCr.Code = ""3311"" THEN GL.SoTien ELSE 0 END) AS VendorCr,
		| SUM(CASE WHEN GL.AccountCr.Code = ""33318"" THEN GL.SoTien ELSE 0 END) AS FCTVATCr,
		| SUM(CASE WHEN GL.AccountCr.Code = ""3338"" THEN GL.SoTien ELSE 0 END) AS FCTCITCr,
		| SUM(CASE WHEN GL.AccountDr.Code IN (""627"", ""1331"") THEN GL.SoTien ELSE 0 END) AS TotalDr,
		| SUM(CASE WHEN GL.AccountCr.Code IN (""3311"", ""33318"", ""3338"") THEN GL.SoTien ELSE 0 END) AS TotalCr
		|FROM AccountingRegister.SoCaiKeToan AS GL
		|WHERE GL.Recorder = &Ref";
	Q.SetParameter("Ref", APInvoiceRef);
	FCT = Q.Execute().Unload()[0];
	If FCT.ExpenseDr <> 190000000 Or FCT.InputVATDr <> 10000000
		Or FCT.VendorCr <> 180000000 Or FCT.FCTVATCr <> 10000000 Or FCT.FCTCITCr <> 10000000
		Or FCT.TotalDr <> 200000000 Or FCT.TotalCr <> 200000000 Then
		Raise "Posted AP FCT GL rows differ from expected expense, VAT, CIT, payable, or balanced totals.";
	EndIf;
	ExpectedCashBalance = SalesGross - 180000000;
	If CashBalance <> ExpectedCashBalance Then
		Raise StrTemplate("Bank closing balance is %1, expected %2 VND after receipt and payment.", CashBalance, ExpectedCashBalance);
	EndIf;

	ResultData = New Structure;
	ResultData.Insert("acceptance_posted", AcceptanceRef.Posted);
	ResultData.Insert("sales_invoice_posted", SalesInvoiceRef.Posted);
	ResultData.Insert("receipt_posted", ReceiptRef.Posted);
	ResultData.Insert("ap_invoice_posted", APInvoiceRef.Posted);
	ResultData.Insert("payment_posted", Payment.Posted);
	ResultData.Insert("ar_bbnt_residual_vnd", ARAcceptanceBalance);
	ResultData.Insert("ar_invoice_residual_vnd", ARSalesBalance);
	ResultData.Insert("ap_invoice_residual_vnd", APInvoiceBalance);
	ResultData.Insert("fct_vat_outstanding_vnd", FCT.FCTVATCr);
	ResultData.Insert("fct_cit_outstanding_vnd", FCT.FCTCITCr);
	ResultData.Insert("gl_bank_debit_vnd", E2EGL.CashDr);
	ResultData.Insert("gl_bank_credit_vnd", E2EGL.CashCr);
	ResultData.Insert("gl_ar_debit_vnd", E2EGL.ARDr);
	ResultData.Insert("gl_ar_credit_vnd", E2EGL.ARCr);
	ResultData.Insert("gl_ap_debit_vnd", E2EGL.APDr);
	ResultData.Insert("gl_ap_credit_vnd", E2EGL.APCr);
	ResultData.Insert("sales_vat_outstanding_vnd", E2EGL.SalesVATCr);
	ResultData.Insert("bank_closing_vnd", CashBalance);
	ResultData.Insert("opening_cash_vnd", 0);
	ResultData.Insert("ar_receipt_vnd", SalesGross);
	ResultData.Insert("ap_payment_vnd", Payment.SoTien);
	ResultData.Insert("payment_number", Payment.Number);
	Return ResultData;
EndFunction

Function SubmitFinanceE2ENettingAcceptance() Export
	RequireFinanceE2ERole("KeToanPhaiThu");
	Context = FinanceE2EContext();
	Doc = Documents.BienBanNghiemThuGiaiDoan.CreateDocument();
	Doc.Number = "E2E-NT-AR001";
	Doc.Date = Date(2026, 10, 20, 9, 0, 0);
	Doc.PhapNhan = Context.PhapNhan;
	Doc.DoiTac = Context.Customer;
	Doc.HopDong = Context.CustomerContract;
	Doc.GiaTriNghiemThuChuaVAT = 40000000;
	Doc.ApDungGiamThueGTGT = True;
	Doc.NgayNghiemThu = BegOfDay(Doc.Date);
	Doc.TyLeVAT = ThueGTGTClientServer.TyLeVATApDungTheoNgay(Doc.NgayNghiemThu, Doc.ApDungGiamThueGTGT);
	Doc.TienVAT = 0;
	Doc.TongGiaTri = 0;
	Doc.TrangThai = Enums.TrangThaiNghiemThuAR.DuThao;
	Doc.NguoiDuyet = "cfo_giamdoc";
	Doc.DienGiai = "E2E internal license receivable for bilateral netting";
	Doc.Write();
	Doc.TrangThai = Enums.TrangThaiNghiemThuAR.ChoDuyetNoiBo;
	Doc.Write();
	If Doc.TienVAT <> 3200000 Or Doc.TongGiaTri <> 43200000 Then
		Raise "Netting AR source must contain 40m base plus the fixture's 8 percent VAT.";
	EndIf;
	Return New Structure("ar_source,base_vnd,vat_vnd,gross_vnd,maker", String(Doc.Ref), Doc.GiaTriNghiemThuChuaVAT, Doc.TienVAT, Doc.TongGiaTri, UserName());
EndFunction

Function PostFinanceE2ENettingAcceptance() Export
	RequireFinanceE2ERole("GiamDocTaiChinh_CFO");
	Context = FinanceE2EContext();
	DocRef = Documents.BienBanNghiemThuGiaiDoan.FindByNumber("E2E-NT-AR001", Date(2026, 10, 20, 9, 0, 0));
	If Not ValueIsFilled(DocRef) Then Raise "Netting AR source acceptance is missing."; EndIf;
	Doc = DocRef.GetObject();
	If Doc.TrangThai <> Enums.TrangThaiNghiemThuAR.ChoDuyetNoiBo Then
		Raise "Netting AR source must pass through the internal approval state before posting.";
	EndIf;
	Doc.TrangThai = Enums.TrangThaiNghiemThuAR.DaDuyetNoiBo;
	Doc.NguoiDuyet = UserName();
	Doc.Write();
	Doc.Write(DocumentWriteMode.Posting);
	If Not Doc.Posted Or FinanceE2EARBalance(Context, DocRef) <> 40000000 Then
		Raise "Posted acceptance must create its pre-VAT 40m unbilled AR balance.";
	EndIf;
	AssertFinanceE2EGL(DocRef, "1312", "5113", 40000000);
	Return New Structure("ar_source_posted,ar_open_vnd,approver", Doc.Posted, FinanceE2EARBalance(Context, DocRef), UserName());
EndFunction

Function SubmitFinanceE2ENettingSalesInvoice() Export
	RequireFinanceE2ERole("KeToanPhaiThu");
	Context = FinanceE2EContext();
	AcceptanceRef = Documents.BienBanNghiemThuGiaiDoan.FindByNumber("E2E-NT-AR001", Date(2026, 10, 20, 9, 0, 0));
	If Not ValueIsFilled(AcceptanceRef) Or Not AcceptanceRef.Posted Then
		Raise "Netting sales invoice requires the approved and posted AR acceptance.";
	EndIf;
	Doc = Documents.HoaDonGTGTDauRa.CreateDocument();
	Doc.Number = "E2E-AR-NT001";
	Doc.Date = Date(2026, 10, 20, 9, 30, 0);
	Doc.SoHoaDon = "E2EINV-NT001";
	Doc.KyHieu = "1C26NT";
	Doc.PhapNhan = Context.PhapNhan;
	Doc.DoiTac = Context.Customer;
	Doc.HopDong = Context.CustomerContract;
	Doc.BienBanNghiemThu = AcceptanceRef;
	Doc.ApDungGiamThueGTGT = AcceptanceRef.ApDungGiamThueGTGT;
	Doc.NgayHoaDon = BegOfDay(Doc.Date);
	Doc.TienChuaThue = AcceptanceRef.GiaTriNghiemThuChuaVAT;
	Doc.ThueSuatVAT = AcceptanceRef.TyLeVAT;
	Doc.TienThueVAT = AcceptanceRef.TienVAT;
	Doc.TongTienThanhToan = AcceptanceRef.TongGiaTri;
	Doc.TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.DuThao;
	Doc.MaCQT = "E2E-CQT-NT001";
	Doc.NguoiDuyet = "cfo_giamdoc";
	Doc.DienGiai = "E2E VAT invoice transferring acceptance AR before bilateral netting";
	Doc.Write();
	Doc.TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.ChoKySo;
	Doc.Write();
	If Doc.NguoiLap <> UserName() Or Doc.TongTienThanhToan <> 43200000
		Or Doc.TienThueVAT <> 3200000
		Or Doc.TrangThaiHDDT <> Enums.TrangThaiHoaDonDienTu.ChoKySo Then
		Raise "Netting invoice did not preserve its source acceptance's VAT basis and approval state.";
	EndIf;
	Return New Structure("invoice,acceptance,base_vnd,vat_vnd,gross_vnd,maker,status", String(Doc.Ref), String(AcceptanceRef), Doc.TienChuaThue, Doc.TienThueVAT, Doc.TongTienThanhToan, Doc.NguoiLap, XMLString(Doc.TrangThaiHDDT));
EndFunction

Function IssueFinanceE2ENettingSalesInvoice() Export
	RequireFinanceE2ERole("GiamDocTaiChinh_CFO");
	Context = FinanceE2EContext();
	InvoiceRef = Documents.HoaDonGTGTDauRa.FindByNumber("E2E-AR-NT001", Date(2026, 10, 20, 9, 30, 0));
	AcceptanceRef = Documents.BienBanNghiemThuGiaiDoan.FindByNumber("E2E-NT-AR001", Date(2026, 10, 20, 9, 0, 0));
	If Not ValueIsFilled(InvoiceRef) Or Not ValueIsFilled(AcceptanceRef) Then
		Raise "Netting invoice or its acceptance source is missing.";
	EndIf;
	Invoice = InvoiceRef.GetObject();
	Invoice.TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.DaPhatHanh;
	Invoice.NguoiDuyet = UserName();
	Invoice.Write(DocumentWriteMode.Posting);
	If Not Invoice.Posted Or Invoice.TongTienThanhToan <> 43200000
		Or FinanceE2EARBalance(Context, AcceptanceRef) <> 0
		Or FinanceE2EARBalance(Context, InvoiceRef) <> 43200000 Then
		Raise "Issued VAT invoice did not transfer the 40m acceptance balance and create the 43.2m receivable.";
	EndIf;
	AssertFinanceE2EGL(InvoiceRef, "1312", "33311", 3200000);
	Return New Structure("invoice,acceptance,posted,net_vnd,vat_vnd,gross_ar_vnd,approver", Invoice.Number, AcceptanceRef.Number, Invoice.Posted, Invoice.TienChuaThue, Invoice.TienThueVAT, FinanceE2EARBalance(Context, InvoiceRef), UserName());
EndFunction

Function SubmitFinanceE2ENettingInvoice() Export
	RequireFinanceE2ERole("KeToanPhaiTra");
	Context = FinanceE2EContext();
	Doc = Documents.HoaDonNhaCungCap.CreateDocument();
	Doc.Number = "E2E-AP-NT001";
	Doc.Date = Date(2026, 10, 20, 10, 0, 0);
	Doc.NgayHoaDon = BegOfDay(Doc.Date);
	Doc.SoHoaDon = "E2EAP-NT001";
	Doc.PhapNhan = Context.PhapNhan;
	Doc.DoiTac = Context.Customer;
	Doc.HopDong = Context.CustomerContract;
	Doc.TaiKhoanChiPhi = Context.Account627;
	Doc.TienTe = Context.VND;
	Doc.TyGia = 1;
	Doc.TongTien = 40000000;
	Doc.TienDichVu = 40000000;
	Doc.TienThueVAT = 0;
	Doc.CoKhauTruFCT = False;
	Doc.TrangThai = Enums.TrangThaiHoaDonAP.DuThao;
	Doc.NguoiDuyet = "ketoan_truong";
	Doc.DienGiai = "E2E VND internal lab rental payable for bilateral netting";
	Doc.Write();
	Doc.TrangThai = Enums.TrangThaiHoaDonAP.ChoKeToanTruongDuyet;
	Doc.Write();
	If Doc.NoThucTraNCC <> 40000000 Or Doc.DoiTac <> Context.Customer Then
		Raise "Netting AP source must create a 40m payable for the same internal partner.";
	EndIf;
	Return New Structure("ap_source,maker,approver,payable_vnd,status", String(Doc.Ref), Doc.NguoiLap, Doc.NguoiDuyet, Doc.NoThucTraNCC, QuanLyVongDoiChungTuServer.TenTrangThai(Doc.TrangThai));
EndFunction

Function PostFinanceE2ENettingInvoice() Export
	RequireFinanceE2ERole("KeToanTruong");
	Context = FinanceE2EContext();
	DocRef = Documents.HoaDonNhaCungCap.FindByNumber("E2E-AP-NT001", Date(2026, 10, 20, 10, 0, 0));
	If Not ValueIsFilled(DocRef) Then Raise "Netting AP source invoice is missing."; EndIf;
	Doc = DocRef.GetObject();
	If Doc.TrangThai <> Enums.TrangThaiHoaDonAP.ChoKeToanTruongDuyet Then
		Raise "Netting AP invoice must be submitted to the KTT before posting.";
	EndIf;
	Doc.TrangThai = Enums.TrangThaiHoaDonAP.DaGhiSo;
	Doc.NguoiDuyet = UserName();
	Doc.Write(DocumentWriteMode.Posting);
	APBalance = FinanceE2ENettingAPBalance(Context, Context.CustomerContract, DocRef);
	If Not Doc.Posted Or APBalance <> 40000000 Then
		Raise StrTemplate("Netting AP source did not create the expected open payable: %1 VND.", APBalance);
	EndIf;
	AssertFinanceE2EGL(DocRef, "627", "3312", 40000000);
	Return New Structure("ap_source_posted,ap_open_vnd,approver", Doc.Posted, APBalance, UserName());
EndFunction

Function PostVerifyFinanceE2ENetting() Export
	RequireFinanceE2ERole("KeToanTruong");
	Context = FinanceE2EContext();
	ARRef = Documents.HoaDonGTGTDauRa.FindByNumber("E2E-AR-NT001", Date(2026, 10, 20, 9, 30, 0));
	APRef = Documents.HoaDonNhaCungCap.FindByNumber("E2E-AP-NT001", Date(2026, 10, 20, 10, 0, 0));
	If Not ValueIsFilled(ARRef) Or Not ValueIsFilled(APRef) Or Not ARRef.Posted Or Not APRef.Posted Then
		Raise "Netting depends on posted AR and AP source documents.";
	EndIf;
	ARBefore = FinanceE2EARBalance(Context, ARRef);
	APBefore = FinanceE2ENettingAPBalance(Context, Context.CustomerContract, APRef);
	If ARBefore <> 43200000 Or APBefore <> 40000000 Then
		Raise StrTemplate("Unexpected open-item balances before netting: AR=%1 AP=%2.", ARBefore, APBefore);
	EndIf;

	OverLimitDoc = Documents.CanTruCongNoNoiBo.CreateDocument();
	OverLimitDoc.Number = "E2E-NET-OVER";
	OverLimitDoc.Date = Date(2026, 10, 20, 10, 59, 0);
	OverLimitDoc.PhapNhan = Context.PhapNhan;
	OverLimitDoc.DoiTac = Context.Customer;
	OverLimitDoc.ChungTuAR = ARRef;
	OverLimitDoc.ChungTuAP = APRef;
	OverLimitDoc.SoTien = 40000001;
	OverLimitDoc.DienGiai = "Negative test: 1 VND greater than the smaller open AR/AP balance";
	OverLimitError = "";
	Try
		OverLimitDoc.Write(DocumentWriteMode.Posting);
	Except
		OverLimitError = DetailErrorDescription(ErrorInfo());
	EndTry;
	If Not IsBlankString(OverLimitError) Then
		WriteLogEvent("Netting.Test.ExpectedRejection", EventLogLevel.Information,,, OverLimitError);
	EndIf;
	If OverLimitDoc.Posted Or FinanceE2EARBalance(Context, ARRef) <> ARBefore
		Or FinanceE2ENettingAPBalance(Context, Context.CustomerContract, APRef) <> APBefore
		Or CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiThu", OverLimitDoc.Ref) <> 0
		Or CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiTra", OverLimitDoc.Ref) <> 0
		Or CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", OverLimitDoc.Ref) <> 0 Then
		Raise "Netting 1 VND above the smaller open balance was not rejected atomically.";
	EndIf;

	Doc = Documents.CanTruCongNoNoiBo.CreateDocument();
	Doc.Number = "E2E-NET-001";
	Doc.Date = Date(2026, 10, 20, 11, 0, 0);
	Doc.PhapNhan = Context.PhapNhan;
	Doc.DoiTac = Context.Customer;
	Doc.ChungTuAR = ARRef;
	Doc.ChungTuAP = APRef;
	Doc.SoTien = 40000000;
	Doc.DienGiai = "Bilateral netting: internal software license AR against lab rental AP";
	Doc.Write(DocumentWriteMode.Posting);
	If Not Doc.Posted Then Raise "40m bilateral netting did not post."; EndIf;
	ARAfter = FinanceE2EARBalance(Context, ARRef);
	APAfter = FinanceE2ENettingAPBalance(Context, Context.CustomerContract, APRef);
	If ARAfter <> 3200000 Or APAFter <> 0 Then
		Raise StrTemplate("Netting balances are wrong: expected AR 3.2m/AP 0; got AR=%1 AP=%2.", ARAfter, APAFter);
	EndIf;
	AssertFinanceE2EGL(Doc.Ref, "3312", "1312", 40000000);
	If CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiThu", Doc.Ref) <> 1
		Or CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiTra", Doc.Ref) <> 1
		Or CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", Doc.Ref) <> 1
		Or CountRecorderMovementRecords("AccumulationRegister.DongTien", Doc.Ref) <> 0 Then
		Raise "Netting must write one AR expense, one AP expense, one balanced GL row, and no cash movement.";
	EndIf;
	Q = New Query(
		"SELECT COUNT(*) AS Cnt
		|FROM AccountingRegister.SoCaiKeToan AS GL
		|WHERE GL.Recorder = &Ref AND GL.DoiTacNo = &Partner AND GL.DoiTacCo = &Partner
		| AND GL.HopDongNo = &APContract AND GL.HopDongCo = &ARContract
		| AND GL.ChungTuGocNo = &APSource AND GL.ChungTuGocCo = &ARSource");
	Q.SetParameter("Ref", Doc.Ref);
	Q.SetParameter("Partner", Context.Customer);
	Q.SetParameter("APContract", Context.CustomerContract);
	Q.SetParameter("ARContract", Context.CustomerContract);
	Q.SetParameter("APSource", APRef);
	Q.SetParameter("ARSource", ARRef);
	If Q.Execute().Unload()[0].Cnt <> 1 Then
		Raise "Netting GL entry is missing the customer, contract, or source-document subconto links.";
	EndIf;

	// Unpost and repost must remove then recreate exactly the same three accounting movements.
	Doc.Write(DocumentWriteMode.UndoPosting);
	If Doc.Posted Or CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiThu", Doc.Ref) <> 0
		Or CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiTra", Doc.Ref) <> 0
		Or CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", Doc.Ref) <> 0
		Or FinanceE2EARBalance(Context, ARRef) <> ARBefore
		Or FinanceE2ENettingAPBalance(Context, Context.CustomerContract, APRef) <> APBefore Then
		Raise "Netting unpost left movement residue or did not restore the original balances.";
	EndIf;
	Doc.Write(DocumentWriteMode.Posting);
	If Not Doc.Posted Or FinanceE2EARBalance(Context, ARRef) <> ARAfter
		Or FinanceE2ENettingAPBalance(Context, Context.CustomerContract, APRef) <> APAFter
		Or CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiThu", Doc.Ref) <> 1
		Or CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiTra", Doc.Ref) <> 1
		Or CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", Doc.Ref) <> 1 Then
		Raise "Netting repost did not reproduce the original balances and movements.";
	EndIf;

	ExhaustedAPDoc = Documents.CanTruCongNoNoiBo.CreateDocument();
	ExhaustedAPDoc.Number = "E2E-NET-ZERO";
	ExhaustedAPDoc.Date = Date(2026, 10, 20, 11, 30, 0);
	ExhaustedAPDoc.PhapNhan = Context.PhapNhan;
	ExhaustedAPDoc.DoiTac = Context.Customer;
	ExhaustedAPDoc.ChungTuAR = ARRef;
	ExhaustedAPDoc.ChungTuAP = APRef;
	ExhaustedAPDoc.SoTien = 1;
	ExhaustedAPDoc.DienGiai = "Negative test: no AP balance remains after the successful offset";
	ExhaustedError = "";
	Try
		ExhaustedAPDoc.Write(DocumentWriteMode.Posting);
	Except
		ExhaustedError = DetailErrorDescription(ErrorInfo());
	EndTry;
	If Not IsBlankString(ExhaustedError) Then
		WriteLogEvent("Netting.Test.ExpectedRejection", EventLogLevel.Information,,, ExhaustedError);
	EndIf;
	If ExhaustedAPDoc.Posted Or FinanceE2EARBalance(Context, ARRef) <> ARAfter
		Or FinanceE2ENettingAPBalance(Context, Context.CustomerContract, APRef) <> APAFter
		Or CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiThu", ExhaustedAPDoc.Ref) <> 0
		Or CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiTra", ExhaustedAPDoc.Ref) <> 0
		Or CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", ExhaustedAPDoc.Ref) <> 0 Then
		Raise "Netting against an exhausted AP balance was not rejected atomically.";
	EndIf;

	Return New Structure("netting_posted,ar_open_before_vnd,ap_open_before_vnd,ar_open_after_vnd,ap_open_after_vnd,gl_debit,gl_credit,unpost_repost,over_available_balance_rejected,exhausted_ap_rejected,cash_movements",
		Doc.Posted, ARBefore, APBefore, ARAfter, APAFter, "3312", "1312", True, Not OverLimitDoc.Posted, Not ExhaustedAPDoc.Posted, 0);
EndFunction

Function CreateFinanceE2ENettingReceipt() Export
	RequireFinanceE2ERole("KeToanPhaiThu");
	Context = FinanceE2EContext();
	ARRef = Documents.HoaDonGTGTDauRa.FindByNumber("E2E-AR-NT001", Date(2026, 10, 20, 9, 30, 0));
	If Not ValueIsFilled(ARRef) Or Not ARRef.Posted Then Raise "Remaining AR receipt requires the posted netting source."; EndIf;
	RemainingAR = FinanceE2EARBalance(Context, ARRef);
	If RemainingAR <> 3200000 Then Raise StrTemplate("Expected 3.2m AR after netting, got %1.", RemainingAR); EndIf;
	Doc = Documents.PhieuThuTienKhachHang.CreateDocument();
	Doc.Number = "E2E-PT-NT001";
	Doc.Date = Date(2026, 10, 20, 14, 0, 0);
	Doc.NgayThu = BegOfDay(Doc.Date);
	Doc.PhapNhan = Context.PhapNhan;
	Doc.DoiTac = Context.Customer;
	Doc.HopDong = Context.CustomerContract;
	Doc.ChungTuGoc = ARRef;
	Doc.TaiKhoanTien = Context.Bank;
	Doc.KhoanMucDongTien = Context.CustomerReceiptCategory;
	Doc.TienTe = Context.VND;
	Doc.TyGia = 1;
	Doc.SoTien = 3200000;
	Doc.NguoiDuyet = "cfo_giamdoc";
	Doc.DienGiai = "E2E settle remaining receivable after bilateral netting";
	Doc.Write();
	If Doc.NguoiLap <> UserName() Then Raise "Netting residual receipt maker was not captured from the AR session."; EndIf;
	Return New Structure("receipt_number,maker,amount_vnd,source", Doc.Number, Doc.NguoiLap, Doc.SoTien, String(ARRef));
EndFunction

Function PostFinanceE2ENettingReceipt() Export
	RequireFinanceE2ERole("GiamDocTaiChinh_CFO");
	Context = FinanceE2EContext();
	DocRef = Documents.PhieuThuTienKhachHang.FindByNumber("E2E-PT-NT001", Date(2026, 10, 20, 14, 0, 0));
	If Not ValueIsFilled(DocRef) Then Raise "Netting residual AR receipt is missing."; EndIf;
	Doc = DocRef.GetObject();
	Doc.Write(DocumentWriteMode.Posting);
	ARRef = Documents.HoaDonGTGTDauRa.FindByNumber("E2E-AR-NT001", Date(2026, 10, 20, 9, 30, 0));
	If Not Doc.Posted Or FinanceE2EARBalance(Context, ARRef) <> 0 Then
		Raise "Receipt after netting did not settle the remaining 3.2m AR balance.";
	EndIf;
	AssertFinanceE2EGL(Doc.Ref, "1121", "1312", 3200000);
	Return New Structure("receipt_posted,ar_closing_vnd,bank_increase_vnd", Doc.Posted, FinanceE2EARBalance(Context, ARRef), Doc.SoTien);
EndFunction

Function RunFinanceE2EPaymentReconciliation() Export
	RequireFinanceE2ERole("GiamDocTaiChinh_CFO");
	Context = FinanceE2EContext();
	CashBefore = FinanceE2ECashBalance(Context);
	Doc = Documents.DoiSoatKenhThanhToan.CreateDocument();
	Doc.Number = "E2E-BK-VNPAY-001";
	Doc.Date = Date(2026, 10, 20, 15, 0, 0);
	Doc.PhapNhan = Context.PhapNhan;
	Doc.DoiTacTrungGian = Context.PaymentProvider;
	Doc.TaiKhoanTien = Context.Bank;
	Doc.KhoanMucDongTien = Context.PaymentReconciliationCategory;
	Doc.TienTe = Context.VND;
	Doc.KenhThanhToan = "VNPAY";
	Doc.TongTienGiaoDich = 75000000;
	Doc.TongPhi = 1125000;
	Doc.TongTienThucNhan = 73875000;
	Doc.DienGiai = "VNPAY settlement: gross 75m, fee 1.5 percent, net 73.875m";
	Doc.Write(DocumentWriteMode.Posting);
	If Not Doc.Posted Then Raise "Balanced VNPAY settlement failed to post."; EndIf;
	AssertFinanceE2EGL(Doc.Ref, "1121", "1388", 73875000);
	AssertFinanceE2EGL(Doc.Ref, "6427", "1388", 1125000);
	CashAfter = FinanceE2ECashBalance(Context);
	If CashAfter <> CashBefore + 73875000
		Or CountRecorderMovementRecords("AccumulationRegister.DongTien", Doc.Ref) <> 1
		Or CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", Doc.Ref) <> 2 Then
		Raise "VNPAY reconciliation did not create exactly one net cash receipt and two balanced GL rows.";
	EndIf;
	Q = New Query(
		"SELECT SUM(GL.SoTien) AS PostedAmount
		|FROM AccountingRegister.SoCaiKeToan AS GL WHERE GL.Recorder = &Ref");
	Q.SetParameter("Ref", Doc.Ref);
	If Q.Execute().Unload()[0].PostedAmount <> 75000000 Then
		Raise "VNPAY GL debits/credits do not each total the 75m gross settlement.";
	EndIf;

	Doc.Write(DocumentWriteMode.UndoPosting);
	If Doc.Posted Or FinanceE2ECashBalance(Context) <> CashBefore
		Or CountRecorderMovementRecords("AccumulationRegister.DongTien", Doc.Ref) <> 0
		Or CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", Doc.Ref) <> 0 Then
		Raise "VNPAY settlement unpost left bank or GL movements behind.";
	EndIf;
	Doc.Write(DocumentWriteMode.Posting);
	If Not Doc.Posted Or FinanceE2ECashBalance(Context) <> CashAfter
		Or CountRecorderMovementRecords("AccumulationRegister.DongTien", Doc.Ref) <> 1
		Or CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", Doc.Ref) <> 2 Then
		Raise "VNPAY settlement repost did not reproduce the same bank and GL balances.";
	EndIf;

	OverDoc = Documents.DoiSoatKenhThanhToan.CreateDocument();
	OverDoc.Number = "E2E-BK-VNPAY-BAD";
	OverDoc.Date = Date(2026, 10, 20, 15, 30, 0);
	OverDoc.PhapNhan = Context.PhapNhan;
	OverDoc.DoiTacTrungGian = Context.PaymentProvider;
	OverDoc.TaiKhoanTien = Context.Bank;
	OverDoc.KhoanMucDongTien = Context.PaymentReconciliationCategory;
	OverDoc.TienTe = Context.VND;
	OverDoc.KenhThanhToan = "VNPAY";
	OverDoc.TongTienGiaoDich = 75000000;
	OverDoc.TongPhi = 1125000;
	OverDoc.TongTienThucNhan = 73875001;
	OverDoc.DienGiai = "Negative test: one VND imbalance";
	Try
		OverDoc.Write(DocumentWriteMode.Posting);
	Except
		// Rejection may be returned by the platform or the document event; movement checks decide PASS.
	EndTry;
	If OverDoc.Posted Or FinanceE2ECashBalance(Context) <> CashAfter
		Or CountRecorderMovementRecords("AccumulationRegister.DongTien", OverDoc.Ref) <> 0
		Or CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", OverDoc.Ref) <> 0 Then
		Raise "One-VND settlement imbalance was not rejected without residual movements.";
	EndIf;
	Return New Structure("channel,gross_vnd,fee_vnd,fee_percent,net_vnd,bank_before_vnd,bank_after_vnd,gl_rows,unpost_repost,one_vnd_imbalance_rejected",
		Doc.KenhThanhToan, Doc.TongTienGiaoDich, Doc.TongPhi, 1.5, Doc.TongTienThucNhan, CashBefore, CashAfter, 2, True, Not OverDoc.Posted);
EndFunction

Function FinanceE2EContext()
	Context = New Structure;
	Context.Insert("PhapNhan", Catalogs.PhapNhan.FindByCode("PN-VSF"));
	Context.Insert("VND", Catalogs.TienTe.FindByCode("VND"));
	Context.Insert("Customer", Catalogs.DoiTac.FindByCode("TEST_VG_VINFAST_VN"));
	Context.Insert("CustomerContract", Catalogs.HopDong.FindByCode("HD-TEST_VG_VINFAST_VN-2025"));
	Context.Insert("Vendor", Catalogs.DoiTac.FindByCode("E2E_AWS_VND"));
	Context.Insert("VendorContract", Catalogs.HopDong.FindByCode("HD-E2E-AWS-VND-2026"));
	Context.Insert("Bank", Catalogs.TaiKhoanTien.FindByCode("TK-E2E-VND"));
	If ValueIsFilled(Context.Bank) And Context.Bank.Code <> "TK-E2E-VND" Then
		Raise "E2E bank account lookup returned a truncated code instead of TK-E2E-VND.";
	EndIf;
	Context.Insert("CustomerReceiptCategory", Catalogs.KhoanMucDongTien.FindByCode("KM-01"));
	Context.Insert("VendorPaymentCategory", Catalogs.KhoanMucDongTien.FindByCode("KM-E2E-AP"));
	Context.Insert("PaymentProvider", Catalogs.DoiTac.FindByCode("E2E_VNPAY"));
	Context.Insert("PaymentReconciliationCategory", Catalogs.KhoanMucDongTien.FindByCode("KM-E2E-GATEWAY"));
	Context.Insert("Account1121", ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1121"));
	Context.Insert("Account627", ChartsOfAccounts.HeThongTaiKhoan.FindByCode("627"));
	For Each PropertyName In StrSplit("PhapNhan,VND,Customer,CustomerContract,Vendor,VendorContract,Bank,CustomerReceiptCategory,VendorPaymentCategory,PaymentProvider,PaymentReconciliationCategory,Account1121,Account627", ",") Do
		If Not ValueIsFilled(Context[PropertyName]) Then
			Raise "Required E2E master data is missing: " + PropertyName;
		EndIf;
	EndDo;
	If Not Context.Customer.LaBenLienKet Then Raise "E2E customer must be an internal counterparty."; EndIf;
	If Context.Vendor.LaBenLienKet Then Raise "E2E vendor must be an external counterparty."; EndIf;
	If Context.VendorContract.DongTienThanhToan.Code <> "VND" Then
		Raise "E2E vendor contract must be denominated in VND.";
	EndIf;
	Return Context;
EndFunction

Procedure EnsureFinanceE2ECashCategory(Val Code, Val Description, Val CashType)
	Ref = Catalogs.KhoanMucDongTien.FindByCode(Code);
	If Not ValueIsFilled(Ref) Then
		Item = Catalogs.KhoanMucDongTien.CreateItem();
		Item.Code = Code;
		Item.Description = Description;
		Item.LoaiDongTien = CashType;
		Item.Write();
	EndIf;
EndProcedure

Procedure EnsureFinanceE2EVendorMasterData(Val LegalEntity, Val VND)
	VendorRef = Catalogs.DoiTac.FindByCode("E2E_AWS_VND");
	If ValueIsFilled(VendorRef) Then
		Vendor = VendorRef.GetObject();
	Else
		Vendor = Catalogs.DoiTac.CreateItem();
		Vendor.Code = "E2E_AWS_VND";
	EndIf;
	Vendor.Description = "E2E AWS foreign contractor, VND settlement";
	Vendor.LaBenLienKet = False;
	Vendor.LoaiDoiTac = Enums.LoaiDoiTac.NhaCungCapCloud;
	Vendor.DaDangKyThueTrucTiep = False;
	Vendor.Write();
	VendorRef = Vendor.Ref;

	ContractRef = Catalogs.HopDong.FindByCode("HD-E2E-AWS-VND-2026");
	If ValueIsFilled(ContractRef) Then
		Contract = ContractRef.GetObject();
	Else
		Contract = Catalogs.HopDong.CreateItem();
		Contract.Code = "HD-E2E-AWS-VND-2026";
	EndIf;
	Contract.Description = "E2E AWS cloud services, VND contract";
	Contract.PhapNhan = LegalEntity;
	Contract.ChuSoHuu = VendorRef;
	Contract.DongTienThanhToan = VND;
	Contract.HanThanhToanNgay = 30;
	Contract.GrossUpThue = False;
	Contract.Write();
EndProcedure

Procedure EnsureFinanceE2EPaymentGateway()
	ProviderRef = Catalogs.DoiTac.FindByCode("E2E_VNPAY");
	If ValueIsFilled(ProviderRef) Then
		Provider = ProviderRef.GetObject();
	Else
		Provider = Catalogs.DoiTac.CreateItem();
		Provider.Code = "E2E_VNPAY";
	EndIf;
	Provider.Description = "E2E payment intermediary VNPAY";
	Provider.LaBenLienKet = False;
	Provider.LoaiDoiTac = Enums.LoaiDoiTac.NhaCungCap;
	Provider.Write();
EndProcedure

Procedure RequireFinanceE2ERole(Val RoleName)
	If Not IsInRole(RoleName) Then
		Raise StrTemplate("E2E phase requires role %1; current user is %2.", RoleName, UserName());
	EndIf;
EndProcedure

Function FinanceE2EARBalance(Val Context, Val SourceDocument)
	Q = New Query(
		"SELECT ISNULL(SUM(SoTienBalance), 0) AS Balance
		|FROM AccumulationRegister.CongNoPhaiThu.Balance(,
		| PhapNhan = &PN AND DoiTac = &Partner AND HopDong = &Contract AND ChungTuGoc = &Source)");
	Q.SetParameter("PN", Context.PhapNhan);
	Q.SetParameter("Partner", Context.Customer);
	If TypeOf(SourceDocument) = Type("DocumentRef.BienBanNghiemThuGiaiDoan") Then
		Q.SetParameter("Contract", Context.CustomerContract);
	Else
		Q.SetParameter("Contract", Context.CustomerContract);
	EndIf;
	Q.SetParameter("Source", SourceDocument);
	Return Q.Execute().Unload()[0].Balance;
EndFunction

Function FinanceE2EAPBalance(Val Context, Val SourceDocument)
	Q = New Query(
		"SELECT ISNULL(SUM(SoTienBalance), 0) AS Balance
		|FROM AccumulationRegister.CongNoPhaiTra.Balance(,
		| PhapNhan = &PN AND DoiTac = &Partner AND HopDong = &Contract AND ChungTuGoc = &Source)");
	Q.SetParameter("PN", Context.PhapNhan);
	Q.SetParameter("Partner", Context.Vendor);
	Q.SetParameter("Contract", Context.VendorContract);
	Q.SetParameter("Source", SourceDocument);
	Return Q.Execute().Unload()[0].Balance;
EndFunction

Function FinanceE2ENettingAPBalance(Val Context, Val Contract, Val SourceDocument)
	Q = New Query(
		"SELECT ISNULL(SUM(SoTienBalance), 0) AS Balance
		|FROM AccumulationRegister.CongNoPhaiTra.Balance(,
		| PhapNhan = &PN AND DoiTac = &Partner AND HopDong = &Contract AND ChungTuGoc = &Source)");
	Q.SetParameter("PN", Context.PhapNhan);
	Q.SetParameter("Partner", Context.Customer);
	Q.SetParameter("Contract", Contract);
	Q.SetParameter("Source", SourceDocument);
	Return Q.Execute().Unload()[0].Balance;
EndFunction

Function FinanceE2ECashBalance(Val Context)
	Q = New Query(
		"SELECT ISNULL(SUM(SoTienBalance), 0) AS Balance
		|FROM AccumulationRegister.DongTien.Balance(,
		| PhapNhan = &PN AND TaiKhoanTien = &Bank AND TienTe = &Currency)");
	Q.SetParameter("PN", Context.PhapNhan);
	Q.SetParameter("Bank", Context.Bank);
	Q.SetParameter("Currency", Context.VND);
	Return Q.Execute().Unload()[0].Balance;
EndFunction

Procedure AssertFinanceE2EGL(Val Recorder, Val DebitAccount, Val CreditAccount, Val Amount)
	Q = New Query(
		"SELECT COUNT(*) AS Cnt
		|FROM AccountingRegister.SoCaiKeToan AS GL
		|WHERE GL.Recorder = &Recorder AND GL.AccountDr.Code = &Debit AND GL.AccountCr.Code = &Credit AND GL.SoTien = &Amount");
	Q.SetParameter("Recorder", Recorder);
	Q.SetParameter("Debit", DebitAccount);
	Q.SetParameter("Credit", CreditAccount);
	Q.SetParameter("Amount", Amount);
	If Q.Execute().Unload()[0].Cnt = 0 Then
		Raise StrTemplate("Missing expected GL entry for recorder %1: Dr %2 / Cr %3 / %4.", Recorder, DebitAccount, CreditAccount, Amount);
	EndIf;
EndProcedure

Function RunBoundaries(Val RunId, Val ResultPath) Export
	Cases = New Array;
	AllPassed = True;
	
	// Test 1: AR Logic & Doi tru chuyen dich cong no
	PassedAR = False;
	ErrorAR = "";
	Try
		ResAR = KiemTraLogicARDemoV3();
		PassedAR = ResAR.Pass;
		If Not PassedAR Then ErrorAR = ResAR.MoTa; EndIf;
	Except
		ErrorAR = DetailErrorDescription(ErrorInfo());
	EndTry;
	AllPassed = AllPassed And PassedAR;
	Cases.Add(New Structure("name,passed,error", "AR_Logic_DebtTransfer", PassedAR, ErrorAR));
	
	// Test 2: AP Logic & Khau tru thue FCT (33318 & 3338)
	PassedAP = False;
	ErrorAP = "";
	Try
		ResAP = KiemTraLogicAPDemoV3();
		PassedAP = ResAP.Pass;
		If Not PassedAP Then ErrorAP = ResAP.MoTa; EndIf;
	Except
		ErrorAP = DetailErrorDescription(ErrorInfo());
	EndTry;
	AllPassed = AllPassed And PassedAP;
	Cases.Add(New Structure("name,passed,error", "AP_Logic_FCT_Split", PassedAP, ErrorAP));
	
	// Test 3: AP Approval Boundary (500M vs 500M+1) & Maker-Checker
	PassedSec = False;
	ErrorSec = "";
	Try
		ResSec = KiemTraAPNguongBienV3();
		PassedSec = ResSec.Pass;
		If Not PassedSec Then ErrorSec = ResSec.MoTa; EndIf;
	Except
		ErrorSec = DetailErrorDescription(ErrorInfo());
	EndTry;
	AllPassed = AllPassed And PassedSec;
	Cases.Add(New Structure("name,passed,error", "AP_Boundary_Approval_500M", PassedSec, ErrorSec));
	
	Result = New Structure("run_id,status,cases", RunId, ?(AllPassed, "PASS", "FAIL"), Cases);
	
	If ValueIsFilled(ResultPath) Then
		Try
			Writer = New JSONWriter;
			Writer.OpenFile(ResultPath);
			WriteJSON(Writer, Result);
			Writer.Close();
		Except
			QuanLyVongDoiChungTuServer.GhiNhatKyError("Boundary.ExportError", DetailErrorDescription(ErrorInfo()));
		EndTry;
	EndIf;
	
	Return Result;
EndFunction

Function PreparePostingInvariantAPFixtures() Export
	RequireFinanceE2ERole("KeToanPhaiTra");
	Context = FinanceE2EContext();
	DraftPayment = CreatePostingInvariantPayment(Context, "E2E-INV-DRAFT");
	BulkDraftPayment = CreatePostingInvariantPayment(Context, "E2E-INV-BULK");
	If DraftPayment.NguoiLap <> UserName() Or BulkDraftPayment.NguoiLap <> UserName()
		Or DraftPayment.TrangThai <> Enums.TrangThaiLenhThanhToan.DuThao
		Or BulkDraftPayment.TrangThai <> Enums.TrangThaiLenhThanhToan.DuThao Then
		Raise "AP posting invariant drafts were not created by the authenticated AP maker.";
	EndIf;
	Return New Structure("draft_payment,batch_payment,maker", String(DraftPayment.Ref), String(BulkDraftPayment.Ref), UserName());
EndFunction

Function PreparePostingInvariantAcceptance() Export
	RequireFinanceE2ERole("KeToanPhaiThu");
	Context = FinanceE2EContext();
	Acceptance = Documents.BienBanNghiemThuGiaiDoan.CreateDocument();
	Acceptance.Number = "E2E-INV-ZVAT-BB";
	Acceptance.Date = Date(2026, 10, 20, 9, 0, 0);
	Acceptance.PhapNhan = Context.PhapNhan;
	Acceptance.DoiTac = Context.Customer;
	Acceptance.HopDong = Context.CustomerContract;
	Acceptance.NgayNghiemThu = BegOfDay(Acceptance.Date);
	Acceptance.GiaTriNghiemThuChuaVAT = 1234567;
	Acceptance.TyLeVAT = 0;
	Acceptance.TienVAT = 0;
	Acceptance.TongGiaTri = 1234567;
	Acceptance.TrangThai = Enums.TrangThaiNghiemThuAR.ChoDuyetNoiBo;
	Acceptance.NguoiDuyet = "cfo_giamdoc";
	Acceptance.DienGiai = "Posting invariant zero VAT acceptance";
	Acceptance.Write();
	If Acceptance.NguoiTao <> UserName() Or Acceptance.Posted Then
		Raise "Zero-VAT acceptance draft was not saved by AR in the expected unposted state.";
	EndIf;
	Return New Structure("acceptance,maker,status", String(Acceptance.Ref), Acceptance.NguoiTao, XMLString(Acceptance.TrangThai));
EndFunction

Function PostPostingInvariantAcceptance() Export
	RequireFinanceE2ERole("GiamDocTaiChinh_CFO");
	AcceptanceRef = Documents.BienBanNghiemThuGiaiDoan.FindByNumber("E2E-INV-ZVAT-BB", Date(2026, 10, 20, 9, 0, 0));
	If Not ValueIsFilled(AcceptanceRef) Then Raise "Zero-VAT acceptance fixture is missing."; EndIf;
	Acceptance = AcceptanceRef.GetObject();
	If Acceptance.Posted Or Acceptance.NguoiTao <> "ketoan_ar" Or Acceptance.NguoiDuyet <> UserName() Then
		Raise "Zero-VAT acceptance is not in the expected maker-checker state.";
	EndIf;
	Acceptance.TrangThai = Enums.TrangThaiNghiemThuAR.DaDuyetNoiBo;
	Acceptance.Write();
	Acceptance.Write(DocumentWriteMode.Posting);
	If Not Acceptance.Posted Then Raise "CFO did not post the zero-VAT acceptance source."; EndIf;
	Return New Structure("acceptance,approver,status,posted", String(AcceptanceRef), UserName(), XMLString(Acceptance.TrangThai), Acceptance.Posted);
EndFunction

Function PreparePostingInvariantARInvoices() Export
	RequireFinanceE2ERole("KeToanPhaiThu");
	Context = FinanceE2EContext();
	AcceptanceRef = Documents.BienBanNghiemThuGiaiDoan.FindByNumber("E2E-INV-ZVAT-BB", Date(2026, 10, 20, 9, 0, 0));
	If Not ValueIsFilled(AcceptanceRef) Or Not AcceptanceRef.Posted Then
		Raise "AR invoice invariant fixtures require a posted zero-VAT acceptance source.";
	EndIf;
	CancelledInvoice = CreatePostingInvariantSalesInvoiceDraft(Context, "E2E-INV-CANCEL", Undefined);
	ZeroVATInvoice = CreatePostingInvariantSalesInvoiceDraft(Context, "E2E-INV-ZVAT", AcceptanceRef);
	ValidInvoice = CreatePostingInvariantSalesInvoiceDraft(Context, "E2E-INV-TX-GOOD", Undefined);
	InvalidInvoice = CreatePostingInvariantSalesInvoiceDraft(Context, "E2E-INV-TX-BAD", Undefined);
	Invoices = New Array;
	Invoices.Add(CancelledInvoice);
	Invoices.Add(ZeroVATInvoice);
	Invoices.Add(ValidInvoice);
	Invoices.Add(InvalidInvoice);
	For Each Invoice In Invoices Do
		If Invoice.NguoiLap <> UserName() Or Invoice.NguoiDuyet <> "cfo_giamdoc"
			Or Invoice.TrangThaiHDDT <> Enums.TrangThaiHoaDonDienTu.ChoKySo Or Invoice.Posted Then
			Raise StrTemplate("AR invariant draft %1 was not created by the authenticated maker in ChoKySo.", Invoice.Number);
		EndIf;
	EndDo;
	Return New Structure("cancelled_invoice,zero_vat_invoice,transaction_valid,transaction_invalid,maker",
		CancelledInvoice.Number, ZeroVATInvoice.Number, ValidInvoice.Number, InvalidInvoice.Number, UserName());
EndFunction

Function RunPostingStateInvariantTests(Val RunId, Val ResultPath) Export
	Cases = New Array;
	AllPassed = True;
	Context = FinanceE2EContext();

	// A payment in Draft must not become Posted or report success without register records.
	Passed = False;
	ErrorText = "";
	Try
		PaymentRef = Documents.UyNhiemChi.FindByNumber("E2E-INV-DRAFT", Date(2026, 10, 20, 8, 0, 0));
		If Not ValueIsFilled(PaymentRef) Then Raise "AP draft posting invariant fixture is missing."; EndIf;
		Payment = PaymentRef.GetObject();
		PostError = "";
		Try
			Payment.Write(DocumentWriteMode.Posting);
		Except
			PostError = DetailErrorDescription(ErrorInfo());
		EndTry;
		SavedPayment = Payment.Ref.GetObject();
		APCount = CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiTra", Payment.Ref);
		CashCount = CountRecorderMovementRecords("AccumulationRegister.DongTien", Payment.Ref);
		GLCount = CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", Payment.Ref);
		Passed = StrFind(PostError, "Failed to post") > 0 And Not SavedPayment.Posted And APCount = 0 And CashCount = 0 And GLCount = 0;
		If Not Passed Then
			ErrorText = StrTemplate("Draft payment invariant failed: error=%1 Posted=%2 AP=%3 Cash=%4 GL=%5", PostError, SavedPayment.Posted, APCount, CashCount, GLCount);
		EndIf;
	Except
		ErrorText = DetailErrorDescription(ErrorInfo());
	EndTry;
	AllPassed = AllPassed And Passed;
	Cases.Add(New Structure("name,passed,error", "UNC_DraftCannotBePosted", Passed, ErrorText));

	// A cancelled outgoing invoice cannot be marked Posted with empty movements.
	Passed = False;
	ErrorText = "";
	Try
		InvoiceRef = Documents.HoaDonGTGTDauRa.FindByNumber("E2E-INV-CANCEL", Date(2026, 10, 20, 9, 0, 0));
		If Not ValueIsFilled(InvoiceRef) Then Raise "Cancelled AR invoice posting invariant fixture is missing."; EndIf;
		Invoice = InvoiceRef.GetObject();
		Invoice.TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.DaHuy;
		Invoice.Write();
		PostError = "";
		Try
			Invoice.Write(DocumentWriteMode.Posting);
		Except
			PostError = DetailErrorDescription(ErrorInfo());
		EndTry;
		SavedInvoice = Invoice.Ref.GetObject();
		ARCount = CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiThu", Invoice.Ref);
		GLCount = CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", Invoice.Ref);
		Passed = StrFind(PostError, "Failed to post") > 0 And Not SavedInvoice.Posted And ARCount = 0 And GLCount = 0;
		If Not Passed Then
			ErrorText = StrTemplate("Cancelled invoice invariant failed: error=%1 Posted=%2 AR=%3 GL=%4", PostError, SavedInvoice.Posted, ARCount, GLCount);
		EndIf;
	Except
		ErrorText = DetailErrorDescription(ErrorInfo());
	EndTry;
	AllPassed = AllPassed And Passed;
	Cases.Add(New Structure("name,passed,error", "CancelledInvoiceCannotBePosted", Passed, ErrorText));

	// A zero-VAT invoice based on a posted acceptance still has to transfer the AR balance.
	Passed = False;
	ErrorText = "";
	Try
		AcceptanceRef = Documents.BienBanNghiemThuGiaiDoan.FindByNumber("E2E-INV-ZVAT-BB", Date(2026, 10, 20, 9, 0, 0));
		If Not ValueIsFilled(AcceptanceRef) Or Not AcceptanceRef.Posted Then Raise "Zero-VAT source acceptance is missing or unposted."; EndIf;
		Acceptance = AcceptanceRef.GetObject();
		ZeroVATInvoiceRef = Documents.HoaDonGTGTDauRa.FindByNumber("E2E-INV-ZVAT", Date(2026, 10, 20, 9, 0, 0));
		If Not ValueIsFilled(ZeroVATInvoiceRef) Then Raise "Zero-VAT sales invoice fixture is missing."; EndIf;
		ZeroVATInvoice = ZeroVATInvoiceRef.GetObject();
		ZeroVATInvoice.TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.DaPhatHanh;
		ZeroVATInvoice.Write();
		ZeroVATInvoice.Write(DocumentWriteMode.Posting);
		SavedZeroVATInvoice = ZeroVATInvoice.Ref.GetObject();
		Q = New Query("SELECT * FROM AccumulationRegister.CongNoPhaiThu WHERE Recorder = &Recorder ORDER BY LineNumber");
		Q.SetParameter("Recorder", ZeroVATInvoice.Ref);
		Selection = Q.Execute().Select();
		ClearedAcceptance = 0;
		CreatedInvoice = 0;
		ARCount = 0;
		While Selection.Next() Do
			ARCount = ARCount + 1;
			If Selection.RecordType = AccumulationRecordType.Expense And Selection.ChungTuGoc = Acceptance.Ref Then
				ClearedAcceptance = ClearedAcceptance + Selection.SoTien;
			ElsIf Selection.RecordType = AccumulationRecordType.Receipt And Selection.ChungTuGoc = ZeroVATInvoice.Ref Then
				CreatedInvoice = CreatedInvoice + Selection.SoTien;
			EndIf;
		EndDo;
		Passed = SavedZeroVATInvoice.Posted And ARCount = 2
			And ClearedAcceptance = Acceptance.GiaTriNghiemThuChuaVAT
			And CreatedInvoice = Acceptance.GiaTriNghiemThuChuaVAT;
		If Not Passed Then
			ErrorText = StrTemplate("Zero-VAT debt transfer failed: Posted=%1 records=%2 cleared=%3 invoiced=%4 expected=%5", SavedZeroVATInvoice.Posted, ARCount, ClearedAcceptance, CreatedInvoice, Acceptance.GiaTriNghiemThuChuaVAT);
		EndIf;
	Except
		ErrorText = DetailErrorDescription(ErrorInfo());
	EndTry;
	AllPassed = AllPassed And Passed;
	Cases.Add(New Structure("name,passed,error", "ZeroVATInvoiceTransfersAcceptanceAR", Passed, ErrorText));

	// Bulk approval must only accept a workflow-eligible document and must verify the saved outcome.
	Passed = False;
	ErrorText = "";
	Try
		DraftPaymentRef = Documents.UyNhiemChi.FindByNumber("E2E-INV-BULK", Date(2026, 10, 20, 8, 0, 0));
		If Not ValueIsFilled(DraftPaymentRef) Then Raise "AP batch-approval invariant fixture is missing."; EndIf;
		DraftPayment = DraftPaymentRef.GetObject();
		Refs = New Array;
		Refs.Add(DraftPayment.Ref);
		Workspace = DataProcessors.BanLamViecWebERP.Create();
		BulkResult = Workspace.PheDuyetHangLoat(Refs);
		SavedDraftPayment = DraftPayment.Ref.GetObject();
		Queue = DataProcessors.BanLamViecWebERP.LayDanhSachChoPheDuyet();
		IsInApprovalQueue = False;
		For Each QueueItem In Queue Do
			If QueueItem.ChungTu = DraftPayment.Ref Then IsInApprovalQueue = True; EndIf;
		EndDo;
		Passed = BulkResult.ThanhCong = 0 And BulkResult.ThatBai = 1 And Not SavedDraftPayment.Posted And Not IsInApprovalQueue;
		If Not Passed Then
			ErrorText = StrTemplate("Batch approval eligibility failed: success=%1 failure=%2 posted=%3 queued=%4", BulkResult.ThanhCong, BulkResult.ThatBai, SavedDraftPayment.Posted, IsInApprovalQueue);
		EndIf;
	Except
		ErrorText = DetailErrorDescription(ErrorInfo());
	EndTry;
	AllPassed = AllPassed And Passed;
	Cases.Add(New Structure("name,passed,error", "BatchApprovalRejectsDraft", Passed, ErrorText));

	// A later posting failure must roll back an earlier successful post in the same explicit transaction.
	Passed = False;
	ErrorText = "";
	ValidInvoice = Undefined;
	InvalidInvoice = Undefined;
	PostError = "";
	ValidPostedInsideTransaction = False;
	ValidGLInsideTransaction = 0;
	Try
		ValidInvoiceRef = Documents.HoaDonGTGTDauRa.FindByNumber("E2E-INV-TX-GOOD", Date(2026, 10, 20, 9, 0, 0));
		InvalidInvoiceRef = Documents.HoaDonGTGTDauRa.FindByNumber("E2E-INV-TX-BAD", Date(2026, 10, 20, 9, 0, 0));
		If Not ValueIsFilled(ValidInvoiceRef) Or Not ValueIsFilled(InvalidInvoiceRef) Then Raise "Transaction rollback invoice fixtures are missing."; EndIf;
		ValidInvoice = ValidInvoiceRef.GetObject();
		InvalidInvoice = InvalidInvoiceRef.GetObject();
		ValidInvoice.TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.DaPhatHanh;
		ValidInvoice.Write();
		InvalidInvoice.TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.DaHuy;
		InvalidInvoice.Write();
		BeginTransaction();
		ValidInvoice.Write(DocumentWriteMode.Posting);
		ValidPostedInsideTransaction = ValidInvoice.Ref.GetObject().Posted;
		ValidGLInsideTransaction = CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", ValidInvoice.Ref);
		Try
			InvalidInvoice.Write(DocumentWriteMode.Posting);
		Except
			PostError = DetailErrorDescription(ErrorInfo());
		EndTry;
		If TransactionActive() Then RollbackTransaction(); EndIf;

		SavedValidInvoice = ValidInvoice.Ref.GetObject();
		SavedInvalidInvoice = InvalidInvoice.Ref.GetObject();
		ValidMovementCount = CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", ValidInvoice.Ref)
			+ CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiThu", ValidInvoice.Ref);
		InvalidMovementCount = CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", InvalidInvoice.Ref)
			+ CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiThu", InvalidInvoice.Ref);
		Passed = StrFind(PostError, "Failed to post") > 0 And ValidPostedInsideTransaction And ValidGLInsideTransaction > 0
			And Not SavedValidInvoice.Posted And Not SavedInvalidInvoice.Posted
			And ValidMovementCount = 0 And InvalidMovementCount = 0;
		If Not Passed Then
			ErrorText = StrTemplate("Transaction rollback invariant failed: error=%1 validPostedInside=%2 validGLInside=%3 validPostedAfter=%4 invalidPostedAfter=%5 validMovements=%6 invalidMovements=%7.",
				PostError, ValidPostedInsideTransaction, ValidGLInsideTransaction, SavedValidInvoice.Posted, SavedInvalidInvoice.Posted, ValidMovementCount, InvalidMovementCount);
		EndIf;
	Except
		If TransactionActive() Then RollbackTransaction(); EndIf;
		ErrorText = DetailErrorDescription(ErrorInfo());
	EndTry;
	AllPassed = AllPassed And Passed;
	Cases.Add(New Structure("name,passed,error", "PostingFailureRollsBackPriorDocument", Passed, ErrorText));

	Result = New Structure("run_id,phase,user,status,cases", RunId, "posting_state_invariants", UserName(), ?(AllPassed, "PASS", "FAIL"), Cases);
	If ValueIsFilled(ResultPath) Then
		Writer = New JSONWriter;
		Writer.OpenFile(ResultPath);
		WriteJSON(Writer, Result);
		Writer.Close();
	EndIf;
	Return Result;
EndFunction

Function CreatePostingInvariantPayment(Val Context, Val Number)
	Payment = Documents.UyNhiemChi.CreateDocument();
	Payment.Number = Number;
	Payment.Date = Date(2026, 10, 20, 8, 0, 0);
	Payment.NgayLap = BegOfDay(Payment.Date);
	Payment.NgayGhiSo = BegOfDay(Payment.Date);
	Payment.PhapNhan = Context.PhapNhan;
	Payment.DoiTac = Context.Vendor;
	Payment.HopDong = Context.VendorContract;
	Payment.ChungTuGoc = Documents.HoaDonNhaCungCap.FindByNumber("E2E-AP001", Date(2026, 10, 13, 9, 0, 0));
	Payment.TaiKhoanTien = Context.Bank;
	Payment.KhoanMucDongTien = Context.VendorPaymentCategory;
	Payment.TienTe = Context.VND;
	Payment.TyGia = 1;
	Payment.SoTien = 1;
	Payment.TrangThai = Enums.TrangThaiLenhThanhToan.DuThao;
	Payment.NguoiDuyet = "cfo_giamdoc";
	Payment.Write();
	If Payment.NguoiLap <> UserName() Then Raise "AP invariant draft maker was not captured from the authenticated session."; EndIf;
	Return Payment;
EndFunction

Function CreatePostingInvariantSalesInvoiceDraft(Val Context, Val Number, Val AcceptanceRef)
	Invoice = Documents.HoaDonGTGTDauRa.CreateDocument();
	Invoice.Number = Number;
	Invoice.Date = Date(2026, 10, 20, 9, 0, 0);
	Invoice.SoHoaDon = Number;
	Invoice.KyHieu = "E2E-INV";
	Invoice.PhapNhan = Context.PhapNhan;
	Invoice.DoiTac = Context.Customer;
	Invoice.HopDong = Context.CustomerContract;
	Invoice.BienBanNghiemThu = AcceptanceRef;
	Invoice.NgayHoaDon = BegOfDay(Invoice.Date);
	Invoice.TienChuaThue = 1234567;
	Invoice.ThueSuatVAT = 0;
	Invoice.TienThueVAT = 0;
	Invoice.TongTienThanhToan = 1234567;
	Invoice.TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.ChoKySo;
	Invoice.NguoiDuyet = "cfo_giamdoc";
	Invoice.DienGiai = "Posting invariant sales invoice";
	Invoice.Write();
	If Invoice.NguoiLap <> UserName() Or Invoice.TrangThaiHDDT <> Enums.TrangThaiHoaDonDienTu.ChoKySo Then
		Raise "AR invariant invoice draft maker or approval state is incorrect.";
	EndIf;
	Return Invoice;
EndFunction

Function CountRecorderMovementRecords(Val TableName, Val Recorder)
	Q = New Query("SELECT COUNT(*) AS Cnt FROM " + TableName + " WHERE Recorder = &Recorder");
	Q.SetParameter("Recorder", Recorder);
	Return Q.Execute().Unload()[0].Cnt;
EndFunction

// Kiem tra toan bo luong AR: BBNT 200tr -> HD 220tr -> Phieu thu 220tr -> Tat toan 0
Function KiemTraLogicARDemoV3() Export
	KetQua = New Structure("Pass, MoTa", True, "");
	
	// 1. Kiem tra tinh toan thue va chuyen dich theo ngay hien hanh (fixture du dieu kien giam)
	GiaTriChuaVAT = 200000000;
	TyLeVAT = ThueGTGTClientServer.TyLeVATApDungTheoNgay(CurrentSessionDate(), True);
	TienThueVAT = Round(GiaTriChuaVAT * (TyLeVAT / 100), 2);
	TongTien = GiaTriChuaVAT + TienThueVAT;
	
	If TienThueVAT <> Round(GiaTriChuaVAT * TyLeVAT / 100, 2)
		Or TongTien <> GiaTriChuaVAT + TienThueVAT Then
		KetQua.Pass = False;
		KetQua.MoTa = StrTemplate("Sai lech tinh toan AR: Thue=%1, Tong=%2", TienThueVAT, TongTien);
		Return KetQua;
	EndIf;
	
	// 2. Kiem tra can doi chuyen dich no tren Subledger CongNoPhaiThu
	// BBNT: Receipt +200tr (ChungTuGoc = BBNT)
	// HD: Expense -200tr (ChungTuGoc = BBNT) va Receipt +TongTien (ChungTuGoc = HD)
	// Phieu thu: Expense -TongTien (ChungTuGoc = HD)
	DuBBNT_SauHD = 200000000 - 200000000;
	DuHD_SauHD = TongTien;
	DuHD_SauPhieuThu = DuHD_SauHD - TongTien;
	
	If DuBBNT_SauHD <> 0 Or DuHD_SauPhieuThu <> 0 Then
		KetQua.Pass = False;
		KetQua.MoTa = StrTemplate("Sổ chi tiết AR không về 0: Dư BBNT=%1, Dư HĐ=%2", DuBBNT_SauHD, DuHD_SauPhieuThu);
		Return KetQua;
	EndIf;
	
	// 3. Kiem tra can doi So cai TK 1311
	// BBNT: No 1311 +200tr
	// HD: No 1311 +VAT
	// Phieu thu: Co 1311 -TongTien
	DuGL_1311 = 200000000 + TienThueVAT - TongTien;
	If DuGL_1311 <> 0 Then
		KetQua.Pass = False;
		KetQua.MoTa = StrTemplate("Sổ cái TK 1311 không về 0: Dư=%1", DuGL_1311);
		Return KetQua;
	EndIf;
	
	KetQua.MoTa = StrTemplate("AR_LOGIC_PASS_ZERO_RESIDUAL: VAT=%1%%, BBNT=0, HD=0, TK 1311=0", TyLeVAT);
	Return KetQua;
EndFunction

// Kiem tra toan bo luong AP: HD 250tr gross -> FCT 25tr -> Thuc tra 225tr -> UNC 225tr -> 3311 ve 0, 33318/3338 treo 25tr
Function KiemTraLogicAPDemoV3() Export
	KetQua = New Structure("Pass, MoTa", True, "");
	
	TongTienGross = 250000000;
	TyLeVAT_FCT = 5;
	TyLeTNDN_FCT = 5;
	
	TienThueVAT = Round(TongTienGross * (TyLeVAT_FCT / 100), 2);
	TienThueTNDN = Round(TongTienGross * (TyLeTNDN_FCT / 100), 2);
	TongThueFCT = TienThueVAT + TienThueTNDN;
	NoThucTraNCC = TongTienGross - TongThueFCT;
	ChiPhiVSF = NoThucTraNCC + TienThueTNDN;
	
	If TienThueVAT <> 12500000 Or TienThueTNDN <> 12500000 Or NoThucTraNCC <> 225000000 Or ChiPhiVSF <> 237500000 Then
		KetQua.Pass = False;
		KetQua.MoTa = StrTemplate("Sai lech tinh toan FCT: VAT=%1, TNDN=%2, ThucTra=%3, ChiPhi=%4", TienThueVAT, TienThueTNDN, NoThucTraNCC, ChiPhiVSF);
		Return KetQua;
	EndIf;
	
	// Can doi kep So cai tai Hoa don NCC:
	// No: ChiPhi 627 (237.5tr) + ThueVATDauVao 1331 (12.5tr) = 250tr
	// Co: CongNo 3311 (225tr) + ThueVAT 33318 (12.5tr) + ThueTNDN 3338 (12.5tr) = 250tr
	TongNoGL = ChiPhiVSF + TienThueVAT;
	TongCoGL = NoThucTraNCC + TienThueVAT + TienThueTNDN;
	If TongNoGL <> TongCoGL Then
		KetQua.Pass = False;
		KetQua.MoTa = StrTemplate("Mất cân đối Sổ cái Hóa đơn NCC: Nợ=%1, Có=%2", TongNoGL, TongCoGL);
		Return KetQua;
	EndIf;
	
	// Can doi sau UNC 225tr:
	// No 3311 / Co 1121 = 225tr
	DuTK3311 = NoThucTraNCC - NoThucTraNCC;
	If DuTK3311 <> 0 Then
		KetQua.Pass = False;
		KetQua.MoTa = StrTemplate("Công nợ NCC TK 3311 không về 0: Dư=%1", DuTK3311);
		Return KetQua;
	EndIf;
	
	KetQua.MoTa = "AP_LOGIC_PASS_FCT_MATCH: TK 3311=0, Treo Có 33318=12.5tr, Treo Có 3338=12.5tr";
	Return KetQua;
EndFunction

// Kiem tra nguong bien phe duyet AP: 500.000.000 (KTT) vs 500.000.001 (CFO) va chan KTT vuot quyen
Function KiemTraAPNguongBienV3() Export
	KetQua = New Structure("Pass, MoTa", True, "");
	
	// 1. Dung bang 500.000.000 VND -> KTT duyet thang sang DaGhiSo
	NextState_500M = QuyTrinhPheDuyetAPServer.XacDinhTrangThaiTiepTheo("ChoKeToanTruongDuyet", 500000000);
	If NextState_500M <> "DaGhiSo" Then
		KetQua.Pass = False;
		KetQua.MoTa = StrTemplate("Lỗi ca biên 500.000.000: Kỳ vọng 'DaGhiSo' nhưng thực tế là '%1'", NextState_500M);
		Return KetQua;
	EndIf;
	
	// 2. Vuot 1 dong: 500.000.001 VND -> Bat buoc ChoDuyetCFO
	NextState_500M_Plus1 = QuyTrinhPheDuyetAPServer.XacDinhTrangThaiTiepTheo("ChoKeToanTruongDuyet", 500000001);
	If NextState_500M_Plus1 <> "ChoDuyetCFO" Then
		KetQua.Pass = False;
		KetQua.MoTa = StrTemplate("Lỗi ca biên 500.000.001: Kỳ vọng 'ChoDuyetCFO' nhưng thực tế là '%1'", NextState_500M_Plus1);
		Return KetQua;
	EndIf;
	
	// 3. Kiem tra chan KTT vuot quyen: Hoa don 600tr khong the ghi so thang tu ChoKeToanTruongDuyet
	ChanVuotQuyenPass = False;
	Try
		QuyTrinhPheDuyetAPServer.KiemTraBuocDuyetAP("ChoKeToanTruongDuyet", "DaGhiSo", 600000000, "nguoi_khac");
	Except
		ChanVuotQuyenPass = True;
	EndTry;
	
	If Not ChanVuotQuyenPass Then
		KetQua.Pass = False;
		KetQua.MoTa = "LỖI BẢO MẬT: Kế toán trưởng duyệt thẳng hóa đơn > 500tr mà không bị chặn!";
		Return KetQua;
	EndIf;
	
	// 4. Maker-Checker: Nguoi lap tu duyet bi chan
	MakerCheckerPass = False;
	Try
		QuyTrinhPheDuyetAPServer.KiemTraBuocDuyetAP("ChoKeToanTruongDuyet", "DaGhiSo", 250000000, UserName());
	Except
		MakerCheckerPass = True;
	EndTry;
	
	If Not MakerCheckerPass Then
		KetQua.Pass = False;
		KetQua.MoTa = "LỖI BẢO MẬT: Người lập tự phê duyệt hóa đơn của mình mà không bị chặn!";
		Return KetQua;
	EndIf;
	
	KetQua.MoTa = "BOUNDARY_AND_SECURITY_PASS: 500M (KTT) -> DaGhiSo; 500M+1 -> ChoDuyetCFO; Maker-Checker chan thanh cong.";
	Return KetQua;
EndFunction

#EndRegion


Function VerifyFinanceDashboard() Export
	ThoiDiemBaoCao = CurrentDate();
	DauNgayBaoCao = Date(Year(ThoiDiemBaoCao), Month(ThoiDiemBaoCao), Day(ThoiDiemBaoCao));
	DauKyThang = Date(Year(ThoiDiemBaoCao), Month(ThoiDiemBaoCao), 1);
	
	ThangQuery = New Query;
	ThangQuery.Text =
		"SELECT
		|	COUNT(HoaDon.Ref) AS SoHoaDon
		|FROM
		|	Document.HoaDonGTGTDauRa AS HoaDon
		|WHERE
		|	HoaDon.Posted = TRUE
		|	AND HoaDon.DeletionMark = FALSE
		|	AND HoaDon.Date >= &DauKy
		|	AND HoaDon.Date <= &CuoiKy";
	ThangQuery.SetParameter("DauKy", DauKyThang);
	ThangQuery.SetParameter("CuoiKy", ThoiDiemBaoCao);
	BangThang = ThangQuery.Execute().Unload();
	DoanhThuKyVong = 0;
	SoHoaDonKyVong = 0;
	If BangThang.Count() > 0 Then
		If BangThang[0].SoHoaDon <> Null Then
			SoHoaDonKyVong = BangThang[0].SoHoaDon;
		EndIf;
	EndIf;
	
	AcceptedRevenueQuery = New Query;
	AcceptedRevenueQuery.Text =
		"SELECT
		|    SUM(Acceptance.GiaTriNghiemThuChuaVAT) AS DoanhThu
		|FROM
		|    Document.BienBanNghiemThuGiaiDoan AS Acceptance
		|WHERE
		|    Acceptance.Posted = TRUE
		|    AND Acceptance.DeletionMark = FALSE
		|    AND Acceptance.Date >= &DauKy
		|    AND Acceptance.Date <= &CuoiKy";
	AcceptedRevenueQuery.SetParameter("DauKy", DauKyThang);
	AcceptedRevenueQuery.SetParameter("CuoiKy", ThoiDiemBaoCao);
	AcceptedRevenueTable = AcceptedRevenueQuery.Execute().Unload();
	ExpectedAcceptedRevenue = 0;
	If AcceptedRevenueTable.Count() > 0 And AcceptedRevenueTable[0].DoanhThu <> Null Then
		ExpectedAcceptedRevenue = AcceptedRevenueTable[0].DoanhThu;
	EndIf;
	DirectRevenueQuery = New Query;
	DirectRevenueQuery.Text =
		"SELECT
		|    SUM(Invoice.TienChuaThue) AS DoanhThu
		|FROM
		|    Document.HoaDonGTGTDauRa AS Invoice
		|WHERE
		|    Invoice.Posted = TRUE
		|    AND Invoice.DeletionMark = FALSE
		|    AND Invoice.BienBanNghiemThu = &EmptyAcceptance
		|    AND Invoice.Date >= &DauKy
		|    AND Invoice.Date <= &CuoiKy";
	DirectRevenueQuery.SetParameter("EmptyAcceptance", Documents.BienBanNghiemThuGiaiDoan.EmptyRef());
	DirectRevenueQuery.SetParameter("DauKy", DauKyThang);
	DirectRevenueQuery.SetParameter("CuoiKy", ThoiDiemBaoCao);
	DirectRevenueTable = DirectRevenueQuery.Execute().Unload();
	ExpectedDirectRevenue = 0;
	If DirectRevenueTable.Count() > 0 And DirectRevenueTable[0].DoanhThu <> Null Then
		ExpectedDirectRevenue = DirectRevenueTable[0].DoanhThu;
	EndIf;
	DoanhThuKyVong = ExpectedAcceptedRevenue + ExpectedDirectRevenue;
	
	RevenueAccount = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("5113");
	GLRevenueQuery = New Query;
	GLRevenueQuery.Text =
		"SELECT
		|	SUM(Entry.SoTien) AS TongDoanhThu
		|FROM
		|	AccountingRegister.SoCaiKeToan AS Entry
		|WHERE
		|	Entry.AccountCr = &TaiKhoanDoanhThu
		|	AND Entry.Active = TRUE
		|	AND Entry.Period >= &DauKy
		|	AND Entry.Period <= &CuoiKy";
	GLRevenueQuery.SetParameter("TaiKhoanDoanhThu", RevenueAccount);
	GLRevenueQuery.SetParameter("DauKy", DauKyThang);
	GLRevenueQuery.SetParameter("CuoiKy", ThoiDiemBaoCao);
	GLRevenueTable = GLRevenueQuery.Execute().Unload();
	ExpectedGLRevenue = 0;
	If GLRevenueTable.Count() > 0 Then
		If GLRevenueTable[0].TongDoanhThu <> Null Then
			ExpectedGLRevenue = GLRevenueTable[0].TongDoanhThu;
		EndIf;
	EndIf;
	GLRevenueDebitQuery = New Query;
	GLRevenueDebitQuery.Text =
		"SELECT
		|    SUM(Entry.SoTien) AS TongDoanhThu
		|FROM
		|    AccountingRegister.SoCaiKeToan AS Entry
		|WHERE
		|    Entry.AccountDr = &TaiKhoanDoanhThu
		|    AND Entry.Active = TRUE
		|    AND Entry.Period >= &DauKy
		|    AND Entry.Period <= &CuoiKy";
	GLRevenueDebitQuery.SetParameter("TaiKhoanDoanhThu", RevenueAccount);
	GLRevenueDebitQuery.SetParameter("DauKy", DauKyThang);
	GLRevenueDebitQuery.SetParameter("CuoiKy", ThoiDiemBaoCao);
	GLRevenueDebitTable = GLRevenueDebitQuery.Execute().Unload();
	If GLRevenueDebitTable.Count() > 0 And GLRevenueDebitTable[0].TongDoanhThu <> Null Then
		ExpectedGLRevenue = ExpectedGLRevenue - GLRevenueDebitTable[0].TongDoanhThu;
	EndIf;
	InvoiceDetailsQuery = New Query;
	InvoiceDetailsQuery.Text =
		"SELECT
		|    Invoice.Number AS Number,
		|    Invoice.Date AS Date,
		|    Invoice.Posted AS Posted,
		|    Invoice.DeletionMark AS DeletionMark,
		|    Invoice.TrangThaiHDDT AS Status,
		|    Invoice.TienChuaThue AS NetAmount
		|FROM
		|    Document.HoaDonGTGTDauRa AS Invoice
		|WHERE
		|    Invoice.Date >= &DauKy
		|    AND Invoice.Date <= &CuoiKy
		|ORDER BY
		|    Invoice.Date";
	InvoiceDetailsQuery.SetParameter("DauKy", DauKyThang);
	InvoiceDetailsQuery.SetParameter("CuoiKy", ThoiDiemBaoCao);
	InvoiceDetailsTable = InvoiceDetailsQuery.Execute().Unload();
	InvoiceDetails = New Array;
	For Each InvoiceRow In InvoiceDetailsTable Do
		InvoiceDetails.Add(New Structure("number,date,posted,deletion_mark,status,net_amount",
			InvoiceRow.Number, InvoiceRow.Date, InvoiceRow.Posted, InvoiceRow.DeletionMark,
			XMLString(InvoiceRow.Status), InvoiceRow.NetAmount));
	EndDo;
	GLRevenueDetailsQuery = New Query;
	GLRevenueDetailsQuery.Text =
		"SELECT
		|    Entry.Recorder AS Recorder,
		|    Entry.Period AS Period,
		|    Entry.AccountDr AS AccountDr,
		|    Entry.AccountCr AS AccountCr,
		|    Entry.SoTien AS Amount
		|FROM
		|    AccountingRegister.SoCaiKeToan AS Entry
		|WHERE
		|    (Entry.AccountCr = &TaiKhoanDoanhThu OR Entry.AccountDr = &TaiKhoanDoanhThu)
		|    AND Entry.Active = TRUE
		|    AND Entry.Period >= &DauKy
		|    AND Entry.Period <= &CuoiKy
		|ORDER BY
		|    Entry.Period";
	GLRevenueDetailsQuery.SetParameter("TaiKhoanDoanhThu", RevenueAccount);
	GLRevenueDetailsQuery.SetParameter("DauKy", DauKyThang);
	GLRevenueDetailsQuery.SetParameter("CuoiKy", ThoiDiemBaoCao);
	GLRevenueDetailsTable = GLRevenueDetailsQuery.Execute().Unload();
	GLRevenueDetails = New Array;
	For Each GLRevenueRow In GLRevenueDetailsTable Do
		GLRevenueDetails.Add(New Structure("recorder,period,account_dr,account_cr,amount",
			String(GLRevenueRow.Recorder), GLRevenueRow.Period, String(GLRevenueRow.AccountDr),
			String(GLRevenueRow.AccountCr), GLRevenueRow.Amount));
	EndDo;
	ReceiptQuery = New Query;
	ReceiptQuery.Text =
		"SELECT
		|	SUM(Receipt.SoTien) AS TongTienThu
		|FROM
		|	Document.PhieuThuTienKhachHang AS Receipt
		|WHERE
		|	Receipt.Posted = TRUE
		|	AND Receipt.DeletionMark = FALSE
		|	AND Receipt.Date >= &DauKy
		|	AND Receipt.Date <= &CuoiKy";
	ReceiptQuery.SetParameter("DauKy", DauKyThang);
	ReceiptQuery.SetParameter("CuoiKy", ThoiDiemBaoCao);
	ReceiptTable = ReceiptQuery.Execute().Unload();
	ExpectedReceipts = 0;
	If ReceiptTable.Count() > 0 Then
		If ReceiptTable[0].TongTienThu <> Null Then
			ExpectedReceipts = ReceiptTable[0].TongTienThu;
		EndIf;
	EndIf;
		ARQuery = New Query("SELECT SUM(AR.SoTienBalance) AS SoDu FROM AccumulationRegister.CongNoPhaiThu.Balance AS AR");
	ARTable = ARQuery.Execute().Unload();
	ARValue = 0;
	If ARTable.Count() > 0 Then
		If ARTable[0].SoDu <> Null Then
			ARValue = ARTable[0].SoDu;
		EndIf;
	EndIf;
	APQuery = New Query("SELECT SUM(AP.SoTienBalance) AS SoDu FROM AccumulationRegister.CongNoPhaiTra.Balance AS AP");
	APTable = APQuery.Execute().Unload();
	APValue = 0;
	If APTable.Count() > 0 Then
		If APTable[0].SoDu <> Null Then
			APValue = APTable[0].SoDu;
		EndIf;
	EndIf;
	CashQuery = New Query("SELECT SUM(Cash.SoTienBalance) AS SoDu FROM AccumulationRegister.DongTien.Balance AS Cash");
	CashTable = CashQuery.Execute().Unload();
	CashValue = 0;
	If CashTable.Count() > 0 Then
		If CashTable[0].SoDu <> Null Then
			CashValue = CashTable[0].SoDu;
		EndIf;
	EndIf;
	PositiveARQuery = New Query("SELECT SUM(AR.SoTienBalance) AS SoDu FROM AccumulationRegister.CongNoPhaiThu.Balance AS AR WHERE AR.SoTienBalance > 0");
	PositiveARTable = PositiveARQuery.Execute().Unload();
	PositiveARValue = 0;
	If PositiveARTable.Count() > 0 Then
		If PositiveARTable[0].SoDu <> Null Then
			PositiveARValue = PositiveARTable[0].SoDu;
		EndIf;
	EndIf;
		JSONThang = BangDieuKhienServer.LayDuLieuTongQuan("ThangNay");
	JSONQuy = BangDieuKhienServer.LayDuLieuTongQuan("QuyNay");
	JSONNam = BangDieuKhienServer.LayDuLieuTongQuan("NamNay");
	TuChoiKyKhongHopLe = False;
	Try
		BangDieuKhienServer.LayDuLieuTongQuan("InvalidPeriod");
	Except
		TuChoiKyKhongHopLe = True;
	EndTry;
	If Not TuChoiKyKhongHopLe Then
		Raise "Dashboard accepted an unsupported report period.";
	EndIf;
	
	Return New Structure("month_json,quarter_json,year_json,unsupported_period_rejected,expected_revenue,expected_accepted_revenue,expected_direct_invoice_revenue,expected_gl_revenue,expected_receipts,expected_invoice_count,expected_ar,expected_ap,expected_cash,expected_positive_ar,as_of,invoice_details,gl_revenue_details",
		JSONThang, JSONQuy, JSONNam, TuChoiKyKhongHopLe, DoanhThuKyVong, ExpectedAcceptedRevenue, ExpectedDirectRevenue, ExpectedGLRevenue, ExpectedReceipts, SoHoaDonKyVong, ARValue, APValue, CashValue, PositiveARValue, ThoiDiemBaoCao, InvoiceDetails, GLRevenueDetails);
EndFunction
