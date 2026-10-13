# -*- coding: utf-8 -*-
"""
KIEM THU TU DONG 4 BAO CAO QUAN TRI CHUYEN SAU (EXECUTIVE REPORTS TEST SUITE)
Direction 1: Nghiem thu truc quan 4 Bao cao Quan tri Chuyen sau (VSF)

Cac bao cao kiem thu:
1. BaoCaoTuoiNoPhanTachNoiBo (AR & AP 5 Buckets + Operational Safety Gate)
2. MaTranCanTruNoiBoTapDoan (Bilateral & Multilateral Bridge Netting, Delta = 0)
3. DoiSoatKenhThanhToanVaDongTienAo (Payment Gateways Reconciliation, Gross = Fee + Net, Delta = 0)
4. CanhBaoHanMucVaGiaHanCloud (USD Quota & Expiration Alerts, FX Exchange Rate)
"""

import os
import sys
import json
import subprocess
import unittest

ROOT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
JSON_PATH = os.path.join(ROOT_DIR, "docs", "superpowers", "reports", "executive_reports_data.json")
EXE_PATH = r"C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe"
IB_PATH = os.path.join(ROOT_DIR, "Infobase_FullData")

class TestExecutiveReports(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        # Luon xuat moi truc tiep tu Infobase_FullData de dam bao tinh xac thuc kiem toan doc lap
        if os.path.exists(JSON_PATH):
            try:
                os.remove(JSON_PATH)
            except:
                pass
        
        print("[*] Khoi chay 1C Enterprise de trich xuat truc tiep 4 bao cao quan tri...")
        assert os.path.exists(EXE_PATH), f"Khong tim thay 1C: {EXE_PATH}"
        assert os.path.exists(IB_PATH), f"Khong tim thay Infobase: {IB_PATH}"
        res = subprocess.run([
            EXE_PATH, "ENTERPRISE",
            "/F", IB_PATH,
            "/N", "Admin",
            "/C", "ExportExecutiveReports",
            "/DisableStartupDialogs", "/DisableStartupMessages"
        ], capture_output=True, timeout=90)
        assert res.returncode == 0, f"1C export that bai voi code {res.returncode}"

        assert os.path.exists(JSON_PATH), f"Khong tim thay file JSON sau xuat: {JSON_PATH}"
        with open(JSON_PATH, "r", encoding="utf-8") as f:
            cls.data = json.load(f)

    def test_00_general_status(self):
        """Kiem tra trang thai tong the cua qua trinh xuat bao cao"""
        self.assertEqual(self.data.get("TrangThai"), "EXECUTIVE_REPORTS_SUCCESS_100")
        self.assertIn("Report1_TuoiNo", self.data)
        self.assertIn("Report2_MaTranNetting", self.data)
        self.assertIn("Report3_DoiSoatKenh", self.data)
        self.assertIn("Report4_CanhBaoCloud", self.data)

    def test_01_tuoi_no_phan_tach_noi_bo(self):
        """Kiem tra Bao cao tuoi no phan tach noi bo: 5 Buckets & Safety Gate"""
        rep = self.data["Report1_TuoiNo"]
        self.assertIsNotNone(rep)
        
        ar = rep.get("AR_Buckets", {})
        ap = rep.get("AP_Buckets", {})
        
        # 1. Kiem tra day du 5 buckets cho AR
        for b in ["TrongHan", "QuaHan1_30", "QuaHan31_60", "QuaHan61_90", "QuaHanTren90", "TongCong"]:
            self.assertIn(b, ar, f"Thieu bucket {b} trong AR")
            self.assertGreater(ar[b], 0, f"Bucket {b} cua AR phai co so du duong")
            
        sum_ar = (ar["TrongHan"] + ar["QuaHan1_30"] + ar["QuaHan31_60"] + 
                  ar["QuaHan61_90"] + ar["QuaHanTren90"])
        self.assertEqual(sum_ar, ar["TongCong"], "Tong 5 buckets AR phai bang TongCong AR")
        
        # 2. Kiem tra day du 5 buckets cho AP
        for b in ["TrongHan", "QuaHan1_30", "QuaHan31_60", "QuaHan61_90", "QuaHanTren90", "TongCong"]:
            self.assertIn(b, ap, f"Thieu bucket {b} trong AP")
            self.assertGreater(ap[b], 0, f"Bucket {b} cua AP phai co so du duong")
            
        sum_ap = (ap["TrongHan"] + ap["QuaHan1_30"] + ap["QuaHan31_60"] + 
                  ap["QuaHan61_90"] + ap["QuaHanTren90"])
        self.assertEqual(sum_ap, ap["TongCong"], "Tong 5 buckets AP phai bang TongCong AP")
        
        # 3. Kiem tra Operational Safety Gate
        gate = rep.get("SafetyGateSummary", {})
        self.assertGreater(gate.get("TongSoDoiTacNoiBo", 0), 0)
        # Tat ca doi tac noi bo PHAI co CamKhoaDichVu = True (100% tuyet doi)
        self.assertEqual(gate["SoNoiBoCamKhoa"], gate["TongSoDoiTacNoiBo"], 
                         "100% doi tac noi bo phai co CamKhoaDichVu = True")
        self.assertGreater(gate.get("SoNoiBoCanhBaoCFO", 0), 0, "Phai co doi tac noi bo qua han kich hoat CanhBaoCFOVaNetting")
        self.assertGreater(gate.get("TongSoKhachNgoai", 0), 0)
        self.assertGreater(gate.get("SoDeXuatKhoaAPI", 0), 0, "Phai co khach hang ngoai qua han >60d de xuat khoa API")
        
        # 4. Kiem tra chi tiet tung dong AR phu hop voi Safety Gate
        chitiet = rep.get("ChiTietAR", [])
        self.assertGreater(len(chitiet), 0)
        for item in chitiet:
            if item.get("LaBenLienKet"):
                self.assertTrue(item.get("CamKhoaDichVu"), f"Doi tac noi bo {item.get('MaDoiTac')} phai co CamKhoaDichVu = True")
                self.assertFalse(item.get("DeXuatKhoaDichVu"), f"Doi tac noi bo {item.get('MaDoiTac')} tuyet doi khong duoc de xuat khoa")
                if item.get("SoNgayQuaHan", 0) > 60:
                    self.assertEqual(item.get("TrangThaiXuLy"), "CanhBaoCFOVaNetting")
                elif item.get("SoNgayQuaHan", 0) > 0:
                    self.assertEqual(item.get("TrangThaiXuLy"), "DoiChieuNoiBo")
            else:
                if item.get("SoNgayQuaHan", 0) > 60:
                    self.assertTrue(item.get("DeXuatKhoaDichVu"), f"Khach ngoai {item.get('MaDoiTac')} qua han >60d phai de xuat khoa API")
                    self.assertEqual(item.get("TrangThaiXuLy"), "KhoaDichVuAPI")

    def test_02_ma_tran_can_tru_noi_bo(self):
        """Kiem tra Ma tran can tru cong no noi bo: Song phuong & Bac cau (Delta = 0)"""
        rep = self.data["Report2_MaTranNetting"]
        self.assertIsNotNone(rep)
        
        tong_gt = rep.get("TongGiaTriCanTru", 0)
        song_phuong = rep.get("TongCanTruSongPhuong", 0)
        bac_cau = rep.get("TongCanTruBacCau", 0)
        delta = rep.get("DeltaCanDoi", 0)
        so_ct = rep.get("TongSoChungTu", 0)
        
        self.assertGreater(tong_gt, 0, "Tong gia tri can tru phai lon hon 0")
        self.assertGreater(song_phuong, 0, "Can tru song phuong phai lon hon 0")
        self.assertGreater(bac_cau, 0, "Can tru bac cau phai lon hon 0")
        self.assertEqual(tong_gt, song_phuong + bac_cau, "Tong gia tri phai bang song phuong + bac cau")
        self.assertEqual(delta, 0, "Delta can doi can tru phai bang 0 (Delta = 0)")
        self.assertGreater(so_ct, 0, "Phai co it nhat 1 chung tu can tru")
        
        # Kiem tra cac doi tac Vingroup chu chot deu co so lieu can tru
        doi_tac = rep.get("CacDoiTacChinh", {})
        self.assertGreater(doi_tac.get("VinFastVN", 0), 0)
        self.assertGreater(doi_tac.get("VinFastProd", 0), 0)
        self.assertGreater(doi_tac.get("VinFastTrading", 0), 0)
        self.assertGreater(doi_tac.get("GSM", 0), 0)
        self.assertGreater(doi_tac.get("Vinhomes", 0), 0)
        self.assertGreater(doi_tac.get("Vinmec", 0), 0)
        self.assertGreater(doi_tac.get("Vinpearl", 0), 0)
        self.assertGreater(doi_tac.get("VGreen", 0), 0)
        self.assertGreater(doi_tac.get("VIC", 0), 0)
        
        # Kiem tra danh sach chi tiet cap can tru
        chitiet_cap = rep.get("ChiTietTheoCap", [])
        self.assertGreater(len(chitiet_cap), 0)
        co_bac_cau = any(c.get("LaCanTruBacCau") for c in chitiet_cap)
        co_song_phuong = any(not c.get("LaCanTruBacCau") for c in chitiet_cap)
        self.assertTrue(co_bac_cau, "Phai co ban ghi can tru bac cau")
        self.assertTrue(co_song_phuong, "Phai co ban ghi can tru song phuong")

    def test_03_doi_soat_kenh_thanh_toan(self):
        """Kiem tra Doi soat kenh thanh toan va dong tien ao: Gross = Phi + Net, Delta = 0"""
        rep = self.data["Report3_DoiSoatKenh"]
        self.assertIsNotNone(rep)
        
        gross = rep.get("TongGross", 0)
        phi = rep.get("TongPhiKenh", 0)
        net = rep.get("TongNetThucNhan", 0)
        delta = rep.get("DeltaCanDoi", 0)
        ty_le_phi = rep.get("TyLePhiTrungBinh", 0)
        so_bk = rep.get("TongSoBangKe", 0)
        
        self.assertGreater(gross, 0, "Tong Gross phai lon hon 0")
        self.assertGreater(phi, 0, "Tong Phi kenh phai lon hon 0")
        self.assertGreater(net, 0, "Tong Net thuc nhan phai lon hon 0")
        self.assertEqual(gross, phi + net, "Gross phai bang Phi + Net")
        self.assertEqual(delta, 0, "Delta can doi doi soat phai bang 0")
        self.assertGreater(so_bk, 0, "So bang ke doi soat phai lon hon 0")
        self.assertGreater(ty_le_phi, 0, "Ty le phi trung binh phai lon hon 0")
        self.assertLess(ty_le_phi, 5.0, "Ty le phi trung binh phai hop ly (<5%)")
        
        # Kiem tra chi tiet kenh va ngan hang
        kenh_list = rep.get("ChiTietTheoKenh", [])
        nh_list = rep.get("ChiTietTheoNganHang", [])
        self.assertGreater(len(kenh_list), 0, "Phai co chi tiet kenh thanh toan (VNPAY, OnePay, ...)")
        self.assertGreater(len(nh_list), 0, "Phai co chi tiet tai khoan ngan hang (TCB, VPB, ...)")
        
        for k in kenh_list:
            self.assertEqual(k["Gross"], k["Phi"] + k["Net"], f"Kenh {k.get('MaKenh')} khong can doi Gross=Phi+Net")
            
        for n in nh_list:
            self.assertEqual(n["Gross"], n["Phi"] + n["Net"], f"Ngan hang {n.get('MaTaiKhoan')} khong can doi Gross=Phi+Net")

    def test_04_canh_bao_cloud_usd(self):
        """Kiem tra Canh bao han muc & gia han Cloud USD: Quota & Contract Alerts"""
        rep = self.data["Report4_CanhBaoCloud"]
        self.assertIsNotNone(rep)
        
        usd = rep.get("TongChiPhiUSD", 0)
        vnd = rep.get("TongChiPhiVND", 0)
        fx = rep.get("TyGiaUSDHienHanh", 0)
        ncc_cnt = rep.get("TongNhaCungCapCloud", 0)
        
        self.assertGreater(usd, 0, "Tong chi phi USD phai lon hon 0")
        self.assertGreater(vnd, 0, "Tong chi phi VND phai lon hon 0")
        self.assertGreaterEqual(fx, 25000, f"Ty gia USD hach toan phai hop ly (>=25,000): {fx}")
        self.assertGreater(ncc_cnt, 0, "Tong so NCC cloud phai lon hon 0")
        
        # Kiem tra cac muc canh bao quota va thoi han
        quota_stat = rep.get("ThongKeCanhBaoQuota", {})
        exp_stat = rep.get("ThongKeCanhBaoThoiHan", {})
        
        self.assertIn("Do", quota_stat)
        self.assertIn("Cam", quota_stat)
        self.assertIn("Do", exp_stat)
        self.assertIn("Cam", exp_stat)
        
        # Kiem tra danh sach nha cung cap cong nghe toan cau
        ncc_list = rep.get("ChiTietNhaCungCap", [])
        ncc_codes = [n.get("MaDoiTac") for n in ncc_list]
        
        for key_vendor in ["TEST_NCC_AWS", "TEST_NCC_MICROSOFT", "TEST_NCC_QUALCOMM", "TEST_NCC_GOOGLE"]:
            self.assertIn(key_vendor, ncc_codes, f"Thieu key vendor {key_vendor} trong danh sach Cloud")
            
        # Kiem tra tinh dung dan cua de xuat hanh dong
        for ncc in ncc_list:
            if ncc.get("MucCanhBaoQuota") == "Do" or ncc.get("MucCanhBaoThoiHan") == "Do":
                self.assertIn("KHẨN CẤP", ncc.get("DeXuatHanhDong"))
            elif ncc.get("MucCanhBaoQuota") == "Cam" or ncc.get("MucCanhBaoThoiHan") == "Cam":
                self.assertIn("CẢNH BÁO", ncc.get("DeXuatHanhDong"))

if __name__ == "__main__":
    unittest.main(verbosity=2)
