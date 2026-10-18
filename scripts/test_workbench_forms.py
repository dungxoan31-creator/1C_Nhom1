import unittest
from pathlib import Path

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent

class TestWorkbenchForms(unittest.TestCase):
    def test_workbench_forms_exist(self):
        forms = ["FormBanLamViec", "FormPheDuyetHangLoat"]
        for form in forms:
            meta = WORKSPACE_ROOT / "src" / "DataProcessors" / "BanLamViecWebERP" / "Forms" / f"{form}.xml"
            ext_xml = WORKSPACE_ROOT / "src" / "DataProcessors" / "BanLamViecWebERP" / "Forms" / form / "Ext" / "Form.xml"
            ext_bsl = WORKSPACE_ROOT / "src" / "DataProcessors" / "BanLamViecWebERP" / "Forms" / form / "Ext" / "Form" / "Module.bsl"
            self.assertTrue(meta.exists(), f"{form}.xml must exist")
            self.assertTrue(ext_xml.exists(), f"{form}/Ext/Form.xml must exist")
            self.assertTrue(ext_bsl.exists(), f"{form}/Ext/Form/Module.bsl must exist")

    def test_dataprocessor_xml_references_forms(self):
        dp_xml = WORKSPACE_ROOT / "src" / "DataProcessors" / "BanLamViecWebERP.xml"
        content = dp_xml.read_text(encoding="utf-8")
        self.assertIn("<DefaultForm>DataProcessor.BanLamViecWebERP.Form.FormBanLamViec</DefaultForm>", content)
        self.assertIn("<Form>FormBanLamViec</Form>", content)
        self.assertIn("<Form>FormPheDuyetHangLoat</Form>", content)

    def test_template_html_contains_modern_cockpit(self):
        tpl = WORKSPACE_ROOT / "src" / "CommonTemplates" / "MauHTMLTrangChu" / "Ext" / "Template.txt"
        self.assertTrue(tpl.exists(), "Template.txt must exist")
        content = tpl.read_text(encoding="utf-8")
        self.assertIn("VinSmart Future", content)
        self.assertIn("e1cib/data/Document.", content)
        self.assertIn("#EA0B2A", content)

if __name__ == "__main__":
    unittest.main()
