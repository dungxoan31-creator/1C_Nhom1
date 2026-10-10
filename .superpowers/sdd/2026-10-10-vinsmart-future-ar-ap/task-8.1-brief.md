# Task 8.1 Brief: Migration Số Dư Đầu Kỳ AR/AP, Tiền Mặt & Quỹ Ngoại Tệ

## 1. Mục tiêu
Xây dựng công cụ nạp số dư đầu kỳ `DataProcessor.NapSoDuDauKy`:
1. Nạp số dư nợ phải thu đầu kỳ (AR) vào `AccumulationRegister.CongNoPhaiThu` và GL `TK 1311/1312`.
2. Nạp số dư nợ phải trả đầu kỳ (AP) vào `AccumulationRegister.CongNoPhaiTra` và GL `TK 3311/3312`.
3. Nạp số dư quỹ tiền gửi và tiền ngoại tệ vào `AccumulationRegister.DongTien` và GL `TK 1121/1122`.
4. Hạch toán qua tài khoản đối ứng số dư đầu kỳ (TK 000), bảo đảm Invariant $\Delta = |\text{Subledger} - \text{GL}| = 0$.

## 2. File tác động
- `tests/migration/MigrationSoDuDauKyTest.bsl` (New)
- `src/DataProcessors/NapSoDuDauKy.xml` (New)
- `src/DataProcessors/NapSoDuDauKy/Ext/ObjectModule.bsl` (New)
- `src/Configuration.xml` (Register DataProcessor)

## 3. Kịch bản kiểm thử (TDD)
1. Nạp số dư AR đầu kỳ 1.5 tỷ VND: Subledger `CongNoPhaiThu` = 1.5 tỷ, GL `TK 1312` = 1.5 tỷ, đối ứng TK 000.
2. Nạp số dư AP đầu kỳ 800 triệu VND: Subledger `CongNoPhaiTra` = 800tr, GL `TK 3311` = 800tr.
3. Nạp số dư quỹ ngoại tệ: 100.000 USD @ 25.400 = 2.54 tỷ VND trên `DongTien` (cả 2 resource VND và Ngoại tệ) và GL `TK 1122`.
4. Invariant reconciliation: $\Delta = |\text{Subledger} - \text{GL}| = 0$ trên tất cả các sổ.
5. Metadata Schema XML của DataProcessor hợp lệ 100% theo chuẩn 1C version 2.15.
