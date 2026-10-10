param(
    [string]$OutputPath = "C:\Users\Dung\Documents\1C_Enterprise\VinSmart_Future_AR_AP_Test.dt"
)

$exePath = "C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe"
$ibPath = "C:\Users\Dung\Documents\1C_Enterprise\Infobase"
$logPath = "dump_last.log"

Remove-Item $logPath -Force -ErrorAction SilentlyContinue

Write-Host "Xuat du lieu Infobase sang file DT: $OutputPath ..."
$p = Start-Process -FilePath $exePath -ArgumentList "DESIGNER", "/F", $ibPath, "/DumpIB", $OutputPath, "/DisableStartupDialogs", "/DisableStartupMessages", "/OUT", $logPath -PassThru -Wait

Write-Host ("Ma thoat: " + $p.ExitCode)
if (Test-Path $logPath) { Get-Content $logPath }

if (Test-Path $OutputPath) {
    $item = Get-Item $OutputPath
    Write-Host "Tao file DT thanh cong! Dung luong: $([math]::round($item.Length/1MB, 2)) MB ($($item.Length) bytes)"
} else {
    Write-Host "Loi: Khong tim thay file DT."
}
