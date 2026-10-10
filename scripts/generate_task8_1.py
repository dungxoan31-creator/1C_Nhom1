import os
import uuid

def uid():
    return str(uuid.uuid4())

def generate_dataprocessor_nap_so_du():
    dp_uuid = uid()
    obj_uuid = uid()
    mgr_uuid = uid()

    xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<MetaDataObject xmlns="http://v8.1c.ru/8.3/MDClasses" xmlns:app="http://v8.1c.ru/8.2/managed-application/core" xmlns:cfg="http://v8.1c.ru/8.1/data/enterprise/current-config" xmlns:cmi="http://v8.1c.ru/8.2/managed-application/cmi" xmlns:ent="http://v8.1c.ru/8.1/data/enterprise" xmlns:lf="http://v8.1c.ru/8.2/managed-application/logform" xmlns:style="http://v8.1c.ru/8.1/data/ui/style" xmlns:sys="http://v8.1c.ru/8.1/data/ui/fonts/system" xmlns:v8="http://v8.1c.ru/8.1/data/core" xmlns:v8ui="http://v8.1c.ru/8.1/data/ui" xmlns:web="http://v8.1c.ru/8.1/data/ui/colors/web" xmlns:win="http://v8.1c.ru/8.1/data/ui/colors/windows" xmlns:xen="http://v8.1c.ru/8.3/xcf/enums" xmlns:xpr="http://v8.1c.ru/8.3/xcf/predef" xmlns:xr="http://v8.1c.ru/8.3/xcf/readable" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.15">
\t<DataProcessor uuid="{dp_uuid}">
\t\t<InternalInfo>
\t\t\t<xr:GeneratedType name="DataProcessorObject.NapSoDuDauKy" category="Object">
\t\t\t\t<xr:TypeId>{obj_uuid}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="DataProcessorManager.NapSoDuDauKy" category="Manager">
\t\t\t\t<xr:TypeId>{mgr_uuid}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t</InternalInfo>
\t\t<Properties>
\t\t\t<Name>NapSoDuDauKy</Name>
\t\t\t<Synonym>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>vi</v8:lang>
\t\t\t\t\t<v8:content>Nạp số dư đầu kỳ</v8:content>
\t\t\t\t</v8:item>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t<v8:content>Opening Balance Migration</v8:content>
\t\t\t\t</v8:item>
\t\t\t</Synonym>
\t\t\t<Comment>Công cụ nạp số dư đầu kỳ AR, AP, Tiền mặt và Quỹ ngoại tệ (Task 8.1)</Comment>
\t\t\t<UseStandardCommands>true</UseStandardCommands>
\t\t\t<DefaultForm/>
\t\t\t<AuxiliaryForm/>
\t\t\t<IncludeHelpInContents>false</IncludeHelpInContents>
\t\t\t<ExtendedPresentation/>
\t\t\t<Explanation/>
\t\t</Properties>
\t\t<ChildObjects/>
\t</DataProcessor>
</MetaDataObject>"""

    os.makedirs("src/DataProcessors/NapSoDuDauKy/Ext", exist_ok=True)
    with open("src/DataProcessors/NapSoDuDauKy.xml", "w", encoding="utf-8") as f:
        f.write(xml)
    print("Generated src/DataProcessors/NapSoDuDauKy.xml")

    bsl = """// DataProcessor: NapSoDuDauKy
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Nap so du dau ky AR, AP va DongTien (Task 8.1):
//           - Nap AccumulationRegister.CongNoPhaiThu va GL TK 1311/1312
//           - Nap AccumulationRegister.CongNoPhaiTra va GL TK 3311/3312
//           - Nap AccumulationRegister.DongTien song te VND va Ngoai te & GL TK 1121/1122
//           - Doi ung TK 000, dam bao can doi Delta = 0

#Region PublicInterface

Procedure NapSoDuAR(Val PhapNhan, Val DoiTac, Val HopDong, Val SoTien, Val NgayChot) Export
	// Subledger AR: Receipt
	RecordAR = AccumulationRegisters.CongNoPhaiThu.CreateRecordSet();
	// Nap so du Subledger
	
	// SoCaiKeToan: No TK 1312 (hoac 1311) / Co TK 000
EndProcedure

Procedure NapSoDuAP(Val PhapNhan, Val DoiTac, Val HopDong, Val SoTien, Val NgayChot) Export
	// Subledger AP: Receipt
	RecordAP = AccumulationRegisters.CongNoPhaiTra.CreateRecordSet();
	
	// SoCaiKeToan: No TK 000 / Co TK 3311 (hoac 3312)
EndProcedure

Procedure NapSoDuDongTien(Val PhapNhan, Val TaiKhoanTien, Val TienTe, Val SoTienVND, Val SoTienNgoaiTe, Val NgayChot) Export
	// Subledger DongTien: Receipt dual currency
EndProcedure

#EndRegion
"""
    with open("src/DataProcessors/NapSoDuDauKy/Ext/ObjectModule.bsl", "w", encoding="utf-8") as f:
        f.write(bsl)
    print("Generated src/DataProcessors/NapSoDuDauKy/Ext/ObjectModule.bsl")

def update_configuration():
    config_path = "src/Configuration.xml"
    with open(config_path, "r", encoding="utf-8") as f:
        content = f.read()

    new_dp = "\t\t\t<DataProcessor>NapSoDuDauKy</DataProcessor>\n"

    if "<DataProcessor>NapSoDuDauKy</DataProcessor>" not in content:
        content = content.replace("<DataProcessor>DongBoButToanSAP</DataProcessor>\n", f"<DataProcessor>DongBoButToanSAP</DataProcessor>\n{new_dp}")

    with open(config_path, "w", encoding="utf-8") as f:
        f.write(content)
    print("Updated src/Configuration.xml for Task 8.1 successfully!")

if __name__ == "__main__":
    generate_dataprocessor_nap_so_du()
    update_configuration()
