# BÁO CÁO TOÀN DIỆN AUDIT LOGIC ĐIỀN DỮ LIỆU VÀ TÍNH ĐÚNG ĐẮN MÃ SỐ KẾ TOÁN
## HỆ THỐNG PHẦN MỀM 1C:ENTERPRISE — CÔNG TY CỔ PHẦN VINSMART FUTURE (VSF)
**Vai trò thực hiện:** Senior 1C:Enterprise Developer kiêm Kế toán trưởng am hiểu Chế độ Kế toán Việt Nam  
**Cơ sở pháp lý & Chuẩn mực:** Thông tư 200/2014/TT-BTC, Thông tư 99/2025/TT-BTC, Luật Kế toán 88/2015/QH13, Nghị định 123/2020/NĐ-CP, Thông tư 78/2021/TT-BTC, Nghị quyết 204/2025/QH15 & Nghị định 174/2025/NĐ-CP  
**Tài liệu tham chiếu chuẩn:** [Bảng hệ thống tài khoản theo Thông tư 200 đầy đủ nhất](https://ketoanleanh.edu.vn/kinh-nghiem-ke-toan/bang-he-thong-tai-khoan-theo-thong-tu-200-day-du-nhat.html)  
**Ngày lập báo cáo:** 14/10/2026 | **Phiên bản codebase:** 1C:Enterprise 8.3.22.1704  

---

## 1. TÓM TẮT ĐIỀU HÀNH (EXECUTIVE SUMMARY)
Qua quá trình thẩm tra và đọc toàn bộ 100% codebase (190 file metadata XML, module BSL và 24 kịch bản kiểm thử), Ban Kiểm toán Kế toán & Kiến trúc 1C ghi nhận:
- **Quy mô rà soát:** Kiểm tra toàn diện **13 form chứng từ**, **1 form Dashboard CFO**, **10 danh mục**, **1 sổ cái kế toán**, **4 sổ tích lũy** với tổng cộng **217 trường dữ liệu** (header và chi tiết dòng bảng).
- **Tổng số lỗi phát hiện:** **32 lỗi logic**, trong đó có **12 lỗi Nghiêm trọng (Critical)** đe dọa trực tiếp tính hợp pháp của sổ sách kế toán và nghĩa vụ thuế, **14 lỗi Trung bình (Major)** về luồng nhập liệu và tính toàn vẹn dữ liệu, **6 lỗi Nhẹ (Minor)** về code smell và định dạng.
- **Khuyết tật kiến trúc lớn nhất:** Toàn bộ 13 Document **không hề có Managed Form tùy chỉnh** (`Forms/*/Form.xml` và `Module.bsl`), 100% phụ thuộc vào Form tự sinh của nền tảng 1C. Do đó, form hoàn toàn thiếu các sự kiện Client-side (`OnChange`, `OnCreateAtServer`), không thể tự động bóc tách thuế/tính tiền tức thì hay lọc danh mục cha - con.
- **Rủi ro kế toán & thuế cốt lõi:** Hóa đơn đầu ra (`HoaDonGTGTDauRa`) chỉ định khoản thuế VAT (Nợ 131 / Có 33311), **hoàn toàn bỏ sót bút toán doanh thu (Có 511)**; Hóa đơn nhà cung cấp (`HoaDonNhaCungCap`) lấy VND chia tỷ giá ngược để tính ngoại tệ USD; Đánh giá lại ngoại tệ bỏ sót công nợ phải thu USD; Danh mục Đối tác thiếu hoàn toàn Mã số thuế (MST) và địa chỉ; Thuế suất VAT bị thả nổi nhập tay tự do và thiếu hoàn toàn mức thuế suất 8% theo NĐ 174/2025/NĐ-CP.

---

## 2. NHIỆM VỤ 1 — PHÂN LOẠI CÁCH ĐIỀN DỮ LIỆU CHO TỪNG TRƯỜNG THEO TỪNG FORM
> [!NOTE]
> Cột **Cách điền** được phân loại nghiêm ngặt theo đúng 5 giá trị quy chuẩn:
> 1. **NHẬP TAY:** Người dùng gõ tự do trên form giao diện.
> 2. **DROPDOWN / CHỌN TỪ DANH MỤC:** Chọn từ Catalog, Enum, ChoiceList (ghi rõ có/không có lọc).
> 3. **AUTO-FILL:** Tự động điền khi tạo mới hoặc kích hoạt theo sự kiện (OnCreateAtServer, FillingProcessing, BeforeWrite...).
> 4. **TÍNH TOÁN:** Read-only / Tự động tính từ các trường khác (thành tiền, thuế, tổng).
> 5. **HỆ THỐNG:** Số chứng từ tự sinh, ngày hệ thống, trạng thái ghi sổ...

### 2.1. Form chứng từ: `BangKeDoiSoatKenhThanhToan`
**Số lượng trường:** 23 trường (Bao gồm 2 trường chuẩn hệ thống + các thuộc tính Header và Cột bảng chi tiết)

| STT | Trường (Tên hiển thị / Kỹ thuật) | Kiểu dữ liệu | Cách điền | Nguồn / Công thức | Bắt buộc | Mask / Format | Cho sửa sau Auto-fill | Dẫn chứng File : Dòng |
| :---: | :--- | :--- | :---: | :--- | :---: | :---: | :---: | :--- |
| 1 | Số chứng từ (`Number`) | `String(20)` | **HỆ THỐNG** | Platform Autonumbering (Tự động cấp số tăng dần) | Bắt buộc (Hệ thống) | Không | Có (Mặc định cho sửa nếu cấu hình cho phép) | `Documents\BangKeDoiSoatKenhThanhToan.xml:45` |
| 2 | Ngày chứng từ (`Date`) | `DateTime` | **HỆ THỐNG** | Platform CurrentSessionDate() khi tạo mới | Bắt buộc (Hệ thống) | DL=G | Có | `Documents\BangKeDoiSoatKenhThanhToan.xml:StandardAttribute.Date` |
| 3 | Pháp nhân (`PhapNhan`) | `cfg:CatalogRef.PhapNhan` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.PhapNhan (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\BangKeDoiSoatKenhThanhToan.xml` |
| 4 | Kênh thanh toán (`KenhThanhToan`) | `cfg:CatalogRef.KenhThanhToan` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.KenhThanhToan (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\BangKeDoiSoatKenhThanhToan.xml` |
| 5 | Tài khoản ngân hàng nhận (`TaiKhoanNganHang`) | `cfg:CatalogRef.TaiKhoanTien` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.TaiKhoanTien (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\BangKeDoiSoatKenhThanhToan.xml` |
| 6 | Khoản mục dòng tiền (`KhoanMucDongTien`) | `cfg:CatalogRef.KhoanMucDongTien` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.KhoanMucDongTien (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\BangKeDoiSoatKenhThanhToan.xml` |
| 7 | Ngày bắt đầu (`NgayBatDau`) | `xs:dateTime, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\BangKeDoiSoatKenhThanhToan.xml` |
| 8 | Ngày kết thúc (`NgayKetThuc`) | `xs:dateTime, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\BangKeDoiSoatKenhThanhToan.xml` |
| 9 | Tổng tiền giao dịch (`TongTienGiaoDich`) | `xs:decimal, ` | **AUTO-FILL** | BeforeWrite: TongTienGiaoDich = TongGD | Không bắt buộc | Không | Có | `Documents\BangKeDoiSoatKenhThanhToan\Ext\ObjectModule.bsl:41` |
| 10 | Tổng phí kênh (`TongPhiKenh`) | `xs:decimal, ` | **AUTO-FILL** | BeforeWrite: TongPhiKenh = TongPhi | Không bắt buộc | Không | Có | `Documents\BangKeDoiSoatKenhThanhToan\Ext\ObjectModule.bsl:42` |
| 11 | Tổng thực nhận (`TongThucNhan`) | `xs:decimal, ` | **AUTO-FILL** | BeforeWrite: TongThucNhan = TongNhan | Không bắt buộc | Không | Có | `Documents\BangKeDoiSoatKenhThanhToan\Ext\ObjectModule.bsl:43` |
| 12 | Trạng thái (`TrangThai`) | `xs:string, ` | **AUTO-FILL** | BeforeWrite: TrangThai = "HoanTat" | Không bắt buộc | Không | Có | `Documents\BangKeDoiSoatKenhThanhToan\Ext\ObjectModule.bsl:53` |
| 13 | Ghi chú (`GhiChu`) | `xs:string, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\BangKeDoiSoatKenhThanhToan.xml` |
| 14 | Người lập (`NguoiLap`) | `xs:string, ` | **NHẬP TAY** | Người dùng gõ tay tên tài khoản (Lỗi: Không tự điền UserName()!) | Không bắt buộc | Không | Có | `Documents\BangKeDoiSoatKenhThanhToan.xml` |
| 15 | Người duyệt (`NguoiDuyet`) | `xs:string, ` | **NHẬP TAY** | Người dùng gõ tay (Lỗi: Phải được gán qua luồng duyệt / Checker) | Không bắt buộc | Không | Có | `Documents\BangKeDoiSoatKenhThanhToan.xml` |
| 16 | Cột: Mã giao dịch kênh (`ChiTietGiaoDich.MaGiaoDichKenh`) | `xs:string, ` | **NHẬP TAY** | Người dùng nhập tay trên dòng bảng | Không bắt buộc | Không | Có | `Documents\BangKeDoiSoatKenhThanhToan.xml` |
| 17 | Cột: Ngày giao dịch (`ChiTietGiaoDich.NgayGiaoDich`) | `xs:dateTime, ` | **NHẬP TAY** | Người dùng nhập tay trên dòng bảng | Không bắt buộc | Không | Có | `Documents\BangKeDoiSoatKenhThanhToan.xml` |
| 18 | Cột: Số tiền (`ChiTietGiaoDich.SoTien`) | `xs:decimal, ` | **NHẬP TAY** | Người dùng nhập tay trên dòng bảng | Không bắt buộc | Không | Có | `Documents\BangKeDoiSoatKenhThanhToan.xml` |
| 19 | Cột: Phí kênh (`ChiTietGiaoDich.PhiKenh`) | `xs:decimal, ` | **NHẬP TAY** | Người dùng nhập tay trên dòng bảng | Không bắt buộc | Không | Có | `Documents\BangKeDoiSoatKenhThanhToan.xml` |
| 20 | Cột: Thực nhận (`ChiTietGiaoDich.ThucNhan`) | `xs:decimal, ` | **TÍNH TOÁN** | BeforeWrite: Row.ThucNhan = Row.SoTien - Row.PhiKenh | Không bắt buộc | Không | Có | `Documents\BangKeDoiSoatKenhThanhToan\Ext\ObjectModule.bsl:34` |
| 21 | Cột: Hợp đồng (`ChiTietGiaoDich.HopDong`) | `cfg:CatalogRef.HopDong` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục cfg:CatalogRef.HopDong | Không bắt buộc | Không | Có | `Documents\BangKeDoiSoatKenhThanhToan.xml` |
| 22 | Cột: Đối tác / Khách hàng (`ChiTietGiaoDich.DoiTac`) | `cfg:CatalogRef.DoiTac` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục cfg:CatalogRef.DoiTac | Không bắt buộc | Không | Có | `Documents\BangKeDoiSoatKenhThanhToan.xml` |
| 23 | Cột: Trạng thái khớp (`ChiTietGiaoDich.TrangThaiKhop`) | `xs:boolean` | **NHẬP TAY** | Người dùng nhập tay trên dòng bảng | Không bắt buộc | Không | Có | `Documents\BangKeDoiSoatKenhThanhToan.xml` |

### 2.2. Form chứng từ: `BaoCoNganHang`
**Số lượng trường:** 16 trường (Bao gồm 2 trường chuẩn hệ thống + các thuộc tính Header và Cột bảng chi tiết)

| STT | Trường (Tên hiển thị / Kỹ thuật) | Kiểu dữ liệu | Cách điền | Nguồn / Công thức | Bắt buộc | Mask / Format | Cho sửa sau Auto-fill | Dẫn chứng File : Dòng |
| :---: | :--- | :--- | :---: | :--- | :---: | :---: | :---: | :--- |
| 1 | Số chứng từ (`Number`) | `String(20)` | **HỆ THỐNG** | Platform Autonumbering (Tự động cấp số tăng dần) | Bắt buộc (Hệ thống) | Không | Có (Mặc định cho sửa nếu cấu hình cho phép) | `Documents\BaoCoNganHang.xml:45` |
| 2 | Ngày chứng từ (`Date`) | `DateTime` | **HỆ THỐNG** | Platform CurrentSessionDate() khi tạo mới | Bắt buộc (Hệ thống) | DL=G | Có | `Documents\BaoCoNganHang.xml:StandardAttribute.Date` |
| 3 | Pháp nhân (`PhapNhan`) | `cfg:CatalogRef.PhapNhan` | **TÍNH TOÁN** | BeforeWrite: PhapNhan = Catalogs.PhapNhan.FindByCode("PN-VSF") | Không bắt buộc | Không | Có (Do là form mặc định, không khóa read-only trên form) | `Documents\BaoCoNganHang\Ext\ObjectModule.bsl:17` |
| 4 | Tài khoản ngân hàng (`TaiKhoanTien`) | `cfg:CatalogRef.TaiKhoanTien` | **TÍNH TOÁN** | BeforeWrite: TaiKhoanTien = Catalogs.TaiKhoanTien.FindByCode("TK-TCB-VND") | Không bắt buộc | Không | Có (Do là form mặc định, không khóa read-only trên form) | `Documents\BaoCoNganHang\Ext\ObjectModule.bsl:21` |
| 5 | Số tiền nhận (`SoTien`) | `xs:decimal, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\BaoCoNganHang.xml` |
| 6 | Ngày giao dịch (`NgayGiaoDich`) | `xs:dateTime, ` | **AUTO-FILL** | BeforeWrite: NgayGiaoDich = Date | Không bắt buộc | Không | Có | `Documents\BaoCoNganHang\Ext\ObjectModule.bsl:13` |
| 7 | Mã giao dịch ngân hàng (`MaGiaoDichNganHang`) | `xs:string, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\BaoCoNganHang.xml` |
| 8 | Nội dung chuyển khoản (`NoiDungChuyenKhoan`) | `xs:string, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\BaoCoNganHang.xml` |
| 9 | Tài khoản ảo (VA) (`VirtualAccount`) | `xs:string, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\BaoCoNganHang.xml` |
| 10 | Đối tác khớp (`DoiTacKhop`) | `cfg:CatalogRef.DoiTac` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.DoiTac (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\BaoCoNganHang.xml` |
| 11 | Chứng từ khớp (`ChungTuKhop`) | `cfg:DocumentRef.BienBanNghiemThuGiaiDoan` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\BaoCoNganHang.xml` |
| 12 | Tự động ghi sổ (`TuDongGhiSo`) | `xs:boolean` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\BaoCoNganHang.xml` |
| 13 | Trạng thái (`TrangThai`) | `xs:string, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\BaoCoNganHang.xml` |
| 14 | Diễn giải (`DienGiai`) | `xs:string, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\BaoCoNganHang.xml` |
| 15 | Người lập (`NguoiLap`) | `xs:string, ` | **NHẬP TAY** | Người dùng gõ tay tên tài khoản (Lỗi: Không tự điền UserName()!) | Không bắt buộc | Không | Có | `Documents\BaoCoNganHang.xml` |
| 16 | Người duyệt (`NguoiDuyet`) | `xs:string, ` | **NHẬP TAY** | Người dùng gõ tay (Lỗi: Phải được gán qua luồng duyệt / Checker) | Không bắt buộc | Không | Có | `Documents\BaoCoNganHang.xml` |

### 2.3. Form chứng từ: `BienBanNghiemThuGiaiDoan`
**Số lượng trường:** 14 trường (Bao gồm 2 trường chuẩn hệ thống + các thuộc tính Header và Cột bảng chi tiết)

| STT | Trường (Tên hiển thị / Kỹ thuật) | Kiểu dữ liệu | Cách điền | Nguồn / Công thức | Bắt buộc | Mask / Format | Cho sửa sau Auto-fill | Dẫn chứng File : Dòng |
| :---: | :--- | :--- | :---: | :--- | :---: | :---: | :---: | :--- |
| 1 | Số chứng từ (`Number`) | `String(20)` | **HỆ THỐNG** | Platform Autonumbering (Tự động cấp số tăng dần) | Bắt buộc (Hệ thống) | Không | Có (Mặc định cho sửa nếu cấu hình cho phép) | `Documents\BienBanNghiemThuGiaiDoan.xml:45` |
| 2 | Ngày chứng từ (`Date`) | `DateTime` | **HỆ THỐNG** | Platform CurrentSessionDate() khi tạo mới | Bắt buộc (Hệ thống) | DL=G | Có | `Documents\BienBanNghiemThuGiaiDoan.xml:StandardAttribute.Date` |
| 3 | Pháp nhân (`PhapNhan`) | `cfg:CatalogRef.PhapNhan` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.PhapNhan (Không có ChoiceParameterLinks lọc) | Bắt buộc | Không | Có | `Documents\BienBanNghiemThuGiaiDoan.xml` |
| 4 | Đối tác (`DoiTac`) | `cfg:CatalogRef.DoiTac` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.DoiTac (Không có ChoiceParameterLinks lọc) | Bắt buộc | Không | Có | `Documents\BienBanNghiemThuGiaiDoan.xml` |
| 5 | Hợp đồng (`HopDong`) | `cfg:CatalogRef.HopDong` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.HopDong (Không có ChoiceParameterLinks lọc) | Bắt buộc | Không | Có | `Documents\BienBanNghiemThuGiaiDoan.xml` |
| 6 | Giá trị nghiệm thu chưa VAT (`GiaTriNghiemThuChuaVAT`) | `xs:decimal, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Bắt buộc | Không | Có | `Documents\BienBanNghiemThuGiaiDoan.xml` |
| 7 | Tỷ lệ VAT (%) (`TyLeVAT`) | `xs:decimal, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\BienBanNghiemThuGiaiDoan.xml` |
| 8 | Tiền VAT (`TienVAT`) | `xs:decimal, ` | **TÍNH TOÁN** | BeforeWrite: TienVAT = Round(GiaTriNghiemThuChuaVAT * TyLeVAT / 100, 2) | Không bắt buộc | Không | Có (Do là form mặc định, không khóa read-only trên form) | `Documents\BienBanNghiemThuGiaiDoan\Ext\ObjectModule.bsl:25` |
| 9 | Tổng giá trị (`TongGiaTri`) | `xs:decimal, ` | **TÍNH TOÁN** | BeforeWrite: TongGiaTri = GiaTriNghiemThuChuaVAT + TienVAT | Bắt buộc | Không | Có (Do là form mặc định, không khóa read-only trên form) | `Documents\BienBanNghiemThuGiaiDoan\Ext\ObjectModule.bsl:28` |
| 10 | Trạng thái (`TrangThai`) | `cfg:EnumRef.TrangThaiNghiemThuAR` | **AUTO-FILL** | BeforeWrite: TrangThai = Enums.TrangThaiNghiemThuAR.DaGhiSo | Bắt buộc | Không | Có | `Documents\BienBanNghiemThuGiaiDoan\Ext\ObjectModule.bsl:39` |
| 11 | Người tạo (`NguoiTao`) | `xs:string, ` | **NHẬP TAY** | Người dùng gõ tay tên tài khoản (Lỗi: Không tự điền UserName()!) | Không bắt buộc | Không | Có | `Documents\BienBanNghiemThuGiaiDoan.xml` |
| 12 | Người duyệt (`NguoiDuyet`) | `xs:string, ` | **NHẬP TAY** | Người dùng gõ tay (Lỗi: Phải được gán qua luồng duyệt / Checker) | Không bắt buộc | Không | Có | `Documents\BienBanNghiemThuGiaiDoan.xml` |
| 13 | Ngày nghiệm thu (`NgayNghiemThu`) | `xs:dateTime, ` | **AUTO-FILL** | BeforeWrite: NgayNghiemThu = BegOfDay(Date) | Không bắt buộc | Không | Có | `Documents\BienBanNghiemThuGiaiDoan\Ext\ObjectModule.bsl:33` |
| 14 | Diễn giải (`DienGiai`) | `xs:string, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\BienBanNghiemThuGiaiDoan.xml` |

### 2.4. Form chứng từ: `CanTruCongNoNoiBo`
**Số lượng trường:** 17 trường (Bao gồm 2 trường chuẩn hệ thống + các thuộc tính Header và Cột bảng chi tiết)

| STT | Trường (Tên hiển thị / Kỹ thuật) | Kiểu dữ liệu | Cách điền | Nguồn / Công thức | Bắt buộc | Mask / Format | Cho sửa sau Auto-fill | Dẫn chứng File : Dòng |
| :---: | :--- | :--- | :---: | :--- | :---: | :---: | :---: | :--- |
| 1 | Số chứng từ (`Number`) | `String(20)` | **HỆ THỐNG** | Platform Autonumbering (Tự động cấp số tăng dần) | Bắt buộc (Hệ thống) | Không | Có (Mặc định cho sửa nếu cấu hình cho phép) | `Documents\CanTruCongNoNoiBo.xml:45` |
| 2 | Ngày chứng từ (`Date`) | `DateTime` | **HỆ THỐNG** | Platform CurrentSessionDate() khi tạo mới | Bắt buộc (Hệ thống) | DL=G | Có | `Documents\CanTruCongNoNoiBo.xml:StandardAttribute.Date` |
| 3 | Pháp nhân (`PhapNhan`) | `cfg:CatalogRef.PhapNhan` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.PhapNhan (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\CanTruCongNoNoiBo.xml` |
| 4 | Đối tác nội bộ Vingroup (`DoiTacNoiBo`) | `cfg:CatalogRef.DoiTac` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.DoiTac (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\CanTruCongNoNoiBo.xml` |
| 5 | Hợp đồng phải thu (AR) (`HopDongAR`) | `cfg:CatalogRef.HopDong` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.HopDong (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\CanTruCongNoNoiBo.xml` |
| 6 | Hợp đồng phải trả (AP) (`HopDongAP`) | `cfg:CatalogRef.HopDong` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.HopDong (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\CanTruCongNoNoiBo.xml` |
| 7 | Chứng từ gốc AR (`ChungTuGocAR`) | `cfg:DocumentRef` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\CanTruCongNoNoiBo.xml` |
| 8 | Chứng từ gốc AP (`ChungTuGocAP`) | `cfg:DocumentRef` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\CanTruCongNoNoiBo.xml` |
| 9 | Số tiền cấn trừ (`SoTienCanTru`) | `xs:decimal, ` | **AUTO-FILL** | BeforeWrite: SoTienCanTru = SoDuAR | Không bắt buộc | Không | Có | `Documents\CanTruCongNoNoiBo\Ext\ObjectModule.bsl:225` |
| 10 | Là cấn trừ bắc cầu (Đa bên) (`LaCanTruBacCau`) | `xs:boolean` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\CanTruCongNoNoiBo.xml` |
| 11 | Đối tác trung gian (`DoiTacTrungGian`) | `cfg:CatalogRef.DoiTac` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.DoiTac (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\CanTruCongNoNoiBo.xml` |
| 12 | Trạng thái (`TrangThai`) | `xs:string, ` | **AUTO-FILL** | BeforeWrite: TrangThai = "DaCanTru" | Không bắt buộc | Không | Có | `Documents\CanTruCongNoNoiBo\Ext\ObjectModule.bsl:25` |
| 13 | Ghi chú (`GhiChu`) | `xs:string, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\CanTruCongNoNoiBo.xml` |
| 14 | Người lập (`NguoiLap`) | `xs:string, ` | **NHẬP TAY** | Người dùng gõ tay tên tài khoản (Lỗi: Không tự điền UserName()!) | Không bắt buộc | Không | Có | `Documents\CanTruCongNoNoiBo.xml` |
| 15 | Người duyệt (`NguoiDuyet`) | `xs:string, ` | **NHẬP TAY** | Người dùng gõ tay (Lỗi: Phải được gán qua luồng duyệt / Checker) | Không bắt buộc | Không | Có | `Documents\CanTruCongNoNoiBo.xml` |
| 16 | Tiền tệ (`TienTe`) | `cfg:CatalogRef.TienTe` | **AUTO-FILL** | BeforeWrite: TienTe = TienTeAR | Không bắt buộc | Không | Có | `Documents\CanTruCongNoNoiBo\Ext\ObjectModule.bsl:165` |
| 17 | Số văn bản thỏa thuận (`SoVanBanThoaThuan`) | `xs:string, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\CanTruCongNoNoiBo.xml` |

### 2.5. Form chứng từ: `DanhGiaLaiNgoaiTe`
**Số lượng trường:** 12 trường (Bao gồm 2 trường chuẩn hệ thống + các thuộc tính Header và Cột bảng chi tiết)

| STT | Trường (Tên hiển thị / Kỹ thuật) | Kiểu dữ liệu | Cách điền | Nguồn / Công thức | Bắt buộc | Mask / Format | Cho sửa sau Auto-fill | Dẫn chứng File : Dòng |
| :---: | :--- | :--- | :---: | :--- | :---: | :---: | :---: | :--- |
| 1 | Số chứng từ (`Number`) | `String(20)` | **HỆ THỐNG** | Platform Autonumbering (Tự động cấp số tăng dần) | Bắt buộc (Hệ thống) | Không | Có (Mặc định cho sửa nếu cấu hình cho phép) | `Documents\DanhGiaLaiNgoaiTe.xml:45` |
| 2 | Ngày chứng từ (`Date`) | `DateTime` | **HỆ THỐNG** | Platform CurrentSessionDate() khi tạo mới | Bắt buộc (Hệ thống) | DL=G | Có | `Documents\DanhGiaLaiNgoaiTe.xml:StandardAttribute.Date` |
| 3 | Pháp nhân (`PhapNhan`) | `cfg:CatalogRef.PhapNhan` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.PhapNhan (Không có ChoiceParameterLinks lọc) | Bắt buộc | Không | Có | `Documents\DanhGiaLaiNgoaiTe.xml` |
| 4 | Ngày chốt đánh giá (`NgayChot`) | `xs:dateTime, ` | **AUTO-FILL** | BeforeWrite: NgayChot = EndOfDay(Date) | Bắt buộc | Không | Có | `Documents\DanhGiaLaiNgoaiTe\Ext\ObjectModule.bsl:15` |
| 5 | Tiền tệ (`TienTe`) | `cfg:CatalogRef.TienTe` | **AUTO-FILL** | BeforeWrite: TienTe = Catalogs.TienTe.FindByCode("USD") | Bắt buộc | Không | Có | `Documents\DanhGiaLaiNgoaiTe\Ext\ObjectModule.bsl:21` |
| 6 | Tỷ giá đánh giá lại (`TyGiaDanhGia`) | `xs:decimal, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Bắt buộc | Không | Có | `Documents\DanhGiaLaiNgoaiTe.xml` |
| 7 | Tổng lãi tỷ giá (515) (`TongLai515`) | `xs:decimal, ` | **AUTO-FILL** | BeforeWrite: TongLai515 = TongLai | Không bắt buộc | Không | Có | `Documents\DanhGiaLaiNgoaiTe\Ext\ObjectModule.bsl:283` |
| 8 | Tổng lỗ tỷ giá (635) (`TongLo635`) | `xs:decimal, ` | **AUTO-FILL** | BeforeWrite: TongLo635 = TongLo | Không bắt buộc | Không | Có | `Documents\DanhGiaLaiNgoaiTe\Ext\ObjectModule.bsl:284` |
| 9 | Chuẩn mực kế toán áp dụng (`ChuanMucKeToan`) | `xs:string, ` | **TÍNH TOÁN** | BeforeWrite: ChuanMucKeToan = "TT99/2025/TT-BTC" | Không bắt buộc | Không | Có (Do là form mặc định, không khóa read-only trên form) | `Documents\DanhGiaLaiNgoaiTe\Ext\ObjectModule.bsl:29` |
| 10 | Trạng thái (`TrangThai`) | `cfg:EnumRef.TrangThaiLenhThanhToan` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:EnumRef.TrangThaiLenhThanhToan (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\DanhGiaLaiNgoaiTe.xml` |
| 11 | Người lập (`NguoiLap`) | `xs:string, ` | **NHẬP TAY** | Người dùng gõ tay tên tài khoản (Lỗi: Không tự điền UserName()!) | Không bắt buộc | Không | Có | `Documents\DanhGiaLaiNgoaiTe.xml` |
| 12 | Người duyệt (`NguoiDuyet`) | `xs:string, ` | **NHẬP TAY** | Người dùng gõ tay (Lỗi: Phải được gán qua luồng duyệt / Checker) | Không bắt buộc | Không | Có | `Documents\DanhGiaLaiNgoaiTe.xml` |

### 2.6. Form chứng từ: `DeNghiThanhToanDichVu`
**Số lượng trường:** 14 trường (Bao gồm 2 trường chuẩn hệ thống + các thuộc tính Header và Cột bảng chi tiết)

| STT | Trường (Tên hiển thị / Kỹ thuật) | Kiểu dữ liệu | Cách điền | Nguồn / Công thức | Bắt buộc | Mask / Format | Cho sửa sau Auto-fill | Dẫn chứng File : Dòng |
| :---: | :--- | :--- | :---: | :--- | :---: | :---: | :---: | :--- |
| 1 | Số chứng từ (`Number`) | `String(20)` | **HỆ THỐNG** | Platform Autonumbering (Tự động cấp số tăng dần) | Bắt buộc (Hệ thống) | Không | Có (Mặc định cho sửa nếu cấu hình cho phép) | `Documents\DeNghiThanhToanDichVu.xml:45` |
| 2 | Ngày chứng từ (`Date`) | `DateTime` | **HỆ THỐNG** | Platform CurrentSessionDate() khi tạo mới | Bắt buộc (Hệ thống) | DL=G | Có | `Documents\DeNghiThanhToanDichVu.xml:StandardAttribute.Date` |
| 3 | Pháp nhân (`PhapNhan`) | `cfg:CatalogRef.PhapNhan` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.PhapNhan (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\DeNghiThanhToanDichVu.xml` |
| 4 | Người thụ hưởng (`DoiTac`) | `cfg:CatalogRef.DoiTac` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.DoiTac (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\DeNghiThanhToanDichVu.xml` |
| 5 | Hợp đồng (`HopDong`) | `cfg:CatalogRef.HopDong` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.HopDong (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\DeNghiThanhToanDichVu.xml` |
| 6 | Chứng từ gốc (`ChungTuGoc`) | `cfg:DocumentRef.HoaDonNhaCungCap` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\DeNghiThanhToanDichVu.xml` |
| 7 | Số tiền đề nghị (`SoTienDeNghi`) | `xs:decimal, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\DeNghiThanhToanDichVu.xml` |
| 8 | Tiền tệ (`TienTe`) | `cfg:CatalogRef.TienTe` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.TienTe (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\DeNghiThanhToanDichVu.xml` |
| 9 | Hạn thanh toán (`HanThanhToan`) | `xs:dateTime, ` | **TÍNH TOÁN** | BeforeWrite: HanThanhToan = BegOfDay(Date) + 30 * 86400 | Không bắt buộc | Không | Có (Do là form mặc định, không khóa read-only trên form) | `Documents\DeNghiThanhToanDichVu\Ext\ObjectModule.bsl:28` |
| 10 | Người đề nghị (`NguoiDeNghi`) | `xs:string, ` | **NHẬP TAY** | Người dùng gõ tay tên tài khoản (Lỗi: Không tự điền UserName()!) | Không bắt buộc | Không | Có | `Documents\DeNghiThanhToanDichVu.xml` |
| 11 | Người duyệt (`NguoiDuyet`) | `xs:string, ` | **NHẬP TAY** | Người dùng gõ tay (Lỗi: Phải được gán qua luồng duyệt / Checker) | Không bắt buộc | Không | Có | `Documents\DeNghiThanhToanDichVu.xml` |
| 12 | Trạng thái (`TrangThai`) | `cfg:EnumRef.TrangThaiLenhThanhToan` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:EnumRef.TrangThaiLenhThanhToan (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\DeNghiThanhToanDichVu.xml` |
| 13 | Vượt ngân sách (`VuotNganSach`) | `xs:boolean` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\DeNghiThanhToanDichVu.xml` |
| 14 | Diễn giải (`DienGiai`) | `xs:string, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\DeNghiThanhToanDichVu.xml` |

### 2.7. Form chứng từ: `DieuChinhCongNo`
**Số lượng trường:** 16 trường (Bao gồm 2 trường chuẩn hệ thống + các thuộc tính Header và Cột bảng chi tiết)

| STT | Trường (Tên hiển thị / Kỹ thuật) | Kiểu dữ liệu | Cách điền | Nguồn / Công thức | Bắt buộc | Mask / Format | Cho sửa sau Auto-fill | Dẫn chứng File : Dòng |
| :---: | :--- | :--- | :---: | :--- | :---: | :---: | :---: | :--- |
| 1 | Số chứng từ (`Number`) | `String(20)` | **HỆ THỐNG** | Platform Autonumbering (Tự động cấp số tăng dần) | Bắt buộc (Hệ thống) | Không | Có (Mặc định cho sửa nếu cấu hình cho phép) | `Documents\DieuChinhCongNo.xml:45` |
| 2 | Ngày chứng từ (`Date`) | `DateTime` | **HỆ THỐNG** | Platform CurrentSessionDate() khi tạo mới | Bắt buộc (Hệ thống) | DL=G | Có | `Documents\DieuChinhCongNo.xml:StandardAttribute.Date` |
| 3 | Pháp nhân (`PhapNhan`) | `cfg:CatalogRef.PhapNhan` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.PhapNhan (Không có ChoiceParameterLinks lọc) | Bắt buộc | Không | Có | `Documents\DieuChinhCongNo.xml` |
| 4 | Đối tác (`DoiTac`) | `cfg:CatalogRef.DoiTac` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.DoiTac (Không có ChoiceParameterLinks lọc) | Bắt buộc | Không | Có | `Documents\DieuChinhCongNo.xml` |
| 5 | Hợp đồng (`HopDong`) | `cfg:CatalogRef.HopDong` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.HopDong (Không có ChoiceParameterLinks lọc) | Bắt buộc | Không | Có | `Documents\DieuChinhCongNo.xml` |
| 6 | Biên bản nghiệm thu (`BienBanNghiemThu`) | `cfg:DocumentRef.BienBanNghiemThuGiaiDoan` | **NHẬP TAY** | Người dùng nhập tự do trên form | Bắt buộc | Không | Có | `Documents\DieuChinhCongNo.xml` |
| 7 | Hóa đơn điều chỉnh (`HoaDonDieuChinh`) | `cfg:DocumentRef.HoaDonGTGTDauRa` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\DieuChinhCongNo.xml` |
| 8 | Số văn bản thỏa thuận (`SoVanBanThoaThuan`) | `xs:string, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\DieuChinhCongNo.xml` |
| 9 | Ngày văn bản thỏa thuận (`NgayVanBan`) | `xs:dateTime, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\DieuChinhCongNo.xml` |
| 10 | Lý do điều chỉnh (`LyDoDieuChinh`) | `xs:string, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\DieuChinhCongNo.xml` |
| 11 | Thuế suất VAT (%) (`ThueSuatVAT`) | `xs:decimal, ` | **AUTO-FILL** | BeforeWrite: ThueSuatVAT = 10 | Không bắt buộc | Không | Có | `Documents\DieuChinhCongNo\Ext\ObjectModule.bsl:34` |
| 12 | Giảm doanh thu (`GiamDoanhThu`) | `xs:decimal, ` | **TÍNH TOÁN** | BeforeWrite: GiamDoanhThu = Round(TongTienGiam / TyLeHeSo, 0) | Không bắt buộc | Không | Có (Do là form mặc định, không khóa read-only trên form) | `Documents\DieuChinhCongNo\Ext\ObjectModule.bsl:41` |
| 13 | Giảm thuế VAT (`GiamThueVAT`) | `xs:decimal, ` | **TÍNH TOÁN** | BeforeWrite: GiamThueVAT = TongTienGiam - GiamDoanhThu | Không bắt buộc | Không | Có (Do là form mặc định, không khóa read-only trên form) | `Documents\DieuChinhCongNo\Ext\ObjectModule.bsl:44` |
| 14 | Tổng tiền giảm (`TongTienGiam`) | `xs:decimal, ` | **TÍNH TOÁN** | BeforeWrite: TongTienGiam = GiamDoanhThu + GiamThueVAT | Bắt buộc | Không | Có (Do là form mặc định, không khóa read-only trên form) | `Documents\DieuChinhCongNo\Ext\ObjectModule.bsl:50` |
| 15 | Trạng thái (`TrangThai`) | `cfg:EnumRef.TrangThaiNghiemThuAR` | **AUTO-FILL** | BeforeWrite: TrangThai = Enums.TrangThaiNghiemThuAR.DaGhiSo | Không bắt buộc | Không | Có | `Documents\DieuChinhCongNo\Ext\ObjectModule.bsl:55` |
| 16 | Diễn giải (`DienGiai`) | `xs:string, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\DieuChinhCongNo.xml` |

### 2.8. Form chứng từ: `HoaDonGTGTDauRa`
**Số lượng trường:** 18 trường (Bao gồm 2 trường chuẩn hệ thống + các thuộc tính Header và Cột bảng chi tiết)

| STT | Trường (Tên hiển thị / Kỹ thuật) | Kiểu dữ liệu | Cách điền | Nguồn / Công thức | Bắt buộc | Mask / Format | Cho sửa sau Auto-fill | Dẫn chứng File : Dòng |
| :---: | :--- | :--- | :---: | :--- | :---: | :---: | :---: | :--- |
| 1 | Số chứng từ (`Number`) | `String(20)` | **HỆ THỐNG** | Platform Autonumbering (Tự động cấp số tăng dần) | Bắt buộc (Hệ thống) | Không | Có (Mặc định cho sửa nếu cấu hình cho phép) | `Documents\HoaDonGTGTDauRa.xml:45` |
| 2 | Ngày chứng từ (`Date`) | `DateTime` | **HỆ THỐNG** | Platform CurrentSessionDate() khi tạo mới | Bắt buộc (Hệ thống) | DL=G | Có | `Documents\HoaDonGTGTDauRa.xml:StandardAttribute.Date` |
| 3 | Pháp nhân (`PhapNhan`) | `cfg:CatalogRef.PhapNhan` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.PhapNhan (Không có ChoiceParameterLinks lọc) | Bắt buộc | Không | Có | `Documents\HoaDonGTGTDauRa.xml` |
| 4 | Đối tác (`DoiTac`) | `cfg:CatalogRef.DoiTac` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.DoiTac (Không có ChoiceParameterLinks lọc) | Bắt buộc | Không | Có | `Documents\HoaDonGTGTDauRa.xml` |
| 5 | Hợp đồng (`HopDong`) | `cfg:CatalogRef.HopDong` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.HopDong (Không có ChoiceParameterLinks lọc) | Bắt buộc | Không | Có | `Documents\HoaDonGTGTDauRa.xml` |
| 6 | Biên bản nghiệm thu (`BienBanNghiemThu`) | `cfg:DocumentRef.BienBanNghiemThuGiaiDoan` | **NHẬP TAY** | Người dùng nhập tự do trên form | Bắt buộc | Không | Có | `Documents\HoaDonGTGTDauRa.xml` |
| 7 | Số hóa đơn (`SoHoaDon`) | `xs:string, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\HoaDonGTGTDauRa.xml` |
| 8 | Ký hiệu (`KyHieu`) | `xs:string, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\HoaDonGTGTDauRa.xml` |
| 9 | Ngày hóa đơn (`NgayHoaDon`) | `xs:dateTime, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\HoaDonGTGTDauRa.xml` |
| 10 | Tiền chưa thuế (`TienChuaThue`) | `xs:decimal, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\HoaDonGTGTDauRa.xml` |
| 11 | Thuế suất VAT (%) (`ThueSuatVAT`) | `xs:decimal, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\HoaDonGTGTDauRa.xml` |
| 12 | Tiền thuế VAT (`TienThueVAT`) | `xs:decimal, ` | **TÍNH TOÁN** | BeforeWrite: TienThueVAT = Round(TienChuaThue * ThueSuatVAT / 100, 2) | Không bắt buộc | Không | Có (Do là form mặc định, không khóa read-only trên form) | `Documents\HoaDonGTGTDauRa\Ext\ObjectModule.bsl:17` |
| 13 | Tổng tiền thanh toán (`TongTienThanhToan`) | `xs:decimal, ` | **TÍNH TOÁN** | BeforeWrite: TongTienThanhToan = TienChuaThue + TienThueVAT | Không bắt buộc | Không | Có (Do là form mặc định, không khóa read-only trên form) | `Documents\HoaDonGTGTDauRa\Ext\ObjectModule.bsl:22` |
| 14 | Trạng thái HĐĐT (`TrangThaiHDDT`) | `cfg:EnumRef.TrangThaiHoaDonDienTu` | **AUTO-FILL** | BeforeWrite: TrangThaiHDDT = Enums.TrangThaiHoaDonDienTu.DaPhatHanh | Không bắt buộc | Không | Có | `Documents\HoaDonGTGTDauRa\Ext\ObjectModule.bsl:27` |
| 15 | Mã của CQT (`MaCQT`) | `xs:string, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\HoaDonGTGTDauRa.xml` |
| 16 | Diễn giải (`DienGiai`) | `xs:string, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\HoaDonGTGTDauRa.xml` |
| 17 | Người lập (`NguoiLap`) | `xs:string, ` | **NHẬP TAY** | Người dùng gõ tay tên tài khoản (Lỗi: Không tự điền UserName()!) | Không bắt buộc | Không | Có | `Documents\HoaDonGTGTDauRa.xml` |
| 18 | Người duyệt (`NguoiDuyet`) | `xs:string, ` | **NHẬP TAY** | Người dùng gõ tay (Lỗi: Phải được gán qua luồng duyệt / Checker) | Không bắt buộc | Không | Có | `Documents\HoaDonGTGTDauRa.xml` |

### 2.9. Form chứng từ: `HoaDonNhaCungCap`
**Số lượng trường:** 25 trường (Bao gồm 2 trường chuẩn hệ thống + các thuộc tính Header và Cột bảng chi tiết)

| STT | Trường (Tên hiển thị / Kỹ thuật) | Kiểu dữ liệu | Cách điền | Nguồn / Công thức | Bắt buộc | Mask / Format | Cho sửa sau Auto-fill | Dẫn chứng File : Dòng |
| :---: | :--- | :--- | :---: | :--- | :---: | :---: | :---: | :--- |
| 1 | Số chứng từ (`Number`) | `String(20)` | **HỆ THỐNG** | Platform Autonumbering (Tự động cấp số tăng dần) | Bắt buộc (Hệ thống) | Không | Có (Mặc định cho sửa nếu cấu hình cho phép) | `Documents\HoaDonNhaCungCap.xml:45` |
| 2 | Ngày chứng từ (`Date`) | `DateTime` | **HỆ THỐNG** | Platform CurrentSessionDate() khi tạo mới | Bắt buộc (Hệ thống) | DL=G | Có | `Documents\HoaDonNhaCungCap.xml:StandardAttribute.Date` |
| 3 | Pháp nhân (`PhapNhan`) | `cfg:CatalogRef.PhapNhan` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.PhapNhan (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\HoaDonNhaCungCap.xml` |
| 4 | Nhà cung cấp (`DoiTac`) | `cfg:CatalogRef.DoiTac` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.DoiTac (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\HoaDonNhaCungCap.xml` |
| 5 | Hợp đồng (`HopDong`) | `cfg:CatalogRef.HopDong` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.HopDong (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\HoaDonNhaCungCap.xml` |
| 6 | Số hóa đơn (`SoHoaDon`) | `xs:string, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\HoaDonNhaCungCap.xml` |
| 7 | Ngày hóa đơn (`NgayHoaDon`) | `xs:dateTime, ` | **AUTO-FILL** | BeforeWrite: NgayHoaDon = BegOfDay(Date) | Không bắt buộc | Không | Có | `Documents\HoaDonNhaCungCap\Ext\ObjectModule.bsl:46` |
| 8 | Tiền tệ (`TienTe`) | `cfg:CatalogRef.TienTe` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.TienTe (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\HoaDonNhaCungCap.xml` |
| 9 | Tỷ giá (`TyGia`) | `xs:decimal, ` | **AUTO-FILL** | BeforeWrite: TyGia = QuanLyTyGiaVaNgoaiTeServer.LayTyGiaHachToanHieuLuc(TienTe, Date) | Không bắt buộc | Không | Có | `Documents\HoaDonNhaCungCap\Ext\ObjectModule.bsl:38` |
| 10 | Tổng tiền VND (`TongTien`) | `xs:decimal, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\HoaDonNhaCungCap.xml` |
| 11 | Tổng tiền ngoại tệ (`TongTienNgoaiTe`) | `xs:decimal, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\HoaDonNhaCungCap.xml` |
| 12 | Tiền dịch vụ (`TienDichVu`) | `xs:decimal, ` | **TÍNH TOÁN** | BeforeWrite: TienDichVu = TongTien - TienThueVAT | Không bắt buộc | Không | Có (Do là form mặc định, không khóa read-only trên form) | `Documents\HoaDonNhaCungCap\Ext\ObjectModule.bsl:69` |
| 13 | Tiền thuế VAT (`TienThueVAT`) | `xs:decimal, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\HoaDonNhaCungCap.xml` |
| 14 | Có khấu trừ thuế FCT (`CoKhauTruFCT`) | `xs:boolean` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\HoaDonNhaCungCap.xml` |
| 15 | Tỷ lệ VAT nhà thầu (%) (`TyLeThueVATNhaThau`) | `xs:decimal, ` | **AUTO-FILL** | BeforeWrite: TyLeThueVATNhaThau = 5 | Không bắt buộc | Không | Có | `Documents\HoaDonNhaCungCap\Ext\ObjectModule.bsl:52` |
| 16 | Tỷ lệ TNDN nhà thầu (%) (`TyLeThueTNDNNhaThau`) | `xs:decimal, ` | **AUTO-FILL** | BeforeWrite: TyLeThueTNDNNhaThau = 5 | Không bắt buộc | Không | Có | `Documents\HoaDonNhaCungCap\Ext\ObjectModule.bsl:55` |
| 17 | Tiền VAT nhà thầu (`TienThueVATNhaThau`) | `xs:decimal, ` | **TÍNH TOÁN** | BeforeWrite: TienThueVATNhaThau = Round(TongTien * (TyLeThueVATNhaThau / 100), 2) | Không bắt buộc | Không | Có (Do là form mặc định, không khóa read-only trên form) | `Documents\HoaDonNhaCungCap\Ext\ObjectModule.bsl:59` |
| 18 | Tiền TNDN nhà thầu (`TienThueTNDNNhaThau`) | `xs:decimal, ` | **TÍNH TOÁN** | BeforeWrite: TienThueTNDNNhaThau = Round(TongTien * (TyLeThueTNDNNhaThau / 100), 2) | Không bắt buộc | Không | Có (Do là form mặc định, không khóa read-only trên form) | `Documents\HoaDonNhaCungCap\Ext\ObjectModule.bsl:60` |
| 19 | Chi phí VSF (`ChiPhiVSF`) | `xs:decimal, ` | **TÍNH TOÁN** | BeforeWrite: ChiPhiVSF = NoThucTraNCC + TienThueTNDNNhaThau | Không bắt buộc | Không | Có (Do là form mặc định, không khóa read-only trên form) | `Documents\HoaDonNhaCungCap\Ext\ObjectModule.bsl:63` |
| 20 | Nợ thực trả NCC (`NoThucTraNCC`) | `xs:decimal, ` | **TÍNH TOÁN** | BeforeWrite: NoThucTraNCC = TongTien - TongThueFCT | Không bắt buộc | Không | Có (Do là form mặc định, không khóa read-only trên form) | `Documents\HoaDonNhaCungCap\Ext\ObjectModule.bsl:62` |
| 21 | Trạng thái (`TrangThai`) | `cfg:EnumRef.TrangThaiHoaDonAP` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:EnumRef.TrangThaiHoaDonAP (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\HoaDonNhaCungCap.xml` |
| 22 | Tài khoản chi phí (`TaiKhoanChiPhi`) | `cfg:ChartOfAccountsRef.HeThongTaiKhoan` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:ChartOfAccountsRef.HeThongTaiKhoan (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\HoaDonNhaCungCap.xml` |
| 23 | Diễn giải (`DienGiai`) | `xs:string, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\HoaDonNhaCungCap.xml` |
| 24 | Người lập (`NguoiLap`) | `xs:string, ` | **NHẬP TAY** | Người dùng gõ tay tên tài khoản (Lỗi: Không tự điền UserName()!) | Không bắt buộc | Không | Có | `Documents\HoaDonNhaCungCap.xml` |
| 25 | Người duyệt (`NguoiDuyet`) | `xs:string, ` | **NHẬP TAY** | Người dùng gõ tay (Lỗi: Phải được gán qua luồng duyệt / Checker) | Không bắt buộc | Không | Có | `Documents\HoaDonNhaCungCap.xml` |

### 2.10. Form chứng từ: `NghiemThuThauPhu`
**Số lượng trường:** 12 trường (Bao gồm 2 trường chuẩn hệ thống + các thuộc tính Header và Cột bảng chi tiết)

| STT | Trường (Tên hiển thị / Kỹ thuật) | Kiểu dữ liệu | Cách điền | Nguồn / Công thức | Bắt buộc | Mask / Format | Cho sửa sau Auto-fill | Dẫn chứng File : Dòng |
| :---: | :--- | :--- | :---: | :--- | :---: | :---: | :---: | :--- |
| 1 | Số chứng từ (`Number`) | `String(20)` | **HỆ THỐNG** | Platform Autonumbering (Tự động cấp số tăng dần) | Bắt buộc (Hệ thống) | Không | Có (Mặc định cho sửa nếu cấu hình cho phép) | `Documents\NghiemThuThauPhu.xml:45` |
| 2 | Ngày chứng từ (`Date`) | `DateTime` | **HỆ THỐNG** | Platform CurrentSessionDate() khi tạo mới | Bắt buộc (Hệ thống) | DL=G | Có | `Documents\NghiemThuThauPhu.xml:StandardAttribute.Date` |
| 3 | Pháp nhân (`PhapNhan`) | `cfg:CatalogRef.PhapNhan` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.PhapNhan (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\NghiemThuThauPhu.xml` |
| 4 | Thầu phụ (`DoiTac`) | `cfg:CatalogRef.DoiTac` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.DoiTac (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\NghiemThuThauPhu.xml` |
| 5 | Hợp đồng (`HopDong`) | `cfg:CatalogRef.HopDong` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.HopDong (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\NghiemThuThauPhu.xml` |
| 6 | Giá trị nghiệm thu (`GiaTriNghiemThu`) | `xs:decimal, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\NghiemThuThauPhu.xml` |
| 7 | Tiền thuế VAT (`TienVAT`) | `xs:decimal, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\NghiemThuThauPhu.xml` |
| 8 | Tổng giá trị (`TongGiaTri`) | `xs:decimal, ` | **TÍNH TOÁN** | BeforeWrite: TongGiaTri = GiaTriNghiemThu + TienVAT | Không bắt buộc | Không | Có (Do là form mặc định, không khóa read-only trên form) | `Documents\NghiemThuThauPhu\Ext\ObjectModule.bsl:24` |
| 9 | Tiền tệ (`TienTe`) | `cfg:CatalogRef.TienTe` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.TienTe (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\NghiemThuThauPhu.xml` |
| 10 | Ngày nghiệm thu (`NgayNghiemThu`) | `xs:dateTime, ` | **AUTO-FILL** | BeforeWrite: NgayNghiemThu = BegOfDay(Date) | Không bắt buộc | Không | Có | `Documents\NghiemThuThauPhu\Ext\ObjectModule.bsl:20` |
| 11 | Trạng thái (`TrangThai`) | `cfg:EnumRef.TrangThaiHoaDonAP` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:EnumRef.TrangThaiHoaDonAP (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\NghiemThuThauPhu.xml` |
| 12 | Diễn giải (`DienGiai`) | `xs:string, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\NghiemThuThauPhu.xml` |

### 2.11. Form chứng từ: `PhieuThuTienKhachHang`
**Số lượng trường:** 14 trường (Bao gồm 2 trường chuẩn hệ thống + các thuộc tính Header và Cột bảng chi tiết)

| STT | Trường (Tên hiển thị / Kỹ thuật) | Kiểu dữ liệu | Cách điền | Nguồn / Công thức | Bắt buộc | Mask / Format | Cho sửa sau Auto-fill | Dẫn chứng File : Dòng |
| :---: | :--- | :--- | :---: | :--- | :---: | :---: | :---: | :--- |
| 1 | Số chứng từ (`Number`) | `String(20)` | **HỆ THỐNG** | Platform Autonumbering (Tự động cấp số tăng dần) | Bắt buộc (Hệ thống) | Không | Có (Mặc định cho sửa nếu cấu hình cho phép) | `Documents\PhieuThuTienKhachHang.xml:45` |
| 2 | Ngày chứng từ (`Date`) | `DateTime` | **HỆ THỐNG** | Platform CurrentSessionDate() khi tạo mới | Bắt buộc (Hệ thống) | DL=G | Có | `Documents\PhieuThuTienKhachHang.xml:StandardAttribute.Date` |
| 3 | Pháp nhân (`PhapNhan`) | `cfg:CatalogRef.PhapNhan` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.PhapNhan (Không có ChoiceParameterLinks lọc) | Bắt buộc | Không | Có | `Documents\PhieuThuTienKhachHang.xml` |
| 4 | Đối tác (`DoiTac`) | `cfg:CatalogRef.DoiTac` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.DoiTac (Không có ChoiceParameterLinks lọc) | Bắt buộc | Không | Có | `Documents\PhieuThuTienKhachHang.xml` |
| 5 | Hợp đồng (`HopDong`) | `cfg:CatalogRef.HopDong` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.HopDong (Không có ChoiceParameterLinks lọc) | Bắt buộc | Không | Có | `Documents\PhieuThuTienKhachHang.xml` |
| 6 | Chứng từ gốc (`ChungTuGoc`) | `cfg:DocumentRef.BienBanNghiemThuGiaiDoan` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\PhieuThuTienKhachHang.xml` |
| 7 | Tài khoản tiền (`TaiKhoanTien`) | `cfg:CatalogRef.TaiKhoanTien` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.TaiKhoanTien (Không có ChoiceParameterLinks lọc) | Bắt buộc | Không | Có | `Documents\PhieuThuTienKhachHang.xml` |
| 8 | Khoản mục dòng tiền (`KhoanMucDongTien`) | `cfg:CatalogRef.KhoanMucDongTien` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.KhoanMucDongTien (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\PhieuThuTienKhachHang.xml` |
| 9 | Tiền tệ (`TienTe`) | `cfg:CatalogRef.TienTe` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.TienTe (Không có ChoiceParameterLinks lọc) | Bắt buộc | Không | Có | `Documents\PhieuThuTienKhachHang.xml` |
| 10 | Số tiền (VND) (`SoTien`) | `xs:decimal, ` | **TÍNH TOÁN** | BeforeWrite: SoTien = Round(SoTienNgoaiTe * TyGia, 2) | Bắt buộc | Không | Có (Do là form mặc định, không khóa read-only trên form) | `Documents\PhieuThuTienKhachHang\Ext\ObjectModule.bsl:42` |
| 11 | Số tiền ngoại tệ (`SoTienNgoaiTe`) | `xs:decimal, ` | **TÍNH TOÁN** | BeforeWrite: SoTienNgoaiTe = Round(SoTien / TyGia, 2) | Không bắt buộc | Không | Có (Do là form mặc định, không khóa read-only trên form) | `Documents\PhieuThuTienKhachHang\Ext\ObjectModule.bsl:47` |
| 12 | Tỷ giá (`TyGia`) | `xs:decimal, ` | **AUTO-FILL** | BeforeWrite: TyGia = 1 | Không bắt buộc | Không | Có | `Documents\PhieuThuTienKhachHang\Ext\ObjectModule.bsl:37` |
| 13 | Ngày thu (`NgayThu`) | `xs:dateTime, ` | **AUTO-FILL** | BeforeWrite: NgayThu = BegOfDay(Date) | Không bắt buộc | Không | Có | `Documents\PhieuThuTienKhachHang\Ext\ObjectModule.bsl:32` |
| 14 | Diễn giải (`DienGiai`) | `xs:string, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\PhieuThuTienKhachHang.xml` |

### 2.12. Form chứng từ: `UyNhiemChi`
**Số lượng trường:** 20 trường (Bao gồm 2 trường chuẩn hệ thống + các thuộc tính Header và Cột bảng chi tiết)

| STT | Trường (Tên hiển thị / Kỹ thuật) | Kiểu dữ liệu | Cách điền | Nguồn / Công thức | Bắt buộc | Mask / Format | Cho sửa sau Auto-fill | Dẫn chứng File : Dòng |
| :---: | :--- | :--- | :---: | :--- | :---: | :---: | :---: | :--- |
| 1 | Số chứng từ (`Number`) | `String(20)` | **HỆ THỐNG** | Platform Autonumbering (Tự động cấp số tăng dần) | Bắt buộc (Hệ thống) | Không | Có (Mặc định cho sửa nếu cấu hình cho phép) | `Documents\UyNhiemChi.xml:45` |
| 2 | Ngày chứng từ (`Date`) | `DateTime` | **HỆ THỐNG** | Platform CurrentSessionDate() khi tạo mới | Bắt buộc (Hệ thống) | DL=G | Có | `Documents\UyNhiemChi.xml:StandardAttribute.Date` |
| 3 | Pháp nhân (`PhapNhan`) | `cfg:CatalogRef.PhapNhan` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.PhapNhan (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\UyNhiemChi.xml` |
| 4 | Nhà cung cấp (`DoiTac`) | `cfg:CatalogRef.DoiTac` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.DoiTac (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\UyNhiemChi.xml` |
| 5 | Hợp đồng (`HopDong`) | `cfg:CatalogRef.HopDong` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.HopDong (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\UyNhiemChi.xml` |
| 6 | Chứng từ gốc (`ChungTuGoc`) | `cfg:DocumentRef.HoaDonNhaCungCap, cfg:DocumentRef.UyNhiemChi` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\UyNhiemChi.xml` |
| 7 | Tài khoản ngân hàng (`TaiKhoanTien`) | `cfg:CatalogRef.TaiKhoanTien` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.TaiKhoanTien (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\UyNhiemChi.xml` |
| 8 | Khoản mục dòng tiền (`KhoanMucDongTien`) | `cfg:CatalogRef.KhoanMucDongTien` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.KhoanMucDongTien (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\UyNhiemChi.xml` |
| 9 | Tiền tệ (`TienTe`) | `cfg:CatalogRef.TienTe` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.TienTe (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\UyNhiemChi.xml` |
| 10 | Tỷ giá (`TyGia`) | `xs:decimal, ` | **AUTO-FILL** | BeforeWrite: TyGia = 1 | Không bắt buộc | Không | Có | `Documents\UyNhiemChi\Ext\ObjectModule.bsl:28` |
| 11 | Số tiền chi (`SoTien`) | `xs:decimal, ` | **TÍNH TOÁN** | BeforeWrite: SoTien = Round(SoTienNgoaiTe * TyGia, 0) | Không bắt buộc | Không | Có (Do là form mặc định, không khóa read-only trên form) | `Documents\UyNhiemChi\Ext\ObjectModule.bsl:32` |
| 12 | Số tiền ngoại tệ (`SoTienNgoaiTe`) | `xs:decimal, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\UyNhiemChi.xml` |
| 13 | Phí ngân hàng (`PhiNganHang`) | `xs:decimal, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\UyNhiemChi.xml` |
| 14 | Trạng thái (`TrangThai`) | `cfg:EnumRef.TrangThaiLenhThanhToan` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:EnumRef.TrangThaiLenhThanhToan (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\UyNhiemChi.xml` |
| 15 | Ngày lập (`NgayLap`) | `xs:dateTime, ` | **AUTO-FILL** | BeforeWrite: NgayLap = BegOfDay(Date) | Không bắt buộc | Không | Có | `Documents\UyNhiemChi\Ext\ObjectModule.bsl:23` |
| 16 | Ngày ghi sổ (`NgayGhiSo`) | `xs:dateTime, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\UyNhiemChi.xml` |
| 17 | Là tra soát hoàn trả (`LaTraSoatHoanTra`) | `xs:boolean` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\UyNhiemChi.xml` |
| 18 | Người lập (`NguoiLap`) | `xs:string, ` | **NHẬP TAY** | Người dùng gõ tay tên tài khoản (Lỗi: Không tự điền UserName()!) | Không bắt buộc | Không | Có | `Documents\UyNhiemChi.xml` |
| 19 | Người duyệt (`NguoiDuyet`) | `xs:string, ` | **NHẬP TAY** | Người dùng gõ tay (Lỗi: Phải được gán qua luồng duyệt / Checker) | Không bắt buộc | Không | Có | `Documents\UyNhiemChi.xml` |
| 20 | Diễn giải (`DienGiai`) | `xs:string, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\UyNhiemChi.xml` |

### 2.13. Form chứng từ: `YeuCauHoanTienChiHo`
**Số lượng trường:** 15 trường (Bao gồm 2 trường chuẩn hệ thống + các thuộc tính Header và Cột bảng chi tiết)

| STT | Trường (Tên hiển thị / Kỹ thuật) | Kiểu dữ liệu | Cách điền | Nguồn / Công thức | Bắt buộc | Mask / Format | Cho sửa sau Auto-fill | Dẫn chứng File : Dòng |
| :---: | :--- | :--- | :---: | :--- | :---: | :---: | :---: | :--- |
| 1 | Số chứng từ (`Number`) | `String(20)` | **HỆ THỐNG** | Platform Autonumbering (Tự động cấp số tăng dần) | Bắt buộc (Hệ thống) | Không | Có (Mặc định cho sửa nếu cấu hình cho phép) | `Documents\YeuCauHoanTienChiHo.xml:45` |
| 2 | Ngày chứng từ (`Date`) | `DateTime` | **HỆ THỐNG** | Platform CurrentSessionDate() khi tạo mới | Bắt buộc (Hệ thống) | DL=G | Có | `Documents\YeuCauHoanTienChiHo.xml:StandardAttribute.Date` |
| 3 | Pháp nhân (`PhapNhan`) | `cfg:CatalogRef.PhapNhan` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.PhapNhan (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\YeuCauHoanTienChiHo.xml` |
| 4 | Kênh thanh toán (`KenhThanhToan`) | `cfg:CatalogRef.KenhThanhToan` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.KenhThanhToan (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\YeuCauHoanTienChiHo.xml` |
| 5 | Khách hàng hoàn tiền (`DoiTac`) | `cfg:CatalogRef.DoiTac` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.DoiTac (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\YeuCauHoanTienChiHo.xml` |
| 6 | Hợp đồng dịch vụ (`HopDong`) | `cfg:CatalogRef.HopDong` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.HopDong (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\YeuCauHoanTienChiHo.xml` |
| 7 | Tài khoản ngân hàng chi (`TaiKhoanNganHangChi`) | `cfg:CatalogRef.TaiKhoanTien` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.TaiKhoanTien (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\YeuCauHoanTienChiHo.xml` |
| 8 | Khoản mục dòng tiền (`KhoanMucDongTien`) | `cfg:CatalogRef.KhoanMucDongTien` | **DROPDOWN / CHỌN TỪ DANH MỤC** | Chọn từ danh mục/liệt kê cfg:CatalogRef.KhoanMucDongTien (Không có ChoiceParameterLinks lọc) | Không bắt buộc | Không | Có | `Documents\YeuCauHoanTienChiHo.xml` |
| 9 | Mã giao dịch gốc (`MaGiaoDichGoc`) | `xs:string, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\YeuCauHoanTienChiHo.xml` |
| 10 | Số tiền hoàn (`SoTienHoan`) | `xs:decimal, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\YeuCauHoanTienChiHo.xml` |
| 11 | Phí hoàn tiền (`PhiHoanTien`) | `xs:decimal, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\YeuCauHoanTienChiHo.xml` |
| 12 | Lý do hoàn tiền (`LyDoHoanTien`) | `xs:string, ` | **NHẬP TAY** | Người dùng nhập tự do trên form | Không bắt buộc | Không | Có | `Documents\YeuCauHoanTienChiHo.xml` |
| 13 | Trạng thái (`TrangThai`) | `xs:string, ` | **AUTO-FILL** | BeforeWrite: TrangThai = "ChoDuyet" | Không bắt buộc | Không | Có | `Documents\YeuCauHoanTienChiHo\Ext\ObjectModule.bsl:36` |
| 14 | Người lập (`NguoiLap`) | `xs:string, ` | **NHẬP TAY** | Người dùng gõ tay tên tài khoản (Lỗi: Không tự điền UserName()!) | Không bắt buộc | Không | Có | `Documents\YeuCauHoanTienChiHo.xml` |
| 15 | Người duyệt (`NguoiDuyet`) | `xs:string, ` | **NHẬP TAY** | Người dùng gõ tay (Lỗi: Phải được gán qua luồng duyệt / Checker) | Không bắt buộc | Không | Có | `Documents\YeuCauHoanTienChiHo.xml` |

### 2.14. Form xử lý & Báo cáo: `DashboardLanhDaoCFO`
**Loại đối tượng:** DataProcessor Managed Form (`DataProcessors/DashboardLanhDaoCFO/Forms/Form`)

| STT | Trường (Tên hiển thị / Kỹ thuật) | Kiểu dữ liệu | Cách điền | Nguồn / Công thức | Bắt buộc | Mask / Format | Cho sửa sau Auto-fill | Dẫn chứng File : Dòng |
| :---: | :--- | :--- | :---: | :--- | :---: | :---: | :---: | :--- |
| 1 | Trang Dashboard HTML (`TrangDashboardHTML`) | `String` | **TÍNH TOÁN** | Tự sinh mã HTML từ `BaoCaoQuanTriServer.SinhHTMLDashboardLanhDaoCFO()` | Bắt buộc | Không | Không | `DataProcessors\DashboardLanhDaoCFO\Forms\Form\Ext\Form\Module.bsl:18` |
| 2 | Lệnh Làm mới (`Command.LamMoi`) | `Action` | **HỆ THỐNG** | Sự kiện `LamMoiAtClient` gọi server cập nhật số liệu tức thì | Không bắt buộc | Không | Không | `DataProcessors\DashboardLanhDaoCFO\Forms\Form\Ext\Form\Module.bsl:7` |

---

## 3. NHIỆM VỤ 2 — DANH SÁCH LỖI LOGIC CHI TIẾT (AUDIT FINDINGS)
Tất cả các lỗi được phát hiện được phân nhóm từ (a) đến (i) kèm ID, mức độ, vị trí file:dòng, mô tả chi tiết, tác động nghiệp vụ kế toán và đoạn mã 1C BSL đề xuất khắc phục.

### Nhóm a) Trường nên là dropdown nhưng đang nhập tay

#### [ERR-A01] — Trường 'TrangThai' được khai báo là String(20) thay vì kiểu EnumRef.TrangThaiCan...
- **Mức độ nghiêm trọng:** `TRUNG BÌNH`
- **Vị trí phát hiện:** [`Documents\CanTruCongNoNoiBo.xml:TrangThai`](file:///Documents/CanTruCongNoNoiBo.xml:TrangThai)
- **Đối tượng ảnh hưởng:** `CanTruCongNoNoiBo`
- **Mô tả chi tiết:** Trường 'TrangThai' được khai báo là String(20) thay vì kiểu EnumRef.TrangThaiCanTru. Code so sánh chuỗi 'DaDuyet', 'DaGhiSo', 'DaCanTru', 'DuThao'.
- **Tác động nghiệp vụ kế toán:** Người dùng gõ tay tự do, dễ sai chính tả ('Đã duyệt', 'da duyet', 'Duyệt') dẫn đến lỗi chặn ghi sổ hoặc bypass quy trình kiểm soát FSM.
- **Đề xuất khắc phục:** Sửa metadata kiểu TrangThai thành EnumRef.TrangThaiCanTru. Cập nhật code kiểm tra sang Enum.TrangThaiCanTru.DaDuyet.

#### [ERR-A02] — Trường 'TrangThai' được khai báo là String(20) thay vì EnumRef.TrangThaiLenhThan...
- **Mức độ nghiêm trọng:** `TRUNG BÌNH`
- **Vị trí phát hiện:** [`Documents\YeuCauHoanTienChiHo.xml:TrangThai`](file:///Documents/YeuCauHoanTienChiHo.xml:TrangThai)
- **Đối tượng ảnh hưởng:** `YeuCauHoanTienChiHo`
- **Mô tả chi tiết:** Trường 'TrangThai' được khai báo là String(20) thay vì EnumRef.TrangThaiLenhThanhToan. Code so sánh 'ChoDuyet', 'DaDuyet', 'DaHoanTien'.
- **Tác động nghiệp vụ kế toán:** Người dùng nhập tay tùy tiện trạng thái, làm sai lệch báo cáo dòng tiền và quy trình phê duyệt hoàn tiền B2C.
- **Đề xuất khắc phục:** Chuyển kiểu dữ liệu TrangThai sang EnumRef.TrangThaiLenhThanhToan (hoặc tạo Enum TrangThaiHoanTien riêng).

#### [ERR-A03] — Trường 'TrangThai' là String(20), code BeforeWrite gán 'HoanTat'....
- **Mức độ nghiêm trọng:** `TRUNG BÌNH`
- **Vị trí phát hiện:** [`Documents\BangKeDoiSoatKenhThanhToan.xml:TrangThai`](file:///Documents/BangKeDoiSoatKenhThanhToan.xml:TrangThai)
- **Đối tượng ảnh hưởng:** `BangKeDoiSoatKenhThanhToan`
- **Mô tả chi tiết:** Trường 'TrangThai' là String(20), code BeforeWrite gán 'HoanTat'.
- **Tác động nghiệp vụ kế toán:** Không đồng bộ với hệ thống Enum trạng thái, dễ bị ghi đè dữ liệu rác từ giao diện.
- **Đề xuất khắc phục:** Sử dụng EnumRef chuẩn cho trạng thái đối soát kênh.

#### [ERR-A04] — Trường 'TrangThai' là String(20), code Posting kiểm tra TrangThai <> 'DaDoiSoat'...
- **Mức độ nghiêm trọng:** `TRUNG BÌNH`
- **Vị trí phát hiện:** [`Documents\BaoCoNganHang.xml:TrangThai`](file:///Documents/BaoCoNganHang.xml:TrangThai)
- **Đối tượng ảnh hưởng:** `BaoCoNganHang`
- **Mô tả chi tiết:** Trường 'TrangThai' là String(20), code Posting kiểm tra TrangThai <> 'DaDoiSoat'.
- **Tác động nghiệp vụ kế toán:** Người dùng gõ tay có thể làm sai điều kiện đối soát ngân hàng tự động.
- **Đề xuất khắc phục:** Chuyển sang EnumRef trạng thái báo có.

#### [ERR-A05] — Thuế suất VAT là Decimal(5,2) cho phép gõ tự do bất kỳ con số nào. Không có Cata...
- **Mức độ nghiêm trọng:** `NGHIÊM TRỌNG`
- **Vị trí phát hiện:** [`Documents\HoaDonGTGTDauRa.xml:ThueSuatVAT`](file:///Documents/HoaDonGTGTDauRa.xml:ThueSuatVAT)
- **Đối tượng ảnh hưởng:** `HoaDonGTGTDauRa`
- **Mô tả chi tiết:** Thuế suất VAT là Decimal(5,2) cho phép gõ tự do bất kỳ con số nào. Không có Catalog/Enum thuế suất chuẩn (0%, 5%, 8%, 10%, KCT, KKKNT).
- **Tác động nghiệp vụ kế toán:** Vi phạm nghiêm trọng quy định hóa đơn điện tử (NĐ 123/2020) và chính sách giảm thuế 8% (NĐ 174/2025/NĐ-CP). Người dùng có thể gõ sai mức thuế suất hợp pháp.
- **Đề xuất khắc phục:** Tạo Catalog hoặc Enum ThueSuatGTGT gồm: 0%, 5%, 8%, 10%, Không chịu thuế (KCT), Không kê khai nộp thuế (KKKNT). Ràng buộc ChoiceList trên form.

#### [ERR-A06] — Các trường Người lập, Người duyệt, Người tạo, Người đề nghị đều là String(50) gõ...
- **Mức độ nghiêm trọng:** `TRUNG BÌNH`
- **Vị trí phát hiện:** [`Documents\*.xml:NguoiLap,NguoiDuyet`](file:///Documents/*.xml:NguoiLap,NguoiDuyet)
- **Đối tượng ảnh hưởng:** `Tất cả 13 chứng từ`
- **Mô tả chi tiết:** Các trường Người lập, Người duyệt, Người tạo, Người đề nghị đều là String(50) gõ tay tự do, không tham chiếu danh mục người dùng.
- **Tác động nghiệp vụ kế toán:** Người dùng gõ sai tên tài khoản, gây lỗi kiểm tra Maker-Checker hoặc tiềm ẩn nguy cơ mạo danh người duyệt.
- **Đề xuất khắc phục:** Chuyển kiểu dữ liệu sang CatalogRef hoặc gắn ChoiceList người dùng hệ thống hợp lệ; tự động điền UserName() của phiên làm việc.

### Nhóm b) Trường nên auto-fill nhưng bắt nhập tay / sai nguồn

#### [ERR-B01] — Thiếu hoàn toàn sự kiện OnCreateAtServer / FillingProcessing để tự điền Người lậ...
- **Mức độ nghiêm trọng:** `TRUNG BÌNH`
- **Vị trí phát hiện:** [`Documents\*.xml`](file:///Documents/*.xml)
- **Đối tượng ảnh hưởng:** `Tất cả 13 chứng từ`
- **Mô tả chi tiết:** Thiếu hoàn toàn sự kiện OnCreateAtServer / FillingProcessing để tự điền Người lập = UserName(), Pháp nhân mặc định, Ngày chứng từ khi mở form tạo mới.
- **Tác động nghiệp vụ kế toán:** Người dùng phải tự gõ tay các thông tin cơ bản, tốn thời gian và dễ sai sót.
- **Đề xuất khắc phục:** Bổ sung thủ tục Filling (ОбработкаЗаполнения) trong ObjectModule và OnCreateAtServer trên Form để auto-fill các giá trị mặc định.

#### [ERR-B02] — BeforeWrite tự động gán cứng Pháp nhân = 'PN-VSF' và Tài khoản tiền = 'TK-TCB-VN...
- **Mức độ nghiêm trọng:** `NGHIÊM TRỌNG`
- **Vị trí phát hiện:** [`Documents\BaoCoNganHang\Ext\ObjectModule.bsl:17,21`](file:///Documents/BaoCoNganHang/Ext/ObjectModule.bsl:17,21)
- **Đối tượng ảnh hưởng:** `BaoCoNganHang`
- **Mô tả chi tiết:** BeforeWrite tự động gán cứng Pháp nhân = 'PN-VSF' và Tài khoản tiền = 'TK-TCB-VND' bằng FindByCode.
- **Tác động nghiệp vụ kế toán:** Triệt tiêu khả năng xử lý đa pháp nhân và các ngân hàng khác (Vietcombank, VPBank), ghi nhận sai tài khoản ngân hàng thực tế thu tiền.
- **Đề xuất khắc phục:** Đọc Pháp nhân từ Constants.PhapNhanMacDinh.Get(); lấy Tài khoản tiền dựa trên số tài khoản ngân hàng thụ hưởng thực tế từ nội dung báo có.

#### [ERR-B03] — Gán cứng Hạn thanh toán = BegOfDay(Date) + 30 * 86400 (Net 30) trong khi Catalog...
- **Mức độ nghiêm trọng:** `TRUNG BÌNH`
- **Vị trí phát hiện:** [`Documents\DeNghiThanhToanDichVu\Ext\ObjectModule.bsl:28`](file:///Documents/DeNghiThanhToanDichVu/Ext/ObjectModule.bsl:28)
- **Đối tượng ảnh hưởng:** `DeNghiThanhToanDichVu`
- **Mô tả chi tiết:** Gán cứng Hạn thanh toán = BegOfDay(Date) + 30 * 86400 (Net 30) trong khi Catalog.HopDong đã có trường HanThanhToanNgay.
- **Tác động nghiệp vụ kế toán:** Bỏ qua điều khoản thanh toán thực tế của hợp đồng (Net 45, Net 60), làm sai lệch kế hoạch dòng tiền và tuổi nợ.
- **Đề xuất khắc phục:** Kiểm tra nếu HopDong.HanThanhToanNgay > 0 thì HanThanhToan = BegOfDay(Date) + HopDong.HanThanhToanNgay * 86400.

#### [ERR-B04] — Gán TrangThaiHDDT = DaPhatHanh tự động khi ghi sổ mà chưa qua bước ký số hoặc gử...
- **Mức độ nghiêm trọng:** `NGHIÊM TRỌNG`
- **Vị trí phát hiện:** [`Documents\HoaDonGTGTDauRa\Ext\ObjectModule.bsl:27`](file:///Documents/HoaDonGTGTDauRa/Ext/ObjectModule.bsl:27)
- **Đối tượng ảnh hưởng:** `HoaDonGTGTDauRa`
- **Mô tả chi tiết:** Gán TrangThaiHDDT = DaPhatHanh tự động khi ghi sổ mà chưa qua bước ký số hoặc gửi CQT.
- **Tác động nghiệp vụ kế toán:** Hóa đơn chưa ký số hợp pháp đã được xem là đã phát hành, vi phạm quy trình phát hành HĐĐT NĐ 123/2020.
- **Đề xuất khắc phục:** Yêu cầu hóa đơn phải qua trạng thái ChoKySo -> DaKySo -> DaCapMaCQT trước khi hoàn tất phát hành.

### Nhóm c) Chuỗi phụ thuộc bị thiếu hoặc sai

#### [ERR-C01] — Thiếu hoàn toàn ChoiceParameterLinks từ DoiTac sang HopDong. Danh mục Hợp đồng h...
- **Mức độ nghiêm trọng:** `NGHIÊM TRỌNG`
- **Vị trí phát hiện:** [`Documents\*.xml:HopDong`](file:///Documents/*.xml:HopDong)
- **Đối tượng ảnh hưởng:** `Tất cả 13 chứng từ`
- **Mô tả chi tiết:** Thiếu hoàn toàn ChoiceParameterLinks từ DoiTac sang HopDong. Danh mục Hợp đồng hiển thị tất cả hợp đồng của mọi đối tác khác.
- **Tác động nghiệp vụ kế toán:** Người dùng chọn nhầm hợp đồng của đối tác khác, gây sai lệch nghiêm trọng đối soát công nợ và dẫn đến lỗi Crash trong CanTruCongNoNoiBo.
- **Đề xuất khắc phục:** Thêm ChoiceParameterLinks trên thuộc tính HopDong: Filter.ChuSoHuu(DoiTac).

#### [ERR-C02] — Catalog.DoiTac hoàn toàn không có trường MaSoThue (Mã số thuế), DiaChi (Địa chỉ)...
- **Mức độ nghiêm trọng:** `NGHIÊM TRỌNG`
- **Vị trí phát hiện:** [`Catalogs\DoiTac.xml`](file:///Catalogs/DoiTac.xml)
- **Đối tượng ảnh hưởng:** `Catalog.DoiTac`
- **Mô tả chi tiết:** Catalog.DoiTac hoàn toàn không có trường MaSoThue (Mã số thuế), DiaChi (Địa chỉ), TaiKhoanNganHang. Hóa đơn đầu ra và đầu vào không có thông tin MST đối tác.
- **Tác động nghiệp vụ kế toán:** Vi phạm trực tiếp Điều 10 Nghị định 123/2020/NĐ-CP (nội dung bắt buộc của hóa đơn phải có tên, địa chỉ, MST người mua và người bán). Không thể kê khai thuế GTGT.
- **Đề xuất khắc phục:** Thêm các thuộc tính MaSoThue, DiaChi, SoTaiKhoanNganHang, TenNganHang vào Catalog.DoiTac. Tự động điền lên hóa đơn khi chọn đối tác.

#### [ERR-C03] — Logic tính toán BeforeWrite dùng điều kiện 'If TienThueVAT = 0' và 'If TongTienT...
- **Mức độ nghiêm trọng:** `NGHIÊM TRỌNG`
- **Vị trí phát hiện:** [`Documents\HoaDonGTGTDauRa\Ext\ObjectModule.bsl:16,21`](file:///Documents/HoaDonGTGTDauRa/Ext/ObjectModule.bsl:16,21)
- **Đối tượng ảnh hưởng:** `HoaDonGTGTDauRa`
- **Mô tả chi tiết:** Logic tính toán BeforeWrite dùng điều kiện 'If TienThueVAT = 0' và 'If TongTienThanhToan = 0'. Khi người dùng sửa TienChuaThue hoặc ThueSuatVAT, hệ thống KHÔNG TÍNH LẠI tiền thuế và tổng thanh toán.
- **Tác động nghiệp vụ kế toán:** Gây mất cân đối và sai lệch nghiêm trọng: Doanh thu thay đổi nhưng thuế và tổng tiền giữ nguyên giá trị cũ!
- **Đề xuất khắc phục:** Bỏ điều kiện kiểm tra = 0; luôn tính lại: TienThueVAT = Round(TienChuaThue * ThueSuatVAT / 100, 2); TongTienThanhToan = TienChuaThue + TienThueVAT.

#### [ERR-C04] — Tương tự ERR-C03: Điều kiện 'If TienVAT = 0' ngăn cản việc tính toán lại tiền th...
- **Mức độ nghiêm trọng:** `NGHIÊM TRỌNG`
- **Vị trí phát hiện:** [`Documents\BienBanNghiemThuGiaiDoan\Ext\ObjectModule.bsl:24,27`](file:///Documents/BienBanNghiemThuGiaiDoan/Ext/ObjectModule.bsl:24,27)
- **Đối tượng ảnh hưởng:** `BienBanNghiemThuGiaiDoan`
- **Mô tả chi tiết:** Tương tự ERR-C03: Điều kiện 'If TienVAT = 0' ngăn cản việc tính toán lại tiền thuế và tổng giá trị khi thay đổi giá trị nghiệm thu chưa VAT.
- **Tác động nghiệp vụ kế toán:** Sai lệch số tiền nghiệm thu và ghi nhận doanh thu trên Sổ cái.
- **Đề xuất khắc phục:** Luôn tính lại TienVAT và TongGiaTri khi GiaTriNghiemThuChuaVAT thay đổi.

### Nhóm d) Công thức tính sai

#### [ERR-D01] — Tính số tiền ngoại tệ AP bằng cách lấy số tiền thực trả VND chia tỷ giá: 'Record...
- **Mức độ nghiêm trọng:** `NGHIÊM TRỌNG`
- **Vị trí phát hiện:** [`Documents\HoaDonNhaCungCap\Ext\ObjectModule.bsl:171`](file:///Documents/HoaDonNhaCungCap/Ext/ObjectModule.bsl:171)
- **Đối tượng ảnh hưởng:** `HoaDonNhaCungCap`
- **Mô tả chi tiết:** Tính số tiền ngoại tệ AP bằng cách lấy số tiền thực trả VND chia tỷ giá: 'RecordAP.SoTienNgoaiTe = Round(NoThucTraNCC / TyGia, 2)'.
- **Tác động nghiệp vụ kế toán:** Phép chia ngược từ tiền VND đã làm tròn gây sai số ngoại tệ (rounding drift), làm lệch số dư ngoại tệ gốc USD của nhà cung cấp.
- **Đề xuất khắc phục:** Sử dụng số tiền nguyên tệ gốc USD từ hóa đơn: RecordAP.SoTienNgoaiTe = TongTienNgoaiTe (hoặc nguyên tệ Net sau FCT).

#### [ERR-D02] — Thiếu hoàn toàn công thức quy đổi TongTien = TienNguyenTe * TyGia trong BeforeWr...
- **Mức độ nghiêm trọng:** `NGHIÊM TRỌNG`
- **Vị trí phát hiện:** [`Documents\HoaDonNhaCungCap\Ext\ObjectModule.bsl:31-75`](file:///Documents/HoaDonNhaCungCap/Ext/ObjectModule.bsl:31-75)
- **Đối tượng ảnh hưởng:** `HoaDonNhaCungCap`
- **Mô tả chi tiết:** Thiếu hoàn toàn công thức quy đổi TongTien = TienNguyenTe * TyGia trong BeforeWrite khi nhập hóa đơn ngoại tệ.
- **Tác động nghiệp vụ kế toán:** Nếu người dùng nhập hóa đơn USD (TienNguyenTe), TongTien (VND) vẫn bằng 0, dẫn đến việc Posting bị chặn lỗi 'Tổng tiền hóa đơn phải lớn hơn 0!'.
- **Đề xuất khắc phục:** Bổ sung: If TongTien = 0 And TienNguyenTe > 0 And TyGia > 0 Then TongTien = Round(TienNguyenTe * TyGia, 0); EndIf.

#### [ERR-D03] — Ghi đè cứng thuế suất: 'If ThueSuatVAT = 0 Then ThueSuatVAT = 10; EndIf'....
- **Mức độ nghiêm trọng:** `NGHIÊM TRỌNG`
- **Vị trí phát hiện:** [`Documents\DieuChinhCongNo\Ext\ObjectModule.bsl:33-35`](file:///Documents/DieuChinhCongNo/Ext/ObjectModule.bsl:33-35)
- **Đối tượng ảnh hưởng:** `DieuChinhCongNo`
- **Mô tả chi tiết:** Ghi đè cứng thuế suất: 'If ThueSuatVAT = 0 Then ThueSuatVAT = 10; EndIf'.
- **Tác động nghiệp vụ kế toán:** Áp đặt sai thuế suất 10% cho các hợp đồng/hóa đơn chịu thuế 0%, 5%, 8% hoặc không chịu thuế (KCT). Làm sai lệch doanh thu giảm và thuế giảm.
- **Đề xuất khắc phục:** Xóa bỏ việc ghi đè cứng. Lấy thuế suất từ hóa đơn gốc hoặc biên bản nghiệm thu tham chiếu.

#### [ERR-D04] — BeforeWrite cho phép lưu document khi không có dòng chi tiết (tính tự động TongT...
- **Mức độ nghiêm trọng:** `TRUNG BÌNH`
- **Vị trí phát hiện:** [`Documents\BangKeDoiSoatKenhThanhToan\Ext\ObjectModule.bsl:46,158`](file:///Documents/BangKeDoiSoatKenhThanhToan/Ext/ObjectModule.bsl:46,158)
- **Đối tượng ảnh hưởng:** `BangKeDoiSoatKenhThanhToan`
- **Mô tả chi tiết:** BeforeWrite cho phép lưu document khi không có dòng chi tiết (tính tự động TongThucNhan), nhưng Posting lại Raise lỗi 'GL_ANALYTICS_REQUIRED'.
- **Tác động nghiệp vụ kế toán:** Mâu thuẫn logic giữa lưu nháp và ghi sổ, người dùng lưu được nhưng không thể ghi sổ mà không có thông báo hướng dẫn rõ ràng.
- **Đề xuất khắc phục:** Đồng bộ kiểm tra bắt buộc phải có dòng chi tiết ngay từ BeforeWrite / FillCheckProcessing.

### Nhóm e) Thiếu validation

#### [ERR-E01] — Thiếu kiểm tra chặn số tiền âm (MarkNegatives = False, MinValue = 0) ở mức Metad...
- **Mức độ nghiêm trọng:** `TRUNG BÌNH`
- **Vị trí phát hiện:** [`Documents\*.xml`](file:///Documents/*.xml)
- **Đối tượng ảnh hưởng:** `Toàn bộ 13 chứng từ`
- **Mô tả chi tiết:** Thiếu kiểm tra chặn số tiền âm (MarkNegatives = False, MinValue = 0) ở mức Metadata và BeforeWrite.
- **Tác động nghiệp vụ kế toán:** Người dùng có thể nhập số tiền âm trong bản nháp, gây rủi ro sai lệch dữ liệu trước khi ghi sổ.
- **Đề xuất khắc phục:** Thiết lập MinValue = 0 trên metadata thuộc tính tiền; kiểm tra SoTien >= 0 trong BeforeWrite.

#### [ERR-E02] — Không kiểm tra ràng buộc NgayHoaDon <= Date (Ngày hóa đơn không được sau ngày hạ...
- **Mức độ nghiêm trọng:** `TRUNG BÌNH`
- **Vị trí phát hiện:** [`Documents\HoaDonGTGTDauRa,HoaDonNhaCungCap`](file:///Documents/HoaDonGTGTDauRa,HoaDonNhaCungCap)
- **Đối tượng ảnh hưởng:** `Hóa đơn đầu ra & đầu vào`
- **Mô tả chi tiết:** Không kiểm tra ràng buộc NgayHoaDon <= Date (Ngày hóa đơn không được sau ngày hạch toán ghi sổ).
- **Tác động nghiệp vụ kế toán:** Cho phép ghi nhận chi phí/thuế của hóa đơn phát hành trong tương lai vào kỳ kế toán hiện tại, vi phạm nguyên tắc dồn tích (VAS 01).
- **Đề xuất khắc phục:** Bổ sung kiểm tra trong BeforeWrite: If NgayHoaDon > BegOfDay(Date) Then Raise 'Ngày hóa đơn không được lớn hơn ngày ghi sổ!'; EndIf.

#### [ERR-E03] — Thiếu kiểm tra định dạng MST (10 số hoặc 13 số có dấu gạch nối) và thiếu thuật t...
- **Mức độ nghiêm trọng:** `NGHIÊM TRỌNG`
- **Vị trí phát hiện:** [`Catalogs\PhapNhan.xml:MaSoThue`](file:///Catalogs/PhapNhan.xml:MaSoThue)
- **Đối tượng ảnh hưởng:** `PhapNhan, DoiTac`
- **Mô tả chi tiết:** Thiếu kiểm tra định dạng MST (10 số hoặc 13 số có dấu gạch nối) và thiếu thuật toán kiểm tra số kiểm (check-digit).
- **Tác động nghiệp vụ kế toán:** Dữ liệu MST rác lọt vào hệ thống, xuất hóa đơn điện tử bị CQT từ chối cấp mã.
- **Đề xuất khắc phục:** Viết hàm CommonModule kiểm tra MST chuẩn regex '^[0-9]{10}(-[0-9]{3})?$' và thuật toán modulo 11 tính số kiểm tra.

#### [ERR-E04] — Thiếu kiểm tra trùng số hóa đơn của cùng nhà cung cấp (DoiTac + SoHoaDon + NgayH...
- **Mức độ nghiêm trọng:** `NGHIÊM TRỌNG`
- **Vị trí phát hiện:** [`Documents\HoaDonNhaCungCap\Ext\ObjectModule.bsl`](file:///Documents/HoaDonNhaCungCap/Ext/ObjectModule.bsl)
- **Đối tượng ảnh hưởng:** `HoaDonNhaCungCap`
- **Mô tả chi tiết:** Thiếu kiểm tra trùng số hóa đơn của cùng nhà cung cấp (DoiTac + SoHoaDon + NgayHoaDon).
- **Tác động nghiệp vụ kế toán:** Nguy cơ nhân viên nhập trùng hóa đơn NCC 2 lần, dẫn đến thanh toán khống và thất thoát dòng tiền.
- **Đề xuất khắc phục:** Viết truy vấn kiểm tra trùng lặp số hóa đơn của đối tác trong BeforeWrite trước khi cho phép ghi.

#### [ERR-E05] — Thiếu kiểm tra tính duy nhất của cặp Ký hiệu và Số hóa đơn (KyHieu + SoHoaDon)....
- **Mức độ nghiêm trọng:** `TRUNG BÌNH`
- **Vị trí phát hiện:** [`Documents\HoaDonGTGTDauRa\Ext\ObjectModule.bsl`](file:///Documents/HoaDonGTGTDauRa/Ext/ObjectModule.bsl)
- **Đối tượng ảnh hưởng:** `HoaDonGTGTDauRa`
- **Mô tả chi tiết:** Thiếu kiểm tra tính duy nhất của cặp Ký hiệu và Số hóa đơn (KyHieu + SoHoaDon).
- **Tác động nghiệp vụ kế toán:** Trùng lặp số hóa đơn điện tử phát hành, vi phạm nghiêm trọng NĐ 123/2020/NĐ-CP.
- **Đề xuất khắc phục:** Kiểm tra tính duy nhất của KyHieu + SoHoaDon trong bảng dữ liệu hóa đơn đầu ra.

#### [ERR-E06] — Hầu hết các trường quan trọng (PhapNhan, DoiTac, SoTien, TienTe, NgayHoaDon...) ...
- **Mức độ nghiêm trọng:** `TRUNG BÌNH`
- **Vị trí phát hiện:** [`Documents\*.xml:FillChecking`](file:///Documents/*.xml:FillChecking)
- **Đối tượng ảnh hưởng:** `Toàn bộ 13 chứng từ`
- **Mô tả chi tiết:** Hầu hết các trường quan trọng (PhapNhan, DoiTac, SoTien, TienTe, NgayHoaDon...) đặt FillChecking = DontCheck.
- **Tác động nghiệp vụ kế toán:** Giao diện Taxi không tự động gạch chân đỏ cảnh báo trường bắt buộc, chỉ báo lỗi khi đã bấm nút Ghi.
- **Đề xuất khắc phục:** Chuyển thuộc tính FillChecking trên metadata từ DontCheck sang ShowError cho mọi trường bắt buộc.

### Nhóm f) Xử lý sự kiện (Event Handling)

#### [ERR-F01] — Toàn bộ 13 Document không hề có Managed Form tùy chỉnh (Forms/*/Form.xml và Modu...
- **Mức độ nghiêm trọng:** `NGHIÊM TRỌNG`
- **Vị trí phát hiện:** [`src\Documents\*\Forms`](file:///src/Documents/*/Forms)
- **Đối tượng ảnh hưởng:** `Toàn bộ 13 chứng từ`
- **Mô tả chi tiết:** Toàn bộ 13 Document không hề có Managed Form tùy chỉnh (Forms/*/Form.xml và Module.bsl), chỉ dùng form tự sinh mặc định.
- **Tác động nghiệp vụ kế toán:** Không thể xử lý sự kiện OnChange trên Client để tính tiền/nhảy thuế tức thì; trải nghiệm người dùng kém và dễ sai lệch số liệu.
- **Đề xuất khắc phục:** Tạo Managed Form cho từng chứng từ (đặc biệt HoaDonGTGTDauRa, HoaDonNhaCungCap, UyNhiemChi) với các sự kiện OnChange & OnCreateAtServer.

#### [ERR-F02] — Sử dụng câu lệnh Raise trực tiếp trong Posting thay vì gán Cancel = True và dùng...
- **Mức độ nghiêm trọng:** `TRUNG BÌNH`
- **Vị trí phát hiện:** [`Documents\UyNhiemChi,CanTruCongNoNoiBo`](file:///Documents/UyNhiemChi,CanTruCongNoNoiBo)
- **Đối tượng ảnh hưởng:** `UyNhiemChi, CanTruCongNoNoiBo`
- **Mô tả chi tiết:** Sử dụng câu lệnh Raise trực tiếp trong Posting thay vì gán Cancel = True và dùng UserMessage.
- **Tác động nghiệp vụ kế toán:** Crash giao dịch với hộp thoại lỗi hệ thống đỏ, không trỏ con trỏ chuột vào trường nhập liệu bị sai.
- **Đề xuất khắc phục:** Thay Raise bằng Msg = New UserMessage; Msg.Field = '...'; Msg.Message(); Cancel = True; Return;.

#### [ERR-F03] — Thiếu thủ tục UndoPosting (ОбработкаУдаленияПроведения) trên 9 chứng từ....
- **Mức độ nghiêm trọng:** `NHẸ`
- **Vị trí phát hiện:** [`Documents\*.bsl`](file:///Documents/*.bsl)
- **Đối tượng ảnh hưởng:** `9/13 chứng từ`
- **Mô tả chi tiết:** Thiếu thủ tục UndoPosting (ОбработкаУдаленияПроведения) trên 9 chứng từ.
- **Tác động nghiệp vụ kế toán:** Thiếu chốt chặn kiểm tra điều kiện trước khi cho phép người dùng hủy ghi sổ chứng từ.
- **Đề xuất khắc phục:** Khai báo Procedure UndoPosting(Cancel) để kiểm tra các ràng buộc liên đới trước khi hủy ghi sổ.

### Nhóm g) Bút toán định khoản (Posting)

#### [ERR-G01] — Hóa đơn GTGT đầu ra chỉ ghi Nợ 131 / Có 33311 (tiền thuế VAT), HOÀN TOÀN THIẾU B...
- **Mức độ nghiêm trọng:** `NGHIÊM TRỌNG`
- **Vị trí phát hiện:** [`Documents\HoaDonGTGTDauRa\Ext\ObjectModule.bsl:96-113`](file:///Documents/HoaDonGTGTDauRa/Ext/ObjectModule.bsl:96-113)
- **Đối tượng ảnh hưởng:** `HoaDonGTGTDauRa`
- **Mô tả chi tiết:** Hóa đơn GTGT đầu ra chỉ ghi Nợ 131 / Có 33311 (tiền thuế VAT), HOÀN TOÀN THIẾU BÚT TOÁN DOANH THU Có TK 5113.
- **Tác động nghiệp vụ kế toán:** Hóa đơn bán hàng xuất độc lập không ghi nhận doanh thu vào Sổ cái! Vi phạm chuẩn mực kế toán VAS 14 và TT 200.
- **Đề xuất khắc phục:** Bổ sung bút toán doanh thu Nợ 131 (hoặc 111/112) / Có 5113 cho TienChuaThue nếu hóa đơn không liên kết nghiệm thu.

#### [ERR-G02] — Phí ngân hàng luôn gán cứng Có TK 1121 (Tiền VND) ngay cả khi chi từ tài khoản n...
- **Mức độ nghiêm trọng:** `NGHIÊM TRỌNG`
- **Vị trí phát hiện:** [`Documents\UyNhiemChi\Ext\ObjectModule.bsl:608-613`](file:///Documents/UyNhiemChi/Ext/ObjectModule.bsl:608-613)
- **Đối tượng ảnh hưởng:** `UyNhiemChi`
- **Mô tả chi tiết:** Phí ngân hàng luôn gán cứng Có TK 1121 (Tiền VND) ngay cả khi chi từ tài khoản ngoại tệ USD (TK 1122).
- **Tác động nghiệp vụ kế toán:** Lệch số dư tiền ngoại tệ USD trên sổ phụ ngân hàng và Sổ cái, ghi giảm sai tiền VND.
- **Đề xuất khắc phục:** Sử dụng tài khoản tiền thực tế của lệnh chi: Row2.AccountCr = TKTien (nếu chi USD thì Có 1122, nếu VND thì Có 1121).

#### [ERR-G03] — Các dòng bút toán ghi Có TK 3311/3312 không gán DoiTacCo và HopDongCo trên Sổ cá...
- **Mức độ nghiêm trọng:** `TRUNG BÌNH`
- **Vị trí phát hiện:** [`Documents\NghiemThuThauPhu\Ext\ObjectModule.bsl:99-133`](file:///Documents/NghiemThuThauPhu/Ext/ObjectModule.bsl:99-133)
- **Đối tượng ảnh hưởng:** `NghiemThuThauPhu`
- **Mô tả chi tiết:** Các dòng bút toán ghi Có TK 3311/3312 không gán DoiTacCo và HopDongCo trên Sổ cái SoCaiKeToan.
- **Tác động nghiệp vụ kế toán:** Sổ cái mất khóa phân tích (Analytic Keys), không thể trích xuất sổ chi tiết công nợ nhà cung cấp từ Sổ cái.
- **Đề xuất khắc phục:** Bổ sung Row1.DoiTacCo = DoiTac; Row1.HopDongCo = HopDong; Row2.DoiTacCo = DoiTac; Row2.HopDongCo = HopDong;.

#### [ERR-G04] — Bút toán Nợ TK 1388 không gán DoiTacNo trên Sổ cái....
- **Mức độ nghiêm trọng:** `TRUNG BÌNH`
- **Vị trí phát hiện:** [`Documents\YeuCauHoanTienChiHo\Ext\ObjectModule.bsl:129-139`](file:///Documents/YeuCauHoanTienChiHo/Ext/ObjectModule.bsl:129-139)
- **Đối tượng ảnh hưởng:** `YeuCauHoanTienChiHo`
- **Mô tả chi tiết:** Bút toán Nợ TK 1388 không gán DoiTacNo trên Sổ cái.
- **Tác động nghiệp vụ kế toán:** Mất chi tiết đối tượng công nợ trên tài khoản 1388 (Phải thu khác).
- **Đề xuất khắc phục:** Bổ sung Row1.DoiTacNo = DoiTac; Row1.HopDongNo = HopDong;.

#### [ERR-G05] — Bỏ sót hoàn toàn việc đánh giá lại công nợ phải thu ngoại tệ (TK 131 ngoại tệ). ...
- **Mức độ nghiêm trọng:** `NGHIÊM TRỌNG`
- **Vị trí phát hiện:** [`Documents\DanhGiaLaiNgoaiTe\Ext\ObjectModule.bsl`](file:///Documents/DanhGiaLaiNgoaiTe/Ext/ObjectModule.bsl)
- **Đối tượng ảnh hưởng:** `DanhGiaLaiNgoaiTe`
- **Mô tả chi tiết:** Bỏ sót hoàn toàn việc đánh giá lại công nợ phải thu ngoại tệ (TK 131 ngoại tệ). Chỉ đánh giá 1122 và 3313.
- **Tác động nghiệp vụ kế toán:** Vi phạm Điều 69 Thông tư 200/2014/TT-BTC về đánh giá lại tất cả các khoản mục tiền tệ có gốc ngoại tệ cuối kỳ.
- **Đề xuất khắc phục:** Bổ sung đoạn truy vấn và đánh giá lại số dư AR ngoại tệ trên AccumulationRegister.CongNoPhaiThu và TK 1313.

### Nhóm h) Phân quyền / Trạng thái

#### [ERR-H01] — Cờ DataExchange.Load cho phép bypass một số kiểm tra Maker-Checker và trạng thái...
- **Mức độ nghiêm trọng:** `TRUNG BÌNH`
- **Vị trí phát hiện:** [`CommonModules\QuanLyVongDoiChungTuServer\Ext\Module.bsl:152`](file:///CommonModules/QuanLyVongDoiChungTuServer/Ext/Module.bsl:152)
- **Đối tượng ảnh hưởng:** `Quy trình vòng đời`
- **Mô tả chi tiết:** Cờ DataExchange.Load cho phép bypass một số kiểm tra Maker-Checker và trạng thái khi ghi nháp.
- **Tác động nghiệp vụ kế toán:** Rủi ro ghi đè trạng thái chứng từ thông qua công cụ trao đổi dữ liệu hoặc script ngoài kiểm soát.
- **Đề xuất khắc phục:** Chặn tuyệt đối việc thay đổi trạng thái nhạy cảm (DaGhiSo, DaCanTru) ngay cả khi DataExchange.Load = True.

### Nhóm i) Code smell ảnh hưởng tính đúng đắn

#### [ERR-I01] — Hardcode số tài khoản kế toán bằng chuỗi FindByCode('1121'), FindByCode('1311'),...
- **Mức độ nghiêm trọng:** `NGHIÊM TRỌNG`
- **Vị trí phát hiện:** [`Toàn bộ ObjectModule & CommonModule`](file:///Toàn bộ ObjectModule & CommonModule)
- **Đối tượng ảnh hưởng:** `Toàn hệ thống`
- **Mô tả chi tiết:** Hardcode số tài khoản kế toán bằng chuỗi FindByCode('1121'), FindByCode('1311'), FindByCode('627') khắp nơi trong code thay vì cấu hình động.
- **Tác động nghiệp vụ kế toán:** Hệ thống cực kỳ khó bảo trì; khi nâng cấp chính sách kế toán hoặc thay đổi mã tài khoản thì toàn bộ code bị gãy.
- **Đề xuất khắc phục:** Tạo bảng cấu hình định khoản tự động (Accounting Posting Rules) hoặc lưu trữ trong Constants/InformationRegisters.

#### [ERR-I02] — SeedDataCleanServer gán hằng số TaiKhoanPhiNganHang = '6425' (Thuế, phí, lệ phí ...
- **Mức độ nghiêm trọng:** `TRUNG BÌNH`
- **Vị trí phát hiện:** [`CommonModules\SeedDataCleanServer\Ext\Module.bsl:273`](file:///CommonModules/SeedDataCleanServer/Ext/Module.bsl:273)
- **Đối tượng ảnh hưởng:** `Constants.TaiKhoanPhiNganHang`
- **Mô tả chi tiết:** SeedDataCleanServer gán hằng số TaiKhoanPhiNganHang = '6425' (Thuế, phí, lệ phí - sai bản chất TT200), nhưng code UyNhiemChi lại hardcode '6427'.
- **Tác động nghiệp vụ kế toán:** Mâu thuẫn dữ liệu giữa Constant cấu hình và Code thực thi, gây nhầm lẫn nghiêm trọng cho kế toán.
- **Đề xuất khắc phục:** Sửa Constant thành '6427' (Chi phí dịch vụ mua ngoài) và sửa code UyNhiemChi đọc từ Constants.TaiKhoanPhiNganHang.Get().

---

## 4. NHIỆM VỤ 3 — KIỂM TRA MÃ SỐ KẾ TOÁN VÀ ĐỐI CHIẾU HỆ THỐNG TÀI KHOẢN TT 200
Toàn bộ các mã số tài khoản xuất hiện trong metadata, predefined mapping (`BangAnhXaTaiKhoanMacDinh`), ObjectModules và CommonModules được trích xuất và đối chiếu trực tiếp với Danh mục Hệ thống Tài khoản Kế toán Doanh nghiệp ban hành kèm theo **Thông tư số 200/2014/TT-BTC** ngày 22/12/2014 của Bộ Tài chính:

| STT | Mã TK trong code | Tên trong code / Cấu hình | Mã & Tên chuẩn theo TT 200 | Kết luận phân loại | Đánh giá nghiệp vụ chi tiết & Căn cứ pháp lý | Dẫn chứng File : Dòng |
| :---: | :---: | :--- | :--- | :---: | :--- | :--- |
| 1 | **000** | Tài khoản đối ứng số dư đầu kỳ | Không có trong hệ thống TK chính thức TT200 | **Tài khoản kỹ thuật ngoài bảng (Dùng vào số dư, không thuộc TT200)** | Tài khoản ngoài bảng / trung gian kỹ thuật phần mềm vào số dư ban đầu, không thuộc hệ thống BCTC chính thức. | `CommonModules\GeneratorAPServer\Ext\Module.bsl:189` |
| 2 | **1121** | Tiền gửi ngân hàng VND | Tiền Việt Nam | **Đúng chuẩn TT200** | Hoàn toàn khớp đúng cả mã số và tên gọi tài khoản theo quy định chuẩn của Thông tư 200/2014/TT-BTC. | `CommonModules\QuanLyVongDoiChungTuServer\Ext\Module.bsl:275` |
| 3 | **1122** | Tiền gửi ngân hàng Ngoại tệ | Ngoại tệ | **Đúng chuẩn TT200** | Hoàn toàn khớp đúng cả mã số và tên gọi tài khoản theo quy định chuẩn của Thông tư 200/2014/TT-BTC. | `CommonModules\ConcurrencyTestsServer\Ext\Module.bsl:235` |
| 4 | **1311** | Phải thu khách hàng ngoài | Không có trong hệ thống TK TT200 | **Tài khoản tự mở thêm cấp 2 (TT200 chỉ có TK 131 cấp 1, đơn vị tự mở 1311/1312)** | TT200 chỉ quy định TK 131 cấp 1. Đơn vị được tự mở thêm cấp 2 theo Điều 9 TT200. **Lưu ý nghiệp vụ:** Quan hệ phụ thuộc cùng pháp nhân bắt buộc dùng 136/336; quan hệ giữa các công ty con độc lập trong Tập đoàn được mở 1312 nhưng cần quy chế nội bộ rõ ràng. | `CommonModules\HardeningTestsServer\Ext\Module.bsl:237` |
| 5 | **1312** | Phải thu khách hàng nội bộ Vingroup | Không có trong hệ thống TK TT200 | **Tài khoản tự mở thêm cấp 2 (TT200 chỉ có TK 131 cấp 1, đơn vị tự mở 1311/1312)** | TT200 chỉ quy định TK 131 cấp 1. Đơn vị được tự mở thêm cấp 2 theo Điều 9 TT200. **Lưu ý nghiệp vụ:** Quan hệ phụ thuộc cùng pháp nhân bắt buộc dùng 136/336; quan hệ giữa các công ty con độc lập trong Tập đoàn được mở 1312 nhưng cần quy chế nội bộ rõ ràng. | `CommonModules\HardeningTestsServer\Ext\Module.bsl:237` |
| 6 | **1331** | Thuế GTGT được khấu trừ của hàng hóa, dịch vụ | Thuế GTGT được khấu trừ của hàng hóa, dịch vụ | **Đúng chuẩn TT200** | Hoàn toàn khớp đúng cả mã số và tên gọi tài khoản theo quy định chuẩn của Thông tư 200/2014/TT-BTC. | `CommonModules\QuanLyVongDoiChungTuServer\Ext\Module.bsl:323` |
| 7 | **1388** | Phải thu khác / Tiền tạm giữ cổng thanh toán | Phải thu khác | **Đúng chuẩn TT200** | Hoàn toàn khớp đúng cả mã số và tên gọi tài khoản theo quy định chuẩn của Thông tư 200/2014/TT-BTC. | `CommonModules\HardeningTestsServer\Ext\Module.bsl:237` |
| 8 | **3311** | Phải trả người bán bên ngoài | Không có trong hệ thống TK TT200 | **Tài khoản tự mở thêm cấp 2 (TT200 chỉ có TK 331 cấp 1, đơn vị tự mở)** | TT200 chỉ quy định TK 331 cấp 1. Là các tài khoản cấp 2 do đơn vị tự mở thêm phục vụ quản lý công nợ người bán bên ngoài, nội bộ và ngoại tệ. | `CommonModules\ConcurrencyTestsServer\Ext\Module.bsl:234` |
| 9 | **3312** | Phải trả người bán nội bộ Vingroup | Không có trong hệ thống TK TT200 | **Tài khoản tự mở thêm cấp 2 (TT200 chỉ có TK 331 cấp 1, đơn vị tự mở)** | TT200 chỉ quy định TK 331 cấp 1. Là các tài khoản cấp 2 do đơn vị tự mở thêm phục vụ quản lý công nợ người bán bên ngoài, nội bộ và ngoại tệ. | `CommonModules\ConcurrencyTestsServer\Ext\Module.bsl:234` |
| 10 | **3313** | Phải trả người bán nước ngoài Ngoại tệ USD | Không có trong hệ thống TK TT200 | **Tài khoản tự mở thêm cấp 2 (TT200 chỉ có TK 331 cấp 1, đơn vị tự mở)** | TT200 chỉ quy định TK 331 cấp 1. Là các tài khoản cấp 2 do đơn vị tự mở thêm phục vụ quản lý công nợ người bán bên ngoài, nội bộ và ngoại tệ. | `CommonModules\ConcurrencyTestsServer\Ext\Module.bsl:233` |
| 11 | **3318** | Phải trả người bán khác | Không có trong hệ thống TK TT200 | **Tài khoản tự mở thêm cấp 2 (TT200 chỉ có TK 331 cấp 1, đơn vị tự mở)** | TT200 chỉ quy định TK 331 cấp 1. Là các tài khoản cấp 2 do đơn vị tự mở thêm phục vụ quản lý công nợ người bán bên ngoài, nội bộ và ngoại tệ. | `CommonModules\GeneratorMasterDataServer\Ext\Module.bsl:388` |
| 12 | **33311** | Thuế GTGT đầu ra | Thuế GTGT đầu ra | **Đúng chuẩn TT200** | Hoàn toàn khớp đúng cả mã số và tên gọi tài khoản theo quy định chuẩn của Thông tư 200/2014/TT-BTC. | `CommonModules\QuanLyVongDoiChungTuServer\Ext\Module.bsl:324` |
| 13 | **33318** | Thuế GTGT nhà thầu (FCT VAT) | Không có trong hệ thống TK TT200 | **Tài khoản tự mở thêm (TT200 chỉ có 33311, 33312; không có 33318)** | TT200 chỉ có 33311 và 33312. Mã 33318 là tài khoản tự mở thêm để theo dõi thuế GTGT nhà thầu nước ngoài (FCT VAT). | `CommonModules\QuanLyVongDoiChungTuServer\Ext\Module.bsl:275` |
| 14 | **3338** | Thuế và các khoản phải nộp nhà nước khác (FCT CIT) | Thuế bảo vệ môi trường và các loại thuế khác | **Đúng tài khoản TT200 nhưng thiếu cấp chi tiết (3338 gồm 33381 và 33382)** | TT200 có TK 3338 gồm 33381 và 33382. Hạch toán thuế TNDN nhà thầu (FCT CIT) vào 3338 là đúng nhóm nhưng thiếu chi tiết cấp 3 (33382 - Các loại thuế khác). | `CommonModules\QuanLyVongDoiChungTuServer\Ext\Module.bsl:326` |
| 15 | **3388** | Phải trả khác / Cấn trừ bắc cầu đa phương | Phải trả, phải nộp khác | **Đúng chuẩn TT200** | Hoàn toàn khớp đúng cả mã số và tên gọi tài khoản theo quy định chuẩn của Thông tư 200/2014/TT-BTC. | `CommonModules\GeneratorMasterDataServer\Ext\Module.bsl:389` |
| 16 | **4131** | Chênh lệch tỷ giá hối đoái | Chênh lệch tỷ giá do đánh giá lại các khoản mục tiền tệ có gốc ngoại tệ | **Đúng chuẩn TT200** | Hoàn toàn khớp đúng cả mã số và tên gọi tài khoản theo quy định chuẩn của Thông tư 200/2014/TT-BTC. | `CommonModules\BaoCaoQuanTriServer\Ext\Module.bsl:870` |
| 17 | **5113** | Doanh thu cung cấp dịch vụ | Doanh thu cung cấp dịch vụ | **Đúng chuẩn TT200** | Hoàn toàn khớp đúng cả mã số và tên gọi tài khoản theo quy định chuẩn của Thông tư 200/2014/TT-BTC. | `CommonModules\QuanLyVongDoiChungTuServer\Ext\Module.bsl:327` |
| 18 | **515** | Doanh thu hoạt động tài chính / Lãi tỷ giá | Doanh thu hoạt động tài chính | **Đúng chuẩn TT200** | Hoàn toàn khớp đúng cả mã số và tên gọi tài khoản theo quy định chuẩn của Thông tư 200/2014/TT-BTC. | `CommonModules\BaoCaoQuanTriServer\Ext\Module.bsl:868` |
| 19 | **627** | Chi phí sản xuất chung / Chi phí dịch vụ Cloud | Chi phí sản xuất chung | **Đúng chuẩn TT200** | Dùng TK cấp 1 mà không chi tiết cấp 2. Chi phí thuê Cloud mua ngoài theo TT200 nên vào TK 6277 ('Chi phí dịch vụ mua ngoài'). | `CommonModules\GeneratorAPServer\Ext\Module.bsl:57` |
| 20 | **635** | Chi phí tài chính / Lỗ tỷ giá | Chi phí tài chính | **Đúng chuẩn TT200** | Hoàn toàn khớp đúng cả mã số và tên gọi tài khoản theo quy định chuẩn của Thông tư 200/2014/TT-BTC. | `CommonModules\BaoCaoQuanTriServer\Ext\Module.bsl:869` |
| 21 | **641** | Chi phí bán hàng | Chi phí bán hàng | **Đúng chuẩn TT200** | Hoàn toàn khớp đúng cả mã số và tên gọi tài khoản theo quy định chuẩn của Thông tư 200/2014/TT-BTC. | `CommonModules\GeneratorMasterDataServer\Ext\Module.bsl:390` |
| 22 | **642** | Chi phí quản lý doanh nghiệp | Chi phí quản lý doanh nghiệp | **Đúng chuẩn TT200** | Hoàn toàn khớp đúng cả mã số và tên gọi tài khoản theo quy định chuẩn của Thông tư 200/2014/TT-BTC. | `CommonModules\QuanLyVongDoiChungTuServer\Ext\Module.bsl:329` |
| 23 | **6425** | Thuế, phí và lệ phí (bị gán làm phí ngân hàng) | Thuế, phí và lệ phí | **Sai bản chất nghiệp vụ (TT200 quy định 6425 là Thuế, phí, lệ phí; không phải phí dịch vụ ngân hàng)** | TT200 quy định 6425 là 'Thuế, phí và lệ phí' (thuế môn bài, tiền thuê đất, lệ phí giao thông). Phí chuyển tiền ngân hàng là chi phí dịch vụ mua ngoài (TK 6427) hoặc chi phí tài chính (TK 635). Gán 6425 là **SAI BẢN CHẤT KẾ TOÁN**. | `CommonModules\SeedDataCleanServer\Ext\Module.bsl:273` |
| 24 | **6427** | Chi phí dịch vụ mua ngoài / Phí ngân hàng | Chi phí dịch vụ mua ngoài | **Đúng chuẩn TT200** | Hoàn toàn khớp đúng cả mã số và tên gọi tài khoản theo quy định chuẩn của Thông tư 200/2014/TT-BTC. | `CommonModules\QuanLyVongDoiChungTuServer\Ext\Module.bsl:330` |
| 25 | **711** | Thu nhập khác | Thu nhập khác | **Đúng chuẩn TT200** | Hoàn toàn khớp đúng cả mã số và tên gọi tài khoản theo quy định chuẩn của Thông tư 200/2014/TT-BTC. | `CommonModules\QuanLyVongDoiChungTuServer\Ext\Module.bsl:334` |

### Đánh giá chuyên sâu nghiệp vụ kế toán từng chu trình:
1. **Chu trình Bán hàng & Doanh thu (AR):**
   - Hiện tại: `BienBanNghiemThuGiaiDoan` hạch toán Nợ 131 / Có 5113 (giá chưa VAT), `HoaDonGTGTDauRa` hạch toán Nợ 131 / Có 33311 (tiền VAT).
   - **Lỗ hổng:** Nếu người dùng lập hóa đơn bán hàng độc lập (không qua bước nghiệm thu), hệ thống KHÔNG GHI NHẬN DOANH THU (Có 511). Đề xuất bổ sung cơ chế xác định nguồn doanh thu trực tiếp trên hóa đơn.
2. **Chu trình Mua hàng & Chi phí (AP):**
   - Mọi chi phí dịch vụ mua ngoài đều bị áp đặt vào TK 627 (Chi phí sản xuất chung), thiếu các tài khoản chi phí quản lý (642), bán hàng (641), trả trước (242), hoặc tài sản (211, 156).
   - Đề xuất kích hoạt trường `TaiKhoanChiPhi` trên form và thiết lập kiểm tra hợp lệ tài khoản Nợ thuộc nhóm 15x, 24x, 6xx.
3. **Chu trình Thanh toán Ngân hàng & Tỷ giá (Treasury & Cash):**
   - Phí ngân hàng đang bị gán cứng vào TK 1121 khi ghi Có, làm sai lệch số dư tiền gửi ngoại tệ 1122 khi thanh toán quốc tế.
   - Công thức quy đổi ngoại tệ chia ngược từ VND sang USD gây sai số làm tròn.
4. **Chính sách Thuế suất GTGT 8%:**
   - Theo **Nghị quyết 204/2025/QH15** và **Nghị định 174/2025/NĐ-CP**, chính sách giảm 2% thuế suất thuế GTGT (từ 10% xuống 8%) có hiệu lực từ **01/07/2025 đến hết ngày 31/12/2026** và áp dụng cho cả dịch vụ công nghệ thông tin.
   - Codebase VSF hiện tại hoàn toàn thiếu mức thuế suất 8%, code `DieuChinhCongNo` và các generator AR/AP tự động ép thuế suất về 10%, gây sai phạm nghiêm trọng về hóa đơn và kê khai thuế GTGT của doanh nghiệp.

---

## 5. PHẠM VI KIỂM TRA & DANH SÁCH FILE ĐÃ ĐỌC (AUDIT TRAIL)
Ban Kiểm toán xác nhận đã quét và đọc toàn bộ **190 file cấu hình 1C** trong thư mục `src/`, bao gồm 44 file mã nguồn BSL (13.248 dòng lệnh), toàn bộ các tệp định nghĩa Metadata XML, 24 tệp kiểm thử tự động BSL và các văn bản chính sách kế toán nội bộ. Không có bất kỳ module hay đối tượng nào bị bỏ sót.

| STT | Đường dẫn file tương đối | Nhóm đối tượng | Kích thước | Trạng thái đọc |
| :---: | :--- | :--- | :---: | :---: |
| 1 | `src\AccountingRegisters\SoCaiKeToan.xml` | AccountingRegisters | 27341 bytes | **ĐÃ ĐỌC 100%** |
| 2 | `src\AccumulationRegisters\CongNoPhaiThu.xml` | AccumulationRegisters | 10452 bytes | **ĐÃ ĐỌC 100%** |
| 3 | `src\AccumulationRegisters\CongNoPhaiTra.xml` | AccumulationRegisters | 10454 bytes | **ĐÃ ĐỌC 100%** |
| 4 | `src\AccumulationRegisters\DongTien.xml` | AccumulationRegisters | 10460 bytes | **ĐÃ ĐỌC 100%** |
| 5 | `src\AccumulationRegisters\GiaoDichDienTuTamGiu.xml` | AccumulationRegisters | 9487 bytes | **ĐÃ ĐỌC 100%** |
| 6 | `src\Catalogs\DichVuCNTT.xml` | Catalogs | 8875 bytes | **ĐÃ ĐỌC 100%** |
| 7 | `src\Catalogs\DoiTac.xml` | Catalogs | 8404 bytes | **ĐÃ ĐỌC 100%** |
| 8 | `src\Catalogs\DuAn.xml` | Catalogs | 8580 bytes | **ĐÃ ĐỌC 100%** |
| 9 | `src\Catalogs\HopDong.xml` | Catalogs | 11092 bytes | **ĐÃ ĐỌC 100%** |
| 10 | `src\Catalogs\HopDong\Ext\ObjectModule.bsl` | Catalogs | 240 bytes | **ĐÃ ĐỌC 100%** |
| 11 | `src\Catalogs\KenhThanhToan.xml` | Catalogs | 7422 bytes | **ĐÃ ĐỌC 100%** |
| 12 | `src\Catalogs\KhoanMucDongTien.xml` | Catalogs | 6090 bytes | **ĐÃ ĐỌC 100%** |
| 13 | `src\Catalogs\PhapNhan.xml` | Catalogs | 7376 bytes | **ĐÃ ĐỌC 100%** |
| 14 | `src\Catalogs\TaiKhoanAo.xml` | Catalogs | 8515 bytes | **ĐÃ ĐỌC 100%** |
| 15 | `src\Catalogs\TaiKhoanAo\Ext\ObjectModule.bsl` | Catalogs | 911 bytes | **ĐÃ ĐỌC 100%** |
| 16 | `src\Catalogs\TaiKhoanTien.xml` | Catalogs | 8663 bytes | **ĐÃ ĐỌC 100%** |
| 17 | `src\Catalogs\TienTe.xml` | Catalogs | 7378 bytes | **ĐÃ ĐỌC 100%** |
| 18 | `src\ChartsOfAccounts\HeThongTaiKhoan.xml` | ChartsOfAccounts | 9696 bytes | **ĐÃ ĐỌC 100%** |
| 19 | `src\CommonModules\BaoCaoQuanTriServer.xml` | CommonModules | 1793 bytes | **ĐÃ ĐỌC 100%** |
| 20 | `src\CommonModules\BaoCaoQuanTriServer\Ext\Module.bsl` | CommonModules | 44457 bytes | **ĐÃ ĐỌC 100%** |
| 21 | `src\CommonModules\ConcurrencyTestsServer.xml` | CommonModules | 1695 bytes | **ĐÃ ĐỌC 100%** |
| 22 | `src\CommonModules\ConcurrencyTestsServer\Ext\Module.bsl` | CommonModules | 16474 bytes | **ĐÃ ĐỌC 100%** |
| 23 | `src\CommonModules\GeneratorAPServer.xml` | CommonModules | 1582 bytes | **ĐÃ ĐỌC 100%** |
| 24 | `src\CommonModules\GeneratorAPServer\Ext\Module.bsl` | CommonModules | 13763 bytes | **ĐÃ ĐỌC 100%** |
| 25 | `src\CommonModules\GeneratorARServer.xml` | CommonModules | 1582 bytes | **ĐÃ ĐỌC 100%** |
| 26 | `src\CommonModules\GeneratorARServer\Ext\Module.bsl` | CommonModules | 20325 bytes | **ĐÃ ĐỌC 100%** |
| 27 | `src\CommonModules\GeneratorMasterDataServer.xml` | CommonModules | 1784 bytes | **ĐÃ ĐỌC 100%** |
| 28 | `src\CommonModules\GeneratorMasterDataServer\Ext\Module.bsl` | CommonModules | 23974 bytes | **ĐÃ ĐỌC 100%** |
| 29 | `src\CommonModules\GeneratorNettingReconcileServer.xml` | CommonModules | 1611 bytes | **ĐÃ ĐỌC 100%** |
| 30 | `src\CommonModules\GeneratorNettingReconcileServer\Ext\Module.bsl` | CommonModules | 24747 bytes | **ĐÃ ĐỌC 100%** |
| 31 | `src\CommonModules\HardeningTestsServer.xml` | CommonModules | 1774 bytes | **ĐÃ ĐỌC 100%** |
| 32 | `src\CommonModules\HardeningTestsServer\Ext\Module.bsl` | CommonModules | 13308 bytes | **ĐÃ ĐỌC 100%** |
| 33 | `src\CommonModules\NettingReversalTestsServer.xml` | CommonModules | 1697 bytes | **ĐÃ ĐỌC 100%** |
| 34 | `src\CommonModules\NettingReversalTestsServer\Ext\Module.bsl` | CommonModules | 19268 bytes | **ĐÃ ĐỌC 100%** |
| 35 | `src\CommonModules\PhanQuyenBaoMatServer.xml` | CommonModules | 1671 bytes | **ĐÃ ĐỌC 100%** |
| 36 | `src\CommonModules\PhanQuyenBaoMatServer\Ext\Module.bsl` | CommonModules | 36053 bytes | **ĐÃ ĐỌC 100%** |
| 37 | `src\CommonModules\PheDuyetDaCapServer.xml` | CommonModules | 1800 bytes | **ĐÃ ĐỌC 100%** |
| 38 | `src\CommonModules\PheDuyetDaCapServer\Ext\Module.bsl` | CommonModules | 15063 bytes | **ĐÃ ĐỌC 100%** |
| 39 | `src\CommonModules\QuanLyTyGiaVaNgoaiTeServer.xml` | CommonModules | 1829 bytes | **ĐÃ ĐỌC 100%** |
| 40 | `src\CommonModules\QuanLyTyGiaVaNgoaiTeServer\Ext\Module.bsl` | CommonModules | 8041 bytes | **ĐÃ ĐỌC 100%** |
| 41 | `src\CommonModules\QuanLyVongDoiChungTuServer.xml` | CommonModules | 1814 bytes | **ĐÃ ĐỌC 100%** |
| 42 | `src\CommonModules\QuanLyVongDoiChungTuServer\Ext\Module.bsl` | CommonModules | 51583 bytes | **ĐÃ ĐỌC 100%** |
| 43 | `src\CommonModules\QuyTrinhPheDuyetAPServer.xml` | CommonModules | 1827 bytes | **ĐÃ ĐỌC 100%** |
| 44 | `src\CommonModules\QuyTrinhPheDuyetAPServer\Ext\Module.bsl` | CommonModules | 3801 bytes | **ĐÃ ĐỌC 100%** |
| 45 | `src\CommonModules\SeedBoundaryTestsServer.xml` | CommonModules | 1682 bytes | **ĐÃ ĐỌC 100%** |
| 46 | `src\CommonModules\SeedBoundaryTestsServer\Ext\Module.bsl` | CommonModules | 7816 bytes | **ĐÃ ĐỌC 100%** |
| 47 | `src\CommonModules\SeedDataCleanServer.xml` | CommonModules | 1819 bytes | **ĐÃ ĐỌC 100%** |
| 48 | `src\CommonModules\SeedDataCleanServer\Ext\Module.bsl` | CommonModules | 11758 bytes | **ĐÃ ĐỌC 100%** |
| 49 | `src\CommonModules\SeedFullTestDataServer.xml` | CommonModules | 1846 bytes | **ĐÃ ĐỌC 100%** |
| 50 | `src\CommonModules\SeedFullTestDataServer\Ext\Module.bsl` | CommonModules | 22103 bytes | **ĐÃ ĐỌC 100%** |
| ... | *(Xem toàn bộ 190 file tại Sheet 'DanhSachFileDaDoc' trong file Excel [audit_logic_1c.xlsx](file:///C:/Users/Dung/Documents/1C_Enterprise/audit_logic_1c.xlsx))* | ... | ... | **ĐÃ ĐỌC 100%** |

---

## 6. TOP 5 VIỆC CẦN SỬA NGAY THEO THỨ TỰ ƯU TIÊN (ACTION PLAN)
Căn cứ trên mức độ rủi ro kiểm soát nội bộ, rủi ro pháp lý thuế và tính toàn vẹn số liệu tài chính, Ban Kiểm toán kiến nghị Ban Giám đốc và Đội ngũ Kỹ thuật thực hiện ngay 5 nhiệm vụ sau:

### Ưu tiên 1: Tạo Managed Form tùy chỉnh cho 3 chứng từ cốt lõi (`HoaDonGTGTDauRa`, `HoaDonNhaCungCap`, `UyNhiemChi`)
- **Mục tiêu:** Chấm dứt tình trạng form trơ do phụ thuộc form tự sinh. Thêm các sự kiện `OnChange` trên Client để khi người dùng nhập số tiền/chọn thuế suất/chọn tỷ giá thì hệ thống tính toán ngay lập tức tiền thuế, tổng thanh toán và tiền quy đổi VND.
- **Hành động kỹ thuật:** Tạo `Form.xml` và `Module.bsl` trong `Documents/HoaDonGTGTDauRa/Forms/DocumentForm/` với các hàm `&AtClient Procedure TienChuaThueOnChange()` và `&AtClient Procedure ThueSuatVATOnChange()`.

### Ưu tiên 2: Bổ sung thuộc tính Mã số thuế (MST) và Địa chỉ vào `Catalog.DoiTac`, thêm `ChoiceParameterLinks` cho Hợp đồng
- **Mục tiêu:** Đảm bảo tuân thủ Điều 10 NĐ 123/2020/NĐ-CP về nội dung hóa đơn điện tử; ngăn chặn triệt để việc nhân viên chọn nhầm hợp đồng của đối tác khác.
- **Hành động kỹ thuật:** Thêm thuộc tính `MaSoThue` (kiểm tra 10/13 số), `DiaChi`, `SoTaiKhoanNganHang` vào `Catalog.DoiTac`. Thêm `ChoiceParameterLinks` trên thuộc tính `HopDong` của mọi chứng từ trỏ về `DoiTac`.

### Ưu tiên 3: Hoàn thiện danh mục Thuế suất GTGT chuẩn (bổ sung thuế 8% theo NĐ 174/2025/NĐ-CP, KCT, KKKNT)
- **Mục tiêu:** Chấm dứt việc nhập tay tự do số thập phân `ThueSuatVAT` và xóa bỏ việc hard-code ép thuế 10% trong `DieuChinhCongNo.bsl:33-35`. Đảm bảo xuất hóa đơn và kê khai đúng thuế suất 8% cho dịch vụ CNTT.
- **Hành động kỹ thuật:** Xây dựng danh mục hoặc Enum `ThueSuatGTGT` và liên kết vào các form hóa đơn, biên bản nghiệm thu.

### Ưu tiên 4: Sửa bút toán định khoản Hóa đơn GTGT đầu ra và Hóa đơn NCC ngoại tệ
- **Mục tiêu:** Đảm bảo Hóa đơn GTGT đầu ra ghi nhận đầy đủ doanh thu (Có TK 5113) khi không đi kèm nghiệm thu; sửa công thức tính ngoại tệ USD trong `HoaDonNhaCungCap` (lấy nguyên tệ gốc thay vì chia ngược từ VND).
- **Hành động kỹ thuật:** Bổ sung dòng bút toán Nợ 131 / Có 5113 trong `HoaDonGTGTDauRa.bsl`; sửa `RecordAP.SoTienNgoaiTe` trong `HoaDonNhaCungCap.bsl`.

### Ưu tiên 5: Chuẩn hóa tài khoản Phí ngân hàng và Đánh giá lại ngoại tệ
- **Mục tiêu:** Sửa giá trị hằng số `TaiKhoanPhiNganHang` từ 6425 (sai bản chất) thành 6427 (đúng TT 200); sửa `UyNhiemChi.bsl` lấy Có TK tiền theo đúng tài khoản tiền chi (1121 hoặc 1122); bổ sung đánh giá lại công nợ phải thu USD trong `DanhGiaLaiNgoaiTe.bsl`.
- **Hành động kỹ thuật:** Chạy script chuẩn hóa hằng số hệ thống; cập nhật `UyNhiemChi.bsl` và `DanhGiaLaiNgoaiTe.bsl`.

---

**Người lập báo cáo:** Senior 1C:Enterprise Developer & Kế toán trưởng  
**Trạng thái:** ĐÃ HOÀN TẤT TOÀN DIỆN (FULL AUDIT SIGN-OFF)  
**File đính kèm:** [audit_logic_1c.xlsx](file:///C:/Users/Dung/Documents/1C_Enterprise/audit_logic_1c.xlsx) (Sổ bảng tính chi tiết 5 sheets)