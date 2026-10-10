# Tài liệu gộp: lessons-11-15

Gồm các mục: § bai-11, § bai-12, § bai-13, § bai-14, § bai-15


---

# § bai-11

# Bài 11 — Accumulation registers & Document posting

## Khái niệm chính

### Accumulation register — mục đích
- Mục đích của accumulation register: thu thập dữ liệu số theo các tập measurements (dimensions). Ví dụ register "Goods in warehouses" cho phép lấy số dư theo quantity và amount của hàng hóa tại kho tại bất kỳ thời điểm nào.
- Lý do dùng register thay vì tính số dư từ documents:
  - Nhiều loại document ảnh hưởng số dư ("Purchase invoice", "Movement of goods", "Inventory capitalization" tăng; "Sales", "Movement of goods", "Inventory write-off" giảm); danh sách có thể mở rộng → phải sửa thuật toán mỗi lần.
  - Business-process có thể thay đổi (ví dụ thêm attribute Status, chỉ "Approved" mới giảm số dư) → thuật toán càng phức tạp.
  - Số lượng document tăng → tính toán ngày càng nặng (ví dụ 50 nghìn document/năm → sau 5 năm là 250 nghìn).
- Records của accumulation register phụ thuộc (subordinate) vào documents là **recorders** của register → không thể thêm/sửa/xóa trực tiếp, chỉ thay đổi được qua document ảnh hưởng tới register.
- Cấu trúc register:
  - **Dimensions**: dữ liệu theo đó quantity/amount được ghi nhận (ví dụ Product, Warehouse).
  - **Resources**: những gì được tích lũy (ví dụ Quantity, Amount).
  - **Attributes**: lưu thông tin bổ sung cho mỗi record.

### Register kind
- Property **"Register kind"**: **Balances** hoặc **Turnovers**.
- Register kiểu Turnovers dùng khi cần lấy nhanh turnovers cho một kỳ (ví dụ chiết khấu theo doanh số trong tháng/quý/năm). Ví dụ: register Sales kiểu Turnovers, dimension Counterparty, resource Amount.
- Real table chứa dữ liệu từ một bảng vật lý; virtual table được tạo lúc thực thi query và có thể lấy dữ liệu từ một hoặc nhiều bảng vật lý.
- Virtual tables:
  - Register kiểu **Balances**: 3 virtual tables — **Balance**, **Turnovers**, **BalanceAndTurnovers**.
  - Register kiểu **Turnovers**: 1 virtual table — **Turnovers**.
- Ở mức database, accumulation register mọi kiểu lưu dữ liệu trong 2 bảng vật lý: **movement table** và **totals table** (totals table của hai kiểu khác nhau). Movement table chứa mọi record được đưa vào khi posting document.

### Bảng của register kiểu Balances
- Totals table lưu số dư theo mọi dimensions với tần suất tháng, tại đầu tháng. Hệ thống tính totals table dựa trên movement table; khoảng thời gian lưu số dư bị giới hạn bởi **period of calculated totals** — chỉ định là ngày cuối tháng mà totals được tính (ví dụ 31.05.2024 → totals được tính tới 01.06.2024 bao gồm). Ngoài ra, current totals được lưu riêng trong totals table.
- Ví dụ: record đầu tiên ngày 03.12.2023, period of calculated totals là 31.02.2024 → tại 10.03.2024, totals table lưu totals cho 01.01.2024, 01.02.2024, 01.03.2024 và current totals.
- Current totals có period **01.11.3999**.
- **Balance** (virtual table): luôn dùng totals table, đôi khi dùng movement table (tùy thời điểm tính và period of calculated totals). Chiến lược:
  1. Chọn thời điểm totals gần nhất lớn hơn hoặc bằng thời điểm cần tính.
  2. Lấy số dư từ totals table tại thời điểm đó.
  3. Nếu không trùng, tính số dư dựa trên movements từ thời điểm yêu cầu tới thời điểm totals.
  - Ví dụ: số dư tại 01.02.2024 = 42, movement chi (Expense) 3 trong khoảng 15.01–01.02 → số dư tại 15.01.2024 = 42 − (−3) = 45.
- **Turnovers** (virtual table của register Balances): luôn dùng dữ liệu từ movement table, bất kể period of calculated totals → nếu cần lấy turnovers thường xuyên, nên tạo register kiểu Turnovers.
- **BalanceAndTurnovers**: tính đồng thời balance và turnovers. Nếu không chỉ định periodicity → một query (chứa subqueries); nếu chỉ định periodicity → 2 query riêng, kết quả được kết hợp.

### Bảng của register kiểu Turnovers
- Totals table lưu turnovers đã tính (movements nhóm theo dimensions) với tần suất tháng, cho mọi kỳ có movements. **Không thể lấy balances** từ register này.
- Virtual table Turnovers lấy dữ liệu từ movement table, totals table hoặc cả hai, tùy period và periodicity:
  - Periodicity được chỉ định và nhỏ hơn tháng → chỉ dùng movement table.
  - Không chỉ định periodicity hoặc ≥ tháng → phụ thuộc period: các tháng trọn vẹn lấy từ totals table, phần còn lại lấy từ movement table. Không chỉ định period → lấy toàn bộ thời gian từ movement đầu tới cuối, cùng thuật toán.
  - Ví dụ (periodicity Month): 01.11.2023–30.11.2023 → chỉ totals table; 25.10.2023–15.01.2024 → tháng 11 từ totals table, (25.10–31.10) và (01.01–15.01) từ movement table; 25.10.2023–25.11.2024 → theo tài liệu: chỉ từ movement table vì kỳ không chứa tháng trọn vẹn.

### Lấy dữ liệu từ virtual tables
- 2 cách: built-in code và query.
- Built-in code: methods **Balance** và **Turnovers** của accumulation register, trả về value table (cột = dimensions và resources, có thể giới hạn qua tham số); có thể chỉ định period, filter, dimensions và resources.
- Built-in code không hỗ trợ lấy balances và turnovers cùng lúc.
- Gọi method Balance cho register kiểu Turnovers → ném exception.
- Lấy bằng query phổ biến hơn vì cho phép chọn lọc phức tạp, join và merge dữ liệu.
- Trong query wizard: chọn virtual table trong node AccumulationRegisters; mở virtual table settings bằng nút bánh răng (nếu nút không khả dụng, chọn bảng trong danh sách bảng đã chọn).
- **Balance** virtual table: 2 tham số — **period** và **condition**. Không chỉ định period → lấy current balances. Period thường là query parameter (`&` + tên). Condition: điều kiện bất kỳ trong query language, thường lọc theo giá trị dimensions; có thể dùng nested query (ví dụ lọc theo product trong temporary table).
  - **Note**: nested query trong condition phải tự viết, không tạo được bằng constructor.
- **Turnovers** virtual table: **BeginOfPeriod**, **EndOfPeriod**, **Periodicity** (tần suất nhóm records: Day, Month, ...). Khi periodicity tăng, records cùng giá trị dimensions được gộp trong kỳ, period đổi thành đầu kỳ.
  - Records chỉ nhóm theo các dimensions có trong selection (không phải tất cả dimensions của register).
  - **Note**: không có turnovers cho một tập dimensions trong kỳ → không trả về record (ví dụ tháng 12/2023 → kết quả rỗng).
  - Nếu mọi resource được chọn đều = 0 cho một tập dimensions (ví dụ +10 −10 = 0) → không có record. Nếu ít nhất một resource ≠ 0 → record được trả về (có thể có resource = 0).
- **BalanceAndTurnovers** virtual table: mỗi resource có 5 trường — Opening balance, Turnover, Receipt, Expense, Closing balance (Turnover/Receipt/Expense tính theo periodicity).
  - Tham số **ComplementMethod**: **RegisterRecords** → không gồm boundary periods (chỉ các kỳ có movements); **RegisterRecordsAndPeriodBoundaries** → gồm boundary periods bất kể có movements hay không.
- **Important**: luôn giới hạn dữ liệu chọn từ virtual table càng nhiều càng tốt. Bước đầu tiên của query là lấy dữ liệu từ virtual table; nếu lọc ở WHERE, database trước tiên lấy toàn bộ số dư (có thể hàng chục nghìn records) rồi mới lọc. Đặt điều kiện trong parameters của virtual table → chỉ lấy dữ liệu cần thiết ngay từ đầu.

### Document posting
- Cần xác định documents nào là recorders của accumulation register (hoặc ngược lại — chỉ định cho document các register nó có thể ghi).
- Viết code thêm records vào register. Công cụ **Record wizard** (Register record wizard): mở từ Document object editor, tab **Posting**, hoặc chuột phải vào document → **Wizards - Register record wizard**.
- Thường records được ghi trong event handler **Posting** — document ghi movements khi posting. Posting là dấu hiệu cần ghi nhận các thay đổi liên quan đến sự kiện đã xảy ra (ví dụ Sales invoice: trừ hàng khỏi kho, ghi nhận công nợ của người mua...).
- Record wizard:
  - Nếu object module đã có procedure Posting → cảnh báo procedure sẽ bị thay toàn bộ.
  - Bước đầu chọn một register; trong wizard có thể thêm các register khác.
  - Register kiểu Turnovers không cho chỉ định loại movement (receipt, expense); các kiểu register có icon khác nhau.
  - Điền tuần tự danh sách dưới (thuật toán điền register records) bằng cách chọn register ở danh sách trên.
  - Nếu document có tabular section, phải chọn nó trước để attributes xuất hiện trong danh sách Document attributes.
  - Nút **Fill Expressions**: tự điền các trường register trùng tên với trường document. Sau đó sửa bằng double-click trên trường có sẵn hoặc viết trực tiếp vào cột **Expression**.
  - Chọn đúng register record type (**Receipt**, **Expense**) — ví dụ Sales invoice giảm số dư kho → Expense.
  - Wizard để lại service comments đầu/cuối: code bên trong do Wizard tạo, mọi chỉnh sửa tay sẽ mất lần dùng Wizard tiếp theo. Mỗi lần dùng Record wizard và bấm OK, code procedure Posting bị thay toàn bộ, dù không sửa tay.
- 2 nhược điểm của code do Record wizard tạo:
  1. Không cho tạo movements từ nhiều tabular sections cùng lúc (ví dụ Products và Services — chỉ chọn được Products; Services phải tự viết).
  2. Việc duyệt cùng tabular section không được gộp cho nhiều register (duyệt Products 2 lần) → nên tối ưu.
- **RegisterRecords**: collection đặc biệt chứa record sets của mọi register mà document này là recorder. Truy cập record set qua property theo tên, ví dụ `RegisterRecords.Sales`, `RegisterRecords.GoodsByWarehouses`.
- Property **Write** của record set: sau khi thoát procedure Posting, các record set có Write = True sẽ được nền tảng tự ghi (mặc định False). Muốn ghi trước khi kết thúc Posting → dùng method `Write()`.

### Posting mode
- 2 loại: **real time** và **regular** (backdated). Real time posting xảy ra khi: metadata của document có properties "posting", "real time posting" và ngày document tại lúc posting là hôm nay. Khi đó nền tảng tự đổi thời gian document thành hiện tại.
- Real time dùng khi thời điểm thao tác chính xác tới giây là quan trọng (ví dụ bán lẻ: cấm bán rượu sau giờ nhất định, business lunch theo giờ, nhiều quầy thu ngân song song, gửi electronic checks lên hệ thống nhà nước chỉ nhận trong tuần gần nhất).
- Thời gian bị chỉnh về giây hiện tại khi posting → nên tắt real time posting cho document không cần.
- Document dịch vụ không phản ánh nghiệp vụ thực → có thể tắt posting.

### Date, PointInTime, Boundary
- Không có hạn chế nhập nhiều document cùng date/time → rủi ro số dư không chính xác tại ngày của một trong các document đó.
- Virtual table **Balance** với period kiểu Date: lấy dữ liệu **TRƯỚC** giây chỉ định. Virtual table **Turnovers**: lấy dữ liệu **BAO GỒM** các giây chỉ định trong BeginOfPeriod và EndOfPeriod.
  - Ví dụ: 4 Sales invoice, 0002–0004 cùng 10.01.2024 01:12:14 PM → từ document 0003, kiểm tra số dư theo ngày document không tính các document khác cùng giây.
- **PointInTime**: kiểu giá trị để làm việc chi tiết hơn trên trục thời gian; gồm 2 phần: date và link. Dù trùng giây, các document vẫn có thứ tự trên trục thời gian. Truyền PointInTime vào Period của Balance → lấy số dư ngay trước PointInTime đó (không tính chính document). Ví dụ "Pen": theo ngày → 100 cho cả 0002, 0003, 0004; theo PointInTime → 100, 85, 65.
- Tạo PointInTime: method `PointInTime()` hoặc `New PointInTime(...)`.
- Lấy số dư của giây kế tiếp (`DocumentDate + 1`) cũng được nhưng có thể gây hiểu nhầm cho developer khác.
- **Boundary**: đối tượng làm rõ việc bao gồm/loại trừ giá trị biên của kỳ — `BoundaryType.Including`, `BoundaryType.Excluding`. Có thể kết hợp Boundary và PointInTime để lấy số dư tại PointInTime bao gồm movements tại thời điểm đó.

### Features of document writing
- Khác biệt giữa chế độ interactive (user thao tác ở Enterprise mode) và programmatic (từ code).
- Khi tạo document form, property **RepostOnWrite** bật mặc định → user lưu document đã post từ form → nền tảng post lại.
- Từ code: method `Write()` có 2 tham số:
  - **WriteMode**: Posting, UndoPosting, Write.
  - **PostingMode**: RealTime, Regular.
  - Mặc định: Write mode = Write, Posting mode = Regular.
- Object và link tới document có method `Copy()` — tạo object mới chưa ghi vào database. Phải ghi object sau khi thay đổi xong, nếu không mọi thay đổi bị mất.
- Form table có method `Refresh()` để làm mới danh sách.
- Ví dụ lệnh "Copy and Post": thêm command vào list form Sales Invoice, nút trên command bar, tạo handler qua nút kính lúp ở property Action → "Create on client and a procedure on server".
- **Note**: trong list form, main attribute là dynamic list. Với form element kiểu Table gắn với attribute kiểu dynamic list, giá trị property **CurrentRow**: nếu main table là bảng của reference object → chứa link tới object được chọn, hoặc Undefined nếu không chọn dòng nào (thường chỉ khi danh sách rỗng). Với bảng gắn attribute kiểu khác, CurrentRow thường chứa row identifier (số).

### AdditionalProperties
- Property **AdditionalProperties** của object (reference objects như Catalog, Document; non-reference như Information register record set, accumulation register record set), kiểu **Structure**, để lưu/truyền thông tin bổ sung giữa các event handlers và methods.
- Ví dụ: không thể kiểm tra document có mới không trong handler Posting (khi đó object đã ghi vào database, có link nên không còn "new"). Kiểm tra trong event **BeforeWrite** rồi truyền qua AdditionalProperties.
- `IsNew()`: True với object mới, False với object đã ghi; chỉ reference objects có hàm này.

### Generation (tạo đối tượng dựa trên đối tượng khác)
- Cho phép tạo object mới dựa trên object khác, chuyển dữ liệu và mô tả thuật toán điền theo điều kiện (ví dụ theo loại object nguồn).
- Cấu hình: trong object editor, tab **Generation**, danh sách **"Generated based on"** → chọn metadata objects (bao nhiêu cũng được).
- Mô tả thuật toán điền trong event handler **Filling**. Event Filling xảy ra khi:
  - tạo object mới interactively;
  - tạo object mới dựa trên object khác;
  - gọi method `Fill()` của object từ code.
- Công cụ **Generation settings wizard**: giống Record wizard; nút Fill Expressions; tạo procedure `Filling()` trong object module với service comments — code bị thay toàn bộ lần dùng wizard tiếp theo.
- Ở Enterprise mode, list form và form của document nguồn có submenu **Generate**.
- Nên tạo attribute liên kết tới document nguồn (ví dụ `SalesDocument` kiểu `DocumentRef.SalesInvoice`) và điền trong Filling. Trên form: field không cho sửa, kiểu **"Label Field"** và bật property **hyperlink** để mở document nguồn.

## Cú pháp & ví dụ code

Methods Balance và Turnovers của accumulation register:
```bsl
// Get quantity and amount balance of all products at all warehouses
GoodsBalance = AccumulationRegisters.GoodsInWarehouses.Balance(Date);

// Get quantity balance of all products at the "Additional" warehouse
Filter = New Structure("Warehouse", AdditionalWarehouse);
GoodsBalance = AccumulationRegisters.GoodsInWarehouses.Balance(Date, Filter, "Product", "Quantity");

// Get turnovers for one product for the current month for all clients
Filter = New Structure("Product", ProductForSearch);
SalesTurnovers = AccumulationRegisters.Sales.Turnovers(
BegOfMonth(Date), EndOfMonth(Date), Filter, "Customer");
```

Write — method và property:
```bsl
// This is a method
RegisterRecords.Sales.Write();

// and this is a property
RegisterRecords.Sales.Write = True;
```

PointInTime:
```bsl
Query.SetParameter("Period", ThisObject.PointInTime());
```

```bsl
PointInTime = New PointInTime(DocumentOrAnyOtherDate, RefToDocument);
```

Lấy số dư giây kế tiếp (không khuyến khích vì dễ gây hiểu nhầm):
```bsl
Query.SetParameter("Period", DocumentDate + 1);
```

Boundary:
```bsl
Boundary = New Boundary(DocumentDate, BoundaryType.Including);
Query.SetParameter("Period", Boundary);
```

```bsl
StartDate = Date(2024, 01, 10);
EndDate = New Boundary(DocumentDate, BoundaryType.Excluding);
Query.SetParameter("StartDate", StartDate);
Query.SetParameter("EndDate", EndDate);
```

Ghi document từ code:
```bsl
Write(DocumentWriteMode.Posting, DocumentPostingMode.RealTime);

// The method has default values for both of the parameters:
// Write mode = Write, Posting mode = Regular
Write();
```

[ghi chú ngoài nguồn] Các ví dụ khác trong tài liệu gốc (query lấy Balance/Turnovers/BalanceAndTurnovers, code Posting do Record wizard tạo và bản đã tối ưu, kết hợp Boundary + PointInTime, lệnh "Copy and Post", BeforeWrite + AdditionalProperties, Filling do Generation settings wizard tạo) chỉ có dạng ảnh chụp màn hình, không có văn bản code nên không được chép lại. → Posting bản tối ưu, BeforeWrite + AdditionalProperties (IsNew), Filling do wizard tạo và lệnh "Copy and Post" → xem mục Code demo của bài Theory (nhánh lesson/11-theory); query Balance/Turnovers, Posting do Record wizard tạo và Boundary + PointInTime → xem Thẻ gợi ý bài thực hành. Query BalanceAndTurnovers vẫn chưa có.

## Thuộc tính/thiết lập quan trọng trong Designer
- Accumulation register: **Register kind** (**Balances** / **Turnovers**); Dimensions, Resources, Attributes; period of calculated totals.
- Virtual table parameters:
  - Balance: **Period**, **Condition**.
  - Turnovers: **BeginOfPeriod**, **EndOfPeriod**, **Periodicity**, condition.
  - BalanceAndTurnovers: thêm **ComplementMethod** (**RegisterRecords** / **RegisterRecordsAndPeriodBoundaries**).
- Document: tab **Posting** (recorders, Record wizard); properties **posting**, **real time posting**; tab **Generation** → **Generated based on**.
- Record wizard: nút **Fill Expressions**, cột **Expression**, register record type **Receipt**/**Expense**.
- Document form: property **RepostOnWrite** (mặc định bật).
- Command: property **Action** → "Create on client and a procedure on server".
- Form table: **CurrentRow**, method **Refresh()**.
- Form field: kiểu **Label Field**, property **hyperlink**.
- Record set: property **Write**, method **Write()**.
- Object: **AdditionalProperties**, **IsNew()**, **Copy()**, **Fill()**, **PointInTime()**.

## Lỗi thường gặp / lưu ý
- Gọi method Balance cho register kiểu Turnovers → exception.
- Không lấy được balances từ register kiểu Turnovers.
- Virtual table Turnovers của register Balances luôn đọc movement table → nếu cần turnovers thường xuyên, tạo register kiểu Turnovers.
- Lọc ở WHERE thay vì trong parameters của virtual table → lấy dữ liệu thừa, tốn tài nguyên.
- Dùng lại Record wizard / Generation settings wizard → code Posting / Filling bị thay toàn bộ, mất code tay và mất movements của các register bị quên.
- Record wizard không xử lý nhiều tabular sections và duyệt lặp tabular section cho từng register → cần tự sửa/tối ưu.
- Quên chọn đúng record type (Receipt/Expense).
- Real time posting ép thời gian về giây hiện tại → tắt cho document không cần.
- Balance với Date lấy dữ liệu trước giây chỉ định → các document cùng giây không được tính; dùng PointInTime/Boundary.
- Dùng `DocumentDate + 1` gây khó hiểu cho developer khác.
- Không kiểm tra được IsNew() trong Posting (object đã được ghi) — kiểm tra ở BeforeWrite.
- Sau `Copy()` phải ghi object, nếu không mất thay đổi.
- Nested query trong condition của virtual table phải tự viết.

## Điểm cần nhớ
- Accumulation register = dimensions + resources (số) + attributes; records chỉ thay đổi qua recorder documents.
- Register Balances có 3 virtual tables (Balance, Turnovers, BalanceAndTurnovers); register Turnovers chỉ có Turnovers.
- Mỗi register có movement table + totals table; totals theo tháng; current totals có period 01.11.3999.
- Luôn đặt filter trong parameters của virtual table, không ở WHERE.
- Ghi movements trong handler Posting qua RegisterRecords; record set có Write = True được tự ghi khi thoát Posting.
- Balance (Date) lấy dữ liệu trước giây chỉ định; Turnovers bao gồm giây biên; PointInTime = date + link; Boundary Including/Excluding.
- `Write(DocumentWriteMode..., DocumentPostingMode...)` — mặc định Write + Regular.
- Generation: tab Generation → Generated based on + handler Filling (Generation settings wizard).

## Thẻ gợi ý bài thực hành (Practice 11)

> Thẻ gợi ý dẫn hướng cho từng yêu cầu của 11. Practice.docx; không có lời giải hoàn chỉnh. Làm theo thứ tự Gợi ý 1 → 2 → 3.

### Bài tập 1 — Accumulation register GoodsInWarehouses
- **Đề bài (tóm tắt):** Tạo register cho biết bao nhiêu hàng, trị giá bao nhiêu đang ở từng kho; đưa vào subsystem phù hợp.
- **Gợi ý 1 — Hướng đi:** Cần **số dư** tại thời điểm bất kỳ → accumulation register, **Register kind = Balances** (mục Register kind, Bảng của register kiểu Balances).
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Register `GoodsInWarehouses`: Dimensions `Product` (`CatalogRef.Products`), `Warehouse` (`CatalogRef.Warehouses`); Resources `Quantity`, `Amount` (Number). Subsystem: Warehouse.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo register, chọn Register kind.
  2. Thêm 2 dimensions, 2 resources.
  3. Đặt subsystem, synonym.
  4. (Register chưa lưu được dữ liệu cho tới khi có recorder — Bài tập 2.)
- **Lỗi hay gặp:**
  - Chọn kiểu Turnovers → không lấy được balances (gọi Balance sẽ lỗi).
  - Đặt Amount là dimension thay vì resource.
- **Tự kiểm tra:** Designer không báo lỗi khi cập nhật database; register xuất hiện trong tab Posting của các document ở bước sau.

### Bài tập 2 — Ba document ghi movements vào GoodsInWarehouses
- **Đề bài (tóm tắt):** PurchaseInvoice tăng số dư; SalesInvoice giảm số dư; InventoryTransfer giảm ở kho gửi và tăng ở kho nhận (Amount để trống). Services không được vào register (Note 2.1); tạm thời ghi giá vốn bằng amount trong document (Note 2.2).
- **Gợi ý 1 — Hướng đi:** Mỗi document là **recorder** của register, movements được ghi trong handler **Posting** qua collection **RegisterRecords** (mục Document posting). Tăng = **Receipt**, giảm = **Expense**.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Tab Posting của từng document → chọn `GoodsInWarehouses` làm register; mở **Record wizard** để sinh khung (chọn tabular section `Products` trước, bấm Fill Expressions, sửa cột Expression).
  - Object module, `Procedure Posting(Cancel, Mode)`; `RegisterRecords.GoodsInWarehouses.Write = True`; mỗi dòng Products → `Add()`, đặt `RecordType`, `Period = Date`, dimensions, resources.
  - InventoryTransfer: mỗi dòng sinh **hai** records (Expense ở `WarehouseSender`, Receipt ở `WarehouseRecipient`).
- **Gợi ý 3 — Khung bài làm:**
```bsl
Procedure Posting(Cancel, Mode)
	// bật tự ghi record set: RegisterRecords.___.Write = ___
	For Each CurRow In Products Do
		// Record = RegisterRecords.GoodsInWarehouses.Add();
		// RecordType = ___ (Receipt / Expense tùy document)
		// Period, Product, Warehouse, Quantity, Amount = ___
	EndDo;
	// InventoryTransfer: trong vòng lặp thêm record thứ hai cho kho ___
EndProcedure
```
- **Lỗi hay gặp:**
  - Chọn sai Receipt/Expense (lỗi phổ biến nhất). [ghi chú ngoài nguồn] Code demo của bài Theory (nhánh lesson/11-theory) ghi `Receipt` cho Sales invoice — đây là lỗi của demo, bán hàng phải là `Expense`; đừng chép theo.
  - Duyệt cả tabular section Services → services lọt vào register kho.
  - Quên `Write = True` → record set không được ghi, register rỗng.
  - Chạy lại Record wizard sau khi sửa tay → Posting bị thay toàn bộ.
- **Tự kiểm tra:** Post một Purchase invoice, mở document → chuyển tới register records (hoặc mở list của register) thấy records Receipt; post Sales invoice thấy Expense; Inventory transfer có 2 records mỗi dòng với 2 kho khác nhau.

### Bài tập 3 — Viết lại "Fill in by the remaining goods" bằng dữ liệu register
- **Đề bài (tóm tắt):** InventoryTransfer lấy số dư từ register (không còn tính từ documents); thêm cột Amount vào tabular section Products (không đặt lên form) và điền bằng số dư amount.
- **Gợi ý 1 — Hướng đi:** Đọc virtual table **Balance** của register với tham số Period = ngày document và Condition lọc theo kho gửi (mục Lấy dữ liệu từ virtual tables — đặt điều kiện trong parameters, không ở WHERE).
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Thêm attribute `Amount` vào tabular section `Products` của InventoryTransfer; không kéo lên form.
  - Sửa `FillInByTheRemainingGoodsAtServer` (`&AtServer`): query tới `AccumulationRegister.GoodsInWarehouses.Balance(&Date, <condition theo Warehouse>)`; các trường số dư có hậu tố `Balance` (`QuantityBalance`, `AmountBalance`) → đặt alias trùng tên cột tabular section.
  - Phần client (ShowQueryBox, callback) giữ nguyên.
- **Gợi ý 3 — Khung bài làm:**
```bsl
&AtServer
Procedure FillInByTheRemainingGoodsAtServer()
	// SELECT Product, ___Balance AS Quantity, ___Balance AS Amount
	// FROM AccumulationRegister.GoodsInWarehouses.Balance(&Date, Warehouse = ___)
	// SetParameter: Date = ___, Warehouse = ___ (kho gửi)
	// nạp vào Object.Products
EndProcedure
```
- **Lỗi hay gặp:**
  - Lọc kho ở WHERE thay vì trong tham số virtual table → đọc thừa dữ liệu.
  - Alias không trùng tên cột → `Load` không điền Quantity/Amount.
  - Period kiểu Date lấy dữ liệu **trước** giây chỉ định — document khác cùng giây không được tính.
- **Tự kiểm tra:** Sau khi post vài Purchase/Sales invoice vào một kho, bấm nút trên Inventory transfer có kho gửi đó → Quantity khớp với report/list của register; xem cột Amount trong debugger (vì không có trên form).

### Bài tập 4 — Document ReturnOfGoodsFromCustomer (Generation từ SalesInvoice)
- **Đề bài (tóm tắt):** Document trả hàng, thuộc Sales, có mọi attributes và tabular sections của Sales invoice, phải **liên kết** với sales document và tạo được dựa trên Sales invoice với mọi field/bảng được điền; tạo object form, list form, synonym.
- **Gợi ý 1 — Hướng đi:** Cơ chế **Generation** (mục Generation): tab Generation → Generated based on, thuật toán điền trong handler **Filling**; nên có attribute liên kết tới document nguồn.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Có thể copy document SalesInvoice rồi đổi tên/synonym (giữ đủ attributes và tabular sections).
  - Thêm attribute `SalesDocument` kiểu `DocumentRef.SalesInvoice`; trên form hiển thị dạng **Label Field** với property **hyperlink**, không cho sửa.
  - Tab Generation → Generated based on: `Document.SalesInvoice`; dùng **Generation settings wizard** để sinh `Filling(FillingData, StandardProcessing)` rồi bổ sung `SalesDocument`.
- **Gợi ý 3 — Khung bài làm:**
```bsl
Procedure Filling(FillingData, StandardProcessing)
	If TypeOf(FillingData) = Type("___") Then
		// header: Customer, Contract, Warehouse, Discount ... = FillingData.___
		// SalesDocument = ___
		// For Each ... In FillingData.Products: thêm dòng, chép các cột
		// For Each ... In FillingData.Services: thêm dòng, chép các cột
	EndIf;
EndProcedure
```
- **Lỗi hay gặp:**
  - Quên attribute liên kết (đề in đậm "must be linked") → không truy ngược được sales document.
  - Thêm cột/attribute mới vào Sales invoice sau này nhưng không bổ sung vào Filling.
  - Chạy lại wizard → mất phần sửa tay (service comments `//{{__CREATE_BASED_ON_WIZARD`).
- **Tự kiểm tra:** Mở một Sales invoice → Generate → Return of goods from customer: header và hai bảng được điền, field SalesDocument là hyperlink mở đúng invoice gốc.

### Bài tập 5 — Form ReturnOfGoodsFromCustomer: tính amount, khóa Price/Amount, tổng document
- **Đề bài (tóm tắt):** Khi đổi Quantity → tính lại Amount của dòng (cả Products và Services); không cho sửa Price và Amount; tính lại tổng document như ở SalesInvoice.
- **Gợi ý 1 — Hướng đi:** Dùng lại đúng các handler đã viết cho SalesInvoice form (Bài 8–9): event **OnChange** của cột Quantity, event OnChange của bảng để tính tổng; khóa cột bằng property **ReadOnly** của form item.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Form module của document; `ProductsQuantityOnChange` / `ServicesQuantityOnChange` (`&AtClient`) gọi procedure tính amount dòng (có thể `&AtClientAtServerNoContext` để dùng được cả trên server); `ProductsOnChange` / `ServicesOnChange` gọi procedure tính tổng (`&AtServer`); trong Form editor đặt ReadOnly cho các cột Price, Amount.
- **Gợi ý 3 — Khung bài làm:**
  1. Đặt ReadOnly = True cho `ProductsPrice`, `ProductsAmount`, `ServicesPrice`, `ServicesAmount`.
  2. Tạo handler OnChange cho cột Quantity của cả hai bảng → gọi procedure tính amount của dòng hiện tại (`Items.<Bảng>.CurrentData`), có tính Discount.
  3. Tạo handler OnChange của hai bảng → gọi procedure server tính tổng vào `DocumentTotal`.
- **Lỗi hay gặp:**
  - Chỉ làm cho Products, quên Services.
  - Gán ReadOnly trong metadata attribute thay vì trên form item (khi đó Filling vẫn chạy được, nhưng hãy kiểm tra lại hành vi bạn muốn).
- **Tự kiểm tra:** Trên document trả hàng, đổi Quantity → Amount và tổng cập nhật; không gõ được vào Price/Amount.

### Bài tập 6 — ReturnOfGoodsFromCustomer ghi vào GoodsInWarehouses
- **Đề bài (tóm tắt):** Document trả hàng làm tăng quantity và amount ở kho của document.
- **Gợi ý 1 — Hướng đi:** Giống Bài tập 2: document là recorder, Posting ghi movements; trả hàng làm **tăng** số dư.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Tab Posting → register `GoodsInWarehouses`; object module `Posting`; chỉ duyệt tabular section `Products` (không Services); kho = attribute `Warehouse`.
- **Gợi ý 3 — Khung bài làm:**
  1. Đánh dấu register trong tab Posting.
  2. Viết vòng lặp Products trong Posting, mỗi dòng một record tăng số dư.
  3. Bật Write cho record set.
- **Lỗi hay gặp:**
  - Chọn Expense thay vì Receipt.
  - [ghi chú ngoài nguồn] Cấu hình mẫu cuối khóa (sau khi có batch ở các bài sau) có nhánh ghi trả hàng bằng `Expense` với số âm — đó là cách riêng của bản cuối; ở Bài 11 cứ làm theo cách hiểu trực tiếp: trả hàng = Receipt dương.
- **Tự kiểm tra:** Post một return → số dư hàng ở kho tăng đúng số lượng trả.

### Bài tập 7 — Accumulation register Sales (bán − trả, theo customer và contract)
- **Đề bài (tóm tắt):** Register lưu quantity và amount bán hàng (cả goods và services) theo customer và contract; recorders: SalesInvoice và ReturnOfGoodsFromCustomer; bán ghi dương, trả ghi âm; tự xác định Register kind.
- **Gợi ý 1 — Hướng đi:** Chỉ cần **doanh số trong kỳ**, không cần số dư → **Register kind = Turnovers** (mục Register kind, Bảng của register kiểu Turnovers). Với kiểu này record không có RecordType → trả hàng ghi bằng số âm.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Register `Sales`: Dimensions `Product`, `Customer`, `Contract`; Resources `Quantity`, `Amount`.
  - Tab Posting của SalesInvoice và ReturnOfGoodsFromCustomer: thêm `Sales`.
  - Posting duyệt **cả** Products **và** Services (Record wizard chỉ chọn được một tabular section → phần Services phải tự viết). Có thể ghi hai register trong cùng một vòng Products (xem demo "Posting ghi hai register từ một vòng lặp" — nhớ sửa RecordType của GoodsInWarehouses thành Expense).
- **Gợi ý 3 — Khung bài làm:**
```bsl
	// RegisterRecords.Sales.Write = ___
	For Each CurRow In Products Do
		// ... record GoodsInWarehouses (Bài tập 2/6)
		// Record = RegisterRecords.Sales.Add(); Period, Product, Customer, Contract = ___
		// Quantity, Amount = ___ (dấu dương với sales invoice, ___ với return)
	EndDo;
	For Each CurRow In Services Do
		// chỉ ghi Sales, không ghi GoodsInWarehouses
	EndDo;
```
- **Lỗi hay gặp:**
  - Chọn kiểu Balances → vẫn chạy nhưng virtual table Turnovers luôn đọc movement table (chậm khi dữ liệu lớn).
  - Gán `RecordType` cho record của register Turnovers → lỗi.
  - Quên dấu âm ở return → doanh số cộng thay vì trừ.
  - Quên Services.
- **Tự kiểm tra:** Bán 10 sản phẩm cho một customer, trả 2 trong cùng tháng → query/report Sales.Turnovers theo tháng cho customer đó ra Quantity = 8.

### Bài tập 8 — RequiredSalesAmount và discount theo doanh số tháng trước
- **Đề bài (tóm tắt):** Thêm `RequiredSalesAmount` vào CounterpartyContracts; trong SalesInvoice: nếu không điền → luôn được discount; nếu có → chỉ được discount khi doanh số của customer tháng trước vượt RequiredSalesAmount, ngược lại discount = 0. Gợi ý của đề: AddMonth, BegOfMonth, EndOfMonth.
- **Gợi ý 1 — Hướng đi:** Đọc virtual table **Turnovers** của register Sales cho kỳ = tháng trước, Periodicity Month, Condition theo Customer; chỉ cần biết "có/không" có dòng vượt ngưỡng (mục Lấy dữ liệu từ virtual tables).
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Attribute `RequiredSalesAmount` (Number) trong catalog `CounterpartyContracts`, đặt lên item form.
  - Sửa function/procedure tính discount đã có trong object module của SalesInvoice (export, được form gọi khi đổi Contract).
  - Query: `AccumulationRegister.Sales.Turnovers(&BeginOfPeriod, &EndOfPeriod, Month, <condition>)`; resource có hậu tố `Turnover` (`AmountTurnover`); kiểm tra kết quả bằng `QueryResult.IsEmpty()`.
  - Tháng trước: lùi một tháng từ `Date` bằng `AddMonth`, rồi lấy đầu/cuối tháng.
- **Gợi ý 3 — Khung bài làm:**
```bsl
Procedure ___() Export
	// DiscountPercent = Contract.___ ; Required = Contract.___
	If ___ Then
		// query Turnovers tháng trước, Customer = &Customer, AmountTurnover >= &Required
		// PreviousMonth = AddMonth(___, ___)
		// rỗng -> Discount = ___ ; có dòng -> Discount = ___
	Else
		// Discount = ___
	EndIf;
EndProcedure
```
- **Lỗi hay gặp:**
  - Đặt Customer vào WHERE thay vì Condition của virtual table.
  - Lấy tháng hiện tại thay vì tháng trước.
  - Đề nói "exceeds"; [ghi chú ngoài nguồn] lời giải tham khảo của khóa dùng `>=` — quyết định và ghi rõ biên của bạn.
  - Tên tham số query gõ sai giữa Text và SetParameter → lỗi "parameter not set" (lỗi chính tả kiểu này có trong một bản lời giải của khóa).
- **Tự kiểm tra:** Contract có RequiredSalesAmount = 1000; tháng trước bán cho customer 1500 → Sales invoice tháng này nhận discount; đổi sang customer chỉ mua 500 → discount = 0; contract không điền RequiredSalesAmount → luôn có discount.

## Code demo của bài Theory (repo 1CJDCourse, nhánh lesson/11-theory)

> So với lesson/10-theory, nhánh lesson/11-theory thêm hai accumulation register (`GoodsInWarehouses` kiểu Balance, `Sales` kiểu Turnovers), Posting của SalesInvoice và PurchaseInvoice, document ReturnOfGoodsFromCustomer (Generation) và lệnh Copy and Post ở list form của SalesInvoice.

### Posting ghi hai register từ một vòng lặp (SalesInvoice)
Nguồn: nhánh lesson/11-theory — cf/Documents/SalesInvoice/Ext/ObjectModule.bsl
```bsl
Procedure Posting(Cancel, PostingMode)

	RegisterRecords.GoodsInWarehouses.Write = True;
	RegisterRecords.Sales.Write = True;
	
	For Each CurRowProducts In Products Do
		Record = RegisterRecords.GoodsInWarehouses.Add();
		Record.RecordType = AccumulationRecordType.Receipt;
		Record.Period = Date;
		Record.Product = CurRowProducts.Product;
		Record.Warehouse = Warehouse;
		Record.Quantity = CurRowProducts.Quantity;
		Record.Amount = CurRowProducts.Amount;

		Record = RegisterRecords.Sales.Add();
		Record.Period = Date;
		Record.Product = CurRowProducts.Product;
		Record.Customer = Customer;
		Record.Amount = CurRowProducts.Amount;
	EndDo;

	For Each CurRowServices In Services Do
		Record = RegisterRecords.Sales.Add();
		Record.Period = Date;
		Record.Product = CurRowServices.Service;
		Record.Customer = Customer;
		Record.Amount = CurRowServices.Amount;
	EndDo;
	
EndProcedure
```
- Bản Posting viết tay: `Write = True` cho cả hai record sets, duyệt Products **một lần** cho cả hai register (khắc phục điểm Record wizard duyệt lặp tabular section cho từng register) và thêm vòng Services chỉ cho `Sales`.
- Register `Sales` kiểu Turnovers → record không có `RecordType`; register `GoodsInWarehouses` kiểu Balance → phải chọn `RecordType`.
- [ghi chú ngoài nguồn] Demo ghi `AccumulationRecordType.Receipt` cho sales invoice; về nghiệp vụ, bán hàng giảm số dư kho nên phải là `Expense` (xem Thẻ gợi ý bài thực hành, Bài tập 2).

### Posting đã tối ưu + BeforeWrite/AdditionalProperties với IsNew() (PurchaseInvoice)
Nguồn: nhánh lesson/11-theory — cf/Documents/PurchaseInvoice/Ext/ObjectModule.bsl
```bsl
Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	AdditionalProperties.Insert("IsNew", IsNew());
EndProcedure

Procedure Posting(Cancel, PostingMode)
	
	If AdditionalProperties.IsNew Then
	
		// Some code execution	
	
	EndIf;
	
	GoodsInWarehouses = RegisterRecords.GoodsInWarehouses;
	GoodsInWarehouses.Write = True;
	
	For Each ProductsRow In Products Do
	
		NewRecord = GoodsInWarehouses.AddReceipt();
		NewRecord.Period 	= Date;
		NewRecord.Warehouse = Warehouse;
		NewRecord.Product 	= ProductsRow.Product;
		NewRecord.Quantity 	= ProductsRow.Quantity;
		NewRecord.Amount 	= ProductsRow.Amount;
	
	EndDo;
	
EndProcedure
```
- Đúng ví dụ lý thuyết: `IsNew()` không kiểm tra được trong Posting (object đã được ghi) nên được kiểm tra trong `BeforeWrite` và truyền sang qua `AdditionalProperties`.
- Bản tối ưu của code Record wizard: gán record set vào biến `GoodsInWarehouses`, dùng `AddReceipt()` thay cho `Add()` + `RecordType = AccumulationRecordType.Receipt`.
- `Write = True` → record set được tự ghi khi thoát Posting.

### Filling do Generation settings wizard tạo (ReturnOfGoodsFromCustomer dựa trên SalesInvoice)
Nguồn: nhánh lesson/11-theory — cf/Documents/ReturnOfGoodsFromCustomer/Ext/ObjectModule.bsl
```bsl
Procedure Filling(FillingData, StandardProcessing)
	//{{__CREATE_BASED_ON_WIZARD
	// This fragment was built by the wizard.
	// Warning! All manually made changes will be lost next time you use the wizard.
	If TypeOf(FillingData) = Type("DocumentRef.SalesInvoice") Then
		// Filling the headline
		SalesDocument 	= FillingData;
		Company 		= FillingData.Company;
		Contract 		= FillingData.Contract;
		Customer 		= FillingData.Customer;
		Warehouse 		= FillingData.Warehouse;
		For Each CurRowProducts In FillingData.Products Do
			NewRow = Products.Add();
			NewRow.Amount = CurRowProducts.Amount;
			NewRow.Price = CurRowProducts.Price;
			NewRow.Product = CurRowProducts.Product;
			NewRow.Quantity = CurRowProducts.Quantity;
		EndDo;
		For Each CurRowServices In FillingData.Services Do
			NewRow = Services.Add();
			NewRow.Amount = CurRowServices.Amount;
			NewRow.Price = CurRowServices.Price;
			NewRow.Quantity = CurRowServices.Quantity;
			NewRow.Service = CurRowServices.Service;
		EndDo;
	EndIf;
	//}}__CREATE_BASED_ON_WIZARD
EndProcedure
```
- Bản nguyên gốc do wizard tạo, còn service comments `//{{__CREATE_BASED_ON_WIZARD` … `//}}__CREATE_BASED_ON_WIZARD`: chạy lại wizard thì đoạn này bị thay toàn bộ, mất sửa tay.
- Trong ReturnOfGoodsFromCustomer.xml, `BasedOn` = `Document.SalesInvoice`; `TypeOf(FillingData) = Type("DocumentRef.SalesInvoice")` kiểm tra kiểu object nguồn.
- Bản wizard chưa có `Products.Clear()` và chưa chép `Discount`, `DocumentTotal` — khi làm Practice cần tự bổ sung (xem Thẻ gợi ý bài thực hành, Bài tập 4).

### Lệnh "Copy and Post" ở list form (Copy() + Write + Refresh())
Nguồn: nhánh lesson/11-theory — cf/Documents/SalesInvoice/Forms/ListForm/Ext/Form/Module.bsl
```bsl
&AtServer
Procedure CopyAndPostAtServer()
	
	DocumentRef = Items.List.CurrentRow;
	If ValueIsFilled(DocumentRef) Then
		NewDocument = DocumentRef.Copy();
		// NewDocument variable contains a value of type DocumentObject
		NewDocument.Write(DocumentWriteMode.Posting, DocumentPostingMode.RealTime);
		
		Items.List.Refresh();
	Else
		Message("No document selected for copying");
	EndIf;
	
EndProcedure

&AtClient
Procedure CopyAndPost(Command)
	CopyAndPostAtServer();
EndProcedure
```
- Command `CopyAndPost` (nút `FormCopyAndPost` trên command bar của list form) có Action tạo theo kiểu "Create on client and a procedure on server": client handler chỉ gọi `CopyAndPostAtServer()`.
- `Items.List.CurrentRow` của dynamic list là reference document đang chọn; `Copy()` trả về DocumentObject mới, chưa ghi.
- Phải gọi `Write(DocumentWriteMode.Posting, DocumentPostingMode.RealTime)`, nếu không bản copy bị mất; sau đó `Items.List.Refresh()` để list hiện document mới.

## Video tham khảo

Video bài giảng trên YouTube có phạm vi trùng với bài này. Khi dẫn cho người học, nói "Bạn có thể tham khảo thêm về <chủ đề> của khóa tại đây: [<tên video>](link)" — không nói "khóa cũ/Junior", không dùng mã JC (mã JC trong danh sách chỉ để tra nội bộ). Quy ước đầy đủ: `references/video.md#video-junior-course`.

- [Chứng từ và biểu ghi tích lũy](https://www.youtube.com/watch?v=dQt7_Ln8zVI&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=6) (4:50) — Bài 3 — Document; Bài 11 — Accumulation register, posting _(mã nội bộ JC-7)_
- [Kết chuyển chứng từ](https://www.youtube.com/watch?v=fsu3Wqn9wz8&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=21) (8:01) — Bài 11 — Document posting, event Posting, RegisterRecords, posting mode _(mã nội bộ JC-22)_
- [Biểu ghi tích lũy](https://www.youtube.com/watch?v=wbF-aWunEdc&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=22) (13:46) — Bài 11 — Accumulation register Balances/Turnovers, dimensions, resources, virtual tables _(mã nội bộ JC-23)_
- [Truy vấn SQL và cấu trúc truy vấn](https://www.youtube.com/watch?v=E3EJ6WRG8Sk&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=40) (4:32) — Bài 10 — cấu trúc query; Bài 11 — virtual tables _(mã nội bộ JC-41)_
- [FROM và WHERE](https://www.youtube.com/watch?v=PtCdTq0a1nM&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=42) (5:58) — Bài 10 — FROM, WHERE; Bài 11 — lọc trong tham số virtual table _(mã nội bộ JC-43)_

<!-- video-qa-thuchanh:start -->

Video giải đáp tình huống thực chiến và video thực hành từng bước liên quan tới bài này (thẻ chi tiết, triệu chứng, lưu ý khi giới thiệu: `references/video.md#video-qa-thuc-chien`, `references/video.md#video-thuc-hanh`; cùng mẫu câu dẫn ở trên):

- [Xây dựng cơ chế tích điểm thưởng](https://www.youtube.com/watch?v=0aAaQQP9fXI&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=14) (23:35) — tích và trừ điểm thưởng qua register (giải đáp tình huống; Bài 11 chính) _(mã nội bộ QA-14)_
- [Chặn kết chuyển khi phát hiện tồn kho âm](https://www.youtube.com/watch?v=k2uht5J1f3c&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=25) (10:03) — kiểm soát âm kho khi posting (giải đáp tình huống; Bài 11 chính) _(mã nội bộ QA-25)_
- [Ghi nhận luân chuyển dòng tiền](https://www.youtube.com/watch?v=YzhM76Wy9fk&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=7) (18:29) — quỹ tiền mặt: thu/chi, posting, số dư trên form và đánh số chứng từ (thực hành case study; Bài 11 chính) _(mã nội bộ P1-6)_
- [Hệ thống cho thuê xe điện](https://www.youtube.com/watch?v=wWGXT2KSul8&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=4) (10:40) — một chứng từ ghi vào hai register (thực hành case study; Bài 11 chính) _(mã nội bộ P2-4)_
- [Tạo lập hệ thống thông tin thư viện](https://www.youtube.com/watch?v=3DMFgUjg2Js&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=5) (24:38) — mượn – trả và tạo phiếu trả từ phiếu mượn (thực hành case study; Bài 11 chính) _(mã nội bộ P2-5)_
- [Hạch toán hàng hóa - Bài toán đơn giản nhất](https://www.youtube.com/watch?v=SwgfC-uA6Eg&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=10) (16:55) — nhập – xuất – tồn và chặn âm kho (thực hành case study; Bài 11 chính) _(mã nội bộ P2-10)_
- [Hạch toán hàng hóa - Hạch toán một kho](https://www.youtube.com/watch?v=BD370AtszHI&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=11) (20:57) — tồn kho theo từng kho (kho trên đầu chứng từ) (thực hành case study; Bài 11 chính) _(mã nội bộ P2-11)_
- [Hạch toán hàng hóa nhiều kho (Full)](https://www.youtube.com/watch?v=HIAYMOepPw4&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=12) (18:40) — kho trên từng dòng hàng và chặn âm theo từng kho (thực hành case study; Bài 11 chính) _(mã nội bộ P2-12)_
- [Hạch toán hàng hóa nhiều kho (Short)](https://www.youtube.com/watch?v=sHl70mbjk4c&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=13) (14:51) — sửa cấu trúc chứng từ đang có dữ liệu (thực hành case study; Bài 11 chính) _(mã nội bộ P2-13)_
- [Hạch toán hàng hóa - Theo hạn sử dụng](https://www.youtube.com/watch?v=TBgeOMXYp0w&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=14) (13:24) — tồn kho theo hạn sử dụng và xuất dần theo lô (thực hành case study; Bài 11 chính) _(mã nội bộ P2-14)_
- [Cách hiển thị biểu ghi tích lũy lên phân hệ](https://www.youtube.com/watch?v=DBJeS7LfUpY&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=4) (1:53) — cách hiện register lên phân hệ (giải đáp tình huống; Bài 11 liên quan) _(mã nội bộ QA-4)_
- [Báo cáo lợi nhuận theo kỳ](https://www.youtube.com/watch?v=98gDiVV8jx0&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=8) (9:16) — báo cáo DCS theo kỳ (giải đáp tình huống; Bài 11 liên quan) _(mã nội bộ QA-8)_
- [Truy vấn tồn kho trong chứng từ bán hàng](https://www.youtube.com/watch?v=13817kAvhwQ&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=17) (9:53) — hiển thị tồn kho khi chọn hàng (giải đáp tình huống; Bài 11 liên quan) _(mã nội bộ QA-17)_
- [Lưu trữ và báo cáo kết quả học tập của sinh viên](https://www.youtube.com/watch?v=NhFE1uwi7Hw&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=3) (14:56) — chấm điểm qua chứng từ và báo cáo trung bình có tô màu (thực hành case study; Bài 11 liên quan) _(mã nội bộ P2-3)_
- [Hạch toán thu nhập theo doanh số](https://www.youtube.com/watch?v=QRAzQKBCtds&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=8) (20:00) — quy đổi tỷ giá khi posting bằng SliceLast (thực hành case study; Bài 11 liên quan) _(mã nội bộ P2-8)_

<!-- video-qa-thuchanh:end -->


---

# § bai-12

# Bài 12 — Data validation, Information registers, Transactions, Errors & Event log

## Khái niệm chính

### Data validation (kiểm tra dữ liệu)
- Kiểm tra đơn giản: property **"Required field"** = **"Display error"** của attribute/tabular section.
- Kiểm tra phức tạp: không chỉ kiểm tra đã điền mà còn kiểm tra dữ liệu đúng (ví dụ: bán hàng chịu VAT thì mỗi dòng phải có VAT rate; Sales order có "Shipment date" không được sớm hơn ngày document).
- Trước tiên xác định khi nào kiểm tra: mọi lần ghi, lúc posting, lúc ghi/post nhưng chỉ interactively (từ form). Với document thường kiểm tra lúc posting (document chưa post giống bản nháp).
- Event **FillCheckProcessing** của object — xảy ra trong 2 trường hợp:
  - Làm việc interactive (trực tiếp từ giao diện): với document có posting mode — khi posting interactive; với object khác có event này — khi ghi interactive.
  - Làm việc từ code: gọi method **CheckFilling()** của object kích hoạt FillCheckProcessing. Không gọi method này thì kể cả posting document từ code cũng không phát sinh event.
- 2 tham số của procedure:
  - **Cancel**: mặc định False; đổi thành True → posting (hoặc ghi, với object không có posting) không thực hiện, user thấy cửa sổ hệ thống báo thao tác thất bại.
  - **CheckedAttributes**: chứa tên các attributes và tabular sections sẽ được kiểm tra khi thoát procedure.
- Cách điển hình cho kiểm tra có điều kiện: đặt "Required field" = "Display error", rồi trong handler loại attribute/tabular section khỏi danh sách kiểm tra theo điều kiện.
- Ví dụ: Sales Invoice có 2 tabular sections Products và Services, yêu cầu ít nhất một dòng ở một trong hai → đặt cả hai bắt buộc, trong FillCheckProcessing loại Services khỏi kiểm tra nếu Products có dòng, và ngược lại.
- Phần tử mảng phải xóa theo index; lấy index bằng method **Find()** — trả về Undefined nếu không tìm thấy. Code tìm và xóa lặp lại → tách ra procedure riêng.
- Ví dụ phức tạp hơn: cột Amount của Products bắt buộc, trừ sản phẩm khuyến mãi (attribute "Promotional" của catalog Products, giá 0).
  - Ẩn "Weight" và "Promotional" với product kiểu Service: thêm group trên form, dùng handler **OnChange** của field Type; đồng thời gọi cập nhật visibility từ event client **OnOpen** (vì khi mở form, visibility là mặc định). Tách code thành procedure riêng gọi từ cả hai handler.
  - Kiểm tra bằng query chọn các dòng Products có amount rỗng, product thuộc kiểu product và không "Promotional" (Promotional = False).
  - **Rất quan trọng**: FillCheckProcessing chạy TRƯỚC khi object được ghi vào database → không thể chọn dữ liệu object theo reference; phải dùng dữ liệu object hiện có: truyền dữ liệu tabular section vào query, chọn vào temporary table, rồi dùng temporary table trong các query sau.
  - Hủy ghi/post: đổi Cancel = True và thông báo lỗi cho user (thông báo cho từng dòng lỗi, ví dụ dòng 1 và 3).

### Information registers
- Mục đích: lưu thông tin cần cho các nhiệm vụ khác nhau. Khác accumulation register (resources luôn là số), information register lưu được mọi loại thông tin (người chịu trách nhiệm của tổ chức, email settings, giá sản phẩm...).
- Cấu trúc giống accumulation register: dimensions, resources, details (attributes). Khác biệt: nền tảng kiểm soát **tính duy nhất của records theo tập dimensions** → không thể có 2 records cùng tập dimensions (sẽ phát sinh exception).
- Ví dụ: Dimensions: Organization; Resources: CEO, Chief Accountant, CTO.

### Periodic information registers
- Property **"periodicity"**: lưu giá trị theo tập dimensions + period. Giá trị: **None, Second, Day, Month, Quarter, Year**.
- Ví dụ periodicity "Day" → chỉ đổi resources cho cùng tổ chức tối đa một lần/ngày. Nền tảng kiểm soát duy nhất theo dimensions + service attribute **Period** (tự thêm trong periodic register).
- Giá trị **"By recorder position"**: chỉ chọn được ở periodic information register subordinate to recorder; cho phép records cùng dimensions + period với các recorder khác nhau. Thực tế gần như không gặp.

### Virtual tables của information register
- Chỉ có virtual tables khi register là periodic. 2 virtual tables: **SliceFirst** và **SliceLast**.
- SliceLast trả về dữ liệu mới nhất cho từng tập dimensions tại ngày chỉ định (ví dụ tại 1/25/2024 → Development company bản 1/15, Best chocolate bản 1/22; tại 1/21/2024 11:59:59 PM → Best chocolate trả bản 1/15).

### Write mode
- Records information register có thể thay đổi trực tiếp, không cần recorder document — gọi là **independent** register. Điều khiển bằng property **"Write mode"** = **"Independent"** (mặc định khi tạo register).
- Independent register dùng khi không gắn với business processes hoặc không cần hạn chế user truy cập trực tiếp register. (Ví dụ: giá sản phẩm nên đổi qua document cài đặt giá riêng để tránh user sửa register không để lại dấu vết.) Thường là service registers: "Email settings", "Exchange history", "Financial accounting policy"...
- Document là phản ánh một nghiệp vụ; nếu không có nghiệp vụ thiết lập người chịu trách nhiệm thì không tạo document → register "Companies responsible persons" nên là independent.
- Ghi vào independent register từ code giống register subordinate to recorder, nhưng không cần reference tới recorder.

### Đọc dữ liệu information register
- Bằng query tới virtual tables, hoặc bằng methods của register:
  1. Tương đương hoàn toàn query: **SliceFirst(<BeginOfPeriod>, <Filter>)**, **SliceLast(<EndOfPeriod>, <Filter>)** → trả về value table (có thể rỗng nếu không có dữ liệu khớp).
  2. Chỉ lấy resource values của một tập dimensions: **GetFirst(<BeginOfPeriod>, <Filter>)**, **GetLast(<EndOfPeriod>, <Filter>)** → trả về structure với properties trùng resources; nếu không có record khớp, giá trị là default của kiểu resource.
- Dữ liệu chỉ đọc được trên server → dùng handler **OnCreateAtServer** của form.
- **FillPropertyValues()** (global method): tham số Receiver, Source; các giá trị trùng tên được điền vào Receiver.
- Ghi dữ liệu form vào register: lấy lại bản ghi cuối cho ngày hiện tại, so sánh resources với attributes của form; nếu ít nhất một khác → thêm record với giá trị form và ngày hiện tại. Ban đầu đặt ở **AfterWriteAtServer** (sau khi object đã ghi và transaction đã commit); code lấy bản ghi cuối tách thành hàm riêng. (Sau đó được chuyển sang OnWriteAtServer — xem phần Transactions.)

### RecordSet và RecordManager
- **RecordSet**: công cụ chung để đọc, ghi, xóa records register. Khi làm việc với movements accumulation register từ document cũng là RecordSet (lấy từ property RegisterRecords).
- **RecordManager**: add-on của RecordSet, tiện cho làm việc với MỘT record của information register. Chỉ dùng được cho **independent** information registers.
  - **Note**: RecordManager ở mức hệ thống dùng 2 RecordSets (một xóa record cũ, một thêm record mới) → không khuyến khích khi xử lý số lượng lớn records; dùng RecordSet.
- Cả hai có method **Write()** với tham số **Replace** (Boolean): có ghi đè records nếu đã tồn tại records cùng tập dimensions hay không. Ví dụ cần thay giá trị cũ vì có thể đổi người chịu trách nhiệm trong cùng ngày.
- Xóa: RecordManager xóa một record; RecordSet xóa bao nhiêu cũng được theo filter giá trị dimensions và period (với periodic registers). Với RecordSet: xóa từng record bằng **Delete()**, hoặc xóa toàn bộ theo selection bằng **Write(True)** (ghi đè cưỡng bức).
- Information register subordinate to recorder làm việc giống accumulation register.

### Quick navigation tới register records
- Ví dụ SalesInvoice ghi vào GoodsInWarehouses và Sales: mở form document → tab **Command interface** → mở nhánh **"Go to"** → bật flag ở cột **Visible**. Khi chuyển sang tab register records, danh sách được lọc theo recorder = document hiện tại.
- Với independent register (không có recorder): records có thể subordinate tới objects là dimensions của register. Chọn dimension cần hiển thị, bật property **"Master"** của dimension. Property này nghĩa là record subordinate tới object được tham chiếu trong dimension; nếu object đó bị xóa khỏi database, nền tảng tự động xóa các records subordinate.

### Transactions
- Transaction: chuỗi thao tác dữ liệu không thể chia, đưa database từ trạng thái toàn vẹn này sang trạng thái toàn vẹn mới. Mọi thao tác trong transaction hoặc được commit (transaction commit) hoặc bị hủy (transaction rollback).
- **Implicit**: nền tảng tự bắt đầu và kết thúc khi thay đổi thông tin trong database; developer có thể xây dựng thuật toán để ngắt chúng.
- **Explicit**: developer điều khiển bằng code qua global context methods **BeginTransaction()**, **CommitTransaction()**, **RollbackTransaction()**.
- Ví dụ: import counterparty và contract (CounterpartyContracts subordinate tới Counterparties, standard attribute **Owner** bắt buộc). Lỗi khi ghi contract → phải hủy cả counterparty. Code đặt trong `Try - Except - EndTry`.
  - Mọi thay đổi sau khi bắt đầu transaction không có hiệu lực trong database cho đến khi CommitTransaction() → đặt cuối khối Try.
  - Trong khối Except, bước đầu tiên là RollbackTransaction(), rồi ghi log, báo user...
- Event diagram của Document khi posting từ form ("Post" / "Post and close"): các event trong transaction do nền tảng tự bắt đầu/kết thúc. Developer có thể hủy transaction bằng cách đặt Cancel = True trong handler chạy trong transaction hoặc raise exception. Object không có posting thì không có event Posting, các event còn lại và thứ tự giống nhau.
- Vấn đề với **AfterWriteAtServer**: chạy sau khi transaction ghi đã commit → object có thể đã ghi nhưng ghi register lỗi; cờ form modified (property **"Modified"**) đã bị bỏ → user mất một phần thay đổi và không thể hủy.
  - Giải pháp: chuyển thuật toán sang **OnWriteAtServer** (chạy trong transaction, có thể hủy nếu lỗi). Nếu cần ghi register cả khi ghi từ object (không chỉ từ form) → đặt vào event object **OnWrite** (trong object module); event **BeforeWrite** xảy ra trước khi object được ghi vào database.
- 2 cách hủy transaction từ event: (1) đổi **Cancel** = True; (2) raise exception. Khác biệt:
  - Với user: raise exception → cửa sổ có error text, icon lỗi, nút OK. Cancel = True → error text hiện trong message window dưới form; cửa sổ có nút OK chỉ hiện cho event Post Processing, không có error text mà là text do nền tảng tạo báo document không post được.
  - Với chương trình: raise exception ngắt thực thi code tiếp theo; Cancel = True thì không. Khi không nên ngắt code (ví dụ kiểm tra cột Amount của Products — để báo tất cả các dòng lỗi) → dùng cách Cancel; nếu không, user chỉ nhận thông báo cho một dòng.

### Errors và exception handling
- Implicit exceptions: lỗi không do developer gọi bằng **Raise**, ví dụ truy cập property không tồn tại, chia cho 0, lỗi khi làm việc với database object.
- Có thể phòng một số lỗi bằng kiểm tra (ví dụ kiểm tra số chia khác 0). Nhưng có lỗi không thể lường trước (ví dụ mọi lý do khiến document tạo/post bằng code bị lỗi) → dùng `Try - Except - EndTry`: lỗi trong Try không làm vỡ thực thi mà chuyển sang Except, nơi developer xử lý lỗi.
- Có khi chỉ cần ghi Event Log; có khi cần báo user. Nếu không còn ý nghĩa thực thi code tiếp → sau khi xử lý, raise exception tường minh bằng **Raise** (explicit tốt hơn implicit vì developer có thể thực hiện hành động liên quan và sửa thông báo cho dễ hiểu).
- Lấy thông tin lỗi (chỉ có ý nghĩa trong khối Except): **ErrorInfo()**, **ErrorDescription()**, và global context object **ErrorProcessing** (kiểu **ErrorProcessingManager**).
  - ErrorInfo() trả về object kiểu **ErrorInfo**.
  - WriteEventLog() thêm record vào Event log.
  - Mô tả ngắn: method **BriefErrorDescription** của ErrorProcessing.
- Không bỏ qua xử lý exception: không để khối Except rỗng. Lý tưởng: luôn ghi thông tin exception vào Event log.

### Event log
- Dùng để biết sự kiện nào xảy ra tại thời điểm nào, user nào thực hiện hành động gì; admin lấy lịch sử thao tác.
- Event log **không phải là một phần của database** và không được lưu khi export/import infobase.
- 1C:Enterprise ghi các hành động chính: thay đổi infobase, cấp/từ chối truy cập, routine operations, đăng nhập, đăng xuất...
- Ghi log bằng code: method **WriteLogEvent()** — khuyến nghị dùng khi admin cần thông tin chẩn đoán bổ sung về sự kiện mà nền tảng không ghi (cả trong interactive và background (scheduled) tasks). Một entry ứng với một sự kiện.
- WriteLogEvent() chạy trên server, có 6 tham số:
  - **EventName** (String): nhóm theo "Event group name.Event name" (ví dụ "Tasks.New task notification"). Không đưa giá trị cụ thể từ infobase/hệ thống ngoài vào tên sự kiện (sai: "Cannot cancel posting document <Sales KP00-00002 dated 11/10/2020>"; đúng: "Document posting.Cannot unpost", "Employees.Employee not found in the infobase").
  - **Level** (EventLogLevel): "Error" (lỗi nghiêm trọng, lỗi business logic, hỏng ứng dụng), "Warning" (vấn đề tiềm ẩn, lỗi không nghiêm trọng), "Information" (thao tác thành công), "Comment" (mức thấp nhất).
  - **MetadataObject**: chỉ định metadata object liên quan; nếu không gắn object cụ thể, chỉ định module nơi lỗi xảy ra (ví dụ `Metadata.CommonModules.IntegrationWith<ServiceName>`).
  - **Data**: reference tới object cụ thể, hoặc primitive types, Undefined, Null, Type. Chỉ điền khi giúp lọc chính xác hơn; không điền reference tới object chưa được ghi (object không tồn tại).
  - **Commentary** (String): thông tin dạng text không cấu trúc; không gộp nhiều sự kiện vào một comment; không đặt dữ liệu có kích thước không biết trước (nội dung file, response web service...) — hướng tới tối đa **10 KB**.
  - **TransactionMode** (EventLogEntryTransactionMode): independent hoặc transactional; sự kiện trong transaction → dùng "Transactional".
- Ghi thông tin exception vào log: `ErrorProcessing.DetailErrorDescription(ErrorInfo())`.
- Mở Event log: Designer — menu **Administration - Event log**; Enterprise mode — menu **"Functions for technician"** (technician mode thường bị tắt trong infobase mới, cần bật trước).

## Cú pháp & ví dụ code

FillPropertyValues:
```bsl
FillPropertyValues(ThisObject, LastValues);
```

Explicit transaction:
```bsl
Procedure LoadCounterpartyAndContract(ExternalData)
    // no need to begin a transaction inside the Try statement
    BeginTransaction(); 
    Try
        Counterparty = Catalogs.Counterparties.CreateItem();
        FillPropertyValues(Counterparty, ExternalData);
        Counterparty.Write();
        
        CounterpartyContract = Catalogs.CounterpartyContracts.CreateItem();
        FillPropertyValues(CounterpartyContract, ExternalData);
        
        CounterpartyContract.Owner = Counterparty.Ref;
        CounterpartyContract.Write();
        // If no errors occurred, commit all changes to the database
        CommitTransaction();
    Except
        // If there was an error, cancel all changes, so they won't be written to the database
        RollbackTransaction();
        
        ErrorInformation = DetailErrorDescription(ErrorInfo());
        
        WriteLogEvent(
            "Data import",
            EventLogLevel.Error,,,
            ErrorInformation,
            EventLogEntryTransactionMode.Transactional
        );
        
        Message(ErrorInformation);
    EndTry;
EndProcedure
```

Implicit exceptions — truy cập property không tồn tại:
```bsl
IntegrationSettings = New Structure;
IntegrationSettings.Insert("Name", "James Bond");
IntegrationSettings.Insert("Password", "007");
WebAddress = IntegrationSettings.WebAddress;
```

Chia cho 0:
```bsl
Amount = 10;
Quantity = 0;
Price = Amount/Quantity;
```

Lỗi khi làm việc với database object:
```bsl
NewSalesInvoice = Documents.SalesInvoice.CreateDocument();
NewSalesInvoice.Write(DocumentWriteMode.Posting);
```

WriteLogEvent — chữ ký:
```bsl
WriteLogEvent(
    EventName (String),
    Level (EventLogLevel),
   MetadataObject (Metadata.Documents.SalesInvoice, Metadata.CommonModules.TasksClient...),
   Data (Type: Any reference, Number, String, Date, Boolean, Undefined,Null, Type),
   Commentary (String),
   TransactionMode (EventLogEntryTransactionMode)
);
```

Tên sự kiện:
```bsl
"Tasks.New task notification"
"Tasks.Pending task notification"

// Correct:
"Document posting.Cannot unpost"
"Employees.Employee not found in the infobase"
```

Ghi exception vào log:
```bsl
ErrorProcessing.DetailErrorDescription(ErrorInfo())
```

[ghi chú ngoài nguồn] Các ví dụ khác (FillCheckProcessing với CheckedAttributes và Find(), visibility theo Type, query kiểm tra Amount qua temporary table, GetLast trong OnCreateAtServer, ghi bằng RecordManager, xóa bằng RecordSet, xử lý exception với BriefErrorDescription) chỉ có dạng ảnh chụp màn hình, không có văn bản code nên không được chép lại. → FillCheckProcessing với Find(), visibility theo Type, query Amount qua temporary table, GetLast trong OnCreateAtServer, RecordManager và BriefErrorDescription → xem mục Code demo của bài Theory (nhánh lesson/12-theory). Riêng ví dụ xóa bằng RecordSet không có trong nhánh lesson/12-theory nên vẫn chưa có code.

## Thuộc tính/thiết lập quan trọng trong Designer
- Attribute / tabular section: **Required field** = **Display error**.
- Object event: **FillCheckProcessing** (tham số **Cancel**, **CheckedAttributes**); method **CheckFilling()**.
- Form events: **OnOpen**, **OnCreateAtServer**, **OnWriteAtServer**, **AfterWriteAtServer**; field event **OnChange**; form property **Modified**.
- Object events: **BeforeWrite**, **OnWrite**, **Posting**.
- Information register: **Periodicity** (None, Second, Day, Month, Quarter, Year, **By recorder position**); service attribute **Period**; **Write mode** = **Independent** (mặc định) / subordinate to recorder.
- Dimension: property **Master**.
- Document form: tab **Command interface** → nhánh **Go to** → cột **Visible**.
- Catalog subordinate: standard attribute **Owner**.
- Event log: Designer **Administration - Event log**; Enterprise **Functions for technician**.

## Lỗi thường gặp / lưu ý
- Posting document từ code không kích hoạt FillCheckProcessing nếu không gọi CheckFilling().
- Trong FillCheckProcessing không thể đọc dữ liệu object theo reference (object chưa được ghi) → dùng dữ liệu object hiện tại qua temporary table.
- Xóa phần tử mảng phải theo index (Find() trả Undefined nếu không có).
- Visibility chỉ cập nhật trong OnChange → phải gọi thêm từ OnOpen.
- Thêm record trùng tập dimensions (+ Period nếu periodic) vào information register → exception.
- RecordManager chỉ dùng cho independent register; không dùng cho số lượng lớn records (dùng 2 RecordSets bên trong).
- Ghi register trong AfterWriteAtServer (sau commit) → có thể mất một phần thay đổi; chuyển sang OnWriteAtServer / OnWrite.
- Đặt CommitTransaction() cuối khối Try; RollbackTransaction() đầu khối Except; BeginTransaction() không cần đặt trong Try.
- Raise exception ngắt code — khi cần báo tất cả lỗi, dùng Cancel = True.
- Không để khối Except rỗng; luôn ghi exception vào Event log.
- Event name không chứa giá trị cụ thể; comment không gộp nhiều sự kiện, không quá ~10 KB; không truyền reference tới object chưa ghi vào Data.
- Event log không nằm trong database, không theo export/import infobase.

## Điểm cần nhớ
- FillCheckProcessing: Cancel + CheckedAttributes; kích hoạt khi post/ghi interactive hoặc khi gọi CheckFilling().
- Information register: duy nhất theo dimensions (+ Period nếu periodic); resources có thể là bất kỳ kiểu nào.
- Chỉ periodic register mới có virtual tables SliceFirst / SliceLast; methods SliceFirst/SliceLast (value table) và GetFirst/GetLast (structure).
- Write mode Independent cho phép ghi trực tiếp; RecordSet (nhiều records) vs RecordManager (một record, chỉ independent); Write(Replace).
- Property Master của dimension: điều hướng "Go to" cho independent register + tự xóa records khi object bị xóa.
- Transactions: BeginTransaction / CommitTransaction / RollbackTransaction trong Try-Except; OnWriteAtServer/OnWrite chạy trong transaction, AfterWriteAtServer thì không.
- Cancel = True không ngắt code; Raise ngắt code.
- WriteLogEvent(EventName, Level, MetadataObject, Data, Commentary, TransactionMode); ghi exception bằng ErrorProcessing.DetailErrorDescription(ErrorInfo()).

## Thẻ gợi ý bài thực hành (Practice 12)

> Thẻ gợi ý dẫn hướng cho từng yêu cầu của 12. Practice.docx; không có lời giải hoàn chỉnh. Nhắc lại yêu cầu chung của đề: mọi object mới phải nằm trong subsystem phù hợp và có synonym đúng cho list form, item form, record form.

### Bài tập 1 — InventoryTransfer: chặn posting khi kho gửi = kho nhận
- **Đề bài (tóm tắt):** Không cho post document có WarehouseSender trùng WarehouseRecepient, kèm thông báo rõ ràng.
- **Gợi ý 1 — Hướng đi:** Kiểm tra logic giữa hai attribute (không chỉ "đã điền") → event **FillCheckProcessing** của object (mục Data validation); hủy bằng tham số **Cancel**.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Object module của InventoryTransfer, `Procedure FillCheckProcessing(Cancel, CheckedAttributes)`; so sánh hai attribute; `Message(...)` để báo user.
- **Gợi ý 3 — Khung bài làm:**
```bsl
Procedure FillCheckProcessing(Cancel, CheckedAttributes)
	If ___ Then
		// hủy posting: Cancel = ___
		// thông báo cho user: ___
	EndIf;
EndProcedure
```
- **Lỗi hay gặp:**
  - Đặt kiểm tra trong `Posting` → vẫn chạy được nhưng sai vị trí; FillCheckProcessing là chỗ dành cho kiểm tra dữ liệu nhập.
  - Quên rằng post từ code không gọi FillCheckProcessing nếu không gọi `CheckFilling()`.
  - Hai kho đều rỗng cũng "bằng nhau" → nên để Required field xử lý trường hợp rỗng.
- **Tự kiểm tra:** Chọn cùng một kho ở hai field rồi Post → không post được, thấy thông báo; đổi kho nhận khác → post bình thường.

### Bài tập 2 — Catalog Companies và attribute Company trong documents
- **Đề bài (tóm tắt):** Tạo object lưu danh sách công ty của mình; thêm attribute bắt buộc Company vào PurchaseInvoice, SalesInvoice, ReturnOfGoodsFromCustomer; sửa Filling của return để chép Company từ sales invoice.
- **Gợi ý 1 — Hướng đi:** Danh sách công ty → Catalog; "bắt buộc" → property **Required field** = Display error; Filling của return đã có từ Bài 11, chỉ cần thêm một dòng gán.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Catalog `Companies`; attribute `Company` (`CatalogRef.Companies`, Required field) trong ba documents + đặt field lên form; handler `Filling` trong object module của ReturnOfGoodsFromCustomer.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo catalog Companies, đưa vào subsystem (ví dụ Master data).
  2. Thêm attribute Company vào 3 documents, đặt Required field, kéo lên form.
  3. Trong Filling của return: thêm phép gán Company từ `FillingData`.
- **Lỗi hay gặp:**
  - Sửa Filling bằng cách chạy lại Generation settings wizard → mất phần đã sửa tay ở Bài 11.
- **Tự kiểm tra:** Tạo return từ một sales invoice có Company → field Company được điền; xóa Company rồi post → báo lỗi field bắt buộc.

### Bài tập 3 — Dimension Company trong register Sales
- **Đề bài (tóm tắt):** Thêm dimension Company vào accumulation register Sales và sửa Posting của mọi document ghi register này.
- **Gợi ý 1 — Hướng đi:** Thêm dimension mới → mọi nơi tạo record của register phải gán dimension đó (mục Document posting, RegisterRecords).
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Register `Sales` → dimension `Company`; Posting của SalesInvoice và ReturnOfGoodsFromCustomer: thêm phép gán Company cho record ở **mọi** vòng lặp ghi Sales.
- **Gợi ý 3 — Khung bài làm:**
  1. Thêm dimension.
  2. Tìm mọi chỗ `RegisterRecords.Sales.Add()` (Edit → Find in modules).
  3. Ở mỗi chỗ, gán `Company` của document.
- **Lỗi hay gặp:**
  - Chỉ sửa vòng Services hoặc chỉ vòng Products. [ghi chú ngoài nguồn] Một bản lời giải trung gian của khóa chỉ gán Company ở vòng Services, quên vòng Products — đừng lặp lại lỗi này.
  - Quên document ReturnOfGoodsFromCustomer.
- **Tự kiểm tra:** Re-post một sales invoice có cả goods và services, mở records của register Sales → mọi dòng đều có Company.

### Bài tập 4 — Banks, BankAccounts (subordinate tới Companies/Counterparties), subsystem Funds
- **Đề bài (tóm tắt):** Catalog Banks và BankAccounts: một bank có nhiều account, mỗi account có đúng một bank bắt buộc; subsystem Funds; mỗi bank account subordinate tới một company **hoặc** counterparty.
- **Gợi ý 1 — Hướng đi:** "Subordinate tới company hoặc counterparty" → catalog **subordinate** với property **Owners** chứa hai catalog (standard attribute **Owner**); liên kết với bank → attribute thường, bắt buộc.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** `BankAccounts`: tab Owners → thêm `Catalog.Companies` và `Catalog.Counterparties`; attribute `Bank` (`CatalogRef.Banks`, Required field = Display error); subsystem `Funds` chứa cả hai catalog.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo/kiểm tra catalog Banks (nếu đã làm ở Bài 10, tái sử dụng).
  2. BankAccounts: đặt Owners, thêm attribute Bank bắt buộc.
  3. Tạo subsystem Funds và đưa hai catalog vào.
- **Lỗi hay gặp:**
  - Đặt Banks làm owner (thay vì attribute) → không còn chỗ cho owner Companies/Counterparties như đề yêu cầu.
  - Quên Required field cho Bank.
- **Tự kiểm tra:** Mở item form của một company/counterparty → có link tới danh sách bank accounts của nó; không lưu được account chưa có bank.

### Bài tập 5 — Attribute "Bank account" với giới hạn lựa chọn
- **Đề bài (tóm tắt):** Thêm attribute bắt buộc BankAccount vào PurchaseInvoice, SalesInvoice, ReturnOfGoodsFromCustomer; PurchaseInvoice chỉ chọn account của counterparty (Vendor) trong document; SalesInvoice và return chỉ chọn account của Company.
- **Gợi ý 1 — Hướng đi:** Lọc danh sách chọn theo giá trị field khác bằng **choice parameter links** của attribute: `Filter.Owner` lấy từ attribute tương ứng của document — không cần code.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Attribute `BankAccount` (`CatalogRef.BankAccounts`, Required field); properties palette → **Choice parameter links** → thêm link tên `Filter.Owner`, data path tới attribute `Vendor` (PurchaseInvoice) hoặc `Company` (SalesInvoice, return).
- **Gợi ý 3 — Khung bài làm:**
  1. Thêm attribute vào 3 documents, đặt lên form.
  2. Ở từng document, đặt Choice parameter links như trên.
  3. Cân nhắc chế độ thay đổi giá trị (Clear) khi Vendor/Company đổi.
  4. Bổ sung BankAccount vào Filling của return.
- **Lỗi hay gặp:**
  - Link nhầm sang Customer ở SalesInvoice (đề yêu cầu account của **Company**). Lưu ý: attribute Contract của SalesInvoice có link `Filter.Owner` theo Customer (đúng), còn BankAccount phải theo Company — đừng nhầm hai link.
  - Đặt choice parameters (giá trị cố định) thay vì choice parameter links (theo field).
- **Tự kiểm tra:** Đổi Company trên sales invoice → danh sách Bank account chỉ còn account của company đó.

### Bài tập 6 — Kiểm tra đủ hàng trong kho khi post SalesInvoice và InventoryTransfer
- **Đề bài (tóm tắt):** Kiểm tra trong handler **Posting**: không đặt `Write = True` cho GoodsInWarehouses, mà thêm records, gọi `Write()`, rồi query tìm số dư âm; với mỗi product thiếu báo "Not enough %1 units of product %2 in the warehouse %3" và hủy posting. InventoryTransfer kiểm tra theo WarehouseSender.
- **Gợi ý 1 — Hướng đi:** Sau khi `Write()`, movements của chính document đã nằm trong database (trong transaction posting) → đọc virtual table **Balance** tại **PointInTime** của document **bao gồm** chính thời điểm đó (**Boundary** Including, mục Date, PointInTime, Boundary của Bài 11) và lọc số dư `< 0`. Dùng `Cancel = True` (không `Raise`) để báo **mọi** product thiếu (mục Transactions — Cancel vs Raise).
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Object module, trong `Posting`: bỏ `Write = True` của GoodsInWarehouses; sau vòng lặp gọi `RegisterRecords.GoodsInWarehouses.Write()`; rồi gọi procedure kiểm tra (có thể tách riêng, nhận `Cancel`).
  - Query: `AccumulationRegister.GoodsInWarehouses.Balance(&Period, Product IN (&Products) AND Warehouse = &Warehouse)`; `&Period` = `New Boundary(PointInTime(), BoundaryType.Including)`; `&Products` = mảng product từ tabular section (`UnloadColumn`).
  - Thông báo: `StrTemplate(...)` với số thiếu = giá trị âm đổi dấu.
- **Gợi ý 3 — Khung bài làm:**
```bsl
Procedure ___(Cancel)
	// Query: SELECT Product, QuantityBalance FROM ...Balance(&Period, ___) WHERE ___ < 0
	// Period = New Boundary(___, BoundaryType.___)
	// Products = ___ ; Warehouse = ___
	// While Selection.Next(): Message(StrTemplate("Not enough %1 ...", ___)); Cancel = ___
EndProcedure
```
- **Lỗi hay gặp:**
  - Giữ `Write = True` và không gọi `Write()` → khi query chạy, movements của document chưa có, kiểm tra luôn "đủ".
  - Dùng Period kiểu Date hoặc PointInTime không có Boundary → không thấy movements của chính document.
  - Kiểm tra trong FillCheckProcessing → không đọc được movements của document (object chưa ghi).
  - Dùng `Raise` → chỉ báo product đầu tiên.
  - Sales invoice: kiểm tra theo `Warehouse`; Inventory transfer: theo `WarehouseSender` (không phải kho nhận).
- **Tự kiểm tra:** Kho có 5 cái, tạo sales invoice bán 7 → không post được, thông báo "Not enough 2 units ..."; bán 5 → post được. Re-post một document cũ đã post cũng phải kiểm tra đúng (số lượng cũ của chính nó không bị tính hai lần).

### Bài tập 7 — Attribute State của SalesInvoice (Planned, InDelivery, Completed)
- **Đề bài (tóm tắt):** Attribute State với 3 giá trị cố định, user không thêm được giá trị; mặc định Planned; ở state Planned không ghi movement hàng hóa.
- **Gợi ý 1 — Hướng đi:** Tập giá trị cố định do developer định nghĩa → **Enumeration**; giá trị mặc định → property **Fill value** của attribute; điều kiện trong Posting.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Enumeration `SalesInvoiceStates` (Planned, InDelivery, Completed); attribute `State` kiểu `EnumRef.SalesInvoiceStates`, Fill value = Planned; trong `Posting` so sánh `State` với `Enums.SalesInvoiceStates.Planned` ở đầu procedure.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo enumeration và attribute, đặt Fill value, kéo field lên form.
  2. Trong Posting: nếu State là Planned thì không ghi movements (thoát sớm hoặc bọc phần ghi trong điều kiện).
- **Lỗi hay gặp:**
  - Dùng catalog cho State → user tự thêm được giá trị (trái đề).
  - Chỉ bỏ movements GoodsInWarehouses nhưng vẫn ghi Sales — đề nói "movement of goods"; quyết định rõ và nhất quán. [ghi chú ngoài nguồn] Lời giải tham khảo của khóa bỏ qua toàn bộ movements khi Planned.
- **Tự kiểm tra:** Document mới có State = Planned; post → không có records trong GoodsInWarehouses; đổi sang InDelivery và post lại → có records.

### Bài tập 8 — Lịch sử state của SalesInvoice
- **Đề bài (tóm tắt):** Object lưu lịch sử: ngày đặt state, Document, State. Chỉ thêm record khi state **thay đổi** so với giá trị trong database (document mới: ghi state lúc ghi lần đầu); phân tích trước khi ghi object; ghi lịch sử cùng lúc với document — lỗi thì document không được ghi và có record lỗi trong event log.
- **Gợi ý 1 — Hướng đi:**
  - Lưu lịch sử theo thời gian → **periodic information register**, **independent** (ghi khi chỉ "Write", không cần post).
  - Lấy giá trị cũ **trước khi ghi** trong **BeforeWrite** (đọc qua `Ref`), truyền sang **OnWrite** bằng **AdditionalProperties** (mục AdditionalProperties của Bài 11).
  - Ghi trong **OnWrite** của object (chạy trong transaction ghi document, mục Transactions) bằng **RecordManager**; bọc trong `Try - Except` + **WriteLogEvent** + hủy ghi.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Information register `SalesInvoiceStates`: Periodicity đủ nhỏ để đổi nhiều lần trong ngày (ví dụ Second), Write mode Independent; dimension `SalesInvoice` (`DocumentRef.SalesInvoice`, có thể bật Master), resource `State`.
  - Object module SalesInvoice: `BeforeWrite(Cancel, WriteMode, PostingMode)` và `OnWrite(Cancel)`.
  - `InformationRegisters.SalesInvoiceStates.CreateRecordManager()`, `Write(True)`; `CurrentSessionDate()` cho ngày.
  - Trong Except: `WriteLogEvent(<"Nhóm.Sự kiện">, EventLogLevel.Error, ..., DetailErrorDescription(ErrorInfo()), EventLogEntryTransactionMode.Transactional)` rồi `Cancel = True` (hoặc Raise).
- **Gợi ý 3 — Khung bài làm:**
```bsl
Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	// lưu state cũ trong database vào AdditionalProperties: ___
EndProcedure

Procedure OnWrite(Cancel)
	// If state hiện tại <> state cũ Then
	//   Try: tạo RecordManager, gán Period, SalesInvoice, State = ___; Write(___)
	//   Except: WriteLogEvent(___); Cancel = ___
	// EndIf
EndProcedure
```
- **Lỗi hay gặp:**
  - So sánh trong OnWrite bằng `Ref.State` → lúc này database đã có giá trị mới, luôn "không đổi".
  - Ghi ở form `AfterWriteAtServer` → ngoài transaction, lỗi không hủy được việc ghi document; và không chạy khi ghi từ code.
  - Periodicity Day → đổi state hai lần trong ngày bị ghi đè/lỗi trùng.
  - Khối Except rỗng; [ghi chú ngoài nguồn] lời giải tham khảo của khóa thiếu phần `Try - Except` + `WriteLogEvent` mà đề yêu cầu — bạn cần tự thêm.
  - Document mới: `Ref` rỗng nên state cũ là giá trị rỗng → lần ghi đầu luôn tạo record (đúng đề).
- **Tự kiểm tra:** Tạo document, đổi state Planned → InDelivery trước khi ghi, ghi → register có 1 record InDelivery; đổi lại Planned, ghi → thêm record; ghi lại không đổi state → không thêm. Để thử nhánh lỗi, tạm gây exception trong Try và xem Event log (Designer: Administration - Event log).

### Bài tập 9 — Giá theo ngày: document PriceSetup và register ProductPrices
- **Đề bài (tóm tắt):** Lưu giá theo ngày bắt đầu hiệu lực, mỗi product đổi giá tối đa một lần/ngày; giá được đặt (lẻ hoặc hàng loạt) bằng document PriceSetup, ngày document là ngày hiệu lực; register ProductPrices; đưa vào Sales.
- **Gợi ý 1 — Hướng đi:** Giá theo thời gian → **periodic information register** với Periodicity **Day**; giá chỉ được đổi qua document để có dấu vết → Write mode **subordinate to recorder** (mục Write mode); document ghi register trong **Posting** giống accumulation register.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Register `ProductPrices`: dimension `Product`, resource `Price`, Periodicity Day, Write mode Subordinate to recorder. Document `PriceSetup`: tabular section `Products` (Product, Price); tab Posting → `ProductPrices`; object module `Posting` với `RegisterRecords.ProductPrices`, `Period = Date`.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo register và document, đưa vào subsystem Sales.
  2. Chọn register trong tab Posting của PriceSetup (Record wizard sinh được khung).
  3. Posting: mỗi dòng một record (Period, Product, Price).
- **Lỗi hay gặp:**
  - Để register Independent → user sửa giá trực tiếp, không dấu vết (trái tinh thần đề).
  - Hai dòng cùng product trong một PriceSetup → trùng dimensions + Period → lỗi khi post.
- **Tự kiểm tra:** Post PriceSetup ngày 01 giá 100 và ngày 10 giá 120 → list của register có 2 records với recorder là các document.

### Bài tập 10 — SalesInvoice tự điền giá theo register, khóa Price/Amount
- **Đề bài (tóm tắt):** Khi chọn/đổi product → tự điền giá từ register (nếu có); giữ các xử lý liên quan khi đổi giá, trừ kiểm tra giá tối thiểu (tắt lời gọi, không xóa code); không cho sửa Price và Amount; thiếu giá thì không post được.
- **Gợi ý 1 — Hướng đi:** Giá có hiệu lực tại ngày document = record mới nhất tại ngày đó → virtual table **SliceLast** (hoặc method `GetLast`) của periodic register (mục Đọc dữ liệu information register). Dữ liệu register chỉ đọc trên server → client gọi một function server.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Form module SalesInvoice: handler OnChange của cột Product (cả Products và Services) và ChoiceProcessing (khi Pick) cùng gọi một procedure client "khi đổi product".
  - Function `&AtServerNoContext` (hoặc export function trong manager module của register) nhận Product và Date, trả giá: query `InformationRegister.ProductPrices.SliceLast(&Period, Product = &Product)`, không có dòng → 0.
  - Sau khi gán giá: gọi lại tính Amount dòng; lời gọi kiểm tra giá tối thiểu thì comment lại.
  - Cột Price, Amount: ReadOnly trên form; Price trong tabular section đặt **Required field** để thiếu giá thì posting báo field rỗng.
- **Gợi ý 3 — Khung bài làm:**
```bsl
&AtClient
Procedure ___(CurrentData)
	// CurrentData.Price = ___(CurrentData.Product, Object.Date)
	// // ControlMinimumSalesPrice(___);  <- tắt lời gọi, giữ procedure
	// tính lại Amount của dòng: ___
EndProcedure

&AtServerNoContext
Function ___(Product, Date)
	// query SliceLast(&Period, Product = &Product); không có dòng -> Return ___
EndFunction
```
- **Lỗi hay gặp:**
  - Đọc register trực tiếp trong procedure `&AtClient` → lỗi (register không truy cập được trên client).
  - Chỉ xử lý OnChange, quên dòng thêm bằng Pick (ChoiceProcessing).
  - Không đặt Required field cho Price → document có giá 0 vẫn post được.
  - Đổi Date của document không tự cập nhật giá các dòng đã có — đề không bắt buộc, nhưng nên biết.
- **Tự kiểm tra:** Đặt giá 100 từ ngày 01, 120 từ ngày 10 → sales invoice ngày 05 nhận 100, ngày 12 nhận 120; product không có giá → Price = 0 và post báo lỗi field rỗng; không gõ được vào Price/Amount.

## Code demo của bài Theory (repo 1CJDCourse, nhánh lesson/12-theory)

So với nhánh lesson/11-theory, nhánh lesson/12-theory thêm: FillCheckProcessing của SalesInvoice, ẩn/hiện group Weight/Promotional trên item form của Products, catalog Companies và independent information register `CompaniesResponsiblePersons` (periodicity `Day`, Write mode `Independent`, dimension `Company` có flag `Master` = true).

### FillCheckProcessing của Sales invoice: Products/Services, Find() và query qua temporary table
Nguồn: nhánh lesson/12-theory — cf/Documents/SalesInvoice/Ext/ObjectModule.bsl
```bsl
Procedure FillCheckProcessing(Cancel, CheckedAttributes)

	If Products.Count() > 0 Then
		DeleteAttributeFromChecking(CheckedAttributes, "Services");
	ElsIf Services.Count() > 0 Then	
		DeleteAttributeFromChecking(CheckedAttributes, "Products");
	EndIf;

	// Turn off checking by the platform
	DeleteAttributeFromChecking(CheckedAttributes, "Products.Amount");
	
	Query = New Query;
	Query.Text = 
	"SELECT
	|	Products.LineNumber AS LineNumber,
	|	Products.Product AS Product,
	|	Products.Amount AS Amount
	|INTO TempTableProducts
	|FROM
	|	&Products AS Products
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	TempTableProducts.LineNumber AS LineNumber,
	|	TempTableProducts.Product AS Product,
	|	TempTableProducts.Amount AS Amount
	|FROM
	|	TempTableProducts AS TempTableProducts
	|		INNER JOIN Catalog.Products AS Products
	|		ON TempTableProducts.Product = Products.Ref
	|WHERE
	|	NOT Products.Promotional
	|	AND TempTableProducts.Amount = 0";
	
	Query.SetParameter("Products", Products);
	
	// Execute query and select data from the query result
	Selection = Query.Execute().Select();
	While Selection.Next() Do
		
		MessageText = StrTemplate(
			"The ""Amount"" is required on line %1 of the ""Products"" list.",
			Selection.LineNumber
		);
		Message(MessageText);
		Cancel = True;
		
	EndDo;
	
EndProcedure

Procedure DeleteAttributeFromChecking(CheckedAttributes, AttributeToDelete)

	IndexOfAttribute = CheckedAttributes.Find(AttributeToDelete);
	If IndexOfAttribute <> Undefined Then
	
		CheckedAttributes.Delete(IndexOfAttribute);
	
	EndIf;

EndProcedure
```
- Đúng ví dụ trong lý thuyết: cả Products và Services đều "Required field"; tabular section nào có dòng thì tabular section kia bị loại khỏi `CheckedAttributes`.
- Việc tìm index bằng `Find()` rồi `Delete()` được tách thành procedure riêng `DeleteAttributeFromChecking` vì dùng lặp lại.
- `"Products.Amount"` bị loại khỏi kiểm tra của nền tảng, thay bằng query riêng: vì FillCheckProcessing chạy TRƯỚC khi ghi, tabular section được truyền vào parameter `&Products`, chọn INTO `TempTableProducts`, rồi join với `Catalog.Products` để bỏ qua sản phẩm `Promotional`.
- Dùng `Cancel = True` (không `Raise`) trong vòng lặp → user nhận thông báo cho **tất cả** các dòng thiếu Amount.

### Ẩn group Weight/Promotional khi product là Service (OnOpen + OnChange)
Nguồn: nhánh lesson/12-theory — cf/Catalogs/Products/Forms/ItemForm/Ext/Form/Module.bsl
```bsl
&AtClient
Procedure OnOpen(Cancel)
	ChangeVisibilityOfWeightPromotional();
EndProcedure

&AtClient
Procedure TypeOnChange(Item)
	ChangeVisibilityOfWeightPromotional();
EndProcedure

&AtClient
Procedure ChangeVisibilityOfWeightPromotional()

	If Object.Type = PredefinedValue("Enum.ProductTypes.Service") Then
		Items.GroupWeightPromotional.Visible = False;
	Else
		Items.GroupWeightPromotional.Visible = True;
	EndIf;	

EndProcedure
```
- Một procedure client `ChangeVisibilityOfWeightPromotional()` được gọi từ cả event form `OnOpen` (khi mở form visibility là mặc định) và `TypeOnChange` của field Type.
- So sánh với giá trị enumeration trên client phải dùng `PredefinedValue("Enum.ProductTypes.Service")`.
- Ẩn cả group `GroupWeightPromotional` thay vì từng field.

### Đọc người chịu trách nhiệm bằng GetLast và FillPropertyValues trong OnCreateAtServer
Nguồn: nhánh lesson/12-theory — cf/Catalogs/Companies/Forms/ItemForm/Ext/Form/Module.bsl
```bsl
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	ResponsiblePersons = ResponsiblePersons(CurrentSessionDate(), Object.Ref);
	
	FillPropertyValues(ThisObject, ResponsiblePersons);
	
EndProcedure
// ...
&AtServerNoContext
Function ResponsiblePersons(Period, Company)

	Filter = New Structure("Company", Company);
	
	Return InformationRegisters.CompaniesResponsiblePersons.GetLast(
		Period,
		Filter
	);
	
EndFunction
```
- `GetLast(<EndOfPeriod>, <Filter>)` trả về structure có các properties trùng resources (CEO, ChiefAccountant, CTO); nếu chưa có record → giá trị default.
- Filter là `Structure` với key là tên dimension (`Company`).
- `FillPropertyValues(ThisObject, ResponsiblePersons)` điền các form attributes cùng tên — đúng ví dụ "GetLast trong OnCreateAtServer" của lý thuyết.
- Function đặt `&AtServerNoContext` vì chỉ cần tham số, không cần dữ liệu form; dữ liệu register chỉ đọc được trên server.

### Ghi bằng RecordManager trong OnWriteAtServer, bắt lỗi bằng BriefErrorDescription
Nguồn: nhánh lesson/12-theory — cf/Catalogs/Companies/Forms/ItemForm/Ext/Form/Module.bsl
```bsl
&AtServer
Procedure OnWriteAtServer(Cancel, CurrentObject, WriteParameters)
	
	Try
	
		UpdateResponsiblePersons(CurrentObject.Ref);
	
	Except
		
		Cancel = True;
		ErrorText = StrTemplate(
			"Failed to update responsible persons with the error: %1",
			ErrorProcessing.BriefErrorDescription(ErrorInfo())
		);
		Message(ErrorText);

	EndTry;
	
EndProcedure

&AtServer
Procedure UpdateResponsiblePersons(Company)

	Period = CurrentSessionDate();
	
	ResponsiblePersons = ResponsiblePersons(Period, Company);
	
	If ResponsiblePersons.CEO <> CEO
		Or ResponsiblePersons.ChiefAccountant <> ChiefAccountant
		Or ResponsiblePersons.CTO <> CTO Then
				
		RecordManager = InformationRegisters.CompaniesResponsiblePersons.CreateRecordManager();
		
		RecordManager.Company = Company;
		RecordManager.Period = Period;
		
		RecordManager.CEO = CEO;
		RecordManager.ChiefAccountant = ChiefAccountant;
		RecordManager.CTO = CTO;
		
		RecordManager.Write(True);
		
	EndIf;

EndProcedure
```
- Thuật toán nằm ở `OnWriteAtServer` (trong transaction ghi object) chứ không ở `AfterWriteAtServer` → lỗi ghi register thì `Cancel = True` hủy luôn việc ghi company.
- Chỉ thêm record khi ít nhất một resource khác với bản ghi cuối (so sánh qua `ResponsiblePersons(...)`).
- `CreateRecordManager()` dùng được vì register là independent; `Write(True)` (Replace = True) ghi đè record cùng Company + Period nếu đổi người chịu trách nhiệm nhiều lần trong ngày.
- `ErrorProcessing.BriefErrorDescription(ErrorInfo())` cho mô tả ngắn để hiện cho user; khi cần ghi Event log thì dùng `DetailErrorDescription` như ví dụ Explicit transaction ở mục "Cú pháp & ví dụ code".

## Video tham khảo

Video bài giảng trên YouTube có phạm vi trùng với bài này. Khi dẫn cho người học, nói "Bạn có thể tham khảo thêm về <chủ đề> của khóa tại đây: [<tên video>](link)" — không nói "khóa cũ/Junior", không dùng mã JC (mã JC trong danh sách chỉ để tra nội bộ). Quy ước đầy đủ: `references/video.md#video-junior-course`.

- [Thẩm định dữ liệu](https://www.youtube.com/watch?v=DVdxgqJrd14&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=12) (14:16) — Bài 12 — Data validation, FillCheckProcessing, CheckFilling() _(mã nội bộ JC-13)_
- [Đối tượng và tập hợp bản ghi](https://www.youtube.com/watch?v=L4OkNedrIeQ&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=16) (5:26) — Bài 15 — object vs non-object entities; Bài 12 — RecordSet / RecordManager _(mã nội bộ JC-17)_
- [Biểu ghi thông tin](https://www.youtube.com/watch?v=2opmwhrnU2A&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=23) (7:54) — Bài 12 — Information register, periodic, SliceLast/SliceFirst, RecordSet/RecordManager _(mã nội bộ JC-24)_

<!-- video-qa-thuchanh:start -->

Video giải đáp tình huống thực chiến và video thực hành từng bước liên quan tới bài này (thẻ chi tiết, triệu chứng, lưu ý khi giới thiệu: `references/video.md#video-qa-thuc-chien`, `references/video.md#video-thuc-hanh`; cùng mẫu câu dẫn ở trên):

- [Lấy giá tự động](https://www.youtube.com/watch?v=oMowT1e019k&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=5) (8:32) — tự điền giá theo bảng giá (giải đáp tình huống; Bài 12 chính) _(mã nội bộ QA-5)_
- [Ghi nhận thay đổi tỷ giá hối đoái](https://www.youtube.com/watch?v=9_m7XqHPZlA&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=1) (9:04) — information register theo ngày và biểu đồ (thực hành case study; Bài 12 chính) _(mã nội bộ P2-1)_
- [Ghi nhận thay đổi giá mua tiền tệ](https://www.youtube.com/watch?v=lYPmr3Rxi3g&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=2) (8:11) — information register nhiều dimension (thực hành case study; Bài 12 chính) _(mã nội bộ P2-2)_
- [Hạch toán thu nhập theo doanh số](https://www.youtube.com/watch?v=QRAzQKBCtds&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=8) (20:00) — quy đổi tỷ giá khi posting bằng SliceLast (thực hành case study; Bài 12 chính) _(mã nội bộ P2-8)_
- [Kiểm tra dữ liệu trùng lặp](https://www.youtube.com/watch?v=603j21ItABk&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=11) (8:55) — cảnh báo dữ liệu trùng (giải đáp tình huống; Bài 12 liên quan) _(mã nội bộ QA-11)_
- [Kết nhập file excel vào danh mục sản phẩm](https://www.youtube.com/watch?v=DlXBXRzBJGw&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=13) (38:42) — nhập dữ liệu từ Excel (giải đáp tình huống; Bài 12 liên quan) _(mã nội bộ QA-13)_
- [Hủy sự kiện đang thực thi](https://www.youtube.com/watch?v=rW40s85Gtc4&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=16) (3:18) — chặn ghi bằng Cancel = True (giải đáp tình huống; Bài 12 liên quan) _(mã nội bộ QA-16)_
- [Chặn kết chuyển khi phát hiện tồn kho âm](https://www.youtube.com/watch?v=k2uht5J1f3c&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=25) (10:03) — kiểm soát âm kho khi posting (giải đáp tình huống; Bài 12 liên quan) _(mã nội bộ QA-25)_
- [Lưu trữ thông tin nhân viên](https://www.youtube.com/watch?v=WF19J3tct0I&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=5) (9:37) — catalog cấp dưới và lịch sử lương theo tháng (thực hành case study; Bài 12 liên quan) _(mã nội bộ P1-4)_
- [Hạch toán hàng hóa - Hạch toán một kho](https://www.youtube.com/watch?v=BD370AtszHI&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=11) (20:57) — tồn kho theo từng kho (kho trên đầu chứng từ) (thực hành case study; Bài 12 liên quan) _(mã nội bộ P2-11)_
- [Hạch toán hàng hóa nhiều kho (Full)](https://www.youtube.com/watch?v=HIAYMOepPw4&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=12) (18:40) — kho trên từng dòng hàng và chặn âm theo từng kho (thực hành case study; Bài 12 liên quan) _(mã nội bộ P2-12)_

<!-- video-qa-thuchanh:end -->


---

# § bai-13

# Bài 13 — Constants, Document journals, Charts of characteristic types

## Khái niệm chính

### Constants
- **Constants** dùng để lưu thông tin ít hoặc không bao giờ thay đổi. Ví dụ: "pickup warehouse" — khi delivery method là "pickup", tự điền kho bán hàng bằng giá trị mặc định; khi cần đổi (ví dụ đổi kho thuê sang kho mua), chỉ cần đổi giá trị constant.
- Nền tảng tự sinh form để làm việc với giá trị constant.
- Developer có thể tạo common form (nhánh **Common** → **Common forms**) loại **"Constants form"** để làm việc với một nhóm constants — gom constants theo mục đích (ví dụ "Default company" và "Default bank account" trên common form "Default values", thêm vào subsystem Sales).
- Property **"Include in the command interface"**: cho phép user làm việc với giá trị constant từ giao diện mà không cần common form. Khi đã có Constants form chung, có thể tắt property này để bỏ form riêng của từng constant khỏi giao diện.
- Property **"Default form"**: form được dùng thay cho form tự sinh khi mở constant để sửa.
- Từ code: **Set()** (procedure) để đặt giá trị, **Get()** (function) của constant manager để lấy giá trị.
- Ví dụ: tự điền company và bank account cho Sales invoice trong handler **Filling** của document object module.
- **Note**: không khuyến khích dùng constants cho giá trị thay đổi liên tục: temporary resource access tokens; giá trị số tính toán được tính lại định kỳ; các giá trị biết trước sẽ thay đổi theo chu kỳ.

### Document journals
- **Document journals** chủ yếu để nhóm trực quan các document khác loại khi xem. Có thể tạo nhiều metadata object "Document journal" trong configuration.
- Metadata của journal chỉ định loại document nào được đưa vào. Mỗi document có thể thuộc một hoặc nhiều journal, hoặc không thuộc journal nào.
- Có thể mô tả nhiều cột (columns) cho journal. Journal column = danh sách details của các document khác loại, có giá trị hiển thị trong cùng một cột (ví dụ journal "Purchases and Sales" gồm "Purchase invoice" và "Sales invoice": gộp attribute Vendor và Customer thành cột "Counterparty").
- **Note**: không thể chọn nhiều attributes của cùng một document vào một journal column.
- Journal có các cột mặc định: date, number, document type; có thể thêm số cột bổ sung bất kỳ.
- Nếu không chọn detail của một document cho cột → cột đó trống với mọi document loại đó. Không trộn các khái niệm hoàn toàn khác nhau vào một cột (ví dụ counterparty và tổng tiền).
- Nếu journal có hơn 1 loại document, nút tạo document mới thành submenu chọn loại document.
- Với mỗi journal, hệ thống tạo bảng trong database lưu link tới documents thuộc journal, và nhân bản nội dung các details đưa vào cột, số document, dấu posting... Khi document được ghi, hệ thống ghi/cập nhật records trong các bảng journal mà document thuộc về.

### Charts of characteristic types
- Dùng khi cần lưu thuộc tính của applied objects mà thành phần và kiểu chưa biết trước lúc phát triển (ví dụ product: màu, size, kích thước, vật liệu đóng gói; counterparty: "foreign company", "settlement in foreign currency"; warehouse: "requires an order for a pass to the territory").
- Characteristics có thể khác nhau theo nhóm object; user có thể tự nhập characteristics khi vận hành.
- 2 cách:
  1. Tạo attribute riêng cho mỗi characteristic → nhược điểm: mỗi characteristic là một trường trong bảng database, chiếm chỗ dù không dùng; nhiều characteristic → nhiều trường "thừa", bất tiện cho cả developer và user; thêm characteristic mới phải sửa ứng dụng.
  2. Dùng object đặc biệt mô tả tên, kiểu characteristic... → không có các nhược điểm trên; thêm characteristic không cần sửa ứng dụng, không tốn chỗ thừa, user tự thêm được. Đối tượng này là **chart of characteristic types**. Nhược điểm: logic tổ chức và sử dụng phức tạp hơn, nhưng chi phí chỉ phát sinh một lần lúc phát triển.
- Property **"Characteristic value type"**: định nghĩa composite data type gồm mọi kiểu có thể cần khi chỉ định kiểu giá trị characteristic.
- Ngoài primitive types, thường cần reference tới objects trong database (ví dụ "Main supplier" là link tới counterparty). Để giữ toàn vẹn dữ liệu (tránh "red", "Red", "Redd" khi nhập màu dạng string) và giới hạn lựa chọn (ví dụ chỉ các size thực có của mẫu giày) → lưu additional characteristic values trong object riêng: tạo catalog subordinate tới chart of characteristic types và chỉ định nó trong property **"Additional characteristic values"**.
  - **Note**: để chọn catalog làm giá trị "Additional characteristic values", catalog đó cũng phải được chọn trong "Characteristic value type".
- Lưu giá trị characteristic gắn với owner (product, counterparty...) → dùng **information register**. Ví dụ register "ObjectsCharacteristicValues":
  - Dimensions: "Object" (owner — liệt kê mọi object muốn gắn vào cơ chế), "Characteristic type" (link tới chart of characteristic types).
  - Resource: "Characteristic value".
  - Bật flags **"Master"** và **"No empty values"** cho cả hai dimensions.
  - Kiểu của resource "Characteristic value": sau khi thêm chart of characteristic types, danh sách kiểu có nhóm **"Characteristic"** — chọn characteristics của chart vừa tạo.
  - **Note**: không thể chỉ định cho resource này composite type gồm nhiều Characteristic types → giá trị của một chart of characteristic types lưu trong một register (chart thứ hai → register thứ hai...).
- Property **"Select type automatically"** của resource CharacteristicValue: đặt giá trị "Characteristic type" để kiểu của field phụ thuộc vào field khác (dimension CharacteristicType). Khi đó không còn nút chọn kiểu (ba chấm), mà là nút chọn từ danh sách và nút mở.
- Lọc additional values theo characteristic type đã chọn: đặt tham số chọn giá trị (choice parameters) cho resource của information register.
- Phân loại characteristic types theo object sở hữu:
  - Tạo enumeration **CharacteristicsObjectTypes** (Companies, Counterparties, Employees, Products, Warehouses; gán synonym chi tiết hơn).
  - Thêm attribute **CharacteristicsObjectType** (kiểu enumeration trên) vào chart of characteristic types, bắt buộc điền.
  - Sửa record form của register "Objects characteristic values":
    - Ẩn field Object nếu đã được điền (form mở từ một object cụ thể hoặc tạo bằng copy) — trong handler **OnCreateAtServer**; nếu chưa điền thì hiển thị để user điền.
    - Đặt choice parameters cho field "CharacteristicType" theo CharacteristicsObjectType: nếu Object khác Undefined → lọc theo loại object; nếu không → choice parameters rỗng (không lọc).
    - Gọi lại procedure này trong event **OnChange** của field Object: nếu loại object thay đổi (so với biến **PreviousObjectType**) → xóa CharacteristicType và CharacteristicValue, cập nhật choice parameters, rồi cập nhật biến.
- Cửa sổ **Additional metadata object characteristics** (mở từ context menu của metadata object — dòng Characteristics — hoặc nút **Characteristics** trên tab data của object editor): **phải làm cho mỗi object có characteristics**, chỉ định:
  - Object chứa danh sách characteristics (field **Characteristic types**, ví dụ chart AdditionalAttributesAndProperties).
  - Key field để lấy characteristic cụ thể, xác định kiểu giá trị và presentation (property **Key Field** — ví dụ standard attribute Ref).
  - Attribute characteristic nào (với giá trị filter nào) xác định danh sách characteristics của metadata object.
  - Phần trái: object cung cấp characteristic types; phần phải: nơi lưu giá trị characteristic.
  - Nhờ thiết lập này, user truy cập characteristics như attributes trong mọi report và dynamic list (ví dụ filter theo Color, Size trong list form của Products).
- Các phương án khác dùng chart of characteristic types:
  - Một chart cho một metadata object.
  - Một chart cho một (hoặc nhiều) metadata object, nhưng tính khả dụng của characteristics cấu hình riêng cho elements/groups (ví dụ "Shoe Size" chỉ cho nhóm "Shoes").
  - Một chart cho nhiều metadata objects, nhưng characteristics thuộc object qua entity trung gian (ví dụ catalog CharacteristicSet "aluminum can, 330 ml" dùng cho nhiều product) → lợi thế: ghi sổ theo characteristics (registers lưu nomenclature + set of characteristics); với cách demo (mỗi characteristic là một giá trị riêng) thì phải áp hai selection rồi gộp.

### Dùng characteristics trong query
- Ví dụ: chọn items thuộc nhóm "Clothes and shoes", hiển thị color và size ở cột riêng → join tới bảng register lưu giá trị characteristics **hai lần**; điều kiện join chỉ định characteristic type cụ thể và Object của register = reference của product.
- Trong WHERE: kiểm tra product thuộc hierarchy của group, và loại bỏ groups (folders) khỏi kết quả.

## Cú pháp & ví dụ code

Set / Get constant:
```bsl
// Setting the value
Constants.MainSignatory.Set("John Doe");

// Getting the value
DefaultCompany = Constants.DefaultCompany.Get();
```

Tự điền từ constants trong Filling:
```bsl
Procedure Filling(FillingData, FillingText, StandardProcessing)
    
    Company     = Constants.DefaultCompany.Get();
    BankAccount = Constants.DefaultBankAccount.Get();
    
EndProcedure
```

[ghi chú ngoài nguồn] Code OnCreateAtServer/OnChange của record form register và query hiển thị Color/Size trong tài liệu gốc chỉ có dạng ảnh chụp màn hình, không có văn bản code nên không được chép lại. → code record form: xem mục Code demo của bài Theory (nhánh lesson/13-theory). Riêng query hiển thị Color/Size không có trong nhánh lesson/13-theory nên vẫn chưa có code.

## Thuộc tính/thiết lập quan trọng trong Designer
- Constant: **Include in the command interface**, **Default form**; constant manager **Set()** / **Get()**.
- Common form: loại **Constants form** (Common → Common forms).
- Document journal: danh sách documents đưa vào; **columns** (mỗi cột chọn details của các document khác loại); cột mặc định date, number, document type.
- Chart of characteristic types: **Characteristic value type**, **Additional characteristic values**; attribute **CharacteristicsObjectType** (bắt buộc).
- Information register lưu giá trị: dimensions **Object**, **CharacteristicType**; resource **CharacteristicValue**; flags **Master**, **No empty values**; nhóm kiểu **Characteristic**; resource property **Select type automatically** = "Characteristic type"; choice parameters.
- Cửa sổ **Additional metadata object characteristics**: **Characteristic types**, **Key Field**, phần lưu trữ giá trị.

## Lỗi thường gặp / lưu ý
- Không dùng constants cho giá trị thay đổi liên tục (access tokens, giá trị tính lại định kỳ...).
- Không chọn được nhiều attributes của cùng một document vào một journal column.
- Không trộn khái niệm khác nhau vào một journal column.
- Catalog dùng làm "Additional characteristic values" phải có trong "Characteristic value type".
- Resource CharacteristicValue không nhận composite type gồm nhiều Characteristic types → mỗi chart một register.
- Nếu không đặt "Select type automatically", field giá trị mở form chọn kiểu dù characteristic type chỉ có một kiểu.
- Nếu không đặt choice parameters, danh sách hiển thị mọi additional values (ví dụ "48-50" của Size khi chọn Color).
- Không phân loại theo CharacteristicsObjectType → user có thể chỉ định màu cho counterparty.
- Thiết lập Additional metadata object characteristics phải làm cho **từng** object có characteristics.

## Điểm cần nhớ
- Constants: dữ liệu ít thay đổi; `Constants.<Name>.Set()` / `.Get()`; gom nhiều constants vào common form loại Constants form.
- Document journal: nhóm document khác loại để xem; columns gộp details khác tên; có bảng riêng trong database được cập nhật khi ghi document.
- Chart of characteristic types: lưu characteristics chưa biết trước; Characteristic value type (composite) + Additional characteristic values (catalog subordinate).
- Giá trị characteristics lưu trong information register (Object + CharacteristicType → CharacteristicValue), bật Master & No empty values.
- "Select type automatically" + choice parameters để field giá trị đúng kiểu và lọc đúng danh sách.
- Phân loại characteristic types theo owner bằng enumeration CharacteristicsObjectTypes.
- Cấu hình Additional metadata object characteristics cho từng object để dùng characteristics trong report/dynamic list.
- Query lấy nhiều characteristics thành nhiều cột: join register nhiều lần, mỗi lần một characteristic type.

## Thẻ gợi ý bài thực hành (Practice 13)

> Thẻ gợi ý dẫn hướng cho từng yêu cầu của 13. Practice.docx; không có lời giải hoàn chỉnh. Phần lớn bài này là thiết lập metadata trong Designer, rất ít code.

### Bài tập 1 — Constant "Control balances of goods" và form "Goods turnover settings"
- **Đề bài (tóm tắt):** Tạo constant bật/tắt kiểm tra số dư hàng; code kiểm tra số dư (Bài 12) chỉ chạy khi constant = True; tạo form "Goods turnover settings" để sửa constant và đưa vào subsystem Master data.
- **Gợi ý 1 — Hướng đi:** Giá trị cấu hình ít thay đổi → **Constant** (kiểu Boolean); đọc bằng `Get()` (mục Constants). Form gom constants → common form loại **Constants form**.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Constant (ví dụ `ControlBalanceOfGoods`, Boolean).
  - Trong procedure kiểm tra số dư của SalesInvoice và InventoryTransfer (object module, gọi từ Posting): ở đầu procedure đọc `Constants.<Tên>.Get()`, nếu False thì thoát.
  - Common form loại Constants form (main attribute kiểu `ConstantsSet`), kéo constant từ cây attribute lên form; đưa form vào subsystem Master data. Có thể tắt **Include in the command interface** của constant để chỉ sửa qua form chung.
- **Gợi ý 3 — Khung bài làm:**
```bsl
Procedure ___(Cancel)
	If Not Constants.___.Get() Then
		// không kiểm tra -> ___
	EndIf;
	// ... phần query số dư âm của Bài 12 giữ nguyên
EndProcedure
```
- **Lỗi hay gặp:**
  - Đọc constant trên client (form `&AtClient`) → không được; đọc trong object module (server).
  - Chỉ sửa một trong hai document.
  - [ghi chú ngoài nguồn] Constant trong cấu hình của khóa tên `ContolBalanceOfGoods` (thiếu chữ "r"); khi đặt tên của bạn, kiểm tra chính tả trước khi viết code vì đổi tên sau sẽ phải sửa mọi nơi gọi.
- **Tự kiểm tra:** Tắt constant trên form settings → sales invoice bán quá số dư vẫn post được; bật lại → bị chặn như Bài 12.

### Bài tập 2 — Document journal "Sales documents"
- **Đề bài (tóm tắt):** Journal gồm SalesInvoice và ReturnOfGoodsFromCustomer, các cột Company, Customer, Contract, Warehouse, BankAccount, DocumentTotal; đưa vào subsystem Sales, nhóm Important.
- **Gợi ý 1 — Hướng đi:** **Document journal** nhóm document khác loại để xem; mỗi **column** gộp một attribute của từng document (mục Document journals).
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Journal `SalesDocuments`: tab Data → Registered documents chọn 2 documents; Columns: thêm 6 cột, mỗi cột chọn attribute cùng nghĩa của cả hai documents. Command interface của subsystem Sales: kéo command mở journal vào nhóm **Navigation panel.Important**.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo journal, chọn documents.
  2. Thêm từng column, mỗi column chọn 2 attributes (một của mỗi document).
  3. Đưa journal vào subsystem Sales.
  4. Mở Command interface của subsystem Sales, đặt command OpenList của journal vào Important.
- **Lỗi hay gặp:**
  - Chọn hai attributes của cùng một document vào một column (không được phép).
  - Return thiếu attribute tương ứng (ví dụ BankAccount) → column trống với return.
- **Tự kiểm tra:** Section Sales hiển thị journal in đậm; mở journal thấy cả invoice và return, 6 cột có giá trị; nút tạo mới là submenu chọn loại document.

### Bài tập 3 — Chart of characteristic types AdditionalAttributesAndProperties
- **Đề bài (tóm tắt):** Cho phép user thêm attributes/properties bổ sung cho Companies, Counterparties, CounterpartyContracts, Products, Warehouses, SalesInvoice, ReturnOfGoodsFromCustomer; giá trị có thể là primitive types, Counterparties, hoặc giá trị bổ sung trong object riêng; tạo được characteristic và giá trị ngay từ các object đó; mỗi object chỉ thấy characteristics của loại mình.
- **Gợi ý 1 — Hướng đi:** Đây chính là mô hình của lý thuyết: **chart of characteristic types** + catalog subordinate lưu additional values + **information register** lưu giá trị theo (Object, CharacteristicType) + enumeration phân loại theo object owner (mục Charts of characteristic types).
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Chart `AdditionalAttributesAndProperties`: **Characteristic value type** = composite (Boolean, String, Date, Number, `CatalogRef.Counterparties`, catalog additional values); **Additional characteristic values** = catalog subordinate (ví dụ `ObjectsPropertiesValues`, Owners = chart).
  - Enumeration `CharacteristicsObjectTypes` (một giá trị cho mỗi object trong danh sách của đề) + attribute `CharacteristicsObjectType` bắt buộc trong chart.
  - Information register `ObjectsCharacteristicValues`: dimensions `Object` (composite: 5 catalogs + 2 documents) và `CharacteristicType` (ref tới chart), cả hai bật **Master** và **No empty values**; resource `CharacteristicValue` kiểu nhóm **Characteristic** của chart, **Select type automatically** = CharacteristicType, choice parameter link `Filter.Owner` theo CharacteristicType.
  - Record form của register (form module):
    - `OnCreateAtServer` (`&AtServer`): nếu `Record.Object` đã điền → ẩn `Items.Object` và gọi procedure đặt choice parameters.
    - Procedure đặt choice parameters (`&AtServer`): tạo mảng, nếu Object khác Undefined thì thêm một `New ChoiceParameter("Filter.CharacteristicsObjectType", <giá trị enum>)`, gán vào `Items.CharacteristicType.ChoiceParameters` dưới dạng `FixedArray` (mảng rỗng = không lọc).
    - `ObjectOnChange` (`&AtClient`): so loại object mới với biến form `PreviousObjectType` (khai báo `Var` đầu module); nếu khác → xóa CharacteristicType và CharacteristicValue, gọi lại procedure đặt choice parameters, cập nhật biến.
    - Function ánh xạ `TypeOf(Record.Object)` → giá trị enum: xem mẫu ở mục Code demo của bài Theory (bản demo chỉ có catalogs của lý thuyết; bạn thêm nhánh cho các object của đề).
  - Bật Master giúp mở danh sách giá trị từ form của từng object (Go to).
- **Gợi ý 3 — Khung bài làm:**
```bsl
&AtServer
Function CharacteristicsObjectType()
	// TypeOfObject = TypeOf(Record.Object)
	// If TypeOfObject = Type("CatalogRef.___") Then Result = Enums.CharacteristicsObjectTypes.___
	// ElsIf ... (mỗi object của đề, kể cả 2 documents: Type("DocumentRef.___"))
	// Else Raise ___
	// Return Result
EndFunction
```
- **Lỗi hay gặp:**
  - Catalog additional values không có trong Characteristic value type → không chọn được làm "Additional characteristic values".
  - Không đặt Select type automatically → field giá trị luôn hỏi chọn kiểu.
  - Không có choice parameter link → chọn Color mà vẫn thấy giá trị của Size.
  - Hàm ánh xạ loại object chỉ có 5 catalogs → mở record form từ SalesInvoice/return rơi vào nhánh `Raise`. [ghi chú ngoài nguồn] Lời giải tham khảo của khóa cũng chỉ xử lý 5 catalogs — bạn cần bổ sung hai documents (và giá trị enumeration tương ứng).
  - Quên đưa chart, catalog values, register vào subsystem.
- **Tự kiểm tra:** Từ form của một product mở danh sách giá trị characteristics → tạo record: chỉ thấy characteristic types có CharacteristicsObjectType = Products; chọn type kiểu catalog values → chỉ thấy giá trị của type đó; thử tương tự từ một Sales invoice.

### Bài tập 4 — Characteristics như attributes thường; "Primary supplier" và filter trên list form Products
- **Đề bài (tóm tắt):** Thiết lập characteristics cho mọi object để dùng như attributes thường; với Products thêm additional attribute "Primary supplier" kiểu CatalogRef.Counterparties và hiển thị filter theo nó trên list form.
- **Gợi ý 1 — Hướng đi:** Cửa sổ **Additional metadata object characteristics** (mục cuối phần Charts of characteristic types) — phải làm cho **từng** object; sau đó characteristic xuất hiện như field trong dynamic list và report.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Mỗi object (5 catalogs + 2 documents): nút **Characteristics** → nguồn characteristic types = chart, **Key Field** = Ref, filter field = `CharacteristicsObjectType`, filter value = giá trị enumeration của object đó; nguồn giá trị = register `ObjectsCharacteristicValues` (Object / CharacteristicType / CharacteristicValue).
  - "Primary supplier": là **dữ liệu** — tạo ở Enterprise mode một characteristic type mới (loại Products, kiểu Counterparties), không phải attribute trong Designer.
  - List form Products: tạo list form (nếu chưa có), thêm field của characteristic vào khu vực filter/quick settings của dynamic list (hoặc user tự thêm qua Settings), hoặc thêm field filter trên form.
- **Gợi ý 3 — Khung bài làm:**
  1. Lặp thiết lập Characteristics cho từng object, đổi filter value tương ứng.
  2. Cập nhật database, vào Enterprise mode tạo characteristic "Primary supplier".
  3. Gán Primary supplier cho vài products.
  4. Mở list form Products → thêm filter theo Primary supplier.
- **Lỗi hay gặp:**
  - Chỉ thiết lập cho Products → các object khác không dùng được characteristics như attributes.
  - Sai filter value (copy từ object khác) → object thấy characteristics của loại khác.
  - Tạo "Primary supplier" thành attribute metadata của Products → đi ngược mục đích của chart.
- **Tự kiểm tra:** Trên list form Products lọc theo một supplier → chỉ còn products có Primary supplier đó; thêm cột Primary supplier vào danh sách qua More → Change form/Settings.

## Code demo của bài Theory (repo 1CJDCourse, nhánh lesson/13-theory)

So với nhánh lesson/12-theory, nhánh lesson/13-theory thêm: constants `DefaultCompany`, `DefaultBankAccount` và common form `DefaultValues`, handler `Filling` của SalesInvoice (đã có nguyên văn ở mục "Cú pháp & ví dụ code"), document journal `PurchasesAndSales`, chart of characteristic types `AdditionalAttributesAndProperties` và information register `ObjectsCharacteristicValues` với record form. Dưới đây là các phần chính của nhánh.

### Constants form "Default values": hai constants trên một common form
Nguồn: nhánh lesson/13-theory — cf/CommonForms/DefaultValues/Ext/Form.xml
```xml
	<ChildItems>
		<InputField name="DefaultCompany" id="1">
			<DataPath>ConstantsSet.DefaultCompany</DataPath>
			<EditMode>EnterOnInput</EditMode>
			<ContextMenu name="DefaultCompanyContextMenu" id="2"/>
			<ExtendedTooltip name="DefaultCompanyExtendedTooltip" id="3"/>
		</InputField>
		<InputField name="DefaultBankAccount" id="4">
			<DataPath>ConstantsSet.DefaultBankAccount</DataPath>
			<ContextMenu name="DefaultBankAccountContextMenu" id="5"/>
			<ExtendedTooltip name="DefaultBankAccountExtendedTooltip" id="6"/>
		</InputField>
	</ChildItems>
	<Attributes>
		<Attribute name="ConstantsSet" id="1">
			<Type>
				<v8:Type>cfg:ConstantsSet</v8:Type>
			</Type>
			<MainAttribute>true</MainAttribute>
			<SavedData>true</SavedData>
		</Attribute>
```
- Đúng ví dụ lý thuyết: gom "Default company" và "Default bank account" vào common form `DefaultValues` (main attribute kiểu `ConstantsSet`).
- Trong `DefaultCompany.xml` / `DefaultBankAccount.xml` của nhánh này, `UseStandardCommands` = false → form riêng của từng constant không hiện trong giao diện, user chỉ sửa qua form chung.

### Journal "Purchases and Sales": column Counterparty gộp Vendor và Customer
Nguồn: nhánh lesson/13-theory — cf/DocumentJournals/PurchasesAndSales.xml
```xml
			<Column uuid="9e21df68-5159-44ae-af51-4b0ea57516fe">
				<Properties>
					<Name>Counterparty</Name>
					<Synonym>
						<v8:item>
							<v8:lang>en</v8:lang>
							<v8:content>Counterparty</v8:content>
						</v8:item>
					</Synonym>
					<Comment/>
					<Indexing>DontIndex</Indexing>
					<References>
						<xr:Item xsi:type="xr:MDObjectRef">Document.PurchaseInvoice.Attribute.Vendor</xr:Item>
						<xr:Item xsi:type="xr:MDObjectRef">Document.SalesInvoice.Attribute.Customer</xr:Item>
						<xr:Item xsi:type="xr:MDObjectRef">Document.ReturnOfGoodsFromCustomer.Attribute.Customer</xr:Item>
					</References>
				</Properties>
			</Column>
```
- Đây chính là ví dụ trong lý thuyết: attribute `Vendor` của Purchase invoice và `Customer` của Sales invoice (và Return of goods from customer) hiển thị trong cùng một column "Counterparty".
- Mỗi document góp đúng một attribute vào column; các cột date, number, document type là mặc định, không cần khai báo.

### Resource CharacteristicValue: Select type automatically + choice parameter link
Nguồn: nhánh lesson/13-theory — cf/InformationRegisters/ObjectsCharacteristicValues.xml
```xml
					<ChoiceParameterLinks>
						<xr:Link>
							<xr:Name>Filter.Owner</xr:Name>
							<xr:DataPath xsi:type="xs:string">InformationRegister.ObjectsCharacteristicValues.Dimension.CharacteristicType</xr:DataPath>
							<xr:ValueChange>Clear</xr:ValueChange>
						</xr:Link>
					</ChoiceParameterLinks>
					<ChoiceParameters/>
					<QuickChoice>Auto</QuickChoice>
					<CreateOnInput>Auto</CreateOnInput>
					<ChoiceForm/>
					<LinkByType>
						<xr:DataPath>InformationRegister.ObjectsCharacteristicValues.Dimension.CharacteristicType</xr:DataPath>
						<xr:LinkItem>0</xr:LinkItem>
					</LinkByType>
```
- `LinkByType` → DataPath tới dimension `CharacteristicType` = property **Select type automatically** = "Characteristic type": kiểu của field giá trị đi theo characteristic type đã chọn, không còn nút chọn kiểu.
- `ChoiceParameterLinks` với `Filter.Owner` = `CharacteristicType` → danh sách additional values chỉ gồm các giá trị thuộc characteristic type đó (không hiện "48-50" của Size khi chọn Color); `ValueChange` = `Clear` xóa giá trị khi đổi type.
- Hai dimensions `Object` và `CharacteristicType` trong cùng file đều có `Master` = true và `DenyIncompleteValues` = true (flag **No empty values**).

### Ánh xạ loại object sang CharacteristicsObjectTypes (bản demo của lý thuyết)
Nguồn: nhánh lesson/13-theory — cf/InformationRegisters/ObjectsCharacteristicValues/Forms/RecordForm/Ext/Form/Module.bsl
```bsl
&AtServer
Function CharacteristicsObjectType()

	TypeOfObject = TypeOf(Record.Object);
	
	If TypeOfObject = Type("CatalogRef.Companies") Then
		Result = Enums.CharacteristicsObjectTypes.Companies;
	ElsIf TypeOfObject = Type("CatalogRef.Counterparties") Then
		Result = Enums.CharacteristicsObjectTypes.Counterparties;
	ElsIf TypeOfObject = Type("CatalogRef.Employees") Then
		Result = Enums.CharacteristicsObjectTypes.Employees;
	ElsIf TypeOfObject = Type("CatalogRef.Products") Then
		Result = Enums.CharacteristicsObjectTypes.Products;
	ElsIf TypeOfObject = Type("CatalogRef.Warehouses") Then
		Result = Enums.CharacteristicsObjectTypes.Warehouses;
	Else
		Raise "Unexpected type of object: " + TypeOfObject;
	EndIf;

	Return Result;
	
EndFunction
```
- Function này nằm trong record form của register; cùng module còn có `OnCreateAtServer` (ẩn field Object khi đã điền), `ObjectOnChange` (so với biến `PreviousObjectType`, xóa CharacteristicType/CharacteristicValue khi loại object đổi) và `SetChoiceParametersForCharacteristicType` (đặt choice parameter `Filter.CharacteristicsObjectType`) — đúng các bước mô tả ở mục Charts of characteristic types; tự viết các procedure đó theo Thẻ gợi ý bài thực hành, Bài tập 3.
- Bản demo xử lý đúng 5 giá trị enumeration của lý thuyết (Companies, Counterparties, **Employees**, Products, Warehouses). [ghi chú ngoài nguồn] Danh sách object của 13. Practice khác (có CounterpartyContracts và hai documents, không có Employees) → phải sửa cả enumeration lẫn function này.

## Video tham khảo

Video bài giảng trên YouTube có phạm vi trùng với bài này. Khi dẫn cho người học, nói "Bạn có thể tham khảo thêm về <chủ đề> của khóa tại đây: [<tên video>](link)" — không nói "khóa cũ/Junior", không dùng mã JC (mã JC trong danh sách chỉ để tra nội bộ). Quy ước đầy đủ: `references/video.md#video-junior-course`.

- [Hằng số (Constant)](https://www.youtube.com/watch?v=0Ru2FzltA4k&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=15) (7:28) — Bài 13 — Constants _(mã nội bộ JC-16)_
- [Dữ liệu xác định trước](https://www.youtube.com/watch?v=EQLuZq69Nmw&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=20) (8:02) — Bài 4 — Predefined data; Bài 13 / 24 — predefined của Chart of characteristic types, Chart of accounts _(mã nội bộ JC-21)_

<!-- video-qa-thuchanh:start -->

Video giải đáp tình huống thực chiến và video thực hành từng bước liên quan tới bài này (thẻ chi tiết, triệu chứng, lưu ý khi giới thiệu: `references/video.md#video-qa-thuc-chien`, `references/video.md#video-thuc-hanh`; cùng mẫu câu dẫn ở trên):

- [Ghi nhận luân chuyển dòng tiền](https://www.youtube.com/watch?v=YzhM76Wy9fk&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=7) (18:29) — quỹ tiền mặt: thu/chi, posting, số dư trên form và đánh số chứng từ (thực hành case study; Bài 13 liên quan) _(mã nội bộ P1-6)_
- [Bắt lần khởi động đầu tiên](https://www.youtube.com/watch?v=Q9op8HgLMtM&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=9) (9:05) — xử lý lần chạy đầu tiên của ứng dụng (thực hành case study; Bài 13 liên quan) _(mã nội bộ P2-9)_

<!-- video-qa-thuchanh:end -->


---

# § bai-14

# Bài 14 — Common modules, Application/Session modules, Commands & Command interface

## Khái niệm chính

### Common modules
- **Common modules** chứa procedures và functions có thể gọi từ bất kỳ module nào khác của configuration; các procedures/functions đó phải có từ khóa **Export** trong tiêu đề.
- Có thể tạo procedures/functions thường (không Export) — chỉ gọi được trong chính module đó; thường mang mục đích phục vụ (service) cho các export methods.
- Properties của common module chỉ xem được trong **Properties palette** (common module không có object editor).
- Theo execution context, có 4 loại:
  - **client**: chỉ gọi từ client, chỉ chạy trên client.
  - **server**: chỉ gọi từ server, chỉ chạy trên server.
  - **client-server**: gọi được từ cả client và server; chạy trong cùng context nơi gọi.
  - **server call** (server with the ability to call the server): gọi được từ client và server, nhưng chỉ chạy trên server.
- Flag **"External connection"**: module có khả dụng trong session không khởi động interactive (kết nối database từ bên ngoài, ví dụ truy cập HTTP service hoặc Web-service khởi động session ở external connection). Nên bật cho server và client-server modules.
- Property **Global**: export methods của module thuộc global context → gọi trực tiếp như built-in methods, không cần tên module.
  - Global = False → global context có property cùng tên với common module (read-only), giá trị là object **CommonModule**; gọi dạng `XXXXX.YYYYY` (tên module.tên export method). Object common module có thể gán vào biến rồi gọi qua biến.
- Quy tắc cho client-server và server call modules:
  - Client-server module phải làm mọi việc trong một context duy nhất — không chấp nhận khi gọi từ client mà thực thi chuyển sang server từ module này hoặc module khác.
  - **Incorrect 1**: Form module -> Client-server module -> Module with the "Call server" flag
  - **Incorrect 2**: Form module -> Client-server module -> Client module -> Module with the "Call server" flag
  - **Correct**: Form module -> Client module -> Module with the "Call server" flag
- Khi gọi module "Server call" từ client: không phải object nào cũng truyền được giữa client và server (tra syntax assistant). Thường không truyền được: objects không tồn tại trên client hoặc server như **CatalogObject**, **DocumentObject**, collections **ValueTable**, **ValueTree**; form data collections (**FormDataStructure**, **FormDataCollection**, **FormDataTree**, **FormDataStructureAndCollection** — sửa trên server sau khi truyền từ client sẽ lỗi khi quay về client); một số objects không tồn tại trong thin client context. Ví dụ: **FileDialog** không tồn tại ở server; **ValueTable** không tồn tại ở client.
- Mỗi client-server module khi biên dịch tạo thành 2 bản: client và server; có thể khác nhau nhờ **preprocessor directives** — đặt code trong điều kiện để code chỉ vào bản có context hỗ trợ (ví dụ ghi event log không thực hiện được trong thin client).
- **Note**: preprocessor directives có thể tổng quát hoặc chi tiết: `#If Server` bao gồm kiểm tra `#If MobileAppServer Or MobileStandaloneServer`; `#If Client` bao gồm mọi client (thick client, web client, mobile client...).
- Danh sách đầy đủ preprocessor directives cho điều kiện: Client, Server, ThinClient, WebClient, MobileStandaloneServer, MobileAppClient, MobileAppServer, MobileClient, ThickClientOrdinaryApplication, ThickClientManagedApplication, ExternalConnection.
- Property **Privileged**: tắt kiểm soát quyền truy cập khi thực thi methods của module — mọi code chạy với full rights, không áp access restrictions.
  - **Note**: bật Privileged → property **Server** tự bật, các properties còn lại (**Client (ordinary application)**, **Client (managed application)**, **External connection**) bị reset. Privileged module chỉ chạy được trên server.

### Reuse return values
- Chỉ khả dụng nếu common module không phải Global. Property **"Reuse return values"**:
  - **Do not use**: không tái sử dụng.
  - **During call** / **During session**: sau lần gọi đầu, hệ thống nhớ tham số và kết quả; gọi lại với cùng tham số → trả giá trị đã lưu mà không thực thi function. Nếu function thay đổi giá trị tham số khi chạy, lần gọi lại sẽ không làm việc đó.
- Nơi lưu:
  - Function chạy trên server, gọi từ code server → nhớ cho session hiện tại ở server.
  - Function chạy trên thick/thin client → nhớ ở client.
  - Function chạy trên server, gọi từ client → nhớ ở cả client và server (session hiện tại).
- Xóa giá trị đã lưu:
  - **During call**: server — khi trả quyền điều khiển từ server; client — khi procedure/function built-in language cấp cao nhất kết thúc (do hệ thống gọi từ giao diện, không phải từ procedure khác).
  - **During session**: server — cuối session (hoặc sau thời gian nhất định); client — khi đóng client application (hoặc sau thời gian nhất định).
  - Theo thời gian: trên server, thick client, external connection, thin client và web client với tốc độ kết nối bình thường — **20 phút** sau khi tính giá trị hoặc **6 phút** sau lần dùng cuối (ví dụ gọi mỗi 5,5 phút: ba lần trả giá trị cũ, lần thứ tư thực thi lại vì đã 22 phút). Thin client và web client với kết nối chậm — **20 phút** sau khi tính.
  - Theo infobase settings: thiếu RAM trong working process của server; restart working process; client chuyển sang working process khác.
  - Sau khi xóa, lần gọi kế tiếp được thực thi như lần đầu.
- **Note**: không ảnh hưởng procedures — procedures luôn được thực thi.
- Kiểu tham số của export function khi bật reuse chỉ được là: primitive types (Undefined, NULL, Boolean, Number, String, Date); references tới database objects; Structures có property thuộc các kiểu trên (so sánh "theo nội dung").
- Nếu function trả về object → thực ra trả reference tới object trong cache; thay đổi trạng thái object sau đó thì lần gọi sau trả reference tới object đã bị thay đổi mà không thực thi function — cho tới khi giá trị bị xóa.
- Cache không quan tâm trạng thái privileged mode lúc gọi: lần gọi thật đầu tiên ở privileged mode có thể trả object không lấy được khi tắt privileged mode; các lần gọi sau không privileged vẫn nhận object "không được phép" cho tới khi cache bị xóa. Ngược lại cũng đúng.
- "During session": giá trị trả về không được chứa **TemporaryTableManager**, **Query** và application objects (ví dụ **DataProcessorObject**, **DocumentObject**), trực tiếp hay trong collection. Ngoại lệ: reference types (DocumentRef, CatalogRef...).
- Gọi function của module có reuse từ chính module đó: gọi bằng tên ngắn (`MyFunction()`) → luôn thực thi; muốn dùng giá trị lưu phải gọi bằng tên đầy đủ (`Pricing.MyFunction()`).
- **RefreshReusableValues()** (global context): xóa mọi giá trị lưu ở cả server và client, bất kể gọi ở đâu; có thể chạy lâu → chỉ dùng khi thực sự cần.

### Purpose and use
- Khuyến nghị đặt vào common modules code liên quan tới subsystem thay vì object cụ thể. Ví dụ: kiểm tra cột "Amount" (sản phẩm Promotional được giá 0) dùng cho cả Sales invoice và Return of goods from customer → đưa vào export procedure của common module Sales (server module) và gọi từ object module của các document.

### Application module
- Tự động thực thi khi configuration được nạp lúc 1C:Enterprise khởi động ở các chế độ: thin client, web client, thick client ở managed application mode (thick client regular application chỉ dùng trong configuration cũ, mặc định tắt trong infobase mới).
- Dùng xử lý hành động liên quan session của user (chủ yếu bắt đầu/kết thúc session). **Không khả dụng cho procedures chạy trên server.** Khuyến nghị chỉ viết handlers cho các event tương ứng.
- Unhandled exception trong bất kỳ event handler nào của managed application module (**BeforeStart()**, **OnStart()**, **BeforeExit()**, **OnExit()**) → toàn bộ hệ thống crash. Bắt exception trong khối Except thì không crash.
- Procedures, functions, variables có Export trong application module khả dụng trong: non-global client common modules; client procedures/functions của command module; client procedures/functions của form module.
- Trong context của application module khả dụng: phần global context chạy được ở client; export methods của mọi client common modules; export methods của server non-global common modules có property "Server call".

### External connection module
- Nằm ở root của configuration (như application module). Chứa event handlers khởi tạo khi hệ thống bắt đầu và kết thúc ở external connection mode (ví dụ HTTP-service).
- Có thể khai báo variables, procedures, functions khả dụng cho ứng dụng bên ngoài.
- Objects truy cập được từ bên ngoài qua external connection: export methods của external connection module; export methods của common modules (bao gồm/loại trừ module hoàn toàn bằng properties của common modules; bao gồm/loại trừ đoạn code bằng preprocessor instructions); global context của 1C:Enterprise script language.
- Module chỉ có trong external connection session; chế độ này hoàn toàn không có user interface.

### Session module
- Tự động thực thi khi 1C:Enterprise khởi động và configuration được nạp.
- Dùng khởi tạo **session parameters** và hành động liên quan session. Luôn chạy ở **privileged mode** của 1C:Enterprise server. Đặt session parameters trong handler **SessionParametersSetting()**.
- Chỉ chứa định nghĩa procedures/functions, có thể dùng procedures của common modules, **không chứa export** procedures/functions.
- SessionParametersSetting() được gọi **trước** BeforeStart() (hoặc OnStart() với external connection module).
- Xác định loại session (background job hay khác): **GetCurrentInfoBaseSession()** trả về object InformationBase Session; gọi **GetBackgroundJob()** trên object đó để biết có phải background task session. [ghi chú ngoài nguồn] Tài liệu gốc ghi cả "GetBackgroundTask()" và "GetBackgroundJob()" cho cùng phương thức. → xem mục Code demo của bài Theory (nhánh lesson/14-theory): code demo dùng `GetBackgroundJob()`.

### Commands
- **Command**: configuration object để mô tả hành động user thực hiện.
- Loại command:
  - **Standard**: platform tự sinh dựa trên configuration (ví dụ command mở list form của catalog Products trong subsystem "Master data"; nút "Create" trên list form). Platform cũng tạo command tạo object mới trong subsystems chứa object, nhưng mặc định tắt — developer có thể bật.
  - **Object commands**: catalog, register... có commands riêng (ví dụ tạo object mới theo quy tắc điền nhất định, mở form object trung gian).
  - **Common commands**: không gắn với object cụ thể hoặc thao tác với objects không dùng standard commands (ví dụ đổi password user hiện tại, gửi email, mở exchange settings).
- Phân loại ảnh hưởng vị trí trong command interface:
  - Theo dữ liệu: **independent** và **parameterizable**.
  - Theo mục đích: **navigation** và **action**.
- **Independent commands**: không cần dữ liệu bổ sung; kết quả như nhau bất kể gọi từ đâu (mở form list/form tạo document mới, chạy quy trình như tính giá vốn).
- **Parameterizable commands**: cần **command parameter** quyết định kết quả (mở list subordinate catalog — tham số là reference tới owner; tạo document dựa trên object; xử lý với reference tới object, ví dụ tải tỷ giá một loại tiền). Ví dụ standard: commands chuyển tới register records của document.
- Ví dụ tự tạo parameterizable command: object command của document Sales invoice gọi từ catalog Products:
  - **Group**: command panel of the form. General
  - **Command parameter type**: CatalogRef.Products
  - **Parameter usage mode**: Multiple
  - Trong command module, handler được tạo mặc định. Mode **Single** → tham số là một reference; mode **Multiple** → tham số là mảng references. Truyền mảng vào property **Products** của structure **FillingValues**, mở form document với parameter structure chứa FillingValues.
  - Trong handler **Filling**: kiểm tra kiểu FillingData; nếu là structure và có property Products → gọi procedure điền tabular sections Products và Services (quantity = 1). Tabular sections không thể tự điền bởi event này.
  - Kết quả: nút trong submenu **Generate** của item form và list form của Products; chọn nhiều item (product và service) → điền cả hai tabular sections.
- **Navigation commands**: điều hướng user trong chức năng ứng dụng; thường mở list form mới trong cửa sổ nơi gọi, thay form đang hiển thị trong work area. Có thể là independent hoặc parameterizable global commands (đi tới catalog list form — independent; đi tới list form của subordinate catalog — parameterizable).
  - Mỗi reference object có parameterizable navigation command **"Show in list"**: mở list form với dòng của object được highlight. Nếu document thuộc document journal, "Show in list" là submenu (list form document + journal).
- **Action command** (parameterizable): khi nhập chuỗi vào field kiểu reference rồi bấm "Create" → mở form tạo object mới, field gắn với attribute default presentation chứa chuỗi đã nhập (trừ documents — không có property "Default presentation").
  - **Note**: cần property **"Create on input"** = **"Use"** cho object (hoặc attributes tham chiếu tới object đó).
- **Command groups**: gom commands để dễ đặt vào command interface. Chọn một trong 4 categories (**Navigation panel**, **form navigation panel**, **action panel**, **form command bar**), rồi với các command đặt property **Group** = command group. Ví dụ group "Sales Calculations" (Navigation Panel, subsystem Sales) với common commands "Calculate cost" và "Calculate financial result".
  - Trên current section functions panel, commands không được gộp thành submenu; trên sections panel, commands được gộp thành subgroup như subordinate subsystem.

### Command interface
- Root configuration object có các mục command interface (chuột phải hoặc properties palette).
- **Configuration command interface**: lưu thứ tự sections và visibility của sections (kể cả theo user roles). Đổi thứ tự bằng mũi tên lên/xuống; reset bằng cách chọn root **Sections** trong cửa sổ "Command interface" và bấm **"Restore automatic order"**.
- **Main section command interface**: lưu thiết lập main section — service subsystem **Quick menu**, đứng trước mọi subsystems ở Enterprise mode; thường chứa objects dùng nhiều nhất.
  - Nút **"Open main section command interface"**: trái — objects có thể đặt vào main section; phải — vị trí trên các panel. Thêm/bớt bằng **"add command"** / **"remove command"** (mũi tên phải/trái). Mặc định vào nhóm **Navigation panel.Normal**; kéo thả sang **Navigation panel.Important** → command hiển thị in đậm.
- **"All subsystems" editor**: quản lý subsystems và command interfaces; mở từ context menu của root configuration node hoặc của node Subsystems (nhánh Common). Là phiên bản mở rộng của cửa sổ command interface một subsystem: thêm/sửa/xóa subsystems, đổi thứ tự trong configuration tree (không phải trong interface), nội dung, bật/tắt visibility objects cho mọi roles hoặc từng role.

## Cú pháp & ví dụ code

Export procedures/functions:
```bsl
Procedure RecalculateTotalOfDocument(Document) Export
    
Function DiscountPercentage(Product, Date) Export
```

Gọi methods của common module:
```bsl
// Calling a Global module method
FillPricesInTabularSection(TabularSection, Date);

// Calling a non-global module method
Pricing.FillPricesInTabularSection(TabularSection, Date);

// Writing a common module object to a variable 
// and calling a method of this common module via that variable
MyVariable = CommonModuleWithAVeryLongName;
MyVariable.ProcedureOfTheCommonModule();
```

Preprocessor directives (dạng điều kiện được nêu trong tài liệu):
```bsl
#If Server
#If MobileAppServer Or MobileStandaloneServer
#If Client
```

Gọi function có reuse từ chính module:
```bsl
MyFunction()          // executed on each call
Pricing.MyFunction()  // stored values are used
```

Xóa mọi giá trị lưu:
```bsl
RefreshReusableValues()
```

[ghi chú ngoài nguồn] Các ví dụ khác (bảng flag của 4 loại module, procedure ghi event log với preprocessor directive và hai bản client/server, common module Sales và lời gọi từ document, application module crash/không crash, command handler với FillingValues, Filling điền Products/Services) chỉ có dạng ảnh chụp màn hình, không có văn bản code nên không được chép lại. → bảng flag, common module Sales và lời gọi từ document, command handler với FillingValues, Filling điền Products/Services → xem mục Code demo của bài Theory (nhánh lesson/14-theory). Riêng procedure ghi event log với preprocessor directive và ví dụ application module crash/không crash không có trong nhánh lesson/14-theory (managed application module của nhánh là file rỗng) nên vẫn chưa có code.

## Thuộc tính/thiết lập quan trọng trong Designer
- Common module (Properties palette): **Client (ordinary application)**, **Client (managed application)**, **Server**, **Server call**, **External connection**, **Global**, **Privileged**, **Reuse return values** (**Do not use** / **During call** / **During session**).
- Session module: handler **SessionParametersSetting()**.
- Application module handlers: **BeforeStart()**, **OnStart()**, **BeforeExit()**, **OnExit()**.
- Command: **Group**, **Command parameter type**, **Parameter usage mode** (**Single** / **Multiple**).
- Command group: category **Navigation panel** / **form navigation panel** / **action panel** / **form command bar**.
- Object / attribute: **Create on input** = **Use**; **Default presentation**.
- Root configuration: **Configuration command interface** (**Restore automatic order**), **Main section command interface** (**Navigation panel.Normal**, **Navigation panel.Important**), **All subsystems** editor.

## Lỗi thường gặp / lưu ý
- Client-server module gọi tiếp sang module "Server call" (trực tiếp hoặc qua client module) → sai; phải đi Form module -> Client module -> Server call module.
- Truyền CatalogObject, DocumentObject, ValueTable, ValueTree, form data collections giữa client và server → lỗi (FileDialog không có ở server, ValueTable không có ở client; trả form data structure đã sửa từ server về client → lỗi).
- Code không khả dụng trong một context (ví dụ ghi event log trong thin client) → bọc bằng preprocessor directive.
- Privileged module chỉ chạy trên server; bật Privileged sẽ reset các flags khác.
- Reuse return values: không áp dụng cho procedures; tham số chỉ primitive/reference/Structure; object trả về là reference trong cache (thay đổi sẽ bị "nhớ"); cache bỏ qua privileged mode; "During session" không trả TemporaryTableManager, Query, application objects.
- Gọi function reuse bằng tên ngắn trong cùng module → không dùng cache.
- RefreshReusableValues() có thể chạy lâu — chỉ dùng khi thật cần.
- Unhandled exception trong BeforeStart/OnStart/BeforeExit/OnExit của application module → crash toàn hệ thống.
- Application module không khả dụng cho code server.
- Session module không chứa export methods.
- Muốn tạo object mới khi nhập reference → phải đặt "Create on input" = "Use".

## Điểm cần nhớ
- Common module: chỉ methods có Export mới gọi được từ ngoài; 4 loại context: client, server, client-server, server call.
- Global = gọi trực tiếp; non-global = `ModuleName.Method()`.
- Client-server module phải chạy trong một context; dùng preprocessor directives để tách code client/server.
- Privileged = full rights, chỉ server.
- Reuse return values (non-global): During call / During session; 20 phút / 6 phút; chỉ áp cho functions; RefreshReusableValues() để xóa.
- Application module: session phía client, handlers BeforeStart/OnStart/BeforeExit/OnExit — luôn bắt exception.
- Session module: SessionParametersSetting() chạy ở privileged mode, trước BeforeStart/OnStart; không có export.
- Commands: standard / object / common; independent vs parameterizable; navigation vs action; Command parameter type + Parameter usage mode (Single → reference, Multiple → mảng).

## Thẻ gợi ý bài thực hành (Practice 14)

> Thẻ gợi ý dẫn hướng cho từng yêu cầu của 14. Practice.docx; không có lời giải hoàn chỉnh. Với mỗi common module, đề nhắc phải đặt đúng flags trong Properties palette.

### Bài tập 1 — Server common module ProductsInDocuments: kiểm tra số dư dùng chung
- **Đề bài (tóm tắt):** Tạo server common module ProductsInDocuments (thêm hậu tố nếu cần) và chuyển phần kiểm tra số dư hàng của InventoryTransfer và SalesInvoice vào đó.
- **Gợi ý 1 — Hướng đi:** Code giống nhau ở nhiều document → đưa vào **export procedure** của **server** common module (mục Common modules, Purpose and use); document chỉ còn lời gọi `ModuleName.Method(...)` vì module không Global.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Common module `ProductsInDocuments`: flags **Server** = true, **External connection** = true (khuyến nghị cho server module), Client = false, **Server call** = false, Global = false.
  - Procedure export nhận đủ dữ liệu qua tham số vì không còn truy cập trực tiếp attributes của document: danh sách products (mảng), kho, thời điểm (PointInTime của document), `Cancel`.
  - Giữ đoạn đọc constant "Control balances of goods" (Bài 13) bên trong procedure chung.
  - Trong `Posting` của hai documents: thay lời gọi procedure cục bộ bằng lời gọi module; InventoryTransfer truyền `WarehouseSender`.
- **Gợi ý 3 — Khung bài làm:**
```bsl
// Common module ProductsInDocuments (Server)
Procedure ___(Products, Warehouse, Date, Cancel) Export
	// kiểm tra constant -> nếu tắt thì ___
	// query số dư âm như Bài 12, nhưng dùng tham số thay cho attributes của document
	// Period = New Boundary(___, ___)
EndProcedure

// Object module của document, trong Posting, sau Write():
// ProductsInDocuments.___(___, ___, PointInTime(), Cancel);
```
- **Lỗi hay gặp:**
  - Bật Server call → module gọi được từ client, không cần thiết và lộ code server ra client.
  - Bật Global rồi vẫn gọi `ProductsInDocuments.Method` (hoặc ngược lại).
  - Quên `Export` → document không gọi được.
  - Trong module vẫn viết `PointInTime()` / `Products` như trong object module → lỗi, vì common module không có context của document.
- **Tự kiểm tra:** Xóa procedure kiểm tra cũ trong hai object modules, post sales invoice và inventory transfer vượt số dư → vẫn bị chặn với đúng thông báo; đặt breakpoint trong common module để thấy cả hai document đi qua cùng một chỗ.

### Bài tập 2 — Server call common module: function lấy giá
- **Đề bài (tóm tắt):** Tạo server call common module ProductsInDocuments (có hậu tố) chứa function trả giá của product tại ngày bất kỳ (tham số Product, Date); dùng nó trong form modules khi gọi từ client.
- **Gợi ý 1 — Hướng đi:** Client cần dữ liệu server mà không có form context → module có flag **Server call** (mục Common modules — loại server call); tham số chỉ là reference và Date (truyền được giữa client và server).
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Common module `ProductsInDocumentsServerCall`: Server = true, **Server call** = true.
  - Export function `(Product, Date)`: đọc giá từ register ProductPrices (SliceLast, như Bài 12). Có thể đặt logic đọc giá trong manager module của register và để function server call chỉ gọi tiếp.
  - Trong form SalesInvoice: procedure client "khi đổi product" gọi `ProductsInDocumentsServerCall.<Function>(...)`, bỏ function `&AtServerNoContext` cục bộ cũ.
- **Gợi ý 3 — Khung bài làm:**
```bsl
// Common module ProductsInDocumentsServerCall (Server, Server call)
Function ___(Product, Date) Export
	// trả về giá mới nhất của Product tại Date: ___
EndFunction

// Form module (&AtClient):
// CurrentData.Price = ___.___(CurrentData.Product, Object.Date);
```
- **Lỗi hay gặp:**
  - Tạo module server thường (không Server call) rồi gọi từ client → lỗi "procedure not found"/không khả dụng.
  - Truyền form data (`CurrentData`, `Object`) sang server call → nên truyền giá trị đơn (Product, Date).
- **Tự kiểm tra:** Chọn product trên sales invoice → giá được điền như trước khi refactor; trong debugger bước vào thấy code chạy ở server.

### Bài tập 3 — Client-server common module: tính amount của dòng, discount tùy chọn
- **Đề bài (tóm tắt):** Module client-server ProductsInDocuments (có hậu tố) chứa procedure tính lại amount của dòng tabular section; discount là tham số **tùy chọn**; thay mọi procedure cục bộ tính amount ở các form.
- **Gợi ý 1 — Hướng đi:** Một procedure dùng được cả trong `&AtClient` (OnChange) và `&AtServer` (tính tổng) → **client-server** module (mục Common modules); tham số tùy chọn khai báo bằng giá trị mặc định trong tiêu đề.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Common module `ProductsInDocumentsClientServer`: **Client (managed application)** = true, **Server** = true, External connection = true, Server call = false.
  - Export procedure `(Row, Discount = 0)`: tính Amount từ Quantity, Price, Discount.
  - Thay lời gọi ở form SalesInvoice, ReturnOfGoodsFromCustomer (và PurchaseInvoice nếu có tính amount — gọi không truyền discount); xóa procedure cục bộ `&AtClientAtServerNoContext`.
- **Gợi ý 3 — Khung bài làm:**
```bsl
// Common module ProductsInDocumentsClientServer (Client + Server)
Procedure ___(ProductsRow, Discount = ___) Export
	// ProductsRow.Amount = ___
EndProcedure
```
- **Lỗi hay gặp:**
  - Gọi sang module Server call từ bên trong client-server module → sai quy tắc "một context" (Incorrect 1 của lý thuyết).
  - Không đặt giá trị mặc định → mọi lời gọi phải truyền discount (trái đề).
  - Quên sửa một form → vẫn còn procedure cục bộ trùng logic.
- **Tự kiểm tra:** Đổi Quantity ở sales invoice, return, purchase invoice → Amount đúng; Find in modules không còn procedure tính amount cục bộ.

### Bài tập 4 — Parameterizable command "Set price"
- **Đề bài (tóm tắt):** Command mở form PriceSetup với các product được chọn đã chèn sẵn vào tabular section; gọi được cho một hoặc nhiều products; có trên command bar của item form và list form Products; tự chọn object command hay common command.
- **Gợi ý 1 — Hướng đi:** Command cần dữ liệu (products được chọn) → **parameterizable command**; vì kết quả là tạo document PriceSetup → **object command** của PriceSetup với **Command parameter type** = CatalogRef.Products (mục Commands — đúng ví dụ tạo Sales invoice từ Products của lý thuyết). Dữ liệu chuyển sang document qua **FillingValues** và event **Filling**.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Document PriceSetup → tab Commands → command `SetPrice`: Group = command bar của form (ví dụ Important), Command parameter type = `CatalogRef.Products`, **Parameter usage mode = Multiple** (→ tham số là mảng).
  - Command module, handler `CommandProcessing(CommandParameter, CommandExecuteParameters)` (`&AtClient`): tạo structure FillingValues có property Products, mở `"Document.PriceSetup.ObjectForm"` với parameter `FillingValues`.
  - Object module PriceSetup, `Filling(FillingData, FillingText, StandardProcessing)`: nếu FillingData là Structure và có property Products → thêm dòng vào tabular section cho từng product (Filling không tự điền tabular section).
- **Gợi ý 3 — Khung bài làm:**
```bsl
&AtClient
Procedure CommandProcessing(CommandParameter, CommandExecuteParameters)
	// FillingValues = New Structure("___", CommandParameter)
	// mở form object của PriceSetup với New Structure("FillingValues", ___)
EndProcedure

Procedure Filling(FillingData, FillingText, StandardProcessing)
	// If TypeOf(FillingData) = Type("___") And FillingData.Property("___") Then
	//   For Each ... thêm dòng, Product = ___
EndProcedure
```
- **Lỗi hay gặp:**
  - Parameter usage mode = Single → chọn nhiều products chỉ nhận một (hoặc lệnh không khả dụng).
  - Dùng common command không có parameter type → không xuất hiện trên form Products.
  - Không kiểm tra `TypeOf(FillingData)` → lỗi khi PriceSetup được tạo bình thường hoặc dựa trên object khác.
  - Chọn Group trong submenu Generate trong khi đề yêu cầu trên command bar.
- **Tự kiểm tra:** Trên list form Products chọn 3 dòng → bấm Set price → form PriceSetup mở với 3 dòng, chỉ cần nhập Price và lưu; thử từ item form của một product.

### Bài tập 5 — Main section command interface
- **Đề bài (tóm tắt):** Main section hiển thị commands mở list purchase documents, journal Sales documents, catalogs Products, Counterparties, CounterpartyContracts, Warehouses; Products và journal Sales documents ở panel Important.
- **Gợi ý 1 — Hướng đi:** Thiết lập trong **Main section command interface** của root configuration (mục Command interface) — không cần code.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Chuột phải root configuration → Open main section command interface; bên trái chọn command OpenList của từng object, "add command"; kéo Products và journal SalesDocuments sang **Navigation panel.Important**, các command còn lại ở **Navigation panel.Normal**.
- **Gợi ý 3 — Khung bài làm:**
  1. Mở editor main section command interface.
  2. Thêm 6 commands.
  3. Kéo 2 commands vào Important, sắp xếp thứ tự.
- **Lỗi hay gặp:**
  - Thêm vào command interface của subsystem thay vì main section.
  - Object chưa có quyền/không thuộc subsystem nào nên không hiện trong danh sách bên trái — kiểm tra lại.
- **Tự kiểm tra:** Ở Enterprise mode, section đầu tiên (main) có 6 lệnh, 2 lệnh in đậm.

### Bài tập 6 — Lệnh tạo mới trong command interface của subsystems
- **Đề bài (tóm tắt):** Thêm command tạo Products vào subsystem Master data; command tạo Counterparty và CounterpartyContract vào subsystem Sales.
- **Gợi ý 1 — Hướng đi:** Platform đã sinh **standard command** "Create" cho object trong subsystem nhưng mặc định tắt (mục Commands — Standard) → bật trong command interface của subsystem.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Subsystem Master data → Command interface → nhóm action panel (Create) → bật Visible cho `Catalog.Products.StandardCommand.Create`; tương tự ở Sales cho Counterparties và CounterpartyContracts (object phải thuộc subsystem đó).
- **Gợi ý 3 — Khung bài làm:**
  1. Mở command interface của Master data, bật command Create của Products.
  2. Kiểm tra Counterparties, CounterpartyContracts đã thuộc subsystem Sales; bật command Create.
- **Lỗi hay gặp:**
  - Object không thuộc subsystem → command không có trong danh sách của subsystem đó.
- **Tự kiểm tra:** Ở section Master data có nút "Product" trong action panel (Create); ở Sales có "Counterparty" và "Counterparty contract".

### Bài tập 7 — Enumeration WriteOffMethods và constant WriteOffOrder
- **Đề bài (tóm tắt):** Enumeration "Write-Off methods" (FIFO, LIFO, Manually); constant WriteOffOrder kiểu EnumRef.WriteOffMethods; thêm field sửa constant vào constants form đã tạo (Bài 13).
- **Gợi ý 1 — Hướng đi:** Tập giá trị cố định → Enumeration; giá trị thiết lập chung → Constant; constants form có main attribute ConstantsSet nên chỉ cần kéo constant mới lên.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Enumeration `WriteOffMethods`; constant `WriteOffOrder`; mở common form "Goods turnover settings" → kéo `ConstantsSet.WriteOffOrder` lên form.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo enumeration với 3 values, đặt synonym dễ hiểu.
  2. Tạo constant, chọn kiểu.
  3. Thêm field vào constants form.
- **Lỗi hay gặp:**
  - Tạo form riêng mới thay vì thêm vào form có sẵn (đề yêu cầu form đã tạo trước đó).
- **Tự kiểm tra:** Mở form settings, chọn FIFO, lưu, mở lại vẫn là FIFO.

### Bài tập 8 — Dimension Batch trong GoodsInWarehouses
- **Đề bài (tóm tắt):** Register GoodsInWarehouses lưu movements và số dư không chỉ theo Product, Warehouse mà cả theo Batch (batch là document PurchaseInvoice); các thay đổi khác làm ở bài sau.
- **Gợi ý 1 — Hướng đi:** Thêm phân tích mới cho số dư → thêm **dimension** (mục Accumulation register của Bài 11).
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Register `GoodsInWarehouses` → dimension `Batch` kiểu `DocumentRef.PurchaseInvoice`. Ở Posting của PurchaseInvoice, batch tự nhiên chính là reference của document đang post — có thể bắt đầu gán ngay từ bài này.
- **Gợi ý 3 — Khung bài làm:**
  1. Thêm dimension Batch.
  2. Cập nhật database configuration.
  3. (Tùy chọn) PurchaseInvoice: thêm phép gán Batch cho record trong Posting.
- **Lỗi hay gặp:**
  - Chọn kiểu Batch là composite hoặc catalog → không khớp đề ("batch document is the PurchaseInvoice").
  - Sau khi thêm dimension, số dư của các document cũ có Batch rỗng — cần re-post nếu muốn dữ liệu nhất quán.
- **Tự kiểm tra:** Re-post một Purchase invoice, mở records của register → cột Batch có giá trị là chính invoice đó.

## Code demo của bài Theory (repo 1CJDCourse, nhánh lesson/14-theory)

So với nhánh lesson/13-theory, nhánh lesson/14-theory thêm: các common modules `Sales`, `CommonClientServer`, `CommonServerCall`, `CommonServerPrivileged`, session module, managed application module (file rỗng), object command `CreateFromProducts` của SalesInvoice, command group `SalesCalculations` với hai common commands.

Flags của các common modules demo (đọc từ file .xml của từng module trong nhánh) — tương ứng bảng 4 loại module của lý thuyết:

| Common module | Loại | Client (managed application) | Server | External connection | Server call | Privileged | Global | Reuse return values |
|---|---|---|---|---|---|---|---|---|
| Sales | server | false | true | true | false | false | false | DontUse |
| CommonServer | server | false | true | false | false | false | false | DontUse |
| CommonClientServer | client-server | true | true | true | false | false | false | DontUse |
| CommonServerCall | server call | false | true | false | true | false | false | DontUse |
| CommonServerPrivileged | privileged | false | true | false | false | true | false | DontUse |

- `CommonServerPrivileged`: Privileged = true kéo theo Server = true, các flag client và External connection bị reset — đúng **Note** của lý thuyết.
- Trong nhánh, các module `CommonClientServer`, `CommonServerCall`, `CommonServerPrivileged` chỉ được tạo để minh họa flags (module rỗng, chưa có code).

### Common module Sales: kiểm tra Amount dùng chung cho hai document
Nguồn: nhánh lesson/14-theory — cf/CommonModules/Sales/Ext/Module.bsl
```bsl
Procedure CheckAmountOfProducts(Products, Cancel) Export
	
	Query = New Query;
	Query.Text = 
	"SELECT
	|	Products.LineNumber AS LineNumber,
	|	Products.Product AS Product,
	|	Products.Amount AS Amount
	|INTO TempTableProducts
	|FROM
	|	&Products AS Products
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	TempTableProducts.LineNumber AS LineNumber,
	|	TempTableProducts.Product AS Product,
	|	TempTableProducts.Amount AS Amount
	|FROM
	|	TempTableProducts AS TempTableProducts
	|		INNER JOIN Catalog.Products AS Products
	|		ON TempTableProducts.Product = Products.Ref
	|WHERE
	|	NOT Products.Promotional
	|	AND TempTableProducts.Amount = 0";
	
	Query.SetParameter("Products", Products);
	
	Selection = Query.Execute().Select();
	While Selection.Next() Do
		
		MessageText = StrTemplate(
			"The ""Amount"" is required on line %1 of the ""Products"" list.",
			Selection.LineNumber
		);
		Message(MessageText);
		Cancel = True;
		
	EndDo;
	
EndProcedure
```
- Đúng ví dụ "Purpose and use": query kiểm tra cột Amount (bỏ qua sản phẩm `Promotional`) được chuyển nguyên từ FillCheckProcessing của Sales invoice (Bài 12) sang export procedure của server common module `Sales`.
- `Export` trong tiêu đề → gọi được từ object module của các document; `Cancel` truyền vào và được đổi bên trong procedure.

### Gọi Sales.CheckAmountOfProducts từ FillCheckProcessing
Nguồn: nhánh lesson/14-theory — cf/Documents/SalesInvoice/Ext/ObjectModule.bsl
```bsl
Procedure FillCheckProcessing(Cancel, CheckedAttributes)

	If Products.Count() > 0 Then
		DeleteAttributeFromChecking(CheckedAttributes, "Services");
	ElsIf Services.Count() > 0 Then	
		DeleteAttributeFromChecking(CheckedAttributes, "Products");
	EndIf;

	// Turn off checking by the platform
	DeleteAttributeFromChecking(CheckedAttributes, "Products.Amount");
	
	Sales.CheckAmountOfProducts(Products, Cancel);
	
EndProcedure
```
- Module có Global = false → gọi dạng `Sales.CheckAmountOfProducts(...)` (tên module.tên method).
- `ReturnOfGoodsFromCustomer/Ext/ObjectModule.bsl` trong cùng nhánh có FillCheckProcessing giống hệt, cùng gọi `Sales.CheckAmountOfProducts(Products, Cancel);` — một chỗ sửa cho cả hai document.

### Session module: phân biệt session của background job
Nguồn: nhánh lesson/14-theory — cf/Ext/SessionModule.bsl
```bsl
Procedure SessionParametersSetting(RequiredParameters)
	
	CurrentSession = GetCurrentInfoBaseSession();
	BackgroundJob = CurrentSession.GetBackgroundJob();
	If BackgroundJob <> Undefined Then
		// This session is started in a background job
	Else
		// This session is started not in a backgroung job
	EndIf;
	
EndProcedure
```
- Handler `SessionParametersSetting()` chạy ở privileged mode, trước `BeforeStart()`; module không có export.
- `GetCurrentInfoBaseSession()` trả về object session; `GetBackgroundJob()` trả `Undefined` nếu session không phải background job — xác nhận tên method đúng là `GetBackgroundJob()` (không phải "GetBackgroundTask()").

### Object command CreateFromProducts: tạo Sales invoice từ danh sách Products
Nguồn: nhánh lesson/14-theory — cf/Documents/SalesInvoice/Commands/CreateFromProducts/Ext/CommandModule.bsl
```bsl
&AtClient
Procedure CommandProcessing(CommandParameter, CommandExecuteParameters)
	
	FillingValues = New Structure("Products", CommandParameter);
	
	FormParameters = New Structure("FillingValues", FillingValues);
	OpenForm(
		"Document.SalesInvoice.ObjectForm",
		FormParameters, 
		CommandExecuteParameters.Source, 
		CommandExecuteParameters.Uniqueness, 
		CommandExecuteParameters.Window, 
		CommandExecuteParameters.URL
	);

EndProcedure
```
- Thiết lập trong `SalesInvoice.xml`: Group = `FormCommandBarCreateBasedOn`, Command parameter type = `CatalogRef.Products`, Parameter usage mode = `Multiple` → `CommandParameter` là mảng references; nút hiện trong submenu tạo dựa trên (Generate) của form Products.
- Mảng được đặt vào property `Products` của structure `FillingValues`, rồi truyền qua parameter `FillingValues` của `OpenForm`.

### Filling điền cả Products và Services bằng batch query
Nguồn: nhánh lesson/14-theory — cf/Documents/SalesInvoice/Ext/ObjectModule.bsl
```bsl
Procedure Filling(FillingData, FillingText, StandardProcessing)
	
	Company 	= Constants.DefaultCompany.Get();
	BankAccount = Constants.DefaultBankAccount.Get();
	
	If TypeOf(FillingData) = Type("Structure") Then
		
		If FillingData.Property("Products") Then
			
			FillProductAndServices(FillingData.Products);
			
		EndIf;
	
	EndIf;
	
EndProcedure

Procedure FillProductAndServices(ProductsAndServices)
	
	Query = New Query;
	Query.Text = 
	"SELECT
	|	Products.Ref AS Product,
	|	1 AS Quantity
	|FROM
	|	Catalog.Products AS Products
	|WHERE
	|	Products.Ref IN(&ProductsAndServices)
	|	AND Products.Type = &Product
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	Products.Ref AS Service,
	|	1 AS Quantity
	|FROM
	|	Catalog.Products AS Products
	|WHERE
	|	Products.Ref IN(&ProductsAndServices)
	|	AND Products.Type = &Service";
	
	Query.SetParameter("ProductsAndServices", 	ProductsAndServices);
	Query.SetParameter("Product", 				Enums.ProductTypes.Product);
	Query.SetParameter("Service", 				Enums.ProductTypes.Service);
	
	Results = Query.ExecuteBatch();
	Products.Load(Results[0].Unload());
	Services.Load(Results[1].Unload());
	
EndProcedure
```
- Đúng ví dụ lý thuyết: kiểm tra `TypeOf(FillingData) = Type("Structure")` và `Property("Products")`, rồi tự điền tabular sections (event Filling không tự điền tabular section).
- Batch query tách mảng references theo `Products.Type`: kết quả 0 → Products, kết quả 1 → Services, mỗi dòng `Quantity` = 1; nạp bằng `Load(Results[i].Unload())`.
- Hai dòng đầu vẫn điền Company/BankAccount từ constants (Bài 13).

### Command group SalesCalculations (Navigation panel)
Nguồn: nhánh lesson/14-theory — cf/CommandGroups/SalesCalculations.xml và cf/CommonCommands/CalculateCost.xml
```xml
			<Category>NavigationPanel</Category>
```
```xml
			<Group>CommandGroup.SalesCalculations</Group>
```
- Command group category `NavigationPanel`; common commands `CalculateCost` và `CalculateFinancialResult` đặt property Group = `CommandGroup.SalesCalculations` — đúng ví dụ "Sales Calculations" của lý thuyết.
- Command module của hai common commands chỉ là template mặc định (handler `CommandProcessing` với nội dung bị comment) — demo tập trung vào vị trí trong command interface.

## Video tham khảo

Video bài giảng trên YouTube có phạm vi trùng với bài này. Khi dẫn cho người học, nói "Bạn có thể tham khảo thêm về <chủ đề> của khóa tại đây: [<tên video>](link)" — không nói "khóa cũ/Junior", không dùng mã JC (mã JC trong danh sách chỉ để tra nội bộ). Quy ước đầy đủ: `references/video.md#video-junior-course`.

- [Homepage, form và command](https://www.youtube.com/watch?v=DDk5kS4BRow&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=8) (5:11) — Bài 9 — Home page, form; Bài 14 — Commands, Command interface _(mã nội bộ JC-9)_
- [Làm việc với bối cảnh toàn cục (Global Context)](https://www.youtube.com/watch?v=cqwM140spEs&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=25) (5:16) — Bài 5-6 — Syntax assistant nhánh Global context, `Message()`; Bài 14 — common module Global _(mã nội bộ JC-26)_
- [Giao diện lệnh (command) trên biểu mẫu (form)](https://www.youtube.com/watch?v=4sYHynvvbls&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=34) (6:29) — Bài 9 — form commands, command bar; Bài 14 — commands. Ngoài giáo trình: gán phím tắt cho command không có trong giáo trình _(mã nội bộ JC-35)_

<!-- video-qa-thuchanh:start -->

Video giải đáp tình huống thực chiến và video thực hành từng bước liên quan tới bài này (thẻ chi tiết, triệu chứng, lưu ý khi giới thiệu: `references/video.md#video-qa-thuc-chien`, `references/video.md#video-thuc-hanh`; cùng mẫu câu dẫn ở trên):

- [Hiển thị đối tượng Siêu dữ liệu lên Quick menu](https://www.youtube.com/watch?v=rPSNKvFEQ8E&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=21) (2:23) — bật lệnh cho phân hệ đang trống (giải đáp tình huống; Bài 14 chính) _(mã nội bộ QA-21)_
- [Hệ thống thông tin cửa hàng nhỏ](https://www.youtube.com/watch?v=zXa4pQv0LHE&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=6) (12:28) — xử lý nhiều đơn hàng bằng một lệnh (thực hành case study; Bài 14 chính) _(mã nội bộ P2-6)_
- [Bắt lần khởi động đầu tiên](https://www.youtube.com/watch?v=Q9op8HgLMtM&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=9) (9:05) — xử lý lần chạy đầu tiên của ứng dụng (thực hành case study; Bài 14 chính) _(mã nội bộ P2-9)_
- [Cách hiển thị biểu ghi tích lũy lên phân hệ](https://www.youtube.com/watch?v=DBJeS7LfUpY&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=4) (1:53) — cách hiện register lên phân hệ (giải đáp tình huống; Bài 14 liên quan) _(mã nội bộ QA-4)_
- [Tạo chức năng in hóa đơn chứng từ](https://www.youtube.com/watch?v=uwEBQJZG6t4&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=7) (5:31) — tạo mẫu in chứng từ bằng Print wizard (giải đáp tình huống; Bài 14 liên quan) _(mã nội bộ QA-7)_

<!-- video-qa-thuchanh:end -->


---

# § bai-15

# Bài 15 — Functional options, Object/non-object entities, Referential integrity

## Khái niệm chính

### Functional options (FO)
- **Functional options** là metadata class cho phép người dùng tự bật/tắt một phần chức năng của chương trình. Giúp developer làm **một** applied solution duy nhất thay vì nhiều giải pháp cho từng trường hợp sử dụng (ví dụ: DB này dùng nhiều currency, DB kia không).
- **Functional option parameters**: metadata class dùng để chia chức năng **theo vùng dữ liệu** (ví dụ theo Company) thay vì theo toàn bộ database.
- FO có tác động tới:
  - **User interface** — khi tắt FO, hệ thống ẩn mọi phần tử liên quan:
    - global command interface;
    - form details (kể cả các cột của form details kiểu Value Table hoặc Value Tree);
    - form commands;
    - reports được làm bằng data composition system.
  - **Thuật toán viết bằng built-in language** — có thể lấy giá trị FO từ code để dùng trong điều kiện (ví dụ giảm khối lượng tính toán).
- FO và parameters **không ảnh hưởng nội dung database**: mọi bảng và field đều tồn tại trong DB bất kể trạng thái FO.
- **Global command interface**: hệ thống ẩn commands của mọi object thuộc FO bị tắt. Ví dụ `UseProduction` = False → ẩn command mở section Production, tạo document ProductRelease, mở list ProductRelease...
  - FO `UseProduction` có thể tính theo giá trị functional option parameter (ví dụ Company): bật cho company này, tắt cho company khác. Đổi giá trị parameter bằng built-in language → đổi trạng thái FO → đổi visibility.
  - Một command bị loại khỏi command interface nếu **attribute là command parameter** bị FO tắt.
  - Một parameterizable command bị loại nếu **command parameter type** bị FO tắt. Nếu parameter type là composite → command chỉ unavailable khi **tất cả** các type đều bị tắt.
- **Nơi lưu giá trị FO** (property **Data path**) có thể là:
  - constants,
  - catalog attributes,
  - resources of information registers.
  - Không giới hạn kiểu giá trị, nhưng **chỉ FO lưu giá trị kiểu Boolean** mới dùng được để quản lý interface. FO kiểu khác chỉ dùng được khi đọc trong built-in language.
- **Gán object vào FO** — 2 cách:
  1. Từ object, tab **"Functional options"** (chỉ hiện các FO lưu giá trị kiểu Boolean).
  2. Từ tab **Content** của FO — chi tiết hơn: chọn được không chỉ catalogs, documents..., mà cả attributes, tabular sections, attributes of tabular sections.
- **Quy tắc visibility (toán tử "OR")**: object không được gán FO nào → luôn visible. Nếu có gán → visible khi **ít nhất một** FO được gán đang bật. Quy tắc giống hệt cho form attributes / form commands.
- Constant mới có default value **False** → FO bị tắt ngay sau khi update.
- Trong "functions for technician", objects luôn hiện bất kể FO; list form khi đó cho thấy object thuộc chức năng bị tắt và không dùng được.
- **Commands của global command interface và form đang mở KHÔNG tự cập nhật** khi giá trị FO thay đổi → dùng global context method **`RefreshInterface()`**.
  - `RefreshInterface()` tốn nhiều tài nguyên → dùng có chủ đích, không gọi mỗi lần FO đổi.
  - Pattern của standard solutions: một form chứa nhiều FO nhóm theo khối chức năng (Purchases, Sales, Production...). Nếu user đổi ít nhất 1 FO → ghi vào một biến cờ rằng sau khi lưu cần refresh interface.
  - Ví dụ trong bài: common form DefaultValues đổi tên thành **ApplicationSettings**, thêm form attribute kiểu Boolean làm cờ "cần update interface"; khi đổi constant liên quan FO → set cờ = True; handler **AfterWrite** của form kiểm tra cờ và gọi `RefreshInterface()` (method này là **client-side**, dù dẫn tới server call).
- **Hệ quả khi set FO parameters (và khi chạy `RefreshInterface()`)**:
  - với mỗi form, gọi đóng tất cả auxiliary forms (kèm các handler tương ứng);
  - form từ chối đóng thì không bị đóng;
  - thành phần elements của main form được cập nhật;
  - nếu main form đang active → hiển thị theo thành phần mới;
  - nếu auxiliary form đang active: command mở auxiliary form được chạy lại nếu còn available sau refresh; nếu không → cập nhật và hiển thị main form;
  - nếu active form là auxiliary form mở bằng command không thuộc form navigation panel → thay bằng main form đã cập nhật.
- **Form attributes và form commands** có property **"Functional options"** (chọn 1 hoặc nhiều FO) — cùng quy tắc OR như configuration objects.
- FO không chỉ để đổi command interface: còn là công cụ tiện để **lấy một giá trị mà không phải xét user rights**, và **cache** giá trị để tối ưu việc đọc thường xuyên từ code.

### Privileged mode & caching
- Property **"Use privileged mode for getting data"**:
  - **Bật**: giá trị FO lấy trong privileged mode; kết quả được cache cho **tất cả sessions** của infobase.
  - **Tắt**: lấy ở normal mode; cache cho **session hiện tại**. Cache cả giá trị (nếu lấy được) lẫn dấu hiệu không lấy được giá trị.
  - Cache bị reset khi giá trị **session parameters** thay đổi.

### Functional option parameters
- Dùng khi giá trị FO cần lấy kèm "làm rõ", ví dụ: company 1 có hạch toán theo contracts không → tạo FO `UseContracts` (hoặc `AccountingByContracts`) + functional option parameter `Company`.
- Kiểu giá trị property **Use** của parameter:
  - FO lưu trong **catalog attribute** → `CatalogRef.Companies`.
  - FO lưu trong **information register resource** → một **dimension** của chính register đó có kiểu `CatalogRef.Company`.
- Một parameter dùng được cho nhiều FO. Danh sách trong **Use** gồm catalog references và information register dimensions; với mỗi parameter chọn được **một catalog** và **một dimension của mỗi information register**.
- **Không được** dùng cùng một metadata object trong nhiều functional option parameters.
- Ví dụ trong bài:
  - FO `CompanyPrefix` — lưu trong attribute của catalog Companies; **không gán objects** vì không phải separator, chỉ để lấy prefix của company (đánh số document riêng theo company, ví dụ AB0001, CH0001).
  - FO `UseContracts` — lưu trong resource của information register `CompanyAccountingSettings` (có thể thêm resource khác như dùng tax accounting). Content: catalog `CounterpartyContracts` và attribute `Contract` của các documents.
  - Parameter `Company`: chọn reference tới catalog Companies (cho `CompanyPrefix`) và dimension kiểu `CatalogRef.Companies` của register `CompanyAccountingSettings`.
  - Record form của register cũng cần làm cơ chế gọi `RefreshInterface()` như common form của constants.
- **Global interface với parameterized FO**: nếu flag True ở **ít nhất một** register record → FO = True → catalog `CounterpartyContracts` hiện trong global interface.
- **Trong form**: platform **không tự xác định** dùng parameter nào để tính FO chứa attribute `Contract` → tính như global interface (True nếu có 1 record True). Phải dùng global method dành cho form: **`SetParametersFormFunctionalOptions(<ParametersStructure>)`** — structure gồm tên parameter và giá trị (ở đây: `Company` = Company của document).
  - Gọi từ form event **OnCreateAtServer** và từ handler **OnChange** của form field Company (vì company khác có thể có giá trị FO khác).
- **Đọc giá trị FO từ code**: function **`GetFunctionalOption`**, có tham số tuỳ chọn `Parameters` kiểu **Structure** (key = tên functional option parameter, value = giá trị làm rõ).

### Object và non-object entities
- **Object entities**: mọi object có reference — catalogs, documents, charts of characteristic types, charts of accounts, charts of calculation types, exchange plans, business processes, tasks.
  - Mỗi object là duy nhất (kể cả khi điền giống hệt object khác) nhờ **unique identifier** không đổi suốt vòng đời object, dù mọi attribute/tabular section thay đổi.
  - Ví dụ: 2 item "Scissors" giống hệt trong Products → 2 reference khác nhau, hạch toán riêng. Đổi tên thành Small Scissors / Large Scissors → nhờ referential integrity, presentation đổi ở mọi nơi dùng.
  - Ví dụ chuẩn hơn: catalog **Individuals** — một người có thể đổi chức vụ, tình trạng hôn nhân, họ, thậm chí giới tính nhưng vẫn là cùng một người → phải là object entity.
- **Non-object entities**: **tất cả registers**. Record là phản ánh của một thông tin (số odometer ngày bảo dưỡng, đã bán bao nhiêu hàng với số tiền nào...). Đổi key fields → đổi ý nghĩa record (đổi John thành Michael trong lịch sử chức vụ → dữ liệu hoàn toàn khác).
  - Ví dụ: information register **Employee Positions** (Period – Individual – Position).
- Chọn object để lưu thông tin dựa trên **loại entity** mà object phản ánh; chú ý cách đặt tên object (catalog `Individuals` vs information register `Employee Positions`).

### Referential integrity
- Khi presentation của object đổi → mọi reference tới nó đổi presentation ở mọi nơi dùng.
- Dimension có flag **Master**: register records phụ thuộc object được tham chiếu; xoá object thì records tự động bị xoá.
- **2 cách xoá object entities**:
  1. **Direct deletion** — không an toàn: reference vẫn còn trong DB nhưng trỏ tới object không tồn tại → có thể gây lỗi trong thuật toán, và hiển thị không thân thiện (chỉ là identifier). Mặc định không có trong context menu, chỉ có trong submenu **"More actions"** của item/object form hoặc list form.
  2. **Mark for deletion** rồi xoá với kiểm soát referential integrity — cách được khuyến nghị: user có thể đổi ý (bỏ deletion mark); khi xoá qua service processing **"Delete marked objects"**, hệ thống phân tích reference còn lại tới object, nếu có thì **cấm xoá** cho tới khi các reference đó được xử lý (thay/xoá giá trị attribute, hoặc xoá object chứa reference).
- **"Delete marked objects"** nằm trong section **"Standard"** của menu **"functions for technician"**, có 2 lựa chọn:
  - **"Full deletion"** — xoá tất cả object đã đánh dấu.
  - **"Selective deletion"** — chỉ xoá object user chọn (**khuyến nghị**, tránh xoá nhầm object user định bỏ đánh dấu nhưng chưa làm).
  - Có lệnh "set all" / "clear all", và bật/tắt flag theo metadata object trong cây.
  - Khi object còn bị tham chiếu → thông báo và xem được danh sách object tham chiếu (ví dụ bank bị đánh dấu xoá nhưng còn bank account có owner là bank đó).
- **Access rights** (trong objects kiểu Role): **Delete** — cho phép direct deletion; **"Interactive mark for deletion"** — cho phép đánh dấu xoá trong interactive mode (từ form).

## Cú pháp & ví dụ code

```bsl
FunctionalOptionParameters = New Structure("Company", CompanyValue);

Prefix = GetFunctionalOption("CompanyPrefix", FunctionalOptionParameters);
```

Các method được nêu trong tài liệu (chỉ có chữ ký, không có đoạn code đầy đủ dạng văn bản):

```bsl
RefreshInterface()
SetParametersFormFunctionalOptions(<ParametersStructure>)
GetFunctionalOption
```

[ghi chú ngoài nguồn] Các đoạn code khác trong bài (handler AfterWrite gọi RefreshInterface, procedure gọi SetParametersFormFunctionalOptions) chỉ có ở dạng ảnh chụp màn hình, không có văn bản trong tài liệu nên không chép lại. → xem mục Code demo của bài Theory (nhánh lesson/15-theory): handler AfterWrite gọi `RefreshInterface()` ở record form của `CompanyAccountingSettings`, và ví dụ đặt FO parameters ở form Sales invoice (tên method thật là `SetFormFunctionalOptionParameters`). Phần áp dụng cho common form cài đặt → xem Thẻ gợi ý bài thực hành.

## Thuộc tính/thiết lập quan trọng trong Designer
- Functional option: **Data path** (constant / catalog attribute / information register resource).
- Functional option: **Use privileged mode for getting data**.
- Functional option: tab **Content**.
- Configuration object: tab **Functional options**.
- Form attribute / form command: property **Functional options**.
- Functional option parameter: property **Use** (catalog reference / information register dimension).
- Information register dimension: flag **Master**.
- Catalog: property **Check uniqueness** (uniqueness control — ví dụ không được có 2 object cùng code).
- Attribute: property **Required field** = "Display error".
- Role access rights: **Delete**, **Interactive mark for deletion**.

## Lỗi thường gặp / lưu ý
- Client làm việc với **file version** của infobase **qua web server**: đổi FO chỉ đổi interface sau khi **restart web server** (restart client application không có tác dụng).
- Sau khi bật FO, subsystem vẫn chưa hiện trong global command interface → do interface và form đang mở không tự refresh; cần `RefreshInterface()` (hoặc restart infobase — bất tiện).
- Không gọi `RefreshInterface()` mỗi lần FO thay đổi vì tốn tài nguyên.
- Field `Contract` vẫn hiện trên form dù FO tắt cho company đó → vì platform không biết dùng parameter nào; phải gọi `SetParametersFormFunctionalOptions`.
- **Required field = "Display error"**: nếu attribute bị tắt bởi FO **thường** → không kiểm tra; nếu bị tắt bởi FO **có parameter** → **vẫn kiểm tra** dù field bị ẩn khỏi form → phải tự loại attribute khỏi danh sách checked attributes trong event handler của object (hoặc form).
- Không dùng cùng một metadata object trong nhiều functional option parameters.
- Direct deletion để lại "broken reference" (reference trỏ tới object không tồn tại).
- Uniqueness control bật → attribute xác định uniqueness không được trùng giá trị.

## Điểm cần nhớ
- FO ẩn/hiện UI (global command interface, form details, form commands, DCS reports) nhưng **không đổi cấu trúc database**.
- Chỉ FO lưu giá trị **Boolean** mới điều khiển được interface; nơi lưu: constant, catalog attribute, information register resource.
- Visibility theo quy tắc **OR**: không gán FO → luôn hiện; có gán → hiện nếu ít nhất 1 FO bật.
- Đổi FO xong phải gọi **`RefreshInterface()`** (client-side, tốn tài nguyên) để cập nhật interface và form đang mở.
- FO có parameter: dùng **`SetParametersFormFunctionalOptions`** trong form (OnCreateAtServer + OnChange của field làm parameter), và **`GetFunctionalOption(Name, Structure)`** trong code.
- Bật **Use privileged mode for getting data** khi giá trị FO không nhạy cảm (cache cho mọi session).
- Object entities có reference/unique identifier; registers là non-object entities — đổi key field là đổi ý nghĩa record.
- Xoá an toàn = **mark for deletion** + **"Delete marked objects"** (ưu tiên **Selective deletion**); direct deletion không an toàn.

## Thẻ gợi ý bài thực hành (Practice 15)

Các thẻ dưới đây đi theo thứ tự đề trong 15. Practice. Mỗi thẻ chỉ có gợi ý, không có lời giải: bạn tự viết code rồi kiểm tra lại trong Enterprise mode.

### Bài tập 1 — Functional option UseCharacteristics và form cài đặt

- **Đề bài (tóm tắt):** Tạo FO `UseCharacteristics` để bật/tắt toàn bộ chức năng characteristics; làm một form riêng để user sửa giá trị FO; khi lưu form phải cập nhật global command interface và các form đang mở.
- **Gợi ý 1 — Hướng đi:** FO kiểu Boolean điều khiển visibility của các object liên quan đến characteristics (mục "Functional options (FO)"). Interface và form đang mở **không tự refresh** khi FO đổi, nên phải gọi `RefreshInterface()`, nhưng chỉ gọi một lần sau khi ghi, vì method này tốn tài nguyên.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Constant Boolean `UseCharacteristics` làm **Data path** của FO.
  - Tab **Content** của FO: chart of characteristic types, information register và catalog phục vụ characteristics (các object bạn đã tạo ở bài trước).
  - Common form (bài lý thuyết đổi `DefaultValues` thành `ApplicationSettings`) có attribute kiểu ConstantsSet và một form attribute Boolean làm cờ "cần refresh".
  - Handler client `OnChange` của field constant (chỉ bật cờ) và form event `AfterWrite` (`&AtClient`).
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo constant, rồi tạo FO, đặt Data path và Content.
  2. Đưa constant lên common form cài đặt, thêm attribute cờ, tốt nhất đặt tên khác tên method (ví dụ `InterfaceRefreshRequired`).
  3. Gán handler OnChange cho field và AfterWrite cho form qua Properties palette.
  4. Đưa form vào command interface của subsystem phù hợp.
  ```bsl
  &AtClient
  Procedure ___OnChange(Item)
  	// chỉ đánh dấu cờ "cần refresh", KHÔNG refresh ở đây
  	___
  EndProcedure

  &AtClient
  Procedure AfterWrite(WriteParameters)
  	// nếu cờ bật -> gọi method refresh interface (client-side)
  	___
  EndProcedure
  ```
- **Lỗi hay gặp:**
  - Gọi `RefreshInterface()` ngay trong OnChange: giá trị chưa được ghi, lại tốn tài nguyên.
  - Constant mới có giá trị mặc định False, nên sau khi update configuration các object trong Content bị ẩn ngay. Đây là hành vi đúng, không phải lỗi.
  - Đặt tên attribute trùng tên method `RefreshInterface`: vẫn chạy được nhưng khó đọc.
  - Nếu chạy file infobase qua web server, interface chỉ đổi sau khi restart web server.
- **Tự kiểm tra:** Trong Enterprise mode, tắt FO rồi Save: các command của characteristics biến khỏi sections mà không cần khởi động lại. Bật lại thì chúng xuất hiện. Đặt breakpoint ở AfterWrite để thấy cờ chỉ True khi field thật sự bị đổi.

### Bài tập 2 — FO có parameter ControlBalanceOfGoods theo từng company

- **Đề bài (tóm tắt):** Thay constant kiểm soát tồn kho bằng FO có parameter `Company` (lưu trong information register `CompanyAccountingSettings`). Document có Company thì kiểm tra theo company, document không có Company thì giữ logic cũ (đọc constant).
- **Gợi ý 1 — Hướng đi:** Mục "Functional option parameters": FO lưu trong **resource** của information register, còn parameter trỏ tới **dimension** Company của register đó. Đọc giá trị từ code bằng `GetFunctionalOption(Name, Structure)`, trong đó key của structure là tên parameter. Procedure kiểm tra tồn kho dùng chung (nằm trong server common module) nhận thêm tham số tuỳ chọn `Company = Undefined`.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Information register `CompanyAccountingSettings`: nonperiodical, dimension `Company` (CatalogRef.Companies), resource Boolean `ControlBalanceOfGoods`.
  - FO `ControlBalanceOfGoods`: Data path là resource trên, Content để trống (chỉ đọc từ code), nên bật **Use privileged mode for getting data**.
  - Functional option parameter `Company`: trong **Use** chọn dimension `Company` của register.
  - Procedure Export trong common module (Server), gọi từ handler `Posting` của các document đang kiểm tra tồn kho.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo register, FO và parameter như trên.
  2. Thêm tham số tuỳ chọn Company vào procedure kiểm tra chung.
  3. Đầu procedure: chọn nguồn giá trị (FO có parameter hay constant), nếu không cần kiểm tra thì `Return`.
  4. Document có attribute Company truyền thêm Company; document không có thì không truyền.
  ```bsl
  Procedure ___(Products, Warehouse, Date, Cancel, Company = Undefined) Export
  	If ___ Then  // Company có được truyền vào không?
  		// đọc FO có parameter: tên FO + Structure("Company", ...)
  		___
  	Else
  		// giữ cách cũ: đọc constant
  		___
  	EndIf;
  	// nếu không cần kiểm tra -> thoát; ngược lại query Balance và báo dòng âm
  	___
  EndProcedure
  ```
- **Lỗi hay gặp:**
  - Truyền structure sai key: key phải đúng **tên functional option parameter** (`Company`), không phải tên dimension hay tên attribute.
  - Quên truyền Company từ document có Company, khi đó FO không được tính theo company.
  - [ghi chú ngoài nguồn] Trong cấu hình mẫu của khóa, tên FO/constant bị gõ thiếu chữ "r" (`ContolBalanceOfGoods`). Khi tự làm, đặt đúng `ControlBalanceOfGoods` như đề bài và dùng thống nhất một tên.
  - Kiểm tra tồn kho phải lấy balance tại thời điểm **bao gồm** chính document (dùng `New Boundary(..., BoundaryType.Including)` hoặc `PointInTime()`), sau khi đã ghi movements.
- **Tự kiểm tra:** Tạo 2 record trong `CompanyAccountingSettings`: company A bật, company B tắt. Post Sales invoice bán vượt tồn: với A thì bị chặn kèm thông báo, với B thì post được. Inventory transfer vẫn theo constant như cũ.

### Bài tập 3 — Prefix số document theo company (CompanyPrefix + OnSetNewNumber)

- **Đề bài (tóm tắt):** Thêm attribute `Prefix` cho catalog Companies, tạo FO có parameter `CompanyPrefix` lưu giá trị trong attribute này, rồi tự động gắn prefix vào số của mọi document có Company qua `OnSetNewNumber`, gọi chung một server common module `DocumentNumbering`.
- **Gợi ý 1 — Hướng đi:** FO không kiểu Boolean không điều khiển interface, nhưng vẫn đọc được bằng `GetFunctionalOption` (mục "Functional option parameters", ví dụ `CompanyPrefix`). Event `OnSetNewNumber` của object module có tham số `Prefix`: gán giá trị cho nó thì platform dùng làm phần đầu của số tự động.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Catalog Companies: attribute `Prefix` (String, ngắn).
  - FO `CompanyPrefix`: Data path = attribute `Prefix`, Content trống.
  - Parameter `Company`: **Use** phải có thêm **reference của catalog Companies** (ngoài dimension của register ở bài 2).
  - Common module `DocumentNumbering` (Server): một export procedure nhận `StandardProcessing`, `Prefix`, `Company`.
  - Object module của **từng** document có Company: handler `OnSetNewNumber(StandardProcessing, Prefix)`.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo attribute, FO và bổ sung Use của parameter.
  2. Viết procedure chung trong `DocumentNumbering`: gán `Prefix` bằng giá trị FO tính theo company truyền vào.
  3. Thêm handler `OnSetNewNumber` vào mọi document có Company, mỗi handler chỉ một dòng gọi module chung.
  ```bsl
  // CommonModule DocumentNumbering (Server)
  Procedure ___(StandardProcessing, Prefix, Company) Export
  	// Prefix = giá trị FO "CompanyPrefix" với parameter Company
  	___
  EndProcedure
  ```
- **Lỗi hay gặp:**
  - Use của parameter `Company` thiếu catalog Companies, khi đó FO `CompanyPrefix` không tính được theo company.
  - Prefix chỉ áp dụng khi **số mới được cấp**; document đã có số giữ nguyên số cũ.
  - [ghi chú ngoài nguồn] Cấu hình mẫu của khóa chỉ có handler này ở Sales invoice, trong khi đề bài yêu cầu **mọi** document có Company. Hãy thêm cho đủ.
  - Quên chọn Company trước khi ghi (Company trống) thì prefix rỗng.
- **Tự kiểm tra:** Đặt Prefix "AB" cho company 1 và "CH" cho company 2. Tạo mới document cho từng company, Save: số bắt đầu bằng AB… hoặc CH…. Đặt breakpoint trong `OnSetNewNumber` để xem giá trị `Prefix`.

### Bài tập 4 — Thử xoá object với và không có referential integrity control

- **Đề bài (tóm tắt):** Tạo 3 company, dùng 2 company trong vài document. Xoá trực tiếp một company và quan sát các field tham chiếu; đánh dấu xoá 2 company còn lại rồi chạy "Delete marked objects", đọc thông báo lỗi và danh sách object còn tham chiếu.
- **Gợi ý 1 — Hướng đi:** Mục "Referential integrity": direct deletion để lại broken reference; mark for deletion + "Delete marked objects" kiểm tra reference trước khi xoá.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Lệnh **More actions → Delete** trên list/item form (direct deletion); lệnh đánh dấu xoá; service processing **"Delete marked objects"** trong section **Standard** của "functions for technician"; nên dùng **Selective deletion**. User cần quyền **Delete** / **Interactive mark for deletion** trong role.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo company X, Y, Z; dùng X và Y trong 1–2 document mỗi company.
  2. Xoá trực tiếp X, mở lại document có X và xem field Company hiển thị gì.
  3. Đánh dấu xoá Y và Z, chạy "Delete marked objects" (Selective), chọn cả hai.
  4. Đọc kết quả: Z bị xoá, Y bị giữ lại; mở danh sách object đang tham chiếu tới Y.
  (Bài này thao tác trong Enterprise mode, không cần viết code.)
- **Lỗi hay gặp:**
  - Không thấy lệnh Delete trong context menu: lệnh chỉ có trong **More actions**.
  - Dùng "Full deletion" làm xoá luôn object khác đang đánh dấu nhầm.
  - Quên rằng record của register có dimension **Master** trỏ tới object sẽ bị xoá theo.
- **Tự kiểm tra:** Field tham chiếu X hiển thị dạng identifier (object không tồn tại); Y vẫn còn với deletion mark kèm báo cáo "có reference"; Z biến khỏi danh sách.

### Bài tập 5 — Purchase invoice ghi chính nó vào dimension Batch

- **Đề bài (tóm tắt):** Sửa movements của Purchase invoice để dimension mới `Batch` của register GoodsInWarehouses nhận reference tới chính document đang post.
- **Gợi ý 1 — Hướng đi:** Mỗi phiếu nhập là một batch. Trong object module, `Ref` là reference của document đang post.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Dimension `Batch` của accumulation register GoodsInWarehouses có kiểu `DocumentRef.PurchaseInvoice`; handler `Posting` trong object module của Purchase invoice; chỉ cần thêm một phép gán vào vòng lặp tạo record đã có.
- **Gợi ý 3 — Khung bài làm:**
  1. Thêm dimension Batch vào register (nếu chưa có).
  2. Trong vòng lặp tạo record Receipt của Purchase invoice, gán thêm field Batch.
  3. Re-post các Purchase invoice cũ để movements có Batch.
- **Lỗi hay gặp:**
  - Code được sinh bằng register records wizard có cảnh báo trong marker: chạy lại wizard sẽ **ghi đè** phần bạn sửa tay.
  - Quên re-post document cũ, nên balance theo batch trống.
- **Tự kiểm tra:** Post một Purchase invoice, mở **Register records** (Go to → GoodsInWarehouses) và thấy cột Batch chứa chính document đó.

### Bài tập 6 — Cột Batch trong Sales invoice và lệnh "Pick batch"

- **Đề bài (tóm tắt):** Thêm cột `Batch` vào tabular section Products của Sales invoice, chỉ hiện khi Write-off order = Manually. Cột là bắt buộc nhưng phải bỏ khỏi danh sách kiểm tra khi không ở Manually. Thêm lệnh "Pick batch": kiểm tra dòng hiện tại, Product và Warehouse; mở form `PickBatch` (của Purchase invoice) liệt kê các batch còn tồn và số lượng; batch được chọn ghi vào dòng hiện tại qua callback `PickBatchAfterSelection`.
- **Gợi ý 1 — Hướng đi:**
  - Ẩn/hiện cột: đọc constant WriteOffOrder trong form event phía server.
  - Bỏ kiểm tra bắt buộc: cùng kỹ thuật lý thuyết nêu cho attribute bị ẩn bởi FO có parameter, tức là xoá path khỏi `CheckedAttributes` trong `FillCheckProcessing`.
  - Form chọn: dynamic list với custom query trên virtual table **Balance** của GoodsInWarehouses, tham số đặt qua `Parameters.SetParameterValue` (gợi ý trong đề).
  - Mở form non-modal kèm owner và `CallbackDescription`.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Column `Batch` (kiểu giống dimension Batch), Required field = "Display error".
  - Form Sales invoice: `OnCreateAtServer` (`&AtServer`) đặt `Visible` cho cột và nút; command `PickBatch` với handler `&AtClient`; callback Export `PickBatchAfterSelection(Result, AdditionalParameters)`.
  - Object module: `FillCheckProcessing(Cancel, CheckedAttributes)`, path cần xoá là `"Products.Batch"`.
  - Purchase invoice: form generic `PickBatch`, các form parameters Date, Product, Warehouse, đọc trong `OnCreateAtServer`.
  - `OpenForm`: owner là **form field** Batch của table, callback qua tham số CallbackDescriptionOnClose (theo đề bài).
- **Gợi ý 3 — Khung bài làm:**
  1. Thêm column, đặt Required field, đưa lên form; thêm command và nút vào command bar của table Products.
  2. `OnCreateAtServer`: tính một biến Boolean "đang Manually", gán cho Visible của cột và nút.
  3. `FillCheckProcessing`: nếu không Manually thì tìm index của path, khác Undefined thì xoá.
  4. Tạo form `PickBatch`: attribute DynamicList với custom query trên Balance (lọc theo &Product, &Warehouse, ngày &Date); `OnCreateAtServer` đặt 3 tham số từ `Parameters`.
  5. Handler `PickBatch`: kiểm tra rồi mở form.
  6. Callback: bỏ qua khi Result là Undefined, ngược lại ghi vào dòng hiện tại.
  ```bsl
  &AtClient
  Procedure PickBatch(Command)
  	// 1) dòng hiện tại có tồn tại? Product đã điền? -> nếu không: báo user, Return
  	// 2) Warehouse đã điền? -> nếu không: báo lỗi, Return
  	___
  	// 3) Structure tham số (Date, Product, Warehouse) + OpenForm(..., owner = field Batch, ..., callback)
  	___
  EndProcedure

  &AtClient
  Procedure PickBatchAfterSelection(Result, AdditionalParameters) Export
  	___ // kiểm tra Result và dòng hiện tại, rồi gán Batch
  EndProcedure
  ```
- **Lỗi hay gặp:**
  - Quên `Export` ở callback thì platform không gọi được.
  - Không kiểm tra `Items.Products.CurrentData = Undefined`: lỗi khi table trống hoặc không có dòng nào được chọn.
  - [ghi chú ngoài nguồn] Code mẫu của khóa chỉ kiểm tra Product; đề bài yêu cầu báo lỗi cả khi **Warehouse** trống. Đừng bỏ bước này. Tên callback trong cấu hình mẫu là `PickBatchOnSelection`; tên theo đề là `PickBatchAfterSelection`, chỉ khác tên.
  - `CheckedAttributes.Find()` trả Undefined nếu không có path, nên phải kiểm tra trước khi `Delete()`.
- **Tự kiểm tra:** Đặt Write-off order = FIFO: cột Batch và nút ẩn, document post được khi Batch trống. Đặt Manually: cột hiện; bấm "Pick batch" khi chưa chọn product hoặc warehouse thì nhận thông báo; khi đủ dữ liệu, form chỉ liệt kê batch còn tồn của đúng product và kho, chọn một dòng thì Batch được điền.

## Code demo của bài Theory (repo 1CJDCourse, nhánh lesson/15-theory)

So với nhánh lesson/14-theory, nhánh lesson/15-theory thêm: functional options `UseCharacteristics`, `UseContracts`, `CompanyPrefix` (và `UseCounterparties`), functional option parameter `Company`, information register `CompanyAccountingSettings` (Nonperiodical, Write mode `Independent`, dimension `Company`, resources `UseContracts`, `UseTaxes`) với record form, common form `DefaultValues` đổi tên thành `ApplicationSettings`, và code đặt FO parameters trong form Sales invoice.

### Form Sales invoice: đặt functional option parameters theo Company
Nguồn: nhánh lesson/15-theory — cf/Documents/SalesInvoice/Forms/DocumentForm/Ext/Form/Module.bsl
```bsl
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)

	SetFunctionalOptionParameters();
	
EndProcedure

&AtClient
Procedure CompanyOnChange(Item)
	
	OnCompanyChangeAtServer();
	
EndProcedure

&AtServer
Procedure OnCompanyChangeAtServer()

	SetFunctionalOptionParameters();

EndProcedure
// ...
&AtServer
Procedure SetFunctionalOptionParameters()
	
	FunctionalOptionParatemets = New Structure("Company", Object.Company);
	
	SetFormFunctionalOptionParameters(FunctionalOptionParatemets);
	
EndProcedure
```
- Đây là ví dụ còn thiếu của lý thuyết: gọi từ `OnCreateAtServer` và từ `CompanyOnChange` (qua `OnCompanyChangeAtServer`, vì method chỉ chạy trên server) — company khác có thể có giá trị FO `UseContracts` khác → field `Contract` ẩn/hiện theo company của document.
- Structure gồm tên functional option parameter (`Company`) và giá trị (`Object.Company`).
- Tên method thật của platform là **`SetFormFunctionalOptionParameters`**; tài liệu lý thuyết ghi `SetParametersFormFunctionalOptions` — khi viết code phải dùng tên `SetFormFunctionalOptionParameters`. (Tên biến `FunctionalOptionParatemets` bị gõ sai trong demo nhưng không ảnh hưởng.)

### Record form của CompanyAccountingSettings: cờ RefreshInterface khi đổi UseContracts
Nguồn: nhánh lesson/15-theory — cf/InformationRegisters/CompanyAccountingSettings/Forms/RecordForm/Ext/Form/Module.bsl
```bsl
&AtClient
Procedure UseContractsOnChange(Item)
	RefreshInterface = True;
EndProcedure

&AtClient
Procedure AfterWrite(WriteParameters)
	
	If RefreshInterface Then
		RefreshInterface();
	EndIf;
	
EndProcedure
```
- Đúng ghi chú lý thuyết "Record form của register cũng cần làm cơ chế gọi `RefreshInterface()` như common form của constants": form attribute Boolean `RefreshInterface`, field `Record.UseContracts` gắn handler OnChange `UseContractsOnChange`.
- Common form `ApplicationSettings` trong nhánh này có cùng cơ chế (handler OnChange bật cờ + `AfterWrite`) như record form ở trên.

### FO UseContracts: Data path là resource của information register, Content gồm catalog và attributes
Nguồn: nhánh lesson/15-theory — cf/FunctionalOptions/UseContracts.xml
```xml
			<Location>InformationRegister.CompanyAccountingSettings.Resource.UseContracts</Location>
			<PrivilegedGetMode>true</PrivilegedGetMode>
			<Content>
				<xr:Object>Catalog.CounterpartyContracts</xr:Object>
				<xr:Object>Document.PurchaseInvoice.Attribute.Contract</xr:Object>
				<xr:Object>Document.ReturnOfGoodsFromCustomer.Attribute.Contract</xr:Object>
				<xr:Object>Document.SalesInvoice.Attribute.Contract</xr:Object>
			</Content>
		</Properties>
```
- `Location` (Data path) = resource `UseContracts` của register `CompanyAccountingSettings`; `PrivilegedGetMode` = **Use privileged mode for getting data** bật.
- Tab Content chọn chi tiết tới mức attribute: catalog `CounterpartyContracts` và attribute `Contract` của ba documents.

### FO CompanyPrefix (không gán objects) và parameter Company
Nguồn: nhánh lesson/15-theory — cf/FunctionalOptions/CompanyPrefix.xml và cf/FunctionalOptionsParameters/Company.xml
```xml
			<Location>Catalog.Companies.Attribute.Prefix</Location>
			<PrivilegedGetMode>true</PrivilegedGetMode>
			<Content/>
```
```xml
			<Use>
				<xr:Item xsi:type="xr:MDObjectRef">InformationRegister.CompanyAccountingSettings.Dimension.Company</xr:Item>
			</Use>
```
- `CompanyPrefix` lưu ở catalog attribute `Companies.Prefix`, `Content` rỗng — chỉ để đọc bằng `GetFunctionalOption("CompanyPrefix", ...)`, không điều khiển interface.
- Property **Use** của parameter `Company` trỏ tới dimension `Company` của `CompanyAccountingSettings`.
- [ghi chú ngoài nguồn] Lý thuyết nói parameter `Company` chọn cả reference catalog Companies (cho `CompanyPrefix`); trong nhánh lesson/15-theory, **Use** chỉ có dimension của register.

## Video tham khảo

Video bài giảng trên YouTube có phạm vi trùng với bài này. Khi dẫn cho người học, nói "Bạn có thể tham khảo thêm về <chủ đề> của khóa tại đây: [<tên video>](link)" — không nói "khóa cũ/Junior", không dùng mã JC (mã JC trong danh sách chỉ để tra nội bộ). Quy ước đầy đủ: `references/video.md#video-junior-course`.

- [Đối tượng và tập hợp bản ghi](https://www.youtube.com/watch?v=L4OkNedrIeQ&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=16) (5:26) — Bài 15 — object vs non-object entities; Bài 12 — RecordSet / RecordManager _(mã nội bộ JC-17)_
- [Tính toàn vẹn tham chiếu](https://www.youtube.com/watch?v=e-C_yERp2sE&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=17) (7:49) — Bài 15 — referential integrity, deletion mark, xóa object _(mã nội bộ JC-18)_
- [Tùy chọn chức năng](https://www.youtube.com/watch?v=RF55RDNLgks&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=37) (7:02) — Bài 15 — Functional options _(mã nội bộ JC-38)_

<!-- video-qa-thuchanh:start -->

Video giải đáp tình huống thực chiến và video thực hành từng bước liên quan tới bài này (thẻ chi tiết, triệu chứng, lưu ý khi giới thiệu: `references/video.md#video-qa-thuc-chien`, `references/video.md#video-thuc-hanh`; cùng mẫu câu dẫn ở trên):

- [Hạch toán sản phẩm dịch vụ](https://www.youtube.com/watch?v=GFsS9x1bOTQ&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=7) (15:54) — tách hàng hóa/dịch vụ và bật tắt tính năng bằng Functional option (thực hành case study; Bài 15 chính) _(mã nội bộ P2-7)_

<!-- video-qa-thuchanh:end -->
