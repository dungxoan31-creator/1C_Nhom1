# HƯỚNG DẪN KHÔI PHỤC VÀ SỬ DỤNG FILE .DT
## HỆ THỐNG QUẢN LÝ CÔNG NỢ AR & AP — VINSMART FUTURE (VSF)

Tài liệu này hướng dẫn chi tiết cách nạp file sao lưu dữ liệu `.dt` vào nền tảng **1C:Enterprise 8.3** (tương thích cả phiên bản **Training** lẫn phiên bản **Thương mại**), cơ cấu dữ liệu test phong phú đã được sinh sẵn và các bước kiểm tra, vận hành hệ thống.

> **Bản Việt hóa (16/10/2026):** giao diện cấu hình đã chuyển tiếng Việt (ngôn ngữ mặc định `vi`). Muốn cả chữ của nền tảng 1C (Tìm kiếm, Tạo, Ghi sổ...) cũng tiếng Việt: trong danh sách infobase → Sửa → trang cuối → *Tham số khởi động bổ sung* = `/L vi /VL vi`. Bản **1C Training**: đăng nhập để **trống mật khẩu**, mỗi infobase chỉ 1 kết nối cùng lúc. Chi tiết + kết quả test: `docs/07_LOG_VIET_HOA_VA_TEST.md`; bộ test: `docs/08_KICH_BAN_TEST_CHI_TIET.xlsx`.

> **Bản sửa lỗi Đợt 1–2 (15/10/2026):** file `.dt` này đã được dựng lại với cấu hình đã sửa (`src/`), dữ liệu giữ nguyên bản trước. Chi tiết, kết quả kiểm tra trên 1C và cách tự dựng lại: `docs/06_LOG_SUA_LOI.md`. Dựng lại trên Windows: `powershell -ExecutionPolicy Bypass -File .\scripts\rebuild_dt_from_src.ps1 -SourceDt "<file .dt gốc>"`.

---

### 1. THÔNG TIN GÓI DỮ LIỆU ĐÓNG GÓI (.DT)

- **File dữ liệu lớn phát hành đầy đủ:** [VinSmart_Future_AR_AP_Full.dt](file:///C:/Users/Dung/Documents/1C_Enterprise/VinSmart_Future_AR_AP_Full.dt)
- **Dung lượng:** ~1.18 MB (đã đóng gói từ Infobase_FullData, chứa đầy đủ 6.473 chứng từ đã ghi sổ của 21 tháng nghiệp vụ từ 01/01/2025 đến 30/09/2026)
- **Nền tảng mục tiêu:** 1C:Enterprise 8.3 (Platform 8.3.22 trở lên)
- **Giao diện người dùng:** Taxi (Managed Application)
- **Tài khoản đăng nhập quản trị:**
  - **Tên đăng nhập (User):** `Admin`
  - **Mật khẩu (Password):** *(để trống)*
  - **Vai trò:** Toàn quyền Quản trị hệ thống (`QuanTriHeThong`)
- **Tài khoản người dùng nghiệp vụ mẫu (Mật khẩu: `123`):**
  - `ketoan_ar` (Role: `KeToanPhaiThu`), `ketoan_ap` (Role: `KeToanPhaiTra`), `chuyenvien_doisoat` (Role: `ChuyenVienDoiSoatTapDoan`), `cfo_giamdoc` (Role: `GiamDocTaiChinh_CFO`), `ketoan_truong` (Role: `KeToanTruong`), `pm_duan` (Role: `ProjectManager_QuanLyDuAn`), `techlead_kythuat` (Role: `TechLead_KiemTraKyThuat`), `it_director` (Role: `ITDirector_GiamDocHaTang`).
- **Kiến trúc tập trung duy nhất (Standalone 1C):**
  - Hệ thống 1C độc lập, hoàn toàn không còn bất kỳ đầu nối tích hợp SAP hay webhook bên ngoài nào.
  - Sổ Cái kép đối ứng đạt cân đối tuyệt đối 100%: $\Delta = 0$, $\Delta_{AR} = 0$, $\Delta_{AP} = 0$.
  - Danh mục tài khoản kế toán mở rộng đầy đủ theo chuẩn VAS: 1311, 1312, 3311, 3312, 3313, 3318, 3388, 641, 1121, 1122, 627, 5113, 515, 635, 4131.

---

### 2. DỮ LIỆU NGHIỆP VỤ MẪU ĐÃ ĐƯỢC NẠP SẴN (FULL TEST DATA)

Gói `.dt` đã được nạp sẵn **43 chứng từ nghiệp vụ thực tế**, tất cả đều ở trạng thái **ĐÃ GHI SỔ (POSTED)** và phản ánh đầy đủ vào Sổ cái GL và các Sổ tích lũy công nợ, dòng tiền:

#### A. Phân hệ Phải thu (AR) — 16 Chứng từ
1. **10 Biên bản nghiệm thu giai đoạn (`BienBanNghiemThuGiaiDoan`) & 10 Hóa đơn GTGT đầu ra (`HoaDonGTGTDauRa`):**
   - Mã số: `BB0001` đến `BB0010` và `HD26E0000001` đến `HD26E0000010`.
   - Đối tác: Vingroup (VIC), VinFast (VFS), FPT Telecom, Viettel Solutions.
   - Tổng giá trị dịch vụ: **2.450.000.000 VND**; Thuế VAT 10%: **245.000.000 VND**; Tổng AR phát sinh: **2.695.000.000 VND**.
   - Phân bố tuổi nợ đa dạng để kiểm thử báo cáo Aging:
     - *Quá hạn > 90 ngày:* BB-VIC-01 (330 tr VND).
     - *Quá hạn 61-90 ngày:* BB-VIC-02 (275 tr), BB-VFS-01 (440 tr), BB-FPT-01 (198 tr).
     - *Quá hạn 31-60 ngày:* BB-VFS-02 (385 tr), BB-FPT-02 (242 tr), BB-VTS-01 (231 tr).
     - *Trong hạn (Dưới 30 ngày):* BB-VIC-03 (220 tr), BB-VFS-03 (330 tr), BB-VTS-02 (209 tr).
2. **6 Phiếu thu tiền khách hàng (`PhieuThuTienKhachHang`):**
   - Mã số: `PT0001` đến `PT0006`.
   - Thu tiền thanh toán nợ từ Vingroup, FPT, VinFast, Viettel qua tài khoản ngân hàng Techcombank VND.
   - Tổng số tiền thực thu: **1.248.000.000 VND**.

#### B. Phân hệ Phải trả (AP) — 13 Chứng từ
1. **8 Hóa đơn nhà cung cấp (`HoaDonNhaCungCap`):**
   - Mã số: `AP0001` đến `AP0008`.
   - Nhà cung cấp ngoại quốc (FCT Withholding):
     - Amazon Web Services (AWS) 3 kỳ: 12.000 USD (304,8 tr), 15.000 USD (381 tr), 18.000 USD (457,2 tr) - Tự động khấu trừ 5% VAT nhà thầu & 5% CIT nhà thầu.
     - Qualcomm Technologies: 10.000 USD (254 tr) và 8.000 USD (203,2 tr).
   - Nhà cung cấp trong nước: VinFast (thuê mặt bằng lab 80 tr), FPT Telecom (đường truyền 45 tr & 55 tr).
   - Tổng công nợ dịch vụ phát sinh: **1.775.200.000 VND**; Nợ thực trả NCC sau FCT: **1.661.120.000 VND**.
2. **5 Lệnh chi Ủy nhiệm chi ngân hàng (`UyNhiemChi`):**
   - Mã số: `UNC0001` đến `UNC0005`.
   - Thanh toán nợ cho AWS (USD qua VCB), Qualcomm (USD qua VCB), FPT Telecom (TCB VND), VinFast (TCB VND).
   - Tổng số tiền thực thanh toán: **816.520.000 VND** (Kèm phí chuyển tiền ngân hàng tự động hạch toán TK 6427).

#### C. Phân hệ Ngân hàng & Đối soát Kênh thanh toán — 2 Chứng từ
- **BK-VNPAY-01:** Bảng kê đối soát cổng VNPAY (Tổng GD: 75.000.000 VND, Phí kênh: 1.125.000 VND, Thực nhận về TK Techcombank: 73.875.000 VND).
- **BK-ONEPAY-01:** Bảng kê đối soát cổng OnePay Thẻ quốc tế (Tổng GD: 40.000.000 VND, Phí kênh: 880.000 VND, Thực nhận về TK Techcombank: 39.120.000 VND).

#### D. Phân hệ Bù trừ & Netting Nội bộ Tập đoàn — 2 Chứng từ
- **CT-BILATERAL-01:** Cấn trừ song phương 2 bên trực tiếp giữa VSF và VinFast: **40.000.000 VND** (Bù trừ giữa nợ AR bán phần mềm xe thông minh và nợ AP thuê mặt bằng lab R&D).
- **CT-MULTILATERAL-01:** Cấn trừ đa biên 3 bên giữa VSF - Vingroup - VinFast qua tài khoản trung gian TK 1388: **100.000.000 VND**.

---

### 3. THỐNG KÊ CÂN ĐỐI SỔ SÁCH KẾ TOÁN (VERIFIED)

Hệ thống đã được kiểm toán tự động qua truy vấn cơ sở dữ liệu (`verify_full_test_data.log`):

| Chỉ tiêu kế toán | Giá trị ghi nhận | Trạng thái kỹ thuật |
| :--- | :--- | :--- |
| **Tổng số chứng từ đã ghi sổ (Posted)** | **43 chứng từ** | Hợp lệ 100% |
| **Tổng phát sinh kép Sổ cái (`SoCaiKeToan`)** | **7.060.242.000 VND** | Đối ứng Nợ - Có hoàn hảo |
| **Độ lệch Nợ - Có Sổ cái ($\Delta GL$)** | **0 VND ($\Delta = 0$)** | Cân đối tuyệt đối |
| **Dư nợ Sổ tích lũy Phải thu (`CongNoPhaiThu`)** | **1.472.000.000 VND** | Khớp từng khoản nợ theo hợp đồng |
| **Dư nợ Sổ tích lũy Phải trả (`CongNoPhaiTra`)** | **709.380.000 VND** | Khớp công nợ thực tế sau FCT |
| **Số dư Tiền gửi & Quỹ (`DongTien`)** | **543.953.000 VND** | Khớp sổ phụ ngân hàng TCB & VCB |

---

### 4. CÁCH NẠP FILE .DT VÀO 1C:ENTERPRISE

#### Cách 1: Nạp qua giao diện đồ họa Designer (Khuyến nghị)

1. Khởi động ứng dụng **1C:Enterprise** từ màn hình Desktop hoặc Start Menu.
2. Tại cửa sổ danh sách cơ sở dữ liệu, bấm nút **Add...** (Thêm cơ sở dữ liệu mới).
3. Chọn tùy chọn: **"Create an infobase without configuration..."** (Tạo cơ sở dữ liệu trống) -> Bấm **Next**.
4. Đặt tên cơ sở dữ liệu, ví dụ: `VinSmart Future - AR AP Management` -> Bấm **Next**.
5. Chọn thư mục lưu trữ trên máy tính của bạn -> Bấm **Next** -> Bấm **Finish**.
6. Chọn cơ sở dữ liệu vừa tạo trong danh sách, bấm nút **Designer** (Cấu hình) để mở chế độ quản trị.
7. Trên thanh menu trên cùng của Designer, chọn:
   ```text
   Administration -> Restore infobase...
   (hoặc tiếng Nga: Администрирование -> Загрузить информационную базу...)
   ```
8. Cửa sổ chọn file hiện ra: Trỏ đến vị trí file **[VinSmart_Future_AR_AP_Full.dt](file:///C:/Users/Dung/Documents/1C_Enterprise/VinSmart_Future_AR_AP_Full.dt)** -> Bấm **Open**.
9. Phần mềm sẽ hiển thị thông báo ghi đè: Bấm **Yes** (Đồng ý).
10. Hệ thống báo: **"Infobase successfully restored"** (Khôi phục thành công).
11. Đóng Designer, chọn cơ sở dữ liệu và bấm **1C:Enterprise** để bắt đầu sử dụng.

#### Cách 2: Nạp nhanh bằng Script PowerShell (Dành cho Developer)

Mở PowerShell tại thư mục dự án và chạy lệnh:
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\import_dt.ps1 -InputPath ".\VinSmart_Future_AR_AP_Full.dt" -IBPath "D:\1C\VSF_Demo"
# (Bắt buộc -IBPath trỏ tới thư mục infobase RIÊNG; script từ chối thư mục tên Infobase / Infobase_FullData và hỏi xác nhận YES trước khi ghi đè)
```

---

### 5. GỢI Ý TEST CÁC TÍNH NĂNG & BÁO CÁO SAU KHI NẠP

Sau khi mở giao diện Taxi, người dùng có thể kiểm thử ngay lập tức các tính năng cốt lõi:

1. **Kiểm tra Menu Phân hệ:** Quan sát thanh menu dọc bên trái gồm đủ 6 phân hệ (Phải thu AR, Phải trả AP, Ngân hàng & Quỹ, Bù trừ Netting, Sổ cái & Bàn làm việc CFO, Danh mục nền tảng).
2. **Xem Sổ cái GL:** Vào phân hệ **Sổ cái & Bàn làm việc CFO** -> mở **Sổ cái kế toán**, kiểm tra các dòng định khoản đối ứng (Nợ 131 / Có 511, Nợ 627 / Có 331, Nợ 112 / Có 131, v.v.).
3. **Mở Báo cáo tuổi nợ AR:** Vào phân hệ **Phải thu** -> mở **Báo cáo tuổi nợ AR phân tách nội bộ & ngoài**, bấm **Tạo báo cáo (Generate)** để thấy 4 cột phân tầng tuổi nợ (>90 ngày, 61-90 ngày, 31-60 ngày, trong hạn) phân nhóm chi tiết theo từng đối tác Vingroup, VinFast, FPT, Viettel.
4. **Mở Báo cáo đối soát kênh thanh toán:** Vào phân hệ **Ngân hàng & Quỹ** -> mở **Báo cáo đối soát kênh thanh toán & VA** để xem bảng kê đối soát VNPAY và OnePay với phí cổng tự động trích lọc.
5. **Mở Báo cáo ma trận cấn trừ nội bộ:** Vào phân hệ **Bù trừ & Netting** -> mở **Báo cáo ma trận cấn trừ nội bộ Tập đoàn** để theo dõi số tiền 40 triệu và 100 triệu đã được cấn trừ giữa VSF, Vingroup và VinFast.
6. **Mở Báo cáo cảnh báo hạn mức Cloud:** Vào phân hệ **Phải trả** -> mở **Báo cáo cảnh báo hạn mức Cloud** để theo dõi chi phí chi tiêu AWS so với ngân sách được duyệt.

---

### 6. LIÊN HỆ & BẢO TRÌ

- **Dự án:** Phân hệ Quản lý Công nợ Phải thu (AR) & Phải trả (AP) — VinSmart Future (VSF)
- **Đơn vị phát triển:** Antigravity AI Engineering Team
- **Trạng thái:** Hoàn tất bàn giao, dữ liệu test toàn diện 100%, sẵn sàng triển khai UAT.
