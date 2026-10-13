$exe = "C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe"
$ib = "C:\Users\Dung\Documents\1C_Enterprise\Infobase_FullData"
Remove-Item "seed_run.log" -Force -ErrorAction SilentlyContinue
$p = Start-Process -FilePath $exe -ArgumentList "ENTERPRISE", "/F", $ib, "/N", "Admin", "/C", "SeedFullTestData", "/DisableStartupDialogs", "/DisableStartupMessages", "/OUT", "seed_run.log" -PassThru -Wait
Write-Host ("SeedFullTestData ExitCode: " + $p.ExitCode)
if (Test-Path "seed_run.log") {
    Get-Content "seed_run.log"
}
