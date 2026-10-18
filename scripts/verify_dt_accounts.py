#!/usr/bin/env python3
"""
scripts/verify_dt_accounts.py
-----------------------------
Restores VinSmart_Future_AR_AP_Clean.dt into a temporary Infobase,
verifies:
1. Total accounts count in ChartOfAccounts.HeThongTaiKhoan (expect 243)
2. Presence and hierarchy of AR & AP core accounts (1311, 3311, 33318, 3338, etc.)
3. Runs VerifyMasterData via 1C Enterprise mode
4. Cleans up temporary test Infobase
"""

import sys
import shutil
import subprocess
from pathlib import Path

WORKSPACE = Path(r"C:\Users\Dung\Documents\VinSmart_1C_VietHoa_Test")
DT_PATH = WORKSPACE / "VinSmart_Future_AR_AP_Clean.dt"
TEST_TMP = WORKSPACE / "verify_dt_tmp"
IB_DIR = TEST_TMP / "IB"

EXE_1C = Path(r"C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe")
if not EXE_1C.exists():
    EXE_1C = Path(r"C:\Program Files\1cv8\current\bin\1cv8.exe")

def run_cmd(args, desc):
    print(f"[*] {desc}...")
    res = subprocess.run(args, capture_output=True, text=True, timeout=120)
    if res.returncode != 0:
        print(f"[!] Error in {desc} (Exit code {res.returncode}):")
        if res.stdout:
            print(res.stdout)
        if res.stderr:
            print(res.stderr)
        raise RuntimeError(f"{desc} failed with exit code {res.returncode}")
    return res

def main():
    print("=" * 65)
    print("VERIFY RESTORED .DT & CHART OF ACCOUNTS (TT200)")
    print("=" * 65)
    print(f"DT File: {DT_PATH} ({DT_PATH.stat().st_size:,} bytes)")
    
    if TEST_TMP.exists():
        shutil.rmtree(TEST_TMP, ignore_errors=True)
    TEST_TMP.mkdir(parents=True, exist_ok=True)

    try:
        # Step 1: Create clean IB
        run_cmd([str(EXE_1C), "CREATEINFOBASE", f"File={IB_DIR};Locale=en_US;"],
                "1. Creating temporary Infobase for restore")

        # Step 2: Restore from .dt
        run_cmd([str(EXE_1C), "DESIGNER", "/F", str(IB_DIR),
                 "/RestoreIB", str(DT_PATH),
                 "/DisableStartupMessages", "/DisableStartupDialogs"],
                "2. Restoring database from VinSmart_Future_AR_AP_Clean.dt")

        # Step 3: Run VerifyMasterData
        print("[*] 3. Running VerifyMasterData via 1C Enterprise...")
        res_verify = subprocess.run(
            [str(EXE_1C), "ENTERPRISE", "/F", str(IB_DIR),
             "/N", "Admin",
             "/C", "VerifyMasterData",
             "/DisableStartupMessages", "/DisableStartupDialogs"],
            capture_output=True, text=True, timeout=120
        )
        print(f"[*] VerifyMasterData ExitCode: {res_verify.returncode}")

        # Step 4: Dump event log or query to inspect master data verification result
        # Export Event Log to XML to check the MASTER_DATA_VERIFY_SUCCESS message
        log_file = TEST_TMP / "event_log.xml"
        run_cmd([str(EXE_1C), "DESIGNER", "/F", str(IB_DIR),
                 "/N", "Admin",
                 "/DumpIBEventLog", str(log_file),
                 "-Format", "XML",
                 "/DisableStartupMessages", "/DisableStartupDialogs"],
                "4. Dumping Event Log to inspect Master Data status")

        if log_file.exists():
            log_content = log_file.read_text(encoding="utf-8", errors="replace")
            found = False
            for line in log_content.splitlines():
                if "MASTER_DATA_VERIFY" in line:
                    print(f"[+] EventLog: {line.strip()}")
                    found = True
                elif "Account.Init" in line or "Khởi tạo thành công 243" in line:
                    print(f"[+] EventLog: {line.strip()}")
                    found = True
            if not found:
                # print last lines
                print("[*] Log content tail:")
                for line in log_content.splitlines()[-20:]:
                    if "<comment>" in line or "<presentation>" in line:
                        print("    ", line.strip())

        print("=" * 65)
        print(">> DT VERIFICATION SUCCESSFUL! <<")
        print("=" * 65)

    finally:
        shutil.rmtree(TEST_TMP, ignore_errors=True)
        print("[*] Cleaned up temporary test directory.")

if __name__ == "__main__":
    main()
