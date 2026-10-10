param(
    [string]$User = "Admin",
    [string]$Password = ""
)

$exePath = "C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe"
$ibPath = "C:\Users\Dung\Documents\1C_Enterprise\Infobase"
$srcPath = "C:\Users\Dung\Documents\1C_Enterprise\src"

Remove-Item "load_last.log" -Force -ErrorAction SilentlyContinue
Remove-Item "update_last.log" -Force -ErrorAction SilentlyContinue

$userArg = ""
if ($User) {
    $userArg = "/N `"$User`""
    if ($Password) {
        $userArg += " /P `"$Password`""
    }
}

Write-Host "1. Loading Config from Files..."
$cmd1 = "DESIGNER /F `"$ibPath`" $userArg /LoadConfigFromFiles `"$srcPath`" /DisableStartupDialogs /DisableStartupMessages /OUT `"load_last.log`""
$p1 = Start-Process -FilePath $exePath -ArgumentList $cmd1 -PassThru -Wait
Write-Host ("Load exit code: " + $p1.ExitCode)
if (Test-Path "load_last.log") { Get-Content "load_last.log" }

if ($p1.ExitCode -eq 0) {
    Write-Host "2. Updating DB Config..."
    $cmd2 = "DESIGNER /F `"$ibPath`" $userArg /UpdateDBCfg /DisableStartupDialogs /DisableStartupMessages /OUT `"update_last.log`""
    $p2 = Start-Process -FilePath $exePath -ArgumentList $cmd2 -PassThru -Wait
    Write-Host ("Update exit code: " + $p2.ExitCode)
    if (Test-Path "update_last.log") { Get-Content "update_last.log" }
}
