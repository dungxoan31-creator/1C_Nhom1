param(
    [Parameter(Mandatory = $true)][string]$IBPath,
    [string]$User = "Admin",
    [string]$ExePath = "",
    [double]$Timeout = 90,
    [string]$PythonPath = "python",
    [switch]$Smoke,
    [switch]$BoundedWorkflow,
    [switch]$MetadataOnly
)

$ErrorActionPreference = "Stop"
try {
    $runtimeArgs = @("-B", (Join-Path $PSScriptRoot "seed_workflow.py"), "clean",
        "--ib-path", $IBPath, "--user", $User, "--timeout", [string]$Timeout)
    if ($ExePath) { $runtimeArgs += @("--exe-path", $ExePath) }
    if ($Smoke) { $runtimeArgs += "--smoke" }
    & $PythonPath @runtimeArgs
    exit $LASTEXITCODE
} catch {
    Write-Error ("FAIL: " + $_.Exception.Message) -ErrorAction Continue
    exit 1
}
