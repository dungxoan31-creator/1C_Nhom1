---
name: onec-code-quality
description: Use when reviewing 1C:Enterprise BSL code, auditing code against official 1C standards (#stdNNN), detecting antipatterns (query in loop, commit in loop, missing lock, modal call in client), translating Russian-English BSL syntax, or systematically debugging 1C runtime errors.
---

# 1C Code Quality, Antipattern Detection & Systematic Debugging

Bộ quy chuẩn kiểm thử chất lượng mã nguồn, phát hiện phản mẫu (antipatterns), đối chiếu tiêu chuẩn phát triển chính thức của 1C (#stdNNN) và quy trình gỡ lỗi hệ thống.

## 1. Bản đồ tài liệu tham chiếu (`references/`)

| Tài liệu | Nội dung chính | Khi nào đọc |
|---|---|---|
| [review-rules.md](references/review-rules.md) | Bộ quy tắc thực chiến phân loại theo mã: **P** (Posting), **Q** (Query), **F** (Forms), **V** (Validation), **T** (Transactions), **X** (Excel/Files), **E** (Extensions), **M** (Modules). | Khi người dùng gửi code nhờ review, tối ưu hóa hoặc kiểm tra logic nghiệp vụ. |
| [development-standards.md](references/development-standards.md) | ~50 tiêu chuẩn phát triển chính thức cốt lõi của 1C (#stdNNN) rút gọn từ v8std. | Khi cần dẫn chứng căn cứ tiêu chuẩn kỹ thuật của hãng khi review. |
| [debug-protocol.md](references/debug-protocol.md) | Giao thức 7 bước xử lý sự cố + Từ điển đối chiếu thông báo lỗi Tiếng Anh ↔ Tiếng Nga. | Khi có lỗi runtime, mã lỗi ngoại lệ, hoặc hành vi không mong muốn. |
| [ru-en-dictionary.md](references/ru-en-dictionary.md) | Bảng tra cứu đối chiếu từ khóa BSL, phương thức, hàm toán tử, loại metadata giữa Tiếng Nga và Tiếng Anh. | Khi đọc mã nguồn thư viện cộng đồng (tiếng Nga) hoặc chuyển ngữ mã. |
| [ssl-api-english.md](references/ssl-api-english.md) | Danh mục chữ ký hàm và API tiếng Anh của Standard Subsystems Library (SSL 3.1.x). | Khi gọi các module dùng chung của SSL (`CommonClientServer`, `PrintManagement`...). |
| [known-traps.md](references/known-traps.md) | Danh mục lỗi tiềm ẩn trong các template và code mẫu thông dụng. | Khi kiểm tra các đoạn code tham khảo từ tài liệu hoặc khóa học. |
| [external-tools.md](references/external-tools.md) | Khảo sát các công cụ phân tích tĩnh (BSL Language Server, SonarQube, OneScript). | Khi người dùng cần thiết lập môi trường CI/CD hoặc linter bên ngoài. |
| [rules-yaml/](references/rules-yaml/) | Định nghĩa máy đọc (YAML) cho từng Antipattern và Standard. | Dành cho công cụ linter hoặc kiểm tra tự động. |

---

## 2. Quy trình Review Code (5 bước chuẩn)

1. **Kiểm tra nghiệp vụ & tính đúng đắn dữ liệu**: Dấu và `RecordType` của Register (`AddExpense`, `AddReceipt`), biên thời điểm `PointInTime` khi phân bổ FIFO/bình quân, khóa ghi `LockForUpdate` hoặc `DataLock`.
2. **Kiểm tra ngữ cảnh thực thi (Client/Server)**: Procedure trong form module phải có compilation directive rõ ràng (`&AtClient`, `&AtServer`, `&AtServerNoContext`). Tránh gọi server lặp lại nhiều lần.
3. **Hiệu năng truy vấn & cơ sở dữ liệu**:
   - **Tuyệt đối không chạy Query trong vòng lặp**: Thay bằng gom mảng `IN (&Array)` hoặc bảng tạm (`TempTable`).
   - Lọc dữ liệu trong tham số virtual table (`.Balance(&Date, Filter)`), không lọc ở mệnh đề `WHERE` của virtual table.
4. **An toàn giao dịch & ngoại lệ**: Mỗi `BeginTransaction()` phải có `CommitTransaction()` hoặc `RollbackTransaction()` trên mọi nhánh; khối `Try...Except` phải ghi log `WriteLogEvent` hoặc báo người dùng, không được bắt lỗi im lặng.
5. **Định dạng & Tiêu chuẩn**: Phân vùng `#Region`, đặt tên biến và hàm chuẩn PascalCase theo ngôn ngữ tiếng Anh.

---

## 3. Quy trình Gỡ lỗi (7 bước)

```
1. Thu thập      → Nguyên văn thông báo lỗi (Nga/Anh), dòng phát sinh, thao tác gây lỗi.
2. Dịch & Phân loại → Tra cứu trong references/debug-protocol.md mục 2.
3. Xác định ngữ cảnh → Module nào, directive nào, cờ common module nào.
4. Tái hiện tối thiểu → Bộ dữ liệu nhỏ nhất làm phát sinh lỗi.
5. Sử dụng công cụ → Breakpoint, Evaluate expression, Event log, Query console.
6. Xác định nguyên nhân gốc & Đưa bản sửa.
7. Kiểm tra xác nhận → Chạy lại kịch bản, đối chiếu Register records / Báo cáo.
```

Mẫu phản hồi khi xử lý lỗi:
```
🔎 Lỗi: <nguyên văn thông báo lỗi> → Nghĩa là: <giải thích dễ hiểu>
📍 Vị trí: <Object -> Module -> Procedure/Handler, compilation directive>
🧠 Nguyên nhân gốc: <phân tích logic hoặc ngữ cảnh gây lỗi>
🛠 Cách khắc phục: <đoạn code sửa hoàn chỉnh hoặc hướng dẫn Designer>
✅ Kiểm tra lại: <kịch bản nhập liệu và kết quả mong đợi>
🛡 Phòng ngừa: <thói quen lập trình hoặc cơ chế kiểm soát ngăn tái diễn>
```
