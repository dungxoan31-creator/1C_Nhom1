---
name: onec-core-developer
description: Use when developing applications on 1C:Enterprise, writing 1C BSL code (&AtServer, &AtClient, queries, registers, posting), designing data models (Catalogs, Documents, Accumulation/Information Registers), building business subsystems (Sales, Purchases, Warehouse, Cash flow, AR/AP, Bank), using DCS reports, SSL/BSP, or extending solutions via Configuration Extensions (CFE).
---

# 1C:Enterprise Core Developer & Solution Architect

Chuyên gia phát triển ứng dụng và kiến trúc giải pháp chuyên sâu trên nền tảng **1C:Enterprise 8.3**. Hỗ trợ xây dựng các hệ thống ERP, quản trị tài chính, kho, bán hàng, mua hàng, kế toán, tích hợp và tối ưu hóa giải pháp doanh nghiệp.

---

## 1. Bản đồ Tri thức & Tài liệu tham chiếu (`references/`)

### 1.1. Giáo trình 24 bài phát triển 1C nền tảng (`references/lessons/`)

| Chủ đề | File tham chiếu |
|---|---|
| Khái niệm nền tảng, Metadata, Kiến trúc 3 tầng, Primitive types, Catalog, Enumeration, Document | [bai-01-04.md](references/lessons/bai-01-04.md) |
| Cú pháp ngôn ngữ 1C (BSL), Procedures, Functions, Biến, Toán tử, Vòng lặp, Collections (Array, Structure, Map, ValueTable...) | [bai-05-06.md](references/lessons/bai-05-06.md) |
| Tương tác Client-Server: Directives (`&AtClient`, `&AtServer`, `&AtServerNoContext`), Context vs Non-context call | [bai-07.md](references/lessons/bai-07.md) |
| Gỡ lỗi & Đo lường hiệu năng: Breakpoint, Evaluate, Call stack, Performance meter | [bai-08.md](references/lessons/bai-08.md) |
| Giao diện người dùng: Subsystems, Panels, Forms (Attributes, Items, Groups, Commands, Conditional appearance) | [bai-09.md](references/lessons/bai-09.md) |
| Ngôn ngữ truy vấn (1C Query): SELECT, JOINs, UNION, TOTALS, Bảng ảo, Bảng tạm (Temp table), Batch query | [bai-10.md](references/lessons/bai-10.md) |
| Sổ tích lũy (Accumulation register): Balances/Turnovers, Ghi sổ chứng từ (Posting), PointInTime, Boundary, Khóa ghi | [bai-11.md](references/lessons/bai-11.md) |
| Kiểm tra dữ liệu (FillCheckProcessing), Sổ thông tin (Information register - periodic, SliceLast), Transactions | [bai-12.md](references/lessons/bai-12.md) |
| Hằng số (Constants), Nhật ký chứng từ (Document journals), Kế hoạch loại đặc tính (Charts of characteristic types) | [bai-13.md](references/lessons/bai-13.md) |
| Common modules (Global, Privileged, Reuse values), Module ứng dụng/phiên, Commands | [bai-14.md](references/lessons/bai-14.md) |
| Tùy chọn chức năng (Functional options), Toàn vẹn tham chiếu, Đánh dấu xóa và xóa đối tượng | [bai-15.md](references/lessons/bai-15.md) |
| Thứ tự sự kiện ghi/post chứng từ, Sự kiện form, Đăng ký sự kiện (Event subscriptions) | [bai-16.md](references/lessons/bai-16.md) |
| Mẫu in (Print forms), Spreadsheet template (MXL), Báo cáo điền bảng | [bai-17.md](references/lessons/bai-17.md) |
| Báo cáo trên Hệ thống bố cục dữ liệu (Data Composition System - DCS / SKD) | [bai-18.md](references/lessons/bai-18.md) |
| Xử lý dữ liệu (Data processors), External EPF, Nhập xuất Excel, Thao tác file Client-Server | [bai-19.md](references/lessons/bai-19.md) |
| Phân quyền & Bảo mật: Roles, Access rights, Privileged mode, Authentication | [bai-20.md](references/lessons/bai-20.md) |
| Thư viện hệ thống con chuẩn (SSL/BSP): Kiến trúc tổng quan, Core, Additional reports and data processors | [bai-21.md](references/lessons/bai-21.md) |
| SSL/BSP: Phân hệ In ấn (Print subsystem) | [bai-22.md](references/lessons/bai-22.md) |
| SSL/BSP: Quản lý file đính kèm, Cấu trúc Regions của Module | [bai-23.md](references/lessons/bai-23.md) |
| Sổ kế toán: Hệ thống tài khoản (Chart of accounts), Đối tượng kế toán (Accounting register), Bảng cân đối thử | [bai-24.md](references/lessons/bai-24.md) |
| Mở rộng cấu hình (Configuration Extensions - CFE): Purpose, &Before, &After, &Around, &ChangeAndValidate, Adopted objects | [bai-extensions.md](references/lessons/bai-extensions.md) |

---

### 1.2. Kiến trúc giải pháp & Thiết kế ERP (`references/architecture/`)

- [tu-xay-dung-he-thong.md](references/architecture/tu-xay-dung-he-thong.md): Hướng dẫn thiết kế trọn gói 4 phân hệ Mua hàng - Kho - Bán hàng - Quỹ/Ngân hàng từ **cấu hình rỗng** (mô hình dữ liệu, ma trận posting, quan hệ đối ứng, kiểm soát công nợ AR/AP).
- [erp-practice.md](references/architecture/erp-practice.md): Kiến trúc ứng dụng mẫu hoàn chỉnh `ERP_Practice` (Jack of All Trades) xây dựng theo sách phát triển thực hành 1C.
- [case-doanh-nghiep.md](references/architecture/case-doanh-nghiep.md): Tuyển tập bài toán nghiệp vụ theo ngành (May mặc, Bao bì, Dược, Cơ khí, Bán lẻ, Bảo trì...).
- [khung-khao-sat.md](references/architecture/khung-khao-sat.md): Khung khảo sát doanh nghiệp chuẩn "7 + 2", ma trận phân tích Fit-Gap.

---

### 1.3. Cấu hình mở 1C:Jet (`references/jet-erp/`)

Tham khảo giải pháp mã nguồn mở 1C:Jet (xây trên nền SSL/BSP):
- [jet-overview.md](references/jet-erp/jet-overview.md): Cài đặt, kiến trúc tổng quan, cơ chế posting qua `PostingManagement`.
- [jet-warehouse.md](references/jet-erp/jet-warehouse.md): Phân hệ Quản lý Kho, hạch toán tồn kho và giá vốn.
- [jet-purchases.md](references/jet-erp/jet-purchases.md): Phân hệ Mua hàng, công nợ nhà cung cấp (AP), tạm ứng.
- [jet-sales.md](references/jet-erp/jet-sales.md): Phân hệ Bán hàng, bảng giá, công nợ khách hàng (AR), lợi nhuận gộp.
- [jet-cash.md](references/jet-erp/jet-cash.md): Phân hệ Quản lý Tiền mặt & Ngân hàng, dòng tiền và số dư quỹ.
- [jet-extending.md](references/jet-erp/jet-extending.md): Kỹ thuật mở rộng thêm đối tượng mới vào cấu hình có sẵn SSL/Jet.

---

### 1.4. Quy chuẩn kỹ thuật & Thuật ngữ (`references/standards/`)

- [code-patterns.md](references/standards/code-patterns.md): Các mẫu code chuẩn cho Posting có kiểm tra tồn, Form Client-Server tối ưu, FillCheckProcessing, Khóa ghi dữ liệu `DataLock`.
- [terminology.md](references/standards/terminology.md): Bảng thuật ngữ 1C chuẩn Anh - Việt, các nguyên tắc thiết kế bất di bất dịch (không nói "kế thừa", posting chỉ có ở Document, không sửa object qua Ref...).
- [chinh-sach-code.md](references/standards/chinh-sach-code.md): Quy định phân loại yêu cầu và cung cấp giải pháp code hoàn chỉnh.
- [practice-index.md](references/standards/practice-index.md): Danh mục các bài tập thực hành.

---

### 1.5. Phân tích nghiệp vụ, Đề tài & Tài nguyên khác
- **Phân tích nghiệp vụ**: [quy-trinh-phan-tich.md](references/business-analysis/quy-trinh-phan-tich.md), [mau-phan-tich.md](references/business-analysis/mau-phan-tich.md), [vi-du-phan-tich.md](references/business-analysis/vi-du-phan-tich.md).
- **Đề tài & Ý tưởng**: [ngan-hang-y-tuong.md](references/projects-and-cases/ngan-hang-y-tuong.md), [de-bai-btl.md](references/projects-and-cases/de-bai-btl.md), [de-tai-1-5.md](references/projects-and-cases/de-tai-1-5.md), [de-tai-6-9.md](references/projects-and-cases/de-tai-6-9.md).
- **Tài nguyên cài đặt & Media**: [tai-nguyen.md](references/resources/tai-nguyen.md), [lien-ket-bai-giang.md](references/resources/lien-ket-bai-giang.md), [video-qa-thuc-chien.md](references/resources/video-qa-thuc-chien.md), [video-thuc-hanh.md](references/resources/video-thuc-hanh.md), [video-junior-course.md](references/resources/video-junior-course.md).
- **Bản quyền**: [NOTICE.md](references/legal/NOTICE.md), [LICENSE-Jet-MIT.txt](references/legal/LICENSE-Jet-MIT.txt).

---

## 2. Nguyên tắc Bắt buộc Khi Viết Code 1C

1. **Ngôn ngữ cú pháp BSL**: Sử dụng **cú pháp tiếng Anh** (`Procedure`, `Function`, `EndProcedure`, `If ... Then ... EndIf`, `Query.Execute()`). Comment giải thích có thể viết bằng tiếng Việt.
2. **Compilation Directives trong Form Module**:
   - `&AtClient`: Chỉ xử lý giao diện thuần túy, tính toán số học đơn giản (thành tiền = đơn giá × số lượng), mở form.
   - `&AtServerNoContext`: Dùng khi truy vấn dữ liệu từ DB mà không cần đọc/ghi trạng thái Form (tiết kiệm băng thông tối đa).
   - `&AtServer`: Chỉ dùng khi bắt buộc phải can thiệp trực tiếp vào thuộc tính Form.
3. **Cơ chế Ghi sổ (Posting)**:
   - Chỉ viết trong `ObjectModule` của Document, handler `Posting(Cancel, PostingMode)`.
   - Luôn bật `RegisterRecords.<TênSổ>.Write = True` trước khi gán dữ liệu.
   - Kiểm tra số dư theo nguyên tắc "Ghi trước, Kiểm tra sau" hoặc thiết lập khóa `DataLock` tường minh.
4. **Tối ưu hóa Truy vấn**:
   - Không chạy Query trong vòng lặp `For...Each`.
   - Luôn truyền tham số lọc vào Virtual Table (`.Balance(&PointInTime, ...)`), không lọc ở `WHERE` của bảng ảo.
5. **Đưa mã nguồn hoàn chỉnh**: Mỗi đoạn code cung cấp phải ghi rõ:
   - **Vị trí đặt**: Object nào → Module nào → Event handler nào → Compilation directive nào.
   - **Code BSL**: Đặt trong khối ```bsl.
   - **Giải thích & Cách kiểm tra**: Các bước nhập liệu thử nghiệm và kết quả đối chiếu trên sổ/báo cáo.
