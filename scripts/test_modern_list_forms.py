import unittest
from pathlib import Path

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent

class TestModernListForms(unittest.TestCase):
    def setUp(self):
        self.docs = [
            "HoaDonGTGTDauRa", "HoaDonNhaCungCap",
            "PhieuThuTienKhachHang", "UyNhiemChi", "BienBanNghiemThuGiaiDoan"
        ]

    def test_list_forms_exist_and_configured(self):
        for doc in self.docs:
            meta = WORKSPACE_ROOT / "src" / "Documents" / doc / "Forms" / "FormDanhSach.xml"
            ext_xml = WORKSPACE_ROOT / "src" / "Documents" / doc / "Forms" / "FormDanhSach" / "Ext" / "Form.xml"
            ext_bsl = WORKSPACE_ROOT / "src" / "Documents" / doc / "Forms" / "FormDanhSach" / "Ext" / "Form" / "Module.bsl"
            
            self.assertTrue(meta.exists(), f"{doc} FormDanhSach.xml must exist")
            self.assertTrue(ext_xml.exists(), f"{doc} FormDanhSach/Ext/Form.xml must exist")
            self.assertTrue(ext_bsl.exists(), f"{doc} FormDanhSach/Ext/Form/Module.bsl must exist")
            
            doc_xml = WORKSPACE_ROOT / "src" / "Documents" / f"{doc}.xml"
            self.assertIn(f"<DefaultListForm>Document.{doc}.Form.FormDanhSach</DefaultListForm>", doc_xml.read_text(encoding="utf-8"))
            
            xml_text = ext_xml.read_text(encoding="utf-8")
            self.assertIn("BoLocNhanh", xml_text, f"{doc} FormDanhSach must have BoLocNhanh group")
            self.assertIn("ConditionalAppearance", xml_text, f"{doc} FormDanhSach must have ConditionalAppearance")

if __name__ == "__main__":
    unittest.main()
