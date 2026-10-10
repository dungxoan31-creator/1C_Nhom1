# Tài liệu gộp: lessons-07-10

Gồm các mục: § bai-07, § bai-08, § bai-09, § bai-10


---

# § bai-07

# Bài 7 — Client-server: compilation directives, loại module, context/non-context call, đặt code đúng chỗ

## Khái niệm chính

### Phân chia client – server
- Mọi thao tác với application objects, đọc/ghi dữ liệu database chỉ thực hiện trên **server**. Chức năng form và command interface cũng được tạo ở server (chuẩn bị form data, sắp xếp elements, ghi form data sau khi thay đổi).
- Form chuẩn bị ở server được hiển thị ở **client**; client nhập liệu, gọi server để ghi dữ liệu. Command interface tạo ở server, hiển thị ở client. Report được tạo hoàn toàn ở server, hiển thị ở client.
- Platform tối thiểu hóa dữ liệu truyền về client: dữ liệu list, tabular sections, reports được truyền **dần theo phần người dùng đang xem**, không truyền hết ngay.
- **Server chạy**: database queries; ghi dữ liệu; posting documents; các phép tính; data processing; tạo reports; chuẩn bị form để hiển thị.
- **Client chạy**: lấy và mở form; hiển thị form; "giao tiếp" với người dùng (warnings, questions…); phép tính nhỏ cần phản hồi nhanh trong form (ví dụ price × quantity trên một dòng); làm việc với local files; làm việc với commercial equipment.

### Compilation directives trong form module
- **&AtClient**: chạy trong context client application. Có toàn bộ context form: attributes, elements, form parameters. Dùng cho mọi client event handler của form và procedure mô tả local form commands.
- **&AtServer**: chạy trong context server, có context form. Dùng cho mọi server event handler của form; developer cũng dùng để chuyển code lên server ("form's server procedures"). Gọi procedure này từ client = **context server call**.
- **&AtServerNoContext**: chạy ở server nhưng **không có form context** (attributes, elements, parameters). Dùng để chạy code chỉ chạy được ở server mà không phải truyền context giữa client và server (việc truyền context có thể tốn kém — phụ thuộc lượng form data, tốc độ client-server, sức mạnh máy client...). Gọi = **non-context server call**.
- **&AtClientAtServerNoContext**: chạy được cả ở client và server context. Ít dùng; dùng khi cần cùng một hành động cả lúc tạo form (server) và trong vòng đời form ở client → thay vì hai procedure giống nhau, viết một.
- Nếu **không ghi directive** trong form module → platform mặc định **&AtServer**.

### Quy tắc gọi
- Client procedure có thể gọi server procedure; chạy xong quay về client.
- **Không thể** gọi theo chiều ngược lại: server procedure không gọi được client procedure.
- Context server method **không thể** được gọi từ non-context client-server method hoặc non-context server method.

### Module chỉ chạy trên server
- Object module (catalog, document, chart of characteristic types và các reference objects khác).
- Object manager module.
- Record set module (registers).
- Một số common module — context phụ thuộc vào properties của module.

### Mục đích các module
- **Object module**: hiện thực hành vi của một instance riêng lẻ (CatalogObject, DocumentObject...). Chứa procedure/function làm việc với dữ liệu object (`ThisObject` và biến module), kể cả khi object chưa được ghi vào infobase. Ví dụ: object event handlers; procedure điền dữ liệu cho instance.
- **Manager module**: chứa chức năng "tĩnh" gắn logic với metadata object nhưng **không phụ thuộc trạng thái một instance cụ thể**:
  - liên quan tới tập hợp object (in danh sách, thông tin chung cho mọi instance, cập nhật infobase gắn với metadata object...);
  - làm việc với object đã ghi vào infobase, input parameter là **reference** (lấy printed form theo reference, tạo movements theo reference...).
  - Không cần data object instance (CatalogObject, DocumentObject...) để chạy.
- **Common module**: chức năng không gắn với một metadata object cụ thể, dùng chung cho nhiều object.

### 4 loại common module thường dùng
- **Client** — code luôn chạy chỉ trên client.
- **Client-server** — chạy trong context nơi gọi (gọi từ client → chạy ở client). Chỉ áp dụng cho code chạy được ở cả hai phía.
- **Server call** — chạy ở server, **có thể gọi từ client**.
- **Server** — chạy ở server, **chỉ gọi được từ server**.

### Preprocessor commands
- Dùng để tách code theo context chi tiết hơn: client method thực tế có thể chạy trên thin client, thick client, web client, mobile client. Một số code không chạy được trên web/mobile client hoặc cần điều kiện → tách bằng preprocessor commands.
- Ví dụ: method `Choose()` của object `FileDialog` (mở hộp thoại chọn file) yêu cầu file extension được kết nối khi chạy trên web client → cần tách logic.
- Method `AttachAddIn()` (gắn external component) không cần bước bổ sung, nhưng giới hạn: chỉ dùng được component dạng archive lưu trong infobase.

### Context và non-context call
- Mỗi context server call tạo thêm tải vì **toàn bộ form (elements + attribute data) được đóng gói gửi lên server**. Nếu không cần form data ở server → nên dùng non-context server call.
- Method &AtServerNoContext không biết `Object`, `ThisObject` (form hiện tại), `Items` (elements form hiện tại), và cả server variables của module → chỉ làm việc với dữ liệu được **truyền trực tiếp qua parameters**.
- Khi thêm parameter cho hàm, phải sửa lời gọi tương ứng, nếu không platform báo thiếu actual parameters.
- &AtClientAtServerNoContext: ngoài không có context, chỉ chạy code khả dụng ở cả client và server → **cấm truy cập database và tương tác người dùng**. Thường dùng cho tính toán đơn giản: tính tổng, điền title/text...
- Ví dụ tình huống: document có bảng products và attribute Total; Total tính lại ở client khi sửa số liệu; nhưng có server method thêm product rồi tính discount (discount ở server vì lưu trong database và phụ thuộc date + amount). Thay vì copy method tính Total thành bản server (trùng lặp code), tạo một method **client-server non-context** gọi được từ cả hai context. Cách nhân bản chỉ dùng trong tình huống khẩn cấp khi cần cùng hành động ở cả hai phía nhưng vẫn cần context.
- `AddMonth` cộng số tháng vào ngày truyền vào.

### Code placement (đặt code đúng module)
- Lỗi phổ biến: đặt business logic (ví dụ lấy giá hiện tại của product) trong **form module**.
- Form module dùng cho: làm việc với form, attributes, elements; tương tác người dùng (xử lý dữ liệu nhập, hiển thị kết quả, thông báo).
- Ví dụ SalesInvoice: attributes Customer (catalog Counterparties) và Contract (catalog CounterpartyContracts); Counterparties có attribute MainContract. Khi Customer đổi → Contract = MainContract của customer (handler sự kiện **OnChange** của field Customer).
- Gán **Undefined** cho attribute để xóa giá trị → kết quả là giá trị mặc định của kiểu: Number → 0; String → "" ; Date → 01.01.0001 00:00:00; Boolean → False; reference type → empty reference.
- Lý do không đặt logic này trong form module: document có thể được tạo từ code, hoặc từ giao diện với một số attribute đã điền sẵn (generation mechanism — tạo document dựa trên object khác); lúc đó không làm việc với form mà chỉ với object.
- Giải pháp: chuyển thuật toán vào **object module**, làm thành **export procedure** (FillMainContract), gọi lại từ form module.
  - Trong object module không có `Object` → bỏ tiền tố `Object.` (viết `MainContract` thay vì `Object.MainContract`).
  - Từ form module: lấy instance document object từ form attribute `Object`, gọi export method, rồi **đồng bộ lại** instance với form attribute `Object` để chuyển thay đổi lên form.
  - FillMainContractAtServer **không thể** là non-context, vì nó làm việc với form attribute (lấy instance và đồng bộ lại).
- Main attribute của form là **Object**, kết nối với một instance của object.

### Processing tabular sections
- Nên duyệt rows của tabular section **trên server**: ở client tabular section chỉ chứa phần rows đang hiển thị, phần còn lại được tải theo từng phần khi duyệt → bảng hàng trăm dòng có thể gây nhiều server calls, ảnh hưởng hiệu năng.

## Cú pháp & ví dụ code

### Danh sách compilation directives
```bsl
&AtClient
&AtServer
&AtServerNoContext
&AtClientAtServerNoContext
```

### Context server call — kiểm tra nhân viên trên 16 tuổi (document PersonnelChange)
```bsl
&AtClient

Procedure ChangesEmployeeOnChange(Item)

    CurrentData = Items.Changes.CurrentData;

    If ValueIsFilled(CurrentData.Employee) And Not EmployeeIsOldEnough(CurrentData.Employee) Then

        CurrentData.Employee = Undefined;

        MessageText = StrTemplate(

            "Employee %1 is under 16 years old on a document's date. You can't hire him",

            CurrentData.Employee

        );

        Message(MessageText);

    EndIf;

EndProcedure

&AtServer

Function EmployeeIsOldEnough(Employee)

    DateOfBirth = Employee.DateOfBirth;

    //If DateOfBirth <= AddMonth(Object.Date, -16 * 12) Then

    //  Return True;

    //Else

    //  Return False;

    //EndIf;

    // We can simplify the code above to return the result of comparison as Boolean

    Return DateOfBirth <= AddMonth(Object.Date, -16 * 12);

EndFunction
```
- Đổi `&AtServer` → `&AtServerNoContext` thì lỗi vì `Object` thành biến chưa khai báo. Cách sửa (tài liệu mô tả bằng hình): thêm parameter `Date` vào function và truyền thêm đối số ở lời gọi. [ghi chú ngoài nguồn: code sau khi sửa chỉ có trong ảnh chụp, không có dạng text trong tài liệu.] → đã bổ sung ở mục Code demo của bài Theory (nhánh lesson/07-theory).

### Ví dụ khác
- Code cho FillMainContractAtServer / FillMainContract, preprocessor commands và FileDialog chỉ xuất hiện dưới dạng ảnh trong tài liệu, không có text để trích nguyên văn. → FillMainContractAtServer / FillMainContract đã bổ sung ở mục Code demo của bài Theory (nhánh lesson/07-theory); preprocessor commands và FileDialog không có trong nhánh.

## Thuộc tính/thiết lập quan trọng trong Designer
- Thuộc tính của **common module** quyết định context thực thi (4 loại: Client, Client-server, Server call, Server).
- Event **OnChange** của form field (ví dụ field Customer) để gán handler.
- Form main attribute: **Object**.
- Các loại module: Object module, Object manager module, Record set module, Common module, Form module.

## Lỗi thường gặp / lưu ý
- Truy cập `Object`, `ThisObject`, `Items` hoặc server variables của module trong method &AtServerNoContext → lỗi biến chưa khai báo.
- Thêm parameter cho function nhưng không sửa lời gọi → platform báo không đủ actual parameters.
- Gọi client procedure từ server → không thể.
- Gọi context server method từ non-context client-server / non-context server method → không thể.
- Dùng context server call khi không cần form data → tải thêm không cần thiết.
- Đặt business logic trong form module → không chạy được khi document tạo từ code hoặc qua generation mechanism.
- Nhân bản cùng một method cho client và server → trùng lặp code; ưu tiên &AtClientAtServerNoContext.
- Trong &AtClientAtServerNoContext: không truy cập database, không tương tác người dùng.
- Duyệt tabular section lớn ở client → nhiều server calls, giảm hiệu năng.
- Khi copy code từ form module sang object module phải bỏ tham chiếu `Object.`.

## Điểm cần nhớ
- Đọc/ghi database, posting, queries, reports, chuẩn bị form: **server**. Hiển thị, tương tác người dùng, phép tính nhanh, local files, thiết bị: **client**.
- Bốn directive: &AtClient, &AtServer (mặc định khi không ghi), &AtServerNoContext, &AtClientAtServerNoContext.
- Chỉ gọi được client → server, không có chiều ngược lại.
- Ưu tiên non-context server call khi không cần form data, vì context call đóng gói toàn bộ form gửi lên server.
- Object module / manager module / record set module chạy trên server; manager module không cần instance, thường nhận reference.
- Common module: Client, Client-server, Server call (gọi được từ client), Server (chỉ từ server).
- Business logic đặt trong object module (export procedure), form module chỉ gọi lại và đồng bộ với attribute `Object`.
- Gán Undefined cho attribute = trả về giá trị mặc định của kiểu; duyệt tabular section trên server.

## Thẻ gợi ý bài thực hành (Practice 7)

> Thẻ bám theo đề "7. Practice.docx". Toàn bộ bài xoay quanh câu hỏi "code này đặt ở module nào, chạy ở client hay server" (mục Code placement và Compilation directives).

### Bài tập 1 — Attribute Discount (hợp đồng và SalesInvoice)
- **Đề bài (tóm tắt):** Thêm Discount (Number(4, 2)) vào CounterpartyContracts và vào SalesInvoice; trên form SalesInvoice field Discount phải read-only.
- **Gợi ý 1 — Hướng đi:** Discount trên chứng từ là giá trị được **điền tự động** từ hợp đồng, không cho sửa tay — chuẩn bị cho Bài tập 2.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Attribute `Discount` ở cả catalog và document (Length 4, Precision 2); trên form document đặt field và bật property **ReadOnly**.
- **Gợi ý 3 — Khung bài làm:**
  1. Thêm attribute vào catalog, nhập discount cho vài hợp đồng.
  2. Thêm attribute vào document, đặt field lên form, bật ReadOnly.
- **Lỗi hay gặp:**
  - Đặt ReadOnly ở attribute metadata thay vì ở form item, hoặc quên hẳn.
  - Length 4, Precision 2 nghĩa là tối đa 99.99 — đủ cho phần trăm, đừng đặt Precision 4.
- **Tự kiểm tra:** Form SalesInvoice có field Discount mờ, không gõ được.

### Bài tập 2 — FillDiscount trong object module
- **Đề bài (tóm tắt):** Khi đổi Contract trên SalesInvoice, điền Discount từ hợp đồng bằng procedure FillDiscount đặt trong **object module** của document (vì Contract có thể đổi từ code, không chỉ từ form).
- **Gợi ý 1 — Hướng đi:** Mẫu "business logic trong object module, form chỉ gọi lại" giống hệt FillMainContract trong phần Code demo của bài Theory: export procedure trong object module + context server call ở form dùng `FormAttributeToValue` / `ValueToFormAttribute`.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Object module của SalesInvoice: `Procedure FillDiscount() Export` — trong object module viết thẳng tên attribute (không có `Object.`). Form module: handler `&AtClient` cho event **OnChange** của field Contract → gọi một procedure `&AtServer` để chuyển `Object` thành applied object, gọi FillDiscount, rồi chuyển ngược lại.
- **Gợi ý 3 — Khung bài làm:**
  1. Viết export procedure trong object module: đọc discount từ hợp đồng, gán cho attribute Discount.
  2. Tạo handler OnChange của Contract trên form.
  3. Viết procedure server của form theo mẫu FillMainContractAtServer.
  ```bsl
  &AtServer
  Procedure OnChangeContractAtServer()
  	DocumentObject = ___;   // chuyển form attribute "Object" thành applied object
  	// gọi export procedure của object module
  	// chuyển applied object ngược về form attribute "Object"
  EndProcedure
  ```
- **Lỗi hay gặp:**
  - Viết `Object.Contract` trong object module → biến không xác định; ở đó dùng thẳng `Contract`.
  - Thiếu `Export` → form không gọi được method.
  - Đặt procedure gọi `FormAttributeToValue` là `&AtServerNoContext` → không có `Object`.
  - Quên `ValueToFormAttribute` → giá trị Discount không hiện lại trên form.
- **Tự kiểm tra:** Chọn hợp đồng có Discount 5 → field Discount trên chứng từ thành 5 ngay; đặt breakpoint trong FillDiscount để thấy nó chạy ở server.

### Bài tập 3 — Tính Amount có discount, dùng được ở client và server
- **Đề bài (tóm tắt):** Sửa procedure tính Amount của một dòng để tính cả discount của document và gọi được từ client lẫn server; tự lập công thức theo ví dụ Price 15, Quantity 10, Discount 5 → Amount 142.5; tạo method tính lại Amount cả bảng và gọi khi đổi discount.
- **Gợi ý 1 — Hướng đi:** Directive **&AtClientAtServerNoContext** (hoặc common module loại **Client-server**) cho code chạy được ở cả hai phía, với điều kiện không truy cập database, không tương tác người dùng. Discount phải truyền qua parameter vì method non-context không thấy `Object`.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Form module SalesInvoice: đổi directive của `CalculateAmountAtRow`, thêm parameter Discount; handler OnChange của Quantity/Price truyền thêm `Object.Discount`. Procedure tính lại cả bảng `&AtServer` duyệt `Object.Products`, gọi lại `CalculateAmountAtRow` cho từng dòng; gọi nó sau khi FillDiscount chạy (Bài tập 2).
- **Gợi ý 3 — Khung bài làm:**
  1. Từ ví dụ của đề suy ra công thức: 15 × 10 = 150, giảm 5% còn 142.5.
  2. Đổi directive và chữ ký procedure tính một dòng.
  3. Sửa mọi lời gọi cũ cho đủ parameter.
  4. Viết procedure server duyệt bảng và gọi lại procedure tính một dòng.
  ```bsl
  ___                                          // directive cho phép gọi từ client và server
  Procedure CalculateAmountAtRow(ProductsRow, ___)
  	ProductsRow.Amount = ___;                // Quantity × Price, trừ đi phần trăm discount
  EndProcedure
  ```
- **Lỗi hay gặp:**
  - Viết `Object.Discount` bên trong procedure `&AtClientAtServerNoContext` → lỗi biến chưa khai báo (giống ví dụ EmployeeIsOldEnough của bài).
  - Thêm parameter nhưng không sửa lời gọi cũ → "không đủ actual parameters".
  - Nhân trực tiếp với Discount (5) thay vì chia 100 → Amount sai.
  - Nhân bản hai procedure riêng cho client và server → trùng code.
- **Tự kiểm tra:** Nhập Price 15, Quantity 10 với hợp đồng Discount 5 → Amount = 142.5; đổi hợp đồng sang discount khác → mọi dòng tính lại.

### Bài tập 4 — DocumentTotal tính trên server
- **Đề bài (tóm tắt):** Chuyển việc tính DocumentTotal từ handler client ProductsOnChange sang một procedure server (hoặc gộp vào procedure tính lại Amount cả bảng, vì nó đã duyệt bảng); gọi sau khi tính lại Amount.
- **Gợi ý 1 — Hướng đi:** "Processing tabular sections": duyệt tabular section nên làm ở server để tránh nhiều server call. Gộp tính tổng vào cùng vòng lặp tính lại Amount là cách gọn nhất.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Procedure `&AtServer` (cần `Object` → context call) trong form module; handler `ProductsOnChange` (`&AtClient`) chỉ gọi procedure đó; procedure server của Bài tập 2 cũng gọi nó.
- **Gợi ý 3 — Khung bài làm:**
  1. Trong vòng lặp duyệt dòng ở server: tính Amount của dòng rồi cộng vào biến tổng.
  2. Sau vòng lặp gán tổng vào attribute của document.
  3. Thay nội dung handler ProductsOnChange bằng một lời gọi.
- **Lỗi hay gặp:**
  - Đặt procedure là `&AtServerNoContext` → không duyệt được `Object.Products`.
  - Quên gọi lại sau khi đổi hợp đồng → tổng không cập nhật theo discount mới.
  - Giữ vòng lặp cũ ở client song song → tính hai lần.
- **Tự kiểm tra:** Thêm/xóa dòng và đổi hợp đồng → DocumentTotal luôn bằng tổng các Amount; Performance snapshot (Bài 8) cho thấy chỉ một server call mỗi lần thay đổi.

### Bài tập 5 — Cảnh báo hợp đồng hết hiệu lực
- **Đề bài (tóm tắt):** Khi đổi ngày hoặc đổi hợp đồng, nếu ValidUntil của hợp đồng đã điền và nhỏ hơn ngày chứng từ thì báo "This contract is invalid on <ngày chứng từ không kèm giờ>"; ngày kết thúc lấy bằng function server không context; chỉ cảnh báo, không chặn.
- **Gợi ý 1 — Hướng đi:** **Non-context server call** (mục "Context và non-context call"): server chỉ cần reference hợp đồng để đọc ValidUntil, không cần cả form. So sánh và `Message()` ở client. Hợp đồng còn hiệu lực đến **hết** ngày ValidUntil, nên đưa ngày chứng từ về đầu ngày (hoặc ValidUntil về cuối ngày) trước khi so sánh.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Form module: procedure kiểm tra `&AtClient`; function `&AtServerNoContext` nhận hợp đồng làm parameter, trả về ngày kết thúc. Handler OnChange của field Date và field Contract cùng gọi procedure kiểm tra. Dùng `ValueIsFilled()`, `BegOfDay()` / `EndOfDay()`, `Format()` (tra format chuỗi chỉ hiện ngày trong Syntax assistant).
- **Gợi ý 3 — Khung bài làm:**
  1. Viết function server không context: input là hợp đồng, output là ValidUntil.
  2. Viết procedure client: gọi function, kiểm tra đã điền, so sánh với ngày chứng từ đã đưa về đầu ngày, báo message.
  3. Gọi procedure từ OnChange của Date và (sau phần FillDiscount) từ OnChange của Contract.
  ```bsl
  &AtServerNoContext
  Function ContractValidUntil(___)
  	Return ___;      // ngày kết thúc của hợp đồng nhận qua parameter
  EndFunction
  ```
- **Lỗi hay gặp:**
  - Dùng `Object.Contract` bên trong function `&AtServerNoContext` → phải truyền qua parameter.
  - So sánh trực tiếp hai Date có giờ → chứng từ lập trong ngày ValidUntil (sau 00:00) bị báo nhầm là hết hạn.
  - Không kiểm tra ValidUntil trống → hợp đồng vô thời hạn (date rỗng) bị báo hết hạn.
  - Message in kèm giờ vì nối thẳng Date vào chuỗi thay vì dùng `Format()`.
- **Tự kiểm tra:** Hợp đồng ValidUntil = hôm qua, chứng từ hôm nay → có cảnh báo; ValidUntil = hôm nay → không cảnh báo; ValidUntil trống → không cảnh báo; đổi ngày chứng từ cũng kích hoạt kiểm tra.

## Code demo của bài Theory (repo 1CJDCourse, nhánh lesson/07-theory)

> Nhánh lesson/07-theory là trạng thái cấu hình khi quay demo Theory Bài 7 (so với lesson/05-theory: thêm form module của PersonnelChange, FillMainContract của SalesInvoice và 4 common module rỗng). Các đoạn dưới đây là code thật đứng sau những ảnh chụp màn hình của tài liệu.

### EmployeeIsOldEnough sau khi đổi sang &AtServerNoContext (truyền thêm parameter Date)
Nguồn: nhánh lesson/07-theory — cf/Documents/PersonnelChange/Forms/DocumentForm/Ext/Form/Module.bsl
```bsl
&AtClient
Procedure ChangesEmployeeOnChange(Item)
	
	CurrentData = Items.Changes.CurrentData;
	
	If ValueIsFilled(CurrentData.Employee) And Not EmployeeIsOldEnough(CurrentData.Employee, Object.Date) Then
		CurrentData.Employee = Undefined;
		MessageText = StrTemplate(
			"Employee %1 is under 16 years old on a document's date. You can't hire him",
			CurrentData.Employee
		);
		Message(MessageText);
	EndIf;
	
EndProcedure

&AtServerNoContext
Function EmployeeIsOldEnough(Employee, Date)

	DateOfBirth = Employee.DateOfBirth;
	
	Return DateOfBirth <= AddMonth(Date, -16 * 12);
	
EndFunction
```
- Đây đúng là bản "sau khi sửa" mà tài liệu chỉ có ảnh: function thêm parameter `Date`, lời gọi ở client truyền thêm `Object.Date`.
- Trong hàm `&AtServerNoContext` không còn `Object.Date` — dùng parameter `Date`; nếu vẫn viết `Object.Date` sẽ lỗi biến chưa khai báo như bài mô tả.
- Server chỉ cần reference `Employee` (đọc `Employee.DateOfBirth`) và một ngày → non-context call, không đóng gói cả form gửi lên server.
- So với bản trong mục "Cú pháp & ví dụ code": phần comment `If ... Then Return True ...` đã được rút gọn thành `Return DateOfBirth <= AddMonth(Date, -16 * 12);`.

### FillMainContractAtServer (form module) gọi export procedure FillMainContract (object module)
Nguồn: nhánh lesson/07-theory — cf/Documents/SalesInvoice/Forms/DocumentForm/Ext/Form/Module.bsl và cf/Documents/SalesInvoice/Ext/ObjectModule.bsl
```bsl
&AtClient
Procedure CustomerOnChange(Item)
	
	FillMainContractAtServer();
	
EndProcedure

&AtServer
Procedure FillMainContractAtServer()

	DocumentObject = FormAttributeToValue("Object");
	DocumentObject.FillMainContract();
	
	ValueToFormAttribute(DocumentObject, "Object");

EndProcedure
```
```bsl
Procedure FillMainContract() Export

	If ValueIsFilled(Customer) Then
		Contract = Customer.MainContract;
	Else	
		Contract = Undefined;
	EndIf;
	
EndProcedure
```
- Đây là ví dụ Code placement của bài (trước đây chỉ có ảnh): business logic "điền hợp đồng chính của customer" nằm trong **object module** (`Export`), form module chỉ gọi lại.
- `FillMainContractAtServer` phải là `&AtServer` (context call) vì dùng `FormAttributeToValue("Object")` / `ValueToFormAttribute(DocumentObject, "Object")`.
- Trong object module viết thẳng `Customer`, `Contract` (attribute của chính object), không có `Object.`; gán `Undefined` khi chưa chọn customer → attribute trở về giá trị rỗng của kiểu.
- Handler `CustomerOnChange` gắn vào event **OnChange** của field Customer — đúng chiều gọi client → server.

### Bốn common module theo context thực thi
- Nhánh có 4 common module rỗng minh họa 4 loại trong bài, phân biệt chỉ bằng properties (cf/CommonModules/*.xml), không có code BSL:
  - `CommonClient`: Client (managed application) = true, Server = false.
  - `CommonClientServer`: Client (managed application) = true, Server = true, Server call = false.
  - `CommonServerCall`: Server = true, Server call = true (gọi được từ client).
  - `CommonServer`: Server = true, Server call = false (chỉ gọi từ server).
- [ghi chú ngoài nguồn] Nhánh lesson/07-theory không có ví dụ preprocessor commands (`#If ... #EndIf`) và không có ví dụ FileDialog.

## Video tham khảo

Video bài giảng trên YouTube có phạm vi trùng với bài này. Khi dẫn cho người học, nói "Bạn có thể tham khảo thêm về <chủ đề> của khóa tại đây: [<tên video>](link)" — không nói "khóa cũ/Junior", không dùng mã JC (mã JC trong danh sách chỉ để tra nội bộ). Quy ước đầy đủ: `references/video.md#video-junior-course`.

- [Các module và tương tác Client-Server](https://www.youtube.com/watch?v=oD8pK7RvuYw&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=29) (6:16) — Bài 7 — compilation directives, loại module, context / non-context call _(mã nội bộ JC-30)_
- [Trò chuyện với người dùng](https://www.youtube.com/watch?v=s0MHq7d_nVc&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=38) (9:26) — Bài 9 — ShowQueryBox + CallbackDescription (code mẫu); Bài 7 — dialog không chặn (CallbackDescription); Bài 21 — ShowUserNotification _(mã nội bộ JC-39)_

<!-- video-qa-thuchanh:start -->

Video giải đáp tình huống thực chiến và video thực hành từng bước liên quan tới bài này (thẻ chi tiết, triệu chứng, lưu ý khi giới thiệu: `references/video.md#video-qa-thuc-chien`, `references/video.md#video-thuc-hanh`; cùng mẫu câu dẫn ở trên):

- [Tự động lấy đơn vị tính của sản phẩm](https://www.youtube.com/watch?v=RKAGi62Vy5E&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=12) (8:16) — điền thuộc tính sản phẩm vào dòng chứng từ (giải đáp tình huống; Bài 7 chính) _(mã nội bộ QA-12)_
- [Lấy giá tự động](https://www.youtube.com/watch?v=oMowT1e019k&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=5) (8:32) — tự điền giá theo bảng giá (giải đáp tình huống; Bài 7 liên quan) _(mã nội bộ QA-5)_
- [Tạo chức năng sửa password với vai trò người dùng](https://www.youtube.com/watch?v=taKIdmcCmIQ&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=9) (26:39) — cho người dùng tự đổi mật khẩu (giải đáp tình huống; Bài 7 liên quan) _(mã nội bộ QA-9)_
- [Kiểm tra dữ liệu trùng lặp](https://www.youtube.com/watch?v=603j21ItABk&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=11) (8:55) — cảnh báo dữ liệu trùng (giải đáp tình huống; Bài 7 liên quan) _(mã nội bộ QA-11)_
- [Kết nhập file excel vào danh mục sản phẩm](https://www.youtube.com/watch?v=DlXBXRzBJGw&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=13) (38:42) — nhập dữ liệu từ Excel (giải đáp tình huống; Bài 7 liên quan) _(mã nội bộ QA-13)_
- [Truy vấn tồn kho trong chứng từ bán hàng](https://www.youtube.com/watch?v=13817kAvhwQ&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=17) (9:53) — hiển thị tồn kho khi chọn hàng (giải đáp tình huống; Bài 7 liên quan) _(mã nội bộ QA-17)_
- [Hướng dẫn publish Infobase 1C:Enterprise lên web server](https://www.youtube.com/watch?v=P_bwSfxAV8I&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=28) (7:21) — publish infobase lên web server (IIS) (giải đáp tình huống; Bài 7 liên quan) _(mã nội bộ QA-28)_
- [Giới thiệu nền tảng 1C:Enterprise](https://www.youtube.com/watch?v=Dahr2ACNN74&list=PLp-gQ5Mgw0ZybnANjTWo69eHYBDWgE-r2&index=2) (13:59) — tổng quan nền tảng 1C:Enterprise (thực hành case study; Bài 7 liên quan) _(mã nội bộ P1-1)_
- [Bắt lần khởi động đầu tiên](https://www.youtube.com/watch?v=Q9op8HgLMtM&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=9) (9:05) — xử lý lần chạy đầu tiên của ứng dụng (thực hành case study; Bài 7 liên quan) _(mã nội bộ P2-9)_

<!-- video-qa-thuchanh:end -->


---

# § bai-08

# Bài 8 — Debugging: debugger, breakpoints, step-by-step, Expression, Local variables, Call stack, Performance snapshot

## Khái niệm chính

### Debugger
- Công cụ chính để tìm và sửa lỗi; hỗ trợ phát triển và debug program modules. Khả năng:
  - debug module ở cả file và client-server version, kể cả **background jobs**
  - chạy từng bước (step by step)
  - đặt **breakpoints**
  - ngắt và tiếp tục chạy module
  - evaluate expressions để phân tích trạng thái biến
  - thay đổi giá trị biến khi debug
  - xem **call stack** của procedures/functions
  - dừng khi xảy ra lỗi
- Debug được qua **TCP/IP** và **HTTP**. Bài học chỉ dùng TCP/IP (HTTP cần cấu hình debug server). Điều kiện: giao thức mạng TCP/IP phải được bật trên hệ thống.

### Start debugging
- Từ Designer: nút **Start debugging** trên toolbar hoặc menu **Debug**, hotkey **F5**. Platform chạy client phù hợp nhất (thường là thin client).
- Chạy loại client khác: **Debug - Start debugging with -**.
- Trong khi debug đang kết nối, icon start debug đổi hình dạng. Bấm lại → cảnh báo debug đang chạy; nếu tiếp tục, session hiện tại bị kết thúc và session mới được khởi động.
- **Attach** vào session có sẵn: session phải bật debug connection. Kiểm tra trong Enterprise mode (user full rights): **Service and settings - Settings - Options**, property **Debug in current session** = **Allowed (TCP/IP)**.
- Trong Designer: **Debug - Attach for debugging…** → chọn session ở danh sách trên → **Attach**; chọn ở danh sách dưới → **Detach** để ngắt.
- Debug external connections, HTTP services, background jobs: bấm **Autoattach…**, đánh dấu loại kết nối cần, bấm **OK**.

### Breakpoints
- Breakpoint: vị trí trong module nơi việc thực thi dừng và quyền điều khiển chuyển cho debugger. Hiển thị bằng ký hiệu ở cột trái của module (ký hiệu khác nhau cho enabled/disabled).
- Đặt được ở bất kỳ dòng nào, bất kỳ lúc nào khi debug. Nếu dòng không có operator (dòng trống), chứa text không thực thi (header procedure/function, khai báo biến), hoặc là phần tiếp nối của operator dòng trên → vị trí breakpoint **tự động điều chỉnh**.
- Đặt/xóa bằng chuột: **double-click vùng xám** của dòng.
- Breakpoints được **lưu khi đóng configuration**. Xem danh sách: **Debug - Breakpoint list** (cột On/Off, module name, row).

| Command | Mô tả |
| --- | --- |
| Breakpoint | Đặt hoặc xóa breakpoint tại dòng con trỏ |
| Breakpoint with the condition | Đặt breakpoint và mở hộp thoại nhập điều kiện (logical expression); chỉ dừng khi điều kiện thỏa |
| Disable breakpoint | Bật/tắt breakpoint (khi dòng hiện tại có breakpoint) |
| Remove all breakpoints | Xóa mọi breakpoint ở mọi module |
| Disable all breakpoints | Tắt mọi breakpoint ở mọi module, không xóa |
| Breakpoint list | Xem và quản lý breakpoints |
| Stop on Error | Khi có lỗi, debugger dừng và chuyển tới dòng gây lỗi |

### Step-by-step execution
- Khi debug item đầu tiên được attach, hệ thống thêm các lệnh quản lý debug vào menu Debug.

| Command | Mô tả |
| --- | --- |
| Step In | Nếu operator kế tiếp là lời gọi procedure/function → đi vào từng bước bên trong; nếu không → sang operator kế |
| Step Over | Nếu là lời gọi → chạy trọn (không từng bước), sang operator kế |
| Step Out | Ngắt chạy từng bước của procedure/function hiện tại, dừng ở operator đầu tiên sau lời gọi |
| Go to Cursor | Chạy mọi lệnh tới dòng có con trỏ |
| Continue | Thoát chế độ từng bước, chạy tự do (tới breakpoint kế tiếp) |

- **Debug - Continue Debugging**: chạy tự do cho các debug item đã attach; client application được attach sẽ tự kích hoạt.
- Ngắt toàn bộ quá trình debug (trừ background jobs): xóa mọi breakpoint rồi chạy **Debug - Continue Debugging** (nếu breakpoint đã kích hoạt).
- Ngắt debug và kết thúc các debug item: **Debug - Finish** → khi đó `BeforeExit()` và `OnExit()` **không được chạy**.
- Có thể sửa và lưu configuration khi debug, nhưng debugger **không compile code đã sửa** — vẫn debug theo database configuration lúc bắt đầu/attach. Muốn debug thay đổi → phải **update database configuration**.
- Bảng phím tắt debugger có trong Help.

### Debug management (các lệnh còn lại trong menu Debug)
- **Restart**: dừng và khởi động lại ở 1C:Enterprise mode; nếu configuration đã sửa → nhắc update database configuration.
- **Break**: dừng module và kết thúc debug item hiện tại.
- **Stop**: dừng tại operator hiện tại; dùng để bắt đầu debug từ dòng thực thi kế tiếp; hữu ích để phân tích module bị "cycling" (lặp vô hạn).
- **Stop on errors**: mở hộp thoại thiết lập "stop on error".
  - Checkbox **Stop on error**: có dừng khi lỗi hay không. Khi dừng → cảnh báo *Runtime error* kèm vị trí và nguyên nhân.
  - Checkbox **Stop on errors that include specific text**: chỉ dừng nếu thông báo lỗi chứa substring trong bảng (substring chỉ được xét khi đánh dấu checkbox cạnh nó). Không chọn → dừng với mọi lỗi.
  - Tại chỗ lỗi, execution point được đặt và debug item gây lỗi thành item hiện tại.

### "Expression" window
- Mở bằng **Debug - Evaluate expression**, hoặc **Evaluate expression** trong context menu (right click), hoặc hotkey **Shift+F9**.
- Nhập biểu thức 1C:Enterprise language vào field **Expression** (tay hoặc chọn từ danh sách đã dùng). Nếu con trỏ đặt trên/đã chọn biểu thức → tự điền.
- Bấm **Evaluate** → kết quả ở field **Value**.
- Biểu thức được tính trong **hệ thống thật** → có thể có side effect (ví dụ biểu thức tạo item trong infobase nếu chưa có sẽ chỉ tạo một lần, vì lần sau item đã tồn tại thật).
- Nút **Add to immediate …**: đưa biểu thức vào immediate window (dòng mới) để theo dõi thay đổi; tự mở immediate window nếu chưa có.
- Với String, array hoặc collection → nút **Show value in a new window** khả dụng (hoặc context menu, phím **F2**):
  - String: cửa sổ multiline, copy được ra clipboard.
  - Collection/array: bảng, cột = tên attribute, row = giá trị; hiện số phần tử, cột đầu là index.
- Nút **Output list**: xuất bảng kết quả ra text hoặc spreadsheet document; với cây chỉ xuất các nhánh đang mở.
- Rê chuột lên biểu thức → tooltip giá trị hiện tại (nếu có textual representation); dùng được cho property.
- Có thể evaluate cả **code đã comment**; có thể chọn một phần biểu thức để tính riêng (ví dụ `Products[0]`).

### "Local variables" window
- Mở: **Debug - Local Variables** (khi đang debug).
- Chứa parameters của method đang debug và mọi local variable ở mức call stack hiện tại (mặc định đỉnh stack). Ban đầu biến ở trạng thái uninitialized; giá trị hiện khi được gán.
- Không sửa được cột Variable; không sửa được thành phần các rows.
- Tự cập nhật sau mỗi thao tác debug (đổi call stack, đổi debug item...).
- Context menu cột Value: **Copy result**. Một số kiểu xem được ở cửa sổ riêng.
- Immediate window có thể xuất ra spreadsheet hoặc text document.
- Cửa sổ tự đóng khi kết thúc debug.

### Variable value change
- Khi dừng ở breakpoint, có thể đổi giá trị biến và property object có quyền ghi — từ expressions window, immediate window, local variables window.
- Trong expressions window: rê chuột lên biến, bấm nút **Set expression as a value** (hình "f(x)") → cửa sổ nhập biểu thức (header là tên biến). Có thể nhập hằng số các kiểu hoặc biểu thức hợp lệ; có context help theo context method hiện tại.
- Bấm **Set** → kết quả hiện ở dưới: "The value is changed." hoặc thông báo lỗi.
- Trong immediate/local variables window: context menu → **Set expression as a value**. "Variable" bao gồm cả property của collection (lồng nhau tùy ý).

### Call stack
- Hiển thị chuỗi lời gọi procedure/function dẫn tới dòng đang debug. Cột: **Name** (method), **Line** (số dòng), **Item** (debug item chứa module).
- Icon cột đầu:
  - **Mũi tên vàng**: đỉnh call stack.
  - **Mũi tên xanh lá**: method mà context đó dùng để tính biến trong Expression window và Immediate window. Không hiện nếu đỉnh stack trùng context hiện tại.
- Double-click một row để đổi context và đặt con trỏ tới dòng tương ứng. Biến chỉ có giá trị trong context method khai báo nó (ví dụ TotalWeight trong CalculateWeightAtServer()).
- Row màu **xám**: chuyển tới dòng được nhưng **không evaluate** được biểu thức trong context đó — đó là các item "nằm" trên client khi đỉnh stack "nằm" trên server.

### Performance snapshot
- Đánh giá hiệu năng toàn configuration hoặc một phần, trong debug item bất kỳ: tần suất dùng và tốc độ từng đoạn code; code chạy ở server hay client; dòng nào gây server call. Có thể hiện thực nhiều cách giải rồi chọn cách nhanh nhất.
- So sánh phải trong **cùng điều kiện** (CPU bận việc khác ảnh hưởng kết quả); khi hai cách có hiệu năng gần nhau → chụp nhiều snapshot cho mỗi cách và lấy trung bình.
- Dùng **Performance meter** (menu Debug hoặc command bar). Chọn lại lần nữa → dừng đo và mở cửa sổ kết quả. Bật/tắt ảnh hưởng mọi debug item đang attach.
- Các phương án:
  1. Đo cả phần khởi động: chạy **Debug - Performance Snapshot** trước, rồi mới khởi động 1C:Enterprise (thời gian từ lúc bắt đầu đo tới lúc hệ thống chạy không tính).
  2. Không đo phần khởi động: khởi động 1C:Enterprise, chuẩn bị tới đoạn cần đo, sang Designer bật snapshot.
  - Đo cả phần shutdown: tắt chương trình rồi sang Designer — không cần dừng đo thủ công, kết quả tự hiện.
  - Không đo shutdown: dừng snapshot thủ công để xem kết quả. Ví dụ phân tích posting document: mở chương trình, mở và điền document, sang Designer bật snapshot, sang Enterprise post document, sang Designer kết thúc snapshot.

### Measurement results
- Bảng các cột:
  - **Module** — tên module
  - **Row number** — số dòng
  - **Line** — text của dòng
  - **Col.** — số lần gọi dòng này
  - **Time (net)** — tổng thời gian (giây) của dòng
  - **%(Time) (net)** — phần trăm trên tổng thời gian snapshot (100% là thực thi code trên client)
  - **Client** — icon đánh dấu dòng chạy trên client
  - **Server** — icon đánh dấu dòng chạy trên server
  - **Server proc.** (server processing) — icon dòng khởi tạo server call: **Direct server call** (gọi server ở mức platform hoặc gọi trực tiếp method server) và **Nested server call** (gọi local method client mà bên trong có server call).
- Checkbox **Track execution for procedures and functions**: chọn → thời gian = full time (call time + net time); bỏ chọn → chỉ thời gian của chính dòng ("net time"), không gồm thời gian procedure/function được gọi. Mặc định được chọn, trạng thái lưu giữa các session; đổi trạng thái thì header các cột thời gian đổi theo.
- Checkbox **Client** / **Server** (góc dưới phải) để hiển thị kết quả đo ở client, server hoặc cả hai — chỉ hiện khi debug server infobase / server debug item.
- Nhiều cửa sổ kết quả: rê chuột lên cột kết quả → tooltip URL file dữ liệu.
- Khi cửa sổ snapshot mở, module window có thêm cột số lần gọi và % thời gian (kèm icon client/server/server call); mở nhiều kết quả → nhiều cột; đóng cửa sổ kết quả → cột biến mất.
- Double-click dòng trong kết quả → nhảy tới dòng trong module (và ngược lại từ cột kết quả trong module editor).
- Sort theo cột bằng click header: Module/Row number → theo số dòng; Col. → theo số lần gọi; Time/%(Time) → theo thời gian; nếu đo cả client và server thì sort được theo các cột đó.

## Cú pháp & ví dụ code
- Tài liệu bài 8 không có ví dụ code 1C dạng text (các ví dụ chỉ ở dạng ảnh chụp màn hình). → đã bổ sung ở mục Code demo của bài Theory (nhánh lesson/08-theory).
- Các procedure được nhắc tên: `BeforeExit()`, `OnExit()` (không chạy khi dùng Debug - Finish); method ví dụ trong call stack: `Document.SalesInvoice.Form.DocumentForm.CalculateWeightAtServer()`; biểu thức ví dụ: `Products[0]`.

## Thuộc tính/thiết lập quan trọng trong Designer
- Menu **Debug**: Start debugging (**F5**), Start debugging with, Attach for debugging…, Autoattach…, Breakpoint, Breakpoint with the condition, Disable breakpoint, Remove all breakpoints, Disable all breakpoints, Breakpoint list, Stop on Error, Step In, Step Over, Step Out, Go to Cursor, Continue / Continue Debugging, Finish, Restart, Break, Stop, Stop on errors, Evaluate expression (**Shift+F9**), Local Variables, Performance meter / Performance Snapshot.
- Enterprise mode: **Service and settings - Settings - Options** → **Debug in current session** = **Allowed (TCP/IP)**.
- Hộp thoại Stop on errors: **Stop on error**, **Stop on errors that include specific text**.
- Expression window: field **Expression**, **Value**, nút **Evaluate**, **Add to immediate …**, **Show value in a new window** (F2), **Output list**, **Set expression as a value** (f(x)), **Set**.
- Local variables: **Copy result**.
- Performance snapshot: **Track execution for procedures and functions**, checkbox **Client** / **Server**.

## Lỗi thường gặp / lưu ý
- Sửa code khi đang debug nhưng không update database configuration → debugger vẫn chạy code cũ.
- **Debug - Finish** bỏ qua `BeforeExit()` và `OnExit()`.
- Bấm Start debugging khi đang debug → session hiện tại bị kết thúc.
- Attach không được nếu session chưa bật **Debug in current session = Allowed (TCP/IP)**.
- Evaluate expression chạy trên hệ thống thật → có side effect (ví dụ tạo dữ liệu trong infobase).
- Row xám trong Call stack: không evaluate được biểu thức (context client khi đỉnh stack ở server).
- Biến chỉ evaluate được trong context method chứa nó (đổi context → "not defined").
- Bỏ chọn **Track execution for procedures and functions** → Time không phản ánh thời gian thực của dòng có gọi method.
- So sánh hiệu năng phải cùng điều kiện; chạy nhiều snapshot và lấy trung bình.
- Debug qua TCP/IP yêu cầu TCP/IP bật trên hệ thống.

## Điểm cần nhớ
- F5 = Start debugging; Shift+F9 = Evaluate expression; F2 = Show value in a new window; double-click vùng xám = đặt/xóa breakpoint.
- Attach vào session cần **Debug in current session = Allowed (TCP/IP)**; dùng Autoattach cho background jobs, HTTP services, external connections.
- Breakpoint with the condition chỉ dừng khi điều kiện đúng; Stop on Error dừng tại dòng gây lỗi (có thể lọc theo text lỗi).
- Step In (vào trong), Step Over (chạy trọn), Step Out (ra ngoài), Go to Cursor, Continue.
- Thay đổi code khi debug cần update database configuration mới có hiệu lực.
- Có thể đổi giá trị biến khi dừng bằng **Set expression as a value**.
- Call stack: mũi tên vàng = đỉnh stack, xanh lá = context đang evaluate; row xám = không evaluate được.
- Performance snapshot cho biết số lần gọi, thời gian, client/server và dòng gây server call (Direct / Nested).

## Thẻ gợi ý bài thực hành (Practice 8)

> Thẻ bám theo đề "8. Practice.docx". Bài này chủ yếu là thao tác với debugger; phần code của form FormForDebugTest được **đề bài cho sẵn** (bạn chép từ file đề), nhiệm vụ là dùng debugger để tìm lỗi và quan sát.

### Bài tập 1 — Breakpoint cơ bản
- **Đề bài (tóm tắt):** Đặt breakpoint, start debugging và kiểm tra code dừng tại đó.
- **Gợi ý 1 — Hướng đi:** Mục "Breakpoints" và "Start debugging" của bài.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Double-click vùng xám bên trái dòng code (hoặc Debug → Breakpoint); **F5** = Start debugging.
- **Gợi ý 3 — Khung bài làm:**
  1. Chọn một handler client đã có (ví dụ OnChange của cột Quantity trong SalesInvoice).
  2. Đặt breakpoint ở dòng có operator.
  3. F5, thao tác ở Enterprise mode để handler chạy.
- **Lỗi hay gặp:**
  - Đặt breakpoint trên dòng trống/dòng `Procedure` → platform dời sang dòng có operator gần nhất.
  - Sửa code mà chưa update database configuration → debugger chạy code cũ.
- **Tự kiểm tra:** Designer bật lên, mũi tên vàng nằm ở dòng có breakpoint.

### Bài tập 2 — Breakpoint bị disable
- **Đề bài (tóm tắt):** Đặt breakpoint thứ hai sau breakpoint đầu và disable nó; tiếp tục debug (Continue / F5) từ breakpoint đầu và kiểm tra code không dừng ở breakpoint đã disable.
- **Gợi ý 1 — Hướng đi:** Breakpoint disable vẫn được giữ trong danh sách nhưng không dừng.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Debug → **Disable breakpoint**; **Breakpoint list** để xem trạng thái; Continue debugging (F5).
- **Gợi ý 3 — Khung bài làm:**
  1. Đặt breakpoint thứ hai cùng procedure, phía dưới.
  2. Disable nó.
  3. Chạy tới breakpoint đầu, bấm F5.
- **Lỗi hay gặp:**
  - Xóa breakpoint thay vì disable — đề muốn quan sát trạng thái disable.
  - Bấm Start debugging thay vì Continue khi đang debug → kết thúc session hiện tại.
- **Tự kiểm tra:** Code chạy hết procedure, không dừng ở breakpoint thứ hai; Breakpoint list hiện nó ở trạng thái tắt.

### Bài tập 3 — Conditional breakpoint
- **Đề bài (tóm tắt):** Đặt breakpoint có điều kiện, nên thử trong vòng lặp qua collection để điều kiện chỉ đúng ở một số dòng.
- **Gợi ý 1 — Hướng đi:** **Breakpoint with the condition** chỉ dừng khi biểu thức điều kiện đúng.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Debug → Breakpoint with the condition; nơi phù hợp: vòng `While` trong procedure FillProducts (code đề cho), điều kiện dựa trên biến đếm dòng; hoặc vòng duyệt tabular section ở server trong SalesInvoice.
- **Gợi ý 3 — Khung bài làm:**
  1. Chọn dòng bên trong thân vòng lặp.
  2. Đặt breakpoint có điều kiện dùng một biến thay đổi theo từng vòng.
  3. Chạy và kiểm tra giá trị biến khi dừng.
- **Lỗi hay gặp:**
  - Điều kiện dùng biến chưa tồn tại ở dòng đó → không bao giờ dừng.
  - Đặt breakpoint ngoài vòng lặp → chỉ dừng một lần, không thấy tác dụng của điều kiện.
- **Tự kiểm tra:** Debugger dừng đúng ở vòng có điều kiện đúng; Local variables cho thấy biến đếm đúng giá trị điều kiện.

### Bài tập 4 — Step In / Step Out / Step Over
- **Đề bài (tóm tắt):** Tự dùng ba lệnh step với các lời gọi lồng nhau.
- **Gợi ý 1 — Hướng đi:** Mục "Step-by-step execution": Step In vào trong method được gọi, Step Over chạy trọn method, Step Out chạy nốt method hiện tại rồi quay về nơi gọi.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Menu Debug (hoặc phím tắt); chuỗi gọi phù hợp: handler client CreateSalesInvoice → CreateSalesInvoiceAtServer → NewCustomer / NewContract / FillProducts. Mở **Call stack** để thấy các tầng.
- **Gợi ý 3 — Khung bài làm:**
  1. Breakpoint ở handler client CreateSalesInvoice.
  2. Step In vào procedure server, Step In tiếp vào NewCustomer.
  3. Step Out để quay lại; ở dòng NewContract dùng Step Over.
- **Lỗi hay gặp:**
  - Step In tại dòng không gọi method → chỉ đi tiếp một dòng như Step Over.
  - Muốn evaluate biến client khi đỉnh stack ở server → row client màu xám, không evaluate được.
- **Tự kiểm tra:** Call stack lúc ở trong NewContract có 3 tầng (NewContract ← CreateSalesInvoiceAtServer ← CreateSalesInvoice).

### Bài tập 5 — Đổi giá trị biến khi debug (SendMessage)
- **Đề bài (tóm tắt):** Tạo common form FormForDebugTest (thuộc MasterData), command SendMessage có handler client với đoạn code đề cho; khi debug, đổi biến để điều kiện đúng, sau đó đổi lần nữa để message là "Number is two, not one!".
- **Gợi ý 1 — Hướng đi:** Mục "Variable value change": dùng **Set expression as a value** trong Expression window hoặc Local variables. Biến 1C có kiểu động, nên có thể gán cả giá trị kiểu khác.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Common form + form command `SendMessage` (Action `&AtClient`), kéo lên form thành button; chép đoạn code của đề vào handler. Evaluate expression (Shift+F9), nút f(x) Set.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo form, command, button, chép code đề cho.
  2. Breakpoint ở dòng `If`; khi dừng, gán giá trị khiến điều kiện đúng.
  3. Step Over vào nhánh trong; khi đứng ở dòng `Message`, gán lại biến thành chuỗi phù hợp để message ra đúng câu của đề.
- **Lỗi hay gặp:**
  - Đổi giá trị **sau** khi dòng `If` đã chạy → không vào nhánh được nữa.
  - Gán số 2 lần thứ hai → message vẫn là "Number is 2".
  - Gán chuỗi không có khoảng trắng/dấu phẩy đúng → message lệch câu yêu cầu.
- **Tự kiểm tra:** Enterprise mode hiện đúng "Number is two, not one!".

### Bài tập 6 — Tìm lỗi trong CreateSalesInvoiceAtServer (Try/Except, ErrorInfo)
- **Đề bài (tóm tắt):** Thêm command CreateSalesInvoice (handler client gọi CreateSalesInvoiceAtServer), chép code đề cho vào form module, bấm nút → gặp lỗi chung chung; dùng debugger và Local variables để tìm nguyên nhân; thử evaluate `DetailErrorDescription(ErrorInfo())` trong khối Except.
- **Gợi ý 1 — Hướng đi:** Khối `Try ... Except` "nuốt" lỗi thật và `Raise` một thông báo chung, nên message trên màn hình không giúp gì. Dùng **Stop on Error** (dừng ngay tại dòng gây lỗi trước khi nhảy sang Except) hoặc Step Over từng dòng trong `Try`.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Debug → Stop on errors; Expression window; Local variables; dòng comment gán `ErrorText` trong khối Except của code đề cho.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo command + handler client gọi procedure server; chép 4 method của đề.
  2. Bật Stop on Error, bấm nút → ghi lại dòng debugger dừng và nội dung lỗi.
  3. Đối chiếu với object module của SalesInvoice: method được gọi ở dòng đó có tồn tại không?
  4. Thử evaluate biểu thức lỗi trực tiếp trong Except, rồi bỏ comment dòng gán vào biến và xem lại.
  5. Sửa lỗi theo cách hợp lý (bỏ lời gọi không hợp lệ hoặc tự viết method còn thiếu).
- **Lỗi hay gặp:**
  - Chỉ đọc message "An error occurred while creating the document" và đoán mò.
  - Evaluate `DetailErrorDescription(ErrorInfo())` trực tiếp → rỗng; theo đề, `ErrorInfo()` chỉ cho kết quả khi gán vào biến.
  - Evaluate expression chạy trên hệ thống thật → có thể tạo thêm dữ liệu (ví dụ Counterparty) ngoài ý muốn.
  - [ghi chú ngoài nguồn] Ngay cả khi hết lỗi, procedure của đề không gọi ghi document, nên chứng từ không xuất hiện trong danh sách; chỉ Customer và Contract mới được ghi. Đề không yêu cầu ghi chứng từ, nhưng hãy nhận ra điều này khi debug.
- **Tự kiểm tra:** Sau khi sửa, bấm nút không còn lỗi; trong Local variables của CreateSalesInvoiceAtServer thấy `Document` có 3 dòng Products; danh sách Counterparties có thêm item mới (không tên).

### Bài tập 7 — Performance snapshot
- **Đề bài (tóm tắt):** Sau khi sửa lỗi, đo hiệu năng từ handler command client; sort theo các cột; chuyển qua lại giữa cửa sổ kết quả và module bằng double-click.
- **Gợi ý 1 — Hướng đi:** Mục "Performance snapshot" và "Measurement results": số lần gọi, thời gian, client/server, dòng gây server call.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Debug → Performance meter / Performance Snapshot; bật **Track execution for procedures and functions**; checkbox Client/Server; click header để sort.
- **Gợi ý 3 — Khung bài làm:**
  1. Bật đo, bấm nút CreateSalesInvoice, tắt đo.
  2. Sort theo Col. (số lần gọi) và theo Time.
  3. Double-click một dòng kết quả → nhảy vào module; double-click cột kết quả trong module → quay lại.
- **Lỗi hay gặp:**
  - Tắt Track execution → thời gian dòng có gọi method không phản ánh thực tế.
  - So sánh hai lần đo trong điều kiện khác nhau; nên đo vài lần và lấy trung bình.
- **Tự kiểm tra:** Dòng trong vòng `While` của FillProducts có số lần gọi bằng số product được thêm; dòng handler client gọi procedure server được đánh dấu là server call.

## Code demo của bài Theory (repo 1CJDCourse, nhánh lesson/08-theory)

> So với lesson/07-theory, nhánh lesson/08-theory chỉ thêm một đoạn code vào form module của SalesInvoice: tính Amount của dòng ở client và tính tổng trọng lượng ở server. Đây chính là code được debug trong các ảnh chụp của Bài 8 (call stack `Document.SalesInvoice.Form.DocumentForm.CalculateWeightAtServer()`, biến `TotalWeight`).

### Client: tính Amount của dòng hiện tại
Nguồn: nhánh lesson/08-theory — cf/Documents/SalesInvoice/Forms/DocumentForm/Ext/Form/Module.bsl
```bsl
&AtClient
Procedure ProductsQuantityOnChange(Item)
	
	FillAmountInProductsRow();
	OnProductOrQuantityChange();
	
EndProcedure

&AtClient
Procedure ProductsPriceOnChange(Item)
	FillAmountInProductsRow();
EndProcedure

&AtClient
Procedure FillAmountInProductsRow()

	CurrentData = Items.Products.CurrentData;
	If CurrentData = Undefined Then
		Return;
	EndIf;
	
	CurrentData.Amount = CurrentData.Price * CurrentData.Quantity;
	
EndProcedure
```
- Đặt breakpoint ở dòng `CurrentData.Amount = ...`, mở **Evaluate expression** (Shift+F9) để xem `CurrentData.Price`, `CurrentData.Quantity`; có thể dùng **Set expression as a value** để đổi giá trị trước khi dòng chạy.
- `ProductsQuantityOnChange` gọi hai procedure liên tiếp → chỗ luyện **Step In** (vào `FillAmountInProductsRow`) và **Step Over** (chạy trọn).
- Toàn bộ đoạn này chạy ở client (`&AtClient`) — trong kết quả Performance snapshot các dòng này được đánh dấu cột **Client**.

### Client → server: CalculateWeightAtServer và WeightOfProduct (call stack, Local variables)
Nguồn: nhánh lesson/08-theory — cf/Documents/SalesInvoice/Forms/DocumentForm/Ext/Form/Module.bsl
```bsl
&AtClient
Procedure ProductsProductOnChange(Item)
	OnProductOrQuantityChange();
EndProcedure

&AtClient
Procedure OnProductOrQuantityChange()

	CalculateWeightAtServer();

EndProcedure

&AtServer
Procedure CalculateWeightAtServer()

	TotalWeight = 0;
	For Each ProductsRow In Object.Products Do
	
		TotalWeight = TotalWeight + WeightOfProduct(ProductsRow.Product) * ProductsRow.Quantity;
	
	EndDo;

EndProcedure

&AtServerNoContext
Function WeightOfProduct(Product)

	Return Product.Weight;

EndFunction
```
- Dừng trong `WeightOfProduct` rồi mở **Call stack**: đỉnh stack là `WeightOfProduct`, bên dưới là `CalculateWeightAtServer` (server), rồi `OnProductOrQuantityChange` và `ProductsProductOnChange`/`ProductsQuantityOnChange` (client) — các row client hiện màu **xám**, chuyển tới dòng được nhưng không evaluate được biểu thức.
- `TotalWeight` là biến local của `CalculateWeightAtServer`: double-click row đó trong Call stack mới evaluate được; ở context `WeightOfProduct` biến này "not defined" — đúng ví dụ trong bài.
- **Local variables** của `CalculateWeightAtServer` hiển thị `TotalWeight` và `ProductsRow`; đặt **Breakpoint with the condition** trong vòng `For Each` (ví dụ `ProductsRow.Quantity > 10`) để chỉ dừng ở dòng cần xem.
- Performance snapshot: dòng `CalculateWeightAtServer();` trong `OnProductOrQuantityChange` là **Direct server call**; dòng gọi `OnProductOrQuantityChange()` trong handler là **Nested server call**. `WeightOfProduct` được gọi từ server nên không tạo thêm server call.
- [ghi chú ngoài nguồn] `TotalWeight` chỉ là biến local, không được ghi vào attribute nào — code demo phục vụ debug, không phải nghiệp vụ hoàn chỉnh.

## Video tham khảo

Video bài giảng trên YouTube có phạm vi trùng với bài này. Khi dẫn cho người học, nói "Bạn có thể tham khảo thêm về <chủ đề> của khóa tại đây: [<tên video>](link)" — không nói "khóa cũ/Junior", không dùng mã JC (mã JC trong danh sách chỉ để tra nội bộ). Quy ước đầy đủ: `references/video.md#video-junior-course`.

Không có video bài giảng tương ứng — chỉ dẫn tài liệu Theory/Practice của bài.

<!-- video-qa-thuchanh:start -->

Video giải đáp tình huống thực chiến và video thực hành từng bước liên quan tới bài này (thẻ chi tiết, triệu chứng, lưu ý khi giới thiệu: `references/video.md#video-qa-thuc-chien`, `references/video.md#video-thuc-hanh`; cùng mẫu câu dẫn ở trên):

- [Fix lỗi không tính toán Thành tiền khi thay đổi Số lượng](https://www.youtube.com/watch?v=LRRNf8MxoQw&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=1) (4:24) — cách tìm lỗi sự kiện OnChange không chạy (giải đáp tình huống; Bài 8 liên quan) _(mã nội bộ QA-1)_

<!-- video-qa-thuchanh:end -->


---

# § bai-09

# Bài 9 — Subsystems, Panels, Forms (attributes, parameters, commands, items, groups, conditional appearance), Home page

## Khái niệm chính

### Subsystems
- **Subsystem** là khối cơ bản để xây giao diện 1C:Enterprise → việc đầu tiên khi phát triển configuration là thiết kế thành phần các subsystem, rồi gắn configuration objects vào subsystem một cách chính xác, có ý nghĩa.
- Ứng dụng đơn giản có thể không dùng subsystem, nhưng khuyến nghị **luôn dùng**: ngoài xây giao diện, Subsystem còn mô tả các phần chức năng (logical parts) của applied solution.
- Hai cấp: **top-level** (là các section chính của giao diện) và **subordinate**.
- Subordinate subsystems **không hiển thị trong Current section functions panel**; chỉ thấy khi click lại vào section đang mở.
- Mỗi configuration object có thể nằm trong **một hoặc nhiều** subsystem (khả dụng ở mỗi subsystem được chọn).
- Subsystems kết hợp với visibility theo roles → giao diện gọn, người dùng chỉ thấy các section cần cho công việc (ví dụ thủ kho chỉ cần nhập/xuất hàng).
- Ngay cả ứng dụng nhỏ cũng cần nhiều subsystem (ví dụ Accounting, Sales, Purchases, Warehouses, và một subsystem chỉ cho administrator).

### Subsystem properties
- **Include in the command interface**: subsystem có hiển thị trong giao diện không. Một số subsystem chỉ dùng để phân nhóm chức năng metadata, không cần hiển thị.
- **Explanation**: hiển thị thông tin subsystem dạng tooltip khi rê chuột.
- **Picture**: ảnh subsystem trong giao diện; **chỉ hiển thị cho top-level subsystems**.
  - Nếu có ít nhất một ảnh cao hơn 48 pixel → mọi ảnh như vậy thu nhỏ tỷ lệ về 48 pixel chiều cao.
  - Nếu mọi ảnh trong sections panel thấp hơn 48 pixel → chiều cao panel tính theo ảnh cao nhất; ảnh nhỏ hơn được căn giữa.
  - Thêm ảnh: Picture → nút chọn → cửa sổ **Select picture**, tab **From configuration** → **Add** → platform tạo configuration object **Common picture** và mở editor → **Load from file** → chọn file → nhập **Name** → đóng editor → chọn ảnh trong Select picture → **OK**. Ảnh xuất hiện trong nhánh **Common pictures** của cây configuration.
  - Trong giao diện, **synonym** của subsystem là tên section, ảnh hiện cạnh tên. Không có ảnh → dùng ảnh mặc định.
- Tab **Content**: thêm/bớt objects khỏi subsystem.

### Panels
- Developer cấu hình bố cục panel mặc định cho mọi người dùng; mỗi người dùng có thể tự thay đổi thành phần và vị trí.
- Sửa thành phần panel: lệnh **Open client application interface** trong context menu của configuration. Mặc định configuration mới: **Sections panel** ở trên, dưới là **Current section functions panel**.
- Trong Enterprise mode, thêm/bớt panel bằng **kéo thả**.
- **Sections panel**: hiển thị các section chính (top-level subsystems). Section **Quick menu** tự tạo, chứa documents, reports... hay dùng.
- **Current section functions panel**: hiển thị objects và commands của subsystem đang chọn; chưa chọn thì trống. Thường bị tắt vì không chia theo subordinate subsystems và các section "reports", "service" (platform tự tạo khi subsystem có reports và data processors).
- **Open items panel**: danh sách mọi form đang mở (như tab trình duyệt).
- **Favorites bar**: các mục người dùng đánh dấu sao (ngôi sao cạnh header form). Có thể sửa danh sách (attach/detach, rename, đổi thứ tự bằng kéo, xóa).
- **History panel**: lịch sử form mở gần đây; click icon đồng hồ → danh sách chi tiết ngày giờ, mở lại form, quản lý favorites.
- Tìm kiếm: **Ctrl + F** để tới ô search.

### Forms — tổng quan
- Form: object để nhập, xem thông tin và quản lý các quy trình.
- Phần hiển thị mô tả bằng **cây form items**: input fields, check boxes, radio buttons, buttons...; item có thể là **group** (framed panel, panel có pages/tabs, page, command bar) hoặc **table** (chứa columns).
- Chức năng form mô tả bằng **attributes** (dữ liệu form xử lý) và **commands** (hành động form thực hiện).
- Hệ thống có thể tự tạo form cho applied object; developer cũng có thể tự tạo. Hệ thống tự sắp xếp giao diện theo mô tả logic (có xét kiểu dữ liệu); developer tinh chỉnh thứ tự, width, height.
- Form dùng được commands của chính nó và **global commands** của command interface; có thể tạo configurable commands mở form khác theo dữ liệu form hiện tại (ví dụ báo cáo tồn kho của warehouse đang chọn trong sales invoice).
- Có thể gắn user messages vào form data → hệ thống đánh dấu và kích hoạt control người dùng nhập sai.
- Form tự xét quyền theo role: attribute không được xem → control liên quan tự bị gỡ, form được dựng lại.
- Form editor (Designer) định nghĩa: **Form attributes**, **Form commands**, **Form parameters**, **Form module**, **Form items**, **Command interface**.
- **Lưu ý: form tồn tại đồng thời ở cả server và client.**

### Form attributes
- Tập attributes = **form data**: dữ liệu hiển thị, sửa, lưu trong form. Bản thân attribute không hiển thị/sửa dữ liệu — form controls gắn với attribute làm việc đó.
- **Mọi form data phải mô tả bằng form attributes**; không được dùng biến của form module làm nguồn dữ liệu cho form controls.
- Availability attribute có thể cấu hình bằng functional options (học sau).
- **Main attribute**: quyết định chức năng chuẩn của form (**form extension**). **Form chỉ có một main attribute.**
- Form extension = các properties, methods, form parameters bổ sung của object **ClientApplicationForm** đặc thù theo kiểu main attribute.
- Các nhóm kiểu dữ liệu form dùng:
  - Kiểu dùng trực tiếp (hỗ trợ cả thin client và web client): ví dụ Number, CatalogRef.Items, GraphicalSchema, SpreadsheetDocument.
  - Kiểu được chuyển sang form data types — hiển thị trong ngoặc, ví dụ `(CatalogObject.Items)`.
  - **Dynamic list**: kiểu đặc biệt hiển thị dữ liệu tùy ý từ bảng database (chỉ định bảng hoặc mô tả bằng query language); dựa trên data composition system; hỗ trợ sort, selection, search, grouping, conditional appearance.
- Một số applied types (CatalogObject...) không có ở thin/web client → platform có form data types riêng, phải chuyển đổi applied objects ↔ form data:
  - **FormDataStructure**: tập attributes kiểu tùy ý (có thể chứa structures, collections). Ví dụ đại diện CatalogObject trong form.
  - **FormDataCollection**: danh sách có kiểu giống array, truy cập theo index hoặc ID. Với collection từ register record sets hoặc object tables, field **LineNumber** không tương ứng index thật. Đôi khi không truy cập được theo ID. ID có thể là số nguyên bất kỳ. Đại diện table trong form.
  - **FormDataStructureAndCollection**: vừa là structure vừa là collection. Ví dụ đại diện record set.
  - **FormDataTree**: lưu dữ liệu phân cấp.
- **Important!** Không khuyến nghị dùng form data làm parameters của procedure/function chuyển quyền từ client sang server, hoặc làm giá trị trả về khi chuyển về client.
- **Important!** Khi gọi server và trả về client, **chỉ phần dữ liệu thay đổi** được truyền về form.
- Document có table → FormDataStructure (document) chứa FormDataCollection (table).
- **Lưu ý**: applied objects chỉ có ở server; form data objects dùng được ở cả server và client.
- Hạn chế khi tạo form attributes:
  - Cấm gán giá trị kiểu **Array** và **Map** cho form attributes.
  - Với attributes kiểu tùy ý của các object FormDataStructure, FormDataCollectionItem, FormDataTreeItem, FormDataStructureAndCollection: không được gán Array, Map.
  - Không khuyến nghị dùng Array, Map làm phần tử của Structure hoặc ValueList → dùng **FixedArray**, **FixedMap**.
  - Không khuyến nghị dùng Structure, ValueList trong attribute data (attributes của attributes).
  - Attribute kiểu Arbitrary hoặc chứa collection: không gán giá trị chứa các applied object: DocumentObject, CatalogObject, BusinessProcessObject, TaskObject, ChartOfCharacteristicTypesObject, ChartOfCalculationTypesObject, ExchangePlanObject, ChartOfAccountsObject, ExternalDataSourceCubeDimensionTableObject, ExternalDataSourceTableObject.
- Form data = biểu diễn thống nhất dữ liệu từ nhiều applied objects, có ở cả server và client. Nếu developer tự viết thuật toán xử lý thì phải **tự chuyển đổi** dữ liệu.
- Cột **Always use** (”Use always”) trong attribute editor — ảnh hưởng truyền dữ liệu server–client:
  - Attribute con của dynamic list (column): bật → luôn đọc từ database và đưa vào form data; tắt → chỉ đọc khi có form item **đang hiển thị** gắn với attribute (hoặc attribute con).
  - Attribute con của register record collection: bật → register records của document được đọc và có trong form data; tắt → không đọc (nếu không có form item tham chiếu).
  - Các attribute còn lại: bật → luôn có trong form data; tắt → chỉ có khi tồn tại form item gắn với attribute (khác dynamic list: **visibility của item không quan trọng**).
  - Property của attribute cha ảnh hưởng mọi attribute con (tắt ở document table → coi như tắt ở mọi attribute con).
- Kiểu trong ngoặc ở cột Type (ví dụ `(CatalogObject.Products)`) nghĩa là applied type sẽ được chuyển sang form data type; kiểu thật của attribute Object là **FormDataStructure**.
- Đặc điểm theo kiểu:
  - ValueTable, ValueTree: thêm columns bằng lệnh **Add attribute column** (định nghĩa cấu trúc).
  - FormDataCollection (object tables) và FormDataStructureAndCollection (record sets): thêm cột bổ sung (**Add attribute column**) không gắn dữ liệu infobase; được tạo khi sinh form data, truy cập được ở client và server.
  - ValueList: đặt **Value type** → giới hạn kiểu khi thêm tương tác; thêm bằng code không bị cấm nhưng sẽ cố ép sang kiểu giới hạn. Có thể gắn Value type với form item.
  - DynamicList: thiết lập list parameters: main table, settings...

### Chuyển đổi applied object ↔ form data
- Global methods: **ValueToFormData()** (applied object → form data), **FormDataToValue()** (form data → applied object), **CopyFormData()** (copy form data có cấu trúc tương thích; trả True nếu thành công, False nếu không tương thích).
- Method làm việc với applied objects chỉ có trong **server procedures**; CopyFormData() dùng được ở cả server và client.
- Khi chuyển đổi, object được cache và kiểm tra tính cập nhật của bản cache.
- Với standard actions (mở form, lệnh Write chuẩn...) trong form có main attribute → chuyển đổi **tự động**.
- Methods của ClientApplicationForm (server): **ValueToFormAttribute()** (applied object → form attribute chỉ định), **FormAttributeToValue()** (form attribute → applied object).
- Trong form module, nên dùng **FormAttributeToValue** thay vì FormDataToValue: nhất quán với các ứng dụng 1C khác, cú pháp đơn giản hơn (không cần chỉ định kiểu), ít lỗi hơn. FormDataToValue yêu cầu chỉ định kiểu tường minh.
- Khi chuyển ValueTable/ValueTree sang form data bằng ValueToFormData() hoặc ValueToFormAttribute(): object phải chứa **mọi cột** của form data.
- **Important!** Cột attribute không gắn dữ liệu không tham gia chuyển đổi; cột thiếu trong object data sẽ bị xóa khi chuyển sang form data.
- Tham số thứ nhất của FormAttributeToValue() và FormDataToValue() chỉ có thể là: FormDataStructure, FormDataCollection, FormDataStructureAndCollection, FormDataTree.

### Attribute properties
- **Title**: dùng làm tiêu đề form item gắn với attribute nếu item không có Title riêng.
- **Main attribute**: attribute này là main → quyết định form extension.
- **Saved data**: khi sửa tương tác attribute → cố lock form attribute liên quan; bật property **Modified** của form; nếu form ở chế độ **Read only** → mọi item gắn attribute này cũng Read only.
- **Required field**: kiểm tra điền dữ liệu (giá trị **Display error**). Chỉ áp dụng cho: primitive types (Number, String, Boolean, Date, mọi reference, standard period), Value list, Value tree, Value table. Kiểm tra tương tự hàm `ValueIsFilled()`; table được coi là đã điền khi có ít nhất một row.

### Form parameters
- Tab **Parameters**, hai mục đích:
  - Mô tả dữ liệu ảnh hưởng tới việc mở form (parameterization).
  - Xác định parameters tạo **form uniqueness key**: bật property **Key parameter**. Khi mở form, hệ thống tìm form có cùng uniqueness key; có → trả form đó; không → tạo form mới.
- Giá trị parameter truyền qua parameters structure cùng system parameters. Phân tích trong event **OnCreateAtServer()** (collection **Parameters** là property của ClientApplicationForm).
- **Important!** Sau handler OnCreateAtServer, mọi **non-key** parameter bị xóa khỏi collection Parameters. Key parameters hiển thị **in đậm** trong danh sách. Non-key parameter cần dùng tiếp → lưu vào form data.
- Parameter không được truyền khi mở form → platform vẫn thêm vào structure với giá trị **Undefined** (tương đương bỏ qua parameter khi gọi method); áp dụng cho cả parameter developer tạo và standard parameters.
- **Standard parameters** hỗ trợ tương tác tự động giữa forms (chọn giá trị từ choice form, mở object form, standard commands...); developer có thể truyền khi gọi **OpenForm()**.
- Danh sách standard parameters: Help - Interface (managed) - Client application form - Client application form extension for... Với list forms và choice forms xem "Client application form extension for dynamic lists" (main attribute là dynamic list).

### Form commands
- Command chỉ mô tả hành động; muốn chạy phải gắn với form item (ví dụ Button). Các nhóm:
  - **Commands created by developer**: phải tạo handler trong form module.
  - **Standard commands**: do extension của main attribute và của attributes dạng list (object table, dynamic list, information register record set...) cung cấp, nếu có form item gắn attribute đó.
  - **Global commands**: từ global command interface (tab **Global commands**); có thể non-parameterized hoặc parameterized. Parameterized chỉ được cung cấp nếu form có nguồn parameter đúng kiểu. Đặt được ở bất kỳ đâu trên form.
- Availability của standard commands do property **Command set** của form item quyết định (ví dụ tắt nút "Mark for deletion" và "Delete" trên command bar của Sales invoice).
- Property **Action**: handler thực hiện command. Không có handler → command không dùng được. Chỉ chọn được **client-side** procedure/function **có một parameter**.
- Property **Modifies saved data**: khi chạy command → cố lock main form attribute (thất bại → command thất bại); bật **Modified** của form. Nếu form Read-only → mọi item gắn command này cũng Read-only.
- Chạy parameterized global command mà parameter lấy từ attribute có ”Modifies data”, với object mới chưa ghi → hệ thống cố ghi object, hỏi người dùng; trả lời không → command thất bại.
- Khi tự điền command bars/context menus có command source: standard commands **không** được thêm nếu item đã có nút thêm thủ công cùng command (không áp dụng cho command từ fragment của global command interface).
- Command có property **Use** tắt → mọi nút liên quan biến khỏi command interface; người dùng không đổi được.

### Form items
- Các item của managed form tạo thành tập phân cấp, quyết định giao diện. Loại: **Form** (root, duy nhất), **Form field**, **Form decoration**, **Form table**, **Form button**, **Form group**, **Form item add-on**.
- Form field và form table **luôn gắn form data**. Nếu không chỉ định attribute, hoặc attribute không có ở client do hạn chế quyền, hoặc bị loại khỏi thành phần (properties View và Edit của form attribute) → field không hiển thị và tự bị xóa khi tạo form ở Enterprise mode.

### General properties of form items
- **TitleLocation**: cách hiển thị tiêu đề. Tiêu đề = synonym của attribute gắn item, trừ khi item có **Title**. Tiêu đề luôn kết thúc bằng ":" (hệ thống tự thêm).
- **Data**: tham chiếu tới form attribute gắn item; không gắn → item không hiển thị.
- **Command** (của button): command chạy khi bấm; không gắn → button không hiển thị.
- Item ở chế độ Read-only khi: có property **ReadOnly** (Designer hoặc code), hoặc group chứa nó có ReadOnly, hoặc attribute gắn có **SavedData** và form ở Read-only. (Field Read-only có khung màu nhạt hơn, không có nút select, chỉ có nút open.)
- Visibility: **Visible** (đổi được trong Designer và bằng code) và **User visibility** (chỉ cấu hình trong Designer, visibility ban đầu theo **roles**). Visibility cuối = Visible **AND** User visibility. Người dùng đổi visibility trong hộp thoại **Customize form** thực chất đổi User visibility.

### Associating items with form attributes
- **Connection to current data of tables**: item gắn với cột của table trên form → hiển thị dữ liệu dòng hiện tại. Áp dụng cho fields và tables; cột không cần hiển thị trong table; item có thể Read only hoặc edit. Ví dụ data path: `Elements.Products.CurrentData.Price` (Elements = property form chứa mọi items; Products = form table; CurrentData = dòng hiện tại; Price = attribute của table). Loại field: Label field hoặc Input field.
- **Connection to attributes through reference**: attribute kiểu reference (ví dụ CatalogRef) → item gắn với attribute lấy qua reference; dữ liệu tự lấy và cập nhật khi reference đổi; độ sâu tùy ý; luôn **View only**. Ví dụ: `Object.Products.Product.Weight`.
  - **Note**: attribute **composite type** (nhiều kiểu, gồm CatalogRef, DocumentRef...) **không** lấy attribute qua reference được.
- **Connection with collections totals**: gắn với tổng của collection (tables, record sets, value lists — value list chỉ có số rows): totals theo number fields; số rows; luôn View only. Ví dụ: `Object.Products.TotalAmount` (tổng cột Amount).
  - Hiển thị totals ở footer cột: bật property **Footer** của table, điền **FooterDataPath** của cột.
  - Hiển thị số rows ở tiêu đề tab: điền **TitleDataPath** của group kiểu Page.
- **Choice parameters**: giá trị parameters dùng khi chọn giá trị attribute (khi mở choice form, quick choice list, nhập theo dòng). Truyền vào form được mở qua structure **Parameters**: cột Name = key, cột Value = value. Nếu Name là ”Filter.Type” → tạo form parameter **Filter** (Structure) chứa key ”Type” với value ”Product”. Danh sách giá trị cho filter: chọn kiểu **Fixed array** khi sửa cột Value. Ví dụ: giới hạn products có Type = `Enumeration.ProductTypes.Product`.

### Form (root item)
- Mô tả thuộc tính hiển thị của form và form event handlers; luôn duy nhất, ở gốc cây.
- Ngắt mở form:
  - **OnCreateAtServer**: đặt `Cancel = True` → form không được tạo.
  - **OnOpen**: đặt `Cancel = True` → form không được mở.
- Property **WindowOpeningMode**:
  - **Independent**: mở trong vùng làm việc của cửa sổ chính.
  - **Lock parent window**: cửa sổ non-modal, khóa form đã khởi tạo việc mở. Cho form nhập ít thông tin, dùng nhanh (ví dụ catalog ít attribute). Trông giống modal nhưng khi mở từ code, module **không dừng**. Mở ở cửa sổ phụ. Mặc định cho: Catalog item and group; Exchange plan node; Item and group of a chart of characteristic types; Account; Calculation type; Task; Record of an independent information register.
  - **Lock the entire interface**: như trên nhưng khóa cả form cha và toàn bộ giao diện. Không là mặc định cho form nào.
- Thuật toán xác định cửa sổ bị khóa: nếu **FormOwner** là form chưa đóng → khóa form đó; nếu FormOwner là form item của form chưa đóng → khóa form chứa item; còn lại (FormOwner = Undefined hoặc owner đã đóng) → khóa cửa sổ hiện tại của client application lúc mở.
- WindowOpeningMode không ảnh hưởng khi mở form từ form đang khóa giao diện; khi đó parameter WindowOpeningMode của **OpenForm()** cũng bị bỏ qua → form mở ở cửa sổ riêng, non-blocking.
- **Command bar** của form: vị trí bằng property ”Command bar location”; tập standard commands bằng property ”Command set”.
- **Enable form change** tắt → người dùng không đổi được tập và vị trí items ở Enterprise mode.
- **ReadOnly** của form: chỉ đổi bằng code. True → không khả dụng: items gắn attributes có "Saved data"; buttons gắn commands có "Changes saved data"; buttons gắn hầu hết standard commands. Chỉ attribute tắt "Saved data" còn sửa được.

### Radio buttons và checkboxes
- Field kiểu **Radio button field**: property **ChoiceList** quyết định số lượng và giá trị radio buttons. Mặc định nằm ngang; xếp dọc bằng ”Column count”. Column count = 0 → hệ thống tự chia nhiều dòng theo chỗ trống (tính lúc tạo form, không động).
- Checkbox field và Radio button field có display kind: checkbox dùng property **Checkbox type** (segmented buttons, switches, checkboxes); radio button dùng property "radio button type".

### Group
- Kết hợp được fields, pages, commands, columns. Loại group:
  - **Regular group**: nhóm form items.
  - **Command bar**: chứa buttons và groups.
  - **Pages**: panel có tabs (dọc hoặc ngang); bên trong chỉ chứa group kiểu **Page**; Page chứa items khác.
  - **Column group**: nhóm cột trong table; đổi quy tắc nhóm (dọc/ngang).
- Group lồng nhau được; di chuyển items giữa groups — hệ thống tự kiểm tra hợp lệ, tự đổi properties cần thiết (ví dụ View); yêu cầu với item con đổi → tự sửa hoặc xóa.
- Thiết kế Regular group:
  - **No**: không đánh dấu.
  - **Slight highlight**: tiêu đề chữ lớn màu xanh lá.
  - **Standard highlight**: tiêu đề chữ lớn xanh lá + indent quanh items (mỗi phía).
  - **Strong highlight**: tiêu đề chữ lớn xanh lá + dải xanh bên trái suốt chiều cao + indent phía dưới.
- Property **Behavior**:
  - **Regular** (hoặc **Auto**) — standard group: không đổi hiển thị khi người dùng thao tác.
  - **Collapsible**: người dùng thu/mở ở Enterprise mode. Developer **không** xác định được trạng thái từ code, **không** ép thu/mở. Trạng thái ban đầu theo checkbox **Collapsed**. Không thu/mở được nếu tiêu đề rỗng hoặc không hiển thị (**ShowTitle** = False).
  - **Pop-up**: ban đầu như group thu gọn; click tiêu đề → "pop up" trên form ở cửa sổ đặc biệt. Mỗi lúc chỉ một pop-up group → không lồng được; pop-up lồng sẽ hiển thị như collapsible. Hiện/ẩn **không cần server call**. Phải có tiêu đề (tiêu đề là text hyperlink); không có tiêu đề → hoạt động như standard group.
- **ControlRepresentation**: điều khiển trạng thái collapsible bằng hình hoặc hyperlink. **CollapsedRepresentationTitle**: tiêu đề khi thu gọn; không điền → dùng tiêu đề thường.
- Command bar: property **”Command source”** chỉ định form item (Form, Form table, Spreadsheet document field, Graphical schema field) cung cấp "own" commands; tập commands hiển thị theo property Command set của item nguồn. Ví dụ: attribute SpreadsheetDocument → thêm group Command Bar với source là spreadsheet document. Form tables đã có command bar sẵn; chỉ thêm khi cần khác thường (đặt bên trái, nút dọc, tách vị trí).

### Conditional appearance
- Thiết lập từ properties panel của **root item** của form. Data composition system (reports, dynamic lists) cũng có conditional appearance.
- Không khuyến nghị dùng conditional appearance **của form** cho dynamic list nếu có thể dùng conditional appearance của chính list.
- Các kiểu:
  - **Background color** — form items: input field, text document field, table, standard button; table fields: label field, input field, radio button field, picture field.
  - **Text color** — form items: label field, input field, text document field, picture field, radio button field, table, regular button, hyperlink, text decoration, picture decoration; table fields: label field, input field, radio button field.
  - **Font** — form items: label field, input field, text document field, picture field, radio button field, calendar field, table, regular button, hyperlink, text decoration, picture decoration; table fields: label field, input field. Note: đổi font bằng conditional appearance không được tính khi xác định kích thước items.
  - **Mark negatives** — form items và table fields: label field, input field.
  - **Horizontal position** — form items: label field, input field, text decoration; table fields: label field, input field.
  - **Unfilled mark** — form items: input field, table; table fields: input field. Note: nếu điều khiển *MarkIncomplete* bằng conditional appearance → nên đặt *AutoMarkIncomplete* = “No” cho field.
  - **Text** — table fields: label field, input field.
  - **Format** — form items: Page group, Regular group; table fields: label field, input field.
  - **Visibility** — ẩn table fields: label field, input field, radio button field, picture field; ô ẩn được thay bằng ô kề (lớn hơn), thuật toán có thể khác giữa các client. Không khuyến nghị dùng để ẩn **cả dòng** (giảm hiệu năng, hiển thị sai).
  - **Accessibility** — tắt availability của table fields: label field, input field, radio button field, picture field.
  - **Read only** — View only cho các table fields trên.
  - **Show** — ẩn giá trị trong cột table (label field, input field, radio button field, picture field); dùng cho cột nằm trong column group kiểu **In cell**. Cột không nhóm hoặc vẫn hiển thị riêng → dùng **Visibility**.
- Note: conditional appearance dùng ngày giờ máy hiện tại điều chỉnh theo time zone của session.
- Cột form table được format có điều kiện chứa field của table đó → dùng current data của table đó; field không thuộc table → dùng current data của **table đầu tiên** (theo thứ tự trong form editor).
- Thiết kế động theo form data, không cần thao tác đặc biệt. Nếu dùng dynamic list fields trong điều kiện → bật *Always use* cho các field đó.
- Ví dụ: đổi màu chữ dòng trong table Products nếu amount > 1 triệu.

### Home page
- **Home page**: form active khi khởi động ứng dụng, chứa các chức năng hay dùng. Mặc định do developer cấu hình; chung cho mọi người hoặc theo roles. Mỗi người dùng có thể đổi thành phần home page ở Enterprise mode.

## Cú pháp & ví dụ code

### Chuyển đổi dữ liệu trong thuật toán tự viết
```bsl
&AtClient

Procedure WriteObject();

    WriteObjectAtServer();

EndProcedure

&AtServer

Procedure WriteObjectAtServer()

    ObjectItem = FormDataToValue(Form.Object, Type("CatalogObject.Items"));

    ObjectItem.Write();

EndProcedure
```
[ghi chú ngoài nguồn: dòng `Procedure WriteObject();` có dấu chấm phẩy — theo chính Bài 6, đặt chấm phẩy sau mô tả procedure gây compilation error; giữ nguyên như tài liệu.]

### FormDataToValue vs FormAttributeToValue
```bsl
Products = FormDataToValue(ProductsTable, Type("ValueTable"));
```
```bsl
Products = FormAttributeToValue("ProductsTable");
```

### FormAttributeToValue + ValueToFormAttribute
```bsl
&AtServer

Procedure CalculateTotalAtServer()

    // Convert the Object attribute to an applied object.

DocumentObject = FormAttributeToValue("Object");

// Perform recomputing by the method defined in the document module.

    DocumentObject.CalculateTotal();

    // Convert the applied object back to an attribute.

    ValueToFormAttribute(DocumentObject, "Object");

EndProcedure
```

### Form parameters — nơi gọi
```bsl
// Generate a form parameter.

Parameters = New Structure();

Parameters.Insert("PickMode", PredefinedValue("Enumeration.PickModes.Simple"));

// Open a form with specified parameters.

OpenForm("CommonForm.PickProducts", Parameters);
```

### Form parameters — trong form module
```bsl
&AtServer

Procedure OnCreateAtServer(Cancel, StandardProcessing)

    // Check if the form contains such a parameter

    If Parameters.Property("PickMode") Then

        If Parameters.PickMode= Enumerations.PickModes.Simple Then

            …

        EndIf;

    EndIf;

EndProcedure
```

### Data path ví dụ
```bsl
Elements.Products.CurrentData.Price
Object.Products.Product.Weight
Object.Products.TotalAmount
```

## Thuộc tính/thiết lập quan trọng trong Designer

**Subsystem**: Include in the command interface; Explanation; Picture (Select picture → From configuration → Add → Common picture → Load from file → Name → OK); Synonym (tên section); tab Content.

**Configuration**: context menu → Open client application interface (sửa panels).

**Form editor**: Form attributes, Form commands, Form parameters (tab Parameters), Form module, Form items, Command interface; tab Global commands.

**Form attribute**: Title; Main attribute; Saved data; Required field (Display error); cột Always use / Use always; cột Type; lệnh Add attribute column; Value type (ValueList); View, Edit.

**Form parameter**: Key parameter.

**Form command**: Action; Modifies saved data; Use; Command set (của form item).

**Form item (chung)**: TitleLocation; Title; Data; Command (button); ReadOnly; Visible; User visibility; Choice parameters (Name/Value, Fixed array).

**Table / Page group**: Footer; FooterDataPath (column); TitleDataPath (Page group).

**Form (root)**: WindowOpeningMode (Independent / Lock parent window / Lock the entire interface); FormOwner; Command bar location; Command set; Enable form change; ReadOnly (chỉ bằng code); event OnCreateAtServer, OnOpen; Conditional appearance.

**Radio button / Checkbox**: ChoiceList; Column count; Checkbox type; radio button type.

**Group**: loại Regular group / Command bar / Pages / Page / Column group; design No / Slight highlight / Standard highlight / Strong highlight; Behavior (Regular/Auto, Collapsible, Pop-up); Collapsed; ShowTitle; ControlRepresentation; CollapsedRepresentationTitle; Command source.

**Conditional appearance kinds**: Background color, Text color, Font, Mark negatives, Horizontal position, Unfilled mark (MarkIncomplete / AutoMarkIncomplete), Text, Format, Visibility, Accessibility, Read only, Show.

## Lỗi thường gặp / lưu ý
- Dùng biến form module làm nguồn dữ liệu cho form controls → không được phép; phải dùng form attributes.
- Form chỉ có **một** main attribute.
- Không dùng form data làm parameter khi gọi từ client sang server, hoặc làm giá trị trả về cho client.
- Gán Array/Map cho form attributes → cấm; dùng FixedArray/FixedMap trong Structure/ValueList.
- Không gán applied objects (DocumentObject, CatalogObject...) vào attribute Arbitrary hoặc collection.
- Applied objects chỉ có ở server; ValueToFormData/FormDataToValue/ValueToFormAttribute/FormAttributeToValue chỉ dùng trong server procedures.
- Chuyển ValueTable/ValueTree sang form data mà thiếu cột → cột thiếu bị xóa; cột không gắn dữ liệu không tham gia chuyển đổi.
- Non-key form parameters bị xóa sau OnCreateAtServer → lưu vào form data nếu cần.
- Composite type không lấy attribute qua reference được.
- Command không có Action → không dùng được; Action chỉ nhận client procedure/function có một parameter.
- Field không gắn attribute / button không gắn command → không hiển thị.
- Collapsible/Pop-up group cần tiêu đề hiển thị; pop-up không lồng nhau.
- Không dùng conditional appearance để ẩn cả dòng table; không dùng conditional appearance của form cho dynamic list nếu list tự làm được.
- Dùng dynamic list fields trong conditional appearance → bật Always use.
- Điều khiển MarkIncomplete bằng conditional appearance → đặt AutoMarkIncomplete = “No”.
- Subordinate subsystems không hiển thị trong Current section functions panel; Picture chỉ hiện với top-level subsystems.

## Điểm cần nhớ
- Thiết kế subsystems là bước đầu tiên; object có thể thuộc nhiều subsystem; kết hợp roles để giao diện gọn.
- Panels: Sections, Current section functions, Open items, Favorites, History; người dùng tự điều chỉnh được.
- Form có mặt ở cả server và client; mọi dữ liệu form phải là form attributes; một main attribute quyết định form extension.
- Form data types: FormDataStructure, FormDataCollection, FormDataStructureAndCollection, FormDataTree; kiểu trong ngoặc ở cột Type = sẽ được chuyển đổi.
- Trong form module ưu tiên FormAttributeToValue / ValueToFormAttribute (server); CopyFormData chạy cả client và server.
- Form parameters: Key parameter tạo uniqueness key; non-key bị xóa sau OnCreateAtServer; parameter không truyền = Undefined.
- Visibility cuối = Visible AND User visibility; ReadOnly được áp dụng theo group và từ Saved data khi form Read-only.
- WindowOpeningMode: Independent / Lock parent window (mặc định cho catalog item...) / Lock the entire interface; Cancel = True trong OnCreateAtServer hoặc OnOpen để ngắt mở form.

## Thẻ gợi ý bài thực hành (Practice 9)

> Thẻ bám theo đề "9. Practice.docx". Phần lớn yêu cầu làm bằng thiết lập trong Designer (subsystem, form editor, choice parameters, home page); chỉ một số bài cần code trong form module.

### Bài tập 1 — Subsystem Purchases, picture và explanation
- **Đề bài (tóm tắt):** Tạo subsystem Purchases; đặt picture và explanation cho mọi subsystem.
- **Gợi ý 1 — Hướng đi:** Mục "Subsystems" và "Subsystem properties"; Picture chỉ hiển thị với top-level subsystem.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Subsystem → property **Explanation**, **Picture** (Select picture → From configuration → Add → Common picture → Load from file).
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo subsystem Purchases, bật Include in the command interface.
  2. Tạo common picture cho từng subsystem, gán vào Picture.
  3. Điền Explanation.
- **Lỗi hay gặp:**
  - Gán picture cho subsystem con → không hiện.
  - Quên Include in the command interface → section không xuất hiện.
- **Tự kiểm tra:** Sections panel hiển thị icon cho từng section; rê chuột thấy explanation.

### Bài tập 2 — Document PurchaseInvoice
- **Đề bài (tóm tắt):** Tạo PurchaseInvoice có **Vendor**, **Contract**, DocumentTotal và tabular section **Products** (**Product**, **Quantity**, **Price**, **Amount**), thuộc Purchases, list presentation "Purchase Invoices".
- **Gợi ý 1 — Hướng đi:** Cấu trúc tương tự SalesInvoice (Bài 3–4); đề không yêu cầu thêm, nhưng nên cho Contract lọc theo Vendor giống Contract của SalesInvoice lọc theo Customer (Choice parameter links `Filter.Owner`, Bài 4).
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Document mới; Vendor kiểu `CatalogRef.Counterparties`; Contract kiểu `CatalogRef.CounterpartyContracts`; Fill checking cho các attribute in đậm; List presentation; tab Subsystems chọn Purchases.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo document và attribute.
  2. Thêm tabular section với 4 attribute.
  3. Đặt presentation và subsystem.
- **Lỗi hay gặp:**
  - Không đặt Choice parameter links cho Contract → chọn được hợp đồng của đối tác khác.
  - Quên Fill checking cho các attribute in đậm.
- **Tự kiểm tra:** Section Purchases có lệnh "Purchase Invoices"; bỏ trống Vendor → không ghi được.

### Bài tập 3 — Number và Date trên cùng một dòng
- **Đề bài (tóm tắt):** Sửa form SalesInvoice và PurchaseInvoice để Number và Date nằm ngang trên một dòng.
- **Gợi ý 1 — Hướng đi:** Mục "Group": một **Regular group** với kiểu nhóm ngang chứa hai field.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Form editor → Form items → Add → Group – Regular group; property Group (horizontal), ShowTitle = No, Representation None; kéo Number và Date vào group.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo document form (nếu chưa có) cho từng document.
  2. Thêm regular group ngang ở đầu form.
  3. Kéo Number và Date vào.
- **Lỗi hay gặp:**
  - Group để kiểu dọc → field vẫn xếp chồng.
  - Để hiện tiêu đề group → thêm một dòng tiêu đề thừa.
- **Tự kiểm tra:** Mở chứng từ ở Enterprise mode, Number và Date nằm cạnh nhau.

### Bài tập 4 — Mặc định chỉ hai panel
- **Đề bài (tóm tắt):** Cấu hình để mặc định hiển thị sections panel và open items panel.
- **Gợi ý 1 — Hướng đi:** Mục "Panels": developer chỉnh bố cục mặc định, người dùng có thể tự đổi sau.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Root Configuration → context menu → **Open client application interface**.
- **Gợi ý 3 — Khung bài làm:**
  1. Mở cửa sổ chỉnh panels.
  2. Chỉ giữ Sections panel và Open items panel ở vùng hiển thị.
- **Lỗi hay gặp:**
  - Infobase cũ đã lưu thiết lập giao diện của người dùng → không thấy thay đổi; thử với người dùng mới hoặc khôi phục thiết lập mặc định.
- **Tự kiểm tra:** Khởi động Enterprise mode chỉ thấy hai panel đó.

### Bài tập 5 — Quan hệ của Counterparty (vendor / customer / other)
- **Đề bài (tóm tắt):** Thêm số attribute cần thiết vào Counterparties để biểu diễn quan hệ: vendor, customer, other — một counterparty có thể có nhiều quan hệ cùng lúc; tạo item form, đổi TitleLocation của các checkbox sang "Right".
- **Gợi ý 1 — Hướng đi:** Vì các quan hệ **không loại trừ nhau**, một attribute Enumeration (chỉ chọn một giá trị) không đủ; mỗi quan hệ là một attribute Boolean riêng. Trên form, Boolean hiển thị dạng checkbox (mục "Radio buttons và checkboxes").
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Ba attribute Boolean trong catalog Counterparties; tạo Item form; từng checkbox → property **TitleLocation** = Right.
- **Gợi ý 3 — Khung bài làm:**
  1. Thêm attribute Boolean cho từng quan hệ.
  2. Tạo item form.
  3. Chỉnh TitleLocation cho các checkbox.
- **Lỗi hay gặp:**
  - Dùng một attribute Enumeration → không thể vừa vendor vừa customer.
  - Đổi TitleLocation của group thay vì của từng checkbox.
- **Tự kiểm tra:** Một counterparty tick được cả Vendor và Customer; nhãn nằm bên phải ô tick.

### Bài tập 6 — Chỉ chọn Vendor / Customer phù hợp
- **Đề bài (tóm tắt):** Trong PurchaseInvoice, field Vendor chỉ chọn counterparty có quan hệ Vendor; trong SalesInvoice, Customer chỉ chọn counterparty có quan hệ Customer.
- **Gợi ý 1 — Hướng đi:** Giá trị lọc **cố định** (luôn là True) → property **Choice parameters** của attribute (khác Choice parameter links, vốn lấy giá trị từ field khác).
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Attribute Vendor của PurchaseInvoice / Customer của SalesInvoice → Choice parameters → Name `Filter.<tên attribute Boolean>`, Value = True.
- **Gợi ý 3 — Khung bài làm:**
  1. Mở Choice parameters của attribute.
  2. Thêm một dòng filter theo attribute Boolean tương ứng.
  3. F7 và thử chọn.
- **Lỗi hay gặp:**
  - Gõ sai tên sau `Filter.` → filter không có tác dụng.
  - Đặt filter trên form item của một form nhưng quên form khác; đặt ở attribute metadata thì áp dụng cho mọi form.
- **Tự kiểm tra:** Danh sách chọn Vendor chỉ hiện counterparty có tick Vendor; tương tự với Customer.

### Bài tập 7 — Tabular section Services trên page riêng
- **Đề bài (tóm tắt):** Thêm tabular section Services (cùng attribute như Products) cho PurchaseInvoice và SalesInvoice; đặt bảng Products và Services trên hai page khác nhau.
- **Gợi ý 1 — Hướng đi:** Mục "Group": group kiểu **Pages** chứa các group **Page**.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Document → Tabular sections → Add `Services` với Product, Quantity, Price, Amount; form editor → Add group Pages → hai Page → kéo table Products vào page 1, Services vào page 2.
- **Gợi ý 3 — Khung bài làm:**
  1. Thêm tabular section ở cả hai document.
  2. Kéo tabular section mới lên form.
  3. Tạo Pages + 2 Page, sắp lại hai table.
- **Lỗi hay gặp:**
  - Thêm Services chỉ ở một document.
  - Đặt Page trực tiếp dưới form mà không có group Pages cha.
  - Quên đặt ReadOnly cho cột Amount của Services như đã làm ở Products.
- **Tự kiểm tra:** Form chứng từ có hai tab "Products" và "Services", mỗi tab một bảng.

### Bài tập 8 — Dùng chung thuật toán cho Services
- **Đề bài (tóm tắt):** Tính Amount theo dòng và kiểm tra giá tối thiểu cho bảng Services giống bảng Products, không lặp code mà gọi cùng code từ event của cả hai bảng.
- **Gợi ý 1 — Hướng đi:** Thuật toán không được "đóng cứng" vào `Items.Products`; nhận **dòng hiện tại làm parameter**, rồi mỗi handler chỉ truyền dòng của bảng mình. Đây chính là áp dụng mục "Data path" (`Items.<Table>.CurrentData`) và quy tắc tránh duplication.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Form module SalesInvoice: sửa procedure kiểm tra giá tối thiểu để nhận parameter dòng; thêm handler OnChange cho cột Quantity, Price, Product của Services (`&AtClient`), mỗi handler chỉ vài dòng gọi các procedure chung với `Items.Services.CurrentData`.
- **Gợi ý 3 — Khung bài làm:**
  1. Đổi chữ ký procedure kiểm tra giá: thêm parameter dòng, bỏ việc tự lấy `Items.Products.CurrentData` bên trong.
  2. Sửa các handler Products để truyền dòng.
  3. Tạo các handler Services tương ứng.
  ```bsl
  &AtClient
  Procedure ServicesPriceOnChange(Item)
  	ControlMinimumSalesPrice(___);          // dòng hiện tại của bảng Services
  	CalculateAmountAtRow(___, ___);         // cùng dòng đó và discount của document
  EndProcedure
  ```
- **Lỗi hay gặp:**
  - Copy nguyên procedure thành bản "...Services" → duplication.
  - Bên trong procedure chung vẫn còn tham chiếu `Items.Products` → bảng Services kiểm tra nhầm dòng.
  - Quên kiểm tra dòng = Undefined trước khi đọc field.
- **Tự kiểm tra:** Nhập giá thấp hơn tối thiểu ở bảng Services → giá tự sửa và có message; Amount của Services tính có discount.

### Bài tập 9 — DocumentTotal = goods + services
- **Đề bài (tóm tắt):** Sửa thuật toán DocumentTotal thành tổng Amount của cả Products và Services.
- **Gợi ý 1 — Hướng đi:** Mở rộng procedure server tính lại tổng (Bài 7) để duyệt thêm bảng thứ hai; gọi nó từ OnChange của cả hai form table.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Procedure `&AtServer` hiện có; handler OnChange của form table Services (`&AtClient`).
- **Gợi ý 3 — Khung bài làm:**
  1. Thêm vòng lặp thứ hai cho `Object.Services` vào cùng biến tổng.
  2. Tạo handler OnChange của table Services gọi procedure đó.
- **Lỗi hay gặp:**
  - Reset biến tổng về 0 giữa hai vòng lặp → mất phần goods.
  - Quên handler OnChange của Services → tổng không cập nhật khi sửa dịch vụ.
- **Tự kiểm tra:** Goods 100 + services 50 → DocumentTotal = 150; xóa dòng dịch vụ → tổng giảm.

### Bài tập 10 — Số dòng trên tiêu đề page "Products (2)"
- **Đề bài (tóm tắt):** Tiêu đề page hiển thị số dòng của bảng trên page đó.
- **Gợi ý 1 — Hướng đi:** Không cần code: page có property **TitleDataPath** (mục "Thuộc tính/thiết lập": Table / Page group) — gắn tiêu đề với một data path có sẵn của tabular section là số dòng.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Form editor → page chứa Products → property TitleDataPath → chọn trong cây `Object.Products` phần tử biểu diễn số dòng; làm tương tự cho Services, ở cả hai document.
- **Gợi ý 3 — Khung bài làm:**
  1. Chọn page, mở TitleDataPath.
  2. Mở rộng `Object` → tabular section → chọn mục số dòng.
- **Lỗi hay gặp:**
  - Viết code đếm dòng trong OnChange và gán Title → chạy được nhưng phức tạp và dễ quên cập nhật.
  - Chọn data path của bảng khác page.
- **Tự kiểm tra:** Thêm dòng → tiêu đề page tự đổi thành "Products (n)".

### Bài tập 11 — Lọc Product theo loại trong Products / Services
- **Đề bài (tóm tắt):** Bảng Products chỉ chọn product loại InventoryItem; bảng Services chỉ chọn loại Service.
- **Gợi ý 1 — Hướng đi:** Lọc theo giá trị cố định → **Choice parameters** của attribute Product trong từng tabular section.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Document → tabular section Products → attribute Product → Choice parameters: `Filter.<attribute loại của Products>` = giá trị enum tương ứng; làm tương tự cho Services, ở cả hai document.
- **Gợi ý 3 — Khung bài làm:**
  1. Mở Choice parameters của Product trong Products, chọn giá trị InventoryItem.
  2. Làm lại cho Services với giá trị Service.
- **Lỗi hay gặp:**
  - Tên attribute sau `Filter.` phải đúng tên attribute loại trong catalog Products của bạn (trong cấu hình mẫu là `ProductType`).
  - Đặt filter ở attribute Product của catalog thay vì ở attribute của tabular section.
- **Tự kiểm tra:** Danh sách chọn ở bảng Products không có dịch vụ và ngược lại.

### Bài tập 12 — Nút Pick cho Products và Services
- **Đề bài (tóm tắt):** Thêm nút Pick cho từng bảng của SalesInvoice; mở choice form của Products lọc theo loại; chọn không đóng form; nếu product đã có trong bảng thì bỏ qua, chưa có thì thêm dòng với Product và Quantity = 1.
- **Gợi ý 1 — Hướng đi:** Mục "Form parameters" và "Form commands": mở form bằng `OpenForm` với Structure tham số (MultipleChoice, CloseOnChoice, Filter); truyền **Owner** là form table để giá trị chọn quay về event **ChoiceProcessing** của table đó. Một procedure mở form dùng chung, nhận table và loại product làm parameter.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Form commands `PickProducts`, `PickServices` (Action `&AtClient`), đặt thành button trong command bar của từng table. `PredefinedValue("Enum.<...>.<...>")` lấy giá trị enum trên client. Event ChoiceProcessing của từng form table (`&AtClient`). Kiểm tra trùng bằng `Object.<Tabular section>.FindRows(<Structure>)` — trả về Array.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo hai command + button.
  2. Viết procedure chung mở choice form với 3 key tham số và Owner.
  3. Tạo handler ChoiceProcessing cho từng bảng: tìm dòng có Product đã chọn, nếu không có thì thêm dòng.
  ```bsl
  &AtClient
  Procedure PickProductsToTable(TableItem, ProductType)
  	Parameters_ = New Structure("MultipleChoice, CloseOnChoice, Filter", ___, ___, ___);
  	OpenForm(___, Parameters_, ___);   // tên choice form, tham số, Owner
  EndProcedure

  &AtClient
  Procedure ProductsChoiceProcessing(Item, SelectedValue, StandardProcessing)
  	// tìm dòng có Product = SelectedValue; nếu Count() = 0 thì thêm dòng, điền 2 cột
  EndProcedure
  ```
- **Lỗi hay gặp:**
  - Không truyền Owner → ChoiceProcessing của table không được gọi.
  - Gõ sai tên key: [ghi chú ngoài nguồn] code demo/cấu hình của khóa có chỗ viết `CloseOnChoise` — platform không nhận key sai nên form vẫn đóng sau mỗi lần chọn; key đúng là `CloseOnChoice`.
  - Key bên trong Filter phải là tên attribute loại trong catalog Products của bạn (đề viết "Type", cấu hình mẫu dùng `ProductType`).
  - `FindRows()` trả về Array các dòng — kiểm tra "chưa có" bằng method `Count()` của Array.
- **Tự kiểm tra:** Bấm Pick ở Products → chỉ thấy InventoryItem; chọn liên tiếp nhiều product, form không đóng, mỗi product chỉ xuất hiện một lần với Quantity = 1; chọn lại product đã có → không thêm dòng.

### Bài tập 13 — Footer tổng Amount
- **Đề bài (tóm tắt):** Thêm footer cho bảng Products và Services của SalesInvoice và PurchaseInvoice, hiển thị tổng cột Amount.
- **Gợi ý 1 — Hướng đi:** Không cần code: table có property **Footer**, cột có **FooterDataPath** gắn với tổng của collection (mục "Associating items with form attributes", connection with collection totals).
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Form table → Footer = bật; cột Amount → FooterDataPath → chọn phần tổng của Amount trong `Object.<Tabular section>`.
- **Gợi ý 3 — Khung bài làm:**
  1. Bật Footer cho table.
  2. Đặt FooterDataPath cho cột Amount.
  3. Lặp lại cho 4 bảng (2 document × 2 tabular section).
- **Lỗi hay gặp:**
  - Bật Footer nhưng quên FooterDataPath → footer trống.
  - Đặt FooterDataPath ở cột khác (ví dụ Quantity) trong khi đề yêu cầu Amount.
  - [ghi chú ngoài nguồn] Trong cấu hình mẫu cuối khóa không tìm thấy footer tổng Amount; demo Theory chỉ có footer cho cột Quantity — đừng dựa vào cấu hình mẫu để đối chiếu bài này.
- **Tự kiểm tra:** Dưới mỗi bảng hiện tổng Amount, cập nhật ngay khi sửa dòng.

### Bài tập 14 — List form trên Home page
- **Đề bài (tóm tắt):** Hiển thị list form của SalesInvoice và PurchaseInvoice trên home page; tạo list form nếu chưa có.
- **Gợi ý 1 — Hướng đi:** Mục "Home page": developer cấu hình bố cục mặc định của home page.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Tạo **List form** cho từng document (Forms → Add → Document list form); root Configuration → context menu → mở cấu hình **Home page** → thêm hai list form vào cột.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo list form cho hai document.
  2. Mở cấu hình home page, thêm hai form.
  3. F7, khởi động lại Enterprise mode.
- **Lỗi hay gặp:**
  - Không tạo list form trước → không chọn được form để đưa lên home page.
  - Thiết lập home page của người dùng đã lưu ghi đè bố cục mặc định.
- **Tự kiểm tra:** Mở ứng dụng thấy ngay danh sách Sales invoices và Purchase Invoices trên trang chủ.

## Code demo của bài Theory (repo 1CJDCourse, nhánh lesson/10-theory)

> [ghi chú ngoài nguồn] Bản export nhánh lesson/09-theory trùng với master (chỉ khác ConfigDumpInfo, Rights và một file XML) — tức là chứa lời giải Practice, nên không trích vào bản học viên. Các demo form của Theory Bài 9 (Filter qua form parameters, conditional appearance "amount > 1 triệu", footer) xuất hiện trong nhánh lesson/10-theory khi so với lesson/08-theory, nên được trích từ nhánh đó.

### Standard parameter Filter khi mở choice form từ code (StartChoice)
Nguồn: nhánh lesson/10-theory — cf/Documents/PersonnelChange/Forms/DocumentForm/Ext/Form/Module.bsl
```bsl
&AtClient
Procedure ChangesEmployeeStartChoice(Item, ChoiceData, StandardProcessing)
	
	StandardProcessing = False;
	
	OpenParameters = New Structure("Filter", New Structure("Gender", PredefinedValue("Enum.Gender.Female")));
	
	OpenForm("Catalog.Employees.ChoiceForm", OpenParameters, Item);
	
EndProcedure
```
- Tắt xử lý chuẩn (`StandardProcessing = False`) rồi tự mở choice form với form parameter `Filter` (Structure lồng Structure) — dạng code của property **Choice parameters** `Filter.Gender`.
- Parameter thứ ba của `OpenForm` là `Item` → field `ChangesEmployee` thành **FormOwner**; giá trị chọn được trả về field đó.
- `PredefinedValue("Enum.Gender.Female")` lấy giá trị enum ở client (không truy cập database).

### Choice parameters "Filter.Type" bằng code và Pick với form parameters
Nguồn: nhánh lesson/10-theory — cf/Documents/SalesInvoice/Forms/DocumentForm/Ext/Form/Module.bsl và cf/Documents/PurchaseInvoice/Forms/DocumentForm/Ext/Form/Module.bsl
```bsl
&AtClient
Procedure PickProducts(Command)
	PickProductsToTable(Items.Products, PredefinedValue("Enum.ProductTypes.Product"));
EndProcedure

&AtClient
Procedure PickServices(Command)
	PickProductsToTable(Items.Services, PredefinedValue("Enum.ProductTypes.Service"));
EndProcedure

&AtClient
Procedure PickProductsToTable(TableItem, ProductType)

	OpenForm(
		"Catalog.Products.ChoiceForm",
		New Structure("MultipleChoice, CloseOnChoise, Filter", False, False, New Structure("Type", ProductType)),
		TableItem
	);

EndProcedure
```
```bsl
&AtClient
Procedure Pick(Command)
	OpenForm("Catalog.Products.ChoiceForm", New Structure("ChoiceMode, CloseOnChoice", True, False), Items.Products);
EndProcedure
```
- Đúng ví dụ của bài: giới hạn products có `Type = Enum.ProductTypes.Product` — `New Structure("Type", ProductType)` được truyền làm form parameter `Filter`.
- Ở PurchaseInvoice, standard parameters `ChoiceMode` và `CloseOnChoice` được truyền qua Structure; Owner là table `Items.Products` → giá trị chọn đi vào event `ProductsChoiceProcessing`.
- [ghi chú ngoài nguồn] Key `CloseOnChoise` trong SalesInvoice là lỗi chính tả của code demo (standard parameter đúng là `CloseOnChoice`, như trong PurchaseInvoice); platform không nhận key sai này nên `CloseOnChoice` giữ giá trị mặc định.

### Conditional appearance và footer (thiết lập trong Form.xml, không có code)
Nguồn: nhánh lesson/10-theory — cf/Documents/SalesInvoice/Forms/DocumentForm/Ext/Form.xml
```xml
			<dcsset:item>
				<dcsset:selection>
					<dcsset:item>
						<dcsset:field>Products</dcsset:field>
					</dcsset:item>
				</dcsset:selection>
				<dcsset:filter>
					<dcsset:item xsi:type="dcsset:FilterItemComparison">
						<dcsset:left xsi:type="dcscor:Field">Object.Products.Amount</dcsset:left>
						<dcsset:comparisonType>GreaterOrEqual</dcsset:comparisonType>
						<dcsset:right xsi:type="xs:decimal">1000000</dcsset:right>
					</dcsset:item>
				</dcsset:filter>
				<dcsset:appearance>
					<dcscor:item xsi:type="dcsset:SettingsParameterValue">
						<dcscor:parameter>TextColor</dcscor:parameter>
						<dcscor:value xsi:type="v8ui:Color">#4BB859</dcscor:value>
					</dcscor:item>
				</dcsset:appearance>
			</dcsset:item>
```
- Đây là ví dụ "đổi màu chữ dòng trong table Products nếu amount > 1 triệu": điều kiện `Object.Products.Amount` **GreaterOrEqual** `1000000`, appearance **TextColor**, áp dụng cho field `Products`.
- Cùng Form.xml, cột `ProductsQuantity` có `FooterDataPath` = `Object.Products.TotalQuantity` (connection with collection totals); cột `ProductsWieght` có DataPath `Object.Products.Product.Weight` (connection through reference, luôn View only).

## Video tham khảo

Video bài giảng trên YouTube có phạm vi trùng với bài này. Khi dẫn cho người học, nói "Bạn có thể tham khảo thêm về <chủ đề> của khóa tại đây: [<tên video>](link)" — không nói "khóa cũ/Junior", không dùng mã JC (mã JC trong danh sách chỉ để tra nội bộ). Quy ước đầy đủ: `references/video.md#video-junior-course`.

- [Giao diện người dùng cơ bản](https://www.youtube.com/watch?v=rn0hEz5Xc08&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=7) (5:44) — Bài 3 — Subsystem (sơ lược); Bài 9 — Subsystems, Panels, command interface _(mã nội bộ JC-8)_
- [Homepage, form và command](https://www.youtube.com/watch?v=DDk5kS4BRow&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=8) (5:11) — Bài 9 — Home page, form; Bài 14 — Commands, Command interface _(mã nội bộ JC-9)_
- [Cơ bản về trình chỉnh sửa form](https://www.youtube.com/watch?v=FqrPnmv_QPA&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=9) (7:05) — Bài 9 — form attributes, form items, groups, DataPath _(mã nội bộ JC-10)_
- [Sự kiện và trình xử lý sự kiện](https://www.youtube.com/watch?v=FAkymD2Zqks&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=10) (9:29) — Bài 9 — form events; Bài 16 — form & form element events, thứ tự events _(mã nội bộ JC-11)_
- [Cơ bản về UX-UI](https://www.youtube.com/watch?v=Fsfbuzgyutk&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=30) (6:39) — Bài 9 — bố cục form, groups. Ngoài giáo trình: nguyên lý thiết kế giao diện (công thái học) không có trong giáo trình _(mã nội bộ JC-31)_
- [Phần tử trường](https://www.youtube.com/watch?v=KmiQm3DJ4AQ&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=31) (5:32) — Bài 9 — form items (field). Ngoài giáo trình: các loại field chi tiết, mặt nạ nhập liệu (mask), định dạng hiển thị không có mục riêng trong giáo trình _(mã nội bộ JC-32)_
- [Giao diện lệnh (command) trên biểu mẫu (form)](https://www.youtube.com/watch?v=4sYHynvvbls&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=34) (6:29) — Bài 9 — form commands, command bar; Bài 14 — commands. Ngoài giáo trình: gán phím tắt cho command không có trong giáo trình _(mã nội bộ JC-35)_
- [Hiển thị có điều kiện](https://www.youtube.com/watch?v=a6kSspz-wo4&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=35) (10:29) — Bài 9 — conditional appearance trên form; Bài 18 — conditional appearance trong DCS _(mã nội bộ JC-36)_
- [Danh sách động (Dynamic list)](https://www.youtube.com/watch?v=rr_ohZ13H6k&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=36) (4:53) — Bài 9 — Dynamic list (bảng hoặc query tùy ý); Bài 10 — query language _(mã nội bộ JC-37)_
- [Trò chuyện với người dùng](https://www.youtube.com/watch?v=s0MHq7d_nVc&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=38) (9:26) — Bài 9 — ShowQueryBox + CallbackDescription (code mẫu); Bài 7 — dialog không chặn (CallbackDescription); Bài 21 — ShowUserNotification _(mã nội bộ JC-39)_

<!-- video-qa-thuchanh:start -->

Video giải đáp tình huống thực chiến và video thực hành từng bước liên quan tới bài này (thẻ chi tiết, triệu chứng, lưu ý khi giới thiệu: `references/video.md#video-qa-thuc-chien`, `references/video.md#video-thuc-hanh`; cùng mẫu câu dẫn ở trên):

- [Cách hiển thị biểu ghi tích lũy lên phân hệ](https://www.youtube.com/watch?v=DBJeS7LfUpY&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=4) (1:53) — cách hiện register lên phân hệ (giải đáp tình huống; Bài 9 chính) _(mã nội bộ QA-4)_
- [Báo động tồn kho thấp với màu chữ hiển thị](https://www.youtube.com/watch?v=0JbOMl80lnY&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=18) (13:09) — tô màu cảnh báo tồn kho thấp (giải đáp tình huống; Bài 9 chính) _(mã nội bộ QA-18)_
- [Lọc dữ liệu chọn sản phẩm theo hãng](https://www.youtube.com/watch?v=EfF2acfP2Y8&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=19) (6:30) — lọc danh sách chọn theo một trường khác (giải đáp tình huống; Bài 9 chính) _(mã nội bộ QA-19)_
- [Thay đổi Style (màu sắc) của chương trình](https://www.youtube.com/watch?v=cgmDdh6bHMg&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=24) (2:47) — đổi màu giao diện bằng Style (giải đáp tình huống; Bài 9 chính) _(mã nội bộ QA-24)_
- [Fix lỗi không tính toán Thành tiền khi thay đổi Số lượng](https://www.youtube.com/watch?v=LRRNf8MxoQw&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=1) (4:24) — cách tìm lỗi sự kiện OnChange không chạy (giải đáp tình huống; Bài 9 liên quan) _(mã nội bộ QA-1)_
- [Thêm ảnh cho các đối tượng](https://www.youtube.com/watch?v=TQNa4cveOdc&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=6) (10:04) — lưu và hiển thị ảnh cho sản phẩm (giải đáp tình huống; Bài 9 liên quan) _(mã nội bộ QA-6)_
- [Hiển thị đối tượng Siêu dữ liệu lên Quick menu](https://www.youtube.com/watch?v=rPSNKvFEQ8E&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=21) (2:23) — bật lệnh cho phân hệ đang trống (giải đáp tình huống; Bài 9 liên quan) _(mã nội bộ QA-21)_
- [Extension (Phần mở rộng) trong 1C:Enterprise](https://www.youtube.com/watch?v=T_DEaA1p_bA&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=22) (6:33) — thêm báo cáo bằng extension mà không sửa cấu hình gốc (giải đáp tình huống; Bài 9 liên quan) _(mã nội bộ QA-22)_
- [Tạo lập hệ thống thông tin thư viện](https://www.youtube.com/watch?v=3DMFgUjg2Js&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=5) (24:38) — mượn – trả và tạo phiếu trả từ phiếu mượn (thực hành case study; Bài 9 liên quan) _(mã nội bộ P2-5)_
- [Hệ thống thông tin cửa hàng nhỏ](https://www.youtube.com/watch?v=zXa4pQv0LHE&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=6) (12:28) — xử lý nhiều đơn hàng bằng một lệnh (thực hành case study; Bài 9 liên quan) _(mã nội bộ P2-6)_

<!-- video-qa-thuchanh:end -->


---

# § bai-10

# Bài 10 — Query language (Ngôn ngữ truy vấn)

## Khái niệm chính

### Query object và query text
- Nền tảng 1C dùng đối tượng đặc biệt **Query** để tạo và thực thi truy vấn tới các bảng cơ sở dữ liệu. Query tiện dùng khi cần lấy tập dữ liệu phức tạp, được nhóm và/hoặc sắp xếp; ví dụ kinh điển: tổng hợp trạng thái của register tại một thời điểm, lấy thông tin theo các lát cắt thời gian khác nhau.
- 1C dùng ngôn ngữ truy vấn giống SQL (SQL-like). Khi thực thi, nền tảng tự động chuyển query text sang văn bản truy vấn phù hợp với SQL server đang dùng.
- Nguồn dữ liệu (data sources) của query: bảng cơ sở dữ liệu, value table truyền vào query parameters, và temporary tables.
- Bảng cơ sở dữ liệu chia làm 2 lớp:
  - **Real tables**: được lưu trong database; có thể có các trường tính toán (calculable fields) được tính từ nhiều trường thật.
  - **Virtual tables**: không lưu trong database; khi truy cập, hệ thống tự thu thập thông tin từ các real tables. Virtual table có thể được tham số hóa (parameterized) — nội dung thực tế phụ thuộc giá trị tham số chỉ định trong query text. Mỗi virtual table có tên riêng để dùng trong query. (Chi tiết ở các bài về information register và accumulation register.)

### Các phần (section) của query
- Query text luôn bắt đầu bằng từ khóa bắt buộc **SELECT** — đây là từ khóa bắt buộc duy nhất, các từ khóa khác là tùy chọn.
- **Selection fields**: liệt kê sau SELECT, cách nhau bằng dấu phẩy. Dùng `*` để chọn tất cả trường.
- **AS**: đặt alias cho trường (hoặc cho nguồn dữ liệu). Có thể dùng biểu thức làm selection field (ví dụ `Quantity * Price AS Amount`). Nếu không đặt alias cho biểu thức, nền tảng tự gán (ví dụ `Field1`).
- **FROM**: chỉ định một hoặc nhiều nguồn dữ liệu.
- **WHERE**: điều kiện lọc; có thể dùng cả các trường không được chọn trong query. Điều kiện luôn là biểu thức logic (True/False). Có thể dùng thao tác trên selection fields, predefined values, giá trị kiểu nguyên thủy, query parameters, virtual fields.
- **Comment** trong query không ảnh hưởng gì; viết bằng 2 cách: (1) xuống dòng trong query text; (2) không xuống dòng — sau hai ký tự `//`.
- **GROUP BY**: các bản ghi có cùng giá trị ở các trường nhóm sẽ được "gộp" thành một bản ghi; các trường còn lại dùng aggregate functions: `SUM`, `COUNT(DISTINCT <field>)`, `COUNT`, `MAX`, `MIN`, `AVG`.
- **ORDER BY**: sắp xếp theo trường/biểu thức; `DESC` = giảm dần, mặc định tăng dần. Trường dùng để sắp xếp không bắt buộc phải có trong kết quả query.
- **HIERARCHY** (sắp xếp theo phân cấp, cho đối tượng phân cấp như catalog): trước tiên sắp xếp các parent từ cấp cao nhất, rồi cấp tiếp theo của mỗi parent, v.v. Giảm dần: `<field name> HIERARCHY DESC` (HIERARCHY đứng trước).
- **ALLOWED**: query chỉ chọn các bản ghi mà user hiện tại có quyền. Nếu không có, query báo lỗi khi gặp bản ghi user không có quyền. Chỉ ghi ở mệnh đề SELECT cấp cao nhất và áp dụng cho toàn bộ query (kể cả nested queries). Chỉ có tác dụng nếu bảng có data access restrictions. Quyền truy cập bảng không được xét: nếu bảng không có quyền READ, query vẫn lỗi dù có ALLOWED.
- **DISTINCT**: loại bỏ các dòng trùng lặp khỏi kết quả.
- **TOP <Count>**: giới hạn số dòng của kết quả (lấy các dòng đầu tiên theo quy tắc sắp xếp); số lượng là số nguyên. Có thể ORDER trong nested queries nếu nested query có TOP.
- **HAVING <Filter condition>**: đặt điều kiện cho giá trị aggregate function (WHERE không cho phép dùng aggregate function). Thứ tự: nhóm (GROUP BY) trước, rồi áp điều kiện HAVING.
- **Nested table trong selection field list**: nếu chọn tabular section của nguồn, trường kết quả có kiểu **QueryResult** (kết quả nested query). Khi Unload sang value table, kết quả lồng cũng được unload thành value table lồng. Mặc định nested result gồm mọi trường của nested table; có thể chỉ định trường trong ngoặc, hoặc `*` để chọn tất cả. Lấy dữ liệu từ trường này bằng `Select()` hoặc `Unload()`.

### Thực thi query và lấy kết quả
- `Text` property: gán query text cho Query object.
- `SetParameter()`: đặt giá trị tham số; đối số 1 = tên tham số, đối số 2 = giá trị. Tham số trong query text viết `&ParameterName`.
- `Execute()`: hàm trả về đối tượng kiểu **QueryResult**.
- Lấy dữ liệu từ QueryResult theo 2 cách:
  - `Select()` → đối tượng kiểu **Selection**: duyệt từng dòng; chỉ lưu dữ liệu một bản ghi tại một thời điểm → ít tốn bộ nhớ.
  - `Unload()` → đối tượng kiểu **ValueTable**: lấy toàn bộ một lần; Value table lưu trong RAM nên dữ liệu càng nhiều càng tốn bộ nhớ.
  - Chọn cách nào tùy vào nhiệm vụ.

### Query wizard
- Công cụ tạo query text bằng giao diện; mở từ context menu của module hoặc mục "Text" trên main menu.
- 2 biến thể: **query wizard** (chỉ tạo query text) và **query wizard with result processing** (có thêm tab result processing ở vị trí đầu; sinh sẵn code tạo Query object, gán text, thực thi, tạo selection và duyệt selection).
- Code đặt tham số KHÔNG được wizard sinh ra — phải tự viết.
- Nếu mở wizard ngoài khối code chứa kết quả query trước đó, nền tảng báo không tìm thấy query text, hỏi có tiếp tục không.
- Tab "Tables and fields": 3 danh sách — tất cả bảng của infobase, bảng đã chọn, selection fields.
- Tab "Order": ban đầu chỉ thấy các trường đã chọn; để sắp xếp theo trường khác, mở node "All fields". Cột Sort chọn thứ tự (ví dụ "Hierarchy, descending").
- Tab "Links": cấu hình join; flag **All** = chọn tất cả bản ghi từ bảng đó; tắt flag thì chỉ chọn bản ghi thỏa điều kiện nối.
- Có thể thêm nested query và đổi tên bảng nested query (tăng tính dễ đọc).
- Query batch trong wizard: query đưa dữ liệu vào temporary table hiển thị bằng tên temporary table; query hủy temporary table hiển thị bằng dấu trừ + tên (ví dụ "- Purchases"); query thường hiển thị là "Query Batch N" (N bắt đầu từ 1).
- Wizard báo lỗi khi mở query có UNION với số trường khác nhau.

### Joins
- Khi chọn từ nhiều nguồn mà không nối, kết quả là mọi tổ hợp của tất cả bản ghi (ví dụ 3 × 3 = 9 dòng).
- 4 loại join:
  - `[INNER] JOIN <Source description> BY <Filter condition>`
  - `LEFT JOIN <Source description> BY <Filter condition>`
  - `RIGHT JOIN <Source description> BY <Filter condition>`
  - `FULL JOIN <Source description> BY <Filter condition>`
- Trong 1C thực tế chỉ dùng 3 loại vì RIGHT join có thể biểu diễn bằng LEFT join — query wizard tự đổi RIGHT join thành LEFT join khi kết thúc.
- Danh sách join có thể mô tả nhiều join của nhiều nguồn cùng lúc.
- Từ khóa INNER có thể bỏ qua (chỉ tăng tính dễ đọc).
- Các nguồn nối không tương đương: kết quả có thể phụ thuộc bảng nào đứng trước (bên trái JOIN) và bảng nào đứng sau (bên phải).
- **INNER**: chỉ lấy các tổ hợp bản ghi thỏa điều kiện từ cả hai bảng.
- **LEFT**: lấy tất cả bản ghi của nguồn thứ nhất; bản ghi nguồn thứ hai chỉ lấy khi thỏa điều kiện; nếu không có bản ghi phù hợp, trường từ nguồn thứ hai = **NULL**.
- **FULL**: lấy tất cả bản ghi của cả hai nguồn; nối khi thỏa điều kiện; phía không tìm thấy bản ghi phù hợp chứa NULL.

### Nested tables và nested queries
- Danh sách nguồn có thể chứa nested tables — tabular sections của catalog và document. Tabular section có trường **Ref** lưu link tới owner (catalog, document); dùng trường này để nối các tabular section với nhau hoặc với owner.
- Nested query có thể dùng làm nguồn; mô tả giống query thường.
- Join bảng với nested query có thể làm giảm hiệu năng (DBMS optimizer có thể lập query plan sai).
- Ví dụ lỗi: nối document với cả hai tabular section Products (3 dòng) và Services (1 dòng, 1000) qua Ref → mỗi dòng Products nhận giá trị Services 1000 → tổng Services = 3000 (sai). Cách đúng: tính tổng Products và Services riêng (nested queries) rồi mới nối.

### Merging queries (UNION)
- Mỗi query trong union thu dữ liệu độc lập; ordering và tính totals thực hiện trên kết quả đã merge.
- Tên trường kết quả lấy theo danh sách selection fields của query đầu tiên; các trường của query còn lại khớp theo thứ tự xuất hiện.
- Các query merge phải có cùng số trường.
- Nếu các trường tương ứng có kiểu khác nhau → trường kết quả có kiểu composite.
- `UNION`: loại bỏ bản ghi trùng hoàn toàn giữa các query (chỉ giữ bản ghi đầu tiên). `UNION ALL`: giữ tất cả bản ghi.
- Grouping áp dụng riêng cho từng query trong union → muốn gộp kết quả union, đặt union vào nested query rồi GROUP BY từ nested query đó.

### Calculating query totals (TOTALS)
- Mệnh đề **TOTALS** xác định totals cần tính; giá trị aggregate được tính theo các tập dữ liệu có cùng giá trị checkpoint fields; totals được thêm vào kết quả như các totals rows.
- Bắt đầu bằng từ khóa bắt buộc TOTALS; danh sách aggregate functions: SUM, AVG, MIN, MAX, COUNT, COUNT (DISTINCT).
- **OVERALL**: tạo totals row cho toàn bộ kết quả.
- Totals theo checkpoints: sau từ khóa bắt buộc **BY**, liệt kê các grouping fields làm checkpoints.
- Nếu trường nhóm totals là reference tới catalog, có thể tính totals theo hierarchy: thêm từ khóa **HIERARCHY** sau reference đó.

### Expressions — Built-in functions
- Dùng được trong selection fields, filter conditions của join, và điều kiện WHERE. Danh sách xem trong cửa sổ custom expression; trợ giúp: tìm "Functions of query language".
- **DATEDIFF(<Date1>, <Date2>, <Type>)**: lấy Date2 trừ Date1, trả về số đơn vị theo Type (SECOND, MINUTE, HOUR, DAY, MONTH, QUARTER, YEAR); chỉ tính chênh lệch của đơn vị chỉ định, không xét các đơn vị còn lại (cả hai ví dụ trong tài liệu đều trả về 1).
- **VALUETYPE(<Expression>)**: trả về giá trị kiểu Type; nếu tham số là Undefined thì trả về Undefined.

### Selection operations (CASE)
- Các WHEN ... THEN được xử lý tuần tự; khi biểu thức logic là True thì kết thúc, kết quả là biểu thức sau THEN. Nếu mọi điều kiện đều False → dùng giá trị sau ELSE.

### Type casting (CAST)
- Dùng trong selection fields và WHERE. Ép biểu thức về kiểu nguyên thủy hoặc reference type (khi đó dùng tên bảng infobase tương ứng).
- Nếu kiểu composite có chứa kiểu cần ép → giá trị đúng kiểu giữ nguyên, giá trị kiểu khác → NULL.
- Nếu kiểu composite KHÔNG chứa kiểu cần ép → query thất bại với lỗi.

### Constants và parameters
- Literal: TRUE, FALSE, Number, String, Date (`DATETIME(...)`), Type (`TYPE(<Type name>)`), parameter (`&ParameterName`), UNDEFINED, NULL.
- Boolean, Number, String đặt giống như trong 1C:Enterprise language.
- Date: `DATETIME(năm, tháng, ngày[, giờ, phút, giây])` — 3 giá trị cuối là tùy chọn.
- Ngày tối đa với DATETIME: **31.12.3999 23:59:59**.
- `TYPE(<Type name>)`: Type name là tên kiểu nguyên thủy hoặc tên bảng có reference type cần lấy; kết quả là giá trị kiểu **Type**.

### Conditions và logical expressions
- Toán tử logic: **Not** (ưu tiên cao nhất) → **And** → **Or** (thấp nhất). Biểu thức logic đơn được tính trước, rồi Not, And, Or. Dùng ngoặc tròn () để đổi thứ tự.
- Các dạng logical expression:
  - `<Expression>`
  - `(<Expression> | <Logical expression>) <Comparison operation> (<Expression> | <Logical expression>)`
  - `<Expression> [Not] IN [HIERARCHY] (<Value list>)`
  - `<Expression> [Not] IN [HIERARCHY](<Query description>)`
  - `<Expression> [Not] BETWEEN <Expression> AND <Expression>`
  - `<Expression> IS [Not] NULL`
  - `<Expression> REFS <Table name>`
  - `<Expression> [Not] LIKE <STRING type literal> [Special character <STRING type literal>]`
- Comparison operations: `>`, `<`, `=`, `>=`, `<=`, `<>`.

### Value comparison rules
- Áp dụng cho: comparison operators; MIN/MAX; sắp xếp ORDER BY.
- Ưu tiên kiểu khi kiểu khác nhau (thấp → cao): NULL → Undefined → Boolean → Number → Date → String → Reference types. Giữa các reference types: theo internal table reference numbers.
- Cùng kiểu:
  - Boolean: True > False.
  - Number: quy tắc so sánh số thông thường.
  - Date: ngày sớm hơn nhỏ hơn.
  - String: theo đặc tính quốc gia của database và thứ tự sắp xếp; **không phân biệt hoa thường**; **không xét khoảng trắng cuối** (khác với 1C:Enterprise language: "bb" và "bb " → False trong ngôn ngữ, True trong query). Không đảm bảo sắp xếp giống nhau trên các DBMS khác nhau.
  - Reference types và UUID: so sánh theo giá trị; chỉ đảm bảo lặp lại trong cùng một database.
  - Không hỗ trợ so sánh UUID với kiểu khác.
  - Không cho phép so sánh trường có độ dài không giới hạn (string không giới hạn, ValueStorage, trường ValueType của chart of characteristic types).
- So sánh có ít nhất một NULL → kết quả NULL. Điều kiện (WHERE, BY, WHEN) có kết quả NULL → không thỏa.

### Các toán tử
- **IN**: kiểm tra giá trị có khớp một trong các giá trị liệt kê hoặc trong kết quả của query khác; **Not** đảo ngược.
- **IN HIERARCHY**: True nếu giá trị bên trái là reference tới phần tử catalog và nằm trong tập bên phải hoặc thuộc phân cấp của một group trong tập đó.
- IN cho nhiều trường: với nested query, với value table (truyền value table làm tham số, dùng N cột đầu), hoặc danh sách trực tiếp.
- **BETWEEN**: kiểm tra giá trị bên trái có nằm trong khoảng bên phải; NOT đảo ngược.
- **IS NULL**: không dùng `=` để kiểm tra NULL vì `NULL = NULL` luôn trả về False. Thường dùng với LEFT JOIN để lấy các dòng bảng chính không có dòng phù hợp ở bảng nối.
- **REFS**: kiểm tra giá trị bên trái có phải reference tới bảng chỉ định bên phải.
- **LIKE**: so khớp chuỗi với template; không phân biệt hoa thường trên mọi DBMS; giá trị phải kiểu String. Ký tự đặc biệt:
  - `%`: chuỗi bất kỳ số ký tự.
  - `_`: một ký tự bất kỳ.
  - `[...]`: một ký tự bất kỳ trong ngoặc; có thể dùng khoảng như a–z (gồm cả biên).
  - `[^...]`: bất kỳ ký tự nào trừ các ký tự sau dấu phủ định.
  - Muốn dùng ký tự đặc biệt như ký tự thường: đặt special character trước nó; special character được định nghĩa sau từ khóa **ESCAPE**.
  - Ví dụ template `"A_[0-9][a-z]\_e%"`: chữ A/a, một ký tự bất kỳ, một chữ số, một chữ cái, ký tự gạch dưới, chữ E/e; phía trước có thể có chuỗi ký tự bất kỳ.

### Query result iteration methods
- `Select()` và `Unload()` đều có tham số tùy chọn **TabOrderType** (kiểu duyệt) với 3 giá trị: `Linear` (mặc định), `ByGroupsWithHierarchy`, `ByGroups`.
- Nếu query có TOTALS, kết quả là cây → dùng `QueryResultIteration.ByGroupsWithHierarchy`: `Unload()` trả về **ValueTree**; `Select()` trả về Selection chỉ duyệt được cấp đầu — để duyệt cấp tiếp theo, gọi `Select()` trên từng Selection.
- Selection có phương thức `Level()` trả về cấp hiện tại, bắt đầu từ 0.

### Temporary tables
- Dùng temporary tables giúp tăng hiệu năng và đơn giản hóa việc đọc query text.
- 2 thành phần: đối tượng **TempTablesManager** (lưu dữ liệu temporary tables) và cú pháp query language để tạo/dùng temporary tables.
- Có thể tạo nhiều instance TempTablesManager, mỗi instance có tập temporary tables riêng; trong một manager, tên mỗi temporary table phải duy nhất (cũng là ID). Tên phải đáp ứng yêu cầu đặt tên biến của 1C:Enterprise language.
- Tạo bằng constructor `New`. Temporary table tồn tại chừng nào manager còn tồn tại; xóa manager → xóa mọi temporary table trong đó. Đóng cưỡng bức bằng `Close()` → xóa mọi bảng, không dùng tiếp manager được nữa.
- Query liên kết với manager qua property **TempTablesManager** của query.
- Tạo từ dữ liệu database: dùng từ khóa **INTO** + tên temporary table, đặt sau selection list. Kết quả (QueryResult) của query đó có selection gồm một dòng một cột **Count** = số bản ghi đã đưa vào temporary table.
- Lỗi nếu: manager chưa được đặt, hoặc đã đóng, hoặc đã có bảng cùng tên trong manager.
- Hàm **RECORDAUTONUMBER()**: thêm cột chứa số duy nhất vào temporary table.
- Tạo từ external source: chỉ định tên tham số chứa external source trong danh sách nguồn. External sources: Value table, Tabular section, Query result. Nếu cột trong value table không chỉ định kiểu → lỗi; dùng cột không có kiểu trong biểu thức (ví dụ CASE, ISNULL) → cũng lỗi.
- **Important**: temporary table tạo từ external source → query đó không được dùng UNION, JOIN, và không được dùng trường là attributes của trường bảng nguồn (ví dụ chọn ref tới company từ external source thì không chọn được attribute Address của catalog Companies trong cùng query).
- Dùng temporary table có sẵn: đặt manager cho Query qua property TempTablesManager, rồi truy cập temporary table theo tên như bảng thường.
- **DROP** + tên bảng: hủy temporary table khi không còn cần (temporary tables tốn tài nguyên máy chạy DBMS, hoặc máy hiện tại nếu infobase dạng file). Bảng không tồn tại → lỗi.
- Debug query có temporary tables:
  - `Query.ExecuteBatchWithIntermediateData()`.
  - Lấy dữ liệu từ manager: sau khi thực thi, manager lưu mọi bảng đã thêm và chưa bị drop; truy cập theo index hoặc tên qua `TempTablesManager.Tables`; `GetData()` trả về query result, rồi dùng `Select()`/`Unload()`.

### Batch queries
- Các query text trong batch cách nhau bằng dấu `;`. Thực thi tuần tự; temporary table tạo ra tồn tại đến hết batch hoặc đến khi bị hủy trong batch.
- Nếu Query có TempTablesManager, các temporary tables chưa bị drop trong batch sẽ được lưu vào manager. Có thể dùng và drop trong batch các temporary tables đã có sẵn trong manager.
- `Execute()`: thực thi tất cả, trả về kết quả của query cuối cùng.
- `ExecuteBatch()`: thực thi tất cả, trả về mảng kết quả theo thứ tự query; query drop temporary table có kết quả là **Undefined** (cũng nằm trong mảng).
- Batch dùng để lấy nhiều tập dữ liệu (có thể không liên quan nhau) trong một lần gọi database — không chỉ để tạo temporary tables.

## Cú pháp & ví dụ code

Chọn tất cả trường:
```bsl
"SELECT
|   *
|FROM
…
```

Biểu thức làm selection field:
```bsl
"SELECT
|   Products.Product AS Product,
|   Products.Quantity AS Quantity,
|   Products.Price,
|   Products.Quantity * Products.Price AS Amount
```

Cú pháp tổng quát:
```bsl
SELECT [ALLOWED] [DISTINCT] [TOP <Count>]
<Selection field list>
[FROM <Source list>]
[WHERE <Filter condition>]
[GROUP BY <Grouping fields>]
[HAVING <Filter condition>]
[ORDER BY <Sorting fields>]
```

UNION ALL trong nested query rồi GROUP BY:
```bsl
"SELECT
|   ProductsAndServices.Ref AS Ref,
|   SUM(ProductsAndServices.ProductsAmount) AS ProductsAmount,
|   SUM(ProductsAndServices.ServicesAmount) AS ServicesAmount
|FROM
|   (SELECT
|       SalesInvoiceProducts.Ref AS Ref,
|       SalesInvoiceProducts.Amount AS ProductsAmount,
|       0 AS ServicesAmount
|   FROM
|       Document.SalesInvoice.Products AS SalesInvoiceProducts
|    
|   UNION ALL
|    
|   SELECT
|       SalesInvoiceServices.Ref,
|       0,
|       SalesInvoiceServices.Amount
|   FROM
|       Document.SalesInvoice.Services AS SalesInvoiceServices) AS ProductsAndServices
|        
|GROUP BY
|   ProductsAndServices.Ref"
```

DATEDIFF:
```bsl
DATEDIFF(<Date1>, <Date2>, <Type>)

DATEDIFF(Date1, Date2, Year), where Date1 = 31.12.2021 15:00:00 and Date2 = 01.01.2022 13:00:00
DATEDIFF(Date1, Date2, Year), where Date1 = 01.01.2021 14:00:00 and Date2 = 31.12.2022 18:00:00
```

VALUETYPE:
```bsl
VALUETYPE(<Expression>)
```

Selection operation (CASE):
```bsl
CASE
<Selection alternatives>
[ELSE <Expression>]
END

WHEN <Logical expression>
THEN <Expression>
```

Type casting:
```bsl
CAST(<Expression> AS <Value type>)
```

Literals:
```bsl
TRUE
FALSE
<NUMBER type literal> (<Integer>[.<Integer>])
<STRING type literal> (<Character sequence>)
<DATE type literal> (DATETIME(<Integer>, <Integer>, <Integer>[, <Integer>, <Integer>, <Integer>])
<TYPE type literal> (TYPE(<Type name>))
<Parameter name> (&ParameterName)
UNDEFINED
NULL
```

Number:
```bsl
"SELECT
|	10 AS Integer,
|	12.45 AS Float"
```

String:
```bsl
"SELECT
|	""123abc"" AS FirstString,
|	""abcdefghijklmnop"" AS SecondString"
```

Date:
```bsl
"SELECT
|	DATETIME(2023, 12, 31) AS NewYearEve,
|	DATETIME(2024, 1, 1, 8, 30, 0) AS NewYearMorning"
```

Parameter:
```bsl
"SELECT
|	Products.Description AS Description,
|	Products.Type AS Type,
|	Products.Weight AS Weight
|FROM
|	Catalog.Products AS Products
|WHERE
|	Products.Ref = &Product"
```

Type:
```bsl
TYPE(String)
TYPE(Catalog.Products)

"SELECT
|	Counterparties.Description AS Description,
|	Counterparties.Contact AS Contact
|FROM
|	Catalog.Counterparties AS Counterparties
|WHERE
|	VALUETYPE(Counterparties.Contact) = TYPE(Catalog.Contacts)"
```

IN với danh sách giá trị:
```bsl
"SELECT
|	SalesInvoice.Ref AS Ref
|FROM
|	Document.SalesInvoice AS SalesInvoice
|WHERE
|	SalesInvoice.State IN (VALUE(Enum.SalesInvoiceStates.InDelivery), 
|					VALUE(Enum.SalesInvoiceStates.Finished))"
```

IN HIERARCHY:
```bsl
"SELECT
|	Products.Description
|FROM
|	Catalog.Products AS Products
|WHERE
|	Products.Ref IN HIERARCHY(&Group)"
```

IN HIERARCHY với query description:
```bsl
"SELECT
|	Products.Description
|FROM
|	Catalog.Products AS Products
|WHERE
|	Products.Ref IN HIERARCHY
|	(SELECT
|		Products.Ref
|	FROM
|		Catalog.Products AS Products
|	WHERE
|		Products.Description = ""Tools"")"
```

IN với kết quả query:
```bsl
// Select names of the products that were present in sales invoice documents
"SELECT
|	Products.Description AS Description
|FROM
|	Catalog.Products AS Products
|WHERE
|	Products.Ref IN
|		(SELECT
|			SalesInvoiceProducts.Product
|		FROM
|			Document.SalesInvoice.Products AS SalesInvoiceProducts)"
```

NOT IN:
```bsl
// Select names of the products that were present in sales invoices
"SELECT
|	Products.Description AS Description
|FROM
|	Catalog.Products AS Products
|WHERE
|	NOT Products.Ref IN
|		(SELECT
|			SalesInvoiceProducts.Product
|		FROM
|			Document.SalesInvoice.Products AS SalesInvoiceProducts)"
```
[ghi chú ngoài nguồn] Comment của ví dụ NOT IN trong tài liệu gốc giữ nguyên như ví dụ IN; về ý nghĩa, query này chọn các product KHÔNG có trong sales invoices.

IN cho nhiều trường — nested query:
```bsl
(expression1, expression2, …, expressionN) IN (SELECT expression1, expression2, …, expressionN FROM <DataSource>)

// Select PurchaseInvoice documents with company and vendor information, but only those in which the Company + Responsible coincides with the Company + Responsible of SalesInvoice documents
"SELECT
|	PurchaseInvoice.Ref AS Ref,
|	PurchaseInvoice.Company AS Company,
|	PurchaseInvoice.Vendor AS Vendor
|FROM
|	Document.PurchaseInvoice AS PurchaseInvoice
|WHERE
|	(PurchaseInvoice.Company, PurchaseInvoice.Responsible) IN
|			(SELECT
|				SalesInvoice.Company,
|				SalesInvoice.Responsible
|			FROM
|				Document.SalesInvoice AS SalesInvoice)"
```

IN — value table:
```bsl
(expression1, expression2, …, expressionN) IN (&Parameter)
```

IN — danh sách trực tiếp trong điều kiện:
```bsl
(expression1) IN ("Some string", 123, DATETIME(2023, 12, 31), True, VALUE(<MetadataClassName.MetadataObjectName.PredefinedValue>))

// Select sales documents in which the status is equal to one of several enumeration values
"SELECT
|	SalesInvoice.Ref AS Ref,
|	SalesInvoice.State AS State
|FROM
|	Document.SalesInvoice AS SalesInvoice
|WHERE
|	SalesInvoice.State IN (
|		VALUE(Enum.SalesInvoiceStates.Planned), 
|		VALUE(Enum.SalesInvoiceStates.InDelivery)
|	)"
```

BETWEEN:
```bsl
"SELECT
|	SalesInvoice.Ref AS SalesInvoice
|FROM
|	Document.SalesInvoice AS SalesInvoice
|WHERE
|	SalesInvoice.Date BETWEEN DATETIME(2023, 1, 1) AND &EndPeriod"
```

IS NULL:
```bsl
"SELECT
|	NULL IS NULL AS CorrectChecking,
|	NULL = NULL AS IncorrectChecking"
```

LEFT JOIN + IS NULL (bank accounts không dùng trong contract nào):
```bsl
"SELECT
|	BankAccounts.Ref AS Ref,
|	BankAccounts.Owner AS Owner
|FROM
|	Catalog.BankAccounts AS BankAccounts
|		LEFT JOIN Catalog.CounterpartyContracts AS CounterpartyContracts
|		ON BankAccounts.Ref = CounterpartyContracts.BankAccount
|WHERE
|	CounterpartyContracts.Ref IS NULL"
```

REFS:
```bsl
"SELECT
|	Counterparties.Description AS Description,
|	Counterparties.Contact AS Contact
|FROM
|	Catalog.Counterparties AS Counterparties
|WHERE
|	Counterparties.Contact REFS Catalog.Contacts"
```

LIKE:
```bsl
"SELECT
|	Counterparties.Ref AS Ref,
|	Counterparties.Contact AS Contact
|FROM
|	Catalog.Counterparties AS Counterparties
|WHERE
|	Counterparties.Contact LIKE ""M[rs][.]%[#][0-9]%"""
```

Unload kết quả có TOTALS vào Value tree:
```bsl
ValueTree = QueryResult.Unload(QueryResultIteration.ByGroupsWithHierarchy);
```

TempTablesManager:
```bsl
TempTablesManager = New TempTablesManager;
```

```bsl
Query = New Query;

// Creating a manager into a separate variable
TempTablesManager = New TempTablesManager;
Query.TempTablesManager = TempTablesManager;

// Creating a manager directly into the query property
Query.TempTablesManager = New TempTablesManager;
```

INTO:
```bsl
"SELECT
|   SalesInvoiceProducts.Product AS Product,
|   SalesInvoiceProducts.Ref AS SalesInvoice
|INTO ProductsByDocuments
|FROM
|   Document.SalesInvoice.Products AS SalesInvoiceProducts"
```

RECORDAUTONUMBER():
```bsl
"SELECT
|   SalesInvoiceProducts.Ref AS SalesInvoice,
|   SalesInvoiceProducts.Product AS Product,
|   RECORDAUTONUMBER() AS RecordNumber
|INTO TempTableProducts
|FROM
|   Document.SalesInvoice.Products AS SalesInvoiceProducts"
```

DROP:
```bsl
DROP TempTableProducts
```

Debug — lấy dữ liệu temporary table từ manager:
```bsl
TempTablesManager = New TempTablesManager;
Query = New Query;
Query.TempTablesManager = TempTablesManager;
Query.Text = 
    "SELECT
    |   SalesInvoiceProducts.Product AS Product,
    |   SalesInvoiceProducts.Ref AS SalesInvoice,
    |   SalesInvoiceProducts.Quantity AS Quantity,
    |   SalesInvoiceProducts.Amount AS Amount
    |INTO TempTableProducts
    |FROM
    |   Document.SalesInvoice.Products AS SalesInvoiceProducts";
QueryResult = Query.Execute();

// Get data from temp table of temp tables manager and then unload the query result to a ValueTable
SalesInvoicesProducts = TempTablesManager.Tables["TempTableProducts"].GetData().Unload(); // Option 1
SalesInvoicesProducts = TempTablesManager.Tables[0].GetData().Unload(); // Option 2
```

Batch query với temporary tables:
```bsl
Query = New Query;
Query.Text = 
"SELECT
|   PurchaseInvoiceProducts.Product AS Product,
|   MAX(PurchaseInvoiceProducts.Price) AS PriceOfPurchase
|INTO TempTablePurchasedProducts
|FROM
|   Document.PurchaseInvoice.Products AS PurchaseInvoiceProducts
|WHERE
|   PurchaseInvoiceProducts.Ref.Posted
|
|GROUP BY
|   PurchaseInvoiceProducts.Product
|;
|
|////////////////////////////////////////////////////////////////////////////////
|SELECT
|   SalesInvoiceProducts.Product AS Product,
|   MAX(SalesInvoiceProducts.Price) AS PriceOfSale
|INTO TempTableSoldProducts
|FROM
|   Document.SalesInvoice.Products AS SalesInvoiceProducts
|WHERE
|   SalesInvoiceProducts.Ref.Posted
|
|GROUP BY
|   SalesInvoiceProducts.Product
|;
|
|////////////////////////////////////////////////////////////////////////////////
|SELECT
|   TempTableSoldProducts.Product AS Product,
|   TempTableSoldProducts.PriceOfSale AS PriceOfSale,
|   TempTablePurchasedProducts.PriceOfPurchase AS PriceOfPurchase
|FROM
|   TempTablePurchasedProducts AS TempTablePurchasedProducts
|       INNER JOIN TempTableSoldProducts AS TempTableSoldProducts
|       ON TempTablePurchasedProducts.Product = TempTableSoldProducts.Product"; 
QueryResult = Query.Execute();
```

ExecuteBatch():
```bsl
Query = New Query;
Query.Text = 
"SELECT
|   PurchaseInvoiceProducts.Product AS Product,
|   SUM(PurchaseInvoiceProducts.Quantity) AS Quantity
|FROM
|   Document.PurchaseInvoice.Products AS PurchaseInvoiceProducts
|WHERE
|   PurchaseInvoiceProducts.Ref.Posted
|
|GROUP BY
|   PurchaseInvoiceProducts.Product
|;
|
|////////////////////////////////////////////////////////////////////////////////
|SELECT
|   SalesInvoiceProducts.Product AS Product,
|   SUM(SalesInvoiceProducts.Quantity) AS Quantity
|FROM
|   Document.SalesInvoice.Products AS SalesInvoiceProducts
|WHERE
|   SalesInvoiceProducts.Ref.Posted
|
|GROUP BY
|   SalesInvoiceProducts.Product";
QueryBatch = Query.ExecuteBatch(); // array with 2 query results
Purchases   = QueryBatch[0].Select();
Sales       = QueryBatch[1].Select();
```

[ghi chú ngoài nguồn] Một số ví dụ trong tài liệu gốc (query hợp đồng còn hiệu lực theo counterparty, HAVING, nested table trong selection, các ví dụ join, CASE, CAST, TOTALS, temporary table từ external source, dùng temporary table ở query 2) chỉ có dạng ảnh chụp màn hình, không có văn bản code nên không được chép lại. → ví dụ dùng temporary table ở query 2 → xem mục Code demo của bài Theory (nhánh lesson/10-theory); nested table, join, CASE, TOTALS → luyện qua Thẻ gợi ý bài thực hành; HAVING, CAST, query hợp đồng theo counterparty, temporary table từ external source vẫn chưa có.

## Thuộc tính/thiết lập quan trọng trong Designer
- Query object: property **Text**, **TempTablesManager**; methods **SetParameter()**, **Execute()**, **ExecuteBatch()**, **ExecuteBatchWithIntermediateData()**.
- QueryResult: **Select()**, **Unload()** (tham số TabOrderType: **Linear**, **ByGroupsWithHierarchy**, **ByGroups**).
- Selection: **Level()**.
- TempTablesManager: **Close()**, **Tables** (truy cập theo tên hoặc index), **GetData()**.
- Query wizard: tab **Tables and fields**, **Order** (node **All fields**, cột **Sort**), **Links** (flag **All**); biến thể **query wizard with result processing** có thêm tab **result processing**.
- Hàm hỗ trợ được dùng trong ví dụ: **BegOfDay()** (đưa ngày hiện tại về đầu ngày khi đặt tham số &StartDate, &EndDate).

## Lỗi thường gặp / lưu ý
- Dùng **query wizard with result processing** sau khi đã sửa code xung quanh → code tự viết bị thay bằng code chuẩn. Chỉ dùng biến thể này trước khi sửa code; sau đó chỉ dùng **query wizard** để sửa query text.
- Không dùng **DISTINCT** khi không cần (ví dụ chắc chắn không có bản ghi trùng) — tạo tải thêm, ảnh hưởng hiệu năng với dữ liệu lớn.
- Không dùng aggregate function trong WHERE — dùng HAVING. Đặt điều kiện tổng vào WHERE sẽ áp cho từng bản ghi riêng → kết quả sai.
- Không dùng subqueries trong filter conditions của join — làm chậm query đáng kể, có thể gây lỗi trên một số DBMS.
- Chỉ dùng nested queries khi không có join với bảng khác hoặc chắc chắn các bảng nối có rất ít bản ghi.
- Nối document với nhiều tabular section cùng lúc qua Ref → nhân dòng, tổng sai.
- UNION với số trường khác nhau → lỗi (query wizard không mở được).
- Grouping áp riêng cho từng query trong union — phải group lại kết quả union qua nested query.
- CAST sang kiểu không có trong composite type → query lỗi.
- Không dùng `=` để kiểm tra NULL (`NULL = NULL` → False); dùng IS NULL.
- So sánh string trong query bỏ qua khoảng trắng cuối và không phân biệt hoa thường — khác 1C:Enterprise language.
- LIKE ở chế độ client/server có thể không thực thi nếu template quá dài (giới hạn phụ thuộc DBMS).
- Value table dùng làm nguồn temporary table phải có kiểu cột; cột không có kiểu dùng trong CASE/ISNULL → lỗi.
- Temporary table từ external source: không dùng UNION, JOIN, attributes của trường nguồn trong cùng query.
- Tạo temporary table khi manager chưa đặt / đã đóng / trùng tên → lỗi. DROP bảng không tồn tại → lỗi.
- Tạo temporary table cẩn thận khi dữ liệu lớn; drop khi không còn cần.
- Value table nằm trong RAM — dữ liệu lớn tốn bộ nhớ.

## Điểm cần nhớ
- SELECT là từ khóa bắt buộc duy nhất; thứ tự: SELECT [ALLOWED] [DISTINCT] [TOP] → FROM → WHERE → GROUP BY → HAVING → ORDER BY (TOTALS ở cuối).
- `Execute()` → QueryResult → `Select()` (Selection, từng dòng) hoặc `Unload()` (ValueTable, toàn bộ trong RAM).
- Join: INNER (chỉ khớp), LEFT (tất cả bên trái, NULL nếu không khớp), FULL (tất cả hai bên); RIGHT được wizard đổi thành LEFT.
- UNION loại trùng, UNION ALL giữ tất cả; số trường phải bằng nhau; tên trường theo query đầu.
- HAVING lọc trên aggregate; WHERE lọc trên từng bản ghi.
- NULL: kiểm tra bằng IS NULL; mọi so sánh có NULL → NULL → điều kiện không thỏa.
- Temporary tables: TempTablesManager + INTO; DROP để giải phóng; batch cách nhau bằng `;`; ExecuteBatch() trả mảng kết quả.
- Query có TOTALS → duyệt bằng QueryResultIteration.ByGroupsWithHierarchy (Unload → ValueTree).

## Thẻ gợi ý bài thực hành (Practice 10)

> Thẻ gợi ý dẫn hướng cho từng yêu cầu của 10. Practice.docx; không có lời giải hoàn chỉnh. Làm theo thứ tự Gợi ý 1 → 2 → 3, chỉ mở gợi ý sau khi đã thử tự làm.

### Bài tập 1 — Object Warehouses và attribute Warehouse trong PurchaseInvoice / SalesInvoice
- **Đề bài (tóm tắt):** Chọn loại metadata object phù hợp để lưu danh sách kho (Warehouses), thêm attribute **Warehouse** vào PurchaseInvoice và SalesInvoice và đặt field lên form của hai document.
- **Gợi ý 1 — Hướng đi:** Danh sách kho là dữ liệu tham chiếu (master data) được nhiều document dùng lại → là **Catalog**, không phải document hay register.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Catalog `Warehouses` (Code, Description là đủ cho bài này); attribute `Warehouse` kiểu `CatalogRef.Warehouses` trong cả hai document; trên document form kéo attribute từ cây `Object` vào nhóm header.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo catalog `Warehouses`, đặt synonym số ít/số nhiều.
  2. Mở PurchaseInvoice → tab Data → thêm attribute `Warehouse`, chọn kiểu.
  3. Làm tương tự cho SalesInvoice.
  4. Mở document form của từng document, kéo field `Warehouse` lên header.
- **Lỗi hay gặp:**
  - Thêm attribute vào metadata nhưng quên đặt field lên form → user không nhập được.
  - Chọn kiểu String cho Warehouse thay vì reference → không chọn được từ danh sách, dễ gõ sai tên kho.
- **Tự kiểm tra:** Ở Enterprise mode tạo 2 kho, mở Purchase invoice và Sales invoice, chọn được kho từ danh sách và lưu được document.

### Bài tập 2 — Subsystem Warehouse
- **Đề bài (tóm tắt):** Thêm subsystem mới **Warehouse** và đưa catalog Warehouses vào đó.
- **Gợi ý 1 — Hướng đi:** Subsystem quyết định object xuất hiện ở section nào của command interface.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Nhánh Common → Subsystems → thêm `Warehouse`; trên tab Content của subsystem chọn `Catalog.Warehouses` (hoặc từ catalog: tab Subsystems → đánh dấu `Warehouse`).
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo subsystem, đặt synonym.
  2. Đưa `Warehouses` vào content.
  3. Cập nhật database configuration và mở Enterprise mode.
- **Lỗi hay gặp:**
  - Subsystem rỗng hoặc tắt "Include in command interface" → không thấy section mới.
- **Tự kiểm tra:** Section "Warehouse" xuất hiện trên sections panel và mở được list form của Warehouses.

### Bài tập 3 — Document InventoryTransfer
- **Đề bài (tóm tắt):** Tạo document chuyển hàng giữa hai kho: attributes **WarehouseSender**, **WarehouseRecipient**, tabular section **Products** (Product, Quantity); đưa vào subsystem Warehouse.
- **Gợi ý 1 — Hướng đi:** Mỗi lần chuyển hàng là một nghiệp vụ có ngày, số → **Document**; danh sách hàng chuyển là **tabular section**.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Document `InventoryTransfer`; hai attributes kiểu `CatalogRef.Warehouses`; tabular section `Products` với `Product` (`CatalogRef.Products`) và `Quantity` (Number); tab Subsystems → `Warehouse`.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo document, đặt synonym, numbering mặc định.
  2. Thêm 2 attributes kho và tabular section Products với 2 cột.
  3. Đưa document vào subsystem Warehouse.
  4. Tạo document form và list form (Form wizard).
- **Lỗi hay gặp:**
  - Đặt Quantity không có độ chính xác phù hợp (Length/Precision) → nhập số lẻ bị cắt.
  - Quên đưa vào subsystem → không mở được từ giao diện.
- **Tự kiểm tra:** Tạo và lưu được một Inventory transfer có 2 dòng hàng trong section Warehouse.

### Bài tập 4 — Bố cục form InventoryTransfer (2 cột header)
- **Đề bài (tóm tắt):** Header gồm 2 cột: trái có dòng 1 Number + Date, dòng 2 WarehouseSender; phải có WarehouseRecipient nằm ngang hàng với WarehouseSender.
- **Gợi ý 1 — Hướng đi:** Bố cục form điều khiển bằng **group** lồng nhau: group ngang chứa hai group dọc; khoảng trống được tạo bằng label decoration không có title (đúng gợi ý của đề).
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Form editor → tab Elements: một `UsualGroup` có Group = **AlwaysHorizontal** (header), bên trong hai `UsualGroup` Group = **Vertical** (trái, phải); trong group trái thêm group ngang cho Number + Date; ở group phải đặt `LabelDecoration` rỗng phía trên WarehouseRecipient, chỉnh property **Font** (cỡ chữ) để decoration cao bằng dòng Number/Date. Tắt hiển thị title/viền của group nếu cần (ShowTitle, Representation).
- **Gợi ý 3 — Khung bài làm:**
  1. Thêm group header ngang, kéo các field hiện có vào.
  2. Tạo group trái (dọc) và group phải (dọc).
  3. Trong group trái: group ngang Number/Date, rồi WarehouseSender.
  4. Trong group phải: decoration rỗng, rồi WarehouseRecipient.
  5. Xem trước bằng Enterprise mode, chỉnh Font của decoration tới khi thẳng hàng.
- **Lỗi hay gặp:**
  - Dùng Group = Horizontal (không phải AlwaysHorizontal) → khi form hẹp, nền tảng có thể xếp lại thành dọc.
  - Decoration có title → hiện chữ thừa.
- **Tự kiểm tra:** Mở document form ở Enterprise mode, WarehouseRecipient nằm đúng ngang hàng WarehouseSender khi thay đổi kích thước cửa sổ.

### Bài tập 5 — Nút "Pick" trên InventoryTransfer
- **Đề bài (tóm tắt):** Thêm nút "Pick" chọn hàng vào tabular section, hoạt động giống ở Purchase invoice / Sales invoice.
- **Gợi ý 1 — Hướng đi:** Mở choice form của Products ở chế độ chọn nhiều lần (không đóng sau mỗi lần chọn), kết quả trả về form owner là bảng Products, xử lý trong event **ChoiceProcessing** của bảng — đúng như đã làm ở hai document kia (Bài 9).
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Form command `Pick` (handler `&AtClient`), nút trên command bar của bảng Products; `OpenForm("Catalog.Products.ChoiceForm", ...)` với tham số structure `CloseOnChoice` = False và Filter theo loại product là hàng hóa (InventoryItem); event `ProductsChoiceProcessing` của item bảng: tìm dòng đã có bằng `FindRows`, nếu chưa có thì thêm dòng, Quantity = 1.
- **Gợi ý 3 — Khung bài làm:**
```bsl
&AtClient
Procedure ___(Command)
	// mở choice form của Products: owner = ___, CloseOnChoice = ___,
	// Filter chỉ lấy hàng hóa (không lấy service)
EndProcedure

&AtClient
Procedure ___(Item, SelectedValue, StandardProcessing)
	// tìm SelectedValue trong Object.Products bằng ___
	// nếu chưa có: thêm dòng, gán Product = ___, Quantity = ___
EndProcedure
```
- **Lỗi hay gặp:**
  - Không truyền owner (item bảng) cho `OpenForm` → event ChoiceProcessing không được gọi.
  - Không kiểm tra dòng trùng → cùng một product xuất hiện nhiều dòng.
  - So sánh enumeration trên client mà không dùng `PredefinedValue(...)`.
- **Tự kiểm tra:** Bấm Pick, chọn liên tiếp 3 product (có một product chọn 2 lần) → bảng có 3 dòng, không trùng, Quantity = 1; service không xuất hiện trong danh sách chọn.

### Bài tập 6 — Nút "Fill in by the remaining goods" (batch query với temporary tables)
- **Đề bài (tóm tắt):** Trên command bar của bảng Products: kiểm tra đã điền kho gửi; nếu bảng có dòng thì hỏi xác nhận (ShowQueryBox); nếu đồng ý thì xóa và điền số dư hàng tại ngày document = tổng mua đã post − tổng bán đã post, bằng **query batch** gồm temporary table Purchases, temporary table Sales và query cuối lấy hiệu.
- **Gợi ý 1 — Hướng đi:** Phần client (kiểm tra kho, hỏi user, callback) dùng đúng đoạn mẫu `CallbackDescription` / `ShowQueryBox` / `RunCallback` có sẵn trong đề. Phần server dùng **Temporary tables** + **Batch queries** (xem mục Temporary tables, Batch queries, Joins và IS NULL ở phần lý thuyết): query 1 gom số lượng mua theo product INTO Purchases, query 2 gom số lượng bán INTO Sales, query 3 nối hai bảng tạm và lấy hiệu.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Form command `FillInByTheRemainingGoods` (`&AtClient`), callback export `FillInByTheRemainingGoodsAnswer`, server procedure `FillInByTheRemainingGoodsAtServer` (`&AtServer`, vì cần chạy query và sửa `Object`).
  - Nguồn: tabular section `Document.PurchaseInvoice.Products` và `Document.SalesInvoice.Products`; điều kiện qua dấu chấm `...Ref.Posted` và `...Ref.Date < &Date`; `SUM(...)` + `GROUP BY Product`.
  - Query cuối: `Purchases` **LEFT JOIN** `Sales` theo Product; phần bán bọc bằng `ISNULL(..., 0)` vì product chưa bán sẽ ra NULL.
  - Nạp kết quả: `Object.Products.Load(<QueryResult>.Unload())` — tên cột kết quả phải trùng tên cột tabular section (Product, Quantity).
- **Gợi ý 3 — Khung bài làm:**
```bsl
&AtServer
Procedure FillInByTheRemainingGoodsAtServer()
	// Query.Text gồm 3 phần, cách nhau bằng ";"
	//  1) SELECT Product, SUM(Quantity) ... INTO ___ FROM tabular section mua, WHERE ___
	//  2) SELECT Product, SUM(Quantity) ... INTO ___ FROM tabular section bán, WHERE ___
	//  3) SELECT ... FROM Purchases LEFT JOIN Sales ON ___ (Quantity = mua - ISNULL(___))
	// SetParameter("Date", ___)
	// nạp kết quả query cuối vào Object.Products bằng ___
EndProcedure
```
- **Lỗi hay gặp:**
  - Quên điều kiện Posted → document chưa post (bản nháp) cũng bị tính.
  - Dùng `Sales.Quantity` trực tiếp, không `ISNULL` → dòng của product chưa bán có Quantity = NULL.
  - Đặt cả Purchases và Sales vào cùng một query bằng join tabular sections → nhân dòng, tổng sai (xem "Lỗi thường gặp" của bài).
  - Tham số `&Date` lấy theo ngày document: Purchases/Sales cùng giây với document không được tính khi dùng `<`; đây là chấp nhận được ở Bài 10.
  - [ghi chú ngoài nguồn] Đề bắt kiểm tra kho gửi nhưng công thức số dư trong đề không nhắc tới kho; lời giải tham khảo của khóa ở Bài 10 cũng không lọc theo kho (số dư chung mọi kho). Nếu muốn chính xác hơn, có thể thêm điều kiện theo attribute `Warehouse` của document mua/bán. Bài 11 sẽ viết lại thủ tục này để đọc từ accumulation register theo `WarehouseSender`.
- **Tự kiểm tra:** Tạo 2 Purchase invoice (post 1, để nháp 1) và 1 Sales invoice đã post → bấm nút, số lượng mỗi product = mua đã post − bán đã post; bấm lại khi bảng có dòng → hiện câu hỏi, chọn "No" thì bảng giữ nguyên. Đặt breakpoint trong procedure server để xem `Query.ExecuteBatch()` nếu muốn quan sát từng temporary table.

### Bài tập 7 — Catalog Banks
- **Đề bài (tóm tắt):** Catalog lưu danh sách ngân hàng, attributes **NationalCode**, Country, City, Address, CorrAccount.
- **Gợi ý 1 — Hướng đi:** Danh sách ngân hàng là master data → Catalog; Country có thể tham chiếu catalog Countries đã có.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Catalog `Banks`; NationalCode, City, Address, CorrAccount kiểu String; Country kiểu `CatalogRef.Countries`. NationalCode in đậm trong đề → nên đặt **Required field** = Display error.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo catalog, thêm 5 attributes.
  2. Đặt Required field cho NationalCode.
  3. Tạo item form, sắp xếp field hợp lý.
- **Lỗi hay gặp:**
  - Độ dài String quá ngắn cho Address/CorrAccount.
- **Tự kiểm tra:** Tạo một bank để trống NationalCode → không lưu được; điền đủ → lưu được.

### Bài tập 8 — Catalog BankAccounts (phụ thuộc Banks)
- **Đề bài (tóm tắt):** Danh sách tài khoản ngân hàng, không tồn tại nếu không gắn với một bank; attributes **AccountNumber**, OpeningDate, CloseDate.
- **Gợi ý 1 — Hướng đi:** "Không tồn tại nếu thiếu bank" → hoặc catalog **subordinate** (property Owners = Banks, standard attribute **Owner** bắt buộc), hoặc attribute Bank bắt buộc. [ghi chú ngoài nguồn] Ở 12. Practice, BankAccounts phải subordinate tới Companies/Counterparties, còn Bank là attribute bắt buộc — nếu chọn cách attribute ngay từ đầu thì Bài 12 sửa ít hơn.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Catalog `BankAccounts`; AccountNumber (String), OpeningDate, CloseDate (Date, phần Date only); Bank: `CatalogRef.Banks` với Required field.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo catalog, thêm các attributes.
  2. Quyết định cách liên kết với Banks và đặt kiểm tra bắt buộc.
  3. Tạo item form.
- **Lỗi hay gặp:**
  - Dùng kiểu Date có cả giờ cho OpeningDate/CloseDate.
  - Không đặt bắt buộc → lưu được tài khoản không có bank.
- **Tự kiểm tra:** Không lưu được bank account khi chưa chọn bank.

### Bài tập 9 — Subsystem Funds
- **Đề bài (tóm tắt):** Subsystem Funds chứa Banks và BankAccounts, có picture.
- **Gợi ý 1 — Hướng đi:** Giống Bài tập 2, thêm property **Picture** của subsystem.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Subsystem `Funds` → Content: Banks, BankAccounts (sau này thêm PaymentExpense, PaymentReceipt); property Picture: chọn từ thư viện picture hoặc common picture.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo subsystem, đặt synonym và Picture.
  2. Đưa hai catalog vào content.
- **Lỗi hay gặp:**
  - Quên picture → section hiện icon mặc định (đề yêu cầu có picture).
- **Tự kiểm tra:** Section Funds hiện với icon riêng, mở được hai list form.

### Bài tập 10 — Document PaymentExpense (tạo dựa trên PurchaseInvoice)
- **Đề bài (tóm tắt):** Document chi tiền: **BankAccount**, **Counterparty**, DocumentAmount, tabular section **PaymentDetails** (**Document** kiểu DocumentRef.PurchaseInvoice, **Amount**); thuộc Funds; tạo được dựa trên Purchase invoice: Counterparty = Vendor, thêm một dòng Document = invoice, Amount = Amount của invoice.
- **Gợi ý 1 — Hướng đi:** Phần "tạo dựa trên" là cơ chế **Generation** (tab Generation → Generated based on + event **Filling**) — được trình bày chi tiết ở Bài 11 (mục Generation); có thể đọc trước mục đó.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Document `PaymentExpense`, attributes và tabular section như đề; subsystem Funds.
  - Tab Generation → Generated based on: `Document.PurchaseInvoice`.
  - Object module, handler `Filling(FillingData, StandardProcessing)`: kiểm tra `TypeOf(FillingData)` là `DocumentRef.PurchaseInvoice`, gán header, thêm dòng vào `PaymentDetails`. Có thể dùng Generation settings wizard để sinh khung rồi sửa.
  - Tổng tiền của invoice: dùng attribute tổng tiền mà Purchase invoice của bạn đang có (ví dụ DocumentTotal) — đề gọi là "Purchase invoice Amount".
- **Gợi ý 3 — Khung bài làm:**
```bsl
Procedure Filling(FillingData, StandardProcessing)
	If TypeOf(FillingData) = Type("___") Then
		// header: Counterparty = ___ (Vendor của invoice)
		// PaymentDetails: thêm 1 dòng, Document = ___, Amount = ___
		// DocumentAmount = ___
	EndIf;
EndProcedure
```
- **Lỗi hay gặp:**
  - Không kiểm tra kiểu FillingData → lỗi khi tạo document mới bình thường (FillingData = Undefined).
  - Chạy lại Generation settings wizard sau khi đã sửa tay → code Filling bị thay toàn bộ.
  - [ghi chú ngoài nguồn] Cấu hình mẫu của khóa không có PaymentExpense/PaymentReceipt nên không có bản đối chiếu; tự kiểm tra kỹ bằng Enterprise mode.
- **Tự kiểm tra:** Mở một Purchase invoice → submenu Generate → Payment expense: Counterparty và dòng PaymentDetails được điền đúng.

### Bài tập 11 — Document PaymentReceipt (tạo dựa trên SalesInvoice)
- **Đề bài (tóm tắt):** Giống PaymentExpense nhưng cột Document kiểu DocumentRef.SalesInvoice; tạo dựa trên Sales invoice: Counterparty = Customer, một dòng với Document = invoice, Amount = tổng của invoice.
- **Gợi ý 1 — Hướng đi:** Cùng cơ chế Generation như Bài tập 10; có thể copy document PaymentExpense rồi đổi kiểu cột và nguồn Generation.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Document `PaymentReceipt`; Generated based on: `Document.SalesInvoice`; handler `Filling` kiểm tra kiểu `DocumentRef.SalesInvoice`, lấy `Customer`.
- **Gợi ý 3 — Khung bài làm:**
  1. Copy PaymentExpense → đổi tên, synonym.
  2. Đổi kiểu cột `PaymentDetails.Document`.
  3. Đổi Generated based on và điều kiện kiểu trong Filling, lấy Customer thay cho Vendor.
- **Lỗi hay gặp:**
  - Copy xong quên đổi kiểu trong `Type("...")` của Filling → không bao giờ điền.
- **Tự kiểm tra:** Từ Sales invoice → Generate → Payment receipt được điền Customer và một dòng đúng số tiền.

### Bài tập 12 — Nút "Fill in by balance" trên PaymentExpense / PaymentReceipt
- **Đề bài (tóm tắt):** Nếu chưa có counterparty → báo và dừng; nếu bảng có dòng → cảnh báo sẽ xóa và hỏi tiếp tục; nếu đồng ý → tìm mọi invoice đã post của counterparty chưa có trong payment document đã post nào, thêm vào bảng cùng số tiền.
- **Gợi ý 1 — Hướng đi:** Phần client giống hệt Bài tập 6 (ValueIsFilled → ShowQueryBox / RunCallback → callback). Phần server: query lấy invoices **không có** trong tabular section PaymentDetails của payment documents đã post — dùng **LEFT JOIN + IS NULL** (mục IS NULL của lý thuyết) hoặc `NOT IN (nested query)`.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Form command + callback export `&AtClient`; procedure điền `&AtServer`.
  - Query: bảng chính `Document.PurchaseInvoice` (hoặc SalesInvoice) lọc `Posted` và `Vendor`/`Customer = &Counterparty`; bảng nối `Document.PaymentExpense.PaymentDetails` với điều kiện nối gồm `...Ref.Posted`; WHERE phần bên phải `IS NULL`.
  - Đặt tên trường kết quả trùng tên cột tabular section (Document, Amount) để nạp bằng `Load(...Unload())`.
- **Gợi ý 3 — Khung bài làm:**
```bsl
&AtServer
Procedure ___()
	// SELECT invoice AS Document, tổng tiền AS Amount
	// FROM Document.___ AS Invoices
	//   LEFT JOIN tabular section PaymentDetails của payment AS Paid
	//   ON Paid.Document = ___ AND Paid.Ref.Posted
	// WHERE Invoices.Posted AND counterparty = &Counterparty AND Paid.___ IS NULL
	// nạp kết quả vào Object.PaymentDetails
EndProcedure
```
- **Lỗi hay gặp:**
  - Đặt điều kiện `Paid.Ref.Posted` vào WHERE thay vì điều kiện nối → LEFT JOIN thành INNER, mất đúng các dòng cần tìm.
  - Dùng `= NULL` thay cho `IS NULL`.
  - Không loại chính document đang sửa: nếu nó đã post, các invoice của nó bị coi là "đã thanh toán" — cân nhắc thêm điều kiện `Paid.Ref <> &Ref`.
- **Tự kiểm tra:** Có 3 invoice đã post của một counterparty, 1 invoice đã nằm trong payment đã post → nút điền đúng 2 dòng; đổi counterparty rỗng → hiện thông báo và không làm gì.

### Bài tập T1 — Sales order có tổng services không quá 1000
- **Đề bài (tóm tắt):** Query chọn các Sales order có tổng tiền services ≤ 1000.
- **Gợi ý 1 — Hướng đi:** Điều kiện trên **tổng** → aggregate + **HAVING**, không phải WHERE (mục "Lỗi thường gặp": không dùng aggregate trong WHERE).
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Nguồn là tabular section services của document Sales order trong cấu hình của bạn (nếu chưa có document Sales order, áp dụng cho Sales invoice); `SUM(Amount)`, `GROUP BY Ref`, `HAVING SUM(...) <= 1000`. Viết trong query console hoặc query wizard.
- **Gợi ý 3 — Khung bài làm:**
```bsl
// SELECT Services.Ref AS Document, SUM(___) AS AmountOfServices
// FROM Document.___.Services AS Services
// GROUP BY ___
// HAVING ___ <= 1000
```
- **Lỗi hay gặp:**
  - Document không có dòng service nào sẽ không xuất hiện (không có dòng để gom) — nếu muốn tính cả document "0 service" thì phải đi từ bảng document và LEFT JOIN.
- **Tự kiểm tra:** Đối chiếu kết quả với tổng tính tay của 2–3 document.

### Bài tập T2 — Sales order: services > 5000 và goods = 0
- **Đề bài (tóm tắt):** Chọn Sales order có tổng services > 5000 và tổng goods bằng 0.
- **Gợi ý 1 — Hướng đi:** Không join hai tabular sections trực tiếp qua Ref (nhân dòng, tổng sai). Gom từng tabular section riêng (nested query hoặc temporary table), rồi LEFT JOIN từ bảng document; "goods = 0" gồm cả trường hợp không có dòng goods → `ISNULL(..., 0) = 0`.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Hai temporary tables (`INTO`) hoặc hai nested queries; `ISNULL`; điều kiện ở WHERE của query cuối.
- **Gợi ý 3 — Khung bài làm:**
```bsl
// 1) SELECT Ref, SUM(Amount) AS ServicesAmount INTO ___ FROM ...Services GROUP BY Ref;
// 2) SELECT Ref, SUM(Amount) AS GoodsAmount INTO ___ FROM ...Products GROUP BY Ref;
// 3) SELECT Docs.Ref FROM Document.___ AS Docs
//      LEFT JOIN ___ ON ___   LEFT JOIN ___ ON ___
//    WHERE ISNULL(___, 0) > 5000 AND ISNULL(___, 0) = 0
```
- **Lỗi hay gặp:**
  - Join cả hai tabular sections cùng lúc → SUM bị nhân theo số dòng của bảng kia.
  - Dùng INNER JOIN cho phần goods → mất các document không có dòng goods (chính là các document cần tìm).
- **Tự kiểm tra:** Tạo một document chỉ có services 6000 và một document có services 6000 + 1 dòng goods → chỉ document đầu được chọn.

### Bài tập T3 — Products có tổng mua và tổng bán > 0 (TempTablesManager, chỉ document đã post)
- **Đề bài (tóm tắt):** Viết nhiều query riêng dùng chung một temporary table manager; query cuối chọn products có tổng mua > 0 và tổng bán > 0, chỉ tính Purchase Order và Sales Order đã post.
- **Gợi ý 1 — Hướng đi:** Đúng mẫu "TempTablesManager: tạo temporary table ở query 1, dùng ở query 2" của mục Code demo của bài Theory: nhiều object Query (hoặc nhiều lần Execute) dùng chung property `TempTablesManager`.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** `New TempTablesManager`; query 1 INTO bảng mua (lọc `Ref.Posted`), query 2 INTO bảng bán, query 3 **INNER JOIN** hai bảng tạm và điều kiện > 0. Code đặt trong server procedure (ví dụ common module server hoặc form `&AtServer`).
- **Gợi ý 3 — Khung bài làm:**
```bsl
// Manager = New ___;
// Query1.TempTablesManager = ___;  Query1.Text = "... INTO PurchasesTotals ..."; Execute
// Query2.TempTablesManager = ___;  Query2.Text = "... INTO SalesTotals ...";     Execute
// Query3: SELECT ... FROM PurchasesTotals INNER JOIN SalesTotals ON ___
//         WHERE ___ > 0 AND ___ > 0
```
- **Lỗi hay gặp:**
  - Query sau không gán cùng manager → lỗi "table not found".
  - Tạo temporary table trùng tên lần hai trên cùng manager → lỗi (DROP hoặc đóng manager trước).
- **Tự kiểm tra:** Trong debugger xem `Manager.Tables[0].GetData().Unload()` để kiểm tra từng bảng tạm trước khi chạy query cuối.

### Bài tập T4 — Products: từ lần mua cuối tới lần bán cuối không quá một tuần
- **Đề bài (tóm tắt):** Chọn products mà khoảng cách giữa lần mua cuối và lần bán cuối ≤ 7 ngày.
- **Gợi ý 1 — Hướng đi:** "Lần cuối" = `MAX(Ref.Date)` theo product; sau đó so sánh hai ngày bằng **DATEDIFF** (mục Expressions — Built-in functions).
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Hai nhóm dữ liệu (mua, bán) gom theo product bằng `MAX`; INNER JOIN theo product; `DATEDIFF(<ngày mua cuối>, <ngày bán cuối>, DAY)` trong WHERE.
- **Gợi ý 3 — Khung bài làm:**
```bsl
// LastPurchase: SELECT Product, MAX(___) AS PurchaseDate ... GROUP BY Product
// LastSale:     SELECT Product, MAX(___) AS SaleDate ... GROUP BY Product
// SELECT ... FROM LastPurchase INNER JOIN LastSale ON ___
// WHERE DATEDIFF(___, ___, DAY) ___ 7
```
- **Lỗi hay gặp:**
  - Đảo thứ tự tham số DATEDIFF → số âm; cân nhắc trường hợp bán trước mua (giá trị âm) có tính hay không.
  - DATEDIFF chỉ tính chênh lệch theo đơn vị chỉ định — đọc lại ví dụ trong lý thuyết.
- **Tự kiểm tra:** Tạo một product mua ngày 1, bán ngày 5 và một product mua ngày 1, bán ngày 20 → chỉ product đầu được chọn.

### Bài tập T5 — Mua và bán theo document trong kỳ, kết quả hai cấp (TOTALS)
- **Đề bài (tóm tắt):** Query 4 trường Product, Document, Quantity, Amount (tổng theo document) cho mua và bán trong khoảng StartDate–EndDate; kết quả hai cấp: cấp 1 là tổng theo product; sắp xếp theo tên product.
- **Gợi ý 1 — Hướng đi:** Gộp mua và bán bằng **UNION ALL** (số trường phải bằng nhau), group lại kết quả union qua nested query hoặc temporary table, rồi thêm **TOTALS ... BY Product**; duyệt bằng `QueryResultIteration.ByGroups` / `ByGroupsWithHierarchy` (mục Query result iteration methods).
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Trường Document có composite type (PurchaseInvoice hoặc SalesInvoice); điều kiện `Ref.Date BETWEEN &StartDate AND &EndDate`; `ORDER BY Product.Description`; `TOTALS SUM(Quantity), SUM(Amount) BY Product`.
- **Gợi ý 3 — Khung bài làm:**
```bsl
// SELECT Product, Ref AS Document, SUM(Quantity), SUM(Amount) FROM ...mua WHERE ___ GROUP BY ___
// UNION ALL
// SELECT Product, Ref, SUM(Quantity), SUM(Amount) FROM ...bán WHERE ___ GROUP BY ___
// ORDER BY ___
// TOTALS SUM(___), SUM(___) BY ___
```
- **Lỗi hay gặp:**
  - Đặt ORDER BY/TOTALS vào từng phần của union thay vì cuối toàn bộ query.
  - Sắp xếp theo Product (reference) thay vì `Product.Description` → thứ tự không theo tên.
  - Ngày kết thúc kiểu Date lúc 00:00:00 làm mất document trong ngày cuối — dùng `EndOfDay`.
- **Tự kiểm tra:** Chạy trong query console, xem kết quả dạng cây: dòng product có tổng bằng tổng các dòng document bên dưới.

### Bài tập T6 — Products: Description + Details "This is a group" / "This is not a group"
- **Đề bài (tóm tắt):** Hai trường; Details hiển thị chuỗi tùy theo product là group hay item.
- **Gợi ý 1 — Hướng đi:** Selection operation **CASE WHEN ... THEN ... ELSE ... END** trên standard attribute **IsFolder** của catalog phân cấp.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** `Catalog.Products` (Hierarchical, kiểu phân cấp folders and items); field `IsFolder`; chuỗi trong query đặt trong ngoặc kép (trong code 1C phải nhân đôi ngoặc kép).
- **Gợi ý 3 — Khung bài làm:**
```bsl
// SELECT Products.Description,
//   CASE WHEN ___ THEN ___ ELSE ___ END AS Details
// FROM Catalog.Products AS Products
```
- **Lỗi hay gặp:**
  - Viết chuỗi trong Query.Text mà quên nhân đôi ngoặc kép → lỗi cú pháp code 1C.
- **Tự kiểm tra:** Group và item đều xuất hiện với Details đúng.

### Bài tập T7 — Products KHÔNG nằm trong group có tên chứa "water"
- **Đề bài (tóm tắt):** Chọn products không thuộc (ở bất kỳ cấp nào) các group có description chứa từ "water".
- **Gợi ý 1 — Hướng đi:** **NOT IN HIERARCHY (nested query)** — nested query chọn các group có `Description LIKE "%water%"` (mục Các toán tử: IN HIERARCHY, LIKE).
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Nested query trên `Catalog.Products` với `IsFolder` và `LIKE`; query ngoài có `NOT ... IN HIERARCHY (...)`; cân nhắc loại group khỏi kết quả (`NOT IsFolder`) nếu chỉ muốn item.
- **Gợi ý 3 — Khung bài làm:**
```bsl
// SELECT Products.Ref FROM Catalog.Products AS Products
// WHERE NOT Products.Ref IN HIERARCHY (
//     SELECT Groups.Ref FROM Catalog.Products AS Groups
//     WHERE ___ AND Groups.Description LIKE ___ )
```
- **Lỗi hay gặp:**
  - Dùng `IN` thay cho `IN HIERARCHY` → chỉ loại item trực tiếp trong group, không loại item ở group con.
  - Template LIKE thiếu `%` ở hai đầu → chỉ khớp tên đúng bằng "water".
  - LIKE không phân biệt hoa thường — "Water" cũng khớp (đúng yêu cầu).
- **Tự kiểm tra:** Tạo group "Mineral water" có group con "Sparkling" chứa một item → item đó không có trong kết quả.

## Code demo của bài Theory (repo 1CJDCourse, nhánh lesson/10-theory)

> Phần query của Theory Bài 10 trong nhánh lesson/10-theory nằm ở common module `CommonServer` (Server). Function thứ hai `Qu()` của module trùng nguyên văn ví dụ `ExecuteBatch()` đã có ở mục "Cú pháp & ví dụ code" nên không chép lại.

### TempTablesManager: tạo temporary table ở query 1, dùng ở query 2
Nguồn: nhánh lesson/10-theory — cf/CommonModules/CommonServer/Ext/Module.bsl
```bsl
Function ContractSumsByCounterparties() Export
	
	TempTablesManager = New TempTablesManager;
	
	Query = New Query;
	Query.TempTablesManager = TempTablesManager;
	
	Query.Text = 
		"SELECT
		|	SalesInvoiceProducts.Product AS Product,
		|	SalesInvoiceProducts.Ref AS SalesInvoice,
		|	SalesInvoiceProducts.Quantity AS Quantity,
		|	SalesInvoiceProducts.Amount AS Amount
		|INTO TempTableProducts
		|FROM
		|	Document.SalesInvoice.Products AS SalesInvoiceProducts";

	QueryResult = Query.Execute();
	
	SecondQuery = New Query;
	SecondQuery.TempTablesManager = TempTablesManager;
	
	SecondQuery.Text = 
		"SELECT
		|	Products.Ref AS Product,
		|	SalesInvoiceProducts.SalesInvoice AS SalesInvoice,
		|	SalesInvoiceProducts.Quantity AS Quantity,
		|	SalesInvoiceProducts.Amount AS Amount
		|FROM
		|	Catalog.Products AS Products
		|		LEFT JOIN TempTableProducts AS SalesInvoiceProducts
		|		ON Products.Ref = SalesInvoiceProducts.Product";
	
	QueryResult = SecondQuery.Execute();
```
- Đúng ví dụ "dùng temporary table ở query 2" (trước đây chỉ có ảnh): hai object `Query` khác nhau dùng chung một `TempTablesManager` qua property `TempTablesManager`.
- Query 1 tạo bảng bằng `INTO TempTableProducts`; kết quả của nó chỉ có cột `Count`. Query 2 đọc `TempTableProducts` như bảng thường.
- `LEFT JOIN` từ `Catalog.Products`: product chưa bán vẫn có dòng, các trường từ temporary table là NULL.

### Đọc dữ liệu temporary table để debug, duyệt selection hai cấp, Level()
Nguồn: nhánh lesson/10-theory — cf/CommonModules/CommonServer/Ext/Module.bsl
```bsl
	// Get data from temp table and then unload the query result to a ValueTable
	ProductsFromSalesInvoices = TempTablesManager.Tables[0].GetData().Unload();
	
	SelectionProducts = QueryResult.Select();
	// First level selection
	While SelectionProducts.Next() Do
		SelectionDetailRecords = SelectionProducts.Select();
		
		Message("Total amount of product " + SelectionProducts.Product 
				+ " is " + SelectionProducts.Amount);
		
		// Second level selection
		While SelectionDetailRecords.Next() Do
			
			Message("Amount of product " + SelectionDetailRecords.Product 
					+ " at document " + SelectionDetailRecords.SalesInvoice 
					+ " is " + SelectionDetailRecords.Amount);
					
			// Current level of selection can be retrieved using the Level() method
			CurrentLevel = SelectionDetailRecords.Level();
		EndDo;
	
	EndDo;
	
	ValueTable = QueryResult.Unload();
	
EndFunction
```
- `TempTablesManager.Tables[0].GetData().Unload()` — cách xem dữ liệu temporary table khi debug: lấy bảng theo index, `GetData()` trả về query result, rồi `Unload()`.
- Selection lồng nhau: `SelectionProducts.Select()` lấy selection cấp con; `Level()` trả về cấp hiện tại.
- `QueryResult.Unload()` ở cuối đưa toàn bộ kết quả vào value table.
- [ghi chú ngoài nguồn] Query 2 không có `TOTALS`, nên selection không thực sự có nhóm (muốn có nhóm thật phải thêm `TOTALS` và duyệt bằng `QueryResultIteration.ByGroups` — xem mục Query result iteration methods và Bài tập T5 trong Thẻ gợi ý bài thực hành); function cũng không có `Return` — đây là code demo để quan sát trong debugger.
- [ghi chú ngoài nguồn] Nhánh lesson/10-theory không có code cho HAVING, CAST, query hợp đồng còn hiệu lực theo counterparty và temporary table từ external source.

## Video tham khảo

Video bài giảng trên YouTube có phạm vi trùng với bài này. Khi dẫn cho người học, nói "Bạn có thể tham khảo thêm về <chủ đề> của khóa tại đây: [<tên video>](link)" — không nói "khóa cũ/Junior", không dùng mã JC (mã JC trong danh sách chỉ để tra nội bộ). Quy ước đầy đủ: `references/video.md#video-junior-course`.

- [Cơ bản về ngôn ngữ Query 1](https://www.youtube.com/watch?v=wgEsimf_2ks&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=13) (11:42) — Bài 10 — SELECT, FROM, Query wizard _(mã nội bộ JC-14)_
- [Danh sách động (Dynamic list)](https://www.youtube.com/watch?v=rr_ohZ13H6k&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=36) (4:53) — Bài 9 — Dynamic list (bảng hoặc query tùy ý); Bài 10 — query language _(mã nội bộ JC-37)_
- [Cơ bản về ngôn ngữ truy vấn 2](https://www.youtube.com/watch?v=HJ2nTpet2yo&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=39) (5:33) — Bài 10 — parameters, Query wizard _(mã nội bộ JC-40)_
- [Truy vấn SQL và cấu trúc truy vấn](https://www.youtube.com/watch?v=E3EJ6WRG8Sk&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=40) (4:32) — Bài 10 — cấu trúc query; Bài 11 — virtual tables _(mã nội bộ JC-41)_
- [Mệnh đề SELECT](https://www.youtube.com/watch?v=gcvHm8ER72o&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=41) (6:34) — Bài 10 — SELECT, ISNULL, CASE, DISTINCT _(mã nội bộ JC-42)_
- [FROM và WHERE](https://www.youtube.com/watch?v=PtCdTq0a1nM&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=42) (5:58) — Bài 10 — FROM, WHERE; Bài 11 — lọc trong tham số virtual table _(mã nội bộ JC-43)_
- [JOIN](https://www.youtube.com/watch?v=Ukd1zPxIJqE&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=43) (7:23) — Bài 10 — LEFT / INNER / FULL JOIN _(mã nội bộ JC-44)_
- [GROUP BY và HAVING](https://www.youtube.com/watch?v=cCC-HVpGhJk&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=44) (5:10) — Bài 10 — GROUP BY, hàm tổng hợp, HAVING _(mã nội bộ JC-45)_
- [Query trong ngôn ngữ 1C Script](https://www.youtube.com/watch?v=Mws4QN1CdQY&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=45) (4:28) — Bài 10 — `New Query`, `.Text`, `SetParameter()`, `Execute()`, `Select()` / `Next()`, `Unload()` _(mã nội bộ JC-46)_

<!-- video-qa-thuchanh:start -->

Video giải đáp tình huống thực chiến và video thực hành từng bước liên quan tới bài này (thẻ chi tiết, triệu chứng, lưu ý khi giới thiệu: `references/video.md#video-qa-thuc-chien`, `references/video.md#video-thuc-hanh`; cùng mẫu câu dẫn ở trên):

- [Truy vấn tồn kho trong chứng từ bán hàng](https://www.youtube.com/watch?v=13817kAvhwQ&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=17) (9:53) — hiển thị tồn kho khi chọn hàng (giải đáp tình huống; Bài 10 chính) _(mã nội bộ QA-17)_
- [Thực hiện tính toán đơn giản với SQL trong 1C](https://www.youtube.com/watch?v=dP21dfHxkCo&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=23) (2:59) — tính toán ngay trong query (giải đáp tình huống; Bài 10 chính) _(mã nội bộ QA-23)_
- [Báo cáo lợi nhuận theo kỳ](https://www.youtube.com/watch?v=98gDiVV8jx0&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=8) (9:16) — báo cáo DCS theo kỳ (giải đáp tình huống; Bài 10 liên quan) _(mã nội bộ QA-8)_
- [Xây dựng cơ chế tích điểm thưởng](https://www.youtube.com/watch?v=0aAaQQP9fXI&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=14) (23:35) — tích và trừ điểm thưởng qua register (giải đáp tình huống; Bài 10 liên quan) _(mã nội bộ QA-14)_
- [Báo động tồn kho thấp với màu chữ hiển thị](https://www.youtube.com/watch?v=0JbOMl80lnY&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=18) (13:09) — tô màu cảnh báo tồn kho thấp (giải đáp tình huống; Bài 10 liên quan) _(mã nội bộ QA-18)_
- [Chặn kết chuyển khi phát hiện tồn kho âm](https://www.youtube.com/watch?v=k2uht5J1f3c&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=25) (10:03) — kiểm soát âm kho khi posting (giải đáp tình huống; Bài 10 liên quan) _(mã nội bộ QA-25)_
- [Hạch toán thu nhập theo doanh số](https://www.youtube.com/watch?v=QRAzQKBCtds&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=8) (20:00) — quy đổi tỷ giá khi posting bằng SliceLast (thực hành case study; Bài 10 liên quan) _(mã nội bộ P2-8)_
- [Hạch toán hàng hóa - Bài toán đơn giản nhất](https://www.youtube.com/watch?v=SwgfC-uA6Eg&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=10) (16:55) — nhập – xuất – tồn và chặn âm kho (thực hành case study; Bài 10 liên quan) _(mã nội bộ P2-10)_
- [Hạch toán hàng hóa - Hạch toán một kho](https://www.youtube.com/watch?v=BD370AtszHI&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=11) (20:57) — tồn kho theo từng kho (kho trên đầu chứng từ) (thực hành case study; Bài 10 liên quan) _(mã nội bộ P2-11)_
- [Hạch toán hàng hóa nhiều kho (Full)](https://www.youtube.com/watch?v=HIAYMOepPw4&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=12) (18:40) — kho trên từng dòng hàng và chặn âm theo từng kho (thực hành case study; Bài 10 liên quan) _(mã nội bộ P2-12)_
- [Hạch toán hàng hóa nhiều kho (Short)](https://www.youtube.com/watch?v=sHl70mbjk4c&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=13) (14:51) — sửa cấu trúc chứng từ đang có dữ liệu (thực hành case study; Bài 10 liên quan) _(mã nội bộ P2-13)_
- [Hạch toán hàng hóa - Theo hạn sử dụng](https://www.youtube.com/watch?v=TBgeOMXYp0w&list=PLp-gQ5Mgw0ZwiR39KPVCIVuUKhfEAD0KM&index=14) (13:24) — tồn kho theo hạn sử dụng và xuất dần theo lô (thực hành case study; Bài 10 liên quan) _(mã nội bộ P2-14)_

<!-- video-qa-thuchanh:end -->
