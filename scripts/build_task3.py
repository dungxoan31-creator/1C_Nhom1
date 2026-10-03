import os
import uuid

def uid():
    return str(uuid.uuid4())

def build_task3():
    print("Building Task 3: AccountsPayable Register and VendorInvoice Document...")
    os.makedirs("src/AccumulationRegisters", exist_ok=True)
    os.makedirs("src/Documents/VendorInvoice/Ext", exist_ok=True)

    # 1. AccumulationRegister.AccountsPayable
    ap_id = uid()
    ap_xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<MetaDataObject xmlns="http://v8.1c.ru/8.3/MDClasses" xmlns:app="http://v8.1c.ru/8.2/managed-application/core" xmlns:cfg="http://v8.1c.ru/8.1/data/enterprise/current-config" xmlns:cmi="http://v8.1c.ru/8.2/managed-application/cmi" xmlns:ent="http://v8.1c.ru/8.1/data/enterprise" xmlns:lf="http://v8.1c.ru/8.2/managed-application/logform" xmlns:style="http://v8.1c.ru/8.1/data/ui/style" xmlns:sys="http://v8.1c.ru/8.1/data/ui/fonts/system" xmlns:v8="http://v8.1c.ru/8.1/data/core" xmlns:v8ui="http://v8.1c.ru/8.1/data/ui" xmlns:web="http://v8.1c.ru/8.1/data/ui/colors/web" xmlns:win="http://v8.1c.ru/8.1/data/ui/colors/windows" xmlns:xen="http://v8.1c.ru/8.3/xcf/enums" xmlns:xpr="http://v8.1c.ru/8.3/xcf/predef" xmlns:xr="http://v8.1c.ru/8.3/xcf/readable" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.15">
\t<AccumulationRegister uuid="{ap_id}">
\t\t<InternalInfo>
\t\t\t<xr:GeneratedType name="AccumulationRegisterRecord.AccountsPayable" category="Record">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="AccumulationRegisterManager.AccountsPayable" category="Manager">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="AccumulationRegisterSelection.AccountsPayable" category="Selection">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="AccumulationRegisterList.AccountsPayable" category="List">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="AccumulationRegisterRecordSet.AccountsPayable" category="RecordSet">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="AccumulationRegisterRecordKey.AccountsPayable" category="RecordKey">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t</InternalInfo>
\t\t<Properties>
\t\t\t<Name>AccountsPayable</Name>
\t\t\t<Synonym>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t<v8:content>Accounts Payable (Công nợ phải trả)</v8:content>
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
\t\t\t\t\t<Name>DueDate</Name>
\t\t\t\t\t<Synonym>
\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t\t<v8:content>Due date</v8:content>
\t\t\t\t\t\t</v8:item>
\t\t\t\t\t</Synonym>
\t\t\t\t\t<Comment/>
\t\t\t\t\t<Type>
\t\t\t\t\t\t<v8:Type>xs:dateTime</v8:Type>
\t\t\t\t\t\t<v8:DateQualifiers>
\t\t\t\t\t\t\t<v8:DateFractions>Date</v8:DateFractions>
\t\t\t\t\t\t</v8:DateQualifiers>
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
\t\t\t\t\t<Indexing>DontIndex</Indexing>
\t\t\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t\t</Properties>
\t\t\t</Attribute>
\t\t\t<Dimension uuid="{uid()}">
\t\t\t\t<Properties>
\t\t\t\t\t<Name>Company</Name>
\t\t\t\t\t<Synonym>
\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t\t<v8:content>Company</v8:content>
\t\t\t\t\t\t</v8:item>
\t\t\t\t\t</Synonym>
\t\t\t\t\t<Comment/>
\t\t\t\t\t<Type>
\t\t\t\t\t\t<v8:Type>xs:string</v8:Type>
\t\t\t\t\t\t<v8:StringQualifiers>
\t\t\t\t\t\t\t<v8:Length>50</v8:Length>
\t\t\t\t\t\t\t<v8:AllowedLength>Variable</v8:AllowedLength>
\t\t\t\t\t\t</v8:StringQualifiers>
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
\t\t\t\t\t<DenyIncompleteValues>false</DenyIncompleteValues>
\t\t\t\t\t<Indexing>DontIndex</Indexing>
\t\t\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t\t\t<UseInTotals>true</UseInTotals>
\t\t\t\t</Properties>
\t\t\t</Dimension>
\t\t\t<Dimension uuid="{uid()}">
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
\t\t\t\t\t<DenyIncompleteValues>false</DenyIncompleteValues>
\t\t\t\t\t<Indexing>DontIndex</Indexing>
\t\t\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t\t\t<UseInTotals>true</UseInTotals>
\t\t\t\t</Properties>
\t\t\t</Dimension>
\t\t\t<Dimension uuid="{uid()}">
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
\t\t\t\t\t<DenyIncompleteValues>false</DenyIncompleteValues>
\t\t\t\t\t<Indexing>DontIndex</Indexing>
\t\t\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t\t\t<UseInTotals>true</UseInTotals>
\t\t\t\t</Properties>
\t\t\t</Dimension>
\t\t\t<Dimension uuid="{uid()}">
\t\t\t\t<Properties>
\t\t\t\t\t<Name>Invoice</Name>
\t\t\t\t\t<Synonym>
\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t\t<v8:content>Invoice</v8:content>
\t\t\t\t\t\t</v8:item>
\t\t\t\t\t</Synonym>
\t\t\t\t\t<Comment/>
\t\t\t\t\t<Type>
\t\t\t\t\t\t<v8:Type>cfg:DocumentRef.VendorInvoice</v8:Type>
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
\t\t\t\t\t<DenyIncompleteValues>false</DenyIncompleteValues>
\t\t\t\t\t<Indexing>DontIndex</Indexing>
\t\t\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t\t\t<UseInTotals>true</UseInTotals>
\t\t\t\t</Properties>
\t\t\t</Dimension>
\t\t</ChildObjects>
\t</AccumulationRegister>
</MetaDataObject>"""

    with open("src/AccumulationRegisters/AccountsPayable.xml", "w", encoding="utf-8") as f:
        f.write(ap_xml)

    # 2. Document.VendorInvoice
    vi_id = uid()
    vi_xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<MetaDataObject xmlns="http://v8.1c.ru/8.3/MDClasses" xmlns:app="http://v8.1c.ru/8.2/managed-application/core" xmlns:cfg="http://v8.1c.ru/8.1/data/enterprise/current-config" xmlns:cmi="http://v8.1c.ru/8.2/managed-application/cmi" xmlns:ent="http://v8.1c.ru/8.1/data/enterprise" xmlns:lf="http://v8.1c.ru/8.2/managed-application/logform" xmlns:style="http://v8.1c.ru/8.1/data/ui/style" xmlns:sys="http://v8.1c.ru/8.1/data/ui/fonts/system" xmlns:v8="http://v8.1c.ru/8.1/data/core" xmlns:v8ui="http://v8.1c.ru/8.1/data/ui" xmlns:web="http://v8.1c.ru/8.1/data/ui/colors/web" xmlns:win="http://v8.1c.ru/8.1/data/ui/colors/windows" xmlns:xen="http://v8.1c.ru/8.3/xcf/enums" xmlns:xpr="http://v8.1c.ru/8.3/xcf/predef" xmlns:xr="http://v8.1c.ru/8.3/xcf/readable" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.15">
\t<Document uuid="{vi_id}">
\t\t<InternalInfo>
\t\t\t<xr:GeneratedType name="DocumentObject.VendorInvoice" category="Object">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="DocumentRef.VendorInvoice" category="Ref">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="DocumentSelection.VendorInvoice" category="Selection">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="DocumentList.VendorInvoice" category="List">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="DocumentManager.VendorInvoice" category="Manager">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t</InternalInfo>
\t\t<Properties>
\t\t\t<Name>VendorInvoice</Name>
\t\t\t<Synonym>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t<v8:content>Vendor invoice (Hóa đơn mua hàng/Dịch vụ)</v8:content>
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
\t\t\t\t\t<Name>VendorInvoiceNumber</Name>
\t\t\t\t\t<Synonym>
\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t\t<v8:content>Vendor invoice number</v8:content>
\t\t\t\t\t\t</v8:item>
\t\t\t\t\t</Synonym>
\t\t\t\t\t<Comment/>
\t\t\t\t\t<Type>
\t\t\t\t\t\t<v8:Type>xs:string</v8:Type>
\t\t\t\t\t\t<v8:StringQualifiers>
\t\t\t\t\t\t\t<v8:Length>30</v8:Length>
\t\t\t\t\t\t\t<v8:AllowedLength>Variable</v8:AllowedLength>
\t\t\t\t\t\t</v8:StringQualifiers>
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
\t\t\t\t\t\t\t<xr:DataPath xsi:type="xs:string">Document.VendorInvoice.Attribute.Counterparty</xr:DataPath>
\t\t\t\t\t\t\t<xr:ValueChange>Clear</xr:ValueChange>
\t\t\t\t\t\t</xr:Link>
\t\t\t\t\t</ChoiceParameterLinks>
\t\t\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t\t</Properties>
\t\t\t</Attribute>
\t\t\t<Attribute uuid="{uid()}">
\t\t\t\t<Properties>
\t\t\t\t\t<Name>DueDate</Name>
\t\t\t\t\t<Synonym>
\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t\t<v8:content>Payment due date</v8:content>
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
\t\t\t\t\t<Name>TotalAmount</Name>
\t\t\t\t\t<Synonym>
\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t\t<v8:content>Total amount</v8:content>
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
\t\t\t<Attribute uuid="{uid()}">
\t\t\t\t<Properties>
\t\t\t\t\t<Name>SourceWarehouseDoc</Name>
\t\t\t\t\t<Synonym>
\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t\t<v8:content>Source warehouse document</v8:content>
\t\t\t\t\t\t</v8:item>
\t\t\t\t\t</Synonym>
\t\t\t\t\t<Comment/>
\t\t\t\t\t<Type>
\t\t\t\t\t\t<v8:Type>cfg:DocumentRef.ReceiveAndImportProducts</v8:Type>
\t\t\t\t\t</Type>
\t\t\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t\t</Properties>
\t\t\t</Attribute>
\t\t</ChildObjects>
\t</Document>
</MetaDataObject>"""

    with open("src/Documents/VendorInvoice.xml", "w", encoding="utf-8") as f:
        f.write(vi_xml)

    # 3. ObjectModule.bsl for VendorInvoice
    bsl_code = """Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
\t// Calculate DueDate automatically if not filled
\tIf Not ValueIsFilled(DueDate) Then
\t\tPaymentDays = 30; // Default Net 30
\t\tIf ValueIsFilled(Contract) And ValueIsFilled(Contract.PaymentTermsDays) Then
\t\t\tPaymentDays = Contract.PaymentTermsDays;
\t\tEndIf;
\t\tDueDate = BegOfDay(Date) + PaymentDays * 86400;
\tEndIf;

\t// Default CashFlowItem from Contract if empty
\tIf Not ValueIsFilled(CashFlowItem) And ValueIsFilled(Contract) And ValueIsFilled(Contract.DefaultCashFlowItem) Then
\t\tCashFlowItem = Contract.DefaultCashFlowItem;
\tEndIf;
EndProcedure

Procedure Posting(Cancel, Mode)
\t// 1. Tăng nợ phải trả trong sổ chi tiết AccountsPayable
\tRegisterRecords.AccountsPayable.Write = True;
\tRecord = RegisterRecords.AccountsPayable.Add();
\tRecord.RecordType = AccumulationRecordType.Receipt;
\tRecord.Period = Date;
\tRecord.Company = "VinSmart Future";
\tRecord.Counterparty = Counterparty;
\tRecord.Contract = Contract;
\tRecord.Invoice = Ref;
\tRecord.Amount = TotalAmount;
\tRecord.DueDate = DueDate;

\t// 2. Bút toán kép vào Sổ cái Kế toán: Nợ Chi phí / Linh kiện, Có TK 331 (Phải trả NCC)
\tRegisterRecords.GeneralLedger.Write = True;
\tGLRecord = RegisterRecords.GeneralLedger.Add();
\tGLRecord.Period = Date;
\tGLRecord.AccountDr = ChartsOfAccounts.Main.CloudInfrastructure;
\tGLRecord.AccountCr = ChartsOfAccounts.Main.AccountsPayable;
\tGLRecord.Amount = TotalAmount;
EndProcedure
"""
    with open("src/Documents/VendorInvoice/Ext/ObjectModule.bsl", "w", encoding="utf-8") as f:
        f.write(bsl_code)

    # 4. Update Configuration.xml and Subsystem
    with open("src/Configuration.xml", "r", encoding="utf-8") as f:
        cfg = f.read()

    new_cfg = """\t\t\t<Document>VendorInvoice</Document>
\t\t\t<AccumulationRegister>AccountsPayable</AccumulationRegister>"""

    if "<Document>VendorInvoice</Document>" not in cfg:
        cfg = cfg.replace("\t\t</ChildObjects>", f"{new_cfg}\n\t\t</ChildObjects>")
        with open("src/Configuration.xml", "w", encoding="utf-8") as f:
            f.write(cfg)

    with open("src/Subsystems/AccountsPayable.xml", "r", encoding="utf-8") as f:
        ss = f.read()

    ss_items = """\t\t\t\t<xr:Item xsi:type="xr:MDObjectRef">Document.VendorInvoice</xr:Item>
\t\t\t\t<xr:Item xsi:type="xr:MDObjectRef">AccumulationRegister.AccountsPayable</xr:Item>"""

    if "Document.VendorInvoice" not in ss:
        ss = ss.replace("\t\t\t</Content>", f"{ss_items}\n\t\t\t</Content>")
        with open("src/Subsystems/AccountsPayable.xml", "w", encoding="utf-8") as f:
            f.write(ss)

    print("Task 3 files built successfully!")

if __name__ == "__main__":
    build_task3()
