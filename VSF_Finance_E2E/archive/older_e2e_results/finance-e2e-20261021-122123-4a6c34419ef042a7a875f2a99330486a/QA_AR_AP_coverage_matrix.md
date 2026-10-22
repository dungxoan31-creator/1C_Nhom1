# Ma trận coverage AR/AP — run 20261021-115703

Run cuối: `finance-e2e-20261021-122123-4a6c34419ef042a7a875f2a99330486a`. **85/85 phase PASS, 0 FAIL.** `PASS` nghĩa assertion đã chạy và đạt; `Partial` là một phần tổ hợp được chạy; `Gap` là đối tượng chưa có hoặc chưa có kiểm thử tương ứng.

## Metadata

| Nhóm | Inventory | Coverage |
|---|---|---|
| Catalog | 9: ChiNhanh, DichVuCNTT, DoiTac, DuAn, HopDong, KhoanMucDongTien, PhapNhan, TaiKhoanTien, TienTe | 9/9 danh sách mở; Create/Copy mở form — PASS |
| Document | 7: BBNT, hóa đơn AR, phiếu thu, hóa đơn AP, UNC, cấn trừ, đối soát | 7/7 list và document form mở — PASS |
| Accumulation register | 3: CongNoPhaiThu, CongNoPhaiTra, DongTien | Số dư/movement AR, AP, tiền được assert qua E2E — PASS cho assertion hiện có |
| Accounting register | 1: SoCaiKeToan | Debit/credit, cân đối và mismatch rollback — PASS cho assertion hiện có |
| Information register | 2: PhanQuyenChiNhanh, TyGiaHoiDoai | Branch RLS và FX — PASS cho case hiện có |
| Data Processor | 1: BanLamViecWebERP | Dashboard và batch Maker-Checker; 2 form mở — PASS |
| Common Module | 12 | Module nghiệp vụ, workflow, quyền, thuế, ngân hàng, dashboard và test liên quan đã được rà soát |
| Role | 5 | 10 assertion mỗi role, 50/50 PASS |
| Report metadata | 0 | Aging có trên dashboard; Report object riêng — Gap |
| Document attributes | 114 | 41 required-write + 7 autofill/calculation + 66 field write/readback = 114/114 phân loại runtime |

## Màn hình và form

### Màn hình mở

| Nhóm | Số lượng | Kết quả |
|---|---:|---|
| Document list | 7 | PASS |
| Document form | 7 | PASS |
| Data Processor form | 2 | PASS |
| Tổng FormSmoke | 16 | 16/16 PASS |
| Catalog list | 9 | 9/9 PASS |

### Tab của custom document form

| Form | Tab / visible input theo thứ tự | Kết quả |
|---|---|---|
| BBNT | 11 / 1 / 1 / 3 | 4/4 tab; PASS |
| Hóa đơn AR | 11 / 2 / 2 / 1 | 4/4 tab; PASS |
| Phiếu thu | 8 / 1 / 1 / 1 | 4/4 tab; PASS |
| Hóa đơn AP | 9 / 2 / 1 / 1 | 4/4 tab; PASS |
| UNC | 8 / 1 / 4 / 1 | 4/4 tab; PASS |
| **Tổng** | **20 tab** | **20/20 PASS** |

Cấn trừ và đối soát mở default form; repo không có custom `FormChungTu` cho hai document này.

## Command và thao tác UI

| Thao tác | Kết quả | Trạng thái / giới hạn |
|---|---|---|
| Create / Copy trên document list | 7/7 mở form rồi đóng không lưu | PASS cho mở form; chưa lưu bản mới/duplicate qua toàn bộ workflow |
| Create / Copy trên catalog list | 9/9 list đã mở; command smoke PASS | Chưa validate toàn bộ catalog fields |
| Save trên form smoke | 2 command enabled đã gọi; 5 command disabled được xác nhận | Partial theo trạng thái fixture; không phải mọi state/role |
| Save rỗng | 7/7 form từ chối lưu, không cấp số, hiện validation | PASS cho blank scenario; không thử từng required field qua UI riêng lẻ |
| Post / Undo trên native UI | 2/2 document: cấn trừ và đối soát | PASS; backend lifecycle regression bao phủ luồng khác |
| Print preview | 5/7 có command và mở preview; 2/7 không có command | Partial; preview mở được nhưng nội dung phần lớn chưa thành bản in nghiệp vụ hoàn chỉnh |
| Custom command coverage | 6 definitions / 6 toolbar bindings; 8 runtime cases | 8/8 PASS: related-document 4/4, bank send 2/2, refund confirmation 2/2 |
| Related-document command | 4/4 được gọi; notification và expected chain khớp | PASS cho notification/chain; chưa xác nhận mở form đích |
| Bank send / refund confirmation | Accepted + HTTP_REJECTED; 2 refund confirmation là REFUND_RECEIVED | 4/4 command behavior cases PASS; duplicate idempotency PASS |
| Period filter | 5 list | 5/5 PASS |
| Partner → contract choice | 5 form | 5/5 PASS |
| Role matrix | 5 role × 10 assertion | 50/50 PASS; chưa chạy toàn bộ tổ hợp role × command |

## Fields và validation

| Nhóm kiểm tra | Case | Kết quả | Giới hạn |
|---|---:|---|---|
| Required `Write()` validation | 41 trường trên 7 Document | 41/41 bị từ chối khi rỗng; probe rollback sạch | BSL/object write, không phải từng field trên UI |
| System autofill/calculation | 7 trường | 7/7 giá trị mong đợi | Các field được liệt kê trong runtime matrix |
| Field write/readback | 66 trường còn lại | 66/66 ghi, đọc lại bằng giá trị đã lưu, rồi rollback | Mỗi trường có probe giá trị hợp lệ; chưa fuzz toàn bộ giá trị sai/độ dài/biên |
| Metadata classification | 114 thuộc tính, 48 `FillChecking=ShowError` | 0 thuộc tính chưa phân loại | Binding vào form không đồng nghĩa field đã được fuzz trên UI |
| AR boundary | 7 | Ngày hóa đơn tương lai, MST sai ký tự/độ dài và MST hợp lệ | Không bao gồm mọi dạng date/string của tất cả field |
| AP boundary | 8 | VAT, tổng, FX tolerance, FCT; 8/8 PASS | Giá trị biên theo business rules hiện có |
| UNC VND ngoại tệ | 1 case âm trong field probe | Giá trị 1 bị `BeforeWrite` từ chối; không persisted; rollback PASS | Chỉ scenario VND cụ thể |
| Required field UI | 7 form | 7/7 blank Save bị từ chối | Không tách từng field thành thao tác UI riêng |
| Reference choice | 5 form | Đối tác → hợp đồng đúng chủ sở hữu | Chưa bao phủ mọi reference type |

### 41 trường bắt buộc

| Document | Trường |
|---|---|
| BBNT | `PhapNhan`, `DoiTac`, `HopDong`, `GiaTriNghiemThuChuaVAT` |
| Hóa đơn AR | `PhapNhan`, `DoiTac`, `HopDong`, `SoHoaDon`, `KyHieu`, `NgayHoaDon` |
| Phiếu thu | `PhapNhan`, `DoiTac`, `HopDong`, `TaiKhoanTien`, `KhoanMucDongTien`, `SoTien` |
| Hóa đơn AP | `PhapNhan`, `DoiTac`, `HopDong`, `SoHoaDon` |
| UNC | `PhapNhan`, `DoiTac`, `HopDong`, `TaiKhoanTien`, `KhoanMucDongTien`, `TienTe`, `SoTien` |
| Cấn trừ | `PhapNhan`, `DoiTac`, `ChungTuAR`, `ChungTuAP`, `SoTien` |
| Đối soát | `PhapNhan`, `DoiTacTrungGian`, `TaiKhoanTien`, `KhoanMucDongTien`, `TienTe`, `KenhThanhToan`, `TongTienGiaoDich`, `TongPhi`, `TongTienThucNhan` |

## Workflow, posting và kiểm soát số liệu

| Luồng | Assertion đã chạy | Kết quả | Còn thiếu |
|---|---|---|---|
| AR: BBNT → hóa đơn → thu | Net 200m + VAT 16m; thu đủ; số dư về 0; over-collection 1 VND bị chặn | PASS | Không có Sales Order metadata |
| Hủy hóa đơn đã thu | Phiếu thu đã post; undo hóa đơn bị từ chối; movement giữ nguyên | PASS | — |
| AP: hóa đơn → duyệt → UNC → ngân hàng → post | Gross 200m; FCT VAT/CIT 10m mỗi loại; payable 180m; Accepted/Rejected | PASS | Không có Purchase Order hoặc Payment Request metadata |
| Netting AR/AP | Cấn trừ đúng số dư; vượt số dư bị chặn; không phát sinh cash movement | PASS | — |
| FX / refund | AR/AP USD, realized FX gain/loss, over-collection, refund idempotency | PASS | Không bao phủ mọi currency/rate/date |
| Đối soát thanh toán | Gross 75m, fee 1.125m, net 73.875m; 7 case âm bị chặn; fee 0 ghi/undo | PASS | Không thay cho mọi tổ hợp fee/currency |
| Maker-Checker | Ngưỡng 500m và 500m+1; escalation KTT/CFO | PASS | Chỉ các ngưỡng/scenario đã cấu hình |
| GL / subledger | Mismatch detection + rollback; posting lifecycle 4/4; AP lifecycle 3/3; state invariant 5/5 | PASS | Assertion theo invariant được liệt kê |
| Concurrency / DataLock | Background holder và posting chờ lock; over-collection bị chặn | PASS cho scenario | Chưa stress test deadlock hoặc contention kéo dài |
| Branch RLS | Submit/approve/post/verify qua branch khác | PASS cho scenario | Chưa vét cạn mọi chi nhánh |
| Dashboard aging | Aging, kỳ và queue assertions | PASS | Không phải Report object riêng |

## Gap còn lại so với yêu cầu strict 100%

| Gap | Tác động |
|---|---|
| Không có Sales Order, Purchase Order, Payment Request | Không thể test đúng chuỗi chứng từ đầu vào của các quy trình AR/AP được yêu cầu |
| Không có Report object riêng | Chỉ xác nhận dashboard aging; không thể test form/report riêng |
| Không có metadata/service khóa kỳ | Không thể thực hiện case sửa chứng từ trong kỳ đã khóa |
| Chỉ 5/7 document có custom form; cấn trừ/đối soát dùng default form | Chưa có tab/control audit theo custom layout cho hai document |
| 5 preview mở được nhưng template/nội dung chưa hoàn chỉnh; 2 document không có Print command | Không thể xác nhận toàn bộ nội dung in |
| 66 field probes kiểm tra một giá trị hợp lệ qua lưu/đọc lại | Chưa fuzz null, ký tự đặc biệt, format sai, min/max và từng business boundary cho mọi field |
| UI command/role coverage không phải toàn bộ Cartesian product | Chưa click tất cả command trên mọi form với mọi role |
| DataLock chỉ có scenario đơn | Chưa chạy stress/deadlock test kéo dài |

**Kết luận:** run `finance-e2e-20261021-122123-4a6c34419ef042a7a875f2a99330486a` xanh 100% trong phạm vi 85 phase và custom command 8/8; coverage strict 100% cho phạm vi nghiệp vụ/metadata được mô tả rộng hơn vẫn là Partial/Gap ở các hàng trên.

## Bằng chứng

- [Full suite summary](summary.json)
- [Runtime field matrix](required_field_runtime_matrix.json)
- [114-field inventory](document-field-inventory.csv), [inventory summary](document-field-inventory.summary.json)
- [Custom command coverage](custom-command-coverage.json) — 6/6 definitions có toolbar binding, 8/8 runtime cases PASS.
- [FormSmoke và 20 tab](ui-document-forms.json)
- [Required-field UI](ui-required-field-validation.json), [choice filter](ui-reference-choice.json), [period list](ui-list-periods.json), [catalog list](ui-catalog-lists.json), [Post/Undo UI](ui-posting-command-actions.json)
- [AR concurrency](ar-concurrency.json), [payment reconciliation](payment_reconciliation.json), [dashboard](dashboard_verify.json), [AR seed](ar-seed-regression.json), [AP seed](ap-seed-regression.json)
