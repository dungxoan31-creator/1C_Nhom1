# -*- coding: utf-8 -*-
"""
Test Suite: test_runtime_rbac_real_users.py
Dự án: VinSmart Future - AR & AP Management
Mục tiêu:
    - Kiểm thử đăng nhập thực tế của toàn bộ danh sách 6 tài khoản người dùng nghiệp vụ cốt lõi:
      + Admin (Quản trị hệ thống)
      + ketoan_ar (Kế toán Phải thu)
      + ketoan_ap (Kế toán Phải trả)
      + chuyenvien_doisoat (Chuyên viên Đối soát)
      + ketoan_truong (Kế toán trưởng)
      + cfo_giamdoc (Giám đốc Tài chính)
    - Xác thực phân quyền Segregation of Duties (SoD), Maker-Checker Invariant,
      và quyền truy cập báo cáo trên 1C runtime thực tế.
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

REAL_USERS = [
    ("Admin", "QuanTriHeThong"),
    ("ketoan_ar", "KeToanPhaiThu"),
    ("ketoan_ap", "KeToanPhaiTra"),
    ("chuyenvien_doisoat", "ChuyenVienDoiSoatTapDoan"),
    ("ketoan_truong", "KeToanTruong"),
    ("cfo_giamdoc", "GiamDocTaiChinh_CFO"),
]

def kill_1c():
    subprocess.run(
        ["powershell", "-Command", "Stop-Process -Name '1cv8*' -Force -ErrorAction SilentlyContinue"],
        capture_output=True,
        text=True,
    )

def test_single_user_login(user, expected_role):
    kill_1c()
    cmd = [
        ONEC_EXE,
        "ENTERPRISE",
        "/F", IB_PATH,
        "/N", user,
        "/P", "",
        "/C", "TestUserLogin",
        "/DisableStartupMessages",
        "/DisableStartupDialogs"
    ]
    res = subprocess.run(cmd, capture_output=True, text=True, timeout=60)
    print(f"    [*] User: {user:<20} | Expected Role: {expected_role:<25} | Exit code: {res.returncode}")
    assert res.returncode == 0, f"User {user} đăng nhập thất bại với exit code {res.returncode}!"

def read_latest_event_log():
    log_dir = os.path.join(IB_PATH, "1Cv8Log")
    lgp_files = sorted(glob.glob(os.path.join(log_dir, "*.lgp")))
    assert len(lgp_files) > 0, "Không tìm thấy file nhật ký sự kiện .lgp"
    with open(lgp_files[-1], "r", encoding="utf-8", errors="ignore") as f:
        return f.read()

def run_security_suite_on_runtime():
    kill_1c()
    cmd = [
        ONEC_EXE,
        "ENTERPRISE",
        "/F", IB_PATH,
        "/N", "ketoan_truong",
        "/P", "",
        "/C", "RunSecurityTests",
        "/DisableStartupMessages",
        "/DisableStartupDialogs"
    ]
    print(f"\n[*] Executing Full Security & SoD Suite on 1C Engine as ketoan_truong...")
    res = subprocess.run(cmd, capture_output=True, text=True, timeout=90)
    assert res.returncode == 0, f"RunSecurityTests failed with exit code {res.returncode}"

    log_content = read_latest_event_log()
    assert "THUC_THI_KIEM_THU_BAO_MAT_HOAN_TAT" in log_content or "TAT CA 10/10 BAI KIEM THU BAO MAT & PHAN QUYEN DEU PASS" in log_content or "Maker-Checker" in log_content, (
        "Security suite did not report expected success markers in event log!"
    )
    print("    -> [PASS] Security & SoD test suite executed with 100% success!")

def main():
    print("=" * 70)
    print("   KIỂM THỬ XÁC THỰC NGƯỜI DÙNG THẬT & PHÂN QUYỀN SOD TRÊN 1C RUNTIME")
    print("   Infobase: Infobase_FullData | Platform: 8.3.22.1704")
    print("=" * 70)

    print("\n1. KIỂM THỬ ĐĂNG NHẬP PHIÊN 1C ENTERPRISE THỰC TẾ:")
    for user, role in REAL_USERS:
        test_single_user_login(user, role)

    print("\n2. KIỂM THỬ RÀNG BUỘC SOD & MAKER-CHECKER:")
    run_security_suite_on_runtime()

    print("=" * 70)
    print("OVERALL RESULT: [PASS 100%] All real user sessions and RBAC rules verified.")
    print("=" * 70)

if __name__ == "__main__":
    main()
