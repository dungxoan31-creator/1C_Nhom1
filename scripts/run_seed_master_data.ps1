$exe = "C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe"
$ib = "C:\Users\Dung\Documents\1C_Enterprise\Infobase_FullData"
$p = Start-Process -FilePath $exe -ArgumentList "ENTERPRISE", "/F", $ib, "/N", "Admin", "/C", "SeedMasterData", "/DisableStartupDialogs", "/DisableStartupMessages" -PassThru -Wait
Write-Host ("SeedMasterData ExitCode: " + $p.ExitCode)
