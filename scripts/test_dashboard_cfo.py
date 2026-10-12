# -*- coding: utf-8 -*-
"""
Test Suite: test_dashboard_cfo.py
Dự án: VinSmart Future - AR & AP Management (Hệ thống tập trung 1C thuần nhất)
Mục tiêu:
    Kiểm thử DataProcessor.DashboardLanhDaoCFO:
    - Truy vấn số liệu thời gian thực cho Ban Giám đốc & CFO độc lập trên 1C.
    - Tổng hợp KPI Doanh thu & Chi phí theo 4 Khối kinh doanh VSF (Khối I, II, III, IV) và Khối BO.
    - Tổng hợp Số dư công nợ AR (TK 131: 1311, 1312) và AP (TK 331: 3311, 3312).
    - Tổng hợp Dòng tiền tài khoản Techcombank VND, Vietcombank USD, VPBank Virtual Account.
    - Tính toán chỉ số tài chính: DSO, DPO, Chu kỳ tiền mặt (CCC), Tỷ lệ tiết kiệm thanh khoản qua Netting.
"""

import os
import sys
import io
import subprocess
import glob

if sys.stdout.encoding != 'utf-8':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

def test_dashboard_cfo():
    exe = r"C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe"
    ib = r"C:\Users\Dung\Documents\1C_Enterprise\Infobase_FullData"
    
    assert os.path.exists(exe), f"1C binary không tồn tại: {exe}"
    assert os.path.exists(ib), f"Infobase không tồn tại: {ib}"

    print("=================================================================")
    print("   CHẠY KIỂM THỬ: EXECUTIVE DASHBOARD CFO (1C DUY NHẤT TẬP TRUNG)")
    print("=================================================================")
    
    # Chạy 1C Enterprise với LaunchParameter = TestDashboardCFO
    p = subprocess.run([
        exe, "ENTERPRISE",
        "/F", ib,
        "/N", "Admin",
        "/C", "TestDashboardCFO",
        "/DisableStartupDialogs", "/DisableStartupMessages"
    ], capture_output=True, timeout=90)

    log_dir = os.path.join(ib, "1Cv8Log")
    assert os.path.exists(log_dir), "Chưa có thư mục 1Cv8Log"
    
    lgp_files = sorted(glob.glob(os.path.join(log_dir, "*.lgp")))
    assert len(lgp_files) > 0, "Không tìm thấy file .lgp nhật ký sự kiện"
    
    latest_lgp = lgp_files[-1]
    with open(latest_lgp, "r", encoding="utf-8", errors="ignore") as f:
        log_content = f.read()

    # Trích xuất các dòng log liên quan
    lines = log_content.splitlines()
    relevant_lines = [l for l in lines if any(k in l for k in [
        "DASHBOARD_VERIFY", "DASHBOARD_CFO_ALL_TESTS_PASS",
        "Khối kinh doanh", "Công nợ AR", "Dòng tiền ngân hàng", "Chỉ số tài chính"
    ])]

    print("\n[*] Chi tiết kết quả kiểm thử từ Nhật ký sự kiện 1C:")
    for line in relevant_lines[-15:]:
        clean_line = line.strip().strip('"')
        if clean_line.startswith('{'):
            comma_idx = clean_line.find(',"')
            if comma_idx != -1:
                clean_line = clean_line[comma_idx+2:]
        print(f"    {clean_line}")

    # Assertions
    assert "DASHBOARD_VERIFY_SUCCESS" in log_content, (
        "FAIL: Dashboard CFO không truy vấn thành công số liệu! Chi tiết:\n" +
        "\n".join([l for l in lines if "Dashboard" in l or "DASHBOARD" in l][-10:])
    )
    print("\n[+] PASS 1: Dashboard CFO tổng hợp thành công 4 Khối kinh doanh VSF & Khối BO, AR/AP, Dòng tiền và Chỉ số DSO/DPO/Netting!")

    assert "DASHBOARD_CFO_ALL_TESTS_PASS" in log_content, (
        "FAIL: Chưa đạt chứng nhận hoàn tất kiểm thử Dashboard CFO!"
    )
    print("[+] PASS 2: Xác nhận kiểm thử toàn diện Bàn làm việc CFO 1C thuần nhất PASS 100%!")
    print("=================================================================\n")

if __name__ == "__main__":
    try:
        test_dashboard_cfo()
    except Exception as e:
        print(f"\nFAIL: {e}")
        sys.exit(1)
