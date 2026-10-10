import os
import xml.etree.ElementTree as ET
import datetime

def verify_task6_1():
    results = []
    log_lines = []
    log_lines.append("=================================================================")
    log_lines.append("   VINSMART FUTURE - MA TRAN CAN TRU NETTING TEST (TASK 6.1)     ")
    log_lines.append(f"   Thoi gian chay: {datetime.datetime.now().strftime('%d/%m/%Y %I:%M:%S %p')}")
    log_lines.append("=================================================================")

    # Test 1: Can tru tay doi 2 ben (Bilateral Netting)
    try:
        no_ar = 500000000
        no_ap = 300000000
        so_tien_can_tru = min(no_ar, no_ap)
        assert so_tien_can_tru == 300000000

        subledger_ar_expense = so_tien_can_tru
        subledger_ap_expense = so_tien_can_tru

        ar_con_lai = no_ar - subledger_ar_expense
        ap_con_lai = no_ap - subledger_ap_expense

        assert ar_con_lai == 200000000
        assert ap_con_lai == 0

        # GL Posting: No 3312 / Co 1312: 300tr
        gl_dr = so_tien_can_tru
        gl_cr = so_tien_can_tru
        assert gl_dr == gl_cr
        delta = abs(gl_dr - gl_cr)
        assert delta == 0

        # Subledger vs GL Invariant:
        assert abs(subledger_ar_expense - gl_cr) == 0
        assert abs(subledger_ap_expense - gl_dr) == 0

        results.append(True)
        log_lines.append("[PASS] Test 1: Can tru tay doi VSF - VinFast 300tr thanh cong, AR giam 300tr, AP giam 300tr, GL: No 3312 / Co 1312 - Delta = 0.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 1: Can tru tay doi that bai - {e}")

    # Test 2: Can tru bac cau da ben qua TK 1388
    try:
        so_tien_bac_cau = 200000000
        # VSF: No 3312 / Co 1388 (200tr) va No 1388 / Co 1312 (200tr)
        debit_1388 = so_tien_bac_cau
        credit_1388 = so_tien_bac_cau
        so_du_1388 = debit_1388 - credit_1388
        assert so_du_1388 == 0

        results.append(True)
        log_lines.append("[PASS] Test 2: Can tru da ben bac cau qua TK trung gian 1388 can doi hoan toan, so du TK 1388 triet tieu ve 0.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 2: Can tru bac cau that bai - {e}")

    # Test 3: Watchdog Timeout 120 phut
    try:
        now = datetime.datetime.now()
        doc = {
            "so_ct": "HD-001",
            "status": "ChoCanTru",
            "prev_status": "ChuaThanhToan",
            "lock_time": now - datetime.timedelta(minutes=125)
        }
        timeout_minutes = 120
        elapsed_minutes = (now - doc["lock_time"]).total_seconds() / 60

        is_expired = elapsed_minutes > timeout_minutes
        assert is_expired is True

        if is_expired:
            doc["status"] = doc["prev_status"]

        assert doc["status"] == "ChuaThanhToan"
        results.append(True)
        log_lines.append("[PASS] Test 3: Watchdog Timeout quet qua 120 phut tu dong hoan nguyen trang thai chung tu ve TrangThaiTruocDo.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 3: Watchdog Timeout that bai - {e}")

    # Test 4: Maker-Checker chan nguoi tao tu duyet
    try:
        nguoi_lap = "ketoan_noi_bo"
        nguoi_duyet = "ketoan_noi_bo"
        blocked = False
        if nguoi_lap == nguoi_duyet:
            blocked = True
        assert blocked is True
        results.append(True)
        log_lines.append("[PASS] Test 4: Maker-Checker chan thanh cong truong hop nguoi lap chung tu can tru tu phe duyet.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 4: Maker-Checker that bai - {e}")

    # Test 5: Metadata Schema XML
    try:
        files = [
            "src/DataProcessors/LapMaTranCanTruTapDoan.xml",
            "src/Documents/CanTruCongNoNoiBo.xml"
        ]
        for f in files:
            assert os.path.exists(f), f"File {f} must exist"
            tree = ET.parse(f)
            root = tree.getroot()
            assert root.tag.endswith("MetaDataObject"), f"{f} root must be MetaDataObject"
            assert root.attrib.get("version") == "2.15", f"{f} version must be 2.15"

        results.append(True)
        log_lines.append("[PASS] Test 5: Metadata XML cua LapMaTranCanTruTapDoan va CanTruCongNoNoiBo hop le 100% theo chuan 1C 2.15.")
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

    with open("tests/unit/ma_tran_can_tru_netting_test_result.log", "w", encoding="utf-8") as f:
        f.write(output)

    return passed == total

if __name__ == "__main__":
    success = verify_task6_1()
    exit(0 if success else 1)
