[CmdletBinding()]
param(
	[Parameter(Mandatory = $true)][string]$ConfigurationPath,
	[Parameter(Mandatory = $true)][string]$ArtifactPath,
	[string]$OutputPath
)

$ErrorActionPreference = 'Stop'
foreach ($Path in @($ConfigurationPath, $ArtifactPath)) {
	if (-not (Test-Path -LiteralPath $Path)) { throw "Required custom-command input path is missing: $Path" }
}
if ([string]::IsNullOrWhiteSpace($OutputPath)) {
	$OutputPath = Join-Path $ArtifactPath 'custom-command-coverage.json'
}

$Failures = [System.Collections.Generic.List[string]]::new()
$Definitions = [System.Collections.Generic.List[object]]::new()
$Cases = [System.Collections.Generic.List[object]]::new()
$RelatedDocumentNumbers = @{
	'HoaDonGTGTDauRa' = 'E2E-AR001'
	'PhieuThuTienKhachHang' = 'E2E-PT001'
	'HoaDonNhaCungCap' = 'E2E-AP001'
	'UyNhiemChi' = 'E2E-UNC01'
}
$ExpectedBankCases = @{
	'CmdGuiLenhChiNganHang' = @(
		@{ document_number = 'E2E-UNC01'; expected_status = 'ACCEPTED' }
		@{ document_number = 'E2E-BANK-REJECT'; expected_status = 'HTTP_REJECTED' }
	)
	'CmdXacNhanHoanTienNganHang' = @(
		@{ document_number = 'E2E-REFUND-USD-01'; expected_status = 'REFUND_RECEIVED' }
		@{ document_number = 'E2E-REFUND-USD-DUP'; expected_status = 'REFUND_RECEIVED' }
	)
}
$ExpectedCustomCommandNames = @(
	'CmdXemChungTuLienQuan',
	'CmdGuiLenhChiNganHang',
	'CmdXacNhanHoanTienNganHang',
	'OpenRegisterRecords',
	'ChonTepCSV',
	'XemTruocCSV',
	'GhepHoaDonAR'
)

$DocumentFormsPath = Join-Path $ArtifactPath 'ui-document-forms.json'
if (-not (Test-Path -LiteralPath $DocumentFormsPath)) { throw "Document form UI evidence is missing: $DocumentFormsPath" }
$DocumentForms = Get-Content -LiteralPath $DocumentFormsPath -Raw -Encoding UTF8 | ConvertFrom-Json
if ($DocumentForms.status -ne 'PASS') { $Failures.Add('Document form UI workflow is not PASS.') }

$MetadataFormFiles = @(Get-ChildItem -LiteralPath $ConfigurationPath -Recurse -File -Filter 'Form.xml')
foreach ($MetadataFormFile in $MetadataFormFiles) {
	[xml]$Form = [System.IO.File]::ReadAllText($MetadataFormFile.FullName, [System.Text.Encoding]::UTF8)
	$RelativeFormPath = $MetadataFormFile.FullName.Substring([System.IO.Path]::GetFullPath($ConfigurationPath).Length).TrimStart('\', '/') -replace '/', '\'
	$ObjectNameMatch = [regex]::Match($RelativeFormPath, '^(Documents|DataProcessors)\\([^\\]+)\\')
	$ObjectName = if ($ObjectNameMatch.Success) { $ObjectNameMatch.Groups[2].Value } else { '' }
	foreach ($CommandNode in $Form.SelectNodes("//*[local-name()='Commands']/*[local-name()='Command']")) {
		$CommandName = [string]$CommandNode.GetAttribute('name')
		$ActionNode = $CommandNode.SelectSingleNode('./*[local-name()="Action"]')
		$ActionName = if ($ActionNode) { [string]$ActionNode.InnerText } else { '' }
		$EscapedName = [regex]::Escape($CommandName)
		$ToolbarButtons = @($Form.SelectNodes("//*[local-name()='Button' and *[local-name()='CommandName']]" ) | Where-Object {
			$CommandNameNode = $_.SelectSingleNode('./*[local-name()="CommandName"]')
			$null -ne $CommandNameNode -and $CommandNameNode.InnerText -match ('Form\.Command\.' + $EscapedName + '$')
		})
		$Definition = [PSCustomObject]@{
			object_name = $ObjectName
			form_path = $RelativeFormPath
			command_name = $CommandName
			action_name = $ActionName
			toolbar_button_count = $ToolbarButtons.Count
		}
		$Definitions.Add($Definition)
		if ($CommandName -notin $ExpectedCustomCommandNames) {
			$Failures.Add("Custom command has no runtime evidence mapping: $RelativeFormPath::$CommandName")
			continue
		}
		if ([string]::IsNullOrWhiteSpace($ActionName)) { $Failures.Add("Custom command has no Action handler: $RelativeFormPath::$CommandName") }
		if ($ToolbarButtons.Count -eq 0) { $Failures.Add("Custom command has no toolbar button binding: $RelativeFormPath::$CommandName") }

		if ($CommandName -eq 'OpenRegisterRecords') {
			$RegisterPage = $Form.SelectSingleNode("//*[local-name()='Page' and @name='RegisterRecordsTab']")
			$ExpectedRegisterPages = if ($RegisterPage) {
				@($RegisterPage.SelectNodes("./*[local-name()='ChildItems']/*[local-name()='Pages']/*[local-name()='ChildItems']/*[local-name()='Page']"))
			} else { @() }
			$ExpectedRegisterTitles = @($ExpectedRegisterPages | ForEach-Object {
				$TitleNode = $_.SelectSingleNode("./*[local-name()='Title']//*[local-name()='content']")
				if ($TitleNode) { [string]$TitleNode.InnerText } else { [string]$_.GetAttribute('name') }
			})
			$RegisterAction = @($DocumentForms.register_record_actions | Where-Object { $_.document_type -eq $ObjectName }) | Select-Object -First 1
			$ActualRegisterTitles = if ($RegisterAction) { @($RegisterAction.register_tabs) } else { @() }
			$MissingRegisterTitles = @($ExpectedRegisterTitles | Where-Object { $_ -notin $ActualRegisterTitles })
			$Passed = $null -ne $RegisterAction -and $RegisterAction.command_visible_in_more -and
				$RegisterAction.command_invoked -and $RegisterAction.viewer_tab_visible -and
				$ExpectedRegisterPages.Count -gt 0 -and $MissingRegisterTitles.Count -eq 0
			if (-not $Passed) { $Failures.Add("Register-record command lacks runtime viewer evidence for $ObjectName / $($RegisterAction.document_number). Missing tabs: $($MissingRegisterTitles -join ', ').") }
			$Cases.Add([PSCustomObject]@{
				command_name = $CommandName
				object_name = $ObjectName
				document_number = if ($RegisterAction) { [string]$RegisterAction.document_number } else { '' }
				command_visible_in_more = [bool]($RegisterAction -and $RegisterAction.command_visible_in_more)
				invoked = [bool]($RegisterAction -and $RegisterAction.command_invoked)
				viewer_tab_visible = [bool]($RegisterAction -and $RegisterAction.viewer_tab_visible)
				expected_register_tabs = $ExpectedRegisterTitles
				actual_register_tabs = $ActualRegisterTitles
				passed = [bool]$Passed
			})
			continue
		}

		if ($CommandName -in @('ChonTepCSV', 'XemTruocCSV', 'GhepHoaDonAR')) {
			$ReconciliationAction = @($DocumentForms.register_record_actions | Where-Object { $_.document_type -eq 'DoiSoatKenhThanhToan' }) | Select-Object -First 1
			$ReconciliationAudit = if ($ReconciliationAction) {
				@($DocumentForms.form_audit | Where-Object { $_.screen -eq $ReconciliationAction.document_number }) | Select-Object -First 1
			} else { $null }
			$ExpectedPhase = if ($CommandName -eq 'GhepHoaDonAR') { 'csv_match_post' } else { 'csv_import_preview' }
			$PhasePath = Join-Path $ArtifactPath ($ExpectedPhase + '.json')
			$PhaseResult = if (Test-Path -LiteralPath $PhasePath) { Get-Content -LiteralPath $PhasePath -Raw -Encoding UTF8 | ConvertFrom-Json } else { $null }
			$PhaseData = if ($PhaseResult) { $PhaseResult.data } else { $null }
			$CsvButtonAvailable = $null -ne $ReconciliationAudit -and $CommandName -in @($ReconciliationAudit.enabled_button_names)
			$CsvPageVisible = $null -ne $ReconciliationAudit -and
				'CsvFileName:' -in @($ReconciliationAudit.visible_field_names) -and
				'CsvPreviewSummary:' -in @($ReconciliationAudit.visible_field_names) -and
				@($ReconciliationAudit.visible_table_controls | Where-Object { $_.control_type -eq 'ControlType.Table' -and @($_.bounds).Count -eq 4 -and $_.bounds[2] -gt 0 -and $_.bounds[3] -gt 0 }).Count -eq 1
			$CsvPhaseValid = $null -ne $PhaseResult -and $PhaseResult.status -eq 'PASS'
			if ($CommandName -eq 'ChonTepCSV') {
				$CsvPhaseValid = $CsvPhaseValid -and $PhaseData.preview_rows -eq 1 -and $PhaseData.preview_gross_vnd -eq 75000000 -and $PhaseData.manual_confirmation_required
			} elseif ($CommandName -eq 'XemTruocCSV') {
				$CsvPhaseValid = $CsvPhaseValid -and $PhaseData.preview_rows -eq 1 -and $PhaseData.preview_fee_vnd -eq 1125000 -and $PhaseData.preview_net_vnd -eq 73875000
			} else {
				$CsvPhaseValid = $CsvPhaseValid -and $PhaseData.posted -and $PhaseData.gross_vnd -eq 75000000 -and
					$PhaseData.cash_delta_vnd -eq 73875000 -and $PhaseData.ar_after_vnd -eq 145000000
			}
			$Passed = $CsvButtonAvailable -and $CsvPageVisible -and $CsvPhaseValid
			if (-not $Passed) { $Failures.Add("$CommandName is not bound to the visible reconciliation CSV page or its $ExpectedPhase runtime evidence failed.") }
			$Cases.Add([PSCustomObject]@{
				command_name = $CommandName
				object_name = $ObjectName
				document_number = if ($ReconciliationAction) { [string]$ReconciliationAction.document_number } else { '' }
				command_available = [bool]$CsvButtonAvailable
				ui_page_visible = [bool]$CsvPageVisible
				runtime_phase = $ExpectedPhase
				runtime_phase_status = if ($PhaseResult) { [string]$PhaseResult.status } else { '' }
				passed = [bool]$Passed
			})
			continue
		}

		if ($CommandName -eq 'CmdXemChungTuLienQuan') {
			if (-not $RelatedDocumentNumbers.ContainsKey($ObjectName)) {
				$Failures.Add("No related-document runtime fixture mapping exists for $ObjectName.")
				continue
			}
			$DocumentNumber = $RelatedDocumentNumbers[$ObjectName]
			$Case = @($DocumentForms.related_document_actions | Where-Object { $_.document_number -eq $DocumentNumber }) | Select-Object -First 1
			$Passed = $null -ne $Case -and $Case.invoked -and $Case.notification_visible -and $Case.notification_matches_expected_chain
			if (-not $Passed) { $Failures.Add("Related-document command did not produce its expected chain for $DocumentNumber.") }
			$Cases.Add([PSCustomObject]@{
				command_name = $CommandName
				object_name = $ObjectName
				document_number = $DocumentNumber
				invoked = [bool]($Case -and $Case.invoked)
				outcome = if ($Case) { [string]$Case.notification_text } else { '' }
				passed = [bool]$Passed
			})
			continue
		}

		foreach ($ExpectedCase in $ExpectedBankCases[$CommandName]) {
			$EvidencePath = Join-Path $ArtifactPath ("ui-bank-{0}.json" -f $ExpectedCase.document_number)
			$Evidence = $null
			if (Test-Path -LiteralPath $EvidencePath) {
				$Evidence = Get-Content -LiteralPath $EvidencePath -Raw -Encoding UTF8 | ConvertFrom-Json
			}
			$ExpectedWorkflow = if ($CommandName -eq 'CmdGuiLenhChiNganHang') { 'BankSend' } else { 'RefundConfirm' }
			$InvocationText = if ($CommandName -eq 'CmdGuiLenhChiNganHang') { 'bank payment submission command invoked' } else { 'incoming refund confirmation command invoked' }
			$Passed = $null -ne $Evidence -and $Evidence.status -eq 'PASS' -and
				$Evidence.workflow -eq $ExpectedWorkflow -and $Evidence.bank_status -eq $ExpectedCase.expected_status -and
				@($Evidence.verified | Where-Object { $_ -ceq $InvocationText }).Count -gt 0
			if (-not $Passed) { $Failures.Add("$CommandName runtime evidence failed for $($ExpectedCase.document_number) / $($ExpectedCase.expected_status).") }
			$Cases.Add([PSCustomObject]@{
				command_name = $CommandName
				object_name = $ObjectName
				document_number = $ExpectedCase.document_number
				workflow = if ($Evidence) { [string]$Evidence.workflow } else { '' }
				expected_bank_status = $ExpectedCase.expected_status
				actual_bank_status = if ($Evidence) { [string]$Evidence.bank_status } else { '' }
				invoked = [bool]($Evidence -and @($Evidence.verified | Where-Object { $_ -ceq $InvocationText }).Count -gt 0)
				passed = [bool]$Passed
			})
		}
	}
}

$DefinitionCounts = @{
	'CmdXemChungTuLienQuan' = 4
	'CmdGuiLenhChiNganHang' = 1
	'CmdXacNhanHoanTienNganHang' = 1
	'OpenRegisterRecords' = 7
	'ChonTepCSV' = 1
	'XemTruocCSV' = 1
	'GhepHoaDonAR' = 1
}
foreach ($CommandName in $ExpectedCustomCommandNames) {
	$ActualCount = @($Definitions | Where-Object command_name -eq $CommandName).Count
	if ($ActualCount -ne $DefinitionCounts[$CommandName]) {
		$Failures.Add("Expected $($DefinitionCounts[$CommandName]) metadata definitions for $CommandName, found $ActualCount.")
	}
}

$Summary = [ordered]@{
	status = if ($Failures.Count -eq 0 -and $Cases.Count -eq 18 -and @($Cases | Where-Object passed).Count -eq 18) { 'PASS' } else { 'FAIL' }
	command_definition_count = $Definitions.Count
	toolbar_button_binding_count = @($Definitions | Where-Object toolbar_button_count -gt 0).Count
	runtime_case_count = $Cases.Count
	runtime_passed_count = @($Cases | Where-Object passed).Count
	definitions = $Definitions.ToArray()
	cases = $Cases.ToArray()
	failures = $Failures.ToArray()
	output_path = [System.IO.Path]::GetFullPath($OutputPath)
}
$OutputDirectory = Split-Path -Parent $OutputPath
if (-not (Test-Path -LiteralPath $OutputDirectory)) { New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null }
[System.IO.File]::WriteAllText($OutputPath, ($Summary | ConvertTo-Json -Depth 8), [System.Text.UTF8Encoding]::new($false))
$Summary | ConvertTo-Json -Depth 8
if ($Summary.status -ne 'PASS') { throw "Custom command runtime coverage failed with $($Failures.Count) issue(s)." }
