import os
import uuid

def uid():
    return str(uuid.uuid4())

def generate_report_xml(name, syn_vi, syn_en, comment):
    rep_uuid = uid()
    obj_uuid = uid()
    mgr_uuid = uid()

    return f"""<?xml version="1.0" encoding="UTF-8"?>
<MetaDataObject xmlns="http://v8.1c.ru/8.3/MDClasses" xmlns:app="http://v8.1c.ru/8.2/managed-application/core" xmlns:cfg="http://v8.1c.ru/8.1/data/enterprise/current-config" xmlns:cmi="http://v8.1c.ru/8.2/managed-application/cmi" xmlns:ent="http://v8.1c.ru/8.1/data/enterprise" xmlns:lf="http://v8.1c.ru/8.2/managed-application/logform" xmlns:style="http://v8.1c.ru/8.1/data/ui/style" xmlns:sys="http://v8.1c.ru/8.1/data/ui/fonts/system" xmlns:v8="http://v8.1c.ru/8.1/data/core" xmlns:v8ui="http://v8.1c.ru/8.1/data/ui" xmlns:web="http://v8.1c.ru/8.1/data/ui/colors/web" xmlns:win="http://v8.1c.ru/8.1/data/ui/colors/windows" xmlns:xen="http://v8.1c.ru/8.3/xcf/enums" xmlns:xpr="http://v8.1c.ru/8.3/xcf/predef" xmlns:xr="http://v8.1c.ru/8.3/xcf/readable" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.15">
\t<Report uuid="{rep_uuid}">
\t\t<InternalInfo>
\t\t\t<xr:GeneratedType name="ReportObject.{name}" category="Object">
\t\t\t\t<xr:TypeId>{obj_uuid}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="ReportManager.{name}" category="Manager">
\t\t\t\t<xr:TypeId>{mgr_uuid}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t</InternalInfo>
\t\t<Properties>
\t\t\t<Name>{name}</Name>
\t\t\t<Synonym>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>vi</v8:lang>
\t\t\t\t\t<v8:content>{syn_vi}</v8:content>
\t\t\t\t</v8:item>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t<v8:content>{syn_en}</v8:content>
\t\t\t\t</v8:item>
\t\t\t</Synonym>
\t\t\t<Comment>{comment}</Comment>
\t\t\t<UseStandardCommands>true</UseStandardCommands>
\t\t\t<DefaultForm/>
\t\t\t<AuxiliaryForm/>
\t\t\t<MainDataCompositionSchema/>
\t\t\t<DefaultSettingsForm/>
\t\t\t<AuxiliarySettingsForm/>
\t\t\t<DefaultVariantForm/>
\t\t\t<VariantsStorage/>
\t\t\t<SettingsStorage/>
\t\t\t<IncludeHelpInContents>false</IncludeHelpInContents>
\t\t\t<ExtendedPresentation/>
\t\t\t<Explanation/>
\t\t</Properties>
\t\t<ChildObjects/>
\t</Report>
</MetaDataObject>"""

def generate_reports():
    # 1. MaTranCanTruNoiBoTapDoan
    xml1 = generate_report_xml(
        "MaTranCanTruNoiBoTapDoan",
        "Ma trận cấn trừ nội bộ tập đoàn",
        "Intercompany Netting Matrix Report",
        "Báo cáo trực quan hóa ma trận cấn trừ đa bên Tập đoàn Vingroup (Task 6.3)"
    )
    os.makedirs("src/Reports/MaTranCanTruNoiBoTapDoan/Ext", exist_ok=True)
    with open("src/Reports/MaTranCanTruNoiBoTapDoan.xml", "w", encoding="utf-8") as f:
        f.write(xml1)
    bsl1 = """// Report: MaTranCanTruNoiBoTapDoan
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Truc quan hoa ma tran bu tru cong no noi bo da ben (Task 6.3)

#Region PublicInterface

Function TinhMaTranBuTru(DanhSachDoiTac, DanhSachAR, DanhSachAP) Export
	KetQua = New Structure;
	KetQua.Insert("TongCanTru", 0);
	KetQua.Insert("ChiTietCanTru", New Array);
	
	// Tinh tong can tru can bang giua cac don vi
	TongAR = 0;
	TongAP = 0;
	For Each Item In DanhSachAR Do
		TongAR = TongAR + Item.SoTien;
	EndDo;
	For Each Item In DanhSachAP Do
		TongAP = TongAP + Item.SoTien;
	EndDo;
	
	KetQua.TongCanTru = Min(TongAR, TongAP);
	Return KetQua;
EndFunction

#EndRegion
"""
    with open("src/Reports/MaTranCanTruNoiBoTapDoan/Ext/ObjectModule.bsl", "w", encoding="utf-8") as f:
        f.write(bsl1)
    print("Generated Report 1: MaTranCanTruNoiBoTapDoan")

    # 2. DoiSoatKenhThanhToanVaDongTienAo
    xml2 = generate_report_xml(
        "DoiSoatKenhThanhToanVaDongTienAo",
        "Đối soát kênh thanh toán và dòng tiền ảo",
        "Payment Gateway and Virtual Account Reconciliation Report",
        "Đối chiếu dòng tiền cổng thanh toán, tài khoản ảo và hóa đơn AR (Task 6.3)"
    )
    os.makedirs("src/Reports/DoiSoatKenhThanhToanVaDongTienAo/Ext", exist_ok=True)
    with open("src/Reports/DoiSoatKenhThanhToanVaDongTienAo.xml", "w", encoding="utf-8") as f:
        f.write(xml2)
    bsl2 = """// Report: DoiSoatKenhThanhToanVaDongTienAo
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Doi chieu dong tien cong thanh toan, VA va phi kenh (Task 6.3)

#Region PublicInterface

Function DoiSoatDongTien(Val TongGross, Val PhiKenh) Export
	KetQua = New Structure;
	KetQua.Insert("TongGross", TongGross);
	KetQua.Insert("PhiKenh", PhiKenh);
	KetQua.Insert("ThucNhanNet", TongGross - PhiKenh);
	KetQua.Insert("CanDoi", (TongGross = (TongGross - PhiKenh) + PhiKenh));
	Return KetQua;
EndFunction

#EndRegion
"""
    with open("src/Reports/DoiSoatKenhThanhToanVaDongTienAo/Ext/ObjectModule.bsl", "w", encoding="utf-8") as f:
        f.write(bsl2)
    print("Generated Report 2: DoiSoatKenhThanhToanVaDongTienAo")

    # 3. CanhBaoHanMucVaGiaHanCloud
    xml3 = generate_report_xml(
        "CanhBaoHanMucVaGiaHanCloud",
        "Cảnh báo hạn mức và gia hạn Cloud",
        "Cloud Quota and Renewal Warning Report",
        "Cảnh báo thời hạn gói Cloud và hạn mức sử dụng theo 3 cấp độ (Task 6.3)"
    )
    os.makedirs("src/Reports/CanhBaoHanMucVaGiaHanCloud/Ext", exist_ok=True)
    with open("src/Reports/CanhBaoHanMucVaGiaHanCloud.xml", "w", encoding="utf-8") as f:
        f.write(xml3)
    bsl3 = """// Report: CanhBaoHanMucVaGiaHanCloud
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Canh bao han muc va thoi han goi Cloud theo 3 cap Vang, Cam, Do (Task 6.3)

#Region PublicInterface

Function XacDinhMucCanhBaoThoiHan(Val SoNgayConLai) Export
	If SoNgayConLai <= 7 Then
		Return "Do";
	ElsIf SoNgayConLai <= 14 Then
		Return "Cam";
	ElsIf SoNgayConLai <= 30 Then
		Return "Vang";
	Else
		Return "BinhThuong";
	EndIf;
EndFunction

Function XacDinhMucCanhBaoQuota(Val PhanTramSuDung) Export
	If PhanTramSuDung >= 98 Then
		Return "Do";
	ElsIf PhanTramSuDung >= 90 Then
		Return "Cam";
	ElsIf PhanTramSuDung >= 80 Then
		Return "Vang";
	Else
		Return "BinhThuong";
	EndIf;
EndFunction

#EndRegion
"""
    with open("src/Reports/CanhBaoHanMucVaGiaHanCloud/Ext/ObjectModule.bsl", "w", encoding="utf-8") as f:
        f.write(bsl3)
    print("Generated Report 3: CanhBaoHanMucVaGiaHanCloud")

def update_configuration():
    config_path = "src/Configuration.xml"
    with open(config_path, "r", encoding="utf-8") as f:
        content = f.read()

    new_reps = (
        "\t\t\t<Report>MaTranCanTruNoiBoTapDoan</Report>\n"
        "\t\t\t<Report>DoiSoatKenhThanhToanVaDongTienAo</Report>\n"
        "\t\t\t<Report>CanhBaoHanMucVaGiaHanCloud</Report>\n"
    )

    if "<Report>MaTranCanTruNoiBoTapDoan</Report>" not in content:
        content = content.replace("<Report>BaoCaoTuoiNoPhanTachNoiBo</Report>\n", f"<Report>BaoCaoTuoiNoPhanTachNoiBo</Report>\n{new_reps}")

    with open(config_path, "w", encoding="utf-8") as f:
        f.write(content)
    print("Updated src/Configuration.xml for Task 6.3 successfully!")

if __name__ == "__main__":
    generate_reports()
    update_configuration()
