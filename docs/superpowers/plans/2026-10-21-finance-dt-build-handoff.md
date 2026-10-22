# Finance DT Build and Handoff Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` after this plan is approved. Execute only after the reporting, forms, CSV, and guide plans are complete.

**Goal:** Build, verify, and safely install the completed configuration as the project’s canonical `.dt` file.

**Architecture:** Preserve the current root DT, update the source configuration on an isolated working infobase, dump a candidate DT, restore that exact candidate to a disposable infobase, run the full E2E against the restored candidate, and only then replace the canonical file.

**Tech Stack:** 1C Designer 8.3.22.1704, PowerShell project scripts, `onec-xml-automation` DT load/dump helpers, SHA-256.

**Spec:** `docs/superpowers/specs/2026-10-21-finance-e2e-completion-design.md`, sections 4–5.

## Global Constraints

- Canonical target: `VinSmart_Future_AdminFull_v5_SuaFont.dt` in the workspace root.
- Preserve the pre-change DT with its original bytes and record its SHA-256 before any replacement.
- Do not replace the canonical DT until the restored candidate has completed configuration update and full E2E successfully.
- Use an isolated file-mode infobase; never load the candidate over the only source/base infobase.
- Use the 1C runtime `8.3.22.1704`; report a blocked handoff if Designer cannot load, update, restore, or dump the candidate.
- No Git repository exists; record artifacts in an audit document instead of committing.

## Review Focus

- Source configuration may not match the chosen DT; compare source/object counts and load/update logs before dumping.
- Designer exit code alone is insufficient; require the `Configuration successfully updated` log marker.
- A successful source-base test is not evidence for the final DT; restore and run the exact dumped candidate.
- If the candidate contains preloaded data that violates E2E fixture preconditions, preserve that data and run the full suite on a clean test base using the candidate's exported XML configuration; record the deviation and prove the exports match.
- Atomic replacement or backup can fail on Windows if handles are open; verify output hashes and preserve the backup path.
- E2E results must point to the same candidate DT hash recorded in the handoff audit.

## Files and responsibilities

- Read/modify only `VSF_Finance_E2E/Configuration` and isolated `VSF_Finance_E2E/dt_working/*` paths during build.
- Create candidate under `VSF_Finance_E2E/dt_working/finance_complete_20261021/candidate-branch-default-final-20261022.dt` and restored test base under the same isolated work directory.
- Use `VSF_Finance_E2E/scripts/compile_infobase_config.ps1` for Designer configuration update and `scripts/run_finance_e2e.ps1` for full E2E.
- Use `.codex/skills/onec-xml-automation/scripts/db-dump-dt.ps1` and `db-load-dt.ps1` with explicit infobase paths for candidate dump/restore.
- Create `docs/audits/2026-10-21-finance-e2e-completion.md` with platform, backup/candidate/final hashes, E2E run path, and unresolved limitations.

---

### Task 1: Prepare an isolated build and preserve the source DT

**Files:**
- Read: root `VinSmart_Future_AdminFull_v5_SuaFont.dt`
- Create: `VSF_Finance_E2E/dt_working/finance_complete_20261021/` build paths
- Create: `VSF_Finance_E2E/archive/VinSmart_Future_AdminFull_v5_SuaFont_before_branch_default_fix_20261022.dt`

- [x] **Step 1: Record source DT size, timestamp, and SHA-256** in the handoff audit.
- [x] **Step 2: Copy the selected DT to a dated backup** and verify byte length and SHA-256 match the source.
- [x] **Step 3: Create an isolated working infobase from the selected DT** using the `db-create` skill script at an explicit new path; do not target `BaseInfobase` or the canonical file.
- [x] **Step 4: Confirm the working base opens in Designer 8.3.22.1704** and retains expected configuration identity before loading source files.

### Task 2: Load source configuration and create candidate DT

**Files:**
- Read: `VSF_Finance_E2E/Configuration`
- Create: `VSF_Finance_E2E/dt_working/finance_complete_20261021/candidate-branch-default-final-20261022.dt`
- Test: Designer update log

- [x] **Step 1: Load all current XML source** into the isolated working infobase with the documented `db-load-xml` skill workflow.
- [x] **Step 2: Run `scripts/compile_infobase_config.ps1 -Infobase <isolated-build-base> -Configuration .\VSF_Finance_E2E\Configuration`**; require exit code 0 and `Configuration successfully updated`.
- [x] **Step 3: Dump the updated working infobase** to the candidate path with `db-dump-dt.ps1`.
- [x] **Step 4: Verify candidate exists, is non-empty, and has a recorded SHA-256**; retain the Designer update log beside build artifacts.

### Task 3: Restore and verify the exact candidate DT

**Files:**
- Read: `candidate.dt`
- Create: isolated restored candidate infobase and E2E artifacts under `dt_working/finance_complete_20261021/`

- [x] **Step 1: Restore `candidate.dt` into a fresh disposable infobase** with `db-create`; do not reuse the build infobase.
- [x] **Step 2: Run report/forms/CSV/guide targeted UI and runtime phases** against the restored candidate; preserve their JSON and logs.
- [x] **Step 3: Run the full suite** using the XML export from the restored candidate and a clean E2E data base via `-ConfigurationPath <candidate-config-xml> -BaseInfobase <clean-base>`.
- [x] **Step 4: Require process exit 0, `summary.json.status=PASS`, zero failed phases, and all reporting/forms/CSV/guide assertions PASS.** The final candidate-configuration run had 108/108 phases PASS on 2026-10-22; see the final handoff section below.

**Candidate data note:** Restoring the candidate succeeded. A full run directly on its stored data stopped at setup because `TK-E2E-VND` already had a balance; the all-forms smoke also found that the stored data did not include `E2E-NET-001`. The candidate was kept unchanged. Its exported configuration matched the clean E2E configuration byte-for-byte across all 200 metadata files (excluding `ConfigDumpInfo.xml`), so the full suite ran against that exact exported configuration on the clean test data base. Direct AR and AP form smoke checks on the restored candidate passed.

### Task 4: Replace canonical DT and record the handoff

**Files:**
- Replace: root `VinSmart_Future_AdminFull_v5_SuaFont.dt`
- Preserve: dated backup DT
- Create: `docs/audits/2026-10-21-finance-e2e-completion.md`

- [x] **Step 1: Reconfirm backup and candidate hashes** and close any 1C handles to those files.
- [x] **Step 2: Replace the root DT only after Task 3 passes**, using a same-volume staged file and a rollback-safe Windows replacement operation.
- [x] **Step 3: Recompute the root DT SHA-256** and require an exact match with the candidate hash.
- [x] **Step 4: Write the handoff audit** with runtime version, root/candidate/backup hashes, full E2E run path, UI artifacts, and the data-fixture limitation.
- [x] **Step 5: Verify the original backup remains loadable and unchanged**; the backup is byte-identical to the source DT used to create the isolated build infobase.

## Actual Handoff — 2026-10-22

- Candidate DT: `candidate-branch-default-final-20261022.dt`, 1,195,864 bytes, SHA-256 `327BA9C1A02CB4956C5BD1C54B11F19D432FAB8BE318C5780F63D2F806A93086`.
- Installed canonical DT has the same byte count and hash.
- Exact pre-replacement canonical backup: `VSF_Finance_E2E/archive/VinSmart_Future_AdminFull_v5_SuaFont_before_branch_default_fix_20261022.dt`, 1,195,766 bytes, SHA-256 `799C4EA4F8ED41CEB8D0E80CC2005F30B88193C7EC72DB5566632E27443CB026`.
- The restored-candidate configuration export at `candidate-config-restored-branch-default-final-20261022` passed the full suite: run `finance-e2e-20261022-085513-4a2cf2d295224da69299212f3cdec636`, 108/108 phases, zero failures.
- A clean E2E base was used because preloaded candidate data conflicts with fixture seeding; the candidate data itself was preserved. All 50 BSL modules matched after BOM/line-ending normalization; raw XML export differences are recorded in `candidate-config-source-compare-branch-default-final-20261022.json`.
- Detailed build, test, and data-boundary evidence: `docs/audits/2026-10-21-finance-e2e-completion.md`.
- No Git repository exists in this workspace; the audit and hash-verified backup record the handoff instead of a commit.