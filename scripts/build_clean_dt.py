#!/usr/bin/env python3
"""
Build and Export a complete, clean 1C:Enterprise .dt file for testing:
1. Creates temporary clean Infobase
2. Loads configuration from src/
3. Updates DB schema and runs CheckConfig
4. Creates 5 standard users (Admin, ketoan_ar, ketoan_ap, ketoan_truong, cfo_giamdoc)
5. Initializes standard master data (PhapNhan, DoiTac, HopDong, Accounts, Currency)
6. Dumps Infobase to .dt file
7. Cleans up temporary directory
"""

import os
import sys
import shutil
import subprocess
from pathlib import Path

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')

WORKSPACE = Path(r"C:\Users\Dung\Documents\VinSmart_1C_VietHoa_Test")
SRC_DIR = WORKSPACE / "src"
BUILD_TMP = WORKSPACE / "build_dt_tmp"
IB_DIR = BUILD_TMP / "IB"
OUT_DT = WORKSPACE / "VinSmart_Future_AR_AP_Clean.dt"

EXE_1C = Path(r"C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe")
if not EXE_1C.exists():
    EXE_1C = Path(r"C:\Program Files\1cv8\current\bin\1cv8.exe")

def log(msg):
    print(f"[*] {msg}")

def run_cmd(args, desc, check=True):
    log(desc)
    res = subprocess.run(args, capture_output=True, text=True, timeout=180)
    if check and res.returncode != 0:
        print(f"[!] Error in {desc} (ExitCode: {res.returncode}):")
        if res.stdout:
            print(res.stdout)
        if res.stderr:
            print(res.stderr)
        raise RuntimeError(f"{desc} failed with exit code {res.returncode}")
    return res

def main():
    print("=" * 65)
    print("BUILD & EXPORT CLEAN 1C:ENTERPRISE .DT PACKAGE (AR & AP)")
    print("=" * 65)
    print(f"1C Engine: {EXE_1C}")
    print(f"Source:    {SRC_DIR}")
    print(f"Target DT: {OUT_DT}")
    print("=" * 65)

    if BUILD_TMP.exists():
        shutil.rmtree(BUILD_TMP, ignore_errors=True)
    BUILD_TMP.mkdir(parents=True, exist_ok=True)

    try:
        # Step 1: Create Infobase
        run_cmd([str(EXE_1C), "CREATEINFOBASE", f"File={IB_DIR};Locale=en_US;"],
                "1. Creating clean temporary Infobase")

        # Step 2: Load configuration from src/
        run_cmd([str(EXE_1C), "DESIGNER", "/F", str(IB_DIR), "/LoadConfigFromFiles", str(SRC_DIR),
                 "/DisableStartupMessages", "/DisableStartupDialogs"],
                "2. Loading configuration from src/")

        # Step 3: Update DB configuration
        run_cmd([str(EXE_1C), "DESIGNER", "/F", str(IB_DIR), "/UpdateDBCfg",
                 "/DisableStartupMessages", "/DisableStartupDialogs"],
                "3. Updating database configuration (UpdateDBCfg)")

        # Step 4: Verify CheckConfig
        run_cmd([str(EXE_1C), "DESIGNER", "/F", str(IB_DIR), "/CheckConfig", "-Config", "-ThinClient",
                 "/DisableStartupMessages", "/DisableStartupDialogs"],
                "4. Running CheckConfig verification")

        # Step 5: Setup standard users
        run_cmd([str(EXE_1C), "ENTERPRISE", "/F", str(IB_DIR),
                 "/C", "SetupSampleUsers",
                 "/DisableStartupMessages", "/DisableStartupDialogs"],
                "5. Initializing 5 standard users (Admin, ketoan_ar, ketoan_ap, ketoan_truong, cfo_giamdoc)")

        # Step 6: Initialize standard master data (including 243 TT200 accounts)
        run_cmd([str(EXE_1C), "ENTERPRISE", "/F", str(IB_DIR),
                 "/N", "Admin",
                 "/C", "SeedMasterData",
                 "/DisableStartupMessages", "/DisableStartupDialogs"],
                "6. Initializing standard Master Data (PhapNhan, DoiTac, HopDong, 243 Accounts TT200)")

        # Step 6b: Verify Master Data & COA stats
        report_file = BUILD_TMP / "coa_stats.txt"
        run_cmd([str(EXE_1C), "ENTERPRISE", "/F", str(IB_DIR),
                 "/N", "Admin",
                 "/C", f"ReportCOAStats;{report_file}",
                 "/DisableStartupMessages", "/DisableStartupDialogs"],
                "6b. Verifying Chart of Accounts structure")

        if report_file.exists():
            print("[*] COA Statistics Report:")
            with open(report_file, "r", encoding="utf-8-sig") as rf:
                for line in rf:
                    print("   ", line.strip())

        # Step 7: Export to .dt file
        if OUT_DT.exists():
            OUT_DT.unlink()

        run_cmd([str(EXE_1C), "DESIGNER", "/F", str(IB_DIR),
                 "/N", "Admin",
                 "/DumpIB", str(OUT_DT),
                 "/DisableStartupMessages", "/DisableStartupDialogs"],
                "7. Exporting Infobase to .dt package (DumpIB)")

        if OUT_DT.exists():
            size_bytes = OUT_DT.stat().st_size
            size_mb = round(size_bytes / (1024 * 1024), 2)
            print("\n" + "=" * 65)
            print(">> PACKAGE CREATION COMPLETED SUCCESSFULLY! <<")
            print(f"Path: {OUT_DT}")
            print(f"Size: {size_mb} MB ({size_bytes:,} bytes)")
            print("=" * 65)
        else:
            raise RuntimeError("Target DT file was not generated!")

    finally:
        shutil.rmtree(BUILD_TMP, ignore_errors=True)
        log("Cleaned up temporary build infobase directory.")

if __name__ == "__main__":
    main()
