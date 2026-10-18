import unittest
import xml.etree.ElementTree as ET
from pathlib import Path

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent

class TestDataModelIntegrity(unittest.TestCase):
    def setUp(self):
        self.src_dir = WORKSPACE_ROOT / "src"
        self.ns = {"md": "http://v8.1c.ru/8.3/MDClasses", "core": "http://v8.1c.ru/8.1/data/core"}

    def test_catalogs_autonumbering_and_unique(self):
        """All Catalogs must have Autonumbering and CheckUnique enabled."""
        cats = list((self.src_dir / "Catalogs").glob("*.xml"))
        self.assertGreaterEqual(len(cats), 8, "Must have at least 8 Catalogs")
        for cat in cats:
            tree = ET.parse(cat)
            root = tree.getroot()
            cu = root.find(".//md:CheckUnique", self.ns)
            an = root.find(".//md:Autonumbering", self.ns)
            self.assertIsNotNone(cu, f"{cat.name} must declare CheckUnique")
            self.assertEqual(cu.text, "true", f"{cat.name} CheckUnique must be true")
            self.assertIsNotNone(an, f"{cat.name} must declare Autonumbering")
            self.assertEqual(an.text, "true", f"{cat.name} Autonumbering must be true")

    def test_documents_autonumbering_and_unique(self):
        """All Documents must have Autonumbering and CheckUnique enabled."""
        docs = list((self.src_dir / "Documents").glob("*.xml"))
        self.assertGreaterEqual(len(docs), 5, "Must have at least 5 Documents")
        for doc in docs:
            tree = ET.parse(doc)
            root = tree.getroot()
            cu = root.find(".//md:CheckUnique", self.ns)
            an = root.find(".//md:Autonumbering", self.ns)
            self.assertIsNotNone(cu, f"{doc.name} must declare CheckUnique")
            self.assertEqual(cu.text, "true", f"{doc.name} CheckUnique must be true")
            self.assertIsNotNone(an, f"{doc.name} must declare Autonumbering")
            self.assertEqual(an.text, "true", f"{doc.name} Autonumbering must be true")

    def test_registers_dimensions_and_resources(self):
        """All Accumulation and Information Registers must have Dimensions and Resources."""
        acc_regs = list((self.src_dir / "AccumulationRegisters").glob("*.xml"))
        self.assertGreaterEqual(len(acc_regs), 3, "Must have at least 3 AccumulationRegisters")
        for reg in acc_regs:
            tree = ET.parse(reg)
            root = tree.getroot()
            dims = root.findall(".//md:Dimension", self.ns)
            res = root.findall(".//md:Resource", self.ns)
            self.assertGreater(len(dims), 0, f"{reg.name} must have at least 1 Dimension")
            self.assertGreater(len(res), 0, f"{reg.name} must have at least 1 Resource")

        info_regs = list((self.src_dir / "InformationRegisters").glob("*.xml"))
        self.assertGreaterEqual(len(info_regs), 1, "Must have at least 1 InformationRegister")
        for reg in info_regs:
            tree = ET.parse(reg)
            root = tree.getroot()
            dims = root.findall(".//md:Dimension", self.ns)
            res = root.findall(".//md:Resource", self.ns)
            self.assertGreater(len(dims), 0, f"{reg.name} must have at least 1 Dimension")
            self.assertGreater(len(res), 0, f"{reg.name} must have at least 1 Resource")

    def test_foreign_key_strong_typing(self):
        """Document relational attributes must use strongly typed 1C References."""
        docs = list((self.src_dir / "Documents").glob("*.xml"))
        for doc in docs:
            tree = ET.parse(doc)
            root = tree.getroot()
            for attr in root.findall(".//md:Attribute", self.ns):
                name = attr.find("md:Properties/md:Name", self.ns).text
                if name in ["PhapNhan", "DoiTac", "HopDong", "TaiKhoanTien", "KhoanMucDongTien", "TienTe"]:
                    types = [t.text for t in attr.findall(".//core:Type", self.ns)]
                    self.assertTrue(any(t.startswith("cfg:CatalogRef.") for t in types),
                                    f"{doc.name}.{name} must reference CatalogRef")
                elif name == "TrangThai" or name == "TrangThaiHDDT":
                    types = [t.text for t in attr.findall(".//core:Type", self.ns)]
                    self.assertTrue(any(t.startswith("cfg:EnumRef.") for t in types),
                                    f"{doc.name}.{name} must reference EnumRef")

if __name__ == "__main__":
    unittest.main()
