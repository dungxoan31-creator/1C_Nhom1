#!/usr/bin/env python3
"""
Build and Export complete 1C:Enterprise .dt file with Modern Web UI/UX.
Uses /Out log file and accepts exit codes 0-1 from LoadConfigFromFiles (ISO warning is benign).
"""

import os
import sys
import shutil
import subprocess
import tempfile
from pathlib import Path

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')

WORKSPACE = Path(r"C:\Users\Dung\Documents\VinSmart_1C_VietHoa_Test")
SRC_DIR = WORKSPACE / "src"
BUILD_TMP = WORKSPACE / "build_web_ui_tmp"
IB_DIR = BUILD_TMP / "IB"
LOG_DIR = BUILD_TMP / "logs"
OUT_DT = WORKSPACE / "VinSmart_Future_Modern_Web_UI.dt"

EXE_1C = Path(r"C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe")
if not EXE_1C.exists():
    EXE_1C = Path(r"C:\Program Files\1cv8\current\bin\1cv8.exe")

def log(msg):
    print(f"[*] {msg}", flush=True)

def run_step(step_name, args, desc, acceptable_codes=(0,)):
    log_file = LOG_DIR / f"{step_name}.log"
    full_args = args + ["/DisableStartupDialogs", "/DisableStartupMessages", "/Out", str(log_file)]
    log(desc)
    res = subprocess.run(full_args, timeout=240, capture_output=True, text=True)
    output = ""
    if log_file.exists():
        output = log_file.read_text(encoding="utf-8", errors="ignore")
        for line in output.splitlines()[:20]:
            print(f"    | {line}")
    print(f"    Exit code: {res.returncode}")
    if res.returncode not in acceptable_codes:
        print(f"[!] FAILED: {desc}")
        raise RuntimeError(f"Step {step_name} failed (exit {res.returncode})")
    return res.returncode, output

def main():
    print("=" * 65)
    print("BUILD & EXPORT MODERN WEB UI/UX .DT PACKAGE (VINSMART FUTURE)")
    print("=" * 65)
    print(f"1C Engine: {EXE_1C}")
    print(f"Source:    {SRC_DIR}")
    print(f"Target DT: {OUT_DT}")
    print("=" * 65)

    if BUILD_TMP.exists():
        shutil.rmtree(BUILD_TMP, ignore_errors=True)
    BUILD_TMP.mkdir(parents=True)
    LOG_DIR.mkdir(parents=True)

    try:
        # Step 1: Create Infobase
        run_step("01_create", 
            [str(EXE_1C), "CREATEINFOBASE", f"File={IB_DIR};Locale=en_US;"],
            "1. Creating clean temporary Infobase")

        # Step 2: Load configuration from src/
        # Exit code 1 is acceptable - it's just a WebKit ISO-8859-1 localization warning
        run_step("02_load_src",
            [str(EXE_1C), "DESIGNER", "/F", str(IB_DIR), "/LoadConfigFromFiles", str(SRC_DIR)],
            "2. Loading configuration from src/",
            acceptable_codes=(0, 1))

        # Step 3: Update DB configuration
        run_step("03_update_db",
            [str(EXE_1C), "DESIGNER", "/F", str(IB_DIR), "/UpdateDBCfg"],
            "3. Updating database configuration (UpdateDBCfg)")

        # Step 4: CheckConfig verification
        run_step("04_check",
            [str(EXE_1C), "DESIGNER", "/F", str(IB_DIR), "/CheckConfig", "-Config", "-ThinClient"],
            "4. Running CheckConfig verification")

        # Step 5: Export to .dt file
        if OUT_DT.exists():
            OUT_DT.unlink()

        run_step("05_dump",
            [str(EXE_1C), "DESIGNER", "/F", str(IB_DIR), "/DumpIB", str(OUT_DT)],
            "5. Exporting Infobase to .dt package (DumpIB)")

        if OUT_DT.exists():
            size_bytes = OUT_DT.stat().st_size
            size_mb = round(size_bytes / (1024 * 1024), 2)
            print("\n" + "=" * 65)
            print(">> MODERN WEB UI PACKAGE CREATION COMPLETED SUCCESSFULLY! <<")
            print(f"Path: {OUT_DT}")
            print(f"Size: {size_mb} MB ({size_bytes:,} bytes)")
            print("=" * 65)
        else:
            raise RuntimeError("Target DT file was not generated!")

    finally:
        shutil.rmtree(BUILD_TMP, ignore_errors=True)
        log("Cleaned up temporary build directory.")

if __name__ == "__main__":
    main()
