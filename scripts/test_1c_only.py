"""Guard the configuration against reintroducing external system adapters."""

from pathlib import Path
import unittest
import xml.etree.ElementTree as ET


ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"


class Test1COnly(unittest.TestCase):
    def test_no_external_adapters(self):
        config = ET.parse(SRC / "Configuration.xml").getroot()
        names = {element.text for element in config.iter() if element.text}
        removed = {
            "DongBoButToanSAP", "DongBoSAPHangNgay", "TrangThaiDongBoSAP",
            "TuDongDongBoSAP", "WebhookNganHang", "KichHoatWebhookNganHang",
            "LichSuGiaoDichNganHang", "TichHopNganHangServer",
            "TichHopHoaDonDienTuServer", "CapNhatTyGiaNgoaiTeTuDong",
        }
        self.assertFalse(names & removed, names & removed)
        self.assertFalse(list((SRC / "HTTPServices").glob("*.xml")))
        self.assertFalse(list((SRC / "ScheduledJobs").glob("*.xml")))
        lifecycle = (SRC / "CommonModules" / "QuanLyVongDoiChungTuServer"
                     / "Ext" / "Module.bsl").read_text(encoding="utf-8")
        self.assertNotIn("SA_BankingIntegration", lifecycle)


if __name__ == "__main__":
    unittest.main()
