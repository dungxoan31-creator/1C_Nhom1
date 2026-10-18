param(
    [Parameter(Mandatory = $true)][string]$IBPath,
    [string]$SourcePath = "",
    [string]$User = "Admin",
    [string]$Password = "",
    [string]$ExePath = "",
    [double]$Timeout = 90,
    [string]$PythonPath = "python"
)

$ErrorActionPreference = "Stop"
try {
    $runtimeArgs = @("-B", (Join-Path $PSScriptRoot "onec_runtime.py"), "update-db",
        "--ib-path", $IBPath,
        "--user", $User, "--timeout", [string]$Timeout)
    if ($SourcePath) { $runtimeArgs += @("--source-path", $SourcePath) }
    if ($Password) { $runtimeArgs += @("--password", $Password) }
    if ($ExePath) { $runtimeArgs += @("--exe-path", $ExePath) }
    & $PythonPath @runtimeArgs
    exit $LASTEXITCODE
} catch {
    Write-Error ("FAIL: " + $_.Exception.Message) -ErrorAction Continue
    exit 1
}
