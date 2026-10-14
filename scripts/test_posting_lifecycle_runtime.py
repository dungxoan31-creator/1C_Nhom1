# -*- coding: utf-8 -*-
"""
Verification Script: Kiểm thử Runtime chu trình Ghi sổ (Post -> Unpost -> Repost) & Đối chiếu GL - Sổ phụ
Yêu cầu:
1. Thực thi chu trình Post -> Unpost -> Repost trên các chứng từ tài chính trên 1C engine thật
2. Chứng minh khi Hủy ghi sổ (Unpost), toàn bộ bút toán GL và Sổ phụ triệt tiêu về 0 (Zero Residual)
3. Chứng minh khi Ghi sổ lại (Repost), dữ liệu tái tạo chính xác 100%
4. Kiểm chứng đối chiếu độc lập Sổ Cái vs Sổ Phụ (AR, AP, Bank) cân đối Delta = 0
"""

import os
import sys
import io
import subprocess

if sys.stdout.encoding != 'utf-8':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
EXE_PATH = r"C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe"
IB_PATH = os.path.join(ROOT_DIR, "Infobase_FullData")
LOG_PATH = os.path.join(ROOT_DIR, "test_posting_lifecycle.log")

def run_lifecycle_test():
    print("\n--- KIỂM THỬ RUNTIME: POST -> UNPOST -> REPOST & ĐỐI CHIẾU GL - SỔ PHỤ ---")
    if os.path.exists(LOG_PATH):
        try: os.remove(LOG_PATH)
        except: pass
        
    cmd = [
        EXE_PATH, "ENTERPRISE",
        "/F", IB_PATH,
        "/N", "ketoan_truong",
        "/C", "RunPostingLifecycleTests",
        "/DisableStartupDialogs",
        "/DisableStartupMessages"
    ]
    
    p = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8", errors="ignore", timeout=90)
    
    assert os.path.exists(LOG_PATH), (
        f"Không tìm thấy file log kết quả kiểm thử {LOG_PATH}! Lệnh chưa hoàn tất trên 1C."
    )
    
    with open(LOG_PATH, "r", encoding="utf-8") as f:
        log_content = f.read()
        
    print(log_content)
    
    assert "POSTING_LIFECYCLE_ALL_PASS" in log_content, (
        "Kiểm thử chu trình ghi sổ thất bại! Xem log chi tiết ở trên."
    )
    assert "ZERO_RESIDUAL_VERIFIED" in log_content, (
        "Thất bại kiểm tra triệt tiêu về 0 khi hủy ghi sổ!"
    )
    assert "REPOST_PARITY_VERIFIED" in log_content, (
        "Thất bại kiểm tra tính tương đương khi ghi sổ lại!"
    )
    assert "GL_SUBLEDGER_DELTA_ZERO" in log_content, (
        "Thất bại đối chiếu độc lập GL vs Sổ phụ!"
    )
    
    print(">> PASS: Toàn bộ chu trình Post -> Unpost -> Repost và đối chiếu GL - Sổ phụ đã được xác minh 100% trên 1C runtime!\n")

if __name__ == "__main__":
    try:
        run_lifecycle_test()
    except AssertionError as e:
        print(f"FAILED: {e}")
        sys.exit(1)
