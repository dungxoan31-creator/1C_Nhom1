# ==============================================================================
# SCRIPT XUAT VA DONG BO DU LIEU 4 BAO CAO QUAN TRI CHUYEN SAU (VSF)
# Direction 1: Nghiem thu truc quan 4 Bao cao Quan tri Chuyen sau
# ==============================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$exePath = "C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe"
$ibPath  = "C:\Users\Dung\Documents\1C_Enterprise\Infobase_FullData"
$jsonPath = "C:\Users\Dung\Documents\1C_Enterprise\docs\superpowers\reports\executive_reports_data.json"

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "    VINSMART FUTURE - XUAT & DONG BO 4 BAO CAO QUAN TRI CHUYEN SAU" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

if (-not (Test-Path $exePath)) {
    Write-Error "Khong tim thay 1C binary tai: $exePath"
    exit 1
}

if (-not (Test-Path $ibPath)) {
    Write-Error "Khong tim thay Infobase tai: $ibPath"
    exit 1
}

Write-Host "[1/3] Khoi dong 1C Enterprise de xuat du lieu 4 bao cao quan tri..." -ForegroundColor Yellow
$proc = Start-Process -FilePath $exePath -ArgumentList "ENTERPRISE", "/F", "`"$ibPath`"", "/N", "Admin", "/C", "ExportExecutiveReports", "/DisableStartupDialogs", "/DisableStartupMessages" -PassThru -Wait

if ($proc.ExitCode -ne 0) {
    Write-Error "1C Enterprise thoat voi loi ma: $($proc.ExitCode)"
    exit $proc.ExitCode
}

Write-Host "[2/3] Kiem tra ket qua xuat JSON..." -ForegroundColor Yellow
if (-not (Test-Path $jsonPath)) {
    Write-Error "Khong tim thay file JSON ket qua tai: $jsonPath"
    exit 1
}

$fileInfo = Get-Item $jsonPath
Write-Host "  -> File JSON hop le: $($fileInfo.FullName)" -ForegroundColor Green
Write-Host "  -> Dung luong: $([math]::Round($fileInfo.Length / 1KB, 2)) KB" -ForegroundColor Green
Write-Host "  -> Thoi gian cap nhat: $($fileInfo.LastWriteTime)" -ForegroundColor Green

Write-Host "[3/3] Doc va hien thi Dashboard Tom tat 4 Bao cao Quan tri:" -ForegroundColor Yellow
Write-Host "-----------------------------------------------------------------" -ForegroundColor Gray

python scripts/display_executive_dashboard.py

Write-Host "Xuat bao cao va hien thi Dashboard hoan tat 100%!" -ForegroundColor Green
