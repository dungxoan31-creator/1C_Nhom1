# Task 5.2 Brief: Động Cơ Đối Soát Tầng 2 & Tầng 3 (Dung Sai Nội Bộ Tuyệt Đối = 0)

## 1. Mục tiêu
Xây dựng DataProcessor `DongCoDoiSoatTuDong` xử lý đối soát hóa đơn khi không khớp tự động qua Virtual Account ở Tầng 1:
1. **Đối soát Tầng 2 (Fuzzy Matching & Dung sai):**
   - Quét nội dung chuyển khoản tìm Số hóa đơn, Mã hợp đồng, Mã số thuế.
   - **Quy tắc dung sai làm tròn sống còn (Spec v5.0):**
     - Khách hàng ngoài tập đoàn (`LaBenLienKet = False`): Cho phép dung sai làm tròn $\le 1.000$ VND $\rightarrow$ Hạch toán khoản chênh lệch vào `TK 711` (Thu nhập khác) hoặc `TK 635` (Chi phí tài chính).
     - **Đối tác nội bộ Vingroup (`LaBenLienKet = True`): DUNG SAI LÀM TRÒN TUYỆT ĐỐI BẰNG 0**!
       - Bất kỳ khoản chênh lệch nào dù chỉ 1 đồng cũng KHÔNG được tự động xóa nợ, mà bắt buộc đẩy sang Tầng 3 để kế toán đối soát thủ công!
2. **Đối soát Tầng 3 (Manual Review & Treo có đích danh):**
   - Các khoản tiền về không xác định được hóa đơn hoặc lệch tiền nội bộ:
   - Treo nợ có đích danh mã đối tác (`Có TK 1312` chi tiết đối tác, `ChungTuGoc = Undefined`).
   - Cảnh báo kế toán AR và yêu cầu Kế toán trưởng phê duyệt gán nợ thủ công.

## 2. File tác động
- `tests/unit/DongCoDoiSoatTest.bsl` (New)
- `src/DataProcessors/DongCoDoiSoatTuDong.xml` (New)
- `src/DataProcessors/DongCoDoiSoatTuDong/Ext/ObjectModule.bsl` (New)

## 3. Kịch bản kiểm thử `tests/unit/DongCoDoiSoatTest.bsl` (5 Test Cases)
1. Tầng 2 khách ngoài: Khớp số hóa đơn, lệch 500đ (dưới 1.000đ) -> Khớp thành công, chênh lệch vào TK 711.
2. Tầng 2 khách ngoài: Lệch 2.500đ (> 1.000đ) -> Chuyển sang Tầng 3 nghi vấn lệch tiền.
3. Tầng 2 đối tác nội bộ Vingroup: Lệch 500đ -> Chặn áp dụng dung sai, bắt buộc chuyển Tầng 3 (Dung sai = 0).
4. Tầng 2 đối tác nội bộ Vingroup: Khớp chính xác 100% số tiền -> Khớp thành công.
5. Tầng 3: Treo có đích danh đối tác nội bộ chờ kế toán xử lý.

## 4. Báo cáo nghiệm thu
- Ghi báo cáo tại `.superpowers/sdd/2026-10-10-vinsmart-future-ar-ap/task-5.2-report.md`.
