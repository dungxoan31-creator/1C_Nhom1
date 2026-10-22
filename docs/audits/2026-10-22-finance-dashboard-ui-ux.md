# Finance dashboard UI/UX refinement

Date: 2026-10-22

## Scope

Refined the existing 1C thin-client dashboard in `VSF_Finance_E2E/Configuration/CommonTemplates/MauHTMLTrangChu/Ext/Template.txt`. The working note records the screen, users, findings, and acceptance checks in `VSF_Finance_E2E/dt_working/ui_ux_refinement_20261022/UX_before_note.md`.

The dashboard uses a managed form `HTMLDocumentField`. Before and after captures use the same 1C 8.3.22.1704 thin client window (1438×753 client window on a 1920×1080 desktop), signed in as `ketoan_truong`, with copies of the same finance test data. A separate maximized capture checked the wide layout.

## Findings and changes

1. **P1 — Aging legend items overlapped.** The old renderer emitted label, progress bar, and amount as separate flex children and pulled the latter two upward with negative margins. Each category now renders as a single grouped item with its linked label and percentage, then amount and progress bar. All six categories and their `report_aging` links are retained. The labels now display Vietnamese accents.
2. **P2 — Long balances wrapped in a medium-width client window.** KPI cards now use two columns from 901–1250px, two columns at widths through 900px, one column below 560px, and smaller values below 360px. The four-column layout remains at wider desktop widths. Explicit grid row/column gaps provide the spacing visible in the actual 1C HTML field.
3. **P2 — Dashboard marks lacked a visible key and the greeting claimed every user was an administrator.** Added text and matching marks for red booked-revenue bars and the green customer-receipts line. Replaced the false role greeting with “Số liệu được tải từ cơ sở dữ liệu 1C.”

## Business behavior preserved

- No BSL module, posting procedure, register, approval threshold, role, permission, report, dashboard calculation, or drill-down handler was changed.
- KPI values, aging percentages/amounts, and the six bucket keys are still supplied by the existing server module. The AR aging links still use the existing form click handler.
- The root `.dt` was not replaced. Its SHA-256 remains `327BA9C1A02CB4956C5BD1C54B11F19D432FAB8BE318C5780F63D2F806A93086`.
- The source template’s pre-change copy is preserved at `VSF_Finance_E2E/dt_working/ui_ux_refinement_20261022/Template.txt.before-uiux-20261022`.

## Verification

- The project source compiled into an isolated infobase: `compile-root-source.log` contains `Configuration successfully updated`.
- `cf-validate` on the project source and safe UI copy reported **0 errors**. It reports one existing format warning: configuration format 2.15 is below the validator’s verified range 2.17–2.21.
- Native dashboard/Maker-Checker UI workflow passed as `ketoan_truong`: dashboard opened, refresh invoked, one-row approval invoked, and Approve All invoked. Evidence: `ui-root-source.json` and `ui-root-source.dashboard-top.png`.
- The native scrolled dashboard capture passed and visibly shows the revenue key and all six aging groups without overlap: `ui-root-source-visual.json` and `ui-root-source-visual.dashboard-scrolled.png`.
- The maximized thin-client capture passed and showed four readable KPI columns at wide width: `ui-root-source-wide.json` and `ui-root-source-wide.dashboard-top.png`.
- AR ledger, AP ledger, and aging report each opened and rendered a result grid (3/3): `ui-reports.json` and its three report-result screenshots.
- After the template-only refinement, the full finance business E2E suite was rerun against the current `Configuration`: **108/108 phases PASS, 0 failed**, exit code 0. Summary: `VSF_Finance_E2E/results/finance-e2e-20261022-094814-9bc8bce7f0924d3d8e84d0d9190cfe7b/summary.json`. This run also passed native FCT250, required-field UI (7/7), partner/contract choice filters (5/5), AR/AP/aging reports (3/3), and finance-guide UI checks. `test_required_field_ui.ps1` was additionally run against `ui-required-field-validation.json` and confirmed blank-save rejection, no document numbering or persistence, and a correction message across all seven forms.

## Candidate handoff

The refined configuration was compiled and exported with the `db-dump-dt` skill to `VSF_Finance_E2E/dt_working/ui_ux_refinement_20261022/VinSmart_Future_UIUX_candidate_20261022.dt`.

- Size: 1,198,103 bytes
- SHA-256: `0D30191FE332DA78C045A808B5BD439404538E1EAF0667DBD208A9B27F8ECBA2`
- Export log: `db-dump-dt` reported `Infobase successfully dumped`.

This is a separate candidate for review. The canonical root `.dt` remains unchanged.

## Skill guidance applied

- **Impeccable:** Operate mode, app-screen critique/layout, and craft floor informed scanability, native 1C expectations, spacing, contrast, and truthful copy. The context command was run once. Website detector tooling was not used because this surface is an embedded 1C thin-client document field.
- **Taste Skill:** app-screen, critique, layout, type, colour, copy, and tells guidance informed the dashboard and data labels. Marketing-page, imagery, video, and decorative-motion guidance was not applied: this operational screen adds no imagery or animation, and the visual test ran in the native 1C client.
- **1C tooling:** `form-info` confirmed the managed form hosts an HTML document field; `onec-dev`/`onec-platform-toolkit` and `onec-xml-automation` guided isolated compilation and validation; `cf-validate` and `db-dump-dt` were run for the handoff.
- **Execution and verification:** the `executing-plans`, `systematic-debugging`, and `verification-before-completion` workflows were used to resume the approved implementation, verify the last missing business E2E run, and confirm the final artifacts and canonical `.dt` hash.

## Separate review finding

The independent finance review found branch-scoped `Insert`/`Update`/`Delete` rights on legal-entity, contract, and project catalogs in AR/AP roles. This UI task intentionally preserved permissions as specified; removing those rights requires a separate permission review because it could affect catalog-maintenance workflows.
