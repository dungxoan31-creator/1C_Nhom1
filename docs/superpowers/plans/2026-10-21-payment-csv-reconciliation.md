# Payment CSV Reconciliation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` after this plan is approved. Complete each checked task in order.

**Goal:** Import mapped bank/gateway CSV rows, identify duplicates and mismatches, match incoming receipts to AR invoices, and prevent duplicate or invalid postings.

**Architecture:** Add a preview/import workflow to `DoiSoatKenhThanhToan`, store imported lines in its tabular section, reserve transaction identities in an information register at posting, and post cash/fee/AR movements through the existing reconciliation document.

**Tech Stack:** 1C:Enterprise 8.3.22.1704, BSL, XML metadata, managed forms, PowerShell and CSV fixtures.

**Spec:** `docs/superpowers/specs/2026-10-21-finance-e2e-completion-design.md`, section 3.3.

## Global Constraints

- CSV import is preview-only until the user confirms; it never calls a bank/gateway API or sends money.
- Do not post a row with invalid structure, unresolved duplicate, unmatched transaction, or an unbalanced `gross = fee + net` amount.
- Match only to an issued AR invoice with a positive outstanding balance; one CSV row maps to one invoice in this version.
- Partial receipt is allowed up to the open balance; over-collection is rejected.
- Existing manually entered VNPAY/OnePay reconciliation without imported rows remains supported.
- Use a managed lock and persistent key so concurrent/repeated imports cannot post a bank transaction twice.
- No Git repository exists; omit commit steps.

## Review Focus

- Quoted commas, doubled quotes, UTF-8 BOM, and comma/semicolon delimiters must parse correctly; test these in the parser task.
- Ambiguous numeric separators must be controlled by the import mapping; test rejected or explicitly mapped formats.
- Duplicate external ID and fallback fingerprint must both stop double posting; test repeat import after the first posting.
- A partial amount must leave residual AR; an amount above outstanding must be rejected with no register movement; test both.
- Unmatched/mismatched rows must not post cash, AR, or GL; test zero movement after rejection.

## Files and responsibilities

- Create `Configuration/CommonModules/NhapSaoKeCsvServer.xml` and `.../Ext/Module.bsl` for CSV parsing, column mapping, normalization, fingerprinting, and match suggestions.
- Modify `Configuration/Documents/DoiSoatKenhThanhToan.xml`, its `Ext/ObjectModule.bsl`, and add `Forms/FormChungTu.xml`, `Forms/FormChungTu/Ext/Form.xml`, and `Forms/FormChungTu/Ext/Form/Module.bsl` for row storage and preview/match commands.
- Create `Configuration/InformationRegisters/GiaoDichSaoKeDaNhap.xml` for posted external transaction keys and source links.
- Add the standard `RegisterRecords` command to the new reconciliation object form so imported-document movements open from **Khác**.
- Modify `Configuration/Configuration.xml`, `Subsystems/PhanHeNganHangVaQuy.xml`, and applicable role rights for the new object/form.
- Modify `CommonModules/SeedBoundaryTestsServer/Ext/Module.bsl`, `scripts/run_finance_e2e.ps1`, `scripts/run_finance_ui_e2e.ps1`.
- Create `scripts/fixtures/bank_statement_vnpay_demo.csv` and `scripts/test_statement_csv_contract.ps1`.

---

### Task 1: Add CSV parser and explicit column mapping

**Files:**
- Create: `CommonModules/NhapSaoKeCsvServer.xml`, `CommonModules/NhapSaoKeCsvServer/Ext/Module.bsl`
- Create: `scripts/test_statement_csv_contract.ps1`
- Test: `scripts/fixtures/bank_statement_vnpay_demo.csv`

**Interfaces:**
- `Function ParseCSVRows(Val CSVText, Val ColumnMap, Val Delimiter, Val DecimalSeparator, Val ThousandsSeparator) Export` returns `Structure("Rows,Errors")`; `Rows` is a `ValueTable`, `Errors` is a `ValueTable` with line and field.
- `Function CreateTransactionKey(Val LegalEntity, Val CashAccount, Val Channel, Val ExternalId, Val Date, Val Currency, Val Amount, Val NormalizedMemo) Export` returns a stable string key.

- [ ] **Step 1: Write parser contract cases** for quoted comma, escaped quote, BOM, CRLF, comma/semicolon delimiter, row count, missing mapped column, malformed number, and duplicate headers.
- [ ] **Step 2: Run `test_statement_csv_contract.ps1`** with `-ConfigurationPath .\VSF_Finance_E2E\Configuration -FixturePath .\VSF_Finance_E2E\scripts\fixtures\bank_statement_vnpay_demo.csv`; confirm it fails because parser/module does not exist.
- [ ] **Step 3: Implement `ParseCSVRows`** with explicit mapping and locale separators; preserve row number and return errors without coercing invalid amounts to zero.
- [ ] **Step 4: Implement `CreateTransactionKey`** using external transaction ID where supplied, otherwise a normalized account/date/currency/amount/memo fingerprint.
- [ ] **Step 5: Add the fixture rows** for gross 75,000,000 VND, fee 1,125,000 VND, and net 73,875,000 VND; the contract test must report valid totals and no parse errors.

### Task 2: Store statement rows and deduplicate posting

**Files:**
- Modify: `Documents/DoiSoatKenhThanhToan.xml`, `Documents/DoiSoatKenhThanhToan/Ext/ObjectModule.bsl`
- Create: `InformationRegisters/GiaoDichSaoKeDaNhap.xml`
- Modify: `Configuration/Configuration.xml`, applicable role `Rights.xml`
- Test: `CommonModules/SeedBoundaryTestsServer/Ext/Module.bsl`

**Interfaces:**
- Add tabular section `GiaoDichSaoKe` with external ID/key, transaction/value dates, memo, currency, gross, fee, net, matched AR invoice, matched amount, and row status/reason.
- Information register key is legal entity + cash account + channel + normalized transaction key; its record points to the reconciliation document and imported row.

- [ ] **Step 1: Add failing runtime cases** for duplicate ID, fallback fingerprint duplicate, missing key components, and concurrent duplicate posting.
- [ ] **Step 2: Invoke the new `csv_dedup_verify` phase** on a disposable infobase; confirm the expected duplicate cases are absent/failing.
- [ ] **Step 3: Add the tabular section and information register** with managed locking on the full unique key.
- [ ] **Step 4: Validate and reserve each imported key in the same posting transaction**; return a user-visible duplicate row/ID and roll back all cash/AR/GL movements on conflict.
- [ ] **Step 5: Run the runtime duplicate phase twice with the same source rows**; first post is PASS, second attempt is rejected and register/cash totals remain unchanged.

### Task 3: Add preview and AR matching to the reconciliation form

**Files:**
- Create: `Documents/DoiSoatKenhThanhToan/Forms/FormChungTu.xml`
- Create: `Documents/DoiSoatKenhThanhToan/Forms/FormChungTu/Ext/Form.xml`
- Create: `Documents/DoiSoatKenhThanhToan/Forms/FormChungTu/Ext/Form/Module.bsl`
- Modify: `Subsystems/PhanHeNganHangVaQuy.xml`, form role rights

**Interfaces:**
- Form actions: `ChonTepCSV`, `XemTruocCSV`, `GhepHoaDonAR`, and `XacNhanDongGhep`.
- Match suggestions use issued `Document.HoaDonGTGTDauRa` references and positive `CongNoPhaiThu` balance; explicit invoice reference takes priority, then partner/reference/amount suggestions.

- [ ] **Step 1: Add failing native UI cases** for file selection, field mapping, preview counts, manual match confirmation, and unmatched-row blocker.
- [ ] **Step 2: Run the reconciliation UI E2E** and confirm those controls/actions are absent.
- [ ] **Step 3: Add the managed form** with file, channel/account/currency, delimiter/encoding/number separators, mapping, preview table, and match/status columns; expose **Khác → Chuyển động của chứng từ theo sổ** for its posted movements.
- [ ] **Step 4: Populate only suggestions until a user confirms the invoice**; do not auto-match solely by amount. Reject a row when matched amount exceeds current outstanding balance.
- [ ] **Step 5: Verify preview has valid/error/duplicate/unmatched/mismatch counts** and every blocked row names its CSV line and resolution.

### Task 4: Post confirmed rows through existing reconciliation logic

**Files:**
- Modify: `Documents/DoiSoatKenhThanhToan/Ext/ObjectModule.bsl`
- Modify: `CommonModules/SeedBoundaryTestsServer/Ext/Module.bsl`
- Test: `scripts/test_statement_csv_contract.ps1`

**Interfaces:**
- Imported mode recomputes header gross/fee/net from included confirmed rows. The legacy single-summary mode remains unchanged.
- For each matched row, write a decrease to AR with `ChungTuGoc` set to the matched invoice; write cash for net and fee/clearing GL entries through the current account mapping.

- [ ] **Step 1: Add failing posting cases** for exact receipt, partial receipt, over-collection, unmatched row, fee imbalance, and legacy VNPAY summary.
- [ ] **Step 2: Run `csv_posting_verify`** and confirm new line-level assertions fail while old VNPAY cases remain recorded.
- [ ] **Step 3: Implement imported-mode posting** with atomic validation and transaction rollback; require `gross = fee + net` and recompute totals from rows rather than trusting editable header totals.
- [ ] **Step 4: Assert exact totals** for 75,000,000 gross, 73,875,000 cash, 1,125,000 fee, AR reduction equal to the confirmed matched amount, and GL balance.
- [ ] **Step 5: Assert partial receipt leaves the expected AR residual** and every rejected case leaves cash, AR, and GL deltas at zero.

### Task 5: Connect CSV cases to the full E2E runner

**Files:**
- Modify: `scripts/run_finance_e2e.ps1`, `scripts/run_finance_ui_e2e.ps1`
- Modify: `CommonModules/SeedBoundaryTestsServer/Ext/Module.bsl`
- Test: `scripts/fixtures/bank_statement_vnpay_demo.csv`

- [ ] **Step 1: Add `csv_import_preview`, `csv_match_post`, `csv_duplicate_reimport`, and `csv_invalid_rows` phases** to the runner summary.
- [ ] **Step 2: Run each phase on a fresh disposable infobase** with `invoke_finance_e2e_phase.ps1`; expected result is PASS for valid preview/post and zero-movement rejection for invalid/repeated rows.
- [ ] **Step 3: Add UI checks** for the CSV form, row statuses, match selection, navigation to the linked AR invoice, and the reconciliation form’s register-records command.
- [ ] **Step 4: Run the full finance E2E after the reporting/forms plans are merged**; preserve the existing 75m VNPAY regression and add CSV row-level artifacts to `summary.json`.
