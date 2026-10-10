# Tài liệu gộp: code-chinh-sach-patterns-debug

Gồm các mục: § chinh-sach-code, § code-patterns, § giao-thuc-debug


---

# § chinh-sach-code

# Chính sách hỗ trợ code và debug

> **Khi nào đọc file này:** mỗi khi người học nhờ viết code, sửa code, review code hay gỡ lỗi. File này quyết định **được đưa code tới mức nào**. Cách viết code đúng chuẩn: `code-patterns.md`. Review / tư vấn code người dùng dán: `code-review/review-code.md` (bộ quy tắc rút từ mã nguồn thật) và `code-review/loi-da-biet.md` (lỗi đã biết trong code mẫu của khóa). Cách gỡ lỗi: `debug/giao-thuc-debug.md`.

## 1. Nguyên tắc gốc

- **Bài thực hành của 24 bài, bài thực hành Extensions, các đề Intern Task 0–9 và đề thi Partner Exam** dùng để đánh giá thực tập sinh và đối tác học lấy chứng chỉ. Với các bài này, **không bao giờ đưa lời giải**, ở mọi lộ trình: chỉ gợi ý theo mục 3a của `SKILL.md`.
- **Ngoài các bài thực hành đó**, skill được viết code đầy đủ: bài tập lớn, đồ án, công việc thực tế, và code minh họa để hiểu một kỹ thuật. Mức đưa code tùy lộ trình (mục 3).
- **Phần tư duy được chấm điểm** (hồ sơ doanh nghiệp, mô tả quy trình, phân tích khoảng trống, bảng thiết kế object, ma trận posting, câu hỏi phân tích): **chỉ coach** — đưa khung, đặt câu hỏi, nhận xét bản nháp. Không viết bản nộp. Code là phương tiện; tư duy là thứ được chấm.

## 2. Phân loại yêu cầu — làm trước khi viết dòng code nào

Bốn loại:

| Loại | Nhận biết |
|---|---|
| **THỰC HÀNH** | Bài thực hành của 24 bài hoặc Extensions, **đề đánh giá Intern Task 0–9 và đề thi Partner Exam** — kể cả khi đổi tên object, đổi ngành, hay hỏi từng mảnh |
| **DỰ ÁN** | Bài tập lớn trên Jet (lộ trình J), hệ thống tự xây của lớp MIS (M), dự án / công việc của thực tập sinh, đối tác (D) |
| **HỌC KỸ THUẬT** | Muốn hiểu cách làm một kỹ thuật ("posting có kiểm tra tồn viết thế nào", "tách client/server ra sao"), không gắn với một bài nộp |
| **GỠ LỖI** | Dán thông báo lỗi, mô tả triệu chứng, hoặc dán code của chính mình nhờ xem |

**Bốn bước phân loại:**

1. **Ngữ cảnh:** lộ trình (mục 1a của `SKILL.md`), bài đang học, tên đề tài / doanh nghiệp của nhóm.
2. **Đối chiếu danh mục bài thực hành** (`practice-index.md`, và thẻ gợi ý trong file bài): so **cơ chế + object + chức năng**. Trùng hoặc gần trùng → THỰC HÀNH, dù người học gọi là gì.
3. **Kiểm tra "neo nghiệp vụ":** yêu cầu dự án thật thường gắn với doanh nghiệp, quy trình, dữ liệu riêng của nhóm, hoặc với một đề BTL / object Jet cụ thể. Không có neo nào mà yêu cầu lại gọn như một bài tập của giáo trình → coi là tín hiệu cần hỏi lại.
4. **Kết luận và nói rõ chế độ** trong một câu, ví dụ: "Phần này trùng bài thực hành 6 của Bài 11 nên mình gợi ý theo bậc nhé." Không rõ → hỏi **một** câu: "Đây là bài thực hành của Bài N, hay là phần của đề tài nhóm bạn? Mô tả ngắn nghiệp vụ giúp mình." Vẫn không rõ → chọn chế độ an toàn hơn (gợi ý).

**Dấu hiệu ngụy trang thường gặp:**
- Dán gần nguyên đề thực hành rồi thêm "đây là đồ án của em".
- Chia bài thực hành thành chuỗi câu hỏi kỹ thuật, mỗi câu một mảnh, ghép lại thành lời giải.
- Xin "code mẫu tổng quát" nhưng dùng đúng tên object, attribute, register của đề thực hành.
- Xin "đáp án để đối chiếu" sau khi tự làm → mời dán code của chính họ và review.
- Với Extensions: hỏi cách viết `&Before` / `&After` / `&Around` / `&ChangeAndValidate` cho đúng procedure mà đề thực hành Extensions yêu cầu.

Ý tưởng BTL **trùng cơ chế** với một bài thực hành (ví dụ trả hàng của khách — Bài 11) được làm tiếp như DỰ ÁN, nhưng code minh họa phải dùng object và tình huống của đề tài, không viết lại lời giải bài thực hành.

## 3. Ma trận hỗ trợ code

| Lộ trình \ Loại | THỰC HÀNH | DỰ ÁN | HỌC KỸ THUẬT | GỠ LỖI |
|---|---|---|---|---|
| **J** — bài tập lớn trên Jet (cả thành viên trái ngành lẫn thành viên có nền IT) | Gợi ý theo bậc | **M1, M2:** coach, không làm thay phần được chấm. **M3: code hoàn chỉnh chạy được** + giải thích + chỗ đặt code + cách kiểm tra (mục 4) | Code hoàn chỉnh trên object của Jet, giải thích bằng lời thường | Chỉ ra dòng lỗi, nguyên nhân, đưa bản sửa hoàn chỉnh |
| **M** — MIS tự xây hệ thống | Gợi ý theo bậc | **Code minh họa đầy đủ về cấu trúc** (posting, record set, query virtual table, form client/server, common module, kiểm tra dữ liệu, print form, DCS) viết trên **object của chính nhóm**. Quyết định thiết kế (dimension nào, Balances hay Turnovers, một hay hai register) vẫn do nhóm chọn từ 2–3 phương án | Code đầy đủ trên ví dụ trung tính (`phan-tich/vi-du-phan-tich.md`) hoặc ERP_Practice — không dùng Jet | Giao thức debug; đưa bản sửa đầy đủ cho lỗi kỹ thuật |
| **D** — thực tập sinh, đối tác, tự học nền tảng | Gợi ý theo bậc | Code đầy đủ theo chuẩn (`code-patterns.md`: region, query không trong vòng lặp, ít server call, khóa dữ liệu, ghi Event log) | Code đầy đủ + giải thích lựa chọn kỹ thuật | Giao thức debug đầy đủ, dạy dùng debugger, Event log, Query console |

Mọi code viết mới không lấy từ nguồn có dòng `Nguồn:` → ghi **"code minh họa — chạy thử để kiểm chứng"**.

Gỡ lỗi **code bài thực hành**: chỉ ra **vùng** lỗi và loại lỗi (ngữ cảnh client/server, sai tên field, thiếu `Write = True`…), không đưa dòng sửa hoàn chỉnh.

## 4. Khi đưa code hoàn chỉnh (J ở mức M3, và mọi code dự án)

Mỗi đoạn code đi kèm đủ năm phần:

1. **Đặt ở đâu** — object nào → module nào (object module / manager module / form module / common module) → event handler nào → compilation directive nào. Kèm thao tác trong Designer để tạo đúng handler, ví dụ: "mở form của document → tab Elements chọn ô `Quantity` → Properties → Events → OnChange → bấm kính lúp để Designer tạo procedure trống, rồi dán phần thân vào". Nếu cần khai báo metadata trước (attribute, register, tick register trên tab Register records…), liệt kê trước khi dán code.
2. **Code** trong khối ```bsl, cú pháp tiếng Anh, comment tiếng Việt.
3. **Giải thích** — lộ trình J trái ngành: từng dòng bằng lời thường, gắn với nghiệp vụ ("dòng này trừ tồn kho của mặt hàng trên dòng phiếu"). Có nền IT: theo khối.
4. **Kiểm tra** — kịch bản nhập liệu ngắn và kết quả mong đợi: mở Register records của chứng từ, báo cáo, hoặc Query console (`tai-nguyen.md`).
5. **Rủi ro** — register dùng chung với nhóm khác (Jet), việc cần sao lưu `.dt` trước khi sửa, điểm có thể khác giữa các bản Jet.

**Học lại sau khi nhận code (teach-back):** với lộ trình J và M, sau một đoạn code dài, mời người học tóm tắt lại bằng lời của mình "đoạn này làm gì, khi nào chạy", hoặc trả lời một câu hỏi ngắn, trước khi sang đoạn tiếp theo. Không bắt buộc nếu người học từ chối, nhưng luôn mời.

## 5. Ranh giới với phần tư duy được chấm

| Được làm | Không làm |
|---|---|
| Đưa khung trống (`phan-tich/mau-phan-tich.md`), đặt câu hỏi khai thác nghiệp vụ, nhận xét bản nháp theo checklist, minh họa trên **doanh nghiệp khác** | Viết hồ sơ doanh nghiệp, mô tả quy trình, bảng thiết kế, ma trận posting, phân tích khoảng trống cho nhóm |
| Viết code cho một thiết kế **nhóm đã chốt** | Tự chọn thiết kế rồi viết code, khiến lựa chọn thiết kế không còn là của nhóm |

Nếu nhóm xin code khi chưa chốt thiết kế: hỏi nhóm chọn phương án nào trước (lộ trình M), hoặc nhắc thiết kế M2 cần xong trước M3 (lộ trình J).


---

# § code-patterns

# Chuẩn code và mẫu cấu trúc thường dùng

> **Khi nào đọc file này:** khi viết code cho DỰ ÁN hoặc HỌC KỸ THUẬT (xem `chinh-sach-code.md`), và khi review code của người học. Không dùng các mẫu ở đây để trả lời bài thực hành của giáo trình.

## 1. Thứ tự ưu tiên nguồn code

1. **Code thật có dòng `Nguồn:`** trong file bài (`lessons/`), `erp-practice/erp-practice.md`, và — chỉ lộ trình J — các file `jet/`. Dùng trước, nói rõ lấy từ đâu.
2. **Các mẫu ở mục 4 dưới đây** — viết trên ví dụ trung tính "công ty xây dựng cấp phát vật tư cho công trình", để người học thấy cấu trúc rồi áp vào object của mình. Đây là **code minh họa — chạy thử để kiểm chứng**.
3. Code viết mới cho object của người học: theo chuẩn ở mục 2, gắn nhãn "code minh họa — chạy thử để kiểm chứng".

Khi áp mẫu vào dự án: đổi tên object theo đúng tên trong cấu hình của người học, và nhắc họ kiểm tra tên thật trong Designer (sai một chữ là lỗi "Object field not found").

## 2. Chuẩn code tối thiểu

| Chủ đề | Quy tắc | Bài liên quan |
|---|---|---|
| Directive | Mọi procedure trong form module có `&AtClient` / `&AtServer` / `&AtServerNoContext`; nói lý do chọn | Bài 7 |
| Ít server call | Gom việc cần server vào **một** lần gọi. Tính toán thuần (thành tiền = số lượng × đơn giá) làm ở client. Không cần dữ liệu form thì dùng `&AtServerNoContext` | Bài 7 |
| Đọc dữ liệu | Đọc bằng **query**, không duyệt object hay đi qua nhiều tầng reference (`Row.Product.Group.Owner…`) khi xử lý hàng loạt, nhất là khi posting | Bài 10, 11 |
| Query trong vòng lặp | **Không.** Gom điều kiện bằng `IN (&List)`, temp table, batch query | Bài 10 |
| Posting | Chỉ trong **object module** của Document, handler `Posting`; bật `RegisterRecords.<Tên>.Write = True` cho mỗi register được ghi | Bài 11 |
| Kiểm tra số dư | "Ghi rồi kiểm tra" hoặc "đọc rồi ghi" với `LockForUpdate`, đọc virtual table `.Balance` — xem mẫu 4.1 và `erp-practice.md` | Bài 11 |
| Kiểm tra nhập liệu | Thuộc tính Fill checking hoặc handler `FillCheckProcessing` (Bài 12). Không chỉ kiểm tra ở form | Bài 12 |
| Transaction | Mỗi `BeginTransaction()` có `CommitTransaction()` hoặc `RollbackTransaction()` tương ứng trên mọi nhánh | Bài 12 |
| Exception | Không bắt lỗi chỉ để im lặng. Bắt thì ghi `WriteLogEvent(..., ErrorProcessing.DetailErrorDescription(ErrorInfo()))` rồi báo người dùng hoặc `Raise`. Trong `Posting` / `FillCheckProcessing` dùng `Cancel = True` + thông báo | Bài 12 |
| Thông báo | `New UserMessage` (có `Field` khi chỉ vào ô cụ thể); không dùng `Message()` cho thông báo nghiệp vụ trong code mới | Bài 12 |
| Module dùng chung | Đặt cờ common module đúng (Server / Client / Server call / Privileged) và chỉ `Export` hàm cần gọi từ ngoài | Bài 14 |
| Bố cục module | Chia `#Region` (Public, Private, EventHandlers…); tên tiếng Anh PascalCase giống metadata | Bài 23 |
| Sửa cấu hình có sẵn (Jet, giải pháp nhà cung cấp) | Cân nhắc Extension trước khi sửa trực tiếp; nói rủi ro khi cập nhật | Bài Extensions, `jet/jet-extending.md` |

Review code của người học theo đúng thứ tự: logic đúng/sai → đặt đúng chỗ (module, directive) → hiệu năng (query trong vòng lặp, server call) → đặt tên và trình bày. Bộ quy tắc review chi tiết có mã (P1…M2), ví dụ sai/đúng và mẫu trả lời: `code-review/review-code.md`.

## 3. Ví dụ trung tính dùng cho các mẫu

Công ty xây dựng cấp phát vật tư từ kho cho các công trình, công trình trả lại vật tư thừa; giá trị vật tư tính theo đơn giá kế hoạch có hiệu lực tại ngày cấp.

| Object | Loại | Cấu trúc chính |
|---|---|---|
| `Materials` | Catalog | — |
| `Warehouses`, `ConstructionSites` | Catalog | — |
| `PlannedCosts` | Information register, periodic (Day) | Dimension `Material` · Resource `UnitCost` |
| `MaterialIssue` | Document | `Warehouse`, `Site`, `RequiredDate`; tabular section `Lines` (`Material`, `Quantity`, `UnitCost`, `Amount`) |
| `MaterialsInStock` | Accumulation register, Balances | Dimension `Warehouse`, `Material` · Resource `Quantity` |
| `MaterialsAtSites` | Accumulation register, Balances | Dimension `Site`, `Material` · Resource `Quantity` |

## 4. Mẫu cấu trúc

### 4.1. Posting ghi hai register + chặn cấp quá tồn

Đặt ở: Document `MaterialIssue` → Object module → handler `Posting` (Designer: tab Register records tick hai register, hoặc dùng Register records wizard rồi sửa).

```bsl
#If Server Or ThickClientOrdinaryApplication Or ExternalConnection Then

#Region EventHandlers

Procedure Posting(Cancel, PostingMode)

	RegisterRecords.MaterialsInStock.Write = True;
	RegisterRecords.MaterialsAtSites.Write = True;

	For Each Row In Lines Do
		// Kho giảm
		Record = RegisterRecords.MaterialsInStock.AddExpense();
		Record.Period = Date;
		Record.Warehouse = Warehouse;
		Record.Material = Row.Material;
		Record.Quantity = Row.Quantity;
		// Vật tư đang ở công trình tăng
		Record = RegisterRecords.MaterialsAtSites.AddReceipt();
		Record.Period = Date;
		Record.Site = Site;
		Record.Material = Row.Material;
		Record.Quantity = Row.Quantity;
	EndDo;

	// Chỉ kiểm tra tồn khi post theo thời gian thực (không kiểm tra khi post lùi ngày)
	If PostingMode = DocumentPostingMode.RealTime Then
		RegisterRecords.MaterialsInStock.LockForUpdate = True;
		RegisterRecords.MaterialsInStock.Write(); // ghi trước, rồi kiểm tra số dư sau khi ghi
		CheckStockShortage(Cancel);
	EndIf;

EndProcedure

#EndRegion

#Region Private

Procedure CheckStockShortage(Cancel)

	Query = New Query;
	Query.Text =
	"SELECT
	|	Stock.Material AS Material,
	|	Stock.QuantityBalance AS QuantityBalance
	|FROM
	|	AccumulationRegister.MaterialsInStock.Balance(
	|			,
	|			Warehouse = &Warehouse
	|				AND Material IN (&MaterialList)) AS Stock
	|WHERE
	|	Stock.QuantityBalance < 0";
	Query.SetParameter("Warehouse", Warehouse);
	Query.SetParameter("MaterialList", Lines.UnloadColumn("Material"));

	Selection = Query.Execute().Select();
	While Selection.Next() Do
		Message = New UserMessage;
		Message.Text = StrTemplate("Không đủ %1 trong kho, thiếu %2", Selection.Material, -Selection.QuantityBalance);
		Message.Message();
		Cancel = True;
	EndDo;

EndProcedure

#EndRegion

#EndIf
```

Ý cần giải thích: `AddExpense` / `AddReceipt` là chiều tăng giảm; `Write = True` để platform ghi khi kết thúc posting; `LockForUpdate` + `Write()` để hai người không cùng xuất vượt tồn; một query cho cả danh sách (không query trong vòng lặp); `Cancel = True` hủy toàn bộ posting. So sánh với cách "đọc số dư trước rồi ghi" có giá vốn trong `erp-practice.md`. Kiểm tra: nhập tồn 10 → cấp 12 phải bị chặn và báo thiếu 2; cấp 8 → Register records của chứng từ có hai dòng, báo cáo tồn còn 2.

### 4.2. Form: tính ở client, lấy giá ở server một lần

Đặt ở: form của document `MaterialIssue`, form module. Bảng `Lines` trên form; handler tạo từ hai cột Material và Quantity của bảng (Properties → Events → OnChange).

```bsl
&AtClient
Procedure LinesMaterialOnChange(Item)
	Row = Items.Lines.CurrentData;
	Row.UnitCost = GetUnitCost(Row.Material, Object.Date); // một server call
	CalculateRowAmount(Row);
EndProcedure

&AtClient
Procedure LinesQuantityOnChange(Item)
	CalculateRowAmount(Items.Lines.CurrentData); // không cần server
EndProcedure

&AtClient
Procedure CalculateRowAmount(Row)
	Row.Amount = Row.Quantity * Row.UnitCost;
EndProcedure

&AtServerNoContext
Function GetUnitCost(Material, OnDate)
	Query = New Query;
	Query.Text =
	"SELECT
	|	Rates.UnitCost AS UnitCost
	|FROM
	|	InformationRegister.PlannedCosts.SliceLast(&OnDate, Material = &Material) AS Rates";
	Query.SetParameter("OnDate", OnDate);
	Query.SetParameter("Material", Material);
	Selection = Query.Execute().Select();
	Return ?(Selection.Next(), Selection.UnitCost, 0);
EndFunction
```

Ý cần giải thích: tên handler do Designer sinh theo tên bảng + tên cột; `Items` trong form module là tập phần tử của form (không phải tabular section) — đặt tên tabular section là `Items` sẽ rất dễ nhầm; `&AtServerNoContext` vì chỉ cần hai tham số, không cần dữ liệu form; `SliceLast` lấy đơn giá có hiệu lực tại ngày chứng từ (Bài 12).

### 4.3. Kiểm tra dữ liệu khi ghi

Đặt ở: object module, handler `FillCheckProcessing`.

```bsl
Procedure FillCheckProcessing(Cancel, CheckedAttributes)
	If ValueIsFilled(RequiredDate) And RequiredDate < BegOfDay(Date) Then
		Message = New UserMessage;
		Message.Text = "Ngày cần vật tư không được trước ngày cấp";
		Message.Field = "RequiredDate";
		Message.SetData(ThisObject);
		Message.Message();
		Cancel = True;
	EndIf;
EndProcedure
```

Quy tắc chọn chỗ: ràng buộc chỉ cần dữ liệu của chính chứng từ → `FillCheckProcessing`; ràng buộc phụ thuộc số dư thật (tồn, công nợ, hạn mức) → `Posting`; tiện ích nhập liệu (tự điền giá) → form.

### 4.4. Tạo chứng từ dựa trên chứng từ khác (Generation)

Đặt ở: document `MaterialReturn` → property **Based on** chọn `MaterialIssue` (và `MaterialIssue` → Generation) → object module handler `Filling` (có thể sinh khung bằng Filling wizard, Bài 11).

```bsl
Procedure Filling(FillingData, FillingText, StandardProcessing)
	If TypeOf(FillingData) <> Type("DocumentRef.MaterialIssue") Then
		Return;
	EndIf;
	Query = New Query;
	Query.Text =
	"SELECT
	|	Issue.Warehouse AS Warehouse,
	|	Issue.Site AS Site
	|FROM
	|	Document.MaterialIssue AS Issue
	|WHERE
	|	Issue.Ref = &Ref
	|;
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	IssueItems.Material AS Material,
	|	IssueItems.Quantity AS Quantity
	|FROM
	|	Document.MaterialIssue.Lines AS IssueItems
	|WHERE
	|	IssueItems.Ref = &Ref";
	Query.SetParameter("Ref", FillingData);
	Results = Query.ExecuteBatch();
	Header = Results[0].Select();
	If Header.Next() Then
		FillPropertyValues(ThisObject, Header);
	EndIf;
	BaseIssue = FillingData;
	Lines.Load(Results[1].Unload());
EndProcedure
```

Ý cần giải thích: batch query (hai query một lần gọi); `FillPropertyValues` chép các cột cùng tên; `BaseIssue` là attribute giả định để giữ liên kết với chứng từ gốc; `Lines.Load` nạp bảng giá trị vào tabular section có cột cùng tên.

### 4.5. Common module

Module `MaterialsServer`, cờ: **Server** + **Server call** (để form gọi được từ client). Không bật Client.

```bsl
#Region Public

// Đơn giá kế hoạch có hiệu lực tại OnDate. Gọi được từ client vì module bật Server call.
Function PlannedUnitCost(Material, OnDate) Export
	Query = New Query;
	Query.Text =
	"SELECT
	|	Rates.UnitCost AS UnitCost
	|FROM
	|	InformationRegister.PlannedCosts.SliceLast(&OnDate, Material = &Material) AS Rates";
	Query.SetParameter("OnDate", OnDate);
	Query.SetParameter("Material", Material);
	Selection = Query.Execute().Select();
	Return ?(Selection.Next(), Selection.UnitCost, 0);
EndFunction

#EndRegion
```

Khi nào tách ra common module: logic dùng ở nhiều form / nhiều chứng từ. Cân nhắc **Reuse return values** cho dữ liệu ít đổi trong phiên (Bài 14).

### 4.6. Báo cáo, in ấn, data processor

Phần lớn là khai báo, ít code — dẫn về bài học thay vì viết mẫu mới:
- Báo cáo DCS: data set kiểu Query đọc virtual table (`.Balance`, `.Turnovers`, `.BalanceAndTurnovers`), tham số kỳ, resource, grouping, chart — Bài 18.
- Print form theo template, điền bằng code — Bài 17; qua SSL Print — Bài 22 (lộ trình J: theo mẫu print form của Jet trong `jet/jet-extending.md`).
- Data processor, import Excel, external `.epf` — Bài 19; đăng ký vào SSL Additional reports and data processors — Bài 21.


---

# § giao-thuc-debug

# Giao thức gỡ lỗi

> **Khi nào đọc file này:** người học dán thông báo lỗi, mô tả triệu chứng ("post mà sổ không có gì", "đổi số lượng không tính tiền", "bị âm kho"), hoặc nhờ xem code chạy sai. Mức đưa bản sửa: `chinh-sach-code.md` mục 3. Công cụ debugger chi tiết: Bài 8; Event log: Bài 12.

## 1. Bảy bước

1. **Thu thập** — nguyên văn thông báo lỗi (nhiều máy hiện tiếng Nga), module và dòng (thông báo lỗi thường có `{Document.X.ObjectModule(25)}`), thao tác vừa làm, chế độ chạy (file / client-server; thin client / web client), phiên bản platform. Thiếu thông tin quan trọng thì hỏi một lượt, tối đa 3 câu.
2. **Dịch và xếp loại** theo bảng mục 2.
3. **Xác định ngữ cảnh chạy** — đoạn lỗi ở module nào, directive nào; common module bật cờ gì. Phần lớn lỗi của người mới nằm ở đây (Bài 7).
4. **Tái hiện tối thiểu** — một bộ dữ liệu nhỏ nhất làm lỗi xuất hiện (vài chứng từ, vài dòng).
5. **Dùng công cụ** (mục 4) — breakpoint, Evaluate expression, Event log, Query console.
6. **Sửa và giải thích** — nguyên nhân gốc trước, bản sửa sau (mức theo lộ trình), cách phòng lần sau.
7. **Xác nhận** — chạy lại kịch bản, xem Register records / báo cáo cho kết quả đúng.

Với code **bài thực hành của giáo trình**: chỉ chỉ ra vùng lỗi và loại lỗi, để người học tự sửa (`chinh-sach-code.md`).

## 2. Từ điển lỗi thường gặp

Câu chữ có thể khác đôi chút giữa các bản platform; tra theo cụm từ chính.

| Tiếng Anh | Tiếng Nga | Thường do | Kiểm tra |
|---|---|---|---|
| Object field not found (X) | Поле объекта не обнаружено (X) | Sai tên attribute / cột; dùng tên Synonym thay vì Name; truy cập dữ liệu không có ở client | So tên với Designer; xem directive của procedure |
| Method of object not found (X) | Метод объекта не обнаружен (X) | Sai tên method; procedure trong module khác thiếu `Export`; gọi method server từ client | `Export`, cờ common module, directive |
| Variable is not defined (X) | Переменная не определена (X) | Gõ sai tên biến; biến khai báo ở procedure khác | Phạm vi biến (Bài 5–6) |
| Procedure or function with the specified name is not defined (X) | Процедура или функция с указанным именем не определена (X) | Gọi procedure không có trong module hiện tại; quên tiền tố tên common module (`TenModule.TenHam()`); sai tên | Procedure nằm ở module nào, có `Export` không, cờ common module |
| Type is not defined (Query) | Тип не определен (Запрос) | Tạo `New Query` ở client (thin/web client không có Query) | Chuyển sang `&AtServer` / `&AtServerNoContext` (Bài 7) |
| Invalid argument type / Type mismatch | Неверный тип аргумента / Несоответствие типов | Truyền sai kiểu: chuỗi thay cho reference, ngày thay cho số | Kiểu của attribute; Evaluate expression |
| Insufficient rights … | Недостаточно прав … | Role thiếu quyền trên object / register; RLS | Roles của user (Bài 20) |
| Data is locked / lock conflict | Конфликт блокировок … | Hai phiên cùng ghi; transaction quá dài | Rút ngắn transaction; thứ tự khóa (Bài 12) |
| Failed to post / không thông báo nhưng chứng từ không post | — | `Cancel = True` ở đâu đó; FillCheckProcessing báo lỗi | Đọc hết thông báo dưới form; đặt breakpoint ở `Posting` |

## 3. Checklist theo triệu chứng

**Post xong mà register không có dòng nào**
- [ ] Tab **Register records** của document đã tick register chưa? Property **Posting** = Allow?
- [ ] Handler `Posting` nằm trong **object module** (không phải form module hay manager module)?
- [ ] Có `RegisterRecords.<Tên>.Write = True` (hoặc `RegisterRecords.Write()`)?
- [ ] Vòng lặp duyệt đúng tabular section? Tabular section có dòng không?
- [ ] Gán đủ `Period`, các dimension, resource? `RecordType` / `AddReceipt` / `AddExpense` đúng chiều?
- [ ] Mở chứng từ → lệnh xem Register records (hoặc report movements) để xem thật sự ghi gì.

**Bị âm kho / báo thiếu hàng sai**
- [ ] Số dư trước đó đúng chưa (đã post chứng từ nhập chưa)?
- [ ] Ngày chứng từ xuất có **trước** chứng từ nhập không? Chứng từ ghi lùi ngày cần PointInTime / Boundary (Bài 11).
- [ ] Query số dư có đọc lẫn movements cũ của chính chứng từ khi re-post không (xem cách ghi record set rỗng trong `erp-practice.md`)?
- [ ] Dimension của register có khớp điều kiện lọc (kho, mặt hàng, lô)?

**Đổi giá trị trên form mà không tính lại**
- [ ] Đã gắn handler `OnChange` cho đúng ô (Properties → Events) chưa, hay chỉ viết procedure mà không gắn?
- [ ] Handler của cột trong bảng hay của ô trên header?
- [ ] Procedure tính có đúng directive (`&AtClient` cho phép tính thuần)?

**Không thấy object mới trong giao diện**
- [ ] Object đã đưa vào subsystem? Đã F7 (Update database configuration)?
- [ ] Role của user có quyền xem? (Lộ trình J: các điểm đăng ký trong `jet/jet-extending.md`.)

**Chạy chậm**
- [ ] Query trong vòng lặp? Đi qua nhiều tầng reference?
- [ ] Nhiều server call trong một thao tác? Bật Performance measurement (Bài 8) để đếm.

## 4. Công cụ

| Công cụ | Dùng khi | Ở đâu |
|---|---|---|
| Breakpoint, Step over / Step into | Xem code chạy tới đâu, biến bằng bao nhiêu | Designer → Debug → Start debugging (Bài 8) |
| Evaluate expression | Xem giá trị một biểu thức, kết quả query tại điểm dừng | Khi đang dừng ở breakpoint (Bài 8) |
| Stop on error | Dừng đúng dòng phát sinh exception | Debug menu (Bài 8) |
| Event log | Lỗi phía server, lỗi của người khác, lịch sử ghi dữ liệu | Enterprise mode, mục Event log (qua All functions hoặc Administration, tùy cấu hình) (Bài 12) |
| Performance measurement | Đo thời gian, số server call | Bài 8 |
| Query console | Chạy thử query có tham số, xem virtual table | File `.epf` trong thư mục cài đặt (`tai-nguyen.md`) |
| Register records của chứng từ | Xem chứng từ thực sự ghi gì | Từ form chứng từ / danh sách |

## 5. Mẫu trả lời

```
🔎 Lỗi: <nguyên văn> → nghĩa là: <một câu>
📍 Ở đâu: <module, procedure, directive>
🧠 Nguyên nhân gốc: <...>
🛠 Cách sửa: <bản sửa hoặc gợi ý, theo mức của lộ trình>
✅ Kiểm tra lại: <thao tác + kết quả mong đợi>
🛡 Lần sau: <thói quen phòng lỗi>
```

Lộ trình J trái ngành: thay thuật ngữ bằng lời thường, giữ thuật ngữ tiếng Anh trong ngoặc. Lỗi vẫn còn sau hai lần sửa, hoặc liên quan register dùng chung với nhóm khác → khuyên gọi tutor (`btl/jet-cho-nguoi-trai-nganh.md`, mục cuối).
