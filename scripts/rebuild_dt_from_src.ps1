# Dung lai file .dt tu code trong src/ + du lieu cua mot file .dt co san.
# Dung khi may ban dung phien ban 1C khac (vd 8.3.22) va khong nap duoc file .dt da build san.
#
# Cac buoc: tao infobase trong (thu muc tam) -> RestoreIB tu .dt goc -> LoadConfigFromFiles src
#           -> CheckConfig -> UpdateDBCfg -> DumpIB ra .dt moi.
# KHONG dung toi Infobase/ hay Infobase_FullData. Moi buoc ghi log vao build_out\<buoc>.log.
#
# Vi du:
#   powershell -ExecutionPolicy Bypass -File scripts\rebuild_dt_from_src.ps1 `
#       -SourceDt "D:\backup\VinSmart_Future_AR_AP_Full_OLD.dt" -OutputDt ".\VinSmart_Future_AR_AP_Full.dt"
param(
    [Parameter(Mandatory = $true)][string]$SourceDt,
    [string]$OutputDt = ".\VinSmart_Future_AR_AP_Full.dt",
    [string]$SrcDir = ".\src",
    [string]$WorkDir = ".\build_tmp",
    [string]$User = "Admin",
    [string]$Password = "",
    [string]$ExePath = $env:ONEC_EXE_PATH
)

if (-not $ExePath) { $ExePath = "C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe" }
if (-not (Test-Path $ExePath)) { Write-Host "Loi: khong tim thay 1C tai $ExePath (dung -ExePath)"; exit 2 }
if (-not (Test-Path $SourceDt)) { Write-Host "Loi: khong tim thay file .dt goc $SourceDt"; exit 1 }
if (-not (Test-Path (Join-Path $SrcDir "Configuration.xml"))) { Write-Host "Loi: $SrcDir khong chua Configuration.xml"; exit 1 }

$SourceDt = [System.IO.Path]::GetFullPath($SourceDt)
$OutputDt = [System.IO.Path]::GetFullPath($OutputDt)
$SrcDir   = [System.IO.Path]::GetFullPath($SrcDir)
$WorkDir  = [System.IO.Path]::GetFullPath($WorkDir)
if ($SourceDt -ieq $OutputDt) { Write-Host "Loi: -OutputDt phai khac -SourceDt"; exit 1 }

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
    Write-Host ("    ma thoat: " + $p.ExitCode)
    if (Test-Path $log) { Get-Content $log | ForEach-Object { Write-Host "    | $_" } }
    return $p.ExitCode
}

$auth = "/N `"$User`""
if ($Password -ne "") { $auth += " /P `"$Password`"" }

if ((Run-Step "01_create"  "CREATEINFOBASE File=`"$ib`"") -ne 0) { exit 3 }
# Infobase moi tao chua co user nen buoc restore khong truyen /N
if ((Run-Step "02_restore" "DESIGNER /F `"$ib`" /RestoreIB `"$SourceDt`"") -ne 0) { exit 4 }
if ((Run-Step "03_load"    "DESIGNER /F `"$ib`" $auth /LoadConfigFromFiles `"$SrcDir`"") -ne 0) { exit 5 }
$check = Run-Step "04_check" "DESIGNER /F `"$ib`" $auth /CheckConfig -ConfigLogIntegrity -IncorrectReferences -ThinClient -Server -ExternalConnection -HandlersExistence"
if ((Run-Step "05_update"  "DESIGNER /F `"$ib`" $auth /UpdateDBCfg") -ne 0) { exit 6 }
if ((Run-Step "06_dump"    "DESIGNER /F `"$ib`" $auth /DumpIB `"$OutputDt`"") -ne 0) { exit 7 }

Write-Host "=== XONG: $OutputDt | CheckConfig ma thoat: $check (0 = sach; 101 = co canh bao/loi, xem logs\04_check.log) ==="
exit 0
