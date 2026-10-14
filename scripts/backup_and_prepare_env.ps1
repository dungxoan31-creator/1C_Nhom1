param(
    [Parameter(Mandatory = $true)][string]$SourceDT,
    [Alias("TargetPath")][string]$TargetIB = "",
    [string]$RunId = "",
    [string]$ExePath = "",
    [double]$Timeout = 90,
    [string]$PythonPath = "python"
)

# Restore directly from SourceDT into a new UAT clone; never overwrite a backup.
# Omitting TargetIB chooses a new UUID run directory under workspace/scratch/uat.
$ErrorActionPreference = "Stop"
try {
    $cloneArgs = @("-B", (Join-Path $PSScriptRoot "create_uat_clone.py"),
        "--source-dt", $SourceDT, "--timeout", [string]$Timeout)
    if ($TargetIB) { $cloneArgs += @("--target-path", $TargetIB) }
    if ($RunId) { $cloneArgs += @("--run-id", $RunId) }
    if ($ExePath) { $cloneArgs += @("--exe-path", $ExePath) }
    & $PythonPath @cloneArgs
    exit $LASTEXITCODE
} catch {
    Write-Error ("FAIL: " + $_.Exception.Message) -ErrorAction Continue
    exit 1
}
