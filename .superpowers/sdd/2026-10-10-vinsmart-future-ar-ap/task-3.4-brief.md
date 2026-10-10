# Task 3.4 Brief: Chứng Từ `PhieuThuTienKhachHang` & Phân Bổ Thanh Toán AR

## 1. Mục tiêu
Xây dựng chứng từ `PhieuThuTienKhachHang` (Document) đại diện cho việc thu tiền bán hàng/dịch vụ từ khách hàng hoặc đơn vị nội bộ Vingroup.
1. **Quy tắc hạch toán:**
   - Khi nhận tiền:
     - Ghi Sổ Cái `SoCaiKeToan`: `Nợ TK 1121 (hoặc 1122) / Có TK 1312 (hoặc 1311)`: theo số tiền thanh toán.
     - Ghi Sổ Tích Lũy `CongNoPhaiThu` (Expense / Giảm số dư): giảm công nợ khách hàng theo hợp đồng & chứng từ gốc.
     - Ghi Sổ Tích Lũy `DongTien` (Receipt / Tăng số dư dòng tiền): tăng số dư tài khoản ngân hàng.
2. **Metadata thuộc tính:**
   - `PhapNhan` (`CatalogRef.PhapNhan`, DenyIncompleteValues: True)
   - `DoiTac` (`CatalogRef.DoiTac`, DenyIncompleteValues: True)
   - `HopDong` (`CatalogRef.HopDong`, DenyIncompleteValues: True)
   - `ChungTuGoc` (`DocumentRef.BienBanNghiemThuGiaiDoan`)
   - `TaiKhoanTien` (`CatalogRef.TaiKhoanTien`, DenyIncompleteValues: True)
   - `KhoanMucDongTien` (`CatalogRef.KhoanMucDongTien`)
   - `TienTe` (`CatalogRef.TienTe`, DenyIncompleteValues: True)
   - `SoTien` (`Number 15,2`, Nonnegative)
   - `SoTienNgoaiTe` (`Number 15,2`, Nonnegative)
   - `TyGia` (`Number 10,4`, Nonnegative)
   - `NgayThu` (`Date`)
   - `DienGiai` (`String 200`)

## 2. File tác động
- `tests/unit/PhieuThuTienTest.bsl` (New)
- `src/Documents/PhieuThuTienKhachHang.xml` (New)
- `src/Documents/PhieuThuTienKhachHang/Ext/ObjectModule.bsl` (New)

## 3. Kịch bản kiểm thử `tests/unit/PhieuThuTienTest.bsl`
1. Khách hàng thanh toán 200.000.000 VND cho chứng từ nghiệm thu còn nợ 200.000.000 VND.
2. Ghi sổ `PhieuThuTienKhachHang`.
3. Assert:
   - Sổ `CongNoPhaiThu` giảm 200.000.000 VND -> Số dư nợ của chứng từ gốc về 0 (Tất toán).
   - Sổ `DongTien` tăng 200.000.000 VND.
   - Sổ cái `SoCaiKeToan`: Nợ TK 1121 = 200.000.000 VND, Có TK 1312 = 200.000.000 VND.
   - Variance $\Delta = 0$.

## 4. Báo cáo nghiệm thu
- Ghi báo cáo tại `.superpowers/sdd/2026-10-10-vinsmart-future-ar-ap/task-3.4-report.md`.
