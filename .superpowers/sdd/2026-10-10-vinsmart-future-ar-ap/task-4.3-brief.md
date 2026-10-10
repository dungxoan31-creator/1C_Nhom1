# Task 4.3 Brief: Chứng Từ `UyNhiemChi` - Ghi Sổ Khi Ngân Hàng Xác Nhận & Xử Lý Reversal Thực Tế (P0.2 Invariant)

## 1. Mục tiêu
Xây dựng chứng từ `UyNhiemChi` (Payment Order) phục vụ chi tiền thanh toán công nợ nhà cung cấp qua ngân hàng (Techcombank / VietinBank):
1. **Quy tắc State Machine & Ghi Sổ Sống Còn (P0.2 Invariant):**
   - Các trạng thái (`Enum.TrangThaiLenhThanhToan`): `DuThao`, `ChoDuyet`, `DaDuyet`, `DaGuiNganHang`, `DaGhiSo`, `TuChoi`, `HuyBo`.
   - **KHI Ở TRẠNG THÁI `DaGuiNganHang`:**
     - **CHƯA GHI SỔ GL (`SoCaiKeToan`)** và **CHƯA GIẢM NỢ TRÊN `CongNoPhaiTra`**!
     - Tiền chưa thực sự rời khỏi ngân hàng.
   - **KHI NGÂN HÀNG XÁC NHẬN THÀNH CÔNG:**
     - Chuyển sang `DaGhiSo`.
     - Lúc này MỚI ghi sổ:
       - Sổ cái `SoCaiKeToan`: `Nợ TK 3311 (hoặc 3312) / Có TK 1121 (hoặc 1122)`
       - Sổ tích lũy `CongNoPhaiTra` (Expense / Giảm nợ): Giảm đúng số tiền đã chi
       - Sổ tích lũy `DongTien` (Expense / Giảm tiền): Giảm số dư tài khoản ngân hàng
       - Phí ngân hàng (nếu có): `Nợ TK 6427 / Có TK 1121`
   - **KHI NGÂN HÀNG TỪ CHỐI LỆNH (Rejection):**
     - Chuyển sang `TuChoi` hoặc `HuyBo`.
     - **KHÔNG SINH BÚT TOÁN ĐẢO (Zero Phantom Reversals)** vì lệnh chưa từng được ghi sổ!
   - **KHI PHÁT SINH TRA SOÁT HOÀN TRẢ (Reversal sau ghi sổ):**
     - Chỉ áp dụng khi lệnh đã ở `DaGhiSo` nhưng ngân hàng phát sinh điện tra soát hoàn tiền sau đó.
     - Lập bút toán đảo (Reversal Entry): `Nợ TK 1121 / Có TK 3311` và tăng lại nợ `CongNoPhaiTra`.
2. **Maker-Checker Lệnh Chi:**
   - CẤM tuyệt đối người lập lệnh chi ký duyệt hoặc chuyển trạng thái `DaDuyet`.

## 2. File tác động
- `tests/unit/UyNhiemChiStateReversalTest.bsl` (New)
- `src/Documents/UyNhiemChi.xml` (New)
- `src/Documents/UyNhiemChi/Ext/ObjectModule.bsl` (New)

## 3. Kịch bản kiểm thử `tests/unit/UyNhiemChiStateReversalTest.bsl` (5 Test Cases)
1. Lệnh chi ở trạng thái `DaGuiNganHang`: Không có bút toán trong `SoCaiKeToan`, công nợ `CongNoPhaiTra` chưa bị giảm.
2. Ngân hàng từ chối (`TuChoi`): Không sinh bất kỳ bút toán đảo nào, GL sạch 100%.
3. Ngân hàng xác nhận thành công (`DaGhiSo`): Ghi giảm nợ AP, giảm tiền ngân hàng, ghi nhận chi phí phí ngân hàng TK 6427.
4. Maker-Checker: Chặn người lập lệnh chi duyệt lệnh.
5. Tra soát hoàn trả sau ghi sổ: Sinh bút toán đảo hoàn nguyên chính xác số dư công nợ và số dư tiền.

## 4. Báo cáo nghiệm thu
- Ghi báo cáo tại `.superpowers/sdd/2026-10-10-vinsmart-future-ar-ap/task-4.3-report.md`.
