# CFO Dashboard & Modern 3D Enterprise UI Enhancement Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Triển khai nâng cấp giao diện chuẩn "Modern 3D Enterprise" cho hệ thống ERP VinSmart Future (VSF), bao gồm bộ Design Tokens mới, Bàn làm việc Lãnh đạo CFO (`DashboardLanhDaoCFO`) dạng 3D Fintech thời gian thực, và cấu hình tô màu cảnh báo có điều kiện (`Conditional Appearance`) cho báo cáo tài chính.

**Architecture:** Kết hợp sức mạnh native của nền tảng 1C:Enterprise 8.3 (Managed Forms, StyleItems, Conditional Appearance) với khả năng trực quan hóa cao cấp thông qua `HTMLDocumentField` (HTML5/CSS3 Grid, Soft 3D Elevation, Tabular numbers). Hệ thống lấy dữ liệu trực tiếp từ các hàm nghiệp vụ đã kiểm toán của `BaoCaoQuanTriServer` và `DashboardLanhDaoCFO`.

**Tech Stack:** 1C:Enterprise 8.3 (BSL, Managed Forms XML 2.15), HTML5/CSS3 (Modern 3D Enterprise, Glassmorphism, Responsive Grid), Python 3.12 (Kiểm thử tự động).

**Spec:** `docs/superpowers/specs/2026-10-14-modern-3d-enterprise-ui-spec.md`

## Global Constraints

- Tuân thủ nghiêm ngặt chuẩn XML 1C:Enterprise version 2.15 (không phá vỡ metadata schema).
- Đảm bảo 100% tương thích ngược và giữ nguyên toàn bộ logic kế toán, kiểm toán đã đạt 100/100.
- Không để xảy ra lỗi cú pháp (`/CheckConfig -Config -Server` phải đạt ExitCode 0, No errors found).
- Toàn bộ 114 bộ kiểm thử tự động của repository phải tiếp tục PASS 100%.
- Đóng gói toàn bộ cấu hình mới vào duy nhất 1 file `.dt` chuẩn: `VinSmart_Future_AR_AP_Full.dt`.

## Review Focus

1. Kiểm tra trường HTML trong 1C Desktop Client: Đảm bảo HTML load mượt mà, không gọi tài nguyên CDN ngoài internet (hoàn toàn tự chứa, offline-first).
2. Xung đột bảng mã Unicode tiếng Việt: Đảm bảo các chuỗi HTML tiếng Việt hiển thị sắc nét, không lỗi font UTF-8 BOM.
3. Đồng bộ dữ liệu tài chính: Các số liệu trên thẻ KPI (Tổng AR, Tổng AP, Tiền gửi, Quá hạn) phải khớp chính xác 100% với số liệu kiểm toán Sổ Cái VAS.
4. Tương thích phân quyền: Đảm bảo các vai trò `GiamDocTaiChinh_CFO`, `KeToanTruong`, `QuanTriHeThong` đều có quyền mở và thao tác trên Dashboard mới.
5. Cân bằng bố cục trên các độ phân giải: Hoạt động hoàn hảo từ màn hình laptop 1366x768 đến màn hình 1920x1080 (Full HD).

---

### Task 1: Bổ sung các StyleItems chuẩn cho trạng thái nghiệp vụ

**Files:**
- Create: `src/StyleItems/MauTrangThaiThanhCong.xml`
- Create: `src/StyleItems/MauCanhBaoVangVSF.xml`
- Create: `src/StyleItems/MauTrangThaiNhap.xml`
- Create: `src/StyleItems/MauVanBanPhuVSF.xml`
- Create: `src/StyleItems/MauThongTinVSF.xml`
- Modify: `src/Configuration.xml`

**Steps:**
- [ ] Bước 1.1: Tạo 5 file metadata `StyleItem` định nghĩa các màu: Xanh ngọc (`#059669`), Vàng hổ phách (`#D97706`), Xám nháp (`#64748B`), Xám nhãn (`#475569`), Xanh cobalt (`#2563EB`).
- [ ] Bước 1.2: Khai báo 5 StyleItem mới vào danh mục `<ChildObjects>` trong `src/Configuration.xml`.
- [ ] Bước 1.3: Chạy `scripts/verify_bsl_syntax.py` và kiểm tra tính toàn vẹn XML.

---

### Task 2: Xây dựng hàm sinh giao diện HTML 3D Fintech cho Dashboard CFO

**Files:**
- Modify: `src/CommonModules/BaoCaoQuanTriServer/Ext/Module.bsl`
- Test: `scripts/test_dashboard_cfo_html.py`

**Steps:**
- [ ] Bước 2.1: Viết test unit `scripts/test_dashboard_cfo_html.py` kiểm tra cấu trúc HTML sinh ra từ hàm server (chứa đầy đủ banner 3D, 4 thẻ KPI, số tiền tabular, và bảng phân bổ tuổi nợ).
- [ ] Bước 2.2: Bổ sung hàm `SinhHTMLDashboardLanhDaoCFO(Val SoLieuDashboard)` trong `BaoCaoQuanTriServer` tạo mã HTML5/CSS3 chuẩn "Modern 3D Enterprise" với đầy đủ dữ liệu động (AR 39.55B, AP 34.44B, Tiền gửi 817.82B, Quá hạn 10.1%).
- [ ] Bước 2.3: Chạy `python -B scripts/test_dashboard_cfo_html.py` xác nhận test PASS.

---

### Task 3: Tạo Managed Form trực quan cho `DashboardLanhDaoCFO`

**Files:**
- Create: `src/DataProcessors/DashboardLanhDaoCFO/Forms/Form.xml`
- Create: `src/DataProcessors/DashboardLanhDaoCFO/Forms/Form/Ext/Form.xml`
- Create: `src/DataProcessors/DashboardLanhDaoCFO/Forms/Form/Ext/Form/Module.bsl`
- Modify: `src/DataProcessors/DashboardLanhDaoCFO.xml`

**Steps:**
- [ ] Bước 3.1: Tạo metadata `Forms/Form.xml` và khai báo Form trong `DashboardLanhDaoCFO.xml` làm `<DefaultForm>`.
- [ ] Bước 3.2: Tạo `Forms/Form/Ext/Form.xml` chứa thuộc tính `TrangDashboardHTML` (loại String/HTML) cùng trường `HTMLDocumentField` trải rộng toàn màn hình kèm thanh lệnh (Command Bar) chứa nút `Làm mới (F5)`.
- [ ] Bước 3.3: Viết mã BSL trong `Forms/Form/Ext/Form/Module.bsl`: Xử lý sự kiện `OnCreateAtServer()` và lệnh `LamMoi()` tự động lấy dữ liệu từ `ObjectModule` và cập nhật trường HTML.
- [ ] Bước 3.4: Kiểm tra cú pháp bằng `verify_bsl_syntax.py`.

---

### Task 4: Cập nhật quyền truy cập (Rights) cho Form mới của Dashboard CFO

**Files:**
- Modify: `src/Roles/GiamDocTaiChinh_CFO/Ext/Rights.xml`
- Modify: `src/Roles/QuanTriHeThong/Ext/Rights.xml`
- Modify: `src/Roles/KeToanTruong/Ext/Rights.xml`

**Steps:**
- [ ] Bước 4.1: Bổ sung quyền `<name>DataProcessor.DashboardLanhDaoCFO.Form.Form</name>` trong Rights.xml của các vai trò CFO, Kế toán trưởng và Quản trị hệ thống.
- [ ] Bước 4.2: Kiểm tra cú pháp XML của các file Rights.

---

### Task 5: Kiểm định toàn diện trên 1C Runtime & Đóng gói CSDL chuẩn

**Files:**
- Update: `Infobase_FullData`
- Update: `VinSmart_Future_AR_AP_Full.dt`

**Steps:**
- [ ] Bước 5.1: Chạy biên dịch cú pháp 1C Designer `/CheckConfig -Config -Server` xác nhận 0 lỗi.
- [ ] Bước 5.2: Cập nhật cấu hình vào CSDL bằng `/UpdateDBCfg`.
- [ ] Bước 5.3: Chạy toàn bộ 114 bộ kiểm thử unit/runtime bằng `python -B -m unittest discover -s scripts -p "test_*.py"`.
- [ ] Bước 5.4: Xuất gói CSDL hoàn chỉnh ra file duy nhất `VinSmart_Future_AR_AP_Full.dt`.
- [ ] Bước 5.5: Tạo clone UAT mới từ file `.dt` và xác thực lại toàn bộ các lệnh kiểm toán (`VerifyGLAnalyticKeys`, `ExportTrialBalanceEvidence`, `RunRBACChecks`).
- [ ] Bước 5.6: Commit và push cập nhật lên nhánh `main` và `master` của GitHub.
