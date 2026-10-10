import os
import uuid

def uid():
    return str(uuid.uuid4())

def setup_subsystems():
    os.makedirs('src/Subsystems', exist_ok=True)

    subsystems = [
        {
            'name': 'PhanHePhaiThu',
            'synonym_vi': '1. Phải thu (AR)',
            'synonym_en': 'Accounts Receivable (AR)',
            'items': [
                'Document.BienBanNghiemThuGiaiDoan',
                'Document.HoaDonGTGTDauRa',
                'Document.PhieuThuTienKhachHang',
                'Document.DieuChinhCongNo',
                'AccumulationRegister.CongNoPhaiThu',
                'Report.BaoCaoTuoiNoPhanTachNoiBo'
            ]
        },
        {
            'name': 'PhanHePhaiTra',
            'synonym_vi': '2. Phải trả (AP)',
            'synonym_en': 'Accounts Payable (AP)',
            'items': [
                'Document.NghiemThuThauPhu',
                'Document.HoaDonNhaCungCap',
                'Document.DeNghiThanhToanDichVu',
                'Document.UyNhiemChi',
                'AccumulationRegister.CongNoPhaiTra',
                'Report.CanhBaoHanMucVaGiaHanCloud'
            ]
        },
        {
            'name': 'PhanHeNganHangVaQuy',
            'synonym_vi': '3. Ngân hàng &amp; Quỹ',
            'synonym_en': 'Cash &amp; Banking',
            'items': [
                'Document.BaoCoNganHang',
                'Document.BangKeDoiSoatKenhThanhToan',
                'Document.YeuCauHoanTienChiHo',
                'DataProcessor.DongCoDoiSoatTuDong',
                'AccumulationRegister.DongTien',
                'AccumulationRegister.GiaoDichDienTuTamGiu',
                'InformationRegister.LichSuGiaoDichNganHang',
                'Report.DoiSoatKenhThanhToanVaDongTienAo'
            ]
        },
        {
            'name': 'PhanHeCanTruNetting',
            'synonym_vi': '4. Bù trừ &amp; Netting',
            'synonym_en': 'Netting &amp; Settlement',
            'items': [
                'Document.CanTruCongNoNoiBo',
                'DataProcessor.LapMaTranCanTruTapDoan',
                'Report.MaTranCanTruNoiBoTapDoan'
            ]
        },
        {
            'name': 'PhanHeSoCaiVaDongBo',
            'synonym_vi': '5. Sổ cái &amp; Đồng bộ SAP',
            'synonym_en': 'General Ledger &amp; SAP Sync',
            'items': [
                'ChartOfAccounts.HeThongTaiKhoan',
                'AccountingRegister.SoCaiKeToan',
                'DataProcessor.NapSoDuDauKy',
                'DataProcessor.DongBoButToanSAP',
                'InformationRegister.TrangThaiDongBoSAP',
                'ScheduledJob.DongBoSAPHangNgay',
                'ScheduledJob.CapNhatTyGiaNgoaiTeTuDong'
            ]
        },
        {
            'name': 'PhanHeDanhMuc',
            'synonym_vi': '6. Danh mục nền tảng',
            'synonym_en': 'Master Data',
            'items': [
                'Catalog.PhapNhan',
                'Catalog.DoiTac',
                'Catalog.HopDong',
                'Catalog.TaiKhoanTien',
                'Catalog.TaiKhoanAo',
                'Catalog.KenhThanhToan',
                'Catalog.DichVuCNTT',
                'Catalog.DuAn',
                'Catalog.KhoanMucDongTien',
                'Catalog.TienTe',
                'InformationRegister.TyGiaHoiDoai',
                'InformationRegister.HanMucVaChanXuatDichVu',
                'InformationRegister.KeHoachChiTien'
            ]
        }
    ]

    for sub in subsystems:
        content_items = '\n'.join([f'\t\t\t\t<xr:Item xsi:type="xr:MDObjectRef">{item}</xr:Item>' for item in sub['items']])
        sub_xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<MetaDataObject xmlns="http://v8.1c.ru/8.3/MDClasses" xmlns:app="http://v8.1c.ru/8.2/managed-application/core" xmlns:cfg="http://v8.1c.ru/8.1/data/enterprise/current-config" xmlns:cmi="http://v8.1c.ru/8.2/managed-application/cmi" xmlns:ent="http://v8.1c.ru/8.1/data/enterprise" xmlns:lf="http://v8.1c.ru/8.2/managed-application/logform" xmlns:style="http://v8.1c.ru/8.1/data/ui/style" xmlns:sys="http://v8.1c.ru/8.1/data/ui/fonts/system" xmlns:v8="http://v8.1c.ru/8.1/data/core" xmlns:v8ui="http://v8.1c.ru/8.1/data/ui" xmlns:web="http://v8.1c.ru/8.1/data/ui/colors/web" xmlns:win="http://v8.1c.ru/8.1/data/ui/colors/windows" xmlns:xen="http://v8.1c.ru/8.3/xcf/enums" xmlns:xpr="http://v8.1c.ru/8.3/xcf/predef" xmlns:xr="http://v8.1c.ru/8.3/xcf/readable" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.15">
\t<Subsystem uuid="{uid()}">
\t\t<Properties>
\t\t\t<Name>{sub['name']}</Name>
\t\t\t<Synonym>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>vi</v8:lang>
\t\t\t\t\t<v8:content>{sub['synonym_vi']}</v8:content>
\t\t\t\t</v8:item>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t<v8:content>{sub['synonym_en']}</v8:content>
\t\t\t\t</v8:item>
\t\t\t</Synonym>
\t\t\t<Comment/>
\t\t\t<IncludeHelpInContents>false</IncludeHelpInContents>
\t\t\t<IncludeInCommandInterface>true</IncludeInCommandInterface>
\t\t\t<Explanation/>
\t\t\t<Picture/>
\t\t\t<Content>
{content_items}
\t\t\t</Content>
\t\t</Properties>
\t\t<ChildObjects/>
\t</Subsystem>
</MetaDataObject>"""
        with open(f"src/Subsystems/{sub['name']}.xml", "w", encoding="utf-8") as f:
            f.write(sub_xml)
        print(f"Generated src/Subsystems/{sub['name']}.xml")

    # Update Configuration.xml
    with open("src/Configuration.xml", "r", encoding="utf-8") as f:
        cfg = f.read()

    for sub in subsystems:
        tag = f"<Subsystem>{sub['name']}</Subsystem>"
        if tag not in cfg:
            cfg = cfg.replace("<ChildObjects>\n", f"<ChildObjects>\n\t\t\t{tag}\n")

    with open("src/Configuration.xml", "w", encoding="utf-8") as f:
        f.write(cfg)
    print("Updated src/Configuration.xml with Subsystems successfully!")

if __name__ == "__main__":
    setup_subsystems()
