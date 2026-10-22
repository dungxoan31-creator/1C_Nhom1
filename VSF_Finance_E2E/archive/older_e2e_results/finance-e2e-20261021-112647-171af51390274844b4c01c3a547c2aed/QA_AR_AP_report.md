# Báo cáo QA tự động AR/AP — 21/10/2026

## Kết quả cuối

- Run: `finance-e2e-20261021-112647-171af51390274844b4c01c3a547c2aed`.
- Full suite: **85/85 phase PASS, 0 phase FAIL**; tiến trình kết thúc với exit code 0.
- Runtime matrix: 41/41 trường bắt buộc, 7/7 giá trị tự điền, 7/7 biên AR, 8/8 biên AP; 7 nhánh lỗi đối soát và case phí 0 cũng PASS.
- Đối chiếu metadata: 114 thuộc tính trên 7 chứng từ; đủ 48/48 thuộc tính `FillChecking=ShowError` được phân loại thành 41 ca từ chối ghi rỗng và 7 ca autofill/calculation.
- UI native: 16/16 màn hình; 9/9 danh sách Catalog; 20/20 tab trên 5 form chứng từ; 7/7 required-field UI; 5/5 bộ lọc đối tác → hợp đồng.
- Quyền: 5 role × 10 assertion = 50/50. Luồng DataLock đồng thời, posting, sổ cái/subledger, FX, netting, ngân hàng và branch RLS đều PASS.
- Suite chạy trên clone tạm tại `%TEMP%`; `BaseInfobase` gốc không được dùng làm nơi ghi dữ liệu kiểm thử.

**Kết luận chính xác:** toàn bộ test hiện có đều xanh. Chưa thể kết luận coverage nghiệp vụ đạt 100% mọi tiêu chí ban đầu: một số metadata không tồn tại, nội dung bản in chưa hoàn chỉnh, và chưa fuzz mọi field/command theo mọi role. Chi tiết nằm trong [ma trận coverage](QA_AR_AP_coverage_matrix.md).

## Khảo sát metadata và kiến trúc

| Loại | Số lượng | Đối tượng |
|---|---:|---|
| Catalogs | 9 | ChiNhanh, DichVuCNTT, DoiTac, DuAn, HopDong, KhoanMucDongTien, PhapNhan, TaiKhoanTien, TienTe |
| Documents | 7 | BienBanNghiemThuGiaiDoan, HoaDonGTGTDauRa, PhieuThuTienKhachHang, HoaDonNhaCungCap, UyNhiemChi, CanTruCongNoNoiBo, DoiSoatKenhThanhToan |
| Accumulation registers | 3 | CongNoPhaiThu, CongNoPhaiTra, DongTien |
| Accounting registers | 1 | SoCaiKeToan |
| Information registers | 2 | PhanQuyenChiNhanh, TyGiaHoiDoai |
| Data Processor | 1 | BanLamViecWebERP, gồm dashboard và bàn duyệt Maker-Checker |
| Common modules | 12 | BSL cho dashboard, AR/AP seed, quyền, workflow, thuế, ngân hàng và kiểm thử biên |
| Roles | 5 | Admin, AR, AP, Kế toán trưởng, CFO |
| Reports | 0 | Dashboard aging được xác nhận qua Data Processor, không phải metadata Report riêng |

Đã đọc/đối chiếu object, manager và form modules có liên quan đến vòng đời chứng từ, validation, posting/undo posting, phân quyền, tỷ giá, thuế, duyệt và tích hợp ngân hàng. Không có metadata Sales Order, Purchase Order hoặc Payment Request; luồng AR hiện bắt đầu từ biên bản nghiệm thu, luồng AP từ hóa đơn nhà cung cấp. Không thấy service/metadata khóa kỳ kế toán.

## Ma trận thực thi tóm tắt

### Màn hình và tab

FormSmoke mở 7 list chứng từ, 7 form chứng từ và 2 form Data Processor. Các tab cấu hình trên 5 form tùy biến đều được chọn trong runtime; contract kiểm tra số lượng field control, tên và bounds khớp metadata:

| Form | Tab / số control theo thứ tự |
|---|---|
| BienBanNghiemThuGiaiDoan | 4 tab: 11, 1, 1, 3 |
| HoaDonGTGTDauRa | 4 tab: 11, 2, 2, 1 |
| PhieuThuTienKhachHang | 4 tab: 8, 1, 1, 1 |
| HoaDonNhaCungCap | 4 tab: 9, 2, 1, 1 |
| UyNhiemChi | 4 tab: 8, 1, 4, 1 |

Inventory 114 thuộc tính đối chiếu được binding vào custom form cho 5 chứng từ: BBNT 13/14, AR invoice 10/22, receipt 7/14, AP invoice 9/23, UNC 11/21 thuộc tính có ít nhất một control binding. Một số field không gắn form có thể là system-managed; các liên kết nguồn `ChungTuGoc` ở receipt/UNC và các field FCT/FX AP cần được rà nghiệp vụ trước khi coi là chủ ý.

CanTruCongNoNoiBo và DoiSoatKenhThanhToan không có form tùy biến `FormChungTu`; đã mở form mặc định qua runtime UI.

### Nút và command

| Nhóm | Kết quả |
|---|---|
| Create / Copy | 7/7 list chứng từ và 9/9 list Catalog mở form rồi đóng không lưu |
| Save của form mẫu đã ghi sổ | 2 command enabled được gọi; 5 command disabled được xác nhận |
| Save rỗng | 7/7 form từ chối ghi, không cấp số và hiện validation |
| Post / Undo | 2/2 chứng từ được Undo rồi Post lại; trạng thái cuối restored là posted |
| Print preview | 5/7 có command và mở preview; 2/7 không có command |
| Chứng từ liên quan | 4/4 command hiển thị đúng chuỗi tham chiếu mong đợi |
| Gửi ngân hàng / nhận hoàn tiền | ACCEPTED, HTTP_REJECTED, RefundReceived và idempotency được kiểm tra |
| Period filter | 5/5 list hỗ trợ được kiểm tra |
| Partner → contract choice | 5/5 form chỉ hiện hợp đồng đúng đối tác |

Preview đã mở được nhưng phần lớn vùng thân trang trống; metadata không có template/MXL in riêng cho chứng từ. Vì thế PASS ở đây chỉ khẳng định command mở preview, không xác nhận bản in nghiệp vụ hoàn chỉnh.

### Trường và validation

Runtime required-field matrix đã thử riêng từng trường; các phép ghi thiếu dữ liệu bị từ chối và probe được rollback:

| Chứng từ | Trường bắt buộc đã thử |
|---|---|
| BBNT | `PhapNhan`, `DoiTac`, `HopDong`, `GiaTriNghiemThuChuaVAT` |
| Hóa đơn AR | `PhapNhan`, `DoiTac`, `HopDong`, `SoHoaDon`, `KyHieu`, `NgayHoaDon` |
| Phiếu thu | `PhapNhan`, `DoiTac`, `HopDong`, `TaiKhoanTien`, `KhoanMucDongTien`, `SoTien` |
| Hóa đơn AP | `PhapNhan`, `DoiTac`, `HopDong`, `SoHoaDon` |
| Ủy nhiệm chi | `PhapNhan`, `DoiTac`, `HopDong`, `TaiKhoanTien`, `KhoanMucDongTien`, `TienTe`, `SoTien` |
| Cấn trừ | `PhapNhan`, `DoiTac`, `ChungTuAR`, `ChungTuAP`, `SoTien` |
| Đối soát | `PhapNhan`, `DoiTacTrungGian`, `TaiKhoanTien`, `KhoanMucDongTien`, `TienTe`, `KenhThanhToan`, `TongTienGiaoDich`, `TongPhi`, `TongTienThucNhan` |

Đã kiểm tra autofill gồm tổng/thuế/trạng thái, tiền tệ và ngày hóa đơn; ngày tương lai, MST sai ký tự/độ dài, VAT/total, dung sai tỷ giá, FCT VAT/CIT, thu vượt công nợ, phí đối soát âm/0 và dấu tiền. Inventory có đủ 114 thuộc tính: 48/48 trường metadata bắt buộc đã được phân loại và xác nhận contract; 65 thuộc tính chưa có ca runtime field-level riêng (một số vẫn được chạm trong happy path/E2E). Vì vậy chưa phải fuzz tổng quát toàn bộ kiểu dữ liệu trên mọi thuộc tính.

### Luồng nghiệp vụ

- **AR:** BBNT → hóa đơn 216 triệu (net 200 + VAT 16) → thu đủ, dư nợ về 0; thu vượt 1 VND bị chặn và không phát sinh AR/GL/cash; không cho hủy ghi sổ hóa đơn còn phiếu thu đã post.
- **AP:** hóa đơn gross 200 triệu; FCT VAT 10 triệu + CIT 10 triệu; phải trả ròng 180 triệu → duyệt KTT → UNC → bank accepted/rejected → posting.
- **Cấn trừ:** giảm đúng AR/AP, bảo toàn phần AR còn lại, từ chối vượt số dư và không phát sinh cash movement.
- **FX:** AR/AP USD, tỷ giá ghi sổ và thanh toán, lãi/lỗ đã thực hiện, over-collection và refund duplicate idempotency.
- **Đối soát:** gross 75 triệu, phí 1,125 triệu, net 73,875 triệu; 7 case âm bị từ chối, phí 0 ghi sổ rồi Undo sạch.
- **Khác:** Maker-Checker theo ngưỡng 500 triệu; 50 assertion phân quyền; branch RLS; DataLock contention; GL/subledger mismatch detection và rollback; posting state invariants.
- **Tải hồi quy:** AR 1.260 BBNT, 1.260 hóa đơn, 1.162 phiếu thu; AP 1.260 hóa đơn, trong đó 315 USD.

## Lỗi tìm thấy và sửa

Các lỗi nghiệp vụ đã được sửa trong codebase và được suite này kiểm tra lại:

| Lỗi / nguyên nhân | Hotfix |
|---|---|
| Chỉ dựa vào FillChecking của form khiến lời gọi `Write()` từ BSL có thể ghi chứng từ thiếu dữ liệu | Thêm `ValidateRequiredFieldsForWrite(Cancel)` trong `BeforeWrite` cho cả 7 Document; lỗi gắn với field và không bỏ validation nghiệp vụ |
| Metadata bắt buộc hóa đơn AR phải có BBNT, trong khi direct invoice là luồng hợp lệ | `BienBanNghiemThu.FillChecking` chuyển thành `DontCheck`; khi BBNT được khai báo vẫn đối chiếu Pháp nhân/Đối tác/Hợp đồng |
| Validator MST cũ chỉ xét độ dài nên ký tự chữ/gạch nối có thể lọt | Chuẩn hóa và kiểm tra từng ký tự thuộc `0123456789`, giữ độ dài hợp lệ 10/13/14 |
| Posting có thể dùng hợp đồng sai chủ sở hữu/pháp nhân | Kiểm tra chủ hợp đồng, đối tác và pháp nhân trước khi tạo movement; trường hợp sai bị rollback |
| Rights mặc định cấp quyền Posting/Undo cho Admin dù server SoD từ chối | Khai báo deny rõ quyền Posting/Undo và quyền tương tác tương ứng trên 7 Document |
| Fixture đối soát âm chạy trước khi có cash-flow category Chi | Tạo fixture category trong bước setup E2E bằng Admin; suite hiện chạy case âm và phí 0 thành công |
| Locator Save mơ hồ giữa command cùng tên | Chọn đúng command row của form; fallback chỉ khi còn đúng một candidate |
| UI automation đôi lúc bấm “Functions” lần hai và đóng menu do không khôi phục foreground/chờ quá ngắn | `Open-ListCommand` đưa 1C lên foreground, đợi có giới hạn, quan sát menu trước khi mở lại và báo menu items khi lỗi. Receipt từng fail trước khi mở list, sau sửa chạy lại PASS cả targeted và full suite. |

## File BSL/config và harness đã sửa

- Object modules thêm validation required field và kiểm tra chiều posting: [BBNT](../../Configuration/Documents/BienBanNghiemThuGiaiDoan/Ext/ObjectModule.bsl), [hóa đơn AR](../../Configuration/Documents/HoaDonGTGTDauRa/Ext/ObjectModule.bsl), [phiếu thu](../../Configuration/Documents/PhieuThuTienKhachHang/Ext/ObjectModule.bsl), [hóa đơn AP](../../Configuration/Documents/HoaDonNhaCungCap/Ext/ObjectModule.bsl), [UNC](../../Configuration/Documents/UyNhiemChi/Ext/ObjectModule.bsl), [cấn trừ](../../Configuration/Documents/CanTruCongNoNoiBo/Ext/ObjectModule.bsl), [đối soát](../../Configuration/Documents/DoiSoatKenhThanhToan/Ext/ObjectModule.bsl).
- MST số-only: [HoaDonGTGTDauRa ObjectModule](../../Configuration/Documents/HoaDonGTGTDauRa/Ext/ObjectModule.bsl), trong nhánh kiểm tra `MaSoThueChuanHoa` / `ChiCoChuSo`.
- BBNT tùy chọn khi phát hành hóa đơn trực tiếp: [HoaDonGTGTDauRa.xml](../../Configuration/Documents/HoaDonGTGTDauRa.xml), thuộc tính `BienBanNghiemThu` (`FillChecking=DontCheck`); kiểm tra chiều liên kết vẫn nằm trong BSL.
- SoD Admin: [QuanTriHeThong Rights.xml](../../Configuration/Roles/QuanTriHeThong/Ext/Rights.xml), deny 5 quyền posting liên quan trên từng Document.
- Runtime fixture và matrix: [SeedBoundaryTestsServer](../../Configuration/CommonModules/SeedBoundaryTestsServer/Ext/Module.bsl).
- UI automation: [run_finance_ui_e2e.ps1](../../scripts/run_finance_ui_e2e.ps1); runner và contract tab: [run_finance_e2e.ps1](../../scripts/run_finance_e2e.ps1), [test_form_tab_runtime_contract.ps1](../../scripts/test_form_tab_runtime_contract.ps1).

Ví dụ BSL trong `ValidateRequiredFieldsForWrite` của hóa đơn AR: nếu thiếu thuộc tính bắt buộc, hủy ghi, báo lỗi gắn đúng field rồi `Return`; sau đó mới kiểm tra chủ hợp đồng và tổng tiền dương. MST được kiểm tra riêng từng ký tự trước khi cho ghi. Không có assert nào bị comment/xóa để làm xanh test.

## Bằng chứng kết quả

- [summary.json](summary.json) — status PASS, 85 phase, dữ liệu và từng phase.
- [ui-document-forms.json](ui-document-forms.json) — 16 màn hình, tab, field controls, lệnh và preview.
- [ui-catalog-lists.json](ui-catalog-lists.json) — 9/9 danh sách Catalog.
- [ui-required-field-validation.json](ui-required-field-validation.json) — 7/7 form từ chối Save rỗng.
- [required_field_runtime_matrix.json](required_field_runtime_matrix.json) — 41 required, 7 autofill, 7 AR boundary, 8 AP boundary.
- [document-field-inventory.csv](document-field-inventory.csv) và [summary](document-field-inventory.summary.json) — đối chiếu 114 thuộc tính, loại dữ liệu, FillChecking, runtime case và binding tới 20 tab.
- [ui-reference-choice.json](ui-reference-choice.json) — 5/5 lọc hợp đồng theo đối tác.
- [ui-posting-command-actions.json](ui-posting-command-actions.json) — Undo/Post 2/2.
- [ar-concurrency.json](ar-concurrency.json), [payment_reconciliation.json](payment_reconciliation.json), [dashboard_verify.json](dashboard_verify.json), [ar-seed-regression.json](ar-seed-regression.json), [ap-seed-regression.json](ap-seed-regression.json).
- [AR print preview](finance-print-preview-E2E-AR001.png), [AP print preview](finance-print-preview-E2E-AP001.png), [phiếu thu preview](finance-print-preview-E2E-PT001.png), [UNC preview](finance-print-preview-E2E-UNC01.png), [BBNT preview](finance-print-preview-E2E-BB001.png).

## Khoảng trống còn lại

- Không có Sales Order, Purchase Order, Payment Request hoặc metadata Report riêng; không thể test UI/flow tương ứng.
- Không thấy cơ chế khóa kỳ; ca sửa chứng từ trong kỳ khóa chưa thể thực thi.
- Preview mở được 5/7, nhưng không có print template riêng và nội dung hiển thị chưa đủ để xác nhận bản in hoàn chỉnh.
- Native Post/Undo chỉ chạy trên 2 chứng từ; backend posting lifecycle có assertion riêng cho các luồng còn lại.
- Required-field, boundary và UI assertions bao phủ matrix hiện có, chưa phải fuzz từng field bằng null, chuỗi đặc biệt, sai kiểu và biên độ dài trên toàn bộ form.
- Chưa click mọi command trên mọi form theo mọi role; 50 assertion role hiện có không đồng nghĩa kiểm thử toàn bộ tổ hợp role × command.
- Có kiểm tra contention/DataLock đơn lẻ; chưa phải stress test deadlock kéo dài.

Do đó, **suite hiện tại xanh hoàn toàn**, còn yêu cầu **coverage strict 100% chưa đạt** vì các gap trên.
