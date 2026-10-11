# -*- coding: utf-8 -*-
import os
import sys
import io
import subprocess

if sys.stdout.encoding != 'utf-8':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

def test_netting_data():
    exe = r"C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe"
    ib = r"C:\Users\Dung\Documents\1C_Enterprise\Infobase_FullData"
    
    assert os.path.exists(ib), f"Infobase không tồn tại: {ib}"

    # Launch 1C to verify Netting Data
    p = subprocess.run([
        exe, "ENTERPRISE",
        "/F", ib,
        "/N", "Admin",
        "/C", "VerifyNettingData",
        "/DisableStartupDialogs", "/DisableStartupMessages"
    ], capture_output=True, timeout=60)
    
    log_dir = os.path.join(ib, "1Cv8Log")
    assert os.path.exists(log_dir), "Chưa có thư mục 1Cv8Log"
    
    lgp_files = sorted([os.path.join(log_dir, f) for f in os.listdir(log_dir) if f.endswith(".lgp")])
    assert len(lgp_files) > 0, "Không tìm thấy file .lgp nhật ký sự kiện"
    
    latest_lgp = lgp_files[-1]
    with open(latest_lgp, "r", encoding="utf-8", errors="ignore") as f:
        log_content = f.read()

    assert "NETTING_VERIFY_SUCCESS" in log_content, (
        "Không tìm thấy xác nhận NETTING_VERIFY_SUCCESS trong Nhật ký sự kiện 1C! Chi tiết:\n" +
        "\n".join([line for line in log_content.splitlines() if "NETTING_VERIFY" in line][-5:])
    )
    print("PASS: Toàn bộ chứng từ Netting & Đối soát kênh thanh toán đã ghi sổ thành công!")

if __name__ == "__main__":
    try:
        test_netting_data()
    except Exception as e:
        print(f"FAIL: {e}")
        sys.exit(1)
