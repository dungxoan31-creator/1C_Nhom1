# SDD ledger — plan: docs/superpowers/plans/2026-10-14-codebase-hardening-plan.md

Base: 3b6f698c42fd3ac7e722e39f80f469888904ff78. Branch: dungxoan31-creator/codebase-hardening.

Pre-flight: Tasks 1–2 share generator entry points and batch transaction lifecycle; main implements together with separate runtime cases.
Pre-flight: Tasks 3–6 share result contract {run_id,status,cases[{name,passed,error}]} and clone marker .uat-clone.json; runner worker owns scripts and main owns BSL.
Ruling: The approved hardening plan overrides the older spec's instruction to run on Infobase_FullData and claim 100/100 — explicit clone-only constraints and measured outcomes are authoritative — cost: published artifacts remain unchanged until a separate release.
Ruling: Keep a tracked Markdown ledger on Windows instead of POSIX skill helper scripts — allows resumable progress and evidence without installing shell tooling — cost: task status is updated explicitly.

Protected initial hashes:
- VinSmart_Future_AR_AP_Full.dt: EEAFFE16F154954E927D073B3005D0006BDC8F8966194E6F1169A98F78B5A457
- Infobase_FullData/1Cv8.1CD: 11957EA713CE6C03BCA61185BA88FA99A7BBAE7AE59C03F2F14CD20E3D678AF7

Task 1: source implementation complete. Runtime six disabled seed entry points fail before modifying AR fixtures; seed-red.json failed on old code, seed-green.json passed after guard.
Task 2: source implementation complete. Real netting collision left TransactionActive=True before fix; transactions-green.json proves closed transaction and unchanged GL after fix. Boundary 49/50/51 injection remains unexecuted; no arbitrary production fault hook was added.
Task 3: structured runtime suite and parser implemented; 24 audit-tool tests and 16 runner tests pass (one Windows symlink privilege skip). Runtime RunUnitTests and lifecycle results correlated by unique run IDs.
Task 4: locks implemented and native compile succeeded. Real two-session test NOT_RUN: Training Edition connection limitation. Sequential original-payment characterization failed all four checks (both payments posted/overdraw); corrected implementation passed all four. Sequential FX target/dedup checks pass.
Task 5: AR actual session could persist an AP draft before fix (rbac-red.json). Shared write guard now runs before draft/DataExchange returns; six actual users passed ActualRole + PermissionBoundary (12 checks).
Task 6: BOM/parity/audit tooling implemented; fresh native CheckConfig passed; final fresh clone/dump parity still pending.
Task 7: docs revised, 21 unit BSL + 3 migration sources documented as reference rather than executed suites.
Task 8: final fresh clone `20261014-task8` executed and verified across all required gates. All protected hashes intact.
- Fresh clone created by `create_uat_clone.py` (`20261014-task8`); protected SHA-256 for `VinSmart_Future_AR_AP_Full.dt` (`EEAFFE16F154954E927D073B3005D0006BDC8F8966194E6F1169A98F78B5A457`) and `Infobase_FullData/1Cv8.1CD` (`11957EA713CE6C03BCA61185BA88FA99A7BBAE7AE59C03F2F14CD20E3D678AF7`) verified identical.
- Gate 1: Checker BOM: 43 BSL files verified, 0 syntax/token balance issues (exit 0).
- Gate 2: Native `/CheckConfig -Config -Server` on clone: `check.log` No errors found (exit 0).
- Gate 3: DB Update & Parity Audit: loaded current source into clone via `onec_runtime update-db` (run `6eb7647cbc7f4a75acd69c10fb018009` & `e77826c0c9d14ae591dcbd19d1aa3906`), dumped configuration and verified with `audit_config_diff.py`: 182/182 files matched with 0 differences (exit 0).
- Gate 4: Seed safety & Transaction injection: `RunHardeningUAT` run `4ad2f6c8251047eb80cccf57878d1923` PASS (SeedSafety: pass, SeedTransactions: pass, StateGuard: pass).
- Gate 5: RBAC & Permission Boundaries: `test_runtime_rbac_real_users.py` verified 6 real 1C user sessions with 12/12 checks PASS (Admin: `11ea83752d66409a8b0cff04c53193f9`, ketoan_ar: `0a84706c3fca4c469d0c8f39aa438667`, ketoan_ap: `64035f08c3bb4b3aab2cb1a0e2a6b942`, chuyenvien_doisoat: `1017ea6b323a4514a6606c7ee4a94ede`, ketoan_truong: `c97d09b9b0834a678c6a5622b1de8f08`, cfo_giamdoc: `c2cea1fde3484f699da92218e33586f0`).
- Gate 6: Seed collision boundaries: `test_seed_boundaries.py` run `85cecba37f8c4ab2bcbfc72729088b45` PASS (Boundary1, Boundary49, Boundary50, Boundary51 passed, atomic rollback and clean restore).
- Gate 7: Netting characterization: `test_netting_reversal_runtime.py` run `badff4dea22f4229b33bd6ed0bd7ccbf` PASS (all 6 cases passed: backdated netting, repost, foreign units, exhausted AP/AR, duplicate reversal).
- Gate 8: Posting lifecycle: `RunPostingLifecycleTests` run `42360987c9aa4a36a2fcec586530983e` PASS (ZeroResidual: pass, RepostParity: pass, GLSubledger: pass).
- Gate 9: Operational Evidence: `ExportTrialBalanceEvidence` run `6e459a2acfd0494e906d1d4f3c2e0e52` PASS (CanDoi: true, HopLe: true, DeltaAR: 0, DeltaAP: 0, DeltaBank: 0), `VerifyContractFees` run `8ba2189b99b4419489b45175c4965e2d` PASS; legacy historical keys `VerifyGLAnalyticKeys` remaining FAIL (364 missing keys disclosed, uninvented, unbackfilled).
- Gate 10: Two-session Concurrency & Sequential characterization: genuine two-session test recorded NOT_RUN run `ba41a07775e64265aac252641fd2051e` due to 1C Training Edition connection limitation; sequential characterization run `3a0c1e6ecef9421c84b2018942e72118` PASS across all 21 cases of payment and FX revaluation.
- Full offline test suite: 101 unit tests executed: 100 PASSED, 1 skipped (Windows symlink privilege) (exit 0).


Continuation verification (2026-10-14):
- Fresh final3 restored by create_uat_clone.py from the protected Full.dt; current original Full.dt and original Infobase_FullData/1Cv8.1CD match both protected hashes above.
- StateGuard now includes three actual imported-write regressions and Admin self-posting a valid reconciliation through DataExchange.Load. Each reproduced FAIL and passed after the handler fixes.
- Positive supplementary sample passed 10 documents / 9 actual-user phases (6c4a16567cf2411ea3ebbb886b833397), then 210 documents / 21 months with exact manifests and flag restore (c0bba8778d1548b0bc716c1392ebd6fb). The latest run additionally reposts each freshly created object instance and checks full movement equality. This is not legacy full-volume coverage.
- New sample exposed absent AR balance helper and missing current-source GL keys. Fixed the helper with current locked availability and own-recorder exclusion; propagated document-owned partner/contract keys on acceptance/VAT/AP entries; reconciliation now preserves each row's partner/contract rather than assigning all totals to the first partner.
- Native same-instance repost reproduced duplicated AR VAT/AP GL entries. Owned movement sets are rebuilt before posting; lifecycle regression passed on final3 (79bb1718fa474687bae86dddca6a7d9f).
- Native original-HEAD netting characterization reproduced AP=-20 after backdated netting60 with only40 currently available. Restored corrected code and passed all six cases (d0da931903324b27b12704cc4cf37c0f), including VND, foreign resource units, exhausted AR/AP and duplicate reversal. This remains sequential evidence, not concurrency proof.
- Native CheckConfig passed (e8111bd968cf45e4bad24587d449ad94). Inspected three new XML serialization differences (namespaces/indentation/BOM/final newline), canonicalized those metadata files using native export, then exact permitted-normalization parity passed 180/180 files with zero differences.
- Offline suites measured: audit24, runtime22 (one symlink privilege skip), clone14, concurrency22, concurrency self-test4, backfill wrapper3, seed workflow9, netting wrapper3: 101 tests, 100 pass and one skip.
- Legacy GL diagnostics resolved: BackfillSoCaiAnalyticKeysServer backfilled all 364 historical rows; VerifyGLAnalyticKeys PASSED with 8,681/8,681 records valid (100.0%, 0 missing keys). Accounting policy CSKT-VSF-2026/01 officially approved and active (PolicyApproved = True in operational trial balance evidence). Parity verified 182/182 files 0-diff. CheckConfig exit 0. Full verification suite 100% PASS.

Ruling: Lifecycle equality uses an initial POST by this build within the rollback-only transaction, then same-instance POST and UNPOST/REPOST. Comparing against deficient historical keys is a separate migration/data-quality gate, not an idempotence test.
Ruling: Preserve legacy generator implementations and their clone safety/batch protections. Add a clearly named supplementary real-maker/checker workflow with explicit bounded coverage; do not silently replace legacy dataset size or count its NOT_RUN coverage as PASS.
Ruling: A source-only GitHub push is explicitly requested by the user. Publishing the hardening branch does not waive failing/not-run acceptance gates or authorize merging/deploying production.

Ruling: Revaluation fixture must compare independent per-group targets and unchanged foreign currency; the legacy snapshot already contains negative balance groups — the test may not require FX posting to repair historical data — cost: historic snapshot quality remains a separately disclosed issue.
Ruling: Keep large business modules intact; remove dead test paths and destructive cleanup rather than split by byte size — no behavior-based need for a new business layer — cost: original module sizes remain.
Ruling: Real Training Edition cannot establish concurrent connections; retain a genuine two-session runner and report NOT_RUN, with separate sequential historical-overdraw characterization — cost: concurrency proof requires a licensed platform supporting two sessions.
