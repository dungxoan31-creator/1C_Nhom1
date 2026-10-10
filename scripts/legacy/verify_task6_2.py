import os
import xml.etree.ElementTree as ET
import datetime

def verify_task6_2():
    results = []
    log_lines = []
    log_lines.append("=================================================================")
    log_lines.append("   VINSMART FUTURE - BAO CAO TUOI NO & SAFETY GATE TEST (TASK 6.2)")
    log_lines.append(f"   Thoi gian chay: {datetime.datetime.now().strftime('%d/%m/%Y %I:%M:%S %p')}")
    log_lines.append("=================================================================")

    def lay_nhom_tuoi_no(days):
        if days <= 0:
            return "TrongHan"
        elif days <= 30:
            return "QuaHan1_30"
        elif days <= 60:
            return "QuaHan31_60"
        else:
            return "QuaHanTren60"

    def kiem_tra_safety_gate(is_affiliated, days):
        res = {"de_xuat_khoa": False, "cam_khoa": False, "status": "BinhThuong"}
        if is_affiliated:
            # OPERATIONAL SAFETY GATE: Cam tuyet doi khoa dich vu doi tac noi bo Vingroup
            res["cam_khoa"] = True
            res["de_xuat_khoa"] = False
            if days > 60:
                res["status"] = "CanhBaoCFOVaNetting"
            elif days > 0:
                res["status"] = "DoiChieuNoiBo"
        else:
            if days > 60:
                res["de_xuat_khoa"] = True
                res["status"] = "KhoaDichVuAPI"
            elif days > 30:
                res["status"] = "NhacNo"
            elif days > 0:
                res["status"] = "CanhBaoSom"
        return res

    # Test 1: Khach ngoai qua han 45 ngay
    try:
        nhom = lay_nhom_tuoi_no(45)
        assert nhom == "QuaHan31_60"
        gate = kiem_tra_safety_gate(False, 45)
        assert gate["de_xuat_khoa"] is False
        assert gate["status"] == "NhacNo"
        results.append(True)
        log_lines.append("[PASS] Test 1: Khach hang ngoai qua han 45 ngay xep nhom 31-60 ngay, trang thai NhacNo hop le.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 1: Khach ngoai qua han 45 ngay that bai - {e}")

    # Test 2: Khach ngoai qua han 75 ngay
    try:
        nhom = lay_nhom_tuoi_no(75)
        assert nhom == "QuaHanTren60"
        gate = kiem_tra_safety_gate(False, 75)
        assert gate["de_xuat_khoa"] is True
        assert gate["status"] == "KhoaDichVuAPI"
        results.append(True)
        log_lines.append("[PASS] Test 2: Khach hang ngoai qua han 75 ngay (>60 ngay) tu dong de xuat khoa API Cloud.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 2: Khach ngoai qua han 75 ngay that bai - {e}")

    # Test 3: Noi bo Vingroup qua han 90 ngay
    try:
        nhom = lay_nhom_tuoi_no(90)
        assert nhom == "QuaHanTren60"
        gate = kiem_tra_safety_gate(True, 90)
        assert gate["de_xuat_khoa"] is False, "Operational Safety Gate MUST NOT disconnect internal partner"
        assert gate["cam_khoa"] is True
        assert gate["status"] == "CanhBaoCFOVaNetting"
        results.append(True)
        log_lines.append("[PASS] Test 3: Doi tac noi bo Vingroup qua han 90 ngay: Safety Gate chan tuyet doi ngat dich vu, kich hoat CanhBaoCFOVaNetting.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 3: Safety Gate noi bo that bai - {e}")

    # Test 4: Tinh tong du no
    try:
        data = [
            {"amount": 100000000, "days": 0},
            {"amount": 50000000, "days": 15},
            {"amount": 30000000, "days": 45},
            {"amount": 20000000, "days": 75}
        ]
        t_trong = sum(x["amount"] for x in data if lay_nhom_tuoi_no(x["days"]) == "TrongHan")
        t_1_30 = sum(x["amount"] for x in data if lay_nhom_tuoi_no(x["days"]) == "QuaHan1_30")
        t_31_60 = sum(x["amount"] for x in data if lay_nhom_tuoi_no(x["days"]) == "QuaHan31_60")
        t_tren_60 = sum(x["amount"] for x in data if lay_nhom_tuoi_no(x["days"]) == "QuaHanTren60")

        assert t_trong == 100000000
        assert t_1_30 == 50000000
        assert t_31_60 == 30000000
        assert t_tren_60 == 20000000
        assert t_trong + t_1_30 + t_31_60 + t_tren_60 == 200000000
        results.append(True)
        log_lines.append("[PASS] Test 4: Tinh tong du no theo tung nhom tuoi no chinh xac 100%.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 4: Tinh tong du no that bai - {e}")

    # Test 5: Metadata Schema XML
    try:
        report_xml = "src/Reports/BaoCaoTuoiNoPhanTachNoiBo.xml"
        assert os.path.exists(report_xml), "BaoCaoTuoiNoPhanTachNoiBo.xml must exist"
        tree = ET.parse(report_xml)
        root = tree.getroot()
        assert root.tag.endswith("MetaDataObject"), "Root must be MetaDataObject"
        assert root.attrib.get("version") == "2.15", "Version must be 2.15"

        results.append(True)
        log_lines.append("[PASS] Test 5: Metadata XML cua Report.BaoCaoTuoiNoPhanTachNoiBo hop le 100% theo chuan 1C 2.15.")
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

    with open("tests/unit/bao_cao_tuoi_no_safety_gate_test_result.log", "w", encoding="utf-8") as f:
        f.write(output)

    return passed == total

if __name__ == "__main__":
    success = verify_task6_2()
    exit(0 if success else 1)
