# -*- coding: utf-8 -*-
"""
Test Runner: test_task2_security.py
Audit Task 2 / Gate 2: Maker-Checker, Segregation of Duties (SoD) & Persisted State Machine
"""

import io
import os
import re
import sys
import time
import unittest
import xml.etree.ElementTree as ET

if sys.stdout.encoding != 'utf-8':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))


class TestSecurityMakerChecker(unittest.TestCase):
    def test_invoice_metadata(self):
        """Kiểm tra sự hiện diện của thuộc tính NguoiLap và NguoiDuyet trong metadata Hóa đơn."""
        docs = [
            os.path.join(REPO_ROOT, "src", "Documents", "HoaDonGTGTDauRa.xml"),
            os.path.join(REPO_ROOT, "src", "Documents", "HoaDonNhaCungCap.xml"),
        ]
        for doc_path in docs:
            self.assertTrue(os.path.exists(doc_path), f"File không tồn tại: {doc_path}")
            with open(doc_path, "r", encoding="utf-8") as f:
                content = f.read()
            self.assertIn("<Name>NguoiLap</Name>", content, f"Thiếu thuộc tính NguoiLap trong {os.path.basename(doc_path)}")
            self.assertIn("<Name>NguoiDuyet</Name>", content, f"Thiếu thuộc tính NguoiDuyet trong {os.path.basename(doc_path)}")

    def test_maker_checker_enforcement(self):
        """Kiểm tra logic cưỡng chế Maker-Checker và chặn DataExchange.Load bypass trong BSL."""
        common_mod = os.path.join(REPO_ROOT, "src", "CommonModules", "PhanQuyenBaoMatServer", "Ext", "Module.bsl")
        self.assertTrue(os.path.exists(common_mod), f"File không tồn tại: {common_mod}")
        with open(common_mod, "r", encoding="utf-8") as f:
            code = f.read()
        self.assertIn("KiemTraMakerChecker", code, "CommonModule thiếu hàm KiemTraMakerChecker")
        self.assertIn("NguoiLap = NguoiDuyet", code, "Thiếu kiểm tra NguoiLap trùng NguoiDuyet")
        
        # Kiểm tra 4 chứng từ tài chính chính
        checked_docs = [
            os.path.join(REPO_ROOT, "src", "Documents", "HoaDonGTGTDauRa", "Ext", "ObjectModule.bsl"),
            os.path.join(REPO_ROOT, "src", "Documents", "HoaDonNhaCungCap", "Ext", "ObjectModule.bsl"),
            os.path.join(REPO_ROOT, "src", "Documents", "UyNhiemChi", "Ext", "ObjectModule.bsl"),
            os.path.join(REPO_ROOT, "src", "Documents", "CanTruCongNoNoiBo", "Ext", "ObjectModule.bsl"),
        ]
        for obj_path in checked_docs:
            self.assertTrue(os.path.exists(obj_path), f"File không tồn tại: {obj_path}")
            with open(obj_path, "r", encoding="utf-8") as f:
                obj_code = f.read()
            self.assertIn("KiemTraMakerChecker", obj_code, f"{os.path.basename(os.path.dirname(obj_path))} chưa gọi KiemTraMakerChecker")
            # Kiểm tra chặn DataExchange bypass
            self.assertIn("DataExchange.Load", obj_code, f"{os.path.basename(os.path.dirname(obj_path))} thiếu kiểm soát DataExchange")


if __name__ == "__main__":
    unittest.main()
