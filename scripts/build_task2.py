import os
import uuid

def uid():
    return str(uuid.uuid4())

def build_task2():
    print("Building Task 2: Chart of Accounts & General Ledger...")
    os.makedirs("src/ChartsOfAccounts", exist_ok=True)
    os.makedirs("src/AccountingRegisters", exist_ok=True)

    coa_id = uid()
    coa_xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<MetaDataObject xmlns="http://v8.1c.ru/8.3/MDClasses" xmlns:app="http://v8.1c.ru/8.2/managed-application/core" xmlns:cfg="http://v8.1c.ru/8.1/data/enterprise/current-config" xmlns:cmi="http://v8.1c.ru/8.2/managed-application/cmi" xmlns:ent="http://v8.1c.ru/8.1/data/enterprise" xmlns:lf="http://v8.1c.ru/8.2/managed-application/logform" xmlns:style="http://v8.1c.ru/8.1/data/ui/style" xmlns:sys="http://v8.1c.ru/8.1/data/ui/fonts/system" xmlns:v8="http://v8.1c.ru/8.1/data/core" xmlns:v8ui="http://v8.1c.ru/8.1/data/ui" xmlns:web="http://v8.1c.ru/8.1/data/ui/colors/web" xmlns:win="http://v8.1c.ru/8.1/data/ui/colors/windows" xmlns:xen="http://v8.1c.ru/8.3/xcf/enums" xmlns:xpr="http://v8.1c.ru/8.3/xcf/predef" xmlns:xr="http://v8.1c.ru/8.3/xcf/readable" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.15">
\t<ChartOfAccounts uuid="{coa_id}">
\t\t<InternalInfo>
\t\t\t<xr:GeneratedType name="ChartOfAccountsObject.Main" category="Object">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="ChartOfAccountsRef.Main" category="Ref">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="ChartOfAccountsSelection.Main" category="Selection">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="ChartOfAccountsList.Main" category="List">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="ChartOfAccountsManager.Main" category="Manager">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t</InternalInfo>
\t\t<Properties>
\t\t\t<Name>Main</Name>
\t\t\t<Synonym>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t<v8:content>Main chart of accounts</v8:content>
\t\t\t\t</v8:item>
\t\t\t</Synonym>
\t\t\t<Comment/>
\t\t\t<UseStandardCommands>true</UseStandardCommands>
\t\t\t<IncludeHelpInContents>false</IncludeHelpInContents>
\t\t\t<CodeMask/>
\t\t\t<CodeLength>9</CodeLength>
\t\t\t<CodeType>String</CodeType>
\t\t\t<DescriptionLength>50</DescriptionLength>
\t\t\t<OrderLength>5</OrderLength>
\t\t\t<AutoOrderName>true</AutoOrderName>
\t\t\t<Characteristics/>
\t\t\t<PredefinedDataUpdate>Auto</PredefinedDataUpdate>
\t\t\t<EditType>InDialog</EditType>
\t\t\t<QuickChoice>false</QuickChoice>
\t\t\t<ChoiceMode>BothWays</ChoiceMode>
\t\t\t<InputByString>
\t\t\t\t<xr:Field>ChartOfAccounts.Main.StandardAttribute.Description</xr:Field>
\t\t\t\t<xr:Field>ChartOfAccounts.Main.StandardAttribute.Code</xr:Field>
\t\t\t</InputByString>
\t\t\t<SearchStringModeOnInputByString>Begin</SearchStringModeOnInputByString>
\t\t\t<FullTextSearchOnInputByString>DontUse</FullTextSearchOnInputByString>
\t\t\t<ChoiceDataGetModeOnInputByString>Directly</ChoiceDataGetModeOnInputByString>
\t\t\t<DefaultObjectForm/>
\t\t\t<DefaultListForm/>
\t\t\t<DefaultChoiceForm/>
\t\t\t<AuxiliaryObjectForm/>
\t\t\t<AuxiliaryListForm/>
\t\t\t<AuxiliaryChoiceForm/>
\t\t\t<DataLockControlMode>Managed</DataLockControlMode>
\t\t\t<FullTextSearch>DontUse</FullTextSearch>
\t\t\t<ObjectPresentation/>
\t\t\t<ExtendedObjectPresentation/>
\t\t\t<ListPresentation/>
\t\t\t<ExtendedListPresentation/>
\t\t\t<Explanation/>
\t\t\t<ChoiceHistoryOnInput>Auto</ChoiceHistoryOnInput>
\t\t\t<Predefined>
\t\t\t\t<Item id="{uid()}">
\t\t\t\t\t<Name>Cash</Name>
\t\t\t\t\t<Code>111</Code>
\t\t\t\t\t<Description>Cash in hand</Description>
\t\t\t\t\t<Order>111</Order>
\t\t\t\t\t<Type>Active</Type>
\t\t\t\t\t<OffBalance>false</OffBalance>
\t\t\t\t</Item>
\t\t\t\t<Item id="{uid()}">
\t\t\t\t\t<Name>BankDeposits</Name>
\t\t\t\t\t<Code>112</Code>
\t\t\t\t\t<Description>Bank deposits</Description>
\t\t\t\t\t<Order>112</Order>
\t\t\t\t\t<Type>Active</Type>
\t\t\t\t\t<OffBalance>false</OffBalance>
\t\t\t\t</Item>
\t\t\t\t<Item id="{uid()}">
\t\t\t\t\t<Name>HardwareComponents</Name>
\t\t\t\t\t<Code>156</Code>
\t\t\t\t\t<Description>Hardware components</Description>
\t\t\t\t\t<Order>156</Order>
\t\t\t\t\t<Type>Active</Type>
\t\t\t\t\t<OffBalance>false</OffBalance>
\t\t\t\t</Item>
\t\t\t\t<Item id="{uid()}">
\t\t\t\t\t<Name>AccountsPayable</Name>
\t\t\t\t\t<Code>331</Code>
\t\t\t\t\t<Description>Accounts payable</Description>
\t\t\t\t\t<Order>331</Order>
\t\t\t\t\t<Type>ActivePassive</Type>
\t\t\t\t\t<OffBalance>false</OffBalance>
\t\t\t\t</Item>
\t\t\t\t<Item id="{uid()}">
\t\t\t\t\t<Name>CloudInfrastructure</Name>
\t\t\t\t\t<Code>627</Code>
\t\t\t\t\t<Description>Cloud infrastructure</Description>
\t\t\t\t\t<Order>627</Order>
\t\t\t\t\t<Type>Active</Type>
\t\t\t\t\t<OffBalance>false</OffBalance>
\t\t\t\t</Item>
\t\t\t\t<Item id="{uid()}">
\t\t\t\t\t<Name>SoftwareLicenses</Name>
\t\t\t\t\t<Code>642</Code>
\t\t\t\t\t<Description>Software licenses</Description>
\t\t\t\t\t<Order>642</Order>
\t\t\t\t\t<Type>Active</Type>
\t\t\t\t\t<OffBalance>false</OffBalance>
\t\t\t\t</Item>
\t\t\t</Predefined>
\t\t</Properties>
\t\t<ChildObjects/>
\t</ChartOfAccounts>
</MetaDataObject>"""

    with open("src/ChartsOfAccounts/Main.xml", "w", encoding="utf-8") as f:
        f.write(coa_xml)

    # AccountingRegister.GeneralLedger
    reg_id = uid()
    reg_xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<MetaDataObject xmlns="http://v8.1c.ru/8.3/MDClasses" xmlns:app="http://v8.1c.ru/8.2/managed-application/core" xmlns:cfg="http://v8.1c.ru/8.1/data/enterprise/current-config" xmlns:cmi="http://v8.1c.ru/8.2/managed-application/cmi" xmlns:ent="http://v8.1c.ru/8.1/data/enterprise" xmlns:lf="http://v8.1c.ru/8.2/managed-application/logform" xmlns:style="http://v8.1c.ru/8.1/data/ui/style" xmlns:sys="http://v8.1c.ru/8.1/data/ui/fonts/system" xmlns:v8="http://v8.1c.ru/8.1/data/core" xmlns:v8ui="http://v8.1c.ru/8.1/data/ui" xmlns:web="http://v8.1c.ru/8.1/data/ui/colors/web" xmlns:win="http://v8.1c.ru/8.1/data/ui/colors/windows" xmlns:xen="http://v8.1c.ru/8.3/xcf/enums" xmlns:xpr="http://v8.1c.ru/8.3/xcf/predef" xmlns:xr="http://v8.1c.ru/8.3/xcf/readable" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.15">
\t<AccountingRegister uuid="{reg_id}">
\t\t<InternalInfo>
\t\t\t<xr:GeneratedType name="AccountingRegisterRecord.GeneralLedger" category="Record">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="AccountingRegisterManager.GeneralLedger" category="Manager">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="AccountingRegisterSelection.GeneralLedger" category="Selection">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="AccountingRegisterList.GeneralLedger" category="List">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="AccountingRegisterRecordSet.GeneralLedger" category="RecordSet">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="AccountingRegisterRecordKey.GeneralLedger" category="RecordKey">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t</InternalInfo>
\t\t<Properties>
\t\t\t<Name>GeneralLedger</Name>
\t\t\t<Synonym>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t<v8:content>General Ledger</v8:content>
\t\t\t\t</v8:item>
\t\t\t</Synonym>
\t\t\t<Comment/>
\t\t\t<UseStandardCommands>true</UseStandardCommands>
\t\t\t<IncludeHelpInContents>false</IncludeHelpInContents>
\t\t\t<ChartOfAccounts>ChartOfAccounts.Main</ChartOfAccounts>
\t\t\t<Correspondence>true</Correspondence>
\t\t\t<PeriodAdjustmentLength>0</PeriodAdjustmentLength>
\t\t\t<DefaultListForm/>
\t\t\t<AuxiliaryListForm/>
\t\t\t<DataLockControlMode>Managed</DataLockControlMode>
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
\t\t\t\t\t<Balance>true</Balance>
\t\t\t\t</Properties>
\t\t\t</Resource>
\t\t</ChildObjects>
\t</AccountingRegister>
</MetaDataObject>"""

    with open("src/AccountingRegisters/GeneralLedger.xml", "w", encoding="utf-8") as f:
        f.write(reg_xml)

    # Update Configuration.xml
    with open("src/Configuration.xml", "r", encoding="utf-8") as f:
        cfg = f.read()

    new_items = """\t\t\t<ChartOfAccounts>Main</ChartOfAccounts>
\t\t\t<AccountingRegister>GeneralLedger</AccountingRegister>"""

    if "<ChartOfAccounts>Main</ChartOfAccounts>" not in cfg:
        cfg = cfg.replace("\t\t</ChildObjects>", f"{new_items}\n\t\t</ChildObjects>")
        with open("src/Configuration.xml", "w", encoding="utf-8") as f:
            f.write(cfg)

    # Update Subsystems/AccountsPayable.xml
    with open("src/Subsystems/AccountsPayable.xml", "r", encoding="utf-8") as f:
        ss = f.read()
    
    ss_items = """\t\t\t\t<xr:Item xsi:type="xr:MDObjectRef">ChartOfAccounts.Main</xr:Item>
\t\t\t\t<xr:Item xsi:type="xr:MDObjectRef">AccountingRegister.GeneralLedger</xr:Item>"""
    if "ChartOfAccounts.Main" not in ss:
        ss = ss.replace("\t\t\t</Content>", f"{ss_items}\n\t\t\t</Content>")
        with open("src/Subsystems/AccountsPayable.xml", "w", encoding="utf-8") as f:
            f.write(ss)

    print("Task 2 files written successfully!")

if __name__ == "__main__":
    build_task2()
