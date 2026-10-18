#!/usr/bin/env python3
"""
scripts/import_coa_tt200.py
---------------------------
Parses Circular 200/2014/TT-BTC Chart of Accounts from:
  C:\\Users\\Dung\\Downloads\\He-thong-Tai-khoan-ke-toan-theo-TT-200.xlsx

Generates standard BSL code in GeneratorMasterDataServer to initialize
and maintain the complete Chart of Accounts (243 accounts: 77 L1, 156 L2, 10 L3)
with proper hierarchy, account types (Active/Passive/ActivePassive), and custom attributes.
"""

import sys
import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path

WORKSPACE = Path(r"C:\Users\Dung\Documents\VinSmart_1C_VietHoa_Test")
DEFAULT_EXCEL = Path(r"C:\Users\Dung\Downloads\He-thong-Tai-khoan-ke-toan-theo-TT-200.xlsx")
GMD_BSL = WORKSPACE / "src" / "CommonModules" / "GeneratorMasterDataServer" / "Ext" / "Module.bsl"
MAM_BSL = WORKSPACE / "src" / "Ext" / "ManagedApplicationModule.bsl"

def classify_account(code, name):
    if code == '000':
        return 'ActivePassive'
    if code.startswith('214') or code.startswith('229'):
        return 'Passive'
    if code.startswith('419'):
        return 'Active'
    if code.startswith('521'):
        return 'Active'
    if code.startswith('131') or code.startswith('136') or code.startswith('138'):
        return 'ActivePassive'
    if code.startswith('331') or code.startswith('334') or code.startswith('336') or code.startswith('338'):
        return 'ActivePassive'
    if code.startswith('412') or code.startswith('413') or code.startswith('421'):
        return 'ActivePassive'
    if code == '911':
        return 'ActivePassive'
    if code.startswith('333'):
        if code == '333':
            return 'ActivePassive'
        return 'Passive'
    
    first = code[0]
    if first in ['1', '2', '6', '8']:
        return 'Active'
    elif first in ['3', '4', '5', '7']:
        return 'Passive'
    elif first == '9':
        return 'ActivePassive'
    return 'ActivePassive'

def parse_excel_coa(excel_path):
    print(f"[*] Reading Excel file: {excel_path}")
    wb = zipfile.ZipFile(excel_path)
    shared_xml = wb.read('xl/sharedStrings.xml')
    sst = ET.fromstring(shared_xml)
    ns = {'ns': 'http://schemas.openxmlformats.org/spreadsheetml/2006/main'}
    strings = []
    for si in sst.findall('ns:si', ns):
        t = si.find('ns:t', ns)
        if t is not None and t.text:
            strings.append(t.text)
        else:
            texts = [e.text for e in si.findall('.//ns:t', ns) if e.text]
            strings.append(''.join(texts))

    sheet1_xml = wb.read('xl/worksheets/sheet1.xml')
    sheet1 = ET.fromstring(sheet1_xml)
    rows = sheet1.findall('.//ns:row', ns)

    accounts = {}
    for row in rows:
        row_num = int(row.attrib.get('r', 0))
        if row_num <= 8:
            continue
        c_dict = {}
        for c in row.findall('ns:c', ns):
            ref = c.attrib.get('r', '')
            col = ''.join(ch for ch in ref if ch.isalpha())
            val = c.find('ns:v', ns)
            t = c.attrib.get('t')
            cell_val = ''
            if val is not None and val.text:
                if t == 's':
                    idx = int(val.text)
                    cell_val = strings[idx] if idx < len(strings) else val.text
                else:
                    cell_val = val.text
            c_dict[col] = cell_val.strip()
        
        colA = c_dict.get('A', '')
        colB = c_dict.get('B', '')
        colC = c_dict.get('C', '')
        if colA or colB:
            code = colA if colA else colB
            level = 1 if colA else (2 if len(code) == 4 else 3)
            parent = '' if level == 1 else (code[:3] if level == 2 else code[:4])
            tchat = classify_account(code, colC)
            accounts[code] = {
                'code': code,
                'name': colC,
                'level': level,
                'parent': parent,
                'tchat': tchat
            }

    print(f"[*] Parsed {len(accounts)} accounts from Excel.")

    # Supplementary demo sub-accounts
    supp = [
        ('1311', 'Phải thu của khách hàng bên ngoài', 2, '131', 'ActivePassive'),
        ('1312', 'Phải thu của khách hàng nội bộ Vingroup', 2, '131', 'ActivePassive'),
        ('3311', 'Phải trả cho người bán bên ngoài', 2, '331', 'ActivePassive'),
        ('3312', 'Phải trả cho người bán nội bộ Vingroup', 2, '331', 'ActivePassive'),
        ('3313', 'Phải trả người bán nước ngoài (Ngoại tệ USD)', 2, '331', 'ActivePassive'),
        ('3318', 'Phải trả người bán khác', 2, '331', 'ActivePassive'),
        ('33318', 'Thuế GTGT nhà thầu nước ngoài (FCT VAT)', 3, '3331', 'Passive'),
        ('000', 'Tài khoản đối ứng số dư ban đầu', 1, '', 'ActivePassive')
    ]

    for code, name, lvl, par, tch in supp:
        if code not in accounts:
            accounts[code] = {
                'code': code,
                'name': name,
                'level': lvl,
                'parent': par,
                'tchat': tch
            }
        else:
            # ensure demo properties
            accounts[code]['name'] = name
            accounts[code]['tchat'] = tch

    print(f"[*] Total accounts after demo additions: {len(accounts)}")
    return accounts

def generate_bsl_code(accounts):
    lvl1 = sorted([a for a in accounts.values() if a['level'] == 1], key=lambda x: x['code'])
    lvl2 = sorted([a for a in accounts.values() if a['level'] == 2], key=lambda x: x['code'])
    lvl3 = sorted([a for a in accounts.values() if a['level'] == 3], key=lambda x: x['code'])

    lines = []
    lines.append("#Region ChartOfAccountsTT200")
    lines.append("")
    lines.append("// Khoi tao he thong tai khoan ke toan theo TT 200/2014/TT-BTC")
    lines.append("Procedure KhoiTaoHeThongTaiKhoanTT200() Export")
    lines.append("\tQuanLyVongDoiChungTuServer.KiemTraChoPhepSinhDuLieuMau();")
    lines.append("\t")
    lines.append("\tDS1 = New Array;")
    lines.append("\tNapDanhSachTaiKhoanCap1(DS1);")
    lines.append("\tGhiDanhSachTaiKhoan(DS1);")
    lines.append("\t")
    lines.append("\tDS2 = New Array;")
    lines.append("\tNapDanhSachTaiKhoanCap2(DS2);")
    lines.append("\tGhiDanhSachTaiKhoan(DS2);")
    lines.append("\t")
    lines.append("\tDS3 = New Array;")
    lines.append("\tNapDanhSachTaiKhoanCap3(DS3);")
    lines.append("\tGhiDanhSachTaiKhoan(DS3);")
    lines.append("\t")
    lines.append('\tWriteLogEvent("Account.Init", EventLogLevel.Information,,, "Khởi tạo thành công 243 tài khoản kế toán theo TT 200/2014/TT-BTC!");')
    lines.append("EndProcedure")
    lines.append("")
    lines.append("Procedure ThemTK(DS, Code, Name, TinhChat, ParentCode = \"\")")
    lines.append("\tDS.Add(New Structure(\"Code,Name,Type,ParentCode\", Code, Name, TinhChat, ParentCode));")
    lines.append("EndProcedure")
    lines.append("")
    lines.append("Procedure GhiDanhSachTaiKhoan(DS)")
    lines.append("\tFor Each Item In DS Do")
    lines.append("\t\tRefAcc = ChartsOfAccounts.HeThongTaiKhoan.FindByCode(Item.Code);")
    lines.append("\t\tIf ValueIsFilled(RefAcc) Then")
    lines.append("\t\t\tObjAcc = RefAcc.GetObject();")
    lines.append("\t\tElse")
    lines.append("\t\t\tObjAcc = ChartsOfAccounts.HeThongTaiKhoan.CreateAccount();")
    lines.append("\t\t\tObjAcc.Code = Item.Code;")
    lines.append("\t\tEndIf;")
    lines.append("\t\tObjAcc.Description = Item.Name;")
    lines.append("\t\tIf Item.Type = \"Active\" Then")
    lines.append("\t\t\tObjAcc.Type = AccountType.Active;")
    lines.append("\t\tElsIf Item.Type = \"Passive\" Then")
    lines.append("\t\t\tObjAcc.Type = AccountType.Passive;")
    lines.append("\t\tElse")
    lines.append("\t\t\tObjAcc.Type = AccountType.ActivePassive;")
    lines.append("\t\tEndIf;")
    lines.append("\t\tObjAcc.MaLogic = Item.Code;")
    lines.append("\t\tObjAcc.TenTaiKhoan = Item.Name;")
    lines.append("\t\tObjAcc.TinhChat = Item.Type;")
    lines.append("\t\tIf ValueIsFilled(Item.ParentCode) Then")
    lines.append("\t\t\tRefParent = ChartsOfAccounts.HeThongTaiKhoan.FindByCode(Item.ParentCode);")
    lines.append("\t\t\tIf ValueIsFilled(RefParent) Then")
    lines.append("\t\t\t\tObjAcc.Parent = RefParent;")
    lines.append("\t\t\tEndIf;")
    lines.append("\t\tElse")
    lines.append("\t\t\tObjAcc.Parent = Undefined;")
    lines.append("\t\tEndIf;")
    lines.append("\t\tObjAcc.Write();")
    lines.append("\tEndDo;")
    lines.append("EndProcedure")
    lines.append("")

    # Helper 1: Level 1
    lines.append("Procedure NapDanhSachTaiKhoanCap1(DS)")
    for a in lvl1:
        name_esc = a['name'].replace('"', '""')
        lines.append(f'\tThemTK(DS, "{a["code"]}", "{name_esc}", "{a["tchat"]}");')
    lines.append("EndProcedure")
    lines.append("")

    # Helper 2: Level 2
    lines.append("Procedure NapDanhSachTaiKhoanCap2(DS)")
    for a in lvl2:
        name_esc = a['name'].replace('"', '""')
        lines.append(f'\tThemTK(DS, "{a["code"]}", "{name_esc}", "{a["tchat"]}", "{a["parent"]}");')
    lines.append("EndProcedure")
    lines.append("")

    # Helper 3: Level 3
    lines.append("Procedure NapDanhSachTaiKhoanCap3(DS)")
    for a in lvl3:
        name_esc = a['name'].replace('"', '""')
        lines.append(f'\tThemTK(DS, "{a["code"]}", "{name_esc}", "{a["tchat"]}", "{a["parent"]}");')
    lines.append("EndProcedure")
    lines.append("")
    lines.append("#EndRegion")

    return "\n".join(lines)

def main():
    excel_path = DEFAULT_EXCEL
    if len(sys.argv) > 1:
        excel_path = Path(sys.argv[1])
    
    if not excel_path.exists():
        print(f"[!] Error: Excel file not found: {excel_path}")
        sys.exit(1)

    accounts = parse_excel_coa(excel_path)
    bsl_coa = generate_bsl_code(accounts)

    # Update GeneratorMasterDataServer.bsl
    print(f"[*] Reading {GMD_BSL}...")
    content = GMD_BSL.read_text(encoding="utf-8")

    # Replace KhoiTaoCacTaiKhoanConThieu() with calling KhoiTaoHeThongTaiKhoanTT200()
    old_call = "KhoiTaoCacTaiKhoanConThieu();"
    new_call = "KhoiTaoHeThongTaiKhoanTT200();"
    if old_call in content:
        content = content.replace(old_call, new_call, 1)

    # If KhoiTaoCacTaiKhoanConThieu implementation exists, update it to call KhoiTaoHeThongTaiKhoanTT200
    if "Procedure KhoiTaoCacTaiKhoanConThieu() Export" in content:
        # replace the old stub with delegator
        import re
        content = re.sub(
            r"Procedure KhoiTaoCacTaiKhoanConThieu\(\) Export.*?EndProcedure",
            "Procedure KhoiTaoCacTaiKhoanConThieu() Export\n\tKhoiTaoHeThongTaiKhoanTT200();\nEndProcedure",
            content,
            flags=re.DOTALL
        )

    # Append or replace #Region ChartOfAccountsTT200
    if "#Region ChartOfAccountsTT200" in content:
        import re
        content = re.sub(r"#Region ChartOfAccountsTT200.*?#EndRegion", bsl_coa, content, flags=re.DOTALL)
    else:
        content = content.rstrip() + "\n\n" + bsl_coa + "\n"

    GMD_BSL.write_text(content, encoding="utf-8")
    print(f"[+] Updated {GMD_BSL} with complete TT200 Chart of Accounts logic.")

    # Update ManagedApplicationModule.bsl if ImportCOATT200 not present
    mam_content = MAM_BSL.read_text(encoding="utf-8")
    if "ImportCOATT200" not in mam_content:
        target = 'ElsIf Cmd = "SeedMasterData" Then'
        replacement = 'ElsIf Cmd = "ImportCOATT200" Then\n\t\tTry\n\t\t\tGeneratorMasterDataServer.KhoiTaoHeThongTaiKhoanTT200();\n\t\tExcept\n\t\t\tQuanLyVongDoiChungTuServer.GhiNhatKyError("COA.Fatal", DetailErrorDescription(ErrorInfo()));\n\t\tEndTry;\n\t\tExit(False);\n\t' + target
        mam_content = mam_content.replace(target, replacement, 1)
        MAM_BSL.write_text(mam_content, encoding="utf-8")
        print(f"[+] Added ImportCOATT200 handler to {MAM_BSL}.")

    print("[*] Checking BSL syntax verification...")
    import subprocess
    v_res = subprocess.run([sys.executable, str(WORKSPACE / "scripts" / "verify_bsl_syntax.py")], capture_output=True, text=True)
    print(v_res.stdout)
    if v_res.returncode != 0:
        print("[!] BSL Syntax verification failed!")
        sys.exit(1)

    print("[+] All done successfully!")

if __name__ == "__main__":
    main()
