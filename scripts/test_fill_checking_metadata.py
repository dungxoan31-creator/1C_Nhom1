import unittest
import xml.etree.ElementTree as ET
from pathlib import Path

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent

class TestFillCheckingMetadata(unittest.TestCase):
    def setUp(self):
        self.src_dir = WORKSPACE_ROOT / "src"
        self.ns = {
            "md": "http://v8.1c.ru/8.3/MDClasses",
            "core": "http://v8.1c.ru/8.1/data/core",
            "v8": "http://v8.1c.ru/8.1/data/core"
        }

    def _get_attribute(self, file_path, attr_name):
        tree = ET.parse(file_path)
        root = tree.getroot()
        for attr in root.findall(".//md:Attribute", self.ns):
            name_el = attr.find("md:Properties/md:Name", self.ns)
            if name_el is not None and name_el.text == attr_name:
                return attr
        return None

    def test_hoadon_gtgt_daura_required_fields(self):
        doc_path = self.src_dir / "Documents" / "HoaDonGTGTDauRa.xml"
        required_fields = ["PhapNhan", "DoiTac", "HopDong", "SoHoaDon", "KyHieu", "NgayHoaDon", "TongTienThanhToan"]
        for field in required_fields:
            attr = self._get_attribute(doc_path, field)
            self.assertIsNotNone(attr, f"HoaDonGTGTDauRa must have {field}")
            fc = attr.find("md:Properties/md:FillChecking", self.ns)
            self.assertIsNotNone(fc, f"HoaDonGTGTDauRa.{field} must have FillChecking")
            self.assertEqual(fc.text, "ShowError", f"HoaDonGTGTDauRa.{field} must have FillChecking=ShowError")

    def test_hoadon_nhacungcap_required_fields(self):
        doc_path = self.src_dir / "Documents" / "HoaDonNhaCungCap.xml"
        required_fields = ["PhapNhan", "DoiTac", "HopDong", "SoHoaDon", "NgayHoaDon", "TienTe", "TongTien"]
        for field in required_fields:
            attr = self._get_attribute(doc_path, field)
            self.assertIsNotNone(attr, f"HoaDonNhaCungCap must have {field}")
            fc = attr.find("md:Properties/md:FillChecking", self.ns)
            self.assertIsNotNone(fc, f"HoaDonNhaCungCap.{field} must have FillChecking")
            self.assertEqual(fc.text, "ShowError", f"HoaDonNhaCungCap.{field} must have FillChecking=ShowError")

    def test_phieu_thu_tien_required_fields(self):
        doc_path = self.src_dir / "Documents" / "PhieuThuTienKhachHang.xml"
        required_fields = ["PhapNhan", "DoiTac", "HopDong", "TaiKhoanTien", "KhoanMucDongTien", "TienTe", "SoTien"]
        for field in required_fields:
            attr = self._get_attribute(doc_path, field)
            self.assertIsNotNone(attr, f"PhieuThuTienKhachHang must have {field}")
            fc = attr.find("md:Properties/md:FillChecking", self.ns)
            self.assertIsNotNone(fc, f"PhieuThuTienKhachHang.{field} must have FillChecking")
            self.assertEqual(fc.text, "ShowError", f"PhieuThuTienKhachHang.{field} must have FillChecking=ShowError")

    def test_uynhiemchi_required_fields(self):
        doc_path = self.src_dir / "Documents" / "UyNhiemChi.xml"
        required_fields = ["PhapNhan", "DoiTac", "HopDong", "TaiKhoanTien", "KhoanMucDongTien", "TienTe", "SoTien"]
        for field in required_fields:
            attr = self._get_attribute(doc_path, field)
            self.assertIsNotNone(attr, f"UyNhiemChi must have {field}")
            fc = attr.find("md:Properties/md:FillChecking", self.ns)
            self.assertIsNotNone(fc, f"UyNhiemChi.{field} must have FillChecking")
            self.assertEqual(fc.text, "ShowError", f"UyNhiemChi.{field} must have FillChecking=ShowError")

    def test_catalog_doitac_masothue_required(self):
        cat_path = self.src_dir / "Catalogs" / "DoiTac.xml"
        attr = self._get_attribute(cat_path, "MaSoThue")
        self.assertIsNotNone(attr)
        fc = attr.find("md:Properties/md:FillChecking", self.ns)
        self.assertEqual(fc.text, "ShowError", "DoiTac.MaSoThue must have FillChecking=ShowError")

    def test_non_negative_on_monetary_fields(self):
        docs = [
            ("HoaDonGTGTDauRa.xml", ["TongTienThanhToan", "TienChuaThue", "TienThueVAT"]),
            ("HoaDonNhaCungCap.xml", ["TongTien", "TienDichVu", "TienThueVAT", "TyGia"]),
            ("PhieuThuTienKhachHang.xml", ["SoTien", "TyGia"]),
            ("UyNhiemChi.xml", ["SoTien", "TyGia"])
        ]
        for doc_file, fields in docs:
            doc_path = self.src_dir / "Documents" / doc_file
            for field in fields:
                attr = self._get_attribute(doc_path, field)
                self.assertIsNotNone(attr, f"{doc_file} must have {field}")
                sign = attr.find(".//v8:NumberQualifiers/v8:AllowedSign", self.ns)
                self.assertIsNotNone(sign, f"{doc_file}.{field} must have AllowedSign qualifier")
                self.assertEqual(sign.text, "Nonnegative", f"{doc_file}.{field} AllowedSign must be Nonnegative")

if __name__ == "__main__":
    unittest.main()
