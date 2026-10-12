param(
    [string]$IBPath = "C:\Users\Dung\Documents\1C_Enterprise\Infobase_FullData",
    [string]$User = "Admin",
    [string]$Password = ""
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinSecTestUtil {
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
}
"@ -ErrorAction SilentlyContinue

$exe = "C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe"
$logPath = "C:\Users\Dung\Documents\1C_Enterprise\security_test_results.log"
Remove-Item $logPath -Force -ErrorAction SilentlyContinue

$cmdArgs = @("ENTERPRISE", "/F", $IBPath, "/N", $User)
if ($Password) {
    $cmdArgs += @("/P", $Password)
}
$cmdArgs += @("/C", "RunSecurityTests", "/DisableStartupDialogs", "/DisableStartupMessages")

$proc = Start-Process -FilePath $exe -ArgumentList $cmdArgs -PassThru
$wshell = New-Object -ComObject WScript.Shell

for ($i = 0; $i -lt 30; $i++) {
    Start-Sleep -Milliseconds 500
    if ($proc.HasExited) { break }
    $proc.Refresh()
    if ($proc.MainWindowHandle -ne [IntPtr]::Zero) {
        [WinSecTestUtil]::SetForegroundWindow($proc.MainWindowHandle) | Out-Null
        $wshell.SendKeys("{ENTER}")
    } else {
        $wshell.AppActivate($proc.Id) | Out-Null
        $wshell.SendKeys("{ENTER}")
    }
    if (Test-Path $logPath) {
        Start-Sleep -Milliseconds 500
        break
    }
}

if (-not $proc.HasExited) {
    $proc.WaitForExit(10000) | Out-Null
}

Write-Host "ExitCode: " $proc.ExitCode
if (Test-Path $logPath) {
    Write-Host "`n=== KET QUA KIEM THU BAO MAT ==="
    Get-Content $logPath
} else {
    Write-Warning "Khong tim thay file log security_test_results.log!"
}
