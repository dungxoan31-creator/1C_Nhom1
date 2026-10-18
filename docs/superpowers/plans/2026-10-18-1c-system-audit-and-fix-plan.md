# Kế Hoạch Rà Soát & Cấu Hình Chuẩn Hóa Hệ Thống 1C:Enterprise (Ponytail & 1C Dev Mentor)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rà soát, chuẩn hóa và cấu hình lại toàn bộ hệ thống 1C:Enterprise (quyền Admin toàn quyền, kiến trúc Metadata PK/FK/Register, ràng buộc bắt buộc declarative, tự động điền BSL lifecycle, phân định Enum/Catalog, form Taxi UI/UX và tính toàn vẹn CSDL) theo phương pháp **Ponytail** (tối giản, tận dụng tối đa tính năng gốc của platform, loại bỏ mã thừa over-engineering) kết hợp quy chuẩn **1C Dev Mentor Student References** (`code-patterns.md`, `chinh-sach-code.md`, `review-code.md`, `giao-thuc-debug.md`).

**Architecture:** Sử dụng kiến trúc hướng đối tượng của nền tảng 1C:Enterprise 8.3 Taxi. Khai thác triệt để các thuộc tính metadata khai báo (declarative metadata) như `Ref` (UUID PK), `FillChecking = ShowError`, `CheckUnique = true`, `Autonumbering = true`, `NonNegative = true`, `ChoiceParameterLinks` thay vì tự viết code BSL kiểm tra thủ công. Gỡ bỏ rào cản chặn quyền Admin tại tầng gốc (`PhanQuyenBaoMatServer`), bảo toàn luồng Maker-Checker độc lập cho các role vận hành, và tổ chức dữ liệu kế toán chuẩn TT200.

**Tech Stack:** 1C:Enterprise 8.3 (Platform 8.3.22.1704 / Compatibility Mode 8.3.22), BSL (1C Enterprise Script), XML Metadata 2.15, Managed Forms (Taxi UI), 1C Dev Mentor Standards, Ponytail Principle (Lite/Full/Ultra YAGNI).

**Spec & References:**
- `docs/superpowers/specs/2026-10-18-modern-web-erp-ui-spec.md`
- `1c-dev-mentor-student/references/code-patterns.md` (Quy chuẩn code 1C tối thiểu)
- `1c-dev-mentor-student/references/chinh-sach-code.md` (Chính sách hỗ trợ & phân loại code)
- `1c-dev-mentor-student/references/code-review/review-code.md` (Quy tắc review code chuẩn 1C)
- `1c-dev-mentor-student/references/debug/giao-thuc-debug.md` (Giao thức gỡ lỗi root-cause)
- `1c-dev-mentor-student/references/mis/tu-xay-dung-he-thong.md` (Mô hình hóa hệ thống từ cấu hình rỗng)
- `1c-dev-mentor-student/references/terminology.md` (Thuật ngữ chuẩn 1C:Enterprise)

---

## Global Constraints

- **Ponytail Ladder First**: Ưu tiên tính năng có sẵn của platform 1C trước khi viết mã BSL. Không viết code BSL cho những gì Metadata `FillChecking`, `CheckUnique`, `Autonumbering`, `NonNegative`, `ChoiceParameterLinks` đã giải quyết xong.
- **Admin Toàn quyền**: Tài khoản Admin / Role QuanTriHeThong phải có toàn quyền xem, thêm, sửa, xóa, ghi sổ, hủy ghi sổ trên toàn bộ hệ thống; không bị chặn bởi bất kỳ điều kiện logic hay RLS nào.
- **Bảo toàn phân quyền vận hành**: Các Role nghiệp vụ (`KeToanPhaiThu`, `KeToanPhaiTra`, `KeToanTruong`, `GiamDocTaiChinh_CFO`) vẫn tuân thủ nghiêm ngặt ma trận Maker-Checker và phân định nhiệm vụ (SoD).
- **Zero Syntax & Metadata Error**: 100% mã nguồn BSL đạt chuẩn cú pháp; lệnh 1C Designer `/CheckConfig` đạt kết quả `No errors found`.
- **Bảo toàn dữ liệu nghiệp vụ & TT200**: Hệ thống 243 tài khoản kế toán, các chứng từ AR/AP và sổ thanh ghi không bị mất tính toàn vẹn khi cấu hình.

---

## Review Focus

- **RF-01 (Admin Bypass)**: Admin ghi sổ hoặc hủy ghi sổ chứng từ có bị vướng exception chặn "Tài khoản quản trị không được phép ghi sổ" hay không? -> Kỳ vọng: Admin thực hiện thành công 100% mọi thao tác.
- **RF-02 (Maker-Checker Invariant)**: User vận hành thường (`ketoan_ar`, `ketoan_ap`) có bị lọt quyền tự phê duyệt chứng từ do chính mình tạo không? -> Kỳ vọng: Bị chặn chính xác, tuân thủ SoD.
- **RF-03 (Declarative FillChecking)**: Các trường bắt buộc (`DoiTac`, `HopDong`, `TongTienThanhToan`) khi để trống có hiển thị thông báo lỗi trường đỏ chuẩn của 1C Taxi không? -> Kỳ vọng: `FillChecking = ShowError` kích hoạt báo lỗi rõ ràng.
- **RF-04 (Referential Filter Links)**: Khi chọn Hợp đồng trên chứng từ, danh sách chọn có tự động lọc theo đúng `DoiTac` của chứng từ không? -> Kỳ vọng: `ChoiceParameterLinks` lọc chính xác, không cho chọn sai đối tác.
- **RF-05 (Read-Only Guard)**: Chứng từ sau khi đã ghi sổ (`Posted = true`) có bị sửa tùy tiện các trường số tiền / tài khoản trên giao diện không? -> Kỳ vọng: Form tự động khóa chỉ đọc các trường trọng yếu.

---

## Kế Hoạch Triển Khai (Task Breakdown)

### Task 1: Gỡ Bỏ Rào Cản Quyền Admin & Chuẩn Hóa Role QuanTriHeThong (Ponytail Root-Cause)

**Mục tiêu:** Cung cấp toàn quyền tuyệt đối cho Admin trên toàn bộ hệ thống (đọc, ghi, sửa, xóa, duyệt, ghi sổ, xem báo cáo) bằng cách gỡ bỏ các đoạn mã chặn cứng trong BSL theo phương pháp Ponytail (sửa đúng tận gốc, xóa bỏ logic thừa thay vì bọc thêm lớp code mới).

**Files:**
- Sửa: `src/CommonModules/PhanQuyenBaoMatServer/Ext/Module.bsl`
- Sửa: `src/Roles/QuanTriHeThong/Ext/Rights.xml`
- Test: `scripts/test_admin_full_access.py`

**Các bước thực hiện:**
- [ ] **Bước 1.1**: Viết test kiểm tra quyền Admin: xác nhận Admin có thể lưu, ghi sổ, hủy ghi sổ chứng từ bất kỳ mà không bị ném exception.
- [ ] **Bước 1.2**: Trong `PhanQuyenBaoMatServer.bsl`, tại hàm `KiemTraQuyenChungTu`:
  - Ponytail fix: Xóa bỏ khối mã `Raise "Tài khoản quản trị hệ thống không được phép ghi sổ hoặc hủy ghi sổ chứng từ tài chính!"`.
  - Thay bằng: Nếu là Admin hoặc có role `QuanTriHeThong` thì `Return;` (cho phép toàn quyền thực thi ngay lập tức, không qua bất kỳ rào cản SoD nào).
- [ ] **Bước 1.3**: Trong `PhanQuyenBaoMatServer.bsl`, tại hàm `KiemTraMakerChecker`:
  - Cho phép tài khoản Admin thực hiện phê duyệt trong môi trường quản trị / test dữ liệu mà không bị chặn cưỡng bức.
- [ ] **Bước 1.4**: Trong `PhanQuyenBaoMatServer.bsl`, tại hàm `KiemTraQuyenBaoCaoTaiChinh`:
  - Đảm bảo Admin và `QuanTriHeThong` có toàn quyền xem mọi báo cáo tài chính cao cấp.
- [ ] **Bước 1.5**: Trong `src/Roles/QuanTriHeThong/Ext/Rights.xml`:
  - Đảm bảo `setForNewObjects = true`, `setForAttributesByDefault = true` và cấp quyền hệ thống `Administration`, `DataAdministration`.
- [ ] **Bước 1.6**: Chạy test kiểm tra quyền Admin và đảm bảo các user thường (`ketoan_ar`, `ketoan_ap`) vẫn bị kiểm soát Maker-Checker chặt chẽ.
- [ ] **Bước 1.7**: Commit git: `fix(security): grant full unrestricted access to Admin and QuanTriHeThong role`.

---

### Task 2: Rà Soát Metadata Data Model, Primary Key & Foreign Key (Kiến Trúc 1C Chuẩn)

**Mục tiêu:** Rà soát toàn bộ Catalogs, Documents, Tabular Sections, Registers theo chuẩn kiến trúc 1C Dev Mentor (`terminology.md`, `mis/tu-xay-dung-he-thong.md`). Đảm bảo mọi đối tượng dùng khóa chính ngầm định `Ref`, mã/số tự sinh duy nhất, quan hệ 1-N qua TabularSection, và khóa ngoại kiểu Reference chuẩn.

**Files:**
- Rà soát & sửa: `src/Catalogs/*.xml`
- Rà soát & sửa: `src/Documents/*.xml`
- Rà soát & sửa: `src/AccumulationRegisters/*.xml`
- Rà soát & sửa: `src/InformationRegisters/*.xml`
- Test: `scripts/test_data_model_integrity.py`

**Các bước thực hiện:**
- [ ] **Bước 2.1**: Viết script kiểm tra tính toàn vẹn mô hình dữ liệu 1C:
  - Kiểm tra 100% Catalogs có `Autonumbering = true`, `CheckUnique = true`.
  - Kiểm tra 100% Documents có `Autonumbering = true`, `CheckUnique = true`, `NumberPeriodicity` hợp lý.
  - Kiểm tra 100% Registers có đầy đủ `Dimensions` và `Resources`.
- [ ] **Bước 2.2 (Primary Keys)**:
  - Khẳng định chuẩn 1C: Toàn bộ bảng thực thể dùng `Ref` (UUID 128-bit) làm khóa chính bất biến.
  - Tuyệt đối không tạo thêm thuộc tính ID tự chế (tránh trùng lặp với `Ref`).
  - Chuẩn hóa độ dài mã `Code` của Catalog (`Length = 9` hoặc `15`) và số `Number` của Document (`Length = 11` đến `20`).
- [ ] **Bước 2.3 (Foreign Keys & Relations)**:
  - Thay thế mọi trường dạng Text lưu tên đối tác/hợp đồng bằng đúng kiểu tham chiếu `CatalogRef.DoiTac`, `CatalogRef.HopDong`, `CatalogRef.PhapNhan`, `CatalogRef.TaiKhoanTien`.
  - Kiểm tra quan hệ 1-N: Chi tiết hóa đơn hàng hóa/dịch vụ dùng `TabularSection` nội tại của Document (như `ChiTietDichVu` trong `HoaDonGTGTDauRa`), không tạo bảng phụ riêng lẻ bên ngoài.
- [ ] **Bước 2.4 (Registers)**:
  - Rà soát `AccumulationRegister.CongNoPhaiThu` & `CongNoPhaiTra`: Khóa logic là bộ `Dimensions` (`PhapNhan`, `DoiTac`, `HopDong`, `ChungTuGoc`). `Resources` là `SoTien`, `SoTienNgoaiTe`.
  - Rà soát `AccumulationRegister.DongTien`: `Dimensions` (`PhapNhan`, `TaiKhoanTien`, `KhoanMucDongTien`).
  - Rà soát `InformationRegister.TyGiaHoiDoai`: Tính chu kỳ `Periodicity = Day`, Dimensions `TienTe`, Resources `TyGia`.
- [ ] **Bước 2.5**: Chạy script kiểm tra và xác nhận 100% đạt chuẩn.
- [ ] **Bước 2.6**: Commit git: `refactor(metadata): standardize data model, primary keys, and foreign key references`.

---

### Task 3: Cấu Hình Ràng Buộc Bắt Buộc Declarative (Ponytail: FillChecking vs Custom Code)

**Mục tiêu:** Áp dụng nguyên tắc Ponytail: Thay vì viết hàng chục dòng code `If IsBlankString(Field) Then Raise ...` trong module, kích hoạt trực tiếp thuộc tính nền tảng `FillChecking = ShowError` trên Metadata để 1C tự động kiểm tra và đánh dấu viền đỏ trên giao diện Taxi.

**Files:**
- Sửa metadata: `src/Documents/HoaDonGTGTDauRa.xml`
- Sửa metadata: `src/Documents/HoaDonNhaCungCap.xml`
- Sửa metadata: `src/Documents/PhieuThuTienKhachHang.xml`
- Sửa metadata: `src/Documents/UyNhiemChi.xml`
- Sửa metadata: `src/Documents/BienBanNghiemThuGiaiDoan.xml`
- Sửa metadata: `src/Catalogs/DoiTac.xml`, `HopDong.xml`, `PhapNhan.xml`
- Test: `scripts/test_fill_checking_metadata.py`

**Các bước thực hiện:**
- [ ] **Bước 3.1**: Viết test quét thuộc tính metadata: liệt kê các trường bắt buộc nghiệp vụ và kiểm tra cờ `FillChecking = ShowError`.
- [ ] **Bước 3.2**: Thiết lập `FillChecking = ShowError` trên Metadata cho các trường cốt lõi:
  - Document Header: `PhapNhan`, `DoiTac`, `HopDong`, `Date`, `Number`.
  - Hóa đơn VAT: `NgayHoaDon`, `KyHieu`, `SoHoaDon`, `TongTienThanhToan`.
  - Phiếu thu / Ủy nhiệm chi: `TaiKhoanTien`, `KhoanMucDongTien`, `SoTien`, `TienTe`.
  - Catalogs: `Description` (Tên), `MaSoThue` (Mã số thuế của Đối tác).
- [ ] **Bước 3.3**: Với các trường thực sự tùy chọn (`DienGiai`, `GhiChu`, `MaCQT`), đảm bảo đặt `FillChecking = DontCheck` để không gây phiền nhiễu cho người dùng.
- [ ] **Bước 3.4**: Cấu hình kiểm tra số không âm: Thiết lập `NonNegative = true` trên định nghĩa kiểu `NumberQualifiers` cho toàn bộ các trường `SoTien`, `TongTien`, `TyGia`, `DonGia`, `SoLuong`.
- [ ] **Bước 3.5**: Chạy test kiểm tra `FillChecking` và xác nhận không còn trường bắt buộc nào thiếu cờ metadata.
- [ ] **Bước 3.6**: Commit git: `feat(metadata): enforce declarative FillChecking and NonNegative constraints`.

---

### Task 4: Chuẩn Hóa Tự Động Điền Dữ Liệu Qua Vòng Đời BSL (Filling & BeforeWrite)

**Mục tiêu:** Cấu hình cơ chế tự động điền giá trị mặc định cho chứng từ và danh mục bằng đúng các handler chuẩn của 1C (`Filling` khi tạo mới/kế thừa, `BeforeWrite` khi tính toán tổng hợp), giảm thiểu tối đa thao tác nhập tay của người dùng theo `code-patterns.md`.

**Files:**
- Sửa: `src/Documents/HoaDonGTGTDauRa/Ext/ObjectModule.bsl`
- Sửa: `src/Documents/HoaDonNhaCungCap/Ext/ObjectModule.bsl`
- Sửa: `src/Documents/PhieuThuTienKhachHang/Ext/ObjectModule.bsl`
- Sửa: `src/Documents/UyNhiemChi/Ext/ObjectModule.bsl`
- Sửa: `src/Documents/BienBanNghiemThuGiaiDoan/Ext/ObjectModule.bsl`
- Test: `scripts/test_autofill_lifecycle.py`

**Các bước thực hiện:**
- [ ] **Bước 4.1**: Viết test kiểm tra tự động điền: khởi tạo đối tượng Document mới qua BSL và kiểm tra các trường mặc định được điền tự động.
- [ ] **Bước 4.2**: Trong sự kiện `Filling(FillingData, FillingText, StandardProcessing)` của cả 5 Document ObjectModule:
  - Tự động điền ngày chứng từ: `Date = CurrentSessionDate()`.
  - Tự động điền người lập: `NguoiLap = UserName()`.
  - Tự động điền pháp nhân: `PhapNhan = Constants.PhapNhanMacDinh.Get()`.
  - Tự động điền tiền tệ: `TienTe = Catalogs.TienTe.FindByCode("VND")` (nếu chưa có).
  - Tự động điền tỷ giá: Nếu tiền tệ là ngoại tệ, gọi `InformationRegisters.TyGiaHoiDoai.GetLast(Date, New Structure("TienTe", TienTe)).TyGia`.
- [ ] **Bước 4.3**: Xử lý kế thừa dữ liệu (`BasedOn` trong `FillingData`):
  - Khi tạo `PhieuThuTienKhachHang` từ `HoaDonGTGTDauRa`: Tự động lấy `PhapNhan`, `DoiTac`, `HopDong`, `SoTien = TongTienThanhToan`.
  - Khi tạo `UyNhiemChi` từ `HoaDonNhaCungCap`: Tự động lấy `PhapNhan`, `DoiTac`, `HopDong`, `SoTien = TongTien`.
- [ ] **Bước 4.4**: Trong sự kiện `BeforeWrite` của Document ObjectModule:
  - Tự động tính toán lại các trường tài chính: `TongTienThanhToan = TienChuaThue + TienThueVAT`.
  - Tự động cập nhật `NguoiLap` nếu còn trống.
- [ ] **Bước 4.5**: Chạy test kiểm tra tự động điền và xác nhận toàn bộ trường mặc định hoạt động trơn tru.
- [ ] **Bước 4.6**: Commit git: `feat(bsl): implement native Filling and BeforeWrite auto-population handlers`.

---

### Task 5: Rà Soát Phân Định Enum vs Catalog & Cấu Hình ChoiceParameterLinks

**Mục tiêu:** Phân tách rạch ròi giữa giá trị cố định (`Enum`) và danh mục quản trị động (`Catalog`). Áp dụng tính năng platform `ChoiceParameterLinks` để tự động lọc dropdown danh mục phụ thuộc (ví dụ Hợp đồng lọc theo Đối tác) mà không cần viết mã sự kiện form.

**Files:**
- Sửa metadata: `src/Documents/HoaDonGTGTDauRa.xml`
- Sửa metadata: `src/Documents/HoaDonNhaCungCap.xml`
- Sửa metadata: `src/Documents/PhieuThuTienKhachHang.xml`
- Sửa metadata: `src/Documents/UyNhiemChi.xml`
- Test: `scripts/test_choice_parameter_links.py`

**Các bước thực hiện:**
- [ ] **Bước 5.1**: Rà soát danh sách lựa chọn:
  - Cố định logic $\rightarrow$ Đảm bảo dùng Enum: `TrangThaiHoaDonAP`, `TrangThaiLenhThanhToan`, `TrangThaiNghiemThuAR`, `TrangThaiHoaDonDienTu`, `LoaiDoiTac`, `HuongDongTien`.
  - Quản trị động $\rightarrow$ Dùng Catalog: `DoiTac`, `HopDong`, `TaiKhoanTien`, `KhoanMucDongTien`.
- [ ] **Bước 5.2 (Ponytail Declarative)**: Cấu hình `ChoiceParameterLinks` cho thuộc tính `HopDong` trên tất cả 5 Document:
  - Liên kết: `Filter.Owner(DoiTac)` hoặc `Filter.DoiTac(DoiTac)`.
  - Kết quả: Khi người dùng bấm chọn Hợp đồng, 1C tự động lọc chỉ hiển thị các hợp đồng của Đối tác đang chọn trên chứng từ.
- [ ] **Bước 5.3**: Cấu hình `ChoiceParameterLinks` cho thuộc tính `TaiKhoanTien`:
  - Liên kết: `Filter.Owner(PhapNhan)` hoặc `Filter.PhapNhan(PhapNhan)`.
- [ ] **Bước 5.4**: Kích hoạt `QuickChoice = true` trên các Catalog danh mục ngắn/cố định để người dùng có thể chọn nhanh từ combobox.
- [ ] **Bước 5.5**: Chạy test xác nhận cấu hình `ChoiceParameterLinks` hợp lệ và vượt qua CheckConfig.
- [ ] **Bước 5.6**: Commit git: `feat(metadata): configure ChoiceParameterLinks for dynamic dependent selection`.

---

### Task 6: Cấu Hình Thuộc Tính Chỉ Đọc & Bảo Vệ Chứng Từ Đã Ghi Sổ (ReadOnly Guard)

**Mục tiêu:** Khóa các trường kỹ thuật và trường tính toán không cho người dùng sửa tùy tiện, đồng thời tự động bảo vệ chứng từ đã ghi sổ (`Posted = true`) trên Form theo chuẩn an toàn kế toán.

**Files:**
- Sửa Form Modules: `src/Documents/*/Forms/FormChungTu/Ext/Form/Module.bsl`
- Sửa Form XML: `src/Documents/*/Forms/FormChungTu/Ext/Form.xml`
- Test: `scripts/test_readonly_controls.py`

**Các bước thực hiện:**
- [ ] **Bước 6.1**: Rà soát thuộc tính chỉ đọc trên Form:
  - Khóa `ReadOnly = true` trên giao diện cho các trường: `Number` (Số tự sinh), `TongTienThanhToan` (Tổng tiền tự tính), `TienThueVAT` (Tiền thuế VAT tự tính), `TrangThai` (Trạng thái quy trình), `NguoiLap`, `NguoiDuyet`.
- [ ] **Bước 6.2**: Tại sự kiện `OnCreateAtServer` và `OnReadAtServer` của các Form chứng từ:
  - Bổ sung logic khóa form khi đã ghi sổ: Nếu `Object.Posted = True` thì đặt `ReadOnly = True` cho form hoặc vô hiệu hóa các bảng chỉnh sửa hàng hóa, chỉ giữ lại nút *Hủy ghi sổ* / *In ấn* / *Chứng từ liên quan*.
- [ ] **Bước 6.3**: Kiểm tra không còn trường hệ thống nào bị phơi bày cho phép sửa tay.
- [ ] **Bước 6.4**: Commit git: `feat(ui): enforce ReadOnly controls and posted document protection`.

---

### Task 7: Rà Soát UI/UX Form Taxi Chuẩn Mực & Đánh Chỉ Mục Truy Vấn (Indexing)

**Mục tiêu:** Hoàn thiện giao diện Form Taxi hiển thị chuyên nghiệp (Header Bar Badge, Tabulation, Stepper Maker-Checker) và đặt cờ `Indexing = Index` cho các trường thường xuyên lọc tìm kiếm để tối ưu tốc độ CSDL.

**Files:**
- Sửa metadata XML: `src/Documents/*.xml`
- Sửa metadata XML: `src/Catalogs/*.xml`
- Sửa Form Modules: `src/Documents/*/Forms/FormChungTu/Ext/Form/Module.bsl`
- Test: `scripts/test_indexing_and_ui.py`

**Các bước thực hiện:**
- [ ] **Bước 7.1 (Tối ưu hóa Indexing)**:
  - Đặt `Indexing = Index` cho các trường thường xuyên làm điều kiện truy vấn trong Sổ cái và Dashboard:
    - Trong `HoaDonGTGTDauRa`: `DoiTac`, `NgayHoaDon`, `TrangThaiHDDT`.
    - Trong `HoaDonNhaCungCap`: `DoiTac`, `NgayHoaDon`, `TrangThai`.
    - Trong `UyNhiemChi`: `DoiTac`, `NgayGhiSo`, `TrangThai`.
    - Trong `PhieuThuTienKhachHang`: `DoiTac`, `NgayThu`.
    - Trong `Catalogs.DoiTac`: `MaSoThue` (`Indexing = Index`).
- [ ] **Bước 7.2 (Giao diện Taxi chuẩn)**:
  - Rà soát các control hiển thị: DatePicker cho ngày, Numeric input căn phải cho số tiền, DropList cho Enum, Checkbox cho Boolean, Multiline cho Diễn giải.
  - Đảm bảo huy hiệu trạng thái động (`TrangThaiBadge`) hiển thị màu sắc thương hiệu VinSmart rõ ràng (`#EA0B2A`, `#10B981`, `#F59E0B`).
- [ ] **Bước 7.3**: Chạy test kiểm tra metadata và form layout.
- [ ] **Bước 7.4**: Commit git: `perf(metadata): add database indexes and polish Taxi form controls`.

---

### Task 8: Lập Bảng Rà Soát Toàn Diện Mọi Đối Tượng Metadata (1C Entity Specification Matrix)

**Mục tiêu:** Xuất bản tài liệu ma trận cấu hình CSDL 1C chi tiết cho từng Catalog, Document, TabularSection và Register theo đúng 14 cột tiêu chuẩn được yêu cầu tại Mục 12 của prompt người dùng, nêu rõ cấu hình hiện tại, vấn đề, đề xuất chuẩn 1C và lý do nghiệp vụ.

**Files:**
- Tạo tài liệu báo cáo: `docs/superpowers/reports/2026-10-18-1c-data-model-audit-matrix.md`
- Script hỗ trợ tự động trích xuất: `scripts/generate_1c_metadata_matrix.py`

**Các bước thực hiện:**
- [ ] **Bước 8.1**: Viết script `generate_1c_metadata_matrix.py` tự động đọc toàn bộ metadata XML của dự án (`src/Catalogs`, `src/Documents`, `src/AccumulationRegisters`, `src/InformationRegisters`, `src/AccountingRegisters`).
- [ ] **Bước 8.2**: Trích xuất dữ liệu và lập bảng ma trận 14 cột đầy đủ:
  - `Đối tượng (Metadata Object)` | `Thuộc tính (Attribute)` | `Kiểu dữ liệu 1C (TypeDescription)` | `Khóa / Nhận diện (Ref / Code / Dim)` | `Tham chiếu đến (Reference To)` | `Bắt buộc điền (FillChecking)` | `Tự động điền (Auto Fill / Sự kiện)` | `Giá trị ngầm định (Default)` | `Dạng Control hiển thị (Taxi)` | `Kiểm tra duy nhất (Unique)` | `Chỉ đọc (ReadOnly)` | `Quy tắc hợp lệ (Validation BSL)` | `Đánh chỉ mục (Indexing)` | `Ghi chú nghiệp vụ`.
- [ ] **Bước 8.3**: Soạn thảo phần phân tích đánh giá:
  - Nêu rõ các điểm cấu hình chưa chuẩn trước đó (mojibake, thiếu FillChecking, thiếu Indexing, Admin bị chặn SoD).
  - Trình bày cấu hình đề xuất đã được áp dụng và lý do kỹ thuật nền tảng 1C.
- [ ] **Bước 8.4**: Xuất bản báo cáo hoàn chỉnh vào `docs/superpowers/reports/2026-10-18-1c-data-model-audit-matrix.md`.
- [ ] **Bước 8.5**: Commit git: `docs(audit): generate complete 1C metadata and data model audit matrix`.

---

### Task 9: Kiểm Thử Toàn Diện & Xuất Bản Gói CSDL .DT Mới Nhất

**Mục tiêu:** Chạy toàn bộ quy trình kiểm thử đơn vị, kiểm tra cú pháp BSL, chạy 1C Designer CheckConfig (đạt 0 lỗi), đóng gói và xác minh tệp CSDL `.dt` xuất xưởng hoàn chỉnh.

**Files:**
- Script kiểm tra: `scripts/verify_bsl_syntax.py`
- Script kiểm tra: `scripts/verify_check_config.ps1`
- Script đóng gói: `scripts/build_web_ui_dt.py`
- Script kiểm tra DT: `scripts/verify_dt_accounts.py`
- Tệp đích: `VinSmart_Future_Modern_Web_UI.dt`

**Các bước thực hiện:**
- [ ] **Bước 9.1**: Chạy toàn bộ test suite đơn vị Python: `python -B -m unittest discover scripts "test_*.py"`. Yêu cầu 100% test pass.
- [ ] **Bước 9.2**: Chạy kiểm tra cú pháp BSL: `python -B scripts/verify_bsl_syntax.py`. Yêu cầu 0 lỗi cân bằng cú pháp.
- [ ] **Bước 9.3**: Chạy 1C Designer CheckConfig chính thức: `powershell -ExecutionPolicy Bypass -File scripts/verify_check_config.ps1`. Yêu cầu trả về `1C_CHECKCONFIG_PASS_ZERO_ERROR`.
- [ ] **Bước 9.4**: Xóa file `.dt` cũ và chạy `python -B scripts/build_web_ui_dt.py` để tạo lại tệp `VinSmart_Future_Modern_Web_UI.dt` mới nhất chứa đầy đủ cấu hình chuẩn và Master Data + Transaction Data.
- [ ] **Bước 9.5**: Chạy `python -B scripts/verify_dt_accounts.py` để xác minh khôi phục và toàn vẹn dữ liệu từ `.dt`.
- [ ] **Bước 9.6**: Commit git cuối cùng: `release: final verified VinSmart Future 1C Modern Web UI package`.
