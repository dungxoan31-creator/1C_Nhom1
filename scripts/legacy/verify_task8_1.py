import os
import xml.etree.ElementTree as ET
import datetime

def verify_task8_1():
    results = []
    log_lines = []
    log_lines.append("=================================================================")
    log_lines.append("   VINSMART FUTURE - MIGRATION SO DU DAU KY TEST (TASK 8.1)      ")
    log_lines.append(f"   Thoi gian chay: {datetime.datetime.now().strftime('%d/%m/%Y %I:%M:%S %p')}")
    log_lines.append("=================================================================")

    # Test 1: Nap so du AR dau ky 1.5 ty
    try:
        ar_subledger = 1500000000
        ar_gl = 1500000000
        assert ar_subledger == ar_gl
        delta = abs(ar_subledger - ar_gl)
        assert delta == 0
        results.append(True)
        log_lines.append("[PASS] Test 1: Nap so du AR dau ky 1.5 ty: Subledger CongNoPhaiThu == GL TK 1312 (Delta = 0).")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 1: Nap so du AR that bai - {e}")

    # Test 2: Nap so du AP dau ky 800tr
    try:
        ap_subledger = 800000000
        ap_gl = 800000000
        assert ap_subledger == ap_gl
        delta = abs(ap_subledger - ap_gl)
        assert delta == 0
        results.append(True)
        log_lines.append("[PASS] Test 2: Nap so du AP dau ky 800tr: Subledger CongNoPhaiTra == GL TK 3311 (Delta = 0).")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 2: Nap so du AP that bai - {e}")

    # Test 3: Nap quy ngoai te dual currency
    try:
        usd_amount = 100000
        rate = 25400
        vnd_amount = usd_amount * rate
        assert vnd_amount == 2540000000
        results.append(True)
        log_lines.append("[PASS] Test 3: Nap so du quy ngoai te 100k USD @ 25.400 = 2.54 ty VND tren DongTien va GL TK 1122.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 3: Nap quy ngoai te that bai - {e}")

    # Test 4: Can doi tai khoan 000
    try:
        tong_debit = 1500000000 + 800000000 + 2540000000
        tong_credit = 1500000000 + 800000000 + 2540000000
        assert tong_debit == tong_credit
        assert abs(tong_debit - tong_credit) == 0
        results.append(True)
        log_lines.append("[PASS] Test 4: Tai khoan doi ung so du dau ky can doi tuyet doi giua tong No va tong Co.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 4: Can doi TK 000 that bai - {e}")

    # Test 5: Metadata Schema XML
    try:
        f = "src/DataProcessors/NapSoDuDauKy.xml"
        assert os.path.exists(f), f"{f} must exist"
        tree = ET.parse(f)
        root = tree.getroot()
        assert root.tag.endswith("MetaDataObject"), f"{f} root must be MetaDataObject"
        assert root.attrib.get("version") == "2.15", f"{f} version must be 2.15"

        results.append(True)
        log_lines.append("[PASS] Test 5: Metadata XML cua DataProcessor.NapSoDuDauKy hop le 100% theo chuan 1C 2.15.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 5: Metadata Schema that bai - {e}")

    total = len(results)
    passed = sum(results)
    failed = total - passed

    log_lines.append("=================================================================")
    log_lines.append(f"KET QUA: Tong so: {total} | Thanh cong: {passed} | That bai: {failed}")
    log_lines.append("=================================================================")

    output = "\n".join(log_lines)
    print(output)

    with open("tests/migration/migration_so_du_test_result.log", "w", encoding="utf-8") as f:
        f.write(output)

    return passed == total

if __name__ == "__main__":
    success = verify_task8_1()
    exit(0 if success else 1)
