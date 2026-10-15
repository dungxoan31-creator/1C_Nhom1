"""Rebuild Infobase_FullData from src/ and export VinSmart_Future_AR_AP_Full.dt."""

import os
import shutil
import subprocess
import sys
from pathlib import Path

WORKSPACE = Path(__file__).resolve().parent.parent
EXE = Path(r"C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe")
IB_FULLDATA = WORKSPACE / "Infobase_FullData"
SRC = WORKSPACE / "src"
OUT_DT = WORKSPACE / "VinSmart_Future_AR_AP_Full.dt"
LOG = WORKSPACE / "rebuild_dt.log"


def run_1c(arguments, description):
    print(f"--> {description}...")
    if LOG.exists():
        LOG.unlink()
    cmd = [
        str(EXE),
        "DESIGNER",
        "/F",
        str(IB_FULLDATA),
        "/N",
        "Admin",
        *arguments,
        "/DisableStartupMessages",
        "/DisableStartupDialogs",
        "/OUT",
        str(LOG),
    ]
    res = subprocess.run(cmd)
    if res.returncode != 0:
        print(f"FAILED (ExitCode: {res.returncode})")
        if LOG.exists():
            print(LOG.read_text(encoding="utf-8-sig", errors="replace"))
        sys.exit(1)
    if LOG.exists():
        content = LOG.read_text(encoding="utf-8-sig", errors="replace").strip()
        if content:
            print(f"    Log: {content}")
    print("    OK")


def main():
    print(f"Starting Rebuild & Export DT workflow...")
    print(f"Workspace: {WORKSPACE}")
    print(f"Target DT: {OUT_DT}")

    # Ensure ConfigDumpInfo.xml exists in src
    dump_info_src = SRC / "ConfigDumpInfo.xml"
    if not dump_info_src.exists():
        cached_info = WORKSPACE / "scratch" / "dump_test" / "ConfigDumpInfo.xml"
        if cached_info.exists():
            shutil.copy2(cached_info, dump_info_src)
            print("Copied ConfigDumpInfo.xml into src/")

    # 1. LoadConfigFromFiles
    run_1c(["/LoadConfigFromFiles", str(SRC)], "1. Loading config from files into Infobase_FullData")

    # 2. UpdateDBCfg
    run_1c(["/UpdateDBCfg"], "2. Updating database configuration (UpdateDBCfg)")

    # 3. CheckConfig
    run_1c(["/CheckConfig", "-Config", "-ThinClient"], "3. Verifying configuration integrity (CheckConfig)")

    # 4. DumpIB
    run_1c(["/DumpIB", str(OUT_DT)], "4. Exporting Infobase to DT package (DumpIB)")

    if OUT_DT.exists():
        size = OUT_DT.stat().st_size
        size_mb = round(size / (1024 * 1024), 2)
        print(f"\n========================================================")
        print(f"SUCCESS: Package created successfully!")
        print(f"File: {OUT_DT}")
        print(f"Size: {size_mb} MB ({size} bytes)")
        print(f"========================================================")
    else:
        print("ERROR: Output DT file not found!")
        sys.exit(1)


if __name__ == "__main__":
    main()
