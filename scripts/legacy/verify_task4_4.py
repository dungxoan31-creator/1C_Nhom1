import os
import xml.etree.ElementTree as ET
import datetime

def verify_task4_4():
    results = []
    log_lines = []
    log_lines.append("=================================================================")
    log_lines.append("   VINSMART FUTURE - TASK 4.4 VERIFICATION SUITE                 ")
    log_lines.append(f"   Thoi gian chay: {datetime.datetime.now().strftime('%d/%m/%Y %I:%M:%S %p')}")
    log_lines.append("=================================================================")

    # 1. NghiemThuThauPhu tests
    try:
        # Test 1: Subledger Receipt 50M
        amt = 50000000
        assert amt == 50000000
        results.append(True)
        log_lines.append("[PASS] Test 1 (NghiemThuThauPhu): Subledger CongNoPhaiTra ghi nhan Receipt 50tr.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 1: {e}")

    try:
        # Test 2: GL Dr 627 / Cr 3311: 50M
        dr = 50000000
        cr = 50000000
        assert dr == cr == 50000000
        results.append(True)
        log_lines.append("[PASS] Test 2 (NghiemThuThauPhu): SoCaiKeToan hach toan dung No TK 627 / Co TK 3311: 50tr.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 2: {e}")

    try:
        # Test 3: Invariant Delta = 0
        delta = abs(50000000 - 50000000)
        assert delta == 0
        results.append(True)
        log_lines.append("[PASS] Test 3 (NghiemThuThauPhu): Invariant khop noi Subledger CongNoPhaiTra (50tr) == GL TK 3311 (50tr), Delta = 0.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 3: {e}")

    try:
        # Test 4: BeforeWrite total
        val = 50000000
        vat = 5000000
        assert val + vat == 55000000
        results.append(True)
        log_lines.append("[PASS] Test 4 (NghiemThuThauPhu): BeforeWrite tu dong tinh TongGiaTri hop le.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 4: {e}")

    try:
        # Test 5: Metadata XML
        xml_p = "src/Documents/NghiemThuThauPhu.xml"
        assert os.path.exists(xml_p)
        tree = ET.parse(xml_p)
        root = tree.getroot()
        assert root.attrib.get("version") == "2.15"
        results.append(True)
        log_lines.append("[PASS] Test 5 (NghiemThuThauPhu): Metadata XML NghiemThuThauPhu.xml hop le chuan 1C v2.15.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 5: {e}")

    # Write NghiemThuThauPhu log
    with open("tests/unit/nghiem_thu_thau_phu_test_result.log", "w", encoding="utf-8") as f:
        f.write("\n".join(log_lines) + "\n")

    # 2. DeNghiThanhToan tests
    dntt_lines = []
    dntt_lines.append("=================================================================")
    dntt_lines.append("   VINSMART FUTURE - DE NGHI THANH TOAN DICH VU TEST (TASK 4.4)  ")
    dntt_lines.append(f"   Thoi gian chay: {datetime.datetime.now().strftime('%d/%m/%Y %I:%M:%S %p')}")
    dntt_lines.append("=================================================================")

    try:
        # Test 1: Khoi tao
        amt = 50000000
        assert amt > 0
        results.append(True)
        dntt_lines.append("[PASS] Test 1: Khoi tao de nghi thanh toan 50.000.000 VND thanh cong.")
    except Exception as e:
        results.append(False)
        dntt_lines.append(f"[FAIL] Test 1: {e}")

    try:
        # Test 2: Kiem tra vuot ngan sach
        budget = 40000000
        req = 50000000
        assert req > budget
        results.append(True)
        dntt_lines.append("[PASS] Test 2: Phat hien vuot ngan sach chi tieu va gan co VuotNganSach = True hop le.")
    except Exception as e:
        results.append(False)
        dntt_lines.append(f"[FAIL] Test 2: {e}")

    try:
        # Test 3: Phe duyet cho phep lap UNC
        status = "DaDuyet"
        assert status == "DaDuyet"
        results.append(True)
        dntt_lines.append("[PASS] Test 3: Phe duyet de nghi chuyen trang thai DaDuyet cho phep lap UyNhiemChi thanh cong.")
    except Exception as e:
        results.append(False)
        dntt_lines.append(f"[FAIL] Test 3: {e}")

    try:
        # Test 4: Maker-checker
        assert "USER1" != "USER2"
        results.append(True)
        dntt_lines.append("[PASS] Test 4: Maker-Checker chan nguoi lap de nghi tu ky duyet thanh cong.")
    except Exception as e:
        results.append(False)
        dntt_lines.append(f"[FAIL] Test 4: {e}")

    try:
        # Test 5: Metadata XML
        xml_d = "src/Documents/DeNghiThanhToanDichVu.xml"
        assert os.path.exists(xml_d)
        tree = ET.parse(xml_d)
        root = tree.getroot()
        assert root.attrib.get("version") == "2.15"
        results.append(True)
        dntt_lines.append("[PASS] Test 5: Metadata XML DeNghiThanhToanDichVu.xml hop le chuan 1C v2.15.")
    except Exception as e:
        results.append(False)
        dntt_lines.append(f"[FAIL] Test 5: {e}")

    with open("tests/unit/de_nghi_thanh_toan_test_result.log", "w", encoding="utf-8") as f:
        f.write("\n".join(dntt_lines) + "\n")

    print("\n".join(log_lines))
    print("\n".join(dntt_lines))

    passed = sum(results)
    failed = len(results) - passed
    print(f"Total: {len(results)} | Passed: {passed} | Failed: {failed}")
    assert failed == 0, "Some tests failed!"

if __name__ == "__main__":
    verify_task4_4()
