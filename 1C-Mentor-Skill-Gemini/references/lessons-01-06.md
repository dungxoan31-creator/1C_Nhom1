# Tài liệu gộp: lessons-01-06

Gồm các mục: § bai-01-04, § bai-05-06


---

# § bai-01-04

# Bài 1–4 — Nền tảng 1C:Enterprise, metadata, Catalog/Enumeration/Document, hierarchy

## Bài 1 — Giới thiệu nền tảng

### Platform và applied solution
- 1C:Enterprise gồm hai thành phần gắn chặt: **platform** và **applied solution** (application/configuration) chạy trên platform.
- So sánh của tài liệu: platform như **đầu Blu-ray**, applied solution như **đĩa**. Thiếu một trong hai thì không dùng được. Chỉ có một platform (1C:Enterprise 8) nhưng có thể tạo vô số applied solution.
- Platform: là nền để xây applied solution, cung cấp môi trường thực thi, và công cụ phát triển / quản trị / hỗ trợ. Platform tự nó không tự động hóa nghiệp vụ nào.
- **Low-code approach**: phát triển chủ yếu bằng mô hình hóa trực quan và cơ chế dựng sẵn; viết code chỉ cho các tình huống đặc thù.

### Metadata
- Applied solution không được "viết" bằng ngôn ngữ lập trình theo nghĩa đen. Nền tảng của nó là **metadata** — mô tả khai báo (declarative) có cấu trúc.
- Khi chạy, platform "phát" (interprets) metadata.
- Metadata mô tả: cấu trúc dữ liệu, kiểu, quan hệ giữa object, hành vi, cách hiển thị, phân quyền, giao diện…
- Ngôn ngữ lập trình chỉ dùng cho việc cần mô tả thuật toán (ví dụ tính thuế, kiểm tra dữ liệu nhập).

### Standard applied object prototypes
- Toàn bộ applied solution được mô tả bằng metadata như một tập applied object dựa trên một số **prototype** (ví dụ: catalogs, documents, accumulation registers).
- Mỗi prototype có **basic implementation**: cấu trúc dữ liệu với các field định sẵn, kiểu trong ngôn ngữ, methods, events, properties, thao tác điển hình, cách xem/sửa, phân quyền…
- Applied object được **tạo từ prototype** (instantiation), không phải "kế thừa" theo nghĩa OOP.

### Kiến trúc 3 tầng (client-server)
- Client application ↔ 1C:Enterprise server cluster ↔ Database server (Microsoft SQL Server, PostgreSQL, IBM DB2, Oracle Database).
- Xử lý nặng (ví dụ query phức tạp) chạy trên server cluster; client chỉ nhận kết quả cần.
- Người dùng chỉ cần biết tên cluster và tên infobase.
- Ngoài ra có **file infobase** (file .1CD) — không cần server 1C và DBMS.

### Client applications
- **Thin client**: cài trên máy người dùng, truy cập file system máy client, dùng license cục bộ.
- **Web client**: không cần cài, chạy trong trình duyệt.
- Việc phát triển applied solution không phụ thuộc người dùng chọn client nào.
- Thick client và thin client có trên Windows và Linux; Mac dùng web client.
- Server làm việc trên Linux có giới hạn: không hỗ trợ Microsoft SQL Server, không hỗ trợ COM, xác thực bằng Kerberos.

### Cloud
- Tính năng **data separation** là nền tảng cho công nghệ cloud (multitenant), hỗ trợ mô hình SaaS.

### Thao tác cơ bản
- Tạo infobase mới: 1C starter → Insert → Creating new infobase → "Create an infobase without a configuration…".
- Remove khỏi danh sách **không xóa** infobase khỏi đĩa/DBMS.
- Designer → Tools → **Dump infobase** / **Restore infobase** (sao lưu/khôi phục cả dữ liệu).
- Designer → Configuration → **Open configuration**, **Save configuration to file**, **Load configuration from file**.

## Bài 2 — Metadata classes, metadata objects, data objects

- **Metadata classes**: danh sách do platform định sẵn (Catalogs, Documents, Enumerations, Charts of characteristic types, Reports, Data processors, Information registers, Accumulation registers, Business processes, Subsystems, Roles…). Developer **không tạo được** metadata class mới, nhưng tạo được bao nhiêu **metadata object** cũng được trong mỗi class.
- Ví dụ nhà máy: loại thiết bị (điện thoại) = metadata class; mẫu điện thoại cụ thể = metadata object; một chiếc điện thoại cụ thể có số serial = **data object**.
- Mỗi class có **standard attributes** chung (mọi Document có Date, Number; mọi Catalog có Code, Parent…), events (Document có các event liên quan đến Posting), hành vi.
- Developer tạo metadata object trong **Designer**; người dùng tạo data object trong **Enterprise mode**.

### Object và Reference
- Mở form của một item/document là làm việc với **object**; thay đổi được lưu khi **write** object.
- Để liên kết giữa các object dùng **reference**, ví dụ attribute Product kiểu `CatalogRef.Products`.
- Reference trỏ tới một instance duy nhất. Sửa object không đổi giá trị reference đang lưu, nhưng nếu đổi attribute dùng làm **presentation** thì presentation thay đổi ở mọi nơi.
- Một object tồn tại một instance duy nhất — sửa nó ảnh hưởng mọi nơi đang tham chiếu.
- **Không thể thay đổi data object thông qua reference.**

### Primitive types
- **Number**: Length (tổng số chữ số), Precision (số chữ số phần thập phân), Nonnegative.
- **String**: Length (0 → tự bật Unlimited length), Type of length (Fixed: thêm khoảng trắng cho đủ; Variable), Unlimited length — chuỗi unlimited **không dùng được trong so sánh**.
- **Date**: Date format = Date / Time / Date and time. Giá trị luôn chứa đủ ngày và giờ; format "Date" luôn có giờ là đầu ngày (00:00:00).
- **Boolean**: True/False.

## Bài 3 — Catalog, Enumeration, Document

### Catalog
- Quản lý danh sách dữ liệu (nhân viên, khách hàng, sản phẩm…). Mục đích: **nhập liệu nhất quán** (chọn từ danh sách thay vì gõ text) và **lưu thông tin bổ sung** về object.
- Attributes và **tabular sections** do developer thêm. Mỗi tabular section lưu ở bảng riêng, nối với bảng catalog qua key field.
- Standard attributes: **Ref, Code, Description, Owner, Parent, IsFolder, DeletionMark, Predefined, PredefinedDataName**.
- Forms của Catalog: **Item, Group, List, Choice, Group selection, Generic**. Nếu không gán default form, platform tự sinh form động trong Enterprise mode. Tự tạo form khi cần đổi thiết kế hoặc thêm/đổi logic.
- Presentation properties: Object presentation, Extended object presentation, List presentation, Extended list presentation.

### Subsystem (sơ lược)
- Dùng để nhóm object theo mục đích trong giao diện. Khi đã có ít nhất một subsystem, platform cảnh báo nếu object không thuộc subsystem nào.

### Enumeration
- Lưu tập giá trị **cố định, người dùng không thay đổi được** (ví dụ thuế suất theo luật, loại sản phẩm, giới tính). Dùng khi thuật toán dựa vào các giá trị đó.
- Property **Required field = "Display error"** khiến platform kiểm tra attribute đã được điền khi write.

### Document
- Phản ánh **nghiệp vụ / sự kiện** (bán hàng, tuyển dụng…).
- Khác biệt chính so với các metadata object khác: Document **có thể được post**. Posting là phản ánh nghiệp vụ vào infobase; chưa post thì document như bản nháp.
- Document luôn **gắn với thời gian** — đảm bảo thứ tự nghiệp vụ thực tế (ví dụ tránh tồn kho âm khi đổi ngày).
- Standard attributes riêng: **Number, Date, Posted**.
- Forms: Document form (thay cho Item form), List, Choice; không có Group / Group selection.
- **Default value** của attribute: giá trị điền sẵn khi tạo object.

## Bài 4 — Hierarchy, subordination, predefined data, numbering

### Hierarchy (Catalog và Chart of characteristic types)
- **Folder and item hierarchy**: group chứa group và item; item chỉ nằm trong group. Group chủ yếu để phân loại, ít khi tham gia logic.
- **Item hierarchy**: item có thể trực thuộc item khác và cả hai đều chọn được làm giá trị (ví dụ StructuralUnits).
- Có thể **giới hạn số cấp** hierarchy.
- Form table có các chế độ xem: hierarchical list, list, tree.

### Subordination (Owner)
- Quan hệ một-nhiều (ví dụ Bank accounts thuộc Bank). Thiết lập ở tab **Owners**. Standard attribute **Owner**.
- **Choice parameter links**: giới hạn lựa chọn theo giá trị của field khác (ví dụ Contract lọc theo Customer bằng `Filter.Owner`).

### Predefined data
- Item có sẵn từ khi bắt đầu dùng app; dùng để **xây thuật toán dựa trên item ổn định**.
- Predefined item trong configuration **không phải** data object; platform tạo data object và liên kết qua tên (Predefined = True, PredefinedDataName).
- Truy cập từ code bằng tên predefined item. Không nên xây thuật toán dựa trên dữ liệu không ổn định (tìm theo code/description) vì người dùng có thể sửa hoặc xóa.

### Code, number, autonumbering
- **Autonumbering**: platform tự gán code/number khi write.
- **Check uniqueness**: kiểm tra trùng.
- **Code series**: Across the catalog / Within subordination / Within subordination to owner.
- Document: **Periodicity** (phạm vi duy nhất của số, ví dụ trong năm; Nonperiodic), **Numerator** (DocumentNumerator để đánh số thống nhất nhiều loại document).
- Tắt code bằng Code length = 0.

## Điểm cần nhớ
- Platform ≠ applied solution; platform "phát" metadata.
- Metadata class do platform định sẵn; developer tạo metadata object; người dùng tạo data object.
- Applied object được tạo từ prototype có basic implementation — không dùng khái niệm "kế thừa".
- Không sửa object qua reference.
- Posting là đặc trưng của Document.
- Dựa thuật toán vào predefined data hoặc Enumeration, không dựa vào code/description người dùng nhập.

## Thẻ gợi ý bài thực hành (Practice 1–4)

> Các thẻ dưới đây bám theo đề "1. Introduction practice.docx", "2. Practice.docx", "3. Practice.docx", "4. Practice.docx". Bài 1–3 hầu như chỉ thao tác trong Designer / Enterprise mode, không cần viết code; Bài 4 có một bài tập code nhỏ đầu tiên (form module).

### Practice 1 — Bài tập Task 1 (tạo infobase, load configuration, dump/restore)
- **Đề bài (tóm tắt):** Tạo thư mục 1C_Bases, tạo infobase Lesson1_Base1, load configuration từ "Lesson1_Configuration1.cf", thêm 1 product ở Enterprise mode, dump ra "Lesson1_Base1.dt", tạo Lesson1_Base2 rồi restore từ file .dt và kiểm tra product đã có.
- **Gợi ý 1 — Hướng đi:** Phân biệt hai loại file: `.cf` chỉ chứa **configuration** (metadata, không có dữ liệu), còn `.dt` chứa **cả configuration lẫn dữ liệu** của infobase (xem "Thao tác cơ bản" ở Bài 1). Vì vậy product nhập ở Base1 chỉ sang được Base2 qua dump/restore, không qua load `.cf`.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** 1C starter → Insert → "Create an infobase without a configuration…"; Designer → Configuration → **Open configuration** → **Load configuration from file**; sau đó **Update database configuration** (F7); Designer → Administration/Tools → **Dump infobase** / **Restore infobase**.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo thư mục trên đĩa, tạo infobase trống trỏ vào thư mục con của nó.
  2. Mở Designer → Open configuration → Load configuration from file → chọn file `.cf` → đồng ý cập nhật database configuration.
  3. Chạy Enterprise mode, thêm 1 item vào catalog Products.
  4. Quay lại Designer → Dump infobase ra `.dt`.
  5. Tạo infobase trống thứ hai, mở Designer → Restore infobase từ file `.dt`.
- **Lỗi hay gặp:**
  - Load `.cf` vào Base2 thay vì restore `.dt` → configuration giống nhưng không có product.
  - Quên Update database configuration sau khi load → Enterprise mode chưa thấy object mới.
  - Restore ghi đè toàn bộ dữ liệu của infobase đích — chỉ làm trên infobase trống/thử nghiệm.
- **Tự kiểm tra:** Mở Lesson1_Base2 ở Enterprise mode → catalog Products có đúng item đã tạo ở Base1.

### Practice 1 — Bài tập Task 2 (danh sách infobase, web client, server infobase)
- **Đề bài (tóm tắt):** Xóa Lesson1_Base2 khỏi danh sách rồi thêm lại; thêm infobase đã publish trên web server (Lesson1_Web) và chạy bằng thin client và web client; thêm infobase trên server cluster "DemoServer" và quan sát lỗi.
- **Gợi ý 1 — Hướng đi:** Danh sách trong 1C starter chỉ là danh sách **đường dẫn kết nối**; Remove khỏi danh sách **không xóa** infobase (Bài 1, "Thao tác cơ bản"). Ba kiểu kết nối tương ứng ba loại vị trí infobase: file, web server, 1C:Enterprise server cluster (xem "Kiến trúc 3 tầng" và "Client applications").
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** 1C starter → Remove / Add → "Add an existing infobase to the list" → chọn kiểu vị trí: On this computer or local network (file), On web server (URL), On 1C:Enterprise server (Server cluster + Infobase name).
- **Gợi ý 3 — Khung bài làm:**
  1. Remove Lesson1_Base2, kiểm tra thư mục vẫn còn trên đĩa.
  2. Add existing infobase → chọn đúng thư mục cũ → chạy Enterprise mode.
  3. Add existing infobase → kiểu web server → dán URL của đề → chạy bằng thin client; sau đó dán URL vào trình duyệt để chạy web client.
  4. Add existing infobase → kiểu server → nhập tên cluster và tên infobase theo đề → chạy và đọc thông báo lỗi.
- **Lỗi hay gặp:**
  - Nghĩ rằng Remove là xóa infobase → thực ra dữ liệu vẫn còn.
  - Chọn sai kiểu vị trí khi thêm (dán URL vào kiểu file).
  - Kỳ vọng infobase "DemoServer" chạy được — lỗi là đúng như đề nói, vì mạng của bạn không có cluster đó.
- **Tự kiểm tra:** So sánh giao diện thin client và web client của cùng infobase (cùng chức năng, khác cách cài đặt/chạy); ghi lại nội dung lỗi khi kết nối server không tồn tại.

### Practice 1 — Bài tập Task 3 (Compare and merge, cache form)
- **Đề bài (tóm tắt):** Trong Designer của Lesson1_Base1, dùng "Compare and merge with configuration from file" với "Lesson1_Configuration2.cf", update database configuration, rồi kiểm tra attribute mới "Service" trên form product (dùng "Restore window position" nếu form bị cache).
- **Gợi ý 1 — Hướng đi:** Merge cho phép **gộp** thay đổi từ file `.cf` khác vào configuration hiện tại thay vì thay thế toàn bộ như Load. Sau merge phải update database configuration thì cấu trúc dữ liệu mới có hiệu lực.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Designer → Configuration → **Compare and merge with configuration from file**; bỏ chọn "Save settings automatically"; Execute → OK; F7. Enterprise mode → Menu → Window → **Restore window position**.
- **Gợi ý 3 — Khung bài làm:**
  1. Mở Designer, chạy Compare and merge, đối chiếu cửa sổ so sánh với ảnh trong đề.
  2. Execute, OK, rồi Update database configuration.
  3. Mở form product đã tạo ở Task 1, tìm field "Service".
  4. Nếu chỉ thấy thanh cuộn → Restore window position.
- **Lỗi hay gặp:**
  - Dùng Load configuration thay vì Compare and merge → mất các thay đổi riêng của configuration hiện tại.
  - Quên F7 → Enterprise mode chưa có attribute mới.
  - Tưởng attribute không được thêm, trong khi thực ra form đang dùng kích thước cửa sổ đã cache.
- **Tự kiểm tra:** Form product hiển thị field "Service"; product tạo ở Task 1 vẫn còn (merge không làm mất dữ liệu).

### Practice 2 — Bài tập Task 1 (reference và primitive types)
- **Đề bài (tóm tắt):** Tạo hai catalog (một catalog có default presentation là Code), một document `WorkWithRefsAndPrimitiveTypes` với các attribute reference và primitive theo đúng kiểu/độ dài trong đề; nhập dữ liệu ở Enterprise mode và so sánh cách hiển thị.
- **Gợi ý 1 — Hướng đi:** Bài này minh họa "Object và Reference" và "Primitive types" của Bài 2: field reference hiển thị **presentation** của object (Code hoặc Description tùy thiết lập), còn mỗi primitive type có properties riêng (Length, Precision, Nonnegative, Fixed/Variable, Date format, Unlimited length).
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Catalog → tab Data → property **Default presentation** = As code (cho `CatalogWithCodePresentation`). Document → attributes: kiểu `CatalogRef.<Tên catalog>`; String (Length, Allowed length Fixed/Variable, Length = 0 → Unlimited); Number (Length, Precision, Nonnegative); Date (Date format: Date / Time); Boolean.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo infobase mới, mở Designer.
  2. Tạo hai catalog; chỉnh Default presentation ở catalog thứ nhất.
  3. Tạo document và lần lượt thêm 10 attribute theo đúng bảng trong đề.
  4. F7, chạy Enterprise mode; tạo 1 item ở mỗi catalog, cùng Description "Test".
  5. Tạo document, điền các field reference → so sánh; điền các field primitive → so sánh từng cặp như đề gợi ý.
- **Lỗi hay gặp:**
  - Đặt Length cho Float là 5 thay vì 10 → đề muốn tổng 10 chữ số, trong đó Precision 5, nên phần nguyên chỉ còn 5 chữ số.
  - Quên chọn Fixed-length cho FixedString → không thấy khác biệt với VariableString.
  - Nghĩ rằng field OnlyDate không có giờ: giá trị Date luôn chứa cả ngày và giờ, format chỉ quyết định phần hiển thị/nhập.
  - Unlimited string không dùng được trong so sánh — nhớ cho các bài query sau.
- **Tự kiểm tra:** Hai field reference cùng trỏ tới item "Test" nhưng một field hiện Code, một field hiện Description; NonnegativeInteger không nhận số âm, Float nhận số âm; dán đoạn text rất dài vào UnlimitedString vẫn lưu được.

### Practice 2 — Bài tập Task 2 (Standard attributes)
- **Đề bài (tóm tắt):** Mở cửa sổ "Standard attributes" của một catalog và một document, so sánh danh sách và properties từng attribute.
- **Gợi ý 1 — Hướng đi:** Standard attributes do metadata class quy định (Bài 2, Bài 3): Catalog có Code, Description, Parent, Owner, IsFolder, DeletionMark, Predefined…; Document có Number, Date, Posted, DeletionMark.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Designer → mở object → tab Data → nút **Standard attributes**; chọn từng attribute để xem properties (Synonym, Fill checking, Tooltip…).
- **Gợi ý 3 — Khung bài làm:**
  1. Mở Standard attributes của catalog, liệt kê ra giấy.
  2. Làm tương tự với document.
  3. Đánh dấu attribute nào chỉ có ở catalog, attribute nào chỉ có ở document.
- **Lỗi hay gặp:**
  - Tìm Standard attributes trong danh sách Attributes thông thường — chúng nằm ở cửa sổ riêng.
  - Nhầm Posted là attribute chung — đó là đặc trưng của Document.
- **Tự kiểm tra:** Giải thích được vì sao Document có Date/Number/Posted còn Catalog có Code/Description/Parent/Owner.

### Practice 3 — Bài tập 1 (infobase mang tên bạn)
- **Đề bài (tóm tắt):** Tạo file infobase mới, đặt tên bằng họ tên đầy đủ của bạn.
- **Gợi ý 1 — Hướng đi:** Từ bài này trở đi mọi bài thực hành xây dần một applied solution kế toán bán hàng trên cùng infobase, nên hãy tạo infobase riêng và giữ nó.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** 1C starter → Insert → "Create an infobase without a configuration…" → kiểu "On this computer or local network".
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo infobase trống với tên là họ tên.
  2. Mở Designer → Open configuration.
- **Lỗi hay gặp:**
  - Tạo nhầm từ template có sẵn → configuration không còn trống.
  - Không sao lưu: nên Dump infobase định kỳ sau mỗi bài.
- **Tự kiểm tra:** Infobase xuất hiện trong danh sách với tên bạn, configuration trống.

### Practice 3 — Bài tập 2 (Countries)
- **Đề bài (tóm tắt):** Chọn metadata class phù hợp cho danh sách quốc gia, tạo object `Countries`.
- **Gợi ý 1 — Hướng đi:** Danh sách người dùng có thể thêm/sửa, cần chọn nhất quán → **Catalog** (Bài 3, mục Catalog), không phải Enumeration.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Designer → Catalogs → Add → Name = `Countries`; xem lại Description length (mặc định 25).
- **Gợi ý 3 — Khung bài làm:**
  1. Thêm catalog.
  2. Kiểm tra độ dài Description có đủ cho tên quốc gia dài.
- **Lỗi hay gặp:**
  - Chọn Enumeration → người dùng không thêm được quốc gia mới.
  - Để Description length 25 → tên dài bị cắt.
- **Tự kiểm tra:** Ở Enterprise mode tạo được item quốc gia có tên dài.

### Practice 3 — Bài tập 3 (Products với presentation khác nhau)
- **Đề bài (tóm tắt):** Tạo object `Products` có Weight (Number(15, 3, Non-negative)), FullDescription (String(500)), CountryOfOrigin (kiểu object ở bài 2); đặt bốn tên hiển thị: "Product", "Product/Service", "Products", "Products list".
- **Gợi ý 1 — Hướng đi:** Catalog có 4 **presentation properties** (Bài 3): Object presentation, Extended object presentation, List presentation, Extended list presentation — mỗi property dùng ở một chỗ khác nhau trong giao diện.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Catalog Products → tab Main/Presentation: ghép đúng 4 chuỗi của đề vào 4 property (lệnh tạo mới, tiêu đề form object, lệnh mở list, tiêu đề form list). Attribute `CountryOfOrigin` kiểu `CatalogRef.Countries`. Tăng Description length.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo catalog, thêm 3 attribute với đúng kiểu/độ dài/Nonnegative.
  2. Điền 4 presentation property.
  3. F7 rồi xem 4 chỗ hiển thị ở Enterprise mode.
- **Lỗi hay gặp:**
  - Ghép lệch "object" và "list": lệnh "Create" dùng Object presentation, lệnh mở danh sách dùng List presentation.
  - Quên Non-negative hoặc Precision 3 cho Weight.
  - Đặt CountryOfOrigin kiểu String thay vì reference → mất tính nhất quán dữ liệu.
- **Tự kiểm tra:** Ở Enterprise mode: lệnh tạo mới tên "Product", tiêu đề form item "Product/Service", lệnh danh sách "Products", tiêu đề form list "Products list".

### Practice 3 — Bài tập 4 (ProductsTypes và attribute bắt buộc có giá trị mặc định)
- **Đề bài (tóm tắt):** Tạo object `ProductsTypes` với các giá trị InventoryItem, Service, ContractWork; thêm attribute bắt buộc **ProductsType** vào Products, mặc định InventoryItem.
- **Gợi ý 1 — Hướng đi:** Tập giá trị cố định, thuật toán sau này sẽ dựa vào → **Enumeration** (Bài 3). Bắt buộc điền và giá trị mặc định là hai property của attribute.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Enumerations → Add → tab Enum values. Attribute của Products: kiểu `EnumRef.ProductsTypes`, property **Fill value** = giá trị InventoryItem, **Fill checking** = Show error ("Display error").
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo enumeration với 3 value.
  2. Thêm attribute vào Products, chọn kiểu enum.
  3. Đặt Fill value và Fill checking.
- **Lỗi hay gặp:**
  - Dùng Catalog cho loại product → người dùng xóa/sửa được, thuật toán dựa vào nó không còn ổn định.
  - Chỉ đặt Fill value mà quên Fill checking → người dùng xóa trắng vẫn ghi được.
  - (Lưu ý tên) Cấu hình mẫu của khóa ở các bài sau đặt tên attribute là `ProductType`; bạn có thể dùng đúng tên trong đề, chỉ cần nhất quán khi viết code/choice parameters sau này.
- **Tự kiểm tra:** Tạo product mới → field loại đã có InventoryItem; xóa trắng rồi ghi → platform báo lỗi field bắt buộc.

### Practice 3 — Bài tập 5 (subsystem Master data)
- **Đề bài (tóm tắt):** Tạo subsystem "Master data" và đưa mọi object đã tạo vào.
- **Gợi ý 1 — Hướng đi:** Subsystem nhóm object theo mục đích trong giao diện (Bài 3, "Subsystem (sơ lược)").
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Subsystems → Add → Name `MasterData`, Synonym "Master data" → tab **Content** chọn các object (hoặc tab Subsystems trong từng object).
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo subsystem.
  2. Tick Countries, Products, ProductsTypes ở Content.
  3. F7, mở Enterprise mode xem section mới.
- **Lỗi hay gặp:**
  - Quên một object → platform cảnh báo object không thuộc subsystem nào.
  - Enumeration không có form list riêng nên có thể không thấy lệnh của nó trong section — đó là bình thường.
- **Tự kiểm tra:** Section "Master data" hiển thị lệnh mở Countries và Products.

### Practice 3 — Bài tập 6 (Counterparties)
- **Đề bài (tóm tắt):** Tạo object cho danh sách khách hàng và nhà cung cấp, có TIN (String(12)) và RegistrationCountry (kiểu object ở bài 2); tên số ít là "Counterparty".
- **Gợi ý 1 — Hướng đi:** Danh sách đối tác người dùng tự quản lý → **Catalog**; "tên số ít" là Object presentation.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Catalog `Counterparties`; attribute `TIN` (String, Length 12), `RegistrationCountry` (`CatalogRef.Countries`); property Object presentation = "Counterparty"; tăng Description length.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo catalog, thêm hai attribute.
  2. Điền Object presentation.
- **Lỗi hay gặp:**
  - Đặt TIN kiểu Number → mất số 0 đầu và không đúng đề (String).
  - Ghi "Counterparty" vào Synonym thay vì Object presentation → tên danh sách cũng bị đổi.
- **Tự kiểm tra:** Lệnh tạo mới và tiêu đề form item dùng "Counterparty".

### Practice 3 — Bài tập 7 (SalesInvoice với tabular section Products)
- **Đề bài (tóm tắt):** Tạo object cho nghiệp vụ bán hàng `SalesInvoice`, có **Customer** (kiểu Counterparties) và tabular section **Products** gồm **Product**, **Quantity** (Number(15, 3, Non-negative)), **Price** (Number(15, 0, Non-negative)); tên số nhiều "Sales invoices".
- **Gợi ý 1 — Hướng đi:** Nghiệp vụ gắn thời gian, sau này sẽ post → **Document** (Bài 3). Nhiều dòng hàng trong một chứng từ → **tabular section**.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Document `SalesInvoice` → attribute `Customer` (`CatalogRef.Counterparties`); tab Data → Tabular sections → Add `Products` với 3 attribute; List presentation = "Sales invoices"; các attribute in đậm trong đề → Fill checking = Show error.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo document, thêm Customer.
  2. Thêm tabular section và 3 attribute của nó.
  3. Đặt Fill checking cho các attribute bắt buộc, điền List presentation.
- **Lỗi hay gặp:**
  - Tạo Product/Quantity/Price là attribute của document thay vì của tabular section → chỉ nhập được một dòng.
  - Quên Fill checking cho các attribute in đậm.
  - Đặt Price có Precision khác 0 trong khi đề yêu cầu Number(15, 0).
- **Tự kiểm tra:** Form document cho thêm nhiều dòng hàng; bỏ trống Customer rồi ghi → báo lỗi.

### Practice 3 — Bài tập 8 (subsystem Sales)
- **Đề bài (tóm tắt):** Tạo subsystem "Sales" và đưa object của bài 6 và 7 vào.
- **Gợi ý 1 — Hướng đi:** Một object có thể thuộc nhiều subsystem — Counterparties có thể nằm ở cả Master data lẫn Sales nếu muốn.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Subsystems → Add `Sales` → Content: Counterparties, SalesInvoice.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo subsystem.
  2. Chọn 2 object ở Content.
- **Lỗi hay gặp:**
  - Bỏ Counterparties khỏi Master data khi thêm vào Sales — không bắt buộc phải bỏ.
- **Tự kiểm tra:** Section "Sales" có lệnh mở "Sales invoices" và danh sách Counterparties.

### Practice 3 — Bài tập 9 (cập nhật và nhập dữ liệu)
- **Đề bài (tóm tắt):** Update database configuration, chạy Enterprise mode, nhập ít nhất 5 bản ghi cho mỗi object mới.
- **Gợi ý 1 — Hướng đi:** Người dùng tạo **data object** ở Enterprise mode (Bài 2) — kiểm tra thiết kế metadata bằng cách dùng thử.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** F7 → F5 (hoặc 1C:Enterprise) → nhập dữ liệu ở từng section.
- **Gợi ý 3 — Khung bài làm:**
  1. Nhập Countries trước, rồi Products, Counterparties (vì chúng tham chiếu Countries).
  2. Cuối cùng nhập SalesInvoice.
- **Lỗi hay gặp:**
  - Nhập SalesInvoice trước khi có Counterparties/Products → không có gì để chọn.
  - Description bị cắt → quay lại tăng Description length.
- **Tự kiểm tra:** Mỗi danh sách có ≥ 5 dòng; các field reference hiển thị đúng presentation.

### Practice 4 — Bài tập 1 (Products có group, tối đa 4 cấp group)
- **Đề bài (tóm tắt):** Cho phép lưu Products theo group, độ sâu hierarchy không quá 4 group; field group/parent hiển thị là "Group".
- **Gợi ý 1 — Hướng đi:** **Folder and item hierarchy** và giới hạn số cấp (Bài 4, mục Hierarchy). Tên hiển thị của field cha là Synonym của standard attribute **Parent**.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Catalog Products → tab Hierarchy: Hierarchical, Hierarchy type = Folder and item hierarchy, Limit level count + Level count. Tab Data → Standard attributes → Parent → Synonym "Group".
- **Gợi ý 3 — Khung bài làm:**
  1. Bật hierarchy, chọn đúng kiểu.
  2. Bật giới hạn số cấp và chọn số cấp.
  3. Đổi Synonym của Parent.
  4. F7, thử tạo group lồng nhau.
- **Lỗi hay gặp:**
  - Chọn Item hierarchy → item làm cha của item, không phải group.
  - Đặt số cấp mà không thử: hãy tự kiểm tra trong Enterprise mode cách platform đếm cấp (tạo group lồng nhau đến khi bị chặn) để chắc chắn đủ 4 cấp group như đề.
  - Đổi Synonym của catalog thay vì của standard attribute Parent.
- **Tự kiểm tra:** Tạo được 4 group lồng nhau, group thứ 5 bị từ chối; form item hiển thị field "Group".

### Practice 4 — Bài tập 2 (predefined "Vietnam" làm giá trị mặc định)
- **Đề bài (tóm tắt):** Thêm predefined item "Vietnam" vào Countries; RegistrationCountry của Counterparty mới tự điền "Vietnam".
- **Gợi ý 1 — Hướng đi:** **Predefined data** (Bài 4) là item ổn định để dựa vào; giá trị mặc định khi tạo object là property **Fill value** của attribute (Bài 3, "Default value").
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Catalog Countries → nút **Predefined** → thêm item Name `Vietnam`. Catalog Counterparties → attribute `RegistrationCountry` → Fill value = predefined item vừa tạo.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo predefined item.
  2. Chọn nó làm Fill value của attribute.
  3. F7, tạo Counterparty mới.
- **Lỗi hay gặp:**
  - Tạo item "Vietnam" bằng tay ở Enterprise mode → không chọn được làm Fill value ổn định và người dùng có thể xóa.
  - Đổi tên (Name) của predefined item sau khi code đã dùng tên đó.
- **Tự kiểm tra:** Counterparty mới mở ra đã có RegistrationCountry = Vietnam; item Vietnam trong list có biểu tượng predefined.

### Practice 4 — Bài tập 3 (CounterpartyContracts: owner, hierarchy hợp đồng/phụ lục, code)
- **Đề bài (tóm tắt):** Tạo object danh sách hợp đồng, subordinate với Counterparties (field owner tên "Counterparty"), tên số ít "Contract"; phụ lục là item nằm dưới hợp đồng, phụ lục không làm cha được; field cha tên "Main contract"; code duy nhất trong phạm vi owner và người dùng tự nhập.
- **Gợi ý 1 — Hướng đi:** Kết hợp ba cơ chế Bài 4: **Subordination (Owner)**, **Item hierarchy** với giới hạn số cấp (chỉ 2 cấp: hợp đồng → phụ lục), và **Code series = Within subordination to owner** + tắt **Autonumbering**.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Catalog `CounterpartyContracts`: tab **Owners** thêm Counterparties; tab Hierarchy: Hierarchy type = Item hierarchy, giới hạn số cấp; tab Numbering: Code series, Check uniqueness, Autonumbering; Standard attributes → Owner (Synonym "Counterparty"), Parent (Synonym "Main contract"); Object presentation "Contract".
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo catalog, khai báo owner.
  2. Bật Item hierarchy, giới hạn số cấp để phụ lục không thể có con.
  3. Thiết lập Code series, Check uniqueness, tắt Autonumbering.
  4. Đổi Synonym của Owner, Parent; điền Object presentation.
- **Lỗi hay gặp:**
  - Chọn Folder and item hierarchy → hợp đồng chính thành "group" không chọn được làm giá trị.
  - Quên giới hạn số cấp → phụ lục có thể làm cha của phụ lục khác.
  - Để Code series "Across the catalog" → hai counterparty khác nhau không thể cùng có hợp đồng số "001".
- **Tự kiểm tra:** Hai counterparty khác nhau mỗi bên có hợp đồng code "001" → ghi được; cùng counterparty trùng code → bị chặn; tạo phụ lục dưới phụ lục → bị chặn; code mới để trống chờ người dùng nhập.

### Practice 4 — Bài tập 4 (Contract trong SalesInvoice lọc theo Customer)
- **Đề bài (tóm tắt):** Thêm attribute **Contract** vào SalesInvoice, chỉ cho chọn hợp đồng của Customer trên chứng từ.
- **Gợi ý 1 — Hướng đi:** **Choice parameter links** (Bài 4, mục Subordination): lọc lựa chọn theo giá trị một field khác, dùng `Filter.Owner`.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Document SalesInvoice → attribute `Contract` (`CatalogRef.CounterpartyContracts`) → property **Choice parameter links** → Name `Filter.Owner`, data path = attribute Customer của chính document. Đặt Fill checking vì attribute in đậm.
- **Gợi ý 3 — Khung bài làm:**
  1. Thêm attribute với kiểu reference hợp đồng.
  2. Mở Choice parameter links, thêm một link theo hướng dẫn trên.
  3. F7, thử chọn hợp đồng khi đã chọn Customer.
- **Lỗi hay gặp:**
  - Dùng Choice parameters (giá trị cố định) thay vì Choice parameter links (giá trị lấy từ field khác).
  - Trỏ link tới sai attribute (ví dụ Contract chính nó) hoặc dùng `Filter.Parent` thay vì `Filter.Owner`.
- **Tự kiểm tra:** Đổi Customer → danh sách chọn Contract chỉ còn hợp đồng của customer đó.

### Practice 4 — Bài tập 5 (số SalesInvoice duy nhất trong năm)
- **Đề bài (tóm tắt):** Number của SalesInvoice chỉ cần duy nhất trong phạm vi một năm.
- **Gợi ý 1 — Hướng đi:** Property **Periodicity** của Document (Bài 4, "Code, number, autonumbering").
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Document SalesInvoice → tab Numbering → Number periodicity = Within a year; giữ Check uniqueness và Autonumbering.
- **Gợi ý 3 — Khung bài làm:**
  1. Mở tab Numbering, đổi Periodicity.
  2. F7, tạo chứng từ ở hai năm khác nhau.
- **Lỗi hay gặp:**
  - Tắt Check uniqueness → số có thể trùng ngay trong một năm.
  - Nhầm với Numerator (dùng để đánh số chung nhiều loại document).
- **Tự kiểm tra:** Chứng từ đầu tiên của năm mới được đánh số lại từ đầu; trong cùng năm không trùng số.

### Practice 4 — Bài tập 6 (Amount tự tính khi đổi Quantity/Price, procedure CalculateAmountAtRow)
- **Đề bài (tóm tắt):** Thêm Amount (Number(15), Non-negative) vào tabular section Products, đặt field ReadOnly trên form, tính lại Amount khi đổi Quantity hoặc Price, rồi tách phần tính toán sang procedure `CalculateAmountAtRow` để tránh lặp code.
- **Gợi ý 1 — Hướng đi:** Đây là bài code đầu tiên: dùng event **OnChange** của form field (cột của form table). Phép tính một dòng chạy ngay trên client; hai handler cùng gọi một procedure chung để tránh duplication.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Tạo **Document form** cho SalesInvoice; field ProductsAmount → ReadOnly. Field ProductsQuantity và ProductsPrice → tab Events → OnChange (tạo handler `&AtClient` trong **form module**). Dòng hiện tại của form table lấy qua `Items.Products.CurrentData`. Procedure chung `CalculateAmountAtRow` nhận dòng làm parameter, directive `&AtClient`.
- **Gợi ý 3 — Khung bài làm:**
  1. Thêm attribute Amount vào tabular section, F7.
  2. Tạo document form, đặt ReadOnly cho cột Amount.
  3. Tạo handler OnChange cho cột Quantity, viết phép tính; làm lại cho Price.
  4. Thấy hai handler giống nhau → chuyển phép tính sang `CalculateAmountAtRow`, hai handler chỉ gọi nó.
  ```bsl
  &AtClient
  Procedure CalculateAmountAtRow(___)
  	// gán Amount của dòng nhận được = ___ (từ Quantity và Price của chính dòng đó)
  EndProcedure

  &AtClient
  Procedure ___OnChange(Item) // handler của cột Quantity (làm tương tự cho Price)
  	CalculateAmountAtRow(___); // truyền dòng hiện tại của form table
  EndProcedure
  ```
- **Lỗi hay gặp:**
  - Gắn handler vào event của cả table thay vì của từng cột Quantity/Price.
  - Quên ReadOnly → người dùng sửa tay Amount, rồi bị ghi đè khi đổi Quantity.
  - Viết phép tính ở cả hai handler → phải sửa hai chỗ khi đổi thuật toán (chính là duplication mà đề cảnh báo).
  - Đặt Amount ở document thay vì ở tabular section Products.
- **Tự kiểm tra:** Ở Enterprise mode đổi Quantity hoặc Price → Amount của dòng đó cập nhật ngay; field Amount không sửa tay được. Đặt breakpoint trong `CalculateAmountAtRow` (Bài 8) để thấy cả hai handler cùng đi vào một procedure.

## Code demo của bài Theory

[ghi chú ngoài nguồn] Không có code demo cho Bài 1–4. Các nhánh `lesson/02-theory`, `lesson/03-theory`, `lesson/04-theory` của repo 1CJDCourse chỉ chứa module rỗng (ví dụ ObjectModule của Catalogs Carriers/Cities/StructuralUnits, ManagerModule của Employees, ObjectModule của PersonnelChange — đều là file trống). Demo của Bài 1–4 là thao tác khai báo metadata trong Designer, không viết code. Khi người học hỏi "code demo bài 1–4 ở đâu", trả lời đúng như vậy; không tự tạo code và gán cho bài.

## Video tham khảo

Video bài giảng trên YouTube có phạm vi trùng với bài này. Khi dẫn cho người học, nói "Bạn có thể tham khảo thêm về <chủ đề> của khóa tại đây: [<tên video>](link)" — không nói "khóa cũ/Junior", không dùng mã JC (mã JC trong danh sách chỉ để tra nội bộ). Quy ước đầy đủ: `references/video.md#video-junior-course`.

- [Hướng dẫn cài đặt nền tảng 1C:Enterprise](https://www.youtube.com/watch?v=hclmzfC2Lak&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=1) (3:57) — Bài 1 — Thao tác cơ bản. Ngoài giáo trình: cài đặt bản Training version, thư mục cài đặt, phím tắt khởi động _(mã nội bộ JC-2)_
- [Hello world với 1C:Enterprise](https://www.youtube.com/watch?v=BBmgzkbdcG8&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=2) (3:52) — Bài 1 — tạo infobase không có configuration; Bài 5-6 — `Message()` _(mã nội bộ JC-3)_
- [Infobase - Cơ sở thông tin](https://www.youtube.com/watch?v=Q3j_VFjTakc&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=3) (9:42) — Bài 1 — Kiến trúc 3 tầng, file infobase (.1CD), Thao tác cơ bản (thêm/xóa khỏi danh sách, Dump/Restore infobase) _(mã nội bộ JC-4)_
- [Metadata class](https://www.youtube.com/watch?v=tQQjrh3gBJk&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=4) (6:19) — Bài 1 — Metadata, Standard applied object prototypes; Bài 2 — metadata class / metadata object / data object _(mã nội bộ JC-5)_
- [Enumeration và Catalog - Liệt kê và danh mục](https://www.youtube.com/watch?v=AOKkvDYjsuw&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=5) (3:42) — Bài 3 — Catalog, Enumeration (attributes, tabular sections) _(mã nội bộ JC-6)_
- [Chứng từ và biểu ghi tích lũy](https://www.youtube.com/watch?v=dQt7_Ln8zVI&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=6) (4:50) — Bài 3 — Document; Bài 11 — Accumulation register, posting _(mã nội bộ JC-7)_
- [Giao diện người dùng cơ bản](https://www.youtube.com/watch?v=rn0hEz5Xc08&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=7) (5:44) — Bài 3 — Subsystem (sơ lược); Bài 9 — Subsystems, Panels, command interface _(mã nội bộ JC-8)_
- [Những thuộc tính chính của đối tượng Siêu dữ liệu](https://www.youtube.com/watch?v=ZBmyFnjNP-s&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=14) (4:59) — Bài 2 — standard attributes của class; Bài 3 — standard attributes Catalog (Ref, Code, Description…) và Document (Number, Date, Posted) _(mã nội bộ JC-15)_
- [Dữ liệu phân cấp](https://www.youtube.com/watch?v=nuFs1bCOQFc&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=18) (12:13) — Bài 4 — Hierarchy (Catalog và Chart of characteristic types) _(mã nội bộ JC-19)_
- [Mã danh mục, số chứng từ và tự động đánh số](https://www.youtube.com/watch?v=9HFCAWmdJCQ&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=19) (8:02) — Bài 4 — Code, number, autonumbering, periodicity _(mã nội bộ JC-20)_
- [Dữ liệu xác định trước](https://www.youtube.com/watch?v=EQLuZq69Nmw&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=20) (8:02) — Bài 4 — Predefined data; Bài 13 / 24 — predefined của Chart of characteristic types, Chart of accounts _(mã nội bộ JC-21)_
- [Làm việc với đối tượng Metadata](https://www.youtube.com/watch?v=opQkqATP8oA&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=24) (7:50) — Bài 1–2 — khái niệm metadata; `Metadata.` chỉ xuất hiện rải rác trong code mẫu (Bài 16, 19, 20, 21, 23). Ngoài giáo trình: duyệt cấu trúc metadata bằng code (global property Metadata) không có mục riêng trong giáo trình _(mã nội bộ JC-25)_
- [Các kiểu dữ liệu cơ sở](https://www.youtube.com/watch?v=jdO9y_nXLIQ&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=26) (9:23) — Bài 2 — Primitive types; Bài 5-6 — làm việc với kiểu, ValueIsFilled _(mã nội bộ JC-27)_

<!-- video-qa-thuchanh:start -->

Video giải đáp tình huống thực chiến và video thực hành từng bước liên quan tới bài này (thẻ chi tiết, triệu chứng, lưu ý khi giới thiệu: `references/video.md#video-qa-thuc-chien`, `references/video.md#video-thuc-hanh`; cùng mẫu câu dẫn ở trên):

- [Chuyển đổi ngôn ngữ trên cấu hình 1C:Enterprise](https://www.youtube.com/watch?v=lqhWahjse2I&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=2) (1:37) — cách đổi giao diện nền tảng sang tiếng Việt (giải đáp tình huống; Bài 1 chính) _(mã nội bộ QA-2)_
- [Xây dựng các trường tự động điền](https://www.youtube.com/watch?v=8klMmoJXBCk&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=10) (2:02) — giá trị mặc định khi tạo chứng từ (giải đáp tình huống; Bài 4 chính) _(mã nội bộ QA-10)_
- [Hướng dẫn truy cập bản dùng thử 1C:AccountingSuite](https://www.youtube.com/watch?v=8Vmkv3KP5ek&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=20) (1:16) — xem thử một ứng dụng 1C thực tế qua trình duyệt (giải đáp tình huống; Bài 1 chính) _(mã nội bộ QA-20)_
- [Kết xuất kết nhập cấu hình bằng file *.1CD](https://www.youtube.com/watch?v=3X0EAToibUg&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=27) (3:29) — mang một file infobase sang máy hoặc thư mục khác (giải đáp tình huống; Bài 1 chính) _(mã nội bộ QA-27)_
- [Hướng dẫn publish Infobase 1C:Enterprise lên web server](https://www.youtube.com/watch?v=P_bwSfxAV8I&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=28) (7:21) — publish infobase lên web server (IIS) (giải đáp tình huống; Bài 1 chính) _(mã nội bộ QA-28)_
- [Giới thiệu nền tảng 1C:Enterprise](https://www.youtube.com/watch?v=Dahr2ACNN74&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=2) (13:59) — tổng quan nền tảng 1C:Enterprise (thực hành case study; Bài 1 chính) _(mã nội bộ P1-1)_
- [Cài đặt 1C:Enterprise phiên bản đào tạo](https://www.youtube.com/watch?v=sJqX17GGRt0&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=3) (2:19) — cài đặt bản 1C:Enterprise đào tạo (thực hành case study; Bài 1 chính) _(mã nội bộ P1-2)_
- [Lưu trữ thông tin sinh viên và môn học](https://www.youtube.com/watch?v=UGXVLOKRaGw&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=4) (12:19) — Catalog, phân cấp và tabular section (thực hành case study; Bài 3 chính) _(mã nội bộ P1-3)_
- [Lưu trữ thông tin nhân viên](https://www.youtube.com/watch?v=WF19J3tct0I&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=5) (9:37) — catalog cấp dưới và lịch sử lương theo tháng (thực hành case study; Bài 4 chính) _(mã nội bộ P1-4)_
- [Lưu trữ thông tin các chuyến du lịch](https://www.youtube.com/watch?v=PwqP4GODNrY&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=6) (13:15) — tạo chứng từ trên cơ sở chứng từ khác (Input on basis) (thực hành case study; Bài 3 chính) _(mã nội bộ P1-5)_
- [Tự động lấy đơn vị tính của sản phẩm](https://www.youtube.com/watch?v=RKAGi62Vy5E&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=12) (8:16) — điền thuộc tính sản phẩm vào dòng chứng từ (giải đáp tình huống; Bài 3 liên quan) _(mã nội bộ QA-12)_
- [Báo động tồn kho thấp với màu chữ hiển thị](https://www.youtube.com/watch?v=0JbOMl80lnY&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=18) (13:09) — tô màu cảnh báo tồn kho thấp (giải đáp tình huống; Bài 3 liên quan) _(mã nội bộ QA-18)_
- [Lọc dữ liệu chọn sản phẩm theo hãng](https://www.youtube.com/watch?v=EfF2acfP2Y8&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=19) (6:30) — lọc danh sách chọn theo một trường khác (giải đáp tình huống; Bài 3 liên quan) _(mã nội bộ QA-19)_
- [Tùy chỉnh ngôn ngữ theo người dùng](https://www.youtube.com/watch?v=wo7G7jSPtBE&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=26) (4:30) — hiển thị ngôn ngữ khác nhau cho từng người dùng (giải đáp tình huống; Bài 2 liên quan) _(mã nội bộ QA-26)_
- [Ghi nhận luân chuyển dòng tiền](https://www.youtube.com/watch?v=YzhM76Wy9fk&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=7) (18:29) — quỹ tiền mặt: thu/chi, posting, số dư trên form và đánh số chứng từ (thực hành case study; Bài 4 liên quan) _(mã nội bộ P1-6)_
- [Ghi nhận thay đổi tỷ giá hối đoái](https://www.youtube.com/watch?v=9_m7XqHPZlA&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=1) (9:04) — information register theo ngày và biểu đồ (thực hành case study; Bài 4 liên quan) _(mã nội bộ P2-1)_
- [Ghi nhận thay đổi giá mua tiền tệ](https://www.youtube.com/watch?v=lYPmr3Rxi3g&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=2) (8:11) — information register nhiều dimension (thực hành case study; Bài 3 liên quan) _(mã nội bộ P2-2)_
- [Lưu trữ và báo cáo kết quả học tập của sinh viên](https://www.youtube.com/watch?v=NhFE1uwi7Hw&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=3) (14:56) — chấm điểm qua chứng từ và báo cáo trung bình có tô màu (thực hành case study; Bài 3 liên quan) _(mã nội bộ P2-3)_
- [Hệ thống cho thuê xe điện](https://www.youtube.com/watch?v=wWGXT2KSul8&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=4) (10:40) — một chứng từ ghi vào hai register (thực hành case study; Bài 3 liên quan) _(mã nội bộ P2-4)_
- [Tạo lập hệ thống thông tin thư viện](https://www.youtube.com/watch?v=3DMFgUjg2Js&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=5) (24:38) — mượn – trả và tạo phiếu trả từ phiếu mượn (thực hành case study; Bài 3 liên quan) _(mã nội bộ P2-5)_
- [Hạch toán sản phẩm dịch vụ](https://www.youtube.com/watch?v=GFsS9x1bOTQ&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=7) (15:54) — tách hàng hóa/dịch vụ và bật tắt tính năng bằng Functional option (thực hành case study; Bài 3 liên quan) _(mã nội bộ P2-7)_

<!-- video-qa-thuchanh:end -->


---

# § bai-05-06

# Bài 5-6 — Giới thiệu lập trình 1C: cú pháp, procedure/function, biến, toán tử, vòng lặp, collections

## Khái niệm chính

### Module và cấu trúc module
- 1C:Enterprise script là ngôn ngữ lập trình chuyên biệt (domain-specific), dành cho cả lập trình viên chuyên nghiệp lẫn người dùng.
- Code được lưu trong **module**. Hầu hết configuration object đều có module (một số object có nhiều module).
- Cấu trúc object module có 3 vùng, **không vùng nào bắt buộc**:
  - variable declaration area (khai báo biến)
  - procedure and function area
  - main program area
- **Common module** chỉ có thể có procedure and function area.
- Mỗi module là một phần của configuration, không tồn tại độc lập. Toàn bộ code trong một module chạy trong một context duy nhất.

### Quy tắc đặt tên
- Tên biến, procedure, function: chuỗi chữ cái, chữ số, dấu gạch dưới `_`; phải bắt đầu bằng chữ cái hoặc `_`.
- Không được trùng reserved words hoặc tên property đang có sẵn trong context hiện tại.
- Tên **không phân biệt hoa thường** (not case sensitive).

### Comment
- Comment bắt đầu sau `//` và kết thúc ở cuối dòng.

### Reserved words
`If, Then, ElsIf, Else, EndIf, For, Each, In, To, While, Do, EndDo, And, Or, Not, Procedure, Function, EndProcedure, EndFunction, Var, Goto, Return, Continue, Break, New, Execute, Try, Except, Raise, EndTry`
- Không được dùng làm tên biến, attribute của configuration object, tên procedure/function.

### Procedure và Function
- Method chia thành procedure và function: **procedure không trả về giá trị**, **function luôn trả về giá trị** (đôi khi ngầm định).
- Quy tắc mô tả: keyword `Procedure`/`Function` → tên → cặp ngoặc (có thể chứa parameters) → `Export` sau ngoặc nếu cần truy cập từ module khác → thân (code 1C) → `EndProcedure`/`EndFunction`.
- Quy ước đặt tên: procedure đặt theo **hành động** nó thực hiện; function đặt theo **giá trị** nó trả về.
- Function không có `Return` (hoặc có `Return` chỉ trong một nhánh) sẽ trả về **Undefined** ở các trường hợp còn lại.
- Trong procedure, `Return` dùng độc lập để thoát procedure ngay lập tức.

### Parameters (arguments)
- Parameter có thể bắt buộc (mandatory) hoặc tùy chọn (optional). Muốn optional thì gán **giá trị mặc định** trong mô tả procedure/function; nếu không truyền, parameter nhận giá trị mặc định.
- Khi gọi có thể bỏ qua optional parameters bằng dấu phẩy liên tiếp.
- Good practice: đặt parameter bắt buộc trước, optional sau.
- Hai cách truyền: **by reference** (mặc định) và **by value** (keyword `Val`).
  - By reference: thay đổi parameter bên trong method sẽ thay đổi biến gốc của nơi gọi (side effect).
  - By value (`Val`): làm việc với vùng nhớ mới, giá trị gốc không đổi.
  - Lưu ý với aggregate object (ví dụ Array) truyền by value: không thể gán giá trị khác cho actual parameter ở nơi gọi, nhưng **có thể thay đổi chính object** (ví dụ `Clear()` làm mảng rỗng).

### Variables
- Variable là tham chiếu tới vùng nhớ chứa giá trị có kiểu; bản thân giá trị không đổi kiểu từ lúc tạo.
- 1C dùng **dynamic typing**: một biến có thể tham chiếu tới giá trị khác kiểu tại các thời điểm khác nhau.
- Không bắt buộc khai báo tường minh; biến chưa được gán giá trị thì chứa **Undefined**.
- Khai báo tường minh bằng `Var` (nhiều biến cách nhau dấu phẩy). Khai báo ngầm định xảy ra khi gán giá trị lần đầu.
- Không được dùng trong biểu thức biến chưa được khai báo (tường minh hoặc ngầm định).
- `Export` sau khai báo biến: biến truy cập được khi context module này được truy cập từ module khác. Phải ghi `Export` **riêng cho từng biến**. Không có ý nghĩa với biến trong procedure/function.
- Phạm vi (scope) — 3 vùng khai báo:
  - Variable definition area của **managed application program module** → global variables. Global variable có `Export` dùng được ở mọi procedure/function của mọi client program module trong configuration.
  - Variable definition area trong một module → module variables. Dùng được trong mọi procedure/function của module đó; có `Export` thì truy cập được từ module khác qua context của module khai báo.
  - Trong procedure/function → local variables, chỉ thấy bên trong procedure/function đó.
- Hai biến cùng tên trong hai procedure khác nhau (không phải global) là hai biến local khác nhau. Nếu tên đã là global thì mọi lần dùng tên đó đều gọi biến global.
- Cách duy nhất tạo biến local trùng tên biến global: khai báo tường minh bằng `Var`.
- Khai báo local variable phải đặt **ở đầu** procedure/function, trước mọi operator/expression.

### Message to user
- Cách đơn giản: procedure global context `Message(<MessageText>)` — báo người dùng thao tác sai hoặc kết quả (thành công/thất bại).

### Syntax assistant
- Platform có 2 loại tài liệu: **help** và **syntax assistant**, đều trong menu Help.
- Syntax assistant hiển thị ở sidebar, có thể pin hoặc thu gọn.
- Lệnh **Search in Syntax assistant** (context menu, platform panel, menu Help, hotkey **Ctrl + F1**) tìm đoạn text đang chọn.
- Tab **Index**: nhập text, double-click (hoặc chọn + Enter) để xem.
- Tra theo nhánh: ví dụ "Global context" → "Functions for working with String type values".
- Nút **Find current element in the tree** chuyển sang tab Content và highlight mục đang xem.

### Operators (Bài 6)
- Hai loại: variable declaration operators và executable operators.
- Operators ngăn cách bằng **dấu chấm phẩy**; xuống dòng không phải kết thúc operator (If, loop viết nhiều dòng, chấm phẩy chỉ ở cuối).
- Khi mô tả procedure/function **không** đặt chấm phẩy — đặt sẽ gây compilation error.
- Được viết nhiều operator trên một dòng nhưng không khuyến khích (khó đọc).
- Expression: công thức toán học, logic hoặc chuỗi tính ra một giá trị; gồm constants, variables, functions nối bằng phép toán logic/số học. Logical expressions có thể là điều kiện trong If, While, For.

### Arithmetic operations
| Name | Expression |
| --- | --- |
| Addition | Operand1 + Operand2 |
| Subtraction | Operand1 – Operand2 |
| Multiplication | Operand1 * Operand2 |
| Division | Operand1 / Operand2 |
| Remainder in Division | Operand1 % Operand2 |
| Unary minus | -Operand1 |

- Ngữ nghĩa phép toán phụ thuộc **operand thứ nhất**. Operand thứ hai sai kiểu sẽ được chuyển kiểu theo type conversion rules; operand thứ nhất sai kiểu có thể được chuyển hoặc gây execution error.
- Kiểu hợp lệ:
  - Addition: Number + Number; Date + Number (cộng số giây vào ngày).
  - Subtraction: Number - Number; Date - Number (trừ số giây); Date - Date (kết quả là chênh lệch tính bằng giây).
  - Multiplication: Number * Number. Division: Number / Number. Modulo: Number % Number.

### Concatenation
- Dùng `+` để nối chuỗi; độ dài kết quả = tổng độ dài. Operand thứ hai trở đi không phải String sẽ được chuyển sang String.

### Logical operations
- Kết quả Boolean: **True** / **False**. Hai loại: comparison operations và Boolean operations.
- Comparison: `>`, `>=`, `=`, `<>`, `<`, `<=`.
  - `>`, `>=`, `<`, `<=` định nghĩa cho Number–Number, String–String, Date–Date.
  - `=` và `<>` định nghĩa cho Any type.
- Boolean: **AND** (conjunction), **OR** (disjunction), **NOT** (negation).
- Biểu thức logic tính từ trái sang phải; dùng ngoặc tròn để tránh mơ hồ.
- Thứ tự ưu tiên: Level 1 — operands trong ngoặc tròn; Level 2 — NOT; Level 3 — AND; Level 4 — OR.
- Chỉ tính phần cần thiết (short-circuit): trong `Price > 0 AND CheckSum()`, nếu `Price <= 0` thì `CheckSum()` không được gọi.

### New
- Operator `New` tạo giá trị của một số kiểu; có thể có parameters trong ngoặc nếu constructor của kiểu đó định nghĩa.

### If
- Điều khiển luồng theo kết quả một hoặc nhiều biểu thức logic; có thể có số lượng tùy ý các cặp `ElsIf` - `Then`; `Else` là tùy chọn.
- Khi một nhánh đúng, code nhánh đó chạy rồi thoát khối; các điều kiện `ElsIf` phía sau **không được tính**.

### Loops
- **For**: biến được gán `<Expression 1>`, tự tăng 1 mỗi vòng; lặp khi biến `<=` `<Expression 2>`. Điều kiện luôn kiểm tra trước khi chạy vòng.
- **Break**: dừng vòng lặp ngay. **Continue**: chuyển ngay sang bước kế tiếp (có thể kết thúc vòng lặp nếu biến vượt `<Expression 2>`); các lệnh sau nó trong vòng hiện tại không chạy.
- **For Each**: duyệt collection; mỗi vòng gán phần tử kế tiếp vào biến, chạy tới hết collection hoặc tới `Break`.
- **While**: lặp khi biểu thức logic là True; điều kiện kiểm tra trước.

### Collections
- Universal objects: **Array, ValueList, ValueTable, ValueTree, Structure, Map**.
- **Array**: các phần tử nối tiếp, truy cập theo **Index** (bắt đầu từ 0). Phần tử có thể là kiểu bất kỳ, kể cả Array.
- **ValueList**: mảng động một chiều tạo ra để giải quyết các tác vụ giao diện. Mỗi phần tử có kiểu đặc biệt **ValueListItem**, lưu: value (kiểu bất kỳ), representation (String), check mark (Boolean), picture (Picture).
- **ValueTable**: không lưu vào database; tạo tập giá trị động, thêm/sửa/xóa/sort. Các cột có thể khác kiểu (cột có thể composite type). Có thể sort, copy, unload và load values. Truy cập rows và collection of columns.
- **ValueTree**: dữ liệu phân cấp dạng cây — bản chất là value table mà row có thể có subordinate rows. Mỗi row có tối đa một parent; row không có parent là top-level row.
- **Structure**: tập giá trị gắn với key (cặp **KeyAndValue**); key duy nhất trong structure; truy cập value như property theo tên key.
  - Insert hai lần cùng key → vẫn chỉ một cặp, value lấy theo lần cuối.
  - Truy cập key không tồn tại → lỗi. Dùng `Property()` (function, trả True/False) để kiểm tra; có thể truyền biến thứ hai để nhận value.
- **Map**: cặp key-value, nhưng key có thể là kiểu bất kỳ (String, Number, Date, Reference...). Lấy value bằng ngoặc vuông hoặc `Get()` (không truy cập như property). Là indexed collection, lấy value rất nhanh. `Get()` với key không có → trả Undefined.
- Map và Structure **không giữ thứ tự** key/value đã thêm.

## Cú pháp & ví dụ code

### Comment
```bsl
Factor = 10; // This is a comment

// And this is a comment

This is not a comment
```

### Khung procedure/function
```bsl
Procedure ProcedureName()

// procedure body

EndProcedure

Function FunctionName()

// function body

EndFunction
```

### Procedure vs Function
```bsl
Procedure CalculateAmount(Amount, Quantity, Price) Export

    Amount = Quantity * Price;

EndProcedure

Function CalculatedAmount(Quantity, Price) Export

    Return Quantity * Price;

EndFunction
```

### Function và giá trị trả về
```bsl
Function FunctionWithoutReturnedValue()

    A = 1;

EndFunction
```
(Trả về **Undefined**.)

```bsl
Function FunctionSometimesWithoutReturnedValue(B)

    A = 1;

    If B = 2 Then

        Return A;

    EndIf;

EndFunction
```
(Trả về A chỉ khi B = 2, còn lại trả về Undefined.)

```bsl
Function FunctionWithReturnedValue()

    A = 1;

    Return A;

EndFunction
```
(Trả về 1.)

### Return trong procedure
```bsl
Procedure SaveFile(FileName)

    If IsBlankString(FileName) Then

        Message("File name is a required field for file saving");

        Return;

    EndIf;

... // file save code

EndProcedure
```

### Optional parameters
```bsl
Procedure Example(MessageToUserText, Date = '00010101', AdditionalText = "", NumberOfAttempts = 1, Cancel = False, Table = Undefined)
```
Các cách gọi:
```bsl
Example("Hello");

Example("Hello", CurrentDate, "Some text");

Example("Hello",,, 2,, DataTable);
```
Cách gọi bất tiện khi tham số bắt buộc nằm cuối:
```bsl
Example("Hello",,,,, DataTable);
```
*Incorrect*:
```bsl
Procedure Example(MessageToUserText, Date = '00010101', AdditionalText = "", NumberOfAttempts = 1, Cancel = False, Table)
```
*Correct*:
```bsl
Procedure Example(MessageToUserText, Table, Date = '00010101', AdditionalText = "", NumberOfAttempts = 1, Cancel = False)
```

### By reference (side effect)
```bsl
Procedure MultiplyAmountByFactor(Amount, Factor)

    If Factor = 0 Then

        Factor = 1;

    EndIf;

    Amount = Amount * Factor;

EndProcedure
```
```bsl
Factor = 0;

Amount = 10;

MultiplyAmountByFactor(Amount, Factor);

// Factor = 1 here even though we don't need it to be changed
```

### By value (Val)
```bsl
Procedure MultiplyAmountByFactor(Amount, Val Factor)

    If Factor = 0 Then

        Factor = 1;

    EndIf;

    Amount = Amount * Factor;

EndProcedure
```

### Aggregate object truyền by value
```bsl
Procedure MyProcedure()

    Numbers = New Array;

    Numbers.Add(4);

    Numbers.Add(12);

    // Array contains 2 values

    PassByValue(Numbers);

    // Array is empty, but still it's an array

EndProcedure

Procedure PassByValue(Val TestParameter)

    // Array contains 2 values

    TestParameter.Clear();

    // Array contains no values

    // Change of formal parameter

    TestParameter = 10;

    // Formal parameter value has been changed

EndProcedure
```

### Khai báo biến
```bsl
Var User;

Var StartDate, EndDate;
```
```bsl
User = CurrentUser;

StartDate = Date(2000, 1, 1);

EndDate = AddMonth(StartDate, 12);

Quantity = 10;
```
```bsl
Var MyGlobalVar1, MyGlobalVar2 Export;
```
(Tài liệu ghi: "In this example, only the first variable will be exported." [ghi chú ngoài nguồn: theo chính quy tắc trong tài liệu "Export phải ghi riêng cho từng biến", `Export` ở đây đứng sau `MyGlobalVar2`, nên câu này có thể là lỗi in; cần đối chiếu lại với giảng viên.])

### Vị trí khai báo local variable
*Incorrect*:
```bsl
Procedure MoveDate(Date, Seconds)

    Hours = Seconds / 3600;

    Var Days;

    Days = Hours / 24;

EndProcedure
```
*Correct*:
```bsl
Procedure MoveDate(Date, Seconds)

    Var Days;

    Hours = Seconds / 3600;

    Days  = Hours / 24;

EndProcedure
```

### Message
```bsl
Message("Recalculation completed successfully");

Message("Description is a required field");
```

### Nhiều operator trên một dòng (không khuyến khích)
```bsl
Quantity = 10; Price = 50; Amount = Quantity * Price;

If Quantity <> 0 Then Price = Amount / Quantity; Else Price = 0; EndIf;
```

### Concatenation
```bsl
FullName = SecondName + " " + FirstName;

Message("Recalculation completed successfully in " + CalculationTime + " seconds");

// CalculationTime is a number
```

### Short-circuit
```bsl
Price > 0 AND CheckSum()
```

### New
```bsl
// #1

CreationWithTypeName = New Array;

// #2

ArrayType = Type("Array");

CreationWithTheType = New(Type);
```
[ghi chú ngoài nguồn: theo ngữ cảnh, dòng cuối có lẽ ý là `New(ArrayType)`; giữ nguyên như tài liệu.]

### If
```bsl
If Quantity = 0 And Amount = 0 Then

    Message("Quantity and Amount are required fields.");

EndIf;

If Quantity <> 0 Then

    Price = Amount / Quantity;

Else // optional part

    Price = 0;

EndIf;

If MonthOfDate >= 1 And MonthOfDate <= 3 Then

    Quarter = 1;

ElsIf MonthOfDate >= 4 And MonthOfDate <= 6 Then // optional part

    Quarter = 2;

ElsIf MonthOfDate >= 7 And MonthOfDate <= 9 Then // optional part

    Quarter = 3;

Else // optional part

    Quarter = 4;    

EndIf;

Message("It's a quarter #" + Quarter);
```

### For
```bsl
For <Variable name> = <Expression 1> To <Expression 2> Do

// Statements

[Break;]

// Statements

[Continue;]

// Statements

EndDo;
```
```bsl
// Products is a tabular section with columns "Product" and "Price". Count() is a method of a tabular section, returning count of rows.

For i = 0 To Products.Count() - 1 Do

    // Writing a table row found by index to a variable ProductsRow

    ProductsRow = Products[i];

    // DesiredProduct - is a variable with some searching product

    If ProductsRow.Product = DesiredProduct Then

        Price = ProductsRow.Price;

        Break;

    EndIf;

EndDo;
```

### For each
```bsl
For each <Variable name 1> In <Variable name 2> Do

// Statements

[Break;]

// Statements

[Continue;]

// Statements

EndDo;
```
```bsl
Function TotalAmountOfProducts(Products)

    Total = 0; 

    For each ProductRow In Products Do

        Total = Total + ProductRow.Amount;

    EndDo;

    Return Total;

EndFunction
```

### While
```bsl
While <Logical expression> Do

// Statements

[Break;]

// Statements

[Continue;]

// Statements

EndDo;
```
```bsl
DocumentNumber = "12345";

RequiredLengthOfNumber = 9;

// StrLen() method returns the number of characters in a string

While StrLen(DocumentNumber) < RequiredLengthOfNumber Do

    DocumentNumber = "0" + DocumentNumber;

EndDo;

// The value of the DocumentNumber variable is "000012345" now
```

### Array
```bsl
Array = New Array;

Array.Add("January"); // Index = 0

Array.Add("February"); // Index = 1

Array.Add("March"); // Index = 2

Array.Add("April"); // Index = 3

Array.Add("May"); //...

Array.Add("June");

Array.Add("July");

Array.Add("August");

Array.Add("September");

Array.Add("October");

Array.Add("November");

Array.Add("December");

NumberOfMonth = 4;

Month = Array.Get(NumberOfMonth - 1); // Month = "April"
```

### ValueList
```bsl
ValueList = New ValueList;

ValueList.Add(1, "January"); // Index = 0

ValueList.Add(2, "February"); // Index = 1

ValueList.Add(3, "March"); // Index = 2

ValueList.Add(4, "April"); // Index = 3

ValueList.Add(5, "May"); //...

ValueList.Add(6, "June");

ValueList.Add(7, "July");

ValueList.Add(8, "August");

ValueList.Add(9, "September");

ValueList.Add(10, "October");

ValueList.Add(11, "November");

ValueList.Add(12, "December");

NumberOfMonth = 4;

Month = ValueList.FindByValue(NumberOfMonth);
```

### ValueTable
```bsl
ValueTable = New ValueTable;

ValueTable.Columns.Add("FullName", New TypeDescription("String")); 

// If you don't specify a type, you can write a value of any type to the column.

ValueTable.Columns.Add("Seniority"); // years of work experience

ValueTable.Columns.Add("DateOfBirth", 

New TypeDescription("Date",,,,, New DateQualifiers(DateFractions.Date)));

NewRow = ValueTable.Add();

NewRow.FullName     = "John Doe";

NewRow.DateOfBirth  = Date(1970, 12, 31);

NewRow.Seniority    = 8; // Number

NewRow = ValueTable.Add();

NewRow.FullName     = "Jane Doe";

NewRow.DateOfBirth  = Date(1985, 1, 5);

NewRow.Seniority    = "None"; // String
```

### ValueTree
```bsl
ValueTree = New ValueTree;

ValueTree.Columns.Add("City", New TypeDescription("String")); 

ValueTree.Columns.Add("Population", New TypeDescription("Number"));

NewCountryRow = ValueTree.Rows.Add(); // top-level row

NewCountryRow.City          = "UK";

NewCountryRow.Population    = 68138484;

NewCountryRow = NewCountryRow.Rows.Add(); // second level row

NewCountryRow.City          = "England";

NewCountryRow.Population    = 56489800;

NewRow = NewCountryRow.Rows.Add(); // third level row

NewRow.City         = "London";

NewRow.Population   = 8799800;

NewRow = NewCountryRow.Rows.Add();  

NewRow.City         = "Birmingham";

NewRow.Population   = 2293099;

NewCountryRow = ValueTree.Rows.Add();

NewCountryRow.City          = "France";

NewCountryRow.Population    = 68042591;

NewRow = NewCountryRow.Rows.Add();  

NewRow.City         = "Paris";

NewRow.Population   = 2229621;

NewRow = NewCountryRow.Rows.Add();

NewRow.City         = "Marseille";

NewRow.Population   = 855393;
```

### Structure
```bsl
// 1. Empty structure for insertion of keys and values

Structure = New Structure;

Structure.Insert("FirstName", "John");

Structure.Insert("SecondName", "Doe");

// 2. In this case both keys have Undefined value after initialization

Structure = New Structure("FirstName, SecondName");

// a) usage of Insert method

Structure.Insert("FirstName", "John");

// b) usage of access as a property

Structure.FirstName = "John";

// c) usage with square brackets

Structure["SecondName"] = "Doe";

// 3. Initialization with keys and values

Structure = New Structure("FirstName, SecondName", "John", "Doe");
```
```bsl
Structure = New Structure;

Structure.Insert("FirstName", "John");

Structure.Insert("FirstName", 752);

// This structure contains one Key "FirstName" with the value 752
```
```bsl
// Option 1

If Structure.Property("FirstName") Then

    FirstName = Structure.FirstName;

EndIf;

// Option 2

FirstName = Undefined;

Structure.Property("FirstName", FirstName);

// In this case if Structure contains "FirstName" key, then its value will be assigned to FirstName variable (as if the code FirstName = Structure.FirstName was executed), otherwise method will return Undefined value to the FirstName variable
```

### Map
```bsl
// 1. setting values

Map = New Map;

// a) 

Map.Insert(10, "Even");

// b)

Map[11] = "Odd";

For Each KeyAndValue In Map Do

    Message("Key: " + KeyAndValue.Key + ", Value: " + KeyAndValue.Value);

EndDo;

// 2. getting values

Map = New Map;

Map[True] = "True";

// a)

ValueOfTrueKey  = Map[True];

// b) If Map doesn't contain such Key, it returns Undefined

ValueOfFalseKey = Map.Get(False);

Message(ValueOfTrueKey = "True");

// checking if the value is Undefined with a message

Message(ValueOfFalseKey = Undefined);
```

## Thuộc tính/thiết lập quan trọng trong Designer
- Menu **Help** → help và **Syntax assistant**.
- Lệnh **Search in Syntax assistant** — hotkey **Ctrl + F1** (context menu / platform panel / menu Help).
- Syntax assistant: tab **Index** (tìm kiếm), tab **Content** (cây mục lục), nút **Find current element in the tree**.
- Nhánh tra cứu ví dụ: **Global context** → **Functions for working with String type values**.

## Lỗi thường gặp / lưu ý
- Khai báo local variable (`Var`) sau operator/expression → lỗi: *"Variable declarations must be placed at beginning of module, procedure, or function"*.
- Đặt dấu chấm phẩy sau dòng mô tả procedure/function → compilation error.
- Dùng biến chưa khai báo (tường minh hoặc ngầm định) trong biểu thức → không được phép.
- Truyền by reference (mặc định) có thể gây side effect ngoài ý muốn → dùng `Val` khi không muốn thay đổi biến gốc.
- Truyền aggregate object (Array...) bằng `Val` vẫn có thể bị thay đổi nội dung (ví dụ `Clear()`).
- Function quên `Return` ở một số nhánh → trả về Undefined.
- Đặt parameter bắt buộc sau optional → lời gọi bất tiện (`Example("Hello",,,,, DataTable);`).
- Truy cập key không tồn tại trong Structure → lỗi; dùng `Property()` để kiểm tra trước.
- Đặt tên trùng reserved words hoặc tên property trong context hiện tại → không được phép.
- Không nên viết nhiều operator trên một dòng (khó đọc).

## Điểm cần nhớ
- Procedure không trả giá trị; Function luôn trả giá trị (mặc định Undefined nếu không có `Return`). `Export` để gọi từ module khác.
- Parameter mặc định truyền **by reference**; thêm `Val` để truyền by value. Optional parameter = có giá trị mặc định, đặt sau parameter bắt buộc.
- Dynamic typing; biến chưa gán = Undefined; `Var` phải nằm đầu procedure/function; `Export` ghi riêng cho từng biến.
- Ba phạm vi biến: global (managed application module), module, local.
- Thứ tự ưu tiên logic: ngoặc → NOT → AND → OR; tính short-circuit, từ trái sang phải.
- Date + Number cộng giây; Date - Date ra số giây.
- Sáu collection: Array (index từ 0), ValueList (ValueListItem), ValueTable, ValueTree, Structure (key là tên, duy nhất, `Property()`), Map (key kiểu bất kỳ, `Get()` trả Undefined nếu thiếu); Structure và Map không giữ thứ tự.
- Dùng Syntax assistant (Ctrl + F1) thường xuyên để tra cứu ngôn ngữ.

## Thẻ gợi ý bài thực hành (Practice 5-6)

> Thẻ bám theo đề "5-6. Practice.docx". Ở bài này bạn mới học ngôn ngữ; directive `&AtServer` / `&AtServerNoContext` được đề cho sẵn, giải thích chi tiết ở Bài 7.

### Bài tập 1 — DocumentTotal tự tính từ tabular section Products
- **Đề bài (tóm tắt):** Thêm attribute DocumentTotal vào SalesInvoice, hiển thị dưới bảng Products dạng Label field; tính lại khi bảng Products thay đổi (event OnChange của form table) và ghi vào `Object.DocumentTotal`.
- **Gợi ý 1 — Hướng đi:** Cộng dồn trong vòng lặp **For each** qua các dòng của tabular section (mục "Loops", "For each"); dùng một biến local tích lũy (mục "Variables", "Arithmetic operations").
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Attribute `DocumentTotal` (Number) của document; trên form kéo xuống dưới table, kiểu item **Label field**. Form table `Products` → event **OnChange** → handler `&AtClient` trong form module; dữ liệu dòng lấy từ `Object.Products`.
- **Gợi ý 3 — Khung bài làm:**
  1. Thêm attribute, F7, đặt field lên form.
  2. Tạo handler OnChange của table (không phải của cột).
  3. Khởi tạo biến tích lũy = 0, duyệt các dòng, cộng Amount, cuối cùng gán vào attribute.
  ```bsl
  &AtClient
  Procedure ProductsOnChange(Item)
  	Total = ___;            // giá trị khởi đầu
  	For Each ___ In ___ Do  // duyệt các dòng của tabular section
  		// cộng Amount của dòng vào Total
  	EndDo;
  	___ = Total;            // ghi vào attribute của document
  EndProcedure
  ```
- **Lỗi hay gặp:**
  - Gắn vào OnChange của cột Amount → không chạy khi xóa/thêm dòng.
  - Quên khởi tạo biến = 0 → biến là Undefined, phép cộng lỗi.
  - Gán vào biến form thay vì `Object.DocumentTotal` → giá trị không được ghi cùng document.
- **Tự kiểm tra:** Đổi Quantity, Price, thêm và xóa dòng → tổng dưới bảng đổi theo; ghi document, mở lại vẫn đúng.

### Bài tập 2 — Giá bán tối thiểu (MinimumSalePrice)
- **Đề bài (tóm tắt):** Thêm MinimumSalePrice vào catalog Products; khi đổi Price hoặc Product trong bảng Products của SalesInvoice, nếu giá thấp hơn tối thiểu thì đổi về giá tối thiểu và báo "Minimum sale price for <product> is <price>"; không lặp code và vẫn tính lại Amount.
- **Gợi ý 1 — Hướng đi:** Một procedure kiểm tra dùng chung cho cả hai handler (mục "Procedure và Function"); đọc attribute qua reference là việc của server nên cần function `&AtServerNoContext` như đề cho. Câu điều kiện **If**, ghép chuỗi bằng **concatenation** `+`, hiển thị bằng `Message()`. Thoát sớm bằng **Return trong procedure** khi không có dòng hiện tại.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Attribute `MinimumSalePrice` (Number) của catalog Products. Form module SalesInvoice: handler OnChange của cột Price và cột Product (`&AtClient`); procedure kiểm tra `&AtClient`; function `MinimumSalePriceOfProduct(Product)` với `&AtServerNoContext` trả về `Product.MinimumSalePrice`.
- **Gợi ý 3 — Khung bài làm:**
  1. Thêm attribute vào catalog, nhập giá tối thiểu cho vài product.
  2. Viết function server theo chữ ký đề cho.
  3. Viết procedure kiểm tra: lấy dòng hiện tại, nếu Undefined thì thoát; so sánh giá, sửa giá và báo message.
  4. Gọi procedure kiểm tra từ handler Product và Price; ở handler Price vẫn gọi tính lại Amount **sau** khi kiểm tra.
  ```bsl
  &AtClient
  Procedure ControlMinimumSalesPrice()
  	CurrentData = ___;      // dòng hiện tại của form table
  	If ___ Then             // chưa có dòng nào
  		Return;
  	EndIf;
  	// lấy giá tối thiểu qua function server, so sánh, sửa giá, Message(...)
  EndProcedure
  ```
- **Lỗi hay gặp:**
  - Viết `CurrentData.Product.MinimumSalePrice` ngay trên client → không đọc được attribute qua reference ở client.
  - Tính Amount trước rồi mới sửa giá → Amount không khớp giá mới.
  - Chép cùng đoạn kiểm tra vào hai handler → duplication.
  - Quên khoảng trắng trong chuỗi message → "Minimum sale price forCable".
  - [ghi chú ngoài nguồn] Ở bản cuối của cấu hình mẫu, cột Price đã ReadOnly và giá lấy từ register ProductPrices (các bài sau), nên đừng ngạc nhiên nếu thấy cấu hình cuối khóa không còn handler của cột Price.
- **Tự kiểm tra:** Chọn product có MinimumSalePrice = 100, gõ giá 50 → giá tự thành 100, xuất hiện message đúng định dạng, Amount tính theo 100. Đổi sang product có giá tối thiểu cao hơn → cũng được kiểm tra.

### Bài tập 3 — ValidUntil và "Days left" trên form hợp đồng
- **Đề bài (tóm tắt):** Thêm ValidUntil (Date, không bắt buộc) vào CounterpartyContracts; tạo item form có field "Days left" = số ngày từ hôm nay đến ValidUntil; ẩn field khi ValidUntil trống; tính lại và đổi hiển thị khi mở form và khi đổi ValidUntil.
- **Gợi ý 1 — Hướng đi:** Phép trừ **Date − Date** cho ra **số giây** (mục "Arithmetic operations") → đổi ra ngày rồi `Round()`. `ValueIsFilled()` kiểm tra date đã điền. Ẩn/hiện bằng property `Visible` của form item. Gom tính toán và ẩn/hiện vào procedure riêng, gọi từ hai event để không lặp code.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Attribute `ValidUntil` (Date) của catalog. Item form → form attribute `DaysLeft` (Number) đặt lên form. Event form **OnOpen** và event **OnChange** của field ValidUntil. `CurrentDate()` (client và server) hoặc `CurrentSessionDate()` (chỉ server); nếu dùng `CurrentSessionDate()` thì procedure tính phải là `&AtServer`. `Items.DaysLeft.Visible`.
- **Gợi ý 3 — Khung bài làm:**
  1. Thêm attribute, tạo item form, thêm form attribute `DaysLeft` và field của nó.
  2. Viết procedure tính số ngày (nhánh có/không có ValidUntil).
  3. Viết procedure đặt `Visible`.
  4. Gọi cả hai từ OnOpen và từ OnChange của ValidUntil.
  ```bsl
  ___                          // directive phù hợp với hàm lấy ngày hiện tại bạn chọn
  Procedure CalculateDaysLeft()
  	If ValueIsFilled(___) Then
  		DaysLeft = ___;      // hiệu hai ngày (giây) đổi ra ngày, làm tròn
  	Else
  		DaysLeft = ___;
  	EndIf;
  EndProcedure
  ```
- **Lỗi hay gặp:**
  - Quên chia số giây cho số giây trong một ngày → "Days left" ra số rất lớn.
  - Dùng `CurrentSessionDate()` trong procedure `&AtClient` → không có ở client.
  - Chỉ xử lý OnChange mà quên OnOpen → mở hợp đồng cũ không có ValidUntil vẫn thấy field.
  - Viết `If ... Then Visible = True Else Visible = False` dài dòng — gán thẳng kết quả Boolean gọn hơn.
  - [ghi chú ngoài nguồn] Trong cấu hình mẫu tên field/handler bị gõ sai thành `ValudUntil`; khi đối chiếu, hãy để ý tên handler phải khớp tên item trên form của bạn.
- **Tự kiểm tra:** ValidUntil = 10 ngày sau hôm nay → Days left ≈ 10; xóa ValidUntil → field biến mất ngay; mở lại form → trạng thái vẫn đúng.

### Bài tập 4 — Common form TestCollections và SortArray
- **Đề bài (tóm tắt):** Tạo common form TestCollections (thuộc MasterData, bật "Include in the command interface"), command SortArray; viết function `SortedArray(<Array>)` dùng ValueList để sắp xếp tăng dần; trong handler tạo array 4, 2, 15, 7, 10, gọi function rồi in từng phần tử.
- **Gợi ý 1 — Hướng đi:** **Function** nhận parameter và trả kết quả bằng `Return` (mục "Function và giá trị trả về"). Array không có sẵn sort, nên chuyển sang **ValueList** (mục "Collections", "ValueList") để dùng method sắp xếp rồi chuyển ngược lại.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Common forms → Add; form command `SortArray` có Action là procedure `&AtClient` một parameter `Command`, kéo command lên form thành button. Trong function: `New ValueList`, `LoadValues()`, `SortByValue()`, và method "unload values" tìm trong Syntax assistant (Ctrl + F1). In bằng `For Each` + `Message()`.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo form, gắn vào subsystem, tạo command + button.
  2. Viết function: tạo ValueList, nạp, sắp xếp, trả về array.
  3. Trong handler: tạo array, thêm 5 số, gọi function, gán kết quả vào biến, duyệt và in.
  ```bsl
  &AtClient
  Function SortedArray(UnsortedArray)
  	List = ___;          // tạo ValueList
  	// nạp các phần tử của UnsortedArray vào List
  	// sắp xếp theo value
  	Return ___;          // chuyển List trở lại thành Array
  EndFunction
  ```
- **Lỗi hay gặp:**
  - Quên bật "Include in the command interface" → không thấy form trong section.
  - Viết procedure thay vì function → không có giá trị trả về để gán.
  - Gọi `SortByValue()` rồi in chính ValueList thay vì array được trả về.
- **Tự kiểm tra:** Bấm SortArray → thấy lần lượt 2, 4, 7, 10, 15.

### Bài tập 5 — ShowSelectionFromValueList (ShowChooseItem + CallbackDescription)
- **Đề bài (tóm tắt):** Command ShowSelectionFromValueList: tạo ValueList "ActionsToPerform" 3 phần tử (value 1/2/3 kèm presentation), mở danh sách chọn với tiêu đề "Choose the action to perform"; procedure callback báo value và presentation của phần tử đã chọn.
- **Gợi ý 1 — Hướng đi:** Mỗi phần tử ValueList là `ValueListItem` lưu **Value** và **Presentation** (mục "ValueList"). Chọn từ danh sách là thao tác **không chặn**: kết quả trả về qua procedure được chỉ định bằng `CallbackDescription`.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** `ValueList.Add(Value, Presentation)`; `ShowChooseItem(<CallbackDescription>, <Title>)`; `New CallbackDescription("<tên procedure>", ThisObject)` như đề cho. Procedure callback `&AtClient`, **Export**, đúng hai parameter `SelectedElement, AdditionalParameters`.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo command và handler.
  2. Tạo ValueList, thêm 3 phần tử.
  3. Tạo CallbackDescription, gọi ShowChooseItem.
  4. Trong callback: chỉ khi có lựa chọn mới ghép chuỗi và gọi `Message()` (khung callback đã có trong đề).
- **Lỗi hay gặp:**
  - Quên `Export` hoặc sai số parameter ở callback → platform không gọi được.
  - Đọc `SelectedElement.Value` khi người dùng đóng danh sách → `SelectedElement` là Undefined, gây lỗi.
  - Truyền tên procedure sai chính tả trong chuỗi của CallbackDescription.
- **Tự kiểm tra:** Chọn "Second action" → message có Value = 2 và đúng presentation; đóng danh sách không chọn → không có message, không lỗi.

### Bài tập 6 — CopyAndSearchValueTable (Copy theo filter + Total)
- **Đề bài (tóm tắt):** Command có handler client và server; ở server tạo ValueTable 3 cột Product, Price, Quantity với 4 dòng theo đề; tính tổng Quantity của "Cable, 10m" theo phương án #3 (Copy có filter rồi Total) và báo "Quantity of <Product> is equal to <QuantityTotal>".
- **Gợi ý 1 — Hướng đi:** ValueTable không có ở client → xử lý trong procedure `&AtServer`, handler client chỉ gọi sang. Filter cho `Copy()` là một **Structure** (key = tên cột, value = giá trị cần lọc) (mục "Structure", "ValueTable").
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** `New ValueTable`, `Columns.Add()`, `Add()` cho dòng mới; `New Structure("<Key>", <Value>)`; `Copy(<filter>)`; `Total("<Tên cột>")`.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo command; handler client gọi procedure server.
  2. Trong server: tạo bảng, 3 cột, 4 dòng.
  3. Tạo biến RowsFilter, copy bảng theo filter vào biến mới, lấy Total cột Quantity.
  4. Ghép message, lấy tên product từ biến thay vì gõ cứng.
- **Lỗi hay gặp:**
  - Viết code ValueTable trong procedure `&AtClient` → lỗi kiểu không có ở client.
  - Dùng `FindRows()` rồi gọi `Total()` trên kết quả → `FindRows()` trả về Array, không có `Total()`.
  - Gõ sai giá trị filter (thừa/thiếu khoảng trắng, dấu phẩy) → bảng copy rỗng, tổng = 0.
  - [ghi chú ngoài nguồn] Cấu hình mẫu đặt tên command khác đề và viết cứng tên product trong message; đề yêu cầu tên `CopyAndSearchValueTable` và lấy presentation của product.
- **Tự kiểm tra:** Kết quả là 76 (24 + 52). Dùng debugger (Bài 8) xem bảng copy chỉ còn 2 dòng.

### Bài tập 7 — CalculateTotalAtValueTree (cây 3 cấp + function đệ quy)
- **Đề bài (tóm tắt):** Command có handler client và server; ở server dựng ValueTree 3 cấp (Period → Customer → Product/Amount) theo bảng trong đề; viết function đệ quy `AmountOfProductAtTree(Tree, Product)` trả tổng Amount của một product; báo "Amount of Water is <Result>".
- **Gợi ý 1 — Hướng đi:** Cả tree và từng row đều có property **Rows** (mục "ValueTree"), nên một function có thể tự gọi lại với một row như với cả tree (**đệ quy**). Chọn function để biến tích lũy nằm bên trong, lời gọi bên ngoài ngắn gọn.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Procedure `&AtServer` dựng tree: `New ValueTree`, `Columns.Add()`, `Rows.Add()` ở tree cho cấp 1 và `<dòng cha>.Rows.Add()` cho cấp dưới. Function `&AtServer` đệ quy, biến local khởi tạo 0, `For Each ... In <...>.Rows`, `Return`.
- **Gợi ý 3 — Khung bài làm:**
  1. Dựng cây đúng bảng của đề, điền đầy đủ mọi cột cho cả dòng con.
  2. Viết function: khởi tạo kết quả, duyệt các row, quyết định khi nào cộng Amount, khi nào gọi đệ quy.
  3. Gọi function với "Water" và báo kết quả.
  ```bsl
  &AtServer
  Function AmountOfProductAtTree(Tree, Product)
  	Result = ___;               // biến tích lũy
  	For Each ___ In ___ Do      // duyệt các row (property Rows)
  		If ___ Then
  			// cộng Amount của dòng này
  		Else
  			// cộng kết quả của lời gọi đệ quy với ___
  		EndIf;
  	EndDo;
  	Return ___;
  EndFunction
  ```
- **Lỗi hay gặp:**
  - Thêm mọi dòng bằng `Tree.Rows.Add()` → cây phẳng, không có cấp.
  - Không điền Period/Customer cho dòng con — đề nhấn mạnh dòng con không tự lấy giá trị của dòng cha. [ghi chú ngoài nguồn] Cấu hình mẫu bỏ qua điểm này ở cấp 3; kết quả vẫn đúng vì chỉ so sánh Product, nhưng bạn nên làm đúng đề.
  - Quên `Return` → function trả Undefined, phép cộng lỗi ở cấp trên.
  - Amount khai báo kiểu String như đề nhưng gán số; nếu gán chuỗi "1250" thì phép `+` thành ghép chuỗi — hãy gán số.
- **Tự kiểm tra:** Kết quả Water = 5030 (1250 + 480 + 2500 + 800). Thử với "Flour" → 1000.

### Code demo của bài Theory (repo 1CJDCourse, nhánh lesson/05-theory)

[ghi chú ngoài nguồn] Nhánh `lesson/05-theory` chỉ chứa module rỗng (giống `04-theory`), repo không có nhánh riêng cho Bài 6. Các ví dụ cú pháp của Bài 5–6 nằm trong văn bản Theory (mục "Cú pháp & ví dụ code" ở trên). Không tự tạo "code demo Theory" và gán cho bài.

## Video tham khảo

Video bài giảng trên YouTube có phạm vi trùng với bài này. Khi dẫn cho người học, nói "Bạn có thể tham khảo thêm về <chủ đề> của khóa tại đây: [<tên video>](link)" — không nói "khóa cũ/Junior", không dùng mã JC (mã JC trong danh sách chỉ để tra nội bộ). Quy ước đầy đủ: `references/video.md#video-junior-course`.

- [Hello world với 1C:Enterprise](https://www.youtube.com/watch?v=BBmgzkbdcG8&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=2) (3:52) — Bài 1 — tạo infobase không có configuration; Bài 5-6 — `Message()` _(mã nội bộ JC-3)_
- [Cơ bản về ngôn ngữ script 1C](https://www.youtube.com/watch?v=HvOuAQJ8W2s&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=11) (6:46) — Bài 5-6 — module, procedure/function, biến & scope, If, vòng lặp _(mã nội bộ JC-12)_
- [Làm việc với bối cảnh toàn cục (Global Context)](https://www.youtube.com/watch?v=cqwM140spEs&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=25) (5:16) — Bài 5-6 — Syntax assistant nhánh Global context, `Message()`; Bài 14 — common module Global _(mã nội bộ JC-26)_
- [Các kiểu dữ liệu cơ sở](https://www.youtube.com/watch?v=jdO9y_nXLIQ&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=26) (9:23) — Bài 2 — Primitive types; Bài 5-6 — làm việc với kiểu, ValueIsFilled _(mã nội bộ JC-27)_
- [Các toán tử](https://www.youtube.com/watch?v=FpPWl5JoKfg&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=27) (13:07) — Bài 5-6 — toán tử và biểu thức _(mã nội bộ JC-28)_
- [Các lớp hệ thống](https://www.youtube.com/watch?v=_6VNsJ5nWrM&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=28) (7:57) — Bài 5-6 — collections: Array, Structure, Map, ValueList, ValueTable, ValueTree _(mã nội bộ JC-29)_
