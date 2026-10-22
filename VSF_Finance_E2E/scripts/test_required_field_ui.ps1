[CmdletBinding()]
param(
	[Parameter(Mandatory = $true)][string]$ResultPath
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$Failures = [System.Collections.Generic.List[string]]::new()
$DocumentModules = [ordered]@{
	Acceptance = 'BienBanNghiemThuGiaiDoan'
	ARInvoice = 'HoaDonGTGTDauRa'
	Receipt = 'PhieuThuTienKhachHang'
	APInvoice = 'HoaDonNhaCungCap'
	Payment = 'UyNhiemChi'
	Netting = 'CanTruCongNoNoiBo'
	Reconciliation = 'DoiSoatKenhThanhToan'
}
$RequiredFieldChecks = @{
	Acceptance = @('PhapNhan', 'DoiTac', 'HopDong', 'GiaTriNghiemThuChuaVAT')
	ARInvoice = @('PhapNhan', 'DoiTac', 'HopDong', 'SoHoaDon', 'KyHieu', 'NgayHoaDon', 'TongTienThanhToan')
	Receipt = @('PhapNhan', 'DoiTac', 'HopDong', 'TaiKhoanTien', 'KhoanMucDongTien', 'TienTe', 'SoTien')
	APInvoice = @('PhapNhan', 'DoiTac', 'HopDong', 'SoHoaDon', 'NgayHoaDon', 'TienTe', 'TongTien')
	Payment = @('PhapNhan', 'DoiTac', 'HopDong', 'TaiKhoanTien', 'KhoanMucDongTien', 'TienTe', 'SoTien')
	Netting = @('PhapNhan', 'DoiTac', 'ChungTuAR', 'ChungTuAP', 'SoTien')
	Reconciliation = @('PhapNhan', 'DoiTacTrungGian', 'TaiKhoanTien', 'KhoanMucDongTien', 'TienTe', 'KenhThanhToan', 'TongTienGiaoDich', 'TongPhi', 'TongTienThucNhan')
}

if (-not (Test-Path -LiteralPath $ResultPath)) {
	$Failures.Add("Required-field UI result was not found: $ResultPath")
} else {
	$RuntimeRoot = Get-Content -LiteralPath $ResultPath -Raw | ConvertFrom-Json
	$RuntimeCases = if ($RuntimeRoot.cases) { @($RuntimeRoot.cases) } else { @($RuntimeRoot) }
	if ($RuntimeCases.Count -ne $DocumentModules.Count) {
		$Failures.Add("Expected $($DocumentModules.Count) required-field UI cases, found $($RuntimeCases.Count).")
	}
	foreach ($DocumentType in $DocumentModules.Keys) {
		$Case = @($RuntimeCases | Where-Object { $_.document_type -eq $DocumentType }) | Select-Object -First 1
		if ($null -eq $Case) {
			$Failures.Add("Missing runtime required-field case for $DocumentType.")
			continue
		}
		if ($Case.status -ne 'PASS') { $Failures.Add("Blank $DocumentType Save did not pass: $($Case.status) $($Case.error)") }
		if (-not [string]::IsNullOrWhiteSpace([string]$Case.document_number_before) -or
			-not [string]::IsNullOrWhiteSpace([string]$Case.document_number_after)) {
			$Failures.Add("Blank $DocumentType Save assigned a document number.")
		}
		if (-not $Case.blank_save_rejected) { $Failures.Add("Runtime did not confirm that blank $DocumentType Save was rejected.") }
		if ($Case.document_persisted) { $Failures.Add("Blank $DocumentType was persisted despite missing required fields.") }
		if (-not $Case.save_button_still_visible) { $Failures.Add("Rejected blank $DocumentType Save did not leave its form open for correction.") }
		if (-not $Case.validation_message_visible -or [string]::IsNullOrWhiteSpace([string]$Case.validation_message_text)) {
			$Failures.Add("Blank $DocumentType Save did not show a required-field validation message.")
		}

		$ModulePath = Join-Path $ProjectRoot ('Configuration\Documents\' + $DocumentModules[$DocumentType] + '\Ext\ObjectModule.bsl')
		$ModuleSource = [System.IO.File]::ReadAllText($ModulePath, [System.Text.Encoding]::UTF8)
		$BeforeWrite = [regex]::Match($ModuleSource, '(?s)Procedure BeforeWrite\(.*?EndProcedure')
		$Validator = [regex]::Match($ModuleSource, '(?s)Procedure ValidateRequiredFieldsForWrite\(Cancel\).*?EndProcedure')
		if (-not $BeforeWrite.Success -or $BeforeWrite.Value -notmatch 'ValidateRequiredFieldsForWrite\(Cancel\)') {
			$Failures.Add("$DocumentType BeforeWrite does not validate ordinary Save operations.")
		}
		if (-not $Validator.Success -or $Validator.Value -notmatch 'Cancel\s*=\s*True[\s\S]*?ThongBaoLoiChungTu') {
			$Failures.Add("$DocumentType is missing the required-field rejection and user-facing message.")
		} else {
			foreach ($Field in $RequiredFieldChecks[$DocumentType]) {
				if ($Validator.Value -notmatch ('\b' + [regex]::Escape($Field) + '\b')) {
					$Failures.Add("$DocumentType required field $Field is missing from its write validator.")
				}
			}
		}
		if ($DocumentType -eq 'ARInvoice') {
			$MetadataPath = Join-Path $ProjectRoot 'Configuration\Documents\HoaDonGTGTDauRa.xml'
			[xml]$Metadata = [System.IO.File]::ReadAllText($MetadataPath, [System.Text.Encoding]::UTF8)
			$AcceptanceAttribute = @($Metadata.SelectNodes('//*[local-name()="Attribute"]') | Where-Object {
				$Name = $_.SelectSingleNode('./*[local-name()="Properties"]/*[local-name()="Name"]')
				$null -ne $Name -and $Name.InnerText -eq 'BienBanNghiemThu'
			}) | Select-Object -First 1
			$FillChecking = if ($AcceptanceAttribute) { $AcceptanceAttribute.SelectSingleNode('./*[local-name()="Properties"]/*[local-name()="FillChecking"]').InnerText } else { '' }
			if ($FillChecking -ne 'DontCheck' -or $Validator.Value -notmatch 'If ValueIsFilled\(BienBanNghiemThu\)') {
				$Failures.Add('ARInvoice must allow direct invoices without BBNT while validating a source certificate when one is selected.')
			}
		}
	}
}

if ($Failures.Count -gt 0) {
	$Failures | ForEach-Object { Write-Error $_ -ErrorAction Continue }
	Write-Output ("FAIL required-field UI contract: {0} issue(s)." -f $Failures.Count)
	exit 1
}

Write-Output ("PASS required-field UI contract: blank Save rejected in all {0} forms; no number or persistence; correction message visible." -f $DocumentModules.Count)
