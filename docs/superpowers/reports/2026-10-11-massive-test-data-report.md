# BÁO CÁO NGHIỆM THU & BÀN GIAO DỮ LIỆU TEST TOÀN DIỆN VSF (AR - AP - NETTING - SỔ CÁI)

> **Dự án**: Hệ Thống Quản Trị Tài Chính & Kế Toán VinSmart Future (VSF)  
> **Nền tảng**: 1C:Enterprise 8.3 (Việt hóa 100% - Chuẩn VAS)  
> **Giai đoạn phát sinh dữ liệu**: Từ ngày **01/01/2025** đến **30/09/2026** (21 tháng)  
> **Tệp CSDL bàn giao**: `VinSmart_Future_AR_AP_Test_FULLDATA.dt` (Dung lượng: **1.05 MB**, CSDL khôi phục: **22.09 MB**)  
> **Tệp gốc bảo lưu an toàn**: `VinSmart_Future_AR_AP_Test.ORIGINAL.dt`  

---

## 1. Bối Cảnh Doanh Nghiệp & Cơ Cấu Tổ Chức VSF (2026)

Hệ thống phản ánh chân thực mô hình hoạt động của **Công ty Cổ phần VinSmart Future (VSF)** – Đơn vị công nghệ thuộc Tập đoàn Vingroup phụ trách nghiên cứu, phát triển và vận hành các nền tảng số cốt lõi:

### 1.1. Cơ cấu 4 Khối Kinh Doanh & Khối Hỗ Trợ (32 Dự án / Trung tâm chi phí)
1. **Khối I – Nền tảng, Dữ liệu, AI**: Nền tảng số V-App Core; Hồ dữ liệu & Big Data; Bách khoa toàn thư & Báo điện tử; Nền tảng & Mô hình AI lớn (LLM); AI Thiết bị & IoT; AI Platform Mở (API Hub); Trung tâm NCSP & Thiết kế UIUX.
2. **Khối II – Hệ sinh thái số**: Cổng thanh toán & Ví điện tử Fintech; Sàn TMĐT & Mạng quảng cáo số; Ứng dụng Chat nội bộ & Khách hàng; Nền tảng Dịch vụ Xe (Connected Car); Chuyển đổi số Y tế (Vinmec); Giáo dục thông minh (VinUni & Vinschool).
3. **Khối III – Công nghiệp, Hạ tầng**: Hạ tầng Data Center & Cloud; Mạng Truyền dẫn & Kết nối Đối ngoại; Nền tảng Smart City & IoT Đô thị; Phần mềm Dùng chung & Công ty Mới; Vận hành Phần mềm Sản xuất (VinFast).
4. **Khối IV – Kinh doanh, Vận hành, Du lịch, BĐS, CSKH**: BĐS & Bán lẻ (Vinhomes); Du lịch - Khách sạn (Vinpearl & VinWonders); Kinh doanh Vận hành; Trung tâm CSKH Toàn cầu.
5. **Khối Hỗ Trợ (BO - Cost Center)**: Ban Tổng Giám đốc, Nhân sự & Đào tạo (HRS, HRBP), Tài chính - Kế toán, Pháp chế & Kiểm soát tuân thủ.

### 1.2. Danh mục Đối tác & Hợp đồng (249 Đối tác, 249 Hợp đồng)
- **Nhóm 1 – P&L lớn Vingroup (chiếm ~75% doanh thu Vingroup)**:
  - `TEST_VG_VINFAST_VN`: CTCP VinFast Việt Nam (Pháp nhân mới sau tái cấu trúc 2026).
  - `TEST_VG_VINFAST_PROD`: Công ty TNHH SX & KD VinFast (Pháp nhân cũ, còn công nợ tồn).
  - `TEST_VG_VINFAST_TRADING`: Công ty TNHH Kinh doanh & Phân phối VinFast Trading.
  - `TEST_VG_VINHOMES`: CTCP Vinhomes.
  - `TEST_VG_VINPEARL` & `TEST_VG_VINWONDERS`: Du lịch & Giải trí.
  - `TEST_VG_VINMEC`: Y tế.
  - `TEST_VG_GSM`: Di chuyển Xanh và Thông minh (Xanh SM).
  - `TEST_VG_VGREEN`: Phát triển Trạm sạc Toàn cầu V-Green.
  - `TEST_VG_VINCOM_RETAIL`, `TEST_VG_VINUNI`, `TEST_VG_VINSCHOOL`.
- **Nhóm 2 – P&L Công nghệ & Dịch vụ**: VinES, VinBigdata, VinAI, VinBrain, VinCSS, VinClub, VinRobotics, VinBus...
- **Nhóm 3 – Công ty mẹ & Quỹ**: Tập đoàn Vingroup (VIC), Quỹ VinFuture, Quỹ Thiện Tâm.
- **Khách hàng ngoài (~105 đối tác)**: Seller sàn TMĐT V-App Shop, Nhà quảng cáo Brand Agency, Doanh nghiệp công nghệ ngoài.
- **Nhà cung cấp Quốc tế (20 NCC USD)**: AWS, Microsoft, Qualcomm, Google Cloud, Oracle, SAP, IBM, Cisco, Dell, NVIDIA, Intel, Atlassian, Zoom, Salesforce...
- **Nhà cung cấp Trong nước (100 NCC VND)**: Hạ tầng viễn thông, bảo trì, dịch vụ số.
- **Tỷ giá hối đoái**: 639 bản ghi tỷ giá USD/VND hằng ngày từ 01/01/2025 đến 30/09/2026 (24.850 - 25.650 VND/USD).

---

## 2. Thống Kê Chi Tiết Chứng Từ Nghiệp Vụ Đã Ghi Sổ (6,061 Chứng Từ)

| STT | Loại chứng từ 1C | Tên tiếng Việt | Số lượng Đã Ghi Sổ (Posted) |
| :---: | :--- | :--- | :---: |
| 1 | `Document.BienBanNghiemThuGiaiDoan` | Biên bản nghiệm thu dịch vụ CNTT (AR) | **1,260** |
| 2 | `Document.HoaDonGTGTDauRa` | Hóa đơn GTGT điện tử đầu ra (AR) | **1,260** |
| 3 | `Document.PhieuThuTienKhachHang` | Phiếu thu tiền khách hàng ngoài (AR) | **546** |
| 4 | `Document.BaoCoNganHang` | Báo có ngân hàng Techcombank (AR) | **308** |
| 5 | `Document.HoaDonNhaCungCap` | Hóa đơn nhà cung cấp trong/ngoài nước (AP) | **1,268** |
| 6 | `Document.UyNhiemChi` | Ủy nhiệm chi thanh toán ngân hàng (AP) | **1,055** |
| 7 | `Document.CanTruCongNoNoiBo` | Cấn trừ công nợ nội bộ song/đa phương (Netting) | **182** |
| 8 | `Document.BangKeDoiSoatKenhThanhToan` | Bảng kê đối soát cổng TT / Virtual Account | **182** |
| **TỔNG** | **Tất cả chứng từ kế toán** | **Toàn bộ hệ thống** | **6,061** |

---

## 3. Kiểm Toán Số Sách & Tính Toàn Vẹn Sổ Cái (GL Integrity)

### 3.1. Cân đối kép Sổ Cái Kế Toán (`AccountingRegister.SoCaiKeToan`)
- **Tổng phát sinh kép**: **2,789,169,024,070 VND** (~2.79 nghìn tỷ VND).
- **Chênh lệch Nợ - Có**: **DELTA = 0.00 VND** (Cân đối kép tuyệt đối 100%).

### 3.2. Số dư các sổ phụ kế toán (Subledgers)
- **Công nợ Phải thu (`AccumulationRegister.CongNoPhaiThu`)**: Dư Nợ **134,081,200,000 VND** (Phân bổ đủ 5 nhóm tuổi nợ: đúng hạn, trễ 1-30d, 31-60d, 61-90d, và quá hạn >90d).
- **Công nợ Phải trả (`AccumulationRegister.CongNoPhaiTra`)**: Dư Có ròng **-20,881,120,000 VND**.
- **Dòng tiền (`AccumulationRegister.DongTien`)**: Dư tiền tại các tài khoản Techcombank VND, Vietcombank USD, VPBank VA đạt **556,222,849,465 VND**.

### 3.3. Tuân thủ Invariant P0.1 & Kiểm soát Nội bộ Maker-Checker
- **Invariant P0.1**: Biên bản nghiệm thu chỉ hạch toán doanh thu chưa thuế (Nợ 131 / Có 5113); Hóa đơn GTGT đầu ra chỉ hạch toán nghĩa vụ thuế VAT (Nợ 131 / Có 33311). Khớp đúng 100% giữa Subledger và GL.
- **Maker-Checker**: 100% chứng từ áp dụng nghiêm ngặt nguyên tắc người lập (`NguoiLap`/`NguoiTao`) khác người duyệt (`NguoiDuyet`/`CFO`), không có bất kỳ chứng từ nào vi phạm tự duyệt.
- **Edge cases**: Đã đưa vào 4% chứng từ mang nhãn `TEST_EDGE_CASE:` mô phỏng tranh chấp công nợ, cấn trừ bắc cầu 3 bên qua TK 1388, và giữ lại bảo hành phục vụ kiểm thử báo cáo quản trị rủi ro.

---

## 4. Hướng Dẫn Khôi Phục & Sử Dụng

### Khôi phục CSDL từ file `.dt`:
1. Mở **1C:Enterprise Starter** -> Bấm **Add...** -> Chọn **Create a new infobase** -> Nhập tên (ví dụ: `VSF_FullData_2026`).
2. Chọn thư mục lưu CSDL -> Bấm **Finish**.
3. Chọn dòng CSDL vừa tạo -> Bấm **Designer**.
4. Trên thanh menu Designer: Chọn **Administration** -> **Restore infobase...**.
5. Trỏ tới file: `C:\Users\Dung\Documents\1C_Enterprise\VinSmart_Future_AR_AP_Test_FULLDATA.dt`.
6. Nhấn **Open**, chờ hoàn tất thông báo **"Infobase successfully restored"**.
7. Khởi động ở chế độ **1C:Enterprise (Thin Client / Thick Client)** với tài khoản:
   - **Tên đăng nhập**: `Admin` (hoặc các user chuyên viên kế toán).
   - **Mật khẩu**: *(để trống)*.
