[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$ConfigurationRoot = Join-Path $ProjectRoot 'Configuration\Documents'
$DocumentNames = @(
	'BienBanNghiemThuGiaiDoan',
	'HoaDonGTGTDauRa',
	'PhieuThuTienKhachHang',
	'HoaDonNhaCungCap',
	'UyNhiemChi'
)
$RequiredPatterns = [ordered]@{
	'session date captured once' = 'NgayHienTai\s*=\s*CurrentSessionDate\(\)'
	'current day range' = '(?s)BoLocKy\s*=\s*"HomNay".*?BegOfDay\(NgayHienTai\).*?EndOfDay\(NgayHienTai\)'
	'current month range' = '(?s)BoLocKy\s*=\s*"ThangNay".*?BegOfMonth\(NgayHienTai\).*?EndOfMonth\(NgayHienTai\)'
	'current quarter range' = '(?s)BoLocKy\s*=\s*"QuyNay".*?BegOfQuarter\(NgayHienTai\).*?EndOfQuarter\(NgayHienTai\)'
	'document date lower bound' = '(?s)New DataCompositionField\("Date"\).*?DataCompositionComparisonType\.GreaterOrEqual'
	'document date upper bound' = '(?s)New DataCompositionField\("Date"\).*?DataCompositionComparisonType\.LessOrEqual'
}

$Failures = [System.Collections.Generic.List[string]]::new()
foreach ($DocumentName in $DocumentNames) {
	$ModulePath = Join-Path $ConfigurationRoot (Join-Path $DocumentName 'Forms\FormDanhSach\Ext\Form\Module.bsl')
	if (-not (Test-Path -LiteralPath $ModulePath)) {
		$Failures.Add("${DocumentName}: list form module is missing.")
		continue
	}

	$Source = [System.IO.File]::ReadAllText($ModulePath, [System.Text.Encoding]::UTF8)
	foreach ($Check in $RequiredPatterns.GetEnumerator()) {
		if ($Source -notmatch $Check.Value) {
			$Failures.Add("${DocumentName}: missing $($Check.Key) filter logic.")
		}
	}
}

$APModulePath = Join-Path $ConfigurationRoot 'HoaDonNhaCungCap\Forms\FormDanhSach\Ext\Form\Module.bsl'
$APSource = [System.IO.File]::ReadAllText($APModulePath, [System.Text.Encoding]::UTF8)
if ($APSource -notmatch '(?s)BoLocTrangThai\s*=\s*"ChoPheDuyet".*?TrangThaiHoaDonAP\.ChoPheDuyet') {
	$Failures.Add('HoaDonNhaCungCap: approval status filter is missing.')
}

if ($Failures.Count -gt 0) {
	$Failures | ForEach-Object { Write-Error $_ -ErrorAction Continue }
	Write-Output ("FAIL list period filter regression: {0} issue(s)." -f $Failures.Count)
	exit 1
}

Write-Output ("PASS list period filter regression: {0} list forms; day/month/quarter ranges and AP approval status." -f $DocumentNames.Count)
