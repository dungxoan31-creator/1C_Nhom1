# -*- coding: utf-8 -*-
"""
Verification Script: Kiểm kê Analytic Keys (Đối tác & Hợp đồng) trong Sổ Cái SoCaiKeToan
Yêu cầu:
1. Kết nối hoặc chạy query trên 1C runtime để kiểm kê 100% bản ghi SoCaiKeToan
2. Kiểm tra tỷ lệ hoàn tất điền DoiTacNo, DoiTacCo, HopDongNo, HopDongCo trên các tài khoản AR/AP
3. Báo cáo tỷ lệ đạt chuẩn 100.0%
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
LOG_PATH = os.path.join(ROOT_DIR, "verify_gl_keys.log")

def verify_analytic_keys():
    print("\n--- KIỂM KÊ ANALYTIC KEYS (ĐỐI TÁC & HỢP ĐỒNG) SỔ CÁI KẾ TOÁN ---")
    if os.path.exists(LOG_PATH):
        try: os.remove(LOG_PATH)
        except: pass
        
    cmd = [
        EXE_PATH, "ENTERPRISE",
        "/F", IB_PATH,
        "/N", "Admin",
        "/P", "Vsf@2026!Secure",
        "/C", "VerifyGLAnalyticKeys",
        "/DisableStartupDialogs",
        "/DisableStartupMessages"
    ]
    p = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8", errors="ignore", timeout=60)
    
    if not os.path.exists(LOG_PATH):
        # Fallback without password
        cmd_no_p = [
            EXE_PATH, "ENTERPRISE",
            "/F", IB_PATH,
            "/N", "Admin",
            "/C", "VerifyGLAnalyticKeys",
            "/DisableStartupDialogs",
            "/DisableStartupMessages"
        ]
        p = subprocess.run(cmd_no_p, capture_output=True, text=True, encoding="utf-8", errors="ignore", timeout=60)
        
    assert os.path.exists(LOG_PATH), (
        f"Không tìm thấy file log kết quả kiểm kê {LOG_PATH}! Có thể lệnh chưa được thực thi trong 1C."
    )
    
    with open(LOG_PATH, "r", encoding="utf-8") as f:
        log_content = f.read()
        
    print(log_content)
    assert "TY LE HOAN TAT: 100.0%" in log_content or "100.0% ANALYTIC KEYS POPULATED" in log_content, (
        "Kiểm kê thất bại: Vẫn còn bản ghi Sổ Cái thiếu Analytic Keys!"
    )
    print(">> PASS: 100% bản ghi Sổ Cái lịch sử đã được kiểm kê và có đầy đủ Analytic Keys!\n")

if __name__ == "__main__":
    try:
        verify_analytic_keys()
    except AssertionError as e:
        print(f"FAILED: {e}")
        sys.exit(1)
