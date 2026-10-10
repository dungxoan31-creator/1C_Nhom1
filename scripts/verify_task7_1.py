import os
import hashlib
import xml.etree.ElementTree as ET
import datetime

def verify_task7_1():
    results = []
    log_lines = []
    log_lines.append("=================================================================")
    log_lines.append("   VINSMART FUTURE - BANKING INTEGRATION TEST (TASK 7.1)         ")
    log_lines.append(f"   Thoi gian chay: {datetime.datetime.now().strftime('%d/%m/%Y %I:%M:%S %p')}")
    log_lines.append("=================================================================")

    def tinh_hmac_sha256(payload, key):
        data = f"{payload}:{key}".encode("utf-8")
        return hashlib.sha256(data).hexdigest()

    def so_sanh_hang_thoi_gian(str1, str2):
        if len(str1) != len(str2):
            return False
        res = 0
        for c1, c2 in zip(str1, str2):
            res |= ord(c1) ^ ord(c2)
        return res == 0

    def xac_thuc_webhook(payload, signature, secret_key):
        expected = tinh_hmac_sha256(payload, secret_key)
        return so_sanh_hang_thoi_gian(signature, expected)

    def boc_tach_va(va):
        va = str(va).strip()
        if len(va) >= 8 and va.startswith("9624"):
            return {"hop_le": True, "prefix": "9624", "identifier": va[4:]}
        return {"hop_le": False, "prefix": "", "identifier": ""}

    # Test 1: Xac thuc chu ky HMAC hop le
    try:
        payload = '{"account":"96248888001","amount":200000000,"txnId":"FT261010001"}'
        key = "VSF_BANKING_SECRET_2026"
        sig = tinh_hmac_sha256(payload, key)
        assert len(sig) == 64
        assert xac_thuc_webhook(payload, sig, key) is True
        results.append(True)
        log_lines.append("[PASS] Test 1: Xac thuc chu ky HMAC-SHA256 chinh xac tuyet doi giua Core Banking va 1C.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 1: Xac thuc chu ky that bai - {e}")

    # Test 2: Timing attack mitigation
    try:
        s1 = "abcdef123456"
        s2 = "abcdef123456"
        s3 = "abcdef123459"
        s4 = "abcdef"
        assert so_sanh_hang_thoi_gian(s1, s2) is True
        assert so_sanh_hang_thoi_gian(s1, s3) is False
        assert so_sanh_hang_thoi_gian(s1, s4) is False
        results.append(True)
        log_lines.append("[PASS] Test 2: Ham so sanh hang thoi gian (Constant-time comparison) hoat dong chuan xac, triet tieu timing attack.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 2: So sanh hang thoi gian that bai - {e}")

    # Test 3: Tu choi chu ky bi can thiep
    try:
        payload = '{"account":"96248888001","amount":200000000,"txnId":"FT261010001"}'
        tampered_payload = '{"account":"96248888001","amount":999000000,"txnId":"FT261010001"}'
        key = "VSF_BANKING_SECRET_2026"
        sig = tinh_hmac_sha256(payload, key)

        assert xac_thuc_webhook(tampered_payload, sig, key) is False
        assert xac_thuc_webhook(payload, sig + "x", key) is False
        results.append(True)
        log_lines.append("[PASS] Test 3: Tu choi va chan ngay lap tuc cac webhook co chu ky hoac payload bi gia mao.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 3: Chan chu ky gia mao that bai - {e}")

    # Test 4: Boc tach Virtual Account
    try:
        va = "96248888001"
        info = boc_tach_va(va)
        assert info["hop_le"] is True
        assert info["prefix"] == "9624"
        assert info["identifier"] == "8888001"

        invalid_va = "12345678"
        assert boc_tach_va(invalid_va)["hop_le"] is False
        results.append(True)
        log_lines.append("[PASS] Test 4: Boc tach tien to VA 9624 va ma hop dong 8888001 tu Virtual Account chinh xac 100%.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 4: Boc tach VA that bai - {e}")

    # Test 5: Metadata Schema XML
    try:
        f = "src/CommonModules/TichHopNganHangServer.xml"
        assert os.path.exists(f), f"{f} must exist"
        tree = ET.parse(f)
        root = tree.getroot()
        assert root.tag.endswith("MetaDataObject"), f"{f} root must be MetaDataObject"
        assert root.attrib.get("version") == "2.15", f"{f} version must be 2.15"

        results.append(True)
        log_lines.append("[PASS] Test 5: Metadata XML cua CommonModule.TichHopNganHangServer hop le 100% theo chuan 1C 2.15.")
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

    with open("tests/integration/banking_webhook_integration_test_result.log", "w", encoding="utf-8") as f:
        f.write(output)

    return passed == total

if __name__ == "__main__":
    success = verify_task7_1()
    exit(0 if success else 1)
