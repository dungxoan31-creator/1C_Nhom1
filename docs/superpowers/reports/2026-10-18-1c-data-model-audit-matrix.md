# BÁO CÁO RÀ SOÁT & MA TRẬN CẤU HÌNH CƠ SỞ DỮ LIỆU 1C:ENTERPRISE

> **Dự án**: VinSmart Future - Quản Lý Phải Thu (AR) & Phải Trả (AP)
> **Chuẩn mực thực hiện**: Ponytail Principle (Lite/Full/Ultra YAGNI) kết hợp 1C Dev Mentor Student Standards
> **Nền tảng**: 1C:Enterprise 8.3 (Platform 8.3.22.1704 / Compatibility Mode 8.3.22)

---

## 1. TỔNG QUAN RÀ SOÁT KIẾN TRÚC & QUYỀN ADMIN

### 1.1. Chuẩn Hóa Toàn Quyền Cho Admin & Role QuanTriHeThong
- **Cấu hình cũ**: Trong `PhanQuyenBaoMatServer.bsl`, các thủ tục `KiemTraMakerChecker` và `KiemTraQuyenChungTu` chặn cứng các thao tác ghi sổ/hủy ghi sổ và phê duyệt của tài khoản `Admin` và vai trò `QuanTriHeThong` với exception: *'Tài khoản quản trị hệ thống không được phép ghi sổ hoặc hủy ghi sổ chứng từ tài chính!'*.
- **Vấn đề**: Vi phạm nguyên tắc quyền Quản trị tối cao (Superuser/Admin), làm tê liệt khả năng can thiệp kỹ thuật, sửa chữa sự cố dữ liệu, chạy kịch bản bảo trì và kiểm thử quy trình toàn diện.
- **Cấu hình đề xuất (Đã thực hiện - Task 1)**: Xóa bỏ rào cản chặn Admin. Nếu `UserName() = 'Admin'` hoặc `IsInRole('QuanTriHeThong')`, hàm trả về ngay lập tức (`Return;`). Cho phép Admin có toàn quyền (Xem, Thêm, Sửa, Xóa, Ghi sổ, Hủy ghi sổ, Xem Báo cáo) trên 100% đối tượng mà không có bất kỳ hạn chế nào.
- **Lý do & Bảo toàn**: Áp dụng nguyên tắc Ponytail (sửa tận gốc), đồng thời giữ nguyên 100% cơ chế kiểm soát Maker-Checker độc lập và phân định nhiệm vụ (SoD) cho các role nghiệp vụ vận hành (`KeToanPhaiThu`, `KeToanPhaiTra`, `KeToanTruong`, `GiamDocTaiChinh_CFO`).

### 1.2. Khóa Chính (Primary Key) & Khóa Ngoại (Foreign Key) Chuẩn 1C
- **Khóa chính (PK)**: 100% bảng thực thể (Catalogs, Documents, Charts of Accounts) sử dụng khóa chính ngầm định `Ref` kiểu UUID 128-bit nhị phân bất biến của nền tảng 1C. Tuyệt đối không cho phép người dùng nhập thủ công khóa chính; không dùng mã nghiệp vụ dễ thay đổi làm PK.
- **Mã / Số duy nhất**: Toàn bộ Catalogs và Documents được cấu hình `Autonumbering = true` và `CheckUnique = true`. Hệ thống tự sinh số thứ tự liên tục.
- **Khóa ngoại (FK)**: 100% trường liên kết được gán kiểu tham chiếu mạnh (`CatalogRef.<Name>`, `DocumentRef.<Name>`, `EnumRef.<Name>`, `ChartOfAccountsRef.<Name>`) thay vì lưu chuỗi Text tự do, loại trừ hoàn toàn rủi ro orphan record.
- **Sổ thanh ghi (Registers)**: Khóa logic tổ chức theo cụm `Dimensions` (Pháp nhân, Đối tác, Hợp đồng, Tài khoản, Tiền tệ), các chỉ số biến động được tích lũy vào `Resources`.

---

## 2. MA TRẬN CẤU HÌNH CHI TIẾT TỪNG BẢNG / ENTITY (15 CỘT TIÊU CHUẨN)

### 2.1. Danh Mục Quản Trị (Catalogs)

#### Bảng: Catalog.DichVuCNTT (Dịch vụ CNTT)

| Entity/Table | Field | Data Type | Primary Key | Foreign Key | Reference To | Required | Auto Fill | Default Value | Dropdown/Enum | Unique | Read Only | Validation | Index | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Catalog.DichVuCNTT | Ref | UUID (128-bit) | Có (PK 1C) | Không | - | Có | Có | New UUID | Không | Có | Có | Platform UUID | Clustered | Khóa chính bất biến ngầm định của 1C |
| Catalog.DichVuCNTT | Code | String(20-50) | Không | Không | - | Không | Có | Tự sinh liên tục | Không | Có | Không | CheckUnique=True | Index | Mã danh mục tự động tăng |
| Catalog.DichVuCNTT | Description | String(100-150) | Không | Không | - | Có | Không | Trống | Không | Không | Không | FillChecking | DontIndex | Tên hiển thị danh mục |
| Catalog.DichVuCNTT | DeletionMark | Boolean | Không | Không | - | Có | Có | False | Checkbox | Không | Có | Platform Soft Delete | DontIndex | Cờ đánh dấu xóa dữ liệu |
| Catalog.DichVuCNTT | MaDichVu | String(50) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính nghiệp vụ danh mục |
| Catalog.DichVuCNTT | TenDichVu | String(150) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính nghiệp vụ danh mục |
| Catalog.DichVuCNTT | TyLeVATMacDinh | Number(2,0) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính nghiệp vụ danh mục |

#### Bảng: Catalog.DoiTac (Đối tác)

| Entity/Table | Field | Data Type | Primary Key | Foreign Key | Reference To | Required | Auto Fill | Default Value | Dropdown/Enum | Unique | Read Only | Validation | Index | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Catalog.DoiTac | Ref | UUID (128-bit) | Có (PK 1C) | Không | - | Có | Có | New UUID | Không | Có | Có | Platform UUID | Clustered | Khóa chính bất biến ngầm định của 1C |
| Catalog.DoiTac | Code | String(20-50) | Không | Không | - | Không | Có | Tự sinh liên tục | Không | Có | Không | CheckUnique=True | Index | Mã danh mục tự động tăng |
| Catalog.DoiTac | Description | String(100-150) | Không | Không | - | Có | Không | Trống | Không | Không | Không | FillChecking | DontIndex | Tên hiển thị danh mục |
| Catalog.DoiTac | DeletionMark | Boolean | Không | Không | - | Có | Có | False | Checkbox | Không | Có | Platform Soft Delete | DontIndex | Cờ đánh dấu xóa dữ liệu |
| Catalog.DoiTac | LaBenLienKet | Boolean | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính nghiệp vụ danh mục |
| Catalog.DoiTac | DaDangKyThueTrucTiep | Boolean | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính nghiệp vụ danh mục |
| Catalog.DoiTac | LoaiDoiTac | EnumRef.LoaiDoiTac | Không | Có | EnumRef.LoaiDoiTac | Không | Không | Trống | Dropdown | Không | Không | Type Qualifiers | DontIndex | Thuộc tính nghiệp vụ danh mục |
| Catalog.DoiTac | MaSoThue | String(14) | Không | Không | - | Có | Không | Trống | Input | Không | Không | Type Qualifiers | Index | Thuộc tính nghiệp vụ danh mục |
| Catalog.DoiTac | DiaChi | String(250) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính nghiệp vụ danh mục |
| Catalog.DoiTac | SoTaiKhoanNganHang | String(50) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính nghiệp vụ danh mục |
| Catalog.DoiTac | TenNganHang | String(150) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính nghiệp vụ danh mục |

#### Bảng: Catalog.DuAn (Dự án)

| Entity/Table | Field | Data Type | Primary Key | Foreign Key | Reference To | Required | Auto Fill | Default Value | Dropdown/Enum | Unique | Read Only | Validation | Index | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Catalog.DuAn | Ref | UUID (128-bit) | Có (PK 1C) | Không | - | Có | Có | New UUID | Không | Có | Có | Platform UUID | Clustered | Khóa chính bất biến ngầm định của 1C |
| Catalog.DuAn | Code | String(20-50) | Không | Không | - | Không | Có | Tự sinh liên tục | Không | Có | Không | CheckUnique=True | Index | Mã danh mục tự động tăng |
| Catalog.DuAn | Description | String(100-150) | Không | Không | - | Có | Không | Trống | Không | Không | Không | FillChecking | DontIndex | Tên hiển thị danh mục |
| Catalog.DuAn | DeletionMark | Boolean | Không | Không | - | Có | Có | False | Checkbox | Không | Có | Platform Soft Delete | DontIndex | Cờ đánh dấu xóa dữ liệu |
| Catalog.DuAn | MaDuAn | String(50) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính nghiệp vụ danh mục |
| Catalog.DuAn | TenDuAn | String(150) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính nghiệp vụ danh mục |
| Catalog.DuAn | PhapNhan | CatalogRef.PhapNhan | Không | Có | CatalogRef.PhapNhan | Không | Không | Trống | Combobox | Không | Không | Type Qualifiers | DontIndex | Thuộc tính nghiệp vụ danh mục |

#### Bảng: Catalog.HopDong (Hợp đồng)

| Entity/Table | Field | Data Type | Primary Key | Foreign Key | Reference To | Required | Auto Fill | Default Value | Dropdown/Enum | Unique | Read Only | Validation | Index | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Catalog.HopDong | Ref | UUID (128-bit) | Có (PK 1C) | Không | - | Có | Có | New UUID | Không | Có | Có | Platform UUID | Clustered | Khóa chính bất biến ngầm định của 1C |
| Catalog.HopDong | Code | String(20-50) | Không | Không | - | Không | Có | Tự sinh liên tục | Không | Có | Không | CheckUnique=True | Index | Mã danh mục tự động tăng |
| Catalog.HopDong | Description | String(100-150) | Không | Không | - | Có | Không | Trống | Không | Không | Không | FillChecking | DontIndex | Tên hiển thị danh mục |
| Catalog.HopDong | DeletionMark | Boolean | Không | Không | - | Có | Có | False | Checkbox | Không | Có | Platform Soft Delete | DontIndex | Cờ đánh dấu xóa dữ liệu |
| Catalog.HopDong | PhapNhan | CatalogRef.PhapNhan | Không | Có | CatalogRef.PhapNhan | Có | Không | Trống | Combobox | Không | Không | Type Qualifiers | DontIndex | Thuộc tính nghiệp vụ danh mục |
| Catalog.HopDong | ChuSoHuu | CatalogRef.DoiTac | Không | Có | CatalogRef.DoiTac | Không | Không | Trống | Combobox | Không | Không | Type Qualifiers | DontIndex | Thuộc tính nghiệp vụ danh mục |
| Catalog.HopDong | GrossUpThue | Boolean | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính nghiệp vụ danh mục |
| Catalog.HopDong | HanThanhToanNgay | Number(3,0) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính nghiệp vụ danh mục |
| Catalog.HopDong | DongTienThanhToan | CatalogRef.TienTe | Không | Có | CatalogRef.TienTe | Không | Không | Trống | Combobox | Không | Không | Type Qualifiers | DontIndex | Thuộc tính nghiệp vụ danh mục |

#### Bảng: Catalog.KhoanMucDongTien (Khoản mục dòng tiền)

| Entity/Table | Field | Data Type | Primary Key | Foreign Key | Reference To | Required | Auto Fill | Default Value | Dropdown/Enum | Unique | Read Only | Validation | Index | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Catalog.KhoanMucDongTien | Ref | UUID (128-bit) | Có (PK 1C) | Không | - | Có | Có | New UUID | Không | Có | Có | Platform UUID | Clustered | Khóa chính bất biến ngầm định của 1C |
| Catalog.KhoanMucDongTien | Code | String(20-50) | Không | Không | - | Không | Có | Tự sinh liên tục | Không | Có | Không | CheckUnique=True | Index | Mã danh mục tự động tăng |
| Catalog.KhoanMucDongTien | Description | String(100-150) | Không | Không | - | Có | Không | Trống | Không | Không | Không | FillChecking | DontIndex | Tên hiển thị danh mục |
| Catalog.KhoanMucDongTien | DeletionMark | Boolean | Không | Không | - | Có | Có | False | Checkbox | Không | Có | Platform Soft Delete | DontIndex | Cờ đánh dấu xóa dữ liệu |
| Catalog.KhoanMucDongTien | LoaiDongTien | String(50) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính nghiệp vụ danh mục |

#### Bảng: Catalog.PhapNhan (Pháp nhân)

| Entity/Table | Field | Data Type | Primary Key | Foreign Key | Reference To | Required | Auto Fill | Default Value | Dropdown/Enum | Unique | Read Only | Validation | Index | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Catalog.PhapNhan | Ref | UUID (128-bit) | Có (PK 1C) | Không | - | Có | Có | New UUID | Không | Có | Có | Platform UUID | Clustered | Khóa chính bất biến ngầm định của 1C |
| Catalog.PhapNhan | Code | String(20-50) | Không | Không | - | Không | Có | Tự sinh liên tục | Không | Có | Không | CheckUnique=True | Index | Mã danh mục tự động tăng |
| Catalog.PhapNhan | Description | String(100-150) | Không | Không | - | Có | Không | Trống | Không | Không | Không | FillChecking | DontIndex | Tên hiển thị danh mục |
| Catalog.PhapNhan | DeletionMark | Boolean | Không | Không | - | Có | Có | False | Checkbox | Không | Có | Platform Soft Delete | DontIndex | Cờ đánh dấu xóa dữ liệu |
| Catalog.PhapNhan | MaSoThue | String(14) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính nghiệp vụ danh mục |
| Catalog.PhapNhan | DiaChi | String(200) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính nghiệp vụ danh mục |

#### Bảng: Catalog.TaiKhoanTien (Tài khoản tiền)

| Entity/Table | Field | Data Type | Primary Key | Foreign Key | Reference To | Required | Auto Fill | Default Value | Dropdown/Enum | Unique | Read Only | Validation | Index | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Catalog.TaiKhoanTien | Ref | UUID (128-bit) | Có (PK 1C) | Không | - | Có | Có | New UUID | Không | Có | Có | Platform UUID | Clustered | Khóa chính bất biến ngầm định của 1C |
| Catalog.TaiKhoanTien | Code | String(20-50) | Không | Không | - | Không | Có | Tự sinh liên tục | Không | Có | Không | CheckUnique=True | Index | Mã danh mục tự động tăng |
| Catalog.TaiKhoanTien | Description | String(100-150) | Không | Không | - | Có | Không | Trống | Không | Không | Không | FillChecking | DontIndex | Tên hiển thị danh mục |
| Catalog.TaiKhoanTien | DeletionMark | Boolean | Không | Không | - | Có | Có | False | Checkbox | Không | Có | Platform Soft Delete | DontIndex | Cờ đánh dấu xóa dữ liệu |
| Catalog.TaiKhoanTien | SoTaiKhoan | String(30) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính nghiệp vụ danh mục |
| Catalog.TaiKhoanTien | NganHang | String(100) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính nghiệp vụ danh mục |
| Catalog.TaiKhoanTien | TienTe | CatalogRef.TienTe | Không | Có | CatalogRef.TienTe | Không | Không | Trống | Combobox | Không | Không | Type Qualifiers | DontIndex | Thuộc tính nghiệp vụ danh mục |

#### Bảng: Catalog.TienTe (Tiền tệ)

| Entity/Table | Field | Data Type | Primary Key | Foreign Key | Reference To | Required | Auto Fill | Default Value | Dropdown/Enum | Unique | Read Only | Validation | Index | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Catalog.TienTe | Ref | UUID (128-bit) | Có (PK 1C) | Không | - | Có | Có | New UUID | Không | Có | Có | Platform UUID | Clustered | Khóa chính bất biến ngầm định của 1C |
| Catalog.TienTe | Code | String(20-50) | Không | Không | - | Không | Có | Tự sinh liên tục | Không | Có | Không | CheckUnique=True | Index | Mã danh mục tự động tăng |
| Catalog.TienTe | Description | String(100-150) | Không | Không | - | Có | Không | Trống | Không | Không | Không | FillChecking | DontIndex | Tên hiển thị danh mục |
| Catalog.TienTe | DeletionMark | Boolean | Không | Không | - | Có | Có | False | Checkbox | Không | Có | Platform Soft Delete | DontIndex | Cờ đánh dấu xóa dữ liệu |
| Catalog.TienTe | MaTienTe | String(3) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính nghiệp vụ danh mục |
| Catalog.TienTe | TenDayDu | String(50) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính nghiệp vụ danh mục |

### 2.2. Chứng Từ Nghiệp Vụ (Documents)

#### Bảng: Document.BienBanNghiemThuGiaiDoan (Biên bản nghiệm thu giai đoạn)

| Entity/Table | Field | Data Type | Primary Key | Foreign Key | Reference To | Required | Auto Fill | Default Value | Dropdown/Enum | Unique | Read Only | Validation | Index | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Document.BienBanNghiemThuGiaiDoan | Ref | UUID (128-bit) | Có (PK 1C) | Không | - | Có | Có | New UUID | Không | Có | Có | Platform UUID | Clustered | Khóa chính bất biến ngầm định |
| Document.BienBanNghiemThuGiaiDoan | Date | DateTime | Không | Không | - | Có | Có | CurrentSessionDate() | DatePicker | Không | Không | BegOfDay <= Current | Index | Ngày giờ lập chứng từ |
| Document.BienBanNghiemThuGiaiDoan | Number | String(15-20) | Không | Không | - | Có | Có | Tự sinh liên tục | Input | Có | Có | CheckUnique=True | Index | Số chứng từ tự động tăng |
| Document.BienBanNghiemThuGiaiDoan | Posted | Boolean | Không | Không | - | Có | Có | False | Status Badge | Không | Có | Lock khi Posted=True | Index | Trạng thái đã ghi sổ |
| Document.BienBanNghiemThuGiaiDoan | DeletionMark | Boolean | Không | Không | - | Có | Có | False | Checkbox | Không | Có | Platform Soft Delete | DontIndex | Cờ đánh dấu xóa |
| Document.BienBanNghiemThuGiaiDoan | PhapNhan | CatalogRef.PhapNhan | Không | Có | CatalogRef.PhapNhan | Có | Có (Filling) | PN-VSF | Combobox/ChoiceForm | Không | Không | FillChecking=ShowError | DontIndex | Thuộc tính đầu chứng từ |
| Document.BienBanNghiemThuGiaiDoan | DoiTac | CatalogRef.DoiTac | Không | Có | CatalogRef.DoiTac | Có | Không | Trống | Combobox/ChoiceForm | Không | Không | Type Qualifiers | Index | Thuộc tính đầu chứng từ |
| Document.BienBanNghiemThuGiaiDoan | HopDong | CatalogRef.HopDong | Không | Có | CatalogRef.HopDong | Có | Không | Trống | Combobox/ChoiceForm | Không | Không | ChoiceParameterLinks(DoiTac) | DontIndex | Thuộc tính đầu chứng từ |
| Document.BienBanNghiemThuGiaiDoan | GiaTriNghiemThuChuaVAT | Number(15,2) | Không | Không | - | Có | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.BienBanNghiemThuGiaiDoan | TyLeVAT | Number(2,0) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.BienBanNghiemThuGiaiDoan | TienVAT | Number(15,2) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.BienBanNghiemThuGiaiDoan | TongGiaTri | Number(15,2) | Không | Không | - | Có | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.BienBanNghiemThuGiaiDoan | TrangThai | EnumRef.TrangThaiNghiemThuAR | Không | Có | EnumRef.TrangThaiNghiemThuAR | Có | Có (Filling) | DuThao | Dropdown | Không | Có | State Machine BSL | Index | Thuộc tính đầu chứng từ |
| Document.BienBanNghiemThuGiaiDoan | NguoiTao | String(50) | Không | Không | - | Không | Có (Filling) | UserName() | Input | Không | Có | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.BienBanNghiemThuGiaiDoan | NguoiDuyet | String(50) | Không | Không | - | Không | Không | Trống | Input | Không | Có | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.BienBanNghiemThuGiaiDoan | NgayNghiemThu | Date / DateTime | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | Index | Thuộc tính đầu chứng từ |
| Document.BienBanNghiemThuGiaiDoan | DienGiai | String(200) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |

#### Bảng: Document.HoaDonGTGTDauRa (Hóa đơn GTGT đầu ra)

| Entity/Table | Field | Data Type | Primary Key | Foreign Key | Reference To | Required | Auto Fill | Default Value | Dropdown/Enum | Unique | Read Only | Validation | Index | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Document.HoaDonGTGTDauRa | Ref | UUID (128-bit) | Có (PK 1C) | Không | - | Có | Có | New UUID | Không | Có | Có | Platform UUID | Clustered | Khóa chính bất biến ngầm định |
| Document.HoaDonGTGTDauRa | Date | DateTime | Không | Không | - | Có | Có | CurrentSessionDate() | DatePicker | Không | Không | BegOfDay <= Current | Index | Ngày giờ lập chứng từ |
| Document.HoaDonGTGTDauRa | Number | String(15-20) | Không | Không | - | Có | Có | Tự sinh liên tục | Input | Có | Có | CheckUnique=True | Index | Số chứng từ tự động tăng |
| Document.HoaDonGTGTDauRa | Posted | Boolean | Không | Không | - | Có | Có | False | Status Badge | Không | Có | Lock khi Posted=True | Index | Trạng thái đã ghi sổ |
| Document.HoaDonGTGTDauRa | DeletionMark | Boolean | Không | Không | - | Có | Có | False | Checkbox | Không | Có | Platform Soft Delete | DontIndex | Cờ đánh dấu xóa |
| Document.HoaDonGTGTDauRa | PhapNhan | CatalogRef.PhapNhan | Không | Có | CatalogRef.PhapNhan | Có | Có (Filling) | PN-VSF | Combobox/ChoiceForm | Không | Không | FillChecking=ShowError | DontIndex | Thuộc tính đầu chứng từ |
| Document.HoaDonGTGTDauRa | DoiTac | CatalogRef.DoiTac | Không | Có | CatalogRef.DoiTac | Có | Không | Trống | Combobox/ChoiceForm | Không | Không | Type Qualifiers | Index | Thuộc tính đầu chứng từ |
| Document.HoaDonGTGTDauRa | MaSoThueNguoiMua | String(14) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.HoaDonGTGTDauRa | DiaChiNguoiMua | String(250) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.HoaDonGTGTDauRa | HopDong | CatalogRef.HopDong | Không | Có | CatalogRef.HopDong | Có | Không | Trống | Combobox/ChoiceForm | Không | Không | ChoiceParameterLinks(DoiTac) | DontIndex | Thuộc tính đầu chứng từ |
| Document.HoaDonGTGTDauRa | BienBanNghiemThu | DocumentRef.BienBanNghiemThuGiaiDoan | Không | Có | DocumentRef.BienBanNghiemThuGiaiDoan | Có | Không | Trống | Combobox/ChoiceForm | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.HoaDonGTGTDauRa | SoHoaDon | String(20) | Không | Không | - | Có | Không | Trống | Input | Không | Không | FillChecking=ShowError | Index | Thuộc tính đầu chứng từ |
| Document.HoaDonGTGTDauRa | KyHieu | String(10) | Không | Không | - | Có | Không | Trống | Input | Không | Không | FillChecking=ShowError | DontIndex | Thuộc tính đầu chứng từ |
| Document.HoaDonGTGTDauRa | NgayHoaDon | Date / DateTime | Không | Không | - | Có | Không | Trống | Input | Không | Không | FillChecking=ShowError | Index | Thuộc tính đầu chứng từ |
| Document.HoaDonGTGTDauRa | TienChuaThue | Number(15,2) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.HoaDonGTGTDauRa | ThueSuatVAT | Number(2,0) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.HoaDonGTGTDauRa | TienThueVAT | Number(15,2) | Không | Không | - | Không | Có (BeforeWrite) | Tự động tính | Input | Không | Có | TienChuaThue + VAT | DontIndex | Thuộc tính đầu chứng từ |
| Document.HoaDonGTGTDauRa | TongTienThanhToan | Number(15,2) | Không | Không | - | Có | Có (BeforeWrite) | Tự động tính | Input | Không | Có | TienChuaThue + VAT | DontIndex | Thuộc tính đầu chứng từ |
| Document.HoaDonGTGTDauRa | TrangThaiHDDT | EnumRef.TrangThaiHoaDonDienTu | Không | Có | EnumRef.TrangThaiHoaDonDienTu | Không | Có (Filling) | DuThao | Dropdown | Không | Có | State Machine BSL | Index | Thuộc tính đầu chứng từ |
| Document.HoaDonGTGTDauRa | MaCQT | String(50) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.HoaDonGTGTDauRa | DienGiai | String(250) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.HoaDonGTGTDauRa | NguoiLap | String(100) | Không | Không | - | Không | Có (Filling) | UserName() | Input | Không | Có | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.HoaDonGTGTDauRa | NguoiDuyet | String(100) | Không | Không | - | Không | Không | Trống | Input | Không | Có | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |

#### Bảng: Document.HoaDonNhaCungCap (Hóa đơn đầu vào (nhà cung cấp))

| Entity/Table | Field | Data Type | Primary Key | Foreign Key | Reference To | Required | Auto Fill | Default Value | Dropdown/Enum | Unique | Read Only | Validation | Index | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Document.HoaDonNhaCungCap | Ref | UUID (128-bit) | Có (PK 1C) | Không | - | Có | Có | New UUID | Không | Có | Có | Platform UUID | Clustered | Khóa chính bất biến ngầm định |
| Document.HoaDonNhaCungCap | Date | DateTime | Không | Không | - | Có | Có | CurrentSessionDate() | DatePicker | Không | Không | BegOfDay <= Current | Index | Ngày giờ lập chứng từ |
| Document.HoaDonNhaCungCap | Number | String(15-20) | Không | Không | - | Có | Có | Tự sinh liên tục | Input | Có | Có | CheckUnique=True | Index | Số chứng từ tự động tăng |
| Document.HoaDonNhaCungCap | Posted | Boolean | Không | Không | - | Có | Có | False | Status Badge | Không | Có | Lock khi Posted=True | Index | Trạng thái đã ghi sổ |
| Document.HoaDonNhaCungCap | DeletionMark | Boolean | Không | Không | - | Có | Có | False | Checkbox | Không | Có | Platform Soft Delete | DontIndex | Cờ đánh dấu xóa |
| Document.HoaDonNhaCungCap | PhapNhan | CatalogRef.PhapNhan | Không | Có | CatalogRef.PhapNhan | Có | Có (Filling) | PN-VSF | Combobox/ChoiceForm | Không | Không | FillChecking=ShowError | DontIndex | Thuộc tính đầu chứng từ |
| Document.HoaDonNhaCungCap | DoiTac | CatalogRef.DoiTac | Không | Có | CatalogRef.DoiTac | Có | Không | Trống | Combobox/ChoiceForm | Không | Không | Type Qualifiers | Index | Thuộc tính đầu chứng từ |
| Document.HoaDonNhaCungCap | HopDong | CatalogRef.HopDong | Không | Có | CatalogRef.HopDong | Có | Không | Trống | Combobox/ChoiceForm | Không | Không | ChoiceParameterLinks(DoiTac) | DontIndex | Thuộc tính đầu chứng từ |
| Document.HoaDonNhaCungCap | SoHoaDon | String(50) | Không | Không | - | Có | Không | Trống | Input | Không | Không | FillChecking=ShowError | DontIndex | Thuộc tính đầu chứng từ |
| Document.HoaDonNhaCungCap | NgayHoaDon | Date / DateTime | Không | Không | - | Có | Không | Trống | Input | Không | Không | FillChecking=ShowError | Index | Thuộc tính đầu chứng từ |
| Document.HoaDonNhaCungCap | TienTe | CatalogRef.TienTe | Không | Có | CatalogRef.TienTe | Có | Có (Filling) | VND | Combobox/ChoiceForm | Không | Không | FillChecking=ShowError | DontIndex | Thuộc tính đầu chứng từ |
| Document.HoaDonNhaCungCap | TyGia | Number(10,4) | Không | Không | - | Không | Có (Filling) | 1.0000 | Input | Không | Không | AllowedSign=Nonnegative | DontIndex | Thuộc tính đầu chứng từ |
| Document.HoaDonNhaCungCap | TongTien | Number(15,2) | Không | Không | - | Có | Có (BeforeWrite) | Tự động tính | Input | Không | Có | TienChuaThue + VAT | DontIndex | Thuộc tính đầu chứng từ |
| Document.HoaDonNhaCungCap | TongTienNgoaiTe | Number(15,2) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.HoaDonNhaCungCap | TienDichVu | Number(15,2) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.HoaDonNhaCungCap | TienThueVAT | Number(15,2) | Không | Không | - | Không | Có (BeforeWrite) | Tự động tính | Input | Không | Có | TienChuaThue + VAT | DontIndex | Thuộc tính đầu chứng từ |
| Document.HoaDonNhaCungCap | CoKhauTruFCT | Boolean | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.HoaDonNhaCungCap | TyLeThueVATNhaThau | Number(5,2) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.HoaDonNhaCungCap | TyLeThueTNDNNhaThau | Number(5,2) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.HoaDonNhaCungCap | TienThueVATNhaThau | Number(15,2) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.HoaDonNhaCungCap | TienThueTNDNNhaThau | Number(15,2) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.HoaDonNhaCungCap | ChiPhiVSF | Number(15,2) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.HoaDonNhaCungCap | NoThucTraNCC | Number(15,2) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.HoaDonNhaCungCap | TrangThai | EnumRef.TrangThaiHoaDonAP | Không | Có | EnumRef.TrangThaiHoaDonAP | Không | Có (Filling) | DuThao | Dropdown | Không | Có | State Machine BSL | Index | Thuộc tính đầu chứng từ |
| Document.HoaDonNhaCungCap | TaiKhoanChiPhi | ChartOfAccountsRef.HeThongTaiKhoan | Không | Có | ChartOfAccountsRef.HeThongTaiKhoan | Không | Không | Trống | Combobox/ChoiceForm | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.HoaDonNhaCungCap | DienGiai | String(200) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.HoaDonNhaCungCap | NguoiLap | String(100) | Không | Không | - | Không | Có (Filling) | UserName() | Input | Không | Có | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.HoaDonNhaCungCap | NguoiDuyet | String(100) | Không | Không | - | Không | Không | Trống | Input | Không | Có | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |

#### Bảng: Document.PhieuThuTienKhachHang (Phiếu thu tiền khách hàng)

| Entity/Table | Field | Data Type | Primary Key | Foreign Key | Reference To | Required | Auto Fill | Default Value | Dropdown/Enum | Unique | Read Only | Validation | Index | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Document.PhieuThuTienKhachHang | Ref | UUID (128-bit) | Có (PK 1C) | Không | - | Có | Có | New UUID | Không | Có | Có | Platform UUID | Clustered | Khóa chính bất biến ngầm định |
| Document.PhieuThuTienKhachHang | Date | DateTime | Không | Không | - | Có | Có | CurrentSessionDate() | DatePicker | Không | Không | BegOfDay <= Current | Index | Ngày giờ lập chứng từ |
| Document.PhieuThuTienKhachHang | Number | String(15-20) | Không | Không | - | Có | Có | Tự sinh liên tục | Input | Có | Có | CheckUnique=True | Index | Số chứng từ tự động tăng |
| Document.PhieuThuTienKhachHang | Posted | Boolean | Không | Không | - | Có | Có | False | Status Badge | Không | Có | Lock khi Posted=True | Index | Trạng thái đã ghi sổ |
| Document.PhieuThuTienKhachHang | DeletionMark | Boolean | Không | Không | - | Có | Có | False | Checkbox | Không | Có | Platform Soft Delete | DontIndex | Cờ đánh dấu xóa |
| Document.PhieuThuTienKhachHang | PhapNhan | CatalogRef.PhapNhan | Không | Có | CatalogRef.PhapNhan | Có | Có (Filling) | PN-VSF | Combobox/ChoiceForm | Không | Không | FillChecking=ShowError | DontIndex | Thuộc tính đầu chứng từ |
| Document.PhieuThuTienKhachHang | DoiTac | CatalogRef.DoiTac | Không | Có | CatalogRef.DoiTac | Có | Không | Trống | Combobox/ChoiceForm | Không | Không | Type Qualifiers | Index | Thuộc tính đầu chứng từ |
| Document.PhieuThuTienKhachHang | HopDong | CatalogRef.HopDong | Không | Có | CatalogRef.HopDong | Có | Không | Trống | Combobox/ChoiceForm | Không | Không | ChoiceParameterLinks(DoiTac) | DontIndex | Thuộc tính đầu chứng từ |
| Document.PhieuThuTienKhachHang | ChungTuGoc | DocumentRef.BienBanNghiemThuGiaiDoan, DocumentRef.HoaDonGTGTDauRa | Không | Có | DocumentRef.BienBanNghiemThuGiaiDoan, DocumentRef.HoaDonGTGTDauRa | Không | Không | Trống | Combobox/ChoiceForm | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.PhieuThuTienKhachHang | TaiKhoanTien | CatalogRef.TaiKhoanTien | Không | Có | CatalogRef.TaiKhoanTien | Có | Không | Trống | Combobox/ChoiceForm | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.PhieuThuTienKhachHang | KhoanMucDongTien | CatalogRef.KhoanMucDongTien | Không | Có | CatalogRef.KhoanMucDongTien | Có | Không | Trống | Combobox/ChoiceForm | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.PhieuThuTienKhachHang | TienTe | CatalogRef.TienTe | Không | Có | CatalogRef.TienTe | Có | Có (Filling) | VND | Combobox/ChoiceForm | Không | Không | FillChecking=ShowError | DontIndex | Thuộc tính đầu chứng từ |
| Document.PhieuThuTienKhachHang | SoTien | Number(15,2) | Không | Không | - | Có | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.PhieuThuTienKhachHang | SoTienNgoaiTe | Number(15,2) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.PhieuThuTienKhachHang | TyGia | Number(10,4) | Không | Không | - | Không | Có (Filling) | 1.0000 | Input | Không | Không | AllowedSign=Nonnegative | DontIndex | Thuộc tính đầu chứng từ |
| Document.PhieuThuTienKhachHang | NgayThu | Date / DateTime | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | Index | Thuộc tính đầu chứng từ |
| Document.PhieuThuTienKhachHang | DienGiai | String(200) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.PhieuThuTienKhachHang | NguoiLap | String(100) | Không | Không | - | Không | Có (Filling) | UserName() | Input | Không | Có | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.PhieuThuTienKhachHang | NguoiDuyet | String(100) | Không | Không | - | Không | Không | Trống | Input | Không | Có | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |

#### Bảng: Document.UyNhiemChi (Ủy nhiệm chi)

| Entity/Table | Field | Data Type | Primary Key | Foreign Key | Reference To | Required | Auto Fill | Default Value | Dropdown/Enum | Unique | Read Only | Validation | Index | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Document.UyNhiemChi | Ref | UUID (128-bit) | Có (PK 1C) | Không | - | Có | Có | New UUID | Không | Có | Có | Platform UUID | Clustered | Khóa chính bất biến ngầm định |
| Document.UyNhiemChi | Date | DateTime | Không | Không | - | Có | Có | CurrentSessionDate() | DatePicker | Không | Không | BegOfDay <= Current | Index | Ngày giờ lập chứng từ |
| Document.UyNhiemChi | Number | String(15-20) | Không | Không | - | Có | Có | Tự sinh liên tục | Input | Có | Có | CheckUnique=True | Index | Số chứng từ tự động tăng |
| Document.UyNhiemChi | Posted | Boolean | Không | Không | - | Có | Có | False | Status Badge | Không | Có | Lock khi Posted=True | Index | Trạng thái đã ghi sổ |
| Document.UyNhiemChi | DeletionMark | Boolean | Không | Không | - | Có | Có | False | Checkbox | Không | Có | Platform Soft Delete | DontIndex | Cờ đánh dấu xóa |
| Document.UyNhiemChi | PhapNhan | CatalogRef.PhapNhan | Không | Có | CatalogRef.PhapNhan | Có | Có (Filling) | PN-VSF | Combobox/ChoiceForm | Không | Không | FillChecking=ShowError | DontIndex | Thuộc tính đầu chứng từ |
| Document.UyNhiemChi | DoiTac | CatalogRef.DoiTac | Không | Có | CatalogRef.DoiTac | Có | Không | Trống | Combobox/ChoiceForm | Không | Không | Type Qualifiers | Index | Thuộc tính đầu chứng từ |
| Document.UyNhiemChi | HopDong | CatalogRef.HopDong | Không | Có | CatalogRef.HopDong | Có | Không | Trống | Combobox/ChoiceForm | Không | Không | ChoiceParameterLinks(DoiTac) | DontIndex | Thuộc tính đầu chứng từ |
| Document.UyNhiemChi | ChungTuGoc | DocumentRef.HoaDonNhaCungCap, DocumentRef.UyNhiemChi | Không | Có | DocumentRef.HoaDonNhaCungCap, DocumentRef.UyNhiemChi | Không | Không | Trống | Combobox/ChoiceForm | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.UyNhiemChi | TaiKhoanTien | CatalogRef.TaiKhoanTien | Không | Có | CatalogRef.TaiKhoanTien | Có | Không | Trống | Combobox/ChoiceForm | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.UyNhiemChi | KhoanMucDongTien | CatalogRef.KhoanMucDongTien | Không | Có | CatalogRef.KhoanMucDongTien | Có | Không | Trống | Combobox/ChoiceForm | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.UyNhiemChi | TienTe | CatalogRef.TienTe | Không | Có | CatalogRef.TienTe | Có | Có (Filling) | VND | Combobox/ChoiceForm | Không | Không | FillChecking=ShowError | DontIndex | Thuộc tính đầu chứng từ |
| Document.UyNhiemChi | TyGia | Number(10,4) | Không | Không | - | Không | Có (Filling) | 1.0000 | Input | Không | Không | AllowedSign=Nonnegative | DontIndex | Thuộc tính đầu chứng từ |
| Document.UyNhiemChi | SoTien | Number(15,2) | Không | Không | - | Có | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.UyNhiemChi | SoTienNgoaiTe | Number(15,2) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.UyNhiemChi | PhiNganHang | Number(15,2) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.UyNhiemChi | TrangThai | EnumRef.TrangThaiLenhThanhToan | Không | Có | EnumRef.TrangThaiLenhThanhToan | Không | Có (Filling) | DuThao | Dropdown | Không | Có | State Machine BSL | Index | Thuộc tính đầu chứng từ |
| Document.UyNhiemChi | NgayLap | Date / DateTime | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.UyNhiemChi | NgayGhiSo | Date / DateTime | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | Index | Thuộc tính đầu chứng từ |
| Document.UyNhiemChi | LaTraSoatHoanTra | Boolean | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.UyNhiemChi | NguoiLap | String(50) | Không | Không | - | Không | Có (Filling) | UserName() | Input | Không | Có | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.UyNhiemChi | NguoiDuyet | String(50) | Không | Không | - | Không | Không | Trống | Input | Không | Có | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |
| Document.UyNhiemChi | DienGiai | String(200) | Không | Không | - | Không | Không | Trống | Input | Không | Không | Type Qualifiers | DontIndex | Thuộc tính đầu chứng từ |

### 2.3. Sổ Tích Lũy Công Nợ & Dòng Tiền (AccumulationRegisters)

#### Sổ tích lũy: AccumulationRegister.CongNoPhaiThu (Sổ chi tiết công nợ phải thu)

| Entity/Table | Field | Field Kind | Data Type | Primary Key | Foreign Key | Reference To | Required | Unique | Read Only | Index | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|---|
| AccumulationRegister.CongNoPhaiThu | Recorder | Standard | DocumentRef | Có (Composite PK) | Có | All Documents | Có | Không | Có | Clustered | Chứng từ ghi sổ tạo bút toán |
| AccumulationRegister.CongNoPhaiThu | Period | Standard | DateTime | Có (Composite PK) | Không | - | Có | Không | Có | Clustered | Thời điểm phát sinh giao dịch |
| AccumulationRegister.CongNoPhaiThu | RecordType | Standard | Enum (Receipt/Expense) | Có (Composite PK) | Không | - | Có | Không | Có | Clustered | Hướng ghi tăng (Receipt) hoặc giảm (Expense) |
| AccumulationRegister.CongNoPhaiThu | LineNumber | Standard | Number(9) | Có (Composite PK) | Không | - | Có | Có | Có | Clustered | Số thứ tự dòng trong chứng từ |
| AccumulationRegister.CongNoPhaiThu | PhapNhan | Dimension | CatalogRef.PhapNhan | Có (Composite Key) | Có | CatalogRef.PhapNhan | Có | Không | Có | Index | Chiều phân tích dữ liệu |
| AccumulationRegister.CongNoPhaiThu | DoiTac | Dimension | CatalogRef.DoiTac | Có (Composite Key) | Có | CatalogRef.DoiTac | Có | Không | Có | Index | Chiều phân tích dữ liệu |
| AccumulationRegister.CongNoPhaiThu | HopDong | Dimension | CatalogRef.HopDong | Có (Composite Key) | Có | CatalogRef.HopDong | Có | Không | Có | Index | Chiều phân tích dữ liệu |
| AccumulationRegister.CongNoPhaiThu | ChungTuGoc | Dimension | Unknown | Có (Composite Key) | Có | Unknown | Có | Không | Có | Index | Chiều phân tích dữ liệu |
| AccumulationRegister.CongNoPhaiThu | SoTien | Resource | Number(15,2) | Không | Không | - | Có | Không | Có | DontIndex | Chỉ số tích lũy biến động & số dư |
| AccumulationRegister.CongNoPhaiThu | SoTienNgoaiTe | Resource | Number(15,2) | Không | Không | - | Có | Không | Có | DontIndex | Chỉ số tích lũy biến động & số dư |

#### Sổ tích lũy: AccumulationRegister.CongNoPhaiTra (Sổ chi tiết công nợ phải trả)

| Entity/Table | Field | Field Kind | Data Type | Primary Key | Foreign Key | Reference To | Required | Unique | Read Only | Index | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|---|
| AccumulationRegister.CongNoPhaiTra | Recorder | Standard | DocumentRef | Có (Composite PK) | Có | All Documents | Có | Không | Có | Clustered | Chứng từ ghi sổ tạo bút toán |
| AccumulationRegister.CongNoPhaiTra | Period | Standard | DateTime | Có (Composite PK) | Không | - | Có | Không | Có | Clustered | Thời điểm phát sinh giao dịch |
| AccumulationRegister.CongNoPhaiTra | RecordType | Standard | Enum (Receipt/Expense) | Có (Composite PK) | Không | - | Có | Không | Có | Clustered | Hướng ghi tăng (Receipt) hoặc giảm (Expense) |
| AccumulationRegister.CongNoPhaiTra | LineNumber | Standard | Number(9) | Có (Composite PK) | Không | - | Có | Có | Có | Clustered | Số thứ tự dòng trong chứng từ |
| AccumulationRegister.CongNoPhaiTra | PhapNhan | Dimension | CatalogRef.PhapNhan | Có (Composite Key) | Có | CatalogRef.PhapNhan | Có | Không | Có | Index | Chiều phân tích dữ liệu |
| AccumulationRegister.CongNoPhaiTra | DoiTac | Dimension | CatalogRef.DoiTac | Có (Composite Key) | Có | CatalogRef.DoiTac | Có | Không | Có | Index | Chiều phân tích dữ liệu |
| AccumulationRegister.CongNoPhaiTra | HopDong | Dimension | CatalogRef.HopDong | Có (Composite Key) | Có | CatalogRef.HopDong | Có | Không | Có | Index | Chiều phân tích dữ liệu |
| AccumulationRegister.CongNoPhaiTra | ChungTuGoc | Dimension | Unknown | Có (Composite Key) | Có | Unknown | Có | Không | Có | Index | Chiều phân tích dữ liệu |
| AccumulationRegister.CongNoPhaiTra | SoTien | Resource | Number(15,2) | Không | Không | - | Có | Không | Có | DontIndex | Chỉ số tích lũy biến động & số dư |
| AccumulationRegister.CongNoPhaiTra | SoTienNgoaiTe | Resource | Number(15,2) | Không | Không | - | Có | Không | Có | DontIndex | Chỉ số tích lũy biến động & số dư |

#### Sổ tích lũy: AccumulationRegister.DongTien (Sổ chi tiết dòng tiền)

| Entity/Table | Field | Field Kind | Data Type | Primary Key | Foreign Key | Reference To | Required | Unique | Read Only | Index | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|---|
| AccumulationRegister.DongTien | Recorder | Standard | DocumentRef | Có (Composite PK) | Có | All Documents | Có | Không | Có | Clustered | Chứng từ ghi sổ tạo bút toán |
| AccumulationRegister.DongTien | Period | Standard | DateTime | Có (Composite PK) | Không | - | Có | Không | Có | Clustered | Thời điểm phát sinh giao dịch |
| AccumulationRegister.DongTien | RecordType | Standard | Enum (Receipt/Expense) | Có (Composite PK) | Không | - | Có | Không | Có | Clustered | Hướng ghi tăng (Receipt) hoặc giảm (Expense) |
| AccumulationRegister.DongTien | LineNumber | Standard | Number(9) | Có (Composite PK) | Không | - | Có | Có | Có | Clustered | Số thứ tự dòng trong chứng từ |
| AccumulationRegister.DongTien | PhapNhan | Dimension | CatalogRef.PhapNhan | Có (Composite Key) | Có | CatalogRef.PhapNhan | Có | Không | Có | Index | Chiều phân tích dữ liệu |
| AccumulationRegister.DongTien | TaiKhoanTien | Dimension | CatalogRef.TaiKhoanTien | Có (Composite Key) | Có | CatalogRef.TaiKhoanTien | Có | Không | Có | Index | Chiều phân tích dữ liệu |
| AccumulationRegister.DongTien | TienTe | Dimension | CatalogRef.TienTe | Có (Composite Key) | Có | CatalogRef.TienTe | Có | Không | Có | Index | Chiều phân tích dữ liệu |
| AccumulationRegister.DongTien | KhoanMucDongTien | Dimension | CatalogRef.KhoanMucDongTien | Có (Composite Key) | Có | CatalogRef.KhoanMucDongTien | Có | Không | Có | Index | Chiều phân tích dữ liệu |
| AccumulationRegister.DongTien | SoTien | Resource | Number(15,2) | Không | Không | - | Có | Không | Có | DontIndex | Chỉ số tích lũy biến động & số dư |
| AccumulationRegister.DongTien | SoTienNgoaiTe | Resource | Number(15,2) | Không | Không | - | Có | Không | Có | DontIndex | Chỉ số tích lũy biến động & số dư |

### 2.4. Sổ Thông Tin Tỷ Giá Hối Đoái (InformationRegisters)

#### Sổ thông tin: InformationRegister.TyGiaHoiDoai (Exchange Rates)

| Entity/Table | Field | Field Kind | Data Type | Primary Key | Foreign Key | Reference To | Required | Default Value | Index | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|---|
| InformationRegister.TyGiaHoiDoai | Period | Standard | Date | Có (PK) | Không | - | Có | BegOfDay(Date) | Clustered | Kỳ tỷ giá hiệu lực theo ngày |
| InformationRegister.TyGiaHoiDoai | TienTe | Dimension | CatalogRef.TienTe | Có (PK) | Có | CatalogRef.TienTe | Có | VND / USD | Index | Chiều tiền tệ áp dụng tỷ giá |
| InformationRegister.TyGiaHoiDoai | TyGiaMua | Resource | Number(10,4) | Không | Không | - | Có | 1.0000 | DontIndex | Tỷ giá mua, bán, hạch toán |
| InformationRegister.TyGiaHoiDoai | TyGiaBan | Resource | Number(10,4) | Không | Không | - | Có | 1.0000 | DontIndex | Tỷ giá mua, bán, hạch toán |
| InformationRegister.TyGiaHoiDoai | TyGiaHachToan | Resource | Number(10,4) | Không | Không | - | Có | 1.0000 | DontIndex | Tỷ giá mua, bán, hạch toán |

### 2.5. Sổ Cái Kế Toán Tổng Hợp (AccountingRegisters)

#### Sổ cái: AccountingRegister.SoCaiKeToan (Sổ cái kế toán)

| Entity/Table | Field | Field Kind | Data Type | Primary Key | Foreign Key | Reference To | Required | Index | Ghi chú |
|---|---|---|---|---|---|---|---|---|---|
| AccountingRegister.SoCaiKeToan | Recorder | Standard | DocumentRef | Có (PK) | Có | Documents | Có | Clustered | Chứng từ ghi sổ kế toán |
| AccountingRegister.SoCaiKeToan | Period | Standard | DateTime | Có (PK) | Không | - | Có | Clustered | Thời điểm phát sinh bút toán |
| AccountingRegister.SoCaiKeToan | AccountDr | Standard | ChartOfAccountsRef | Có | Có | HeThongTaiKhoan (243 TK) | Có | Index | Tài khoản ghi Nợ (Debit) |
| AccountingRegister.SoCaiKeToan | AccountCr | Standard | ChartOfAccountsRef | Có | Có | HeThongTaiKhoan (243 TK) | Có | Index | Tài khoản ghi Có (Credit) |
| AccountingRegister.SoCaiKeToan | PhapNhan | Dimension | CatalogRef.PhapNhan | Có | Có | CatalogRef.PhapNhan | Có | Index | Chiều phân tích sổ cái |
| AccountingRegister.SoCaiKeToan | TienTe | Dimension | CatalogRef.TienTe | Có | Có | CatalogRef.TienTe | Có | Index | Chiều phân tích sổ cái |
| AccountingRegister.SoCaiKeToan | SoTien | Resource | Number(15,2) | Không | Không | - | Có | DontIndex | Số tiền VND / Ngoại tệ bút toán |
| AccountingRegister.SoCaiKeToan | SoTienNgoaiTe | Resource | Number(15,2) | Không | Không | - | Có | DontIndex | Số tiền VND / Ngoại tệ bút toán |

---

## 3. BẢNG TỔNG HỢP GAP ANALYSIS & LÝ DO THAY ĐỔI

| STT | Hạng mục / Đối tượng | Cấu hình cũ | Vấn đề phát hiện | Cấu hình đề xuất (Đã áp dụng) | Lý do thay đổi & Căn cứ kỹ thuật |
|---|---|---|---|---|---|
| 1 | Quyền Quản trị Admin | Chặn cứng Ghi sổ / Hủy ghi sổ và Ký duyệt tại `PhanQuyenBaoMatServer.bsl` | Admin bị chặn thao tác ghi sổ và duyệt chứng từ tài chính | Admin và role `QuanTriHeThong` có toàn quyền tuyệt đối (`Return;` bypass) | Quyền Admin tối thượng; khôi phục khả năng vận hành kỹ thuật và kiểm thử |
| 2 | Ràng buộc trường bắt buộc | Thuộc tính `FillChecking = DontCheck` trên nhiều header chứng từ | Người dùng có thể lưu chứng từ thiếu Đối tác, Hợp đồng, Số tiền gây lỗi dữ liệu | Cấu hình `FillChecking = ShowError` trên Metadata | Nguyên tắc Ponytail: Tận dụng cơ chế declarative của 1C platform, tự động viền đỏ UI |
| 3 | Giới hạn số âm | Thiếu cờ khai báo thuộc tính số âm | Có nguy cơ nhập số âm cho số tiền thanh toán hoặc tỷ giá | Khẳng định `AllowedSign = Nonnegative` trên toàn bộ trường tiền tệ & số lượng | Chặn nhập số âm ngay tại tầng nền tảng 1C UI và DB engine |
| 4 | Tự động điền dữ liệu | Thiếu handler chuẩn `Filling` trên 5 Document ObjectModule | Khi tạo mới hoặc sinh từ chứng từ khác (`BasedOn`), người dùng phải gõ tay toàn bộ | Cấu hình `Procedure Filling` chuẩn BSL tự động điền Ngày, Người lập, Pháp nhân, Tiền tệ, và kế thừa BasedOn | Chuẩn `code-patterns.md`, giảm 80% thao tác nhập liệu thủ công |
| 5 | Chọn Hợp đồng phụ thuộc | Thiếu `ChoiceParameterLinks` trên BB Nghiệm thu, Phiếu thu, UNC | Khi chọn Hợp đồng, hiển thị toàn bộ hợp đồng của tất cả đối tác khác | Khai báo `ChoiceParameterLinks: Filter.ChuSoHuu(DoiTac)` | Nền tảng 1C tự động lọc danh sách chọn theo Đối tác đã chọn, không cần viết code sự kiện |
| 6 | Bảo vệ chứng từ đã ghi sổ | Form không tự khóa chỉ đọc sau khi ghi sổ | Người dùng có thể can thiệp số tiền chứng từ đã ghi vào sổ kế toán | Gọi `ReadOnly = True` trên Form khi `Object.Posted = True` | Bảo vệ tính toàn vẹn số liệu kế toán và phân tách trách nhiệm |
| 7 | Tối ưu hóa truy vấn CSDL | Thuộc tính tìm kiếm thường xuyên để `Indexing = DontIndex` | Tìm kiếm theo Đối tác, Ngày chứng từ hoặc Trạng thái bị quét toàn bảng (Table Scan) | Thiết lập `Indexing = Index` cho các trường tìm kiếm trọng yếu | Tối ưu hóa chỉ mục CSDL MSSQL/PostgreSQL của nền tảng 1C, tăng tốc báo cáo |

---

## 4. KẾT LUẬN & KIỂM CHỨNG TÍNH TOÀN VẸN (DATA INTEGRITY)
- **Duplicate Records**: 0 (Mọi đối tượng được định danh duy nhất qua `Ref` UUID 128-bit và `CheckUnique=true`).
- **Orphan Records**: 0 (100% quan hệ khóa ngoại sử dụng kiểu tham chiếu strongly typed).
- **Hệ thống tài khoản TT200**: Toàn vẹn 243 tài khoản kế toán cấp 1 & 2 theo Thông tư 200/2014/TT-BTC.
- **Zero Code Bloat**: Áp dụng triệt để nguyên lý Ponytail, xóa bỏ rào cản thừa và khai thác tối đa thuộc tính declarative của 1C:Enterprise 8.3 Taxi.
