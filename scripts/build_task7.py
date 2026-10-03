import os
import uuid

def uid():
    return str(uuid.uuid4())

def create_report_files(name, synonym, query_text, fields, total_fields, group_fields):
    rep_dir = f"src/Reports/{name}"
    tmpl_dir = f"{rep_dir}/Templates/MainDataCompositionSchema/Ext"
    os.makedirs(tmpl_dir, exist_ok=True)

    # 1. Report Metadata XML
    rep_uuid = uid()
    rep_xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<MetaDataObject xmlns="http://v8.1c.ru/8.3/MDClasses" xmlns:app="http://v8.1c.ru/8.2/managed-application/core" xmlns:cfg="http://v8.1c.ru/8.1/data/enterprise/current-config" xmlns:cmi="http://v8.1c.ru/8.2/managed-application/cmi" xmlns:ent="http://v8.1c.ru/8.1/data/enterprise" xmlns:lf="http://v8.1c.ru/8.2/managed-application/logform" xmlns:style="http://v8.1c.ru/8.1/data/ui/style" xmlns:sys="http://v8.1c.ru/8.1/data/ui/fonts/system" xmlns:v8="http://v8.1c.ru/8.1/data/core" xmlns:v8ui="http://v8.1c.ru/8.1/data/ui" xmlns:web="http://v8.1c.ru/8.1/data/ui/colors/web" xmlns:win="http://v8.1c.ru/8.1/data/ui/colors/windows" xmlns:xen="http://v8.1c.ru/8.3/xcf/enums" xmlns:xpr="http://v8.1c.ru/8.3/xcf/predef" xmlns:xr="http://v8.1c.ru/8.3/xcf/readable" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.15">
\t<Report uuid="{rep_uuid}">
\t\t<InternalInfo>
\t\t\t<xr:GeneratedType name="ReportObject.{name}" category="Object">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="ReportManager.{name}" category="Manager">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t</InternalInfo>
\t\t<Properties>
\t\t\t<Name>{name}</Name>
\t\t\t<Synonym>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t<v8:content>{synonym}</v8:content>
\t\t\t\t</v8:item>
\t\t\t</Synonym>
\t\t\t<Comment/>
\t\t\t<UseStandardCommands>true</UseStandardCommands>
\t\t\t<DefaultForm/>
\t\t\t<AuxiliaryForm/>
\t\t\t<MainDataCompositionSchema>Report.{name}.Template.MainDataCompositionSchema</MainDataCompositionSchema>
\t\t\t<DefaultSettingsForm/>
\t\t\t<AuxiliarySettingsForm/>
\t\t\t<DefaultVariantForm/>
\t\t\t<VariantsStorage/>
\t\t\t<SettingsStorage/>
\t\t\t<IncludeHelpInContents>false</IncludeHelpInContents>
\t\t\t<ExtendedPresentation/>
\t\t\t<Explanation/>
\t\t</Properties>
\t\t<ChildObjects>
\t\t\t<Template>MainDataCompositionSchema</Template>
\t\t</ChildObjects>
\t</Report>
</MetaDataObject>"""

    with open(f"src/Reports/{name}.xml", "w", encoding="utf-8") as f:
        f.write(rep_xml)

    # 2. Template Metadata XML
    tmpl_meta = f"""<?xml version="1.0" encoding="UTF-8"?>
<MetaDataObject xmlns="http://v8.1c.ru/8.3/MDClasses" xmlns:app="http://v8.1c.ru/8.2/managed-application/core" xmlns:cfg="http://v8.1c.ru/8.1/data/enterprise/current-config" xmlns:cmi="http://v8.1c.ru/8.2/managed-application/cmi" xmlns:ent="http://v8.1c.ru/8.1/data/enterprise" xmlns:lf="http://v8.1c.ru/8.2/managed-application/logform" xmlns:style="http://v8.1c.ru/8.1/data/ui/style" xmlns:sys="http://v8.1c.ru/8.1/data/ui/fonts/system" xmlns:v8="http://v8.1c.ru/8.1/data/core" xmlns:v8ui="http://v8.1c.ru/8.1/data/ui" xmlns:web="http://v8.1c.ru/8.1/data/ui/colors/web" xmlns:win="http://v8.1c.ru/8.1/data/ui/colors/windows" xmlns:xen="http://v8.1c.ru/8.3/xcf/enums" xmlns:xpr="http://v8.1c.ru/8.3/xcf/predef" xmlns:xr="http://v8.1c.ru/8.3/xcf/readable" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.15">
\t<Template uuid="{uid()}">
\t\t<Properties>
\t\t\t<Name>MainDataCompositionSchema</Name>
\t\t\t<Synonym>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t<v8:content>Main data composition schema</v8:content>
\t\t\t\t</v8:item>
\t\t\t</Synonym>
\t\t\t<Comment/>
\t\t\t<TemplateType>DataCompositionSchema</TemplateType>
\t\t</Properties>
\t</Template>
</MetaDataObject>"""

    with open(f"{rep_dir}/Templates/MainDataCompositionSchema.xml", "w", encoding="utf-8") as f:
        f.write(tmpl_meta)

    # 3. DCS Ext/Template.xml
    fields_xml = ""
    for fld in fields:
        fields_xml += f"""\t\t<field xsi:type="DataSetFieldField">
\t\t\t<dataPath>{fld}</dataPath>
\t\t\t<field>{fld}</field>
\t\t</field>\n"""

    total_xml = ""
    for tf in total_fields:
        total_xml += f"""\t<totalField>
\t\t<dataPath>{tf}</dataPath>
\t\t<expression>Sum({tf})</expression>
\t</totalField>\n"""

    selection_xml = ""
    for fld in fields:
        selection_xml += f"""\t\t\t\t<dcsset:item xsi:type="dcsset:SelectedItemField">
\t\t\t\t\t<dcsset:field>{fld}</dcsset:field>
\t\t\t\t</dcsset:item>\n"""

    # Nested groups or single group
    structure_xml = ""
    if len(group_fields) == 0:
        structure_xml = f"""\t\t\t<dcsset:item xsi:type="dcsset:StructureItemGroup">
\t\t\t\t<dcsset:order>
\t\t\t\t\t<dcsset:item xsi:type="dcsset:OrderItemAuto"/>
\t\t\t\t</dcsset:order>
\t\t\t\t<dcsset:selection>
\t\t\t\t\t<dcsset:item xsi:type="dcsset:SelectedItemAuto"/>
\t\t\t\t</dcsset:selection>
\t\t\t</dcsset:item>"""
    else:
        # Build structure with first group field
        indent = "\t\t\t"
        structure_xml = f"""{indent}<dcsset:item xsi:type="dcsset:StructureItemGroup">
{indent}\t<dcsset:groupItems>
{indent}\t\t<dcsset:item xsi:type="dcsset:GroupItemField">
{indent}\t\t\t<dcsset:field>{group_fields[0]}</dcsset:field>
{indent}\t\t\t<dcsset:groupType>Items</dcsset:groupType>
{indent}\t\t\t<dcsset:periodAdditionType>None</dcsset:periodAdditionType>
{indent}\t\t\t<dcsset:periodAdditionBegin xsi:type="xs:dateTime">0001-01-01T00:00:00</dcsset:periodAdditionBegin>
{indent}\t\t\t<dcsset:periodAdditionEnd xsi:type="xs:dateTime">0001-01-01T00:00:00</dcsset:periodAdditionEnd>
{indent}\t\t</dcsset:item>
{indent}\t</dcsset:groupItems>
{indent}\t<dcsset:order>
{indent}\t\t<dcsset:item xsi:type="dcsset:OrderItemAuto"/>
{indent}\t</dcsset:order>
{indent}\t<dcsset:selection>
{indent}\t\t<dcsset:item xsi:type="dcsset:SelectedItemAuto"/>
{indent}\t</dcsset:selection>
{indent}\t<dcsset:item xsi:type="dcsset:StructureItemGroup">
{indent}\t\t<dcsset:order>
{indent}\t\t\t<dcsset:item xsi:type="dcsset:OrderItemAuto"/>
{indent}\t\t</dcsset:order>
{indent}\t\t<dcsset:selection>
{indent}\t\t\t<dcsset:item xsi:type="dcsset:SelectedItemAuto"/>
{indent}\t\t</dcsset:selection>
{indent}\t</dcsset:item>
{indent}</dcsset:item>"""

    dcs_content = f"""<?xml version="1.0" encoding="UTF-8"?>
<DataCompositionSchema xmlns="http://v8.1c.ru/8.1/data-composition-system/schema" xmlns:dcscom="http://v8.1c.ru/8.1/data-composition-system/common" xmlns:dcscor="http://v8.1c.ru/8.1/data-composition-system/core" xmlns:dcsset="http://v8.1c.ru/8.1/data-composition-system/settings" xmlns:v8="http://v8.1c.ru/8.1/data/core" xmlns:v8ui="http://v8.1c.ru/8.1/data/ui" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
\t<dataSource>
\t\t<name>DataSource1</name>
\t\t<dataSourceType>Local</dataSourceType>
\t</dataSource>
\t<dataSet xsi:type="DataSetQuery">
\t\t<name>DataSet1</name>
{fields_xml}\t\t<dataSource>DataSource1</dataSource>
\t\t<query><![CDATA[{query_text}]]></query>
\t</dataSet>
{total_xml}\t<settingsVariant>
\t\t<dcsset:name>Default</dcsset:name>
\t\t<dcsset:presentation xsi:type="xs:string">Default</dcsset:presentation>
\t\t<dcsset:settings xmlns:style="http://v8.1c.ru/8.1/data/ui/style" xmlns:sys="http://v8.1c.ru/8.1/data/ui/fonts/system" xmlns:web="http://v8.1c.ru/8.1/data/ui/colors/web" xmlns:win="http://v8.1c.ru/8.1/data/ui/colors/windows">
\t\t\t<dcsset:selection>
{selection_xml}\t\t\t</dcsset:selection>
{structure_xml}
\t\t</dcsset:settings>
\t</settingsVariant>
</DataCompositionSchema>"""

    with open(f"{tmpl_dir}/Template.xml", "w", encoding="utf-8") as f:
        f.write(dcs_content)

def build_task7():
    print("Building Task 7: 6 Management Reports for AP & Cash Management...")
    os.makedirs("src/Reports", exist_ok=True)

    # Report 1: APOutstanding
    q1 = """SELECT
	AP.Company AS Company,
	AP.Counterparty AS Counterparty,
	AP.Contract AS Contract,
	AP.Invoice AS Invoice,
	AP.Invoice.DueDate AS DueDate,
	AP.AmountBalance AS AmountBalance
FROM
	AccumulationRegister.AccountsPayable.Balance AS AP"""
    create_report_files(
        name="APOutstanding",
        synonym="AP Outstanding Report (Báo cáo chi tiết công nợ phải trả)",
        query_text=q1,
        fields=["Company", "Counterparty", "Contract", "Invoice", "DueDate", "AmountBalance"],
        total_fields=["AmountBalance"],
        group_fields=["Counterparty"]
    )

    # Report 2: APAging
    q2 = """SELECT
	AP.Counterparty AS Counterparty,
	AP.Contract AS Contract,
	AP.Invoice AS Invoice,
	AP.Invoice.DueDate AS DueDate,
	AP.AmountBalance AS TotalOutstanding,
	CASE
		WHEN DATEDIFF(AP.Invoice.DueDate, &Period, DAY) <= 0
			THEN AP.AmountBalance
		ELSE 0
	END AS CurrentNotDue,
	CASE
		WHEN DATEDIFF(AP.Invoice.DueDate, &Period, DAY) >= 1
				AND DATEDIFF(AP.Invoice.DueDate, &Period, DAY) <= 30
			THEN AP.AmountBalance
		ELSE 0
	END AS Overdue1_30,
	CASE
		WHEN DATEDIFF(AP.Invoice.DueDate, &Period, DAY) >= 31
				AND DATEDIFF(AP.Invoice.DueDate, &Period, DAY) <= 60
			THEN AP.AmountBalance
		ELSE 0
	END AS Overdue31_60,
	CASE
		WHEN DATEDIFF(AP.Invoice.DueDate, &Period, DAY) >= 61
				AND DATEDIFF(AP.Invoice.DueDate, &Period, DAY) <= 90
			THEN AP.AmountBalance
		ELSE 0
	END AS Overdue61_90,
	CASE
		WHEN DATEDIFF(AP.Invoice.DueDate, &Period, DAY) > 90
			THEN AP.AmountBalance
		ELSE 0
	END AS OverdueOver90
FROM
	AccumulationRegister.AccountsPayable.Balance AS AP"""
    create_report_files(
        name="APAging",
        synonym="AP Aging Report (Báo cáo phân tích tuổi nợ AP)",
        query_text=q2,
        fields=["Counterparty", "Contract", "Invoice", "DueDate", "TotalOutstanding", "CurrentNotDue", "Overdue1_30", "Overdue31_60", "Overdue61_90", "OverdueOver90"],
        total_fields=["TotalOutstanding", "CurrentNotDue", "Overdue1_30", "Overdue31_60", "Overdue61_90", "OverdueOver90"],
        group_fields=["Counterparty"]
    )

    # Report 3: SupplierStatement
    q3 = """SELECT
	AP.Counterparty AS Counterparty,
	AP.Contract AS Contract,
	AP.AmountOpeningBalance AS AmountOpeningBalance,
	AP.AmountReceipt AS AmountReceipt,
	AP.AmountExpense AS AmountExpense,
	AP.AmountClosingBalance AS AmountClosingBalance
FROM
	AccumulationRegister.AccountsPayable.BalanceAndTurnovers(, , Auto, , ) AS AP"""
    create_report_files(
        name="SupplierStatement",
        synonym="Supplier Statement (Bảng đối chiếu biến động công nợ NCC)",
        query_text=q3,
        fields=["Counterparty", "Contract", "AmountOpeningBalance", "AmountReceipt", "AmountExpense", "AmountClosingBalance"],
        total_fields=["AmountOpeningBalance", "AmountReceipt", "AmountExpense", "AmountClosingBalance"],
        group_fields=["Counterparty"]
    )

    # Report 4: APReconciliationWithAccounting
    q4 = """SELECT
	"VinSmart Future" AS Company,
	ISNULL(AP.APAmount, 0) AS APDetailedBalance,
	ISNULL(GL.GLAmount, 0) AS GLAccount331Balance,
	ISNULL(AP.APAmount, 0) - ISNULL(GL.GLAmount, 0) AS Variance
FROM
	(SELECT
		1 AS JoinKey,
		SUM(APBalance.AmountBalance) AS APAmount
	FROM
		AccumulationRegister.AccountsPayable.Balance AS APBalance) AS AP
		FULL JOIN (SELECT
			1 AS JoinKey,
			SUM(GLBalance.AmountBalanceCredit) AS GLAmount
		FROM
			AccountingRegister.GeneralLedger.Balance(, Account.Code = "331") AS GLBalance) AS GL
		ON AP.JoinKey = GL.JoinKey"""
    create_report_files(
        name="APReconciliationWithAccounting",
        synonym="AP Reconciliation with Accounting (Đối chiếu sổ AP với TK 331)",
        query_text=q4,
        fields=["Company", "APDetailedBalance", "GLAccount331Balance", "Variance"],
        total_fields=["APDetailedBalance", "GLAccount331Balance", "Variance"],
        group_fields=[]
    )

    # Report 5: CashPosition
    q5 = """SELECT
	CashFlowBalanceAndTurnovers.CashAccount AS CashAccount,
	CashFlowBalanceAndTurnovers.CashFlowItem AS CashFlowItem,
	CashFlowBalanceAndTurnovers.AmountOpeningBalance AS OpeningBalance,
	CashFlowBalanceAndTurnovers.AmountReceipt AS Inflows,
	CashFlowBalanceAndTurnovers.AmountExpense AS Outflows,
	CashFlowBalanceAndTurnovers.AmountClosingBalance AS ClosingBalance
FROM
	AccumulationRegister.CashFlow.BalanceAndTurnovers(, , Auto, , ) AS CashFlowBalanceAndTurnovers"""
    create_report_files(
        name="CashPosition",
        synonym="Cash Position Report (Báo cáo số dư tiền và dòng tiền thực tế)",
        query_text=q5,
        fields=["CashAccount", "CashFlowItem", "OpeningBalance", "Inflows", "Outflows", "ClosingBalance"],
        total_fields=["OpeningBalance", "Inflows", "Outflows", "ClosingBalance"],
        group_fields=["CashAccount"]
    )

    # Report 6: ActualVsPlanCashFlow
    q6 = """SELECT
	ISNULL(Plan.CashFlowItem, Actual.CashFlowItem) AS CashFlowItem,
	ISNULL(Plan.PlanAmount, 0) AS PlannedAmount,
	ISNULL(Actual.ActualAmount, 0) AS ActualAmount,
	ISNULL(Plan.PlanAmount, 0) - ISNULL(Actual.ActualAmount, 0) AS Variance
FROM
	(SELECT
		CFP.CashFlowItem AS CashFlowItem,
		SUM(CFP.PlannedAmountTurnover) AS PlanAmount
	FROM
		AccumulationRegister.CashFlowPlan.Turnovers AS CFP
	GROUP BY
		CFP.CashFlowItem) AS Plan
		FULL JOIN (SELECT
			CF.CashFlowItem AS CashFlowItem,
			SUM(CF.AmountExpenseTurnover) AS ActualAmount
		FROM
			AccumulationRegister.CashFlow.Turnovers AS CF
		GROUP BY
			CF.CashFlowItem) AS Actual
		ON Plan.CashFlowItem = Actual.CashFlowItem"""
    create_report_files(
        name="ActualVsPlanCashFlow",
        synonym="Actual vs Plan Cash Flow (So sánh Kế hoạch chi vs Thực tế đã chi)",
        query_text=q6,
        fields=["CashFlowItem", "PlannedAmount", "ActualAmount", "Variance"],
        total_fields=["PlannedAmount", "ActualAmount", "Variance"],
        group_fields=["CashFlowItem"]
    )

    # Update Configuration.xml
    with open("src/Configuration.xml", "r", encoding="utf-8") as f:
        cfg = f.read()

    reports = [
        "APOutstanding",
        "APAging",
        "SupplierStatement",
        "APReconciliationWithAccounting",
        "CashPosition",
        "ActualVsPlanCashFlow"
    ]

    new_reports_cfg = "\n".join([f"\t\t\t<Report>{r}</Report>" for r in reports if f"<Report>{r}</Report>" not in cfg])
    if new_reports_cfg:
        cfg = cfg.replace("\t\t</ChildObjects>", f"{new_reports_cfg}\n\t\t</ChildObjects>")
        with open("src/Configuration.xml", "w", encoding="utf-8") as f:
            f.write(cfg)

    # Update Subsystem AccountsPayable.xml
    with open("src/Subsystems/AccountsPayable.xml", "r", encoding="utf-8") as f:
        ss = f.read()

    ss_items = "\n".join([f"\t\t\t\t<xr:Item xsi:type=\"xr:MDObjectRef\">Report.{r}</xr:Item>" for r in reports if f"Report.{r}" not in ss])
    if ss_items:
        ss = ss.replace("\t\t\t</Content>", f"{ss_items}\n\t\t\t</Content>")
        with open("src/Subsystems/AccountsPayable.xml", "w", encoding="utf-8") as f:
            f.write(ss)

    print("Task 7: All 6 Reports built and registered successfully!")

if __name__ == "__main__":
    build_task7()
