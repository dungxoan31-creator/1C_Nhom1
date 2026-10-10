param(
    [string]$InputPath = "C:\Users\Dung\Documents\1C_Enterprise\VinSmart_Future_AR_AP_Full.dt",
    [string]$User = "Admin",
    [string]$Password = ""
)

$exePath = "C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe"
$ibPath = "C:\Users\Dung\Documents\1C_Enterprise\Infobase"
$logPath = "restore_last.log"

if (-not (Test-Path $InputPath)) {
    Write-Host "Loi: Khong tim thay file DT tai $InputPath"
    exit 1
}

Remove-Item $logPath -Force -ErrorAction SilentlyContinue

$argStr = "DESIGNER /F `"$ibPath`" /N `"$User`""
if ($Password -ne "") {
    $argStr += " /P `"$Password`""
}
$argStr += " /RestoreIB `"$InputPath`" /DisableStartupDialogs /DisableStartupMessages /OUT `"$logPath`""

Write-Host "Nap du lieu Infobase tu file DT: $InputPath (User: $User)..."
$p = Start-Process -FilePath $exePath -ArgumentList $argStr -PassThru -Wait

Write-Host ("Ma thoat: " + $p.ExitCode)
if (Test-Path $logPath) { Get-Content $logPath }
