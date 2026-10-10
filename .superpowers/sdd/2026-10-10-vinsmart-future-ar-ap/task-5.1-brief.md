# Task 5.1 Brief: Webhook Ngân Hàng, Idempotency Nguyên Tử & Báo Có Tự Động (P3.1)

## 1. Mục tiêu
Xây dựng HTTP Service webhook ngân hàng tiếp nhận biến động số dư và chứng từ `BaoCoNganHang`:
1. **Xử lý Webhook trong Atomic Transaction (Giao dịch nguyên tử):**
   - Tiếp nhận payload webhook từ Core Banking Techcombank/VietinBank.
   - Kiểm tra trùng lặp trên `InformationRegister.LichSuGiaoDichNganHang`:
     - Trùng `IdempotencyKey` + trùng `PayloadHash`: Trả về `HTTP 200 OK` (Already Processed / Bỏ qua xử lý lặp).
     - Trùng `IdempotencyKey` + khác `PayloadHash`: Trả về `HTTP 409 Conflict` (Dữ liệu bị sửa đổi / Bất thường).
     - Chưa từng xuất hiện: Ghi nhận vào sổ `LichSuGiaoDichNganHang` và sinh chứng từ `BaoCoNganHang`.
2. **Chứng từ `Document.BaoCoNganHang`:**
   - Trạng thái: `ChoDoiSoat`, `DaDoiSoat`, `NghiVanLecDoiSoat`.
   - Thuộc tính: `PhapNhan`, `TaiKhoanTien`, `SoTien`, `NgayGiaoDich`, `MaGiaoDichNganHang`, `NoiDungChuyenKhoan`, `VirtualAccount`, `DoiTacKhop`, `ChungTuKhop`.
   - Tự động nhận diện Tầng 1 (Virtual Account chính xác):
     - Tự động ghi sổ (`TuDongGhiSo = True`) không cần maker-checker thủ công:
       $$\text{Nợ TK 1121 / Có TK 1312 (hoặc 1311)}, \quad \text{CongNoPhaiThu (Expense): SoTien}, \quad \text{DongTien (Receipt): SoTien}$$

## 2. File tác động
- `tests/unit/WebhookIdempotencyTest.bsl` (New)
- `src/HTTPServices/WebhookNganHang.xml` (New)
- `src/HTTPServices/WebhookNganHang/Ext/Module.bsl` (New)
- `src/Documents/BaoCoNganHang.xml` (New)
- `src/Documents/BaoCoNganHang/Ext/ObjectModule.bsl` (New)

## 3. Kịch bản kiểm thử `tests/unit/WebhookIdempotencyTest.bsl` (5 Test Cases)
1. Webhook lần 1: Ghi nhận thành công, sinh `BaoCoNganHang` và bản ghi Idempotency.
2. Webhook lặp (Trùng key + Trùng hash): Trả về mã 200 "Already Processed", không sinh chứng từ trùng lặp.
3. Webhook xung đột (Trùng key + Khác hash): Trả về mã 409 "Conflict detected".
4. Khớp Tầng 1 qua Virtual Account: Tự động ghi giảm nợ AR và tăng dòng tiền.
5. Giao dịch không có VA: Chuyển sang trạng thái `ChoDoiSoat` để chuyển Tầng 2.

## 4. Báo cáo nghiệm thu
- Ghi báo cáo tại `.superpowers/sdd/2026-10-10-vinsmart-future-ar-ap/task-5.1-report.md`.
