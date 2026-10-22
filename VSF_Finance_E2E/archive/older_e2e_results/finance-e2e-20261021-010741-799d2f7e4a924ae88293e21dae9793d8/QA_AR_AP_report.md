# Báo cáo QA tự động AR/AP — 21/10/2026

## Kết quả chạy cuối

- Run: `finance-e2e-20261021-010741-799d2f7e4a924ae88293e21dae9793d8`.
- Trạng thái runner: **PASS**, 78/78 phase PASS, 0 phase FAIL.
- UI: 16/16 màn hình chứng từ/Data Processor mở được; 5/5 danh sách áp dụng đúng bộ lọc ngày/tháng/quý/tất cả; 4/4 luồng ngân hàng và hoàn tiền UI PASS.
- Bài kiểm tra posting: lifecycle 4/4; GL–subledger integrity 3/3; AP invoice lifecycle 3/3; posting invariants 5/5; boundary tests 3/3.
- Security: ma trận 5 vai trò × 10 thao tác PASS; branch RLS PASS. AR DataLock concurrency và chặn thu vượt số dư PASS.
- Seed hồi quy: AR 1.260 biên bản, 1.260 hóa đơn, 1.162 phiếu thu; AP 1.260 hóa đơn, trong đó 315 hóa đơn USD. Tổng bút toán AR khớp sổ cái/công nợ/tiền, không có sai lệch nguồn thuế.
- CSDL chạy thử là bản clone trong `%TEMP%`; không ghi vào `BaseInfobase` gốc.

Artifact JSON đầy đủ: `summary.json` trong cùng thư mục.

## Khảo sát metadata

| Loại | Số lượng | Thành phần |
|---|---:|---|
| Catalogs | 9 | ChiNhanh, DichVuCNTT, DoiTac, DuAn, HopDong, KhoanMucDongTien, PhapNhan, TaiKhoanTien, TienTe |
| Documents | 7 | BienBanNghiemThuGiaiDoan, HoaDonGTGTDauRa, PhieuThuTienKhachHang, HoaDonNhaCungCap, UyNhiemChi, CanTruCongNoNoiBo, DoiSoatKenhThanhToan |
| Accumulation registers | 3 | CongNoPhaiThu, CongNoPhaiTra, DongTien |
| Accounting registers | 1 | SoCaiKeToan |
| Information registers | 2 | PhanQuyenChiNhanh, TyGiaHoiDoai |
| Data processors | 1 | BanLamViecWebERP, có 2 custom forms |
| Common modules | 12 | Bao gồm posting lifecycle, generator AR/AP, RLS, approvals, tax, bank integration và test seed |
| Roles | 5 | Admin, AR, AP, Kế toán trưởng, CFO |
| Reports | 0 | Không có thư mục/object Reports; dashboard nằm trong Data Processor |

Không có metadata riêng cho đơn bán hàng, đơn mua hàng hoặc đề nghị thanh toán. Luồng AR hiện bắt đầu từ biên bản nghiệm thu; luồng AP bắt đầu từ hóa đơn nhà cung cấp. Hai document `CanTruCongNoNoiBo` và `DoiSoatKenhThanhToan` dùng form mặc định của nền tảng, không có custom form XML.

## Ma trận màn hình và giao diện

| Màn hình | Kết quả | Phạm vi xác nhận |
|---|---|---|
| Danh sách Biên bản nghiệm thu | PASS | Mở UI; kiểm tra 4 giá trị kỳ; bản ghi tháng 10 bị loại bởi `HomNay`, được giữ bởi `ThangNay`, `QuyNay`, `TatCa` |
| Chi tiết Biên bản nghiệm thu | PASS | Mở từ danh sách; form có control dữ liệu hiển thị |
| Danh sách Hóa đơn GTGT đầu ra | PASS | Mở UI; 4 giá trị kỳ |
| Chi tiết Hóa đơn GTGT đầu ra | PASS | Mở từ danh sách; UI xác nhận nguồn nghiệm thu, số hóa đơn, net 200.000.000, VAT 16.000.000, gross 216.000.000 VND |
| Danh sách Phiếu thu khách hàng | PASS | Mở UI; 4 giá trị kỳ |
| Chi tiết Phiếu thu khách hàng | PASS | Mở từ danh sách; form có control dữ liệu hiển thị |
| Danh sách Hóa đơn nhà cung cấp | PASS | Mở UI; 4 giá trị kỳ |
| Chi tiết Hóa đơn nhà cung cấp | PASS | Mở từ danh sách; AP E2E kiểm tra gross/FCT/net payable ở backend |
| Danh sách Ủy nhiệm chi | PASS | Mở UI; 4 giá trị kỳ |
| Chi tiết Ủy nhiệm chi | PASS | Mở UI; gửi ngân hàng Accepted/Rejected và xác nhận hoàn tiền |
| Danh sách Cấn trừ công nợ nội bộ | PASS | Mở được sau hotfix Command Interface |
| Chi tiết Cấn trừ công nợ nội bộ | PASS | Mở chứng từ `E2E-NET-001` |
| Danh sách Đối soát kênh thanh toán | PASS | Mở được sau hotfix Command Interface |
| Chi tiết Đối soát kênh thanh toán | PASS | Mở chứng từ `E2E-BK-VNPAY-001` |
| Bàn làm việc Web ERP | PASS | Form dashboard mở; dashboard calculations/aging/period/work queue được assertion ở runtime |
| Duyệt Maker-Checker hàng loạt | PASS | Form mở từ action card dashboard; logic phê duyệt batch được kiểm tra ở backend |

Tổng cộng: 7 list forms + 7 document forms + 2 Data Processor forms = 16/16 mở được. Bộ lọc kỳ được kiểm tra runtime trên 5 list forms tùy biến; hai list mặc định không có bộ lọc kỳ tùy biến.

## Ma trận nút lệnh

| Nút/tác vụ | Kết quả | Ghi chú |
|---|---|---|
| Gửi lệnh chi ngân hàng | PASS | UI xác nhận `ACCEPTED` và `HTTP_REJECTED`; nhánh reject giữ nguyên AP, không sinh transaction ID |
| Xác nhận tiền hoàn ngân hàng | PASS | UI xác nhận `REFUND_RECEIVED` cho hoàn tiền gốc và chứng từ trùng; backend chặn ghi sổ hoàn chưa xác nhận và hoàn trùng |
| Phê duyệt Maker-Checker | PASS có giới hạn | Backend batch pass 3 chứng từ ở Kế toán trưởng và 1 chứng từ ở CFO; form batch mở được, chưa click nút “Phê duyệt toàn bộ” từ UI |
| Ghi/Ghi sổ/Hủy ghi sổ/Ghi lại | PASS ở backend | Posting lifecycle, AP unpost/repost, rollback và GL/subledger assertion đều pass; chưa bấm riêng từng nút chuẩn trên mọi form UI |
| Tạo mới/Sao chép/In/Preview | Chưa đủ bằng chứng | Không có ca UI riêng cho mọi loại chứng từ và mọi lệnh chuẩn |
| Xem chứng từ liên quan/lệnh tùy chỉnh khác | Chưa đủ bằng chứng | Chưa kích hoạt toàn bộ command tùy chỉnh trên tất cả detail forms |

## Ma trận trường và kiểm tra nghiệp vụ

| Nhóm kiểm tra | Kết quả | Bằng chứng |
|---|---|---|
| AR VAT và tổng tiền | PASS | UI kiểm tra net 200.000.000, VAT 16.000.000, gross 216.000.000 VND; seed kiểm tra nhiều mức VAT và nguồn thuế |
| Thu vượt công nợ | PASS | Thu 216.000.001 trên hóa đơn 216.000.000 bị từ chối; không tạo movement AR/GL/tiền |
| AP thuế nhà thầu | PASS | Gross 200.000.000; FCT VAT 10.000.000; FCT CIT 10.000.000; payable 180.000.000 VND |
| Ngưỡng duyệt AP | PASS | Boundary 500 triệu và escalation CFO được chạy; AP seed 1.085 KTT + 175 CFO |
| FX USD và lãi/lỗ thực hiện | PASS | AR/AP invoice, receipt, payment, bank settlement, realized FX gain/loss, foreign cash balance và refund |
| Đối soát VNPAY | PASS | Gross 75.000.000, fee 1.125.000 (1,5%), net 73.875.000; sai lệch 1 VND bị chặn; unpost/repost giữ số dư |
| Cấn trừ AR/AP | PASS | AR 43.200.000 và AP 40.000.000; sau cấn trừ còn AR 3.200.000, AP 0, không tạo cash movement |
| Tất cả trường rỗng/null, sai định dạng, ký tự đặc biệt, ngày không hợp lệ | Chưa đủ bằng chứng | Chưa có bộ fuzz/boundary cho từng field và từng form |
| Quan hệ lọc đối tác → hợp đồng | Chưa đủ bằng chứng | Chưa tự động hóa đầy đủ lựa chọn reference/choice và kiểm tra tập hợp hợp đồng trên mọi form |
| Visible/Enabled theo quyền cho từng field/button | Chưa đủ bằng chứng | Role matrix kiểm tra quyền server/RLS; chưa chụp trạng thái UI cho mọi control × role |

## Luồng E2E đã chạy

- AR: nghiệm thu → hóa đơn đầu ra → thu tiền → đối chiếu công nợ và sổ cái.
- AP: hóa đơn nhà cung cấp → KTT/CFO duyệt theo ngưỡng → gửi ngân hàng → ghi sổ thanh toán; bank reject không làm giảm AP.
- Cấn trừ nội bộ AR/AP và thu nốt phần dư.
- Đối soát kênh VNPAY, phí ngân hàng, GL và dòng tiền.
- USD: chênh tỷ giá invoice/receipt/payment; xác nhận hoàn tiền và chống hoàn trùng.
- RLS theo chi nhánh; quyền 5 vai trò; đồng thời ghi phiếu thu dưới DataLock và từ chối chứng từ vượt số dư.
- Posting rollback, hủy ghi sổ/ghi lại, zero VAT, chứng từ nháp/hủy không hợp lệ và lệch GL/subledger.

## Bug phát hiện và hotfix

### 1. Bộ lọc ngày/tháng/quý trên 5 danh sách không tác động lên ngày chứng từ

`BoLocKy` có OnChange và giao diện hiển thị, nhưng `ApDungBoLocAtServer()` trước đây chỉ áp dụng trạng thái/đối tác. Chọn `HomNay`, `ThangNay`, `QuyNay` không lọc `Date`.

Hotfix thêm khoảng ngày bắt đầu/kết thúc theo `CurrentSessionDate()` và hai điều kiện DCS `Date >= start`, `Date <= end` trên cả năm list form. Runtime UI đã xác nhận 5/5 danh sách × 4 lựa chọn kỳ. Regression test trước hotfix đã fail; sau hotfix pass.

### 2. Danh sách cấn trừ và đối soát không xuất hiện trong navigation

Hai chứng từ có trong subsystem và role metadata, nhưng `MainSectionCommandInterface.xml` chỉ đặt 5 lệnh mở danh sách khác. Người dùng không thể mở hai list form qua navigation.

Hotfix thêm `StandardCommand.OpenList` cho `CanTruCongNoNoiBo` và `DoiSoatKenhThanhToan` vào visibility, placement và order. Configuration compile thành công; UI mở được cả list và detail cho `E2E-NET-001`/`E2E-BK-VNPAY-001`; full suite sau hotfix PASS.

Không phát hiện lỗi sản phẩm khác trong các ca đã chạy. Lỗi selector trong quá trình phát triển FormSmoke được sửa ở test harness; không phải lỗi ứng dụng.

## File đã sửa/thêm

- BSL period filtering:
  - `Configuration/Documents/BienBanNghiemThuGiaiDoan/Forms/FormDanhSach/Ext/Form/Module.bsl`
  - `Configuration/Documents/HoaDonGTGTDauRa/Forms/FormDanhSach/Ext/Form/Module.bsl`
  - `Configuration/Documents/PhieuThuTienKhachHang/Forms/FormDanhSach/Ext/Form/Module.bsl`
  - `Configuration/Documents/HoaDonNhaCungCap/Forms/FormDanhSach/Ext/Form/Module.bsl`
  - `Configuration/Documents/UyNhiemChi/Forms/FormDanhSach/Ext/Form/Module.bsl`
- Navigation: `Configuration/Ext/MainSectionCommandInterface.xml`.
- UI automation: `scripts/run_finance_ui_e2e.ps1`, `scripts/run_finance_e2e.ps1`.
- Regression test: `scripts/test_list_period_filters.ps1`.

## Phần chưa đạt tiêu chí 100%

**Toàn bộ test case hiện có đều PASS, nhưng không thể xác nhận “100% mọi nút và mọi trường” từ bằng chứng hiện tại.** Còn thiếu UI automation cho mọi nút chuẩn/custom, create/copy/print, mọi trường null/sai định dạng/ngày không hợp lệ/ký tự đặc biệt, selection forms và trạng thái Visible/Enabled theo từng role.

Trong codebase cũng không có Sales Order, Purchase Order, Payment Request document, Report object hoặc cơ chế khóa kỳ kế toán được phát hiện trong metadata/source scan. Vì vậy các kịch bản đó không thể được xác nhận bằng suite của cấu hình hiện tại. Hủy hóa đơn đã thanh toán và stress test deadlock cũng chưa có ca chuyên biệt. Các mục này được ghi là **chưa kiểm thử/không có đối tượng**, không tính là PASS.

## Trạng thái kết luận

- **Automated suite:** ALL EXECUTED CASES GREEN.
- **UI forms được mở:** 16/16 trong phạm vi 7 chứng từ + 2 Data Processor forms.
- **Strict acceptance 100% buttons/fields/workflows:** CHƯA ĐẠT; xem phần còn thiếu ở trên.

