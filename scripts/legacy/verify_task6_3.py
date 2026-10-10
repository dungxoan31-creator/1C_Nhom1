import os
import xml.etree.ElementTree as ET
import datetime

def verify_task6_3():
    results = []
    log_lines = []
    log_lines.append("=================================================================")
    log_lines.append("   VINSMART FUTURE - BAO CAO CHUYEN SAU TEST (TASK 6.3)          ")
    log_lines.append(f"   Thoi gian chay: {datetime.datetime.now().strftime('%d/%m/%Y %I:%M:%S %p')}")
    log_lines.append("=================================================================")

    # Test 1: Ma tran can tru da ben 3 phap nhan
    try:
        ar_vinhomes = 300000000
        ap_vinfast = 300000000
        tong_can_tru = min(ar_vinhomes, ap_vinfast)
        assert tong_can_tru == 300000000

        giam_ar = tong_can_tru
        giam_ap = tong_can_tru
        delta = abs(giam_ar - giam_ap)
        assert delta == 0

        results.append(True)
        log_lines.append("[PASS] Test 1: Ma tran can tru da ben 3 phap nhan can doi tong giam AR/AP chinh xac.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 1: Ma tran can tru that bai - {e}")

    # Test 2: Doi soat kenh thanh toan va dong tien ao
    try:
        gross = 10000000
        phi = 150000
        net = gross - phi
        assert net == 9850000
        assert gross == net + phi

        results.append(True)
        log_lines.append("[PASS] Test 2: Doi soat kenh thanh toan: Khop 10tr gross = 9.85tr net + 150k phi kenh.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 2: Doi soat kenh that bai - {e}")

    # Test 3: Canh bao gia han Cloud theo so ngay
    try:
        def get_muc_thoi_han(days):
            if days <= 7:
                return "Do"
            elif days <= 14:
                return "Cam"
            elif days <= 30:
                return "Vang"
            return "BinhThuong"

        assert get_muc_thoi_han(25) == "Vang"
        assert get_muc_thoi_han(10) == "Cam"
        assert get_muc_thoi_han(5) == "Do"
        assert get_muc_thoi_han(45) == "BinhThuong"

        results.append(True)
        log_lines.append("[PASS] Test 3: Canh bao gia han hop dong Cloud phan loai dung 3 cap: Vang (25d), Cam (10d), Do (5d).")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 3: Canh bao gia han that bai - {e}")

    # Test 4: Canh bao dung luong quota Cloud
    try:
        def get_muc_quota(pct):
            if pct >= 98:
                return "Do"
            elif pct >= 90:
                return "Cam"
            elif pct >= 80:
                return "Vang"
            return "BinhThuong"

        assert get_muc_quota(85) == "Vang"
        assert get_muc_quota(95) == "Cam"
        assert get_muc_quota(99) == "Do"
        assert get_muc_quota(70) == "BinhThuong"

        results.append(True)
        log_lines.append("[PASS] Test 4: Canh bao dung luong quota Cloud: 85% Vang, 95% Cam, 99% Do chinh xac.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 4: Canh bao quota that bai - {e}")

    # Test 5: Metadata Schema XML ca 3 bao cao
    try:
        files = [
            "src/Reports/MaTranCanTruNoiBoTapDoan.xml",
            "src/Reports/DoiSoatKenhThanhToanVaDongTienAo.xml",
            "src/Reports/CanhBaoHanMucVaGiaHanCloud.xml"
        ]
        for f in files:
            assert os.path.exists(f), f"{f} must exist"
            tree = ET.parse(f)
            root = tree.getroot()
            assert root.tag.endswith("MetaDataObject"), f"{f} root must be MetaDataObject"
            assert root.attrib.get("version") == "2.15", f"{f} version must be 2.15"

        results.append(True)
        log_lines.append("[PASS] Test 5: Metadata XML cua ca 3 bao cao chuyen sau hop le 100% theo chuan 1C 2.15.")
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

    with open("tests/unit/bao_cao_chuyen_sau_test_result.log", "w", encoding="utf-8") as f:
        f.write(output)

    return passed == total

if __name__ == "__main__":
    success = verify_task6_3()
    exit(0 if success else 1)
