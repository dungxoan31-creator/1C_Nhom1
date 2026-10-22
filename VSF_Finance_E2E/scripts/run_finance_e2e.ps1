[CmdletBinding()]
param(
	[string]$OneCExe = 'C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe',
	[string]$BaseInfobase,
	[string]$ConfigurationPath
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
if (-not $BaseInfobase) {
	$BaseInfobase = Join-Path $ProjectRoot 'BaseInfobase'
}
if ([string]::IsNullOrWhiteSpace($ConfigurationPath)) {
	$Configuration = Join-Path $ProjectRoot 'Configuration'
} else {
	if (-not (Test-Path -LiteralPath $ConfigurationPath -PathType Container)) {
		throw "Configuration path does not exist: $ConfigurationPath"
	}
	$Configuration = (Resolve-Path -LiteralPath $ConfigurationPath).Path
}
$ResultsRoot = Join-Path $ProjectRoot 'results'
$RunId = 'finance-e2e-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [guid]::NewGuid().ToString('N')
$TempRoot = Join-Path $env:TEMP ('VSF_' + $RunId)
$ArtifactRoot = Join-Path $ResultsRoot $RunId
$PhaseResults = New-Object System.Collections.Generic.List[object]
$BankUIResults = New-Object System.Collections.Generic.List[object]
$CatalogListUIResult = $null
$ListPeriodUIResult = $null
$DocumentFormsUIResult = $null
$RequiredFieldUIResult = $null
$ARAutofillUIResult = $null
$ReferenceChoiceUIResult = $null
$ReportUIResult = $null
$FinanceGuideUIResult = $null
$ReportValuesVerification = $null
$BatchApprovalUIResult = $null
$BatchApprovalUIVerification = $null
$BatchApprovalUIContract = $null
$CustomCommandCoverage = $null
$ConcurrencyBlocked = $false
$BankStubProcess = $null
$BankStubPort = 17891

function Start-OneCProcess([string]$Arguments) {
	$StartInfo = New-Object System.Diagnostics.ProcessStartInfo
	$StartInfo.FileName = $OneCExe
	$StartInfo.Arguments = $Arguments
	$StartInfo.CreateNoWindow = $true
	$StartInfo.UseShellExecute = $false
	return [System.Diagnostics.Process]::Start($StartInfo)
}

function Wait-OneCProcess([System.Diagnostics.Process]$Process, [string]$LogPath, [int]$TimeoutMs = 600000) {
	if (-not $Process.WaitForExit($TimeoutMs)) {
		$Process.Kill()
		throw "1C process timed out after $TimeoutMs ms. Log: $LogPath"
	}
	return $Process.ExitCode
}

function Invoke-OneCProcess([string]$Arguments, [string]$LogPath, [int]$TimeoutMs = 600000) {
	$Process = Start-OneCProcess $Arguments
	return Wait-OneCProcess $Process $LogPath $TimeoutMs
}

function Copy-RunArtifacts([string]$JsonPath, [string]$LogPath) {
	if (Test-Path -LiteralPath $JsonPath) {
		Copy-Item -LiteralPath $JsonPath -Destination $ArtifactRoot -Force
	}
	if (Test-Path -LiteralPath $LogPath) {
		Copy-Item -LiteralPath $LogPath -Destination $ArtifactRoot -Force
	}
}

function Invoke-FinancePhase([string]$Infobase, [string]$Phase, [string]$User, [string]$ExtraParameters = '') {
	$JsonPath = Join-Path $TempRoot ($Phase + '.json')
	$LogPath = Join-Path $TempRoot ($Phase + '.log')
	$Arguments = 'ENTERPRISE /F"' + $Infobase + '" /N' + $User + ' /CRunFinanceE2E;' + $Phase + ';' + $RunId + ';' + $JsonPath + $ExtraParameters + ' /DisableStartupMessages /Out"' + $LogPath + '"'
	$ExitCode = Invoke-OneCProcess $Arguments $LogPath
	Copy-RunArtifacts $JsonPath $LogPath
	if (-not (Test-Path -LiteralPath $JsonPath)) {
		throw "Phase $Phase produced no result JSON (1C exit $ExitCode). Log: $LogPath"
	}
	$Result = Get-Content -LiteralPath $JsonPath -Raw | ConvertFrom-Json
	if ($ExitCode -ne 0 -or $Result.status -ne 'PASS') {
		throw "Phase $Phase failed for user $User (1C exit $ExitCode): $($Result.error)"
	}
	if ($Phase -eq 'required_reference_post' -and
		(@($Result.data.cases).Count -ne 4 -or $Result.data.failed -or
		@($Result.data.cases | Where-Object { $_.unexpected_posting -or $_.persisted_posted -or ($_.attempt_movement_probe_available -and ($_.attempt_ar_movements -ne 0 -or $_.attempt_gl_movements -ne 0)) -or $_.ar_movements -ne 0 -or $_.gl_movements -ne 0 }).Count -gt 0)) {
		throw "Required-reference posting regression did not reject all four incomplete or inconsistent AR fixtures: $($Result.data | ConvertTo-Json -Depth 8 -Compress)"
	}
	if ($Phase -eq 'required_ap_contract_post' -and
		(@($Result.data.cases).Count -ne 1 -or $Result.data.failed -or
		@($Result.data.cases | Where-Object { $_.unexpected_posting -or $_.persisted_posted -or ($_.attempt_movement_probe_available -and ($_.attempt_ap_movements -ne 0 -or $_.attempt_gl_movements -ne 0)) -or $_.ap_movements -ne 0 -or $_.gl_movements -ne 0 }).Count -gt 0)) {
		throw "AP contract-owner posting regression did not reject the inconsistent invoice: $($Result.data | ConvertTo-Json -Depth 8 -Compress)"
	}
	if ($Phase -eq 'required_field_runtime_matrix') {
		if ($Result.data.status -ne 'PASS' -or $Result.data.case_count -ne 41 -or $Result.data.passed_count -ne 41 -or
			$Result.data.auto_case_count -ne 7 -or $Result.data.auto_passed_count -ne 7 -or
			$Result.data.field_probe_case_count -ne 79 -or $Result.data.field_probe_passed_count -ne 79 -or
			$Result.data.boundary_case_count -ne 7 -or $Result.data.boundary_passed_count -ne 7 -or
			$Result.data.ap_boundary_case_count -ne 8 -or $Result.data.ap_boundary_passed_count -ne 8 -or
			@($Result.data.cases | Where-Object { $_.status -ne 'PASS' -or -not $_.write_rejected -or $_.document_persisted -or -not $_.rolled_back }).Count -gt 0 -or
			@($Result.data.auto_cases | Where-Object { $_.status -ne 'PASS' -or -not $_.write_accepted -or -not $_.automatic_value_valid -or -not $_.rolled_back }).Count -gt 0 -or
			@($Result.data.field_probe_cases | Where-Object { $_.status -ne 'PASS' -or -not $_.write_accepted -or -not $_.document_persisted -or -not $_.round_trip_matches -or -not $_.rolled_back -or $_.persisted_after_rollback }).Count -gt 0 -or
			@($Result.data.boundary_cases | Where-Object { $_.status -ne 'PASS' -or -not $_.rolled_back -or $_.document_persisted_after_rollback }).Count -gt 0 -or
			@($Result.data.ap_boundary_cases | Where-Object { $_.status -ne 'PASS' -or -not $_.rolled_back -or $_.persisted_after_rollback }).Count -gt 0) {
			throw "Required-field runtime matrix assertions failed: $($Result.data | ConvertTo-Json -Depth 8 -Compress)"
		}
		$ContractScript = Join-Path $PSScriptRoot 'test_required_field_matrix.ps1'
		$ContractArgs = '-NoProfile -ExecutionPolicy Bypass -File "' + $ContractScript + '" -ResultPath "' + $JsonPath + '"'
		$ContractProcess = Start-Process -FilePath 'powershell.exe' -ArgumentList $ContractArgs -PassThru -WindowStyle Hidden
		if (-not $ContractProcess.WaitForExit(30000)) {
			Stop-Process -Id $ContractProcess.Id -Force
			throw 'Required-field runtime metadata and BSL contract timed out.'
		}
		if ($ContractProcess.ExitCode -ne 0) { throw 'Required-field runtime metadata and BSL contract failed.' }
	}
	$PhaseResults.Add($Result)
	Write-Host ("PASS {0} ({1})" -f $Phase, $User)
	return $Result
}

function Invoke-FinanceBankUI([string]$Infobase, [string]$PaymentNumber, [string]$ExpectedOutcome, [string]$User) {
	$Workflow = if ($ExpectedOutcome -eq 'RefundReceived') { 'RefundConfirm' } else { 'BankSend' }
	$ResultPath = Join-Path $TempRoot ('ui-bank-' + $PaymentNumber + '.json')
	$ScriptPath = Join-Path $PSScriptRoot 'run_finance_ui_e2e.ps1'
	$Arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $ScriptPath + '" -OneCExe "' + $OneCExe + '" -Infobase "' + $Infobase + '" -User ' + $User + ' -Workflow ' + $Workflow + ' -ExpectedPaymentNumber ' + $PaymentNumber + ' -ExpectedBankOutcome ' + $ExpectedOutcome + ' -ResultPath "' + $ResultPath + '"'
	$Process = Start-Process -FilePath 'powershell.exe' -ArgumentList $Arguments -PassThru
	if (-not $Process.WaitForExit(180000)) {
		Stop-Process -Id $Process.Id -Force
		throw "Native 1C bank UI workflow timed out for $PaymentNumber."
	}
	if (-not (Test-Path -LiteralPath $ResultPath)) { throw "Native 1C bank UI workflow produced no result for $PaymentNumber (exit $($Process.ExitCode))." }
	$Result = Get-Content -LiteralPath $ResultPath -Raw | ConvertFrom-Json
	Copy-Item -LiteralPath $ResultPath -Destination $ArtifactRoot -Force
	if ($Process.ExitCode -ne 0 -or $Result.status -ne 'PASS') {
		throw "Native 1C bank UI workflow failed for ${PaymentNumber}: $($Result | ConvertTo-Json -Depth 8 -Compress)"
	}
	$BankUIResults.Add($Result)
	Write-Host ("PASS native 1C {0} UI workflow ({1}; {2})" -f $Workflow, $PaymentNumber, $ExpectedOutcome)
	return $Result
}

function Invoke-FinanceBatchApprovalUI([string]$Infobase) {
	$ResultPath = Join-Path $TempRoot 'ui-batch-approval.json'
	$ScriptPath = Join-Path $PSScriptRoot 'run_finance_ui_e2e.ps1'
	$Arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $ScriptPath + '" -OneCExe "' + $OneCExe + '" -Infobase "' + $Infobase + '" -User ketoan_truong -Workflow BatchApproval -ResultPath "' + $ResultPath + '"'
	$Process = Start-Process -FilePath 'powershell.exe' -ArgumentList $Arguments -PassThru
	if (-not $Process.WaitForExit(180000)) {
		Stop-Process -Id $Process.Id -Force
		throw 'Native 1C KTT batch approval UI workflow timed out.'
	}
	if (-not (Test-Path -LiteralPath $ResultPath)) { throw "Native 1C KTT batch approval UI workflow produced no result (exit $($Process.ExitCode))." }
	$Result = Get-Content -LiteralPath $ResultPath -Raw -Encoding UTF8 | ConvertFrom-Json
	foreach ($PropertyName in @('screenshot_path', 'after_click_screenshot_path', 'after_approval_screenshot_path')) {
		$SourcePath = [string]$Result.$PropertyName
		if ($SourcePath -and (Test-Path -LiteralPath $SourcePath)) {
			$TargetPath = Join-Path $ArtifactRoot (Split-Path -Leaf $SourcePath)
			Copy-Item -LiteralPath $SourcePath -Destination $TargetPath -Force
			$Result.$PropertyName = $TargetPath
		}
	}
	$Result | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $ResultPath -Encoding UTF8
	Copy-Item -LiteralPath $ResultPath -Destination $ArtifactRoot -Force
	if ($Process.ExitCode -ne 0 -or $Result.status -ne 'PASS') {
		throw "Native 1C KTT batch approval UI workflow failed: $($Result | ConvertTo-Json -Depth 10 -Compress)"
	}
	Write-Host 'PASS native 1C KTT batch approval UI (isolated one-document queue)'
	return $Result
}

function Invoke-FinanceCatalogUI([string]$Infobase) {
	$ContractScript = Join-Path $PSScriptRoot 'test_catalog_ui_coverage.ps1'
	$ContractArgs = '-NoProfile -ExecutionPolicy Bypass -File "' + $ContractScript + '"'
	$ContractProcess = Start-Process -FilePath 'powershell.exe' -ArgumentList $ContractArgs -PassThru -WindowStyle Hidden
	if (-not $ContractProcess.WaitForExit(30000)) {
		Stop-Process -Id $ContractProcess.Id -Force
		throw 'Catalog UI coverage contract timed out.'
	}
	if ($ContractProcess.ExitCode -ne 0) { throw 'Catalog UI coverage contract failed.' }
	Write-Host 'PASS catalog metadata/UI coverage contract (9 catalogs)'

	$ResultPath = Join-Path $TempRoot 'ui-catalog-lists.json'
	$ScriptPath = Join-Path $PSScriptRoot 'run_finance_ui_e2e.ps1'
	$Arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $ScriptPath + '" -OneCExe "' + $OneCExe + '" -Infobase "' + $Infobase + '" -User Admin -Workflow CatalogSmoke -ResultPath "' + $ResultPath + '"'
	$Process = Start-Process -FilePath 'powershell.exe' -ArgumentList $Arguments -PassThru
	if (-not $Process.WaitForExit(180000)) {
		Stop-Process -Id $Process.Id -Force
		throw 'Native 1C catalog list UI workflow timed out.'
	}
	if (-not (Test-Path -LiteralPath $ResultPath)) { throw "Native 1C catalog list UI workflow produced no result (exit $($Process.ExitCode))." }
	$Result = Get-Content -LiteralPath $ResultPath -Raw | ConvertFrom-Json
	Copy-Item -LiteralPath $ResultPath -Destination $ArtifactRoot -Force
	if ($Process.ExitCode -ne 0 -or $Result.status -ne 'PASS' -or @($Result.verified).Count -ne 9 -or @($Result.catalog_screens).Count -ne 9) {
		throw "Native 1C catalog list UI workflow failed: $($Result | ConvertTo-Json -Depth 8 -Compress)"
	}
	$CopyCommandFailures = @($Result.catalog_screens | Where-Object { -not $_.copy_form_opened -or -not $_.copy_form_closed_without_save })
	if ($CopyCommandFailures.Count -gt 0) {
		throw "Catalog Copy command was not exercised for every populated list: $($CopyCommandFailures.metadata_object -join ', ')"
	}
	Write-Host ("PASS native 1C catalog lists ({0}/9)" -f @($Result.catalog_screens).Count)
	return $Result
}

function Invoke-FinanceListPeriodUI([string]$Infobase) {
	$ResultPath = Join-Path $TempRoot 'ui-list-periods.json'
	$ScriptPath = Join-Path $PSScriptRoot 'run_finance_ui_e2e.ps1'
	$Arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $ScriptPath + '" -OneCExe "' + $OneCExe + '" -Infobase "' + $Infobase + '" -User Admin -Workflow ListPeriods -ResultPath "' + $ResultPath + '"'
	$Process = Start-Process -FilePath 'powershell.exe' -ArgumentList $Arguments -PassThru
	if (-not $Process.WaitForExit(180000)) {
		Stop-Process -Id $Process.Id -Force
		throw 'Native 1C list period UI workflow timed out.'
	}
	if (-not (Test-Path -LiteralPath $ResultPath)) { throw "Native 1C list period UI workflow produced no result (exit $($Process.ExitCode))." }
	$Result = Get-Content -LiteralPath $ResultPath -Raw | ConvertFrom-Json
	Copy-Item -LiteralPath $ResultPath -Destination $ArtifactRoot -Force
	if ($Process.ExitCode -ne 0 -or $Result.status -ne 'PASS' -or @($Result.verified).Count -ne 5) {
		throw "Native 1C list period UI workflow failed: $($Result | ConvertTo-Json -Depth 8 -Compress)"
	}
	Write-Host ("PASS native 1C period filters ({0}/5 document lists)" -f @($Result.verified).Count)
	return $Result
}

function Invoke-FinanceDocumentFormsUI([string]$Infobase) {
	foreach ($AuditScriptName in @('test_form_smoke_audit.ps1', 'test_reference_choice_filters.ps1', 'test_paid_invoice_unpost_contract.ps1')) {
		$AuditContractScript = Join-Path $PSScriptRoot $AuditScriptName
		$AuditContractArgs = '-NoProfile -ExecutionPolicy Bypass -File "' + $AuditContractScript + '"'
		if ($AuditScriptName -eq 'test_reference_choice_filters.ps1') {
			$ReferenceChoiceResultPath = Join-Path $TempRoot 'reference-choice-contract.json'
			$AuditContractArgs += ' -ResultPath "' + $ReferenceChoiceResultPath + '"'
		}
		$AuditContractProcess = Start-Process -FilePath 'powershell.exe' -ArgumentList $AuditContractArgs -PassThru -WindowStyle Hidden
		if (-not $AuditContractProcess.WaitForExit(30000)) {
			Stop-Process -Id $AuditContractProcess.Id -Force
			throw "$AuditScriptName timed out."
		}
		if ($AuditContractProcess.ExitCode -ne 0) { throw "$AuditScriptName failed." }
		if ($AuditScriptName -eq 'test_reference_choice_filters.ps1' -and (Test-Path -LiteralPath $ReferenceChoiceResultPath)) {
			Copy-Item -LiteralPath $ReferenceChoiceResultPath -Destination $ArtifactRoot -Force
		}
		Write-Host ("PASS static audit contract ({0})" -f $AuditScriptName)
	}

	$ResultPath = Join-Path $TempRoot 'ui-document-forms.json'
	$ScriptPath = Join-Path $PSScriptRoot 'run_finance_ui_e2e.ps1'
	$Arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $ScriptPath + '" -OneCExe "' + $OneCExe + '" -Infobase "' + $Infobase + '" -User Admin -Workflow FormSmoke -ResultPath "' + $ResultPath + '"'
	$Process = Start-Process -FilePath 'powershell.exe' -ArgumentList $Arguments -PassThru
	if (-not $Process.WaitForExit(360000)) {
		$OrphanedOneCProcesses = @(
			Get-CimInstance Win32_Process |
			Where-Object {
				$_.Name -like '1cv8*' -and
				-not [string]::IsNullOrWhiteSpace([string]$_.CommandLine) -and
				$_.CommandLine.IndexOf($Infobase, [System.StringComparison]::OrdinalIgnoreCase) -ge 0
			} |
			ForEach-Object { [int]$_.ProcessId }
		)
		foreach ($OneCProcessId in $OrphanedOneCProcesses) {
			Stop-Process -Id $OneCProcessId -Force -ErrorAction SilentlyContinue
		}
		Stop-Process -Id $Process.Id -Force -ErrorAction SilentlyContinue
		throw 'Native 1C document form smoke workflow timed out after 360 seconds.'
	}
	if (-not (Test-Path -LiteralPath $ResultPath)) { throw "Native 1C document form smoke workflow produced no result (exit $($Process.ExitCode))." }
	$Result = Get-Content -LiteralPath $ResultPath -Raw | ConvertFrom-Json
	foreach ($PreviewAction in @($Result.print_preview_actions)) {
		if ($PreviewAction.screenshot_path -and (Test-Path -LiteralPath $PreviewAction.screenshot_path)) {
			$ScreenshotArtifactPath = Join-Path $ArtifactRoot (Split-Path -Leaf $PreviewAction.screenshot_path)
			Copy-Item -LiteralPath $PreviewAction.screenshot_path -Destination $ScreenshotArtifactPath -Force
			$PreviewAction.screenshot_path = $ScreenshotArtifactPath
		}
	}
	$Result | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $ResultPath -Encoding UTF8
	Copy-Item -LiteralPath $ResultPath -Destination $ArtifactRoot -Force
	$RuntimeAuditScript = Join-Path $PSScriptRoot 'test_form_smoke_audit.ps1'
	$RuntimeAuditArguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $RuntimeAuditScript + '" -ResultPath "' + $ResultPath + '"'
	$RuntimeAuditProcess = Start-Process -FilePath 'powershell.exe' -ArgumentList $RuntimeAuditArguments -PassThru -WindowStyle Hidden
	if (-not $RuntimeAuditProcess.WaitForExit(30000)) {
		Stop-Process -Id $RuntimeAuditProcess.Id -Force
		throw 'Runtime FormSmoke action contract timed out.'
	}
	if ($RuntimeAuditProcess.ExitCode -ne 0) { throw 'Runtime FormSmoke document-form UI action contract failed.' }
	$TabAuditScript = Join-Path $PSScriptRoot 'test_form_tab_runtime_contract.ps1'
	$TabAuditArguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $TabAuditScript + '" -ResultPath "' + $ResultPath + '" -ConfigurationPath "' + $Configuration + '"'
	$TabAuditProcess = Start-Process -FilePath 'powershell.exe' -ArgumentList $TabAuditArguments -PassThru -WindowStyle Hidden
	if (-not $TabAuditProcess.WaitForExit(30000)) {
		Stop-Process -Id $TabAuditProcess.Id -Force
		throw 'Runtime document-form tab and field visibility contract timed out.'
	}
	if ($TabAuditProcess.ExitCode -ne 0) { throw 'Runtime document-form tab and field visibility contract failed.' }
	Write-Host 'PASS runtime document-form tabs and fields match metadata (20/20 primary pages)'
	$FieldInventoryScript = Join-Path $PSScriptRoot 'export_finance_field_inventory.ps1'
	$RuntimeMatrixPath = Join-Path $TempRoot 'required_field_runtime_matrix.json'
	$FieldInventoryPath = Join-Path $ArtifactRoot 'document-field-inventory.csv'
	$FieldInventoryArguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $FieldInventoryScript + '" -RuntimeMatrixPath "' + $RuntimeMatrixPath + '" -UIResultPath "' + $ResultPath + '" -OutputPath "' + $FieldInventoryPath + '" -ConfigurationPath "' + $Configuration + '"'
	$FieldInventoryProcess = Start-Process -FilePath 'powershell.exe' -ArgumentList $FieldInventoryArguments -PassThru -WindowStyle Hidden
	if (-not $FieldInventoryProcess.WaitForExit(30000)) {
		Stop-Process -Id $FieldInventoryProcess.Id -Force
		throw 'Metadata-wide document field inventory contract timed out.'
	}
	if ($FieldInventoryProcess.ExitCode -ne 0) { throw 'Metadata-wide document field inventory contract failed.' }
	Write-Host 'PASS metadata field inventory (127 attributes; all 48 ShowError fields accounted for)'
	if ($Process.ExitCode -ne 0 -or $Result.status -ne 'PASS' -or @($Result.verified).Count -ne 16 -or @($Result.form_audit).Count -ne 9 -or @($Result.document_list_actions).Count -ne 7 -or @($Result.form_command_actions).Count -ne 7) {
		throw "Native 1C document form smoke workflow failed: $($Result | ConvertTo-Json -Depth 8 -Compress)"
	}
	$DocumentListActionFailures = @($Result.document_list_actions | Where-Object { -not $_.create_form_opened -or -not $_.create_form_closed_without_save -or -not $_.copy_form_opened -or -not $_.copy_form_closed_without_save })
	if ($DocumentListActionFailures.Count -gt 0) {
		throw "Document list Create/Copy commands did not open and close cleanly: $($DocumentListActionFailures.document_number -join ', ')"
	}
	$FormCommandActionFailures = @($Result.form_command_actions | Where-Object {
		-not $_.returned_to_list -or
		($_.command_enabled -and (-not $_.invoked -or -not $_.form_remained_open)) -or
		(-not $_.command_enabled -and (-not $_.disabled_as_observed -or $_.invoked -or -not $_.form_remained_open))
	})
	if ($FormCommandActionFailures.Count -gt 0) {
		throw "Document form Save command state/action did not verify cleanly for: $($FormCommandActionFailures.document_number -join ', ')"
	}
	$DocumentAudits = @($Result.form_audit | Where-Object { $_.screen -like 'E2E-*' })
	if ($DocumentAudits.Count -ne 7) { throw "Expected seven document form audit rows, found $($DocumentAudits.Count)." }
	foreach ($Audit in $DocumentAudits) {
		$EnabledPostingCommands = @($Audit.enabled_button_names | Where-Object {
			$_ -match '(?i)(^post$|post and close|undo|unpost|cancel posting|ghi sổ|hủy ghi sổ|huy ghi so)'
		})
		if ($Audit.visible_edit_count -lt 2 -or @($Audit.visible_field_names).Count -lt 2 -or
			@($Audit.visible_control_details).Count -lt 2 -or
			@($Audit.visible_button_names) -notcontains 'Save' -or $EnabledPostingCommands.Count -gt 0) {
			throw "Document form accessibility or core command audit failed for $($Audit.screen)."
		}
	}
	$SaveInvocations = @($Result.form_command_actions | Where-Object { $_.invoked }).Count
	$DisabledSaveStates = @($Result.form_command_actions | Where-Object { -not $_.command_enabled }).Count
	$PrintPreviewInvocations = @($Result.print_preview_actions | Where-Object { $_.invoked }).Count
	$PrintPreviewUnavailable = @($Result.print_preview_actions | Where-Object { -not $_.command_available }).Count
	Write-Host ("PASS native 1C document and processor form smoke ({0}/16 screens; Create/Copy {1}/7 lists; Save invoked {2}/7, disabled {3}/7; Print preview invoked {4}/7, unavailable {5}/7)" -f @($Result.verified).Count, @($Result.document_list_actions).Count, $SaveInvocations, $DisabledSaveStates, $PrintPreviewInvocations, $PrintPreviewUnavailable)
	return $Result
}

function Invoke-FinancePostingCommandsUI([string]$Infobase) {
	$ResultPath = Join-Path $TempRoot 'ui-posting-command-actions.json'
	$ScriptPath = Join-Path $PSScriptRoot 'run_finance_ui_e2e.ps1'
	$Arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $ScriptPath + '" -OneCExe "' + $OneCExe + '" -Infobase "' + $Infobase + '" -User ketoan_truong -Workflow PostingCommandDiagnostics -ResultPath "' + $ResultPath + '"'
	$Process = Start-Process -FilePath 'powershell.exe' -ArgumentList $Arguments -PassThru
	if (-not $Process.WaitForExit(180000)) {
		Stop-Process -Id $Process.Id -Force
		throw 'Native 1C posting-command UI workflow timed out.'
	}
	if (-not (Test-Path -LiteralPath $ResultPath)) { throw "Native 1C posting-command UI workflow produced no result (exit $($Process.ExitCode))." }
	$Result = Get-Content -LiteralPath $ResultPath -Raw | ConvertFrom-Json
	Copy-Item -LiteralPath $ResultPath -Destination $ArtifactRoot -Force
	if ($Process.ExitCode -ne 0 -or $Result.status -ne 'PASS' -or @($Result.posting_command_actions).Count -ne 2) {
		throw "Native 1C posting-command UI workflow failed: $($Result | ConvertTo-Json -Depth 8 -Compress)"
	}
	$ActionFailures = @($Result.posting_command_actions | Where-Object {
		$_.initial_state -ne 'posted' -or -not $_.undo_invoked -or -not $_.post_invoked_after_undo -or
		-not $_.undo_available_after_repost -or $_.final_state -ne 'posted'
	})
	if ($ActionFailures.Count -gt 0) {
		throw "Post/Undo UI actions did not restore the original posted state: $($ActionFailures.document_number -join ', ')"
	}
	Write-Host ("PASS native 1C posting commands UI (Undo/Post {0}/2; original posted state restored)" -f @($Result.posting_command_actions).Count)
	return $Result
}

function Invoke-FinanceReferenceChoiceUI([string]$Infobase) {
	$ResultPath = Join-Path $TempRoot 'ui-reference-choice.json'
	$ScriptPath = Join-Path $PSScriptRoot 'run_finance_ui_e2e.ps1'
	$Documents = @('Acceptance', 'ARInvoice', 'Receipt', 'APInvoice', 'Payment')
	$Results = New-Object System.Collections.Generic.List[object]
	foreach ($Document in $Documents) {
		$CaseResultPath = Join-Path $TempRoot ('ui-reference-choice-' + $Document + '.json')
		$Arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $ScriptPath + '" -OneCExe "' + $OneCExe + '" -Infobase "' + $Infobase + '" -User Admin -Workflow ReferenceChoiceDiagnostics -ReferenceChoiceDocument ' + $Document + ' -ResultPath "' + $CaseResultPath + '"'
		$Process = Start-Process -FilePath 'powershell.exe' -ArgumentList $Arguments -PassThru
		if (-not $Process.WaitForExit(180000)) {
			Stop-Process -Id $Process.Id -Force
			throw "Native 1C partner-contract choice UI workflow timed out for $Document."
		}
		if (-not (Test-Path -LiteralPath $CaseResultPath)) { throw "Native 1C $Document partner-contract choice workflow produced no result (exit $($Process.ExitCode))." }
		$CaseResult = Get-Content -LiteralPath $CaseResultPath -Raw | ConvertFrom-Json
		Copy-Item -LiteralPath $CaseResultPath -Destination $ArtifactRoot -Force
		if ($Process.ExitCode -ne 0 -or $CaseResult.status -ne 'PASS' -or
			-not $CaseResult.partner_choice_open_detected -or -not $CaseResult.contract_choice_open_detected -or
			-not $CaseResult.expected_contract_visible -or $CaseResult.unexpected_contract_code_count -ne 0 -or
			$CaseResult.reference_choice_document -ne $Document) {
			throw "Native 1C $Document partner-contract choice UI workflow failed: $($CaseResult | ConvertTo-Json -Depth 8 -Compress)"
		}
		$Results.Add($CaseResult)
		Write-Host ("PASS native 1C partner-contract choice UI ({0}; {1})" -f $Document, $CaseResult.expected_contract_code)
	}
	$Aggregate = [ordered]@{
		status = if ($Results.Count -eq 5) { 'PASS' } else { 'FAIL' }
		case_count = $Results.Count
		cases = $Results.ToArray()
	}
	[System.IO.File]::WriteAllText($ResultPath, ($Aggregate | ConvertTo-Json -Depth 12), [System.Text.UTF8Encoding]::new($false))
	Copy-Item -LiteralPath $ResultPath -Destination $ArtifactRoot -Force
	Write-Host ("PASS native 1C partner-to-contract choice filter ({0}/5 forms)" -f $Results.Count)
	return $Aggregate
}

function Invoke-FinanceReportUI([string]$Infobase) {
	$ResultPath = Join-Path $TempRoot 'ui-report-smoke.json'
	$ScriptPath = Join-Path $PSScriptRoot 'run_finance_ui_e2e.ps1'
	$Arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $ScriptPath + '" -OneCExe "' + $OneCExe + '" -Infobase "' + $Infobase + '" -User Admin -Workflow ReportSmoke -ResultPath "' + $ResultPath + '"'
	$Process = Start-Process -FilePath 'powershell.exe' -ArgumentList $Arguments -PassThru -WindowStyle Hidden
	if (-not $Process.WaitForExit(300000)) {
		Stop-Process -Id $Process.Id -Force
		throw 'Native report UI workflow timed out.'
	}
	if (-not (Test-Path -LiteralPath $ResultPath)) { throw "Native report UI workflow produced no result (exit $($Process.ExitCode))." }
	$Result = Get-Content -LiteralPath $ResultPath -Raw | ConvertFrom-Json
	Copy-Item -LiteralPath $ResultPath -Destination $ArtifactRoot -Force
	if ($Process.ExitCode -ne 0 -or $Result.status -ne 'PASS' -or @($Result.report_audit).Count -ne 3 -or
		@($Result.report_audit | Where-Object { $_.visible_result_grid_count -lt 1 -or $_.ui_error_count -gt 0 }).Count -gt 0) {
		throw "Native report UI workflow failed: $($Result | ConvertTo-Json -Depth 10 -Compress)"
	}
	Write-Host 'PASS native AR/AP/aging report UI (3/3 generated result grids)'
	return $Result
}

function Invoke-FinanceGuideUI([string]$Infobase) {
	$ResultPath = Join-Path $TempRoot 'ui-finance-guide.json'
	$ScriptPath = Join-Path $PSScriptRoot 'run_finance_ui_e2e.ps1'
	$Arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $ScriptPath + '" -OneCExe "' + $OneCExe + '" -Infobase "' + $Infobase + '" -User Admin -Workflow GuideSmoke -ResultPath "' + $ResultPath + '"'
	$Process = Start-Process -FilePath 'powershell.exe' -ArgumentList $Arguments -PassThru -WindowStyle Hidden
	if (-not $Process.WaitForExit(180000)) {
		Stop-Process -Id $Process.Id -Force
		throw 'Native finance guide UI workflow timed out.'
	}
	if (-not (Test-Path -LiteralPath $ResultPath)) { throw "Native finance guide UI workflow produced no result (exit $($Process.ExitCode))." }
	$Result = Get-Content -LiteralPath $ResultPath -Raw | ConvertFrom-Json
	Copy-Item -LiteralPath $ResultPath -Destination $ArtifactRoot -Force
	if ($Process.ExitCode -ne 0 -or $Result.status -ne 'PASS' -or $Result.verified.Count -lt 2 -or
		-not (Test-Path -LiteralPath $Result.screenshot_path)) {
		throw "Native finance guide UI workflow failed: $($Result | ConvertTo-Json -Depth 10 -Compress)"
	}
	Write-Host 'PASS native finance process guide UI and native AR route'
	return $Result
}

function Invoke-FinanceFCTInvoiceUI([string]$Infobase) {
	$ResultPath = Join-Path $TempRoot 'ui-ap-fct250-smoke.json'
	$ScriptPath = Join-Path $PSScriptRoot 'run_finance_ui_e2e.ps1'
	$Arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $ScriptPath + '" -OneCExe "' + $OneCExe + '" -Infobase "' + $Infobase + '" -User Admin -Workflow FCTInvoiceSmoke -ResultPath "' + $ResultPath + '"'
	$Process = Start-Process -FilePath 'powershell.exe' -ArgumentList $Arguments -PassThru -WindowStyle Hidden
	if (-not $Process.WaitForExit(180000)) {
		Stop-Process -Id $Process.Id -Force
		throw 'Native AP FCT250 UI workflow timed out.'
	}
	if (-not (Test-Path -LiteralPath $ResultPath)) { throw "Native AP FCT250 UI workflow produced no result (exit $($Process.ExitCode))." }
	$Result = Get-Content -LiteralPath $ResultPath -Raw | ConvertFrom-Json
	Copy-Item -LiteralPath $ResultPath -Destination $ArtifactRoot -Force
	if ($Process.ExitCode -ne 0 -or $Result.status -ne 'PASS' -or $Result.fct_invoice -ne 'E2E-AP-FCT250' -or
		-not $Result.fct_checkbox_persisted -or $Result.register_row_counts.SoCaiKeToan -lt 1 -or
		$Result.register_row_counts.CongNoPhaiTra -lt 1) {
		throw "Native AP FCT250 UI workflow failed: $($Result | ConvertTo-Json -Depth 10 -Compress)"
	}
	Write-Host 'PASS native FCT250 form (checkbox checked; three GL rows and AP register rows visible)'
	return $Result
}

function Invoke-FinanceBranchRoleCreateUI([string]$Infobase, [string]$User, [string]$Document) {
	$ResultPath = Join-Path $TempRoot ("ui-branch-create-" + $User + "-" + $Document + ".json")
	$ScriptPath = Join-Path $PSScriptRoot 'run_finance_ui_e2e.ps1'
	$Arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $ScriptPath + '" -OneCExe "' + $OneCExe + '" -Infobase "' + $Infobase + '" -User ' + $User + ' -Workflow RequiredFieldDiagnostics -RequiredFieldDocument ' + $Document + ' -ResultPath "' + $ResultPath + '"'
	$Process = Start-Process -FilePath 'powershell.exe' -ArgumentList $Arguments -PassThru
	if (-not $Process.WaitForExit(180000)) {
		Stop-Process -Id $Process.Id -Force
		throw "Branch-scoped $User $Document create-form workflow timed out."
	}
	if (-not (Test-Path -LiteralPath $ResultPath)) { throw "Branch-scoped $User $Document create-form workflow produced no result (exit $($Process.ExitCode))." }
	$Result = Get-Content -LiteralPath $ResultPath -Raw -Encoding UTF8 | ConvertFrom-Json
	Copy-Item -LiteralPath $ResultPath -Destination $ArtifactRoot -Force
	$LegalEntityFields = @($Result.empty_save_before | Where-Object { $_.name -eq 'Pháp nhân:' })
	$LegalEntityValue = if ($LegalEntityFields.Count -eq 1) { [string]$LegalEntityFields[0].value } else { '' }
	if ($Process.ExitCode -ne 0 -or $Result.status -ne 'PASS' -or -not $Result.blank_save_rejected -or
		$LegalEntityValue -ne 'E2E legal entity for branch RLS') {
		throw "Branch-scoped create form failed for $User/$Document (entity='$LegalEntityValue'): $($Result | ConvertTo-Json -Depth 8 -Compress)"
	}
	$Result | Add-Member -NotePropertyName branch_default_legal_entity -NotePropertyValue $LegalEntityValue -Force
	Write-Host ("PASS branch-scoped create form ({0}/{1}; legal entity {2})" -f $User, $Document, $LegalEntityValue)
	return $Result
}
function Invoke-FinanceRequiredFieldUI([string]$Infobase) {
	$ResultPath = Join-Path $TempRoot 'ui-required-field-validation.json'
	$ScriptPath = Join-Path $PSScriptRoot 'run_finance_ui_e2e.ps1'
	$Documents = @('Acceptance', 'ARInvoice', 'Receipt', 'APInvoice', 'Payment', 'Netting', 'Reconciliation')
	$Results = [System.Collections.Generic.List[object]]::new()
	foreach ($Document in $Documents) {
		$CaseResultPath = Join-Path $TempRoot ('ui-required-field-' + $Document + '.json')
		$Arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $ScriptPath + '" -OneCExe "' + $OneCExe + '" -Infobase "' + $Infobase + '" -User Admin -Workflow RequiredFieldDiagnostics -RequiredFieldDocument ' + $Document + ' -ResultPath "' + $CaseResultPath + '"'
		$Process = Start-Process -FilePath 'powershell.exe' -ArgumentList $Arguments -PassThru -WindowStyle Hidden
		if (-not $Process.WaitForExit(180000)) {
			Stop-Process -Id $Process.Id -Force
			$Results.Add([PSCustomObject]@{ document_type = $Document; status = 'TIMEOUT'; error = 'UI diagnostic exceeded 180 seconds.' })
			Write-Host ('FAIL native 1C required-field UI timed out (' + $Document + ')')
			continue
		}
		if (-not (Test-Path -LiteralPath $CaseResultPath)) {
			$Results.Add([PSCustomObject]@{ document_type = $Document; status = 'NO_RESULT'; process_exit_code = $Process.ExitCode })
			Write-Host ('FAIL native 1C required-field UI produced no result (' + $Document + ')')
			continue
		}
		$CaseResult = Get-Content -LiteralPath $CaseResultPath -Raw | ConvertFrom-Json
		$CaseResult | Add-Member -NotePropertyName process_exit_code -NotePropertyValue $Process.ExitCode -Force
		Copy-Item -LiteralPath $CaseResultPath -Destination $ArtifactRoot -Force
		$Results.Add($CaseResult)
		if ($Process.ExitCode -eq 0 -and $CaseResult.status -eq 'PASS') {
			Write-Host ('PASS native 1C required-field UI (' + $Document + '; blank rejected, no number assigned)')
		} else {
			Write-Host ('FAIL native 1C required-field UI (' + $Document + '; ' + $CaseResult.error + ')')
		}
	}
	$Result = [ordered]@{
		status = if ($Results.Count -eq $Documents.Count -and @($Results | Where-Object { $_.status -ne 'PASS' -or $_.process_exit_code -ne 0 }).Count -eq 0) { 'PASS' } else { 'FAIL' }
		case_count = $Results.Count
		cases = $Results.ToArray()
	}
	$ContractScript = Join-Path $PSScriptRoot 'test_required_field_ui.ps1'
	[System.IO.File]::WriteAllText($ResultPath, ($Result | ConvertTo-Json -Depth 12), [System.Text.UTF8Encoding]::new($false))
	Copy-Item -LiteralPath $ResultPath -Destination $ArtifactRoot -Force
	$ContractArguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $ContractScript + '" -ResultPath "' + $ResultPath + '"'
	$ContractProcess = Start-Process -FilePath 'powershell.exe' -ArgumentList $ContractArguments -PassThru -WindowStyle Hidden
	if (-not $ContractProcess.WaitForExit(30000)) {
		Stop-Process -Id $ContractProcess.Id -Force
		throw 'Required-field UI contract timed out.'
	}
	if ($ContractProcess.ExitCode -ne 0 -or $Result.status -ne 'PASS') { throw 'Required-field UI validation contract failed.' }
	Write-Host ('PASS native 1C required-field validation UI (' + $Result.case_count + '/7 document forms)')
	return $Result
}

function Invoke-FinanceARAutofillUI([string]$Infobase) {
	$ResultPath = Join-Path $TempRoot 'ui-ar-autofill.json'
	$ScriptPath = Join-Path $PSScriptRoot 'run_finance_ui_e2e.ps1'
	$Arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $ScriptPath + '" -OneCExe "' + $OneCExe + '" -Infobase "' + $Infobase + '" -User Admin -Workflow ARAutofillSmoke -ResultPath "' + $ResultPath + '"'
	$Process = Start-Process -FilePath 'powershell.exe' -ArgumentList $Arguments -PassThru -WindowStyle Hidden
	if (-not $Process.WaitForExit(180000)) {
		Stop-Process -Id $Process.Id -Force
		throw 'Native AR BBNT-autofill UI workflow timed out.'
	}
	if (-not (Test-Path -LiteralPath $ResultPath)) { throw "Native AR BBNT-autofill workflow produced no result (exit $($Process.ExitCode))." }
	$Result = Get-Content -LiteralPath $ResultPath -Raw | ConvertFrom-Json
	Copy-Item -LiteralPath $ResultPath -Destination $ArtifactRoot -Force
	$Values = $Result.autofill_values
	if ($Process.ExitCode -ne 0 -or $Result.status -ne 'PASS' -or
		$Values.'Biên bản nghiệm thu:' -notlike '*E2E-BB001*' -or
		$Values.'Pháp nhân:' -notlike '*VinSmart Future*' -or
		$Values.'Đối tác:' -notlike '*VinFast*' -or
		$Values.'Hợp đồng:' -notlike '*2025*VinFast*' -or
		$Values.'Thành tiền chưa thuế:' -ne '200,000,000.00' -or
		$Values.'Thuế suất GTGT (%):' -notlike '10*' -or
		$Values.'Tiền thuế GTGT:' -ne '20,000,000.00' -or
		$Values.'Tổng tiền thanh toán:' -ne '220,000,000.00' -or
		-not (Test-Path -LiteralPath $Result.screenshot_path)) {
		throw "Native AR BBNT-autofill UI workflow failed: $($Result | ConvertTo-Json -Depth 8 -Compress)"
	}
	$PhaseResults.Add([PSCustomObject]@{
		run_id = $RunId
		phase = 'ui_ar_autofill'
		user = 'Admin'
		status = 'PASS'
		error = ''
		data = $Result.autofill_values
	})
	Write-Host 'PASS native AR BBNT lookup autofill (entity/partner/contract; 200m + VAT 10% = 220m)'
	return $Result
}

function Invoke-SecurityRoleMatrix([string]$Infobase, [string]$User) {
	$JsonPath = Join-Path $TempRoot ('security-' + $User + '.json')
	$LogPath = Join-Path $TempRoot ('security-' + $User + '.log')
	$Arguments = 'ENTERPRISE /F"' + $Infobase + '" /N' + $User + ' /CRunSecurityRoleMatrix;' + $RunId + ';' + $JsonPath + ' /DisableStartupMessages /Out"' + $LogPath + '"'
	$ExitCode = Invoke-OneCProcess $Arguments $LogPath
	Copy-RunArtifacts $JsonPath $LogPath
	if (-not (Test-Path -LiteralPath $JsonPath)) {
		throw "Security role matrix produced no result JSON for $User (1C exit $ExitCode). Log: $LogPath"
	}
	$Result = Get-Content -LiteralPath $JsonPath -Raw | ConvertFrom-Json
	if ($ExitCode -ne 0 -or $Result.status -ne 'PASS' -or $Result.total -ne 10 -or
		$Result.passed_cases -ne 10 -or $Result.failed_cases -ne 0 -or $Result.skipped_cases -ne 0 -or
		@($Result.cases | Where-Object { $_.status -ne 'PASS' }).Count -gt 0) {
		throw "Security role matrix failed for $($User): $($Result | ConvertTo-Json -Depth 10 -Compress)"
	}
	$PhaseResults.Add($Result)
	Write-Host ("PASS security role matrix ({0}; {1}/{2})" -f $User, $Result.passed_cases, $Result.total)
}

function Invoke-ARSeedCommand([string]$Infobase, [string]$Stage, [string]$User) {
	$Label = if ($Stage) { 'ar-seed-' + $Stage } else { 'ar-seed-master-data' }
	$JsonPath = Join-Path $TempRoot ($Label + '.json')
	$LogPath = Join-Path $TempRoot ($Label + '.log')
	if ($Stage) {
		$Arguments = 'ENTERPRISE /F"' + $Infobase + '" /N' + $User + ' /CRunARSeedStage;' + $Stage + ';' + $RunId + ';' + $JsonPath + ' /DisableStartupMessages /Out"' + $LogPath + '"'
	}
	else {
		$Arguments = 'ENTERPRISE /F"' + $Infobase + '" /N' + $User + ' /CRunARSeedMasterData;' + $RunId + ';' + $JsonPath + ' /DisableStartupMessages /Out"' + $LogPath + '"'
	}
	$ExitCode = Invoke-OneCProcess $Arguments $LogPath 1800000
	Copy-RunArtifacts $JsonPath $LogPath
	if (-not (Test-Path -LiteralPath $JsonPath)) { throw "AR seed phase $Label produced no JSON (1C exit $ExitCode). Log: $LogPath" }
	$Result = Get-Content -LiteralPath $JsonPath -Raw | ConvertFrom-Json
	if ($ExitCode -ne 0 -or $Result.status -ne 'PASS') {
		throw "AR seed phase $Label failed for $User (1C exit $ExitCode): $($Result.error)"
	}
	$PhaseResults.Add($Result)
	Write-Host ("PASS AR seed phase {0} ({1}; {2} documents)" -f $Label, $User, $Result.data.documents)
	return $Result
}

function Invoke-APSeedCommand([string]$Infobase, [string]$Stage, [string]$User) {
	$Label = if ($Stage) { 'ap-seed-' + $Stage } else { 'ap-seed-master-data' }
	$JsonPath = Join-Path $TempRoot ($Label + '.json')
	$LogPath = Join-Path $TempRoot ($Label + '.log')
	if ($Stage) {
		$Arguments = 'ENTERPRISE /F"' + $Infobase + '" /N' + $User + ' /CRunAPSeedStage;' + $Stage + ';' + $RunId + ';' + $JsonPath + ' /DisableStartupMessages /Out"' + $LogPath + '"'
	}
	else {
		$Arguments = 'ENTERPRISE /F"' + $Infobase + '" /N' + $User + ' /CRunAPSeedMasterData;' + $RunId + ';' + $JsonPath + ' /DisableStartupMessages /Out"' + $LogPath + '"'
	}
	$ExitCode = Invoke-OneCProcess $Arguments $LogPath 1800000
	Copy-RunArtifacts $JsonPath $LogPath
	if (-not (Test-Path -LiteralPath $JsonPath)) { throw "AP seed phase $Label produced no JSON (1C exit $ExitCode). Log: $LogPath" }
	$Result = Get-Content -LiteralPath $JsonPath -Raw | ConvertFrom-Json
	if ($ExitCode -ne 0 -or $Result.status -ne 'PASS') {
		throw "AP seed phase $Label failed for $User (1C exit $ExitCode): $($Result.error)"
	}
	$PhaseResults.Add($Result)
	Write-Host ("PASS AP seed phase {0} ({1}; docs={2}, posted={3}, pending CFO={4})" -f $Label, $User, $Result.data.documents, $Result.data.posted, $Result.data.pending_cfo)
	return $Result
}

function Invoke-Compile([string]$Infobase, [string]$Label) {
	$LogPath = Join-Path $TempRoot ($Label + '-compile.log')
	$Arguments = 'DESIGNER /F"' + $Infobase + '" /NAdmin /LoadConfigFromFiles "' + $Configuration + '" /UpdateDBCfg /DisableStartupMessages /Out"' + $LogPath + '"'
	$ExitCode = Invoke-OneCProcess $Arguments $LogPath 900000
	if (Test-Path -LiteralPath $LogPath) {
		Copy-Item -LiteralPath $LogPath -Destination $ArtifactRoot -Force
	}
	if ($ExitCode -ne 0 -or -not (Select-String -LiteralPath $LogPath -Pattern 'Configuration successfully updated' -Quiet)) {
		throw "Configuration compile/update failed for $Label (1C exit $ExitCode). Log: $LogPath"
	}
	Write-Host ("PASS compile/update ({0})" -f $Label)
}

try {
	if (-not (Test-Path -LiteralPath $OneCExe)) { throw "1C executable not found: $OneCExe" }
	if (-not (Test-Path -LiteralPath (Join-Path $BaseInfobase '1Cv8.1CD'))) { throw "Base infobase is missing: $BaseInfobase" }
	New-Item -ItemType Directory -Path $TempRoot -Force | Out-Null
	New-Item -ItemType Directory -Path $ArtifactRoot -Force | Out-Null
	$BankStubScript = Join-Path $PSScriptRoot 'bank_stub_server.ps1'
	$BankStubReady = Join-Path $TempRoot 'bank-stub.ready.json'
	$BankStubLog = Join-Path $TempRoot 'bank-stub.requests.jsonl'
	$BankStubFailure = Join-Path $TempRoot 'bank-stub.failure.log'
	$BankStubArgs = '-NoProfile -ExecutionPolicy Bypass -File "' + $BankStubScript + '" -Port ' + $BankStubPort + ' -ReadyPath "' + $BankStubReady + '" -LogPath "' + $BankStubLog + '" -FailurePath "' + $BankStubFailure + '"'
	$BankStubProcess = Start-Process -FilePath 'powershell.exe' -ArgumentList $BankStubArgs -PassThru -WindowStyle Hidden
	$BankStubDeadline = (Get-Date).AddSeconds(15)
	while (-not (Test-Path -LiteralPath $BankStubReady) -and (Get-Date) -lt $BankStubDeadline -and -not $BankStubProcess.HasExited) {
		Start-Sleep -Milliseconds 100
	}
	if (-not (Test-Path -LiteralPath $BankStubReady)) {
		$BankStubError = if (Test-Path -LiteralPath $BankStubFailure) { Get-Content -LiteralPath $BankStubFailure -Raw } else { 'bank stub failed to start or did not publish its readiness marker' }
		throw "Local bank HTTP stub startup failed: $BankStubError"
	}
	Write-Host ("PASS local bank integration stub ({0}:{1})" -f '127.0.0.1', $BankStubPort)

	$E2EInfobase = Join-Path $TempRoot 'e2e-infobase'
	Copy-Item -LiteralPath $BaseInfobase -Destination $E2EInfobase -Recurse
	Invoke-Compile $E2EInfobase 'e2e'

	# The demo explicitly warns that Approve All is only safe in an isolated
	# single-document queue. Exercise that UI workflow in its own disposable copy
	# so unrelated validation fixtures in the main suite cannot enter the queue.
	$BatchUIInfobase = Join-Path $TempRoot 'batch-ui-infobase'
	Copy-Item -LiteralPath $BaseInfobase -Destination $BatchUIInfobase -Recurse
	Invoke-Compile $BatchUIInfobase 'batch-ui'
	Invoke-FinancePhase $BatchUIInfobase 'setup' 'Admin' | Out-Null
	Invoke-FinancePhase $BatchUIInfobase 'approval_ui_queue_check' 'ketoan_truong' | Out-Null
	Invoke-FinancePhase $BatchUIInfobase 'batch_ui_setup' 'ketoan_ap' | Out-Null
	Invoke-FinancePhase $BatchUIInfobase 'batch_ui_queue_check' 'ketoan_truong' | Out-Null
	$BatchApprovalUIResult = Invoke-FinanceBatchApprovalUI $BatchUIInfobase
	$BatchApprovalUIVerification = Invoke-FinancePhase $BatchUIInfobase 'batch_ui_verify' 'ketoan_truong'
	$BatchContractScript = Join-Path $PSScriptRoot 'test_batch_approval_ui_contract.ps1'
	& $BatchContractScript -ArtifactPath $ArtifactRoot -UIResultPath (Join-Path $ArtifactRoot 'ui-batch-approval.json') | Out-Null
	$BatchApprovalUIContract = Get-Content -LiteralPath (Join-Path $ArtifactRoot 'batch-approval-ui-contract.json') -Raw -Encoding UTF8 | ConvertFrom-Json

	$Phases = @(
		@('setup', 'Admin'),
		@('required_reference_prepare', 'ketoan_ar'),
		@('required_reference_post', 'ketoan_truong'),
		@('required_ap_contract_prepare', 'ketoan_ap'),
		@('required_ap_contract_post', 'ketoan_truong'),
		@('ar_submit_acceptance', 'ketoan_ar'),
		@('ktt_approve_acceptance', 'ketoan_truong'),
		@('ktt_post_acceptance', 'ketoan_truong'),
		@('ar_submit_invoice', 'ketoan_ar'),
		@('ktt_issue_invoice', 'ketoan_truong'),
		@('csv_import_preview', 'cfo_giamdoc'),
		@('csv_match_post', 'cfo_giamdoc'),
		@('csv_duplicate_reimport', 'cfo_giamdoc'),
		@('csv_invalid_rows', 'cfo_giamdoc'),
		@('ar_create_receipts', 'ketoan_ar'),
		@('cfo_post_receipts', 'cfo_giamdoc'),
		@('ar_unpost_paid_invoice_rejected', 'cfo_giamdoc'),
		@('ap_submit_invoice', 'ketoan_ap'),
		@('ktt_post_ap_invoice', 'ketoan_truong'),
		@('ap_fct_250_prepare', 'ketoan_ap'),
		@('ap_fct_250_post_verify', 'ketoan_truong'),
		@('ap_submit_payment', 'ketoan_ap'),
		@('ktt_approve_payment', 'ketoan_truong'),
		@('bank_idempotency_verify', 'ketoan_truong'),
		@('bank_reject_submit', 'ketoan_ap'),
		@('bank_reject_approve', 'ketoan_truong'),
		@('bank_reject_send', 'ketoan_truong'),
		@('cfo_post_payment_verify', 'cfo_giamdoc'),
		@('netting_submit_acceptance', 'ketoan_ar'),
		@('netting_post_acceptance', 'ketoan_truong'),
		@('netting_submit_output_invoice', 'ketoan_ar'),
		@('netting_issue_output_invoice', 'ketoan_truong'),
		@('netting_submit_ap', 'ketoan_ap'),
		@('netting_post_ap', 'ketoan_truong'),
		@('netting_post_verify', 'ketoan_truong'),
		@('netting_create_remaining_receipt', 'ketoan_ar'),
		@('netting_post_remaining_receipt', 'cfo_giamdoc'),
		@('required_field_runtime_matrix', 'Admin'),
		@('approver_eligibility_verify', 'Admin'),
		@('payment_reconciliation', 'cfo_giamdoc'),
		@('approval_setup', 'ketoan_ap'),
		@('approval_ar_queue', 'ketoan_ar'),
		@('approval_ktt', 'ketoan_truong'),
		@('approval_cfo', 'cfo_giamdoc'),
		@('bank_submit_bulk_payment', 'ketoan_truong'),
		@('bank_post_bulk_payment', 'cfo_giamdoc'),
		@('posting_invariant_setup_ap', 'ketoan_ap'),
		@('posting_invariant_setup_acceptance', 'ketoan_ar'),
		@('posting_invariant_post_acceptance', 'ketoan_truong'),
		@('posting_invariant_setup_ar_invoices', 'ketoan_ar'),
		@('concurrency_setup', 'ketoan_ar'),
		@('concurrency_post_invoice', 'ketoan_truong'),
		@('concurrency_receipt_setup', 'ketoan_ar')
	)
	foreach ($Step in $Phases) {
		Invoke-FinancePhase $E2EInfobase $Step[0] $Step[1]
		if ($Step[0] -eq 'ktt_approve_payment') {
			Invoke-FinanceBankUI $E2EInfobase 'E2E-UNC01' 'Accepted' 'ketoan_truong' | Out-Null
		}
		if ($Step[0] -eq 'bank_reject_approve') {
			Invoke-FinanceBankUI $E2EInfobase 'E2E-BANK-REJECT' 'Rejected' 'ketoan_truong' | Out-Null
		}
	}
	$AgingVerification = Invoke-FinancePhase $E2EInfobase 'aging_algorithm_verify' 'cfo_giamdoc'
	if ($AgingVerification.data.case_count -ne 9 -or $AgingVerification.data.passed_count -ne 9) { throw 'Shared six-group aging boundary checks failed.' }
	$DashboardVerification = Invoke-FinancePhase $E2EInfobase 'dashboard_verify' 'cfo_giamdoc'
	Invoke-FinancePhase $E2EInfobase 'ar_fct_cash_funding_prepare_invoice' 'ketoan_ar' | Out-Null
	Invoke-FinancePhase $E2EInfobase 'ar_fct_cash_funding_post_invoice' 'ketoan_truong' | Out-Null
	Invoke-FinancePhase $E2EInfobase 'ar_fct_cash_funding_prepare_receipt' 'ketoan_ar' | Out-Null
	Invoke-FinancePhase $E2EInfobase 'ar_fct_cash_funding_post_receipt' 'cfo_giamdoc' | Out-Null
	Invoke-FinancePhase $E2EInfobase 'ap_fct_250_payment_submit' 'ketoan_ap' | Out-Null
	Invoke-FinancePhase $E2EInfobase 'ap_fct_250_payment_approve' 'ketoan_truong' | Out-Null
	Invoke-FinancePhase $E2EInfobase 'ap_fct_250_payment_bank_submit' 'ketoan_truong' | Out-Null
	Invoke-FinancePhase $E2EInfobase 'ap_fct_250_payment_post_verify' 'cfo_giamdoc' | Out-Null
	$ReportValuesVerification = Invoke-FinancePhase $E2EInfobase 'reporting_values_verify' 'cfo_giamdoc'
	if ($ReportValuesVerification.data.status -ne 'PASS' -or
		-not $ReportValuesVerification.data.ar_register_equation.equation_passed -or
		-not $ReportValuesVerification.data.ap_register_equation.equation_passed -or
		$ReportValuesVerification.data.fct250_report_increase_vnd -ne 225000000 -or
		$ReportValuesVerification.data.fct250_report_decrease_vnd -ne 225000000 -or
		$ReportValuesVerification.data.fct250_closing_balance_vnd -ne 0) {
		throw "AR/AP report values did not reconcile: $($ReportValuesVerification.data | ConvertTo-Json -Depth 8 -Compress)"
	}
	$DashboardMonth = $DashboardVerification.data.month_json | ConvertFrom-Json
	$DashboardQuarter = $DashboardVerification.data.quarter_json | ConvertFrom-Json
	$DashboardYear = $DashboardVerification.data.year_json | ConvertFrom-Json
	$DashboardData = $DashboardVerification.data
	if (-not $DashboardData.unsupported_period_rejected -or
		$DashboardMonth.TongDoanhThu -ne $DashboardData.expected_revenue -or
		$DashboardMonth.TongDoanhThu -ne $DashboardData.expected_gl_revenue -or
		$DashboardMonth.BieuDoDoanhThu[5].DoanhThu -ne $DashboardData.expected_revenue -or
		$DashboardMonth.BieuDoDoanhThu[5].TienThu -ne $DashboardData.expected_receipts -or
		$DashboardMonth.SoHoaDonBan -ne $DashboardData.expected_invoice_count -or
		$DashboardMonth.NoPhaiThu -ne $DashboardData.expected_ar -or
		$DashboardMonth.NoPhaiTra -ne $DashboardData.expected_ap -or
		$DashboardMonth.TienKhaDung -ne $DashboardData.expected_cash -or
		@($DashboardMonth.BieuDoDoanhThu).Count -ne 6 -or
		@($DashboardMonth.BieuDoTuoiNo).Count -ne 6 -or
		$DashboardMonth.TongDoanhThu -gt $DashboardQuarter.TongDoanhThu -or
		$DashboardQuarter.TongDoanhThu -gt $DashboardYear.TongDoanhThu -or
		$DashboardMonth.NoPhaiThuQuaHan -lt 0 -or
		$DashboardMonth.NoPhaiThuQuaHan -gt $DashboardData.expected_positive_ar -or
		@($DashboardMonth.TopNoQuaHan).Count -gt 5 -or
		@($DashboardMonth.TopChungTuCanXuLy).Count -gt 5) {
		throw "Dashboard runtime assertions failed: $($DashboardMonth | ConvertTo-Json -Depth 10 -Compress)"
	}
	$DashboardAgingTotal = [decimal](($DashboardMonth.BieuDoTuoiNo | Measure-Object -Property SoTien -Sum).Sum)
	if ($DashboardAgingTotal -ne [decimal]$DashboardData.expected_positive_ar) {
		throw "Dashboard aging buckets do not reconcile to positive AR: aging=$DashboardAgingTotal expected=$($DashboardData.expected_positive_ar)"
	}
	if (@($DashboardMonth.TopNoQuaHan | Where-Object { $_.SoDuNo -le 0 -or $_.SoNgayQuaHan -le 0 }).Count -gt 0) {
		throw 'Dashboard overdue list contains a non-positive balance or a non-overdue item.'
	}
	if (@($DashboardMonth.TopChungTuCanXuLy | Where-Object { -not $_.LoaiChungTu -or -not $_.SoChungTu }).Count -gt 0) {
		throw 'Dashboard actionable document list contains an incomplete row.'
	}
	$ExpectedActionableNumbers = @('E2E-BANK-REJECT', 'E2E-INV-CANCEL', 'E2E-INV-ZVAT', 'E2E-INV-TX-GOOD', 'E2E-INV-TX-BAD' | Sort-Object)
	$ActualActionableNumbers = @($DashboardMonth.TopChungTuCanXuLy | ForEach-Object { [string]$_.SoChungTu } | Sort-Object)
	if (@(Compare-Object -ReferenceObject $ExpectedActionableNumbers -DifferenceObject $ActualActionableNumbers).Count -gt 0) {
		throw "Dashboard actionable document selection mismatch: expected=$($ExpectedActionableNumbers -join ',') actual=$($ActualActionableNumbers -join ',')"
	}
	$BankRetryItem = @($DashboardMonth.TopChungTuCanXuLy | Where-Object { $_.SoChungTu -eq 'E2E-BANK-REJECT' })
	if ($BankRetryItem.Count -ne 1 -or $BankRetryItem[0].LoaiChungTu -ne 'UyNhiemChi' -or $BankRetryItem[0].SoTien -ne 1000000) {
		throw 'Dashboard did not surface the rejected bank payment as an actionable retry item with its correct amount.'
	}
	$DashboardSummary = [ordered]@{
		status = 'PASS'
		report_periods = @('ThangNay', 'QuyNay', 'NamNay')
		month_revenue_vnd = $DashboardMonth.TongDoanhThu
		month_revenue_gl_vnd = $DashboardData.expected_gl_revenue
		month_receipts_vnd = $DashboardData.expected_receipts
		month_invoice_count = $DashboardMonth.SoHoaDonBan
		ar_balance_vnd = $DashboardMonth.NoPhaiThu
		ap_balance_vnd = $DashboardMonth.NoPhaiTra
		cash_balance_vnd = $DashboardMonth.TienKhaDung
		overdue_ar_vnd = $DashboardMonth.NoPhaiThuQuaHan
		due_ap_vnd = $DashboardMonth.NoPhaiTraDenHan
		revenue_chart_points = @($DashboardMonth.BieuDoDoanhThu).Count
		aging_buckets = @($DashboardMonth.BieuDoTuoiNo).Count
		actionable_documents = @($DashboardMonth.TopChungTuCanXuLy).Count
		bank_rejection_visible_for_retry = $true
		invalid_period_rejected = $DashboardData.unsupported_period_rejected
	}
	$DashboardSummary | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $ArtifactRoot 'dashboard-verify.json') -Encoding UTF8
	Write-Host 'PASS dashboard report, aging, period and workflow assertions.'
	foreach ($SecurityUser in @('Admin', 'ketoan_ar', 'ketoan_ap', 'ketoan_truong', 'cfo_giamdoc')) {
		Invoke-SecurityRoleMatrix $E2EInfobase $SecurityUser
	}

	$LifecycleActorResults = @()
	$LifecycleCases = @()
	foreach ($LifecycleUser in @('cfo_giamdoc', 'ketoan_truong')) {
		$LifecycleLabel = if ($LifecycleUser -eq 'cfo_giamdoc') { 'cfo-receipt' } else { 'ktt-netting' }
		$LifecycleJson = Join-Path $TempRoot ('posting-lifecycle-' + $LifecycleLabel + '.json')
		$LifecycleLog = Join-Path $TempRoot ('posting-lifecycle-' + $LifecycleLabel + '.log')
		$LifecycleArgs = 'ENTERPRISE /F"' + $E2EInfobase + '" /N' + $LifecycleUser + ' /CRunPostingLifecycle;' + $RunId + ';' + $LifecycleJson + ' /DisableStartupMessages /Out"' + $LifecycleLog + '"'
		$LifecycleExit = Invoke-OneCProcess $LifecycleArgs $LifecycleLog
		Copy-RunArtifacts $LifecycleJson $LifecycleLog
		if (-not (Test-Path -LiteralPath $LifecycleJson)) { throw "Posting lifecycle regression for $LifecycleUser produced no result JSON (1C exit $LifecycleExit)." }
		$ActorLifecycleResult = Get-Content -LiteralPath $LifecycleJson -Raw | ConvertFrom-Json
		if ($LifecycleExit -ne 0 -or $ActorLifecycleResult.status -ne 'PASS' -or @($ActorLifecycleResult.cases | Where-Object { -not $_.passed }).Count -gt 0) {
			throw "Posting lifecycle regression failed for ${LifecycleUser}: $($ActorLifecycleResult | ConvertTo-Json -Depth 10 -Compress)"
		}
		$LifecycleActorResults += [PSCustomObject]@{ user = $LifecycleUser; result = $ActorLifecycleResult }
		foreach ($LifecycleCase in $ActorLifecycleResult.cases) {
			$LifecycleCases += [PSCustomObject]@{
				name = $LifecycleLabel + '_' + $LifecycleCase.name
				passed = $LifecycleCase.passed
				error = $LifecycleCase.error
			}
		}
	}
	$LifecycleResult = [PSCustomObject]@{
		run_id = $RunId
		status = 'PASS'
		actors = $LifecycleActorResults
		cases = $LifecycleCases
	}
	Write-Host ("PASS assigned-approver lifecycle regressions ({0}/{1}; CFO receipt + KTT netting)" -f @($LifecycleCases | Where-Object passed).Count, $LifecycleCases.Count)

	$IntegrityJson = Join-Path $TempRoot 'gl-subledger-integrity.json'
	$IntegrityLog = Join-Path $TempRoot 'gl-subledger-integrity.log'
	$IntegrityArgs = 'ENTERPRISE /F"' + $E2EInfobase + '" /NAdmin /CRunGLSubledgerIntegrity;' + $RunId + ';' + $IntegrityJson + ' /DisableStartupMessages /Out"' + $IntegrityLog + '"'
	$IntegrityExit = Invoke-OneCProcess $IntegrityArgs $IntegrityLog
	Copy-RunArtifacts $IntegrityJson $IntegrityLog
	if (-not (Test-Path -LiteralPath $IntegrityJson)) { throw "GL/subledger integrity regression produced no result JSON (1C exit $IntegrityExit)." }
	$GLSubledgerIntegrityResult = Get-Content -LiteralPath $IntegrityJson -Raw | ConvertFrom-Json
	if ($IntegrityExit -ne 0 -or $GLSubledgerIntegrityResult.status -ne 'PASS' -or
		@($GLSubledgerIntegrityResult.cases).Count -ne 3 -or
		@($GLSubledgerIntegrityResult.cases | Where-Object { -not $_.passed }).Count -gt 0) {
		throw "GL/subledger integrity regression failed: $($GLSubledgerIntegrityResult | ConvertTo-Json -Depth 10 -Compress)"
	}
	Write-Host ("PASS real GL/subledger mismatch detection and rollback ({0}/{1})" -f @($GLSubledgerIntegrityResult.cases | Where-Object passed).Count, @($GLSubledgerIntegrityResult.cases).Count)

	$APLifecycleJson = Join-Path $TempRoot 'ap-invoice-posting-lifecycle.json'
	$APLifecycleLog = Join-Path $TempRoot 'ap-invoice-posting-lifecycle.log'
	$APLifecycleArgs = 'ENTERPRISE /F"' + $E2EInfobase + '" /Nketoan_truong /CRunAPInvoiceLifecycle;' + $RunId + ';' + $APLifecycleJson + ' /DisableStartupMessages /Out"' + $APLifecycleLog + '"'
	$APLifecycleExit = Invoke-OneCProcess $APLifecycleArgs $APLifecycleLog
	Copy-RunArtifacts $APLifecycleJson $APLifecycleLog
	if (-not (Test-Path -LiteralPath $APLifecycleJson)) { throw "AP invoice lifecycle regression produced no result JSON (1C exit $APLifecycleExit)." }
	$APInvoiceLifecycleResult = Get-Content -LiteralPath $APLifecycleJson -Raw | ConvertFrom-Json
	if ($APLifecycleExit -ne 0 -or $APInvoiceLifecycleResult.status -ne 'PASS' -or @($APInvoiceLifecycleResult.cases | Where-Object { -not $_.passed }).Count -gt 0) {
		throw "KTT AP invoice lifecycle regression failed: $($APInvoiceLifecycleResult | ConvertTo-Json -Depth 10 -Compress)"
	}
	Write-Host ("PASS KTT AP invoice lifecycle regression ({0}/{1})" -f @($APInvoiceLifecycleResult.cases | Where-Object passed).Count, @($APInvoiceLifecycleResult.cases).Count)

	$ConcurrencyRoot = Join-Path $TempRoot 'concurrency'
	New-Item -ItemType Directory -Path $ConcurrencyRoot -Force | Out-Null
	$StartPath = Join-Path $ConcurrencyRoot 'start.signal.json'
	$HolderReadyPath = Join-Path $ConcurrencyRoot 'holder-ready.json'
	$LockedPath = Join-Path $ConcurrencyRoot 'ar-lock-held.json'
	$ReceiptAttempt = Join-Path $ConcurrencyRoot 'receipt-1-attempt.json'
	$ReleasePath = Join-Path $ConcurrencyRoot 'release.signal.json'
	$LockHolderResult = Join-Path $ConcurrencyRoot 'ar-lock-holder.json'
	$ReceiptResultPath = Join-Path $ConcurrencyRoot 'receipt-1-result.json'
	$ConcurrencyResultPath = Join-Path $ConcurrencyRoot 'ar-concurrency-runtime.json'
	$ConcurrencyLog = Join-Path $ConcurrencyRoot 'ar-concurrency-runtime.log'
	$ConcurrencyArgs = 'ENTERPRISE /F"' + $E2EInfobase + '" /Ncfo_giamdoc /CRunARLockConcurrencyBackground;E2E-CONC-AR-INV;E2E-CONC-PT-1;' + $StartPath + ';' + $HolderReadyPath + ';' + $LockedPath + ';' + $ReceiptAttempt + ';' + $ReleasePath + ';' + $LockHolderResult + ';' + $ReceiptResultPath + ';' + $ConcurrencyResultPath + ' /DisableStartupMessages /Out"' + $ConcurrencyLog + '"'
	$ConcurrencyExit = Invoke-OneCProcess $ConcurrencyArgs $ConcurrencyLog 180000
	Copy-RunArtifacts $ConcurrencyResultPath $ConcurrencyLog
	Copy-RunArtifacts $LockHolderResult $ConcurrencyLog
	Copy-RunArtifacts $ReceiptResultPath $ConcurrencyLog
	Copy-RunArtifacts $ReceiptAttempt $ConcurrencyLog
	if (-not (Test-Path -LiteralPath $ConcurrencyResultPath)) { throw "Background concurrency test produced no JSON (1C exit $ConcurrencyExit)." }
	$ConcurrencyRuntime = Get-Content -LiteralPath $ConcurrencyResultPath -Raw | ConvertFrom-Json
	if ($ConcurrencyExit -ne 0 -or $ConcurrencyRuntime.status -notin @('PASS', 'BLOCKED_ENVIRONMENT')) {
		throw "AR DataLock concurrency assertion failed: $($ConcurrencyRuntime | ConvertTo-Json -Depth 10 -Compress)"
	}
	if ($ConcurrencyRuntime.status -eq 'BLOCKED_ENVIRONMENT') { $ConcurrencyBlocked = $true }
	if ($ConcurrencyRuntime.status -eq 'PASS') {
		if (-not (Test-Path -LiteralPath $LockHolderResult) -or -not (Test-Path -LiteralPath $ReceiptResultPath)) {
			throw 'AR DataLock concurrency reported PASS without both worker result records.'
		}
		$HolderCheck = Get-Content -LiteralPath $LockHolderResult -Raw | ConvertFrom-Json
		$ProbeCheck = Get-Content -LiteralPath $ReceiptResultPath -Raw | ConvertFrom-Json
		if ($HolderCheck.status -ne 'PASS' -or $ProbeCheck.status -ne 'PASS' -or -not $ProbeCheck.posted -or
			$ProbeCheck.ar_balance_vnd -ne 70000000 -or $ProbeCheck.ar_movements -le 0 -or
			$ProbeCheck.cash_movements -le 0 -or $ProbeCheck.gl_movements -le 0 -or
			-not $ConcurrencyRuntime.attempt_marker_before_release -or $ConcurrencyRuntime.lock_wait_seconds -lt 2) {
			throw "AR DataLock workers did not satisfy the posted-state, movement, balance, and lock-wait assertions: holder=$($HolderCheck | ConvertTo-Json -Compress), probe=$($ProbeCheck | ConvertTo-Json -Compress), coordinator=$($ConcurrencyRuntime | ConvertTo-Json -Compress)"
		}
	}

	if (Test-Path -LiteralPath $ReceiptResultPath) {
		$ReceiptResult = Get-Content -LiteralPath $ReceiptResultPath -Raw | ConvertFrom-Json
		$ReceiptExit = 0
	}
	else {
		$FallbackAttempt = Join-Path $ConcurrencyRoot 'receipt-1-sequential-attempt.json'
		$ReceiptResultPath = Join-Path $ConcurrencyRoot 'receipt-1-sequential-result.json'
		$ReceiptLog = Join-Path $ConcurrencyRoot 'receipt-1-sequential.log'
		$FallbackArgs = 'ENTERPRISE /F"' + $E2EInfobase + '" /Ncfo_giamdoc /CPostConcurrentARReceipt;E2E-CONC-PT-1;' + $FallbackAttempt + ';' + $ReceiptResultPath + ';POSTED /DisableStartupMessages /Out"' + $ReceiptLog + '"'
		$ReceiptExit = Invoke-OneCProcess $FallbackArgs $ReceiptLog
		Copy-RunArtifacts $FallbackAttempt $ReceiptLog
		Copy-RunArtifacts $ReceiptResultPath $ReceiptLog
		if (-not (Test-Path -LiteralPath $ReceiptResultPath)) { throw "Sequential fallback receipt produced no JSON (1C exit $ReceiptExit)." }
		$ReceiptResult = Get-Content -LiteralPath $ReceiptResultPath -Raw | ConvertFrom-Json
	}
	if ($ReceiptExit -ne 0 -or $ReceiptResult.status -ne 'PASS' -or -not $ReceiptResult.posted) {
		throw "Concurrent receipt/fallback failed: $($ReceiptResult | ConvertTo-Json -Depth 10 -Compress)"
	}

	$OverReceiptAttempt = Join-Path $ConcurrencyRoot 'receipt-2-attempt.json'
	$OverReceiptResultPath = Join-Path $ConcurrencyRoot 'receipt-2-result.json'
	$OverReceiptLog = Join-Path $ConcurrencyRoot 'receipt-2.log'
	$OverReceiptArgs = 'ENTERPRISE /F"' + $E2EInfobase + '" /Ncfo_giamdoc /CPostConcurrentARReceipt;E2E-CONC-PT-2;' + $OverReceiptAttempt + ';' + $OverReceiptResultPath + ';REJECTED /DisableStartupMessages /Out"' + $OverReceiptLog + '"'
	$OverReceiptExit = Invoke-OneCProcess $OverReceiptArgs $OverReceiptLog
	Copy-RunArtifacts $OverReceiptAttempt $OverReceiptLog
	Copy-RunArtifacts $OverReceiptResultPath $OverReceiptLog
	if (-not (Test-Path -LiteralPath $OverReceiptResultPath)) { throw "Over-collection test produced no JSON (1C exit $OverReceiptExit)." }
	$OverReceiptResult = Get-Content -LiteralPath $OverReceiptResultPath -Raw | ConvertFrom-Json
	if ($OverReceiptExit -ne 0 -or $OverReceiptResult.status -ne 'PASS' -or $OverReceiptResult.posted -or $OverReceiptResult.ar_balance_vnd -ne 70000000) {
		throw "Concurrent over-collection test failed: $($OverReceiptResult | ConvertTo-Json -Depth 10 -Compress)"
	}
	$ConcurrencySummary = [ordered]@{
		status = if ($ConcurrencyBlocked) { 'BLOCKED_ENVIRONMENT' } else { 'PASS' }
		background_runtime = $ConcurrencyRuntime
		lock_holder = if (Test-Path -LiteralPath $LockHolderResult) { Get-Content -LiteralPath $LockHolderResult -Raw | ConvertFrom-Json } else { $null }
		first_receipt_exit_code = $ReceiptExit
		second_receipt_exit_code = $OverReceiptExit
		first_receipt = $ReceiptResult
		over_collection_rejected = $OverReceiptResult
		reason = if ($ConcurrencyBlocked) { $ConcurrencyRuntime.error } else { '' }
	}
	$ConcurrencySummary | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath (Join-Path $ArtifactRoot 'ar-concurrency.json') -Encoding UTF8
	if ($ConcurrencyBlocked) { Write-Host 'BLOCKED_ENVIRONMENT background AR DataLock contention could not run in this file-mode runtime.' }
	else { Write-Host 'PASS concurrent AR DataLock and over-collection rejection (background lock holder + 1C posting)' }

	$InvariantJson = Join-Path $TempRoot 'posting-state-invariants.json'
	$InvariantLog = Join-Path $TempRoot 'posting-state-invariants.log'
	$InvariantArgs = 'ENTERPRISE /F"' + $E2EInfobase + '" /Nketoan_truong /CRunPostingStateInvariants;' + $RunId + ';' + $InvariantJson + ' /DisableStartupMessages /Out"' + $InvariantLog + '"'
	$InvariantExit = Invoke-OneCProcess $InvariantArgs $InvariantLog
	Copy-RunArtifacts $InvariantJson $InvariantLog
	if (-not (Test-Path -LiteralPath $InvariantJson)) { throw "Posting state invariant tests produced no result JSON (1C exit $InvariantExit)." }
	$InvariantResult = Get-Content -LiteralPath $InvariantJson -Raw | ConvertFrom-Json
	if ($InvariantExit -ne 0 -or $InvariantResult.status -ne 'PASS' -or @($InvariantResult.cases | Where-Object { -not $_.passed }).Count -gt 0) {
		throw "Posting state invariant tests failed: $($InvariantResult | ConvertTo-Json -Depth 10 -Compress)"
	}
	Write-Host ("PASS posting state invariants ({0}/{1})" -f @($InvariantResult.cases | Where-Object passed).Count, @($InvariantResult.cases).Count)

	$BoundaryJson = Join-Path $TempRoot 'boundaries.json'
	$BoundaryLog = Join-Path $TempRoot 'boundaries.log'
	$BoundaryArgs = 'ENTERPRISE /F"' + $E2EInfobase + '" /Nketoan_ap /CRunSeedBoundaries;' + $RunId + ';' + $BoundaryJson + ' /DisableStartupMessages /Out"' + $BoundaryLog + '"'
	$BoundaryExit = Invoke-OneCProcess $BoundaryArgs $BoundaryLog
	Copy-RunArtifacts $BoundaryJson $BoundaryLog
	if (-not (Test-Path -LiteralPath $BoundaryJson)) { throw "Boundary tests produced no result JSON (1C exit $BoundaryExit)." }
	$BoundaryResult = Get-Content -LiteralPath $BoundaryJson -Raw | ConvertFrom-Json
	if ($BoundaryExit -ne 0 -or $BoundaryResult.status -ne 'PASS' -or @($BoundaryResult.cases | Where-Object { -not $_.passed }).Count -gt 0) {
		throw "Boundary tests failed: $($BoundaryResult | ConvertTo-Json -Depth 10 -Compress)"
	}
	Write-Host 'PASS existing boundary/security tests (ketoan_ap, 3/3)'

	$ARSeedInfobase = Join-Path $TempRoot 'ar-seed-infobase'
	Copy-Item -LiteralPath $BaseInfobase -Destination $ARSeedInfobase -Recurse
	Invoke-Compile $ARSeedInfobase 'ar-seed-regression'
	# Prepare the default legal entity and its branch assignment before the
	# large AR document fixture runs under the maker/checker roles.
	Invoke-FinancePhase $ARSeedInfobase 'setup' 'Admin' | Out-Null
	$ARSeedStageResults = New-Object System.Collections.Generic.List[object]
	$ARSeedStageResults.Add((Invoke-ARSeedCommand $ARSeedInfobase '' 'cfo_giamdoc'))
	$ARSeedStageResults.Add((Invoke-ARSeedCommand $ARSeedInfobase 'PrepareAcceptances' 'ketoan_ar'))
	$ARSeedStageResults.Add((Invoke-ARSeedCommand $ARSeedInfobase 'PostAcceptances' 'ketoan_truong'))
	$ARSeedStageResults.Add((Invoke-ARSeedCommand $ARSeedInfobase 'PrepareInvoices' 'ketoan_ar'))
	$ARSeedStageResults.Add((Invoke-ARSeedCommand $ARSeedInfobase 'PostInvoices' 'ketoan_truong'))
	$ARSeedStageResults.Add((Invoke-ARSeedCommand $ARSeedInfobase 'PrepareReceipts' 'ketoan_ar'))
	$ARSeedStageResults.Add((Invoke-ARSeedCommand $ARSeedInfobase 'PostReceipts' 'cfo_giamdoc'))
	$ARSeedJson = Join-Path $TempRoot 'ar-seed-regression.json'
	$ARSeedLog = Join-Path $TempRoot 'ar-seed-regression.log'
	$ARSeedArgs = 'ENTERPRISE /F"' + $ARSeedInfobase + '" /Ncfo_giamdoc /CRunARSeedRegression;' + $RunId + ';' + $ARSeedJson + ' /DisableStartupMessages /Out"' + $ARSeedLog + '"'
	$ARSeedExit = Invoke-OneCProcess $ARSeedArgs $ARSeedLog 1800000
	Copy-RunArtifacts $ARSeedJson $ARSeedLog
	if (-not (Test-Path -LiteralPath $ARSeedJson)) { throw "AR seed regression produced no result JSON (1C exit $ARSeedExit)." }
	$ARSeedResult = Get-Content -LiteralPath $ARSeedJson -Raw | ConvertFrom-Json
	if ($ARSeedExit -ne 0 -or $ARSeedResult.status -ne 'PASS') {
		throw "AR seed regression failed (1C exit $ARSeedExit): $($ARSeedResult.error)"
	}
	Write-Host ("PASS AR seed regression: acceptances={0}, invoices={1}, receipts={2}" -f $ARSeedResult.data.posted_acceptances, $ARSeedResult.data.posted_invoices, $ARSeedResult.data.posted_receipts)

	$SeedInfobase = Join-Path $TempRoot 'ap-seed-infobase'
	Copy-Item -LiteralPath $BaseInfobase -Destination $SeedInfobase -Recurse
	Invoke-Compile $SeedInfobase 'ap-seed-regression'
	$APSeedStageResults = New-Object System.Collections.Generic.List[object]
	$APSeedStageResults.Add((Invoke-APSeedCommand $SeedInfobase '' 'cfo_giamdoc'))
	$APSeedStageResults.Add((Invoke-APSeedCommand $SeedInfobase 'PrepareInvoices' 'ketoan_ap'))
	$APSeedStageResults.Add((Invoke-APSeedCommand $SeedInfobase 'ApproveInvoicesKTT' 'ketoan_truong'))
	$APSeedStageResults.Add((Invoke-APSeedCommand $SeedInfobase 'PostHighInvoicesCFO' 'cfo_giamdoc'))
	$SeedJson = Join-Path $TempRoot 'ap-seed-regression.json'
	$SeedLog = Join-Path $TempRoot 'ap-seed-regression.log'
	$SeedArgs = 'ENTERPRISE /F"' + $SeedInfobase + '" /Ncfo_giamdoc /CRunAPSeedRegression;' + $RunId + ';' + $SeedJson + ' /DisableStartupMessages /Out"' + $SeedLog + '"'
	$SeedExit = Invoke-OneCProcess $SeedArgs $SeedLog 1800000
	Copy-RunArtifacts $SeedJson $SeedLog
	if (-not (Test-Path -LiteralPath $SeedJson)) { throw "AP seed regression produced no result JSON (1C exit $SeedExit)." }
	$SeedResult = Get-Content -LiteralPath $SeedJson -Raw | ConvertFrom-Json
	if ($SeedExit -ne 0 -or $SeedResult.status -ne 'PASS') {
		throw "AP seed regression failed (1C exit $SeedExit): $($SeedResult.error)"
	}
	Write-Host ("PASS AP seed regression: invoices={0}, USD={1}, payments={2}" -f $SeedResult.data.posted_invoices, $SeedResult.data.valid_usd_invoices, $SeedResult.data.posted_payments)

	# Cross-module FX and refund cycle: collect USD AR, settle USD AP from those
	# bank receipts, recognize the realized FX loss, then reverse and reconcile.
	Invoke-FinancePhase $E2EInfobase 'fx_prepare' 'Admin'
	Invoke-FinancePhase $E2EInfobase 'fx_submit_ar_invoices' 'ketoan_ar'
	Invoke-FinancePhase $E2EInfobase 'fx_post_ar_invoices' 'ketoan_truong'
	Invoke-FinancePhase $E2EInfobase 'fx_submit_ar_receipts' 'ketoan_ar'
	Invoke-FinancePhase $E2EInfobase 'fx_post_ar_receipts' 'cfo_giamdoc'
	Invoke-FinancePhase $E2EInfobase 'fx_submit_ap_invoice' 'ketoan_ap'
	Invoke-FinancePhase $E2EInfobase 'fx_post_ap_invoice' 'ketoan_truong'
	Invoke-FinancePhase $E2EInfobase 'fx_submit_ap_payment' 'ketoan_ap'
	Invoke-FinancePhase $E2EInfobase 'fx_approve_ap_payment' 'ketoan_truong'
	Invoke-FinancePhase $E2EInfobase 'fx_submit_bank_payment' 'ketoan_truong'
	Invoke-FinancePhase $E2EInfobase 'fx_post_ap_payment' 'cfo_giamdoc'
	Invoke-FinancePhase $E2EInfobase 'fx_submit_refund' 'ketoan_ap'
	Invoke-FinancePhase $E2EInfobase 'fx_approve_refund' 'ketoan_truong'
	Invoke-FinancePhase $E2EInfobase 'fx_reject_unconfirmed_refund' 'cfo_giamdoc'
	$FXRefundBankConfirmation = Invoke-FinanceBankUI $E2EInfobase 'E2E-REFUND-USD-01' 'RefundReceived' 'cfo_giamdoc'
	$FXRefundIdempotency = Invoke-FinanceBankUI $E2EInfobase 'E2E-REFUND-USD-DUP' 'RefundReceived' 'cfo_giamdoc'
	if ($FXRefundBankConfirmation.bank_transaction_id -ne $FXRefundIdempotency.bank_transaction_id) {
		throw 'Duplicate refund documents did not resolve to one idempotent incoming bank transaction.'
	}
	$FXRefundVerification = Invoke-FinancePhase $E2EInfobase 'fx_post_refund' 'cfo_giamdoc'
	$PostingCommandUIResult = Invoke-FinancePostingCommandsUI $E2EInfobase
	$PhaseResults.Add([PSCustomObject]@{
		run_id = $RunId
		phase = 'ui_posting_commands'
		user = 'ketoan_truong'
		status = 'PASS'
		error = ''
		data = $PostingCommandUIResult.posting_command_actions
	})

	# Branch RLS workflow runs last because it deliberately moves the business
	# users from branch 1 to branch 2 for an isolated session-scope verification.
	$BranchFixture = Invoke-FinancePhase $E2EInfobase 'branch_rls_prepare' 'Admin'
	Invoke-FinancePhase $E2EInfobase 'branch_rls_submit' 'ketoan_ar'
	Invoke-FinancePhase $E2EInfobase 'branch_rls_approve' 'ketoan_truong'
	Invoke-FinancePhase $E2EInfobase 'branch_rls_post' 'ketoan_truong'
	$BranchExtra = ';' + [string]$BranchFixture.data.branch1_legal_entity_uuid + ';' + [string]$BranchFixture.data.branch1_vendor_contract_uuid
	$BranchVerification = Invoke-FinancePhase $E2EInfobase 'branch_rls_verify' 'ketoan_ap' $BranchExtra
	$BranchRoleCreateUIResults = @(
		(Invoke-FinanceBranchRoleCreateUI $E2EInfobase 'ketoan_ar' 'Acceptance')
		(Invoke-FinanceBranchRoleCreateUI $E2EInfobase 'ketoan_ap' 'APInvoice')
	)

	$UIResultPath = Join-Path $TempRoot 'ui-e2e.json'
	$UIScript = Join-Path $PSScriptRoot 'run_finance_ui_e2e.ps1'
	$UIArgs = '-NoProfile -ExecutionPolicy Bypass -File "' + $UIScript + '" -OneCExe "' + $OneCExe + '" -Infobase "' + $E2EInfobase + '" -User Admin -ExpectedNumber E2E-AR001 -ResultPath "' + $UIResultPath + '"'
	$UIProcess = Start-Process -FilePath 'powershell.exe' -ArgumentList $UIArgs -PassThru
	if (-not $UIProcess.WaitForExit(180000)) {
		Stop-Process -Id $UIProcess.Id -Force
		throw 'Native 1C UI E2E automation timed out.'
	}
	if (-not (Test-Path -LiteralPath $UIResultPath)) { throw "Native 1C UI E2E produced no result JSON (exit $($UIProcess.ExitCode))." }
	$UIResult = Get-Content -LiteralPath $UIResultPath -Raw | ConvertFrom-Json
	Copy-Item -LiteralPath $UIResultPath -Destination $ArtifactRoot -Force
	if ($UIProcess.ExitCode -ne 0 -or $UIResult.status -ne 'PASS') {
		throw "Native 1C UI E2E failed: $($UIResult | ConvertTo-Json -Depth 8 -Compress)"
	}
	Write-Host 'PASS native 1C UI workflow (AR list → source document form → amounts)'
	$ARAutofillUIResult = Invoke-FinanceARAutofillUI $E2EInfobase

	$ListPeriodUIResult = Invoke-FinanceListPeriodUI $E2EInfobase
	$CatalogListUIResult = Invoke-FinanceCatalogUI $E2EInfobase
	$DocumentFormsUIResult = Invoke-FinanceDocumentFormsUI $E2EInfobase
	$APFCTFormUIResult = Invoke-FinanceFCTInvoiceUI $E2EInfobase
	$RequiredFieldUIResult = Invoke-FinanceRequiredFieldUI $E2EInfobase
	$ReferenceChoiceUIResult = Invoke-FinanceReferenceChoiceUI $E2EInfobase
	$ReportUIResult = Invoke-FinanceReportUI $E2EInfobase
	$FinanceGuideUIResult = Invoke-FinanceGuideUI $E2EInfobase
	$CustomCommandScript = Join-Path $PSScriptRoot 'test_custom_command_coverage.ps1'
	& $CustomCommandScript -ConfigurationPath $Configuration -ArtifactPath $ArtifactRoot | Out-Null
	$CustomCommandCoverage = Get-Content -LiteralPath (Join-Path $ArtifactRoot 'custom-command-coverage.json') -Raw -Encoding UTF8 | ConvertFrom-Json
	$Summary = [ordered]@{
		run_id = $RunId
		status = if ($ConcurrencyBlocked) { 'BLOCKED' } else { 'PASS' }
		phase_count = $PhaseResults.Count
		phases = $PhaseResults.ToArray()
		posting_lifecycle = $LifecycleResult
		gl_subledger_integrity = $GLSubledgerIntegrityResult
		ap_invoice_posting_lifecycle = $APInvoiceLifecycleResult
		posting_state_invariants = $InvariantResult
		ar_concurrency = $ConcurrencySummary
		boundary_tests = $BoundaryResult
		ar_seed_stages = $ARSeedStageResults.ToArray()
		ap_seed_stages = $APSeedStageResults.ToArray()
		ar_seed_regression = $ARSeedResult
		ap_seed_regression = $SeedResult
		branch_rls = $BranchVerification
		branch_role_form_create_ui = $BranchRoleCreateUIResults
		fx_refund = $FXRefundVerification
		fx_refund_ui_confirmation = @($FXRefundBankConfirmation, $FXRefundIdempotency)
		ui_e2e = $UIResult
		catalog_list_ui_e2e = $CatalogListUIResult
		list_period_ui_e2e = $ListPeriodUIResult
		document_forms_ui_e2e = $DocumentFormsUIResult
		ap_fct_form_ui_e2e = $APFCTFormUIResult
		required_field_ui_e2e = $RequiredFieldUIResult
		ar_autofill_ui_e2e = $ARAutofillUIResult
		reference_choice_ui_e2e = $ReferenceChoiceUIResult
		report_values_verification = $ReportValuesVerification
		report_ui_e2e = $ReportUIResult
		finance_guide_ui = $FinanceGuideUIResult
		custom_command_coverage = $CustomCommandCoverage
		posting_command_ui_e2e = $PostingCommandUIResult
		bank_ui_e2e = $BankUIResults.ToArray()
		batch_approval_ui = $BatchApprovalUIResult
		batch_approval_ui_state = $BatchApprovalUIVerification
		batch_approval_ui_contract = $BatchApprovalUIContract
		bank_stub_log = $BankStubLog
		temp_root = $TempRoot
		base_infobase = $BaseInfobase
		configuration_path = $Configuration
		artifact_root = $ArtifactRoot
	}
	$Summary | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath (Join-Path $ArtifactRoot 'summary.json') -Encoding UTF8
	if ($ConcurrencyBlocked) { throw "E2E BLOCKED_ENVIRONMENT: two-session AR concurrency could not execute in the available file-mode 1C environment. Artifacts: $ArtifactRoot" }
	Write-Host "E2E PASS. Artifacts: $ArtifactRoot"
}
catch {
	$FailureSummary = [ordered]@{
		run_id = $RunId
		status = if ($ConcurrencyBlocked -and $_.Exception.Message -like 'E2E BLOCKED_ENVIRONMENT:*') { 'BLOCKED' } else { 'FAIL' }
		error = $_.Exception.Message
		completed_phases = $PhaseResults.ToArray()
		posting_lifecycle = $LifecycleResult
		gl_subledger_integrity = $GLSubledgerIntegrityResult
		ap_invoice_posting_lifecycle = $APInvoiceLifecycleResult
		posting_state_invariants = $InvariantResult
		ar_concurrency = $ConcurrencySummary
		boundary_tests = $BoundaryResult
		ar_seed_regression = $ARSeedResult
		ap_seed_regression = $SeedResult
		branch_rls = $BranchVerification
		branch_role_form_create_ui = $BranchRoleCreateUIResults
		fx_refund = $FXRefundVerification
		fx_refund_ui_confirmation = @($FXRefundBankConfirmation, $FXRefundIdempotency)
		ui_e2e = $UIResult
		catalog_list_ui_e2e = $CatalogListUIResult
		list_period_ui_e2e = $ListPeriodUIResult
		document_forms_ui_e2e = $DocumentFormsUIResult
		ap_fct_form_ui_e2e = $APFCTFormUIResult
		required_field_ui_e2e = $RequiredFieldUIResult
		ar_autofill_ui_e2e = $ARAutofillUIResult
		reference_choice_ui_e2e = $ReferenceChoiceUIResult
		report_values_verification = $ReportValuesVerification
		report_ui_e2e = $ReportUIResult
		finance_guide_ui = $FinanceGuideUIResult
		custom_command_coverage = $CustomCommandCoverage
		bank_ui_e2e = $BankUIResults.ToArray()
		batch_approval_ui = $BatchApprovalUIResult
		batch_approval_ui_state = $BatchApprovalUIVerification
		batch_approval_ui_contract = $BatchApprovalUIContract
		bank_stub_log = $BankStubLog
		temp_root = $TempRoot
		base_infobase = $BaseInfobase
		configuration_path = $Configuration
		artifact_root = $ArtifactRoot
	}
	if (Test-Path -LiteralPath $ArtifactRoot) {
		$FailureSummary | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath (Join-Path $ArtifactRoot 'summary.json') -Encoding UTF8
	}
	throw
}
finally {
	if ($BankStubProcess -and -not $BankStubProcess.HasExited) {
		Stop-Process -Id $BankStubProcess.Id -Force -ErrorAction SilentlyContinue
	}
	if ($BankStubLog -and (Test-Path -LiteralPath $BankStubLog) -and $ArtifactRoot -and (Test-Path -LiteralPath $ArtifactRoot)) {
		Copy-Item -LiteralPath $BankStubLog -Destination $ArtifactRoot -Force
	}
}
