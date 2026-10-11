import os

roles = [
    'ChuyenVienDoiSoatTapDoan',
    'GiamDocTaiChinh_CFO',
    'ITDirector_GiamDocHaTang',
    'KeToanPhaiThu',
    'KeToanPhaiTra',
    'KeToanTruong',
    'ProjectManager_QuanLyDuAn',
    'TechLead_KiemTraKyThuat'
]

content = """<?xml version="1.0" encoding="UTF-8"?>
<Rights xmlns="http://v8.1c.ru/8.2/roles" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="Rights" version="2.15">
\t<setForNewObjects>true</setForNewObjects>
\t<setForAttributesByDefault>true</setForAttributesByDefault>
\t<independentRightsOfChildObjects>false</independentRightsOfChildObjects>
\t<object>
\t\t<name>Configuration.Configuration</name>
\t\t<right>
\t\t\t<name>ThinClient</name>
\t\t\t<value>true</value>
\t\t</right>
\t\t<right>
\t\t\t<name>WebClient</name>
\t\t\t<value>true</value>
\t\t</right>
\t\t<right>
\t\t\t<name>MainWindowModeNormal</name>
\t\t\t<value>true</value>
\t\t</right>
\t\t<right>
\t\t\t<name>SaveUserData</name>
\t\t\t<value>true</value>
\t\t</right>
\t\t<right>
\t\t\t<name>Output</name>
\t\t\t<value>true</value>
\t\t</right>
\t</object>
</Rights>
"""

for r in roles:
    d = os.path.join('src', 'Roles', r, 'Ext')
    os.makedirs(d, exist_ok=True)
    fpath = os.path.join(d, 'Rights.xml')
    with open(fpath, 'w', encoding='utf-8') as f:
        f.write(content)
    print('Created', fpath)
