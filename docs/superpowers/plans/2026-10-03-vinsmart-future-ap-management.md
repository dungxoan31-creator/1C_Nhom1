# VinSmart Future Accounts Payable Management (AP) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Xây dựng hoàn chỉnh phân hệ Quản lý công nợ phải trả (AP) và Dòng tiền chi trả (Cash Management) cho Công ty Công nghệ VinSmart Future trên nền tảng 1C:Enterprise 8.3 trong 2 tuần, đáp ứng trọn vẹn 8 năng lực AP cốt lõi, liên kết sổ cái kế toán (TK 331) và đóng gói thành file `.dt`.

**Architecture:** Cấu hình mở rộng trực tiếp trên dự án 1C hiện hữu (`src/`). Sử dụng mô hình Subledger chi tiết (`AccumulationRegister.AccountsPayable`) liên kết với chứng từ hóa đơn tài chính (`Document.VendorInvoice`), quản lý hạn nợ (`DueDate`) theo hợp đồng (`Catalog.Contracts`), phân bổ thanh toán linh hoạt trên phiếu chi (`Document.CashPayment`), cập nhật dòng tiền thực tế (`AccumulationRegister.CashFlow`), lập kế hoạch quét tự động theo hạn nợ (`Document.CashFlowPlan`), và hạch toán kép đồng thời vào Sổ kế toán tổng hợp (`AccountingRegister.GeneralLedger` qua `ChartOfAccounts.Main`).

**Tech Stack:** 1C:Enterprise 8.3 (Platform 8.3.22.1704 / Managed Application / Taxi Interface / BSL 1C Script / XML Configuration Dump & Load / 1cv8 CLI).

**Spec:** [docs/superpowers/specs/2026-10-03-vinsmart-future-ap-management-design.md](file:///C:/Users/Dung/Documents/1C_Enterprise/docs/superpowers/specs/2026-10-03-vinsmart-future-ap-management-design.md)

---

## Global Constraints

- Mọi mã nguồn BSL, tên định danh 1C đối tượng (metadata objects), thuộc tính (attributes), dimensions, resources giữ nguyên tiếng Anh chuẩn (`VendorInvoice`, `CashPayment`, `AccountsPayable`, `GeneralLedger`...).
- Giao diện người dùng (Synonym tiếng Việt/Anh), báo cáo và tài liệu thể hiện bằng tiếng Việt rõ ràng, chuyên nghiệp.
- Mọi thay đổi metadata được thực hiện chuẩn xác trong cấu trúc XML tại `C:\Users\Dung\Documents\1C_Enterprise\src\`.
- Sau mỗi tác vụ (Task), cấu hình phải được nạp và cập nhật thành công vào cơ sở dữ liệu (`/LoadConfigFromFiles` và `/UpdateDBCfg`) mà không phát sinh lỗi biên dịch.
- Cơ chế kiểm thử tự động (Verification step) phải được thực thi trực tiếp bằng lệnh 1C Enterprise batch mode hoặc kiểm tra cấu trúc dữ liệu thực tế.

## Review Focus

1. **Sai lệch hạn thanh toán (Due Date calculation)**: Nếu hợp đồng không có số ngày nợ hoặc hóa đơn không chọn hợp đồng, hệ thống phải gán mặc định `DueDate = Date` (thanh toán ngay), không được để giá trị rỗng hoặc `0001-01-01`.
2. **Thanh toán vượt quá số nợ (Over-allocation)**: Khi người dùng phân bổ số tiền thanh toán vào hóa đơn lớn hơn số dư nợ còn lại (`OutstandingAmount`), hệ thống phải cảnh báo hoặc tự động tách phần dư thừa thành khoản chưa phân bổ (`Unallocated Payment`).
3. **Thanh toán trả trước (Prepayment / Unallocated Payment)**: Chứng từ `CashPayment` khi không chọn hóa đơn nào phải ghi nhận số dư âm (hoặc số dư ứng trước) cho NCC, không được gây lỗi khóa ngoại hoặc crash khi tính toán Aging.
4. **Đối trừ công nợ khi hủy/sửa chứng từ (Unpost/Repost Integrity)**: Khi hủy ghi nhận hoặc sửa số tiền của `VendorInvoice` hay `CashPayment`, số dư trên `AccountsPayable`, `CashFlow` và `GeneralLedger` phải tự động đồng bộ sạch sẽ, không sinh rác hoặc lệch số dư.
5. **Độ lệch đối chiếu kế toán (Accounting Reconciliation Discrepancy)**: Số dư cuối kỳ của TK 331 trên `GeneralLedger` phải luôn bằng chính xác tổng số dư chi tiết của `AccountsPayable` tại mọi thời điểm chốt sổ (`Variance = 0`).

---

## Task Decomposition

### Task 1: Danh mục cốt lõi & Phân hệ AP cho VinSmart Future

**Files:**
- Create: `src/Catalogs/Contracts.xml`, `src/Catalogs/Contracts/`
- Create: `src/Catalogs/CashAccounts.xml`, `src/Catalogs/CashAccounts/`
- Create: `src/Catalogs/CashFlowItems.xml`, `src/Catalogs/CashFlowItems/`
- Create: `src/Enums/CashFlowType.xml`, `src/Enums/CashClassificationMethod.xml`
- Create: `src/Subsystems/AccountsPayable.xml`
- Modify: `src/Configuration.xml` (Đăng ký metadata mới vào danh sách ChildObjects và Subsystem)
- Modify: `src/Catalogs/Counterparties.xml` (Bổ sung thuộc tính `IsSupplier`, `TaxCode`, `PaymentTermsDays`)

**Interfaces:**
- Consumes: `Catalog.Counterparties` hiện hữu.
- Produces: 
  - `Catalog.Contracts`: Có `Owner` (Counterparties), `PaymentTermsDays` (Number 3, 0), `DefaultCashFlowItem`.
  - `Catalog.CashAccounts`: Quản lý tài khoản ngân hàng và quỹ tiền mặt.
  - `Catalog.CashFlowItems`: Predefined items: Linh kiện phần cứng BOM, Cloud AWS/GCP, Bản quyền phần mềm SaaS, Thuê ngoài R&D, Bảo trì IT...

- [ ] **Step 1: Tạo tệp XML metadata cho Catalogs và Enums**
  Tạo `Contracts.xml`, `CashAccounts.xml`, `CashFlowItems.xml`, `CashFlowType.xml`, `CashClassificationMethod.xml` và cập nhật `Counterparties.xml` đúng chuẩn 1C schema version 2.15.
- [ ] **Step 2: Đăng ký đối tượng mới vào `src/Configuration.xml` và tạo phân hệ `AccountsPayable`**
  Thêm các phần tử `<Catalog>`, `<Enum>`, `<Subsystem>` vào danh sách `<ChildObjects>` của `Configuration.xml`.
- [ ] **Step 3: Cập nhật cấu hình vào Infobase**
  Chạy lệnh:
  `1cv8t.exe DESIGNER /F "C:\Users\Dung\Documents\1C_Enterprise\Infobase" /LoadConfigFromFiles "C:\Users\Dung\Documents\1C_Enterprise\src" /UpdateDBCfg`
- [ ] **Step 4: Kiểm tra và xác nhận cấu hình được nạp thành công**
  Kiểm tra mã thoát (ExitCode = 0) và xác nhận thông điệp cập nhật thành công từ log.

---

### Task 2: Khung Kế Toán Kép (Chart of Accounts & General Ledger)

**Files:**
- Create: `src/ChartsOfAccounts/Main.xml`, `src/ChartsOfAccounts/Main/`
- Create: `src/AccountingRegisters/GeneralLedger.xml`, `src/AccountingRegisters/GeneralLedger/`
- Modify: `src/Configuration.xml` (Khai báo ChartOfAccounts.Main và AccountingRegister.GeneralLedger)

**Interfaces:**
- Consumes: `Catalog.Counterparties`, `Catalog.Contracts`.
- Produces:
  - `ChartOfAccounts.Main`: Chứa các tài khoản chuẩn:
    - `111` (Tiền mặt - Cash)
    - `112` (Tiền gửi ngân hàng - Bank)
    - `156` (Hàng hóa & Linh kiện kho)
    - `331` (Phải trả cho người bán - AP, bật theo dõi chi tiết Subconto: Đối tác, Hợp đồng)
    - `627` (Chi phí hạ tầng & Kỹ thuật chung - Cloud/IDC)
    - `642` (Chi phí quản lý doanh nghiệp - Software Licenses/SaaS)
  - `AccountingRegister.GeneralLedger`: Sổ kế toán tổng hợp Nợ/Có.

- [ ] **Step 1: Tạo metadata `ChartOfAccounts.Main.xml` và các tài khoản định sẵn (Predefined Accounts)**
  Khai báo tài khoản 111, 112, 156, 331, 627, 642 với phân loại Nợ/Có phù hợp.
- [ ] **Step 2: Tạo metadata `AccountingRegister.GeneralLedger.xml`**
  Gắn bảng tài khoản `ChartOfAccounts.Main`, thiết lập cờ cân đối bút toán kép (`Correspondence = True`).
- [ ] **Step 3: Đăng ký vào `Configuration.xml` và cập nhật cơ sở dữ liệu**
  Nạp cấu hình vào cơ sở dữ liệu thông qua lệnh `/LoadConfigFromFiles` và `/UpdateDBCfg`.
- [ ] **Step 4: Kiểm chứng tính hợp lệ của Sổ cái kế toán**
  Kiểm tra log cập nhật DB không có lỗi ràng buộc dữ liệu.

---

### Task 3: Sổ Chi Tiết AP & Chứng Từ Hóa Đơn Mua (VendorInvoice)

**Files:**
- Create: `src/AccumulationRegisters/AccountsPayable.xml`, `src/AccumulationRegisters/AccountsPayable/`
- Create: `src/Documents/VendorInvoice.xml`, `src/Documents/VendorInvoice/Ext/ObjectModule.bsl`
- Create: `src/Documents/VendorInvoice/Forms/DocumentForm.xml`, `src/Documents/VendorInvoice/Forms/DocumentForm/Ext/Form/Module.bsl`
- Modify: `src/Configuration.xml` (Khai báo Document.VendorInvoice và AccumulationRegister.AccountsPayable)

**Interfaces:**
- Consumes: `Catalog.Counterparties`, `Catalog.Contracts`, `ChartOfAccounts.Main`, `AccountingRegister.GeneralLedger`.
- Produces:
  - `AccumulationRegister.AccountsPayable`: Balances theo `Company`, `Counterparty`, `Contract`, `Invoice`; lưu `DueDate`.
  - `Document.VendorInvoice`: Tự tính `DueDate = Date + Contract.PaymentTermsDays`.
  - Logic Posting:
    - Ghi tăng nợ vào `AccountsPayable` (Receipt).
    - Sinh bút toán: Nợ TK 627/642/156, Có TK 331 trên `GeneralLedger`.

- [ ] **Step 1: Tạo metadata `AccumulationRegister.AccountsPayable.xml`**
  Định nghĩa đầy đủ Dimensions (`Company`, `Counterparty`, `Contract`, `Invoice`), Resource (`Amount`), Attribute (`DueDate`).
- [ ] **Step 2: Tạo metadata và form cho `Document.VendorInvoice.xml`**
  Khai báo các thuộc tính: Số hóa đơn NCC, Đối tác, Hợp đồng, Ngày hóa đơn, Hạn nợ, Mục dòng tiền, bảng dịch vụ/linh kiện chi tiết.
- [ ] **Step 3: Viết BSL Code cho ObjectModule của `VendorInvoice`**
  Cài đặt sự kiện `Posting(Cancel, Mode)`: Tự động ghi vào `AccountsPayable` và `GeneralLedger`.
  Cài đặt logic gán `DueDate`: Nếu chọn Hợp đồng, lấy số ngày nợ cộng vào ngày chứng từ; nếu không có thì gán bằng ngày chứng từ.
- [ ] **Step 4: Nạp và kiểm thử cập nhật cấu hình vào 1C Infobase**
  Chạy lệnh cập nhật DB và kiểm tra log.

---

### Task 4: Động Cơ Thanh Toán & Phân Bổ Công Nợ (CashPayment & Payment Allocation)

**Files:**
- Create: `src/Documents/CashPayment.xml`, `src/Documents/CashPayment/Ext/ObjectModule.bsl`
- Create: `src/Documents/CashPayment/Forms/DocumentForm.xml`, `src/Documents/CashPayment/Forms/DocumentForm/Ext/Form/Module.bsl`
- Modify: `src/Configuration.xml` (Khai báo Document.CashPayment)

**Interfaces:**
- Consumes: `AccumulationRegister.AccountsPayable`, `Catalog.CashAccounts`, `AccountingRegister.GeneralLedger`.
- Produces:
  - `Document.CashPayment`: Hỗ trợ thanh toán toàn bộ, thanh toán một phần (`Partial Payment`), và thanh toán ứng trước (`Unallocated Payment`).
  - Bảng phân bổ `PaymentAllocation` (`Invoice`, `AllocatedAmount`).
  - Logic Posting:
    - Ghi giảm nợ trên `AccountsPayable` (Expense).
    - Sinh bút toán: Nợ TK 331, Có TK 111/112 trên `GeneralLedger`.

- [ ] **Step 1: Tạo metadata `Document.CashPayment.xml`**
  Khai báo Header (`Account`, `Counterparty`, `Contract`, `PaymentAmount`, `CashFlowItem`) và Tabular Section `PaymentAllocation` (`Invoice`, `AllocatedAmount`).
- [ ] **Step 2: Lập trình BSL ObjectModule cho `CashPayment`**
  Xử lý logic `Posting`:
  - Nếu có bảng phân bổ: Duyệt từng dòng và ghi giảm công nợ cho từng `Invoice`.
  - Nếu không có bảng phân bổ (trả trước): Ghi giảm công nợ với `Invoice = Undefined` (hoặc rỗng).
  - Ghi bút toán kép vào `GeneralLedger`: Nợ TK 331, Có TK 111/112.
- [ ] **Step 3: Lập trình hỗ trợ trên DocumentForm**
  Nút "Fill Outstanding Invoices" (Tự động điền các hóa đơn chưa trả của NCC được chọn).
- [ ] **Step 4: Nạp và kiểm thử cập nhật cấu hình vào 1C Infobase**
  Chạy lệnh cập nhật DB và kiểm tra log.

---

### Task 5: Tích Hợp Sổ Dòng Tiền & Vị Thế Quỹ (CashFlow & Cash Position)

**Files:**
- Create: `src/AccumulationRegisters/CashFlow.xml`, `src/AccumulationRegisters/CashFlow/`
- Modify: `src/Documents/CashPayment/Ext/ObjectModule.bsl` (Bổ sung ghi sổ CashFlow)
- Modify: `src/Configuration.xml` (Khai báo AccumulationRegister.CashFlow)

**Interfaces:**
- Consumes: `Document.CashPayment`, `Catalog.CashAccounts`, `Catalog.CashFlowItems`.
- Produces:
  - `AccumulationRegister.CashFlow`: Loại Balances theo `Account` và `CashFlowItem`.
  - Khi chi tiền trả nợ NCC: Ghi nhận Expense trên `CashFlow`, giảm số dư tiền của `Account`, lưu vết `Counterparty` và `SourceDocument`.

- [ ] **Step 1: Tạo metadata `AccumulationRegister.CashFlow.xml`**
  Dimensions: `Account` (CashAccounts), `CashFlowItem` (CashFlowItems); Resource: `Amount`; Attributes: `Counterparty`, `SourceDocument`.
- [ ] **Step 2: Cập nhật ObjectModule `CashPayment` để ghi đồng thời vào `CashFlow`**
  Trong `Posting`: Thêm bản ghi Expense vào `RegisterRecords.CashFlow` với số tiền thanh toán thực tế và mục dòng tiền.
- [ ] **Step 3: Nạp và cập nhật cấu hình vào cơ sở dữ liệu**
  Chạy `/LoadConfigFromFiles` và `/UpdateDBCfg`.

---

### Task 6: Kế Hoạch Dòng Tiền & Tự Động Quét Hạn Nợ (CashFlowPlan & Due Date Scan)

**Files:**
- Create: `src/AccumulationRegisters/CashFlowPlan.xml`, `src/AccumulationRegisters/CashFlowPlan/`
- Create: `src/Documents/CashFlowPlan.xml`, `src/Documents/CashFlowPlan/Ext/ObjectModule.bsl`
- Create: `src/Documents/CashFlowPlan/Forms/DocumentForm.xml`, `src/Documents/CashFlowPlan/Forms/DocumentForm/Ext/Form/Module.bsl`
- Modify: `src/Configuration.xml` (Khai báo Document.CashFlowPlan và AccumulationRegister.CashFlowPlan)

**Interfaces:**
- Consumes: `AccumulationRegister.AccountsPayable`, `Document.VendorInvoice`.
- Produces:
  - `AccumulationRegister.CashFlowPlan`: Lưu trữ kế hoạch lưu lượng chi trả theo kỳ và mục dòng tiền.
  - Chức năng BSL `FillFromDueDates(BeginDate, EndDate)`: Truy vấn số dư nợ của các hóa đơn có `DueDate` nằm trong kỳ kế hoạch và tự động nạp vào bảng kế hoạch chi.

- [ ] **Step 1: Tạo metadata `AccumulationRegister.CashFlowPlan.xml`**
  Loại Turnovers theo `CashFlowItem`, `Counterparty`; Resource: `PlannedAmount`.
- [ ] **Step 2: Tạo metadata và form `Document.CashFlowPlan.xml`**
  Header: `PlanPeriod`, `Description`; Tabular Section: `Counterparty`, `Contract`, `CashFlowItem`, `PlannedDueDate`, `PlannedAmount`.
- [ ] **Step 3: Viết thủ tục BSL `FillFromDueDates` trên Form & ObjectModule**
  Sử dụng câu lệnh truy vấn 1C Query quét `AccountsPayable.Balance` kết hợp với thuộc tính `DueDate`.
- [ ] **Step 4: Nạp và cập nhật cấu hình vào cơ sở dữ liệu**
  Chạy `/LoadConfigFromFiles` và `/UpdateDBCfg`.

---

### Task 7: Bộ Báo Cáo Chuyên Sâu (AP Outstanding, Aging, Statement, Reconciliation, Cash Position, Actual vs Plan)

**Files:**
- Create: `src/Reports/APOutstanding.xml`, `src/Reports/APOutstanding/`
- Create: `src/Reports/APAging.xml`, `src/Reports/APAging/`
- Create: `src/Reports/SupplierStatement.xml`, `src/Reports/SupplierStatement/`
- Create: `src/Reports/APReconciliationWithAccounting.xml`, `src/Reports/APReconciliationWithAccounting/`
- Create: `src/Reports/CashPosition.xml`, `src/Reports/CashPosition/`
- Create: `src/Reports/ActualVsPlanCashFlow.xml`, `src/Reports/ActualVsPlanCashFlow/`
- Modify: `src/Configuration.xml` (Đăng ký 6 Reports mới)

**Interfaces:**
- Consumes: `AccountsPayable`, `CashFlow`, `CashFlowPlan`, `GeneralLedger`.
- Produces: Bộ 6 báo cáo quản trị đầy đủ trên giao diện Taxi DCS (Data Composition Schema):
  1. `APOutstanding`: Báo cáo chi tiết công nợ phải trả theo NCC & Hóa đơn.
  2. `APAging`: Báo cáo phân loại tuổi nợ (Chưa đến hạn, 1-30, 31-60, 61-90, >90 ngày).
  3. `SupplierStatement`: Bảng đối chiếu biến động công nợ đối tác (Đầu kỳ, Mua hàng, Thanh toán, Cuối kỳ).
  4. `APReconciliationWithAccounting`: Đối chiếu Sổ chi tiết AP vs Số dư Có TK 331 (hiển thị cột Variance).
  5. `CashPosition`: Báo cáo số dư Quỹ và Tài khoản ngân hàng.
  6. `ActualVsPlanCashFlow`: Báo cáo so sánh Kế hoạch chi vs Thực tế đã chi trả.

- [ ] **Step 1: Tạo Schema DCS và metadata cho các báo cáo công nợ (APOutstanding, APAging, SupplierStatement)**
  Xây dựng câu truy vấn Query trích xuất dữ liệu từ `AccumulationRegister.AccountsPayable.BalancesAndTurnovers`.
- [ ] **Step 2: Tạo Schema DCS cho báo cáo APReconciliationWithAccounting**
  Full Outer Join giữa bảng ảo `AccountsPayable.Balances` và `GeneralLedger.Balances` (Tài khoản 331), tính công thức `Variance = AccountsPayableAmount - GeneralLedgerAmount`.
- [ ] **Step 3: Tạo Schema DCS cho CashPosition và ActualVsPlanCashFlow**
  Truy vấn từ `CashFlow.BalancesAndTurnovers` và `CashFlowPlan.Turnovers`.
- [ ] **Step 4: Đăng ký các báo cáo vào `Configuration.xml` và cập nhật cơ sở dữ liệu**
  Chạy `/LoadConfigFromFiles` và `/UpdateDBCfg`.

---

### Task 8: Dựng Kịch Bản Kiểm Thử VinSmart Future DoD, Xác Nhận Toàn Vẹn & Xuất File `.dt`

**Files:**
- Create: `scripts/test_vinsmart_ap_flow.py` hoặc 1C batch test runner.
- Output: `VinSmart_Future_AP_MVP.dt` (Tệp sao lưu hoàn chỉnh).

**Interfaces:**
- Consumes: Toàn bộ phân hệ đã hoàn thiện ở các Task 1 - 7.
- Produces: Kịch bản kiểm thử tự động chứng minh Definition of Done:
  1. Tạo nhà cung cấp mẫu: *AWS Cloud Services*, *Qualcomm Technologies*, *JetBrains s.r.o*.
  2. Tạo hợp đồng công nghệ với điều khoản tín dụng (AWS Net 30, Qualcomm Net 45).
  3. Lập Hóa đơn mua: AWS Cloud (100.000.000 VNĐ), Qualcomm (200.000.000 VNĐ).
  4. Xác nhận `DueDate` được tính tự động đúng chuẩn.
  5. Lập kế hoạch chi trả `CashFlowPlan` từ chức năng quét hạn nợ.
  6. Lập phiếu chi `CashPayment` trả một phần 40.000.000 VNĐ cho AWS Cloud.
  7. Kiểm tra kết quả:
     - Dư nợ AWS = 60.000.000 VNĐ.
     - Dư nợ Qualcomm = 200.000.000 VNĐ.
     - Số dư tiền mặt/ngân hàng giảm 40.000.000 VNĐ.
     - Số dư Sổ chi tiết AP = 260.000.000 VNĐ khớp 100% với Sổ cái TK 331 (`Variance = 0`).
  8. Xuất Infobase hoàn chỉnh ra tệp `VinSmart_Future_AP_MVP.dt`.

- [ ] **Step 1: Viết script nạp dữ liệu và kiểm thử kịch bản DoD**
  Khởi tạo dữ liệu mẫu và thực hiện ghi sổ tự động qua 1C Enterprise.
- [ ] **Step 2: Chạy kiểm thử và xác nhận các chỉ số nghiệp vụ**
  Đảm bảo tất cả 9 tiêu chí DoD đạt kết quả PASS.
- [ ] **Step 3: Xuất cơ sở dữ liệu ra file `.dt`**
  Chạy lệnh:
  `1cv8t.exe DESIGNER /F "C:\Users\Dung\Documents\1C_Enterprise\Infobase" /DumpIB "C:\Users\Dung\Documents\1C_Enterprise\VinSmart_Future_AP_MVP.dt"`
- [ ] **Step 4: Kiểm tra tệp `.dt` đã tạo thành công và báo cáo nghiệm thu**
  Kiểm tra dung lượng file, tính toàn vẹn và lập báo cáo kết quả hoàn thành.
