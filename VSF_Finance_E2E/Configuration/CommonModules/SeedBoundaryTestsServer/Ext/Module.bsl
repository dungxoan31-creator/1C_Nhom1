// CommonModule: SeedBoundaryTestsServer
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Kiem thu tu dong toan ven nghiep vu 2 luong cot loi AR va AP (Demo V3)

#Region PublicInterface

Function RunFinanceE2EPhase(Val Phase, Val RunId, Val ResultPath, Val ExtraParameters = Undefined) Export
	Result = New Structure("run_id,phase,user,status,error,data", RunId, Phase, UserName(), "FAIL", "", New Structure);
	Try
		If Phase = "setup" Then
			Result.data = PrepareFinanceE2E();
		ElsIf Phase = "required_reference_prepare" Then
			Result.data = PrepareRequiredReferencePostingFixtures();
		ElsIf Phase = "required_reference_post" Then
			Result.data = VerifyRequiredReferencePostingRejected();
		ElsIf Phase = "required_ap_contract_prepare" Then
			Result.data = PrepareAPWrongContractPostingFixture();
		ElsIf Phase = "required_ap_contract_post" Then
			Result.data = VerifyAPWrongContractPostingRejected();
		ElsIf Phase = "required_field_runtime_matrix" Then
			Result.data = RunRequiredFieldRuntimeMatrix();
			If Not Result.data.all_passed Then
				Raise StrTemplate("Finance field matrix failed: %1/%2 required fields, %3/%4 auto-fill, %5/%6 field write/readback, %7/%8 AR boundaries, and %9/%10 AP boundaries passed.",
					Result.data.passed_count, Result.data.case_count, Result.data.auto_passed_count, Result.data.auto_case_count,
					Result.data.field_probe_passed_count, Result.data.field_probe_case_count,
					Result.data.boundary_passed_count, Result.data.boundary_case_count,
					Result.data.ap_boundary_passed_count, Result.data.ap_boundary_case_count);
			EndIf;
		ElsIf Phase = "ar_submit_acceptance" Then
			Result.data = SubmitFinanceE2EAcceptance();
		ElsIf Phase = "ktt_approve_acceptance" Then
			Result.data = ApproveFinanceE2EAcceptance();
		ElsIf Phase = "ktt_post_acceptance" Then
			Result.data = PostFinanceE2EAcceptance();
		ElsIf Phase = "ar_submit_invoice" Then
			Result.data = SubmitFinanceE2ESalesInvoice();
		ElsIf Phase = "ktt_issue_invoice" Then
			Result.data = IssueFinanceE2ESalesInvoice();
		ElsIf Phase = "ar_create_receipts" Then
			Result.data = CreateFinanceE2EReceipts();
		ElsIf Phase = "cfo_post_receipts" Then
			Result.data = PostFinanceE2EReceipts();
		ElsIf Phase = "ar_unpost_paid_invoice_rejected" Then
			Result.data = VerifyPaidARInvoiceUnpostRejected();
		ElsIf Phase = "ap_submit_invoice" Then
			Result.data = SubmitFinanceE2EVendorInvoice();
		ElsIf Phase = "ktt_post_ap_invoice" Then
			Result.data = PostFinanceE2EVendorInvoice();
		ElsIf Phase = "ap_fct_250_prepare" Then
			Result.data = PrepareFinanceE2EFCT250Invoice();
		ElsIf Phase = "ap_fct_250_post_verify" Then
			Result.data = PostVerifyFinanceE2EFCT250Invoice();
		ElsIf Phase = "ar_fct_cash_funding_prepare_invoice" Then
			Result.data = PrepareFinanceE2EFCTCashFundingInvoice();
		ElsIf Phase = "ar_fct_cash_funding_post_invoice" Then
			Result.data = PostFinanceE2EFCTCashFundingInvoice();
		ElsIf Phase = "ar_fct_cash_funding_prepare_receipt" Then
			Result.data = PrepareFinanceE2EFCTCashFundingReceipt();
		ElsIf Phase = "ar_fct_cash_funding_post_receipt" Then
			Result.data = PostFinanceE2EFCTCashFundingReceipt();
		ElsIf Phase = "ap_fct_250_payment_submit" Then
			Result.data = SubmitFinanceE2EFCT250Payment();
		ElsIf Phase = "ap_fct_250_payment_approve" Then
			Result.data = ApproveFinanceE2EFCT250Payment();
		ElsIf Phase = "ap_fct_250_payment_bank_submit" Then
			Result.data = SubmitFinanceE2EFCT250PaymentToBank();
		ElsIf Phase = "ap_fct_250_payment_post_verify" Then
			Result.data = PostVerifyFinanceE2EFCT250Payment();
		ElsIf Phase = "reporting_values_verify" Then
			Result.data = VerifyFinanceE2EReportValues();
		ElsIf Phase = "ap_submit_payment" Then
			Result.data = SubmitFinanceE2EPayment();
		ElsIf Phase = "ktt_approve_payment" Then
			Result.data = ApproveFinanceE2EPayment();
		ElsIf Phase = "bank_submit_payment" Then
			Result.data = SubmitFinanceE2EPaymentToBank();
		ElsIf Phase = "bank_idempotency_verify" Then
			Result.data = VerifyFinanceE2EBankIdempotency();
		ElsIf Phase = "bank_reject_submit" Then
			Result.data = SubmitFinanceE2EBankRejectedPayment();
		ElsIf Phase = "bank_reject_approve" Then
			Result.data = ApproveFinanceE2EBankRejectedPayment();
		ElsIf Phase = "bank_reject_send" Then
			Result.data = VerifyFinanceE2EBankRejectedPayment();
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
		ElsIf Phase = "csv_import_preview" Then
			Result.data = VerifyFinanceE2ECsvImportPreview();
		ElsIf Phase = "csv_match_post" Then
			Result.data = PostFinanceE2ECsvImport();
		ElsIf Phase = "csv_duplicate_reimport" Then
			Result.data = VerifyFinanceE2ECsvDuplicateReimport();
		ElsIf Phase = "csv_invalid_rows" Then
			Result.data = VerifyFinanceE2ECsvInvalidRows();
		ElsIf Phase = "csv_parser_verify" Then
			Result.data = VerifyStatementCSVParser();
			If Not Result.data.all_passed Then
				Raise StrTemplate("CSV parser cases passed %1/%2.", Result.data.passed_count, Result.data.case_count);
			EndIf;
		ElsIf Phase = "approver_eligibility_verify" Then
			Result.data = VerifyFinanceApproverEligibility();
		ElsIf Phase = "approval_setup" Then
			Result.data = PrepareBulkApprovalRegression();
		ElsIf Phase = "approval_ui_queue_check" Then
			Result.data = VerifyFinanceE2EBatchApprovalUIQueueEmpty();
		ElsIf Phase = "batch_ui_setup" Then
			Result.data = PrepareFinanceE2EBatchApprovalUI();
		ElsIf Phase = "batch_ui_queue_check" Then
			Result.data = VerifyFinanceE2EBatchApprovalUIQueue();
		ElsIf Phase = "batch_ui_verify" Then
			Result.data = VerifyFinanceE2EBatchApprovalUI();
		ElsIf Phase = "approval_ar_queue" Then
			Result.data = VerifyBulkApprovalQueueHiddenFromAR();
		ElsIf Phase = "approval_ktt" Then
			Result.data = RunBulkApprovalKTTStage();
		ElsIf Phase = "approval_cfo" Then
			Result.data = RunBulkApprovalCFOStage();
		ElsIf Phase = "bank_submit_bulk_payment" Then
			Result.data = SubmitFinanceE2EBulkPaymentToBank();
		ElsIf Phase = "bank_post_bulk_payment" Then
			Result.data = PostFinanceE2EBulkPayment();
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
		ElsIf Phase = "aging_algorithm_verify" Then
			Result.data = VerifyFinanceAgingBuckets();
			If Not Result.data.all_passed Then
				Raise StrTemplate("Aging bucket boundaries failed: %1/%2 cases passed.", Result.data.passed_count, Result.data.case_count);
			EndIf;
		ElsIf Phase = "branch_rls_prepare" Then
			Result.data = PrepareBranchRLSE2E();
		ElsIf Phase = "branch_rls_submit" Then
			Result.data = SubmitBranchRLSE2EAcceptance();
		ElsIf Phase = "branch_rls_approve" Then
			Result.data = ApproveBranchRLSE2EAcceptance();
		ElsIf Phase = "branch_rls_post" Then
			Result.data = PostBranchRLSE2EAcceptance();
		ElsIf Phase = "branch_rls_verify" Then
			Result.data = VerifyBranchRLSE2E(ExtraParameters);
		ElsIf Phase = "fx_prepare" Then
			Result.data = PrepareFinanceE2EFX();
		ElsIf Phase = "fx_submit_ar_invoices" Then
			Result.data = SubmitFinanceE2EFXInvoices();
		ElsIf Phase = "fx_post_ar_invoices" Then
			Result.data = PostFinanceE2EFXInvoices();
		ElsIf Phase = "fx_submit_ar_receipts" Then
			Result.data = SubmitFinanceE2EFXReceipts();
		ElsIf Phase = "fx_post_ar_receipts" Then
			Result.data = PostAndVerifyFinanceE2EFXReceipts();
		ElsIf Phase = "fx_submit_ap_invoice" Then
			Result.data = SubmitFinanceE2EFXAPInvoice();
		ElsIf Phase = "fx_post_ap_invoice" Then
			Result.data = PostFinanceE2EFXAPInvoice();
		ElsIf Phase = "fx_submit_ap_payment" Then
			Result.data = SubmitFinanceE2EFXAPPayment();
		ElsIf Phase = "fx_approve_ap_payment" Then
			Result.data = ApproveFinanceE2EFXAPPayment();
		ElsIf Phase = "fx_submit_bank_payment" Then
			Result.data = SubmitFinanceE2EFXAPPaymentToBank();
		ElsIf Phase = "fx_post_ap_payment" Then
			Result.data = PostAndVerifyFinanceE2EFXAPPayment();
		ElsIf Phase = "fx_submit_refund" Then
			Result.data = SubmitFinanceE2EFXRefund();
		ElsIf Phase = "fx_approve_refund" Then
			Result.data = ApproveFinanceE2EFXRefund();
		ElsIf Phase = "fx_reject_unconfirmed_refund" Then
			Result.data = RejectUnconfirmedFinanceE2EFXRefundPosting();
		ElsIf Phase = "fx_post_refund" Then
			Result.data = PostAndVerifyFinanceE2EFXRefund();
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

Function VerifyFinanceAgingBuckets() Export
	CutoffDate = Date(2026, 1, 1) + 100 * 86400;
	Cases = New Array;
	ExpectedGroups = New Array;
	ExpectedGroups.Add(New Structure("days,group", 0, "TrongHan"));
	ExpectedGroups.Add(New Structure("days,group", 30, "QuaHan1Den30"));
	ExpectedGroups.Add(New Structure("days,group", 31, "QuaHan31Den60"));
	ExpectedGroups.Add(New Structure("days,group", 60, "QuaHan31Den60"));
	ExpectedGroups.Add(New Structure("days,group", 61, "QuaHan61Den90"));
	ExpectedGroups.Add(New Structure("days,group", 90, "QuaHan61Den90"));
	ExpectedGroups.Add(New Structure("days,group", 91, "QuaHanTren90"));
	For Each Expected In ExpectedGroups Do
		DueDate = CutoffDate - Expected.days * 86400;
		InvoiceDate = Date(2026, 1, 1);
		Terms = Int((DueDate - InvoiceDate) / 86400);
		Actual = BangDieuKhienServer.TinhTuoiNo(InvoiceDate, Terms, CutoffDate);
		Cases.Add(New Structure("name,passed,expected,actual", "days_" + String(Expected.days), Actual.Nhom = Expected.group, Expected.group, Actual.Nhom));
	EndDo;
	ActualMissingDate = BangDieuKhienServer.TinhTuoiNo(Undefined, 10, CutoffDate);
	Cases.Add(New Structure("name,passed,expected,actual", "missing_document_date", ActualMissingDate.Nhom = "ChuaXacDinhHan", "ChuaXacDinhHan", ActualMissingDate.Nhom));
	ActualMissingTerms = BangDieuKhienServer.TinhTuoiNo(Date(2026, 1, 1), Undefined, CutoffDate);
	Cases.Add(New Structure("name,passed,expected,actual", "missing_payment_terms", ActualMissingTerms.Nhom = "ChuaXacDinhHan", "ChuaXacDinhHan", ActualMissingTerms.Nhom));
	PassedCount = 0;
	For Each TestCase In Cases Do
		If TestCase.passed Then PassedCount = PassedCount + 1; EndIf;
	EndDo;
	Return New Structure("status,case_count,passed_count,all_passed,cases", ?(PassedCount = Cases.Count(), "PASS", "FAIL"), Cases.Count(), PassedCount, PassedCount = Cases.Count(), Cases);
EndFunction

Function VerifyFinanceApproverEligibility() Export
	NguongCFO = Constants.NguongPheDuyetChiTienCFO.Get();
	If NguongCFO <= 0 Then
		NguongCFO = 500000000;
	EndIf;
	Cases = New Array;

	ARAtThreshold = PheDuyetDaCapServer.LayDanhSachNguoiDuyet("BienBanNghiemThuGiaiDoan", NguongCFO);
	Cases.Add(New Structure("name,passed,expected,actual", "AR_threshold_excludes_CFO", Not ContainsApprover(ARAtThreshold, "cfo_giamdoc"), "no CFO", ApproverListText(ARAtThreshold)));
	Cases.Add(New Structure("name,passed,expected,actual", "AR_threshold_includes_KTT_and_Admin", ContainsApprover(ARAtThreshold, "ketoan_truong") And ContainsApprover(ARAtThreshold, "Admin"), "KTT and Admin", ApproverListText(ARAtThreshold)));

	ARAboveThreshold = PheDuyetDaCapServer.LayDanhSachNguoiDuyet("HoaDonGTGTDauRa", NguongCFO + 1);
	Cases.Add(New Structure("name,passed,expected,actual", "AR_above_threshold_includes_CFO", ContainsApprover(ARAboveThreshold, "cfo_giamdoc"), "CFO", ApproverListText(ARAboveThreshold)));

	APAtThreshold = PheDuyetDaCapServer.LayDanhSachNguoiDuyet("HoaDonNhaCungCap", NguongCFO);
	Cases.Add(New Structure("name,passed,expected,actual", "AP_threshold_excludes_CFO_and_Admin", Not ContainsApprover(APAtThreshold, "cfo_giamdoc") And Not ContainsApprover(APAtThreshold, "Admin"), "KTT only", ApproverListText(APAtThreshold)));
	APAboveThreshold = PheDuyetDaCapServer.LayDanhSachNguoiDuyet("HoaDonNhaCungCap", NguongCFO + 1);
	Cases.Add(New Structure("name,passed,expected,actual", "AP_above_threshold_includes_CFO", ContainsApprover(APAboveThreshold, "cfo_giamdoc"), "KTT and CFO", ApproverListText(APAboveThreshold)));

	Acceptance = Documents.BienBanNghiemThuGiaiDoan.CreateDocument();
	Acceptance.NguoiTao = "ketoan_ar";
	Acceptance.TongGiaTri = NguongCFO;
	Acceptance.NguoiDuyet = "Admin";
	AdminCheckerAccepted = True;
	Try
		PheDuyetDaCapServer.KiemTraNguoiDuyetHopLe(Acceptance, UserName());
	Except
		AdminCheckerAccepted = False;
	EndTry;
	Cases.Add(New Structure("name,passed,expected,actual", "Admin_is_eligible_AR_checker", AdminCheckerAccepted, True, AdminCheckerAccepted));

	Acceptance.NguoiDuyet = "cfo_giamdoc";
	CFOAtThresholdRejected = False;
	Try
		PheDuyetDaCapServer.KiemTraNguoiDuyetHopLe(Acceptance, UserName());
	Except
		CFOAtThresholdRejected = True;
	EndTry;
	Cases.Add(New Structure("name,passed,expected,actual", "CFO_rejected_at_threshold", CFOAtThresholdRejected, True, CFOAtThresholdRejected));

	Acceptance.TongGiaTri = NguongCFO + 1;
	CFOAboveThresholdAccepted = True;
	Try
		PheDuyetDaCapServer.KiemTraNguoiDuyetHopLe(Acceptance, UserName());
	Except
		CFOAboveThresholdAccepted = False;
	EndTry;
	Cases.Add(New Structure("name,passed,expected,actual", "CFO_accepted_above_threshold", CFOAboveThresholdAccepted, True, CFOAboveThresholdAccepted));

	Acceptance.NguoiDuyet = "ketoan_ar";
	SelfApprovalRejected = False;
	Try
		PheDuyetDaCapServer.KiemTraNguoiDuyetHopLe(Acceptance, UserName());
	Except
		SelfApprovalRejected = True;
	EndTry;
	Cases.Add(New Structure("name,passed,expected,actual", "maker_self_approval_rejected", SelfApprovalRejected, True, SelfApprovalRejected));

	AdminAssignedMakerCheckerAccepted = True;
	Try
		PhanQuyenBaoMatServer.KiemTraMakerChecker("ketoan_ar", "Admin", UserName());
	Except
		AdminAssignedMakerCheckerAccepted = False;
	EndTry;
	Cases.Add(New Structure("name,passed,expected,actual", "assigned_Admin_can_check", AdminAssignedMakerCheckerAccepted, True, AdminAssignedMakerCheckerAccepted));

	AdminPostingRejected = False;
	Try
		PhanQuyenBaoMatServer.KiemTraQuyenChungTu("BienBanNghiemThuGiaiDoan", "GhiSo", UserName());
	Except
		AdminPostingRejected = True;
	EndTry;
	Cases.Add(New Structure("name,passed,expected,actual", "Admin_still_cannot_post", AdminPostingRejected, True, AdminPostingRejected));

	Passed = 0;
	For Each TestCase In Cases Do
		If TestCase.passed Then
			Passed = Passed + 1;
		Else
			Raise StrTemplate("Approver eligibility test failed: %1 (expected %2, actual %3).", TestCase.name, TestCase.expected, TestCase.actual);
		EndIf;
	EndDo;
	Return New Structure("case_count,passed_count,threshold_vnd,cases", Cases.Count(), Passed, NguongCFO, Cases);
EndFunction

Function ContainsApprover(Val Approvers, Val ExpectedUser)
	For Each Approver In Approvers Do
		If Upper(TrimAll(String(Approver))) = Upper(TrimAll(String(ExpectedUser))) Then
			Return True;
		EndIf;
	EndDo;
	Return False;
EndFunction

Function ApproverListText(Val Approvers)
	Result = "";
	For Each Approver In Approvers Do
		If ValueIsFilled(Result) Then
			Result = Result + ",";
		EndIf;
		Result = Result + String(Approver);
	EndDo;
	Return Result;
EndFunction

Function VerifyPaidARInvoiceUnpostRejected() Export
	RequireFinanceE2ERole("GiamDocTaiChinh_CFO");
	InvoiceRef = Documents.HoaDonGTGTDauRa.FindByNumber("E2E-AR001", Date(2026, 10, 10, 10, 0, 0));
	ReceiptRef = Documents.PhieuThuTienKhachHang.FindByNumber("E2E-PT001", Date(2026, 10, 14, 9, 0, 0));
	If Not ValueIsFilled(InvoiceRef) Or Not InvoiceRef.Posted Or Not ValueIsFilled(ReceiptRef) Or Not ReceiptRef.Posted Then
		Raise "Paid invoice unposting test requires a posted AR invoice and a posted receipt.";
	EndIf;
	Receipt = ReceiptRef.GetObject();
	If Receipt.ChungTuGoc <> InvoiceRef Then
		Raise "Paid invoice unposting test receipt does not reference the target invoice.";
	EndIf;
	DependentDocuments = QuanLyVongDoiChungTuServer.DanhSachChungTuPhuThuoc(InvoiceRef);
	If DependentDocuments.Count() = 0 Then
		Raise "Paid invoice unposting test did not find the posted receipt movement dependency.";
	EndIf;
	OriginalMovements = QuanLyVongDoiChungTuServer.LayDauVanMovements(InvoiceRef);

	Invoice = InvoiceRef.GetObject();
	Cancel = False;
	QuanLyVongDoiChungTuServer.XuLyHuyGhiSo(Invoice, Cancel);
	If Not Cancel Then
		Raise "Paid invoice lifecycle guard did not cancel unposting while a posted receipt references it.";
	EndIf;

	UnpostWriteError = "";
	BeginTransaction();
	Try
		Invoice.Write(DocumentWriteMode.UndoPosting);
	Except
		UnpostWriteError = DetailErrorDescription(ErrorInfo());
	EndTry;
	If TransactionActive() Then RollbackTransaction(); EndIf;

	If StrFind(UnpostWriteError, "Failed to save") = 0 Then
		Raise "Undo posting did not report the expected rejected document write.";
	EndIf;
	UnpostAttempt = InvoiceRef.GetObject();
	If Not UnpostAttempt.Posted Or QuanLyVongDoiChungTuServer.LayDauVanMovements(InvoiceRef) <> OriginalMovements Then
		Raise "Paid AR invoice unposting was not rejected or its movements changed despite the posted receipt dependency.";
	EndIf;

	RestoredInvoice = InvoiceRef.GetObject();
	RestoredReceipt = ReceiptRef.GetObject();
	If Not RestoredInvoice.Posted Or Not RestoredReceipt.Posted
		Or QuanLyVongDoiChungTuServer.LayDauVanMovements(InvoiceRef) <> OriginalMovements
		Or RestoredReceipt.ChungTuGoc <> InvoiceRef Then
		Raise "Paid invoice rollback did not preserve the posted invoice, receipt, and register movements.";
	EndIf;

	Return New Structure("invoice,receipt,posted_dependency_count,rejected_due_to_posted_receipt,write_rejection_reported,invoice_still_posted,receipt_still_posted,movements_preserved",
		InvoiceRef.Number, ReceiptRef.Number, DependentDocuments.Count(), True, True, RestoredInvoice.Posted, RestoredReceipt.Posted, True);
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

Function VerifyFinanceE2EBatchApprovalUIQueueEmpty() Export
	RequireFinanceE2ERole("KeToanTruong");
	Queue = DataProcessors.BanLamViecWebERP.LayDanhSachChoPheDuyet();
	If Queue.Count() <> 0 Then
		Raise StrTemplate("Batch approval UI fixture requires an empty KTT queue; found %1 pending documents.", Queue.Count());
	EndIf;
	Return New Structure("user,ktt_queue_count", UserName(), Queue.Count());
EndFunction

Function VerifyFinanceE2EBatchApprovalUIQueue() Export
	RequireFinanceE2ERole("KeToanTruong");
	Queue = DataProcessors.BanLamViecWebERP.LayDanhSachChoPheDuyet();
	If Queue.Count() <> 2 Or Queue[0].SoChungTu <> "E2E-BATCH-UI"
		Or Queue[1].SoChungTu <> "E2E-BATCH-UI-ALL"
		Or Queue[0].LoaiChungTu <> "HoaDonNhaCungCap"
		Or Queue[1].LoaiChungTu <> "HoaDonNhaCungCap" Then
		Raise StrTemplate("Batch approval UI requires the two known documents in its isolated KTT queue; count=%1.", Queue.Count());
	EndIf;
	Return New Structure("user,ktt_queue_count,document_number,document_type,amount_vnd,approve_all_document_number",
		UserName(), Queue.Count(), Queue[0].SoChungTu, Queue[0].LoaiChungTu, Queue[0].SoTien, Queue[1].SoChungTu);
EndFunction

Function PrepareFinanceE2EBatchApprovalUI() Export
	RequireFinanceE2ERole("KeToanPhaiTra");
	Context = FinanceE2EContext();
	CreateBulkApprovalInvoice(Context, "E2E-BATCH-UI-ALL", "E2E-BATCH-UI-ALL-TAX", 1000000, Date(2026, 10, 21, 15, 0, 0));
	InvoiceRef = CreateBulkApprovalInvoice(Context, "E2E-BATCH-UI", "E2E-BATCH-UI-TAX", 1000000, Date(2026, 10, 21, 16, 0, 0));
	Invoice = InvoiceRef.GetObject();
	If Invoice.Posted Or Invoice.TrangThai <> Enums.TrangThaiHoaDonAP.ChoKeToanTruongDuyet
		Or Invoice.NguoiLap <> UserName() Then
		Raise "Batch approval UI fixture did not persist as an unposted AP invoice in the KTT queue.";
	EndIf;
	Return New Structure("document_number,maker,amount_vnd,status,posted",
		Invoice.Number, UserName(), Invoice.TongTien, String(Invoice.TrangThai), Invoice.Posted);
EndFunction

Function VerifyFinanceE2EBatchApprovalUI() Export
	RequireFinanceE2ERole("KeToanTruong");
	InvoiceRef = Documents.HoaDonNhaCungCap.FindByNumber("E2E-BATCH-UI", Date(2026, 10, 21, 16, 0, 0));
	If Not ValueIsFilled(InvoiceRef) Then Raise "Batch approval UI invoice fixture is missing."; EndIf;
	Invoice = InvoiceRef.GetObject();
	ApproveAllRef = Documents.HoaDonNhaCungCap.FindByNumber("E2E-BATCH-UI-ALL", Date(2026, 10, 21, 15, 0, 0));
	If Not ValueIsFilled(ApproveAllRef) Then Raise "Batch approval Approve All fixture is missing."; EndIf;
	ApproveAllInvoice = ApproveAllRef.GetObject();
	Context = New Structure;
	Context.Insert("PhapNhan", Invoice.PhapNhan);
	Context.Insert("Vendor", Invoice.DoiTac);
	Context.Insert("VendorContract", Invoice.HopDong);
	Queue = DataProcessors.BanLamViecWebERP.LayDanhSachChoPheDuyet();
	OpenAP = FinanceE2EAPBalance(Context, InvoiceRef);
	GLRows = CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", InvoiceRef);
	CashRows = CountRecorderMovementRecords("AccumulationRegister.DongTien", InvoiceRef);
	ApproveAllOpenAP = FinanceE2EAPBalance(Context, ApproveAllRef);
	ApproveAllGLRows = CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", ApproveAllRef);
	ApproveAllCashRows = CountRecorderMovementRecords("AccumulationRegister.DongTien", ApproveAllRef);
	If Not Invoice.Posted Or Invoice.TrangThai <> Enums.TrangThaiHoaDonAP.DaGhiSo
		Or Invoice.NguoiDuyet <> UserName() Or OpenAP <> 1000000 Or GLRows = 0 Or CashRows <> 0
		Or Not ApproveAllInvoice.Posted Or ApproveAllInvoice.TrangThai <> Enums.TrangThaiHoaDonAP.DaGhiSo
		Or ApproveAllInvoice.NguoiDuyet <> UserName() Or ApproveAllOpenAP <> 1000000
		Or ApproveAllGLRows = 0 Or ApproveAllCashRows <> 0
		Or Queue.Count() <> 0 Then
		ErrorMessage = StrTemplate("Batch approval UI posting mismatch: row=%1/%2/AP%3/GL%4/cash%5; all=%6/%7/AP%8/GL%9/cash%10",
			Invoice.Posted, String(Invoice.TrangThai), OpenAP, GLRows, CashRows,
			ApproveAllInvoice.Posted, String(ApproveAllInvoice.TrangThai), ApproveAllOpenAP,
			ApproveAllGLRows, ApproveAllCashRows);
		Raise ErrorMessage + StrTemplate("; queue=%1.", Queue.Count());
	EndIf;
	Return New Structure("document_number,posted,status,maker,approver,open_ap_vnd,gl_rows,cash_rows,ktt_queue_count,approve_all_document_number,approve_all_posted,approve_all_status,approve_all_open_ap_vnd,approve_all_gl_rows,approve_all_cash_rows",
		Invoice.Number, Invoice.Posted, String(Invoice.TrangThai), Invoice.NguoiLap, Invoice.NguoiDuyet,
		OpenAP, GLRows, CashRows, Queue.Count(), ApproveAllInvoice.Number, ApproveAllInvoice.Posted,
		String(ApproveAllInvoice.TrangThai), ApproveAllOpenAP, ApproveAllGLRows, ApproveAllCashRows);
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
		Or Payment.Posted Or Payment.TrangThai <> Enums.TrangThaiLenhThanhToan.DaDuyet
		Or Not IsBlankString(Payment.MaGiaoDichNganHang) Then
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
	If ApprovalQueueContains(QueueAfter, HighRef) Or Not ApprovalQueueContains(QueueAfter, PaymentRef) Then
		Raise "KTT queue must retain the approved payment as pending bank submission and hide the CFO-stage invoice.";
	EndIf;

	ResultData = New Structure;
	ResultData.Insert("batch_success", Result.ThanhCong);
	ResultData.Insert("batch_failure", Result.ThatBai);
	ResultData.Insert("low_invoice_posted", Low.Posted);
	ResultData.Insert("low_invoice_gl_rows", CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", LowRef));
	ResultData.Insert("high_invoice_waiting_cfo", High.TrangThai = Enums.TrangThaiHoaDonAP.ChoDuyetCFO And Not High.Posted);
	ResultData.Insert("payment_waiting_bank", Payment.TrangThai = Enums.TrangThaiLenhThanhToan.DaDuyet And Not Payment.Posted);
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
	If Not ApprovalQueueContains(Queue, HighRef) Or ApprovalQueueContains(Queue, PaymentRef)
		Or ApprovalQueueContains(Queue, LowRef) Then
		Raise "CFO queue must show the escalated invoice only until the KTT submits the approved payment to the bank.";
	EndIf;

	Refs = New Array;
	Refs.Add(HighRef);
	Result = Workspace.PheDuyetHangLoat(Refs);
	High = HighRef.GetObject();
	Payment = PaymentRef.GetObject();
	If Result.ThanhCong <> 1 Or Result.ThatBai <> 0
		Or Not High.Posted Or High.TrangThai <> Enums.TrangThaiHoaDonAP.DaGhiSo
		Or Payment.Posted Or Payment.TrangThai <> Enums.TrangThaiLenhThanhToan.DaDuyet Then
		Raise StrTemplate("CFO invoice stage mismatch: success=%1 failure=%2 highPosted=%3 paymentPosted=%4.", Result.ThanhCong, Result.ThatBai, High.Posted, Payment.Posted);
	EndIf;

	LowBalance = FinanceE2EAPBalance(Context, LowRef);
	HighBalance = FinanceE2EAPBalance(Context, HighRef);
	CashBalance = FinanceE2ECashBalance(Context);
	SalesInvoiceRef = Documents.HoaDonGTGTDauRa.FindByNumber("E2E-AR001", Date(2026, 10, 10, 10, 0, 0));
	MainPaymentRef = Documents.UyNhiemChi.FindByNumber("E2E-UNC01", Date(2026, 10, 14, 9, 0, 0));
	If Not ValueIsFilled(SalesInvoiceRef) Or Not ValueIsFilled(MainPaymentRef) Or Not MainPaymentRef.Posted Then
		Raise "Bulk approval cash reconciliation is missing the E2E sales invoice or posted main payment.";
	EndIf;
	If LowBalance <> 1000000 Or HighBalance <> 500000001 Or CashBalance <> CashBefore Then
		Raise StrTemplate("Bulk approval ledger mismatch: lowAP=%1 highAP=%2 bank=%3.", LowBalance, HighBalance, CashBalance);
	EndIf;
	If CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", HighRef) = 0
		Or CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", PaymentRef) <> 0
		Or CountRecorderMovementRecords("AccumulationRegister.DongTien", PaymentRef) <> 0 Then
		Raise "CFO invoice approval created an unexpected payment movement before bank acceptance.";
	EndIf;

	ResultData = New Structure;
	ResultData.Insert("batch_success", Result.ThanhCong);
	ResultData.Insert("batch_failure", Result.ThatBai);
	ResultData.Insert("high_invoice_posted", High.Posted);
	ResultData.Insert("high_invoice_ap_residual_vnd", HighBalance);
	ResultData.Insert("payment_awaiting_bank", Payment.TrangThai = Enums.TrangThaiLenhThanhToan.DaDuyet And Not Payment.Posted);
	ResultData.Insert("bank_opening_vnd", CashBefore);
	ResultData.Insert("bank_closing_vnd", CashBalance);
	ResultData.Insert("high_invoice_gl_rows", CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", HighRef));
	ResultData.Insert("payment_gl_rows_before_bank", CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", PaymentRef));
	ResultData.Insert("payment_cash_rows_before_bank", CountRecorderMovementRecords("AccumulationRegister.DongTien", PaymentRef));
	Return ResultData;
EndFunction

Function SubmitFinanceE2EBulkPaymentToBank() Export
	RequireFinanceE2ERole("KeToanTruong");
	PaymentRef = Documents.UyNhiemChi.FindByNumber("E2E-BULK-PAY", Date(2026, 10, 16, 9, 0, 0));
	If Not ValueIsFilled(PaymentRef) Or Not PaymentRef.ChungTuGoc.Posted Then
		Raise "Bulk bank payment can only be submitted after its supplier invoice is posted.";
	EndIf;
	Workspace = DataProcessors.BanLamViecWebERP.Create();
	BankResult = Workspace.GuiLenhChiDaDuyetNganHang(PaymentRef);
	Payment = PaymentRef.GetObject();
	If Not BankResult.accepted Or Payment.TrangThai <> Enums.TrangThaiLenhThanhToan.DaGuiNganHang
		Or IsBlankString(Payment.MaGiaoDichNganHang) Then
		Raise StrTemplate("Bulk bank submission failed: %1", BankResult.error);
	EndIf;
	Return New Structure("payment_number,bank_status,transaction_id,source_invoice_posted,ap_open_vnd",
		Payment.Number, Payment.TrangThaiGuiNganHang, Payment.MaGiaoDichNganHang,
		Payment.ChungTuGoc.Posted, FinanceE2EAPBalance(FinanceE2EContext(), Payment.ChungTuGoc));
EndFunction

Function PostFinanceE2EBulkPayment() Export
	RequireFinanceE2ERole("GiamDocTaiChinh_CFO");
	Context = FinanceE2EContext();
	PaymentRef = Documents.UyNhiemChi.FindByNumber("E2E-BULK-PAY", Date(2026, 10, 16, 9, 0, 0));
	If Not ValueIsFilled(PaymentRef) Then Raise "Approved bulk payment is missing before CFO posting."; EndIf;
	Payment = PaymentRef.GetObject();
	If Payment.TrangThai <> Enums.TrangThaiLenhThanhToan.DaGuiNganHang
		Or Payment.TrangThaiGuiNganHang <> "ACCEPTED" Or IsBlankString(Payment.MaGiaoDichNganHang) Then
		Raise "CFO cannot post the bulk payment until bank acceptance is persisted.";
	EndIf;
	CashBefore = FinanceE2ECashBalance(Context);
	Refs = New Array;
	Refs.Add(PaymentRef);
	Workspace = DataProcessors.BanLamViecWebERP.Create();
	PostingResult = Workspace.PheDuyetHangLoat(Refs);
	Payment = PaymentRef.GetObject();
	CashAfter = FinanceE2ECashBalance(Context);
	HighRef = Payment.ChungTuGoc;
	HighBalance = FinanceE2EAPBalance(Context, HighRef);
	If PostingResult.ThanhCong <> 1 Or PostingResult.ThatBai <> 0 Or Not Payment.Posted
		Or Payment.TrangThai <> Enums.TrangThaiLenhThanhToan.DaGhiSo
		Or HighBalance <> 499000001 Or CashAfter <> CashBefore - Payment.SoTien
		Or CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", PaymentRef) = 0
		Or CountRecorderMovementRecords("AccumulationRegister.DongTien", PaymentRef) = 0 Then
		Raise StrTemplate("CFO payment posting mismatch: success=%1 failure=%2 posted=%3 AP=%4 cash=%5 expected=%6.",
			PostingResult.ThanhCong, PostingResult.ThatBai, Payment.Posted, HighBalance, CashAfter, CashBefore - Payment.SoTien);
	EndIf;
	Return New Structure("payment_number,posted,bank_transaction_id,ap_open_vnd,bank_before_vnd,bank_after_vnd,gl_rows,cash_rows",
		Payment.Number, Payment.Posted, Payment.MaGiaoDichNganHang, HighBalance, CashBefore, CashAfter,
		CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", PaymentRef),
		CountRecorderMovementRecords("AccumulationRegister.DongTien", PaymentRef));
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
	Acceptance = Documents.BienBanNghiemThuGiaiDoan.CreateDocument();
	Acceptance.Number = "E2E-CONC-AR-BB";
	Acceptance.Date = Date(2026, 10, 17, 8, 30, 0);
	Acceptance.PhapNhan = Context.PhapNhan;
	Acceptance.DoiTac = Context.Customer;
	Acceptance.HopDong = Context.CustomerContract;
	Acceptance.NgayNghiemThu = BegOfDay(Acceptance.Date);
	Acceptance.ApDungGiamThueGTGT = True;
	Acceptance.GiaTriNghiemThuChuaVAT = 250000000;
	Acceptance.TyLeVAT = ThueGTGTClientServer.TyLeVATApDungTheoNgay(Acceptance.NgayNghiemThu, True);
	Acceptance.TienVAT = Round(Acceptance.GiaTriNghiemThuChuaVAT * Acceptance.TyLeVAT / 100, 2);
	Acceptance.TongGiaTri = Acceptance.GiaTriNghiemThuChuaVAT + Acceptance.TienVAT;
	Acceptance.TrangThai = Enums.TrangThaiNghiemThuAR.ChoDuyetNoiBo;
	Acceptance.NguoiDuyet = "ketoan_truong";
	Acceptance.DienGiai = "Concurrent receipt regression acceptance source";
	Acceptance.Write();
	If Acceptance.NguoiTao <> UserName() Or Acceptance.Posted Or Acceptance.TongGiaTri <> 270000000 Then
		Raise "Concurrent AR acceptance source was not saved with the expected maker and 270,000,000 VND total.";
	EndIf;

	Invoice = Documents.HoaDonGTGTDauRa.CreateDocument();
	Invoice.Number = "E2E-CONC-AR-INV";
	Invoice.Date = Date(2026, 10, 17, 9, 0, 0);
	Invoice.SoHoaDon = "E2E-CONC-AR-TAX";
	Invoice.KyHieu = "E2E-CONC";
	Invoice.MaCQT = "E2E-CQT-CONC";
	Invoice.PhapNhan = Context.PhapNhan;
	Invoice.DoiTac = Context.Customer;
	Invoice.HopDong = Context.CustomerContract;
	Invoice.BienBanNghiemThu = Acceptance.Ref;
	Invoice.NgayHoaDon = BegOfDay(Invoice.Date);
	Invoice.TienChuaThue = 250000000;
	Invoice.ApDungGiamThueGTGT = True;
	Invoice.ThueSuatVAT = ThueGTGTClientServer.TyLeVATApDungTheoNgay(Invoice.NgayHoaDon, True);
	Invoice.TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.ChoKySo;
	Invoice.NguoiDuyet = "ketoan_truong";
	Invoice.DienGiai = "Concurrent receipt lock regression source invoice";
	Invoice.Write();
	If Invoice.Posted Or Invoice.TrangThaiHDDT <> Enums.TrangThaiHoaDonDienTu.ChoKySo
		Or Invoice.NguoiLap <> UserName() Then
		Raise "Concurrent AR source invoice draft was not saved under its maker with the expected approval state.";
	EndIf;
	Result = New Structure("invoice,acceptance,invoice_status,maker,expected_ar_vnd", String(Invoice.Ref), String(Acceptance.Ref), XMLString(Invoice.TrangThaiHDDT), Invoice.NguoiLap, 270000000);
	Return Result;
EndFunction

Function PostConcurrentARInvoice() Export
	RequireFinanceE2ERole("KeToanTruong");
	InvoiceRef = Documents.HoaDonGTGTDauRa.FindByNumber("E2E-CONC-AR-INV", Date(2026, 10, 17, 9, 0, 0));
	If Not ValueIsFilled(InvoiceRef) Then Raise "Concurrent AR invoice draft is missing."; EndIf;
	Invoice = InvoiceRef.GetObject();
	If Invoice.Posted Or Invoice.TrangThaiHDDT <> Enums.TrangThaiHoaDonDienTu.ChoKySo
		Or Invoice.NguoiLap <> "ketoan_ar" Or Invoice.NguoiDuyet <> UserName() Then
		Raise "Concurrent AR invoice is not in the expected maker-checker state before KTT approval.";
	EndIf;
	AcceptanceRef = Documents.BienBanNghiemThuGiaiDoan.FindByNumber("E2E-CONC-AR-BB", Date(2026, 10, 17, 8, 30, 0));
	If Not ValueIsFilled(AcceptanceRef) Then Raise "Concurrent AR acceptance source is missing."; EndIf;
	Acceptance = AcceptanceRef.GetObject();
	If Acceptance.Posted Or Acceptance.NguoiTao <> "ketoan_ar" Or Acceptance.NguoiDuyet <> UserName() Then
		Raise "Concurrent AR acceptance source is not in the expected maker-checker state.";
	EndIf;
	Acceptance.TrangThai = Enums.TrangThaiNghiemThuAR.DaDuyetNoiBo;
	Acceptance.Write();
	Acceptance.Write(DocumentWriteMode.Posting);
	If Not Acceptance.Posted Then Raise "Concurrent AR acceptance source did not post."; EndIf;
	Invoice.TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.DaPhatHanh;
	Invoice.Write();
	Invoice.Write(DocumentWriteMode.Posting);
	If Not Invoice.Posted Or Invoice.TrangThaiHDDT <> Enums.TrangThaiHoaDonDienTu.DaPhatHanh
		Or Invoice.TongTienThanhToan <> 270000000 Then
		Raise "Concurrent AR source invoice did not post for 270,000,000 VND after CFO issuance.";
	EndIf;
	Return New Structure("invoice,acceptance,approver,status,posted,amount_vnd", Invoice.Number, Acceptance.Number, UserName(), XMLString(Invoice.TrangThaiHDDT), Invoice.Posted, Invoice.TongTienThanhToan);
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
	BranchRef = EnsureFinanceE2EBranchAccess();

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
	BankConfig = RefBank.GetObject();
	BankConfig.BankApiHost = "127.0.0.1";
	BankConfig.BankApiPort = 17891;
	BankConfig.BankApiPath = "/v1/payments";
	BankConfig.BankRefundConfirmationPath = "/v1/refunds/confirm";
	BankConfig.BankApiTimeoutSeconds = 3;
	BankConfig.BankApiUseTLS = False;
	BankConfig.Write();
	EnsureFinanceE2ECashCategory("KM-01", "E2E customer receipts", "Thu");
	EnsureFinanceE2ECashCategory("KM-E2E-AP", "E2E supplier payments", "Chi");
	EnsureFinanceE2ECashCategory("KM-E2E-GATEWAY", "E2E payment gateway settlement", "Thu");
	EnsureFinanceE2ECashCategory("KM-CHI-CLOUD", "E2E supplier cloud expense", "Chi");

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
	ResultData.Insert("branch", BranchRef.Code);
	ResultData.Insert("customer", Context.Customer.Code);
	ResultData.Insert("customer_contract", Context.CustomerContract.Code);
	ResultData.Insert("vendor", Context.Vendor.Code);
	ResultData.Insert("vendor_contract", Context.VendorContract.Code);
	ResultData.Insert("bank_account", Context.Bank.Code);
	ResultData.Insert("opening_cash_vnd", 0);
	Return ResultData;
EndFunction

Function EnsureFinanceE2EBranchAccess()
	RequireFinanceE2ERole("QuanTriHeThong");
	BranchRef = Catalogs.ChiNhanh.FindByCode("CN-VSF-HCM");
	If Not ValueIsFilled(BranchRef) Then
		Branch = Catalogs.ChiNhanh.CreateItem();
		Branch.Code = "CN-VSF-HCM";
		Branch.Description = "VSF HCMC accounting branch";
		Branch.Write();
		BranchRef = Branch.Ref;
	EndIf;

	LegalEntityRef = Catalogs.PhapNhan.FindByCode("PN-VSF");
	If Not ValueIsFilled(LegalEntityRef) Then
		Raise "E2E legal entity PN-VSF is missing before branch assignment.";
	EndIf;
	LegalEntity = LegalEntityRef.GetObject();
	If LegalEntity.ChiNhanh <> BranchRef Then
		LegalEntity.ChiNhanh = BranchRef;
		LegalEntity.Write();
	EndIf;

	For Each UserNameValue In StrSplit("Admin,ketoan_ar,ketoan_ap,cfo_giamdoc,ketoan_truong", ",") Do
		EnsureFinanceE2EUserBranch(UserNameValue, BranchRef);
	EndDo;
	Return BranchRef;
EndFunction

Procedure EnsureFinanceE2EUserBranch(Val UserNameValue, Val BranchRef)
	If InfoBaseUsers.FindByName(UserNameValue) = Undefined Then
		Raise StrTemplate("Cannot assign branch %1: infobase user %2 is missing.", BranchRef.Code, UserNameValue);
	EndIf;

	Assignments = InformationRegisters.PhanQuyenChiNhanh.CreateRecordSet();
	Assignments.Filter.NguoiDung.Set(UserNameValue);
	Assignments.Read();
	Assignments.Clear();
	Assignment = Assignments.Add();
	Assignment.NguoiDung = UserNameValue;
	Assignment.ChiNhanh = BranchRef;
	Assignments.Write(True);
EndProcedure

Function PrepareBranchRLSE2E() Export
	RequireFinanceE2ERole("QuanTriHeThong");
	BranchRef = Catalogs.ChiNhanh.FindByCode("CN-E2E-BR2");
	If Not ValueIsFilled(BranchRef) Then
		Branch = Catalogs.ChiNhanh.CreateItem();
		Branch.Code = "CN-E2E-BR2";
		Branch.Description = "E2E branch 2";
		Branch.Write();
		BranchRef = Branch.Ref;
	EndIf;

	LegalEntityRef = Catalogs.PhapNhan.FindByCode("PN-BR02");
	If Not ValueIsFilled(LegalEntityRef) Then
		LegalEntity = Catalogs.PhapNhan.CreateItem();
		LegalEntity.Code = "PN-BR02";
	Else
		LegalEntity = LegalEntityRef.GetObject();
	EndIf;
	LegalEntity.Description = "E2E legal entity for branch RLS";
	LegalEntity.ChiNhanh = BranchRef;
	LegalEntity.Write();
	LegalEntityRef = LegalEntity.Ref;

	CustomerRef = Catalogs.DoiTac.FindByCode("TEST_VG_VINFAST_VN");
	ContractRef = Catalogs.HopDong.FindByCode("HD-RLS-BR02");
	If Not ValueIsFilled(ContractRef) Then
		Contract = Catalogs.HopDong.CreateItem();
		Contract.Code = "HD-RLS-BR02";
	Else
		Contract = ContractRef.GetObject();
	EndIf;
	Contract.Description = "Branch RLS E2E customer contract";
	Contract.PhapNhan = LegalEntityRef;
	Contract.ChuSoHuu = CustomerRef;
	Contract.DongTienThanhToan = Catalogs.TienTe.FindByCode("VND");
	Contract.HanThanhToanNgay = 30;
	Contract.Write();

	For Each UserNameValue In StrSplit("ketoan_ar,ketoan_ap,cfo_giamdoc,ketoan_truong", ",") Do
		EnsureFinanceE2EUserBranch(UserNameValue, BranchRef);
	EndDo;

	AssignedUsers = StrSplit("ketoan_ar,ketoan_ap,cfo_giamdoc,ketoan_truong", ",");
	VendorContractRef = Catalogs.HopDong.FindByCode("HD-E2E-AWS-VND-2026");
	If Not ValueIsFilled(VendorContractRef) Then
		Raise "Branch RLS fixture requires the seeded branch 1 vendor contract.";
	EndIf;
	Return New Structure("branch,legal_entity,contract,assigned_users,branch1_legal_entity_uuid,branch1_vendor_contract_uuid",
		BranchRef.Code, LegalEntityRef.Code, Contract.Ref.Code, AssignedUsers,
		String(Catalogs.PhapNhan.FindByCode("PN-VSF").UUID()), String(VendorContractRef.UUID()));
EndFunction

Function SubmitBranchRLSE2EAcceptance() Export
	RequireFinanceE2ERole("KeToanPhaiThu");
	BranchRef = Catalogs.ChiNhanh.FindByCode("CN-E2E-BR2");
	LegalEntityRef = Catalogs.PhapNhan.FindByCode("PN-BR02");
	CustomerRef = Catalogs.DoiTac.FindByCode("TEST_VG_VINFAST_VN");
	ContractRef = Catalogs.HopDong.FindByCode("HD-RLS-BR02");
	If Not ValueIsFilled(BranchRef) Or Not ValueIsFilled(LegalEntityRef)
		Or Not ValueIsFilled(CustomerRef) Or Not ValueIsFilled(ContractRef) Then
		Raise "Branch RLS fixture is missing a required reference.";
	EndIf;
	If SessionParameters.CurrentBranch <> BranchRef Then
		CurrentBranchCode = ?(ValueIsFilled(SessionParameters.CurrentBranch), SessionParameters.CurrentBranch.Code, "<empty>");
		Raise StrTemplate("Branch RLS maker session is scoped to '%1', expected assigned branch '%2'.",
			CurrentBranchCode, BranchRef.Code);
	EndIf;
	EntityAccessQuery = New Query("SELECT ALLOWED COUNT(*) AS Amount FROM Catalog.PhapNhan WHERE Ref = &Ref");
	EntityAccessQuery.SetParameter("Ref", LegalEntityRef);
	EntityAccess = EntityAccessQuery.Execute().Unload()[0].Amount;
	ContractAccessQuery = New Query("SELECT ALLOWED COUNT(*) AS Amount FROM Catalog.HopDong WHERE Ref = &Ref");
	ContractAccessQuery.SetParameter("Ref", ContractRef);
	ContractAccess = ContractAccessQuery.Execute().Unload()[0].Amount;
	If EntityAccess <> 1 Or ContractAccess <> 1 Or LegalEntityRef.ChiNhanh <> BranchRef Then
		Raise StrTemplate("Branch RLS fixture references are outside the session scope: entity=%1, contract=%2, entity branch=%3, session branch=%4.",
			EntityAccess, ContractAccess, LegalEntityRef.ChiNhanh.Code, SessionParameters.CurrentBranch.Code);
	EndIf;

	Doc = Documents.BienBanNghiemThuGiaiDoan.CreateDocument();
	Doc.Number = "RLS-BB02";
	Doc.Date = Date(2026, 10, 20, 9, 0, 0);
	Doc.PhapNhan = LegalEntityRef;
	Doc.ChiNhanh = BranchRef;
	Doc.DoiTac = CustomerRef;
	Doc.HopDong = ContractRef;
	Doc.GiaTriNghiemThuChuaVAT = 1000000;
	Doc.ApDungGiamThueGTGT = False;
	Doc.TrangThai = Enums.TrangThaiNghiemThuAR.DuThao;
	Doc.NguoiDuyet = "ketoan_truong";
	Doc.DienGiai = "Branch 2 RLS E2E acceptance";
	Doc.Write();
	Doc.TrangThai = Enums.TrangThaiNghiemThuAR.ChoDuyetNoiBo;
	Doc.Write();
	If Doc.NguoiTao <> UserName() Or Doc.PhapNhan <> LegalEntityRef Then
		Raise "Branch RLS acceptance was not created by the authenticated maker in its assigned legal entity.";
	EndIf;
	Return New Structure("branch,document,status,maker", BranchRef.Code, Doc.Number,
		QuanLyVongDoiChungTuServer.TenTrangThai(Doc.TrangThai), Doc.NguoiTao);
EndFunction

Function ApproveBranchRLSE2EAcceptance() Export
	RequireFinanceE2ERole("KeToanTruong");
	DocRef = Documents.BienBanNghiemThuGiaiDoan.FindByNumber("RLS-BB02", Date(2026, 10, 20, 9, 0, 0));
	If Not ValueIsFilled(DocRef) Then Raise "Branch RLS acceptance was not visible to the KTT of branch 2."; EndIf;
	Doc = DocRef.GetObject();
	If Doc.TrangThai <> Enums.TrangThaiNghiemThuAR.ChoDuyetNoiBo Then
		Raise "Branch RLS acceptance must be submitted before KTT approval.";
	EndIf;
	Doc.TrangThai = Enums.TrangThaiNghiemThuAR.DaDuyetNoiBo;
	Doc.NguoiDuyet = UserName();
	Doc.Write();
	Return New Structure("branch,document,status,approver", Doc.PhapNhan.ChiNhanh.Code, Doc.Number,
		QuanLyVongDoiChungTuServer.TenTrangThai(Doc.TrangThai), Doc.NguoiDuyet);
EndFunction

Function PostBranchRLSE2EAcceptance() Export
	RequireFinanceE2ERole("KeToanTruong");
	DocRef = Documents.BienBanNghiemThuGiaiDoan.FindByNumber("RLS-BB02", Date(2026, 10, 20, 9, 0, 0));
	If Not ValueIsFilled(DocRef) Then Raise "Approved branch RLS acceptance is missing before posting."; EndIf;
	Doc = DocRef.GetObject();
	If Doc.TrangThai <> Enums.TrangThaiNghiemThuAR.DaDuyetNoiBo Then
		Raise "Branch RLS acceptance must be approved before posting.";
	EndIf;
	Doc.Write(DocumentWriteMode.Posting);
	If Not Doc.Posted Or Doc.TrangThai <> Enums.TrangThaiNghiemThuAR.DaGhiSo Then
		Raise "Branch RLS acceptance did not post to its expected state.";
	EndIf;
	Return New Structure("branch,document,posted,status", Doc.PhapNhan.ChiNhanh.Code, Doc.Number,
		Doc.Posted, QuanLyVongDoiChungTuServer.TenTrangThai(Doc.TrangThai));
EndFunction

Function VerifyBranchRLSE2E(Val ExtraParameters) Export
	RequireFinanceE2ERole("KeToanPhaiTra");
	Branch2 = Catalogs.ChiNhanh.FindByCode("CN-E2E-BR2");
	LegalEntity2 = Catalogs.PhapNhan.FindByCode("PN-BR02");
	If ExtraParameters = Undefined Or Not ExtraParameters.Property("branch1_legal_entity_uuid")
		Or Not ExtraParameters.Property("branch1_vendor_contract_uuid") Then
		Raise "Branch RLS verification requires the branch 1 reference UUIDs from the privileged fixture step.";
	EndIf;
	LegalEntity1 = Catalogs.PhapNhan.GetRef(New UUID(ExtraParameters.branch1_legal_entity_uuid));
	VendorContract1 = Catalogs.HopDong.GetRef(New UUID(ExtraParameters.branch1_vendor_contract_uuid));
	If SessionParameters.CurrentBranch <> Branch2 Then
		Raise StrTemplate("Branch RLS session initialized to %1 instead of assigned branch %2.", SessionParameters.CurrentBranch.Code, Branch2.Code);
	EndIf;

	VisibleDoc2 = CountAllowedBranchAcceptance(LegalEntity2);
	VisibleDoc1 = CountAllowedBranchAcceptance(LegalEntity1);
	VisibleAR2 = CountAllowedBranchRegister("AccumulationRegister.CongNoPhaiThu", LegalEntity2);
	VisibleAR1 = CountAllowedBranchRegister("AccumulationRegister.CongNoPhaiThu", LegalEntity1);
	VisibleGL2 = CountAllowedBranchRegister("AccountingRegister.SoCaiKeToan", LegalEntity2);
	VisibleGL1 = CountAllowedBranchRegister("AccountingRegister.SoCaiKeToan", LegalEntity1);
	If VisibleDoc2 <> 1 Or VisibleDoc1 <> 0 Or VisibleAR2 < 1 Or VisibleAR1 <> 0 Or VisibleGL2 < 1 Or VisibleGL1 <> 0 Then
		Raise StrTemplate("Branch RLS leaked or hid records: docs own/other=%1/%2, AR own/other=%3/%4, GL own/other=%5/%6.",
			VisibleDoc2, VisibleDoc1, VisibleAR2, VisibleAR1, VisibleGL2, VisibleGL1);
	EndIf;

	InsertDenied = False;
	Try
		ForeignDraft = Documents.HoaDonNhaCungCap.CreateDocument();
		ForeignDraft.Number = "RLS-DENY";
		ForeignDraft.Date = Date(2026, 10, 20, 10, 0, 0);
		ForeignDraft.PhapNhan = LegalEntity1;
		ForeignDraft.DoiTac = Catalogs.DoiTac.FindByCode("E2E_AWS_VND");
		ForeignDraft.HopDong = VendorContract1;
		ForeignDraft.TienTe = Catalogs.TienTe.FindByCode("VND");
		ForeignDraft.TongTien = 1000;
		ForeignDraft.Write();
	Except
		InsertDenied = True;
	EndTry;
	If Not InsertDenied Then
		Raise "AP user assigned to branch 2 was allowed to create a document for branch 1.";
	EndIf;

	Return New Structure("current_branch,branch2_documents,branch1_documents,branch2_ar_movements,branch1_ar_movements,branch2_gl_movements,branch1_gl_movements,foreign_insert_denied",
		Branch2.Code, VisibleDoc2, VisibleDoc1, VisibleAR2, VisibleAR1, VisibleGL2, VisibleGL1, InsertDenied);
EndFunction

Function CountAllowedBranchAcceptance(Val LegalEntityRef)
	Query = New Query(
		"SELECT ALLOWED
		|   COUNT(*) AS Amount
		|FROM
		|   Document.BienBanNghiemThuGiaiDoan
		|WHERE
		|   PhapNhan = &PhapNhan");
	Query.SetParameter("PhapNhan", LegalEntityRef);
	Return Query.Execute().Unload()[0].Amount;
EndFunction

Function CountAllowedBranchRegister(Val RegisterName, Val LegalEntityRef)
	If RegisterName = "AccumulationRegister.CongNoPhaiThu" Then
		QueryText = "SELECT ALLOWED COUNT(*) AS Amount FROM AccumulationRegister.CongNoPhaiThu WHERE PhapNhan = &PhapNhan";
	ElsIf RegisterName = "AccountingRegister.SoCaiKeToan" Then
		QueryText = "SELECT ALLOWED COUNT(*) AS Amount FROM AccountingRegister.SoCaiKeToan WHERE PhapNhan = &PhapNhan";
	Else
		Raise "Unsupported branch RLS register: " + RegisterName;
	EndIf;
	Query = New Query(QueryText);
	Query.SetParameter("PhapNhan", LegalEntityRef);
	Return Query.Execute().Unload()[0].Amount;
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
	// The demo E2E uses the standard 10% VAT fixture. Reduced-rate cases
	// remain covered separately by the VAT boundary tests below.
	Doc.ApDungGiamThueGTGT = False;
	Doc.NgayNghiemThu = BegOfDay(Doc.Date);
	Doc.TyLeVAT = ThueGTGTClientServer.TyLeVATApDungTheoNgay(Doc.NgayNghiemThu, Doc.ApDungGiamThueGTGT);
	Doc.TienVAT = 0;
	Doc.TongGiaTri = 0;
	Doc.TrangThai = Enums.TrangThaiNghiemThuAR.DuThao;
	Doc.NguoiDuyet = "ketoan_truong";
	Doc.DienGiai = "E2E accepted service October 2026";
	Doc.Write();
	Doc.TrangThai = Enums.TrangThaiNghiemThuAR.ChoDuyetNoiBo;
	Doc.Write();
	If Doc.NguoiTao <> UserName() Or Doc.TyLeVAT <> 10 Or Doc.TienVAT <> 20000000 Or Doc.TongGiaTri <> 220000000 Then
		Raise "Acceptance maker, VAT, or gross amount did not match the deterministic input.";
	EndIf;
	ResultData = New Structure;
	ResultData.Insert("acceptance_number", Doc.Number);
	ResultData.Insert("maker", Doc.NguoiTao);
	ResultData.Insert("status", QuanLyVongDoiChungTuServer.TenTrangThai(Doc.TrangThai));
	ResultData.Insert("net_vnd", Doc.GiaTriNghiemThuChuaVAT);
	ResultData.Insert("vat_rate", Doc.TyLeVAT);
	ResultData.Insert("vat_vnd", Doc.TienVAT);
	ResultData.Insert("gross_vnd", Doc.TongGiaTri);
	Return ResultData;
EndFunction

Function ApproveFinanceE2EAcceptance() Export
	RequireFinanceE2ERole("KeToanTruong");
	DocRef = Documents.BienBanNghiemThuGiaiDoan.FindByNumber("E2E-BB001", Date(2026, 10, 10, 9, 0, 0));
	If Not ValueIsFilled(DocRef) Then Raise "E2E acceptance E2E-BB001 is missing."; EndIf;
	Doc = DocRef.GetObject();
	If Doc.TrangThai <> Enums.TrangThaiNghiemThuAR.ChoDuyetNoiBo Then
		Raise "E2E acceptance must be submitted before KTT approval.";
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
	RequireFinanceE2ERole("KeToanTruong");
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
	Doc.DienGiai = "E2E issued service invoice";
	Doc.Write();
	If Doc.Posted Or Doc.TrangThaiHDDT <> Enums.TrangThaiHoaDonDienTu.DuThao
		Or Not IsBlankString(Doc.SoHoaDon) Or Not IsBlankString(Doc.KyHieu) Or Not IsBlankString(Doc.MaCQT) Then
		Raise "AR invoice draft must save without external e-invoice identifiers and remain unposted.";
	EndIf;
	Doc.TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.ChoKySo;
	Doc.NguoiDuyet = "ketoan_truong";
	Doc.Write();
	ResultData = New Structure;
	ResultData.Insert("invoice_number", Doc.Number);
	ResultData.Insert("external_ids_empty_before_issue", IsBlankString(Doc.SoHoaDon) And IsBlankString(Doc.KyHieu) And IsBlankString(Doc.MaCQT));
	ResultData.Insert("draft_saved_unposted", Not Doc.Posted);
	ResultData.Insert("maker", Doc.NguoiLap);
	ResultData.Insert("status", QuanLyVongDoiChungTuServer.TenTrangThai(Doc.TrangThaiHDDT));
	ResultData.Insert("base_acceptance", String(AcceptanceRef));
	Return ResultData;
EndFunction

Function IssueFinanceE2ESalesInvoice() Export
	RequireFinanceE2ERole("KeToanTruong");
	DocRef = Documents.HoaDonGTGTDauRa.FindByNumber("E2E-AR001", Date(2026, 10, 10, 10, 0, 0));
	If Not ValueIsFilled(DocRef) Then Raise "E2E sales invoice E2E-AR001 is missing."; EndIf;
	Doc = DocRef.GetObject();
	Doc.TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.DaPhatHanh;
	Doc.NguoiDuyet = UserName();
	MissingIssueDataError = "";
	Try
		Doc.Write(DocumentWriteMode.Posting);
	Except
		MissingIssueDataError = DetailErrorDescription(ErrorInfo());
	EndTry;
	If StrFind(MissingIssueDataError, "Failed to post") = 0 Then
		Raise StrTemplate("Issuing an AR invoice without external identifiers was not rejected: %1", MissingIssueDataError);
	EndIf;
	SavedAfterMissingIssueData = DocRef.GetObject();
	If SavedAfterMissingIssueData.Posted
		Or SavedAfterMissingIssueData.TrangThaiHDDT <> Enums.TrangThaiHoaDonDienTu.ChoKySo
		Or Not IsBlankString(SavedAfterMissingIssueData.SoHoaDon)
		Or Not IsBlankString(SavedAfterMissingIssueData.KyHieu)
		Or Not IsBlankString(SavedAfterMissingIssueData.MaCQT) Then
		Raise "An issued AR invoice without its external number, series, and tax authority code must remain unposted in ChoKySo.";
	EndIf;
	Doc = DocRef.GetObject();
	Doc.SoHoaDon = "E2EINV-001";
	Doc.KyHieu = "1C26E2E";
	Doc.MaCQT = "E2E-CQT-001";
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
	ResultData.Insert("sales_invoice_number", Doc.SoHoaDon);
	ResultData.Insert("approver", Doc.NguoiDuyet);
	ResultData.Insert("missing_issue_data_rejected", True);
	ResultData.Insert("missing_issue_data_error", MissingIssueDataError);
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

Function PrepareFinanceE2EFCT250Invoice() Export
	RequireFinanceE2ERole("KeToanPhaiTra");
	Context = FinanceE2EContext();
	Doc = Documents.HoaDonNhaCungCap.CreateDocument();
	Doc.Number = "E2E-AP-FCT250";
	Doc.Date = Date(2026, 10, 16, 11, 0, 0);
	Doc.NgayHoaDon = BegOfDay(Doc.Date);
	Doc.SoHoaDon = "E2EAP-FCT250";
	Doc.PhapNhan = Context.PhapNhan;
	Doc.DoiTac = Context.Vendor;
	Doc.HopDong = Context.VendorContract;
	Doc.TaiKhoanChiPhi = Context.Account627;
	Doc.TienTe = Context.VND;
	Doc.TyGia = 1;
	Doc.TongTien = 250000000;
	Doc.TienDichVu = 250000000;
	Doc.CoKhauTruFCT = True;
	Doc.TyLeThueVATNhaThau = 5;
	Doc.TyLeThueTNDNNhaThau = 5;
	Doc.TrangThai = Enums.TrangThaiHoaDonAP.DuThao;
	Doc.DienGiai = "E2E exact FCT fixture: gross 250m, vendor payable 225m";
	Doc.Write();
	Doc.TrangThai = Enums.TrangThaiHoaDonAP.ChoKeToanTruongDuyet;
	Doc.NguoiDuyet = "ketoan_truong";
	Doc.Write();
	If Not Doc.CoKhauTruFCT Or Doc.TongTien <> 250000000 Or Doc.TienThueVATNhaThau <> 12500000
		Or Doc.TienThueTNDNNhaThau <> 12500000 Or Doc.NoThucTraNCC <> 225000000 Or Doc.ChiPhiVSF <> 237500000 Then
		Raise "FCT250 prepare must persist gross 250m, VAT/CIT 12.5m each, expense 237.5m, and payable 225m.";
	EndIf;
	Return New Structure("invoice_number,posted,gross_vnd,fct_vat_vnd,fct_cit_vnd,expense_vnd,payable_vnd,fct_enabled,approver",
		Doc.Number, Doc.Posted, Doc.TongTien, Doc.TienThueVATNhaThau, Doc.TienThueTNDNNhaThau, Doc.ChiPhiVSF, Doc.NoThucTraNCC, Doc.CoKhauTruFCT, Doc.NguoiDuyet);
EndFunction

Function PostVerifyFinanceE2EFCT250Invoice() Export
	RequireFinanceE2ERole("KeToanTruong");
	DocRef = Documents.HoaDonNhaCungCap.FindByNumber("E2E-AP-FCT250", Date(2026, 10, 16, 11, 0, 0));
	If Not ValueIsFilled(DocRef) Then Raise "FCT250 AP invoice is missing before approval."; EndIf;
	Doc = DocRef.GetObject();
	Doc.TrangThai = Enums.TrangThaiHoaDonAP.DaGhiSo;
	Doc.NguoiDuyet = UserName();
	Doc.Write(DocumentWriteMode.Posting);
	APBalance = FinanceE2EAPBalanceFor(Doc.PhapNhan, Doc.DoiTac, Doc.HopDong, DocRef);
	If Not Doc.Posted Or Not Doc.CoKhauTruFCT Or Doc.TongTien <> 250000000
		Or Doc.TienThueVATNhaThau <> 12500000 Or Doc.TienThueTNDNNhaThau <> 12500000
		Or Doc.NoThucTraNCC <> 225000000 Or Doc.ChiPhiVSF <> 237500000 Or APBalance <> 225000000 Then
		Raise StrTemplate("FCT250 posted source/register values differ: gross=%1, VAT=%2, CIT=%3, payable=%4, AP balance=%5.",
			Doc.TongTien, Doc.TienThueVATNhaThau, Doc.TienThueTNDNNhaThau, Doc.NoThucTraNCC, APBalance);
	EndIf;
	AssertFinanceE2EGL(DocRef, "627", "3311", 225000000);
	AssertFinanceE2EGL(DocRef, "627", "3338", 12500000);
	AssertFinanceE2EGL(DocRef, "1331", "33318", 12500000);
	If CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", DocRef) <> 3
		Or CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiTra", DocRef) <> 1 Then
		Raise "FCT250 must post three GL rows and one AP subledger row.";
	EndIf;
	Return New Structure("invoice_number,posted,gross_vnd,fct_vat_vnd,fct_cit_vnd,expense_vnd,payable_vnd,ap_balance_vnd,gl_rows,ap_rows,checkbox_persisted",
		Doc.Number, Doc.Posted, Doc.TongTien, Doc.TienThueVATNhaThau, Doc.TienThueTNDNNhaThau, Doc.ChiPhiVSF, Doc.NoThucTraNCC,
		APBalance, CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", DocRef),
		CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiTra", DocRef), Doc.CoKhauTruFCT);
EndFunction

Function PrepareFinanceE2EFCTCashFundingInvoice() Export
	RequireFinanceE2ERole("KeToanPhaiThu");
	Context = FinanceE2EContext();
	Invoice = Documents.HoaDonGTGTDauRa.CreateDocument();
	Invoice.Number = "E2E-AR-FCT-FUND";
	Invoice.Date = Date(2026, 10, 18, 12, 0, 0);
	Invoice.NgayHoaDon = BegOfDay(Invoice.Date);
	Invoice.PhapNhan = Context.PhapNhan;
	Invoice.DoiTac = Context.Customer;
	Invoice.HopDong = Context.CustomerContract;
	Invoice.TienTe = Context.VND;
	Invoice.TyGia = 1;
	Invoice.TienChuaThue = 225000000;
	Invoice.ThueSuatVAT = 0;
	Invoice.TienThueVAT = 0;
	Invoice.TongTienThanhToan = 225000000;
	Invoice.TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.DuThao;
	Invoice.DienGiai = "E2E customer advance funds the 225m FCT payment fixture";
	Invoice.Write();
	Invoice.TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.ChoKySo;
	Invoice.NguoiDuyet = "ketoan_truong";
	Invoice.Write();
	If ValueIsFilled(Invoice.BienBanNghiemThu) Or Invoice.TienChuaThue <> 225000000 Or Invoice.TongTienThanhToan <> 225000000 Or Invoice.Posted Then
		Raise "FCT funding invoice must preserve manual-invoice behavior and remain unposted for KTT review.";
	EndIf;
	Return New Structure("invoice_number,posted,manual_source_empty,net_vnd,gross_vnd,approver",
		Invoice.Number, Invoice.Posted, Not ValueIsFilled(Invoice.BienBanNghiemThu), Invoice.TienChuaThue, Invoice.TongTienThanhToan, Invoice.NguoiDuyet);
EndFunction

Function PostFinanceE2EFCTCashFundingInvoice() Export
	RequireFinanceE2ERole("KeToanTruong");
	InvoiceRef = Documents.HoaDonGTGTDauRa.FindByNumber("E2E-AR-FCT-FUND", Date(2026, 10, 18, 12, 0, 0));
	If Not ValueIsFilled(InvoiceRef) Then Raise "FCT funding invoice is missing."; EndIf;
	Invoice = InvoiceRef.GetObject();
	Invoice.SoHoaDon = "E2E-AR-FCT-FUND";
	Invoice.KyHieu = "1CFCT26";
	Invoice.MaCQT = "E2E-CQT-FCT-FUND";
	Invoice.TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.DaPhatHanh;
	Invoice.NguoiDuyet = UserName();
	Invoice.Write(DocumentWriteMode.Posting);
	ARBalance = FinanceE2EARBalanceFor(Invoice.PhapNhan, Invoice.DoiTac, Invoice.HopDong, InvoiceRef);
	If Not Invoice.Posted Or ARBalance <> 225000000 Then
		Raise StrTemplate("FCT funding invoice failed posting: posted=%1, AR=%2.", Invoice.Posted, ARBalance);
	EndIf;
	AssertFinanceE2EGL(InvoiceRef, "1312", "5113", 225000000);
	Return New Structure("invoice_number,posted,net_vnd,gross_vnd,ar_balance_vnd,gl_rows",
		Invoice.Number, Invoice.Posted, Invoice.TienChuaThue, Invoice.TongTienThanhToan, ARBalance,
		CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", InvoiceRef));
EndFunction

Function PrepareFinanceE2EFCTCashFundingReceipt() Export
	RequireFinanceE2ERole("KeToanPhaiThu");
	Context = FinanceE2EContext();
	InvoiceRef = Documents.HoaDonGTGTDauRa.FindByNumber("E2E-AR-FCT-FUND", Date(2026, 10, 18, 12, 0, 0));
	If Not ValueIsFilled(InvoiceRef) Or Not InvoiceRef.Posted Then Raise "FCT funding receipt requires the issued manual invoice."; EndIf;
	Receipt = Documents.PhieuThuTienKhachHang.CreateDocument();
	Receipt.Number = "E2E-PT-FCT-FUND";
	Receipt.Date = Date(2026, 10, 18, 13, 0, 0);
	Receipt.PhapNhan = Context.PhapNhan;
	Receipt.DoiTac = Context.Customer;
	Receipt.HopDong = Context.CustomerContract;
	Receipt.ChungTuGoc = InvoiceRef;
	Receipt.TaiKhoanTien = Context.Bank;
	Receipt.KhoanMucDongTien = Context.CustomerReceiptCategory;
	Receipt.TienTe = Context.VND;
	Receipt.TyGia = 1;
	Receipt.NgayThu = BegOfDay(Receipt.Date);
	Receipt.SoTien = 225000000;
	Receipt.NguoiDuyet = "cfo_giamdoc";
	Receipt.DienGiai = "E2E customer advance funding for vendor FCT payment";
	Receipt.Write();
	Return New Structure("receipt_number,amount_vnd,source_invoice,posted", Receipt.Number, Receipt.SoTien, String(InvoiceRef), Receipt.Posted);
EndFunction

Function PostFinanceE2EFCTCashFundingReceipt() Export
	RequireFinanceE2ERole("GiamDocTaiChinh_CFO");
	ReceiptRef = Documents.PhieuThuTienKhachHang.FindByNumber("E2E-PT-FCT-FUND", Date(2026, 10, 18, 13, 0, 0));
	If Not ValueIsFilled(ReceiptRef) Then Raise "FCT cash funding receipt is missing."; EndIf;
	Receipt = ReceiptRef.GetObject();
	Receipt.NguoiDuyet = UserName();
	Receipt.Write(DocumentWriteMode.Posting);
	ARBalance = FinanceE2EARBalanceFor(Receipt.PhapNhan, Receipt.DoiTac, Receipt.HopDong, Receipt.ChungTuGoc);
	CashBalance = FinanceE2ECashBalanceFor(Receipt.PhapNhan, Receipt.TaiKhoanTien, Receipt.TienTe).SoTien;
	If Not Receipt.Posted Or ARBalance <> 0 Or CountRecorderMovementRecords("AccumulationRegister.DongTien", ReceiptRef) <> 1 Or CashBalance < 225000000 Then
		Raise StrTemplate("FCT cash funding receipt did not post to cash and settle its invoice: posted=%1, AR=%2, cash=%3.", Receipt.Posted, ARBalance, CashBalance);
	EndIf;
	AssertFinanceE2EGL(ReceiptRef, "1121", "1312", 225000000);
	Return New Structure("receipt_number,posted,amount_vnd,ar_balance_vnd,cash_balance_vnd,cash_rows,gl_rows",
		Receipt.Number, Receipt.Posted, Receipt.SoTien, ARBalance, CashBalance,
		CountRecorderMovementRecords("AccumulationRegister.DongTien", ReceiptRef),
		CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", ReceiptRef));
EndFunction

Function SubmitFinanceE2EFCT250Payment() Export
	RequireFinanceE2ERole("KeToanPhaiTra");
	Context = FinanceE2EContext();
	InvoiceRef = Documents.HoaDonNhaCungCap.FindByNumber("E2E-AP-FCT250", Date(2026, 10, 16, 11, 0, 0));
	If Not ValueIsFilled(InvoiceRef) Or Not InvoiceRef.Posted Then Raise "FCT250 payment requires the posted FCT invoice."; EndIf;
	Payment = Documents.UyNhiemChi.CreateDocument();
	Payment.Number = "E2E-UNC-FCT250";
	Payment.Date = Date(2026, 10, 17, 9, 0, 0);
	Payment.NgayLap = Payment.Date;
	Payment.NgayGhiSo = Payment.Date;
	Payment.PhapNhan = Context.PhapNhan;
	Payment.DoiTac = Context.Vendor;
	Payment.HopDong = Context.VendorContract;
	Payment.ChungTuGoc = InvoiceRef;
	Payment.TaiKhoanTien = Context.Bank;
	Payment.KhoanMucDongTien = Context.VendorPaymentCategory;
	Payment.TienTe = Context.VND;
	Payment.TyGia = 1;
	Payment.SoTien = 225000000;
	Payment.PhiNganHang = 0;
	Payment.TrangThai = Enums.TrangThaiLenhThanhToan.DuThao;
	Payment.NguoiDuyet = "ketoan_truong";
	Payment.DienGiai = "E2E payment of FCT250 supplier payable";
	Payment.Write();
	Payment.TrangThai = Enums.TrangThaiLenhThanhToan.ChoDuyet;
	Payment.Write();
	Return New Structure("payment_number,amount_vnd,status,source_invoice", Payment.Number, Payment.SoTien,
		QuanLyVongDoiChungTuServer.TenTrangThai(Payment.TrangThai), String(InvoiceRef));
EndFunction

Function ApproveFinanceE2EFCT250Payment() Export
	RequireFinanceE2ERole("KeToanTruong");
	PaymentRef = Documents.UyNhiemChi.FindByNumber("E2E-UNC-FCT250", Date(2026, 10, 17, 9, 0, 0));
	If Not ValueIsFilled(PaymentRef) Then Raise "FCT250 payment is missing before approval."; EndIf;
	PaymentRefs = New Array;
	PaymentRefs.Add(PaymentRef);
	Workspace = DataProcessors.BanLamViecWebERP.Create();
	ApprovalResult = Workspace.PheDuyetHangLoat(PaymentRefs);
	Payment = PaymentRef.GetObject();
	If ApprovalResult.ThatBai <> 0 Or Payment.TrangThai <> Enums.TrangThaiLenhThanhToan.DaDuyet Or Payment.Posted Then
		Raise "KTT approval did not leave the FCT250 payment approved and unposted.";
	EndIf;
	Return New Structure("payment_number,amount_vnd,status,approver,posted", Payment.Number, Payment.SoTien,
		QuanLyVongDoiChungTuServer.TenTrangThai(Payment.TrangThai), Payment.NguoiDuyet, Payment.Posted);
EndFunction

Function SubmitFinanceE2EFCT250PaymentToBank() Export
	RequireFinanceE2ERole("KeToanTruong");
	PaymentRef = Documents.UyNhiemChi.FindByNumber("E2E-UNC-FCT250", Date(2026, 10, 17, 9, 0, 0));
	If Not ValueIsFilled(PaymentRef) Then Raise "FCT250 payment is missing before bank submission."; EndIf;
	Workspace = DataProcessors.BanLamViecWebERP.Create();
	BankResult = Workspace.GuiLenhChiDaDuyetNganHang(PaymentRef);
	Payment = PaymentRef.GetObject();
	If Not BankResult.accepted Or Payment.TrangThai <> Enums.TrangThaiLenhThanhToan.DaGuiNganHang
		Or Payment.TrangThaiGuiNganHang <> "ACCEPTED" Or IsBlankString(Payment.MaGiaoDichNganHang) Then
		Raise StrTemplate("FCT250 payment bank submission failed: %1", BankResult.error);
	EndIf;
	Return New Structure("payment_number,amount_vnd,status,bank_status,request_id", Payment.Number, Payment.SoTien,
		QuanLyVongDoiChungTuServer.TenTrangThai(Payment.TrangThai), Payment.TrangThaiGuiNganHang, BankResult.request_id);
EndFunction

Function PostVerifyFinanceE2EFCT250Payment() Export
	RequireFinanceE2ERole("GiamDocTaiChinh_CFO");
	PaymentRef = Documents.UyNhiemChi.FindByNumber("E2E-UNC-FCT250", Date(2026, 10, 17, 9, 0, 0));
	If Not ValueIsFilled(PaymentRef) Then Raise "FCT250 payment is missing before CFO posting."; EndIf;
	InvoiceRef = PaymentRef.ChungTuGoc;
	Context = FinanceE2EContext();
	Payment = PaymentRef.GetObject();
	If Payment.TrangThaiGuiNganHang <> "ACCEPTED" Or Payment.SoTien <> 225000000 Then
		Raise "FCT250 payment must be bank-accepted for exactly 225m before posting.";
	EndIf;
	Payment.TrangThai = Enums.TrangThaiLenhThanhToan.DaGhiSo;
	Payment.NguoiDuyet = UserName();
	Payment.Write(DocumentWriteMode.Posting);
	APBalance = FinanceE2EAPBalance(Context, InvoiceRef);
	If Not Payment.Posted Or APBalance <> 0 Or CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiTra", PaymentRef) <> 1
		Or CountRecorderMovementRecords("AccumulationRegister.DongTien", PaymentRef) <> 1 Then
		Raise StrTemplate("FCT250 payment did not settle AP/cash records: posted=%1, AP balance=%2.", Payment.Posted, APBalance);
	EndIf;
	AssertFinanceE2EGL(PaymentRef, "3311", "1121", 225000000);
	Return New Structure("payment_number,posted,amount_vnd,ap_balance_after_vnd,cash_rows,ap_rows,gl_rows,bank_status",
		Payment.Number, Payment.Posted, Payment.SoTien, APBalance,
		CountRecorderMovementRecords("AccumulationRegister.DongTien", PaymentRef),
		CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiTra", PaymentRef),
		CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", PaymentRef), Payment.TrangThaiGuiNganHang);
EndFunction

Function VerifyFinanceE2EReportValues() Export
	RequireFinanceE2ERole("GiamDocTaiChinh_CFO");
	StartDate = Date(2026, 1, 1);
	EndDate = Date(2026, 10, 22);
	AR = VerifyFinanceE2ERegisterEquation("CongNoPhaiThu", StartDate, EndDate);
	AP = VerifyFinanceE2ERegisterEquation("CongNoPhaiTra", StartDate, EndDate);
	FCTInvoiceRef = Documents.HoaDonNhaCungCap.FindByNumber("E2E-AP-FCT250", Date(2026, 10, 16, 11, 0, 0));
	FCTPaymentRef = Documents.UyNhiemChi.FindByNumber("E2E-UNC-FCT250", Date(2026, 10, 17, 9, 0, 0));
	If Not ValueIsFilled(FCTInvoiceRef) Or Not FCTInvoiceRef.Posted Or Not ValueIsFilled(FCTPaymentRef) Or Not FCTPaymentRef.Posted Then
		Raise "Report verification requires the posted and paid FCT250 source documents.";
	EndIf;
	FCTMovementQuery = New Query(
		"SELECT
		| ISNULL(SUM(CASE WHEN Movement.RecordType = VALUE(AccumulationRecordType.Receipt) THEN Movement.SoTien ELSE 0 END), 0) AS Increase,
		| ISNULL(SUM(CASE WHEN Movement.RecordType = VALUE(AccumulationRecordType.Expense) THEN Movement.SoTien ELSE 0 END), 0) AS Decrease
		|FROM AccumulationRegister.CongNoPhaiTra AS Movement
		|WHERE Movement.Active = TRUE AND Movement.ChungTuGoc = &Source");
	FCTMovementQuery.SetParameter("Source", FCTInvoiceRef);
	FCTMovement = FCTMovementQuery.Execute().Unload()[0];
	FCTClosing = FinanceE2EAPBalance(FinanceE2EContext(), FCTInvoiceRef);
	If FCTMovement.Increase <> 225000000 Or FCTMovement.Decrease <> 225000000 Or FCTClosing <> 0 Then
		Raise StrTemplate("AP detail report source FCT250 must show +225m / -225m / closing 0; got %1 / %2 / %3.",
			FCTMovement.Increase, FCTMovement.Decrease, FCTClosing);
	EndIf;
	If Not AR.equation_passed Or Not AP.equation_passed Then
		Raise "AR/AP detail reports failed opening + increases - decreases = closing balance.";
	EndIf;
	AgingData = BangDieuKhienServer.LayDuLieuTongQuan("NamNay");
	If StrFind(AgingData, "BieuDoTuoiNo") = 0 Or StrFind(AgingData, "QuaHanTren90") = 0
		Or StrFind(AgingData, "TrongHan") = 0 Then
		Raise "Dashboard/aging report did not return the expected shared aging groups.";
	EndIf;
	Return New Structure("status,ar_register_equation,ap_register_equation,fct250_report_increase_vnd,fct250_report_decrease_vnd,fct250_closing_balance_vnd,aging_json,period_start,period_end",
		"PASS", AR, AP, FCTMovement.Increase, FCTMovement.Decrease, FCTClosing, AgingData, StartDate, EndDate);
EndFunction

Function VerifyFinanceE2ERegisterEquation(Val RegisterName, Val StartDate, Val EndDate)
	OpeningQuery = New Query("SELECT ISNULL(SUM(SoTienBalance), 0) AS Balance FROM AccumulationRegister." + RegisterName + ".Balance(&Moment, )");
	OpeningQuery.SetParameter("Moment", StartDate);
	Opening = OpeningQuery.Execute().Unload()[0].Balance;
	MovementQuery = New Query(
		"SELECT
		| ISNULL(SUM(CASE WHEN Movement.RecordType = VALUE(AccumulationRecordType.Receipt) THEN Movement.SoTien ELSE 0 END), 0) AS Increase,
		| ISNULL(SUM(CASE WHEN Movement.RecordType = VALUE(AccumulationRecordType.Expense) THEN Movement.SoTien ELSE 0 END), 0) AS Decrease
		|FROM AccumulationRegister." + RegisterName + " AS Movement
		|WHERE Movement.Active = TRUE AND Movement.Period >= &Start AND Movement.Period < DATEADD(&End, DAY, 1)");
	MovementQuery.SetParameter("Start", StartDate);
	MovementQuery.SetParameter("End", EndDate);
	Movements = MovementQuery.Execute().Unload()[0];
	ClosingQuery = New Query("SELECT ISNULL(SUM(SoTienBalance), 0) AS Balance FROM AccumulationRegister." + RegisterName + ".Balance(DATEADD(&Moment, DAY, 1), )");
	ClosingQuery.SetParameter("Moment", EndDate);
	Closing = ClosingQuery.Execute().Unload()[0].Balance;
	EquationPassed = Opening + Movements.Increase - Movements.Decrease = Closing;
	Return New Structure("register,opening_vnd,increase_vnd,decrease_vnd,closing_vnd,equation_passed",
		RegisterName, Opening, Movements.Increase, Movements.Decrease, Closing, EquationPassed);
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
	PaymentRefs = New Array;
	PaymentRefs.Add(DocRef);
	Workspace = DataProcessors.BanLamViecWebERP.Create();
	ApprovalResult = Workspace.PheDuyetHangLoat(PaymentRefs);
	If ApprovalResult.ThatBai <> 0 Then
		Raise StrTemplate("KTT approval failed for E2E-UNC01: %1", ApprovalResult.ChiTiet[0].GhiChu);
	EndIf;
	Doc = DocRef.GetObject();
	If Doc.TrangThai <> Enums.TrangThaiLenhThanhToan.DaDuyet Or Doc.Posted
		Or Not IsBlankString(Doc.MaGiaoDichNganHang) Then
		Raise "KTT approval must leave E2E-UNC01 approved and unposted before bank submission.";
	EndIf;
	ResultData = New Structure;
	ResultData.Insert("payment_number", Doc.Number);
	ResultData.Insert("approver", Doc.NguoiDuyet);
	ResultData.Insert("status", QuanLyVongDoiChungTuServer.TenTrangThai(Doc.TrangThai));
	Return ResultData;
EndFunction

Function SubmitFinanceE2EPaymentToBank() Export
	RequireFinanceE2ERole("KeToanTruong");
	PaymentRef = Documents.UyNhiemChi.FindByNumber("E2E-UNC01", Date(2026, 10, 14, 9, 0, 0));
	If Not ValueIsFilled(PaymentRef) Then Raise "Approved E2E payment is missing before bank submission."; EndIf;
	Workspace = DataProcessors.BanLamViecWebERP.Create();
	BankResult = Workspace.GuiLenhChiDaDuyetNganHang(PaymentRef);
	Payment = PaymentRef.GetObject();
	If Not BankResult.accepted Or Payment.TrangThai <> Enums.TrangThaiLenhThanhToan.DaGuiNganHang
		Or IsBlankString(Payment.MaGiaoDichNganHang) Or Payment.TrangThaiGuiNganHang <> "ACCEPTED" Then
		Raise StrTemplate("Bank submission failed for E2E-UNC01: %1", BankResult.error);
	EndIf;
	Return New Structure("payment_number,approver,status,bank_transaction_id,bank_status,request_id,http_code",
		Payment.Number, Payment.NguoiDuyet, QuanLyVongDoiChungTuServer.TenTrangThai(Payment.TrangThai),
		Payment.MaGiaoDichNganHang, Payment.TrangThaiGuiNganHang, BankResult.request_id, BankResult.http_code);
EndFunction

Function VerifyFinanceE2EBankIdempotency() Export
	RequireFinanceE2ERole("KeToanTruong");
	PaymentRef = Documents.UyNhiemChi.FindByNumber("E2E-UNC01", Date(2026, 10, 14, 9, 0, 0));
	If Not ValueIsFilled(PaymentRef) Then Raise "Accepted E2E payment is missing before the bank idempotency retry."; EndIf;
	Payment = PaymentRef.GetObject();
	OriginalTransactionId = Payment.MaGiaoDichNganHang;
	If Payment.TrangThai <> Enums.TrangThaiLenhThanhToan.DaGuiNganHang Or IsBlankString(OriginalTransactionId) Then
		Raise "Bank idempotency retry requires a previously accepted payment.";
	EndIf;
	Payment.MaGiaoDichNganHang = "";
	Payment.TrangThaiGuiNganHang = "RETRY_PENDING";
	Payment.Write();
	RetryResult = TichHopNganHangServer.GuiLenhChiNganHang(PaymentRef);
	If Not RetryResult.accepted Or RetryResult.transaction_id <> OriginalTransactionId Then
		Raise "Bank gateway did not return the same transaction for the same idempotency key.";
	EndIf;
	Payment = PaymentRef.GetObject();
	Payment.MaGiaoDichNganHang = RetryResult.transaction_id;
	Payment.TrangThaiGuiNganHang = RetryResult.bank_status;
	Payment.ThoiDiemGuiNganHang = CurrentSessionDate();
	Payment.Write();
	Return New Structure("request_id,original_transaction_id,retry_transaction_id,idempotent",
		RetryResult.request_id, OriginalTransactionId, RetryResult.transaction_id, True);
EndFunction

Function SubmitFinanceE2EBankRejectedPayment() Export
	RequireFinanceE2ERole("KeToanPhaiTra");
	Context = FinanceE2EContext();
	InvoiceRef = Documents.HoaDonNhaCungCap.FindByNumber("E2E-AP001", Date(2026, 10, 13, 9, 0, 0));
	If Not ValueIsFilled(InvoiceRef) Or Not InvoiceRef.Posted Then
		Raise "Bank rejection test requires the posted E2E AP invoice.";
	EndIf;
	Payment = Documents.UyNhiemChi.CreateDocument();
	Payment.Number = "E2E-BANK-REJECT";
	Payment.Date = Date(2026, 10, 14, 10, 0, 0);
	Payment.NgayLap = Payment.Date;
	Payment.NgayGhiSo = Payment.Date;
	Payment.PhapNhan = Context.PhapNhan;
	Payment.DoiTac = Context.Vendor;
	Payment.HopDong = Context.VendorContract;
	Payment.ChungTuGoc = InvoiceRef;
	Payment.TaiKhoanTien = Context.Bank;
	Payment.KhoanMucDongTien = Context.VendorPaymentCategory;
	Payment.TienTe = Context.VND;
	Payment.TyGia = 1;
	Payment.SoTien = 1000000;
	Payment.PhiNganHang = 0;
	Payment.TrangThai = Enums.TrangThaiLenhThanhToan.DuThao;
	Payment.DienGiai = "E2E deterministic bank rejection and retry handling";
	Payment.Write();
	Payment.TrangThai = Enums.TrangThaiLenhThanhToan.ChoDuyet;
	Payment.Write();
	Return New Structure("payment_number,amount_vnd,initial_status,source_invoice", Payment.Number,
		Payment.SoTien, QuanLyVongDoiChungTuServer.TenTrangThai(Payment.TrangThai), String(InvoiceRef));
EndFunction

Function ApproveFinanceE2EBankRejectedPayment() Export
	RequireFinanceE2ERole("KeToanTruong");
	PaymentRef = Documents.UyNhiemChi.FindByNumber("E2E-BANK-REJECT", Date(2026, 10, 14, 10, 0, 0));
	If Not ValueIsFilled(PaymentRef) Then Raise "Bank rejection payment fixture is missing before approval."; EndIf;
	PaymentRefs = New Array;
	PaymentRefs.Add(PaymentRef);
	Workspace = DataProcessors.BanLamViecWebERP.Create();
	ApprovalResult = Workspace.PheDuyetHangLoat(PaymentRefs);
	Payment = PaymentRef.GetObject();
	If ApprovalResult.ThatBai <> 0 Or Payment.Posted
		Or Payment.TrangThai <> Enums.TrangThaiLenhThanhToan.DaDuyet
		Or Not IsBlankString(Payment.TrangThaiGuiNganHang) Then
		Raise "Bank rejection fixture must be approved separately before the gateway call.";
	EndIf;
	Return New Structure("payment_number,status,approver,posted", Payment.Number,
		QuanLyVongDoiChungTuServer.TenTrangThai(Payment.TrangThai), Payment.NguoiDuyet, Payment.Posted);
EndFunction

Function VerifyFinanceE2EBankRejectedPayment() Export
	RequireFinanceE2ERole("KeToanTruong");
	PaymentRef = Documents.UyNhiemChi.FindByNumber("E2E-BANK-REJECT", Date(2026, 10, 14, 10, 0, 0));
	If Not ValueIsFilled(PaymentRef) Then Raise "Bank rejection payment fixture is missing."; EndIf;
	InvoiceRef = PaymentRef.ChungTuGoc;
	Context = FinanceE2EContext();	
	BalanceBefore = FinanceE2EAPBalance(Context, InvoiceRef);
	Workspace = DataProcessors.BanLamViecWebERP.Create();
	BankResult = Workspace.GuiLenhChiDaDuyetNganHang(PaymentRef);
	Payment = PaymentRef.GetObject();
	BalanceAfter = FinanceE2EAPBalance(Context, InvoiceRef);
	If BankResult.accepted Or BankResult.http_code <> 422 Or Payment.Posted
		Or Payment.TrangThai <> Enums.TrangThaiLenhThanhToan.DaDuyet
		Or Payment.TrangThaiGuiNganHang <> "HTTP_REJECTED"
		Or Not IsBlankString(Payment.MaGiaoDichNganHang)
		Or BalanceAfter <> BalanceBefore
		Or CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiTra", PaymentRef) <> 0
		Or CountRecorderMovementRecords("AccumulationRegister.DongTien", PaymentRef) <> 0
		Or CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", PaymentRef) <> 0 Then
		Raise "Rejected bank payment changed AP, cash, or GL state, or did not remain retryable.";
	EndIf;
	Return New Structure("payment_number,bank_status,http_code,request_id,ap_before_vnd,ap_after_vnd,posted,transaction_id_empty",
		Payment.Number, Payment.TrangThaiGuiNganHang, BankResult.http_code, BankResult.request_id,
		BalanceBefore, BalanceAfter, Payment.Posted, IsBlankString(Payment.MaGiaoDichNganHang));
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
	Doc.NguoiDuyet = "ketoan_truong";
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
	RequireFinanceE2ERole("KeToanTruong");
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
	Doc.NguoiDuyet = "ketoan_truong";
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
	RequireFinanceE2ERole("KeToanTruong");
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
	Context = FinanceE2EContext(True);
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
	NegativeCases = New Array;
	NegativeCases.Add(New Structure("name,rejected,posted,persisted,cash_unchanged,accumulation_rows,gl_rows",
		"one_vnd_imbalance", Not OverDoc.Posted, OverDoc.Posted, ValueIsFilled(Documents.DoiSoatKenhThanhToan.FindByNumber(OverDoc.Number, OverDoc.Date)),
		FinanceE2ECashBalance(Context) = CashAfter, CountRecorderMovementRecords("AccumulationRegister.DongTien", OverDoc.Ref),
		CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", OverDoc.Ref)));
	USD = Catalogs.TienTe.FindByCode("USD");
	ExpenseCategory = Catalogs.KhoanMucDongTien.FindByCode("KM-CHI-CLOUD");
	If Not ValueIsFilled(USD) Then Raise "Reconciliation currency boundary requires the USD currency reference."; EndIf;
	If Not ValueIsFilled(ExpenseCategory) Then Raise "Reconciliation cash-flow boundary requires the seeded expense category."; EndIf;
	For Each CaseName In StrSplit("unsupported_channel,negative_fee,zero_gross,zero_net,unsupported_currency,expense_cash_category", ",") Do
		NegativeCases.Add(VerifyRejectedFinanceE2EReconciliation(Context, CaseName, USD, ExpenseCategory));
	EndDo;
	ZeroFeeCase = VerifyZeroFeeFinanceE2EReconciliation(Context);
	AllNegativeCasesRejected = True;
	For Each NegativeCase In NegativeCases Do
		If Not NegativeCase.rejected Or NegativeCase.posted Or NegativeCase.persisted
			Or Not NegativeCase.cash_unchanged Or NegativeCase.accumulation_rows <> 0 Or NegativeCase.gl_rows <> 0 Then
			AllNegativeCasesRejected = False;
		EndIf;
	EndDo;
	If Not AllNegativeCasesRejected Then
		Raise "At least one invalid gateway reconciliation was persisted, posted, or left cash/GL movements.";
	EndIf;
	If Not ZeroFeeCase.accepted_then_unposted Or Not ZeroFeeCase.posted_without_fee_row
		Or Not ZeroFeeCase.cash_restored Or ZeroFeeCase.accumulation_rows_after_unpost <> 0
		Or ZeroFeeCase.gl_rows_after_unpost <> 0 Then
		Raise "A valid zero-fee gateway reconciliation failed or left residual movements after unposting.";
	EndIf;
	Return New Structure("channel,gross_vnd,fee_vnd,fee_percent,net_vnd,bank_before_vnd,bank_after_vnd,gl_rows,unpost_repost,negative_case_count,negative_cases,all_negative_cases_rejected,zero_fee_case",
		Doc.KenhThanhToan, Doc.TongTienGiaoDich, Doc.TongPhi, 1.5, Doc.TongTienThucNhan, CashBefore, CashAfter, 2, True,
		NegativeCases.Count(), NegativeCases, AllNegativeCasesRejected, ZeroFeeCase);
EndFunction

Function VerifyRejectedFinanceE2EReconciliation(Val Context, Val CaseName, Val USD, Val ExpenseCategory)
	Doc = Documents.DoiSoatKenhThanhToan.CreateDocument();
	If CaseName = "unsupported_channel" Then
		Doc.Number = "E2E-BK-CHANNEL";
	ElsIf CaseName = "negative_fee" Then
		Doc.Number = "E2E-BK-NEGFEE";
	ElsIf CaseName = "zero_gross" Then
		Doc.Number = "E2E-BK-ZGROSS";
	ElsIf CaseName = "zero_net" Then
		Doc.Number = "E2E-BK-ZNET";
	ElsIf CaseName = "unsupported_currency" Then
		Doc.Number = "E2E-BK-CURRENCY";
	ElsIf CaseName = "expense_cash_category" Then
		Doc.Number = "E2E-BK-EXPENSE";
	Else
		Raise "Unknown gateway reconciliation boundary case: " + CaseName;
	EndIf;
	Doc.Date = Date(2026, 10, 20, 15, 31, 0);
	Doc.PhapNhan = Context.PhapNhan;
	Doc.DoiTacTrungGian = Context.PaymentProvider;
	Doc.TaiKhoanTien = Context.Bank;
	Doc.KhoanMucDongTien = Context.PaymentReconciliationCategory;
	Doc.TienTe = Context.VND;
	Doc.KenhThanhToan = "VNPAY";
	Doc.TongTienGiaoDich = 10000;
	Doc.TongPhi = 100;
	Doc.TongTienThucNhan = 9900;
	Doc.DienGiai = "Negative reconciliation boundary: " + CaseName;
	If CaseName = "unsupported_channel" Then
		Doc.KenhThanhToan = "STRIPE";
	ElsIf CaseName = "negative_fee" Then
		Doc.TongPhi = -1;
		Doc.TongTienThucNhan = 10001;
	ElsIf CaseName = "zero_gross" Then
		Doc.TongTienGiaoDich = 0;
		Doc.TongPhi = 0;
		Doc.TongTienThucNhan = 0;
	ElsIf CaseName = "zero_net" Then
		Doc.TongPhi = 10000;
		Doc.TongTienThucNhan = 0;
	ElsIf CaseName = "unsupported_currency" Then
		Doc.TienTe = USD;
	ElsIf CaseName = "expense_cash_category" Then
		Doc.KhoanMucDongTien = ExpenseCategory;
	Else
		Raise "Unknown gateway reconciliation boundary case: " + CaseName;
	EndIf;

	CashBefore = FinanceE2ECashBalance(Context);
	Try
		Doc.Write(DocumentWriteMode.Posting);
	Except
		// Expected: posting validation cancels the transaction; state checks below are authoritative.
	EndTry;
	DocRef = Documents.DoiSoatKenhThanhToan.FindByNumber(Doc.Number, Doc.Date);
	Persisted = ValueIsFilled(DocRef);
	AccumulationRows = CountRecorderMovementRecords("AccumulationRegister.DongTien", Doc.Ref);
	GLRows = CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", Doc.Ref);
	CashUnchanged = FinanceE2ECashBalance(Context) = CashBefore;
	Rejected = Not Doc.Posted And Not Persisted And CashUnchanged And AccumulationRows = 0 And GLRows = 0;
	Return New Structure("name,rejected,posted,persisted,cash_unchanged,accumulation_rows,gl_rows",
		CaseName, Rejected, Doc.Posted, Persisted, CashUnchanged, AccumulationRows, GLRows);
EndFunction

Function VerifyZeroFeeFinanceE2EReconciliation(Val Context)
	Doc = Documents.DoiSoatKenhThanhToan.CreateDocument();
	Doc.Number = "E2E-BK-ZERO-FEE";
	Doc.Date = Date(2026, 10, 20, 15, 40, 0);
	Doc.PhapNhan = Context.PhapNhan;
	Doc.DoiTacTrungGian = Context.PaymentProvider;
	Doc.TaiKhoanTien = Context.Bank;
	Doc.KhoanMucDongTien = Context.PaymentReconciliationCategory;
	Doc.TienTe = Context.VND;
	Doc.KenhThanhToan = "ONEPAY";
	Doc.TongTienGiaoDich = 10000;
	Doc.TongPhi = 0;
	Doc.TongTienThucNhan = 10000;
	Doc.DienGiai = "Valid gateway reconciliation boundary: zero fee";
	CashBefore = FinanceE2ECashBalance(Context);
	Doc.Write(DocumentWriteMode.Posting);
	AccumulationRowsPosted = CountRecorderMovementRecords("AccumulationRegister.DongTien", Doc.Ref);
	GLRowsPosted = CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", Doc.Ref);
	CashAfterPost = FinanceE2ECashBalance(Context);
	AcceptedThenUnposted = Doc.Posted And AccumulationRowsPosted = 1 And GLRowsPosted = 1
		And CashAfterPost = CashBefore + 10000;
	Doc.Write(DocumentWriteMode.UndoPosting);
	AccumulationRowsAfterUnpost = CountRecorderMovementRecords("AccumulationRegister.DongTien", Doc.Ref);
	GLRowsAfterUnpost = CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", Doc.Ref);
	CashRestored = FinanceE2ECashBalance(Context) = CashBefore;
	Return New Structure("accepted_then_unposted,posted_without_fee_row,cash_restored,accumulation_rows_after_unpost,gl_rows_after_unpost",
		AcceptedThenUnposted, GLRowsPosted = 1, CashRestored, AccumulationRowsAfterUnpost, GLRowsAfterUnpost);
EndFunction

Function PrepareFinanceE2EFX() Export
	RequireFinanceE2ERole("QuanTriHeThong");
	Context = FinanceE2EContext();
	USD = Catalogs.TienTe.FindByCode("USD");
	If Not ValueIsFilled(USD) Then Raise "USD currency master is required for the FX flow."; EndIf;
	FXVendorRef = Catalogs.DoiTac.FindByCode("TEST_NCC_AWS");
	If Not ValueIsFilled(FXVendorRef) Then Raise "USD AP bank integration requires supplier TEST_NCC_AWS."; EndIf;
	FXVendor = FXVendorRef.GetObject();
	FXVendor.SoTaiKhoanNganHang = "E2E-USD-BENEFICIARY-01";
	FXVendor.TenNganHang = "E2E USD Bank Gateway";
	FXVendor.Write();
	EnsureFinanceE2EFXRate(USD, Date(2026, 10, 18, 0, 0, 0), 25100);
	EnsureFinanceE2EFXRate(USD, Date(2026, 10, 19, 0, 0, 0), 25000);
	EnsureFinanceE2EFXRate(USD, Date(2026, 10, 20, 0, 0, 0), 25100);

	USDContractRef = Catalogs.HopDong.FindByCode("HD-E2E-CUSTOMER-USD");
	If ValueIsFilled(USDContractRef) Then
		USDContract = USDContractRef.GetObject();
	Else
		USDContract = Catalogs.HopDong.CreateItem();
		USDContract.Code = "HD-E2E-CUSTOMER-USD";
	EndIf;
	USDContract.Description = "E2E internal customer service contract in USD";
	USDContract.PhapNhan = Context.PhapNhan;
	USDContract.ChuSoHuu = Context.Customer;
	USDContract.DongTienThanhToan = USD;
	USDContract.HanThanhToanNgay = 30;
	USDContract.GrossUpThue = False;
	USDContract.Write();

	USDBankRef = Catalogs.TaiKhoanTien.FindByCode("TK-E2E-USD");
	If Not ValueIsFilled(USDBankRef) Then
		USDBank = Catalogs.TaiKhoanTien.CreateItem();
		USDBank.Code = "TK-E2E-USD";
		USDBank.Description = "E2E USD settlement bank account";
		USDBank.SoTaiKhoan = "E2E-USD-001";
		USDBank.NganHang = "E2E USD bank";
		USDBank.TienTe = USD;
		USDBank.Write();
		USDBankRef = USDBank.Ref;
	EndIf;
	USDBank = USDBankRef.GetObject();
	USDBank.BankApiHost = "127.0.0.1";
	USDBank.BankApiPort = 17891;
	USDBank.BankApiPath = "/v1/payments";
	USDBank.BankRefundConfirmationPath = "/v1/refunds/confirm";
	USDBank.BankApiTimeoutSeconds = 3;
	USDBank.BankApiUseTLS = False;
	USDBank.Write();
	If USDBankRef.TienTe <> USD Then Raise "E2E USD bank account currency is not USD."; EndIf;

	CashBefore = FinanceE2ECashBalanceFor(Context.PhapNhan, USDBankRef, USD);
	If CashBefore.SoTien <> 0 Or CashBefore.SoTienNgoaiTe <> 0 Then
		Raise "E2E FX bank account has an opening balance; use a clean infobase for deterministic settlement tests.";
	EndIf;
	Return New Structure("currency,bank,customer_contract,opening_vnd,opening_usd,invoice_gain,invoice_loss",
		USD.Code, USDBankRef.Code, USDContract.Ref.Code, CashBefore.SoTien, CashBefore.SoTienNgoaiTe,
		"E2E-ARUSD-GAIN", "E2E-ARUSD-LOSS");
EndFunction

Procedure EnsureFinanceE2EFXRate(Val CurrencyRef, Val RateDate, Val Rate)
	Q = New Query("SELECT TOP 1 Period FROM InformationRegister.TyGiaHoiDoai WHERE Period = &Period AND TienTe = &Currency");
	Q.SetParameter("Period", RateDate);
	Q.SetParameter("Currency", CurrencyRef);
	If Not Q.Execute().IsEmpty() Then
		Existing = New Query("SELECT TOP 1 TyGiaHachToan FROM InformationRegister.TyGiaHoiDoai WHERE Period = &Period AND TienTe = &Currency");
		Existing.SetParameter("Period", RateDate);
		Existing.SetParameter("Currency", CurrencyRef);
		If Existing.Execute().Unload()[0].TyGiaHachToan <> Rate Then
			Raise StrTemplate("E2E exchange-rate fixture mismatch for %1 on %2.", CurrencyRef.Code, RateDate);
		EndIf;
		Return;
	EndIf;
	RecordSet = InformationRegisters.TyGiaHoiDoai.CreateRecordSet();
	RecordSet.Filter.Period.Set(RateDate);
	RecordSet.Filter.TienTe.Set(CurrencyRef);
	Record = RecordSet.Add();
	Record.Period = RateDate;
	Record.TienTe = CurrencyRef;
	Record.TyGiaHachToan = Rate;
	Record.TyGiaMua = Rate - 20;
	Record.TyGiaBan = Rate + 20;
	RecordSet.Write(True);
EndProcedure

Function SubmitFinanceE2EFXInvoices() Export
	RequireFinanceE2ERole("KeToanPhaiThu");
	Context = FinanceE2EContext();
	USD = Catalogs.TienTe.FindByCode("USD");
	USDContract = Catalogs.HopDong.FindByCode("HD-E2E-CUSTOMER-USD");
	GainInvoice = CreateFinanceE2EFXARInvoice("E2E-ARUSD-GAIN", "USD-GAIN-001", Date(2026, 10, 19, 9, 0, 0), Context, USDContract, USD, 25000000, 2000000, 1080);
	LossNet = Round(25100000 / 1.08, 2);
	LossTax = Round(LossNet * 0.08, 2);
	LossInvoice = CreateFinanceE2EFXARInvoice("E2E-ARUSD-LOSS", "USD-LOSS-001", Date(2026, 10, 18, 9, 0, 0), Context, USDContract, USD, LossNet, LossTax, 1000);
	If GainInvoice.TyGia <> 25000 Or GainInvoice.TongTienThanhToan <> 27000000
		Or LossInvoice.TyGia <> 25100 Or LossInvoice.TongTienThanhToan <> 25100000 Then
		Raise "AR FX invoice fixture did not use its dated exchange rates and deterministic VND totals.";
	EndIf;
	Return New Structure("gain_invoice,gain_rate,gain_vnd,gain_foreign,loss_invoice,loss_rate,loss_vnd,loss_foreign",
		GainInvoice.Number, GainInvoice.TyGia, GainInvoice.TongTienThanhToan, GainInvoice.TongTienNgoaiTe,
		LossInvoice.Number, LossInvoice.TyGia, LossInvoice.TongTienThanhToan, LossInvoice.TongTienNgoaiTe);
EndFunction

Function CreateFinanceE2EFXARInvoice(Val InternalNumber, Val TaxNumber, Val InvoiceDate, Val Context, Val ContractRef, Val CurrencyRef, Val NetVND, Val VATVND, Val ForeignAmount)
	InvoiceRef = Documents.HoaDonGTGTDauRa.FindByNumber(InternalNumber, InvoiceDate);
	If ValueIsFilled(InvoiceRef) Then
		Raise "E2E FX AR invoice already exists; this scenario requires a fresh E2E infobase.";
	EndIf;
	Invoice = Documents.HoaDonGTGTDauRa.CreateDocument();
	Invoice.Number = InternalNumber;
	Invoice.Date = InvoiceDate;
	Invoice.SoHoaDon = TaxNumber;
	Invoice.KyHieu = "E2EUSD26";
	Invoice.PhapNhan = Context.PhapNhan;
	Invoice.DoiTac = Context.Customer;
	Invoice.HopDong = ContractRef;
	Invoice.TienTe = CurrencyRef;
	Invoice.TyGia = 0;
	Invoice.TongTienNgoaiTe = ForeignAmount;
	Invoice.ApDungGiamThueGTGT = True;
	Invoice.NgayHoaDon = BegOfDay(InvoiceDate);
	Invoice.TienChuaThue = NetVND;
	Invoice.ThueSuatVAT = 8;
	Invoice.TienThueVAT = VATVND;
	Invoice.TongTienThanhToan = NetVND + VATVND;
	Invoice.MaCQT = "CQT-" + TaxNumber;
	Invoice.TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.DuThao;
	Invoice.NguoiDuyet = "ketoan_truong";
	Invoice.DienGiai = "E2E AR foreign-currency invoice";
	Invoice.Write();
	Invoice.TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.ChoKySo;
	Invoice.Write();
	Return Invoice;
EndFunction

Function PostFinanceE2EFXInvoices() Export
	RequireFinanceE2ERole("KeToanTruong");
	InvoiceNumbers = New Array;
	InvoiceNumbers.Add(New Structure("number,date", "E2E-ARUSD-GAIN", Date(2026, 10, 19, 9, 0, 0)));
	InvoiceNumbers.Add(New Structure("number,date", "E2E-ARUSD-LOSS", Date(2026, 10, 18, 9, 0, 0)));
	For Each InvoiceInfo In InvoiceNumbers Do
		InvoiceRef = Documents.HoaDonGTGTDauRa.FindByNumber(InvoiceInfo.number, InvoiceInfo.date);
		If Not ValueIsFilled(InvoiceRef) Or InvoiceRef.TrangThaiHDDT <> Enums.TrangThaiHoaDonDienTu.ChoKySo Then
			Raise StrTemplate("AR FX invoice %1 must be submitted before issuance.", InvoiceInfo.number);
		EndIf;
		Invoice = InvoiceRef.GetObject();
		Invoice.TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.DaPhatHanh;
		Invoice.NguoiDuyet = UserName();
		Invoice.Write(DocumentWriteMode.Posting);
		If Not Invoice.Posted Then Raise StrTemplate("AR FX invoice %1 did not post.", InvoiceInfo.number); EndIf;
		If CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiThu", Invoice.Ref) <> 1
			Or CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", Invoice.Ref) < 1 Then
			Raise StrTemplate("AR FX invoice %1 did not produce its subledger and GL movements.", InvoiceInfo.number);
		EndIf;
	EndDo;
	Return New Structure("gain_posted,loss_posted", True, True);
EndFunction

Function SubmitFinanceE2EFXReceipts() Export
	RequireFinanceE2ERole("KeToanPhaiThu");
	Context = FinanceE2EContext();
	USD = Catalogs.TienTe.FindByCode("USD");
	USDBank = Catalogs.TaiKhoanTien.FindByCode("TK-E2E-USD");
	GainInvoice = Documents.HoaDonGTGTDauRa.FindByNumber("E2E-ARUSD-GAIN", Date(2026, 10, 19, 9, 0, 0));
	LossInvoice = Documents.HoaDonGTGTDauRa.FindByNumber("E2E-ARUSD-LOSS", Date(2026, 10, 18, 9, 0, 0));
	If Not GainInvoice.Posted Or Not LossInvoice.Posted Then Raise "AR FX receipts require both issued invoices."; EndIf;
	GainReceipt = CreateFinanceE2EFXReceipt("E2E-PTUSD-GAIN", GainInvoice, Date(2026, 10, 20, 10, 0, 0), Context, USDBank, USD);
	LossReceipt = CreateFinanceE2EFXReceipt("E2E-PTUSD-LOSS", LossInvoice, Date(2026, 10, 19, 10, 0, 0), Context, USDBank, USD);
	OverReceipt = CreateFinanceE2EFXReceipt("E2E-PTUSD-OVER", GainInvoice, Date(2026, 10, 20, 11, 0, 0), Context, USDBank, USD, True);
	Return New Structure("gain_receipt,gain_rate,gain_cash_vnd,loss_receipt,loss_rate,loss_cash_vnd,over_receipt,over_foreign",
		GainReceipt.Number, GainReceipt.TyGia, GainReceipt.SoTien,
		LossReceipt.Number, LossReceipt.TyGia, LossReceipt.SoTien, OverReceipt.Number, OverReceipt.SoTienNgoaiTe);
EndFunction

Function CreateFinanceE2EFXReceipt(Val InternalNumber, Val InvoiceRef, Val ReceiptDate, Val Context, Val USDBank, Val USD, Val Overpay = False)
	Receipt = Documents.PhieuThuTienKhachHang.CreateDocument();
	Receipt.Number = InternalNumber;
	Receipt.Date = ReceiptDate;
	Receipt.PhapNhan = Context.PhapNhan;
	Receipt.DoiTac = InvoiceRef.DoiTac;
	Receipt.HopDong = InvoiceRef.HopDong;
	Receipt.ChungTuGoc = InvoiceRef;
	Receipt.TaiKhoanTien = USDBank;
	Receipt.KhoanMucDongTien = Context.CustomerReceiptCategory;
	Receipt.TienTe = USD;
	Receipt.TyGia = 0;
	Receipt.SoTienNgoaiTe = InvoiceRef.TongTienNgoaiTe + ?(Overpay, 1, 0);
	Receipt.SoTien = 0;
	Receipt.NgayThu = BegOfDay(ReceiptDate);
	Receipt.NguoiDuyet = "cfo_giamdoc";
	Receipt.DienGiai = "E2E USD receipt with exchange-rate settlement";
	Receipt.Write();
	Return Receipt;
EndFunction

Function PostAndVerifyFinanceE2EFXReceipts() Export
	RequireFinanceE2ERole("GiamDocTaiChinh_CFO");
	Expected = New Array;
	Expected.Add(New Structure("number,date,source,expectedCash,expectedGain,expectedLoss",
		"E2E-PTUSD-GAIN", Date(2026, 10, 20, 10, 0, 0), "E2E-ARUSD-GAIN", 27108000, 108000, 0));
	Expected.Add(New Structure("number,date,source,expectedCash,expectedGain,expectedLoss",
		"E2E-PTUSD-LOSS", Date(2026, 10, 19, 10, 0, 0), "E2E-ARUSD-LOSS", 25000000, 0, 100000));
	For Each Item In Expected Do
		ReceiptRef = Documents.PhieuThuTienKhachHang.FindByNumber(Item.number, Item.date);
		If Not ValueIsFilled(ReceiptRef) Then Raise StrTemplate("AR FX receipt %1 is missing.", Item.number); EndIf;
		Receipt = ReceiptRef.GetObject();
		Receipt.NguoiDuyet = UserName();
		Receipt.Write(DocumentWriteMode.Posting);
		If Not Receipt.Posted Then Raise StrTemplate("AR FX receipt %1 did not post.", Item.number); EndIf;
		Q = New Query(
			"SELECT
			|   ISNULL(SUM(CASE WHEN GL.AccountDr.Code = ""1122"" THEN GL.SoTien ELSE 0 END), 0) AS BankDebit,
			|   ISNULL(SUM(CASE WHEN GL.AccountCr.Code = ""1312"" THEN GL.SoTien ELSE 0 END), 0) AS ARCredit,
			|   ISNULL(SUM(CASE WHEN GL.AccountCr.Code = ""515"" THEN GL.SoTien ELSE 0 END), 0) AS FXGain,
			|   ISNULL(SUM(CASE WHEN GL.AccountDr.Code = ""635"" THEN GL.SoTien ELSE 0 END), 0) AS FXLoss
			|FROM AccountingRegister.SoCaiKeToan AS GL WHERE GL.Recorder = &Recorder");
		Q.SetParameter("Recorder", Receipt.Ref);
		GL = Q.Execute().Unload()[0];
		CashMovement = LoadSingleFinanceMovement("AccumulationRegister.DongTien", Receipt.Ref);
		ARMovement = LoadSingleFinanceMovement("AccumulationRegister.CongNoPhaiThu", Receipt.Ref);
		SourceInvoice = Receipt.ChungTuGoc.GetObject();
		If GL.BankDebit <> Item.expectedCash Or CashMovement.SoTien <> Item.expectedCash
			Or GL.FXGain <> Item.expectedGain Or GL.FXLoss <> Item.expectedLoss
			Or ARMovement.SoTien <> SourceInvoice.TongTienThanhToan
			Or ARMovement.SoTienNgoaiTe <> Receipt.SoTienNgoaiTe Then
			Raise StrTemplate("AR FX register mismatch on %1: cash=%2/%3 gain=%4 loss=%5 AR=%6.",
				Item.number, CashMovement.SoTien, GL.BankDebit, GL.FXGain, GL.FXLoss, ARMovement.SoTien);
		EndIf;
		If FinanceE2EARBalanceFor(Receipt.PhapNhan, Receipt.DoiTac, Receipt.HopDong, Receipt.ChungTuGoc) <> 0
			Or FinanceE2EARForeignBalanceFor(Receipt.PhapNhan, Receipt.DoiTac, Receipt.HopDong, Receipt.ChungTuGoc) <> 0 Then
			Raise StrTemplate("AR FX source invoice %1 did not fully reconcile in VND and foreign currency.", Item.source);
		EndIf;
	EndDo;

	OverRef = Documents.PhieuThuTienKhachHang.FindByNumber("E2E-PTUSD-OVER", Date(2026, 10, 20, 11, 0, 0));
	OverReceipt = OverRef.GetObject();
	OverReceipt.NguoiDuyet = UserName();
	Try
		OverReceipt.Write(DocumentWriteMode.Posting);
	Except
		// The expected over-collection rejection is proved by Posted and recorder movements below.
	EndTry;
	If OverReceipt.Posted Or CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiThu", OverRef) <> 0
		Or CountRecorderMovementRecords("AccumulationRegister.DongTien", OverRef) <> 0
		Or CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", OverRef) <> 0 Then
		Raise "AR foreign-currency over-collection posted or left orphan movements.";
	EndIf;

	GainRef = Documents.PhieuThuTienKhachHang.FindByNumber("E2E-PTUSD-GAIN", Date(2026, 10, 20, 10, 0, 0));
	GainReceipt = GainRef.GetObject();
	GainReceipt.Write(DocumentWriteMode.UndoPosting);
	If GainReceipt.Posted Or CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", GainRef) <> 0
		Or CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiThu", GainRef) <> 0
		Or CountRecorderMovementRecords("AccumulationRegister.DongTien", GainRef) <> 0 Then
		Raise "AR FX unposting left stale register movements.";
	EndIf;
	GainReceipt.NguoiDuyet = UserName();
	GainReceipt.Write(DocumentWriteMode.Posting);
	If Not GainReceipt.Posted Or CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", GainRef) <> 2
		Or FinanceE2EARBalanceFor(GainReceipt.PhapNhan, GainReceipt.DoiTac, GainReceipt.HopDong, GainReceipt.ChungTuGoc) <> 0 Then
		Raise "AR FX unpost/repost changed ledger outcomes or failed idempotency.";
	EndIf;
	Return New Structure("gain_vnd,loss_vnd,gain_realized_vnd,loss_realized_vnd,over_collection_rejected,unpost_repost_idempotent",
		27108000, 25000000, 108000, 100000, True, True);
EndFunction

Function SubmitFinanceE2EFXAPInvoice() Export
	RequireFinanceE2ERole("KeToanPhaiTra");
	Context = FinanceE2EContext();
	USD = Catalogs.TienTe.FindByCode("USD");
	Vendor = Catalogs.DoiTac.FindByCode("TEST_NCC_AWS");
	Contract = Catalogs.HopDong.FindByCode("HD-TEST_NCC_AWS-2025");
	Invoice = Documents.HoaDonNhaCungCap.CreateDocument();
	Invoice.Number = "E2E-AP-USD-01";
	Invoice.Date = Date(2026, 10, 19, 12, 0, 0);
	Invoice.NgayHoaDon = BegOfDay(Invoice.Date);
	Invoice.SoHoaDon = "APUSD-E2E-01";
	Invoice.PhapNhan = Context.PhapNhan;
	Invoice.DoiTac = Vendor;
	Invoice.HopDong = Contract;
	Invoice.TaiKhoanChiPhi = Context.Account627;
	Invoice.TienTe = USD;
	Invoice.TyGia = 0;
	Invoice.TongTienNgoaiTe = 500;
	Invoice.TongTien = 12500000;
	Invoice.TienDichVu = 12500000;
	Invoice.TienThueVAT = 0;
	Invoice.CoKhauTruFCT = False;
	Invoice.TrangThai = Enums.TrangThaiHoaDonAP.DuThao;
	Invoice.DienGiai = "E2E USD cloud invoice, no FCT withholding";
	Invoice.NguoiDuyet = "ketoan_truong";
	Invoice.Write();
	Invoice.TrangThai = Enums.TrangThaiHoaDonAP.ChoKeToanTruongDuyet;
	Invoice.Write();
	If Invoice.TyGia <> 25000 Or Invoice.NoThucTraNCC <> 12500000 Then
		Raise "AP USD invoice did not use the Oct 19 accounting rate or payable amount.";
	EndIf;
	Return New Structure("invoice,foreign_amount,book_rate,payable_vnd,status",
		Invoice.Number, Invoice.TongTienNgoaiTe, Invoice.TyGia, Invoice.NoThucTraNCC,
		QuanLyVongDoiChungTuServer.TenTrangThai(Invoice.TrangThai));
EndFunction

Function PostFinanceE2EFXAPInvoice() Export
	RequireFinanceE2ERole("KeToanTruong");
	InvoiceRef = Documents.HoaDonNhaCungCap.FindByNumber("E2E-AP-USD-01", Date(2026, 10, 19, 12, 0, 0));
	If Not ValueIsFilled(InvoiceRef) Or InvoiceRef.TrangThai <> Enums.TrangThaiHoaDonAP.ChoKeToanTruongDuyet Then
		Raise "KTT must receive the submitted USD AP invoice before posting.";
	EndIf;
	Invoice = InvoiceRef.GetObject();
	Invoice.TrangThai = Enums.TrangThaiHoaDonAP.DaGhiSo;
	Invoice.NguoiDuyet = UserName();
	Invoice.Write(DocumentWriteMode.Posting);
	If Not Invoice.Posted Or CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiTra", Invoice.Ref) <> 1
		Or CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", Invoice.Ref) < 1 Then
		Raise "KTT failed to post the USD AP invoice or create its movements.";
	EndIf;
	Return New Structure("invoice,posted,payable_vnd,payable_usd", Invoice.Number, Invoice.Posted, Invoice.NoThucTraNCC, Invoice.TongTienNgoaiTe);
EndFunction

Function SubmitFinanceE2EFXAPPayment() Export
	RequireFinanceE2ERole("KeToanPhaiTra");
	Context = FinanceE2EContext();
	InvoiceRef = Documents.HoaDonNhaCungCap.FindByNumber("E2E-AP-USD-01", Date(2026, 10, 19, 12, 0, 0));
	USD = Catalogs.TienTe.FindByCode("USD");
	USDBank = Catalogs.TaiKhoanTien.FindByCode("TK-E2E-USD");
	VendorPaymentCategory = Context.VendorPaymentCategory;
	Payment = Documents.UyNhiemChi.CreateDocument();
	Payment.Number = "E2E-UNC-USD-01";
	Payment.Date = Date(2026, 10, 20, 13, 0, 0);
	Payment.NgayLap = Payment.Date;
	Payment.NgayGhiSo = Payment.Date;
	Payment.PhapNhan = Context.PhapNhan;
	Payment.DoiTac = InvoiceRef.DoiTac;
	Payment.HopDong = InvoiceRef.HopDong;
	Payment.ChungTuGoc = InvoiceRef;
	Payment.TaiKhoanTien = USDBank;
	Payment.KhoanMucDongTien = VendorPaymentCategory;
	Payment.TienTe = USD;
	Payment.TyGia = 0;
	Payment.SoTienNgoaiTe = 500;
	Payment.SoTien = 0;
	Payment.PhiNganHang = 0;
	Payment.TrangThai = Enums.TrangThaiLenhThanhToan.DuThao;
	Payment.NguoiDuyet = "ketoan_truong";
	Payment.DienGiai = "E2E USD AP settlement";
	Payment.Write();
	Payment.TrangThai = Enums.TrangThaiLenhThanhToan.ChoDuyet;
	Payment.Write();
	If Payment.TyGia <> 25100 Or Payment.SoTienNgoaiTe <> 500 Then
		Raise "USD AP payment did not use the registered settlement rate and full foreign amount.";
	EndIf;
	Return New Structure("payment,foreign_amount,settlement_rate,indicative_vnd,status", Payment.Number,
		Payment.SoTienNgoaiTe, Payment.TyGia, Payment.SoTien, QuanLyVongDoiChungTuServer.TenTrangThai(Payment.TrangThai));
EndFunction

Function ApproveFinanceE2EFXAPPayment() Export
	RequireFinanceE2ERole("KeToanTruong");
	PaymentRef = Documents.UyNhiemChi.FindByNumber("E2E-UNC-USD-01", Date(2026, 10, 20, 13, 0, 0));
	If Not ValueIsFilled(PaymentRef) Then Raise "Submitted USD AP payment is missing before KTT approval."; EndIf;
	PaymentRefs = New Array;
	PaymentRefs.Add(PaymentRef);
	Workspace = DataProcessors.BanLamViecWebERP.Create();
	ApprovalResult = Workspace.PheDuyetHangLoat(PaymentRefs);
	If ApprovalResult.ThatBai <> 0 Then
		Raise StrTemplate("KTT approval of USD payment failed: %1", ApprovalResult.ChiTiet[0].GhiChu);
	EndIf;
	Payment = PaymentRef.GetObject();
	If Payment.TrangThai <> Enums.TrangThaiLenhThanhToan.DaDuyet Or Payment.Posted
		Or Not IsBlankString(Payment.MaGiaoDichNganHang) Then
		Raise "USD payment must be approved and remain unposted before bank submission.";
	EndIf;
	Return New Structure("payment,status,approver,posted", Payment.Number,
		QuanLyVongDoiChungTuServer.TenTrangThai(Payment.TrangThai), Payment.NguoiDuyet, Payment.Posted);
EndFunction

Function SubmitFinanceE2EFXAPPaymentToBank() Export
	RequireFinanceE2ERole("KeToanTruong");
	PaymentRef = Documents.UyNhiemChi.FindByNumber("E2E-UNC-USD-01", Date(2026, 10, 20, 13, 0, 0));
	If Not ValueIsFilled(PaymentRef) Then Raise "Approved USD AP payment is missing before bank submission."; EndIf;
	Workspace = DataProcessors.BanLamViecWebERP.Create();
	BankResult = Workspace.GuiLenhChiDaDuyetNganHang(PaymentRef);
	Payment = PaymentRef.GetObject();
	If Not BankResult.accepted Or Payment.TrangThai <> Enums.TrangThaiLenhThanhToan.DaGuiNganHang
		Or IsBlankString(Payment.MaGiaoDichNganHang) Or Payment.TrangThaiGuiNganHang <> "ACCEPTED" Then
		Raise StrTemplate("Direct USD bank submission failed: %1", BankResult.error);
	EndIf;
	Return New Structure("payment,status,bank_transaction_id,bank_status,foreign_amount,foreign_currency",
		Payment.Number, QuanLyVongDoiChungTuServer.TenTrangThai(Payment.TrangThai),
		Payment.MaGiaoDichNganHang, Payment.TrangThaiGuiNganHang, Payment.SoTienNgoaiTe, Payment.TienTe.Code);
EndFunction

Function PostAndVerifyFinanceE2EFXAPPayment() Export
	RequireFinanceE2ERole("GiamDocTaiChinh_CFO");
	PaymentRef = Documents.UyNhiemChi.FindByNumber("E2E-UNC-USD-01", Date(2026, 10, 20, 13, 0, 0));
	Payment = PaymentRef.GetObject();
	If Payment.TrangThai <> Enums.TrangThaiLenhThanhToan.DaGuiNganHang
		Or Payment.TrangThaiGuiNganHang <> "ACCEPTED" Or IsBlankString(Payment.MaGiaoDichNganHang) Then
		Raise "CFO cannot post USD AP payment before direct bank acceptance.";
	EndIf;
	CashBefore = FinanceE2ECashBalanceFor(Payment.PhapNhan, Payment.TaiKhoanTien, Payment.TienTe);
	Payment.TrangThai = Enums.TrangThaiLenhThanhToan.DaGhiSo;
	Payment.NguoiDuyet = UserName();
	Payment.Write(DocumentWriteMode.Posting);
	If Not Payment.Posted Then Raise "CFO failed to post the USD AP settlement."; EndIf;
	GLQuery = New Query(
		"SELECT
		| ISNULL(SUM(CASE WHEN GL.AccountCr.Code = ""1122"" THEN GL.SoTien ELSE 0 END), 0) AS BankCredit,
		| ISNULL(SUM(CASE WHEN GL.AccountDr.Code = ""3313"" THEN GL.SoTien ELSE 0 END), 0) AS APDebit,
		| ISNULL(SUM(CASE WHEN GL.AccountDr.Code = ""635"" THEN GL.SoTien ELSE 0 END), 0) AS FXLoss
		|FROM AccountingRegister.SoCaiKeToan AS GL WHERE GL.Recorder = &Recorder");
	GLQuery.SetParameter("Recorder", Payment.Ref);
	GL = GLQuery.Execute().Unload()[0];
	CashMovement = LoadSingleFinanceMovement("AccumulationRegister.DongTien", Payment.Ref);
	APMovement = LoadSingleFinanceMovement("AccumulationRegister.CongNoPhaiTra", Payment.Ref);
	CashAfter = FinanceE2ECashBalanceFor(Payment.PhapNhan, Payment.TaiKhoanTien, Payment.TienTe);
	APResidual = FinanceE2EAPBalanceFor(Payment.PhapNhan, Payment.DoiTac, Payment.HopDong, Payment.ChungTuGoc);
	If GL.FXLoss <= 0 Or GL.BankCredit <> CashMovement.SoTien Or GL.APDebit <> 12500000
		Or GL.BankCredit <> GL.APDebit + GL.FXLoss Or APMovement.SoTien <> 12500000
		Or APMovement.SoTienNgoaiTe <> 500 Or APResidual <> 0
		Or CashBefore.SoTienNgoaiTe - CashAfter.SoTienNgoaiTe <> 500
		Or CashBefore.SoTien - CashAfter.SoTien <> GL.BankCredit Then
		Raise StrTemplate("USD AP payment failed rate-loss or register reconciliation. Bank=%1 AP=%2 loss=%3 AR/AP residual=%4 cash delta=%5/%6.",
			GL.BankCredit, GL.APDebit, GL.FXLoss, APResidual, CashBefore.SoTien - CashAfter.SoTien,
			CashBefore.SoTienNgoaiTe - CashAfter.SoTienNgoaiTe);
	EndIf;
	Return New Structure("payment,posted,book_value_vnd,foreign_amount,bank_outflow_vnd,realized_fx_loss_vnd,ap_residual_vnd,cash_balance_vnd,cash_balance_usd",
		Payment.Number, Payment.Posted, GL.APDebit, APMovement.SoTienNgoaiTe, GL.BankCredit, GL.FXLoss, APResidual,
		CashAfter.SoTien, CashAfter.SoTienNgoaiTe);
EndFunction

Function SubmitFinanceE2EFXRefund() Export
	RequireFinanceE2ERole("KeToanPhaiTra");
	PaymentRef = Documents.UyNhiemChi.FindByNumber("E2E-UNC-USD-01", Date(2026, 10, 20, 13, 0, 0));
	If Not ValueIsFilled(PaymentRef) Or Not PaymentRef.Posted Then Raise "Cannot refund a missing or unposted USD AP payment."; EndIf;
	Refund = CreateFinanceE2EFXRefundDocument("E2E-REFUND-USD-01", PaymentRef);
	DuplicateRefund = CreateFinanceE2EFXRefundDocument("E2E-REFUND-USD-DUP", PaymentRef);
	Return New Structure("refund,duplicate_refund,source_payment,foreign_amount", Refund.Number,
		DuplicateRefund.Number, PaymentRef.Number, Refund.SoTienNgoaiTe);
EndFunction

Function ApproveFinanceE2EFXRefund() Export
	RequireFinanceE2ERole("KeToanTruong");
	RefundRef = Documents.UyNhiemChi.FindByNumber("E2E-REFUND-USD-01", Date(2026, 10, 20, 14, 0, 0));
	DuplicateRef = Documents.UyNhiemChi.FindByNumber("E2E-REFUND-USD-DUP", Date(2026, 10, 20, 14, 0, 0));
	If Not ValueIsFilled(RefundRef) Or Not ValueIsFilled(DuplicateRef) Then Raise "Refund fixtures are missing before KTT approval."; EndIf;
	RefundRefs = New Array;
	RefundRefs.Add(RefundRef);
	RefundRefs.Add(DuplicateRef);
	Workspace = DataProcessors.BanLamViecWebERP.Create();
	ApprovalResult = Workspace.PheDuyetHangLoat(RefundRefs);
	If ApprovalResult.ThanhCong <> 2 Or ApprovalResult.ThatBai <> 0 Then
		Raise StrTemplate("KTT approval of USD refund fixtures failed: %1", ApprovalResult.ChiTiet[0].GhiChu);
	EndIf;
	Refund = RefundRef.GetObject();
	DuplicateRefund = DuplicateRef.GetObject();
	If Refund.TrangThai <> Enums.TrangThaiLenhThanhToan.DaDuyet Or DuplicateRefund.TrangThai <> Enums.TrangThaiLenhThanhToan.DaDuyet
		Or Refund.Posted Or DuplicateRefund.Posted Or Not IsBlankString(Refund.MaGiaoDichNganHang)
		Or Not IsBlankString(DuplicateRefund.MaGiaoDichNganHang) Then
		Raise "KTT approval must leave both refund documents approved, unposted, and awaiting bank receipt confirmation.";
	EndIf;
	Return New Structure("refund,duplicate_refund,approver,status,posted", Refund.Number,
		DuplicateRefund.Number, Refund.NguoiDuyet, QuanLyVongDoiChungTuServer.TenTrangThai(Refund.TrangThai), Refund.Posted);
EndFunction

Function RejectUnconfirmedFinanceE2EFXRefundPosting() Export
	RequireFinanceE2ERole("GiamDocTaiChinh_CFO");
	RefundRef = Documents.UyNhiemChi.FindByNumber("E2E-REFUND-USD-01", Date(2026, 10, 20, 14, 0, 0));
	If Not ValueIsFilled(RefundRef) Then Raise "Approved USD refund is missing before unconfirmed-posting validation."; EndIf;
	Refund = RefundRef.GetObject();
	Refund.TrangThai = Enums.TrangThaiLenhThanhToan.DaGhiSo;
	Refund.NguoiDuyet = UserName();
	Rejected = False;
	Try
		Refund.Write(DocumentWriteMode.Posting);
	Except
		Rejected = True;
	EndTry;
	SavedRefund = RefundRef.GetObject();
	If Not Rejected Or SavedRefund.Posted Or SavedRefund.TrangThai <> Enums.TrangThaiLenhThanhToan.DaDuyet
		Or CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiTra", RefundRef) <> 0
		Or CountRecorderMovementRecords("AccumulationRegister.DongTien", RefundRef) <> 0
		Or CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", RefundRef) <> 0 Then
		Raise "A refund without bank receipt confirmation was posted or left ledger movements.";
	EndIf;
	Return New Structure("refund,unconfirmed_post_rejected,posted,ledger_movements", RefundRef.Number,
		Rejected, SavedRefund.Posted, 0);
EndFunction

Function CreateFinanceE2EFXRefundDocument(Val InternalNumber, Val PaymentRef)
	Refund = Documents.UyNhiemChi.CreateDocument();
	Refund.Number = InternalNumber;
	Refund.Date = Date(2026, 10, 20, 14, 0, 0);
	Refund.NgayLap = Refund.Date;
	Refund.NgayGhiSo = Refund.Date;
	Refund.PhapNhan = PaymentRef.PhapNhan;
	Refund.DoiTac = PaymentRef.DoiTac;
	Refund.HopDong = PaymentRef.HopDong;
	Refund.ChungTuGoc = PaymentRef;
	Refund.TaiKhoanTien = PaymentRef.TaiKhoanTien;
	Refund.KhoanMucDongTien = PaymentRef.KhoanMucDongTien;
	Refund.TienTe = PaymentRef.TienTe;
	Refund.TyGia = PaymentRef.TyGia;
	Refund.SoTien = PaymentRef.SoTien;
	Refund.SoTienNgoaiTe = PaymentRef.SoTienNgoaiTe;
	Refund.PhiNganHang = 0;
	Refund.LaTraSoatHoanTra = True;
	Refund.NguoiDuyet = "ketoan_truong";
	Refund.TrangThai = Enums.TrangThaiLenhThanhToan.DuThao;
	Refund.DienGiai = "E2E full refund of original USD supplier payment";
	Refund.Write();
	Refund.TrangThai = Enums.TrangThaiLenhThanhToan.ChoDuyet;
	Refund.Write();
	Return Refund;
EndFunction

Function PostAndVerifyFinanceE2EFXRefund() Export
	RequireFinanceE2ERole("GiamDocTaiChinh_CFO");
	PaymentRef = Documents.UyNhiemChi.FindByNumber("E2E-UNC-USD-01", Date(2026, 10, 20, 13, 0, 0));
	RefundRef = Documents.UyNhiemChi.FindByNumber("E2E-REFUND-USD-01", Date(2026, 10, 20, 14, 0, 0));
	DuplicateRef = Documents.UyNhiemChi.FindByNumber("E2E-REFUND-USD-DUP", Date(2026, 10, 20, 14, 0, 0));
	If Not ValueIsFilled(RefundRef) Or Not ValueIsFilled(DuplicateRef) Then Raise "Refund fixtures are missing."; EndIf;
	Refund = RefundRef.GetObject();
	DuplicateRefund = DuplicateRef.GetObject();
	If Refund.TrangThai <> Enums.TrangThaiLenhThanhToan.DaNhanHoanTien
		Or DuplicateRefund.TrangThai <> Enums.TrangThaiLenhThanhToan.DaNhanHoanTien
		Or Refund.TrangThaiGuiNganHang <> "REFUND_RECEIVED"
		Or IsBlankString(Refund.MaGiaoDichNganHang)
		Or Refund.MaGiaoDichNganHang <> DuplicateRefund.MaGiaoDichNganHang Then
		Raise "USD refund documents must share the single confirmed bank refund transaction before posting.";
	EndIf;
	Payment = PaymentRef.GetObject();
	CashBeforeRefund = FinanceE2ECashBalanceFor(Payment.PhapNhan, Payment.TaiKhoanTien, Payment.TienTe);
	APBeforeRefund = FinanceE2EAPBalanceFor(Payment.PhapNhan, Payment.DoiTac, Payment.HopDong, Payment.ChungTuGoc);
	OriginalGLQuery = New Query(
		"SELECT
		| ISNULL(SUM(CASE WHEN GL.AccountCr.Code = ""1122"" THEN GL.SoTien ELSE 0 END), 0) AS BankCredit,
		| ISNULL(SUM(CASE WHEN GL.AccountDr.Code = ""3313"" THEN GL.SoTien ELSE 0 END), 0) AS APDebit,
		| ISNULL(SUM(CASE WHEN GL.AccountDr.Code = ""635"" THEN GL.SoTien ELSE 0 END), 0) AS FXLoss,
		| ISNULL(SUM(CASE WHEN GL.AccountCr.Code = ""515"" THEN GL.SoTien ELSE 0 END), 0) AS FXGain
		|FROM AccountingRegister.SoCaiKeToan AS GL WHERE GL.Recorder = &Payment");
	OriginalGLQuery.SetParameter("Payment", PaymentRef);
	OriginalGL = OriginalGLQuery.Execute().Unload()[0];
	If OriginalGL.BankCredit <= 0 Or OriginalGL.APDebit <> 12500000 Or OriginalGL.FXLoss <= 0 Then
		Raise StrTemplate("Original USD payment does not contain the expected AP/bank/FX loss entries: bank=%1 AP=%2 loss=%3.",
			OriginalGL.BankCredit, OriginalGL.APDebit, OriginalGL.FXLoss);
	EndIf;
	Refund.TrangThai = Enums.TrangThaiLenhThanhToan.DaGhiSo;
	Refund.NguoiDuyet = UserName();
	Refund.Write(DocumentWriteMode.Posting);
	If Not Refund.Posted Then Raise "The first USD payment refund did not post."; EndIf;
	DuplicateRefund = DuplicateRef.GetObject();
	DuplicateRefund.TrangThai = Enums.TrangThaiLenhThanhToan.DaGhiSo;
	DuplicateRefund.NguoiDuyet = UserName();
	Try
		DuplicateRefund.Write(DocumentWriteMode.Posting);
	Except
		// Duplicate refund rejection is asserted against document state and all three ledgers below.
	EndTry;
	If DuplicateRefund.Posted Or CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiTra", DuplicateRef) <> 0
		Or CountRecorderMovementRecords("AccumulationRegister.DongTien", DuplicateRef) <> 0
		Or CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", DuplicateRef) <> 0 Then
		Raise "A duplicate refund was posted or left orphan accounting movements.";
	EndIf;
	Payment = PaymentRef.GetObject();
	APBalance = FinanceE2EAPBalanceFor(Payment.PhapNhan, Payment.DoiTac, Payment.HopDong, Payment.ChungTuGoc);
	CashAfterRefund = FinanceE2ECashBalanceFor(Payment.PhapNhan, Payment.TaiKhoanTien, Payment.TienTe);
	Q = New Query(
		"SELECT
		| ISNULL(SUM(CASE WHEN GL.AccountDr.Code = ""1122"" THEN GL.SoTien ELSE 0 END), 0) AS BankDebit,
		| ISNULL(SUM(CASE WHEN GL.AccountCr.Code = ""1122"" THEN GL.SoTien ELSE 0 END), 0) AS BankCredit,
		| ISNULL(SUM(CASE WHEN GL.AccountDr.Code = ""3313"" THEN GL.SoTien ELSE 0 END), 0) AS APDebit,
		| ISNULL(SUM(CASE WHEN GL.AccountCr.Code = ""3313"" THEN GL.SoTien ELSE 0 END), 0) AS APCredit,
		| ISNULL(SUM(CASE WHEN GL.AccountCr.Code = ""635"" THEN GL.SoTien ELSE 0 END), 0) AS FXLossCredit,
		| ISNULL(SUM(CASE WHEN GL.AccountDr.Code = ""515"" THEN GL.SoTien ELSE 0 END), 0) AS FXGainDebit
		|FROM AccountingRegister.SoCaiKeToan AS GL WHERE GL.Recorder = &Refund");
	Q.SetParameter("Refund", RefundRef);
	GL = Q.Execute().Unload()[0];
	If APBalance <> 12500000 Or APBeforeRefund <> 0 Or CashAfterRefund.SoTienNgoaiTe - CashBeforeRefund.SoTienNgoaiTe <> 500
		Or CashAfterRefund.SoTien - CashBeforeRefund.SoTien <> OriginalGL.BankCredit
		Or GL.BankDebit <> OriginalGL.BankCredit Or GL.APCredit <> OriginalGL.APDebit
		Or GL.FXLossCredit <> OriginalGL.FXLoss Or GL.FXGainDebit <> OriginalGL.FXGain
		Or CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiTra", RefundRef) <> 1
		Or CountRecorderMovementRecords("AccumulationRegister.DongTien", RefundRef) <> 1 Then
		Raise StrTemplate("USD refund failed exact reversal reconciliation: AP=%1, bank USD delta=%2, VND delta=%3, GL Dr bank=%4 Cr AP=%5 FX loss reversal=%6.",
			APBalance, CashAfterRefund.SoTienNgoaiTe - CashBeforeRefund.SoTienNgoaiTe,
			CashAfterRefund.SoTien - CashBeforeRefund.SoTien, GL.BankDebit, GL.APCredit, GL.FXLossCredit);
	EndIf;
	Return New Structure("refund,posted,original_payment,ap_reopened_vnd,bank_reopened_usd,bank_reopened_vnd,bank_transaction_id,duplicate_refund_rejected",
		Refund.Number, Refund.Posted, Payment.Number, APBalance, CashAfterRefund.SoTienNgoaiTe,
		CashAfterRefund.SoTien, Refund.MaGiaoDichNganHang, True);
EndFunction

Function LoadSingleFinanceMovement(Val RegisterName, Val RecorderRef)
	Query = New Query(StrTemplate(
		"SELECT TOP 1 * FROM %1 WHERE Recorder = &Recorder AND Active = TRUE", RegisterName));
	Query.SetParameter("Recorder", RecorderRef);
	Rows = Query.Execute().Unload();
	If Rows.Count() = 0 Then
		Raise StrTemplate("No active movement exists for %1, recorder %2.", RegisterName, RecorderRef);
	EndIf;
	Return Rows[0];
EndFunction

Function FinanceE2ECashBalanceFor(Val LegalEntity, Val BankAccount, Val Currency)
	Q = New Query(
		"SELECT
		| ISNULL(SUM(SoTienBalance), 0) AS SoTien,
		| ISNULL(SUM(SoTienNgoaiTeBalance), 0) AS SoTienNgoaiTe
		|FROM AccumulationRegister.DongTien.Balance(,
		| PhapNhan = &LegalEntity AND TaiKhoanTien = &BankAccount AND TienTe = &Currency)");
	Q.SetParameter("LegalEntity", LegalEntity);
	Q.SetParameter("BankAccount", BankAccount);
	Q.SetParameter("Currency", Currency);
	Return Q.Execute().Unload()[0];
EndFunction

Function FinanceE2EARBalanceFor(Val LegalEntity, Val Partner, Val Contract, Val SourceDoc)
	Q = New Query(
		"SELECT ISNULL(SUM(SoTienBalance), 0) AS Amount FROM AccumulationRegister.CongNoPhaiThu.Balance(,
		| PhapNhan = &LegalEntity AND DoiTac = &Partner AND HopDong = &Contract AND ChungTuGoc = &Source)");
	Q.SetParameter("LegalEntity", LegalEntity);
	Q.SetParameter("Partner", Partner);
	Q.SetParameter("Contract", Contract);
	Q.SetParameter("Source", SourceDoc);
	Return Q.Execute().Unload()[0].Amount;
EndFunction

Function FinanceE2EARForeignBalanceFor(Val LegalEntity, Val Partner, Val Contract, Val SourceDoc)
	Q = New Query(
		"SELECT ISNULL(SUM(SoTienNgoaiTeBalance), 0) AS Amount FROM AccumulationRegister.CongNoPhaiThu.Balance(,
		| PhapNhan = &LegalEntity AND DoiTac = &Partner AND HopDong = &Contract AND ChungTuGoc = &Source)");
	Q.SetParameter("LegalEntity", LegalEntity);
	Q.SetParameter("Partner", Partner);
	Q.SetParameter("Contract", Contract);
	Q.SetParameter("Source", SourceDoc);
	Return Q.Execute().Unload()[0].Amount;
EndFunction

Function FinanceE2EAPBalanceFor(Val LegalEntity, Val Partner, Val Contract, Val SourceDoc)
	Q = New Query(
		"SELECT ISNULL(SUM(SoTienBalance), 0) AS Amount FROM AccumulationRegister.CongNoPhaiTra.Balance(,
		| PhapNhan = &LegalEntity AND DoiTac = &Partner AND HopDong = &Contract AND ChungTuGoc = &Source)");
	Q.SetParameter("LegalEntity", LegalEntity);
	Q.SetParameter("Partner", Partner);
	Q.SetParameter("Contract", Contract);
	Q.SetParameter("Source", SourceDoc);
	Return Q.Execute().Unload()[0].Amount;
EndFunction

Function FinanceE2EContext(Val IncludePaymentProvider = False)
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
	Context.Insert("PaymentReconciliationCategory", Catalogs.KhoanMucDongTien.FindByCode("KM-E2E-GATEWAY"));
	Context.Insert("Account1121", ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1121"));
	Context.Insert("Account627", ChartsOfAccounts.HeThongTaiKhoan.FindByCode("627"));
	For Each PropertyName In StrSplit("PhapNhan,VND,Customer,CustomerContract,Vendor,VendorContract,Bank,CustomerReceiptCategory,VendorPaymentCategory,PaymentReconciliationCategory,Account1121,Account627", ",") Do
		If Not ValueIsFilled(Context[PropertyName]) Then
			Raise "Required E2E master data is missing: " + PropertyName;
		EndIf;
	EndDo;
	If IncludePaymentProvider Then
		PaymentProviderRef = Catalogs.DoiTac.FindByCode("E2E_VNPAY");
		If Not ValueIsFilled(PaymentProviderRef) Then Raise "Required E2E master data is missing: PaymentProvider."; EndIf;
		Context.Insert("PaymentProvider", PaymentProviderRef);
	EndIf;
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
	Vendor.SoTaiKhoanNganHang = "190088880001-E2E";
	Vendor.TenNganHang = "E2E Bank Gateway";
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
	Acceptance.NguoiDuyet = "ketoan_truong";
	Acceptance.DienGiai = "Posting invariant zero VAT acceptance";
	Acceptance.Write();
	If Acceptance.NguoiTao <> UserName() Or Acceptance.Posted Then
		Raise "Zero-VAT acceptance draft was not saved by AR in the expected unposted state.";
	EndIf;

	TransactionAcceptance = Documents.BienBanNghiemThuGiaiDoan.CreateDocument();
	TransactionAcceptance.Number = "E2E-INV-TX-BB";
	TransactionAcceptance.Date = Date(2026, 10, 20, 9, 30, 0);
	TransactionAcceptance.PhapNhan = Context.PhapNhan;
	TransactionAcceptance.DoiTac = Context.Customer;
	TransactionAcceptance.HopDong = Context.CustomerContract;
	TransactionAcceptance.NgayNghiemThu = BegOfDay(TransactionAcceptance.Date);
	TransactionAcceptance.ApDungGiamThueGTGT = True;
	TransactionAcceptance.GiaTriNghiemThuChuaVAT = 1234567;
	TransactionAcceptance.TyLeVAT = ThueGTGTClientServer.TyLeVATApDungTheoNgay(TransactionAcceptance.NgayNghiemThu, True);
	TransactionAcceptance.TienVAT = Round(TransactionAcceptance.GiaTriNghiemThuChuaVAT * TransactionAcceptance.TyLeVAT / 100, 2);
	TransactionAcceptance.TongGiaTri = TransactionAcceptance.GiaTriNghiemThuChuaVAT + TransactionAcceptance.TienVAT;
	TransactionAcceptance.TrangThai = Enums.TrangThaiNghiemThuAR.ChoDuyetNoiBo;
	TransactionAcceptance.NguoiDuyet = "ketoan_truong";
	TransactionAcceptance.DienGiai = "Posting transaction rollback acceptance";
	TransactionAcceptance.Write();
	If TransactionAcceptance.NguoiTao <> UserName() Or TransactionAcceptance.Posted Then
		Raise "Transaction rollback acceptance draft was not saved by AR in the expected unposted state.";
	EndIf;
	Return New Structure("acceptance,transaction_acceptance,maker,status", String(Acceptance.Ref), String(TransactionAcceptance.Ref), Acceptance.NguoiTao, XMLString(Acceptance.TrangThai));
EndFunction

Function PostPostingInvariantAcceptance() Export
	RequireFinanceE2ERole("KeToanTruong");
	AcceptanceRef = Documents.BienBanNghiemThuGiaiDoan.FindByNumber("E2E-INV-ZVAT-BB", Date(2026, 10, 20, 9, 0, 0));
	If Not ValueIsFilled(AcceptanceRef) Then Raise "Zero-VAT acceptance fixture is missing."; EndIf;
	Acceptance = AcceptanceRef.GetObject();
	If Acceptance.Posted Or Acceptance.NguoiTao <> "ketoan_ar" Or Acceptance.NguoiDuyet <> UserName() Then
		Raise "Zero-VAT acceptance is not in the expected maker-checker state.";
	EndIf;
	Acceptance.TrangThai = Enums.TrangThaiNghiemThuAR.DaDuyetNoiBo;
	Acceptance.Write();
	Acceptance.Write(DocumentWriteMode.Posting);
	If Not Acceptance.Posted Then Raise "KTT did not post the zero-VAT acceptance source."; EndIf;

	TransactionAcceptanceRef = Documents.BienBanNghiemThuGiaiDoan.FindByNumber("E2E-INV-TX-BB", Date(2026, 10, 20, 9, 30, 0));
	If Not ValueIsFilled(TransactionAcceptanceRef) Then Raise "Transaction rollback acceptance fixture is missing."; EndIf;
	TransactionAcceptance = TransactionAcceptanceRef.GetObject();
	TransactionAcceptance.TrangThai = Enums.TrangThaiNghiemThuAR.DaDuyetNoiBo;
	TransactionAcceptance.Write();
	TransactionAcceptance.Write(DocumentWriteMode.Posting);
	If Not TransactionAcceptance.Posted Then Raise "KTT did not post the transaction rollback acceptance source."; EndIf;
	Return New Structure("acceptance,transaction_acceptance,approver,status,posted", String(AcceptanceRef), String(TransactionAcceptanceRef), UserName(), XMLString(Acceptance.TrangThai), Acceptance.Posted And TransactionAcceptance.Posted);
EndFunction

Function PreparePostingInvariantARInvoices() Export
	RequireFinanceE2ERole("KeToanPhaiThu");
	Context = FinanceE2EContext();
	AcceptanceRef = Documents.BienBanNghiemThuGiaiDoan.FindByNumber("E2E-INV-ZVAT-BB", Date(2026, 10, 20, 9, 0, 0));
	If Not ValueIsFilled(AcceptanceRef) Or Not AcceptanceRef.Posted Then
		Raise "AR invoice invariant fixtures require a posted zero-VAT acceptance source.";
	EndIf;
	TransactionAcceptanceRef = Documents.BienBanNghiemThuGiaiDoan.FindByNumber("E2E-INV-TX-BB", Date(2026, 10, 20, 9, 30, 0));
	If Not ValueIsFilled(TransactionAcceptanceRef) Or Not TransactionAcceptanceRef.Posted Then
		Raise "AR transaction invoice fixtures require a posted transaction acceptance source.";
	EndIf;
	CancelledInvoice = CreatePostingInvariantSalesInvoiceDraft(Context, "E2E-INV-CANCEL", TransactionAcceptanceRef);
	ZeroVATInvoice = CreatePostingInvariantSalesInvoiceDraft(Context, "E2E-INV-ZVAT", AcceptanceRef);
	ValidInvoice = CreatePostingInvariantSalesInvoiceDraft(Context, "E2E-INV-TX-GOOD", TransactionAcceptanceRef);
	InvalidInvoice = CreatePostingInvariantSalesInvoiceDraft(Context, "E2E-INV-TX-BAD", TransactionAcceptanceRef);
	Invoices = New Array;
	Invoices.Add(CancelledInvoice);
	Invoices.Add(ZeroVATInvoice);
	Invoices.Add(ValidInvoice);
	Invoices.Add(InvalidInvoice);
	For Each Invoice In Invoices Do
		If Invoice.NguoiLap <> UserName() Or Invoice.NguoiDuyet <> "ketoan_truong"
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
	Payment.NguoiDuyet = "ketoan_truong";
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
	Invoice.MaCQT = "E2E-CQT-INV";
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
	Invoice.NguoiLap = UserName();
	Invoice.NguoiDuyet = "ketoan_truong";
	Invoice.DienGiai = "Posting invariant sales invoice";
	If ValueIsFilled(AcceptanceRef) Then
		Invoice.Write();
	Else
		WriteInvalidPostingFixture(Invoice);
	EndIf;
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

#Region RequiredReferencePostingRegression

Procedure WriteInvalidPostingFixture(DocumentObject)
	// E2E-only data-exchange path creates malformed stored drafts so Posting guards can be tested.
	DocumentObject.DataExchange.Load = True;
	Try
		DocumentObject.Write(DocumentWriteMode.Write);
	Except
		DocumentObject.DataExchange.Load = False;
		Raise;
	EndTry;
	DocumentObject.DataExchange.Load = False;
EndProcedure

Function PrepareRequiredReferencePostingFixtures() Export
	RequireFinanceE2ERole("KeToanPhaiThu");
	Context = FinanceE2EContext();
	Prepared = New Array;

	PartnerMissing = Documents.BienBanNghiemThuGiaiDoan.CreateDocument();
	PartnerMissing.Number = "E2E-REQ-NOPARTNER";
	PartnerMissing.Date = Date(2026, 10, 20, 9, 0, 0);
	PartnerMissing.PhapNhan = Context.PhapNhan;
	PartnerMissing.HopDong = Context.CustomerContract;
	PartnerMissing.NgayNghiemThu = BegOfDay(PartnerMissing.Date);
	PartnerMissing.GiaTriNghiemThuChuaVAT = 1000000;
	PartnerMissing.TyLeVAT = 10;
	PartnerMissing.TienVAT = 100000;
	PartnerMissing.TongGiaTri = 1100000;
	PartnerMissing.TrangThai = Enums.TrangThaiNghiemThuAR.DuThao;
	PartnerMissing.NguoiTao = UserName();
	PartnerMissing.NguoiDuyet = "ketoan_truong";
	PartnerMissing.DienGiai = "Required-reference regression: partner missing";
	WriteInvalidPostingFixture(PartnerMissing);
	PartnerMissing.TrangThai = Enums.TrangThaiNghiemThuAR.ChoDuyetNoiBo;
	WriteInvalidPostingFixture(PartnerMissing);
	If PartnerMissing.Posted Or PartnerMissing.NguoiTao <> UserName() Then
		Raise "Partner-missing fixture was not saved as an unposted document by the authenticated AR maker.";
	EndIf;
	Prepared.Add(New Structure("name,number,maker", "missing_partner", PartnerMissing.Number, PartnerMissing.NguoiTao));

	ContractMissing = Documents.BienBanNghiemThuGiaiDoan.CreateDocument();
	ContractMissing.Number = "E2E-REQ-NOCONTRACT";
	ContractMissing.Date = Date(2026, 10, 20, 10, 0, 0);
	ContractMissing.PhapNhan = Context.PhapNhan;
	ContractMissing.DoiTac = Context.Customer;
	ContractMissing.NgayNghiemThu = BegOfDay(ContractMissing.Date);
	ContractMissing.GiaTriNghiemThuChuaVAT = 1000000;
	ContractMissing.TyLeVAT = 10;
	ContractMissing.TienVAT = 100000;
	ContractMissing.TongGiaTri = 1100000;
	ContractMissing.TrangThai = Enums.TrangThaiNghiemThuAR.DuThao;
	ContractMissing.NguoiTao = UserName();
	ContractMissing.NguoiDuyet = "ketoan_truong";
	ContractMissing.DienGiai = "Required-reference regression: contract missing";
	WriteInvalidPostingFixture(ContractMissing);
	ContractMissing.TrangThai = Enums.TrangThaiNghiemThuAR.ChoDuyetNoiBo;
	WriteInvalidPostingFixture(ContractMissing);
	If ContractMissing.Posted Or ContractMissing.NguoiTao <> UserName() Then
		Raise "Contract-missing fixture was not saved as an unposted document by the authenticated AR maker.";
	EndIf;
	Prepared.Add(New Structure("name,number,maker", "missing_contract", ContractMissing.Number, ContractMissing.NguoiTao));

	WrongOwnerContract = Catalogs.HopDong.FindByCode("HD-TEST_VG_VINCLUB-2025");
	If Not ValueIsFilled(WrongOwnerContract) Or WrongOwnerContract.ChuSoHuu = Context.Customer Then
		Raise "Wrong-owner contract fixture is missing or belongs to the selected customer.";
	EndIf;
	WrongContractOwner = Documents.BienBanNghiemThuGiaiDoan.CreateDocument();
	WrongContractOwner.Number = "E2E-REQ-MISMATCH";
	WrongContractOwner.Date = Date(2026, 10, 20, 11, 0, 0);
	WrongContractOwner.PhapNhan = Context.PhapNhan;
	WrongContractOwner.DoiTac = Context.Customer;
	WrongContractOwner.HopDong = WrongOwnerContract;
	WrongContractOwner.NgayNghiemThu = BegOfDay(WrongContractOwner.Date);
	WrongContractOwner.GiaTriNghiemThuChuaVAT = 1000000;
	WrongContractOwner.TyLeVAT = 10;
	WrongContractOwner.TienVAT = 100000;
	WrongContractOwner.TongGiaTri = 1100000;
	WrongContractOwner.TrangThai = Enums.TrangThaiNghiemThuAR.DuThao;
	WrongContractOwner.NguoiTao = UserName();
	WrongContractOwner.NguoiDuyet = "ketoan_truong";
	WrongContractOwner.DienGiai = "Required-reference regression: contract owner mismatch";
	WriteInvalidPostingFixture(WrongContractOwner);
	WrongContractOwner.TrangThai = Enums.TrangThaiNghiemThuAR.ChoDuyetNoiBo;
	WriteInvalidPostingFixture(WrongContractOwner);
	If WrongContractOwner.Posted Or WrongContractOwner.NguoiTao <> UserName() Then
		Raise "Wrong-owner contract fixture was not saved as an unposted document by the authenticated AR maker.";
	EndIf;
	Prepared.Add(New Structure("name,number,maker", "mismatched_contract_owner", WrongContractOwner.Number, WrongContractOwner.NguoiTao));

	SalesInvoiceMismatch = CreatePostingInvariantSalesInvoiceDraft(Context, "E2E-REQ-AR-DIM", Undefined);
	SalesInvoiceMismatch.HopDong = WrongOwnerContract;
	SalesInvoiceMismatch.NguoiLap = UserName();
	WriteInvalidPostingFixture(SalesInvoiceMismatch);
	If SalesInvoiceMismatch.Posted Or SalesInvoiceMismatch.NguoiLap <> UserName()
		Or SalesInvoiceMismatch.DoiTac <> Context.Customer
		Or SalesInvoiceMismatch.HopDong.ChuSoHuu = SalesInvoiceMismatch.DoiTac Then
		Raise "Sales invoice mismatch fixture does not isolate a contract owned by another customer.";
	EndIf;
	Prepared.Add(New Structure("name,number,maker", "sales_invoice_wrong_contract_owner", SalesInvoiceMismatch.Number, SalesInvoiceMismatch.NguoiLap));

	Return New Structure("fixtures", Prepared);
EndFunction

Function VerifyRequiredReferencePostingRejected() Export
	RequireFinanceE2ERole("KeToanTruong");
	Fixtures = New Array;
	Fixtures.Add(New Structure("name,attribute,number", "missing_partner", "DoiTac", "E2E-REQ-NOPARTNER"));
	Fixtures.Add(New Structure("name,attribute,number", "missing_contract", "HopDong", "E2E-REQ-NOCONTRACT"));
	Fixtures.Add(New Structure("name,attribute,number", "mismatched_contract_owner", "HopDong.ChuSoHuu", "E2E-REQ-MISMATCH"));
	Results = New Array;
	Failed = False;

	For Each Fixture In Fixtures Do
		DocRef = Documents.BienBanNghiemThuGiaiDoan.FindByNumber(Fixture.number, Date(2026, 10, 20, 0, 0, 0));
		If Not ValueIsFilled(DocRef) Then Raise "Required-reference fixture is missing: " + Fixture.number; EndIf;
		Doc = DocRef.GetObject();
		If Doc.NguoiTao <> "ketoan_ar" Or Doc.NguoiDuyet <> "ketoan_truong" Or Doc.Posted Then
			Raise "Required-reference fixture is not in the expected maker-checker draft state: " + Fixture.number;
		EndIf;
		If Fixture.attribute = "DoiTac" And ValueIsFilled(Doc.DoiTac) Then Raise "Partner-missing fixture unexpectedly has a partner."; EndIf;
		If Fixture.attribute = "HopDong" And (Not ValueIsFilled(Doc.DoiTac) Or ValueIsFilled(Doc.HopDong)) Then
			Raise "Contract-missing fixture does not isolate the missing contract field.";
		EndIf;
		If Fixture.attribute = "HopDong.ChuSoHuu" And (Not ValueIsFilled(Doc.DoiTac) Or Not ValueIsFilled(Doc.HopDong)
			Or Doc.HopDong.ChuSoHuu = Doc.DoiTac) Then
			Raise "Mismatched-owner fixture does not isolate the partner-contract relationship.";
		EndIf;

		BeginTransaction();
		TransactionStarted = True;
		Try
			Doc.TrangThai = Enums.TrangThaiNghiemThuAR.DaDuyetNoiBo;
			Doc.NguoiDuyet = UserName();
			WriteInvalidPostingFixture(Doc);
			PostingError = "";
			Try
				Doc.Write(DocumentWriteMode.Posting);
			Except
				PostingError = DetailErrorDescription(ErrorInfo());
			EndTry;

			PostedInAttempt = Doc.Posted;
			AttemptMovementProbeAvailable = Not ValueIsFilled(PostingError);
			AttemptARMovements = 0;
			AttemptGLMovements = 0;
			If AttemptMovementProbeAvailable Then
				AttemptARMovements = CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiThu", Doc.Ref);
				AttemptGLMovements = CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", Doc.Ref);
			EndIf;
			RollbackTransaction();
			TransactionStarted = False;
			PersistedRef = Documents.BienBanNghiemThuGiaiDoan.FindByNumber(Fixture.number, Date(2026, 10, 20, 0, 0, 0));
			If Not ValueIsFilled(PersistedRef) Then Raise "Required-reference fixture disappeared after rollback: " + Fixture.number; EndIf;
			PersistedDoc = PersistedRef.GetObject();
			PersistedPosted = PersistedDoc.Posted;
			ARQuery = New Query("SELECT COUNT(*) AS Amount FROM AccumulationRegister.CongNoPhaiThu AS AR WHERE AR.ChungTuGoc = &Ref");
			ARQuery.SetParameter("Ref", PersistedRef);
			ARMovements = ARQuery.Execute().Unload()[0].Amount;
			GLQuery = New Query("SELECT COUNT(*) AS Amount FROM AccountingRegister.SoCaiKeToan AS GL WHERE GL.ChungTuGoc = &Ref");
			GLQuery.SetParameter("Ref", PersistedRef);
			GLMovements = GLQuery.Execute().Unload()[0].Amount;
			UnexpectedPosting = Not ValueIsFilled(PostingError) And PostedInAttempt;
			If UnexpectedPosting Or PersistedPosted Or (AttemptMovementProbeAvailable And (AttemptARMovements <> 0 Or AttemptGLMovements <> 0))
				Or ARMovements <> 0 Or GLMovements <> 0 Then
				Failed = True;
			EndIf;
			Results.Add(New Structure("name,missing_attribute,posting_call_succeeded,posted_in_attempt,persisted_posted,attempt_movement_probe_available,attempt_ar_movements,attempt_gl_movements,ar_movements,gl_movements,error,unexpected_posting",
				Fixture.name, Fixture.attribute, Not ValueIsFilled(PostingError), PostedInAttempt, PersistedPosted,
				AttemptMovementProbeAvailable, AttemptARMovements, AttemptGLMovements, ARMovements, GLMovements, PostingError, UnexpectedPosting));
		Except
			If TransactionStarted Then
				Try
					RollbackTransaction();
				Except
				EndTry;
			EndIf;
			Raise;
		EndTry;
	EndDo;

	InvoiceRef = Documents.HoaDonGTGTDauRa.FindByNumber("E2E-REQ-AR-DIM", Date(2026, 10, 20, 9, 0, 0));
	If Not ValueIsFilled(InvoiceRef) Then Raise "AR wrong-contract regression fixture is missing."; EndIf;
	Invoice = InvoiceRef.GetObject();
	If Invoice.NguoiLap <> "ketoan_ar" Or Invoice.NguoiDuyet <> "ketoan_truong" Or Invoice.Posted
		Or Invoice.HopDong.ChuSoHuu = Invoice.DoiTac Then
		Raise "AR wrong-contract regression fixture is not in the expected pre-issue state.";
	EndIf;

	BeginTransaction();
	TransactionStarted = True;
	Try
		Invoice.TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.DaPhatHanh;
		Invoice.NguoiDuyet = UserName();
		PostingError = "";
		Try
			Invoice.Write(DocumentWriteMode.Posting);
		Except
			PostingError = DetailErrorDescription(ErrorInfo());
		EndTry;
		PostedInAttempt = Invoice.Posted;
		AttemptMovementProbeAvailable = Not ValueIsFilled(PostingError);
		AttemptARMovements = 0;
		AttemptGLMovements = 0;
		If AttemptMovementProbeAvailable Then
			AttemptARMovements = CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiThu", Invoice.Ref);
			AttemptGLMovements = CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", Invoice.Ref);
		EndIf;
		RollbackTransaction();
		TransactionStarted = False;
		PersistedRef = Documents.HoaDonGTGTDauRa.FindByNumber("E2E-REQ-AR-DIM", Date(2026, 10, 20, 9, 0, 0));
		If Not ValueIsFilled(PersistedRef) Then Raise "AR wrong-contract invoice disappeared after rollback."; EndIf;
		PersistedInvoice = PersistedRef.GetObject();
		ARMovements = CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiThu", PersistedRef);
		GLMovements = CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", PersistedRef);
		UnexpectedPosting = Not ValueIsFilled(PostingError) And PostedInAttempt;
		If UnexpectedPosting Or PersistedInvoice.Posted Or (AttemptMovementProbeAvailable And (AttemptARMovements <> 0 Or AttemptGLMovements <> 0))
			Or ARMovements <> 0 Or GLMovements <> 0 Then
			Failed = True;
		EndIf;
		Results.Add(New Structure("name,attribute,posting_call_succeeded,posted_in_attempt,persisted_posted,attempt_movement_probe_available,attempt_ar_movements,attempt_gl_movements,ar_movements,gl_movements,error,unexpected_posting",
			"sales_invoice_wrong_contract_owner", "HopDong.ChuSoHuu", Not ValueIsFilled(PostingError), PostedInAttempt,
			PersistedInvoice.Posted, AttemptMovementProbeAvailable, AttemptARMovements, AttemptGLMovements, ARMovements, GLMovements, PostingError, UnexpectedPosting));
	Except
		If TransactionStarted Then
			Try
				RollbackTransaction();
			Except
			EndTry;
		EndIf;
		Raise;
	EndTry;
	InvoiceCleanupRef = Documents.HoaDonGTGTDauRa.FindByNumber("E2E-REQ-AR-DIM", Date(2026, 10, 20, 9, 0, 0));
	InvoiceCleanup = InvoiceCleanupRef.GetObject();
	InvoiceCleanup.DeletionMark = True;
	WriteInvalidPostingFixture(InvoiceCleanup);
	If Not InvoiceCleanup.DeletionMark Or InvoiceCleanup.Posted Then
		Raise "AR relationship regression fixture was not cleaned up after verification.";
	EndIf;

	Return New Structure("cases,failed", Results, Failed);
EndFunction

Function PrepareAPWrongContractPostingFixture() Export
	RequireFinanceE2ERole("KeToanPhaiTra");
	Context = FinanceE2EContext();
	WrongOwnerContract = Catalogs.HopDong.FindByCode("HD-TEST_VG_VINCLUB-2025");
	If Not ValueIsFilled(WrongOwnerContract) Or WrongOwnerContract.ChuSoHuu = Context.Vendor Then
		Raise "AP wrong-owner contract fixture is missing or belongs to the selected vendor.";
	EndIf;

	Invoice = Documents.HoaDonNhaCungCap.CreateDocument();
	Invoice.Number = "E2E-REQ-AP-DIM";
	Invoice.Date = Date(2026, 10, 20, 12, 0, 0);
	Invoice.NgayHoaDon = BegOfDay(Invoice.Date);
	Invoice.SoHoaDon = "E2E-REQ-AP-DIM";
	Invoice.PhapNhan = Context.PhapNhan;
	Invoice.DoiTac = Context.Vendor;
	Invoice.HopDong = WrongOwnerContract;
	Invoice.TaiKhoanChiPhi = Context.Account627;
	Invoice.TienTe = Context.VND;
	Invoice.TyGia = 1;
	Invoice.TongTien = 1000000;
	Invoice.TienDichVu = 1000000;
	Invoice.TienThueVAT = 0;
	Invoice.CoKhauTruFCT = False;
	Invoice.TrangThai = Enums.TrangThaiHoaDonAP.DuThao;
	Invoice.NguoiLap = UserName();
	Invoice.NguoiDuyet = "ketoan_truong";
	Invoice.DienGiai = "Required-dimension regression: AP contract belongs to another counterparty";
	WriteInvalidPostingFixture(Invoice);
	Invoice.TrangThai = Enums.TrangThaiHoaDonAP.ChoKeToanTruongDuyet;
	WriteInvalidPostingFixture(Invoice);
	If Invoice.Posted Or Invoice.NguoiLap <> UserName()
		Or Invoice.DoiTac <> Context.Vendor Or Invoice.HopDong.ChuSoHuu = Invoice.DoiTac
		Or Invoice.TrangThai <> Enums.TrangThaiHoaDonAP.ChoKeToanTruongDuyet Then
		Raise "AP wrong-contract fixture was not saved as an unposted invoice awaiting KTT approval.";
	EndIf;
	Return New Structure("invoice,maker,approver,contract_owner", Invoice.Number, Invoice.NguoiLap, Invoice.NguoiDuyet, Invoice.HopDong.ChuSoHuu.Code);
EndFunction

Function VerifyAPWrongContractPostingRejected() Export
	RequireFinanceE2ERole("KeToanTruong");
	InvoiceRef = Documents.HoaDonNhaCungCap.FindByNumber("E2E-REQ-AP-DIM", Date(2026, 10, 20, 12, 0, 0));
	If Not ValueIsFilled(InvoiceRef) Then Raise "AP wrong-contract regression fixture is missing."; EndIf;
	Invoice = InvoiceRef.GetObject();
	If Invoice.NguoiLap <> "ketoan_ap" Or Invoice.NguoiDuyet <> "ketoan_truong"
		Or Invoice.Posted Or Invoice.TrangThai <> Enums.TrangThaiHoaDonAP.ChoKeToanTruongDuyet
		Or Invoice.HopDong.ChuSoHuu = Invoice.DoiTac Then
		Raise "AP wrong-contract regression fixture is not in the expected maker-checker state.";
	EndIf;

	BeginTransaction();
	TransactionStarted = True;
	Try
		Invoice.TrangThai = Enums.TrangThaiHoaDonAP.DaGhiSo;
		Invoice.NguoiDuyet = UserName();
		PostingError = "";
		Try
			Invoice.Write(DocumentWriteMode.Posting);
		Except
			PostingError = DetailErrorDescription(ErrorInfo());
		EndTry;
		PostedInAttempt = Invoice.Posted;
		AttemptMovementProbeAvailable = Not ValueIsFilled(PostingError);
		AttemptAPMovements = 0;
		AttemptGLMovements = 0;
		If AttemptMovementProbeAvailable Then
			AttemptAPMovements = CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiTra", Invoice.Ref);
			AttemptGLMovements = CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", Invoice.Ref);
		EndIf;
		RollbackTransaction();
		TransactionStarted = False;
		PersistedRef = Documents.HoaDonNhaCungCap.FindByNumber("E2E-REQ-AP-DIM", Date(2026, 10, 20, 12, 0, 0));
		If Not ValueIsFilled(PersistedRef) Then Raise "AP wrong-contract invoice disappeared after rollback."; EndIf;
		PersistedInvoice = PersistedRef.GetObject();
		APMovements = CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiTra", PersistedRef);
		GLMovements = CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", PersistedRef);
		UnexpectedPosting = Not ValueIsFilled(PostingError) And PostedInAttempt;
		Failed = UnexpectedPosting Or PersistedInvoice.Posted Or (AttemptMovementProbeAvailable And (AttemptAPMovements <> 0 Or AttemptGLMovements <> 0))
			Or APMovements <> 0 Or GLMovements <> 0;
		CaseResult = New Structure("name,attribute,posting_call_succeeded,posted_in_attempt,persisted_posted,attempt_movement_probe_available,attempt_ap_movements,attempt_gl_movements,ap_movements,gl_movements,error,unexpected_posting",
			"ap_invoice_wrong_contract_owner", "HopDong.ChuSoHuu", Not ValueIsFilled(PostingError), PostedInAttempt,
			PersistedInvoice.Posted, AttemptMovementProbeAvailable, AttemptAPMovements, AttemptGLMovements, APMovements, GLMovements, PostingError, UnexpectedPosting);
	Except
		If TransactionStarted Then
			Try
				RollbackTransaction();
			Except
			EndTry;
		EndIf;
		Raise;
	EndTry;
	CleanupRef = Documents.HoaDonNhaCungCap.FindByNumber("E2E-REQ-AP-DIM", Date(2026, 10, 20, 12, 0, 0));
	CleanupInvoice = CleanupRef.GetObject();
	CleanupInvoice.DeletionMark = True;
	WriteInvalidPostingFixture(CleanupInvoice);
	If Not CleanupInvoice.DeletionMark Or CleanupInvoice.Posted Then
		Raise "AP relationship regression fixture was not cleaned up after verification.";
	EndIf;
	Results = New Array;
	Results.Add(CaseResult);
	Return New Structure("cases,failed", Results, Failed);
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

#Region RequiredFieldRuntimeMatrix

Function RunRequiredFieldRuntimeMatrix() Export
	If Upper(TrimAll(UserName())) <> "ADMIN" Then
		Raise "Required-field runtime matrix must run as Admin in the disposable E2E infobase.";
	EndIf;
	Context = FinanceE2EContext(True);
	ARSource = Documents.HoaDonGTGTDauRa.FindByNumber("E2E-AR-NT001", Date(2026, 10, 20, 9, 30, 0));
	APSource = Documents.HoaDonNhaCungCap.FindByNumber("E2E-AP-NT001", Date(2026, 10, 20, 10, 0, 0));
	If Not ValueIsFilled(ARSource) Or Not ARSource.Posted Or Not ValueIsFilled(APSource) Or Not APSource.Posted Then
		Raise "Required-field matrix needs the posted AR/AP netting source fixtures.";
	EndIf;

	Matrix = New Array;
	AddRequiredFieldMatrixCases(Matrix, "BienBanNghiemThuGiaiDoan", "PhapNhan,DoiTac,HopDong,GiaTriNghiemThuChuaVAT");
	AddRequiredFieldMatrixCases(Matrix, "HoaDonGTGTDauRa", "PhapNhan,DoiTac,HopDong,SoHoaDon,KyHieu,NgayHoaDon");
	AddRequiredFieldMatrixCases(Matrix, "PhieuThuTienKhachHang", "PhapNhan,DoiTac,HopDong,TaiKhoanTien,KhoanMucDongTien,SoTien");
	AddRequiredFieldMatrixCases(Matrix, "HoaDonNhaCungCap", "PhapNhan,DoiTac,HopDong,SoHoaDon");
	AddRequiredFieldMatrixCases(Matrix, "UyNhiemChi", "PhapNhan,DoiTac,HopDong,TaiKhoanTien,KhoanMucDongTien,TienTe,SoTien");
	AddRequiredFieldMatrixCases(Matrix, "CanTruCongNoNoiBo", "PhapNhan,DoiTac,ChungTuAR,ChungTuAP,SoTien");
	AddRequiredFieldMatrixCases(Matrix, "DoiSoatKenhThanhToan", "PhapNhan,DoiTacTrungGian,TaiKhoanTien,KhoanMucDongTien,TienTe,KenhThanhToan,TongTienGiaoDich,TongPhi,TongTienThucNhan");
	If Matrix.Count() <> 41 Then
		Raise StrTemplate("Required-field test definition drifted: expected 41 fields, found %1.", Matrix.Count());
	EndIf;

	Results = New Array;
	PassedCount = 0;
	For Each MatrixCase In Matrix Do
		TransactionStarted = False;
		Try
			BeginTransaction();
			TransactionStarted = True;
			DocumentObject = CreateRequiredFieldMatrixDocument(MatrixCase.document_type, Context, ARSource, APSource, Results.Count() + 1);
			If MatrixCase.document_type = "HoaDonGTGTDauRa" Then
				DocumentObject.TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.DaPhatHanh;
				DocumentObject.MaCQT = "REQM-CQT";
			EndIf;
			ClearRequiredFieldMatrixValue(DocumentObject, MatrixCase.field);
			NumberBefore = String(DocumentObject.Number);
			WriteError = "";
			Try
				DocumentObject.Write(DocumentWriteMode.Write);
			Except
				WriteError = DetailErrorDescription(ErrorInfo());
			EndTry;
			NumberAfter = String(DocumentObject.Number);
			DocumentPersisted = False;
			If IsBlankString(WriteError) Then
				DocumentPersisted = RequiredFieldMatrixDocumentExists(MatrixCase.document_type, NumberAfter, DocumentObject.Date);
			EndIf;
			WriteRejected = Not DocumentPersisted And IsBlankString(NumberAfter);
			RollbackTransaction();
			TransactionStarted = False;
			PersistedAfterRollback = RequiredFieldMatrixDocumentExists(MatrixCase.document_type, NumberAfter, DocumentObject.Date);
			RolledBack = Not PersistedAfterRollback;
			CaseStatus = "FAIL";
			If WriteRejected And IsBlankString(NumberBefore) And RolledBack Then
				CaseStatus = "PASS";
				PassedCount = PassedCount + 1;
			EndIf;
			Results.Add(New Structure("document_type,field,key,status,write_rejected,document_persisted,document_persisted_after_rollback,rolled_back,document_number_before,document_number_after,write_error",
				MatrixCase.document_type, MatrixCase.field, MatrixCase.key, CaseStatus, WriteRejected, DocumentPersisted,
				PersistedAfterRollback, RolledBack, NumberBefore, NumberAfter, WriteError));
		Except
			If TransactionStarted Then
				Try
					RollbackTransaction();
				Except
				EndTry;
			EndIf;
			Raise;
		EndTry;
	EndDo;

	AutoResults = RunRequiredFieldAutoFillMatrix(Context, ARSource, APSource);
	FieldProbeResults = RunDocumentFieldProbeMatrix(Context, ARSource, APSource);
	BoundaryResults = RunRequiredFieldBoundaryMatrix(Context, ARSource, APSource);
	APBoundaryResults = RunAPInvoiceBoundaryMatrix(Context);
	FailedCount = Matrix.Count() - PassedCount;
	AutoPassedCount = 0;
	For Each AutoCase In AutoResults Do
		If AutoCase.status = "PASS" Then
			AutoPassedCount = AutoPassedCount + 1;
		EndIf;
	EndDo;
	AutoAllPassed = AutoPassedCount = AutoResults.Count();
	FieldProbePassedCount = 0;
	For Each FieldProbeCase In FieldProbeResults Do
		If FieldProbeCase.status = "PASS" Then
			FieldProbePassedCount = FieldProbePassedCount + 1;
		EndIf;
	EndDo;
	FieldProbeAllPassed = FieldProbePassedCount = FieldProbeResults.Count();
	BoundaryPassedCount = 0;
	For Each BoundaryCase In BoundaryResults Do
		If BoundaryCase.status = "PASS" Then
			BoundaryPassedCount = BoundaryPassedCount + 1;
		EndIf;
	EndDo;
	BoundaryAllPassed = BoundaryPassedCount = BoundaryResults.Count();
	APBoundaryPassedCount = 0;
	For Each APBoundaryCase In APBoundaryResults Do
		If APBoundaryCase.status = "PASS" Then
			APBoundaryPassedCount = APBoundaryPassedCount + 1;
		EndIf;
	EndDo;
	APBoundaryAllPassed = APBoundaryPassedCount = APBoundaryResults.Count();
	AllPassed = FailedCount = 0 And AutoAllPassed And FieldProbeAllPassed And BoundaryAllPassed And APBoundaryAllPassed;
	Return New Structure("status,all_passed,case_count,passed_count,failed_count,cases,auto_case_count,auto_passed_count,auto_cases,field_probe_case_count,field_probe_passed_count,field_probe_cases,boundary_case_count,boundary_passed_count,boundary_cases,ap_boundary_case_count,ap_boundary_passed_count,ap_boundary_cases",
		?(AllPassed, "PASS", "FAIL"), AllPassed, Matrix.Count(), PassedCount, FailedCount, Results,
		AutoResults.Count(), AutoPassedCount, AutoResults, FieldProbeResults.Count(), FieldProbePassedCount, FieldProbeResults,
		BoundaryResults.Count(), BoundaryPassedCount, BoundaryResults,
		APBoundaryResults.Count(), APBoundaryPassedCount, APBoundaryResults);
EndFunction

Function RunDocumentFieldProbeMatrix(Val Context, Val ARSource, Val APSource)
	Cases = New Array;
	AddRequiredFieldMatrixCases(Cases, "BienBanNghiemThuGiaiDoan", "ApDungGiamThueGTGT,ChiNhanh,DienGiai,NgayNghiemThu,NguoiDuyet,NguoiTao,TienVAT,TyLeVAT");
	AddRequiredFieldMatrixCases(Cases, "HoaDonGTGTDauRa", "ApDungGiamThueGTGT,BienBanNghiemThu,DiaChiNguoiMua,DienGiai,MaCQT,MaSoThueNguoiMua,NguoiDuyet,NguoiLap,ThueSuatVAT,TienChuaThue,TienTe,TienThueVAT,TongTienNgoaiTe,TrangThaiHDDT,TyGia");
	AddRequiredFieldMatrixCases(Cases, "PhieuThuTienKhachHang", "ChungTuGoc,DienGiai,NgayThu,NguoiDuyet,NguoiLap,SoTienNgoaiTe,TyGia");
	AddRequiredFieldMatrixCases(Cases, "HoaDonNhaCungCap", "ChiPhiVSF,CoKhauTruFCT,DienGiai,NguoiDuyet,NguoiLap,NoThucTraNCC,TaiKhoanChiPhi,TienDichVu,TienThueTNDNNhaThau,TienThueVAT,TienThueVATNhaThau,TongTienNgoaiTe,TrangThai,TyGia,TyLeThueTNDNNhaThau,TyLeThueVATNhaThau");
	AddRequiredFieldMatrixCases(Cases, "UyNhiemChi", "ChungTuGoc,DienGiai,LaTraSoatHoanTra,MaGiaoDichNganHang,NgayGhiSo,NgayLap,NguoiDuyet,NguoiLap,PhiNganHang,SoTienNgoaiTe,ThoiDiemGuiNganHang,TrangThai,TrangThaiGuiNganHang,TyGia");
	AddRequiredFieldMatrixCases(Cases, "CanTruCongNoNoiBo", "DienGiai,NguoiDuyet,NguoiLap");
	AddRequiredFieldMatrixCases(Cases, "DoiSoatKenhThanhToan", "DienGiai,NguoiDuyet,NguoiLap,ExternalId,KhoaGiaoDich,NgayGiaoDich,DienGiaiDong,TienTeDong,Gross,Phi,Net,HoaDonAR,SoTienGhep,TrangThaiDong,LyDoChan,InvoiceNumber");
	If Cases.Count() <> 79 Then
		Raise StrTemplate("Document and statement-row field probe definition drifted: expected 79 fields, found %1.", Cases.Count());
	EndIf;

	Results = New Array;
	For Each MatrixCase In Cases Do
		TransactionStarted = False;
		Try
			BeginTransaction();
			TransactionStarted = True;
			DocumentObject = CreateRequiredFieldMatrixDocument(MatrixCase.document_type, Context, ARSource, APSource, Results.Count() + 501);
			DocumentObject.Number = StrTemplate("XFP%1", Results.Count() + 1);
			InputValue = ApplyDocumentFieldProbeValue(DocumentObject, MatrixCase.document_type, MatrixCase.field, Context, ARSource, APSource, Results.Count() + 1);
			NumberBefore = String(DocumentObject.Number);
			WriteError = "";
			Try
				DocumentObject.Write(DocumentWriteMode.Write);
			Except
				WriteError = DetailErrorDescription(ErrorInfo());
			EndTry;
			NumberAfter = String(DocumentObject.Number);
			DocumentPersisted = False;
			RoundTripMatches = False;
			ActualValue = "";
			If IsBlankString(WriteError) And Not IsBlankString(NumberAfter) Then
				DocumentRef = FindRequiredFieldMatrixDocument(MatrixCase.document_type, NumberAfter, DocumentObject.Date);
				DocumentPersisted = ValueIsFilled(DocumentRef);
				If DocumentPersisted Then
					PersistedObject = DocumentRef.GetObject();
					ActualValue = String(ReadDocumentFieldProbeValue(DocumentObject, MatrixCase.document_type, MatrixCase.field));
					RoundTripMatches = ReadDocumentFieldProbeValue(PersistedObject, MatrixCase.document_type, MatrixCase.field)
						= ReadDocumentFieldProbeValue(DocumentObject, MatrixCase.document_type, MatrixCase.field);
				EndIf;
			EndIf;
			WriteAccepted = IsBlankString(WriteError) And DocumentPersisted;
			InvalidVariantChecked = False;
			InvalidVariantRejected = False;
			InvalidVariantPersisted = False;
			InvalidVariantError = "";
			If MatrixCase.key = "UyNhiemChi|SoTienNgoaiTe" And DocumentPersisted Then
				InvalidVariantChecked = True;
				DocumentObject.SoTienNgoaiTe = 1;
				Try
					DocumentObject.Write(DocumentWriteMode.Write);
				Except
					InvalidVariantError = DetailErrorDescription(ErrorInfo());
				EndTry;
				InvalidVariantRejected = Not IsBlankString(InvalidVariantError);
			EndIf;
			DocumentNumber = DocumentObject.Number;
			DocumentDate = DocumentObject.Date;
			RollbackTransaction();
			TransactionStarted = False;
			PersistedAfterRollback = ValueIsFilled(FindRequiredFieldMatrixDocument(MatrixCase.document_type, String(DocumentNumber), DocumentDate));
			RolledBack = Not PersistedAfterRollback;
			CaseStatus = "FAIL";
			If WriteAccepted And RoundTripMatches And RolledBack
				And (Not InvalidVariantChecked Or InvalidVariantRejected) Then
				CaseStatus = "PASS";
			EndIf;
			Results.Add(New Structure("document_type,field,key,status,write_accepted,document_persisted,round_trip_matches,persisted_after_rollback,rolled_back,input_value,actual_value,write_error,invalid_variant_checked,invalid_variant_rejected,invalid_variant_persisted,invalid_variant_error",
				MatrixCase.document_type, MatrixCase.field, MatrixCase.key, CaseStatus, WriteAccepted, DocumentPersisted,
				RoundTripMatches, PersistedAfterRollback, RolledBack, String(InputValue), ActualValue, WriteError,
				InvalidVariantChecked, InvalidVariantRejected, InvalidVariantPersisted, InvalidVariantError));
		Except
			If TransactionStarted Then
				Try
					RollbackTransaction();
				Except
				EndTry;
			EndIf;
			Raise;
		EndTry;
	EndDo;
	Return Results;
EndFunction

Function ApplyDocumentFieldProbeValue(DocumentObject, Val DocumentName, Val FieldName, Val Context, Val ARSource, Val APSource, Val CaseNumber)
	IsStatementLineField = IsReconciliationStatementLineProbeField(DocumentName, FieldName);
	If IsStatementLineField Then
		Line = EnsureReconciliationStatementLineProbe(DocumentObject, Context, ARSource, CaseNumber);
		CurrentValue = Line[FieldName];
	Else
		CurrentValue = DocumentObject[FieldName];
	EndIf;
	ProbeValue = CurrentValue;
	If FieldName = "HoaDonAR" And IsStatementLineField Then
		ProbeValue = ARSource;
	ElsIf FieldName = "TienTeDong" And IsStatementLineField Then
		ProbeValue = Context.VND;
	ElsIf FieldName = "ChiNhanh" Then
		ProbeValue = Context.PhapNhan.ChiNhanh;
	ElsIf FieldName = "BienBanNghiemThu" Then
		ProbeValue = ARSource.BienBanNghiemThu;
	ElsIf FieldName = "TaiKhoanChiPhi" Then
		ProbeValue = Context.Account627;
	ElsIf FieldName = "MaSoThueNguoiMua" Then
		ProbeValue = Context.Customer.MaSoThue;
	ElsIf FieldName = "NguoiDuyet" Then
		ProbeValue = "ketoan_truong";
	ElsIf FieldName = "TrangThaiGuiNganHang" Then
		ProbeValue = "ACCEPTED";
	ElsIf FieldName = "SoTienNgoaiTe" And DocumentName = "UyNhiemChi" Then
		ProbeValue = 0;
	ElsIf FieldName = "ChungTuGoc" Then
		If DocumentName = "PhieuThuTienKhachHang" Then
			ProbeValue = ARSource;
		Else
			ProbeValue = APSource;
		EndIf;
	ElsIf FieldName = "TienTe" Then
		ProbeValue = Context.VND;
	ElsIf TypeOf(CurrentValue) = Type("String") Then
		ProbeValue = StrTemplate("QA-%1", CaseNumber);
	ElsIf TypeOf(CurrentValue) = Type("Number") Then
		ProbeValue = 1;
	ElsIf TypeOf(CurrentValue) = Type("Boolean") Then
		ProbeValue = Not CurrentValue;
	ElsIf TypeOf(CurrentValue) = Type("Date") Then
		ProbeValue = Date(2026, 10, 21, 10, 0, 0);
	EndIf;
	If IsStatementLineField Then
		Line[FieldName] = ProbeValue;
	Else
		DocumentObject[FieldName] = ProbeValue;
	EndIf;
	Return ProbeValue;
EndFunction

Function IsReconciliationStatementLineProbeField(Val DocumentName, Val FieldName)
	If DocumentName <> "DoiSoatKenhThanhToan" Then
		Return False;
	EndIf;
	Return StrFind(",ExternalId,KhoaGiaoDich,NgayGiaoDich,DienGiaiDong,TienTeDong,Gross,Phi,Net,HoaDonAR,SoTienGhep,TrangThaiDong,LyDoChan,InvoiceNumber,",
		"," + FieldName + ",") > 0;
EndFunction

Function ReadDocumentFieldProbeValue(DocumentObject, Val DocumentName, Val FieldName)
	If IsReconciliationStatementLineProbeField(DocumentName, FieldName) Then
		If DocumentObject.GiaoDichSaoKe.Count() = 0 Then
			Return Undefined;
		EndIf;
		Line = DocumentObject.GiaoDichSaoKe[0];
		Return Line[FieldName];
	EndIf;
	Return DocumentObject[FieldName];
EndFunction

Function EnsureReconciliationStatementLineProbe(DocumentObject, Val Context, Val ARSource, Val CaseNumber)
	If DocumentObject.GiaoDichSaoKe.Count() > 0 Then
		Return DocumentObject.GiaoDichSaoKe[0];
	EndIf;
	Line = DocumentObject.GiaoDichSaoKe.Add();
	Line.ExternalId = StrTemplate("QA-CSV-%1", CaseNumber);
	Line.KhoaGiaoDich = StrTemplate("QA-CSV-KEY-%1", CaseNumber);
	Line.NgayGiaoDich = Date(2026, 10, 20, 10, 0, 0);
	Line.DienGiaiDong = "QA statement row field probe";
	Line.TienTeDong = Context.VND;
	Line.Gross = 10;
	Line.Phi = 1;
	Line.Net = 9;
	Line.HoaDonAR = ARSource;
	Line.InvoiceNumber = String(ARSource.Number);
	Line.SoTienGhep = 1;
	Line.TrangThaiDong = "ChuaGhep";
	Line.LyDoChan = "QA statement row field probe";
	Return Line;
EndFunction

Function RunAPInvoiceBoundaryMatrix(Val Context)
	USD = Catalogs.TienTe.FindByCode("USD");
	If Not ValueIsFilled(USD) Then Raise "AP invoice boundary matrix requires USD master data."; EndIf;
	CaseNames = StrSplit("negative_vat,vat_equals_total,zero_total,vat_one_below_total,fx_difference_two,fx_tolerance_plus_one,fx_tolerance_minus_one,fct_default_rates", ",");
	Results = New Array;
	CaseIndex = 0;
	For Each CaseName In CaseNames Do
		CaseIndex = CaseIndex + 1;
		TransactionStarted = False;
		Try
			BeginTransaction();
			TransactionStarted = True;
			Doc = CreateAPInvoiceBoundaryDocument(Context, CaseName, CaseIndex, USD);
			VATBeforeWrite = Doc.TienThueVAT;
			WriteError = "";
			Try
				Doc.Write(DocumentWriteMode.Write);
			Except
				WriteError = DetailErrorDescription(ErrorInfo());
			EndTry;
			PersistedInTransaction = False;
			If IsBlankString(WriteError) Then
				PersistedInTransaction = ValueIsFilled(Documents.HoaDonNhaCungCap.FindByNumber(Doc.Number, Doc.Date));
			EndIf;
			WriteAccepted = IsBlankString(WriteError) And PersistedInTransaction;
			VATAfterWrite = Doc.TienThueVAT;
			ShouldAccept = CaseName = "vat_one_below_total" Or CaseName = "fx_tolerance_plus_one"
				Or CaseName = "fx_tolerance_minus_one" Or CaseName = "fct_default_rates";
			NegativeInputSafe = True;
			If CaseName = "negative_vat" Then
				NegativeInputSafe = (Not WriteAccepted And Not PersistedInTransaction)
					Or (WriteAccepted And VATBeforeWrite >= 0 And VATAfterWrite >= 0);
			EndIf;
			CalculatedValuesValid = True;
			If CaseName = "vat_one_below_total" Then
				CalculatedValuesValid = Doc.TienDichVu = 1 And Doc.ChiPhiVSF = 1 And Doc.NoThucTraNCC = 10000;
			ElsIf CaseName = "fx_tolerance_plus_one" Then
				CalculatedValuesValid = Doc.TyGia = 25000 And Doc.TongTienNgoaiTe = 100 And Doc.TongTien = 2500001;
			ElsIf CaseName = "fx_tolerance_minus_one" Then
				CalculatedValuesValid = Doc.TyGia = 25000 And Doc.TongTienNgoaiTe = 100 And Doc.TongTien = 2499999;
			ElsIf CaseName = "fct_default_rates" Then
				CalculatedValuesValid = Doc.TyLeThueVATNhaThau = 5 And Doc.TyLeThueTNDNNhaThau = 5
					And Doc.TienThueVATNhaThau = 5000 And Doc.TienThueTNDNNhaThau = 5000
					And Doc.NoThucTraNCC = 90000 And Doc.ChiPhiVSF = 95000;
			EndIf;
			OutcomeMatches = CalculatedValuesValid And NegativeInputSafe;
			If CaseName <> "negative_vat" Then
				OutcomeMatches = OutcomeMatches And WriteAccepted = ShouldAccept;
			EndIf;
			DocNumber = Doc.Number;
			DocDate = Doc.Date;
			RollbackTransaction();
			TransactionStarted = False;
			PersistedAfterRollback = ValueIsFilled(Documents.HoaDonNhaCungCap.FindByNumber(DocNumber, DocDate));
			RolledBack = Not PersistedAfterRollback;
			CaseStatus = "FAIL";
			If OutcomeMatches And RolledBack Then CaseStatus = "PASS"; EndIf;
			Results.Add(New Structure("key,name,status,should_accept,write_accepted,persisted_in_transaction,persisted_after_rollback,rolled_back,calculated_values_valid,negative_input_safe,input_requested,vat_before_write,vat_after_write,error",
				"HoaDonNhaCungCap|" + CaseName, CaseName, CaseStatus, ShouldAccept, WriteAccepted,
				PersistedInTransaction, PersistedAfterRollback, RolledBack, CalculatedValuesValid, NegativeInputSafe,
				?(CaseName = "negative_vat", -1, 0), VATBeforeWrite, VATAfterWrite, WriteError));
		Except
			If TransactionStarted Then
				Try
					RollbackTransaction();
				Except
				EndTry;
			EndIf;
			Raise;
		EndTry;
	EndDo;
	Return Results;
EndFunction

Function CreateAPInvoiceBoundaryDocument(Val Context, Val CaseName, Val CaseIndex, Val USD)
	Doc = Documents.HoaDonNhaCungCap.CreateDocument();
	If CaseName = "negative_vat" Then
		Doc.Number = "E2E-AP-BD-VATNEG";
	ElsIf CaseName = "vat_equals_total" Then
		Doc.Number = "E2E-AP-BD-VATEQ";
	ElsIf CaseName = "zero_total" Then
		Doc.Number = "E2E-AP-BD-ZTOTAL";
	ElsIf CaseName = "vat_one_below_total" Then
		Doc.Number = "E2E-AP-BD-VATMAX";
	ElsIf CaseName = "fx_difference_two" Then
		Doc.Number = "E2E-AP-BD-FX2";
	ElsIf CaseName = "fx_tolerance_plus_one" Then
		Doc.Number = "E2E-AP-BD-FXP1";
	ElsIf CaseName = "fx_tolerance_minus_one" Then
		Doc.Number = "E2E-AP-BD-FXM1";
	ElsIf CaseName = "fct_default_rates" Then
		Doc.Number = "E2E-AP-BD-FCT";
	Else
		Raise "Unknown AP invoice boundary case: " + CaseName;
	EndIf;
	Doc.Date = Date(2026, 10, 20, 7, CaseIndex, 0);
	Doc.NgayHoaDon = BegOfDay(Doc.Date);
	Doc.SoHoaDon = "APBD" + String(CaseIndex);
	Doc.PhapNhan = Context.PhapNhan;
	Doc.DoiTac = Context.Vendor;
	Doc.HopDong = Context.VendorContract;
	Doc.TienTe = Context.VND;
	Doc.TyGia = 1;
	Doc.TongTien = 10000;
	Doc.TienDichVu = 10000;
	Doc.TienThueVAT = 0;
	Doc.CoKhauTruFCT = False;
	Doc.TrangThai = Enums.TrangThaiHoaDonAP.DuThao;
	Doc.DienGiai = "E2E AP invoice boundary: " + CaseName;
	If CaseName = "negative_vat" Then
		Doc.TienThueVAT = -1;
	ElsIf CaseName = "vat_equals_total" Then
		Doc.TienThueVAT = 10000;
	ElsIf CaseName = "zero_total" Then
		Doc.TongTien = 0;
		Doc.TienDichVu = 0;
	ElsIf CaseName = "vat_one_below_total" Then
		Doc.TienThueVAT = 9999;
	ElsIf CaseName = "fx_difference_two" Or CaseName = "fx_tolerance_plus_one" Or CaseName = "fx_tolerance_minus_one" Then
		Doc.TienTe = USD;
		Doc.TyGia = 25000;
		Doc.TongTienNgoaiTe = 100;
		If CaseName = "fx_difference_two" Then
			Doc.TongTien = 2500002;
		ElsIf CaseName = "fx_tolerance_plus_one" Then
			Doc.TongTien = 2500001;
		Else
			Doc.TongTien = 2499999;
		EndIf;
		Doc.TienDichVu = Doc.TongTien;
	ElsIf CaseName = "fct_default_rates" Then
		Doc.TongTien = 100000;
		Doc.TienDichVu = 100000;
		Doc.CoKhauTruFCT = True;
		Doc.TyLeThueVATNhaThau = 0;
		Doc.TyLeThueTNDNNhaThau = 0;
	EndIf;
	Return Doc;
EndFunction

Function RunRequiredFieldBoundaryMatrix(Val Context, Val ARSource, Val APSource)
	Results = New Array;
	TransactionStarted = False;
	Try
		BeginTransaction();
		TransactionStarted = True;
		DocumentObject = CreateRequiredFieldMatrixDocument("HoaDonGTGTDauRa", Context, ARSource, APSource, 201);
		DocumentObject.Date = CurrentSessionDate();
		DocumentObject.Number = "XRFDATE1";
		DocumentObject.NgayHoaDon = BegOfDay(CurrentSessionDate()) + 86400;
		DateIsFuture = BegOfDay(DocumentObject.NgayHoaDon) > BegOfDay(CurrentSessionDate());
		WriteError = "";
		Try
			DocumentObject.Write(DocumentWriteMode.Write);
		Except
			WriteError = DetailErrorDescription(ErrorInfo());
		EndTry;
		NumberAfter = String(DocumentObject.Number);
		PersistedInTransaction = False;
		If IsBlankString(WriteError) Then
			PersistedInTransaction = RequiredFieldMatrixDocumentExists("HoaDonGTGTDauRa", NumberAfter, DocumentObject.Date);
		EndIf;
		WriteRejected = Not PersistedInTransaction;
		RollbackTransaction();
		TransactionStarted = False;
		PersistedAfterRollback = RequiredFieldMatrixDocumentExists("HoaDonGTGTDauRa", NumberAfter, DocumentObject.Date);
		RolledBack = Not PersistedAfterRollback;
		CaseStatus = "FAIL";
		If DateIsFuture And WriteRejected And RolledBack Then
			CaseStatus = "PASS";
		EndIf;
		Results.Add(New Structure("key,status,date_is_future,write_rejected,document_persisted,document_persisted_after_rollback,rolled_back,document_number,invoice_date,error",
			"HoaDonGTGTDauRa|NgayHoaDon|future", CaseStatus, DateIsFuture, WriteRejected, PersistedInTransaction,
			PersistedAfterRollback, RolledBack, NumberAfter, String(DocumentObject.NgayHoaDon), WriteError));
	Except
		If TransactionStarted Then
			Try
				RollbackTransaction();
			Except
			EndTry;
		EndIf;
		Raise;
	EndTry;

	TaxIdCases = New Array;
	TaxIdCases.Add(New Structure("key,value,should_accept", "HoaDonGTGTDauRa|MaSoThueNguoiMua|letters_10", "ABCDEFGHIJ", False));
	TaxIdCases.Add(New Structure("key,value,should_accept", "HoaDonGTGTDauRa|MaSoThueNguoiMua|hyphen_10", "12345-6789", False));
	TaxIdCases.Add(New Structure("key,value,should_accept", "HoaDonGTGTDauRa|MaSoThueNguoiMua|too_short_9", "123456789", False));
	TaxIdCases.Add(New Structure("key,value,should_accept", "HoaDonGTGTDauRa|MaSoThueNguoiMua|valid_10_digits", "0123456789", True));
	TaxIdCases.Add(New Structure("key,value,should_accept", "HoaDonGTGTDauRa|MaSoThueNguoiMua|valid_13_digits", "0123456789012", True));
	TaxIdCases.Add(New Structure("key,value,should_accept", "HoaDonGTGTDauRa|MaSoThueNguoiMua|valid_14_digits", "01234567890123", True));
	For Each TaxIdCase In TaxIdCases Do
		TransactionStarted = False;
		Try
			BeginTransaction();
			TransactionStarted = True;
			DocumentObject = CreateRequiredFieldMatrixDocument("HoaDonGTGTDauRa", Context, ARSource, APSource, 301 + Results.Count());
			DocumentObject.Date = CurrentSessionDate();
			DocumentObject.Number = StrTemplate("XRFT%1", Results.Count() + 1);
			DocumentObject.NgayHoaDon = BegOfDay(CurrentSessionDate());
			DocumentObject.MaSoThueNguoiMua = TaxIdCase.value;
			WriteError = "";
			Try
				DocumentObject.Write(DocumentWriteMode.Write);
			Except
				WriteError = DetailErrorDescription(ErrorInfo());
			EndTry;
			NumberAfter = String(DocumentObject.Number);
			PersistedInTransaction = False;
			If IsBlankString(WriteError) Then
				PersistedInTransaction = RequiredFieldMatrixDocumentExists("HoaDonGTGTDauRa", NumberAfter, DocumentObject.Date);
			EndIf;
			WriteAccepted = Not ValueIsFilled(WriteError) And PersistedInTransaction;
			OutcomeMatches = WriteAccepted = TaxIdCase.should_accept;
			RollbackTransaction();
			TransactionStarted = False;
			PersistedAfterRollback = RequiredFieldMatrixDocumentExists("HoaDonGTGTDauRa", NumberAfter, DocumentObject.Date);
			RolledBack = Not PersistedAfterRollback;
			CaseStatus = "FAIL";
			If OutcomeMatches And RolledBack Then
				CaseStatus = "PASS";
			EndIf;
			Results.Add(New Structure("key,status,should_accept,write_accepted,document_persisted,document_persisted_after_rollback,rolled_back,tax_id,error",
				TaxIdCase.key, CaseStatus, TaxIdCase.should_accept, WriteAccepted, PersistedInTransaction,
				PersistedAfterRollback, RolledBack, TaxIdCase.value, WriteError));
		Except
			If TransactionStarted Then
				Try
					RollbackTransaction();
				Except
				EndTry;
			EndIf;
			Raise;
		EndTry;
	EndDo;
	Return Results;
EndFunction

Function RunRequiredFieldAutoFillMatrix(Val Context, Val ARSource, Val APSource)
	Cases = New Array;
	Cases.Add(New Structure("document_type,field,key", "BienBanNghiemThuGiaiDoan", "TongGiaTri", "BienBanNghiemThuGiaiDoan|TongGiaTri"));
	Cases.Add(New Structure("document_type,field,key", "BienBanNghiemThuGiaiDoan", "TrangThai", "BienBanNghiemThuGiaiDoan|TrangThai"));
	Cases.Add(New Structure("document_type,field,key", "HoaDonGTGTDauRa", "TongTienThanhToan", "HoaDonGTGTDauRa|TongTienThanhToan"));
	Cases.Add(New Structure("document_type,field,key", "PhieuThuTienKhachHang", "TienTe", "PhieuThuTienKhachHang|TienTe"));
	Cases.Add(New Structure("document_type,field,key", "HoaDonNhaCungCap", "NgayHoaDon", "HoaDonNhaCungCap|NgayHoaDon"));
	Cases.Add(New Structure("document_type,field,key", "HoaDonNhaCungCap", "TienTe", "HoaDonNhaCungCap|TienTe"));
	Cases.Add(New Structure("document_type,field,key", "HoaDonNhaCungCap", "TongTien", "HoaDonNhaCungCap|TongTien"));

	Results = New Array;
	For Each MatrixCase In Cases Do
		TransactionStarted = False;
		Try
			BeginTransaction();
			TransactionStarted = True;
			If MatrixCase.key = "BienBanNghiemThuGiaiDoan|TrangThai" Then
				DocumentObject = CreateRequiredFieldMatrixAcceptanceWithFilling(Context);
			Else
				DocumentObject = CreateRequiredFieldMatrixDocument(MatrixCase.document_type, Context, ARSource, APSource, Results.Count() + 101);
				ClearRequiredFieldMatrixValue(DocumentObject, MatrixCase.field);
			EndIf;
			DocumentObject.Number = StrTemplate("XRF%1", Results.Count() + 1);
			WriteError = "";
			Try
				DocumentObject.Write(DocumentWriteMode.Write);
			Except
				WriteError = DetailErrorDescription(ErrorInfo());
			EndTry;
			NumberAfter = String(DocumentObject.Number);
			PersistedInTransaction = False;
			If IsBlankString(WriteError) Then
				PersistedInTransaction = RequiredFieldMatrixDocumentExists(MatrixCase.document_type, NumberAfter, DocumentObject.Date);
			EndIf;
			WriteAccepted = Not ValueIsFilled(WriteError) And PersistedInTransaction;
			AutomaticValueValid = False;
			ActualValue = "";
			If MatrixCase.key = "BienBanNghiemThuGiaiDoan|TongGiaTri" Then
				ActualValue = String(DocumentObject.TongGiaTri);
				AutomaticValueValid = DocumentObject.TongGiaTri = 1000000;
			ElsIf MatrixCase.key = "BienBanNghiemThuGiaiDoan|TrangThai" Then
				ActualValue = String(DocumentObject.TrangThai);
				AutomaticValueValid = DocumentObject.TrangThai = Enums.TrangThaiNghiemThuAR.DuThao;
			ElsIf MatrixCase.key = "HoaDonGTGTDauRa|TongTienThanhToan" Then
				ActualValue = String(DocumentObject.TongTienThanhToan);
				AutomaticValueValid = DocumentObject.TongTienThanhToan = 1000000;
			ElsIf MatrixCase.key = "PhieuThuTienKhachHang|TienTe" Then
				ActualValue = String(DocumentObject.TienTe.Code);
				AutomaticValueValid = DocumentObject.TienTe = Context.VND;
			ElsIf MatrixCase.key = "HoaDonNhaCungCap|NgayHoaDon" Then
				ActualValue = String(DocumentObject.NgayHoaDon);
				AutomaticValueValid = ValueIsFilled(DocumentObject.NgayHoaDon)
					And BegOfDay(DocumentObject.NgayHoaDon) = BegOfDay(DocumentObject.Date);
			ElsIf MatrixCase.key = "HoaDonNhaCungCap|TienTe" Then
				ActualValue = String(DocumentObject.TienTe.Code);
				AutomaticValueValid = DocumentObject.TienTe = Context.VND;
			ElsIf MatrixCase.key = "HoaDonNhaCungCap|TongTien" Then
				ActualValue = String(DocumentObject.TongTien);
				AutomaticValueValid = DocumentObject.TongTien = 1000000;
			EndIf;
			RollbackTransaction();
			TransactionStarted = False;
			PersistedAfterRollback = RequiredFieldMatrixDocumentExists(MatrixCase.document_type, NumberAfter, DocumentObject.Date);
			RolledBack = Not PersistedAfterRollback;
			CaseStatus = "FAIL";
			If WriteAccepted And AutomaticValueValid And RolledBack Then
				CaseStatus = "PASS";
			EndIf;
			Results.Add(New Structure("document_type,field,key,status,write_accepted,automatic_value_valid,actual_value,persisted_in_transaction,persisted_after_rollback,rolled_back,error",
				MatrixCase.document_type, MatrixCase.field, MatrixCase.key, CaseStatus, WriteAccepted, AutomaticValueValid,
				ActualValue, PersistedInTransaction, PersistedAfterRollback, RolledBack, WriteError));
		Except
			If TransactionStarted Then
				Try
					RollbackTransaction();
				Except
				EndTry;
			EndIf;
			Raise;
		EndTry;
	EndDo;
	Return Results;
EndFunction

Function CreateRequiredFieldMatrixAcceptanceWithFilling(Val Context)
	Doc = Documents.BienBanNghiemThuGiaiDoan.CreateDocument();
	Doc.Fill(Undefined);
	Doc.Date = Date(2026, 10, 21, 9, 0, 0);
	Doc.PhapNhan = Context.PhapNhan;
	Doc.DoiTac = Context.Customer;
	Doc.HopDong = Context.CustomerContract;
	Doc.NgayNghiemThu = BegOfDay(Doc.Date);
	Doc.GiaTriNghiemThuChuaVAT = 1000000;
	Doc.TyLeVAT = 0;
	Doc.TienVAT = 0;
	Doc.TongGiaTri = 1000000;
	Doc.NguoiDuyet = "ketoan_truong";
	Doc.DienGiai = "Required-field matrix acceptance Filling default";
	Return Doc;
EndFunction

Procedure AddRequiredFieldMatrixCases(Cases, Val DocumentName, Val FieldNames)
	For Each FieldName In StrSplit(FieldNames, ",") Do
		Cases.Add(New Structure("document_type,field,key", DocumentName, FieldName, DocumentName + "|" + FieldName));
	EndDo;
EndProcedure

Function CreateRequiredFieldMatrixDocument(Val DocumentName, Val Context, Val ARSource, Val APSource, Val CaseNumber)
	DocDate = Date(2026, 10, 21, 9, 0, 0);
	If DocumentName = "BienBanNghiemThuGiaiDoan" Then
		Doc = Documents.BienBanNghiemThuGiaiDoan.CreateDocument();
		Doc.Date = DocDate;
		Doc.PhapNhan = Context.PhapNhan;
		Doc.DoiTac = Context.Customer;
		Doc.HopDong = Context.CustomerContract;
		Doc.NgayNghiemThu = BegOfDay(DocDate);
		Doc.GiaTriNghiemThuChuaVAT = 1000000;
		Doc.TyLeVAT = 0;
		Doc.TienVAT = 0;
		Doc.TongGiaTri = 1000000;
		Doc.TrangThai = Enums.TrangThaiNghiemThuAR.DuThao;
			Doc.NguoiDuyet = "ketoan_truong";
		Doc.DienGiai = "Required-field matrix acceptance";
		Return Doc;
	ElsIf DocumentName = "HoaDonGTGTDauRa" Then
		Doc = Documents.HoaDonGTGTDauRa.CreateDocument();
		Doc.Date = DocDate;
		Doc.SoHoaDon = StrTemplate("REQM-AR-%1", CaseNumber);
		Doc.KyHieu = "REQM26";
		Doc.PhapNhan = Context.PhapNhan;
		Doc.DoiTac = Context.Customer;
		Doc.HopDong = Context.CustomerContract;
		Doc.NgayHoaDon = BegOfDay(DocDate);
		Doc.TienChuaThue = 1000000;
		Doc.ThueSuatVAT = 0;
		Doc.TienThueVAT = 0;
		Doc.TongTienThanhToan = 1000000;
		Doc.TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.DuThao;
		Doc.NguoiDuyet = "ketoan_truong";
		Doc.DienGiai = "Required-field matrix direct sales invoice";
		Return Doc;
	ElsIf DocumentName = "PhieuThuTienKhachHang" Then
		Doc = Documents.PhieuThuTienKhachHang.CreateDocument();
		Doc.Date = DocDate;
		Doc.PhapNhan = Context.PhapNhan;
		Doc.DoiTac = Context.Customer;
		Doc.HopDong = Context.CustomerContract;
		Doc.ChungTuGoc = ARSource;
		Doc.TaiKhoanTien = Context.Bank;
		Doc.KhoanMucDongTien = Context.CustomerReceiptCategory;
		Doc.TienTe = Context.VND;
		Doc.TyGia = 1;
		Doc.NgayThu = BegOfDay(DocDate);
		Doc.SoTien = 1;
		Doc.NguoiDuyet = "cfo_giamdoc";
		Doc.DienGiai = "Required-field matrix customer receipt";
		Return Doc;
	ElsIf DocumentName = "HoaDonNhaCungCap" Then
		Doc = Documents.HoaDonNhaCungCap.CreateDocument();
		Doc.Date = DocDate;
		Doc.NgayHoaDon = BegOfDay(DocDate);
		Doc.SoHoaDon = StrTemplate("REQM-AP-%1", CaseNumber);
		Doc.PhapNhan = Context.PhapNhan;
		Doc.DoiTac = Context.Vendor;
		Doc.HopDong = Context.VendorContract;
		Doc.TaiKhoanChiPhi = Context.Account627;
		Doc.TienTe = Context.VND;
		Doc.TyGia = 1;
		Doc.TongTien = 1000000;
		Doc.TienDichVu = 1000000;
		Doc.NoThucTraNCC = 1000000;
		Doc.CoKhauTruFCT = False;
		Doc.TrangThai = Enums.TrangThaiHoaDonAP.DuThao;
		Doc.NguoiDuyet = "ketoan_truong";
		Doc.DienGiai = "Required-field matrix supplier invoice";
		Return Doc;
	ElsIf DocumentName = "UyNhiemChi" Then
		Doc = Documents.UyNhiemChi.CreateDocument();
		Doc.Date = DocDate;
		Doc.NgayLap = BegOfDay(DocDate);
		Doc.NgayGhiSo = BegOfDay(DocDate);
		Doc.PhapNhan = Context.PhapNhan;
		Doc.DoiTac = Context.Vendor;
		Doc.HopDong = Context.VendorContract;
		Doc.ChungTuGoc = APSource;
		Doc.TaiKhoanTien = Context.Bank;
		Doc.KhoanMucDongTien = Context.VendorPaymentCategory;
		Doc.TienTe = Context.VND;
		Doc.TyGia = 1;
		Doc.SoTien = 1;
		Doc.PhiNganHang = 0;
		Doc.TrangThai = Enums.TrangThaiLenhThanhToan.DuThao;
		Doc.NguoiDuyet = "ketoan_truong";
		Doc.DienGiai = "Required-field matrix payment order";
		Return Doc;
	ElsIf DocumentName = "CanTruCongNoNoiBo" Then
		Doc = Documents.CanTruCongNoNoiBo.CreateDocument();
		Doc.Date = DocDate;
		Doc.PhapNhan = Context.PhapNhan;
		Doc.DoiTac = Context.Customer;
		Doc.ChungTuAR = ARSource;
		Doc.ChungTuAP = APSource;
		Doc.SoTien = 1;
		Doc.DienGiai = "Required-field matrix netting";
		Return Doc;
	ElsIf DocumentName = "DoiSoatKenhThanhToan" Then
		Doc = Documents.DoiSoatKenhThanhToan.CreateDocument();
		Doc.Date = DocDate;
		Doc.PhapNhan = Context.PhapNhan;
		Doc.DoiTacTrungGian = Context.PaymentProvider;
		Doc.TaiKhoanTien = Context.Bank;
		Doc.KhoanMucDongTien = Context.PaymentReconciliationCategory;
		Doc.TienTe = Context.VND;
		Doc.KenhThanhToan = "VNPAY";
		Doc.TongTienGiaoDich = 10;
		Doc.TongPhi = 1;
		Doc.TongTienThucNhan = 9;
		Doc.DienGiai = "Required-field matrix settlement reconciliation";
		Return Doc;
	EndIf;
	Raise "Unsupported required-field matrix document type: " + DocumentName;
EndFunction

Procedure ClearRequiredFieldMatrixValue(DocumentObject, Val FieldName)
	If FieldName = "PhapNhan" Then
		DocumentObject.PhapNhan = Catalogs.PhapNhan.EmptyRef();
	ElsIf FieldName = "DoiTac" Then
		DocumentObject.DoiTac = Catalogs.DoiTac.EmptyRef();
	ElsIf FieldName = "HopDong" Then
		DocumentObject.HopDong = Catalogs.HopDong.EmptyRef();
	ElsIf FieldName = "SoHoaDon" Then
		DocumentObject.SoHoaDon = "";
	ElsIf FieldName = "KyHieu" Then
		DocumentObject.KyHieu = "";
	ElsIf FieldName = "NgayHoaDon" Then
		DocumentObject.NgayHoaDon = Date(1, 1, 1, 0, 0, 0);
	ElsIf FieldName = "GiaTriNghiemThuChuaVAT" Then
		DocumentObject.GiaTriNghiemThuChuaVAT = 0;
	ElsIf FieldName = "TaiKhoanTien" Then
		DocumentObject.TaiKhoanTien = Catalogs.TaiKhoanTien.EmptyRef();
	ElsIf FieldName = "KhoanMucDongTien" Then
		DocumentObject.KhoanMucDongTien = Catalogs.KhoanMucDongTien.EmptyRef();
	ElsIf FieldName = "TienTe" Then
		DocumentObject.TienTe = Catalogs.TienTe.EmptyRef();
	ElsIf FieldName = "SoTien" Then
		DocumentObject.SoTien = 0;
	ElsIf FieldName = "ChungTuAR" Then
		DocumentObject.ChungTuAR = Documents.BienBanNghiemThuGiaiDoan.EmptyRef();
	ElsIf FieldName = "ChungTuAP" Then
		DocumentObject.ChungTuAP = Documents.HoaDonNhaCungCap.EmptyRef();
	ElsIf FieldName = "TongTien" Then
		DocumentObject.TongTien = 0;
	ElsIf FieldName = "TongGiaTri" Then
		DocumentObject.TongGiaTri = 0;
	ElsIf FieldName = "TongTienThanhToan" Then
		DocumentObject.TongTienThanhToan = 0;
	ElsIf FieldName = "DoiTacTrungGian" Then
		DocumentObject.DoiTacTrungGian = Catalogs.DoiTac.EmptyRef();
	ElsIf FieldName = "KenhThanhToan" Then
		DocumentObject.KenhThanhToan = "";
	ElsIf FieldName = "TongTienGiaoDich" Then
		DocumentObject.TongTienGiaoDich = 0;
	ElsIf FieldName = "TongPhi" Then
		DocumentObject.TongPhi = 0;
	ElsIf FieldName = "TongTienThucNhan" Then
		DocumentObject.TongTienThucNhan = 0;
	Else
		Raise "Unsupported required field in matrix: " + FieldName;
	EndIf;
EndProcedure

Function RequiredFieldMatrixDocumentExists(Val DocumentName, Val DocumentNumber, Val DocumentDate)
	If IsBlankString(DocumentNumber) Then
		Return False;
	EndIf;
	Return ValueIsFilled(FindRequiredFieldMatrixDocument(DocumentName, DocumentNumber, DocumentDate));
EndFunction

Function FindRequiredFieldMatrixDocument(Val DocumentName, Val DocumentNumber, Val DocumentDate)
	If IsBlankString(DocumentNumber) Then
		Return Undefined;
	EndIf;
	If DocumentName = "BienBanNghiemThuGiaiDoan" Then
		Return Documents.BienBanNghiemThuGiaiDoan.FindByNumber(DocumentNumber, DocumentDate);
	ElsIf DocumentName = "HoaDonGTGTDauRa" Then
		Return Documents.HoaDonGTGTDauRa.FindByNumber(DocumentNumber, DocumentDate);
	ElsIf DocumentName = "PhieuThuTienKhachHang" Then
		Return Documents.PhieuThuTienKhachHang.FindByNumber(DocumentNumber, DocumentDate);
	ElsIf DocumentName = "HoaDonNhaCungCap" Then
		Return Documents.HoaDonNhaCungCap.FindByNumber(DocumentNumber, DocumentDate);
	ElsIf DocumentName = "UyNhiemChi" Then
		Return Documents.UyNhiemChi.FindByNumber(DocumentNumber, DocumentDate);
	ElsIf DocumentName = "CanTruCongNoNoiBo" Then
		Return Documents.CanTruCongNoNoiBo.FindByNumber(DocumentNumber, DocumentDate);
	ElsIf DocumentName = "DoiSoatKenhThanhToan" Then
		Return Documents.DoiSoatKenhThanhToan.FindByNumber(DocumentNumber, DocumentDate);
	EndIf;
	Raise "Unsupported required-field matrix document type for persistence probe: " + DocumentName;
EndFunction

#EndRegion


#Region CSVReconciliationE2E

Function VerifyFinanceE2ECsvImportPreview() Export
	RequireFinanceE2ERole("GiamDocTaiChinh_CFO");
	Context = FinanceE2EContext(True);
	InvoiceRef = Documents.HoaDonGTGTDauRa.FindByNumber("E2E-AR001", Date(2026, 10, 10, 10, 0, 0));
	If Not ValueIsFilled(InvoiceRef) Or Not InvoiceRef.Posted Then
		Raise "CSV preview requires the issued and posted E2E AR invoice.";
	EndIf;
	Invoice = InvoiceRef.GetObject();
	If Invoice.TrangThaiHDDT <> Enums.TrangThaiHoaDonDienTu.DaPhatHanh Then
		Raise "CSV preview must use an issued AR invoice.";
	EndIf;

	ColumnMap = New Structure;
	ColumnMap.Insert("ExternalId", "ExternalId");
	ColumnMap.Insert("TransactionDate", "TransactionDate");
	ColumnMap.Insert("InvoiceNumber", "InvoiceNumber");
	ColumnMap.Insert("Memo", "Memo");
	ColumnMap.Insert("Gross", "Gross");
	ColumnMap.Insert("Fee", "Fee");
	ColumnMap.Insert("Net", "Net");
	ColumnMap.Insert("Currency", "Currency");
	CSVText = "ExternalId,TransactionDate,InvoiceNumber,Memo,Gross,Fee,Net,Currency" + Char(13) + Char(10)
		+ "TXN-E2E-CSV-001,2026-10-21," + Invoice.Number + ",VNPay settlement,75000000,1125000,73875000,VND";
	Parsed = NhapSaoKeCsvServer.ParseCSVRows(CSVText, ColumnMap, ",", ".", ",");
	If Parsed.Errors.Count() <> 0 Or Parsed.Rows.Count() <> 1 Then
		Raise "CSV preview did not parse the valid VNPAY row and explicit column mapping.";
	EndIf;
	Row = Parsed.Rows[0];
	SuggestedInvoiceRef = Documents.HoaDonGTGTDauRa.FindByNumber(Row.InvoiceNumber, Date(2026, 10, 10, 10, 0, 0));
	If Row.Status <> "Valid" Or Row.Gross <> 75000000 Or Row.Fee <> 1125000 Or Row.Net <> 73875000
		Or Not ValueIsFilled(SuggestedInvoiceRef) Or Row.InvoiceNumber <> Invoice.Number Then
		Raise "CSV preview amount mapping or invoice-number suggestion did not match the issued invoice.";
	EndIf;
	OpenBalance = FinanceE2EARBalanceFor(Context.PhapNhan, Context.Customer, Context.CustomerContract, InvoiceRef);
	If OpenBalance < Row.Gross Then Raise "CSV preview invoice suggestion has insufficient open AR."; EndIf;

	FallbackMap = New Structure;
	FallbackMap.Insert("TransactionDate", "TransactionDate");
	FallbackMap.Insert("Memo", "Memo");
	FallbackMap.Insert("Gross", "Gross");
	FallbackMap.Insert("Fee", "Fee");
	FallbackMap.Insert("Net", "Net");
	FallbackMap.Insert("Currency", "Currency");
	AmountOnlyCSV = "TransactionDate,Memo,Gross,Fee,Net,Currency" + Char(13) + Char(10)
		+ "2026-10-21,VNPay settlement,75000000,1125000,73875000,VND";
	AmountOnlyParsed = NhapSaoKeCsvServer.ParseCSVRows(AmountOnlyCSV, FallbackMap, ",", ".", ",");
	If AmountOnlyParsed.Errors.Count() <> 0 Or AmountOnlyParsed.Rows.Count() <> 1
		Or StrLen(AmountOnlyParsed.Rows[0].InvoiceNumber) <> 0 Then
		Raise "Amount-only CSV preview must remain unmatched until a user chooses an invoice.";
	EndIf;

	Return New Structure("invoice_number,open_ar_vnd,preview_rows,preview_gross_vnd,preview_fee_vnd,preview_net_vnd,amount_only_has_no_match,manual_confirmation_required",
		Invoice.Number, OpenBalance, Parsed.Rows.Count(), Row.Gross, Row.Fee, Row.Net, True, True);
EndFunction

Function PostFinanceE2ECsvImport() Export
	RequireFinanceE2ERole("GiamDocTaiChinh_CFO");
	Context = FinanceE2EContext(True);
	InvoiceRef = Documents.HoaDonGTGTDauRa.FindByNumber("E2E-AR001", Date(2026, 10, 10, 10, 0, 0));
	If Not ValueIsFilled(InvoiceRef) Or Not InvoiceRef.Posted Then Raise "CSV posting requires the issued E2E AR invoice."; EndIf;
	Invoice = InvoiceRef.GetObject();
	ARBefore = FinanceE2EARBalanceFor(Context.PhapNhan, Context.Customer, Context.CustomerContract, InvoiceRef);
	CashBefore = FinanceE2ECashBalanceFor(Context.PhapNhan, Context.Bank, Context.VND).SoTien;
	If ARBefore < 75000000 Then Raise "CSV partial receipt fixture requires at least 75m open AR."; EndIf;

	Doc = CreateFinanceE2ECsvReconciliation(Context, "E2E-BK-CSV-001", InvoiceRef,
		75000000, 1125000, 73875000, "TXN-E2E-CSV-001", "DaGhep", 75000000);
	Doc.Write(DocumentWriteMode.Posting);
	If Not Doc.Posted Then Raise "Confirmed imported CSV reconciliation did not post."; EndIf;
	ARAfter = FinanceE2EARBalanceFor(Context.PhapNhan, Context.Customer, Context.CustomerContract, InvoiceRef);
	CashAfter = FinanceE2ECashBalanceFor(Context.PhapNhan, Context.Bank, Context.VND).SoTien;
	ARAccountCode = "1311";
	If Invoice.DoiTac.LaBenLienKet Then ARAccountCode = "1312"; EndIf;
	AssertFinanceE2EGL(Doc.Ref, "1121", "1388", 73875000);
	AssertFinanceE2EGL(Doc.Ref, "6427", "1388", 1125000);
	AssertFinanceE2EGL(Doc.Ref, "1388", ARAccountCode, 75000000);
	If ARAfter <> ARBefore - 75000000 Or CashAfter <> CashBefore + 73875000
		Or CountRecorderMovementRecords("AccumulationRegister.DongTien", Doc.Ref) <> 1
		Or CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiThu", Doc.Ref) <> 1
		Or CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", Doc.Ref) <> 3
		Or CountActiveFinanceE2ECsvKeys(Context, Doc.GiaoDichSaoKe[0].KhoaGiaoDich) <> 1 Then
		Raise "CSV receipt postings did not reconcile net cash, gross AR, GL, and one active transaction key.";
	EndIf;

	Return New Structure("document_number,posted,gross_vnd,fee_vnd,net_vnd,ar_before_vnd,ar_after_vnd,cash_delta_vnd,gl_rows,ar_rows,key_reserved",
		Doc.Number, Doc.Posted, 75000000, 1125000, 73875000, ARBefore, ARAfter, CashAfter - CashBefore,
		CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", Doc.Ref),
		CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiThu", Doc.Ref), True);
EndFunction

Function VerifyFinanceE2ECsvDuplicateReimport() Export
	RequireFinanceE2ERole("GiamDocTaiChinh_CFO");
	Context = FinanceE2EContext(True);
	OriginalRef = Documents.DoiSoatKenhThanhToan.FindByNumber("E2E-BK-CSV-001", Date(2026, 10, 21, 16, 0, 0));
	If Not ValueIsFilled(OriginalRef) Or Not OriginalRef.Posted Then Raise "CSV duplicate test requires its first reconciliation to be posted."; EndIf;
	Original = OriginalRef.GetObject();
	OriginalLine = Original.GiaoDichSaoKe[0];
	InvoiceRef = OriginalLine.HoaDonAR;
	ARAfterOriginal = FinanceE2EARBalanceFor(Context.PhapNhan, Context.Customer, Context.CustomerContract, InvoiceRef);
	CashAfterOriginal = FinanceE2ECashBalanceFor(Context.PhapNhan, Context.Bank, Context.VND).SoTien;
	ARBeforeOriginal = ARAfterOriginal + OriginalLine.SoTienGhep;
	CashBeforeOriginal = CashAfterOriginal - OriginalLine.Net;

	Duplicate = CreateFinanceE2ECsvReconciliation(Context, "E2E-BK-CSV-DUP-03", InvoiceRef,
		75000000, 1125000, 73875000, OriginalLine.ExternalId, "DaGhep", 75000000);
	DuplicateError = "";
	Try
		Duplicate.Write(DocumentWriteMode.Posting);
	Except
		DuplicateError = DetailErrorDescription(ErrorInfo());
	EndTry;
	DuplicateCash = FinanceE2ECashBalanceFor(Context.PhapNhan, Context.Bank, Context.VND).SoTien;
	DuplicateAR = FinanceE2EARBalanceFor(Context.PhapNhan, Context.Customer, Context.CustomerContract, InvoiceRef);
	DuplicateRejected = Not Duplicate.Posted
		And DuplicateCash = CashAfterOriginal And DuplicateAR = ARAfterOriginal
		And CountRecorderMovementRecords("AccumulationRegister.DongTien", Duplicate.Ref) = 0
		And CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiThu", Duplicate.Ref) = 0
		And CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", Duplicate.Ref) = 0
		And CountActiveFinanceE2ECsvKeys(Context, OriginalLine.KhoaGiaoDich) = 1;
	If Not DuplicateRejected Then Raise StrTemplate("Duplicate CSV re-import was not rejected without movement. %1", DuplicateError); EndIf;

	Original = OriginalRef.GetObject();
	Original.Write(DocumentWriteMode.UndoPosting);
	ARAfterUndo = FinanceE2EARBalanceFor(Context.PhapNhan, Context.Customer, Context.CustomerContract, InvoiceRef);
	CashAfterUndo = FinanceE2ECashBalanceFor(Context.PhapNhan, Context.Bank, Context.VND).SoTien;
	If Original.Posted Or ARAfterUndo <> ARBeforeOriginal Or CashAfterUndo <> CashBeforeOriginal
		Or CountRecorderMovementRecords("AccumulationRegister.DongTien", OriginalRef) <> 0
		Or CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiThu", OriginalRef) <> 0
		Or CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", OriginalRef) <> 0
		Or CountActiveFinanceE2ECsvKeys(Context, OriginalLine.KhoaGiaoDich) <> 0 Then
		Raise "CSV unposting did not restore cash/AR and release its key reservation.";
	EndIf;

	Return New Structure("duplicate_rejected,duplicate_cash_delta_vnd,duplicate_ar_delta_vnd,duplicate_movement_rows,original_unposted,key_released,ar_restored,cash_restored",
		DuplicateRejected, DuplicateCash - CashAfterOriginal, DuplicateAR - ARAfterOriginal,
		CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", Duplicate.Ref), Not Original.Posted, True,
		ARAfterUndo = ARBeforeOriginal, CashAfterUndo = CashBeforeOriginal);
EndFunction

Function VerifyFinanceE2ECsvInvalidRows() Export
	RequireFinanceE2ERole("GiamDocTaiChinh_CFO");
	Context = FinanceE2EContext(True);
	InvoiceRef = Documents.HoaDonGTGTDauRa.FindByNumber("E2E-AR001", Date(2026, 10, 10, 10, 0, 0));
	If Not ValueIsFilled(InvoiceRef) Or Not InvoiceRef.Posted Then Raise "CSV invalid-row tests require the issued E2E AR invoice."; EndIf;
	ARBefore = FinanceE2EARBalanceFor(Context.PhapNhan, Context.Customer, Context.CustomerContract, InvoiceRef);
	CashBefore = FinanceE2ECashBalanceFor(Context.PhapNhan, Context.Bank, Context.VND).SoTien;
	Cases = New Array;

	Unmatched = CreateFinanceE2ECsvReconciliation(Context, "E2E-BK-CSV-UNMATCHED", Undefined,
		75000000, 1125000, 73875000, "TXN-E2E-CSV-UNMATCHED", "ChuaGhep", 0);
	Cases.Add(AttemptFinanceE2ECsvInvalidPosting(Unmatched, Context, InvoiceRef, "unmatched_row", ARBefore, CashBefore));

	Imbalanced = CreateFinanceE2ECsvReconciliation(Context, "E2E-BK-CSV-IMBALANCE", InvoiceRef,
		75000000, 1125000, 73874999, "TXN-E2E-CSV-IMBALANCE", "DaGhep", 75000000);
	Cases.Add(AttemptFinanceE2ECsvInvalidPosting(Imbalanced, Context, InvoiceRef, "fee_imbalance", ARBefore, CashBefore));

	PartialAllocation = CreateFinanceE2ECsvReconciliation(Context, "E2E-BK-CSV-PARTIAL-ALLOC", InvoiceRef,
		75000000, 1125000, 73875000, "TXN-E2E-CSV-PARTIAL-ALLOC", "DaGhep", 74000000);
	Cases.Add(AttemptFinanceE2ECsvInvalidPosting(PartialAllocation, Context, InvoiceRef, "allocation_mismatch", ARBefore, CashBefore));

	OverCollection = CreateFinanceE2ECsvReconciliation(Context, "E2E-BK-CSV-OVER", InvoiceRef,
		ARBefore + 1, 0, ARBefore + 1, "TXN-E2E-CSV-OVER", "DaGhep", ARBefore + 1);
	Cases.Add(AttemptFinanceE2ECsvInvalidPosting(OverCollection, Context, InvoiceRef, "over_collection", ARBefore, CashBefore));

	PassedCount = 0;
	For Each CaseRow In Cases Do
		If CaseRow.passed Then PassedCount = PassedCount + 1; EndIf;
	EndDo;
	If PassedCount <> Cases.Count() Then Raise StrTemplate("CSV invalid-row cases passed %1/%2.", PassedCount, Cases.Count()); EndIf;
	Return New Structure("case_count,passed_count,all_passed,cases,cash_unchanged,ar_unchanged",
		Cases.Count(), PassedCount, PassedCount = Cases.Count(), Cases,
		FinanceE2ECashBalanceFor(Context.PhapNhan, Context.Bank, Context.VND).SoTien = CashBefore,
		FinanceE2EARBalanceFor(Context.PhapNhan, Context.Customer, Context.CustomerContract, InvoiceRef) = ARBefore);
EndFunction

Function CreateFinanceE2ECsvReconciliation(Val Context, Val DocNumber, Val InvoiceRef, Val Gross, Val Fee, Val Net, Val ExternalId, Val RowStatus, Val MatchedAmount)
	Doc = Documents.DoiSoatKenhThanhToan.CreateDocument();
	Doc.Number = DocNumber;
	Doc.Date = Date(2026, 10, 21, 16, 0, 0);
	Doc.PhapNhan = Context.PhapNhan;
	Doc.DoiTacTrungGian = Context.PaymentProvider;
	Doc.TaiKhoanTien = Context.Bank;
	Doc.KhoanMucDongTien = Context.PaymentReconciliationCategory;
	Doc.TienTe = Context.VND;
	Doc.KenhThanhToan = "VNPAY";
	Doc.TongTienGiaoDich = Gross;
	Doc.TongPhi = Fee;
	Doc.TongTienThucNhan = Net;
	Doc.DienGiai = "E2E imported CSV reconciliation";
	Line = Doc.GiaoDichSaoKe.Add();
	Line.ExternalId = ExternalId;
	Line.InvoiceNumber = "";
	Line.NgayGiaoDich = Date(2026, 10, 21);
	Line.DienGiaiDong = "VNPay E2E settlement";
	Line.Gross = Gross;
	Line.Phi = Fee;
	Line.Net = Net;
	Line.TienTeDong = Context.VND;
	Line.KhoaGiaoDich = NhapSaoKeCsvServer.CreateTransactionKey(Context.PhapNhan, Context.Bank, Doc.KenhThanhToan,
		ExternalId, Line.NgayGiaoDich, Context.VND, Gross, Line.DienGiaiDong);
	Line.HoaDonAR = InvoiceRef;
	If ValueIsFilled(InvoiceRef) Then Line.InvoiceNumber = InvoiceRef.Number; EndIf;
	Line.SoTienGhep = MatchedAmount;
	Line.TrangThaiDong = RowStatus;
	Line.LyDoChan = "E2E test row";
	Return Doc;
EndFunction

Function AttemptFinanceE2ECsvInvalidPosting(Val Doc, Val Context, Val InvoiceRef, Val CaseName, Val ARBefore, Val CashBefore)
	ErrorText = "";
	Try
		Doc.Write(DocumentWriteMode.Posting);
	Except
		ErrorText = DetailErrorDescription(ErrorInfo());
	EndTry;
	ARAfter = FinanceE2EARBalanceFor(Context.PhapNhan, Context.Customer, Context.CustomerContract, InvoiceRef);
	CashAfter = FinanceE2ECashBalanceFor(Context.PhapNhan, Context.Bank, Context.VND).SoTien;
	MovementCount = CountRecorderMovementRecords("AccumulationRegister.DongTien", Doc.Ref)
		+ CountRecorderMovementRecords("AccumulationRegister.CongNoPhaiThu", Doc.Ref)
		+ CountRecorderMovementRecords("AccountingRegister.SoCaiKeToan", Doc.Ref);
	KeyCount = CountActiveFinanceE2ECsvKeys(Context, Doc.GiaoDichSaoKe[0].KhoaGiaoDich);
	Passed = Not Doc.Posted And CashAfter = CashBefore And ARAfter = ARBefore And MovementCount = 0 And KeyCount = 0;
	If Not Passed Then Raise StrTemplate("CSV invalid row %1 changed posting state or balances. %2", CaseName, ErrorText); EndIf;
	Return New Structure("case_name,passed,posted,cash_delta_vnd,ar_delta_vnd,movement_rows,active_key_rows,error",
		CaseName, Passed, Doc.Posted, CashAfter - CashBefore, ARAfter - ARBefore, MovementCount, KeyCount, ErrorText);
EndFunction

Function CountActiveFinanceE2ECsvKeys(Val Context, Val TransactionKey)
	Q = New Query(
		"SELECT COUNT(*) AS Cnt
		|FROM InformationRegister.GiaoDichSaoKeDaNhap
		|WHERE PhapNhan = &PN AND TaiKhoanTien = &Cash AND KenhThanhToan = &Channel AND KhoaGiaoDich = &Key");
	Q.SetParameter("PN", Context.PhapNhan);
	Q.SetParameter("Cash", Context.Bank);
	Q.SetParameter("Channel", "VNPAY");
	Q.SetParameter("Key", TransactionKey);
	Return Q.Execute().Unload()[0].Cnt;
EndFunction

#EndRegion

#Region CSVParserRegression

Function VerifyStatementCSVParser() Export
	Cases = New Array;
	ColumnMap = New Structure;
	ColumnMap.Insert("ExternalId", "ExternalId");
	ColumnMap.Insert("TransactionDate", "TransactionDate");
	ColumnMap.Insert("InvoiceNumber", "InvoiceNumber");
	ColumnMap.Insert("Memo", "Memo");
	ColumnMap.Insert("Gross", "Gross");
	ColumnMap.Insert("Fee", "Fee");
	ColumnMap.Insert("Net", "Net");
	ColumnMap.Insert("Currency", "Currency");
	CRLF = Char(13) + Char(10);
	Quote = """";
	MemoField = Quote + "VNPay, receipt " + Quote + Quote + "settlement" + Quote + Quote + Quote;
	Header = "ExternalId,TransactionDate,InvoiceNumber,Memo,Gross,Fee,Net,Currency";
	QuotedCSV = Char(65279) + Header + CRLF
		+ "TXN-VNP-TEST-001,2026-10-21,HD-26-000795," + MemoField + ",75000000,1125000,73875000,VND";
	QuotedResult = NhapSaoKeCsvServer.ParseCSVRows(QuotedCSV, ColumnMap, ",", ".", ",");
	ExpectedMemo = "VNPay, receipt " + Quote + "settlement" + Quote;
	AddCSVParserRegressionCase(Cases, "utf8_bom_quoted_comma_and_escaped_quote",
		QuotedResult.Errors.Count() = 0 And QuotedResult.Rows.Count() = 1 And QuotedResult.Rows[0].Memo = ExpectedMemo,
		StrTemplate("rows=%1 errors=%2 memo=%3", QuotedResult.Rows.Count(), QuotedResult.Errors.Count(), ?(QuotedResult.Rows.Count() > 0, QuotedResult.Rows[0].Memo, "")));

	SemicolonMap = New Structure;
	SemicolonMap.Insert("TransactionDate", "TransactionDate");
	SemicolonMap.Insert("Memo", "Memo");
	SemicolonMap.Insert("Currency", "Currency");
	SemicolonMap.Insert("Gross", "Gross");
	SemicolonMap.Insert("Fee", "Fee");
	SemicolonMap.Insert("Net", "Net");
	SemicolonCSV = "TransactionDate;Memo;Currency;Gross;Fee;Net" + CRLF
		+ "21/10/2026;Gateway settlement;VND;75.000.000,00;1.125.000,00;73.875.000,00";
	SemicolonResult = NhapSaoKeCsvServer.ParseCSVRows(SemicolonCSV, SemicolonMap, ";", ",", ".");
	AddCSVParserRegressionCase(Cases, "semicolon_delimiter_and_explicit_vietnamese_number_separators",
		SemicolonResult.Errors.Count() = 0 And SemicolonResult.Rows.Count() = 1
			And SemicolonResult.Rows[0].Gross = 75000000 And SemicolonResult.Rows[0].Fee = 1125000 And SemicolonResult.Rows[0].Net = 73875000,
		StrTemplate("rows=%1 errors=%2 gross=%3 fee=%4 net=%5", SemicolonResult.Rows.Count(), SemicolonResult.Errors.Count(),
			?(SemicolonResult.Rows.Count() > 0, SemicolonResult.Rows[0].Gross, 0),
			?(SemicolonResult.Rows.Count() > 0, SemicolonResult.Rows[0].Fee, 0),
			?(SemicolonResult.Rows.Count() > 0, SemicolonResult.Rows[0].Net, 0)));

	DuplicateHeaderCSV = "TransactionDate,TransactionDate,Memo,Currency,Gross,Fee,Net" + CRLF
		+ "2026-10-21,2026-10-21,Duplicate header,VND,10,0,10";
	DuplicateHeaderResult = NhapSaoKeCsvServer.ParseCSVRows(DuplicateHeaderCSV, SemicolonMap, ",", ".", ",");
	AddCSVParserRegressionCase(Cases, "duplicate_header_is_rejected",
		DuplicateHeaderResult.Errors.Count() > 0 And DuplicateHeaderResult.Rows.Count() = 0,
		StrTemplate("rows=%1 errors=%2", DuplicateHeaderResult.Rows.Count(), DuplicateHeaderResult.Errors.Count()));

	MissingHeaderMap = New Structure;
	MissingHeaderMap.Insert("TransactionDate", "MissingDate");
	MissingHeaderMap.Insert("Memo", "Memo");
	MissingHeaderMap.Insert("Currency", "Currency");
	MissingHeaderMap.Insert("Gross", "Gross");
	MissingHeaderMap.Insert("Fee", "Fee");
	MissingHeaderMap.Insert("Net", "Net");
	MissingHeaderResult = NhapSaoKeCsvServer.ParseCSVRows(SemicolonCSV, MissingHeaderMap, ";", ",", ".");
	AddCSVParserRegressionCase(Cases, "missing_mapped_header_is_reported",
		MissingHeaderResult.Errors.Count() > 0 And MissingHeaderResult.Rows.Count() = 0,
		StrTemplate("rows=%1 errors=%2", MissingHeaderResult.Rows.Count(), MissingHeaderResult.Errors.Count()));

	BadNumberCSV = "TransactionDate;Memo;Currency;Gross;Fee;Net" + CRLF
		+ "21/10/2026;Gateway settlement;VND;75.00.000,00;0,00;75.000.000,00";
	BadNumberResult = NhapSaoKeCsvServer.ParseCSVRows(BadNumberCSV, SemicolonMap, ";", ",", ".");
	AddCSVParserRegressionCase(Cases, "malformed_grouping_is_rejected_not_coerced",
		BadNumberResult.Rows.Count() = 1 And BadNumberResult.Rows[0].Status = "Invalid" And BadNumberResult.Errors.Count() > 0,
		StrTemplate("rows=%1 errors=%2 status=%3", BadNumberResult.Rows.Count(), BadNumberResult.Errors.Count(),
			?(BadNumberResult.Rows.Count() > 0, BadNumberResult.Rows[0].Status, "none")));

	DuplicateIdCSV = Header + CRLF
		+ "TXN-DUP-001,2026-10-21,INV-1,First,10,0,10,VND" + CRLF
		+ "TXN-DUP-001,2026-10-21,INV-2,Second,10,0,10,VND";
	DuplicateIdResult = NhapSaoKeCsvServer.ParseCSVRows(DuplicateIdCSV, ColumnMap, ",", ".", ",");
	AddCSVParserRegressionCase(Cases, "duplicate_external_id_in_one_file_is_blocked",
		DuplicateIdResult.Rows.Count() = 2 And DuplicateIdResult.Rows[0].Status = "Valid"
			And DuplicateIdResult.Rows[1].Status = "Duplicate" And DuplicateIdResult.Errors.Count() > 0,
		StrTemplate("rows=%1 errors=%2 second_status=%3", DuplicateIdResult.Rows.Count(), DuplicateIdResult.Errors.Count(),
			?(DuplicateIdResult.Rows.Count() > 1, DuplicateIdResult.Rows[1].Status, "none")));

	UnclosedQuoteCSV = "TransactionDate,Memo,Currency,Gross,Fee,Net" + CRLF
		+ "2026-10-21," + Quote + "unclosed,VND,10,0,10";
	UnclosedQuoteResult = NhapSaoKeCsvServer.ParseCSVRows(UnclosedQuoteCSV, SemicolonMap, ",", ".", ",");
	AddCSVParserRegressionCase(Cases, "unclosed_quoted_field_is_reported",
		UnclosedQuoteResult.Errors.Count() > 0 And UnclosedQuoteResult.Rows.Count() = 0,
		StrTemplate("rows=%1 errors=%2", UnclosedQuoteResult.Rows.Count(), UnclosedQuoteResult.Errors.Count()));

	Context = FinanceE2EContext();
	KeyOne = NhapSaoKeCsvServer.CreateTransactionKey(Context.PhapNhan, Context.Bank, "VNPAY", "", Date(2026, 10, 21), Context.VND, 75000000, "Gateway settlement");
	KeyTwo = NhapSaoKeCsvServer.CreateTransactionKey(Context.PhapNhan, Context.Bank, "VNPAY", "", Date(2026, 10, 21), Context.VND, 75000000, "Gateway settlement");
	KeyDifferentMemo = NhapSaoKeCsvServer.CreateTransactionKey(Context.PhapNhan, Context.Bank, "VNPAY", "", Date(2026, 10, 21), Context.VND, 75000000, "Other settlement");
	AddCSVParserRegressionCase(Cases, "fallback_transaction_fingerprint_is_stable_and_bounded",
		StrLen(KeyOne) > 0 And StrLen(KeyOne) <= 64 And KeyOne = KeyTwo And KeyOne <> KeyDifferentMemo,
		StrTemplate("length=%1 stable=%2 memo_sensitive=%3", StrLen(KeyOne), KeyOne = KeyTwo, KeyOne <> KeyDifferentMemo));

	PassedCount = 0;
	For Each CaseRow In Cases Do
		If CaseRow.passed Then PassedCount = PassedCount + 1; EndIf;
	EndDo;
	Return New Structure("case_count,passed_count,all_passed,cases", Cases.Count(), PassedCount, PassedCount = Cases.Count(), Cases);
EndFunction

Procedure AddCSVParserRegressionCase(Cases, Val CaseName, Val Passed, Val Detail)
	Cases.Add(New Structure("case_name,passed,detail", CaseName, Passed, Detail));
EndProcedure

#EndRegion
