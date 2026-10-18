# [FIX B66] Nap file .dt vao MOT infobase do nguoi chay chi dinh ro rang.
# Truoc day script restore de thang vao C:\Users\Dung\Documents\1C_Enterprise\Infobase (infobase chinh),
# khong hoi xac nhan, va luon thoat ma 0. Nay:
#   - Bat buoc -IBPath (khong co gia tri mac dinh), tu choi thu muc ten Infobase / Infobase_FullData.
#   - Bat buoc go xac nhan "YES" (hoac truyen -Force) truoc khi ghi de.
#   - Duong dan file 1C lay tu -ExePath hoac bien moi truong ONEC_EXE_PATH.
#   - Tra ve dung ma thoat cua 1C.
# Khuyen nghi: dung scripts/create_uat_clone.py de tao clone UAT co kiem tra an toan day du.
param(
    [Parameter(Mandatory = $true)][string]$InputPath,
    [Parameter(Mandatory = $true)][string]$IBPath,
    [string]$User = "Admin",
    [string]$Password = "",
    [string]$ExePath = $env:ONEC_EXE_PATH,
    [switch]$Force
)

if (-not $ExePath) {
    $ExePath = "C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe"
}
if (-not (Test-Path $ExePath)) {
    Write-Host "Loi: Khong tim thay 1C tai $ExePath (dung -ExePath hoac bien ONEC_EXE_PATH)"
    exit 2
}
if (-not (Test-Path $InputPath)) {
    Write-Host "Loi: Khong tim thay file DT tai $InputPath"
    exit 1
}

$ibFull = [System.IO.Path]::GetFullPath($IBPath)
$leaf = Split-Path $ibFull -Leaf
if ($leaf -ieq "Infobase" -or $leaf -ieq "Infobase_FullData") {
    Write-Host "Tu choi: khong restore de vao infobase chinh/ban phat hanh ($ibFull). Hay dung mot thu muc clone rieng."
    exit 3
}

if (-not $Force) {
    $answer = Read-Host "Restore se GHI DE toan bo du lieu trong '$ibFull'. Go YES de tiep tuc"
    if ($answer -ne "YES") {
        Write-Host "Da huy."
        exit 4
    }
}

$logPath = Join-Path (Get-Location) "restore_last.log"
Remove-Item $logPath -Force -ErrorAction SilentlyContinue

$argStr = "DESIGNER /F `"$ibFull`" /N `"$User`""
if ($Password -ne "") {
    $argStr += " /P `"$Password`""
}
$argStr += " /RestoreIB `"$InputPath`" /DisableStartupDialogs /DisableStartupMessages /OUT `"$logPath`""

Write-Host "Nap du lieu Infobase tu file DT: $InputPath -> $ibFull (User: $User)..."
$p = Start-Process -FilePath $ExePath -ArgumentList $argStr -PassThru -Wait

Write-Host ("Ma thoat: " + $p.ExitCode)
if (Test-Path $logPath) { Get-Content $logPath }
exit $p.ExitCode
