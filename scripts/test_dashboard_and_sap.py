# -*- coding: utf-8 -*-
"""
Test Suite: test_dashboard_and_sap.py
Dự án: VinSmart Future - AR & AP Management
Mục tiêu:
    1. Kiểm thử DataProcessor.DashboardLanhDaoCFO:
       - Truy vấn số liệu thời gian thực cho Ban Giám đốc & CFO.
       - Tổng hợp KPI Doanh thu & Chi phí theo 4 Khối kinh doanh VSF (Khối I, II, III, IV) và Khối BO.
       - Tổng hợp Số dư công nợ AR (TK 131: 1311, 1312) và AP (TK 331: 3311, 3312).
       - Tổng hợp Dòng tiền tài khoản Techcombank VND, Vietcombank USD, VPBank Virtual Account.
       - Tính toán chỉ số tài chính: DSO, DPO, Chu kỳ tiền mặt (CCC), Tỷ lệ tiết kiệm thanh khoản qua Netting.
    2. Kiểm thử DataProcessor.DongBoButToanSAP:
       - Trích xuất bút toán từ Sổ Cái SoCaiKeToan.
       - Đóng gói chuẩn SAP FI-GL IDoc/RFC/BAPI (Header, Items, Tax, Currency).
       - Kiểm tra Invariant cân đối tuyệt đối Debit = Credit (chặn 100% bút toán lệch sổ).
       - Mô phỏng đồng bộ batch sang SAP ERP thành công có Audit Trail.
"""

import os
import sys
import io
import subprocess
import glob

if sys.stdout.encoding != 'utf-8':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

def test_dashboard_and_sap():
    exe = r"C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe"
    ib = r"C:\Users\Dung\Documents\1C_Enterprise\Infobase_FullData"
    
    assert os.path.exists(exe), f"1C binary không tồn tại: {exe}"
    assert os.path.exists(ib), f"Infobase không tồn tại: {ib}"

    print("=================================================================")
    print("   CHẠY KIỂM THỬ: EXECUTIVE DASHBOARD CFO & TÍCH HỢP SAP ERP    ")
    print("=================================================================")
    
    # Chạy 1C Enterprise với LaunchParameter = TestDashboardAndSAP
    p = subprocess.run([
        exe, "ENTERPRISE",
        "/F", ib,
        "/N", "Admin",
        "/C", "TestDashboardAndSAP",
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
        "DASHBOARD_VERIFY", "SAP_SYNC_VERIFY", "DASHBOARD_AND_SAP_ALL_TESTS_PASS",
        "Khối kinh doanh", "Công nợ AR", "Dòng tiền ngân hàng", "Chỉ số tài chính",
        "Đóng gói SAP", "chốt an toàn", "Gửi batch sang SAP"
    ])]

    print("\n[*] Chi tiết kết quả kiểm thử từ Nhật ký sự kiện 1C:")
    for line in relevant_lines[-20:]:
        # Format log line cleanly
        clean_line = line.strip().strip('"')
        if clean_line.startswith('{'):
            # Skip raw lgp event header if present
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

    assert "SAP_SYNC_VERIFY_SUCCESS" in log_content, (
        "FAIL: Đồng bộ SAP ERP không thành công! Chi tiết:\n" +
        "\n".join([l for l in lines if "SAP" in l or "SAP_SYNC" in l][-10:])
    )
    print("[+] PASS 2: Module Đồng bộ SAP trích xuất Sổ Cái, đóng gói payload FI-GL IDoc/RFC và bảo vệ cân đối Debit = Credit chuẩn 100%!")

    assert "DASHBOARD_AND_SAP_ALL_TESTS_PASS" in log_content, (
        "FAIL: Chưa đạt chứng nhận hoàn tất toàn bộ kiểm thử!"
    )
    print("[+] PASS 3: Xác nhận kiểm thử toàn diện Bàn làm việc CFO và Tích hợp SAP ERP PASS 100%!")
    print("=================================================================\n")

if __name__ == "__main__":
    try:
        test_dashboard_and_sap()
    except Exception as e:
        print(f"\nFAIL: {e}")
        sys.exit(1)
