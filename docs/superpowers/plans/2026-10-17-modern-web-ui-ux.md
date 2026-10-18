# Modern Web UI/UX Implementation Plan for VinSmart 1C

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Hiện đại hóa giao diện người dùng VinSmart 1C:Enterprise 8.3 đạt chuẩn Web App (Dashboard HTML5 + Form chứng từ Tab/Badge + Web Client ready) và đóng gói thành file CSDL `.dt` hoàn chỉnh.

**Architecture:** Sử dụng kiến trúc Hybrid Taxi kết hợp biểu mẫu dùng chung `CommonForm.TrangChuTongQuan` nhúng trường `HTMLDocumentField` (HTML5/CSS phong cách SaaS, biểu đồ SVG offline), module BSL Server tổng hợp số liệu tài chính, các Managed Form chứng từ được tái cấu trúc thành các thẻ Card, Tabs và Status Badges; sau đó cập nhật Infobase và xuất file `.dt` mới.

**Tech Stack:** 1C:Enterprise 8.3.22 (Managed Application, Taxi UI), BSL (1C Enterprise Script), XML metadata dump, HTML5/CSS3/SVG, Python 3 / PowerShell.

**Spec:** [docs/superpowers/specs/2026-10-17-modern-web-ui-ux-design.md](file:///C:/Users/Dung/Documents/VinSmart_1C_VietHoa_Test/docs/superpowers/specs/2026-10-17-modern-web-ui-ux-design.md)

## Global Constraints

- Phiên bản nền tảng 1C: 8.3.22.1704, CompatibilityMode: Version8_3_22.
- Giao diện: Taxi (`InterfaceCompatibilityMode = Taxi`), DefaultRunMode: ManagedApplication.
- Màu sắc thương hiệu VinSmart: `#EA0B2A` (`MauChuDaoVSF`).
- Không phụ thuộc mạng Internet/CDN bên ngoài: Toàn bộ CSS/JS/SVG chạy offline cục bộ.
- Bảo toàn 100% logic nghiệp vụ: Không thay đổi cấu trúc Sổ kế toán, Sổ tích lũy, GL key hay quy trình kiểm soát Maker-Checker.

## Review Focus

- HTML Document Field tương thích cả Web Client trình duyệt lẫn Thin Client máy tính.
- Sự kiện click trên Dashboard HTML gọi đúng lệnh mở form của 1C mà không crash client.
- Form chứng từ tính toán lại thành tiền/thuế mượt mà tại client khi thay đổi số lượng/đơn giá.
- Lệnh cập nhật cấu hình `/UpdateDBCfg` và xuất `/DumpIB` ra `.dt` thực thi sạch sẽ, exit code 0.
- Không gây lỗi cú pháp BSL (`verify_bsl_syntax.py` trả về PASS).

---

### Task 1: Thiết lập Cấu hình & Kích hoạt Web Client

**Files:**
- Modify: `src/Configuration.xml`
- Modify: `src/ConfigDumpInfo.xml`
- Create: `default.vrd`
- Create: `scripts/publish_web_client.ps1`
- Test: `scripts/verify_bsl_syntax.py`

**Interfaces:**
- Consumes: Cấu hình hiện hữu của `Configuration.xml`.
- Produces: `Configuration.xml` có `<UsePurposes>` chứa `WebApplication`, đăng ký các đối tượng mới (`CommonForm.TrangChuTongQuan`, `CommonModule.BangDieuKhienServer`, `CommonTemplate.MauHTMLTrangChu`).

- [ ] **Step 1: Viết test kiểm tra cấu hình Web Client trong test script**
  Kiểm tra `Configuration.xml` chứa thẻ `WebApplication` và các ChildObjects cần thiết.
- [ ] **Step 2: Chạy test để xác nhận trạng thái hiện tại thiếu cấu hình**
- [ ] **Step 3: Cập nhật `Configuration.xml` và `ConfigDumpInfo.xml`**
  Thêm `WebApplication`, đăng ký `TrangChuTongQuan`, `BangDieuKhienServer`, `MauHTMLTrangChu`.
- [ ] **Step 4: Tạo file `default.vrd` và script `publish_web_client.ps1`**
  Định dạng xuất bản ảo hóa cho IIS / Apache.
- [ ] **Step 5: Chạy lại test xác nhận PASS**

---

### Task 2: Xây dựng Module BSL Tổng hợp Số liệu Dashboard

**Files:**
- Create: `src/CommonModules/BangDieuKhienServer.xml`
- Create: `src/CommonModules/BangDieuKhienServer/Ext/Module.bsl`
- Create: `scripts/test_dashboard_server.py`

**Interfaces:**
- Consumes: `AccumulationRegisters.CongNoPhaiThu`, `AccumulationRegisters.CongNoPhaiTra`, `AccumulationRegisters.TienGuiNganHang`, `Documents.HoaDonGTGTDauRa`.
- Produces: `BangDieuKhienServer.LayDuLieuTongQuan(KyBaoCao) -> String (JSON)` chứa các trường: `TongDoanhThu`, `NoPhaiThu`, `NoPhaiThuQuaHan`, `NoPhaiTra`, `NoPhaiTraDenHan`, `TienKhaDung`, `TopNoQuaHan`, `TopChungTuChoDuyet`.

- [ ] **Step 1: Viết script test giả lập kiểm tra JSON schema và hàm `LayDuLieuTongQuan`**
- [ ] **Step 2: Chạy test xác nhận FAIL khi chưa có module**
- [ ] **Step 3: Viết mã BSL `src/CommonModules/BangDieuKhienServer/Ext/Module.bsl` và metadata XML**
  Thực hiện truy vấn 1C an toàn, chuyển đổi sang chuỗi JSON bằng `XDTOFactory` hoặc `WriteJSON`.
- [ ] **Step 4: Chạy `scripts/verify_bsl_syntax.py` và script test xác nhận PASS**

---

### Task 3: Xây dựng Template HTML5 & Biểu Mẫu Trang Chủ (`TrangChuTongQuan`)

**Files:**
- Create: `src/CommonTemplates/MauHTMLTrangChu.xml`
- Create: `src/CommonTemplates/MauHTMLTrangChu/Ext/Template.txt`
- Create: `src/CommonForms/TrangChuTongQuan.xml`
- Create: `src/CommonForms/TrangChuTongQuan/Ext/Form.xml`
- Create: `src/CommonForms/TrangChuTongQuan/Ext/Form/Module.bsl`

**Interfaces:**
- Consumes: `BangDieuKhienServer.LayDuLieuTongQuan(KyBaoCao)`.
- Produces: Biểu mẫu Trang chủ 1C hoàn chỉnh với trường tài liệu HTML phản hồi mượt mà, hỗ trợ nút F5 làm mới và lọc kỳ báo cáo.

- [ ] **Step 1: Soạn thảo giao diện HTML5/CSS3/SVG trong `MauHTMLTrangChu/Ext/Template.txt`**
  Đầy đủ 4 khối: Header VSF, 4 Metric Cards, Biểu đồ SVG dòng tiền + tuổi nợ, Bảng tác vụ ưu tiên.
- [ ] **Step 2: Định nghĩa `TrangChuTongQuan/Ext/Form.xml`**
  Khai báo form Managed Form 1C chứa `HTMLDocumentField` và CommandBar actions.
- [ ] **Step 3: Viết logic điều khiển trong `TrangChuTongQuan/Ext/Form/Module.bsl`**
  Xử lý sự kiện `OnCreateAtServer`, nạp JSON vào HTML, xử lý sự kiện `TruongHTMLDashboardOnClick` để mở form chứng từ.
- [ ] **Step 4: Chạy `python -B scripts/verify_bsl_syntax.py` xác nhận 0 lỗi**

---

### Task 4: Thiết kế lại Form Managed Form cho Hóa Đơn Bán Ra (`HoaDonGTGTDauRa`)

**Files:**
- Create: `src/Documents/HoaDonGTGTDauRa/Forms/FormChungTu.xml`
- Create: `src/Documents/HoaDonGTGTDauRa/Forms/FormChungTu/Ext/Form.xml`
- Create: `src/Documents/HoaDonGTGTDauRa/Forms/FormChungTu/Ext/Form/Module.bsl`
- Modify: `src/Documents/HoaDonGTGTDauRa.xml` (gán DefaultForm)

**Interfaces:**
- Consumes: Thuộc tính và bảng dữ liệu của `Document.HoaDonGTGTDauRa`.
- Produces: Giao diện Form chứng từ AR phong cách Web App với Status Badge, Thẻ tổng tiền `#EA0B2A`, hệ thống Tabs (`ThongTinChung`, `ChiTietDichVu`, `ThueVaHoaDonDienTu`, `NhatKy`).

- [ ] **Step 1: Khai báo Form XML với cấu trúc Tabs, Status Badge và Header Card**
- [ ] **Step 2: Viết logic Client/Server trong `Form/Module.bsl`**
  Xử lý hiển thị badge theo trạng thái ghi sổ, realtime tính tổng tiền khi sửa bảng dịch vụ.
- [ ] **Step 3: Cập nhật metadata `HoaDonGTGTDauRa.xml` để trỏ vào Form mới**
- [ ] **Step 4: Chạy `scripts/verify_bsl_syntax.py` xác nhận PASS**

---

### Task 5: Thiết kế lại Form Managed Form cho Hóa Đơn Mua Vào & Thu/Chi Ngân Hàng

**Files:**
- Create: `src/Documents/HoaDonNhaCungCap/Forms/FormChungTu/*`
- Create: `src/Documents/UyNhiemChi/Forms/FormChungTu/*`
- Create: `src/Documents/PhieuThuTienKhachHang/Forms/FormChungTu/*`
- Modify: `src/Documents/HoaDonNhaCungCap.xml`
- Modify: `src/Documents/UyNhiemChi.xml`
- Modify: `src/Documents/PhieuThuTienKhachHang.xml`

**Interfaces:**
- Consumes: Thuộc tính của các chứng từ AP, UNC, Phiếu thu.
- Produces: Chuẩn hóa toàn bộ trải nghiệm người dùng đồng nhất giữa tất cả các chứng từ giao dịch.

- [ ] **Step 1: Tạo Form chứng từ cho `HoaDonNhaCungCap` (AP Invoices)**
- [ ] **Step 2: Tạo Form chứng từ cho `UyNhiemChi` (Bank Payment)**
- [ ] **Step 3: Tạo Form chứng từ cho `PhieuThuTienKhachHang` (Customer Receipt)**
- [ ] **Step 4: Cập nhật metadata XML đăng ký các Form mặc định**
- [ ] **Step 5: Chạy `scripts/verify_bsl_syntax.py` xác nhận PASS**

---

### Task 6: Kiểm thử Toàn diện & Xác thực Không Lỗi Hồi quy (Regression Testing)

**Files:**
- Run: `scripts/verify_bsl_syntax.py`
- Run: `test_audit_tools.py`, `test_onec_runtime.py`, `test_clone_creation.py`

**Interfaces:**
- Consumes: Toàn bộ mã nguồn `src/`.
- Produces: Báo cáo xác thực 0 lỗi cú pháp, toàn bộ suite unittest PASS.

- [ ] **Step 1: Chạy `verify_bsl_syntax.py` trên toàn bộ source tree**
- [ ] **Step 2: Chạy các unittest offline của dự án**
- [ ] **Step 3: Đối chiếu tính nhất quán của metadata XML**

---

### Task 7: Biên dịch Nạp Cấu hình vào Infobase & Xuất File `.dt` Mới

**Files:**
- Create: `scripts/build_web_ui_dt.py`
- Output: `VinSmart_Future_Modern_Web_UI.dt`

**Interfaces:**
- Consumes: `src/` hoàn chỉnh và file `.dt` dữ liệu gốc `VinSmart_Future_AR_AP_Clean.dt`.
- Produces: File cơ sở dữ liệu `VinSmart_Future_Modern_Web_UI.dt` tích hợp đầy đủ giao diện Web App mới.

- [ ] **Step 1: Tạo kịch bản Python tự động tạo infobase sạch, restore dữ liệu gốc**
- [ ] **Step 2: Nạp mã nguồn `src/` mới qua Designer `/LoadConfigFromFiles`**
- [ ] **Step 3: Cập nhật cấu hình cơ sở dữ liệu qua `/UpdateDBCfg`**
- [ ] **Step 4: Xuất gói cơ sở dữ liệu hoàn chỉnh ra `VinSmart_Future_Modern_Web_UI.dt` qua `/DumpIB`**
- [ ] **Step 5: Kiểm tra dung lượng và tính toàn vẹn của file `.dt` mới**
