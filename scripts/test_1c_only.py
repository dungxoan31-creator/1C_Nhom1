"""Guard the configuration against reintroducing external system adapters (1C-Only Architecture Gate)."""

from pathlib import Path
import unittest
import xml.etree.ElementTree as ET
import re


ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"


class Test1COnly(unittest.TestCase):
    REMOVED_ADAPTERS = {
        "DongBoButToanSAP", "DongBoSAPHangNgay", "TrangThaiDongBoSAP",
        "TuDongDongBoSAP", "WebhookNganHang", "KichHoatWebhookNganHang",
        "LichSuGiaoDichNganHang", "TichHopNganHangServer",
        "TichHopHoaDonDienTuServer", "CapNhatTyGiaNgoaiTeTuDong",
    }

    def test_no_external_adapters_in_config(self):
        """Kiem tra Configuration.xml sach, khong co bat ky adapter hoac job dong bo ngoai."""
        config = ET.parse(SRC / "Configuration.xml").getroot()
        names = {element.text for element in config.iter() if element.text}
        violations = names & self.REMOVED_ADAPTERS
        self.assertFalse(violations, f"Phat hien doi tuong tich hop ngoai vi pham: {violations}")
        self.assertFalse(list((SRC / "HTTPServices").glob("*.xml")), "HTTPServices phai rong")
        self.assertFalse(list((SRC / "ScheduledJobs").glob("*.xml")), "ScheduledJobs phai rong")
        lifecycle = (SRC / "CommonModules" / "QuanLyVongDoiChungTuServer"
                     / "Ext" / "Module.bsl").read_text(encoding="utf-8")
        self.assertNotIn("SA_BankingIntegration", lifecycle)

    def test_counter_example_detects_external_adapter_violation(self):
        """Phan vi du: Kiem tra guard PHAI bat loi va fail neu bat ky adapter nao duoc them lai."""
        # Gia lap XML chua doi tuong cam DongBoButToanSAP
        mock_xml_content = """<Configuration>
            <DataProcessors>
                <DataProcessor>DongBoButToanSAP</DataProcessor>
            </DataProcessors>
        </Configuration>"""
        mock_root = ET.fromstring(mock_xml_content)
        mock_names = {element.text for element in mock_root.iter() if element.text}
        
        detected_violations = mock_names & self.REMOVED_ADAPTERS
        self.assertTrue(len(detected_violations) > 0, "Guard phai phat hien phan vi du DongBoButToanSAP")
        self.assertIn("DongBoButToanSAP", detected_violations)

    def test_source_code_has_no_active_sap_sync_procedures(self):
        """Kiem tra source code BSL khong co ham thuc thi dong bo SAP hoac HTTP external ledger."""
        forbidden_patterns = [
            r"Procedure\s+DongBo.*SAP",
            r"Function\s+DongBo.*SAP",
            r"HTTPConnection.*sap",
            r"RFC_.*CALL",
            r"BAPI_.*CALL",
        ]
        
        for bsl_file in SRC.glob("**/*.bsl"):
            content = bsl_file.read_text(encoding="utf-8", errors="ignore")
            for pattern in forbidden_patterns:
                matches = re.findall(pattern, content, re.IGNORECASE)
                self.assertFalse(matches, f"Phat hien ham dong bo ngoai {pattern} trong {bsl_file.name}")


if __name__ == "__main__":
    unittest.main()
