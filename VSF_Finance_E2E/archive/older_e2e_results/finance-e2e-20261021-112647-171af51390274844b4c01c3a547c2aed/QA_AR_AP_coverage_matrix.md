# Ma trận coverage AR/AP — run 20261021-112647

Trạng thái dùng trong bảng: **PASS** = assertion đã chạy và đạt; **Partial** = chỉ một phần tổ hợp được chạy; **Gap** = không có metadata hoặc chưa có test thực thi. Tất cả dữ liệu runtime lấy từ clone E2E, không phải BaseInfobase gốc.

## Metadata khảo sát

| Nhóm | Inventory | Coverage |
|---|---|---|
| Catalogs | ChiNhanh, DichVuCNTT, DoiTac, DuAn, HopDong, KhoanMucDongTien, PhapNhan, TaiKhoanTien, TienTe | 9/9 list mở; Create/Copy mở form — PASS |
| Documents | BBNT, hóa đơn AR, phiếu thu, hóa đơn AP, UNC, cấn trừ, đối soát | 7/7 list và form mở — PASS |
| Accumulation registers | CongNoPhaiThu, CongNoPhaiTra, DongTien | E2E movement/balance kiểm tra trong AR/AP/cash — PASS cho assertion hiện có |
| Accounting register | SoCaiKeToan | GL balance, debit/credit và mismatch rollback — PASS cho assertion hiện có |
| Information registers | PhanQuyenChiNhanh, TyGiaHoiDoai | Branch RLS và FX — PASS cho case hiện có |
| Data Processor | BanLamViecWebERP; dashboard, batch Maker-Checker | 2/2 form mở; dashboard aging/period/queue assertions — PASS |
| Common modules | 12 | Luồng AR/AP, quyền, posting, thuế, ngân hàng, seed và boundary được rà theo test liên quan |
| Document attributes | 114 | 48/48 `FillChecking=ShowError` được đối chiếu với 41 required-write test + 7 system-managed test; inventory xuất CSV |
| Roles | Admin, AR, AP, Kế toán trưởng, CFO | 50/50 assertion — PASS; mọi tổ hợp role × command chưa chạy |
| Reports | Không có object Report | Aging kiểm tra trên dashboard, không phải report riêng; report object — Gap |

## Màn hình / form

| Màn hình | Bằng chứng | Trạng thái | Còn thiếu |
|---|---|---|---|
| 7 document lists | Open, Create, Copy; list filter kỳ trên 5 list | PASS theo hành vi đã assert | Không kiểm kê từng command trên mọi role |
| BBNT form | Mở form; 4/4 tab được chọn; field counts 11/1/1/3 | PASS | Không fuzz từng control |
| AR invoice form | Mở form; 4/4 tab; 11/2/2/1 | PASS | Không test mọi trạng thái UI |
| Receipt form | Mở form; 4/4 tab; 8/1/1/1 | PASS | Form hiện không có control `ChungTuGoc` như cấu hình/flow liên quan kỳ vọng — cần review UI |
| AP invoice form | Mở form; 4/4 tab; 9/2/1/1 | PASS | Cờ FCT chưa hiện trên form; cần review UI |
| UNC form | Mở form; 4/4 tab; 8/1/4/1 | PASS | `ChungTuGoc` và field FX không được expose hết trên custom form — cần review UI |
| Netting form | Mở form mặc định | PASS cho mở form | Không có custom FormChungTu/tab audit |
| Reconciliation form | Mở form mặc định | PASS cho mở form | Không có custom FormChungTu/tab audit |
| 2 Data Processor forms | Dashboard và batch approval mở | PASS | Chưa bao phủ hết control/command |
| 9 catalog lists | Mở list, Create/Copy mở form | PASS | Chưa validation toàn bộ Catalog fields |

Contract tab runtime kiểm soát control theo loại Edit/ComboBox/CheckBox/RadioButton/DataGrid, tên không rỗng và bounds nằm dưới tab strip. Tổng cộng **20/20 tab trên 5 custom document forms** khớp số InputField/CheckBoxField/RadioButtonField/Table trong metadata. Không có tab tùy chỉnh cho 2 Document còn lại.

| Custom form | Thuộc tính metadata có binding control |
|---|---:|
| BBNT | 13/14 |
| AR invoice | 10/22 |
| Receipt | 7/14 |
| AP invoice | 9/23 |
| UNC | 11/21 |

Không có binding không đồng nghĩa mọi thuộc tính đều thiếu do một số thuộc tính do hệ thống quản lý. Tuy nhiên `ChungTuGoc` ở receipt/UNC và các thuộc tính FCT/FX của AP cần được xác nhận về tính chủ ý; hiện chúng không được kiểm tra qua field-level UI.

## Command / nút

| Command | Kết quả | Trạng thái | Phần còn thiếu |
|---|---|---|---|
| Create / Copy | 7/7 Document list; 9/9 Catalog list mở form và đóng không lưu | PASS cho mở form | Chưa lưu bản tạo/sao chép qua mọi workflow |
| Save enabled | 2/7 được gọi, form vẫn mở | PASS theo trạng thái fixture | Không phủ mọi trạng thái hoặc role |
| Save disabled | 5/7 được xác nhận disabled | PASS theo trạng thái fixture | Không phủ mọi trạng thái hoặc role |
| Save rỗng | 7/7 form từ chối, không lưu/cấp số, có validation | PASS | Mỗi form thử blank scenario, không bỏ riêng từng trường qua UI |
| Post / Undo | Native UI Undo → Post 2/2 (netting, reconciliation) | Partial | 5 Document còn lại chỉ có backend lifecycle, không có native UI click trong run này |
| Print preview | 5/7 mở và quay lại; 2/7 không có command | Partial | Nội dung preview chưa đủ; không có template riêng; không gửi máy in vật lý |
| Chứng từ liên quan | 4/4 đúng chuỗi hiển thị | Partial | Chỉ hiện thông báo chuỗi, chưa điều hướng tới chứng từ đích |
| BankSend / RefundConfirm | Accepted, rejected, refund received, duplicate idempotency | PASS cho các scenario | Không phủ mọi bank response/state |
| Các nút khác | Inventory từ UIA trong FormSmoke | Gap | Chưa invoke mọi chuẩn/custom command trên mọi form/role |

## Field / validation

| Kiểm tra | Cases | Trạng thái | Giới hạn |
|---|---:|---|---|
| Required-field BSL Write | 41 trường trên 7 Document | PASS | Chưa fuzz mọi kiểu dữ liệu của mọi field |
| Autofill | 7 | PASS | Chỉ các giá trị trong matrix |
| Metadata-wide classification | 114 thuộc tính; 48/48 bắt buộc được phân loại | PASS cho inventory/contract | 65 thuộc tính chưa có runtime field-level case riêng; một số được chạm trong happy path |
| Required-field blank Save UI | 7 form | PASS | Không bỏ từng field một trong UI |
| AR boundary: ngày/MST | 7 | PASS | Không phủ mọi string/date edge cho tất cả field |
| AP boundary: VAT/FX/FCT | 8 | PASS | VAT âm bị metadata AllowedSign chuẩn hóa về 0; không tính là BSL rejection |
| Đối soát âm / phí 0 | 7 negative + 0-fee | PASS | Không thay cho fuzz tất cả tổ hợp đối soát |
| Null, ký tự đặc biệt, sai kiểu, max length | Một số ca MST/date/empty | Partial | Chưa chạy matrix trên từng input control |
| Ràng buộc Partner → Contract | 5 Document forms | PASS | Chưa phủ toàn bộ reference type trong metadata |

41 required fields đã thử:

| Document | Trường |
|---|---|
| BBNT | `PhapNhan`, `DoiTac`, `HopDong`, `GiaTriNghiemThuChuaVAT` |
| ARInvoice | `PhapNhan`, `DoiTac`, `HopDong`, `SoHoaDon`, `KyHieu`, `NgayHoaDon` |
| Receipt | `PhapNhan`, `DoiTac`, `HopDong`, `TaiKhoanTien`, `KhoanMucDongTien`, `SoTien` |
| APInvoice | `PhapNhan`, `DoiTac`, `HopDong`, `SoHoaDon` |
| Payment | `PhapNhan`, `DoiTac`, `HopDong`, `TaiKhoanTien`, `KhoanMucDongTien`, `TienTe`, `SoTien` |
| Netting | `PhapNhan`, `DoiTac`, `ChungTuAR`, `ChungTuAP`, `SoTien` |
| Reconciliation | `PhapNhan`, `DoiTacTrungGian`, `TaiKhoanTien`, `KhoanMucDongTien`, `TienTe`, `KenhThanhToan`, `TongTienGiaoDich`, `TongPhi`, `TongTienThucNhan` |

## Workflow / posting

| Luồng | Assertion runtime | Trạng thái | Gap |
|---|---|---|---|
| AR BBNT → invoice → receipt | Net 200m + VAT 16m; thu đủ; dư nợ 0; over-receipt 1 VND bị chặn | PASS | Không có Sales Order metadata |
| Không hủy hóa đơn đã thu | Receipt đã posted; invoice unpost bị từ chối; movement giữ nguyên | PASS | — |
| AP invoice → approval → payment → bank | Gross 200m, FCT VAT/CIT 10m mỗi khoản, payable 180m | PASS | Không có Purchase Order/Payment Request metadata |
| Netting AR/AP | Số dư giảm đúng, over-balance bị chặn, không sinh cash movement | PASS | — |
| FX / refund | AR/AP USD, realized FX, over-collection và refund duplicate idempotency | PASS | — |
| Reconciliation | Gross 75m, fee 1.125m, net 73.875m; 7 negative case bị chặn; fee 0 Undo sạch | PASS | — |
| Maker-Checker | Ngưỡng 500m và 500m+1; KTT/CFO escalation | PASS | — |
| GL/subledger | Mismatch detection, rollback, 4/4 posting lifecycle, 3/3 AP lifecycle, 5/5 invariants | PASS | Chỉ các invariant được liệt kê |
| DataLock | Holder nền và posting chờ lock; over-collection bị từ chối | PASS cho scenario | Chưa stress test deadlock/thời lượng dài |
| Branch RLS | Quyền chi nhánh qua luồng submit/approve/post/verify | PASS | Chưa vét cạn mọi chi nhánh |
| Kỳ khóa | Không có metadata/service khóa kỳ | Gap | Không thể chạy case sửa trong kỳ khóa |
| Báo cáo AR/AP riêng | 0 Reports; dashboard aging được kiểm tra | Gap cho Report object | Cần bổ sung object/report nếu nghiệp vụ yêu cầu |

## Bằng chứng

- [Full suite summary](summary.json) — 85/85 phase PASS.
- [FormSmoke runtime](ui-document-forms.json) — 16 màn hình và tab/control audit.
- [Runtime tab contract](../../scripts/test_form_tab_runtime_contract.ps1).
- [Required-field matrix](required_field_runtime_matrix.json), [blank Save UI](ui-required-field-validation.json), [reference choice](ui-reference-choice.json).
- [Inventory 114 thuộc tính](document-field-inventory.csv), [inventory summary](document-field-inventory.summary.json).
- [Exporter field inventory](../../scripts/export_finance_field_inventory.ps1).
- [Catalog list UI](ui-catalog-lists.json), [period filter](ui-list-periods.json), [Post/Undo UI](ui-posting-command-actions.json).
- [AR concurrency](ar-concurrency.json), [reconciliation](payment_reconciliation.json), [dashboard](dashboard_verify.json).
- [Print preview AR](finance-print-preview-E2E-AR001.png), [print preview AP](finance-print-preview-E2E-AP001.png).

**Overall:** test hiện có xanh 100%; coverage strict của yêu cầu rộng hơn vẫn là Partial/Gap ở các dòng đã ghi rõ.
