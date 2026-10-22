# 1C Configuration Audit and Final Verification — 2026-10-20

This report supersedes the earlier baseline figures and stale pre-fix test status in `2026-10-20-1c-functional-inventory.md`. A PASS below applies only to a scenario that actually ran on 1C 8.3.22.1704 and whose result was asserted; it does not imply that unimplemented or untested capabilities pass.

## 1. Configuration and source inventory

| Area | Current finding |
|---|---|
| Platform | 1C:Enterprise 8.3.22.1704; compatibility `Version8_3_22`; managed application; Taxi interface; managed locks; modality disabled |
| Storage | File mode (`1Cv8.1CD`). The E2E runner works on disposable copies. |
| Extensions / libraries | No CFE source or attached extension was found in the inspected workspace/base. No SSL/BSP or 1C:Jet source was found. |
| Source files | 118 XML files; 34 BSL files; 11,663 BSL lines; 12 managed `Form.xml` files |
| Metadata | 77 top-level objects: 6 subsystems, 8 catalogs, 7 documents, 3 accumulation registers, 1 accounting register, 1 information register, 1 chart of accounts, 1 data processor, 11 common modules, 5 roles, 6 enums, 3 constants, 2 languages, 1 common form, 1 common template, 6 common pictures, and 14 style items |
| Entry points | 12 managed forms and startup module. 0 HTTP services, 0 SOAP/Web services, 0 scheduled jobs, 0 exchange plans, 0 reports, and 0 event subscriptions. OData runtime exposure was not independently confirmed. |
| Business objects | Seven finance documents post to AR/AP/cash and the general ledger. No document manager modules are present. |

## 2. Functional inventory

| ID | Capability / flow | Entry point and output | Runtime status / remaining scope |
|---|---|---|---|
| C01 / F01 | Master data, chart, users, test setup | `GeneratorMasterDataServer`, `UserProvisioningServer`; catalogs, accounts, currencies, users | Core E2E setup PASS. Import/migration from production sources is absent. |
| C02 / F02 | Acceptance and AR recognition | `BienBanNghiemThuGiaiDoan`; AR and GL | Submit, approve, post, rollback and repost checks PASS. |
| C03 / F02 | Outgoing VAT invoice | `HoaDonGTGTDauRa`; AR and GL | Source-acceptance dependency, posting, VAT boundary and state checks PASS. |
| C04 / F02 | Customer receipt and cash | `PhieuThuTienKhachHang`; AR, cash and GL | Receipt and over-collection rejection PASS; FX receipt, refund and correction paths remain untested. |
| C05 / F03 | Vendor invoice and payable | `HoaDonNhaCungCap`; AP and GL | VND E2E plus 1,260-invoice seed regression PASS; vendor-tax and FX cases are incomplete. |
| C06 / F03 | Supplier payment and bank balance | `UyNhiemChi`; AP, cash and GL | VND payment and insufficient-cash guard exercised. Cash-balance lookup is now a single grouped query after managed locks. FX payment, bank-fee and reversal cases remain untested. |
| C07 / F04 | Maker-checker / approval | `PhanQuyenBaoMatServer`, `QuyTrinhPheDuyetAPServer` | Tested users and stages PASS for the E2E path. Ten role assertions per each of five real 1C sessions PASS. Full platform RLS is unverified. |
| C08 / F06 | Unpost, rollback, repost, reconciliation | `QuanLyVongDoiChungTuServer`; register records | Runtime lifecycle 4/4 PASS; posting invariants 5/5 PASS; GL/subledger delta is zero. |
| C09 / F05 | Dashboard and financial KPIs | `BangDieuKhienServer`, workspace forms | Source exists; no UI-driven value, empty-period or role-filter E2E was run. |
| C10 / F05 | Batch approval | Workspace / manager modules | Queue approval stages and draft rejection PASS through 1C command automation; UI interaction is unverified. |
| C11 | Four-tier approval, anti-split, CFO budget unlock | `PheDuyetDaCapServer` | Exported logic exists but no production caller, budget register or corresponding roles were found; not a complete active flow. |
| C12 | Deterministic seed and regression harness | AR/AP generators and `SeedBoundaryTestsServer` | AR and AP aggregate regressions PASS. |
| C13 / F07 | Internal AR/AP netting | `CanTruCongNoNoiBo`; `PhanHeCanTruCongNo` | VND bilateral netting: same entity/partner, 40m AR vs 40m AP; Dr 3312 / Cr 1312, AR/AP Expense movements, no cash movement. E2E verifies the 43.2m invoiced AR, 40m offset, 3.2m residual receipt, unpost/repost and atomic over-limit rejection. PASS. Multilateral/FX netting remains unimplemented. |
| C14 / F08 | Payment-channel settlement reconciliation | `DoiSoatKenhThanhToan`; `PhanHeNganHangVaQuy` | Deterministic VNPAY settlement: gross 75m = net 73.875m + fee 1.125m; Dr 1121/6427, Cr 1388, bank Receipt for net only. E2E verifies movement amounts, unpost/repost and one-VND mismatch rejection. PASS. Live bank/gateway connectivity and statement-level duplicate detection are not implemented. |

There are 14 catalogued capability groups and 8 catalogued business flows. All 14 have at least partial source implementation; this does not mean every branch, integration or user-interface path is complete or production-ready.

## 3. Test matrix and execution evidence

Final candidate DT execution on 1C 8.3.22.1704: run finance-e2e-20261020-122633-0f2a246548464cc68dc73b7ed2b79072, exit code 0, 51/51 runner phases PASS, no failed or blocked phase. Artifacts: VSF_Finance_E2E/results/finance-e2e-20261020-122633-0f2a246548464cc68dc73b7ed2b79072/summary.json.

| Runtime group | Result |
|---|---:|
| Runner execution phases | 51/51 PASS; process exit code 0 |
| Security role matrices | 5 users x 10 assertions = 50/50 PASS; 0 skipped |
| Document lifecycle | 4/4 PASS: no residual after unpost, movement parity after repost, transaction rollback, GL/subledger reconciliation |
| GL/subledger integrity | 3/3 PASS using actual accounting-register records, injected 1 VND mismatch detected and rolled back |
| AP invoice lifecycle | 3/3 PASS |
| Posting-state invariants | 5/5 PASS |
| Existing boundary/security cases | 3/3 PASS |
| Managed-lock concurrency | PASS; real 1C worker sessions, deterministic lock serialization and over-collection rejection |
| AR seed aggregate regression | PASS: 1,260 acceptances, 1,260 invoices, 1,162 receipts |
| AP seed aggregate regression | PASS: 1,260 invoices, including 315 USD invoices |
| Dashboard | PASS; recognized revenue 491,234,567 VND equals net GL 5113; receipts 216,000,000 VND; 6 chart periods and 5 aging buckets |

Runner phases include workflow, role and seed operations; nested case counts are reported separately and should not be added as independent runner phases. Generated documents are data volume, not individual test cases. A unified before/after test-case manifest does not exist, so the historical total test-case count is UNKNOWN.

The executed tests cover the implemented paths above. Remaining unverified or absent paths include invalid datatype and missing-required-field matrices for every document; broad duplicate/reference/deletion-mark cases; branch/company RLS; FX and multilateral netting; refunds and reversals; live bank, gateway and e-invoice connectivity; dashboard UI automation; inventory costing, fixed assets and statutory financial statements. These are not reported as PASS.

## 4. Fixes applied and root causes

| Finding | Root cause | Change and verification |
|---|---|---|
| 8% VAT policy could be applied without an explicit eligibility basis or effective-date check | Existing rate field did not encode eligibility and the temporary reduction period | Added shared date/eligibility calculation, explicit eligibility attributes on acceptance and invoice, source-acceptance rate transfer and validation. Six VAT boundary cases and source-to-invoice tax parity passed. |
| Cash-balance guard queried separately for each account/currency key | Query sat inside a cash-key loop on the payment posting path | Cash keys are locked in deterministic order; one grouped balance query retrieves all account/currency totals, then checks payment plus fee. VND payment and concurrent DataLock E2E passed. |
| Rejected document states could leave Posted=True without movements in identified paths | Posting handlers returned without reliably canceling the write | Posting-state invariants verify persisted state and movement absence. 5/5 runtime checks passed. |
| Batch approval could report success after a posting attempt was rejected | Result was based on absence of an exception instead of persisted state | Approval code now verifies persisted status and posted outcome. Approval stages and draft rejection passed. |
| GL/subledger negative coverage was synthetic and uncalled | Legacy helpers used hard-coded tables and arithmetic instead of persisted register data | Replaced with a real accounting-register mutation inside a transaction; production reconciliation detected aggregate and recorder mismatch, and rollback restored the baseline. 3/3 passed. |
| AR contract lookup repeated in generated-document processing | Per-partner contract lookups were in the generation path | Contracts are prefetched once and mapped by partner/code. AR seed regression verified 1,260 invoices and 1,162 receipts. |
| Netting used gross AR before VAT invoice issuance | Acceptance posting recognizes pre-VAT AR; invoice transfers acceptance balance and creates gross invoice AR | Added invoice maker/checker steps and netting against the issued invoice. E2E verifies 40m offset, 3.2m residual and final collection. |
| Netting lifecycle did not reverse the downstream netting document | Lifecycle dependency list omitted the newly added netting document | Lifecycle now reverses receipt, netting, invoice and acceptance in dependency order and reposts in reverse order. 4/4 passed. |
| CFO approval test assumed a fixed bank closing balance | Prior E2E receipt and settlement correctly changed opening cash | Assertion now verifies the phase bank delta equals its own posted payment while retaining AP and movement assertions. |
| Admin role test expected bypass of a KTT/CFO restriction | Test expectation contradicted the configured finance-control policy | Corrected the expected denial without weakening production restrictions. Five session matrices passed 10/10 each. |
| Dashboard revenue used invoice gross/issued-invoice totals rather than recognized net revenue | Acceptance posting recognizes net revenue on GL 5113; invoicing transfers AR/VAT and does not recognize revenue again | KPI and chart now use net 5113 movement. Independent acceptance/direct-invoice source totals reconcile to GL. Dashboard test passed with 491,234,567 VND. |
| Current-month dashboard chart included future-dated receipts | Month end was used after the report timestamp | Current month is capped at report time; historical months end at month end. Dashboard receipts reconcile to 216,000,000 VND. |
| Dashboard ran two database queries per chart month | Both monthly queries were inside a six-period loop | Replaced with two grouped batch queries outside the loop. Dashboard and full E2E passed. |
| Lifecycle verification queried every register for each document | Register snapshots and GL counts were fetched one document at a time | Four recorder-filtered batch queries now load all lifecycle rows; memory comparisons retain exact register-row parity and rollback assertions. Exported LayDauVanMovements remains as a compatible wrapper. Posting lifecycle and AP lifecycle passed. |
| First lifecycle batch refactor removed an exported helper still called by AP tests | Shared helper API had an external caller in SeedBoundaryTestsServer | The runtime surfaced “Object method not found (LayDauVanMovements)”; restored the exported compatibility wrapper and CountOnly output. The clean rerun passed 51/51, including AP lifecycle 3/3. |

Primary modified areas include finance document metadata/object modules, dashboard, VAT, AR/AP, cash and netting common modules, SeedBoundaryTestsServer, QuanLyVongDoiChungTuServer, and scripts/run_finance_e2e.ps1. No test was disabled or skipped, and assertions were not weakened.

## 5. Static and configuration validation

- Designer LoadConfigFromFiles plus /UpdateDBCfg succeeded on the staging infobase and in every E2E runner invocation.
- cf-validate: 0 errors and 1 warning. The warning is source format 2.15 below the validator's tested range 2.17–2.21; this export corresponds to platform 8.3.22. The format number was not manually changed.
- meta-validate for both added documents: 0 errors each, 1 format-version warning each. PowerShell parser checks passed.
- Static scan covered all 34 BSL files. No Query.Execute call remains in a loop body; recurring lifecycle snapshots now use batch queries. Contract generation executes one prefetched query as the For Each source, not once inside its body.
- No TODO/FIXME markers or empty Except blocks were found in the scanned configuration source.
- The final DT was restored through the Skill db-create script and run through full E2E. Designer DumpConfigToFiles round-trip found 34 source and 34 dumped BSL files, with no missing, extra or differing normalized BSL file.
- No standalone BSL Language Server or OneScript CLI was installed; compilation was verified with Designer /UpdateDBCfg and actual 1C runtime execution.

A transient regression failure occurred during the lifecycle query batching change because an exported helper was removed while an AP test still called it. The failure was diagnosed from the runtime JSON, the API wrapper was restored, and the complete clean-base E2E rerun then passed.

## 6. Accounting, tax and access limits

- The E2E verifies VND balance paths, subledger movements, general-ledger debit/credit balance, transaction rollback and residual balance. It does not certify a complete Vietnamese statutory chart, all tax treatments, all foreign-exchange revaluation, inventory costing, fixed assets or financial statements; those domains are not implemented in this configuration.
- **Legal-framework correction:** an earlier draft of this report described TT 200/2014/TT-BTC as the current general corporate accounting regime. That statement is not valid for fiscal years starting on or after 2026-01-01. TT 99/2025/TT-BTC took effect on 2026-01-01 and replaces TT 200 for those fiscal years, except for the stated state-owned-enterprise equitization content. A non-calendar fiscal year beginning before 2026-01-01 moves to TT 99 only in its next fiscal year beginning on or after that date. The configuration's target legal entity, fiscal-year start and applicable accounting regime are not represented in the tested fixture, and the chart/account mappings have not been audited against TT 99. Therefore the accounting E2E is a PASS for the tested internal posting invariants only; statutory compliance is UNKNOWN / NEED BUSINESS CONFIRMATION, not PASS. [Ministry of Finance notice on TT 99](https://www.mof.gov.vn/tin-tuc-tai-chinh/tin-chinh-sach-tai-chinh/tap-huan-trien-khai-thong-tu-so-992025tt-btc), [Ministry of Finance clarification on non-calendar fiscal years](https://portal.mof.gov.vn/hoidapcstc/home/cthoidap/159102).
- For SMEs, TT 133/2016/TT-BTC appears in the legal database as partially effective and amended by TT 46/2025/TT-BTC. As of this report date, the Ministry of Finance had published consultation materials for a draft replacement; a draft is not treated as enacted law here. The system does not record whether the target entity qualifies for or has selected the SME regime. Confirm entity classification and selected regime, then complete a chart, posting, and financial-statement mapping review against the applicable effective text. [National legal database: TT 133 and its amendment relationship](https://vbpl.vn/vinhlong/Pages/vbpq-luocdo.aspx?ItemID=113560), [Ministry of Finance: SME accounting circular draft consultation record](https://www.mof.gov.vn/bo-tai-chinh/dong-gop-y-kien-du-thao-van-ban/bang-tong-hop-giai-trinh-y-kien-tham-gia-doi-voi-du-thao-thong-tu-huong-dan-che-do-ke-toan-doanh-nghiep-nho-va-vua).
- The test fixture explicitly marks its sample IT service eligible for the temporary 8% VAT rate. Production eligibility must be set from the actual goods/service classification; do not infer it from a service name. Resolution 204/2025/QH15 and Decree 174/2025/ND-CP establish the temporary reduction window from 2025-07-01 through 2026-12-31 for eligible categories, subject to exclusions. [Resolution 204/2025/QH15](https://vanban.chinhphu.vn/default.aspx?docid=214209&pageid=27160), [Decree 174/2025/ND-CP](https://chinhphu.vn/?docid=214310&pageid=27160), [Government summary of scope and exclusions](https://baochinhphu.vn/giam-thue-gia-tri-gia-tang-tu-01-7-2025-den-het-31-12-2026-10225070118590677.htm).
- NEED BUSINESS CONFIRMATION: target legal entity classification and selected accounting regime/fiscal-year start; production eligibility mapping for temporary VAT relief; legal-entity/counterparty model and accounting treatment for intercompany netting; bank-statement and gateway fee source data. These are absent from current source/fixtures, so no statutory accounting rule was invented for them.
- Five application roles exist. Effective 1C platform grants and RLS are not proven by the current runtime tests; the tested app-level workflow does not establish branch-level record security.
## 7. Final DT handoff

- The original VinSmart_Future_AdminFull_v5_SuaFont.dt now contains the verified candidate. Size: 540,331 bytes; SHA256: 0983BA13BCBB0CC668BAFF1DDE2CFBA9D997200D064195BC1771E094974F4B95.
- Atomic replacement preserved the immediately pre-change DT at VinSmart_Future_AdminFull_v5_SuaFont_pre_batch_query_20261020.dt. Backup size: 535,739 bytes; SHA256: 8EC603BB531A27DD7A652DAC4F6EC653CD11F0963F9831E74CE9171A4C66B93F.
- Build path: copied the clean candidate restore into restore_dashboard_batch_query_20261020, loaded all current XML source, applied Designer /UpdateDBCfg, and dumped the final DT. Created restore_final_batch_query_20261020 from that DT with the Skill db-create script.
- Final full E2E on the restored DT: finance-e2e-20261020-122633-0f2a246548464cc68dc73b7ed2b79072; 51/51 phases PASS, 0 failures, 0 blocked phases, process exit code 0. The DT installed as the original is byte-identical to this tested candidate.
- Round-trip output: VSF_Finance_E2E/dt_working/roundtrip_final_batch_query_20261020. All 34 BSL source files matched after line-ending normalization.

Rerun from the workspace root:

powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\VSF_Finance_E2E\scripts\run_finance_e2e.ps1 -BaseInfobase .\VSF_Finance_E2E\dt_working\restore_final_batch_query_20261020

The E2E verifies the implemented scenarios listed above. Incomplete or untested capabilities listed in section 3 remain outside runtime coverage and are not reported as PASS.
