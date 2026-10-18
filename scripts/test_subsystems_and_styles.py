import unittest
from pathlib import Path

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent

class TestSubsystemsAndStyles(unittest.TestCase):
    def test_dataprocessor_in_subsystems(self):
        subsystems = [
            "PhanHePhaiThu", "PhanHePhaiTra", "PhanHeNganHangVaQuy",
            "PhanHeSoCaiVaDongBo", "PhanHeDanhMuc"
        ]
        for sub in subsystems:
            sub_xml = WORKSPACE_ROOT / "src" / "Subsystems" / f"{sub}.xml"
            content = sub_xml.read_text(encoding="utf-8")
            self.assertIn("<xr:Item xsi:type=\"xr:MDObjectRef\">DataProcessor.BanLamViecWebERP</xr:Item>", content, f"{sub} must include BanLamViecWebERP")

    def test_vinsmart_brand_style_item(self):
        style_file = WORKSPACE_ROOT / "src" / "StyleItems" / "FunctionsPanelSectionColor.xml"
        self.assertTrue(style_file.exists(), "FunctionsPanelSectionColor.xml must exist")
        content = style_file.read_text(encoding="utf-8")
        self.assertIn("#EA0B2A", content, "FunctionsPanelSectionColor must use VinSmart red #EA0B2A")

if __name__ == "__main__":
    unittest.main()
