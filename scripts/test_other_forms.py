import unittest
from pathlib import Path

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent

class TestOtherDocumentForms(unittest.TestCase):
    def setUp(self):
        self.docs = ["HoaDonNhaCungCap", "UyNhiemChi", "PhieuThuTienKhachHang"]

    def test_form_files_exist_for_all_docs(self):
        for doc in self.docs:
            form_meta = WORKSPACE_ROOT / "src" / "Documents" / doc / "Forms" / "FormChungTu.xml"
            form_xml = WORKSPACE_ROOT / "src" / "Documents" / doc / "Forms" / "FormChungTu" / "Ext" / "Form.xml"
            form_bsl = WORKSPACE_ROOT / "src" / "Documents" / doc / "Forms" / "FormChungTu" / "Ext" / "Form" / "Module.bsl"
            self.assertTrue(form_meta.exists(), f"{doc} FormChungTu.xml must exist")
            self.assertTrue(form_xml.exists(), f"{doc} Form.xml must exist")
            self.assertTrue(form_bsl.exists(), f"{doc} Form/Module.bsl must exist")

    def test_doc_xml_references_form(self):
        for doc in self.docs:
            doc_xml = WORKSPACE_ROOT / "src" / "Documents" / f"{doc}.xml"
            content = doc_xml.read_text(encoding="utf-8")
            self.assertIn(f"<DefaultObjectForm>Document.{doc}.Form.FormChungTu</DefaultObjectForm>", content)
            self.assertIn("<Form>FormChungTu</Form>", content)

if __name__ == "__main__":
    unittest.main()
