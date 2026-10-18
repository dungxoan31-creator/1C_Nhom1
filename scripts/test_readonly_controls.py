import unittest
import xml.etree.ElementTree as ET
from pathlib import Path

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent

class TestReadOnlyControls(unittest.TestCase):
    def setUp(self):
        self.docs = [
            "BienBanNghiemThuGiaiDoan",
            "HoaDonGTGTDauRa",
            "HoaDonNhaCungCap",
            "PhieuThuTienKhachHang",
            "UyNhiemChi"
        ]
        self.ns = {"lf": "http://v8.1c.ru/8.2/managed-application/logform"}

    def test_form_xml_number_readonly(self):
        for doc in self.docs:
            form_xml = WORKSPACE_ROOT / "src" / "Documents" / doc / "Forms" / "FormChungTu" / "Ext" / "Form.xml"
            self.assertTrue(form_xml.exists(), f"{doc} Form.xml must exist")
            tree = ET.parse(form_xml)
            root = tree.getroot()
            number_elem = None
            for elem in root.iter():
                if elem.attrib.get("name") == "Number":
                    number_elem = elem
                    break
            self.assertIsNotNone(number_elem, f"{doc} Form.xml must have Number element")
            ro = next((c for c in number_elem if c.tag.endswith("ReadOnly")), None)
            self.assertIsNotNone(ro, f"{doc} Number element must have ReadOnly child")
            self.assertEqual(ro.text.lower(), "true", f"{doc} Number ReadOnly must be true")

    def test_form_bsl_posted_protection(self):
        for doc in self.docs:
            bsl_path = WORKSPACE_ROOT / "src" / "Documents" / doc / "Forms" / "FormChungTu" / "Ext" / "Form" / "Module.bsl"
            self.assertTrue(bsl_path.exists(), f"{doc} Form Module.bsl must exist")
            content = bsl_path.read_text(encoding="utf-8")
            self.assertIn("Object.Posted", content, f"{doc} must check Object.Posted for locking")
            self.assertIn("ReadOnly", content, f"{doc} must set ReadOnly when posted")

if __name__ == "__main__":
    unittest.main()
