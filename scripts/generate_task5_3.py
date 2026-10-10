import os
import uuid
import xml.etree.ElementTree as ET

def uid():
    return str(uuid.uuid4())

def make_attr(name, syn_vi, syn_en, type_str, comment="", len_str=None, prec_str=None):
    attr_id = uid()
    if type_str == "String":
        type_block = f"""<Type>
\t\t\t\t\t\t<v8:Type>xs:string</v8:Type>
\t\t\t\t\t\t<v8:StringQualifiers>
\t\t\t\t\t\t\t<v8:Length>{len_str or 100}</v8:Length>
\t\t\t\t\t\t\t<v8:AllowedLength>Variable</v8:AllowedLength>
\t\t\t\t\t\t</v8:StringQualifiers>
\t\t\t\t\t</Type>"""
    elif type_str == "Number":
        type_block = f"""<Type>
\t\t\t\t\t\t<v8:Type>xs:decimal</v8:Type>
\t\t\t\t\t\t<v8:NumberQualifiers>
\t\t\t\t\t\t\t<v8:Digits>{len_str or 15}</v8:Digits>
\t\t\t\t\t\t\t<v8:FractionDigits>{prec_str or 2}</v8:FractionDigits>
\t\t\t\t\t\t\t<v8:AllowedSign>Any</v8:AllowedSign>
\t\t\t\t\t\t</v8:NumberQualifiers>
\t\t\t\t\t</Type>"""
    elif type_str == "Date":
        type_block = """<Type>
\t\t\t\t\t\t<v8:Type>xs:dateTime</v8:Type>
\t\t\t\t\t\t<v8:DateQualifiers>
\t\t\t\t\t\t\t<v8:DateFractions>DateTime</v8:DateFractions>
\t\t\t\t\t\t</v8:DateQualifiers>
\t\t\t\t\t</Type>"""
    elif type_str == "Boolean":
        type_block = """<Type>
\t\t\t\t\t\t<v8:Type>xs:boolean</v8:Type>
\t\t\t\t\t</Type>"""
    else: # Reference type
        type_block = f"""<Type>
\t\t\t\t\t\t<v8:Type>cfg:{type_str}</v8:Type>
\t\t\t\t\t</Type>"""

    return f"""\t\t\t<Attribute uuid="{attr_id}">
\t\t\t\t<Properties>
\t\t\t\t\t<Name>{name}</Name>
\t\t\t\t\t<Synonym>
\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t<v8:lang>vi</v8:lang>
\t\t\t\t\t\t\t<v8:content>{syn_vi}</v8:content>
\t\t\t\t\t\t</v8:item>
\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t\t<v8:content>{syn_en}</v8:content>
\t\t\t\t\t\t</v8:item>
\t\t\t\t\t</Synonym>
\t\t\t\t\t<Comment>{comment}</Comment>
\t\t\t\t\t{type_block}
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
\t\t\t\t\t<FillFromFillingValue>false</FillFromFillingValue>
\t\t\t\t\t<FillValue xsi:nil="true"/>
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
\t\t\t\t\t<DataHistory>Use</DataHistory>
\t\t\t\t</Properties>
\t\t\t</Attribute>"""

def make_tabular_attr(name, syn_vi, syn_en, type_str, comment="", len_str=None, prec_str=None):
    attr_id = uid()
    if type_str == "String":
        type_block = f"""<Type>
\t\t\t\t\t\t\t<v8:Type>xs:string</v8:Type>
\t\t\t\t\t\t\t<v8:StringQualifiers>
\t\t\t\t\t\t\t\t<v8:Length>{len_str or 100}</v8:Length>
\t\t\t\t\t\t\t\t<v8:AllowedLength>Variable</v8:AllowedLength>
\t\t\t\t\t\t\t</v8:StringQualifiers>
\t\t\t\t\t\t</Type>"""
    elif type_str == "Number":
        type_block = f"""<Type>
\t\t\t\t\t\t\t<v8:Type>xs:decimal</v8:Type>
\t\t\t\t\t\t\t<v8:NumberQualifiers>
\t\t\t\t\t\t\t\t<v8:Digits>{len_str or 15}</v8:Digits>
\t\t\t\t\t\t\t\t<v8:FractionDigits>{prec_str or 2}</v8:FractionDigits>
\t\t\t\t\t\t\t\t<v8:AllowedSign>Any</v8:AllowedSign>
\t\t\t\t\t\t\t</v8:NumberQualifiers>
\t\t\t\t\t\t</Type>"""
    elif type_str == "Date":
        type_block = """<Type>
\t\t\t\t\t\t\t<v8:Type>xs:dateTime</v8:Type>
\t\t\t\t\t\t\t<v8:DateQualifiers>
\t\t\t\t\t\t\t\t<v8:DateFractions>DateTime</v8:DateFractions>
\t\t\t\t\t\t\t</v8:DateQualifiers>
\t\t\t\t\t\t</Type>"""
    elif type_str == "Boolean":
        type_block = """<Type>
\t\t\t\t\t\t\t<v8:Type>xs:boolean</v8:Type>
\t\t\t\t\t\t</Type>"""
    else: # Reference type
        type_block = f"""<Type>
\t\t\t\t\t\t\t<v8:Type>cfg:{type_str}</v8:Type>
\t\t\t\t\t\t</Type>"""

    return f"""\t\t\t\t\t<Attribute uuid="{attr_id}">
\t\t\t\t\t\t<Properties>
\t\t\t\t\t\t\t<Name>{name}</Name>
\t\t\t\t\t\t\t<Synonym>
\t\t\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t\t\t<v8:lang>vi</v8:lang>
\t\t\t\t\t\t\t\t\t<v8:content>{syn_vi}</v8:content>
\t\t\t\t\t\t\t\t</v8:item>
\t\t\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t\t\t\t<v8:content>{syn_en}</v8:content>
\t\t\t\t\t\t\t\t</v8:item>
\t\t\t\t\t\t\t</Synonym>
\t\t\t\t\t\t\t<Comment>{comment}</Comment>
\t\t\t\t\t\t\t{type_block}
\t\t\t\t\t\t\t<PasswordMode>false</PasswordMode>
\t\t\t\t\t\t\t<Format/>
\t\t\t\t\t\t\t<EditFormat/>
\t\t\t\t\t\t\t<ToolTip/>
\t\t\t\t\t\t\t<MarkNegatives>false</MarkNegatives>
\t\t\t\t\t\t\t<Mask/>
\t\t\t\t\t\t\t<MultiLine>false</MultiLine>
\t\t\t\t\t\t\t<ExtendedEdit>false</ExtendedEdit>
\t\t\t\t\t\t\t<MinValue xsi:nil="true"/>
\t\t\t\t\t\t\t<MaxValue xsi:nil="true"/>
\t\t\t\t\t\t\t<FillFromFillingValue>false</FillFromFillingValue>
\t\t\t\t\t\t\t<FillValue xsi:nil="true"/>
\t\t\t\t\t\t\t<FillChecking>DontCheck</FillChecking>
\t\t\t\t\t\t\t<ChoiceFoldersAndItems>Items</ChoiceFoldersAndItems>
\t\t\t\t\t\t\t<ChoiceParameterLinks/>
\t\t\t\t\t\t\t<ChoiceParameters/>
\t\t\t\t\t\t\t<QuickChoice>Auto</QuickChoice>
\t\t\t\t\t\t\t<CreateOnInput>Auto</CreateOnInput>
\t\t\t\t\t\t\t<ChoiceForm/>
\t\t\t\t\t\t\t<LinkByType/>
\t\t\t\t\t\t\t<ChoiceHistoryOnInput>Auto</ChoiceHistoryOnInput>
\t\t\t\t\t\t\t<Indexing>DontIndex</Indexing>
\t\t\t\t\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t\t\t\t\t<DataHistory>Use</DataHistory>
\t\t\t\t\t\t</Properties>
\t\t\t\t\t</Attribute>"""

def generate_bang_ke():
    doc_uuid = uid()
    tab_uuid = uid()
    tab_type_uuid = uid()
    tab_val_uuid = uid()
    row_type_uuid = uid()
    row_val_uuid = uid()

    header_attrs = [
        make_attr("PhapNhan", "Pháp nhân", "Legal Entity", "CatalogRef.PhapNhan", "Pháp nhân thụ hưởng"),
        make_attr("KenhThanhToan", "Kênh thanh toán", "Payment Gateway", "CatalogRef.KenhThanhToan", "Kênh thanh toán điện tử"),
        make_attr("TaiKhoanNganHang", "Tài khoản ngân hàng nhận", "Bank Account", "CatalogRef.TaiKhoanTien", "Tài khoản nhận tiền về"),
        make_attr("KhoanMucDongTien", "Khoản mục dòng tiền", "Cash Flow Item", "CatalogRef.KhoanMucDongTien", "Khoản mục dòng tiền"),
        make_attr("NgayBatDau", "Ngày bắt đầu", "Start Date", "Date", "Kỳ đối soát từ ngày"),
        make_attr("NgayKetThuc", "Ngày kết thúc", "End Date", "Date", "Kỳ đối soát đến ngày"),
        make_attr("TongTienGiaoDich", "Tổng tiền giao dịch", "Total Amount", "Number", "Tổng tiền gốc trước phí", len_str=15, prec_str=2),
        make_attr("TongPhiKenh", "Tổng phí kênh", "Total Gateway Fee", "Number", "Tổng phí kênh thanh toán khấu trừ", len_str=15, prec_str=2),
        make_attr("TongThucNhan", "Tổng thực nhận", "Total Net Received", "Number", "Tổng tiền thực nhận về tài khoản ngân hàng", len_str=15, prec_str=2),
        make_attr("TrangThai", "Trạng thái", "Status", "String", "MoiTao / DaDoiSoat / HoanTat", len_str=50),
        make_attr("GhiChu", "Ghi chú", "Note", "String", "Ghi chú bảng kê", len_str=250),
        make_attr("NguoiLap", "Người lập", "Created By", "String", "Người lập bảng kê", len_str=100),
        make_attr("NguoiDuyet", "Người duyệt", "Approved By", "String", "Người phê duyệt bảng kê", len_str=100)
    ]

    tab_attrs = [
        make_tabular_attr("MaGiaoDichKenh", "Mã giao dịch kênh", "Gateway Txn ID", "String", "Mã giao dịch từ cổng thanh toán", len_str=100),
        make_tabular_attr("NgayGiaoDich", "Ngày giao dịch", "Txn Date", "Date", "Ngày phát sinh giao dịch"),
        make_tabular_attr("SoTien", "Số tiền", "Amount", "Number", "Số tiền thanh toán", len_str=15, prec_str=2),
        make_tabular_attr("PhiKenh", "Phí kênh", "Gateway Fee", "Number", "Phí kênh giao dịch", len_str=15, prec_str=2),
        make_tabular_attr("ThucNhan", "Thực nhận", "Net Amount", "Number", "Số tiền thực nhận sau phí", len_str=15, prec_str=2),
        make_tabular_attr("HopDong", "Hợp đồng", "Contract", "CatalogRef.HopDong", "Hợp đồng dịch vụ liên quan"),
        make_tabular_attr("DoiTac", "Đối tác / Khách hàng", "Partner", "CatalogRef.DoiTac", "Khách hàng thanh toán"),
        make_tabular_attr("TrangThaiKhop", "Trạng thái khớp", "Is Matched", "Boolean", "Đã khớp với sổ tạm giữ")
    ]

    header_attrs_str = "\n".join(header_attrs)
    tab_attrs_str = "\n".join(tab_attrs)

    xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<MetaDataObject xmlns="http://v8.1c.ru/8.3/MDClasses" xmlns:app="http://v8.1c.ru/8.2/managed-application/core" xmlns:cfg="http://v8.1c.ru/8.1/data/enterprise/current-config" xmlns:cmi="http://v8.1c.ru/8.2/managed-application/cmi" xmlns:ent="http://v8.1c.ru/8.1/data/enterprise" xmlns:lf="http://v8.1c.ru/8.2/managed-application/logform" xmlns:style="http://v8.1c.ru/8.1/data/ui/style" xmlns:sys="http://v8.1c.ru/8.1/data/ui/fonts/system" xmlns:v8="http://v8.1c.ru/8.1/data/core" xmlns:v8ui="http://v8.1c.ru/8.1/data/ui" xmlns:web="http://v8.1c.ru/8.1/data/ui/colors/web" xmlns:win="http://v8.1c.ru/8.1/data/ui/colors/windows" xmlns:xen="http://v8.1c.ru/8.3/xcf/enums" xmlns:xpr="http://v8.1c.ru/8.3/xcf/predef" xmlns:xr="http://v8.1c.ru/8.3/xcf/readable" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.15">
\t<Document uuid="{doc_uuid}">
\t\t<InternalInfo>
\t\t\t<xr:GeneratedType name="DocumentObject.BangKeDoiSoatKenhThanhToan" category="Object">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="DocumentRef.BangKeDoiSoatKenhThanhToan" category="Ref">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="DocumentSelection.BangKeDoiSoatKenhThanhToan" category="Selection">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="DocumentList.BangKeDoiSoatKenhThanhToan" category="List">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="DocumentManager.BangKeDoiSoatKenhThanhToan" category="Manager">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t</InternalInfo>
\t\t<Properties>
\t\t\t<Name>BangKeDoiSoatKenhThanhToan</Name>
\t\t\t<Synonym>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>vi</v8:lang>
\t\t\t\t\t<v8:content>Bảng kê đối soát kênh thanh toán</v8:content>
\t\t\t\t</v8:item>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t<v8:content>Payment Gateway Reconciliation Statement</v8:content>
\t\t\t\t</v8:item>
\t\t\t</Synonym>
\t\t\t<Comment>Bảng kê đối soát định kỳ cổng thanh toán điện tử (Task 5.3)</Comment>
\t\t\t<UseStandardCommands>true</UseStandardCommands>
\t\t\t<Numerator/>
\t\t\t<NumberType>String</NumberType>
\t\t\t<NumberLength>20</NumberLength>
\t\t\t<NumberAllowedLength>Variable</NumberAllowedLength>
\t\t\t<NumberPeriodicity>Nonperiodical</NumberPeriodicity>
\t\t\t<CheckUnique>true</CheckUnique>
\t\t\t<Autonumbering>true</Autonumbering>
\t\t\t<Characteristics/>
\t\t\t<BasedOn/>
\t\t\t<InputByString>
\t\t\t\t<xr:Field>Document.BangKeDoiSoatKenhThanhToan.StandardAttribute.Number</xr:Field>
\t\t\t</InputByString>
\t\t\t<CreateOnInput>Use</CreateOnInput>
\t\t\t<SearchStringModeOnInputByString>Begin</SearchStringModeOnInputByString>
\t\t\t<FullTextSearchOnInputByString>DontUse</FullTextSearchOnInputByString>
\t\t\t<ChoiceDataGetModeOnInputByString>Directly</ChoiceDataGetModeOnInputByString>
\t\t\t<DefaultObjectForm/>
\t\t\t<DefaultListForm/>
\t\t\t<DefaultChoiceForm/>
\t\t\t<AuxiliaryObjectForm/>
\t\t\t<AuxiliaryListForm/>
\t\t\t<AuxiliaryChoiceForm/>
\t\t\t<Posting>Allow</Posting>
\t\t\t<RealTimePosting>Allow</RealTimePosting>
\t\t\t<RegisterRecordsDeletion>AutoDeleteOnUnpost</RegisterRecordsDeletion>
\t\t\t<RegisterRecordsWritingOnPost>WriteSelected</RegisterRecordsWritingOnPost>
\t\t\t<SequenceFilling>AutoFill</SequenceFilling>
\t\t\t<RegisterRecords>
\t\t\t\t<xr:Item xsi:type="xr:MDObjectRef">AccumulationRegister.GiaoDichDienTuTamGiu</xr:Item>
\t\t\t\t<xr:Item xsi:type="xr:MDObjectRef">AccumulationRegister.DongTien</xr:Item>
\t\t\t\t<xr:Item xsi:type="xr:MDObjectRef">AccountingRegister.SoCaiKeToan</xr:Item>
\t\t\t</RegisterRecords>
\t\t\t<PostInPrivilegedMode>true</PostInPrivilegedMode>
\t\t\t<UnpostInPrivilegedMode>true</UnpostInPrivilegedMode>
\t\t\t<IncludeHelpInContents>false</IncludeHelpInContents>
\t\t\t<DataLockFields/>
\t\t\t<DataLockControlMode>Managed</DataLockControlMode>
\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t<ObjectPresentation/>
\t\t\t<ExtendedObjectPresentation/>
\t\t\t<ListPresentation/>
\t\t\t<ExtendedListPresentation/>
\t\t\t<Explanation/>
\t\t\t<ChoiceHistoryOnInput>Auto</ChoiceHistoryOnInput>
\t\t\t<DataHistory>DontUse</DataHistory>
\t\t\t<UpdateDataHistoryImmediatelyAfterWrite>false</UpdateDataHistoryImmediatelyAfterWrite>
\t\t\t<ExecuteAfterWriteDataHistoryVersionProcessing>false</ExecuteAfterWriteDataHistoryVersionProcessing>
\t\t</Properties>
\t\t<ChildObjects>
{header_attrs_str}
\t\t\t<TabularSection uuid="{tab_uuid}">
\t\t\t\t<InternalInfo>
\t\t\t\t\t<xr:GeneratedType name="DocumentTabularSection.BangKeDoiSoatKenhThanhToan.ChiTietGiaoDich" category="TabularSection">
\t\t\t\t\t\t<xr:TypeId>{tab_type_uuid}</xr:TypeId>
\t\t\t\t\t\t<xr:ValueId>{tab_val_uuid}</xr:ValueId>
\t\t\t\t\t</xr:GeneratedType>
\t\t\t\t\t<xr:GeneratedType name="DocumentTabularSectionRow.BangKeDoiSoatKenhThanhToan.ChiTietGiaoDich" category="TabularSectionRow">
\t\t\t\t\t\t<xr:TypeId>{row_type_uuid}</xr:TypeId>
\t\t\t\t\t\t<xr:ValueId>{row_val_uuid}</xr:ValueId>
\t\t\t\t\t</xr:GeneratedType>
\t\t\t\t</InternalInfo>
\t\t\t\t<Properties>
\t\t\t\t\t<Name>ChiTietGiaoDich</Name>
\t\t\t\t\t<Synonym>
\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t<v8:lang>vi</v8:lang>
\t\t\t\t\t\t\t<v8:content>Chi tiết giao dịch</v8:content>
\t\t\t\t\t\t</v8:item>
\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t\t<v8:content>Transaction Details</v8:content>
\t\t\t\t\t\t</v8:item>
\t\t\t\t\t</Synonym>
\t\t\t\t\t<Comment/>
\t\t\t\t\t<ToolTip/>
\t\t\t\t\t<FillChecking>DontCheck</FillChecking>
\t\t\t\t</Properties>
\t\t\t\t<ChildObjects>
{tab_attrs_str}
\t\t\t\t</ChildObjects>
\t\t\t</TabularSection>
\t\t</ChildObjects>
\t</Document>
</MetaDataObject>"""

    os.makedirs("src/Documents/BangKeDoiSoatKenhThanhToan/Ext", exist_ok=True)
    with open("src/Documents/BangKeDoiSoatKenhThanhToan.xml", "w", encoding="utf-8") as f:
        f.write(xml)
    print("Generated src/Documents/BangKeDoiSoatKenhThanhToan.xml")

    # ObjectModule for BangKeDoiSoatKenhThanhToan
    bsl = """// Document: BangKeDoiSoatKenhThanhToan
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Xu ly su kien ghi so Bang ke doi soat kenh thanh toan (Task 5.3):
//           - Tinh toan tong cong cac dong chi tiet (Truoc khi ghi)
//           - Ghi giam so du tren AccumulationRegister.GiaoDichDienTuTamGiu (Expense)
//           - Ghi tang dong tien tren AccumulationRegister.DongTien (Receipt)
//           - Ghi so cai SoCaiKeToan:
//             + No TK 1121: Tong thuc nhan
//             + No TK 6427: Tong phi kenh
//             + Co TK 1388: Tong tien giao dich
//           - Kiem tra Invariant can doi SoCaiKeToan (Delta = 0)

#Region EventHandlers

Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	If DataExchange.Load Then
		Return;
	EndIf;
	
	// Tu dong tinh tong giao dich, phi kenh, thuc nhan tu bang ChiTietGiaoDich neu co
	If ChiTietGiaoDich.Count() > 0 Then
		TongGD = 0;
		TongPhi = 0;
		TongNhan = 0;
		
		For Each Row In ChiTietGiaoDich Do
			If Row.ThucNhan = 0 And Row.SoTien > 0 Then
				Row.ThucNhan = Row.SoTien - Row.PhiKenh;
			EndIf;
			TongGD = TongGD + Row.SoTien;
			TongPhi = TongPhi + Row.PhiKenh;
			TongNhan = TongNhan + Row.ThucNhan;
		EndDo;
		
		TongTienGiaoDich = TongGD;
		TongPhiKenh = TongPhi;
		TongThucNhan = TongNhan;
	Else
		// Neu khong nhap chi tiet thi tu dong can bang ThucNhan = TongTien - PhiKenh
		If TongThucNhan = 0 And TongTienGiaoDich > 0 Then
			TongThucNhan = TongTienGiaoDich - TongPhiKenh;
		EndIf;
	EndIf;
EndProcedure

Procedure Posting(Cancel, Mode)
	// 1. Kiem tra tinh hop le
	If Not ValueIsFilled(PhapNhan) Then
		Cancel = True;
		Raise "Trường 'Pháp nhân' chưa được điền!";
		Return;
	EndIf;
	If Not ValueIsFilled(KenhThanhToan) Then
		Cancel = True;
		Raise "Trường 'Kênh thanh toán' chưa được điền!";
		Return;
	EndIf;
	If Not ValueIsFilled(TaiKhoanNganHang) Then
		Cancel = True;
		Raise "Trường 'Tài khoản ngân hàng' chưa được điền!";
		Return;
	EndIf;
	If TongTienGiaoDich <= 0 Then
		Cancel = True;
		Raise "Tổng tiền giao dịch đối soát phải lớn hơn 0!";
		Return;
	EndIf;
	
	NgayHachToan = BegOfDay(Date);
	
	// 2. Ghi giam so du tren GiaoDichDienTuTamGiu (Expense)
	RegisterRecords.GiaoDichDienTuTamGiu.Write = True;
	If ChiTietGiaoDich.Count() > 0 Then
		For Each Row In ChiTietGiaoDich Do
			RecTamGiu = RegisterRecords.GiaoDichDienTuTamGiu.Add();
			RecTamGiu.RecordType = AccumulationRecordType.Expense;
			RecTamGiu.Period = NgayHachToan;
			RecTamGiu.PhapNhan = PhapNhan;
			RecTamGiu.KenhThanhToan = KenhThanhToan;
			RecTamGiu.MaGiaoDichKenh = Row.MaGiaoDichKenh;
			RecTamGiu.SoTien = Row.SoTien;
			RecTamGiu.PhiKenh = Row.PhiKenh;
		EndDo;
	Else
		RecTamGiu = RegisterRecords.GiaoDichDienTuTamGiu.Add();
		RecTamGiu.RecordType = AccumulationRecordType.Expense;
		RecTamGiu.Period = NgayHachToan;
		RecTamGiu.PhapNhan = PhapNhan;
		RecTamGiu.KenhThanhToan = KenhThanhToan;
		RecTamGiu.MaGiaoDichKenh = Number;
		RecTamGiu.SoTien = TongTienGiaoDich;
		RecTamGiu.PhiKenh = TongPhiKenh;
	EndIf;
	
	// 3. Ghi tang tien tren DongTien (Receipt)
	RegisterRecords.DongTien.Write = True;
	RecDT = RegisterRecords.DongTien.Add();
	RecDT.RecordType = AccumulationRecordType.Receipt;
	RecDT.Period = NgayHachToan;
	RecDT.PhapNhan = PhapNhan;
	RecDT.TaiKhoanTien = TaiKhoanNganHang;
	RecDT.KhoanMucDongTien = KhoanMucDongTien;
	RecDT.SoTien = TongThucNhan;
	
	// 4. Ghi so cai SoCaiKeToan
	RegisterRecords.SoCaiKeToan.Write = True;
	
	TK1121 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1121");
	TK6427 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("6427");
	TK1388 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1388");
	
	// But toan 1: Thuc nhan tien ve ngan hang
	// No 1121 / Co 1388: TongThucNhan
	Row1 = RegisterRecords.SoCaiKeToan.Add();
	Row1.Period = NgayHachToan;
	Row1.AccountDr = TK1121;
	Row1.AccountCr = TK1388;
	Row1.Amount = TongThucNhan;
	Row1.Description = StrTemplate("Thu tiền cổng thanh toán %1 theo bảng kê %2", KenhThanhToan, Number);
	Row1.PhapNhan = PhapNhan;
	
	// But toan 2: Phi kenh thanh toan
	// No 6427 / Co 1388: TongPhiKenh
	If TongPhiKenh > 0 Then
		Row2 = RegisterRecords.SoCaiKeToan.Add();
		Row2.Period = NgayHachToan;
		Row2.AccountDr = TK6427;
		Row2.AccountCr = TK1388;
		Row2.Amount = TongPhiKenh;
		Row2.Description = StrTemplate("Phí dịch vụ cổng thanh toán %1 theo bảng kê %2", KenhThanhToan, Number);
		Row2.PhapNhan = PhapNhan;
	EndIf;
	
	// Invariant Check
	QuanLyVongDoiChungTuServer.KiemTraCanDoiSoCai(RegisterRecords.SoCaiKeToan);
	
	TrangThai = "HoanTat";
EndProcedure

#EndRegion
"""
    with open("src/Documents/BangKeDoiSoatKenhThanhToan/Ext/ObjectModule.bsl", "w", encoding="utf-8") as f:
        f.write(bsl)
    print("Generated src/Documents/BangKeDoiSoatKenhThanhToan/Ext/ObjectModule.bsl")

def generate_hoan_tien():
    doc_uuid = uid()

    attrs = [
        make_attr("PhapNhan", "Pháp nhân", "Legal Entity", "CatalogRef.PhapNhan", "Pháp nhân thực hiện hoàn tiền"),
        make_attr("KenhThanhToan", "Kênh thanh toán", "Payment Gateway", "CatalogRef.KenhThanhToan", "Kênh thanh toán gốc"),
        make_attr("DoiTac", "Khách hàng hoàn tiền", "Customer / Partner", "CatalogRef.DoiTac", "Khách hàng nhận hoàn tiền"),
        make_attr("HopDong", "Hợp đồng dịch vụ", "Contract", "CatalogRef.HopDong", "Hợp đồng dịch vụ liên quan"),
        make_attr("TaiKhoanNganHangChi", "Tài khoản ngân hàng chi", "Disbursement Account", "CatalogRef.TaiKhoanTien", "Tài khoản chi tiền hoàn"),
        make_attr("KhoanMucDongTien", "Khoản mục dòng tiền", "Cash Flow Item", "CatalogRef.KhoanMucDongTien", "Khoản mục dòng tiền"),
        make_attr("MaGiaoDichGoc", "Mã giao dịch gốc", "Original Txn ID", "String", "Mã giao dịch kênh gốc cần hoàn trả", len_str=100),
        make_attr("SoTienHoan", "Số tiền hoàn", "Refund Amount", "Number", "Số tiền hoàn cho khách hàng", len_str=15, prec_str=2),
        make_attr("PhiHoanTien", "Phí hoàn tiền", "Refund Fee", "Number", "Phí phát sinh khi hoàn tiền (nếu có)", len_str=15, prec_str=2),
        make_attr("LyDoHoanTien", "Lý do hoàn tiền", "Refund Reason", "String", "Lý do hủy dịch vụ hoặc hoàn tiền chi hộ", len_str=250),
        make_attr("TrangThai", "Trạng thái", "Status", "String", "ChoDuyet / DaDuyet / DaHoanTien / TuChoi", len_str=50),
        make_attr("NguoiLap", "Người lập", "Created By", "String", "Người tạo yêu cầu hoàn tiền", len_str=100),
        make_attr("NguoiDuyet", "Người duyệt", "Approved By", "String", "Người phê duyệt hoàn tiền", len_str=100)
    ]

    attrs_str = "\n".join(attrs)

    xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<MetaDataObject xmlns="http://v8.1c.ru/8.3/MDClasses" xmlns:app="http://v8.1c.ru/8.2/managed-application/core" xmlns:cfg="http://v8.1c.ru/8.1/data/enterprise/current-config" xmlns:cmi="http://v8.1c.ru/8.2/managed-application/cmi" xmlns:ent="http://v8.1c.ru/8.1/data/enterprise" xmlns:lf="http://v8.1c.ru/8.2/managed-application/logform" xmlns:style="http://v8.1c.ru/8.1/data/ui/style" xmlns:sys="http://v8.1c.ru/8.1/data/ui/fonts/system" xmlns:v8="http://v8.1c.ru/8.1/data/core" xmlns:v8ui="http://v8.1c.ru/8.1/data/ui" xmlns:web="http://v8.1c.ru/8.1/data/ui/colors/web" xmlns:win="http://v8.1c.ru/8.1/data/ui/colors/windows" xmlns:xen="http://v8.1c.ru/8.3/xcf/enums" xmlns:xpr="http://v8.1c.ru/8.3/xcf/predef" xmlns:xr="http://v8.1c.ru/8.3/xcf/readable" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.15">
\t<Document uuid="{doc_uuid}">
\t\t<InternalInfo>
\t\t\t<xr:GeneratedType name="DocumentObject.YeuCauHoanTienChiHo" category="Object">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="DocumentRef.YeuCauHoanTienChiHo" category="Ref">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="DocumentSelection.YeuCauHoanTienChiHo" category="Selection">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="DocumentList.YeuCauHoanTienChiHo" category="List">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="DocumentManager.YeuCauHoanTienChiHo" category="Manager">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t</InternalInfo>
\t\t<Properties>
\t\t\t<Name>YeuCauHoanTienChiHo</Name>
\t\t\t<Synonym>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>vi</v8:lang>
\t\t\t\t\t<v8:content>Yêu cầu hoàn tiền chi hộ B2C</v8:content>
\t\t\t\t</v8:item>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t<v8:content>Customer Refund Payment Order</v8:content>
\t\t\t\t</v8:item>
\t\t\t</Synonym>
\t\t\t<Comment>Yêu cầu hoàn tiền cho khách hàng B2C khi hủy/lỗi dịch vụ (Task 5.3)</Comment>
\t\t\t<UseStandardCommands>true</UseStandardCommands>
\t\t\t<Numerator/>
\t\t\t<NumberType>String</NumberType>
\t\t\t<NumberLength>20</NumberLength>
\t\t\t<NumberAllowedLength>Variable</NumberAllowedLength>
\t\t\t<NumberPeriodicity>Nonperiodical</NumberPeriodicity>
\t\t\t<CheckUnique>true</CheckUnique>
\t\t\t<Autonumbering>true</Autonumbering>
\t\t\t<Characteristics/>
\t\t\t<BasedOn/>
\t\t\t<InputByString>
\t\t\t\t<xr:Field>Document.YeuCauHoanTienChiHo.StandardAttribute.Number</xr:Field>
\t\t\t</InputByString>
\t\t\t<CreateOnInput>Use</CreateOnInput>
\t\t\t<SearchStringModeOnInputByString>Begin</SearchStringModeOnInputByString>
\t\t\t<FullTextSearchOnInputByString>DontUse</FullTextSearchOnInputByString>
\t\t\t<ChoiceDataGetModeOnInputByString>Directly</ChoiceDataGetModeOnInputByString>
\t\t\t<DefaultObjectForm/>
\t\t\t<DefaultListForm/>
\t\t\t<DefaultChoiceForm/>
\t\t\t<AuxiliaryObjectForm/>
\t\t\t<AuxiliaryListForm/>
\t\t\t<AuxiliaryChoiceForm/>
\t\t\t<Posting>Allow</Posting>
\t\t\t<RealTimePosting>Allow</RealTimePosting>
\t\t\t<RegisterRecordsDeletion>AutoDeleteOnUnpost</RegisterRecordsDeletion>
\t\t\t<RegisterRecordsWritingOnPost>WriteSelected</RegisterRecordsWritingOnPost>
\t\t\t<SequenceFilling>AutoFill</SequenceFilling>
\t\t\t<RegisterRecords>
\t\t\t\t<xr:Item xsi:type="xr:MDObjectRef">AccumulationRegister.GiaoDichDienTuTamGiu</xr:Item>
\t\t\t\t<xr:Item xsi:type="xr:MDObjectRef">AccumulationRegister.DongTien</xr:Item>
\t\t\t\t<xr:Item xsi:type="xr:MDObjectRef">AccountingRegister.SoCaiKeToan</xr:Item>
\t\t\t</RegisterRecords>
\t\t\t<PostInPrivilegedMode>true</PostInPrivilegedMode>
\t\t\t<UnpostInPrivilegedMode>true</UnpostInPrivilegedMode>
\t\t\t<IncludeHelpInContents>false</IncludeHelpInContents>
\t\t\t<DataLockFields/>
\t\t\t<DataLockControlMode>Managed</DataLockControlMode>
\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t<ObjectPresentation/>
\t\t\t<ExtendedObjectPresentation/>
\t\t\t<ListPresentation/>
\t\t\t<ExtendedListPresentation/>
\t\t\t<Explanation/>
\t\t\t<ChoiceHistoryOnInput>Auto</ChoiceHistoryOnInput>
\t\t\t<DataHistory>DontUse</DataHistory>
\t\t\t<UpdateDataHistoryImmediatelyAfterWrite>false</UpdateDataHistoryImmediatelyAfterWrite>
\t\t\t<ExecuteAfterWriteDataHistoryVersionProcessing>false</ExecuteAfterWriteDataHistoryVersionProcessing>
\t\t</Properties>
\t\t<ChildObjects>
{attrs_str}
\t\t</ChildObjects>
\t</Document>
</MetaDataObject>"""

    os.makedirs("src/Documents/YeuCauHoanTienChiHo/Ext", exist_ok=True)
    with open("src/Documents/YeuCauHoanTienChiHo.xml", "w", encoding="utf-8") as f:
        f.write(xml)
    print("Generated src/Documents/YeuCauHoanTienChiHo.xml")

    # ObjectModule for YeuCauHoanTienChiHo
    bsl = """// Document: YeuCauHoanTienChiHo
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Xu ly yeu cau hoan tien chi ho cho khach hang B2C (Task 5.3):
//           - Maker-Checker: Nguoi lap khong duoc tu duyet
//           - Chi ghi so khi TrangThai = "DaDuyet" hoac "DaHoanTien"
//           - Ghi giam so du tren AccumulationRegister.GiaoDichDienTuTamGiu
//           - Ghi giam dong tien tren AccumulationRegister.DongTien (Expense)
//           - Ghi so cai SoCaiKeToan:
//             + No TK 1388: So tien hoan
//             + (No TK 6427: Phi hoan tien neu co)
//             + Co TK 1121: Tong tien chi ngan hang
//           - Invariant can doi Delta = 0

#Region EventHandlers

Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	If DataExchange.Load Then
		Return;
	EndIf;
	
	// Kiem tra Maker-Checker chan nguoi lap tu duyet
	If ValueIsFilled(NguoiLap) And ValueIsFilled(NguoiDuyet) And NguoiLap = NguoiDuyet Then
		Cancel = True;
		Raise "CẤM TUYỆT ĐỐI: Người lập yêu cầu hoàn tiền không được phép tự phê duyệt!";
		Return;
	EndIf;
	
	If Not ValueIsFilled(TrangThai) Then
		TrangThai = "ChoDuyet";
	EndIf;
EndProcedure

Procedure Posting(Cancel, Mode)
	// Chi ghi so khi da duyet hoac da hoan tien
	If TrangThai <> "DaDuyet" And TrangThai <> "DaHoanTien" Then
		RegisterRecords.GiaoDichDienTuTamGiu.Write = False;
		RegisterRecords.DongTien.Write = False;
		RegisterRecords.SoCaiKeToan.Write = False;
		Return;
	EndIf;
	
	// Kiem tra truong bat buoc
	If Not ValueIsFilled(PhapNhan) Then
		Cancel = True;
		Raise "Trường 'Pháp nhân' chưa được điền!";
		Return;
	EndIf;
	If Not ValueIsFilled(TaiKhoanNganHangChi) Then
		Cancel = True;
		Raise "Trường 'Tài khoản ngân hàng chi' chưa được điền!";
		Return;
	EndIf;
	If SoTienHoan <= 0 Then
		Cancel = True;
		Raise "Số tiền hoàn phải lớn hơn 0!";
		Return;
	EndIf;
	
	NgayHachToan = BegOfDay(Date);
	
	// 1. Giam so du tren GiaoDichDienTuTamGiu
	RegisterRecords.GiaoDichDienTuTamGiu.Write = True;
	RecTamGiu = RegisterRecords.GiaoDichDienTuTamGiu.Add();
	RecTamGiu.RecordType = AccumulationRecordType.Expense;
	RecTamGiu.Period = NgayHachToan;
	RecTamGiu.PhapNhan = PhapNhan;
	RecTamGiu.KenhThanhToan = KenhThanhToan;
	RecTamGiu.MaGiaoDichKenh = MaGiaoDichGoc;
	RecTamGiu.SoTien = SoTienHoan;
	RecTamGiu.PhiKenh = PhiHoanTien;
	
	// 2. Giam dong tien tren DongTien (Expense)
	RegisterRecords.DongTien.Write = True;
	RecDT = RegisterRecords.DongTien.Add();
	RecDT.RecordType = AccumulationRecordType.Expense;
	RecDT.Period = NgayHachToan;
	RecDT.PhapNhan = PhapNhan;
	RecDT.TaiKhoanTien = TaiKhoanNganHangChi;
	RecDT.KhoanMucDongTien = KhoanMucDongTien;
	RecDT.SoTien = SoTienHoan + PhiHoanTien;
	
	// 3. Ghi so cai SoCaiKeToan
	RegisterRecords.SoCaiKeToan.Write = True;
	
	TK1121 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1121");
	TK6427 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("6427");
	TK1388 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1388");
	
	// But toan 1: Hoan tien khach hang
	// No TK 1388 / Co TK 1121: SoTienHoan
	Row1 = RegisterRecords.SoCaiKeToan.Add();
	Row1.Period = NgayHachToan;
	Row1.AccountDr = TK1388;
	Row1.AccountCr = TK1121;
	Row1.Amount = SoTienHoan;
	Row1.Description = StrTemplate("Hoàn tiền cho khách hàng theo giao dịch %1: %2", MaGiaoDichGoc, LyDoHoanTien);
	Row1.PhapNhan = PhapNhan;
	Row1.DoiTac = DoiTac;
	Row1.HopDong = HopDong;
	
	// But toan 2: Phi hoan tien neu co
	If PhiHoanTien > 0 Then
		Row2 = RegisterRecords.SoCaiKeToan.Add();
		Row2.Period = NgayHachToan;
		Row2.AccountDr = TK6427;
		Row2.AccountCr = TK1121;
		Row2.Amount = PhiHoanTien;
		Row2.Description = StrTemplate("Phí xử lý hoàn tiền giao dịch %1", MaGiaoDichGoc);
		Row2.PhapNhan = PhapNhan;
	EndIf;
	
	// Invariant Check
	QuanLyVongDoiChungTuServer.KiemTraCanDoiSoCai(RegisterRecords.SoCaiKeToan);
	
	TrangThai = "DaHoanTien";
EndProcedure

#EndRegion
"""
    with open("src/Documents/YeuCauHoanTienChiHo/Ext/ObjectModule.bsl", "w", encoding="utf-8") as f:
        f.write(bsl)
    print("Generated src/Documents/YeuCauHoanTienChiHo/Ext/ObjectModule.bsl")

def update_configuration():
    config_path = "src/Configuration.xml"
    with open(config_path, "r", encoding="utf-8") as f:
        content = f.read()

    new_docs = "\t\t\t<Document>BangKeDoiSoatKenhThanhToan</Document>\n\t\t\t<Document>YeuCauHoanTienChiHo</Document>\n"
    new_reg = "\t\t\t<AccumulationRegister>GiaoDichDienTuTamGiu</AccumulationRegister>\n"

    if "<Document>BangKeDoiSoatKenhThanhToan</Document>" not in content:
        content = content.replace("<Document>BaoCoNganHang</Document>\n", f"<Document>BaoCoNganHang</Document>\n{new_docs}")

    if "<AccumulationRegister>GiaoDichDienTuTamGiu</AccumulationRegister>" not in content:
        content = content.replace("<AccumulationRegister>DongTien</AccumulationRegister>\n", f"<AccumulationRegister>DongTien</AccumulationRegister>\n{new_reg}")

    with open(config_path, "w", encoding="utf-8") as f:
        f.write(content)
    print("Updated src/Configuration.xml successfully!")

if __name__ == "__main__":
    generate_bang_ke()
    generate_hoan_tien()
    update_configuration()
