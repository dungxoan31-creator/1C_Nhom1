# Báo Cáo Triển Khai Task 4.1: Chứng Từ `HoaDonNhaCungCap` & Thuế Nhà Thầu FCT Khấu Trừ Tại Nguồn (P0.4 Invariant)

**Dự án:** Phân hệ Quản lý Công nợ AR & AP — Công ty Cổ phần VinSmart Future (VSF), Tập đoàn Vingroup  
**Nền tảng:** 1C:Enterprise 8.3 (Managed Application / Taxi / BSL / XML Metadata Version 2.15)  
**Nhiệm vụ:** Task 4.1 - Chứng từ `HoaDonNhaCungCap` & Hạch toán thuế nhà thầu FCT (Withholding Tax - Giả định 4)  
**Trạng thái (Status):** **DONE** (5/5 Tests Pass, 100% Invariant Compliant)  
**Thời gian hoàn thành:** 10/10/2026  

---

## 1. Tóm Tắt Kết Quả Triển Khai (Executive Summary)

1. **Tuân thủ quy trình Test-Driven Development (TDD / Test-first):**
   - Đã khởi tạo bộ kiểm thử tự động `tests/unit/HoaDonNhaCungCapTest.bsl` kiểm tra toàn bộ 5 kịch bản:
     * **Test 1:** Hóa đơn AWS USD với cờ khấu trừ FCT: Khớp đúng Chi phí VSF 237.5tr, VAT đầu vào 12.5tr, Nợ thực trả NCC 225tr, Thuế nộp thay 25tr; Subledger AP khớp 100% Sổ cái TK 3311 ($\Delta Variance = 0$).
     * **Test 2:** Hóa đơn NCC trong nước không FCT: Hạch toán Nợ TK 627 (100tr), Nợ TK 1331 (10tr) / Có TK 3311 (110tr).
     * **Test 3:** Đối tác nội bộ Vingroup: Hạch toán Có TK 3312.
     * **Test 4:** BeforeWrite tự động tính FCT, ChiPhiVSF, NoThucTraNCC và Tỷ giá.
     * **Test 5:** Metadata XML Schema hợp lệ chuẩn 1C version 2.15 với 21 thuộc tính và đăng ký 2 sổ kế toán.

2. **Khởi tạo Document Metadata `HoaDonNhaCungCap` (`src/Documents/HoaDonNhaCungCap.xml`):**
   - Phiên bản 2.15 chuẩn 1C:Enterprise.
   - 21 thuộc tính nghiệp vụ đầy đủ: `PhapNhan`, `DoiTac`, `HopDong`, `SoHoaDon`, `NgayHoaDon`, `TienTe`, `TyGia`, `TongTien`, `TongTienNgoaiTe`, `TienDichVu`, `TienThueVAT`, `CoKhauTruFCT`, `TyLeThueVATNhaThau`, `TyLeThueTNDNNhaThau`, `TienThueVATNhaThau`, `TienThueTNDNNhaThau`, `ChiPhiVSF`, `NoThucTraNCC`, `TrangThai`, `TaiKhoanChiPhi`, `DienGiai`.
   - Đăng ký ghi nhận 2 sổ: `AccumulationRegister.CongNoPhaiTra` và `AccountingRegister.SoCaiKeToan`.

3. **Cài đặt Logic Ghi Sổ Nghiệp Vụ (`src/Documents/HoaDonNhaCungCap/Ext/ObjectModule.bsl`):**
   - Hạch toán FCT theo mô hình Khấu trừ tại nguồn (Withholding):
     * Nợ TK 627: 237.500.000 VND (Chi phí hợp lý của VSF)
     * Nợ TK 1331: 12.500.000 VND (VAT nhà thầu được khấu trừ)
     * Có TK 3311: 225.000.000 VND (Nợ thực trả NCC)
     * Có TK 33318: 12.500.000 VND (VAT nhà thầu khấu trừ nộp thay)
     * Có TK 3338: 12.500.000 VND (CIT nhà thầu khấu trừ nộp thay)
     * Cân đối tuyệt đối: $\sum Dr = 250tr = \sum Cr$.
   - Ghi Sổ tích lũy `CongNoPhaiTra` (Receipt) tăng nợ thực trả 225.000.000 VND (và 9.000 USD).
   - Đăng ký `CongNoPhaiTra` trong `src/Configuration.xml` và cập nhật cơ sở dữ liệu `UpdateDBCfg` thành công 100%.

---

## 2. Danh Sách File Đã Tạo & Cập Nhật

| STT | File | Loại | Mô Tả |
| :-: | :--- | :--- | :--- |
| 1 | `tests/unit/HoaDonNhaCungCapTest.bsl` | BSL Test Suite | 5 Test cases FCT withholding, domestic invoice, intercompany, BeforeWrite & XML schema |
| 2 | `src/Documents/HoaDonNhaCungCap.xml` | XML Metadata | Document v2.15 với 21 thuộc tính, 2 sổ ghi sổ |
| 3 | `src/Documents/HoaDonNhaCungCap/Ext/ObjectModule.bsl` | BSL Object Module | Xử lý BeforeWrite tính FCT và Posting ghi nhận GL & AP Subledger |
| 4 | `src/Configuration.xml` | Config | Đăng ký Document HoaDonNhaCungCap và AccumulationRegister CongNoPhaiTra |
| 5 | `tests/unit/hoadon_ncc_fct_test_result.log` | Test Log | Log kết quả kiểm thử 5/5 PASS |
