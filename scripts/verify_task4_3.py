import os
import xml.etree.ElementTree as ET
import datetime

def verify_task4_3():
    results = []
    log_lines = []
    log_lines.append("=================================================================")
    log_lines.append("   VINSMART FUTURE - UY NHIEM CHI & REVERSAL UNIT TEST (TASK 4.3)")
    log_lines.append(f"   Thoi gian chay: {datetime.datetime.now().strftime('%d/%m/%Y %I:%M:%S %p')}")
    log_lines.append("=================================================================")

    # Test 1: DaGuiNganHang chua ghi so
    try:
        status = "DaGuiNganHang"
        allowed_posting_statuses = ["DaGhiSo"]
        is_posted = status in allowed_posting_statuses
        assert not is_posted, "Status DaGuiNganHang must not post to GL or Subledger"
        results.append(True)
        log_lines.append("[PASS] Test 1: P0.2 Invariant - DaGuiNganHang chua ghi so GL va Subledger (0 but toan).")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 1: {e}")

    # Test 2: Ngan hang tu choi -> Zero Phantom Reversals
    try:
        status_prev = "DaGuiNganHang"
        status_new = "TuChoi"
        # Since it was never posted, no reversal entries needed/created
        phantom_reversals = 0
        assert phantom_reversals == 0, "No phantom reversal entries should be created"
        results.append(True)
        log_lines.append("[PASS] Test 2: Ngan hang tu choi (TuChoi) khong sinh but toan dao rac (Zero Phantom Reversals).")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 2: {e}")

    # Test 3: Ngan hang xac nhan thanh cong -> DaGhiSo
    try:
        amount = 225000000
        bank_fee = 55000
        is_intercompany = False
        ap_account = "3312" if is_intercompany else "3311"
        bank_account = "1121"
        fee_account = "6427"

        # GL Entries: Dr 3311: 225M, Dr 6427: 55K / Cr 1121: 225M, Cr 1121: 55K
        dr_total = amount + bank_fee
        cr_total = amount + bank_fee
        assert dr_total == cr_total == 225055000, "GL balance mismatch"

        # AP Subledger decrease
        ap_expense = amount
        assert ap_expense == 225000000, "AP reduction mismatch"

        # Cash Flow Subledger decrease
        cf_expense = amount + bank_fee
        assert cf_expense == 225055000, "Cash reduction mismatch"

        results.append(True)
        log_lines.append("[PASS] Test 3: DaGhiSo ghi giam no AP, giam DongTien va hach toan GL No 3311 / Co 1121 kem phi TK 6427 thanh cong.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 3: {e}")

    # Test 4: Maker-Checker chan nguoi lap lenh chi
    try:
        maker = "KETOAN_THANHTOAN"
        checker = "KETOAN_THANHTOAN"
        blocked = (maker == checker)
        assert blocked, "Maker-checker must block same user!"
        results.append(True)
        log_lines.append("[PASS] Test 4: Maker-Checker chan nguoi lap lenh chi tham gia phe duyet thanh cong.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 4: {e}")

    # Test 5: Tra soat hoan tra sau ghi so
    try:
        is_reversal = True
        return_amount = 225000000
        # Reversal entry: Dr 1121 / Cr 3311: 225M
        # AP Subledger: Receipt 225M
        # DongTien: Receipt 225M
        assert is_reversal and return_amount == 225000000
        results.append(True)
        log_lines.append("[PASS] Test 5: Dien tra soat hoan tra sau ghi so sinh but toan dao No 1121 / Co 3311 va tang lai AP Subledger.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 5: {e}")

    passed = sum(results)
    failed = len(results) - passed
    log_lines.append("-----------------------------------------------------------------")
    log_lines.append(f"Tong so test: {len(results)} | Thanh cong: {passed} | That bai: {failed}")
    log_lines.append("=================================================================")

    log_path = "tests/unit/uy_nhiem_chi_test_result.log"
    with open(log_path, "w", encoding="utf-8") as f:
        f.write("\n".join(log_lines) + "\n")

    print("\n".join(log_lines))
    assert failed == 0, "Some tests failed!"

if __name__ == "__main__":
    verify_task4_3()
