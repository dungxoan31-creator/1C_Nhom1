<#
.SYNOPSIS
    Script xuat ban (publish) 1C Infobase len Web Server (IIS / Apache) de chay 1C Web Client tren trinh duyet.
.PARAMETER WebServer
    Loai Web Server: "iis" hoac "apache24" (mac dinh: "iis")
.PARAMETER VSDir
    Ten duong dan ao (Virtual directory name, mac dinh: "vinsmart")
.PARAMETER IBPath
    Duong dan thu muc Infobase (mac dinh: thu muc Infobase trong workspace)
#>

param (
    [string]$WebServer = "iis",
    [string]$VSDir = "vinsmart",
    [string]$IBPath = "$PSScriptRoot\..\Infobase"
)

$ErrorActionPreference = "Stop"

$ResolvedIBPath = (Resolve-Path -Path $IBPath -ErrorAction SilentlyContinue)
if (-not $ResolvedIBPath) {
    Write-Warning "Thu muc Infobase chua ton tai tai: $IBPath"
    $ResolvedIBPath = (Resolve-Path -Path "$PSScriptRoot\.." | Select-Object -ExpandProperty Path) + "\Infobase"
} else {
    $ResolvedIBPath = $ResolvedIBPath.Path
}

# Tim 1C webinst.exe
$WebinstCandidates = @(
    "C:\Program Files\1cv8\8.3.22.1704\bin\webinst.exe",
    "C:\Program Files (x86)\1cv8\8.3.22.1704\bin\webinst.exe",
    "C:\Program Files\1cv8\current\bin\webinst.exe",
    "C:\Program Files (x86)\1cv8\current\bin\webinst.exe"
)

$WebinstPath = $null
foreach ($path in $WebinstCandidates) {
    if (Test-Path $path) {
        $WebinstPath = $path
        break
    }
}

$WwwRootDir = "C:\inetpub\wwwroot\$VSDir"
if (-not (Test-Path $WwwRootDir)) {
    New-Item -ItemType Directory -Path $WwwRootDir -Force | Out-Null
}

# Sao chep default.vrd vao thu muc wwwroot
$VrdSource = Join-Path $PSScriptRoot "..\default.vrd"
if (Test-Path $VrdSource) {
    Copy-Item -Path $VrdSource -Destination (Join-Path $WwwRootDir "default.vrd") -Force
    Write-Host "[OK] Da sao chep default.vrd vao $WwwRootDir"
}

if ($WebinstPath) {
    Write-Host "[1C] Tim thay webinst tai: $WebinstPath"
    Write-Host "[1C] Thuc hien dang ky voi $WebServer..."
    & $WebinstPath -publish -$WebServer -wsdir $VSDir -dir $WwwRootDir -connstr "File=`"$ResolvedIBPath`";"
    Write-Host "[SUCCESS] Da publish thanh cong! Truy cap: http://localhost/$VSDir"
} else {
    Write-Host "[INFO] Chua tim thay webinst.exe tu dong. File default.vrd da san sang tai: $WwwRootDir\default.vrd"
    Write-Host "[INFO] Ban co the mo Designer -> Administration -> Publish to web server de hoan tat."
}
