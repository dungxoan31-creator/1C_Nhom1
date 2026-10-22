[CmdletBinding()]
param(
	[Parameter(Mandatory = $true)][string]$Infobase,
	[string]$OneCExe = 'C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe',
	[string]$Configuration,
	[string]$LogPath = (Join-Path $env:TEMP 'finance-config-compile.log')
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($Configuration)) {
	$Configuration = Join-Path (Split-Path -Parent $PSScriptRoot) 'Configuration'
}
$Arguments = 'DESIGNER /F"' + $Infobase + '" /NAdmin /LoadConfigFromFiles "' + $Configuration + '" /UpdateDBCfg /DisableStartupMessages /Out"' + $LogPath + '"'
$StartInfo = New-Object System.Diagnostics.ProcessStartInfo
$StartInfo.FileName = $OneCExe
$StartInfo.Arguments = $Arguments
$StartInfo.CreateNoWindow = $true
$StartInfo.UseShellExecute = $false
$Process = [System.Diagnostics.Process]::Start($StartInfo)
if (-not $Process.WaitForExit(900000)) {
	$Process.Kill()
	throw "Configuration update timed out. Log: $LogPath"
}
$ExitCode = $Process.ExitCode
Write-Host ('Designer exit=' + $ExitCode)
if (Test-Path -LiteralPath $LogPath) { Get-Content -LiteralPath $LogPath | Select-Object -Last 60 }
if ($ExitCode -ne 0 -or -not (Test-Path -LiteralPath $LogPath) -or -not (Select-String -LiteralPath $LogPath -Pattern 'Configuration successfully updated' -Quiet)) {
	throw "Configuration compile/update failed. Log: $LogPath"
}
Write-Host 'PASS Designer configuration compile/update.'
