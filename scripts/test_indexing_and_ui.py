import unittest
import xml.etree.ElementTree as ET
from pathlib import Path

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent

class TestIndexingAndUI(unittest.TestCase):
    def setUp(self):
        self.src_dir = WORKSPACE_ROOT / "src"
        self.ns = {"md": "http://v8.1c.ru/8.3/MDClasses"}
        self.fields_to_check = {
            "Documents/HoaDonGTGTDauRa.xml": ["DoiTac", "NgayHoaDon", "TrangThaiHDDT"],
            "Documents/HoaDonNhaCungCap.xml": ["DoiTac", "NgayHoaDon", "TrangThai"],
            "Documents/UyNhiemChi.xml": ["DoiTac", "NgayGhiSo", "TrangThai"],
            "Documents/PhieuThuTienKhachHang.xml": ["DoiTac", "NgayThu"],
            "Documents/BienBanNghiemThuGiaiDoan.xml": ["DoiTac", "NgayNghiemThu", "TrangThai"],
            "Catalogs/DoiTac.xml": ["MaSoThue"]
        }

    def _get_attribute_indexing(self, rel_path, attr_name):
        tree = ET.parse(self.src_dir / rel_path)
        root = tree.getroot()
        for attr in root.findall(".//md:Attribute", self.ns):
            name_el = attr.find("md:Properties/md:Name", self.ns)
            if name_el is not None and name_el.text == attr_name:
                idx = attr.find("md:Properties/md:Indexing", self.ns)
                return idx.text if idx is not None else None
        return None

    def test_database_indexing_on_critical_search_attributes(self):
        for rel_path, flds in self.fields_to_check.items():
            for fld in flds:
                idx_val = self._get_attribute_indexing(rel_path, fld)
                self.assertIsNotNone(idx_val, f"{rel_path}.{fld} must declare Indexing")
                self.assertEqual(idx_val, "Index", f"{rel_path}.{fld} Indexing must be 'Index'")

    def test_form_ui_components_exist(self):
        for doc in ["BienBanNghiemThuGiaiDoan", "HoaDonGTGTDauRa", "HoaDonNhaCungCap", "PhieuThuTienKhachHang", "UyNhiemChi"]:
            form_bsl = self.src_dir / "Documents" / doc / "Forms" / "FormChungTu" / "Ext" / "Form" / "Module.bsl"
            self.assertTrue(form_bsl.exists())
            txt = form_bsl.read_text(encoding="utf-8")
            self.assertIn("CapNhatHTMLHeader", txt, f"{doc} must have CapNhatHTMLHeader")
            self.assertIn("stepper", txt.lower(), f"{doc} must have stepper in HTML Header")

if __name__ == "__main__":
    unittest.main()
