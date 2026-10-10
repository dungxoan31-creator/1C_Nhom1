# Task 1.1 Brief: Khởi tạo 10 Danh mục (Catalogs) & Thiết Lập RLS Phân Quyền Pháp Nhân

## 1. Mục tiêu
Định nghĩa 10 Catalogs nền tảng cho phân hệ Quản lý Công nợ AR/AP của VinSmart Future trên nền tảng 1C:Enterprise 8.3 (CompatibilityMode Version8_3_22). Thiết lập cấu trúc dữ liệu, ràng buộc giá trị mặc định Net 30 trên `Catalog.HopDong`, trường bắt buộc `PhapNhan` cho RLS, và Unique Index cho `Catalog.TaiKhoanAo`.

## 2. File tác động
- `tests/unit/CatalogsCoreTest.bsl` (New)
- `src/Catalogs/PhapNhan.xml` (New)
- `src/Catalogs/DoiTac.xml` (New)
- `src/Catalogs/HopDong.xml` (New)
- `src/Catalogs/HopDong/Ext/ObjectModule.bsl` (New)
- `src/Catalogs/TaiKhoanTien.xml` (New)
- `src/Catalogs/KhoanMucDongTien.xml` (New)
- `src/Catalogs/TienTe.xml` (New)
- `src/Catalogs/DuAn.xml` (New)
- `src/Catalogs/DichVuCNTT.xml` (New)
- `src/Catalogs/KenhThanhToan.xml` (New)
- `src/Catalogs/TaiKhoanAo.xml` (New)
- `src/Catalogs/TaiKhoanAo/Ext/ObjectModule.bsl` (New)

## 3. Yêu cầu Chi tiết Kỹ thuật
1. **Catalog.PhapNhan:**
   - Mã, Tên.
   - Thuộc tính: `MaSoThue` (String 14), `DiaChi` (String 200).
2. **Catalog.DoiTac:** (Danh mục dùng chung - Shared cấp Tập đoàn)
   - Mã, Tên.
   - Thuộc tính: `LaBenLienKet` (Boolean), `DaDangKyThueTrucTiep` (Boolean), `LoaiDoiTac` (EnumRef.LoaiDoiTac).
3. **Catalog.HopDong:**
   - Thuộc tính bắt buộc phục vụ RLS: `PhapNhan` (CatalogRef.PhapNhan).
   - Thuộc tính: `ChuSoHuu` (CatalogRef.DoiTac), `GrossUpThue` (Boolean), `HanThanhToanNgay` (Number 3, default 30), `DongTienThanhToan` (CatalogRef.TienTe).
   - Logic `BeforeWrite`: nếu `HanThanhToanNgay <= 0` thì tự gán `= 30`.
4. **Catalog.TaiKhoanAo:**
   - Thuộc tính: `SoTaiKhoanAo` (String 30 - Unique Index), `DoiTac` (CatalogRef.DoiTac), `NganHang` (CatalogRef.TaiKhoanTien).
   - Logic `BeforeWrite`: Bắt trùng lặp mã `SoTaiKhoanAo`. Nếu trùng, ném lỗi: `"Số tài khoản ảo đã được cấp phát cho đối tác khác!"`.
5. **6 Catalogs còn lại:**
   - `Catalog.TaiKhoanTien`: `SoTaiKhoan` (String 30), `NganHang` (String 100), `TienTe` (CatalogRef.TienTe).
   - `Catalog.KhoanMucDongTien`: `LoaiDongTien` (String 50).
   - `Catalog.TienTe`: `MaTienTe` (String 3 - ISO 4217, e.g. VND, USD), `TenDayDu` (String 50).
   - `Catalog.DuAn`: `MaDuAn` (String 50), `TenDuAn` (String 150), `PhapNhan` (CatalogRef.PhapNhan).
   - `Catalog.DichVuCNTT`: `MaDichVu` (String 50), `TenDichVu` (String 150), `TyLeVATMacDinh` (Number 2).
   - `Catalog.KenhThanhToan`: `MaKenh` (String 50 - VNPAY, VINCLUB, MOMO), `TenKenh` (String 100).

## 4. Test Case `tests/unit/CatalogsCoreTest.bsl`
Viết test theo mô hình BUnit / Vanessa:
- Test 1: Khởi tạo bản ghi trên 10 Catalogs.
- Test 2: `HopDong` tự động gán `HanThanhToanNgay = 30` khi không truyền hoặc truyền $\le 0$.
- Test 3: `TaiKhoanAo` ném lỗi khi cố tạo 2 bản ghi trùng `SoTaiKhoanAo`.
- Test 4: Giả lập Session Parameter `CurrentPhapNhan`: User VSF Corp không nhìn thấy HopDong của VSF Software khi truy vấn bảng `Catalog.HopDong` với điều kiện RLS `#PhapNhanAccess(PhapNhan)`.

## 5. Báo cáo kết quả
Implementer lưu báo cáo tại: `.superpowers/sdd/2026-10-10-vinsmart-future-ar-ap/task-1.1-report.md`.
Contract trả về: Status (DONE / DONE_WITH_CONCERNS / BLOCKED), danh sách commit hoặc file đã tạo, tóm tắt kết quả test.
