param(
    [string]$IBPath = "C:\Users\Dung\Documents\1C_Enterprise\Infobase_FullData",
    [string]$AdminUser = "Admin",
    [string]$AdminPassword = ""
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinUserSetupUtil {
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@ -ErrorAction SilentlyContinue

$exe = "C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe"
$setupLog = "C:\Users\Dung\Documents\1C_Enterprise\setup_sample_users.log"
$verifyLog = "C:\Users\Dung\Documents\1C_Enterprise\verify_sample_users.log"

Remove-Item $setupLog -Force -ErrorAction SilentlyContinue
Remove-Item $verifyLog -Force -ErrorAction SilentlyContinue

function Invoke-1CWithPopupHandle {
    param(
        [string[]]$ArgumentList,
        [string]$TargetLog
    )
    $proc = Start-Process -FilePath $exe -ArgumentList $ArgumentList -PassThru
    $wshell = New-Object -ComObject WScript.Shell

    for ($i = 0; $i -lt 30; $i++) {
        Start-Sleep -Milliseconds 500
        if ($proc.HasExited) { break }
        
        $proc.Refresh()
        if ($proc.MainWindowHandle -ne [IntPtr]::Zero) {
            [WinUserSetupUtil]::SetForegroundWindow($proc.MainWindowHandle) | Out-Null
            $wshell.SendKeys("{ENTER}")
        } else {
            $wshell.AppActivate($proc.Id) | Out-Null
            $wshell.SendKeys("{ENTER}")
        }
        
        if ($TargetLog -and (Test-Path $TargetLog)) {
            Start-Sleep -Milliseconds 500
            break
        }
    }
    
    if (-not $proc.HasExited) {
        $proc.WaitForExit(10000) | Out-Null
    }
    return $proc.ExitCode
}

Write-Host "=========================================================="
Write-Host "  VINSMART FUTURE - THIET LAP NGUOI DUNG & PHAN QUYEN     "
Write-Host "=========================================================="
Write-Host "Infobase: $IBPath"
Write-Host "Admin User: $AdminUser"

# 1. Chay khoi tao 8 nguoi dung mau + Admin
Write-Host "`n1. Khoi tao 8 nguoi dung nghiep vu qua InfoBaseUsers API..."
$adminArgs = @("ENTERPRISE", "/F", $IBPath, "/N", $AdminUser)
if ($AdminPassword) {
    $adminArgs += @("/P", $AdminPassword)
}
$adminArgs += @("/C", "SetupSampleUsers", "/DisableStartupDialogs", "/DisableStartupMessages")

$exit1 = Invoke-1CWithPopupHandle -ArgumentList $adminArgs -TargetLog $setupLog
Write-Host ("   Exit code thiet lap: " + $exit1)

if (Test-Path $setupLog) {
    Write-Host "`n--- KET QUA KHOI TAO NGUOI DUNG ---"
    Get-Content $setupLog
    Write-Host "------------------------------------`n"
} else {
    Write-Warning "Khong tim thay file log setup_sample_users.log!"
}

# 2. Xac thuc danh sach nguoi dung da duoc tao day du
Write-Host "2. Kiem tra xac nhan danh sach nguoi dung va Role..."
$verifyArgs = @("ENTERPRISE", "/F", $IBPath, "/N", $AdminUser)
if ($AdminPassword) {
    $verifyArgs += @("/P", $AdminPassword)
}
$verifyArgs += @("/C", "VerifySampleUsers", "/DisableStartupDialogs", "/DisableStartupMessages")

$exit2 = Invoke-1CWithPopupHandle -ArgumentList $verifyArgs -TargetLog $verifyLog
Write-Host ("   Exit code kiem tra: " + $exit2)

if (Test-Path $verifyLog) {
    Write-Host "`n--- KET QUA XAC NHAN NGUOI DUNG ---"
    Get-Content $verifyLog
    Write-Host "------------------------------------`n"
} else {
    Write-Warning "Khong tim thay file log verify_sample_users.log!"
}

$verifyContent = ""
if (Test-Path $verifyLog) {
    $verifyContent = Get-Content $verifyLog -Raw
}

if ($exit1 -eq 0 -and $exit2 -eq 0 -and ($verifyContent -like "*100% NGUOI DUNG VA ROLE HOP LE CHUAN XAC*")) {
    Write-Host "THIET LAP THANH CONG TOAN BO 8 NGUOI DUNG VA MA TRAN PHAN QUYEN!" -ForegroundColor Green
} else {
    Write-Error "CO LOI XAY RA TRONG QUA TRINH THIET LAP NGUOI DUNG!"
}
