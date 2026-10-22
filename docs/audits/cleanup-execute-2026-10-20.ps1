$ErrorActionPreference = 'Stop'
$workspace = [System.IO.Path]::GetFullPath((Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path)
$workspacePrefix = $workspace.TrimEnd('\') + '\'
$dtWorking = Join-Path $workspace 'VSF_Finance_E2E\dt_working'
$audit = Join-Path $workspace 'docs\audits'

$sourceComparison = Join-Path $workspace 'VSF_Finance_E2E\cleanup_review_20261020\snapshot_comparison.json'
$savedComparison = Join-Path $audit 'snapshot_comparison-2026-10-20.json'
if (-not (Test-Path -LiteralPath $sourceComparison)) { throw 'Missing comparison evidence; cleanup stopped.' }
Copy-Item -LiteralPath $sourceComparison -Destination $savedComparison -Force

$preMockup = Join-Path $workspace 'VinSmart_Future_AdminFull_v5_SuaFont_pre_mockup_20261020.dt'
$preMockupAtomic = Join-Path $workspace 'VinSmart_Future_AdminFull_v5_SuaFont_pre_mockup_atomic_20261020.dt'
$current = Join-Path $workspace 'VinSmart_Future_AdminFull_v5_SuaFont.dt'
$baseline = Join-Path $workspace 'VinSmart_Future_AdminFull_v5_SuaFont_backup_before_e2e_20261020.dt'
$atomic = Join-Path $workspace 'VinSmart_Future_AdminFull_v5_SuaFont_atomic_backup_20261020.dt'
if ((Get-FileHash -LiteralPath $preMockup -Algorithm SHA256).Hash -ne (Get-FileHash -LiteralPath $preMockupAtomic -Algorithm SHA256).Hash) { throw 'Pre-mockup DT pair differ; cleanup stopped.' }
if ((Get-FileHash -LiteralPath $baseline -Algorithm SHA256).Hash -ne (Get-FileHash -LiteralPath $atomic -Algorithm SHA256).Hash) { throw 'Baseline/atomic DT differ; cleanup stopped.' }
if (-not (Test-Path -LiteralPath (Join-Path $workspace 'VSF_Finance_E2E\demo_seeded_20261020.dt'))) { throw 'Missing demo backup; cleanup stopped.' }

$keepWorking = @('restore_final_batch_query_20261020', 'roundtrip_final_batch_query_20261020', 'roundtrip_final_batch_query_20261020.log')
$targets = @(
    $preMockupAtomic,
    $atomic,
    (Join-Path $workspace '1Cv8.1CD.cfl'),
    (Join-Path $workspace 'docs\audits\encoding-probe.txt'),
    (Join-Path $workspace 'Configuration_pre_verified_branches_20261020_155425'),
    (Join-Path $workspace 'VSF_Finance_E2E\guide_work_20261020\infobase'),
    (Join-Path $workspace 'VSF_Finance_E2E\cleanup_review_20261020')
)
$targets += @(Get-ChildItem -LiteralPath $dtWorking -Force | Where-Object { $_.Name -notin $keepWorking } | ForEach-Object FullName)

# Full-path and reparse-point validation occurs before any deletion.
$manifest = @()
foreach ($target in $targets) {
    if (-not (Test-Path -LiteralPath $target)) { throw "Missing intended target: $target" }
    $full = [System.IO.Path]::GetFullPath($target)
    if (-not $full.StartsWith($workspacePrefix, [System.StringComparison]::OrdinalIgnoreCase)) { throw "Target escapes workspace: $full" }
    if ($full -eq $workspace) { throw 'Refusing to remove workspace root.' }
    $item = Get-Item -LiteralPath $full -Force
    if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) { throw "Refusing reparse target: $full" }
    if ($item.PSIsContainer) {
        $links = @(Get-ChildItem -LiteralPath $full -Recurse -Force -Attributes ReparsePoint -ErrorAction Stop)
        if ($links.Count -gt 0) { throw "Refusing directory with reparse child: $full" }
        $bytes = (Get-ChildItem -LiteralPath $full -Recurse -File -Force | Measure-Object Length -Sum).Sum
    } else { $bytes = $item.Length }
    $manifest += [pscustomobject]@{ Path = $full.Substring($workspacePrefix.Length); Type = $(if ($item.PSIsContainer) { 'Directory' } else { 'File' }); Bytes = [long]$bytes }
}

$manifestPath = Join-Path $audit 'cleanup-manifest-2026-10-20.json'
$manifest | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $manifestPath -Encoding UTF8
$sum = ($manifest | Measure-Object Bytes -Sum).Sum
Write-Output ("Validated {0} targets; {1} bytes to remove." -f $manifest.Count, $sum)

foreach ($target in $targets) {
    $item = Get-Item -LiteralPath $target -Force
    if ($item.PSIsContainer) { Remove-Item -LiteralPath $item.FullName -Recurse -Force -ErrorAction Stop }
    else { Remove-Item -LiteralPath $item.FullName -Force -ErrorAction Stop }
}

foreach ($target in $targets) { if (Test-Path -LiteralPath $target) { throw "Target still exists: $target" } }
foreach ($required in @($current, $baseline, (Join-Path $workspace 'VinSmart_Future_AdminFull_v5_SuaFont_before_final_replace_20261020.dt'), (Join-Path $workspace 'VSF_Finance_E2E\Configuration\Configuration.xml'), (Join-Path $workspace 'VSF_Finance_E2E\mockup_work_20261020\infobase\1Cv8.1CD'))) {
    if (-not (Test-Path -LiteralPath $required)) { throw "Required file missing after cleanup: $required" }
}
Write-Output ("Removed {0} targets; {1} bytes. Manifest: {2}" -f $manifest.Count, $sum, $manifestPath)
