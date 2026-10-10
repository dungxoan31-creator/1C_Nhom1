# Tài liệu gộp: video

Gồm các mục: § video-junior-course, § video-thuc-hanh, § video-qa-thuc-chien


---

# § video-junior-course

# Video bài giảng trên YouTube (playlist "Junior Developer Course") ↔ giáo trình 24 bài

> **Khi nào đọc file này:** khi người học hỏi về một kiến thức có video tương ứng trong playlist cũ, muốn "xem video" thay vì đọc, hỏi "video nào nói về X", hoặc hỏi về một video của khóa cũ ("video bài 23 nói gì", "bài 37 khóa cũ thuộc phần nào"). Dùng để **dẫn người học tới đúng video** và **nối video với bài trong giáo trình 24 bài**.

## Nguồn và độ tin cậy

- Playlist YouTube **"Junior Developer Course - Khóa học lập trình 1C: Enterprise cho Junior Developer"** của kênh 1C Vietnam Academy: 49 video, đăng khoảng 4 năm trước (tính tới 10/2026), playlist: https://www.youtube.com/playlist?list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P
- Bảng ánh xạ gốc của giảng viên: `1C_OLD_Junior_Course_Video_Mapping.xlsx` (project 1C JD Course). Mã video, thứ tự và thời lượng được đọc lại trực tiếp từ playlist ngày 07/10/2026.
- Cột "Phạm vi trong giáo trình" đã được đối chiếu với các file bài của skill; những chỗ bảng gốc ghi lệch đã sửa và ghi ở mục cuối.
- **Mô tả nội dung từng video lấy từ bảng gốc, chưa đối chiếu bằng cách xem video.** Khi trả lời, dùng video như tài liệu xem thêm; kiến thức chính vẫn lấy từ file bài của giáo trình.

## Quy ước khi dẫn video (bắt buộc)

- **Cách nói với người học:** "🎬 Bạn có thể tham khảo thêm về <chủ đề> của khóa tại đây: [<tên video>](<link>)" — ví dụ "🎬 Bạn có thể tham khảo thêm về JOIN của khóa tại đây: [JOIN](https://www.youtube.com/watch?v=Ukd1zPxIJqE&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=43)". Đặt sau dòng "📖 Đọc thêm" (nếu có), tối đa 2 video liên quan nhất.
- **Không** gọi là "khóa cũ", "khóa Junior", "Junior Course"; **không** dùng mã "JC-<số>" và **không** nêu số "Bài N" trong tên video (số đó khác số bài giáo trình). Tên video dùng phần sau "Bài N:" (cột "Tên video" bên dưới, bỏ chữ «»).
- Mã **JC-<số>** (= số "Bài N" trong tên video trên YouTube) chỉ dùng **nội bộ** để tra bảng. Chỉ khi người học tự hỏi theo số video ("video bài 37 học gì") mới trả lời theo đúng cách họ gọi.
- Chỉ dùng link trong bảng dưới (link đã kiểm tra theo mã video thật). Video quay trên phiên bản platform trước — giao diện có thể khác; nếu video và giáo trình nói khác nhau, theo giáo trình và nói rõ.
- Phần đánh dấu **ngoài giáo trình** (ví dụ FormattedDocument, trường HTML) dẫn được cho người học muốn tìm hiểu thêm, nhưng không dùng để trả lời câu hỏi về nội dung kiểm tra của giáo trình.

## Bảng 1 — Từng video → bài trong giáo trình

| # | Video | Thời lượng | Nhóm phạm vi | Phạm vi trong giáo trình (file bài) | Ngoài giáo trình |
|---|---|---|---|---|---|
| 1 | [JC-2 «Hướng dẫn cài đặt nền tảng 1C:Enterprise»](https://www.youtube.com/watch?v=hclmzfC2Lak&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=1) | 3:57 | Cài đặt & tổng quan platform | Bài 1 — Thao tác cơ bản (`bai-01-04.md`) | cài đặt bản Training version, thư mục cài đặt, phím tắt khởi động |
| 2 | [JC-3 «Hello world với 1C:Enterprise»](https://www.youtube.com/watch?v=BBmgzkbdcG8&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=2) | 3:52 | Cài đặt & tổng quan platform | Bài 1 — tạo infobase không có configuration; Bài 5-6 — `Message()` (`bai-01-04.md`, `bai-05-06.md`) | — |
| 3 | [JC-4 «Infobase - Cơ sở thông tin»](https://www.youtube.com/watch?v=Q3j_VFjTakc&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=3) | 9:42 | Cài đặt & tổng quan platform | Bài 1 — Kiến trúc 3 tầng, file infobase (.1CD), Thao tác cơ bản (thêm/xóa khỏi danh sách, Dump/Restore infobase) (`bai-01-04.md`) | — |
| 4 | [JC-5 «Metadata class»](https://www.youtube.com/watch?v=tQQjrh3gBJk&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=4) | 6:19 | Metadata & mô hình đối tượng | Bài 1 — Metadata, Standard applied object prototypes; Bài 2 — metadata class / metadata object / data object (`bai-01-04.md`) | — |
| 5 | [JC-6 «Enumeration và Catalog - Liệt kê và danh mục»](https://www.youtube.com/watch?v=AOKkvDYjsuw&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=5) | 3:42 | Metadata & mô hình đối tượng | Bài 3 — Catalog, Enumeration (attributes, tabular sections) (`bai-01-04.md`) | — |
| 6 | [JC-7 «Chứng từ và biểu ghi tích lũy»](https://www.youtube.com/watch?v=dQt7_Ln8zVI&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=6) | 4:50 | Chứng từ & posting | Bài 3 — Document; Bài 11 — Accumulation register, posting (`bai-01-04.md`, `bai-11.md`) | — |
| 7 | [JC-8 «Giao diện người dùng cơ bản»](https://www.youtube.com/watch?v=rn0hEz5Xc08&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=7) | 5:44 | Giao diện & subsystem | Bài 3 — Subsystem (sơ lược); Bài 9 — Subsystems, Panels, command interface (`bai-01-04.md`, `bai-09.md`) | — |
| 8 | [JC-9 «Homepage, form và command»](https://www.youtube.com/watch?v=DDk5kS4BRow&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=8) | 5:11 | Giao diện & subsystem | Bài 9 — Home page, form; Bài 14 — Commands, Command interface (`bai-09.md`, `bai-14.md`) | — |
| 9 | [JC-10 «Cơ bản về trình chỉnh sửa form»](https://www.youtube.com/watch?v=FqrPnmv_QPA&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=9) | 7:05 | Form | Bài 9 — form attributes, form items, groups, DataPath (`bai-09.md`) | — |
| 10 | [JC-11 «Sự kiện và trình xử lý sự kiện»](https://www.youtube.com/watch?v=FAkymD2Zqks&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=10) | 9:29 | Form & event | Bài 9 — form events; Bài 16 — form & form element events, thứ tự events (`bai-09.md`, `bai-16.md`) | — |
| 11 | [JC-12 «Cơ bản về ngôn ngữ script 1C»](https://www.youtube.com/watch?v=HvOuAQJ8W2s&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=11) | 6:46 | 1C script | Bài 5-6 — module, procedure/function, biến & scope, If, vòng lặp (`bai-05-06.md`) | — |
| 12 | [JC-13 «Thẩm định dữ liệu»](https://www.youtube.com/watch?v=DVdxgqJrd14&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=12) | 14:16 | Kiểm tra dữ liệu | Bài 12 — Data validation, FillCheckProcessing, CheckFilling() (`bai-12.md`) | — |
| 13 | [JC-14 «Cơ bản về ngôn ngữ Query 1»](https://www.youtube.com/watch?v=wgEsimf_2ks&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=13) | 11:42 | Query language | Bài 10 — SELECT, FROM, Query wizard (`bai-10.md`) | — |
| 14 | [JC-15 «Những thuộc tính chính của đối tượng Siêu dữ liệu»](https://www.youtube.com/watch?v=ZBmyFnjNP-s&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=14) | 4:59 | Metadata chuyên sâu | Bài 2 — standard attributes của class; Bài 3 — standard attributes Catalog (Ref, Code, Description…) và Document (Number, Date, Posted) (`bai-01-04.md`) | — |
| 15 | [JC-16 «Hằng số (Constant)»](https://www.youtube.com/watch?v=0Ru2FzltA4k&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=15) | 7:28 | Metadata chuyên sâu | Bài 13 — Constants (`bai-13.md`) | — |
| 16 | [JC-17 «Đối tượng và tập hợp bản ghi»](https://www.youtube.com/watch?v=L4OkNedrIeQ&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=16) | 5:26 | Metadata chuyên sâu | Bài 15 — object vs non-object entities; Bài 12 — RecordSet / RecordManager (`bai-12.md`, `bai-15.md`) | — |
| 17 | [JC-18 «Tính toàn vẹn tham chiếu»](https://www.youtube.com/watch?v=e-C_yERp2sE&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=17) | 7:49 | Toàn vẹn dữ liệu | Bài 15 — referential integrity, deletion mark, xóa object (`bai-15.md`) | — |
| 18 | [JC-19 «Dữ liệu phân cấp»](https://www.youtube.com/watch?v=nuFs1bCOQFc&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=18) | 12:13 | Catalog | Bài 4 — Hierarchy (Catalog và Chart of characteristic types) (`bai-01-04.md`) | — |
| 19 | [JC-20 «Mã danh mục, số chứng từ và tự động đánh số»](https://www.youtube.com/watch?v=9HFCAWmdJCQ&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=19) | 8:02 | Catalog & Document | Bài 4 — Code, number, autonumbering, periodicity (`bai-01-04.md`) | — |
| 20 | [JC-21 «Dữ liệu xác định trước»](https://www.youtube.com/watch?v=EQLuZq69Nmw&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=20) | 8:02 | Dữ liệu hệ thống | Bài 4 — Predefined data; Bài 13 / 24 — predefined của Chart of characteristic types, Chart of accounts (`bai-01-04.md`, `bai-13.md`, `bai-24.md`) | — |
| 21 | [JC-22 «Kết chuyển chứng từ»](https://www.youtube.com/watch?v=fsu3Wqn9wz8&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=21) | 8:01 | Posting | Bài 11 — Document posting, event Posting, RegisterRecords, posting mode (`bai-11.md`) | — |
| 22 | [JC-23 «Biểu ghi tích lũy»](https://www.youtube.com/watch?v=wbF-aWunEdc&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=22) | 13:46 | Register | Bài 11 — Accumulation register Balances/Turnovers, dimensions, resources, virtual tables (`bai-11.md`) | — |
| 23 | [JC-24 «Biểu ghi thông tin»](https://www.youtube.com/watch?v=2opmwhrnU2A&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=23) | 7:54 | Register | Bài 12 — Information register, periodic, SliceLast/SliceFirst, RecordSet/RecordManager (`bai-12.md`) | — |
| 24 | [JC-25 «Làm việc với đối tượng Metadata»](https://www.youtube.com/watch?v=opQkqATP8oA&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=24) | 7:50 | Platform nâng cao | Bài 1–2 — khái niệm metadata; `Metadata.` chỉ xuất hiện rải rác trong code mẫu (Bài 16, 19, 20, 21, 23) (`bai-01-04.md`) | duyệt cấu trúc metadata bằng code (global property Metadata) không có mục riêng trong giáo trình |
| 25 | [JC-26 «Làm việc với bối cảnh toàn cục (Global Context)»](https://www.youtube.com/watch?v=cqwM140spEs&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=25) | 5:16 | Platform nâng cao | Bài 5-6 — Syntax assistant nhánh Global context, `Message()`; Bài 14 — common module Global (`bai-05-06.md`, `bai-14.md`) | — |
| 26 | [JC-27 «Các kiểu dữ liệu cơ sở»](https://www.youtube.com/watch?v=jdO9y_nXLIQ&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=26) | 9:23 | Kiểu dữ liệu & 1C script | Bài 2 — Primitive types; Bài 5-6 — làm việc với kiểu, ValueIsFilled (`bai-01-04.md`, `bai-05-06.md`) | — |
| 27 | [JC-28 «Các toán tử»](https://www.youtube.com/watch?v=FpPWl5JoKfg&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=27) | 13:07 | Kiểu dữ liệu & 1C script | Bài 5-6 — toán tử và biểu thức (`bai-05-06.md`) | — |
| 28 | [JC-29 «Các lớp hệ thống»](https://www.youtube.com/watch?v=_6VNsJ5nWrM&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=28) | 7:57 | Collections | Bài 5-6 — collections: Array, Structure, Map, ValueList, ValueTable, ValueTree (`bai-05-06.md`) | — |
| 29 | [JC-30 «Các module và tương tác Client-Server»](https://www.youtube.com/watch?v=oD8pK7RvuYw&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=29) | 6:16 | Client-server | Bài 7 — compilation directives, loại module, context / non-context call (`bai-07.md`) | — |
| 30 | [JC-31 «Cơ bản về UX-UI»](https://www.youtube.com/watch?v=Fsfbuzgyutk&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=30) | 6:39 | Form UX/UI | Bài 9 — bố cục form, groups (`bai-09.md`) | nguyên lý thiết kế giao diện (công thái học) không có trong giáo trình |
| 31 | [JC-32 «Phần tử trường»](https://www.youtube.com/watch?v=KmiQm3DJ4AQ&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=31) | 5:32 | Form UX/UI | Bài 9 — form items (field) (`bai-09.md`) | các loại field chi tiết, mặt nạ nhập liệu (mask), định dạng hiển thị không có mục riêng trong giáo trình |
| 32 | [JC-33 «Tài liệu được định dạng»](https://www.youtube.com/watch?v=zJWbGGSkDvY&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=32) | 6:15 | Form UX/UI | — (—) | FormattedDocument không có trong giáo trình 24 bài |
| 33 | [JC-34 «Trường tài liệu HTML»](https://www.youtube.com/watch?v=ME0T1MLyNps&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=33) | 4:50 | Form UX/UI | — (—) | trường HTML document trên form không có trong giáo trình 24 bài |
| 34 | [JC-35 «Giao diện lệnh (command) trên biểu mẫu (form)»](https://www.youtube.com/watch?v=4sYHynvvbls&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=34) | 6:29 | Form UX/UI | Bài 9 — form commands, command bar; Bài 14 — commands (`bai-09.md`, `bai-14.md`) | gán phím tắt cho command không có trong giáo trình |
| 35 | [JC-36 «Hiển thị có điều kiện»](https://www.youtube.com/watch?v=a6kSspz-wo4&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=35) | 10:29 | Form UX/UI | Bài 9 — conditional appearance trên form; Bài 18 — conditional appearance trong DCS (`bai-09.md`, `bai-18.md`) | — |
| 36 | [JC-37 «Danh sách động (Dynamic list)»](https://www.youtube.com/watch?v=rr_ohZ13H6k&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=36) | 4:53 | Form UX/UI | Bài 9 — Dynamic list (bảng hoặc query tùy ý); Bài 10 — query language (`bai-09.md`, `bai-10.md`) | — |
| 37 | [JC-38 «Tùy chọn chức năng»](https://www.youtube.com/watch?v=RF55RDNLgks&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=37) | 7:02 | Quản trị tính năng | Bài 15 — Functional options (`bai-15.md`) | — |
| 38 | [JC-39 «Trò chuyện với người dùng»](https://www.youtube.com/watch?v=s0MHq7d_nVc&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=38) | 9:26 | Tương tác người dùng | Bài 9 — ShowQueryBox + CallbackDescription (code mẫu); Bài 7 — dialog không chặn (CallbackDescription); Bài 21 — ShowUserNotification (`bai-07.md`, `bai-09.md`, `bai-21.md`) | — |
| 39 | [JC-40 «Cơ bản về ngôn ngữ truy vấn 2»](https://www.youtube.com/watch?v=HJ2nTpet2yo&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=39) | 5:33 | Query language | Bài 10 — parameters, Query wizard (`bai-10.md`) | — |
| 40 | [JC-41 «Truy vấn SQL và cấu trúc truy vấn»](https://www.youtube.com/watch?v=E3EJ6WRG8Sk&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=40) | 4:32 | Query language | Bài 10 — cấu trúc query; Bài 11 — virtual tables (`bai-10.md`, `bai-11.md`) | — |
| 41 | [JC-42 «Mệnh đề SELECT»](https://www.youtube.com/watch?v=gcvHm8ER72o&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=41) | 6:34 | Query language | Bài 10 — SELECT, ISNULL, CASE, DISTINCT (`bai-10.md`) | — |
| 42 | [JC-43 «FROM và WHERE»](https://www.youtube.com/watch?v=PtCdTq0a1nM&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=42) | 5:58 | Query language | Bài 10 — FROM, WHERE; Bài 11 — lọc trong tham số virtual table (`bai-10.md`, `bai-11.md`) | — |
| 43 | [JC-44 «JOIN»](https://www.youtube.com/watch?v=Ukd1zPxIJqE&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=43) | 7:23 | Query language | Bài 10 — LEFT / INNER / FULL JOIN (`bai-10.md`) | — |
| 44 | [JC-45 «GROUP BY và HAVING»](https://www.youtube.com/watch?v=cCC-HVpGhJk&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=44) | 5:10 | Query language | Bài 10 — GROUP BY, hàm tổng hợp, HAVING (`bai-10.md`) | — |
| 45 | [JC-46 «Query trong ngôn ngữ 1C Script»](https://www.youtube.com/watch?v=Mws4QN1CdQY&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=45) | 4:28 | Query language | Bài 10 — `New Query`, `.Text`, `SetParameter()`, `Execute()`, `Select()` / `Next()`, `Unload()` (`bai-10.md`) | — |
| 46 | [JC-47 «Báo cáo dựa trên khuôn mẫu»](https://www.youtube.com/watch?v=WVqrshBBH-E&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=46) | 6:34 | DCS | Bài 18 — DCS (theo mô tả của bảng gốc); nếu video nói về report điền template bằng code thì là Bài 17 (`bai-17.md`, `bai-18.md`) | — |
| 47 | [JC-48 «Khuôn mẫu và trình soạn thảo dữ liệu»](https://www.youtube.com/watch?v=It9J9M69Tl8&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=47) | 8:13 | DCS | Bài 18 — data composition schema, data fields, resources (`bai-18.md`) | — |
| 48 | [JC-49 «Bộ dữ liệu (data set)»](https://www.youtube.com/watch?v=HLvgcgPFRq0&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=48) | 5:59 | DCS | Bài 18 — data sets: Query, Object, Union (`bai-18.md`) | — |
| 49 | [JC-50 «Thiết lập (setting)»](https://www.youtube.com/watch?v=rq_qf0e3is8&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=49) | 8:31 | DCS | Bài 18 — settings: grouping, selected fields, filters, sorting (`bai-18.md`) | — |

## Bảng 2 — Bài trong giáo trình → video tham khảo

| Bài giáo trình | Video |
|---|---|
| Bài 1 (Giới thiệu nền tảng) | [JC-2](https://www.youtube.com/watch?v=hclmzfC2Lak&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=1) «Hướng dẫn cài đặt nền tảng 1C:Enterprise»; [JC-3](https://www.youtube.com/watch?v=BBmgzkbdcG8&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=2) «Hello world với 1C:Enterprise»; [JC-4](https://www.youtube.com/watch?v=Q3j_VFjTakc&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=3) «Infobase - Cơ sở thông tin»; [JC-5](https://www.youtube.com/watch?v=tQQjrh3gBJk&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=4) «Metadata class»; [JC-25](https://www.youtube.com/watch?v=opQkqATP8oA&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=24) «Làm việc với đối tượng Metadata» |
| Bài 2 (Metadata, primitive types) | [JC-5](https://www.youtube.com/watch?v=tQQjrh3gBJk&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=4) «Metadata class»; [JC-15](https://www.youtube.com/watch?v=ZBmyFnjNP-s&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=14) «Những thuộc tính chính của đối tượng Siêu dữ liệu»; [JC-25](https://www.youtube.com/watch?v=opQkqATP8oA&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=24) «Làm việc với đối tượng Metadata»; [JC-27](https://www.youtube.com/watch?v=jdO9y_nXLIQ&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=26) «Các kiểu dữ liệu cơ sở» |
| Bài 3 (Catalog, Enumeration, Document) | [JC-6](https://www.youtube.com/watch?v=AOKkvDYjsuw&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=5) «Enumeration và Catalog - Liệt kê và danh mục»; [JC-7](https://www.youtube.com/watch?v=dQt7_Ln8zVI&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=6) «Chứng từ và biểu ghi tích lũy»; [JC-8](https://www.youtube.com/watch?v=rn0hEz5Xc08&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=7) «Giao diện người dùng cơ bản»; [JC-15](https://www.youtube.com/watch?v=ZBmyFnjNP-s&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=14) «Những thuộc tính chính của đối tượng Siêu dữ liệu» |
| Bài 4 (Hierarchy, Owner, predefined, numbering) | [JC-19](https://www.youtube.com/watch?v=nuFs1bCOQFc&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=18) «Dữ liệu phân cấp»; [JC-20](https://www.youtube.com/watch?v=9HFCAWmdJCQ&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=19) «Mã danh mục, số chứng từ và tự động đánh số»; [JC-21](https://www.youtube.com/watch?v=EQLuZq69Nmw&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=20) «Dữ liệu xác định trước» |
| Bài 5-6 (1C script, collections) | [JC-3](https://www.youtube.com/watch?v=BBmgzkbdcG8&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=2) «Hello world với 1C:Enterprise»; [JC-12](https://www.youtube.com/watch?v=HvOuAQJ8W2s&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=11) «Cơ bản về ngôn ngữ script 1C»; [JC-26](https://www.youtube.com/watch?v=cqwM140spEs&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=25) «Làm việc với bối cảnh toàn cục (Global Context)»; [JC-27](https://www.youtube.com/watch?v=jdO9y_nXLIQ&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=26) «Các kiểu dữ liệu cơ sở»; [JC-28](https://www.youtube.com/watch?v=FpPWl5JoKfg&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=27) «Các toán tử»; [JC-29](https://www.youtube.com/watch?v=_6VNsJ5nWrM&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=28) «Các lớp hệ thống» |
| Bài 7 (Client-server) | [JC-30](https://www.youtube.com/watch?v=oD8pK7RvuYw&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=29) «Các module và tương tác Client-Server»; [JC-39](https://www.youtube.com/watch?v=s0MHq7d_nVc&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=38) «Trò chuyện với người dùng» |
| Bài 8 (Debugging) | — |
| Bài 9 (Subsystems, Panels, Forms) | [JC-8](https://www.youtube.com/watch?v=rn0hEz5Xc08&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=7) «Giao diện người dùng cơ bản»; [JC-9](https://www.youtube.com/watch?v=DDk5kS4BRow&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=8) «Homepage, form và command»; [JC-10](https://www.youtube.com/watch?v=FqrPnmv_QPA&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=9) «Cơ bản về trình chỉnh sửa form»; [JC-11](https://www.youtube.com/watch?v=FAkymD2Zqks&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=10) «Sự kiện và trình xử lý sự kiện»; [JC-31](https://www.youtube.com/watch?v=Fsfbuzgyutk&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=30) «Cơ bản về UX-UI»; [JC-32](https://www.youtube.com/watch?v=KmiQm3DJ4AQ&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=31) «Phần tử trường»; [JC-35](https://www.youtube.com/watch?v=4sYHynvvbls&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=34) «Giao diện lệnh (command) trên biểu mẫu (form)»; [JC-36](https://www.youtube.com/watch?v=a6kSspz-wo4&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=35) «Hiển thị có điều kiện»; [JC-37](https://www.youtube.com/watch?v=rr_ohZ13H6k&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=36) «Danh sách động (Dynamic list)»; [JC-39](https://www.youtube.com/watch?v=s0MHq7d_nVc&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=38) «Trò chuyện với người dùng» |
| Bài 10 (Query language) | [JC-14](https://www.youtube.com/watch?v=wgEsimf_2ks&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=13) «Cơ bản về ngôn ngữ Query 1»; [JC-37](https://www.youtube.com/watch?v=rr_ohZ13H6k&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=36) «Danh sách động (Dynamic list)»; [JC-40](https://www.youtube.com/watch?v=HJ2nTpet2yo&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=39) «Cơ bản về ngôn ngữ truy vấn 2»; [JC-41](https://www.youtube.com/watch?v=E3EJ6WRG8Sk&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=40) «Truy vấn SQL và cấu trúc truy vấn»; [JC-42](https://www.youtube.com/watch?v=gcvHm8ER72o&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=41) «Mệnh đề SELECT»; [JC-43](https://www.youtube.com/watch?v=PtCdTq0a1nM&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=42) «FROM và WHERE»; [JC-44](https://www.youtube.com/watch?v=Ukd1zPxIJqE&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=43) «JOIN»; [JC-45](https://www.youtube.com/watch?v=cCC-HVpGhJk&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=44) «GROUP BY và HAVING»; [JC-46](https://www.youtube.com/watch?v=Mws4QN1CdQY&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=45) «Query trong ngôn ngữ 1C Script» |
| Bài 11 (Accumulation register, posting) | [JC-7](https://www.youtube.com/watch?v=dQt7_Ln8zVI&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=6) «Chứng từ và biểu ghi tích lũy»; [JC-22](https://www.youtube.com/watch?v=fsu3Wqn9wz8&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=21) «Kết chuyển chứng từ»; [JC-23](https://www.youtube.com/watch?v=wbF-aWunEdc&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=22) «Biểu ghi tích lũy»; [JC-41](https://www.youtube.com/watch?v=E3EJ6WRG8Sk&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=40) «Truy vấn SQL và cấu trúc truy vấn»; [JC-43](https://www.youtube.com/watch?v=PtCdTq0a1nM&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=42) «FROM và WHERE» |
| Bài 12 (Data validation, information register) | [JC-13](https://www.youtube.com/watch?v=DVdxgqJrd14&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=12) «Thẩm định dữ liệu»; [JC-17](https://www.youtube.com/watch?v=L4OkNedrIeQ&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=16) «Đối tượng và tập hợp bản ghi»; [JC-24](https://www.youtube.com/watch?v=2opmwhrnU2A&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=23) «Biểu ghi thông tin» |
| Bài 13 (Constants, charts of characteristic types, journals) | [JC-16](https://www.youtube.com/watch?v=0Ru2FzltA4k&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=15) «Hằng số (Constant)»; [JC-21](https://www.youtube.com/watch?v=EQLuZq69Nmw&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=20) «Dữ liệu xác định trước» |
| Bài 14 (Common modules, commands) | [JC-9](https://www.youtube.com/watch?v=DDk5kS4BRow&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=8) «Homepage, form và command»; [JC-26](https://www.youtube.com/watch?v=cqwM140spEs&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=25) «Làm việc với bối cảnh toàn cục (Global Context)»; [JC-35](https://www.youtube.com/watch?v=4sYHynvvbls&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=34) «Giao diện lệnh (command) trên biểu mẫu (form)» |
| Bài 15 (Functional options, object/non-object, referential integrity) | [JC-17](https://www.youtube.com/watch?v=L4OkNedrIeQ&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=16) «Đối tượng và tập hợp bản ghi»; [JC-18](https://www.youtube.com/watch?v=e-C_yERp2sE&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=17) «Tính toàn vẹn tham chiếu»; [JC-38](https://www.youtube.com/watch?v=RF55RDNLgks&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=37) «Tùy chọn chức năng» |
| Bài 16 (Events, subscriptions) | [JC-11](https://www.youtube.com/watch?v=FAkymD2Zqks&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=10) «Sự kiện và trình xử lý sự kiện» |
| Bài 17 (Print forms, template-based reports) | [JC-47](https://www.youtube.com/watch?v=WVqrshBBH-E&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=46) «Báo cáo dựa trên khuôn mẫu» |
| Bài 18 (DCS reports) | [JC-36](https://www.youtube.com/watch?v=a6kSspz-wo4&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=35) «Hiển thị có điều kiện»; [JC-47](https://www.youtube.com/watch?v=WVqrshBBH-E&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=46) «Báo cáo dựa trên khuôn mẫu»; [JC-48](https://www.youtube.com/watch?v=It9J9M69Tl8&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=47) «Khuôn mẫu và trình soạn thảo dữ liệu»; [JC-49](https://www.youtube.com/watch?v=HLvgcgPFRq0&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=48) «Bộ dữ liệu (data set)»; [JC-50](https://www.youtube.com/watch?v=rq_qf0e3is8&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=49) «Thiết lập (setting)» |
| Bài 19 (Data processors) | — |
| Bài 20 (Roles, access rights) | — |
| Bài 21 (SSL: additional reports & data processors) | [JC-39](https://www.youtube.com/watch?v=s0MHq7d_nVc&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=38) «Trò chuyện với người dùng» |
| Bài 22 (SSL: Print) | — |
| Bài 23 (SSL: files) | — |
| Bài 24 (Accounting) | [JC-21](https://www.youtube.com/watch?v=EQLuZq69Nmw&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=20) «Dữ liệu xác định trước» |
| Extensions (Configuration extensions) | — |

**Bài không có video trong playlist:** Bài 8 (Debugging), Bài 19 (Data processors), Bài 20 (Roles, access rights), Bài 22 (SSL: Print), Bài 23 (SSL: files), Extensions (Configuration extensions). Với các bài này chỉ dẫn tài liệu Theory/Practice.

## Các chỗ đã sửa so với bảng gốc

- **Link:** tất cả 49 link trong bảng gốc dùng cùng mã video `hclmzfC2Lak` (video đầu tiên) và chỉ khác tham số `index` → bấm vào luôn mở video JC-2. Hai dòng còn trùng index (JC-42 và JC-43 cùng `index=42`; JC-45 và JC-46 cùng `index=45`). Bảng trên dùng mã video thật đọc từ playlist.
- **JC-6 «Enumeration và Catalog - Liệt kê và danh mục»:** Bảng gốc ghi Bài 2 & 3; nội dung Catalog/Enumeration nằm ở Bài 3.
- **JC-8 «Giao diện người dùng cơ bản»:** Bảng gốc ghi Bài 4 & 9; Subsystem nằm ở Bài 3 (sơ lược) và Bài 9, Bài 4 không có nội dung giao diện.
- **JC-16 «Hằng số (Constant)»:** Bảng gốc ghi thêm "Value Storage" cho Bài 13; ValueStorage trong giáo trình nằm ở Bài 17 (LogoPicture) và Bài 10.
- **JC-21 «Dữ liệu xác định trước»:** Bảng gốc ghi "Predefined Data trong Catalog và Register"; theo giáo trình, predefined data có ở Catalog, Chart of characteristic types, Chart of accounts — register không có predefined data.
- **JC-25 «Làm việc với đối tượng Metadata»:** Bảng gốc ghi Bài 1 & 14; Bài 14 không có nội dung này.
- **JC-33 «Tài liệu được định dạng»:** Bảng gốc ghi Bài 9 & 17; cả hai bài không đề cập FormattedDocument.
- **JC-34 «Trường tài liệu HTML»:** Bảng gốc ghi Bài 9; Bài 9 không đề cập trường HTML.
- **JC-39 «Trò chuyện với người dùng»:** Bảng gốc ghi Bài 7 & 9; ShowUserNotification trong giáo trình chỉ xuất hiện ở Bài 21.
- **JC-46 «Query trong ngôn ngữ 1C Script»:** Bảng gốc ghi `.Choose()`; tên method đúng (bản tiếng Anh) là `Select()`.
- **JC-47 «Báo cáo dựa trên khuôn mẫu»:** Tên video "báo cáo dựa trên khuôn mẫu" trùng tên Bài 17 (template-based reports) nhưng mô tả của bảng gốc là giới thiệu DCS — cần xem video để chốt.
- Một số mô tả trong bảng gốc nêu chi tiết không có trong giáo trình (Training version, mặt nạ nhập liệu, phím tắt command, nguyên lý công thái học); những phần đó được tách sang cột "Ngoài giáo trình".


---

# § video-thuc-hanh

# Chuỗi video thực hành case study (xây từ cấu hình rỗng) ↔ bài giáo trình ↔ lộ trình người học

> Cập nhật 07/10/2026. Nguồn: Phần 1 — playlist "Tuyển tập các bài tập thực hành 1C:Enterprise" (https://www.youtube.com/playlist?list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2; 6 bài + 1 đoạn mở đầu 5 giây); Phần 2 — playlist "(TEMP) Tuyển tập các bài tập thực hành 1C:Enterprise" (https://www.youtube.com/playlist?list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM; 14 video). Mỗi video dựng một bài toán nghiệp vụ từ cấu hình rỗng, làm từng bước trong Designer. Nội dung đã kiểm chứng bằng transcript.

**Về đánh số:** tiêu đề video đánh "Bài 1 … Bài 20" theo thứ tự riêng của chuỗi, **không** trùng số bài giáo trình. Phần 2 bắt đầu từ "Bài 7", không có "Bài 9", "Bài 19" có hai bản (Full/Short), và hiện dừng ở "Bài 20". Khi nói với người học, dùng tên video; khi nói thứ tự trong lộ trình, nói "video thứ k của lộ trình".

## Cách dùng

- Người học hỏi "nên học/xem gì", "mới bắt đầu, không biết gì", "muốn làm theo từng bước", hoặc hỏi lộ trình → Mục A chọn đúng nhóm.
- Lộ trình J đang làm một đề cụ thể → Mục B (kết hợp cả video giải đáp).
- Người học gặp một tình huống cụ thể → `references/video.md#video-qa-thuc-chien` Mục A (có cả tình huống lấy từ chuỗi này).
- Câu dẫn cho người học (giống quy ước video bài giảng): "🎬 Bạn có thể tham khảo thêm về <chủ đề> của khóa tại đây: [<tên video>](<link>)" — với tình huống lỗi có thể nói "tham khảo cách xử lý <tình huống> của khóa tại đây". Dùng **tên hiển thị** trong bảng (đã bỏ "Bài N:" và hậu tố tên kênh). Không nêu số "Bài N" của video (khác số bài giáo trình), không dùng mã QA-/P1-/P2- (chỉ để tra nội bộ), không gọi là "khóa cũ".
- Video dựng **ví dụ minh họa**. Với lộ trình M, nói rõ đây là ví dụ kỹ thuật, không phải thiết kế mẫu cho hệ thống của nhóm (nhóm vẫn tự chọn object theo doanh nghiệp của mình).
- Mỗi thẻ có "Lưu ý khi giới thiệu": chỗ video đơn giản hóa hoặc chưa chặt. Với D/M, có thể biến các lưu ý này thành bài tập nâng cấp ("thử sửa để chặn một sinh viên thuê hai xe").

## A. Lộ trình theo nhóm người học

### A1. Bắt đầu từ con số 0 hoặc sinh viên trái ngành — nắm vững thao tác Designer mà không bị ngợp

Giảng viên khuyến nghị: học theo chuỗi từ video "Ghi nhận luân chuyển dòng tiền" (cuối Phần 1) qua hết Phần 2. Chưa cài nền tảng thì xem trước [Cài đặt 1C:Enterprise phiên bản đào tạo](https://www.youtube.com/watch?v=sJqX17GGRt0&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=3) (2:19).

1. [Ghi nhận luân chuyển dòng tiền](https://www.youtube.com/watch?v=YzhM76Wy9fk&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=7) (18:29) — quỹ tiền mặt: thu/chi, posting, số dư trên form và đánh số chứng từ _(mã nội bộ P1-6)_
2. [Ghi nhận thay đổi tỷ giá hối đoái](https://www.youtube.com/watch?v=9_m7XqHPZlA&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=1) (9:04) — information register theo ngày và biểu đồ _(mã nội bộ P2-1)_
3. [Ghi nhận thay đổi giá mua tiền tệ](https://www.youtube.com/watch?v=lYPmr3Rxi3g&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=2) (8:11) — information register nhiều dimension _(trùng nhiều với video trước — có thể bỏ qua)_ _(mã nội bộ P2-2)_
4. [Lưu trữ và báo cáo kết quả học tập của sinh viên](https://www.youtube.com/watch?v=NhFE1uwi7Hw&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=3) (14:56) — chấm điểm qua chứng từ và báo cáo trung bình có tô màu _(mã nội bộ P2-3)_
5. [Hệ thống cho thuê xe điện](https://www.youtube.com/watch?v=wWGXT2KSul8&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=4) (10:40) — một chứng từ ghi vào hai register _(mã nội bộ P2-4)_
6. [Tạo lập hệ thống thông tin thư viện](https://www.youtube.com/watch?v=3DMFgUjg2Js&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=5) (24:38) — mượn – trả và tạo phiếu trả từ phiếu mượn _(mã nội bộ P2-5)_
7. [Hệ thống thông tin cửa hàng nhỏ](https://www.youtube.com/watch?v=zXa4pQv0LHE&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=6) (12:28) — xử lý nhiều đơn hàng bằng một lệnh _(nâng cao (code client-server, command) — có thể để cuối)_ _(mã nội bộ P2-6)_
8. [Hạch toán sản phẩm dịch vụ](https://www.youtube.com/watch?v=GFsS9x1bOTQ&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=7) (15:54) — tách hàng hóa/dịch vụ và bật tắt tính năng bằng Functional option _(mã nội bộ P2-7)_
9. [Hạch toán thu nhập theo doanh số](https://www.youtube.com/watch?v=QRAzQKBCtds&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=8) (20:00) — quy đổi tỷ giá khi posting bằng SliceLast _(mã nội bộ P2-8)_
10. [Bắt lần khởi động đầu tiên](https://www.youtube.com/watch?v=Q9op8HgLMtM&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=9) (9:05) — xử lý lần chạy đầu tiên của ứng dụng _(mã nội bộ P2-9)_
11. [Hạch toán hàng hóa - Bài toán đơn giản nhất](https://www.youtube.com/watch?v=SwgfC-uA6Eg&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=10) (16:55) — nhập – xuất – tồn và chặn âm kho _(mã nội bộ P2-10)_
12. [Hạch toán hàng hóa - Hạch toán một kho](https://www.youtube.com/watch?v=BD370AtszHI&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=11) (20:57) — tồn kho theo từng kho (kho trên đầu chứng từ) _(mã nội bộ P2-11)_
13. [Hạch toán hàng hóa nhiều kho (Full)](https://www.youtube.com/watch?v=HIAYMOepPw4&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=12) (18:40) — kho trên từng dòng hàng và chặn âm theo từng kho _(chọn bản này hoặc bản Short ngay sau)_ _(mã nội bộ P2-12)_
14. [Hạch toán hàng hóa nhiều kho (Short)](https://www.youtube.com/watch?v=sHl70mbjk4c&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=13) (14:51) — sửa cấu trúc chứng từ đang có dữ liệu _(chỉ xem nếu đã làm "Hạch toán một kho"; nếu không thì xem bản Full)_ _(mã nội bộ P2-13)_
15. [Hạch toán hàng hóa - Theo hạn sử dụng](https://www.youtube.com/watch?v=TBgeOMXYp0w&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=14) (13:24) — tồn kho theo hạn sử dụng và xuất dần theo lô _(nâng cao — query batch, xuất dần theo lô)_ _(mã nội bộ P2-14)_

Gợi ý khi hướng dẫn: mỗi video, người học tự làm lại trên infobase của mình rồi trả lời một câu "vì sao" (vì sao dùng register này, vì sao đặt code ở module này). Nếu video đầu tiên (dòng tiền) quá dày với người hoàn toàn mới, có thể xem trước ba video Catalog/chứng từ đơn giản của Phần 1 (sinh viên – môn học, nhân viên, du lịch) — đây là đề xuất bổ sung, không thuộc khuyến nghị gốc.

### A2. Làm bài tập lớn / đồ án trên 1C:Jet

Giảng viên khuyến nghị: tham khảo chuỗi Phần 1, đặc biệt video "du lịch" và "dòng tiền" vì đây là các mô hình nghiệp vụ cốt lõi thường gặp trong đồ án.

1. [Giới thiệu nền tảng 1C:Enterprise](https://www.youtube.com/watch?v=Dahr2ACNN74&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=2) (13:59) — tổng quan nền tảng 1C:Enterprise _(mã nội bộ P1-1)_
2. [Cài đặt 1C:Enterprise phiên bản đào tạo](https://www.youtube.com/watch?v=sJqX17GGRt0&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=3) (2:19) — cài đặt bản 1C:Enterprise đào tạo _(mã nội bộ P1-2)_
3. [Lưu trữ thông tin sinh viên và môn học](https://www.youtube.com/watch?v=UGXVLOKRaGw&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=4) (12:19) — Catalog, phân cấp và tabular section _(mã nội bộ P1-3)_
4. [Lưu trữ thông tin nhân viên](https://www.youtube.com/watch?v=WF19J3tct0I&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=5) (9:37) — catalog cấp dưới và lịch sử lương theo tháng _(mã nội bộ P1-4)_
5. [Lưu trữ thông tin các chuyến du lịch](https://www.youtube.com/watch?v=PwqP4GODNrY&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=6) (13:15) — tạo chứng từ trên cơ sở chứng từ khác (Input on basis) _(★ mô hình "đặt trước → chứng từ thực hiện tạo trên cơ sở" (Create based on); trong Jet, phiếu thu/chi được tạo trên cơ sở hóa đơn SalesInvoice/SupplierInvoice theo đúng cơ chế này (`references/jet-1-overview-extending-cash.md#jet-cash` mục 6))_ _(mã nội bộ P1-5)_
6. [Ghi nhận luân chuyển dòng tiền](https://www.youtube.com/watch?v=YzhM76Wy9fk&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=7) (18:29) — quỹ tiền mặt: thu/chi, posting, số dư trên form và đánh số chứng từ _(★ posting, accumulation register số dư, hiển thị số dư lên form, Document journal, Document numerator — đúng mô hình phân hệ CashManagement của Jet)_ _(mã nội bộ P1-6)_

Sau đó chọn video theo đề ở Mục B; khi gặp lỗi tra `references/video.md#video-qa-thuc-chien`.

**Lộ trình J (sinh viên Logistics, ít thời gian):** không xem cả chuỗi. Tối thiểu: video "dòng tiền" (hiểu posting và số dư) + video "du lịch" (hiểu tạo chứng từ trên cơ sở) + 1–2 video theo đề của nhóm (Mục B). Mỗi video xem xong, yêu cầu sinh viên chỉ ra chỗ tương ứng trong Jet (ví dụ register số dư quỹ ↔ register CashBalance của phân hệ CashManagement).

### A3. Sinh viên MIS tự xây hệ thống từ cấu hình trống (lộ trình M)

Chuỗi này sát nhất với việc nhóm M làm. Chọn theo khối chức năng nhóm đang xây:

- Tiền: [Ghi nhận luân chuyển dòng tiền](https://www.youtube.com/watch?v=YzhM76Wy9fk&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=7) (18:29)
- Kho (tăng dần độ khó): [Hạch toán hàng hóa - Bài toán đơn giản nhất](https://www.youtube.com/watch?v=SwgfC-uA6Eg&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=10) (16:55) → [Hạch toán hàng hóa - Hạch toán một kho](https://www.youtube.com/watch?v=BD370AtszHI&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=11) (20:57) → [Hạch toán hàng hóa nhiều kho (Full)](https://www.youtube.com/watch?v=HIAYMOepPw4&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=12) (18:40) → [Hạch toán hàng hóa - Theo hạn sử dụng](https://www.youtube.com/watch?v=TBgeOMXYp0w&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=14) (13:24)
- Bán hàng, giá, tỷ giá: [Hạch toán sản phẩm dịch vụ](https://www.youtube.com/watch?v=GFsS9x1bOTQ&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=7) (15:54) · [Hạch toán thu nhập theo doanh số](https://www.youtube.com/watch?v=QRAzQKBCtds&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=8) (20:00) · [Ghi nhận thay đổi tỷ giá hối đoái](https://www.youtube.com/watch?v=9_m7XqHPZlA&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=1) (9:04)
- Đặt hàng / mua: [Lưu trữ thông tin các chuyến du lịch](https://www.youtube.com/watch?v=PwqP4GODNrY&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=6) (13:15) · [Hệ thống thông tin cửa hàng nhỏ](https://www.youtube.com/watch?v=zXa4pQv0LHE&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=6) (12:28)
- Báo cáo có biểu đồ và tô màu: [Lưu trữ và báo cáo kết quả học tập của sinh viên](https://www.youtube.com/watch?v=NhFE1uwi7Hw&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=3) (14:56)

Nhắc nhóm: video là ví dụ kỹ thuật; quy trình và bộ object là do nhóm tự thiết kế theo doanh nghiệp của mình.

### A4. Intern Dev, nhân sự IT đối tác (lộ trình D)

Lướt nhanh Phần 1 để quen nghiệp vụ; tập trung các video có nhiều code và kỹ thuật:

- Thực hành: [Ghi nhận luân chuyển dòng tiền](https://www.youtube.com/watch?v=YzhM76Wy9fk&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=7) (18:29) · [Hệ thống thông tin cửa hàng nhỏ](https://www.youtube.com/watch?v=zXa4pQv0LHE&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=6) (12:28) · [Hạch toán thu nhập theo doanh số](https://www.youtube.com/watch?v=QRAzQKBCtds&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=8) (20:00) · [Bắt lần khởi động đầu tiên](https://www.youtube.com/watch?v=Q9op8HgLMtM&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=9) (9:05) · [Hạch toán hàng hóa nhiều kho (Full)](https://www.youtube.com/watch?v=HIAYMOepPw4&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=12) (18:40) · [Hạch toán hàng hóa - Theo hạn sử dụng](https://www.youtube.com/watch?v=TBgeOMXYp0w&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=14) (13:24)
- Giải đáp thực chiến: [Tạo chức năng sửa password với vai trò người dùng](https://www.youtube.com/watch?v=taKIdmcCmIQ&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=9) (26:39) · [Kết nhập file excel vào danh mục sản phẩm](https://www.youtube.com/watch?v=DlXBXRzBJGw&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=13) (38:42) · [Extension (Phần mở rộng) trong 1C:Enterprise](https://www.youtube.com/watch?v=T_DEaA1p_bA&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=22) (6:33) · [Chặn kết chuyển khi phát hiện tồn kho âm](https://www.youtube.com/watch?v=k2uht5J1f3c&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=25) (10:03) · [Hướng dẫn publish Infobase 1C:Enterprise lên web server](https://www.youtube.com/watch?v=P_bwSfxAV8I&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=28) (7:21)

Bài tập nâng cấp phù hợp nhóm D: sửa các điểm trong "Lưu ý khi giới thiệu" — kiểm tra theo PointInTime, lọc tồn theo cặp hàng – kho, gom query tỷ giá ra khỏi vòng lặp, chặn ghi ở object module thay vì form.

## B. Chọn video theo đề bài tập lớn trên Jet (cả hai playlist)

| Đề | Xem trước | Lấy gì từ video |
|---|---|---|
| Đề 1 — Lô hàng và hạn sử dụng | [Hạch toán hàng hóa - Theo hạn sử dụng](https://www.youtube.com/watch?v=TBgeOMXYp0w&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=14) (13:24) · [Hạch toán hàng hóa - Bài toán đơn giản nhất](https://www.youtube.com/watch?v=SwgfC-uA6Eg&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=10) (16:55) · [Chặn kết chuyển khi phát hiện tồn kho âm](https://www.youtube.com/watch?v=k2uht5J1f3c&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=25) (10:03) · [Lọc dữ liệu chọn sản phẩm theo hãng](https://www.youtube.com/watch?v=EfF2acfP2Y8&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=19) (6:30) · [Tự động lấy đơn vị tính của sản phẩm](https://www.youtube.com/watch?v=RKAGi62Vy5E&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=12) (8:16) | tồn kho thêm chiều hạn dùng, xuất dần theo lô, chặn bán quá tồn; lọc lô theo sản phẩm khi chọn |
| Đề 2 — Định mức tồn kho chuỗi cửa hàng | [Báo động tồn kho thấp với màu chữ hiển thị](https://www.youtube.com/watch?v=0JbOMl80lnY&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=18) (13:09) · [Truy vấn tồn kho trong chứng từ bán hàng](https://www.youtube.com/watch?v=13817kAvhwQ&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=17) (9:53) · [Hạch toán hàng hóa - Hạch toán một kho](https://www.youtube.com/watch?v=BD370AtszHI&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=11) (20:57) · [Xây dựng các trường tự động điền](https://www.youtube.com/watch?v=8klMmoJXBCk&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=10) (2:02) · [Lưu trữ thông tin nhân viên](https://www.youtube.com/watch?v=WF19J3tct0I&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=5) (9:37) | tô màu khi dưới định mức, xem tồn khi chọn hàng, tồn theo kho/cửa hàng; ý tưởng lưu định mức theo kỳ bằng information register |
| Đề 3 — Đơn đặt hàng nhà cung cấp | [Lưu trữ thông tin các chuyến du lịch](https://www.youtube.com/watch?v=PwqP4GODNrY&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=6) (13:15) · [Hệ thống thông tin cửa hàng nhỏ](https://www.youtube.com/watch?v=zXa4pQv0LHE&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=6) (12:28) · [Fix lỗi không tính toán Thành tiền khi thay đổi Số lượng](https://www.youtube.com/watch?v=LRRNf8MxoQw&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=1) (4:24) · [Lọc dữ liệu chọn sản phẩm theo hãng](https://www.youtube.com/watch?v=EfF2acfP2Y8&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=19) (6:30) · [Tạo chức năng in hóa đơn chứng từ](https://www.youtube.com/watch?v=uwEBQJZG6t4&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=7) (5:31) | tạo chứng từ trên cơ sở đơn đặt, xử lý nhiều đơn, tính thành tiền khi đổi số lượng, lọc hàng theo NCC, in đơn |
| Đề 4 — Đánh giá nhà cung cấp | [Lưu trữ và báo cáo kết quả học tập của sinh viên](https://www.youtube.com/watch?v=NhFE1uwi7Hw&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=3) (14:56) · [Kiểm tra dữ liệu trùng lặp](https://www.youtube.com/watch?v=603j21ItABk&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=11) (8:55) · [Hủy sự kiện đang thực thi](https://www.youtube.com/watch?v=rW40s85Gtc4&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=16) (3:18) · [Báo cáo lợi nhuận theo kỳ](https://www.youtube.com/watch?v=98gDiVV8jx0&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=8) (9:16) | chấm điểm qua chứng từ → register → báo cáo trung bình có tô màu; chống trùng NCC; báo cáo theo kỳ |
| Đề 5 — Chiết khấu theo số lượng | [Lấy giá tự động](https://www.youtube.com/watch?v=oMowT1e019k&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=5) (8:32) · [Fix lỗi không tính toán Thành tiền khi thay đổi Số lượng](https://www.youtube.com/watch?v=LRRNf8MxoQw&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=1) (4:24) · [Hạch toán sản phẩm dịch vụ](https://www.youtube.com/watch?v=GFsS9x1bOTQ&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=7) (15:54) · [Xây dựng cơ chế tích điểm thưởng](https://www.youtube.com/watch?v=0aAaQQP9fXI&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=14) (23:35) | tự điền giá, tính lại khi đổi số lượng, tính tổng tiền, điều chỉnh tiền phải trả |
| Đề 6 — Nhân viên kinh doanh và khu vực | [Lưu trữ thông tin nhân viên](https://www.youtube.com/watch?v=WF19J3tct0I&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=5) (9:37) · [Lọc dữ liệu chọn sản phẩm theo hãng](https://www.youtube.com/watch?v=EfF2acfP2Y8&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=19) (6:30) · [Lưu trữ thông tin sinh viên và môn học](https://www.youtube.com/watch?v=UGXVLOKRaGw&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=4) (12:19) · [Hướng dẫn thiết lập vai trò người dùng](https://www.youtube.com/watch?v=senxXwfjFxU&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=3) (3:38) | thông tin nhân viên và lịch sử theo kỳ, lọc lựa chọn theo khu vực, danh mục phân cấp, role |
| Đề 7 — Hạn thanh toán và tuổi nợ | [Ghi nhận luân chuyển dòng tiền](https://www.youtube.com/watch?v=YzhM76Wy9fk&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=7) (18:29) · [Báo cáo lợi nhuận theo kỳ](https://www.youtube.com/watch?v=98gDiVV8jx0&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=8) (9:16) · [Hủy sự kiện đang thực thi](https://www.youtube.com/watch?v=rW40s85Gtc4&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=16) (3:18) | thu/chi và số dư theo đối tác, báo cáo theo kỳ, chặn ghi dữ liệu không hợp lệ |
| Đề 8 — Khoản mục chi phí và ngân sách | [Ghi nhận luân chuyển dòng tiền](https://www.youtube.com/watch?v=YzhM76Wy9fk&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=7) (18:29) · [Thực hiện tính toán đơn giản với SQL trong 1C](https://www.youtube.com/watch?v=dP21dfHxkCo&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=23) (2:59) · [Báo cáo lợi nhuận theo kỳ](https://www.youtube.com/watch?v=98gDiVV8jx0&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=8) (9:16) · [Hạch toán thu nhập theo doanh số](https://www.youtube.com/watch?v=QRAzQKBCtds&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=8) (20:00) | chi tiền ghi register, tính chênh lệch ngân sách – thực chi trong query, báo cáo theo kỳ, giá trị theo kỳ bằng information register |
| Đề 9 — Kiểm kê kho và xử lý chênh lệch | [Hạch toán hàng hóa - Bài toán đơn giản nhất](https://www.youtube.com/watch?v=SwgfC-uA6Eg&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=10) (16:55) · [Hạch toán hàng hóa - Hạch toán một kho](https://www.youtube.com/watch?v=BD370AtszHI&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=11) (20:57) · [Truy vấn tồn kho trong chứng từ bán hàng](https://www.youtube.com/watch?v=13817kAvhwQ&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=17) (9:53) · [Chặn kết chuyển khi phát hiện tồn kho âm](https://www.youtube.com/watch?v=k2uht5J1f3c&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=25) (10:03) · [Thực hiện tính toán đơn giản với SQL trong 1C](https://www.youtube.com/watch?v=dP21dfHxkCo&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=23) (2:59) | tồn theo kho, tồn sổ sách khi chọn hàng, chặn âm kho, tính chênh lệch trong query |
| Mọi đề — khi thêm object mới vào Jet | [Hiển thị đối tượng Siêu dữ liệu lên Quick menu](https://www.youtube.com/watch?v=rPSNKvFEQ8E&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=21) (2:23) · [Cách hiển thị biểu ghi tích lũy lên phân hệ](https://www.youtube.com/watch?v=DBJeS7LfUpY&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=4) (1:53) · [Extension (Phần mở rộng) trong 1C:Enterprise](https://www.youtube.com/watch?v=T_DEaA1p_bA&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=22) (6:33) · [Tạo chức năng in hóa đơn chứng từ](https://www.youtube.com/watch?v=uwEBQJZG6t4&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=7) (5:31) | đưa object mới lên phân hệ, xem register khi kiểm tra posting, làm báo cáo bằng extension, bản in (trên Jet đăng ký qua SSL Print — Bài 22) |

Video quay trên cấu hình ví dụ, tên object khác Jet: dùng video để hiểu cơ chế, rồi tìm object tương ứng trong Jet (`references/jet-*.md`).

## C. Thẻ video

### Phần 1

### Giới thiệu nền tảng 1C:Enterprise — 13:59

- Link: https://www.youtube.com/watch?v=Dahr2ACNN74&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=2
- Chủ đề để dẫn: tổng quan nền tảng 1C:Enterprise
- Video làm gì: Thuyết trình bằng slide: 1C Company, nền tảng = platform + applied solutions, low-code/RAD, DBMS hỗ trợ, kiến trúc 3 lớp, định hướng nghề nghiệp. Không thao tác Designer.
- Mốc xem nhanh: 0:31 Giới thiệu 3 nội dung: 1C Company, nền tảng, cơ hội nghề nghiệp/đối tác · 2:03 Số liệu quy mô 1C toàn cầu và tại Việt Nam · 4:39 Triết lý RAD/low-code: so sánh quy trình phát triển truyền thống với 1C · 6:13 Ngôn ngữ 1C: domain-specific, OOP, event-driven, script · 6:45 Hệ sinh thái: DBMS hỗ trợ, Designer, on-premise/cloud, đa nền tảng · 9:52 Tích hợp bên thứ ba (web service/API); ảnh Designer: Catalog, Attributes, Tabular section, Document, module · 11:57 Cơ hội đối tác (30/40/50% hoa hồng), cuộc thi, cộng đồng, khóa học
- Bài giáo trình: Bài 1 (chính); Bài 7
- Đề BTL Jet: —
- Nhóm phù hợp: J M D — mức nhập môn
- Lưu ý khi giới thiệu: Các con số (khách hàng, lập trình viên…) là tại thời điểm quay.
- _(mã nội bộ P1-1)_

### Cài đặt 1C:Enterprise phiên bản đào tạo — 2:19

- Link: https://www.youtube.com/watch?v=sJqX17GGRt0&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=3
- Chủ đề để dẫn: cài đặt bản 1C:Enterprise đào tạo
- Video làm gì: Tải và cài Training Version (chọn thành phần, ngôn ngữ giao diện), mở launcher, giới thiệu hai chế độ 1C:Enterprise và Designer.
- Mốc xem nhanh: 0:00 Vào trang cộng đồng 1C để tải bản Training Version · 0:30 Mở thư mục đã tải/giải nén, chạy bộ cài · 1:02 Chọn component (web server extension, additional interface languages EN/VI/RU), chọn ngôn ngữ English, Install, Finish · 1:33 Mở 1C từ Start menu; giới thiệu danh sách infobase · 1:33 Phân biệt chế độ 1C:Enterprise và Designer; hẹn các bài sau
- Bài giáo trình: Bài 1 (chính)
- Đề BTL Jet: —
- Nhóm phù hợp: J M D — mức nhập môn
- Lưu ý khi giới thiệu: Trang tải và giao diện bộ cài có thể đã đổi.
- _(mã nội bộ P1-2)_

### Lưu trữ thông tin sinh viên và môn học — 12:19

- Link: https://www.youtube.com/watch?v=UGXVLOKRaGw&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=4
- Chủ đề để dẫn: Catalog, phân cấp và tabular section
- Dựng từ cấu hình rỗng: Catalog Subjects, Catalog Students (hierarchy, tabular section), Report DCS
- Video làm gì: Từ cấu hình rỗng: Catalog Subjects; Catalog Students phân cấp (folder = lớp), số điện thoại có Mask, tabular section danh sách môn học; báo cáo DCS lọc sinh viên theo môn.
- Mốc xem nhanh: 0:30 Tạo infobase mới không cấu hình, chọn thư mục lưu trữ · 2:04 Tạo Catalog Students, bật Hierarchy (folders and items) — folder là lớp · 2:36 Tạo folder lớp VH1, VH2 và các sinh viên · 3:43 Tab Data: chỉnh độ dài/nhãn (Parent → Class) · 6:56 Thêm Tabular section danh sách môn học, Attribute Subject → CatalogRef.Subjects · 9:38 Settings wizard: List, group by Subject, order by Student · 11:04 Thêm Filter Subject vào user settings; chạy báo cáo, chọn môn Triết học
- Bài giáo trình: Bài 3 (chính); Bài 4, Bài 18, Bài 10
- Đề BTL Jet: Đề 6, Đề 2
- Nhóm phù hợp: M J D — mức cơ bản
- Lưu ý khi giới thiệu: Lưu môn học trong tabular section của sinh viên là thiết kế đơn giản hóa cho bài tập.
- _(mã nội bộ P1-3)_

### Lưu trữ thông tin nhân viên — 9:37

- Link: https://www.youtube.com/watch?v=WF19J3tct0I&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=5
- Chủ đề để dẫn: catalog cấp dưới và lịch sử lương theo tháng
- Dựng từ cấu hình rỗng: Catalog nhân viên (tabular section), Catalog con cái (Owner), Information register lương (periodic)
- Video làm gì: Từ cấu hình rỗng: Catalog nhân viên với tabular section quá trình công tác; catalog con cái là Subordinate catalog (Owner = nhân viên); information register lương Periodicity = Month (dimension nhân viên, Master) để mở từ form nhân viên.
- Mốc xem nhanh: 0:00 Tạo infobase mới cho bài nhân viên · 1:05 Tạo Catalog nhân viên, chạy thử nhập vài nhân viên · 2:38 Tạo Tabular section quá trình làm việc: nơi làm việc, chức vụ, ngày bắt đầu, ngày kết thúc (Date) · 4:12 Nhập thử; lưu ý chưa có kiểm tra ngày bắt đầu/kết thúc hợp lệ · 5:16 Tạo Catalog con cái, Owner = nhân viên, Attribute năm sinh Number(4) · 7:25 Tạo Information register lương: Periodic theo tháng, Independent, Resource lương, Dimension nhân viên (Master) · 8:28 Nhập lương từ form nhân viên, kiểm tra trong register
- Bài giáo trình: Bài 4 (chính); Bài 3, Bài 12, Bài 9
- Đề BTL Jet: Đề 6
- Nhóm phù hợp: M J D — mức cơ bản – trung bình
- Lưu ý khi giới thiệu: Chưa kiểm tra ngày kết thúc > ngày bắt đầu (bổ sung bằng FillCheckProcessing — Bài 12).
- _(mã nội bộ P1-4)_

### Lưu trữ thông tin các chuyến du lịch — 13:15

- Link: https://www.youtube.com/watch?v=PwqP4GODNrY&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=6
- Chủ đề để dẫn: tạo chứng từ trên cơ sở chứng từ khác (Input on basis)
- Dựng từ cấu hình rỗng: Catalog Customers, Visits; Enumeration; Document Booking, VisitExecution (Input on basis); Report DCS
- Video làm gì: Từ cấu hình rỗng: Catalog Customers, Visits; Document Booking; Enumeration phương thức thanh toán; Document VisitExecution tạo "Based on" Booking (Filling wizard tự sinh code); báo cáo DCS doanh thu theo phương thức thanh toán, chỉ lấy chứng từ đã post.
- Mốc xem nhanh: 0:32 Tạo Catalog Customers và Catalog Visits, nhập dữ liệu mẫu · 2:10 Tạo Document Booking với Customer, Visit · 4:18 Tạo Document VisitExecution: Booking, Customer, Visit, Total, PaymentMethod · 6:27 Tab Input on basis: VisitExecution dựa trên Booking, Filling wizard tự sinh code · 8:03 Thử tạo VisitExecution từ Booking (Create based on), nhập tổng tiền, Post · 10:43 Resources: SUM Total; Settings wizard List, group by PaymentMethod, order Total desc · 12:17 Chạy báo cáo, thêm chứng từ và chạy lại
- Bài giáo trình: Bài 3 (chính); Bài 16, Bài 18, Bài 10
- Đề BTL Jet: Đề 3, Đề 7
- Nhóm phù hợp: J M D — mức cơ bản
- Lưu ý khi giới thiệu: Không có tabular section và không ghi register; doanh thu lấy thẳng từ chứng từ — chuẩn giáo trình là ghi qua register (Bài 11).
- _(mã nội bộ P1-5)_

### Ghi nhận luân chuyển dòng tiền — 18:29

- Link: https://www.youtube.com/watch?v=YzhM76Wy9fk&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=7
- Chủ đề để dẫn: quỹ tiền mặt: thu/chi, posting, số dư trên form và đánh số chứng từ
- Dựng từ cấu hình rỗng: Catalog Counterparties, 2 Document thu/chi, Document journal, Accumulation register (Balances), Document numerator
- Video làm gì: Từ cấu hình rỗng: Catalog Counterparties; chứng từ thu và chi tiền; Document journal gom hai chứng từ (lọc theo đối tác); accumulation register số dư quỹ ghi bằng Register records wizard; hiển thị số dư quỹ lên form bằng OnCreateAtServer + query bảng ảo Balance; Document numerator để hai loại phiếu đánh số liên tục.
- Mốc xem nhanh: 1:03 Tạo infobase mới, mở Designer · 2:39 Tạo Document CashReceipt: Counterparty, TotalAmount Number(14,2) không âm · 4:42 Copy CashReceipt thành Document chi tiền · 7:21 Lọc journal theo đối tác (More actions) · 8:52 Register records wizard: thu Receipt, chi Expense; Post lại các chứng từ, kiểm tra register · 11:01 Tạo form, form Attribute Balance; OnCreateAtServer + hàm lấy số dư bằng Query (Balances) · 15:19 Tạo Document numerator (Year) dùng chung cho 2 document; Mark for deletion, Delete marked objects; tạo lại chứng từ kiểm tra số liên tục
- Bài giáo trình: Bài 11 (chính); Bài 13, Bài 4, Bài 10, Bài 9, Bài 7
- Đề BTL Jet: Đề 7, Đề 8
- Nhóm phù hợp: J M D — mức trung bình
- Lưu ý khi giới thiệu: Register chỉ có resource, không có dimension (không tách theo quỹ/đối tác). Số dư tính khi mở form, không tự cập nhật; query không truyền Period.
- _(mã nội bộ P1-6)_

### Phần 2

### Ghi nhận thay đổi tỷ giá hối đoái — 9:04

- Link: https://www.youtube.com/watch?v=9_m7XqHPZlA&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=1
- Chủ đề để dẫn: information register theo ngày và biểu đồ
- Dựng từ cấu hình rỗng: Catalog Currencies (predefined), Information register (periodic Day), Report DCS Chart
- Video làm gì: Từ cấu hình rỗng: Catalog Currencies có Predefined (Dollar); information register tỷ giá Periodicity = Day; báo cáo DCS dạng Chart (đường) theo ngày và loại tiền.
- Mốc xem nhanh: 0:00 Tạo infobase mới · 0:31 Tạo Catalog Currencies, thêm Predefined items (Dollar…) · 1:33 Tạo Information register tỷ giá, Periodicity Day · 2:03 Resource ExchangeRate (Number), Dimension Currency · 3:05 Nhập tỷ giá cho các ngày cách quãng (dùng Copy để nhập nhanh) · 6:44 Settings wizard: Chart, Series Currency, Points Period, Line chart · 7:46 Phân tích điểm không có dữ liệu; chỉnh bổ sung kỳ (period addition)
- Bài giáo trình: Bài 12 (chính); Bài 4, Bài 18
- Đề BTL Jet: Đề 5, Đề 4
- Nhóm phù hợp: M J — mức cơ bản
- Lưu ý khi giới thiệu: Không dùng SliceLast; lấy tỷ giá hiện hành vẫn phải học Bài 12.
- _(mã nội bộ P2-1)_

### Ghi nhận thay đổi giá mua tiền tệ — 8:11

- Link: https://www.youtube.com/watch?v=lYPmr3Rxi3g&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=2
- Chủ đề để dẫn: information register nhiều dimension
- Dựng từ cấu hình rỗng: Catalog Currencies, Enumeration loại giao dịch, Information register 2 dimension, Report DCS Chart
- Video làm gì: Biến thể của video trước: thêm Enumeration Mua/Bán, information register giá theo ngày với hai dimension (loại tiền, loại giao dịch), biểu đồ có filter chọn giá mua hay giá bán.
- Mốc xem nhanh: 0:00 Tạo infobase mới · 1:34 Enumeration loại giao dịch: Mua, Bán · 1:34 Information register periodic Day, Resource Rate Number(10,2) · 2:06 Dimension Currency và loại giao dịch, bật không cho rỗng · 4:46 Tạo Report DCS, Query từ register, khai báo Resource · 6:21 Filter loại giao dịch vào user settings; chạy báo cáo · 6:51 Thử xóa Resource → biểu đồ không chạy; thêm lại
- Bài giáo trình: Bài 12 (chính); Bài 3, Bài 4, Bài 18
- Đề BTL Jet: Đề 5, Đề 3
- Nhóm phù hợp: M — mức cơ bản
- Lưu ý khi giới thiệu: Trùng nhiều với video tỷ giá; có thể chỉ xem một trong hai.
- _(mã nội bộ P2-2)_

### Lưu trữ và báo cáo kết quả học tập của sinh viên — 14:56

- Link: https://www.youtube.com/watch?v=NhFE1uwi7Hw&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=3
- Chủ đề để dẫn: chấm điểm qua chứng từ và báo cáo trung bình có tô màu
- Dựng từ cấu hình rỗng: Catalog Students, Subjects; Document buổi học (tabular section); Accumulation register; Report DCS (Average, Chart, Conditional appearance)
- Video làm gì: Từ cấu hình rỗng: Catalog Students, Subjects; Document buổi học với tabular section điểm; accumulation register điểm; báo cáo DCS điểm trung bình theo môn (parameter), biểu đồ và Conditional appearance 4 mức màu.
- Mốc xem nhanh: 0:32 Tạo infobase mới · 2:40 Tạo Document buổi học: Subject + Tabular section Student, Grade (0–10) · 3:43 Nhập vài buổi học (Hệ điều hành, Toán cao cấp) · 4:46 Tạo Accumulation register: Dimensions Student, Subject; Resource Grade · 6:49 Report DCS: Query từ register, điều kiện Subject = parameter · 8:56 Settings wizard: Chart, Student làm Points, order Grade tăng dần · 10:00 Conditional appearance 4 màu theo ngưỡng 8 / 6.5 / 5; chạy báo cáo theo môn
- Bài giáo trình: Bài 18 (chính); Bài 11, Bài 3, Bài 9
- Đề BTL Jet: Đề 4, Đề 2
- Nhóm phù hợp: J M — mức trung bình
- Lưu ý khi giới thiệu: Dùng accumulation register cho điểm là lựa chọn minh họa; điểm không phải đại lượng tích lũy thật.
- _(mã nội bộ P2-3)_

### Hệ thống cho thuê xe điện — 10:40

- Link: https://www.youtube.com/watch?v=wWGXT2KSul8&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=4
- Chủ đề để dẫn: một chứng từ ghi vào hai register
- Dựng từ cấu hình rỗng: Catalog Students; Document Purchase, Rental, Return; 2 Accumulation register (Balances); Report DCS
- Video làm gì: Từ cấu hình rỗng: Catalog Students; Document nhập xe, cho thuê, trả xe; hai accumulation register (xe trong kho, xe đang cho thuê theo sinh viên); báo cáo ai đang thuê xe.
- Mốc xem nhanh: 0:32 Tạo infobase "cho thuê xe điện" · 1:37 Document Purchase (Quantity), nhập 10 xe, Post · 2:43 Document Rental (Student) · 3:15 Copy Rental → Document Return · 4:21 Accumulation register xe đang thuê: Dimension Student (Copy register) · 8:30 Chạy thử: 3 sinh viên thuê, 1 trả; kiểm tra register · 9:00 Report DCS từ Balances register đang thuê, List Student
- Bài giáo trình: Bài 11 (chính); Bài 3, Bài 18, Bài 10
- Đề BTL Jet: Đề 9, Đề 1
- Nhóm phù hợp: M J — mức cơ bản – trung bình
- Lưu ý khi giới thiệu: Không chặn cho thuê khi hết xe và không chặn một sinh viên thuê 2 xe — bài tập tốt để tự bổ sung kiểm tra số dư khi posting.
- _(mã nội bộ P2-4)_

### Tạo lập hệ thống thông tin thư viện — 24:38

- Link: https://www.youtube.com/watch?v=3DMFgUjg2Js&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=5
- Chủ đề để dẫn: mượn – trả và tạo phiếu trả từ phiếu mượn
- Dựng từ cấu hình rỗng: Catalog Readers, Books; Document mượn, trả (Input on basis); Accumulation register; Report DCS
- Video làm gì: Từ cấu hình rỗng, giải thích kỹ: Catalog Readers (Mask điện thoại), Books (Format NG= cho năm); Document mượn sách với tabular section, Document trả sách tạo "Based on" phiếu mượn; register sách đang mượn theo độc giả; báo cáo DCS có filter.
- Mốc xem nhanh: 0:00 Tạo infobase "library" · 2:05 Attribute Phone String + Mask; hiển thị form Tabs · 5:11 Nhập dữ liệu mẫu (cập nhật cấu hình infobase) · 9:25 Document cho mượn sách: Reader + Tabular section ListOfBooks (Book) · 13:01 Input on basis: trả sách dựa trên mượn sách, Filling wizard · 15:41 Accumulation register BorrowedBooks: Dimensions Book, Reader; Resource Quantity · 20:53 Report DCS từ Balances; List, group Reader, order; Filter Reader/Book trong user settings
- Bài giáo trình: Bài 11 (chính); Bài 3, Bài 9, Bài 16, Bài 18
- Đề BTL Jet: Đề 3, Đề 9
- Nhóm phù hợp: J M — mức cơ bản – trung bình
- Lưu ý khi giới thiệu: Không kiểm tra trả sách chưa mượn và không quản lý số bản sách.
- _(mã nội bộ P2-5)_

### Hệ thống thông tin cửa hàng nhỏ — 12:28

- Link: https://www.youtube.com/watch?v=zXa4pQv0LHE&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=6
- Chủ đề để dẫn: xử lý nhiều đơn hàng bằng một lệnh
- Dựng từ cấu hình rỗng: Catalog Customers, Products; Document Order, OrderProcess; Command có parameter; Filter criteria; Report
- Video làm gì: Từ cấu hình rỗng: Document Order; Document xử lý đơn có tabular section danh sách đơn; Command có parameter mở form xử lý và truyền các đơn đã chọn (OnCreateAtServer đọc Parameters); tìm chứng từ theo sản phẩm bằng Filter criteria.
- Mốc xem nhanh: 0:30 Tạo infobase mới · 2:01 Document Order: Customer + Tabular section Products (Product, Quantity) · 3:39 Document OrderProcess: Tabular section Orders (DocumentRef.Order) · 4:09 Tạo form document, handler OnCreateAtServer đọc Parameters điền Orders; Syntax check · 8:52 Chạy thử: chọn đơn hàng, bấm lệnh → mở OrderProcess đã điền đơn · 10:28 Report DCS Query từ filter criterion, parameter Product · 11:32 Settings List, order; parameter type CatalogRef.Products; chạy với "kem ốc quế"
- Bài giáo trình: Bài 14 (chính); Bài 9, Bài 16, Bài 7, Bài 18
- Đề BTL Jet: Đề 3
- Nhóm phù hợp: M D — mức nâng cao
- Lưu ý khi giới thiệu: Đoạn code transcript nghe không rõ, cần xem trực tiếp. Filter criteria (ngoài giáo trình — hãy kiểm tra lại trong Syntax assistant); cách thường dùng hơn là query vào tabular section.
- _(mã nội bộ P2-6)_

### Hạch toán sản phẩm dịch vụ — 15:54

- Link: https://www.youtube.com/watch?v=GFsS9x1bOTQ&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=7
- Chủ đề để dẫn: tách hàng hóa/dịch vụ và bật tắt tính năng bằng Functional option
- Dựng từ cấu hình rỗng: Catalog ProductsAndServices, Counterparties, Currencies; Document Sale; Constant; Functional option; Report DCS
- Video làm gì: Từ cấu hình rỗng: Catalog ProductsAndServices (IsService); Document Sale có hai tabular section Products/Services lọc bằng Choice parameters; tổng tiền tính ở BeforeWrite; Constant + Functional option ẩn/hiện đa tiền tệ; báo cáo DCS.
- Mốc xem nhanh: 0:30 Tạo infobase mới "Bài 14 hạch toán sản phẩm dịch vụ" từ cấu hình rỗng · 2:37 Nhập dữ liệu mẫu ở chế độ 1C:Enterprise (công ty, USD, sản phẩm Vinamilk, dịch vụ giao hàng) · 3:39 Document Sale: Buyer, Currency, Total Number(14,2); tabular section Products với Choice parameters IsService = False · 6:18 Copy tabular section thành Services, Choice parameters IsService = True · 8:24 Chạy thử: tạo Sale, Post and close → Total tự điền · 12:00 Report Sales (DCS): query Document.Sale, condition Currency = &Currency, Posted = True; resource Total; settings list, sort Buyer · 14:38 Parameter Currency mặc định VND; chạy báo cáo ở chế độ đơn/đa tiền tệ, thử giao dịch USD
- Bài giáo trình: Bài 15 (chính); Bài 3, Bài 4, Bài 13, Bài 16, Bài 18
- Đề BTL Jet: Đề 5
- Nhóm phù hợp: M D — mức cơ bản – trung bình
- Lưu ý khi giới thiệu: Không có register hay posting xuất kho. Tổng tiền chỉ thấy sau khi ghi (nên tính thêm trên form khi đổi dòng).
- _(mã nội bộ P2-7)_

### Hạch toán thu nhập theo doanh số — 20:00

- Link: https://www.youtube.com/watch?v=QRAzQKBCtds&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=8
- Chủ đề để dẫn: quy đổi tỷ giá khi posting bằng SliceLast
- Dựng từ cấu hình rỗng: Như video trước + Information register tỷ giá, Accumulation register thu nhập
- Video làm gì: Dựng lại bài sản phẩm/dịch vụ rồi thêm information register tỷ giá (periodic, Master) và accumulation register thu nhập; khi posting lấy tỷ giá bằng SliceLast để quy đổi sang VND.
- Mốc xem nhanh: 0:31 Tạo infobase "Bài 15", dựng lại Catalog ProductsAndServices (IsService), Counterparties, Currencies (predefined VND) · 4:12 Bật Master và Deny incomplete values cho dimension Currency; mở tỷ giá trực tiếp từ phần tử USD, nhập 23.200 · 5:15 Document Sale (Buyer, Currency, Total Number(14,2)), tabular section Products/Services với Choice parameters · 7:20 Object module, BeforeWrite tính Total; Currency Fill value = VND; chạy thử (620.000) · 11:05 Accumulation register thu nhập: dimension ProductOrService, resource Sum Number(14,2); Sale đặt Posting = Allow, Register records wizard cho Products và Services · 14:17 Query Builder trên virtual table SliceLast của register tỷ giá, SetParameter Currency/Date, Selection.Next() lấy Rate · 18:08 Report SalesIncome (DCS) từ register, resource Sum, settings list, sort tăng dần; chạy báo cáo
- Bài giáo trình: Bài 12 (chính); Bài 11, Bài 10, Bài 15, Bài 18
- Đề BTL Jet: Đề 5, Đề 2, Đề 4
- Nhóm phù hợp: M D — mức trung bình
- Lưu ý khi giới thiệu: Chạy một query tỷ giá cho mỗi dòng trong vòng lặp posting (nên gom một query). Ngày tỷ giá có thể là ngày hiện tại thay vì ngày chứng từ — kiểm tra khi xem.
- _(mã nội bộ P2-8)_

### Bắt lần khởi động đầu tiên — 9:05

- Link: https://www.youtube.com/watch?v=Q9op8HgLMtM&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=9
- Chủ đề để dẫn: xử lý lần chạy đầu tiên của ứng dụng
- Dựng từ cấu hình rỗng: Constant, Common form, Common module, Application module (OnStart)
- Video làm gì: Constant cờ khởi động, Common form thông báo, Common module server call; trong Application module, OnStart gọi server kiểm tra cờ và mở form; sau đó đặt cờ.
- Mốc xem nhanh: 0:00 Đặt bài toán: phát hiện lần khởi động đầu để mở form tham số ban đầu · 1:04 Tạo Constant kiểu Boolean · 3:12 Mở Application module, chọn event OnStart · 3:46 Tạo Common module server (Server, Server call); function Export trả Not Constants...Get() · 5:51 OnStart: If <Module>.IsFirstLaunch() Then OpenForm(...) · 7:24 Trong form tạo handler client + server, gán Constants...Set(True) · 8:26 Khởi động lại: form không còn xuất hiện
- Bài giáo trình: Bài 14 (chính); Bài 13, Bài 7, Bài 9
- Đề BTL Jet: —
- Nhóm phù hợp: M D — mức cơ bản
- Lưu ý khi giới thiệu: Cờ là theo cả infobase, không theo người dùng; nên đặt cờ sau khi người dùng hoàn tất thiết lập.
- _(mã nội bộ P2-9)_

### Hạch toán hàng hóa - Bài toán đơn giản nhất — 16:55

- Link: https://www.youtube.com/watch?v=SwgfC-uA6Eg&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=10
- Chủ đề để dẫn: nhập – xuất – tồn và chặn âm kho
- Dựng từ cấu hình rỗng: Catalog Products; Document PurchaseInvoice, Sale; Accumulation register Inventory; Report DCS
- Video làm gì: Từ cấu hình rỗng: Catalog Products; Document nhập hàng và bán hàng; accumulation register Inventory (Balances) ghi Receipt/Expense; báo cáo tồn theo ngày; chặn âm kho trong Posting (ghi trước, query số dư < 0, Cancel).
- Mốc xem nhanh: 0:31 Tạo infobase "Bài 17 hạch toán hàng hóa đơn giản" · 2:06 Copy thành Document Sale; tạo Accumulation register Inventory (Balances), resource Quantity, dimension Product · 3:10 Register records: PurchaseInvoice → Receipt, Sale → Expense qua Register records wizard · 4:14 Report Inventory (DCS) từ Inventory.Balance; parameter ReportDate (Date, format), EndOfPeriod · 7:57 Sale Posting: RegisterRecords.Write() rồi query Balance với Boundary(PointInTime, Including) · 12:08 Nếu không rỗng: Cancel = True, vòng lặp Selection.Next() → Message thiếu hàng · 15:49 Test: bán 2 khi tồn 1 → chặn post, báo thiếu 1; báo cáo vẫn tồn 1
- Bài giáo trình: Bài 11 (chính); Bài 10, Bài 18, Bài 3
- Đề BTL Jet: Đề 9, Đề 2, Đề 1
- Nhóm phù hợp: J M D — mức cơ bản – trung bình
- Lưu ý khi giới thiệu: Chưa khóa dữ liệu khi nhiều người post (managed lock (ngoài giáo trình — hãy kiểm tra lại trong Syntax assistant)). Đề bài nói "nhiều kho" nhưng phần làm chỉ theo sản phẩm.
- _(mã nội bộ P2-10)_

### Hạch toán hàng hóa - Hạch toán một kho — 20:57

- Link: https://www.youtube.com/watch?v=BD370AtszHI&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=11
- Chủ đề để dẫn: tồn kho theo từng kho (kho trên đầu chứng từ)
- Dựng từ cấu hình rỗng: Catalog Products, Warehouses; Document PurchaseInvoice, Sale; Accumulation register Inventory (Product, Warehouse); Report DCS Table
- Video làm gì: Thêm Catalog Warehouses và dimension Warehouse; mỗi chứng từ thuộc một kho (attribute ở header, Fill checking bắt buộc); chặn âm kho theo hàng + kho; báo cáo tồn Product × Warehouse.
- Mốc xem nhanh: 0:32 Catalog Products, Warehouses; nhập dữ liệu mẫu · 3:42 Thử bỏ trống Warehouse → báo lỗi; copy thành Document Sale · 4:44 Accumulation register Inventory (Balances): dimensions Product, Warehouse; resource Quantity · 5:50 Register records wizard: PurchaseInvoice Receipt, Sale Expense · 7:58 Sale Posting: Write, query Balance < 0 lọc Warehouse = &Warehouse, Product IN &Products · 14:19 Test: bán 33 sữa tươi kho Đống Đa → bị chặn · 15:21 Report cân đối hàng hóa (DCS): Table rows Product / columns Warehouse, parameter ngày báo cáo
- Bài giáo trình: Bài 11 (chính); Bài 12, Bài 10, Bài 18
- Đề BTL Jet: Đề 2, Đề 9
- Nhóm phù hợp: M D J — mức trung bình
- Lưu ý khi giới thiệu: Không khóa dữ liệu trước khi đọc số dư.
- _(mã nội bộ P2-11)_

### Hạch toán hàng hóa nhiều kho (Full) — 18:40

- Link: https://www.youtube.com/watch?v=HIAYMOepPw4&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=12
- Chủ đề để dẫn: kho trên từng dòng hàng và chặn âm theo từng kho
- Dựng từ cấu hình rỗng: Như video trước, Warehouse chuyển xuống tabular section của Sale
- Video làm gì: Dựng lại từ đầu; chứng từ bán chuyển Warehouse xuống tabular section (mỗi dòng một kho); posting và chặn âm kho theo cặp hàng – kho.
- Mốc xem nhanh: 0:00 Giới thiệu: tương tự Bài 18, dựng lại từ đầu để tham khảo đầy đủ · 1:37 Document PurchaseInvoice: tabular section Products, header Warehouse (Fill checking) · 3:09 Nhập hàng 50 đơn vị/mặt hàng vào ba kho · 4:14 Copy thành Document Sale, chuyển Warehouse xuống tabular section · 7:32 Repost chứng từ cũ, kiểm tra register · 11:52 Cancel = True + Message cho từng dòng; test bán 60 khi tồn 50 → chặn · 14:32 Report tồn kho DCS: Table Product × Warehouse, parameter ngày báo cáo
- Bài giáo trình: Bài 11 (chính); Bài 10, Bài 12, Bài 18
- Đề BTL Jet: Đề 9, Đề 2, Đề 1
- Nhóm phù hợp: M D — mức trung bình
- Lưu ý khi giới thiệu: Điều kiện Product IN … AND Warehouse IN … tách rời có thể báo thiếu nhầm cho cặp (hàng, kho) không có trong chứng từ; chuẩn hơn là lọc theo cặp (temporary table/join).
- _(mã nội bộ P2-12)_

### Hạch toán hàng hóa nhiều kho (Short) — 14:51

- Link: https://www.youtube.com/watch?v=sHl70mbjk4c&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=13
- Chủ đề để dẫn: sửa cấu trúc chứng từ đang có dữ liệu
- Dựng từ cấu hình rỗng: Load .dt từ video trước, chỉ sửa phần khác biệt
- Video làm gì: Không dựng lại: load file .dt của video "Hạch toán một kho" rồi chỉ làm phần khác: chuyển Warehouse xuống dòng, chạy lại Register records wizard, điền kho cho chứng từ cũ, repost.
- Mốc xem nhanh: 0:00 Giới thiệu: giống ví dụ 18, đổi từ bán một kho sang bán nhiều kho · 0:32 Dump infobase Bài 18 ra .dt, tạo infobase Bài 19 và load cấu hình · 3:07 Chạy lại Register records wizard cho Sale (Expense, Warehouse của dòng) · 4:10 Điền kho cho chứng từ cũ, repost; kiểm tra register qua All functions · 5:45 Sửa Posting: Write, query Balance < 0, Product IN &Products, Warehouse IN &Warehouses · 12:21 Bổ sung tồn kho để số dư dương, chạy báo cáo có sẵn · 13:54 Test bán 12 sữa chua kho Linh Đàm → chặn, báo thiếu
- Bài giáo trình: Bài 11 (chính); Bài 10
- Đề BTL Jet: Đề 9, Đề 2
- Nhóm phù hợp: M D — mức trung bình
- Lưu ý khi giới thiệu: Bắt buộc đã làm video "Hạch toán một kho"; chưa làm thì xem bản Full. Đây không phải bản tóm tắt.
- _(mã nội bộ P2-13)_

### Hạch toán hàng hóa - Theo hạn sử dụng — 13:24

- Link: https://www.youtube.com/watch?v=TBgeOMXYp0w&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=14
- Chủ đề để dẫn: tồn kho theo hạn sử dụng và xuất dần theo lô
- Dựng từ cấu hình rỗng: Catalog Products; Document PurchaseInvoice (ExpirationDate), Sale; Accumulation register Inventory (Product, ExpirationDate)
- Video làm gì: Register Inventory có thêm dimension ExpirationDate (lô = hạn dùng, không có Catalog Batch); khi bán, query batch (temporary table + join bảng ảo Balance) kiểm tra tồn còn hạn, ghi Expense lần lượt từng lô, thiếu thì Cancel.
- Mốc xem nhanh: 0:00 Bài toán: nhập/bán theo hàng + hạn dùng; bỏ lô quá hạn khi bán · 0:31 Catalog Products; Document PurchaseInvoice, tabular section Product, Quantity, ExpirationDate (Date) · 2:40 Register records wizard cho PurchaseInvoice (Receipt) · 3:13 Form có attribute SpreadsheetDocument + command client/server · 4:19 Query batch: temporary table từ tabular section, Index Product; join Inventory.Balance · 9:37 Vòng lặp xuất dần: Expense, Quantity = Min(còn phải xuất, tồn dòng), giảm biến còn lại · 12:19 RegisterRecords.Inventory.Write = True; chạy báo cáo kiểm tra: lô hết hạn còn lại trong tồn
- Bài giáo trình: Bài 11 (chính); Bài 10
- Đề BTL Jet: Đề 1
- Nhóm phù hợp: M D J — mức nâng cao
- Lưu ý khi giới thiệu: Cách "kiểm tra trước, ghi sau" khác các video trước ("ghi trước, tìm số dư âm sau"). Kiểm tra thứ tự lô (FEFO) và mốc so hạn khi xem; không khóa dữ liệu.
- _(mã nội bộ P2-14)_


---

# § video-qa-thuc-chien

# Video giải đáp tình huống thực chiến ↔ triệu chứng ↔ bài giáo trình

> Cập nhật 07/10/2026. Nguồn: playlist "Giải đáp câu hỏi của sinh viên và cộng đồng lập trình viên 1C:Enterprise" (https://www.youtube.com/playlist?list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r, 28 video, kênh Trung tâm đào tạo lập trình 1C Việt Nam). Nội dung từng video đã được kiểm chứng bằng transcript: phần "Video làm gì" là những gì video **thực sự** làm, có thể khác mô tả trong file Excel đối chiếu ban đầu.

## Cách dùng

1. Người học báo lỗi, mô tả triệu chứng hoặc hỏi "làm sao để…": **giải thích nguyên nhân và cách làm theo giáo trình trước**. Sau đó tra Mục A; nếu khớp, thêm một câu dẫn video (tối đa 2 video).
2. Câu dẫn cho người học (giống quy ước video bài giảng): "🎬 Bạn có thể tham khảo thêm về <chủ đề> của khóa tại đây: [<tên video>](<link>)" — với tình huống lỗi có thể nói "tham khảo cách xử lý <tình huống> của khóa tại đây". Dùng **tên hiển thị** trong bảng (đã bỏ "Bài N:" và hậu tố tên kênh). Không nêu số "Bài N" của video (khác số bài giáo trình), không dùng mã QA-/P1-/P2- (chỉ để tra nội bộ), không gọi là "khóa cũ".
3. Nếu thẻ video (Mục B) có "Lưu ý khi giới thiệu" liên quan tới điều người học sắp làm, nói thêm một câu ngắn (ví dụ: "video kiểm tra theo tồn hiện tại; với chứng từ ghi lùi ngày hãy dùng PointInTime như Bài 11"). Video là cách làm minh họa; nếu khác giáo trình thì theo giáo trình.
4. Có thể gợi ý tua tới mốc thời gian trong dòng "Mốc xem nhanh" ("tua tới khoảng 1:38 để xem cách đặt breakpoint").
5. Lộ trình J (BTL trên Jet): ưu tiên video có cột "Đề BTL Jet" trùng đề của nhóm; bảng theo đề ở `references/video.md#video-thuc-hanh` Mục B. Lộ trình M, D: không cần nhắc Jet.
6. Bản dành cho sinh viên: video là tài liệu công khai, được dẫn bình thường; vẫn giữ nguyên tắc gợi ý trước với bài thực hành của giáo trình.

## A. Tra theo triệu chứng / câu hỏi

### Form, sự kiện, điền tự động

| Người học nói… | Video | Bài giáo trình |
|---|---|---|
| đổi số lượng mà thành tiền không tự tính, phải sửa giá mới tính; viết procedure ...OnChange rồi mà không chạy; đặt breakpoint trong handler mà debugger không dừng | [Fix lỗi không tính toán Thành tiền khi thay đổi Số lượng](https://www.youtube.com/watch?v=LRRNf8MxoQw&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=1) (4:24) | Bài 16 |
| muốn chứng từ mới tự điền sẵn kho/điểm bán mặc định; mỗi lần tạo phiếu phải chọn lại kho | [Xây dựng các trường tự động điền](https://www.youtube.com/watch?v=8klMmoJXBCk&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=10) (2:02) | Bài 4 |
| chọn sản phẩm mà đơn vị tính không tự hiện; lấy thuộc tính của sản phẩm điền vào dòng hàng; lỗi khi đọc Product.UOM ở client | [Tự động lấy đơn vị tính của sản phẩm](https://www.youtube.com/watch?v=RKAGi62Vy5E&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=12) (8:16) | Bài 7 |
| muốn chặn nhập trùng số điện thoại / mã số thuế; báo lỗi khi tạo khách hàng đã tồn tại | [Kiểm tra dữ liệu trùng lặp](https://www.youtube.com/watch?v=603j21ItABk&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=11) (8:55) | Bài 16 |
| đã báo lỗi rồi mà vẫn lưu được dữ liệu sai; làm sao chặn không cho ghi khi dữ liệu không hợp lệ | [Hủy sự kiện đang thực thi](https://www.youtube.com/watch?v=rW40s85Gtc4&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=16) (3:18) | Bài 16 |
| chọn hãng/nhà cung cấp rồi mà danh sách sản phẩm vẫn hiện tất cả; tạo catalog mới chạy lên không sửa được, báo không đủ quyền | [Lọc dữ liệu chọn sản phẩm theo hãng](https://www.youtube.com/watch?v=EfF2acfP2Y8&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=19) (6:30) | Bài 9 |
| làm sao thêm ảnh cho sản phẩm/nhân viên; chọn ảnh xong ghi lại mở ra thì mất ảnh; bấm vào trường ảnh không có gì xảy ra | [Thêm ảnh cho các đối tượng](https://www.youtube.com/watch?v=TQNa4cveOdc&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=6) (10:04) | Bài 17 |

### Tồn kho, posting, register

| Người học nói… | Video | Bài giáo trình |
|---|---|---|
| bán vượt tồn mà chứng từ vẫn post được, tồn kho bị âm; làm sao không cho kết chuyển khi không đủ hàng | [Chặn kết chuyển khi phát hiện tồn kho âm](https://www.youtube.com/watch?v=k2uht5J1f3c&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=25) (10:03) | Bài 11 |
| muốn xem tồn kho ngay khi chọn hàng trên phiếu bán; query tồn kho trả về rỗng khi sản phẩm chưa nhập; ô số lượng bằng 0 bị trống | [Truy vấn tồn kho trong chứng từ bán hàng](https://www.youtube.com/watch?v=13817kAvhwQ&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=17) (9:53) | Bài 10 |
| tồn kho dưới mức tối thiểu thì hiện màu đỏ; conditional appearance so sánh hai cột; đặt định mức tồn kho tối thiểu | [Báo động tồn kho thấp với màu chữ hiển thị](https://www.youtube.com/watch?v=0JbOMl80lnY&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=18) (13:09) | Bài 9 |
| tích điểm cho khách khi bán hàng; trừ điểm thưởng đã dùng; khách dùng quá số điểm đang có | [Xây dựng cơ chế tích điểm thưởng](https://www.youtube.com/watch?v=0aAaQQP9fXI&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=14) (23:35) | Bài 11 |
| đã tích register vào phân hệ mà chạy không thấy; muốn mở register lên để kiểm tra posting | [Cách hiển thị biểu ghi tích lũy lên phân hệ](https://www.youtube.com/watch?v=DBJeS7LfUpY&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=4) (1:53) | Bài 9 |

### Giá và information register

| Người học nói… | Video | Bài giáo trình |
|---|---|---|
| chọn sản phẩm trên chứng từ bán mà giá không tự điền; lấy giá mới nhất theo ngày từ bảng giá thế nào | [Lấy giá tự động](https://www.youtube.com/watch?v=oMowT1e019k&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=5) (8:32) | Bài 12 |

### Báo cáo, truy vấn, bản in

| Người học nói… | Video | Bài giáo trình |
|---|---|---|
| báo cáo doanh thu – chi phí theo tháng làm thế nào; báo cáo DCS lọc từ ngày đến ngày | [Báo cáo lợi nhuận theo kỳ](https://www.youtube.com/watch?v=98gDiVV8jx0&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=8) (9:16) | Bài 18 |
| muốn báo cáo có cột chênh lệch mà không lưu vào register; tính toán cột trong query 1C thế nào | [Thực hiện tính toán đơn giản với SQL trong 1C](https://www.youtube.com/watch?v=dP21dfHxkCo&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=23) (2:59) | Bài 10 |
| chứng từ không có nút in; làm sao tạo mẫu in hóa đơn; sửa chữ trên mẫu in | [Tạo chức năng in hóa đơn chứng từ](https://www.youtube.com/watch?v=uwEBQJZG6t4&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=7) (5:31) | Bài 17 |

### Giao diện, phân hệ, màu sắc

| Người học nói… | Video | Bài giáo trình |
|---|---|---|
| tạo phân hệ/đối tượng mới mà vào không thấy gì; muốn hiện nút Tạo mới ngay trên phân hệ | [Hiển thị đối tượng Siêu dữ liệu lên Quick menu](https://www.youtube.com/watch?v=rPSNKvFEQ8E&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=21) (2:23) | Bài 14 |
| đã tích register vào phân hệ mà chạy không thấy; muốn mở register lên để kiểm tra posting | [Cách hiển thị biểu ghi tích lũy lên phân hệ](https://www.youtube.com/watch?v=DBJeS7LfUpY&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=4) (1:53) | Bài 9 |
| muốn đổi màu vàng của giao diện 1C theo màu công ty | [Thay đổi Style (màu sắc) của chương trình](https://www.youtube.com/watch?v=cgmDdh6bHMg&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=24) (2:47) | Bài 9 |

### Người dùng, phân quyền, ngôn ngữ

| Người học nói… | Video | Bài giáo trình |
|---|---|---|
| tạo user mà không thấy role nào để chọn; làm sao bắt đăng nhập khi mở 1C; tạo xong user thì Designer bắt đăng nhập | [Hướng dẫn thiết lập vai trò người dùng](https://www.youtube.com/watch?v=senxXwfjFxU&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=3) (3:38) | Bài 20 |
| làm sao cho người dùng tự đổi mật khẩu; chạy data processor mới tạo báo không đủ quyền | [Tạo chức năng sửa password với vai trò người dùng](https://www.youtube.com/watch?v=taKIdmcCmIQ&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=9) (26:39) | Bài 20 |
| muốn user Việt thấy tiếng Việt, user nước ngoài thấy tiếng Anh; đã thêm ngôn ngữ mà vẫn hiện tiếng Anh | [Tùy chỉnh ngôn ngữ theo người dùng](https://www.youtube.com/watch?v=wo7G7jSPtBE&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=26) (4:30) | Bài 20 |
| làm sao đổi giao diện 1C sang tiếng Việt; cài 1C xong không thấy tiếng Việt | [Chuyển đổi ngôn ngữ trên cấu hình 1C:Enterprise](https://www.youtube.com/watch?v=lqhWahjse2I&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=2) (1:37) | Bài 1 |

### Dữ liệu ngoài, extension, cài đặt và triển khai

| Người học nói… | Video | Bài giáo trình |
|---|---|---|
| nhập danh sách sản phẩm từ file Excel vào 1C; sau khi import file Excel bị khóa không mở được | [Kết nhập file excel vào danh mục sản phẩm](https://www.youtube.com/watch?v=DlXBXRzBJGw&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=13) (38:42) | Bài 19 |
| mang data processor sang database khác mà không cập nhật cấu hình; mở file .epf bị cảnh báo bảo mật | [Lưu bộ xử lý ngoài](https://www.youtube.com/watch?v=DTRivJSbAoI&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=15) (1:40) | Bài 19 |
| muốn thêm báo cáo vào cấu hình chuẩn mà không sửa cấu hình gốc; tạo extension xong không thấy báo cáo; mang extension sang database khác | [Extension (Phần mở rộng) trong 1C:Enterprise](https://www.youtube.com/watch?v=T_DEaA1p_bA&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=22) (6:33) | bài Extensions |
| gửi bài/infobase cho thầy cô hoặc bạn cùng nhóm thế nào; chép database sang máy khác | [Kết xuất kết nhập cấu hình bằng file *.1CD](https://www.youtube.com/watch?v=3X0EAToibUg&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=27) (3:29) | Bài 1 |
| publish xong mở trình duyệt báo lỗi; muốn truy cập 1C qua trình duyệt từ máy khác | [Hướng dẫn publish Infobase 1C:Enterprise lên web server](https://www.youtube.com/watch?v=P_bwSfxAV8I&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=28) (7:21) | Bài 1 |
| muốn xem thử phần mềm 1C mà không cài đặt | [Hướng dẫn truy cập bản dùng thử 1C:AccountingSuite](https://www.youtube.com/watch?v=8Vmkv3KP5ek&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=20) (1:16) | Bài 1 |

### Tình huống có cách làm trong chuỗi video thực hành (xây từ cấu hình rỗng)

| Người học cần… | Video | Bài giáo trình |
|---|---|---|
| một chứng từ phải ghi vào hai register | [Hệ thống cho thuê xe điện](https://www.youtube.com/watch?v=wWGXT2KSul8&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=4) (10:40) | Bài 11 |
| tạo phiếu trả/phiếu thực hiện từ phiếu mượn/phiếu đặt mà không nhập lại | [Lưu trữ thông tin các chuyến du lịch](https://www.youtube.com/watch?v=PwqP4GODNrY&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=6) (13:15) · [Tạo lập hệ thống thông tin thư viện](https://www.youtube.com/watch?v=3DMFgUjg2Js&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=5) (24:38) | Bài 11, Bài 3 |
| hiện số dư quỹ/tồn hiện tại lên form chứng từ | [Ghi nhận luân chuyển dòng tiền](https://www.youtube.com/watch?v=YzhM76Wy9fk&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=7) (18:29) | Bài 11 |
| phiếu thu và phiếu chi phải đánh số liên tục, mỗi năm đánh lại | [Ghi nhận luân chuyển dòng tiền](https://www.youtube.com/watch?v=YzhM76Wy9fk&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=7) (18:29) | Bài 11 |
| xem chung nhiều loại chứng từ trong một danh sách | [Ghi nhận luân chuyển dòng tiền](https://www.youtube.com/watch?v=YzhM76Wy9fk&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=7) (18:29) | Bài 11 |
| năm hiện "2 000" có dấu cách / định dạng số trên form | [Tạo lập hệ thống thông tin thư viện](https://www.youtube.com/watch?v=3DMFgUjg2Js&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=5) (24:38) | Bài 11 |
| nhập số điện thoại theo mẫu cố định (Mask) | [Lưu trữ thông tin sinh viên và môn học](https://www.youtube.com/watch?v=UGXVLOKRaGw&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=4) (12:19) · [Tạo lập hệ thống thông tin thư viện](https://www.youtube.com/watch?v=3DMFgUjg2Js&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=5) (24:38) | Bài 11, Bài 3 |
| danh mục con thuộc về một phần tử khác (Owner) | [Lưu trữ thông tin nhân viên](https://www.youtube.com/watch?v=WF19J3tct0I&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=5) (9:37) | Bài 4 |
| lưu lịch sử thay đổi theo tháng/ngày (lương, tỷ giá, giá) | [Lưu trữ thông tin nhân viên](https://www.youtube.com/watch?v=WF19J3tct0I&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=5) (9:37) · [Ghi nhận thay đổi tỷ giá hối đoái](https://www.youtube.com/watch?v=9_m7XqHPZlA&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=1) (9:04) | Bài 12, Bài 4 |
| chặn âm kho theo từng kho, kho nằm trên từng dòng hàng | [Hạch toán hàng hóa - Hạch toán một kho](https://www.youtube.com/watch?v=BD370AtszHI&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=11) (20:57) · [Hạch toán hàng hóa nhiều kho (Full)](https://www.youtube.com/watch?v=HIAYMOepPw4&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=12) (18:40) | Bài 11 |
| xuất hàng theo hạn sử dụng, không bán lô quá hạn | [Hạch toán hàng hóa - Theo hạn sử dụng](https://www.youtube.com/watch?v=TBgeOMXYp0w&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=14) (13:24) | Bài 11 |
| ẩn/hiện một tính năng bằng tùy chọn (Functional option) | [Hạch toán sản phẩm dịch vụ](https://www.youtube.com/watch?v=GFsS9x1bOTQ&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=7) (15:54) | Bài 15 |
| quy đổi ngoại tệ theo tỷ giá ngày chứng từ khi posting | [Hạch toán thu nhập theo doanh số](https://www.youtube.com/watch?v=QRAzQKBCtds&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=8) (20:00) | Bài 12 |
| chọn nhiều đơn trong danh sách rồi bấm một nút xử lý | [Hệ thống thông tin cửa hàng nhỏ](https://www.youtube.com/watch?v=zXa4pQv0LHE&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=6) (12:28) | Bài 14 |
| làm gì đó khi ứng dụng chạy lần đầu | [Bắt lần khởi động đầu tiên](https://www.youtube.com/watch?v=Q9op8HgLMtM&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=9) (9:05) | Bài 14 |
| đổi cấu trúc chứng từ khi infobase đã có dữ liệu | [Hạch toán hàng hóa nhiều kho (Short)](https://www.youtube.com/watch?v=sHl70mbjk4c&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=13) (14:51) | Bài 11 |

Thẻ chi tiết của các video thực hành: `references/video.md#video-thuc-hanh`.

## B. Thẻ video (theo thứ tự trong playlist)

### Fix lỗi không tính toán Thành tiền khi thay đổi Số lượng — 4:24

- Link: https://www.youtube.com/watch?v=LRRNf8MxoQw&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=1
- Chủ đề để dẫn: cách tìm lỗi sự kiện OnChange không chạy
- Video làm gì: Tái hiện lỗi đổi Số lượng mà Thành tiền không tính, đặt Breakpoint để thấy handler của cột Quantity không bao giờ được gọi: procedure có trong form module nhưng chưa được gắn vào sự kiện OnChange của phần tử. Sửa bằng cách tạo handler qua bảng Events của phần tử.
- Mốc xem nhanh: 0:00 Mô tả lỗi: thêm sản phẩm, nhập số lượng nhưng Thành tiền không tính · 0:35 Tái hiện: chỉ khi sửa Giá mới tính ra Thành tiền · 1:07 Mở form module của chứng từ, rà các hàm PriceOnChange, hàm tính toán, CalculateTotal · 2:10 Breakpoint ở Quantity không dừng; thử breakpoint ở Price thì dừng, dùng Step into theo dõi luồng · 2:41 Suy luận: handler Quantity chưa được hệ thống "nhận" — xóa procedure cũ · 3:11 Tạo lại handler qua Events của phần tử (OnChange), dán lại code · 3:43 Chạy thử: đổi số lượng đã tự tính Thành tiền; kết luận phải tạo handler qua Events để hệ thống gắn đúng sự kiện
- Người học thường hỏi: "đổi số lượng mà thành tiền không tự tính, phải sửa giá mới tính"; "viết procedure ...OnChange rồi mà không chạy"; "đặt breakpoint trong handler mà debugger không dừng"
- Bài giáo trình: Bài 16 (chính); Bài 8, Bài 9
- Đề BTL Jet: Đề 3, Đề 5, Đề 9
- Nhóm phù hợp: J M D — mức cơ bản
- Lưu ý khi giới thiệu: Video xóa rồi tạo lại procedure; thật ra chỉ cần mở Properties → Events của phần tử và chọn đúng procedure. Tên procedure trùng tên chuẩn không tự gắn vào sự kiện.
- _(mã nội bộ QA-1)_

### Chuyển đổi ngôn ngữ trên cấu hình 1C:Enterprise — 1:37

- Link: https://www.youtube.com/watch?v=lqhWahjse2I&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=2
- Chủ đề để dẫn: cách đổi giao diện nền tảng sang tiếng Việt
- Video làm gì: Sửa bộ cài nền tảng (Change/Modify trong Windows), thêm Vietnamese vào ngôn ngữ giao diện rồi cài lại; Designer hiển thị tiếng Việt. Không thao tác object Languages của cấu hình.
- Mốc xem nhanh: 0:00 Giao diện ban đầu tiếng Anh trên bản training version · 0:31 Chuột phải vào 1C:Enterprise trong danh sách chương trình đã cài, chọn Change/Modify bộ cài; chọn đúng bản platform · 0:31 Trong bước chọn ngôn ngữ giao diện: thêm Vietnamese (ngoài English) · 1:03 Install, Finish · 1:03 Mở lại Designer: giao diện và cây cấu hình hiển thị tiếng Việt
- Người học thường hỏi: "làm sao đổi giao diện 1C sang tiếng Việt"; "cài 1C xong không thấy tiếng Việt"
- Bài giáo trình: Bài 1 (chính)
- Đề BTL Jet: —
- Nhóm phù hợp: J — mức cơ bản
- Lưu ý khi giới thiệu: Chỉ đổi giao diện của nền tảng; tên các object trong cấu hình không tự dịch (xem video "Tùy chỉnh ngôn ngữ theo người dùng"). Giáo trình dùng thuật ngữ Designer tiếng Anh, nên giữ giao diện tiếng Anh khi học theo tài liệu.
- _(mã nội bộ QA-2)_

### Hướng dẫn thiết lập vai trò người dùng — 3:38

- Link: https://www.youtube.com/watch?v=senxXwfjFxU&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=3
- Chủ đề để dẫn: tạo role và user đầu tiên
- Video làm gì: Tạo role Administrator bằng "Set all rights", Update database configuration, tạo user admin và gán role; giải thích các kiểu xác thực. Sau đó cả 1C:Enterprise và Designer đều yêu cầu đăng nhập.
- Mốc xem nhanh: 0:00 Mở infobase bằng Designer, chưa có user nên không cần đăng nhập · 0:00 Common > Roles: tạo role Administrator đầu tiên · 0:32 Mở Rights, chọn Set all rights; nhắc phải Update database configuration · 1:35 Administration > Users: tạo user admin, gán role Administrator · 1:35 Giải thích ô mật khẩu/xác thực bị mờ trên bản training version · 2:06 Chạy thử 1C:Enterprise mode: yêu cầu đăng nhập · 2:37 Mở lại Designer cũng yêu cầu đăng nhập; giải thích 1C:Enterprise / OS / OpenID authentication
- Người học thường hỏi: "tạo user mà không thấy role nào để chọn"; "làm sao bắt đăng nhập khi mở 1C"; "tạo xong user thì Designer bắt đăng nhập"
- Bài giáo trình: Bài 20 (chính)
- Đề BTL Jet: Đề 6
- Nhóm phù hợp: J M D — mức cơ bản
- Lưu ý khi giới thiệu: Video chỉ tạo role toàn quyền; phân quyền theo từng object (Read/Insert/Update…) xem Bài 20. User đầu tiên phải có role có quyền Administration. Phần OpenID được giải thích đơn giản hóa.
- _(mã nội bộ QA-3)_

### Cách hiển thị biểu ghi tích lũy lên phân hệ — 1:53

- Link: https://www.youtube.com/watch?v=DBJeS7LfUpY&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=4
- Chủ đề để dẫn: cách hiện register lên phân hệ
- Video làm gì: Đưa accumulation register vào Content của subsystem nhưng chạy vẫn không thấy; mở Command interface của subsystem và bật Visibility cho lệnh danh sách của register thì register mới hiện.
- Mốc xem nhanh: 0:00 Mục tiêu: hiển thị accumulation register Revenues trong phân hệ · 0:31 Cách thông thường: thêm register vào Content của subsystem · 0:31 Chạy thử: register vẫn không xuất hiện · 1:03 Mở Command interface của subsystem, tìm lệnh của register, bật Visibility · 1:33 Chạy lại: Revenues hiện trong phân hệ; lưu ý thực tế không đưa register cho người dùng
- Người học thường hỏi: "đã tích register vào phân hệ mà chạy không thấy"; "muốn mở register lên để kiểm tra posting"
- Bài giáo trình: Bài 9 (chính); Bài 14, Bài 11
- Đề BTL Jet: Đề 1, Đề 2, Đề 7, Đề 9
- Nhóm phù hợp: J M — mức cơ bản
- Lưu ý khi giới thiệu: Lệnh của register ẩn mặc định là có chủ ý; người dùng cuối nên xem qua báo cáo. Nếu vẫn không thấy, kiểm tra role có quyền View trên register.
- _(mã nội bộ QA-4)_

### Lấy giá tự động — 8:32

- Link: https://www.youtube.com/watch?v=oMowT1e019k&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=5
- Chủ đề để dẫn: tự điền giá theo bảng giá
- Video làm gì: Tạo information register Price (Periodicity = Day, dimension Product, resource Price), nhập bảng giá; trong form chứng từ bán, khi chọn Product thì gọi hàm server dùng InformationRegisters.Price.GetLast(Object.Date, Filter) để điền giá và tính lại thành tiền.
- Mốc xem nhanh: 0:30 Tạo Information register Price: Periodicity Day, Write mode Independent · 1:01 Dimension Product (CatalogRef Products), resource Price (Number) · 2:02 Mở form module chứng từ Sales, tạo hàm chạy phía server GetPrice(Product) · 3:05 Tạo Structure Filter, key = tên dimension Product · 4:06 Gọi GetLast(Object.Date, Filter) lấy bản ghi gần nhất trước ngày chứng từ, Return Row.Price · 7:20 Gán giá vào dòng hiện tại, tính lại Amount và tổng hóa đơn · 7:50 Chạy thử: chọn sản phẩm, giá tự điền
- Người học thường hỏi: "chọn sản phẩm trên chứng từ bán mà giá không tự điền"; "lấy giá mới nhất theo ngày từ bảng giá thế nào"
- Bài giáo trình: Bài 12 (chính); Bài 16, Bài 7
- Đề BTL Jet: Đề 5, Đề 3
- Nhóm phù hợp: M J D — mức trung bình
- Lưu ý khi giới thiệu: Hàm dùng &AtServer; chỉ cần &AtServerNoContext và truyền Product, Date. Khi điền nhiều dòng nên dùng một query bảng ảo SliceLast (cách của Bài 12).
- _(mã nội bộ QA-5)_

### Thêm ảnh cho các đối tượng — 10:04

- Link: https://www.youtube.com/watch?v=TQNa4cveOdc&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=6
- Chủ đề để dẫn: lưu và hiển thị ảnh cho sản phẩm
- Video làm gì: Thêm form attribute địa chỉ ảnh hiển thị bằng Picture field, handler Click gọi BeginPutFile chọn ảnh vào temporary storage; catalog có attribute kiểu ValueStorage, ghi ảnh trong BeforeWriteAtServer và nạp lại khi mở form.
- Mốc xem nhanh: 0:00 Mục tiêu: thêm ảnh cho sản phẩm/nhân sự; tạo item form nếu chưa có · 1:04 Kiểu hiển thị Picture field; NonselectedPictureText; bật Hyperlink · 1:34 Tạo handler Click của picture field · 2:04 New NotifyDescription + BeginPutFile (Interactive True, UUID form), StandardProcessing = False · 5:41 Form events BeforeWriteAtServer và OnCreateAtServer · 8:18 OnCreateAtServer: GetURL(Object.Ref, "<attribute>") để hiển thị lại ảnh · 9:21 Chạy thử, chỉnh PictureSize = Proportionally
- Người học thường hỏi: "làm sao thêm ảnh cho sản phẩm/nhân viên"; "chọn ảnh xong ghi lại mở ra thì mất ảnh"; "bấm vào trường ảnh không có gì xảy ra"
- Bài giáo trình: Bài 17 (chính); Bài 9, Bài 16, Bài 7
- Đề BTL Jet: —
- Nhóm phù hợp: M D — mức trung bình
- Lưu ý khi giới thiệu: Đối chiếu thứ tự tham số BeginPutFile trong Syntax assistant. Ảnh lớn hoặc nhiều file nên dùng cơ chế file (Bài 23).
- _(mã nội bộ QA-6)_

### Tạo chức năng in hóa đơn chứng từ — 5:31

- Link: https://www.youtube.com/watch?v=uwEBQJZG6t4&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=7
- Chủ đề để dẫn: tạo mẫu in chứng từ bằng Print wizard
- Video làm gì: Dùng Print wizard tạo command Print và template cho chứng từ bán (header, bảng hàng, footer), rồi sửa template SpreadsheetDocument: ô parameter và ô chữ cố định, in đậm, đổi màu.
- Mốc xem nhanh: 0:00 Vấn đề: cần in hóa đơn bán hàng gửi khách · 0:31 Mở Print wizard trên chứng từ Sales, đặt tên lệnh in · 1:02 Chọn trường header: Number, Date · 1:33 Chọn footer: Total (và một trường khác, transcript không rõ) · 2:05 Wizard tạo command Print và template; ghim lệnh in lên form chứng từ · 3:09 Chỉnh template: ô parameter vs ô text, sửa nhãn, in đậm, màu, thêm tên doanh nghiệp · 4:43 Chạy thử bản in đã sửa
- Người học thường hỏi: "chứng từ không có nút in"; "làm sao tạo mẫu in hóa đơn"; "sửa chữ trên mẫu in"
- Bài giáo trình: Bài 17 (chính); Bài 22, Bài 14
- Đề BTL Jet: Đề 3, Đề 9, Đề 7
- Nhóm phù hợp: J M D — mức cơ bản
- Lưu ý khi giới thiệu: Print wizard sinh code in kiểu cũ. Jet dùng SSL nên trên Jet hãy đăng ký lệnh in qua Print subsystem (Bài 22).
- _(mã nội bộ QA-7)_

### Báo cáo lợi nhuận theo kỳ — 9:16

- Link: https://www.youtube.com/watch?v=98gDiVV8jx0&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=8
- Chủ đề để dẫn: báo cáo DCS theo kỳ
- Video làm gì: Tạo accumulation register (loại Balances, một resource), chứng từ bán ghi Receipt, chứng từ mua ghi Expense; báo cáo DCS lấy số liệu từ bảng ảo của register với tham số từ ngày – đến ngày.
- Mốc xem nhanh: 0:33 Bối cảnh: chứng từ Sales ghi doanh thu, Purchase ghi chi phí · 1:35 Register records cho Sales: Receipt Profit = tổng hóa đơn · 2:39 Register records cho Purchase: Expense Profit (có nhầm lẫn rồi sửa lại [3:10]) · 3:41 Repost lại toàn bộ chứng từ, xem register · 5:43 Đặt tên trường Profit/Revenue/Cost; Settings: Selected fields · 7:19 Dùng tham số kỳ (BeginOfPeriod/EndOfPeriod) để báo cáo theo kỳ; tạo thêm chứng từ thử · 8:20 Kết quả theo kỳ: bán 6,8 triệu, mua 2 triệu, lợi nhuận 4,8 triệu
- Người học thường hỏi: "báo cáo doanh thu – chi phí theo tháng làm thế nào"; "báo cáo DCS lọc từ ngày đến ngày"
- Bài giáo trình: Bài 18 (chính); Bài 11, Bài 10
- Đề BTL Jet: Đề 8, Đề 7, Đề 4
- Nhóm phù hợp: M J — mức trung bình
- Lưu ý khi giới thiệu: "Lợi nhuận = tổng bán − tổng mua" chỉ để minh họa kỹ thuật, không đúng nghiệp vụ (cần giá vốn hàng bán). Số liệu phát sinh theo kỳ hợp với register loại Turnovers hơn.
- _(mã nội bộ QA-8)_

### Tạo chức năng sửa password với vai trò người dùng — 26:39

- Link: https://www.youtube.com/watch?v=taKIdmcCmIQ&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=9
- Chủ đề để dẫn: cho người dùng tự đổi mật khẩu
- Video làm gì: Tạo data processor có form đổi mật khẩu (PasswordMode), hàm &AtServerNoContext kiểm tra InfoBaseUsers.CurrentUser() rồi ghi mật khẩu mới; nhắc cấp quyền cho role trên data processor mới.
- Mốc xem nhanh: 0:00 Lưu ý: chức năng khó thực hành trên training version, cần bản có bản quyền (theo lời giảng viên) · 1:37 Tạo user admin: bỏ "cannot change password", 1C:Enterprise authentication, Show in list · 3:43 Tạo Data processor ChangePassword và form qua wizard · 4:15 Form attributes: cờ cho phép đổi, NewPassword, ConfirmNewPassword (String, password mode); command ChangePassword · 8:27 Hàm &AtServerNoContext kiểm tra user: InfoBaseUsers.CurrentUser(), CannotChangePassword, StandardAuthentication · 15:21 OnCreateAtServer, OnOpen (ShowMessageBox + Cancel), handler command (ClearMessages, so khớp, Message) · 24:56 Chạy thử: sai xác nhận báo lỗi; đúng thì đổi thành công; đăng nhập lại bằng mật khẩu mới
- Người học thường hỏi: "làm sao cho người dùng tự đổi mật khẩu"; "chạy data processor mới tạo báo không đủ quyền"
- Bài giáo trình: Bài 20 (chính); Bài 19, Bài 7, Bài 16
- Đề BTL Jet: —
- Nhóm phù hợp: D — mức nâng cao
- Lưu ý khi giới thiệu: Video chỉ thử với user toàn quyền; user thường không ghi được InfoBaseUser nếu không bật privileged mode (SetPrivilegedMode — Bài 20) và phải kiểm soát chặt. Nền tảng/SSL đã có sẵn chức năng đổi mật khẩu.
- _(mã nội bộ QA-9)_

### Xây dựng các trường tự động điền — 2:02

- Link: https://www.youtube.com/watch?v=8klMmoJXBCk&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=10
- Chủ đề để dẫn: giá trị mặc định khi tạo chứng từ
- Video làm gì: Không viết code: tạo phần tử Predefined trong catalog điểm bán và đặt thuộc tính Fill value của attribute trên Document Sale trỏ tới phần tử đó; chứng từ mới tự điền sẵn điểm bán.
- Mốc xem nhanh: 0:00 Nêu yêu cầu: chứng từ bán hàng mới cần điểm bán mặc định (cơ sở 1 / trụ sở chính) · 0:31 Vào Catalog Điểm bán, mở Predefined để tạo phần tử xác định trước · 1:04 Nhập phần tử predefined (tên "...supermarket"); sang Document Sale, attribute POS, đặt thuộc tính Fill value · 1:35 Chạy thử: tạo chứng từ bán hàng mới, điểm bán tự hiển thị giá trị mặc định
- Người học thường hỏi: "muốn chứng từ mới tự điền sẵn kho/điểm bán mặc định"; "mỗi lần tạo phiếu phải chọn lại kho"
- Bài giáo trình: Bài 4 (chính); Bài 3, Bài 16
- Đề BTL Jet: Đề 2, Đề 9
- Nhóm phù hợp: J M — mức cơ bản
- Lưu ý khi giới thiệu: Fill value (ngoài giáo trình — hãy kiểm tra lại trong Syntax assistant) chỉ áp dụng khi tạo object mới. Mặc định khác nhau theo người dùng thì phải điền bằng code (OnCreateAtServer / Filling — Bài 16).
- _(mã nội bộ QA-10)_

### Kiểm tra dữ liệu trùng lặp — 8:55

- Link: https://www.youtube.com/watch?v=603j21ItABk&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=11
- Chủ đề để dẫn: cảnh báo dữ liệu trùng
- Video làm gì: Hàm CheckDuplicate dùng Catalogs.Customer.FindByAttribute("PhoneNumber", …) gọi trong OnChange, BeforeClose, BeforeWrite của form khách hàng; trùng thì hiện thông báo. Video nói rõ mới cảnh báo, chưa chặn ghi.
- Mốc xem nhanh: 0:00 Đặt bài toán: kiểm tra trùng số điện thoại khách hàng trong Catalog Customer · 1:03 Demo: chưa có kiểm tra thì vẫn tạo được khách hàng trùng số · 2:06 Function CheckDuplicate(PhoneNumber), dùng Catalogs.Customer.FindByAttribute với tên attribute dạng chuỗi · 3:40 Kiểm tra kết quả rỗng (IsEmpty) để trả về False (không trùng) / True (trùng) · 4:12 Gắn vào các sự kiện: OnChange của trường PhoneNumber, BeforeClose, BeforeWrite của form · 7:18 Chạy thử: đổi số điện thoại trùng thì hiện cảnh báo · 8:23 Kết luận: mới phát hiện trùng, chưa ngăn được việc ghi
- Người học thường hỏi: "muốn chặn nhập trùng số điện thoại / mã số thuế"; "báo lỗi khi tạo khách hàng đã tồn tại"
- Bài giáo trình: Bài 16 (chính); Bài 12, Bài 7
- Đề BTL Jet: Đề 4
- Nhóm phù hợp: M D — mức cơ bản
- Lưu ý khi giới thiệu: FindByAttribute không loại trừ chính khách hàng đang sửa, nên sửa và ghi lại khách hàng cũ sẽ bị báo trùng nhầm — cần so với Object.Ref. Muốn chặn ghi xem video "Hủy sự kiện đang thực thi"; nơi chuẩn để kiểm tra là FillCheckProcessing/BeforeWrite của object (Bài 12).
- _(mã nội bộ QA-11)_

### Tự động lấy đơn vị tính của sản phẩm — 8:16

- Link: https://www.youtube.com/watch?v=RKAGi62Vy5E&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=12
- Chủ đề để dẫn: điền thuộc tính sản phẩm vào dòng chứng từ
- Video làm gì: Tạo catalog đơn vị tính, thêm attribute vào Products và cột vào bảng hàng của Document Sale; trong OnChange của cột Product gọi hàm server trả về Product.UOM rồi gán vào dòng hiện tại. Có xử lý lỗi gọi sai context.
- Mốc xem nhanh: 0:00 Nêu bài toán: đổi sản phẩm trên dòng chứng từ Sale thì đơn vị tính đổi theo · 0:31 Tạo Catalog đơn vị tính (UOM) · 2:05 Đưa catalog vào subsystem, cấp quyền cho role admin, nhập dữ liệu đơn vị tính · 3:07 Kéo trường UOM vào item form sản phẩm, nhập sản phẩm thử (bánh phở = kg, mì chính) · 4:11 Thêm cột UOM vào bảng hàng trên form Sale; viết function GetUOM(Product) chạy ở server · 6:47 Sửa lỗi directive (context/no context), kiểm tra cú pháp · 7:22 Chạy thử: chọn sản phẩm, đơn vị tính tự điền
- Người học thường hỏi: "chọn sản phẩm mà đơn vị tính không tự hiện"; "lấy thuộc tính của sản phẩm điền vào dòng hàng"; "lỗi khi đọc Product.UOM ở client"
- Bài giáo trình: Bài 7 (chính); Bài 3, Bài 16, Bài 9, Bài 20
- Đề BTL Jet: Đề 1, Đề 3, Đề 5
- Nhóm phù hợp: M D J — mức cơ bản
- Lưu ý khi giới thiệu: Chỉ đọc một thuộc tính thì dùng &AtServerNoContext; kiểm tra CurrentData <> Undefined trước khi gán.
- _(mã nội bộ QA-12)_

### Kết nhập file excel vào danh mục sản phẩm — 38:42

- Link: https://www.youtube.com/watch?v=DlXBXRzBJGw&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=13
- Chủ đề để dẫn: nhập dữ liệu từ Excel
- Video làm gì: Data processor trong cấu hình: chọn file bằng FileDialog, mở bằng COMObject("Excel.Application"), đọc từng dòng tạo phần tử Catalogs.Products, tự tạo đơn vị tính nếu chưa có, đóng Excel.
- Mốc xem nhanh: 0:00 Giới thiệu file Excel mẫu (STT, Description, UOM) và mục tiêu nhập vào danh mục sản phẩm · 2:05 Tạo form, attribute ExcelFile kiểu String, trường nhập có ChoiceButton · 3:11 Sự kiện StartChoice: New FileDialog(FileDialogMode.Open), Title, Filter cho xls/xlsx · 7:30 Nếu chọn được file thì gán FullFileName vào ExcelFile; chạy thử hộp thoại chọn file · 12:12 Mở Sheets(1), xác định phiên bản Excel để đếm số dòng/cột ([14:17]–[17:59]) · 23:46 Vòng lặp từ dòng 2: CreateItem sản phẩm, đọc từng ô, gán Description; tìm/tạo mới UOM ([27:37]–[32:22]) · 33:26 Write sản phẩm; DisplayAlerts = False, Excel.Quit(); [35:01] gắn vào command; [36:35]–[37:36] sửa lỗi sai tên, chạy thành công
- Người học thường hỏi: "nhập danh sách sản phẩm từ file Excel vào 1C"; "sau khi import file Excel bị khóa không mở được"
- Bài giáo trình: Bài 19 (chính); Bài 7, Bài 12, Bài 23
- Đề BTL Jet: Đề 2, Đề 9
- Nhóm phù hợp: D M — mức nâng cao
- Lưu ý khi giới thiệu: COM Excel chạy trên server: chỉ ổn ở file infobase trên máy có cài Excel; client-server phải chuyển file lên server. Không kiểm tra trùng nên chạy lại sẽ nhân đôi dữ liệu. Cách của giáo trình (Bài 19) là đọc file vào SpreadsheetDocument.
- _(mã nội bộ QA-13)_

### Xây dựng cơ chế tích điểm thưởng — 23:35

- Link: https://www.youtube.com/watch?v=0aAaQQP9fXI&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=14
- Chủ đề để dẫn: tích và trừ điểm thưởng qua register
- Video làm gì: Accumulation register điểm thưởng (Balances, dimension Customer); chứng từ bán ghi Receipt điểm theo số tiền và Expense điểm đã dùng; báo cáo số dư điểm; trên form giới hạn số điểm được dùng bằng query số dư.
- Mốc xem nhanh: 0:30 Đặt bài toán: 1.000 đồng = 1 điểm, khách dùng điểm để trừ tiền · 1:32 Thêm register vào Register records của Document Sale, Register records wizard: điểm = tiền phải trả / 1000 · 2:35 Tạo báo cáo từ bảng ảo Balance (Customer, điểm Balance), đưa vào subsystem, cấp quyền admin · 4:09 Đăng lại các chứng từ Sale, kiểm tra báo cáo (64 + 21 = 85) · 7:50 Tính điểm nhận thêm trong procedure tính tiền phải trả · 14:38 Nếu dùng vượt điểm tối đa thì báo và đặt về 0; trừ điểm × 1000 vào tiền phải trả; sửa lỗi thiếu EndIf · 21:33 Thêm movement Expense (RecordType.Expense) trong Posting để trừ điểm đã dùng; [22:05] kiểm tra báo cáo 465
- Người học thường hỏi: "tích điểm cho khách khi bán hàng"; "trừ điểm thưởng đã dùng"; "khách dùng quá số điểm đang có"
- Bài giáo trình: Bài 11 (chính); Bài 10, Bài 18, Bài 16
- Đề BTL Jet: Đề 5, Đề 7
- Nhóm phù hợp: M D — mức trung bình – nâng cao
- Lưu ý khi giới thiệu: Giới hạn điểm chỉ kiểm tra trên form; posting chưa chặn số dư âm. Query số dư không truyền Period nên mở lại chứng từ đã post thì số dư đã gồm chính nó.
- _(mã nội bộ QA-14)_

### Lưu bộ xử lý ngoài — 1:40

- Link: https://www.youtube.com/watch?v=DTRivJSbAoI&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=15
- Chủ đề để dẫn: bộ xử lý ngoài (.epf)
- Video làm gì: Lưu một data processor của cấu hình thành file bộ xử lý ngoài, mở bằng File → Open trong 1C:Enterprise ở cấu hình khác (có cảnh báo bảo mật); mở file trong Designer để xem code.
- Mốc xem nhanh: 0:00 Mục tiêu: lưu data processor trong cấu hình ra file để dùng ở cấu hình khác · 0:00 Chọn data processor trong cây cấu hình, dùng chức năng lưu thành external data processor · 0:31 Lưu file ra Desktop · 1:03 Mở file trong 1C:Enterprise mode, chấp nhận cảnh báo bảo mật, chạy được · 1:03 Mở file trong Designer để xem form và module code
- Người học thường hỏi: "mang data processor sang database khác mà không cập nhật cấu hình"; "mở file .epf bị cảnh báo bảo mật"
- Bài giáo trình: Bài 19 (chính); Bài 21, Bài 20
- Đề BTL Jet: —
- Nhóm phù hợp: D M — mức cơ bản
- Lưu ý khi giới thiệu: Người dùng cần quyền mở external data processor. Trên cấu hình dùng SSL (như Jet) nên đăng ký qua Additional reports and data processors (Bài 21).
- _(mã nội bộ QA-15)_

### Hủy sự kiện đang thực thi — 3:18

- Link: https://www.youtube.com/watch?v=rW40s85Gtc4&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=16
- Chủ đề để dẫn: chặn ghi bằng Cancel = True
- Video làm gì: Tiếp video kiểm tra trùng: trong BeforeWrite của form khách hàng, khi trùng thì gán Cancel = True; giải thích handler có tham số Cancel thì hủy được hành động. Ghi khách hàng trùng bị chặn.
- Mốc xem nhanh: 0:00 Nhắc lại ví dụ kiểm tra trùng số điện thoại khách hàng · 0:31 Demo: hệ thống báo trùng nhưng vẫn ghi đối tượng · 1:03 Mục tiêu: chặn sự kiện ghi để không cho đối tượng sai vào database · 1:34 Mở module form Customer, xem CheckDuplicate, OnChange, BeforeClose, BeforeWrite · 2:04 Giải thích tham số Cancel; gán Cancel = True trong BeforeWrite khi trùng · 2:43 Chạy thử: Save and close bị chặn, khách hàng trùng không được ghi
- Người học thường hỏi: "đã báo lỗi rồi mà vẫn lưu được dữ liệu sai"; "làm sao chặn không cho ghi khi dữ liệu không hợp lệ"
- Bài giáo trình: Bài 16 (chính); Bài 12
- Đề BTL Jet: Đề 4, Đề 7
- Nhóm phù hợp: J M D — mức cơ bản
- Lưu ý khi giới thiệu: Cancel trong BeforeWrite của form chỉ chặn khi ghi từ form; muốn chặn mọi đường ghi (code, import) đặt kiểm tra ở object module hoặc FillCheckProcessing (Bài 12). Vẫn còn lỗi báo trùng nhầm của video trước.
- _(mã nội bộ QA-16)_

### Truy vấn tồn kho trong chứng từ bán hàng — 9:53

- Link: https://www.youtube.com/watch?v=13817kAvhwQ&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=17
- Chủ đề để dẫn: hiển thị tồn kho khi chọn hàng
- Video làm gì: Thêm cột tồn kho vào bảng hàng của chứng từ bán; khi chọn Product gọi hàm server chạy query trên bảng ảo Balance của register tồn kho theo sản phẩm và điểm bán; không có bản ghi thì trả 0; chỉnh Format để hiện số 0.
- Mốc xem nhanh: 0:00 Đặt bài toán: chứng từ bán hàng cần cột tồn kho khi chọn mặt hàng · 0:32 Thêm attribute tồn kho (Number) vào tabular section, đặt cạnh Quantity trên form · 3:11 Thêm tham số Location; dùng Query builder lấy bảng Balance của register tồn kho · 4:15 Điều kiện Product = &Product, điểm bán = &Location · 4:45 Selection.Next: trả về số dư; không có bản ghi thì trả về 0 · 6:55 Chạy thử: tồn kho âm vẫn hiện (chưa chặn), tồn 0 hiện trống · 7:56 Chỉnh Format và EditFormat: NZ=0 để hiện số 0; [9:31] kiểm tra lại
- Người học thường hỏi: "muốn xem tồn kho ngay khi chọn hàng trên phiếu bán"; "query tồn kho trả về rỗng khi sản phẩm chưa nhập"; "ô số lượng bằng 0 bị trống"
- Bài giáo trình: Bài 10 (chính); Bài 11, Bài 7, Bài 16, Bài 9
- Đề BTL Jet: Đề 2, Đề 9, Đề 1
- Nhóm phù hợp: J M D — mức trung bình
- Lưu ý khi giới thiệu: Query không truyền Period nên lấy số dư hiện tại, không theo ngày chứng từ. Nên đặt điều kiện trong tham số của virtual table Balance thay vì WHERE.
- _(mã nội bộ QA-17)_

### Báo động tồn kho thấp với màu chữ hiển thị — 13:09

- Link: https://www.youtube.com/watch?v=0JbOMl80lnY&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=18
- Chủ đề để dẫn: tô màu cảnh báo tồn kho thấp
- Video làm gì: Thêm định mức tối thiểu vào Products và cột định mức vào bảng hàng chứng từ bán; Conditional appearance của form tô đỏ ô tồn kho khi tồn < định mức (so sánh hai cột của dòng).
- Mốc xem nhanh: 0:00 Bài toán: cảnh báo tồn kho thấp; ngưỡng do người dùng đặt · 1:03 Thêm attribute MinInventory (Number) vào Catalog Products, đưa lên item form, nhập ngưỡng · 2:36 Thêm cột MinInventory vào tabular section Sale, cạnh cột tồn kho · 6:18 Gọi trong OnChange của Product, gán vào cột MinInventory · 7:20 Chạy thử: hiển thị tồn kho và tồn tối thiểu (tồn đang âm) · 8:26 Form > Conditional appearance: TextColor đỏ, điều kiện tồn kho < MinInventory, Formatted fields = cột tồn kho · 10:04 Chạy thử: tồn thấp hiện đỏ; [10:35] nhập hàng cho điểm bán khác, tồn đủ thì không đỏ
- Người học thường hỏi: "tồn kho dưới mức tối thiểu thì hiện màu đỏ"; "conditional appearance so sánh hai cột"; "đặt định mức tồn kho tối thiểu"
- Bài giáo trình: Bài 9 (chính); Bài 3, Bài 10, Bài 16
- Đề BTL Jet: Đề 2, Đề 9
- Nhóm phù hợp: J M — mức cơ bản – trung bình
- Lưu ý khi giới thiệu: Định mức chỉ theo sản phẩm; Đề 2 cần định mức theo từng cửa hàng/kho (thường dùng information register). Lưu tồn và định mức vào dòng chứng từ là dữ liệu thừa.
- _(mã nội bộ QA-18)_

### Lọc dữ liệu chọn sản phẩm theo hãng — 6:30

- Link: https://www.youtube.com/watch?v=EfF2acfP2Y8&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=19
- Chủ đề để dẫn: lọc danh sách chọn theo một trường khác
- Video làm gì: Tạo catalog Brand, thêm Brand vào Products và vào chứng từ bán; dùng Choice parameter links (Filter.Brand ↔ Object.Brand) trên cột sản phẩm để khi chọn hãng thì danh sách sản phẩm chỉ còn hàng của hãng đó; cấp quyền role cho catalog mới.
- Mốc xem nhanh: 0:30 Tạo Catalog Brand; thêm attribute Brand vào Catalog sản phẩm · 1:33 Đưa Brand lên form của sản phẩm · 2:04 Chạy thử: không sửa được Catalog Brand vì thiếu quyền, vào Role admin cấp quyền · 2:38 Nhập dữ liệu mẫu hãng và sản phẩm · 4:12 Giới thiệu Choice parameters (giá trị cố định) và Choice parameter links · 5:14 Chạy thử: chọn "Trang điểm Hoàng Anh" chỉ còn phấn má, son môi; gợi ý áp dụng cho bài hãng xe → xe · 5:46 Nói thêm về link theo cột trong tabular section
- Người học thường hỏi: "chọn hãng/nhà cung cấp rồi mà danh sách sản phẩm vẫn hiện tất cả"; "tạo catalog mới chạy lên không sửa được, báo không đủ quyền"
- Bài giáo trình: Bài 9 (chính); Bài 3, Bài 20
- Đề BTL Jet: Đề 3, Đề 6, Đề 1
- Nhóm phù hợp: J M — mức cơ bản
- Lưu ý khi giới thiệu: Giáo trình Bài 9 dạy Choice parameters (giá trị cố định); Choice parameter links (ngoài giáo trình — hãy kiểm tra lại trong Syntax assistant). Đổi hãng sau khi đã chọn hàng thì dòng cũ không bị kiểm tra lại.
- _(mã nội bộ QA-19)_

### Hướng dẫn truy cập bản dùng thử 1C:AccountingSuite — 1:16

- Link: https://www.youtube.com/watch?v=8Vmkv3KP5ek&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=20
- Chủ đề để dẫn: xem thử một ứng dụng 1C thực tế qua trình duyệt
- Video làm gì: Mở trang dùng thử, đăng nhập bằng tài khoản demo có sẵn (chọn tài khoản tiếng Việt) và xem giao diện phần mềm kế toán qua trình duyệt.
- Mốc xem nhanh: 0:00 Giới thiệu mục đích: bản dùng thử cho khách hàng/đối tác/trường học · 0:00 Mở địa chỉ web của bản dùng thử · 0:31 Chọn tài khoản dùng thử (bản tiếng Việt), nhập mật khẩu · 0:31 Vào xem giao diện phần mềm qua trình duyệt
- Người học thường hỏi: "muốn xem thử phần mềm 1C mà không cài đặt"
- Bài giáo trình: Bài 1 (chính)
- Đề BTL Jet: —
- Nhóm phù hợp: J — mức giới thiệu
- Lưu ý khi giới thiệu: Địa chỉ và tài khoản demo có thể đã thay đổi; kiểm tra trước khi gửi.
- _(mã nội bộ QA-20)_

### Hiển thị đối tượng Siêu dữ liệu lên Quick menu — 2:23

- Link: https://www.youtube.com/watch?v=rPSNKvFEQ8E&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=21
- Chủ đề để dẫn: bật lệnh cho phân hệ đang trống
- Video làm gì: Phân hệ đã hiện nhưng không có gì bên trong: mở Command interface và bật Visibility cho lệnh danh sách và lệnh "tạo mới" của Document Sale, rồi của catalog sản phẩm.
- Mốc xem nhanh: 0:00 Mô tả: Quick menu xuất hiện nhưng trống · 0:32 Mở Command interface trong Designer, tìm Document Sale và lệnh "Sale: create" · 1:03 Tích hiển thị (Visibility) cho cả hai lệnh · 1:33 Chạy thử: danh sách Sale và lệnh tạo Sale mới đã xuất hiện · 1:33 Thêm Catalog sản phẩm, chỉ tích lệnh danh sách · 2:06 Chạy lại: catalog sản phẩm hiện, lệnh tạo mới không hiện
- Người học thường hỏi: "tạo phân hệ/đối tượng mới mà vào không thấy gì"; "muốn hiện nút Tạo mới ngay trên phân hệ"
- Bài giáo trình: Bài 14 (chính); Bài 9
- Đề BTL Jet: mọi đề (khi thêm object mới vào Jet)
- Nhóm phù hợp: J M — mức cơ bản
- Lưu ý khi giới thiệu: "Quick menu" là tên phân hệ trong ví dụ, không phải khái niệm của nền tảng. Object phải nằm trong Content của subsystem và role phải có quyền thì lệnh mới hiện.
- _(mã nội bộ QA-21)_

### Extension (Phần mở rộng) trong 1C:Enterprise — 6:33

- Link: https://www.youtube.com/watch?v=T_DEaA1p_bA&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=22
- Chủ đề để dẫn: thêm báo cáo bằng extension mà không sửa cấu hình gốc
- Video làm gì: Tạo extension, adopt register tồn kho, tạo báo cáo DCS và subsystem trong extension; chạy thử rồi lưu file .cfe và nạp vào infobase khác.
- Mốc xem nhanh: 0:31 Định nghĩa extension, ví dụ báo cáo riêng cho cấu hình chuẩn · 1:02 Configuration > Configuration extensions > Add, đổi tên/prefix · 3:10 Tạo Report trong extension, mở Data composition schema, tạo data set query · 3:41 Settings: list, chọn trường hiển thị · 4:12 Tạo Subsystem trong extension, thêm report vào Content; chạy thử · 5:13 Mở infobase khác, thêm extension từ file · 5:45 Chạy report trên infobase mới, đọc dữ liệu register
- Người học thường hỏi: "muốn thêm báo cáo vào cấu hình chuẩn mà không sửa cấu hình gốc"; "tạo extension xong không thấy báo cáo"; "mang extension sang database khác"
- Bài giáo trình: bài Extensions (chính); Bài 18, Bài 9, Bài 11
- Đề BTL Jet: Đề 2, Đề 4, Đề 7, Đề 8, Đề 9
- Nhóm phù hợp: D M J — mức trung bình
- Lưu ý khi giới thiệu: Video không nói về Purpose (Patch/Customization/Add-on — xem bài Extensions). Extension chỉ nạp được vào cấu hình có đúng các object đã adopt; object mới cần quyền.
- _(mã nội bộ QA-22)_

### Thực hiện tính toán đơn giản với SQL trong 1C — 2:59

- Link: https://www.youtube.com/watch?v=dP21dfHxkCo&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=23
- Chủ đề để dẫn: tính toán ngay trong query
- Video làm gì: Trong query của DCS, bỏ trường lưu sẵn và thêm trường tính Revenue − Cost với alias tiếng Việt, rồi sửa Settings của báo cáo.
- Mốc xem nhanh: 0:00 Giới thiệu report có Revenue, Cost, Benefits; Benefits đang ghi sẵn vào register · 1:03 Mở DCS, sửa query: bỏ Benefits · 1:33 Thêm trường tính toán Revenue - Cost AS "Lợi nhuận" trong SELECT · 2:04 Sửa Settings: bỏ Benefits, thêm Lợi nhuận · 2:36 Chạy report: cột lợi nhuận hiển thị
- Người học thường hỏi: "muốn báo cáo có cột chênh lệch mà không lưu vào register"; "tính toán cột trong query 1C thế nào"
- Bài giáo trình: Bài 10 (chính); Bài 18
- Đề BTL Jet: Đề 8, Đề 9, Đề 5, Đề 4
- Nhóm phù hợp: J M — mức cơ bản
- Lưu ý khi giới thiệu: Đây là ngôn ngữ truy vấn 1C, không phải SQL. Với LEFT JOIN cần ISNULL; phép chia phải kiểm tra mẫu số 0 (CASE).
- _(mã nội bộ QA-23)_

### Thay đổi Style (màu sắc) của chương trình — 2:47

- Link: https://www.youtube.com/watch?v=cgmDdh6bHMg&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=24
- Chủ đề để dẫn: đổi màu giao diện bằng Style
- Video làm gì: Tạo Style trong nhánh Common, đổi màu một số style item, gán vào thuộc tính Style của cấu hình; giao diện đổi màu.
- Mốc xem nhanh: 0:00 Đặt vấn đề: đổi màu vàng mặc định của giao diện · 0:33 Common > Styles: tạo Style mới · 1:07 Đổi màu các style item (hồng, xanh) · 1:38 Kết quả trong editor: màu đã đổi · 2:09 Configuration root > properties > Style: chọn style mới · 2:09 Chạy chương trình, giao diện đổi màu
- Người học thường hỏi: "muốn đổi màu vàng của giao diện 1C theo màu công ty"
- Bài giáo trình: Bài 9 (chính)
- Đề BTL Jet: —
- Nhóm phù hợp: M D — mức cơ bản
- Lưu ý khi giới thiệu: Đối tượng Style (ngoài giáo trình — hãy kiểm tra lại trong Syntax assistant); không phải vùng nào trên giao diện cũng đổi được qua Style.
- _(mã nội bộ QA-24)_

### Chặn kết chuyển khi phát hiện tồn kho âm — 10:03

- Link: https://www.youtube.com/watch?v=k2uht5J1f3c&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=25
- Chủ đề để dẫn: kiểm soát âm kho khi posting
- Video làm gì: Trong Posting của chứng từ bán: ghi movements vào register trước, query bảng ảo Balance (sản phẩm IN danh sách, kho = kho chứng từ) lấy dòng có tồn < 0; nếu có thì báo thiếu bao nhiêu và Cancel = True.
- Mốc xem nhanh: 0:00 Tái hiện lỗi: bán son môi tồn 0 vẫn post được · 1:37 Mở module Document Sale, handler Posting · 2:10 Ghi movements vào register trước khi kiểm tra · 2:42 Query Builder: virtual table Balance, điều kiện sản phẩm IN (&list) và kho = &kho · 4:15 Tham số danh sách sản phẩm = UnloadColumn từ tabular section · 7:14 Sửa lỗi cú pháp (thiếu đóng ngoặc), chạy thử · 8:57 Post bị chặn: "Failed to post" + thông báo thiếu hàng
- Người học thường hỏi: "bán vượt tồn mà chứng từ vẫn post được, tồn kho bị âm"; "làm sao không cho kết chuyển khi không đủ hàng"
- Bài giáo trình: Bài 11 (chính); Bài 10, Bài 12
- Đề BTL Jet: Đề 1, Đề 9, Đề 2
- Nhóm phù hợp: J M D — mức trung bình
- Lưu ý khi giới thiệu: Không đặt Period cho Balance nên chứng từ ghi lùi ngày bị kiểm tra theo tồn hiện tại — giáo trình Bài 11 dùng PointInTime/Boundary. Không khóa dữ liệu khi nhiều người post cùng lúc (managed lock (ngoài giáo trình — hãy kiểm tra lại trong Syntax assistant)).
- _(mã nội bộ QA-25)_

### Tùy chỉnh ngôn ngữ theo người dùng — 4:30

- Link: https://www.youtube.com/watch?v=wo7G7jSPtBE&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=26
- Chủ đề để dẫn: hiển thị ngôn ngữ khác nhau cho từng người dùng
- Video làm gì: Tạo Language "vi" bên cạnh English, nhập synonym tiếng Việt cho Document Sale, đặt Language cho từng user trong Administration → Users; user tiếng Việt thấy "Bán hàng".
- Mốc xem nhanh: 0:00 Đặt vấn đề: giao diện theo ngôn ngữ của từng user · 1:01 Languages: có English (en), tạo Vietnamese (vi) · 1:31 Mở Synonym của Document Sale · 2:03 Administration > Users: user admin EN, Language = English · 2:34 Tạo user admin VN, Language = Vietnamese; update configuration · 3:05 Chạy bằng user EN: hiện "Sale" · 3:41 Chạy bằng user VN: hiện "Bán hàng"
- Người học thường hỏi: "muốn user Việt thấy tiếng Việt, user nước ngoài thấy tiếng Anh"; "đã thêm ngôn ngữ mà vẫn hiện tiếng Anh"
- Bài giáo trình: Bài 20 (chính); Bài 2
- Đề BTL Jet: —
- Nhóm phù hợp: D M — mức cơ bản
- Lưu ý khi giới thiệu: Chỉ synonym của metadata được dịch; chuỗi trong code cần NStr; dữ liệu (tên hàng…) không tự dịch. Trên cấu hình SSL quản lý user qua catalog Users.
- _(mã nội bộ QA-26)_

### Kết xuất kết nhập cấu hình bằng file *.1CD — 3:29

- Link: https://www.youtube.com/watch?v=3X0EAToibUg&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=27
- Chủ đề để dẫn: mang một file infobase sang máy hoặc thư mục khác
- Video làm gì: Tạo infobase mới rồi chép file 1Cv8.1CD của infobase khác đè vào thư mục; mở lên có đủ cấu hình và dữ liệu. So sánh nhanh với cách gửi file .cf và .dt.
- Mốc xem nhanh: 0:00 Mục tiêu: gửi file .1CD sang cấu hình khác; nhắc .cf (cấu hình) và .dt (cấu hình + dữ liệu) · 0:30 Tạo infobase mới, chọn thư mục lưu · 1:01 Mở infobase thư viện để xem các đối tượng · 1:32 Mở thư mục infobase, tìm file 1Cv8.1CD · 2:02 Chép và dán đè vào thư mục infobase mới (Replace) · 2:35 Mở lại: có đủ dữ liệu độc giả, mượn, trả; so sánh với .dt
- Người học thường hỏi: "gửi bài/infobase cho thầy cô hoặc bạn cùng nhóm thế nào"; "chép database sang máy khác"
- Bài giáo trình: Bài 1 (chính)
- Đề BTL Jet: —
- Nhóm phù hợp: J M D — mức cơ bản
- Lưu ý khi giới thiệu: Chỉ dùng với file infobase và phải đóng mọi phiên làm việc trước khi chép. Cách nên dùng để nộp bài là Dump infobase (.dt) hoặc lưu cấu hình (.cf) — Bài 1.
- _(mã nội bộ QA-27)_

### Hướng dẫn publish Infobase 1C:Enterprise lên web server — 7:21

- Link: https://www.youtube.com/watch?v=P_bwSfxAV8I&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=28
- Chủ đề để dẫn: publish infobase lên web server (IIS)
- Video làm gì: Bật IIS và ISAPI Extensions trên Windows, kiểm tra thành phần web server extension của bộ cài, cấp quyền IIS_IUSRS, Publish to web server từ Designer, chỉnh handler và Application pool; mở localhost/<tên> để đăng nhập.
- Mốc xem nhanh: 0:00 Giới thiệu: publish infobase lên IIS · 1:03 Thêm ASP.NET 3.5, .NET Extensibility; cài và kiểm tra localhost · 2:06 Kiểm tra bản cài 1C có web server extension · 2:36 Thư mục cài 1C: Security, thêm IIS_IUSRS, Full control · 4:11 IIS Manager: trỏ tới module web server extension của 1C · 5:16 Mở localhost/<tên>: màn hình đăng nhập · 5:46 Tạo Role admin và user admin, đăng nhập web thành công
- Người học thường hỏi: "publish xong mở trình duyệt báo lỗi"; "muốn truy cập 1C qua trình duyệt từ máy khác"
- Bài giáo trình: Bài 1 (chính); Bài 7, Bài 20
- Đề BTL Jet: —
- Nhóm phù hợp: D — mức trung bình
- Lưu ý khi giới thiệu: Cấp Full control cho IIS_IUSRS trên cả thư mục cài 1C là quá rộng. "Enable 32-bit applications" chỉ đúng khi cài nền tảng 32-bit.
- _(mã nội bộ QA-28)_

## C. Ghi chú về playlist

- Tiêu đề video đánh số "Bài 13 … Bài 36" theo thứ tự riêng của playlist, **không** trùng số bài giáo trình (ví dụ video "Bài 22: Kiểm tra dữ liệu trùng lặp" không thuộc Bài 22 – SSL Print). Khi người học gọi video theo số đó, tra bảng trên theo tên.
- Vị trí 20 (bản dùng thử AccountingSuite) và 27 (chép file .1CD) không mang số "Bài N". Video vị trí 27 chưa có trong file Excel đối chiếu ban đầu.
- Nhiều video được quay trên cấu hình ví dụ bán mỹ phẩm (Sale, Products, POS/điểm bán) — tên object trong video không phải tên trong giáo trình hay trong Jet.
