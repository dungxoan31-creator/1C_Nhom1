Add-Type -AssemblyName System.Windows.Forms
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinUtil {
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@

$exe = "C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe"
$ib = "C:\Users\Dung\Documents\1C_Enterprise\Infobase"

# Remove old logs
Remove-Item "start_breadcrumb.txt" -Force -ErrorAction SilentlyContinue
Remove-Item "VinSmart_Future_AP_DoD_Report.txt" -Force -ErrorAction SilentlyContinue

Write-Host "Launching 1C Enterprise..."
$proc = Start-Process -FilePath $exe -ArgumentList "ENTERPRISE", "/F", $ib, "/C", "RunDoD" -PassThru

$wshell = New-Object -ComObject WScript.Shell

for ($i = 0; $i -lt 20; $i++) {
    Start-Sleep -Milliseconds 500
    if ($proc.HasExited) {
        Write-Host "Process already exited!"
        break
    }
    
    $proc.Refresh()
    if ($proc.MainWindowHandle -ne [IntPtr]::Zero) {
        [WinUtil]::SetForegroundWindow($proc.MainWindowHandle) | Out-Null
        $wshell.SendKeys("{ENTER}")
    } else {
        $wshell.AppActivate($proc.Id) | Out-Null
        $wshell.SendKeys("{ENTER}")
    }

    if (Test-Path "VinSmart_Future_AP_DoD_Report.txt") {
        Write-Host "Report generated successfully!"
        break
    }
}

Write-Host "Waiting up to 15s for exit..."
$proc.WaitForExit(15000) | Out-Null

if (Test-Path "start_breadcrumb.txt") {
    Write-Host "Breadcrumb: " (Get-Content "start_breadcrumb.txt")
} else {
    Write-Host "No breadcrumb found."
}

if (Test-Path "VinSmart_Future_AP_DoD_Report.txt") {
    Write-Host "=== REPORT ==="
    Get-Content "VinSmart_Future_AP_DoD_Report.txt"
} else {
    Write-Host "No report found."
}
