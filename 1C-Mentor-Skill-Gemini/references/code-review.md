# Tài liệu gộp: code-review

Gồm các mục: § review-code, § loi-da-biet, § chuan-phat-trien, § nguon-ngoai, § ssl-api-en, § thuat-ngu-ru-en


---

# § review-code

# Review và tư vấn code 1C — bộ quy tắc rút từ mã nguồn thật

> **Khi nào đọc file này:** người dùng dán code nhờ xem / sửa / tối ưu, hỏi "code này viết vậy được chưa", "có cách nào tốt hơn", hoặc nhờ tư vấn cách viết một kỹ thuật. Đọc cùng `chinh-sach-code.md` (được đưa code tới mức nào) và `code-patterns.md` (mẫu cấu trúc đầy đủ). Lỗi đã biết trong code mẫu của khóa và ERP_Practice: `code-review/loi-da-biet.md`. Chuẩn chính thức của 1C để dẫn chứng (#stdNNN): `code-review/chuan-phat-trien.md`. Code cú pháp tiếng Nga: `code-review/thuat-ngu-ru-en.md`. Tên API SSL tiếng Anh: `code-review/ssl-api-en.md`.
>
> Các quy tắc dưới đây rút từ việc đọc toàn bộ mã nguồn các repo của khóa (45 nhánh `1CJDCourse`, `ERP_Practice`, các bài làm thật của thực tập sinh) — mỗi quy tắc là một lỗi **đã thực sự xuất hiện** ở đó. Ví dụ viết trên đề trung tính "cấp phát vật tư cho công trình" của `code-patterns.md` mục 3, **không** phải lời giải bài thực hành. Mọi đoạn sửa là **code minh họa — chạy thử để kiểm chứng**.

## 1. Quy trình review

1. **Phân loại** theo `chinh-sach-code.md` mục 2. Nếu code là bài THỰC HÀNH (24 bài, Extensions, Intern Task, Partner Exam): chỉ nêu **vùng** và **mã quy tắc** (ví dụ "dòng 40–55 vi phạm P3 — đọc lại mục đó"), không đưa dòng sửa.
2. **Hỏi thiếu gì thì hỏi một lần:** tên module (object / manager / form / common), metadata liên quan (dimension, resource, thuộc tính `Delete records`, `Write register records on posting`), chế độ khóa của cấu hình (Managed / Automatic), có SSL không. Nhiều lỗi ở mục 2 chỉ kết luận được khi biết metadata.
3. **Đọc theo thứ tự** (giống `code-patterns.md` mục 2): đúng / sai về nghiệp vụ và dữ liệu → đặt đúng chỗ (module, handler, directive) → đồng thời và khóa → hiệu năng → chuẩn và trình bày.
4. **Trả lời theo bảng** `Vị trí | Mã quy tắc | Vấn đề | Vì sao | Sửa`, lỗi nặng trước. Tối đa 5–7 dòng; phần nhỏ gộp thành một câu "dọn dẹp".
5. **Kết thúc bằng cách tự kiểm**: kịch bản nhập liệu ngắn, xem Register records / Query console / Event log (`debug/giao-thuc-debug.md`).

Mức độ: **Nặng** = sai số liệu kho, tiền, sổ sách hoặc lỗi runtime trên luồng chính · **Vừa** = sai trong tình huống biên, hiệu năng đáng kể, đồng thời · **Nhẹ** = chuẩn, đặt tên, dọn dẹp.

## 2. Bộ quy tắc

### P — Posting và register (Bài 11, 12, 15, 16, 24)

**P1 · Nặng · Dấu và RecordType.** Xuất kho là `Expense` (hoặc `AddExpense()`), nhập là `Receipt`. Chứng từ đảo / trả lại: chọn **một** quy ước và dùng nhất quán — hoặc RecordType ngược lại với số dương, hoặc cùng RecordType với số âm (storno). Register Turnovers (doanh thu) của chứng từ trả lại phải mang số **âm**. Lỗi thật đã gặp: bán hàng ghi `Receipt` (tồn tăng khi bán); trả hàng cộng thêm doanh thu; hai nhánh của cùng một procedure dùng hai quy ước dấu khác nhau.

**P2 · Nặng · Movement cũ khi post lại.** Kiểm tra thuộc tính `Delete records` của document. Với `Delete automatically on unposting` và `Write selected`, procedure `Posting` nào có nhánh `Return` sớm (ví dụ "trạng thái Kế hoạch thì không ghi") sẽ để lại movement cũ khi post lại.
```bsl
// Cách 1: Designer → document → Delete records = Delete automatically (xóa mỗi lần post lại)
// Cách 2: luôn bật Write = True trước khi Return — record set rỗng sẽ được ghi, tức là xóa movement cũ
RegisterRecords.MaterialsInStock.Write = True;
RegisterRecords.MaterialsAtSites.Write = True;
If Not MustPost Then
	Return;
EndIf;
```

**P3 · Nặng · Biên thời điểm khi đọc số dư.**
- **Phân bổ** (FIFO / LIFO / bình quân) — đọc **trước** khi ghi: `Balance(&PointInTime, ...)` với `PointInTime()` hoặc `New Boundary(PointInTime(), BoundaryType.Excluding)`, và movement cũ của chính chứng từ phải đã bị xóa (P2, hoặc ghi record set rỗng trước khi đọc).
- **Kiểm tra âm** — ghi **trước** rồi đọc: `RegisterRecords.X.Write()` → `Balance(New Boundary(PointInTime(), BoundaryType.Including), ...) WHERE QuantityBalance < 0`.
- Không truyền ngày (`Balance(, ...)`) = số dư **hiện tại**: post lại chứng từ quá khứ sẽ tính trên số dư hôm nay (lỗi thật trong ERP_Practice).
- Procedure kiểm tra viết xong phải **được gọi** (lỗi thật: procedure kiểm tra tồn có sẵn nhưng `Posting` không gọi).

**P4 · Nặng · Phân bổ theo lô: chỉ lấy lô còn dương, xử lý dòng không có tồn.**
```bsl
|	LEFT JOIN AccumulationRegister.MaterialsInStock.Balance(&PointInTime,
|			Material IN (SELECT T.Material FROM Lines AS T) AND Warehouse = &Warehouse) AS Stock
|	ON Lines.Material = Stock.Material
|		AND Stock.QuantityBalance > 0          // lô âm / bằng 0 không được phân bổ
...
Take = Min(Left, Selection.QuantityBalance);
If Take <= 0 Then
	Continue;                                   // không ghi record số lượng 0, lô rỗng
EndIf;
```
Sắp xếp lô theo `Batch.PointInTime` (không chỉ `Batch.Date` — hai chứng từ cùng giây cho thứ tự không xác định). Còn thiếu sau vòng lặp (`Left > 0`) → báo lỗi + `Cancel = True`.

**P5 · Vừa · Lấy hết lô thì lấy hết tiền.** Giá vốn = `AmountBalance / QuantityBalance` rồi nhân lại sẽ để dư tiền lẻ ở lô đã hết hàng.
```bsl
If Take = Selection.QuantityBalance Then
	Record.Amount = Selection.AmountBalance;
Else
	Record.Amount = Round(Selection.AmountBalance * Take / Selection.QuantityBalance, 2);
EndIf;
```
Chia trong query phải chặn 0: `CASE WHEN QuantityBalance = 0 THEN 0 ELSE AmountBalance / QuantityBalance END`.

**P6 · Vừa · Khóa dữ liệu (Managed lock mode).** Đọc số dư để phân bổ hoặc kiểm tra mà không khóa → hai phiên post cùng lúc đọc cùng một số dư. `LockForUpdate` trên record set rỗng chỉ chắc chắn khóa theo Recorder của chính chứng từ; chuẩn là `DataLock` tường minh **trước** query đọc số dư:
```bsl
Lock = New DataLock;
Item = Lock.Add("AccumulationRegister.MaterialsInStock");
Item.Mode = DataLockMode.Exclusive;
Item.SetValue("Warehouse", Warehouse);
Item.DataSource = Lines;                       // tabular section hoặc ValueTable
Item.UseFromDataSource("Material", "Material");
Lock.Lock();
```

**P7 · Vừa · Đủ dimension, đúng resource.** Mỗi record ghi đủ mọi dimension (thiếu một dimension = số dư lệch sang "giá trị rỗng"). Resource của register **Balances** là thứ cộng dồn được (số lượng, **giá trị**) — không ghi đơn giá, số km, trạng thái vào đó. Ghi một thuộc tính (Company, Site…) cho **mọi** nhánh / mọi tabular section, không chỉ một bảng.

**P8 · Vừa · Lọc trong tham số virtual table, không trong WHERE.** `Balance(&Date, Material IN (&List) AND Warehouse = &Warehouse)` thay vì đọc cả register rồi `WHERE` hoặc lặp tìm bằng code. `SliceLast(&Date, Material = &Material)` — luôn truyền ngày chứng từ (không truyền = giá hiện tại cho chứng từ quá khứ). `Turnovers(&Begin, &End, , ...)`: để trống periodicity khi cần **tổng** — periodicity `Period` / `Recorder` trả **nhiều dòng** mỗi mặt hàng, gán vào một ô thì chỉ giữ dòng cuối (lỗi thật).

**P9 · Vừa · Đọc movement của một chứng từ cụ thể:** đọc **bảng vật lý** của register theo `Recorder = &Doc` (có index), không dùng `Turnovers(...)` cả ngày rồi lọc Recorder. Kiểm tra chứng từ gốc đã điền trước khi dereference `Doc.Date`.

**P10 · Nhẹ · Sửa tay trong khối wizard.** Code đã sửa tay nằm giữa `//{{__REGISTER_REGISTERRECORDS_WIZARD` … `//}}` sẽ mất khi chạy lại wizard. Sửa tay thì xóa marker.

### Q — Query và hiệu năng (Bài 10, 11, 19)

**Q1 · Vừa · Không query trong vòng lặp** — kể cả query ẩn: `Catalogs.X.FindByDescription`, `FindByCode`, dereference `Row.Material.Group.Description` (mỗi lần đọc cả object), `Ref.Attribute` để lấy giá trị cũ trong `BeforeWrite`. Gom về một query `IN (&List)` rồi tra bằng `Map`:
```bsl
Query = New Query("SELECT M.Description AS Description, M.Ref AS Ref
	|FROM Catalog.Materials AS M WHERE M.Description IN (&Names) AND NOT M.DeletionMark");
Query.SetParameter("Names", Names);
RefsByName = New Map;
Selection = Query.Execute().Select();
While Selection.Next() Do
	RefsByName.Insert(Selection.Description, Selection.Ref);
EndDo;
```
Ngoại lệ hợp lý: `GetObject()` trong vòng lặp khi **phải** sửa và ghi từng object — khi đó bọc transaction và xử lý lỗi từng object (T1).

**Q2 · Vừa · Tabular section làm nguồn bảng của query:** truyền `.Unload(, "Cột1, Cột2")` (ValueTable), ép kiểu trong query: `CAST(T.Material AS Catalog.Materials)`. Dùng temp table khi một tập dòng được dùng nhiều lần.

**Q3 · Vừa · Duyệt theo nhóm cần `TOTALS ... BY`** và `Select(QueryResultIteration.ByGroups)`; không có TOTALS thì `Select()` của cấp con rỗng.

**Q4 · Nhẹ · `ExecuteBatch()` + `FindNext(Filter)` / `Reset()`** để tra nhiều lần trên cùng một kết quả thay vì chạy lại query.

**Q5 · Vừa · Trong in ấn / báo cáo:** lấy mọi thứ cần in (kể cả logo, thông tin công ty) trong **query chính** hoặc cache `Map` theo khóa; `Template.GetArea(...)` đặt **ngoài** vòng lặp chứng từ; `ORDER BY` để in đúng thứ tự.

### F — Form và client/server (Bài 7, 9, 10, 16)

**F1 · Vừa · Tính ở client, lấy dữ liệu ở server một lần.** Thành tiền, tổng chứng từ (`Object.Lines.Total("Amount")`) tính ở client. Đổi một dòng cần giá + giá sàn → **một** hàm `&AtServerNoContext` trả `Structure`, không hai lần gọi. Không gọi `&AtServer` (kèm cả form) chỉ để đọc một thuộc tính.

**F2 · Nặng · `BeforeWriteAtServer(Cancel, CurrentObject, WriteParameters)`: ghi vào `CurrentObject`**, không vào `Object` — giá trị gán vào `Object` lúc này không được lưu (lỗi thật: địa chỉ giao hàng không bao giờ được ghi).

**F3 · Vừa · Thêm dòng bằng code không gọi `OnChange` của bảng** → tự gọi lại tính dòng và tính tổng sau `Add()` trong `ChoiceProcessing` / nút Fill.

**F4 · Vừa · Tên tham số `OpenForm` là chuỗi** — viết sai (`CloseOnChoise`) không có lỗi biên dịch, chỉ bị bỏ qua lặng lẽ. Chọn **một** kênh trả kết quả: owner + `ChoiceProcessing`, **hoặc** `CallbackDescription`. Tham số `Filter` của form chọn chỉ áp lên **trường** của danh sách; giá trị dùng làm tham số query của dynamic list thì truyền qua `Parameters` của form rồi `List.Parameters.SetParameterValue(...)`.

**F5 · Nặng · Handler mồ côi.** Xóa procedure trong module nhưng event vẫn gán trong form (Properties → Events) → lỗi khi event xảy ra, và mất luôn logic đáng lẽ chạy (ví dụ kiểm tra giá sàn khi sửa giá tay). Ngược lại: viết handler nhưng quên gán event → code không bao giờ chạy. Kiểm bằng *Configuration → Check* hoặc rà tab Events.

**F6 · Nặng · Không gọi modal khi cấu hình đặt `Modality use mode = Do not use`:** `DoMessageBox`, `DoQueryBox`, `OpenFormModal`, `InputValue`, `Предупреждение`, `Вопрос`… → dùng `ShowMessageBox`, `ShowQueryBox`, `ShowInputValue` + `CallbackDescription`. Có nhánh không cần hỏi thì `RunCallback(Callback, DialogReturnCode.Yes)` để chỉ còn một luồng xử lý.

**F7 · Vừa · Không gọi server trong `OnOpen`** — tính trong `OnCreateAtServer` / `OnReadAtServer`. Trên client không có `CurrentSessionDate()`; truyền ngày từ server hoặc dùng `CommonClient.SessionDate()` (SSL).

**F8 · Nhẹ · `OnActivateRow` đổi tham số danh sách con:** dùng `AttachIdleHandler("UpdateDetails", 0.2, True)` để không query mỗi lần nhấn mũi tên; kiểm `CurrentData = Undefined`.

**F9 · Nhẹ · Ghi giá trị trước khi xóa:** lưu giá trị cần báo vào biến **trước** khi `CurrentData.X = Undefined`, nếu không thông báo luôn rỗng.

### V — Kiểm tra dữ liệu và thông báo (Bài 12, 15, 16)

**V1 · Nặng · `FillCheckProcessing`: báo lỗi phải kèm `Cancel = True`;** không gọi `CheckFilling()` bên trong (đệ quy). Bỏ kiểm tra có điều kiện bằng cách xóa khỏi `CheckedAttributes` (`DeleteAttributeFromChecking` của SSL, hoặc `CheckedAttributes.Delete(...)`).

**V2 · Vừa · Thông báo gắn ô:** `New UserMessage` + `Field` (`"Lines[" + Format(Index, "NZ=0; NG=0") + "].Quantity"`) + `SetData(ThisObject)`; với SSL dùng `Common.MessageToUser` / `CommonClient.MessageToUser`. `Message()` chỉ chấp nhận trong demo, debug.

**V3 · Vừa · Kiểm tra cặp trường:** chỉ so khi cả hai đã điền (`If ValueIsFilled(A) And A = B`), nếu không người dùng nhận thông báo "trùng" khi thực ra là "chưa điền".

**V4 · Vừa · `Filling` / event subscription không ghi đè:** `If Not ValueIsFilled(Source.Company) Then ... EndIf` — giá trị từ `FillingValues` hoặc chứng từ cơ sở phải được giữ. Chữ ký chuẩn: `Filling(FillingData, FillingText, StandardProcessing)`; `FillingData` của Generation đã là Ref (không `.Ref`).

**V5 · Vừa · `BeforeWrite` / `OnWrite`:** kiểm `DataExchange.Load` ở đầu (`If DataExchange.Load Then Return; EndIf;`); truyền trạng thái "mới" / giá trị cũ sang `OnWrite` / `Posting` bằng `AdditionalProperties` (lúc đó `IsNew()` đã là False). Giá trị cũ đọc bằng một query một trường, không `Ref.Attribute`.

### T — Transaction, lỗi, log (Bài 8, 12)

**T1 · Nặng · Mẫu transaction chuẩn:**
```bsl
BeginTransaction();
Try
	// khóa (DataLock) → đọc → ghi các object
	CommitTransaction();
Except
	RollbackTransaction();
	WriteLogEvent("MyApp.Import", EventLogLevel.Error, , ,
		ErrorProcessing.DetailErrorDescription(ErrorInfo()));
	Raise;                                   // ném lại lỗi GỐC, không Raise "chuỗi mới"
EndTry;
```
Lỗi thật đã gặp: thiếu `RollbackTransaction` trên một nhánh; `Raise "Có lỗi"` làm mất lỗi gốc; commit khi object chính chưa `Write()`; tạo nhiều chứng từ / record set không transaction → chạy giữa chừng lỗi để lại dữ liệu nửa vời; chạy lại tạo trùng (cần tìm và dùng lại kết quả cũ).

**T2 · Vừa · `Except` không được im lặng:** log + báo người dùng (hoặc `Raise`). Trong `Posting` / `FillCheckProcessing` dùng `Cancel = True` + thông báo thay vì `Raise`.

**T3 · Vừa · Hàm "không được ném exception"** (theo đề / hợp đồng hàm) phải `Return` ngay khi tham số sai, và trả đúng kiểu đã hứa (chuỗi lỗi, không Structure).

### X — File, Excel, external (Bài 19, 21–23)

**X1 · Vừa · Địa chỉ ô bằng số:** `Spreadsheet.Area(Row, Col, Row, Col)` hoặc `"R" + Format(Row, "NG=0") + "C" + Format(Col, "NG=0")`. `"R" + Row` sai từ dòng 1000 (thành `R1 000C2` / `R1,000C2` tùy locale).

**X2 · Vừa · Đọc giá trị số bằng `.Value`** (đọc file ở chế độ `SpreadsheetDocumentValuesReadingMode.Value`), không `.Text` (chuỗi đã định dạng); kiểm `TypeOf(Value) = Type("Number")` trước khi ghi vào trường số. So tiêu đề cột không phân biệt hoa thường: `Upper(TrimAll(...))`.

**X3 · Vừa · File từ máy người dùng:** `BeginPutFileToServer` / `PutFileToServerAsync` → temp storage → server đọc từ `GetFromTempStorage`. Không đọc đường dẫn client ở server; `New BinaryData(FileName)` ở client không chạy trên web client. Xóa file tạm trong `Try`.

**X4 · Vừa · In SSL:** `PrintCommand.ID` khớp tên trong `Print()`; `PrintManagement.PrintFormTemplate("Document.X.PF_MXL_Name")` / `"CommonTemplate.Name"`; `PutHorizontalPageBreak` từ chứng từ thứ 2; `PrintManagement.SetDocumentPrintArea` sau mỗi chứng từ; lọc query theo `ObjectsArray` (lỗi thật: in mọi chứng từ). Kiểm chữ ký `OutputSpreadsheetDocumentToCollection` theo đúng phiên bản SSL đang dùng.

**X5 · Nhẹ · Nội dung SSL:** sửa trong module `...Overridable` / khối `// StandardSubsystems.*`, không sửa module lõi; module có `Common.SubsystemExists(...)` ở một chỗ thì mọi chỗ gọi subsystem đó cũng phải kiểm.

### E — Extension (Bài Extensions)

**E1 · Vừa · `&Around` không gọi `ProceedWithCall()` = thay thế toàn bộ** procedure gốc; khi nhà cung cấp cập nhật, extension vẫn chạy bản cũ mà không báo. Chỉ thêm / bớt vài dòng → `&ChangeAndValidate` + `#Insert` / `#Delete` (platform báo khi gốc thay đổi).

**E2 · Nhẹ · Prefix** cho mọi procedure, attribute, form item thêm mới (`ext1_...`); tên field tham chiếu trong code phải tồn tại thật trên object (lỗi thật: điều kiện dùng cột `Count` không tồn tại → patch "sửa lỗi" gây lỗi runtime).

### M — Common module và cấu trúc (Bài 14, 23)

**M1 · Vừa · Cờ đúng ngữ cảnh:** Server (gọi từ posting / server) · Server call (client gọi được — chỉ export những gì client cần) · Client · Client+Server (thuần tính toán, không DB). Module scheduled job chỉ cần Server. Không dồn mọi hàm vào một module Server call.

**M2 · Nhẹ · Dọn dẹp:** handler rỗng còn gán event, stub `a = 1` trong `PresentationGetProcessing` (chạy mỗi lần hiển thị), `Message("On change")` debug, code chết, biến trùng tên hàm có sẵn (`Date`, `RefreshInterface`), magic number, typo trong tên metadata (đổi tên về sau rất tốn — sửa sớm). Chia `#Region Public / EventHandlers / Private`.

## 2b. Kiểm tra tự động — đối chiếu với công cụ phân tích tĩnh

Quy tắc ở mục 2 trùng phần lớn với chẩn đoán của **BSL Language Server** (`1c-syntax/bsl-language-server`, có tài liệu tiếng Anh cho ~190 chẩn đoán; dùng qua extension "Language 1C (BSL)" của VS Code, hoặc SonarQube) và các kiểm tra **1C:Code style V8** trong 1C:EDT (`1C-Company/v8-code-style`). Khi người dùng muốn tự kiểm tra hàng loạt, gợi ý chạy công cụ rồi mang kết quả lại để giải thích. Tên chẩn đoán dưới đây giúp tra nhanh:

| Quy tắc | BSL Language Server | 1C:Code style V8 (EDT) |
|---|---|---|
| P8 | `VirtualTableCallWithoutParameters`, `JoinWithVirtualTable` | — |
| Q1 | `CreateQueryInCycle`, `UsingFindElementByString`, `UnsafeFindByCode` | — |
| Q2–Q5 | `FieldsFromJoinsWithoutIsNull`, `SelectTopWithoutOrderBy`, `LogicalOrInJoinQuerySection`, `QueryParseError` | `ql-*` |
| F1 | `ServerCallsInFormEvents`, `TransferringParametersBetweenClientAndServer` | `form-module-pragma` |
| F5 | `WrongDataPathForFormElements`, `MissingEventSubscriptionHandler` | — |
| F6 | `UsingModalWindows`, `UsingSynchronousCalls` | — |
| V1 | `UsingCancelParameter` | — |
| V2 | `DeprecatedMessage` | — |
| V5 | `DataExchangeLoading` | `data-exchange-load` |
| T1 | `BeginTransactionBeforeTryCatch`, `CommitTransactionOutsideTryCatch`, `PairingBrokenTransaction`, `WrongUseOfRollbackTransactionMethod` | `begin-transaction`, `commit-transaction`, `lock-out-of-try` |
| T2 | `MissingCodeTryCatchEx`, `UsageWriteLogEvent` | `empty-except-statement` |
| X3 | `MissingTemporaryFileDeletion`, `MissingTempStorageDeletion`, `FileSystemAccess` | `missing-temporary-file-deletion` |
| E1–E2 | `WrongUseFunctionProceedWithCall`, `SuspiciousChangeAndValidate` | `change-and-validate-instead-of-around`, `extension-method-prefix` |
| M1 | `CompilationDirectiveLost`, `CompilationDirectiveNeedLess`, `CommonModuleNameServerCall`… | `form-module-missing-pragma` |
| M2 | `EmptyCodeBlock`, `CommentedCode`, `UnusedLocalMethod`, `MagicNumber`, `DeprecatedCurrentDate`, `UsingThisForm` | `module-empty-method` |

Công cụ **không** bắt được các lỗi nghiệp vụ nặng nhất ở mục 2 (dấu Receipt/Expense — P1, movement cũ khi post lại — P2, biên thời điểm — P3, lô âm — P4, ghi vào `Object` thay vì `CurrentObject` — F2): vẫn phải đọc code. Phần lớn chẩn đoán viết cho code cú pháp tiếng Nga nhưng chạy được cả với cú pháp tiếng Anh.

## 2c. Dấu hiệu code lỗi thời — nhắc người dùng khi gặp

Code chép từ diễn đàn, sách cũ hay repo cộng đồng thường mang các dấu hiệu dưới. Gặp thì nói rõ là cách cũ và chỉ cách hiện hành (chuẩn 1C ở `chuan-phat-trien.md`, đối chiếu cú pháp Nga ↔ Anh ở `thuat-ngu-ru-en.md`):

| Dấu hiệu | Vấn đề | Thay bằng |
|---|---|---|
| `DoMessageBox`, `DoQueryBox`, `OpenFormModal`, `.DoModal()`, `InputValue(...)`, `Предупреждение`, `Вопрос`, `ОткрытьФормуМодально` | Modal — lỗi khi *Modality use mode = Do not use*, không chạy ổn trên web client (#std703) | `ShowMessageBox`, `ShowQueryBox`, `OpenForm` + `CallbackDescription`, hoặc `Async` / `Await` |
| Form thường (ordinary form), `ЭтаФорма` / `ThisForm`, `ПолучитьФорму` / `GetForm` + `Open()` | Kiểu ứng dụng thường (8.1–8.2) | Managed form, `ThisObject`, `OpenForm` (#std404) |
| `Сообщить` / `Message` cho thông báo nghiệp vụ | Không gắn được ô, không chuẩn (#std418) | `UserMessage` / `Common.MessageToUser` |
| `ТекущаяДата()` / `CurrentDate()` | Giờ máy chủ / máy khách, không theo múi giờ phiên | `CurrentSessionDate()` |
| `FOR UPDATE` / `ДЛЯ ИЗМЕНЕНИЯ` trong query khi cấu hình dùng khóa managed | Không có tác dụng (#std460) | `DataLock` |
| Thư viện / công cụ cũ: xUnitFor1C, SSL 2.x (`ОбщегоНазначенияКлиентСервер.СообщитьПользователю` của bản cũ), lệnh `vrunner xunit` (vanessa-runner 2.x) | Dừng phát triển / đổi API | YAxUnit; SSL 3.x (`ssl-api-en.md`); vanessa-runner 3.x |
| `NotifyDescription` | Tên cũ, vẫn chạy | Bản platform mới dùng `CallbackDescription` — giữ đúng tên mà platform của người dùng có |

## 3. Mẫu trả lời review

```
**Tóm tắt:** 2 lỗi nặng (P1, F2), 1 lỗi vừa (Q1), vài điểm dọn dẹp.

| Vị trí | Quy tắc | Vấn đề | Vì sao | Sửa |
|---|---|---|---|---|
| Posting, dòng 18 | P1 | Ghi Receipt khi xuất | Tồn tăng khi bán | AddExpense() |
| ... | | | | |

**Bản sửa** (code minh họa — chạy thử để kiểm chứng): ...
**Tự kiểm:** post chứng từ → mở Register records → số lượng mang dấu ... ; post lại sau khi đổi ngày → ...
```
Với code bài THỰC HÀNH: giữ cột Vị trí, Quy tắc, Vấn đề, Vì sao; bỏ cột Sửa và phần Bản sửa.


---

# § loi-da-biet

# Lỗi đã biết trong code mẫu của khóa và ERP_Practice

> **Khi nào đọc file này:** người học chép code demo của khóa (nhánh `lesson/NN-theory`, nhánh `master` / `master-edt-archive`) hoặc của ERP_Practice rồi gặp kết quả lạ; người học hỏi "code mẫu sao lại làm thế này"; trước khi trích một đoạn code có dòng `Nguồn:` từ các nhánh dưới đây. Mã quy tắc (P1, F2…) trỏ về `code-review/review-code.md`.
>
> Bản sửa các lỗi nặng của nhánh `master` (1CJDCourse) và ERP_Practice: đã đưa vào nhánh `master` của mỗi repo (10/2026, từ nhánh `fix/code-review-2026-10`) — các bảng dưới mô tả lỗi của bản trước khi sửa; các nhánh `lesson/NN-*` giữ nguyên để khớp video nên lỗi ở mục 1 vẫn còn trên các nhánh đó.
>
> Rút từ đợt đọc toàn bộ mã nguồn (10/2026), **chưa chạy lại trên platform**; dòng nào ghi *cần kiểm chứng* thì nói rõ như vậy với người học. Nguyên tắc khi gặp: nói thẳng đây là chỗ code mẫu đơn giản hóa hoặc có lỗi, chỉ cách đúng, **không lặng lẽ chép lại lỗi**.

## 1. Code demo lý thuyết (nhánh `lesson/NN-theory`)

Lưu ý chung: nhánh `lesson/09-theory` trùng gần như nguyên vẹn với `master-edt-archive` — là ảnh chụp **cả khóa** (đã có lô hàng, FIFO/LIFO, nạp Excel, DCS), không phải trạng thái tích lũy của riêng Bài 9. Đừng nói với người học rằng "đến Bài 9 cấu hình đã có FIFO".

| Bài | Ở đâu | Vấn đề | Đúng là | Quy tắc |
|---|---|---|---|---|
| 11–14 | `SalesInvoice` object module, `Posting` | Bán hàng ghi `Receipt` → tồn **tăng** khi bán; Bài 15 mới sửa thành `Expense` | `AddExpense()` | P1 |
| 14, 24 | `ReturnOfGoodsFromCustomer`, `Posting` | Trả hàng ghi doanh số **dương** vào `Sales` → doanh số cộng gấp đôi; nhập lại kho theo giá bán (bản đơn giản hóa) | Amount âm; giá vốn lấy từ movement của hóa đơn gốc | P1, P9 |
| 15, 16, 24 | `SalesInvoice`, `CheckGoodsInWarehouseBalance` | Procedure kiểm tra tồn viết xong nhưng `Posting` **không gọi** → không chặn bán quá tồn | Ghi movement → gọi kiểm tra với biên `Including` | P3 |
| 16–24 | Form `SalesInvoice`, `FillDeliveryAddress` | Ghi vào `Object` trong `BeforeWriteAtServer` → địa chỉ không được lưu (trái với chính comment của bài) | Ghi vào `CurrentObject` | F2 |
| 16–24 | Form `SalesInvoice`, `FillInSoldThisMonth` | `Turnovers` periodicity `Period` → chỉ giữ dòng cuối, không phải tổng tháng; chỉ tính sau khi ghi | Bỏ periodicity; gọi thêm ở `OnReadAtServer` | P8 |
| 10, 13, 16 | Form `SalesInvoice`, Pick | Typo `CloseOnChoise` → form chọn đóng sau lần chọn đầu; `ServicesChoiceProcessing` không được gán event và dùng cột `Product` (bảng Services có cột `Service`) | `CloseOnChoice`; gán event; cột `Service` | F4, F5 |
| 07–24 | Form `PersonnelChange`; form `SalesInvoice` (16–24: `ProductsBeforeDeleteRow`, `ProductsAfterDeleteRow`) | Event gán trong form nhưng module không có handler *(mức lỗi runtime cần kiểm chứng)* | Bỏ gán hoặc viết handler | F5 |
| 07, 10, 16 | Form `PersonnelChange` | Thông báo dùng tên nhân viên **sau khi** đã xóa → luôn rỗng | Lưu vào biến trước | F9 |
| 08, 10, 13, 16 | Form `SalesInvoice`, `CalculateWeightAtServer` | Dereference `Product.Weight` từng dòng; kết quả gán vào biến cục bộ (không phải form attribute) nên bị bỏ | Một query `SUM`; `TotalWeight` là form attribute | Q1 |
| 10, 14 | `CommonServer.ContractSumsByCounterparties` | Duyệt "2 cấp" nhưng query không có `TOTALS` → cấp con rỗng; function không `Return` | `TOTALS ... BY Product`, `ByGroups`, `Return` | Q3 |
| 12–24 | `SalesInvoice` / common module `Sales` | Truyền tabular section thẳng vào `FROM &Products` *(cần kiểm chứng theo phiên bản)* | `.Unload(, "...")` + `CAST` | Q2 |
| 13–16 | `Filling` / event subscription `DocumentsCommonFilling` | Ghi đè `Company` vô điều kiện | Chỉ điền khi rỗng | V4 |
| 09*, 19 | `ImportPricesFromExcel` | `"R" + i` sai từ dòng 1000; `FindByDescription` mỗi dòng; Bài 19 đọc giá bằng `.Text`; ghi từng `RecordManager` không transaction; 09* nuốt lỗi ghi chứng từ (chỉ log); so ngày đầu ngày với ngày có giờ → tạo trùng chứng từ | Địa chỉ số; một query + `Map`; `.Value`; record set / transaction; báo người dùng; `BegOfDay` | X1, X2, Q1, T1 |
| 09* | `SalesInvoice`, `InventoryTransfer` `Posting` | Đọc số dư không `DataLock` (cấu hình Managed); `InventoryTransfer` xóa movement khi hủy post → post lại sau khi **dời ngày về sau** có thể trừ trùng *(cần kiểm chứng)* | `DataLock`; ghi record set rỗng trước khi đọc | P6, P2 |
| 09* | `ReturnOfGoodsFromCustomer` | Không kiểm `SalesDocument` rỗng; trả vượt số đã bán bị bỏ qua lặng lẽ | Kiểm tra + báo lỗi | P9, V1 |
| 17 | `SalesInvoice` manager module, in | Query logo công ty cho **mỗi** chứng từ; `Products` manager có stub `a = 1` trong `PresentationGetProcessing` | Lấy trong query chính; xóa stub | Q5, M2 |
| 17, 20 | Form `Companies` (logo) | `New BinaryData(FileName)` ở client — không chạy web client | `BeginPutFileToServer` | X3 |
| 24 | `SalesInvoice` bút toán | `Dr Phải thu / Cr Hàng hóa` theo **giá bán**, dịch vụ không có bút toán — đơn giản hóa để minh họa `ExtDimensions` | Hai bút toán: doanh thu theo giá bán, giá vốn theo giá vốn | — |
| Ext | `Bugfix123` | Điều kiện dùng cột `Count` không tồn tại (bảng chỉ có `Quantity`) → bản patch gây lỗi runtime; `CRMImprovemnet` thiếu handler `crm_GoodsAmountOnChangeAfter`, thiếu prefix | Sửa tên cột; thêm handler, prefix | E2 |
| master-edt | `FormForDebugTest` | Chứng từ không `Write()`; `Raise "chuỗi"` mất lỗi gốc *(có thể cố ý cho bài debug)* | Mẫu T1 | T1 |
| Nhiều bài | — | `Message()` cho thông báo nghiệp vụ; handler rỗng; marker wizard; typo tên metadata (`ContolBalanceOfGoods`, `FunctionalOptionParatemets`) | `UserMessage` + `Field`; dọn dẹp | V2, M2 |

Các đoạn **nên dạy** trong nhánh theory (code tốt): kiểm tồn sau ghi bằng `New Boundary(PointInTime, BoundaryType.Including)` (`ProductsInDocuments`, 09*); FIFO/LIFO một query + `Min()` (09*); `SELECT TOP 2` + `Count() = 1` lấy giá trị mặc định duy nhất; `SliceLast` lọc trong tham số; tách common module Server / ServerCall / ClientServer; DCS external data set có kiểu cột (09*, 18); upload file async (09*, 19); `ShowQueryBox` / `RunCallback` một luồng (09*); `AdditionalProperties.Insert("IsNew", IsNew())` (11, 24); `DeleteAttributeFromChecking` + functional option có tham số (12–24); ghi register liên quan trong `OnWriteAtServer` cùng transaction (12, 17); vòng đời ghi của managed form (16); logo bằng `ValueStorage` + temp storage + `LockFormDataForEdit` (17); in với tabular section lồng và `PrintParametersKey` (17); storno trong bút toán đảo, `PresentationGetProcessing` của chart of accounts, `#Region` (24); tích hợp SSL Print (21–23).

## 2. ERP_Practice (`vuongviet2x/ERP_Practice`)

Thiết kế: cấu hình dịch vụ sửa chữa có vật tư theo sách *Practical Developer's Guide* (bản PDF: https://drive.google.com/file/d/1X0uW1nnb8PXg-RwCLLlt5H_e2DzkdsnT/view?usp=sharing) (compat 8.3.24, Managed lock, không modal). `GoodsReceipt` / `Services` ghi `BalanceOfMaterials`, `CostOfMaterials` (giá vốn bình quân, **không** theo kho), `Sales`, accounting register `Primary`; exchange plan `Branches` + prefix số theo node; 9 báo cáo DCS. Luồng posting `Services` là mẫu tốt: temp table dòng chứng từ → ghi record set rỗng → đọc số dư → tính giá vốn bình quân → ghi → (RealTime) kiểm tồn âm.

| Ở đâu | Vấn đề | Đúng là | Quy tắc |
|---|---|---|---|
| `ExchangePlans/Branches/Forms/ListForm` | Gọi `WriteChangesAtServer()` thiếu tham số bắt buộc → lỗi biên dịch | Truyền `Items.List.CurrentRow`, bỏ qua node này | — |
| `DataProcessors/DataExchange` | Gọi `ReadMessageWithChanges` / `WriteMessageWithChanges` — không phải method của platform; trong sách là procedure tự viết trong **object module của exchange plan**, repo thiếu file đó | Thêm `ExchangePlans/Branches/ObjectModule.bsl` theo sách (`CreateMessageWriter`, `SelectChanges`, `CreateMessageReader`, `ReadXML`, `DeleteChangeRecords`) | — |
| `Documents/Services`, `Posting` | Bút toán doanh thu (Nợ Phải thu / Có Doanh thu) nằm **trong** nhánh vật tư → doanh thu dịch vụ không vào sổ | Đưa bút toán doanh thu ra ngoài `If` | P1 |
| `Documents/Services`, `Posting` | Số dư đọc không truyền thời điểm → post lại chứng từ quá khứ tính giá vốn trên số dư hôm nay | `New Boundary(PointInTime(), BoundaryType.Excluding)` | P3 |
| `Documents/Services`, `Posting` | `LockForUpdate` trên record set rỗng không khóa các vật tư được đọc *(cần kiểm chứng)* | `DataLock` tường minh | P6 |
| Exchange plan `Branches` | Content thiếu `Primary`, `ChartOfAccounts`, `InputOpeningMaterialBalances` | Bổ sung content | — |
| `InputOpeningMaterialBalances` | `BeforeWrite` không kiểm `DataExchange.Load` | Thêm ở đầu | V5 |



---

# § chuan-phat-trien

# Chuẩn phát triển của 1C (1C:Enterprise Development Standards) — bản rút gọn cho Junior

> **Khi nào đọc file này:** khi review code và muốn dẫn **chuẩn chính thức** của 1C cho một nhận xét; khi người dùng hỏi "chuẩn của 1C nói gì về…", "viết thế này có đúng chuẩn không"; khi intern / đối tác chuẩn bị code cho dự án thật. Quy tắc thực hành có mã (P1, Q1, F2…) và mẫu trả lời: `code-review/review-code.md`.
>
> **Nguồn:** bộ chuẩn phát triển của 1C (its.1c.ru/db/v8std, bản tiếng Anh trên **kb.1ci.com** → 1C:Enterprise Development Standards), qua bản biên tập mở **v8std.ru** (repo `zeegin/v8std`, giấy phép **CC0**). Bảng dưới là **tóm tắt tiếng Việt của người soạn** cho khoảng 50 chuẩn cốt lõi trên tổng số khoảng 320; mã `#stdNNN` dùng để tra bản đầy đủ: `https://v8std.ru/std/NNN/` (tiếng Nga) hoặc tìm theo tên trên kb.1ci.com (tiếng Anh). Khảo sát 10/2026. Ví dụ code trong các chuẩn gốc viết bằng cú pháp tiếng Nga — khi giải thích, chuyển sang cú pháp tiếng Anh (`code-review/thuat-ngu-ru-en.md`).
>
> Cách dùng khi trả lời: nêu nhận xét bằng lời của mình + "(chuẩn 1C #stdNNN)"; không chép nguyên văn chuẩn. Với người mới (lộ trình J), chỉ dẫn chuẩn khi thật cần — ưu tiên giải thích bằng hậu quả nghiệp vụ.

## 1. Posting, register, khóa, transaction

| Chuẩn | Nội dung chính (tóm tắt) | Quy tắc review | Công cụ bắt được |
|---|---|---|---|
| #std603 | Phần lớn document phải **được post**; chưa post = bản nháp, không kiểm tra nghiệp vụ, không vào sổ. Giai đoạn của chứng từ đã post thể hiện bằng **trạng thái**, kiểm tra theo trạng thái | P2 | — |
| #std450 | **Không** gọi `RecordSet.Write()` tường minh trong `Posting` — để platform ghi khi kết thúc posting (tránh deadlock). **Ngoại lệ:** khi dữ liệu register cần cho thuật toán ngay sau đó trong posting (ví dụ kiểm tra số dư âm sau khi ghi) | P3 | — |
| #std661 | Kiểm soát tồn khi post phải là **đọc có khóa**. Cách khuyến nghị: ghi các register không cần kiểm soát trước; cuối transaction ghi register cần kiểm soát với `LockForUpdate = True`, rồi query số dư âm theo đúng tập dimension; có âm → hủy | P3, P6 | — |
| #std460 | Dùng **chế độ khóa managed**; đặt khóa tường minh (`DataLock`) **trước khi đọc** dữ liệu sẽ dùng để ghi; khóa đúng phạm vi cần thiết; trong chế độ managed, `FOR UPDATE` trong query không có tác dụng | P6 | v8cs `configuration-data-lock-mode`, `ql-using-for-update` |
| #std783 | Transaction: mỗi `BeginTransaction` có cặp `CommitTransaction` / `RollbackTransaction`; bắt đầu và kết thúc **trong cùng một method**; exception trong transaction không tự hủy transaction — phải `RollbackTransaction` trong `Except` | T1 | BSL LS `BeginTransactionBeforeTryCatch`, `CommitTransactionOutsideTryCatch`, `PairingBrokenTransaction`, `WrongUseOfRollbackTransactionMethod` |
| #std792 | Không ghi record set của information / accumulation register **trong vòng lặp** từng bản ghi — gom thành một set (lô khoảng 1 000 bản ghi); nếu chỉ đổi dưới 30 % thì ghi phần thay đổi | Q1, T1 | — |
| #std477 | Register phải **tự đủ nghĩa**: logic và báo cáo trên register không lấy trường của recorder (chứng từ) qua dấu chấm — dữ liệu cần thì đưa vào dimension / attribute của register | P7 | — |
| #std633 | Nếu cấu hình có cơ chế bật / tắt `Active` của movement thì **mọi** query và báo cáo phải lọc movement đang active | — | — |
| #std664 / #std663 | Số dư theo một bộ dimension bị khóa khi ghi → chọn dimension theo đúng "độ mịn" nghiệp vụ và dùng chế độ tách tổng (totals splitting) để nhiều người post song song | P6 | — |

## 2. Sự kiện của object và kiểm tra dữ liệu

| Chuẩn | Nội dung chính | Quy tắc review | Công cụ |
|---|---|---|---|
| #std463 | `FillCheckProcessing`: kiểm tra mà Fill checking thường không làm được (theo điều kiện, theo tabular section, liên quan nhiều trường); bỏ kiểm tra có điều kiện bằng cách xóa khỏi `CheckedAttributes` | V1 | — |
| #std464 | `BeforeWrite`: điền thuộc tính, kiểm tra, làm việc với giá trị **cũ** đã lưu trong DB | V5 | BSL LS `DataExchangeLoading` |
| #std465 | `OnWrite`: ghi dữ liệu liên quan sang object khác; **không** sửa chính object đang ghi (đã ghi xong) | V5 | `DataExchangeLoading` |
| #std773 | Mọi handler `BeforeWrite` / `OnWrite` / `BeforeDelete`… kiểm tra `DataExchange.Load` ở **đầu** handler và thoát (dữ liệu nhận qua trao đổi ghi nguyên trạng) | V5 | `DataExchangeLoading`, v8cs `data-exchange-load` |
| #std686 | Không gán `Cancel = False` (kể cả gián tiếp `Cancel = HasErrors()`) — có thể xóa `True` đã đặt trước đó. Viết `If … Then Cancel = True; EndIf;` hoặc `Cancel = Cancel Or …` | V1 | `UsingCancelParameter`, v8cs `event-handler-boolean-param` |
| #std396 | `Filling`: chặn "Tạo dựa trên" không hợp lệ (dựa trên nhóm, dựa trên chứng từ chưa post) — được phép `Raise` để báo lý do | V4 | — |
| #std466 / #std752 | `OnCopy` xóa dữ liệu không được sao chép; `BeforeDelete` kiểm tra / dọn dữ liệu liên quan | — | — |
| #std451 | Tạo object bằng code qua method của manager (`Documents.X.CreateDocument()`, `Catalogs.X.CreateItem()`), không dùng `New`; gọi `Fill()` tường minh để chạy logic điền mặc định | T1 | — |

## 3. Query

| Chuẩn | Nội dung chính | Quy tắc review | Công cụ |
|---|---|---|---|
| #std436 | Dữ liệu cùng loại lấy bằng **một** query (`IN`, `UNION ALL`, batch query), không query trong vòng lặp | Q1 | v8cs `query-in-loop`; BSL LS `CreateQueryInCycle` |
| #std657 | Mọi điều kiện thuộc về virtual table đặt **trong tham số** virtual table, dạng đơn giản `Dimension = &Value` / `IN (&List)`; subquery trong tham số chỉ dùng một bảng, không join | P8 | `VirtualTableCallWithoutParameters`, v8cs `ql-virtual-table-filters` |
| #std733 | Đọc `.Balance` nhanh nhất khi **không truyền ngày** (bảng tổng hiện hành) — chỉ dùng khi thực sự cần số dư hiện tại (post thời gian thực); post lùi ngày phải truyền thời điểm | P3, P8 | — |
| #std654 | Lấy trường qua dấu chấm (`Ref.Attribute`) tạo join ngầm; với trường **kiểu hỗn hợp** thì đặc biệt tránh — dùng `CAST(... AS ...)` | Q1 | `QueryNestedFieldsByDot`, `RefOveruse` |
| #std655 | Không join với subquery — đưa subquery thành **temp table** | Q2 | `JoinWithSubQuery`, `JoinWithVirtualTable` |
| #std658 / #std652 | Điều kiện chính trong `WHERE` / `ON` / tham số virtual table phải dùng được **index**; không nối điều kiện chính bằng `OR` | Q2 | `LogicalOrInJoinQuerySection`, `LogicalOrInTheWhereSectionOfQuery` |
| #std777 | Temp table để tăng hiệu năng / chia query; chỉ chọn cột và dòng cần thiết; không đổ hàng trăm nghìn dòng | Q2 | v8cs `ql-temp-table-index` |
| #std412 | Thuật toán phụ thuộc thứ tự dòng (FIFO, sinh movement, hiển thị) → luôn `ORDER BY`; `TOP` không có `ORDER BY` là kết quả không xác định | P4, Q5 | `SelectTopWithoutOrderBy` |
| #std438 | Kiểm tra kết quả rỗng bằng `QueryResult.IsEmpty()` chỉ khi **không** đọc dữ liệu sau đó | — | — |
| #std434 / #std435 | Ưu tiên `UNION ALL` thay `UNION` khi không cần loại trùng; hạn chế `FULL OUTER JOIN` | Q2 | `UnionAll`, `FullOuterJoinQuery` |
| #std726 | `LIKE` chỉ dùng với literal hằng (`Attribute LIKE "123%"`) hoặc tham số đã xử lý ký tự đặc biệt | — | `UsingLikeInQuery`, `IncorrectUseLikeInQuery` |
| #std415 | **Không** dùng `ALLOWED` trong query phục vụ tính toán / posting — dữ liệu bị ẩn làm sai kết quả | — | — |
| #std496 | Đọc vài thuộc tính của một ref: dùng query (hoặc `Common.ObjectAttributesValues` của SSL), không `GetObject()` / dereference đọc cả object | Q1, V5 | v8cs `reading-attribute-from-database` |

## 4. Client / server, form

| Chuẩn | Nội dung chính | Quy tắc review | Công cụ |
|---|---|---|---|
| #std487 | Kiểm soát số **server call**: một thao tác người dùng thường không quá một lần gọi thêm; kiểm soát lượng dữ liệu truyền đi | F1 | `MissingTempStorageDeletion` |
| #std636 | `&AtServerNoContext` chỉ truyền tham số; `&AtServer` truyền cả dữ liệu form đã đổi + khởi tạo context → chậm hơn. Không cần dữ liệu form thì dùng NoContext | F1 | — |
| #std629 | Giảm code chạy ở client, nhưng tính toán nhẹ (thành tiền, tổng) vẫn làm ở client để khỏi gọi server | F1 | — |
| #std439 | Mọi method của form module có compilation directive; dùng preprocessor đúng chỗ | M1 | `CompilationDirectiveLost`, v8cs `form-module-missing-pragma` |
| #std703 | Cấu hình đặt *Modality use mode = Do not use*; dùng `ShowMessageBox`, `ShowQueryBox`, `OpenForm` + callback (hoặc `Async`/`Await`) thay method modal | F6 | `UsingModalWindows`, `UsingSynchronousCalls`, v8cs `dont-use-modality-mode` |
| #std404 / #std741 | Mở form bằng `OpenForm` (không `GetForm` + `Open`); form có tham số khai báo trong **Parameters** của form | F4 | `GetFormMethod` |
| #std411 | Giới hạn giá trị chọn bằng **Choice parameters / Choice parameter links** của field hoặc attribute | F4 | — |
| #std409 | Trong form module ưu tiên `FormAttributeToValue` (gọn, ít lỗi) thay cho `FormDataToValue`; chỉ chuyển sang object khi cần method của object | F1 | `FormDataToValue` |
| #std400 / #std418 / #std585 | Thông báo người dùng bằng `UserMessage` (SSL: `Common.MessageToUser` / `CommonClient.MessageToUser`); **không** dùng `Message()` | V2 | `DeprecatedMessage` |
| #std522 / #std523 | Giảm truy cập DB trong handler chạy thường xuyên (OnActivateRow…); không dùng `CurrentRow` để lấy giá trị trường của dòng — dùng `CurrentData` (và kiểm `Undefined`) | F8 | `CurrentRowAccess` |

## 5. Module, đặt tên, lỗi

| Chuẩn | Nội dung chính | Quy tắc review | Công cụ |
|---|---|---|---|
| #std455 | Cấu trúc module theo **region**: phần mô tả biến, `Public` (giao diện lập trình), `EventHandlers`, `Internal`, `Private`… | M2 | `CodeOutOfRegion`, `NonStandardRegion` |
| #std469 | Common module gom theo một chủ đề; chọn 1 trong 4 ngữ cảnh (Server, Client, Server call, Client+Server) và đặt **hậu tố tên** theo ngữ cảnh (`…Client`, `…ServerCall`, `…ClientServer`) | M1 | `CommonModuleName*`, `CommonModuleInvalidType` |
| #std679 | Không bật cờ **Server call** mặc định cho mọi module server — chỉ module chứa API thực sự gọi từ client, và API đó không lộ dữ liệu / không cho làm điều người dùng không được phép | M1 | v8cs `common-module-server-call` |
| #std544 | Không đặt method `Export` trong command module / common command; form module chỉ export khi thật cần (handler gắn từ code, callback) | M1 | `CommandModuleExportMethods` |
| #std454 / #std647 / #std640 | Tên biến, method có nghĩa, PascalCase; tham số từ chung đến riêng, tham số tùy chọn sau tham số bắt buộc | M2 | `FunctionNameStartsWithGet`, `NumberOfOptionalParams` |
| #std453 | Doc-comment cho method `Export` (mô tả, Parameters, Returns) | M2 | `MissingParameterDescription` |
| #std499 | Không bắt exception khi không cần (platform đã hiện lỗi và ghi Event log); khi bắt thì ghi `WriteLogEvent` với `DetailErrorDescription` và báo người dùng | T2 | `MissingCodeTryCatchEx`, `UsageWriteLogEvent`, v8cs `empty-except-statement` |
| #std790 | `Raise` bằng code chỉ khi cần (lỗi nghiệp vụ hiển thị cho người dùng); với lỗi kỹ thuật nên có **category** lỗi | T2, T3 | — |
| #std498 | Ghi Event log có tên sự kiện, mức độ, metadata, dữ liệu liên quan | T2 | — |
| #std693 | `Structure` không nhồi quá nhiều key qua constructor; không dùng làm "bảng" — dùng ValueTable | — | `NumberOfValuesInStructureConstructor` |
| #std782 | Nối chuỗi số lượng lớn (≥ 1 000 lần) bằng `StrConcat` / mảng, không `+` trong vòng lặp | — | — |

## 6. File, tích hợp, bảo mật, quyền

| Chuẩn | Nội dung chính | Quy tắc review | Công cụ |
|---|---|---|---|
| #std542 | File tạm lấy tên bằng `GetTempFileName()`, xóa sau khi dùng; không ghi vào thư mục cố định | X3 | `FileSystemAccess`, `MissingTemporaryFileDeletion`, `TempFilesDir` |
| #std748 | Mọi `HTTPConnection`, `WSProxy`, `FTPConnection`… phải đặt **timeout** | X (tích hợp) | `TimeoutsInExternalResources` |
| #std740 | Không lưu mật khẩu / token dạng rõ trong code hay constant — dùng kho dữ liệu an toàn (`Common.WriteDataToSecureStorage` của SSL) | — | `UsingHardcodeSecretInformation`, v8cs `secure-password-storage` |
| #std669 / #std770 | Hạn chế `Execute` / `Eval` (thực thi code động), đặc biệt trên server | — | `ExecuteExternalCode` |
| #std485 | Privileged mode chỉ cho đoạn ngắn, có lý do; không mở rộng quyền người dùng ngoài mục đích | — | `SetPrivilegedMode` |
| #std689 / #std488 | Thiết kế role theo chức năng, có các role chuẩn (toàn quyền, quản trị…); hạn chế kiểm tra quyền bằng tên role (`IsInRole`) rải rác trong code | — | `IsInRoleMethod` |
| #std548 / #std789 | Lệnh in: người dùng chỉ cần quyền đọc dữ liệu + quyền chạy lệnh; người dùng có thể sửa template (SSL Print) nên code in phải chịu được khi vùng / tham số template bị đổi hoặc xóa | X4 | — |
| #std540 / #std539 | Chỉ dùng scheduled job khi thật cần; luôn cho người dùng cách chạy tay việc tương ứng | — | `ScheduledJobHandler` |

## 7. Ghi chú khi đối chiếu với code của khóa

- Code của khóa (bài 11–16) gọi `RegisterRecords.X.Write()` trong `Posting` rồi kiểm tra số dư âm — đây là **ngoại lệ hợp lệ** của #std450 (cần dữ liệu ngay sau đó) và đúng tinh thần #std661; khi dạy, nói rõ đây là ngoại lệ, không phải cách ghi mặc định.
- Bản đồ đầy đủ chuẩn ↔ chẩn đoán BSL LS / 1C:Code style V8 có trên v8std.ru (mỗi chuẩn liệt kê các check bắt được nó); tên chẩn đoán dùng được với `review-code.md` mục 2b.


---

# § nguon-ngoai

# Nguồn mã mở bên ngoài — danh mục, cho ai, khi nào

> **Khi nào đọc file này:** người dùng hỏi "có thư viện / ví dụ / công cụ nào cho…", cần kỹ thuật **ngoài 24 bài** (HTTP/REST, di động, mã vạch, kiểm thử tự động, phân tích code tĩnh, CI/CD, AI agent với 1C), muốn đọc một ứng dụng lớn hơn, hoặc dán code cộng đồng (thường cú pháp tiếng Nga).
>
> Khảo sát 10/2026 (đọc trực tiếp repo, kiểm giấy phép trong file LICENSE). Số sao, trạng thái thay đổi nhanh — nói "tại thời điểm khảo sát", rà lại mỗi quý.
>
> **Nguyên tắc:** (1) không phải tài liệu của khóa — nói rõ nguồn và giấy phép; (2) phần lớn code cộng đồng là **cú pháp tiếng Nga** — với người mới chỉ giới thiệu nguồn tiếng Anh hoặc dùng như công cụ; chuyển cú pháp theo `code-review/thuat-ngu-ru-en.md`; (3) không chép khối code lớn vào câu trả lời — tóm tắt kỹ thuật, trỏ link; repo **không giấy phép** chỉ được trỏ link; (4) không thay bài thực hành, không dùng để lách `chinh-sach-code.md`.
>
> Ký hiệu đối tượng: **(a)** sinh viên mới, chỉ dùng chat · **(b)** intern / đối tác mức Junior · **(c)** giảng viên, sản xuất khóa học.

## 1. Đã tích hợp vào skill

| Nguồn | Giấy phép · cú pháp | Đã dùng ở đâu |
|---|---|---|
| [1Ci-Company/Jet](https://github.com/1Ci-Company/Jet) (nhánh `community`) — ứng dụng mã mở cho người học, SSL 3.1.10 | MIT · **EN** | `jet/`, `btl/` (lộ trình J) |
| [zeegin/v8std](https://github.com/zeegin/v8std) → v8std.ru — bộ chuẩn phát triển của 1C (~320 chuẩn) + bản đồ chuẩn ↔ chẩn đoán | CC0 · RU (bản EN gốc trên kb.1ci.com) | `code-review/chuan-phat-trien.md` |
| [1c-syntax/ssl_3_1_eng](https://github.com/1c-syntax/ssl_3_1_eng) — SSL 3.1 World edition (bản tiếng Anh) | CC-BY-4.0 (mirror; SSL là sản phẩm của 1C) · **EN** | `code-review/ssl-api-en.md` (chỉ tên + chữ ký) |
| [1c-syntax/bsl-language-server](https://github.com/1c-syntax/bsl-language-server) — ~190 chẩn đoán, tài liệu EN | LGPL-3.0 | `review-code.md` mục 2b (tên chẩn đoán) |
| [1C-Company/v8-code-style](https://github.com/1C-Company/v8-code-style) — kiểm tra chuẩn chính thức trong 1C:EDT | EPL-2.0 | `review-code.md` mục 2b, `chuan-phat-trien.md` |

## 2. Ứng dụng / thư viện mẫu để đọc

| Nguồn | Là gì | Giấy phép · cú pháp | Cho ai, khi nào |
|---|---|---|---|
| [1C-Developer-Network/MobileScanner](https://github.com/1C-Developer-Network/MobileScanner/tree/master/MobScanner) | App **di động** kiểm kê kho (compat 8.3.14): quét mã vạch bằng camera (`MultimediaTools.ShowBarcodeScanning`), tìm hàng theo SKU, thêm hàng mới, nhập tên bằng giọng nói, xuất PDF đẩy lên Dropbox qua `HTTPConnection`. Kèm bài blog trên 1c-dn.com | không ghi giấy phép → chỉ link · **EN** | (a)(b): ý tưởng BTL Logistics (kiểm kê bằng điện thoại), minh họa nền tảng di động |
| [vbondarevsky/Connector](https://github.com/vbondarevsky/Connector) (`src/en`) | HTTP client kiểu "Requests": `HTTPConnector.GetJson / PostJson`, session, cookie, Basic/Digest/AWS4, gzip, retry, redirect; 1 common module ~3 100 dòng + test | Apache-2.0 · **EN** + RU | (b): tích hợp REST/JSON; mẫu tổ chức common module lớn |
| [alexkmbk/1CI](https://github.com/alexkmbk/1CI) | Cấu hình CI server viết trên 1C: HTTP service `RunTask`, COM connector, RLS, giao diện Taxi | MIT · **EN** (SSL 2.2.4 — cũ) | (b): ví dụ HTTP service, RLS bằng cú pháp tiếng Anh; cảnh báo SSL đời cũ |
| [Bayselonarrend/OpenIntegrations](https://github.com/Bayselonarrend/OpenIntegrations) | Tích hợp sẵn Telegram, Google, Bitrix24… cho 1C / OneScript / CLI | MIT · chủ yếu RU | (b): dự án cần kết nối dịch vụ phổ biến |
| [infaton/MCP35](https://github.com/infaton/MCP35) | MCP server viết bằng BSL (JSON-RPC 2.0 qua HTTP service) | MIT · RU | (c)(b nâng cao): ví dụ HTTP service hiện đại |
| [zeegin/OpenSubsystemsLibrary](https://github.com/zeegin/OpenSubsystemsLibrary) | Thư viện nhỏ, sạch, có test và Gherkin | MIT · RU | (c): mẫu thiết kế thư viện |
| [BlizD/Tasks](https://github.com/BlizD/Tasks) | Cấu hình hoàn chỉnh quản lý công việc (kanban, phát hành) | Apache-2.0 · RU | (b) đọc được RU: đọc một cấu hình thật cỡ vừa |
| [1C-Company/dt-demo-configuration](https://github.com/1C-Company/dt-demo-configuration) | Demo EDT của 1C: thiết bị thương mại, máy quét mã vạch, định vị | **không giấy phép** → chỉ link · RU | (c) |
| [FoxyLinkIO/FoxyLink](https://github.com/FoxyLinkIO/FoxyLink), [astrizhachuk/mockserver-client-1c](https://github.com/astrizhachuk/mockserver-client-1c) | Tích hợp JSON / RabbitMQ dựa trên DCS (giấy phép cần đọc kỹ); mock HTTP để test tích hợp (GPL-3.0) | — · RU | (c) |

Lưu ý khi dùng **MobileScanner** làm mẫu: có `DoModal()` (lỗi khi *Modality use mode = Do not use* — thay `OpenForm` + callback), địa chỉ ô `"R" + String(n)` (quy tắc X1), `Message()`, ghi chứng từ ở client sau mỗi lần quét, token Dropbox để trần trong constant (#std740), HTTP không timeout (#std748), không `Try`.

## 3. Công cụ giới thiệu cho người học

| Công cụ | Dùng để | Giấy phép | Cho ai |
|---|---|---|---|
| VS Code + [Language 1C (BSL)](https://github.com/1c-syntax/vsc-language-1c-bsl) + [BSL Language Server](https://github.com/1c-syntax/bsl-language-server) | Tô màu BSL + query, gợi ý, chẩn đoán tĩnh (đặt ngôn ngữ thông báo `en`); đối chiếu `review-code.md` mục 2b | MIT / LGPL-3.0 | (b), (a) khá |
| 1C:EDT + [1C:Code style V8](https://github.com/1C-Company/v8-code-style) | Kiểm tra chuẩn trong EDT | EPL-2.0 | (b) làm trên EDT |
| [EvilBeaver/OneScript](https://github.com/EvilBeaver/OneScript) (2.0, .NET) | Chạy ngôn ngữ 1C **không cần platform** — luyện cú pháp, vòng lặp, collection, viết script tự động hóa | MPL-2.0 | (a) có máy, (b) |
| [cpr1c/tools_ui_1c](https://github.com/cpr1c/tools_ui_1c) | Query console, code console… cho managed form | GPL-3.0 | (b) — ưu tiên `queryconsole.epf` của khóa (`tai-nguyen.md`) |
| [bia-technologies/yaxunit](https://github.com/bia-technologies/yaxunit), [Pr-Mex/vanessa-automation](https://github.com/Pr-Mex/vanessa-automation) | Unit test (extension, EDT); kiểm thử hành vi / UI (BDD, Gherkin) | Apache-2.0 / BSD-3-Clause | (b) |
| [vanessa-opensource/vanessa-runner](https://github.com/vanessa-opensource/vanessa-runner) 3.x | CLI build / test / deploy. **Bản 3.0 đổi cú pháp lệnh** (`vrunner test xunit`, file `autumn-properties.json`, cần OneScript 2.0) — hướng dẫn cũ dùng 2.x | MPL-2.0 | (b) nâng cao, (c) |
| [1C-Company/GitConverter](https://github.com/1C-Company/GitConverter) | Chuyển kho cấu hình (repository) sang Git / EDT | CC-BY-SA-4.0 | (b), (c) |
| [1c-syntax/sonar-bsl-plugin-community](https://github.com/1c-syntax/sonar-bsl-plugin-community) | SonarQube cho đội / đối tác | LGPL-3.0 | (b) đối tác, (c) |
| [Diversus23/onec-docker](https://github.com/Diversus23/onec-docker) | Image Docker cho server, client, EDT, vanessa-runner | MIT | (c) |

## 4. AI agent làm việc với 1C (cho người có platform trên máy)

| Nguồn | Là gì | Giấy phép | Ghi chú |
|---|---|---|---|
| [Nikolay-Shirokov/cc-1c-skills](https://github.com/Nikolay-Shirokov/cc-1c-skills) | ~80 skill cho Claude Code / Cursor / Codex: tạo / sửa / kiểm tra metadata, form, DCS, role, MXL, extension trên bản dump XML; build `.epf`; infobase; web publish; **kiểm thử qua web client, quay video có phụ đề + TTS** | MIT · RU | Bản Python chạy được Linux; `form-validate`, `skd-validate` không cần platform (đã thử trên repo khóa — không bắt được handler mồ côi) |
| [Desko77/claude-code-skills-1c](https://github.com/Desko77/claude-code-skills-1c) | Bộ skill phái sinh từ cc-1c-skills: ~120 skill, ~40 rule, validator, tham chiếu SSL | MIT · RU | Tham khảo cách đóng gói rule |
| [Roman-repo/1c-dev-rules](https://github.com/Roman-repo/1c-dev-rules) | Đóng gói chuẩn v8std thành rule "tóm tắt + checklist + ví dụ sai / đúng" | MIT · RU | Mô hình đã áp dụng cho `chuan-phat-trien.md` |
| [feenlace/mcp-1c](https://github.com/feenlace/mcp-1c) | MCP server (Go): tra cứu metadata, trợ giúp cú pháp ~180 hàm có **đồng nghĩa RU ↔ EN**, gợi ý tối ưu query | MIT · RU | (b) dùng AI agent, (c) |
| [itrous/bsl-analyzer](https://github.com/itrous/bsl-analyzer) | Bộ phân tích BSL mới (LSP + MCP), ~180 chẩn đoán, tài liệu RU/EN | MIT / Apache-2.0 (một phần EPL-2.0) · beta | (c) thử nghiệm |
| [DitriXNew/EDT-MCP](https://github.com/DitriXNew/EDT-MCP), [Untru/1c-mcp](https://github.com/Untru/1c-mcp) | MCP cho 1C:EDT (GPL-3.0); danh mục cập nhật các MCP / skill cho 1C (không giấy phép → chỉ link) | — | (c) theo dõi hệ sinh thái |
| [comol/ai_rules_1c](https://github.com/comol/ai_rules_1c) | Bộ rule / subagent cho Cursor | **không giấy phép** → chỉ link | (c) |

**Phù hợp:** người dùng agent trên máy có cài platform, làm dự án thật. **Không phù hợp:** sinh viên mới chỉ dùng chat — người học nên tự thao tác Designer để học. Skill này là **gia sư** (giải thích, gợi ý, review, chính sách đưa code); các bộ trên là "tay chân" thao tác file — dùng song song được.

## 5. Không nên dùng / hạ ưu tiên

| Nguồn | Lý do |
|---|---|
| xDrivenDevelopment/xUnitFor1C | Dừng từ 2018, ordinary forms → dùng YAxUnit |
| EvilBeaver/oscript-library | Đã archive 2021 → dùng thư viện mới của tổ chức `oscript-library` |
| 1c-syntax/ssl_int | Dừng 2021 → dùng `ssl_3_1_eng` |
| vanessa-opensource/add | Còn dùng được nhưng hướng mới là YAxUnit + Vanessa Automation |
| tormozit/RDT1C, infostart-hub/snegopat | Công cụ mạnh nhưng tiếng Nga, giấy phép không rõ / chỉ Configurator 32-bit — không đưa vào bài giảng |
| Công cụ đặt lại / dò mật khẩu 1C | Không phù hợp giảng dạy (rủi ro bảo mật) |
| Repo "learn 1C" nội dung rỗng, code sinh EPF bằng AI giấy phép GPL | Không có giá trị học / không trích được |

Không tìm thấy repo chính thức của 1C cho **1C:Enterprise.Element** (chỉ có công cụ cộng đồng chưa chính thức) — nếu người dùng hỏi, nói rõ điều này.



---

# § ssl-api-en

# SSL (Standard Subsystems Library) — tên API tiếng Anh hay dùng

> **Khi nào đọc file này:** người dùng làm trên cấu hình có SSL (Jet, SSL Demo của Bài 21–23, 1C:Company Management, AccountingSuite…) và cần đúng **tên tiếng Anh** của module / hàm SSL; khi đọc code hay tài liệu tiếng Nga có `ОбщегоНазначения…`, `УправлениеПечатью…` và cần tên tương ứng. Bài liên quan: B21–B23, Extensions; Jet: `jet/jet-overview.md` (Jet nhúng SSL 3.1.10).
>
> Nguồn kiểm chứng: SSL **World edition 3.1.12.175** (bản tiếng Anh, mirror `1c-syntax/ssl_3_1_eng`, tháng 4/2026). Chữ ký dưới đây chép từ bản đó — **phiên bản SSL khác có thể khác tham số** (SSL 2.x trong cấu hình cũ như AccountingSuite, Company Management đời cũ): luôn mở module trong cấu hình thật của người dùng (Designer → Common modules → tìm tên hàm, đọc doc-comment) trước khi khẳng định. Chỉ trích tên và chữ ký hàm, không chép nguyên module.

## 1. Module ↔ tên tiếng Nga

| English | Русский | Ngữ cảnh |
|---|---|---|
| `Common` | ОбщегоНазначения | Server |
| `CommonClient` | ОбщегоНазначенияКлиент | Client |
| `CommonClientServer` | ОбщегоНазначенияКлиентСервер | Client + Server |
| `CommonServerCall` | ОбщегоНазначенияВызовСервера | Server call |
| `StandardSubsystemsClient` / `StandardSubsystemsServer` | СтандартныеПодсистемыКлиент / …Сервер | |
| `PrintManagement` / `PrintManagementClient` / `PrintManagementOverridable` | УправлениеПечатью / …Клиент / …Переопределяемый | B22 |
| `AdditionalReportsAndDataProcessors` | ДополнительныеОтчетыИОбработки | B21, Intern Task 6–7 |
| `TimeConsumingOperations` / `TimeConsumingOperationsClient` | ДлительныеОперации / …Клиент | |
| `FilesOperations` / `FilesOperationsClient` | РаботаСФайлами / …Клиент | B23 |
| `AccessManagement` | УправлениеДоступом | B20 |
| `Users` / `UsersClient` | Пользователи / …Клиент | |
| `ReportsOptions` | ВариантыОтчетов | |
| `ObjectAttributesLock` | ЗапретРедактированияРеквизитовОбъектов | |
| `InfobaseUpdate` | ОбновлениеИнформационнойБазы | |
| `ObjectsPrefixesEvents` | ПрефиксацияОбъектовСобытия | |
| `PropertyManager` | УправлениеСвойствами | Additional attributes (Jet dùng) |
| `ContactsManager` | УправлениеКонтактнойИнформацией | |
| `AttachableCommands` | ПодключаемыеКоманды | |
| `BatchEditObjects` | ГрупповоеИзменениеОбъектов | |
| `CurrencyRateOperations` | РаботаСКурсамиВалют | |
| `…Overridable` (`CommonOverridable`, `AccessManagementOverridable`…) | …Переопределяемый | Nơi **được phép** viết code tích hợp — không sửa module lõi |

## 2. Hàm hay dùng (chữ ký theo SSL 3.1.12 World edition)

| Việc cần làm | API |
|---|---|
| Thông báo gắn ô (server) | `Common.MessageToUser(MessageToUserText, DataKey = Undefined, Field = "", DataPath = "", Cancel = False)` |
| Thông báo gắn ô (client) | `CommonClient.MessageToUser(MessageToUserText, DataKey = Undefined, …)` |
| Đọc một thuộc tính của ref (không đọc cả object) | `Common.ObjectAttributeValue(Ref, AttributeName, SelectAllowedItems = False, LanguageCode = Undefined)` |
| Đọc nhiều thuộc tính | `Common.ObjectAttributesValues(Ref, Attributes, …)` — `Attributes` là chuỗi "A, B" hoặc Array → Structure |
| Một thuộc tính của nhiều ref | `Common.ObjectsAttributeValue(ReferencesArray, AttributeName, …)` → Map |
| Kiểm tra subsystem có trong cấu hình | `Common.SubsystemExists(FullSubsystemName)` / `CommonClient.SubsystemExists(…)`; gọi module có thể không tồn tại qua `Common.CommonModule(Name)` |
| Ref có tồn tại trong DB | `Common.RefExists(Ref)` |
| Kiểm tra chứng từ đã post | `Common.CheckDocumentsPosting(Documents)` |
| Ngày phiên ở client | `CommonClient.SessionDate()` |
| Hỏi người dùng (không modal) | `StandardSubsystemsClient.ShowQuestionToUser(CallbackDescriptionOnCompletion, QueryText, Buttons, AdditionalParameters = Undefined)` |
| Mở URL | `CommonClient.OpenURL(URL, Notification = Undefined)` |
| Lưu mật khẩu / token an toàn | `Common.WriteDataToSecureStorage(Owner, Data, Key = "Password")`, `Common.ReadDataFromSecureStorage(…)` |
| Người dùng hiện tại | `Users.CurrentUser()`, `Users.AuthorizedUser()` |
| Kiểm tra role | `AccessManagement.HasRole(Role, ObjectReference = Undefined, User = Undefined)` |
| Dynamic list | `CommonClientServer.SetDynamicListParameter(List, ParameterName, Value, Use = True)`, `CommonClientServer.SetDynamicListFilterItem(DynamicList, FieldName, …)` |
| Thuộc tính form item | `CommonClientServer.SetFormItemProperty(FormItems, TagName, PropertyName, Value)` |
| Mảng, Structure | `CommonClientServer.SupplementArray(Destination, Source, UniqueValuesOnly = False)`, `DeleteValueFromArray(Array, Value)`, `ArraysDifference(Array, SubtractionArray)`, `SupplementStructure(Receiver, Source, Replace = Undefined)`; `Common.ValueTableToArray(ValueTable)`, `Common.CopyRecursive(Source)` |
| In (server, trong `Print()` của manager module) | `PrintManagement.MustPrintTemplate(PrintFormsCollection, TemplateName)`; `PrintManagement.PrintFormTemplate(TemplatePath, LanguageCode = Undefined)` — `TemplatePath` dạng `"Document.X.PF_MXL_Name"` hoặc `"CommonTemplate.Name"`; `PrintManagement.OutputSpreadsheetDocumentToCollection(PrintFormsCollection, TemplateName, TemplateSynonym, SpreadsheetDocument, Picture = Undefined, FullTemplatePath = "", PrintFormFileName = Undefined)`; `PrintManagement.SetDocumentPrintArea(SpreadsheetDocument, RowNumberStart, PrintObjects, Ref)` |
| Đăng ký object có lệnh in | `PrintManagementOverridable.OnDefinePrintSettings(Settings)` |
| Gọi lệnh in từ client | `PrintManagementClient.ExecutePrintCommand(PrintManagerName, TemplatesNames, ObjectsArray, FormOwner, PrintParameters = Undefined)` |
| Đăng ký external data processor / report | `AdditionalReportsAndDataProcessors.ExternalDataProcessorInfo(SSLVersion = "")` trong `ExternalDataProcessorInfo()` của object module |
| Chạy nền | `TimeConsumingOperations.ExecuteFunction(ExecutionParameters, FunctionName, …)` / `ExecuteInBackground(ProcedureName, ProcedureParameters, ExecutionParameters)`; tham số: `FunctionExecutionParameters(FormIdentifier)` / `BackgroundExecutionParameters(…)`; client chờ: `TimeConsumingOperationsClient.WaitCompletion(TimeConsumingOperation, CallbackOnCompletion = Undefined, …)` |
| File đính kèm | `FilesOperations.FileBinaryData(AttachedFile, RaiseException = True)`, `FilesOperations.AppendFile(FileParameters, FileAddressInTempStorage, …)` |

## 3. Khối tích hợp chuẩn trong object của cấu hình

SSL nhúng vào object của cấu hình bằng các khối có chú thích `// StandardSubsystems.<Subsystem>` … `// End StandardSubsystems.<Subsystem>` (tiếng Nga: `// СтандартныеПодсистемы.…`). Khi thêm object mới (chứng từ, catalog) vào cấu hình SSL: chép khối tương ứng từ một object có sẵn (ví dụ form có Print, Attachable commands, Additional attributes), sửa tên object; đăng ký object ở module `…Overridable` của subsystem. Không xóa khối của object có sẵn khi tùy biến — ưu tiên extension (`bai-extensions.md`).


---

# § thuat-ngu-ru-en

# Bảng đối chiếu cú pháp và thuật ngữ Nga ↔ Anh ↔ Việt

> **Khi nào đọc file này:** người dùng dán code **cú pháp tiếng Nga** (Процедура, Если…), đọc tài liệu / repo cộng đồng (phần lớn bằng tiếng Nga), hoặc cần chuyển một đoạn code sang cú pháp tiếng Anh của khóa. Thuật ngữ tiếng Việt dùng trong khóa: `terminology.md` (giữ nguyên tên tiếng Anh cho object, chỉ giải thích bằng tiếng Việt).
>
> Platform hiểu **cả hai** cú pháp trong cùng một cấu hình (thuộc tính *Script variant* của cấu hình chỉ quyết định cú pháp khi Designer sinh code mới). Khi chuyển code: đổi từ khóa và tên hàm theo bảng; **tên object metadata** (Справочники.Номенклатура) giữ theo cấu hình thật — đổi tên metadata là việc khác. Bảng dưới là đối chiếu phổ biến; hàm ít gặp hãy tra Syntax Assistant (hiện cả hai tên).

## 1. Từ khóa của ngôn ngữ

| Русский | English | | Русский | English |
|---|---|---|---|---|
| Процедура / КонецПроцедуры | Procedure / EndProcedure | | Функция / КонецФункции | Function / EndFunction |
| Экспорт | Export | | Знач | Val |
| Перем | Var | | Возврат | Return |
| Если / Тогда / ИначеЕсли / Иначе / КонецЕсли | If / Then / ElsIf / Else / EndIf | | Для / По / Цикл / КонецЦикла | For / To / Do / EndDo |
| Для Каждого … Из … Цикл | For Each … In … Do | | Пока … Цикл | While … Do |
| Продолжить / Прервать | Continue / Break | | Попытка / Исключение / КонецПопытки | Try / Except / EndTry |
| ВызватьИсключение | Raise | | Новый | New |
| И / Или / Не | And / Or / Not | | Истина / Ложь / Неопределено / NULL | True / False / Undefined / NULL |
| ЭтотОбъект | ThisObject | | ?(усл, a, b) | ?(cond, a, b) |
| #Область / #КонецОбласти | #Region / #EndRegion | | #Если Сервер Тогда … #КонецЕсли | #If Server Then … #EndIf |
| &НаКлиенте | &AtClient | | &НаСервере | &AtServer |
| &НаСервереБезКонтекста | &AtServerNoContext | | &НаКлиентеНаСервереБезКонтекста | &AtClientAtServerNoContext |
| &Перед / &После / &Вместо / &ИзменениеИКонтроль | &Before / &After / &Around / &ChangeAndValidate | | ПродолжитьВызов() | ProceedWithCall() |
| #Вставка / #КонецВставки / #Удаление / #КонецУдаления | #Insert / #EndInsert / #Delete / #EndDelete | | Асинх / Ждать | Async / Await |

## 2. Hàm và đối tượng hay gặp

| Русский | English | Ghi chú |
|---|---|---|
| Сообщить() | Message() | Code mới dùng `UserMessage` |
| СообщениеПользователю | UserMessage | |
| ЗначениеЗаполнено() | ValueIsFilled() | |
| ТипЗнч() / Тип() | TypeOf() / Type() | |
| СтрШаблон / СтрНайти / СтрРазделить / СтрСоединить | StrTemplate / StrFind / StrSplit / StrConcat | |
| СокрЛП / Лев / Прав / Сред / ВРег / НРег | TrimAll / Left / Right / Mid / Upper / Lower | |
| Формат() / Число() / Строка() / Дата() | Format() / Number() / String() / Date() | |
| ТекущаяДатаСеанса() / ТекущаяДата() | CurrentSessionDate() / CurrentDate() | Ưu tiên CurrentSessionDate |
| НачалоДня / КонецДня / НачалоМесяца / КонецМесяца / ДобавитьМесяц | BegOfDay / EndOfDay / BegOfMonth / EndOfMonth / AddMonth | |
| Мин() / Макс() / Окр() | Min() / Max() / Round() | |
| Запрос / РезультатЗапроса / Выборка | Query / QueryResult / Selection (QueryResultSelection) | |
| УстановитьПараметр / Выполнить / Выбрать / Следующий / Выгрузить | SetParameter / Execute / Select / Next / Unload | |
| ВыполнитьПакет() / МенеджерВременныхТаблиц | ExecuteBatch() / TempTablesManager | |
| ТаблицаЗначений / Массив / Структура / Соответствие / СписокЗначений / ДеревоЗначений | ValueTable / Array / Structure / Map / ValueList / ValueTree | |
| НайтиСтроки / Найти / Итог / Свернуть / ВыгрузитьКолонку | FindRows / Find / Total / GroupBy / UnloadColumn | |
| Движения / НаборЗаписей / Записывать / Записать() | RegisterRecords / RecordSet / Write (= True) / Write() | |
| ДобавитьПриход() / ДобавитьРасход() / ВидДвиженияНакопления.Приход / Расход | AddReceipt() / AddExpense() / AccumulationRecordType.Receipt / Expense | |
| МоментВремени() / Граница / ВидГраницы.Включая / Исключая | PointInTime() / Boundary / BoundaryType.Including / Excluding | |
| БлокировкаДанных / ЭлементБлокировкиДанных / РежимБлокировкиДанных.Исключительный / Заблокировать() | DataLock / DataLockItem / DataLockMode.Exclusive / Lock() | |
| ИсточникДанных / ИспользоватьИзИсточникаДанных | DataSource / UseFromDataSource | |
| НачатьТранзакцию / ЗафиксироватьТранзакцию / ОтменитьТранзакцию | BeginTransaction / CommitTransaction / RollbackTransaction | |
| ЗаписьЖурналаРегистрации / УровеньЖурналаРегистрации.Ошибка | WriteLogEvent / EventLogLevel.Error | |
| ИнформацияОбОшибке / ПодробноеПредставлениеОшибки / КраткоеПредставлениеОшибки | ErrorInfo / DetailErrorDescription / BriefErrorDescription | Bản mới: `ErrorProcessing.DetailErrorDescription` |
| ОбменДанными.Загрузка | DataExchange.Load | |
| ДополнительныеСвойства | AdditionalProperties | |
| ПолучитьОбъект() / Записать(РежимЗаписиДокумента.Проведение) | GetObject() / Write(DocumentWriteMode.Posting) | |
| ОткрытьФорму / ОписаниеОповещения / ВыполнитьОбработкуОповещения | OpenForm / NotifyDescription (CallbackDescription) / RunCallback | |
| ПоказатьПредупреждение / ПоказатьВопрос | ShowMessageBox / ShowQueryBox | Modal cũ: Предупреждение / Вопрос = DoMessageBox / DoQueryBox |
| Элементы / ТекущиеДанные / Объект / Параметры | Items / CurrentData / Object / Parameters | |
| РеквизитФормыВЗначение / ЗначениеВРеквизитФормы | FormAttributeToValue / ValueToFormAttribute | |
| ПоместитьВоВременноеХранилище / ПолучитьИзВременногоХранилища | PutToTempStorage / GetFromTempStorage | |
| ТабличныйДокумент / ПолучитьОбласть / Вывести | SpreadsheetDocument / GetArea / Put | |
| HTTPСоединение / HTTPЗапрос / ЗащищенноеСоединениеOpenSSL | HTTPConnection / HTTPRequest / OpenSSLSecureConnection | |
| ЧтениеJSON / ЗаписьJSON / ПрочитатьJSON / ЗаписатьJSON | JSONReader / JSONWriter / ReadJSON / WriteJSON | |

## 3. Metadata và handler

| Русский | English | Việt (giải thích) |
|---|---|---|
| Справочник / Документ / Перечисление / Константа | Catalog / Document / Enum / Constant | danh mục / chứng từ / liệt kê / hằng |
| РегистрНакопления (Остатки / Обороты) | AccumulationRegister (Balance / Turnovers) | register tích lũy (số dư / phát sinh) |
| РегистрСведений (периодический, подчинен регистратору) | InformationRegister (periodic, subordinate to recorder) | register thông tin |
| РегистрБухгалтерии / ПланСчетов / Субконто | AccountingRegister / ChartOfAccounts / ExtDimension | sổ kế toán / hệ thống tài khoản / chiều phân tích |
| ПланВидовХарактеристик | ChartOfCharacteristicTypes | |
| Обработка / Отчет / ОбщийМодуль / ОбщаяФорма / ОбщаяКоманда | DataProcessor / Report / CommonModule / CommonForm / CommonCommand | |
| Роль / ФункциональнаяОпция / Подсистема / ПодпискаНаСобытие / РегламентноеЗадание | Role / FunctionalOption / Subsystem / EventSubscription / ScheduledJob | |
| ПланОбмена / HTTP-сервис / Расширение конфигурации | ExchangePlan / HTTP service / Configuration extension | |
| Остатки() / Обороты() / ОстаткиИОбороты() / СрезПоследних() | .Balance() / .Turnovers() / .BalanceAndTurnovers() / .SliceLast() | virtual table |
| ОбработкаПроведения / ОбработкаПроверкиЗаполнения / ОбработкаЗаполнения | Posting / FillCheckProcessing / Filling | |
| ПередЗаписью / ПриЗаписи / ПриКопировании / ПередУдалением / ПриУстановкеНовогоНомера | BeforeWrite / OnWrite / OnCopy / BeforeDelete / OnSetNewNumber | |
| ПриСозданииНаСервере / ПриОткрытии / ПриЧтенииНаСервере / ПередЗаписьюНаСервере / ПослеЗаписи | OnCreateAtServer / OnOpen / OnReadAtServer / BeforeWriteAtServer / AfterWrite | |
| ПриИзменении / НачалоВыбора / ОбработкаВыбора / ПослеУдаления | OnChange / StartChoice / ChoiceProcessing / AfterDeleteRow | |
| СКД (система компоновки данных) / Макет / Печатная форма | DCS (Data composition system) / Template / Print form | |
| БСП (Библиотека стандартных подсистем) | SSL (Standard Subsystems Library) | xem `ssl-api-en.md` |
| Конфигуратор / Предприятие / Синтакс-помощник / Консоль запросов | Designer / 1C:Enterprise mode / Syntax Assistant / Query console | |
| ИТС / Стандарты разработки | ITS / Development Standards | `chuan-phat-trien.md` |

## 4. Query language

| Русский | English |
|---|---|
| ВЫБРАТЬ / РАЗЛИЧНЫЕ / ПЕРВЫЕ n / РАЗРЕШЕННЫЕ | SELECT / DISTINCT / TOP n / ALLOWED |
| ИЗ / ГДЕ / СГРУППИРОВАТЬ ПО / ИМЕЮЩИЕ / УПОРЯДОЧИТЬ ПО / ИТОГИ … ПО | FROM / WHERE / GROUP BY / HAVING / ORDER BY / TOTALS … BY |
| ПОМЕСТИТЬ / УНИЧТОЖИТЬ | INTO / DROP |
| ЛЕВОЕ / ВНУТРЕННЕЕ / ПОЛНОЕ СОЕДИНЕНИЕ … ПО | LEFT / INNER / FULL JOIN … ON |
| ОБЪЕДИНИТЬ ВСЕ | UNION ALL |
| ЕСТЬNULL / ВЫБОР КОГДА … ТОГДА … ИНАЧЕ … КОНЕЦ / ВЫРАЗИТЬ … КАК | ISNULL / CASE WHEN … THEN … ELSE … END / CAST … AS |
| В / В ИЕРАРХИИ / ПОДОБНО / МЕЖДУ | IN / IN HIERARCHY / LIKE / BETWEEN |
| СУММА / КОЛИЧЕСТВО / МАКСИМУМ / МИНИМУМ / СРЕДНЕЕ | SUM / COUNT / MAX / MIN / AVG |
| ЗНАЧЕНИЕ(Перечисление.X.Y) / НАЧАЛОПЕРИОДА(…, ДЕНЬ) / ДОБАВИТЬКДАТЕ | VALUE(Enum.X.Y) / BEGINOFPERIOD(…, DAY) / DATEADD |
| ДЛЯ ИЗМЕНЕНИЯ | FOR UPDATE |
