# Task 4.2 Brief: Luồng Phê Duyệt AP 4+1 Cấp & Nhánh Duyệt CFO Khi Vượt Ngân Sách > 10%

## 1. Mục tiêu
Hiện thực luồng chuyển trạng thái và thẩm quyền phê duyệt cho chứng từ `HoaDonNhaCungCap` và `DeNghiThanhToanDichVu` tích hợp với `PheDuyetDaCapServer`:
1. **Luồng chuyển trạng thái 8 bước (`Enum.TrangThaiHoaDonAP`):**
   - `DuThao` $\rightarrow$ `ChoDuyetKyThuat` $\rightarrow$ `ChoDuyetPM` $\rightarrow$ `ChoDuyetITDirector` $\rightarrow$ `ChoDuyetCFO` (nếu vượt ngân sách $>10\%$) $\rightarrow$ `ChoKeToanAP` $\rightarrow$ `DaGhiSo` (hoặc `TuChoi`).
2. **Kiểm tra Maker-Checker & Phân quyền:**
   - Người tạo không được tự duyệt bất kỳ cấp nào.
   - Chỉ người dùng có Role tương ứng mới được nhấn nút duyệt cấp đó.
3. **Cơ chế CFO Special Unlock:**
   - Khi `PheDuyetDaCapServer.KiemTraYeuCauDuyetCFO(...) = True`, luồng duyệt bắt buộc chuyển qua `ChoDuyetCFO`.
   - Nếu không vượt ngân sách: Bỏ qua bước CFO, chuyển thẳng đến `ChoKeToanAP`.

## 2. File tác động
- `tests/unit/WorkflowPheDuyetAPTest.bsl` (New)
- `src/CommonModules/QuyTrinhPheDuyetAPServer.xml` (New)
- `src/CommonModules/QuyTrinhPheDuyetAPServer/Ext/Module.bsl` (New)

## 3. Kịch bản kiểm thử `tests/unit/WorkflowPheDuyetAPTest.bsl` (5 Test Cases)
1. Luồng duyệt chuẩn cho hóa đơn trong hạn mức: Chuyển tuần tự qua các cấp kỹ thuật -> PM -> Kế toán AP -> Ghi sổ.
2. Luồng duyệt vượt ngân sách > 10%: Tự động kích hoạt trạng thái `ChoDuyetCFO`.
3. Kiểm tra Maker-Checker: Người tạo bị chặn khi cố duyệt.
4. Từ chối duyệt (`TuChoi`): Chuyển trạng thái sang `TuChoi`, lưu lý do từ chối.
5. Re-check Anti-Split trước khi chuyển sang `ChoKeToanAP`.

## 4. Báo cáo nghiệm thu
- Ghi báo cáo tại `.superpowers/sdd/2026-10-10-vinsmart-future-ar-ap/task-4.2-report.md`.
