param(
    [string]$SourceDT = "C:\Users\Dung\Documents\1C_Enterprise\VinSmart_Future_AR_AP_Test.dt",
    [string]$BackupDT = "C:\Users\Dung\Documents\1C_Enterprise\VinSmart_Future_AR_AP_Test.ORIGINAL.dt",
    [string]$TargetIB = "C:\Users\Dung\Documents\1C_Enterprise\Infobase_FullData"
)

$exe = "C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe"

Write-Host "1. Sao lưu file DT gốc thành bản sao an toàn..."
Copy-Item -Path $SourceDT -Destination $BackupDT -Force
Write-Host "Đã tạo bản sao an toàn tại: $BackupDT"

Write-Host "2. Khởi tạo thư mục CSDL thử nghiệm cô lập: $TargetIB ..."
if (Test-Path $TargetIB) {
    Remove-Item -Path $TargetIB -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Path $TargetIB -Force | Out-Null

Write-Host "3. Khởi tạo Infobase rỗng..."
$pCreate = Start-Process -FilePath $exe -ArgumentList "CREATEINFOBASE", "File=`"$TargetIB`"", "/DisableStartupDialogs", "/DisableStartupMessages" -PassThru -Wait
Write-Host ("CreateIB ExitCode: " + $pCreate.ExitCode)

Write-Host "4. Nạp dữ liệu từ bản sao vào CSDL thử nghiệm..."
$logRestore = "restore_env.log"
$argRestore = "DESIGNER /F `"$TargetIB`" /RestoreIB `"$BackupDT`" /DisableStartupDialogs /DisableStartupMessages /OUT `"$logRestore`""
$pRestore = Start-Process -FilePath $exe -ArgumentList $argRestore -PassThru -Wait
Write-Host ("RestoreIB ExitCode: " + $pRestore.ExitCode)

if (Test-Path $logRestore) {
    Get-Content $logRestore
    Remove-Item $logRestore -Force -ErrorAction SilentlyContinue
}

Write-Host "Hoàn tất chuẩn bị môi trường thử nghiệm cô lập!"
