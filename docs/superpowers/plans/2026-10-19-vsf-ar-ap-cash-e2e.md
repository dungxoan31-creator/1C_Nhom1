# VSF AR/AP Cash E2E Implementation Plan

## Objective

Deliver a repeatable 1C E2E against disposable infobase copies. Use existing documents and posting logic, verify persisted register and accounting results, and preserve the original supplied `.dt` file.

## Deterministic business scenario

- Setup uses PN-VSF, the existing internal VinFast-group customer, a dedicated external cloud vendor with a VND contract, a dedicated VND bank account, and E2E-only cash-flow categories.
- Opening balance on the dedicated bank account is zero.
- AR: BBNT service amount VND 200,000,000; output VAT 10% = VND 20,000,000; sales invoice and receipt = VND 220,000,000.
- AP: gross VND 200,000,000; contractor VAT 5% and CIT 5% = VND 10,000,000 each; vendor payable = VND 180,000,000; recognized expense = VND 190,000,000.
- KTT approves the AP invoice and bank payment. CFO posts/executes the separate approval steps. Payment is VND 180,000,000 with no fee; closing bank balance is VND 40,000,000.
- The over-collection negative case attempts VND 220,000,001 against the VND 220,000,000 invoice and must leave no financial movements.
- This configuration has no internal-netting or bank-statement import/reconciliation metadata. The run does not claim those features.

## Implemented sequence

1. Copy the workspace base infobase to a unique temporary path, compile the current XML configuration into the copy, and retain logs/results under a run-specific artifacts folder.
2. Run deterministic setup as Admin; assert opening cash is zero and required master data/accounts exist.
3. Create/submit BBNT as AR; approve and post as CFO.
4. Create/submit sales invoice as AR; issue/post as CFO.
5. Create full and over-collection receipts as AR; post the full collection and prove the over-collection remains unposted with no AR/cash/GL movements as CFO.
6. Create/submit AP vendor invoice as AP; KTT posts after approval.
7. Create/submit UNC as AP; KTT approves/sends to bank; CFO posts payment.
8. Query persisted AR/AP/cash registers and GL recorder/account totals; verify AR residuals = 0, AP residual = 0, cash = VND 40,000,000, output VAT = VND 20,000,000, and FCT liabilities = VND 10,000,000 each.
9. Run existing 3-case boundary/security suite under `ketoan_ap` on the E2E copy.
10. On a separate fresh copy, run the AP seed regression without payments; verify at least 1,260 posted invoices and all 315 USD invoices have nonzero USD and VND values.
11. Rerun the complete sequence after the final code change and retain JSON/log evidence.

## Important implementation fixes

- Assign the AP seed's USD amount before converting it to VND; create its missing `KM-CHI-CLOUD` cash-flow category; support an invoice-only regression mode.
- Determine test contract currency from counterparty type and correct existing generated test contracts.
- Permit AP makers to submit drafts to the KTT review queue; retain KTT/CFO authorization for approval and posting.
- Verify finance totals from the correct GL control accounts and compare bank GL movement with the cash register.

## Acceptance evidence

- Designer reports `Configuration successfully updated`.
- All 13 E2E phases return JSON `PASS` under their assigned user sessions.
- All three existing boundary/security tests pass as `ketoan_ap`.
- AP seed regression passes with 1,260 invoices, 315 valid USD invoices, and zero generated payments.
- The original `.dt` SHA-256 remains `660BC1596577A19E78E7267D25A3F8D0EE5A4C46E129D46E0692D9B0338C8816`.
- The runner command is `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\VSF_Finance_E2E\scripts\run_finance_e2e.ps1`.
