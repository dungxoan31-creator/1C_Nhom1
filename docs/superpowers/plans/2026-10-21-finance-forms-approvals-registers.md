# Finance Forms, Approvals, and Register Records Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` after this plan is approved. Complete each checked task in order.

**Goal:** Correct AR/AP form fields and approval choices, auto-fill AR invoices from BBNT, and expose posted register movements from every relevant document form.

**Architecture:** Keep document data and posting procedures authoritative; update managed form controls and server validation together. Reuse existing FCT attributes, workflow/security modules, and standard 1C register-record forms.

**Tech Stack:** 1C:Enterprise 8.3.22.1704, BSL, XML document/form metadata, PowerShell metadata and UI E2E.

**Spec:** `docs/superpowers/specs/2026-10-21-finance-e2e-completion-design.md`, section 3.5.

## Global Constraints

- Preserve Maker-Checker separation: the assigned approver must differ from the maker and server-side permission checks remain mandatory.
- The eligible approver list includes `ketoan_truong` and `Admin`; grant Admin only the explicit checker transition for these workflows, never a maker-checker bypass. Show CFO only when the amount requiring approval is greater than 500,000,000 VND.
- The `NguoiLap` value is assigned from `UserName()` at document creation and is read-only on the AR form.
- Keep process status (`ChoDuyetNoiBo`) separate from e-invoice status (`DaPhatHanh`).
- Bind the AP FCT checkbox to existing `CoKhauTruFCT`; it must affect existing calculations/posting, not act as a visual-only flag.
- Keep VAT selection driven by the selected BBNT and existing tax logic; do not force 10% on other documents.
- No Git repository exists in the workspace; omit commit steps.

## Review Focus

- A maker must not select themselves as approver; add runtime rejection coverage in the maker-checker task.
- CFO eligibility boundary is strict: exactly 500,000,000 VND does not show CFO; 500,000,001 VND does; test both values.
- BBNT auto-fill must use source tax values and preserve manual-invoice behavior when no BBNT is selected; test both cases.
- Posted forms must open actual recorded movements, and unposted forms must show no movements; test one of each.
- FCT checkbox must persist and post expected multi-account rows for the 250,000,000 VND invoice; test register contents, not only checkbox state.

## Files and responsibilities

- Modify `Documents/HoaDonGTGTDauRa.xml`, `Documents/HoaDonGTGTDauRa/Ext/ObjectModule.bsl`, `Documents/HoaDonGTGTDauRa/Forms/FormChungTu/Ext/Form.xml`, and its `Form/Module.bsl` for workflow status, creator, approver, invoice status placement, and BBNT auto-fill.
- Modify `Documents/HoaDonNhaCungCap/Forms/FormChungTu/Ext/Form.xml` and its `Form/Module.bsl` to expose existing `CoKhauTruFCT` and `NguoiDuyet` fields in the correct tabs.
- Modify `CommonModules/PheDuyetDaCapServer/Ext/Module.bsl` and `CommonModules/PhanQuyenBaoMatServer/Ext/Module.bsl` only where needed for eligible approver selection and validation.
- Modify the object forms for the six existing posted documents (`BienBanNghiemThuGiaiDoan`, `HoaDonGTGTDauRa`, `HoaDonNhaCungCap`, `PhieuThuTienKhachHang`, `UyNhiemChi`, and `CanTruCongNoNoiBo`) to expose the standard `RegisterRecords` command in **Khác**. The CSV plan creates the reconciliation form and adds its command.
- Modify `CommonModules/SeedBoundaryTestsServer/Ext/Module.bsl`, `scripts/run_finance_e2e.ps1`, and `scripts/run_finance_ui_e2e.ps1` for approval, auto-fill, FCT, and register-record UI coverage.
- Create `scripts/test_finance_document_forms_contract.ps1` for form-field placement, binding, and register-command metadata checks.

---

### Task 1: Put AR workflow and invoice fields on Tab 4

**Files:**
- Modify: `Documents/HoaDonGTGTDauRa.xml`
- Modify: `Documents/HoaDonGTGTDauRa/Ext/ObjectModule.bsl`
- Modify: `Documents/HoaDonGTGTDauRa/Forms/FormChungTu/Ext/Form.xml`
- Modify: `Documents/HoaDonGTGTDauRa/Forms/FormChungTu/Ext/Form/Module.bsl`
- Test: `scripts/test_finance_document_forms_contract.ps1`

**Interfaces:**
- Tab 4 fields: `NguoiLap` (read-only), `NguoiDuyet`, workflow `TrangThai` (`EnumRef.TrangThaiNghiemThuAR`), `TrangThaiHDDT`, and `DienGiai`.
- Tab 3 retains tax amounts and e-invoice identifiers; it no longer contains `TrangThaiHDDT` or the approver field.

- [ ] **Step 1: Add failing form-contract assertions** for Tab 4 field bindings, Tab 3 removals, creator read-only, and status enum choices.
- [ ] **Step 2: Run the form-contract script** with `-ConfigurationPath .\VSF_Finance_E2E\Configuration`; confirm it reports the current tab placement and missing workflow attribute.
- [ ] **Step 3: Add the AR workflow attribute using the existing `TrangThaiNghiemThuAR` enum**, default it to the valid initial state, and validate status transitions in `HoaDonGTGTDauRa` server writes.
- [ ] **Step 4: Move `TrangThaiHDDT` and `NguoiDuyet` to Tab 4; add `NguoiLap` bound to the existing creator property and set its form control `ReadOnly` to true.** Keep `DienGiai` on Tab 4.
- [ ] **Step 5: Run form contract and runtime state tests**; expected result is all fields appear once on the required tab, `NguoiLap=ketoan_ar` after creation, and unauthorized or invalid state transitions are rejected.

### Task 2: Provide eligible approver choices with server validation

**Files:**
- Modify: AR form/module and `Documents/HoaDonGTGTDauRa/Ext/ObjectModule.bsl`
- Modify: `Documents/HoaDonNhaCungCap/Forms/FormChungTu/Ext/Form.xml` and its `Form/Module.bsl`
- Modify: `CommonModules/PheDuyetDaCapServer/Ext/Module.bsl`, `CommonModules/PhanQuyenBaoMatServer/Ext/Module.bsl`
- Test: `CommonModules/SeedBoundaryTestsServer/Ext/Module.bsl`

**Interfaces:**
- Add `Function LayDanhSachNguoiDuyet(Val LoaiChungTu, Val SoTien) Export` returning an `Array` of eligible usernames.
- Add server validation `Procedure KiemTraNguoiDuyetHopLe(Val ChungTu, Val NguoiThucHien)`; it rejects a missing/ineligible approver, same maker/approver, or an actor lacking approval/post permission.

- [ ] **Step 1: Add failing runtime cases** for the KTT, Admin, CFO boundary, maker-self-approval, missing approver, and unauthorized actor.
- [ ] **Step 2: Run the approval phase** through `invoke_finance_e2e_phase.ps1`; confirm each new case fails against the current implementation.
- [ ] **Step 3: Implement `LayDanhSachNguoiDuyet`** from the existing user/role policy and configured CFO threshold; include `ketoan_truong` and `Admin`, and add CFO only for amounts greater than 500,000,000 VND.
- [ ] **Step 4: Bind both form selectors to that list** and call `KiemTraNguoiDuyetHopLe` from the server-side approval path; grant Admin only the required checker transition, retain posting permissions as currently defined, and keep maker-checker enforcement.
- [ ] **Step 5: Run boundary tests at 500,000,000 and 500,000,001 VND** plus self-approval/unauthorized cases; expected result is correct choices and rejected invalid approvals.

### Task 3: Add AP FCT checkbox to Tab 1

**Files:**
- Modify: `Documents/HoaDonNhaCungCap/Forms/FormChungTu/Ext/Form.xml`
- Modify: `Documents/HoaDonNhaCungCap/Forms/FormChungTu/Ext/Form/Module.bsl`
- Test: form contract script and AP E2E register phase

**Interfaces:**
- Checkbox data path is the existing `Object.CoKhauTruFCT` and appears on Tab 1 immediately after `Object.TienDichVu`.
- Tab 3 retains `Object.TrangThai` and adds `Object.NguoiDuyet`.

- [ ] **Step 1: Add failing assertions** for the checkbox binding/order and AP approver placement.
- [ ] **Step 2: Run `test_finance_document_forms_contract.ps1`** and confirm it reports the absent controls.
- [ ] **Step 3: Add a checkbox bound to `Object.CoKhauTruFCT` after `TienDichVu`; add `NguoiDuyet` to Tab 3 and bind its choice list to `LayDanhSachNguoiDuyet`.**
- [ ] **Step 4: Run the 250,000,000 VND FCT fixture** and assert checkbox persistence plus every existing FCT GL/AP register line against the established fixture totals.
- [ ] **Step 5: Open the AP invoice in native UI E2E**; expected result is the checkbox, assigned approver, and multi-account posting data are visible.

### Task 4: Auto-fill AR invoice from selected BBNT

**Files:**
- Modify: `Documents/HoaDonGTGTDauRa/Forms/FormChungTu/Ext/Form.xml`
- Modify: `Documents/HoaDonGTGTDauRa/Forms/FormChungTu/Ext/Form/Module.bsl`
- Test: `CommonModules/SeedBoundaryTestsServer/Ext/Module.bsl`, `scripts/run_finance_ui_e2e.ps1`

**Interfaces:**
- Add client event `BienBanNghiemThuOnChange(Item)` and server routine `CapNhatTheoBienBanNghiemThu()`.
- Selecting a BBNT copies its `PhapNhan`, `DoiTac`, `HopDong`, `GiaTriNghiemThuChuaVAT`, tax rate and tax amount; recompute `TongTienThanhToan` through existing VAT calculation rules.

- [ ] **Step 1: Add failing runtime/UI cases** for BBNT selection, the demo values, and selecting a different VAT-rate BBNT.
- [ ] **Step 2: Run the BBNT auto-fill test** and confirm the current form leaves the selected source values unsynchronized.
- [ ] **Step 3: Attach `BienBanNghiemThuOnChange` to the source field** and implement the copy/recalculation routine using the selected document’s saved values and existing tax service.
- [ ] **Step 4: Verify demo fixture values** `200,000,000`, `10%`, `20,000,000`, and `220,000,000 VND`; verify a different VAT-rate source preserves its own rate.
- [ ] **Step 5: Verify manual AR invoice behavior** remains unchanged when `BienBanNghiemThu` is empty.

### Task 5: Expose Document Register Records in More on existing posted documents

**Files:**
- Modify the object forms for `BienBanNghiemThuGiaiDoan`, `HoaDonGTGTDauRa`, `HoaDonNhaCungCap`, `PhieuThuTienKhachHang`, `UyNhiemChi`, and `CanTruCongNoNoiBo`.
- Modify: `scripts/run_finance_ui_e2e.ps1`, `scripts/test_finance_document_forms_contract.ps1`

**Interfaces:**
- Standard **Khác → Chuyển động của chứng từ theo sổ** opens the current document’s native register-records view. The CSV plan adds the same command to the new reconciliation form.
- BBNT tabs include `SoCaiKeToan` and `CongNoPhaiThu`; AP invoice tabs include `SoCaiKeToan` and `CongNoPhaiTra`; other documents show the registers declared in their `RegisterRecords` metadata.

- [ ] **Step 1: Add failing metadata/UI cases** for the standard More command on these six documents and the expected register tab sets.
- [ ] **Step 2: Run the form-contract test** and confirm it identifies missing command exposure.
- [ ] **Step 3: Enable the platform `RegisterRecords` standard command on each posted document object form** without adding a custom URL/action; preserve existing standard command bar behavior.
- [ ] **Step 4: Run native UI E2E** on posted BBNT and AP invoice fixtures; open **Khác → Chuyển động của chứng từ theo sổ** and assert the two expected tabs and the 250,000,000 VND AP fixture rows.
- [ ] **Step 5: Smoke all six existing posted documents** and verify their registered movements appear on the same native screen; an unposted fixture must show no movements.

### Task 6: Run integrated form E2E

**Files:**
- Modify: `scripts/run_finance_e2e.ps1`, `scripts/run_finance_ui_e2e.ps1`
- Modify: `CommonModules/SeedBoundaryTestsServer/Ext/Module.bsl`

- [ ] **Step 1: Add `ar_approver_form`, `ar_bbnt_autofill`, `ap_fct_form`, and `document_register_records_ui` cases** to the runner summary.
- [ ] **Step 2: Compile the configuration on a disposable infobase** with `scripts/compile_infobase_config.ps1`.
- [ ] **Step 3: Run targeted native UI and runtime phases**; expected result is PASS for all form, permission, FCT, and source-register assertions.
- [ ] **Step 4: Run the full finance E2E after the CSV/report plans are merged** and confirm existing AR/AP security and posting regressions still pass.

