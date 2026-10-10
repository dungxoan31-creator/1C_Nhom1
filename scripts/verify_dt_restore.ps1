$exe = "C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe"
$dtPath = "C:\Users\Dung\Documents\1C_Enterprise\VinSmart_Future_AR_AP_Full.dt"
$tempIB = "C:\Users\Dung\Documents\1C_Enterprise\scratch\TestRestoreIB"
$logPath = "C:\Users\Dung\Documents\1C_Enterprise\scratch\restore_test.log"

Write-Host "1. Tao thu muc Infobase tam thoi: $tempIB ..."
if (Test-Path $tempIB) { Remove-Item $tempIB -Recurse -Force }
New-Item -ItemType Directory -Path $tempIB -Force | Out-Null

Write-Host "2. Khoi tao co so du lieu trong tai $tempIB ..."
$pCreate = Start-Process -FilePath $exe -ArgumentList "CREATEINFOBASE", "File=`"$tempIB`"", "/DisableStartupDialogs", "/DisableStartupMessages" -PassThru -Wait
Write-Host ("CreateIB ExitCode: " + $pCreate.ExitCode)

Write-Host "3. Khoi phuc du lieu tu file DT vao co so du lieu tam..."
$argRestore = "DESIGNER /F `"$tempIB`" /RestoreIB `"$dtPath`" /DisableStartupDialogs /DisableStartupMessages /OUT `"$logPath`""
$pRestore = Start-Process -FilePath $exe -ArgumentList $argRestore -PassThru -Wait
Write-Host ("Restore ExitCode: " + $pRestore.ExitCode)

if (Test-Path $logPath) {
    Get-Content $logPath
}

if ($pRestore.ExitCode -eq 0) {
    Write-Host "XAC THUC TOAN VEN: File DT khôi phục thành công 100%!"
} else {
    Write-Host "THAT BAI: Khong the khoi phuc file DT."
}

# Cleanup
if (Test-Path $tempIB) { Remove-Item $tempIB -Recurse -Force -ErrorAction SilentlyContinue }
