[CmdletBinding()]
param(
	[string]$ConfigurationPath,
	[string]$FixturePath
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($ConfigurationPath)) {
	$ConfigurationPath = Join-Path $PSScriptRoot '..\Configuration'
}
if ([string]::IsNullOrWhiteSpace($FixturePath)) {
	$FixturePath = Join-Path $PSScriptRoot 'fixtures\bank_statement_vnpay_demo.csv'
}
$ConfigurationPath = (Resolve-Path $ConfigurationPath).Path
$script:Failures = [System.Collections.Generic.List[string]]::new()

function Check([bool]$Condition, [string]$Message) {
	if (-not $Condition) { $script:Failures.Add($Message) }
}

function Read-Text([string]$Path) {
	if (-not (Test-Path -LiteralPath $Path)) { return '' }
	return [System.IO.File]::ReadAllText((Resolve-Path $Path))
}

$ModuleMetadata = Join-Path $ConfigurationPath 'CommonModules\NhapSaoKeCsvServer.xml'
$ModuleCodePath = Join-Path $ConfigurationPath 'CommonModules\NhapSaoKeCsvServer\Ext\Module.bsl'
$DocumentPath = Join-Path $ConfigurationPath 'Documents\DoiSoatKenhThanhToan.xml'
$DocumentCodePath = Join-Path $ConfigurationPath 'Documents\DoiSoatKenhThanhToan\Ext\ObjectModule.bsl'
$FormPath = Join-Path $ConfigurationPath 'Documents\DoiSoatKenhThanhToan\Forms\FormChungTu\Ext\Form.xml'
$FormCodePath = Join-Path $ConfigurationPath 'Documents\DoiSoatKenhThanhToan\Forms\FormChungTu\Ext\Form\Module.bsl'
$SeedTestsPath = Join-Path $ConfigurationPath 'CommonModules\SeedBoundaryTestsServer\Ext\Module.bsl'
$RunnerPath = Join-Path (Split-Path -Parent $ConfigurationPath) 'scripts\run_finance_e2e.ps1'
$UiRunnerPath = Join-Path (Split-Path -Parent $ConfigurationPath) 'scripts\run_finance_ui_e2e.ps1'
$RegisterPath = Join-Path $ConfigurationPath 'InformationRegisters\GiaoDichSaoKeDaNhap.xml'
$ConfigurationXml = Read-Text (Join-Path $ConfigurationPath 'Configuration.xml')
$ModuleMetadataText = Read-Text $ModuleMetadata
$ModuleCode = Read-Text $ModuleCodePath
$DocumentXml = Read-Text $DocumentPath
$DocumentCode = Read-Text $DocumentCodePath
$FormXml = Read-Text $FormPath
$FormCode = Read-Text $FormCodePath
$SeedTests = Read-Text $SeedTestsPath
$Runner = Read-Text $RunnerPath
$UiRunner = Read-Text $UiRunnerPath
$RegisterXml = Read-Text $RegisterPath

Check (Test-Path $ModuleMetadata) 'CSV server common module metadata is missing'
Check (Test-Path $ModuleCodePath) 'CSV parser BSL module is missing'
Check (Test-Path $RegisterPath) 'Imported transaction key register is missing'
Check ($ConfigurationXml.Contains('<CommonModule>NhapSaoKeCsvServer</CommonModule>')) 'CSV common module is not registered in Configuration.xml'
Check ($ConfigurationXml.Contains('<InformationRegister>GiaoDichSaoKeDaNhap</InformationRegister>')) 'Transaction key register is not registered in Configuration.xml'
Check ($ModuleCode.Contains('Function ParseCSVRows(') -and $ModuleCode.Contains('Function CreateTransactionKey(')) 'CSV parser and deterministic transaction key interface are required'
Check ($ModuleCode.Contains('ThousandsSeparator') -and $ModuleCode.Contains('DecimalSeparator') -and $ModuleCode.Contains('InQuotes')) 'CSV parser must support explicit number separators and quoted fields'
Check ($ModuleCode.Contains('HashFunction.SHA256') -and $ModuleCode.Contains('HashSum') -and $ModuleCode.Contains('Base64String')) 'Fallback transaction fingerprint must use a bounded stable hash'
foreach ($Field in @('ExternalId','InvoiceNumber','KhoaGiaoDich','NgayGiaoDich','DienGiaiDong','TienTeDong','Gross','Phi','Net','HoaDonAR','SoTienGhep','TrangThaiDong','LyDoChan')) {
	Check ($DocumentXml.Contains("<Name>$Field</Name>") -or $DocumentXml.Contains("<name>$Field</name>")) "Reconciliation document line field '$Field' is missing"
Check ($FormXml.Contains(".GiaoDichSaoKe.$Field")) "CSV preview form is missing data binding for '$Field'"
}
Check ($DocumentCode.Contains('GiaoDichSaoKe') -and $DocumentCode.Contains('GiaoDichSaoKeDaNhap') -and $DocumentCode.Contains('LockObject.Lock()')) 'Imported posting must reserve each external transaction key under a managed lock'
Check ($DocumentCode.Contains('CongNoPhaiThu') -and $DocumentCode.Contains('HoaDonAR') -and $DocumentCode.Contains('SoTienGhep')) 'Imported posting must reduce the matched invoice AR balance'
Check ($DocumentCode.Contains('TongTienGiaoDich') -and $DocumentCode.Contains('TongPhi') -and $DocumentCode.Contains('TongTienThucNhan')) 'Imported posting must recompute gross, fee, and net from rows'
Check ($RegisterXml.Contains('<Name>PhapNhan</Name>') -and $RegisterXml.Contains('<Name>TaiKhoanTien</Name>') -and $RegisterXml.Contains('<Name>KenhThanhToan</Name>') -and $RegisterXml.Contains('<Name>KhoaGiaoDich</Name>')) 'Transaction key information register dimensions are incomplete'
Check ($DocumentCode.Contains('WHERE ChungTu = &Document') -and $DocumentCode.Contains('KeySet.Write();')) 'Unposting a reconciliation must remove its imported transaction key reservations'
Check ($FormXml.Contains('ChonTepCSV') -and $FormXml.Contains('XemTruocCSV') -and $FormXml.Contains('GhepHoaDonAR')) 'CSV selection, preview, and AR match commands must be present on the form'
Check ($FormCode.Contains('ParseCSVRows') -and $FormCode.Contains('CsvLineInvoiceOnChange') -and $FormCode.Contains('ConfirmARMatchesAtServer')) 'Form must call the parser and implement explicit AR match preview/confirmation'
$FormMainAttributeName = -join @([char]0x041E,[char]0x0431,[char]0x044A,[char]0x0435,[char]0x043A,[char]0x0442)
Check ($FormXml.Contains('<Attribute name="' + $FormMainAttributeName + '"') -and $FormCode.Contains($FormMainAttributeName + '.GiaoDichSaoKe.Clear()') -and -not $FormCode.Contains('Object.')) 'CSV form handlers must use the declared main attribute instead of undefined Object'
$DoiSoatUiCase = @($UiRunner -split '\r?\n' | Where-Object { $_ -match "Object = 'DoiSoatKenhThanhToan'" }) | Select-Object -First 1
Check ($DoiSoatUiCase -match "Registers = @\('SoCaiKeToan','DongTien','CongNoPhaiThu'\)") 'DoiSoat UI smoke must verify its ledger, cash, and AR register tabs'
Check ($FormXml.Contains('CsvPreviewSummary') -and $FormXml.Contains('CsvColumnGross') -and $FormXml.Contains('CsvColumnInvoiceNumber')) 'CSV preview summary and editable header mapping controls are required'
Check ($FormCode.Contains('amount-only matching is not used') -and $FormCode.Contains('Line.TrangThaiDong = "GoiY"') -and $FormCode.Contains('Line.SoTienGhep = 0')) 'Invoice-number matches must remain suggestions until explicit confirmation; amount-only matching must remain unmatched'
Check ($DocumentXml.Contains('AccumulationRegister.CongNoPhaiThu')) 'CSV reconciliation must declare AR subledger register movements'
Check ($DocumentCode.Contains('ValidateImportedARBalances') -and $DocumentCode.Contains('ReserveImportedTransactions') -and $DocumentCode.Contains('DeactivateImportedTransactions')) 'Imported posting must validate AR, reserve keys, and release reservations on unpost'
Check ($DocumentCode.Contains('InformationRegister.GiaoDichSaoKeDaNhap') -and $DocumentCode.Contains('LockObject.Lock()')) 'Imported transaction reservations must be protected by a managed lock'
foreach ($Phase in @('csv_import_preview','csv_match_post','csv_duplicate_reimport','csv_invalid_rows')) {
	Check ($SeedTests.Contains('Phase = "' + $Phase + '"')) "Runtime test phase '$Phase' is not dispatched"
	Check ($Runner.Contains("@('$Phase', 'cfo_giamdoc')")) "Full finance runner does not execute '$Phase' as CFO"
}

Check ($SeedTests.Contains('CreateFinanceE2ECsvReconciliation') -and $SeedTests.Contains('AttemptFinanceE2ECsvInvalidPosting')) 'CSV E2E must exercise real reconciliation documents and zero-movement rejection cases'

Check (Test-Path -LiteralPath $FixturePath) 'VNPAY CSV demo fixture is missing'
if (Test-Path -LiteralPath $FixturePath) {
	$Bytes = [System.IO.File]::ReadAllBytes((Resolve-Path $FixturePath))
	$HasUtf8Bom = $Bytes.Length -ge 3 -and $Bytes[0] -eq 0xEF -and $Bytes[1] -eq 0xBB -and $Bytes[2] -eq 0xBF
	Check $HasUtf8Bom 'CSV demo fixture must include a UTF-8 BOM'
	$Text = [System.IO.File]::ReadAllText((Resolve-Path $FixturePath), [System.Text.Encoding]::UTF8)
	$CsvRows = @($Text | ConvertFrom-Csv -Delimiter ',')
	Check ($CsvRows.Count -eq 1) 'CSV fixture must parse to exactly one valid data row'
	if ($CsvRows.Count -eq 1) {
		Check ($CsvRows[0].Memo -eq 'VNPay, receipt "settlement"') 'CSV parser fixture must preserve quoted comma and escaped quote'
		$Gross = [decimal]$CsvRows[0].Gross
		$Fee = [decimal]$CsvRows[0].Fee
		$Net = [decimal]$CsvRows[0].Net
		Check ($Gross -eq 75000000 -and $Fee -eq 1125000 -and $Net -eq 73875000) 'VNPAY fixture totals must be gross 75m = fee 1.125m + net 73.875m'
		Check ($Gross -eq ($Fee + $Net)) 'VNPAY fixture is not balanced'
	}
}

if ($script:Failures.Count -gt 0) {
	Write-Output "FAIL: $($script:Failures.Count) CSV reconciliation contract issue(s)."
	$script:Failures | ForEach-Object { Write-Output " - $_" }
	exit 1
}

Write-Output 'PASS: CSV parser, mapping, deduplication metadata, reconciliation row controls, and VNPAY fixture.'
Check ($FormXml.Contains("CsvPreviewSummary") -and $FormXml.Contains("CsvColumnGross") -and $FormXml.Contains("CsvColumnInvoiceNumber")) 'CSV preview summary and editable header mapping controls are required'
Check ($DocumentXml.Contains("AccumulationRegister.CongNoPhaiThu")) 'CSV reconciliation must declare AR subledger register movements'
Check ($DocumentCode.Contains("ValidateImportedARBalances") -and $DocumentCode.Contains("ReserveImportedTransactions") -and $DocumentCode.Contains("DeactivateImportedTransactions")) 'Imported posting must validate AR, reserve keys, and release reservations on unpost'
Check ($DocumentCode.Contains("InformationRegister.GiaoDichSaoKeDaNhap") -and $DocumentCode.Contains("LockObject.Lock()")) 'Imported transaction reservations must be protected by a managed lock'
