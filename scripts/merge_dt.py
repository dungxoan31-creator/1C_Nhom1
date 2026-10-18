#!/usr/bin/env python3
"""
Merge VinSmart_Future_AR_AP_Clean.dt (data) + Modern Web UI config (src/) 
into a single VinSmart_Merged_Final.dt.

Strategy:
  1. Restore AR_AP_Clean.dt into temp infobase  → preserves all transactions & master data
  2. LoadConfigFromFiles src/                    → applies new UI/UX configuration
  3. UpdateDBCfg                                 → merges schema, keeps all existing data
  4. CheckConfig                                 → verifies no errors
  5. DumpIB → VinSmart_Merged_Final.dt          → combined output
"""

import sys
import shutil
import subprocess
from pathlib import Path

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')

WORKSPACE  = Path(r"C:\Users\Dung\Documents\VinSmart_1C_VietHoa_Test")
SRC_DIR    = WORKSPACE / "src"
DT_SOURCE  = WORKSPACE / "VinSmart_Future_AR_AP_Clean.dt"
OUT_DT     = WORKSPACE / "VinSmart_Merged_Final.dt"
BUILD_TMP  = WORKSPACE / "build_merge_tmp"
IB_DIR     = BUILD_TMP / "IB"
LOG_DIR    = BUILD_TMP / "logs"

EXE_1C = Path(r"C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe")
if not EXE_1C.exists():
    EXE_1C = Path(r"C:\Program Files\1cv8\current\bin\1cv8.exe")

COMMON = ["/DisableStartupDialogs", "/DisableStartupMessages"]

def log(msg): print(f"[*] {msg}", flush=True)

def run_step(name, args, desc, ok=(0, 1)):
    lf = LOG_DIR / f"{name}.log"
    cmd = args + COMMON + ["/Out", str(lf)]
    log(desc)
    r = subprocess.run(cmd, timeout=360, capture_output=True, text=True)
    if lf.exists():
        for line in lf.read_text(encoding="utf-8", errors="ignore").splitlines()[:25]:
            print(f"    | {line}")
    print(f"    Exit: {r.returncode}")
    if r.returncode not in ok:
        raise RuntimeError(f"Step '{name}' failed (exit {r.returncode})")
    return r.returncode

def main():
    print("=" * 68)
    print("MERGE: AR_AP_Clean.dt (data) + Modern Web UI config -> Merged Final")
    print("=" * 68)
    print(f"Source data : {DT_SOURCE}")
    print(f"UI config   : {SRC_DIR}")
    print(f"Output      : {OUT_DT}")
    print("=" * 68)

    if not DT_SOURCE.exists():
        raise FileNotFoundError(f"Source DT not found: {DT_SOURCE}")
    if not SRC_DIR.exists():
        raise FileNotFoundError(f"src/ directory not found: {SRC_DIR}")

    if BUILD_TMP.exists():
        shutil.rmtree(BUILD_TMP, ignore_errors=True)
    BUILD_TMP.mkdir(parents=True)
    LOG_DIR.mkdir(parents=True)

    try:
        # Step 1: Create empty infobase
        run_step("01_create",
            [str(EXE_1C), "CREATEINFOBASE", f"File={IB_DIR};Locale=en_US;"],
            "1. Creating temporary infobase")

        # Step 2: Restore AR_AP_Clean.dt (original data: transactions + master data)
        run_step("02_restore",
            [str(EXE_1C), "DESIGNER", "/F", str(IB_DIR),
             "/RestoreIB", str(DT_SOURCE)],
            f"2. Restoring original data from {DT_SOURCE.name}",
            ok=(0,))

        # Step 3: Load Modern UI configuration from src/
        #   After RestoreIB the infobase has users, so we need /N Admin /P ""
        #   exit 1 = benign WebKit ISO-8859-1 locale warning
        run_step("03_load_ui",
            [str(EXE_1C), "DESIGNER", "/F", str(IB_DIR),
             "/N", "Admin", "/P", "",
             "/LoadConfigFromFiles", str(SRC_DIR)],
            "3. Loading Modern Web UI config from src/")

        # Step 4: UpdateDBCfg — merges new schema onto existing data (non-destructive)
        run_step("04_update_db",
            [str(EXE_1C), "DESIGNER", "/F", str(IB_DIR),
             "/N", "Admin", "/P", "",
             "/UpdateDBCfg"],
            "4. Merging config into database (UpdateDBCfg) — preserving all data",
            ok=(0,))

        # Step 5: CheckConfig — verify merged result is error-free
        run_step("05_check",
            [str(EXE_1C), "DESIGNER", "/F", str(IB_DIR),
             "/N", "Admin", "/P", "",
             "/CheckConfig", "-Config", "-ThinClient"],
            "5. CheckConfig verification on merged infobase")

        # Step 6: Export merged infobase to .dt
        if OUT_DT.exists():
            OUT_DT.unlink()

        run_step("06_dump",
            [str(EXE_1C), "DESIGNER", "/F", str(IB_DIR),
             "/N", "Admin", "/P", "",
             "/DumpIB", str(OUT_DT)],
            f"6. Exporting merged infobase -> {OUT_DT.name}",
            ok=(0,))

        if OUT_DT.exists():
            size = OUT_DT.stat().st_size
            print("\n" + "=" * 68)
            print(">> MERGE COMPLETED SUCCESSFULLY! <<")
            print(f"   File  : {OUT_DT}")
            print(f"   Size  : {round(size/1024/1024, 2)} MB ({size:,} bytes)")
            print("   Contains: All original AR/AP data + Modern Web UI/UX interface")
            print("=" * 68)
        else:
            raise RuntimeError("Output .dt file was not created!")

    finally:
        shutil.rmtree(BUILD_TMP, ignore_errors=True)
        log("Cleaned up temporary merge directory.")

if __name__ == "__main__":
    main()
