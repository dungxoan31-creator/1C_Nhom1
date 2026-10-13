"""Accounting correspondence must retain a separate analytical key per side."""

import unittest
import xml.etree.ElementTree as ET
from pathlib import Path


GL_METADATA = Path(__file__).resolve().parents[1] / "src/AccountingRegisters/SoCaiKeToan.xml"
NS = {"md": "http://v8.1c.ru/8.3/MDClasses"}


class TestGLDimensions(unittest.TestCase):
    def test_each_side_can_identify_its_own_subledger_obligation(self):
        root = ET.parse(GL_METADATA).getroot()
        names = {x.text for x in root.findall(".//md:Attribute/md:Properties/md:Name", NS)}
        required = {f"{base}{side}" for base in ("DoiTac", "HopDong", "ChungTuGoc", "TaiKhoanTien")
                    for side in ("No", "Co")}
        self.assertFalse(required - names, f"Missing GL side attributes: {sorted(required - names)}")


if __name__ == "__main__":
    unittest.main()
