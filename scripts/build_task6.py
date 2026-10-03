import os
import uuid

def uid():
    return str(uuid.uuid4())

def build_task6():
    print("Building Task 6: CashFlowPlan Register and Document with Due Date Scan...")
    os.makedirs("src/AccumulationRegisters", exist_ok=True)
    os.makedirs("src/Documents/CashFlowPlan/Ext", exist_ok=True)

    # 1. AccumulationRegister.CashFlowPlan
    cfp_id = uid()
    cfp_xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<MetaDataObject xmlns="http://v8.1c.ru/8.3/MDClasses" xmlns:app="http://v8.1c.ru/8.2/managed-application/core" xmlns:cfg="http://v8.1c.ru/8.1/data/enterprise/current-config" xmlns:cmi="http://v8.1c.ru/8.2/managed-application/cmi" xmlns:ent="http://v8.1c.ru/8.1/data/enterprise" xmlns:lf="http://v8.1c.ru/8.2/managed-application/logform" xmlns:style="http://v8.1c.ru/8.1/data/ui/style" xmlns:sys="http://v8.1c.ru/8.1/data/ui/fonts/system" xmlns:v8="http://v8.1c.ru/8.1/data/core" xmlns:v8ui="http://v8.1c.ru/8.1/data/ui" xmlns:web="http://v8.1c.ru/8.1/data/ui/colors/web" xmlns:win="http://v8.1c.ru/8.1/data/ui/colors/windows" xmlns:xen="http://v8.1c.ru/8.3/xcf/enums" xmlns:xpr="http://v8.1c.ru/8.3/xcf/predef" xmlns:xr="http://v8.1c.ru/8.3/xcf/readable" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.15">
\t<AccumulationRegister uuid="{cfp_id}">
\t\t<InternalInfo>
\t\t\t<xr:GeneratedType name="AccumulationRegisterRecord.CashFlowPlan" category="Record">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="AccumulationRegisterManager.CashFlowPlan" category="Manager">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="AccumulationRegisterSelection.CashFlowPlan" category="Selection">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="AccumulationRegisterList.CashFlowPlan" category="List">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="AccumulationRegisterRecordSet.CashFlowPlan" category="RecordSet">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="AccumulationRegisterRecordKey.CashFlowPlan" category="RecordKey">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t</InternalInfo>
\t\t<Properties>
\t\t\t<Name>CashFlowPlan</Name>
\t\t\t<Synonym>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t<v8:content>Cash Flow Plan (Kế hoạch lưu chuyển dòng tiền)</v8:content>
\t\t\t\t</v8:item>
\t\t\t</Synonym>
\t\t\t<Comment/>
\t\t\t<UseStandardCommands>true</UseStandardCommands>
\t\t\t<DefaultListForm/>
\t\t\t<AuxiliaryListForm/>
\t\t\t<RegisterType>Turnovers</RegisterType>
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
\t\t\t\t\t<Name>PlannedAmount</Name>
\t\t\t\t\t<Synonym>
\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t\t<v8:content>Planned amount</v8:content>
\t\t\t\t\t\t</v8:item>
\t\t\t\t\t</Synonym>
\t\t\t\t\t<Comment/>
\t\t\t\t<Type>
\t\t\t\t\t<v8:Type>xs:decimal</v8:Type>
\t\t\t\t\t<v8:NumberQualifiers>
\t\t\t\t\t\t<v8:Digits>15</v8:Digits>
\t\t\t\t\t\t<v8:FractionDigits>2</v8:FractionDigits>
\t\t\t\t\t\t<v8:AllowedSign>Any</v8:AllowedSign>
\t\t\t\t\t</v8:NumberQualifiers>
\t\t\t\t</Type>
\t\t\t\t<PasswordMode>false</PasswordMode>
\t\t\t\t<Format/>
\t\t\t\t<EditFormat/>
\t\t\t\t<ToolTip/>
\t\t\t\t<MarkNegatives>false</MarkNegatives>
\t\t\t\t<Mask/>
\t\t\t\t<MultiLine>false</MultiLine>
\t\t\t\t<ExtendedEdit>false</ExtendedEdit>
\t\t\t\t<MinValue xsi:nil="true"/>
\t\t\t\t<MaxValue xsi:nil="true"/>
\t\t\t\t<FillChecking>DontCheck</FillChecking>
\t\t\t\t<ChoiceFoldersAndItems>Items</ChoiceFoldersAndItems>
\t\t\t\t<ChoiceParameterLinks/>
\t\t\t\t<ChoiceParameters/>
\t\t\t\t<QuickChoice>Auto</QuickChoice>
\t\t\t\t<CreateOnInput>Auto</CreateOnInput>
\t\t\t\t<ChoiceForm/>
\t\t\t\t<LinkByType/>
\t\t\t\t<ChoiceHistoryOnInput>Auto</ChoiceHistoryOnInput>
\t\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t</Properties>
\t\t</Resource>
\t\t<Dimension uuid="{uid()}">
\t\t\t<Properties>
\t\t\t\t<Name>CashFlowItem</Name>
\t\t\t\t<Synonym>
\t\t\t\t\t<v8:item>
\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t<v8:content>Cash flow item</v8:content>
\t\t\t\t\t</v8:item>
\t\t\t\t</Synonym>
\t\t\t\t<Comment/>
\t\t\t\t<Type>
\t\t\t\t\t<v8:Type>cfg:CatalogRef.CashFlowItems</v8:Type>
\t\t\t\t</Type>
\t\t\t\t<DenyIncompleteValues>false</DenyIncompleteValues>
\t\t\t\t<Indexing>DontIndex</Indexing>
\t\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t\t<UseInTotals>true</UseInTotals>
\t\t\t</Properties>
\t\t</Dimension>
\t\t<Dimension uuid="{uid()}">
\t\t\t<Properties>
\t\t\t\t<Name>Counterparty</Name>
\t\t\t\t<Synonym>
\t\t\t\t\t<v8:item>
\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t<v8:content>Counterparty</v8:content>
\t\t\t\t\t</v8:item>
\t\t\t\t</Synonym>
\t\t\t\t<Comment/>
\t\t\t\t<Type>
\t\t\t\t\t<v8:Type>cfg:CatalogRef.Counterparties</v8:Type>
\t\t\t\t</Type>
\t\t\t\t<DenyIncompleteValues>false</DenyIncompleteValues>
\t\t\t\t<Indexing>DontIndex</Indexing>
\t\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t\t<UseInTotals>true</UseInTotals>
\t\t\t</Properties>
\t\t</Dimension>
\t</ChildObjects>
\t</AccumulationRegister>
</MetaDataObject>"""

    with open("src/AccumulationRegisters/CashFlowPlan.xml", "w", encoding="utf-8") as f:
        f.write(cfp_xml)

    # 2. Document.CashFlowPlan
    doc_id = uid()
    ts_id = uid()
    doc_xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<MetaDataObject xmlns="http://v8.1c.ru/8.3/MDClasses" xmlns:app="http://v8.1c.ru/8.2/managed-application/core" xmlns:cfg="http://v8.1c.ru/8.1/data/enterprise/current-config" xmlns:cmi="http://v8.1c.ru/8.2/managed-application/cmi" xmlns:ent="http://v8.1c.ru/8.1/data/enterprise" xmlns:lf="http://v8.1c.ru/8.2/managed-application/logform" xmlns:style="http://v8.1c.ru/8.1/data/ui/style" xmlns:sys="http://v8.1c.ru/8.1/data/ui/fonts/system" xmlns:v8="http://v8.1c.ru/8.1/data/core" xmlns:v8ui="http://v8.1c.ru/8.1/data/ui" xmlns:web="http://v8.1c.ru/8.1/data/ui/colors/web" xmlns:win="http://v8.1c.ru/8.1/data/ui/colors/windows" xmlns:xen="http://v8.1c.ru/8.3/xcf/enums" xmlns:xpr="http://v8.1c.ru/8.3/xcf/predef" xmlns:xr="http://v8.1c.ru/8.3/xcf/readable" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.15">
\t<Document uuid="{doc_id}">
\t\t<InternalInfo>
\t\t\t<xr:GeneratedType name="DocumentObject.CashFlowPlan" category="Object">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="DocumentRef.CashFlowPlan" category="Ref">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="DocumentSelection.CashFlowPlan" category="Selection">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="DocumentList.CashFlowPlan" category="List">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="DocumentManager.CashFlowPlan" category="Manager">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t</InternalInfo>
\t\t<Properties>
\t\t\t<Name>CashFlowPlan</Name>
\t\t\t<Synonym>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t<v8:content>Cash flow plan (Kế hoạch dòng tiền)</v8:content>
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
\t\t\t\t<xr:Item xsi:type="xr:MDObjectRef">AccumulationRegister.CashFlowPlan</xr:Item>
\t\t\t</RegisterRecords>
\t\t\t<PostInPrivilegedMode>true</PostInPrivilegedMode>
\t\t\t<UnpostInPrivilegedMode>true</UnpostInPrivilegedMode>
\t\t\t<DataLockControlMode>Managed</DataLockControlMode>
\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t</Properties>
\t\t<ChildObjects>
\t\t\t<Attribute uuid="{uid()}">
\t\t\t\t<Properties>
\t\t\t\t\t<Name>PlanPeriod</Name>
\t\t\t\t\t<Synonym>
\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t\t<v8:content>Plan period</v8:content>
\t\t\t\t\t\t</v8:item>
\t\t\t\t\t</Synonym>
\t\t\t\t\t<Comment/>
\t\t\t\t\t<Type>
\t\t\t\t\t\t<v8:Type>xs:dateTime</v8:Type>
\t\t\t\t\t\t<v8:DateQualifiers>
\t\t\t\t\t\t\t<v8:DateFractions>Date</v8:DateFractions>
\t\t\t\t\t\t</v8:DateQualifiers>
\t\t\t\t\t</Type>
\t\t\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t\t</Properties>
\t\t\t</Attribute>
\t\t\t<Attribute uuid="{uid()}">
\t\t\t\t<Properties>
\t\t\t\t\t<Name>Description</Name>
\t\t\t\t\t<Synonym>
\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t\t<v8:content>Description</v8:content>
\t\t\t\t\t\t</v8:item>
\t\t\t\t\t</Synonym>
\t\t\t\t\t<Comment/>
\t\t\t\t\t<Type>
\t\t\t\t\t\t<v8:Type>xs:string</v8:Type>
\t\t\t\t\t\t<v8:StringQualifiers>
\t\t\t\t\t\t\t<v8:Length>100</v8:Length>
\t\t\t\t\t\t\t<v8:AllowedLength>Variable</v8:AllowedLength>
\t\t\t\t\t\t</v8:StringQualifiers>
\t\t\t\t\t</Type>
\t\t\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t\t</Properties>
\t\t\t</Attribute>
\t\t\t<Attribute uuid="{uid()}">
\t\t\t\t<Properties>
\t\t\t\t\t<Name>TotalPlannedAmount</Name>
\t\t\t\t\t<Synonym>
\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t\t<v8:content>Total planned amount</v8:content>
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
\t\t\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t\t</Properties>
\t\t\t</Attribute>
\t\t\t<TabularSection uuid="{ts_id}">
\t\t\t\t<InternalInfo>
\t\t\t\t\t<xr:GeneratedType name="DocumentTabularSection.CashFlowPlan.PlannedPayments" category="TabularSection">
\t\t\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t\t\t</xr:GeneratedType>
\t\t\t\t\t<xr:GeneratedType name="DocumentTabularSectionRow.CashFlowPlan.PlannedPayments" category="TabularSectionRow">
\t\t\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t\t\t</xr:GeneratedType>
\t\t\t\t</InternalInfo>
\t\t\t\t<Properties>
\t\t\t\t\t<Name>PlannedPayments</Name>
\t\t\t\t\t<Synonym>
\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t\t<v8:content>Planned payments</v8:content>
\t\t\t\t\t\t</v8:item>
\t\t\t\t\t</Synonym>
\t\t\t\t\t<Comment/>
\t\t\t\t\t<ToolTip/>
\t\t\t\t\t<FillChecking>DontCheck</FillChecking>
\t\t\t\t</Properties>
\t\t\t\t<ChildObjects>
\t\t\t\t\t<Attribute uuid="{uid()}">
\t\t\t\t\t\t<Properties>
\t\t\t\t\t\t\t<Name>Counterparty</Name>
\t\t\t\t\t\t\t<Synonym>
\t\t\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t\t\t\t<v8:content>Counterparty</v8:content>
\t\t\t\t\t\t\t\t</v8:item>
\t\t\t\t\t\t\t</Synonym>
\t\t\t\t\t\t\t<Comment/>
\t\t\t\t\t\t\t<Type>
\t\t\t\t\t\t\t\t<v8:Type>cfg:CatalogRef.Counterparties</v8:Type>
\t\t\t\t\t\t\t</Type>
\t\t\t\t\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t\t\t\t</Properties>
\t\t\t\t\t</Attribute>
\t\t\t\t\t<Attribute uuid="{uid()}">
\t\t\t\t\t\t<Properties>
\t\t\t\t\t\t\t<Name>Contract</Name>
\t\t\t\t\t\t\t<Synonym>
\t\t\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t\t\t\t<v8:content>Contract</v8:content>
\t\t\t\t\t\t\t\t</v8:item>
\t\t\t\t\t\t\t</Synonym>
\t\t\t\t\t\t\t<Comment/>
\t\t\t\t\t\t\t<Type>
\t\t\t\t\t\t\t\t<v8:Type>cfg:CatalogRef.Contracts</v8:Type>
\t\t\t\t\t\t\t</Type>
\t\t\t\t\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t\t\t\t</Properties>
\t\t\t\t\t</Attribute>
\t\t\t\t\t<Attribute uuid="{uid()}">
\t\t\t\t\t\t<Properties>
\t\t\t\t\t\t\t<Name>CashFlowItem</Name>
\t\t\t\t\t\t\t<Synonym>
\t\t\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t\t\t\t<v8:content>Cash flow item</v8:content>
\t\t\t\t\t\t\t\t</v8:item>
\t\t\t\t\t\t\t</Synonym>
\t\t\t\t\t\t\t<Comment/>
\t\t\t\t\t\t\t<Type>
\t\t\t\t\t\t\t\t<v8:Type>cfg:CatalogRef.CashFlowItems</v8:Type>
\t\t\t\t\t\t\t</Type>
\t\t\t\t\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t\t\t\t</Properties>
\t\t\t\t\t</Attribute>
\t\t\t\t\t<Attribute uuid="{uid()}">
\t\t\t\t\t\t<Properties>
\t\t\t\t\t\t\t<Name>PlannedDueDate</Name>
\t\t\t\t\t\t\t<Synonym>
\t\t\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t\t\t\t<v8:content>Planned due date</v8:content>
\t\t\t\t\t\t\t\t</v8:item>
\t\t\t\t\t\t\t</Synonym>
\t\t\t\t\t\t\t<Comment/>
\t\t\t\t\t\t\t<Type>
\t\t\t\t\t\t\t\t<v8:Type>xs:dateTime</v8:Type>
\t\t\t\t\t\t\t\t<v8:DateQualifiers>
\t\t\t\t\t\t\t\t\t<v8:DateFractions>Date</v8:DateFractions>
\t\t\t\t\t\t\t\t</v8:DateQualifiers>
\t\t\t\t\t\t\t</Type>
\t\t\t\t\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t\t\t\t</Properties>
\t\t\t\t\t</Attribute>
\t\t\t\t\t<Attribute uuid="{uid()}">
\t\t\t\t\t\t<Properties>
\t\t\t\t\t\t\t<Name>PlannedAmount</Name>
\t\t\t\t\t\t\t<Synonym>
\t\t\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t\t\t\t<v8:content>Planned amount</v8:content>
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

    with open("src/Documents/CashFlowPlan.xml", "w", encoding="utf-8") as f:
        f.write(doc_xml)

    # ObjectModule.bsl for CashFlowPlan
    bsl_code = """Procedure Posting(Cancel, Mode)
\tRegisterRecords.CashFlowPlan.Write = True;
\tFor Each Row In PlannedPayments Do
\t\tRecord = RegisterRecords.CashFlowPlan.Add();
\t\tRecord.Period = Date;
\t\tRecord.CashFlowItem = Row.CashFlowItem;
\t\tRecord.Counterparty = Row.Counterparty;
\t\tRecord.PlannedAmount = Row.PlannedAmount;
\tEndDo;
EndProcedure

Procedure FillFromDueDates(BeginDate, EndDate) Export
\tQuery = New Query;
\tQuery.Text = 
\t"SELECT
\t|	AP.Counterparty AS Counterparty,
\t|	AP.Contract AS Contract,
\t|	AP.Invoice.CashFlowItem AS CashFlowItem,
\t|	AP.Invoice.DueDate AS PlannedDueDate,
\t|	SUM(AP.AmountBalance) AS PlannedAmount
\t|FROM
\t|	AccumulationRegister.AccountsPayable.Balance AS AP
\t|WHERE
\t|	AP.Invoice.DueDate >= &BeginDate
\t|	AND AP.Invoice.DueDate <= &EndDate
\t|GROUP BY
\t|	AP.Counterparty,
\t|	AP.Contract,
\t|	AP.Invoice.CashFlowItem,
\t|	AP.Invoice.DueDate";
\tQuery.SetParameter("BeginDate", BeginDate);
\tQuery.SetParameter("EndDate", EndDate);
\t
\tResult = Query.Execute();
\tSelection = Result.Select();
\tPlannedPayments.Clear();
\tTotal = 0;
\tWhile Selection.Next() Do
\t\tNewRow = PlannedPayments.Add();
\t\tNewRow.Counterparty = Selection.Counterparty;
\t\tNewRow.Contract = Selection.Contract;
\t\tNewRow.CashFlowItem = Selection.CashFlowItem;
\t\tNewRow.PlannedDueDate = Selection.PlannedDueDate;
\t\tNewRow.PlannedAmount = Selection.PlannedAmount;
\t\tTotal = Total + Selection.PlannedAmount;
\tEndDo;
\tTotalPlannedAmount = Total;
EndProcedure
"""
    with open("src/Documents/CashFlowPlan/Ext/ObjectModule.bsl", "w", encoding="utf-8") as f:
        f.write(bsl_code)

    # Update Configuration.xml and Subsystems
    with open("src/Configuration.xml", "r", encoding="utf-8") as f:
        cfg = f.read()

    new_cfg = """\t\t\t<Document>CashFlowPlan</Document>
\t\t\t<AccumulationRegister>CashFlowPlan</AccumulationRegister>"""

    if "<Document>CashFlowPlan</Document>" not in cfg:
        cfg = cfg.replace("\t\t</ChildObjects>", f"{new_cfg}\n\t\t</ChildObjects>")
        with open("src/Configuration.xml", "w", encoding="utf-8") as f:
            f.write(cfg)

    with open("src/Subsystems/AccountsPayable.xml", "r", encoding="utf-8") as f:
        ss = f.read()

    ss_items = """\t\t\t\t<xr:Item xsi:type="xr:MDObjectRef">Document.CashFlowPlan</xr:Item>
\t\t\t\t<xr:Item xsi:type="xr:MDObjectRef">AccumulationRegister.CashFlowPlan</xr:Item>"""

    if "Document.CashFlowPlan" not in ss:
        ss = ss.replace("\t\t\t</Content>", f"{ss_items}\n\t\t\t</Content>")
        with open("src/Subsystems/AccountsPayable.xml", "w", encoding="utf-8") as f:
            f.write(ss)

    print("Task 6 files built successfully!")

if __name__ == "__main__":
    build_task6()
