# Finance Process Guides and Demo Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` after this plan is approved. Complete each checked task in order.

**Goal:** Add in-application workflow explanations and finish the manual demo and team assessment checklist.

**Architecture:** Add a small managed 1C guide page using a static common HTML template and native form links; keep the detailed operator script and team checklist under `docs`.

**Tech Stack:** 1C:Enterprise managed forms, common HTML template, BSL link routing, Markdown.

**Spec:** `docs/superpowers/specs/2026-10-21-finance-e2e-completion-design.md`, section 3.4 and the register-record path in section 3.5.

## Global Constraints

- Explain the existing accounting configuration; do not invent statutory tax or account policy.
- Show AR, AP, netting, and CSV reconciliation roles, documents, transitions, and register effects.
- Label 10% VAT as the demo fixture; keep the existing 8% test cases identified separately.
- Never include passwords, personal evaluation answers, or real bank files in source/docs.
- Document the path **Khác → Chuyển động của chứng từ theo sổ** and the register tabs visible for BBNT and AP invoice.
- No Git repository exists; omit commit steps.

## Review Focus

- Demo totals and test fixtures can diverge; run a static number cross-check for every demo amount.
- A draft e-invoice is not an issued invoice; clearly distinguish actual external issuance from the E2E simulated fixture.
- Register-record navigation must name the form/menu and exact tabs; validate against the UI E2E artifacts from the forms plan.
- Flow explanations can become stale when posting code changes; cross-check each documented module/method and account against source.
- Checklist answers may contain sensitive personal information; provide blank reusable prompts only and validate no filled answers are present.

## Files and responsibilities

- Create `Configuration/CommonTemplates/MauHTMLHuongDanQuyTrinhTaiChinh.xml` and `.../Ext/Template.txt` for the app guide page.
- Create `Configuration/DataProcessors/HuongDanQuyTrinhTaiChinh.xml`, its object/module/form metadata, and a managed HTML form with native route handlers.
- Modify `Configuration/Configuration.xml`, `Subsystems/PhanHeSoCaiVaDongBo.xml`, related finance subsystem content, and role rights for navigation.
- Modify `Configuration/CommonTemplates/MauHTMLTrangChu/Ext/Template.txt` and `DataProcessors/BanLamViecWebERP/Forms/FormBanLamViec/Ext/Form/Module.bsl` to link to the guide through a whitelisted `OpenForm` route.
- Modify `docs/Kich_ban_demo_VinSmart_Future.md` and create `docs/Checklist_danh_gia_thanh_vien.md`.
- Create `scripts/test_finance_guide_contract.ps1` for section, totals, source-reference, and sensitive-data checks.

---

### Task 1: Add the app-accessible process guide

**Files:**
- Create: guide DataProcessor, form metadata/module, and common HTML template listed above
- Modify: configuration, subsystems, role rights, dashboard HTML/form module
- Test: `scripts/test_finance_guide_contract.ps1`

**Interfaces:**
- Dashboard menu action opens `DataProcessor.HuongDanQuyTrinhTaiChinh.ObjectForm` through an explicit native 1C handler.
- Guide pages/anchors: `AR`, `AP`, `CanTru`, `DoiSoatCSV`, `TaiKhoanVaChuyenDongSo`.

- [ ] **Step 1: Add failing contract cases** for each required guide page, actor/transition/account sections, and allowed form-link targets.
- [ ] **Step 2: Run the guide contract script** with `-ConfigurationPath .\VSF_Finance_E2E\Configuration`; confirm the page and content are absent.
- [ ] **Step 3: Add the common template and managed guide form** with responsive Vietnamese content and only explicit link IDs.
- [ ] **Step 4: Add an allowlisted native click router** that opens only AR/AP documents, netting, reconciliation, ledger reports, and aging reports.
- [ ] **Step 5: Compile and open the guide in native UI E2E**; expected result is all five anchors present and each command opens its intended form/report.

### Task 2: Complete the operator demo guide

**Files:**
- Modify: `docs/Kich_ban_demo_VinSmart_Future.md`
- Test: `scripts/test_finance_guide_contract.ps1`

- [ ] **Step 1: Add failing documentation checks** for AR receipt, AP approval/payment, netting, CSV import, reports, and register-record navigation.
- [ ] **Step 2: Extend the guide** from AR draft through a valid issued/demo invoice, customer receipt, AR ledger, AP invoice/approval/payment/AP ledger, netting residual/close, CSV match, dashboard and aging report.
- [ ] **Step 3: Use the demo amounts from the spec** (AR 200m + 20m VAT = 220m; AP 100m + 10m VAT = 110m) and mark fixture-only/sandbox steps explicitly.
- [ ] **Step 4: Add the register-record location** for BBNT (`SoCaiKeToan`, `CongNoPhaiThu`) and AP invoice (`SoCaiKeToan`, `CongNoPhaiTra`) under **Khác** in the source document form.
- [ ] **Step 5: Run the guide contract and amount cross-check**; expected result is no contradictory tax totals, missing flow step, or unsupported menu claim.

### Task 3: Add a blank group interview/evaluation checklist

**Files:**
- Create: `docs/Checklist_danh_gia_thanh_vien.md`
- Test: `scripts/test_finance_guide_contract.ps1`

- [ ] **Step 1: Add failing checks** for the required team topics and for absence of populated personal answers.
- [ ] **Step 2: Create a reusable blank checklist** for each member: explain AR/AP/netting/reconciliation, identify documents and accounts, show Maker-Checker and register records, explain one rejection/rollback, and answer a short role-specific question.
- [ ] **Step 3: Include a neutral scoring rubric** with evidence observed and follow-up fields; leave names/answers blank.
- [ ] **Step 4: Run the checklist contract**; expected result is all topics present and no credential or personal response data.

### Task 4: Integrate guide E2E evidence

**Files:**
- Modify: `scripts/run_finance_e2e.ps1`, `scripts/run_finance_ui_e2e.ps1`

- [ ] **Step 1: Add a `finance_guide_ui` case** that opens the guide and each required section.
- [ ] **Step 2: Assert native links reach AR/AP/netting/reconciliation and report forms** without protocol errors.
- [ ] **Step 3: Run the guide UI phase and full E2E after feature plans are merged**; expected result is `finance_guide_ui.status=PASS` in the new `summary.json`.
