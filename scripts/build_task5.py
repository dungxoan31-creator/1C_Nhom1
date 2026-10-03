import os
import uuid

def uid():
    return str(uuid.uuid4())

def build_task5():
    print("Building Task 5: CashFlow Accumulation Register and Cash Position integration...")
    os.makedirs("src/AccumulationRegisters", exist_ok=True)

    # 1. AccumulationRegister.CashFlow
    cf_id = uid()
    cf_xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<MetaDataObject xmlns="http://v8.1c.ru/8.3/MDClasses" xmlns:app="http://v8.1c.ru/8.2/managed-application/core" xmlns:cfg="http://v8.1c.ru/8.1/data/enterprise/current-config" xmlns:cmi="http://v8.1c.ru/8.2/managed-application/cmi" xmlns:ent="http://v8.1c.ru/8.1/data/enterprise" xmlns:lf="http://v8.1c.ru/8.2/managed-application/logform" xmlns:style="http://v8.1c.ru/8.1/data/ui/style" xmlns:sys="http://v8.1c.ru/8.1/data/ui/fonts/system" xmlns:v8="http://v8.1c.ru/8.1/data/core" xmlns:v8ui="http://v8.1c.ru/8.1/data/ui" xmlns:web="http://v8.1c.ru/8.1/data/ui/colors/web" xmlns:win="http://v8.1c.ru/8.1/data/ui/colors/windows" xmlns:xen="http://v8.1c.ru/8.3/xcf/enums" xmlns:xpr="http://v8.1c.ru/8.3/xcf/predef" xmlns:xr="http://v8.1c.ru/8.3/xcf/readable" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.15">
\t<AccumulationRegister uuid="{cf_id}">
\t\t<InternalInfo>
\t\t\t<xr:GeneratedType name="AccumulationRegisterRecord.CashFlow" category="Record">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="AccumulationRegisterManager.CashFlow" category="Manager">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="AccumulationRegisterSelection.CashFlow" category="Selection">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="AccumulationRegisterList.CashFlow" category="List">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="AccumulationRegisterRecordSet.CashFlow" category="RecordSet">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="AccumulationRegisterRecordKey.CashFlow" category="RecordKey">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t</InternalInfo>
\t\t<Properties>
\t\t\t<Name>CashFlow</Name>
\t\t\t<Synonym>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t<v8:content>Cash Flow (Sổ lưu chuyển dòng tiền)</v8:content>
\t\t\t\t</v8:item>
\t\t\t</Synonym>
\t\t\t<Comment/>
\t\t\t<UseStandardCommands>true</UseStandardCommands>
\t\t\t<DefaultListForm/>
\t\t\t<AuxiliaryListForm/>
\t\t\t<RegisterType>Balance</RegisterType>
\t\t\t<IncludeHelpInContents>false</IncludeHelpInContents>
\t\t\t<DataLockControlMode>Managed</DataLockControlMode>
\t\t\t<FullTextSearch>DontUse</FullTextSearch>
\t\t\t<EnableTotalsSplitting>true</EnableTotalsSplitting>
\t\t\t<ListPresentation/>
\t\t\t<ExtendedListPresentation/>
\t\t\t<Explanation/>
\t\t</Properties>
\t\t<ChildObjects>
\t\t\t<Resource uuid="{uid()}">
\t\t\t\t<Properties>
\t\t\t\t\t<Name>Amount</Name>
\t\t\t\t\t<Synonym>
\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t\t<v8:content>Amount</v8:content>
\t\t\t\t\t\t</v8:item>
\t\t\t\t\t</Synonym>
\t\t\t\t\t<Comment/>
\t\t\t\t\t<Type>
\t\t\t\t\t\t<v8:Type>xs:decimal</v8:Type>
\t\t\t\t\t\t<v8:NumberQualifiers>
\t\t\t\t\t\t\t<v8:Digits>15</v8:Digits>
\t\t\t\t\t\t\t<v8:FractionDigits>2</v8:FractionDigits>
\t\t\t\t\t\t\t<v8:AllowedSign>Any</v8:AllowedSign>
\t\t\t\t\t\t</v8:NumberQualifiers>
\t\t\t\t\t</Type>
\t\t\t\t\t<PasswordMode>false</PasswordMode>
\t\t\t\t\t<Format/>
\t\t\t\t\t<EditFormat/>
\t\t\t\t\t<ToolTip/>
\t\t\t\t\t<MarkNegatives>false</MarkNegatives>
\t\t\t\t\t<Mask/>
\t\t\t\t\t<MultiLine>false</MultiLine>
\t\t\t\t\t<ExtendedEdit>false</ExtendedEdit>
\t\t\t\t\t<MinValue xsi:nil="true"/>
\t\t\t\t\t<MaxValue xsi:nil="true"/>
\t\t\t\t\t<FillChecking>DontCheck</FillChecking>
\t\t\t\t\t<ChoiceFoldersAndItems>Items</ChoiceFoldersAndItems>
\t\t\t\t\t<ChoiceParameterLinks/>
\t\t\t\t\t<ChoiceParameters/>
\t\t\t\t\t<QuickChoice>Auto</QuickChoice>
\t\t\t\t\t<CreateOnInput>Auto</CreateOnInput>
\t\t\t\t\t<ChoiceForm/>
\t\t\t\t\t<LinkByType/>
\t\t\t\t\t<ChoiceHistoryOnInput>Auto</ChoiceHistoryOnInput>
\t\t\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t\t</Properties>
\t\t\t</Resource>
\t\t\t<Attribute uuid="{uid()}">
\t\t\t\t<Properties>
\t\t\t\t\t<Name>Counterparty</Name>
\t\t\t\t\t<Synonym>
\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t\t<v8:content>Counterparty</v8:content>
\t\t\t\t\t\t</v8:item>
\t\t\t\t\t</Synonym>
\t\t\t\t\t<Comment/>
\t\t\t\t\t<Type>
\t\t\t\t\t\t<v8:Type>cfg:CatalogRef.Counterparties</v8:Type>
\t\t\t\t\t</Type>
\t\t\t\t\t<Indexing>DontIndex</Indexing>
\t\t\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t\t</Properties>
\t\t\t</Attribute>
\t\t\t<Attribute uuid="{uid()}">
\t\t\t\t<Properties>
\t\t\t\t\t<Name>SourceDocument</Name>
\t\t\t\t\t<Synonym>
\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t\t<v8:content>Source document</v8:content>
\t\t\t\t\t\t</v8:item>
\t\t\t\t\t</Synonym>
\t\t\t\t\t<Comment/>
\t\t\t\t\t<Type>
\t\t\t\t\t\t<v8:Type>cfg:DocumentRef.CashPayment</v8:Type>
\t\t\t\t\t</Type>
\t\t\t\t\t<Indexing>DontIndex</Indexing>
\t\t\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t\t</Properties>
\t\t\t</Attribute>
\t\t\t<Dimension uuid="{uid()}">
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
\t\t\t\t\t<DenyIncompleteValues>false</DenyIncompleteValues>
\t\t\t\t\t<Indexing>DontIndex</Indexing>
\t\t\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t\t\t<UseInTotals>true</UseInTotals>
\t\t\t\t</Properties>
\t\t\t</Dimension>
\t\t\t<Dimension uuid="{uid()}">
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
\t\t\t\t\t<DenyIncompleteValues>false</DenyIncompleteValues>
\t\t\t\t\t<Indexing>DontIndex</Indexing>
\t\t\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t\t\t<UseInTotals>true</UseInTotals>
\t\t\t\t</Properties>
\t\t\t</Dimension>
\t\t</ChildObjects>
\t</AccumulationRegister>
</MetaDataObject>"""

    with open("src/AccumulationRegisters/CashFlow.xml", "w", encoding="utf-8") as f:
        f.write(cf_xml)

    # 2. Update Document.CashPayment.xml to include AccumulationRegister.CashFlow in RegisterRecords
    with open("src/Documents/CashPayment.xml", "r", encoding="utf-8") as f:
        cp_xml = f.read()

    rec_cf = "\t\t\t\t<xr:Item xsi:type=\"xr:MDObjectRef\">AccumulationRegister.CashFlow</xr:Item>\n"
    if "AccumulationRegister.CashFlow" not in cp_xml:
        cp_xml = cp_xml.replace(
            "<xr:Item xsi:type=\"xr:MDObjectRef\">AccumulationRegister.AccountsPayable</xr:Item>",
            "<xr:Item xsi:type=\"xr:MDObjectRef\">AccumulationRegister.AccountsPayable</xr:Item>\n" + rec_cf
        )
        with open("src/Documents/CashPayment.xml", "w", encoding="utf-8") as f:
            f.write(cp_xml)

    # 3. Update ObjectModule.bsl of CashPayment to post to CashFlow
    bsl_code = """Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
\t// Default CashFlowItem from Contract if empty
\tIf Not ValueIsFilled(CashFlowItem) And ValueIsFilled(Contract) And ValueIsFilled(Contract.DefaultCashFlowItem) Then
\t\tCashFlowItem = Contract.DefaultCashFlowItem;
\tEndIf;
EndProcedure

Procedure Posting(Cancel, Mode)
\tRegisterRecords.AccountsPayable.Write = True;
\tRegisterRecords.CashFlow.Write = True;
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

\t// 3. Ghi sổ Dòng tiền (CashFlow Outflow) & Cập nhật số dư quỹ/ngân hàng (Cash Position)
\tCFRecord = RegisterRecords.CashFlow.Add();
\tCFRecord.RecordType = AccumulationRecordType.Expense;
\tCFRecord.Period = Date;
\tCFRecord.Account = Account;
\tCFRecord.CashFlowItem = CashFlowItem;
\tCFRecord.Amount = PaymentAmount;
\tCFRecord.Counterparty = Counterparty;
\tCFRecord.SourceDocument = Ref;

\t// 4. Hạch toán Sổ cái Kế toán: Nợ TK 331 (Phải trả NCC), Có TK 112 (Ngân hàng) hoặc TK 111 (Tiền mặt)
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

    # 4. Update Configuration.xml and Subsystems
    with open("src/Configuration.xml", "r", encoding="utf-8") as f:
        cfg = f.read()

    new_cfg = "\t\t\t<AccumulationRegister>CashFlow</AccumulationRegister>"
    if "<AccumulationRegister>CashFlow</AccumulationRegister>" not in cfg:
        cfg = cfg.replace("\t\t</ChildObjects>", f"{new_cfg}\n\t\t</ChildObjects>")
        with open("src/Configuration.xml", "w", encoding="utf-8") as f:
            f.write(cfg)

    with open("src/Subsystems/AccountsPayable.xml", "r", encoding="utf-8") as f:
        ss = f.read()

    ss_item = '\t\t\t\t<xr:Item xsi:type="xr:MDObjectRef">AccumulationRegister.CashFlow</xr:Item>'
    if "AccumulationRegister.CashFlow" not in ss:
        ss = ss.replace("\t\t\t</Content>", f"{ss_item}\n\t\t\t</Content>")
        with open("src/Subsystems/AccountsPayable.xml", "w", encoding="utf-8") as f:
            f.write(ss)

    print("Task 5 files built successfully!")

if __name__ == "__main__":
    build_task5()
