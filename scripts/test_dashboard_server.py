import unittest
from pathlib import Path
import xml.etree.ElementTree as ET

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent

class TestDashboardServerModule(unittest.TestCase):
    def setUp(self):
        self.xml_path = WORKSPACE_ROOT / "src" / "CommonModules" / "BangDieuKhienServer.xml"
        self.bsl_path = WORKSPACE_ROOT / "src" / "CommonModules" / "BangDieuKhienServer" / "Ext" / "Module.bsl"

    def test_xml_metadata_exists_and_configured(self):
        self.assertTrue(self.xml_path.exists(), "BangDieuKhienServer.xml must exist")
        content = self.xml_path.read_text(encoding="utf-8")
        self.assertIn("<Server>true</Server>", content, "Module must have Server flag set to true")
        self.assertIn("<ServerCall>true</ServerCall>", content, "Module must have ServerCall flag set to true")

    def test_bsl_module_exists_and_has_required_functions(self):
        self.assertTrue(self.bsl_path.exists(), "Module.bsl must exist")
        bsl_content = self.bsl_path.read_text(encoding="utf-8")
        self.assertIn("Function LayDuLieuTongQuan", bsl_content, "Must export Function LayDuLieuTongQuan")
        self.assertIn("Export", bsl_content, "Function must be Exported")

    def test_bsl_module_aggregates_kpis(self):
        bsl_content = self.bsl_path.read_text(encoding="utf-8")
        self.assertIn("CongNoPhaiThu", bsl_content, "Must query CongNoPhaiThu")
        self.assertIn("CongNoPhaiTra", bsl_content, "Must query CongNoPhaiTra")
        self.assertIn("TongDoanhThu", bsl_content, "Must calculate TongDoanhThu")
        self.assertIn("TienKhaDung", bsl_content, "Must calculate TienKhaDung")
        self.assertIn("TopNoQuaHan", bsl_content, "Must query TopNoQuaHan")

if __name__ == "__main__":
    unittest.main()
