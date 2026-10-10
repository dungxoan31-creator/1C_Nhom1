# Tài liệu gộp: jet-2-purchases-sales-warehouse

Gồm các mục: § jet-purchases, § jet-sales, § jet-warehouse


---

# § jet-purchases

# 1C:Jet — Subsystem Purchases (phân hệ Mua hàng)

**Khi nào đọc file này:** khi sinh viên hỏi về phân hệ Mua hàng của Jet (Document `SupplierInvoice`, nhà cung cấp, VAT, ứng trước cho nhà cung cấp, register `Purchases` / `SupplierBalance`, report Purchases / SupplierBalance), hoặc khi nhóm sinh viên cần chọn hướng mở rộng cho phân hệ này.

Nguồn: cấu hình Jet (repo 1Ci-Company/Jet, nhánh `community`, commit 80884de, version 1.0.2.1) — mọi đường dẫn `cf/...` bên dưới là file trong bản dump cấu hình. Chỗ nào là suy luận được ghi "[suy luận]".

## Mục lục

1. [Thành phần của Subsystem Purchases](#1-thành-phần-của-subsystem-purchases)
2. [Catalog Counterparties — phía nhà cung cấp](#2-catalog-counterparties--phía-nhà-cung-cấp)
3. [Catalog VATRates](#3-catalog-vatrates)
4. [Document SupplierInvoice — metadata](#4-document-supplierinvoice--metadata)
5. [SupplierInvoice — form module: tính lại số tiền, VAT, tỷ giá](#5-supplierinvoice--form-module-tính-lại-số-tiền-vat-tỷ-giá)
6. [SupplierInvoice — Filling, BeforeWrite, Posting](#6-supplierinvoice--filling-beforewrite-posting)
7. [Common module PostingManagement — khung Posting dùng chung](#7-common-module-postingmanagement--khung-posting-dùng-chung)
8. [Accumulation register Purchases và SupplierBalance](#8-accumulation-register-purchases-và-supplierbalance)
9. [Ứng trước và thanh toán cho nhà cung cấp](#9-ứng-trước-và-thanh-toán-cho-nhà-cung-cấp)
10. [Report Purchases và SupplierBalance (DCS)](#10-report-purchases-và-supplierbalance-dcs)
11. [Các điểm tích hợp SSL](#11-các-điểm-tích-hợp-ssl)
12. [Những điểm đáng chú ý trong code](#12-những-điểm-đáng-chú-ý-trong-code)
13. [Gợi ý mở rộng cho nhóm sinh viên phân hệ Mua hàng](#13-gợi-ý-mở-rộng-cho-nhóm-sinh-viên-phân-hệ-mua-hàng)

---

## 1. Thành phần của Subsystem Purchases

Subsystem `Purchases` (cf/Subsystems/Purchases.xml) có `Picture` = `CommonPicture.SectionPurchases` và hai subsystem con. Đây là cách chia nhóm chức năng trên giao diện đã học ở Bài 9.

| Cấp | Member object (`<Content>`) |
|---|---|
| `Purchases` (cấp trên) | `AccumulationRegister.Purchases`, `AccumulationRegister.SupplierBalance`, `Report.Purchases`, `Report.SupplierBalance`, `Role.UsePurchases`, `CommonCommand.AdditionalReportsPurchases`, `CommonCommand.AdditionalDataProcessorsPurchases`, `CommonCommand.ReportPanelPurchases` |
| `Purchases.Purchases` (con) | `Document.SupplierInvoice` |
| `Purchases.Catalogs` (con) | `Catalog.Counterparties`, `Catalog.Products`, `Catalog.Units` |

Command interface của subsystem (cf/Subsystems/Purchases/Ext/CommandInterface.xml): hai report được đưa vào nhóm `ActionsPanelReports`; thứ tự subsystem con là `Catalogs` trước, `Purchases` sau. Ở subsystem con `Catalogs` (cf/Subsystems/Purchases/Subsystems/Catalogs/Ext/CommandInterface.xml), lệnh `Catalog.Counterparties.StandardCommand.OpenList` và `Catalog.Counterparties.Command.Customers` bị ẩn (`Visibility` = false) — trong phân hệ Mua hàng người dùng chỉ thấy lệnh **`Suppliers`** của Counterparties.

Ba common command là cầu nối sang SSL (xem Bài 21 — Additional reports and data processors): `AdditionalReportsPurchases` / `AdditionalDataProcessorsPurchases` gọi `AdditionalReportsAndDataProcessorsClient.OpenAdditionalReportAndDataProcessorCommandsForm(..., "Purchases")` (module SSL), còn `ReportPanelPurchases` gọi `ReportsOptionsClient.ShowReportBar("Purchases", ExecutionParameters)` (module SSL). Để các lệnh này hoạt động, Jet khai báo section `Purchases` trong các module SSL "*Overridable": `AdditionalReportsAndDataProcessorsOverridable` (`Sections.Add(Metadata.Subsystems.Purchases)`) và `ReportsOptionsOverridable` (`Sections.Add(Metadata.Subsystems.Purchases, NStr("en = 'Purchases reports'"))`).

**Object liên quan nhưng không nằm trong subsystem này:** `Catalog.VATRates` (thuộc `Company.Taxes`), `Catalog.Warehouses`, `Catalog.Currencies`, `AccumulationRegister.InventoryInWarehouses` và `InventoryCost` (phân hệ Kho), `Document.BankPayment` / `CashVoucher` (phân hệ Dòng tiền — dùng để trả tiền / ứng trước cho nhà cung cấp), `CommonForm.SelectAdvances`.

**Role `UsePurchases`** (cf/Roles/UsePurchases/Ext/Rights.xml) cấp: toàn quyền tương tác với `Document.SupplierInvoice` (gồm Posting, UndoPosting, InteractivePosting…), `Catalog.Counterparties`, `Catalog.Products`, `Catalog.Units` và các catalog `*AttachedFiles`; chỉ Read/View với `AccumulationRegister.Purchases` và `SupplierBalance`; Use/View hai report; View `CommonForm.SelectAdvances`; Read/Update `Sequence.InventoryCostRecalculation`. Role này **không** có quyền trên `Catalog.VATRates`, `Catalog.Warehouses`, `AccumulationRegister.InventoryInWarehouses`, `InventoryCost` — các quyền đó nằm ở `UseCompany`, `UseWarehouses` (xem Bài 20). [suy luận] Người dùng thực tế cần được gán thêm các role đó; việc ghi vào register kho khi post vẫn chạy được vì Document bật **Post in privileged mode** (mục 4).

---

## 2. Catalog Counterparties — phía nhà cung cấp

Jet dùng **một** catalog `Counterparties` cho cả khách hàng và nhà cung cấp; phân biệt bằng hai attribute Boolean `Customer` và `Supplier` (cf/Catalogs/Counterparties.xml). Catalog có hierarchy kiểu `HierarchyFoldersAndItems`, `CodeLength` 9, `DescriptionLength` 25. Các attribute khác: `LegalName`, `TIN`, `PriceType` (`CatalogRef.PriceTypes`), `IsIndividual`; tabular section `AdditionalAttributes` (SSL Properties) và `ContactInformation` (SSL Contact information). Attribute `Supplier` có `FillFromFillingValue` = true.

**Lọc chỉ nhà cung cấp khi chọn trong SupplierInvoice** — làm bằng metadata, không cần code: attribute `SupplierInvoice.Supplier` có Choice parameter `Filter.Supplier` = `true` (cf/Documents/SupplierInvoice.xml). Đây là ví dụ tốt để nhắc sinh viên: nhiều yêu cầu lọc giải quyết được bằng thuộc tính metadata trước khi nghĩ tới code.

**Command `Suppliers`** (cf/Catalogs/Counterparties/Commands/Suppliers/Ext/CommandModule.bsl, &AtClient) mở `Catalog.Counterparties.ListForm` với `FormParameters` gồm `Supplier` = True và `PurposeUseKey` = `"SupplierList"` (để form lưu cài đặt riêng cho danh sách nhà cung cấp).

List form đọc `Parameters.Supplier` / `Parameters.Customer` trong `OnCreateAtServer` rồi gọi `SetFilterCustomersSuppliers`. `SetFilterCustomersSuppliers` là procedure `&AtClientAtServerNoContext` (gọi được cả từ `OnCreateAtServer` lẫn từ handler client `FilterSuppliersOnChange`), dùng các hàm SSL `CommonClientServer.ChangeFilterItems`, `FindFilterItemByPresentation`, `CreateFilterItemGroup`, `AddCompositionItem` để thêm điều kiện vào `List.SettingsComposer.FixedSettings.Filter` (nhóm OR tên `"CustomersOrSuppliers"`).

Report `Purchases` và `SupplierBalance` mỗi cái có một command (`OpenPurchasesReport`, `OpenSupplierBalanceReport`) với `CommandParameterType` = `CatalogRef.Counterparties`, nhóm `FormNavigationPanelSeeAlso` — nên trên form của một counterparty sẽ có liên kết "xem thêm" mở report đã lọc theo counterparty đó (mục 10).

---

## 3. Catalog VATRates

Catalog đơn giản: không hierarchy, `CodeLength` 0, `DescriptionLength` 25, một attribute `Rate` (Number 5.2). `Catalog.Products` có attribute `VATRate` (`CatalogRef.VATRates`) — thuế suất mặc định của mặt hàng.

Item form có `RateOnChange` (&AtClient): nếu `Description` trống thì đặt `Description = String(Object.Rate) + "%"`.

Manager module có một function export, dùng khi chứng từ được đánh dấu "miễn thuế":

Nguồn: Jet — cf/Catalogs/VATRates/Ext/ManagerModule.bsl
```bsl
Function GetExemptFromVATRate() Export
	
	SetPrivilegedMode(True);
	
	Query = New Query;
	Query.Text =
	"SELECT TOP 1
	|	VATRates.Ref AS Ref
	|FROM
	|	Catalog.VATRates AS VATRates
	|WHERE
	|	NOT VATRates.DeletionMark
	|	AND VATRates.Rate = 0";
	
	// ...
	NewVATRate = Catalogs.VATRates.CreateItem();
	NewVATRate.Description = "0%";
	NewVATRate.Rate = 0;
	NewVATRate.Write();
	// ...
	
EndFunction
```

Lưu ý: thuật toán tìm theo **giá trị `Rate` = 0**, không theo Description — đúng nguyên tắc "không dựa vào dữ liệu người dùng có thể sửa tùy ý" (terminology.md mục 2), dù Jet không dùng Predefined data ở đây.

Giá trị phần trăm được đọc qua một chuỗi module Jet: `JetServerCall.GetVATRateValue` (common module **Server call** = true) → `JetCached.GetVATRateValue` (common module có **Reuse return values** = `DuringSession`, xem Bài 14):

`JetCached.GetVATRateValue` trả về `?(ValueIsFilled(VATRate), Common.ObjectAttributeValue(VATRate, "Rate"), 0)`.

[suy luận] Vì cache theo session, nếu ai đó sửa `Rate` của một thuế suất đang dùng, người dùng khác có thể vẫn thấy giá trị cũ cho tới khi mở lại phiên.

---

## 4. Document SupplierInvoice — metadata

Synonym "Supplier invoice" (hóa đơn nhà cung cấp / phiếu nhập mua). Thuộc tính chính (cf/Documents/SupplierInvoice.xml):

| Property | Giá trị |
|---|---|
| Number | String, length 9, Variable, Autonumbering, CheckUnique |
| Posting | Allow; RealTimePosting = Deny |
| RegisterRecordsDeletion | AutoDeleteOff |
| RegisterRecordsWritingOnPost | WriteSelected |
| Post in privileged mode / Unpost in privileged mode | true / true |
| DataLockControlMode | Managed |
| BasedOn | (trống) — SupplierInvoice không được tạo từ document khác |
| Register records | `Purchases`, `SupplierBalance`, `InventoryInWarehouses`, `InventoryCost` |
| Templates | `PF_MXL_GoodsReceivedNote` (in), `PrintData` (DCS dữ liệu in), `LoadingFromFile` (mẫu import) |

**Header attributes**

| Attribute | Type | Ghi chú |
|---|---|---|
| `Supplier` | CatalogRef.Counterparties | FillChecking = ShowError; Choice parameter `Filter.Supplier` = true |
| `Warehouse` | CatalogRef.Warehouses | ShowError |
| `Currency` | CatalogRef.Currencies | ShowError |
| `ExchangeRate` | Number 10.4, Nonnegative | tỷ giá |
| `Multiplier` | Number 10.0, Nonnegative | "bội số" tỷ giá (Repetition) |
| `Comment` | String (không giới hạn) | |
| `Author` | CatalogRef.Users | điền khi tạo (mục 6) |
| `Total` | Number 15.2 | tính lại trong `BeforeWrite` |
| `ExemptFromVAT` | Boolean | miễn VAT |

Standard attribute `Date` có FillChecking = ShowError.

**Tabular section `Inventory`**: `Product` (CatalogRef.Products), `Quantity` (15.3), `Price`, `Amount`, `VATRate` (CatalogRef.VATRates), `VATAmount`, `Total` (đều 15.2). Quy ước: `Amount` = trước thuế, `Total` = sau thuế, tất cả tính theo **tiền của chứng từ** (`Currency`).

**Tabular section `AdvanceClearing`** (cấn trừ ứng trước): `Document` (composite type: `DocumentRef.BankPayment`, `DocumentRef.CashVoucher`), `Amount` (theo presentation currency), `AmountCur` (theo tiền chứng từ).

**Tabular section `AdditionalAttributes`**: `Property`, `Value`, `TextString` — phục vụ SSL Properties.

**Form `DocumentForm`** (cf/Documents/SupplierInvoice/Forms/DocumentForm/Ext/Form.xml): header gồm `Supplier`, `Currency`, `ExchangeRate`, `Multiplier`, `ExemptFromVAT`, `Number`, `Date`, `Warehouse`; ba page: `GroupInventory` (bảng `Inventory` + nút `ImportInventoryFromFile` + nhóm tổng `GroupTotal`), `GroupAdvanceClearing` (bảng `AdvanceClearing` + nút `SelectAdvances`), `GroupAdditionalInfo` (`Comment`, `Author`, nhóm thuộc tính bổ sung). Cột `InventoryUnit` là LabelField với DataPath `Object.Inventory.Product.Unit` — hiển thị đơn vị tính bằng dereference, không lưu vào document. Form attribute ngoài `Object`: `PresentationCurrency`.

---

## 5. SupplierInvoice — form module: tính lại số tiền, VAT, tỷ giá

### 5.1. Bản đồ handler → module được gọi

| Handler (directive) | Sự kiện | Gọi tới |
|---|---|---|
| `OnCreateAtServer` (&AtServer) | tạo form | `JetServer.GetPresentationCurrency`; SSL `AttachableCommands`, `PropertyManager` |
| `OnOpen` (&AtClient) | mở form | `FormManagement()`; SSL |
| `FillCheckProcessingAtServer` (&AtServer) | kiểm tra trước khi ghi | `Common.MessageToUser` (SSL) |
| `CurrencyOnChange` (&AtClient) | đổi tiền tệ | `GetExchangeRateData` (&AtServerNoContext) → SSL `CurrencyRateOperations.GetCurrencyRate` |
| `ExemptFromVATOnChange` (&AtClient) | bật/tắt miễn thuế | `FillVATRateByVATExemption` (&AtServer) |
| `InventoryProductOnChange` (&AtClient) | chọn sản phẩm | `GetProductData` (&AtServerNoContext), `InventoryTabularSectionClientServer.CalculateAmount` |
| `InventoryQuantityOnChange`, `InventoryPriceOnChange` | đổi SL / đơn giá | `InventoryTabularSectionClientServer.CalculateAmount` |
| `InventoryAmountOnChange` | sửa thành tiền | tính ngược `Price`, rồi `CalculateVATAmountAndTotal` |
| `InventoryVATRateOnChange` | đổi thuế suất | `InventoryTabularSectionClientServer.CalculateVATAmountAndTotal` |
| `AdvanceClearingAmountOnChange`, `AdvanceClearingAmountCurOnChange` | sửa số cấn trừ | `JetClientServer.CalculateFromCurrencyToCurrency` |
| `SelectAdvances` (command) | chọn khoản ứng trước | `CommonForm.SelectAdvances` (mục 9) |
| `ImportInventoryFromFile` (command) | import Excel | SSL `ImportDataFromFileClient` |

### 5.2. Product / Quantity / Price / VAT

Nguồn: Jet — cf/Documents/SupplierInvoice/Forms/DocumentForm/Ext/Form/Module.bsl
```bsl
&AtClient
Procedure InventoryProductOnChange(Item)
	
	// ...
	GetProductData(DataStructure);
	
	FillPropertyValues(CurrentData, DataStructure);
	
	InventoryTabularSectionClientServer.CalculateAmount(CurrentData);
	
EndProcedure

// ...
&AtClient
Procedure InventoryAmountOnChange(Item)
	
	TabSectionRow = Items.Inventory.CurrentData;
	
	If TabSectionRow.Quantity <> 0 Then
		TabSectionRow.Price = Round(TabSectionRow.Amount / TabSectionRow.Quantity, 2);
	EndIf;
	
	InventoryTabularSectionClientServer.CalculateVATAmountAndTotal(TabSectionRow);
	
EndProcedure
```

`GetProductData` chạy `&AtServerNoContext` — chỉ truyền một Structure nhỏ lên server, không truyền cả form (xem Bài 7, context vs non-context call):

Nguồn: Jet — cf/Documents/SupplierInvoice/Forms/DocumentForm/Ext/Form/Module.bsl
```bsl
&AtServerNoContext
Procedure GetProductData(DataStructure)
	
	// ...
		ProductAttributes = Common.ObjectAttributesValues(DataStructure.Product, "VATRate");
	// ...
	If DataStructure.Property("ExemptFromVAT") And DataStructure.ExemptFromVAT Then
		DataStructure.Insert("VATRate", Catalogs.VATRates.GetExemptFromVATRate());
	Else
		DataStructure.Insert("VATRate", ProductAttributes.VATRate);
	EndIf;
	
	DataStructure.Insert("Quantity", 1);
	
EndProcedure
```

So sánh: `GetProductData` trong form của `SalesInvoice` có thêm hai dòng lấy giá bằng `PriceManagementServerCall.GetProductPriceByPriceType`. Ở SupplierInvoice **không tự điền giá** — người dùng nhập `Price` bằng tay (ý tưởng mở rộng ở mục 13).

Công thức nằm trong common module Jet `InventoryTabularSectionClientServer` (Client (managed application) = true, Server = true, Server call = false — chạy được cả hai phía, dùng chung với các document khác có tabular section `Inventory`):

Nguồn: Jet — cf/CommonModules/InventoryTabularSectionClientServer/Ext/Module.bsl
```bsl
Procedure CalculateAmount(TabSectionRow) Export
	
	TabSectionRow.Amount = TabSectionRow.Quantity * TabSectionRow.Price;
	CalculateVATAmountAndTotal(TabSectionRow);
	
EndProcedure
// ...
Procedure CalculateVATAmountAndTotal(TabSectionRow) Export
	
	VATRate = JetServerCall.GetVATRateValue(TabSectionRow.VATRate);
	TabSectionRow.VATAmount = TabSectionRow.Amount * VATRate / 100;
	TabSectionRow.Total = TabSectionRow.Amount + TabSectionRow.VATAmount;
	
EndProcedure
```

Chuỗi gọi khi sửa Quantity trên client: `InventoryQuantityOnChange` (client) → `CalculateAmount` (client) → `CalculateVATAmountAndTotal` (client) → `JetServerCall.GetVATRateValue` (**server call**) → `JetCached.GetVATRateValue` (server, cache). [suy luận] Mỗi lần sửa một ô là một lần gọi server; cache giúp phía server nhanh nhưng vẫn có round-trip.

### 5.3. Miễn thuế (ExemptFromVAT)

Nguồn: Jet — cf/Documents/SupplierInvoice/Forms/DocumentForm/Ext/Form/Module.bsl
```bsl
&AtServer
Procedure FillVATRateByVATExemption()
	
	If Object.ExemptFromVAT Then
		
		ExemptFromVATRate = Catalogs.VATRates.GetExemptFromVATRate();
		
		For Each InventoryRow In Object.Inventory Do
			InventoryRow.VATRate = ExemptFromVATRate;
			InventoryRow.VATAmount = 0;
			InventoryRow.Total = InventoryRow.Amount;
		EndDo;
	Else
		For Each InventoryRow In Object.Inventory Do
			InventoryRow.VATRate = InventoryRow.Product.VATRate;
			InventoryTabularSectionClientServer.CalculateVATAmountAndTotal(InventoryRow);
		EndDo;
	EndIf;
	
EndProcedure
```

Directive `&AtServer` (có context) vì phải duyệt và sửa toàn bộ `Object.Inventory`; dòng `InventoryRow.Product.VATRate` dùng dereference nên chỉ viết được ở server. `FormManagement()` (client) ẩn các cột `InventoryVATRate`, `InventoryVATAmount`, `InventoryTotal` và tổng VAT khi `ExemptFromVAT` = true, và khóa `ExchangeRate`/`Multiplier` khi `Currency` = presentation currency.

### 5.4. Tiền tệ và tỷ giá

`CurrencyOnChange` (&AtClient) gom `Currency`, `PresentationCurrency`, `Date` vào Structure rồi gọi `GetExchangeRateData` (&AtServerNoContext): nếu tiền tệ khác presentation currency thì lấy `CurrencyRateOperations.GetCurrencyRate(Currency, Date)` và gán `ExchangeRate = Rate`, `Multiplier = Repetition`; ngược lại gán 1 / 1. `CurrencyRateOperations` là module SSL (Currencies subsystem). Presentation currency lấy từ `JetServer.GetPresentationCurrency()` = attribute `PresentationCurrency` của `Catalogs.Companies.MainCompany` (predefined item). Đổi tiền tệ **không** tự quy đổi lại giá trong bảng — chỉ cập nhật `ExchangeRate`, `Multiplier`.

### 5.5. Kiểm tra trước khi ghi

Nguồn: Jet — cf/Documents/SupplierInvoice/Forms/DocumentForm/Ext/Form/Module.bsl
```bsl
&AtServer
Procedure FillCheckProcessingAtServer(Cancel, CheckedAttributes)
	
	If Object.Inventory.Total("Total") < Object.AdvanceClearing.Total("AmountCur") Then
		MessageText = NStr("en = 'The invoice amount is less than the clearing amount.'");
		Common.MessageToUser(MessageText,,,, Cancel);
	EndIf;
	// ...
EndProcedure
```

So sánh tổng hóa đơn với tổng cấn trừ **cùng theo tiền chứng từ** (`AmountCur`). Lưu ý đây là `FillCheckProcessingAtServer` của **form**, không phải `FillCheckProcessing` của object module (xem Bài 12, Bài 16) — nếu document được ghi bằng code (không qua form) thì kiểm tra này không chạy.

---

## 6. SupplierInvoice — Filling, BeforeWrite, Posting

Object module ngắn gọn; toàn bộ logic dữ liệu được đẩy sang manager module và common module.

Nguồn: Jet — cf/Documents/SupplierInvoice/Ext/ObjectModule.bsl
```bsl
#If Server Or ExternalConnection Then

#Region EventHandlers

Procedure Filling(FillingData, FillingText, StandardProcessing)
	
	ObjectFillingJet.FillDocument(ThisObject, FillingData);
	
EndProcedure

Procedure Posting(Cancel, PostingMode)
	
	// Initialization of additional properties for document posting.
	PostingManagement.InitializeAdditionalPropertiesForPosting(Ref, AdditionalProperties);
	
	// Document data initialization.
	Documents.SupplierInvoice.InitializeDocumentData(Ref, AdditionalProperties);
	
	// Preparation of records sets.
	PostingManagement.PrepareRecordSetsForWriting(ThisObject);
	
	// Movements on the Purchases register
	PostingManagement.ReflectPurchases(AdditionalProperties, RegisterRecords, Cancel);
	
	// Movements on the InventoryInWarehouses register
	PostingManagement.ReflectInventoryInWarehouses(AdditionalProperties, RegisterRecords, Cancel);
	
	// Movements on the SupplierBalance register
	PostingManagement.ReflectSupplierBalance(AdditionalProperties, RegisterRecords, Cancel);
	
	// Movements on the InventoryCost register
	PostingManagement.ReflectInventoryCost(AdditionalProperties, RegisterRecords, Cancel);
	
	// Writing of the records sets.
	PostingManagement.WriteRecordSets(ThisObject);
	
	// Negative balance control
	AccumulationRegisters.InventoryInWarehouses.NegativeBalanceControl(Ref, AdditionalProperties, Cancel);
	
EndProcedure

// ...
```

Các điểm cần giải thích cho sinh viên:

- **Filling** gọi `ObjectFillingJet.FillDocument` (common module Jet, chỉ Server): nếu `FillingData` không phải Structure thì thay bằng Structure rỗng; điền `Currency` = presentation currency với `ExchangeRate` = 1, `Multiplier` = 1 (hoặc lấy tỷ giá qua `CurrencyRateOperations.GetCurrencyRate` nếu FillingData có Currency); điền `Author` = `Users.AuthorizedUser()` (SSL). Vì không có `BasedOn`, SupplierInvoice hiện chỉ được "điền" khi tạo mới, không có Generation từ document khác.
- **Posting** theo mẫu 3 bước: (1) chuẩn bị dữ liệu bằng **một batch query** trong manager module → (2) nạp từng bảng vào record set bằng `PostingManagement.Reflect*` → (3) ghi và kiểm soát tồn âm. So với cách "duyệt tabular section, `RegisterRecords.X.Add()`" ở Bài 11, đây là cách làm của ứng dụng thật: tách truy vấn khỏi ghi sổ, dễ mở rộng thêm register.
- **UndoPosting** xóa các record set (record set rỗng được ghi lại) và vẫn chạy `NegativeBalanceControl` — hủy một phiếu nhập có thể làm tồn kho âm nếu hàng đã được bán.
- **BeforeWrite** tính `Total` header; kiểm tra `DataExchange.Load` để bỏ qua khi nạp dữ liệu trao đổi.

### 6.1. InitializeDocumentData — batch query

Nguồn: Jet — cf/Documents/SupplierInvoice/Ext/ManagerModule.bsl
```bsl
Procedure InitializeDocumentData(SupplierInvoiceRef, AdditionalProperties) Export
	
	Query = New Query;
	Query.Text =
	"SELECT
	// ...
	|INTO DocumentHeader
	// ...
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	DocumentHeader.Date AS Period,
	|	DocumentHeader.Supplier AS Counterparty,
	|	DocumentHeader.Warehouse AS Warehouse,
	|	DocumentHeader.Ref AS Document,
	|	SupplierInvoiceInventory.Product AS Product,
	|	SupplierInvoiceInventory.Quantity AS Quantity,
	|	SupplierInvoiceInventory.Amount * DocumentHeader.ExchangeRate / DocumentHeader.Multiplier AS Amount,
	|	SupplierInvoiceInventory.VATAmount * DocumentHeader.ExchangeRate / DocumentHeader.Multiplier AS VATAmount,
	|	SupplierInvoiceInventory.Total * DocumentHeader.ExchangeRate / DocumentHeader.Multiplier AS Total
	|INTO DocumentInventory
	|FROM
	|	DocumentHeader AS DocumentHeader
	|		INNER JOIN Document.SupplierInvoice.Inventory AS SupplierInvoiceInventory
	|		ON DocumentHeader.Ref = SupplierInvoiceInventory.Ref
	|;
	|
	// ...
	|		INNER JOIN Catalog.Products AS Products
	|		ON DocumentInventory.Product = Products.Ref
	|			AND (Products.ProductType = VALUE(Enum.ProductTypes.Inventory))
	// ...
```

Bốn query đầu (index 0–3) tạo temporary table (xem Bài 10 — temporary tables, batch query):

| Temp table | Nội dung |
|---|---|
| `DocumentHeader` | header của document |
| `DocumentInventory` | các dòng `Inventory`, số tiền đã **quy đổi sang presentation currency**: `× ExchangeRate / Multiplier` |
| `ProductTable` | chỉ các sản phẩm `ProductType = Inventory` (loại `Service` bị loại), gộp theo Period/Warehouse/Product |
| `DocumentAdvanceClearing` | các dòng cấn trừ ứng trước |

Bốn query sau (index 4–7) trả ra bảng cho từng register: `Purchases` (từ `DocumentInventory`, gộp theo Product/Counterparty/Period/Document, `Document AS PurchaseDocument`), `InventoryInWarehouses` (Receipt từ `ProductTable`), `SupplierBalance` (ba khối `UNION ALL` — trích dưới đây), `InventoryCost` (Receipt từ `ProductTable`, có `Amount`):

Nguồn: Jet — cf/Documents/SupplierInvoice/Ext/ManagerModule.bsl
```bsl
	|SELECT
	|	VALUE(AccumulationRecordType.Receipt) AS RecordType,
	|	DocumentInventory.Period AS Period,
	|	VALUE(Enum.LiabilityTypes.Liability) AS LiabilityType,
	|	DocumentInventory.Counterparty AS Counterparty,
	|	DocumentInventory.Document AS Document,
	|	SUM(DocumentInventory.Total) AS Amount
	|FROM
	|	DocumentInventory AS DocumentInventory
	|
	|GROUP BY
	|	DocumentInventory.Document,
	|	DocumentInventory.Period,
	|	DocumentInventory.Counterparty
	|
	|UNION ALL
	|
	|SELECT
	|	VALUE(AccumulationRecordType.Receipt),
	|	DocumentAdvanceClearing.Period,
	|	VALUE(Enum.LiabilityTypes.Advance),
	|	DocumentAdvanceClearing.Counterparty,
	|	DocumentAdvanceClearing.Document,
	|	SUM(DocumentAdvanceClearing.Amount)
	|FROM
	|	DocumentAdvanceClearing AS DocumentAdvanceClearing
	// ...
	|UNION ALL
	|
	|SELECT
	|	VALUE(AccumulationRecordType.Expense),
	|	DocumentAdvanceClearing.Period,
	|	VALUE(Enum.LiabilityTypes.Liability),
	|	DocumentAdvanceClearing.Counterparty,
	|	DocumentAdvanceClearing.InvoiceDocument,
	|	SUM(DocumentAdvanceClearing.Amount)
	|FROM
	|	DocumentAdvanceClearing AS DocumentAdvanceClearing
	// ...
	
	Query.SetParameter("Ref", SupplierInvoiceRef);
	
	QueryResult = Query.ExecuteBatch();
	
	AdditionalProperties.TableForRegisterRecords.Insert("TablePurchases", QueryResult[4].Unload());
	AdditionalProperties.TableForRegisterRecords.Insert("TableInventoryInWarehouses", QueryResult[5].Unload());
	AdditionalProperties.TableForRegisterRecords.Insert("TableSupplierBalance", QueryResult[6].Unload());
	AdditionalProperties.TableForRegisterRecords.Insert("TableInventoryCost", QueryResult[7].Unload());
	
EndProcedure
```

Tóm tắt register records của một SupplierInvoice:

| Register | Kiểu | Bản ghi | Dữ liệu |
|---|---|---|---|
| `Purchases` | Turnovers | không có RecordType | mọi dòng (kể cả Service): Counterparty, Product, PurchaseDocument = chính document; Quantity, Amount, VATAmount (presentation currency) |
| `InventoryInWarehouses` | Balance | Receipt | chỉ hàng `Inventory`: Warehouse, Product, Quantity |
| `SupplierBalance` | Balance | Receipt `Liability` | công nợ phải trả = tổng `Total` (sau thuế) theo document |
| | | Receipt `Advance` | mỗi dòng `AdvanceClearing`: Document = chứng từ ứng trước |
| | | Expense `Liability` | cùng số tiền, Document = chính hóa đơn |
| `InventoryCost` | Balance | Receipt | chỉ hàng `Inventory`: Quantity, Amount = giá trị **trước thuế** |

Mẹo dạy: tên cột trong mỗi query **trùng tên** dimension/resource của register, nhờ vậy `RecordSet.Load(ValueTable)` nạp thẳng được (mục 7). Đây cũng là lý do giá vốn nhập kho (`InventoryCost.Amount`) lấy `Amount` trước thuế, còn công nợ (`SupplierBalance.Amount`) lấy `Total` sau thuế.

---

## 7. Common module PostingManagement — khung Posting dùng chung

`PostingManagement` là common module Jet dùng cho mọi document có Posting (SupplierInvoice, SalesInvoice, BankPayment…).

Nguồn: Jet — cf/CommonModules/PostingManagement/Ext/Module.bsl
```bsl
Procedure PrepareRecordSetsForWriting(DocumentObject) Export
	
	For Each RecordSet In DocumentObject.RegisterRecords Do
		If RecordSet.Count() > 0 Then
			RecordSet.Clear();
		EndIf;
	EndDo;
	
	RegisterNameArray = GetUsedRegisterNames(DocumentObject.Ref, DocumentObject.AdditionalProperties.DocumentMetadata);
	For Each RegisterName In RegisterNameArray Do
		DocumentObject.RegisterRecords[RegisterName].Write = True;
	EndDo;
	
EndProcedure

// ...
Procedure ReflectPurchases(AdditionalProperties, RegisterRecords, Cancel) Export
	
	TablePurchases = AdditionalProperties.TableForRegisterRecords.TablePurchases;
	
	If Cancel Or TablePurchases.Count() = 0 Then
		Return;
	EndIf;
	
	PurchaseRecord = RegisterRecords.Purchases;
	PurchaseRecord.Write = True;
	PurchaseRecord.Load(TablePurchases);
	
EndProcedure
```

`WriteRecordSets` duyệt `RegisterRecords`, với record set có `Write = True` thì chép `ForPosting` vào `RecordSet.AdditionalProperties`, gọi `RecordSet.Write()` rồi đặt lại `Write = False`.

`ReflectSupplierBalance`, `ReflectInventoryInWarehouses`, `ReflectInventoryCost` có cấu trúc giống hệt `ReflectPurchases`, chỉ khác tên bảng/register.

Ý nghĩa:

- `InitializeAdditionalPropertiesForPosting` thêm vào `AdditionalProperties` ba khóa: `TableForRegisterRecords` (New Structure), `ForPosting` (Structure chứa `TempTablesManager` = New TempTablesManager), `DocumentMetadata` (= `DocumentRef.Metadata()`).
- `AdditionalProperties` (property có sẵn của data object) được dùng như "túi" truyền dữ liệu giữa các bước: `TableForRegisterRecords` chứa ValueTable cho từng register; `ForPosting.TempTablesManager` được chuyền tiếp vào record set để register module dùng chung temp table.
- `PrepareRecordSetsForWriting`: xóa record set đang có trong bộ nhớ, rồi tìm (bằng hàm private `GetUsedRegisterNames` — một query `UNION ALL` các `SELECT TOP 1 … WHERE Recorder = &Recorder` trên từng register trong `DocumentMetadata.RegisterRecords`) những register **đã có bản ghi cũ** của document và đặt `Write = True` cho chúng. Nhờ vậy khi post lại, register nào không còn bản ghi mới vẫn được ghi đè bằng record set rỗng → bản ghi cũ bị xóa. Kết hợp với `RegisterRecordsWritingOnPost` = WriteSelected (mục 4): [suy luận] platform chỉ tự ghi những record set có `Write = True` khi post (ngoài giáo trình — hãy kiểm tra lại trong Syntax assistant).
- Thứ tự trong `Posting` quan trọng: `NegativeBalanceControl` chạy **sau** `WriteRecordSets`, vì nó dựa vào temp table `InventoryInWarehousesChange` do record set module của `InventoryInWarehouses` tạo ra khi ghi (`BeforeWrite`/`OnWrite` của record set, có `DataLock` Exclusive theo Recorder). Đây là phân hệ Kho — chi tiết ở file Jet về Warehouses.

---

## 8. Accumulation register Purchases và SupplierBalance

### 8.1. AccumulationRegister.Purchases

cf/AccumulationRegisters/Purchases.xml — **Register type: Turnovers** (chỉ có doanh số, không có số dư; xem Bài 11). `EnableTotalsSplitting` = true. Recorder duy nhất: `Document.SupplierInvoice`. Không có module.

| Loại | Tên | Type |
|---|---|---|
| Dimension | `Counterparty` | CatalogRef.Counterparties |
| Dimension | `Product` | CatalogRef.Products |
| Dimension | `PurchaseDocument` | DocumentRef.SupplierInvoice |
| Resource | `Quantity` | Number 15.3 |
| Resource | `Amount` | Number 15.2 |
| Resource | `VATAmount` | Number 15.2 |

Không có `Total` trong register — report tự tính `Amount + VAT` (mục 10). Vì là Turnovers nên không có RecordType; [suy luận] muốn giảm doanh số mua (ví dụ trả hàng) thì ghi số âm.

### 8.2. AccumulationRegister.SupplierBalance

cf/AccumulationRegisters/SupplierBalance.xml — **Register type: Balance**. `EnableTotalsSplitting` = true. Recorders: `SupplierInvoice`, `BankPayment`, `CashVoucher`. Không có module.

| Loại | Tên | Type | DenyIncompleteValues |
|---|---|---|---|
| Dimension | `LiabilityType` | EnumRef.LiabilityTypes (`Liability`, `Advance`) | true |
| Dimension | `Counterparty` | CatalogRef.Counterparties | true |
| Dimension | `Document` | DocumentRef.BankPayment, DocumentRef.CashVoucher, DocumentRef.SupplierInvoice | false |
| Resource | `Amount` | Number 15.2 (presentation currency) | |

Quy ước dấu (rút ra từ code posting):

| Nghiệp vụ | RecordType | LiabilityType | Document |
|---|---|---|---|
| SupplierInvoice ghi nợ phải trả | Receipt | Liability | hóa đơn |
| BankPayment/CashVoucher trả cho một hóa đơn | Expense | Liability | hóa đơn được trả |
| BankPayment/CashVoucher trả không gắn hóa đơn (ứng trước) | Expense | Advance | chính phiếu chi |
| SupplierInvoice cấn trừ ứng trước | Receipt Advance + Expense Liability | | phiếu chi / hóa đơn |

→ Balance `Liability` dương = còn nợ nhà cung cấp; Balance `Advance` **âm** = đã ứng trước chưa cấn trừ. Report SupplierBalance đảo dấu khi hiển thị (mục 10). Dimension `Document` giúp theo dõi công nợ **theo từng chứng từ** (open-item), không chỉ theo nhà cung cấp.

### 8.3. Register phân hệ Kho mà SupplierInvoice ghi vào

- `InventoryInWarehouses` (Balance): dimension `Product`, `Warehouse`; resource `Quantity`. Có ManagerModule (`NegativeBalanceControl`) và RecordSetModule.
- `InventoryCost` (Balance): dimension `Product`, `Warehouse`; resource `Quantity`, `Amount`. Giá vốn bình quân được tính khi xuất (SalesInvoice, InventoryTransfer, InventoryWriteOff) — các document này nằm trong `Sequence.InventoryCostRecalculation`; **SupplierInvoice không nằm trong sequence đó** (xem mục 12).

---

## 9. Ứng trước và thanh toán cho nhà cung cấp

Wiki Jet (How-to-Start-Using-1C:Jet.md, mục 4 "Advance clearing") mô tả quy trình: trả trước bằng Bank payment hoặc Cash voucher → mở Supplier invoice → tab "Advance clearing" → "Select" → chọn chứng từ ứng trước → số ứng trước được trừ vào tổng hóa đơn.

### 9.1. Trả tiền: BankPayment / CashVoucher (phân hệ CashManagement)

`BankPayment` và `CashVoucher` có `BasedOn` = `Document.SupplierInvoice` — tức là từ hóa đơn có thể tạo phiếu chi (Generation, Bài 11). Trong tabular section `PaymentDetails`, attribute `Document` có type `DocumentRef.SupplierInvoice`. `Filling` của BankPayment (cf/Documents/BankPayment/Ext/ObjectModule.bsl), khi `TypeOf(FillingData) = Type("DocumentRef.SupplierInvoice")`, chạy một batch query lấy header hóa đơn và tài khoản ngân hàng đầu tiên cùng tiền tệ, rồi điền `Operation = Enum.BankPaymentOperations.Supplier`, `Counterparty = Supplier`, tiền tệ/tỷ giá, và một dòng `PaymentDetails` với `Document` = hóa đơn, `PaymentAmount` = `Total`, `Amount` = `Total × ExchangeRate / Multiplier`.

Phần ghi `SupplierBalance` khi post BankPayment — dòng nào không gắn hóa đơn thì thành **ứng trước** với Document = chính phiếu chi:

Nguồn: Jet — cf/Documents/BankPayment/Ext/ManagerModule.bsl
```bsl
	|SELECT
	|	VALUE(AccumulationRecordType.Expense) AS RecordType,
	|	DocumentPaymentDetails.Period AS Period,
	|	CASE
	|		WHEN DocumentPaymentDetails.Document = VALUE(Document.SupplierInvoice.EmptyRef)
	|				OR DocumentPaymentDetails.Document = UNDEFINED
	|			THEN VALUE(Enum.LiabilityTypes.Advance)
	|		ELSE VALUE(Enum.LiabilityTypes.Liability)
	|	END AS LiabilityType,
	|	DocumentPaymentDetails.Counterparty AS Counterparty,
	|	CASE
	|		WHEN DocumentPaymentDetails.Document = VALUE(Document.SupplierInvoice.EmptyRef)
	|				OR DocumentPaymentDetails.Document = UNDEFINED
	|			THEN DocumentPaymentDetails.Ref
	|		ELSE DocumentPaymentDetails.Document
	|	END AS Document,
	|	SUM(DocumentPaymentDetails.Amount) AS Amount
	|FROM
	|	DocumentPaymentDetails AS DocumentPaymentDetails
	|WHERE
	|	DocumentPaymentDetails.Operation = VALUE(Enum.BankPaymentOperations.Supplier)
```

BankPayment chỉ post các bản ghi khi `Paid` = true (`WHERE … AND BankPayment.Paid` trong `DocumentHeader`), period = `PaymentDate`. `CashVoucher` có logic SupplierBalance gần như y hệt (chỉ khác `Enum.CashVoucherOperations.Supplier`, period = `Date`).

### 9.2. Cấn trừ: CommonForm.SelectAdvances

Command `SelectAdvances` (&AtClient) trên form SupplierInvoice: báo lỗi nếu chưa chọn `Supplier`; đưa `Object.AdvanceClearing.Unload()` vào temporary storage (`PutAdvanceClearingToStorage`, &AtServer); mở `CommonForm.SelectAdvances` với các tham số `AddressInStorage`, `InvoiceRef`, `Counterparty`, `Currency`, `ExchangeRate`, `Multiplier`, `InvoiceAmount` (= `Object.Inventory.Total("Total")`) và `IsCustomerAdvance` = False (cùng form dùng cho SalesInvoice); callback là `New CallbackDescription("SelectAdvancesOnClose", ...)`.

Khi form đóng với `DialogReturnCode.OK`, `SelectAdvancesOnClose` gọi `GetAdvanceClearingFromStorage` (&AtServer) để `Object.AdvanceClearing.Load(...)` và đặt `Modified = True`. Đây là mẫu "truyền bảng giữa hai form qua temporary storage" (xem Bài 19 về file/storage trong client-server).

Bên trong `SelectAdvances`, query số dư ứng trước (procedure `FillAdvanceBalance`, &AtServer) được viết cho virtual table `AccumulationRegister.CustomerBalance.Balance(, LiabilityType = VALUE(Enum.LiabilityTypes.Advance) AND Counterparty = &Counterparty)` rồi **thay chuỗi** sang `SupplierBalance` khi không phải khách hàng:

Nguồn: Jet — cf/CommonForms/SelectAdvances/Ext/Form/Module.bsl
```bsl
	If Not IsCustomerAdvance Then
		Query.Text = StrReplace(Query.Text, "AccumulationRegister.CustomerBalance", "AccumulationRegister.SupplierBalance");
	EndIf;
```

Logic: lấy số dư `Advance` hiện tại của nhà cung cấp (âm), **cộng bù lại** các bản ghi Advance của chính hóa đơn đang sửa (`Recorder = &Ref` — để hóa đơn đã post vẫn thấy lại khoản ứng trước nó đã cấn), trừ đi các dòng đang có trong bảng cấn trừ, giữ các chứng từ còn số dư âm (`HAVING SUM(TmpAdvanceBalance.Amount) < 0`) và đảo dấu thành số dương để hiển thị. Lệnh `FillInAdvClearing` tự phân bổ: `FillAdvClearingTable(InvoiceAmount)` lần lượt lấy từng khoản ứng trước cho tới khi đủ tổng hóa đơn (dòng cuối có thể chỉ lấy một phần, quy đổi bằng `JetClientServer.CalculateFromCurrencyToCurrency`).

Hàm quy đổi tiền tệ của Jet:

Nguồn: Jet — cf/CommonModules/JetClientServer/Ext/Module.bsl
```bsl
Function CalculateFromCurrencyToCurrency(Amount, SourceRate, SourceMultiplier, NewRate = 1, NewMultiplier = 1) Export
	// ...
	Return Round((Amount * SourceRate * NewMultiplier) / (NewRate * SourceMultiplier), 2);
	
EndFunction
```

Trong form SupplierInvoice: sửa `Amount` (presentation currency) → `AmountCur` = `CalculateFromCurrencyToCurrency(Amount, 1, 1, ExchangeRate, Multiplier)`; sửa `AmountCur` → `Amount` = `CalculateFromCurrencyToCurrency(AmountCur, ExchangeRate, Multiplier)`.

`FilterCriteria.RelatedDocuments` có `Document.SupplierInvoice.TabularSection.AdvanceClearing.Attribute.Document` trong content — nên từ phiếu chi có thể xem các hóa đơn đã cấn trừ nó.

---

## 10. Report Purchases và SupplierBalance (DCS)

Cả hai report chỉ có `MainDataCompositionSchema`, không có object module hay form riêng — form report chuẩn của SSL Report options hiển thị (xem Bài 18, Bài 21). Mô tả biến thể được khai báo trong `ReportsOptionsOverridable` (module SSL Overridable, đoạn code Jet).

### 10.1. Report.Purchases

Nguồn: Jet — cf/Reports/Purchases/Templates/MainDataCompositionSchema/Ext/Template.xml
```bsl
SELECT
	PurchasesTurnovers.Recorder AS Recorder,
	// ...
	PurchasesTurnovers.DayPeriod AS DayPeriod,
	// ...
	PurchasesTurnovers.MonthPeriod AS MonthPeriod,
	// ...
	PurchasesTurnovers.Counterparty AS Counterparty,
	PurchasesTurnovers.Product AS Product,
	PurchasesTurnovers.PurchaseDocument AS PurchaseDocument,
	PurchasesTurnovers.QuantityTurnover AS Quantity,
	PurchasesTurnovers.AmountTurnover AS Amount,
	PurchasesTurnovers.VATAmountTurnover AS VATAmount,
	PurchasesTurnovers.AmountTurnover + PurchasesTurnovers.VATAmountTurnover AS Total
FROM
	AccumulationRegister.Purchases.Turnovers(, , Auto, ) AS PurchasesTurnovers
```

- Virtual table `Turnovers` với Periodicity = `Auto` → DCS cung cấp mọi trường kỳ (`DayPeriod`, `MonthPeriod`…) để người dùng nhóm theo thời gian.
- Parameters: `ItmPeriod` (StandardPeriod, tiêu đề "Accounting period"); `BeginOfPeriod` = `&ItmPeriod.StartDate`, `EndOfPeriod` = `&ItmPeriod.EndDate` (ẩn với người dùng — `useRestriction` = true). [suy luận] DCS tự đẩy hai parameter này vào tham số kỳ của virtual table vì trùng tên chuẩn.
- Resources: `Sum(Quantity)`, `Sum(Amount)`, `Sum(VATAmount)`, `Sum(Total)`.
- Variants: `Default` — biểu đồ + nhóm `Product` / `Counterparty` → `Product` → `PurchaseDocument`, filter `Counterparty`, `Product`; `PurchasesContext` — nhóm `Product` → `PurchaseDocument`, dùng khi mở từ form counterparty (bị tắt khỏi report panel: `OptionSettings.Enabled = False`).

Lệnh mở theo ngữ cảnh `OpenPurchasesReport` (cf/Reports/Purchases/Commands/OpenPurchasesReport/Ext/CommandModule.bsl) gọi `OpenForm("Report.Purchases.Form", ...)` với `VariantKey` = `"PurchasesContext"`, `Filter` = `New Structure("Counterparty", CommandParameter)`, `GenerateOnOpen` = True, `ReportOptionsCommandsVisibility` = False.

### 10.2. Report.SupplierBalance

Nguồn: Jet — cf/Reports/SupplierBalance/Templates/MainDataCompositionSchema/Ext/Template.xml
```bsl
SELECT
	SupplierBalance.LiabilityType AS LiabilityType,
	SupplierBalance.Counterparty AS Counterparty,
	SupplierBalance.Document AS Document,
	CASE
		WHEN SupplierBalance.LiabilityType = VALUE(Enum.LiabilityTypes.Liability)
			THEN SupplierBalance.AmountBalance
		ELSE 0
	END AS AmountLiability,
	CASE
		WHEN SupplierBalance.LiabilityType = VALUE(Enum.LiabilityTypes.Advance)
			THEN -SupplierBalance.AmountBalance
		ELSE 0
	END AS AmountAdvance,
	CASE
		WHEN SupplierBalance.LiabilityType = VALUE(Enum.LiabilityTypes.Liability)
			THEN SupplierBalance.AmountBalance
		ELSE 0
	END - CASE
		WHEN SupplierBalance.LiabilityType = VALUE(Enum.LiabilityTypes.Advance)
			THEN -SupplierBalance.AmountBalance
		ELSE 0
	END AS AmountTotal
FROM
	AccumulationRegister.SupplierBalance.Balance AS SupplierBalance
```

- Một virtual table `Balance`, tách thành hai cột: `AmountLiability` (còn phải trả) và `AmountAdvance` (đã ứng trước, đảo dấu thành dương); `AmountTotal` = phải trả − ứng trước = công nợ ròng.
- Parameter `Period` (Date) với expression: nếu trống thì `DateTime(3999,12,31)`, ngược lại `DATEADD(EndOfPeriod(&Period, "Day"), "Second", 1)` — tức số dư **tính đến hết ngày** được chọn. [suy luận] Cộng thêm 1 giây vì virtual table Balance không tính các bản ghi đúng tại thời điểm truyền vào (xem Bài 11 về Boundary). Đây là chi tiết hay để giải thích PointInTime/Boundary (Bài 11).
- Resources: `Sum(AmountLiability)`, `Sum(AmountAdvance)`, `Sum(AmountTotal)`. Variants: `SupplierBalance` (nhóm `Counterparty` → `Document`, kèm biểu đồ theo `Counterparty`), `SupplierBalanceContext` (mở từ form counterparty, command `OpenSupplierBalanceReport` y hệt `OpenPurchasesReport` với `VariantKey` = `"SupplierBalanceContext"`).

---

## 11. Các điểm tích hợp SSL

SupplierInvoice là ví dụ đầy đủ về cách một document Jet "cắm" vào SSL. Phân biệt rõ: **code của Jet** là các procedure trong manager module/form module và đoạn thêm vào module `*Overridable`; **module SSL được gọi** là `PrintManagement`, `PropertyManager`, `AttachableCommands`, `ImportDataFromFileClient`, `Interactions`…

| Subsystem SSL | Phía SupplierInvoice (code Jet) |
|---|---|
| Print (Bài 22) | Manager module: `OnDefinePrintSettings` (`Settings.OnAddPrintCommands = True`), `AddPrintCommands` thêm lệnh `PrintManager = "PrintManagement"`, `Id = "Document.SupplierInvoice.PF_MXL_GoodsReceivedNote"`, Presentation "Goods received note"; `PrintManagementOverridable.OnDefinePrintSettings` có `Settings.PrintObjects.Add(Documents.SupplierInvoice)` |
| Properties (thuộc tính bổ sung) | Tabular section `AdditionalAttributes`; form gọi `PropertyManager.OnCreateAtServer` với `ItemForPlacementName` = `"GroupAdditionalAttributes"`; `PropertyManagerOverridable` thêm set `"Document_SupplierInvoice"` |
| Attachable commands | Form gọi `AttachableCommands.OnCreateAtServer`, `Attachable_ExecuteCommand`… |
| Interactions | Manager module `GetContacts`, `ContactsQueryText` (contact = `Supplier`); `InteractionsClientServerOverridable` thêm `"DocumentRef.SupplierInvoice"` vào SubjectsTypes; list form `ListDragCheck`/`ListDrag` |
| Message templates | Manager module có các procedure rỗng `OnPrepareMessageTemplate`, `OnCreateMessage`… |
| Import data from file | Template `LoadingFromFile` (cột Product, Quantity, Price, VAT rate); manager module `MapDataToImport`, `FillInListOfAmbiguities` chuyển tiếp sang module Jet `ImportDataFromFileJet`; form `ImportInventoryFromFileAtServer` thêm dòng và gọi `InventoryTabularSectionClientServer.CalculateAmount` |
| Attached files | Catalog `SupplierInvoiceAttachedFiles` |


---

## 12. Những điểm đáng chú ý trong code

Dùng các điểm này khi ra câu hỏi thảo luận hoặc review code — đừng trình bày như "lỗi" chắc chắn của Jet nếu chưa chạy thử.

1. **SupplierInvoice không có trong `Sequence.InventoryCostRecalculation`** (cf/Sequences/InventoryCostRecalculation.xml chỉ có `InventoryTransfer`, `InventoryWriteOff`, `SalesInvoice`), dù SupplierInvoice ghi Receipt vào `InventoryCost`. [suy luận] Nếu nhập lùi ngày một hóa đơn mua sau khi đã có phiếu xuất, ranh giới sequence không tự lùi lại, nên giá vốn bình quân của các phiếu xuất sau đó có thể không được đánh dấu cần tính lại. Nên kiểm thử trên dữ liệu thật.
2. **Purchases ghi cả dịch vụ, kho thì không**: `TablePurchases` lấy từ `DocumentInventory` (mọi dòng), còn `InventoryInWarehouses`/`InventoryCost` lấy từ `ProductTable` (chỉ `ProductTypes.Inventory`). Hợp lý về nghiệp vụ, là ví dụ tốt về "không phải dòng nào cũng vào mọi register".
3. **Kiểm tra cấn trừ chỉ ở form** (`FillCheckProcessingAtServer`), object module không có `FillCheckProcessing` — ghi bằng code hoặc import sẽ bỏ qua kiểm tra này.
4. **Round-trip server khi sửa ô**: `CalculateVATAmountAndTotal` chạy trên client nhưng gọi `JetServerCall.GetVATRateValue` mỗi lần.
5. **`GetExemptFromVATRate` có thể tạo dữ liệu** (`CreateItem` … `Write()` trong privileged mode) ngay trong lúc người dùng tích "Exempt from VAT" — tác dụng phụ ít gặp trong một hàm "Get…".
6. **Thay chuỗi trong query** (`StrReplace(Query.Text, "AccumulationRegister.CustomerBalance", "AccumulationRegister.SupplierBalance")`) để tái dùng một form cho cả khách hàng và nhà cung cấp — gọn nhưng dễ vỡ nếu đổi tên register.
7. **Đổi tiền tệ không quy đổi lại giá dòng hàng**: `CurrencyOnChange` chỉ cập nhật `ExchangeRate`/`Multiplier`.
8. **Role `UsePurchases` không có quyền** đọc `Warehouses`, `VATRates` — cần kết hợp role (mục 1).

---

## 13. Gợi ý mở rộng cho nhóm sinh viên phân hệ Mua hàng

> Các mục dưới đây là **gợi ý** đề tài, không có trong Jet. Mỗi gợi ý nêu object/module Jet sẽ chạm tới để nhóm tự thiết kế. Theo nguyên tắc dạy ở SKILL.md, khi sinh viên làm đề tài thì **gợi ý trước**, không đưa lời giải đầy đủ ngay. Có thể làm trực tiếp trong configuration (bản học tập) hoặc dưới dạng **configuration extension** Purpose **Add-on** (xem bài Extensions) — cách sau là upgrade-safe customization, giữ Jet gốc không đổi.

### Gợi ý 1 — Document PurchaseOrder (đơn đặt hàng nhà cung cấp) trước SupplierInvoice

- **Bài toán:** theo dõi hàng đã đặt nhưng chưa về; tạo hóa đơn từ đơn hàng.
- **Object mới:** `Document.PurchaseOrder` (header giống SupplierInvoice: `Supplier` với Choice parameter `Filter.Supplier` = true, `Warehouse`, `Currency`, `ExchangeRate`, `Multiplier`; tabular section `Inventory` cùng cấu trúc để dùng lại `InventoryTabularSectionClientServer`); `AccumulationRegister.OrdersToSuppliers` (Balance; dimension `Counterparty`, `Product`, `PurchaseOrder`; resource `Quantity`).
- **Chạm vào Jet:** `SupplierInvoice.xml` — thêm `BasedOn` = PurchaseOrder, thêm attribute `PurchaseOrder`, thêm register vào Register records; `SupplierInvoice/Ext/ObjectModule.bsl` `Filling` — xử lý `TypeOf(FillingData) = Type("DocumentRef.PurchaseOrder")` theo mẫu `BankPayment.Filling` (mục 9.1); `SupplierInvoice/Ext/ManagerModule.bsl` `InitializeDocumentData` — thêm query trả bảng Expense cho `OrdersToSuppliers`; `PostingManagement` — thêm `ReflectOrdersToSuppliers` theo mẫu `ReflectPurchases`; `Subsystems/Purchases` (content), `Role.UsePurchases`.
- **Liên hệ bài:** Bài 11 (Generation, Balance register), Bài 12 (kiểm tra không nhận quá số đặt).

### Gợi ý 2 — Document SupplierReturn (trả hàng cho nhà cung cấp)

- **Bài toán:** trả lại hàng lỗi; giảm tồn kho và giảm công nợ phải trả.
- **Object mới:** `Document.SupplierReturn`, `BasedOn` = SupplierInvoice, attribute `SupplierInvoice` (hóa đơn gốc).
- **Register records:** `InventoryInWarehouses` Expense (gọi `AccumulationRegisters.InventoryInWarehouses.NegativeBalanceControl` như SupplierInvoice); `InventoryCost` Expense; `SupplierBalance` Expense `Liability` với Document = hóa đơn gốc; `Purchases` với số lượng/số tiền âm (Turnovers register — xem mục 8.1).
- **Chạm vào Jet:** `PostingManagement` (dùng lại các `Reflect*` sẵn có), `AccumulationRegister.SupplierBalance` (thêm type `DocumentRef.SupplierReturn` vào dimension `Document`, thêm recorder), `AccumulationRegister.Purchases` (cân nhắc thêm type vào `PurchaseDocument` hoặc ghi theo hóa đơn gốc), `Sequence.InventoryCostRecalculation` (thêm document vì nó ghi Expense giá vốn — so với cách SalesInvoice tính giá vốn trong `Documents/SalesInvoice/Ext/ManagerModule.bsl`).
- **Liên hệ bài:** Bài 11, Bài 12 (DataLock), Bài 16 (thứ tự event).

### Gợi ý 3 — Tự điền giá mua theo bảng giá nhà cung cấp

- **Bài toán:** SupplierInvoice hiện bắt nhập giá tay (mục 5.2), trong khi Jet đã có `InformationRegister.Prices` (dimension `PriceType`, `Product`; resource `Price`), `Catalog.PriceTypes` và attribute `Counterparties.PriceType`.
- **Chạm vào Jet:** thêm attribute `PriceType` vào `SupplierInvoice`; trong form, khi đổi `Supplier` lấy `PriceType` của nhà cung cấp (mẫu: `GetCustomerPriceType` và `CustomerOnChange` trong form SalesInvoice); trong `GetProductData` thêm lời gọi `PriceManagementServerCall.GetProductPriceByPriceType(DataStructure)` như SalesInvoice; có thể dùng `PriceManagementClient.RefillTabularSectionPricesByPriceType`.
- **Mở rộng thêm:** khi post SupplierInvoice, ghi giá mua mới nhất vào `Prices` (Information register periodic, `SliceLast` — Bài 12).

### Gợi ý 4 — Hạn thanh toán và báo cáo tuổi nợ phải trả

- **Bài toán:** biết hóa đơn nào sắp/đã quá hạn trả.
- **Chạm vào Jet:** thêm attribute `DueDate` (hoặc `PaymentTermDays` trong `Counterparties`, điền `DueDate` trong `Filling`/form); report mới (hoặc variant mới của `Report.SupplierBalance`) với query DCS nối `AccumulationRegister.SupplierBalance.Balance` (lọc `LiabilityType = Liability`) với `Document.SupplierInvoice` qua dimension `Document` để lấy `DueDate`, tính số ngày quá hạn bằng `DATEDIFF`, nhóm theo khoảng tuổi nợ bằng `CASE`. Đăng ký variant trong `ReportsOptionsOverridable`, thêm report vào `Subsystems/Purchases` và `Role.UsePurchases`.
- **Liên hệ bài:** Bài 10 (CASE, join), Bài 18 (DCS parameters, resources), Bài 21 (Report options).

### Gợi ý 5 — Đưa kiểm tra cấn trừ ứng trước xuống object module

- **Bài toán:** chuyển kiểm tra "tổng hóa đơn < tổng cấn trừ" (mục 5.5) từ form xuống `FillCheckProcessing` của object module để áp dụng cả khi ghi bằng code/import; thêm kiểm tra khoản cấn trừ không vượt số dư ứng trước thật trong `SupplierBalance` (dùng lại logic query của `CommonForm.SelectAdvances`).
- **Chạm vào Jet:** `SupplierInvoice/Ext/ObjectModule.bsl`, form module (bỏ trùng lặp), có thể đưa query số dư ứng trước ra một common module server để form và object module dùng chung.
- **Làm bằng extension:** đề tài phù hợp để thực hành `&Before`/`&After` trên `FillCheckProcessing` hoặc `&ChangeAndValidate` (ngoài giáo trình — hãy kiểm tra lại trong Syntax assistant cho cú pháp cụ thể).

### Gợi ý 6 — Chi phí mua hàng phân bổ vào giá vốn (landed cost)

- **Bài toán:** phí vận chuyển/hải quan cộng vào giá trị hàng nhập.
- **Chạm vào Jet:** document mới (ví dụ `AdditionalPurchaseCosts`) tham chiếu SupplierInvoice, phân bổ chi phí theo `Amount` từng dòng `Inventory`; ghi Receipt chỉ resource `Amount` (Quantity = 0) vào `InventoryCost`; ghi `SupplierBalance` Receipt `Liability` cho nhà cung cấp dịch vụ vận chuyển. Phải xem xét `Sequence.InventoryCostRecalculation` và `DataProcessor.InventoryCostRecalculation` (cùng vấn đề ở mục 12, điểm 1).
- **Mức độ:** khó nhất trong các gợi ý — dành cho nhóm mạnh.


---

# § jet-sales

# 1C:Jet — Phân hệ Bán hàng (Subsystem Sales)

Khi nào đọc file này: sinh viên/nhóm thực hành mở rộng phân hệ **Sales** của Jet, hỏi về `SalesInvoice`, giá bán (`PriceTypes`, `Prices`), giá vốn hàng bán, công nợ khách hàng, các report bán hàng, hoặc print form hóa đơn bán.

Nguồn: Jet (repo 1Ci-Company/Jet, nhánh `community`, commit 80884de, config 1.0.2.1). Mọi đoạn code dưới đây chép nguyên văn; `// ...` là chỗ lược bớt. Phần ghi "[suy luận]" là diễn giải của người viết, không có trong code.

## Mục lục

1. [Thành phần của Subsystem Sales](#1-thành-phần-của-subsystem-sales)
2. [Catalog PriceTypes và Counterparties (phía khách hàng)](#2-catalog-pricetypes-và-counterparties-phía-khách-hàng)
3. [Giá bán: InformationRegister Prices — ghi giá và đọc giá](#3-giá-bán-informationregister-prices--ghi-giá-và-đọc-giá)
4. [Document SalesInvoice — metadata](#4-document-salesinvoice--metadata)
5. [SalesInvoice — form: tự điền giá, tính Amount / VAT](#5-salesinvoice--form-tự-điền-giá-tính-amount--vat)
6. [SalesInvoice — Posting](#6-salesinvoice--posting)
7. [Giá vốn hàng bán — average costing](#7-giá-vốn-hàng-bán--average-costing)
8. [AccumulationRegister Sales và CustomerBalance](#8-accumulationregister-sales-và-customerbalance)
9. [Các report của phân hệ (DCS)](#9-các-report-của-phân-hệ-dcs)
10. [Print form SalesInvoice qua SSL Print](#10-print-form-salesinvoice-qua-ssl-print)
11. [Gợi ý mở rộng cho nhóm sinh viên phân hệ Bán hàng](#11-gợi-ý-mở-rộng-cho-nhóm-sinh-viên-phân-hệ-bán-hàng)
12. [Những điểm lạ / cần lưu ý trong code Jet](#12-những-điểm-lạ--cần-lưu-ý-trong-code-jet)

---

## 1. Thành phần của Subsystem Sales

Subsystem `Sales` (xem Bài 9 về Subsystem) có 3 subsystem con: `Sales`, `Catalogs`, `Pricing`. Nội dung `<Content>` theo từng file XML:

| Subsystem | Member objects |
|---|---|
| `Sales` (gốc) — `cf/Subsystems/Sales.xml` | `AccumulationRegister.Sales`, `AccumulationRegister.CustomerBalance`, `Report.Sales`, `Report.CustomerBalance`, `Report.ProfitOnSales`, `Report.PriceList`, `Role.UseSales`, `CommonCommand.AdditionalReportsSales`, `CommonCommand.AdditionalDataProcessorsSales`, `CommonCommand.ReportPanelSales` |
| `Sales.Sales` — `cf/Subsystems/Sales/Subsystems/Sales.xml` | `Document.SalesInvoice` |
| `Sales.Catalogs` — `.../Subsystems/Catalogs.xml` | `Catalog.Counterparties`, `Catalog.Products`, `Catalog.Units` |
| `Sales.Pricing` — `.../Subsystems/Pricing.xml` | `Catalog.PriceTypes`, `DataProcessor.PricesSetup`, `CommonModule.PriceManagementServerCall`, `InformationRegister.Prices` |

Lưu ý:
- `Catalog.Counterparties` cũng nằm trong `Purchases/Subsystems/Catalogs.xml` — một catalog có thể thuộc nhiều subsystem. Nhóm Bán và nhóm Mua **dùng chung** Counterparties, `Products`.
- `Document.SalesInvoice` còn ghi vào `AccumulationRegister.InventoryInWarehouses` và `InventoryCost` — hai register này **không** thuộc Subsystem Sales (thuộc phân hệ kho). Khi sửa posting của SalesInvoice, nhóm Bán chạm vào dữ liệu của nhóm Kho.
- `Document.PricesSetupAuxiliary` không nằm trong Sales mà trong `Subsystems/InternalSubsystem.xml` (subsystem ẩn) — xem mục 3.
- `CommonCommand.ReportPanelSales` chỉ gọi `ReportsOptionsClient.ShowReportBar("Sales", ExecutionParameters)` (module SSL).

### Role UseSales

`Role.UseSales` (`cf/Roles/UseSales/Ext/Rights.xml`, xem Bài 20): `Document.SalesInvoice` đủ quyền (gồm Posting, UndoPosting, InteractiveChangeOfPosted); `AccumulationRegister.Sales`, `CustomerBalance` chỉ **Read, View** (register chỉ được ghi qua posting); `InformationRegister.Prices` Read/Update/Edit; các catalog `PriceTypes`, `Counterparties`, `Products`, `Units` đọc/ghi; `DataProcessor.PricesSetup` Use; `Sequence.InventoryCostRecalculation` Read/Update; 4 report của phân hệ và `Dashboard` Use. Khi thêm object mới vào phân hệ, nhớ thêm quyền vào `UseSales`, nếu không user chỉ có role này sẽ không thấy object.

---

## 2. Catalog PriceTypes và Counterparties (phía khách hàng)

### Catalog PriceTypes

Catalog rất đơn giản: không hierarchy, `CodeLength` = 0 (không có Code), `DescriptionLength` = 50. **Không có attribute riêng** nào ngoài tabular section `AdditionalAttributes` (của SSL Properties). Không có object module / manager module. Nghĩa là một "loại giá" (bán lẻ, bán buôn…) chỉ là một tên; giá cụ thể nằm ở `InformationRegister.Prices` (mục 3).

[suy luận] PriceTypes không có Currency hay cờ "giá đã gồm VAT" — giá trong `Prices` được hiểu là giá theo presentation currency, chưa gồm VAT (VAT cộng thêm trong document, xem mục 5).

### Catalog Counterparties — phần dùng cho bán hàng

Hierarchical, `CodeLength` 9, `DescriptionLength` 25. Attribute (cấp header): `Customer` (Boolean), `Supplier` (Boolean), `LegalName`, `TIN`, `PriceType` (CatalogRef.PriceTypes), `IsIndividual`. Tabular section: `AdditionalAttributes`, `ContactInformation` (của SSL ContactInformation).

Hai điểm gắn với bán hàng:

1. **Cờ `Customer`** — attribute `Customer` của `SalesInvoice` có Choice parameter `Filter.Customer = true` (trong `cf/Documents/SalesInvoice.xml`), nên khi chọn khách hàng chỉ hiện counterparty có cờ `Customer`. Command `Customers` của catalog mở list form với tham số lọc (`cf/Catalogs/Counterparties/Commands/Customers/Ext/CommandModule.bsl`: `FormParameters.Insert("Customer", True)` rồi `OpenForm("Catalog.Counterparties.ListForm", FormParameters, ...)`.)

List form đọc tham số `Customer`/`Supplier` trong `OnCreateAtServer` và đặt filter cố định cho dynamic list (`SetFilterCustomersSuppliers`, dùng `CommonClientServer.ChangeFilterItems` của SSL).

2. **`PriceType` mặc định của khách** — khi chọn khách trong `SalesInvoice`, form lấy `PriceType` của khách để điền lại giá (mục 5).

Ngoài ra, item form của Counterparties có command `Report.Sales.Command.OpenSalesReport` (panel "See also"), mở report Sales lọc theo khách — xem mục 9.

---

## 3. Giá bán: InformationRegister Prices — ghi giá và đọc giá

### Cấu trúc register

`InformationRegister.Prices` (xem Bài 12 — periodic information register):
- `InformationRegisterPeriodicity` = **Day**, `WriteMode` = **Independent** (không có recorder — không document nào post vào đây).
- Dimensions: `PriceType` (CatalogRef.PriceTypes), `Product` (CatalogRef.Products).
- Resource: `Price` (Number).
- Không có module BSL; có `RecordForm`, `ListForm`.

Vì Independent nên user có thể sửa trực tiếp qua list form của register, hoặc qua data processor `PricesSetup` (cách chính).

### Ghi giá: DataProcessor PricesSetup

Command `PricesSetup` mở form của data processor. Form có các form attribute: `PriceType`, `EffectiveDate`, `ProductPrices` (ValueTable: Product, CurrentPrice, NewPrice), `SourcePriceType`, `PriceAdjustmentMethod`, `AdjustmentPercent`, `AdjustmentAmount`… Luồng làm việc:

1. **Fill in** (`FillInProcessingAtServer`) — chọn "source price type", lấy giá hiện hành bằng `InformationRegister.Prices.SliceLast(&Period, PriceType = &PriceTypeToCopy)` làm `NewPrice`, LEFT JOIN với `SliceLast(&Period, PriceType = &PriceType)` làm `CurrentPrice`.
Ý nghĩa: có thể **sao chép** bảng giá từ loại giá khác (ví dụ lấy giá bán buôn làm gốc cho giá bán lẻ), cột `CurrentPrice` luôn là giá hiện tại của `PriceType` đích.

2. **Apply new prices** — tăng/giảm theo % hoặc số tiền (`IncByPercent`, `DecByPercent`, `IncByAmount`, `DecByAmount`), chạy hoàn toàn ở client trên `ProductPrices` (`ModifyProductPrices`), giá âm bị đưa về 0.

3. **Set** — ghi vào register bằng **RecordSet** (Bài 12). Batch query (`ResultsArray[2]`) báo sản phẩm trùng và hủy, rồi ghi các bản ghi `Price > 0` (`ResultsArray[3]`):

Nguồn: Jet — cf/DataProcessors/PricesSetup/Forms/Form/Ext/Form/Module.bsl
```bsl
	Query.SetParameter("ProductTable", ProductPrices.Unload());
	
	ResultsArray = Query.ExecuteBatch();
	// ...
	
	ResultTable = ResultsArray[3].Unload();
	If ResultTable.Count() > 0 Then
		RecordSet = InformationRegisters.Prices.CreateRecordSet();
		RecordSet.Filter.Period.Set(EffectiveDate);
		RecordSet.Filter.PriceType.Set(PriceType);
		RecordSet.Load(ResultTable);
		RecordSet.Write();
	EndIf;
```
Điểm quan trọng: filter của RecordSet chỉ có `Period` + `PriceType` (không có `Product`), nên `Write()` **thay thế toàn bộ** giá của loại giá đó tại ngày đó. Vì vậy trước khi ghi, `SetPrices` gọi `CheckPricesExist()` và hỏi user nếu ngày đó đã có giá cho sản phẩm **không có** trong danh sách ("Setting the new prices will delete them. Continue?").

Lưu ý: query truyền cả ValueTable `&ProductTable` làm nguồn dữ liệu (`FROM &ProductTable AS ProductTable`) — kỹ thuật dùng value table làm tham số query (xem Bài 10, temporary tables).

### Document PricesSetupAuxiliary — chỉ để import từ file

`Document.PricesSetupAuxiliary`: `Posting` = **Deny**, có tabular section `ProductPrices` (Product, CurrentPrice, NewPrice) và template `LoadingFromFile`. Không ai tạo document này. Nó chỉ tồn tại vì subsystem SSL `ImportDataFromFile` cần một tabular section thật (có template và manager module) để làm "khuôn" import. Form `PricesSetup` dùng nó như sau:

Nguồn: Jet — cf/DataProcessors/PricesSetup/Forms/Form/Ext/Form/Module.bsl
```bsl
&AtClient
Procedure ImportPricesFromFile(Command)
	
	ImportParameters = ImportDataFromFileClient.DataImportParameters();
	ImportParameters.FullTabularSectionName = "PricesSetupAuxiliary.ProductPrices";
	ImportParameters.Title = NStr("en = 'Import prices from file'");
	
	CallbackDescription = New CallbackDescription("ImportPricesFromFileEnd", ThisObject);
	
	ImportDataFromFileClient.ShowImportForm(ImportParameters, CallbackDescription);
	
EndProcedure
```
Manager module của `PricesSetupAuxiliary` cài đặt `MapDataToImport` (tìm `Products` theo `Description`, báo ambiguity nếu trùng tên) và `FillInListOfAmbiguities` (gọi `ImportDataFromFileJet`).

### Đọc giá: PriceManagementServerCall + PriceManagementClient

Hai common module của Jet:
- `PriceManagementServerCall` — flag Server + **ServerCall** = true (gọi được từ client, xem Bài 7/14).
- `PriceManagementClient` — flag ClientManagedApplication.

Đọc giá **một** sản phẩm:

Nguồn: Jet — cf/CommonModules/PriceManagementServerCall/Ext/Module.bsl
```bsl
Function GetProductPriceByPriceType(DataStructure) Export
	
	Price = 0;
	
	If Not (ValueIsFilled(DataStructure.Product) And ValueIsFilled(DataStructure.PriceType)) Then
		Return Price;
	EndIf;
	
	Query = New Query;
	Query.Text =
	"SELECT ALLOWED
	|	PricesSliceLast.Price * &DocumentRepetition / &DocumentRate AS Price
	|FROM
	|	InformationRegister.Prices.SliceLast(
	|			&PriceDate,
	|			PriceType = &PriceType
	|				AND Product = &Product) AS PricesSliceLast";
	
	Query.SetParameter("PriceDate",				BegOfDay(DataStructure.Date));
	Query.SetParameter("Product",				DataStructure.Product);
	Query.SetParameter("PriceType",				DataStructure.PriceType);
	Query.SetParameter("DocumentRate",			?(DataStructure.ExchangeRate = 0, 1, DataStructure.ExchangeRate));
	Query.SetParameter("DocumentRepetition",	?(DataStructure.Multiplier = 0, 1, DataStructure.Multiplier));
	
	Selection = Query.Execute().Select();
	If Selection.Next() Then
		Price = Selection.Price;
	EndIf;
	
	Return Price;
	
EndFunction
```
Giải thích:
- `SliceLast(&PriceDate, <điều kiện>)` — lát cắt cuối: giá có hiệu lực gần nhất **tính đến** ngày `&PriceDate` (Bài 12). Điều kiện filter đặt **trong tham số** virtual table, không đặt ở `WHERE` — đúng khuyến nghị hiệu năng.
- `BegOfDay(...)`: register có periodicity Day nên lấy đầu ngày của document.
- `* &DocumentRepetition / &DocumentRate`: đổi giá (presentation currency) sang tiền tệ document. Nếu document bằng ngoại tệ, rate = tỷ giá, giá được chia cho tỷ giá.
- `SELECT ALLOWED`: chỉ trả bản ghi user có quyền đọc (Bài 20).

Đọc giá **nhiều** sản phẩm cùng lúc — `GetTabularSectionPricesByPriceType`, trả về `Map` Product → Price; sản phẩm không có giá → 0 (tìm trong `PriceTable` có index theo `Product`):

Nguồn: Jet — cf/CommonModules/PriceManagementServerCall/Ext/Module.bsl
```bsl
	Query = New Query;
	Query.Text =
	"SELECT ALLOWED
	|	PricesSliceLast.Product AS Product,
	|	PricesSliceLast.Price * &DocumentRepetition / &DocumentRate AS Price
	|FROM
	|	InformationRegister.Prices.SliceLast(
	|			&PriceDate,
	|			PriceType = &PriceType
	|				AND Product IN (&ProductArray)) AS PricesSliceLast";
	// ...
	PriceTable = Query.Execute().Unload();
	PriceTable.Indexes.Add("Product");
	// ...
```

Phía client, `RefillTabularSectionPricesByPriceType` đóng gói `Date`, `PriceType`, `ExchangeRate`, `Multiplier` của document vào Structure, gom các `Product` không trùng vào `ProductArray`, gọi server **một lần**, rồi điền giá và tính lại tiền cho từng dòng:

Nguồn: Jet — cf/CommonModules/PriceManagementClient/Ext/Module.bsl
```bsl
Procedure RefillTabularSectionPricesByPriceType(Form, TabularSectionName = "Inventory") Export
	
	Object = Form.Object;
	ProductArray = New Array;
	// ...
	DataStructure.Insert("ProductArray", ProductArray);
	
	ProductPriceMap = PriceManagementServerCall.GetTabularSectionPricesByPriceType(DataStructure);
	
	For Each ProductPriceItem In ProductPriceMap Do
		
		FilterStructure = New Structure("Product", ProductPriceItem.Key);
		RowArray = Object[TabularSectionName].FindRows(FilterStructure);
		For Each Row In RowArray Do
			Row.Price = ProductPriceItem.Value;
			InventoryTabularSectionClientServer.CalculateAmount(Row);
		EndDo;
		
	EndDo;
	
EndProcedure
```
Đây là mẫu tốt để dạy "tránh gọi server trong vòng lặp" (Bài 7): một server call cho cả bảng.

---

## 4. Document SalesInvoice — metadata

Nguồn: `cf/Documents/SalesInvoice.xml`.

Thuộc tính chính của document:
- Numbering: `NumberType` String, `NumberLength` 9, `NumberPeriodicity` Year, `Autonumbering`, `CheckUnique` (Bài 4).
- `Posting` Allow, `RealTimePosting` **Deny** (không có chế độ post real-time — Bài 11), `RegisterRecordsDeletion` AutoDeleteOff, `RegisterRecordsWritingOnPost` WriteSelected.
- **Post in privileged mode** = true, **Unpost in privileged mode** = true — nhờ đó Role `UseSales` chỉ cần Read trên các register mà posting vẫn ghi được.
- Register records: `AccumulationRegister.Sales`, `CustomerBalance`, `InventoryInWarehouses`, `InventoryCost`.
- Thuộc Sequence `InventoryCostRecalculation` (mục 7).
- Là "based on" cho `CashReceipt` và `BankReceipt` (thu tiền dựa trên hóa đơn — khai báo trong `<BasedOn>` của hai document đó).

Header attributes:

| Attribute | Type | Ghi chú |
|---|---|---|
| `Customer` | CatalogRef.Counterparties | FillChecking ShowError; choice parameter `Filter.Customer = true` |
| `Warehouse` | CatalogRef.Warehouses | ShowError |
| `Currency` | CatalogRef.Currencies | ShowError |
| `ExchangeRate`, `Multiplier` | Number | tỷ giá và bội số |
| `PriceType` | CatalogRef.PriceTypes | |
| `Comment` | String | |
| `Author` | CatalogRef.Users | điền trong `Filling` |
| `Total` | Number | tổng tiền, tính trong `BeforeWrite` |
| `BankAccount` | CatalogRef.BankAccounts | `BankReceipt.Filling` đọc field này khi tạo dựa trên hóa đơn |
| `ExemptFromVAT` | Boolean | miễn VAT |

Tabular sections:
- `Inventory`: `Product`, `Quantity`, `Price`, `Amount`, `VATRate` (CatalogRef.VATRates), `VATAmount`, `Total`.
- `AdvanceClearing` (cấn trừ tiền khách trả trước): `Document` (DocumentRef.CashReceipt / BankReceipt), `Amount`, `AmountCur`.
- `AdditionalAttributes` (SSL Properties).

Forms: `DocumentForm`, `ListForm`, `ChoiceForm`. Templates: `PF_MXL_SalesInvoice` (SpreadsheetDocument), `PrintData` (DataCompositionSchema), `LoadingFromFile`.

### Object module

Nguồn: Jet — cf/Documents/SalesInvoice/Ext/ObjectModule.bsl
```bsl
Procedure Filling(FillingData, FillingText, StandardProcessing)
	
	ObjectFillingJet.FillDocument(ThisObject, FillingData);
	
EndProcedure
```
Nguồn: Jet — cf/Documents/SalesInvoice/Ext/ObjectModule.bsl
```bsl
Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	
	If DataExchange.Load Then
		Return;
	EndIf;
	
	Total = Inventory.Total("Total");
	
EndProcedure
```
`ObjectFillingJet.FillDocument` (module của Jet) điền `Currency` = presentation currency (tỷ giá 1/1) nếu chưa có, và `Author` = `Users.AuthorizedUser()` (SSL).

---

## 5. SalesInvoice — form: tự điền giá, tính Amount / VAT

Nguồn chung: `cf/Documents/SalesInvoice/Forms/DocumentForm/Ext/Form/Module.bsl`. Form chỉ có 2 form attribute: `Object` và `PresentationCurrency`. Bảng sự kiện được gắn trong Form.xml:

| Item | Event | Handler |
|---|---|---|
| Customer | OnChange | `CustomerOnChange` |
| PriceType | OnChange | `PriceTypeOnChange` |
| Currency | OnChange | `CurrencyOnChange` |
| ExemptFromVAT | OnChange | `ExemptFromVATOnChange` |
| Inventory.Product / Quantity / Price / Amount / VATRate | OnChange | `InventoryProductOnChange`, `InventoryQuantityOnChange`, `InventoryPriceOnChange`, `InventoryAmountOnChange`, `InventoryVATRateOnChange` |
| AdvanceClearing.Amount / AmountCur | OnChange | `AdvanceClearingAmountOnChange`, `AdvanceClearingAmountCurOnChange` |

### Chọn khách → lấy PriceType của khách → điền lại giá

Nguồn: Jet — cf/Documents/SalesInvoice/Forms/DocumentForm/Ext/Form/Module.bsl
```bsl
&AtClient
Procedure CustomerOnChange(Item)
	
	PriceType = GetCustomerPriceType(Object.Customer);
	If ValueIsFilled(PriceType) Then
		Object.PriceType = PriceType;
		PriceManagementClient.RefillTabularSectionPricesByPriceType(ThisObject);
	EndIf;
	
EndProcedure

&AtClient
Procedure PriceTypeOnChange(Item)
	
	If ValueIsFilled(Object.PriceType) Then
		PriceManagementClient.RefillTabularSectionPricesByPriceType(ThisObject);
	EndIf;
	
EndProcedure
```
`GetCustomerPriceType` là `&AtServerNoContext`, trả về `Common.ObjectAttributeValue(Customer, "PriceType")` (hàm SSL) — non-context vì chỉ đọc một attribute của reference, không cần dữ liệu form (Bài 7).
`&AtServerNoContext` vì chỉ cần đọc một attribute của reference, không cần dữ liệu form (Bài 7 — non-context call nhẹ hơn). `Common.ObjectAttributeValue` là hàm SSL.

### Chọn sản phẩm → lấy VATRate + giá

`InventoryProductOnChange` (&AtClient) đóng gói `Product`, `PriceType`, `Date`, `ExchangeRate`, `Multiplier`, `ExemptFromVAT` vào `DataStructure`, gọi `GetProductData(DataStructure)`, rồi `FillPropertyValues(CurrentData, DataStructure)` và `InventoryTabularSectionClientServer.CalculateAmount(CurrentData)`.

Nguồn: Jet — cf/Documents/SalesInvoice/Forms/DocumentForm/Ext/Form/Module.bsl
```bsl
&AtServerNoContext
Procedure GetProductData(DataStructure)
	
	ProductAttributes = New Structure;
	ProductAttributes.Insert("VATRate", Catalogs.VATRates.EmptyRef());
	
	If ValueIsFilled(DataStructure.Product) Then
		ProductAttributes = Common.ObjectAttributesValues(DataStructure.Product, "VATRate");
	EndIf;
	
	If DataStructure.Property("ExemptFromVAT") And DataStructure.ExemptFromVAT Then
		DataStructure.Insert("VATRate", Catalogs.VATRates.GetExemptFromVATRate());
	Else
		DataStructure.Insert("VATRate", ProductAttributes.VATRate);
	EndIf;
	
	DataStructure.Insert("Quantity", 1);
	
	Price = PriceManagementServerCall.GetProductPriceByPriceType(DataStructure);
	DataStructure.Insert("Price", Price);
	
EndProcedure
```
Mẫu "đóng gói tham số vào Structure → 1 server call → `FillPropertyValues` vào dòng hiện tại" là mẫu chuẩn nên dạy lại. Lưu ý `Quantity` được đặt = 1 mỗi khi đổi sản phẩm.

### Tính Amount, VAT, Total — InventoryTabularSectionClientServer

Module của Jet, flag Client + Server (không ServerCall) — chạy được ở cả hai phía (Bài 14), dùng chung cho `SalesInvoice` và `SupplierInvoice`:

Nguồn: Jet — cf/CommonModules/InventoryTabularSectionClientServer/Ext/Module.bsl
```bsl
Procedure CalculateAmount(TabSectionRow) Export
	
	TabSectionRow.Amount = TabSectionRow.Quantity * TabSectionRow.Price;
	CalculateVATAmountAndTotal(TabSectionRow);
	
EndProcedure
```
Nguồn: Jet — cf/CommonModules/InventoryTabularSectionClientServer/Ext/Module.bsl
```bsl
Procedure CalculateVATAmountAndTotal(TabSectionRow) Export
	
	VATRate = JetServerCall.GetVATRateValue(TabSectionRow.VATRate);
	TabSectionRow.VATAmount = TabSectionRow.Amount * VATRate / 100;
	TabSectionRow.Total = TabSectionRow.Amount + TabSectionRow.VATAmount;
	
EndProcedure
```
Công thức: `Amount = Quantity × Price`; `VATAmount = Amount × Rate / 100`; `Total = Amount + VATAmount` — tức giá **chưa gồm** VAT. Giá trị `Rate` lấy qua `JetServerCall.GetVATRateValue` → `JetCached.GetVATRateValue` (module có reuse return values — Bài 14), nên gọi lặp với cùng VATRate không tốn thêm server call trong phiên.

Các handler còn lại: `InventoryAmountOnChange` tính ngược `Price = Round(Amount / Quantity, 2)` (khi `Quantity <> 0`) rồi gọi `CalculateVATAmountAndTotal`. `Quantity`/`Price` đổi → `CalculateAmount`; `VATRate` đổi → `CalculateVATAmountAndTotal`.

### Miễn VAT

`ExemptFromVATOnChange` gọi `FillVATRateByVATExemption()` (&AtServer): nếu miễn VAT thì mọi dòng nhận `Catalogs.VATRates.GetExemptFromVATRate()`, `VATAmount = 0`, `Total = Amount`; nếu bỏ miễn thì lấy lại `InventoryRow.Product.VATRate` và gọi `CalculateVATAmountAndTotal`.
`FormManagement()` (client) ẩn các cột `InventoryVATRate`, `InventoryVATAmount`, `InventoryTotal`… khi `ExemptFromVAT`, và khóa `ExchangeRate`/`Multiplier` khi `Currency` = presentation currency.

### Kiểm tra trước khi ghi và cấn trừ tạm ứng

Nguồn: Jet — cf/Documents/SalesInvoice/Forms/DocumentForm/Ext/Form/Module.bsl
```bsl
&AtServer
Procedure FillCheckProcessingAtServer(Cancel, CheckedAttributes)
	
	If Object.Inventory.Total("Total") < Object.AdvanceClearing.Total("AmountCur") Then
		MessageText = NStr("en = 'The invoice amount is less than the clearing amount.'");
		Common.MessageToUser(MessageText,,,, Cancel);
	EndIf;
	// ...
```
Command `SelectAdvances` mở `CommonForm.SelectAdvances` (dùng chung với SupplierInvoice, tham số `IsCustomerAdvance = True`) và trao đổi bảng `AdvanceClearing` qua temporary storage (`PutToTempStorage` / `GetFromTempStorage` — Bài 19).

[suy luận] Kiểm tra này nằm ở **form** (`FillCheckProcessingAtServer`), không ở object module — nên khi ghi document bằng code (không qua form) thì kiểm tra không chạy. Đây là điểm sinh viên có thể cải tiến (chuyển sang `FillCheckProcessing` của object module — Bài 12).

---

## 6. SalesInvoice — Posting

### Posting handler

Nguồn: Jet — cf/Documents/SalesInvoice/Ext/ObjectModule.bsl
```bsl
Procedure Posting(Cancel, PostingMode)
	
	// Initialization of additional properties for document posting.
	PostingManagement.InitializeAdditionalPropertiesForPosting(Ref, AdditionalProperties);
	
	// Document data initialization.
	Documents.SalesInvoice.InitializeDocumentData(Ref, AdditionalProperties);
	
	// Preparation of records sets.
	PostingManagement.PrepareRecordSetsForWriting(ThisObject);
	
	// Movements on the Sales register
	PostingManagement.ReflectSales(AdditionalProperties, RegisterRecords, Cancel);
	
	// Movements on the InventoryInWarehouses register
	PostingManagement.ReflectInventoryInWarehouses(AdditionalProperties, RegisterRecords, Cancel);
	
	// Movements on the CustomerBalance register
	PostingManagement.ReflectCustomerBalance(AdditionalProperties, RegisterRecords, Cancel);
	
	// Movements on the InventoryCost register
	PostingManagement.ReflectInventoryCost(AdditionalProperties, RegisterRecords, Cancel);
	
	// Writing of the records sets.
	PostingManagement.WriteRecordSets(ThisObject);
	
	// Negative balance control
	AccumulationRegisters.InventoryInWarehouses.NegativeBalanceControl(Ref, AdditionalProperties, Cancel);
	
EndProcedure
```
`UndoPosting` gọi `InitializeAdditionalPropertiesForPosting` → `PrepareRecordSetsForWriting` → `WriteRecordSets` (ghi record set rỗng) → `NegativeBalanceControl`.

Kiến trúc posting của Jet (khác cách "duyệt tabular section, `RegisterRecords.X.Add()`" của Bài 11):

1. `PostingManagement.InitializeAdditionalPropertiesForPosting` tạo trong `AdditionalProperties` một Structure `TableForRegisterRecords`, một Structure `ForPosting` chứa `TempTablesManager`, và `DocumentMetadata`.
2. **Manager module** `InitializeDocumentData` chạy **một batch query** sinh sẵn bảng bản ghi cho từng register, cất vào `TableForRegisterRecords`.
3. `PrepareRecordSetsForWriting` xóa record set cũ và đánh dấu `Write = True` cho register mà document đã từng có bản ghi (để ghi đè thành rỗng nếu lần này không còn).
4. `ReflectXxx` chỉ `Load()` bảng có sẵn vào `RegisterRecords.Xxx`.
5. `WriteRecordSets` ghi các record set có `Write = True`, truyền `ForPosting` vào `RecordSet.AdditionalProperties` (để record set module của `InventoryInWarehouses` dùng chung TempTablesManager).
6. Kiểm soát âm kho sau khi ghi.

Nguồn: Jet — cf/CommonModules/PostingManagement/Ext/Module.bsl
```bsl
Procedure ReflectSales(AdditionalProperties, RegisterRecords, Cancel) Export
	
	TableSales = AdditionalProperties.TableForRegisterRecords.TableSales;
	
	If Cancel Or TableSales.Count() = 0 Then
		Return;
	EndIf;
	
	SalesRecord = RegisterRecords.Sales;
	SalesRecord.Write = True;
	SalesRecord.Load(TableSales);
	
EndProcedure
```
`Load()` cần tên cột của bảng trùng tên dimension/resource/standard field của register (`RecordType`, `Period`…) (ngoài giáo trình — hãy kiểm tra lại trong Syntax assistant) — vì vậy các query trong `InitializeDocumentData` đặt alias đúng tên field register.

### InitializeDocumentData — batch query

Nguồn: Jet — cf/Documents/SalesInvoice/Ext/ManagerModule.bsl
```bsl
Procedure InitializeDocumentData(SalesInvoiceRef, AdditionalProperties) Export
	
	DocumentObject = SalesInvoiceRef.GetObject();
	
	DataLock = New DataLock;
	LockItem = DataLock.Add("AccumulationRegister.InventoryCost");
	LockItem.Mode = DataLockMode.Exclusive;
	LockItem.DataSource = DocumentObject.Inventory;
	LockItem.UseFromDataSource("Product", "Product");
	LockItem.SetValue("Warehouse", DocumentObject.Warehouse);
	DataLock.Lock();
	
	Query = New Query;
	Query.Text =
	"SELECT
	|	SalesInvoice.Ref AS Ref,
	// ...
	|INTO DocumentHeader
	// ...
	|SELECT
	|	DocumentHeader.Date AS Period,
	|	DocumentHeader.Customer AS Counterparty,
	|	DocumentHeader.Warehouse AS Warehouse,
	|	DocumentHeader.Ref AS Document,
	|	SalesInvoiceInventory.Product AS Product,
	|	SalesInvoiceInventory.Quantity AS Quantity,
	|	SalesInvoiceInventory.Amount * DocumentHeader.ExchangeRate / DocumentHeader.Multiplier AS Amount,
	|	SalesInvoiceInventory.VATAmount * DocumentHeader.ExchangeRate / DocumentHeader.Multiplier AS VATAmount,
	|	SalesInvoiceInventory.Total * DocumentHeader.ExchangeRate / DocumentHeader.Multiplier AS Total
	|INTO DocumentInventory
	|FROM
	|	DocumentHeader AS DocumentHeader
	|		INNER JOIN Document.SalesInvoice.Inventory AS SalesInvoiceInventory
	|		ON DocumentHeader.Ref = SalesInvoiceInventory.Ref
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	DocumentInventory.Period AS Period,
	|	DocumentInventory.Warehouse AS Warehouse,
	|	DocumentInventory.Product AS Product,
	|	SUM(DocumentInventory.Quantity) AS Quantity
	|INTO ProductTable
	|FROM
	|	DocumentInventory AS DocumentInventory
	|		INNER JOIN Catalog.Products AS Products
	|		ON DocumentInventory.Product = Products.Ref
	|			AND (Products.ProductType = VALUE(Enum.ProductTypes.Inventory))
	|
	|GROUP BY
	|	DocumentInventory.Product,
	|	DocumentInventory.Period,
	|	DocumentInventory.Warehouse
	|;
	// ...
```
Các bước của batch (đánh số theo chỉ số `QueryResult[i]`):

| # | Kết quả | Dùng làm |
|---|---|---|
| 0 | `DocumentHeader` (temp) | header |
| 1 | `DocumentInventory` (temp) | dòng hàng, **đã quy đổi sang presentation currency** (`* ExchangeRate / Multiplier`) |
| 2 | `ProductTable` (temp) | chỉ hàng `ProductType = Inventory` (loại `Service` không trừ kho, không tính giá vốn) |
| 3 | `DocumentAdvanceClearing` (temp) | dòng cấn trừ tạm ứng |
| 4 | `InventoryCostBalance` (temp) | tồn giá vốn (mục 7) |
| 5 | `InventoryCostTable` (temp) | tồn giá vốn đã cộng gộp |
| 6 | bảng `Sales` | → `TableSales` |
| 7 | bảng `InventoryInWarehouses` | → `TableInventoryInWarehouses` |
| 8 | bảng `CustomerBalance` | → `TableCustomerBalance` |
| 9 | bảng `InventoryCost` | → `TableInventoryCost` |

Nguồn: Jet — cf/Documents/SalesInvoice/Ext/ManagerModule.bsl
```bsl
	Query.SetParameter("Ref", SalesInvoiceRef);
	Query.SetParameter("PointInTime", New Boundary(DocumentObject.PointInTime(), BoundaryType.Including));
	
	QueryResult = Query.ExecuteBatch();
	
	AdditionalProperties.TableForRegisterRecords.Insert("TableSales", QueryResult[6].Unload());
	AdditionalProperties.TableForRegisterRecords.Insert("TableInventoryInWarehouses", QueryResult[7].Unload());
	AdditionalProperties.TableForRegisterRecords.Insert("TableCustomerBalance", QueryResult[8].Unload());
	AdditionalProperties.TableForRegisterRecords.Insert("TableInventoryCost", QueryResult[9].Unload());
```
Nếu thêm/bớt một query trong batch, **mọi chỉ số `QueryResult[i]` phía sau phải sửa theo** — lỗi rất hay gặp khi mở rộng.

### Bản ghi Sales và InventoryInWarehouses

Nguồn: Jet — cf/Documents/SalesInvoice/Ext/ManagerModule.bsl
```bsl
	|SELECT
	|	DocumentInventory.Period AS Period,
	|	DocumentInventory.Counterparty AS Counterparty,
	|	DocumentInventory.Document AS SalesDocument,
	|	DocumentInventory.Product AS Product,
	|	SUM(DocumentInventory.Quantity) AS Quantity,
	|	SUM(DocumentInventory.Amount) AS Amount,
	|	SUM(DocumentInventory.VATAmount) AS VATAmount
	|FROM
	|	DocumentInventory AS DocumentInventory
	|
	|GROUP BY
	|	DocumentInventory.Product,
	|	DocumentInventory.Counterparty,
	|	DocumentInventory.Period,
	|	DocumentInventory.Document
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	VALUE(AccumulationRecordType.Expense) AS RecordType,
	|	ProductTable.Period AS Period,
	|	ProductTable.Warehouse AS Warehouse,
	|	ProductTable.Product AS Product,
	|	ProductTable.Quantity AS Quantity
	|FROM
	|	ProductTable AS ProductTable
	|;
```
`Sales` là register Turnovers nên không có `RecordType`. `Sales` nhận **cả dịch vụ** (lấy từ `DocumentInventory`), còn `InventoryInWarehouses` chỉ nhận hàng tồn kho (từ `ProductTable`) với `Expense`.

### Bản ghi CustomerBalance

Nguồn: Jet — cf/Documents/SalesInvoice/Ext/ManagerModule.bsl
```bsl
	|SELECT
	|	VALUE(AccumulationRecordType.Receipt) AS RecordType,
	|	DocumentInventory.Period AS Period,
	|	VALUE(Enum.LiabilityTypes.Liability) AS LiabilityType,
	|	DocumentInventory.Counterparty AS Counterparty,
	|	DocumentInventory.Document AS Document,
	|	SUM(DocumentInventory.Total) AS Amount
	|FROM
	|	DocumentInventory AS DocumentInventory
	|
	|GROUP BY
	|	DocumentInventory.Document,
	|	DocumentInventory.Period,
	|	DocumentInventory.Counterparty
	|
	|UNION ALL
	|
	|SELECT
	|	VALUE(AccumulationRecordType.Receipt),
	|	DocumentAdvanceClearing.Period,
	|	VALUE(Enum.LiabilityTypes.Advance),
	|	DocumentAdvanceClearing.Counterparty,
	|	DocumentAdvanceClearing.Document,
	|	SUM(DocumentAdvanceClearing.Amount)
	|FROM
	|	DocumentAdvanceClearing AS DocumentAdvanceClearing
	// ...
	// ...
```
Ba phần:
1. `Receipt` / `Liability` / Document = hóa đơn, Amount = `Total` (gồm VAT): khách nợ thêm.
2. `Receipt` / `Advance` / Document = phiếu thu tạm ứng: "trả lại" số dư tạm ứng (tạm ứng được ghi âm bởi phiếu thu, xem mục 8).
3. (phần thứ ba của UNION, đã lược) `Expense` / `Liability` / Document = `InvoiceDocument` (hóa đơn): giảm nợ của hóa đơn đúng bằng số tạm ứng đã cấn trừ.

---

## 7. Giá vốn hàng bán — average costing

`AccumulationRegister.InventoryCost` (Balance): dimensions `Product`, `Warehouse`; resources `Quantity`, `Amount`. `SupplierInvoice` ghi `Receipt` với `Amount` = giá mua (đã quy đổi); `SalesInvoice` ghi `Expense` với giá vốn tính theo **bình quân gia quyền tại thời điểm bán** (moving average theo Product + Warehouse).

### Bước 1 — khóa dữ liệu

Đầu `InitializeDocumentData` đặt managed lock `Exclusive` trên `AccumulationRegister.InventoryCost` theo từng `Product` của tabular section và `Warehouse` của document (code ở mục 6). Mục đích [suy luận]: hai hóa đơn bán cùng sản phẩm/kho post đồng thời không đọc cùng một số tồn để tính giá vốn.

### Bước 2 — đọc tồn giá vốn tại thời điểm document

Nguồn: Jet — cf/Documents/SalesInvoice/Ext/ManagerModule.bsl
```bsl
	|SELECT
	|	InventoryCostBalance.Product AS Product,
	|	InventoryCostBalance.Warehouse AS Warehouse,
	|	InventoryCostBalance.QuantityBalance AS Quantity,
	|	InventoryCostBalance.AmountBalance AS Amount
	|INTO InventoryCostBalance
	|FROM
	|	AccumulationRegister.InventoryCost.Balance(
	|			&PointInTime,
	|			(Product, Warehouse) IN
	|				(SELECT
	|					ProductTable.Product,
	|					ProductTable.Warehouse
	|				FROM
	|					ProductTable AS ProductTable)) AS InventoryCostBalance
	|
	|UNION ALL
	|
	|SELECT
	|	InventoryCost.Product,
	|	InventoryCost.Warehouse,
	|	InventoryCost.Quantity,
	|	InventoryCost.Amount
	|FROM
	|	AccumulationRegister.InventoryCost AS InventoryCost
	|WHERE
	|	InventoryCost.Recorder = &Ref
	|;
```
- `&PointInTime` = `New Boundary(DocumentObject.PointInTime(), BoundaryType.Including)` — tồn **bao gồm** cả bản ghi của chính document (Bài 11, PointInTime/Boundary).
- Vì Including, khi **re-post** một hóa đơn đã post, tồn đã bị trừ bởi bản ghi cũ của chính nó. Phần `UNION ALL ... WHERE InventoryCost.Recorder = &Ref` cộng ngược lại các bản ghi cũ (Expense lưu số dương trong bảng vật lý) để có tồn "trước khi bán".

  [suy luận] Cộng trực tiếp `Quantity`/`Amount` của bảng vật lý chỉ đúng vì mọi bản ghi `InventoryCost` của SalesInvoice đều là `Expense`.
- Điều kiện `(Product, Warehouse) IN (SELECT ...)` đặt trong tham số virtual table để chỉ đọc đúng cặp cần thiết.

### Bước 3 — gộp và tính giá vốn

Nguồn: Jet — cf/Documents/SalesInvoice/Ext/ManagerModule.bsl
```bsl
	|SELECT
	|	VALUE(AccumulationRecordType.Expense) AS RecordType,
	|	ProductTable.Period AS Period,
	|	ProductTable.Product AS Product,
	|	ProductTable.Warehouse AS Warehouse,
	|	ProductTable.Quantity AS Quantity,
	|	CASE
	|		WHEN ISNULL(InventoryCostTable.Quantity, 0) = 0
	|			THEN 0
	|		WHEN ProductTable.Quantity = InventoryCostTable.Quantity
	|			THEN InventoryCostTable.Amount
	|		ELSE CAST(InventoryCostTable.Amount * ProductTable.Quantity / InventoryCostTable.Quantity AS NUMBER(15, 2))
	|	END AS Amount
	|FROM
	|	ProductTable AS ProductTable
	|		LEFT JOIN InventoryCostTable AS InventoryCostTable
	|		ON ProductTable.Product = InventoryCostTable.Product
	|			AND ProductTable.Warehouse = InventoryCostTable.Warehouse";
```
Công thức: **Giá vốn = Amount tồn × Số lượng bán / Số lượng tồn**.
- Không có tồn → giá vốn 0 (tránh chia cho 0).
- Bán hết toàn bộ tồn → lấy nguyên `Amount` tồn (tránh lệch làm tròn để lại số dư "rác").
- Ngược lại làm tròn 2 chữ số bằng `CAST(... AS NUMBER(15, 2))`.

### Sequence InventoryCostRecalculation

Giá vốn tính lúc post phụ thuộc thứ tự thời gian. Nếu user post/sửa một chứng từ **lùi ngày**, giá vốn của các hóa đơn sau đó bị sai. Jet dùng metadata **Sequence** `InventoryCostRecalculation` (ngoài giáo trình — hãy kiểm tra lại trong Syntax assistant) với:
- Documents: `InventoryTransfer`, `InventoryWriteOff`, `SalesInvoice`; RegisterRecords: `InventoryCost`; `MoveBoundaryOnPosting` = Move.

DataProcessor `InventoryCostRecalculation` (thuộc phân hệ kho) so sánh biên của sequence (`GetBound()`) với bản ghi `Expense` cuối cùng và gọi `Sequences.InventoryCostRecalculation.Restore()` — [suy luận] re-post lại các chứng từ sau biên theo thứ tự thời gian.
Data processor này cũng thêm mục "It may be necessary to recalculate inventory costs" vào To-do list của SSL (`OnFillToDoList` trong manager module của nó).

### Kiểm soát âm kho

`AccumulationRegisters.InventoryInWarehouses.NegativeBalanceControl` (manager module register `InventoryInWarehouses`, thuộc phân hệ kho) dùng temp table `InventoryInWarehousesChange` mà **record set module** của register tạo ra trong `BeforeWrite`/`OnWrite` (qua `AdditionalProperties.ForPosting.TempTablesManager`), rồi join với `InventoryInWarehouses.Balance(, )` lọc `QuantityBalance < 0` và báo "Insufficient quantity on %1" với `Cancel = True`.
Lưu ý: kiểm soát này chỉ trên `InventoryInWarehouses` (số lượng), không kiểm `InventoryCost`.

---

## 8. AccumulationRegister Sales và CustomerBalance

Cả hai không có module BSL (không có thư mục `cf/AccumulationRegisters/Sales/`, `.../CustomerBalance/`).

### AccumulationRegister Sales — kind **Turnovers**

| Loại | Field | Type |
|---|---|---|
| Dimension | `Counterparty` | CatalogRef.Counterparties |
| Dimension | `Product` | CatalogRef.Products |
| Dimension | `SalesDocument` | DocumentRef.SalesInvoice |
| Resource | `Quantity`, `Amount`, `VATAmount` | Number |

Chỉ `SalesInvoice` ghi vào. `Amount` = doanh thu chưa VAT, đã quy đổi presentation currency. [suy luận] Dimension `SalesDocument` chỉ có type `DocumentRef.SalesInvoice` — nếu thêm document trả hàng hay bán lẻ ghi vào register này, phải mở rộng type của dimension.

### AccumulationRegister CustomerBalance — kind **Balance**

| Loại | Field | Type |
|---|---|---|
| Dimension | `LiabilityType` | EnumRef.LiabilityTypes (`Liability`, `Advance`) |
| Dimension | `Counterparty` | CatalogRef.Counterparties |
| Dimension | `Document` | DocumentRef.SalesInvoice, CashReceipt, BankReceipt |
| Resource | `Amount` | Number |

Ai ghi vào:
- `SalesInvoice`: như mục 6.
- `CashReceipt` / `BankReceipt` (phân hệ CashManagement) với operation `Customer`: `Expense`; nếu dòng thanh toán không chỉ định hóa đơn (`Document` rỗng) thì `LiabilityType` = `Advance` và `Document` = chính phiếu thu (`cf/Documents/CashReceipt/Ext/ManagerModule.bsl`).
Quy ước dấu [suy luận từ code + report]: số dư `Liability` dương = khách còn nợ; số dư `Advance` **âm** = khách đã trả trước (vì phiếu thu ghi `Expense` mà không có `Receipt` tương ứng). Report CustomerBalance đổi dấu `-AmountBalance` cho cột tạm ứng (mục 9).

---

## 9. Các report của phân hệ (DCS)

Cả 4 report chỉ có `MainDataCompositionSchema` (không form, không module — Bài 18). Mô tả report option được đặt trong `ReportsOptionsOverridable.CustomizeReportsOptions` (module SSL overridable, code Jet), bằng `ReportsOptions.OptionDetails(Settings, Metadata.Reports.<Report>, "<Option>")`. Các option `...Context` bị `Enabled = False`; [suy luận] chúng chỉ dùng khi mở từ command trên form khác (xem `OpenSalesReport` bên dưới), nên ẩn khỏi report panel.

### Report Sales

Settings variants: `Default`, `SalesContext`, `SalesByDate` (biểu đồ theo ngày), `SalesByProduct` (biểu đồ theo sản phẩm). Tham số `BeginOfPeriod` = `&ItmPeriod.StartDate`, `EndOfPeriod` = `&ItmPeriod.EndDate`. Total fields: `Sum(...)` cho Quantity, Amount, VATAmount, Total.

Nguồn: Jet — cf/Reports/Sales/Templates/MainDataCompositionSchema/Ext/Template.xml
```bsl
SELECT
	SalesTurnovers.Recorder AS Recorder,
	SalesTurnovers.SecondPeriod AS SecondPeriod,
	// ...
	SalesTurnovers.YearPeriod AS YearPeriod,
	SalesTurnovers.Counterparty AS Counterparty,
	SalesTurnovers.Product AS Product,
	SalesTurnovers.SalesDocument AS SalesDocument,
	SalesTurnovers.QuantityTurnover AS Quantity,
	SalesTurnovers.AmountTurnover AS Amount,
	SalesTurnovers.VATAmountTurnover AS VATAmount,
	SalesTurnovers.AmountTurnover + SalesTurnovers.VATAmountTurnover AS Total
FROM
	AccumulationRegister.Sales.Turnovers(, , Auto, ) AS SalesTurnovers
```
`Turnovers(, , Auto, )`: để trống Begin/End để DCS tự gắn tham số `BeginOfPeriod`/`EndOfPeriod`; periodicity `Auto` cho phép DCS chọn nhóm theo ngày/tháng… tùy field user dùng (các field `DayPeriod`, `MonthPeriod`…).

Command `OpenSalesReport` (parameter type `CatalogRef.Counterparties`, group `FormNavigationPanelSeeAlso`) mở form report với `VariantKey` = `"SalesContext"`, `Filter` = `New Structure("Counterparty", CommandParameter)`, `GenerateOnOpen` = True.
`Report.CustomerBalance` có command `OpenCustomerBalanceReport` y hệt (option `CustomerBalanceContext`).

### Report PriceList

Tham số `Period`, `PriceType`; total `Min(Price)`.

Nguồn: Jet — cf/Reports/PriceList/Templates/MainDataCompositionSchema/Ext/Template.xml
```bsl
SELECT
	PricesSliceLast.Product AS Product,
	PricesSliceLast.Price AS Price
FROM
	InformationRegister.Prices.SliceLast(&Period, PriceType = &PriceType) AS PricesSliceLast
```

### Report ProfitOnSales

Ghép giá vốn (Expense của `InventoryCost` do `SalesInvoice` ghi) với doanh thu (`Sales`):

Nguồn: Jet — cf/Reports/ProfitOnSales/Templates/MainDataCompositionSchema/Ext/Template.xml
```bsl
SELECT ALLOWED
	InventoryCostTurnovers.Recorder AS Recorder,
	InventoryCostTurnovers.SecondPeriod AS SecondPeriod,
	// ...
	InventoryCostTurnovers.YearPeriod AS YearPeriod,
	InventoryCostTurnovers.Product AS Product,
	InventoryCostTurnovers.AmountExpense AS CostAmount,
	0 AS RevenueAmount
FROM
	AccumulationRegister.InventoryCost.Turnovers(, , Auto, ) AS InventoryCostTurnovers
WHERE
	InventoryCostTurnovers.Recorder REFS Document.SalesInvoice

UNION ALL

SELECT
	SalesTurnovers.Recorder,
	SalesTurnovers.SecondPeriod,
	// ...
	SalesTurnovers.YearPeriod,
	SalesTurnovers.Product,
	0,
	SalesTurnovers.AmountTurnover + SalesTurnovers.VATAmountTurnover
FROM
	AccumulationRegister.Sales.Turnovers(, , Auto, ) AS SalesTurnovers
```
(`// ...` là chỗ lược các field period giống hệt nhau.) Calculated field `Profit` = `RevenueAmount - CostAmount`; totals `Sum` cho cả ba.

Lưu ý: `REFS Document.SalesInvoice` (Bài 10) lọc riêng giá vốn do bán hàng, loại trừ Expense của `InventoryWriteOff`/`InventoryTransfer`. Xem thêm mục 12 về việc `RevenueAmount` **gồm VAT**.

### Report CustomerBalance

Tham số `Period` có expression: rỗng → `DateTime(3999,12,31)`, ngược lại → `DATEADD(EndOfPeriod(&Period, "Day"), "Second", 1)` (lấy số dư đến hết ngày được chọn). Variants: `CustomerBalance`, `CustomerBalanceContext`.

Nguồn: Jet — cf/Reports/CustomerBalance/Templates/MainDataCompositionSchema/Ext/Template.xml
```bsl
SELECT
	CustomerBalance.LiabilityType AS LiabilityType,
	CustomerBalance.Counterparty AS Counterparty,
	CustomerBalance.Document AS Document,
	CASE
		WHEN CustomerBalance.LiabilityType = VALUE(Enum.LiabilityTypes.Liability)
			THEN CustomerBalance.AmountBalance
		ELSE 0
	END AS AmountLiability,
	CASE
		WHEN CustomerBalance.LiabilityType = VALUE(Enum.LiabilityTypes.Advance)
			THEN -CustomerBalance.AmountBalance
		ELSE 0
	END AS AmountAdvance,
	CASE
		WHEN CustomerBalance.LiabilityType = VALUE(Enum.LiabilityTypes.Liability)
			THEN CustomerBalance.AmountBalance
		ELSE 0
	END - CASE
		WHEN CustomerBalance.LiabilityType = VALUE(Enum.LiabilityTypes.Advance)
			THEN -CustomerBalance.AmountBalance
		ELSE 0
	END AS AmountTotal
FROM
	AccumulationRegister.CustomerBalance.Balance AS CustomerBalance
```
`AmountTotal` = nợ − tạm ứng = công nợ ròng của khách.

---

## 10. Print form SalesInvoice qua SSL Print

Print form dùng **subsystem Print của SSL** (Bài 22), nhưng kiểu "template + PrintData", **không có procedure `Print` riêng** trong manager module. Ba mảnh ghép:

**(1) Đăng ký object in** trong module SSL overridable `PrintManagementOverridable.OnDefinePrintSettings` (code Jet): `Settings.PrintObjects.Add(Documents.SalesInvoice);` (cùng các document khác của Jet).


**(2) Manager module** khai báo print command, với `PrintManager = "PrintManagement"` (tức SSL tự in) và `Id` = đường dẫn đầy đủ tới template:

Nguồn: Jet — cf/Documents/SalesInvoice/Ext/ManagerModule.bsl
```bsl
// StandardSubsystems.Print
// ...
Procedure OnDefinePrintSettings(Settings) Export
	
	Settings.OnAddPrintCommands = True;
	
EndProcedure
// ...
Procedure AddPrintCommands(PrintCommands) Export
	
	PrintCommand = PrintCommands.Add();
	PrintCommand.PrintManager = "PrintManagement";
	PrintCommand.Id = "Document.SalesInvoice.PF_MXL_SalesInvoice";
	PrintCommand.Presentation = NStr("en = 'Sales invoice'");
	
EndProcedure

// End StandardSubsystems.Print
```

**(3) Hai template**:
- `PF_MXL_SalesInvoice` (SpreadsheetDocument) — chứa text với tham số trong ngoặc vuông: `Invoice #[Number] date [Date]`, `[Company.LegalName]`, `[Customer.LegalName]`, `[Warehouse]`, `[Inventory.LineNumber]`, `[Inventory.Product]`, `[Inventory.Quantity]`, `[Inventory.Price]`, `[Inventory.Amount]`, `[Inventory.VATAmount]`, `[Inventory.Total]`, `[Total]`, `[CommonAttributes.CurrentUser]`, `[CommonAttributes.CurrentDate]`.
- `PrintData` (DataCompositionSchema) — cung cấp các field đó. SSL tìm template tên `"PrintData"` của object (`PrintManagement`, hàm `FieldsSourceDataCompositionSchemes`: `MetadataObject.Templates.Find("PrintData")`). Query của nó:

Nguồn: Jet — cf/Documents/SalesInvoice/Templates/PrintData/Ext/Template.xml
```bsl
SELECT
	SalesInvoice.Ref AS Ref,
	SalesInvoice.Number AS Number,
	SalesInvoice.Date AS Date,
	VALUE(Catalog.Companies.MainCompany) AS Company,
	SalesInvoice.Customer AS Customer,
	SalesInvoice.Warehouse AS Warehouse,
	// ...
	SalesInvoice.Total AS Total,
	SalesInvoice.Inventory.(
		LineNumber AS LineNumber,
		Product AS Product,
		Quantity AS Quantity,
		// ...
		Total AS Total
	) AS Inventory
FROM
	Document.SalesInvoice AS SalesInvoice
```
`Company` lấy từ predefined `Catalog.Companies.MainCompany` (Jet chỉ có một công ty). Tham số dạng `[Customer.LegalName]` là truy cập attribute qua dấu chấm của field reference.

Phía form: print command hiện trên form nhờ khối `// StandardSubsystems.AttachableCommands` (`AttachableCommands.OnCreateAtServer`, `Attachable_ExecuteCommand`…) trong `DocumentForm` và `ListForm` — đúng như quy trình Bài 22.

[suy luận] Vì layout nằm trong template + PrintData, user có thể sửa mẫu in bằng trình chỉnh template của SSL mà không cần developer; muốn thêm field (ví dụ địa chỉ khách) thì thêm vào query `PrintData` rồi đặt `[...]` trong template.

---

## 11. Gợi ý mở rộng cho nhóm sinh viên phân hệ Bán hàng

Các mục dưới đây là **gợi ý** (không có trong Jet), bám vào object/module có thật để sinh viên biết bắt đầu từ đâu. Cân nhắc làm bằng **Configuration extension** (Purpose = Customization hoặc Add-on — upgrade-safe customization, xem bài Extensions) nếu nhóm muốn giữ nguyên cấu hình gốc của Jet.

### Gợi ý 1 — Document SalesOrder (đơn đặt hàng của khách)

- Tạo `Document.SalesOrder` với header giống `SalesInvoice` (`Customer`, `Warehouse`, `Currency`, `ExchangeRate`, `Multiplier`, `PriceType`) và tabular section `Inventory` cùng tên cột → **tái dùng nguyên** `PriceManagementClient.RefillTabularSectionPricesByPriceType` (tham số `TabularSectionName` mặc định "Inventory") và `InventoryTabularSectionClientServer`.
- Thêm `Document.SalesOrder` vào `<BasedOn>` của `SalesInvoice`, viết nhánh `TypeOf(FillingData) = Type("DocumentRef.SalesOrder")` trong `Filling` của `SalesInvoice` (mẫu có sẵn: `Filling` của `CashReceipt` khi `FillingData` là `DocumentRef.SalesInvoice`). Giữ lời gọi `ObjectFillingJet.FillDocument`.
- Nâng cao: AccumulationRegister `SalesOrders` (Balance: `SalesOrder`, `Product`; resource `Quantity`) — SalesOrder ghi Receipt, SalesInvoice ghi Expense. Khi đó phải thêm attribute `SalesOrder` vào `SalesInvoice`, thêm register vào RegisterRecords, thêm một query trong `InitializeDocumentData` (**sửa lại chỉ số `QueryResult[i]`**), thêm `ReflectSalesOrders` vào `PostingManagement`.
- Nhớ: thêm vào Subsystem `Sales.Sales`, Role `UseSales`, Sequence nếu có ghi `InventoryCost` (SalesOrder thì không).

### Gợi ý 2 — Document CustomerReturn (khách trả hàng)

- Header: `Customer`, `Warehouse`, `Currency`…, thêm attribute `SalesInvoice` (DocumentRef.SalesInvoice). Based on `SalesInvoice`.
- Posting theo đúng kiến trúc `PostingManagement`: `Sales` ghi số **âm** (register Turnovers), `InventoryInWarehouses` `Receipt`, `CustomerBalance` `Expense` / `Liability` theo hóa đơn gốc.
- `InventoryCost` `Receipt` với giá vốn lấy từ bản ghi `Expense` của hóa đơn gốc (query `AccumulationRegister.InventoryCost` `WHERE Recorder = &SalesInvoice`), không lấy giá bán.
- Phải mở rộng type của dimension `Sales.SalesDocument` và `CustomerBalance.Document`; thêm document vào Sequence `InventoryCostRecalculation`; xem lại report `ProfitOnSales` (đang lọc `REFS Document.SalesInvoice`).

### Gợi ý 3 — Chiết khấu (discount) theo dòng

- Thêm cột `DiscountPercent`, `DiscountAmount` vào tabular section `Inventory` của `SalesInvoice`.
- Không sửa thẳng `InventoryTabularSectionClientServer.CalculateAmount` (đang dùng chung với `SupplierInvoice`); thay vào đó viết hàm riêng, hoặc trong extension dùng `&Around` trên `CalculateAmount` có kiểm tra cột tồn tại.
- Cập nhật `InventoryAmountOnChange` (tính ngược `Price` hiện chưa tính chiết khấu), query `PrintData` + template `PF_MXL_SalesInvoice`, và có thể thêm resource `DiscountAmount` vào register `Sales` để report `Sales` thống kê.
- Nâng cao: chiết khấu mặc định theo khách — attribute `DiscountPercent` trên `Counterparties`, đọc trong `CustomerOnChange` giống `GetCustomerPriceType`.

### Gợi ý 4 — Hạn mức công nợ (credit limit) cho khách

- Thêm attribute `CreditLimit` (Number) vào `Catalog.Counterparties`.
- Trong `Posting` của `SalesInvoice`, sau `WriteRecordSets`, viết thủ tục kiểm tra (đặt trong manager module của `CustomerBalance` hoặc module mới), theo mẫu `InventoryInWarehouses.NegativeBalanceControl`: đọc `AccumulationRegister.CustomerBalance.Balance(, Counterparty = &Customer)` và set `Cancel = True` kèm `Common.MessageToUser` nếu vượt hạn mức.
- Lưu ý: `NegativeBalanceControl` chỉ chạy khi `AdditionalProperties.ForPosting.IsInventoryInWarehousesChange` = True — cờ này do `OnWrite` trong `InventoryInWarehouses/Ext/RecordSetModule.bsl` đặt. Kiểm tra hạn mức chỉ chép vị trí gọi và cách báo lỗi, không chép điều kiện này (CustomerBalance không có record set module, nên chép nguyên thì kiểm tra không bao giờ chạy).
- Thảo luận: có nên trừ số dư `Advance` (âm) khỏi nợ không — xem quy ước dấu ở mục 8.

### Gợi ý 5 — Giá theo tiền tệ / giá đã gồm VAT trên PriceTypes

- Thêm attribute `PriceIncludesVAT` (Boolean) và/hoặc `Currency` cho `Catalog.PriceTypes` (hiện chưa có attribute nào).
- Sửa `PriceManagementServerCall.GetProductPriceByPriceType` và `GetTabularSectionPricesByPriceType` để quy đổi đúng; `InventoryTabularSectionClientServer.CalculateVATAmountAndTotal` phải tách VAT ra khỏi giá khi `PriceIncludesVAT`.
- Cập nhật report `PriceList` (thêm cột tiền tệ) và form `DataProcessor.PricesSetup`.

### Gợi ý 6 — Report bán hàng theo nhân viên / hoặc thêm cột lợi nhuận chưa VAT

- `SalesInvoice` đã có `Author`. Thêm dimension `Manager` (CatalogRef.Users) vào register `Sales`, thêm vào query bảng `Sales` trong `InitializeDocumentData`, rồi thêm field vào DCS của report `Sales` và một settings variant mới; đăng ký option trong `ReportsOptionsOverridable.CustomizeReportsOptions`.
- Hoặc bài nhỏ hơn: trong report `ProfitOnSales` thêm field doanh thu chưa VAT (`SalesTurnovers.AmountTurnover`) để so sánh với `RevenueAmount` hiện tại (xem mục 12).
- Sau khi thêm dimension vào register đã có dữ liệu, phải re-post các `SalesInvoice` cũ.

---

## 12. Những điểm lạ / cần lưu ý trong code Jet

Khi sinh viên đọc code, nên chỉ ra các điểm sau (đừng chép lại mà không hiểu):

1. **ProfitOnSales tính doanh thu gồm VAT**: `RevenueAmount` = `AmountTurnover + VATAmountTurnover`, trong khi `CostAmount` lấy từ `InventoryCost` (SupplierInvoice ghi `Amount` — giá chưa VAT). Như vậy `Profit` bao gồm cả thuế VAT phải nộp. [suy luận] Về kế toán, lợi nhuận gộp thường so sánh doanh thu **chưa VAT** với giá vốn.
2. **ProfitOnSales: doanh thu dịch vụ có, giá vốn dịch vụ không** — `Sales` nhận cả dòng `Service`, còn `InventoryCost` chỉ nhận `ProductType = Inventory`. Điều này hợp lý (dịch vụ không có giá vốn kho) nhưng cần biết khi đọc report.
3. **Kiểm tra "invoice amount < clearing amount" chỉ ở form** (`FillCheckProcessingAtServer`), không ở object module.
4. **Thay đổi `Date` của document không tự điền lại giá** — không có handler `DateOnChange` trong form; giá chỉ được lấy lại khi đổi `Customer`, `PriceType` hoặc `Product`. Tương tự, `CurrencyOnChange` cập nhật tỷ giá nhưng **không** quy đổi lại `Price` các dòng đã có.
5. Trong `SalesInvoice.xml`, attribute `ExchangeRate`/`Multiplier` có FillChecking `DontCheck`; nếu bằng 0 thì query posting `* ExchangeRate / Multiplier` sẽ chia cho 0 hoặc ra 0. `ObjectFillingJet.AddCurrency` và `GetExchangeRateData` luôn điền 1/1 khi là presentation currency nên bình thường không xảy ra.
6. Hằng ngữ trong form `PricesSetup`: chuỗi `"Effective date is requred."` viết sai chính tả (requred) — có trong nguồn, không phải lỗi chép.


---

# § jet-warehouse

# 1C:Jet — Phân hệ Kho (Subsystem Warehouses)

Khi nào đọc file này: khi sinh viên làm việc với phân hệ Kho của 1C:Jet — hỏi về Catalog Warehouses/Products/Units, ba Document InventoryIncrease / InventoryWriteOff / InventoryTransfer, hai Accumulation register InventoryInWarehouses / InventoryCost, kiểm soát tồn âm, report StockStatement / AvailableStock, hoặc khi nhóm "Kho" cần ý tưởng mở rộng.

Phiên bản nguồn: Jet repo `github.com/1Ci-Company/Jet`, nhánh `community`, commit 80884de, configuration version 1.0.2.1, compatibility 8.3.24. Mọi đường dẫn `cf/...` là bản dump configuration ra file.

## Mục lục

1. [Thành phần của subsystem Warehouses](#1-thành-phần-của-subsystem-warehouses)
2. [Catalogs: Warehouses, Products, Units](#2-catalogs-warehouses-products-units)
3. [Ba Document kho: cấu trúc chung](#3-ba-document-kho-cấu-trúc-chung)
4. [Mẫu Posting của Jet (object module + PostingManagement)](#4-mẫu-posting-của-jet)
5. [InitializeDocumentData của từng Document](#5-initializedocumentdata-của-từng-document)
6. [Accumulation registers InventoryInWarehouses và InventoryCost](#6-accumulation-registers)
7. [Kiểm soát tồn âm (NegativeBalanceControl)](#7-kiểm-soát-tồn-âm)
8. [Sequence InventoryCostRecalculation và Data processor tính lại giá vốn](#8-sequence-và-data-processor-tính-lại-giá-vốn)
9. [Forms của Document](#9-forms-của-document)
10. [Common module InventoryTabularSectionClientServer](#10-common-module-inventorytabularsectionclientserver)
11. [Reports: StockStatement, AvailableStock](#11-reports)
12. [Print forms, Role, các điểm tích hợp SSL](#12-print-forms-role-và-tích-hợp-ssl)
13. [Những điểm cần lưu ý khi đọc code](#13-những-điểm-cần-lưu-ý)
14. [Gợi ý mở rộng cho nhóm sinh viên phân hệ Kho](#14-gợi-ý-mở-rộng-cho-nhóm-sinh-viên-phân-hệ-kho)

---

## 1. Thành phần của subsystem Warehouses

Subsystem `Warehouses` (xem Bài 9 về Subsystem) có `<Content>` trực tiếp và hai subsystem con.

Nguồn: Jet — cf/Subsystems/Warehouses.xml, cf/Subsystems/Warehouses/Subsystems/*.xml

| Vị trí | Object |
|---|---|
| Warehouses (trực tiếp) | AccumulationRegister.InventoryInWarehouses, AccumulationRegister.InventoryCost, Report.AvailableStock, Report.StockStatement, DataProcessor.InventoryCostRecalculation, Sequence.InventoryCostRecalculation, Role.UseWarehouses, CommonCommand.AdditionalReportsWarehouses, CommonCommand.AdditionalDataProcessorsWarehouses, CommonCommand.ReportPanelWarehouses |
| Warehouses → Catalogs | Catalog.Units, Catalog.Warehouses, Catalog.Products |
| Warehouses → Warehouse | Document.InventoryIncrease, Document.InventoryTransfer, Document.InventoryWriteOff |

Ghi chú:
- Ba CommonCommand `AdditionalReportsWarehouses`, `AdditionalDataProcessorsWarehouses`, `ReportPanelWarehouses` là các lệnh gắn với SSL (Additional reports and data processors, Report options — xem Bài 21).
- Ngoài ba Document kho, **SalesInvoice** và **SupplierInvoice** (thuộc phân hệ Sales/Purchases) cũng có `RegisterRecords` gồm `InventoryInWarehouses` và `InventoryCost` — tức hai register kho được ghi bởi 5 Document (xem mục 6).
- Wiki Features.md mô tả phần kho: "Added **Warehouses catalog** with negative balance control", "Inventory increase (for initial balances)", "Inventory write-off", "Inventory transfer", "Added **Warehouse** field to sales and purchase documents".

## 2. Catalogs: Warehouses, Products, Units

Nguồn: Jet — cf/Catalogs/Warehouses.xml, cf/Catalogs/Products.xml, cf/Catalogs/Units.xml

| Catalog | Thuộc tính chính |
|---|---|
| **Warehouses** | CodeLength 9 (String, Autonumbering), DescriptionLength 50, không Hierarchical. Không có attribute riêng; có tabular section `AdditionalAttributes` (SSL Properties) và `ContactInformation` (SSL Contacts). Forms: ItemForm, ListForm, ChoiceForm |
| **Products** | CodeLength 9, DescriptionLength 100, **Hierarchical**. Attributes: `DetailedDescription` (String), `ProductType` (EnumRef.ProductTypes, FillChecking ShowError, FillValue `Inventory`), `Unit` (CatalogRef.Units, FillChecking ShowError), `VATRate` (CatalogRef.VATRates) |
| **Units** | CodeLength 3 (String, không Autonumbering), DescriptionLength 25. Không có form và module riêng trong dump |

Enum `ProductTypes` có hai giá trị: `Inventory`, `Service`.

Form item của Products khóa field `Unit` sau khi sản phẩm đã được ghi: `LockUnitChanges(ObjectRef)` đặt `Items.Unit.ReadOnly = Not ObjectRef.IsEmpty();`, được gọi trong `OnCreateAtServer` và `AfterWriteAtServer`.

[suy luận] Lý do: register chỉ lưu Quantity, không lưu đơn vị; đổi `Unit` của sản phẩm đã có phát sinh sẽ làm sai ý nghĩa số tồn. Đây chỉ là khóa trên form (ReadOnly), không phải kiểm tra ở object module.

Form của Warehouses chỉ gọi SSL: `AttachableCommands`, `PropertyManager`, `ContactsManager` (trong `OnCreateAtServer`, `OnReadAtServer`, `FillCheckProcessingAtServer`, `BeforeWriteAtServer`). Không có logic nghiệp vụ riêng của Jet.

## 3. Ba Document kho: cấu trúc chung

Nguồn: Jet — cf/Documents/InventoryIncrease.xml, InventoryWriteOff.xml, InventoryTransfer.xml

| | InventoryIncrease | InventoryWriteOff | InventoryTransfer |
|---|---|---|---|
| Ý nghĩa | Nhập tăng hàng (theo wiki: dùng cho số dư đầu) | Xuất hủy / ghi giảm | Chuyển kho |
| Header attributes | `Warehouse` (ShowError), `Comment`, `Author` | `Warehouse` (ShowError), `Comment`, `Author` | `Warehouse` (ShowError), **`WarehouseReceiver`** (DontCheck), `Comment`, `Author` |
| Tabular section `Inventory` | `Product` (ShowError), `Quantity` (15,3), **`Price`** (15,2), **`Amount`** (15,2) | `Product` (ShowError), `Quantity` | `Product` (ShowError), `Quantity` |
| RegisterRecords | InventoryInWarehouses, InventoryCost | như bên trái | như bên trái |
| Thuộc Sequence InventoryCostRecalculation | không | có | có |
| Template | `LoadingFromFile` (SSL ImportDataFromFile) | — | — |

Các property chung của cả ba (xem Bài 11, Bài 20):
- `Posting` = Allow, `RealTimePosting` = **Deny**, `RegisterRecordsDeletion` = AutoDeleteOff, `RegisterRecordsWritingOnPost` = WriteSelected, `SequenceFilling` = AutoFill.
- **Post in privileged mode** = true, **Unpost in privileged mode** = true.
- Number: String, length 9, `NumberPeriodicity` = Year, Autonumbering.
- `Author` có kiểu CatalogRef.Users; `AdditionalAttributes` là tabular section của SSL Properties.
- Field `Product` trong tabular section có Choice parameter `Filter.ProductType = Enum.ProductTypes.EnumValue.Inventory` — chỉ chọn được hàng hóa, không chọn được dịch vụ (xem Bài 9 về choice parameters).

**Không có** handler `FillCheckProcessing`, `BeforeWrite` hay `OnWrite` trong object module của ba Document này. Kiểm tra điền dữ liệu chỉ dựa vào property FillChecking (ShowError) của `Warehouse` và `Product`. `FillCheckProcessingAtServer` / `BeforeWriteAtServer` trong form chỉ gọi SSL `PropertyManager` (mục 9).

Handler `Filling` — giống nhau ở cả ba:

Nguồn: Jet — cf/Documents/InventoryTransfer/Ext/ObjectModule.bsl
```bsl
Procedure Filling(FillingData, FillingText, StandardProcessing)
	
	ObjectFillingJet.FillDocument(ThisObject, FillingData);
	
EndProcedure
```

`ObjectFillingJet.FillDocument` (code của Jet) chuẩn hóa `FillingData` thành Structure, gán `Author` = `Users.AuthorizedUser()` (hàm SSL), nếu Document có attribute `Currency` thì điền currency mặc định (ba Document kho không có `Currency`), rồi `FillPropertyValues(DocumentObject, FillingData)`.

## 4. Mẫu Posting của Jet

Cả ba Document có object module **giống hệt nhau**, chỉ khác dòng gọi `Documents.<Tên>.InitializeDocumentData`. Đây là "khuôn Posting" chuẩn của Jet, cũng được SalesInvoice và SupplierInvoice dùng.

Nguồn: Jet — cf/Documents/InventoryTransfer/Ext/ObjectModule.bsl
```bsl
Procedure Posting(Cancel, PostingMode)
	
	// Initialization of additional properties for document posting.
	PostingManagement.InitializeAdditionalPropertiesForPosting(Ref, AdditionalProperties);
	
	// Document data initialization.
	Documents.InventoryTransfer.InitializeDocumentData(Ref, AdditionalProperties);
	
	// Preparation of records sets.
	PostingManagement.PrepareRecordSetsForWriting(ThisObject);
	
	// Movements on the InventoryInWarehouses register
	PostingManagement.ReflectInventoryInWarehouses(AdditionalProperties, RegisterRecords, Cancel);
	
	// Movements on the InventoryCost register
	PostingManagement.ReflectInventoryCost(AdditionalProperties, RegisterRecords, Cancel);
	
	// Writing of the records sets.
	PostingManagement.WriteRecordSets(ThisObject);
	
	// Negative balance control
	AccumulationRegisters.InventoryInWarehouses.NegativeBalanceControl(Ref, AdditionalProperties, Cancel);
	
EndProcedure
```

Luồng 6 bước (so với Bài 11, nơi Posting viết thẳng `RegisterRecords.X.Add()` trong vòng lặp):

1. **InitializeAdditionalPropertiesForPosting** — tạo trong `AdditionalProperties` các khóa `TableForRegisterRecords` (Structure), `ForPosting` (chứa một `TempTablesManager`), `DocumentMetadata`.
2. **InitializeDocumentData** (manager module của Document) — chạy một batch query, đặt kết quả thành các ValueTable `TableInventoryInWarehouses`, `TableInventoryCost` trong `AdditionalProperties.TableForRegisterRecords`.
3. **PrepareRecordSetsForWriting** — xóa nội dung các record set và bật `Write = True` cho những register mà Document đang có movements (để khi post lại hoặc unpost thì movements cũ bị ghi đè bằng tập rỗng).
4. **ReflectInventoryInWarehouses / ReflectInventoryCost** — `Load()` ValueTable vào record set.
5. **WriteRecordSets** — gọi `RecordSet.Write()` ngay trong Posting, đồng thời truyền `ForPosting` vào `AdditionalProperties` của record set (để record set module dùng chung `TempTablesManager`, xem mục 7).
6. **NegativeBalanceControl** — kiểm tra tồn âm sau khi đã ghi (cùng ý tưởng Bài 12: ghi movements bằng `Write()` rồi mới query số dư).

UndoPosting dùng lại bước 1, 3, 5, 6 — bỏ qua bước 2 và 4, nên record set được ghi **rỗng**. Vì vậy hủy post một InventoryIncrease cũng có thể bị chặn nếu hàng đã được xuất đi.

Code của các bước trong common module `PostingManagement` (module của Jet):

Nguồn: Jet — cf/CommonModules/PostingManagement/Ext/Module.bsl
```bsl
Procedure WriteRecordSets(DocumentObject) Export
	
	For Each RecordSet In DocumentObject.RegisterRecords Do
		If RecordSet.Write Then
			RecordSet.AdditionalProperties.Insert("ForPosting", DocumentObject.AdditionalProperties.ForPosting);
			RecordSet.Write();
			RecordSet.Write = False;
		EndIf;
	EndDo;
	
EndProcedure
// ...
Procedure ReflectInventoryInWarehouses(AdditionalProperties, RegisterRecords, Cancel) Export
	
	TableInventoryInWarehouses = AdditionalProperties.TableForRegisterRecords.TableInventoryInWarehouses;
	
	If Cancel Or TableInventoryInWarehouses.Count() = 0 Then
		Return;
	EndIf;
	
	InventoryInWarehousesRecord = RegisterRecords.InventoryInWarehouses;
	InventoryInWarehousesRecord.Write = True;
	InventoryInWarehousesRecord.Load(TableInventoryInWarehouses);
	
EndProcedure
```

`ReflectInventoryCost` có cấu trúc y hệt, đọc `TableInventoryCost` và nạp vào `RegisterRecords.InventoryCost`.

`GetUsedRegisterNames` (Private) dựng động một query `SELECT TOP 1 ... WHERE RegisterTable.Recorder = &Recorder` cho từng register trong `DocumentMetadata.RegisterRecords`, nối bằng `JetServer.GetQueryUnion()` (trả về chuỗi `UNION ALL`), để biết register nào Document đã có movements.

Điểm then chốt cho sinh viên: **tên cột trong ValueTable phải trùng tên dimension/resource của register** (`RecordType`, `Period`, `Warehouse`, `Product`, `Quantity`, `Amount`) thì `Load()` mới nạp đúng — vì thế các query trong `InitializeDocumentData` đặt alias rất cẩn thận.

## 5. InitializeDocumentData của từng Document

### 5.1 InventoryIncrease — đơn giản nhất (chỉ Receipt)

Không có data lock, không đọc số dư. Batch 4 query; kết quả số 2 và 3 (đánh số từ 0) là bảng movements.

Nguồn: Jet — cf/Documents/InventoryIncrease/Ext/ManagerModule.bsl
```bsl
Procedure InitializeDocumentData(InventoryIncreaseRef, AdditionalProperties) Export
	
	Query = New Query;
	Query.Text =
	"SELECT
	|	InventoryIncrease.Ref AS Ref,
	|	InventoryIncrease.Date AS Date,
	|	InventoryIncrease.Warehouse AS Warehouse
	|INTO DocumentHeader
	|FROM
	|	Document.InventoryIncrease AS InventoryIncrease
	|WHERE
	|	InventoryIncrease.Ref = &Ref
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	// ...
	|SELECT
	|	VALUE(AccumulationRecordType.Receipt) AS RecordType,
	|	DocumentInventory.Period AS Period,
	|	DocumentInventory.Warehouse AS Warehouse,
	|	DocumentInventory.Product AS Product,
	|	SUM(DocumentInventory.Quantity) AS Quantity
	|FROM
	|	DocumentInventory AS DocumentInventory
	|
	|GROUP BY
	|	DocumentInventory.Product,
	|	DocumentInventory.Period,
	|	DocumentInventory.Warehouse
	// ...
	
	Query.SetParameter("Ref", InventoryIncreaseRef);
	
	QueryResult = Query.ExecuteBatch();
	
	AdditionalProperties.TableForRegisterRecords.Insert("TableInventoryInWarehouses", QueryResult[2].Unload());
	AdditionalProperties.TableForRegisterRecords.Insert("TableInventoryCost", QueryResult[3].Unload());
	
EndProcedure
```

Query thứ 2 (đã lược) tạo temp table `DocumentInventory` = `DocumentHeader` INNER JOIN `Document.InventoryIncrease.Inventory` (lấy `Date AS Period`, `Warehouse`, `Product`, `Quantity`, `Amount`). Query thứ 4 (đã lược) có cùng dạng với query thứ 3 nhưng thêm `SUM(DocumentInventory.Amount) AS Amount` — đó là bảng movements cho InventoryCost.

Nhận xét: temporary table `DocumentHeader` → `DocumentInventory` → hai SELECT có `GROUP BY` để gộp các dòng trùng Product (xem Bài 10 về batch query, temporary tables). Giá trị nhập kho (`Amount`) lấy thẳng từ tabular section.

### 5.2 InventoryWriteOff — Expense, tính giá vốn theo bình quân

Có thêm: managed **data lock** trên `InventoryCost`, đọc số dư `InventoryCost.Balance` tại thời điểm Document, rồi phân bổ giá trị xuất theo tỷ lệ Quantity.

Nguồn: Jet — cf/Documents/InventoryWriteOff/Ext/ManagerModule.bsl
```bsl
	DocumentObject = InventoryWriteOffRef.GetObject();
	
	DataLock = New DataLock;
	LockItem = DataLock.Add("AccumulationRegister.InventoryCost");
	LockItem.Mode = DataLockMode.Exclusive;
	LockItem.DataSource = DocumentObject.Inventory;
	LockItem.UseFromDataSource("Product", "Product");
	LockItem.SetValue("Warehouse", DocumentObject.Warehouse);
	DataLock.Lock();
```

`DataLock` khóa độc quyền các bản ghi InventoryCost theo cặp (Product lấy từ tabular section `Inventory`, Warehouse của header) để hai giao dịch đồng thời không cùng đọc một số dư (ngoài giáo trình — hãy kiểm tra lại trong Syntax assistant).

Phần query đọc số dư và tính Amount:

Nguồn: Jet — cf/Documents/InventoryWriteOff/Ext/ManagerModule.bsl
```bsl
	|SELECT
	|	InventoryCostBalance.Product AS Product,
	|	InventoryCostBalance.Warehouse AS Warehouse,
	|	InventoryCostBalance.QuantityBalance AS Quantity,
	|	InventoryCostBalance.AmountBalance AS Amount
	|INTO InventoryCostBalance
	|FROM
	|	AccumulationRegister.InventoryCost.Balance(
	|			&PointInTime,
	|			(Product, Warehouse) IN
	|				(SELECT
	|					ProductTable.Product,
	|					ProductTable.Warehouse
	|				FROM
	|					ProductTable AS ProductTable)) AS InventoryCostBalance
	|
	|UNION ALL
	|
	|SELECT
	|	InventoryCost.Product,
	|	InventoryCost.Warehouse,
	|	InventoryCost.Quantity,
	|	InventoryCost.Amount
	|FROM
	|	AccumulationRegister.InventoryCost AS InventoryCost
	|WHERE
	|	InventoryCost.Recorder = &Ref
	|;
	// ...
	|SELECT
	|	VALUE(AccumulationRecordType.Expense) AS RecordType,
	|	ProductTable.Period AS Period,
	|	ProductTable.Product AS Product,
	|	ProductTable.Warehouse AS Warehouse,
	|	ProductTable.Quantity AS Quantity,
	|	CASE
	|		WHEN ISNULL(InventoryCostTable.Quantity, 0) = 0
	|			THEN 0
	|		WHEN ProductTable.Quantity = InventoryCostTable.Quantity
	|			THEN InventoryCostTable.Amount
	|		ELSE CAST(InventoryCostTable.Amount * ProductTable.Quantity / InventoryCostTable.Quantity AS NUMBER(15, 2))
	|	END AS Amount
	|FROM
	|	ProductTable AS ProductTable
	|		LEFT JOIN InventoryCostTable AS InventoryCostTable
	|		ON ProductTable.Product = InventoryCostTable.Product
	|			AND ProductTable.Warehouse = InventoryCostTable.Warehouse";
	
	Query.SetParameter("Ref", InventoryWriteOffRef);
	Query.SetParameter("PointInTime", New Boundary(DocumentObject.PointInTime(), BoundaryType.Including));
	
	QueryResult = Query.ExecuteBatch();
	
	AdditionalProperties.TableForRegisterRecords.Insert("TableInventoryInWarehouses", QueryResult[5].Unload());
	AdditionalProperties.TableForRegisterRecords.Insert("TableInventoryCost", QueryResult[6].Unload());
```

Giải thích:
- `Balance(&PointInTime, ...)` với `New Boundary(DocumentObject.PointInTime(), BoundaryType.Including)` — số dư **bao gồm** cả thời điểm của Document (xem Bài 11 về PointInTime/Boundary).
- [suy luận] Nhánh `UNION ALL ... WHERE InventoryCost.Recorder = &Ref` cộng ngược movements cũ của chính Document: khi post lại, movements cũ (Expense) vẫn còn trong register lúc query chạy (register chỉ bị ghi đè ở bước WriteRecordSets), nên số dư "Including" đã bị trừ bởi chính Document. Cộng lại Quantity/Amount của chúng sẽ cho số dư "trước khi Document này xuất".
- Công thức giá vốn: nếu xuất hết số tồn → lấy nguyên `Amount` tồn (tránh sai số làm tròn); nếu không → `Amount tồn × Quantity xuất / Quantity tồn`, làm tròn `NUMBER(15, 2)`. Đây là giá **bình quân** theo từng cặp Product + Warehouse. Nếu tồn bằng 0 → Amount = 0.
- Kết quả số 5 (movements InventoryInWarehouses, chỉ Quantity) và số 6 (movements InventoryCost, có Amount).

### 5.3 InventoryTransfer — Expense ở kho xuất + Receipt ở kho nhận

Data lock giống WriteOff. Khác biệt: có `WarehouseReceiver`, nhánh UNION ALL lọc `RecordType = Expense`, và tạo cặp movements.

Nguồn: Jet — cf/Documents/InventoryTransfer/Ext/ManagerModule.bsl
```bsl
	|FROM
	|	AccumulationRegister.InventoryCost AS InventoryCost
	|WHERE
	|	InventoryCost.Recorder = &Ref
	|	AND InventoryCost.RecordType = VALUE(AccumulationRecordType.Expense)
	|;
	// ...
	|SELECT
	|	VALUE(AccumulationRecordType.Expense) AS RecordType,
	|	ProductTable.Period AS Period,
	|	ProductTable.Warehouse AS Warehouse,
	|	ProductTable.Product AS Product,
	|	ProductTable.Quantity AS Quantity
	|FROM
	|	ProductTable AS ProductTable
	|
	|UNION ALL
	|
	|SELECT
	|	VALUE(AccumulationRecordType.Receipt),
	|	ProductTable.Period,
	|	ProductTable.WarehouseReceiver,
	|	ProductTable.Product,
	|	ProductTable.Quantity
	|FROM
	|	ProductTable AS ProductTable
	// ...
	
	Query.SetParameter("Ref", InventoryTransferRef);
	Query.SetParameter("PointInTime", New Boundary(DocumentObject.PointInTime(), BoundaryType.Including));
	
	QueryResult = Query.ExecuteBatch();
	
	AdditionalProperties.TableForRegisterRecords.Insert("TableInventoryInWarehouses", QueryResult[6].Unload());
	AdditionalProperties.TableForRegisterRecords.Insert("TableInventoryCost", QueryResult[7].Unload());
```

Query [7] (đã lược) có cùng dạng Expense/Receipt nhưng đọc từ `ProductTransferTable` và có thêm cột `Amount`.

Batch đầy đủ có 8 query: `DocumentHeader` → `DocumentInventory` → `ProductTable` (GROUP BY) → `InventoryCostBalance` → `InventoryCostTable` (GROUP BY) → `ProductTransferTable` (cùng công thức CASE như WriteOff) → movements InventoryInWarehouses [6] → movements InventoryCost [7]. Kho nhận nhận **đúng Amount** đã tính ở kho xuất, nên giá trị hàng được "chuyển" theo hàng.

[suy luận] Lọc `RecordType = Expense` vì Transfer có cả movements Receipt (vào kho nhận); chỉ cần cộng lại phần đã xuất của chính Document.

## 6. Accumulation registers

Nguồn: Jet — cf/AccumulationRegisters/InventoryInWarehouses.xml, cf/AccumulationRegisters/InventoryCost.xml

| Register | RegisterType | Dimensions | Resources | Module |
|---|---|---|---|---|
| **InventoryInWarehouses** | Balance | `Product` (CatalogRef.Products), `Warehouse` (CatalogRef.Warehouses) — cả hai DenyIncompleteValues = true | `Quantity` (15,3) | ManagerModule (NegativeBalanceControl), RecordSetModule (BeforeWrite, OnWrite) |
| **InventoryCost** | Balance | `Product`, `Warehouse` — DenyIncompleteValues = true | `Quantity` (15,3), `Amount` (15,2) | không có module |

Cả hai có `EnableTotalsSplitting` = true. Không có attribute.

Document ghi vào cả hai register (theo `RegisterRecords` trong XML của Document): InventoryIncrease, InventoryWriteOff, InventoryTransfer, SalesInvoice, SupplierInvoice. Tất cả đều đi qua `PostingManagement.ReflectInventoryInWarehouses` / `ReflectInventoryCost` và gọi `NegativeBalanceControl` trong Posting và UndoPosting.

Vai trò:
- **InventoryInWarehouses** — số lượng tồn theo kho; dùng cho kiểm soát tồn âm và report AvailableStock.
- **InventoryCost** — số lượng + giá trị; nguồn tính giá vốn khi xuất và cho report StockStatement. Là register của Sequence InventoryCostRecalculation (mục 8).

Role `UseWarehouses` chỉ có quyền `Read`, `View` trên hai register (không sửa tay movements).

## 7. Kiểm soát tồn âm

Cơ chế gồm ba mảnh, phối hợp qua `TempTablesManager` dùng chung trong `AdditionalProperties.ForPosting`:

| Bước | Ở đâu | Làm gì |
|---|---|---|
| 1 | RecordSetModule `BeforeWrite` | Lock record set theo Recorder; lưu movements **cũ** của Document vào temp table `InventoryInWarehousesBeforeWrite` (Receipt dương, Expense âm) |
| 2 | RecordSetModule `OnWrite` | So movements cũ với movements **mới** vừa ghi → temp table `InventoryInWarehousesChange` chỉ gồm cặp (Warehouse, Product) có thay đổi; đặt cờ `IsInventoryInWarehousesChange` |
| 3 | ManagerModule `NegativeBalanceControl` | Nếu có thay đổi: join `InventoryInWarehousesChange` với số dư hiện tại, tìm `QuantityBalance < 0`, báo lỗi và đặt `Cancel` |

Nguồn: Jet — cf/AccumulationRegisters/InventoryInWarehouses/Ext/RecordSetModule.bsl
```bsl
Procedure BeforeWrite(Cancel, Replacing)
	
	If DataExchange.Load Or Not AdditionalProperties.Property("ForPosting") Then
		Return;
	EndIf;
	
	Block = New DataLock;
	LockItem = Block.Add("AccumulationRegister.InventoryInWarehouses.RecordSet");
	LockItem.Mode = DataLockMode.Exclusive;
	LockItem.SetValue("Recorder", Filter.Recorder.Value);
	Block.Lock();
	
	Query = New Query;
	Query.TempTablesManager = AdditionalProperties.ForPosting.TempTablesManager;
	Query.SetParameter("Recorder", Filter.Recorder.Value);
	Query.Text =
	"SELECT
	|	InventoryInWarehouses.Warehouse AS Warehouse,
	|	InventoryInWarehouses.Product AS Product,
	|	CASE
	|		WHEN InventoryInWarehouses.RecordType = VALUE(AccumulationRecordType.Receipt)
	|			THEN InventoryInWarehouses.Quantity
	|		ELSE -InventoryInWarehouses.Quantity
	|	END AS Quantity
	|INTO InventoryInWarehousesBeforeWrite
	|FROM
	|	AccumulationRegister.InventoryInWarehouses AS InventoryInWarehouses
	|WHERE
	|	InventoryInWarehouses.Recorder = &Recorder";
	
	Query.Execute();
	
EndProcedure
```

Điều kiện `Not AdditionalProperties.Property("ForPosting")` — chỉ chạy khi record set được ghi qua `PostingManagement.WriteRecordSets` (nơi gán `ForPosting`). `DataExchange.Load` = true khi ghi trong trao đổi dữ liệu → bỏ qua (ngoài giáo trình — hãy kiểm tra lại trong Syntax assistant).

Nguồn: Jet — cf/AccumulationRegisters/InventoryInWarehouses/Ext/RecordSetModule.bsl
```bsl
	QueryResult = Query.ExecuteBatch();
	
	Selection = QueryResult[2].Select();
	Selection.Next();
	
	AdditionalProperties.ForPosting.Insert("IsInventoryInWarehousesChange", Selection.ChangeCount > 0);
```

Trong `OnWrite` (batch query, đã lược), `PrevInventoryInWarehousesChange` = movements cũ (dấu như BeforeWrite) UNION ALL movements mới **đảo dấu** (Receipt → âm, Expense → dương). Temp table `InventoryInWarehousesChange` = `GROUP BY Warehouse, Product HAVING SUM(QuantityChange) <> 0` (có `INDEX BY Warehouse, Product`), query thứ 3 đếm `COUNT(*) AS ChangeCount`. Tổng theo (Warehouse, Product) ≠ 0 nghĩa là cặp đó bị Document làm thay đổi. [suy luận] Dấu dương của `QuantityChange` nghĩa là tồn kho bị **giảm** so với trước — nhưng code không lọc theo dấu, chỉ lấy `<> 0`. Cuối batch, hai temp table trung gian bị `DROP`; `InventoryInWarehousesChange` được giữ lại trong `TempTablesManager` cho bước 3.

Nguồn: Jet — cf/AccumulationRegisters/InventoryInWarehouses/Ext/ManagerModule.bsl
```bsl
Procedure NegativeBalanceControl(Ref, AdditionalProperties, Cancel) Export
	
	If AdditionalProperties.ForPosting.Property("IsInventoryInWarehousesChange")
		And AdditionalProperties.ForPosting.IsInventoryInWarehousesChange Then
		
		Query = New Query;
		Query.TempTablesManager = AdditionalProperties.ForPosting.TempTablesManager;
		Query.Text =
		"SELECT
		|	InventoryInWarehousesChange.Warehouse AS Warehouse,
		|	InventoryInWarehousesChange.Product AS Product,
		|	Products.Unit AS Unit,
		|	-InventoryInWarehousesBalance.QuantityBalance AS Shortage
		|FROM
		|	InventoryInWarehousesChange AS InventoryInWarehousesChange
		|		INNER JOIN Catalog.Products AS Products
		|		ON InventoryInWarehousesChange.Product = Products.Ref
		|		INNER JOIN AccumulationRegister.InventoryInWarehouses.Balance(, ) AS InventoryInWarehousesBalance
		|		ON InventoryInWarehousesChange.Warehouse = InventoryInWarehousesBalance.Warehouse
		|			AND InventoryInWarehousesChange.Product = InventoryInWarehousesBalance.Product
		|			AND (InventoryInWarehousesBalance.QuantityBalance < 0)
		|TOTALS BY
		|	Warehouse";
		
		Result = Query.Execute();
		If Not Result.IsEmpty() Then
			
			WarehouseSelection = Result.Select(QueryResultIteration.ByGroups);
			While WarehouseSelection.Next() Do
				
				MessageText = StringFunctionsClientServer.SubstituteParametersToString(NStr("en = 'Insufficient quantity on %1'"),
					WarehouseSelection.Warehouse);
				Common.MessageToUser(MessageText, Ref, , , Cancel);
				
				Selection = WarehouseSelection.Select();
				While Selection.Next() Do
					MessageText = StringFunctionsClientServer.SubstituteParametersToString(NStr("en = 'Product: %1, shortage %2 %3'"),
						Selection.Product,
						Selection.Shortage,
						Selection.Unit);
					Common.MessageToUser(MessageText, Ref, , , Cancel);
				EndDo;
				
			EndDo;
			
		EndIf;
		
	EndIf;
	
EndProcedure
```

Giải thích:
- `Balance(, )` không truyền Period → số dư **hiện tại** (sau tất cả movements), không phải tại thời điểm Document. Kết hợp `RealTimePosting = Deny`, [suy luận] một Document lùi ngày vẫn bị kiểm theo tồn cuối cùng.
- `TOTALS BY Warehouse` + `QueryResultIteration.ByGroups` → mỗi kho một dòng tiêu đề "Insufficient quantity on ...", sau đó từng sản phẩm thiếu (xem Bài 10 về TOTALS).
- `Common.MessageToUser(..., Cancel)` và `StringFunctionsClientServer.SubstituteParametersToString` là hàm SSL; tham số `Cancel` truyền vào làm post bị hủy.
- Kiểm soát này áp dụng **chỉ cho InventoryInWarehouses** (số lượng). InventoryCost không có kiểm soát tồn âm riêng.

So với Bài 12 (query `GoodsInWarehouses.Balance` sau khi `Write()`): Jet làm cùng ý tưởng nhưng chỉ kiểm những cặp (Warehouse, Product) **thực sự thay đổi**, và đặt logic trong register (record set module + manager module) để mọi Document ghi vào register đều dùng chung.

## 8. Sequence và Data processor tính lại giá vốn

Nguồn: Jet — cf/Sequences/InventoryCostRecalculation.xml

- `Documents`: InventoryTransfer, InventoryWriteOff, SalesInvoice (các Document **xuất** hàng — tính giá vốn từ số dư).
- `RegisterRecords`: AccumulationRegister.InventoryCost.
- `MoveBoundaryOnPosting` = Move; `DataLockControlMode` = Managed.

[suy luận] Ý nghĩa: giá vốn xuất được tính từ số dư InventoryCost tại thời điểm Document; nếu sau đó có Document sửa/lùi ngày làm thay đổi số dư quá khứ, các Document xuất phía sau cần post lại theo đúng thứ tự thời gian. Sequence là cơ chế platform để theo dõi "ranh giới" đã đúng thứ tự (Sequence không có trong giáo trình 24 bài — hãy kiểm tra lại trong Syntax assistant).

Data processor `InventoryCostRecalculation` (manager module) có hai function Export: `GetSeqBoundCurrent()` — đọc `Sequences.InventoryCostRecalculation.GetBound()`; `SequenceEnd()` — query `SELECT TOP 1` movements InventoryCost có `RecordType = Expense` và `Active`, `ORDER BY PointInTime DESC` (thời điểm xuất kho mới nhất). Nếu hai mốc khác nhau → cần tính lại.

Form của data processor: command `Recalculate` gọi `RecalculateAtServer()`; nếu `SeqBoundEnd.Compare(SeqBoundCurrent) = 1` thì gọi `Sequences.InventoryCostRecalculation.Restore()` rồi cập nhật lại hai mốc (`SetSeqBounds()`). `Restore()` là method platform khôi phục sequence bằng cách post lại các Document sau ranh giới (ngoài giáo trình — hãy kiểm tra lại trong Syntax assistant).

Tích hợp SSL **ToDoList**: `ToDoListOverridable.OnDetermineToDoListHandlers` có `ToDoList.Add(DataProcessors.InventoryCostRecalculation);`, và manager module cài `OnFillToDoList`: thêm một dòng `InventoryCostRecalculation` (Owner = `Metadata.Subsystems.Warehouses`) và một dòng con "It may be necessary to recalculate inventory costs" (`Important = True`, `Form = "DataProcessor.InventoryCostRecalculation.Form"`), `HasToDoItems` = kết quả `IsNeedToRecalculate()` (so `GetSeqBoundCurrent()` với `SequenceEnd()`).

## 9. Forms của Document

Mỗi Document có `DocumentForm`, `ListForm`, `ChoiceForm`. Form module của **InventoryWriteOff** và **InventoryTransfer** giống hệt nhau (138 dòng) và chỉ chứa các lệnh gọi SSL:

| Event / handler | Gọi SSL |
|---|---|
| `OnCreateAtServer` | `AttachableCommands.OnCreateAtServer`, `PropertyManager.OnCreateAtServer` (đặt additional attributes vào group `GroupAdditionalAttributes`) |
| `OnReadAtServer`, `OnOpen`, `AfterWrite`, `NotificationProcessing` | `AttachableCommands*`, `PropertyManager*` |
| `FillCheckProcessingAtServer` | `PropertyManager.FillCheckProcessing` |
| `BeforeWriteAtServer` | `PropertyManager.BeforeWriteAtServer` |
Form InventoryTransfer có các input field `Warehouse`, `WarehouseReceiver`, `Number`, `Date`, table `Inventory` (cột `InventoryProduct`, `InventoryQuantity` và một cột hiển thị `Object.Inventory.Product.Unit`), `Comment`, field `Author`.

**InventoryIncrease** thêm logic tính tiền trên client và nhập từ file:

Nguồn: Jet — cf/Documents/InventoryIncrease/Forms/DocumentForm/Ext/Form/Module.bsl
```bsl
&AtClient
Procedure InventoryAmountOnChange(Item)
	
	TabSectionRow = Items.Inventory.CurrentData;
	
	If TabSectionRow.Quantity <> 0 Then
		TabSectionRow.Price = Round(TabSectionRow.Amount / TabSectionRow.Quantity, 2);
	EndIf;
	
EndProcedure
// ...
&AtClient
Procedure CalculateAmount()
	
	TabSectionRow = Items.Inventory.CurrentData;
	
	If TabSectionRow <> Undefined Then
		TabSectionRow.Amount = TabSectionRow.Quantity * TabSectionRow.Price;
	EndIf;
	
EndProcedure
```

`InventoryQuantityOnChange` và `InventoryPriceOnChange` đều chỉ gọi `CalculateAmount()`. Lưu ý: form này **không** dùng `InventoryTabularSectionClientServer.CalculateAmount` (mục 10) vì tabular section của InventoryIncrease không có VAT.

Nhập tabular section từ file (SSL ImportDataFromFile, template `LoadingFromFile` gồm cột Product, Quantity, Price): command `ImportInventoryFromFile` gọi `ImportDataFromFileClient.ShowImportForm` với `FullTabularSectionName = "InventoryIncrease.Inventory"`; callback `ImportInventoryFromFileEnd` → `ImportInventoryFromFileAtServer` đọc `GetFromTempStorage(ImportedDataAddress)`, bỏ dòng không có `Product`, thêm dòng vào `Object.Inventory` và tính `NewRow.Amount = NewRow.Quantity * NewRow.Price`.

Manager module InventoryIncrease cài các handler SSL `MapDataToImport`, `FillInListOfAmbiguities` bằng cách ủy quyền cho `ImportDataFromFileJet` (module của Jet). `FormManagement()` ẩn nút import trên `MobileClient` bằng `#If MobileClient Then`.

## 10. Common module InventoryTabularSectionClientServer

Module của Jet; flags: `ClientManagedApplication` = true, `Server` = true, `ExternalConnection` = true, `ServerCall` = false, `Global` = false (xem Bài 14).

Nguồn: Jet — cf/CommonModules/InventoryTabularSectionClientServer/Ext/Module.bsl
```bsl
Procedure CalculateAmount(TabSectionRow) Export
	
	TabSectionRow.Amount = TabSectionRow.Quantity * TabSectionRow.Price;
	CalculateVATAmountAndTotal(TabSectionRow);
	
EndProcedure
// ...
Procedure CalculateVATAmountAndTotal(TabSectionRow) Export
	
	VATRate = JetServerCall.GetVATRateValue(TabSectionRow.VATRate);
	TabSectionRow.VATAmount = TabSectionRow.Amount * VATRate / 100;
	TabSectionRow.Total = TabSectionRow.Amount + TabSectionRow.VATAmount;
	
EndProcedure
```

- Yêu cầu dòng tabular section có các cột `Quantity`, `Price`, `Amount`, `VATRate`, `VATAmount`, `Total`.
- Lấy % thuế qua `JetServerCall.GetVATRateValue` (module `ServerCall` = true) → `JetCached.GetVATRateValue` (module reuse return values, xem Bài 14) — nên gọi được từ client mà không tốn nhiều lượt server.
- Người dùng thực tế: form `SalesInvoice`, `SupplierInvoice` và `PriceManagementClient`. **Ba Document kho không dùng** module này (tabular section của chúng không có VAT). Tên module có chữ "Inventory" vì nó phục vụ tabular section tên `Inventory` của các hóa đơn.

## 11. Reports

Cả hai report dùng DCS (xem Bài 18), main schema `MainDataCompositionSchema`, không có form riêng (`DefaultForm` rỗng — dùng form report của SSL Report options). Mô tả variant được khai báo trong `ReportsOptionsOverridable` (mục 12).

### 11.1 AvailableStock — tồn kho theo kho (InventoryInWarehouses)

Nguồn: Jet — cf/Reports/AvailableStock/Templates/MainDataCompositionSchema/Ext/Template.xml (query của DataSet1, đã bỏ XML escape)
```
SELECT
	InventoryInWarehousesBalance.Product AS Product,
	InventoryInWarehousesBalance.Warehouse AS Warehouse,
	InventoryInWarehousesBalance.QuantityBalance AS QuantityBalance
FROM
	AccumulationRegister.InventoryInWarehouses.Balance AS InventoryInWarehousesBalance
```

- Resource: `QuantityBalance` = `Sum(QuantityBalance)`.
- Parameter `Period` (dateTime, use Always) với expression: `CASE WHEN &Period = Undefined OR &Period = NULL OR &Period = DateTime(1,1,1) THEN DateTime(3999,12,31) ELSE DATEADD(EndOfPeriod(&Period, "Day"), "Second", 1) END` — để trống thì lấy tồn hiện tại, chọn ngày thì lấy tồn **cuối ngày** đó. [suy luận] DCS tự truyền `&Period` vào tham số Period của virtual table `Balance`.
- Variant `Default` ("Available stock"): một chart + một table, nhóm theo Warehouse, Product; filter Warehouse, Product (tắt sẵn). Variant `AvailableStockContext`: table nhóm Warehouse, Product.

### 11.2 StockStatement — nhập-xuất-tồn có giá trị (InventoryCost)

Nguồn: Jet — cf/Reports/StockStatement/Templates/MainDataCompositionSchema/Ext/Template.xml (query của DataSet1, đã bỏ XML escape)
```
SELECT ALLOWED
	InventoryCostBalanceAndTurnovers.Recorder AS Recorder,
	// ...
	InventoryCostBalanceAndTurnovers.Product AS Product,
	InventoryCostBalanceAndTurnovers.Warehouse AS Warehouse,
	InventoryCostBalanceAndTurnovers.QuantityOpeningBalance AS QuantityOpeningBalance,
	InventoryCostBalanceAndTurnovers.QuantityClosingBalance AS QuantityClosingBalance,
	InventoryCostBalanceAndTurnovers.QuantityReceipt AS QuantityReceipt,
	InventoryCostBalanceAndTurnovers.QuantityExpense AS QuantityExpense,
	InventoryCostBalanceAndTurnovers.AmountOpeningBalance AS AmountOpeningBalance,
	InventoryCostBalanceAndTurnovers.AmountClosingBalance AS AmountClosingBalance,
	InventoryCostBalanceAndTurnovers.AmountReceipt AS AmountReceipt,
	InventoryCostBalanceAndTurnovers.AmountExpense AS AmountExpense
FROM
	AccumulationRegister.InventoryCost.BalanceAndTurnovers(, , Auto, , ) AS InventoryCostBalanceAndTurnovers
```

- Virtual table `BalanceAndTurnovers` với periodicity `Auto` — DCS chọn mức chi tiết theo grouping người dùng chọn (Recorder, DayPeriod, MonthPeriod…).
- Resources: tổng `Sum(...)` cho 8 field Opening/Receipt/Expense/Closing × Quantity/Amount.
- Parameters: `ItmPeriod` (StandardPeriod), `BeginOfPeriod` = `&ItmPeriod.StartDate`, `EndOfPeriod` = `&ItmPeriod.EndDate`.
- Variant `StockStatement`: nhóm theo Product, filter Product. Variant `StockStatementContext`: nhóm theo Product.
- Report đọc **InventoryCost** (có giá trị), không đọc InventoryInWarehouses.

### 11.3 Lệnh mở report theo ngữ cảnh

Mỗi report có một command (`OpenAvailableStockReport`, `OpenStockStatementReport`; CommandParameterType = CatalogRef.Products, group `FormNavigationPanelSeeAlso`). Từ form sản phẩm, `CommandProcessing` (&AtClient) tạo `FilterStructure = New Structure("Product", CommandParameter)` rồi `OpenForm("Report.AvailableStock.Form", ...)` với các form parameter `VariantKey` = `"AvailableStockContext"` (hoặc `"StockStatementContext"`), `Filter`, `GenerateOnOpen = True`, `ReportOptionsCommandsVisibility = False`.

## 12. Print forms, Role và tích hợp SSL

**Print forms**: ba Document được đăng ký với SSL Print (xem Bài 22):

Nguồn: Jet — cf/CommonModules/PrintManagementOverridable/Ext/Module.bsl
```bsl
	Settings.PrintObjects.Add(Documents.InventoryIncrease);
	Settings.PrintObjects.Add(Documents.InventoryTransfer);
	Settings.PrintObjects.Add(Documents.InventoryWriteOff);
```

Manager module mỗi Document có `OnDefinePrintSettings` (đặt `Settings.OnAddPrintCommands = True`) nhưng `AddPrintCommands(PrintCommands)` có thân **rỗng**, và không có template in nào. Tức là hiện **chưa có print form** cho Document kho — chỉ có "chỗ cắm" sẵn.

**Report options** (`ReportsOptionsOverridable`, code Jet trong module SSL Overridable): thêm section `Metadata.Subsystems.Warehouses` ("Warehouses reports"); mô tả variant `StockStatement` = "Opening balance, receipt, consumption, closing balance by products", `AvailableStock.Default` = "Product stock balances by warehouse"; hai variant `...Context` bị `Enabled = False` (chỉ mở qua command ngữ cảnh).

**Properties** (`PropertyManagerOverridable`): khai báo set additional attributes `Catalog_Warehouses`, `Document_InventoryIncrease`, `Document_InventoryTransfer`, `Document_InventoryWriteOff`.

**Attached files**: role có quyền trên `Catalog.WarehousesAttachedFiles`, `InventoryIncreaseAttachedFiles`, `InventoryTransferAttachedFiles`, `InventoryWriteOffAttachedFiles` (SSL Attached files).

**Role UseWarehouses** (xem Bài 20): trên ba Document kho — Read, Insert, Update, Posting, UndoPosting và các quyền Interactive tương ứng; trên ba Catalog Warehouses/Products/Units — Read, Insert, Update, Edit, InputByString và các quyền Interactive; `Read, View` trên hai register; `Read, Update` trên Sequence; `Use, View` trên hai report và data processor; `View` trên subsystem và ba CommonCommand.

## 13. Những điểm cần lưu ý

Rút ra từ việc đọc code — dùng để giảng giải hoặc làm đề bài, không phải kết luận chính thức của Jet.

1. **`WarehouseReceiver` không bắt buộc** (FillChecking = DontCheck), không có `FillCheckProcessing` kiểm tra kho nhận ≠ kho xuất. [suy luận] Để trống → lỗi platform do dimension `Warehouse` có DenyIncompleteValues, thay vì thông báo thân thiện; chọn trùng kho → hai movements triệt tiêu.
2. **`Quantity` không bắt buộc > 0** (DontCheck, không MinValue).
3. **Kiểm tra tồn âm theo số dư hiện tại** `Balance(, )`, không theo thời điểm Document (mục 7); không có kiểm soát âm cho InventoryCost.
4. **Print form chưa có** dù đã đăng ký với SSL Print (mục 12).
5. `InventoryTabularSectionClientServer` không được Document kho nào dùng (mục 10).
6. Form InventoryWriteOff và InventoryTransfer giống hệt nhau, không có handler riêng cho `WarehouseReceiver`.

## 14. Gợi ý mở rộng cho nhóm sinh viên phân hệ Kho

Các ý tưởng dưới đây là **gợi ý** bài tập, dựa trên object/module có thật trong Jet. Chúng không phải tính năng của Jet. Code cụ thể sinh viên tự viết; khi cần code mẫu, viết theo nguyên tắc "code minh họa — chạy thử để kiểm chứng". Nên làm trong **Configuration extension** (Purpose: Customization hoặc Add-on) để giữ configuration gốc nguyên vẹn (upgrade-safe customization, xem bài Extensions).

### Gợi ý 1 — Kiểm tra dữ liệu cho InventoryTransfer (dễ)
- Mục tiêu: bắt buộc `WarehouseReceiver`, cấm trùng `Warehouse`, cấm `Quantity <= 0`.
- Chạm tới: object module `Document.InventoryTransfer` — thêm handler `FillCheckProcessing` (Bài 12); có thể áp dụng tương tự cho InventoryWriteOff / InventoryIncrease.
- Trong extension: adopt Document InventoryTransfer, thêm handler mới vào object module.
- Kiểm thử: tạo Transfer có kho nhận trống / trùng kho / số lượng 0 → phải bị chặn trước khi Posting chạy.

### Gợi ý 2 — Document mới "Kiểm kê kho" (InventoryCount) theo khuôn InventoryWriteOff (trung bình)
- Mục tiêu: header `Warehouse`; tabular section `Inventory` gồm `Product`, `QuantityBook` (sổ sách), `QuantityActual` (thực tế), `Difference`. Nút "Fill from balance" lấy tồn từ `InventoryInWarehouses.Balance`. Khi post: chênh lệch dương → Receipt, âm → Expense vào hai register.
- Chạm tới:
  - Object module: sao chép khuôn `Posting`/`UndoPosting` gồm `PostingManagement.InitializeAdditionalPropertiesForPosting`, `PrepareRecordSetsForWriting`, `ReflectInventoryInWarehouses`, `ReflectInventoryCost`, `WriteRecordSets`, `AccumulationRegisters.InventoryInWarehouses.NegativeBalanceControl`.
  - Manager module: `InitializeDocumentData` — phần thiếu hụt tính Amount theo công thức CASE của InventoryWriteOff, cần `DataLock` trên `InventoryCost` như WriteOff.
  - `Filling` → `ObjectFillingJet.FillDocument`.
  - Thêm Document vào subsystem `Warehouses/Warehouse`, role `UseWarehouses`, `PrintManagementOverridable`, `PropertyManagerOverridable` (nếu cần additional attributes).
  - [suy luận] Cân nhắc thêm vào `Documents` của Sequence `InventoryCostRecalculation` vì Document có phần xuất tính giá vốn.
- Câu hỏi thiết kế cho nhóm: phần thừa (Receipt) lấy Amount từ đâu — nhập giá tay như InventoryIncrease hay dùng giá bình quân hiện tại?

### Gợi ý 3 — Print form "Phiếu chuyển kho" cho InventoryTransfer (trung bình, Bài 17 + 22)
- Mục tiêu: lấp chỗ trống `AddPrintCommands` rỗng.
- Chạm tới: manager module `Document.InventoryTransfer` — cài `AddPrintCommands` và procedure in theo SSL Print; thêm template (spreadsheet) vào Document; `PrintManagementOverridable` đã có sẵn `Settings.PrintObjects.Add(Documents.InventoryTransfer)`.
- Nội dung in: số, ngày, `Warehouse` → `WarehouseReceiver`, bảng Product / Unit / Quantity, `Author`.
- Mở rộng thêm: cột giá trị lấy từ movements `InventoryCost` của chính Document (Recorder = Ref).

### Gợi ý 4 — Report "Thẻ kho" (Stock card) theo một sản phẩm (trung bình, Bài 18)
- Mục tiêu: liệt kê từng chứng từ nhập/xuất của một sản phẩm tại một kho, có tồn đầu – nhập – xuất – tồn cuối theo từng dòng Recorder.
- Chạm tới: Report mới với DCS dựa trên `AccumulationRegister.InventoryInWarehouses.BalanceAndTurnovers(, , Recorder, ...)` hoặc tái dùng cách StockStatement đọc `InventoryCost.BalanceAndTurnovers(, , Auto, , )`; parameter kỳ báo cáo kiểu `StandardPeriod` như `ItmPeriod`.
- Tích hợp: thêm variant vào `ReportsOptionsOverridable` (section Warehouses), thêm command ngữ cảnh trên Products theo mẫu `OpenStockStatementReport` (CommandParameterType = CatalogRef.Products).

### Gợi ý 5 — Tồn kho tối thiểu và cảnh báo (trung bình–khó)
- Mục tiêu: lưu mức tồn tối thiểu theo (Product, Warehouse); report/ToDo cảnh báo sản phẩm dưới mức.
- Chạm tới:
  - Information register mới (non-periodic) dimension `Product`, `Warehouse`, resource `MinQuantity` (Bài 12).
  - Query join register mới với `InventoryInWarehouses.Balance`.
  - Tích hợp SSL ToDoList theo mẫu `DataProcessors.InventoryCostRecalculation.OnFillToDoList` và `ToDoListOverridable.OnDetermineToDoListHandlers`.
  - Hoặc làm report DCS hai data set có link.

### Gợi ý 6 — Kiểm tra tồn âm theo thời điểm Document (khó, thảo luận)
- Mục tiêu: thử phiên bản `NegativeBalanceControl` kiểm số dư tại `PointInTime` của Document thay vì `Balance(, )`, so sánh hai cách với Document lùi ngày.
- Chạm tới: manager module `AccumulationRegister.InventoryInWarehouses` (trong extension: adopt và dùng `&Around` hoặc `&ChangeAndValidate` cho `NegativeBalanceControl`, xem bài Extensions); temp table `InventoryInWarehousesChange` có sẵn trong `AdditionalProperties.ForPosting.TempTablesManager`.
- Lưu ý: procedure được gọi bởi cả SalesInvoice và SupplierInvoice — thay đổi ảnh hưởng phân hệ Sales/Purchases, cần phối hợp với các nhóm khác.
