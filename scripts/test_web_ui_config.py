import unittest
import xml.etree.ElementTree as ET
from pathlib import Path

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent

class TestWebUIConfiguration(unittest.TestCase):
    def setUp(self):
        self.config_xml_path = WORKSPACE_ROOT / "src" / "Configuration.xml"
        self.dump_info_path = WORKSPACE_ROOT / "src" / "ConfigDumpInfo.xml"
        self.vrd_path = WORKSPACE_ROOT / "default.vrd"
        self.publish_script_path = WORKSPACE_ROOT / "scripts" / "publish_web_client.ps1"

    def test_configuration_web_application_enabled(self):
        self.assertTrue(self.config_xml_path.exists(), "Configuration.xml must exist")
        content = self.config_xml_path.read_text(encoding="utf-8")
        self.assertIn("PlatformApplication", content, "Configuration.xml must include PlatformApplication in UsePurposes")
        self.assertIn("<InterfaceCompatibilityMode>Taxi</InterfaceCompatibilityMode>", content, "Interface mode must be Taxi")

    def test_configuration_child_objects_registered(self):
        content = self.config_xml_path.read_text(encoding="utf-8")
        self.assertIn("<CommonForm>TrangChuTongQuan</CommonForm>", content, "CommonForm.TrangChuTongQuan must be registered")
        self.assertIn("<CommonModule>BangDieuKhienServer</CommonModule>", content, "CommonModule.BangDieuKhienServer must be registered")
        self.assertIn("<CommonTemplate>MauHTMLTrangChu</CommonTemplate>", content, "CommonTemplate.MauHTMLTrangChu must be registered")

    def test_config_dump_info_registered(self):
        self.assertTrue(self.dump_info_path.exists(), "ConfigDumpInfo.xml must exist")
        content = self.dump_info_path.read_text(encoding="utf-8")
        self.assertIn("TrangChuTongQuan", content, "TrangChuTongQuan must be in ConfigDumpInfo")
        self.assertIn("BangDieuKhienServer", content, "BangDieuKhienServer must be in ConfigDumpInfo")
        self.assertIn("MauHTMLTrangChu", content, "MauHTMLTrangChu must be in ConfigDumpInfo")

    def test_vrd_file_structure(self):
        self.assertTrue(self.vrd_path.exists(), "default.vrd must exist")
        tree = ET.parse(self.vrd_path)
        root = tree.getroot()
        self.assertTrue(root.tag.endswith("point"), "Root tag must be point")
        self.assertEqual(root.attrib.get("base"), "/vinsmart", "Virtual directory base must be /vinsmart")

    def test_publish_script_exists(self):
        self.assertTrue(self.publish_script_path.exists(), "publish_web_client.ps1 must exist")

if __name__ == "__main__":
    unittest.main()
