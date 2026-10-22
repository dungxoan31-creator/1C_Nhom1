param(
	[Parameter(Mandatory = $false)]
	[string]$ConfigurationPath = (Join-Path $PSScriptRoot '..\Configuration')
)

$ErrorActionPreference = 'Stop'
$ConfigurationPath = (Resolve-Path $ConfigurationPath).Path
$script:Failures = [System.Collections.Generic.List[string]]::new()

function Read-Xml([string]$Path) {
	$Document = New-Object System.Xml.XmlDocument
	$Document.PreserveWhitespace = $true
	$Document.Load((Resolve-Path $Path))
	return $Document
}

function Check([bool]$Condition, [string]$Message) {
	if (-not $Condition) { $script:Failures.Add($Message) }
}

function Get-Page([System.Xml.XmlDocument]$Form, [string]$PageName) {
	return $Form.SelectSingleNode("//*[local-name()='Page' and @name='$PageName']")
}

function Get-PageFields([System.Xml.XmlNode]$Page) {
	if ($null -eq $Page) { return @() }
	return @($Page.SelectNodes(".//*[local-name()='InputField' or local-name()='CheckBoxField']") | ForEach-Object {
		$DataPath = $_.SelectSingleNode("./*[local-name()='DataPath']")
		if ($null -ne $DataPath) {
			$ReadOnlyNode = $_.SelectSingleNode("./*[local-name()='ReadOnly']")
			$IsReadOnly = ($null -ne $ReadOnlyNode) -and ($ReadOnlyNode.InnerText -eq 'true')
			[pscustomobject]@{
				Name = $_.GetAttribute('name')
				Path = $DataPath.InnerText
				Type = $_.LocalName
				ReadOnly = $IsReadOnly
			}
		}
	})
}

function Assert-PageFieldOrder([System.Xml.XmlDocument]$Form, [string]$PageName, [string[]]$Paths, [string]$Label) {
	$Page = Get-Page $Form $PageName
	Check ($null -ne $Page) "${Label}: page '$PageName' is missing"
	if ($null -eq $Page) { return }
	$Fields = @(Get-PageFields $Page)
	$Actual = @($Fields | ForEach-Object Path)
	$Cursor = -1
	foreach ($Path in $Paths) {
		$Matches = @($Actual | Where-Object { $_ -eq $Path }).Count
		Check ($Matches -eq 1) "${Label}: '$Path' must appear exactly once on '$PageName' (found $Matches)"
		$Index = [array]::IndexOf($Actual, $Path)
		Check ($Index -gt $Cursor) "${Label}: '$Path' is not in the required order on '$PageName'"
		$Cursor = $Index
	}
}

function Assert-NotOnPage([System.Xml.XmlDocument]$Form, [string]$PageName, [string]$Path, [string]$Label) {
	$Page = Get-Page $Form $PageName
	if ($null -ne $Page) {
		$Found = @((Get-PageFields $Page) | Where-Object Path -eq $Path).Count -gt 0
		Check (-not $Found) "${Label}: '$Path' must not be on '$PageName'"
	}
}

function Get-ObjectForm([string]$DocumentName, [string]$FormName = 'FormChungTu') {
	$Path = Join-Path $ConfigurationPath "Documents\$DocumentName\Forms\$FormName\Ext\Form.xml"
	if (-not (Test-Path $Path)) { return $null }
	return Read-Xml $Path
}

function Assert-RegisterRecordsCommand([string]$DocumentName) {
	$ObjectPath = Join-Path $ConfigurationPath "Documents\$DocumentName.xml"
	Check (Test-Path $ObjectPath) "${DocumentName}: metadata is missing"
	if (-not (Test-Path $ObjectPath)) { return }
	$Object = Read-Xml $ObjectPath
	$UseStandard = $Object.SelectSingleNode("//*[local-name()='UseStandardCommands']")
	$Registers = @($Object.SelectNodes("//*[local-name()='RegisterRecords']/*"))
	Check (($null -ne $UseStandard) -and ($UseStandard.InnerText -eq 'true')) "${DocumentName}: standard document commands are disabled"
	Check ($Registers.Count -gt 0) "${DocumentName}: no register records are declared"
	$DefaultForm = $Object.SelectSingleNode("//*[local-name()='DefaultObjectForm']")
	Check (($null -ne $DefaultForm) -and -not [string]::IsNullOrWhiteSpace($DefaultForm.InnerText)) "${DocumentName}: no default object form is configured"
	if ($null -ne $DefaultForm -and -not [string]::IsNullOrWhiteSpace($DefaultForm.InnerText)) {
		$Name = ($DefaultForm.InnerText -split '\.')[-1]
		$Form = Get-ObjectForm $DocumentName $Name
		Check ($null -ne $Form) "${DocumentName}: default object form '$Name' is missing its Form.xml"
		if ($null -ne $Form) {
			$MainAttribute = $Form.SelectSingleNode("//*[local-name()='Attribute'][*[local-name()='MainAttribute' and text()='true']]")
			$MainAttributeName = if ($null -ne $MainAttribute) { $MainAttribute.GetAttribute('name') } else { '' }
			Check (-not [string]::IsNullOrWhiteSpace($MainAttributeName)) "${DocumentName}: form main attribute is missing"
			$Command = $Form.SelectSingleNode("//*[local-name()='Commands']/*[local-name()='Command' and @name='OpenRegisterRecords']")
			$Action = if ($null -ne $Command) { $Command.SelectSingleNode("./*[local-name()='Action']") } else { $null }
			Check (($null -ne $Action) -and ($Action.InnerText -eq 'OpenRegisterRecords')) "${DocumentName}: register-records form command is missing"
			$Button = $Form.SelectSingleNode("//*[local-name()='AutoCommandBar']//*[local-name()='Button' and @name='OpenRegisterRecordsButton']")
			$CommandName = if ($null -ne $Button) { $Button.SelectSingleNode("./*[local-name()='CommandName']") } else { $null }
			$Location = if ($null -ne $Button) { $Button.SelectSingleNode("./*[local-name()='LocationInCommandBar']") } else { $null }
			Check (($null -ne $CommandName) -and ($CommandName.InnerText -eq 'Form.Command.OpenRegisterRecords') -and ($null -ne $Location) -and ($Location.InnerText -eq 'InAdditionalSubmenu')) "${DocumentName}: register-records command must appear in More"
			$ButtonTitle = if ($null -ne $Button) { $Button.SelectSingleNode("./*[local-name()='Title']/*[local-name()='item']/*[local-name()='content']") } else { $null }
	Check (($null -ne $ButtonTitle) -and -not [string]::IsNullOrWhiteSpace($ButtonTitle.InnerText) -and ($ButtonTitle.InnerText -ne 'OpenRegisterRecords')) "${DocumentName}: More menu command must have a user-facing title"
			$ViewerPage = $Form.SelectSingleNode("//*[local-name()='Page' and @name='RegisterRecordsTab']")
			Check ($null -ne $ViewerPage) "${DocumentName}: register-records viewer tab is missing"
			$ModulePath = Join-Path $ConfigurationPath "Documents\$DocumentName\Forms\$Name\Ext\Form\Module.bsl"
			$Module = if (Test-Path $ModulePath) { Get-Content -Raw -Encoding UTF8 $ModulePath } else { '' }
			$ViewerHandler = [regex]::Match($Module, '(?s)Procedure\s+OpenRegisterRecords\s*\(.*?EndProcedure')
			Check ($ViewerHandler.Success -and $ViewerHandler.Value -match 'Items\.Pages\.CurrentPage\s*=\s*Items\.Find\("RegisterRecordsTab"\)') "${DocumentName}: register-records command handler does not select the viewer tab"
			foreach ($Register in $Registers) {
				$RegisterName = ($Register.InnerText -split '\.')[-1]
				$RegisterPage = $Form.SelectSingleNode("//*[local-name()='Page' and @name='RegisterPage_$RegisterName']")
				$RegisterTable = $Form.SelectSingleNode("//*[local-name()='Table' and @name='RegisterRows_$RegisterName']")
				$DataPath = if ($null -ne $RegisterTable) { $RegisterTable.SelectSingleNode("./*[local-name()='DataPath']") } else { $null }
				Check (($null -ne $RegisterPage) -and ($null -ne $DataPath) -and ($DataPath.InnerText -eq "$MainAttributeName.RegisterRecords.$RegisterName")) "${DocumentName}: register '$RegisterName' is not shown in its viewer tab"
			}
		}
	}
}

$Bbnt = Get-ObjectForm 'BienBanNghiemThuGiaiDoan'
$BbntTab4 = Get-Page $Bbnt 'NhatKyVaGhiChu'
$BbntTab4Fields = @(Get-PageFields $BbntTab4)
Assert-PageFieldOrder $Bbnt 'NhatKyVaGhiChu' @('Object.NguoiTao','Object.NguoiDuyet','Object.TrangThai','Object.DienGiai') 'BBNT'
Assert-NotOnPage $Bbnt 'ThueVaHoaDonDienTu' 'Object.TrangThai' 'BBNT'
if ($null -ne $BbntTab4) {
	$Creator = @($BbntTab4Fields | Where-Object Path -eq 'Object.NguoiTao') | Select-Object -First 1
	$Approver = @($BbntTab4Fields | Where-Object Path -eq 'Object.NguoiDuyet') | Select-Object -First 1
	Check (($null -ne $Creator) -and $Creator.ReadOnly) 'BBNT: NguoiTao must be read-only'
	Check (($null -ne $Approver) -and -not $Approver.ReadOnly) 'BBNT: NguoiDuyet must be selectable'
}

$Ar = Get-ObjectForm 'HoaDonGTGTDauRa'
Assert-PageFieldOrder $Ar 'NhatKyVaGhiChu' @('Object.NguoiLap','Object.NguoiDuyet','Object.TrangThaiHDDT','Object.DienGiai') 'AR invoice'
Assert-NotOnPage $Ar 'ThanhToanVaThue' 'Object.TrangThaiHDDT' 'AR invoice'
Assert-NotOnPage $Ar 'ThanhToanVaThue' 'Object.NguoiDuyet' 'AR invoice'
$ArFormModule = Get-Content -Raw -Encoding UTF8 (Join-Path $ConfigurationPath 'Documents\HoaDonGTGTDauRa\Forms\FormChungTu\Ext\Form\Module.bsl')
Check ($ArFormModule -match 'Procedure\s+BienBanNghiemThuOnChange\s*\(') 'AR invoice: BBNT OnChange handler is missing'
Check ($ArFormModule -match 'Procedure\s+CapNhatTheoBienBanNghiemThu\s*\(') 'AR invoice: BBNT server fill routine is missing'

$Ap = Get-ObjectForm 'HoaDonNhaCungCap'
$ApTab1 = Get-PageFields (Get-Page $Ap 'ThongTinChung')
$ApTab1Paths = @($ApTab1 | ForEach-Object Path)
$GrossIndex = [array]::IndexOf($ApTab1Paths, 'Object.TienDichVu')
$FctIndex = [array]::IndexOf($ApTab1Paths, 'Object.CoKhauTruFCT')
Check (($FctIndex -gt $GrossIndex) -and ($GrossIndex -ge 0)) 'AP invoice: CoKhauTruFCT checkbox must follow TienDichVu on Tab 1'
$FctField = @($ApTab1 | Where-Object Path -eq 'Object.CoKhauTruFCT') | Select-Object -First 1
Check (($null -ne $FctField) -and ($FctField.Type -eq 'CheckBoxField')) 'AP invoice: CoKhauTruFCT must be a checkbox'
Assert-PageFieldOrder $Ap 'ThueVaHoaDonDienTu' @('Object.TrangThai','Object.NguoiDuyet') 'AP invoice'

$SeedBoundaryTestsPath = Join-Path $ConfigurationPath 'CommonModules\SeedBoundaryTestsServer\Ext\Module.bsl'
$SeedBoundaryTests = if (Test-Path $SeedBoundaryTestsPath) { Get-Content -Raw -Encoding UTF8 $SeedBoundaryTestsPath } else { '' }
$FinanceE2ERunner = Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot 'run_finance_e2e.ps1')
$UiRunner = Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot 'run_finance_ui_e2e.ps1')
Check ($SeedBoundaryTests.Contains('E2E-AP-FCT250') -and $SeedBoundaryTests.Contains('250000000') -and $SeedBoundaryTests.Contains('225000000')) 'AP invoice: a posted 250m gross / 225m payable FCT fixture must be verified at runtime'
foreach ($Account in @('33318','3338','33311')) {
	Check ($SeedBoundaryTests.Contains('"' + $Account + '"')) "AP invoice: FCT fixture must assert GL account $Account"
}
Check ($FinanceE2ERunner.Contains("@('ap_fct_250_prepare'") -and $FinanceE2ERunner.Contains("@('ap_fct_250_post_verify'")) 'AP invoice: full finance E2E must prepare and post the 250m FCT fixture'
Check ($UiRunner.Contains("Number = 'E2E-AP-FCT250'") -and $UiRunner.Contains("Registers = @('SoCaiKeToan','CongNoPhaiTra')") -and $UiRunner.Contains('FCTInvoiceSmoke') -and $UiRunner.Contains('fct_checkbox_persisted')) 'AP invoice: native form smoke must open the posted 250m FCT invoice, checked checkbox, and its registers'

foreach ($DocumentName in @('BienBanNghiemThuGiaiDoan','HoaDonGTGTDauRa','HoaDonNhaCungCap','PhieuThuTienKhachHang','UyNhiemChi','CanTruCongNoNoiBo','DoiSoatKenhThanhToan')) {
	Assert-RegisterRecordsCommand $DocumentName
}

if ($script:Failures.Count -gt 0) {
	Write-Output "FAIL ($($script:Failures.Count) contract checks)"
	$script:Failures | ForEach-Object { Write-Output " - $_" }
	exit 1
}

Write-Output 'PASS: AR/AP form layout, BBNT autofill hooks, and register-record viewer contracts.'
