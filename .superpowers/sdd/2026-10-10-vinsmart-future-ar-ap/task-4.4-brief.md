# Task 4.4 Brief: Chứng Từ `DeNghiThanhToanDichVu` & `NghiemThuThauPhu`

## 1. Mục tiêu
Xây dựng 2 chứng từ phục vụ quản lý thầu phụ gia công phần cứng và đề nghị thanh toán nội bộ:
1. `Document.NghiemThuThauPhu`:
   - Nghiệm thu dịch vụ gia công phần cứng / dịch vụ outsource từ thầu phụ CNTT.
   - Hạch toán: `Nợ TK 627 / Có TK 3311` (hoặc 3312) và ghi tăng Sổ `CongNoPhaiTra`.
2. `Document.DeNghiThanhToanDichVu`:
   - Chứng từ nội bộ yêu cầu thanh toán chi phí/công nợ trước khi lập `UyNhiemChi`.
   - Kết nối với `KeHoachChiTien` để kiểm tra ngân sách chi tiêu.

## 2. File tác động
- `tests/unit/DeNghiThanhToanTest.bsl` (New)
- `tests/unit/NghiemThuThauPhuTest.bsl` (New)
- `src/Documents/DeNghiThanhToanDichVu.xml` (New)
- `src/Documents/DeNghiThanhToanDichVu/Ext/ObjectModule.bsl` (New)
- `src/Documents/NghiemThuThauPhu.xml` (New)
- `src/Documents/NghiemThuThauPhu/Ext/ObjectModule.bsl` (New)

## 3. Kịch bản kiểm thử
1. `NghiemThuThauPhu`: Ghi tăng nợ phải trả thầu phụ 50tr, tăng chi phí TK 627.
2. `DeNghiThanhToanDichVu`: Kiểm tra ngân sách trước khi duyệt, chuyển trạng thái cho phép lập `UyNhiemChi`.

## 4. Báo cáo nghiệm thu
- Ghi báo cáo tại `.superpowers/sdd/2026-10-10-vinsmart-future-ar-ap/task-4.4-report.md`.
