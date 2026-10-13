# -*- coding: utf-8 -*-
import os
import sys
import io
import subprocess

if sys.stdout.encoding != 'utf-8':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

def test_ledger_integrity():
    exe = r"C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe"
    ib = r"C:\Users\Dung\Documents\1C_Enterprise\Infobase_FullData"
    
    assert os.path.exists(ib), f"Infobase không tồn tại: {ib}"

    # Launch 1C to verify Full Test Data and Ledger Integrity
    p = subprocess.run([
        exe, "ENTERPRISE",
        "/F", ib,
        "/N", "Admin",
        "/C", "VerifyFullTestData",
        "/DisableStartupDialogs", "/DisableStartupMessages"
    ], capture_output=True, timeout=60)
    
    log_dir = os.path.join(ib, "1Cv8Log")
    assert os.path.exists(log_dir), "Chưa có thư mục 1Cv8Log"
    
    lgp_files = sorted([os.path.join(log_dir, f) for f in os.listdir(log_dir) if f.endswith(".lgp")])
    assert len(lgp_files) > 0, "Không tìm thấy file .lgp nhật ký sự kiện"
    
    latest_lgp = lgp_files[-1]
    with open(latest_lgp, "r", encoding="utf-8", errors="ignore") as f:
        log_content = f.read()

    # Search for verification log
    assert "TONG SO CHUNG TU DA GHI SO HOP LE" in log_content, (
        "Không tìm thấy log tổng số chứng từ trong Nhật ký sự kiện 1C!"
    )
    
    # Extract total document count
    lines = log_content.splitlines()
    total_docs = 0
    for line in lines:
        if "TONG SO CHUNG TU DA GHI SO HOP LE:" in line:
            parts = line.split("TONG SO CHUNG TU DA GHI SO HOP LE:")
            if len(parts) > 1:
                try:
                    total_docs = int(parts[1].strip().split()[0].replace('"', '').replace(',', ''))
                except:
                    pass
    
    print(f"[*] Tổng số chứng từ kế toán ghi sổ đã kiểm tra: {total_docs}")
    assert total_docs >= 5000, f"Tổng số chứng từ chưa đạt chỉ tiêu (Yêu cầu >= 5000, thực tế: {total_docs})"
    
    # Kiem tra doi soat doc lap GL va Subledger AR / AP
    assert "DELTA_AR = 0" in log_content, "Phát hiện chênh lệch đối soát độc lập GL TK 131 và Subledger AR (DELTA_AR != 0)!"
    assert "DELTA_AP = 0" in log_content, "Phát hiện chênh lệch đối soát độc lập GL TK 331 và Subledger AP (DELTA_AP != 0)!"
    assert "DELTA = 0" in log_content, "Sổ cái kế toán không cân đối (DELTA != 0)!"
    
    print("[*] Đối soát độc lập Sổ Cái (GL TK 131) với Sổ chi tiết Phải thu AR: DELTA_AR = 0 (Khớp 100%)")
    print("[*] Đối soát độc lập Sổ Cái (GL TK 331) với Sổ chi tiết Phải trả AP: DELTA_AP = 0 (Khớp 100%)")
    print(f"PASS: Toàn bộ hệ thống kế toán 1C cân đối tuyệt đối 100%! Tổng số chứng từ: {total_docs} (>= 5,000)")

if __name__ == "__main__":
    try:
        test_ledger_integrity()
    except Exception as e:
        print(f"FAIL: {e}")
        sys.exit(1)
