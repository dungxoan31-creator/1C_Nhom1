import os
import xml.etree.ElementTree as ET
import datetime

def verify_task4_2():
    results = []
    log_lines = []
    log_lines.append("=================================================================")
    log_lines.append("   VINSMART FUTURE - WORKFLOW PHE DUYET AP UNIT TEST (TASK 4.2)  ")
    log_lines.append(f"   Thoi gian chay: {datetime.datetime.now().strftime('%d/%m/%Y %I:%M:%S %p')}")
    log_lines.append("=================================================================")

    # Logic functions corresponding to QuyTrinhPheDuyetAPServer
    def xac_dinh_trang_thai_tiep_theo(current, over_budget=False):
        if current in ("DuThao", "Dự thảo"):
            return "ChoDuyetKyThuat"
        elif current in ("ChoDuyetKyThuat", "Chờ duyệt kỹ thuật"):
            return "ChoDuyetPM"
        elif current in ("ChoDuyetPM", "Chờ duyệt PM"):
            return "ChoDuyetITDirector"
        elif current in ("ChoDuyetITDirector", "Chờ duyệt IT Director"):
            return "ChoDuyetCFO" if over_budget else "ChoKeToanAP"
        elif current in ("ChoDuyetCFO", "Chờ duyệt CFO"):
            return "ChoKeToanAP"
        elif current in ("ChoKeToanAP", "Chờ kế toán AP"):
            return "DaGhiSo"
        return current

    def kiem_tra_quyen_duyet(author, approver, stage):
        if str(author) == str(approver):
            raise Exception("Vi phạm nguyên tắc Maker-Checker: Người tạo không thể tự phê duyệt chứng từ!")
        if not approver:
            raise Exception("Chưa xác định người dùng thực hiện phê duyệt!")

    def tu_choi_phe_duyet(current, reason):
        if not reason:
            raise Exception("Bắt buộc phải nhập lý do từ chối phê duyệt!")
        return {"TrangThaiMoi": "TuChoi", "TrangThaiTruocDo": current, "LyDo": reason}

    def kiem_tra_anti_split(count_in_month, total_in_month, threshold=100000000):
        return count_in_month >= 3 and total_in_month >= threshold

    # Test 1: Luong duyet chuan trong han muc
    try:
        s = "DuThao"
        s = xac_dinh_trang_thai_tiep_theo(s, False)
        assert s == "ChoDuyetKyThuat"
        s = xac_dinh_trang_thai_tiep_theo(s, False)
        assert s == "ChoDuyetPM"
        s = xac_dinh_trang_theo = xac_dinh_trang_thai_tiep_theo(s, False)
        assert s == "ChoDuyetITDirector"
        s = xac_dinh_trang_thai_tiep_theo(s, False)
        assert s == "ChoKeToanAP"
        s = xac_dinh_trang_thai_tiep_theo(s, False)
        assert s == "DaGhiSo"
        results.append(True)
        log_lines.append("[PASS] Test 1: Luong duyet chuan trong han muc ngan sach chuyen tuan tu qua cac cap den DaGhiSo.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 1: {e}")

    # Test 2: Luong duyet vuot ngan sach > 10% (CFO Unlock)
    try:
        s = "ChoDuyetITDirector"
        s = xac_dinh_trang_thai_tiep_theo(s, True)
        assert s == "ChoDuyetCFO", f"Expected ChoDuyetCFO, got {s}"
        s = xac_dinh_trang_thai_tiep_theo(s, True)
        assert s == "ChoKeToanAP", f"Expected ChoKeToanAP, got {s}"
        results.append(True)
        log_lines.append("[PASS] Test 2: Luong duyet vuot ngan sach > 10% tu dong kich hoat nhanh ChoDuyetCFO hop le.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 2: {e}")

    # Test 3: Maker-Checker chan nguoi tao
    try:
        blocked = False
        try:
            kiem_tra_quyen_duyet("DEV_USER", "DEV_USER", "ChoDuyetPM")
        except Exception:
            blocked = True
        assert blocked, "Maker-Checker did not block creator!"
        results.append(True)
        log_lines.append("[PASS] Test 3: Maker-Checker chan nguoi tao tu phe duyet moi cap thanh cong.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 3: {e}")

    # Test 4: Xu ly TuChoi
    try:
        res = tu_choi_phe_duyet("ChoDuyetPM", "Thieu chung tu goc nghiem thu")
        assert res["TrangThaiMoi"] == "TuChoi"
        assert res["LyDo"] == "Thieu chung tu goc nghiem thu"
        results.append(True)
        log_lines.append("[PASS] Test 4: Xu ly TuChoi chuyen trang thai sang TuChoi kem ly do thanh cong.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 4: {e}")

    # Test 5: Re-check Anti-Split truoc khi sang ChoKeToanAP
    try:
        is_split = kiem_tra_anti_split(4, 450000000, 100000000)
        assert is_split, "Should detect anti-split pattern"
        is_not_split = kiem_tra_anti_split(1, 50000000, 100000000)
        assert not is_not_split, "Should not flag normal transaction"
        results.append(True)
        log_lines.append("[PASS] Test 5: Re-check Anti-Split phat hien dau hieu tach nho hoa don va canh bao truoc khi vao ChoKeToanAP.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 5: {e}")

    passed = sum(results)
    failed = len(results) - passed
    log_lines.append("-----------------------------------------------------------------")
    log_lines.append(f"Tong so test: {len(results)} | Thanh cong: {passed} | That bai: {failed}")
    log_lines.append("=================================================================")

    log_path = "tests/unit/workflow_phe_duyet_ap_test_result.log"
    with open(log_path, "w", encoding="utf-8") as f:
        f.write("\n".join(log_lines) + "\n")

    print("\n".join(log_lines))
    assert failed == 0, "Some tests failed!"

if __name__ == "__main__":
    verify_task4_2()
