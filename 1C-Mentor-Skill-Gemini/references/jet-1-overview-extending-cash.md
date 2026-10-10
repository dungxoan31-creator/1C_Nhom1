# Tài liệu gộp: jet-1-overview-extending-cash

Gồm các mục: § jet-overview, § jet-extending, § jet-cash


---

# § jet-overview

# 1C:Jet — tổng quan, kiến trúc và cách tổ chức code

Khi nào đọc file này: sinh viên hỏi "Jet là gì", "Document X post vào register nào", "code posting của Jet nằm ở đâu", "muốn thêm tính năng vào subsystem Warehouses/Purchases/Sales/CashManagement thì bắt đầu từ đâu", hoặc cần bản đồ object của Jet trước khi làm bài thực hành nhóm.

Phiên bản được mô tả: repo `1Ci-Company/Jet`, nhánh `community`, commit 80884de, configuration `Jet` version 1.0.2.1, Compatibility mode `Version8_3_24`. Mọi đoạn code dưới đây chép nguyên văn từ dump cấu hình (`cf/`).

## Mục lục

1. [Jet là gì](#1-jet-là-gì)
2. [Cài đặt và mở Jet](#2-cài-đặt-và-mở-jet)
3. [Kiến trúc: lớp ứng dụng Jet trên SSL](#3-kiến-trúc-lớp-ứng-dụng-jet-trên-ssl)
4. [Sáu subsystem ứng dụng](#4-sáu-subsystem-ứng-dụng)
5. [Bảng tổng: Document → Accumulation register](#5-bảng-tổng-document--accumulation-register)
6. [Bảy Accumulation register](#6-bảy-accumulation-register)
7. [Information register chính](#7-information-register-chính)
8. [Catalog chính và Enumeration](#8-catalog-chính-và-enumeration)
9. [Report của Jet](#9-report-của-jet)
10. [Cách Jet tổ chức code](#10-cách-jet-tổ-chức-code)
11. [Cách tự tìm đường trong Jet](#11-cách-tự-tìm-đường-trong-jet)

---

## 1. Jet là gì

Theo README và Wiki của repo:

- **1C:Jet** là một applied solution trên nền tảng 1C, được làm ra **cho người mới học lập trình 1C**. Mục tiêu: giới thiệu sự linh hoạt và khả năng của platform qua một dự án mã nguồn mở có chức năng thực tế.
- Nghiệp vụ: kế toán cơ bản cho công ty nhỏ — mua hàng, bán hàng, kho, tiền mặt/ngân hàng, tạm ứng (advance payments), tính lợi nhuận. README nhấn mạnh code "clean, readable" và đơn giản.
- Giấy phép **MIT**. Có các bản địa hoá riêng (Jet-TR, Jet-ES, Jet-ID) với nhánh `community-tr`, `community-es`, `community-id`.
- Nền tảng khuyến nghị: **8.3.24** (README). Trang Wiki cài platform hướng dẫn bản Training Platform 8.3.25.1445 tải từ my.1ci.com.

Chức năng theo trang Wiki *Features* (rút gọn):

| Mảng | Có gì |
|---|---|
| Base functionality (SSL) | Users & rights, external reports/data processors, currencies, notes, reminders, contact info, additional properties, batch edit, print forms, to-do list, marked objects deletion, report options |
| Purchases | Catalog Counterparties, Products, Tax rates (VATRates); Document Supplier invoice; report Purchases |
| Sales | Price types, price list; Document Sales invoice; report Sales |
| Warehouse | Catalog Warehouses "with negative balance control"; Document Inventory increase (nhập số dư đầu), Inventory write-off, Inventory transfer; report Warehouse balance |
| Cash & Bank | Catalog Cash accounts, Bank accounts; Document Cash receipt / Cash voucher, Bank receipt / Bank payment; hai operation: Counterparty transaction và Other |
| AP/AR | Advance payments; report công nợ khách hàng / nhà cung cấp |
| Costing & profit | "average cost tracking via document sequencing"; report Cost of goods in stock, Sales revenue |

## 2. Cài đặt và mở Jet

> **Cho sinh viên của khóa:** dùng thư mục cài đặt của khóa (platform Windows / macOS, `jet.dt`, `jet.cf`, `queryconsole.epf`) và platform **8.3.25.1445** — xem `references/chung-thuat-ngu-lien-ket-tai-nguyen.md#tai-nguyen`. Phần dưới đây là cách cài theo Wiki của repo Jet.

Tóm tắt Wiki (chi tiết: các trang *How to install platform*, *How to install Jet using the installer / using the repository*, *1C:Jet Initial Setup Guide*):

1. Cài platform 1C:Enterprise (đăng ký tài khoản Developer trên my.1ci.com → Distributives → Tools for Developers → Training Platform).
2. Cài Jet — hai cách:
   - **Installer**: chạy `setup.exe` → mở platform → "Create infobase from template" → chọn **1C:Jet (demo)** (có dữ liệu mẫu) hoặc **1C:Jet** (trống).
   - **Từ repository** (cách sinh viên nên dùng khi làm dự án): clone repo → tạo infobase "with no configuration" → mở **Designer** → Configuration → Open configuration → **Configuration → Restore configuration from files** → chọn thư mục `cf` → Debug → Start debugging.
3. Lần đầu vào **Enterprise mode**: tạo user có quyền Administrator, đăng nhập lại bằng user đó, bật các tính năng cần (properties, notes & reminders, email, message templates, additional reports and data processors…), nhập thông tin công ty và chọn **presentation currency**.
4. Đóng góp code: fork repo, làm trên nhánh `community`, mở pull request vào `community` (trang *Contributing*).

## 3. Kiến trúc: lớp ứng dụng Jet trên SSL

Jet = **SSL (Standard Subsystems Library) + lớp ứng dụng Jet**. Phần lớn object trong `cf/` (Users, AccessGroups, Files, Interactions, PrintManagement, AttachableCommands…) là của SSL — module `InfobaseUpdateSSL` khai báo SSL version "3.1.10.348". Phần nghiệp vụ của Jet nhỏ và dễ đọc: 16 Document thì 9 là của Jet, 7 Accumulation register, ~10 Catalog, 14 common module.

Thuộc tính configuration (từ `cf/Configuration.xml`): `Name` = Jet, `Version` = 1.0.2.1, `DefaultRunMode` = ManagedApplication, `ScriptVariant` = English, `DataLockControlMode` = Managed, `CompatibilityMode` = Version8_3_24.

### 3.1. Common module của Jet

Cờ lấy từ `cf/CommonModules/<Name>.xml` (chỉ liệt kê cờ = true). Cột "Reuse" là `ReturnValuesReuse` (xem Bài 14 về reuse return values).

| Module | Cờ | Reuse | Vai trò (đọc từ code) |
|---|---|---|---|
| `PostingManagement` | Server, ExternalConnection | DontUse | Khung posting dùng chung cho mọi Document: khởi tạo `AdditionalProperties`, chuẩn bị và ghi record set, các thủ tục `Reflect<Register>` nạp bảng giá trị vào `RegisterRecords` |
| `ObjectFillingJet` | Server, ExternalConnection | DontUse | `FillDocument` — điền mặc định khi tạo Document: `Author`, `Currency`/`ExchangeRate`/`Multiplier` |
| `InfobaseUpdateJet` | Server, ExternalConnection, ClientOrdinaryApplication | DontUse | Khai báo Jet là một "subsystem" với SSL (Name, Version) và đăng ký update handler |
| `JetServer` | Server, ExternalConnection | DontUse | `GetPresentationCurrency` (đọc từ `Catalogs.Companies.MainCompany`), `GetQueryUnion`, `GetQueryDelimeter` — chuỗi ghép query text |
| `JetServerCall` | Server, ServerCall | DontUse | `GetVATRateValue` — cầu nối client gọi server, chuyển tiếp sang `JetCached` |
| `JetCached` | Server | DuringSession | `GetVATRateValue` — đọc `Rate` của VATRates, cache trong phiên |
| `JetClientServer` | ClientManagedApplication, Server, ExternalConnection | DontUse | `CalculateFromCurrencyToCurrency` — quy đổi số tiền giữa hai tỷ giá |
| `InventoryTabularSectionClientServer` | ClientManagedApplication, Server, ExternalConnection | DontUse | `CalculateAmount`, `CalculateVATAmountAndTotal` — tính dòng của tabular section `Inventory` |
| `PriceManagementClient` | ClientManagedApplication | DontUse | `RefillTabularSectionPricesByPriceType` — điền lại giá cả bảng theo `PriceType` của form |
| `PriceManagementServerCall` | Server, ServerCall | DontUse | `GetProductPriceByPriceType`, `GetTabularSectionPricesByPriceType` — query `InformationRegister.Prices.SliceLast` |
| `CashManagementClient` | ClientManagedApplication | DontUse | `RecalculateAmountAtExchangeRate` — tính lại cột `Amount` của `PaymentDetails` theo tỷ giá |
| `CashManagementServerCall` | Server, ServerCall | DontUse | `CurrencyExchangeRateData` — lấy currency + tỷ giá theo cash/bank account và ngày |
| `ImportDataFromFileJet` | Server, ExternalConnection | DontUse | `MapDataToImport`, `FillInListOfAmbiguities` — ánh xạ dữ liệu import từ file vào Products (dùng cho SSL ImportDataFromFile) |
| `UserRemindersJet` | Server, ExternalConnection | DontUse | `OnFillToDoList` — đưa số reminder của user vào To-do list của SSL |

Quy ước tên dễ thấy: hậu tố `Client`, `ServerCall`, `ClientServer`, `Cached` khớp với cờ của module (giống quy ước SSL — xem Bài 14, Bài 21); hậu tố `Jet` (`ObjectFillingJet`, `InfobaseUpdateJet`, `UserRemindersJet`, `ImportDataFromFileJet`) đánh dấu module Jet "cắm" vào một cơ chế SSL cùng tên.

### 3.2. Jet cắm vào SSL ở đâu

SSL có các common module `*Overridable` để configuration điền code riêng. Trong Jet, các chỗ có code Jet thật (không phải comment mẫu):

| Module SSL (Overridable) | Code Jet trong đó |
|---|---|
| `ConfigurationSubsystemsOverridable.OnAddSubsystems` | `SubsystemsModules.Add("InfobaseUpdateJet");` |
| `PrintManagementOverridable.OnDefinePrintSettings` | Đăng ký manager của 9 Document Jet vào `Settings.PrintObjects` |
| `ToDoListOverridable.OnDetermineToDoListHandlers` | Thêm `DataProcessors.InventoryCostRecalculation` và (nếu bật functional option `UseUserReminders`) `UserRemindersJet` |
| `AdditionalReportsAndDataProcessorsOverridable` | Thêm các section như `Metadata.Subsystems.Warehouses` |
| `ContactsManagerOverridable` | Contact information kinds cho Counterparties, Warehouses |
| `InteractionsClientServerOverridable` | SalesInvoice, SupplierInvoice làm subject; Counterparties làm contact |

Ngoài ra Jet dùng **Defined types** của SSL để gắn object vào chức năng SSL, ví dụ `AttachedFilesOwner` (Counterparties, Products, Warehouses, các Document), `ReminderSubject`, `NotesSubject`, `ObjectWithAdditionalCommands` (chỉ có `DocumentRef.SalesInvoice`).

## 4. Sáu subsystem ứng dụng

Lấy từ `<Content>` trong `cf/Subsystems/<Name>.xml` và các subsystem con `cf/Subsystems/<Name>/Subsystems/*.xml`. Một object có thể nằm ở nhiều subsystem (Products, Counterparties, Units, Currencies). Bốn subsystem đầu là nơi các nhóm sinh viên mở rộng.

| Subsystem (Synonym) | Subsystem con → thành viên | Thành viên trực tiếp |
|---|---|---|
| **Warehouses** | Catalogs → Catalog Units, Warehouses, Products · Warehouse → Document InventoryIncrease, InventoryTransfer, InventoryWriteOff | AccumulationRegister InventoryInWarehouses, InventoryCost · Report AvailableStock, StockStatement · DataProcessor InventoryCostRecalculation · Sequence InventoryCostRecalculation · Role UseWarehouses · CommonCommand AdditionalReportsWarehouses, AdditionalDataProcessorsWarehouses, ReportPanelWarehouses |
| **Purchases** | Purchases → Document SupplierInvoice · Catalogs → Catalog Counterparties, Products, Units | AccumulationRegister Purchases, SupplierBalance · Report Purchases, SupplierBalance · Role UsePurchases · CommonCommand AdditionalReportsPurchases, AdditionalDataProcessorsPurchases, ReportPanelPurchases |
| **Sales** | Sales → Document SalesInvoice · Catalogs → Catalog Counterparties, Products, Units · Pricing → Catalog PriceTypes, DataProcessor PricesSetup, CommonModule PriceManagementServerCall, InformationRegister Prices | AccumulationRegister Sales, CustomerBalance · Report Sales, CustomerBalance, ProfitOnSales, PriceList · Role UseSales · CommonCommand AdditionalReportsSales, AdditionalDataProcessorsSales, ReportPanelSales |
| **CashManagement** ("Cash management") | Bank → Document BankPayment, BankReceipt · CashInHand ("Cash-in-hand") → Document CashReceipt, CashVoucher · Catalogs → Catalog Currencies, CashAccounts, BankAccounts | AccumulationRegister CashBalance · Report CashStatement · Enum CashTypes, BankPaymentOperations, BankReceiptOperations, CashReceiptOperations, CashVoucherOperations · CommonModule CashManagementServerCall, CashManagementClient · Role UseCashManagement · CommonCommand AdditionalReportsCashManagement, AdditionalDataProcessorsCashManagement, ReportPanelCashManagement |
| **Company** | Company → Catalog Companies, Currencies · Taxes → Catalog VATRates | Role UseCompany · CommonCommand AdditionalReportsCompany, AdditionalDataProcessorsCompany |
| **Administration** | UserMonitoring → các report về user/quyền (AccessRightsAnalysis, RolesRights, UsersInfo…) | Gần như toàn bộ là object SSL: Catalog Users, AccessGroups, Currencies…, DataProcessor SSLAdministrationPanel, EventLog, ImportDataFromFile… |

Mỗi subsystem nghiệp vụ đi kèm một Role `Use<Subsystem>` — khi thêm object mới vào subsystem, nhớ cấp quyền trong role tương ứng (xem Bài 20).

## 5. Bảng tổng: Document → Accumulation register

Cột "RegisterRecords" đọc từ `<RegisterRecords>` trong `cf/Documents/<Doc>.xml`; cột "Reflect…" là các lời gọi `PostingManagement.Reflect…` trong procedure `Posting` của `ObjectModule.bsl`; hướng ghi (Receipt/Expense) đọc từ query trong `InitializeDocumentData` của `ManagerModule.bsl`. Cả 9 Document đều có `Posting` = Allow, `RealTimePosting` = Deny, `RegisterRecordsDeletion` = AutoDeleteOff, `RegisterRecordsWritingOnPost` = WriteSelected, **Post in privileged mode** = true.

| Document | Subsystem | RegisterRecords | Hướng ghi chính | Ghi chú |
|---|---|---|---|---|
| `SupplierInvoice` | Purchases | Purchases, SupplierBalance, InventoryInWarehouses, InventoryCost | InventoryInWarehouses/InventoryCost: Receipt; SupplierBalance: Receipt (Liability), kèm cặp Receipt Advance / Expense Liability khi cấn trừ tạm ứng | Chỉ dòng `ProductType = Inventory` mới vào 2 register kho; có control âm kho |
| `SalesInvoice` | Sales | Sales, CustomerBalance, InventoryInWarehouses, InventoryCost | InventoryInWarehouses/InventoryCost: Expense; giá vốn tính bình quân từ `InventoryCost.Balance` | Nằm trong Sequence `InventoryCostRecalculation`; có control âm kho |
| `InventoryIncrease` | Warehouses | InventoryInWarehouses, InventoryCost | Receipt | Dùng nhập số dư đầu kỳ |
| `InventoryTransfer` | Warehouses | InventoryInWarehouses, InventoryCost | Expense ở `Warehouse`, Receipt ở `WarehouseReceiver` | Nằm trong Sequence |
| `InventoryWriteOff` | Warehouses | InventoryInWarehouses, InventoryCost | Expense | Nằm trong Sequence |
| `CashReceipt` | CashManagement | CashBalance, CustomerBalance | CashBalance: Receipt, `CashType` = Cash; CustomerBalance: Expense | `BasedOn` = SalesInvoice |
| `CashVoucher` | CashManagement | CashBalance, SupplierBalance | CashBalance: Expense, Cash; SupplierBalance: Expense | `BasedOn` = SupplierInvoice |
| `BankReceipt` | CashManagement | CashBalance, CustomerBalance | CashBalance: Receipt, NonCash; CustomerBalance: Expense | `BasedOn` = SalesInvoice |
| `BankPayment` | CashManagement | CashBalance, SupplierBalance | CashBalance: Expense, NonCash; SupplierBalance: Expense | Chỉ ghi khi `Paid` = True; `Period` = `PaymentDate`; `BasedOn` = SupplierInvoice |

Với 4 chứng từ tiền: nếu dòng `PaymentDetails` không chỉ ra hoá đơn (`Document` rỗng) thì bản ghi công nợ có `LiabilityType` = Advance và `Document` = chính chứng từ thanh toán; ngược lại là Liability theo hoá đơn. Khi Operation = Other, query chỉ lấy dòng có Operation Supplier/Customer cho register công nợ, nên chứng từ "Other" chỉ ghi CashBalance.

Các Document còn lại **không phải nghiệp vụ Jet**: `IncomingEmail`, `OutgoingEmail`, `Meeting`, `PhoneCall`, `PlannedInteraction`, `SMSMessage` (thuộc subsystem Interactions của SSL) và `PricesSetupAuxiliary` (Document phụ, `Posting` = Deny, chỉ có tabular section `ProductPrices`, dùng làm bảng đích khi import giá trong DataProcessor `PricesSetup`). Không Document nào trong số này có RegisterRecords.

**Sequence** `InventoryCostRecalculation` (`cf/Sequences/InventoryCostRecalculation.xml`): Documents = InventoryTransfer, InventoryWriteOff, SalesInvoice; RegisterRecords = InventoryCost; `MoveBoundaryOnPosting` = Move. Đây là cơ chế "average cost tracking via document sequencing": DataProcessor `InventoryCostRecalculation` gọi `Sequences.InventoryCostRecalculation.Restore()` để post lại các chứng từ xuất khi biên sequence bị lùi. [suy luận] SupplierInvoice và InventoryIncrease không nằm trong sequence vì chứng từ nhập không phụ thuộc giá vốn bình quân hiện có.

## 6. Bảy Accumulation register

Đọc từ `cf/AccumulationRegisters/<Name>.xml`. Không register nào có Attribute. Nhắc lại: kind **Balances** có virtual table Balance/BalanceAndTurnovers; **Turnovers** chỉ có Turnovers (Bài 11).

| Register | Kind | Dimensions | Resources | Ai ghi |
|---|---|---|---|---|
| `InventoryInWarehouses` | Balances | `Product` (CatalogRef.Products), `Warehouse` (CatalogRef.Warehouses) | `Quantity` | SupplierInvoice, SalesInvoice, InventoryIncrease, InventoryTransfer, InventoryWriteOff |
| `InventoryCost` | Balances | `Product` (Products), `Warehouse` (Warehouses) | `Quantity`, `Amount` | như trên |
| `Purchases` | Turnovers | `Counterparty` (Counterparties), `Product` (Products), `PurchaseDocument` (DocumentRef.SupplierInvoice) | `Quantity`, `Amount`, `VATAmount` | SupplierInvoice |
| `Sales` | Turnovers | `Counterparty`, `Product`, `SalesDocument` (DocumentRef.SalesInvoice) | `Quantity`, `Amount`, `VATAmount` | SalesInvoice |
| `SupplierBalance` | Balances | `LiabilityType` (EnumRef.LiabilityTypes), `Counterparty`, `Document` (DocumentRef.BankPayment / CashVoucher / SupplierInvoice) | `Amount` | SupplierInvoice, BankPayment, CashVoucher |
| `CustomerBalance` | Balances | `LiabilityType`, `Counterparty`, `Document` (DocumentRef.SalesInvoice / CashReceipt / BankReceipt) | `Amount` | SalesInvoice, BankReceipt, CashReceipt |
| `CashBalance` | Balances | `BankCashAccount` (CatalogRef.CashAccounts / BankAccounts), `CashType` (EnumRef.CashTypes) | `AmountCur` | CashReceipt, CashVoucher, BankReceipt, BankPayment |

Điểm đáng học: dimension `Document` và `BankCashAccount` có **kiểu phức hợp** (composite type); `InventoryCost` có `EnableTotalsSplitting` = true. Chỉ `InventoryInWarehouses` có module: `ManagerModule.bsl` (procedure `NegativeBalanceControl`) và `RecordSetModule.bsl` (`BeforeWrite`/`OnWrite` tính phần thay đổi để kiểm tra âm kho — xem mục 10.2).

## 7. Information register chính

| Register | Periodicity | WriteMode | Dimensions | Resources | Ghi chú |
|---|---|---|---|---|---|
| `Prices` (Jet) | Day | Independent | `PriceType` (CatalogRef.PriceTypes), `Product` (CatalogRef.Products) | `Price` | Ghi bởi DataProcessor `PricesSetup` (`InformationRegisters.Prices.CreateRecordSet()`); đọc bằng `SliceLast` trong `PriceManagementServerCall` và report `PriceList` |
| `ExchangeRates` | Day | Independent | `Currency` (CatalogRef.Currencies) | `Rate`, `Repetition` | [suy luận] thuộc phần tiền tệ của SSL; Jet đọc qua `CurrencyRateOperations.GetCurrencyRate` (module SSL) |

Hầu hết ~80 Information register khác (Access…, Files…, Update…, UserReminders…) là của SSL.

Ví dụ đọc giá theo `SliceLast` (xem Bài 12):

Nguồn: Jet — cf/CommonModules/PriceManagementServerCall/Ext/Module.bsl
```bsl
	Query = New Query;
	Query.Text =
	"SELECT ALLOWED
	|	PricesSliceLast.Price * &DocumentRepetition / &DocumentRate AS Price
	|FROM
	|	InformationRegister.Prices.SliceLast(
	|			&PriceDate,
	|			PriceType = &PriceType
	|				AND Product = &Product) AS PricesSliceLast";
```

## 8. Catalog chính và Enumeration

Chỉ liệt kê attribute developer thêm (ngoài standard attributes Code/Description). Gần như mọi Catalog/Document của Jet có tabular section `AdditionalAttributes` — đó là phần của SSL Properties, không phải dữ liệu nghiệp vụ.

| Catalog | Hierarchical | Attribute chính | Ghi chú |
|---|---|---|---|
| `Products` | true | `DetailedDescription`, `ProductType` (Enum.ProductTypes), `Unit` (Catalog.Units), `VATRate` (Catalog.VATRates) | Dòng có `ProductType` = Service không ghi vào register kho |
| `Counterparties` | true | `Customer`, `Supplier` (Boolean), `LegalName`, `TIN`, `PriceType` (Catalog.PriceTypes), `IsIndividual` | Tabular section `ContactInformation` (SSL); command `Customers`, `Suppliers` |
| `Warehouses` | false | — | `ContactInformation` |
| `PriceTypes` | false | — | |
| `CashAccounts` | false | `Currency` | |
| `BankAccounts` | false | `AccountNumber`, `IBAN`, `Bank`, `SWIFT`, `Currency` | |
| `Companies` | false | `LegalName`, `TIN`, `PresentationCurrency` (Catalog.Currencies), `IsIndividual`, `RegistrationNumber`, `RegistrationCountry`, `RegistrationDate` | Predefined item `MainCompany`; `JetServer.GetPresentationCurrency` đọc từ đây |
| `Units` | false | — | |
| `VATRates` | false | `Rate` | Manager module có `GetExemptFromVATRate` (tìm hoặc tạo mức 0%) |
| `Currencies` | false | `ImportingFromInternet`, `DescriptionFull`, `Markup`, `MainCurrency`, `AmountInWordsParameters`, `RateCalculationFormula`, `RateSource` | [suy luận] Catalog của SSL (module có logic tỷ giá kiểu SSL) |

Enumeration nghiệp vụ: `ProductTypes` (Inventory, Service) · `LiabilityTypes` (Liability, Advance) · `CashTypes` (Cash, NonCash) · `BankPaymentOperations` / `CashVoucherOperations` (Supplier, Other) · `BankReceiptOperations` / `CashReceiptOperations` (Customer, Other).

Header của Document nghiệp vụ (để biết field nào có sẵn):

| Document | Header attributes | Tabular sections |
|---|---|---|
| SupplierInvoice | `Supplier`, `Warehouse`, `Currency`, `ExchangeRate`, `Multiplier`, `Comment`, `Author`, `Total`, `ExemptFromVAT` | `Inventory` (Product, Quantity, Price, Amount, VATRate, VATAmount, Total), `AdvanceClearing` (Document: BankPayment/CashVoucher, Amount, AmountCur) |
| SalesInvoice | `Customer`, `Warehouse`, `Currency`, `ExchangeRate`, `Multiplier`, `PriceType`, `Comment`, `Author`, `Total`, `BankAccount`, `ExemptFromVAT` | `Inventory` (như trên), `AdvanceClearing` (Document: CashReceipt/BankReceipt, Amount, AmountCur) |
| InventoryIncrease | `Warehouse`, `Comment`, `Author` | `Inventory` (Product, Quantity, Price, Amount) |
| InventoryTransfer | `Warehouse`, `WarehouseReceiver`, `Comment`, `Author` | `Inventory` (Product, Quantity) |
| InventoryWriteOff | `Warehouse`, `Comment`, `Author` | `Inventory` (Product, Quantity) |
| CashReceipt / CashVoucher | `Operation`, `CashAccount`, `Counterparty`, `Currency`, `ExchangeRate`, `Multiplier`, `Comment`, `Author`, `PaymentAmount` | `PaymentDetails` (Document, PaymentAmount, Amount) |
| BankReceipt | như trên nhưng `BankAccount` thay `CashAccount` | `PaymentDetails` |
| BankPayment | như BankReceipt + `Paid`, `PaymentDate` | `PaymentDetails` |

## 9. Report của Jet

Tất cả là report DCS với template `MainDataCompositionSchema` (Bài 18). Nguồn dữ liệu (đọc từ template):

| Report | Subsystem | Nguồn |
|---|---|---|
| AvailableStock | Warehouses | `AccumulationRegister.InventoryInWarehouses.Balance` |
| StockStatement | Warehouses | `AccumulationRegister.InventoryCost.BalanceAndTurnovers` |
| Purchases | Purchases | `AccumulationRegister.Purchases.Turnovers` |
| SupplierBalance | Purchases | `AccumulationRegister.SupplierBalance.Balance` |
| Sales | Sales | `AccumulationRegister.Sales.Turnovers` |
| CustomerBalance | Sales | `AccumulationRegister.CustomerBalance.Balance` |
| ProfitOnSales | Sales | `AccumulationRegister.Sales.Turnovers` + `AccumulationRegister.InventoryCost.Turnovers` |
| PriceList | Sales | `InformationRegister.Prices.SliceLast` |
| CashStatement | CashManagement | `AccumulationRegister.CashBalance.BalanceAndTurnovers` |

## 10. Cách Jet tổ chức code

### 10.1. Posting: một khung chung cho mọi Document

Mọi Document nghiệp vụ của Jet post theo cùng một khuôn 3 tầng:

1. **Object module** (`Posting`) — chỉ điều phối, gọi lần lượt các bước.
2. **Manager module** (`InitializeDocumentData`) — một batch query đọc dữ liệu chứng từ, tạo sẵn các bảng giá trị có đúng cột của register, cất vào `AdditionalProperties.TableForRegisterRecords` với tên `Table<RegisterName>`.
3. **Common module `PostingManagement`** — code chung: khởi tạo, xoá bản ghi cũ, `Load` bảng vào record set, ghi.

So với Bài 11 (viết thẳng `RegisterRecords.X.Add()` trong vòng lặp), cách này tách "lấy dữ liệu bằng query" khỏi "ghi register", và dùng lại được cho mọi Document.

**Bước 1 — Object module của Document.** Đây là toàn bộ `Posting` và `UndoPosting` của SupplierInvoice:

Nguồn: Jet — cf/Documents/SupplierInvoice/Ext/ObjectModule.bsl
```bsl
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

Procedure UndoPosting(Cancel)
	
	// Initialization of additional properties for document posting.
	PostingManagement.InitializeAdditionalPropertiesForPosting(Ref, AdditionalProperties);
	
	// Preparation of records sets.
	PostingManagement.PrepareRecordSetsForWriting(ThisObject);
	
	// Writing of the records sets.
	PostingManagement.WriteRecordSets(ThisObject);
	
	// Negative balance control
	AccumulationRegisters.InventoryInWarehouses.NegativeBalanceControl(Ref, AdditionalProperties, Cancel);
	
EndProcedure
```

Các Document khác giống hệt, chỉ khác tên Document và danh sách `Reflect…` (ví dụ BankPayment gọi `ReflectCashBalance` + `ReflectSupplierBalance`, không gọi `NegativeBalanceControl`). `UndoPosting` không nạp bảng nào nên chỉ xoá bản ghi cũ.

**Bước 2 — Manager module: `InitializeDocumentData`.** Batch query dùng temporary table (`INTO DocumentHeader`, `INTO DocumentInventory`, `INTO ProductTable`…), mỗi query cuối trả về đúng cột của một register (có cả `RecordType`, `Period`). Phần kết của SupplierInvoice:

Nguồn: Jet — cf/Documents/SupplierInvoice/Ext/ManagerModule.bsl
```bsl
	|SELECT
	|	VALUE(AccumulationRecordType.Receipt) AS RecordType,
	|	ProductTable.Period AS Period,
	|	ProductTable.Product AS Product,
	|	ProductTable.Warehouse AS Warehouse,
	|	ProductTable.Quantity AS Quantity,
	|	ProductTable.Amount AS Amount
	|FROM
	|	ProductTable AS ProductTable";
	
	Query.SetParameter("Ref", SupplierInvoiceRef);
	
	QueryResult = Query.ExecuteBatch();
	
	AdditionalProperties.TableForRegisterRecords.Insert("TablePurchases", QueryResult[4].Unload());
	AdditionalProperties.TableForRegisterRecords.Insert("TableInventoryInWarehouses", QueryResult[5].Unload());
	AdditionalProperties.TableForRegisterRecords.Insert("TableSupplierBalance", QueryResult[6].Unload());
	AdditionalProperties.TableForRegisterRecords.Insert("TableInventoryCost", QueryResult[7].Unload());
	
EndProcedure
```

Chú ý chỉ số `QueryResult[n]` phải khớp thứ tự query trong batch — thêm/bớt một query ở giữa là phải sửa lại các chỉ số này (lỗi hay gặp khi sinh viên mở rộng).

**Bước 3 — `PostingManagement`.** Ba thủ tục khung:

Nguồn: Jet — cf/CommonModules/PostingManagement/Ext/Module.bsl
```bsl
Procedure InitializeAdditionalPropertiesForPosting(DocumentRef, AdditionalProperties) Export
	
	// Structure that will contain values table with data for movings execution.
	AdditionalProperties.Insert("TableForRegisterRecords", New Structure);
	
	// Contains the properties required for posting.
	AdditionalProperties.Insert("ForPosting", New Structure);
	
	// Stores the value of the temporary table manager
	AdditionalProperties.ForPosting.Insert("TempTablesManager", New TempTablesManager);
	
	// Contains the document metadata.
	AdditionalProperties.Insert("DocumentMetadata", DocumentRef.Metadata());
	
EndProcedure

// ...

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

Procedure WriteRecordSets(DocumentObject) Export
	
	For Each RecordSet In DocumentObject.RegisterRecords Do
		If RecordSet.Write Then
			RecordSet.AdditionalProperties.Insert("ForPosting", DocumentObject.AdditionalProperties.ForPosting);
			RecordSet.Write();
			RecordSet.Write = False;
		EndIf;
	EndDo;
	
EndProcedure
```

Và mỗi register có một `Reflect<Register>` cùng một mẫu (7 bản: Purchases, Sales, InventoryInWarehouses, CashBalance, CustomerBalance, SupplierBalance, InventoryCost):

Nguồn: Jet — cf/CommonModules/PostingManagement/Ext/Module.bsl
```bsl
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

Ý nghĩa từng bước:

- `PrepareRecordSetsForWriting` xoá record set trong bộ nhớ, rồi dùng hàm private `GetUsedRegisterNames` (query `SELECT TOP 1 … WHERE RegisterTable.Recorder = &Recorder` ghép bằng `JetServer.GetQueryUnion()` cho từng register trong `DocumentMetadata.RegisterRecords`) để tìm các register **đang có bản ghi cũ** của chứng từ và đặt `Write = True` — nhờ vậy bản ghi cũ bị ghi đè bằng tập rỗng nếu lần post này không còn ghi vào register đó. Điều này đi cùng thuộc tính `RegisterRecordsWritingOnPost` = WriteSelected (chỉ record set có `Write = True` mới được platform ghi — ngoài giáo trình, hãy kiểm tra lại trong Syntax assistant).
- `Reflect…` chỉ `Load` bảng đã chuẩn bị — không có logic nghiệp vụ. Logic nằm hết trong query của manager module.
- `WriteRecordSets` ghi chủ động từng record set và **truyền `ForPosting` (chứa `TempTablesManager`) sang `RecordSet.AdditionalProperties`** — đây là cầu nối để record set module của register dùng chung temporary table với chứng từ.

### 10.2. Kiểm soát âm kho (negative balance control)

Chuỗi xử lý trải trên 3 nơi:

1. `RecordSetModule` của `InventoryInWarehouses`, event `BeforeWrite`: đặt managed lock (`DataLock`, mode Exclusive) theo `Recorder`, lưu bản ghi cũ vào temp table `InventoryInWarehousesBeforeWrite`.
2. Event `OnWrite`: tính chênh lệch cũ/mới vào temp table `InventoryInWarehousesChange`, đặt cờ `AdditionalProperties.ForPosting.IsInventoryInWarehousesChange`.
3. Object module gọi `AccumulationRegisters.InventoryInWarehouses.NegativeBalanceControl` sau `WriteRecordSets`: nếu cờ bật, join temp table với `Balance(, )` để tìm số dư < 0 và báo lỗi bằng `Common.MessageToUser(..., Cancel)` (module SSL).

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
```

Đây là phương án "kiểm tra sau khi ghi" (ghi trước, đọc Balance sau, nếu âm thì `Cancel`) — khác với cách kiểm tra trước khi ghi trong Bài 11–12; đáng để sinh viên so sánh.

### 10.3. Giá vốn bình quân trong SalesInvoice

`InitializeDocumentData` của SalesInvoice khoá `AccumulationRegister.InventoryCost` theo Product/Warehouse, rồi đọc `InventoryCost.Balance(&PointInTime, …)` với `PointInTime` = `New Boundary(DocumentObject.PointInTime(), BoundaryType.Including)` (Bài 11), cộng lại bản ghi cũ của chính chứng từ, và chia tỷ lệ:

Nguồn: Jet — cf/Documents/SalesInvoice/Ext/ManagerModule.bsl
```bsl
	|	CASE
	|		WHEN ISNULL(InventoryCostTable.Quantity, 0) = 0
	|			THEN 0
	|		WHEN ProductTable.Quantity = InventoryCostTable.Quantity
	|			THEN InventoryCostTable.Amount
	|		ELSE CAST(InventoryCostTable.Amount * ProductTable.Quantity / InventoryCostTable.Quantity AS NUMBER(15, 2))
	|	END AS Amount
```

InventoryTransfer và InventoryWriteOff dùng cùng ý tưởng.

### 10.4. Region trong module

Jet dùng các tên `#Region` chuẩn SSL (Bài 23). Đếm trên các object nghiệp vụ của Jet:

| Loại module | Region dùng |
|---|---|
| Object module | `EventHandlers` (bọc trong `#If Server Or ExternalConnection Then … #EndIf`) |
| Manager module | `Public` (gồm `InitializeDocumentData` và các khối SSL như `// StandardSubsystems.Print … // End StandardSubsystems.Print`) |
| Form module | `FormEventHandlers`, `FormHeaderItemsEventHandlers`, `FormTableItemsEventHandlers<TênBảng>` (ví dụ `FormTableItemsEventHandlersInventory`, `…PaymentDetails`, `…AdvanceClearing`, `…List`), `FormCommandsEventHandlers`, `Private` |
| Common module Jet | `Public`, `Private` (JetServer có region lồng `WorkWithQuery`; InfobaseUpdateJet có `ForCallsFromOtherSubsystems`) |

Trong một region, code gọi SSL được bọc bằng cặp comment `// StandardSubsystems.<Tên>` … `// End StandardSubsystems.<Tên>` — dấu hiệu nhanh để phân biệt "code Jet" với "đoạn tích hợp SSL".

### 10.5. Quy ước đặt tên

- Object: danh từ tiếng Anh, PascalCase, Catalog số nhiều (`Products`, `Warehouses`), Document số ít (`SalesInvoice`).
- Tabular section dùng lại tên cố định: `Inventory` (hàng hoá), `PaymentDetails` (chứng từ tiền), `AdvanceClearing` (cấn trừ tạm ứng) — nhờ vậy `InventoryTabularSectionClientServer` và `CashManagementClient` dùng chung được.
- Cặp tiền tệ trên header: `Currency`, `ExchangeRate`, `Multiplier`; số tiền quy đổi ra presentation currency trong query (`Amount * ExchangeRate / Multiplier`).
- Bảng trong `TableForRegisterRecords`: `Table<RegisterName>`; thủ tục ghi: `Reflect<RegisterName>`.
- Form item handler: `<Bảng><Cột>OnChange` (ví dụ `InventoryProductOnChange`), form tự đặt `FormManagement()` để bật/tắt item.
- Handler của SSL trong form có tiền tố `Attachable_` (`Attachable_ExecuteCommand`, `Attachable_UpdateCommands`, `Attachable_PropertiesExecuteCommand`).
- Cách chia client/server trong form: handler `&AtClient` gom tham số vào một `Structure` (`DataStructure`) rồi gọi procedure `&AtServerNoContext` (`GetProductData`, `GetExchangeRateData`) hoặc common module `…ServerCall` — đúng nguyên tắc giảm số lần gọi server (Bài 7).

### 10.6. Filling: `ObjectFillingJet`

Cả 9 Document nghiệp vụ có event `Filling` gọi một dòng:

Nguồn: Jet — cf/Documents/SupplierInvoice/Ext/ObjectModule.bsl
```bsl
Procedure Filling(FillingData, FillingText, StandardProcessing)
	
	ObjectFillingJet.FillDocument(ThisObject, FillingData);
	
EndProcedure
```

`FillDocument` gán `Author` = `Users.AuthorizedUser()` (SSL) và, nếu Document có attribute `Currency` (kiểm tra bằng `Common.HasObjectAttribute`), điền presentation currency với tỷ giá 1 hoặc tỷ giá của currency được truyền vào. Chứng từ tiền (BankPayment, CashReceipt…) sau dòng đó còn xử lý `FillingData` kiểu `DocumentRef.SupplierInvoice` / `DocumentRef.SalesInvoice` — đó là "nhập dựa trên" (`BasedOn` trong `.xml`, Bài 16).

### 10.7. Print forms

Wiring theo SSL Print (Bài 22):

1. `PrintManagementOverridable.OnDefinePrintSettings` thêm manager Document vào `Settings.PrintObjects`.
2. Manager module của Document: `OnDefinePrintSettings` đặt `Settings.OnAddPrintCommands = True`; `AddPrintCommands` thêm lệnh in.
3. Template trong `Templates/` của Document: `PF_MXL_<Tên>` (SpreadsheetDocument có tham số kiểu `[Customer.LegalName]`, `[Inventory.Product]`…) và `PrintData` (DataCompositionSchema làm nguồn dữ liệu).

Nguồn: Jet — cf/Documents/SalesInvoice/Ext/ManagerModule.bsl
```bsl
	PrintCommand.PrintManager = "PrintManagement";
	PrintCommand.Id = "Document.SalesInvoice.PF_MXL_SalesInvoice";
	PrintCommand.Presentation = NStr("en = 'Sales invoice'");
```

Hiện chỉ SalesInvoice (`PF_MXL_SalesInvoice`) và SupplierInvoice (`PF_MXL_GoodsReceivedNote`) có lệnh in; 7 Document còn lại đã đăng ký nhưng `AddPrintCommands` rỗng — chỗ tốt để giao bài tập "thêm print form".

### 10.8. Attachable commands, Properties, Import from file

- **Attachable commands** (SSL): form của Document gọi `AttachableCommands.OnCreateAtServer(ThisObject)` trong `OnCreateAtServer`, `AttachableCommandsClientServer.UpdateCommands` trong `OnReadAtServer`, và có bộ handler `Attachable_ExecuteCommand` / `Attachable_ContinueCommandExecutionAtServer` / `Attachable_UpdateCommands`. Các procedure trong `AttachableCommandsOverridable` của Jet đều rỗng.
- **Properties** (SSL): `PropertyManager.OnCreateAtServer(ThisObject, AdditionalParameters)` với `ItemForPlacementName` = "GroupAdditionalAttributes" — dữ liệu nằm ở tabular section `AdditionalAttributes`.
- **Import from file** (SSL ImportDataFromFile): command form `ImportInventoryFromFile` gọi `ImportDataFromFileClient.ShowImportForm` với `FullTabularSectionName` = "SupplierInvoice.Inventory"; template `LoadingFromFile` của Document mô tả cột; manager module có `MapDataToImport` / `FillInListOfAmbiguities` chuyển tiếp sang `ImportDataFromFileJet`. Có ở SupplierInvoice, SalesInvoice, InventoryIncrease và `PricesSetupAuxiliary.ProductPrices`.

### 10.9. `InfobaseUpdateJet`

Jet đăng ký mình với cơ chế cập nhật infobase của SSL qua `ConfigurationSubsystemsOverridable.OnAddSubsystems` (mục 3.2). Trong module:

Nguồn: Jet — cf/CommonModules/InfobaseUpdateJet/Ext/Module.bsl
```bsl
Procedure OnAddSubsystem(LongDesc) Export
	
	LongDesc.Name    = "Jet";
	LongDesc.Version = "1.0.2.1";
	LongDesc.DeferredHandlersExecutionMode = "Sequentially";
	
	LongDesc.RequiredSubsystems1.Add("StandardSubsystems");
	
EndProcedure
// ...
Procedure OnAddUpdateHandlers(Handlers) Export
	
	Handler = Handlers.Add();
	Handler.Version			= "1.0.2.1";
	Handler.InitialFilling	= False;
	Handler.ExecutionMode	= "Exclusively";
	Handler.Procedure		= "InfobaseUpdateJet.UpdatePredefinedContactInformationKinds";
	
EndProcedure
```

Khi nhóm sinh viên thêm dữ liệu cần khởi tạo (ví dụ predefined item mới, giá trị mặc định cho attribute mới), đây là chỗ thêm handler — nhớ tăng version của configuration cho khớp `Handler.Version` [suy luận: theo cách SSL so version infobase với version handler].

## 11. Cách tự tìm đường trong Jet

Đường dẫn tính từ thư mục `cf/` (dump) — trong Designer là cây Configuration tương ứng.

| Muốn biết / sửa | Xem ở đâu |
|---|---|
| Document X post vào register nào | `Documents/X.xml` → `<RegisterRecords>`; rồi `Documents/X/Ext/ObjectModule.bsl` → `Posting` |
| Bản ghi register được tính thế nào | `Documents/X/Ext/ManagerModule.bsl` → `InitializeDocumentData` (query) — đếm thứ tự query để khớp `QueryResult[n]` |
| Thêm register mới cho một Document | (1) tạo register; (2) thêm vào `RegisterRecords` của Document; (3) thêm query + `TableForRegisterRecords.Insert("Table<Reg>", …)` trong manager module; (4) thêm `Reflect<Reg>` vào `PostingManagement` theo mẫu; (5) gọi nó trong `Posting`; (6) cấp quyền trong role `Use<Subsystem>` |
| Cấu trúc register (dimension/resource) | `AccumulationRegisters/<Reg>.xml` |
| Kiểm tra âm kho | `AccumulationRegisters/InventoryInWarehouses/Ext/RecordSetModule.bsl` + `ManagerModule.bsl` |
| Giá vốn, post lại chứng từ xuất | `Documents/SalesInvoice/Ext/ManagerModule.bsl`, `Sequences/InventoryCostRecalculation.xml`, `DataProcessors/InventoryCostRecalculation` |
| Giá bán theo PriceType | `InformationRegisters/Prices.xml`, `CommonModules/PriceManagementServerCall`, `DataProcessors/PricesSetup` |
| Tỷ giá, presentation currency | `CommonModules/JetServer` (`GetPresentationCurrency`), `CommonModules/CashManagementServerCall`, `CommonModules/ObjectFillingJet` |
| Tính Amount/VAT trên dòng hàng | `CommonModules/InventoryTabularSectionClientServer`, form `DocumentForm` → region `FormTableItemsEventHandlersInventory` |
| Giá trị mặc định khi tạo chứng từ | `CommonModules/ObjectFillingJet`; nhập dựa trên: event `Filling` của chứng từ tiền + `<BasedOn>` trong `.xml` |
| Kiểm tra bắt buộc nhập | `FillCheckProcessing` trong object module (ví dụ BankPayment bỏ kiểm tra `Counterparty` khi Operation = Other) và `FillCheckProcessingAtServer` trong form |
| Giao diện form, ẩn/hiện item | `Documents/X/Forms/DocumentForm/Ext/Form.xml` (item) + `Form/Module.bsl` → `FormManagement()` |
| Print form | `CommonModules/PrintManagementOverridable`, manager module → `AddPrintCommands`, `Documents/X/Templates/PF_MXL_*` |
| Report | `Reports/<R>/Templates/MainDataCompositionSchema` (mở bằng DCS designer) |
| Object thuộc subsystem/menu nào | `Subsystems/<S>.xml` và `Subsystems/<S>/Subsystems/*.xml` → `<Content>` |
| Quyền | `Roles/Use<Subsystem>` |
| Một module là của Jet hay SSL | Danh sách 14 module ở mục 3.1 là Jet; còn lại là SSL. Trong module SSL `*Overridable`, code Jet là dòng không bị comment có nhắc tới object Jet |
| Thêm update handler / dữ liệu khởi tạo | `CommonModules/InfobaseUpdateJet` → `OnAddUpdateHandlers` |

Mẹo thực hành:

- Bắt đầu đọc từ **một Document** của subsystem nhóm mình: `.xml` → object module → manager module → form module. Ba file đầu thường dưới 250 dòng.
- Tìm "ai gọi hàm này": trong Designer dùng Edit → Find in all modules (hoặc grep thư mục `cf/` nếu làm việc với dump).
- Không sửa module SSL (trừ `*Overridable`) — đó là thư viện; nếu cần thay hành vi, ưu tiên extension (upgrade-safe customization, xem file bài Extensions).
- Đặt breakpoint ở `PostingManagement.WriteRecordSets` rồi post một chứng từ để xem `AdditionalProperties.TableForRegisterRecords` trong Expression window (Bài 8) — cách nhanh nhất để hiểu dữ liệu đi vào register.


---

# § jet-extending

# Thêm đối tượng mới vào Jet đúng cách

Khi nào đọc file này: nhóm sinh viên chuẩn bị thêm Document / Catalog / Report mới vào một subsystem của Jet (Warehouses, Purchases, Sales, CashManagement), phân vân nên sửa thẳng configuration hay làm Extension, hoặc thêm xong mà object "không hiện", "không in được", "Access violation!".

Phiên bản: repo `1Ci-Company/Jet`, nhánh `community`, commit 80884de, configuration `Jet` 1.0.2.1, Compatibility mode `Version8_3_24`. Code và XML chép nguyên văn từ dump `cf/`. Chỗ nào là suy luận được đánh dấu **[suy luận]**.

## Mục lục

1. [Phương pháp: lần theo một Document có sẵn](#1-phương-pháp-lần-theo-một-document-có-sẵn)
2. [Bản đồ touchpoint của InventoryTransfer](#2-bản-đồ-touchpoint-của-inventorytransfer)
3. [Chi tiết từng touchpoint](#3-chi-tiết-từng-touchpoint)
4. [Hai chiến lược: sửa trực tiếp hay Extension](#4-hai-chiến-lược-sửa-trực-tiếp-hay-extension)
5. [Checklist: Thêm một Document mới](#5-checklist-thêm-một-document-mới)
6. [Checklist: Thêm một Catalog mới](#6-checklist-thêm-một-catalog-mới)
7. [Checklist: Thêm một Report (DCS) mới](#7-checklist-thêm-một-report-dcs-mới)
8. [Lỗi thường gặp](#8-lỗi-thường-gặp)

---

## 1. Phương pháp: lần theo một Document có sẵn

Một Document trong Jet không chỉ là `Documents/<Tên>.xml` + module. Vì Jet được xây trên **SSL (Standard Subsystems Library)**, document còn phải được "đăng ký" ở nhiều chỗ khác: subsystem, role, defined type, event subscription, module Overridable… Cách chắc chắn nhất để biết phải đăng ký ở đâu là **tìm mọi chỗ nhắc tới một document mẫu** bên ngoài thư mục của chính nó:

```bash
cd cf
grep -rl "InventoryTransfer" . --include=*.xml --include=*.bsl \
  | grep -v "^./Documents/InventoryTransfer"
```

Kết quả (17 file): `Configuration.xml`; `Subsystems/Warehouses/Subsystems/Warehouse.xml`, `Subsystems/InternalSubsystem.xml`; `Roles/UseWarehouses`, `Roles/FullAccess`; `CommonModules/PrintManagementOverridable`, `CommonModules/PropertyManagerOverridable`; `Catalogs/InventoryTransferAttachedFiles.xml`; `DefinedTypes/` `AttachedFile`, `AttachedFileObject`, `AttachedFilesOwner`, `ReminderSubject`, `ReminderSubjectObject`; `EventSubscriptions/` `DetermineAttachedFileForm`, `SetDeletionMarkForAttachedDocumentFiles`; `ExchangePlans/InfobaseUpdate/Ext/Content.xml`; `Sequences/InventoryCostRecalculation.xml`.

Đây là **danh sách việc phải làm** khi thêm một document kho tương tự. Với nhóm Purchases/Sales, hãy chạy lại lệnh với `SupplierInvoice` / `SalesInvoice` — hai document này có thêm vài touchpoint (mục 3.10).

Mẹo: chạy lệnh tương tự cho object mới của nhóm sau khi làm xong, rồi so số file với document mẫu — thiếu file nào là thiếu bước đăng ký đó.

---

## 2. Bản đồ touchpoint của InventoryTransfer

| # | Touchpoint | File | Ai sở hữu | Bắt buộc cho document mới? |
|---|---|---|---|---|
| 1 | Danh sách object của configuration | `Configuration.xml` | platform | Có — [suy luận] Designer tự thêm khi tạo object |
| 2 | Subsystem Content | `Subsystems/Warehouses/Subsystems/Warehouse.xml` | Jet | Có — để hiện trên giao diện |
| 3 | Role nghiệp vụ | `Roles/UseWarehouses/Ext/Rights.xml` | Jet | Có |
| 4 | Role FullAccess | `Roles/FullAccess/Ext/Rights.xml` | SSL role | Có — bỏ InteractiveDelete |
| 5 | Print subsystem | `CommonModules/PrintManagementOverridable` | SSL Overridable, có code Jet | Có nếu muốn nút Print |
| 6 | Additional attributes (Properties) | `CommonModules/PropertyManagerOverridable` | SSL Overridable, có code Jet | Có nếu copy form từ document mẫu |
| 7 | Catalog attached files | `Catalogs/InventoryTransferAttachedFiles.xml` | Jet | Tuỳ chọn (Files operations) |
| 8 | Defined types file | `DefinedTypes/AttachedFile*.xml` | SSL | Đi kèm #7 |
| 9 | Event subscriptions file | `EventSubscriptions/DetermineAttachedFileForm.xml`, `SetDeletionMarkForAttachedDocumentFiles.xml` | SSL | Đi kèm #7 |
| 10 | Exchange plan InfobaseUpdate | `ExchangePlans/InfobaseUpdate/Ext/Content.xml` | SSL | Đi kèm #7 |
| 11 | InternalSubsystem | `Subsystems/InternalSubsystem.xml` | Jet | Đi kèm #7 (nơi chứa catalog kỹ thuật) |
| 12 | Defined types reminder | `DefinedTypes/ReminderSubject*.xml` | SSL | Tuỳ chọn (nhắc việc) |
| 13 | Sequence | `Sequences/InventoryCostRecalculation.xml` | Jet | Có nếu document ghi vào `InventoryCost` |

Những chỗ **không** nhắc tới InventoryTransfer (dễ tưởng là phải sửa nhưng không cần) — xem mục 3.11.

---

## 3. Chi tiết từng touchpoint

### 3.1 Bản thân document: properties quan trọng

Nguồn: Jet — cf/Documents/InventoryTransfer.xml
```xml
			<Posting>Allow</Posting>
			<RealTimePosting>Deny</RealTimePosting>
			<RegisterRecordsDeletion>AutoDeleteOff</RegisterRecordsDeletion>
			<RegisterRecordsWritingOnPost>WriteSelected</RegisterRecordsWritingOnPost>
			<SequenceFilling>AutoFill</SequenceFilling>
			<RegisterRecords>
				<xr:Item xsi:type="xr:MDObjectRef">AccumulationRegister.InventoryInWarehouses</xr:Item>
				<xr:Item xsi:type="xr:MDObjectRef">AccumulationRegister.InventoryCost</xr:Item>
			</RegisterRecords>
			<PostInPrivilegedMode>true</PostInPrivilegedMode>
			<UnpostInPrivilegedMode>true</UnpostInPrivilegedMode>
			<IncludeHelpInContents>false</IncludeHelpInContents>
			<DataLockFields/>
			<DataLockControlMode>Managed</DataLockControlMode>
```

Cần nhân bản cho document mới:
- **Post in privileged mode / Unpost in privileged mode** = true (xem Bài 20). [suy luận] Nhờ vậy role `UseWarehouses` chỉ cấp `Read`/`View` cho register (mục 3.3) mà user vẫn post được; nếu tắt hai property này, role phải có quyền ghi register.
- **DataLockControlMode = Managed** — vì manager module dùng `DataLock` (mục 3.4).
- **SequenceFilling = AutoFill** — đây là giá trị mặc định, mọi document của Jet đều có (kể cả InventoryIncrease, SupplierInvoice, các chứng từ tiền). Bản thân property này **không** đưa document vào sequence; bước quyết định là thêm document vào `Documents` của `Sequence.InventoryCostRecalculation` (3.9).
- Tabular section `AdditionalAttributes` và khối `<Characteristics>` — xem 3.7.
- Attribute `Author` — được điền bởi `ObjectFillingJet.FillDocument` (3.4).

### 3.2 Subsystem Content

Nguồn: Jet — cf/Subsystems/Warehouses/Subsystems/Warehouse.xml
```xml
			<Content>
				<xr:Item xsi:type="xr:MDObjectRef">Document.InventoryIncrease</xr:Item>
				<xr:Item xsi:type="xr:MDObjectRef">Document.InventoryTransfer</xr:Item>
				<xr:Item xsi:type="xr:MDObjectRef">Document.InventoryWriteOff</xr:Item>
			</Content>
```

Document nằm trong subsystem con `Warehouse` của `Warehouses`; catalog nằm trong subsystem con `Catalogs`; report, register, role nằm thẳng trong `Warehouses` (xem 7.3). Một object có thể nằm trong nhiều subsystem (Bài 9). Với document mới: tick vào đúng subsystem con của nhóm mình trong tab Subsystems của object.

### 3.3 Roles và mẫu quyền

**Role nghiệp vụ** của nhóm kho là `UseWarehouses`. Mẫu quyền cho một Document có posting:

Nguồn: Jet — cf/Roles/UseWarehouses/Ext/Rights.xml
```xml
	<setForNewObjects>false</setForNewObjects>
	<setForAttributesByDefault>true</setForAttributesByDefault>
	<independentRightsOfChildObjects>false</independentRightsOfChildObjects>
	<!-- ... -->
	<object>
		<name>Document.InventoryTransfer</name>
		<right>
			<name>Read</name>
			<value>true</value>
		</right>
		<right>
			<name>Insert</name>
			<value>true</value>
		</right>
		<!-- ... -->
```

Danh sách đầy đủ quyền `true` của `Document.InventoryTransfer` trong `UseWarehouses` (đọc từ cùng file): `Read`, `Insert`, `Update`, `Posting`, `UndoPosting`, `View`, `InteractiveInsert`, `Edit`, `InteractiveSetDeletionMark`, `InteractiveClearDeletionMark`, `InteractivePosting`, `InteractivePostingRegular`, `InteractiveUndoPosting`, `InteractiveChangeOfPosted`, `InputByString`. **Không có** `Delete` / `InteractiveDelete` — đúng khuyến nghị Bài 20 (chỉ để quyền xóa ở FullAccess/SystemAdministrator).

Cùng role còn cấp `View` cho `Subsystem.Warehouses` và `Subsystem.Warehouses.Subsystem.Warehouse`, `Read`+`Update` cho `Sequence.InventoryCostRecalculation`, `Read`+`View` cho `AccumulationRegister.InventoryInWarehouses` và `AccumulationRegister.InventoryCost`:

Nguồn: Jet — cf/Roles/UseWarehouses/Ext/Rights.xml
```xml
	<object>
		<name>Subsystem.Warehouses.Subsystem.Warehouse</name>
		<right>
			<name>View</name>
			<value>true</value>
		</right>
	</object>
```

Tổng hợp những gì một role nghiệp vụ phải có cho document mới:
- Quyền trên document (15 quyền như trên).
- `View` trên subsystem cha và subsystem con chứa document (Bài 20: thiếu `View` subsystem thì user không thấy object).
- `Read`/`View` trên các register mà document post vào (và mà form/report đọc).
- `Read` + `Update` trên Sequence nếu document thuộc Sequence.
- Quyền trên catalog `<Tên>AttachedFiles` nếu có (mẫu giống catalog thường: `Read`, `Insert`, `Update`, `View`, `InteractiveInsert`, `Edit`, `InteractiveSetDeletionMark`, `InteractiveClearDeletionMark`, `InputByString`).
- Nếu nhóm khác cần **xem** document của bạn, thêm quyền đọc vào role của họ. Ví dụ `UseCashManagement` chỉ có `Read`, `View`, `InputByString` trên `Document.SupplierInvoice`.

**Role FullAccess** có `setForNewObjects = true` nên object mới tự nhận đủ quyền; việc cần làm là **tắt** `InteractiveDelete` như mọi document của Jet:

Nguồn: Jet — cf/Roles/FullAccess/Ext/Rights.xml
```xml
	<setForNewObjects>true</setForNewObjects>
	<!-- ... -->
	<object>
		<name>Document.InventoryTransfer</name>
		<right>
			<name>InteractiveDelete</name>
			<value>false</value>
		</right>
	</object>
```

Với Catalog, FullAccess còn tắt thêm các quyền trên predefined data (xem 6.2).

### 3.4 Object module và manager module: khung posting của Jet

Đây là **code của Jet** (common module `PostingManagement`, `ObjectFillingJet`), không phải SSL. Document mới nên theo đúng khung này.

Nguồn: Jet — cf/Documents/InventoryTransfer/Ext/ObjectModule.bsl
```bsl
Procedure Filling(FillingData, FillingText, StandardProcessing)
	
	ObjectFillingJet.FillDocument(ThisObject, FillingData);
	
EndProcedure

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

Phân công:
- **Manager module** — `InitializeDocumentData(Ref, AdditionalProperties)`: khóa dữ liệu (`DataLock`), chạy batch query, đặt các bảng kết quả vào `AdditionalProperties.TableForRegisterRecords` với tên `Table<TênRegister>`.
- **PostingManagement.Reflect<Register>** — đọc bảng `Table<TênRegister>` và `Load` vào record set. Có sẵn: `ReflectPurchases`, `ReflectSales`, `ReflectInventoryInWarehouses`, `ReflectCashBalance`, `ReflectCustomerBalance`, `ReflectSupplierBalance`, `ReflectInventoryCost`.

Nguồn: Jet — cf/Documents/InventoryTransfer/Ext/ManagerModule.bsl
```bsl
Procedure InitializeDocumentData(InventoryTransferRef, AdditionalProperties) Export
	
	DocumentObject = InventoryTransferRef.GetObject();
	
	DataLock = New DataLock;
	LockItem = DataLock.Add("AccumulationRegister.InventoryCost");
	LockItem.Mode = DataLockMode.Exclusive;
	LockItem.DataSource = DocumentObject.Inventory;
	LockItem.UseFromDataSource("Product", "Product");
	LockItem.SetValue("Warehouse", DocumentObject.Warehouse);
	DataLock.Lock();
	// ...
	QueryResult = Query.ExecuteBatch();
	
	AdditionalProperties.TableForRegisterRecords.Insert("TableInventoryInWarehouses", QueryResult[6].Unload());
	AdditionalProperties.TableForRegisterRecords.Insert("TableInventoryCost", QueryResult[7].Unload());
	
EndProcedure
```

Tên bảng phải khớp với tên mà `PostingManagement` đọc: `ReflectInventoryInWarehouses` lấy `AdditionalProperties.TableForRegisterRecords.TableInventoryInWarehouses`, thoát nếu `Cancel` hoặc bảng rỗng, rồi `Write = True` và `Load(...)` vào `RegisterRecords.InventoryInWarehouses`. Nếu document mới post vào **register mới** của nhóm, thêm `Reflect<RegisterMới>` vào `PostingManagement` theo đúng mẫu đó (hoặc viết trong object module của mình). `PrepareRecordSetsForWriting` / `WriteRecordSets` là chung cho mọi document, không cần sửa.

`ObjectFillingJet.FillDocument` (code Jet) điền `Author = Users.AuthorizedUser()` và, nếu document có attribute `Currency`, điền tiền tệ/tỷ giá (`Common.HasObjectAttribute` — SSL).
→ Document mới nên có attribute `Author` (kiểu như document mẫu) để handler `Filling` dùng chung được.

### 3.5 Forms: kết nối SSL AttachableCommands và Properties

Cả 3 form (`DocumentForm`, `ListForm`, `ChoiceForm`) của InventoryTransfer đều gọi **AttachableCommands** (module SSL). Đây là điều kiện để nút Print và các command gắn kèm hoạt động (Bài 22).

Nguồn: Jet — cf/Documents/InventoryTransfer/Forms/ListForm/Ext/Form/Module.bsl
```bsl
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	// StandardSubsystems.AttachableCommands
	AttachableCommands.OnCreateAtServer(ThisObject);
	// End StandardSubsystems.AttachableCommands
	
EndProcedure
// ...
// StandardSubsystems.AttachableCommands
&AtClient
Procedure Attachable_ExecuteCommand(Command)
	AttachableCommandsClient.StartCommandExecution(ThisObject, Command, Items.List);
EndProcedure
// ...
```

List form còn có `ListOnActivateRow` (gọi `AttachableCommandsClient.StartCommandUpdate`) và 3 procedure `Attachable_ContinueCommandExecutionAtServer`, `ExecuteCommandAtServer`, `Attachable_UpdateCommands`. Ở list form tham số là `Items.List`, ở object form là `Object`.

`DocumentForm` gọi thêm **Properties** (PropertyManager của SSL) để vẽ additional attributes vào group `GroupAdditionalAttributes`:

Nguồn: Jet — cf/Documents/InventoryTransfer/Forms/DocumentForm/Ext/Form/Module.bsl
```bsl
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	// StandardSubsystems.AttachableCommands
	AttachableCommands.OnCreateAtServer(ThisObject);
	// End StandardSubsystems.AttachableCommands
	
	// StandardSubsystems.Properties
	AdditionalParameters = New Structure;
	AdditionalParameters.Insert("ItemForPlacementName", "GroupAdditionalAttributes");
	PropertyManager.OnCreateAtServer(ThisObject, AdditionalParameters);
	// End StandardSubsystems.Properties
	
EndProcedure
```

Trong DocumentForm các khối `// StandardSubsystems.Properties` còn xuất hiện ở `OnReadAtServer`, `OnOpen`, `NotificationProcessing`, `FillCheckProcessingAtServer`, `BeforeWriteAtServer`, cùng các procedure `Attachable_PropertiesExecuteCommand`, `UpdateAdditionalAttributesDependencies`, `Attachable_OnChangeAdditionalAttribute`, `UpdateAdditionalAttributesItems`. Khối AttachableCommands có ở `OnCreateAtServer`, `OnReadAtServer`, `OnOpen`, `AfterWrite` và 4 procedure `Attachable_*`. Cách an toàn nhất: **copy nguyên form module** của document mẫu sang document mới, giữ nguyên các comment `// StandardSubsystems.…` (Bài 22, Bài 23 đều khuyến nghị đặt code trong service comments).

[suy luận] Form của InventoryTransfer **không** gọi `FilesOperations.OnCreateAtServer` (khác ví dụ Bài 23); hyperlink file đính kèm đến từ common command `AttachedFiles` (Group `FormNavigationPanelGoTo`, Command parameter type `DefinedType.AttachedFilesOwner`) — tức là chỉ cần document có mặt trong defined type là command tự hiện.

### 3.6 Print: PrintManagementOverridable + manager module

**Bước 1 — đăng ký object** (dòng do Jet thêm vào module Overridable của SSL):

Nguồn: Jet — cf/CommonModules/PrintManagementOverridable/Ext/Module.bsl
```bsl
Procedure OnDefinePrintSettings(Settings) Export
	
	Settings.PrintObjects.Add(Documents.SupplierInvoice);
	// ...
	Settings.PrintObjects.Add(Documents.InventoryTransfer);
	Settings.PrintObjects.Add(Documents.InventoryWriteOff);
	
EndProcedure
```

**Bước 2 — manager module** của document: InventoryTransfer có khung nhưng **chưa có print command nào** (`AddPrintCommands` rỗng):

Nguồn: Jet — cf/Documents/InventoryTransfer/Ext/ManagerModule.bsl
```bsl
// StandardSubsystems.Print
// ...
Procedure OnDefinePrintSettings(Settings) Export
	
	Settings.OnAddPrintCommands = True;
	
EndProcedure
// ...
Procedure AddPrintCommands(PrintCommands) Export
	
	
EndProcedure

// End StandardSubsystems.Print
```

Mẫu có print command thật là SupplierInvoice (template `PF_MXL_GoodsReceivedNote`, kiểu SpreadsheetDocument, kèm template `PrintData` kiểu DataCompositionSchema):

Nguồn: Jet — cf/Documents/SupplierInvoice/Ext/ManagerModule.bsl
```bsl
Procedure AddPrintCommands(PrintCommands) Export
	
	PrintCommand = PrintCommands.Add();
	PrintCommand.PrintManager = "PrintManagement";
	PrintCommand.Id = "Document.SupplierInvoice.PF_MXL_GoodsReceivedNote";
	PrintCommand.Presentation = NStr("en = 'Goods received note'");
	
EndProcedure
```

[suy luận] Ở đây `PrintManager = "PrintManagement"` và Id dạng `Document.<Tên>.PF_MXL_<Template>`; manager module của SupplierInvoice không có procedure `Print` riêng, nên việc in được SSL làm dựa trên template (khác cách viết procedure `Print` trong Bài 22). Muốn chắc chắn, đọc chú thích của `PrintManagement.CreatePrintCommandsCollection` trong SSL (ngoài giáo trình — kiểm tra lại).

**Bước 3** — form đã kết nối AttachableCommands (3.5).

### 3.7 Additional attributes (Properties) và Chart of characteristic types

Ba chỗ phải khớp nhau qua chuỗi `Document_InventoryTransfer`:

(a) Khai báo predefined set trong module Overridable (dòng của Jet):

Nguồn: Jet — cf/CommonModules/PropertyManagerOverridable/Ext/Module.bsl
```bsl
	Set = Sets.Rows.Add();
	Set.Name = "Document_InventoryTransfer";
	Set.Id = New UUID("546bad9f-2907-4f16-99a9-058007509ca2");
```

(b) Khối `Characteristics` trong metadata document, trỏ tới Chart of characteristic types `AdditionalAttributesAndInfo` (Bài 13) qua catalog `AdditionalAttributesAndInfoSets`, lọc theo cùng tên set:

Nguồn: Jet — cf/Documents/InventoryTransfer.xml
```xml
			<Characteristics>
				<xr:Characteristic>
					<xr:CharacteristicTypes from="Catalog.AdditionalAttributesAndInfoSets.TabularSection.AdditionalAttributes">
						<xr:KeyField>Catalog.AdditionalAttributesAndInfoSets.TabularSection.AdditionalAttributes.Attribute.Property</xr:KeyField>
						<xr:TypesFilterField>Catalog.AdditionalAttributesAndInfoSets.TabularSection.AdditionalAttributes.Attribute.PredefinedSetName</xr:TypesFilterField>
						<xr:TypesFilterValue xsi:type="xs:string">Document_InventoryTransfer</xr:TypesFilterValue>
						<!-- ... -->
					<xr:CharacteristicValues from="Document.InventoryTransfer.TabularSection.AdditionalAttributes">
						<xr:ObjectField>Document.InventoryTransfer.TabularSection.AdditionalAttributes.StandardAttribute.Ref</xr:ObjectField>
						<xr:TypeField>Document.InventoryTransfer.TabularSection.AdditionalAttributes.Attribute.Property</xr:TypeField>
						<xr:ValueField>Document.InventoryTransfer.TabularSection.AdditionalAttributes.Attribute.Value</xr:ValueField>
```

(c) Tabular section `AdditionalAttributes` của document (`Property` kiểu `ChartOfCharacteristicTypesRef.AdditionalAttributesAndInfo`, `Value` kiểu `Characteristic.AdditionalAttributesAndInfo`, `TextString`) + group `GroupAdditionalAttributes` trên DocumentForm + code form ở 3.5.

Khi copy document mẫu để làm document mới: đổi tên set thành `Document_<TênMới>` ở **cả (a) và (b)**, và [suy luận] tạo **UUID mới** cho `Set.Id` — các set trong Jet đều có UUID khác nhau, không được dùng lại UUID của set mẫu. Cách tạo UUID mới (ví dụ `New UUID()` trong debugger) là ngoài giáo trình — kiểm tra lại.

Functional option liên quan: `UseAdditionalAttributesAndInfo` (Content gồm `Catalog.AdditionalAttributesAndInfoSets`, `ChartOfCharacteristicTypes.AdditionalAttributesAndInfo`, …) — **không** cần thêm document mới vào đây.

### 3.8 Attached files (FilesOperations của SSL)

Jet dùng cách 1 của Bài 23: mỗi owner có catalog riêng `<Tên>AttachedFiles`. Toàn bộ các bước trùng với Bài 23:

| Bước Bài 23 | Chỗ tương ứng trong Jet |
|---|---|
| 1. Tạo catalog `<Tên>AttachedFiles`, bỏ InteractiveDelete trong FullAccess | `Catalogs/InventoryTransferAttachedFiles.xml`; FullAccess có `InteractiveDelete=false` cho catalog này |
| 2. Kiểu của `FileOwner` = ref owner | `cfg:DocumentRef.InventoryTransfer` |
| 5. Defined types `AttachedFile`, `AttachedFileObject` | có |
| 6. Exchange plan `InfobaseUpdate` | có |
| 7. Hai event subscription | `DetermineAttachedFileForm` (catalog manager), `SetDeletionMarkForAttachedDocumentFiles` (document object) |
| 8. Defined type `AttachedFilesOwner` | có `DocumentRef.InventoryTransfer` |
| 9. `AttachedFilesOwnerObject` (chỉ khi owner không phải document) | Document → không có; Catalog `Warehouses` thì có (6.2) |

Nguồn: Jet — cf/Catalogs/InventoryTransferAttachedFiles.xml
```xml
					<Name>FileOwner</Name>
					<!-- ... -->
					<Type>
						<v8:Type>cfg:DocumentRef.InventoryTransfer</v8:Type>
					</Type>
```

Ba defined type (SSL) mỗi file thêm đúng một dòng: `AttachedFile` ← `cfg:CatalogRef.InventoryTransferAttachedFiles`, `AttachedFileObject` ← `cfg:CatalogObject.InventoryTransferAttachedFiles`, `AttachedFilesOwner` ← `cfg:DocumentRef.InventoryTransfer`.

Nguồn: Jet — cf/EventSubscriptions/DetermineAttachedFileForm.xml
```xml
				<v8:Type>cfg:CatalogManager.InventoryTransferAttachedFiles</v8:Type>
				<!-- ... -->
			<Event>FormGetProcessing</Event>
			<Handler>CommonModule.FilesOperationsClientServer.DetermineAttachedFileForm</Handler>
```

Nguồn: Jet — cf/EventSubscriptions/SetDeletionMarkForAttachedDocumentFiles.xml
```xml
			<Source>
				<v8:Type>cfg:DocumentObject.BankReceipt</v8:Type>
				<!-- ... -->
				<v8:Type>cfg:DocumentObject.InventoryTransfer</v8:Type>
				<!-- ... -->
			</Source>
			<Event>BeforeWrite</Event>
			<Handler>CommonModule.FilesOperations.SetAttachedDocumentFilesDeletionMark</Handler>
```

Lưu ý: tên handler trong Jet là `SetAttachedDocumentFilesDeletionMark`; bảng trong Bài 23 ghi `SetDeletionMarkForAttachedDocumentFiles` (trùng tên subscription). Khi làm bài, tick thêm type vào subscription **có sẵn** chứ không tạo subscription mới.

Exchange plan `InfobaseUpdate` có item `<Metadata>Catalog.InventoryTransferAttachedFiles</Metadata>` với `<AutoRecord>Deny</AutoRecord>`; `Subsystems/InternalSubsystem.xml` có `Catalog.InventoryTransferAttachedFiles` trong Content. `InternalSubsystem` có `IncludeInCommandInterface = false` — nơi Jet gom các catalog kỹ thuật để chúng không hiện trên giao diện.

Manager module của catalog file (code SSL, copy nguyên từ catalog mẫu) có `OnFillAccessRestriction` với text `AllowRead WHERE ObjectReadingAllowed(FileOwner)` / `AllowUpdateIfReadingAllowed WHERE ObjectUpdateAllowed(FileOwner)` — [suy luận] quyền trên file đính kèm đi theo quyền trên owner.

### 3.9 Reminder và Sequence

**Reminder** (nhắc việc của SSL): document có trong hai defined type. Common command `Remind` có Command parameter type `DefinedType.ReminderSubject`, nên [suy luận] thêm document vào defined type là command "Remind" tự hiện trên form.

Hai dòng tương ứng: `cfg:DocumentRef.InventoryTransfer` trong `DefinedTypes/ReminderSubject.xml`, `cfg:DocumentObject.InventoryTransfer` trong `DefinedTypes/ReminderSubjectObject.xml`.

**Sequence** `InventoryCostRecalculation` (object của Jet) gom các document làm giảm giá vốn để data processor `InventoryCostRecalculation` tính lại:

Nguồn: Jet — cf/Sequences/InventoryCostRecalculation.xml
```xml
			<MoveBoundaryOnPosting>Move</MoveBoundaryOnPosting>
			<Documents>
				<xr:Item xsi:type="xr:MDObjectRef">Document.InventoryTransfer</xr:Item>
				<xr:Item xsi:type="xr:MDObjectRef">Document.InventoryWriteOff</xr:Item>
				<xr:Item xsi:type="xr:MDObjectRef">Document.SalesInvoice</xr:Item>
			</Documents>
			<RegisterRecords>
				<xr:Item xsi:type="xr:MDObjectRef">AccumulationRegister.InventoryCost</xr:Item>
			</RegisterRecords>
```

Sequence không có trong giáo trình 24 bài. [suy luận] Quy tắc thực tế: document mới nào **xuất kho có tính giá vốn** (ghi `Expense` vào `InventoryCost`) thì thêm vào `Documents` của sequence này (`SequenceFilling = AutoFill` là mặc định, không cần đổi); `InventoryIncrease` và `SupplierInvoice` (nhập kho) không có trong sequence. Cơ chế boundary của sequence — ngoài giáo trình, kiểm tra lại.

### 3.10 Touchpoint chỉ có ở SupplierInvoice / SalesInvoice

Chạy lệnh ở mục 1 với `SupplierInvoice`, `SalesInvoice` thấy thêm:

| Touchpoint | Ý nghĩa | Cần cho document mới khi… |
|---|---|---|
| `DefinedTypes/InteractionSubject.xml`, `CommonModules/InteractionsClientServerOverridable` | document làm "subject" cho Interactions (email, call…) | muốn gắn email/cuộc gọi vào document |
| `DefinedTypes/MessageTemplateSubject.xml` + khối `// StandardSubsystems.MessagesTemplates` trong manager module | message templates | muốn gửi email theo mẫu |
| `DefinedTypes/NotesSubject*.xml`, `ObjectWithAdditionalCommands.xml`, `EventSubscriptions/SetDocumentDeletionMarkChangeStatus.xml` | Notes (chỉ SalesInvoice) | muốn ghi chú gắn document |
| `FilterCriteria/RelatedDocuments.xml` | "Related documents" | document được document khác tham chiếu (ví dụ tabular section `AdvanceClearing`, `PaymentDetails`) |
| `Ext/MainSectionCommandInterface.xml` | command `OpenList` trên trang chính | muốn hiện ở main section |
| `AccumulationRegisters/Purchases.xml`, `SupplierBalance.xml`… | dimension có kiểu `DocumentRef.SupplierInvoice` | register của bạn có dimension kiểu document |
| Templates `LoadingFromFile` + khối `// StandardSubsystems.ImportDataFromFile` | import tabular section từ file | cần import dòng hàng từ Excel |

Ví dụ `InteractionsClientServerOverridable.OnDeterminePossibleSubjects` của Jet chỉ có hai dòng `SubjectsTypes.Add("DocumentRef.SalesInvoice");` và `SubjectsTypes.Add("DocumentRef.SupplierInvoice");`.

### 3.11 Những nơi KHÔNG cần sửa cho document mới

Đã kiểm tra trong dump — InventoryTransfer (và các document nghiệp vụ khác) **không** xuất hiện ở:

- **DocumentJournals**: Jet chỉ có journal `Interactions` (của SSL, chứa Meeting, PhoneCall, IncomingEmail…). Không có journal cho document nghiệp vụ. Nhóm muốn có journal kiểu Bài 13 thì tạo mới.
- **FunctionalOptions**: không option nào chứa document nghiệp vụ.
- **CommonAttributes**: chỉ có `EditedPredefinedAttributes` (SSL), Content là các catalog SSL.
- **CommonCommands**: không command nào nêu tên document; chúng nhận document qua **DefinedTypes** (ví dụ `AttachedFiles` ← `AttachedFilesOwner`, `Remind` ← `ReminderSubject`, `CreateSubjectNote` ← `NotesSubject`). Vì vậy "đăng ký command" = thêm type vào defined type.
- **AccessManagementOverridable**: mọi procedure rỗng, chỉ có `SimplifiedInterface = True`. Jet không khai báo access kinds/record-level restriction cho document → không cần đăng ký.
- **AttachableCommandsOverridable**, **ObjectsFillingOverridable**: chỉ có procedure rỗng / comment.
- **FilesOperationsOverridable**: chỉ có dòng comment ví dụ.
- **InfobaseUpdateJet** (module Jet): chỉ có một update handler `UpdatePredefinedContactInformationKinds`; không cần sửa trừ khi nhóm cần điền dữ liệu khi cập nhật version (ngoài giáo trình — kiểm tra lại cách viết update handler).
- **ReportsOptionsOverridable**: chỉ đăng ký report (xem 7.2), không đăng ký document.

---

## 4. Hai chiến lược: sửa trực tiếp hay Extension

### 4.1 Bối cảnh của Jet

- Jet là mã nguồn mở, **MIT License** (`LICENSE`: "Copyright (c) 2025 1Ci (1C International)"). Trang Wiki *Contributing* hướng dẫn: fork `1Ci-Company/Jet` → làm việc trên nhánh `community` → commit, push lên fork → mở pull request vào `community`. Mỗi nhóm có thể **fork** và sửa thoải mái.
- Cách cài từ repository (Wiki): tạo infobase rỗng → Designer → *Configuration - Open configuration* → *Configuration - Restore configuration from files* trỏ tới thư mục `cf` → *Debug - Start debugging*. Tức là nhóm làm việc trực tiếp trên configuration chính.
- Dump có `cf/Ext/ParentConfigurations/Jet.cf` và `Configuration.xml` khai báo `ConfigurationExtensionCompatibilityMode = Version8_3_24`.
- Nhiều touchpoint ở mục 3 là **object của SSL** (defined types, event subscriptions, module `*Overridable`). Bài 21: muốn sửa object SSL phải bật khả năng thay đổi trong *Configuration - Support - Support options*. [suy luận] Nếu sau khi restore, Designer không cho sửa các object này (biểu tượng khóa), làm theo Bài 21; việc infobase restore từ dump có đang "under support" hay không — ngoài giáo trình, kiểm tra lại.

### 4.2 Chiến lược A — sửa trực tiếp configuration Jet (trên fork)

Ưu điểm cho đồ án sinh viên:
- Đi đúng checklist mục 5–7: mọi touchpoint (subsystem Content, roles, defined types, event subscription Source, `*Overridable`) đều sửa được ngay trong Designer.
- Code nằm trong repo Git của nhóm (dump `cf/`), review bằng diff, có thể gửi PR ngược về Jet theo Wiki *Contributing*.
- Không phải học thêm các ràng buộc của adopted object, safe mode, restructure DB.

Nhược điểm:
- Bốn nhóm cùng sửa các file dùng chung (`PrintManagementOverridable`, `PropertyManagerOverridable`, `DefinedTypes/*`, `Roles/FullAccess`) → dễ **xung đột khi merge** nếu dùng chung một repo. [suy luận] Nên mỗi nhóm một fork/nhánh, hoặc thống nhất ai sửa file chung lúc nào.
- Khi Jet ra version mới, phải tự so sánh/merge thay đổi (đây chính là vấn đề mà Bài Extensions nói extension giải quyết).

### 4.3 Chiến lược B — Extension (Customization hoặc Add-on)

Theo Bài Extensions, extension là **upgrade-safe customization**: mở rộng configuration mà không sửa nó. Chọn Purpose:
- **Customization** — điều chỉnh Jet theo yêu cầu cụ thể (ví dụ thêm attribute cho document có sẵn của nhóm, sửa form, thêm logic sau khi post).
- **Add-on** — tính năng mới ít gắn với version (ví dụ bộ report mới cho subsystem).
- **Patch** — sửa lỗi; không phải mục đích của đồ án.

Extension làm được (Bài Extensions): tạo object mới; adopt object có sẵn để thêm attributes, tabular sections, commands, templates, sửa form; mở rộng procedure/function bằng "Before" / "After" / `&Around` / `&ChangeAndValidate`. Object mới tự mang **prefix** (ví dụ `crm_`), role mặc định `<prefix>DefaultRole`.

Giới hạn **có trong giáo trình** cần biết trước khi chọn extension:
- Property **Name** của adopted object luôn là *controlled*; các property *controlled* khác (ví dụ "Hierarchical", "Code Type") không khớp thì extension **không áp dụng được** → không đổi được các property đó của object Jet qua extension.
- Extension mặc định chạy **safe mode**: chỉ cho mở rộng form handlers; mở rộng method trong **manager module** (ví dụ `InitializeDocumentData` của Jet) phải tắt safe mode.
- "Before"/"After" **không dùng cho function**; dùng `&Around` + `ProceedWithCall()`.
- Adopt tabular section không adopt attributes của nó; adopt form chưa làm việc được với form attributes/commands cho đến khi adopt attribute `Object`. Khuyến nghị sửa form **bằng code** (`Items.Add()`, `ChangeAttributes()`…).
- Thêm attribute vào object Jet qua extension → restructure DB; xóa extension → dữ liệu của attribute đó **mất vĩnh viễn**.
- Giá trị mặc định của parameter không chuyển sang extension.

Điểm **không có trong giáo trình** (ngoài giáo trình — kiểm tra lại): extension có thể thêm type mới vào một **defined type** có sẵn của Jet/SSL không (giáo trình chỉ nói defined type được adopt *by reference*); có thể thêm object vào **Source** của event subscription có sẵn, vào **Content** của subsystem có sẵn, vào **Documents** của Sequence `InventoryCostRecalculation`, hay sửa quyền trong role `UseWarehouses` có sẵn không. Đây đúng là các touchpoint ở mục 3 — nếu không làm được thì phải viết lại bằng object riêng của extension (subsystem riêng, role riêng, event subscription riêng) hoặc mở rộng procedure `*Overridable` bằng "After".

[suy luận] Hướng mở rộng module `*Overridable` từ extension: adopt `PrintManagementOverridable` rồi mở rộng `OnDefinePrintSettings` bằng "After" để `Settings.PrintObjects.Add(Documents.<prefix>TênMới)`. Theo giáo trình, đây là method của common module (không phải form handler) nên cần tắt safe mode như trường hợp manager module — kiểm tra lại.

### 4.4 Khuyến nghị cho đồ án

| Tiêu chí | A. Sửa trực tiếp (fork) | B. Extension |
|---|---|---|
| Độ khó với sinh viên vừa học 24 bài | Thấp — giống các bài thực hành | Cao hơn — thêm adopted object, safe mode, prefix |
| Đăng ký vào SSL (defined types, subscriptions, Overridable) | Làm trực tiếp | Phần lớn ngoài giáo trình, phải tự kiểm chứng |
| Cập nhật khi Jet ra version mới | Phải merge tay | Upgrade-safe (mục đích của extension) |
| Phù hợp cho | Document/Catalog mới gắn chặt vào posting, role, print | Report mới (Add-on), attribute/form/logic thêm cho object có sẵn (Customization) |

[suy luận] Với đồ án một học kỳ: dùng **A** cho phần lõi (document/catalog/register mới của subsystem), có thể làm thêm một **extension Add-on** nhỏ (ví dụ một report DCS) để luyện Bài Extensions.

---

## 5. Checklist: Thêm một Document mới

Mẫu để bắt chước: **InventoryTransfer** (document kho, 2 register, sequence). Nhóm Purchases/Sales nhìn thêm SupplierInvoice/SalesInvoice; nhóm CashManagement nhìn CashReceipt/BankPayment.

**A. Metadata**
1. Copy document mẫu (hoặc tạo mới) → đặt Name, Synonym. Nếu copy: đổi `Documents.InventoryTransfer.InitializeDocumentData` trong object module thành tên document mới.
2. Attributes header, tabular section hàng (mẫu: `Warehouse`, `WarehouseReceiver`, `Comment`, `Author`, tabular section `Inventory` với `Product`, `Quantity`).
3. Tab Posting: `Posting = Allow`, chọn Register records; **Post in privileged mode** và **Unpost in privileged mode** = true (3.1).
4. `DataLockControlMode = Managed`.
5. Tabular section `AdditionalAttributes` + khối Characteristics với `TypesFilterValue = Document_<TênMới>` (3.7).
6. Forms: `DocumentForm`, `ListForm`, `ChoiceForm` — copy từ document mẫu để giữ code SSL; DocumentForm phải có group `GroupAdditionalAttributes`.

**B. Code**

7. Object module: `Filling` → `ObjectFillingJet.FillDocument`; `Posting` / `UndoPosting` theo khung `PostingManagement` (3.4).
8. Manager module: `InitializeDocumentData` (DataLock + batch query → `TableForRegisterRecords.Table<Register>`); khối `// StandardSubsystems.Print` với `OnDefinePrintSettings` (`OnAddPrintCommands = True`) và `AddPrintCommands`.
9. Register mới → thêm `Reflect<Register>` vào `PostingManagement` (mẫu `ReflectInventoryInWarehouses`).
10. Kiểm soát tồn âm (nếu xuất kho): gọi `AccumulationRegisters.InventoryInWarehouses.NegativeBalanceControl` như mẫu.

**C. Đăng ký**

11. Subsystem: thêm vào Content của subsystem con của nhóm (mẫu `Warehouses.Warehouse`).
12. Role nhóm (`UseWarehouses` / `UsePurchases` / `UseSales` / `UseCashManagement`): 15 quyền document, `View` subsystem, `Read`/`View` register, quyền Sequence nếu có (3.3).
13. FullAccess: `InteractiveDelete = false` cho document.
14. `PrintManagementOverridable.OnDefinePrintSettings`: `Settings.PrintObjects.Add(Documents.<TênMới>)`.
15. `PropertyManagerOverridable.OnGetPredefinedPropertiesSets`: set `Document_<TênMới>` với UUID mới.
16. Sequence `InventoryCostRecalculation`: thêm nếu document ghi Expense vào `InventoryCost` (3.9).

**D. Tuỳ chọn SSL**

17. Attached files: catalog `<TênMới>AttachedFiles` (copy `InventoryTransferAttachedFiles`, đổi kiểu `FileOwner`) → `InternalSubsystem` → defined types `AttachedFile`, `AttachedFileObject`, `AttachedFilesOwner` → `InfobaseUpdate` → hai event subscription → FullAccess `InteractiveDelete = false` → role nhóm quyền trên catalog (3.8).
18. Reminder: `ReminderSubject` + `ReminderSubjectObject`.
19. Interactions / message templates / notes / import from file: theo bảng 3.10.

**E. Kiểm tra**

20. `grep -rl "<TênMới>" cf ...` (mục 1) và so với document mẫu.
21. Chạy Enterprise mode bằng **user chỉ có role nhóm** (không FullAccess): mở list, tạo, post, unpost, in, đính kèm file.

---

## 6. Checklist: Thêm một Catalog mới

Mẫu: **Warehouses** (catalog của nhóm kho, có additional attributes, contact information, attached files). Kết quả grep (mục 1) cho `Catalog.Warehouses` / `CatalogRef.Warehouses` / `Catalog_Warehouses`… ngoài thư mục của nó: các register và document dùng nó làm kiểu, `PropertyManagerOverridable`, `DefinedTypes/AttachedFilesOwner`, `AttachedFilesOwnerObject`, `ContactInformationOwner`, report `AvailableStock`, `Roles/FullAccess`, `Roles/UseWarehouses`, `Subsystems/Warehouses/Subsystems/Catalogs.xml`.

### 6.1 Các bước

1. Tạo catalog, đặt `CodeLength`, `DescriptionLength`, hierarchy (Warehouses: `Hierarchical = false`, `CodeLength = 9`, `DescriptionLength = 50`).
2. Forms `ItemForm`, `ListForm`, `ChoiceForm` — copy từ Warehouses (code AttachableCommands + Properties, thêm ContactInformation nếu cần).
3. Subsystem: thêm vào subsystem con `Catalogs` của nhóm.
4. Role nhóm: `Read`, `Insert`, `Update`, `View`, `InteractiveInsert`, `Edit`, `InteractiveSetDeletionMark`, `InteractiveClearDeletionMark`, `InputByString` (mẫu `Catalog.Warehouses` trong `UseWarehouses`) + `View` subsystem `Catalogs`.
5. FullAccess: tắt `InteractiveDelete` và các quyền predefined (6.2).
6. Additional attributes: set `Catalog_<TênMới>` trong `PropertyManagerOverridable` + Characteristics với `TypesFilterValue` cùng tên + tabular section `AdditionalAttributes`.
7. Attached files (tuỳ chọn): như document, nhưng owner là catalog → thêm `CatalogRef` vào `AttachedFilesOwner` **và** `CatalogObject` vào `AttachedFilesOwnerObject` (Bài 23 bước 9); **không** thêm vào subscription `SetDeletionMarkForAttachedDocumentFiles` (Source của nó chỉ có DocumentObject).
8. Contact information (tuỳ chọn): `DefinedTypes/ContactInformationOwner` + tabular section `ContactInformation` + region trong `ContactsManagerOverridable.OnInitialItemsFilling` (6.3).
9. Dùng catalog làm kiểu attribute/dimension ở document/register của nhóm.

### 6.2 Mẫu quyền FullAccess cho Catalog

Nguồn: Jet — cf/Roles/FullAccess/Ext/Rights.xml
```xml
		<name>Catalog.Warehouses</name>
		<right>
			<name>InteractiveDelete</name>
			<value>false</value>
		</right>
		<right>
			<name>InteractiveDeletePredefinedData</name>
			<value>false</value>
		</right>
		<right>
			<name>InteractiveSetDeletionMarkPredefinedData</name>
			<value>false</value>
		</right>
```

(Trong cùng object còn `InteractiveClearDeletionMarkPredefinedData` và `InteractiveDeleteMarkedPredefinedData` = false — đúng danh sách "không đặt trong role nào" của Bài 20.)

Owner là catalog nên Warehouses có `cfg:CatalogObject.Warehouses` trong `DefinedTypes/AttachedFilesOwnerObject.xml` (document thì không).

### 6.3 Contact information (SSL ContactsManager) — mẫu Warehouses

`ContactsManagerOverridable.OnInitialItemsFilling` có `#Region Warehouses` (code Jet trong module SSL) tạo predefined kind dạng folder `CatalogWarehouses` và kind con `WarehouseActualAddress` (`Item.Parent = "CatalogWarehouses"`, `Item.Type = Enums.ContactInformationTypes.Address`). Và `cfg:CatalogObject.Warehouses` trong `DefinedTypes/ContactInformationOwner.xml`. ContactsManager không có trong giáo trình — ngoài giáo trình, kiểm tra lại trong tài liệu SSL trước khi dùng.

---

## 7. Checklist: Thêm một Report (DCS) mới

Mẫu: **StockStatement**. Grep `StockStatement` ngoài thư mục report chỉ ra 5 file: `ReportsOptionsOverridable`, `Configuration.xml`, `Roles/UseWarehouses`, `Subsystems/Warehouses.xml`, `Subsystems/Warehouses/Ext/CommandInterface.xml`. Report **không có** object module, manager module hay form riêng — chỉ có template DCS và một command.

### 7.1 Report và template DCS

Nguồn: Jet — cf/Reports/StockStatement.xml
```xml
			<UseStandardCommands>true</UseStandardCommands>
			<DefaultForm/>
			<AuxiliaryForm/>
			<MainDataCompositionSchema>Report.StockStatement.Template.MainDataCompositionSchema</MainDataCompositionSchema>
			<DefaultSettingsForm/>
			<AuxiliarySettingsForm/>
			<DefaultVariantForm/>
			<VariantsStorage/>
			<SettingsStorage/>
```

`DefaultForm` để trống → dùng form chung của configuration (SSL):

Nguồn: Jet — cf/Configuration.xml
```xml
			<DefaultReportForm>CommonForm.ReportForm</DefaultReportForm>
```

Template `MainDataCompositionSchema` (Bài 18) có query bắt đầu bằng `SELECT ALLOWED` và **hai settings variant**: `StockStatement` (dùng trong section) và `StockStatementContext` (mở từ form Product, có filter).

### 7.2 Đăng ký report option (ReportsOptionsOverridable — dòng của Jet)

Nguồn: Jet — cf/CommonModules/ReportsOptionsOverridable/Ext/Module.bsl
```bsl
	// Warehouses reports
	OptionSettings = ReportsOptions.OptionDetails(Settings, Metadata.Reports.StockStatement, "StockStatement");
	OptionSettings.LongDesc = NStr("en = 'Opening balance, receipt, consumption, closing balance by products'");
	
	OptionSettings = ReportsOptions.OptionDetails(Settings, Metadata.Reports.StockStatement, "StockStatementContext");
	OptionSettings.Enabled = False;
```

Tên option (tham số thứ 3) phải trùng `dcsset:name` của settings variant trong DCS. Variant "Context" được `Enabled = False` — [suy luận] để nó không hiện trong danh sách report của section mà chỉ dùng khi mở bằng command có filter.

### 7.3 Subsystem, command interface, command ngữ cảnh

`Report.StockStatement` nằm trong Content của subsystem cha `Warehouses` (không phải subsystem con). Command interface của subsystem đặt lệnh mở report vào nhóm Reports:

Nguồn: Jet — cf/Subsystems/Warehouses/Ext/CommandInterface.xml
```xml
		<Command name="Report.StockStatement.StandardCommand.Open">
			<CommandGroup>ActionsPanelReports</CommandGroup>
		</Command>
```

Command ngữ cảnh của report (Group `FormNavigationPanelSeeAlso`, Command parameter type `CatalogRef.Products`, Parameter usage mode `Single` — Bài 14) mở variant Context với filter theo product:

Nguồn: Jet — cf/Reports/StockStatement/Commands/OpenStockStatementReport/Ext/CommandModule.bsl
```bsl
&AtClient
Procedure CommandProcessing(CommandParameter, CommandExecuteParameters)
	
	FilterStructure = New Structure("Product", CommandParameter);
	FormParameters = New Structure;
	FormParameters.Insert("VariantKey", "StockStatementContext");
	FormParameters.Insert("Filter", FilterStructure);
	FormParameters.Insert("GenerateOnOpen", True);
	FormParameters.Insert("ReportOptionsCommandsVisibility", False);
	
	OpenForm("Report.StockStatement.Form",
		FormParameters,
		CommandExecuteParameters.Source,
		CommandExecuteParameters.Uniqueness,
		CommandExecuteParameters.Window);
	
EndProcedure
```

### 7.4 Quyền

Nguồn: Jet — cf/Roles/UseWarehouses/Ext/Rights.xml
```xml
		<name>Report.StockStatement</name>
		<right>
			<name>Use</name>
			<value>true</value>
		</right>
		<right>
			<name>View</name>
			<value>true</value>
		</right>
```

Command riêng `Report.StockStatement.Command.OpenStockStatementReport` được cấp `View` trong cùng role.

Cộng thêm `Read` trên các register mà query DCS đọc (StockStatement đọc `InventoryCost` — `UseWarehouses` có `Read`/`View`).

### 7.5 Các bước

1. Tạo Report, tạo Main data composition schema (Bài 18); dùng `SELECT ALLOWED` như mẫu.
2. Tạo settings variant chính (+ variant `...Context` nếu cần mở từ form khác).
3. `ReportsOptionsOverridable.CustomizeReportsOptions`: một `OptionDetails` cho mỗi variant, `LongDesc` cho variant chính, `Enabled = False` cho variant context.
4. Thêm report vào Content subsystem cha của nhóm; trong Command interface của subsystem, đặt `StandardCommand.Open` vào nhóm `ActionsPanelReports`.
5. Role nhóm: `Use` + `View` trên report, `View` trên command riêng (nếu có), `Read` trên register nguồn.
6. (Tuỳ chọn) Command ngữ cảnh như `OpenStockStatementReport`.
7. Report panel của section (`CommonCommand.ReportPanelWarehouses` gọi `ReportsOptionsClient.ShowReportBar("Warehouses", ExecutionParameters)`) đã có sẵn cho 4 subsystem — không cần tạo lại.

Nếu làm report bằng **extension Add-on**: report là object mới (có prefix), nhưng bước 3–5 chạm vào object có sẵn (`ReportsOptionsOverridable`, subsystem, role) — xem giới hạn ở 4.3.

---

## 8. Lỗi thường gặp

Chỉ liệt kê lỗi có căn cứ từ wiring ở trên hoặc từ file bài.

| Triệu chứng | Nguyên nhân | Căn cứ | Sửa |
|---|---|---|---|
| "Access violation!" khi mở list/post bằng user thường | Role nhóm chưa có quyền trên object mới. Role `Use*` có `setForNewObjects = false` nên object mới **không** tự nhận quyền | Bài 20; `Roles/Use*/Ext/Rights.xml` | Cấp 15 quyền document / 9 quyền catalog (3.3, 6.1) |
| Access violation khi mở form/report dù đã có quyền document | Thiếu `Read` trên register mà form/query đọc | Bài 20 (lỗi đọc register trong OnCreateAtServer) | Cấp `Read`/`View` register |
| Có quyền nhưng không thấy object trên giao diện | Object chưa vào Content subsystem, hoặc role thiếu `View` trên subsystem (cha **và** con, ví dụ `Subsystem.Warehouses.Subsystem.Warehouse`) | Bài 9, Bài 20 | Sửa subsystem Content + quyền View |
| Admin thấy nút Delete trên object mới | FullAccess có `setForNewObjects = true`, object mới nhận cả `InteractiveDelete` | Bài 20, Bài 23 ("nhớ bỏ quyền interactive deletion… khỏi role FullAccess") | Tắt `InteractiveDelete` (và các quyền predefined cho catalog) |
| Không có nút Print | Thiếu `Settings.PrintObjects.Add(...)` trong `PrintManagementOverridable`, hoặc thiếu `OnAddPrintCommands = True` | Bài 22; 3.6 | Thêm cả hai |
| Nút Print có nhưng bấm không chạy / list form không có lệnh | Form (object form **và** list form) chưa kết nối AttachableCommands | Bài 22; 3.5 | Copy khối `// StandardSubsystems.AttachableCommands` |
| Lỗi thiếu method khi mở list form của object đã thêm vào PrintObjects | Manager module chưa có `OnDefinePrintSettings` | Bài 22 | Thêm khối `// StandardSubsystems.Print` |
| Hyperlink file đính kèm không có / form file không mở / xóa document không đánh dấu file | Thiếu một trong: defined type `AttachedFilesOwner`, `AttachedFile`, `AttachedFileObject`, subscription `DetermineAttachedFileForm` / `SetDeletionMarkForAttachedDocumentFiles`, `InfobaseUpdate` | Bài 23; 3.8 | Đi đủ bảng 3.8 |
| Không có nhóm "Additional attributes" trên form, hoặc attribute thêm cho document mới lại hiện ở document mẫu | [suy luận] `TypesFilterValue` trong Characteristics không khớp `Set.Name` ở `PropertyManagerOverridable`, hoặc copy nguyên set/UUID của document mẫu | 3.7 | Đổi cả hai chỗ thành `Document_<TênMới>`, UUID mới |
| Post lỗi ở `PostingManagement.Reflect…` (không có property `Table…`) | [suy luận] Tên bảng trong `TableForRegisterRecords.Insert("Table<Register>", …)` không khớp tên mà `Reflect<Register>` đọc | 3.4 | Đặt đúng `Table<TênRegister>` |
| Document mới post vào cost nhưng data processor tính lại giá vốn bỏ qua | [suy luận] Document chưa có trong Sequence `InventoryCostRecalculation` | 3.9 | Thêm vào `Documents` của sequence + `SequenceFilling = AutoFill` + quyền Sequence trong role |
| User thường post bị Access violation trên register | [suy luận] Tắt Post in privileged mode trong khi role chỉ có `Read`/`View` register | 3.1, Bài 20 | Giữ privileged mode = true như mẫu, hoặc cấp quyền ghi |
| Report không có mô tả / variant context hiện trong danh sách | Chưa đăng ký trong `ReportsOptionsOverridable` | 7.2 | Thêm `OptionDetails` |
| Copy document mẫu nhưng post ra số liệu của document mẫu | Object module vẫn gọi `Documents.InventoryTransfer.InitializeDocumentData` | 3.4 | Đổi sang `Documents.<TênMới>` |
| (Extension) Không mở rộng được `InitializeDocumentData` / method common module | Safe mode chỉ cho mở rộng form handlers | Bài Extensions | Tắt safe mode, khởi động lại |
| (Extension) Mất dữ liệu attribute thêm vào object Jet | Xóa extension / xóa attribute khỏi extension → restructure | Bài Extensions | Sao lưu trước khi gỡ extension |
| Không sửa được defined type / event subscription / module Overridable | Object SSL đang khóa theo support | Bài 21, Bài 23 | Bật khả năng thay đổi trong Support options |

**Quy tắc vàng**: sau khi thêm object, chạy lại `grep` ở mục 1 cho object mới và cho object mẫu; mỗi file object mẫu có mà object mới không có là một câu hỏi "mình có cần bước này không?" — trả lời bằng bảng mục 2.


---

# § jet-cash

# 1C:Jet — Phân hệ Quản lý dòng tiền (Subsystem CashManagement)

Khi nào đọc file này: khi sinh viên hỏi về thu/chi tiền mặt, thu/chi ngân hàng, register CashBalance, công nợ khách hàng/nhà cung cấp phát sinh từ thanh toán, tạm ứng (advance), số dư đầu kỳ tiền, report CashStatement — hoặc khi nhóm sinh viên được giao mở rộng phân hệ Dòng tiền của Jet.

Phạm vi nguồn: Jet commit 80884de (config 1.0.2.1), thư mục `cf/`, README và wiki tiếng Anh. Mọi đoạn code dưới đây được chép nguyên văn; chỗ cắt ghi `// ...`.

## Mục lục

1. Thành phần Subsystem · 2. Catalogs · 3. Enumerations · 4. AccumulationRegister CashBalance · 5. Bốn Document thu/chi · 6. Filling · 7. Posting · 8. Form và CashManagementClient/ServerCall · 9. Settlement và tạm ứng · 10. Số dư đầu kỳ · 11. Reports · 12. Role và điểm gắn SSL · 13. Chỗ lạ trong code · 14. Gợi ý mở rộng

## 1. Thành phần của Subsystem CashManagement

Subsystem `CashManagement` (Synonym "Cash management") có 3 subsystem con: `Catalogs`, `Bank`, `CashInHand`. Danh sách `<Content>` lấy từ các file XML:

| Nơi khai báo | Member objects |
|---|---|
| `cf/Subsystems/CashManagement.xml` | `Enum.CashTypes`, `AccumulationRegister.CashBalance`, `Report.CashStatement`, `Enum.BankPaymentOperations`, `Enum.BankReceiptOperations`, `Enum.CashReceiptOperations`, `Enum.CashVoucherOperations`, `CommonModule.CashManagementServerCall`, `CommonModule.CashManagementClient`, `Role.UseCashManagement`, `CommonCommand.AdditionalReportsCashManagement`, `CommonCommand.AdditionalDataProcessorsCashManagement`, `CommonCommand.ReportPanelCashManagement` |
| `.../CashManagement/Subsystems/Catalogs.xml` | `Catalog.Currencies`, `Catalog.CashAccounts`, `Catalog.BankAccounts` |
| `.../CashManagement/Subsystems/Bank.xml` | `Document.BankPayment`, `Document.BankReceipt` |
| `.../CashManagement/Subsystems/CashInHand.xml` | `Document.CashReceipt`, `Document.CashVoucher` |

Ghi chú:
- Register `CustomerBalance`, `SupplierBalance` và report `CustomerBalance`, `SupplierBalance` **không** nằm trong CashManagement: report `CustomerBalance` thuộc `Subsystems/Sales.xml`, report `SupplierBalance` thuộc `Subsystems/Purchases.xml`. Nhưng 4 chứng từ tiền đều ghi vào hai register công nợ này, nên nhóm Dòng tiền buộc phải hiểu chúng.
- `Catalog.Currencies` đồng thời là thành phần của subsystem SSL `StandardSubsystems/Currencies` (cùng `InformationRegister.ExchangeRates`, `CommonModule.CurrencyRateOperations`…). Tức là Currencies là **object của SSL** được Jet đưa vào giao diện phân hệ (xem Bài 21 về SSL).
- Mỗi object (catalog/document) có thêm catalog `...AttachedFiles` (ví dụ `CashReceiptAttachedFiles`) — [suy luận] theo mẫu catalog đính kèm file của subsystem File operations trong SSL (xem Bài 23).

## 2. Catalogs

### 2.1. CashAccounts và BankAccounts

- **CashAccounts** (quỹ tiền mặt): không phân cấp, Code 9 ký tự (Autonumbering), Description 50; attribute duy nhất `Currency` (`CatalogRef.Currencies`, FillChecking = ShowError).
- **BankAccounts** (tài khoản ngân hàng): không có Code (CodeLength = 0), Description 100; attributes `AccountNumber` và `IBAN` (String 34, Indexing = Index), `Bank` (String 100 — tên ngân hàng là chuỗi, không phải catalog), `SWIFT` (String 11), `Currency` (ShowError). InputByString theo Description, IBAN, AccountNumber.
- Cả hai có tabular section `AdditionalAttributes` (Property / Value / TextString — cấu trúc chuẩn của SSL Properties) và ba form ItemForm, ListForm, ChoiceForm.

### 2.2. Khóa đổi tiền tệ sau khi đã ghi

Item form của cả CashAccounts và BankAccounts giống hệt nhau (diff rỗng). Điểm đáng chú ý duy nhất về nghiệp vụ: một khi tài khoản đã được ghi, field `Currency` chuyển sang ReadOnly — vì số dư trong `CashBalance` được lưu theo tiền tệ của tài khoản.

Nguồn: Jet — cf/Catalogs/CashAccounts/Forms/ItemForm/Ext/Form/Module.bsl
```bsl
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	LockCurrencyChanges(Object.Ref);
	// ...
EndProcedure
// ...
Procedure LockCurrencyChanges(ObjectRef)
	
	Items.Currency.ReadOnly = Not ObjectRef.IsEmpty();
	
EndProcedure
```

[suy luận] Đây chỉ là khóa trên form; nếu ghi object bằng code thì vẫn đổi được Currency. Muốn chặn triệt để cần kiểm tra ở object module (`BeforeWrite`).

### 2.3. Currencies và ExchangeRates (SSL)

`Catalog.Currencies` (Code 3 ký tự, Description 10) có các attribute `ImportingFromInternet`, `DescriptionFull`, `Markup`, `MainCurrency`, `AmountInWordsParameters`, `RateCalculationFormula`, `RateSource` (`EnumRef.RateSources`), tabular section `Presentations`. Object module bắt đầu bằng dòng bản quyền "Copyright (c) 2024, OOO 1C-Soft … CC BY 4.0" → đây là **code SSL**, không phải code Jet.

`InformationRegister.ExchangeRates`: periodic theo **Day**, WriteMode Independent; Dimension `Currency` (Master); Resources `Rate` (DefinedType `CurrencyExchangeRate`) và `Repetition` (hệ số nhân). Đây là ví dụ thực tế của information register periodic + `SliceLast` (xem Bài 12).

Jet đọc tỷ giá qua function SSL `CurrencyRateOperations.GetCurrencyRate(Currency, DateOfCourse)` — bên trong gọi `InformationRegisters.ExchangeRates.GetLast(...)` và trả Structure có `Rate`, `Repetition`.

"Tiền tệ hạch toán" (presentation currency) lấy bằng function Jet `JetServer.GetPresentationCurrency()` — một dòng `Return Common.ObjectAttributeValue(Catalogs.Companies.MainCompany, "PresentationCurrency");` (đọc attribute của công ty chính qua module SSL `Common`).

## 3. Enumerations

| Enum | Values | Dùng ở |
|---|---|---|
| `CashReceiptOperations` | `Customer`, `Other` | CashReceipt.Operation |
| `CashVoucherOperations` | `Supplier`, `Other` | CashVoucher.Operation |
| `BankReceiptOperations` | `Customer`, `Other` | BankReceipt.Operation |
| `BankPaymentOperations` | `Supplier`, `Other` | BankPayment.Operation |
| `CashTypes` | `Cash`, `NonCash` | Dimension `CashType` của CashBalance |
| `LiabilityTypes` (ngoài CashManagement) | `Liability`, `Advance` | Dimension của CustomerBalance / SupplierBalance |

Thuật toán dựa vào **Enumeration** (không dựa vào chuỗi người dùng sửa được). Fill value mặc định của `Operation`: `Customer` (CashReceipt, BankReceipt) và `Supplier` (CashVoucher, BankPayment). Wiki (Features.md) gọi hai thao tác này là "Counterparty transaction" và "Other (for manual entries and balances)".

## 4. AccumulationRegister CashBalance (và hai register công nợ)

### 4.1. CashBalance
RegisterType = **Balance**. Dimensions: `BankCashAccount` — composite type `CatalogRef.CashAccounts` + `CatalogRef.BankAccounts`; `CashType` — `EnumRef.CashTypes` (cả hai DenyIncompleteValues = true). Resource: `AmountCur` Number(15,2).

Nhận xét cho sinh viên (xem Bài 11):
- Dimension **composite type** là cách gộp tiền mặt và ngân hàng vào một register. [suy luận] `CashType` gần như dư thừa về mặt dữ liệu (suy ra được từ kiểu của `BankCashAccount`) nhưng giúp lọc nhanh trong report.
- Chỉ có **một resource `AmountCur`** — số tiền theo tiền tệ của tài khoản. Không có cột quy đổi ra tiền tệ hạch toán. Vì tiền tệ gắn với tài khoản (và bị khóa sau khi ghi), cộng `AmountCur` theo từng tài khoản là hợp lệ; cộng chéo nhiều tài khoản khác tiền tệ thì không — report CashStatement vì vậy nhóm theo `Currency` trước.
- Register **không có RecordSetModule** → không có kiểm soát số dư âm (khác với `InventoryInWarehouses`, xem mục 14).

Chỉ 4 document CashReceipt, CashVoucher, BankReceipt, BankPayment ghi vào CashBalance (grep toàn bộ `cf/`).
### 4.2. CustomerBalance / SupplierBalance

Cả hai: RegisterType = Balance; Dimensions `LiabilityType` (`EnumRef.LiabilityTypes`), `Counterparty` (`CatalogRef.Counterparties`), `Document`; Resource `Amount` Number(15,2) — nhận giá trị đã quy đổi ra tiền tệ hạch toán (cột `Amount` của PaymentDetails). `Document` của CustomerBalance: `SalesInvoice`, `CashReceipt`, `BankReceipt`; của SupplierBalance: `BankPayment`, `CashVoucher`, `SupplierInvoice`.

Dimension `Document` là "chứng từ thanh toán theo" (settlement document): hóa đơn khi là `Liability`, hoặc chính chứng từ thu/chi khi là `Advance`. Quy ước dấu được giải thích ở mục 9.

## 5. Bốn Document thu/chi: cấu trúc chung

| | CashReceipt | CashVoucher | BankReceipt | BankPayment |
|---|---|---|---|---|
| Nghiệp vụ | Thu tiền mặt | Chi tiền mặt | Thu qua ngân hàng | Chi qua ngân hàng |
| Tài khoản (attribute) | `CashAccount` | `CashAccount` | `BankAccount` | `BankAccount` |
| `Operation` | CashReceiptOperations | CashVoucherOperations | BankReceiptOperations | BankPaymentOperations |
| `Counterparty` ChoiceParameters | `Filter.Customer = true` | `Filter.Supplier = true` | `Filter.Customer = true` | `Filter.Supplier = true` |
| `PaymentDetails.Document` | `DocumentRef.SalesInvoice` | `DocumentRef.SupplierInvoice` | `DocumentRef.SalesInvoice` | `DocumentRef.SupplierInvoice` |
| BasedOn | SalesInvoice | SupplierInvoice | SalesInvoice | SupplierInvoice |
| RegisterRecords | CustomerBalance, CashBalance | SupplierBalance, CashBalance | CustomerBalance, CashBalance | SupplierBalance, CashBalance |
| Thêm riêng | — | — | — | `Paid` (Boolean), `PaymentDate` (Date) |

Header chung: `Operation`, tài khoản (FillChecking = ShowError), `Counterparty` (ShowError), `Currency`, `ExchangeRate` (10,4), `Multiplier` (10,0), `Comment`, `Author` (`CatalogRef.Users`), `PaymentAmount` (15,2 — tổng, tính lại trong `BeforeWrite`).

Tabular section `PaymentDetails`: `Document`, `PaymentAmount` (số tiền theo tiền tệ chứng từ/tài khoản), `Amount` (số tiền quy đổi ra tiền tệ hạch toán).

Thuộc tính posting (cả 4): Posting = Allow, RealTimePosting = Deny, **Post in privileged mode** = true, **Unpost in privileged mode** = true, NumberType String(9), DataLockControlMode = Managed.

Code 4 document gần như sao chép nhau — chỉ khác tên object/enum/register (đã đối chiếu bằng `diff`). Vì vậy file này trích CashReceipt làm mẫu và chỉ ra chỗ khác.

## 6. Filling — tạo chứng từ thanh toán từ hóa đơn

Handler `Filling` trong object module chạy khi tạo mới (kể cả "Create based on" từ SalesInvoice/SupplierInvoice — BasedOn ở mục 5). Đầu tiên gọi module Jet `ObjectFillingJet.FillDocument` để gán tiền tệ mặc định và `Author`:

Nguồn: Jet — cf/CommonModules/ObjectFillingJet/Ext/Module.bsl
```bsl
Procedure FillDocument(DocumentObject, Val FillingData) Export
	
	If TypeOf(FillingData) <> Type("Structure") Then
		FillingData = New Structure;
	EndIf;
	
	AddCurrency(DocumentObject, FillingData);
	FillingData.Insert("Author", Users.AuthorizedUser());
	FillPropertyValues(DocumentObject, FillingData);
	
EndProcedure
```

Sau đó, nếu `FillingData` là hóa đơn, một batch query lấy header hóa đơn, chọn quỹ đầu tiên có cùng tiền tệ, và tính `Amount` quy đổi:

Nguồn: Jet — cf/Documents/CashReceipt/Ext/ObjectModule.bsl
```bsl
Procedure Filling(FillingData, FillingText, StandardProcessing)
	
	ObjectFillingJet.FillDocument(ThisObject, FillingData);
	
	If TypeOf(FillingData) = Type("DocumentRef.SalesInvoice") Then
		
		Query = New Query;
		Query.Text = 
		"SELECT
		// ...
		|INTO DocumentHeader
		// ...
		|SELECT TOP 1
		|	CashAccounts.Ref AS Ref,
		|	CashAccounts.Currency AS Currency
		|INTO CashAccount
		// ...
		|SELECT
		|	VALUE(Enum.CashReceiptOperations.Customer) AS Operation,
		|	DocumentHeader.Customer AS Counterparty,
		|	ISNULL(CashAccount.Ref, VALUE(Catalog.CashAccounts.EmptyRef)) AS CashAccount,
		|	DocumentHeader.Currency AS Currency,
		// ...
		|	DocumentHeader.Ref AS Document,
		|	DocumentHeader.Total AS PaymentAmount,
		|		ELSE CAST(DocumentHeader.Total * DocumentHeader.ExchangeRate / DocumentHeader.Multiplier AS NUMBER(15, 2))
		// ...
		|		LEFT JOIN CashAccount AS CashAccount
		|		ON DocumentHeader.Currency = CashAccount.Currency";
		
		Query.SetParameter("Ref", FillingData);
		QueryResult = Query.Execute();
		
		If Not QueryResult.IsEmpty() Then
			// ...
			FillPropertyValues(ThisObject, Selection);
			
			PaymentDetails.Clear();
			FillPropertyValues(PaymentDetails.Add(), Selection);
			// ...
EndProcedure
```

Điểm học được (Bài 10): temporary table (`INTO`), `TOP 1` (phần cắt: `FROM Catalog.CashAccounts INNER JOIN DocumentHeader` theo `Currency`, điều kiện `NOT CashAccounts.DeletionMark`), `ISNULL(..., VALUE(...EmptyRef))`, `CAST ... AS NUMBER(15, 2)`, và mẹo `FillPropertyValues` cùng một Selection cho cả header lẫn dòng tabular section (field nào trùng tên thì được gán).

Khác biệt ở BankReceipt: hóa đơn bán có attribute `BankAccount`, nên query lấy thêm `SalesInvoice.BankAccount` và dùng `CASE WHEN DocumentHeader.BankAccount = VALUE(Catalog.BankAccounts.EmptyRef) THEN ISNULL(FirstBankAccount.Ref, ...) ELSE DocumentHeader.BankAccount END AS BankAccount` — ưu tiên tài khoản ghi trên hóa đơn, chỉ khi trống mới lấy tài khoản đầu tiên cùng tiền tệ (temp table `FirstBankAccount`).

CashVoucher và BankPayment làm tương tự với `SupplierInvoice` (`SupplierInvoice.Supplier AS Supplier`); BankPayment chọn `TOP 1` từ `Catalog.BankAccounts`.

## 7. Posting — code và luồng PostingManagement

### 7.1. Object module: BeforeWrite, Posting, UndoPosting, FillCheckProcessing

Nguồn: Jet — cf/Documents/CashReceipt/Ext/ObjectModule.bsl
```bsl
Procedure Posting(Cancel, PostingMode)
	
	// Initialization of additional properties for document posting.
	PostingManagement.InitializeAdditionalPropertiesForPosting(Ref, AdditionalProperties);
	
	// Document data initialization.
	Documents.CashReceipt.InitializeDocumentData(Ref, AdditionalProperties);
	
	// Preparation of records sets.
	PostingManagement.PrepareRecordSetsForWriting(ThisObject);
	
	// Movements on the CashBalance register
	PostingManagement.ReflectCashBalance(AdditionalProperties, RegisterRecords, Cancel);
	
	// Movements on the CustomerBalance register
	PostingManagement.ReflectCustomerBalance(AdditionalProperties, RegisterRecords, Cancel);
	
	// Writing of the records sets.
	PostingManagement.WriteRecordSets(ThisObject);
	
EndProcedure

Procedure FillCheckProcessing(Cancel, CheckedAttributes)
	
	If Operation = Enums.CashReceiptOperations.Other Then
		CheckedAttributes.Delete(CheckedAttributes.Find("Counterparty"));
	EndIf;
	
EndProcedure
```

- `BeforeWrite` (không trích): bỏ qua khi `DataExchange.Load`, còn lại gán `PaymentAmount = PaymentDetails.Total("PaymentAmount")`.
- `UndoPosting` (không trích) chỉ gọi 3 dòng: `InitializeAdditionalPropertiesForPosting`, `PrepareRecordSetsForWriting`, `WriteRecordSets` — xem 7.3 để hiểu vì sao như vậy là đủ xóa register records.
- Cấu trúc "khung" 5 bước: khởi tạo `AdditionalProperties` → manager module chuẩn bị bảng dữ liệu → xóa record set cũ → nạp bảng vào `RegisterRecords` → ghi. Khác với cách Bài 11 (dùng Record wizard, vòng lặp `For Each ... RegisterRecords.X.Add()`), Jet dùng **query → ValueTable → `RecordSet.Load()`**.
- CashVoucher / BankPayment gọi `ReflectSupplierBalance` thay vì `ReflectCustomerBalance`.
- `FillCheckProcessing`: với `Operation = Other`, bỏ `Counterparty` khỏi danh sách bắt buộc (Bài 12).
- File object module được bọc trong `#If Server Or ExternalConnection Then` (preprocessor, Bài 7).

### 7.2. Manager module: InitializeDocumentData (CashReceipt)

Nguồn: Jet — cf/Documents/CashReceipt/Ext/ManagerModule.bsl
```bsl
Procedure InitializeDocumentData(CashReceiptRef, AdditionalProperties) Export
	
	Query = New Query;
	Query.Text =
	"SELECT
	// ...
	|INTO DocumentHeader
	// ...
	|SELECT
	|	DocumentHeader.Ref AS Ref,
	|	DocumentHeader.Date AS Period,
	// ...
	|INTO DocumentPaymentDetails
	|FROM
	|	DocumentHeader AS DocumentHeader
	|		INNER JOIN Document.CashReceipt.PaymentDetails AS CashReceiptPaymentDetails
	|		ON DocumentHeader.Ref = CashReceiptPaymentDetails.Ref
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	VALUE(AccumulationRecordType.Receipt) AS RecordType,
	|	VALUE(Enum.CashTypes.Cash) AS CashType,
	|	DocumentPaymentDetails.Period AS Period,
	|	DocumentPaymentDetails.CashAccount AS BankCashAccount,
	|	SUM(DocumentPaymentDetails.PaymentAmount) AS AmountCur
	|FROM
	|	DocumentPaymentDetails AS DocumentPaymentDetails
	|
	|GROUP BY
	|	DocumentPaymentDetails.Period,
	|	DocumentPaymentDetails.CashAccount
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	VALUE(AccumulationRecordType.Expense) AS RecordType,
	|	DocumentPaymentDetails.Period AS Period,
	|	CASE
	|		WHEN DocumentPaymentDetails.Document = VALUE(Document.SalesInvoice.EmptyRef)
	|				OR DocumentPaymentDetails.Document = UNDEFINED
	|			THEN VALUE(Enum.LiabilityTypes.Advance)
	|		ELSE VALUE(Enum.LiabilityTypes.Liability)
	|	END AS LiabilityType,
	|	DocumentPaymentDetails.Counterparty AS Counterparty,
	// ...
	|	SUM(DocumentPaymentDetails.Amount) AS Amount
	|FROM
	|	DocumentPaymentDetails AS DocumentPaymentDetails
	|WHERE
	|	DocumentPaymentDetails.Operation = VALUE(Enum.CashReceiptOperations.Customer)
	|
	|GROUP BY
	// ...
	|	DocumentPaymentDetails.Period";
	
	Query.SetParameter("Ref", CashReceiptRef);
	
	QueryResult = Query.ExecuteBatch();
	
	AdditionalProperties.TableForRegisterRecords.Insert("TableCashBalance", QueryResult[2].Unload());
	AdditionalProperties.TableForRegisterRecords.Insert("TableCustomerBalance", QueryResult[3].Unload());
	
EndProcedure
```

Đọc query theo từng gói của batch (Bài 10, "batch query"):
- `QueryResult[0]` (phần cắt: `Ref`, `Date`, `Operation`, `Counterparty`, `CashAccount` của chính chứng từ, `WHERE CashReceipt.Ref = &Ref`) và `[1]` (`DocumentPaymentDetails`: header + từng dòng `PaymentDetails` — `Operation`, `Counterparty`, `CashAccount`, `Document`, `PaymentAmount`, `Amount`): temp table, không trả dữ liệu.
- `QueryResult[2]` → bảng cho **CashBalance**: tổng `PaymentAmount` (tiền tệ tài khoản) vào `AmountCur`, `CashType` cố định `Cash`. Tên cột trùng tên dimension/resource của register nên `Load()` nạp thẳng được.
- `QueryResult[3]` → bảng cho **CustomerBalance**: dùng `Amount` (tiền tệ hạch toán); chỉ khi `Operation = Customer`. Dòng không có hóa đơn → `Advance`, và `Document` = chính chứng từ thu (phần cắt `// ...` là một CASE cùng điều kiện: `THEN DocumentPaymentDetails.Ref ELSE DocumentPaymentDetails.Document END AS Document`).

Khác biệt giữa 4 document trong gói `[2]`:

| Document | RecordType (CashBalance) | CashType | Period | Gói `[3]` |
|---|---|---|---|---|
| CashReceipt | Receipt | Cash | `Date` | CustomerBalance, Expense |
| CashVoucher | Expense | Cash | `Date` | SupplierBalance, Expense |
| BankReceipt | Receipt | NonCash | `Date` | CustomerBalance, Expense |
| BankPayment | Expense | NonCash | `PaymentDate` | SupplierBalance, Expense |

Đặc biệt BankPayment chỉ sinh dữ liệu khi đã đánh dấu `Paid`, và kỳ ghi sổ là `PaymentDate` chứ không phải `Date`:

Nguồn: Jet — cf/Documents/BankPayment/Ext/ManagerModule.bsl
```bsl
	"SELECT
	|	BankPayment.Ref AS Ref,
	|	BankPayment.PaymentDate AS PaymentDate,
	// ...
	|INTO DocumentHeader
	|FROM
	|	Document.BankPayment AS BankPayment
	|WHERE
	|	BankPayment.Ref = &Ref
	|	AND BankPayment.Paid
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	DocumentHeader.Ref AS Ref,
	|	DocumentHeader.PaymentDate AS Period,
```

Nếu `Paid = False`, `DocumentHeader` rỗng → mọi bảng rỗng → các `Reflect...` return sớm → chứng từ vẫn post nhưng không có register records (lệnh chi "đã lập nhưng chưa chi").

### 7.3. PostingManagement (common module của Jet)

Module `PostingManagement`: Server = true, ExternalConnection = true, ServerCall = false (chỉ gọi được từ code server). Dùng chung cho mọi document của Jet.

Nguồn: Jet — cf/CommonModules/PostingManagement/Ext/Module.bsl
```bsl
Procedure PrepareRecordSetsForWriting(DocumentObject) Export
	
	For Each RecordSet In DocumentObject.RegisterRecords Do
		// ...
	EndDo;
	
	RegisterNameArray = GetUsedRegisterNames(DocumentObject.Ref, DocumentObject.AdditionalProperties.DocumentMetadata);
	For Each RegisterName In RegisterNameArray Do
		DocumentObject.RegisterRecords[RegisterName].Write = True;
	EndDo;
	
EndProcedure

Procedure ReflectCashBalance(AdditionalProperties, RegisterRecords, Cancel) Export
	
	TableCashBalance = AdditionalProperties.TableForRegisterRecords.TableCashBalance;
	
	If Cancel Or TableCashBalance.Count() = 0 Then
		Return;
	EndIf;
	
	CashBalanceRecord = RegisterRecords.CashBalance;
	CashBalanceRecord.Write = True;
	CashBalanceRecord.Load(TableCashBalance);
	
EndProcedure
```

- `InitializeAdditionalPropertiesForPosting` tạo trong `AdditionalProperties` các khóa `TableForRegisterRecords` (Structure chứa các ValueTable), `ForPosting` (chứa `TempTablesManager`) và `DocumentMetadata`.
- `ReflectCustomerBalance` / `ReflectSupplierBalance` có cấu trúc giống hệt `ReflectCashBalance` (đọc `TableCustomerBalance` / `TableSupplierBalance`, nạp vào register tương ứng).
- `WriteRecordSets` duyệt `RegisterRecords`, với record set có `Write = True` thì gán `RecordSet.AdditionalProperties.ForPosting` rồi gọi `RecordSet.Write()`.

Giải thích cho sinh viên:
- `PrepareRecordSetsForWriting` xóa record set trong bộ nhớ, rồi (qua function private `GetUsedRegisterNames` — query `UNION` các register của document để tìm register nào **đã có** bản ghi của recorder này) bật cờ `Write = True` cho các register đó. Nhờ vậy khi re-post hoặc `UndoPosting`, bản ghi cũ trong DB bị ghi đè bằng tập rỗng — tức là bị xóa. Đây là lý do `UndoPosting` chỉ cần 3 dòng.
- Document có property RegisterRecordsWritingOnPost = `WriteSelected` (trong XML), khớp với cách bật cờ `Write` thủ công.
- `WriteRecordSets` truyền `ForPosting` (có `TempTablesManager`) sang record set — đây là "cửa" để RecordSetModule của register kiểm tra số dư (Jet dùng cho `InventoryInWarehouses`; CashBalance chưa dùng).

## 8. Form của Document và CashManagementClient / CashManagementServerCall

### 8.1. Hai common module của phân hệ

| Module | Flags | Nội dung |
|---|---|---|
| `CashManagementClient` | ClientManagedApplication = true, Server = false | `RecalculateAmountAtExchangeRate` |
| `CashManagementServerCall` | Server = true, ServerCall = true | `CurrencyExchangeRateData` |

Nguồn: Jet — cf/CommonModules/CashManagementClient/Ext/Module.bsl
```bsl
Procedure RecalculateAmountAtExchangeRate(Object, TabSectionName = "PaymentDetails") Export
	
	If Object[TabSectionName].Count() = 0 Then
		Return;
	EndIf;
	
	ExchangeRate = ?(Object.ExchangeRate = 0, 1, Object.ExchangeRate);
	Multiplier = ?(Object.Multiplier = 0, 1, Object.Multiplier);
	
	For Each Row In Object[TabSectionName] Do
		Row.Amount = Round(Row.PaymentAmount * ExchangeRate / Multiplier, 2);
	EndDo;
	
EndProcedure
```

Nguồn: Jet — cf/CommonModules/CashManagementServerCall/Ext/Module.bsl
```bsl
Procedure CurrencyExchangeRateData(DataStructure) Export
	
	PresentationCurrency = JetServer.GetPresentationCurrency();
	
	If ValueIsFilled(DataStructure.CashBankAccount) Then
		
		Currency = Common.ObjectAttributeValue(DataStructure.CashBankAccount, "Currency");
		
		If Currency <> PresentationCurrency Then
			ExchRateStructure = CurrencyRateOperations.GetCurrencyRate(Currency, DataStructure.Date);
			DataStructure.Insert("Currency", Currency);
			DataStructure.Insert("ExchangeRate", ExchRateStructure.Rate);
			DataStructure.Insert("Multiplier", ExchRateStructure.Repetition);
		Else
			// ...
		EndIf;
		// ...
	EndIf;
	
EndProcedure
```

Hai nhánh bị cắt `// ...` (tiền tệ tài khoản = tiền tệ hạch toán, hoặc tài khoản trống) đều gán `Currency = PresentationCurrency`, `ExchangeRate = 1`, `Multiplier = 1`.

Đây là ví dụ đẹp cho Bài 7 và Bài 14: tách module theo context — tính toán thuần (nhân/chia) chạy ở client, việc đọc DB (`Common.ObjectAttributeValue`, `ExchangeRates`) đi qua **một** server call, dữ liệu trao đổi bằng `Structure`. Hai module SSL được gọi: `Common` (Core) và `CurrencyRateOperations` (Currencies).

### 8.2. DocumentForm — event handlers của Jet

Form item `Currency` trên form có `ReadOnly = true`: tiền tệ luôn đi theo tài khoản, người dùng không chọn tay.

Nguồn: Jet — cf/Documents/CashReceipt/Forms/DocumentForm/Ext/Form/Module.bsl
```bsl
&AtClient
Procedure CashAccountOnChange(Item)
	
	DataStructure = New Structure("CashBankAccount, Date", Object.CashAccount, Object.Date);
	CashManagementServerCall.CurrencyExchangeRateData(DataStructure);
	FillPropertyValues(Object, DataStructure, "Currency, ExchangeRate, Multiplier");
	
	CashManagementClient.RecalculateAmountAtExchangeRate(Object);
	
	FormManagement();
	
EndProcedure

// ...
// ...
&AtClient
Procedure FormManagement()
	
	If Object.Currency = PresentationCurrency Then
		Items.ExchangeRate.ReadOnly = True;
		Items.Multiplier.ReadOnly = True;
	Else
		// ...
	EndIf;
	
	If Object.Operation = PredefinedValue("Enum.CashReceiptOperations.Other") Then
		Items.Counterparty.Visible = False;
		Items.PaymentDetailsDocument.Visible = False;
	Else
		// ...
	EndIf;
	
EndProcedure
```

- Hai handler của cột bảng: `PaymentDetailsPaymentAmountOnChange` tính `Amount = Round(PaymentAmount * ExchangeRate / Multiplier, 2)`, `PaymentDetailsAmountOnChange` tính ngược `PaymentAmount = Round(Amount * Multiplier / ExchangeRate, 2)` (tỷ giá/hệ số = 0 được thay bằng 1). `ExchangeRateOnChange`, `MultiplierOnChange` gọi `CashManagementClient.RecalculateAmountAtExchangeRate(Object)`.
- `PresentationCurrency` là form attribute, gán trong `OnCreateAtServer` bằng `JetServer.GetPresentationCurrency()`; `FormManagement` được gọi ở `OnOpen`, `OperationOnChange`, `CashAccountOnChange`.
- `PredefinedValue(...)` dùng trên client vì không truy cập được `Enums` ở client (Bài 7).
- Phần còn lại của form module là "boilerplate" SSL: `AttachableCommands` (lệnh in, tạo dựa trên…) và `PropertyManager` (Additional attributes) — đặt trong comment `// StandardSubsystems.…` để dễ nhận biết.

BankPayment thêm handler cho `Paid`:

Nguồn: Jet — cf/Documents/BankPayment/Forms/DocumentForm/Ext/Form/Module.bsl
```bsl
&AtClient
Procedure PaidOnChange(Item)
	
	If Object.Paid Then
		Object.PaymentDate = Object.Date;
	ElsIf ValueIsFilled(Object.PaymentDate) Then
		Object.PaymentDate = Date(1, 1, 1);
	EndIf;
	
	FormManagement();
	
EndProcedure
```

và trong `FormManagement` của BankPayment có thêm dòng `Items.PaymentDate.Enabled = Object.Paid;`.

## 9. Liên kết thanh toán với hóa đơn và tạm ứng (settlement)

### 9.1. Quy ước dấu trong CustomerBalance

Ghép từ code posting của SalesInvoice và CashReceipt/BankReceipt:

| Sự kiện | RecordType | LiabilityType | Document | Ý nghĩa số dư |
|---|---|---|---|---|
| SalesInvoice post | Receipt | Liability | hóa đơn | khách nợ tăng (+) |
| Thu tiền, dòng có hóa đơn | Expense | Liability | hóa đơn | khách nợ giảm |
| Thu tiền, dòng **không** có hóa đơn | Expense | Advance | chính chứng từ thu | số dư Advance **âm** = khách đã trả trước |
| SalesInvoice cấn trừ tạm ứng (`AdvanceClearing`) | Receipt | Advance | chứng từ thu | xóa dần số âm của tạm ứng |
| … đồng thời | Expense | Liability | hóa đơn | giảm nợ hóa đơn tương ứng |

SupplierBalance đối xứng: SupplierInvoice ghi Receipt/Liability; CashVoucher/BankPayment ghi Expense (Liability hoặc Advance). Wiki (Initial Setup Guide, mục 11) xác nhận: "Leave the Document field empty — this tells the system it's an advance".

### 9.2. Cấn trừ tạm ứng nằm ở phía hóa đơn

Tạm ứng không được "gắn" vào hóa đơn trong chứng từ tiền; ngược lại, hóa đơn có tabular section `AdvanceClearing` (SalesInvoice: `Document` kiểu `CashReceipt`/`BankReceipt`; SupplierInvoice: `BankPayment`/`CashVoucher`). Phần ghi sổ trong manager module SalesInvoice gồm hai nhánh `UNION ALL`: Receipt/Advance theo `Document` (chứng từ thu) và Expense/Liability theo `InvoiceDocument` (hóa đơn), cùng số tiền `SUM(DocumentAdvanceClearing.Amount)`:

Nguồn: Jet — cf/Documents/SalesInvoice/Ext/ManagerModule.bsl
```bsl
	|	VALUE(AccumulationRecordType.Receipt),
	|	DocumentAdvanceClearing.Period,
	|	VALUE(Enum.LiabilityTypes.Advance),
	// ...
	|	VALUE(AccumulationRecordType.Expense),
	|	DocumentAdvanceClearing.Period,
	|	VALUE(Enum.LiabilityTypes.Liability),
	|	DocumentAdvanceClearing.Counterparty,
	|	DocumentAdvanceClearing.InvoiceDocument,
```

Danh sách tạm ứng còn dư được chọn qua common form `SelectAdvances` (mở từ command `SelectAdvances` của form hóa đơn, tham số `IsCustomerAdvance`). Query đọc virtual table `Balance` với điều kiện `LiabilityType = Advance`, cộng lại phần hóa đơn hiện tại đã cấn trừ (để khi mở lại hóa đơn đã post không bị trừ hai lần), và đổi register bằng `StrReplace`:

Nguồn: Jet — cf/CommonForms/SelectAdvances/Ext/Form/Module.bsl
```bsl
	|SELECT
	|	BalanceTable.Document AS Document,
	|	BalanceTable.AmountBalance AS Amount,
	// ...
	|INTO TmpAdvanceBalance
	|FROM
	|	AccumulationRegister.CustomerBalance.Balance(
	|			,
	|			LiabilityType = VALUE(Enum.LiabilityTypes.Advance)
	|				AND Counterparty = &Counterparty) AS BalanceTable
	// ...
	|HAVING
	|	SUM(TmpAdvanceBalance.Amount) < 0
	// ...
	
	If Not IsCustomerAdvance Then
		Query.Text = StrReplace(Query.Text, "AccumulationRegister.CustomerBalance", "AccumulationRegister.SupplierBalance");
	EndIf;
```

`HAVING SUM(...) < 0` chính là "chỉ lấy tạm ứng còn dư" theo quy ước dấu ở 9.1. Form này thuộc phân hệ Sales/Purchases nhưng **dữ liệu nó đọc do chứng từ tiền sinh ra** — sửa logic Advance trong chứng từ tiền phải kiểm tra lại form này.

[suy luận] Chứng từ tiền không kiểm tra số tiền trả có vượt nợ còn lại của hóa đơn không; trả thừa trên dòng có hóa đơn sẽ làm số dư `Liability` của hóa đơn âm chứ không chuyển thành `Advance`.

## 10. Nhập số dư đầu kỳ

Jet **không có** document riêng cho số dư đầu kỳ tiền (tìm "Opening/InitialBalance" trong `cf/` không ra object nào). Cách làm theo wiki (1C:Jet-Initial-Setup-Guide.md, mục 10–11):

- **Tiền gửi ngân hàng**: `BankReceipt` với Operation = **Other**.
- **Tiền mặt**: `CashReceipt` với Operation = **Other**.
- Công nợ phải thu/phải trả: dùng `SalesInvoice` / `SupplierInvoice` với một product dịch vụ giả (ví dụ "Opening balances input"), ngày **trước** Start Date.
- Tạm ứng đầu kỳ: chứng từ thu/chi với Operation thường, để trống cột Document.

Code khớp với hướng dẫn: với `Other`, gói `[2]` vẫn ghi CashBalance (Receipt), còn gói `[3]` bị loại bởi `WHERE DocumentPaymentDetails.Operation = VALUE(Enum.CashReceiptOperations.Customer)` → không đụng công nợ; `Counterparty` không bắt buộc (`FillCheckProcessing`) và bị ẩn trên form (`FormManagement`).

Hệ quả: trong report CashStatement, số dư đầu kỳ hiện như một **khoản thu** trong kỳ chứa ngày của chứng từ đó, không phân biệt được với thu "Other" thật (mục 14 có gợi ý).

## 11. Reports

Cả ba report là DCS (Bài 18), chỉ có `MainDataCompositionSchema` và một command mở ngữ cảnh; không có object module.

### 11.1. CashStatement

Query của data set (lấy từ `<query>` trong template; trong XML các ký tự được escape):

Nguồn: Jet — cf/Reports/CashStatement/Templates/MainDataCompositionSchema/Ext/Template.xml
```bsl
SELECT
	CashBalanceBalanceAndTurnovers.CashType AS CashType,
	ISNULL(BankAccounts.Currency, CashAccounts.Currency) AS Currency,
	CashBalanceBalanceAndTurnovers.BankCashAccount AS BankCashAccount,
	CashBalanceBalanceAndTurnovers.AmountCurOpeningBalance AS AmountCurOpeningBalance,
	CashBalanceBalanceAndTurnovers.AmountCurReceipt AS AmountCurReceipt,
	CashBalanceBalanceAndTurnovers.AmountCurExpense AS AmountCurExpense,
	CashBalanceBalanceAndTurnovers.AmountCurClosingBalance AS AmountCurClosingBalance,
	CashBalanceBalanceAndTurnovers.Recorder AS Recorder
FROM
	AccumulationRegister.CashBalance.BalanceAndTurnovers(, , Auto, , ) AS CashBalanceBalanceAndTurnovers
		LEFT JOIN Catalog.BankAccounts AS BankAccounts
		ON CashBalanceBalanceAndTurnovers.BankCashAccount = BankAccounts.Ref
		LEFT JOIN Catalog.CashAccounts AS CashAccounts
		ON CashBalanceBalanceAndTurnovers.BankCashAccount = CashAccounts.Ref
```

- Virtual table `BalanceAndTurnovers` với periodicity `Auto` và field `Recorder` → DCS tự chi tiết đến từng chứng từ (Bài 11, 18).
- `ISNULL(BankAccounts.Currency, CashAccounts.Currency)`: kỹ thuật lấy attribute từ dimension composite type bằng hai LEFT JOIN.
- Parameters: `ItmPeriod` (StandardPeriod, mặc định `ThisMonth` trong variant), `BeginOfPeriod = &ItmPeriod.StartDate`, `EndOfPeriod = &ItmPeriod.EndDate`.
- Resources: `Sum(...)` của 4 cột AmountCur. Grouping: `Currency` → `BankCashAccount`.
- Hai variant: `CashStatement` và `CashStatementContext`; `ReportsOptionsOverridable` (module SSL Overridable có code Jet) mô tả variant chính "Opening balance, inflow, outflow, closing balance by cash or bank accounts" và tắt variant Context khỏi report panel.

Command `OpenCashStatementReport` (parameter type `CashAccounts`/`BankAccounts`, group `FormNavigationPanelSeeAlso`) mở report ngay từ thẻ tài khoản: tạo `FilterStructure` với `BankCashAccount = CommandParameter` và `CashType` = `Cash` hay `NonCash` tùy `TypeOf(CommandParameter)`, rồi `OpenForm("Report.CashStatement.Form", ...)` với `VariantKey = "CashStatementContext"`, `GenerateOnOpen = True`.

### 11.2. CustomerBalance / SupplierBalance

Hai report dùng chung một mẫu query (thay tên register). Tách số dư theo `LiabilityType` thành hai cột và đảo dấu tạm ứng để hiển thị số dương:

Nguồn: Jet — cf/Reports/CustomerBalance/Templates/MainDataCompositionSchema/Ext/Template.xml
```bsl
	CASE
		WHEN CustomerBalance.LiabilityType = VALUE(Enum.LiabilityTypes.Advance)
			THEN -CustomerBalance.AmountBalance
		ELSE 0
	END AS AmountAdvance,
	// ...
FROM
	AccumulationRegister.CustomerBalance.Balance AS CustomerBalance
```

Các field khác: `LiabilityType`, `Counterparty`, `Document`, `AmountLiability` (CASE tương tự lấy `AmountBalance` khi `Liability`).

Parameter `Period`; resources `Sum(AmountLiability)`, `Sum(AmountAdvance)`, `Sum(AmountTotal)`. `AmountTotal` = biểu thức `AmountLiability` trừ biểu thức `AmountAdvance` = công nợ ròng. Command `OpenCustomerBalanceReport` nhận `CatalogRef.Counterparties` và mở variant `CustomerBalanceContext` lọc theo `Counterparty`.

## 12. Role UseCashManagement và các điểm gắn SSL

Role `UseCashManagement` (đọc từ `Roles/UseCashManagement/Ext/Rights.xml`, chỉ liệt kê quyền = true):
- 4 document tiền: đầy đủ Read/Insert/Update/Posting/UndoPosting/Interactive… (Bài 20).
- `Catalog.CashAccounts`, `BankAccounts`, `Currencies` và các catalog `...AttachedFiles`: Read/Insert/Update/Edit…
- `AccumulationRegister.CashBalance`: **chỉ Read, View** — không có quyền ghi register. Việc ghi xảy ra nhờ **Post in privileged mode** = true trên document.
- `Document.SalesInvoice`, `SupplierInvoice`, `Catalog.Counterparties`: chỉ Read/View/InputByString; `Report.CashStatement`, `Report.Dashboard`: Use/View.
- Role này **không** có quyền trên `CustomerBalance`/`SupplierBalance` (grep = 0) — cũng dựa vào privileged mode khi post.

Các module SSL "*Overridable" có code Jet liên quan phân hệ:
- `PrintManagementOverridable`: `Settings.PrintObjects.Add(Documents.CashReceipt)` (và 3 document còn lại). Nhưng `AddPrintCommands` trong manager module của cả 4 document đang **rỗng** → chưa có mẫu in.
- `PropertyManagerOverridable`: khai báo bộ Additional attributes `Catalog_CashAccounts`, `Catalog_BankAccounts`, `Document_CashReceipt`…
- `ReportsOptionsOverridable`: section "Cash management reports" và mô tả variant CashStatement.
- `AdditionalReportsAndDataProcessorsOverridable`: thêm `Metadata.Subsystems.CashManagement` vào danh sách section → các common command `AdditionalReportsCashManagement` / `AdditionalDataProcessorsCashManagement` mở external report/data processor gắn vào phân hệ (Bài 21).

## 13. Điểm cần lưu ý / chỗ lạ trong code

1. **BankPayment tạo từ hóa đơn sẽ không ghi sổ cho tới khi tick Paid**: `Filling` không gán `Paid`, fill value của `Paid` trống (False) → post xong không có register records. Đây là ý đồ thiết kế (lệnh chi chưa thực hiện), nhưng dễ khiến sinh viên tưởng posting lỗi.
2. **Không kiểm soát âm quỹ**: CashBalance không có RecordSetModule; chi quá số dư vẫn post được.
3. **`TOP 1` không có `ORDER BY`** khi chọn quỹ/tài khoản mặc định trong `Filling` → [suy luận] nếu có nhiều tài khoản cùng tiền tệ, tài khoản được chọn không xác định trước.
4. **Comment sao chép**: manager module của CashReceipt, CashVoucher, BankPayment đều mô tả tham số là `ref to Bank receipt.` (chỉ đúng với BankReceipt; ví dụ CashVoucher: `//  CashVoucherRef - DocumentRef.CashVoucher - ref to Bank receipt.`).
5. **ChoiceParameterLinks của `PaymentDetails.Document`** trong metadata 4 document có Name = `Counterparty` (không có tiền tố `Filter.`), trong khi chính Jet dùng `Filter.Counterparty` cho chiều ngược lại (SalesInvoice.AdvanceClearing.Document). [suy luận] Với tên `Counterparty`, tham số được truyền vào choice form của hóa đơn dưới dạng parameter thường; choice form SalesInvoice không xử lý parameter này, nên danh sách hóa đơn có thể không được lọc theo khách hàng — nên kiểm tra lại trong Enterprise mode.
6. **Không có liên kết bắt buộc giữa `Counterparty` header và khách hàng của hóa đơn ở dòng**: [suy luận] code posting lấy `Counterparty` từ header cho mọi dòng; nếu chọn hóa đơn của khách khác, CustomerBalance sẽ ghi sai đối tượng.
7. Wiki (mục tạm ứng ở Initial Setup Guide) gọi "Cash Payment" — object thật là `CashVoucher`.

## 14. Gợi ý mở rộng cho nhóm sinh viên phân hệ Dòng tiền

Các ý dưới đây là **gợi ý** để nhóm chọn đề tài, dựa trên những chỗ còn trống trong Jet; chưa có trong Jet và chưa được kiểm chứng — nhóm cần thiết kế và chạy thử. Khi làm, nhắc lại nguyên tắc: không sửa trực tiếp code gốc nếu có thể làm bằng configuration extension (Purpose **Add-on** cho object mới, **Customization** khi thay đổi hành vi có sẵn); extension là **upgrade-safe customization** (xem bài Extensions).

### Gợi ý 1 — Chứng từ chuyển tiền nội bộ (CashTransfer)

Bài toán: nộp tiền mặt vào ngân hàng, rút tiền về quỹ, chuyển giữa hai tài khoản — hiện chỉ làm được bằng cặp chứng từ "Other" rời rạc.
- Object mới: `Document.CashTransfer` (header: `AccountFrom`, `AccountTo` — composite `CashAccounts`/`BankAccounts`, `Amount`), RegisterRecords = `CashBalance`.
- Posting theo đúng khuôn Jet: `PostingManagement.InitializeAdditionalPropertiesForPosting` → `Documents.CashTransfer.InitializeDocumentData` (query trả 2 dòng: Expense từ `AccountFrom`, Receipt vào `AccountTo`, `CashType` suy từ kiểu tài khoản như trong `OpenCashStatementReport`) → `ReflectCashBalance` → `WriteRecordSets`.
- Kiểm tra trong `FillCheckProcessing`: hai tài khoản khác nhau, cùng `Currency` (vì CashBalance chỉ có `AmountCur`).
- Đưa vào `Subsystems/CashManagement` và cấp quyền trong `Role.UseCashManagement`; Post in privileged mode như 4 chứng từ hiện có.

### Gợi ý 2 — Kiểm soát số dư âm của quỹ/tài khoản

- Thêm RecordSetModule cho `AccumulationRegister.CashBalance`, mô phỏng `AccumulationRegisters/InventoryInWarehouses/Ext/RecordSetModule.bsl`: `BeforeWrite` lưu bản ghi cũ vào temp table qua `AdditionalProperties.ForPosting.TempTablesManager` (do `PostingManagement.WriteRecordSets` truyền vào), `OnWrite` tính phần thay đổi và đọc `CashBalance.Balance` để báo lỗi nếu âm.
- Có thể thêm Functional option / Constant "Kiểm soát âm quỹ" (Bài 13, 15).
- Liên quan: Bài 11 (Balance), Bài 12 (DataLock, transaction), Bài 16 (thứ tự event).

### Gợi ý 3 — Khoản mục dòng tiền (Cash flow items) và báo cáo lưu chuyển tiền

- Bài toán: chi "Other" không cho biết chi cho việc gì (lương, thuê nhà, điện…). Object mới: `Catalog.CashFlowItems` (hierarchical; có thể có predefined items như "Thu từ khách hàng", "Trả nhà cung cấp").
- Thêm attribute `CashFlowItem` vào 4 document (bắt buộc khi Operation = Other — sửa `FillCheckProcessing` và `FormManagement`).
- Ghi sổ: hoặc thêm dimension vào `CashBalance`, hoặc tạo register **Turnovers** mới `CashFlow` (Period, BankCashAccount, CashFlowItem, Amount) để không ảnh hưởng report cũ. Cần sửa `InitializeDocumentData` của 4 manager module và thêm `ReflectCashFlow` theo mẫu `PostingManagement`.
- Report DCS mới "Cash flow by items" (Bài 18). Chuyển tiền nội bộ (gợi ý 1) không nên tính vào lưu chuyển.

### Gợi ý 4 — Ngân sách dòng tiền: kế hoạch và thực tế

- Tiếp nối gợi ý 3: `Document.CashFlowBudget` (kỳ, tabular section `CashFlowItem` / `Amount`), ghi vào register Turnovers `CashFlowBudget`.
- Report DCS so sánh Plan vs Actual: hai data set (budget và `CashFlow`) nối theo `CashFlowItem` + kỳ, cột chênh lệch (Bài 18: nhiều data set, data set links).
- Có thể thêm Event subscription / cảnh báo khi chứng từ chi làm vượt ngân sách (Bài 16).

### Gợi ý 5 — Mẫu in phiếu thu / phiếu chi

- Jet đã đăng ký 4 document trong `PrintManagementOverridable`, nhưng `AddPrintCommands` trong manager module đang rỗng.
- Việc cần làm: tạo template (spreadsheet), điền `AddPrintCommands` và procedure `Print` trong manager module theo SSL Print (Bài 22); dùng `CurrencyRateOperations.GenerateAmountInWords` (module SSL đã có trong Jet) để in số tiền bằng chữ.

### Gợi ý 6 — Phân biệt số dư đầu kỳ và cải thiện CashStatement

- Thêm giá trị `OpeningBalance` vào `CashReceiptOperations` / `BankReceiptOperations` (hoặc một document `CashOpeningBalance` riêng), xử lý giống `Other` trong posting và form.
- Mở rộng CashStatement: thêm field `Operation`, `Counterparty` (lấy qua `Recorder`) để lọc/nhóm, hoặc thêm resource quy đổi ra tiền tệ hạch toán (cần thêm resource `Amount` vào `CashBalance` và sửa gói `[2]` của 4 `InitializeDocumentData` — lấy `SUM(Amount)` song song với `SUM(PaymentAmount)`).
- Có thể kết hợp sửa các điểm 5–6 ở mục 13 (lọc hóa đơn theo `Counterparty`, kiểm tra hóa đơn thuộc đúng khách hàng) như một phần "Patch" nhỏ.
