# Task 4.1 Brief: Chứng Từ `HoaDonNhaCungCap` - FCT Khấu Trừ Tại Nguồn Chuẩn Xác (P0.4 Invariant)

## 1. Mục tiêu
Xây dựng chứng từ `HoaDonNhaCungCap` (Document) đại diện cho hóa đơn mua dịch vụ Cloud (AWS, Microsoft Azure, Google Cloud) hoặc phần cứng/dịch vụ CNTT.
1. **Quy tắc hạch toán thuế Nhà thầu FCT (Withholding Tax - Giả định 4):**
   - Hợp đồng thỏa thuận giá thanh toán Gross = 250.000.000 VND (10.000 USD) đã bao gồm thuế FCT:
   - Thuế FCT gồm: VAT nhà thầu 5% = 12.500.000 VND; Thuế TNDN nhà thầu (CIT) 5% = 12.500.000 VND.
   - VSF khấu trừ 25.000.000 VND nộp thay cho NCC nước ngoài.
   - Số tiền thực trả NCC: $250.000.000 - 25.000.000 = 225.000.000$ VND.
2. **Bút toán ghi sổ Sổ cái `SoCaiKeToan`:**
   - `Nợ TK 627` (Chi phí hạ tầng Cloud): 237.500.000 VND (gồm tiền dịch vụ thuần 225tr + thuế TNDN nhà thầu 12.5tr)
   - `Nợ TK 1331` (Thuế VAT đầu vào khấu trừ): 12.500.000 VND (VAT nhà thầu được khấu trừ)
   - `Có TK 3311` (Phải trả NCC nước ngoài): 225.000.000 VND (Số nợ thực trả NCC)
   - `Có TK 33318` (Thuế GTGT nhà thầu khấu trừ nộp thay): 12.500.000 VND
   - `Có TK 3338` (Thuế TNDN nhà thầu khấu trừ nộp thay): 12.500.000 VND
   - **Cân đối Nợ - Có:** $\sum \text{Dr} = 237.5tr + 12.5tr = 250tr$; $\sum \text{Cr} = 225tr + 12.5tr + 12.5tr = 250tr$.
3. **Ghi sổ Sổ tích lũy `CongNoPhaiTra` (AP Subledger):**
   - Ghi tăng nợ phải trả (Receipt): `SoTien = 225.000.000` VND (và `SoTienNgoaiTe = 9.000` USD).
   - Bảo toàn: Subledger AP khớp 100% với Sổ cái TK 3311 (225tr).

## 2. File tác động
- `tests/unit/HoaDonNhaCungCapTest.bsl` (New)
- `src/Documents/HoaDonNhaCungCap.xml` (New)
- `src/Documents/HoaDonNhaCungCap/Ext/ObjectModule.bsl` (New)

## 3. Kịch bản kiểm thử `tests/unit/HoaDonNhaCungCapTest.bsl` (5 Test Cases)
1. Hóa đơn AWS USD với cờ khấu trừ FCT: Khớp đúng Chi phí VSF 237.5tr, VAT đầu vào 12.5tr, Nợ NCC 225tr, Thuế nộp thay 25tr.
2. Hóa đơn nhà cung cấp trong nước không có FCT: Hạch toán bình thường Nợ 627, Nợ 1331 / Có 3311.
3. Hóa đơn đối tác nội bộ Vingroup: Hạch toán Nợ 627 / Có 3312.
4. Tỷ giá hạch toán tự động tra cứu từ `TyGiaHoiDoai` tại ngày hóa đơn.
5. Invariant: $\Delta = |Subledger - GL (TK 3311)| = 0$.

## 4. Báo cáo nghiệm thu
- Ghi báo cáo tại `.superpowers/sdd/2026-10-10-vinsmart-future-ar-ap/task-4.1-report.md`.
