[CmdletBinding()]
param(
    [string]$OneCExe = 'C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe',
    [string]$Infobase,
    [string]$WorkRoot,
    [switch]$OnlySetup,
    [switch]$VerifyOnly
)

$ErrorActionPreference = 'Stop'
$RunId = 'mockup-20261020'
if (-not $WorkRoot) { $WorkRoot = Join-Path (Split-Path -Parent $PSScriptRoot) 'mockup_work_20261020' }
if (-not $Infobase) { $Infobase = Join-Path $WorkRoot 'infobase' }

function Invoke-SeedStage([string]$Label, [string]$User, [string]$Command) {
    $SavedResult = Join-Path $WorkRoot ($Label + '.json')
    if (Test-Path -LiteralPath $SavedResult) {
        $Previous = Get-Content -LiteralPath $SavedResult -Raw | ConvertFrom-Json
        if ($Previous.status -eq 'PASS') {
            Write-Host "SKIP $Label (already passed)"
            return
        }
    }

    # /C is one unquoted 1C argument, so its result path must have no spaces.
    $TempResult = Join-Path $env:TEMP ('VSFMockup_' + $Label + '.json')
    if (Test-Path -LiteralPath $TempResult) { Remove-Item -LiteralPath $TempResult -Force }
    $Log = Join-Path $WorkRoot ($Label + '.log')
    $Arguments = 'ENTERPRISE /F"' + $Infobase + '" /N' + $User + ' /C' + $Command + ';' + $RunId + ';' + $TempResult + ' /DisableStartupMessages /Out"' + $Log + '"'
    $StartInfo = New-Object System.Diagnostics.ProcessStartInfo
    $StartInfo.FileName = $OneCExe
    $StartInfo.Arguments = $Arguments
    $StartInfo.CreateNoWindow = $true
    $StartInfo.UseShellExecute = $false
    $Process = [System.Diagnostics.Process]::Start($StartInfo)
    if (-not $Process.WaitForExit(1800000)) {
        $Process.Kill()
        throw "Timed out at $Label; see $Log"
    }
    if (-not (Test-Path -LiteralPath $TempResult)) {
        throw "No JSON from $Label (1C exit $($Process.ExitCode)); see $Log"
    }
    Copy-Item -LiteralPath $TempResult -Destination $SavedResult -Force
    $Result = Get-Content -LiteralPath $SavedResult -Raw | ConvertFrom-Json
    if ($Process.ExitCode -ne 0 -or $Result.status -ne 'PASS') {
        throw "Failed $Label (1C exit $($Process.ExitCode)): $($Result.error)"
    }
    Write-Host ("PASS {0}: {1}" -f $Label, ($Result.data | ConvertTo-Json -Compress -Depth 5))
}

if (-not (Test-Path -LiteralPath $OneCExe)) { throw "1C not found: $OneCExe" }
if (-not (Test-Path -LiteralPath (Join-Path $Infobase '1Cv8.1CD'))) { throw "Infobase not found: $Infobase" }

if ($VerifyOnly) {
    Invoke-SeedStage 'roundtrip-ar-regression' 'cfo_giamdoc' 'RunARSeedRegression'
    Invoke-SeedStage 'roundtrip-ap-regression' 'cfo_giamdoc' 'RunAPSeedRegression'
    return
}

Invoke-SeedStage 'setup' 'Admin' 'RunFinanceE2E;setup'
if ($OnlySetup) { return }

Invoke-SeedStage 'ar-master' 'cfo_giamdoc' 'RunARSeedMasterData'
Invoke-SeedStage 'ap-master' 'cfo_giamdoc' 'RunAPSeedMasterData'
Invoke-SeedStage 'ar-prepare-acceptances' 'ketoan_ar' 'RunARSeedStage;PrepareAcceptances'
Invoke-SeedStage 'ar-post-acceptances' 'cfo_giamdoc' 'RunARSeedStage;PostAcceptances'
Invoke-SeedStage 'ar-prepare-invoices' 'ketoan_ar' 'RunARSeedStage;PrepareInvoices'
Invoke-SeedStage 'ar-post-invoices' 'cfo_giamdoc' 'RunARSeedStage;PostInvoices'
Invoke-SeedStage 'ar-prepare-receipts' 'ketoan_ar' 'RunARSeedStage;PrepareReceipts'
Invoke-SeedStage 'ar-post-receipts' 'cfo_giamdoc' 'RunARSeedStage;PostReceipts'
Invoke-SeedStage 'ap-prepare-invoices' 'ketoan_ap' 'RunAPSeedStage;PrepareInvoices'
Invoke-SeedStage 'ap-approve-invoices' 'ketoan_truong' 'RunAPSeedStage;ApproveInvoicesKTT'
Invoke-SeedStage 'ap-post-high-invoices' 'cfo_giamdoc' 'RunAPSeedStage;PostHighInvoicesCFO'
Invoke-SeedStage 'ar-regression' 'cfo_giamdoc' 'RunARSeedRegression'
Invoke-SeedStage 'ap-regression' 'cfo_giamdoc' 'RunAPSeedRegression'

# A small linked transaction chain also populates the payment worklist.
Invoke-SeedStage 'demo-ar-submit-acceptance' 'ketoan_ar' 'RunFinanceE2E;ar_submit_acceptance'
Invoke-SeedStage 'demo-cfo-approve-acceptance' 'cfo_giamdoc' 'RunFinanceE2E;cfo_approve_acceptance'
Invoke-SeedStage 'demo-cfo-post-acceptance' 'cfo_giamdoc' 'RunFinanceE2E;cfo_post_acceptance'
Invoke-SeedStage 'demo-ar-submit-invoice' 'ketoan_ar' 'RunFinanceE2E;ar_submit_invoice'
Invoke-SeedStage 'demo-cfo-issue-invoice' 'cfo_giamdoc' 'RunFinanceE2E;cfo_issue_invoice'
Invoke-SeedStage 'demo-ar-create-receipts' 'ketoan_ar' 'RunFinanceE2E;ar_create_receipts'
Invoke-SeedStage 'demo-cfo-post-receipts' 'cfo_giamdoc' 'RunFinanceE2E;cfo_post_receipts'
Invoke-SeedStage 'demo-ap-submit-invoice' 'ketoan_ap' 'RunFinanceE2E;ap_submit_invoice'
Invoke-SeedStage 'demo-ktt-post-ap-invoice' 'ketoan_truong' 'RunFinanceE2E;ktt_post_ap_invoice'
Invoke-SeedStage 'demo-ap-submit-payment' 'ketoan_ap' 'RunFinanceE2E;ap_submit_payment'
Invoke-SeedStage 'demo-ktt-approve-payment' 'ketoan_truong' 'RunFinanceE2E;ktt_approve_payment'
