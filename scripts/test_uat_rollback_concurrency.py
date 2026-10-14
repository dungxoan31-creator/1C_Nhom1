# -*- coding: utf-8 -*-
"""
Test Suite: test_uat_rollback_concurrency.py
Dự án: VinSmart Future - AR & AP Management
Mục tiêu:
    - Chứng minh UAT trên 1C runtime thực tế:
      + Kịch bản 1: Rollback transaction atomic khi lỗi -> 0 bản ghi rác trong GL/Sổ phụ.
      + Kịch bản 2: DataLock độc quyền (Exclusive Lock) ngăn chặn race condition.
      + Kịch bản 3: BeforeWrite FSM guard chặn sửa trực tiếp trạng thái chứng từ Posted.
"""

import os
import sys
import io
import subprocess
import glob

if sys.stdout.encoding != 'utf-8':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

ONEC_EXE = r"C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe"
IB_PATH = r"C:\Users\Dung\Documents\1C_Enterprise\Infobase_FullData"

def kill_1c():
    subprocess.run(
        ["powershell", "-Command", "Stop-Process -Name '1cv8*' -Force -ErrorAction SilentlyContinue"],
        capture_output=True,
        text=True,
    )

def read_latest_event_log():
    log_dir = os.path.join(IB_PATH, "1Cv8Log")
    lgp_files = sorted(glob.glob(os.path.join(log_dir, "*.lgp")))
    assert len(lgp_files) > 0, "Không tìm thấy file nhật ký sự kiện .lgp"
    with open(lgp_files[-1], "r", encoding="utf-8", errors="ignore") as f:
        return f.read()

def run_uat_proof():
    assert os.path.exists(ONEC_EXE), f"1C binary không tồn tại: {ONEC_EXE}"
    assert os.path.exists(IB_PATH), f"Infobase không tồn tại: {IB_PATH}"

    print("=" * 70)
    print("   KIỂM THỬ UAT RUNTIME: ROLLBACK, CONCURRENCY & FSM STATE GUARD")
    print("   Infobase: Infobase_FullData | User: ketoan_truong")
    print("=" * 70)

    kill_1c()
    cmd = [
        ONEC_EXE,
        "ENTERPRISE",
        "/F", IB_PATH,
        "/N", "ketoan_truong",
        "/P", "",
        "/C", "RunUATSecurityProof",
        "/DisableStartupMessages",
        "/DisableStartupDialogs"
    ]
    print("[*] Executing 1C Enterprise with command: RunUATSecurityProof...")
    res = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
    print(f"    Exit code: {res.returncode}")
    assert res.returncode == 0, f"1C returned non-zero exit code: {res.returncode}"

    log_content = read_latest_event_log()
    lines = log_content.splitlines()

    print("\n[*] Chi tiết kết quả kiểm thử từ Nhật ký sự kiện 1C:")
    relevant = [l for l in lines if any(k in l for k in [
        "UAT_ROLLBACK_ATOMIC_VERIFIED",
        "UAT_DATALOCK_CONCURRENCY_VERIFIED",
        "UAT_STATE_GUARD_VERIFIED",
        "UAT_ROLLBACK_CONCURRENCY_ALL_PASS",
        "Kich ban 1", "Kich ban 2", "Kich ban 3"
    ])]
    for l in relevant:
        clean = l.strip().strip('"')
        if clean.startswith('{'):
            idx = clean.find(',"')
            if idx != -1:
                clean = clean[idx+2:]
        print(f"    {clean}")

    assert "UAT_ROLLBACK_ATOMIC_VERIFIED" in log_content, (
        "FAIL: Kịch bản 1 (Rollback Atomic) chưa đạt chứng nhận!"
    )
    print("\n[+] PASS 1: Kịch bản 1 (Rollback Atomic khi lỗi) đã xác minh thành công trên 1C runtime!")

    assert "UAT_DATALOCK_CONCURRENCY_VERIFIED" in log_content, (
        "FAIL: Kịch bản 2 (Exclusive DataLock Concurrency) chưa đạt chứng nhận!"
    )
    print("[+] PASS 2: Kịch bản 2 (DataLock độc quyền ngăn Race Condition) đã xác minh thành công!")

    assert "UAT_STATE_GUARD_VERIFIED" in log_content, (
        "FAIL: Kịch bản 3 (BeforeWrite FSM State Guard) chưa đạt chứng nhận!"
    )
    print("[+] PASS 3: Kịch bản 3 (Chặn sửa trực tiếp trạng thái chứng từ Posted) đã xác minh thành công!")

    assert "UAT_ROLLBACK_CONCURRENCY_ALL_PASS" in log_content, (
        "FAIL: Toàn bộ suite UAT Rollback & Concurrency chưa đạt PASS 100%!"
    )
    print("\n" + "=" * 70)
    print("OVERALL RESULT: [PASS 100%] UAT Rollback, Concurrency & FSM Guard VERIFIED.")
    print("=" * 70)

if __name__ == "__main__":
    run_uat_proof()
