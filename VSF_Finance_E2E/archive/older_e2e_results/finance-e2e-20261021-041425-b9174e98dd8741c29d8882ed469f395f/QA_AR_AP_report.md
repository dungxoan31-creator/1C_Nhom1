# Báo cáo QA tự động AR/AP — 21/10/2026

## Kết quả chạy cuối

- Run: `finance-e2e-20261021-041425-b9174e98dd8741c29d8882ed469f395f`.
- Trạng thái runner: **PASS — 83/83 phase PASS, 0 phase FAIL**.
- UI: 16/16 màn hình chứng từ/Data Processor mở được; 9 form context có audit controls; 9/9 danh sách Catalog mở được; Tạo mới/Sao chép mở và đóng không lưu trên 7/7 danh sách chứng từ và 9/9 danh sách Catalog; 5/5 danh sách chứng từ xác nhận bộ lọc kỳ; partner→contract choice UI 5/5 chứng từ PASS; 4/4 luồng ngân hàng/hoàn tiền UI PASS.
- Hồi quy posting: lifecycle 4/4; GL–subledger integrity 3/3; AP invoice lifecycle 3/3; posting invariants 5/5; boundary tests 3/3.
- Security: 50/50 kiểm tra trong ma trận 5 vai trò; branch RLS PASS. AR DataLock concurrency và chặn thu vượt số dư PASS.
- Seed hồi quy: AR 1.260 biên bản, 1.260 hóa đơn, 1.162 phiếu thu; AP 1.260 hóa đơn, trong đó 315 hóa đơn USD. Tổng bút toán AR khớp sổ cái/công nợ/tiền; 0 sai lệch nguồn thuế.
- Cơ sở dữ liệu chạy thử là bản clone trong `%TEMP%`; không ghi vào `BaseInfobase` gốc.

Artifact bằng chứng: `summary.json`, `ui-document-forms.json`, `ui-catalog-lists.json`, `ui-list-periods.json`, `reference-choice-contract.json`, `ui-reference-choice.json`, năm file `ui-reference-choice-*.json`, `required_reference_post.json`, `required_ap_contract_post.json` và các file phase trong thư mục run này.

## Khảo sát metadata và kiến trúc

| Loại | Số lượng | Thành phần |
|---|---:|---|
| Catalogs | 9 | ChiNhanh, DichVuCNTT, DoiTac, DuAn, HopDong, KhoanMucDongTien, PhapNhan, TaiKhoanTien, TienTe |
| Documents | 7 | BienBanNghiemThuGiaiDoan, HoaDonGTGTDauRa, PhieuThuTienKhachHang, HoaDonNhaCungCap, UyNhiemChi, CanTruCongNoNoiBo, DoiSoatKenhThanhToan |
| Accumulation registers | 3 | CongNoPhaiThu, CongNoPhaiTra, DongTien |
| Accounting registers | 1 | SoCaiKeToan |
| Information registers | 2 | PhanQuyenChiNhanh, TyGiaHoiDoai |
| Data processors | 1 | BanLamViecWebERP, có 2 custom forms |
| Common modules | 12 | Posting lifecycle, generator AR/AP, RLS, approvals, thuế, ngân hàng và seed/test |
| Roles | 5 | Admin, AR, AP, Kế toán trưởng, CFO |
| Reports | 0 | Không có object Reports; phần tổng hợp/aging nằm trên dashboard Data Processor |

Không có metadata riêng cho Sales Order, Purchase Order hoặc Payment Request; luồng AR hiện bắt đầu từ biên bản nghiệm thu, luồng AP bắt đầu từ hóa đơn nhà cung cấp. `CanTruCongNoNoiBo` và `DoiSoatKenhThanhToan` không có custom form XML, dùng form mặc định 1C. Các danh mục cũng không khai báo custom form XML; lượt UI dùng form mặc định. Metadata có liên kết lọc `HopDong` theo `DoiTac` trên 5 chứng từ; contract test xác nhận `Filter.ChuSoHuu`, DataPath và clear khi đổi đối tác. Runtime UI kiểm tra đủ 5 chứng từ: Acceptance/ARInvoice/Receipt lọc `TEST_VG_VINCLUB` về `HD-TEST_VG_VINCLUB-2025`; APInvoice/Payment lọc `TEST_NCC_AWS` về `HD-TEST_NCC_AWS-2025`. Cả 5 popup chỉ có hợp đồng thuộc đối tác đang chọn (0 mã ngoài phạm vi).

## Ma trận màn hình

### Chứng từ và Data Processor

| Màn hình | Kết quả | Bằng chứng |
|---|---|---|
| Danh sách Biên bản nghiệm thu | PASS | Mở danh sách; bộ lọc kỳ được kiểm tra |
| Chi tiết Biên bản nghiệm thu | PASS | Form mở; audit thấy 11 edit, 12 named inputs |
| Danh sách Hóa đơn GTGT đầu ra | PASS | Mở danh sách; bộ lọc kỳ được kiểm tra |
| Chi tiết Hóa đơn GTGT đầu ra | PASS | Form mở; kiểm tra nguồn nghiệm thu và net/VAT/gross 200/16/216 triệu VND |
| Danh sách Phiếu thu khách hàng | PASS | Mở danh sách; bộ lọc kỳ được kiểm tra |
| Chi tiết Phiếu thu khách hàng | PASS | Form mở; audit thấy 9 edit, 9 named inputs |
| Danh sách Hóa đơn nhà cung cấp | PASS | Mở danh sách; bộ lọc kỳ được kiểm tra |
| Chi tiết Hóa đơn nhà cung cấp | PASS | Form mở; AP E2E kiểm tra gross/FCT/net payable |
| Danh sách Ủy nhiệm chi | PASS | Mở danh sách; bộ lọc kỳ được kiểm tra |
| Chi tiết Ủy nhiệm chi | PASS | Form mở; bank send/reject và xác nhận hoàn tiền chạy qua UI |
| Danh sách Cấn trừ công nợ nội bộ | PASS | Mở được qua Navigation sau hotfix; form mặc định |
| Chi tiết Cấn trừ công nợ nội bộ | PASS | Mở chứng từ `E2E-NET-001` |
| Danh sách Đối soát kênh thanh toán | PASS | Mở được qua Navigation sau hotfix; form mặc định |
| Chi tiết Đối soát kênh thanh toán | PASS | Mở chứng từ `E2E-BK-VNPAY-001` |
| Bàn làm việc Web ERP | PASS | Form mở; dashboard/aging/period/work queue có runtime assertions |
| Duyệt Maker-Checker hàng loạt | PASS | Form mở từ dashboard; batch approval được kiểm tra backend |

Tổng: 7 danh sách + 7 form chứng từ + 2 form Data Processor = 16/16 màn hình.

### Thao tác trên danh sách chứng từ

| Chứng từ | Tạo mới | Sao chép |
|---|---|---|
| Biên bản nghiệm thu `E2E-BB001` | Mở/đóng, không lưu | Mở/đóng, không lưu |
| Hóa đơn đầu ra `E2E-AR001` | Mở/đóng, không lưu | Mở/đóng, không lưu |
| Phiếu thu `E2E-PT001` | Mở/đóng, không lưu | Mở/đóng, không lưu |
| Hóa đơn nhà cung cấp `E2E-AP001` | Mở/đóng, không lưu | Mở/đóng, không lưu |
| Ủy nhiệm chi `E2E-UNC01` | Mở/đóng, không lưu | Mở/đóng, không lưu |
| Cấn trừ công nợ `E2E-NET-001` | Mở/đóng, không lưu | Mở/đóng, không lưu |
| Đối soát kênh `E2E-BK-VNPAY-001` | Mở/đóng, không lưu | Mở/đóng, không lưu |

### Danh mục

| Danh mục | Danh sách | Tạo mới | Sao chép |
|---|---|---|---|
| ChiNhanh | PASS | Mở/đóng, không lưu | Mở/đóng, không lưu |
| DichVuCNTT | PASS | Mở/đóng, không lưu | Mở/đóng, không lưu |
| DoiTac | PASS | Mở/đóng, không lưu | Mở/đóng, không lưu |
| DuAn | PASS | Mở/đóng, không lưu | Mở/đóng, không lưu |
| HopDong | PASS | Mở/đóng, không lưu | Mở/đóng, không lưu |
| KhoanMucDongTien | PASS | Mở/đóng, không lưu | Mở/đóng, không lưu |
| PhapNhan | PASS | Mở/đóng, không lưu | Mở/đóng, không lưu |
| TaiKhoanTien | PASS | Mở/đóng, không lưu | Mở/đóng, không lưu |
| TienTe | PASS | Mở/đóng, không lưu | Mở/đóng, không lưu |

Sao chép được kiểm tra trên các danh sách có dòng dữ liệu hiển thị; từng form tạo/sao chép đã đóng bằng UI mà không ghi dữ liệu.

## Ma trận nút và tác vụ

| Tác vụ | Kết quả | Phạm vi xác nhận |
|---|---|---|
| Mở list/detail | PASS | 16 màn hình chứng từ/Data Processor và 9 danh sách Catalog |
| Tạo mới/Sao chép chứng từ | PASS | Mở form trên 7/7 danh sách; đóng không lưu |
| Tạo mới/Sao chép Catalog | PASS | Mở form trên 9/9 danh sách; đóng không lưu |
| Gửi thanh toán ngân hàng | PASS | UI trả `ACCEPTED`; retry giữ nguyên transaction ID (idempotency) |
| Ngân hàng từ chối | PASS | UI trả `HTTP_REJECTED`; AP và transaction ID không đổi/không phát sinh |
| Xác nhận tiền hoàn | PASS | UI trả `REFUND_RECEIVED` cho hoàn gốc và ca duplicate; posting kiểm tra idempotency |
| Phê duyệt Maker-Checker | PASS có giới hạn | Backend batch 3 chứng từ ở KTT và 1 chứng từ ở CFO; form mở nhưng nút phê duyệt hàng loạt chưa được click bằng UI |
| Ghi/Ghi sổ/Hủy ghi sổ/Ghi lại | PASS ở backend | Posting lifecycle, AP unpost/repost, rollback, GL/subledger; hủy hóa đơn AR đã thu đủ bị từ chối và giữ movement |
| In/Preview và toàn bộ lệnh tùy chỉnh | Chưa đủ bằng chứng | Control được ghi nhận trong UI audit nhưng chưa click riêng trên mọi form |

UI audit ghi nhận visible/enabled/disabled button names cho 7 form chứng từ và 2 form Data Processor ở vai trò Admin. Đây không phải kiểm thử mọi nút × mọi vai trò.

## Ma trận trường và validation

| Nhóm | Kết quả | Bằng chứng |
|---|---|---|
| Hiển thị field | PASS trong phạm vi audit | 9 form context có visible input/button inventory; các field tiền và thuế được đối chiếu trong E2E |
| AR VAT và tổng tiền | PASS | Net 200.000.000, VAT 16.000.000, gross 216.000.000; seed có 6 ca biên VAT và kiểm tra nguồn thuế |
| Thu vượt công nợ | PASS | Thu 216.000.001 trên hóa đơn 216.000.000 bị từ chối; không tạo movement AR/GL/tiền |
| AP thuế nhà thầu | PASS | Gross 200.000.000; FCT VAT 10.000.000; FCT CIT 10.000.000; payable 180.000.000 VND |
| Ngưỡng phê duyệt AP | PASS | Kiểm tra biên 500 triệu và escalation; seed duyệt 1.085 hóa đơn bởi KTT, 175 bởi CFO |
| FX USD và lãi/lỗ thực hiện | PASS | AR/AP invoice, receipt, payment, bank settlement, FX gain/loss và refund |
| Đối soát VNPAY | PASS | Gross 75.000.000; fee 1.125.000 (1,5%); net 73.875.000; lệch 1 VND bị chặn |
| Rỗng/null, định dạng sai, ký tự đặc biệt, ngày không hợp lệ trên mọi field | Chưa đủ bằng chứng | Chưa có bộ field fuzz toàn diện cho mỗi form/control |
| Metadata filter Đối tác → Hợp đồng | Static 5/5; UI runtime 5/5 | Cả năm form mở popup đối tác/hợp đồng, chọn đúng đối tác và chỉ nhìn thấy hợp đồng tương ứng; 0 mã hợp đồng ngoài phạm vi |
| Ràng buộc chủ Hợp đồng khi ghi hóa đơn AR/AP | PASS 3/3 regression | BBNT, hóa đơn AR trực tiếp và hóa đơn AP có hợp đồng thuộc đối tác khác đều bị từ chối; không Posted, 0 movement lưu lại |
| Visible/Enabled theo từng role | Chưa đủ bằng chứng | Backend role/RLS matrix đạt 50/50; chưa audit mọi control ở UI cho từng role |

## Luồng E2E đã chạy

- AR: biên bản nghiệm thu → hóa đơn đầu ra → thu tiền → đối chiếu công nợ/sổ cái; kiểm tra over-collection và từ chối hủy ghi sổ hóa đơn đã thu.
- AP: hóa đơn nhà cung cấp → thuế FCT → phê duyệt theo ngưỡng → ủy nhiệm chi → ngân hàng → ghi sổ; nhánh bank reject không giảm AP.
- Bù trừ nội bộ AR/AP, giới hạn theo số dư và thu nốt phần còn lại.
- Đối soát VNPAY, phí ngân hàng, GL và dòng tiền.
- USD: chênh tỷ giá invoice/receipt/payment, lãi/lỗ thực hiện, xác nhận hoàn tiền và duplicate.
- RLS theo chi nhánh, ma trận 5 vai trò, đồng thời ghi phiếu thu dưới DataLock và từ chối thu vượt số dư.
- Posting rollback/repost, hóa đơn hủy/nháp, zero VAT, kiểm tra lệch GL/subledger.

## Bug phát hiện, nguyên nhân và hotfix

### 1. Bộ lọc ngày/tháng/quý trên 5 danh sách không lọc ngày chứng từ

`ApDungBoLocAtServer()` trước đây chỉ áp dụng một phần trạng thái/đối tác, không đưa khoảng ngày vào điều kiện truy vấn. Chọn `HomNay`, `ThangNay`, `QuyNay` không lọc theo `Date`.

Hotfix thêm ngày đầu/cuối kỳ và điều kiện ngày chứng từ ở năm list form. Regression UI chạy 5 danh sách × 4 lựa chọn kỳ; test hợp đồng và runtime đều PASS.

### 2. Hai danh sách chứng từ tùy chỉnh không có lệnh Navigation

`CanTruCongNoNoiBo` và `DoiSoatKenhThanhToan` có metadata/subsystem nhưng thiếu `StandardCommand.OpenList` trong command interface.

Hotfix thêm visibility, placement và order cho hai lệnh; sau compile, list và detail đều mở bằng UI.

### 3. Không thể mở danh sách Catalog từ Navigation

Cả 9 Catalog thuộc subsystem nhưng không có `StandardCommand.OpenList` trong command interface. UI smoke ban đầu xác nhận không có menu entry để mở.

Hotfix thêm visibility, placement và order cho 9 danh sách Catalog. Thêm `CatalogSmoke` và contract test; full run mở được 9/9 danh sách, Create và Copy mỗi lệnh 9/9 form rồi đóng mà không lưu.

### 4. Fixture test đọc dữ liệu trong transaction đã bị 1C đánh dấu lỗi

Khi `Write(UndoPosting)` bị từ chối vì hóa đơn đã được phiếu thu ghi sổ tham chiếu, transaction test không thể tiếp tục truy vấn. Đây là lỗi fixture, không phải lỗi logic sản phẩm: guard nghiệp vụ đã chặn đúng thao tác.

Hotfix fixture rollback ngay sau thao tác bị từ chối rồi xác minh ngoài transaction. Ca runtime xác nhận hóa đơn/phiếu thu vẫn posted và movements còn nguyên.


### 5. BBNT có thể ghi sổ thiếu đối tác/hợp đồng hoặc sai chủ hợp đồng

Regression test đỏ xác nhận ba chứng từ BBNT ở trạng thái được duyệt vẫn ghi sổ thành công dù thiếu `DoiTac`, thiếu `HopDong`, hoặc hợp đồng thuộc đối tác khác; mỗi lần ghi sổ tạo một movement AR và một movement GL. Metadata `FillChecking=ShowError` và bộ lọc chọn hợp đồng chỉ bảo vệ thao tác qua form, còn lời gọi BSL `Write(DocumentWriteMode.Posting)` đi thẳng vào `Posting()`.

Hotfix thêm kiểm tra `PhapNhan`, `DoiTac`, `HopDong`, chủ hợp đồng và pháp nhân của hợp đồng trong `Posting()` trước khi tạo movement. Regression xanh xác nhận 3/3 lệnh ghi sổ bị từ chối, chứng từ không lưu trạng thái Posted và có 0 movement AR/GL.

### Điều chỉnh fixture UI (không phải lỗi sản phẩm)

Popup AP hiển thị master data `TEST_NCC_AWS`/`HD-TEST_NCC_AWS-2025`, không hiển thị fixture riêng `E2E_AWS_VND` trong lựa chọn UI. Chỉnh test fixture sang mã catalog hiện có; APInvoice và Payment sau đó đều PASS, không sửa dữ liệu nghiệp vụ.

### 6. Hóa đơn AR ghi sổ được với hợp đồng của đối tác khác

Regression đỏ tạo hóa đơn đầu ra trực tiếp cho khách hàng A nhưng gán hợp đồng thuộc khách hàng B. `HoaDonGTGTDauRa.Posting()` chỉ kiểm tra ba tham chiếu có giá trị, nên programmatic `Write(Posting)` vẫn chấp nhận giao dịch dù popup UI đang lọc hợp đồng đúng.

Hotfix bổ sung so khớp chủ hợp đồng với `DoiTac`, pháp nhân hợp đồng với `PhapNhan`, và khi có nguồn BBNT thì so khớp cả ba chiều pháp nhân/đối tác/hợp đồng với chứng từ nguồn. Regression xanh xác nhận lệnh bị từ chối, invoice không Posted sau rollback và không có movement được lưu.

### 7. Hóa đơn AP ghi sổ được với hợp đồng của đối tác khác

`HoaDonNhaCungCap.Posting()` đã kiểm tra pháp nhân, nhà cung cấp, hợp đồng và tổng tiền bắt buộc nhưng chưa xác minh chủ hợp đồng hay pháp nhân hợp đồng. Regression đỏ xác nhận hóa đơn nhà cung cấp có thể Posted với hợp đồng thuộc đối tác khác.

Hotfix kiểm tra chủ hợp đồng và pháp nhân trước khi tạo movement. Regression xanh dưới vai trò Kế toán trưởng xác nhận posting bị từ chối; hóa đơn không Posted và không có movement AP/GL sau rollback. Fixture được đánh dấu xóa sau kiểm tra để không xuất hiện trong dashboard.
Không phát hiện lỗi sản phẩm khác trong các ca đã thực thi.

## File hotfix và test

- Bộ lọc kỳ BSL trên 5 list form:
  - `Configuration/Documents/BienBanNghiemThuGiaiDoan/Forms/FormDanhSach/Ext/Form/Module.bsl`
  - `Configuration/Documents/HoaDonGTGTDauRa/Forms/FormDanhSach/Ext/Form/Module.bsl`
  - `Configuration/Documents/PhieuThuTienKhachHang/Forms/FormDanhSach/Ext/Form/Module.bsl`
  - `Configuration/Documents/HoaDonNhaCungCap/Forms/FormDanhSach/Ext/Form/Module.bsl`
  - `Configuration/Documents/UyNhiemChi/Forms/FormDanhSach/Ext/Form/Module.bsl`
- Command interface cho 2 document list và 9 Catalog list: `Configuration/Ext/MainSectionCommandInterface.xml`.
- UI automation Catalog lists/Create/Copy và các luồng UI: `scripts/run_finance_ui_e2e.ps1`.
- Runner, assertions và E2E phase: `scripts/run_finance_e2e.ps1`.
- Contract tests: `scripts/test_catalog_ui_coverage.ps1`, `scripts/test_list_period_filters.ps1`, `scripts/test_form_smoke_audit.ps1`, `scripts/test_reference_choice_filters.ps1`, `scripts/test_paid_invoice_unpost_contract.ps1`.
- Fixture boundary test: `Configuration/CommonModules/SeedBoundaryTestsServer/Ext/Module.bsl`.
- Hotfix kiểm tra bắt buộc khi BBNT ghi sổ: `Configuration/Documents/BienBanNghiemThuGiaiDoan/Ext/ObjectModule.bsl` (`Posting()`, trước khi ghi sổ tích lũy và sổ cái).
- Kiểm tra chủ hợp đồng và pháp nhân khi ghi hóa đơn AR: `Configuration/Documents/HoaDonGTGTDauRa/Ext/ObjectModule.bsl`.
- Kiểm tra chủ hợp đồng và pháp nhân khi ghi hóa đơn AP: `Configuration/Documents/HoaDonNhaCungCap/Ext/ObjectModule.bsl`.
- Regression 3 ca tham chiếu bắt buộc: `Configuration/CommonModules/SeedBoundaryTestsServer/Ext/Module.bsl` (`PrepareRequiredReferencePostingFixtures`, `VerifyRequiredReferencePostingRejected`); có thêm fixture hóa đơn AR sai chủ hợp đồng.
- Regression AP sai chủ hợp đồng: `PrepareAPWrongContractPostingFixture`, `VerifyAPWrongContractPostingRejected` trong cùng module.
- Runtime UI partner/contract choice 5/5: `scripts/run_finance_ui_e2e.ps1`; runner lặp 5 form và xác nhận 5/5: `scripts/run_finance_e2e.ps1`.

Full run đã compile/update cấu hình thành công. Các contract test nêu trên cũng được chạy riêng và PASS.

## Kết luận và giới hạn

- **Kết quả thực thi:** ALL EXECUTED TESTS GREEN — 83/83 phase, không có phase fail.
- **Màn hình đã mở:** 16/16 chứng từ/Data Processor; 9/9 Catalog list; Create/Copy Catalog 9/9.
- **Tiêu chí strict 100% mọi nút, mọi field và mọi workflow:** **chưa thể xác nhận**. Còn thiếu kiểm tra UI click cho mọi standard/custom command; field fuzz/null/format/date cho từng field; quyền Visible/Enabled từng control cho từng role; khóa kỳ và stress/deadlock.
- Sales Order, Purchase Order, Payment Request và Reports object không tồn tại trong metadata hiện tại; các luồng tương ứng không thể được đánh dấu PASS cho cấu hình này. Dashboard được kiểm tra nhưng không phải object Reports.

Do đó, suite hiện có xanh hoàn toàn, nhưng không ghi nhận coverage 100% ngoài bằng chứng thực tế.
