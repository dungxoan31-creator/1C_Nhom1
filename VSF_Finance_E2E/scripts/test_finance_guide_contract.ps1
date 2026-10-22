[CmdletBinding()]
param(
	[string]$ConfigurationPath = (Join-Path $PSScriptRoot '..\Configuration'),
	[string]$DocsPath = (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) 'docs')
)

$ErrorActionPreference = 'Stop'
$ConfigurationPath = (Resolve-Path $ConfigurationPath).Path
$DocsPath = (Resolve-Path $DocsPath).Path
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$script:Failures = [System.Collections.Generic.List[string]]::new()

function Check([bool]$Condition, [string]$Message) {
	if (-not $Condition) { $script:Failures.Add($Message) }
}

function Read-Text([string]$Path) {
	if (-not (Test-Path -LiteralPath $Path)) { return '' }
	return [System.IO.File]::ReadAllText((Resolve-Path $Path))
}

$TemplateName = 'MauHTMLHuongDanQuyTrinhTaiChinh'
$ProcessorName = 'HuongDanQuyTrinhTaiChinh'
$FormName = 'FormHuongDanQuyTrinhTaiChinh'
$TemplateMetadataPath = Join-Path $ConfigurationPath "CommonTemplates\$TemplateName.xml"
$TemplateContentPath = Join-Path $ConfigurationPath "CommonTemplates\$TemplateName\Ext\Template.txt"
$ProcessorPath = Join-Path $ConfigurationPath "DataProcessors\$ProcessorName.xml"
$FormMetadataPath = Join-Path $ConfigurationPath "DataProcessors\$ProcessorName\Forms\$FormName.xml"
$FormXmlPath = Join-Path $ConfigurationPath "DataProcessors\$ProcessorName\Forms\$FormName\Ext\Form.xml"
$FormModulePath = Join-Path $ConfigurationPath "DataProcessors\$ProcessorName\Forms\$FormName\Ext\Form\Module.bsl"
$ConfigurationXml = Read-Text (Join-Path $ConfigurationPath 'Configuration.xml')
$SubsystemXml = Read-Text (Join-Path $ConfigurationPath 'Subsystems\PhanHeSoCaiVaDongBo.xml')
$DashboardTemplate = Read-Text (Join-Path $ConfigurationPath 'CommonTemplates\MauHTMLTrangChu\Ext\Template.txt')
$DashboardModule = Read-Text (Join-Path $ConfigurationPath 'DataProcessors\BanLamViecWebERP\Forms\FormBanLamViec\Ext\Form\Module.bsl')
$Template = Read-Text $TemplateContentPath
$GuideModule = Read-Text $FormModulePath
$Demo = Read-Text (Join-Path $DocsPath 'Kich_ban_demo_VinSmart_Future.md')
$Checklist = Read-Text (Join-Path $DocsPath 'Checklist_danh_gia_thanh_vien.md')
$UiRunner = Read-Text (Join-Path $ProjectRoot 'VSF_Finance_E2E\scripts\run_finance_ui_e2e.ps1')

foreach ($Path in @($TemplateMetadataPath,$TemplateContentPath,$ProcessorPath,$FormMetadataPath,$FormXmlPath,$FormModulePath)) {
	Check (Test-Path -LiteralPath $Path) "Required guide configuration file is missing: $Path"
}
Check ($ConfigurationXml.Contains("<DataProcessor>$ProcessorName</DataProcessor>") -and $ConfigurationXml.Contains("<CommonTemplate>$TemplateName</CommonTemplate>")) 'Configuration.xml must register the guide processor and shared template'
Check ($SubsystemXml.Contains("DataProcessor.$ProcessorName")) 'Finance navigation subsystem must expose the guide processor'
Check ($DashboardTemplate.Contains('href="#finance_guide"') -and $DashboardModule.Contains("OpenForm(`"DataProcessor.$ProcessorName.Form.$FormName`")")) 'Dashboard must expose a native route to the guide form'

foreach ($Anchor in @('AR','AP','CanTru','DoiSoatCSV','TaiKhoanVaChuyenDongSo')) {
	Check ($Template.Contains('id="' + $Anchor + '"')) "Guide template is missing anchor '$Anchor'"
}
foreach ($Route in @('AR','AP','CanTru','DoiSoatCSV','TaiKhoanVaChuyenDongSo','ReportAR','ReportAP','ReportAging')) {
	Check ($Template.Contains('href="route=' + $Route + '"') -and $GuideModule.Contains('route=' + $Route)) "Guide route '$Route' is not wired through the allowlisted native router"
}
foreach ($Target in @('Document.BienBanNghiemThuGiaiDoan.ObjectForm','Document.HoaDonGTGTDauRa.ObjectForm','Document.PhieuThuTienKhachHang.ObjectForm','Document.HoaDonNhaCungCap.ObjectForm','Document.UyNhiemChi.ObjectForm','Document.CanTruCongNoNoiBo.ObjectForm','Document.DoiSoatKenhThanhToan.ObjectForm','Report.SoChiTietCongNoAR.Form.ReportForm','Report.SoChiTietCongNoAP.Form.ReportForm','Report.BaoCaoTuoiNo.Form.ReportForm')) {
	Check ($GuideModule.Contains($Target)) "Guide router does not map the approved target '$Target'"
}
Check (-not $GuideModule.Contains('OpenForm("Document." +')) 'Guide router must not open a document type parsed from arbitrary HTML'
Check ($UiRunner.Contains('GuideSmoke') -and $UiRunner.Contains('finance_guide_ui')) 'Native UI runner must include the finance guide smoke case'

foreach ($Amount in @('200.000.000 VND','20.000.000 VND','220.000.000 VND','100.000.000 VND','10.000.000 VND','110.000.000 VND','250.000.000 VND','25.000.000 VND','225.000.000 VND','75.000.000 VND','1.125.000 VND','73.875.000 VND','43.200.000 VND','40.000.000 VND','3.200.000 VND')) {
	Check ($Demo.Contains($Amount)) "Demo guide is missing agreed amount '$Amount'"
}
foreach ($Topic in @('## 1. AR:','## 2. AP:','## 3. Cấn trừ','## 4. Đối soát','## 5. Dashboard','Maker-Checker','Báo cáo tuổi nợ','FCT Gross 250 triệu')) {
	Check ($Demo.Contains($Topic)) "Demo guide is missing required flow topic '$Topic'"
}
foreach ($Register in @('SoCaiKeToan','CongNoPhaiThu','CongNoPhaiTra','DongTien')) {
	Check ($Demo.Contains($Register)) "Demo guide is missing register path '$Register'"
}

foreach ($Topic in @('AR','AP','CanTru','CSV','SoCaiKeToan','CongNoPhaiThu','CongNoPhaiTra','Evidence','Điểm','theo dõi')) {
	Check ($Checklist.Contains($Topic)) "Team checklist is missing topic '$Topic'"
}
Check (-not ($Checklist -match '(?im)^\s*(?:Name|Member|Email|Answer|Tên thành viên|Câu trả lời)\s*:\s*\S')) 'Team checklist must leave identity and personal answers blank'
Check (-not ($Checklist -match '(?i)password\s*[:=]\s*\S|[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}')) 'Team checklist must not store credentials or personal contact data'

if ($script:Failures.Count -gt 0) {
	Write-Output "FAIL: $($script:Failures.Count) finance guide contract issue(s)."
	$script:Failures | ForEach-Object { Write-Output " - $_" }
	exit 1
}

Write-Output 'PASS: in-app finance guide, allowlisted native routes, demo flows/amounts, and blank team checklist.'
