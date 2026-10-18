import unittest
from pathlib import Path

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent

class TestHomePageForm(unittest.TestCase):
    def setUp(self):
        self.template_xml = WORKSPACE_ROOT / "src" / "CommonTemplates" / "MauHTMLTrangChu.xml"
        self.template_txt = WORKSPACE_ROOT / "src" / "CommonTemplates" / "MauHTMLTrangChu" / "Ext" / "Template.txt"
        self.form_meta = WORKSPACE_ROOT / "src" / "CommonForms" / "TrangChuTongQuan.xml"
        self.form_xml = WORKSPACE_ROOT / "src" / "CommonForms" / "TrangChuTongQuan" / "Ext" / "Form.xml"
        self.form_bsl = WORKSPACE_ROOT / "src" / "CommonForms" / "TrangChuTongQuan" / "Ext" / "Form" / "Module.bsl"

    def test_template_files_exist(self):
        self.assertTrue(self.template_xml.exists(), "MauHTMLTrangChu.xml must exist")
        self.assertTrue(self.template_txt.exists(), "Template.txt must exist")
        content = self.template_txt.read_text(encoding="utf-8")
        self.assertIn("<!DOCTYPE html>", content, "Template must be HTML5")
        self.assertIn("#EA0B2A", content, "Template must contain VinSmart brand color #EA0B2A")
        self.assertIn("<svg", content, "Template must include SVG visual elements")

    def test_form_files_exist(self):
        self.assertTrue(self.form_meta.exists(), "TrangChuTongQuan.xml must exist")
        self.assertTrue(self.form_xml.exists(), "Form.xml must exist")
        self.assertTrue(self.form_bsl.exists(), "Form/Module.bsl must exist")

    def test_form_xml_elements(self):
        content = self.form_xml.read_text(encoding="utf-8")
        self.assertIn("HTMLDocumentField", content, "Form must define an HTMLDocumentField")

    def test_form_bsl_logic(self):
        content = self.form_bsl.read_text(encoding="utf-8")
        self.assertIn("OnCreateAtServer", content, "Form must implement OnCreateAtServer")
        self.assertIn("BangDieuKhienServer.LayDuLieuTongQuan", content, "Form must call BangDieuKhienServer")

if __name__ == "__main__":
    unittest.main()
