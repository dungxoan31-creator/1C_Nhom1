param(
    [string]$OutputPath = "C:\Users\Dung\Documents\1C_Enterprise\VinSmart_Future_AR_AP_Full.dt",
    [string]$User = "Admin",
    [string]$Password = ""
)

$exePath = "C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe"
$ibPath = "C:\Users\Dung\Documents\1C_Enterprise\Infobase"
$logPath = "dump_last.log"

Remove-Item $logPath -Force -ErrorAction SilentlyContinue

$userArg = ""
if ($User) {
    $userArg = "/N `"$User`""
    if ($Password) {
        $userArg += " /P `"$Password`""
    }
}

Write-Host "Xuat du lieu Infobase sang file DT: $OutputPath ..."
$cmd = "DESIGNER /F `"$ibPath`" $userArg /DumpIB `"$OutputPath`" /DisableStartupDialogs /DisableStartupMessages /OUT `"$logPath`""
$p = Start-Process -FilePath $exePath -ArgumentList $cmd -PassThru -Wait

Write-Host ("Ma thoat: " + $p.ExitCode)
if (Test-Path $logPath) { Get-Content $logPath }

if (Test-Path $OutputPath) {
    $item = Get-Item $OutputPath
    Write-Host "Tao file DT thanh cong! Dung luong: $([math]::round($item.Length/1MB, 2)) MB ($($item.Length) bytes)"
} else {
    Write-Host "Loi: Khong tim thay file DT."
}
