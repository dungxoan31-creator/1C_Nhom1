# Tài liệu gộp: lessons-21-24-extensions

Gồm các mục: § bai-21, § bai-22, § bai-23, § bai-24, § bai-extensions


---

# § bai-21

# Bài 21 — Standard Subsystems Library (SSL): giới thiệu, Core, Additional reports and data processors

## Khái niệm chính

### SSL
- **Standard Subsystems Library (SSL)**: tập các functional subsystem phổ quát dùng trong configuration 1C:Enterprise để triển khai chức năng chuẩn — một "constructor" giải pháp sẵn có giúp tăng tốc và thống nhất chức năng (authorization, reports, data exchange, files, integrations...).
- Subsystem dùng được cùng nhau hoặc riêng lẻ. Hai loại theo công nghệ triển khai:
  - Subsystem **"independent functionality"**: chỉ cần chuyển chức năng sang ("implemented and forgotten"), không cần thiết lập nhiều.
  - **Integrated subsystems** ("tight integration"): chức năng dùng trong các object cụ thể của consumer configuration; phải xác định object nào, rồi thiết lập thêm, sửa code và form của object đó.
- Theo thuật ngữ 1C, SSL cũng là một configuration, nhưng không tự động hóa nghiệp vụ cụ thể mà chứa các cơ chế để mượn vào giải pháp khác.
- Khuyến nghị chỉ đưa vào các subsystem cần thiết. "Subsystems" ở đây là tập metadata object thuộc subsystem (metadata type "Subsystem"): common modules, common commands, catalogs, constants, data processors, scheduled jobs...
- Bài học dùng configuration **"Standard Subsystems Library (demo)"**, phiên bản 3.1.

### Subsystem "Core"
- Gồm common modules "Common", "CommonClient", v.v. Cung cấp procedure/function phổ quát làm việc với configuration, metadata objects, value collections...
- Ví dụ: **CommonClientServer.ValueInArray(<Value>)** — tạo array mới, đặt giá trị truyền vào và trả về array.

### Additional reports and data processors
- Cho phép:
  - kết nối external reports và data processors vào ứng dụng, tùy chỉnh hiển thị trong interface và quyền user;
  - liên kết tới object cụ thể (ví dụ để điền object);
  - dùng làm print form mới hoặc thay print form có sẵn;
  - chạy data processor theo lịch (scheduled);
  - công cụ quản trị danh sách additional reports and data processors.
- Theo mục đích: **global** (dùng chung cho configuration) hoặc **assigned** (dùng với loại object cụ thể). Assignable data processors chia 4 loại: điền object; print forms; tạo object dựa trên object khác; reports.
- Phải **đăng ký** vào infobase: reports từ file **.erf**, các loại khác từ file **.epf**.

### Yêu cầu đăng ký
- Object module phải có export function **ExternalDataProcessorInfo()** (tên giống nhau cho report và data processor), trả về structure.
- Structure khởi tạo bằng cách gọi **AdditionalReportsAndDataProcessors.ExternalDataProcessorInfo()** (có thể truyền SSL version, không bắt buộc). Mô tả các property nằm trong khối mô tả phía trên function trong common module.
- Theo development standards, export procedure/function phải có mô tả (mục đích, parameters, return value với function). Tạo bằng: viết comment ở các dòng trước; hoặc chuột phải dòng khai báo → submenu Refactor → "Document procedure"/"Document function".
- Trong mô tả, property của Structure liệt kê sau ký hiệu "*"; property/cột lồng nhau có thêm indent và thêm "*" ("**", "***"...).

### Các property của RegistrationParameters
- **Kind** (String): PrintForm, ObjectFilling, RelatedObjectsCreation, Report, MessageTemplate, AdditionalDataProcessor, AdditionalReport. Nên điền bằng function "DataProcessorKind<KindName>" của common module **AdditionalReportsAndDataProcessorsClientServer** (ví dụ DataProcessorKindAdditionalDataProcessor()).
- **Purpose**: array tên đầy đủ metadata object mà data processor áp dụng (ví dụ "Document.PurchaseOrder", "Catalog.Products"). Không bắt buộc, nhưng với PrintForm, ObjectFilling nên điền (không dùng độc lập).
- **Version**: phiên bản (1.0; thay đổi nhỏ tăng minor 1.1, 1.2...; thay đổi lớn tăng major 2.0, 2.1...).
- **Information**: mô tả ngắn cho administrator.
- **SafeMode**: bật/tắt safe mode khi chạy; mặc định True — chỉ điền khi cần tắt.
- **Commands**: value table các command (không bắt buộc với reports). Một data processor có thể có nhiều command (ví dụ scheduled: một command điền settings, một command chạy task; PrintForm: nhiều print form command như "Commercial invoice" và "Commercial invoice with discounts").
  - **ID** — tên nội bộ command.
  - **Presentation** — tên hiển thị cho user.
  - **Use** — loại command: "ClientMethodCall", "ServerMethodCall", "FillingForm", "OpeningForm", "DataImportFromFile". Nên lấy bằng các function AdditionalReportsAndDataProcessorsClientServer.CommandType<TypeName>; mô tả các function này có template procedure xử lý command.
  - **ShowNotification** — True → khi chạy hiện thông báo "The command is running...". Áp dụng mọi loại trừ mở form (Use = "OpeningForm").
  - **Modifier** — phân loại bổ sung. Với external print forms: "PrintMXL" cho print form dựa trên table layout. Với load dữ liệu từ file: bắt buộc, chứa tên đầy đủ metadata object (catalog) được load dữ liệu.
  - **Hide** — tùy chọn; True → service command, ẩn trong card của additional object.
- **Quan trọng**: phải trả về (Return) RegistrationParameters, nếu không data processor không kết nối được.

### Đăng ký trong Enterprise mode
- Administration - Print forms, reports and data processors → đảm bảo flag "Additional reports and data processors" bật → hyperlink "Additional reports and data processors" → "Add from file…" → chấp nhận cảnh báo → chọn file.
- Tab **Commands**: danh sách command; field **"Sections"** (hyperlink "Undefined") chọn subsystem hiển thị data processor trong submenu Tools - Additional data processors.
- Tab **"Additional information"**: hiện "Information", version, type, file name, object name.
- User có quyền xem additional reports/data processors và subsystem Administration có thể chạy trực tiếp bằng nút "Run" trong item form, nhưng nên đặt vào subsystem phù hợp.
- Danh sách subsystem hiển thị chỉ gồm các subsystem liệt kê trong một số method của subsystem AdditionalReportsAndDataProcessors và data processor SSLAdministrationPanel. Thêm subsystem khác: liệt kê trong procedure **GetSectionsWithAdditionalDataProcessors()** của common module **AdditionalReportsAndDataProcessorsOverridable**.
- Common module có postfix **Overridable**: dành cho developer khác thay đổi hành vi mà không đụng object quan trọng của subsystem, giúp cập nhật library dễ hơn; các thuật toán chính nằm ở module không có postfix này.
- Cập nhật data processor đã sửa: nút **"Update from file…"** trong list form hoặc item form của catalog "additional reports and data processors".

### Mở khóa sửa object SSL (support)
- "Configuration - Support - Support options" → "Enable the ability to change" → đồng ý rằng cập nhật tự động hoàn toàn sẽ không còn → trong cửa sổ support rules bấm OK.
- Tìm object trong cửa sổ "Support options", double-click cột tên configuration → chọn rule **"Changes are allowed w/o breaking support"** → OK.
- Thêm subsystem riêng (hoặc bất kỳ metadata object không trực thuộc nào) → phải bật thay đổi cho configuration root tương tự.

### Thêm section "Sales" cho additional data processors
1. Bật thay đổi configuration root, tạo subsystem Sales.
2. Trong AdditionalReportsAndDataProcessorsOverridable.GetSectionsWithAdditionalDataProcessors(): copy một dòng, đổi sang subsystem mới.
3. Tạo common command tên theo template **"AdditionalDataProcessors<SubsystemName>"** (có thể copy từ command AdditionalDataProcessorsAdministration), đặt vào subsystem Sales, đưa vào functional option **"UseAdditionalReportsAndDataProcessors"** (cũng phải bật thay đổi trong support settings).
4. Trong command module đổi giá trị tham số cuối của procedure được gọi từ "Administration" sang "Sales".
- Nếu functional option tắt → command ẩn → subsystem Sales trống nên cũng không hiển thị (platform phân tích khi khởi động và khi gọi **RefreshInterface()**).
- Visibility mặc định cấu hình cho user ở cột **"Quick access"**; với DB không có user: trong list additional data processors của section → hyperlink **"Customize list"** → tick data processor → OK.

### Data processor loại "ObjectFilling"
- Dùng để thêm command điền một hoặc nhiều object. Các loại command:
  - Client method call
  - Server method call
  - Opening a data processor form
  - Filling a form (một object, không ghi vào DB; các loại khác ghi object đã điền vào DB)
- Chỉ có thể là assigned, không thể global. Trên form object được gán xuất hiện nút hoặc submenu **"Fill"** trên command bar.
- Chọn loại command theo thứ tự câu hỏi:
  1. Cần mở form riêng? → "OpenForm".
  2. Cần tương tác với user (hỏi, nhập giá trị) mà không cần form riêng? → "ClientMethodCall".
  3. Cần ghi object sau khi điền? Có → "server method call"; không → "FormFilling".
- Một data processor có thể chứa command nhiều loại.
- Ví dụ bài: data processor "Fill goods with balances" điền tabular section Goods của document "Goods transfer" (_DemoInventoryTransfer) theo số dư từ accumulation register "Demo: Available stock in storage locations".
- Nên điền Purpose ngay khi phát triển để user không gắn data processor vào object không phù hợp (có thể gây exception).

#### Command "ClientMethodCall"
- Data processor phải có **main form** (phải được gán là main form), trong module có **export client procedure ExecuteCommand(CommandID, RelatedObjectsArray)**. Không cần command, attribute, element khác trên form.
- Danh sách object có thể gắn assigned data processor do configuration object **"Object with additional commands"** loại **"TypeCollection"** quản lý. Phải bật thay đổi object này và thêm document vào danh sách types; sau đó "Sections" được điền tự động khi đăng ký.
- Tìm document trong interface: search by functions có ở mỗi section.
- Presentation quá dài → nút chỉ hiển thị hình, text hiện ở tooltip.
- Nhấn nút điền trên document mới chưa ghi → hộp hỏi phải ghi object trước.
- Khuyến nghị kiểm tra command ID trong ExecuteCommand dù chỉ có một command.
- Chỉ có thể lấy, sửa, ghi object theo reference ở server → truyền references sang server procedure. Từ list form một lần gọi có thể chứa nhiều reference → truyền tất cả cùng lúc để giảm server call.
- Khi ghi document: nếu đã posted → ghi ở chế độ Posting, nếu không → Write. Khuyến nghị ghi trong khối Try.
- Ghi document bằng code khi form/list đang mở: dữ liệu không được đọc lại → dùng **NotifyChanged(ObjectRef)** hoặc **NotifyChanged(Type)** để dynamic list (main table thuộc type đó) được cập nhật. Form document đang mở không được đọc lại khi gọi method này; cập nhật bằng nút Reread trong submenu "More actions".
- Từ list form có thêm bước chọn command điền.

#### Command "OpenForm"
- Data processor phải có main form; form này mở khi gọi command. Với data processor "Object filling", form phải có parameter **RelatedObjects** kiểu **Arbitrary** (array references tới object).
- Thêm 2 parameter được truyền khi mở: **CommandID** (String(0)) và **AdditionalDataProcessorRef** (CatalogRef.AdditionalReportsAndDataProcessors).
- Để parameter khả dụng trong OnOpen phải bật flag **"Key parameter"** — nếu không chúng bị xóa khỏi structure Parameters khi kết thúc sự kiện tạo form. "Key parameter" làm parameter khả dụng suốt thời gian dùng form.
- Ví dụ thêm decoration "Label" height 3 để form không quá thấp (message panel che element).
- Property **ShouldShowUserNotification** = True cho command ClientMethodCall: client nhận thông báo tùy chỉnh ở góc chương trình khi gọi command.
- Form mở full screen → đổi **WindowOpeningMode** thành "Lock owner's window".
- Đóng form khi user từ chối: đặt code đóng form trong kiểm tra form đang mở (đóng form chưa mở gây exception). Cũng phải đóng form trong handler command "FillGoods".
- Truyền parameter từ client sang server: không có từ khóa **"Val"** (truyền "by reference") → giá trị đi client→server và server→client. Một số object không trả về client được (ví dụ Array lưu trong form parameters) → exception khi trả quyền điều khiển về client. Giải pháp: thêm **Val** trước parameter của server procedure.
- Trong thực tế nên tách code trùng giữa OnOpen và ExecuteCommand thành procedure riêng.

#### Command "FormFilling"
- Điền form của object đang mở mà không ghi DB; user thấy kết quả, sửa được hoặc đóng không lưu. Có thể gọi export method của form module hoặc method nhận form làm tham số. Hạn chế: không dùng từ list form, chỉ gắn vào object form.
- Tạo **export procedure ExecuteCommand** trong **object module** với 3 parameter: **CommandID, RelatedObjects, ExecutionParameters**.
- ExecutionParameters có property **ThisForm** chứa form object đang điền; truy cập main attribute (mặc định tên **Object**) để điền như application object.
- Lỗi: đăng ký external data processor không chỉ SSL version → server procedure ExecuteCommand gọi không có parameter thứ ba ExecutionParameters → lỗi nếu parameter bắt buộc. Giải pháp: truyền SSL version trong ExternalDataProcessorInfo bằng cách gọi method từ common library module (không ghi tay) để vẫn đúng sau khi cập nhật library.
- Tip: command "form filling" không tự đặt form modification; nên đặt modification thủ công.

#### Command "Server method call"
- Tạo export procedure **ExecuteCommand(CommandID, RelatedObjects, ExecutionParameters)** trong data processor object module (giống FormFilling).
- Thông tin cần làm cho từng loại command có trong mô tả các service procedure/function, ví dụ mô tả của **AdditionalReportsAndDataProcessorsClientServer.CommandTypeServerMethodCall()**.

## Cú pháp & ví dụ code

Cách thông thường khởi tạo array:
```bsl
ObjectNames = New Array;

ObjectNames.Add("Catalog.Warehouses");

FillingParameters.ObjectNames = ObjectNames;
```

Dùng Core:
```bsl
FillingParameters.ObjectNames = CommonClientServer.ValueInArray("Catalog.Warehouses");
```

Khai báo function đăng ký:
```bsl
Function ExternalDataProcessorInfo() Export
```

Khởi tạo structure:
```bsl
RegistrationParameters = AdditionalReportsAndDataProcessors.ExternalDataProcessorInfo();
```

Kind:
```bsl
RegistrationParameters.Kind = AdditionalReportsAndDataProcessorsClientServer.DataProcessorKindAdditionalDataProcessor();
```

Purpose (khởi tạo array trong function riêng):
```bsl
RegistrationParameters.Purpose = DataProcessorPurpose();

Function DataProcessorPurpose()

    Result = New Array;

    Result.Add("Document.PurchaseOrder");

    Return Result;

EndFunction
```

Version, Information:
```bsl
RegistrationParameters.Version = "1.0";

RegistrationParameters.Information = "Data processor for product prices import from Excel file";
```

Command loại OpenForm:
```bsl
NewCommand = RegistrationParameters.Commands.Add();

NewCommand.Presentation = "Import product prices from Excel";

NewCommand.ID           = "ImportData";

NewCommand.Use          = AdditionalReportsAndDataProcessorsClientServer.CommandTypeOpenForm();
```

Purpose cho ObjectFilling:
```bsl
RegistrationParameters.Purpose.Add("Document._DemoInventoryTransfer");
```

Command loại ClientMethodCall:
```bsl
NewCommand = RegistrationParameters.Commands.Add();

NewCommand.Presentation = "Fill products with balances with warning";

NewCommand.ID           = "FillProductsWithBalancesClientCall";

NewCommand.Use          = AdditionalReportsAndDataProcessorsClientServer.CommandTypeClientMethodCall();
```

Cập nhật dynamic list sau khi ghi bằng code:
```bsl
NotifyChanged(ObjectRef)

NotifyChanged(Type)

NotifyChanged(Type("DocumentLink._DemoMovementOfProducts"))
```

Chữ ký procedure xử lý command:
```bsl
// Main form module — ClientMethodCall (export client procedure)
ExecuteCommand(CommandID, RelatedObjectsArray)

// Object module — FormFilling / ServerMethodCall (export procedure)
ExecuteCommand(CommandID, RelatedObjects, ExecutionParameters)
```

[ghi chú ngoài nguồn] Code đầy đủ của ExecuteCommand, OnOpen, handler "FillGoods", phần truyền SSL version trong tài liệu gốc là ảnh chụp màn hình, không có văn bản để chép nguyên văn. → Code demo lý thuyết đã được bổ sung từ file .epf gốc (thư mục `external/21` của repo), xem mục "Code demo lý thuyết từ file .epf gốc" ở cuối file.

## Thuộc tính/thiết lập quan trọng trong Designer
- Support: "Configuration - Support - Support options", "Enable the ability to change", rule **"Changes are allowed w/o breaking support"**.
- Common module **AdditionalReportsAndDataProcessorsOverridable** → procedure **GetSectionsWithAdditionalDataProcessors()**.
- Common command tên **AdditionalDataProcessors<SubsystemName>**; functional option **UseAdditionalReportsAndDataProcessors**.
- **"Object with additional commands"** (TypeCollection) — danh sách object gắn assigned data processor.
- Data processor: main form; form parameters **RelatedObjects** (Arbitrary), **CommandID** (String(0)), **AdditionalDataProcessorRef** (CatalogRef.AdditionalReportsAndDataProcessors), flag **"Key parameter"**.
- Form property **WindowOpeningMode** = "Lock owner's window".
- Decoration "Label" (height 3).
- Refactor → "Document procedure"/"Document function".

## Lỗi thường gặp / lưu ý
- Quên `Return RegistrationParameters` → không kết nối được data processor.
- Subsystem không xuất hiện trong danh sách "Sections" → phải thêm vào GetSectionsWithAdditionalDataProcessors().
- Document không có trong danh sách "Sections" của ObjectFilling → thêm vào TypeCollection "Object with additional commands".
- Sửa object SSL → phải bật khả năng thay đổi trong support settings; cập nhật tự động hoàn toàn sẽ không còn.
- Data processor không hiện trong list khi DB không có user → dùng "Customize list".
- Ghi object bằng code khi form mở → dữ liệu không được đọc lại; dùng NotifyChanged (form document vẫn cần Reread).
- Parameters form bị xóa sau khi tạo form nếu không bật "Key parameter".
- Đóng form chưa mở → exception.
- Truyền Array từ form parameters sang server không có Val → exception khi trả về client.
- Không truyền SSL version → ExecuteCommand ở server không nhận ExecutionParameters → lỗi.
- FormFilling không dùng được từ list form; không tự đặt modification.

## Điểm cần nhớ
- SSL là configuration chứa cơ chế phổ quát; chỉ đưa vào subsystem cần thiết; có hai loại: independent và integrated.
- Core: Common/CommonClient/CommonClientServer, ví dụ CommonClientServer.ValueInArray().
- Đăng ký additional report/data processor cần export function ExternalDataProcessorInfo() trả về RegistrationParameters.
- Property quan trọng: Kind, Purpose, Version, Information, SafeMode, Commands (ID, Presentation, Use, ShowNotification, Modifier, Hide).
- Module Overridable là nơi được phép tùy biến hành vi SSL.
- ObjectFilling chỉ assigned; 4 loại command: ClientMethodCall, ServerMethodCall, OpenForm, FormFilling — chọn theo 3 câu hỏi.
- ClientMethodCall → ExecuteCommand(CommandID, RelatedObjectsArray) trong main form; FormFilling/ServerMethodCall → ExecuteCommand(CommandID, RelatedObjects, ExecutionParameters) trong object module.
- Dùng Val khi truyền Array từ client sang server mà không cần trả về.

## Thẻ gợi ý bài thực hành (Practice 21)

Các thẻ dưới đây đi theo thứ tự đề trong 21. Practice (làm trên infobase SSL demo). Mỗi thẻ chỉ có gợi ý, không có lời giải. Các data processor là file .epf bên ngoài configuration: bạn tự viết, đăng ký, rồi kiểm tra trong Enterprise mode.

Lưu ý chung của đề: một data processor có thể chứa nhiều command, nhưng tốt nhất chỉ chứa các command cùng loại. Mọi command phải chạy không lỗi với các object được gán và không xuất hiện ở object khác. Vì vậy Purpose phải điền đúng.

### Bài tập 1 — Global data processor "Revaluation" trong subsystem mới "My projects"

- **Đề bài (tóm tắt):** Additional data processor global (Kind = AdditionalDataProcessor) trong section mới "My projects". User nhập ngày và phần trăm (âm hoặc dương), bấm "Revaluate": với mỗi product có giá trong "Demo: Product prices" **trước** ngày đó, ghi một record mới vào ngày đó với giá cũ nhân theo phần trăm. Ngày và phần trăm bắt buộc nhập.
- **Gợi ý 1 — Hướng đi:**
  - Phần đăng ký: xem "Yêu cầu đăng ký" và "Các property của RegistrationParameters".
  - Phần section: xem "Thêm section Sales cho additional data processors" và làm y hệt với subsystem MyProjects.
  - Phần logic: lấy **giá cuối cùng trước ngày** của mỗi product (virtual table SliceLast của periodic information register), rồi ghi record mới.
  - Command cần form riêng để nhập ngày và phần trăm, nên chọn loại "OpenForm".
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Configuration (bật support cho root và các object SSL cần sửa): subsystem `MyProjects`; một dòng mới trong `AdditionalReportsAndDataProcessorsOverridable.GetSectionsWithAdditionalDataProcessors()`; common command `AdditionalDataProcessorsMyProjects` (copy từ `AdditionalDataProcessorsAdministration`, đổi tham số section) đặt vào subsystem MyProjects và vào Content của functional option `UseAdditionalReportsAndDataProcessors`.
  - External data processor: object module có `ExternalDataProcessorInfo() Export`. Kind lấy từ `AdditionalReportsAndDataProcessorsClientServer.DataProcessorKindAdditionalDataProcessor()`, command Use = `CommandTypeOpenForm()`.
  - Main form: 2 attribute (Date, Percentage) có "Fill check", command "Revaluate".
  - Register: `InformationRegister._DemoProductsPrices` (dimension `Products`, resource `Price`, periodicity Second).
- **Gợi ý 3 — Khung bài làm:**
  1. Làm phần configuration (subsystem, Overridable, common command, FO), update DB.
  2. Tạo external data processor, viết function đăng ký, điền Kind, Version, Information, Commands.
  3. Tạo main form, attribute, command; handler client kiểm tra điền đủ rồi gọi server.
  4. Server: query SliceLast tại thời điểm **ngay trước** ngày nhập, duyệt kết quả, tính giá mới, ghi record cho ngày nhập.
  5. Đăng ký file, chọn section "My projects" ở field Sections, thêm vào "Customize list" nếu DB không có user.
  ```bsl
  &AtClient
  Procedure Revaluate(Command)
  	// kiểm tra Date và Percentage (CheckFilling hoặc kiểm tra tay) -> dừng nếu thiếu
  	___
  	RevaluateAtServer();
  EndProcedure

  &AtServer
  Procedure RevaluateAtServer()
  	// query giá cuối trước ngày; với mỗi dòng: tạo record manager, điền Period/Products/Price, ghi
  	___
  EndProcedure
  ```
- **Lỗi hay gặp:**
  - Truyền đúng ngày nhập vào SliceLast: record cùng ngày (nếu có) cũng bị lấy. Đề nói "before the specified date", nên lùi 1 giây hoặc dùng boundary loại trừ.
  - Product không có giá trước ngày (như "Ruler 15cm" trong ví dụ của đề) không được ghi record giá 0.
  - Quên `Return` structure đăng ký → không đăng ký được.
  - Section "My projects" không có trong danh sách Sections vì quên dòng trong module Overridable, hoặc common command không nằm trong FO/subsystem.
- **Tự kiểm tra:** Dùng đúng bảng ví dụ của đề (ngày 23.10.2024, -10%): register phải có thêm đúng 3 record (135; 28.8; 45). Bấm Revaluate với Date trống phải báo lỗi và không ghi gì.

### Bài tập 2 — Đổi giá theo số cho _DemoCustomerProformaInvoice (ObjectFilling)

- **Đề bài (tóm tắt):** Data processor điền object cho `_DemoCustomerProformaInvoice`: đổi Price ở mỗi dòng tabular section Goods theo số user nhập, tính lại Sum và Total của dòng. Chạy được cho nhiều document cùng lúc.
- **Gợi ý 1 — Hướng đi:** Xem "Data processor loại ObjectFilling" và 3 câu hỏi chọn loại command. Cần user nhập một số, và document phải được ghi (vì chạy cho nhiều document, kể cả từ list). Vì vậy dùng "OpenForm" (form có field nhập số) hoặc "ClientMethodCall" (hỏi số bằng dialog nhập), rồi gọi server để sửa và ghi từng document.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Kind = `DataProcessorKindObjectFilling()`, Purpose có `"Document._DemoCustomerProformaInvoice"`.
  - Với OpenForm: form parameters `RelatedObjects` (Arbitrary), `CommandID`, `AdditionalDataProcessorRef`, bật "Key parameter".
  - Tabular section `Goods` có các cột `Count`, `Price`, `Sum`, `Total`.
  - Server: lấy object theo ref (`GetObject()`), sửa, ghi theo chế độ Posting nếu document đã posted, nếu không thì Write, đặt trong Try.
  - Sau khi ghi: `NotifyChanged(...)` để list được cập nhật.
- **Gợi ý 3 — Khung bài làm:**
  1. Đăng ký: Kind, Purpose, một command (OpenForm hoặc ClientMethodCall).
  2. Client: lấy số từ user. User hủy hoặc số = 0 thì dừng.
  3. Server (nhận `Val` array refs): duyệt document, duyệt dòng Goods, đổi Price, tính lại Sum/Total, ghi.
  4. Client: gọi NotifyChanged, đóng form nếu đang mở.
  ```bsl
  &AtServerNoContext
  Procedure ChangePricesAtServer(Val Refs, Val Delta)
  	For Each DocRef In Refs Do
  		// lấy object, duyệt Goods: đổi Price, tính lại Sum và Total
  		___
  		// ghi: Posting nếu đã posted, ngược lại Write (trong Try)
  		___
  	EndDo;
  EndProcedure
  ```
- **Lỗi hay gặp:**
  - Đổi Price mà quên tính lại Sum/Total (đề bắt buộc).
  - Không có `Val` khi truyền array lấy từ form parameters → exception khi trả quyền về client.
  - Quên đưa document vào TypeCollection "Object with additional commands" → nút Fill không hiện. Trong SSL demo document này đã có sẵn, hãy kiểm tra trước.
  - Form document đang mở không tự đọc lại sau khi ghi bằng code. Dùng Reread.
- **Tự kiểm tra:** Chọn 2–3 document trong list, chạy command, nhập 10: mở từng document, Price tăng 10, Sum = Count × Price mới. Document đã posted vẫn posted.

### Bài tập 3 — Điền giá hiện hành từ register cho _DemoGoodsSales và _DemoCustomerProformaInvoice, có cảnh báo

- **Đề bài (tóm tắt):** Data processor điền object cho 2 document: điền Price ở Goods bằng giá trong "Demo: Product prices" có hiệu lực tại ngày document. Trước khi điền phải cảnh báo mất dữ liệu, user được từ chối. Chạy được cho nhiều document.
- **Gợi ý 1 — Hướng đi:** Cần hỏi user (không cần form riêng) và phải ghi object → loại "ClientMethodCall": hỏi bằng `ShowQueryBox` (không chặn, có callback). Chỉ khi user trả lời Yes mới gọi server. Ở server, giá lấy bằng SliceLast tại **ngày của từng document**, không phải ngày hiện tại.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Purpose có 2 phần tử: `"Document._DemoGoodsSales"`, `"Document._DemoCustomerProformaInvoice"`.
  - Defined type `ObjectWithAdditionalCommands`: kiểm tra `_DemoGoodsSales` đã có chưa. Nếu chưa, bật support và thêm vào.
  - Main form module: `ExecuteCommand(CommandID, RelatedObjectsArray) Export` (client), `New CallbackDescription(...)`, `ShowQueryBox`, `DialogReturnCode.Yes`.
  - Hai document có Goods khác cột (`_DemoGoodsSales` không có Sum/Total). Nếu tính lại tổng thì phải xử lý theo loại document.
- **Gợi ý 3 — Khung bài làm:**
  1. Đăng ký command ClientMethodCall với Purpose 2 document.
  2. `ExecuteCommand`: kiểm tra CommandID, lưu array refs, hiện câu hỏi.
  3. Callback: nếu không phải Yes thì Return. Nếu Yes thì gọi server với array refs.
  4. Server: với mỗi document, lấy giá theo `Date` của nó, điền Price, tính lại cột phụ thuộc nếu có, ghi.
  ```bsl
  &AtClient
  Procedure ExecuteCommand(CommandID, RelatedObjectsArray) Export
  	// kiểm tra CommandID; tạo CallbackDescription, truyền RelatedObjectsArray qua AdditionalParameters
  	___
  EndProcedure

  &AtClient
  Procedure ___Finish(Result, AdditionalParameters) Export
  	// chỉ tiếp tục khi user chọn Yes -> gọi server, rồi NotifyChanged
  	___
  EndProcedure
  ```
- **Lỗi hay gặp:**
  - Dùng `CurrentSessionDate()` thay vì ngày document.
  - Product không có giá: quyết định rõ (giữ giá cũ hay đặt 0) và nhất quán. Đề không nói, nên giữ giá cũ an toàn hơn.
  - Data processor không có main form, hoặc `ExecuteCommand` không Export → command không chạy.
  - Purpose chỉ có một document → command không hiện ở document kia.
- **Tự kiểm tra:** Trên `_DemoGoodsSales` và proforma invoice: bấm Fill, chọn No thì không đổi gì; chọn Yes thì Price khớp giá trong register tại ngày document. Thử document có ngày trước lần đổi giá gần nhất để thấy lấy đúng giá cũ.

### Bài tập 4 — Giống bài 3 nhưng FormFilling: không ghi DB, chỉ một object, không hỏi

- **Đề bài (tóm tắt):** Command điền giá như bài 3 nhưng không ghi vào DB: form object chỉ trở thành modified. Chỉ chạy cho một object và không hỏi user.
- **Gợi ý 1 — Hướng đi:** Không ghi DB và chỉ từ form object → loại "FormFilling" (xem mục "Command FormFilling"). Code ở **object module** của data processor (server), nhận form qua `ExecutionParameters.ThisForm`, sửa main attribute `Object` của form.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Command Use = `CommandTypeFormFilling()`, Purpose như bài 3.
  - Object module: `ExecuteCommand(CommandID, RelatedObjects, ExecutionParameters) Export`.
  - `ExternalDataProcessorInfo`: truyền SSL version bằng hàm trả version của library (ví dụ `StandardSubsystemsServer.LibraryVersion()`), không ghi tay chuỗi version.
  - Form modification: đặt thủ công (property `Modified` của form), vì FormFilling không tự đặt.
- **Gợi ý 3 — Khung bài làm:**
  1. Thêm command FormFilling (có thể chung data processor với bài 3 nếu muốn, nhưng đề khuyên command cùng loại thì chung).
  2. Trong ExecuteCommand: kiểm tra CommandID, lấy form, lấy ngày document từ `Object` của form.
  3. Duyệt dòng Goods của `Object` của form, điền Price.
  4. Đánh dấu form modified.
  ```bsl
  Procedure ExecuteCommand(CommandID, RelatedObjects, ExecutionParameters) Export
  	// kiểm tra CommandID
  	___
  	Form = ExecutionParameters.___;
  	// duyệt Form.Object.Goods, điền Price theo giá tại ngày Form.Object.Date
  	___
  	// đặt cờ modified cho form
  	___
  EndProcedure
  ```
- **Lỗi hay gặp:**
  - Không truyền SSL version khi đăng ký → ExecuteCommand ở server không nhận parameter thứ ba → lỗi "too few parameters".
  - Gọi `Write()` trên object: sai yêu cầu (không được ghi DB).
  - Quên đặt modified → user đóng form mà không được hỏi lưu.
  - FormFilling không dùng được từ list form, đây là đúng yêu cầu "một object".
- **Tự kiểm tra:** Mở document, chạy command: Price đổi ngay, tiêu đề form có dấu "*". Đóng form → platform hỏi lưu. Chọn No rồi mở lại thì giá cũ vẫn còn. Command không xuất hiện ở list form.

## Code demo của bài Theory (repo 1CJDCourse, nhánh lesson/21-23-theory)

Nhánh lesson/21-23-theory là cấu hình demo SSL (Standard Subsystems Library) dùng chung cho bài 21-23. So với cấu hình của bài trước, phần lớn object là module của SSL; phần do khóa học tự thêm/sửa cho bài 21 chỉ gồm: common command `AdditionalDataProcessorsSales`, một dòng trong `AdditionalReportsAndDataProcessorsOverridable`, functional option `UseAdditionalReportsAndDataProcessors` và subsystem `Training`. Nhánh không chứa file external data processor (.epf) nào, cũng không có function `ExternalDataProcessorInfo` hay `ExecuteCommand` do khóa học viết — các data processor đăng ký trong bài được tạo bên ngoài configuration nên không nằm trong dump.

### Thêm section cho additional data processors (Overridable module)
Nguồn: nhánh lesson/21-23-theory — cf/CommonModules/AdditionalReportsAndDataProcessorsOverridable/Ext/Module.bsl
```bsl
Procedure GetSectionsWithAdditionalDataProcessors(Sections) Export
	
	// _Demo Example Start
	Sections.Add(AdditionalReportsAndDataProcessorsClientServer.StartPageName());
	Sections.Add(Metadata.Subsystems._DemoIntegratedSubsystemsPart);
	Sections.Add(Metadata.Subsystems.Sales);
	// _Demo Example End
	
EndProcedure
```
- Code của khóa học: chỉ dòng `Sections.Add(Metadata.Subsystems.Sales);` — copy dòng có sẵn rồi đổi sang subsystem của mình (bước 2 của mục "Thêm section Sales").
- Module của SSL: `AdditionalReportsAndDataProcessorsOverridable` là module "overridable" mà SSL gọi tới khi dựng danh sách section; `AdditionalReportsAndDataProcessorsClientServer.StartPageName()` là API của SSL cho trang chủ.
- Lưu ý khi đọc dump: subsystem trong nhánh tên `Training` (synonym "Training"), không có subsystem tên `Sales`; dòng trên chỉ chạy được khi tên subsystem trùng khớp.

### Common command AdditionalDataProcessorsSales
Nguồn: nhánh lesson/21-23-theory — cf/CommonCommands/AdditionalDataProcessorsSales/Ext/CommandModule.bsl
```bsl
#Region EventHandlers

&AtClient
Procedure CommandProcessing(CommandParameter, CommandExecuteParameters)
	
	AdditionalReportsAndDataProcessorsClient.OpenAdditionalReportAndDataProcessorCommandsForm(
		CommandParameter,
		CommandExecuteParameters,
		AdditionalReportsAndDataProcessorsClientServer.DataProcessorKindAdditionalDataProcessor(),
		"Sales");
	
EndProcedure

#EndRegion
```
- Code của khóa học: command được copy từ `AdditionalDataProcessorsAdministration` (giữ nguyên header copyright của SSL), chỉ đổi tham số cuối từ `"Administration"` sang `"Sales"`.
- Module của SSL được gọi tới: `AdditionalReportsAndDataProcessorsClient.OpenAdditionalReportAndDataProcessorCommandsForm` mở danh sách additional data processors của section; `DataProcessorKindAdditionalDataProcessor()` chọn loại.
- Tên command theo template `AdditionalDataProcessors<SubsystemName>`.

### Đưa command vào functional option và subsystem
Nguồn: nhánh lesson/21-23-theory — cf/FunctionalOptions/UseAdditionalReportsAndDataProcessors.xml
```xml
			<Location>Constant.UseAdditionalReportsAndDataProcessors</Location>
// ...
				<xr:Object>CommonCommand.AdditionalDataProcessorsAdministration</xr:Object>
				<xr:Object>CommonCommand.AdditionalReportsAdministration</xr:Object>
				<xr:Object>CommonCommand.AdditionalDataProcessorsSales</xr:Object>
			</Content>
```
Nguồn: nhánh lesson/21-23-theory — cf/Subsystems/Training.xml
```xml
			<Content>
				<xr:Item xsi:type="xr:MDObjectRef">CommonCommand.AdditionalDataProcessorsSales</xr:Item>
				<xr:Item xsi:type="xr:MDObjectRef">Document.InventoryRecount</xr:Item>
			</Content>
```
- Command mới được thêm vào Content của functional option `UseAdditionalReportsAndDataProcessors` (object của SSL, phải bật thay đổi trong support settings): constant tắt thì command ẩn, section trống cũng ẩn theo.
- Subsystem của khóa học chứa command này (và document `InventoryRecount` của bài 23) để command hiện trên command panel của section.

### Code demo lý thuyết từ file .epf gốc (thư mục external/21)

Nguồn: các file .epf giảng viên dùng khi quay phần lý thuyết bài 21, lưu trong thư mục `external/21` của repo 1CJDCourse (mỗi thư mục có file .epf gốc, `ObjectModule.bsl` và `Forms/Form/Module.bsl`). Code dưới đây chép nguyên văn. Thư mục này còn có lời giải bài thực hành (`Practice_*`); bản sinh viên của skill **không** dùng các lời giải đó — với bài thực hành chỉ dùng thẻ gợi ý ở trên.

| Data processor | Kind | Purpose | Commands (ID → Use) |
|---|---|---|---|
| Theory_ImportPricesFromExcel | AdditionalDataProcessor (global) | — | `ImportData` → OpenForm |
| Theory_FillProductsWithBalances (bản đầu) | ObjectFilling | `Document._DemoInventoryTransfer` | `FillProductsWithBalancesClientCall` → ClientMethodCall · `FillProductsWithBalancesClientOpenForm` → OpenForm · `FillProductsWithBalancesServer` → FormFilling |
| Theory_FillGoodsWithBalances_New (bản sửa) | ObjectFilling | `Document._DemoInventoryTransfer` | `FillProductsWithBalancesClientCall` → ClientMethodCall · `FillProductsWithBalancesClientOpenForm` → OpenForm · `FillProductsWithBalancesServerFormFilling` → FormFilling |

Form attribute/parameter chính (đọc từ mô tả form trong .epf): Fill goods with balances — attribute `ProductGroup`, parameters `RelatedObjects`, `CommandID`, `AdditionalDataProcessorRef`, command `FillGoods`/`FillProducts`; ImportPricesFromExcel — `Period`, `PriceType`, `SpreadsheetDocument`, `PathToFile`, commands `ReadFile`, `LoadPrices`.

#### Demo "Fill goods with balances" — bản sửa (Theory_FillGoodsWithBalances_New)

Đây là bản nên dùng khi giảng: SSL version lấy bằng hàm thư viện và command ID khớp giữa object module và form.

Object module — đăng ký 3 command và xử lý FormFilling:

Nguồn: repo 1CJDCourse — external/21/Theory_FillGoodsWithBalances_New/ObjectModule.bsl

```bsl
Function ExternalDataProcessorInfo() Export 
	
	RegistrationParameters = AdditionalReportsAndDataProcessors.ExternalDataProcessorInfo(
		StandardSubsystemsServer.LibraryVersion()
	);
	
	RegistrationParameters.Kind = AdditionalReportsAndDataProcessorsClientServer.DataProcessorKindObjectFilling();
	RegistrationParameters.Version 		= "1.0";
	RegistrationParameters.Information 	= "Data processor for filling products tabular section of the _DemoInventoryTransfer document";
	RegistrationParameters.Purpose.Add("Document._DemoInventoryTransfer");

	NewCommand = RegistrationParameters.Commands.Add();
	NewCommand.Presentation = "Fill products with balances with warning";
	NewCommand.ID	      	= "FillProductsWithBalancesClientCall";
	NewCommand.Use 			= AdditionalReportsAndDataProcessorsClientServer.CommandTypeClientMethodCall();
	NewCommand.ShouldShowUserNotification = True;
	
	NewCommand = RegistrationParameters.Commands.Add();
	NewCommand.Presentation = "Fill products with balances with warning using filter";
	NewCommand.ID	      	= "FillProductsWithBalancesClientOpenForm";
	NewCommand.Use 			= AdditionalReportsAndDataProcessorsClientServer.CommandTypeOpenForm();

	NewCommand = RegistrationParameters.Commands.Add();
	NewCommand.Presentation = "Fill products with balances without saving";
	NewCommand.ID	      	= "FillProductsWithBalancesServerFormFilling";
	NewCommand.Use 			= AdditionalReportsAndDataProcessorsClientServer.CommandTypeFormFilling();
	
	Return RegistrationParameters;
	
EndFunction

Procedure ExecuteCommand(CommandID, RelatedObjects, ExecutionParameters) Export

	If CommandID <> "FillProductsWithBalancesServerFormFilling" Then
		Return;
	EndIf;
	
	Object = ExecutionParameters.ThisForm.Object;
	
	// Work with object (the attribute of the form)
	Object.Comment = StrTemplate(
		"Written from the filling data processor in %1",
		Format(CurrentSessionDate(), "DF=HH:mm:ss")
	);
	
EndProcedure
```

- `ExternalDataProcessorInfo(StandardSubsystemsServer.LibraryVersion())`: truyền SSL version bằng hàm thư viện (không ghi tay) → server `ExecuteCommand` nhận đủ tham số `ExecutionParameters`.
- `ShouldShowUserNotification = True` gắn cho command ClientMethodCall.
- FormFilling: `ExecutionParameters.ThisForm.Object` là main attribute của form document đang mở; demo chỉ ghi `Comment`, không ghi DB. Code này **không** đặt `ThisForm.Modified = True` (xem tip "FormFilling không tự đặt modification" ở trên).

Form module — ClientMethodCall, OpenForm, ghi document ở server:

Nguồn: repo 1CJDCourse — external/21/Theory_FillGoodsWithBalances_New/Forms/Form/Module.bsl

```bsl
&AtClient
Procedure ExecuteCommand(CommandID, RelatedObjectsArray) Export
	
	If CommandID = "FillProductsWithBalancesClientCall" Then
		AdditionalParameters = New Structure("RelatedObjects", RelatedObjectsArray);
		
		ShowQueryBox(
			New CallbackDescription("FillProductsAnswer", ThisObject, AdditionalParameters),
			"Tabular section will be cleared and then filled with the goods balances. Continue?",
			QuestionDialogMode.YesNo
		);
	EndIf;
	
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
		
	If Parameters.CommandID = "FillProductsWithBalancesClientOpenForm" Then
		AdditionalParameters = New Structure("RelatedObjects", Parameters.RelatedObjects);
		
		ShowQueryBox(
			New CallbackDescription("FillProductsAnswer", ThisObject, AdditionalParameters),
			"Tabular section will be cleared and then filled with the goods balances. Continue?",
			QuestionDialogMode.YesNo
		);
	EndIf;
	
EndProcedure

&AtClient
Procedure FillGoods(Command)
		
	If Not CheckFilling() Then
		Return;
	EndIf;
	
	// Call for the server procedure of filling products
	// ...
	FillProductsWithBalancesAtServer(Parameters.RelatedObjects);

	If IsOpen() Then
		Close();
	EndIf;
	
EndProcedure

&AtClient
Procedure FillProductsAnswer(Result, AdditionalParameters) Export

	If Result <> DialogReturnCode.Yes Then
		If IsOpen() Then
			Close();
		EndIf;
		Return;
	EndIf;

	FillProductsWithBalancesAtServer(AdditionalParameters.RelatedObjects);
	
	NotifyChanged(Type("DocumentRef._DemoInventoryTransfer"));
	
EndProcedure

&AtServer
Procedure FillProductsWithBalancesAtServer(Val RelatedObjects)
	
	For Each RelatedObject In RelatedObjects Do
	
		DocumentObject = RelatedObject.GetObject();
		
		// For each document get goods balances on its date
		// and fill Products tabular section with these balances
		// ...
		
		DocumentObject.Comment = StrTemplate(
			"Written from the filling data processor in %1",
			Format(CurrentSessionDate(), "DF=HH:mm:ss")
		);
		
		If DocumentObject.Posted Then
			WriteMode = DocumentWriteMode.Posting;
		Else
			WriteMode = DocumentWriteMode.Write;
		EndIf;

		DocumentObject.Write(WriteMode);		
	
	EndDo;
	
EndProcedure
```

- ClientMethodCall: SSL gọi export procedure `ExecuteCommand(CommandID, RelatedObjectsArray)` của main form (form không mở ra); câu hỏi non-modal `ShowQueryBox` + `CallbackDescription`, mảng reference truyền qua `AdditionalParameters`.
- OpenForm: form mở với `Parameters.CommandID` và `Parameters.RelatedObjects` (cần flag "Key parameter" để còn đọc được trong `OnOpen`).
- Server: `RelatedObject.GetObject()` → sửa → ghi `Posting` nếu document đã post, ngược lại `Write`. Parameter có `Val` vì mảng nằm trong form parameters không trả về client được.
- `NotifyChanged(Type("DocumentRef._DemoInventoryTransfer"))` để dynamic list cập nhật.
- [ghi chú ngoài nguồn] Phần lấy số dư chỉ là chỗ trống `// ...`; tài liệu lý thuyết nói rõ chức năng không quan trọng, demo minh hoạ cơ chế command. Muốn điền thật thì query virtual table Balance của register số dư theo ngày document (Bài 11).
- [ghi chú ngoài nguồn] Nhánh OpenForm: `OnOpen` hỏi và khi chọn Yes thì điền **ngay**, không đợi người dùng chọn `ProductGroup` rồi bấm `FillGoods` — bộ lọc trên form chưa được dùng, và form vẫn mở sau khi điền. Bản đầu tránh điều này bằng `If ThisObject.IsOpen() Then Return` trong handler câu trả lời. Nếu giảng phần "mở form để lọc", nên chỉ ra điểm này.
- [ghi chú ngoài nguồn] Ghi document không đặt trong `Try` (khác khuyến nghị ở phần lý thuyết).

#### Demo "Fill goods with balances" — bản đầu (Theory_FillProductsWithBalances)

Nguồn: repo 1CJDCourse — external/21/Theory_FillProductsWithBalances/ObjectModule.bsl

```bsl
Function ExternalDataProcessorInfo() Export 
	
	RegistrationParameters = AdditionalReportsAndDataProcessors.ExternalDataProcessorInfo("3.1.10.386");
	
	RegistrationParameters.Kind 		= AdditionalReportsAndDataProcessorsClientServer.DataProcessorKindObjectFilling();
	RegistrationParameters.Version 		= "1.0";
	RegistrationParameters.Information 	= "Data processor for filling products tabular section of the _DemoInventoryTransfer document";
	RegistrationParameters.Purpose 		= CommonClientServer.ValueInArray("Document._DemoInventoryTransfer");
	
	NewCommand = RegistrationParameters.Commands.Add();
	NewCommand.Presentation = "Fill products with balances with warning";
	NewCommand.ID	      	= "FillProductsWithBalancesClientCall";
	NewCommand.Use 			= AdditionalReportsAndDataProcessorsClientServer.CommandTypeClientMethodCall();
	
	NewCommand = RegistrationParameters.Commands.Add();
	NewCommand.Presentation = "Fill products with balances with warning using filter";
	NewCommand.ID	      	= "FillProductsWithBalancesClientOpenForm";
	NewCommand.Use 			= AdditionalReportsAndDataProcessorsClientServer.CommandTypeOpenForm();
	NewCommand.ShouldShowUserNotification = True;

	NewCommand = RegistrationParameters.Commands.Add();
	NewCommand.Presentation = "Fill products with balances without saving";
	NewCommand.ID	      	= "FillProductsWithBalancesServer";
	NewCommand.Use 			= AdditionalReportsAndDataProcessorsClientServer.CommandTypeFormFilling();
	
	Return RegistrationParameters;
	
EndFunction

Procedure ExecuteCommand(CommandID, RelatedObjects, ExecutionParameters) Export

	If CommandID <> "FillProductsWithBalancesServer" Then
		Return;
	EndIf;
	
	Object = ExecutionParameters.ThisForm.Object;
	
	// Work with object (the attribute of the form)
	Object.Goods.Add();
	
EndProcedure
```

Nguồn: repo 1CJDCourse — external/21/Theory_FillProductsWithBalances/Forms/Form/Module.bsl

```bsl
&AtClient
Procedure ExecuteCommand(CommandID, RelatedObjectsArray) Export
	
	If CommandID = "FillProductsWithBalances" Then
	
		FillProductsAfterAsking(RelatedObjectsArray);
	
	EndIf;
	
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	
	If Parameters.CommandID = "FillProductsWithBalancesWithFilter" Then
		FormWasOpen = True;
		FillProductsAfterAsking(Parameters.RelatedObjects);
	Else
		Cancel = True;
	EndIf;
	
EndProcedure

&AtClient
Procedure FillProducts(Command)
	
	If Not CheckFilling() Then
		Return;
	EndIf;
	
	FillAtServer(Parameters.RelatedObjects, True);
	
	// For an additional data processor command with the "Opening form" type
	// we should notify about changes so that dynamic lists update data
	For Each ChangedObject In Parameters.RelatedObjects Do
		NotifyChanged(Parameters.RelatedObjects[0]);
	EndDo;
	
	If ThisObject.IsOpen() Then
		Close();
	EndIf;
	
EndProcedure

&AtClient
Procedure FillProductsAfterAsking(RelatedObjects)

	AdditionalParameters = New Structure("RelatedObjects", RelatedObjects);
	
	ShowQueryBox(
		New CallbackDescription("FillProductsAnswer", ThisObject, AdditionalParameters),
		"Tabular section will be cleared and then filled with the goods balances. Continue?",
		QuestionDialogMode.YesNo
	);

EndProcedure

&AtClient
Procedure FillProductsAnswer(Result, AdditionalParameters) Export

	If Result <> DialogReturnCode.Yes Then
		If ThisObject.IsOpen() Then
			Close();
		EndIf;
		Return;
	EndIf;

	If ThisObject.IsOpen() Then
		Return;
	EndIf;
	
	FillAtServer(AdditionalParameters.RelatedObjects, False);
	
EndProcedure

&AtServer
Procedure FillAtServer(Val RelatedObjects, FilterProducts) // Показать фокус с Знач (Val)
	
	For Each RelatedObject In RelatedObjects Do
	
		DocumentObject = RelatedObject.GetObject();
		
		// For each document get goods balances on its date
		// and fill Products tabular section with these balances
		// ...
		
		If DocumentObject.Posted Then
			WriteMode = DocumentWriteMode.Posting;
		Else
			WriteMode = DocumentWriteMode.Write;
		EndIf;

		DocumentObject.Write(WriteMode);		
	
	EndDo;
	
EndProcedure
```

- SSL version ghi tay `"3.1.10.386"` — đúng cái lý thuyết khuyên tránh (cập nhật library sẽ lệch).
- `Purpose = CommonClientServer.ValueInArray(...)` — ví dụ dùng subsystem Core.
- `FormWasOpen`, `Cancel = True` trong `OnOpen` khi không phải command OpenForm, và `If ThisObject.IsOpen() Then Return` trong handler câu trả lời: khi form mở, việc điền dời sang nút `FillProducts` (sau khi người dùng chọn bộ lọc).
- [ghi chú ngoài nguồn] **Command ID lệch**: object module đăng ký `FillProductsWithBalancesClientCall` / `FillProductsWithBalancesClientOpenForm`, nhưng form kiểm tra `"FillProductsWithBalances"` / `"FillProductsWithBalancesWithFilter"` → command ClientMethodCall không làm gì, command OpenForm luôn bị `Cancel`. Bản `_New` đã sửa — có thể dùng làm bài "tìm lỗi" cho sinh viên.
- [ghi chú ngoài nguồn] Vòng `For Each ChangedObject In Parameters.RelatedObjects Do NotifyChanged(Parameters.RelatedObjects[0])` dùng phần tử đầu thay vì `ChangedObject`.
- [ghi chú ngoài nguồn] Comment tiếng Nga `// Показать фокус с Знач (Val)` = "minh hoạ mẹo với Val" — ghi chú quay bài, không phải logic.

#### Demo ImportPricesFromExcel (Kind AdditionalDataProcessor, command OpenForm)

Nguồn: repo 1CJDCourse — external/21/Theory_ImportPricesFromExcel/ObjectModule.bsl

```bsl
Function ExternalDataProcessorInfo() Export 
	
	RegistrationParameters = AdditionalReportsAndDataProcessors.ExternalDataProcessorInfo();
	
	RegistrationParameters.Kind 		= AdditionalReportsAndDataProcessorsClientServer.DataProcessorKindAdditionalDataProcessor();
	RegistrationParameters.Version 		= "1.0";
	RegistrationParameters.Information 	= "Data processor for product prices import from Excel file";

	NewCommand = RegistrationParameters.Commands.Add();
	NewCommand.Presentation = "Import product prices from Excel";
	NewCommand.ID	      	= "ImportData";
	NewCommand.Use 			= AdditionalReportsAndDataProcessorsClientServer.CommandTypeOpenForm();
	
	Return RegistrationParameters;
	
EndFunction
```

Nguồn: repo 1CJDCourse — external/21/Theory_ImportPricesFromExcel/Forms/Form/Module.bsl

```bsl
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	Period = CurrentSessionDate();
EndProcedure

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

&AtClient
Procedure FileFinishChoice(SelectedFiles, AdditionalParameters) Export

	If SelectedFiles <> Undefined Then
		PathToFile = SelectedFiles[0];
				
		BeginPutFileToServer(
			New CallbackDescription("ReadFinishPuttingFile", ThisObject),,,,
			PathToFile,
			UUID
		);	
	EndIf;	

EndProcedure

&AtClient
Procedure ReadFinishPuttingFile(PlacedFileDescription, AdditionalParameters) Export

	If PlacedFileDescription = Undefined Then
		Return;
	EndIf;
	
	ReadOnServer(PlacedFileDescription.Address, PlacedFileDescription.FileRef.Extension);	

EndProcedure

&AtServer
Procedure ReadOnServer(AddressAtTempStorage, FileExtension)
	
	BinaryData = GetFromTempStorage(AddressAtTempStorage);
	
	// Temp file
	TempFileName = GetTempFileName(FileExtension);
	BinaryData.Write(TempFileName);
	
	SpreadsheetDocument.Read(TempFileName, SpreadsheetDocumentValuesReadingMode.Value);
	
	Try
		DeleteFiles(TempFileName);
	Except
		WriteLogEvent(
			"Files.Deletion",
			EventLogLevel.Error,
			Metadata.DataProcessors.ImportPricesFromExcel,,
			DetailErrorDescription(ErrorInfo())
		);
	EndTry;
	
EndProcedure

&AtClient
Procedure LoadPrices(Command)
	LoadPricesAtServer();
EndProcedure

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
	
	// Rx - row #x, Cx - column #x
	For i = 1 To ColumnsCount Do
		ColumnNameArea = SpreadsheetDocument.Area("R1C" + i);
		ColumnName = TrimAll(ColumnNameArea.Text);
		// Searching name of excel file column at structure with column numbers
		If ColumnNumbers.Property(ColumnName) Then
			ColumnNumbers[ColumnName] = i;
		Else
			Message(StrTemplate("Column %1 with number %2 will be skipped", ColumnName, i));
		EndIf;
	EndDo;
	
	ColumnsError = False;
	For Each KeyAndValue In ColumnNumbers Do
		If Not ValueIsFilled(KeyAndValue.Value) Then
			Message(StrTemplate("Can't find column %1 in Excel file", KeyAndValue.Key));
			ColumnsError = True;
		EndIf;
	EndDo;
	
	If ColumnsError Then
		Return;
	EndIf;
	
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

- Luồng file client → server (Bài 19): `FileDialog.Show` → `BeginPutFileToServer` (đặt vào temp storage, gắn với `UUID` của form) → server `GetFromTempStorage` → ghi temp file → `SpreadsheetDocument.Read(..., SpreadsheetDocumentValuesReadingMode.Value)` → xoá temp file trong `Try`, lỗi ghi Event log.
- Dòng 1 là tiêu đề cột; tìm số cột theo tên bằng Structure `ColumnNumbers` (Product, Price), thiếu cột thì báo và dừng.
- Ghi giá bằng `InformationRegisters.ProductPrices.CreateRecordManager()` + `Write(True)` (Bài 12).
- [ghi chú ngoài nguồn] `ExternalDataProcessorInfo()` gọi **không** truyền SSL version — chấp nhận được vì command OpenForm không cần `ExecutionParameters`. `WriteLogEvent` tham chiếu `Metadata.DataProcessors.ImportPricesFromExcel`, trong khi đây là data processor ngoài (không có trong metadata của configuration) → nhánh xoá file lỗi có thể phát sinh exception; nên kiểm chứng khi chạy. Information register `ProductPrices` và catalog `Products` không phải tên object của cấu hình SSL demo (`_DemoProductsPrices`, `_DemoProducts`) — demo này chạy trên cấu hình có các object đó.

## Video tham khảo

Video bài giảng trên YouTube có phạm vi trùng với bài này. Khi dẫn cho người học, nói "Bạn có thể tham khảo thêm về <chủ đề> của khóa tại đây: [<tên video>](link)" — không nói "khóa cũ/Junior", không dùng mã JC (mã JC trong danh sách chỉ để tra nội bộ). Quy ước đầy đủ: `references/video.md#video-junior-course`.

- [Trò chuyện với người dùng](https://www.youtube.com/watch?v=s0MHq7d_nVc&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=38) (9:26) — Bài 9 — ShowQueryBox + CallbackDescription (code mẫu); Bài 7 — dialog không chặn (CallbackDescription); Bài 21 — ShowUserNotification _(mã nội bộ JC-39)_

<!-- video-qa-thuchanh:start -->

Video giải đáp tình huống thực chiến và video thực hành từng bước liên quan tới bài này (thẻ chi tiết, triệu chứng, lưu ý khi giới thiệu: `references/video.md#video-qa-thuc-chien`, `references/video.md#video-thuc-hanh`; cùng mẫu câu dẫn ở trên):

- [Lưu bộ xử lý ngoài](https://www.youtube.com/watch?v=DTRivJSbAoI&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=15) (1:40) — bộ xử lý ngoài (.epf) (giải đáp tình huống; Bài 21 liên quan) _(mã nội bộ QA-15)_

<!-- video-qa-thuchanh:end -->


---

# § bai-22

# Bài 22 — SSL: Print subsystem

## Khái niệm chính

### Print subsystem
- Tạo print form của object dựa trên table templates (định dạng **MXL**) và template văn bản Office Open XML (**docx**).
- Cung cấp: visual editor cho table templates và DOCX templates (user sửa template có sẵn, print form được dựng theo thay đổi); công cụ đặt print commands vào submenu **"Print"**; preview print forms; lưu ra file, gửi e-mail, tạo ảnh QR code; program interface tạo print form từ template trong configuration.
- Ở Enterprise mode: gộp print forms thành bộ (set), lưu một hoặc nhiều file, gửi mail; tự động tính hàm trên các ô số được chọn (ví dụ tổng).
- Khi có nhiều print form (hơn chục), nên hiển thị trong submenu Print; hiển thị có thể phụ thuộc functional option hoặc giá trị attribute của document.
- Với Print subsystem, nhiệm vụ của developer: kết nối object vào subsystem (một lần), thêm print commands **bằng code** (không tạo metadata object loại Command) và thêm handler cho các command.

### Task trong bài
- Document "Demo: Goods receipt" (_DemoGoodsReceipt) trong SSL demo chưa có print command. Kết nối vào Print subsystem, tạo 2 command: "Goods receipt" và "Receipt at warehouse" (chỉ hiện với một số warehouse).

### Các bước kết nối
1. Chỉ định metadata object trong procedure **PrintManagementOverridable.OnDefinePrintSettings()**: bật khả năng thay đổi cho common module **PrintManagementOverridable**, thêm metadata object vào array **PrintObjects** của property **Settings**.
2. Thêm export procedure **AddPrintCommands(PrintCommands)** vào **manager module** của object, thêm dòng vào value table PrintCommands. Khuyến nghị đặt code trong service comments (xem phần code). Phải bật khả năng thay đổi manager module trong support settings.
3. Nếu thiếu, khi mở list form sẽ lỗi thiếu method **OnDefiningPrintSettings(Settings)** — method này cũng đặt trong manager module, điền property của structure Settings. Mô tả parameter Settings ở function **PrintManagement.ObjectPrintingSettings**. Để thêm print commands phải gán **OnAddPrintCommands = True**.
- Khuyến nghị theo tài liệu SSL; nếu không có tài liệu, tham khảo object đã có print form (ví dụ manager module document "Demo: Sales proforma invoice").
- Một command → nút trên command bar; từ hai command trở lên → submenu "Print".

### Các cột của bảng print commands
- **Order** (Number): ưu tiên thứ tự từ 1 đến 100, mặc định 50. Sắp xếp theo Order + presentation (thứ tự thêm dòng không ảnh hưởng). Command có order 10 lên trên command không chỉ định order.
- **FunctionalOptions** (String): danh sách functional option, phân cách bằng dấu phẩy, ảnh hưởng hiển thị command.
- **VisibilityConditions** (Array): thêm điều kiện bằng method **PrintManagement.AddCommandVisibilityCondition**. Điều kiện gồm 3 phần: tên attribute của object, giá trị so sánh, điều kiện so sánh.
- **Handler**, **PrintManager**, **Id**, **FixedSet** — xem dưới.
- Note của tác giả: tìm warehouse theo description không phải giải pháp tốt (có thể đổi tên, DB khác có thể không có) — chỉ để minh họa.

### AttachableCommands
- Để nút print hoạt động đúng, object phải kết nối với subsystem SSL khác: **AttachableCommands** (đọc tài liệu SSL, khuyến nghị khác nhau theo version).
- Trong form module của object có print command phải thêm lời gọi procedure kết nối form vào subsystem trong các event handler của form, và các attachable procedure xử lý command, đặt trong comment `// StandardSubsystems.AttachableCommands` … `// End StandardSubsystems.AttachableCommands` (tham khảo form "Demo: Sales proforma invoice").
- Gọi print command từ list form → cũng phải kết nối list form module vào AttachableCommands.
- Bài dùng Print wizard tạo template; wizard tạo command và procedure trong manager module — xóa command (không cần), giữ procedure cho "Receipt at warehouse".

### Các cách xử lý print command
1. **Không chỉ định handler và print manager**: manager module của object phải có export procedure **Print(ObjectArray, PrintParameters, PrintFormCollection, PrintObjects, OutputParameters)**.
2. **Property Handler**: client command handler thay cho handler Print chuẩn (ví dụ khi print form tạo trên client).
   - Format `<CommonModuleName>.<FunctionName>` khi đặt trong common module.
   - Format `<FunctionName>` khi đặt trong module main form của report/data processor chỉ định ở PrintManager.
   - Handler được gọi bằng **Eval()** nên chỉ **function** mới làm handler được; giá trị trả về không được dùng. Function có một parameter bắt buộc **PrintParameters** (Structure):
     - PrintObjects — Array — mảng link tới object được chọn.
     - Form — ClientApplicationForm — form gọi print command.
     - AdditionalParameters — Structure — tham số in bổ sung.
3. **Property PrintManager**: tên object có manager module chứa procedure Print tạo spreadsheet document.
   - Có thể chỉ định common module **"PrintManagement"** làm print manager → tự điền template không cần viết method; xử lý trong procedure Print của common module này. Hai điều kiện:
     1. Property ID của print command phải là đường dẫn đầy đủ tới template.
     2. Trong template mọi parameter cần điền phải đặt trong **ngoặc vuông** (vì vậy không thể nằm trong ô có filling property "Parameter").
4. **Phương pháp kết hợp**: property ID chứa nhiều print form (cùng hoặc khác nhau) cho bộ in, phân cách bằng dấu phẩy; có thể chỉ định print manager thay thế thay cho print manager chính trong PrintManager. Print form không có print manager riêng được tạo trong object ở PrintManager, nếu PrintManager trống thì trong manager module của chính object.
- **Important**: nếu PrintManager là common module PrintManagement thì không dùng được print manager khác; ID chỉ chứa đường dẫn đầy đủ tới template, không chứa tên print manager thay thế.

### Procedure Print trong manager module
- Nên đổi procedure điền spreadsheet document do print wizard tạo thành **function**, tối thiểu nhận 2 parameter:
  - **ObjectsArray** — array references tới object cần in.
  - **PrintObjects** — value list, mỗi giá trị là tên area của spreadsheet document nơi object được in.
- Function: tạo spreadsheet document, cuối cùng trả về nó; chọn dữ liệu cho array references; với mỗi document chỉ định area nó chiếm trong PrintObjects.

### Template cho print manager PrintManagement
- Ô chỉ có date và number trong title được điền vì các parameter khác chưa trong ngoặc vuông.
- Chọn mọi ô parameter, đổi property **"FillType"** từ "Parameter" sang **"Template"** (cũng có thể "Text" vì print manager tìm parameter theo text từng ô, nhưng nên dùng Template phòng khi sau này tự điền), rồi đặt parameter trong ngoặc vuông.
- Parameter của tabular section: `[TabularSectionName.ParameterName]`, ví dụ `[Goods.Price]`.

### Document set (bộ chứng từ)
- Phương pháp kết hợp dùng để in bộ chứng từ (ví dụ "Certificate of work completion" + "Invoice"). Không kết hợp được PrintManagement với print manager khác.
- Ví dụ: 3 template mới, 2 data processor (data processor 1 điền form 1, data processor 2 điền form 2 và 3). Command có 4 print form: một tạo trong manager module object, một trong data processor 1, hai trong data processor 2.
  - Cách 1: PrintManager = data processor PringGoodsReceipt2 (quản nhiều form nhất), khi đó form "WarehouseReceipt" phải ghi đường dẫn đầy đủ tới document manager.
  - Cách 2: chỉ để ID form đó, chỉ định print manager cho mọi form khác, PrintManager để trống.
- Muốn nhiều bản của một print form trong bộ → ghi nó trong ID bấy nhiêu lần.
- Property **FixedSet**: mặc định False — user thay đổi số bản từng form, thêm/bớt form khỏi bộ. True → user không đổi được thành phần bộ in.

### Tạo và sửa template
- Từ print form: sửa template và lưu vào infobase ("Edit template"), hoặc đi tới danh sách mọi template ("Go to print form templates").
- Danh sách template: icon bút chì xanh trên nền tờ giấy = template đã sửa đang dùng; nút "Use edited template" / "Use standard template". Template đã sửa nhưng dùng template chuẩn → icon đen trắng. Template đã sửa có thể xóa từ context menu hoặc submenu "More" → không còn icon.
- Để template được đánh dấu chính trong infobase được dùng khi dựng print form, phải lấy template trong code bằng **PrintManagement.PrintFormTemplate**, không dùng method có sẵn của platform **GetTemplate**.
- Danh sách template cũng mở từ "Administration - Print forms, reports and data processors" → hyperlink "Print form templates".
- User có thể tự tạo template/print command mới, tạo bởi print manager PrintManagement (không cần developer). Sau khi tạo phải bật flag hiển thị trong submenu Print; điều kiện hiển thị đặt qua biểu tượng bánh răng.
- Form print forms, reports and data processors có settings submenu Print: tắt bớt command; với external print forms có cột "External print form" với hyperlink tới additional data processor cung cấp command.

### Roles
- **EditPrintFormTemplates** — thêm và sửa print form templates.
- **OutputToPrinterFileClipboard** (thuộc subsystem "Core") — cho phép xuất print form ra máy in và gửi e-mail.
- **PrintFormsEdit** — sửa print form đã tạo trước khi gửi ra máy in hoặc e-mail, lưu ra file.

## Cú pháp & ví dụ code

Service comments cho Print subsystem:
```bsl
// StandardSubsystems.Print

…

// End StandardSubsystems.Print
```

Service comments cho AttachableCommands:
```bsl
// StandardSubsystems.AttachableCommands

…

// End StandardSubsystems.AttachableCommands
```

Chữ ký procedure trong manager module:
```bsl
AddPrintCommands(PrintCommands)

OnDefiningPrintSettings(Settings)

Print(ObjectArray, PrintParameters, PrintFormCollection, PrintObjects, OutputParameters)
```

Functional option cho command:
```bsl
PrintCommand.FunctionalOptions = "UseMultipleWarehouses"
```

PrintManager là data processor:
```bsl
PrintCommand.PrintManager = "DataProcessor.PrintPaymentInvoice";
```

ID là đường dẫn đầy đủ tới template (dùng với PrintManagement):
```bsl
PrintCommand.Id = "Document._DemoGoodsReceipt.PF_MXL_GoodsReceipt";
```

Phương pháp kết hợp:
```bsl
PrintCommand.Id = "SalesInvoice,DataProcessor.PrintPaymentInvoice.PaymentInvoice"
```

Sai (PrintManagement kết hợp print manager khác):
```bsl
PrintCommand.Id = "Document._DemoGoodsReceipt.PF_MXL_GoodsReceipt,DataProcessor.PrintInvoicesFromSupplier.InvoiceFromSupplier";

PrintCommand.PrintManager = "PrintManagement";
```

Đúng:
```bsl
PrintCommand.Id = "Document._DemoGoodsReceipt.PF_MXL_GoodsReceipt,Document._GoodsReceipt.PF_MXL_InvoiceFromSupplier";

PrintCommand.PrintManager = "PrintManagement";
```

Parameter của tabular section trong template:
```bsl
[TabularSectionName.ParameterName]
[Goods.Price]
```

[ghi chú ngoài nguồn] Code đầy đủ của OnDefinePrintSettings, AddPrintCommands, AddCommandVisibilityCondition, procedure Print và function điền spreadsheet trong tài liệu gốc là ảnh chụp màn hình, không có văn bản để chép nguyên văn. → đã bổ sung (nhánh lesson/21-23-theory).

## Thuộc tính/thiết lập quan trọng trong Designer
- Common module **PrintManagementOverridable** → **OnDefinePrintSettings()** → `Settings.PrintObjects`.
- Structure Settings: **OnAddPrintCommands** = True.
- Cột bảng print commands: **Order**, **FunctionalOptions**, **VisibilityConditions**, **Handler**, **PrintManager**, **Id**, **FixedSet**.
- Ô template: property **FillType** ("Parameter" / "Template" / "Text").
- Roles: **EditPrintFormTemplates**, **OutputToPrinterFileClipboard**, **PrintFormsEdit**.

## Lỗi thường gặp / lưu ý
- Thiếu method OnDefiningPrintSettings(Settings) trong manager module → lỗi khi mở list form.
- Không đặt OnAddPrintCommands = True → command không hiện.
- Nút print không chạy đúng nếu object chưa kết nối AttachableCommands (cả object form lẫn list form).
- Handler chỉ có thể là function (gọi qua Eval()).
- PrintManagement: parameter không trong ngoặc vuông → không được điền; ô phải đổi FillType từ "Parameter".
- PrintManagement không kết hợp được với print manager khác trong ID.
- Template đã sửa không được dùng nếu code lấy template bằng GetTemplate thay vì PrintManagement.PrintFormTemplate.
- Tìm dữ liệu (warehouse) theo description để làm visibility condition không phải giải pháp tốt.

## Điểm cần nhớ
- Print subsystem: template MXL và DOCX, submenu Print, preview, lưu file, e-mail, QR code, user tự sửa template.
- Kết nối: PrintManagementOverridable.OnDefinePrintSettings() + AddPrintCommands(PrintCommands) + OnDefiningPrintSettings(Settings) với OnAddPrintCommands = True.
- Print commands thêm bằng code, không tạo metadata Command.
- Order (1–100, mặc định 50), FunctionalOptions, VisibilityConditions điều khiển vị trí và hiển thị.
- 4 cách xử lý: procedure Print trong manager module; Handler (function, Eval()); PrintManager; kết hợp qua Id phân cách dấu phẩy.
- PrintManagement làm print manager: Id = đường dẫn đầy đủ template, parameter trong [ngoặc vuông], không kết hợp print manager khác.
- Dùng PrintManagement.PrintFormTemplate thay GetTemplate để hỗ trợ template do user sửa.
- FixedSet = True khóa thành phần bộ in.

## Thẻ gợi ý bài thực hành (Practice 22)

Các thẻ dưới đây đi theo thứ tự đề trong 22. Practice (document "Demo: Sales order", `_DemoSalesOrder`, trong SSL demo). Mỗi thẻ chỉ có gợi ý, không có lời giải. Yêu cầu chung cho mọi print form: user phải sửa được template, nên template đặt tên với prefix `PF_MXL_` và trong code lấy template bằng `PrintManagement.PrintFormTemplate` (không dùng `GetTemplate`).

### Chuẩn bị — Kết nối _DemoSalesOrder vào Print subsystem (bước chung cho bài 1–3)

- **Đề bài (tóm tắt):** Bước chuẩn bị cho mọi print form của bài: object phải được Print subsystem nhận ra.
- **Gợi ý 1 — Hướng đi:** Xem "Các bước kết nối" và "AttachableCommands". Print command được thêm bằng code, không tạo metadata Command.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - `PrintManagementOverridable.OnDefinePrintSettings(Settings)`: thêm document vào `Settings.PrintObjects` (bật support cho common module).
  - Manager module của `_DemoSalesOrder` (bật support): `OnDefinePrintSettings(Settings) Export` với `OnAddPrintCommands = True`; `AddPrintCommands(PrintCommands) Export`; `Print(...) Export`. Đặt tất cả trong service comments `// StandardSubsystems.Print`.
  - Form document và list form: kiểm tra đã có khối `// StandardSubsystems.AttachableCommands` chưa (SSL demo thường có sẵn).
- **Gợi ý 3 — Khung bài làm:**
  1. Bật khả năng sửa cho `PrintManagementOverridable` và manager module của document.
  2. Thêm một dòng `PrintObjects` cho document.
  3. Tạo 2 procedure export trong manager module như khung dưới, phần command sẽ điền ở các bài sau.
  ```bsl
  // StandardSubsystems.Print
  Procedure OnDefinePrintSettings(Settings) Export
  	// bật cờ để SSL gọi AddPrintCommands
  	___
  EndProcedure

  Procedure AddPrintCommands(PrintCommands) Export
  	// mỗi print form: PrintCommands.Add(), điền Id, Presentation, (PrintManager), (Order)
  	___
  EndProcedure
  // End StandardSubsystems.Print
  ```
- **Lỗi hay gặp:**
  - Thiếu `OnDefinePrintSettings` trong manager module → lỗi khi mở list form.
  - Quên cờ `OnAddPrintCommands` → không có command nào.
- **Tự kiểm tra:** Mở list "Demo: Sales order" không lỗi. Sau khi thêm command ở bài 1, nút/submenu Print xuất hiện.

### Bài tập 1 — Print form "Sales order" (trong data processor PrintSalesOrder) và "Delivery order" (trong document)

- **Đề bài (tóm tắt):** Hai print form với handler tự viết (không dùng PrintManagement làm print manager): "Delivery order" xử lý trong chính document, "Sales order" xử lý trong data processor tự tạo `PrintSalesOrder`. "Sales order" phải đứng đầu submenu Print.
- **Gợi ý 1 — Hướng đi:** Xem "Các cách xử lý print command" (cách 1 và cách 3) và "Procedure Print trong manager module".
  - Command không có PrintManager → SSL gọi `Print` trong manager module của document.
  - Command có `PrintManager = "DataProcessor.PrintSalesOrder"` → SSL gọi `Print` trong manager module của data processor.
  - Thứ tự hiển thị do cột **Order** quyết định, không phải thứ tự thêm dòng.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Templates trong document: `PF_MXL_SalesOrder`, `PF_MXL_DeliveryOrder` (tạo bằng Print wizard hoặc vẽ tay, đặt area như Caption/Header...). Data processor chỉ chứa code, template vẫn có thể nằm ở document.
  - Data processor `PrintSalesOrder`: manager module có `Print(ObjectsArray, PrintParameters, PrintFormsCollection, PrintObjects, OutputParameters) Export` và function điền spreadsheet.
  - SSL API: `PrintManagement.PrintFormInfo(PrintFormsCollection, "<Id>")`, `PrintManagement.PrintFormTemplate("Document._DemoSalesOrder.PF_MXL_...")`, `PrintManagement.SetDocumentPrintArea(...)`; set `TemplateSynonym`, `FullTemplatePath` để user mở "Edit template".
  - Order: giá trị nhỏ (ví dụ 1) cho "Sales order".
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo 2 template có prefix `PF_MXL_`, đặt parameter cho các field cần in (số, ngày, counterparty, địa chỉ giao hàng...).
  2. Trong `AddPrintCommands`: 2 dòng command, dòng "Sales order" có PrintManager và Order.
  3. Trong document: `Print` + function điền "Delivery order". Trong data processor: `Print` + function điền "Sales order".
  4. Function điền: query theo `Ref IN (&...)`, duyệt selection, Put từng area, ngắt trang giữa các document, gọi `SetDocumentPrintArea`.
  ```bsl
  Procedure Print(ObjectsArray, PrintParameters, PrintFormsCollection, PrintObjects, OutputParameters) Export
  	PrintForm = PrintManagement.PrintFormInfo(PrintFormsCollection, "___");
  	If PrintForm <> Undefined Then
  		// gán SpreadsheetDocument = function điền của bạn; TemplateSynonym; FullTemplatePath
  		___
  	EndIf;
  EndProcedure
  ```
- **Lỗi hay gặp:**
  - Id trong `AddPrintCommands` khác Id dùng trong `PrintFormInfo` → print form trống.
  - Lấy template bằng `GetTemplate` → template user sửa không được dùng.
  - Không gọi `SetDocumentPrintArea` → in nhiều document thì chức năng gửi mail/lưu theo từng document không đúng.
  - Quên `PutHorizontalPageBreak()` giữa các document.
- **Tự kiểm tra:** Chọn 2 sales order trong list → Print → "Sales order": 2 trang, mỗi trang một document. "Sales order" đứng trên "Delivery order" trong submenu. "Edit template" mở đúng template `PF_MXL_...`.

### Bài tập 2 — "Sales order details" bằng PrintManagement, chỉ hiện với document từ 01.01.2025

- **Đề bài (tóm tắt):** Print form in mọi attribute và tabular section (trừ ContactInformation), điền hoàn toàn bởi common module PrintManagement, không viết code điền. Chỉ hiện cho document có ngày ≥ 01.01.2025. Tạo document trước và sau mốc này để kiểm tra.
- **Gợi ý 1 — Hướng đi:** Xem "Template cho print manager PrintManagement" và cột VisibilityConditions. PrintManagement tự điền khi Id là **đường dẫn đầy đủ tới template** và mọi parameter trong template viết trong **ngoặc vuông**. Điều kiện hiện thêm bằng `PrintManagement.AddCommandVisibilityCondition` (tên attribute, giá trị, `ComparisonType`).
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Template `PF_MXL_SalesOrderDetails` trong document. Ô parameter: FillType = "Template", text dạng `[AttributeName]`. Cột tabular section dạng `[TabularSectionName.AttributeName]`.
  - Command: `Id = "Document._DemoSalesOrder.PF_MXL_SalesOrderDetails"`, `PrintManager = "PrintManagement"`.
  - Điều kiện: attribute `"Date"`, giá trị `Date(2025, 1, 1)`, phép so sánh "lớn hơn hoặc bằng".
- **Gợi ý 3 — Khung bài làm:**
  1. Xem danh sách attribute và tabular section của document trong Designer (bỏ ContactInformation).
  2. Vẽ template: header là các attribute, mỗi tabular section một area hàng tiêu đề và một area dòng.
  3. Đổi FillType của mọi ô parameter sang Template và bọc tên trong `[...]`.
  4. Thêm command và gắn điều kiện hiện vào **chính command này** (biến command vừa Add).
- **Lỗi hay gặp:**
  - Ô vẫn để FillType = "Parameter" → PrintManagement không điền.
  - Gắn visibility condition nhầm command. [ghi chú ngoài nguồn] Trong bản lời giải mẫu của khóa, điều kiện ngày lại gắn vào command "Delivery order" thay vì "Sales order details". Đề yêu cầu điều kiện cho "Sales order details", đừng lặp lại lỗi này.
  - Trộn PrintManagement với print manager khác trong cùng Id → không chạy (xem mục "Important").
- **Tự kiểm tra:** Document ngày 2024: submenu Print không có "Sales order details". Document ngày 2025: có, và in ra đủ attribute cùng các dòng tabular section.

### Bài tập 3 — "Document set": 2 bản "Sales order" + 1 bản "Delivery order"

- **Đề bài (tóm tắt):** Print form bộ gồm 2 bản "Sales order" và 1 bản "Delivery order".
- **Gợi ý 1 — Hướng đi:** Xem "Document set" và "Phương pháp kết hợp". Id chứa nhiều print form phân cách bằng dấu phẩy. Muốn in 2 bản thì ghi Id đó 2 lần. Form có print manager khác ghi dạng `<PrintManager>.<Id>`.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Một dòng command mới trong `AddPrintCommands`. Id ghép từ: Id "Sales order" kèm tên data processor (2 lần) và Id "Delivery order" (form của chính document, không cần tiền tố nếu PrintManager để trống).
  - Có thể dựng Id bằng array + `StrConcat(..., ",")` cho dễ đọc.
  - Tùy chọn: `FixedSet` (khóa thành phần bộ), `Order` lớn để đứng cuối.
- **Gợi ý 3 — Khung bài làm:**
  1. Xác định 2 phần tử Id: một cho form trong data processor, một cho form trong document.
  2. Ghép thành chuỗi theo thứ tự: Sales order, Sales order, Delivery order.
  3. Thêm command "Document set", để PrintManager trống.
- **Lỗi hay gặp:**
  - Đặt `PrintManager = "PrintManagement"` cho bộ này → không kết hợp được với handler tự viết.
  - Thiếu tiền tố `DataProcessor.PrintSalesOrder.` cho form "Sales order" → SSL tìm form trong document và không thấy.
- **Tự kiểm tra:** In "Document set": preview có 2 trang Sales order và 1 trang Delivery order. Nếu không bật FixedSet, thử đổi số bản trong form preview.

### Bài tập 4 (bổ sung) — External print form "Sales order (external)"

- **Đề bài (tóm tắt):** External print form lặp lại print form "Sales order" (dùng lại template và handler), chỉ khác tiêu đề có thêm "(External)". Đăng ký vào hệ thống, gắn với "Demo: Sales order", kiểm tra.
- **Gợi ý 1 — Hướng đi:** Kết hợp bài 21 (đăng ký additional data processor) với bài này: Kind = PrintForm, Purpose = document. Gợi ý của đề: khi dùng server command, external print form phải có export procedure `Print()` trong **object module**, cùng bộ parameter như `ExecuteCommand` của data processor loại "FillingObject".
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Object module của .epf: `ExternalDataProcessorInfo() Export` với Kind = `DataProcessorKindPrintForm()`, Purpose có `"Document._DemoSalesOrder"`, command Use = `CommandTypeServerMethodCall()`, Modifier = `"PrintMXL"`.
  - Procedure `Print` export trong object module. Bộ parameter lấy đúng theo gợi ý của đề, đối chiếu với mô tả của `AdditionalReportsAndDataProcessorsClientServer.CommandTypeServerMethodCall()` và tài liệu SSL của version bạn dùng. Dùng lại logic điền và template "Sales order" (copy template vào data processor ngoài).
  - Tiêu đề: thêm "(External)" vào area/parameter tiêu đề.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo external data processor, copy template Sales order vào và sửa tiêu đề.
  2. Viết function đăng ký (Kind, Purpose, Version, command với Modifier PrintMXL).
  3. Viết `Print` export trong object module, gọi function điền tương tự bài 1.
  4. Đăng ký trong Administration → Print forms, reports and data processors, kiểm tra Sections/Purpose.
- **Lỗi hay gặp:**
  - Đặt `Print` ở manager module: đề yêu cầu object module.
  - Quên Modifier `"PrintMXL"` cho print form dựa trên table template.
  - Vẫn lấy template theo đường dẫn của document: khi đó bạn không dùng template trong file ngoài, và tiêu đề "(External)" không xuất hiện.
- **Tự kiểm tra:** Sau khi đăng ký, submenu Print của sales order có "Sales order (external)", tiêu đề in ra có "(External)". Danh sách print form trong Administration hiện hyperlink "External print form".

## Code demo của bài Theory (repo 1CJDCourse, nhánh lesson/21-23-theory)

Trong nhánh lesson/21-23-theory, phần code của khóa học cho bài 22 nằm ở: manager module của document `_DemoGoodsReceipt` (thêm khối `// StandardSubsystems.Print`), một dòng trong `PrintManagementOverridable`, và hai data processor mới `PrintGoodsReceipt1`, `PrintGoodsReceipt2` cho document set. Các lời gọi `PrintManagement.*` là module của SSL (Standard Subsystems Library).

### Kết nối object vào Print subsystem (PrintManagementOverridable.OnDefinePrintSettings)
Nguồn: nhánh lesson/21-23-theory — cf/CommonModules/PrintManagementOverridable/Ext/Module.bsl
```bsl
Procedure OnDefinePrintSettings(Settings) Export
// ...
	// _Demo Example End
	
	Settings.PrintObjects.Add(Documents._DemoGoodsReceipt);

EndProcedure
```
- Code của khóa học: chỉ dòng `Settings.PrintObjects.Add(Documents._DemoGoodsReceipt);`, đặt sau khối `// _Demo Example` có sẵn.
- Module của SSL: `PrintManagementOverridable` là module overridable phải bật khả năng thay đổi trong support settings trước khi sửa.

### OnDefinePrintSettings và AddPrintCommands trong manager module
Nguồn: nhánh lesson/21-23-theory — cf/Documents/_DemoGoodsReceipt/Ext/ManagerModule.bsl
```bsl
// StandardSubsystems.Print

// Overrides object's print settings.
//
// Parameters:
//  Settings - See PrintManagement.ObjectPrintingSettings.
//
Procedure OnDefinePrintSettings(Settings) Export
	
	Settings.OnAddPrintCommands = True;
	
EndProcedure
// ...
Procedure AddPrintCommands(PrintCommands) Export
	
	PrintCommand = PrintCommands.Add();
	PrintCommand.Id = "Document._DemoGoodsReceipt.PF_MXL_GoodsReceipt";
	PrintCommand.Presentation = NStr("en = 'Goods receipt';");
	PrintCommand.CheckPostingBeforePrint = True;
	PrintCommand.PrintManager = "PrintManagement";

	PrintCommand = PrintCommands.Add();
	PrintCommand.Id = "WarehouseReceipt";
	PrintCommand.Presentation = NStr("en = 'Receipt at warehouse';");
	PrintCommand.CheckPostingBeforePrint = True;
	PrintCommand.Order = 10;

	Warehouse = Catalogs._DemoStorageLocations.FindByDescription("Storage #1", True);
	If ValueIsFilled(Warehouse) Then
		PrintManagement.AddCommandVisibilityCondition(
			PrintCommand,
			"StorageLocation",
			Warehouse,
			ComparisonType.Equal
		);
	EndIf;
	
	// Document set.
	CommandsID = New Array;
	CommandsID.Add("WarehouseReceipt");
	CommandsID.Add("WarehouseReceipt");
	CommandsID.Add("DataProcessor.PrintGoodsReceipt1.GoodsReceipt1");
	CommandsID.Add("DataProcessor.PrintGoodsReceipt2.GoodsReceipt2");
	CommandsID.Add("DataProcessor.PrintGoodsReceipt2.GoodsReceipt3");
	
	PrintCommand = PrintCommands.Add();
	PrintCommand.Id = StrConcat(CommandsID, ",");
	PrintCommand.Presentation = NStr("en = 'Document set';");
	PrintCommand.CheckPostingBeforePrint = True;
	PrintCommand.FixedSet = True;
	PrintCommand.Order = 75;
// ...
EndProcedure
```
- Code của khóa học: toàn bộ hai procedure, đặt trong service comments `// StandardSubsystems.Print`; `Settings.OnAddPrintCommands = True` là điều kiện để SSL gọi `AddPrintCommands`.
- Command 1 dùng print manager `"PrintManagement"` nên `Id` là đường dẫn đầy đủ tới template; command "WarehouseReceipt" không có PrintManager → SSL gọi procedure `Print` của chính manager module này.
- `PrintManagement.AddCommandVisibilityCondition(PrintCommand, "StorageLocation", Warehouse, ComparisonType.Equal)` là API của SSL; tìm warehouse theo description chỉ để minh họa (như note của tác giả).
- "Document set": `Id` ghép nhiều print form bằng `StrConcat(CommandsID, ",")`, "WarehouseReceipt" lặp hai lần → in hai bản; `FixedSet = True`. (Trong file còn command "Document set 2" dùng PrintManagement, Id chỉ chứa đường dẫn template, không trộn print manager khác — đã lược.)

### Procedure Print và function điền spreadsheet
Nguồn: nhánh lesson/21-23-theory — cf/Documents/_DemoGoodsReceipt/Ext/ManagerModule.bsl
```bsl
Procedure Print(ObjectsArray, PrintParameters, PrintFormsCollection, PrintObjects, OutputParameters) Export
	
	// Print a warehouse receipt
	PrintForm = PrintManagement.PrintFormInfo(PrintFormsCollection, "WarehouseReceipt");
	If PrintForm <> Undefined Then
		PrintForm.SpreadsheetDocument = PrintWarehouseReceipt(ObjectsArray, PrintObjects);
		PrintForm.TemplateSynonym = NStr("en = 'Warehouse receipt'");
		PrintForm.FullTemplatePath = "Document._DemoGoodsReceipt.PF_MXL_WarehouseReceipt";
	EndIf;
	
EndProcedure

Function PrintWarehouseReceipt(RefsToObjects, PrintObjects)

	Spreadsheet = New SpreadsheetDocument;
	Spreadsheet.PrintParametersKey = "PrintParameters_DemoGoodsReceiptWarehouseReceipt";
	
	Template = PrintManagement.PrintFormTemplate("Document._DemoGoodsReceipt.PF_MXL_WarehouseReceipt");
	
	Query = New Query;
	Query.Text =
// ...
	|	_DemoGoodsReceipt.Ref IN (&Refs)";
	
	Query.Parameters.Insert("Refs", RefsToObjects);
	
	Selection = Query.Execute().Select();

	AreaCaption = Template.GetArea("Caption");
	Header = Template.GetArea("Header");
	AreaGoodsHeader = Template.GetArea("GoodsHeader");
	AreaGoods = Template.GetArea("Goods");
	Footer = Template.GetArea("Footer");

	InsertPageBreak = False;
	While Selection.Next() Do
		If InsertPageBreak Then
			Spreadsheet.PutHorizontalPageBreak();
		EndIf;
		RowNumberStart = Spreadsheet.TableHeight + 1;

		Spreadsheet.Put(AreaCaption);

		Header.Parameters.Fill(Selection);
		Spreadsheet.Put(Header, Selection.Level());

		Spreadsheet.Put(AreaGoodsHeader);
		SelectionGoods = Selection.Goods.Select();
		While SelectionGoods.Next() Do
			AreaGoods.Parameters.Fill(SelectionGoods);
			Spreadsheet.Put(AreaGoods, SelectionGoods.Level());
		EndDo;

		Footer.Parameters.Fill(Selection);
		Spreadsheet.Put(Footer);

		InsertPageBreak = True;
		
		PrintManagement.SetDocumentPrintArea(Spreadsheet, RowNumberStart, PrintObjects, Selection.Ref);
	EndDo;

	Return Spreadsheet;
	
EndFunction
```
- Code của khóa học: procedure `Print` và function `PrintWarehouseReceipt(RefsToObjects, PrintObjects)` (procedure do print wizard tạo được đổi thành function nhận hai parameter rồi trả về spreadsheet).
- Module của SSL được gọi tới: `PrintManagement.PrintFormInfo` lấy dòng print form theo ID; `PrintManagement.PrintFormTemplate` lấy template (dùng template đã sửa trong infobase nếu có, khác `GetTemplate`); `PrintManagement.SetDocumentPrintArea` ghi area của từng document vào `PrintObjects`.
- `FullTemplatePath` cho phép user mở "Edit template" từ print form.

### Print manager là data processor (document set)
Nguồn: nhánh lesson/21-23-theory — cf/DataProcessors/PrintGoodsReceipt2/Ext/ManagerModule.bsl
```bsl
Procedure Print(ObjectsArray, PrintParameters, PrintFormsCollection, PrintObjects, OutputParameters) Export
	
	PrintForm = PrintManagement.PrintFormInfo(PrintFormsCollection, "GoodsReceipt2");
	If PrintForm <> Undefined Then
		TemplateSynonym = "Goods receipt 2";
		PrintForm.SpreadsheetDocument = PrintGoodsReceipt(
			ObjectsArray,
			PrintObjects,
			"PF_MXL_GoodsReceipt2", 
			TemplateSynonym
		);
		PrintForm.TemplateSynonym = TemplateSynonym;
		PrintForm.FullTemplatePath = "Document._DemoGoodsReceipt.PF_MXL_GoodsReceipt2";
	EndIf;

// ...
EndProcedure
```
- Code của khóa học: data processor `PrintGoodsReceipt2` quản hai print form "GoodsReceipt2" và "GoodsReceipt3" (khối "GoodsReceipt3" lặp y hệt, đã lược) (cùng function `PrintGoodsReceipt` trong module, khác template; function này giống phần điền Caption + `SetDocumentPrintArea` ở trên nên đã lược); `PrintGoodsReceipt1` có cấu trúc giống hệt cho "GoodsReceipt1".
- Trong `AddPrintCommands` các form này được gọi dạng `DataProcessor.PrintGoodsReceipt2.GoodsReceipt2` — tên print manager thay thế + ID print form.
- Template vẫn nằm trong document `_DemoGoodsReceipt` (`PF_MXL_GoodsReceipt1..3`), data processor chỉ chứa code điền.

## Video tham khảo

Video bài giảng trên YouTube có phạm vi trùng với bài này. Khi dẫn cho người học, nói "Bạn có thể tham khảo thêm về <chủ đề> của khóa tại đây: [<tên video>](link)" — không nói "khóa cũ/Junior", không dùng mã JC (mã JC trong danh sách chỉ để tra nội bộ). Quy ước đầy đủ: `references/video.md#video-junior-course`.

Không có video bài giảng tương ứng — chỉ dẫn tài liệu Theory/Practice của bài.

<!-- video-qa-thuchanh:start -->

Video giải đáp tình huống thực chiến và video thực hành từng bước liên quan tới bài này (thẻ chi tiết, triệu chứng, lưu ý khi giới thiệu: `references/video.md#video-qa-thuc-chien`, `references/video.md#video-thuc-hanh`; cùng mẫu câu dẫn ở trên):

- [Tạo chức năng in hóa đơn chứng từ](https://www.youtube.com/watch?v=uwEBQJZG6t4&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=7) (5:31) — tạo mẫu in chứng từ bằng Print wizard (giải đáp tình huống; Bài 22 liên quan) _(mã nội bộ QA-7)_

<!-- video-qa-thuchanh:end -->


---

# § bai-23

# Bài 23 — SSL: Làm việc với file (FileSystem, FilesOperations) và Module markup

## Khái niệm chính

### Các kịch bản làm việc với file
- Mở file từ file system, sửa, lưu.
- Lưu dữ liệu file trong hệ thống (hoặc storage riêng), gồm đính kèm file vào object (ví dụ ảnh hàng lỗi đính kèm document nhận hàng).
- Làm việc với file lưu trong hệ thống: xem, versioning, sửa tuần tự (một user sửa thì người khác không sửa được).
- Các cơ chế nằm ở các subsystem khác nhau:
  - Làm việc với file trong file system: common modules **FileSystem** thuộc subsystem **"Core"**.
  - File lưu trong hệ thống/storage riêng, đính kèm vào object: subsystem riêng **"FilesOperations"**.

### File system (FileSystemClient / FileSystem)
- Các method hữu ích: chọn file và đặt binary data vào temporary storage, mở thư mục trong Explorer, mở URL bằng ứng dụng mặc định, v.v.
- Ví dụ bài: document mới **"Inventory recount"** với attributes "Warehouse", "EmployeeResponsible", "Comment" và tabular section "Goods" (attributes "Product", "Quantity", "QuantityFact"); subsystem "Sales" đổi tên thành "Training".
- Command "Import data from file" (client handler) gọi procedure **ImportFile_()** của common module **FileSystemClient**: truyền object kiểu **CallbackDescription** chỉ procedure gọi khi chọn file xong; tùy chọn truyền tham số filter lấy bằng **FileSystemClient.FileImportParameters**.
- Ưu điểm method library: xử lý web client (một số browser cần extension làm việc với file) — kiểm tra loại client và kết nối/từ chối file extension; xử lý trường hợp file đang bận hoặc không tồn tại.
- Ví dụ attribute **FileFullName** (đường dẫn file) và **FileURL** (link Internet), form attribute **"FileType"** dạng radio buttons chuyển giữa các trang:
  - Nút open của FileFullName: kiểm tra đã điền rồi gọi **OpenFile** của FileSystemClient, nếu chưa điền thì báo lỗi. Command "Show in Explorer" cùng logic.
  - Nút open của FileURL: gọi **OpenURL**.
- Thông báo user: **CommonClient.MessageToUser()** (dùng object kiểu MessageToUser); có thể nhận parameter **Cancel** để đặt True khi gọi từ handler có parameter đó. Phía server: **Common.MessageToUser()**.
- **OpenURL** hoạt động với public link, link chat messenger, link gửi email, navigation link tới object 1C, link 1C help... — mở theo tương ứng ứng dụng/protocol của hệ thống.
- Kiểm tra link hợp lệ theo phần đầu chuỗi bằng function **IsAllowedRef()**; bỏ phần đầu → báo lỗi.
- Server common module **FileSystem** có ít public method, chủ yếu làm việc với temporary files/directories.

### Files operations (FilesOperations)
- Trong thực tế, file đính kèm object lưu dưới dạng **attached files**.
- 3 cách lưu:
  1. Mỗi object "owner" có catalog riêng **"<ObjectName>AttachedFiles"** (ví dụ "InventoryRecountAttachedFiles") — khi quyền truy cập các owner khác nhau. Thường phù hợp nhất.
  2. Một catalog chung cho nhiều owner — khi ít owner (không quá 10), quyền trùng hoàn toàn và không định thay đổi.
  3. Mọi file trong catalog **Files** có sẵn của FilesOperations — cho configuration đơn giản.
- **File versioning chỉ có với file trong catalog "Files"**; catalog "<OwnerName>AttachedFiles" chỉ luôn có một version (mới nhất). Đôi khi kết hợp các cách trong một configuration.

### Các bước kết nối document InventoryRecount vào FilesOperations
1. Tạo catalog lưu attached files (có thể copy **_DemoProjectsAttachedFiles** trong demo): tên "InventoryRecountAttachedFiles", synonym "Attached files (Inventory recount)". **Important**: nhớ bỏ quyền interactive deletion của object mới khỏi role FullAccess!
2. Đặt link tới document "InventoryRecount" làm kiểu attribute **"FileOwner"** của catalog.
3. Quyết định có tạo group (folder) không: bật **"Hierarchical catalog"**, hierarchy type **"Folder and item hierarchy"**; đổi property **Use** thành **"For folder and item"** cho attributes Author, FileOwner, UniversalModificationDate, CreationDate, ChangedBy, PictureIndex, LongDesc. Nếu không cần group mà catalog copy đã hierarchical → tắt property này.
4. Nếu catalog chứa file service cần ẩn với user → thêm attribute **"Service"** kiểu Boolean.
5. Đưa catalog vào defined types **"AttachedFile"** (links) và **"AttachedFileObject"** (objects) (phải bật khả năng thay đổi trong support options).
6. Đưa catalog vào exchange plan **InfobaseUpdate**.
7. Tạo event subscriptions: catalog file trong types của property **"Source"** của một subscription (ví dụ CatalogManager.InventoryRecountAttachedFiles), object owner trong subscription còn lại (ví dụ DocumentObject.InventoryRecount). Ví dụ trong demo: "_DemoDetermineAttachedFileForm" và "_DemoSetDeletionMarkForAttachedDocumentFiles". Nếu sửa giải pháp chuẩn, các subscription này có thể đã có sẵn.

| Subscription | Event | Handler |
| --- | --- | --- |
| DetermineAttachedFileForm | FormGetProcessing | FilesOperationsClientServer.DetermineAttachedFileForm |
| SetDeletionMarkForAttachedDocumentFiles | BeforeWrite | FilesOperations.SetDeletionMarkForAttachedDocumentFiles |

8. Đưa link tới object có attached files (DocumentRef.InventoryRecount) vào defined type **"AttachedFilesOwner"**.
9. Nếu object không phải document → thêm type (object, không phải link) vào defined type **"AttachedFilesOwnerObject"**.

### Làm việc với attached files trong Enterprise mode
- Document có hyperlink tới attachments. Form attachments: thêm file theo đường dẫn, từ template, từ scanner; nút view, edit, commit, print; thêm nút trong "More actions".
- "Add local file" → dòng file có icon phần mở rộng.
- Double-click/Enter → form "Open file" với "Read-only" (= nút "View") và "Editing" (= nút "Edit"), flag "Do not ask again".
- "Edit": thông báo file bị khóa để sửa, mở bằng ứng dụng liên kết, text trong list chuyển xanh. Chỉ một user sửa tại một thời điểm; người khác xem version mới nhất.
- "Finish": file không thay đổi → không tạo version mới, mở khóa. File có sửa → "Commit", ngày sửa cập nhật.
- File card: F2 hoặc "More actions" → "Open card".
- "Undo edits": hủy khóa; nếu file đã sửa thì khi mở xem sẽ cảnh báo bản local khác bản đã lưu, cho chọn mở từ local copy hoặc từ application.
- "Save changes": cập nhật version nhưng không mở khóa. Có nút khóa file mà không mở.

### Tích hợp vào form document
- **OnCreateAtServer**: gọi **FilesOperations.OnCreateAtServer** với dữ liệu chuẩn bị sẵn. Muốn hyperlink "Attachments" trên command bar: gọi **FilesOperations.FilesHyperlink()**, đặt property **"Location"** = tên group (ở đây command bar).
- Hyperlink hiển thị số file đính kèm.
- Tắt hyperlink "Attachments" ở phần "Go to": bỏ mọi flag trong command interface của form cho command **AttachedFiles**.
- **OnOpen**: gọi FilesOperationsClient.OnOpen — đổi visibility nút scan nếu scan không khả dụng (như Web-client).
- **OnWriteAtServer**: gọi FilesOperations.OnWriteAtServer.
- **NotificationProcessing**: gọi FilesOperationsClient.NotificationProcessing.
- Thêm attachable command handlers (copy từ document "_DemoSalesOrder").
- Nếu copy event handler procedure → phải liên kết event với handler trong properties palette hoặc danh sách procedure của form module; nếu không procedure không hoạt động như handler.

### Module Markup (Region)
- Dùng **module regions** để tách procedure/function theo loại và ý nghĩa (form handlers, form element handlers...).
- Region có thể collapse/expand. **Ctrl + Shift + Num-** / **Ctrl + Shift + Num+** thu gọn/mở rộng mọi "node" trong module; cũng hoạt động trong reports và mọi cấu trúc cây trong 1C (ví dụ list hierarchical catalog ở view mode "Tree").
- Danh sách region khuyến nghị cho từng loại module do 1C development standards quy định. Trong region cấp cao có thể tạo region riêng với tên bất kỳ; region có thể tạo bên trong procedure/function.
- Tên region viết không có dấu cách.

### Biểu tượng kẹp giấy trong list form
- 2 thay đổi:
  1. Trong query của dynamic list thêm field **HasFiles**: 0 nếu không có file, 1 nếu có.
  2. Thêm field vào form table, loại **"Image field"**, tắt title, property **"ValuesPicture"** = picture **"ClipCollection"** (gồm 2 hình: rỗng cho 0 và kẹp giấy cho 1); property **"HeaderPicture"** = picture **"Clip"**.
- Thực hiện: tạo list form, bật flag **"CustomQuery"** cho dynamic list "List", thêm join tới information register **"FilesExist"** trong query text.

### Các method hữu ích khác
- **FillFilesAttachedToObject()**: truyền reference owner và array để nhận references tới attached files.
- **FileData()** của common module FilesOperations: trả thông tin về file (link tới catalog file, không phải file trên đĩa) — dùng khắp nơi khi làm việc với file infobase.
- Client procedures **OpenFile()**, **OpenFileDirectory()**, **SaveFileAs()** của **FilesOperationsClient** (tương tự FileSystemClient) nhận structure **FileData** chứ không phải link.
- Server module cũng: lấy binary data, thêm electronic signature, lưu file kèm chữ ký, copy attached files giữa các owner...

## Cú pháp & ví dụ code

Hyperlink Attachments trên command bar:
```bsl
FilesHyperlink = FilesOperations.FilesHyperlink();

FilesHyperlink.Location = "CommandBar";
```

OnOpen:
```bsl
FilesOperationsClient.OnOpen(ThisObject, Cancel);
```

OnWriteAtServer:
```bsl
FilesOperations.OnWriteAtServer(Cancel, CurrentObject, WriteParameters, ThisObject);
```

NotificationProcessing:
```bsl
FilesOperationsClient.NotificationProcessing(ThisObject, EventName);
```

Region:
```bsl
#Region <RegionName> (the region name is written without spaces)

// code inside the region

#EndRegion
```

[ghi chú ngoài nguồn] Code đầy đủ của ImportFile_, OpenFile/OpenURL handlers, OnCreateAtServer, query HasFiles và FillFilesAttachedToObject trong tài liệu gốc là ảnh chụp màn hình, không có văn bản để chép nguyên văn. → đã bổ sung ImportFile_, OnCreateAtServer, query HasFiles (nhánh lesson/21-23-theory); OpenFile/OpenURL handlers và FillFilesAttachedToObject vẫn chưa có nguồn (không có trong code của khóa ở cả hai nhánh 21-23).

## Thuộc tính/thiết lập quan trọng trong Designer
- Catalog attached files: attribute **FileOwner**; **Hierarchical catalog**, **"Folder and item hierarchy"**; property **Use** = **"For folder and item"** cho Author, FileOwner, UniversalModificationDate, CreationDate, ChangedBy, PictureIndex, LongDesc; attribute **Service** (Boolean).
- Defined types: **AttachedFile**, **AttachedFileObject**, **AttachedFilesOwner**, **AttachedFilesOwnerObject**.
- Exchange plan **InfobaseUpdate**.
- Event subscriptions: property **Source**; event **FormGetProcessing**, **BeforeWrite**.
- Form command interface: command **AttachedFiles**.
- Dynamic list: **CustomQuery**; information register **FilesExist**; field **HasFiles**.
- Form table field: **"Image field"**, **ValuesPicture** = "ClipCollection", **HeaderPicture** = "Clip".

## Lỗi thường gặp / lưu ý
- Quên bỏ quyền interactive deletion của catalog attached files mới khỏi FullAccess.
- Sửa defined types (và object SSL khác) cần bật khả năng thay đổi trong support options.
- File versioning chỉ có với catalog "Files"; catalog <OwnerName>AttachedFiles chỉ có version mới nhất.
- Copy event handler procedure mà không gán event trong form → không chạy.
- OpenURL kiểm tra link bằng IsAllowedRef(); link thiếu phần đầu → lỗi.
- "Undo edits" sau khi sửa → bản local khác bản lưu, cần chọn nguồn mở.

## Điểm cần nhớ
- FileSystem (Core) cho file trên đĩa; FilesOperations cho attached files trong infobase.
- FileSystemClient: ImportFile_ (CallbackDescription, FileImportParameters), OpenFile, OpenURL; xử lý web client và file bận/thiếu.
- CommonClient.MessageToUser() / Common.MessageToUser() để thông báo user.
- 3 cách lưu attached files; phổ biến nhất là catalog <ObjectName>AttachedFiles; versioning chỉ ở catalog Files.
- Kết nối: catalog + FileOwner, defined types, InfobaseUpdate, 2 event subscriptions, AttachedFilesOwner(Object).
- Form: FilesOperations.OnCreateAtServer + FilesHyperlink(), FilesOperationsClient.OnOpen, FilesOperations.OnWriteAtServer, FilesOperationsClient.NotificationProcessing.
- Icon kẹp giấy: field HasFiles qua join FilesExist + Image field với ClipCollection.
- Dùng #Region/#EndRegion để cấu trúc module theo development standards.

## Thẻ gợi ý bài thực hành (Practice 23)

23. Practice là một task tự nghiên cứu duy nhất. Để dễ theo dõi, thẻ dưới đây chia nó thành 4 phần theo đúng các yêu cầu của đề. Mỗi thẻ chỉ có gợi ý, không có lời giải. Mẫu tham khảo tốt nhất là chính SSL demo: document `InventoryRecount` của bài lý thuyết và item form của catalog `_DemoProducts` (có ảnh chính).

### Bài tập — Phần 1: Kết nối catalog _DemoStorageLocations vào FilesOperations (catalog file riêng)

- **Đề bài (tóm tắt):** Kết nối catalog `_DemoStorageLocations` vào FilesOperations. File của storage location phải lưu trong catalog riêng, không dùng catalog "Files" chung.
- **Gợi ý 1 — Hướng đi:** Làm lại đúng 9 bước của mục "Các bước kết nối document InventoryRecount vào FilesOperations", nhưng owner là **catalog** chứ không phải document. Vì vậy bước 9 (defined type cho object owner) là bắt buộc.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Catalog mới `_DemoStorageLocationsAttachedFiles` (copy từ `_DemoProjectsAttachedFiles`), attribute `FileOwner` kiểu `CatalogRef._DemoStorageLocations`. Quyết định có cần hierarchical hay không.
  - Defined types: `AttachedFile` (ref), `AttachedFileObject` (object), `AttachedFilesOwner` (CatalogRef owner), `AttachedFilesOwnerObject` (CatalogObject owner).
  - Exchange plan `InfobaseUpdate`: thêm catalog file.
  - Event subscriptions `_DemoDetermineAttachedFileForm` (Source thêm `CatalogManager` của catalog file) và `_DemoSetDeletionMarkForAttachedDocumentFiles` (xem có cần thêm owner không).
  - Role `FullAccess`: bỏ Interactive delete (và quyền xóa predefined) của catalog mới.
- **Gợi ý 3 — Khung bài làm:**
  1. Bật support cho các object SSL sẽ sửa (defined types, exchange plan, subscriptions, role).
  2. Copy catalog file, đổi tên/synonym, đổi kiểu FileOwner.
  3. Thêm vào 4 defined types, InfobaseUpdate, subscriptions.
  4. Sửa FullAccess cho catalog mới.
  5. Update DB configuration.
- **Lỗi hay gặp:**
  - Quên `AttachedFilesOwnerObject` vì bài lý thuyết là document (document không cần bước này).
  - Copy catalog đang hierarchical nhưng không cần group: phải tắt hoặc đổi Use của các attribute như mục 3 của lý thuyết.
  - Quên bỏ Interactive delete ở FullAccess (lý thuyết nhấn mạnh "Important").
- **Tự kiểm tra:** Trong Enterprise, mở một storage location, thêm file qua form attachments (khi đã làm Phần 2). File mới phải nằm trong list của catalog `_DemoStorageLocationsAttachedFiles`, không nằm trong "Files".

### Bài tập — Phần 2: Item form có submenu file và hyperlink "Attachments"

- **Đề bài (tóm tắt):** Item form của storage location có submenu làm việc với file và hyperlink "Attachments" như bài lý thuyết.
- **Gợi ý 1 — Hướng đi:** Xem "Tích hợp vào form document" và code demo của form `InventoryRecount` ở mục theory demo bên dưới. Có 4 event của form cần gọi tới SSL, cộng các attachable handler.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Form module (item form của catalog): `OnCreateAtServer` (`&AtServer`), `OnOpen` (`&AtClient`), `OnWriteAtServer` (`&AtServer`), `NotificationProcessing` (`&AtClient`).
  - SSL: `FilesOperations.FilesHyperlink()` với `Location = "CommandBar"`, `FilesOperations.OnCreateAtServer`, `FilesOperationsClient.OnOpen`, `FilesOperations.OnWriteAtServer`, `FilesOperationsClient.NotificationProcessing`.
  - Attachable handlers `Attachable_*` (copy từ `_DemoSalesOrder` hoặc `_DemoProducts`).
  - Bọc mỗi lời gọi trong `// StandardSubsystems.StoredFiles` … `// End StandardSubsystems.StoredFiles`.
- **Gợi ý 3 — Khung bài làm:**
  1. Kiểm tra form đã có handler nào (OnCreateAtServer, OnOpen...). Nếu có thì chèn lời gọi vào, không tạo trùng.
  2. Thêm các handler còn thiếu **qua Properties palette** để chúng được gán với event.
  3. Copy các attachable handler, đặt vào region phù hợp.
- **Lỗi hay gặp:**
  - Copy procedure handler mà không gán event trong form → không chạy (lý thuyết đã cảnh báo).
  - Quên `OnWriteAtServer` → file thêm trên form object mới chưa ghi không được lưu đúng.
  - Hyperlink "Attachments" xuất hiện 2 lần (command bar và "Go to"): bỏ flag command AttachedFiles trong command interface của form.
- **Tự kiểm tra:** Hyperlink hiện số file đính kèm và tăng khi thêm file. Submenu file hoạt động.

### Bài tập — Phần 3: Cột "Paperclip" trên list form

- **Đề bài (tóm tắt):** List form có cột hình kẹp giấy cho storage location có file đính kèm.
- **Gợi ý 1 — Hướng đi:** Xem "Biểu tượng kẹp giấy trong list form" và query HasFiles của InventoryRecount trong theory demo: bật custom query cho dynamic list, join information register `FilesExist`, thêm Image field.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Dynamic list `List`: flag **CustomQuery**, LEFT JOIN `InformationRegister.FilesExist` theo `ObjectWithFiles`, field `HasFiles` (0/1).
  - Form table: field loại Image field, `ValuesPicture` = `ClipCollection`, `HeaderPicture` = `Clip`, tắt title.
- **Gợi ý 3 — Khung bài làm:**
  1. Mở list form của catalog (tạo nếu chưa có), bật CustomQuery.
  2. Sửa query: thêm join và field HasFiles. Chú ý trường hợp không có record trong `FilesExist` (giá trị NULL).
  3. Kéo field HasFiles vào table, đổi sang Image field, gán 2 picture.
- **Lỗi hay gặp:**
  - Chỉ xét `HasFiles = TRUE` mà không tính NULL → kết quả trống hoặc sai với item chưa từng có file.
  - Dùng INNER JOIN → mất các storage location không có file.
  - Để field dạng input field → hiện số 0/1 thay vì hình.
- **Tự kiểm tra:** Item có file hiện kẹp giấy, item không có file để trống. Xóa hết file của một item thì kẹp giấy biến mất sau khi refresh list.

### Bài tập — Phần 4: Ảnh chính trên item form (như _DemoProducts)

- **Đề bài (tóm tắt):** Gắn và hiển thị ảnh chính của storage location trên item form. Ảnh phải còn sau khi lưu, đóng và mở lại form. Các nút "View", "Clear", "Open the attachment card" và submenu ảnh phải chạy. Không cần nút "PDF image album". Nhớ chia module bằng region.
- **Gợi ý 1 — Hướng đi:** Ảnh chính là một **attribute** của catalog trỏ tới file đính kèm (vì thế ảnh còn sau khi mở lại). FilesOperations có sẵn "file field" vẽ khung ảnh và các nút, chỉ cần khai báo nó trong `OnCreateAtServer`. Hãy đọc item form của `_DemoProducts` để xem cách nó khai báo.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Catalog `_DemoStorageLocations`: attribute mới (ví dụ `PicturesFile`) kiểu `CatalogRef._DemoStorageLocationsAttachedFiles`.
  - Item form: một group trống để chứa ảnh (sắp xếp lại form thành 2 cột nếu muốn: ảnh bên trái, Code/Description bên phải).
  - SSL: `FilesOperations.FileField()` (các property chỉ chỗ đặt, data path tới attribute ảnh, form attribute chứa địa chỉ dữ liệu ảnh), `FilesOperations.SettingsOfFileManagementInForm()`. `FilesOperations.OnCreateAtServer` nhận được **array** nhiều item (hyperlink + file field).
  - Attachable handlers cho preview field: `Attachable_PreviewFieldClick`, `Attachable_PreviewFieldCheckDragging`, `Attachable_PreviewFieldDrag`, `Attachable_AttachedFilesPanelCommand`.
  - Region theo chuẩn: `FormEventHandlers`, `FormHeaderItemsEventHandlers`, `FormCommandsEventHandlers`...
- **Gợi ý 3 — Khung bài làm:**
  1. Thêm attribute ảnh vào catalog, update DB.
  2. Thêm group chứa ảnh vào item form.
  3. Trong `OnCreateAtServer`: tạo tham số hyperlink (Phần 2) và tham số file field, gom vào array, gọi `OnCreateAtServer` của SSL.
  4. Copy các attachable handler cho preview field, đặt trong region.
  ```bsl
  &AtServer
  Procedure OnCreateAtServer(Cancel, StandardProcessing)
  	// StandardSubsystems.StoredFiles
  	// 1) tham số hyperlink (như Phần 2)
  	___
  	// 2) tham số file field: chỗ đặt = group ảnh, data path = attribute ảnh của Object, attribute địa chỉ ảnh
  	___
  	// 3) gom cả hai vào Array, (tùy chọn) settings, gọi FilesOperations.OnCreateAtServer
  	___
  	// End StandardSubsystems.StoredFiles
  EndProcedure
  ```
- **Lỗi hay gặp:**
  - Lưu ảnh vào form attribute thay vì attribute của catalog → mở lại form thì mất ảnh.
  - Kiểu attribute ảnh trỏ tới catalog "Files" chung hoặc catalog của object khác, trái yêu cầu "catalog riêng".
  - Quên các handler preview field hoặc không gán event → click/kéo thả ảnh không có tác dụng.
  - Thêm procedure mà không đặt trong `#Region` (đề nhắc rõ).
- **Tự kiểm tra:** Click khung ảnh → chọn file → ảnh hiện ngay. Save, đóng, mở lại → ảnh vẫn còn. Thử "View", "Clear", "Open the attachment card". File ảnh cũng xuất hiện trong danh sách Attachments và trong catalog file riêng.

## Code demo của bài Theory (repo 1CJDCourse, nhánh lesson/21-23-theory)

Trong nhánh lesson/21-23-theory, phần code của khóa học cho bài 23 là document `InventoryRecount` (form module + list form) và catalog `InventoryRecountAttachedFiles` (copy từ `_DemoProjectsAttachedFiles` của SSL demo, manager module giữ nguyên code của SSL). Các lời gọi `FilesOperations*`, `FileSystemClient.*` là module của SSL (Standard Subsystems Library).

### Kết nối form document vào FilesOperations (có #Region)
Nguồn: nhánh lesson/21-23-theory — cf/Documents/InventoryRecount/Forms/DocumentForm/Ext/Form/Module.bsl
```bsl
#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	// StandardSubsystems.StoredFiles
	FilesHyperlink = FilesOperations.FilesHyperlink();
	FilesHyperlink.Location = "CommandBar";
	FilesOperations.OnCreateAtServer(ThisObject, FilesHyperlink);
	// End StandardSubsystems.StoredFiles
	
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	
	// StandardSubsystems.StoredFiles
	FilesOperationsClient.OnOpen(ThisObject, Cancel);
	// End StandardSubsystems.StoredFiles

EndProcedure

&AtServer
Procedure OnWriteAtServer(Cancel, CurrentObject, WriteParameters)
		
	// StandardSubsystems.StoredFiles
	FilesOperations.OnWriteAtServer(Cancel, CurrentObject, WriteParameters, ThisObject);
	// End StandardSubsystems.StoredFiles
	
EndProcedure

&AtClient
Procedure NotificationProcessing(EventName, Parameter, Source)
	
	// StandardSubsystems.StoredFiles
	FilesOperationsClient.NotificationProcessing(ThisObject, EventName);
	// End StandardSubsystems.StoredFiles

EndProcedure

#EndRegion

#Region FormHeaderItemsEventHandlers

// StandardSubsystems.StoredFiles
&AtClient
Procedure Attachable_PreviewFieldClick(Item, StandardProcessing)

	FilesOperationsClient.PreviewFieldClick(ThisObject, Item, StandardProcessing);

EndProcedure

&AtClient
Procedure Attachable_PreviewFieldCheckDragging(Item, DragParameters, StandardProcessing)

	FilesOperationsClient.PreviewFieldCheckDragging(ThisObject, Item,
				DragParameters, StandardProcessing);

EndProcedure

&AtClient
Procedure Attachable_PreviewFieldDrag(Item, DragParameters, StandardProcessing)

	FilesOperationsClient.PreviewFieldDrag(ThisObject, Item,
				DragParameters, StandardProcessing);

EndProcedure

&AtClient
Procedure Attachable_AttachedFilesPanelCommand(Command)

	FilesOperationsClient.AttachmentsControlCommand(ThisObject, Command);

EndProcedure
// End StandardSubsystems.StoredFiles

#EndRegion
```
- Code của khóa học: các event handler của form và attachable handler, mỗi lời gọi bọc trong service comments `// StandardSubsystems.StoredFiles`; module chia region `FormEventHandlers`, `FormHeaderItemsEventHandlers` (tên region không có dấu cách).
- Module của SSL được gọi tới: `FilesOperations.FilesHyperlink()` + `Location = "CommandBar"` → hyperlink "Attachments" trên command bar; `FilesOperations.OnCreateAtServer`, `FilesOperationsClient.OnOpen`, `FilesOperations.OnWriteAtServer`, `FilesOperationsClient.NotificationProcessing`.
- Các procedure `Attachable_*` (copy từ `_DemoSalesOrder`) phải được gán làm handler trong properties palette, nếu không sẽ không chạy.

### Chọn file bằng FileSystemClient.ImportFile_
Nguồn: nhánh lesson/21-23-theory — cf/Documents/InventoryRecount/Forms/DocumentForm/Ext/Form/Module.bsl
```bsl
#Region FormCommandsEventHandlers

&AtClient
Procedure ImportDataFromFile(Command)
	
	FileImportParameters = FileSystemClient.FileImportParameters();
	FileImportParameters.FormIdentifier = UUID;
	FileImportParameters.Dialog.Filter = 
		"Tables (*.xls,*.xlsx,*.xlsm)|*.xls;*.xlsx;*.xlsm;
		||Microsoft Excel 1997-2003 (*.xls)|*.xls
		||Microsoft Excel (*.xlsx,*.xlsm)|*.xlsx;*.xlsm";
	
	CallbackDescription = New CallbackDescription("ImportDataAfterSelection", ThisObject);
	
	FileSystemClient.ImportFile_(CallbackDescription, FileImportParameters);
	
EndProcedure

&AtClient
Procedure ImportDataAfterSelection(FileThatWasPut, AdditionalParameters) Export
	
	If FileThatWasPut = Undefined Then
		Return;
	EndIf;

	// FileName = FileThatWasPut.Name
	// BinaryData = GetFromTempStorage(FileThatWasPut.Location)
	
EndProcedure

#EndRegion
```
- Code của khóa học: command `ImportDataFromFile` và callback `ImportDataAfterSelection` (export, nhận file đã đặt vào temporary storage).
- Module của SSL: `FileSystemClient.FileImportParameters()` trả structure tham số (`FormIdentifier`, `Dialog.Filter`...); `FileSystemClient.ImportFile_` mở dialog, đưa file lên server và gọi `CallbackDescription`.
- Trong demo phần xử lý chỉ để ở dạng comment: tên file ở `FileThatWasPut.Name`, binary data đọc bằng `GetFromTempStorage(FileThatWasPut.Location)` — `ImportFile_` đã lo phần chọn file và đưa file vào temporary storage (việc mà nếu dùng method của platform như `FileDialog`, `BeginPutFileToServer` thì developer phải tự viết).

### Biểu tượng kẹp giấy: query HasFiles của dynamic list
Nguồn: nhánh lesson/21-23-theory — cf/Documents/InventoryRecount/Forms/ListForm/Ext/Form.xml
```xml
				<QueryText>SELECT
	DocumentInventoryRecount.Ref,
	DocumentInventoryRecount.DeletionMark,
	DocumentInventoryRecount.Number,
	DocumentInventoryRecount.Date,
	DocumentInventoryRecount.Posted,
	DocumentInventoryRecount.StorageLocation,
	DocumentInventoryRecount.EmployeeResponsible,
	DocumentInventoryRecount.Comment,
	DocumentInventoryRecount.Goods,
	DocumentInventoryRecount.PointInTime,
	CASE
		WHEN FilesExist.HasFiles = TRUE THEN
			1
		ELSE
			0
	END AS HasFiles
FROM
	Document.InventoryRecount AS DocumentInventoryRecount
	LEFT JOIN InformationRegister.FilesExist AS FilesExist
		ON DocumentInventoryRecount.Ref = FilesExist.ObjectWithFiles</QueryText>
```
Nguồn: nhánh lesson/21-23-theory — cf/Documents/InventoryRecount/Forms/ListForm/Ext/Form.xml
```xml
					<HeaderPicture>
						<xr:Ref>CommonPicture.Clip</xr:Ref>
						<xr:LoadTransparent>true</xr:LoadTransparent>
					</HeaderPicture>
					<ValuesPicture>
						<xr:Ref>CommonPicture.ClipCollection</xr:Ref>
						<xr:LoadTransparent>true</xr:LoadTransparent>
					</ValuesPicture>
```
- Code của khóa học: bật CustomQuery cho dynamic list, LEFT JOIN information register `FilesExist` (của SSL) theo `ObjectWithFiles`, chuyển Boolean thành 0/1 bằng `CASE`.
- Picture field `HasFiles`: `HeaderPicture` = `CommonPicture.Clip`, `ValuesPicture` = `CommonPicture.ClipCollection` (hình rỗng cho 0, kẹp giấy cho 1).

## Video tham khảo

Video bài giảng trên YouTube có phạm vi trùng với bài này. Khi dẫn cho người học, nói "Bạn có thể tham khảo thêm về <chủ đề> của khóa tại đây: [<tên video>](link)" — không nói "khóa cũ/Junior", không dùng mã JC (mã JC trong danh sách chỉ để tra nội bộ). Quy ước đầy đủ: `references/video.md#video-junior-course`.

Không có video tương ứng — chỉ dẫn tài liệu Theory/Practice của bài.


---

# § bai-24

# Bài 24 — Accounting (Kế toán trên nền tảng 1C)

## Khái niệm chính

### Các loại metadata then chốt
- Bài không giảng lý thuyết kế toán; giả định học viên đã biết khái niệm cơ bản.
- **Chart of accounts**: mô tả mọi tài khoản dùng ghi nhận hoạt động (ví dụ Materials, Cash).
- **Accounting register**: thông tin các nghiệp vụ theo tài khoản và totals của tài khoản.
- **Chart of characteristic types**: mô tả đối tượng phân tích (extra dimensions) mà kế toán theo dõi trên tài khoản (ví dụ theo từng material).

### Tạo Chart of accounts
- Tạo subsystem "Accounting", chart of accounts "ChartOfAccounts".
- Functional option **"UseAccounting"**, đưa các object đã tạo (và sẽ tạo) vào **Content**.
- Tab **Data**: code length 10, name length 100, bật **"Autoorder by code"** (sắp xếp mặc định theo code).
- Theo dõi cả số lượng: thêm giá trị vào nhánh **"accounting flags"** — flag **"Quantitative"**, kiểu Boolean mặc định.

### Extra dimension types / Extra dimension
- **"Extra dimension types"**: các phân đoạn phân tích; mỗi tài khoản có thể theo dõi theo nhiều extra dimension types.
- **"Extra dimension"**: đối tượng phân tích cụ thể.
- Ví dụ: tài khoản "Goods" theo dõi theo products và warehouses (extra dimension types); sản phẩm "Dark chocolate 100g" và kho "Main" trong một record là extra dimensions.
- Chart of characteristic types được dùng để mô tả extra dimension types và kiểu giá trị extra dimension có thể nhận.
- Tạo chart of characteristic types **"ExtraDimensionTypes"**, đưa vào subsystem "Accounting", characteristic value types = references tới catalogs và documents.
- Trong chart of accounts (tab **"Extra dimension"**): property **"Extra dimension types"** = ExtraDimensionTypes; **"Maximum extra dimensions"** = 3.
- Danh sách extra dimension cho configuration → tạo **predefined values** trong ExtraDimensionTypes. Tương tự tạo predefined accounts.

### Accounting register
- Tạo "GeneralJournal", đưa vào subsystem "Accounting". Property **"Chart of accounts"** = chart đã tạo; bật flag **"Correspondence"** để record chứa debit và credit. Không bật → không hỗ trợ "double entry", record giống accumulation register (một cho debit + một cho credit).
- Không có dimensions; resources: **Amount** và **Quantity**. Với Quantity chỉ định accounting flag **"Quantitative"** để chỉ điền được cho tài khoản có quantitative accounting.
- Flag **"Balance"** của resource (mặc định bật): platform kiểm tra resource value ở bên debit và credit bằng nhau khi ghi. Giữ cho Amount (không thể tạo record Dr 100 / Cr 80). Tắt cho Quantity (không phải mọi tài khoản đều theo dõi số lượng — ví dụ "Goods" có, "Settlements with suppliers" không).
- Recorders: documents "PurchaseInvoice", "SalesInvoice", "ReturnOfGoodsFromCustomer"; sửa handler posting.
- Resource có accounting flag phải ghi tên với postfix **Dr** (debit) hoặc **Cr** (credit). Extra dimensions ghi dạng `ExtDimensionsDr(/ExtDimensionsCr)[RefToExtraDimensionType] = ExtraDimensionValue`.
- Gán manager của chart of characteristic types ExtraDimensionTypes vào biến chỉ để dòng code ngắn hơn, không bắt buộc.
- Record: tài khoản hiển thị chỉ bằng số, extra dimensions được điền, quantity điền cho tài khoản quantitative.
- List form nhiều cột; standard solutions thường tự tổ chức nhóm giá trị debit/credit theo chiều dọc (AccountDr / Extra dimension 1 Dr / 2 Dr / 3 Dr).

### Presentation tài khoản
- Muốn hiển thị `<AccountCode + AccountDescription>`: handler **PresentationGetProcessing** trong **manager module** của Chart of accounts. Sự kiện xảy ra khi platform lấy presentation của object (hiển thị trong document form, register list form...).
- 3 parameter: **Data**, **Presentation**, **StandardProcessing** — phải tắt standard processing để thuật toán riêng chạy.
- **Data** chứa link tới object và field là default presentation field trên tab "Data" (ở đây Code).
- **Presentation** là presentation cuối cùng user thấy.
- Truy cập attribute khác: có thể đọc từ object theo reference, nhưng nếu không cần query phức tạp thì khuyến nghị dùng handler **PresentationFieldsGetProcessing** để chỉ định attributes sẽ được lấy và truyền vào parameter "Data" của PresentationGetProcessing (ví dụ thêm property "Description"), rồi nối code và description vào Presentation.

### Report "Trial balance"
- Report mới đưa vào subsystem "Accounting", tạo main data composition schema, data set loại "Query", mở query console, nhánh **"AccountingRegisters"**.
- Các bảng mới:
  - **ExtDimensions**: bảng **physical**, lưu giá trị extra dimension cho records (bảng chính không lưu extra dimension cho từng record).
  - **RecordsWithExtDimensions**: bảng **virtual**, kết hợp hai bảng thật (bảng chính + "ExtDimensions"): thông tin nghiệp vụ theo tài khoản kèm extra dimension.
  - **DrCrTurnovers**: bảng **virtual**, lấy turnover giữa các tài khoản đối ứng. Chỉ có trong register hỗ trợ correspondence (flag "correspondence" bật). Khác "Turnover": phân tích turnover giữa các tài khoản khi đã biết tài khoản nào ghi nợ, tài khoản nào ghi có.
- Cần cả balance và turnover → chọn từ virtual table **BalanceAndTurnovers**: có thêm field **<Resource>Dr** và **<Resource>Cr** cho mọi resource, cùng **<Resource>OpeningSplittedBalanceDr / <Resource>OpeningSplittedBalanceCr** (cho <Resource>OpeningBalance) và **<Resource>ClosingSplittedBalanceDr / <Resource>ClosingSplittedBalanceCr** (cho <Resource>ClosingBalance). Field splitted balance chỉ dùng cho query có totals.
- Chọn field: account, balance và turnover amount theo debit/credit; nhóm field thành OpeningBalance, Turnover, ClosingBalance; chỉ định resources; tạo parameter **Period** kiểu **StandardPeriod**; grouping "Account"; chọn mọi resource vào selected fields.
- Sửa lỗi hiển thị:
  - Header cột lặp (Opening Balance và Opening Balance.Dr): tab **"Other settings"** → property **"Field header type"** = **"Brief"**.
  - Totals closing balance bằng 0: trên tab **"Data sets"** các balance field tự nhận **accounting roles** → tính theo quy tắc kế toán, không phù hợp report này → xóa roles của resource field.

### Document "General journal entry" (nhập bút toán thủ công)
- User có quyền cao (ví dụ kế toán trưởng) thường được nhập bút toán trực tiếp vào general journal (accounting register).
- Document chỉ đóng vai trò recorder (accumulation và accounting registers không sửa trực tiếp được nếu không có recorder), không lưu dữ liệu trong document.
- Đưa vào subsystem "Accounting" và functional option "Use accounting". **Tắt posting** của document (không phản ánh nghiệp vụ thực, không cần sự kiện "Post").
- Chỉ định document làm recorder của accounting register, tạo document form, thêm bảng register records lên form, gộp cột thành group.
- Cho phép chọn period cho từng record (một document có thể có record nhiều kỳ). Muốn period = ngày document: ẩn cột Period, điền Period cho từng record của record set trước khi ghi document.
- Tắt posting → cũng tắt tự động xóa record trong register phụ thuộc (property **"Delete records"** trên tab **"Posting"**) → document có deletion mark vẫn còn record và ảnh hưởng totals.
- Xóa record set thì document trở nên vô dụng (user mở thấy bảng rỗng).
- **Activity**: record của mọi register có property Activity. Activity = False → record bị loại khi tính totals (vẫn lưu trong bảng physical).
- Deletion mark có thể đặt/bỏ từ document form, list form hoặc bằng code; khi đó record set lấy từ property **RegisterRecords** có thể rỗng (vì Posting tắt) → phải làm việc trực tiếp với register record set: tạo set mới, đặt filter theo recorder và đọc records.
- List form tự sinh của accounting register không hiện field Activity nhưng dùng hình đầu dòng: active → màu, inactive → đen trắng. Bài tạo list form riêng để user lọc theo active/inactive và gộp cột gọn hơn.

## Cú pháp & ví dụ code

Ví dụ record vi phạm "Balance" (credit nhỏ hơn debit):
```bsl
AccountDr    Amount    AccountCr                            Amount
"Goods"          100      "Settlements with suppliers"      80
```

Cú pháp extra dimensions trong record:
```bsl
ExtDimensionsDr(/ExtDimensionsCr)[RefToExtraDimensionType] = ExtraDimensionValue
```

Chữ ký handler (manager module của Chart of accounts):
```bsl
PresentationGetProcessing(Data, Presentation, StandardProcessing)
```

[ghi chú ngoài nguồn] Code posting các document, PresentationGetProcessing, PresentationFieldsGetProcessing, điền Period trước khi ghi và xử lý Activity khi đặt deletion mark trong tài liệu gốc là ảnh chụp màn hình, không có văn bản để chép nguyên văn. → đã bổ sung (nhánh lesson/24-theory).

## Thuộc tính/thiết lập quan trọng trong Designer
- Chart of accounts: tab **Data** (code length, name length, **Autoorder by code**, default presentation field); nhánh **accounting flags** (flag **Quantitative**); tab **Extra dimension** (**Extra dimension types**, **Maximum extra dimensions**); predefined accounts.
- Chart of characteristic types **ExtraDimensionTypes**: characteristic value types, predefined values.
- Accounting register: **Chart of accounts**, **Correspondence**; resources **Amount**, **Quantity** (accounting flag Quantitative); flag **Balance**; recorders.
- Functional option **UseAccounting** → **Content**.
- DCS: data set "Query"; parameter **Period** (StandardPeriod); tab **Other settings** → **Field header type** = "Brief"; tab **Data sets** → accounting roles.
- Document: posting (tắt), tab **Posting** → **Delete records**.
- Register record: **Activity**.

## Lỗi thường gặp / lưu ý
- Không bật "Correspondence" → register không có double entry.
- Để flag "Balance" bật cho Quantity → lỗi vì không mọi tài khoản theo dõi số lượng; tắt cho Quantity, giữ cho Amount.
- Quên postfix Dr/Cr cho resource có accounting flag.
- Header cột lặp trong report → Field header type = "Brief".
- Totals closing balance = 0 do accounting roles tự gán cho balance fields → xóa roles.
- Document tắt posting → không tự xóa record khi đặt deletion mark → dùng Activity.
- RegisterRecords có thể rỗng khi đặt deletion mark từ list form/code → tạo record set mới, filter theo recorder, đọc records.
- Tránh đọc lại object trong PresentationGetProcessing; dùng PresentationFieldsGetProcessing.

## Điểm cần nhớ
- Ba metadata kế toán: Chart of accounts, Accounting register, Chart of characteristic types.
- Extra dimension types (phân đoạn) vs Extra dimension (đối tượng cụ thể); ExtraDimensionTypes gắn vào chart of accounts, Maximum extra dimensions.
- Accounting flag "Quantitative" + resource Quantity; flag Balance chỉ giữ cho Amount.
- Correspondence = double entry; resource dùng postfix Dr/Cr; ExtDimensionsDr/ExtDimensionsCr[...].
- PresentationGetProcessing + PresentationFieldsGetProcessing để hiển thị "Code + Description".
- Bảng mới: ExtDimensions (physical), RecordsWithExtDimensions, DrCrTurnovers (virtual); report dùng BalanceAndTurnovers.
- Document nhập tay: tắt posting, làm recorder; dùng Activity = False để loại record khỏi totals khi đánh dấu xóa.

## Thẻ gợi ý bài thực hành (Practice 24)

Các thẻ dưới đây đi theo thứ tự đề trong 24. Practice, làm trên configuration của bạn (các document PurchaseInvoice, SalesInvoice, ReturnOfGoodsFromCustomer, InventoryTransfer). Mỗi thẻ chỉ có gợi ý, không có lời giải. Code demo trong mục theory demo bên dưới chỉ minh họa cú pháp. Bạn phải tự viết posting cho document của mình, kể cả document chuyển kho mà demo không có.

### Bài tập 1 — Cơ chế kế toán: chart of accounts, extra dimensions, accounting register

- **Đề bài (tóm tắt):** Kế toán theo bút toán kép Dr/Cr, có analytics (extra dimension) cho tài khoản.
- **Gợi ý 1 — Hướng đi:** Ba metadata trong mục "Các loại metadata then chốt": Chart of characteristic types mô tả loại extra dimension, Chart of accounts dùng nó, Accounting register có Correspondence để mỗi record có cả Dr lẫn Cr.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Chart of characteristic types `ExtraDimensionTypes`: value types là catalog refs (Products, Warehouses, Counterparties...).
  - Chart of accounts: tab Data (code length, Autoorder by code), accounting flag **Quantitative**, tab Extra dimension (`Extra dimension types` = ExtraDimensionTypes, `Maximum extra dimensions`).
  - Accounting register `GeneralJournal`: `Chart of accounts`, flag **Correspondence**, resources `Amount` (Balance bật) và `Quantity` (accounting flag Quantitative, Balance **tắt**).
  - Subsystem "Accounting" chứa các object này.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo ExtraDimensionTypes, khai báo type, tạo predefined values cho từng loại analytics cần dùng.
  2. Tạo chart of accounts, gắn ExtraDimensionTypes, thêm flag Quantitative.
  3. Tạo accounting register, bật Correspondence, tạo 2 resource như trên.
  4. Đưa tất cả vào subsystem Accounting.
- **Lỗi hay gặp:**
  - Quên Correspondence → register không có double entry (record tách Dr và Cr riêng).
  - Để Balance bật cho Quantity → lỗi khi ghi bút toán giữa tài khoản có và không có số lượng.
  - Maximum extra dimensions nhỏ hơn số analytics của tài khoản Goods (cần ít nhất 2).
- **Tự kiểm tra:** Mở chart of accounts trong Enterprise mode. Tab extra dimensions của một tài khoản cho chọn đúng các loại analytics.

### Bài tập 2 — Cho user bật/tắt kế toán

- **Đề bài (tóm tắt):** User bật/tắt được tính năng kế toán. Khi tắt thì không thấy object nào liên quan.
- **Gợi ý 1 — Hướng đi:** Functional option lưu trong Boolean constant (xem bài 15 và mục "Tạo Chart of accounts"). Object trong Content bị ẩn khỏi interface khi option tắt.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Constant Boolean (ví dụ `UseAccounting`), functional option `UseAccounting` với Location = constant đó. Content: chart of accounts, accounting register, ExtraDimensionTypes, subsystem Accounting, report Trial balance, document nhập bút toán tay. Đưa constant lên form cài đặt của ứng dụng.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo constant và functional option, đặt Location.
  2. Thêm mọi object kế toán (kể cả object tạo ở bài 5, 6) vào Content.
  3. Cho user sửa constant trên form settings (có refresh interface như bài 15).
- **Lỗi hay gặp:**
  - Tạo report/document mới ở bài sau mà quên thêm vào Content.
  - Role của user thường không có Read trên constant → interface sai. Có thể bật "Privileged get mode" cho option.
- **Tự kiểm tra:** Tắt option → section Accounting và mọi object kế toán biến mất. Bật lại → xuất hiện.

### Bài tập 3 — Tài khoản 01 Goods, 02 Trade payables, 03 Trade receivables

- **Đề bài (tóm tắt):** Goods theo dõi theo product + warehouse và có số lượng. Trade payables và Trade receivables theo dõi theo counterparty.
- **Gợi ý 1 — Hướng đi:** Tài khoản là **predefined** của chart of accounts. Analytics của từng tài khoản đặt ở tab extra dimensions của tài khoản. Số lượng bật bằng accounting flag Quantitative (cho tài khoản và cho từng extra dimension nếu cần).
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Chart of accounts → Predefined: code `01`, `02`, `03`, Name tiếng Anh không dấu cách (dùng trong code dạng `ChartsOfAccounts.<Tên chart>.<Name>`). Mỗi tài khoản: flag Quantitative (chỉ 01), danh sách extra dimension types.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo 3 predefined accounts với code và description.
  2. 01: thêm extra dimensions Product, Warehouse, bật Quantitative.
  3. 02, 03: thêm extra dimension Counterparty.
  4. (Tùy chọn) handler presentation để tài khoản hiện "Code Description" (xem mục "Presentation tài khoản").
- **Lỗi hay gặp:**
  - Bật Quantitative cho 02/03 → phải ghi số lượng cho tài khoản công nợ.
  - Thứ tự extra dimension khác nhau giữa các tài khoản mà code lại truy cập theo chỉ số thay vì theo predefined type.
- **Tự kiểm tra:** Danh sách chart of accounts hiện 01, 02, 03 theo thứ tự code. Mở tài khoản 01 thấy 2 extra dimension và cờ số lượng.

### Bài tập 4 — Bút toán khi mua, bán, trả hàng, chuyển kho

- **Đề bài (tóm tắt):** Mua: Dr Goods – Cr Trade payables. Bán: Dr Trade receivables – Cr Goods. Trả hàng: như bán nhưng quantity và amount âm. Chuyển kho: Dr Goods – Cr Goods, chỉ khác extra dimension Warehouse.
- **Gợi ý 1 — Hướng đi:** Thêm accounting register vào **Register records** của 4 document, rồi trong `Posting` ghi thêm record vào `RegisterRecords.<AccountingRegister>` cạnh các record accumulation hiện có. Cú pháp: mục "Accounting register" (postfix Dr/Cr cho resource có accounting flag, `ExtDimensionsDr[...]`/`ExtDimensionsCr[...]`).
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Object module của từng document, procedure `Posting(Cancel, PostingMode)` (server).
  - Record: `Period`, `AccountDr`, `AccountCr`, `Amount` (một property vì Balance bật), `QuantityDr` hoặc `QuantityCr` (bên nào là tài khoản Goods), extra dimensions theo predefined của ExtraDimensionTypes.
  - Counterparty: mua thì lấy nhà cung cấp, bán/trả thì lấy khách hàng của document.
  - Đặt `Write = True` cho record set kế toán.
- **Gợi ý 3 — Khung bài làm:**
  1. Thêm accounting register vào Register records của 4 document.
  2. Mua hàng: mỗi dòng Products → một bút toán, quantity bên Dr.
  3. Bán hàng: mỗi dòng Products → một bút toán, quantity bên Cr.
  4. Trả hàng: như bán, amount và quantity mang dấu âm (không đảo Dr/Cr).
  5. Chuyển kho: cả hai bên là Goods, quantity cả Dr và Cr, Warehouse Dr = kho nhận, Warehouse Cr = kho gửi. Amount lấy theo giá vốn đã tính cho accumulation register.
  ```bsl
  // trong Posting, bên trong vòng lặp dòng hàng
  NewRecord = RegisterRecords.___.Add();
  NewRecord.Period    = ___;
  NewRecord.AccountDr = ___;   // predefined account
  NewRecord.AccountCr = ___;
  // Amount, QuantityDr/QuantityCr, ExtDimensionsDr[...] / ExtDimensionsCr[...]
  ___
  ```
- **Lỗi hay gặp:**
  - Ghi `Quantity` không postfix → lỗi, vì resource có accounting flag.
  - Trả hàng mà đảo Dr/Cr thay vì dấu âm → turnover bị phồng cả hai bên (đề yêu cầu số âm).
  - Dòng Services: dịch vụ không phải hàng tồn kho. [ghi chú ngoài nguồn] Demo của bài không tạo bút toán Cr Goods cho Services. Đề không nói rõ, hãy quyết định và ghi lý do.
  - Quên thêm register vào Register records → record không được ghi khi post.
- **Tự kiểm tra:** Post từng loại document, mở list accounting register: đúng cặp tài khoản, extra dimension, số lượng chỉ ở bên Goods. Unpost thì record biến mất.

### Bài tập 5 — Report Trial Balance

- **Đề bài (tóm tắt):** Report hiện số dư đầu kỳ, phát sinh trong kỳ, số dư cuối kỳ theo tài khoản, tách riêng Dr và Cr.
- **Gợi ý 1 — Hướng đi:** Xem mục "Report Trial balance": DCS với data set Query trên virtual table **BalanceAndTurnovers** của accounting register, có sẵn field tách Dr/Cr.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:** Report mới, main data composition schema. Query console nhánh AccountingRegisters. Parameter `Period` kiểu StandardPeriod. Grouping theo Account. Resources. Tab Other settings → Field header type = "Brief". Tab Data sets → xóa accounting roles của resource field.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo report, schema, data set Query, chọn field Account và 6 field amount opening/turnover/closing Dr/Cr.
  2. Gom field thành nhóm OpeningBalance / Turnover / ClosingBalance, khai báo resources.
  3. Tạo parameter Period, truyền ngày đầu/cuối vào virtual table.
  4. Settings: grouping Account, selected fields là các resource.
  5. Sửa header lặp và totals cuối kỳ như lý thuyết.
- **Lỗi hay gặp:**
  - Totals closing balance bằng 0 vì accounting roles tự gán → xóa roles.
  - Header cột lặp "Opening Balance.Dr" → Field header type = Brief.
  - Dùng field splitted balance trong query không có totals.
- **Tự kiểm tra:** Sau khi post mua rồi bán: tổng phát sinh Dr = tổng phát sinh Cr. Số dư cuối kỳ của 01 khớp hàng còn lại theo giá trị.

### Bài tập 6 — Document nhập bút toán tay, không posting, xử lý deletion mark

- **Đề bài (tóm tắt):** Document cho phép nhập bút toán tùy ý vào accounting register, không có thuộc tính posting. Khi đánh dấu xóa, record không ảnh hưởng totals nhưng vẫn được giữ để user sửa tiếp hoặc bỏ đánh dấu.
- **Gợi ý 1 — Hướng đi:** Xem mục "Document General journal entry". Document chỉ là recorder, tắt Posting. Record nhập trực tiếp trên form qua bảng register records. Khi deletion mark đổi, đổi **Activity** của record (Activity = False → không tính vào totals) thay vì xóa.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Document mới: Posting = Deny, là recorder của accounting register, đưa vào subsystem và functional option.
  - Form: bảng register records của document, ẩn cột Period.
  - Object module, event **BeforeWrite** (server): gán Period = ngày document cho mọi record. Phát hiện deletion mark thay đổi so với giá trị trong DB.
  - Khi đổi Activity: **không** dựa vào `RegisterRecords` (có thể rỗng khi đánh dấu từ list form). Tạo record set mới qua manager của register, filter theo recorder, đọc, đổi Active, ghi.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo document, tắt posting, thêm làm recorder.
  2. Tạo form, thêm bảng register records, gộp cột, ẩn Period.
  3. BeforeWrite: gán Period cho các record; gọi procedure đổi activity.
  4. Procedure đổi activity: thoát nếu object mới hoặc deletion mark không đổi; ngược lại đọc record set theo recorder và đổi Active.
  ```bsl
  Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
  	// gán Period = Date cho từng record; rồi gọi procedure xử lý Activity
  	___
  EndProcedure

  Procedure ___()
  	// thoát sớm: object mới, hoặc DeletionMark không đổi so với giá trị trong DB
  	___
  	// record set mới -> filter theo recorder -> Read -> đổi Active -> ghi đè
  	___
  EndProcedure
  ```
- **Lỗi hay gặp:**
  - Tắt posting nhưng tưởng record tự xóa khi đánh dấu xóa (không xóa: "Delete records" phụ thuộc posting).
  - Xóa record set khi đánh dấu xóa → bỏ đánh dấu thì document trống, trái yêu cầu.
  - Dùng `RegisterRecords` để đổi Active → không chạy khi đánh dấu từ list form.
  - So sánh deletion mark với chính nó thay vì với giá trị đã lưu (`Ref.<...>`).
- **Tự kiểm tra:** Nhập bút toán, lưu, xem Trial balance. Đánh dấu xóa từ **list form** → report không còn số đó, record vẫn còn (hình đen trắng trong list register). Bỏ đánh dấu → số trở lại.

## Code demo của bài Theory (repo 1CJDCourse, nhánh lesson/24-theory)

Nhánh lesson/24-theory là trạng thái cấu hình khi quay demo bài 24: so với cấu hình của bài 20 có thêm ChartsOfAccounts/ChartOfAccounts, AccountingRegisters/GeneralJournal, ChartsOfCharacteristicTypes/ExtraDimensionTypes, Documents/GeneralJournalEntry, Reports/TrialBalance và functional option UseAccounting. Mọi mẫu dưới đây lấy từ nhánh theory.

### Hiển thị tài khoản dạng "Code Description" (PresentationFieldsGetProcessing + PresentationGetProcessing)
Nguồn: nhánh lesson/24-theory — cf/ChartsOfAccounts/ChartOfAccounts/Ext/ManagerModule.bsl
```bsl
Procedure PresentationFieldsGetProcessing(Fields, StandardProcessing)
	
	StandardProcessing = False;
	
	Fields.Add("Code");
	Fields.Add("Description");
	Fields.Add("Ref");
	
EndProcedure

Procedure PresentationGetProcessing(Data, Presentation, StandardProcessing)
	
	StandardProcessing = False;
	Presentation = StrTemplate("%1 %2", Data.Code, Data.Description);
	
EndProcedure
```
- Cả hai handler đặt trong manager module của Chart of accounts, đều gán `StandardProcessing = False` để thuật toán riêng chạy.
- `PresentationFieldsGetProcessing` khai báo các field cần đọc ("Code", "Description", "Ref"); platform truyền đúng các field này vào parameter `Data` của `PresentationGetProcessing`, không phải đọc lại object theo reference.
- `StrTemplate("%1 %2", ...)` ghép code và description thành presentation user thấy trong document form và list form của register.

### Posting của PurchaseInvoice: bút toán Dr Products / Cr TradePayables
Nguồn: nhánh lesson/24-theory — cf/Documents/PurchaseInvoice/Ext/ObjectModule.bsl
```bsl
Procedure Posting(Cancel, PostingMode)
// ...
	GoodsInWarehouses = RegisterRecords.GoodsInWarehouses;
	GoodsInWarehouses.Write = True;
	
	GeneralJournal = RegisterRecords.GeneralJournal;
	GeneralJournal.Write = True;
	
	ExtraDimensionTypes = ChartsOfCharacteristicTypes.ExtraDimensionTypes;
	
	For Each ProductsRow In Products Do
	
		NewRecord = GoodsInWarehouses.AddReceipt();
		NewRecord.Period 	= Date;
		NewRecord.Warehouse = Warehouse;
		NewRecord.Product 	= ProductsRow.Product;
		NewRecord.Quantity 	= ProductsRow.Quantity;
		NewRecord.Amount 	= ProductsRow.Amount;
		
		NewRecord = GeneralJournal.Add();
		NewRecord.Period 	 = Date;
		NewRecord.AccountDr  = ChartsOfAccounts.ChartOfAccounts.Products;
		NewRecord.AccountCr  = ChartsOfAccounts.ChartOfAccounts.TradePayables;
		NewRecord.Amount 	 = ProductsRow.Amount;
		NewRecord.QuantityDr = ProductsRow.Quantity;
		NewRecord.ExtDimensionsDr[ExtraDimensionTypes.Product]   	= ProductsRow.Product;
		NewRecord.ExtDimensionsDr[ExtraDimensionTypes.Warehouse] 	= Warehouse;
		NewRecord.ExtDimensionsCr[ExtraDimensionTypes.Counterparty] = Vendor;
		
	EndDo;
	
EndProcedure
```
- Cùng một vòng lặp ghi cả record của accumulation register GoodsInWarehouses và record của accounting register GeneralJournal; cả hai record set đều bật `Write = True`.
- Resource Quantity có accounting flag Quantitative nên ghi với postfix: `QuantityDr` (tài khoản Products bên debit có theo dõi số lượng). Amount có flag Balance nên chỉ một property `Amount` cho cả hai bên.
- Extra dimensions gán qua `ExtDimensionsDr[...]` / `ExtDimensionsCr[...]` với key là predefined value của chart of characteristic types ExtraDimensionTypes; biến `ExtraDimensionTypes` chỉ để dòng code ngắn hơn.
- Tài khoản lấy từ predefined accounts: `ChartsOfAccounts.ChartOfAccounts.Products`, `ChartsOfAccounts.ChartOfAccounts.TradePayables`.

### Posting của SalesInvoice: bút toán Dr TradeReceivables / Cr Products
Nguồn: nhánh lesson/24-theory — cf/Documents/SalesInvoice/Ext/ObjectModule.bsl
```bsl
Procedure Posting(Cancel, PostingMode)

	RegisterRecords.GoodsInWarehouses.Write = True;
	RegisterRecords.Sales.Write = True;
	RegisterRecords.GeneralJournal.Write = True;

	ExtraDimensionTypes = ChartsOfCharacteristicTypes.ExtraDimensionTypes;
// ...
		NewRecord = RegisterRecords.GeneralJournal.Add();
		NewRecord.Period 	 = Date;
		NewRecord.AccountDr  = ChartsOfAccounts.ChartOfAccounts.TradeReceivables;
		NewRecord.AccountCr  = ChartsOfAccounts.ChartOfAccounts.Products;
		NewRecord.Amount 	 = CurRowProducts.Amount;
		NewRecord.QuantityCr = CurRowProducts.Quantity;
		NewRecord.ExtDimensionsDr[ExtraDimensionTypes.Counterparty] = Customer;
		NewRecord.ExtDimensionsCr[ExtraDimensionTypes.Product]   	= CurRowProducts.Product;
		NewRecord.ExtDimensionsCr[ExtraDimensionTypes.Warehouse] 	= Warehouse;
	EndDo;
// ...
EndProcedure
```
- Bên credit là tài khoản quantitative nên số lượng ghi vào `QuantityCr`; extra dimension Counterparty bên debit, Product và Warehouse bên credit.
- Trong demo, vòng lặp Services chỉ ghi register Sales, không tạo bút toán (dịch vụ không phải hàng tồn kho) — xem thêm thẻ gợi ý Bài tập 4.

### Posting của ReturnOfGoodsFromCustomer: bút toán đảo dấu
Nguồn: nhánh lesson/24-theory — cf/Documents/ReturnOfGoodsFromCustomer/Ext/ObjectModule.bsl
```bsl
		NewRecord = RegisterRecords.GeneralJournal.Add();
		NewRecord.Period 	 = Date;
		NewRecord.AccountDr  = ChartsOfAccounts.ChartOfAccounts.TradeReceivables;
		NewRecord.AccountCr  = ChartsOfAccounts.ChartOfAccounts.Products;
		NewRecord.Amount 	 = - CurRowProducts.Amount;
		NewRecord.QuantityCr = - CurRowProducts.Quantity;
		NewRecord.ExtDimensionsDr[ExtraDimensionTypes.Counterparty] = Customer;
		NewRecord.ExtDimensionsCr[ExtraDimensionTypes.Product]   	= CurRowProducts.Product;
		NewRecord.ExtDimensionsCr[ExtraDimensionTypes.Warehouse] 	= Warehouse;
	EndDo;
```
- Trả hàng dùng cùng cặp tài khoản với bán hàng nhưng Amount và QuantityCr âm (bút toán "đỏ"), thay vì đảo Dr/Cr.
- Nhờ vậy turnover của tài khoản trong report Trial balance giảm đúng chiều bán hàng, không làm phồng cả hai bên debit và credit.

### Document GeneralJournalEntry: điền Period và đổi Activity khi đặt deletion mark
Nguồn: nhánh lesson/24-theory — cf/Documents/GeneralJournalEntry/Ext/ObjectModule.bsl
```bsl
Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	
	For Each Record In RegisterRecords.GeneralJournal Do
		Record.Period = Date;
	EndDo;
	
	ChangeRecordsActivity();
	
EndProcedure

Procedure ChangeRecordsActivity()

	If IsNew() Or DeletionMark = Ref.DeletionMark Then
		Return;
	EndIf;
	
	GeneralJournalRecords = AccountingRegisters.GeneralJournal.CreateRecordSet();
	
	GeneralJournalRecords.Filter.Recorder.Set(Ref);
	GeneralJournalRecords.Read();
	
	For Each Record In GeneralJournalRecords Do
		Record.Active = Not DeletionMark;
	EndDo;
	
	GeneralJournalRecords.Write(True);
	
EndProcedure
```
- Document tắt Posting nên dùng `BeforeWrite`: gán `Record.Period = Date` cho mọi record trong `RegisterRecords.GeneralJournal` (cột Period đã ẩn trên form).
- `ChangeRecordsActivity` thoát sớm nếu document mới hoặc deletion mark không đổi (`DeletionMark = Ref.DeletionMark` so giá trị trong object với giá trị đang lưu trong DB).
- Không dùng `RegisterRecords` vì khi đặt deletion mark từ list form record set này có thể rỗng: tạo record set mới bằng `AccountingRegisters.GeneralJournal.CreateRecordSet()`, đặt `Filter.Recorder` rồi `Read()`.
- `Record.Active = Not DeletionMark` loại record khỏi totals khi document bị đánh dấu xóa; `Write(True)` ghi đè record set.

### Query của report TrialBalance (virtual table BalanceAndTurnovers)
Nguồn: nhánh lesson/24-theory — cf/Reports/TrialBalance/Templates/MainDataCompositionSchema/Ext/Template.xml
```xml
		<query>SELECT
	GeneralJournalBalanceAndTurnovers.Account AS Account,
	GeneralJournalBalanceAndTurnovers.AmountOpeningBalanceDr AS AmountOpeningBalanceDr,
	GeneralJournalBalanceAndTurnovers.AmountOpeningBalanceCr AS AmountOpeningBalanceCr,
	GeneralJournalBalanceAndTurnovers.AmountTurnoverDr AS AmountTurnoverDr,
	GeneralJournalBalanceAndTurnovers.AmountTurnoverCr AS AmountTurnoverCr,
	GeneralJournalBalanceAndTurnovers.AmountClosingBalanceDr AS AmountClosingBalanceDr,
	GeneralJournalBalanceAndTurnovers.AmountClosingBalanceCr AS AmountClosingBalanceCr
FROM
	AccountingRegister.GeneralJournal.BalanceAndTurnovers AS GeneralJournalBalanceAndTurnovers</query>
```
- Text query nằm trong main data composition schema; chọn từ virtual table `AccountingRegister.GeneralJournal.BalanceAndTurnovers`, có sẵn các field tách Dr/Cr cho opening balance, turnover, closing balance.
- Schema còn khai báo parameter Period (cùng BeginOfPeriod/EndOfPeriod) để truyền khoảng thời gian vào virtual table.

### Functional option UseAccounting
Nguồn: nhánh lesson/24-theory — cf/FunctionalOptions/UseAccounting.xml
```xml
			<Content>
				<xr:Object>ChartOfAccounts.ChartOfAccounts</xr:Object>
				<xr:Object>AccountingRegister.GeneralJournal</xr:Object>
				<xr:Object>ChartOfCharacteristicTypes.ExtraDimensionTypes</xr:Object>
				<xr:Object>Subsystem.Accounting</xr:Object>
				<xr:Object>Document.GeneralJournalEntry</xr:Object>
			</Content>
```
- Content gồm chart of accounts, accounting register, ExtraDimensionTypes, subsystem Accounting và document GeneralJournalEntry — cùng cơ chế functional option lưu ở Boolean constant (xem thẻ gợi ý Bài tập 2).

## Video tham khảo

Video bài giảng trên YouTube có phạm vi trùng với bài này. Khi dẫn cho người học, nói "Bạn có thể tham khảo thêm về <chủ đề> của khóa tại đây: [<tên video>](link)" — không nói "khóa cũ/Junior", không dùng mã JC (mã JC trong danh sách chỉ để tra nội bộ). Quy ước đầy đủ: `references/video.md#video-junior-course`.

- [Dữ liệu xác định trước](https://www.youtube.com/watch?v=EQLuZq69Nmw&list=PLp-gQ5Mgw0Zyp6VM4w9hZZQBtYrBpP5_P&index=20) (8:02) — Bài 4 — Predefined data; Bài 13 / 24 — predefined của Chart of characteristic types, Chart of accounts _(mã nội bộ JC-21)_


---

# § bai-extensions

# Bài Extensions — Configuration extensions (Mở rộng cấu hình)

## Khái niệm chính

### Giới thiệu
- **Configuration extension mechanism**: cơ chế mở rộng configuration **mà không thay đổi nó** (và không cần gỡ khỏi support). Extension là "add-on" kết nối vào main configuration và chạy bên trên nó.
- Đơn giản hóa:
  - **Configuration updates**: configuration không bị gỡ khỏi vendor support → cập nhật tự động, không phải so sánh object đã sửa với version mới.
  - **Bug fixes**: sửa lỗi trong extension và bật trong infobase, không cần phát hành full release và cập nhật tốn thời gian.
  - Tạo chức năng/subsystem mới phân phối cho nhiều infobase hoặc nhiều khách hàng.
- Configuration được áp extension gọi là **extended configuration**. Extension cho phép:
  - Tạo object mới.
  - Sửa object có sẵn: thêm subordinate objects (attributes, tabular sections, commands, templates); thay đổi object forms.
  - Sửa (thêm/thay thế) procedures và functions, kể cả event handlers.
- Để sửa object có sẵn phải thêm nó vào extension — gọi là **adopted** objects.

### Làm việc với extension
- Mở danh sách: menu **Configuration - Configuration extensions**. Có thể thêm, sửa, xóa, đặt active/inactive.
- Extension **inactive** vẫn có thể ảnh hưởng cấu trúc bảng DB nhưng đang bị tắt (không ảnh hưởng hành vi của configuration).
- Khi tạo extension phải chỉ định **name, synonym, prefix, purpose**.
- **Prefix** tự thêm vào metadata object mới tạo trong extension và event handler tạo trong adopted forms. Ví dụ prefix "crm_" → catalog mới tên **crm_Catalog1**.
- Double-click extension trong danh sách → mở cây configuration của extension; object duy nhất ban đầu là role tự tạo, dùng làm default role của extension.
- Prefix đổi được trong quá trình làm việc, nhưng object đã tạo giữ prefix cũ — trừ role tự tạo được gán vào property **"Default roles"** của extension. Tên role mặc định theo quy tắc **<prefix>+"DefaultRole"**; khi đổi prefix platform gợi ý đổi tên theo quy tắc với prefix mới.
- Số extension trên một infobase không giới hạn. **Thứ tự thực thi** phụ thuộc **purpose** và **thứ tự thêm vào infobase** (xem trong danh sách extension). Ví dụ: extension "Patch" đứng đầu; extension "AddOn" đứng cuối; extension "Customization" thêm sau "CRMImprovement" (cùng purpose) đứng sau nó.

### Property Purpose
- **Patch**: sửa lỗi ứng dụng. Được dự kiến dùng các tính năng "nguy hiểm" tiềm ẩn (ví dụ method extension với annotation **Around**). Dành cho một version ứng dụng cụ thể; khi có version mới tác giả phải phân tích khả năng áp dụng. Cho phép nhiều extension Patch nhưng phải đảm bảo không xung đột (ví dụ nhiều extension không được mở rộng cùng một method với mục đích khác nhau). Không cần xét extension có purpose khác.
- **Customization**: điều chỉnh ứng dụng theo yêu cầu khách hàng cụ thể. Khuyến nghị không dùng tính năng "nguy hiểm" (có thể gây xung đột khi chạy cùng nhau hoặc phụ thuộc thứ tự kết nối). Được dùng cẩn thận nếu tác giả chịu hoàn toàn trách nhiệm về hoạt động đúng trong version mới, có xét các extension Patch. Giả định mỗi thời điểm có số lượng tối thiểu extension loại này; nếu không gộp được vào một extension thì chia thành các khối lớn nhất của ứng dụng.
- **Add-on**: tính năng mới ít gắn với version ứng dụng (ví dụ bộ report mới). Phải chạy đúng khi ứng dụng được cập nhật; không được xét sự hiện diện của extension purpose khác. Số lượng tùy ý.

### Extension "Patch" — ví dụ
- Document PurchaseOrder mới trong SSL demo, tabular section Products (Product, Quantity, Price, Amount). Handler OnChange của cột Amount tính lại Price = Amount/Quantity, cố ý không kiểm tra Quantity = 0 → lỗi chia cho 0.
- Tạo extension purpose "Patch". Đặt tên patch theo số task trong hệ thống quản lý task (ví dụ "Bigfix123") thay vì tên dài như "OrderToSupplierDivideByZeroFix"; nói chung nên đặt tên theo chức năng.
- Mở rộng procedure **CalculatePriceAtRow**: đặt con trỏ trong procedure/khai báo → chuột phải → **"Add to Extension"**. Nhiều extension → platform hỏi chọn extension. Sau đó chọn **call type**:
  - Call before...
  - Call after...
  - Call instead of...
  - Call instead (with control)...
- **"Before"**: method extension chạy trước, rồi đến method configuration.
- **"After"**: method configuration chạy trước, rồi đến method extension.
- **"Instead of"**: method configuration không chạy, bị thay hoàn toàn. Thường dùng trong extension "Patch". Vẫn có thể gọi thuật toán chuẩn bằng method đặc biệt **ProceedWithCall()**; method "Instead" tạo ra đã chứa lời gọi ProceedWithCall() (có thể xóa).
- **"Instead (with control)"**: sửa có mục tiêu một hoặc vài phần của method, phần còn lại chạy theo thuật toán chuẩn.

### &Around annotation
- Chọn "Instead of" → document form và document tự động được thêm vào extension. **Note**: không thêm subordinate metadata objects (attributes, tabular sections...).
- Xóa ProceedWithCall() và viết thuật toán tính giá mới xét Quantity = 0.
- Procedure được khai báo với annotation **"Around"** và tên có prefix tự thêm.

### Extension "Customization" — ví dụ
- Yêu cầu: cột Discount (%) và AmountAfterDiscount = `Amount - Amount * Discount / 100` (ví dụ 150 - 150 * 10 / 100 = 135); tính lại khi Amount hoặc Discount thay đổi.
- Tạo extension "Customization" tên CRMImprovement. Thêm form PurchaseOrder → hiện cửa sổ chọn extension (vì có 2 extension).
- **Information**: để khỏi chọn extension mỗi lần, đóng mọi cửa sổ cây configuration của các extension trừ extension đang cần.
- Thêm tabular section Products vào extension → chỉ tabular section được thêm, attributes của nó không. Tạo 2 attribute riêng.
- Đặt synonym có ý nghĩa (ví dụ "Discount", không để user thấy prefix).
- crm_AmountAfterDiscount cần kiểu như Amount — **DefinedType.MonetaryAmountNonNegative** — chưa có trong extension. Có thể thêm trực tiếp, hoặc thêm attribute dùng kiểu đó (ví dụ attribute Amount) → defined type tự được adopt **by reference**. Không nên thêm object không cần.
- Adopted form: mặc định làm việc được với form **elements**, nhưng không làm việc được với form **attributes, commands, form parameters** (chữ xám, flag tắt, properties không sửa được). Attribute adopted có icon **mảnh ghép (puzzle)**, chưa adopted có icon **hình tròn**. Để truy cập attribute mới của tabular section → thêm main form attribute **Object** vào extension.
- Khi adopt main form attribute, mọi object được tham chiếu cũng được adopt (có ngoại lệ hiếm — xem tài liệu platform).
- Tạo event handler cho field gắn với property tạo trong extension, platform vẫn hỏi chọn "Before", "After", "Instead" — trường hợp này không quan trọng, có thể luôn chọn mặc định "After".
- Handler OnChange của Amount đã được mở rộng trong extension Patch → **không nên** dùng "Instead" ("Around") trong extension mới; không cần chạy trước → chọn **"After"**.
- Khi mở rộng handler từ main configuration, platform hỏi mở rộng **event handler** (khuyến nghị) hay **method**. Nếu chỉ mở rộng procedure mà không mở rộng event handler, khi event handler trong main configuration bị xóa thì procedure mở rộng không được gọi nữa. Mở rộng event handler tương đương tạo handler từ form của extension và hoạt động bất kể main configuration có handler cho event đó hay không.
- Kết quả: khi OnChange của Amount xảy ra, handler của extension "Patch" chạy trước (thay handler lỗi), sau đó handler của extension "Customization".

### &ChangeAndValidate annotation
- Thuộc call type "Instead (with control)". Dùng khi cần sửa một phần thuật toán chuẩn mà không dùng được "Before"/"After" (ví dụ sửa giữa method), còn "Around" không mong muốn vì nếu code method thay đổi khi cập nhật configuration thì thuật toán mới sẽ không chạy (Around ghi đè hoàn toàn).
- Method với "ChangeAndValidate" cho phép xóa/thêm dòng có chọn lọc; nếu phát hiện khác biệt giữa code đã lưu trong extension và code trong main configuration, method sẽ **ngừng mở rộng** method gốc (extension ngừng áp dụng cho method đó nhưng vẫn hoạt động ở các phần khác).
- Ví dụ: print form "Purchase order" hiển thị AmountAfterDiscount thay Amount, giữ nguyên header cột.
- **Lưu ý**: annotation "Before" và "After" **không khả dụng cho functions**.
- Method mở rộng với ChangeAndValidate được adopt **toàn bộ code**.
- Preprocessor directives: **#Delete / #EndDelete** để xóa dòng; **#Insert / #EndInsert** để chèn code. Thứ tự không quan trọng, miễn mọi code ngoài các directive giữ nguyên như method adopted.
- **Information**: query có text sửa bằng các preprocessor directive không mở được bằng query builder.
- Lỗi khi mở list PurchaseOrder: extension chạy ở **safe mode**, mặc định chỉ cho phép mở rộng client-side và server-side form handlers. Mở rộng method trong object manager module → extension không qua security check. Giải pháp: tắt flag **safe mode** và khởi động lại ứng dụng.

### &Around annotation cho functions
- Dùng "Around" và ProceedWithCall() thay cho "Before"/"After" (không khả dụng cho functions).
- Ví dụ: function trả turnover counterparty theo kỳ; nếu không truyền begin/end date thì chỉ lấy dữ liệu năm gần nhất (function đã điền EndDate rỗng bằng ngày hiện tại nhưng không kiểm tra BeginDate → lấy toàn bộ kỳ, chạy lâu).
- **Giá trị mặc định của parameter không được chuyển sang extension.**
- ProceedWithCall() gọi function gốc và trả kết quả. Code sau ProceedWithCall() và trước khi trả Result (có thể thay bằng giá trị riêng) ≈ "After". Code trước khi gọi function gốc (có thể không gọi nếu không cần) ≈ "Before".
- Đổi BeginDate, EndDate không ảnh hưởng code bên ngoài vì parameter khai báo với từ khóa **"Val"**.
- Emulate "After": biến Result chứa giá trị function gốc trả về; sửa rồi mới return (ví dụ thêm/bớt phần tử array).

### Lưu và load extension từ file
- Làm việc với extension như với configuration: lưu ra file, load từ file, so sánh và merge, syntax check...
- Không cần vào Designer để kết nối/cập nhật extension — làm được từ **Enterprise mode**: user có quyền quản trị phía client có thể tự load extension, thêm/cập nhật từ file, xóa, lưu ra file, quản lý properties như **Activity (Active)**.

### Lưu dữ liệu thêm trong extension vào bảng DB
- Adopt một catalog (ví dụ "Counterparties") **không** ảnh hưởng cấu trúc DB.
- **Note**: khi chưa có extension nào ảnh hưởng cấu trúc lưu trữ của metadata object, dữ liệu lưu trong bảng ban đầu.
- Thêm attribute mới (ví dụ "IsCustomer" Boolean) → lần cập nhật sau platform cảnh báo cần **restructure DB**: tạo bảng mới cho catalog có cột mới, chuyển mọi dữ liệu từ bảng gốc sang. Bảng gốc vẫn còn nhưng không còn record.
- Dù bao nhiêu extension khác sửa cấu trúc catalog, dữ liệu vẫn lưu trong cùng bảng mới miễn còn ít nhất một extension sửa cấu trúc object (thêm/sửa attribute hoặc tabular section).
- Nếu không còn extension nào ảnh hưởng cấu trúc (bị xóa, hoặc attributes/tabular sections bị xóa khỏi extension) → sau lần restructure tiếp, dữ liệu chuyển về bảng gốc; dữ liệu của attributes/tabular sections chỉ có trong extension **mất vĩnh viễn**.
- Extension **inactive** vẫn ảnh hưởng cấu trúc bảng nhưng metadata objects và code không được dùng; tắt activity không ảnh hưởng dữ liệu đã lưu, chỉ không đọc từ bảng tương ứng — field của extension bị tắt không truy cập được trong query.

### Forms extension
- Adopt form = adopt version hiện tại. Form trong main configuration thay đổi → extension hiện cảnh báo đề nghị cập nhật form từ configuration.
- Không bắt buộc cập nhật mỗi lần, nhưng có thể ảnh hưởng usability. Thêm/xóa/di chuyển element trong extension rồi trong main configuration có thể làm vị trí element khác thay đổi dù không ai sửa trực tiếp (ví dụ form _DemoGoodsSales: di chuyển "Storage location" sang tab "Additional" trong extension, rồi trong main configuration sang tab "Proforma invoices" → sau cập nhật field "Currency" bị chuyển sang tab "Proforma invoices").
- Cập nhật bằng nút nền vàng tốn thời gian khi nhiều form/nhiều DB, và còn phải kiểm tra sau cập nhật.
- **Khuyến nghị: thay đổi thành phần form attributes, commands và giao diện (elements) bằng code**. Hai lý do: sửa song song element ở main configuration và extension; sửa đồng thời form trong nhiều extension.

### Tạo form element bằng code
- Ví dụ attribute crm_Amount trong tabular section Products của _DemoGoodsSales; handler **OnCreateOnServer** với call type "After".
- Method **Add()** của object **Items** trả về item tạo ra. Property chính: **"DataPath"** (form/object attribute liên kết) và **"Type"** (loại field/element).
- Đường dẫn attribute tabular section: `<TabularSectionName.AttributeName>`; nếu là tabular section của object (không phải bảng form attribute) thêm "Object": `<Object.TabularSectionName.AttributeName>`.
- **Insert()**: thêm parameter là element mà item mới chèn **trước** nó (ví dụ để field đứng sau cột Price).
- Gán event bằng code: method **SetAction()** của form item — chỉ định tên action và tên handler procedure; áp dụng cho cả item tạo bằng code lẫn tạo trong form designer. Phải giữ đúng tập và thứ tự parameter của handler (có thể tạo handler cho field có sẵn để xem parameter, rồi xóa handler thừa).

### Tạo form attribute và command bằng code
- Ví dụ: field "Percentage" (form attribute, không lưu DB) và nút "Change prices by percentage" tăng giá mọi dòng theo phần trăm.
- Form attribute: method **ChangeAttributes()** của form, 2 parameter tùy chọn **AttributesToBeAdded** và **AttributesToBeDeleted** (Array of **FormAttribute**, phải tạo trước). Đây là thao tác tốn tài nguyên → gọi càng ít càng tốt, thực hiện mọi thay đổi một lần.
- Kiểu form attribute: object **TypeDescription** với qualifiers cho number (total length, độ dài phần thập phân, allowed sign — any hoặc non-negative). Thêm FormAttribute vào array mới, truyền vào ChangeAttributes().
- Gọi procedure (AddOwnAttributesAndCommands()) trong OnCreateAtServer, rồi tạo field Percentage. Đặt field trong group mới → phải tạo group trước.
- DataPath của field gắn form attribute: ghi trực tiếp tên attribute, **không** có "Object".
- Tắt title group bằng property **"ShowTitle"** để tránh indent thừa.
- Command thêm từ manager **"Commands"** của form. Property chính:
  - **"Action"** — tên handler procedure (procedure có một parameter, Command).
  - **"ModifiesStoredData"** — flag nhấn nút làm thay đổi stored data → form được đánh dấu modified để platform hỏi xác nhận khi đóng form.
- Handler: kiểm tra Percentage đã điền; nếu có, duyệt mọi dòng tabular section và tăng Price; nếu không, thông báo user.
- Truy cập trực tiếp attribute tạo bằng code theo tên → lỗi **"Variable not defined"**. Giải pháp: truy cập qua property của **ThisObject** — `ThisObject.MyProperty` hoặc `ThisObject["MyProperty"]`.
- **Information**: attributes và tabular sections tạo bằng code không có trong context help (khi tham chiếu bằng dấu chấm). Khuyến nghị tham chiếu theo tên trong ngoặc vuông để cho người khác biết attribute có thể được tạo bằng code.
- Nút gắn command: chỉ định tên command ở property **CommandName**; title lấy từ command.

### Operations with adopted objects
- Adopted object chỉ chứa properties có thể đặt **controlled**, **checked** hoặc **modifiable**:
  - **Controlled property**: không khớp giữa extension và extended configuration → **không thể áp dụng** extension. Ví dụ với catalog _DemoCounterparties: "Extended configuration object", "Hierarchical", "Code Type", "Allowed code length".
  - **Property to check**: không khớp → **cảnh báo**, không ngăn áp dụng. Ví dụ: "Code length", "Description length".
  - **Property to modify**: ví dụ "Object module".
- Property modifiable trong object kết quả: lấy từ extension (với property chỉ một giá trị, như "Main form") hoặc kết hợp main configuration và extensions (property bổ sung được, như "Object module"). Nhiều extension → lấy giá trị từ extension **đứng cuối** danh sách.
- Property modifiable không chỉ định giá trị → hành vi như configuration thường với giá trị trống (ví dụ Main report form modifiable mà không chỉ form → form tự sinh).
- Property **Name** luôn là controlled. Đổi tên object trong extended configuration (ví dụ _DemoCounterparties → Counterparties) → extension ngừng hoạt động cho đến khi đặt cùng tên cho adopted object.
- Property extension **"Support mapping to extended configuration objects by internal IDs"**: theo dõi tương ứng theo internal ID của loại object; tự bật cho extension mới. Khi bật, property **Extended configuration object** (controlled) được điền cho mỗi adopted object (kể cả subordinate).
- Trong Designer có thể **check extension applicability**; hệ thống đưa phương án (áp dụng cho nhiều dòng):
  - **Rename and save match** — đặt tên object theo object trong extended configuration có internal ID đã lưu (nếu tồn tại và cùng metadata type).
  - **Save name and change match** — đặt internal ID của object cùng tên vào Extended configuration object.
  - **Select match** — đặt internal ID của object chọn thủ công.
  - **Disable check** — tắt property Extended configuration object.
  - **Clear match** — đặt giá trị nội bộ; property không được cập nhật khi lưu extension.
  - **Set value from configuration object** — đặt giá trị property từ extended object.
  - **Delete object** — xóa object khỏi extension.
- Nên đọc tài liệu đúng version platform vì cơ chế extension thay đổi thường xuyên: [Configuration_extensions](https://kb.1ci.com/1C_Enterprise_Platform/Guides/Developer_Guides/1C_Enterprise_8.3.25_Developer_Guide/Chapter_30._Configuration_extension/)

### Tóm tắt annotations / call types (theo tài liệu)
| Call type (Designer) | Annotation trong tài liệu | Ghi chú |
| --- | --- | --- |
| Call before... | "Before" | Extension chạy trước; không có cho functions |
| Call after... | "After" | Configuration chạy trước; không có cho functions |
| Call instead of... | &Around | Thay hoàn toàn; ProceedWithCall() để gọi gốc |
| Call instead (with control)... | &ChangeAndValidate | #Delete/#EndDelete, #Insert/#EndInsert |

[ghi chú ngoài nguồn] Tài liệu chỉ viết dạng "&Around" và "&ChangeAndValidate" trong tiêu đề; "Before"/"After" được nhắc như tên annotation trong ngoặc kép, không có dạng "&Before"/"&After"/"&Instead" trong văn bản tài liệu.

## Cú pháp & ví dụ code

Công thức amount after discount:
```bsl
Amount - Amount * Discount / 100

150 - 150 * 10 / 100 = 150 - 15 = 135
```

Gọi thuật toán gốc từ method extension:
```bsl
ProceedWithCall()
```

Preprocessor directives cho &ChangeAndValidate:
```bsl
#Delete

#EndDelete

#Insert

#EndInsert
```

Đường dẫn DataPath:
```bsl
<TabularSectionName.AttributeName>
<Object.TabularSectionName.AttributeName>
```

Truy cập attribute tạo bằng code:
```bsl
ThisObject.MyProperty
ThisObject["MyProperty"]
```

[ghi chú ngoài nguồn] Trong tài liệu gốc, code là ảnh chụp màn hình. Code thật của CalculatePriceAtRow (&Around) và handler Discount (After) có ở mục "Code demo của bài Theory" cuối file (lấy từ file .cfe); function print form với #Delete/#Insert, function turnover với ProceedWithCall() và các ví dụ Items.Insert()/SetAction()/ChangeAttributes()/Commands vẫn chưa có code dạng văn bản.

## Thuộc tính/thiết lập quan trọng trong Designer
- Menu **Configuration - Configuration extensions**; thuộc tính extension: **Name, Synonym, Prefix, Purpose** (Patch / Customization / Add-on), **Default roles**, **Safe mode**, **Active**, **Support mapping to extended configuration objects by internal IDs**.
- Context menu **"Add to Extension"**; call type: Call before / Call after / Call instead of / Call instead (with control).
- Adopted object properties: Controlled / Property to check / Property to modify; **Extended configuration object**; **Name** (luôn controlled).
- Form item: **DataPath**, **Type**, **ShowTitle**, **CommandName**; command: **Action**, **ModifiesStoredData**.
- Methods: **Items.Add()**, **Items.Insert()**, **SetAction()**, **ChangeAttributes()** (AttributesToBeAdded, AttributesToBeDeleted), **FormAttribute**, **TypeDescription**.

## Lỗi thường gặp / lưu ý
- Lỗi chia cho 0 khi không kiểm tra Quantity = 0 (ví dụ minh họa cho Patch).
- Nhiều extension Patch không được mở rộng cùng method với mục đích khác nhau.
- Không dùng "Around" trong Customization khi method đã được Patch mở rộng → dùng "After".
- Chỉ mở rộng method mà không mở rộng event handler → có thể ngừng được gọi khi handler gốc bị xóa.
- Adopt tabular section không adopt attributes của nó; adopt form không cho làm việc với attributes/commands/parameters cho đến khi adopt (ví dụ main attribute Object).
- "Before"/"After" không có cho functions → dùng "Around" + ProceedWithCall().
- Giá trị mặc định của parameter không chuyển sang extension.
- ChangeAndValidate: code gốc thay đổi → method ngừng được mở rộng. Query sửa bằng directive không mở được bằng query builder.
- Safe mode chỉ cho phép mở rộng form handlers; mở rộng manager module → phải tắt safe mode.
- Xóa mọi extension sửa cấu trúc object → dữ liệu attributes chỉ có trong extension mất vĩnh viễn sau restructure.
- Sửa form element trực quan trong extension → có thể sai vị trí sau khi cập nhật form; nên sửa bằng code.
- Truy cập trực tiếp attribute tạo bằng code → "Variable not defined"; dùng ThisObject["..."].
- ChangeAttributes() tốn tài nguyên → gọi một lần.
- Đổi tên object trong configuration (Name là controlled) → extension ngừng hoạt động; dùng applicability check.

## Điểm cần nhớ
- Extension mở rộng configuration mà không sửa và không gỡ khỏi support; object cần sửa phải được adopt.
- Ba purpose: **Patch** (sửa lỗi, cho phép tính năng "nguy hiểm"), **Customization** (theo khách hàng, hạn chế tính năng nguy hiểm), **Add-on** (tính năng mới độc lập version); thứ tự thực thi theo purpose rồi thứ tự thêm.
- Call types: Before, After, Instead of (**&Around** + ProceedWithCall()), Instead with control (**&ChangeAndValidate** + #Delete/#Insert).
- Before/After không có cho functions; emulate bằng &Around.
- Safe mode của extension chỉ cho phép mở rộng form handlers.
- Thêm attribute trong extension → restructure DB sang bảng mới; extension inactive vẫn ảnh hưởng cấu trúc.
- Sửa form trong extension nên làm bằng code: Items.Add()/Insert(), SetAction(), ChangeAttributes(), Commands.
- Adopted properties: Controlled (chặn áp dụng), Check (cảnh báo), Modify; Name luôn controlled; dùng mapping theo internal IDs.

## Code demo của bài Theory (file .cfe của giảng viên)

Đây là code thật của các demo **lý thuyết** (không phải lời giải bài thực hành), dùng để minh họa khi giải thích.

Ba extension dưới đây là file thật khi quay demo Theory, làm trên document **`PurchaseInvoice`** (tabular section **`Goods`**: Product, Quantity, Price, Amount) trong infobase SSL (Demo).

> [ghi chú ngoài nguồn] Văn bản Theory gọi document là **PurchaseOrder**, tabular section **Products**, tên patch "BigFix123" và extension "CRMImprovement"; file thực tế là `PurchaseInvoice`/`Goods`, `Bugfix123`, `CRMImprovemnet` (sai chính tả trong tên extension). Khi trích dẫn cho người học, dùng tên trong file và nói rõ sự khác biệt này.

| Extension | Purpose | Prefix | Adopted objects |
|---|---|---|---|
| `Bugfix123` | Patch | `bf123_` | `PurchaseInvoice`, form `DocumentForm` |
| `CRMImprovemnet` | Customization | `crm_` | `PurchaseInvoice` (tabular section `Goods` + attribute mới `crm_Discount` synonym "Discount", `crm_AmountAfterDiscount` synonym "Amount after discount", kiểu DefinedType `MonetaryAmountNonNegative`), form `DocumentForm`, `_DemoCounterparties`, `_DemoCounterpartiesContracts`, `_DemoProducts` |
| `TestExtension` | Patch | `Test_` | `PurchaseInvoice`, form `DocumentForm` |

#### Extension "Patch" — &Around cho CalculatePriceAtRow (Bugfix123)
Nguồn: `Bugfix123.cfe` — Documents/PurchaseInvoice/Forms/DocumentForm (form module)
```bsl
&AtClient
&Around("CalculatePriceAtRow")
Procedure bf123_CalculatePriceAtRow(GoodsRow)
	
	If GoodsRow.Count <> 0 Then 
		GoodsRow.Price = GoodsRow.Amount / GoodsRow.Quantity;
	Else
		 GoodsRow.Price = 0; 	
	EndIf;
	
EndProcedure
```

- [ghi chú ngoài nguồn] Điều kiện kiểm tra `GoodsRow.Count` nhưng phép chia dùng `GoodsRow.Quantity`. Tabular section `Goods` của PurchaseInvoice (phần adopted trong các extension) có `Quantity`, không có `Count` → điều kiện phải là `GoodsRow.Quantity <> 0` như Theory mô tả ("tính đến trường hợp số lượng bằng 0"). Nói rõ với người học, đừng chép lại lỗi.
- Không gọi `ProceedWithCall()` — thuật toán gốc bị thay hoàn toàn (đúng ý Theory: lỗi nằm trong method gốc).

#### Extension "Customization" — cột Discount (CRMImprovemnet)
Nguồn: `CRMImprovemnet.cfe` — Documents/PurchaseInvoice/Forms/DocumentForm (form module)
```bsl
&AtClient
Procedure crm_Goodscrm_DiscountOnChangeAfter(Item)
	
	CalculateAmountWithDiscount(Items.Goods.CurrentData);
	
EndProcedure

&AtClient
Procedure CalculateAmountWithDiscount(GoodsRow)
	
    GoodsRow.crm_AmountAfterDiscount = GoodsRow.Amount - GoodsRow.Amount * GoodsRow.Discount / 100;
	
EndProcedure
```

- Handler OnChange của cột Discount (field `Goodscrm_Discount`) có call type **After** → tên `crm_Goodscrm_DiscountOnChangeAfter`. Procedure tính toán `CalculateAmountWithDiscount` là procedure mới của extension (không có prefix vì người làm tự đặt tên).
- [ghi chú ngoài nguồn] Form của extension có gán handler `crm_GoodsAmountOnChangeAfter` (After) cho cột **Amount** như Theory mô tả, nhưng module **không có** procedure này — trong file chỉ có handler của cột Discount. Muốn số tiền sau chiết khấu cập nhật khi Amount đổi thì cần thêm procedure đó (gọi `CalculateAmountWithDiscount(Items.Goods.CurrentData)`).
- [ghi chú ngoài nguồn] Công thức đọc `GoodsRow.Discount`, nhưng attribute mới tên `crm_Discount` (synonym "Discount") → cần kiểm tra lại trên infobase; theo tên attribute trong extension, đúng phải là `GoodsRow.crm_Discount`.

#### TestExtension
Nguồn: `TestExtension.cfe` — Documents/PurchaseInvoice/Forms/DocumentForm
- Purpose Patch; form gán handler `Test_GoodsAmountOnChangeAround` (call type **Instead**) cho cột Amount nhưng **module form rỗng** — extension thử nghiệm, không xuất hiện trong văn bản Theory. Dùng làm ví dụ "handler đã gán mà chưa viết procedure" khi giải thích lỗi.

#### Phần Theory chưa có code dạng văn bản
- `&ChangeAndValidate` cho print form "Purchase order", `&Around` cho function turnover + `ProceedWithCall()`, ví dụ `crm_Amount` trên `_DemoGoodsSales` với `Items.Insert()`/`SetAction()`/`ChangeAttributes()`/`Commands`: chỉ có trong ảnh chụp tài liệu, không có trong 3 file `.cfe`.

## Thẻ gợi ý bài thực hành (Extensions practice)

Các thẻ dưới đây đi theo thứ tự đề trong Extensions practice, làm trên infobase SSL (Demo). Mỗi thẻ chỉ có gợi ý, không có lời giải. Nguyên tắc chung: không sửa main configuration (trừ bước cố ý tạo lỗi ở bài 1). Mọi thay đổi nằm trong extension.

### Bài tập 1 — Extension "Patch" sửa lỗi lời gọi SetMainProject

- **Đề bài (tóm tắt):** Gỡ support cho command MakeDefault của catalog `_DemoProjects`. Trong procedure `SetMainProject` của command module, xóa tham số Project khỏi lời gọi `Catalogs._DemoProjects.SetMainProject(...)` để tạo lỗi. Thử command trên list form (chọn dòng, trả lời "Yes") để thấy lỗi. Sau đó sửa lỗi bằng extension mới với purpose "Patch".
- **Gợi ý 1 — Hướng đi:** Xem "Extension Patch — ví dụ" và "&Around annotation". Muốn thay hoàn toàn một procedure bị lỗi thì dùng "Call instead of..." (annotation Around): method gốc không chạy nữa, method trong extension chạy thay.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Main configuration: Support options của command module `Catalog._DemoProjects.Command.MakeDefault` (cho phép sửa), sửa lời gọi trong procedure `&AtServer SetMainProject(Project)`.
  - Extension mới: Purpose = Patch, đặt prefix và tên ngắn theo số task (ví dụ kiểu "Bugfix…").
  - Trong command module: chuột phải trong procedure `SetMainProject` → "Add to Extension" → "Call instead of...". Procedure mới có annotation Around và tên có prefix.
  - Giữ đúng directive `&AtServer` như procedure gốc.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo lỗi trong main configuration, update DB, tái hiện lỗi trong Enterprise.
  2. Tạo extension Patch, mở cây extension.
  3. Add to Extension procedure `SetMainProject` với call type "Instead of".
  4. Trong method mới: bỏ lời gọi `ProceedWithCall()` (gọi lại code lỗi), viết lời gọi đúng tới manager module.
  5. Update extension, test lại.
  ```bsl
  &AtServer
  &Around("SetMainProject")
  Procedure ___SetMainProject(Project)
  	// không gọi ProceedWithCall() — thay bằng lời gọi đúng tới manager module, truyền đủ tham số
  	___
  EndProcedure
  ```
- **Lỗi hay gặp:**
  - Giữ `ProceedWithCall()` → code lỗi gốc vẫn chạy.
  - Mở rộng nhầm procedure trong **manager module** của catalog thay vì procedure trong **command module** (lỗi nằm ở lời gọi).
  - Extension chưa active hoặc chưa update DB configuration của extension.
- **Tự kiểm tra:** Trên list `_DemoProjects`, chọn project, bấm MakeDefault, trả lời Yes: không lỗi, project in đậm và tên hiện trên tiêu đề ứng dụng. Tắt extension (Active = False) thì lỗi quay lại.

### Bài tập 2 — Extension "Customization": ReleasedBy/ReceivedBy cho _DemoInventoryTransfer

- **Đề bài (tóm tắt):** Thêm 2 attribute `ReleasedBy`, `ReceivedBy` kiểu `CatalogRef._DemoIndividuals` vào `_DemoInventoryTransfer`, hiển thị field trên form **chỉ bằng code**. Đổi `StorageSource` → điền `ReleasedBy` bằng người phụ trách của kho đó. Tương tự `StorageLocationDestination` → `ReceivedBy`. User vẫn sửa tay được.
- **Gợi ý 1 — Hướng đi:**
  - Attribute mới của object: adopt document vào extension rồi thêm attribute (xem "Lưu dữ liệu thêm trong extension vào bảng DB": sẽ có restructure DB).
  - Field trên form: xem "Tạo form element bằng code" (`Items.Add()`, `Insert()`, `DataPath`, `SetAction()`).
  - Điền tự động: handler OnChange cho 2 field kho. Field có sẵn nên gán handler bằng `SetAction()` hoặc mở rộng event handler của field với call type "After".
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Extension mới, Purpose = Customization. Adopt `Document._DemoInventoryTransfer`, thêm 2 attribute (synonym không lộ prefix).
  - Catalog `_DemoStorageLocations` có attribute `FinanciallyLiablePerson` (synonym "Financially liable person", kiểu `CatalogRef._DemoIndividuals`). Đây là "Person responsible" của đề.
  - Adopt form `DocumentForm`. Mở rộng `OnCreateAtServer` (call type "After") để tạo 2 input field. DataPath dạng `Object.<tên attribute có prefix>`. Đặt cạnh `StorageSource`/`StorageLocationDestination` (group `StorageLocationsGroup`).
  - Lấy attribute của kho ở server: dùng hàm của SSL `Common.ObjectAttributeValue(...)` hoặc đọc qua ref trong procedure `&AtServerNoContext`.
- **Gợi ý 3 — Khung bài làm:**
  1. Tạo extension, adopt document, thêm 2 attribute.
  2. Adopt form, mở rộng `OnCreateAtServer` với "After": tạo 2 field, gán handler OnChange cho 2 field kho.
  3. Viết 2 handler client và một function server lấy người phụ trách của kho.
  4. Kiểm tra lại safe mode của extension nếu bạn mở rộng gì khác ngoài form handler.
  ```bsl
  &AtServer
  Procedure ___OnCreateAtServerAfter(Cancel, StandardProcessing)
  	// Items.Insert/Add cho 2 field + DataPath; SetAction("OnChange", ...) cho 2 field kho
  	___
  EndProcedure

  &AtServerNoContext
  Function ___(StorageLocation)
  	// trả về người phụ trách của kho
  	___
  EndFunction
  ```
- **Lỗi hay gặp:**
  - Vẽ field bằng form designer trong extension: đề cấm, phải tạo bằng code.
  - DataPath thiếu `Object.` → field không gắn được với attribute của document.
  - Ghi đè handler OnChange có sẵn của field bằng "Around": hãy dùng "After" hoặc thêm hành động riêng, không phá logic gốc.
  - Handler gán qua `SetAction()` sai tập/thứ tự parameter (OnChange nhận `Item`).
  - Ghi đè giá trị user đã sửa tay mỗi lần mở form: chỉ điền trong OnChange của field kho.
- **Tự kiểm tra:** Mở document chuyển kho: 2 field mới hiện cạnh field kho. Chọn kho gửi → "Released by" tự điền đúng người phụ trách. Sửa tay rồi Save, mở lại → giá trị giữ nguyên.

### Bài tập 3 — Print form "Transfer Note" in Released/Received by từ attribute mới

- **Đề bài (tóm tắt):** Dùng extension của bài 2 để sửa print form "Transfer Note" của `_DemoInventoryTransfer`, sao cho ô "Released by" và "Received by" lấy từ 2 attribute mới.
- **Gợi ý 1 — Hướng đi:** Cần sửa **một phần** function dựng print form trong manager module (thêm field vào query, thêm dữ liệu cho template) mà vẫn giữ phần còn lại → "Call instead (with control)..." (`&ChangeAndValidate`) với `#Insert/#EndInsert` (và `#Delete/#EndDelete` nếu cần). Template cũng phải có parameter cho 2 ô này. Cách khác cũng được chấp nhận: "Call instead of..." (`&Around`) viết lại cả function — đơn giản hơn nhưng sẽ không nhận thay đổi của function gốc khi cấu hình được cập nhật; nếu chọn cách này, hãy giải thích được vì sao.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Manager module của `_DemoInventoryTransfer`, function `GoodsTransferPrintForm(ObjectsArray, PrintObjects)` (dựng "Transfer Note" từ template `PF_MXL_TransferNote`).
  - Trong function: query lấy header document, rồi structure dữ liệu in được điền vào parameters của các area. Area "Signatures" có nhãn "Released by"/"Received by".
  - Adopt template `PF_MXL_TransferNote` vào extension và thêm parameter vào ô cạnh nhãn (hoặc kiểm tra template đã có parameter chưa).
  - Mở rộng method trong manager module → tắt **Safe mode** của extension và khởi động lại (xem "&ChangeAndValidate annotation").
- **Gợi ý 3 — Khung bài làm:**
  1. Đọc function gốc, tìm chỗ query chọn field header và chỗ điền structure dữ liệu in.
  2. Add to Extension function đó với "Call instead (with control)".
  3. Dùng `#Insert` để thêm 2 field vào text query và thêm 2 phần tử vào dữ liệu in.
  4. Thêm parameter trong area chữ ký của template (tên trùng key bạn thêm).
  5. Tắt safe mode, update extension.
- **Lỗi hay gặp:**
  - Sửa dòng ngoài `#Insert/#Delete` → extension phát hiện khác biệt và ngừng mở rộng method.
  - Query đã sửa bằng directive không mở được bằng query builder. Sửa bằng tay cẩn thận dấu `|` và dấu phẩy.
  - Lỗi khi mở list/print vì safe mode chặn mở rộng manager module.
  - Tên parameter trong template không khớp key trong dữ liệu in → ô trống.
- **Tự kiểm tra:** Print → "Transfer note": ô Released by / Received by hiện đúng tên từ document. Đổi người trên document, Save, in lại → thay đổi theo.

### Bài tập 4 — Thử thứ tự gọi khi nhiều extension cùng mở rộng một method

- **Đề bài (tóm tắt):** Đọc tài liệu về thứ tự gọi method được mở rộng. Tạo nhiều extension mỗi loại purpose (ví dụ 2 Patch, 3 Customization, 2 Add-on), cùng mở rộng một method với cùng các annotation (Before, After, Instead), mỗi method hiện message là tên extension để quan sát thứ tự.
- **Gợi ý 1 — Hướng đi:** Xem "Làm việc với extension" (thứ tự thực thi theo purpose rồi theo thứ tự thêm vào infobase) và bảng "Tóm tắt annotations / call types". Before chạy trước method gốc, After chạy sau. Instead (Around) thay method gốc và chỉ gọi tiếp chuỗi khi có `ProceedWithCall()`.
- **Gợi ý 2 — Dùng gì, đặt ở đâu:**
  - Chọn một **procedure** dễ kích hoạt, ví dụ một form event handler client của một form demo (Before/After không có cho functions).
  - Mỗi extension: "Add to Extension" cùng method, chọn call type cần thử. Trong thân chỉ hiện message chứa tên extension và call type.
  - Danh sách Configuration extensions để xem và đổi thứ tự thêm.
- **Gợi ý 3 — Khung bài làm:**
  1. Ghi trước dự đoán thứ tự (Patch → Customization → Add-on, trong cùng purpose theo thứ tự thêm).
  2. Tạo lần lượt các extension, mỗi extension mở rộng cùng method với Before và After. Một vài extension dùng Instead.
  3. Kích hoạt method, chép lại thứ tự message.
  4. Thử bỏ `ProceedWithCall()` trong một method Instead và quan sát extension nào bị "cắt" khỏi chuỗi.
  ```bsl
  &AtClient
  &___("<TênMethodGốc>")   // Before / After / Around tùy thử nghiệm
  Procedure ___<TênMethodGốc>(___)
  	// message: tên extension + call type
  	___
  EndProcedure
  ```
- **Lỗi hay gặp:**
  - Dùng function để thử Before/After: không có call type này cho functions.
  - Nhiều extension Patch cùng mở rộng một method với mục đích khác nhau: tài liệu khuyến cáo tránh trong thực tế. Ở đây chỉ để thí nghiệm.
  - Quên đặt extension về Active, hoặc quên update extension → message không hiện.
- **Tự kiểm tra:** Bảng thứ tự message khớp quy tắc purpose + thứ tự thêm. Đổi thứ tự (xóa rồi thêm lại một extension) thì message đổi theo dự đoán.

## Video tham khảo

Video bài giảng trên YouTube có phạm vi trùng với bài này. Khi dẫn cho người học, nói "Bạn có thể tham khảo thêm về <chủ đề> của khóa tại đây: [<tên video>](link)" — không nói "khóa cũ/Junior", không dùng mã JC (mã JC trong danh sách chỉ để tra nội bộ). Quy ước đầy đủ: `references/video.md#video-junior-course`.

Không có video bài giảng tương ứng — chỉ dẫn tài liệu Theory/Practice của bài.

<!-- video-qa-thuchanh:start -->

Video giải đáp tình huống thực chiến và video thực hành từng bước liên quan tới bài này (thẻ chi tiết, triệu chứng, lưu ý khi giới thiệu: `references/video.md#video-qa-thuc-chien`, `references/video.md#video-thuc-hanh`; cùng mẫu câu dẫn ở trên):

- [Extension (Phần mở rộng) trong 1C:Enterprise](https://www.youtube.com/watch?v=T_DEaA1p_bA&list=PLp-gQ5Mgw0ZyRJw4qEFKcUz4cCagjYG6r&index=22) (6:33) — thêm báo cáo bằng extension mà không sửa cấu hình gốc (giải đáp tình huống; bài Extensions chính) _(mã nội bộ QA-22)_

<!-- video-qa-thuchanh:end -->
