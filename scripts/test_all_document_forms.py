import unittest
from pathlib import Path

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent

class TestAllDocumentForms(unittest.TestCase):
    def test_all_five_docs_have_complete_forms(self):
        docs = [
            "HoaDonGTGTDauRa", "HoaDonNhaCungCap",
            "PhieuThuTienKhachHang", "UyNhiemChi", "BienBanNghiemThuGiaiDoan"
        ]
        for doc in docs:
            form_meta = WORKSPACE_ROOT / "src" / "Documents" / doc / "Forms" / "FormChungTu.xml"
            form_xml = WORKSPACE_ROOT / "src" / "Documents" / doc / "Forms" / "FormChungTu" / "Ext" / "Form.xml"
            form_bsl = WORKSPACE_ROOT / "src" / "Documents" / doc / "Forms" / "FormChungTu" / "Ext" / "Form" / "Module.bsl"
            
            self.assertTrue(form_meta.exists(), f"{doc} FormChungTu.xml must exist")
            self.assertTrue(form_xml.exists(), f"{doc} Form.xml must exist")
            self.assertTrue(form_bsl.exists(), f"{doc} Module.bsl must exist")
            
            xml_text = form_xml.read_text(encoding="utf-8")
            self.assertIn("ThongTinChung", xml_text, f"{doc} must have ThongTinChung tab")
            
            bsl_text = form_bsl.read_text(encoding="utf-8")
            self.assertIn("ShowUserNotification", bsl_text, f"{doc} Module.bsl must support ShowUserNotification")
            self.assertIn("WorkflowStepper", bsl_text, f"{doc} Module.bsl must render WorkflowStepper")

    def test_document_metadata_declares_form(self):
        docs = [
            "HoaDonGTGTDauRa", "HoaDonNhaCungCap",
            "PhieuThuTienKhachHang", "UyNhiemChi", "BienBanNghiemThuGiaiDoan"
        ]
        for doc in docs:
            doc_xml = WORKSPACE_ROOT / "src" / "Documents" / f"{doc}.xml"
            content = doc_xml.read_text(encoding="utf-8")
            self.assertIn(f"<DefaultObjectForm>Document.{doc}.Form.FormChungTu</DefaultObjectForm>", content)
            self.assertIn("<Form>FormChungTu</Form>", content)

if __name__ == "__main__":
    unittest.main()
