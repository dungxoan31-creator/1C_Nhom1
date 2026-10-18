# Kế Hoạch Triển Khai: Hệ Thống Giao Diện Web ERP Chuyên Dụng VinSmart 1C

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Triển khai nâng cấp toàn diện giao diện Web Client VinSmart 1C đạt chuẩn Ứng dụng Web ERP Doanh nghiệp Hiện đại (VinSmart Enterprise Modern SaaS 2026), ưu tiên sử dụng DataProcessor làm hạt nhân điều hành.

**Architecture:** Kết hợp mô hình Hybrid Taxi UI với Trung tâm điều hành `DataProcessors.BanLamViecWebERP` nhúng Cockpit HTML5/SVG thuần và hệ thống Biểu mẫu Chứng từ/Danh sách động chuẩn hóa 1C Managed Forms. Đảm bảo zero external network dependencies, tối ưu hóa client-server (#std487, #std629) và bảo toàn 100% dữ liệu kế toán và phân quyền Maker-Checker.

**Tech Stack:** 1C:Enterprise 8.3 (Managed Application, Taxi UI, Web Client), 1C BSL Scripting, HTML5/CSS/SVG nội tuyến, Python 3.14 (Validation & Build automation), PowerShell (Web Publishing).

**Spec:** [`docs/superpowers/specs/2026-10-18-modern-web-erp-ui-spec.md`](file:///C:/Users/Dung/Documents/VinSmart_1C_VietHoa_Test/docs/superpowers/specs/2026-10-18-modern-web-erp-ui-spec.md)

## Global Constraints

- **Ưu tiên DataProcessor:** Toàn bộ logic tổng hợp tài chính cho dashboard và phê duyệt hàng loạt phải đặt trong `DataProcessors.BanLamViecWebERP`.
- **Zero External Network Dependency:** Không sử dụng CDN hay thư viện bên ngoài; 100% HTML, CSS và biểu đồ SVG chạy offline trên mạng nội bộ On-Premise.
- **Tiêu chuẩn phát triển 1C (1C Development Standards):**
  - Chuẩn #std487: Hạn chế tối đa số lần gọi Server từ Form Client; không gọi server trong các thao tác tính toán số học nhẹ.
  - Chuẩn #std629: Tự động tính Thành tiền = Số lượng * Đơn giá ngay tại Client trong sự kiện `OnChange`.
  - Chuẩn #std409: Sử dụng `FormAttributeToValue()` thay vì `FormDataToValue()`.
  - Chuẩn #std400 / #std418: Hiển thị thông báo người dùng qua `ShowUserNotification()` hoặc `UserMessage`, không dùng cửa sổ modal chặn luồng.
  - Chuẩn #std657: Tối ưu điều kiện lọc trên `DynamicList` qua virtual table parameters.
- **Bảo toàn dữ liệu & nghiệp vụ:** Không thay đổi bất kỳ logic ghi sổ (Posting) nào của 5 chứng từ, không phá vỡ phân quyền Maker-Checker và sổ cái `SoCaiKeToan`.
- **Chất lượng mã nguồn:** 0 lỗi cú pháp BSL (`verify_bsl_syntax.py`), 0 lỗi kiểm tra cấu hình (`CheckConfig`).

## Review Focus

1. **Khả năng hiển thị chéo nền tảng (Cross-Client Compatibility):** Giao diện Cockpit HTML5/SVG và các Form chứng từ phải hiển thị hoàn hảo, không vỡ layout trên cả trình duyệt Web (Chrome, Edge) và 1C Thin Client.
2. **Xử lý sự kiện Click Drill-down:** Các liên kết URL Scheme dạng `e1cib/...` trên Dashboard khi click trên Web Client phải điều hướng mở đúng chứng từ đích mà không gây lỗi phiên làm việc.
3. **Độ nhạy tính toán tức thì (Realtime Client Recalculation):** Khi người dùng sửa số lượng hoặc đơn giá trên bảng dòng hàng, thành tiền và thuế phải nhảy ngay lập tức mà không có độ trễ mạng.
4. **Kiểm soát tính hợp lệ dữ liệu khi phê duyệt hàng loạt:** Bàn duyệt hàng loạt phải từ chối các chứng từ không đủ điều kiện (ví dụ: chưa được Kế toán trưởng soát xét) và thông báo lý do rõ ràng cho từng dòng.
5. **Toàn vẹn Metadata 1C:** Việc đăng ký `DataProcessors.BanLamViecWebERP` và các biểu mẫu mới trong `Configuration.xml` và `ConfigDumpInfo.xml` phải chuẩn xác về UUID và định dạng phân cấp.

---

### Task 1: Khởi Tạo & Đăng Ký `DataProcessors.BanLamViecWebERP`

**Files:**
- Create: `src/DataProcessors/BanLamViecWebERP.xml`
- Create: `src/DataProcessors/BanLamViecWebERP/Ext/ObjectModule.bsl`
- Create: `src/DataProcessors/BanLamViecWebERP/Ext/ManagerModule.bsl`
- Modify: `src/Configuration.xml`
- Modify: `src/ConfigDumpInfo.xml`
- Test: `scripts/test_dataprocessor_registration.py`

**Interfaces:**
- Produces:
  - Metadata: `DataProcessor.BanLamViecWebERP`
  - Manager Module: `DataProcessors.BanLamViecWebERP.LayDuLieuCockpit(KyBaoCao) -> Structure`
  - Object Module: `BanLamViecWebERP.PheDuyetHangLoat(DanhSachChungTu) -> Structure`

- [ ] **Step 1: Viết test kiểm tra đăng ký DataProcessor**

```python
# scripts/test_dataprocessor_registration.py
import unittest
from pathlib import Path

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent

class TestDataProcessorRegistration(unittest.TestCase):
    def test_dataprocessor_files_and_registration(self):
        dp_xml = WORKSPACE_ROOT / "src" / "DataProcessors" / "BanLamViecWebERP.xml"
        self.assertTrue(dp_xml.exists(), "BanLamViecWebERP.xml must exist")
        config_xml = WORKSPACE_ROOT / "src" / "Configuration.xml"
        self.assertIn("<DataProcessor>BanLamViecWebERP</DataProcessor>", config_xml.read_text(encoding="utf-8"))
```

- [ ] **Step 2: Chạy test để xác nhận FAIL**

Run: `python -B -m unittest scripts/test_dataprocessor_registration.py`  
Expected: FAIL (File not found / not registered)

- [ ] **Step 3: Tạo metadata XML và các module BSL cho `DataProcessors.BanLamViecWebERP`**

Tạo thư mục `src/DataProcessors/`, file `BanLamViecWebERP.xml`, `Ext/ObjectModule.bsl` và `Ext/ManagerModule.bsl`. Đăng ký `<DataProcessor>BanLamViecWebERP</DataProcessor>` trong `Configuration.xml` và `ConfigDumpInfo.xml`.

- [ ] **Step 4: Chạy test xác nhận PASS**

Run: `python -B -m unittest scripts/test_dataprocessor_registration.py`  
Expected: PASS (1 test OK)

- [ ] **Step 5: Kiểm tra cú pháp BSL**

Run: `python -B scripts/verify_bsl_syntax.py`  
Expected: 0 Syntax Errors.

---

### Task 2: Xây Dựng Biểu Mẫu Cockpit Dashboard & Bàn Duyệt Hàng Loạt Trong DataProcessor

**Files:**
- Create: `src/DataProcessors/BanLamViecWebERP/Forms/FormBanLamViec.xml`
- Create: `src/DataProcessors/BanLamViecWebERP/Forms/FormBanLamViec/Ext/Form.xml`
- Create: `src/DataProcessors/BanLamViecWebERP/Forms/FormBanLamViec/Ext/Form/Module.bsl`
- Create: `src/DataProcessors/BanLamViecWebERP/Forms/FormPheDuyetHangLoat.xml`
- Create: `src/DataProcessors/BanLamViecWebERP/Forms/FormPheDuyetHangLoat/Ext/Form.xml`
- Create: `src/DataProcessors/BanLamViecWebERP/Forms/FormPheDuyetHangLoat/Ext/Form/Module.bsl`
- Modify: `src/DataProcessors/BanLamViecWebERP.xml` (Khai báo 2 forms: `FormBanLamViec`, `FormPheDuyetHangLoat`)
- Modify: `src/CommonTemplates/MauHTMLTrangChu/Template.txt` (Cập nhật giao diện HTML5/SVG Cockpit VinSmart Modern)
- Test: `scripts/test_workbench_forms.py`

**Interfaces:**
- Consumes: `DataProcessors.BanLamViecWebERP`, `CommonModule.BangDieuKhienServer`.
- Produces:
  - Form `FormBanLamViec`: Dashboard Cockpit với 4 KPI Cards, Bar Chart SVG 6 tháng, Donut Chart tuổi nợ, danh sách việc ưu tiên và link `e1cib/...` drill-down.
  - Form `FormPheDuyetHangLoat`: Bảng duyệt tập trung Maker-Checker, tích chọn nhiều chứng từ và nút phê duyệt đồng loạt.

- [ ] **Step 1: Viết test kiểm tra cấu trúc 2 Form trong DataProcessor**

```python
# scripts/test_workbench_forms.py
import unittest
from pathlib import Path

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent

class TestWorkbenchForms(unittest.TestCase):
    def test_workbench_forms_exist(self):
        forms = ["FormBanLamViec", "FormPheDuyetHangLoat"]
        for form in forms:
            meta = WORKSPACE_ROOT / "src" / "DataProcessors" / "BanLamViecWebERP" / "Forms" / f"{form}.xml"
            ext_xml = WORKSPACE_ROOT / "src" / "DataProcessors" / "BanLamViecWebERP" / "Forms" / form / "Ext" / "Form.xml"
            ext_bsl = WORKSPACE_ROOT / "src" / "DataProcessors" / "BanLamViecWebERP" / "Forms" / form / "Ext" / "Form" / "Module.bsl"
            self.assertTrue(meta.exists(), f"{form}.xml must exist")
            self.assertTrue(ext_xml.exists(), f"{form}/Ext/Form.xml must exist")
            self.assertTrue(ext_bsl.exists(), f"{form}/Ext/Form/Module.bsl must exist")
```

- [ ] **Step 2: Chạy test xác nhận FAIL**

Run: `python -B -m unittest scripts/test_workbench_forms.py`  
Expected: FAIL

- [ ] **Step 3: Triển khai Form `FormBanLamViec` và `FormPheDuyetHangLoat`**

Triển khai đầy đủ metadata Form XML và BSL Module. Cập nhật `MauHTMLTrangChu` với phong cách VinSmart Modern (Đỏ `#EA0B2A`, Slate `#F8FAFC`, SVG Bar & Donut chart, URL Scheme drill-down).

- [ ] **Step 4: Chạy test xác nhận PASS**

Run: `python -B -m unittest scripts/test_workbench_forms.py`  
Expected: PASS

- [ ] **Step 5: Kiểm tra cú pháp BSL**

Run: `python -B scripts/verify_bsl_syntax.py`  
Expected: 0 Syntax Errors.

---

### Task 3: Nâng Cấp Form Chứng Từ Cho 4 Chứng Từ Hiện Tại & Tạo Mới Form Cho Biên Bản Nghiệm Thu

**Files:**
- Create: `src/Documents/BienBanNghiemThuGiaiDoan/Forms/FormChungTu.xml`
- Create: `src/Documents/BienBanNghiemThuGiaiDoan/Forms/FormChungTu/Ext/Form.xml`
- Create: `src/Documents/BienBanNghiemThuGiaiDoan/Forms/FormChungTu/Ext/Form/Module.bsl`
- Modify: `src/Documents/BienBanNghiemThuGiaiDoan.xml` (Đăng ký DefaultObjectForm)
- Modify: `src/Documents/HoaDonGTGTDauRa/Forms/FormChungTu/Ext/Form.xml` & `Module.bsl`
- Modify: `src/Documents/HoaDonNhaCungCap/Forms/FormChungTu/Ext/Form.xml` & `Module.bsl`
- Modify: `src/Documents/PhieuThuTienKhachHang/Forms/FormChungTu/Ext/Form.xml` & `Module.bsl`
- Modify: `src/Documents/UyNhiemChi/Forms/FormChungTu/Ext/Form.xml` & `Module.bsl`
- Test: `scripts/test_all_document_forms.py`

**Interfaces:**
- Produces:
  - Header Bar với Status Badge động (`✓ ĐÃ GHI SỔ`, `⏳ BẢN NHÁP`, `✕ ĐÃ HỦY`).
  - Thẻ tổng tiền thanh toán nổi bật font lớn màu `#EA0B2A`.
  - Workflow Stepper 4 bước hiển thị tiến trình Maker-Checker.
  - 4 Tabs công thái học: `Thông tin chung` (2 cột), `Chi tiết hàng hóa/thanh toán`, `Hóa đơn điện tử & Thuế`, `Nhật ký & Phê duyệt`.
  - Nút `[ Xem chứng từ liên quan ]` và Toast thông báo `ShowUserNotification`.
  - Sự kiện Client `OnChange` tính toán thành tiền và tiền thuế tức thì.

- [ ] **Step 1: Viết test kiểm tra Form của tất cả 5 chứng từ**

```python
# scripts/test_all_document_forms.py
import unittest
from pathlib import Path

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent

class TestAllDocumentForms(unittest.TestCase):
    def test_all_five_docs_have_complete_forms(self):
        docs = [
            "HoaDonGTGTDauRa", "HoaDonNhaCungCap",
            "PhieuThuTienKhachHang", "UyNhiemChi", "BienBanNghiemThuGiaiDoan"
        ]
        for doc in docs:
            form_xml = WORKSPACE_ROOT / "src" / "Documents" / doc / "Forms" / "FormChungTu" / "Ext" / "Form.xml"
            form_bsl = WORKSPACE_ROOT / "src" / "Documents" / doc / "Forms" / "FormChungTu" / "Ext" / "Form" / "Module.bsl"
            self.assertTrue(form_xml.exists(), f"{doc} Form.xml must exist")
            self.assertTrue(form_bsl.exists(), f"{doc} Module.bsl must exist")
            xml_text = form_xml.read_text(encoding="utf-8")
            self.assertIn("ThongTinChung", xml_text, f"{doc} must have ThongTinChung tab")
            self.assertIn("HuyHieuTrangThai", xml_text, f"{doc} must have HuyHieuTrangThai element")
```

- [ ] **Step 2: Chạy test xác nhận FAIL (do thiếu BienBanNghiemThuGiaiDoan và badge)**

Run: `python -B -m unittest scripts/test_all_document_forms.py`  
Expected: FAIL

- [ ] **Step 3: Triển khai hoàn thiện FormChungTu cho 5 chứng từ**

Tạo mới `FormChungTu` cho `BienBanNghiemThuGiaiDoan`. Nâng cấp Form của 4 chứng từ còn lại: bổ sung Status Badge, Workflow Stepper, Thẻ tổng tiền, Toast Notification và tính toán realtime tại Client.

- [ ] **Step 4: Chạy test xác nhận PASS**

Run: `python -B -m unittest scripts/test_all_document_forms.py`  
Expected: PASS

- [ ] **Step 5: Kiểm tra cú pháp BSL**

Run: `python -B scripts/verify_bsl_syntax.py`  
Expected: 0 Syntax Errors.

---

### Task 4: Xây Dựng Danh Sách Chứng Từ Hiện Đại (`Modern List Forms`)

**Files:**
- Create: `src/Documents/HoaDonGTGTDauRa/Forms/FormDanhSach.xml`, `Ext/Form.xml`, `Ext/Form/Module.bsl`
- Create: `src/Documents/HoaDonNhaCungCap/Forms/FormDanhSach.xml`, `Ext/Form.xml`, `Ext/Form/Module.bsl`
- Create: `src/Documents/PhieuThuTienKhachHang/Forms/FormDanhSach.xml`, `Ext/Form.xml`, `Ext/Form/Module.bsl`
- Create: `src/Documents/UyNhiemChi/Forms/FormDanhSach.xml`, `Ext/Form.xml`, `Ext/Form/Module.bsl`
- Create: `src/Documents/BienBanNghiemThuGiaiDoan/Forms/FormDanhSach.xml`, `Ext/Form.xml`, `Ext/Form/Module.bsl`
- Modify: `src/Documents/*.xml` (Đăng ký `DefaultListForm = Document.<Doc>.Form.FormDanhSach`)
- Test: `scripts/test_modern_list_forms.py`

**Interfaces:**
- Produces:
  - Thanh Quick Filters Bar ở Header danh sách: Lọc theo Kỳ (Hôm nay, Tháng này, Quý này, Tất cả), Trạng thái (Đã ghi sổ, Nháp, Hủy) và Đối tác.
  - `ConditionalAppearance` tô màu trực quan (bản nháp vàng nhạt, ghi sổ chuẩn, hủy gạch ngang mờ, nợ quá hạn text đỏ).

- [ ] **Step 1: Viết test kiểm tra Modern List Forms**

```python
# scripts/test_modern_list_forms.py
import unittest
from pathlib import Path

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent

class TestModernListForms(unittest.TestCase):
    def test_list_forms_exist_and_configured(self):
        docs = [
            "HoaDonGTGTDauRa", "HoaDonNhaCungCap",
            "PhieuThuTienKhachHang", "UyNhiemChi", "BienBanNghiemThuGiaiDoan"
        ]
        for doc in docs:
            meta = WORKSPACE_ROOT / "src" / "Documents" / doc / "Forms" / "FormDanhSach.xml"
            ext_xml = WORKSPACE_ROOT / "src" / "Documents" / doc / "Forms" / "FormDanhSach" / "Ext" / "Form.xml"
            self.assertTrue(meta.exists(), f"{doc} FormDanhSach.xml must exist")
            self.assertTrue(ext_xml.exists(), f"{doc} FormDanhSach/Ext/Form.xml must exist")
            doc_xml = WORKSPACE_ROOT / "src" / "Documents" / f"{doc}.xml"
            self.assertIn(f"<DefaultListForm>Document.{doc}.Form.FormDanhSach</DefaultListForm>", doc_xml.read_text(encoding="utf-8"))
```

- [ ] **Step 2: Chạy test xác nhận FAIL**

Run: `python -B -m unittest scripts/test_modern_list_forms.py`  
Expected: FAIL

- [ ] **Step 3: Triển khai FormDanhSach cho 5 chứng từ và gắn ConditionalAppearance**

Xây dựng các FormDanhSach với DynamicList, thêm các form item cho bộ lọc nhanh và cấu hình ConditionalAppearance tô màu phân biệt dòng. Đăng ký `<DefaultListForm>` trong metadata chứng từ.

- [ ] **Step 4: Chạy test xác nhận PASS**

Run: `python -B -m unittest scripts/test_modern_list_forms.py`  
Expected: PASS

- [ ] **Step 5: Kiểm tra cú pháp BSL**

Run: `python -B scripts/verify_bsl_syntax.py`  
Expected: 0 Syntax Errors.

---

### Task 5: Đồng Bộ Phân Hệ (`Subsystems`), Nhận Diện Thương Hiệu (`StyleItems`) & Cấu Hình Web Client

**Files:**
- Modify: `src/Subsystems/PhanHeDanhMuc.xml`
- Modify: `src/Subsystems/PhanHePhaiThu.xml`
- Modify: `src/Subsystems/PhanHePhaiTra.xml`
- Modify: `src/Subsystems/PhanHeNganHangVaQuy.xml`
- Modify: `src/Subsystems/PhanHeSoCaiVaDongBo.xml`
- Modify: `src/StyleItems/*.xml` (Đồng bộ bảng màu VinSmart Red, Slate Light, Border)
- Modify: `default.vrd` (Chuẩn hóa cấu hình Web Client)
- Test: `scripts/test_subsystems_and_styles.py`

**Interfaces:**
- Produces:
  - Đăng ký `DataProcessor.BanLamViecWebERP` vào cả 5 phân hệ để người dùng truy cập thuận tiện từ bất kỳ đâu.
  - Đồng bộ StyleItems cho giao diện Taxi UI.
  - Cấu hình Virtual Resource `default.vrd` cho Apache/IIS.

- [ ] **Step 1: Viết test kiểm tra tích hợp Subsystem và StyleItems**

```python
# scripts/test_subsystems_and_styles.py
import unittest
from pathlib import Path

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent

class TestSubsystemsAndStyles(unittest.TestCase):
    def test_dataprocessor_in_subsystems(self):
        subsystems = [
            "PhanHePhaiThu", "PhanHePhaiTra", "PhanHeNganHangVaQuy",
            "PhanHeSoCaiVaDongBo", "PhanHeDanhMuc"
        ]
        for sub in subsystems:
            sub_xml = WORKSPACE_ROOT / "src" / "Subsystems" / f"{sub}.xml"
            content = sub_xml.read_text(encoding="utf-8")
            self.assertIn("<xr:Item xsi:type=\"xr:MDObjectRef\">DataProcessor.BanLamViecWebERP</xr:Item>", content, f"{sub} must include BanLamViecWebERP")
```

- [ ] **Step 2: Chạy test xác nhận FAIL**

Run: `python -B -m unittest scripts/test_subsystems_and_styles.py`  
Expected: FAIL

- [ ] **Step 3: Cập nhật Subsystems và StyleItems**

Thêm `DataProcessor.BanLamViecWebERP` vào `<Content>` của 5 phân hệ. Cập nhật các giá trị màu sắc trong `StyleItems/`.

- [ ] **Step 4: Chạy test xác nhận PASS**

Run: `python -B -m unittest scripts/test_subsystems_and_styles.py`  
Expected: PASS

---

### Task 6: Kiểm Thử Toàn Diện, Xác Thực 0 Lỗi & Tự Động Build Xuất Gói `VinSmart_Future_Modern_Web_UI.dt`

**Files:**
- Create: `scripts/build_web_erp_ui_dt.py`
- Create: `scripts/verify_check_config.ps1`
- Test: Chạy toàn bộ bộ testsuite
- Output: `VinSmart_Future_Modern_Web_UI.dt`

**Interfaces:**
- Produces: File cơ sở dữ liệu `VinSmart_Future_Modern_Web_UI.dt` mới nhất, 100% sạch, đã tích hợp đầy đủ giao diện Web ERP và sẵn sàng vận hành.

- [ ] **Step 1: Chạy toàn bộ kiểm tra cú pháp BSL**

Run: `python -B scripts/verify_bsl_syntax.py`  
Expected: Exit code 0, 0 Syntax Errors trên 100% file BSL.

- [ ] **Step 2: Chạy kiểm tra tính toàn vẹn cấu hình (CheckConfig)**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify_check_config.ps1`  
Expected: ReturnCode = 0, không có mâu thuẫn metadata.

- [ ] **Step 3: Chạy script build tự động nạp `src/` và đóng gói xuất file `.dt`**

Run: `python -B scripts/build_web_erp_ui_dt.py`  
Expected: Tạo thành công file `VinSmart_Future_Modern_Web_UI.dt` với dung lượng > 400KB.

- [ ] **Step 4: Kiểm tra xác minh gói `.dt` vừa tạo**

Run: `python -B scripts/verify_dt_accounts.py`  
Expected: Xác thực thành công toàn bộ hệ thống tài khoản TT200 và cấu hình Web UI trong file `.dt`.
