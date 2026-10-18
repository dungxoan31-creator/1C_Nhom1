# 07 — LOG VIỆT HÓA GIAO DIỆN + KẾT QUẢ TEST LOGIC

> Ngày: 16/10/2026. Dựa trên nhánh sửa lỗi Đợt 1–2 (`docs/06_LOG_SUA_LOI.md`).
> File `.dt` trong gói: `VinSmart_Future_AR_AP_Full.dt` = cấu hình đã sửa + Việt hóa, dữ liệu giữ nguyên bản trước.
> Bộ test thủ công cho Thuận: `docs/08_KICH_BAN_TEST_CHI_TIET.xlsx`.

## 1. Vì sao trước đây giao diện hiện tiếng Anh

Cấu hình chỉ khai báo **một ngôn ngữ: English (mã `en`)**. Các bản dịch tiếng Việt (`vi`) đã có sẵn trong 319 tên hiển thị nhưng 1C bỏ qua, vì cấu hình không có ngôn ngữ `vi`. 134 tên khác chỉ có bản `en`.

## 2. Các bước đã làm (thao tác trong Designer — đã làm bằng script `scripts/localize_vi.py`, chạy lại được)

1. **Cấu hình → Chung → Ngôn ngữ → Thêm** ngôn ngữ `TiengViet`, Mã ngôn ngữ = `vi`, tên hiển thị "Tiếng Việt".
2. **Thuộc tính cấu hình → Ngôn ngữ chính (Default language) = TiengViet.** Người dùng không đặt ngôn ngữ riêng sẽ dùng tiếng Việt (toàn bộ người dùng mẫu).
3. Với mọi tên đồng nghĩa (Synonym), tiêu đề (Title), chú thích (ToolTip): thêm bản `vi` cho 134 chỗ còn thiếu; chuẩn hóa 48 thuật ngữ theo kế toán Việt Nam (bảng mục 4).
4. Thông báo lỗi còn tiếng Anh trong code: Bảng kê đối soát (4 thông báo) và Hạn mức & chặn xuất dịch vụ (1 thông báo) → viết lại tiếng Việt có dấu. Các thông báo `NStr("vi = ...; en = ...")` có sẵn tự hiện tiếng Việt.
5. Nạp cấu hình (`/LoadConfigFromFiles`) → Kiểm tra cấu hình (`/CheckConfig`, như F7) → Cập nhật CSDL (`/UpdateDBCfg`) → Xuất `.dt` (`/DumpIB`).
6. Giữ ngôn ngữ English để ai cần vẫn chuyển được (đặt ngôn ngữ người dùng = English).

## 3. Chữ của nền tảng 1C (Search, Favorites, More actions, Create, Post...)

Các chữ chuẩn của nền tảng **không nằm trong cấu hình**; 1C hiển thị theo ngôn ngữ giao diện của chương trình (mặc định lấy theo ngôn ngữ hệ điều hành). Đã thử trên máy Huy (1C Training 8.3.27, macOS): mặc định còn tiếng Anh; thêm tham số `/L vi /VL vi` thì cả chữ của nền tảng cũng hiện tiếng Việt (Huy đã thử, 16/10/2026).

Cách bật cố định (làm 1 lần trên mỗi máy):
1. Mở 1C (cửa sổ danh sách infobase) → chọn infobase → **Sửa (Edit)**.
2. Bấm **Tiếp (Next)** tới trang cuối → ô **Tham số khởi động bổ sung (Additional launch parameters)** gõ: `/L vi /VL vi` → **Xong (Finish)**.
3. Mở lại infobase.

Nếu bộ cài 1C trên máy không có gói tiếng Việt, chữ nền tảng vẫn tiếng Anh (chữ của cấu hình vẫn tiếng Việt) — **Cần xác nhận** trên máy Windows 8.3.22 của nhóm.

## 4. Bảng dịch Anh → Việt

### 4.1. Các mục trong yêu cầu

| Tiếng Anh | Tiếng Việt |
|---|---|
| Quick menu | Trang chủ / menu nhanh (chữ nền tảng — bật bằng `/L vi`) |
| Search (Ctrl+F) | Tìm kiếm (chữ nền tảng — bật bằng `/L vi`) |
| Netting & Settlement | 4. Cấn trừ công nợ (Netting) |
| Master Data | 6. Danh mục |
| Cash & Banking | 3. Ngân hàng & Quỹ |
| Accounts Receivable (AR) | 1. Công nợ phải thu (AR) |
| Accounts Payable (AP) | 2. Công nợ phải trả (AP) |
| General Ledger & CFO Dashboard | 5. Sổ cái & Bảng điều hành CFO |
| Phase Acceptance Minute | Biên bản nghiệm thu giai đoạn |
| Output VAT Invoice | Hóa đơn GTGT đầu ra |
| Customer Payment Receipt | Phiếu thu tiền khách hàng |
| AP Vendor Invoice | Hóa đơn đầu vào (nhà cung cấp) |
| Payment Order | Ủy nhiệm chi |
| Intercompany Netting Document | Cấn trừ công nợ nội bộ |
| Bank Credit Advice | Giấy báo Có ngân hàng |

### 4.2. Toàn bộ tên hiển thị của cấu hình (đối tượng, trường, trạng thái, vai trò, hằng số)

**Tên ứng dụng**

| Đối tượng | Tiếng Anh (en) | Tiếng Việt (vi) |
|---|---|---|
| Configuration.xml | VINSMART FUTURE - Finance & Accounting System | VINSMART FUTURE - Hệ Thống Tài Chính & Kế Toán |

**Phân hệ (menu)**

| Đối tượng | Tiếng Anh (en) | Tiếng Việt (vi) |
|---|---|---|
| PhanHeCanTruNetting | Netting & Settlement | 4. Cấn trừ công nợ (Netting) |
| PhanHeDanhMuc | Master Data | 6. Danh mục |
| PhanHeNganHangVaQuy | Cash & Banking | 3. Ngân hàng & Quỹ |

**Ảnh phân hệ**

| Đối tượng | Tiếng Anh (en) | Tiếng Việt (vi) |
|---|---|---|
| LogoVSF | VSF Logo | Logo VinSmart Future |
| PhanHeCanTruNetting | Intercompany Netting | 4. Cấn trừ công nợ (Netting) |
| PhanHeDanhMuc | Master Data Catalogs | 6. Danh mục |
| PhanHeNganHangVaQuy | Banking & Treasury | 3. Ngân hàng & Quỹ |
| PhanHePhaiThu | Accounts Receivable (AR) | 1. Công nợ phải thu (AR) |
| PhanHePhaiTra | Accounts Payable (AP) | 2. Công nợ phải trả (AP) |
| PhanHeSoCaiVaDongBo | General Ledger & CFO Dashboard | 5. Sổ cái & Bảng điều hành CFO |

**Chứng từ**

| Đối tượng | Tiếng Anh (en) | Tiếng Việt (vi) |
|---|---|---|
| BangKeDoiSoatKenhThanhToan | Payment Gateway Reconciliation Statement | Bảng kê đối soát kênh thanh toán |
| BangKeDoiSoatKenhThanhToan | Payment Gateway | Kênh thanh toán |
| BangKeDoiSoatKenhThanhToan | Bank Account | Tài khoản ngân hàng nhận |
| BangKeDoiSoatKenhThanhToan | Cash Flow Item | Khoản mục dòng tiền |
| BangKeDoiSoatKenhThanhToan | Start Date | Ngày bắt đầu |
| BangKeDoiSoatKenhThanhToan | End Date | Ngày kết thúc |
| BangKeDoiSoatKenhThanhToan | Total Amount | Tổng tiền giao dịch |
| BangKeDoiSoatKenhThanhToan | Total Gateway Fee | Tổng phí kênh thanh toán |
| BangKeDoiSoatKenhThanhToan | Total Net Received | Tổng số tiền thực nhận |
| BangKeDoiSoatKenhThanhToan | Status | Trạng thái |
| BangKeDoiSoatKenhThanhToan | Created By | Người lập |
| BangKeDoiSoatKenhThanhToan | Approved By | Người duyệt |
| BangKeDoiSoatKenhThanhToan | Transaction Details | Chi tiết giao dịch |
| BangKeDoiSoatKenhThanhToan | Gateway Txn ID | Mã giao dịch kênh thanh toán |
| BangKeDoiSoatKenhThanhToan | Txn Date | Ngày giao dịch |
| BangKeDoiSoatKenhThanhToan | Gateway Fee | Phí kênh thanh toán |
| BangKeDoiSoatKenhThanhToan | Net Amount | Số tiền thực nhận |
| BangKeDoiSoatKenhThanhToan | Partner | Đối tác / Khách hàng |
| BangKeDoiSoatKenhThanhToan | Is Matched | Đã khớp |
| BaoCoNganHang | Bank Credit Advice | Giấy báo Có ngân hàng |
| BaoCoNganHang | Bank Account | Tài khoản ngân hàng |
| BaoCoNganHang | Received Amount | Số tiền nhận |
| BaoCoNganHang | Transaction Date | Ngày giao dịch |
| BaoCoNganHang | Bank Txn ID | Mã giao dịch ngân hàng |
| BaoCoNganHang | Transfer Description | Nội dung chuyển khoản |
| BaoCoNganHang | Virtual Account | Tài khoản ảo (VA) |
| BaoCoNganHang | Matched Partner | Đối tác khớp |
| BaoCoNganHang | Matched Document | Chứng từ khớp |
| BaoCoNganHang | Auto Posted | Tự động ghi sổ |
| BienBanNghiemThuGiaiDoan | Phase Acceptance Minute | Biên bản nghiệm thu giai đoạn |
| BienBanNghiemThuGiaiDoan | Net Acceptance Amount | Giá trị nghiệm thu chưa thuế GTGT |
| BienBanNghiemThuGiaiDoan | VAT Rate (%) | Thuế suất GTGT (%) |
| BienBanNghiemThuGiaiDoan | VAT Amount | Tiền thuế GTGT |
| BienBanNghiemThuGiaiDoan | Total Amount | Tổng giá trị |
| BienBanNghiemThuGiaiDoan | Creator | Người tạo |
| BienBanNghiemThuGiaiDoan | Approver | Người duyệt |
| BienBanNghiemThuGiaiDoan | Acceptance Date | Ngày nghiệm thu |
| CanTruCongNoNoiBo | Intercompany Netting Document | Cấn trừ công nợ nội bộ |
| CanTruCongNoNoiBo | Intercompany Partner | Đối tác nội bộ Vingroup |
| CanTruCongNoNoiBo | AR Contract | Hợp đồng phải thu (AR) |
| CanTruCongNoNoiBo | AP Contract | Hợp đồng phải trả (AP) |
| CanTruCongNoNoiBo | Original AR Document | Chứng từ gốc AR |
| CanTruCongNoNoiBo | Original AP Document | Chứng từ gốc AP |
| CanTruCongNoNoiBo | Netting Amount | Số tiền cấn trừ |
| CanTruCongNoNoiBo | Is Multilateral Bridge | Là cấn trừ bắc cầu (Đa bên) |
| CanTruCongNoNoiBo | Bridge Partner | Đối tác trung gian |
| CanTruCongNoNoiBo | Tripartite Agreement No | Số văn bản thỏa thuận |
| DanhGiaLaiNgoaiTe | Period-End FX Revaluation | Đánh giá lại số dư ngoại tệ cuối kỳ |
| DanhGiaLaiNgoaiTe | Cutoff Date | Ngày chốt đánh giá |
| DanhGiaLaiNgoaiTe | Revaluation Rate | Tỷ giá đánh giá lại |
| DanhGiaLaiNgoaiTe | Total FX Gain (515) | Tổng lãi tỷ giá (515) |
| DanhGiaLaiNgoaiTe | Total FX Loss (635) | Tổng lỗ tỷ giá (635) |
| DanhGiaLaiNgoaiTe | Accounting Standard | Chuẩn mực kế toán áp dụng |
| DanhGiaLaiNgoaiTe | Preparer | Người lập |
| DeNghiThanhToanDichVu | Service Payment Requisition | Đề nghị thanh toán dịch vụ |
| DeNghiThanhToanDichVu | Payee | Người thụ hưởng |
| DeNghiThanhToanDichVu | Base Document | Chứng từ gốc |
| DeNghiThanhToanDichVu | Requested Amount | Số tiền đề nghị |
| DeNghiThanhToanDichVu | Due Date | Hạn thanh toán |
| DeNghiThanhToanDichVu | Requested By | Người đề nghị |
| DeNghiThanhToanDichVu | Over Budget | Vượt ngân sách |
| DieuChinhCongNo | Debt Adjustment | Điều chỉnh công nợ |
| DieuChinhCongNo | Acceptance Report | Biên bản nghiệm thu |
| DieuChinhCongNo | Adjusted Invoice | Hóa đơn điều chỉnh |
| DieuChinhCongNo | Agreement Document Number | Số văn bản thỏa thuận |
| DieuChinhCongNo | Agreement Date | Ngày văn bản thỏa thuận |
| DieuChinhCongNo | Adjustment Reason | Lý do điều chỉnh |
| DieuChinhCongNo | Revenue Reduction | Giảm doanh thu |
| DieuChinhCongNo | VAT Reduction | Giảm thuế GTGT |
| DieuChinhCongNo | Total Reduction Amount | Tổng tiền giảm |
| HoaDonGTGTDauRa | Output VAT Invoice | Hóa đơn GTGT đầu ra |
| HoaDonGTGTDauRa | Buyer Tax Code | Mã số thuế |
| HoaDonGTGTDauRa | Buyer Address | Địa chỉ |
| HoaDonGTGTDauRa | Invoice Number | Số hóa đơn |
| HoaDonGTGTDauRa | Invoice Serial | Ký hiệu hóa đơn |
| HoaDonGTGTDauRa | Invoice Date | Ngày hóa đơn |
| HoaDonGTGTDauRa | Subtotal Amount | Thành tiền chưa thuế |
| HoaDonGTGTDauRa | Total Payment Amount | Tổng tiền thanh toán |
| HoaDonGTGTDauRa | e-Invoice Status | Trạng thái hóa đơn điện tử |
| HoaDonGTGTDauRa | Tax Authority Code | Mã của cơ quan thuế |
| HoaDonNhaCungCap | AP Vendor Invoice | Hóa đơn đầu vào (nhà cung cấp) |
| HoaDonNhaCungCap | Vendor | Nhà cung cấp |
| HoaDonNhaCungCap | Total Amount VND | Tổng tiền VND |
| HoaDonNhaCungCap | Total Amount FCY | Tổng tiền ngoại tệ |
| HoaDonNhaCungCap | Service Amount | Tiền dịch vụ |
| HoaDonNhaCungCap | Has Withholding FCT | Có khấu trừ thuế nhà thầu (FCT) |
| HoaDonNhaCungCap | FCT VAT Rate (%) | Tỷ lệ thuế GTGT nhà thầu (%) |
| HoaDonNhaCungCap | FCT CIT Rate (%) | Tỷ lệ thuế TNDN nhà thầu (%) |
| HoaDonNhaCungCap | FCT VAT Amount | Thuế GTGT nhà thầu |
| HoaDonNhaCungCap | FCT CIT Amount | Thuế TNDN nhà thầu |
| HoaDonNhaCungCap | VSF Expense | Chi phí VSF |
| HoaDonNhaCungCap | Net Payable to Vendor | Số tiền thực trả nhà cung cấp |
| HoaDonNhaCungCap | Expense Account | Tài khoản chi phí |
| NghiemThuThauPhu | Subcontractor Acceptance | Nghiệm thu thầu phụ |
| NghiemThuThauPhu | Subcontractor | Thầu phụ |
| NghiemThuThauPhu | Acceptance Value | Giá trị nghiệm thu |
| NghiemThuThauPhu | Total Value | Tổng giá trị |
| PhieuThuTienKhachHang | Customer Payment Receipt | Phiếu thu tiền khách hàng |
| PhieuThuTienKhachHang | Amount (VND) | Số tiền (VND) |
| PhieuThuTienKhachHang | Foreign Currency Amount | Số tiền ngoại tệ |
| PhieuThuTienKhachHang | Receipt Date | Ngày thu |
| UyNhiemChi | Payment Order | Ủy nhiệm chi |
| UyNhiemChi | Payment Amount | Số tiền chi |
| UyNhiemChi | FCY Amount | Số tiền ngoại tệ |
| UyNhiemChi | Bank Fee | Phí ngân hàng |
| UyNhiemChi | Created Date | Ngày lập |
| UyNhiemChi | Posting Date | Ngày ghi sổ |
| UyNhiemChi | Is Reversal Return | Là chứng từ hoàn trả (tra soát) |
| YeuCauHoanTienChiHo | Customer Refund Payment Order | Yêu cầu hoàn tiền chi hộ B2C |
| YeuCauHoanTienChiHo | Customer / Partner | Khách hàng hoàn tiền |
| YeuCauHoanTienChiHo | Contract | Hợp đồng dịch vụ |
| YeuCauHoanTienChiHo | Disbursement Account | Tài khoản ngân hàng chi |
| YeuCauHoanTienChiHo | Original Txn ID | Mã giao dịch gốc |
| YeuCauHoanTienChiHo | Refund Amount | Số tiền hoàn |
| YeuCauHoanTienChiHo | Refund Fee | Phí hoàn tiền |
| YeuCauHoanTienChiHo | Refund Reason | Lý do hoàn tiền |

**Danh mục**

| Đối tượng | Tiếng Anh (en) | Tiếng Việt (vi) |
|---|---|---|
| DichVuCNTT | Dịch vụ CNTT (IT Services) | Dịch vụ CNTT |
| DichVuCNTT | Mã dịch vụ | Mã dịch vụ |
| DichVuCNTT | Tên dịch vụ | Tên dịch vụ |
| DichVuCNTT | Tỷ lệ VAT mặc định (%) | Thuế suất GTGT mặc định (%) |
| DoiTac | Đối tác (Counterparties) | Đối tác |
| DoiTac | Là bên liên kết | Là bên liên kết |
| DoiTac | Đã đăng ký thuế trực tiếp | Đã đăng ký thuế trực tiếp |
| DoiTac | Loại đối tác | Loại đối tác |
| DoiTac | Tax Identification Number | Mã số thuế |
| DoiTac | Address | Địa chỉ |
| DoiTac | Bank Account Number | Số tài khoản ngân hàng |
| DoiTac | Bank Name | Tên ngân hàng |
| DuAn | Dự án (Projects) | Dự án |
| DuAn | Mã dự án | Mã dự án |
| DuAn | Tên dự án | Tên dự án |
| HopDong | Hợp đồng (Contracts) | Hợp đồng |
| HopDong | Chủ sở hữu (Đối tác) | Chủ sở hữu (Đối tác) |
| HopDong | Gross-up thuế | Tính gộp thuế (gross-up) |
| HopDong | Hạn thanh toán (ngày) | Hạn thanh toán (ngày) |
| HopDong | Đồng tiền thanh toán | Đồng tiền thanh toán |
| KenhThanhToan | Kênh thanh toán (Payment Channels) | Kênh thanh toán |
| KenhThanhToan | Mã kênh | Mã kênh |
| KenhThanhToan | Tên kênh | Tên kênh |
| KhoanMucDongTien | Khoản mục dòng tiền (Cash Flow Items) | Khoản mục dòng tiền |
| KhoanMucDongTien | Loại dòng tiền | Loại dòng tiền |
| PhapNhan | Pháp nhân (Entities) | Pháp nhân |
| PhapNhan | Mã số thuế | Mã số thuế |
| PhapNhan | Địa chỉ | Địa chỉ |
| TaiKhoanAo | Tài khoản ảo (Virtual Accounts) | Tài khoản ảo |
| TaiKhoanAo | Số tài khoản ảo | Số tài khoản ảo |
| TaiKhoanAo | Ngân hàng | Ngân hàng |
| TaiKhoanTien | Tài khoản tiền (Cash Accounts) | Tài khoản tiền |
| TaiKhoanTien | Số tài khoản | Số tài khoản |
| TienTe | Tiền tệ (Currencies) | Tiền tệ |
| TienTe | Mã tiền tệ (ISO 4217) | Mã tiền tệ (ISO 4217) |
| TienTe | Tên đầy đủ | Tên đầy đủ |

**Liệt kê/Trạng thái**

| Đối tượng | Tiếng Anh (en) | Tiếng Việt (vi) |
|---|---|---|
| HuongDongTien | Cash Flow Direction | Hướng dòng tiền |
| HuongDongTien | Thu | Thu tiền |
| HuongDongTien | Chi | Chi tiền |
| LoaiDoiTac | Counterparty Type | Loại đối tác |
| LoaiDoiTac | Khách hàng ngoài | Khách hàng ngoài |
| LoaiDoiTac | Nội bộ Vingroup | Nội bộ Vingroup |
| LoaiDoiTac | Nhà cung cấp Cloud | Nhà cung cấp Cloud |
| LoaiDoiTac | Nhà cung cấp linh kiện | Nhà cung cấp linh kiện |
| LoaiDoiTac | Thầu phụ CNTT | Thầu phụ CNTT |
| LoaiDoiTac | Khách hàng và Nhà cung cấp | Khách hàng và Nhà cung cấp |
| LoaiDoiTac | Khách hàng | Khách hàng |
| LoaiDoiTac | Nhà cung cấp | Nhà cung cấp |
| LoaiDoiTac | Nội bộ tập đoàn | Nội bộ tập đoàn |
| TrangThaiCanTru | Netting Status | Trạng thái cấn trừ |
| TrangThaiCanTru | Dự thảo | Dự thảo |
| TrangThaiCanTru | Chờ duyệt nội bộ | Chờ duyệt nội bộ |
| TrangThaiCanTru | Chờ tập đoàn duyệt | Chờ tập đoàn duyệt |
| TrangThaiCanTru | Chờ cấn trừ | Chờ cấn trừ |
| TrangThaiCanTru | Đã tất toán | Đã tất toán |
| TrangThaiCanTru | Hủy bỏ | Hủy bỏ |
| TrangThaiHoaDonAP | AP Invoice Status | Trạng thái hóa đơn đầu vào |
| TrangThaiHoaDonAP | Chờ duyệt kỹ thuật | Chờ duyệt kỹ thuật |
| TrangThaiHoaDonAP | Chờ duyệt PM | Chờ Quản lý dự án duyệt |
| TrangThaiHoaDonAP | Chờ duyệt IT Director | Chờ Giám đốc hạ tầng CNTT duyệt |
| TrangThaiHoaDonAP | Chờ duyệt CFO | Chờ CFO duyệt |
| TrangThaiHoaDonAP | Chờ kế toán AP | Chờ kế toán phải trả |
| TrangThaiHoaDonAP | Đã ghi sổ | Đã ghi sổ |
| TrangThaiHoaDonAP | Từ chối | Từ chối |
| TrangThaiHoaDonDienTu | Chờ ký số | Chờ ký số |
| TrangThaiHoaDonDienTu | Đã phát hành | Đã phát hành |
| TrangThaiHoaDonDienTu | Đã điều chỉnh | Đã điều chỉnh |
| TrangThaiHoaDonDienTu | Đã thay thế | Đã thay thế |
| TrangThaiHoaDonDienTu | Đã hủy | Đã hủy |
| TrangThaiLenhThanhToan | Payment Order Status | Trạng thái ủy nhiệm chi |
| TrangThaiLenhThanhToan | Chờ duyệt | Chờ duyệt |
| TrangThaiLenhThanhToan | Đã duyệt | Đã duyệt |
| TrangThaiLenhThanhToan | Đã gửi ngân hàng | Đã gửi ngân hàng |
| TrangThaiNghiemThuAR | AR Acceptance Status | Trạng thái nghiệm thu phải thu |
| TrangThaiNghiemThuAR | Đã duyệt nội bộ | Đã duyệt nội bộ |
| TrangThaiNghiemThuAR | Chờ đối tác ký | Chờ đối tác ký |
| TrangThaiNghiemThuAR | Đã thanh toán một phần | Đã thanh toán một phần |
| TrangThaiNghiemThuAR | Tranh chấp | Tranh chấp |

**Sổ cái**

| Đối tượng | Tiếng Anh (en) | Tiếng Việt (vi) |
|---|---|---|
| SoCaiKeToan | General Ledger | Sổ cái kế toán |
| SoCaiKeToan | Legal Entity | Pháp nhân |
| SoCaiKeToan | Currency | Tiền tệ |
| SoCaiKeToan | Amount | Số tiền |
| SoCaiKeToan | Currency Amount | Số tiền ngoại tệ |
| SoCaiKeToan | Original Document | Chứng từ gốc |
| SoCaiKeToan | Exchange Rate | Tỷ giá |
| SoCaiKeToan | Description | Diễn giải |
| SoCaiKeToan | Counterparty | Đối tác |
| SoCaiKeToan | Contract | Hợp đồng |
| SoCaiKeToan | Cash Account | Tài khoản tiền |

**Hệ thống TK**

| Đối tượng | Tiếng Anh (en) | Tiếng Việt (vi) |
|---|---|---|
| HeThongTaiKhoan | Chart of Accounts | Hệ thống tài khoản |
| HeThongTaiKhoan | Logical Code | Mã logic |
| HeThongTaiKhoan | Account Name | Tên tài khoản |
| HeThongTaiKhoan | Nature | Tính chất |

**Sổ tích lũy**

| Đối tượng | Tiếng Anh (en) | Tiếng Việt (vi) |
|---|---|---|
| CongNoPhaiThu | Công nợ phải thu (AR Subledger) | Sổ chi tiết công nợ phải thu |
| CongNoPhaiThu | Số tiền (VND) | Số tiền (VND) |
| CongNoPhaiThu | Số tiền ngoại tệ | Số tiền ngoại tệ |
| CongNoPhaiThu | Pháp nhân | Pháp nhân |
| CongNoPhaiThu | Đối tác | Đối tác |
| CongNoPhaiThu | Hợp đồng | Hợp đồng |
| CongNoPhaiThu | Chứng từ gốc | Chứng từ gốc |
| CongNoPhaiTra | Công nợ phải trả (AP Subledger) | Sổ chi tiết công nợ phải trả |
| DongTien | Dòng tiền (Cash Flow & FX) | Sổ chi tiết dòng tiền |
| DongTien | Số tiền ngoại tệ (USD) | Số tiền ngoại tệ (USD) |
| DongTien | Tài khoản tiền | Tài khoản tiền |
| DongTien | Tiền tệ | Tiền tệ |
| DongTien | Khoản mục dòng tiền | Khoản mục dòng tiền |
| GiaoDichDienTuTamGiu | Giao dịch điện tử tạm giữ (Clearing / Escrow) | Giao dịch điện tử tạm giữ |
| GiaoDichDienTuTamGiu | Số tiền | Số tiền |
| GiaoDichDienTuTamGiu | Phí kênh thanh toán | Phí kênh thanh toán |
| GiaoDichDienTuTamGiu | Kênh thanh toán | Kênh thanh toán |
| GiaoDichDienTuTamGiu | Mã giao dịch kênh | Mã giao dịch kênh thanh toán |

**Sổ thông tin**

| Đối tượng | Tiếng Anh (en) | Tiếng Việt (vi) |
|---|---|---|
| HanMucVaChanXuatDichVu | Credit Limits and Service Delivery Blocking | Hạn mức và chặn xuất dịch vụ |
| HanMucVaChanXuatDichVu | Credit Limit | Hạn mức công nợ |
| HanMucVaChanXuatDichVu | Lock Status | Trạng thái khóa |
| HanMucVaChanXuatDichVu | Lock Reason | Lý do khóa |
| KeHoachChiTien | Cash Disbursement Plan | Kế hoạch chi tiền |
| KeHoachChiTien | Budget Amount | Số tiền ngân sách |
| KeHoachChiTien | Approved Amount | Số tiền đã duyệt |
| KeHoachChiTien | Actual Disbursed Amount | Số tiền thực chi |
| KeHoachChiTien | Month | Tháng |
| KeHoachChiTien | Project | Dự án |
| TyGiaHoiDoai | Exchange Rates | Tỷ giá hối đoái |
| TyGiaHoiDoai | Buying Rate | Tỷ giá mua |
| TyGiaHoiDoai | Selling Rate | Tỷ giá bán |
| TyGiaHoiDoai | Accounting Rate | Tỷ giá hạch toán |

**Báo cáo**

| Đối tượng | Tiếng Anh (en) | Tiếng Việt (vi) |
|---|---|---|
| BaoCaoTuoiNoPhanTachNoiBo | Aging Report with Intercompany Segregation | Báo cáo tuổi nợ phân tách nội bộ |
| CanhBaoHanMucVaGiaHanCloud | Cloud Quota and Renewal Warning Report | Cảnh báo hạn mức và gia hạn Cloud |
| DoiSoatKenhThanhToanVaDongTienAo | Payment Gateway and Virtual Account Reconciliation Report | Đối soát kênh thanh toán và dòng tiền ảo |
| MaTranCanTruNoiBoTapDoan | Intercompany Netting Matrix Report | Ma trận cấn trừ nội bộ tập đoàn |

**Xử lý**

| Đối tượng | Tiếng Anh (en) | Tiếng Việt (vi) |
|---|---|---|
| DashboardLanhDaoCFO | Executive CFO Dashboard | Bảng điều hành CFO |
| Form | — | Trang bảng điều hành |
| Form | Refresh | Làm mới |
| Form | — | Cập nhật số liệu tức thì |
| DongCoDoiSoatTuDong | Automated Reconciliation Engine | Đối soát tự động |
| LapMaTranCanTruTapDoan | Intercompany Netting Matrix Generator | Lập ma trận cấn trừ tập đoàn |
| LapMaTranCanTruTapDoan | Initiator Entity | Pháp nhân khởi tạo |
| LapMaTranCanTruTapDoan | Cutoff Date | Ngày chốt công nợ |
| LapMaTranCanTruTapDoan | Netting Type | Hình thức cấn trừ |
| LapMaTranCanTruTapDoan | Timeout in Minutes | Thời gian chờ (phút) |
| LapMaTranCanTruTapDoan | Note | Ghi chú |
| NapSoDuDauKy | Opening Balance Migration | Nạp số dư đầu kỳ |

**Hằng số**

| Đối tượng | Tiếng Anh (en) | Tiếng Việt (vi) |
|---|---|---|
| CanhBaoCloudMucCam | Cloud Warning Orange Level (Days) | Ngưỡng cảnh báo Cloud mức cam (ngày) |
| CanhBaoCloudMucDo | Cloud Warning Red Level (Days) | Ngưỡng cảnh báo Cloud mức đỏ (ngày) |
| CanhBaoCloudMucVang | Cloud Warning Yellow Level (Days) | Ngưỡng cảnh báo Cloud mức vàng (ngày) |
| ChoPhepSinhDuLieuMau | Allow sample data generation on UAT clone | Cho phép sinh dữ liệu mẫu trên bản sao UAT |
| GiaTriFIFOMax | Max FIFO Value | Giá trị tối đa phân bổ FIFO |
| NguongPheDuyetChiTienCFO | CFO Payment Approval Threshold | Ngưỡng chi tiền cần CFO phê duyệt |
| NguongThanhToanKhongDungTienMat | Non-Cash Payment Threshold | Ngưỡng thanh toán không dùng tiền mặt |
| PhapNhanMacDinh | Default Legal Entity | Pháp nhân mặc định |
| SoLuongHoaDonFIFOMax | Max FIFO Invoice Count | Số hóa đơn tối đa phân bổ FIFO |
| TaiKhoanPhiNganHang | Bank Fee Account | Tài khoản phí ngân hàng |
| TaiKhoanTrungGianCanTru | Netting Intermediate Account | Tài khoản trung gian cấn trừ |
| TimeoutChoCanTruPhut | Netting Timeout (Minutes) | Thời gian chờ cấn trừ (phút) |

**Vai trò**

| Đối tượng | Tiếng Anh (en) | Tiếng Việt (vi) |
|---|---|---|
| ChuyenVienDoiSoatTapDoan | Group Reconciliation Specialist | Chuyên viên đối soát tập đoàn |
| GiamDocTaiChinh_CFO | Chief Financial Officer | Giám đốc tài chính (CFO) |
| ITDirector_GiamDocHaTang | IT Infrastructure Director | Giám đốc hạ tầng CNTT |
| KeToanPhaiThu | AR Accountant | Kế toán phải thu |
| KeToanPhaiTra | AP Accountant | Kế toán phải trả |
| KeToanTruong | Chief Accountant | Kế toán trưởng |
| ProjectManager_QuanLyDuAn | Project Manager | Quản lý dự án (PM) |
| QuanTriHeThong | System Administrator | Quản trị hệ thống |
| TechLead_KiemTraKyThuat | Technical Lead | Trưởng nhóm kỹ thuật |

**Ngôn ngữ**

| Đối tượng | Tiếng Anh (en) | Tiếng Việt (vi) |
|---|---|---|
| English | English | Tiếng Anh |
| TiengViet | Vietnamese | Tiếng Việt |

Ghi chú: một số tên tiếng Anh gốc vốn đã là tiếng Việt (vd danh mục, trạng thái) — giữ nguyên, chỉ bỏ phần tiếng Anh trong ngoặc ở bản `vi`.

## 5. Test logic tự động trên 1C

Chạy trên máy Huy, 1C Training 8.3.27, trên **bản sao** nạp lại từ chính file `.dt` trong gói (kiểm tra luôn việc file `.dt` nạp lại được). Script: `scripts/build_and_test_mac.sh`. Mỗi lệnh chạy bằng đúng tài khoản thật (đăng nhập riêng từng người).

**Tổng: 232 ca — 207 ĐẠT, 0 TRƯỢT, 25 BỎ QUA** (bỏ qua = ca không áp dụng cho vai trò của người đang đăng nhập).

| Bộ test | Nội dung | Tài khoản | Đạt | Trượt | Bỏ qua |
|---|---|---|---|---|---|
| RunE2E (quy trình nhiều người) | Quy trình đầu-cuối nhiều người (xem mục 5.1) | cfo_giamdoc, it_director, ketoan_ap, ketoan_ar, ketoan_truong, pm_duan, techlead_kythuat | 46 | 0 | 0 |
| ExportTrialBalanceEvidence_sau | Bảng cân đối phát sinh cân; sổ cái khớp sổ chi tiết AR/AP/ngân hàng (trước và sau khi chạy các test có ghi dữ liệu) | Admin | 1 | 0 | 0 |
| ExportTrialBalanceEvidence_truoc | Bảng cân đối phát sinh cân; sổ cái khớp sổ chi tiết AR/AP/ngân hàng (trước và sau khi chạy các test có ghi dữ liệu) | Admin | 1 | 0 | 0 |
| RunHardeningUAT | Chặn sinh dữ liệu mẫu ngoài bản sao, giao dịch an toàn, chặn sửa trạng thái sai | Admin | 3 | 0 | 0 |
| RunPostingLifecycleTests | Ghi sổ → hủy ghi sổ → ghi sổ lại: hủy sạch bút toán, ghi lại ra đúng bút toán cũ | ketoan_truong | 3 | 0 | 0 |
| RunRBACChecks | Phân quyền khi ghi chứng từ THẬT bằng từng tài khoản (đúng vai trò; chặn vượt quyền) | Admin, cfo_giamdoc, chuyenvien_doisoat, ketoan_ap, ketoan_ar, ketoan_truong | 12 | 0 | 0 |
| RunUnitTests | Bộ bảo mật theo phiên thật (maker-checker, phân tách nhiệm vụ, quyền báo cáo) + sổ cái khớp sổ chi tiết — chạy bằng cả 9 tài khoản | Admin, cfo_giamdoc, chuyenvien_doisoat, it_director, ketoan_ap, ketoan_ar, ketoan_truong, pm_duan, techlead_kythuat | 18 | 0 | 0 |
| VerifyContractFees | Biểu phí hợp đồng kênh thanh toán và tài khoản ảo | Admin | 1 | 0 | 0 |
| VerifyGLAnalyticKeys | Mọi dòng sổ cái có đủ đối tác/hợp đồng | Admin | 1 | 0 | 0 |
| Nhật ký (bộ bảo mật / Task2 / Task6) | Bộ bảo mật / Task 2 / Task 6 ghi nhật ký (từng dòng PASS/FAIL) | Admin, cfo_giamdoc, chuyenvien_doisoat, it_director, ketoan_ap, ketoan_ar, ketoan_truong, pm_duan, techlead_kythuat | 121 | 0 | 25 |

### 5.1. Quy trình đầu-cuối nhiều người (mỗi bước 1 tài khoản thật)

| Bước | Tài khoản | Ca kiểm tra | Kết quả | Chi tiết (lý do chặn / bút toán) |
|---|---|---|---|---|
| AP10 | ketoan_truong | AP10.1 Huy ghi so: xoa het but toan va so chi tiet, tra ve Cho ke toan AP | ĐẠT |  / GL=0 SCT dong=0 TT=ChoKeToanAP |
| AP10 | ketoan_truong | AP10.2 Ghi so lai cho cung but toan (55.000.000) | ĐẠT |  No 1331/Co 3311=5000000; No 627/Co 3311=50000000;  |
| AP1 | ketoan_ap | AP1.1 Ke toan AP luu nhap hoa don dau vao | ĐẠT |  |
| AP1 | ketoan_ap | AP1.2 Nguoi lap duoc he thong tu ghi = nguoi dang nhap (khong lay so nhap tay) | ĐẠT | NguoiLap=ketoan_ap |
| AP1 | ketoan_ap | AP1.3 Sua tay Nguoi lap bi chan | ĐẠT | Ly do bi chan: Không được sửa Người lập chứng từ (đang là 'ketoan_ap'). Người lập do hệ thống tự ghi nhận khi tạo chứng từ. |
| AP1 | ketoan_ap | AP1.4 Tu tinh tien dich vu = Tong - VAT = 50.000.000 | ĐẠT | TienDichVu=50,000,000 NoThucTraNCC=55,000,000 |
| AP1 | ketoan_ap | AP1.5 Nhay coc Du thao -> Cho duyet PM bi chan | ĐẠT | Ly do bi chan: Vi phạm nguyên tắc Maker-Checker: Người lập không thể tự chuyển chứng từ sang trạng thái 'ChoDuyetPM'! |
| AP1 | ketoan_ap | AP1.6 Gui duyet: Du thao -> Cho duyet ky thuat | ĐẠT |  |
| AP1 | ketoan_ap | AP1.7 Nguoi lap tu duyet buoc ky thuat bi chan | ĐẠT | Ly do bi chan: Vi phạm nguyên tắc Maker-Checker: Người lập không thể tự chuyển chứng từ sang trạng thái 'ChoDuyetPM'! |
| AP2 | pm_duan | AP2 pm_duan duyet buoc ky thuat (sai vai tro) bi chan | ĐẠT | Ly do bi chan: Bạn không có thẩm quyền duyệt bước 'ChoDuyetKyThuat'. Vai trò được phép: TechLead_KiemTraKyThuat,KeToanTruong. |
| AP3B | ketoan_ap | AP3B Nguoi lap sua so tien khi hoa don dang o buoc duyet PM bi chan | ĐẠT | Ly do bi chan: Người lập không được sửa chứng từ đã chuyển sang bước duyệt (trạng thái hiện tại: 'ChoDuyetPM')! |
| AP3 | techlead_kythuat | AP3.1 Tech Lead nhay thang sang Cho ke toan AP bi chan | ĐẠT | Ly do bi chan: Quy trình phê duyệt không hợp lệ: không được chuyển từ trạng thái 'ChoDuyetKyThuat' (đã lưu) sang 'ChoKeToanAP'. Chỉ được chuyển sang 'ChoKeToanAP' từ: ChoDuyetITDirector,ChoDuyetCFO. |
| AP3 | techlead_kythuat | AP3.2 Tech Lead duyet: Cho duyet ky thuat -> Cho duyet PM | ĐẠT |  |
| AP4 | pm_duan | AP4 PM duyet: Cho duyet PM -> Cho duyet IT Director | ĐẠT |  |
| AP5 | it_director | AP5 IT Director duyet -> Cho ke toan AP | ĐẠT |  |
| AP6 | cfo_giamdoc | AP6 Hoa don khong can CFO duyet (dung quy tac nguong) | ĐẠT | Trang thai: ChoKeToanAP |
| AP7 | ketoan_ar | AP7 Ke toan AR ghi so hoa don dau vao bi chan (phan tach nhiem vu) | ĐẠT | Ly do bi chan: Vi phạm phân định trách nhiệm (Segregation of Duties): Kế toán Phải thu (AR) không được phép ghi sổ, sửa hoặc can thiệp chứng từ Phải trả (AP)! |
| AP8 | ketoan_truong | AP8.1 Ke toan truong ghi so hoa don dau vao | ĐẠT |  |
| AP8 | ketoan_truong | AP8.2 But toan No 627 / Co 331x = 50.000.000 | ĐẠT | No 1331/Co 3311=5000000; No 627/Co 3311=50000000;  |
| AP8 | ketoan_truong | AP8.3 But toan No 1331 / Co 331x = 5.000.000 | ĐẠT | No 1331/Co 3311=5000000; No 627/Co 3311=50000000;  |
| AP8 | ketoan_truong | AP8.4 Tong phat sinh So cai = 55.000.000 | ĐẠT | No 1331/Co 3311=5000000; No 627/Co 3311=50000000;  |
| AP8 | ketoan_truong | AP8.5 So chi tiet cong no phai tra tang 55.000.000 (= Co 331x) | ĐẠT | So chi tiet=55,000,000 |
| AP9 | ketoan_ap | AP9 Ke toan AP huy ghi so bi chan (chi KTT/CFO) | ĐẠT | Ly do bi chan: Failed to save "Hóa đơn đầu vào (nhà cung cấp) E2EAP261016155323 dated 10/16/2026 3:53:23 PM"! / Chỉ Kế toán trưởng hoặc Giám đốc tài chính (CFO) được hủy ghi sổ chứng từ đã ghi sổ! |
| AR1 | ketoan_ar | AR1.1 Ke toan AR lap bien ban nghiem thu, gui duyet noi bo | ĐẠT |  |
| AR1 | ketoan_ar | AR1.2 Tu tinh thue GTGT 10% = 10.000.000, tong = 110.000.000; nguoi tao = nguoi dang nhap | ĐẠT | TienVAT=10,000,000 Tong=110,000,000 NguoiTao=ketoan_ar |
| AR1 | ketoan_ar | AR1.3 Nguoi lap tu duyet va ghi so bien ban bi chan | ĐẠT | Ly do bi chan: Vi phạm nguyên tắc Maker-Checker: Người dùng đăng nhập hiện tại là Người lập, không được phép phê duyệt! |
| AR2 | ketoan_ap | AR2 Ke toan AP ghi so bien ban nghiem thu (AR) bi chan | ĐẠT | Ly do bi chan: Vi phạm phân định trách nhiệm (Segregation of Duties): Kế toán Phải trả (AP) không được phép ghi sổ, sửa hoặc can thiệp chứng từ Phải thu (AR)! |
| AR3 | ketoan_truong | AR3.1 Ke toan truong duyet va ghi so bien ban; trang thai tu chuyen Da ghi so | ĐẠT |  |
| AR3 | ketoan_truong | AR3.2 But toan No 1311 / Co 5113 = 100.000.000 (chua ghi thue o buoc nghiem thu) | ĐẠT | No 1311/Co 5113=100000000;  |
| AR3 | ketoan_truong | AR3.3 So chi tiet cong no phai thu tang 100.000.000 | ĐẠT | So chi tiet=100,000,000 |
| AR4 | ketoan_ar | AR4.1 Ke toan AR lap hoa don GTGT theo bien ban, trang thai Cho ky so | ĐẠT |  |
| AR4 | ketoan_ar | AR4.2 Hoa don tu tinh thue GTGT = 10.000.000 va tong thanh toan = 110.000.000 | ĐẠT | VAT=10,000,000 Tong=110,000,000 |
| AR4 | ketoan_ar | AR4.3 Nguoi lap tu phat hanh va ghi so hoa don bi chan | ĐẠT | Ly do bi chan: Vi phạm nguyên tắc Maker-Checker: Người dùng đăng nhập hiện tại là Người lập, không được phép phê duyệt! |
| AR4 | ketoan_ar | AR4.4 Ke toan AR lap phieu thu 50.000.000 (chua ghi so) | ĐẠT |  |
| AR4 | ketoan_ar | AR4.5 Ke toan AR lap phieu thu thu 2: 100.000.000 (de kiem tra chan thu vuot) | ĐẠT |  |
| AR4 | ketoan_ar | AR4.6 Nguoi lap tu ghi so phieu thu bi chan | ĐẠT | Ly do bi chan: Vi phạm nguyên tắc Maker-Checker: Người dùng đăng nhập hiện tại là Người lập, không được phép phê duyệt! |
| AR5 | ketoan_truong | AR5.1 Ke toan truong phat hanh va ghi so hoa don GTGT | ĐẠT |  |
| AR5 | ketoan_truong | AR5.2 Hoa don theo bien ban chi ghi thue: No 1311 / Co 33311 = 10.000.000 (khong ghi lai doanh thu) | ĐẠT | No 1311/Co 33311=10000000;  |
| AR5 | ketoan_truong | AR5.3 Cong no cua bien ban sau hoa don = 110.000.000 | ĐẠT | So du=110,000,000 |
| AR5 | ketoan_truong | AR5.4 Ke toan truong ghi so phieu thu 50.000.000 | ĐẠT |  |
| AR5 | ketoan_truong | AR5.5 But toan No 1121 / Co 1311 = 50.000.000 | ĐẠT | No 1121/Co 1311=50000000;  |
| AR5 | ketoan_truong | AR5.6 So dong tien tang 50.000.000 | ĐẠT | Dong tien=50,000,000 |
| AR5 | ketoan_truong | AR5.7 Cong no con lai cua bien ban = 60.000.000 | ĐẠT | So du=60,000,000 |
| AR5 | ketoan_truong | AR5.8 Phieu thu 100.000.000 vuot so con no 60.000.000 bi chan | ĐẠT | Ly do bi chan: Failed to post "Phiếu thu tiền khách hàng E2EPX2610161554 dated 10/16/2026 3:54:43 PM"! / Số tiền thu vượt quá số dư phải thu còn lại của chứng từ gốc! |
| AR5 | ketoan_truong | AR5.9 Huy ghi so bien ban da co hoa don/phieu thu bi chan | ĐẠT | Ly do bi chan: Failed to save "Biên bản nghiệm thu giai đoạn E2EAR2610161554 dated 10/16/2026 3:54:26 PM"! / Không thể hủy ghi sổ: còn 2 chứng từ khác đã ghi sổ đang tham chiếu tới chứng từ này (Hóa đơn GTGT đầu ra E2EHD |
| DOISOAT | ketoan_truong | DOISOAT: So cai khop so chi tiet AR/AP/Ngan hang sau kiem thu | ĐẠT | Delta AR=0 AP=0 Bank=0 |

### 5.2. Sửa bộ test cũ (không phải sửa nghiệp vụ)

- `ThucThiKiemThuBaoMatToanDien` và `ThucThiKiemThuTask2Runtime` (CM `PhanQuyenBaoMatServer`): trước đây "đóng giả" người khác bằng tham số tên. Từ khi sửa B28/B32/B34 hệ thống luôn dùng người đăng nhập thật, nên các ca này báo sai. Đã viết lại: mỗi ca kiểm tra quy tắc của **chính người đang đăng nhập**; ca không áp dụng cho vai trò đó ghi BỎ QUA. Chạy bằng cả 9 tài khoản.
- Task 2 ca 4–6: thủ tục con chỉ báo lỗi khi KHÔNG chặn được vi phạm, nhưng ca test lại coi "có lỗi" là đạt → kết quả bị đảo ngược. Đã sửa.
- Thêm lệnh `RunE2E;<run_id>;<file>;<bước>` (CM `HardeningTestsServer`, chỉ chạy trên bản sao `scratch/uat`): quy trình hóa đơn đầu vào 4+1 cấp, biên bản → hóa đơn GTGT → phiếu thu, kiểm bút toán và số dư; ca "phải bị chặn" chỉ đạt khi bị chặn **đúng lý do**.
- Lệnh cũ `RunTask3USDTests`, `RunTask4FXTests`, `RunTask5NettingTests` gọi hàm không tồn tại trong `QuanLyTyGiaVaNgoaiTeServer` (lỗi có từ trước) → không chạy; ghi nhận.

## 6. Kết quả kiểm tra cấu hình

`/CheckConfig` (Thin client, Server, External connection, tham chiếu, handler): **0 lỗi biên dịch**. Còn 2 cảnh báo có từ trước: hàm `TaoKhoaSoDu` không ai gọi; handler `UndoPosting` rỗng ở Biên bản nghiệm thu (cố ý).

## 7. Lưu ý khi Thuận test

- Bản **1C Training**: đăng nhập để **trống mật khẩu** (bản Training báo chỉ cho mật khẩu trống); chỉ **1 kết nối** mỗi infobase — đóng hết cửa sổ 1C (kể cả Designer) trước khi mở bằng tài khoản khác.
- File `.dt` dump bằng 1C 8.3.27, chế độ tương thích cấu hình 8.3.22. Nếu 1C 8.3.22 không nạp được: dựng lại bằng `scripts/rebuild_dt_from_src.ps1` (**Cần xác nhận** trên máy Windows).
- Lỗi đã biết (chưa sửa, Đợt 3–6) liệt kê ở sheet `8_Loi_da_biet` của file Excel.

## 8. File thay đổi

```
src/Languages/TiengViet.xml (mới), src/Configuration.xml, src/ConfigDumpInfo.xml, ~66 file XML (bản dịch vi)
src/Documents/BangKeDoiSoatKenhThanhToan/Ext/ObjectModule.bsl, src/InformationRegisters/HanMucVaChanXuatDichVu/Ext/RecordSetModule.bsl
src/CommonModules/PhanQuyenBaoMatServer/Ext/Module.bsl (bộ test theo phiên thật)
src/CommonModules/HardeningTestsServer/Ext/Module.bsl (RunE2E), src/Ext/ManagedApplicationModule.bsl (lệnh RunE2E)
scripts/localize_vi.py, scripts/build_and_test_mac.sh (mới)
docs/07_LOG_VIET_HOA_VA_TEST.md, docs/08_KICH_BAN_TEST_CHI_TIET.xlsx (mới)
```
