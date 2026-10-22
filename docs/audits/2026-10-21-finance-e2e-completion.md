# Finance AR/AP Completion and DT Handoff Audit

**Audit finalized:** 2026-10-22  
**Result:** Complete; canonical DT replaced and verified.

## Handoff files

- Canonical DT: `VinSmart_Future_AdminFull_v5_SuaFont.dt`
- Candidate used for handoff: `VSF_Finance_E2E/dt_working/finance_complete_20261021/candidate-branch-default-final-20261022.dt`
- Exact backup of the pre-replacement canonical DT: `VSF_Finance_E2E/archive/VinSmart_Future_AdminFull_v5_SuaFont_before_branch_default_fix_20261022.dt`

| File | Bytes | SHA-256 |
|---|---:|---|
| Pre-replacement canonical DT and retained backup | 1,195,766 | `799C4EA4F8ED41CEB8D0E80CC2005F30B88193C7EC72DB5566632E27443CB026` |
| Candidate DT and installed canonical DT | 1,195,864 | `327BA9C1A02CB4956C5BD1C54B11F19D432FAB8BE318C5780F63D2F806A93086` |

The candidate was copied to a same-volume staging file and installed with `System.IO.File.Replace`. The new canonical hash and byte count match the candidate. The retained archive backup matches the old canonical hash and byte count. No 1C process was running during replacement.

## Build and configuration evidence

- Runtime: 1C:Enterprise/Designer `8.3.22.1704`.
- Build infobase configuration update log: `VSF_Finance_E2E/dt_working/finance_complete_20261021/branch-default-final-build-update.log`; it contains `Configuration successfully updated`.
- The candidate was restored into `candidate-restored-branch-default-final` and exported to `candidate-config-restored-branch-default-final-20261022`.
- Full E2E used that exported configuration on the clean `VSF_Finance_E2E/BaseInfobase` so the candidate's existing data fixtures did not collide with suite seeding.
- The source/candidate export comparison is recorded in `candidate-config-source-compare-branch-default-final-20261022.json` (200 files each). Raw exports include serializer, encoding, and line-ending differences; normalized comparison confirmed all 50 BSL modules match. The test configuration itself is the export from the restored candidate.
- `cf-validate` and `form-validate` reported zero errors. They emitted a format-coverage warning because this project's configuration format is `2.15`, below the validator's verified range `2.17–2.21`.

## Finance changes in the candidate

The branch-scoped default legal-entity lookup is implemented in `CommonModules/QuanLyVongDoiChungTuServer/Ext/Module.bsl`. It selects an active legal entity visible to the current branch under normal RLS; it does not bypass access checks. The seven finance document object modules use this helper instead of assuming `PN-VSF` is visible:

- `BienBanNghiemThuGiaiDoan`
- `HoaDonGTGTDauRa`
- `HoaDonNhaCungCap`
- `PhieuThuTienKhachHang`
- `UyNhiemChi`
- `CanTruCongNoNoiBo`
- `DoiSoatKenhThanhToan`

The regression coverage for AR/AP approvals, form behavior, document register records, required fields, branch RLS, FCT posting, reconciliation, reports, and process guide is in `VSF_Finance_E2E/scripts/run_finance_e2e.ps1` and its result artifacts.

## Final verification

Run: `finance-e2e-20261022-085513-4a2cf2d295224da69299212f3cdec636`  
Summary: `VSF_Finance_E2E/results/finance-e2e-20261022-085513-4a2cf2d295224da69299212f3cdec636/summary.json`  
Configuration tested: `VSF_Finance_E2E/dt_working/finance_complete_20261021/candidate-config-restored-branch-default-final-20261022`

**E2E result: PASS, 108/108 phases, 0 failed.** Highlights:

- Native UI form smoke: 16/16 screens; document register records opened for the posting documents.
- Runtime document tabs: 20/20 primary pages; metadata inventory: 127 attributes with all 48 `ShowError` fields accounted for.
- AR autofill: BBNT, partner, contract and amounts populated as 200,000,000 VND + 10% VAT = 220,000,000 VND.
- AP FCT form: checkbox persisted; register viewer showed three GL rows and AP rows for the 250,000,000 VND invoice / 225,000,000 VND payment scenario.
- Required-field UI: 7/7 document forms reject blank submissions without assigning a document number.
- Partner/contract selection filters: 5/5 forms.
- AR/AP detail ledgers and aging report: 3/3 report grids generated and visible.
- Finance process guide opened, and its AR link opened the native acceptance form.
- Branch-scoped blank-form checks passed for `ketoan_ar` and `ketoan_ap` in the second branch.

Related artifacts include `ui-document-forms.json`, `ui-ap-fct250-smoke.json`, `ui-required-field-validation.json`, `ui-reference-choice.json`, `ui-report-smoke.json`, `ui-finance-guide.json`, `ui-branch-create-ketoan_ar-Acceptance.json`, and `ui-branch-create-ketoan_ap-APInvoice.json` in the run directory.

## Data boundary and repository note

The candidate DT's stored data was preserved unchanged. Because its existing fixture balances conflict with clean-suite setup and it lacks one E2E netting fixture, the complete 108-phase suite ran against the exact configuration exported from the restored candidate on a clean E2E base. Direct form smoke was also performed on the restored candidate. This verifies the packaged configuration end to end; it does not claim that the candidate's preloaded business data is itself a clean demo dataset.

This workspace has no `.git` directory. The audited file hashes, run summary, and dated backup are the handoff record; no Git commit or branch review range exists.