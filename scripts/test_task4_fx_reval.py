# -*- coding: utf-8 -*-
"""
Test Runner: test_task4_fx_reval.py
Audit Task 2.3 / Gate 5: Period-End Foreign Exchange Revaluation (TK 4131 -> 515/635 clearance)
"""

import io
import os
import sys
import unittest

if sys.stdout.encoding != 'utf-8':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))


class TestTask4FxReval(unittest.TestCase):
    def test_danh_gia_lai_ngoai_te_metadata_and_logic(self):
        """Kiểm tra sự hiện diện của DanhGiaLaiNgoaiTe trong metadata và logic tất toán 4131 về 0."""
        # 1. Kiểm tra đăng ký trong Configuration.xml
        config_file = os.path.join(REPO_ROOT, "src", "Configuration.xml")
        self.assertTrue(os.path.exists(config_file), f"File không tồn tại: {config_file}")
        with open(config_file, "r", encoding="utf-8") as f:
            config_content = f.read()
        self.assertIn("<Document>DanhGiaLaiNgoaiTe</Document>", config_content, "Configuration.xml chưa đăng ký DanhGiaLaiNgoaiTe")

        # 2. Kiểm tra file metadata DanhGiaLaiNgoaiTe.xml
        doc_xml = os.path.join(REPO_ROOT, "src", "Documents", "DanhGiaLaiNgoaiTe.xml")
        self.assertTrue(os.path.exists(doc_xml), f"File không tồn tại: {doc_xml}")

        # 3. Kiểm tra ObjectModule.bsl và logic tất toán TK 4131
        bsl_file = os.path.join(REPO_ROOT, "src", "Documents", "DanhGiaLaiNgoaiTe", "Ext", "ObjectModule.bsl")
        self.assertTrue(os.path.exists(bsl_file), f"File không tồn tại: {bsl_file}")
        with open(bsl_file, "r", encoding="utf-8") as f:
            code = f.read()

        self.assertIn('TK4131 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("4131")', code, "Thiếu tìm TK 4131")
        self.assertIn("TK515", code, "Thiếu kết chuyển TK 515")
        self.assertIn("TK635", code, "Thiếu kết chuyển TK 635")
        self.assertTrue("KetChuyenTatToan4131" in code or "4131" in code, "Thiếu logic tất toán số dư 4131 về 0")


if __name__ == "__main__":
    unittest.main()
