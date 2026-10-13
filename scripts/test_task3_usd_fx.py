# -*- coding: utf-8 -*-
"""
Test Runner: test_task3_usd_fx.py
Audit Task 2.2 / Gate 4: USD Payments, Account 1122 Book Rate & FX Gain/Loss (515/635)
"""

import io
import os
import sys
import unittest

if sys.stdout.encoding != 'utf-8':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))


class TestTask3UsdFx(unittest.TestCase):
    def test_usd_fx_gain_loss_logic(self):
        """Kiểm tra logic hạch toán chênh lệch tỷ giá phát sinh (TK 515 / 635) trong UyNhiemChi.bsl."""
        unc_file = os.path.join(REPO_ROOT, "src", "Documents", "UyNhiemChi", "Ext", "ObjectModule.bsl")
        self.assertTrue(os.path.exists(unc_file), f"File không tồn tại: {unc_file}")
        with open(unc_file, "r", encoding="utf-8") as f:
            code = f.read()

        # Kiểm tra sự hiện diện của hạch toán 635 (lỗ) và 515 (lãi)
        self.assertIn('TK635 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("635")', code, "Thiếu tìm TK 635 trong UyNhiemChi.bsl")
        self.assertIn('TK515 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("515")', code, "Thiếu tìm TK 515 trong UyNhiemChi.bsl")
        self.assertIn("RowFX.AccountDr = TK635", code, "Thiếu bút toán Nợ 635 khi lỗ tỷ giá")
        self.assertIn("RowFX.AccountCr = TK515", code, "Thiếu bút toán Có 515 khi lãi tỷ giá")
        self.assertIn("ChenhLech = SoTienThucTra - SoTienGhiSoAP", code, "Thiếu phép tính chênh lệch tỷ giá thực tế")
        self.assertIn("AccumulationRegister.CongNoPhaiTra.Balance", code, "Thiếu truy vấn số dư thực tế CongNoPhaiTra.Balance")
        self.assertIn("AccumulationRegister.DongTien.Balance", code, "Thiếu truy vấn số dư thực tế DongTien.Balance")
        self.assertIn("TaiKhoanTienPhi", code, "Thiếu xác định nguồn tài khoản tiền phí tách bạch")


if __name__ == "__main__":
    unittest.main()
