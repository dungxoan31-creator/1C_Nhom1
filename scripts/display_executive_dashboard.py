import json
import os
import sys

def main():
    json_path = os.path.join(os.path.dirname(__file__), "..", "docs", "superpowers", "reports", "executive_reports_data.json")
    if not os.path.exists(json_path):
        print(f"[!] Khong tim thay file JSON: {json_path}")
        sys.exit(1)

    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    r1 = data.get("Report1_TuoiNo", {})
    r2 = data.get("Report2_MaTranNetting", {})
    r3 = data.get("Report3_DoiSoatKenh", {})
    r4 = data.get("Report4_CanhBaoCloud", {})

    print(f"""
================================================================================
           DASHBOARD 4 BAO CAO QUAN TRI CHUYEN SAU (EXECUTIVE SUMMARY)
================================================================================
1. BAO CAO TUOI NO PHAN TACH NOI BO & SAFETY GATE
   - Tong Cong no Phai thu (AR): {r1.get("AR_Buckets", {}).get("TongCong", 0):>18,d} VND
     * Trong han               : {r1.get("AR_Buckets", {}).get("TrongHan", 0):>18,d} VND
     * Qua han 1 - 30 ngay     : {r1.get("AR_Buckets", {}).get("QuaHan1_30", 0):>18,d} VND
     * Qua han 31 - 60 ngay    : {r1.get("AR_Buckets", {}).get("QuaHan31_60", 0):>18,d} VND
     * Qua han 61 - 90 ngay    : {r1.get("AR_Buckets", {}).get("QuaHan61_90", 0):>18,d} VND
     * Qua han tren 90 ngay    : {r1.get("AR_Buckets", {}).get("QuaHanTren90", 0):>18,d} VND
   - Tong Cong no Phai tra (AP): {r1.get("AP_Buckets", {}).get("TongCong", 0):>18,d} VND
     * Trong han               : {r1.get("AP_Buckets", {}).get("TrongHan", 0):>18,d} VND
     * Qua han 1 - 30 ngay     : {r1.get("AP_Buckets", {}).get("QuaHan1_30", 0):>18,d} VND
     * Qua han 31 - 60 ngay    : {r1.get("AP_Buckets", {}).get("QuaHan31_60", 0):>18,d} VND
     * Qua han 61 - 90 ngay    : {r1.get("AP_Buckets", {}).get("QuaHan61_90", 0):>18,d} VND
     * Qua han tren 90 ngay    : {r1.get("AP_Buckets", {}).get("QuaHanTren90", 0):>18,d} VND
   - Safety Gate Chuyen sau    :
     * Doi tac Vingroup noi bo : {r1.get("SafetyGateSummary", {}).get("SoNoiBoCamKhoa", 0)} / {r1.get("SafetyGateSummary", {}).get("TongSoDoiTacNoiBo", 0)} (100% TUYET DOI CAM KHOA DICH VU)
     * Canh bao CFO & Netting  : {r1.get("SafetyGateSummary", {}).get("SoNoiBoCanhBaoCFO", 0)} doi tac noi bo qua han
     * Khach ngoai de xuat khoa: {r1.get("SafetyGateSummary", {}).get("SoDeXuatKhoaAPI", 0)} / {r1.get("SafetyGateSummary", {}).get("TongSoKhachNgoai", 0)} (>60 ngay qua han)

2. MA TRAN CAN TRU CONG NO NOI BO TAP DOAN (NETTING MATRIX)
   - Tong gia tri can tru      : {r2.get("TongGiaTriCanTru", 0):>18,d} VND
   - Can tru song phuong       : {r2.get("TongCanTruSongPhuong", 0):>18,d} VND
   - Can tru bac cau (Bridge)  : {r2.get("TongCanTruBacCau", 0):>18,d} VND
   - Tong so chung tu can tru  : {r2.get("TongSoChungTu", 0):>18,d} chung tu
   - Delta can doi (AR - AP)   : {r2.get("DeltaCanDoi", 0):>18,d} VND (CAN DOI TUYET DOI: DELTA = 0)

3. DOI SOAT KENH THANH TOAN & TAI KHOAN AO (GATEWAY RECONCILIATION)
   - Tong doanh so Gross       : {r3.get("TongGross", 0):>18,d} VND
   - Tong phi kenh thanh toan  : {r3.get("TongPhiKenh", 0):>18,d} VND
   - Tong thuc nhan (Net)      : {r3.get("TongNetThucNhan", 0):>18,d} VND
   - Ty le phi trung binh      : {r3.get("TyLePhiTrungBinh", 0):>17.2f}%
   - Delta can doi (Gross-(Phi+Net)): {r3.get("DeltaCanDoi", 0):>12,d} VND (CAN DOI TUYET DOI: DELTA = 0)

4. CANH BAO HAN MUC VA GIA HAN CLOUD USD (CLOUD SPENDING & QUOTA)
   - Tong chi phi Cloud USD    : ${r4.get("TongChiPhiUSD", 0):>17,d} USD
   - Tong chi phi quy doi VND  : {r4.get("TongChiPhiVND", 0):>18,d} VND
   - Ty gia USD hach toan      : {r4.get("TyGiaUSDHienHanh", 0):>18,d} VND/USD
   - Tong nha cung cap Cloud   : {r4.get("TongNhaCungCapCloud", 0):>18,d} NCC
   - Canh bao Quota            : Do={r4.get("ThongKeCanhBaoQuota", {}).get("Do", 0)}, Cam={r4.get("ThongKeCanhBaoQuota", {}).get("Cam", 0)}, Vang={r4.get("ThongKeCanhBaoQuota", {}).get("Vang", 0)}, BinhThuong={r4.get("ThongKeCanhBaoQuota", {}).get("BinhThuong", 0)}
   - Canh bao Thoi han hop dong: Do={r4.get("ThongKeCanhBaoThoiHan", {}).get("Do", 0)}, Cam={r4.get("ThongKeCanhBaoThoiHan", {}).get("Cam", 0)}, Vang={r4.get("ThongKeCanhBaoThoiHan", {}).get("Vang", 0)}, BinhThuong={r4.get("ThongKeCanhBaoThoiHan", {}).get("BinhThuong", 0)}
================================================================================
""")

if __name__ == "__main__":
    main()
