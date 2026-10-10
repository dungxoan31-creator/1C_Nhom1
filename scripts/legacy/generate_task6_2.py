import os
import uuid

def uid():
    return str(uuid.uuid4())

def generate_report_tuoi_no():
    rep_uuid = uid()
    obj_uuid = uid()
    mgr_uuid = uid()

    xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<MetaDataObject xmlns="http://v8.1c.ru/8.3/MDClasses" xmlns:app="http://v8.1c.ru/8.2/managed-application/core" xmlns:cfg="http://v8.1c.ru/8.1/data/enterprise/current-config" xmlns:cmi="http://v8.1c.ru/8.2/managed-application/cmi" xmlns:ent="http://v8.1c.ru/8.1/data/enterprise" xmlns:lf="http://v8.1c.ru/8.2/managed-application/logform" xmlns:style="http://v8.1c.ru/8.1/data/ui/style" xmlns:sys="http://v8.1c.ru/8.1/data/ui/fonts/system" xmlns:v8="http://v8.1c.ru/8.1/data/core" xmlns:v8ui="http://v8.1c.ru/8.1/data/ui" xmlns:web="http://v8.1c.ru/8.1/data/ui/colors/web" xmlns:win="http://v8.1c.ru/8.1/data/ui/colors/windows" xmlns:xen="http://v8.1c.ru/8.3/xcf/enums" xmlns:xpr="http://v8.1c.ru/8.3/xcf/predef" xmlns:xr="http://v8.1c.ru/8.3/xcf/readable" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.15">
\t<Report uuid="{rep_uuid}">
\t\t<InternalInfo>
\t\t\t<xr:GeneratedType name="ReportObject.BaoCaoTuoiNoPhanTachNoiBo" category="Object">
\t\t\t\t<xr:TypeId>{obj_uuid}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="ReportManager.BaoCaoTuoiNoPhanTachNoiBo" category="Manager">
\t\t\t\t<xr:TypeId>{mgr_uuid}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t</InternalInfo>
\t\t<Properties>
\t\t\t<Name>BaoCaoTuoiNoPhanTachNoiBo</Name>
\t\t\t<Synonym>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>vi</v8:lang>
\t\t\t\t\t<v8:content>Báo cáo tuổi nợ phân tách nội bộ</v8:content>
\t\t\t\t</v8:item>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t<v8:content>Aging Report with Intercompany Segregation</v8:content>
\t\t\t\t</v8:item>
\t\t\t</Synonym>
\t\t\t<Comment>Báo cáo phân tích tuổi nợ và Operational Safety Gate (Task 6.2)</Comment>
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

    os.makedirs("src/Reports/BaoCaoTuoiNoPhanTachNoiBo/Ext", exist_ok=True)
    with open("src/Reports/BaoCaoTuoiNoPhanTachNoiBo.xml", "w", encoding="utf-8") as f:
        f.write(xml)
    print("Generated src/Reports/BaoCaoTuoiNoPhanTachNoiBo.xml")

    # ObjectModule for Report
    bsl = """// Report: BaoCaoTuoiNoPhanTachNoiBo
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Phan tich tuoi no AR/AP va ap dung Operational Safety Gate (Task 6.2):
//           - Tinh toan tuoi no theo DueDate: TrongHan, 1-30, 31-60, >60 ngay
//           - Operational Safety Gate: Khach ngoai qua han > 60 ngay -> DeXuatKhoaDichVu
//           - Doi tac noi bo Vingroup qua han: CAM TUYET DOI tu dong ngat API/Cloud, chuyen sang CanhBaoCFOVaNetting

#Region PublicInterface

// Ham xac dinh nhom tuoi no theo so ngay qua han
Function LayNhomTuoiNo(Val SoNgayQuaHan) Export
	If SoNgayQuaHan <= 0 Then
		Return "TrongHan";
	ElsIf SoNgayQuaHan <= 30 Then
		Return "QuaHan1_30";
	ElsIf SoNgayQuaHan <= 60 Then
		Return "QuaHan31_60";
	Else
		Return "QuaHanTren60";
	EndIf;
EndFunction

// Xu ly kiem tra Operational Safety Gate
Function KiemTraOperationalSafetyGate(Val LaBenLienKet, Val SoNgayQuaHan) Export
	KetQua = New Structure;
	KetQua.Insert("DeXuatKhoaDichVu", False);
	KetQua.Insert("CamKhoaDichVu", False);
	KetQua.Insert("TrangThaiXuLy", "BinhThuong");
	
	If LaBenLienKet Then
		// OPERATIONAL SAFETY GATE: Cam tuyet doi tu dong khoa dich vu doi tac noi bo Vingroup
		KetQua.CamKhoaDichVu = True;
		KetQua.DeXuatKhoaDichVu = False;
		If SoNgayQuaHan > 60 Then
			KetQua.TrangThaiXuLy = "CanhBaoCFOVaNetting";
		ElsIf SoNgayQuaHan > 0 Then
			KetQua.TrangThaiXuLy = "DoiChieuNoiBo";
		EndIf;
	Else
		// Khach hang ngoai tap doan
		If SoNgayQuaHan > 60 Then
			KetQua.DeXuatKhoaDichVu = True;
			KetQua.TrangThaiXuLy = "KhoaDichVuAPI";
		ElsIf SoNgayQuaHan > 30 Then
			KetQua.TrangThaiXuLy = "NhacNo";
		ElsIf SoNgayQuaHan > 0 Then
			KetQua.TrangThaiXuLy = "CanhBaoSom";
		EndIf;
	EndIf;
	
	Return KetQua;
EndFunction

// Phan tich va tinh tong du no theo tung bucket
Function PhanTichTuoiNoDanhSach(DanhSachKhoanNo) Export
	KetQua = New Structure;
	KetQua.Insert("TongTrongHan", 0);
	KetQua.Insert("TongQuaHan1_30", 0);
	KetQua.Insert("TongQuaHan31_60", 0);
	KetQua.Insert("TongQuaHanTren60", 0);
	KetQua.Insert("TongDuNo", 0);
	
	For Each Row In DanhSachKhoanNo Do
		Nhom = LayNhomTuoiNo(Row.NgayQuaHan);
		If Nhom = "TrongHan" Then
			KetQua.TongTrongHan = KetQua.TongTrongHan + Row.SoTien;
		ElsIf Nhom = "QuaHan1_30" Then
			KetQua.TongQuaHan1_30 = KetQua.TongQuaHan1_30 + Row.SoTien;
		ElsIf Nhom = "QuaHan31_60" Then
			KetQua.TongQuaHan31_60 = KetQua.TongQuaHan31_60 + Row.SoTien;
		ElsIf Nhom = "QuaHanTren60" Then
			KetQua.TongQuaHanTren60 = KetQua.TongQuaHanTren60 + Row.SoTien;
		EndIf;
	EndDo;
	
	KetQua.TongDuNo = KetQua.TongTrongHan + KetQua.TongQuaHan1_30 + KetQua.TongQuaHan31_60 + KetQua.TongQuaHanTren60;
	Return KetQua;
EndFunction

#EndRegion
"""
    with open("src/Reports/BaoCaoTuoiNoPhanTachNoiBo/Ext/ObjectModule.bsl", "w", encoding="utf-8") as f:
        f.write(bsl)
    print("Generated src/Reports/BaoCaoTuoiNoPhanTachNoiBo/Ext/ObjectModule.bsl")

def update_configuration():
    config_path = "src/Configuration.xml"
    with open(config_path, "r", encoding="utf-8") as f:
        content = f.read()

    new_rep = "\t\t\t<Report>BaoCaoTuoiNoPhanTachNoiBo</Report>\n"

    if "<Report>BaoCaoTuoiNoPhanTachNoiBo</Report>" not in content:
        content = content.replace("<DataProcessor>LapMaTranCanTruTapDoan</DataProcessor>\n", f"<DataProcessor>LapMaTranCanTruTapDoan</DataProcessor>\n{new_rep}")

    with open(config_path, "w", encoding="utf-8") as f:
        f.write(content)
    print("Updated src/Configuration.xml for Task 6.2 successfully!")

if __name__ == "__main__":
    generate_report_tuoi_no()
    update_configuration()
