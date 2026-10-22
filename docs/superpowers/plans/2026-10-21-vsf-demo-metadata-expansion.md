# VSF AR/AP Demo Metadata Completion Plan

## Objective

Complete the AR/AP user journeys represented by the supplied demo and the broader requested flows. Close the current user-visible gaps, add the missing business metadata for sales orders, purchase orders, payment requests, AR/AP reporting, and accounting-period locks, then exercise the resulting configuration on disposable 1C infobases.

## Guardrails

- Preserve the supplied `.dt` files; compile and run against a fresh disposable copy.
- Keep accounting movements balanced and tied to a source document. Do not let orders post AR/AP balances before an invoice is issued or accepted.
- Preserve existing maker-checker roles, branch RLS, validation, and negative-balance guards.
- Do not issue a real e-invoice or contact a real bank; use the existing local bank stub and a simulated e-invoice status transition.
- Every new command must validate the current document status and role on the server, even when a UI control is hidden or disabled.

## Work sequence

1. **Reconcile current configuration and demo gaps.** Inventory metadata, forms, object managers/modules, posting handlers, access rights, and current test coverage. Record expected happy paths and rejection cases against the demo values and existing seeded data.
2. **Fix the live KTT approval-pane access failure.** Reproduce it with a minimal KTT query, isolate the failing object/field/RLS condition, correct the least-privilege read path, and add a regression assertion before changing the dashboard workflow.
3. **Complete the demo forms and commands.** Add AR issue/release controls backed by the existing e-invoice state; add receipt and payment source links and “create based on” routes; expose currency, rate, foreign amount, and refund state where required; replace queue-wide approval with a per-document command and explicit selection.
4. **Add the missing business metadata.** Add sales order and purchase order documents with draft/approved/closed lifecycle and source linkage; add payment request tied to an AP invoice; add an AR/AP balance report over persisted registers; add a legal-entity period-lock register and server-side lock checks for writes, posting, and unposting.
5. **Integrate roles and navigation.** Add the new objects to configuration, subsystem command interfaces, and roles with branch-scoped access. Verify role matrices for list/read/create/update/post/undo-post and report access.
6. **Expand automated coverage.** Add metadata inventory and form contracts, command coverage, required/reference/boundary probes, maker-checker/RLS checks, source-link validation, currency/rate checks, period-lock rejection cases, concurrent posting/lock checks, and E2E AR/AP flows including reports and register reconciliation.
7. **Validate and run the full suite.** Run metadata/form/role validation, Designer configuration update, UI smoke on all available forms and commands, functional E2E on disposable copies, and rerun the entire suite after every fix. Capture JSON, logs, screenshots, and a generated coverage report.

## Acceptance evidence

- New object metadata is present in `Configuration.xml`, subsystem menus, and intended role rights.
- Designer updates the expanded configuration successfully; metadata and role validators pass.
- Each new list and object form opens, its available controls match metadata, and each exposed command has a positive and negative test.
- Period-lock tests prove that writes/posting/unposting are rejected without financial movements for the locked legal entity and remain permitted for an unlocked entity/period.
- AR/AP source-document amounts and residual balances reconcile to accumulation-register movements and balanced GL entries.
- All suite phases return structured `PASS` with zero failed cases; the report identifies any environment-blocked coverage rather than counting it as passed.
- Original `.dt` SHA-256 remains unchanged.

## Self-review

- The request does not define new order approval policy or e-invoice provider integration. Use existing maker-checker roles and a deterministic simulated issue command; do not add an external integration.
- Period locks are scoped by legal entity and accounting period so one locked entity cannot block another.
- Order documents remain non-posting planning documents until their linked invoice documents produce accounting movements.
- “100%” means all declared objects, controls, and supported workflows in this plan are represented in the coverage matrix and runtime results; unavailable UI/platform paths are explicitly recorded as blocked, not green.
