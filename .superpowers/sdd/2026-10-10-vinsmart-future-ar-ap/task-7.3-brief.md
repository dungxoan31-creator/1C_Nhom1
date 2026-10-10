# Task 7.3 Brief: Động Cơ Đồng Bộ Bút Toán SAP ERP & Outbox Audit Trail

## 1. Mục tiêu
Triển khai động cơ đồng bộ sổ cái kế toán từ 1C sang hệ thống lõi SAP ERP của Tập đoàn Vingroup:
1. **`DataProcessor.DongBoButToanSAP`:**
   - Đọc các bút toán phát sinh trong kỳ từ `AccountingRegister.SoCaiKeToan`.
   - Ánh xạ mã tài khoản và pháp nhân sang mã SAP chuẩn (`CompanyCode`, `GLAccount`, `CostCenter`).
   - Kiến trúc Outbox Pattern: Đảm bảo độ tin cậy và không mất mát dữ liệu giao dịch.
   - Cơ chế Retry 3 lần với Exponential Backoff (1m, 5m, 15m) khi mạng chập chờn.
   - Ghi nhận Audit Trail: Lưu `SAP_DOC_NUMBER` và thời gian đồng bộ thành công.
2. **`ScheduledJob.DongBoSAPHangNgay`:**
   - Chạy định kỳ lúc 22:00 hàng đêm để tự động quét và gửi lô dữ liệu (Batch) sang SAP ERP.

## 2. File tác động
- `tests/integration/DongBoSAPIntegrationTest.bsl` (New)
- `src/DataProcessors/DongBoButToanSAP.xml` (New)
- `src/DataProcessors/DongBoButToanSAP/Ext/ObjectModule.bsl` (New)
- `src/ScheduledJobs/DongBoSAPHangNgay.xml` (New)
- `src/Configuration.xml` (Register DataProcessor and ScheduledJob)

## 3. Kịch bản kiểm thử (TDD)
1. Đóng gói bút toán GL sang SAP IDoc/OData payload: Đủ các trường `CompanyCode`, `PostingDate`, `GLAccount`, `Amount`, `DrCr`.
2. Đồng bộ thành công: SAP trả về HTTP 200 và `SAP_DOC_NUMBER` -> Cập nhật trạng thái `ThanhCong`.
3. Cơ chế Retry 3 lần: Giả lập lỗi mạng tạm thời ở lần 1 và lần 2, thành công ở lần 3.
4. Quá 3 lần retry thất bại: Chuyển sang trạng thái `LoiDongBo`, gửi cảnh báo cho IT/Kế toán trưởng.
5. Metadata Schema XML của ScheduledJob và DataProcessor hợp lệ 100% theo chuẩn 1C version 2.15.
