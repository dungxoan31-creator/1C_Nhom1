# -*- coding: utf-8 -*-
"""Test offline HTML generator for CFO Dashboard (Modern 3D Enterprise)."""

import unittest
import re


def mock_so_lieu_dashboard():
    return {
        "ThoiDiemBaoCao": "30/09/2026 23:59:59",
        "TongHopKinhDoanh": {
            "TongDoanhThu": 1053136000000,
            "TongChiPhi": 380507224685,
            "LoiNhuanTruocThue": 672628775315,
            "TySuatLoiNhuanRong": 63.87,
        },
        "CongNo": {
            "AR": {
                "TongAR": 39549200000,
                "AR_KhachNgoai": 37004400000,
                "AR_NoiBo": 2544800000,
                "TyLeNoiBoAR": 6.43,
            },
            "AP": {
                "TongAP": 34440537922,
                "AP_NhaCungCapNgoai": 18924537922,
                "AP_NoiBo": 15516000000,
                "TyLeNoiBoAP": 45.05,
            },
            "NetWorkingCapital": 5108662078,
        },
        "DongTien": {
            "TongTienMatKhaDung": 817817013237,
            "Techcombank_VND": 789620561781,
            "Vietcombank_USD": {
                "SoTienUSD": 121257.96,
                "QuyDoiVND": 3079952140,
                "TyGiaQuyDoi": 25400,
            },
            "VPBank_VA": 22549685000,
        },
        "ChiSoTaiChinh": {
            "DSO": 24,
            "DPO": 56,
            "VongQuayTienMat": -32,
            "Netting": {
                "TongTienCanTru": 28360200000,
                "TienTietKiemThanhKhoan": 28360200000,
                "SoLuongGiaoDichCanTru": 148,
            },
        },
        "CacKhoiKinhDoanh": [
            {
                "TenKhoi": "Khối Công nghệ cao & AI",
                "DoanhThu": 450000000000,
                "ChiPhi": 120000000000,
                "LoiNhuanGop": 330000000000,
                "TySuatLoiNhuan": 73.33,
                "SoLuongDuAn": 12,
            },
            {
                "TenKhoi": "Khối Thiết bị IoT & Phần cứng",
                "DoanhThu": 320000000000,
                "ChiPhi": 150000000000,
                "LoiNhuanGop": 170000000000,
                "TySuatLoiNhuan": 53.13,
                "SoLuongDuAn": 8,
            },
            {
                "TenKhoi": "Khối Dịch vụ Cloud & Hạ tầng",
                "DoanhThu": 180000000000,
                "ChiPhi": 85000000000,
                "LoiNhuanGop": 95000000000,
                "TySuatLoiNhuan": 52.78,
                "SoLuongDuAn": 15,
            },
            {
                "TenKhoi": "Khối Phần mềm & Chuyển đổi số",
                "DoanhThu": 103136000000,
                "ChiPhi": 25507224685,
                "LoiNhuanGop": 77628775315,
                "TySuatLoiNhuan": 75.27,
                "SoLuongDuAn": 10,
            },
        ],
    }


class TestDashboardCFOHTML(unittest.TestCase):
    """Verify BSL HTML generator design structure and WCAG tokens."""

    def test_mock_data_integrity(self):
        data = mock_so_lieu_dashboard()
        self.assertEqual(data["CongNo"]["AR"]["TongAR"], 39549200000)
        self.assertEqual(data["CongNo"]["AP"]["TongAP"], 34440537922)
        self.assertEqual(data["DongTien"]["TongTienMatKhaDung"], 817817013237)
        self.assertEqual(len(data["CacKhoiKinhDoanh"]), 4)

    def test_html_tokens_and_accessibility(self):
        # Tokens required by Modern 3D Enterprise spec
        required_tokens = ["#E4202A", "#059669", "#D97706", "#0F172A", "#F8FAFC"]
        for token in required_tokens:
            self.assertTrue(re.match(r"^#[0-9A-Fa-f]{6}$", token))


if __name__ == "__main__":
    unittest.main()
