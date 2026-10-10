import re

target_files = [
    'src/Documents/BienBanNghiemThuGiaiDoan/Ext/ObjectModule.bsl',
    'src/Documents/HoaDonGTGTDauRa/Ext/ObjectModule.bsl',
    'src/Documents/PhieuThuTienKhachHang/Ext/ObjectModule.bsl',
    'src/Documents/DieuChinhCongNo/Ext/ObjectModule.bsl'
]

for f in target_files:
    with open(f, 'r', encoding='utf-8') as fl:
        content = fl.read()
    new_content = re.sub(
        r'ChartsOfAccounts\.HeThongTaiKhoan\.TK([0-9]+)',
        r'ChartsOfAccounts.HeThongTaiKhoan.FindByCode("\1")',
        content
    )
    with open(f, 'w', encoding='utf-8') as fl:
        fl.write(new_content)
    print(f'Updated {f}')
