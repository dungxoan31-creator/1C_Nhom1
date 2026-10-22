[CmdletBinding()]
param(
	[Parameter(Mandatory = $true)][string]$Infobase,
	[Parameter(Mandatory = $true)][string]$Phase,
	[Parameter(Mandatory = $true)][string]$User,
	[Parameter(Mandatory = $true)][string]$RunId,
	[Parameter(Mandatory = $true)][string]$ResultPath,
	[string]$ExtraParameters = '',
	[string]$OneCExe = 'C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe'
)

$ErrorActionPreference = 'Stop'
$LogPath = [System.IO.Path]::ChangeExtension($ResultPath, '.log')
$ExecutionResultPath = $ResultPath
$StagedResultPath = ''
if ($ResultPath -match '\s') {
	$StagedResultPath = Join-Path $env:TEMP ('finance-phase-output-' + [Guid]::NewGuid().ToString('N') + '.json')
	$ExecutionResultPath = $StagedResultPath
}
$Arguments = 'ENTERPRISE /F"' + $Infobase + '" /N' + $User + ' /CRunFinanceE2E;' + $Phase + ';' + $RunId + ';' + $ExecutionResultPath + $ExtraParameters + ' /DisableStartupMessages /Out"' + $LogPath + '"'
$StartInfo = New-Object System.Diagnostics.ProcessStartInfo
$StartInfo.FileName = $OneCExe
$StartInfo.Arguments = $Arguments
$StartInfo.CreateNoWindow = $true
$StartInfo.UseShellExecute = $false
$Process = [System.Diagnostics.Process]::Start($StartInfo)
if (-not $Process.WaitForExit(900000)) {
	$Process.Kill()
	throw "Finance E2E phase $Phase timed out. Log: $LogPath"
}
if ($StagedResultPath -and (Test-Path -LiteralPath $StagedResultPath)) {
	Copy-Item -LiteralPath $StagedResultPath -Destination $ResultPath -Force
	Remove-Item -LiteralPath $StagedResultPath -Force
}
if (-not (Test-Path -LiteralPath $ResultPath)) { throw "Finance E2E phase $Phase produced no result. Log: $LogPath" }
$Result = Get-Content -LiteralPath $ResultPath -Raw | ConvertFrom-Json
if ($Process.ExitCode -ne 0 -or $Result.status -ne 'PASS') {
	throw "Finance E2E phase $Phase failed: $($Result.error) Log: $LogPath"
}
$Result | ConvertTo-Json -Depth 12
Write-Host ('PASS ' + $Phase + ' (' + $User + ')')
