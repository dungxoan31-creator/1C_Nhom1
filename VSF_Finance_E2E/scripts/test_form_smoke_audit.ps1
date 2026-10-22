[CmdletBinding()]
param(
	[string]$ResultPath
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$UIScriptPath = Join-Path $PSScriptRoot 'run_finance_ui_e2e.ps1'
$Source = [System.IO.File]::ReadAllText($UIScriptPath, [System.Text.Encoding]::UTF8)
$Failures = [System.Collections.Generic.List[string]]::new()
$FinancialDocuments = @(
	'BienBanNghiemThuGiaiDoan',
	'HoaDonGTGTDauRa',
	'PhieuThuTienKhachHang',
	'HoaDonNhaCungCap',
	'UyNhiemChi',
	'CanTruCongNoNoiBo',
	'DoiSoatKenhThanhToan'
)

foreach ($Contract in @(
	@{ Name = 'active-window UI Automation fallback'; Pattern = 'visible_controls_in_active_window' },
	@{ Name = 'visible form field evidence'; Pattern = 'visible_field_names' },
	@{ Name = 'per-control metadata and state'; Pattern = 'visible_control_details' },
	@{ Name = 'enabled form command evidence'; Pattern = 'enabled_button_names' },
	@{ Name = 'field accessibility assertion'; Pattern = 'visible_edit_count' },
	@{ Name = 'document list Create/Copy actions'; Pattern = 'document_list_actions' },
	@{ Name = 'safe action form open/close'; Pattern = 'Invoke-ListActionForm' },
	@{ Name = 'Print preview UI workflow'; Pattern = 'print_preview_actions' },
	@{ Name = 'runtime partner-contract choice workflow'; Pattern = 'ReferenceChoiceDiagnostics' },
	@{ Name = 'filtered contract choice evidence'; Pattern = 'contract_choice_candidates' }
)) {
	if ($Source -notmatch $Contract.Pattern) {
		$Failures.Add("FormSmoke is missing $($Contract.Name).")
	}
}

$AdminRightsPath = Join-Path $ProjectRoot 'Configuration\Roles\QuanTriHeThong\Ext\Rights.xml'
if (-not (Test-Path -LiteralPath $AdminRightsPath)) {
	$Failures.Add('System Administrator role Rights.xml is missing.')
} else {
	[xml]$AdminRights = [System.IO.File]::ReadAllText($AdminRightsPath, [System.Text.Encoding]::UTF8)
	$ForbiddenPostingRights = @('Posting', 'InteractivePosting', 'InteractivePostingRegular', 'UndoPosting', 'InteractiveUndoPosting')
	foreach ($DocumentName in $FinancialDocuments) {
		$ObjectNode = @($AdminRights.SelectNodes("//*[local-name()='object']") | Where-Object {
			$NameNode = $_.SelectSingleNode("./*[local-name()='name']")
			$null -ne $NameNode -and $NameNode.InnerText -eq "Document.$DocumentName"
		}) | Select-Object -First 1
		if ($null -eq $ObjectNode) {
			$Failures.Add("System Administrator role has no explicit posting restrictions for Document.$DocumentName.")
			continue
		}
		foreach ($RightName in $ForbiddenPostingRights) {
			$RightNode = @($ObjectNode.SelectNodes("./*[local-name()='right']") | Where-Object {
				$NameNode = $_.SelectSingleNode("./*[local-name()='name']")
				$null -ne $NameNode -and $NameNode.InnerText -eq $RightName
			}) | Select-Object -First 1
			$ValueNode = if ($null -ne $RightNode) { $RightNode.SelectSingleNode("./*[local-name()='value']") } else { $null }
			if ($null -eq $ValueNode -or $ValueNode.InnerText -ne 'false') {
				$Failures.Add("System Administrator role must explicitly deny $RightName on Document.$DocumentName.")
			}
		}
	}
}

$DetailForms = @(Get-ChildItem -Path (Join-Path $ProjectRoot 'Configuration\Documents') -Recurse -Filter Form.xml -File |
	Where-Object { $_.FullName -match '\\Forms\\FormChungTu\\Ext\\Form\.xml$' })
if ($DetailForms.Count -ne 7) {
	$Failures.Add("Expected seven custom document detail forms, found $($DetailForms.Count).")
}
foreach ($Form in $DetailForms) {
	[xml]$Xml = [System.IO.File]::ReadAllText($Form.FullName, [System.Text.Encoding]::UTF8)
	$InputFields = @($Xml.DocumentElement.SelectNodes("//*[local-name()='InputField' or local-name()='CheckBoxField' or local-name()='RadioButtonField' or local-name()='CalendarField']"))
	if ($InputFields.Count -eq 0) {
		$Failures.Add("$($Form.FullName) contains no declared input controls.")
	}
}

$DemoFormContracts = @(
	@{ document = 'HoaDonGTGTDauRa'; fields = @('NgayHoaDon', 'TrangThaiHDDT', 'SoHoaDon', 'KyHieu', 'MaCQT', 'NguoiDuyet') },
	@{ document = 'PhieuThuTienKhachHang'; fields = @('ChungTuGoc', 'TienTe', 'TyGia', 'SoTienNgoaiTe') },
	@{ document = 'UyNhiemChi'; fields = @('ChungTuGoc', 'TienTe', 'TyGia', 'SoTienNgoaiTe', 'LaTraSoatHoanTra') }
)
foreach ($Contract in $DemoFormContracts) {
	$FormPath = Join-Path $ProjectRoot ("Configuration\Documents\{0}\Forms\FormChungTu\Ext\Form.xml" -f $Contract.document)
	if (-not (Test-Path -LiteralPath $FormPath)) {
		$Failures.Add("Demo form contract is missing for $($Contract.document).")
		continue
	}
	[xml]$DemoFormXml = [System.IO.File]::ReadAllText($FormPath, [System.Text.Encoding]::UTF8)
	foreach ($FieldName in $Contract.fields) {
		$FieldNode = $DemoFormXml.SelectSingleNode("//*[local-name()='InputField' or local-name()='CheckBoxField'][@name='$FieldName']")
		if ($null -eq $FieldNode -or $FieldNode.SelectSingleNode("./*[local-name()='DataPath']").InnerText -ne "Object.$FieldName") {
			$Failures.Add("$($Contract.document) demo form is missing bound control Object.$FieldName.")
		}
	}
}

$ReceiptFormModule = [System.IO.File]::ReadAllText((Join-Path $ProjectRoot 'Configuration\Documents\PhieuThuTienKhachHang\Forms\FormChungTu\Ext\Form\Module.bsl'), [System.Text.Encoding]::UTF8)
$PaymentFormModule = [System.IO.File]::ReadAllText((Join-Path $ProjectRoot 'Configuration\Documents\UyNhiemChi\Forms\FormChungTu\Ext\Form\Module.bsl'), [System.Text.Encoding]::UTF8)
$ApproverFormModule = [System.IO.File]::ReadAllText((Join-Path $ProjectRoot 'Configuration\DataProcessors\BanLamViecWebERP\Forms\FormPheDuyetHangLoat\Ext\Form\Module.bsl'), [System.Text.Encoding]::UTF8)
foreach ($Contract in @(
	@{ Name = 'receipt source-reference autofill'; Source = $ReceiptFormModule; Pattern = 'Procedure ChungTuGocOnChange' },
	@{ Name = 'payment source-reference autofill'; Source = $PaymentFormModule; Pattern = 'Procedure ChungTuGocOnChange' },
	@{ Name = 'individual Maker-Checker approval action'; Source = $ApproverFormModule; Pattern = 'approve-one:' },
	@{ Name = 'server-side current-queue token validation'; Source = $ApproverFormModule; Pattern = 'Item.ChungTu.UUID\(\)' }
)) {
	if ($Contract.Source -notmatch $Contract.Pattern) {
		$Failures.Add("Demo workflow contract is missing $($Contract.Name).")
	}
}

if ($ResultPath) {
	if (-not (Test-Path -LiteralPath $ResultPath)) {
		$Failures.Add("FormSmoke runtime result was not found: $ResultPath")
	} else {
		$Runtime = Get-Content -LiteralPath $ResultPath -Raw | ConvertFrom-Json
		if ($Runtime.status -ne 'PASS') {
			$Failures.Add("FormSmoke runtime result is not PASS: $($Runtime.status)")
		}
		$RelatedDocumentActions = @($Runtime.related_document_actions | Where-Object { $null -ne $_ })
		$PrintPreviewActions = @($Runtime.print_preview_actions | Where-Object { $null -ne $_ })
		$DocumentAudits = @($Runtime.form_audit | Where-Object { $_.screen -like 'E2E-*' })
		if ($DocumentAudits.Count -ne 7) {
			$Failures.Add("Expected seven Admin document-form command audits, found $($DocumentAudits.Count).")
		}
		foreach ($Audit in $DocumentAudits) {
			$EnabledButtons = @($Audit.enabled_button_names)
			if (@($EnabledButtons | Where-Object { $_ -match '(?i)(^post$|post and close|undo|unpost|cancel posting|ghi sổ|hủy ghi sổ|huy ghi so)' }).Count -gt 0) {
				$Failures.Add("Admin sees an enabled posting or undo-posting command on $($Audit.screen).")
			}
		}
		if ($PrintPreviewActions.Count -ne 7) {
			$Failures.Add("Expected seven document Print preview command audits, found $($PrintPreviewActions.Count).")
		}
		foreach ($DocumentNumber in @('E2E-BB001', 'E2E-AR001', 'E2E-PT001', 'E2E-AP001', 'E2E-UNC01', 'E2E-NET-001', 'E2E-BK-VNPAY-001')) {
			$Action = @($PrintPreviewActions | Where-Object document_number -eq $DocumentNumber)
			if ($Action.Count -ne 1) {
				$Failures.Add("Expected one Print preview result for $DocumentNumber, found $($Action.Count).")
				continue
			}
			if ($Action[0].command_available) {
				if (-not $Action[0].command_enabled -or -not $Action[0].invoked -or
					-not $Action[0].preview_surface_detected -or -not $Action[0].returned_to_form) {
					$Failures.Add("Available Print preview command did not open a preview surface and return to $DocumentNumber.")
				}
				if ([string]::IsNullOrWhiteSpace([string]$Action[0].screenshot_path) -or -not (Test-Path -LiteralPath $Action[0].screenshot_path)) {
					$Failures.Add("Print preview screenshot evidence is missing for $DocumentNumber.")
				}
			} elseif ($Action[0].invoked -or -not $Action[0].returned_to_form -or
				[string]::IsNullOrWhiteSpace([string]$Action[0].command_source)) {
				$Failures.Add("Unavailable Print preview command state was not documented for $DocumentNumber.")
			}
		}
		$AvailablePrintPreviews = @($PrintPreviewActions | Where-Object command_available).Count
		if ($AvailablePrintPreviews -ne 5) {
			$Failures.Add("Expected five documents with Print preview and two documents without a direct or overflow command; found $AvailablePrintPreviews available.")
		}
		if ($RelatedDocumentActions.Count -ne 4) {
			$Failures.Add("Expected four invoked related-document commands with visible notifications, found $($RelatedDocumentActions.Count).")
		}
		foreach ($DocumentNumber in @('E2E-AR001', 'E2E-PT001', 'E2E-AP001', 'E2E-UNC01')) {
			$Action = @($RelatedDocumentActions | Where-Object document_number -eq $DocumentNumber)
			if ($Action.Count -ne 1) {
				$Failures.Add("Expected one related-document command result for $DocumentNumber, found $($Action.Count).")
				continue
			}
			if ($Action[0].command -ne 'Chứng từ liên quan' -or -not $Action[0].command_enabled -or
				-not $Action[0].invoked -or -not $Action[0].notification_visible -or
				-not $Action[0].notification_contains_document_number -or -not $Action[0].notification_matches_expected_chain -or
				-not $Action[0].returned_to_list) {
				$Failures.Add("Related-document UI action did not complete with its document number visible for $DocumentNumber.")
			}
		}
	}
}

if ($Failures.Count -gt 0) {
	$Failures | ForEach-Object { Write-Error $_ -ErrorAction Continue }
	Write-Output ("FAIL FormSmoke UI audit contract: {0} issue(s)." -f $Failures.Count)
	exit 1
}

if ($ResultPath) {
	Write-Output ("PASS FormSmoke UI audit: {0} custom detail forms; five print previews and two unavailable preview states; four related-document notifications verified." -f $DetailForms.Count)
} else {
	Write-Output ("PASS FormSmoke UI audit contract: {0} custom detail forms have input controls; runtime audit and document list Create/Copy actions are wired." -f $DetailForms.Count)
}
