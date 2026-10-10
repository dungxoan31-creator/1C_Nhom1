# HƯỚNG DẪN KHÔI PHỤC VÀ SỬ DỤNG FILE .DT
## HỆ THỐNG QUẢN LÝ CÔNG NỢ AR & AP — VINSMART FUTURE (VSF)

Tài liệu này hướng dẫn chi tiết cách nạp file sao lưu dữ liệu `.dt` vào nền tảng **1C:Enterprise 8.3** (tương thích cả phiên bản **Training** lẫn phiên bản **Thương mại**) và các bước đăng nhập sử dụng hệ thống.

---

### 1. THÔNG TIN GÓI DỮ LIỆU ĐÓNG GÓI (.DT)

- **File đóng gói chính:** `VinSmart_Future_AR_AP_Full.dt`
- **File sao lưu phụ:** `VinSmart_Future_AR_AP_Test.dt`
- **Dung lượng:** ~238 KB (đã nén toàn bộ metadata và dữ liệu khởi tạo theo chuẩn 1C)
- **Nền tảng mục tiêu:** 1C:Enterprise 8.3 (Platform 8.3.22 trở lên)
- **Giao diện:** Taxi (Managed Application)
- **Thành phần đóng gói:**
  1. **69 Đối tượng Metadata:** Catalogs, Documents, Accumulation Registers, Accounting Registers, Chart of Accounts, Reports, Data Processors, Scheduled Jobs, HTTP Services.
  2. **6 Phân hệ chức năng (Subsystems):** Hiển thị trực quan trên menu chính giao diện Taxi.
  3. **Bộ Danh mục Nền tảng sạch (Clean Master Data):**
     - **Pháp nhân:** VinSmart Future (VSF - MST: 0109988776), Tập đoàn Vingroup (VIC), VinFast (VFS).
     - **Đối tác:** Amazon Web Services Inc. (AWS), Qualcomm Technologies, Viettel Solutions, FPT Telecom, Vingroup, VinFast, Khách hàng cá nhân B2C.
     - **Tiền tệ & Tỷ giá:** Đồng Việt Nam (VND), US Dollar (USD - tỷ giá hạch toán 25.400 VND), Euro (EUR - tỷ giá 27.500 VND).
     - **Tài khoản tiền (Ngân hàng):** Techcombank VND VSF, Vietcombank USD VSF, VPBank VA VSF.
     - **Tài khoản ảo (Virtual Account):** VA Techcombank FPT, VA Techcombank Vingroup, VA VPBank Viettel (96248888001).
     - **Hợp đồng mẫu:** HĐ AWS Cloud Net 30, HĐ Qualcomm Net 45, HĐ Phần mềm VinFast Net 30, HĐ Vingroup Net 30, HĐ FPT Net 30.
     - **Cổng thanh toán & Dịch vụ CNTT:** VNPAY, OnePay, Máy chủ ảo EC2/RDS, S3 Cloud Storage, AI Inference Server.
     - **Khoản mục dòng tiền & Dự án:** Thu bán hàng, Chi dịch vụ Cloud, Chi thuế FCT, Chi phí ngân hàng, Dự án SmartLife, Dự án ADAS.
  4. **12 Hằng số hệ thống (Constants):** Thiết lập sẵn Pháp nhân mặc định, Ngưỡng duyệt chi CFO (50.000.000 VND), Ngưỡng không dùng tiền mặt (20.000.000 VND), Cảnh báo ngân sách Cloud (80%, 90%, 100%), Tự động đồng bộ SAP (`True`).
  5. **Tài khoản quản trị Admin:** Toàn quyền Quản trị hệ thống (`QuanTriHeThong`), không mật khẩu để đăng nhập trực tiếp.

---

### 2. CÁCH NẠP FILE .DT VÀO 1C:ENTERPRISE

#### Cách 1: Nạp qua giao diện đồ họa Designer (Khuyến nghị cho người dùng)

1. Khởi động ứng dụng **1C:Enterprise** từ màn hình Desktop hoặc Start Menu.
2. Tại cửa sổ danh sách cơ sở dữ liệu, bấm nút **Add...** (Thêm cơ sở dữ liệu mới).
3. Chọn tùy chọn: **"Create an infobase without configuration..."** (Tạo cơ sở dữ liệu trống chưa có cấu hình) -> Bấm **Next**.
4. Đặt tên cơ sở dữ liệu, ví dụ: `VinSmart Future - AR AP Management` -> Bấm **Next**.
5. Chọn thư mục lưu trữ trên máy tính của bạn -> Bấm **Next** -> Bấm **Finish**.
6. Chọn cơ sở dữ liệu vừa tạo trong danh sách, bấm nút **Designer** (Cấu hình) để mở chế độ quản trị.
7. Trên thanh menu trên cùng của Designer, chọn:
   ```text
   Administration -> Restore infobase...
   (hoặc tiếng Nga: Администрирование -> Загрузить информационную базу...)
   ```
8. Cửa sổ chọn file hiện ra: Trỏ đến vị trí file **`VinSmart_Future_AR_AP_Full.dt`** -> Bấm **Open**.
9. Phần mềm sẽ hiển thị cảnh báo ghi đè dữ liệu: Bấm **Yes** (Đồng ý).
10. Sau vài giây, hệ thống báo: **"Infobase successfully restored"** (Khôi phục thành công).
11. Bấm nút **Restart** hoặc đóng Designer, sau đó chọn cơ sở dữ liệu và bấm **1C:Enterprise** để bắt đầu sử dụng.

#### Cách 2: Nạp nhanh bằng Script PowerShell (Dành cho Developer)

Mở PowerShell tại thư mục dự án và chạy lệnh:
```powershell
.\scripts\import_dt.ps1 -InputPath ".\VinSmart_Future_AR_AP_Full.dt"
```

---

### 3. HƯỚNG DẪN ĐĂNG NHẬP & SỬ DỤNG HỆ THỐNG

1. Tại màn hình đăng nhập 1C:Enterprise:
   - **User name:** Chọn hoặc gõ **`Admin`**
   - **Password:** Để trống
   - Bấm **OK** (hoặc Enter).
2. Giao diện người dùng chuẩn **Taxi** sẽ hiển thị với thanh phân hệ (Sections panel) bên trái gồm 6 phân hệ nghiệp vụ:

| Menu Phân Hệ | Chức Năng Nổi Bật |
| :--- | :--- |
| **1. Phải thu (AR)** | • Lập **Biên bản nghiệm thu giai đoạn**<br>• Phát hành **Hóa đơn GTGT đầu ra**<br>• Lập **Phiếu thu tiền khách hàng**<br>• Xem **Báo cáo tuổi nợ phân tách nội bộ & ngoài** |
| **2. Phải trả (AP)** | • Tiếp nhận **Hóa đơn nhà cung cấp** (AWS USD, Qualcomm USD)<br>• **Nghiệm thu thầu phụ** & **Đề nghị thanh toán**<br>• Lập lệnh chi **Ủy nhiệm chi ngân hàng**<br>• **Báo cáo cảnh báo hạn mức Cloud** |
| **3. Ngân hàng & Quỹ** | • Ghi nhận **Báo có ngân hàng**<br>• Tiếp nhận **Bảng kê đối soát kênh thanh toán** (VNPAY, OnePay)<br>• Thực thi **Động cơ đối soát tự động**<br>• **Yêu cầu hoàn tiền chi hộ**<br>• **Báo cáo đối soát kênh thanh toán & VA** |
| **4. Bù trừ & Netting** | • Lập chứng từ **Cấn trừ công nợ nội bộ** (Bilateral & Multilateral)<br>• Công cụ **Lập ma trận cấn trừ Tập đoàn**<br>• **Báo cáo ma trận cấn trừ nội bộ Tập đoàn** |
| **5. Sổ cái & Đồng bộ SAP** | • Tra cứu **Hệ thống tài khoản kế toán** (TK 111, 112, 131, 331, 000)<br>• Xem **Sổ cái kế toán** (Đối ứng $\Delta = 0$)<br>• Công cụ **Nạp số dư đầu kỳ**<br>• Công cụ **Đồng bộ bút toán sang SAP S/4HANA** |
| **6. Danh mục nền tảng** | • Quản lý **Pháp nhân**, **Đối tác**, **Hợp đồng**<br>• Quản lý **Tài khoản ngân hàng** & **Tài khoản ảo (VA)**<br>• Bảng **Tỷ giá hối đoái** (USD = 25.400, EUR = 27.500)<br>• Danh mục **Dịch vụ CNTT**, **Dự án**, **Kênh thanh toán** |

---

### 4. THÔNG TIN LIÊN HỆ & BẢO TRÌ

- Dự án: Phân hệ Quản lý Công nợ Phải thu (AR) & Phải trả (AP) — VinSmart Future
- Đơn vị phát triển: Antigravity AI Engineering Team
- Phiên bản phát hành: v3.0 Production Ready (Đã vượt qua 100% UAT End-to-End Test Suite).
