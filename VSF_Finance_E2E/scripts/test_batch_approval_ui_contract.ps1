[CmdletBinding()]
param(
	[Parameter(Mandatory = $true)][string]$ArtifactPath,
	[string]$UIResultPath
)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $ArtifactPath)) { throw "Artifact directory is missing: $ArtifactPath" }
if ([string]::IsNullOrWhiteSpace($UIResultPath)) { $UIResultPath = Join-Path $ArtifactPath 'ui-batch-approval.json' }
if (-not (Test-Path -LiteralPath $UIResultPath)) { throw "Batch approval UI evidence is missing: $UIResultPath" }
$VerificationPath = Join-Path $ArtifactPath 'batch_ui_verify.json'
if (-not (Test-Path -LiteralPath $VerificationPath)) { throw "Batch approval persisted-state verification is missing: $VerificationPath" }
$QueuePath = Join-Path $ArtifactPath 'batch_ui_queue_check.json'
if (-not (Test-Path -LiteralPath $QueuePath)) { throw "Batch approval isolated-queue evidence is missing: $QueuePath" }

$UIResult = Get-Content -LiteralPath $UIResultPath -Raw -Encoding UTF8 | ConvertFrom-Json
$Verification = Get-Content -LiteralPath $VerificationPath -Raw -Encoding UTF8 | ConvertFrom-Json
$Queue = Get-Content -LiteralPath $QueuePath -Raw -Encoding UTF8 | ConvertFrom-Json
$Failures = [System.Collections.Generic.List[string]]::new()
$RefreshAction = @($UIResult.batch_approval_actions | Where-Object action -eq 'refresh') | Select-Object -First 1
$ApproveOneAction = @($UIResult.batch_approval_actions | Where-Object action -eq 'approve_one') | Select-Object -First 1
$ApproveAllAction = @($UIResult.batch_approval_actions | Where-Object action -eq 'approve_all') | Select-Object -First 1

if ($UIResult.status -ne 'PASS' -or $UIResult.workflow -ne 'BatchApproval' -or $UIResult.user -ne 'ketoan_truong') {
	$Failures.Add('Batch approval controls must be exercised in the native KTT BatchApproval session.')
}
if (-not $UIResult.batch_approval_panel_opened) { $Failures.Add('Batch approval panel did not open from the dashboard.') }

$RefreshText = if ($RefreshAction) { [string]$RefreshAction.notification_text } else { '' }
$RefreshPassed = $null -ne $RefreshAction -and $RefreshAction.invoked -and
	$RefreshAction.notification_visible -and $RefreshText.Contains('Đã cập nhật danh sách chờ duyệt')
if (-not $RefreshPassed) { $Failures.Add('Refresh action did not show its expected runtime notification.') }

$ApproveOneText = if ($ApproveOneAction) { [string]$ApproveOneAction.notification_text } else { '' }
$ApproveOnePassed = $null -ne $ApproveOneAction -and $ApproveOneAction.invoked -and
	$ApproveOneAction.notification_visible -and $ApproveOneText.Contains('Duyệt chứng từ hoàn tất: 1 thành công, 0 thất bại')
if (-not $ApproveOnePassed) { $Failures.Add('Single-row approval action did not report one successful approval and zero failures.') }

$ApproveAllText = if ($ApproveAllAction) { [string]$ApproveAllAction.notification_text } else { '' }
$ApproveAllPassed = $null -ne $ApproveAllAction -and $ApproveAllAction.invoked -and
	$ApproveAllAction.notification_visible -and $ApproveAllText.Contains('Phê duyệt hoàn tất: 1 thành công, 0 thất bại')
if (-not $ApproveAllPassed) { $Failures.Add('Approve-all action did not report one successful approval for the sole remaining queue item.') }

$QueueSafetyPassed = $Queue.status -eq 'PASS' -and
	$Queue.data.ktt_queue_count -eq 2 -and
	$Queue.data.document_number -eq 'E2E-BATCH-UI' -and
	$Queue.data.approve_all_document_number -eq 'E2E-BATCH-UI-ALL' -and
	$Queue.data.document_type -eq 'HoaDonNhaCungCap' -and
	$UIResult.batch_approval_panel_opened -and
	$UIResult.after_click_screenshot_path -and (Test-Path -LiteralPath $UIResult.after_click_screenshot_path) -and
	$UIResult.after_row_approval_screenshot_path -and (Test-Path -LiteralPath $UIResult.after_row_approval_screenshot_path)
if (-not $QueueSafetyPassed) { $Failures.Add('The native batch screen lacks server-confirmed isolated queue evidence and before/after row-action screenshots.') }

$PersistedStatePassed = $Verification.status -eq 'PASS' -and
	$Verification.data.document_number -eq 'E2E-BATCH-UI' -and
	$Verification.data.posted -and
	-not [string]::IsNullOrWhiteSpace([string]$Verification.data.status) -and
	$Verification.data.open_ap_vnd -eq 1000000 -and
	$Verification.data.gl_rows -gt 0 -and
	$Verification.data.cash_rows -eq 0 -and
	$Verification.data.approve_all_document_number -eq 'E2E-BATCH-UI-ALL' -and
	$Verification.data.approve_all_posted -and
	$Verification.data.approve_all_open_ap_vnd -eq 1000000 -and
	$Verification.data.approve_all_gl_rows -gt 0 -and
	$Verification.data.approve_all_cash_rows -eq 0 -and
	$Verification.data.ktt_queue_count -eq 0
if (-not $PersistedStatePassed) { $Failures.Add('The UI batch actions did not persist the expected AP postings and empty KTT queue.') }

$Cases = @(
	[PSCustomObject]@{ action = 'refresh'; passed = [bool]$RefreshPassed; notification = $RefreshText },
	[PSCustomObject]@{ action = 'approve_one'; passed = [bool]$ApproveOnePassed; notification = $ApproveOneText },
	[PSCustomObject]@{ action = 'approve_all'; passed = [bool]$ApproveAllPassed; notification = $ApproveAllText },
	[PSCustomObject]@{ action = 'isolated_two_document_queue'; passed = [bool]$QueueSafetyPassed; row_document = [string]$Queue.data.document_number; approve_all_document = [string]$Queue.data.approve_all_document_number },
	[PSCustomObject]@{ action = 'persisted_ap_state'; passed = [bool]$PersistedStatePassed; row_document = [string]$Verification.data.document_number; approve_all_document = [string]$Verification.data.approve_all_document_number }
)
$Summary = [ordered]@{
	status = if ($Failures.Count -eq 0 -and @($Cases | Where-Object passed).Count -eq 5) { 'PASS' } else { 'FAIL' }
	case_count = $Cases.Count
	passed_count = @($Cases | Where-Object passed).Count
	batch_approval_panel_opened = [bool]$UIResult.batch_approval_panel_opened
	cases = $Cases
	failures = $Failures.ToArray()
	output_path = [System.IO.Path]::GetFullPath((Join-Path $ArtifactPath 'batch-approval-ui-contract.json'))
}
[System.IO.File]::WriteAllText($Summary.output_path, ($Summary | ConvertTo-Json -Depth 8), [System.Text.UTF8Encoding]::new($false))
$Summary | ConvertTo-Json -Depth 8
if ($Summary.status -ne 'PASS') { throw "Batch approval UI contract failed with $($Failures.Count) issue(s)." }
