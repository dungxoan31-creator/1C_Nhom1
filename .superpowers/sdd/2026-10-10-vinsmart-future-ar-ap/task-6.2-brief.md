# Task 6.2 Brief: Báo Cáo Tuổi Nợ Phân Tách Nội Bộ & Operational Safety Gate

## 1. Mục tiêu
Triển khai Báo cáo tuổi nợ `Report.BaoCaoTuoiNoPhanTachNoiBo` với cơ chế bảo vệ vận hành (Operational Safety Gate):
1. **Phân tích tuổi nợ (Aging Analysis):**
   - Tính toán số ngày quá hạn từ `DueDate` (Hạn thanh toán) của hợp đồng/hóa đơn.
   - Phân loại 4 nhóm tuổi nợ: `TrongHan` (0 ngày), `QuaHan1_30` (1-30 ngày), `QuaHan31_60` (31-60 ngày), `QuaHanTren60` (>60 ngày).
2. **Operational Safety Gate (Bảo vệ đối tác nội bộ Vingroup):**
   - Đối với khách hàng ngoài: Nếu quá hạn > 60 ngày, đề xuất khóa dịch vụ (`DeXuatKhoaDichVu = True`).
   - Đối với đơn vị thành viên Vingroup (`LaBenLienKet = True`):
     - **CẤM TUYỆT ĐỐI** tự động khóa dịch vụ hoặc ngắt API (`CamKhoaDichVu = True`, `DeXuatKhoaDichVu = False`).
     - Tự động chuyển sang luồng `CanhBaoCFOVaNetting` để đưa vào ma trận bù trừ nợ nội bộ.

## 2. File tác động
- `tests/unit/BaoCaoTuoiNoVaSafetyGateTest.bsl` (New)
- `src/Reports/BaoCaoTuoiNoPhanTachNoiBo.xml` (New)
- `src/Reports/BaoCaoTuoiNoPhanTachNoiBo/Ext/ObjectModule.bsl` (New)
- `src/Configuration.xml` (Register Report)

## 3. Kịch bản kiểm thử (TDD)
1. Khách hàng ngoài quá hạn 45 ngày: Xếp vào nhóm 31-60 ngày, trạng thái cảnh báo nhắc nợ.
2. Khách hàng ngoài quá hạn 75 ngày (> 60 ngày): Xếp vào nhóm > 60 ngày, `DeXuatKhoaDichVu = True`.
3. Đơn vị nội bộ Vingroup (VinFast) quá hạn 90 ngày: Xếp vào nhóm > 60 ngày, NHƯNG Operational Safety Gate chặn khóa dịch vụ (`CamKhoaDichVu = True`, `DeXuatKhoaDichVu = False`), kích hoạt `CanhBaoCFOVaNetting`.
4. Tính toán tổng dư nợ theo từng nhóm tuổi nợ chính xác 100%.
5. Metadata Schema XML của Report đúng chuẩn 1C version 2.15.
