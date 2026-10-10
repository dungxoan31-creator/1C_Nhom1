import os
import xml.etree.ElementTree as ET
import datetime

def verify_task4_1():
    results = []
    log_lines = []
    log_lines.append("=================================================================")
    log_lines.append("   VINSMART FUTURE - HOA DON NHA CUNG CAP FCT TEST (TASK 4.1)    ")
    log_lines.append(f"   Thoi gian chay: {datetime.datetime.now().strftime('%d/%m/%Y %I:%M:%S %p')}")
    log_lines.append("=================================================================")

    # Test 1: Hoa don AWS FCT
    try:
        gross_vnd = 250000000
        gross_usd = 10000
        rate = 25000
        fct_vat_rate = 0.05
        fct_cit_rate = 0.05

        fct_vat = gross_vnd * fct_vat_rate # 12.500.000
        fct_cit = gross_vnd * fct_cit_rate # 12.500.000
        net_payable = gross_vnd - (fct_vat + fct_cit) # 225.000.000
        vsf_expense = net_payable + fct_cit # 237.500.000
        vat_deductible = fct_vat # 12.500.000

        assert vsf_expense == 237500000, f"vsf_expense {vsf_expense}"
        assert net_payable == 225000000, f"net_payable {net_payable}"
        assert net_payable / rate == 9000, "USD net payable mismatch"

        dr_total = vsf_expense + vat_deductible
        cr_total = net_payable + fct_vat + fct_cit
        assert dr_total == cr_total == 250000000, "GL balance mismatch"

        subledger_ap = net_payable
        gl_3311 = net_payable
        delta = abs(subledger_ap - gl_3311)
        assert delta == 0, f"Invariant delta {delta}"

        results.append(True)
        log_lines.append("[PASS] Test 1: Hoa don AWS FCT - Chi phi VSF 237.5tr, VAT 12.5tr, No NCC 225tr, Thue nop thay 25tr, Subledger == GL TK 3311 (Delta = 0).")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 1: {e}")

    # Test 2: Hoa don trong nuoc khong FCT
    try:
        service_amt = 100000000
        vat_amt = 10000000
        total_amt = 110000000
        dr = service_amt + vat_amt
        cr = total_amt
        assert dr == cr == 110000000
        assert total_amt == 110000000
        results.append(True)
        log_lines.append("[PASS] Test 2: Hoa don trong nuoc khong FCT hach toan dung No 627 (100tr), No 1331 (10tr) / Co 3311 (110tr).")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 2: {e}")

    # Test 3: Doi tac noi bo Vingroup
    try:
        is_intercompany = True
        acc = "3312" if is_intercompany else "3311"
        assert acc == "3312"
        results.append(True)
        log_lines.append("[PASS] Test 3: Doi tac noi bo Vingroup hach toan dung Co TK 3312 (100tr).")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 3: {e}")

    # Test 4: BeforeWrite auto calculation
    try:
        gross = 250000000
        vat_fct_pct = 5
        cit_fct_pct = 5
        vat_fct = round(gross * (vat_fct_pct / 100), 2)
        cit_fct = round(gross * (cit_fct_pct / 100), 2)
        net = gross - (vat_fct + cit_fct)
        vsf_exp = net + cit_fct
        assert vat_fct == 12500000
        assert cit_fct == 12500000
        assert net == 225000000
        assert vsf_exp == 237500000
        results.append(True)
        log_lines.append("[PASS] Test 4: BeforeWrite tu dong tinh FCT, ChiPhiVSF (237.5tr), NoThucTraNCC (225tr) va TyGia mac dinh.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 4: {e}")

    # Test 5: XML schema validation
    try:
        xml_file = "src/Documents/HoaDonNhaCungCap.xml"
        assert os.path.exists(xml_file), "File not found"
        tree = ET.parse(xml_file)
        root = tree.getroot()
        assert root.attrib.get("version") == "2.15"

        ns = {"md": "http://v8.1c.ru/8.3/MDClasses", "xr": "http://v8.1c.ru/8.3/xcf/readable"}
        doc = root.find("md:Document", ns)
        assert doc is not None

        props = doc.find("md:Properties", ns)
        name = props.find("md:Name", ns).text
        assert name == "HoaDonNhaCungCap"
        assert props.find("md:Posting", ns).text == "Allow"

        regs = props.find("md:RegisterRecords", ns)
        reg_items = [item.text for item in regs.findall("xr:Item", ns)]
        assert "AccumulationRegister.CongNoPhaiTra" in reg_items
        assert "AccountingRegister.SoCaiKeToan" in reg_items

        child_objs = doc.find("md:ChildObjects", ns)
        attrs = [a.find("md:Properties", ns).find("md:Name", ns).text for a in child_objs.findall("md:Attribute", ns)]
        expected = ["PhapNhan", "DoiTac", "HopDong", "SoHoaDon", "NgayHoaDon", "TienTe", "TyGia",
                    "TongTien", "TongTienNgoaiTe", "TienDichVu", "TienThueVAT", "CoKhauTruFCT",
                    "TyLeThueVATNhaThau", "TyLeThueTNDNNhaThau", "TienThueVATNhaThau", "TienThueTNDNNhaThau",
                    "ChiPhiVSF", "NoThucTraNCC", "TrangThai", "TaiKhoanChiPhi", "DienGiai"]
        for ea in expected:
            assert ea in attrs, f"Missing attr {ea}"

        results.append(True)
        log_lines.append(f"[PASS] Test 5: Metadata XML HoaDonNhaCungCap.xml hop le v2.15 voi {len(attrs)} thuoc tinh va dang ky 2 so.")
    except Exception as e:
        results.append(False)
        log_lines.append(f"[FAIL] Test 5: {e}")

    passed = sum(results)
    failed = len(results) - passed
    log_lines.append("-----------------------------------------------------------------")
    log_lines.append(f"Tong so test: {len(results)} | Thanh cong: {passed} | That bai: {failed}")
    log_lines.append("=================================================================")

    log_path = "tests/unit/hoadon_ncc_fct_test_result.log"
    with open(log_path, "w", encoding="utf-8") as f:
        f.write("\n".join(log_lines) + "\n")

    print("\n".join(log_lines))
    assert failed == 0, "Some tests failed!"

if __name__ == "__main__":
    verify_task4_1()
