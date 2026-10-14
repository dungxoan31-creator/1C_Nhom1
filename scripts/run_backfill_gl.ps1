# PowerShell script to execute GL Analytic Keys backfill on 1C runtime
$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
$1CExe = "C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe"
$IB = Join-Path $Root "Infobase_FullData"

Stop-Process -Name "1cv8*" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

Write-Host "Executing BackfillGLAnalyticKeys in 1C..." -ForegroundColor Cyan

# Try with password first, then without password if needed
$proc = Start-Process -FilePath $1CExe -ArgumentList "ENTERPRISE /F `"$IB`" /N `"Admin`" /P `"Vsf@2026!Secure`" /C `"BackfillGLAnalyticKeys`" /DisableStartupDialogs /DisableStartupMessages" -Wait -PassThru -NoNewWindow
if ($proc.ExitCode -ne 0) {
    Write-Host "Retrying with empty password..." -ForegroundColor Yellow
    $proc = Start-Process -FilePath $1CExe -ArgumentList "ENTERPRISE /F `"$IB`" /N `"Admin`" /C `"BackfillGLAnalyticKeys`" /DisableStartupDialogs /DisableStartupMessages" -Wait -PassThru -NoNewWindow
}

Write-Host "Backfill process finished with ExitCode $($proc.ExitCode)." -ForegroundColor Green
