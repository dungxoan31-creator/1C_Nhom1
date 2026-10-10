import os
import uuid

def uid():
    return str(uuid.uuid4())

XML_HEADER = '<?xml version="1.0" encoding="UTF-8"?>\n<MetaDataObject xmlns="http://v8.1c.ru/8.3/MDClasses" xmlns:app="http://v8.1c.ru/8.2/managed-application/core" xmlns:cfg="http://v8.1c.ru/8.1/data/enterprise/current-config" xmlns:cmi="http://v8.1c.ru/8.2/managed-application/cmi" xmlns:ent="http://v8.1c.ru/8.1/data/enterprise" xmlns:lf="http://v8.1c.ru/8.2/managed-application/logform" xmlns:style="http://v8.1c.ru/8.1/data/ui/style" xmlns:sys="http://v8.1c.ru/8.1/data/ui/fonts/system" xmlns:v8="http://v8.1c.ru/8.1/data/core" xmlns:v8ui="http://v8.1c.ru/8.1/data/ui" xmlns:web="http://v8.1c.ru/8.1/data/ui/colors/web" xmlns:win="http://v8.1c.ru/8.1/data/ui/colors/windows" xmlns:xen="http://v8.1c.ru/8.3/xcf/enums" xmlns:xpr="http://v8.1c.ru/8.3/xcf/predef" xmlns:xr="http://v8.1c.ru/8.3/xcf/readable" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.15">'

def build_attribute_xml(attr):
    name = attr["name"]
    synonym = attr.get("synonym", name)
    attr_type = attr["type"]
    indexing = attr.get("indexing", "DontIndex")
    fill_checking = attr.get("fill_checking", "DontCheck")
    attr_id = uid()

    if attr_type == "string":
        length = attr.get("length", 50)
        type_xml = f"""\t\t\t\t\t<Type>
\t\t\t\t\t\t<v8:Type>xs:string</v8:Type>
\t\t\t\t\t\t<v8:StringQualifiers>
\t\t\t\t\t\t\t<v8:Length>{length}</v8:Length>
\t\t\t\t\t\t\t<v8:AllowedLength>Variable</v8:AllowedLength>
\t\t\t\t\t\t</v8:StringQualifiers>
\t\t\t\t\t</Type>"""
        fill_val_xml = '<FillValue xsi:type="xs:string"/>'
    elif attr_type == "boolean":
        type_xml = """\t\t\t\t\t<Type>
\t\t\t\t\t\t<v8:Type>xs:boolean</v8:Type>
\t\t\t\t\t</Type>"""
        default_bool = "true" if attr.get("fill_value") is True else "false"
        fill_val_xml = f'<FillValue xsi:type="xs:boolean">{default_bool}</FillValue>'
    elif attr_type == "number":
        digits = attr.get("digits", 10)
        fraction = attr.get("fraction", 0)
        fill_val = attr.get("fill_value", 0)
        type_xml = f"""\t\t\t\t\t<Type>
\t\t\t\t\t\t<v8:Type>xs:decimal</v8:Type>
\t\t\t\t\t\t<v8:NumberQualifiers>
\t\t\t\t\t\t\t<v8:Digits>{digits}</v8:Digits>
\t\t\t\t\t\t\t<v8:FractionDigits>{fraction}</v8:FractionDigits>
\t\t\t\t\t\t\t<v8:AllowedSign>Nonnegative</v8:AllowedSign>
\t\t\t\t\t\t</v8:NumberQualifiers>
\t\t\t\t\t</Type>"""
        fill_val_xml = f'<FillValue xsi:type="xs:decimal">{fill_val}</FillValue>'
    elif attr_type.startswith("CatalogRef.") or attr_type.startswith("EnumRef."):
        type_xml = f"""\t\t\t\t\t<Type>
\t\t\t\t\t\t<v8:Type>cfg:{attr_type}</v8:Type>
\t\t\t\t\t</Type>"""
        fill_val_xml = '<FillValue xsi:nil="true"/>'
    else:
        raise ValueError(f"Unknown type: {attr_type}")

    return f"""\t\t\t<Attribute uuid="{attr_id}">
\t\t\t\t<Properties>
\t\t\t\t\t<Name>{name}</Name>
\t\t\t\t\t<Synonym>
\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t\t<v8:content>{synonym}</v8:content>
\t\t\t\t\t\t</v8:item>
\t\t\t\t\t</Synonym>
\t\t\t\t\t<Comment/>
{type_xml}
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
\t\t\t\t\t{fill_val_xml}
\t\t\t\t\t<FillChecking>{fill_checking}</FillChecking>
\t\t\t\t\t<ChoiceFoldersAndItems>Items</ChoiceFoldersAndItems>
\t\t\t\t\t<ChoiceParameterLinks/>
\t\t\t\t\t<ChoiceParameters/>
\t\t\t\t\t<QuickChoice>Auto</QuickChoice>
\t\t\t\t\t<CreateOnInput>Auto</CreateOnInput>
\t\t\t\t\t<ChoiceForm/>
\t\t\t\t\t<LinkByType/>
\t\t\t\t\t<ChoiceHistoryOnInput>Auto</ChoiceHistoryOnInput>
\t\t\t\t\t<Use>ForItem</Use>
\t\t\t\t\t<Indexing>{indexing}</Indexing>
\t\t\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t\t\t<DataHistory>Use</DataHistory>
\t\t\t\t</Properties>
\t\t\t</Attribute>"""

def build_catalog_xml(cat_name, synonym, code_len, desc_len, attributes):
    cat_id = uid()
    obj_type_id = uid()
    obj_val_id = uid()
    ref_type_id = uid()
    ref_val_id = uid()
    sel_type_id = uid()
    sel_val_id = uid()
    list_type_id = uid()
    list_val_id = uid()
    mgr_type_id = uid()
    mgr_val_id = uid()

    attrs_xml = "\n".join(build_attribute_xml(a) for a in attributes)

    xml = f"""{XML_HEADER}
\t<Catalog uuid="{cat_id}">
\t\t<InternalInfo>
\t\t\t<xr:GeneratedType name="CatalogObject.{cat_name}" category="Object">
\t\t\t\t<xr:TypeId>{obj_type_id}</xr:TypeId>
\t\t\t\t<xr:ValueId>{obj_val_id}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="CatalogRef.{cat_name}" category="Ref">
\t\t\t\t<xr:TypeId>{ref_type_id}</xr:TypeId>
\t\t\t\t<xr:ValueId>{ref_val_id}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="CatalogSelection.{cat_name}" category="Selection">
\t\t\t\t<xr:TypeId>{sel_type_id}</xr:TypeId>
\t\t\t\t<xr:ValueId>{sel_val_id}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="CatalogList.{cat_name}" category="List">
\t\t\t\t<xr:TypeId>{list_type_id}</xr:TypeId>
\t\t\t\t<xr:ValueId>{list_val_id}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="CatalogManager.{cat_name}" category="Manager">
\t\t\t\t<xr:TypeId>{mgr_type_id}</xr:TypeId>
\t\t\t\t<xr:ValueId>{mgr_val_id}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t</InternalInfo>
\t\t<Properties>
\t\t\t<Name>{cat_name}</Name>
\t\t\t<Synonym>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t<v8:content>{synonym}</v8:content>
\t\t\t\t</v8:item>
\t\t\t</Synonym>
\t\t\t<Comment/>
\t\t\t<Hierarchical>false</Hierarchical>
\t\t\t<HierarchyType>HierarchyFoldersAndItems</HierarchyType>
\t\t\t<LimitLevelCount>false</LimitLevelCount>
\t\t\t<LevelCount>2</LevelCount>
\t\t\t<FoldersOnTop>true</FoldersOnTop>
\t\t\t<UseStandardCommands>true</UseStandardCommands>
\t\t\t<Owners/>
\t\t\t<SubordinationUse>ToItems</SubordinationUse>
\t\t\t<CodeLength>{code_len}</CodeLength>
\t\t\t<DescriptionLength>{desc_len}</DescriptionLength>
\t\t\t<CodeType>String</CodeType>
\t\t\t<CodeAllowedLength>Variable</CodeAllowedLength>
\t\t\t<CodeSeries>WholeCatalog</CodeSeries>
\t\t\t<CheckUnique>true</CheckUnique>
\t\t\t<Autonumbering>true</Autonumbering>
\t\t\t<DefaultPresentation>AsDescription</DefaultPresentation>
\t\t\t<Characteristics/>
\t\t\t<PredefinedDataUpdate>Auto</PredefinedDataUpdate>
\t\t\t<EditType>InDialog</EditType>
\t\t\t<QuickChoice>false</QuickChoice>
\t\t\t<ChoiceMode>BothWays</ChoiceMode>
\t\t\t<InputByString>
\t\t\t\t<xr:Field>Catalog.{cat_name}.StandardAttribute.Description</xr:Field>
\t\t\t\t<xr:Field>Catalog.{cat_name}.StandardAttribute.Code</xr:Field>
\t\t\t</InputByString>
\t\t\t<SearchStringModeOnInputByString>Begin</SearchStringModeOnInputByString>
\t\t\t<FullTextSearchOnInputByString>DontUse</FullTextSearchOnInputByString>
\t\t\t<ChoiceDataGetModeOnInputByString>Directly</ChoiceDataGetModeOnInputByString>
\t\t\t<DefaultObjectForm/>
\t\t\t<DefaultFolderForm/>
\t\t\t<DefaultListForm/>
\t\t\t<DefaultChoiceForm/>
\t\t\t<DefaultFolderChoiceForm/>
\t\t\t<AuxiliaryObjectForm/>
\t\t\t<AuxiliaryFolderForm/>
\t\t\t<AuxiliaryListForm/>
\t\t\t<AuxiliaryChoiceForm/>
\t\t\t<AuxiliaryFolderChoiceForm/>
\t\t\t<IncludeHelpInContents>false</IncludeHelpInContents>
\t\t\t<BasedOn/>
\t\t\t<DataLockFields/>
\t\t\t<DataLockControlMode>Managed</DataLockControlMode>
\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t<ObjectPresentation/>
\t\t\t<ExtendedObjectPresentation/>
\t\t\t<ListPresentation/>
\t\t\t<ExtendedListPresentation/>
\t\t\t<Explanation/>
\t\t\t<CreateOnInput>Use</CreateOnInput>
\t\t\t<ChoiceHistoryOnInput>Auto</ChoiceHistoryOnInput>
\t\t\t<DataHistory>DontUse</DataHistory>
\t\t\t<UpdateDataHistoryImmediatelyAfterWrite>false</UpdateDataHistoryImmediatelyAfterWrite>
\t\t\t<ExecuteAfterWriteDataHistoryVersionProcessing>false</ExecuteAfterWriteDataHistoryVersionProcessing>
\t\t</Properties>
\t\t<ChildObjects>
{attrs_xml}
\t\t</ChildObjects>
\t</Catalog>
</MetaDataObject>"""
    return xml

def build_enum_xml(enum_name, synonym, values):
    enum_id = uid()
    ref_type_id = uid()
    ref_val_id = uid()
    mgr_type_id = uid()
    mgr_val_id = uid()
    list_type_id = uid()
    list_val_id = uid()

    vals_xml = []
    for val_name, val_syn in values:
        v_id = uid()
        vals_xml.append(f"""\t\t\t<EnumValue uuid="{v_id}">
\t\t\t\t<Properties>
\t\t\t\t\t<Name>{val_name}</Name>
\t\t\t\t\t<Synonym>
\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t\t<v8:content>{val_syn}</v8:content>
\t\t\t\t\t\t</v8:item>
\t\t\t\t\t</Synonym>
\t\t\t\t\t<Comment/>
\t\t\t\t</Properties>
\t\t\t</EnumValue>""")

    child_objs = "\n".join(vals_xml)

    return f"""{XML_HEADER}
\t<Enum uuid="{enum_id}">
\t\t<InternalInfo>
\t\t\t<xr:GeneratedType name="EnumRef.{enum_name}" category="Ref">
\t\t\t\t<xr:TypeId>{ref_type_id}</xr:TypeId>
\t\t\t\t<xr:ValueId>{ref_val_id}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="EnumManager.{enum_name}" category="Manager">
\t\t\t\t<xr:TypeId>{mgr_type_id}</xr:TypeId>
\t\t\t\t<xr:ValueId>{mgr_val_id}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="EnumList.{enum_name}" category="List">
\t\t\t\t<xr:TypeId>{list_type_id}</xr:TypeId>
\t\t\t\t<xr:ValueId>{list_val_id}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t</InternalInfo>
\t\t<Properties>
\t\t\t<Name>{enum_name}</Name>
\t\t\t<Synonym>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t<v8:content>{synonym}</v8:content>
\t\t\t\t</v8:item>
\t\t\t</Synonym>
\t\t\t<Comment/>
\t\t\t<UseStandardCommands>false</UseStandardCommands>
\t\t\t<Characteristics/>
\t\t\t<QuickChoice>true</QuickChoice>
\t\t\t<ChoiceMode>BothWays</ChoiceMode>
\t\t\t<DefaultListForm/>
\t\t\t<DefaultChoiceForm/>
\t\t\t<AuxiliaryListForm/>
\t\t\t<AuxiliaryChoiceForm/>
\t\t\t<ListPresentation/>
\t\t\t<ExtendedListPresentation/>
\t\t\t<Explanation/>
\t\t\t<ChoiceHistoryOnInput>Auto</ChoiceHistoryOnInput>
\t\t</Properties>
\t\t<ChildObjects>
{child_objs}
\t\t</ChildObjects>
\t</Enum>
</MetaDataObject>"""

def main():
    catalogs_dir = "src/Catalogs"
    enums_dir = "src/Enums"
    os.makedirs(catalogs_dir, exist_ok=True)
    os.makedirs(enums_dir, exist_ok=True)

    # 1. Enum.LoaiDoiTac
    enum_xml = build_enum_xml(
        "LoaiDoiTac", 
        "Counterparty Type", 
        [
            ("KhachHang", "Khách hàng"),
            ("NhaCungCap", "Nhà cung cấp"),
            ("KhachHangVaNhaCungCap", "Khách hàng và Nhà cung cấp"),
            ("NoiBoTapDoan", "Nội bộ tập đoàn")
        ]
    )
    with open(os.path.join(enums_dir, "LoaiDoiTac.xml"), "w", encoding="utf-8") as f:
        f.write(enum_xml)
    print("Created Enum.LoaiDoiTac.xml")

    # 2. Catalogs definitions
    catalogs = [
        # 1. PhapNhan
        {
            "name": "PhapNhan",
            "synonym": "Pháp nhân (Entities)",
            "code_len": 9,
            "desc_len": 150,
            "attributes": [
                {"name": "MaSoThue", "synonym": "Mã số thuế", "type": "string", "length": 14},
                {"name": "DiaChi", "synonym": "Địa chỉ", "type": "string", "length": 200}
            ]
        },
        # 2. DoiTac
        {
            "name": "DoiTac",
            "synonym": "Đối tác (Counterparties)",
            "code_len": 9,
            "desc_len": 150,
            "attributes": [
                {"name": "LaBenLienKet", "synonym": "Là bên liên kết", "type": "boolean", "fill_value": False},
                {"name": "DaDangKyThueTrucTiep", "synonym": "Đã đăng ký thuế trực tiếp", "type": "boolean", "fill_value": False},
                {"name": "LoaiDoiTac", "synonym": "Loại đối tác", "type": "EnumRef.LoaiDoiTac"}
            ]
        },
        # 3. HopDong
        {
            "name": "HopDong",
            "synonym": "Hợp đồng (Contracts)",
            "code_len": 20,
            "desc_len": 150,
            "attributes": [
                {"name": "PhapNhan", "synonym": "Pháp nhân", "type": "CatalogRef.PhapNhan", "fill_checking": "ShowError"},
                {"name": "ChuSoHuu", "synonym": "Chủ sở hữu (Đối tác)", "type": "CatalogRef.DoiTac"},
                {"name": "GrossUpThue", "synonym": "Gross-up thuế", "type": "boolean", "fill_value": False},
                {"name": "HanThanhToanNgay", "synonym": "Hạn thanh toán (ngày)", "type": "number", "digits": 3, "fraction": 0, "fill_value": 30},
                {"name": "DongTienThanhToan", "synonym": "Đồng tiền thanh toán", "type": "CatalogRef.TienTe"}
            ]
        },
        # 4. TaiKhoanAo
        {
            "name": "TaiKhoanAo",
            "synonym": "Tài khoản ảo (Virtual Accounts)",
            "code_len": 9,
            "desc_len": 100,
            "attributes": [
                {"name": "SoTaiKhoanAo", "synonym": "Số tài khoản ảo", "type": "string", "length": 30, "indexing": "Index"},
                {"name": "DoiTac", "synonym": "Đối tác", "type": "CatalogRef.DoiTac"},
                {"name": "NganHang", "synonym": "Ngân hàng", "type": "CatalogRef.TaiKhoanTien"}
            ]
        },
        # 5. TaiKhoanTien
        {
            "name": "TaiKhoanTien",
            "synonym": "Tài khoản tiền (Cash Accounts)",
            "code_len": 9,
            "desc_len": 100,
            "attributes": [
                {"name": "SoTaiKhoan", "synonym": "Số tài khoản", "type": "string", "length": 30},
                {"name": "NganHang", "synonym": "Ngân hàng", "type": "string", "length": 100},
                {"name": "TienTe", "synonym": "Tiền tệ", "type": "CatalogRef.TienTe"}
            ]
        },
        # 6. KhoanMucDongTien
        {
            "name": "KhoanMucDongTien",
            "synonym": "Khoản mục dòng tiền (Cash Flow Items)",
            "code_len": 9,
            "desc_len": 100,
            "attributes": [
                {"name": "LoaiDongTien", "synonym": "Loại dòng tiền", "type": "string", "length": 50}
            ]
        },
        # 7. TienTe
        {
            "name": "TienTe",
            "synonym": "Tiền tệ (Currencies)",
            "code_len": 10,
            "desc_len": 50,
            "attributes": [
                {"name": "MaTienTe", "synonym": "Mã tiền tệ (ISO 4217)", "type": "string", "length": 3},
                {"name": "TenDayDu", "synonym": "Tên đầy đủ", "type": "string", "length": 50}
            ]
        },
        # 8. DuAn
        {
            "name": "DuAn",
            "synonym": "Dự án (Projects)",
            "code_len": 20,
            "desc_len": 150,
            "attributes": [
                {"name": "MaDuAn", "synonym": "Mã dự án", "type": "string", "length": 50},
                {"name": "TenDuAn", "synonym": "Tên dự án", "type": "string", "length": 150},
                {"name": "PhapNhan", "synonym": "Pháp nhân", "type": "CatalogRef.PhapNhan"}
            ]
        },
        # 9. DichVuCNTT
        {
            "name": "DichVuCNTT",
            "synonym": "Dịch vụ CNTT (IT Services)",
            "code_len": 20,
            "desc_len": 150,
            "attributes": [
                {"name": "MaDichVu", "synonym": "Mã dịch vụ", "type": "string", "length": 50},
                {"name": "TenDichVu", "synonym": "Tên dịch vụ", "type": "string", "length": 150},
                {"name": "TyLeVATMacDinh", "synonym": "Tỷ lệ VAT mặc định (%)", "type": "number", "digits": 2, "fraction": 0, "fill_value": 0}
            ]
        },
        # 10. KenhThanhToan
        {
            "name": "KenhThanhToan",
            "synonym": "Kênh thanh toán (Payment Channels)",
            "code_len": 20,
            "desc_len": 100,
            "attributes": [
                {"name": "MaKenh", "synonym": "Mã kênh", "type": "string", "length": 50},
                {"name": "TenKenh", "synonym": "Tên kênh", "type": "string", "length": 100}
            ]
        }
    ]

    for cat in catalogs:
        xml = build_catalog_xml(
            cat["name"],
            cat["synonym"],
            cat["code_len"],
            cat["desc_len"],
            cat["attributes"]
        )
        cat_file = os.path.join(catalogs_dir, f"{cat['name']}.xml")
        with open(cat_file, "w", encoding="utf-8") as f:
            f.write(xml)
        print(f"Created {cat_file}")

    # 3. ObjectModules
    # 3.1 HopDong
    hopdong_ext_dir = os.path.join(catalogs_dir, "HopDong", "Ext")
    os.makedirs(hopdong_ext_dir, exist_ok=True)
    hopdong_module = """Procedure BeforeWrite(Cancel)
\t// Rang buoc mac dinh Net 30: neu HanThanhToanNgay <= 0 thi tu gan = 30
\tIf HanThanhToanNgay <= 0 Then
\t\tHanThanhToanNgay = 30;
\tEndIf;
EndProcedure
"""
    with open(os.path.join(hopdong_ext_dir, "ObjectModule.bsl"), "w", encoding="utf-8") as f:
        f.write(hopdong_module)
    print("Created HopDong/Ext/ObjectModule.bsl")

    # 3.2 TaiKhoanAo
    taikhoanao_ext_dir = os.path.join(catalogs_dir, "TaiKhoanAo", "Ext")
    os.makedirs(taikhoanao_ext_dir, exist_ok=True)
    taikhoanao_module = """Procedure BeforeWrite(Cancel)
\t// Bat trung lap ma SoTaiKhoanAo (Unique constraint)
\tIf ValueIsFilled(SoTaiKhoanAo) Then
\t\tQuery = New Query;
\t\tQuery.Text = 
\t\t"SELECT TOP 1
\t\t|\tTaiKhoanAo.Ref AS Ref
\t\t|FROM
\t\t|\tCatalog.TaiKhoanAo AS TaiKhoanAo
\t\t|WHERE
\t\t|\tTaiKhoanAo.SoTaiKhoanAo = &SoTaiKhoanAo
\t\t|\tAND TaiKhoanAo.Ref <> &Ref";
\t\t
\t\tQuery.SetParameter("SoTaiKhoanAo", SoTaiKhoanAo);
\t\tQuery.SetParameter("Ref", Ref);
\t\t
\t\tQueryResult = Query.Execute();
\t\tIf Not QueryResult.IsEmpty() Then
\t\t\tCancel = True;
\t\t\tRaise "Số tài khoản ảo đã được cấp phát cho đối tác khác!";
\t\tEndIf;
\tEndIf;
EndProcedure
"""
    with open(os.path.join(taikhoanao_ext_dir, "ObjectModule.bsl"), "w", encoding="utf-8") as f:
        f.write(taikhoanao_module)
    print("Created TaiKhoanAo/Ext/ObjectModule.bsl")

    # 4. Update Configuration.xml
    child_objects_xml = """\t\t<ChildObjects>
\t\t\t<Language>English</Language>
\t\t\t<Catalog>PhapNhan</Catalog>
\t\t\t<Catalog>DoiTac</Catalog>
\t\t\t<Catalog>HopDong</Catalog>
\t\t\t<Catalog>TaiKhoanAo</Catalog>
\t\t\t<Catalog>TaiKhoanTien</Catalog>
\t\t\t<Catalog>KhoanMucDongTien</Catalog>
\t\t\t<Catalog>TienTe</Catalog>
\t\t\t<Catalog>DuAn</Catalog>
\t\t\t<Catalog>DichVuCNTT</Catalog>
\t\t\t<Catalog>KenhThanhToan</Catalog>
\t\t\t<Enum>LoaiDoiTac</Enum>
\t\t</ChildObjects>"""

    cfg_xml = f"""{XML_HEADER}
\t<Configuration uuid="097a612e-c834-4cc9-9bdb-b99f80e6356c">
\t\t<InternalInfo>
\t\t\t<xr:ContainedObject>
\t\t\t\t<xr:ClassId>9cd510cd-abfc-11d4-9434-004095e12fc7</xr:ClassId>
\t\t\t\t<xr:ObjectId>9b24fcb6-4fec-4419-9355-f2eecc4be68f</xr:ObjectId>
\t\t\t</xr:ContainedObject>
\t\t\t<xr:ContainedObject>
\t\t\t\t<xr:ClassId>9fcd25a0-4822-11d4-9414-008048da11f9</xr:ClassId>
\t\t\t\t<xr:ObjectId>6b378f08-77ed-4ef1-8aff-8a232ffe950d</xr:ObjectId>
\t\t\t</xr:ContainedObject>
\t\t\t<xr:ContainedObject>
\t\t\t\t<xr:ClassId>e3687481-0a87-462c-a166-9f34594f9bba</xr:ClassId>
\t\t\t\t<xr:ObjectId>387160b2-f329-43e8-b834-c5d6b79e0580</xr:ObjectId>
\t\t\t</xr:ContainedObject>
\t\t\t<xr:ContainedObject>
\t\t\t\t<xr:ClassId>9de14907-ec23-4a07-96f0-85521cb6b53b</xr:ClassId>
\t\t\t\t<xr:ObjectId>20faca19-9f43-4cad-a0f6-3ea146e2c5d9</xr:ObjectId>
\t\t\t</xr:ContainedObject>
\t\t\t<xr:ContainedObject>
\t\t\t\t<xr:ClassId>51f2d5d8-ea4d-4064-8892-82951750031e</xr:ClassId>
\t\t\t\t<xr:ObjectId>bdc4d6d2-b842-4da2-885e-0176d96b5493</xr:ObjectId>
\t\t\t</xr:ContainedObject>
\t\t\t<xr:ContainedObject>
\t\t\t\t<xr:ClassId>e68182ea-4237-4383-967f-90c1e3370bc7</xr:ClassId>
\t\t\t\t<xr:ObjectId>6083ef80-99c6-40a0-af40-f540fa80d57a</xr:ObjectId>
\t\t\t</xr:ContainedObject>
\t\t\t<xr:ContainedObject>
\t\t\t\t<xr:ClassId>fb282519-d103-4dd3-bc12-cb271d631dfc</xr:ClassId>
\t\t\t\t<xr:ObjectId>17e8183b-2015-4d4c-9274-3baff8ccc9f3</xr:ObjectId>
\t\t\t</xr:ContainedObject>
\t\t</InternalInfo>
\t\t<Properties>
\t\t\t<Name>Configuration</Name>
\t\t\t<Synonym/>
\t\t\t<Comment/>
\t\t\t<NamePrefix/>
\t\t\t<ConfigurationExtensionCompatibilityMode>Version8_3_22</ConfigurationExtensionCompatibilityMode>
\t\t\t<DefaultRunMode>ManagedApplication</DefaultRunMode>
\t\t\t<UsePurposes>
\t\t\t\t<v8:Value xsi:type="app:ApplicationUsePurpose">PlatformApplication</v8:Value>
\t\t\t</UsePurposes>
\t\t\t<ScriptVariant>English</ScriptVariant>
\t\t\t<DefaultRoles/>
\t\t\t<Vendor/>
\t\t\t<Version/>
\t\t\t<UpdateCatalogAddress/>
\t\t\t<IncludeHelpInContents>false</IncludeHelpInContents>
\t\t\t<UseManagedFormInOrdinaryApplication>false</UseManagedFormInOrdinaryApplication>
\t\t\t<UseOrdinaryFormInManagedApplication>false</UseOrdinaryFormInManagedApplication>
\t\t\t<AdditionalFullTextSearchDictionaries/>
\t\t\t<CommonSettingsStorage/>
\t\t\t<ReportsUserSettingsStorage/>
\t\t\t<ReportsVariantsStorage/>
\t\t\t<FormDataSettingsStorage/>
\t\t\t<DynamicListsUserSettingsStorage/>
\t\t\t<URLExternalDataStorage/>
\t\t\t<Content/>
\t\t\t<DefaultReportForm/>
\t\t\t<DefaultReportVariantForm/>
\t\t\t<DefaultReportSettingsForm/>
\t\t\t<DefaultReportAppearanceTemplate/>
\t\t\t<DefaultDynamicListSettingsForm/>
\t\t\t<DefaultSearchForm/>
\t\t\t<DefaultDataHistoryChangeHistoryForm/>
\t\t\t<DefaultDataHistoryVersionDataForm/>
\t\t\t<DefaultDataHistoryVersionDifferencesForm/>
\t\t\t<DefaultCollaborationSystemUsersChoiceForm/>
\t\t\t<RequiredMobileApplicationPermissions/>
\t\t\t<UsedMobileApplicationFunctionalities>
\t\t\t\t<app:functionality>
\t\t\t\t\t<app:functionality>Biometrics</app:functionality>
\t\t\t\t\t<app:use>true</app:use>
\t\t\t\t</app:functionality>
\t\t\t\t<app:functionality>
\t\t\t\t\t<app:functionality>OSBackup</app:functionality>
\t\t\t\t\t<app:use>true</app:use>
\t\t\t\t</app:functionality>
\t\t\t</UsedMobileApplicationFunctionalities>
\t\t\t<StandaloneConfigurationRestrictionRoles/>
\t\t\t<MobileApplicationURLs/>
\t\t\t<MainClientApplicationWindowMode>Normal</MainClientApplicationWindowMode>
\t\t\t<DefaultInterface/>
\t\t\t<DefaultStyle/>
\t\t\t<DefaultLanguage>Language.English</DefaultLanguage>
\t\t\t<BriefInformation/>
\t\t\t<DetailedInformation/>
\t\t\t<Copyright/>
\t\t\t<VendorInformationAddress/>
\t\t\t<ConfigurationInformationAddress/>
\t\t\t<DataLockControlMode>Managed</DataLockControlMode>
\t\t\t<ObjectAutonumerationMode>NotAutoFree</ObjectAutonumerationMode>
\t\t\t<ModalityUseMode>DontUse</ModalityUseMode>
\t\t\t<SynchronousPlatformExtensionAndAddInCallUseMode>DontUse</SynchronousPlatformExtensionAndAddInCallUseMode>
\t\t\t<InterfaceCompatibilityMode>Taxi</InterfaceCompatibilityMode>
\t\t\t<CompatibilityMode>Version8_3_22</CompatibilityMode>
\t\t\t<DefaultConstantsForm/>
\t\t</Properties>
{child_objects_xml}
\t</Configuration>
</MetaDataObject>"""

    with open("src/Configuration.xml", "w", encoding="utf-8") as f:
        f.write(cfg_xml)
    print("Updated src/Configuration.xml")

if __name__ == "__main__":
    main()
