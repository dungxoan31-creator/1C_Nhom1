import os
import uuid

def uid():
    return str(uuid.uuid4())

XML_HEADER = '<?xml version="1.0" encoding="UTF-8"?>\n<MetaDataObject xmlns="http://v8.1c.ru/8.3/MDClasses" xmlns:app="http://v8.1c.ru/8.2/managed-application/core" xmlns:cfg="http://v8.1c.ru/8.1/data/enterprise/current-config" xmlns:cmi="http://v8.1c.ru/8.2/managed-application/cmi" xmlns:ent="http://v8.1c.ru/8.1/data/enterprise" xmlns:lf="http://v8.1c.ru/8.2/managed-application/logform" xmlns:style="http://v8.1c.ru/8.1/data/ui/style" xmlns:sys="http://v8.1c.ru/8.1/data/ui/fonts/system" xmlns:v8="http://v8.1c.ru/8.1/data/core" xmlns:v8ui="http://v8.1c.ru/8.1/data/ui" xmlns:web="http://v8.1c.ru/8.1/data/ui/colors/web" xmlns:win="http://v8.1c.ru/8.1/data/ui/colors/windows" xmlns:xen="http://v8.1c.ru/8.3/xcf/enums" xmlns:xpr="http://v8.1c.ru/8.3/xcf/predef" xmlns:xr="http://v8.1c.ru/8.3/xcf/readable" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.15">'

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

def build_constant_xml(const_name, synonym, const_type, **kwargs):
    c_id = uid()
    mgr_type_id = uid()
    mgr_val_id = uid()
    vmgr_type_id = uid()
    vmgr_val_id = uid()
    vkey_type_id = uid()
    vkey_val_id = uid()

    if const_type == "string":
        length = kwargs.get("length", 50)
        type_xml = f"""\t\t\t<Type>
\t\t\t\t<v8:Type>xs:string</v8:Type>
\t\t\t\t<v8:StringQualifiers>
\t\t\t\t\t<v8:Length>{length}</v8:Length>
\t\t\t\t\t<v8:AllowedLength>Variable</v8:AllowedLength>
\t\t\t\t</v8:StringQualifiers>
\t\t\t</Type>"""
    elif const_type == "boolean":
        type_xml = """\t\t\t<Type>
\t\t\t\t<v8:Type>xs:boolean</v8:Type>
\t\t\t</Type>"""
    elif const_type == "number":
        digits = kwargs.get("digits", 15)
        fraction = kwargs.get("fraction", 0)
        type_xml = f"""\t\t\t<Type>
\t\t\t\t<v8:Type>xs:decimal</v8:Type>
\t\t\t\t<v8:NumberQualifiers>
\t\t\t\t\t<v8:Digits>{digits}</v8:Digits>
\t\t\t\t\t<v8:FractionDigits>{fraction}</v8:FractionDigits>
\t\t\t\t\t<v8:AllowedSign>Nonnegative</v8:AllowedSign>
\t\t\t\t</v8:NumberQualifiers>
\t\t\t</Type>"""
    else:
        raise ValueError(f"Unknown constant type: {const_type}")

    return f"""{XML_HEADER}
\t<Constant uuid="{c_id}">
\t\t<InternalInfo>
\t\t\t<xr:GeneratedType name="ConstantManager.{const_name}" category="Manager">
\t\t\t\t<xr:TypeId>{mgr_type_id}</xr:TypeId>
\t\t\t\t<xr:ValueId>{mgr_val_id}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="ConstantValueManager.{const_name}" category="ValueManager">
\t\t\t\t<xr:TypeId>{vmgr_type_id}</xr:TypeId>
\t\t\t\t<xr:ValueId>{vmgr_val_id}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="ConstantValueKey.{const_name}" category="ValueKey">
\t\t\t\t<xr:TypeId>{vkey_type_id}</xr:TypeId>
\t\t\t\t<xr:ValueId>{vkey_val_id}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t</InternalInfo>
\t\t<Properties>
\t\t\t<Name>{const_name}</Name>
\t\t\t<Synonym>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t<v8:content>{synonym}</v8:content>
\t\t\t\t</v8:item>
\t\t\t</Synonym>
\t\t\t<Comment/>
{type_xml}
\t\t\t<UseStandardCommands>true</UseStandardCommands>
\t\t\t<DefaultForm/>
\t\t\t<ExtendedPresentation/>
\t\t\t<Explanation/>
\t\t\t<PasswordMode>false</PasswordMode>
\t\t\t<Format/>
\t\t\t<EditFormat/>
\t\t\t<ToolTip/>
\t\t\t<MarkNegatives>false</MarkNegatives>
\t\t\t<Mask/>
\t\t\t<MultiLine>false</MultiLine>
\t\t\t<ExtendedEdit>false</ExtendedEdit>
\t\t\t<MinValue xsi:nil="true"/>
\t\t\t<MaxValue xsi:nil="true"/>
\t\t\t<FillChecking>DontCheck</FillChecking>
\t\t\t<ChoiceFoldersAndItems>Items</ChoiceFoldersAndItems>
\t\t\t<ChoiceParameterLinks/>
\t\t\t<ChoiceParameters/>
\t\t\t<QuickChoice>Auto</QuickChoice>
\t\t\t<ChoiceForm/>
\t\t\t<LinkByType/>
\t\t\t<ChoiceHistoryOnInput>Auto</ChoiceHistoryOnInput>
\t\t\t<DataLockControlMode>Managed</DataLockControlMode>
\t\t\t<DataHistory>DontUse</DataHistory>
\t\t\t<UpdateDataHistoryImmediatelyAfterWrite>false</UpdateDataHistoryImmediatelyAfterWrite>
\t\t\t<ExecuteAfterWriteDataHistoryVersionProcessing>false</ExecuteAfterWriteDataHistoryVersionProcessing>
\t\t</Properties>
\t</Constant>
</MetaDataObject>"""

def main():
    enums_dir = "src/Enums"
    constants_dir = "src/Constants"
    os.makedirs(enums_dir, exist_ok=True)
    os.makedirs(constants_dir, exist_ok=True)

    # 8 Enums
    enums = [
        # 1. TrangThaiNghiemThuAR
        (
            "TrangThaiNghiemThuAR",
            "AR Acceptance Status",
            [
                ("DuThao", "Dự thảo"),
                ("ChoDuyetNoiBo", "Chờ duyệt nội bộ"),
                ("DaDuyetNoiBo", "Đã duyệt nội bộ"),
                ("ChoDoiTacKy", "Chờ đối tác ký"),
                ("DaGhiSo", "Đã ghi sổ"),
                ("DaThanhToanMotPhan", "Đã thanh toán một phần"),
                ("DaTatToan", "Đã tất toán"),
                ("TranhChap", "Tranh chấp")
            ]
        ),
        # 2. TrangThaiHoaDonAP
        (
            "TrangThaiHoaDonAP",
            "AP Invoice Status",
            [
                ("DuThao", "Dự thảo"),
                ("ChoDuyetKyThuat", "Chờ duyệt kỹ thuật"),
                ("ChoDuyetPM", "Chờ duyệt PM"),
                ("ChoDuyetITDirector", "Chờ duyệt IT Director"),
                ("ChoDuyetCFO", "Chờ duyệt CFO"),
                ("ChoKeToanAP", "Chờ kế toán AP"),
                ("DaGhiSo", "Đã ghi sổ"),
                ("TuChoi", "Từ chối")
            ]
        ),
        # 3. TrangThaiLenhThanhToan
        (
            "TrangThaiLenhThanhToan",
            "Payment Order Status",
            [
                ("DuThao", "Dự thảo"),
                ("ChoDuyet", "Chờ duyệt"),
                ("DaDuyet", "Đã duyệt"),
                ("DaGuiNganHang", "Đã gửi ngân hàng"),
                ("DaGhiSo", "Đã ghi sổ"),
                ("TuChoi", "Từ chối"),
                ("HuyBo", "Hủy bỏ")
            ]
        ),
        # 4. TrangThaiCanTru
        (
            "TrangThaiCanTru",
            "Netting Status",
            [
                ("DuThao", "Dự thảo"),
                ("ChoDuyetNoiBo", "Chờ duyệt nội bộ"),
                ("ChoTapDoanDuyet", "Chờ tập đoàn duyệt"),
                ("ChoCanTru", "Chờ cấn trừ"),
                ("DaTatToan", "Đã tất toán"),
                ("HuyBo", "Hủy bỏ")
            ]
        ),
        # 5. TrangThaiHoaDonDienTu
        (
            "TrangThaiHoaDonDienTu",
            "e-Invoice Status",
            [
                ("DuThao", "Dự thảo"),
                ("ChoKySo", "Chờ ký số"),
                ("DaPhatHanh", "Đã phát hành"),
                ("DaDieuChinh", "Đã điều chỉnh"),
                ("DaThayThe", "Đã thay thế"),
                ("DaHuy", "Đã hủy")
            ]
        ),
        # 6. LoaiDoiTac
        (
            "LoaiDoiTac",
            "Counterparty Type",
            [
                ("KhachHangNgoai", "Khách hàng ngoài"),
                ("NoiBoVingroup", "Nội bộ Vingroup"),
                ("NhaCungCapCloud", "Nhà cung cấp Cloud"),
                ("NhaCungCapLinhKien", "Nhà cung cấp linh kiện"),
                ("ThauPhuCNTT", "Thầu phụ CNTT"),
                ("KhachHangVaNhaCungCap", "Khách hàng và Nhà cung cấp"),
                ("KhachHang", "Khách hàng"),
                ("NhaCungCap", "Nhà cung cấp"),
                ("NoiBoTapDoan", "Nội bộ tập đoàn")
            ]
        ),
        # 7. HuongDongTien
        (
            "HuongDongTien",
            "Cash Flow Direction",
            [
                ("Thu", "Thu"),
                ("Chi", "Chi")
            ]
        ),
        # 8. TrangThaiDongBo
        (
            "TrangThaiDongBo",
            "Sync Status",
            [
                ("ChuaDongBo", "Chưa đồng bộ"),
                ("ChoDongBo", "Chờ đồng bộ"),
                ("ThanhCong", "Thành công"),
                ("LoiDongBo", "Lỗi đồng bộ")
            ]
        )
    ]

    for name, syn, vals in enums:
        xml = build_enum_xml(name, syn, vals)
        filepath = os.path.join(enums_dir, f"{name}.xml")
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(xml)
        print(f"Created {filepath}")

    # 12 Constants
    constants = [
        # 1. PhapNhanMacDinh (String 50 = "VSF_CORP")
        {
            "name": "PhapNhanMacDinh",
            "synonym": "Default Legal Entity",
            "type": "string",
            "length": 50
        },
        # 2. NguongPheDuyetChiTienCFO (Number 15,0 = 500000000)
        {
            "name": "NguongPheDuyetChiTienCFO",
            "synonym": "CFO Payment Approval Threshold",
            "type": "number",
            "digits": 15,
            "fraction": 0
        },
        # 3. TaiKhoanTrungGianCanTru (String 20 = "1388")
        {
            "name": "TaiKhoanTrungGianCanTru",
            "synonym": "Netting Intermediate Account",
            "type": "string",
            "length": 20
        },
        # 4. TuDongDongBoSAP (Boolean = True)
        {
            "name": "TuDongDongBoSAP",
            "synonym": "Auto SAP Synchronization",
            "type": "boolean"
        },
        # 5. NguongThanhToanKhongDungTienMat (Number 15,0 = 5000000)
        {
            "name": "NguongThanhToanKhongDungTienMat",
            "synonym": "Non-Cash Payment Threshold",
            "type": "number",
            "digits": 15,
            "fraction": 0
        },
        # 6. TaiKhoanPhiNganHang (String 20 = "6427")
        {
            "name": "TaiKhoanPhiNganHang",
            "synonym": "Bank Fee Account",
            "type": "string",
            "length": 20
        },
        # 7. SoLuongHoaDonFIFOMax (Number 3,0 = 2)
        {
            "name": "SoLuongHoaDonFIFOMax",
            "synonym": "Max FIFO Invoice Count",
            "type": "number",
            "digits": 3,
            "fraction": 0
        },
        # 8. GiaTriFIFOMax (Number 15,0 = 100000000)
        {
            "name": "GiaTriFIFOMax",
            "synonym": "Max FIFO Value",
            "type": "number",
            "digits": 15,
            "fraction": 0
        },
        # 9. TimeoutChoCanTruPhut (Number 4,0 = 120)
        {
            "name": "TimeoutChoCanTruPhut",
            "synonym": "Netting Timeout (Minutes)",
            "type": "number",
            "digits": 4,
            "fraction": 0
        },
        # 10. CanhBaoCloudMucVang (Number 3,0 = 30)
        {
            "name": "CanhBaoCloudMucVang",
            "synonym": "Cloud Warning Yellow Level (Days)",
            "type": "number",
            "digits": 3,
            "fraction": 0
        },
        # 11. CanhBaoCloudMucCam (Number 3,0 = 14)
        {
            "name": "CanhBaoCloudMucCam",
            "synonym": "Cloud Warning Orange Level (Days)",
            "type": "number",
            "digits": 3,
            "fraction": 0
        },
        # 12. CanhBaoCloudMucDo (Number 3,0 = 7)
        {
            "name": "CanhBaoCloudMucDo",
            "synonym": "Cloud Warning Red Level (Days)",
            "type": "number",
            "digits": 3,
            "fraction": 0
        }
    ]

    for c in constants:
        xml = build_constant_xml(
            c["name"],
            c["synonym"],
            c["type"],
            digits=c.get("digits", 15),
            fraction=c.get("fraction", 0),
            length=c.get("length", 50)
        )
        filepath = os.path.join(constants_dir, f"{c['name']}.xml")
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(xml)
        print(f"Created {filepath}")

    # Update Configuration.xml safely
    cfg_file = "src/Configuration.xml"
    with open(cfg_file, "r", encoding="utf-8") as f:
        content = f.read()

    enum_names = [e[0] for e in enums]
    constant_names = [c["name"] for c in constants]

    new_entries = []
    for ename in enum_names:
        tag = f"<Enum>{ename}</Enum>"
        if tag not in content:
            new_entries.append(f"\t\t\t{tag}")

    for cname in constant_names:
        tag = f"<Constant>{cname}</Constant>"
        if tag not in content:
            new_entries.append(f"\t\t\t{tag}")

    if new_entries:
        insert_block = "\n".join(new_entries) + "\n"
        content = content.replace("\t\t</ChildObjects>", insert_block + "\t\t</ChildObjects>")
        with open(cfg_file, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"Updated {cfg_file} with {len(new_entries)} new objects")
    else:
        print("All objects already registered in Configuration.xml")

if __name__ == "__main__":
    main()
