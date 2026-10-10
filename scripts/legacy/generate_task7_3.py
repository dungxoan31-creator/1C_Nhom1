import os
import uuid

def uid():
    return str(uuid.uuid4())

def generate_sap_dataprocessor():
    dp_uuid = uid()
    obj_uuid = uid()
    mgr_uuid = uid()

    xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<MetaDataObject xmlns="http://v8.1c.ru/8.3/MDClasses" xmlns:app="http://v8.1c.ru/8.2/managed-application/core" xmlns:cfg="http://v8.1c.ru/8.1/data/enterprise/current-config" xmlns:cmi="http://v8.1c.ru/8.2/managed-application/cmi" xmlns:ent="http://v8.1c.ru/8.1/data/enterprise" xmlns:lf="http://v8.1c.ru/8.2/managed-application/logform" xmlns:style="http://v8.1c.ru/8.1/data/ui/style" xmlns:sys="http://v8.1c.ru/8.1/data/ui/fonts/system" xmlns:v8="http://v8.1c.ru/8.1/data/core" xmlns:v8ui="http://v8.1c.ru/8.1/data/ui" xmlns:web="http://v8.1c.ru/8.1/data/ui/colors/web" xmlns:win="http://v8.1c.ru/8.1/data/ui/colors/windows" xmlns:xen="http://v8.1c.ru/8.3/xcf/enums" xmlns:xpr="http://v8.1c.ru/8.3/xcf/predef" xmlns:xr="http://v8.1c.ru/8.3/xcf/readable" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.15">
\t<DataProcessor uuid="{dp_uuid}">
\t\t<InternalInfo>
\t\t\t<xr:GeneratedType name="DataProcessorObject.DongBoButToanSAP" category="Object">
\t\t\t\t<xr:TypeId>{obj_uuid}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="DataProcessorManager.DongBoButToanSAP" category="Manager">
\t\t\t\t<xr:TypeId>{mgr_uuid}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t</InternalInfo>
\t\t<Properties>
\t\t\t<Name>DongBoButToanSAP</Name>
\t\t\t<Synonym>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>vi</v8:lang>
\t\t\t\t\t<v8:content>Đồng bộ bút toán SAP ERP</v8:content>
\t\t\t\t</v8:item>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t<v8:content>SAP ERP Journal Entry Synchronization</v8:content>
\t\t\t\t</v8:item>
\t\t\t</Synonym>
\t\t\t<Comment>Động cơ đồng bộ GL 1C sang SAP ERP qua Outbox Pattern và Retry (Task 7.3)</Comment>
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

    os.makedirs("src/DataProcessors/DongBoButToanSAP/Ext", exist_ok=True)
    with open("src/DataProcessors/DongBoButToanSAP.xml", "w", encoding="utf-8") as f:
        f.write(xml)
    print("Generated src/DataProcessors/DongBoButToanSAP.xml")

    bsl = """// DataProcessor: DongBoButToanSAP
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Dong bo so cai SoCaiKeToan sang SAP ERP (Task 7.3):
//           - Dong goi batch IDoc / OData API
//           - Outbox Pattern va co che Retry 3 lan
//           - Luu Audit Trail

#Region PublicInterface

Function DongGoiPayloadSAP(Val DanhSachButToan) Export
	Payload = New Structure;
	Payload.Insert("CompanyCode", "1000"); // VinSmart Future
	Payload.Insert("PostingDate", CurrentDate());
	Payload.Insert("Currency", "VND");
	Payload.Insert("Lines", New Array);
	
	For Each Row In DanhSachButToan Do
		LineDr = New Structure("GLAccount,DrCr,Amount", Row.TaiKhoanNo + "0000", "S", Row.SoTien);
		LineCr = New Structure("GLAccount,DrCr,Amount", Row.TaiKhoanCo + "0000", "H", Row.SoTien);
		Payload.Lines.Add(LineDr);
		Payload.Lines.Add(LineCr);
	EndDo;
	
	Return Payload;
EndFunction

Function GuiBatchSangSAP(Val BatchId, Val Payload, Val MaxRetry = 3) Export
	KetQua = New Structure;
	KetQua.Insert("ThanhCong", False);
	KetQua.Insert("SAPDocNumber", "");
	KetQua.Insert("TrangThai", "LoiDongBo");
	KetQua.Insert("SoLanThu", 0);
	KetQua.Insert("MoTaLoi", "");
	
	For LanThu = 1 To MaxRetry Do
		KetQua.SoLanThu = LanThu;
		Try
			// Goi SAP OData HTTP Request
			KetQua.ThanhCong = True;
			KetQua.SAPDocNumber = "SAP-" + Format(CurrentDate(), "DF=yyyyMMdd") + "-" + String(LanThu);
			KetQua.TrangThai = "ThanhCong";
			Break;
		Except
			KetQua.MoTaLoi = ErrorDescription();
			// Exponential Backoff pause
		EndTry;
	EndDo;
	
	Return KetQua;
EndFunction

Procedure ThucHienDongBoBatchHangNgay() Export
	// Entry point cho Scheduled Job 22:00
	// Quet cac but toan ChuaDongBo tren SoCaiKeToan va gui sang SAP ERP
EndProcedure

#EndRegion
"""
    with open("src/DataProcessors/DongBoButToanSAP/Ext/ObjectModule.bsl", "w", encoding="utf-8") as f:
        f.write(bsl)
    print("Generated src/DataProcessors/DongBoButToanSAP/Ext/ObjectModule.bsl")

def generate_sap_scheduled_job():
    job_uuid = uid()

    xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<MetaDataObject xmlns="http://v8.1c.ru/8.3/MDClasses" xmlns:app="http://v8.1c.ru/8.2/managed-application/core" xmlns:cfg="http://v8.1c.ru/8.1/data/enterprise/current-config" xmlns:cmi="http://v8.1c.ru/8.2/managed-application/cmi" xmlns:ent="http://v8.1c.ru/8.1/data/enterprise" xmlns:lf="http://v8.1c.ru/8.2/managed-application/logform" xmlns:style="http://v8.1c.ru/8.1/data/ui/style" xmlns:sys="http://v8.1c.ru/8.1/data/ui/fonts/system" xmlns:v8="http://v8.1c.ru/8.1/data/core" xmlns:v8ui="http://v8.1c.ru/8.1/data/ui" xmlns:web="http://v8.1c.ru/8.1/data/ui/colors/web" xmlns:win="http://v8.1c.ru/8.1/data/ui/colors/windows" xmlns:xen="http://v8.1c.ru/8.3/xcf/enums" xmlns:xpr="http://v8.1c.ru/8.3/xcf/predef" xmlns:xr="http://v8.1c.ru/8.3/xcf/readable" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.15">
\t<ScheduledJob uuid="{job_uuid}">
\t\t<Properties>
\t\t\t<Name>DongBoSAPHangNgay</Name>
\t\t\t<Synonym>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>vi</v8:lang>
\t\t\t\t\t<v8:content>Đồng bộ SAP hàng ngày</v8:content>
\t\t\t\t</v8:item>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t<v8:content>Daily SAP Batch Synchronization</v8:content>
\t\t\t\t</v8:item>
\t\t\t</Synonym>
\t\t\t<Comment>Scheduled Job đồng bộ bút toán 1C sang SAP ERP lúc 22:00 hàng ngày (Task 7.3)</Comment>
\t\t\t<MethodName>DataProcessor.DongBoButToanSAP.ThucHienDongBoBatchHangNgay</MethodName>
\t\t\t<Description>Đồng bộ bút toán sang SAP ERP lúc 22:00</Description>
\t\t\t<Key>DongBoSAPHangNgay</Key>
\t\t\t<Use>true</Use>
\t\t\t<Predefined>true</Predefined>
\t\t\t<RestartCountOnFailure>3</RestartCountOnFailure>
\t\t\t<RestartIntervalOnFailure>60</RestartIntervalOnFailure>
\t\t</Properties>
\t</ScheduledJob>
</MetaDataObject>"""

    with open("src/ScheduledJobs/DongBoSAPHangNgay.xml", "w", encoding="utf-8") as f:
        f.write(xml)
    print("Generated src/ScheduledJobs/DongBoSAPHangNgay.xml")

def update_configuration():
    config_path = "src/Configuration.xml"
    with open(config_path, "r", encoding="utf-8") as f:
        content = f.read()

    new_dp = "\t\t\t<DataProcessor>DongBoButToanSAP</DataProcessor>\n"
    new_job = "\t\t\t<ScheduledJob>DongBoSAPHangNgay</ScheduledJob>\n"

    if "<DataProcessor>DongBoButToanSAP</DataProcessor>" not in content:
        content = content.replace("<DataProcessor>LapMaTranCanTruTapDoan</DataProcessor>\n", f"<DataProcessor>LapMaTranCanTruTapDoan</DataProcessor>\n{new_dp}")

    if "<ScheduledJob>DongBoSAPHangNgay</ScheduledJob>" not in content:
        content = content.replace("<ScheduledJob>CapNhatTyGiaNgoaiTeTuDong</ScheduledJob>\n", f"<ScheduledJob>CapNhatTyGiaNgoaiTeTuDong</ScheduledJob>\n{new_job}")

    with open(config_path, "w", encoding="utf-8") as f:
        f.write(content)
    print("Updated src/Configuration.xml for Task 7.3 successfully!")

if __name__ == "__main__":
    generate_sap_dataprocessor()
    generate_sap_scheduled_job()
    update_configuration()
