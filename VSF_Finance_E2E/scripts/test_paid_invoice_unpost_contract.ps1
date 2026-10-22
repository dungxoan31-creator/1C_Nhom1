[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$ModulePath = Join-Path $ProjectRoot 'Configuration\CommonModules\SeedBoundaryTestsServer\Ext\Module.bsl'
$RunnerPath = Join-Path $PSScriptRoot 'run_finance_e2e.ps1'
$Module = [System.IO.File]::ReadAllText($ModulePath, [System.Text.Encoding]::UTF8)
$Runner = [System.IO.File]::ReadAllText($RunnerPath, [System.Text.Encoding]::UTF8)
$Checks = @(
	@{ Name = 'E2E phase dispatch'; Text = $Module; Pattern = 'Phase = "ar_unpost_paid_invoice_rejected"' },
	@{ Name = 'paid invoice fixture verification'; Text = $Module; Pattern = 'Function VerifyPaidARInvoiceUnpostRejected\(\)' },
	@{ Name = 'undo posting attempt'; Text = $Module; Pattern = 'Invoice\.Write\(DocumentWriteMode\.UndoPosting\)' },
	@{ Name = 'expected cancellation from dependent document guard'; Text = $Module; Pattern = 'XuLyHuyGhiSo\(Invoice, Cancel\)' },
	@{ Name = 'expected write rejection is asserted'; Text = $Module; Pattern = 'StrFind\(UnpostWriteError, "Failed to save"\)' },
	@{ Name = 'failed attempt is rolled back before persisted state is read'; Text = $Module; Pattern = '(?s)If TransactionActive\(\) Then RollbackTransaction\(\); EndIf;.*?UnpostAttempt = InvoiceRef\.GetObject\(\);' },
	@{ Name = 'rejected unposting preserves posted state'; Text = $Module; Pattern = 'rejected_due_to_posted_receipt' },
	@{ Name = 'full E2E runner invokes the new phase'; Text = $Runner; Pattern = "@\('ar_unpost_paid_invoice_rejected', 'cfo_giamdoc'\)" }
)
$Failures = @($Checks | Where-Object { $_.Text -notmatch $_.Pattern })
if ($Failures.Count -gt 0) {
	$Failures | ForEach-Object { Write-Error ("Missing $($_.Name).") -ErrorAction Continue }
	Write-Output ("FAIL paid invoice unpost contract: {0} issue(s)." -f $Failures.Count)
	exit 1
}
Write-Output 'PASS paid invoice unpost contract: posted receipt dependency and rollback assertion are wired.'
