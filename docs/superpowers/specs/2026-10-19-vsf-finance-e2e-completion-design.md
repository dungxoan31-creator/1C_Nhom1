# VSF AR/AP Cash E2E Design

**Status:** Implemented against a disposable 1C infobase. See the latest runner artifacts under `VSF_Finance_E2E/results/`.

## Chosen flow

`Master data setup (zero opening cash) -> internal BBNT 200m -> issued sales invoice 220m -> customer receipt 220m -> foreign cloud vendor invoice 200m gross -> FCT 20m -> KTT approval -> bank payment 180m -> ledger/register verification`

This uses the existing 1C documents and posting handlers. The current configuration has no internal-netting document and no bank-statement import/reconciliation object; those features are outside this E2E.

## Explicit assumptions

- The AR customer is the existing internal VinFast-group test counterparty under PN-VSF. Accepted service is VND 200,000,000 plus 10% output VAT.
- The E2E AP supplier is a dedicated external cloud vendor. Its contract is denominated in VND for a deterministic payment. Gross invoice is VND 200,000,000; contractor VAT and CIT withholding are each 5% of gross. Payable to the vendor is VND 180,000,000, retained tax is VND 20,000,000, and recognized expense is VND 190,000,000.
- A fresh copied infobase has zero opening balance in the dedicated E2E bank account. No synthetic opening transaction is inserted.
- The customer receipt is VND 220,000,000, the supplier payment is VND 180,000,000, and bank fee is zero. Closing bank cash is VND 40,000,000.
- Admin is used only for fixture setup and regression data generation. Workflow assertions run in separate AR, AP, KTT, and CFO user sessions.
- UI automation is unavailable. The runner invokes the actual 1C enterprise client, document writes, posting handlers, and query/register verification. It does not claim UI coverage.

## Defects found and addressed

- AP USD seed invoices omitted assignment of the foreign-currency amount before VND conversion.
- Test vendor currency was inferred from the `TEST_NCC_` code prefix, incorrectly classifying domestic test vendors as USD. Currency now follows vendor type and existing test contracts are synchronized.
- The central maker state whitelist rejected AP makers submitting a draft to `ChoKeToanTruongDuyet`, contrary to the AP workflow module. The submit transition is now permitted while approval/posting remains role-controlled.
- Initial E2E verification selected bank account 1121 when totaling AP invoice GL entries and also had a contradictory cash-zero guard despite the expected VND 40m closing balance. Both assertions now reconcile the correct AP, AR, tax, and bank GL/control-account totals.

## Verification scope

- Real BBNT, sales invoice, customer receipt, AP invoice, and bank payment creation and posting.
- Workflow transitions with distinct `ketoan_ar`, `cfo_giamdoc`, `ketoan_ap`, and `ketoan_truong` logins.
- A negative over-collection receipt must remain unposted with zero AR, cash, and GL movements.
- AR and AP residuals, FCT tax liabilities, bank cash accumulation balance, and control-account GL totals are read back from persisted 1C registers.
- Existing approval-boundary/security suite and a separate 1,260-invoice AP seed regression run on disposable copies.
- The PowerShell runner validates both 1C exit codes and structured JSON status; an exit code alone is not treated as a pass.

