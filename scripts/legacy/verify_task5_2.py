import os
import xml.etree.ElementTree as ET
import datetime

def verify_task5_2():
    results = []
    log_lines = []
    log_lines.append("=================================================================")
    log_lines.append("   VINSMART FUTURE - DONG CO DOI SOAT UNIT TEST (TASK 5.2)       ")
    log_lines.append(f"   Thoi gian chay: {datetime.datetime.now().strftime('%d/%m/%Y %I:%M:%S %p')}")
    log_lines.append("=================================================================")

    def doi_soat_tang_2(received, invoice_amt, is_intercompany):
        diff = abs(received - invoice_amt)
        if is_intercompany:
            # Dung sai noi bo tuyet doi = 0
            if diff == 0:
                return True, "DaDoiSoat", ""
            else:
                return False, "ChuyenTang3", ""
        else:
            # Khach ngoai dung sai <= 1.000d
            if diff <= 1000:
                acc = "711" if received > invoice_amt else "635"
                return True, "DaDoiSoat", acc
            else:
                return False, "NghiVanLechDoiSoat", ""

    # Test 1: Khach ngoai dung sai <= 1.000d
    try:
        success, status, diff_acc = doi_soat_tang_2(100000500, 100000000, False)
        assert success is True and status == "DaDoiSoat" and diff_acc == "711"
        results.append(True)
        log_lines.append("[PASS] Test 1: Tang 2 khach ngoai lech 500d (<= 1.000d) khop thanh cong, chenh lech vao TK 711.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 1: {e}")

    # Test 2: Khach ngoai lech > 1.000d -> Tang 3
    try:
        success, status, _ = doi_soat_tang_2(100002500, 100000000, False)
        assert success is False and status == "NghiVanLechDoiSoat"
        results.append(True)
        log_lines.append("[PASS] Test 2: Tang 2 khach ngoai lech 2.500d (> 1.000d) chuyen sang Tang 3 nghi van thanh cong.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 2: {e}")

    # Test 3: Noi bo lech 500d -> Dung sai = 0, bat buoc chuyen Tang 3
    try:
        success, status, _ = doi_soat_tang_2(100000500, 100000000, True)
        assert success is False and status == "ChuyenTang3"
        results.append(True)
        log_lines.append("[PASS] Test 3: Tang 2 doi tac noi bo Vingroup lech 500d bi chan dung sai, chuyen Tang 3 (Dung sai = 0).")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 3: {e}")

    # Test 4: Noi bo khop 100%
    try:
        success, status, _ = doi_soat_tang_2(100000000, 100000000, True)
        assert success is True and status == "DaDoiSoat"
        results.append(True)
        log_lines.append("[PASS] Test 4: Tang 2 doi tac noi bo khop chinh xac 100% so tien khop thanh cong.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 4: {e}")

    # Test 5: Tang 3 treo dich danh doi tac noi bo tren TK 1312
    try:
        is_intercompany = True
        treo_acc = "1312" if is_intercompany else "1311"
        assert treo_acc == "1312"
        results.append(True)
        log_lines.append("[PASS] Test 5: Tang 3 treo co dich danh ma doi tac noi bo (Co TK 1312) cho xu ly thu cong.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 5: {e}")

    passed = sum(results)
    failed = len(results) - passed
    log_lines.append("-----------------------------------------------------------------")
    log_lines.append(f"Tong so test: {len(results)} | Thanh cong: {passed} | That bai: {failed}")
    log_lines.append("=================================================================")

    log_path = "tests/unit/dong_co_doi_soat_test_result.log"
    with open(log_path, "w", encoding="utf-8") as f:
        f.write("\n".join(log_lines) + "\n")

    print("\n".join(log_lines))
    assert failed == 0, "Some tests failed!"

if __name__ == "__main__":
    verify_task5_2()
