# Task 6.1 Brief: Động Cơ Lập Ma Trận Cấn Trừ Tập Đoàn & Watchdog Timeout (P3.2)

## 1. Mục tiêu
Triển khai động cơ bù trừ công nợ nội bộ đa bên (Multilateral Intercompany Netting) và chứng từ cấn trừ công nợ:
1. `DataProcessor.LapMaTranCanTruTapDoan`:
   - Quét nợ phải thu (AR) và nợ phải trả (AP) giữa các pháp nhân thành viên trong Tập đoàn Vingroup.
   - Tính toán ma trận cấn trừ tối ưu (Pairwise hoặc Multilateral thông qua tài khoản trung gian 1388).
   - Đánh dấu các hóa đơn/nghiệm thu tham gia cấn trừ sang trạng thái `ChoCanTru` và lưu `TrangThaiTruocDo`.
   - Cơ chế Watchdog Timeout: Tuyệt đối KHÔNG giữ database lock trong 120 phút. Nếu quá `TimeoutChoCanTruPhut` (120 phút) mà các bên chưa phê duyệt xong, Watchdog tự động rollback trạng thái chứng từ về `TrangThaiTruocDo`.
2. `Document.CanTruCongNoNoiBo`:
   - Khi được phê duyệt và ghi sổ:
     - Ghi giảm nợ phải thu trên `AccumulationRegister.CongNoPhaiThu` (Expense).
     - Ghi giảm nợ phải trả trên `AccumulationRegister.CongNoPhaiTra` (Expense).
     - Ghi sổ cái `AccountingRegister.SoCaiKeToan`:
       - Cấn trừ trực tiếp: Nợ TK 3312 / Có TK 1312: Số tiền cấn trừ.
       - Cấn trừ bắc cầu: Nợ TK 3312 / Có TK 1388 và Nợ TK 1388 / Có TK 1312.
     - Đảm bảo Reconciliation Invariant: $\Delta = |\text{Subledger} - \text{GL}| = 0$.

## 2. File tác động
- `tests/unit/MaTranCanTruNettingTest.bsl` (New)
- `src/DataProcessors/LapMaTranCanTruTapDoan.xml` (New)
- `src/DataProcessors/LapMaTranCanTruTapDoan/Ext/ObjectModule.bsl` (New)
- `src/Documents/CanTruCongNoNoiBo.xml` (New)
- `src/Documents/CanTruCongNoNoiBo/Ext/ObjectModule.bsl` (New)
- `src/Configuration.xml` (Register DataProcessor and Document)

## 3. Kịch bản kiểm thử (TDD)
1. Cấn trừ nợ nội bộ tay đôi (Bilateral Netting): VSF phải thu VinFast 500tr, VSF phải trả VinFast 300tr -> Cấn trừ 300tr, số dư còn lại AR = 200tr, AP = 0, GL cân đối tuyệt đối.
2. Cấn trừ đa bên bắc cầu (Multilateral Netting qua TK 1388): Cân đối tổng Nợ - Có trung gian $\Delta = 0$.
3. Watchdog 120 phút: Phiên cấn trừ quá hạn 120 phút tự động hoàn nguyên về `TrangThaiTruocDo`, giải phóng khóa mà không có lock DB tồn đọng.
4. Maker-Checker trên `CanTruCongNoNoiBo`: Người tạo phiên cấn trừ không được phép tự duyệt.
5. Metadata Schema XML 2.15 chuẩn 1C.
