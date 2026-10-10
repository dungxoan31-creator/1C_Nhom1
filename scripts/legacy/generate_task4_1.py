import os
import uuid

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
\t\t\t\t\t\t\t<v8:AllowedSign>Nonnegative</v8:AllowedSign>
\t\t\t\t\t\t</v8:NumberQualifiers>
\t\t\t\t\t</Type>"""
    elif type_str == "Date":
        type_block = """<Type>
\t\t\t\t\t\t<v8:Type>xs:dateTime</v8:Type>
\t\t\t\t\t\t<v8:DateQualifiers>
\t\t\t\t\t\t\t<v8:DateFractions>Date</v8:DateFractions>
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

def generate_doc_xml():
    doc_uuid = uid()
    obj_uuid = uid()
    ref_uuid = uid()
    sel_uuid = uid()
    list_uuid = uid()
    mgr_uuid = uid()

    attrs = [
        make_attr("PhapNhan", "Pháp nhân", "Legal Entity", "CatalogRef.PhapNhan", "Pháp nhân sở hữu"),
        make_attr("DoiTac", "Nhà cung cấp", "Vendor", "CatalogRef.DoiTac", "Nhà cung cấp dịch vụ"),
        make_attr("HopDong", "Hợp đồng", "Contract", "CatalogRef.HopDong", "Hợp đồng mua dịch vụ"),
        make_attr("SoHoaDon", "Số hóa đơn", "Invoice Number", "String", "Số hóa đơn GTGT / e-Invoice", len_str=50),
        make_attr("NgayHoaDon", "Ngày hóa đơn", "Invoice Date", "Date", "Ngày phát hành hóa đơn"),
        make_attr("TienTe", "Tiền tệ", "Currency", "CatalogRef.TienTe", "Đồng tiền hóa đơn"),
        make_attr("TyGia", "Tỷ giá", "Exchange Rate", "Number", "Tỷ giá quy đổi VND", len_str=10, prec_str=4),
        make_attr("TongTien", "Tổng tiền VND", "Total Amount VND", "Number", "Tổng tiền thanh toán Gross VND", len_str=15, prec_str=2),
        make_attr("TongTienNgoaiTe", "Tổng tiền ngoại tệ", "Total Amount FCY", "Number", "Tổng tiền thanh toán nguyên tệ USD", len_str=15, prec_str=2),
        make_attr("TienDichVu", "Tiền dịch vụ", "Service Amount", "Number", "Tiền dịch vụ chưa thuế", len_str=15, prec_str=2),
        make_attr("TienThueVAT", "Tiền thuế VAT", "VAT Amount", "Number", "Tiền thuế VAT đầu vào thông thường", len_str=15, prec_str=2),
        make_attr("CoKhauTruFCT", "Có khấu trừ thuế FCT", "Has Withholding FCT", "Boolean", "Áp dụng thuế nhà thầu khấu trừ tại nguồn"),
        make_attr("TyLeThueVATNhaThau", "Tỷ lệ VAT nhà thầu (%)", "FCT VAT Rate (%)", "Number", "Tỷ lệ thuế VAT nhà thầu", len_str=5, prec_str=2),
        make_attr("TyLeThueTNDNNhaThau", "Tỷ lệ TNDN nhà thầu (%)", "FCT CIT Rate (%)", "Number", "Tỷ lệ thuế TNDN nhà thầu", len_str=5, prec_str=2),
        make_attr("TienThueVATNhaThau", "Tiền VAT nhà thầu", "FCT VAT Amount", "Number", "Tiền thuế VAT nhà thầu nộp thay", len_str=15, prec_str=2),
        make_attr("TienThueTNDNNhaThau", "Tiền TNDN nhà thầu", "FCT CIT Amount", "Number", "Tiền thuế TNDN nhà thầu nộp thay", len_str=15, prec_str=2),
        make_attr("ChiPhiVSF", "Chi phí VSF", "VSF Expense", "Number", "Chi phí hợp lý tính vào TK 627", len_str=15, prec_str=2),
        make_attr("NoThucTraNCC", "Nợ thực trả NCC", "Net Payable to Vendor", "Number", "Nợ thực tế trả nhà cung cấp", len_str=15, prec_str=2),
        make_attr("TrangThai", "Trạng thái", "Status", "EnumRef.TrangThaiHoaDonAP", "Trạng thái phê duyệt AP"),
        make_attr("TaiKhoanChiPhi", "Tài khoản chi phí", "Expense Account", "ChartOfAccountsRef.HeThongTaiKhoan", "Tài khoản chi phí TK 627"),
        make_attr("DienGiai", "Diễn giải", "Description", "String", "Nội dung hóa đơn", len_str=200)
    ]

    xml_content = f"""<?xml version="1.0" encoding="UTF-8"?>
<MetaDataObject xmlns="http://v8.1c.ru/8.3/MDClasses" xmlns:app="http://v8.1c.ru/8.2/managed-application/core" xmlns:cfg="http://v8.1c.ru/8.1/data/enterprise/current-config" xmlns:cmi="http://v8.1c.ru/8.2/managed-application/cmi" xmlns:ent="http://v8.1c.ru/8.1/data/enterprise" xmlns:lf="http://v8.1c.ru/8.2/managed-application/logform" xmlns:style="http://v8.1c.ru/8.1/data/ui/style" xmlns:sys="http://v8.1c.ru/8.1/data/ui/fonts/system" xmlns:v8="http://v8.1c.ru/8.1/data/core" xmlns:v8ui="http://v8.1c.ru/8.1/data/ui" xmlns:web="http://v8.1c.ru/8.1/data/ui/colors/web" xmlns:win="http://v8.1c.ru/8.1/data/ui/colors/windows" xmlns:xen="http://v8.1c.ru/8.3/xcf/enums" xmlns:xpr="http://v8.1c.ru/8.3/xcf/predef" xmlns:xr="http://v8.1c.ru/8.3/xcf/readable" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.15">
\t<Document uuid="{doc_uuid}">
\t\t<InternalInfo>
\t\t\t<xr:GeneratedType name="DocumentObject.HoaDonNhaCungCap" category="Object">
\t\t\t\t<xr:TypeId>{obj_uuid}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="DocumentRef.HoaDonNhaCungCap" category="Ref">
\t\t\t\t<xr:TypeId>{ref_uuid}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="DocumentSelection.HoaDonNhaCungCap" category="Selection">
\t\t\t\t<xr:TypeId>{sel_uuid}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="DocumentList.HoaDonNhaCungCap" category="List">
\t\t\t\t<xr:TypeId>{list_uuid}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="DocumentManager.HoaDonNhaCungCap" category="Manager">
\t\t\t\t<xr:TypeId>{mgr_uuid}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t</InternalInfo>
\t\t<Properties>
\t\t\t<Name>HoaDonNhaCungCap</Name>
\t\t\t<Synonym>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>vi</v8:lang>
\t\t\t\t\t<v8:content>Hóa đơn nhà cung cấp</v8:content>
\t\t\t\t</v8:item>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t<v8:content>AP Vendor Invoice</v8:content>
\t\t\t\t</v8:item>
\t\t\t</Synonym>
\t\t\t<Comment>Hóa đơn mua dịch vụ Cloud (AWS, Azure) hoặc phần cứng CNTT kèm FCT Withholding (Task 4.1)</Comment>
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
\t\t\t\t<xr:Field>Document.HoaDonNhaCungCap.StandardAttribute.Number</xr:Field>
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
\t\t\t\t<xr:Item xsi:type="xr:MDObjectRef">AccumulationRegister.CongNoPhaiTra</xr:Item>
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
\t\t\t<ExecuteVisitorGroupRegistration>false</ExecuteVisitorGroupRegistration>
\t\t</Properties>
\t\t<ChildObjects>
{chr(10).join(attrs)}
\t\t</ChildObjects>
\t</Document>
</MetaDataObject>"""

    os.makedirs("src/Documents", exist_ok=True)
    with open("src/Documents/HoaDonNhaCungCap.xml", "w", encoding="utf-8") as f:
        f.write(xml_content)
    print("Generated src/Documents/HoaDonNhaCungCap.xml successfully!")

if __name__ == "__main__":
    generate_doc_xml()
