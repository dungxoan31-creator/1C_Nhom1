#If Server Or ExternalConnection Then

Function RunVerification() Export
	Try
		ReportText = "=================================================================" + Chars.LF;
		ReportText = ReportText + "   VINSMART FUTURE - AP & CASH MANAGEMENT MVP VERIFICATION REPORT" + Chars.LF;
		ReportText = ReportText + "   Thoi gian chay: " + CurrentDate() + Chars.LF;
		ReportText = ReportText + "=================================================================" + Chars.LF + Chars.LF;

		// -1. Don dep du lieu kiem thu cu neu co
		QueryClean = New Query;
		QueryClean.Text = 
		"SELECT Ref AS Ref FROM Document.VendorInvoice
		|UNION ALL
		|SELECT Ref AS Ref FROM Document.CashPayment
		|UNION ALL
		|SELECT Ref AS Ref FROM Document.CashFlowPlan";
		ResClean = QueryClean.Execute().Select();
		While ResClean.Next() Do
			DocObj = ResClean.Ref.GetObject();
			If DocObj <> Undefined Then
				DocObj.Write(DocumentWriteMode.UndoPosting);
				DocObj.Delete();
			EndIf;
		EndDo;

		// 0. Khoi tao He thong Tai khoan Ke toan (Chart of Accounts)
		AccList = New Map;
		AccList.Insert("111", "Tien mat");
		AccList.Insert("112", "Tien gui ngan hang");
		AccList.Insert("156", "Linh kien & Hang hoa");
		AccList.Insert("331", "Phai tra cho nguoi ban");
		AccList.Insert("627", "Chi phi ha tang Cloud");
		AccList.Insert("642", "Chi phi ban quyen phan mem");

		For Each Item In AccList Do
			AccRef = ChartsOfAccounts.Main.FindByCode(Item.Key);
			If AccRef.IsEmpty() Then
				NewAcc = ChartsOfAccounts.Main.CreateAccount();
				NewAcc.Code = Item.Key;
				NewAcc.Order = Item.Key;
				NewAcc.Description = Item.Value;
				If Item.Key = "331" Then
					NewAcc.Type = AccountType.ActivePassive;
				Else
					NewAcc.Type = AccountType.Active;
				EndIf;
				NewAcc.Write();
			EndIf;
		EndDo;

		// 1. Khoi tao Danh muc (Catalogs)
		// 1.1. CashFlowItems
		ItemCloud = Catalogs.CashFlowItems.FindByDescription("Chi phí hạ tầng Cloud & Máy chủ");
		If ItemCloud.IsEmpty() Then
			Obj = Catalogs.CashFlowItems.CreateItem();
			Obj.Description = "Chi phí hạ tầng Cloud & Máy chủ";
			Obj.FlowType = Enums.CashFlowType.Outflow;
			Obj.Active = True;
			Obj.Write();
			ItemCloud = Obj.Ref;
		EndIf;

		ItemChipset = Catalogs.CashFlowItems.FindByDescription("Chi phí linh kiện & Phần cứng");
		If ItemChipset.IsEmpty() Then
			Obj = Catalogs.CashFlowItems.CreateItem();
			Obj.Description = "Chi phí linh kiện & Phần cứng";
			Obj.FlowType = Enums.CashFlowType.Outflow;
			Obj.Active = True;
			Obj.Write();
			ItemChipset = Obj.Ref;
		EndIf;

		ItemLicense = Catalogs.CashFlowItems.FindByDescription("Chi phí bản quyền phần mềm & R&D");
		If ItemLicense.IsEmpty() Then
			Obj = Catalogs.CashFlowItems.CreateItem();
			Obj.Description = "Chi phí bản quyền phần mềm & R&D";
			Obj.FlowType = Enums.CashFlowType.Outflow;
			Obj.Active = True;
			Obj.Write();
			ItemLicense = Obj.Ref;
		EndIf;

		// 1.2. Counterparties
		VendAWS = Catalogs.Counterparties.FindByDescription("AWS Cloud Services");
		If VendAWS.IsEmpty() Then
			Obj = Catalogs.Counterparties.CreateItem();
			Obj.Description = "AWS Cloud Services";
			Obj.Write();
			VendAWS = Obj.Ref;
		EndIf;

		VendQC = Catalogs.Counterparties.FindByDescription("Qualcomm Technologies");
		If VendQC.IsEmpty() Then
			Obj = Catalogs.Counterparties.CreateItem();
			Obj.Description = "Qualcomm Technologies";
			Obj.Write();
			VendQC = Obj.Ref;
		EndIf;

		VendJB = Catalogs.Counterparties.FindByDescription("JetBrains s.r.o");
		If VendJB.IsEmpty() Then
			Obj = Catalogs.Counterparties.CreateItem();
			Obj.Description = "JetBrains s.r.o";
			Obj.Write();
			VendJB = Obj.Ref;
		EndIf;

		// 1.3. Contracts
		ContractAWS = Catalogs.Contracts.FindByDescription("HĐ Điện toán đám mây #AWS-2026-01", , , VendAWS);
		If ContractAWS.IsEmpty() Then
			Obj = Catalogs.Contracts.CreateItem();
			Obj.Owner = VendAWS;
			Obj.Description = "HĐ Điện toán đám mây #AWS-2026-01";
			Obj.PaymentTermsDays = 30;
			Obj.DefaultCashFlowItem = ItemCloud;
			Obj.Write();
			ContractAWS = Obj.Ref;
		EndIf;

		ContractQC = Catalogs.Contracts.FindByDescription("HĐ Cung ứng Chipset 5G #QC-2026-08", , , VendQC);
		If ContractQC.IsEmpty() Then
			Obj = Catalogs.Contracts.CreateItem();
			Obj.Owner = VendQC;
			Obj.Description = "HĐ Cung ứng Chipset 5G #QC-2026-08";
			Obj.PaymentTermsDays = 45;
			Obj.DefaultCashFlowItem = ItemChipset;
			Obj.Write();
			ContractQC = Obj.Ref;
		EndIf;

		// 1.4. CashAccounts
		BankTCB = Catalogs.CashAccounts.FindByDescription("Techcombank VND - 1903686868");
		If BankTCB.IsEmpty() Then
			Obj = Catalogs.CashAccounts.CreateItem();
			Obj.Description = "Techcombank VND - 1903686868";
			Obj.AccountType = Enums.CashAccountTypes.BankAccount;
			Obj.AccountNumber = "1903686868";
			Obj.BankName = "Techcombank";
			Obj.Write();
			BankTCB = Obj.Ref;
		EndIf;

		// 2. Lập Hóa đơn VendorInvoice
		BaseDate = Date(2026, 10, 1, 9, 0, 0);

		// Hóa đơn AWS: 100,000,000 VND
		InvAWS = Documents.VendorInvoice.CreateDocument();
		InvAWS.Date = BaseDate;
		InvAWS.VendorInvoiceNumber = "INV-AWS-202610-01";
		InvAWS.Counterparty = VendAWS;
		InvAWS.Contract = ContractAWS;
		InvAWS.CashFlowItem = ItemCloud;
		InvAWS.TotalAmount = 100000000;
		InvAWS.Write(DocumentWriteMode.Posting);
		RefInvAWS = InvAWS.Ref;

		// Hóa đơn Qualcomm: 200,000,000 VND
		InvQC = Documents.VendorInvoice.CreateDocument();
		InvQC.Date = BaseDate;
		InvQC.VendorInvoiceNumber = "INV-QC-202610-08";
		InvQC.Counterparty = VendQC;
		InvQC.Contract = ContractQC;
		InvQC.CashFlowItem = ItemChipset;
		InvQC.TotalAmount = 200000000;
		InvQC.Write(DocumentWriteMode.Posting);
		RefInvQC = InvQC.Ref;

		// 3. Lập Kế hoạch Dòng tiền CashFlowPlan cho tháng 10/2026
		PlanDoc = Documents.CashFlowPlan.CreateDocument();
		PlanDoc.Date = BaseDate;
		PlanDoc.PlanPeriod = BaseDate;
		PlanDoc.Description = "Ke hoach chi tra cong no thang 10/2026";
		PlanDoc.FillFromDueDates(Date(2026, 10, 1), Date(2026, 10, 31, 23, 59, 59));
		PlanDoc.Write(DocumentWriteMode.Posting);

		// 4. Lập Phiếu chi CashPayment trả 40,000,000 VND cho AWS Cloud
		PayDate = Date(2026, 10, 3, 14, 0, 0);
		PayDoc = Documents.CashPayment.CreateDocument();
		PayDoc.Date = PayDate;
		PayDoc.Counterparty = VendAWS;
		PayDoc.Contract = ContractAWS;
		PayDoc.Account = BankTCB;
		PayDoc.CashFlowItem = ItemCloud;
		PayDoc.PaymentAmount = 40000000;
		PayDoc.Memo = "Thanh toan dot 1 hoa don AWS Cloud";
		
		AllocRow = PayDoc.PaymentAllocation.Add();
		AllocRow.Invoice = RefInvAWS;
		AllocRow.AllocatedAmount = 40000000;
		PayDoc.Write(DocumentWriteMode.Posting);

		// 5. Kiểm tra 9 Tiêu chí Definition of Done (DoD)
		AllPassed = True;

		// DoD 1 & 2: Số dư chi tiết nợ của AWS và Qualcomm
		QueryAP = New Query;
		QueryAP.Text = 
		"SELECT
		|	AP.Counterparty AS Counterparty,
		|	SUM(AP.AmountBalance) AS Balance
		|FROM
		|	AccumulationRegister.AccountsPayable.Balance AS AP
		|GROUP BY
		|	AP.Counterparty";
		ResAP = QueryAP.Execute().Unload();

		BalAWS = 0;
		BalQC = 0;
		For Each Row In ResAP Do
			If Row.Counterparty = VendAWS Then
				BalAWS = Row.Balance;
			ElsIf Row.Counterparty = VendQC Then
				BalQC = Row.Balance;
			EndIf;
		EndDo;

		// DoD 1
		Passed1 = (BalAWS = 60000000);
		ReportText = ReportText + "[DoD 1] Du no chi tiet AWS Cloud Services (100tr - 40tr = 60tr): " + ?(Passed1, "PASS (60,000,000 VND)", "FAIL (" + BalAWS + ")") + Chars.LF;
		If Not Passed1 Then AllPassed = False; EndIf;

		// DoD 2
		Passed2 = (BalQC = 200000000);
		ReportText = ReportText + "[DoD 2] Du no chi tiet Qualcomm Technologies (200tr): " + ?(Passed2, "PASS (200,000,000 VND)", "FAIL (" + BalQC + ")") + Chars.LF;
		If Not Passed2 Then AllPassed = False; EndIf;

		// DoD 3: Tổng số dư Sổ chi tiết AP
		TotalAP = BalAWS + BalQC;
		Passed3 = (TotalAP = 260000000);
		ReportText = ReportText + "[DoD 3] Tong du no So chi tiet AP (60tr + 200tr = 260tr): " + ?(Passed3, "PASS (260,000,000 VND)", "FAIL (" + TotalAP + ")") + Chars.LF;
		If Not Passed3 Then AllPassed = False; EndIf;

		// DoD 4: Số dư Có TK 331 trên GeneralLedger
		QueryGL = New Query;
		QueryGL.Text = 
		"SELECT
		|	SUM(GL.AmountBalanceCr) AS BalanceCredit
		|FROM
		|	AccountingRegister.GeneralLedger.Balance(, Account.Code = ""331"") AS GL";
		ResGL = QueryGL.Execute().Unload();
		BalGL = 0;
		If ResGL.Count() > 0 And ValueIsFilled(ResGL[0].BalanceCredit) Then
			BalGL = ResGL[0].BalanceCredit;
		EndIf;
		Passed4 = (BalGL = 260000000);
		ReportText = ReportText + "[DoD 4] Tong so du Co TK 331 tren So cai GeneralLedger: " + ?(Passed4, "PASS (260,000,000 VND)", "FAIL (" + BalGL + ")") + Chars.LF;
		If Not Passed4 Then AllPassed = False; EndIf;

		// DoD 5: Đối chiếu AP vs Sổ cái TK 331 (Variance = 0)
		Variance = TotalAP - BalGL;
		Passed5 = (Variance = 0);
		ReportText = ReportText + "[DoD 5] Doi chieu So chi tiet AP va TK 331 (Variance = 0): " + ?(Passed5, "PASS (Variance = 0.00)", "FAIL (Variance = " + Variance + ")") + Chars.LF;
		If Not Passed5 Then AllPassed = False; EndIf;

		// DoD 6: Dòng tiền thực chi (CashFlow Expense)
		QueryCF = New Query;
		QueryCF.Text = 
		"SELECT
		|	SUM(CF.AmountExpense) AS ExpenseTurnover
		|FROM
		|	AccumulationRegister.CashFlow.Turnovers AS CF";
		ResCF = QueryCF.Execute().Unload();
		ExpCF = 0;
		If ResCF.Count() > 0 And ValueIsFilled(ResCF[0].ExpenseTurnover) Then
			ExpCF = ResCF[0].ExpenseTurnover;
		EndIf;
		Passed6 = (ExpCF = 40000000);
		ReportText = ReportText + "[DoD 6] Dong tien thuc chi ghi nhan tren So CashFlow: " + ?(Passed6, "PASS (40,000,000 VND)", "FAIL (" + ExpCF + ")") + Chars.LF;
		If Not Passed6 Then AllPassed = False; EndIf;

		// DoD 7: Tính toán DueDate tự động chính xác theo Hợp đồng
		Passed7 = (InvAWS.DueDate = Date(2026, 10, 31)) And (InvQC.DueDate = Date(2026, 11, 15));
		ReportText = ReportText + "[DoD 7] Tinh DueDate tu dong (AWS Net 30 -> 31/10/2026, Qualcomm Net 45 -> 15/11/2026): " + ?(Passed7, "PASS", "FAIL") + Chars.LF;
		If Not Passed7 Then AllPassed = False; EndIf;

		// DoD 8: Báo cáo đối chiếu biến động công nợ NCC (Supplier Statement)
		QueryStmt = New Query;
		QueryStmt.Text = 
		"SELECT
		|	AP.AmountOpeningBalance AS Op,
		|	AP.AmountReceipt AS Rcpt,
		|	AP.AmountExpense AS Exp,
		|	AP.AmountClosingBalance AS Cl
		|FROM
		|	AccumulationRegister.AccountsPayable.BalanceAndTurnovers(, , Auto, , Counterparty = &Counterparty) AS AP";
		QueryStmt.SetParameter("Counterparty", VendAWS);
		ResStmt = QueryStmt.Execute().Unload();
		Passed8 = False;
		If ResStmt.Count() > 0 Then
			RowS = ResStmt[0];
			Passed8 = (RowS.Op = 0) And (RowS.Rcpt = 100000000) And (RowS.Exp = 40000000) And (RowS.Cl = 60000000);
		EndIf;
		ReportText = ReportText + "[DoD 8] Bien dong cong no AWS (Dau ky: 0, Mua: 100tr, Tra: 40tr, Cuoi ky: 60tr): " + ?(Passed8, "PASS", "FAIL") + Chars.LF;
		If Not Passed8 Then AllPassed = False; EndIf;

		// DoD 9: Kế hoạch chi vs Thực tế (Actual vs Plan)
		QueryAvP = New Query;
		QueryAvP.Text = 
		"SELECT
		|	SUM(CFP.PlannedAmountTurnover) AS PlanAmt
		|FROM
		|	AccumulationRegister.CashFlowPlan.Turnovers AS CFP
		|WHERE
		|	CFP.CashFlowItem = &ItemCloud";
		QueryAvP.SetParameter("ItemCloud", ItemCloud);
		ResAvP = QueryAvP.Execute().Unload();
		PlanAmt = 0;
		If ResAvP.Count() > 0 And ValueIsFilled(ResAvP[0].PlanAmt) Then
			PlanAmt = ResAvP[0].PlanAmt;
		EndIf;
		Passed9 = (PlanAmt = 100000000) And (ExpCF = 40000000);
		ReportText = ReportText + "[DoD 9] Actual vs Plan (Ke hoach thang 10: 100tr, Thuc chi: 40tr, Chenh lech: 60tr): " + ?(Passed9, "PASS", "FAIL") + Chars.LF;
		If Not Passed9 Then AllPassed = False; EndIf;

		ReportText = ReportText + Chars.LF + "=================================================================" + Chars.LF;
		If AllPassed Then
			StatusStr = "TAT CA 9 TIEU CHI DOD HOAN TOAN DAT CHUAN (100% PASS)";
		Else
			StatusStr = "CO TIEU CHI CHUA DAT";
		EndIf;
		ReportText = ReportText + "   KET QUA CHUNG CUOC: " + StatusStr + Chars.LF;
		ReportText = ReportText + "=================================================================" + Chars.LF;

		// Ghi ra file bao cao nghiem thu
		TextWriter = New TextWriter("C:/Users/Dung/Documents/1C_Enterprise/VinSmart_Future_AP_DoD_Report.txt", TextEncoding.UTF8);
		TextWriter.Write(ReportText);
		TextWriter.Close();

		Return AllPassed;
	Except
		Err = ErrorDescription();
		TextWriter = New TextWriter("C:/Users/Dung/Documents/1C_Enterprise/VinSmart_Future_AP_DoD_Report.txt", TextEncoding.UTF8);
		TextWriter.Write("EXCEPTION IN RUNVERIFICATION:" + Chars.LF + Err);
		TextWriter.Close();
		Return False;
	EndTry;
EndFunction

#EndIf
