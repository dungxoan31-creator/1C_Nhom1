Add-Type -AssemblyName System.Windows.Forms
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinVerifyFullUtil {
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@

$exe = "C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe"
$ib = "C:\Users\Dung\Documents\1C_Enterprise\Infobase"
$logPath = "C:\Users\Dung\Documents\1C_Enterprise\verify_full_test_data.log"

Remove-Item $logPath -Force -ErrorAction SilentlyContinue

Write-Host "Khoi dong 1C Enterprise de xac minh toan ven du lieu..."
$proc = Start-Process -FilePath $exe -ArgumentList "ENTERPRISE", "/F", $ib, "/N", "Admin", "/C", "VerifyFullTestData", "/DisableStartupDialogs", "/DisableStartupMessages" -PassThru

$wshell = New-Object -ComObject WScript.Shell

for ($i = 0; $i -lt 40; $i++) {
    Start-Sleep -Milliseconds 500
    if ($proc.HasExited) {
        Write-Host "Tien trinh 1C da ket thuc!"
        break
    }
    
    $proc.Refresh()
    if ($proc.MainWindowHandle -ne [IntPtr]::Zero) {
        [WinVerifyFullUtil]::SetForegroundWindow($proc.MainWindowHandle) | Out-Null
        $wshell.SendKeys("{ENTER}")
    } else {
        $wshell.AppActivate($proc.Id) | Out-Null
        $wshell.SendKeys("{ENTER}")
    }

    if (Test-Path $logPath) {
        Write-Host "Da phat hien file log xac minh!"
        break
    }
}

Write-Host "Cho tien trinh 1C thoat..."
$proc.WaitForExit(15000) | Out-Null

if (Test-Path $logPath) {
    Write-Host "=== KET QUA XAC MINH DU LIEU ==="
    Get-Content $logPath
} else {
    Write-Host "CANH BAO: Khong tim thay file verify_full_test_data.log!"
}
