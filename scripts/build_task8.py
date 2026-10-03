import os
import uuid

def uid():
    return str(uuid.uuid4())

def build_task8():
    print("Building Task 8: Automated Verification Module & DoD Test Runner...")
    os.makedirs("src/CommonModules/APVerification/Ext", exist_ok=True)

    # 1. CommonModule Metadata
    cm_id = uid()
    cm_xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<MetaDataObject xmlns="http://v8.1c.ru/8.3/MDClasses" xmlns:app="http://v8.1c.ru/8.2/managed-application/core" xmlns:cfg="http://v8.1c.ru/8.1/data/enterprise/current-config" xmlns:cmi="http://v8.1c.ru/8.2/managed-application/cmi" xmlns:ent="http://v8.1c.ru/8.1/data/enterprise" xmlns:lf="http://v8.1c.ru/8.2/managed-application/logform" xmlns:style="http://v8.1c.ru/8.1/data/ui/style" xmlns:sys="http://v8.1c.ru/8.1/data/ui/fonts/system" xmlns:v8="http://v8.1c.ru/8.1/data/core" xmlns:v8ui="http://v8.1c.ru/8.1/data/ui" xmlns:web="http://v8.1c.ru/8.1/data/ui/colors/web" xmlns:win="http://v8.1c.ru/8.1/data/ui/colors/windows" xmlns:xen="http://v8.1c.ru/8.3/xcf/enums" xmlns:xpr="http://v8.1c.ru/8.3/xcf/predef" xmlns:xr="http://v8.1c.ru/8.3/xcf/readable" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.15">
\t<CommonModule uuid="{cm_id}">
\t\t<Properties>
\t\t\t<Name>APVerification</Name>
\t\t\t<Synonym>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t<v8:content>AP Verification (Kiem thu tu dong AP)</v8:content>
\t\t\t\t</v8:item>
\t\t\t</Synonym>
\t\t\t<Comment/>
\t\t\t<Global>false</Global>
\t\t\t<ClientManagedApplication>false</ClientManagedApplication>
\t\t\t<Server>true</Server>
\t\t\t<ExternalConnection>false</ExternalConnection>
\t\t\t<ClientOrdinaryApplication>false</ClientOrdinaryApplication>
\t\t\t<ServerCall>true</ServerCall>
\t\t\t<Privileged>false</Privileged>
\t\t\t<ReturnValuesReuse>DontUse</ReturnValuesReuse>
\t\t</Properties>
\t</CommonModule>
</MetaDataObject>"""

    with open("src/CommonModules/APVerification.xml", "w", encoding="utf-8") as f:
        f.write(cm_xml)

    # 2. BSL Code for APVerification
    bsl_code = """Function RunVerification() Export
\tReportText = "=================================================================" + Chars.LF;
\tReportText = ReportText + "   VINSMART FUTURE - AP & CASH MANAGEMENT MVP VERIFICATION REPORT" + Chars.LF;
\tReportText = ReportText + "   Thoi gian chay: " + CurrentDate() + Chars.LF;
\tReportText = ReportText + "=================================================================" + Chars.LF + Chars.LF;

\t// 1. Khoi tao Danh muc (Catalogs)
\t// 1.1. CashFlowItems
\tItemCloud = Catalogs.CashFlowItems.FindByDescription("Chi phí hạ tầng Cloud & Máy chủ");
\tIf ItemCloud.IsEmpty() Then
\t\tObj = Catalogs.CashFlowItems.CreateItem();
\t\tObj.Description = "Chi phí hạ tầng Cloud & Máy chủ";
\t\tObj.CashFlowType = Enums.CashFlowType.Outflow;
\t\tObj.Active = True;
\t\tObj.Write();
\t\tItemCloud = Obj.Ref;
\tEndIf;

\tItemChipset = Catalogs.CashFlowItems.FindByDescription("Chi phí linh kiện & Phần cứng");
\tIf ItemChipset.IsEmpty() Then
\t\tObj = Catalogs.CashFlowItems.CreateItem();
\t\tObj.Description = "Chi phí linh kiện & Phần cứng";
\t\tObj.CashFlowType = Enums.CashFlowType.Outflow;
\t\tObj.Active = True;
\t\tObj.Write();
\t\tItemChipset = Obj.Ref;
\tEndIf;

\tItemLicense = Catalogs.CashFlowItems.FindByDescription("Chi phí bản quyền phần mềm & R&D");
\tIf ItemLicense.IsEmpty() Then
\t\tObj = Catalogs.CashFlowItems.CreateItem();
\t\tObj.Description = "Chi phí bản quyền phần mềm & R&D";
\t\tObj.CashFlowType = Enums.CashFlowType.Outflow;
\t\tObj.Active = True;
\t\tObj.Write();
\t\tItemLicense = Obj.Ref;
\tEndIf;

\t// 1.2. Counterparties
\tVendAWS = Catalogs.Counterparties.FindByDescription("AWS Cloud Services");
\tIf VendAWS.IsEmpty() Then
\t\tObj = Catalogs.Counterparties.CreateItem();
\t\tObj.Description = "AWS Cloud Services";
\t\tObj.Write();
\t\tVendAWS = Obj.Ref;
\tEndIf;

\tVendQC = Catalogs.Counterparties.FindByDescription("Qualcomm Technologies");
\tIf VendQC.IsEmpty() Then
\t\tObj = Catalogs.Counterparties.CreateItem();
\t\tObj.Description = "Qualcomm Technologies";
\t\tObj.Write();
\t\tVendQC = Obj.Ref;
\tEndIf;

\tVendJB = Catalogs.Counterparties.FindByDescription("JetBrains s.r.o");
\tIf VendJB.IsEmpty() Then
\t\tObj = Catalogs.Counterparties.CreateItem();
\t\tObj.Description = "JetBrains s.r.o";
\t\tObj.Write();
\t\tVendJB = Obj.Ref;
\tEndIf;

\t// 1.3. Contracts
\tContractAWS = Catalogs.Contracts.FindByDescription("HĐ Điện toán đám mây #AWS-2026-01", , , VendAWS);
\tIf ContractAWS.IsEmpty() Then
\t\tObj = Catalogs.Contracts.CreateItem();
\t\tObj.Owner = VendAWS;
\t\tObj.Description = "HĐ Điện toán đám mây #AWS-2026-01";
\t\tObj.PaymentTermsDays = 30;
\t\tObj.DefaultCashFlowItem = ItemCloud;
\t\tObj.Write();
\t\tContractAWS = Obj.Ref;
\tEndIf;

\tContractQC = Catalogs.Contracts.FindByDescription("HĐ Cung ứng Chipset 5G #QC-2026-08", , , VendQC);
\tIf ContractQC.IsEmpty() Then
\t\tObj = Catalogs.Contracts.CreateItem();
\t\tObj.Owner = VendQC;
\t\tObj.Description = "HĐ Cung ứng Chipset 5G #QC-2026-08";
\t\tObj.PaymentTermsDays = 45;
\t\tObj.DefaultCashFlowItem = ItemChipset;
\t\tObj.Write();
\t\tContractQC = Obj.Ref;
\tEndIf;

\t// 1.4. CashAccounts
\tBankTCB = Catalogs.CashAccounts.FindByDescription("Techcombank VND - 1903686868");
\tIf BankTCB.IsEmpty() Then
\t\tObj = Catalogs.CashAccounts.CreateItem();
\t\tObj.Description = "Techcombank VND - 1903686868";
\t\tObj.AccountType = Enums.CashAccountTypes.Bank;
\t\tObj.Currency = "VND";
\t\tObj.Active = True;
\t\tObj.Write();
\t\tBankTCB = Obj.Ref;
\tEndIf;

\t// 2. Lập Hóa đơn VendorInvoice
\tBaseDate = Date(2026, 10, 1, 9, 0, 0);

\t// Hóa đơn AWS: 100,000,000 VND
\tInvAWS = Documents.VendorInvoice.CreateDocument();
\tInvAWS.Date = BaseDate;
\tInvAWS.Company = "VinSmart Future";
\tInvAWS.Counterparty = VendAWS;
\tInvAWS.Contract = ContractAWS;
\tInvAWS.CashFlowItem = ItemCloud;
\tInvAWS.TotalAmount = 100000000;
\tInvAWS.Description = "Chi phi ha tang Cloud thang 10/2026";
\tInvAWS.Write(DocumentWriteMode.Posting);
\tRefInvAWS = InvAWS.Ref;

\t// Hóa đơn Qualcomm: 200,000,000 VND
\tInvQC = Documents.VendorInvoice.CreateDocument();
\tInvQC.Date = BaseDate;
\tInvQC.Company = "VinSmart Future";
\tInvQC.Counterparty = VendQC;
\tInvQC.Contract = ContractQC;
\tInvQC.CashFlowItem = ItemChipset;
\tInvQC.TotalAmount = 200000000;
\tInvQC.Description = "Linh kien Chipset AIoT lo #QC-889";
\tInvQC.Write(DocumentWriteMode.Posting);
\tRefInvQC = InvQC.Ref;

\t// 3. Lập Kế hoạch Dòng tiền CashFlowPlan cho tháng 10/2026
\tPlanDoc = Documents.CashFlowPlan.CreateDocument();
\tPlanDoc.Date = BaseDate;
\tPlanDoc.PlanPeriod = BaseDate;
\tPlanDoc.Description = "Ke hoach chi tra cong no thang 10/2026";
\tPlanDoc.FillFromDueDates(Date(2026, 10, 1), Date(2026, 10, 31, 23, 59, 59));
\tPlanDoc.Write(DocumentWriteMode.Posting);

\t// 4. Lập Phiếu chi CashPayment trả 40,000,000 VND cho AWS Cloud
\tPayDate = Date(2026, 10, 3, 14, 0, 0);
\tPayDoc = Documents.CashPayment.CreateDocument();
\tPayDoc.Date = PayDate;
\tPayDoc.Company = "VinSmart Future";
\tPayDoc.Counterparty = VendAWS;
\tPayDoc.Contract = ContractAWS;
\tPayDoc.Account = BankTCB;
\tPayDoc.CashFlowItem = ItemCloud;
\tPayDoc.PaymentAmount = 40000000;
\tPayDoc.Description = "Thanh toan dot 1 hoa don AWS Cloud";
\t
\tAllocRow = PayDoc.PaymentAllocation.Add();
\tAllocRow.Invoice = RefInvAWS;
\tAllocRow.AllocatedAmount = 40000000;
\tPayDoc.Write(DocumentWriteMode.Posting);

\t// 5. Kiểm tra 9 Tiêu chí Definition of Done (DoD)
\tAllPassed = True;

\t// DoD 1 & 2: Số dư chi tiết nợ của AWS và Qualcomm
\tQueryAP = New Query;
\tQueryAP.Text = 
\t"SELECT
\t|	AP.Counterparty AS Counterparty,
\t|	SUM(AP.AmountBalance) AS Balance
\t|FROM
\t|	AccumulationRegister.AccountsPayable.Balance AS AP
\t|GROUP BY
\t|	AP.Counterparty";
\tResAP = QueryAP.Execute().Unload();

\tBalAWS = 0;
\tBalQC = 0;
\tFor Each Row In ResAP Do
\t\tIf Row.Counterparty = VendAWS Then
\t\t\tBalAWS = Row.Balance;
\t\tElsIf Row.Counterparty = VendQC Then
\t\t\tBalQC = Row.Balance;
\t\tEndIf;
\tEndDo;

\t// DoD 1
\tPassed1 = (BalAWS = 60000000);
\tReportText = ReportText + "[DoD 1] Du no chi tiet AWS Cloud Services (100tr - 40tr = 60tr): " + ?(Passed1, "PASS (60,000,000 VND)", "FAIL (" + BalAWS + ")") + Chars.LF;
\tIf Not Passed1 Then AllPassed = False; EndIf;

\t// DoD 2
\tPassed2 = (BalQC = 200000000);
\tReportText = ReportText + "[DoD 2] Du no chi tiet Qualcomm Technologies (200tr): " + ?(Passed2, "PASS (200,000,000 VND)", "FAIL (" + BalQC + ")") + Chars.LF;
\tIf Not Passed2 Then AllPassed = False; EndIf;

\t// DoD 3: Tổng số dư Sổ chi tiết AP
\tTotalAP = BalAWS + BalQC;
\tPassed3 = (TotalAP = 260000000);
\tReportText = ReportText + "[DoD 3] Tong du no So chi tiet AP (60tr + 200tr = 260tr): " + ?(Passed3, "PASS (260,000,000 VND)", "FAIL (" + TotalAP + ")") + Chars.LF;
\tIf Not Passed3 Then AllPassed = False; EndIf;

\t// DoD 4: Số dư Có TK 331 trên GeneralLedger
\tQueryGL = New Query;
\tQueryGL.Text = 
\t"SELECT
\t|	SUM(GL.AmountBalanceCredit) AS BalanceCredit
\t|FROM
\t|	AccountingRegister.GeneralLedger.Balance(, Account.Code = ""331"") AS GL";
\tResGL = QueryGL.Execute().Unload();
\tBalGL = 0;
\tIf ResGL.Count() > 0 And ValueIsFilled(ResGL[0].BalanceCredit) Then
\t\tBalGL = ResGL[0].BalanceCredit;
\tEndIf;
\tPassed4 = (BalGL = 260000000);
\tReportText = ReportText + "[DoD 4] Tong so du Co TK 331 tren So cai GeneralLedger: " + ?(Passed4, "PASS (260,000,000 VND)", "FAIL (" + BalGL + ")") + Chars.LF;
\tIf Not Passed4 Then AllPassed = False; EndIf;

\t// DoD 5: Đối chiếu AP vs Sổ cái TK 331 (Variance = 0)
\tVariance = TotalAP - BalGL;
\tPassed5 = (Variance = 0);
\tReportText = ReportText + "[DoD 5] Doi chieu So chi tiet AP va TK 331 (Variance = 0): " + ?(Passed5, "PASS (Variance = 0.00)", "FAIL (Variance = " + Variance + ")") + Chars.LF;
\tIf Not Passed5 Then AllPassed = False; EndIf;

\t// DoD 6: Dòng tiền thực chi (CashFlow Expense)
\tQueryCF = New Query;
\tQueryCF.Text = 
\t"SELECT
\t|	SUM(CF.AmountExpenseTurnover) AS ExpenseTurnover
\t|FROM
\t|	AccumulationRegister.CashFlow.Turnovers AS CF";
\tResCF = QueryCF.Execute().Unload();
\tExpCF = 0;
\tIf ResCF.Count() > 0 And ValueIsFilled(ResCF[0].ExpenseTurnover) Then
\t\tExpCF = ResCF[0].ExpenseTurnover;
\tEndIf;
\tPassed6 = (ExpCF = 40000000);
\tReportText = ReportText + "[DoD 6] Dong tien thuc chi ghi nhan tren So CashFlow: " + ?(Passed6, "PASS (40,000,000 VND)", "FAIL (" + ExpCF + ")") + Chars.LF;
\tIf Not Passed6 Then AllPassed = False; EndIf;

\t// DoD 7: Tính toán DueDate tự động chính xác theo Hợp đồng
\tPassed7 = (InvAWS.DueDate = Date(2026, 10, 31)) And (InvQC.DueDate = Date(2026, 11, 15));
\tReportText = ReportText + "[DoD 7] Tinh DueDate tu dong (AWS Net 30 -> 31/10/2026, Qualcomm Net 45 -> 15/11/2026): " + ?(Passed7, "PASS", "FAIL") + Chars.LF;
\tIf Not Passed7 Then AllPassed = False; EndIf;

\t// DoD 8: Báo cáo đối chiếu biến động công nợ NCC (Supplier Statement)
\tQueryStmt = New Query;
\tQueryStmt.Text = 
\t"SELECT
\t|	AP.AmountOpeningBalance AS Op,
\t|	AP.AmountReceipt AS Rcpt,
\t|	AP.AmountExpense AS Exp,
\t|	AP.AmountClosingBalance AS Cl
\t|FROM
\t|	AccumulationRegister.AccountsPayable.BalanceAndTurnovers(, , Auto, , Counterparty = &Counterparty) AS AP";
\tQueryStmt.SetParameter("Counterparty", VendAWS);
\tResStmt = QueryStmt.Execute().Unload();
\tPassed8 = False;
\tIf ResStmt.Count() > 0 Then
\t\tRowS = ResStmt[0];
\t\tPassed8 = (RowS.Op = 0) And (RowS.Rcpt = 100000000) And (RowS.Exp = 40000000) And (RowS.Cl = 60000000);
\tEndIf;
\tReportText = ReportText + "[DoD 8] Bien dong cong no AWS (Dau ky: 0, Mua: 100tr, Tra: 40tr, Cuoi ky: 60tr): " + ?(Passed8, "PASS", "FAIL") + Chars.LF;
\tIf Not Passed8 Then AllPassed = False; EndIf;

\t// DoD 9: Kế hoạch chi vs Thực tế (Actual vs Plan)
\tQueryAvP = New Query;
\tQueryAvP.Text = 
\t"SELECT
\t|	SUM(CFP.PlannedAmountTurnover) AS PlanAmt
\t|FROM
\t|	AccumulationRegister.CashFlowPlan.Turnovers AS CFP
\t|WHERE
\t|	CFP.CashFlowItem = &ItemCloud";
\tQueryAvP.SetParameter("ItemCloud", ItemCloud);
\tResAvP = QueryAvP.Execute().Unload();
\tPlanAmt = 0;
\tIf ResAvP.Count() > 0 And ValueIsFilled(ResAvP[0].PlanAmt) Then
\t\tPlanAmt = ResAvP[0].PlanAmt;
\tEndIf;
\tPassed9 = (PlanAmt = 100000000) And (ExpCF = 40000000);
\tReportText = ReportText + "[DoD 9] Actual vs Plan (Ke hoach thang 10: 100tr, Thuc chi: 40tr, Chenh lech: 60tr): " + ?(Passed9, "PASS", "FAIL") + Chars.LF;
\tIf Not Passed9 Then AllPassed = False; EndIf;

\tReportText = ReportText + Chars.LF + "=================================================================" + Chars.LF;
\tReportText = ReportText + "   KET QUA CHUNG CUOC: " + ?(AllPassed, ">>> TAT CA 9 TIEU CHI DOD HOAN TOAN DAT CHUAN (100% PASS) <<<", ">>> CO TIEU CHI CHUA DAT <<<") + Chars.LF;
\tReportText = ReportText + "=================================================================" + Chars.LF;

\t// Ghi ra file bao cao nghiem thu
\tTextWriter = New TextWriter("C:\\Users\\Dung\\Documents\\1C_Enterprise\\VinSmart_Future_AP_DoD_Report.txt", TextEncoding.UTF8);
\tTextWriter.Write(ReportText);
\tTextWriter.Close();

\tReturn AllPassed;
EndFunction
"""
    with open("src/CommonModules/APVerification/Ext/Module.bsl", "w", encoding="utf-8") as f:
        f.write(bsl_code)

    # 3. Update ManagedApplicationModule.bsl
    app_bsl = """Procedure OnStart()
\tIf LaunchParameter = "RunDoD" Then
\t\tAPVerification.RunVerification();
\t\tExit(False);
\tEndIf;
EndProcedure
"""
    with open("src/Ext/ManagedApplicationModule.bsl", "w", encoding="utf-8") as f:
        f.write(app_bsl)

    # 4. Register in Configuration.xml
    with open("src/Configuration.xml", "r", encoding="utf-8") as f:
        cfg = f.read()

    if "<CommonModule>APVerification</CommonModule>" not in cfg:
        cfg = cfg.replace("\t\t</ChildObjects>", "\t\t\t<CommonModule>APVerification</CommonModule>\n\t\t</ChildObjects>")
        with open("src/Configuration.xml", "w", encoding="utf-8") as f:
            f.write(cfg)

    # 5. Register in Subsystems/AccountsPayable.xml
    with open("src/Subsystems/AccountsPayable.xml", "r", encoding="utf-8") as f:
        ss = f.read()

    if "CommonModule.APVerification" not in ss:
        ss = ss.replace("\t\t\t</Content>", "\t\t\t\t<xr:Item xsi:type=\"xr:MDObjectRef\">CommonModule.APVerification</xr:Item>\n\t\t\t</Content>")
        with open("src/Subsystems/AccountsPayable.xml", "w", encoding="utf-8") as f:
            f.write(ss)

    print("Task 8: APVerification module created and registered successfully!")

if __name__ == "__main__":
    build_task8()
