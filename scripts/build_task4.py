import os
import uuid

def uid():
    return str(uuid.uuid4())

def build_task4():
    print("Building Task 4: CashPayment Document with PaymentAllocation...")
    os.makedirs("src/Documents/CashPayment/Ext", exist_ok=True)

    cp_id = uid()
    ts_id = uid()
    cp_xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<MetaDataObject xmlns="http://v8.1c.ru/8.3/MDClasses" xmlns:app="http://v8.1c.ru/8.2/managed-application/core" xmlns:cfg="http://v8.1c.ru/8.1/data/enterprise/current-config" xmlns:cmi="http://v8.1c.ru/8.2/managed-application/cmi" xmlns:ent="http://v8.1c.ru/8.1/data/enterprise" xmlns:lf="http://v8.1c.ru/8.2/managed-application/logform" xmlns:style="http://v8.1c.ru/8.1/data/ui/style" xmlns:sys="http://v8.1c.ru/8.1/data/ui/fonts/system" xmlns:v8="http://v8.1c.ru/8.1/data/core" xmlns:v8ui="http://v8.1c.ru/8.1/data/ui" xmlns:web="http://v8.1c.ru/8.1/data/ui/colors/web" xmlns:win="http://v8.1c.ru/8.1/data/ui/colors/windows" xmlns:xen="http://v8.1c.ru/8.3/xcf/enums" xmlns:xpr="http://v8.1c.ru/8.3/xcf/predef" xmlns:xr="http://v8.1c.ru/8.3/xcf/readable" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.15">
\t<Document uuid="{cp_id}">
\t\t<InternalInfo>
\t\t\t<xr:GeneratedType name="DocumentObject.CashPayment" category="Object">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="DocumentRef.CashPayment" category="Ref">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="DocumentSelection.CashPayment" category="Selection">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="DocumentList.CashPayment" category="List">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="DocumentManager.CashPayment" category="Manager">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t</InternalInfo>
\t\t<Properties>
\t\t\t<Name>CashPayment</Name>
\t\t\t<Synonym>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t<v8:content>Cash payment (Phiếu chi / Báo nợ)</v8:content>
\t\t\t\t</v8:item>
\t\t\t</Synonym>
\t\t\t<Comment/>
\t\t\t<UseStandardCommands>true</UseStandardCommands>
\t\t\t<NumberType>String</NumberType>
\t\t\t<NumberLength>9</NumberLength>
\t\t\t<NumberAllowedLength>Variable</NumberAllowedLength>
\t\t\t<NumberPeriodicity>Nonperiodical</NumberPeriodicity>
\t\t\t<CheckUnique>true</CheckUnique>
\t\t\t<Autonumbering>true</Autonumbering>
\t\t\t<Posting>Allow</Posting>
\t\t\t<RealTimePosting>Allow</RealTimePosting>
\t\t\t<RegisterRecordsDeletion>AutoDeleteOnUnpost</RegisterRecordsDeletion>
\t\t\t<RegisterRecordsWritingOnPost>WriteSelected</RegisterRecordsWritingOnPost>
\t\t\t<SequenceFilling>AutoFill</SequenceFilling>
\t\t\t<RegisterRecords>
\t\t\t\t<xr:Item xsi:type="xr:MDObjectRef">AccumulationRegister.AccountsPayable</xr:Item>
\t\t\t\t<xr:Item xsi:type="xr:MDObjectRef">AccountingRegister.GeneralLedger</xr:Item>
\t\t\t</RegisterRecords>
\t\t\t<PostInPrivilegedMode>true</PostInPrivilegedMode>
\t\t\t<UnpostInPrivilegedMode>true</UnpostInPrivilegedMode>
\t\t\t<DataLockControlMode>Managed</DataLockControlMode>
\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t</Properties>
\t\t<ChildObjects>
\t\t\t<Attribute uuid="{uid()}">
\t\t\t\t<Properties>
\t\t\t\t\t<Name>Account</Name>
\t\t\t\t\t<Synonym>
\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t\t<v8:content>Cash / Bank account</v8:content>
\t\t\t\t\t\t</v8:item>
\t\t\t\t\t</Synonym>
\t\t\t\t\t<Comment/>
\t\t\t\t\t<Type>
\t\t\t\t\t\t<v8:Type>cfg:CatalogRef.CashAccounts</v8:Type>
\t\t\t\t\t</Type>
\t\t\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t\t</Properties>
\t\t\t</Attribute>
\t\t\t<Attribute uuid="{uid()}">
\t\t\t\t<Properties>
\t\t\t\t\t<Name>Counterparty</Name>
\t\t\t\t\t<Synonym>
\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t\t<v8:content>Supplier / Counterparty</v8:content>
\t\t\t\t\t\t</v8:item>
\t\t\t\t\t</Synonym>
\t\t\t\t\t<Comment/>
\t\t\t\t\t<Type>
\t\t\t\t\t\t<v8:Type>cfg:CatalogRef.Counterparties</v8:Type>
\t\t\t\t\t</Type>
\t\t\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t\t</Properties>
\t\t\t</Attribute>
\t\t\t<Attribute uuid="{uid()}">
\t\t\t\t<Properties>
\t\t\t\t\t<Name>Contract</Name>
\t\t\t\t\t<Synonym>
\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t\t<v8:content>Contract</v8:content>
\t\t\t\t\t\t</v8:item>
\t\t\t\t\t</Synonym>
\t\t\t\t\t<Comment/>
\t\t\t\t\t<Type>
\t\t\t\t\t\t<v8:Type>cfg:CatalogRef.Contracts</v8:Type>
\t\t\t\t\t</Type>
\t\t\t\t\t<ChoiceParameterLinks>
\t\t\t\t\t\t<xr:Link>
\t\t\t\t\t\t\t<xr:Name>Filter.Owner</xr:Name>
\t\t\t\t\t\t\t<xr:DataPath xsi:type="xs:string">Document.CashPayment.Attribute.Counterparty</xr:DataPath>
\t\t\t\t\t\t\t<xr:ValueChange>Clear</xr:ValueChange>
\t\t\t\t\t\t</xr:Link>
\t\t\t\t\t</ChoiceParameterLinks>
\t\t\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t\t</Properties>
\t\t\t</Attribute>
\t\t\t<Attribute uuid="{uid()}">
\t\t\t\t<Properties>
\t\t\t\t\t<Name>CashFlowItem</Name>
\t\t\t\t\t<Synonym>
\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t\t<v8:content>Cash flow item</v8:content>
\t\t\t\t\t\t</v8:item>
\t\t\t\t\t</Synonym>
\t\t\t\t\t<Comment/>
\t\t\t\t\t<Type>
\t\t\t\t\t\t<v8:Type>cfg:CatalogRef.CashFlowItems</v8:Type>
\t\t\t\t\t</Type>
\t\t\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t\t</Properties>
\t\t\t</Attribute>
\t\t\t<Attribute uuid="{uid()}">
\t\t\t\t<Properties>
\t\t\t\t\t<Name>PaymentAmount</Name>
\t\t\t\t\t<Synonym>
\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t\t<v8:content>Payment amount</v8:content>
\t\t\t\t\t\t</v8:item>
\t\t\t\t\t</Synonym>
\t\t\t\t\t<Comment/>
\t\t\t\t\t<Type>
\t\t\t\t\t\t<v8:Type>xs:decimal</v8:Type>
\t\t\t\t\t\t<v8:NumberQualifiers>
\t\t\t\t\t\t\t<v8:Digits>15</v8:Digits>
\t\t\t\t\t\t\t<v8:FractionDigits>2</v8:FractionDigits>
\t\t\t\t\t\t\t<v8:AllowedSign>Nonnegative</v8:AllowedSign>
\t\t\t\t\t\t</v8:NumberQualifiers>
\t\t\t\t\t</Type>
\t\t\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t\t</Properties>
\t\t\t</Attribute>
\t\t\t<Attribute uuid="{uid()}">
\t\t\t\t<Properties>
\t\t\t\t\t<Name>Memo</Name>
\t\t\t\t\t<Synonym>
\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t\t<v8:content>Memo</v8:content>
\t\t\t\t\t\t</v8:item>
\t\t\t\t\t</Synonym>
\t\t\t\t\t<Comment/>
\t\t\t\t\t<Type>
\t\t\t\t\t\t<v8:Type>xs:string</v8:Type>
\t\t\t\t\t\t<v8:StringQualifiers>
\t\t\t\t\t\t\t<v8:Length>200</v8:Length>
\t\t\t\t\t\t\t<v8:AllowedLength>Variable</v8:AllowedLength>
\t\t\t\t\t\t</v8:StringQualifiers>
\t\t\t\t\t</Type>
\t\t\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t\t</Properties>
\t\t\t</Attribute>
\t\t\t<TabularSection uuid="{ts_id}">
\t\t\t\t<InternalInfo>
\t\t\t\t\t<xr:GeneratedType name="DocumentTabularSection.CashPayment.PaymentAllocation" category="TabularSection">
\t\t\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t\t\t</xr:GeneratedType>
\t\t\t\t\t<xr:GeneratedType name="DocumentTabularSectionRow.CashPayment.PaymentAllocation" category="TabularSectionRow">
\t\t\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t\t\t</xr:GeneratedType>
\t\t\t\t</InternalInfo>
\t\t\t\t<Properties>
\t\t\t\t\t<Name>PaymentAllocation</Name>
\t\t\t\t\t<Synonym>
\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t\t<v8:content>Payment allocation</v8:content>
\t\t\t\t\t\t</v8:item>
\t\t\t\t\t</Synonym>
\t\t\t\t\t<Comment/>
\t\t\t\t\t<ToolTip/>
\t\t\t\t\t<FillChecking>DontCheck</FillChecking>
\t\t\t\t</Properties>
\t\t\t\t<ChildObjects>
\t\t\t\t\t<Attribute uuid="{uid()}">
\t\t\t\t\t\t<Properties>
\t\t\t\t\t\t\t<Name>Invoice</Name>
\t\t\t\t\t\t\t<Synonym>
\t\t\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t\t\t\t<v8:content>Invoice</v8:content>
\t\t\t\t\t\t\t\t</v8:item>
\t\t\t\t\t\t\t</Synonym>
\t\t\t\t\t\t\t<Comment/>
\t\t\t\t\t\t\t<Type>
\t\t\t\t\t\t\t\t<v8:Type>cfg:DocumentRef.VendorInvoice</v8:Type>
\t\t\t\t\t\t\t</Type>
\t\t\t\t\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t\t\t\t</Properties>
\t\t\t\t\t</Attribute>
\t\t\t\t\t<Attribute uuid="{uid()}">
\t\t\t\t\t\t<Properties>
\t\t\t\t\t\t\t<Name>AllocatedAmount</Name>
\t\t\t\t\t\t\t<Synonym>
\t\t\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t\t\t\t<v8:content>Allocated amount</v8:content>
\t\t\t\t\t\t\t\t</v8:item>
\t\t\t\t\t\t\t</Synonym>
\t\t\t\t\t\t\t<Comment/>
\t\t\t\t\t\t\t<Type>
\t\t\t\t\t\t\t\t<v8:Type>xs:decimal</v8:Type>
\t\t\t\t\t\t\t\t<v8:NumberQualifiers>
\t\t\t\t\t\t\t\t\t<v8:Digits>15</v8:Digits>
\t\t\t\t\t\t\t\t\t<v8:FractionDigits>2</v8:FractionDigits>
\t\t\t\t\t\t\t\t\t<v8:AllowedSign>Nonnegative</v8:AllowedSign>
\t\t\t\t\t\t\t\t</v8:NumberQualifiers>
\t\t\t\t\t\t\t</Type>
\t\t\t\t\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t\t\t\t</Properties>
\t\t\t\t\t</Attribute>
\t\t\t\t</ChildObjects>
\t\t\t</TabularSection>
\t\t</ChildObjects>
\t</Document>
</MetaDataObject>"""

    with open("src/Documents/CashPayment.xml", "w", encoding="utf-8") as f:
        f.write(cp_xml)

    # ObjectModule.bsl for CashPayment
    bsl_code = """Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
\t// Default CashFlowItem from Contract if empty
\tIf Not ValueIsFilled(CashFlowItem) And ValueIsFilled(Contract) And ValueIsFilled(Contract.DefaultCashFlowItem) Then
\t\tCashFlowItem = Contract.DefaultCashFlowItem;
\tEndIf;
EndProcedure

Procedure Posting(Cancel, Mode)
\tRegisterRecords.AccountsPayable.Write = True;
\tRegisterRecords.GeneralLedger.Write = True;

\tTotalAllocated = 0;

\t// 1. Phân bổ thanh toán cho các hóa đơn được chỉ định
\tFor Each Row In PaymentAllocation Do
\t\tIf Row.AllocatedAmount > 0 Then
\t\t\tTotalAllocated = TotalAllocated + Row.AllocatedAmount;
\t\t\t
\t\t\t// Giảm nợ cho từng hóa đơn cụ thể (Partial Payment hoặc Full Payment)
\t\t\tRecord = RegisterRecords.AccountsPayable.Add();
\t\t\tRecord.RecordType = AccumulationRecordType.Expense;
\t\t\tRecord.Period = Date;
\t\t\tRecord.Company = "VinSmart Future";
\t\t\tRecord.Counterparty = Counterparty;
\t\t\tRecord.Contract = Contract;
\t\t\tRecord.Invoice = Row.Invoice;
\t\t\tRecord.Amount = Row.AllocatedAmount;
\t\tEndIf;
\tEndDo;

\t// 2. Nếu thanh toán vượt quá số phân bổ hoặc không phân bổ -> Khoản chưa phân bổ (Unallocated Payment / Prepayment)
\tUnallocatedAmount = PaymentAmount - TotalAllocated;
\tIf UnallocatedAmount > 0 Then
\t\tRecord = RegisterRecords.AccountsPayable.Add();
\t\tRecord.RecordType = AccumulationRecordType.Expense;
\t\tRecord.Period = Date;
\t\tRecord.Company = "VinSmart Future";
\t\tRecord.Counterparty = Counterparty;
\t\tRecord.Contract = Contract;
\t\tRecord.Invoice = Undefined; // Đánh dấu khoản chưa phân bổ
\t\tRecord.Amount = UnallocatedAmount;
\tEndIf;

\t// 3. Hạch toán Sổ cái Kế toán: Nợ TK 331 (Phải trả NCC), Có TK 112 (Ngân hàng) hoặc TK 111 (Tiền mặt)
\tCrAccount = ChartsOfAccounts.Main.BankDeposits;
\tIf ValueIsFilled(Account) And ValueIsFilled(Account.AccountType) And Account.AccountType = Enums.CashAccountTypes.Cash Then
\t\tCrAccount = ChartsOfAccounts.Main.Cash;
\tEndIf;

\tGLRecord = RegisterRecords.GeneralLedger.Add();
\tGLRecord.Period = Date;
\tGLRecord.AccountDr = ChartsOfAccounts.Main.AccountsPayable;
\tGLRecord.AccountCr = CrAccount;
\tGLRecord.Amount = PaymentAmount;
EndProcedure
"""
    with open("src/Documents/CashPayment/Ext/ObjectModule.bsl", "w", encoding="utf-8") as f:
        f.write(bsl_code)

    # Update Configuration.xml and Subsystems
    with open("src/Configuration.xml", "r", encoding="utf-8") as f:
        cfg = f.read()

    new_cfg = "\t\t\t<Document>CashPayment</Document>"
    if "<Document>CashPayment</Document>" not in cfg:
        cfg = cfg.replace("\t\t</ChildObjects>", f"{new_cfg}\n\t\t</ChildObjects>")
        with open("src/Configuration.xml", "w", encoding="utf-8") as f:
            f.write(cfg)

    with open("src/Subsystems/AccountsPayable.xml", "r", encoding="utf-8") as f:
        ss = f.read()

    ss_item = '\t\t\t\t<xr:Item xsi:type="xr:MDObjectRef">Document.CashPayment</xr:Item>'
    if "Document.CashPayment" not in ss:
        ss = ss.replace("\t\t\t</Content>", f"{ss_item}\n\t\t\t</Content>")
        with open("src/Subsystems/AccountsPayable.xml", "w", encoding="utf-8") as f:
            f.write(ss)

    print("Task 4 files built successfully!")

if __name__ == "__main__":
    build_task4()
