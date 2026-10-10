# Task 3.3 Brief: Xử Lý Tranh Chấp Sau Ghi Sổ - `DieuChinhCongNo` Ghi Sổ Duy Nhất (P0.3 Invariant)

## 1. Mục tiêu
Xây dựng quy trình xử lý tranh chấp và điều chỉnh giảm giá trị sau khi đã xuất hóa đơn và ghi sổ AR:
1. **Nguyên tắc kỹ thuật sống còn (P0.3):**
   - Khi có biên bản thỏa thuận tranh chấp/sai sót giảm trừ (ví dụ giảm phạt SLA 20.000.000 VND đã bao gồm VAT):
   - Hóa đơn điều chỉnh `HoaDonGTGTDauRa` (ở trạng thái `DaDieuChinh`) là CHỨNG TỪ PHÁP LÝ ĐIỆN TỬ, **KHÔNG SINH BÚT TOÁN KẾ TOÁN (Non-posting)**!
   - Chứng từ `DieuChinhCongNo` là **CHỨNG TỪ DUY NHẤT** sinh bút toán ghi sổ!
2. **Quy tắc tính toán số tiền giảm (Đã gồm VAT):**
   - Tổng giảm gộp: 20.000.000 VND.
   - Doanh thu thuần giảm: $20.000.000 / 1.1 = 18.181.818$ VND.
   - Thuế VAT giảm: $20.000.000 - 18.181.818 = 1.818.182$ VND.
3. **Bút toán hạch toán duy nhất trên `DieuChinhCongNo`:**
   - Sổ cái `SoCaiKeToan`:
     - `Nợ TK 5113`: 18.181.818 VND
     - `Nợ TK 33311`: 1.818.182 VND
     - `Có TK 1312`: 20.000.000 VND
   - Sổ tích lũy `CongNoPhaiThu` (Expense / Giảm số dư):
     - `SoTien`: 20.000.000 VND
4. **Bảo toàn Invariant & Tránh lỗi Double-Crediting:**
   - Tổng phát sinh Có TK 1312 đúng bằng 20.000.000 VND.
   - Tuyệt đối không bị ghi trùng thành 21.818.182 VND (lỗi khi cả Hóa đơn và Điều chỉnh cùng ghi Có 1312).
   - Số dư công nợ sau điều chỉnh: $220.000.000 - 20.000.000 = 200.000.000$ VND.

## 2. File tác động
- `tests/unit/TranhChapSauGhiSoTest.bsl` (New)
- `src/Documents/DieuChinhCongNo.xml` (New)
- `src/Documents/DieuChinhCongNo/Ext/ObjectModule.bsl` (New)

## 3. Kịch bản kiểm thử `tests/unit/TranhChapSauGhiSoTest.bsl`
1. Khởi tạo nghiệm thu 200tr + VAT 20tr = 220tr nợ ban đầu.
2. Phát sinh tranh chấp SLA giảm 20.000.000 VND (đã gồm VAT).
3. Hóa đơn điều chỉnh xuất ra ở trạng thái `DaDieuChinh` -> Xác nhận không ghi sổ GL.
4. Ghi sổ `DieuChinhCongNo`.
5. Assert:
   - GL: Nợ 5113: 18.181.818, Nợ 33311: 1.818.182, Có 1312: 20.000.000.
   - Tổng Có TK 1312 phát sinh của đợt điều chỉnh đúng 20.000.000đ.
   - Dư nợ Subledger `CongNoPhaiThu` còn lại đúng 200.000.000 VND.
   - Dư nợ Sổ cái TK 1312 còn lại đúng 200.000.000 VND.
   - $\Delta \text{Variance} = 0$.

## 4. Báo cáo nghiệm thu
- Ghi báo cáo tại `.superpowers/sdd/2026-10-10-vinsmart-future-ar-ap/task-3.3-report.md`.
