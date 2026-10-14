param(
    [Parameter(Mandatory = $true)][string]$IBPath,
    [string]$User = "Admin",
    [string]$ExePath = "",
    [double]$Timeout = 90,
    [string]$PythonPath = "python"
)

$ErrorActionPreference = "Stop"
try {
    $runtimeArgs = @("-B", (Join-Path $PSScriptRoot "onec_runtime.py"), "RunUnitTests",
        "--ib-path", $IBPath, "--user", $User, "--timeout", [string]$Timeout)
    if ($ExePath) { $runtimeArgs += @("--exe-path", $ExePath) }
    & $PythonPath @runtimeArgs
    exit $LASTEXITCODE
} catch {
    Write-Error ("FAIL: " + $_.Exception.Message) -ErrorAction Continue
    exit 1
}
