import unittest
import xml.etree.ElementTree as ET
from pathlib import Path

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent

class TestChoiceParameterLinks(unittest.TestCase):
    def setUp(self):
        self.src_dir = WORKSPACE_ROOT / "src"
        self.ns = {
            "md": "http://v8.1c.ru/8.3/MDClasses",
            "xr": "http://v8.1c.ru/8.3/xcf/readable"
        }
        self.docs = [
            "BienBanNghiemThuGiaiDoan",
            "HoaDonGTGTDauRa",
            "HoaDonNhaCungCap",
            "PhieuThuTienKhachHang",
            "UyNhiemChi"
        ]

    def test_all_documents_have_hopdong_choice_parameter_links(self):
        for doc in self.docs:
            doc_file = self.src_dir / "Documents" / f"{doc}.xml"
            tree = ET.parse(doc_file)
            root = tree.getroot()
            hopdong_attr = None
            for attr in root.findall(".//md:Attribute", self.ns):
                name_el = attr.find("md:Properties/md:Name", self.ns)
                if name_el is not None and name_el.text == "HopDong":
                    hopdong_attr = attr
                    break
            self.assertIsNotNone(hopdong_attr, f"{doc} must have HopDong attribute")
            cpl = hopdong_attr.find("md:Properties/md:ChoiceParameterLinks", self.ns)
            self.assertIsNotNone(cpl, f"{doc}.HopDong must have ChoiceParameterLinks")
            links = cpl.findall("xr:Link", self.ns)
            self.assertGreater(len(links), 0, f"{doc}.HopDong must declare at least 1 Link in ChoiceParameterLinks")
            link_name = links[0].find("xr:Name", self.ns).text
            link_path = links[0].find("xr:DataPath", self.ns).text
            self.assertEqual(link_name, "Filter.ChuSoHuu")
            self.assertEqual(link_path, f"Document.{doc}.Attribute.DoiTac")

    def test_quick_choice_on_standard_catalogs(self):
        for cat in ["KhoanMucDongTien", "TienTe"]:
            cat_file = self.src_dir / "Catalogs" / f"{cat}.xml"
            tree = ET.parse(cat_file)
            qc = tree.getroot().find(".//md:QuickChoice", self.ns)
            self.assertIsNotNone(qc, f"{cat} must have QuickChoice element")
            self.assertEqual(qc.text.lower(), "true", f"{cat} QuickChoice must be true")

if __name__ == "__main__":
    unittest.main()
