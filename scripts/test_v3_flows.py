#!/usr/bin/env python3
"""
Test runner for AR & AP Core Flows (Demo V3):
1. Creates disposable temporary 1C Infobase
2. Loads configuration from src/
3. Updates DB structure
4. Runs /C "RunSeedBoundaries;test_run;<result_file>"
5. Verifies all 3 core test cases PASS
6. Cleans up temporary test Infobase
"""
import os
import sys
import uuid
import json
import shutil
import subprocess

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC_DIR = os.path.join(REPO_ROOT, "src")
TEMP_IB_DIR = os.path.join(REPO_ROOT, "build_test_tmp")

ONEC_EXE = r"C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe"
if not os.path.exists(ONEC_EXE):
    # Search default path
    default_exe = r"C:\Program Files\1cv8\current\bin\1cv8.exe"
    if os.path.exists(default_exe):
        ONEC_EXE = default_exe

def run_cmd(args, desc):
    cmd_str = " ".join(f'"{a}"' if " " in a else a for a in args)
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
    print("=" * 60)
    print("TEST SUITE: AR & AP CORE WORKFLOWS (DEMO V3)")
    print("=" * 60)

    if os.path.exists(TEMP_IB_DIR):
        shutil.rmtree(TEMP_IB_DIR, ignore_errors=True)
    os.makedirs(TEMP_IB_DIR, exist_ok=True)
    ib_path = os.path.join(TEMP_IB_DIR, "IB")
    result_path = os.path.join(TEMP_IB_DIR, "results.json")
    run_id = uuid.uuid4().hex

    try:
        # 1. CREATE INFOBASE
        run_cmd([ONEC_EXE, "CREATEINFOBASE", f"File={ib_path};Locale=en_US;"], "Create temporary Infobase")

        # 2. LOAD CONFIG
        run_cmd([ONEC_EXE, "DESIGNER", "/F", ib_path, "/LoadConfigFromFiles", SRC_DIR], "Load configuration from src/")

        # 3. UPDATE DB
        run_cmd([ONEC_EXE, "DESIGNER", "/F", ib_path, "/UpdateDBCfg"], "Update DB Configuration")

        # 4. RUN BOUNDARIES / BUSINESS LOGIC TESTS
        cmd_arg = f"RunSeedBoundaries;{run_id};{result_path}"
        print(f"[*] Executing 1C Enterprise Runtime: /C {cmd_arg}...")
        res = subprocess.run([
            ONEC_EXE, "ENTERPRISE",
            "/F", ib_path,
            "/C", cmd_arg,
            "/DisableStartupMessages",
            "/DisableStartupDialogs"
        ], capture_output=True, text=True, timeout=90)

        # 5. VERIFY RESULTS
        if not os.path.exists(result_path):
            raise RuntimeError(f"Result file not created at {result_path}")

        with open(result_path, "r", encoding="utf-8") as f:
            data = json.load(f)

        print("\n" + "=" * 60)
        print("VERIFICATION RESULTS:")
        print("=" * 60)
        status = data.get("status")
        cases = data.get("cases", [])
        all_passed = True
        for c in cases:
            c_name = c.get("name")
            c_passed = c.get("passed")
            c_err = c.get("error", "")
            mark = "[PASS]" if c_passed else "[FAIL]"
            print(f"{mark} {c_name}: {c_err if not c_passed else 'OK'}")
            if not c_passed:
                all_passed = False

        print("=" * 60)
        if status == "PASS" and all_passed:
            print(">> SUCCESS: ALL AR & AP V3 TESTS PASSED 100% <<")
        else:
            print(">> FAILURE: SOME TESTS FAILED <<")
            sys.exit(1)

    finally:
        shutil.rmtree(TEMP_IB_DIR, ignore_errors=True)
        print("[*] Cleaned up temporary test infobase.")

if __name__ == "__main__":
    main()
