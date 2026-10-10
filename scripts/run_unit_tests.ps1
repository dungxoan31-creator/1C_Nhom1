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

Remove-Item "tests/unit/test_result.log" -Force -ErrorAction SilentlyContinue

Write-Host "Launching 1C Enterprise with RunUnitTests..."
$proc = Start-Process -FilePath $exe -ArgumentList "ENTERPRISE", "/F", $ib, "/N", "Admin", "/C", "RunUnitTests", "/DisableStartupDialogs", "/DisableStartupMessages" -PassThru

$wshell = New-Object -ComObject WScript.Shell

for ($i = 0; $i -lt 30; $i++) {
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

    if (Test-Path "tests/unit/test_result.log") {
        Write-Host "Report generated successfully!"
        break
    }
}

Write-Host "Waiting up to 10s for exit..."
$proc.WaitForExit(10000) | Out-Null

if (Test-Path "tests/unit/test_result.log") {
    Write-Host "=== TEST RESULT LOG ==="
    Get-Content "tests/unit/test_result.log"
} else {
    Write-Host "ERROR: No test_result.log found!"
}
