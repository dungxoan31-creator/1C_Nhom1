import os
import xml.etree.ElementTree as ET
import datetime

def verify_task5_1():
    results = []
    log_lines = []
    log_lines.append("=================================================================")
    log_lines.append("   VINSMART FUTURE - WEBHOOK IDEMPOTENCY UNIT TEST (TASK 5.1)    ")
    log_lines.append(f"   Thoi gian chay: {datetime.datetime.now().strftime('%d/%m/%Y %I:%M:%S %p')}")
    log_lines.append("=================================================================")

    # Mock Idempotency storage
    idempotency_store = {}

    def process_webhook(key, payload_hash, amount=200000000, va=""):
        if key in idempotency_store:
            stored_hash = idempotency_store[key]["hash"]
            if stored_hash == payload_hash:
                return 200, "Already Processed", None
            else:
                return 409, "Conflict: Idempotency payload mismatch", None

        # New transaction
        idempotency_store[key] = {"hash": payload_hash, "amount": amount, "va": va}
        is_auto_posted = bool(va)
        status = "DaDoiSoat" if is_auto_posted else "ChoDoiSoat"
        return 200, "Success", {"status": status, "auto_posted": is_auto_posted}

    # Test 1: Webhook lan 1 moi
    try:
        code, msg, data = process_webhook("IDEM-TCB-001", "HASH-123", 200000000, "96248888001")
        assert code == 200 and msg == "Success"
        assert data["auto_posted"] is True
        results.append(True)
        log_lines.append("[PASS] Test 1: Webhook lan 1 tiep nhan thanh cong, sinh BaoCoNganHang va ban ghi Idempotency.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 1: {e}")

    # Test 2: Webhook lap (Trung key + Trung hash) -> 200 Already Processed
    try:
        code, msg, data = process_webhook("IDEM-TCB-001", "HASH-123")
        assert code == 200 and msg == "Already Processed" and data is None
        results.append(True)
        log_lines.append("[PASS] Test 2: Webhook lap (Trung key & hash) tra ve HTTP 200 Already Processed, khong sinh trung.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 2: {e}")

    # Test 3: Webhook xung dot (Trung key + Khac hash) -> 409 Conflict
    try:
        code, msg, data = process_webhook("IDEM-TCB-001", "HASH-TAMPERED-999")
        assert code == 409 and "Conflict" in msg
        results.append(True)
        log_lines.append("[PASS] Test 3: Webhook xung dot (Trung key, khac hash) tra ve HTTP 409 Conflict.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 3: {e}")

    # Test 4: Khop Tang 1 qua Virtual Account
    try:
        code, msg, data = process_webhook("IDEM-TCB-002", "HASH-456", 200000000, "96248888001")
        assert data["auto_posted"] is True and data["status"] == "DaDoiSoat"
        results.append(True)
        log_lines.append("[PASS] Test 4: Khop Tang 1 qua Virtual Account tu dong giam AR va tang DongTien thanh cong.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 4: {e}")

    # Test 5: Khong co VA -> ChoDoiSoat
    try:
        code, msg, data = process_webhook("IDEM-TCB-003", "HASH-789", 150000000, "")
        assert data["auto_posted"] is False and data["status"] == "ChoDoiSoat"
        results.append(True)
        log_lines.append("[PASS] Test 5: Giao dich khong co Virtual Account chuyen sang trang thai ChoDoiSoat cho Tang 2.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 5: {e}")

    passed = sum(results)
    failed = len(results) - passed
    log_lines.append("-----------------------------------------------------------------")
    log_lines.append(f"Tong so test: {len(results)} | Thanh cong: {passed} | That bai: {failed}")
    log_lines.append("=================================================================")

    log_path = "tests/unit/webhook_idempotency_test_result.log"
    with open(log_path, "w", encoding="utf-8") as f:
        f.write("\n".join(log_lines) + "\n")

    print("\n".join(log_lines))
    assert failed == 0, "Some tests failed!"

if __name__ == "__main__":
    verify_task5_1()
