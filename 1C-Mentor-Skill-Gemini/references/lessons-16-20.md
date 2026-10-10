# Tài liệu gộp: lessons-16-20

Gồm các mục: § bai-16, § bai-17, § bai-18, § bai-19, § bai-20


---

# § bai-16

# Bài 16 — Events (object/form/form element events) và Event subscriptions

## Khái niệm chính

### Tổng quan về events
- Khi làm việc với catalogs, documents, registers và form của chúng, nhiều event được kích hoạt. Ví dụ tạo document mới ở interactive mode: **Filling** (object module), **OnCreateAtServer** và **OnOpen** (form module).
- Một số event có hành vi chuẩn của platform, có thể override bằng cách đổi tham số **StandardProcessing** từ True sang False. Ví dụ field "Text box" có event **StartChoice**; tắt standard processing → bấm nút choice không xảy ra gì (thay vì mở choice form cho reference attribute, mở bảng nhập số cho attribute kiểu Number...). Có thể tắt rồi tự mở custom form.

### Cách tìm events và gán handler
- **Object / manager / record set modules / root modules** (application, session, external connection module):
  - Danh sách event nằm trong list procedures and functions của module; handler có thể gán được hiển thị trong **dấu ngoặc nhọn `< >`**. "Go to" hoặc double click → thêm handler vào module.
  - Handler **phải có tên chuẩn**. Procedure tên `BeforeWrite` tự động được coi là handler của event BeforeWrite, **kể cả khi tham số khác chuẩn**. (Ví dụ: đổi `BeforeWrite1` → `BeforeWrite` thì event BeforeWrite không còn trong danh sách để tạo.)
- **Form modules** (form và form elements):
  - Danh sách event ở **properties palette** và context menu của element.
  - Event phải được **gán tường minh** với handler; tên procedure tuỳ ý (khuyến nghị giữ mặc định). Mặc định: event của form → tên trùng tên event; event của element → `<FormElementName>` + `<EventName>` (ví dụ OnChange của field Carrier → `CarrierOnChange()`).
  - Từ properties palette có thể tạo mới **hoặc gán procedure có sẵn**.
  - Có thể tạo một handler chung cho nhiều field (ví dụ field Price trong 2 tabular sections Products và Services để tính lại amount) — đặt tên không gắn với element cụ thể.
  - Danh sách handler có thể chọn được lọc theo **số lượng tham số** của procedure.
  - Platform **không kiểm soát** liên kết event–handler khi rename/xoá procedure. Handler không tồn tại = như không có handler → event xử lý theo chuẩn. Phát hiện bằng cách thử "go to handler" từ palette/context menu.
  - Khuyến nghị thao tác từ **Properties palette**:
    - Rename: sửa tên trong ô event trên palette → platform đề nghị rename procedure. Nếu từ chối → tạo procedure mới, procedure cũ vẫn còn nhưng không còn là handler.
    - Xoá: clear ô event trên palette → platform đề nghị xoá procedure khỏi module.

### Thứ tự events (writing/posting)
- Sơ đồ ghi catalog item và sơ đồ post document chỉ khác nhau ở event **Posting** (chỉ có khi post, không có khi chỉ write).
- Thời điểm **FillCheckProcessingAtServer** (form) / **FillCheckProcessing** (object) khi làm interactive phụ thuộc property **Posting** của document: bật → check khi post; tắt → check khi write, và document không có lệnh post/undo posting.
- Thứ tự:
  1. **Form module. BeforeWrite(Cancel, WriteParameters)** — client, chạy đầu tiên khi write/post/undo posting. Dùng cho check client, chuẩn bị dữ liệu chỉ có ở client, tương tác user (cancel ghi tới khi có trả lời, rồi ghi lại từ code với một cờ báo không cần hỏi nữa).
     - **WriteParameters**: structure có kiểu định sẵn theo loại object; catalog → rỗng; document → 2 property:
       - **WriteMode** (kiểu `DocumentWriteMode`): Write, Posting, UndoPosting
       - **PostingMode** (kiểu `DocumentPostingMode`): RealTime, Regular
     - Có thể bổ sung property bất kỳ để truyền dữ liệu từ client sang BeforeWriteAtServer, OnWriteAtServer, AfterWriteAtServer.
  2. **Form module. FillCheckProcessingAtServer(Cancel, CheckedAttributes)** và **Object module. FillCheckProcessing(Cancel, CheckedAttributes)** — giống nhau, một cho form/attribute của form, một cho object/attribute/tabular sections. Attribute có **"Required field"** = "Display error" → path vào mảng **CheckedAttributes**. Form có property **"AutoFillCheck"** (mặc định bật); tắt → ghi interactive từ form không gọi cả 2 event.
     - Cả 2 chỉ chạy khi ghi **interactive**. Ghi bằng code không gọi → dùng method **`CheckFilling()`** của object để kích hoạt.
     - Ví dụ: form có attributes City, District, Street, Building, Apartment (bắt buộc khi bật cờ "delivery required"), BeforeWriteAtServer ghép thành attribute DeliveryAddress của document theo quy tắc.
  3. **Form module. BeforeWriteAtServer(Cancel, CurrentObject, WriteParameters)** — server. Form đã được "tách" thành form và applied object sẽ ghi vào DB.
     - **CurrentObject** có kiểu "object" class (CatalogObject, DocumentObject...) — instance đã tạo nhưng chưa ghi vào DB.
     - Mọi thay đổi phải làm qua **CurrentObject**; sửa qua form attribute **Object** không có tác dụng (chỉ nên read-only, tốt nhất không dùng). Sau khi write transaction xong, dữ liệu từ CurrentObject được ghi vào Object.
     - Ghi object bằng code → event này (và mọi event trong form module) **không được gọi**. Thuật toán phải chạy với mọi cách ghi → đặt trong handler của object (**BeforeWrite**).
  4. **— Start of transaction —**
  5. **Object module. BeforeWrite(Cancel, WriteMode, PostingMode)** — event đầu tiên sau khi bắt đầu transaction. Với document có thêm WriteMode và PostingMode (chính là các property trong WriteParameters ở form).
     - Dùng để hoàn thiện object (ví dụ TotalAmount = tổng các tabular sections Products, Services...), chuẩn bị dữ liệu cho bước sau (ví dụ so sánh status cũ lấy qua reference với status hiện tại, ghi vào **AdditionalProperties** việc status có đổi không để sau đó ghi vào register).
     - Huỷ ghi → tham số **Cancel**.
     - Tới cuối event, object **chưa** được ghi vào DB; đọc dữ liệu qua reference sẽ là dữ liệu cũ (không có thay đổi của user trên form và của BeforeWriteAtServer/BeforeWrite).
  6. **Object module. OnWrite(Cancel)** — event đầu tiên sau khi object ghi vào DB; object mới đã có reference. Dùng để ghi dữ liệu liên quan đến object (ví dụ lịch sử status: *Document ref - State - Date - Author*). Lỗi → huỷ transaction tường minh (raise exception hoặc Cancel) hoặc ngầm định (exception như chia cho 0). Không lỗi → document và status ghi trong **một transaction**.
  7. **Object module. Posting(Cancel, PostingMode)** — chỉ khi post (interactive hoặc bằng code). Posting tắt → không bao giờ chạy. Mục đích: tạo và ghi movements vào registers, kiểm tra liên quan (ví dụ không âm tồn kho). PostingMode: real-time hoặc backdated. Nếu bật tự động xoá movements trên tab **Posting** (mặc định cho document mới) → mọi register records của document bị xoá tự động trước event; nếu không phải xoá bằng code.
  8. **Form module. OnWriteAtServer(Cancel, CurrentObject, WriteParameters)** — sau khi ghi object vào DB nhưng trước khi kết thúc transaction; **event cuối cùng có thể huỷ ghi** trong transaction.
     - Mục đích: ghi thông tin bổ sung. Tương tự OnWrite của object module: dữ liệu nằm trong object → dùng OnWrite(); dữ liệu nằm trên form → dùng event này. Cũng dùng khi cần WriteParameters.
     - CurrentObject (DocumentObject) chứa dữ liệu đã ghi; gọi được export methods của object.
     - Object mới: `CurrentObject.Ref` có reference; `Object.Ref` vẫn là empty ref.
     - Kết luận: thao tác với object đã ghi → CurrentObject; cần ref của object mới → `CurrentObject.Ref`; form attribute Object chỉ để so sánh "trước" và "đã ghi"; cần ghi dữ liệu bổ sung dựa trên form data + object data → dùng handler này.
     - Ví dụ: lưu các giá trị City/District mới nhập (auto-completion "San" → San Francisco, San Diego; user nhập San Sebastian) vào object riêng trong transaction, tránh tạo record thừa nếu document không ghi được.
  9. **— Completing the transaction —**
  10. **Form module. AfterWriteAtServer(CurrentObject, WriteParameters)** — sau khi transaction xong, dữ liệu object được chuyển thành form data rồi gọi handler. **Không có Cancel** (quá muộn). Handler cuối cùng mà form data và object đã ghi còn tách biệt.
      - Dùng cho thao tác trên form chỉ làm khi object chắc chắn đã ghi (ví dụ hiển thị thông tin bổ sung).
      - Sửa CurrentObject **vô nghĩa** (dữ liệu đã nạp vào Object, CurrentObject bị huỷ khi thoát handler), nhưng dùng được để đọc property/gọi export methods.
      - WriteParameters vẫn còn.
      - Ví dụ: cột form attribute **SoldThisMonth** trong tabular section của Sales invoice, query sales turnovers từ đầu tháng tới cuối ngày của document date để điền cột.
  11. **Form module. AfterWrite(WriteParameters)** — client, event chính cuối cùng. Sau AfterWriteAtServer: form gửi về client, application object bị huỷ trong server memory, form object trên server bị huỷ. Dùng để hiển thị trên form, hội thoại với user (warning), thông báo cho user hoặc các form đang mở rằng object đã đổi.

### Events khi đóng form (client, cấm server call)
- **Form module. BeforeClose(Cancel, Exit, WarningText, StandardProcessing)** — quyết định form có được đóng không.
  - `Cancel = True` → form không đóng.
  - `StandardProcessing = False` → form đóng **không hỏi** dù dữ liệu đã bị sửa (bình thường platform hỏi write / đóng không lưu / huỷ đóng).
  - **Exit** = True khi user đóng main application window; đóng form riêng → False.
  - **WarningText** — text hiển thị khi đóng app hoặc khi từ chối đóng form (web client gộp mọi message vào một dialog). Không set → "The data is changed. All changes will be lost."
  - Hội thoại với user: question dialog là **non-modal** → chia 2 phần: (1) hỏi, set Cancel = True; (2) trong response handler, nếu đồng ý → set attribute (ví dụ `CloseWithoutChecking`, Boolean, mặc định False) = True rồi gọi `Close()`.
  - Item form/document form/record form đã được platform tự kiểm soát mất dữ liệu; common forms, data processor forms, list/choice forms thì platform hiếm khi kiểm tra → đôi khi phải tự làm.
- **Form module. OnClose(Exit)** — form đã đóng (user không thấy) nhưng program object vẫn còn. Dùng cho thao tác chỉ làm khi form chắc chắn đóng: đóng auxiliary form phụ thuộc, tắt trading equipment kết nối ở OnOpen. **Không thể** từ chối đóng ở đây. Sau event, form object bị xoá khỏi client memory.

### Form field events (input field)
- **StartChoice(Item, ChoiceData, StandardProcessing)**
  - **Item**: form element kích hoạt event (ví dụ field `ProductsProduct` của form table).
  - **ChoiceData**: danh sách cho user chọn, thường là Undefined; có thể set `StandardProcessing = False` và gán **ValueList** (khi danh sách nhỏ, tới khoảng 10 phần tử, không cần mở form riêng).
  - Có thể tắt standard processing và mở choice form với thuật toán riêng. Truyền field vào tham số **"Owner"** của `OpenForm` → giá trị chọn tự động điền vào ô, không cần xử lý choice event riêng.
  - Ví dụ: document PersonnelChange, operation "Dismissal" → chỉ chọn nhân viên đang làm việc. Tạo choice form mới cho catalog Employees (**không** đặt làm default choice form), dynamic list bật **CustomQuery**, query catalog Employees + information register Employees (catalog làm main table để platform trả về ref). OnCreateAtServer kiểm tra form parameters có property **Filter**, nếu không → raise exception; điền parameters Date và Company cho dynamic list từ Filter. StartChoice: nếu operation kind = Dismissal → StandardProcessing = False, mở form với filter date + company và Item làm owner.
  - Date field: nút chọn là calendar; number field: calculator — vẫn là cùng choice button, cùng event.
- **Clearing(Item, StandardProcessing)** — lệnh clear (nút clear bật bằng property **"ClearButton"** = Yes, hoặc hotkey **Shift + F4**). Dùng cho thao tác liên quan (xoá Customer thì xoá cả Contract). `StandardProcessing = False` → không xoá giá trị.
- **Tuning(Item, Direction, StandardProcessing)** — nút scroll (property **SpinButton** = Yes). **Direction** kiểu Number: 1 = up/increase, -1 = down/decrease. Không nhất thiết là số (ví dụ chuyển tháng <Month Year>).
- **Opening(Item, StandardProcessing)** — nút open (property **"OpenButton"** = Yes). Mặc định có cho field liên kết reference attribute; tắt bằng OpenButton = No. Bật cho kiểu primitive → standard mở cửa sổ hiển thị giá trị dạng string. Override bằng StandardProcessing = False.
- **ChoiceProcessing(Item, SelectedValue, StandardProcessing)** — sau khi user chọn giá trị nhưng **trước khi** đặt vào field. Có thể:
  - từ chối lựa chọn (`StandardProcessing = False`);
  - đặt giá trị khác (`SelectedValue`).
  - Lý do không giới hạn danh sách từ đầu: (1) usability — user không hiểu vì sao không chọn được supplier có thật → cho chọn rồi báo lỗi và huỷ; (2) kỹ thuật — kiểm tra từng phần tử tốn kém (ví dụ 49 phần tử), chỉ kiểm tra phần tử được chọn.
  - Đặt giá trị khác kiểu: field kiểu string, danh sách chọn là catalog elements → đặt presentation thay vì ref.

### Form table events
- Tập handler phụ thuộc kiểu dữ liệu liên kết (value table, value tree, tabular section, dynamic list, value list).
- **OnChange(Item)** — gọi khi có bất kỳ thay đổi nào trong một row (4 cột → điền 4 cột = 4 lần event). Không dùng cho mọi trường hợp (ví dụ không dùng để tính amount khi đổi quantity/price); chỉ dùng khi thuật toán phải chạy mỗi lần row đổi, hoặc cùng một thuật toán nhẹ cho nhiều event ở nhiều cột. Thêm/xoá row **không** kích hoạt event.
- **Selection(Item, SelectedRow, Field, StandardProcessing)** — double click ô, hoặc chọn row + Enter; hoặc bấm nút "Select" chuẩn khi form table liên kết main attribute bật **"Selection Mode"**.
  - **SelectedRow**: với tabular section/value table là **số identifier của row** (không phải line number) → lấy row bằng `FindByID(RowIdentifier)`.
  - **Field**: form element (cột) hiện tại → xử lý khác nhau theo cột. Hữu ích khi table **ReadOnly** (không có nút open/select trong ô).
  - `ShowValue()` hiển thị giá trị truyền ở tham số thứ hai trong dialog, không chờ đóng; loại dialog phụ thuộc kiểu giá trị.
- **OnActivateRow(Item)** — khi user chọn row: hiển thị thông tin bổ sung, filter table khác (country → cities), cập nhật property của element (availability nút).
  - **Important**: tránh **context server call** — khi về client form được cập nhật, current row bị kích hoạt lại → OnActivateRow gọi lại. Nếu cần → dùng client **Idle handler** (tham số 1: procedure; 2: khoảng thời gian; 3: một lần hay lặp).
  - Idle handler: client procedure gọi theo khoảng thời gian, bật bằng `AttachIdleHandler`; procedure phải **export** và **không có tham số**.
- **BeforeAddRow(Item, Cancel, Clone, Parent, Folder, Parameter)** — thêm row interactive (nút/hotkey). Kiểm tra có cấm thêm không → `Cancel = True`. **Clone** = True nếu thêm bằng copy. **Parent** và **Folder** chỉ có nghĩa với hierarchical catalogs và charts of characteristic types: Parent — phần tử/nhóm cha; Group (Folder) — True tạo group, False tạo element.
  - Không được dùng server method của form có directive **&AtServer** và không được đổi attribute dẫn tới server call.
- **BeforeRowChange(Item, Cancel)** — trước khi vào chế độ sửa row; override (mở form object liên quan) hoặc cấm sửa (`Cancel = True`).
- **OnStartEdit(Item, NewRow, Clone)** — sau khi vào chế độ sửa ô, trước khi thay đổi. Thường dùng cùng BeforeStartAdd: khi row thêm bằng copy → xoá một số cột (ví dụ **RowIdentifier** do developer thêm để định danh row không phụ thuộc line number); điền cột khi thêm row mới. **NewRow**: đang sửa row mới hay row cũ; **Clone**: row mới có phải copy không.
- **BeforeEditEnd(Item, NewRow, CancelEdit, Cancel)** — trước khi kết thúc sửa row (Enter, lệnh "Finish editing", click row khác); cũng xảy ra khi **Esc** → `CancelEdit = True`. Dùng để kiểm tra row ngay sau khi sửa (`Cancel = True` + thông báo). **Chỉ** gọi khi kết thúc sửa row, **không** gọi khi chuyển cột (Tab/chuột). Nên kiểm tra CancelEdit để không ép user điền khi họ bấm Esc.
- **OnEditEnd(Item, NewRow, CancelEdit)** — sau khi thoát chế độ sửa; không huỷ được. Dùng để tính dữ liệu bổ sung (tổng trọng lượng, phí giao hàng). Xảy ra **sau** OnChange của table; chọn thay OnChange khi cần NewRow và CancelEdit.

### Event subscriptions
- Cho phép đặt event handler ở module tách khỏi object, dùng một handler cho event của nhiều object (cả mọi object của một metadata class). Đặc biệt hữu ích khi customize standard configurations — thêm handler mà không đụng code chính.
- Configuration object kiểu **"Event Subscription"**, thiết lập:
  - **Source** — danh sách object types.
  - **Event** — event được xử lý.
  - **Handler** — path tới **export procedure** làm handler.
- Chọn type chung **DocumentObject / CatalogObject /...** → áp dụng cho mọi object của class, kể cả object tạo sau này.
- Chỉ chọn được **object events**, không chọn được form events.
- Danh sách event phụ thuộc Source: nhiều metadata class → chỉ còn event có ở tất cả.
- Handler: platform tìm export procedures khớp số tham số trong **common modules bật flag "Server"**; tạo mới cũng phải chọn common module có flag "Server". Platform cho chọn cả common module client-server (không phù hợp cho server events) → developer tự chọn đúng module.
- Ví dụ: subscription **FillDocumentCompany**, Source = DocumentObject, Event = **Filling**, điền company từ constant "Default Company" — thêm document mới không cần làm gì.
- Ba quy tắc (rule) điền:
  - "điền attribute trong mọi document có attribute đó" → Source = DocumentObject, code kiểm tra attribute tồn tại: lấy metadata object bằng `Metadata()`, tìm attribute theo tên trong property **Attributes**; Undefined → dừng procedure.
  - "điền từ constant cho mọi document, một số document điền khác" → Source = DocumentObject, kiểm tra type của Source để xử lý riêng.
  - "chỉ điền cho các document được chọn có attribute" → chỉ định từng document trong Source (chỉ chọn document có attribute).
- **Thứ tự thực thi event subscriptions**:
  1. Subscription chạy **ngay sau** event handler của object; chỉ chặn được event của object module, chạy trên server.
  2. Cùng source và action → chạy theo thứ tự vị trí trong cây metadata **từ trên xuống**.
  3. Subscription với source kiểu chung (DocumentObject, CatalogObject...) chạy **sau** subscription với source cụ thể (kể cả composite type).
  - Muốn subscription cho một document cụ thể chạy sau subscription chuẩn có Source = DocumentObject → cũng dùng Source DocumentObject, đặt thấp hơn trong danh sách, và kiểm tra type trong handler.

## Cú pháp & ví dụ code

```bsl
ProductRow = Object.Products.FindByID(SelectedRow);
```

```bsl
If TypeOf(Source) <> Type("DocumentObject.MyDocument") Then

    Return;

EndIf;
```

Chữ ký các handler (theo tài liệu):

```bsl
// Form module
BeforeWrite(Cancel, WriteParameters)
FillCheckProcessingAtServer(Cancel, CheckedAttributes)
BeforeWriteAtServer(Cancel, CurrentObject, WriteParameters)
OnWriteAtServer(Cancel, CurrentObject, WriteParameters)
AfterWriteAtServer(CurrentObject, WriteParameters)
AfterWrite(WriteParameters)
BeforeClose(Cancel, Exit, WarningText, StandardProcessing)
OnClose(Exit)

// Object module
FillCheckProcessing(Cancel, CheckedAttributes)
BeforeWrite(Cancel, WriteMode, PostingMode)
OnWrite(Cancel)
Posting(Cancel, PostingMode)

// Form field
StartChoice(Item, ChoiceData, StandardProcessing)
Clearing(Item, StandardProcessing)
Tuning(Item, Direction, StandardProcessing)
Opening(Item, StandardProcessing)
ChoiceProcessing(Item, SelectedValue, StandardProcessing)

// Form table
OnChange(Item)
Selection(Item, SelectedRow, Field, StandardProcessing)
OnActivateRow(Item)
BeforeAddRow(Item, Cancel, Clone, Parent, Folder, Parameter)
BeforeRowChange(Item, Cancel)
OnStartEdit(Item, NewRow, Clone)
BeforeEditEnd(Item, NewRow, CancelEdit, Cancel)
OnEditEnd(Item, NewRow, CancelEdit)
```

[ghi chú ngoài nguồn] Các đoạn code khác (handler Price chung, StartChoice cho Dismissal, BeforeClose với CloseWithoutChecking, handler FillDocumentCompany...) chỉ có dạng ảnh trong tài liệu nên không chép lại. (StartChoice cho operation Dismissal, handler Price chung và FillDocumentCompany → đã bổ sung (nhánh lesson/16-theory). BeforeClose với CloseWithoutChecking: nhánh chỉ có response handler `BeforeCloseAnswer` và attribute `CloseWithoutChecking` → đã bổ sung phần này (nhánh lesson/16-theory); procedure `BeforeClose` (hỏi user, `Cancel = True`) vẫn chưa có nguồn.) → xem mục Code demo của bài Theory bên dưới.

## Thuộc tính/thiết lập quan trọng trong Designer
- Document: property **Posting**; tab **Posting** (tự động xoá movements).
- Attribute: **Required field** = "Display error".
- Form: **AutoFillCheck** (mặc định bật).
- Input field: **ClearButton**, **SpinButton**, **OpenButton**.
- Form table: **Selection Mode**, **ReadOnly**.
- Dynamic list: **CustomQuery**; choice form không đặt làm default choice form.
- Event Subscription: **Source**, **Event**, **Handler**.
- Common module: flag **Server** (bắt buộc cho handler của event subscription).

## Lỗi thường gặp / lưu ý
- Trong object module, procedure trùng tên event **tự động thành handler** dù tham số sai.
- Rename/xoá procedure handler trong form module → platform không cập nhật liên kết; handler không tồn tại = event xử lý chuẩn. Nên thao tác từ Properties palette.
- FillCheckProcessing/FillCheckProcessingAtServer **không** chạy khi ghi bằng code → dùng `CheckFilling()`.
- Trong BeforeWriteAtServer / OnWriteAtServer: thay đổi qua form attribute **Object** không được ghi → dùng **CurrentObject**.
- Form events không chạy khi ghi bằng code → logic bắt buộc phải đặt trong object module (BeforeWrite...).
- Trong object BeforeWrite, đọc qua reference trả dữ liệu cũ.
- AfterWriteAtServer: sửa CurrentObject vô nghĩa; không có Cancel.
- BeforeClose / OnClose: client, **cấm server call**; OnClose không huỷ được việc đóng.
- Form table OnChange gọi cho mỗi thay đổi trong row — không dùng cho tính toán thông thường.
- OnActivateRow: tránh context server call (gây kích hoạt lại event) → dùng Idle handler.
- BeforeAddRow: không dùng method &AtServer, không đổi attribute gây server call.
- BeforeEditEnd: không gọi khi chuyển cột; kiểm tra CancelEdit trước khi ép user điền.
- Event subscription: platform cho chọn cả common module client-server — developer tự chọn module server phù hợp.

## Điểm cần nhớ
- Object module: handler theo **tên chuẩn**; form module: handler **gán tường minh** qua Properties palette.
- `StandardProcessing = False` để tắt hành vi chuẩn của platform.
- Thứ tự ghi: Form BeforeWrite → FillCheck (form + object) → BeforeWriteAtServer → [transaction] Object BeforeWrite → OnWrite → Posting → OnWriteAtServer → [hết transaction] AfterWriteAtServer → AfterWrite.
- **OnWriteAtServer** là nơi cuối cùng huỷ được việc ghi; ref của object mới lấy qua `CurrentObject.Ref`.
- Logic phải chạy với mọi cách ghi → đặt ở **object module**, không đặt ở form.
- StartChoice + `OpenForm` với Owner = Item → giá trị chọn tự điền vào field.
- ChoiceProcessing cho phép từ chối hoặc thay giá trị user chọn.
- Event subscription: Source/Event/Handler, handler là export procedure trong common module **Server**; chỉ object events; source cụ thể chạy trước source chung, cùng loại thì theo thứ tự trong cây metadata.

## Thẻ gợi ý bài thực hành (Practice 16)

Các thẻ đi theo thứ tự đề trong 16. Practice. Các thẻ 4, 5 và 7 cùng sửa Posting của Sales invoice và Return of goods from customer, nên đọc cả ba trước khi bắt đầu viết.

### Bài tập 1 — Bảng products của document đang chọn trên home page

- **Đề bài (tóm tắt):** Dưới list Purchase invoice và Sales invoice trên home page, thêm bảng read-only hiện các product (không gồm services) của document đang chọn. Chỉ áp dụng cho home page và phải xử lý trường hợp list không có dòng active.
- **Gợi ý 1 — Hướng đi:** Mục "Form table events": event **OnActivateRow** của list chạy mỗi khi dòng hiện tại đổi. Dùng một **dynamic list thứ hai** có custom query lọc theo tham số `&Ref`, rồi đổi tham số đó ngay ở client, không cần server call (theo cảnh báo trong lý thuyết, server call trong OnActivateRow dễ gây kích hoạt lại event).
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Tạo **list form riêng** cho mỗi document (ví dụ `DetailedListForm`) và đặt form này lên home page; list form mặc định giữ nguyên.
  - Form attribute thứ hai kiểu DynamicList, **CustomQuery** trên tabular section `Products` của document, điều kiện `Ref = &Ref`.
  - Field `Ref` của list chính phải hiển thị hoặc bật **Use always** (tip trong đề).
  - Handler `&AtClient` cho event OnActivateRow của table List; method `Parameters.SetParameterValue` của dynamic list.
  - Bảng products: **ReadOnly**, tắt thêm/xoá/kéo dòng.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo list form mới, thêm dynamic list thứ hai cùng query, đặt nó dưới list chính.
  2. Đặt bảng read-only, bật Use always cho `Ref` của list chính.
  3. Viết OnActivateRow: lấy dòng hiện tại; có dòng thì truyền Ref, không có thì truyền giá trị rỗng.
  4. Đặt form mới lên home page thay cho list form cũ.
  ```bsl
  &AtClient
  Procedure ListOnActivateRow(Item)
  	// lấy CurrentData của table List
  	If ___ Then
  		___ // tham số Ref = Ref của dòng hiện tại
  	Else
  		___ // tham số Ref = Undefined -> bảng products rỗng
  	EndIf;
  EndProcedure
  ```
- **Lỗi hay gặp:**
  - Quên trường hợp `CurrentData = Undefined` (DB chưa có document hoặc filter không khớp) dẫn tới lỗi runtime.
  - `Ref` không hiển thị và không bật Use always, nên `CurrentData.Ref` không có giá trị.
  - Sửa list form mặc định làm thay đổi list ở mọi nơi khác trong chương trình.
  - Gọi `&AtServer` trong OnActivateRow gây nhấp nháy hoặc lặp event.
- **Tự kiểm tra:** Trên home page, chuyển giữa các document: bảng dưới đổi theo và chỉ có product. Đặt filter không khớp document nào thì bảng rỗng, không có lỗi. Mở list Sales invoice từ section Sales: list không có bảng phụ.

### Bài tập 2 — Mở item Products khi chọn dòng trong bảng mới

- **Đề bài (tóm tắt):** Double-click hoặc Enter trên dòng của bảng products vừa tạo thì mở item form của Products.
- **Gợi ý 1 — Hướng đi:** Event **Selection** của form table chạy khi user chọn dòng. `ShowValue()` mở form chuẩn của giá trị khi để trống tham số đầu (theo đề).
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Handler `&AtClient` cho event Selection của bảng products, signature `(Item, SelectedRow, Field, StandardProcessing)`; đọc `Items.<Bảng>.CurrentData.Product`.
- **Gợi ý 3 — Khung bài làm:**
  1. Gán handler Selection cho bảng qua Properties palette.
  2. Lấy dòng hiện tại; nếu Product đã điền thì gọi `ShowValue` với tham số đầu để trống.
  ```bsl
  &AtClient
  Procedure ___Selection(Item, SelectedRow, Field, StandardProcessing)
  	// lấy CurrentData, kiểm tra Product đã điền
  	___
  EndProcedure
  ```
- **Lỗi hay gặp:**
  - Viết procedure trong form module nhưng không gán vào event thì không có tác dụng (form handler phải gán tường minh).
  - Không kiểm tra giá trị rỗng trước khi mở form.
- **Tự kiểm tra:** Double-click một dòng thì item form của product đó mở ra; Enter trên dòng cũng mở như vậy.

### Bài tập 3 — Event subscription điền Company mặc định cho mọi document

- **Đề bài (tóm tắt):** Tự động điền Company mặc định vào mọi document có attribute Company, kể cả document tạo sau này, mà developer không phải viết thêm code. Company mặc định chỉ tồn tại khi có **đúng một** company chưa đánh dấu xoá. Function lấy company mặc định đặt trong manager module của Companies, và chỉ điền khi Company còn trống.
- **Gợi ý 1 — Hướng đi:** Mục "Event subscriptions": **Source** = mọi document (type `DocumentObject`), **Event** = `Filling`, handler là export procedure trong common module **Server**. Subscription chạy **sau** handler Filling riêng của document, nên phải kiểm tra trống trước khi điền để tôn trọng thuật toán riêng.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Event Subscription: Source / Event / Handler.
  - Common module (flag Server): procedure Export `(Source, FillingData, FillingText, StandardProcessing)`.
  - Kiểm tra document có attribute Company bằng `Source.Metadata().Attributes.Find(...)`.
  - Manager module của Catalog Companies: function Export trả company mặc định. Query dùng `SELECT FIRST 2` / `TOP 2` + điều kiện không đánh dấu xoá; đếm bằng `Selection.Count()` (đề gọi là Quantity()).
- **Gợi ý 3 — Khung bài làm:**
  1. Viết function trong manager module: query tối đa 2 company hợp lệ; đúng 1 thì trả ref đó, ngược lại trả ref rỗng.
  2. Viết handler trong common module: không có attribute thì Return; đã điền thì bỏ qua; còn lại gọi function.
  3. Tạo Event Subscription trỏ tới handler.
  ```bsl
  Procedure ___Filling(Source, FillingData, FillingText, StandardProcessing) Export
  	// 1) document không có attribute "Company" -> Return
  	___
  	// 2) chỉ điền khi Company còn trống -> gọi function của manager module
  	___
  EndProcedure
  ```
- **Lỗi hay gặp:**
  - Ghi đè Company vô điều kiện. [ghi chú ngoài nguồn] Bản demo của bài Theory (mục "Code demo" bên dưới) gán thẳng và **không** kiểm tra trống, nên làm mất giá trị do Filling riêng của document điền trước. Bài Practice phải kiểm tra.
  - Query chọn tất cả company thay vì 2 bản ghi; hoặc quên điều kiện DeletionMark.
  - Common module không bật flag Server, hoặc procedure không Export.
  - Chọn Source là một vài document cụ thể thay vì `DocumentObject`, nên document mới tạo sau này không được điền.
- **Tự kiểm tra:** Khi có đúng 1 company hợp lệ: tạo mới bất kỳ document có Company thì field được điền sẵn. Thêm company thứ 2 (hoặc đánh dấu xoá company duy nhất) thì field trống. Tạo document "based on" có Company riêng thì giá trị riêng được giữ.

### Bài tập 4 — Posting Sales invoice: phân bổ batch FIFO/LIFO/Manually

- **Đề bài (tóm tắt):** Khi post Sales invoice, đọc constant WriteOffOrder. Với FIFO/LIFO, tính batch trong query theo balance và chia số lượng qua các batch (ví dụ 20 = 5 + 10 + 5). Với Manually, dùng batch user đã chọn. Mọi trường hợp đều kiểm tra tồn theo batch (nếu company bật kiểm soát).
- **Gợi ý 1 — Hướng đi:** Lấy balance theo product + batch từ virtual table **Balance** của GoodsInWarehouses, sắp xếp theo ngày của batch (tăng dần cho FIFO, giảm dần cho LIFO). Duyệt selection và giữ một biến "còn phải xuất"; mỗi batch xuất `Min(còn phải xuất, tồn của batch)` rồi trừ dần. Khi re-post, movements cũ của chính document không được tính vào balance.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Object module, handler `Posting(Cancel, Mode)`.
  - Constant `WriteOffOrder`, enum các cách xuất (FIFO / LIFO / Manually).
  - Query batch: temporary table chứa products của document (gộp theo product), LEFT JOIN `GoodsInWarehouses.Balance(&PointInTime, ...)`, ORDER BY product rồi ngày của batch.
  - Hàm `Min()`; `RegisterRecords.GoodsInWarehouses.Add()`, RecordType Expense.
  - Loại movements cũ: tab Posting của document đặt **Register records deletion = AutoDelete**, hoặc ghi một record set rỗng trước query (tip trong đề).
  - Kiểm tra tồn: procedure chung từ bài 15 (truyền Company).
- **Gợi ý 3 — Khung bài làm:**
  1. Đọc WriteOffOrder. Nếu khác Manually thì chọn chiều sắp xếp và chạy query balance theo batch.
  2. Duyệt selection: gặp product mới thì nạp lại biến "còn phải xuất"; đã đủ thì bỏ qua các batch còn lại.
  3. Mỗi batch: tính số xuất, thêm một record Expense có Batch, trừ biến.
  4. Còn thiếu hàng (khi chuyển product và sau vòng lặp) thì Cancel kèm thông báo.
  5. Manually: ghi theo Batch của từng dòng document.
  6. Ghi movements rồi gọi kiểm tra tồn theo batch.
  ```bsl
  While Selection.Next() Do
  	If ___ Then        // sang product mới
  		___            // báo thiếu của product trước (nếu còn), nạp lại "còn phải xuất"
  	ElsIf ___ Then     // đã xuất đủ cho product này
  		Continue;
  	EndIf;
  	___                // số xuất = min(...), thêm record Expense có Batch, trừ "còn phải xuất"
  EndDo;
  ```
- **Lỗi hay gặp:**
  - Re-post làm balance tính trùng với movements cũ của chính document. Đặt AutoDelete hoặc ghi set rỗng **trước** query.
  - Chỉ kiểm tra thiếu hàng sau vòng lặp, nên bỏ sót product ở giữa danh sách. Phải kiểm tra cả khi chuyển product.
  - Nối chiều sắp xếp vào query text nhưng quên khoảng trắng.
  - Quên ISNULL cho product không có balance, dẫn tới NULL trong phép tính.
- **Tự kiểm tra:** Dựng đúng ví dụ trong đề (Batch 1/2/3 = 5/10/15, bán 20). Post với FIFO, xem Register records: 5 + 10 + 5. Đổi sang LIFO, re-post: 15 + 5. Bán 40 thì bị chặn. Re-post nhiều lần, kết quả không đổi.

### Bài tập 5 — Return of goods from customer: dòng chỉ theo Sales document, trả batch theo thứ tự ngược

- **Đề bài (tóm tắt):** Tabular section chỉ được điền từ Sales document. User chỉ được xoá dòng hoặc giảm quantity, không thêm dòng; cột Batch chỉ hiện khi Manually. Movements: Manually thì ghi theo batch của dòng; FIFO/LIFO thì trả batch **muộn trước** (FIFO) hoặc **sớm trước** (LIFO), dựa trên records của sales document.
- **Gợi ý 1 — Hướng đi:**
  - Chặn thêm dòng bằng event **BeforeAddRow** của form table (mục "Form table events").
  - Ẩn cột Batch trong form event server, giống Sales invoice.
  - Batch để trả lấy từ records mà **chính Sales document** đã ghi: virtual table **Turnovers** với periodicity Recorder, lọc theo `Recorder = &SalesInvoice`, sắp xếp ngược với lúc bán. Thuật toán chia số lượng giống thẻ 4.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Form module: `ProductsBeforeAddRow(Item, Cancel, Clone, Parent, Folder, Parameter)` (`&AtClient`), `OnCreateAtServer`; các column không cho sửa (Product, Batch, Price, Amount) đặt ReadOnly.
  - Object module: event `Filling` điền từ `DocumentRef.SalesInvoice` (gộp dòng như Sales document, kèm Batch).
  - `Posting`: với FIFO/LIFO dùng `GoodsInWarehouses.Turnovers(..., Recorder, ...)` lấy QuantityExpense/AmountExpense theo batch; Manually dùng batch của dòng.
  - Cách ghi movement trả hàng: Receipt, hoặc Expense với số **âm** (storno). Chọn một cách và dùng thống nhất.
- **Gợi ý 3 — Khung bài làm:**
  1. Form: chặn thêm dòng, ẩn Batch khi không Manually, khoá các cột không được sửa.
  2. Filling: điền header và dòng từ Sales invoice.
  3. Posting FIFO/LIFO: query turnovers của sales document theo batch, sắp xếp ngược; duyệt và chia như thẻ 4, mỗi batch tối đa bằng số đã xuất.
  4. Posting Manually: mỗi dòng một record theo batch của dòng.
  ```bsl
  &AtClient
  Procedure ProductsBeforeAddRow(Item, Cancel, Clone, Parent, Folder, Parameter)
  	___ // từ chối thêm dòng (kể cả copy)
  EndProcedure
  ```
- **Lỗi hay gặp:**
  - Sắp xếp batch cùng chiều với lúc bán. Khi trả hàng phải **ngược lại**: FIFO trả batch muộn trước.
  - Lấy batch từ balance hiện tại thay vì records của sales document.
  - [ghi chú ngoài nguồn] Lời giải tham khảo của khóa không báo lỗi khi số trả **vượt** số đã bán. Nên tự thêm kiểm tra "còn dư sau vòng lặp".
  - Dùng event OnChange của table để chặn thêm dòng là quá muộn; phải dùng BeforeAddRow.
- **Tự kiểm tra:** Tạo Return "based on" Sales invoice ở ví dụ 20 hammers (FIFO 5/10/5), giảm quantity xuống 10 rồi post. Register records phải là 5 của Batch 3 và 5 của Batch 2. Thử thêm dòng: không được. Đổi sang Manually: cột Batch hiện ra.

### Bài tập 6 — Nút "Fill by sales document" gọi event Filling chuẩn

- **Đề bài (tóm tắt):** Thêm nút trên header của Return of goods from customer để điền lại document đúng như khi tạo "based on" Sales invoice.
- **Gợi ý 1 — Hướng đi:** Không viết lại thuật toán điền. Gọi method `Fill()` của **document object**: platform chạy event `Filling` của object module, giống khi tạo "based on". Trên form phải chuyển form data sang object rồi đưa kết quả về form.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Form command + handler `&AtClient`; kiểm tra `Object.SalesDocument` đã điền.
  - Hỏi xác nhận non-modal: `ShowQueryBox` + `CallbackDescription`; callback Export kiểm tra `DialogReturnCode.Yes`.
  - Procedure `&AtServer`: `FormAttributeToValue("Object")` → `Fill(...)` → `ValueToFormAttribute(...)`.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo command, đặt nút vào header.
  2. Handler client: Sales document trống thì báo; có thì hỏi xác nhận.
  3. Callback: Yes thì gọi procedure server.
  4. Procedure server: chuyển sang object, gọi Fill với Sales document, đưa về form.
  ```bsl
  &AtServer
  Procedure ___AtServer()
  	___ // form data -> document object
  	___ // gọi Fill(...) với Sales document -> chạy event Filling
  	___ // document object -> form data
  EndProcedure
  ```
- **Lỗi hay gặp:**
  - Dùng câu hỏi modal (`DoQueryBox`) thay vì `ShowQueryBox` có callback.
  - Copy lại code điền vào form thay vì gọi `Fill()`, khi đó hai nơi lệch nhau.
  - Callback quên Export.
- **Tự kiểm tra:** Sửa vài dòng rồi bấm nút, trả lời Yes: document trở lại như mới tạo "based on". Trả lời No thì không có gì thay đổi.

### Bài tập 7 — Amount trong GoodsInWarehouses theo giá vốn

- **Đề bài (tóm tắt):** Sales invoice: Amount xuất kho = giá vốn theo balance của batch (ví dụ 1500/15 × 5 = 500). Return of goods: Amount = giá vốn tính từ records của sales document (Turnovers). Phải tránh chia cho 0.
- **Gợi ý 1 — Hướng đi:** Trong cùng query lấy batch ở thẻ 4 và 5, tính thêm "giá đơn vị" = AmountBalance / QuantityBalance (Sales invoice) hoặc AmountExpense / QuantityExpense của sales document (Return). Record ghi `Amount = số lượng × giá đơn vị`.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Field tính trong query, dùng `CASE WHEN <mẫu số> = 0 THEN 0 ELSE ... END` (bọc ISNULL khi có LEFT JOIN). Với Manually: query balance (hoặc turnovers) theo product + batch, rồi tìm dòng tương ứng cho mỗi dòng document (ví dụ `FindNext` với Structure filter, hoặc JOIN trong query).
- **Gợi ý 3 — Khung bài làm:**
  1. Thêm field giá đơn vị có CASE chống chia 0 vào query FIFO/LIFO.
  2. Trong vòng lặp, Amount = số xuất × giá đơn vị.
  3. Nhánh Manually: lấy thêm giá đơn vị theo product + batch.
  4. Return: dùng giá từ turnovers của sales document.
- **Lỗi hay gặp:**
  - Chia cho 0 khi batch hết tồn hoặc không có record dẫn tới exception. Luôn dùng CASE.
  - Vẫn ghi Amount theo giá bán của document, khiến balance amount âm dần (ví dụ pencil 50/70 trong đề).
  - Return dùng giá vốn hiện tại thay vì giá trong records của sales document.
- **Tự kiểm tra:** Theo ví dụ trong đề, xem Register records của Sales invoice: Amount của từng batch bằng số lượng × (amount tồn / quantity tồn). Sau khi bán hết một product, balance amount phải bằng 0, không âm. Return 7 pencils (5 Batch1 + 2 Batch2) thì Amount là 250 và 104.

## Code demo của bài Theory (repo 1CJDCourse, nhánh lesson/16-theory)

### StartChoice cho operation Dismissal: chỉ chọn nhân viên đang làm việc

Nguồn: nhánh lesson/16-theory — cf/Documents/PersonnelChange/Forms/DocumentForm/Ext/Form/Module.bsl; cf/Catalogs/Employees/Forms/WorkingEmployees/Ext/Form/Module.bsl; cf/Catalogs/Employees/Forms/WorkingEmployees/Ext/Form.xml (query của dynamic list)

Form module của document PersonnelChange (handler gán cho field `ChangesEmployee`):

```bsl
&AtClient
Procedure ChangesEmployeeStartChoice(Item, ChoiceData, StandardProcessing)
	
	If Object.OperationKind = PredefinedValue("Enum.OperationKindsPersonnelChange.Dismissal") Then
		StandardProcessing = False;
		
		OpenParameters = New Structure("Filter", New Structure("Date, Company", Object.Date, Object.Company));
		
		OpenForm("Catalog.Employees.Form.WorkingEmployees", OpenParameters, Item);
	EndIf;

	//FillChoiceData(ChoiceData);

EndProcedure
```

Choice form `WorkingEmployees` của catalog Employees:

```bsl
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)

	If Not Parameters.Property("Filter") Then
		Raise "Parameters should contain Filter property";
	EndIf;
	
	List.Parameters.SetParameterValue("Date", 		Parameters.Filter.Date);
	List.Parameters.SetParameterValue("Company", 	Parameters.Filter.Company);
		
EndProcedure
```

Query của dynamic list `List` (ManualQuery = true):

```bsl
SELECT
	Employees.Ref AS Employee,
	EmployeesSliceLast.Position AS Position,
	EmployeesSliceLast.Department AS Department,
	EmployeesSliceLast.Employee.DateOfBirth AS DateOfBirth
FROM
	InformationRegister.Employees.SliceLast(&Date, Company = &Company) AS EmployeesSliceLast
		INNER JOIN Catalog.Employees AS Employees
		ON EmployeesSliceLast.Employee = Employees.Ref
WHERE
	EmployeesSliceLast.Works
```

- Đúng ví dụ trong bài: operation kind = Dismissal → `StandardProcessing = False`, mở form `WorkingEmployees` với `Filter` (Date, Company) và truyền `Item` làm **Owner** → giá trị chọn tự điền vào ô, không cần ChoiceProcessing.
- Operation khác Dismissal → không đụng tới StandardProcessing, platform mở choice form mặc định.
- `OnCreateAtServer` của choice form `Raise` nếu thiếu property `Filter`, rồi đặt parameters `Date`/`Company` cho dynamic list; form này **không** đặt làm default choice form.
- Query: catalog Employees làm main table (INNER JOIN với `SliceLast` của information register Employees, điều kiện `Works`) để dynamic list trả về ref nhân viên. Procedure `FillChoiceData` (gán `ChoiceData` là ValueList) cũng có trong module nhưng lời gọi đang bị comment.

### Phần response handler của BeforeClose: attribute CloseWithoutChecking

Nguồn: nhánh lesson/16-theory — cf/Documents/SalesInvoice/Forms/DocumentForm/Ext/Form/Module.bsl; cf/Documents/SalesInvoice/Forms/DocumentForm/Ext/Form.xml

```bsl
&AtClient
Procedure BeforeCloseAnswer(Result, AdditionalParameters) Export

	If Result = DialogReturnCode.Yes Then
		CloseWithoutChecking = True;
		Close();
	EndIf;

EndProcedure
```

```xml
		<Attribute name="CloseWithoutChecking" id="8">
			<Title>
				<v8:item>
					<v8:lang>en</v8:lang>
					<v8:content>Close without checking</v8:content>
				</v8:item>
			</Title>
			<Type>
				<v8:Type>xs:boolean</v8:Type>
			</Type>
		</Attribute>
```

- Đây là phần (2) của hội thoại non-modal trong bài: user trả lời Yes → đặt `CloseWithoutChecking = True` rồi gọi `Close()` lần nữa.
- Form attribute `CloseWithoutChecking` kiểu Boolean (mặc định False) đúng như mô tả lý thuyết.
- Nhánh **chưa có** procedure `BeforeClose` (phần (1): hỏi user, `Cancel = True`, kiểm tra `CloseWithoutChecking`) — form cũng chưa gán event BeforeClose, nên phần này vẫn chỉ có trong ảnh của tài liệu.

### Một handler Price dùng chung cho Products và Services (Item.Parent)

Nguồn: nhánh lesson/16-theory — cf/Documents/SalesInvoice/Forms/DocumentForm/Ext/Form/Module.bsl; cf/Documents/SalesInvoice/Forms/DocumentForm/Ext/Form.xml

```bsl
&AtClient
Procedure FillAmountInCurrentData(CurrentData)
	
	CurrentData.Amount = CurrentData.Price * CurrentData.Quantity;
	
EndProcedure
// ...
&AtClient
Procedure ProductsServicesPriceOnChange(Item)
	
	CurrentData = Item.Parent.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;
	
	FillAmountInCurrentData(CurrentData);
	
EndProcedure
```

```xml
									<Events>
										<Event name="OnChange">ProductsServicesPriceOnChange</Event>
									</Events>
```

- Ví dụ "một handler cho nhiều field" của bài: field Price của cả Products và Services cùng gán `ProductsServicesPriceOnChange` (tên không gắn với một element cụ thể).
- `Item.Parent.CurrentData` lấy dòng hiện tại của chính form table chứa field vừa đổi → một procedure phục vụ cả hai tabular section.
- Đây là phiên bản demo trong form module: procedure client `FillAmountInCurrentData` không có discount.

### BeforeWriteAtServer: Object và CurrentObject, ghép DeliveryAddress

Nguồn: nhánh lesson/16-theory — cf/Documents/SalesInvoice/Forms/DocumentForm/Ext/Form/Module.bsl

```bsl
&AtClient
Procedure BeforeWrite(Cancel, WriteParameters)
	
	//CurrentWorkplace = CommonClient.CurrentWorkplace();
	//WriteParameters.Insert("Workplace", CurrentWorkplace);
	WriteParameters.Insert("NewObject", Object.Ref.IsEmpty());
	
EndProcedure

&AtServer
Procedure BeforeWriteAtServer(Cancel, CurrentObject, WriteParameters)
	
	// This code doesn't change the object of document,
	// because the object is already placed in the CurrentObject parameter
	Object.Date = EndOfDay(Object.Date);
	
	// That's why we should work with CurrentObject to change the object
	CurrentObject.Date = EndOfDay(CurrentObject.Date);
	
// ...
	FillDeliveryAddress();
	
EndProcedure
// ...
&AtServer
Procedure FillDeliveryAddress()
	
	AddressParts = New Array;
	AddressParts.Add(City);
	AddressParts.Add(District);
	AddressParts.Add(Street);
	AddressParts.Add(Building);
	AddressParts.Add(Apartment);

	// StrConcat function merges an array of strings passed (the first parameter) 
	// into a single string with the specified separator (the second parameter) 
	Object.DeliveryAddress = StrConcat(AddressParts, ", ");
	
EndProcedure
```

- Form `BeforeWrite` (client) thêm property `NewObject` vào `WriteParameters` để dùng ở các bước sau (AfterWrite).
- `BeforeWriteAtServer` minh hoạ trực tiếp quy tắc: gán `Object.Date` **không** có tác dụng, phải sửa qua `CurrentObject.Date`.
- Form còn có `FillCheckProcessingAtServer` xoá City/District/Street/Building/Apartment khỏi `CheckedAttributes` khi không bật `DeliveryIsRequired`, và `AfterWriteAtServer` → `FillInSoldThisMonth()` điền cột SoldThisMonth bằng query turnovers — đúng hai ví dụ của sơ đồ events (cùng file).
- [ghi chú ngoài nguồn] `FillDeliveryAddress()` vẫn gán vào `Object.DeliveryAddress` dù được gọi từ BeforeWriteAtServer — theo chính quy tắc trên, giá trị này sẽ không được ghi; nên gán `CurrentObject.DeliveryAddress`.

### Event subscription FillDocumentCompany (phiên bản demo của bài)

Nguồn: nhánh lesson/16-theory — cf/EventSubscriptions/FillDocumentCompany.xml; cf/CommonModules/DocumentsCommonFilling/Ext/Module.bsl

```xml
			<Source>
				<v8:TypeSet>cfg:DocumentObject</v8:TypeSet>
			</Source>
			<Event>Filling</Event>
			<Handler>CommonModule.DocumentsCommonFilling.FillDocumentCompanyFilling</Handler>
```

```bsl
Procedure FillDocumentCompanyFilling(Source, FillingData, FillingText, StandardProcessing) Export
	
	MetadataObject = Source.Metadata();
	If MetadataObject.Attributes.Find("Company") = Undefined Then
		Return;
	EndIf;
	
	Source.Company = Constants.DefaultCompany.Get();
	
EndProcedure
```

- Đúng tên subscription trong ảnh của bài: Source = `DocumentObject`, Event = `Filling`, Handler trỏ tới export procedure trong common module.
- Lưu ý: bản demo gán thẳng `Constants.DefaultCompany.Get()` và **không** kiểm tra `ValueIsFilled(Source.Company)`, nên ghi đè cả giá trị do Filling riêng của document điền trước đó (subscription chạy sau handler của object). Bài Practice 16 yêu cầu chỉ điền khi Company còn trống → xem Thẻ gợi ý bài tập 3.

## Video tham khảo

Video bài giảng trên YouTube có phạm vi trùng với bài này. Khi dẫn cho người học, nói "Bạn có thể tham khảo thêm về <chủ đề> của khóa tại đây: [<tên video>](link)" — không nói "khóa cũ/Junior", không dùng mã JC (mã JC trong danh sách chỉ để tra nội bộ). Quy ước đầy đủ: `references/video.md#video-junior-course`.

- [Sự kiện và trình xử lý sự kiện](https://www.youtube.com/watch?v=FAkymD2Zqks&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=10) (9:29) — Bài 9 — form events; Bài 16 — form & form element events, thứ tự events _(mã nội bộ JC-11)_

<!-- video-qa-thuchanh:start -->

Video giải đáp tình huống thực chiến và video thực hành từng bước liên quan tới bài này (thẻ chi tiết, triệu chứng, lưu ý khi giới thiệu: `references/video.md#video-qa-thuc-chien`, `references/video.md#video-thuc-hanh`; cùng mẫu câu dẫn ở trên):

- [Fix lỗi không tính toán Thành tiền khi thay đổi Số lượng](https://www.youtube.com/watch?v=LRRNf8MxoQw&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=1) (4:24) — cách tìm lỗi sự kiện OnChange không chạy (giải đáp tình huống; Bài 16 chính) _(mã nội bộ QA-1)_
- [Kiểm tra dữ liệu trùng lặp](https://www.youtube.com/watch?v=603j21ItABk&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=11) (8:55) — cảnh báo dữ liệu trùng (giải đáp tình huống; Bài 16 chính) _(mã nội bộ QA-11)_
- [Hủy sự kiện đang thực thi](https://www.youtube.com/watch?v=rW40s85Gtc4&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=16) (3:18) — chặn ghi bằng Cancel = True (giải đáp tình huống; Bài 16 chính) _(mã nội bộ QA-16)_
- [Lấy giá tự động](https://www.youtube.com/watch?v=oMowT1e019k&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=5) (8:32) — tự điền giá theo bảng giá (giải đáp tình huống; Bài 16 liên quan) _(mã nội bộ QA-5)_
- [Thêm ảnh cho các đối tượng](https://www.youtube.com/watch?v=TQNa4cveOdc&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=6) (10:04) — lưu và hiển thị ảnh cho sản phẩm (giải đáp tình huống; Bài 16 liên quan) _(mã nội bộ QA-6)_
- [Xây dựng các trường tự động điền](https://www.youtube.com/watch?v=8klMmoJXBCk&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=10) (2:02) — giá trị mặc định khi tạo chứng từ (giải đáp tình huống; Bài 16 liên quan) _(mã nội bộ QA-10)_
- [Tự động lấy đơn vị tính của sản phẩm](https://www.youtube.com/watch?v=RKAGi62Vy5E&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=12) (8:16) — điền thuộc tính sản phẩm vào dòng chứng từ (giải đáp tình huống; Bài 16 liên quan) _(mã nội bộ QA-12)_
- [Lưu trữ thông tin các chuyến du lịch](https://www.youtube.com/watch?v=PwqP4GODNrY&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=6) (13:15) — tạo chứng từ trên cơ sở chứng từ khác (Input on basis) (thực hành case study; Bài 16 liên quan) _(mã nội bộ P1-5)_
- [Hệ thống thông tin cửa hàng nhỏ](https://www.youtube.com/watch?v=zXa4pQv0LHE&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=6) (12:28) — xử lý nhiều đơn hàng bằng một lệnh (thực hành case study; Bài 16 liên quan) _(mã nội bộ P2-6)_

<!-- video-qa-thuchanh:end -->


---

# § bai-17

# Bài 17 — Print forms, làm việc với hình ảnh, Reports với programmatic template filling

## Khái niệm chính

### Print forms — tổng quan
- Print form: công cụ hiển thị thông tin về một/nhiều object hoặc thông tin tổng hợp từ DB theo một mẫu đặc biệt. Vẫn cần trong thời đại electronic document management (phải tạo tài liệu điện tử theo format trước khi ký điện tử). Có form theo format bắt buộc (báo cáo cho cơ quan nhà nước), form tự do (nội bộ, ví dụ phiếu kiểm kê kho). Còn dùng để in phong bì, price tags, labels...
- Ngoài in ra máy in, print form có thể lưu ra file ở nhiều format.

### Spreadsheet document & Template
- Print form được xuất ra **spreadsheet document** — internal object của 1C platform, giống Excel/Google Sheet.
- Cấu trúc được định nghĩa bởi configuration object **Template**. Template thêm được vào gần như mọi configuration object: catalogs, documents, enumerations, mọi loại registers, mọi loại plans, reports, data processors, tasks, business processes.
- Loại template dùng cho print forms: **spreadsheet document** và **text document**. "Text document" ít dùng hơn — cho phiếu in trên cash register tape và form không cần cấu trúc phức tạp (bảng, ảnh, độ rộng cột, wrap text...).
- Template "spreadsheet document" chứa "khuôn" dữ liệu; một template có thể dùng cho nhiều biến thể in (có/không discount, có/không tax, có/không con dấu chữ ký...). Có **named areas** lấy được từ code.
- Quy trình điền spreadsheet document từ template:
  1. Lấy template vào biến.
  2. Lấy template area vào biến.
  3. (Nếu cần) điền dữ liệu vào area.
  4. Xuất area ra spreadsheet document.

### Print form wizard
- Nằm trong submenu **"Wizards"** của context menu object (hoặc submenu **"Actions"** trong object editor).
- Bước 1: tạo mới hoặc sửa print command. Đặt tên rõ ràng; dialog **không kiểm tra** space/ký tự cấm, nhưng yêu cầu giống tên metadata object (vì sẽ tạo command và template mới).
- Các bước: chọn field cho header → mỗi tabular section một bước (ví dụ Products, Services) → field cho footer → chọn panel hiển thị command (mặc định **Form command bar** kiểu **"Important"**) và thiết lập spreadsheet document: print without preview, **view-only table** (cấm sửa tay), **table protection** (ngoài cấm sửa còn tắt context menu và cấm copy dữ liệu).
- Wizard tạo các area: Caption, Header, ProductsHeader, Products, ServicesHeader, Services, Footer.
- Loại area: **row areas** (tên hiện bên trái số dòng, viền đỏ trên-dưới), ngoài ra có **column areas** và **cell areas**.

### FillType của cell
- **"Text"** — xuất nguyên văn.
- **"Parameter"** — text trong ngoặc nhọn (ví dụ `<Number>`, `<Responsible>`), toàn bộ ô được điền bằng code.
- **"Template"** — kết hợp: các chuỗi trong ngoặc vuông (`[DocumentNumber]`, `[DocumentDate]`) là parameter của area, phần text còn lại giữ nguyên. Ví dụ điền 12 và 15.08.2024 → "Sales invoice 12 from 15.08.2024" (format ngày phụ thuộc regional settings của infobase).

### Code do wizard sinh ra
- **Command module**: client procedure (command handler) tạo object `SpreadsheetDocument` mới → truyền vào server procedure → gọi procedure điền trong **document manager module** → về client set **ShowGrid**, **Protection**, **ReadOnly**, **ShowHeaders** (Protection và ReadOnly theo flag ở bước cuối wizard) → `SpreadsheetDocument.Show()` mở form chứa spreadsheet document (user sửa, in, preview, lưu file).
- **Manager module**: export procedure `SalesInvoice` với tham số `SpreadsheetDocument` và `Ref`.
  - `GetTemplate()` của document manager lấy template theo tên.
  - Query chỉ chọn các field đã chọn trong wizard; kết quả vào `Selection`.
  - **`GetArea()`**: theo tên, hoặc theo địa chỉ `"RmCn:RxCy"` (m/n = row/column ô đầu, x/y = row/column ô cuối). Ví dụ `GetArea("R2C2:R4C3")` → cột 2–3, dòng 2–4, tổng 6 ô. Cú pháp khác: truyền số — `GetArea(2, 2, 4, 3)`.
  - `SpreadsheetDocument.Clear()` — xoá nội dung phòng khi spreadsheet document truyền vào đã có dữ liệu.
  - Biến `InsertPageBreak` = False ban đầu để không chèn page break ở vòng lặp đầu; sau mỗi vòng = True → mỗi document bắt đầu trang mới, hỗ trợ in nhiều document (điều kiện `SalesInvoice.Ref In (&Ref)`, tham số Ref là array references user chọn).
  - **Page break**: điểm kết thúc trang này / bắt đầu trang sau ở mọi chế độ. Horizontal page break xuất bằng **`PutHorizontalPageBreak()`**; vertical page break hiếm dùng.
  - Khổ giấy đổi được từ code qua property **PageSize** (kiểu String) của spreadsheet document.
  - **`Put()`** — xuất area, luôn từ dòng mới. **`Join()`** — nối area vào dòng cuối sau cột cuối; hữu ích khi tập cột phụ thuộc điều kiện (ví dụ "Sales with discounts" vs "Sales", hoặc functional option "use discounts").
  - **`Parameters.Fill(...)`** — điền parameter của area theo các property trùng tên có trong source (selection, collection, object truy cập property qua dấu chấm). Tên không khớp (ví dụ parameter "Product" mà source chỉ có "Item") → **không được điền**.
  - Điền bằng gán trực tiếp khi cần chuẩn bị dữ liệu (presentation phức tạp của organization, số tiền bằng chữ — có method riêng trong common module).
  - Tham số thứ hai của `Put()` là **selection level** (method `Level()` của selection) làm level grouping dòng; chỉ có nghĩa khi dùng **`StartRowAutoGrouping()`** và **`EndRowAutoGroup()`**. Row autogrouping cho phép thu gọn/mở rộng nhóm dòng bằng "+"/"-".
  - Tabular sections được chọn trong query như **nested parts** → khi đọc kết quả, chúng là query result riêng → lấy bằng `Select()` hoặc `Unload()`. `Level()` của selection mới trả 0; khác 0 khi query có totals (**TOTALS BY**).
- Chọn nhiều document trong list form: Ctrl+click, Shift (từ–đến), Ctrl+A.
- Nhược điểm print form từ wizard: form mở bằng method của spreadsheet document có tiêu đề "Table"; attribute xếp dọc lãng phí chỗ; header bảng Services vẫn in khi không có dòng nào.

### Tạo print form từ đầu (không dùng wizard)
- Xoá template, command và procedure cũ; tạo export function **`PrintFormSalesInvoice`** trong manager module, tham số `PrintingObjects`, trả về spreadsheet document đã điền.
- Command **SalesInvoice**: group **"Form command bar.Important"**, command parameter type = reference tới chính document, **parameter usage mode = Multiple** (in nhiều document từ list).
- Gọi method của manager module chỉ được trên **server** (client context không biết Catalogs, Documents...) → tạo server function trong command module (một dòng return), client nhận spreadsheet document và gọi `Show()` — tham số đầu có thể là **tiêu đề cửa sổ**.
- Template **PF_SalesInvoice** kiểu "Spreadsheet document" — prefix **"PF_"** báo hiệu template dùng cho print form.
- Khuyến nghị: đặt độ rộng các cột bằng nhau, chuẩn A4 = **40 cột**; chọn cột 1–40 → "Column Width..." = **2.75**. Cột 1 và 40 thu hẹp (**0.9**) làm lề, không điền dữ liệu.
- Column width có bước tối thiểu **~0.125**; giá trị không chia hết bị làm tròn xuống (rồi làm tròn 2 chữ số thập phân). Ví dụ 0.9 → 0.88 (7×0.125 = 0.875); nhập 0.87 → 0.75.
- Sắp xếp areas theo thứ tự xuất ra print form để dễ đọc.
- **Title**: để dòng 1 trống; merge cells dòng 2 cột 2–39 (nút **"Merge cells"** trên toolbar **"Spreadsheet Document"**; mọi lệnh có trong menu **Table**); font Arial 12 bold, FillType "Template", căn giữa, text `Sales invoice No.[DocumentNumber] from [DocumentDate]`. Nếu sau khi thoát ô không thấy ngoặc nhọn → kiểm tra lại FillType.
- Đặt tên area: click số dòng → **Table - Names - Set name...**; xoá: **"Remove name"**; xem tất cả: **Table - Names - Names…**. Đổi tên: Table - Names hoặc double-click header area.
- Muốn có dòng trống giữa các area → để dòng trống trong area.
- Đổi số dòng của area bằng insert/delete rows, **trừ area 1 dòng**: dùng "split cell" (vertical) hoặc xoá area rồi tạo lại.
- **Header**: nhãn ("Company:", "Customer:") và parameter đặt ở **ô riêng**, vì font/màu áp dụng cho toàn ô → không dùng "Template" nếu muốn nhãn bold mà giá trị không bold. Parameter `<Contract>` đặt bên phải dòng customer.
- **HeaderProducts**: text tĩnh, bold, borders; thêm dòng trống trước bảng để có khoảng cách (bảng Products/Services chỉ in khi tabular section có dòng).
- **ProductsTableRow**: toàn parameters. Dùng `Fill()` → tên parameter phải trùng tên property; nên đặt trùng tên attribute của object.
- Copy area: chọn **cả dòng** (click số dòng, không phải range ô) rồi đổi tên/text.
- **Totals**: "Total:" + parameter **TotalAmount** (document đã có attribute lưu tổng → chỉ cần chọn trong query).
- **Footer**: người phụ trách, warehouse. Tránh gõ sai tên parameter: copy tên attribute từ metadata tree, hoặc kéo-thả attribute vào template (kéo-thả sẽ **phá merge** ô).
- Query đổi tên Date, Number thành **DocumentDate**, **DocumentNumber** để trùng parameter.
- Format ngày không có giờ: (1) global method **`Format()`**; (2) property **Format** của ô template. Format của ô không có tác dụng cho ô FillType "Template" (giá trị hỗn hợp).
- Format từ code **ưu tiên hơn** format của ô.
- **HorizontalAlign = "Auto"**: số căn phải, chuỗi căn trái. `Format()` trả về **String** → giá trị luôn là chuỗi → nếu căn lề quan trọng, tự đặt alignment.
- Vừa trang: margin, paper size, orientation, scale (page setup từ preview). Dùng property **FitToPage** = True của SpreadsheetDocument; form càng vượt trang thì scale càng giảm → không hợp cho form rất rộng (cân nhắc landscape).
- **PrintParametersKey** (string) lưu page parameters theo từng print form, riêng cho từng user; thường là `<tên object>_<tên print form>`. Đổi key → platform đọc thiết lập theo key mới, chưa có thì reset về mặc định.

### Working with images
- Spreadsheet document có drawings: shapes, drawing để điền text, drawing để thay ảnh, fixed picture, diagrams...
- Drawing để thay ảnh dùng cho logo, con dấu, chữ ký (phụ thuộc company, người phụ trách).
- Catalog Companies: attribute **LogoPicture** kiểu **ValueStorage**.
  - ValueStorage: lưu dữ liệu nhiều kiểu kể cả phức tạp (ảnh/binary data); không sửa trực tiếp được, chỉ ghi đè bằng value storage mới.
- Hiển thị ảnh trên form: **image field** liên kết form attribute kiểu **String** chứa địa chỉ binary data trong **temporary storage**.
  - Temporary storage: lưu bất kỳ giá trị serializable nào trong một session (ví dụ trả value table về client qua địa chỉ).
- Form attribute **LogoPictureAddress**, field type **"Image field"**, bật **"Hyperlink"**, **NonselectedPictureText** = "Add logo" (màu Light Gray), đặt trong group tiêu đề "Logo", **"TitlePosition"** tắt tiêu đề.
- **Important**: **PictureSize** = **"Proportional"** để ảnh co theo kích thước field.
- Handler event **Click** của field: tắt standard processing (nếu không sẽ mở cửa sổ hiện string của attribute), gọi **`LockFormDataForEdit()`** để khoá object company.
- **File dialog**: property **Filter** giới hạn loại file; tắt multiple selection; đặt title; mở bằng **`Show()`** với callback description. Đặt trong procedure riêng để sau chuyển sang common module được.
- Notification handler phải **Export**; tham số (xem Syntax Assistant cho `Show()` của FileDialog): **SelectedFiles** — array path nếu chọn ít nhất 1 file, **Undefined** nếu huỷ (Esc, Cancel, đóng cửa sổ); **AdditionalParameters** (Undefined nếu không truyền).
- Kiểm tra file tồn tại (file có thể bị move/rename/delete, hoặc user gõ tên): `New File(FileName)` rồi **`BeginCheckingExistence`** với callback; tham số đầu **Exist** (Boolean). FileName truyền qua AdditionalParameters của callback description.
- File tồn tại → `New BinaryData(FullFileName)` → **`PutToTemporaryStorage`** kèm **unique identifier của form** (để địa chỉ không bị xoá ở server call tiếp theo) → ghi địa chỉ vào LogoPictureAddress.
- Form attribute **LogoChanged** (Boolean) đánh dấu logo đã đổi; `Modified = True` để platform hỏi lưu khi đóng.
- Platform giới hạn truy cập attribute ValueStorage qua form data → làm việc với object thật trong form event handlers:
  - Đọc: **OnReadAtServer** — value storage chỉ có method **`Get()`**; nếu không có giá trị → Undefined; kiểm tra kiểu là **BinaryData** → đặt vào temporary storage, ghi địa chỉ.
  - Ghi: **BeforeWriteAtServer** — nếu LogoChanged → lấy binary data từ temporary storage → gán **new ValueStorage**. Tham số thứ hai của constructor là compression (compression level: **-1** mặc định, **0** không nén, **9** nén tối đa). Dữ liệu lớn nên nén tối đa để DB không phình.
- **Ảnh trong template**: tăng Title lên 4 dòng; chọn ô → **"Picture"** trên toolbar hoặc **Table - Pictures - Picture…**; không chọn ảnh, bấm OK → shape kích thước tối thiểu, kéo giãn/di chuyển. Đó là **spreadsheet document drawing**. SpreadsheetDocument có property **Drawings** (collection), dùng được cho template và cả template areas (mỗi area cũng là spreadsheet document). Đặt tên drawing **"Logo"**, "picture size" = **"Proportional"**.
- Function export trong **catalog manager module** trả binary data của logo; khi điền: kiểm tra kiểu BinaryData → `New Picture(BinaryData)` → gán vào property **Picture** của drawing.
- Bỏ khung quanh logo: property **"Line"** = "None" trong template, hoặc bằng code (xem bên dưới). Không có line thì drawing không thấy trong template tới khi chọn → đặt property **Pattern** = **"Solid"** (có thể đã active nhưng không hoạt động đúng, chọn lại) để drawing có nền trắng.

### Reports với programmatic template filling
- Nguyên tắc giống print form (spreadsheet document + template). Khác: report thường có **period** và **parameters/filters**.
  - **Parameters**: thường bắt buộc, có thể phức tạp hơn (ví dụ "show balances: only non-negative / only negative / all", "Product type: all / goods / services").
  - **Filters**: gắn trực tiếp với dữ liệu (product, counterparty, company, warehouse).
- Phải tự làm form (nút "Generate", period, parameters, filters) và thêm report vào command interface.
- Phần lớn report thực tế dùng template **"Data composition scheme"** (DCS) — bài sau.
- Ví dụ: report **SalesByCustomers** (subsystem Sales), template **Sales** kiểu SpreadsheetDocument, areas: Title, HeaderProducts, **RowCustomer**, **RowProduct** (multi-level bằng auto-grouping; dòng customer tô màu). Title dùng FillType Template.
- Form kiểu **"Report form"**: command bar có sẵn "Select option...", "Settings...", "More actions" (dùng cho DCS) → tắt **autofill** của command bar.
- Command **"Generate"** (handler client + server), nút bật **"DefaultButton"**.
- Form attribute **Result** kiểu **SpreadsheetDocument**, "TitlePosition" = "No", bật **ReadOnly**.
- Attribute **Period** kiểu **"StandardPeriod"**, **Products** kiểu **"ValueList"** với **"ValueType"** = `CatalogRef.Products`; đặt trong collapsible group "Parameters" (list items thêm như field, không phải table); bật **"ClearButton"** = "Yes".
- Khác print form: không cần `Show()` (form đã mở); filter tuỳ chọn — chỉ áp dụng khi user nhập.
- Procedure **GenerateAtServer**: `Result.Clear()` → lấy template và areas → query:
  - Tham số **FilterProducts** = `ValueIsFilled(Products)`: True → chỉ chọn record có product trong list; False → mọi record.
  - End date trống → truyền **Undefined** (virtual table trả record tới hiện tại); nếu truyền empty date thì chỉ chọn record tới 01.01.0001. Có end date → đưa về **cuối ngày**.
  - Multi-level: query **totals**, group theo customers, tính tổng field Amount.
- Điền: thực thi query → điền Title, xuất → xuất HeaderProducts → nếu không có record thì dừng → `StartRowAutoGrouping` → select theo groups (cấp 1: tổng theo customer, cấp 2: sản phẩm) → số thứ tự dạng **N.M** (biến khởi tạo trước vòng customers và trong vòng, trước vòng products) → `Put()` với level `Selection.Level()` → tăng biến số thứ tự → kết thúc autogrouping.
- Title theo period:
  - có cả start và end → "Sales by customers from []"
  - chỉ start → "Sales by customers from []"
  - chỉ end → "Sales by customers to []"
  - không có → "Sales by customers"
  - → header trở thành **parameter** điền hoàn toàn từ code.
- Loại report này **rất ít dùng**: user không đổi được cấu trúc, không tự thêm filter, không lưu report options. Chỉ dùng khi không thể dùng DCS.

## Cú pháp & ví dụ code

Ô FillType "Template":
```bsl
<Sales invoice [DocumentNumber] from [DocumentDate]>
```

```bsl
SpreadsheetDocument.Show()
```

Lấy area theo địa chỉ:
```bsl
GetArea("R2C2:R4C3")
GetArea(2, 2, 4, 3)
```

```bsl
SpreadsheetDocument.Clear()
```

```bsl
Header.Parameters.Fill(Selection)
```

```bsl
Header.Parameters.DocumentDate = Format(Selection.Date, "DLF=D")
```

Điều kiện trong query để in nhiều document:
```bsl
SalesInvoice.Ref In (&Ref)
```

```bsl
TotalAmount = TotalAmount + ProductsRow.Amount;
```

```bsl
AreaTitle.Parameters.DocumentDate = Format(Selection.DocumentDate, "DLF=DD");
```

```bsl
SpreadsheetDocument.PrintParametersKey = "SalesOfGoodsOfServices_SalesOfGoodsOfServicesWithDiscounts";
```

```bsl
BinaryData = New BinaryData(FullFileName)
```

```bsl
LogoChanged = True;

Modified = True;
```

```bsl
AreaTitle.Drawings.Logo.Line = New Line(SpreadsheetDocumentDrawingLineType.None);
```

```bsl
Result.Clear();
```

Các method được nêu trong bài: `GetTemplate()`, `GetArea()`, `Put()`, `Join()`, `PutHorizontalPageBreak()`, `StartRowAutoGrouping()`, `EndRowAutoGroup()`, `Level()`, `Select()`, `Unload()`, `Format()`, `LockFormDataForEdit()`, `BeginCheckingExistence`, `PutToTemporaryStorage`, `Get()` (ValueStorage), `New Picture(BinaryData)`, `New File(FileName)`, `ValueIsFilled(Products)`.

[ghi chú ngoài nguồn] Code đầy đủ của command module, PrintFormSalesInvoice, file dialog, OnReadAtServer/BeforeWriteAtServer và GenerateAtServer chỉ có dạng ảnh trong tài liệu nên không chép lại. Code logo/file dialog/OnReadAtServer/BeforeWriteAtServer với ValueStorage, function CompanyLogo và command SalesInvoice/PrintFormSalesInvoice của bài → xem mục Code demo của bài Theory (nhánh lesson/17-theory). GenerateAtServer của report programmatic template → xem Thẻ gợi ý bài thực hành (bài tập 4).

## Thuộc tính/thiết lập quan trọng trong Designer
- Template type: **Spreadsheet document**, **Text document**; prefix tên **PF_**.
- Cell: **FillType** (Text / Parameter / Template), **Format**, **HorizontalAlign** (Auto).
- Column Width (2.75 cho 40 cột A4; 0.9 cho cột lề; bước 0.125).
- Command: group **Form command bar.Important**, parameter type, **parameter usage mode = Multiple**.
- SpreadsheetDocument (code): **ShowGrid**, **Protection**, **ReadOnly**, **ShowHeaders**, **PageSize**, **FitToPage**, **PrintParametersKey**, **Drawings**.
- Wizard options: print without preview, view-only table, table protection.
- Image field: **Hyperlink**, **NonselectedPictureText**, **PictureSize** = Proportional, **TitlePosition**.
- Drawing: name, picture size = **Proportional**, **Line** = None, **Pattern** = Solid.
- Catalog attribute: kiểu **ValueStorage**.
- Report form: command bar autofill (tắt), **DefaultButton**, field **ReadOnly**, **TitlePosition** = No, **ClearButton** = Yes; attribute **StandardPeriod**, **ValueList** + **ValueType**.

## Lỗi thường gặp / lưu ý
- Wizard không kiểm tra space/ký tự cấm trong tên command.
- Tên parameter của area không khớp tên property của source → `Fill()` không điền.
- Tham số level của `Put()` vô nghĩa nếu không có `StartRowAutoGrouping()`/`EndRowAutoGroup()`.
- Thoát ô mà không thấy ngoặc nhọn → FillType chưa đặt "Template".
- Area 1 dòng không thêm dòng bằng insert được → dùng split cell (vertical) hoặc tạo lại.
- Kéo-thả attribute vào template phá merge ô.
- Format của ô vô tác dụng với ô FillType "Template"; format từ code đè format của ô; `Format()` trả String → ảnh hưởng căn lề Auto.
- Column width bị làm tròn xuống theo bước 0.125.
- Print form trông vừa nhưng không vừa 1 trang khi preview → dùng FitToPage (không hợp form quá rộng).
- Đổi PrintParametersKey → page settings của user có thể reset về mặc định.
- Ảnh không lưu sau "Save and close" nếu chưa code ghi vào ValueStorage (BeforeWriteAtServer) và đọc ra (OnReadAtServer); không truy cập được ValueStorage qua form data.
- Không truyền form unique identifier khi PutToTemporaryStorage → địa chỉ có thể bị xoá ở server call kế tiếp.
- Report: truyền empty date làm end date → chỉ chọn tới 01.01.0001; dùng Undefined.
- Pattern "Solid" có thể hiển thị đã chọn nhưng không hoạt động → chọn lại.

## Điểm cần nhớ
- Print form = Template (spreadsheet document) + code: `GetTemplate` → `GetArea` → điền `Parameters` → `Put`/`Join` vào SpreadsheetDocument.
- FillType: Text / Parameter (`<...>`) / Template (`[...]` trong text).
- Hỗ trợ in nhiều document: `Ref In (&Ref)`, usage mode Multiple, page break trước mỗi document (trừ document đầu).
- Code của manager module chỉ gọi được trên server; client nhận spreadsheet document rồi `Show(title)`.
- `FitToPage` để vừa trang; `PrintParametersKey` để nhớ page settings theo user.
- Ảnh: ValueStorage trong object, temporary storage + image field trên form, đọc ở OnReadAtServer, ghi ở BeforeWriteAtServer; in bằng drawing + `New Picture(BinaryData)`.
- Report kiểu programmatic template: tự làm form, period/filter tuỳ chọn, multi-level bằng TOTALS + row autogrouping — ít dùng, ưu tiên DCS.

## Thẻ gợi ý bài thực hành (Practice 17)

Các thẻ đi theo thứ tự đề trong 17. Practice.

### Bài tập 1 — Batch FIFO/LIFO/Manually cho document Inventory transfer

- **Đề bài (tóm tắt):** Hoàn thiện batch accounting cho Inventory transfer. Thêm attribute và element còn thiếu; FIFO/LIFO tự phân bổ batch, Manually thì có nút "Pick a batch" như các document khác. Amount trong movements tính theo balance, giống Sales invoice.
- **Gợi ý 1 — Hướng đi:** Dùng lại đúng thuật toán của Sales invoice ở Practice 16 (query Balance theo batch, sắp xếp theo ngày batch, biến "còn phải xuất", `Min()`, giá đơn vị = AmountBalance / QuantityBalance). Điểm khác: mỗi lượng phân bổ là một lần **chuyển kho**, nên tạo **hai** records cùng batch và cùng giá vốn: Expense ở kho xuất, Receipt ở kho nhận.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Document InventoryTransfer: column `Batch` trong tabular section Products (Required field, bỏ khỏi `CheckedAttributes` khi không Manually, như bài 15).
  - Form: `OnCreateAtServer` ẩn/hiện cột Batch và nút; command "Pick a batch" mở lại form chọn batch của Purchase invoice, truyền **WarehouseSender** làm kho.
  - Object module, `Posting`: balance lấy theo `WarehouseSender`; 2 lần `RegisterRecords.GoodsInWarehouses.Add()` cho mỗi phần phân bổ.
- **Gợi ý 3 — Khung bài làm:**
  1. Thêm column Batch, đưa lên form, thêm command Pick batch và callback.
  2. Ẩn/hiện theo WriteOffOrder; xử lý CheckedAttributes.
  3. Posting FIFO/LIFO: copy cấu trúc vòng lặp từ Sales invoice, đổi kho, thêm record Receipt.
  4. Posting Manually: theo batch của từng dòng, giá lấy từ balance theo product + batch.
  5. Kiểm tra tồn ở kho xuất bằng procedure chung (document này không có Company, nên không truyền Company).
  ```bsl
  // trong vòng lặp phân bổ batch
  	___ // số chuyển = min(còn phải chuyển, tồn batch)
  	___ // record Expense: kho XUẤT, Batch, Quantity, Amount = số chuyển * giá đơn vị
  	___ // record Receipt: kho NHẬN, cùng Batch, cùng Quantity và Amount
  	___ // trừ "còn phải chuyển"
  ```
- **Lỗi hay gặp:**
  - Chỉ ghi Expense mà quên Receipt ở kho nhận, hoặc ngược lại.
  - Truyền nhầm kho nhận vào form chọn batch. Batch phải lấy theo tồn ở **kho xuất**.
  - Receipt ở kho nhận ghi Amount khác Expense, làm giá trị hàng thay đổi khi chỉ chuyển kho.
  - Quên AutoDelete hoặc record set rỗng, nên re-post tính trùng balance.
- **Tự kiểm tra:** Chuyển 20 hammers (tồn 5/10/15 theo batch) với FIFO: Register records có 3 cặp Expense/Receipt (5, 10, 5) cùng batch và cùng amount. Report hoặc query balance: tổng amount của hai kho không đổi so với trước khi chuyển.

### Bài tập 2 — Print form "List of goods movement" cho Inventory transfer

- **Đề bài (tóm tắt):** Tạo print form "List of goods movement" cho Inventory transfer (có thể dùng wizard), bố cục cuối cùng phải giống ảnh trong đề.
- **Gợi ý 1 — Hướng đi:** Mục "Print forms" và "Tạo print form từ đầu": template spreadsheet document với các area có tên; code `GetTemplate` → `GetArea` → điền `Parameters` → `Put` vào SpreadsheetDocument. Command ở client chỉ nhận spreadsheet document từ server rồi `Show()`.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Template (prefix tên theo quy ước), các area ví dụ Title / Header / ProductsHeader / Products / Footer; cell FillType Parameter/Template.
  - Command của document: group **Form command bar.Important**, parameter type `DocumentRef.InventoryTransfer`, **parameter usage mode = Multiple**.
  - Command module: `CommandProcessing` (`&AtClient`) + function `&AtServer` một dòng gọi export function trong **manager module**.
  - Manager module: export function nhận mảng refs, trả `SpreadsheetDocument`; query lấy tabular section Products dạng nested (`Products.(...)`) hoặc query riêng.
- **Gợi ý 3 — Khung bài làm:**
  1. Chạy wizard hoặc tự tạo template; đặt tên area và parameter khớp tên field trong query.
  2. Viết function trong manager module: tạo spreadsheet, lấy template và area, query theo `Ref IN (&...)`.
  3. Vòng lặp document: page break trước mỗi document trừ document đầu; điền Title/Header; vòng lặp dòng products; Footer.
  4. Đặt `ShowGrid`/`ReadOnly`, trả kết quả.
  5. Command module gọi function và `Show("List of goods movement")`.
  ```bsl
  &AtClient
  Procedure CommandProcessing(CommandParameter, CommandExecuteParameters)
  	___ // gọi function server -> nhận spreadsheet document
  	___ // Show(<tiêu đề cửa sổ>)
  EndProcedure

  &AtServer
  Function ___(CommandParameter)
  	Return ___; // gọi export function trong manager module của document
  EndFunction
  ```
- **Lỗi hay gặp:**
  - Tên parameter của area không khớp tên field nên `Parameters.Fill()` không điền.
  - Gọi `Documents.<...>` từ client là không được, phải đi qua function `&AtServer`.
  - Quên page break hoặc dùng sai biến cờ, khiến các document dính vào nhau khi in nhiều cùng lúc.
  - Ngày in thô: dùng `Format(..., "DLF=D")`.
- **Tự kiểm tra:** Mở một Inventory transfer, bấm lệnh in: bố cục khớp ảnh trong đề (số, ngày, kho xuất/nhận, bảng dòng). Chọn 2 document trong list rồi in: mỗi document một trang.

### Bài tập 3 — Print form cho 2 documents

- **Đề bài (tóm tắt):** Trong file 17. Practice.docx, mục này chỉ có dòng tiêu đề "The print form for 2 documents:"; phần chi tiết (nhiều khả năng là ảnh mẫu) không có ở dạng văn bản. Hỏi giảng viên để biết chính xác bố cục được yêu cầu.
- **Gợi ý 1 — Hướng đi:** Dù bố cục là gì, print form phải xử lý được **nhiều document trong một lần in** (mục "Điểm cần nhớ": `Ref In (&Ref)`, usage mode Multiple, page break trước mỗi document trừ document đầu).
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Như thẻ 2: command có parameter usage mode = **Multiple**; trong manager module có biến cờ page break và `PutHorizontalPageBreak()`; nếu cần vừa trang thì dùng `FitToPage`, nhớ page settings theo user bằng `PrintParametersKey`.
- **Gợi ý 3 — Khung bài làm:**
  1. Xác nhận bố cục với ảnh mẫu.
  2. Kiểm tra command cho phép chọn nhiều document.
  3. Kiểm tra vòng lặp document đặt page break đúng chỗ.
- **Lỗi hay gặp:**
  - Usage mode để Single nên chỉ in được một document.
  - Page break đặt **sau** mỗi document, làm thừa một trang trắng ở cuối.
- **Tự kiểm tra:** Chọn 2 document trong list và in: 2 trang, mỗi trang đúng một document, không có trang trắng.

### Bài tập 4 — Report "Sales by customers" 3 cấp (programmatic template)

- **Đề bài (tóm tắt):** Report 3 cấp Company → Customer → Product. Cấp 1 và 2 có tổng quantity và amount, mỗi cấp một màu, thu gọn/mở rộng được. Có period, filter nhiều giá trị theo companies, customers, products; các field có nút clear. Đưa report vào subsystem Sales.
- **Gợi ý 1 — Hướng đi:** Mục "Reports với programmatic template filling": tự làm report form với attribute `Result` (SpreadsheetDocument), period và các filter. Query trên virtual table **Turnovers** của register Sales, dùng **TOTALS BY** để có tổng theo 2 cấp. Duyệt selection theo groups và `Put(area, Level())` giữa `StartRowAutoGrouping()` và `EndRowAutoGrouping()` để thu gọn được.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Report form attributes: `Result` (SpreadsheetDocument), `Period` (StandardPeriod), 3 attribute **ValueList** có **ValueType** tương ứng; field có **ClearButton** = Yes, **TitlePosition**; command Generate làm **DefaultButton**.
  - Template của report: area tiêu đề, header cột, 3 area dòng (mỗi cấp một màu nền).
  - Procedure `&AtServer` generate. Filter tuỳ chọn trong điều kiện virtual table: list rỗng thì không lọc (ví dụ cờ Boolean `ValueIsFilled(list)` kết hợp `CASE`).
  - `QueryResultIteration.ByGroups` cho cấp tổng, `Select()` thường cho dòng chi tiết.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo report, form, template, đưa report vào subsystem Sales.
  2. Generate: `Result.Clear()`, lấy area, viết query Turnovers có filter tuỳ chọn, ORDER BY, TOTALS SUM theo Company, Customer.
  3. Đặt tham số kỳ: end date trống thì truyền **Undefined**, có giá trị thì cuối ngày.
  4. Put tiêu đề và header, bật auto grouping, 3 vòng lặp lồng, mỗi lần Put kèm Level, rồi kết thúc auto grouping.
  ```bsl
  ___ // bật row auto-grouping
  SelectionCompanies = QueryResult.Select(___);       // duyệt theo groups
  While SelectionCompanies.Next() Do
  	___ // điền area Company, Put(area, SelectionCompanies.Level())
  	// tương tự: Customer (ByGroups) -> Product (Select() thường)
  	___
  EndDo;
  ___ // kết thúc row auto-grouping
  ```
- **Lỗi hay gặp:**
  - Truyền empty date làm end date thì chỉ chọn tới 01.01.0001. Dùng Undefined.
  - Truyền tham số level cho `Put()` nhưng không bật auto grouping thì không thu gọn được.
  - [ghi chú ngoài nguồn] Tên method đúng trong platform là `EndRowAutoGrouping()`; tài liệu lý thuyết viết `EndRowAutoGroup()`.
  - Filter dùng `IN (&List)` với list rỗng sẽ không trả dòng nào. Phải có nhánh "không lọc".
- **Tự kiểm tra:** Generate không filter: 3 cấp với tổng đúng, nút +/- thu gọn được Company/Customer. Chọn 2 customer trong filter: chỉ còn các customer đó. Xoá filter bằng nút clear rồi generate lại. Đối chiếu tổng với report hoặc register Sales.

## Code demo của bài Theory (repo 1CJDCourse, nhánh lesson/17-theory)

### Logo của company: OnReadAtServer đọc ValueStorage, BeforeWriteAtServer ghi ValueStorage có nén

Nguồn: nhánh lesson/17-theory — cf/Catalogs/Companies/Forms/ItemForm/Ext/Form/Module.bsl

```bsl
&AtServer
Procedure OnReadAtServer(CurrentObject)
	
	BinaryData = CurrentObject.LogoPicture.Get();
	If TypeOf(BinaryData) = Type("BinaryData") Then
		LogoPictureAddress = PutToTempStorage(BinaryData, UUID);
	EndIf;
	
EndProcedure

&AtServer
Procedure BeforeWriteAtServer(Cancel, CurrentObject, WriteParameters)
	
	If LogoChanged Then
		BinaryData = GetFromTempStorage(LogoPictureAddress);
		CurrentObject.LogoPicture = New ValueStorage(BinaryData, New Deflation(9));
	EndIf;
	
EndProcedure
```

- Đọc: `CurrentObject.LogoPicture.Get()` (ValueStorage chỉ có `Get()`), kiểm tra kiểu `BinaryData` rồi `PutToTempStorage(BinaryData, UUID)` → địa chỉ gán vào form attribute `LogoPictureAddress` mà image field hiển thị.
- Ghi: chỉ khi `LogoChanged` → lấy binary data từ temporary storage, gán `New ValueStorage(BinaryData, New Deflation(9))` vào `CurrentObject` (nén tối đa, đúng khuyến nghị cho dữ liệu lớn).
- Làm việc qua `CurrentObject` trong hai form event này vì platform không cho truy cập attribute ValueStorage qua form data — đúng phần lý thuyết "Working with images".

### Chọn file logo: Click của image field → FileDialog → BeginCheckingExistence

Nguồn: nhánh lesson/17-theory — cf/Catalogs/Companies/Forms/ItemForm/Ext/Form/Module.bsl

```bsl
&AtClient
Procedure LogoPictureAddressClick(Item, StandardProcessing)
	
	StandardProcessing = False;
	LockFormDataForEdit();
	
	AddLogoOnClientStartChoosing();
	
EndProcedure

&AtClient
Procedure AddLogoOnClientStartChoosing()
	
	FileDialog = New FileDialog(FileDialogMode.Open);
	FileDialog.Filter 		= "All images (*.bmp;*.png;*.jpeg;*.jpg)|*.bmp;*.png;*.jpeg;*.jpg";
	FileDialog.Multiselect 	= False;
	FileDialog.Title 		= "Select a logo image file";
	
	FileDialog.Show(New CallbackDescription("AddLogoOnClientFinishChoosing", ThisObject));

EndProcedure

&AtClient
Procedure AddLogoOnClientFinishChoosing(SelectedFiles, AdditionalParameters) Export

	If SelectedFiles = Undefined Then
		Return;
	EndIf;

	FileName = SelectedFiles[0];
	
	LogoFile = New File(FileName);
	
	CallbackDescription = New CallbackDescription(
		"AddLogoOnClientCompletion",
		ThisObject,
		New Structure("FileName", FileName)
	);
	LogoFile.BeginCheckingExistence(CallbackDescription);
	
EndProcedure

&AtClient
Procedure AddLogoOnClientCompletion(Exist, AdditionalParameters) Export

	If Not Exist Then
		MessageText = StrTemplate(
			"File by the path '%1' doesn't exist, try to select a file once again",
			AdditionalParameters.FileName
		);
		Message(MessageText);
		Return;
	EndIf;
	
	BinaryData = New BinaryData(AdditionalParameters.FileName);
	
	LogoPictureAddress = PutToTempStorage(BinaryData, UUID);

	LogoChanged = True;
	Modified = True;
	
EndProcedure
```

- Handler `Click`: tắt standard processing (nếu không sẽ mở cửa sổ hiện string của attribute) và gọi `LockFormDataForEdit()` để khoá object company.
- File dialog đặt trong procedure riêng: `Filter` chỉ ảnh, `Multiselect = False`, `Title`, mở bằng `Show()` với `CallbackDescription`; callback `Export` nhận `SelectedFiles` (Undefined khi huỷ).
- Kiểm tra file tồn tại bằng `New File(FileName)` + `BeginCheckingExistence`, FileName truyền qua AdditionalParameters của callback description.
- Tồn tại → `New BinaryData(...)` → `PutToTempStorage(BinaryData, UUID)` (gắn unique identifier của form), rồi `LogoChanged = True` và `Modified = True` để platform hỏi lưu khi đóng.

### Logo trong print form: function trong catalog manager module + drawing "Logo"

Nguồn: nhánh lesson/17-theory — cf/Catalogs/Companies/Ext/ManagerModule.bsl; cf/Documents/SalesInvoice/Ext/ManagerModule.bsl

Catalog Companies, manager module:

```bsl
Function CompanyLogo(Company) Export
	
	Query = New Query;
	Query.Text = 
	"SELECT
	|	Companies.LogoPicture AS LogoPicture
	|FROM
	|	Catalog.Companies AS Companies
	|WHERE
	|	Companies.Ref = &Ref";
	
	Query.SetParameter("Ref", Company);
	
	Selection = Query.Execute().Select();
	If Selection.Next() Then
		Return Selection.LogoPicture.Get();
	Else
		Return Undefined;
	EndIf;
	
EndFunction
```

Đoạn điền area Title trong `PrintFormSalesInvoice` (document SalesInvoice, manager module):

```bsl
Function PrintFormSalesInvoice(PrintingObjects) Export
	
	SpreadsheetDocument = New SpreadsheetDocument;
	SpreadsheetDocument.ShowGrid = False;
	
	SpreadsheetDocument.PrintParametersKey = "SalesInvoice_SalesInvoice";
// ...
	InsertPageBreak = False;
	While Selection.Next() Do
		If InsertPageBreak Then
			SpreadsheetDocument.PutHorizontalPageBreak();
		EndIf;
		
		AreaTitle.Parameters.Fill(Selection);
		AreaTitle.Parameters.DocumentDate = Format(Selection.DocumentDate, "DLF=DD");
		
		CompanyLogo = Catalogs.Companies.CompanyLogo(Selection.Company);
		If TypeOf(CompanyLogo) = Type("BinaryData") Then
			Picture = New Picture(CompanyLogo);
			AreaTitle.Drawings.Logo.Picture = Picture;
		EndIf;
		
		SpreadsheetDocument.Put(AreaTitle);
// ...
		InsertPageBreak = True;
	EndDo;
	
	SpreadsheetDocument.FitToPage = True;
	
	Return SpreadsheetDocument;
	
EndFunction
```

- `CompanyLogo()` là export function trả `LogoPicture.Get()` (binary data hoặc Undefined) — đúng gợi ý "function export trong catalog manager module" của bài.
- Kiểm tra `TypeOf(...) = Type("BinaryData")` → `New Picture(CompanyLogo)` → gán vào `AreaTitle.Drawings.Logo.Picture` (drawing đặt tên "Logo" trong template).
- Cùng function có các thiết lập của bài: `ShowGrid = False`, `PrintParametersKey = "SalesInvoice_SalesInvoice"` (dạng `<tên object>_<tên print form>`), page break trước mỗi document trừ document đầu, `FitToPage = True`.
- Dòng bỏ khung bằng code `AreaTitle.Drawings.Logo.Line = New Line(...)` không có trong nhánh (code của mục "Cú pháp & ví dụ code" vẫn là nguồn duy nhất).

### Command SalesInvoice: server function một dòng gọi PrintFormSalesInvoice

Nguồn: nhánh lesson/17-theory — cf/Documents/SalesInvoice/Commands/SalesInvoice/Ext/CommandModule.bsl

```bsl
&AtClient
Procedure CommandProcessing(CommandParameter, CommandExecuteParameters)

	SpreadsheetDocument = PrintFormSalesInvoice(CommandParameter);
	
	SpreadsheetDocument.Show("Sales invoice");
	
EndProcedure

&AtServer
Function PrintFormSalesInvoice(PrintingObjects)
	Return Documents.SalesInvoice.PrintFormSalesInvoice(PrintingObjects);
EndFunction
```

- Đúng phiên bản "tạo print form từ đầu" của bài (tên command và function trùng ảnh trong tài liệu): client gọi function `&AtServer` một dòng, nhận spreadsheet document rồi `Show("Sales invoice")` với tiêu đề cửa sổ.

## Video tham khảo

Video bài giảng trên YouTube có phạm vi trùng với bài này. Khi dẫn cho người học, nói "Bạn có thể tham khảo thêm về <chủ đề> của khóa tại đây: [<tên video>](link)" — không nói "khóa cũ/Junior", không dùng mã JC (mã JC trong danh sách chỉ để tra nội bộ). Quy ước đầy đủ: `references/video.md#video-junior-course`.

- [Báo cáo dựa trên khuôn mẫu](https://www.youtube.com/watch?v=WVqrshBBH-E&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=46) (6:34) — Bài 18 — DCS (theo mô tả của bảng gốc); nếu video nói về report điền template bằng code thì là Bài 17. Lưu ý: Tên video "báo cáo dựa trên khuôn mẫu" trùng tên Bài 17 (template-based reports) nhưng mô tả của bảng gốc là giới thiệu DCS — cần xem video để chốt. _(mã nội bộ JC-47)_

<!-- video-qa-thuchanh:start -->

Video giải đáp tình huống thực chiến và video thực hành từng bước liên quan tới bài này (thẻ chi tiết, triệu chứng, lưu ý khi giới thiệu: `references/video.md#video-qa-thuc-chien`, `references/video.md#video-thuc-hanh`; cùng mẫu câu dẫn ở trên):

- [Thêm ảnh cho các đối tượng](https://www.youtube.com/watch?v=TQNa4cveOdc&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=6) (10:04) — lưu và hiển thị ảnh cho sản phẩm (giải đáp tình huống; Bài 17 chính) _(mã nội bộ QA-6)_
- [Tạo chức năng in hóa đơn chứng từ](https://www.youtube.com/watch?v=uwEBQJZG6t4&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=7) (5:31) — tạo mẫu in chứng từ bằng Print wizard (giải đáp tình huống; Bài 17 chính) _(mã nội bộ QA-7)_

<!-- video-qa-thuchanh:end -->


---

# § bai-18

# Bài 18 — Reports: Data composition system (DCS)

## Khái niệm chính

### Basics of DCS
- **Data composition system (DCS)**: công cụ bao trùm mọi chức năng chính của report, từ lấy dữ liệu từ nhiều nguồn tới hiển thị thân thiện. Nguồn thường là database, mô tả bằng 1C:Enterprise query language.
- Developer định nghĩa **default report settings** để user chạy ngay; user có thể đổi settings → DCS sinh query khác và trình bày theo settings của user.
- DCS là tập các elements, mỗi element ứng với một giai đoạn thực thi report; mỗi element có declarative description, truy cập bằng code và serialization to/from XML.
- Hai thành phần chính ảnh hưởng kết quả: **composition schema** và **composition settings**.
- **Composition schema** — element cơ bản, mô tả mọi quy tắc lấy và xử lý dữ liệu:
  - Data sets
  - Composition fields
  - Calculated fields
  - Resources
  - Parameters
  - Element bổ sung (cho report phức tạp): Data set links, Templates, Nested schemas.
- **Data composition settings** — mô tả cách trình bày dữ liệu (developer hoặc user cấu hình): filter, ordering, conditional appearance, report structure, data retrieval parameters, data output parameters...
- **Data composition template** — kết quả áp dụng settings cụ thể lên schema; là "task" sẵn sàng cho composition processor. Gồm:
  - Data sets with resulting queries
  - Data set relationships
  - Parameter values
  - Layouts of various report areas
  - Body of the layout với correspondence settings giữa report structure và layouts
- **Composition template query** có thể khác nhiều so với query trong schema: chỉ chứa field và filter được chọn trong settings; field không dùng bị **tự động loại** khỏi query cuối (ngoại lệ: composition fields có role đặc biệt **"Balances"**). Query trong schema còn có thể chứa query language extensions cho DCS.
- Quá trình generate tự động; cũng có thể làm bằng code.

### Data sets
- Ba loại:
  1. **Query** — mô tả bằng query language.
  2. **Object** — tên external data set (value table, selection từ query result, range ô của spreadsheet document, register record set...). Phổ biến nhất: **value table**.
  3. **Union** — không phải data set thực, gộp nhiều data set thành một (giống UNION trong query), nhưng các data set con **không cần cùng số field**. Ví dụ gộp sales và purchases theo product.
- Thuộc tính chung: **Name** (duy nhất trong schema), **Fields**.
- Data set kéo-thả được. Rename bằng double-click tên.
- Union: field cùng **Path** (ví dụ Product) lấy dữ liệu từ cả hai data set con; record **chưa group** trước output (record có balance, record có sales riêng) — grouping làm ở bước sau. Muốn tách → đổi **Path** trong một data set (ví dụ `Product` → `ProductBalance`).

### Simple report (ví dụ Sales)
- Đổi tên report cũ thành **SalesTemplate** (synonym "Sales (template)"), tạo report **Sales** mới trong subsystem Sales. Tạo template kiểu **Data composition schema** bằng nút kính lúp ở field **"Main data composition schema"** hoặc nút **"Open data composition schema"**; loại template cố định, chỉ đổi tên → "Finish".
- Data set Query tên **Sales** — virtual table turnovers của register Sales. **Không cần totals trong query** (hierarchy làm bằng DCS).
- **Resources** tab: field được tính theo groupings (group / overall totals):
  - **Expression** — công thức, ví dụ `Sum(Balance)`; có aggregate functions, custom functions trong expression language của DCS, và cả **export function của common modules**.
  - **Calculate by…** — danh sách groupings tính resource. Trống → mọi grouping. Có giá trị → chỉ có ở grouping đó.
  - Nút **">>"** thêm mọi resource có thể tính totals. Amount → `Sum()`.
- **Settings** tab có 3 phần:
  - Trái: danh sách **report options** (một report nhiều option, ví dụ theo customer hoặc theo product).
  - Phải trên: cấu trúc groupings, tables, diagrams.
  - Phải dưới: parameters, selected fields, filter, sorting, conditional appearance, custom fields, other settings.
- **Settings wizard**:
  - Loại report: **list**, **table**, **diagram**. **Table** = chỉ tiêu tại giao điểm dòng × cột (ví dụ tồn kho: dòng là product, cột là warehouse); không hợp khi số chiều lớn (ví dụ 20+ warehouse).
  - Chọn fields: resources phải chỉ định theo thứ tự hiển thị; groupings có thể bỏ (sẽ tự thêm ở bước sau).
  - Groupings: Customer rồi Product. Với object có hierarchy chọn grouping type: **elements**, **hierarchy**, **hierarchy only** (hierarchy → hiện cả đường dẫn nhóm, tính totals theo hierarchy).
  - Sorting: nếu không chỉ định → DCS sắp tăng dần theo quy tắc kiểu primitive (date, number, string, boolean) và theo **presentation** với reference types (ví dụ description nếu main presentation là description); nhiều field trong một grouping → áp dụng lần lượt.
- Không cần tạo report form — platform tạo **default form**. Đổi tên report option thành **SalesByCustomers**.
- Favorites lưu theo **full name** → report mới mang tên cũ tự hiện trong Favorites, report cũ bị loại khỏi Favorites sau khi đổi tên.
- Form mặc định: nút **"Select option…"** (danh sách report options), **"Settings…"** (settings dành cho user).

### Parameters
- Tab **Parameters** tự có **BeginOfPeriod** và **EndOfPeriod** vì: (1) query dùng virtual table Turnovers có các parameter đó; (2) flag **Autofill** dưới query text trên tab Data sets được bật (tự lấy mọi field dùng trong query làm resource/grouping/filter...). Tắt Autofill → phải tự khai báo field, selection fields, virtual table parameters...
- Đặt tên parameter riêng trong virtual table → tab Parameters có 4 parameter (2 của DCS + 2 tự đặt).
- Đưa setting cho user: Settings → tab Parameters (cũng như Filter, Sorting, Conditional appearance) có flag **"Include in custom settings"**. **"Edit mode"**: **"Quick access"** → hiện ngay trên report form; **"Normal"** → chỉ trong cửa sổ settings.
- Bỏ giờ khỏi ngày: cột **"Type"** → **"Date format"** = "Date".
- Luôn bật parameter (không có checkbox): cột **"Usage"** = **"Always"** thay cho "Auto".
- Virtual table turnovers: empty date ở start/end → không giới hạn.
- Cột **"Expression"** (ngôn ngữ DCS, giao một phần với built-in language): `EndOfPeriod(<Period>, <PeriodType>)`, tham số viết sau ký hiệu **`&`**, PeriodType là chuỗi ("Day", "Month"...).
  - Vấn đề: ngày trống → thành cuối ngày 1.1.0001 (23:59:59) → report không có dữ liệu. Cách xử lý: biểu thức CASE kiểm tra empty date, hoặc dùng **standard period** (tự đưa end date về cuối ngày nếu không trống) — bài chọn cách này.
- Parameter **Period** kiểu **StandardPeriod**, always use. Với BeginOfPeriod/EndOfPeriod: bật **"Availability restriction"**, tắt **"Include in available fields"**, **"Usage"** về Auto; Expression: `&Period.StartDate`, `&Period.EndDate`. Bật "Include in custom settings" cho Period.

### Filter
- Thêm filter trên tab Filter rồi đưa vào custom settings với "Quick access".
- User tự cấu hình: submenu **"More actions"** → **"Change option..."** → cửa sổ gần giống tab Settings trong Designer. Ví dụ filter Product, comparison type **"In the list"**, bỏ use flag (tắt mặc định), include in custom settings + quick access → "finish editing".
- Filter user tạo chỉ user đó thấy; có thể lưu report option. Không đi sâu vào lưu report variant vì cấu hình hiện đại dùng report variants nâng cao trong subsystem **Reports** của **Standard Subsystems Library**.
- Để mọi user có filter → thêm ở mức configuration (Designer).
- Cột **Presentation** trên tab Filter → filter **"fixed"**: user chỉ bật/tắt, không đổi comparison type hay giá trị (ví dụ "Amount >= 1000" với presentation "Only for the amount from 1000"). Trong Enterprise mode: right-click → **"Set presentation"**, hoặc bật flag **"Detailed"** trong "More actions".
- User đổi được cấu trúc report (groupings, tables, diagrams) nhưng **không** đổi được data sets, parameters, resources → developer đôi khi chọn sẵn field bổ sung.

### Complex report (ví dụ PlannedSalary)
- Bối cảnh: hệ thống HRM bên ngoài trả bảng *Employee - Company - NumberOfHours - CurrentSalary*; cần report: employee, số giờ, lương tính, bonus/fine (có thể âm), số tiền trả = lương tính + bonus/fine (âm → hiển thị 0). Chỉ nhân viên đang làm việc tại ngày hiện tại (resource **"Works"** của information register **"Employees"**).
- Tạo subsystem **Salary** (con của HRM); accumulation register **BonusesFinesOfEmployees** kiểu **"Turnover"** (Dimensions: Employee, Company; Resources: Bonus, Fine); document **BonusesFinesOfEmployeesRegistration** (accumulation register không thể độc lập).
- Report **PlannedSalary**: data set **"object"** tên **"CurrentSalaryAccruals"**, field **"Data object name"** = **"PayrollAccrualsFromHRM"** (tên để truyền từ code); tự khai báo fields và value type.
- Data set "query" chọn nhân viên + bonus/fine từ information register "Employees" và accumulation register "BonusesFinesOfEmployees".
- **Data set links**: **mọi link là left join**. **"Link source"** = bảng chính, **"Link target"** = bảng nối; **"Source expression"**, **"Target expression"** = field hoặc biểu thức DCS.
  - Ưu điểm chính: dù mỗi set có nhiều dòng cùng giá trị field nối, khi tính totals chỉ dùng một record mỗi set, **không nhân đôi**; totals theo grouping đúng (khác với join nhiều bảng trong một query).
  - Truyền field của data set chính làm **query parameter** của data set nối: field **"Parameter"** (ví dụ `&Product`) → mỗi product một query. Parameter phải khai báo trong query; nếu chỉ dùng để link → khai báo trên tab **"Data composition"** của query (mọi parameter/field/condition ở tab này là tuỳ chọn).
  - Đơn giản nhưng có thể chậm: 1000 record → 1000 query. Tối ưu: flag **"Parameter list"** → query theo lô **1000 record** (1500 record → 2 query); điều kiện phải đổi sang **IN**: `Product IN (&Product)`.
  - Ví dụ: BonusesFinesOfEmployees làm data set chính, link qua 2 field Employee và Company.
- **Calculated fields**: field bổ sung tính bằng công thức (expression language của DCS); hiện trong settings theo tên ở path. **Hạn chế**: không dùng calculated field khác trong biểu thức. Được dùng data set fields, mọi cú pháp expression language, function **Export** của common modules. Có title, availability restriction, presentation expression, ordering expressions, value type, available values, formatting. Có thể làm resource (thêm vào Resources + expression tính total).
  - Khi chỉ cần tính giá trị cho resource → dùng expression ở Resources, không cần calculated field. Cần field mới không có trong data sets, hoặc field không phải resource → dùng calculated field.
  - Ví dụ: **AmountToPay** = `CurrentSalary + BonusFine`, value type **Number(10, 0)**. Platform cảnh báo khi dùng field không tồn tại.
- Parameters: Period và EndOfPeriod = `CurrentSessionDate()`; BeginOfPeriod = `BeginOfPeriod(CurrentSessionDate(), "Month")`; bật **"Restrict availability"**.
- Settings: option **"PlannedSalaryByCompanies"**; grouping Company → Employee (thêm field Position, Department qua edit grouping: double-click / nút pencil / **F2**). Gom field: chọn → right-click **"group fields"** → group tiêu đề **"Salary"**. Filter company và employee: include in user settings nhưng tắt mặc định.
- Không truyền object data set → user nhận lỗi khi generate.
- **Report object module**, handler **OnComposeResult** (kích hoạt khi generate qua method **`ComposeResult()`** — method then chốt khởi động toàn bộ quá trình):
  1. `StandardProcessing = False`.
  2. Lấy settings của **settings composer**.
  3. Tạo **DataCompositionTemplateComposer**, gọi **`Execute()`** truyền schema, settings và **details data** (từ tham số OnComposeResult) → nhận **DataCompositionTemplate**.
  4. Tạo **Structure** external data sets: key = **data object name** của object data set, value = giá trị hợp lệ (ở đây **ValueTable**).
  5. Tạo **DataCompositionProcessor**, khởi tạo với template + external data sets.
  6. Tạo **DataCompositionResultSpreadsheetDocumentOutputProcessor**, set spreadsheet document (**ResultDocument**), output kết quả. Muốn ra collection (ValueTable/ValueTree) → **DataCompositionResultValueCollectionOutputProcessor**.
  - **DetailsData**: khi DCS tạo spreadsheet document, ô chứa **DetailsIdentifier**, không chứa giá trị field; giá trị lấy từ object DetailsData được điền khi output.
  - Function giả lập HRM: chọn nhân viên đang làm, số giờ/lương random; max = số ngày tới hôm nay × 8 (ví dụ ngày 20 → 160).

### Characteristics in the report
- Characteristics đã khai báo cho object trong **characteristics window** (bài chart of characteristic types) → tự có trong report như attribute của object đó; characteristics của object khác không thấy.
- Chỉ có ở **Enterprise mode**, không có trong Designer. Nếu chưa khai báo cho object → thêm trên tab **Characteristics** của query (query console) — chỉ dùng được trong report đó. Khuyến nghị khai báo trực tiếp trong object.
- Ví dụ report kiểu **Table**: dòng = product, cột = characteristic "Color"; cột tiêu đề trống = sản phẩm chưa có Color. Hai resource → mỗi cột màu hiện cả hai.

### Report design
- Tab **Other/Additional settings**: **"Appearance template"** mặc định **"Main"**; không có metadata object **"Style"** → không có màu (như "Without appearance"). Ví dụ chọn **"Antique"**.
- **Conditional appearance** (developer và user đều dùng được), 4 thiết lập:
  - **Format** — background color, text color, font, cell format, text thay giá trị...
  - **Condition** — ví dụ `Balance < 0`.
  - **Formatted fields**.
  - **Usage area** — groupings, hierarchical groupings, totals, field headers, resource field headers, totals headers, totals resource field headers, header, parameters, filter…
- Ví dụ "Goods movement": màu chữ đỏ dùng predefined color **"Negative number"**. Một điều kiện cho một cột → cần 8 dòng; thay bằng auxiliary formatting **"Mark negatives"** trong Format window — chỉ cần chọn fields, platform tự kiểm tra giá trị âm → 1 dòng là đủ.
- Áp dụng chỉ cho một số grouping: chọn grouping trong report structure → settings riêng của grouping → thêm conditional appearance ở đó (ví dụ Product và Recorder, không cho Warehouse), xoá dòng trong report settings chung.

### Roles of fields
- Đặt trên tab Data sets, nút chọn ở cột **Role**. Platform tự đặt một số.
- Thuộc tính:
  - **Without role**.
  - **Period** — số thứ tự period; 0 = không phải period; period nhỏ nhất = 1, cha = 2... Ví dụ query Balances and Turnovers: Period = 3, Recorder = 2, LineNumber = 1; không dùng LineNumber → Recorder = 1, PeriodSecond = 2... Platform dùng để tính totals cho balance fields.
  - **Additional** — period field tuỳ chọn: không bắt buộc dùng nếu period con được dùng. Nếu không đặt → dùng period con thì field này cũng phải có trong grouping.
  - **Dimension** — dùng khi tính totals cho resources.
  - **Ignore NULL values** — không đưa group record cho field có giá trị NULL.
  - **Required** — thêm field vào data set của composition template nếu có ít nhất 1 field của data set được dùng trong settings (vì DCS loại field không dùng khỏi query → có thể gây lỗi).
  - (Không học: roles "Account" và "Balances".)
- **Periodicity** trong virtual table Turnovers / BalanceAndTurnovers: muốn chọn Recorder phải đặt **Recorder**, **Record** hoặc **Auto**.
  - **Important**: periodicity quyết định cách group resources: Recorder → theo dimensions + recorder; Record → thêm tới record number (nếu chọn LineNumber); Auto → chọn được Second, Hour, Day, Month..., group tới period chi tiết nhất được chọn.
- Gom field thành nhóm bằng **Path** dạng `GroupName.FieldName` (ví dụ `Receipt.Quantity`, `Expense.Quantity`).
- Report Goods movement: groupings Warehouse - Product - Recorder; field groups "Beginning of period", "Receipt", "Expense", "End of period"; đặt tiêu đề "Quantity"/"Amount" bằng nút **"Set title"** (không đặt title trùng nhau trong data set vì user không phân biệt được field trong Enterprise mode).
- Vấn đề: totals opening/closing trong grouping bị ngược (DCS không có dữ liệu theo giây). Giải pháp: chọn field **PeriodSecond** trong query → platform tự gán role **"Period, 2"** (Recorder là "Period, 1"); "additional" bỏ chọn → totals tính theo field này kể cả khi không chọn trong report. Chọn thêm PeriodDay → platform đặt "Additional" cho nó (đã có period chi tiết hơn). Xoá PeriodDay vì không cần.

## Cú pháp & ví dụ code

Ví dụ expression của resource:
```bsl
Sum(Balance)
```
```bsl
1
```
```bsl
Balance / Total * 100
```
```bsl
CASE WHEN FieldValue > 1 THEN True ELSE False END
```
```bsl
ServerCommonModule.Function(Parameter1, Parameter2)
```

Expression của parameter:
```bsl
EndOfPeriod(<Period>, <PeriodType>)
```
```bsl
CASE WHEN &EndOfPeriod = DateTime(1, 1, 1) THEN DateTime(1, 1, 1) ELSE EndOfPeriod(&EndOfPeriod, "Day") END
```
```bsl
&Period.StartDate
```
```bsl
&Period.EndDate
```

Điều kiện khi bật "Parameter list" trong data set links:
```bsl
Product IN (&Product)
```

Calculated field:
```bsl
CurrentSalary + BonusFine
```

Parameters của report PlannedSalary:
```bsl
CurrentSessionDate()
```
```bsl
BeginOfPeriod(CurrentSessionDate(), "Month")
```

Path nhóm field:
```bsl
Receipt.Quantity
Expense.Quantity
```

Các object/method dùng trong OnComposeResult: `ComposeResult()`, `DataCompositionTemplateComposer`, `Execute()`, `DataCompositionTemplate`, `DataCompositionProcessor`, `DataCompositionResultSpreadsheetDocumentOutputProcessor`, `DataCompositionResultValueCollectionOutputProcessor`, `DetailsData`, `DetailsIdentifier`.

[ghi chú ngoài nguồn] Code đầy đủ của OnComposeResult, function giả lập HRM và query text chỉ có dạng ảnh trong tài liệu nên không chép lại. Function giả lập HRM `PayrollAccrualsFromHRM`, OnComposeResult của PlannedSalary và query text của report Sales/PlannedSalary/GoodsMovement → xem mục Code demo của bài Theory (nhánh lesson/18-theory).

## Thuộc tính/thiết lập quan trọng trong Designer
- Report: **Main data composition schema**, nút **Open data composition schema**.
- Data set: **Name**, **Fields**, **Path**, **Role**, flag **Autofill**; object data set: **Data object name**; query tab **Data composition**, **Characteristics**.
- Resources: **Expression**, **Calculate by…**, nút **">>"**.
- Parameters: **Type** (Date format), **Usage** (Auto/Always), **Expression**, **Availability restriction / Restrict availability**, **Include in available fields**.
- Settings: **Include in custom settings**, **Edit mode** (Quick access / Normal), Filter **Presentation**, comparison type **In the list**, grouping type (elements / hierarchy / hierarchy only), **group fields**, **Set title**.
- Data set links: **Link source**, **Link target**, **Source expression**, **Target expression**, **Parameter**, **Parameter list**.
- Calculated field: path, expression, value type (ví dụ Number(10, 0)), title, availability restriction, presentation expression, ordering expressions, available values, formatting.
- Other/Additional settings: **Appearance template** (Main / Without appearance / Antique).
- Conditional appearance: **Format** (bao gồm **Mark negatives**, màu **Negative number**), **Condition**, **Formatted fields**, **Usage area**.
- Field roles: **Period**, **Additional**, **Dimension**, **Ignore NULL values**, **Required**.
- Virtual table parameter **Periodicity**: Recorder / Record / Auto.
- Enterprise mode: **More actions → Change option...**, **Set presentation**, flag **Detailed**.

## Lỗi thường gặp / lưu ý
- Field không dùng trong settings bị loại khỏi query cuối → có thể gây lỗi; dùng role **Required** khi cần.
- Parameter mặc định có checkbox và giờ trong ngày → đặt Date format và Usage = Always.
- Dùng `EndOfPeriod(&EndOfPeriod, "Day")` khi ngày trống → thành 1.1.0001 23:59:59 → report rỗng; dùng CASE hoặc StandardPeriod.
- Không truyền external data set cho object data set → lỗi khi generate.
- Data set links với parameter: mỗi dòng một query → chậm; bật "Parameter list" và dùng IN.
- Calculated field không được tham chiếu calculated field khác.
- Appearance template "Main" không có màu nếu configuration không có metadata object "Style".
- Đặt title trùng nhau trong data set → user không phân biệt được field; dùng "Set title" trong settings.
- Totals opening/closing balance sai khi không có dữ liệu theo giây → thêm PeriodSecond (role Period).
- Union data set: record chưa group trước output.
- Characteristics trong report chỉ có ở Enterprise mode.
- Favorites lưu theo full name → đổi tên report ảnh hưởng Favorites.

## Điểm cần nhớ
- DCS = **composition schema** (data sets, fields, calculated fields, resources, parameters) + **settings** → **composition template** → composition processor → output.
- Data sets: Query / Object (thường là value table, truyền từ code) / Union (không cần cùng số field).
- Resources = totals theo grouping (Expression + Calculate by); không cần TOTALS trong query.
- Đưa parameter/filter cho user: **Include in custom settings** + **Quick access**; dùng **StandardPeriod** với Expression `&Period.StartDate` / `&Period.EndDate`.
- Data set links luôn là **left join**, totals không bị nhân đôi; "Parameter list" xử lý theo lô 1000.
- Generate bằng code trong **OnComposeResult**: TemplateComposer → Processor (kèm external data sets) → OutputProcessor.
- Conditional appearance: Format/Condition/Formatted fields/Usage area; "Mark negatives" tiện cho số âm; có thể đặt theo từng grouping.
- Field role **Period** (và PeriodSecond) cần để totals của balance tính đúng; periodicity Recorder/Record/Auto mới chọn được Recorder.

## Thẻ gợi ý bài thực hành (Practice 18)

Các thẻ đi theo thứ tự đề trong 18. Practice. Cả hai report đều làm bằng DCS (data composition system).

### Bài tập 1 — Report "Sales with price deviation"

- **Đề bài (tóm tắt):** Report DCS gồm quantity đã bán, giá thực tế (Amount / Quantity), giá kế hoạch (export function lấy giá tại **ngày bán**) và chênh lệch (thực tế − kế hoạch), tính trung bình theo product. Có 2 variant (Company → Customer → Product và Customer → Product). Loại hàng trả. Có period kiểu StandardPeriod, filter company/customer/product ngay trên form. Giá chỉ hiện ở grouping Product và tổng chung; giá thực tế hiển thị dạng số nguyên. Đưa report vào subsystem Sales.
- **Gợi ý 1 — Hướng đi:**
  - Data set query trên **Turnovers** của register Sales, periodicity cho phép lấy ngày của record (SecondPeriod hoặc Recorder), rồi lọc quantity turnover **dương** để loại hàng trả.
  - Giá kế hoạch là **calculated field** có expression gọi export function của common module (DCS cho phép gọi function server trong expression).
  - Trung bình và chênh lệch là **resources** (mục "Resources = totals theo grouping"), với **Calculate by** = Product.
  - Lưu ý trong lý thuyết: expression của calculated field **không được** tham chiếu calculated field khác, nhưng expression của resource thì được.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Main data composition schema của report; query có field giá thực tế, dùng `CASE` chống chia 0.
  - Calculated field `PricePlan`: expression gọi function lấy giá đã làm ở bài information registers, qua common module có flag **Server call**, truyền product và **ngày bán**.
  - Calculated field `Deviation` (có thể để trống expression) và các resources: Quantity (Sum), PriceFact/PricePlan (Avg), Deviation (chênh lệch hai trung bình), Calculate by Product.
  - Format của field giá thực tế: `NFD=0` (chỉ đổi hiển thị, giữ nguyên dữ liệu).
  - Parameter `Period` kiểu StandardPeriod; `BeginOfPeriod`/`EndOfPeriod` có Expression `&Period.StartDate`/`&Period.EndDate`, đặt Availability restriction.
  - Settings: 2 variant; filter + period **Include in custom settings**, Edit mode **Quick access**; Appearance template.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo report, mở schema, viết query (ngày bán, company, customer, product, quantity, giá thực tế) với điều kiện quantity > 0.
  2. Đặt role Period cho field ngày.
  3. Thêm calculated field PricePlan, Deviation và các resources với Calculate by = Product.
  4. Khai báo parameters cho period.
  5. Tạo variant 1 (Company → Customer → Product) và variant 2 (Customer → Product, không có Company); thêm filter quick access, format, appearance.
  6. Đưa vào subsystem Sales.
  ```
  // Calculated field PricePlan (expression):  ___(Product, ___)   <- function export + ngày bán
  // Resource PriceFact:  ___(PriceFact)      Calculate by: Product
  // Resource Deviation:  ___                 <- hiệu của hai resource trung bình
  ```
- **Lỗi hay gặp:**
  - Lấy giá kế hoạch tại ngày hiện tại thay vì **ngày bán**.
  - Tính Deviation trong calculated field bằng cách tham chiếu PricePlan là không được. Phải đặt trong resource.
  - Không đặt Calculate by, khiến giá trung bình hiện cả ở Company/Customer.
  - Làm tròn ngay trong query thay vì chỉ format hiển thị, làm phép tính sai.
  - [ghi chú ngoài nguồn] Function giá được gọi cho **từng record** chi tiết (mỗi lần một query), nên dữ liệu lớn sẽ chậm. Có thể tối ưu bằng virtual table SliceLast trong query hoặc data set link.
- **Tự kiểm tra:** Post vài Sales invoice có discount (theo contract) ở những ngày có giá khác nhau. Chạy variant 1: cấp Product có Price fact/Price plan/Deviation trung bình, cấp Company/Customer chỉ có Quantity. Đổi variant 2: không còn Company. Tạo Return of goods: số liệu report không đổi. Đối chiếu một product với bảng ví dụ trong đề (142/151/−9).

### Bài tập 2 — Report "Goods movement" và tồn tối thiểu từ hệ thống ngoài

- **Đề bài (tóm tắt):** Report DCS gồm tồn đầu, nhập, xuất, tồn cuối (quantity và amount) theo kho → product, đúng ở mọi cấp grouping. Variant 2 thêm cột "Required minimum" lấy từ server common module `IntegrationWithWarehouseManagementSystem`: export function trả value table (Warehouse, Product, MinimumBalance) cho mọi kho × mọi product loại "Product", số ngẫu nhiên 1–20. Chỉ có period kiểu StandardPeriod, filter Warehouse (bằng) và Product (in list); tô màu ô tồn cuối khi thấp hơn mức tối thiểu ở cấp Product. Đưa report vào subsystem Warehouse.
- **Gợi ý 1 — Hướng đi:**
  - Query data set trên virtual table **BalanceAndTurnovers** của GoodsInWarehouses. Để balance đúng ở mọi grouping cần field có **role Period** (Recorder là Period 1, SecondPeriod là Period 2), tức là periodicity phải cho phép chọn Recorder (mục "Roles of fields").
  - Dữ liệu ngoài đi vào **object data set**, nối với query data set bằng **data set link** (luôn là left join).
  - Object data set yêu cầu tự generate report trong **OnComposeResult** và truyền external data sets (mục "Generate bằng code").
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Common module `IntegrationWithWarehouseManagementSystem` (Server): export function trả ValueTable. Lấy kho × product (product type "Product") rồi điền số bằng `New RandomNumberGenerator` / `RandomNumber(1, 20)`.
  - Schema: query data set + object data set (**Data object name** phải trùng key của external data sets), data set link theo Warehouse và Product.
  - Path nhóm field: `OpeningBalance.Quantity`, `Receipt.Amount`… và đặt title phân biệt rõ.
  - Resource MinimumBalance chỉ tính ở grouping Product.
  - Object module của report: `OnComposeResult(ResultDocument, DetailsData, StandardProcessing)`.
  - Conditional appearance ở grouping Product của variant 2: điều kiện tồn cuối quantity < MinimumBalance, BackColor sáng.
  - Parameters: chỉ để lại StandardPeriod cho user; `BeginOfPeriod`/`EndOfPeriod` lấy qua Expression và đặt Availability restriction.
- **Gợi ý 3 — Khung bài làm:**
  1. Viết function giả lập (kiểm tra số dòng = số kho × số product loại hàng hoá).
  2. Tạo report và query data set BalanceAndTurnovers, chọn thêm Recorder/SecondPeriod, gom field bằng Path.
  3. Thêm object data set, link, resource MinimumBalance.
  4. Viết OnComposeResult: tắt StandardProcessing, lấy settings, compose template, khởi tạo processor kèm external data sets, output ra ResultDocument.
  5. Tạo 2 variant, filter quick access, appearance, conditional appearance; đưa report vào subsystem Warehouse.
  ```bsl
  Procedure OnComposeResult(ResultDocument, DetailsData, StandardProcessing)
  	___ // tắt xử lý chuẩn
  	___ // settings hiện tại -> TemplateComposer.Execute(schema, settings, DetailsData)
  	___ // Structure external data sets: key = Data object name, value = function giả lập
  	___ // DataCompositionProcessor.Initialize(...) -> output processor -> Output
  EndProcedure
  ```
- **Lỗi hay gặp:**
  - Không truyền external data set cho object data set sẽ lỗi khi generate. Key phải **trùng** Data object name.
  - Không có field role Period (Recorder/SecondPeriod), khiến tồn đầu/cuối ở cấp grouping bị sai.
  - Tám field Quantity/Amount trùng title làm user không phân biệt được trong settings. Đặt title riêng hoặc dùng "Set title".
  - Tô màu ở cả cấp Warehouse. Đặt conditional appearance trong grouping Product.
  - [ghi chú ngoài nguồn] Cấu hình mẫu của khóa đặt tên cột là `RequiredBalance` thay vì `MinimumBalance` như đề. Tên nào cũng được, miễn thống nhất giữa function, object data set và resource.
- **Tự kiểm tra:** So tồn cuối kỳ trước với tồn đầu kỳ sau; tổng theo kho bằng tổng các product. Variant 2 có cột Required minimum chỉ ở dòng product, ô tồn cuối được tô khi thấp hơn. Generate nhiều lần thì số tối thiểu đổi (do ngẫu nhiên) nhưng số dòng của value table không đổi.

## Code demo của bài Theory (repo 1CJDCourse, nhánh lesson/18-theory)

### Function giả lập HRM PayrollAccrualsFromHRM và OnComposeResult của report PlannedSalary

Nguồn: nhánh lesson/18-theory — cf/Reports/PlannedSalary/Ext/ObjectModule.bsl

```bsl
	ExternalDataSets = New Structure;
	ExternalDataSets.Insert("PayrollAccrualsFromHRM", PayrollAccrualsFromHRM());
// ...
Function PayrollAccrualsFromHRM()

	Result = New ValueTable;
	Result.Columns.Add("Employee", New TypeDescription("CatalogRef.Employees"));
	Result.Columns.Add("Company", New TypeDescription("CatalogRef.Companies"));
	
	NumberQualifier = New NumberQualifiers(10, 0, AllowedSign.Nonnegative);
	Result.Columns.Add("NumberOfHours", New TypeDescription("Number", NumberQualifier));
	Result.Columns.Add("CurrentSalary", New TypeDescription("Number", NumberQualifier));
	
	Query = New Query;
	Query.Text = 
	"SELECT
	|	EmployeesSliceLast.Employee AS Employee,
	|	EmployeesSliceLast.Company AS Company
	|FROM
	|	InformationRegister.Employees.SliceLast(&CurrentDate, ) AS EmployeesSliceLast
	|WHERE
	|	EmployeesSliceLast.Works";

	CurrentDate = CurrentSessionDate();

	Query.SetParameter("CurrentDate", CurrentDate);
	Selection = Query.Execute().Select();

	// Number of days during this month up to the current date multiple 8 hours per day
	NumberOfHoursCurrentMonth = Day(CurrentDate) * 8;
	
	RandomNumberGenerator = New RandomNumberGenerator;
	While Selection.Next() Do
		
		NewRow = Result.Add();
		
		FillPropertyValues(NewRow, Selection);
		NewRow.NumberOfHours = RandomNumberGenerator.RandomNumber(1, NumberOfHoursCurrentMonth);
		NewRow.CurrentSalary = NewRow.NumberOfHours * 500;
		
	EndDo;
	
	Return Result;

EndFunction
```

- Đúng function giả lập HRM của bài: chỉ lấy nhân viên đang làm (`SliceLast` của information register Employees, điều kiện `Works`), số giờ random tối đa = số ngày tới hôm nay × 8 (`Day(CurrentDate) * 8`), lương = số giờ × 500.
- Value table được khai báo cột có kiểu (`TypeDescription`, `NumberQualifiers(10, 0, AllowedSign.Nonnegative)`) khớp với các field tự khai báo trong object data set.
- Key `"PayrollAccrualsFromHRM"` trong `ExternalDataSets` trùng **Data object name** của object data set; phần còn lại của `OnComposeResult` theo đúng chuỗi của lý thuyết (StandardProcessing = False → TemplateComposer → DataCompositionProcessor → output processor).
- `FillPropertyValues(NewRow, Selection)` chép Employee, Company từ selection sang dòng mới theo tên cột.

### Data set query của PlannedSalary, data set links và calculated field AmountToPay

Nguồn: nhánh lesson/18-theory — cf/Reports/PlannedSalary/Templates/MainDataCompositionSchema/Ext/Template.xml

Query text của data set `BonusesFinesOfEmployees`:

```bsl
SELECT
	EmployeesSliceLast.Employee AS Employee,
	EmployeesSliceLast.Company AS Company,
	EmployeesSliceLast.Position AS Position,
	EmployeesSliceLast.Department AS Department,
	ISNULL(BonusesFinesOfEmployeesTurnovers.BonusTurnover, 0) 
		- ISNULL(BonusesFinesOfEmployeesTurnovers.FineTurnover, 0) AS BonusFine
FROM
	InformationRegister.Employees.SliceLast AS EmployeesSliceLast
		LEFT JOIN AccumulationRegister.BonusesFinesOfEmployees.Turnovers AS BonusesFinesOfEmployeesTurnovers
		ON EmployeesSliceLast.Employee = BonusesFinesOfEmployeesTurnovers.Employee
			AND EmployeesSliceLast.Company = BonusesFinesOfEmployeesTurnovers.Company
WHERE
	EmployeesSliceLast.Works
```

Object data set, hai data set links và calculated field (XML của schema):

```xml
	<dataSet xsi:type="DataSetObject">
		<name>CurrentPayrollAccruals</name>
<!-- ... -->
		<dataSource>DataSource1</dataSource>
		<objectName>PayrollAccrualsFromHRM</objectName>
	</dataSet>
	<dataSetLink>
		<sourceDataSet>BonusesFinesOfEmployees</sourceDataSet>
		<destinationDataSet>CurrentPayrollAccruals</destinationDataSet>
		<sourceExpression>Employee</sourceExpression>
		<destinationExpression>Employee</destinationExpression>
	</dataSetLink>
	<dataSetLink>
		<sourceDataSet>BonusesFinesOfEmployees</sourceDataSet>
		<destinationDataSet>CurrentPayrollAccruals</destinationDataSet>
		<sourceExpression>Company</sourceExpression>
		<destinationExpression>Company</destinationExpression>
	</dataSetLink>
	<calculatedField>
		<dataPath>AmountToPay</dataPath>
		<expression>CurrentSalary + BonusFine</expression>
		<title xsi:type="v8:LocalStringType">
```

- Query chọn nhân viên đang làm từ `Employees.SliceLast` và LEFT JOIN turnovers của register `BonusesFinesOfEmployees`; `ISNULL(...)` để nhân viên không có bonus/fine vẫn có `BonusFine = 0`.
- Virtual table viết không tham số — parameters `Period`, `BeginOfPeriod`, `EndOfPeriod` do DCS tự thêm (Autofill) và có expression `CurrentSessionDate()` / `BeginOfPeriod(CurrentSessionDate(), "Month")`.
- Hai `dataSetLink` (Employee, Company): link source là data set query, link target là object data set `CurrentPayrollAccruals` (`objectName` = `PayrollAccrualsFromHRM`) — mọi link là left join.
- Calculated field `AmountToPay` = `CurrentSalary + BonusFine` (value type Number(10, 0) trong schema) dùng field của cả hai data set.

### Query của report Sales (DCS) và parameters lấy từ StandardPeriod

Nguồn: nhánh lesson/18-theory — cf/Reports/Sales/Templates/MainDataCompositionSchema/Ext/Template.xml

```bsl
SELECT
	SalesTurnovers.Product AS Product,
	SalesTurnovers.Customer AS Customer,
	SalesTurnovers.AmountTurnover AS Amount
FROM
	AccumulationRegister.Sales.Turnovers(, , Auto, ) AS SalesTurnovers
```

```xml
	<parameter>
		<name>BeginOfPeriod</name>
<!-- ... -->
		<useRestriction>true</useRestriction>
		<expression>&amp;Period.StartDate</expression>
		<availableAsField>false</availableAsField>
	</parameter>
	<parameter>
		<name>EndOfPeriod</name>
<!-- ... -->
		<useRestriction>true</useRestriction>
		<expression>&amp;Period.EndDate</expression>
		<availableAsField>false</availableAsField>
	</parameter>
	<parameter>
		<name>Period</name>
<!-- ... -->
		<valueType>
			<v8:Type>v8:StandardPeriod</v8:Type>
		</valueType>
<!-- ... -->
		<useRestriction>false</useRestriction>
		<use>Always</use>
	</parameter>
```

- Query không có TOTALS — hierarchy Customer → Product do settings của DCS tạo; periodicity `Auto` của virtual table Turnovers.
- `BeginOfPeriod`/`EndOfPeriod`: `useRestriction` = true ("Availability restriction"), expression `&Period.StartDate` / `&Period.EndDate`, `availableAsField` = false — đúng cách bài xử lý vấn đề empty date.
- Parameter `Period` kiểu `StandardPeriod`, `use` = `Always` (không có checkbox).

### Query BalanceAndTurnovers của report GoodsMovement (có SecondPeriod)

Nguồn: nhánh lesson/18-theory — cf/Reports/GoodsMovement/Templates/MainDataCompositionSchema/Ext/Template.xml

```bsl
SELECT
	GoodsInWarehousesBalanceAndTurnovers.Recorder AS Recorder,
	GoodsInWarehousesBalanceAndTurnovers.Product AS Product,
	GoodsInWarehousesBalanceAndTurnovers.Warehouse AS Warehouse,
	GoodsInWarehousesBalanceAndTurnovers.QuantityOpeningBalance AS QuantityOpeningBalance,
	GoodsInWarehousesBalanceAndTurnovers.AmountOpeningBalance AS AmountOpeningBalance,
	GoodsInWarehousesBalanceAndTurnovers.QuantityReceipt AS QuantityReceipt,
	GoodsInWarehousesBalanceAndTurnovers.AmountReceipt AS AmountReceipt,
	GoodsInWarehousesBalanceAndTurnovers.QuantityExpense AS QuantityExpense,
	GoodsInWarehousesBalanceAndTurnovers.AmountExpense AS AmountExpense,
	GoodsInWarehousesBalanceAndTurnovers.QuantityClosingBalance AS QuantityClosingBalance,
	GoodsInWarehousesBalanceAndTurnovers.AmountClosingBalance AS AmountClosingBalance,
	GoodsInWarehousesBalanceAndTurnovers.SecondPeriod AS SecondPeriod
FROM
	AccumulationRegister.GoodsInWarehouses.BalanceAndTurnovers(, , Auto, , ) AS GoodsInWarehousesBalanceAndTurnovers
```

- Periodicity `Auto` để chọn được `Recorder`; field `SecondPeriod` được chọn để platform gán role "Period, 2" (Recorder là "Period, 1") → opening/closing balance trong grouping tính đúng.
- Các field được gom bằng Path dạng `OpeningBalance.Quantity`, `Receipt.Amount`... trong schema (tab Data sets) — ví dụ "Path nhóm field" của bài.

## Video tham khảo

Video bài giảng trên YouTube có phạm vi trùng với bài này. Khi dẫn cho người học, nói "Bạn có thể tham khảo thêm về <chủ đề> của khóa tại đây: [<tên video>](link)" — không nói "khóa cũ/Junior", không dùng mã JC (mã JC trong danh sách chỉ để tra nội bộ). Quy ước đầy đủ: `references/video.md#video-junior-course`.

- [Hiển thị có điều kiện](https://www.youtube.com/watch?v=a6kSspz-wo4&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=35) (10:29) — Bài 9 — conditional appearance trên form; Bài 18 — conditional appearance trong DCS _(mã nội bộ JC-36)_
- [Báo cáo dựa trên khuôn mẫu](https://www.youtube.com/watch?v=WVqrshBBH-E&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=46) (6:34) — Bài 18 — DCS (theo mô tả của bảng gốc); nếu video nói về report điền template bằng code thì là Bài 17. Lưu ý: Tên video "báo cáo dựa trên khuôn mẫu" trùng tên Bài 17 (template-based reports) nhưng mô tả của bảng gốc là giới thiệu DCS — cần xem video để chốt. _(mã nội bộ JC-47)_
- [Khuôn mẫu và trình soạn thảo dữ liệu](https://www.youtube.com/watch?v=It9J9M69Tl8&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=47) (8:13) — Bài 18 — data composition schema, data fields, resources _(mã nội bộ JC-48)_
- [Bộ dữ liệu (data set)](https://www.youtube.com/watch?v=HLvgcgPFRq0&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=48) (5:59) — Bài 18 — data sets: Query, Object, Union _(mã nội bộ JC-49)_
- [Thiết lập (setting)](https://www.youtube.com/watch?v=rq_qf0e3is8&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=49) (8:31) — Bài 18 — settings: grouping, selected fields, filters, sorting _(mã nội bộ JC-50)_

<!-- video-qa-thuchanh:start -->

Video giải đáp tình huống thực chiến và video thực hành từng bước liên quan tới bài này (thẻ chi tiết, triệu chứng, lưu ý khi giới thiệu: `references/video.md#video-qa-thuc-chien`, `references/video.md#video-thuc-hanh`; cùng mẫu câu dẫn ở trên):

- [Báo cáo lợi nhuận theo kỳ](https://www.youtube.com/watch?v=98gDiVV8jx0&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=8) (9:16) — báo cáo DCS theo kỳ (giải đáp tình huống; Bài 18 chính) _(mã nội bộ QA-8)_
- [Lưu trữ và báo cáo kết quả học tập của sinh viên](https://www.youtube.com/watch?v=NhFE1uwi7Hw&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=3) (14:56) — chấm điểm qua chứng từ và báo cáo trung bình có tô màu (thực hành case study; Bài 18 chính) _(mã nội bộ P2-3)_
- [Xây dựng cơ chế tích điểm thưởng](https://www.youtube.com/watch?v=0aAaQQP9fXI&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=14) (23:35) — tích và trừ điểm thưởng qua register (giải đáp tình huống; Bài 18 liên quan) _(mã nội bộ QA-14)_
- [Extension (Phần mở rộng) trong 1C:Enterprise](https://www.youtube.com/watch?v=T_DEaA1p_bA&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=22) (6:33) — thêm báo cáo bằng extension mà không sửa cấu hình gốc (giải đáp tình huống; Bài 18 liên quan) _(mã nội bộ QA-22)_
- [Thực hiện tính toán đơn giản với SQL trong 1C](https://www.youtube.com/watch?v=dP21dfHxkCo&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=23) (2:59) — tính toán ngay trong query (giải đáp tình huống; Bài 18 liên quan) _(mã nội bộ QA-23)_
- [Lưu trữ thông tin sinh viên và môn học](https://www.youtube.com/watch?v=UGXVLOKRaGw&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=4) (12:19) — Catalog, phân cấp và tabular section (thực hành case study; Bài 18 liên quan) _(mã nội bộ P1-3)_
- [Lưu trữ thông tin các chuyến du lịch](https://www.youtube.com/watch?v=PwqP4GODNrY&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=6) (13:15) — tạo chứng từ trên cơ sở chứng từ khác (Input on basis) (thực hành case study; Bài 18 liên quan) _(mã nội bộ P1-5)_
- [Ghi nhận thay đổi tỷ giá hối đoái](https://www.youtube.com/watch?v=9_m7XqHPZlA&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=1) (9:04) — information register theo ngày và biểu đồ (thực hành case study; Bài 18 liên quan) _(mã nội bộ P2-1)_
- [Hệ thống cho thuê xe điện](https://www.youtube.com/watch?v=wWGXT2KSul8&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=4) (10:40) — một chứng từ ghi vào hai register (thực hành case study; Bài 18 liên quan) _(mã nội bộ P2-4)_
- [Hạch toán hàng hóa - Bài toán đơn giản nhất](https://www.youtube.com/watch?v=SwgfC-uA6Eg&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=10) (16:55) — nhập – xuất – tồn và chặn âm kho (thực hành case study; Bài 18 liên quan) _(mã nội bộ P2-10)_

<!-- video-qa-thuchanh:end -->


---

# § bai-19

# Bài 19 — Data processors (built-in & external)

## Khái niệm chính

### Basics
- **Data processor**: configuration object riêng để thực hiện các thao tác lập trình — phân tích dữ liệu, xử lý documents, upload/download thông tin, tính toán phức tạp, thao tác quản trị infobase...
- Khác đa số metadata objects: **không gắn với bảng database**, **không lưu thông tin** trong DB; chỉ thực hiện chức năng developer cài vào — công cụ cho user.

### Types of data processors
- Theo cách lưu:
  1. **Built-in data processors** — nằm trong configuration.
  2. **External data processors** — lưu riêng thành file, kết nối với bất kỳ infobase nào mà **không đổi configuration**.
- Theo mục đích:
  - **Service** — quản trị DB hoặc gọi từ subsystem khác (tạo/xoá dữ liệu, đổi password user...).
  - **Additional interface solutions** — tăng usability (user desktop, configuration overview…).
  - **Data processing** — thay đổi hàng loạt (đổi giá sản phẩm, nhập opening balances, month closing).
  - **Data exchange** — import/export (Excel, XML, JSON).

### Ví dụ: Import prices from Excel
- Chuẩn bị: catalog **"PriceTypes"** trong subsystem mới **"Prices"** (con của Sales); independent information register **"ProductPrices"**, periodicity **Day**: Dimensions **PriceType**, **Product**; Resources **Price**. Hỗ trợ nhiều loại giá (wholesale, retail, partner).
- Data processor **"Import prices from Excel"** trong subsystem "Prices"; form có attribute **PriceType** kiểu `CatalogRef.PriceTypes`, bắt buộc điền.
- **Spreadsheet document trên form** dùng cho 2 mục đích:
  1. Đọc nội dung file và ghi dữ liệu ra file OpenOffice/Excel: **.ods, .xls, .xlsx, .xlsm**.
  2. Cho user xem nội dung file trước khi nạp.
  - Bài chỉ hỗ trợ Excel. Attribute **SpreadsheetDocument**, tắt title, **ReadOnly** = True.
- Attribute **PathToFile** kiểu String độ dài **200**, bắt buộc; field bật choice và clear buttons.
- Handler choice: **FileDialog** mode **Open**, đặt title, filter 3 nhóm:
  - chung cho 3 extension;
  - **Excel 1997-2003** cho .xls;
  - **Excel** cho .xlsx, .xlsm.
  - Gọi **`Show`** với callback handler description.
  - Filter phân tách bằng **"|"**; ký hiệu "|" cũng dùng để xuống dòng trong string value → khi viết nhiều dòng sẽ thấy **"||"** đầu dòng mới (cái đầu để tiếp tục chuỗi, cái thứ hai là separator). Viết một dòng thì chỉ một "|".
- Callback: kiểm tra **SelectedFiles** khác **Undefined** (Undefined khi đóng cửa sổ không chọn). Nếu chọn → kiểu **Array** chứa full path (nhiều file nếu property **"Multiselection"** = True); lấy phần tử đầu.
- Đọc file: method **`Read(FullPathToFile)`** của SpreadsheetDocument, qua command **"Read"** — handler client + procedure server (vì **`Read()` không có trên client**).
- **MessageToUser**: hiển thị cùng loại thông báo như platform khi fill check; tập trung vào field trong property **"Field"**, cho phép chuyển giữa các field bằng mũi tên (nếu nhiều field); ngoài message panel còn có pop-up chỉ vào field.
- Command **"LoadPrices"** (client handler + server procedure), nút làm **default button**:
  - Kiểm tra bắt buộc bằng **`CheckFilling()`** (platform đảm nhận kiểm tra mọi attribute bắt buộc).
  - Kích thước bảng: properties **TableWidth**, **TableHeight**. Nếu số dòng hoặc cột **< 2** → báo lỗi và dừng (cần ít nhất cột Product, Price; dòng 1 là header).
  - Cách xác định cột: (a) header theo tên định sẵn (không phân biệt hoa thường, ví dụ "price"); (b) user nhập số cột (ProductColumnNumber, PriceColumnNumber) — khi đó kiểm tra cột có tồn tại. Bài chọn (a) vì ít thao tác cho user (cột Excel đánh chữ, dễ nhập sai), đổi lại yêu cầu format file chặt hơn.
  - Biến **ColumnNumbers** kiểu **Structure**: key = tên cột bắt buộc, value = số cột.
  - Lặp cột 1..số cột, lấy ô bằng method **`Area()`** (truyền vùng ô như `GetArea()`), ví dụ `"R1C" + i`; đọc property **Text**, bỏ ký tự thừa hai bên bằng **`TrimAll()`**.
  - Tìm tên trong ColumnNumbers: có → gán số cột `i`; không → báo user cột đó sẽ bị bỏ qua.
  - Sau vòng lặp kiểm tra mọi property đã điền; thiếu → báo và set biến **ColumnsError** = True; dừng **sau** vòng lặp để báo **tất cả** cột thiếu cùng lúc.
  - Lặp dòng 2..số dòng; tìm product bằng **`FindByDescription()`** với **exact match** (tránh "Teapot" khớp "Electric Teapot", "Aluminum Teapot"...). Không tìm thấy → báo kèm description; tìm thấy → tạo record bằng **record manager** của register giá. Ngày lấy **một lần trước vòng lặp** để mọi record cùng ngày.
  - `Write` của record manager với **Replace = True**: trùng ngày + product + price type → ghi đè. Muốn user chọn → attribute riêng truyền vào tham số Write.
- Cải tiến: attribute **Period** (kiểu date) thay ngày hiện tại; khởi tạo trong **OnCreateAtServer** bằng ngày hiện tại. Đặt Period và PriceType trong một group.
- Nút **"Test"** phía trên cây form elements trong Designer: xem form ở các kích thước cửa sổ khác nhau.
- Field "Price type" giãn quá rộng → tắt **"AutoMaxWidth"** rồi đặt **"MaxWidth"**: độ rộng tối đa; form không đủ chỗ thì tự thu nhỏ.
- Kết quả kiểm thử: thiếu Price type → lỗi; dòng có product "Test" → "Unable to find a product by description Test"; các dòng khác nạp thành công.
- Gợi ý cải tiến (tự luyện): báo số giá nạp thành công; đọc price type từ file hoặc kết hợp với lựa chọn của user (radio buttons); xử lý file bị xoá/move/rename giữa lúc chọn và đọc.

### Làm việc với file ở client-server mode
- Client và server thường ở máy khác nhau → file theo **local path** (ví dụ `D:\Work`) trên máy client không truy cập được từ server; network path (ví dụ `\\Accountant-computer\Work`) server cũng có thể không có quyền. Đọc file trên server → lỗi vì server tìm trong file system của nó.
- Giải pháp: đưa binary data file vào **temporary storage**, gửi địa chỉ lên server; server tạo **temp file name**, ghi binary data ra temp file, đọc vào spreadsheet document, rồi **xoá temp file**.
- Tránh tách rời chọn file và đọc file (file có thể đổi giữa hai bước): xoá field PathToFile, chuyển code từ handler **"StartChoice"** sang command handler **"Read"**, đổi tên thành **"ReadFile"**.
- Sau khi có full path → **`BeginPutFileToServer`**: truyền callback handler, path file, **unique form identifier** (khi form đóng, platform tự xoá temporary storage gắn identifier này).
- Callback: kiểm tra tham số đầu **PlacedFileDescription** khác **Undefined** (Undefined = đặt file thất bại); gọi server procedure với địa chỉ trong temporary storage và **extension** file (cần để temp file ở format Excel) — lấy từ **`FileRef.Extension`** của PlacedFileDescription.
- Server: lấy binary data từ temporary storage → **`GetTempFileName()`** → ghi binary data ra file → đọc vào spreadsheet document → xoá file bằng **`DeleteFiles()`**, nên đặt trong **Try** (lỗi xoá → xử lý và ghi **event log**). File có thể 5-10-20 MB, vài trăm file sẽ chiếm đáng kể dung lượng.
- **Information**: platform tự xoá temp files cuối session, nhưng ở client-server, temp file tạo trên server thuộc session của **1C server**, không phải client session → có thể tích tụ nhiều ngày/tuần. Syntax assistant của `GetTempFileName()` khuyến nghị tự xoá.

### External data processors
- File có cấu trúc riêng, extension **.epf**, tạo trong Designer; làm được gần như mọi thứ như built-in, **trừ manager module** (chỉ object trong configuration mới có object manager).
- Tạo: menu **File → "New"** hoặc nút **"New Document"** trên panel "Configuration" → chọn **"External data processor"** → editor mở ra (chưa lưu); lưu lần đầu → chọn tên và path file.
- Ví dụ use case: thêm attribute bắt buộc vào catalog/document làm hỏng dữ liệu cũ (document cũ không post được vì attribute bắt buộc chưa điền) → developer phải điền dữ liệu hiện có. Cơ chế **update handlers** của **standard subsystem library (SSL)** (học sau); khi không có SSL hoặc lý do khác → dùng external data processor, chạy trên nhiều infobase có configuration tương tự, kể cả của khách hàng khác, không cần đưa vào configuration.
- Ví dụ: thêm attribute **"PriceType"** (kiểu catalog "PriceTypes") bắt buộc vào document Sales invoice. Phương án 1: cutoff date + 2 price types (trước/sau ngày) + nút **"Fill price type"**. Phương án linh hoạt (được chọn): chọn period (2 field date hoặc 1 field **StandardPeriod**) + một field PriceType → điền dần theo từng khoảng thời gian.
- Server procedure: query mọi document trong period **có filter PriceType chưa điền** (tránh ghi đè document user đã điền sau khi update configuration). Với mỗi document: lấy object, điền price type, write; lỗi → ghi chi tiết vào **event log**. Biến **NumberProcessed**, **NumberUnprocessed** khởi tạo 0, tăng theo kết quả; cuối cùng nếu thay đổi → thông báo.
- Chạy: lưu data processor (không cần lưu configuration hay restart debugging), vào Enterprise mode, **mở data processor từ file**.
- Platform cảnh báo chỉ mở file từ nguồn tin cậy (có thể thực hiện thao tác nguy hiểm). SSL có **role riêng** cho quyền mở external reports và data processors; user không có role không mở được từ file. (Reports cũng có thể là external.)
- Chuyển đổi trong configuration tree (right-click):
  - **"Insert external report or data processor"** — thêm external vào configuration (right-click branch).
  - **"Save as external report or data processor"** — lưu built-in thành external.
  - **"Replace with external report or data processor"** — nạp built-in từ external.
  - Nút compare and merge với external report/data processor — chọn thủ công từng phần, kết quả thay thế built-in object.
- Lưu built-in thành external → **code trong manager module bị mất**.

## Cú pháp & ví dụ code

Lấy ô header cột thứ i:
```bsl
"R1C" + i
```

Tạo binary data / các method được nêu trong bài (không có đoạn code văn bản đầy đủ):
```bsl
Read(FullPathToFile)
CheckFilling()
Area()
TrimAll()
FindByDescription()
BeginPutFileToServer
GetTempFileName()
DeleteFiles()
```

[ghi chú ngoài nguồn] Các đoạn code của bài (FileDialog với filter, callback, ReadAtServer, LoadPrices, BeginPutFileToServer, external data processor điền PriceType) chỉ có dạng ảnh trong tài liệu nên không chép lại. Phiên bản demo của bài (ReadFile, filter có .xlsm, LoadPrices ghi register độc lập bằng record manager) → xem mục Code demo của bài Theory (nhánh lesson/19-theory). (Riêng external data processor điền PriceType không có trong nhánh lesson/19-theory — nhánh chỉ có attribute PriceType bắt buộc của Sales invoice — nên vẫn chưa có code.)

## Thuộc tính/thiết lập quan trọng trong Designer
- Information register "ProductPrices": independent, periodicity **Day**; Dimensions PriceType, Product; Resource Price.
- Form attributes: **PriceType** (`CatalogRef.PriceTypes`, bắt buộc), **SpreadsheetDocument** (ReadOnly = True, title tắt), **PathToFile** (String 200, bắt buộc, choice + clear buttons), **Period** (Date).
- FileDialog: mode **Open**, **Title**, **Filter**, **Multiselection**.
- MessageToUser: property **Field**.
- SpreadsheetDocument: **TableWidth**, **TableHeight**; cell property **Text**.
- Command button: **DefaultButton**.
- Form field: **AutoMaxWidth**, **MaxWidth**; nút **Test** trong form editor.
- External data processor: file **.epf**; File → New / New Document → External data processor.
- Configuration tree: Insert / Save as / Replace with external report or data processor; compare and merge.

## Lỗi thường gặp / lưu ý
- `Read()` của SpreadsheetDocument không có trên client → gọi ở server.
- SelectedFiles = Undefined khi user huỷ chọn file → phải kiểm tra.
- Bảng < 2 dòng hoặc < 2 cột → không có dữ liệu hợp lệ, báo lỗi.
- Báo tất cả cột thiếu một lần (dùng cờ ColumnsError, dừng sau vòng lặp).
- `FindByDescription()` không exact match có thể tìm nhầm sản phẩm tương tự.
- Form trong Designer trông khác Enterprise mode → dùng nút "Test", MaxWidth.
- File có thể bị xoá/move/rename giữa lúc chọn và đọc → gộp chọn + đọc vào một command.
- Client-server: server không đọc được file theo local path của client (và có thể không có quyền với network path) → dùng `BeginPutFileToServer` + temporary storage + temp file.
- PlacedFileDescription = Undefined → đặt file thất bại.
- Tự xoá temp file (`DeleteFiles()` trong Try) — ở client-server temp file trên server có thể tích tụ nhiều ngày/tuần.
- Chỉ mở external data processor từ nguồn tin cậy; cần role phù hợp (SSL).
- External data processor không có manager module; save built-in thành external làm mất code manager module.
- Khi điền hàng loạt bằng external processor, chỉ chọn document chưa điền để không ghi đè dữ liệu user đã sửa.

## Điểm cần nhớ
- Data processor không lưu dữ liệu trong DB; chỉ thực thi thao tác. Hai loại: built-in và external (.epf).
- 4 mục đích: Service, Additional interface solutions, Data processing, Data exchange.
- Import Excel: FileDialog (filter "|") → SpreadsheetDocument.`Read()` trên server → duyệt TableWidth/TableHeight, `Area("R1C"+i).Text` → tìm cột bằng Structure → `FindByDescription` exact → record manager `Write(True)`.
- MessageToUser với property Field để chỉ vào field lỗi; `CheckFilling()` để kiểm tra attribute bắt buộc.
- Client-server: `BeginPutFileToServer` (kèm form UUID) → server `GetTempFileName()` → ghi, đọc → `DeleteFiles()` trong Try.
- External data processor: tạo từ File → New, chạy bằng cách mở file trong Enterprise mode, không cần update configuration; dùng cho điền dữ liệu khi thêm attribute bắt buộc (khi không có SSL update handlers).
- Insert / Save as / Replace with external report or data processor; external không có manager module.

## Thẻ gợi ý bài thực hành (Practice 19)

19. Practice chỉ có một bài lớn. Thẻ dưới đây chia nó thành các phần nhỏ theo đúng các yêu cầu của đề.

### Bài tập 1 — Data processor nạp giá từ Excel vào document PriceSetup

- **Đề bài (tóm tắt):** Data processor đọc file .xls/.xlsx gồm 3 cột Date – Product – Price. Vì register giá **subordinate to recorder**, giá được nạp vào document `PriceSetup`, mỗi ngày khác nhau một document, ghi ở chế độ **Posting**. Product tìm theo description exact match (sau khi bỏ ký tự thừa); không tìm thấy thì bỏ qua và báo. Mỗi ngày chỉ có một document **đã post** được nạp từ file: nếu đã có thì chỉ thêm product mới hoặc sửa giá khi khác. Không có thay đổi thì không ghi. Lỗi khi ghi được ghi vào event log. Có 3 loại thông báo: created / updated / not loaded.
- **Gợi ý 1 — Hướng đi:**
  - Phần đọc file giống bài lý thuyết (mục "Ví dụ: Import prices from Excel" và "Làm việc với file ở client-server mode"): FileDialog → `BeginPutFileToServer` → server dùng temp file → `SpreadsheetDocument.Read()` → `DeleteFiles()` trong Try.
  - Khác bài lý thuyết: register không ghi trực tiếp được, nên phải tạo/sửa **document**. Tip của đề: đọc hết bảng vào **collection trung gian** trước, lấy danh sách ngày, query tất cả document đã có trong **một** query (không query trong vòng lặp).
  - Phân biệt document tự động bằng một attribute riêng do bạn thiết kế, đồng thời hiện điều này trên form document.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Form của data processor: attribute SpreadsheetDocument (ReadOnly), command đọc file và command nạp giá (DefaultButton).
  - Client: `New FileDialog(FileDialogMode.Open)` với `Filter` cho .xls và .xlsx, `Show(CallbackDescription)`; callback Export kiểm tra `SelectedFiles`, gọi `BeginPutFileToServer(..., UUID)`; callback thứ hai kiểm tra `PlacedFileDescription` và lấy địa chỉ cùng extension.
  - Server: `GetFromTempStorage`, `GetTempFileName(<extension>)`, `Read(..., SpreadsheetDocumentValuesReadingMode.Value)` để đọc **Value** của ô Date, `DeleteFiles` + `WriteLogEvent`.
  - Đọc bảng: `TableWidth`/`TableHeight`, `Area("R1C" + i).Text`, Structure tên cột → số cột, `TrimAll()`, `Catalogs.Products.FindByDescription(<tên>, True)`.
  - Collection trung gian: ValueTable (Date, Product, Price) + mảng ngày duy nhất.
  - Function `&AtServerNoContext` query `Document.PriceSetup` theo danh sách ngày (`BEGINOFPERIOD(..., DAY) IN (&Dates)`), lọc theo attribute đánh dấu "nạp từ file".
  - Document PriceSetup: attribute Boolean đánh dấu (ví dụ `LoadedFromFile`); `OnCreateAtServer` của form hiển thị dấu hiệu cho user. Ghi bằng `Write(DocumentWriteMode.Posting)` trong Try.
- **Gợi ý 3 — Khung bài làm:**
  1. Đọc file (client → temporary storage → server temp file → spreadsheet document → xoá temp file).
  2. Kiểm tra kích thước bảng (ít nhất 2 dòng, 3 cột); xác định cột theo tiêu đề và báo **tất cả** cột thiếu một lần.
  3. Duyệt dòng 2..N: đọc Date (Value), Product (Text + TrimAll), Price; tìm product; đưa vào ValueTable hoặc báo không tìm thấy.
  4. Một query lấy document tự động đã có cho mọi ngày.
  5. Với mỗi ngày: lấy object có sẵn hoặc tạo mới (đặt Date và cờ đánh dấu); duyệt các dòng của ngày đó: thêm product mới, sửa giá khi khác, giống thì bỏ qua; ghi nhận "có thay đổi".
  6. Có thay đổi thì ghi Posting trong Try và báo created/updated (in ref để có presentation); lỗi thì WriteLogEvent. Không có thay đổi thì báo "Prices for … were not loaded".
  ```bsl
  For Each Date In ___ Do
  	___ // tìm document có sẵn cho ngày này -> GetObject() / CreateDocument() + cờ "từ file"
  	For Each Row In ___ Do      // các dòng của ngày này trong collection trung gian
  		___ // chưa có product -> thêm; có nhưng giá khác -> sửa; giống -> Continue
  	EndDo;
  	If ___ Then                  // có thay đổi
  		___ // Try: Write(Posting) + thông báo created/updated; Except: ghi event log
  	Else
  		___ // thông báo "Prices for <ngày> were not loaded"
  	EndIf;
  EndDo;
  ```
- **Lỗi hay gặp:**
  - Đọc file trực tiếp theo local path trên server. Ở client-server server không thấy file đó, nên phải đi qua temporary storage + temp file.
  - Query document **trong vòng lặp** theo từng ngày, trái với tip của đề.
  - Đọc ngày bằng `.Text` rồi tự chuyển chuỗi thành ngày (dễ lỗi format). Đặt format ô là Date và đọc `.Value`.
  - Ghi lại document kể cả khi không có thay đổi, trái với yêu cầu "không thay đổi thì không ghi".
  - [ghi chú ngoài nguồn] Lời giải tham khảo của khóa có hai chỗ hở nên tránh: (1) query document cũ chưa lọc `Posted`/`DeletionMark`, trong khi đề nói "một document **đã post** mỗi ngày"; (2) ngày mà mọi product đều không tìm thấy không được báo "not loaded" nếu file còn ngày hợp lệ khác. Hãy xử lý cả hai trường hợp.
  - Quên xoá temp file hoặc không đặt `DeleteFiles` trong Try.
- **Tự kiểm tra:** Dùng đúng bảng trong đề và đối chiếu từng dòng với cột Result: lần nạp đầu tạo 3 document (02.02 có 2 product, 19.02, 03.03). Nạp lại cùng file: không có document nào bị ghi lại, chỉ có thông báo "not loaded". Sửa một giá trong file rồi nạp: document của ngày đó báo "updated". Mở document tự động: thấy dấu hiệu "tạo từ data processor". Kiểm tra register giá (Register records của PriceSetup) có giá mới. Cố tình gây lỗi ghi (ví dụ khoá document) rồi xem Event log.

## Code demo của bài Theory (repo 1CJDCourse, nhánh lesson/19-theory)

### Phiên bản demo của LoadPrices: CheckFilling, Period từ OnCreateAtServer, ghi register giá bằng record manager

Nguồn: nhánh lesson/19-theory — cf/DataProcessors/ImportPricesFromExcel/Forms/Form/Ext/Form/Module.bsl

```bsl
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	Period = CurrentSessionDate();
EndProcedure
// ...
&AtServer
Procedure LoadPricesAtServer()
	
	If Not CheckFilling() Then
		Return;
	EndIf;
	
	// TableWidth contains number of table columns.
	ColumnsCount = SpreadsheetDocument.TableWidth; 
	// TableHeight contains number of table rows.
	RowsCount 	 = SpreadsheetDocument.TableHeight;
	
	If ColumnsCount < 2 Or RowsCount < 2 Then
		Message("Table should contain at least 2 rows (1 is for column titles) and 2 columns");
		Return;
	EndIf;
	
	ColumnNumbers = New Structure;
	ColumnNumbers.Insert("Product");
	ColumnNumbers.Insert("Price");
	
// ...
	For i = 2 To RowsCount Do
		ProductDescription 	= TrimAll(SpreadsheetDocument.Area("R" + i + "C" + ColumnNumbers.Product).Text);
		ProductPrice 		= TrimAll(SpreadsheetDocument.Area("R" + i + "C" + ColumnNumbers.Price).Text);
		
		Product = Catalogs.Products.FindByDescription(ProductDescription, True);
		If ValueIsFilled(Product) Then
			NewRecord = InformationRegisters.ProductPrices.CreateRecordManager();
			
			NewRecord.Period 	= Period;
			NewRecord.Product 	= Product;
			NewRecord.PriceType = PriceType;
			NewRecord.Price 	= ProductPrice;
			
			NewRecord.Write(True);
		Else
			Message(StrTemplate("Unable to find a product by description %1", ProductDescription));
		EndIf;
		
	EndDo;
	
EndProcedure
```

- Đúng phiên bản của bài Theory (bài Practice 19 khác: đọc thêm cột Date và tạo document PriceSetup — xem Thẻ gợi ý bài thực hành): file chỉ cần 2 cột Product, Price; ngày lấy từ form attribute `Period`, khởi tạo trong `OnCreateAtServer` bằng `CurrentSessionDate()`.
- `CheckFilling()` ở đầu procedure → platform tự kiểm tra mọi attribute bắt buộc của form (PriceType); thiếu thì dừng.
- Ở đây register `ProductPrices` là **independent** → ghi thẳng bằng `InformationRegisters.ProductPrices.CreateRecordManager()`, `Write(True)` (Replace) ghi đè record trùng Period + Product + PriceType.
- `FindByDescription(ProductDescription, True)` — exact match; không tìm thấy thì báo "Unable to find a product by description ..." (đúng kết quả kiểm thử với dòng "Test" trong bài).

### Filter của FileDialog trong bài Theory (thêm .xlsm) và command ReadFile

Nguồn: nhánh lesson/19-theory — cf/DataProcessors/ImportPricesFromExcel/Forms/Form/Ext/Form/Module.bsl

```bsl
&AtClient
Procedure ReadFile(Command)
	
	Dialog = New FileDialog(FileDialogMode.Open);
	Dialog.Title = "Choose a file with prices for import";
	Dialog.Filter = 
		"Tables (*.xls,*.xlsx,*.xlsm)|*.xls;*.xlsx;*.xlsm;
		||Microsoft Excel 1997-2003 (*.xls)|*.xls
		||Microsoft Excel (*.xlsx,*.xlsm)|*.xlsx;*.xlsm";

	Dialog.Show(New CallbackDescription("FileFinishChoice", ThisObject));

EndProcedure
```

- Command đã đổi tên thành `ReadFile` như bài mô tả (gộp chọn file + đọc file, bỏ field PathToFile/StartChoice).
- Filter 3 nhóm đúng như lý thuyết: chung cho .xls/.xlsx/.xlsm, "Excel 1997-2003" cho .xls, "Excel" cho .xlsx/.xlsm.
- Phần còn lại (`FileFinishChoice` → `BeginPutFileToServer` → `ReadFinishPuttingFile` → `ReadOnServer` với temp file) cũng có trong cùng module của nhánh, theo đúng chuỗi lý thuyết mô tả (`BeginPutFileToServer` kèm UUID của form, `GetTempFileName`, `DeleteFiles` trong Try).

### Attribute PriceType bắt buộc trong document SalesInvoice (bối cảnh của external data processor)

Nguồn: nhánh lesson/19-theory — cf/Documents/SalesInvoice.xml

```xml
			<Attribute uuid="46bbe897-139e-4ada-a90f-fae6e982909b">
				<Properties>
					<Name>PriceType</Name>
					<Synonym>
						<v8:item>
							<v8:lang>en</v8:lang>
							<v8:content>Price type</v8:content>
						</v8:item>
					</Synonym>
					<Comment/>
					<Type>
						<v8:Type>cfg:CatalogRef.PriceTypes</v8:Type>
					</Type>
					<PasswordMode>false</PasswordMode>
<!-- ... -->
					<FillChecking>ShowError</FillChecking>
```

- Nhánh lesson/19-theory có attribute `PriceType` (kiểu `CatalogRef.PriceTypes`, `FillChecking` = `ShowError`) — đúng thay đổi làm document cũ không post được, lý do cần external data processor trong bài.
- Bản thân external data processor (.epf) điền PriceType theo period **không** có trong nhánh (repo chỉ chứa dump configuration cf/, external data processor là file riêng).

## Video tham khảo

Video bài giảng trên YouTube có phạm vi trùng với bài này. Khi dẫn cho người học, nói "Bạn có thể tham khảo thêm về <chủ đề> của khóa tại đây: [<tên video>](link)" — không nói "khóa cũ/Junior", không dùng mã JC (mã JC trong danh sách chỉ để tra nội bộ). Quy ước đầy đủ: `references/video.md#video-junior-course`.

Không có video bài giảng tương ứng — chỉ dẫn tài liệu Theory/Practice của bài.

<!-- video-qa-thuchanh:start -->

Video giải đáp tình huống thực chiến và video thực hành từng bước liên quan tới bài này (thẻ chi tiết, triệu chứng, lưu ý khi giới thiệu: `references/video.md#video-qa-thuc-chien`, `references/video.md#video-thuc-hanh`; cùng mẫu câu dẫn ở trên):

- [Kết nhập file excel vào danh mục sản phẩm](https://www.youtube.com/watch?v=DlXBXRzBJGw&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=13) (38:42) — nhập dữ liệu từ Excel (giải đáp tình huống; Bài 19 chính) _(mã nội bộ QA-13)_
- [Lưu bộ xử lý ngoài](https://www.youtube.com/watch?v=DTRivJSbAoI&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=15) (1:40) — bộ xử lý ngoài (.epf) (giải đáp tình huống; Bài 19 chính) _(mã nội bộ QA-15)_
- [Tạo chức năng sửa password với vai trò người dùng](https://www.youtube.com/watch?v=taKIdmcCmIQ&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=9) (26:39) — cho người dùng tự đổi mật khẩu (giải đáp tình huống; Bài 19 liên quan) _(mã nội bộ QA-9)_

<!-- video-qa-thuchanh:end -->


---

# § bai-20

# Bài 20 — Roles and access rights (Vai trò và quyền truy cập)

## Khái niệm chính

### Access rights
- Nguyên tắc của 1C:Enterprise: theo mặc định, **mọi thứ không được cho phép đều bị cấm**.
- Chỉ có một thực thể chịu trách nhiệm cho việc user truy cập chức năng/dữ liệu: **Access right**. Đây là phần tử duy nhất điều khiển truy cập tới một chế độ làm việc, dữ liệu catalog, attribute, v.v.
- Số loại access right do platform định sẵn. Có 2 nhóm chính:
  - **General system-wide access rights** (quyền toàn hệ thống tới cơ chế platform): truy cập các chế độ làm việc của platform (Administration, Exclusive Mode, Thin Client, Interactive opening of external reports...).
  - **Object access rights**: làm việc với các configuration object. Số lượng phụ thuộc loại object — ví dụ catalog có 16 loại quyền (Read, Add, Change, Delete...), information register chỉ có 5 loại. Các quyền này đặt ở mức toàn bộ catalog. Có thể giới hạn ở mức attribute, nhưng khi đó chỉ một phần loại quyền khả dụng (với catalog là **View** và **Edit**).
- Object access rights chia 2 loại:
  - **Basic (non-interactive)**: luôn được kiểm tra bất kể cách truy cập object.
  - **Interactive**: chỉ kiểm tra khi thực hiện thao tác tương tác (ví dụ "Set deletion mark", "Post", "Clear posting").
- Kiểm tra interactive rights **có thể bị vượt qua** (ví dụ tự tạo form và thay standard commands bằng command riêng); kiểm tra non-interactive rights **không thể bị vượt qua** trong bất kỳ trường hợp nào.
- Các basic access rights bảo vệ chức năng nền tảng của object: **"Insert", "Read", "Update", "Delete"**. Để xây dựng giải pháp an toàn, chỉ cần quản lý 4 quyền này.
- Có thể kiểm tra quyền từ built-in language. Khi thêm command vào form, developer phải tự lo kiểm tra interactive rights tương ứng.
- Một infobase user có thể có interactive và non-interactive rights khác nhau trên cùng object (ví dụ "Posting" được phép nhưng "Interactive posting" bị cấm).
- Khi thực hiện thao tác không được phép: hiện thông báo lỗi **"Access violation!"** và mọi transaction đã bắt đầu bị hủy.
- Việc kiểm tra basic và interactive rights được dùng bởi form extension, table field extension, input field extension (form extension xác định bởi main attribute; table field/input field extension xác định bởi kiểu dữ liệu được sửa). Do đó nếu không có quyền **"View"**, list form hay object form sẽ không mở và hiện thông báo vi phạm quyền.

### Ví dụ kiểm tra quyền bởi extension (với document)
- Mở document form: kiểm tra "View"; nếu là form object mới → kiểm tra "Interactive insert", nếu không → "Edit". Khi write có posting → kiểm tra "Interactive posting", "Interactive undo posting" hoặc "Interactive posting regular" tùy chế độ write.
- Table field extension của document journal (khi journal là main attribute của form): kiểm tra có "View" cho ít nhất một document trong journal. Khi post từ journal → "Interactive posting"/"Interactive undo posting"/"Interactive posting regular". Khi xóa → "Interactive delete". Khi đặt/bỏ deletion mark → "Interactive mark for deletion"/"Interactive unmark for deletion". Khi thêm document mới (sau khi chọn loại) → "Interactive insert".
- Document input field chỉ kiểm tra quyền **"String input"**.

### Related rights (quyền liên quan)
- Một số quyền phụ thuộc nhau. Ví dụ: không thể cho phép "Update" mà không cấp "Read".
- Interactive rights phụ thuộc trực tiếp vào non-interactive tương ứng ("Interactive delete" phụ thuộc "Delete"). Khi cấu hình: bật interactive right → non-interactive tương ứng tự bật; bỏ non-interactive → interactive tương ứng tự bị reset. Chỉ có thể đặt non-interactive và bỏ interactive, không thể ngược lại.
- Chuỗi phụ thuộc phức tạp: với "Document", "Interactive undo posting" phụ thuộc đồng thời "Undo posting" và "Edit"; "Undo posting" phụ thuộc "Update"; "Update" phụ thuộc "Read".
- Quyền then chốt là **"Read"** — nếu thiếu, mọi quyền khác trên object tự động mất.

### Bảng access rights

| Access right | Mô tả |
| --- | --- |
| ActiveUsers | Xem danh sách active users. Có thể dùng khi tổ chức "guest login". |
| Administration | Thao tác quản trị như duy trì danh sách user hay mở configuration. |
| Automation | Dùng 1C:Enterprise ở automation mode. |
| Delete | Cho phép xóa |
| Edit | Cho phép sửa object (interactive) |
| EventLog | Xem event log và work protocols |
| ExclusiveMode | Chuyển sang exclusive mode khi làm việc ở 1C:Enterprise mode. |
| ExternalConnection | Dùng 1C:Enterprise qua COM connection. |
| Insert | Thêm object loại này. Kiểm tra ở mức object và mức DB. |
| InteractiveDelete | Xóa trực tiếp (interactive) |
| InteractiveDeleteMarked | Xóa interactive các object đã đánh dấu |
| InteractiveInsert | Thêm interactive object loại này |
| InteractiveMarkForDeletion | Đặt deletion mark interactive |
| InteractiveOpenExtDataProcessors | Mở external data processors bằng standard menu commands |
| InteractiveOpenExtReports | Mở external reports bằng standard menu commands |
| InteractivePosting | Post interactive document loại này |
| InteractivePostingRegular | Post interactive (bằng standard form commands) document ở regular (non-operational) mode |
| InteractiveUndoPosting | Hủy posting interactive |
| InteractiveUnmarkForDeletion | Bỏ deletion mark interactive |
| Posting | Post document |
| Read | Đọc dữ liệu từ infobase |
| StringInput | Cho phép dùng line input mode cho các object. |
| TotalsControl | Quản lý totals của accounting registers và accumulation registers — đặt kỳ tính totals và recalculation totals |
| UndoPosting | Hủy posting document |
| Update | Sửa object loại này. Kiểm tra ở mức object và mức DB. |
| Use | Dùng data processor, report, subsystem |
| View | Xem object (ví dụ trong list) |

### Access rights khi làm việc với form
- Quyền được cấu hình cho application objects. **Quyền mở form không được cấu hình, ngoại trừ common forms.**
- Khi mở form, kiểm tra quyền trên object là **main attribute** của form. Quyền trên object mà form trực thuộc trong cây metadata **không** được tính.
- Hệ quả: form của data processor không có main attribute → quyền trên data processor không ảnh hưởng việc mở form. Form trực thuộc catalog A nhưng main attribute là object catalog B → tính quyền trên catalog B.

### Roles
- **Role** là lớp trung gian giữa infobase users và access rights; mỗi role gom một tập quyền mà việc cấp chỉ có ý nghĩa khi đi cùng nhau (ví dụ role "Setting product prices": quyền cho register ProductPrices, catalog Products, document PriceSetup nếu register có recorder...).
- Cách đơn giản nhất: mở IB user card trong Designer mode và tick các role cần thiết. Cách này phổ quát, dùng tốt cho configuration đơn giản/ít user; role thường tương ứng chức danh (CEO, Purchasing Manager, Sales Manager, Storekeeper...).
- Khi configuration phức tạp, nhiều user, thay đổi nhân sự thường xuyên: role theo chức danh không phù hợp (cấp nhiều role lớn → thừa quyền).
- **"Granulated" roles**: role cấp quyền cho từng chức năng nhỏ (ví dụ ReadingSalesInvoice, AddChangePriceSetup, ReadCounterparties, SalesSubsystem). Nhưng với hệ thống lớn, mỗi user cần hàng chục/hàng trăm role → tốn nhiều thời gian quản lý.
- Vì vậy các standard configuration dựa trên **SSL (Standard Subsystems Library)** có thêm một lớp giữa IB user và roles: subsystem **"AccessManagement"**, gom roles thành **"Profiles"**.
  - Có thể tạo profile (ví dụ Accountant có quyền đặt giá) bằng cách gộp roles thay vì tạo role mới trong configuration (vốn cần exclusive access để cập nhật DB configuration).
  - Profiles tạo/sửa được trong Enterprise mode.
  - Sơ đồ: thực thể **"Access profile"** và **"Access group"**. Mỗi access profile gồm nhiều roles; mỗi user được gán một hoặc nhiều access groups; mỗi access group gắn với một access profile.

### Mandatory roles (role bắt buộc)
Configuration phải định nghĩa 3 role bắt buộc:
- **FullAccess** (synonym "Full access"): truy cập không giới hạn tới mọi dữ liệu "applied", nhưng **không** cấp quyền quản trị infobase nói chung (update configuration, làm việc trong designer...). Role này phải:
  - dùng độc lập được (gán cho user);
  - truy cập không giới hạn mọi dữ liệu, trừ quyền interactive deletion;
  - cho phép mọi thao tác quản trị dữ liệu (quản trị user, thiết lập chương trình, xóa object đã đánh dấu...);
  - gồm các quyền: Data administration, Active users, Event log, Exclusive mode, Thin client, Web client, Save user data, Output.
- **SystemAdministrator** (synonym "System administrator"): quyền bổ sung để quản trị infobase nói chung. Role này phải:
  - chỉ gán cho user **cùng với** FullAccess;
  - truy cập không giới hạn mọi dữ liệu (cho configuration phức tạp hoặc cloud infobase);
  - chứa mọi access rights tới objects (trừ quyền interactive delete);
  - gồm mọi quyền tới configuration root (đặc biệt Administration và Data Administration), trừ "Interactive opening of external reports" và "Interactive opening of external data processors".
- **InteractiveOpenExtReportsAndDataProcessors** (synonym "Open external reports and data processors interactively"): quyền mở external reports/data processors qua menu File - Open. Gồm quyền tới configuration root "Interactive opening of external reports" và "Interactive opening of external data processors".
- Ví dụ trong configuration Trade Management: quyền "update configuration" bị tắt cho SystemAdministrator vì có role riêng cho quyền này.
- Ba role trên phải được đặt làm **default roles** của configuration (property **DefaultRoles**). Default roles là role gán cho mỗi user khởi động infobase khi infobase chưa có user nào.
- Nếu cần thiết lập general rights (như "Thin client", "Thick client", "Interactive opening of external data processors"...), configuration phải định nghĩa role riêng để cấp; các role này không dùng độc lập mà gán cùng role khác.
- Configuration phải hoạt động được cả khi user có và không có các role này.
- Các quyền sau **không được đặt trong bất kỳ role nào**, kể cả FullAccess và SystemAdministrator (trừ trường hợp có lý do chính đáng):
  - Interactive delete
  - Interactive deletion of predefined objects
  - Interactive deletion mark on predefined objects
  - Interactive removal of deletion mark from predefined objects
  - Interactive deletion of marked predefined objects
- Khuyến nghị chỉ để quyền delete trong FullAccess và SystemAdministrator. Nếu cần cho user không có full rights xóa object → thêm role riêng **DeleteMarkedObjects** (không dùng độc lập, gán cùng role khác).

### Thiết lập quyền cho object mới và attribute
- Phải tuân thủ cách đặt quyền sao cho không xuất hiện role cấp quyền tới field của object mà không cấp quyền tới chính object (tránh việc user vô tình có quyền tới mọi attribute khi được gán role đó).
- Checkbox **"Set rights for new objects"** chỉ tick cho role **FullAccess**.
- Khi thêm role mới: tick **"Set rights for attributes and tabular sections by default"**, bỏ tick **"General rights for subordinate objects"**.
- Nếu cần role chỉ cấp quyền cho field của metadata object (View/Edit cho attributes, tabular sections, dimensions, commands... mà không có quyền trên object): trước đó trong role phải tick "General rights for subordinate objects", bỏ tick "Set rights for attributes and tabular sections by default" và xóa quyền trên mọi attributes và tabular sections.
- Khi thêm object mới hoặc field mới vào configuration → phải cấu hình quyền cho chúng trong các role tương ứng.

### Kiểm tra user có role
- Có thể dùng role "flag": role không cấp quyền nào, chỉ là marker cho biết user có quyền nào đó (ví dụ duyệt hợp đồng).
- Dùng method **IsInRole()**.

### Thực hành tạo role (theo bài)
- Role theo chức danh: "CEO", "PurchaseManager", "SalesManager", "Storekeeper", "HRM".
- Tạo role bắt buộc trước: SystemAdministrator (cấp quyền configuration root), FullAccess. Vì luôn dùng cùng nhau, chỉ để quyền tới objects cho FullAccess; SystemAdministrator chỉ có quyền tới platform mechanisms.
- FullAccess: mọi quyền tới mọi object trừ "Interactive delete" và các quyền liệt kê ở mục Mandatory roles.
- InteractiveOpenExtReportsAndDataProcessors: chỉ 2 quyền tới platform mechanisms.
- Khi tạo role mới, đã có sẵn các quyền: "Thin client", "Web client", "Mobile client", mọi loại main window modes, "Analytics system client" (sản phẩm BI riêng của 1C), "Save user data", "Output". Khuyến nghị giữ nguyên cho role theo chức danh.
- Với atomic roles (role nhỏ cho từng chức năng): bỏ tick mọi quyền tới platform mechanisms, trừ khi role đó chính là để cấp các quyền này (ví dụ role "ThinClient").
- Role SalesManager:
  - Documents "Sales invoice", "Return of goods from customer": mọi quyền trừ deletion và quyền data history.
  - Document "Purchase invoice": chỉ "Read", "View", "String input".
  - Accumulation registers liên quan bán hàng/di chuyển hàng: "Read", "View" (nếu không user không lập được report).
  - Reports và data processors chỉ có 2 quyền: "Use" và "View".
  - Price register: "Read" và "Update" (vì data processor ghi giá), cộng "View" và "Edit" (vì sales manager được đổi giá ngoài data processor).
  - **Bắt buộc** cấp "View" cho subsystems user cần truy cập — nếu không, user có quyền tới catalog/document nhưng không thấy trong interface.
  - Commands và common forms chỉ có một quyền: "View".
  - Constants: cần đọc giá trị → "Read"; cần thấy giá trị trên form → thêm "View".
- Khuyến nghị test truy cập dưới từng role (hoặc access profile).
- Tạo user Administrator (3 role chính) và User_Sales (role "SalesManager"). Khi infobase có ít nhất một user, platform yêu cầu authentication khi khởi động.
- Với user full access: menu "More" của form object tham chiếu không còn nút "Delete" (xóa trực tiếp record trong DB, không kiểm tra referential integrity) vì đã tắt "Interactive delete" trong FullAccess.

### Điều tra lỗi Access violation
- Tìm sự kiện lỗi truy cập trong **event log** (user có quyền quản trị xem được ở cả Designer và Enterprise).
- Record loại "Error" có record vi phạm quyền đứng trước; cột **Metadata** chỉ metadata object (ví dụ information register "Companies responsible persons"), cột **Data** chỉ quyền còn thiếu (ví dụ "Read"); dòng lỗi cho biết code gọi từ đâu (form catalog Companies).
- Lỗi khó điều tra khi xảy ra trong khối Try mà exception không được xử lý đủ chi tiết.
- Hai cách sửa:
  1. Cấp quyền còn thiếu cho role ("Read" là đủ nếu chỉ đọc bằng code).
  2. Tạm tắt giới hạn quyền — chạy code ở **privileged mode**.

### Privileged mode
- Flag **"Privileged"** của common module: mọi code trong module chạy không giới hạn quyền; module chỉ có thể là server-side.
- Method **SetPrivilegedMode(Boolean)**: bật (True) / tắt (False) privileged mode cho một đoạn code.
- Nếu không tắt tường minh, privileged mode tự tắt khi procedure/function bật nó kết thúc.
- Khuyến nghị **luôn tắt tường minh** (khi làm việc nhóm, người khác có thể thêm code vào procedure và code đó chạy không giới hạn quyền).
- Sai: bật privileged mode trước khi gọi một function (bên trong function có thể có code cần kiểm tra quyền). Đúng: chỉ bật ngay trước đoạn code cần bỏ kiểm tra quyền.
- Nếu bật privileged mode để chạy code sau toán tử Return thì không cần tắt tường minh sau đó (code sau Return không chạy).
- Ở client-server mode, privileged mode chỉ bật được trên server; gọi trên client không có tác dụng.
- Privileged mode không hiệu quả khi hiển thị cho user dữ liệu về object mà user không có quyền "View" — user sẽ thấy link tới object không tồn tại ("Object not found").
- Trong bài: cuối cùng vẫn cấp quyền "Read" (và "View") register responsible persons cho SalesManager và các role khác, xóa code privileged mode. Quyền ghi vào register này cấp cho role có quyền sửa companies (vì form module company ghi vào register khi write).

### User authentication
- Debug dưới user khác (user không có password): Tools - Options → tab **1C:Enterprise startup** → vùng "User" chọn setting "Name".
  - Để trống: mỗi lần khởi động platform hỏi chọn user.
  - Chọn user cụ thể: không có password → khởi động ngay; có password → mở cửa sổ authentication với tên đã chọn sẵn.
- Ẩn user khỏi danh sách chọn: bỏ tick **"Show in the selection list"** trong cửa sổ user.
- **OS authentication**: gán OS user cho 1C user; khi OS user đó đăng nhập, platform đăng nhập dưới 1C user tương ứng mà không hiện cửa sổ authentication.
- Nếu user không có cả 1C:Enterprise authentication lẫn OS authentication → biểu tượng dấu hỏi trong danh sách user. Platform còn có các phương thức authentication khác: OpenID, OpenID Connect, access token.

### Unsafe operation protection
- Cơ chế cảnh báo khi thực hiện thao tác tiềm ẩn nguy hiểm. Các thao tác này gồm:
  - Chạy external data processor (report) hoặc configuration extension.
  - Chạy hoặc cập nhật configuration/extension.
  - Truy cập từ external data processor (report) hoặc extension tới: load external data processor (report) khác; thực thi lệnh hệ điều hành; quản lý user; load external component.
- Flag **"Unsafe operation protection"** trong user properties, bật mặc định khi tạo user. Khuyến nghị không bỏ tick.

## Cú pháp & ví dụ code

Kiểm tra quyền từ built-in language:
```bsl
&AtServer

Procedure OnCreateAtServer(Cancel, StandardProcessing)

    If AccessRight("InteractiveDelete", Metadata.Documents.Document1) Then

        Items.ButtonDeleteDocument1.Enabled = True;

    Else

        Items.ButtonDeleteDocument1.Enabled = False;

    EndIf;

EndProcedure
```

Kiểm tra user có role:
```bsl
If IsInRole("DocumentApproval") Then
```

Method bật/tắt privileged mode:
```bsl
SetPrivilegedMode(Boolean)
```

[ghi chú ngoài nguồn] Các ví dụ privileged mode (tắt ngầm định, tắt tường minh, dùng sai/đúng trước lời gọi function) trong tài liệu gốc là ảnh chụp màn hình, không có code dạng văn bản để chép nguyên văn. Nhánh lesson/20-theory cũng không có lời gọi `SetPrivilegedMode` (đã ở trạng thái cuối bài: cấp quyền Read thay cho privileged mode; common module `CommonServerPrivileged` có flag Privileged nhưng trống) nên các ví dụ này vẫn chưa có code; phần điều tra Access violation, role bắt buộc và thiết lập quyền → đã bổ sung (nhánh lesson/20-theory).

## Thuộc tính/thiết lập quan trọng trong Designer
- **DefaultRoles** (property của configuration) — đặt FullAccess, SystemAdministrator, InteractiveOpenExtReportsAndDataProcessors.
- Role checkboxes: **"Set rights for new objects"** (chỉ FullAccess), **"Set rights for attributes and tabular sections by default"** (tick khi tạo role mới), **"General rights for subordinate objects"** (bỏ tick khi tạo role mới).
- Common module flag **"Privileged"**.
- User properties: **"Show in the selection list"**, **"Unsafe operation protection"**, OS authentication / 1C:Enterprise authentication.
- Tools - Options → tab **1C:Enterprise startup** → "User" → "Name".
- Event log: cột **Metadata**, **Data**.

## Lỗi thường gặp / lưu ý
- Thiếu quyền "View" → list form/object form không mở, hiện thông báo vi phạm quyền.
- Thao tác không được phép → "Access violation!", mọi transaction bị hủy.
- Kiểm tra interactive rights có thể bị vượt qua; non-interactive thì không. Khi thêm command vào form phải tự kiểm tra interactive rights.
- Không thể cho phép interactive right khi cấm non-interactive tương ứng (ví dụ không thể cho "Interactive delete" mà cấm "Delete").
- Thiếu "Read" → mất mọi quyền khác trên object.
- Quên cấp "View" cho subsystem → user không thấy object trong interface dù có quyền.
- Form không có main attribute → quyền trên data processor không ngăn mở form; quyền được xác định bởi main attribute, không phải vị trí form trong cây metadata.
- Lỗi đọc register trong OnCreateAtServer khi role thiếu "Read" → access violation khi mở form (ví dụ register "Companies responsible persons").
- Bật privileged mode trước khi gọi function là sai; quên tắt privileged mode tường minh là rủi ro khi làm việc nhóm.
- Privileged mode trên client không có tác dụng.
- Hiển thị dữ liệu đọc ở privileged mode cho user không có "View" → "Object not found".
- Không đặt "Interactive delete" và các quyền xóa predefined trong bất kỳ role nào.

## Điểm cần nhớ
- 1C: mọi thứ không được cho phép đều bị cấm; access right là cơ chế duy nhất kiểm soát truy cập.
- 4 basic rights Insert / Read / Update / Delete là đủ để xây dựng giải pháp an toàn; "Read" là quyền then chốt.
- Interactive rights phụ thuộc non-interactive; non-interactive không thể bị vượt qua.
- Quyền mở form xác định bởi main attribute (trừ common forms).
- 3 mandatory roles: FullAccess, SystemAdministrator, InteractiveOpenExtReportsAndDataProcessors — đặt làm DefaultRoles.
- Không cấp "Interactive delete" cho role nào; dùng role DeleteMarkedObjects nếu cần cho user thường.
- SSL có subsystem AccessManagement với Access profile / Access group, cấu hình được ở Enterprise mode.
- SetPrivilegedMode(True/False): chỉ bao quanh đúng đoạn code cần, luôn tắt tường minh, chỉ có tác dụng trên server.

## Thẻ gợi ý bài thực hành (Practice 20)

Các thẻ dưới đây đi theo thứ tự đề trong 20. Practice. Bài này chủ yếu là thiết lập role và user trong Designer, gần như không phải viết code. Mỗi thẻ chỉ có gợi ý, không có lời giải: bạn tự làm rồi kiểm tra trong Enterprise mode dưới từng user.

### Bài tập 1 — Ba role bắt buộc và user Administrator

- **Đề bài (tóm tắt):** Tạo 3 role bắt buộc (full rights, quản trị, mở external reports/data processors), đưa cả 3 vào default roles của configuration, tạo user Administrator có cả 3 role.
- **Gợi ý 1 — Hướng đi:** Xem mục "Mandatory roles" và "Thực hành tạo role". Ba role này luôn dùng cùng nhau, nên quyền tới objects chỉ đặt trong role full access; role quản trị chỉ chứa quyền tới configuration root; role thứ ba chỉ có 2 quyền mở external reports/data processors.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Roles: FullAccess (đề gọi là FullRights), SystemAdministrator (đề gọi là Administrator), InteractiveOpenExtReportsAndDataProcessors.
  - Checkbox của role: "Set rights for new objects" chỉ tick ở FullAccess; "Set rights for attributes and tabular sections by default" tick; "General rights for subordinate objects" bỏ tick.
  - Property **DefaultRoles** của configuration root.
  - Administration → Users (Designer) để tạo user.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo role full access: tick mọi quyền tới mọi object, rồi bỏ "Interactive delete" và các quyền xóa/đánh dấu xóa predefined.
  2. Ở configuration root của role full access: bỏ Administration, cập nhật DB configuration và 2 quyền mở external reports/data processors.
  3. Tạo role quản trị: chỉ tick quyền ở configuration root (Administration, Data administration...), trừ 2 quyền mở external.
  4. Tạo role thứ ba với đúng 2 quyền `InteractiveOpenExtDataProcessors`, `InteractiveOpenExtReports`.
  5. Đưa cả 3 vào DefaultRoles, tạo user Administrator và tick 3 role.
  - Mẹo của đề: tick quyền "từ cuối lên đầu". Ví dụ tick "String input" thì "Read" và "View" tự bật.
- **Lỗi hay gặp:**
  - Quên DefaultRoles. [ghi chú ngoài nguồn] Trong dump cấu hình của khóa (cả nhánh theory) property DefaultRoles đang trống, đừng lấy đó làm mẫu.
  - Để "Set rights for new objects" bật ở role khác ngoài full access.
  - Khi infobase đã có ít nhất một user, platform bắt đăng nhập. Hãy tạo user Administrator **trước** khi thử các user khác, kẻo không còn ai có quyền quản trị.
- **Tự kiểm tra:** Khởi động Enterprise dưới Administrator: mọi section hiện đủ, menu "More" của form catalog **không** còn nút "Delete" (xóa trực tiếp), File - Open mở được external data processor.

### Bài tập 2 — Đổi tên configuration

- **Đề bài (tóm tắt):** Đổi property Name của configuration root thành tên phù hợp với giải pháp của bạn.
- **Gợi ý 1 — Hướng đi:** Name của root là tên metadata, khác synonym. Role lưu quyền tới root theo object `Configuration.<Name>`, nên hãy làm bước này rồi mới mở lại các role để kiểm tra quyền ở root.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Properties palette của root configuration → Name (và Synonym hiển thị cho user).
- **Gợi ý 3 — Khung bài làm:**
  1. Mở properties của root, đổi Name (không dấu cách) và Synonym.
  2. Update DB configuration.
  3. Mở lại một role, kiểm tra cây quyền ở root đã mang tên mới.
- **Lỗi hay gặp:**
  - Chỉ đổi Synonym mà quên Name (đề yêu cầu Name).
  - Dùng dấu cách hoặc ký tự không hợp lệ trong Name.
- **Tự kiểm tra:** Tiêu đề cửa sổ Enterprise hiện synonym mới. Trong role, nút cấu hình quyền ở root hiển thị đúng tên mới.

### Bài tập 3 — Role theo chức danh: CEO, PurchaseManager, SalesManager, Storekeeper, MasterDataSpecialist

- **Đề bài (tóm tắt):** Tạo 5 role theo chức danh, mỗi role làm việc với subsystem phù hợp. CEO có quyền tới objects như FullAccess (trừ "Totals control") nhưng không có quyền quản trị ở root. MasterDataSpecialist tạo/sửa mọi master data. Các role khác được sửa master data theo nghiệp vụ.
- **Gợi ý 1 — Hướng đi:** Xem "Thực hành tạo role" (ví dụ SalesManager của bài lý thuyết) và "Access rights khi làm việc với form". Quyền "View" trên subsystem là bắt buộc thì user mới thấy object trong interface. Report/data processor chỉ cần "Use" + "View".
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - 5 role mới, checkbox như khi tạo role mới (xem bài 1).
  - Với CEO: quyền "Advanced tools"/chế độ technician ở root được phép (đề gợi ý), nhưng không có Administration.
  - Register giá: role nào ghi giá (qua data processor) cần "Read" + "Update"; role được sửa giá trên form cần thêm "View" + "Edit".
  - Mẹo của đề: làm xong một role "khung" có các quyền Read/View chung, rồi **copy** nó thành các role khác và chỉ sửa phần Insert/Update.
- **Gợi ý 3 — Khung bài làm:**
  1. Lập bảng giấy: hàng là object (catalog, document, register, report, data processor, subsystem), cột là 5 role, ô ghi R/V hay I/U/E.
  2. Tạo role khung với quyền đọc chung (Read, View, String input cho catalog/document, Read/View cho register, Use/View cho report).
  3. Copy thành 5 role, thêm Insert/Update/Interactive insert/Edit theo bảng (PurchaseManager tạo được product, SalesManager tạo được counterparty và contract...).
  4. Cấp "View" cho subsystem tương ứng của từng role.
- **Lỗi hay gặp:**
  - Quên "View" cho subsystem: user có quyền nhưng không thấy gì trong interface.
  - Cấp quyền sửa catalog mà quên các information register mà form của catalog đó ghi vào khi write (ví dụ register responsible persons của Companies trong bài lý thuyết).
  - Cho CEO "Totals control" hoặc quyền quản trị ở root.
- **Tự kiểm tra:** Đăng nhập lần lượt từng user: section hiển thị đúng chức danh, tạo được đúng loại master data cho phép, không tạo được loại không cho phép.

### Bài tập 4 — Characteristics cho mọi user, quyền xóa chỉ cho CEO, constants chỉ CEO/FullAccess

- **Đề bài (tóm tắt):** Mọi role được tạo characteristic mới (chart of characteristic types "Additional attributes and properties") và giá trị characteristic (catalog "ObjectsPropertiesValues"). Chỉ CEO có quyền xóa object. Chỉ CEO và FullAccess được sửa constants.
- **Gợi ý 1 — Hướng đi:** Quyền "Delete" là non-interactive (xóa bằng code, ví dụ khi xóa object đã đánh dấu), khác "Interactive delete". Constant: "Read" để đọc, "View" để thấy, "Update"/"Edit" để sửa.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - `ChartOfCharacteristicTypes.AdditionalAttributesAndProperties`, `Catalog.ObjectsPropertiesValues`: Insert/Update/Interactive insert/Edit cho mọi role.
  - Quyền "Delete" (không phải Interactive delete) chỉ ở CEO (ngoài FullAccess).
  - Constants: các role thường chỉ Read (+View nếu cần thấy trên form).
- **Gợi ý 3 — Khung bài làm:**
  1. Ở role khung (nếu chưa copy) hoặc lần lượt 5 role, mở 2 object characteristics và cấp quyền tạo/sửa.
  2. Đi qua mọi object trong CEO, tick "Delete" nhưng **không** tick "Interactive delete".
  3. Rà các role còn lại: không có "Delete" ở object nào.
  4. Rà constants ở 4 role không phải CEO: bỏ Update/Edit.
- **Lỗi hay gặp:**
  - Nhầm "Delete" với "Interactive delete" (đề cấm cái thứ hai ở mọi role, xem bài 5).
  - Functional option dựa trên constant bị ẩn sai với user không có "Read" trên constant. Xem bài 7.
- **Tự kiểm tra:** User không phải CEO: tạo được characteristic mới, field constant trên form chỉ đọc. User CEO: dùng được "Delete marked objects".

### Bài tập 5 — Không role nào có Interactive delete và quyền xóa predefined

- **Đề bài (tóm tắt):** Không role nào được có "Interactive delete" và các quyền interactive liên quan tới xóa predefined objects.
- **Gợi ý 1 — Hướng đi:** Đúng danh sách 5 quyền trong mục "Mandatory roles" (kể cả FullAccess và SystemAdministrator).
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Trong mỗi role, các quyền Interactive delete, Interactive deletion of predefined objects, Interactive deletion mark / removal of deletion mark / deletion of marked predefined objects (chỉ xuất hiện ở object có predefined data, ví dụ catalog Users).
- **Gợi ý 3 — Khung bài làm:**
  1. Với từng role, lọc theo từng loại object (catalog, document, chart...).
  2. Bỏ tick 5 quyền trên ở mọi object.
  3. Ghi chú lại để khi thêm object mới vào configuration thì nhớ bỏ tick (đặc biệt ở FullAccess vì "Set rights for new objects" bật).
- **Lỗi hay gặp:**
  - Bỏ ở object thường nhưng quên object có predefined data.
  - Bỏ nhầm quyền "Interactive set deletion mark" thường: đánh dấu xóa vẫn phải được phép.
- **Tự kiểm tra:** Dưới mọi user, menu "More" của form object không có nút "Delete". Đặt deletion mark vẫn làm được.

### Bài tập 6 — Không cấp Update/Edit cho accumulation register, post ở privileged mode

- **Đề bài (tóm tắt):** Không cấp quyền update/edit accumulation registers. Thay vào đó document phải post và unpost ở privileged mode (bật ở tab "Rights" của document nếu chưa bật).
- **Gợi ý 1 — Hướng đi:** Xem "Privileged mode". Posting handler ghi `RegisterRecords`; nếu post ở privileged mode thì platform không kiểm tra quyền của user trên register khi ghi. User chỉ cần Read/View trên register để xem report và số dư.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Tab **Rights** của mỗi document có posting: "Post in privileged mode", "Unpost in privileged mode".
  - Trong role: accumulation registers chỉ "Read" + "View".
- **Gợi ý 3 — Khung bài làm:**
  1. Liệt kê mọi document có posting trong configuration (mua, bán, trả hàng, chuyển kho, đặt giá...).
  2. Mở tab Rights từng document, kiểm tra 2 checkbox privileged mode.
  3. Trong mọi role nghiệp vụ, để accumulation register chỉ Read/View.
- **Lỗi hay gặp:**
  - Sót một document (ví dụ document chuyển kho hoặc đặt giá): user post sẽ bị "Access violation!".
  - Đọc số dư trong posting (kiểm tra tồn) cũng chạy trong privileged mode, nhưng code đọc register **ở form** thì không, nên role vẫn cần "Read".
  - [ghi chú ngoài nguồn] Đề nói CEO "same rights as FullAccess", nên khi chấm có thể chấp nhận CEO có Update/Edit trên register. Hãy tự quyết định và ghi rõ lý do. Mặc định nên theo yêu cầu "không cấp update/edit".
- **Tự kiểm tra:** Đăng nhập Storekeeper/SalesManager, post và unpost document thành công. Mở trực tiếp list của accumulation register: không sửa được record.

### Bài tập 7 — Tạo user cho từng role và test toàn bộ ứng dụng

- **Đề bài (tóm tắt):** Tạo ít nhất một user cho mỗi role chức danh, test mọi chức năng (kể cả report và data processor). Thiếu quyền thì sửa role hoặc dùng privileged mode để lấy dữ liệu.
- **Gợi ý 1 — Hướng đi:** Xem "Điều tra lỗi Access violation" và "Privileged mode". Event log cho biết metadata object và quyền thiếu. Chọn: cấp quyền thiếu (thường chỉ "Read") hoặc bọc đúng đoạn đọc dữ liệu bằng privileged mode ở server.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Tools - Options → tab 1C:Enterprise startup → "User" để debug dưới user khác.
  - Event log (cột Metadata, Data).
  - Server-side: `SetPrivilegedMode(True/False)` hoặc common module có flag Privileged.
  - Functional option có property "Privileged get mode": user không cần quyền đọc constant mà interface vẫn ẩn/hiện đúng.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo user cho từng role (không password cho dễ test), bỏ "Show in the selection list" nếu muốn ẩn user.
  2. Với mỗi user: mở mọi section, tạo/post document, chạy từng report và data processor.
  3. Gặp lỗi → mở event log bằng Administrator, đọc Metadata + Data.
  4. Quyết định: thêm quyền vào role, hoặc dùng khung privileged mode dưới đây cho đoạn chỉ đọc dữ liệu.
  ```bsl
  &AtServer
  Function ___(___)
  	// bật privileged mode NGAY trước đoạn đọc dữ liệu, không bật trước lời gọi function khác
  	___
  	// đoạn đọc dữ liệu user không có quyền
  	___
  	// tắt privileged mode tường minh
  	___
  	Return ___;
  EndFunction
  ```
- **Lỗi hay gặp:**
  - Bật privileged mode ở client: không có tác dụng.
  - Hiển thị dữ liệu đọc bằng privileged mode cho user không có "View" trên object đó → "Object not found".
  - Quên test report (thiếu Read trên register) và data processor (thiếu Use).
- **Tự kiểm tra:** Mỗi user đi hết kịch bản nghiệp vụ của mình mà không có "Access violation!". Event log không còn record lỗi quyền.

### Bài tập 8 — Flag "Modifies saved data" cho nút "Fill by sales document"

- **Đề bài (tóm tắt):** Nút "Fill by sales document" của document "Return of goods from customer" vẫn bấm được khi user không có quyền sửa. Sửa bằng cách bật flag "Modifies saved data" cho form command.
- **Gợi ý 1 — Hướng đi:** Xem "Kiểm tra interactive rights có thể bị vượt qua": khi tự thêm command vào form, developer phải lo quyền. Flag này cho platform biết command sửa dữ liệu, nên platform tự khóa nút khi user không có quyền Edit.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Form của document ReturnOfGoodsFromCustomer → tab Commands → command `FillBySalesDocument` → property **Modifies saved data**. Rà thêm các form command khác có sửa dữ liệu (ví dụ command điền hàng theo số dư ở form chuyển kho).
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo/dùng user chỉ có quyền đọc document trả hàng.
  2. Mở document dưới user đó, xác nhận nút vẫn bấm được (lỗi).
  3. Bật flag cho command, update DB configuration.
  4. Rà mọi form command khác có thay đổi dữ liệu và bật flag tương tự.
- **Lỗi hay gặp:**
  - Bật flag ở **button** thay vì ở **command**.
  - [ghi chú ngoài nguồn] Trong dump cấu hình của khóa, command `FillBySalesDocument` vẫn chưa có flag này (trạng thái trước khi sửa mà đề mô tả), nên đừng lấy dump làm bằng chứng là đã đúng.
- **Tự kiểm tra:** Dưới user chỉ đọc, nút "Fill by sales document" bị mờ. Dưới SalesManager, nút vẫn hoạt động.

## Code demo của bài Theory (repo 1CJDCourse, nhánh lesson/20-theory)

### Điều tra Access violation: code đọc register CompaniesResponsiblePersons và quyền Read/View cấp cho SalesManager

Nguồn: nhánh lesson/20-theory — cf/Catalogs/Companies/Forms/ItemForm/Ext/Form/Module.bsl; cf/Roles/SalesManager/Ext/Rights.xml

Form module của catalog Companies (chỗ gây lỗi "Read" trên information register khi mở company dưới User_Sales):

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

Quyền được cấp trong role SalesManager (cách sửa 1 của bài):

```xml
	<object>
		<name>InformationRegister.CompaniesResponsiblePersons</name>
		<right>
			<name>Read</name>
			<value>true</value>
		</right>
		<right>
			<name>View</name>
			<value>true</value>
		</right>
	</object>
```

- Đúng ví dụ trong bài: event log chỉ metadata object "Companies responsible persons", quyền thiếu "Read", lời gọi xuất phát từ form catalog Companies (`OnCreateAtServer` → `GetLast()` của register).
- Nhánh ở trạng thái **cuối** của bài: đã cấp "Read" + "View" cho SalesManager và không còn code privileged mode trong form.
- Quyền ghi register (`RecordManager.Write(True)` trong `UpdateResponsiblePersons`, gọi từ `OnWriteAtServer`) chỉ cần cho role được sửa companies — SalesManager không có Update trên catalog Companies nên không cần.

### Common module có flag "Privileged"

Nguồn: nhánh lesson/20-theory — cf/CommonModules/CommonServerPrivileged.xml

```xml
			<Global>false</Global>
			<ClientManagedApplication>false</ClientManagedApplication>
			<Server>true</Server>
			<ExternalConnection>false</ExternalConnection>
			<ClientOrdinaryApplication>false</ClientOrdinaryApplication>
			<ServerCall>false</ServerCall>
			<Privileged>true</Privileged>
			<ReturnValuesReuse>DontUse</ReturnValuesReuse>
```

- Flag `Privileged` = true: mọi code trong module chạy không kiểm tra quyền; module chỉ có thể là server-side (`Server` = true, client flags = false).
- Trong nhánh module này còn trống — không có lời gọi `SetPrivilegedMode()` nào trong code, nên các ví dụ privileged mode bằng code của bài vẫn chỉ có trong ảnh.

### "Post in privileged mode" / "Unpost in privileged mode" cho document PersonnelChange

Nguồn: nhánh lesson/20-theory — cf/Documents/PersonnelChange.xml

```xml
			<Posting>Allow</Posting>
			<RealTimePosting>Allow</RealTimePosting>
			<RegisterRecordsDeletion>AutoDeleteOnUnpost</RegisterRecordsDeletion>
			<RegisterRecordsWritingOnPost>WriteSelected</RegisterRecordsWritingOnPost>
			<SequenceFilling>AutoFill</SequenceFilling>
			<RegisterRecords>
				<xr:Item xsi:type="xr:MDObjectRef">InformationRegister.Employees</xr:Item>
			</RegisterRecords>
			<PostInPrivilegedMode>true</PostInPrivilegedMode>
			<UnpostInPrivilegedMode>true</UnpostInPrivilegedMode>
```

- Cả 5 document của nhánh (SalesInvoice, ReturnOfGoodsFromCustomer, PurchaseInvoice, PersonnelChange, BonusesFinesOfEmployeesRegistration) bật hai property này.
- Nhờ vậy role SalesManager chỉ cần "Read"/"View" trên accumulation register mà vẫn post được document.

### Role FullAccess: "Set rights for new objects", không có Interactive delete và quyền quản trị configuration

Nguồn: nhánh lesson/20-theory — cf/Roles/FullAccess/Ext/Rights.xml

```xml
<Rights xmlns="http://v8.1c.ru/8.2/roles" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="Rights" version="2.19">
	<setForNewObjects>true</setForNewObjects>
	<setForAttributesByDefault>true</setForAttributesByDefault>
	<independentRightsOfChildObjects>false</independentRightsOfChildObjects>
	<object>
		<name>Catalog.Companies</name>
		<right>
			<name>InteractiveDelete</name>
			<value>false</value>
		</right>
		<right>
<!-- ... -->
	<object>
		<name>Configuration.Configuration</name>
		<right>
			<name>Administration</name>
			<value>false</value>
		</right>
		<right>
			<name>UpdateDataBaseConfiguration</name>
			<value>false</value>
		</right>
		<right>
			<name>ConfigurationExtensionsAdministration</name>
			<value>false</value>
		</right>
		<right>
			<name>InteractiveOpenExtDataProcessors</name>
			<value>false</value>
		</right>
		<right>
			<name>InteractiveOpenExtReports</name>
			<value>false</value>
		</right>
	</object>
```

- `setForNewObjects` = true chỉ ở FullAccess (role SalesManager và các role khác = false), `setForAttributesByDefault` = true, `independentRightsOfChildObjects` = false — đúng khuyến nghị "Thiết lập quyền cho object mới và attribute".
- `InteractiveDelete` = false cho từng object (ví dụ Catalog.Companies); với catalog có predefined data (Users) role còn tắt thêm các quyền interactive trên predefined data (cùng file, dòng 423-445) — đúng danh sách "không được đặt trong bất kỳ role nào".
- Ở configuration root, FullAccess tắt Administration, UpdateDataBaseConfiguration, ConfigurationExtensionsAdministration và hai quyền mở external reports/data processors — những quyền này nằm ở role Administration và InteractiveOpenExtReportsAndDataProcessors.

### Role bắt buộc InteractiveOpenExtReportsAndDataProcessors

Nguồn: nhánh lesson/20-theory — cf/Roles/InteractiveOpenExtReportsAndDataProcessors/Ext/Rights.xml

```xml
	<setForNewObjects>false</setForNewObjects>
	<setForAttributesByDefault>true</setForAttributesByDefault>
	<independentRightsOfChildObjects>false</independentRightsOfChildObjects>
	<object>
		<name>Configuration.Configuration</name>
		<right>
			<name>InteractiveOpenExtDataProcessors</name>
			<value>true</value>
		</right>
		<right>
			<name>InteractiveOpenExtReports</name>
			<value>true</value>
		</right>
	</object>
```

- Chỉ hai quyền tới configuration root: `InteractiveOpenExtDataProcessors`, `InteractiveOpenExtReports` — đúng mô tả role bắt buộc thứ ba.
- [ghi chú ngoài nguồn] Trong nhánh, role quản trị tên `Administration` (không phải `SystemAdministrator`) và property DefaultRoles của configuration đang trống.

### Role SalesManager: Purchase invoice chỉ đọc, register giá Read/Update/View/Edit, data processor Use/View

Nguồn: nhánh lesson/20-theory — cf/Roles/SalesManager/Ext/Rights.xml

```xml
	<object>
		<name>Document.PurchaseInvoice</name>
		<right>
			<name>Read</name>
			<value>true</value>
		</right>
		<right>
			<name>View</name>
			<value>true</value>
		</right>
		<right>
			<name>InputByString</name>
			<value>true</value>
		</right>
	</object>
<!-- ... -->
		<name>InformationRegister.ProductPrices</name>
		<right>
			<name>Read</name>
			<value>true</value>
		</right>
		<right>
			<name>Update</name>
			<value>true</value>
		</right>
		<right>
			<name>View</name>
			<value>true</value>
		</right>
		<right>
			<name>Edit</name>
			<value>true</value>
		</right>
	</object>
	<object>
```

- Document "Purchase invoice": chỉ "Read", "View", "String input" (`InputByString`) như bài yêu cầu.
- Register giá `ProductPrices`: "Read" + "Update" (data processor ghi giá) và "View" + "Edit" (sales manager được đổi giá ngoài data processor).
- Data processor `ImportPricesFromExcel` chỉ có "Use" và "View" (cùng file, cuối danh sách); role cũng có "View" cho `Subsystem.Sales` và `Subsystem.Sales.Subsystem.Prices` (bắt buộc để thấy object trong interface).

## Video tham khảo

Video bài giảng trên YouTube có phạm vi trùng với bài này. Khi dẫn cho người học, nói "Bạn có thể tham khảo thêm về <chủ đề> của khóa tại đây: [<tên video>](link)" — không nói "khóa cũ/Junior", không dùng mã JC (mã JC trong danh sách chỉ để tra nội bộ). Quy ước đầy đủ: `references/video.md#video-junior-course`.

Không có video bài giảng tương ứng — chỉ dẫn tài liệu Theory/Practice của bài.

<!-- video-qa-thuchanh:start -->

Video giải đáp tình huống thực chiến và video thực hành từng bước liên quan tới bài này (thẻ chi tiết, triệu chứng, lưu ý khi giới thiệu: `references/video.md#video-qa-thuc-chien`, `references/video.md#video-thuc-hanh`; cùng mẫu câu dẫn ở trên):

- [Hướng dẫn thiết lập vai trò người dùng](https://www.youtube.com/watch?v=senxXwfjFxU&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=3) (3:38) — tạo role và user đầu tiên (giải đáp tình huống; Bài 20 chính) _(mã nội bộ QA-3)_
- [Tạo chức năng sửa password với vai trò người dùng](https://www.youtube.com/watch?v=taKIdmcCmIQ&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=9) (26:39) — cho người dùng tự đổi mật khẩu (giải đáp tình huống; Bài 20 chính) _(mã nội bộ QA-9)_
- [Tùy chỉnh ngôn ngữ theo người dùng](https://www.youtube.com/watch?v=wo7G7jSPtBE&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=26) (4:30) — hiển thị ngôn ngữ khác nhau cho từng người dùng (giải đáp tình huống; Bài 20 chính) _(mã nội bộ QA-26)_
- [Lưu bộ xử lý ngoài](https://www.youtube.com/watch?v=DTRivJSbAoI&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=15) (1:40) — bộ xử lý ngoài (.epf) (giải đáp tình huống; Bài 20 liên quan) _(mã nội bộ QA-15)_
- [Lọc dữ liệu chọn sản phẩm theo hãng](https://www.youtube.com/watch?v=EfF2acfP2Y8&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=19) (6:30) — lọc danh sách chọn theo một trường khác (giải đáp tình huống; Bài 20 liên quan) _(mã nội bộ QA-19)_
- [Hướng dẫn publish Infobase 1C:Enterprise lên web server](https://www.youtube.com/watch?v=P_bwSfxAV8I&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=28) (7:21) — publish infobase lên web server (IIS) (giải đáp tình huống; Bài 20 liên quan) _(mã nội bộ QA-28)_

<!-- video-qa-thuchanh:end -->
