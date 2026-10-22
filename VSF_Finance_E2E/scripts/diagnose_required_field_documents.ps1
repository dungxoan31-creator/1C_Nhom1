[CmdletBinding()]
param(
	[Parameter(Mandatory = $true)][string]$Infobase,
	[string]$OneCExe = 'C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe',
	[string]$OutputDirectory = $env:TEMP
)

$ErrorActionPreference = 'Stop'
$UiScript = Join-Path $PSScriptRoot 'run_finance_ui_e2e.ps1'
$Documents = @('Acceptance', 'ARInvoice', 'Receipt', 'APInvoice', 'Payment', 'Netting', 'Reconciliation')
$Results = [System.Collections.Generic.List[object]]::new()

foreach ($Document in $Documents) {
	$ResultPath = Join-Path $OutputDirectory ('ui-required-field-probe-' + $Document + '.json')
	Remove-Item -LiteralPath $ResultPath -Force -ErrorAction SilentlyContinue
	$Arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $UiScript + '" -OneCExe "' + $OneCExe + '" -Infobase "' + $Infobase + '" -User Admin -Workflow RequiredFieldDiagnostics -RequiredFieldDocument ' + $Document + ' -ResultPath "' + $ResultPath + '"'
	$Process = Start-Process -FilePath 'powershell.exe' -ArgumentList $Arguments -PassThru -WindowStyle Hidden
	if (-not $Process.WaitForExit(180000)) {
		Stop-Process -Id $Process.Id -Force
		$Results.Add([PSCustomObject]@{ document_type = $Document; status = 'TIMEOUT'; error = 'UI diagnostic exceeded 180 seconds.' })
		Write-Host ('TIMEOUT ' + $Document)
		continue
	}
	if (-not (Test-Path -LiteralPath $ResultPath)) {
		$Results.Add([PSCustomObject]@{ document_type = $Document; status = 'NO_RESULT'; process_exit_code = $Process.ExitCode })
		Write-Host ('NO_RESULT ' + $Document + ' exit=' + $Process.ExitCode)
		continue
	}
	$Result = Get-Content -LiteralPath $ResultPath -Raw | ConvertFrom-Json
	$Result | Add-Member -NotePropertyName process_exit_code -NotePropertyValue $Process.ExitCode -Force
	$Results.Add($Result)
	Write-Host (($Document + ' status=' + $Result.status + ' before=' + $Result.document_number_before + ' after=' + $Result.document_number_after + ' rejected=' + $Result.blank_save_rejected + ' persisted=' + $Result.document_persisted + ' message=' + $Result.validation_message_text + ' error=' + $Result.error).Trim())
}

$Aggregate = [ordered]@{
	case_count = $Results.Count
	pass_count = @($Results | Where-Object status -eq 'PASS').Count
	fail_count = @($Results | Where-Object status -ne 'PASS').Count
	cases = $Results.ToArray()
}
$AggregatePath = Join-Path $OutputDirectory 'ui-required-field-probe-matrix.json'
[System.IO.File]::WriteAllText($AggregatePath, ($Aggregate | ConvertTo-Json -Depth 12), [System.Text.UTF8Encoding]::new($false))
Write-Host ('RESULT ' + $AggregatePath)
