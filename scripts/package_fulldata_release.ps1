$exe = "C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe"
$ib = "C:\Users\Dung\Documents\1C_Enterprise\Infobase_FullData"
$outDt = "C:\Users\Dung\Documents\1C_Enterprise\VinSmart_Future_AR_AP_Full.dt"
$logPath = "C:\Users\Dung\Documents\1C_Enterprise\dump_fulldata.log"

Remove-Item $logPath -Force -ErrorAction SilentlyContinue

Write-Host "Bắt đầu đóng gói CSDL Infobase_FullData ra file: $outDt..."
$p = Start-Process -FilePath $exe -ArgumentList "DESIGNER", "/F", $ib, "/N", "Admin", "/DumpIB", "`"$outDt`"", "/DisableStartupDialogs", "/DisableStartupMessages", "/OUT", "`"$logPath`"" -PassThru -Wait

Write-Host ("DumpIB ExitCode: " + $p.ExitCode)
if (Test-Path $logPath) {
    Get-Content $logPath
}

if (Test-Path $outDt) {
    $sizeMb = (Get-Item $outDt).Length / 1MB
    Write-Host ("Đóng gói thành công file: " + $outDt + " (" + [Math]::Round($sizeMb, 2) + " MB)")
} else {
    Write-Error "Không tìm thấy file DT sau khi đóng gói!"
}
