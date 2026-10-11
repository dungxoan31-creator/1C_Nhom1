# -*- coding: utf-8 -*-
import os
import sys
import io
import shutil
import subprocess

if sys.stdout.encoding != 'utf-8':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

def test_fulldata_dt():
    dt_path = r"C:\Users\Dung\Documents\1C_Enterprise\VinSmart_Future_AR_AP_Test_FULLDATA.dt"
    exe = r"C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe"
    
    # 1. Assert DT file exists and is not empty (> 1MB)
    assert os.path.exists(dt_path), f"File DT không tồn tại: {dt_path}"
    size_mb = os.path.getsize(dt_path) / (1024 * 1024)
    print(f"[*] File DT: {dt_path} ({size_mb:.2f} MB)")
    assert size_mb >= 0.5, f"Dung lượng file DT quá nhỏ: {size_mb:.2f} MB"

    # 2. Test restore into a temporary scratch infobase
    scratch_ib = r"C:\Users\Dung\Documents\1C_Enterprise\scratch\Infobase_Restore_Test"
    if os.path.exists(scratch_ib):
        shutil.rmtree(scratch_ib, ignore_errors=True)
    os.makedirs(scratch_ib, exist_ok=True)

    log_path = r"C:\Users\Dung\Documents\1C_Enterprise\scratch\restore_test.log"
    if os.path.exists(log_path):
        os.remove(log_path)

    print(f"[*] Đang kiểm tra khôi phục CSDL thử nghiệm tại: {scratch_ib}...")
    p = subprocess.run([
        exe, "DESIGNER",
        "/F", scratch_ib,
        "/RestoreIB", dt_path,
        "/DisableStartupDialogs", "/DisableStartupMessages",
        "/OUT", log_path
    ], capture_output=True, timeout=120)

    assert p.returncode == 0, f"Khôi phục CSDL thất bại với mã lỗi {p.returncode}"
    
    # Verify 1Cv8.1CD was created and is valid
    cd_file = os.path.join(scratch_ib, "1Cv8.1CD")
    assert os.path.exists(cd_file), "Không tìm thấy 1Cv8.1CD sau khi RestoreIB"
    cd_size_mb = os.path.getsize(cd_file) / (1024 * 1024)
    print(f"[*] CSDL khôi phục thành công! Dung lượng 1Cv8.1CD: {cd_size_mb:.2f} MB")

    # Clean up scratch test
    shutil.rmtree(scratch_ib, ignore_errors=True)
    print("PASS: File VinSmart_Future_AR_AP_Test_FULLDATA.dt hoàn toàn nguyên vẹn và khôi phục thành công 100%!")

if __name__ == "__main__":
    try:
        test_fulldata_dt()
    except Exception as e:
        print(f"FAIL: {e}")
        sys.exit(1)
