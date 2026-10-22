# Ma trận truy vết coverage QA AR/AP

Run tham chiếu: finance-e2e-20261021-095808-fbcdabea01f6406580873d6e3cf188bb.  
Trạng thái PASS dưới đây chỉ áp dụng cho những kiểm tra đã thực thi. Mục Partial/Gap chưa được tính là xanh.

## Màn hình và form

| Phạm vi | Bằng chứng đã chạy | Trạng thái | Phần còn thiếu |
|---|---|---|---|
| Danh sách chứng từ | 7/7 list mở; Create và Copy mở form rồi đóng không lưu | PASS cho mở form | Chưa kiểm tra mọi command của list trên mọi role |
| Form chứng từ và Data Processor | 7/7 form chứng từ + 2/2 form Data Processor mở; field/control inventory được lưu | PASS cho mở form | Không chứng minh mọi field/command hoạt động |
| Danh sách Catalog | 9/9 list mở; Create/Copy 9/9 | PASS cho mở và khởi tạo form | Chưa kiểm tra nội dung/validation của mọi field Catalog |
| Choice/reference | 5/5 bộ lọc Đối tác → Hợp đồng | Partial | Không phải toàn bộ choice form/reference trong metadata |
| RLS và role | 5 role × 10 assertion = 50/50 | PASS cho assertion hiện có | Không chạy mọi command UI của mọi role |

## Nút và command

| Command | Bằng chứng | Trạng thái | Phần còn thiếu |
|---|---|---|---|
| Save rỗng | 7/7 form từ chối, không lưu hoặc cấp số | PASS | Chỉ một ca rỗng cho mỗi chứng từ |
| Save form đã ghi sổ | 2 command enabled được gọi; 5 command disabled được xác nhận | PASS theo trạng thái của dữ liệu mẫu | Không phủ Save trên mọi trạng thái/role |
| Post / Undo | Native UI chạy Undo → Post trên Cấn trừ và Đối soát: 2/2 | Partial | Native UI chưa chạy trên 5 chứng từ còn lại; backend posting lifecycle đã chạy riêng |
| Tạo mới / Sao chép | 7/7 list chứng từ và 9/9 list Catalog | PASS cho việc mở form | Chưa lưu bản sao/tạo mới qua toàn bộ nghiệp vụ |
| Chứng từ liên quan | 4/4 command hiện thông báo chuỗi chứng từ mong đợi | Partial | Command chỉ hiện thông báo; chưa mở hoặc điều hướng tới chứng từ liên kết |
| Print preview | 5/5 command mở preview và quay về form; 2 chứng từ không có command | Partial | Không có template in riêng cho chứng từ; kiểm tra nội dung chưa đạt |
| Gửi ngân hàng / xác nhận hoàn tiền | UI ACCEPTED, HTTP_REJECTED, RefundReceived và duplicate idempotency được kiểm tra | PASS cho các kịch bản đã chạy | Không phủ mọi trạng thái ngân hàng/role |
| Các command UI còn lại | Inventory có trong ui-document-forms.json | Gap | Chưa bấm toàn bộ command chuẩn/custom trên mỗi form và mỗi role |

### Kiểm tra nội dung preview

Ảnh [preview AR](finance-print-preview-E2E-AR001.png) và [preview AP](finance-print-preview-E2E-AP001.png) cho thấy preview mở và hiện số chứng từ, ngày, trạng thái, tổng tiền ở dải đầu trang; phần nội dung còn lại gần như trống. Metadata không có document template/MXL riêng. Vì vậy kết quả 5/5 chỉ chứng minh lệnh mở được, chưa chứng minh có bản in nghiệp vụ hoàn chỉnh.

JSON ghi document_number_visible=false cho cả 5 preview. Trên ảnh AR/AP đã xem, số chứng từ vẫn hiện rõ; assertion UI Automation hiện là false-negative và không được dùng làm bằng chứng nội dung. Cần sửa assertion để đọc được nội dung preview hoặc phân loại kết quả theo xác minh ảnh.

## Field và validation

| Nhóm | Bằng chứng | Trạng thái | Phần còn thiếu |
|---|---|---|---|
| Required field object-level | 41/41 field bị bỏ riêng lẻ làm Write từ chối và rollback sạch | PASS | Không phải fuzz tất cả kiểu dữ liệu |
| Required field UI | 7/7 blank Save bị chặn | PASS | Chưa thử từng field qua UI; runtime matrix làm riêng ở object level |
| Auto-fill | 7/7 giá trị hệ thống được kiểm tra | PASS | Chỉ các field được liệt kê trong runtime matrix |
| AR boundary | 7/7 ngày hóa đơn/MST | PASS | Chưa kiểm tra mọi giới hạn chuỗi/kiểu dữ liệu của tất cả field |
| AP boundary | 8/8 VAT/FX/FCT; probe rollback | PASS | VAT âm được metadata AllowedSign=Nonnegative chuẩn hóa về 0; đây không phải từ chối BSL |
| Reconciliation | 7/7 nhánh âm từ chối, không lưu/movement; phí 0 ghi sổ rồi Undo sạch | PASS | Không thay thế fuzz tổng quát toàn bộ field |
| Null, chuỗi đặc biệt, sai định dạng, ngày không hợp lệ | Có một số ca required/date/MST | Partial | Chưa chạy ma trận này trên từng field có nhập liệu |

## Luồng nghiệp vụ và hệ thống

| Yêu cầu | Bằng chứng | Trạng thái |
|---|---|---|
| AR từ BBNT → hóa đơn → thu tiền | Các phase AR/backend/register trong summary PASS | PASS cho cấu hình hiện tại |
| AP hóa đơn → duyệt → UNC/ngân hàng | Các phase AP/backend/bank trong summary PASS | PASS cho cấu hình hiện tại |
| FX, hoàn tiền, cấn trừ, đối soát | Runtime E2E và register assertions hiện có PASS | PASS cho kịch bản đã chạy |
| Cân đối GL/subledger, trạng thái posting | Integrity/state invariants hiện có PASS | PASS cho assertion hiện có |
| DataLock | Một contention AR có holder nền | Partial; chưa stress deadlock |
| Sales Order, Purchase Order, Payment Request | Không có object tương ứng trong metadata | Gap, không thể test |
| Báo cáo aging AR/AP | Không có object Reports; dashboard là Data Processor | Gap, không thể test report riêng |
| Khóa kỳ kế toán | Không có metadata/service khóa kỳ | Gap, không thể test sửa chứng từ trong kỳ khóa |
| In chứng từ hoàn chỉnh | Không có print template riêng; preview chỉ được kiểm tra mở | Gap |

## Bằng chứng runtime

- [summary.json](summary.json) — 85/85 pha runner PASS.
- [ui-document-forms.json](ui-document-forms.json) — màn hình, field inventory, lệnh list/form, preview.
- [ui-required-field-validation.json](ui-required-field-validation.json) — blank Save 7/7.
- [required_field_runtime_matrix.json](required_field_runtime_matrix.json) — 41 required, 7 auto-fill, 7 AR boundary, 8 AP boundary.
- [ui-reference-choice.json](ui-reference-choice.json) — 5 bộ lọc tham chiếu.
- [ui-posting-command-actions.json](ui-posting-command-actions.json) — native Post/Undo 2 chứng từ.

Kết luận: 85/85 pha chạy hiện có đều PASS. Coverage strict 100% chưa đạt; mọi dòng Partial/Gap cần được đóng bằng triển khai hoặc test bổ sung trước khi đưa ra kết luận đó.