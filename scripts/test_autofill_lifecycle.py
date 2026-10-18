import unittest
from pathlib import Path

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent

class TestAutofillLifecycle(unittest.TestCase):
    def setUp(self):
        self.doc_names = [
            "HoaDonGTGTDauRa",
            "HoaDonNhaCungCap",
            "PhieuThuTienKhachHang",
            "UyNhiemChi",
            "BienBanNghiemThuGiaiDoan"
        ]

    def test_all_documents_have_filling_handler(self):
        for doc in self.doc_names:
            bsl_path = WORKSPACE_ROOT / "src" / "Documents" / doc / "Ext" / "ObjectModule.bsl"
            self.assertTrue(bsl_path.exists(), f"{doc} ObjectModule.bsl must exist")
            content = bsl_path.read_text(encoding="utf-8")
            self.assertIn("Procedure Filling(FillingData, FillingText, StandardProcessing)", content,
                          f"{doc} must implement native Filling event handler")
            self.assertIn("CurrentSessionDate()", content, f"{doc} Filling must set default Date")

    def test_based_on_filling_inheritance(self):
        # HoaDonGTGTDauRa inherits from BienBanNghiemThuGiaiDoan
        ar_inv = (WORKSPACE_ROOT / "src" / "Documents" / "HoaDonGTGTDauRa" / "Ext" / "ObjectModule.bsl").read_text(encoding="utf-8")
        self.assertIn("BienBanNghiemThuGiaiDoan", ar_inv, "HoaDonGTGTDauRa must handle filling from BienBanNghiemThuGiaiDoan")

        # PhieuThuTienKhachHang inherits from HoaDonGTGTDauRa and BienBanNghiemThu
        rcpt = (WORKSPACE_ROOT / "src" / "Documents" / "PhieuThuTienKhachHang" / "Ext" / "ObjectModule.bsl").read_text(encoding="utf-8")
        self.assertIn("HoaDonGTGTDauRa", rcpt, "PhieuThuTienKhachHang must handle filling from HoaDonGTGTDauRa")

        # UyNhiemChi inherits from HoaDonNhaCungCap
        unc = (WORKSPACE_ROOT / "src" / "Documents" / "UyNhiemChi" / "Ext" / "ObjectModule.bsl").read_text(encoding="utf-8")
        self.assertIn("HoaDonNhaCungCap", unc, "UyNhiemChi must handle filling from HoaDonNhaCungCap")

    def test_before_write_auto_calculation(self):
        ar_inv = (WORKSPACE_ROOT / "src" / "Documents" / "HoaDonGTGTDauRa" / "Ext" / "ObjectModule.bsl").read_text(encoding="utf-8")
        self.assertIn("TongTienThanhToan = TienChuaThue + TienThueVAT", ar_inv)

if __name__ == "__main__":
    unittest.main()
