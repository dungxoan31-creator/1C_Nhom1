import unittest
from pathlib import Path

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent

class TestDataProcessorRegistration(unittest.TestCase):
    def test_dataprocessor_files_and_registration(self):
        dp_xml = WORKSPACE_ROOT / "src" / "DataProcessors" / "BanLamViecWebERP.xml"
        self.assertTrue(dp_xml.exists(), "BanLamViecWebERP.xml must exist")
        
        obj_bsl = WORKSPACE_ROOT / "src" / "DataProcessors" / "BanLamViecWebERP" / "Ext" / "ObjectModule.bsl"
        self.assertTrue(obj_bsl.exists(), "ObjectModule.bsl must exist")
        
        mgr_bsl = WORKSPACE_ROOT / "src" / "DataProcessors" / "BanLamViecWebERP" / "Ext" / "ManagerModule.bsl"
        self.assertTrue(mgr_bsl.exists(), "ManagerModule.bsl must exist")
        
        config_xml = WORKSPACE_ROOT / "src" / "Configuration.xml"
        self.assertIn("<DataProcessor>BanLamViecWebERP</DataProcessor>", config_xml.read_text(encoding="utf-8"))
        
        dump_info = WORKSPACE_ROOT / "src" / "ConfigDumpInfo.xml"
        self.assertIn("DataProcessor.BanLamViecWebERP", dump_info.read_text(encoding="utf-8"))

if __name__ == "__main__":
    unittest.main()
