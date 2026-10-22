param(
	[Parameter(Mandatory = $false)]
	[string]$ConfigurationPath = (Join-Path $PSScriptRoot '..\Configuration')
)

$ErrorActionPreference = 'Stop'
$ConfigurationPath = (Resolve-Path $ConfigurationPath).Path
$script:Failures = [System.Collections.Generic.List[string]]::new()
$ReportRunnerPath = Join-Path $PSScriptRoot 'run_finance_ui_e2e.ps1'
$FinanceE2ERunnerPath = Join-Path $PSScriptRoot 'run_finance_e2e.ps1'
$SeedBoundaryTestsPath = Join-Path $ConfigurationPath 'CommonModules\SeedBoundaryTestsServer\Ext\Module.bsl'

function Check([bool]$Condition, [string]$Message) {
	if (-not $Condition) { $script:Failures.Add($Message) }
}

function Read-Xml([string]$Path) {
	$Document = New-Object System.Xml.XmlDocument
	$Document.PreserveWhitespace = $true
	$Document.Load((Resolve-Path $Path))
	return $Document
}

$ReportContracts = @(
	@{
		Name = 'SoChiTietCongNoAR'
		Query = 'ar-ledger.sql'
		Register = 'CongNoPhaiThu'
		Filters = @('NgayBatDau','NgayKetThuc','PhapNhan','DoiTac','HopDong','TienTe','ChungTuGoc')
		Fields = @('SoDuDauKy','PhatSinhTang','PhatSinhGiam','SoDuCuoiKy','NgayChungTu','SoChungTu','LoaiChungTu','DienGiai','SoTien','SoDuLuyKe')
	}
	@{
		Name = 'SoChiTietCongNoAP'
		Query = 'ap-ledger.sql'
		Register = 'CongNoPhaiTra'
		Filters = @('NgayBatDau','NgayKetThuc','PhapNhan','DoiTac','HopDong','TienTe','ChungTuGoc')
		Fields = @('SoDuDauKy','PhatSinhTang','PhatSinhGiam','SoDuCuoiKy','NgayChungTu','SoChungTu','LoaiChungTu','DienGiai','SoTien','SoDuLuyKe')
	}
	@{
		Name = 'BaoCaoTuoiNo'
		Query = 'aging.sql'
		Register = 'CongNoPhaiThu'
		Filters = @('LoaiCongNo','NgayChot','PhapNhan','DoiTac','HopDong')
		Fields = @('TrongHan','QuaHan1Den30','QuaHan31Den60','QuaHan61Den90','Tren90Ngay','ChuaXacDinhHan','SoDuConLai','SoNgayDenHan','SoNgayQuaHan','ChungTuGoc')
	}
)

foreach ($Contract in $ReportContracts) {
	$ReportPath = Join-Path $ConfigurationPath "Reports\$($Contract.Name).xml"
	Check (Test-Path $ReportPath) "$($Contract.Name): report metadata is missing"
	$TemplateMetadataPath = Join-Path $ConfigurationPath "Reports\$($Contract.Name)\Templates\ОсновнаяСхемаКомпоновкиДанных.xml"
	$TemplatePath = Join-Path $ConfigurationPath "Reports\$($Contract.Name)\Templates\ОсновнаяСхемаКомпоновкиДанных\Ext\Template.xml"
	Check (Test-Path $TemplateMetadataPath) "$($Contract.Name): SKD template metadata is missing"
	Check (Test-Path $TemplatePath) "$($Contract.Name): SKD template payload is missing"
	if (-not (Test-Path $ReportPath) -or -not (Test-Path $TemplateMetadataPath) -or -not (Test-Path $TemplatePath)) { continue }

	$Report = Read-Xml $ReportPath
	$ReportName = $Report.SelectSingleNode("//*[local-name()='Report']/*[local-name()='Properties']/*[local-name()='Name']")
	Check (($null -ne $ReportName) -and ($ReportName.InnerText -eq $Contract.Name)) "$($Contract.Name): metadata object name is incorrect"
	$SchemaRef = $Report.SelectSingleNode("//*[local-name()='Report']/*[local-name()='Properties']/*[local-name()='MainDataCompositionSchema']")
	$ExpectedSchemaRef = 'Report.' + $Contract.Name + '.Template.ОсновнаяСхемаКомпоновкиДанных'
	$SchemaRefMessage = $Contract.Name + ': main SKD template reference is incorrect'
	Check (($null -ne $SchemaRef) -and ($SchemaRef.InnerText -eq $ExpectedSchemaRef)) $SchemaRefMessage
	$TemplateRef = $Report.SelectSingleNode("//*[local-name()='Report']/*[local-name()='ChildObjects']/*[local-name()='Template']")
	Check (($null -ne $TemplateRef) -and ($TemplateRef.InnerText -eq 'ОсновнаяСхемаКомпоновкиДанных')) "$($Contract.Name): report template child reference is incorrect"
	$TemplateMetadata = Read-Xml $TemplateMetadataPath
	$TemplateType = $TemplateMetadata.SelectSingleNode("//*[local-name()='Template']/*[local-name()='Properties']/*[local-name()='TemplateType']")
	Check (($null -ne $TemplateType) -and ($TemplateType.InnerText -eq 'DataCompositionSchema')) "$($Contract.Name): template metadata type is incorrect"
	$TemplateDocument = Read-Xml $TemplatePath
	$TemplateQuery = $TemplateDocument.SelectSingleNode("//*[local-name()='dataSet']/*[local-name()='query']")
	$TemplateText = [System.IO.File]::ReadAllText((Resolve-Path $TemplatePath))
	$QueryPath = Join-Path $PSScriptRoot ('report-queries\' + $Contract.Query)
	Check (Test-Path $QueryPath) "$($Contract.Name): source query file is missing"
	if (Test-Path $QueryPath) {
		$QueryText = [System.IO.File]::ReadAllText((Resolve-Path $QueryPath))
		$NormalizedQuery = [regex]::Replace($QueryText.Trim(), '\s+', ' ')
		$NormalizedTemplateQuery = if ($null -ne $TemplateQuery) { [regex]::Replace($TemplateQuery.InnerText.Trim(), '\s+', ' ') } else { '' }
		Check ($NormalizedTemplateQuery -eq $NormalizedQuery) "$($Contract.Name): compiled SKD query differs from checked-in query source"
		if ($Contract.Name -in @('SoChiTietCongNoAR','SoChiTietCongNoAP')) {
			Check ($QueryText.Contains('Movement.Period >= &NgayBatDau') -and $QueryText.Contains('Movement.Period < DATEADD(&NgayKetThuc, DAY, 1)')) "$($Contract.Name): selected date range must include both full calendar days with DATEADD"
			Check ($QueryText.Contains('Balance(DATEADD(&NgayKetThuc, DAY, 1), )')) "$($Contract.Name): closing balance must include all movements through the selected end date"
			Check ($QueryText.Contains('Movement.Active = TRUE')) "$($Contract.Name): unposted accumulation-register movements must be excluded"
			Check ($TemplateText.Contains('2026-01-01T00:00:00') -and $TemplateText.Contains('2026-10-22T00:00:00')) "$($Contract.Name): start and end dates must have usable initial values"
			Check ($TemplateText.Contains('EvalExpression(') -and -not $TemplateText.Contains('RunningTotal')) "$($Contract.Name): running balance must use a supported DCS expression"
		} else {
			$DefinitionPath = Join-Path $PSScriptRoot ('report-definitions\' + $Contract.Name + '.json')
			$DefinitionText = if (Test-Path $DefinitionPath) { [System.IO.File]::ReadAllText((Resolve-Path $DefinitionPath)) } else { '' }
			Check ($QueryText.Contains('Balance(DATEADD(&NgayChot, DAY, 1), )')) 'BaoCaoTuoiNo: closing-date balances must include movements through the entire selected day'
			Check ($TemplateText.Contains('2026-10-22T00:00:00')) 'BaoCaoTuoiNo: closing date must have a usable initial value'
			Check ($QueryText.Contains('ChuaXacDinhHan') -and $QueryText.Contains('QuaHan1Den30') -and $QueryText.Contains('QuaHan31Den60') -and $QueryText.Contains('QuaHan61Den90') -and $QueryText.Contains('Tren90Ngay')) 'BaoCaoTuoiNo: source query must use the six dashboard aging groups'
			Check ($QueryText.Contains('DATEADD(BEGINOFPERIOD(') -and $QueryText.Contains('DATEDIFF(') -and -not $QueryText.Contains('HanThanhToanNgay * 86400')) 'BaoCaoTuoiNo: due-date arithmetic must use supported DATEADD/DATEDIFF functions'
			Check ($DefinitionText.Contains('LoaiCongNo = _ @off @user')) 'BaoCaoTuoiNo: optional AR/AP filter must be off by default so both debt types appear'
		}
	}
	Check ($TemplateText.Contains($Contract.Register)) "$($Contract.Name): SKD query does not read $($Contract.Register)"
	foreach ($Filter in $Contract.Filters) {
		Check ($TemplateText.Contains($Filter)) "$($Contract.Name): filter/parameter '$Filter' is missing from its SKD template"
	}
	foreach ($Field in $Contract.Fields) {
		Check ($TemplateText.Contains($Field)) "$($Contract.Name): output field '$Field' is missing from its SKD template"
	}
}

foreach ($SubsystemName in @('PhanHePhaiThu','PhanHePhaiTra')) {
	$SubsystemPath = Join-Path $ConfigurationPath "Subsystems\$SubsystemName.xml"
	Check (Test-Path $SubsystemPath) "${SubsystemName}: subsystem metadata is missing"
	if (Test-Path $SubsystemPath) {
		$SubsystemText = [System.IO.File]::ReadAllText((Resolve-Path $SubsystemPath))
		if ($SubsystemName -eq 'PhanHePhaiThu') {
			Check ($SubsystemText.Contains('Report.SoChiTietCongNoAR') -and $SubsystemText.Contains('Report.BaoCaoTuoiNo')) "${SubsystemName}: AR ledger/aging reports are absent from navigation"
		} else {
			Check ($SubsystemText.Contains('Report.SoChiTietCongNoAP') -and $SubsystemText.Contains('Report.BaoCaoTuoiNo')) "${SubsystemName}: AP ledger/aging reports are absent from navigation"
		}
	}
}

$CommandInterfacePath = Join-Path $ConfigurationPath 'Ext\MainSectionCommandInterface.xml'
Check (Test-Path $CommandInterfacePath) 'Main section command interface is missing'
if (Test-Path $CommandInterfacePath) {
	$CommandInterface = Read-Xml $CommandInterfacePath
	foreach ($Contract in $ReportContracts) {
		$CommandName = 'Report.' + $Contract.Name + '.StandardCommand.Open'
		$VisibleCommand = $CommandInterface.SelectSingleNode("/*[local-name()='CommandInterface']/*[local-name()='CommandsVisibility']/*[local-name()='Command' and @name='$CommandName']/*[local-name()='Visibility']/*[local-name()='Common']")
		$PlacedCommand = $CommandInterface.SelectSingleNode("/*[local-name()='CommandInterface']/*[local-name()='CommandsPlacement']/*[local-name()='Command' and @name='$CommandName']")
		$OrderedCommand = $CommandInterface.SelectSingleNode("/*[local-name()='CommandInterface']/*[local-name()='CommandsOrder']/*[local-name()='Command' and @name='$CommandName']")
		$PlacementGroup = if ($null -ne $PlacedCommand) { $PlacedCommand.SelectSingleNode("*[local-name()='CommandGroup']") } else { $null }
		$PlacementMode = if ($null -ne $PlacedCommand) { $PlacedCommand.SelectSingleNode("*[local-name()='Placement']") } else { $null }
		$OrderGroup = if ($null -ne $OrderedCommand) { $OrderedCommand.SelectSingleNode("*[local-name()='CommandGroup']") } else { $null }
		Check (($null -ne $VisibleCommand) -and ($VisibleCommand.InnerText -eq 'true')) "$($Contract.Name): report Open command is not visible in the main command interface"
		Check (($null -ne $PlacementGroup) -and ($PlacementGroup.InnerText -eq 'NavigationPanelOrdinary') -and ($null -ne $PlacementMode) -and ($PlacementMode.InnerText -eq 'Manual')) "$($Contract.Name): report Open command is not placed in the navigation panel"
		Check (($null -ne $OrderGroup) -and ($OrderGroup.InnerText -eq 'NavigationPanelOrdinary')) "$($Contract.Name): report command navigation order is missing"
	}
}

$RoleContracts = @(
	@{ Name = 'KeToanPhaiThu'; Reports = @('SoChiTietCongNoAR','BaoCaoTuoiNo'); DeniedReports = @('SoChiTietCongNoAP') }
	@{ Name = 'KeToanPhaiTra'; Reports = @('SoChiTietCongNoAP','BaoCaoTuoiNo'); DeniedReports = @('SoChiTietCongNoAR') }
	@{ Name = 'GiamDocTaiChinh_CFO'; Reports = @('SoChiTietCongNoAR','SoChiTietCongNoAP','BaoCaoTuoiNo'); DeniedReports = @() }
	@{ Name = 'QuanTriHeThong'; Reports = @('SoChiTietCongNoAR','SoChiTietCongNoAP','BaoCaoTuoiNo'); DeniedReports = @() }
)
foreach ($RoleContract in $RoleContracts) {
	$RightsPath = Join-Path $ConfigurationPath "Roles\$($RoleContract.Name)\Ext\Rights.xml"
	Check (Test-Path $RightsPath) "$($RoleContract.Name): role rights file is missing"
	if (-not (Test-Path $RightsPath)) { continue }
	$Rights = Read-Xml $RightsPath
	$DefaultReportRight = $Rights.SelectSingleNode("/*[local-name()='Rights']/*[local-name()='setForNewObjects']")
	foreach ($ReportName in $RoleContract.Reports) {
		$ReportObject = $Rights.SelectSingleNode("//*[local-name()='object'][*[local-name()='name' and text()='Report.$ReportName']]")
		$UseRight = if ($null -ne $ReportObject) { $ReportObject.SelectSingleNode("*[local-name()='right'][*[local-name()='name' and text()='Use']]/*[local-name()='value']") } else { $null }
		$ViewRight = if ($null -ne $ReportObject) { $ReportObject.SelectSingleNode("*[local-name()='right'][*[local-name()='name' and text()='View']]/*[local-name()='value']") } else { $null }
		$EffectiveUse = if ($null -ne $UseRight) { $UseRight.InnerText -eq 'true' } else { ($null -ne $DefaultReportRight) -and ($DefaultReportRight.InnerText -eq 'true') }
		$EffectiveView = if ($null -ne $ViewRight) { $ViewRight.InnerText -eq 'true' } else { ($null -ne $DefaultReportRight) -and ($DefaultReportRight.InnerText -eq 'true') }
		$ReadMessage = $RoleContract.Name + ': Report.' + $ReportName + ' must be effectively readable (Use + View)'
		Check ($EffectiveUse -and $EffectiveView) $ReadMessage
	}
	foreach ($ReportName in $RoleContract.DeniedReports) {
		$ReportObject = $Rights.SelectSingleNode("//*[local-name()='object'][*[local-name()='name' and text()='Report.$ReportName']]")
		$UseRight = if ($null -ne $ReportObject) { $ReportObject.SelectSingleNode("*[local-name()='right'][*[local-name()='name' and text()='Use']]/*[local-name()='value']") } else { $null }
		$ViewRight = if ($null -ne $ReportObject) { $ReportObject.SelectSingleNode("*[local-name()='right'][*[local-name()='name' and text()='View']]/*[local-name()='value']") } else { $null }
		$DenyMessage = $RoleContract.Name + ': cross-module Report.' + $ReportName + ' must be explicitly denied'
		Check (($null -ne $UseRight) -and ($UseRight.InnerText -eq 'false') -and ($null -ne $ViewRight) -and ($ViewRight.InnerText -eq 'false')) $DenyMessage
	}
}

$DashboardTemplatePath = Join-Path $ConfigurationPath 'CommonTemplates\MauHTMLTrangChu\Ext\Template.txt'
$DashboardModulePath = Join-Path $ConfigurationPath 'DataProcessors\BanLamViecWebERP\Forms\FormBanLamViec\Ext\Form\Module.bsl'
$DashboardServerPath = Join-Path $ConfigurationPath 'CommonModules\BangDieuKhienServer\Ext\Module.bsl'
Check (Test-Path $DashboardTemplatePath) 'Dashboard HTML template is missing'
Check (Test-Path $DashboardModulePath) 'Dashboard form module is missing'
Check (Test-Path $DashboardServerPath) 'Dashboard server module is missing'
if ((Test-Path $DashboardTemplatePath) -and (Test-Path $DashboardModulePath) -and (Test-Path $DashboardServerPath)) {
	$DashboardTemplate = [System.IO.File]::ReadAllText((Resolve-Path $DashboardTemplatePath))
	$DashboardModule = [System.IO.File]::ReadAllText((Resolve-Path $DashboardModulePath))
	$DashboardServer = [System.IO.File]::ReadAllText((Resolve-Path $DashboardServerPath))
	Check (-not $DashboardTemplate.Contains('vinsmart:') -and -not $DashboardTemplate.Contains('vsmart://')) 'Dashboard HTML must not invoke unsupported custom URI protocols'
	Check ($DashboardTemplate.Contains('href="#refresh"') -and $DashboardModule.Contains('refresh')) 'Dashboard refresh must use an in-form native handler'
	Check ($DashboardTemplate.Contains('report_aging=') -and $DashboardModule.Contains('Report.BaoCaoTuoiNo.Form.ReportForm')) 'Dashboard aging chart must expose a native report drill-down'
	Check ($DashboardTemplate.Contains('#open=') -and $DashboardModule.Contains('FindDashboardDocumentAtServer')) 'Dashboard actionable rows must open the exact source document through a whitelist'
	Check ($DashboardServer.Contains('Function TinhTuoiNo(') -and $DashboardServer.Contains('ChuaXacDinhHan')) 'Dashboard must use the shared six-group aging calculation'
	Check ($DashboardServer.Contains('QuaHan1Den30') -and $DashboardServer.Contains('QuaHan31Den60') -and $DashboardServer.Contains('QuaHan61Den90') -and $DashboardServer.Contains('QuaHanTren90')) 'Dashboard shared aging routine is missing a required overdue bucket'
}

Check (Test-Path $ReportRunnerPath) 'Report UI runner is missing'
if (Test-Path $ReportRunnerPath) {
	$ReportRunnerText = [System.IO.File]::ReadAllText((Resolve-Path $ReportRunnerPath))
	Check ($ReportRunnerText.Contains('Function not found') -and $ReportRunnerText.Contains('Parameter value not specified') -and $ReportRunnerText.Contains('Field not found')) 'ReportSmoke must fail on data-composition error messages instead of passing after Generate is clicked'
	Check ($ReportRunnerText.Contains('report_result_screenshot') -or $ReportRunnerText.Contains('report-result.png')) 'ReportSmoke must capture visible generated report output for review'
	Check ($ReportRunnerText.Contains('$VisibleReportGrids') -and $ReportRunnerText.Contains('visible_result_grid_count')) 'ReportSmoke must require a visible output grid after running each report'
	Check ($ReportRunnerText.Contains('$ReportOnly') -and $ReportRunnerText.Contains('No report case matches')) 'ReportSmoke must support isolating one report when diagnosing a failure'
}

$FinanceE2ERunner = if (Test-Path $FinanceE2ERunnerPath) { [System.IO.File]::ReadAllText((Resolve-Path $FinanceE2ERunnerPath)) } else { '' }
$SeedBoundaryTests = if (Test-Path $SeedBoundaryTestsPath) { [System.IO.File]::ReadAllText((Resolve-Path $SeedBoundaryTestsPath)) } else { '' }
Check ($FinanceE2ERunner.Contains("'reporting_values_verify' 'cfo_giamdoc'") -and $SeedBoundaryTests.Contains('Function VerifyFinanceE2EReportValues(')) 'Finance E2E must verify real report totals and balances against posted register data'
Check ($FinanceE2ERunner.Contains('Invoke-FinanceReportUI') -and $FinanceE2ERunner.Contains('Invoke-FinanceGuideUI') -and $FinanceE2ERunner.Contains('report_ui_e2e') -and $FinanceE2ERunner.Contains('finance_guide_ui')) 'Full finance E2E summary must include native report and process-guide UI evidence'

if ($script:Failures.Count -gt 0) {
	Write-Output "FAIL: $($script:Failures.Count) finance reporting contract issue(s)."
	$script:Failures | ForEach-Object { Write-Output " - $_" }
	exit 1
}

Write-Output 'PASS: AR/AP ledger and aging report metadata, SKD fields, filters, and subsystem navigation.'
