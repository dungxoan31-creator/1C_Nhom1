# Kế Hoạch Triển Khai: Bàn Làm Việc Tổng Quan Điều Hành (Executive Overview Dashboard)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Hoàn thiện và tích hợp Bàn làm việc Tổng quan Điều hành (`DataProcessor.DashboardTongQuan` kết hợp `CommonForm.TrangChuTongQuan`, `CommonModule.BangDieuKhienServer`, `CommonTemplate.MauHTMLTrangChu`), hiển thị tức thời 4 thẻ KPI tài chính chuẩn TT200 (AR, AP, Tiền gửi, FCT tạm giữ), hàng đợi phê duyệt Hóa đơn NCC phân cấp KTT/CFO > 500tr, các phím tắt theo đúng chu trình 2 luồng cốt lõi và xuất hiện trực quan trên thanh Menu điều hướng chính.

**Architecture:** Sử dụng kiến trúc Form lai (Hybrid Taxi Form): `DataProcessor.DashboardTongQuan` gắn lệnh chuẩn trên thanh Menu chính (`MainSectionCommandInterface.xml`), nạp giao diện HTML5/CSS hiện đại theo nhận diện thương hiệu VinSmart Future từ `CommonTemplate.MauHTMLTrangChu`. Logic nghiệp vụ tại `BangDieuKhienServer` thực thi truy vấn trực tiếp từ Sổ cái kế toán `AccountingRegister.SoCaiKeToan` và chứng từ `Document.HoaDonNhaCungCap`, truyền dữ liệu qua JSON. Sự kiện click trên HTML được cầu nối qua giao thức `vsmart://` về Form BSL để mở trực tiếp chứng từ hoặc làm mới dữ liệu.

**Tech Stack:** 1C:Enterprise 8.3 (Managed Application / Taxi, BSL, XML Metadata Version 2.15), HTML5/CSS3/JavaScript, Python (`verify_bsl_syntax.py`).

**Spec:** [docs/superpowers/specs/2026-10-17-dashboard-tong-quan-design.md](docs/superpowers/specs/2026-10-17-dashboard-tong-quan-design.md)

## Global Constraints

- Tuân thủ Metadata XML version 2.15 và cấu trúc danh mục đối tượng trong `Configuration.xml` và `ConfigDumpInfo.xml`.
- Mọi logic tính toán số dư phải lấy từ Sổ cái kế toán `SoCaiKeToan` (TK 1311, TK 3311, TK 1121, TK 33318, TK 3338) và sổ tích lũy, không dùng số liệu giả định hay phỏng đoán.
- Phân cấp phê duyệt AP phải đọc ngưỡng động từ `Constants.NguongPheDuyetChiTienCFO` (mặc định 500.000.000 VND).
- Toàn bộ mã BSL phải vượt qua kiểm tra cân bằng cú pháp của `scripts/verify_bsl_syntax.py`.
- Tương thích đầy đủ với các vai trò hiện hữu (`QuanTriHeThong`, `KeToanTruong`, `GiamDocTaiChinh_CFO`, `KeToanPhaiThu`, `KeToanPhaiTra`).

## Review Focus

1. Truy vấn số dư GL TK 1311, 3311, 1121, 33318, 3338 xử lý đúng giá trị rỗng/NULL (trả về 0 VND thay vì lỗi).
2. Hàng đợi phê duyệt Hóa đơn NCC lọc chính xác các hóa đơn chưa ghi sổ (`Posted = False`) có trạng thái `ChoDuyetKTT` hoặc `ChoDuyetCFO`.
3. Cảnh báo cấp duyệt CFO hiển thị chuẩn xác cho các hóa đơn có `TongTien > 500.000.000` VND hoặc trạng thái `ChoDuyetCFO`.
4. Cầu nối sự kiện `TruongHTMLDashboardOnClick` xử lý mượt mà cả làm mới số liệu (`action=refresh`), tạo mới chứng từ (`create?type=...`) và mở xem chi tiết chứng từ (`open?type=...&ref=...`).
5. Menu chính `MainSectionCommandInterface.xml` hiển thị nút bấm Dashboard ở vị trí đầu tiên của thanh điều hướng.

---

### Task 1: Chuẩn hóa Logic Truy Vấn Số Liệu Kế Toán & Phê Duyệt AP (`BangDieuKhienServer`)

**Files:**
- Modify: `src/CommonModules/BangDieuKhienServer/Ext/Module.bsl`

**Interfaces:**
- Consumes: `AccountingRegister.SoCaiKeToan.Balance`, `Document.HoaDonNhaCungCap`, `Constants.NguongPheDuyetChiTienCFO`
- Produces: `BangDieuKhienServer.LayDuLieuTongQuan(Val KyBaoCao = "ThangNay") -> String (JSON)`

- [ ] **Step 1: Viết hàm truy vấn Sổ cái và Hàng đợi phê duyệt chuẩn mực kế toán**
  Cập nhật `src/CommonModules/BangDieuKhienServer/Ext/Module.bsl`:
  - Đọc ngưỡng CFO từ `Constants.NguongPheDuyetChiTienCFO.Get()` (nếu rỗng lấy 500tr).
  - Truy vấn số dư Sổ cái kế toán:
    - `NoPhaiThu`: Dư Nợ TK 1311.
    - `NoPhaiTra`: Dư Có TK 3311.
    - `TienKhaDung`: Dư Nợ TK 1121.
    - `ThueFCTTamGiu`: Dư Có TK 33318 + Dư Có TK 3338.
  - Truy vấn `Document.HoaDonNhaCungCap`:
    - Lấy các hóa đơn `Posted = False` và `TrangThaiHoaDon IN (ChoDuyetKTT, ChoDuyetCFO)`.
    - Phân cấp `CapDuyet` = "GIÁM ĐỐC TÀI CHÍNH (CFO)" nếu `TrangThaiHoaDon = ChoDuyetCFO` hoặc `TongTien > NguongCFO`, ngược lại là "KẾ TOÁN TRƯỞNG".
    - Tạo chuỗi tham chiếu để nhấp chuột mở form chứng từ.
  - Đảm bảo bọc khối `Try...Except` an toàn.

- [ ] **Step 2: Kiểm tra cú pháp BSL**
  Run: `python -B scripts/verify_bsl_syntax.py`
  Expected: `Checked 18 BSL files. Total syntax balance issues: 0`

- [ ] **Step 3: Đối chiếu tính nhất quán của cấu trúc JSON trả về**
  Đảm bảo các key JSON (`NoPhaiThu`, `NoPhaiTra`, `TienKhaDung`, `ThueFCTTamGiu`, `TopChungTuChoDuyet`, `TopNoQuaHan`) khớp 100% với giao diện HTML.

---

### Task 2: Nâng cấp Giao Diện & Thao Tác Phím Tắt Nhanh (`MauHTMLTrangChu`)

**Files:**
- Modify: `src/CommonTemplates/MauHTMLTrangChu/Ext/Template.txt`

**Interfaces:**
- Consumes: JSON từ `BangDieuKhienServer.LayDuLieuTongQuan`
- Produces: Giao diện HTML hiển thị 4 KPI Cards, thanh Quick Actions 2 luồng AR/AP, bảng hàng đợi phê duyệt Hóa đơn NCC.

- [ ] **Step 1: Cập nhật 4 thẻ KPI Cards**
  Trong `src/CommonTemplates/MauHTMLTrangChu/Ext/Template.txt`:
  - Thẻ 1: Tổng nợ phải thu (TK 1311 / AR) - id `valPhaiThu`.
  - Thẻ 2: Tổng nợ phải trả (TK 3311 / AP) - id `valPhaiTra`.
  - Thẻ 3: Số dư dòng tiền thực tế (TK 1121) - id `valTienKhaDung`.
  - Thẻ 4: Thuế nhà thầu FCT tạm giữ (TK 33318 + 3338) - id `valThueFCT` (thay cho số liệu phỏng đoán trước đây).

- [ ] **Step 2: Cập nhật Thanh Phím Tắt Thao Tác Nhanh (Quick Actions Bar)**
  Cung cấp 5 nút bấm tạo nhanh theo đúng kịch bản 2 luồng cốt lõi:
  - `[+ Nghiệm thu AR]`: href `vsmart://create?type=BienBanNghiemThuGiaiDoan`
  - `[+ Hóa đơn GTGT AR]`: href `vsmart://create?type=HoaDonGTGTDauRa`
  - `[+ Thu tiền KH]`: href `vsmart://create?type=PhieuThuTienKhachHang`
  - `[+ Hóa đơn NCC]`: href `vsmart://create?type=HoaDonNhaCungCap`
  - `[+ Lập UNC AP]`: href `vsmart://create?type=UyNhiemChi`

- [ ] **Step 3: Cập nhật Bảng Hàng Đợi Phê Duyệt Hóa Đơn NCC (Action Center)**
  - Hiển thị các cột: Mã chứng từ, Ngày, Nhà cung cấp, Tổng tiền, Trạng thái, Cấp duyệt.
  - Đối với cấp duyệt CFO: gắn nhãn màu đỏ cảnh báo (`pill-danger`).
  - Mỗi dòng có link `vsmart://open?type=HoaDonNhaCungCap&id=...` để click mở trực tiếp chứng từ.

- [ ] **Step 4: Cập nhật hàm JavaScript `updateDashboardData`**
  - Cập nhật binding dữ liệu cho `valThueFCT`.
  - Render bảng `tableTopChungTu` hiển thị đầy đủ thông tin phê duyệt và liên kết click.

---

### Task 3: Cầu Nối Tương Tác & Điều Hướng trên Form 1C (`TrangChuTongQuan`)

**Files:**
- Modify: `src/CommonForms/TrangChuTongQuan/Ext/Form/Module.bsl`

**Interfaces:**
- Consumes: Sự kiện `TruongHTMLDashboardOnClick` trên Form 1C
- Produces: Mở form chứng từ tương ứng hoặc làm mới số liệu

- [ ] **Step 1: Xử lý các lệnh điều hướng từ HTML trong `TruongHTMLDashboardOnClick`**
  Cập nhật `src/CommonForms/TrangChuTongQuan/Ext/Form/Module.bsl`:
  - `vsmart://action=refresh`: Gọi `CapNhatDuLieuDashboardAtServer()` và thông báo `ShowUserNotification`.
  - `vsmart://create?type=...`: Gọi `OpenForm("Document." + DocType + ".ObjectForm")`.
  - `vsmart://open?type=...&id=...`: Tìm chứng từ bằng UUID / Number và gọi `OpenForm("Document." + DocType + ".ObjectForm", New Structure("Key", DocRef))`.

- [ ] **Step 2: Kiểm tra cú pháp BSL**
  Run: `python -B scripts/verify_bsl_syntax.py`
  Expected: `Checked 18 BSL files. Total syntax balance issues: 0`

---

### Task 4: Đăng Ký DataProcessor & Tích Hợp Menu Điều Hướng Chính

**Files:**
- Create: `src/DataProcessors/DashboardTongQuan.xml`
- Modify: `src/Configuration.xml`
- Modify: `src/ConfigDumpInfo.xml`
- Modify: `src/Ext/MainSectionCommandInterface.xml`

**Interfaces:**
- Consumes: `CommonForm.TrangChuTongQuan`
- Produces: `DataProcessor.DashboardTongQuan.StandardCommand.Open` xuất hiện ở vị trí đầu tiên của thanh điều hướng Taxi.

- [ ] **Step 1: Tạo tệp Metadata `src/DataProcessors/DashboardTongQuan.xml`**
  Khai báo `DataProcessor.DashboardTongQuan` với:
  - `<UseStandardCommands>true</UseStandardCommands>`
  - `<DefaultForm>CommonForm.TrangChuTongQuan</DefaultForm>`
  - Synonym tiếng Việt: `Bàn làm việc Tổng quan Điều hành`
  - Synonym tiếng Anh: `Executive Overview Dashboard`

- [ ] **Step 2: Khai báo DataProcessor trong `src/Configuration.xml` và `src/ConfigDumpInfo.xml`**
  - Thêm `<DataProcessor>DashboardTongQuan</DataProcessor>` vào `ChildObjects` của `Configuration.xml`.
  - Thêm entry vào `ConfigDumpInfo.xml` với UUID hợp lệ.

- [ ] **Step 3: Cập nhật `src/Ext/MainSectionCommandInterface.xml`**
  - Bổ sung lệnh `DataProcessor.DashboardTongQuan.StandardCommand.Open` vào `CommandsVisibility` (`Common = true`).
  - Bổ sung vào `CommandsPlacement` (`CommandGroup = NavigationPanelOrdinary`, `Placement = Manual`).
  - Đặt lên đầu danh sách `CommandsOrder` để hiển thị trước các chứng từ.

---

### Task 5: Kiểm Thử Toàn Diện & Nghiệm Thu Hệ Thống

**Files:**
- Verify: Toàn bộ cấu hình `src/`

- [ ] **Step 1: Kiểm tra cú pháp BSL trên toàn bộ workspace**
  Run: `python -B scripts/verify_bsl_syntax.py`
  Expected: 0 lỗi cú pháp cân bằng khối lệnh.

- [ ] **Step 2: Kiểm tra bộ test suite offline**
  Run: `python -B -m unittest discover -s scripts -p test_audit_tools.py -v`
  Run: `python -B -m unittest discover -s scripts -p test_onec_runtime.py -v`
  Expected: Tất cả các test case đều PASS.

- [ ] **Step 3: Kiểm tra cấu trúc XML Metadata**
  Xác minh các file XML vừa tạo/sửa đều hợp lệ và tuân thủ schema 1C version 2.15.
