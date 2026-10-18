import unittest
from pathlib import Path

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent

class TestARInvoiceForm(unittest.TestCase):
    def setUp(self):
        self.doc_xml = WORKSPACE_ROOT / "src" / "Documents" / "HoaDonGTGTDauRa.xml"
        self.form_meta = WORKSPACE_ROOT / "src" / "Documents" / "HoaDonGTGTDauRa" / "Forms" / "FormChungTu.xml"
        self.form_xml = WORKSPACE_ROOT / "src" / "Documents" / "HoaDonGTGTDauRa" / "Forms" / "FormChungTu" / "Ext" / "Form.xml"
        self.form_bsl = WORKSPACE_ROOT / "src" / "Documents" / "HoaDonGTGTDauRa" / "Forms" / "FormChungTu" / "Ext" / "Form" / "Module.bsl"

    def test_form_files_exist(self):
        self.assertTrue(self.form_meta.exists(), "FormChungTu.xml metadata must exist")
        self.assertTrue(self.form_xml.exists(), "Form.xml must exist")
        self.assertTrue(self.form_bsl.exists(), "Form/Module.bsl must exist")

    def test_doc_metadata_references_form(self):
        content = self.doc_xml.read_text(encoding="utf-8")
        self.assertIn("<DefaultObjectForm>Document.HoaDonGTGTDauRa.Form.FormChungTu</DefaultObjectForm>", content)
        self.assertIn("<Form>FormChungTu</Form>", content)

    def test_form_xml_structure(self):
        content = self.form_xml.read_text(encoding="utf-8")
        self.assertIn("Pages", content, "Form must contain tabbed Pages")
        self.assertIn("ThongTinChung", content, "Form must have ThongTinChung page")
        self.assertIn("ThanhToanVaThue", content, "Form must have ThanhToanVaThue page")

    def test_form_bsl_handlers(self):
        content = self.form_bsl.read_text(encoding="utf-8")
        self.assertIn("Procedure OnCreateAtServer", content)
        self.assertIn("TienChuaThueOnChange", content)

if __name__ == "__main__":
    unittest.main()
