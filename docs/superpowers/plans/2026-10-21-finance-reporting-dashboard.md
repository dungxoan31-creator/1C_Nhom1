# Finance Reporting and Dashboard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` after this plan is approved. Complete each checked task in order.

**Goal:** Add usable AR/AP ledger and aging reports, and make dashboard data drill down to the same report rows.

**Architecture:** Add native 1C Report metadata with SKD queries over existing debt registers; keep `BangDieuKhienServer` as the dashboard data source and route clicks through native 1C forms/commands. Add runtime register assertions and native UI checks.

**Tech Stack:** 1C:Enterprise 8.3.22.1704, BSL, XML metadata, SKD, PowerShell E2E/UI automation.

**Spec:** `docs/superpowers/specs/2026-10-21-finance-e2e-completion-design.md`

## Global Constraints

- Preserve configuration compatibility `Version8_3_22` and managed application behavior.
- Use `AccumulationRegister.CongNoPhaiThu` and `AccumulationRegister.CongNoPhaiTra` as the subledger source of truth.
- Use the same aging calculation for dashboard and report: due date equals source document date plus contract payment days; missing term is a separate `Chưa xác định hạn` group.
- Keep the buckets `Trong hạn`, `Quá hạn 1–30 ngày`, `31–60 ngày`, `61–90 ngày`, `Trên 90 ngày`, and `Chưa xác định hạn`.
- Open source documents and reports with native 1C actions; do not use `vsmart://` or `vinsmart:` custom protocols.
- Keep VAT/accounting policy unchanged; retain the existing 8% regression cases.
- No Git repository exists in the workspace; omit commit steps and keep changes in the project paths named here.

## Review Focus

- Branch/role RLS must still constrain each report; test AR, AP, CFO, and cross-branch access in the report runtime phase.
- Period boundary dates must include the selected start and end; test a movement on each boundary.
- Missing contract/payment terms must go only to `Chưa xác định hạn`; test a source with absent terms.
- Unposted and unposted-after-reversal documents must not contribute to balances; test posting and undo-posting.
- Dashboard aggregate and drill-down filters must describe the same source rows; test each aging bucket and one chart period in UI E2E.

## Files and responsibilities

- Create `VSF_Finance_E2E/Configuration/Reports/SoChiTietCongNoAR.xml` and its `SoChiTietCongNoAR/Ext/Template.xml`: AR ledger SKD and native source-document drill-down.
- Create `VSF_Finance_E2E/Configuration/Reports/SoChiTietCongNoAP.xml` and its `SoChiTietCongNoAP/Ext/Template.xml`: AP ledger SKD and drill-down.
- Create `VSF_Finance_E2E/Configuration/Reports/BaoCaoTuoiNo.xml` and its `BaoCaoTuoiNo/Ext/Template.xml`: AR/AP aging SKD.
- Modify `Configuration/Configuration.xml`, `Subsystems/PhanHePhaiThu.xml`, `Subsystems/PhanHePhaiTra.xml`, and applicable `Roles/*/Ext/Rights.xml` to register reports, navigation, and read rights.
- Modify `CommonModules/BangDieuKhienServer/Ext/Module.bsl`, `CommonTemplates/MauHTMLTrangChu/Ext/Template.txt`, and `DataProcessors/BanLamViecWebERP/Forms/FormBanLamViec/Ext/Form/Module.bsl` for consistent totals and native drill-down.
- Modify `CommonModules/SeedBoundaryTestsServer/Ext/Module.bsl`, `scripts/run_finance_e2e.ps1`, and `scripts/run_finance_ui_e2e.ps1` for report data and UI coverage.
- Create `scripts/test_finance_reporting_contract.ps1` to check report metadata, query fields, navigation, and command identifiers before Designer compilation.

---

### Task 1: Add the three native reports

**Files:**
- Create: `Configuration/Reports/SoChiTietCongNoAR.xml` and `SoChiTietCongNoAR/Ext/Template.xml`
- Create: `Configuration/Reports/SoChiTietCongNoAP.xml` and `SoChiTietCongNoAP/Ext/Template.xml`
- Create: `Configuration/Reports/BaoCaoTuoiNo.xml` and `BaoCaoTuoiNo/Ext/Template.xml`
- Modify: `Configuration/Configuration.xml`
- Test: `scripts/test_finance_reporting_contract.ps1`

**Interfaces:**
- Produces report names `Report.SoChiTietCongNoAR`, `Report.SoChiTietCongNoAP`, and `Report.BaoCaoTuoiNo` for subsystem navigation and UI tests.
- Each ledger report exposes filters `NgayBatDau`, `NgayKetThuc`, `PhapNhan`, `DoiTac`, `HopDong`, `TienTe`, and `ChungTuGoc`.
- Aging report exposes `LoaiCongNo`, `NgayChot`, `PhapNhan`, `DoiTac`, and `HopDong`; groups are the six exact spec buckets.

- [ ] **Step 1: Add failing metadata contract cases** for all three report names, filter names, required output columns, and SKD query sources in `test_finance_reporting_contract.ps1`.
- [ ] **Step 2: Run the contract script** with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\VSF_Finance_E2E\scripts\test_finance_reporting_contract.ps1 -ConfigurationPath .\VSF_Finance_E2E\Configuration`; confirm it fails because report metadata is absent.
- [ ] **Step 3: Compile the three SKD templates** from checked-in definition files using `.codex/skills/onec-xml-automation/scripts/skd-compile.ps1`; query only existing AR/AP balance and turnover registers, and preserve the source-document reference in each row.
- [ ] **Step 4: Add report metadata and configuration references** with the exact names and filters above. Ledger output must contain opening balance, period increase/decrease, closing balance, date, document number/type, description, amount, and running balance. Aging output must include the remaining balance and due/overdue day count.
- [ ] **Step 5: Run the contract script**; expected result is `PASS` for all three reports and all required SKD fields.

### Task 2: Add subsystem navigation and least-privilege read access

**Files:**
- Modify: `Subsystems/PhanHePhaiThu.xml`, `Subsystems/PhanHePhaiTra.xml`, `Roles/KeToanPhaiThu/Ext/Rights.xml`, `Roles/KeToanPhaiTra/Ext/Rights.xml`, `Roles/GiamDocTaiChinh_CFO/Ext/Rights.xml`, `Roles/QuanTriHeThong/Ext/Rights.xml`
- Test: `scripts/test_finance_reporting_contract.ps1`, `CommonModules/SeedBoundaryTestsServer/Ext/Module.bsl`

**Interfaces:**
- AR role can read AR ledger and aging; AP role can read AP ledger and aging; CFO can read all three; administrator access follows the existing system role policy.
- Subsystems expose each report in its related menu.

- [ ] **Step 1: Add failing role and subsystem assertions** for report references and read rights.
- [ ] **Step 2: Run the contract script** and confirm missing report references/rights are reported.
- [ ] **Step 3: Add the reports to AR/AP subsystem content and grant only report read rights** to the corresponding roles; do not grant write/post rights to reports or registers.
- [ ] **Step 4: Add runtime RLS cases** that query each report as AR, AP, CFO, and a different branch, checking inaccessible entities are not returned.
- [ ] **Step 5: Compile configuration and run the reporting runtime phase** on a disposable copy; expected result is zero cross-branch rows and correct allowed-role visibility.

### Task 3: Unify dashboard buckets and add native drill-down

**Files:**
- Modify: `CommonModules/BangDieuKhienServer/Ext/Module.bsl`
- Modify: `CommonTemplates/MauHTMLTrangChu/Ext/Template.txt`
- Modify: `DataProcessors/BanLamViecWebERP/Forms/FormBanLamViec/Ext/Form/Module.bsl`
- Modify: `scripts/run_finance_ui_e2e.ps1`

**Interfaces:**
- Dashboard chart click passes a report identifier plus its period/bucket and existing filters to the managed form.
- Aging chart, overdue customer row, and actionable document row open `Report.BaoCaoTuoiNo` with the exact corresponding filters.
- Refresh remains a handled dashboard action and does not navigate to an unsupported protocol.

- [ ] **Step 1: Add failing UI cases** for each aging bucket click, overdue-row drill-down, chart-period drill-down, and dashboard refresh.
- [ ] **Step 2: Run `run_finance_ui_e2e.ps1` against a disposable infobase** and confirm the new navigation assertions fail before the handlers exist.
- [ ] **Step 3: Extract the existing age bucket/date logic into one exported server routine** consumed by both dashboard and aging report, including explicit missing-term output.
- [ ] **Step 4: Register native click actions in the dashboard form** and open reports with `OpenForm` plus filter parameters; do not parse an unrestricted report name from arbitrary HTML.
- [ ] **Step 5: Add visible-data assertions** for the six chart periods, bucket totals, and source rows; expected result is that dashboard totals equal the destination report filter totals.

### Task 4: Verify the reports against postings and the general ledger

**Files:**
- Modify: `CommonModules/SeedBoundaryTestsServer/Ext/Module.bsl`
- Modify: `scripts/run_finance_e2e.ps1`, `scripts/run_finance_ui_e2e.ps1`
- Test: `scripts/test_finance_reporting_contract.ps1`

**Interfaces:**
- Add E2E phases `reporting_fixture_prepare` and `reporting_values_verify`; result JSON reports opening/turnover/closing totals and the expected/actual source document.

- [ ] **Step 1: Add failing runtime cases** for opening balance, period turnover, closing balance, AR/AP source-document drill-down, aging groups, and unposting removal.
- [ ] **Step 2: Invoke `reporting_values_verify`** with `invoke_finance_e2e_phase.ps1` on a disposable copy; confirm the new phase reports a missing/failed case.
- [ ] **Step 3: Implement the report query assertions** by reading the same register balances/turnovers and GL control-account totals for the identical entity, period, currency, and partner scope.
- [ ] **Step 4: Extend UI automation** to open each report and a source document through its link, then check the displayed totals and document reference.
- [ ] **Step 5: Run `test_finance_reporting_contract.ps1`, the targeted report UI phase, and the complete finance E2E after all subplans are merged; all report values and drill-downs must match persisted registers.**
