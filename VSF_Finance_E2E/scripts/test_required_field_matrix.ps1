[CmdletBinding()]
param(
	[Parameter(Mandatory = $true)][string]$ResultPath
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$DocumentNames = @(
	'BienBanNghiemThuGiaiDoan',
	'HoaDonGTGTDauRa',
	'PhieuThuTienKhachHang',
	'HoaDonNhaCungCap',
	'UyNhiemChi',
	'CanTruCongNoNoiBo',
	'DoiSoatKenhThanhToan'
)
$SystemManagedAttributes = @{
	'BienBanNghiemThuGiaiDoan|TongGiaTri' = $true
	'BienBanNghiemThuGiaiDoan|TrangThai' = $true
	'HoaDonGTGTDauRa|TongTienThanhToan' = $true
	'PhieuThuTienKhachHang|TienTe' = $true
	'HoaDonNhaCungCap|NgayHoaDon' = $true
	'HoaDonNhaCungCap|TienTe' = $true
	'HoaDonNhaCungCap|TongTien' = $true
}
$ExpectedAutoCases = @(
	'BienBanNghiemThuGiaiDoan|TongGiaTri',
	'BienBanNghiemThuGiaiDoan|TrangThai',
	'HoaDonGTGTDauRa|TongTienThanhToan',
	'PhieuThuTienKhachHang|TienTe',
	'HoaDonNhaCungCap|NgayHoaDon',
	'HoaDonNhaCungCap|TienTe',
	'HoaDonNhaCungCap|TongTien'
)
$ManagedSourcePatterns = @{
	'BienBanNghiemThuGiaiDoan|TongGiaTri' = @{ region = 'BeforeWrite'; pattern = 'TongGiaTri\s*=\s*GiaTriNghiemThuChuaVAT\s*\+\s*TienVAT' }
	'BienBanNghiemThuGiaiDoan|TrangThai' = @{ region = 'Filling'; pattern = 'TrangThai\s*=\s*Enums\.TrangThaiNghiemThuAR\.DuThao' }
	'HoaDonGTGTDauRa|TongTienThanhToan' = @{ region = 'BeforeWrite'; pattern = 'TongTienThanhToan\s*=\s*TienChuaThue\s*\+\s*TienThueVAT' }
	'PhieuThuTienKhachHang|TienTe' = @{ region = 'BeforeWrite'; pattern = 'TienTe\s*=\s*ChungTuGoc\.TienTe' }
	'HoaDonNhaCungCap|NgayHoaDon' = @{ region = 'BeforeWrite'; pattern = 'NgayHoaDon\s*=\s*BegOfDay\(Date\)' }
	'HoaDonNhaCungCap|TienTe' = @{ region = 'BeforeWrite'; pattern = 'TienTe\s*=\s*Catalogs\.TienTe\.FindByCode\("VND"\)' }
	'HoaDonNhaCungCap|TongTien' = @{ region = 'BeforeWrite'; pattern = 'TongTien\s*=\s*TienDichVu\s*\+\s*TienThueVAT' }
}
$Failures = [System.Collections.Generic.List[string]]::new()
$ExpectedCases = [System.Collections.Generic.List[object]]::new()
$ExpectedFieldProbeCases = [System.Collections.Generic.List[object]]::new()

foreach ($DocumentName in $DocumentNames) {
	$MetadataPath = Join-Path $ProjectRoot ("Configuration\Documents\{0}.xml" -f $DocumentName)
	if (-not (Test-Path -LiteralPath $MetadataPath)) {
		$Failures.Add("Document metadata is missing: $DocumentName")
		continue
	}
	[xml]$Metadata = [System.IO.File]::ReadAllText($MetadataPath, [System.Text.Encoding]::UTF8)
	foreach ($Attribute in $Metadata.SelectNodes("//*[local-name()='Attribute']")) {
		$NameNode = $Attribute.SelectSingleNode("./*[local-name()='Properties']/*[local-name()='Name']")
		$FillNode = $Attribute.SelectSingleNode("./*[local-name()='Properties']/*[local-name()='FillChecking']")
		if ($null -eq $NameNode -or $null -eq $FillNode) { continue }
		$Key = $DocumentName + '|' + $NameNode.InnerText
		if ($SystemManagedAttributes.ContainsKey($Key)) { continue }
		if ($FillNode.InnerText -ne 'ShowError') {
			$ExpectedFieldProbeCases.Add([PSCustomObject]@{
				document_type = $DocumentName
				field = $NameNode.InnerText
				key = $Key
			})
			continue
		}
		$ExpectedCases.Add([PSCustomObject]@{
		document_type = $DocumentName
		field = $NameNode.InnerText
		key = $Key
		})
		$ModulePath = Join-Path $ProjectRoot ("Configuration\Documents\{0}\Ext\ObjectModule.bsl" -f $DocumentName)
		if (-not (Test-Path -LiteralPath $ModulePath)) {
			$Failures.Add("Document object module is missing: $DocumentName")
			continue
		}
		$ModuleSource = [System.IO.File]::ReadAllText($ModulePath, [System.Text.Encoding]::UTF8)
		$Validator = [regex]::Match($ModuleSource, '(?s)Procedure ValidateRequiredFieldsForWrite\(Cancel\).*?EndProcedure')
		if (-not $Validator.Success -or $Validator.Value -notmatch ('\b' + [regex]::Escape($NameNode.InnerText) + '\b')) {
			$Failures.Add("Metadata-required field $Key is not referenced by the BSL write validator.")
		}
		if ($Validator.Success -and $Validator.Value -notmatch 'ThongBaoLoiChungTu') {
			$Failures.Add("$DocumentName validator has no user-facing validation message for metadata-required fields.")
		}
	}
}

if ($ExpectedCases.Count -ne 41) {
	$Failures.Add("Expected 41 user-entered required fields from metadata after excluding seven system-managed fields; found $($ExpectedCases.Count). Update the explicit classification before accepting coverage.")
}
if ($ExpectedFieldProbeCases.Count -ne 79) {
	$Failures.Add("Expected 79 document and statement-row field write/readback probes for all non-required, non-system-managed attributes; found $($ExpectedFieldProbeCases.Count).")
}

foreach ($ManagedKey in $SystemManagedAttributes.Keys) {
	$Parts = $ManagedKey.Split('|')
	$MetadataPath = Join-Path $ProjectRoot ("Configuration\Documents\{0}.xml" -f $Parts[0])
	[xml]$Metadata = [System.IO.File]::ReadAllText($MetadataPath, [System.Text.Encoding]::UTF8)
	$Attribute = @($Metadata.SelectNodes("//*[local-name()='Attribute']") | Where-Object {
		$NameNode = $_.SelectSingleNode("./*[local-name()='Properties']/*[local-name()='Name']")
		$null -ne $NameNode -and $NameNode.InnerText -eq $Parts[1]
	}) | Select-Object -First 1
	if ($null -eq $Attribute) {
		$Failures.Add("System-managed classification points to missing metadata: $ManagedKey")
		continue
	}
	$FillNode = $Attribute.SelectSingleNode("./*[local-name()='Properties']/*[local-name()='FillChecking']")
	if ($null -eq $FillNode -or $FillNode.InnerText -ne 'ShowError') {
		$Failures.Add("System-managed classification is no longer a metadata-required field: $ManagedKey")
	}
	$ModulePath = Join-Path $ProjectRoot ("Configuration\Documents\{0}\Ext\ObjectModule.bsl" -f $Parts[0])
	if (-not (Test-Path -LiteralPath $ModulePath)) {
		$Failures.Add("System-managed BSL module is missing: $ManagedKey")
		continue
	}
	$ModuleSource = [System.IO.File]::ReadAllText($ModulePath, [System.Text.Encoding]::UTF8)
	$Expectation = $ManagedSourcePatterns[$ManagedKey]
	$Region = [regex]::Match($ModuleSource, ('(?s)Procedure ' + [regex]::Escape($Expectation.region) + '\([^\r\n]*\).*?EndProcedure'))
	if (-not $Region.Success -or $Region.Value -notmatch $Expectation.pattern) {
		$Failures.Add("System-managed field $ManagedKey has no matching BSL auto-fill/calculation rule in $($Expectation.region).")
	}
}
$ARInvoiceModulePath = Join-Path $ProjectRoot 'Configuration\Documents\HoaDonGTGTDauRa\Ext\ObjectModule.bsl'
$ARInvoiceModule = [System.IO.File]::ReadAllText($ARInvoiceModulePath, [System.Text.Encoding]::UTF8)
$ARInvoiceBeforeWrite = [regex]::Match($ARInvoiceModule, '(?s)Procedure BeforeWrite\(Cancel, WriteMode, PostingMode\).*?EndProcedure')
if (-not $ARInvoiceBeforeWrite.Success -or
	$ARInvoiceBeforeWrite.Value -notmatch 'BegOfDay\(NgayHoaDon\)\s*>\s*BegOfDay\(CurrentSessionDate\(\)\)' -or
	$ARInvoiceBeforeWrite.Value -notmatch 'Msg\.Field\s*=\s*"NgayHoaDon"' -or
	$ARInvoiceBeforeWrite.Value -notmatch 'StrFind\("0123456789"') {
	$Failures.Add('AR invoice future-date validation is missing or no longer attached to NgayHoaDon.')
}
if (-not (Test-Path -LiteralPath $ResultPath)) {
	$Failures.Add("Required-field runtime matrix result is missing: $ResultPath")
} else {
	$RuntimeRoot = Get-Content -LiteralPath $ResultPath -Raw | ConvertFrom-Json
	$RuntimeCases = @($RuntimeRoot.data.cases)
	if ($RuntimeRoot.status -ne 'PASS') { $Failures.Add("Runtime matrix status is not PASS: $($RuntimeRoot.status)") }
	if ($RuntimeRoot.data.status -ne 'PASS') { $Failures.Add("Runtime data status is not PASS: $($RuntimeRoot.data.status)") }
	if ($RuntimeCases.Count -ne $ExpectedCases.Count) {
		$Failures.Add("Expected $($ExpectedCases.Count) runtime field cases, found $($RuntimeCases.Count).")
	}
	$DuplicateKeys = @($RuntimeCases | Group-Object key | Where-Object Count -gt 1)
	foreach ($Duplicate in $DuplicateKeys) { $Failures.Add("Duplicate runtime case: $($Duplicate.Name)") }
	foreach ($Expected in $ExpectedCases) {
		$Case = @($RuntimeCases | Where-Object key -eq $Expected.key) | Select-Object -First 1
		if ($null -eq $Case) {
			$Failures.Add("Missing runtime Save validation case: $($Expected.key)")
			continue
		}
		if ($Case.status -ne 'PASS') { $Failures.Add("Runtime case failed for $($Expected.key): $($Case.error)") }
		if (-not $Case.write_rejected) { $Failures.Add("Write was not rejected for empty $($Expected.key)") }
		if ($Case.document_persisted) { $Failures.Add("Empty $($Expected.key) was persisted") }
		if (-not $Case.rolled_back -or $Case.document_persisted_after_rollback) { $Failures.Add("Required-field probe was not removed by rollback: $($Expected.key)") }
		if (-not [string]::IsNullOrWhiteSpace([string]$Case.document_number_before) -or
			-not [string]::IsNullOrWhiteSpace([string]$Case.document_number_after)) {
			$Failures.Add("Empty $($Expected.key) received a number")
		}
	}
	$AutoCases = @($RuntimeRoot.data.auto_cases)
	if ($AutoCases.Count -ne $ExpectedAutoCases.Count) {
		$Failures.Add("Expected $($ExpectedAutoCases.Count) system-managed runtime cases, found $($AutoCases.Count).")
	}
	$DuplicateAutoKeys = @($AutoCases | Group-Object key | Where-Object Count -gt 1)
	foreach ($Duplicate in $DuplicateAutoKeys) { $Failures.Add("Duplicate system-managed runtime case: $($Duplicate.Name)") }
	foreach ($ExpectedKey in $ExpectedAutoCases) {
		$Case = @($AutoCases | Where-Object key -eq $ExpectedKey) | Select-Object -First 1
		if ($null -eq $Case) {
			$Failures.Add("Missing system-managed auto-fill runtime case: $ExpectedKey")
			continue
		}
		if ($Case.status -ne 'PASS') { $Failures.Add("System-managed runtime case failed for ${ExpectedKey}: $($Case.error)") }
		if (-not $Case.write_accepted) { $Failures.Add("Valid baseline was rejected for system-managed field $ExpectedKey") }
		if (-not $Case.automatic_value_valid) { $Failures.Add("Auto-filled/calculated value is incorrect for ${ExpectedKey}: $($Case.actual_value)") }
		if (-not $Case.rolled_back) { $Failures.Add("System-managed runtime case was not rolled back: $ExpectedKey") }
	}
	$FieldProbeCases = @($RuntimeRoot.data.field_probe_cases)
	if ($FieldProbeCases.Count -ne $ExpectedFieldProbeCases.Count) {
		$Failures.Add("Expected $($ExpectedFieldProbeCases.Count) document field write/readback probes, found $($FieldProbeCases.Count).")
	}
	$DuplicateFieldProbeKeys = @($FieldProbeCases | Group-Object key | Where-Object Count -gt 1)
	foreach ($Duplicate in $DuplicateFieldProbeKeys) { $Failures.Add("Duplicate document field probe: $($Duplicate.Name)") }
	foreach ($Expected in $ExpectedFieldProbeCases) {
		$Case = @($FieldProbeCases | Where-Object key -eq $Expected.key) | Select-Object -First 1
		if ($null -eq $Case) {
			$Failures.Add("Missing document field write/readback probe: $($Expected.key)")
			continue
		}
		if ($Case.status -ne 'PASS') { $Failures.Add("Document field probe failed for $($Expected.key): $($Case.write_error)") }
		if (-not $Case.write_accepted -or -not $Case.document_persisted) { $Failures.Add("Valid document field probe was not saved for $($Expected.key)") }
		if (-not $Case.round_trip_matches) { $Failures.Add("Field value differed after reading the saved document for $($Expected.key)") }
		if (-not $Case.rolled_back -or $Case.persisted_after_rollback) { $Failures.Add("Document field probe was not removed by rollback: $($Expected.key)") }
		if ($Expected.key -eq 'UyNhiemChi|SoTienNgoaiTe' -and
			(-not $Case.invalid_variant_checked -or -not $Case.invalid_variant_rejected -or $Case.invalid_variant_persisted -or
			[string]$Case.invalid_variant_error -notmatch 'VND payment cannot contain a foreign-currency amount')) {
			$Failures.Add('A VND payment persisted a foreign-currency amount instead of rejecting it.')
		}
	}
	$BoundaryCases = @($RuntimeRoot.data.boundary_cases)
	if ($BoundaryCases.Count -ne 7) {
		$Failures.Add("Expected seven AR invoice format/date boundary cases, found $($BoundaryCases.Count).")
	}
	$FutureDateCase = @($BoundaryCases | Where-Object key -eq 'HoaDonGTGTDauRa|NgayHoaDon|future') | Select-Object -First 1
	if ($null -eq $FutureDateCase) {
		$Failures.Add('Missing runtime boundary case for future AR invoice date.')
	} else {
		if ($FutureDateCase.status -ne 'PASS') { $Failures.Add("Future AR invoice date case failed: $($FutureDateCase.error)") }
		if (-not $FutureDateCase.date_is_future) { $Failures.Add('Future-date fixture did not exceed the current session date.') }
		if (-not $FutureDateCase.write_rejected -or $FutureDateCase.document_persisted) { $Failures.Add('Future-dated AR invoice was not rejected before persistence.') }
		if (-not $FutureDateCase.rolled_back -or $FutureDateCase.document_persisted_after_rollback) { $Failures.Add('Future-date boundary probe was not rolled back cleanly.') }
	}
	$ExpectedTaxIdOutcomes = [ordered]@{
		'HoaDonGTGTDauRa|MaSoThueNguoiMua|letters_10' = $false
		'HoaDonGTGTDauRa|MaSoThueNguoiMua|hyphen_10' = $false
		'HoaDonGTGTDauRa|MaSoThueNguoiMua|too_short_9' = $false
		'HoaDonGTGTDauRa|MaSoThueNguoiMua|valid_10_digits' = $true
		'HoaDonGTGTDauRa|MaSoThueNguoiMua|valid_13_digits' = $true
		'HoaDonGTGTDauRa|MaSoThueNguoiMua|valid_14_digits' = $true
	}
	foreach ($ExpectedKey in $ExpectedTaxIdOutcomes.Keys) {
		$Case = @($BoundaryCases | Where-Object key -eq $ExpectedKey) | Select-Object -First 1
		if ($null -eq $Case) {
			$Failures.Add("Missing AR tax-ID format boundary case: $ExpectedKey")
			continue
		}
		$ShouldAccept = [bool]$ExpectedTaxIdOutcomes[$ExpectedKey]
		if ($Case.status -ne 'PASS' -or [bool]$Case.should_accept -ne $ShouldAccept -or
			[bool]$Case.write_accepted -ne $ShouldAccept -or [bool]$Case.document_persisted -ne $ShouldAccept) {
			$Failures.Add("AR tax-ID format outcome differs from expected for ${ExpectedKey}: $($Case.error)")
		}
		if (-not $Case.rolled_back -or $Case.document_persisted_after_rollback) {
			$Failures.Add("AR tax-ID boundary probe was not rolled back: $ExpectedKey")
		}
	}
	$APBoundaryCases = @($RuntimeRoot.data.ap_boundary_cases)
	if ($APBoundaryCases.Count -ne 8) {
		$Failures.Add("Expected eight AP invoice VAT/FX/FCT boundary cases, found $($APBoundaryCases.Count).")
	}
	$ExpectedAPOutcomes = [ordered]@{
		'HoaDonNhaCungCap|vat_equals_total' = $false
		'HoaDonNhaCungCap|zero_total' = $false
		'HoaDonNhaCungCap|vat_one_below_total' = $true
		'HoaDonNhaCungCap|fx_difference_two' = $false
		'HoaDonNhaCungCap|fx_tolerance_plus_one' = $true
		'HoaDonNhaCungCap|fx_tolerance_minus_one' = $true
		'HoaDonNhaCungCap|fct_default_rates' = $true
	}
	$NegativeVATCase = @($APBoundaryCases | Where-Object key -eq 'HoaDonNhaCungCap|negative_vat') | Select-Object -First 1
	if ($null -eq $NegativeVATCase) {
		$Failures.Add('Missing AP negative-VAT metadata sign-boundary case.')
	} elseif ($NegativeVATCase.status -ne 'PASS' -or -not $NegativeVATCase.negative_input_safe -or
		[decimal]$NegativeVATCase.input_requested -ge 0 -or
		($NegativeVATCase.write_accepted -and ([decimal]$NegativeVATCase.vat_before_write -lt 0 -or [decimal]$NegativeVATCase.vat_after_write -lt 0)) -or
		(-not $NegativeVATCase.write_accepted -and $NegativeVATCase.persisted_in_transaction)) {
		$Failures.Add("Negative AP VAT crossed the metadata sign boundary or was persisted: $($NegativeVATCase.error)")
	}
	foreach ($ExpectedKey in $ExpectedAPOutcomes.Keys) {
		$Case = @($APBoundaryCases | Where-Object key -eq $ExpectedKey) | Select-Object -First 1
		if ($null -eq $Case) {
			$Failures.Add("Missing AP invoice boundary case: $ExpectedKey")
			continue
		}
		$ShouldAccept = [bool]$ExpectedAPOutcomes[$ExpectedKey]
		if ($Case.status -ne 'PASS' -or [bool]$Case.should_accept -ne $ShouldAccept -or
			[bool]$Case.write_accepted -ne $ShouldAccept -or [bool]$Case.persisted_in_transaction -ne $ShouldAccept -or
			-not $Case.calculated_values_valid) {
			$Failures.Add("AP invoice validation boundary outcome/calculation differs for ${ExpectedKey}: $($Case.error)")
		}
		if (-not $Case.rolled_back -or $Case.persisted_after_rollback) {
			$Failures.Add("AP invoice boundary probe was not rolled back: $ExpectedKey")
		}
	}
}

if ($Failures.Count -gt 0) {
	$Failures | ForEach-Object { Write-Error $_ -ErrorAction Continue }
	Write-Output ("FAIL required-field runtime matrix: {0} issue(s)." -f $Failures.Count)
	exit 1
}

Write-Output ("PASS finance field matrix: {0} required fields rejected; {1} system-managed values verified; {2} document and statement-row field values persisted and read back; 7 AR and 8 AP VAT/FX/FCT boundaries passed; probes rolled back." -f $ExpectedCases.Count, $ExpectedAutoCases.Count, $ExpectedFieldProbeCases.Count)
