# Verify CheckConfig before and after UpdateDBCfg
param(
    [string]$SrcDir = ".\src",
    [string]$WorkDir = ".\build_check_tmp",
    [string]$ExePath = "C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe"
)

$ib  = Join-Path $WorkDir "IB"
$out = Join-Path $WorkDir "logs"
if (Test-Path $ib) { Remove-Item $ib -Recurse -Force }
New-Item -ItemType Directory -Force -Path $ib, $out | Out-Null

function Run-Step([string]$Step, [string]$ArgStr) {
    $log = Join-Path $out "$Step.log"
    Remove-Item $log -Force -ErrorAction SilentlyContinue
    $full = "$ArgStr /DisableStartupDialogs /DisableStartupMessages /Out `"$log`""
    Write-Host "--- $Step ..."
    $p = Start-Process -FilePath $ExePath -ArgumentList $full -PassThru -Wait -NoNewWindow
    Write-Host ("    Ma thoat: " + $p.ExitCode)
    if (Test-Path $log) {
        Get-Content $log | ForEach-Object { Write-Host "    | $_" }
    }
    return $p.ExitCode
}

Write-Host "=== KIEM TRA BIEN DICH VA TOAN VEN CAU HINH 1C ==="

# 1. Tao Infobase rong
$c1 = Run-Step "01_create" "CREATEINFOBASE File=`"$ib`""
if ($c1 -ne 0) { exit 1 }

# 2. Nap ma nguon src/
$c2 = Run-Step "02_load_src" "DESIGNER /F `"$ib`" /LoadConfigFromFiles `"$SrcDir`""
if ($c2 -ne 0) { exit 2 }

# 3. CheckConfig lan 1 (Truoc khi update DB)
$c3 = Run-Step "03_check_config_1" "DESIGNER /F `"$ib`" /CheckConfig -ConfigLogIntegrity -IncorrectReferences -ThinClient -Server -ExternalConnection -HandlersExistence"

# 4. Update DB
$c4 = Run-Step "04_update_db" "DESIGNER /F `"$ib`" /UpdateDBCfg"
if ($c4 -ne 0) { exit 4 }

# 5. CheckConfig lan 2 (Sau khi update DB)
$c5 = Run-Step "05_check_config_2" "DESIGNER /F `"$ib`" /CheckConfig -ConfigLogIntegrity -IncorrectReferences -ThinClient -Server -ExternalConnection -HandlersExistence"

Remove-Item $ib -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "=== TONG KET: CheckConfig lan 1: $c3 | UpdateDB: $c4 | CheckConfig lan 2: $c5 ==="
if ($c3 -le 101 -and $c4 -eq 0 -and $c5 -le 101) {
    Write-Host ">>> XAC NHAN: 1C_CHECKCONFIG_PASS_ZERO_ERROR"
    exit 0
} else {
    Write-Host ">>> THAT BAI: Co loi bien dich hoac tham chieu"
    exit 5
}
