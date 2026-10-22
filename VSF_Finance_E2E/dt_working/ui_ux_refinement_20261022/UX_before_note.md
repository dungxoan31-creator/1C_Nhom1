# Dashboard UI refinement — before note

Date: 2026-10-22

## Screen and users

- Screen: `DataProcessor.BanLamViecWebERP.Form.FormBanLamViec`, the finance dashboard hosted by a 1C `HTMLDocumentField`.
- Client evidence: the existing native run screenshot shows 1C thin client 8.3.22.1704, logged in as `Kế toán trưởng`, at a 1920×1080 desktop capture. The user-provided 1637×910 dashboard image shows the same layout with live finance values.
- Primary users: AR/AP accountants triaging balances, Kế toán trưởng reviewing approvals, and CFO reviewing liquidity and aging risk.
- Screen question: which receivables, payables, cash movements, and pending documents need action now?

## Three highest-impact issues

1. **P1 — AR aging legend overlap.** The six legend entries render each label, progress bar, and amount as separate flex children with negative top margins. In both the user screenshot and existing thin-client screenshot, amount text collides with category labels and bars. Kế toán trưởng/CFO cannot reliably distinguish aging bucket and amount, weakening collection prioritization.
2. **P2 — KPI amounts wrap at the actual thin-client window size.** The 1920×1080 desktop screenshot has a 1C windowed client with a roughly 1,140px dashboard viewport. The four auto-fit metric cards become too narrow for long VNĐ balances; e.g. `59.654.720.000 VNĐ` and `1.083.981.480.000 VNĐ` split across lines, making the figures slower to compare.
3. **P2 — Dashboard labels leave room for misreading.** The chart subtitle names booked revenue and customer receipts, but red bars and the green line have no visible key. Also, the static greeting says “Xin chào Quản trị viên!” while the signed-in thin-client title shows “Kế toán trưởng.” Add the missing series key and replace the false role claim with a neutral data-freshness statement, without adding user/role lookup logic.

## Change direction

- Refine only the existing dashboard template; keep its layout, colors, typography, chart data, six aging categories, role permissions, links, and 1C navigation.
- Render each aging category as one spaced unit: linked label and percentage on the first line, amount and its progress bar below, with no negative margins. Keep all six bucket links and their encoded bucket keys.
- At medium desktop viewport widths, use two metric columns so currency figures stay on one line; keep four columns when the viewport has room and allow a single column on narrow screens.
- Add a compact key that says red columns are `Doanh thu ghi sổ` and the green line is `Tiền thu khách hàng`.
- Replace the incorrect role greeting with neutral copy that remains true for all authorized users.

## Business behavior held constant

No posting, ledger/register, approval threshold, access right, dashboard calculation, fixture, report, or source business module changes. In particular, aging values and bucket drill-down routes remain supplied by `BangDieuKhienServer` and the existing form click handler.

## Completion checks

- The six labels, percentages, formatted amounts, and progress values are readable with no collisions or clipping in the actual thin client.
- KPI currency values stay on one line at the captured window width and retain the four-column layout at wide viewport size.
- Chart series are identifiable from text and a matching visual mark.
- The greeting does not claim a role the form has not resolved.
- Refresh, batch approval, and aging report drill-down still route through the existing 1C form handler.
- The copied configuration validates/compiles, actual-client screenshots are saved before and after at the same desktop geometry, and focused dashboard UI smoke passes.
- The canonical root `.dt` and root source configuration remain untouched by this UI task.
