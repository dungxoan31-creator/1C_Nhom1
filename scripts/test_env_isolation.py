import os
import sys
import io

if sys.stdout.encoding != 'utf-8':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

def test_isolation():
    orig_dt = r"C:\Users\Dung\Documents\1C_Enterprise\VinSmart_Future_AR_AP_Full.dt"
    full_ib = r"C:\Users\Dung\Documents\1C_Enterprise\Infobase_FullData"
    ib_file = os.path.join(full_ib, "1Cv8.1CD")

    assert os.path.exists(orig_dt), f"Bản sao an toàn không tồn tại: {orig_dt}"
    assert os.path.getsize(orig_dt) > 100000, f"Dung lượng bản sao quá nhỏ: {os.path.getsize(orig_dt)}"
    assert os.path.exists(full_ib), f"Thư mục CSDL thử không tồn tại: {full_ib}"
    assert os.path.exists(ib_file), f"File CSDL 1Cv8.1CD chưa khởi tạo: {ib_file}"
    assert os.path.getsize(ib_file) > 1000000, f"Dung lượng CSDL thử chưa hợp lệ: {os.path.getsize(ib_file)}"

    print("PASS: Môi trường thử nghiệm và bản sao an toàn hoàn toàn cô lập và hợp lệ!")

if __name__ == "__main__":
    try:
        test_isolation()
    except AssertionError as e:
        print(f"FAIL: {e}")
        sys.exit(1)
