[CmdletBinding()]
param(
	[string]$OneCExe = 'C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\1cv8t.exe',
	[Parameter(Mandatory = $true)][string]$Infobase,
	[string]$User = 'Admin',
	[ValidateSet('ARInvoice', 'ARAutofillSmoke', 'BankSend', 'RefundConfirm', 'ListPeriods', 'CatalogSmoke', 'FormSmoke', 'ReportSmoke', 'GuideSmoke', 'FCTInvoiceSmoke', 'BatchApproval', 'PostingCommandDiagnostics', 'ListFilterDiagnostics', 'ReferenceChoiceDiagnostics', 'RequiredFieldDiagnostics')][string]$Workflow = 'ARInvoice',
	[ValidateSet('Acceptance', 'ARInvoice', 'Receipt', 'APInvoice', 'Payment')][string]$ReferenceChoiceDocument = 'ARInvoice',
	[ValidateSet('Acceptance', 'ARInvoice', 'Receipt', 'APInvoice', 'Payment', 'Netting', 'Reconciliation')][string]$RequiredFieldDocument = 'Acceptance',
	[ValidateSet('All', 'SoChiTietCongNoAR', 'SoChiTietCongNoAP', 'BaoCaoTuoiNo')][string]$ReportOnly = 'All',
	[string]$ExpectedNumber = 'E2E-AR001',
	[string]$FormSmokeDocumentNumber = '',
	[string]$ExpectedPaymentNumber = 'E2E-UNC01',
	[ValidateSet('Accepted', 'Rejected', 'RefundReceived')][string]$ExpectedBankOutcome = 'Accepted',
	[Parameter(Mandatory = $true)][string]$ResultPath
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
Add-Type -AssemblyName System.Windows.Forms
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class FinanceE2EUIInput {
    [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr window);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern void mouse_event(uint flags, uint dx, uint dy, uint data, UIntPtr extra);
}
'@

function Get-UIElements([System.Windows.Automation.AutomationElement]$Root) {
	return $Root.FindAll([System.Windows.Automation.TreeScope]::Descendants, [System.Windows.Automation.Condition]::TrueCondition)
}

function Get-FormActionButtonCandidates([System.Windows.Automation.AutomationElement]$Root, [System.Windows.Automation.AutomationElement]$Form, [string]$Name) {
	$FormRect = $Form.Current.BoundingRectangle
	$ApplicationRect = $Root.Current.BoundingRectangle
	$VisibleCandidates = @(
		Get-UIElements $Root |
		Where-Object {
			$Rect = $_.Current.BoundingRectangle
			$_.Current.ControlType.ProgrammaticName -eq 'ControlType.Button' -and $_.Current.Name -eq $Name -and
			-not $_.Current.IsOffscreen -and -not $Rect.IsEmpty -and $Rect.Width -gt 0 -and $Rect.Height -gt 0 -and
			$Rect.X -ge $ApplicationRect.X -and ($Rect.X + $Rect.Width) -le ($ApplicationRect.X + $ApplicationRect.Width) -and
			$Rect.Y -ge $ApplicationRect.Y -and ($Rect.Y + $Rect.Height) -le ($ApplicationRect.Y + $ApplicationRect.Height)
		} |
		ForEach-Object {
			$Rect = $_.Current.BoundingRectangle
			[PSCustomObject]@{ element = $_; enabled = $_.Current.IsEnabled; bounds = @($Rect.X, $Rect.Y, $Rect.Width, $Rect.Height) }
		}
	)
	$HasUsableFormBounds = -not $FormRect.IsEmpty
	$FormCoordinates = @($FormRect.X, $FormRect.Y, $FormRect.Width, $FormRect.Height)
	foreach ($Coordinate in @($FormRect.X, $FormRect.Y, $FormRect.Width, $FormRect.Height)) {
		$NumericCoordinate = [double]$Coordinate
		if ([double]::IsNaN($NumericCoordinate) -or [double]::IsInfinity($NumericCoordinate)) { $HasUsableFormBounds = $false }
	}
	$script:FormActionButtonDiagnostic = [PSCustomObject]@{
		name = $Name
		form_is_empty = [bool]$FormRect.IsEmpty
		form_coordinates = $FormCoordinates
		form_width = $FormRect.Width
		form_height = $FormRect.Height
		usable_form_bounds = $HasUsableFormBounds
		application_bounds = @($ApplicationRect.X, $ApplicationRect.Y, $ApplicationRect.Width, $ApplicationRect.Height)
		visible_candidate_count = $VisibleCandidates.Count
		visible_candidates = @($VisibleCandidates | ForEach-Object { [PSCustomObject]@{ enabled = $_.enabled; bounds = $_.bounds } })
		path = ''
		returned_count = 0
	}
	if (-not $HasUsableFormBounds -or $FormRect.Width -le 0 -or $FormRect.Height -le 0) {
		$script:FormActionButtonDiagnostic.path = 'unique-visible-candidate-fallback'
		if ($VisibleCandidates.Count -eq 1) { $script:FormActionButtonDiagnostic.returned_count = 1; return $VisibleCandidates }
		$script:FormActionButtonDiagnostic.returned_count = 0
		return @()
	}
	$FormCommandCandidates = @(
		$VisibleCandidates |
		Where-Object { [double]$_.bounds[1] -ge ([double]$FormRect.Y + [double]$FormRect.Height) } |
		Sort-Object { [double]$_.bounds[1] }
	)
	if ($FormCommandCandidates.Count -gt 0) {
		$script:FormActionButtonDiagnostic.path = 'document-form-command-row'
		$script:FormActionButtonDiagnostic.returned_count = $FormCommandCandidates.Count
		return $FormCommandCandidates
	}
	if ($VisibleCandidates.Count -eq 1) {
		$script:FormActionButtonDiagnostic.path = 'unique-visible-candidate-fallback'
		$script:FormActionButtonDiagnostic.returned_count = 1
		return $VisibleCandidates
	}
	$script:FormActionButtonDiagnostic.path = 'no-unambiguous-candidate'
	$script:FormActionButtonDiagnostic.returned_count = 0
	return @()
}

function Get-FormAudit([System.Windows.Automation.AutomationElement]$Form, [string]$ScreenName, [System.Windows.Automation.AutomationElement]$Root) {
	$Controls = @($Form.FindAll([System.Windows.Automation.TreeScope]::Descendants, [System.Windows.Automation.Condition]::TrueCondition))
	$FormRect = $Form.Current.BoundingRectangle
	$Scope = 'form_descendants'
	if ($Controls.Count -lt 2 -and -not $FormRect.IsEmpty -and $FormRect.Width -gt 0 -and $FormRect.Height -gt 0) {
		$Controls = @(Get-UIElements $Root | Where-Object { -not $_.Current.IsOffscreen })
		$Scope = 'visible_controls_in_active_window'
	}
	$InputTypes = @('ControlType.Edit', 'ControlType.ComboBox', 'ControlType.CheckBox', 'ControlType.RadioButton', 'ControlType.List', 'ControlType.DataGrid')
	$ButtonTypes = @('ControlType.Button', 'ControlType.MenuItem', 'ControlType.Hyperlink')
	$VisibleInputs = @($Controls | Where-Object { $_.Current.ControlType.ProgrammaticName -in $InputTypes -and -not $_.Current.IsOffscreen })
	$VisibleButtons = @($Controls | Where-Object { $_.Current.ControlType.ProgrammaticName -in $ButtonTypes -and -not $_.Current.IsOffscreen })
	$VisibleTableControls = @(
		Get-UIElements $Root |
		Where-Object {
			$_.Current.ControlType.ProgrammaticName -in @('ControlType.DataGrid', 'ControlType.Table') -and
			-not $_.Current.IsOffscreen
		} |
		ForEach-Object {
			$Rect = $_.Current.BoundingRectangle
			[PSCustomObject]@{
				name = [string]$_.Current.Name
				control_type = $_.Current.ControlType.ProgrammaticName
				bounds = @($Rect.X, $Rect.Y, $Rect.Width, $Rect.Height)
			}
		}
	)
	$NamedVisibleInputs = @($VisibleInputs | Where-Object { -not [string]::IsNullOrWhiteSpace($_.Current.Name) } | ForEach-Object { $_.Current.Name } | Select-Object -Unique)
	$EnabledButtonNames = @($VisibleButtons | Where-Object { $_.Current.IsEnabled -and -not [string]::IsNullOrWhiteSpace($_.Current.Name) } | ForEach-Object { $_.Current.Name } | Select-Object -Unique)
	$DisabledButtonNames = @($VisibleButtons | Where-Object { -not $_.Current.IsEnabled -and -not [string]::IsNullOrWhiteSpace($_.Current.Name) } | ForEach-Object { $_.Current.Name } | Select-Object -Unique)
	$VisibleControlDetails = @(
		$VisibleInputs | ForEach-Object {
			$Value = ''
			try { $Value = [string]$_.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern).Current.Value } catch { }
			$Rect = $_.Current.BoundingRectangle
			[PSCustomObject]@{
				name = $_.Current.Name
				automation_id = $_.Current.AutomationId
				control_type = $_.Current.ControlType.ProgrammaticName
				value = $Value
				enabled = $_.Current.IsEnabled
				offscreen = $_.Current.IsOffscreen
				bounds = @($Rect.X, $Rect.Y, $Rect.Width, $Rect.Height)
			}
		}
	)
	return [PSCustomObject]@{
		screen = $ScreenName
		control_scope = $Scope
		form_bounds = @($FormRect.X, $FormRect.Y, $FormRect.Width, $FormRect.Height)
		visible_edit_count = @($VisibleInputs | Where-Object { $_.Current.ControlType.ProgrammaticName -eq 'ControlType.Edit' }).Count
		visible_input_count = $VisibleInputs.Count
		visible_field_names = $NamedVisibleInputs
		visible_control_details = $VisibleControlDetails
		visible_table_controls = $VisibleTableControls
		visible_button_count = $VisibleButtons.Count
		visible_button_names = @($VisibleButtons | Where-Object { -not [string]::IsNullOrWhiteSpace($_.Current.Name) } | ForEach-Object { $_.Current.Name } | Select-Object -Unique)
		enabled_button_names = $EnabledButtonNames
		disabled_button_names = $DisabledButtonNames
	}
}

function Get-FormTabAudit([System.Windows.Automation.AutomationElement]$Form, [string]$DocumentType, [System.Windows.Automation.AutomationElement]$Root) {
	$AllTabItemNames = @(
		Get-UIElements $Form |
		Where-Object { $_.Current.ControlType.ProgrammaticName -eq 'ControlType.TabItem' -and -not [string]::IsNullOrWhiteSpace($_.Current.Name) } |
		ForEach-Object { [string]$_.Current.Name } |
		Select-Object -Unique
	)
	$TabItems = @(
		Get-UIElements $Form |
		Where-Object {
			$_.Current.ControlType.ProgrammaticName -eq 'ControlType.TabItem' -and
			-not $_.Current.IsOffscreen -and -not [string]::IsNullOrWhiteSpace($_.Current.Name) -and
			$_.Current.Name -notlike '*Chuyển động của chứng từ theo sổ*' -and
			$_.Current.Name -notin @('Sổ cái kế toán','Công nợ phải thu','Công nợ phải trả','Dòng tiền & ngân hàng')
		} |
		Sort-Object { $_.Current.BoundingRectangle.X }
	)
	if ($TabItems.Count -eq 0) {
		$TabItems = @(
			Get-UIElements $Root |
			Where-Object {
				$_.Current.ControlType.ProgrammaticName -eq 'ControlType.TabItem' -and
				-not $_.Current.IsOffscreen -and -not [string]::IsNullOrWhiteSpace($_.Current.Name) -and
				$_.Current.Name -notlike '*Chuyển động của chứng từ theo sổ*' -and
				$_.Current.Name -notin @('Sổ cái kế toán','Công nợ phải thu','Công nợ phải trả','Dòng tiền & ngân hàng')
			} |
			Sort-Object { $_.Current.BoundingRectangle.X }
		)
	}
	if ($TabItems.Count -eq 0) {
		return [PSCustomObject]@{ document_type = $DocumentType; page_count = 0; tabs = @(); available_tab_items = $AllTabItemNames }
	}

	$TabAudits = @()
	foreach ($TabItem in $TabItems) {
		$TabName = [string]$TabItem.Current.Name
		$SelectionConfirmed = $false
		try {
			$TabItem.GetCurrentPattern([System.Windows.Automation.SelectionItemPattern]::Pattern).Select()
		} catch {
			Invoke-UIElement $TabItem
		}

		$SelectionDeadline = (Get-Date).AddSeconds(4)
		do {
			try {
				$CurrentTab = @(
					Get-UIElements $Root |
					Where-Object { $_.Current.ControlType.ProgrammaticName -eq 'ControlType.TabItem' -and $_.Current.Name -eq $TabName } |
					Select-Object -First 1
				)
				if ($CurrentTab.Count -gt 0) {
					$SelectionConfirmed = [bool]$CurrentTab[0].GetCurrentPattern([System.Windows.Automation.SelectionItemPattern]::Pattern).Current.IsSelected
				}
			} catch { }
			if (-not $SelectionConfirmed) { Start-Sleep -Milliseconds 100 }
		} while (-not $SelectionConfirmed -and (Get-Date) -lt $SelectionDeadline)

		if (-not $SelectionConfirmed) {
			Invoke-UIElement $TabItem
			$SelectionDeadline = (Get-Date).AddSeconds(4)
			do {
				try {
					$CurrentTab = @(
						Get-UIElements $Root |
						Where-Object { $_.Current.ControlType.ProgrammaticName -eq 'ControlType.TabItem' -and $_.Current.Name -eq $TabName } |
						Select-Object -First 1
					)
					if ($CurrentTab.Count -gt 0) {
						$SelectionConfirmed = [bool]$CurrentTab[0].GetCurrentPattern([System.Windows.Automation.SelectionItemPattern]::Pattern).Current.IsSelected
					}
				} catch { }
				if (-not $SelectionConfirmed) { Start-Sleep -Milliseconds 100 }
			} while (-not $SelectionConfirmed -and (Get-Date) -lt $SelectionDeadline)
		}
		if (-not $SelectionConfirmed) {
			$TabDiagnostics = @(
				$TabItems | ForEach-Object {
					$SelectedState = 'unsupported'
					$SupportedPatternNames = @()
					try {
						$SelectionPattern = $_.GetCurrentPattern([System.Windows.Automation.SelectionItemPattern]::Pattern)
						$SelectedState = [string]$SelectionPattern.Current.IsSelected
					} catch { $SelectedState = 'error:' + $_.Exception.Message }
					try { $SupportedPatternNames = @($_.GetSupportedPatterns() | ForEach-Object { $_.ProgrammaticName }) } catch { }
					$Rect = $_.Current.BoundingRectangle
					[PSCustomObject]@{ name = $_.Current.Name; enabled = $_.Current.IsEnabled; offscreen = $_.Current.IsOffscreen; selected = $SelectedState; patterns = $SupportedPatternNames; bounds = @($Rect.X, $Rect.Y, $Rect.Width, $Rect.Height) }
				} | ConvertTo-Json -Depth 4 -Compress
			)
			$CurrentFormAudit = Get-FormAudit $Form ($DocumentType + '/tab-selection-failure') $Root
			throw "Could not select document form tab '$TabName' on $DocumentType. Visible fields: $($CurrentFormAudit.visible_field_names -join ' | '). Tab controls: $($TabDiagnostics -join ' ')"
		}

		Start-Sleep -Milliseconds 150
		$Audit = Get-FormAudit $Form ($DocumentType + '/' + $TabName) $Root
		$TabRect = $TabItem.Current.BoundingRectangle
		$TabContentTop = [double]$TabRect.Y + [double]$TabRect.Height
		$FieldDetails = @(
			$Audit.visible_control_details |
			Where-Object {
				$Bounds = @($_.bounds)
				$_.control_type -in @('ControlType.Edit', 'ControlType.ComboBox', 'ControlType.CheckBox', 'ControlType.RadioButton', 'ControlType.DataGrid') -and
				-not [string]::IsNullOrWhiteSpace([string]$_.name) -and
				$Bounds.Count -eq 4 -and [double]$Bounds[1] -ge $TabContentTop -and
				[double]$Bounds[2] -gt 0 -and [double]$Bounds[3] -gt 0
			}
		)
		if ($FieldDetails.Count -lt 1) { throw "Document form tab '$TabName' on $DocumentType has no visible, named input controls below the tab strip." }
		$FieldNames = @($FieldDetails | ForEach-Object { [string]$_.name } | Select-Object -Unique)
		$TabAudits += [PSCustomObject]@{
			name = $TabName
			visited = $true
			selected = $true
			tab_bounds = @($TabRect.X, $TabRect.Y, $TabRect.Width, $TabRect.Height)
			visible_input_count = $FieldDetails.Count
			visible_field_names = $FieldNames
			visible_control_details = $FieldDetails
			enabled_button_names = $Audit.enabled_button_names
			disabled_button_names = $Audit.disabled_button_names
		}
	}

	$FirstTab = $TabItems[0]
	$FirstTabName = [string]$FirstTab.Current.Name
	try {
		$FirstTab.GetCurrentPattern([System.Windows.Automation.SelectionItemPattern]::Pattern).Select()
	} catch {
		Invoke-UIElement $FirstTab
	}
	$RestoreDeadline = (Get-Date).AddSeconds(4)
	$Restored = $false
	do {
		try {
			$RestoredTab = @(
				Get-UIElements $Root |
				Where-Object { $_.Current.ControlType.ProgrammaticName -eq 'ControlType.TabItem' -and $_.Current.Name -eq $FirstTabName } |
				Select-Object -First 1
			)
			if ($RestoredTab.Count -gt 0) {
				$Restored = [bool]$RestoredTab[0].GetCurrentPattern([System.Windows.Automation.SelectionItemPattern]::Pattern).Current.IsSelected
			}
		} catch { }
		if (-not $Restored) { Start-Sleep -Milliseconds 100 }
	} while (-not $Restored -and (Get-Date) -lt $RestoreDeadline)
	if (-not $Restored) { throw "Could not restore the first tab '$FirstTabName' on $DocumentType." }

	return [PSCustomObject]@{
		document_type = $DocumentType
		page_count = $TabItems.Count
		tabs = $TabAudits
		available_tab_items = $AllTabItemNames
	}
}

function Wait-UIElement([System.Windows.Automation.AutomationElement]$Root, [string]$Name, [string]$ControlType, [int]$TimeoutSeconds = 20) {
	$Deadline = (Get-Date).AddSeconds($TimeoutSeconds)
	do {
		foreach ($Element in (Get-UIElements $Root)) {
			if ($Element.Current.Name -eq $Name -and $Element.Current.ControlType.ProgrammaticName -eq $ControlType) { return $Element }
		}
		Start-Sleep -Milliseconds 250
	} while ((Get-Date) -lt $Deadline)
	throw "UI element not found: $ControlType '$Name'."
}

function Wait-UIElementLike([System.Windows.Automation.AutomationElement]$Root, [string]$NamePattern, [string]$ControlType, [int]$TimeoutSeconds = 20) {
	$Deadline = (Get-Date).AddSeconds($TimeoutSeconds)
	do {
		foreach ($Element in (Get-UIElements $Root)) {
			if ($Element.Current.Name -like $NamePattern -and $Element.Current.ControlType.ProgrammaticName -eq $ControlType) { return $Element }
		}
		Start-Sleep -Milliseconds 250
	} while ((Get-Date) -lt $Deadline)
	$Candidates = @(Get-UIElements $Root | Where-Object { $_.Current.ControlType.ProgrammaticName -eq $ControlType } | ForEach-Object { $_.Current.Name } | Where-Object { $_ } | Select-Object -Unique)
	throw "UI element not found: $ControlType '$NamePattern'. Candidates: $($Candidates -join ' | ')"
}

function Invoke-UIElement([System.Windows.Automation.AutomationElement]$Element) {
	$Rect = $Element.Current.BoundingRectangle
	if ($Rect.IsEmpty -or $Rect.Width -le 0 -or $Rect.Height -le 0) { throw "UI element has no visible bounds: $($Element.Current.Name)" }
	$x = [int]($Rect.X + ($Rect.Width / 2))
	$y = [int]($Rect.Y + ($Rect.Height / 2))
	[void][FinanceE2EUIInput]::SetCursorPos($x, $y)
	[FinanceE2EUIInput]::mouse_event(2, 0, 0, 0, [UIntPtr]::Zero)
	[FinanceE2EUIInput]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero)
}

function Wait-VisibleNotification([System.Windows.Automation.AutomationElement]$Root, [string]$ExpectedText, [int]$TimeoutSeconds = 6) {
	$Deadline = (Get-Date).AddSeconds($TimeoutSeconds)
	do {
		$NotificationMatches = [System.Collections.Generic.List[string]]::new()
		foreach ($SearchRoot in @($Root, [System.Windows.Automation.AutomationElement]::RootElement)) {
			foreach ($Element in (Get-UIElements $SearchRoot)) {
				if ($Element.Current.IsOffscreen) { continue }
				$Parts = @([string]$Element.Current.Name)
				try { $Parts += [string]$Element.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern).Current.Value } catch { }
				try { $Parts += [string]$Element.Current.HelpText } catch { }
				$Combined = ($Parts -join ' ').Trim()
				if ($Combined.Contains($ExpectedText) -and -not $NotificationMatches.Contains($Combined)) { $NotificationMatches.Add($Combined) }
			}
		}
		if ($NotificationMatches.Count -gt 0) { return [PSCustomObject]@{ visible = $true; text = ($NotificationMatches -join ' | ') } }
		Start-Sleep -Milliseconds 200
	} while ((Get-Date) -lt $Deadline)
	return [PSCustomObject]@{ visible = $false; text = '' }
}

function Invoke-ListActionForm([System.Windows.Automation.AutomationElement]$Root, [string]$CommandName, [string]$Context) {
	$CommandButton = $null
	foreach ($Element in (Get-UIElements $Root)) {
		if ($Element.Current.ControlType.ProgrammaticName -eq 'ControlType.Button' -and $Element.Current.Name -eq $CommandName -and -not $Element.Current.IsOffscreen) {
			$CommandButton = $Element
			break
		}
	}
	if ($null -eq $CommandButton -or -not $CommandButton.Current.IsEnabled) {
		throw "$Context does not expose an enabled $CommandName command."
	}
	Invoke-UIElement $CommandButton
	try {
		$SaveButton = Wait-UIElement $Root 'Save' 'ControlType.Button' 10
	} catch {
		$VisibleState = @(
			Get-UIElements $Root |
			Where-Object { -not $_.Current.IsOffscreen -and $_.Current.ControlType.ProgrammaticName -in @('ControlType.Pane', 'ControlType.Button', 'ControlType.MenuItem', 'ControlType.Text', 'ControlType.Window') } |
			ForEach-Object {
				$Rect = $_.Current.BoundingRectangle
				$Value = ''
				try { $Value = [string]$_.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern).Current.Value } catch { }
				[PSCustomObject]@{ name = $_.Current.Name; type = $_.Current.ControlType.ProgrammaticName; value = $Value; enabled = $_.Current.IsEnabled; bounds = @($Rect.X, $Rect.Y, $Rect.Width, $Rect.Height) }
			} |
			Select-Object -Unique name,type,value,enabled,bounds
		)
		throw "$CommandName did not expose a Save command for $Context. Visible state: $(ConvertTo-Json -InputObject $VisibleState -Compress -Depth 4)"
	}
	if ($SaveButton.Current.IsOffscreen) { throw "$CommandName did not open a visible form for $Context." }
	[System.Windows.Forms.SendKeys]::SendWait('^{F4}')
	$CommandReturned = $false
	$Deadline = (Get-Date).AddSeconds(8)
	do {
		foreach ($Element in (Get-UIElements $Root)) {
			if ($Element.Current.ControlType.ProgrammaticName -eq 'ControlType.Button' -and $Element.Current.Name -eq $CommandName -and -not $Element.Current.IsOffscreen -and $Element.Current.IsEnabled) {
				$CommandReturned = $true
				break
			}
		}
		if (-not $CommandReturned) { Start-Sleep -Milliseconds 250 }
	} while (-not $CommandReturned -and (Get-Date) -lt $Deadline)
	if (-not $CommandReturned) { throw "$CommandName form did not close back to the list for $Context." }
	return $true
}

function Find-ListRow([System.Windows.Automation.AutomationElement]$Root, [string]$DocumentNumber) {
	foreach ($Element in (Get-UIElements $Root)) {
		if ($Element.Current.ControlType.ProgrammaticName -eq 'ControlType.Custom' -and $Element.Current.Name -like ($DocumentNumber + '*')) {
			return $Element
		}
	}
	return $null
}

function Wait-ListRowState([System.Windows.Automation.AutomationElement]$Root, [string]$DocumentNumber, [bool]$ExpectedVisible, [int]$TimeoutSeconds = 12) {
	$Deadline = (Get-Date).AddSeconds($TimeoutSeconds)
	do {
		$IsVisible = $null -ne (Find-ListRow $Root $DocumentNumber)
		if ($IsVisible -eq $ExpectedVisible) { return }
		Start-Sleep -Milliseconds 250
	} while ((Get-Date) -lt $Deadline)
	$ActualState = if ($ExpectedVisible) { 'not visible' } else { 'still visible' }
	throw "List row $DocumentNumber is $ActualState after the period filter change."
}

function Set-PeriodFilter([System.Windows.Automation.AutomationElement]$Root, [string]$Period) {
	$PeriodIndex = switch ($Period) {
		'TatCa' { 0 }
		'HomNay' { 1 }
		'ThangNay' { 2 }
		'QuyNay' { 3 }
		default { throw "Unsupported list period '$Period'." }
	}
	$PeriodControl = $null
	foreach ($Element in (Get-UIElements $Root)) {
		if ($Element.Current.ControlType.ProgrammaticName -eq 'ControlType.ComboBox' -and $Element.Current.Name -like 'Kỳ*') {
			$PeriodControl = $Element
			break
		}
	}
	if ($null -eq $PeriodControl) { throw 'List period ComboBox was not found.' }
	$PeriodValues = @('TatCa', 'HomNay', 'ThangNay', 'QuyNay')
	$CurrentValue = [string]$PeriodControl.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern).Current.Value
	$CurrentIndex = [Array]::IndexOf($PeriodValues, $CurrentValue)
	if ($CurrentIndex -lt 0) { throw "Unknown current period value '$CurrentValue'." }
	$Steps = $PeriodIndex - $CurrentIndex
	$PeriodControl.SetFocus()
	[System.Windows.Forms.SendKeys]::SendWait('%{DOWN}')
	Start-Sleep -Milliseconds 150
	for ($Index = 0; $Index -lt [Math]::Abs($Steps); $Index++) {
		$Key = if ($Steps -gt 0) { '{DOWN}' } else { '{UP}' }
		[System.Windows.Forms.SendKeys]::SendWait($Key)
	}
	[System.Windows.Forms.SendKeys]::SendWait('{ENTER}')
	[System.Windows.Forms.SendKeys]::SendWait('{TAB}')
	$Deadline = (Get-Date).AddSeconds(5)
	do {
		$CurrentValue = [string]$PeriodControl.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern).Current.Value
		if ($CurrentValue -eq $Period) { return }
		Start-Sleep -Milliseconds 100
	} while ((Get-Date) -lt $Deadline)
	throw "List period ComboBox did not accept '$Period'; current value is '$CurrentValue'."
}

function Open-ListCommand([System.Windows.Automation.AutomationElement]$Root, [string]$CommandPattern) {
	if ($Process -and $Process.MainWindowHandle -ne [IntPtr]::Zero) {
		[void][FinanceE2EUIInput]::SetForegroundWindow([IntPtr]$Process.MainWindowHandle)
		Start-Sleep -Milliseconds 100
	}
	$Command = $null
	$FindDeadline = (Get-Date).AddSeconds(5)
	do {
		$Command = @(
			Get-UIElements $Root |
			Where-Object { $_.Current.ControlType.ProgrammaticName -eq 'ControlType.MenuItem' -and $_.Current.Name -like $CommandPattern -and -not $_.Current.IsOffscreen } |
			Select-Object -First 1
		)
		if ($Command.Count -eq 0) { Start-Sleep -Milliseconds 150 }
	} while ($Command.Count -eq 0 -and (Get-Date) -lt $FindDeadline)
	if ($Command.Count -eq 0) {
		$VisibleMenuItems = @(
			Get-UIElements $Root |
			Where-Object { $_.Current.ControlType.ProgrammaticName -eq 'ControlType.MenuItem' -and -not $_.Current.IsOffscreen }
		)
		if ($VisibleMenuItems.Count -gt 0) {
			[System.Windows.Forms.SendKeys]::SendWait('{ESC}')
			Start-Sleep -Milliseconds 150
		}
		$Functions = Wait-UIElement $Root 'Functions' 'ControlType.Button'
		if (-not $Functions.Current.IsEnabled) { throw 'Functions command is disabled while opening a document list.' }
		Invoke-UIElement $Functions
		$OpenDeadline = (Get-Date).AddSeconds(8)
		do {
			$Command = @(
				Get-UIElements $Root |
				Where-Object { $_.Current.ControlType.ProgrammaticName -eq 'ControlType.MenuItem' -and $_.Current.Name -like $CommandPattern -and -not $_.Current.IsOffscreen } |
				Select-Object -First 1
			)
			if ($Command.Count -eq 0) { Start-Sleep -Milliseconds 150 }
		} while ($Command.Count -eq 0 -and (Get-Date) -lt $OpenDeadline)
	}
	if ($Command.Count -eq 0) {
		$MenuDiagnostics = @(
			Get-UIElements $Root |
			Where-Object { $_.Current.ControlType.ProgrammaticName -eq 'ControlType.MenuItem' -and -not $_.Current.IsOffscreen } |
			ForEach-Object { $_.Current.Name } |
			Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
			Select-Object -Unique
		)
		throw "Could not expose list command '$CommandPattern' after restoring the 1C window and opening Functions. Visible menu items: $($MenuDiagnostics -join ' | ')."
	}
	Invoke-UIElement $Command[0]
}

$Result = [ordered]@{
	status = 'FAIL'
	user = $User
	infobase = $Infobase
	workflow = $Workflow
		flow = if ($Workflow -eq 'BankSend') { 'native 1C UI → approved payment order → bank submission' } elseif ($Workflow -eq 'RefundConfirm') { 'native 1C UI → approved supplier refund → incoming bank receipt confirmation' } elseif ($Workflow -eq 'ListPeriods') { 'native 1C UI → five document lists → day/month/quarter filters' } elseif ($Workflow -eq 'CatalogSmoke') { 'native 1C UI → nine catalog list forms → visible controls and commands' } elseif ($Workflow -eq 'FormSmoke') { 'native 1C UI → seven document lists, seven document forms, two data processor forms' } elseif ($Workflow -eq 'ReportSmoke') { 'native 1C UI → AR ledger, AP ledger, aging report' } elseif ($Workflow -eq 'GuideSmoke') { 'native 1C UI → finance process guide and allowlisted native destinations' } elseif ($Workflow -eq 'BatchApproval') { 'native 1C UI → dashboard → Maker-Checker batch approval form' } elseif ($Workflow -eq 'PostingCommandDiagnostics') { 'native 1C UI → post and undo posting for netting and reconciliation' } elseif ($Workflow -eq 'ReferenceChoiceDiagnostics') { 'native 1C UI → ' + $ReferenceChoiceDocument + ' partner/contract reference choice diagnostic' } elseif ($Workflow -eq 'ARAutofillSmoke') { 'native 1C UI → create AR invoice → select BBNT → verify autofilled values' } elseif ($Workflow -eq 'RequiredFieldDiagnostics') { 'native 1C UI → blank ' + $RequiredFieldDocument + ' form → Save validation diagnostic' } elseif ($Workflow -eq 'ListFilterDiagnostics') { 'native 1C UI → AR sales invoice list → accessible controls' } else { 'native 1C UI → Functions → AR sales invoice list → sales invoice form' }
	verified = @()
	error = ''
}
$Process = $null
try {
	if (-not (Test-Path -LiteralPath $OneCExe)) { throw "1C executable not found: $OneCExe" }
	if (-not (Test-Path -LiteralPath (Join-Path $Infobase '1Cv8.1CD'))) { throw "Infobase is missing: $Infobase" }
	$ResultDirectory = Split-Path -Parent $ResultPath
	New-Item -ItemType Directory -Path $ResultDirectory -Force | Out-Null
	$OneCLogPath = [System.IO.Path]::ChangeExtension($ResultPath, '.1c.log')
	$Result.onec_log_path = $OneCLogPath
	$Arguments = 'ENTERPRISE /F"' + $Infobase + '" /N' + $User + ' /DisableStartupMessages /Out"' + $OneCLogPath + '"'
	$Process = Start-Process -FilePath $OneCExe -ArgumentList $Arguments -PassThru
	$Deadline = (Get-Date).AddSeconds(45)
	$Root = $null
	do {
		$Process.Refresh()
		if ($Process.MainWindowHandle -ne [IntPtr]::Zero) {
			$Root = [System.Windows.Automation.AutomationElement]::FromHandle([IntPtr]$Process.MainWindowHandle)
			if ($Root.Current.Name -like '*Hệ Thống Tài Chính*') { break }
		}
		Start-Sleep -Milliseconds 300
	} while ((Get-Date) -lt $Deadline -and -not $Process.HasExited)
	if ($null -eq $Root -or $Root.Current.Name -notlike '*Hệ Thống Tài Chính*') { throw '1C managed application window did not open.' }
	[void][FinanceE2EUIInput]::SetForegroundWindow([IntPtr]$Process.MainWindowHandle)
	$Functions = Wait-UIElement $Root 'Functions' 'ControlType.Button'
	Invoke-UIElement $Functions
	if ($Workflow -eq 'CatalogSmoke') {
		$CatalogCases = @(
			@{ Object = 'ChiNhanh'; Synonym = 'Chi nhánh'; Command = '*Chi nhánh*'; Title = '*Chi nhánh*' },
			@{ Object = 'DichVuCNTT'; Synonym = 'Dịch vụ CNTT'; Command = '*Dịch vụ CNTT*'; Title = '*Dịch vụ CNTT*' },
			@{ Object = 'DoiTac'; Synonym = 'Đối tác'; Command = '*Đối tác*'; Title = '*Đối tác*' },
			@{ Object = 'DuAn'; Synonym = 'Dự án'; Command = '*Dự án*'; Title = '*Dự án*' },
			@{ Object = 'HopDong'; Synonym = 'Hợp đồng'; Command = '*Hợp đồng*'; Title = '*Hợp đồng*' },
			@{ Object = 'KhoanMucDongTien'; Synonym = 'Khoản mục dòng tiền'; Command = '*Khoản mục dòng tiền*'; Title = '*Khoản mục dòng tiền*' },
			@{ Object = 'PhapNhan'; Synonym = 'Pháp nhân'; Command = '*Pháp nhân*'; Title = '*Pháp nhân*' },
			@{ Object = 'TaiKhoanTien'; Synonym = 'Tài khoản tiền'; Command = '*Tài khoản tiền*'; Title = '*Tài khoản tiền*' },
			@{ Object = 'TienTe'; Synonym = 'Tiền tệ'; Command = '*Tiền tệ*'; Title = '*Tiền tệ*' }
		)
		$Result.catalog_screens = @()
		[void][FinanceE2EUIInput]::SetForegroundWindow([IntPtr]$Process.MainWindowHandle)
		foreach ($Case in $CatalogCases) {
			Open-ListCommand $Root $Case.Command
			$Pane = Wait-UIElementLike $Root $Case.Title 'ControlType.Pane' 15
			$Audit = Get-FormAudit $Pane $Case.Object $Root
			$CreateButton = $null
			foreach ($Element in (Get-UIElements $Root)) {
				if ($Element.Current.ControlType.ProgrammaticName -eq 'ControlType.Button' -and $Element.Current.Name -eq 'Create' -and -not $Element.Current.IsOffscreen) {
					$CreateButton = $Element
					break
				}
			}
			if ($null -eq $CreateButton -or -not $CreateButton.Current.IsEnabled) {
				throw "Catalog list $($Case.Object) does not expose an enabled Create command."
			}
			Invoke-UIElement $CreateButton
			$CreateFormSave = Wait-UIElement $Root 'Save' 'ControlType.Button' 10
			if ($CreateFormSave.Current.IsOffscreen) { throw "Create did not expose a visible item form for $($Case.Object)." }
			[System.Windows.Forms.SendKeys]::SendWait('^{F4}')
			Start-Sleep -Milliseconds 250
			$CreateButtonReturned = $false
			$ReturnDeadline = (Get-Date).AddSeconds(8)
			do {
				foreach ($Element in (Get-UIElements $Root)) {
					if ($Element.Current.ControlType.ProgrammaticName -eq 'ControlType.Button' -and $Element.Current.Name -eq 'Create' -and -not $Element.Current.IsOffscreen -and $Element.Current.IsEnabled) {
						$CreateButtonReturned = $true
						break
					}
				}
				if (-not $CreateButtonReturned) { Start-Sleep -Milliseconds 250 }
			} while (-not $CreateButtonReturned -and (Get-Date) -lt $ReturnDeadline)
			if (-not $CreateButtonReturned) { throw "Create form did not close back to the catalog list for $($Case.Object)." }
			$RowCandidates = @(Get-UIElements $Root | Where-Object {
				$_.Current.ControlType.ProgrammaticName -in @('ControlType.DataItem', 'ControlType.DataGridRow', 'ControlType.ListItem', 'ControlType.Custom') -and
				-not $_.Current.IsOffscreen -and -not [string]::IsNullOrWhiteSpace($_.Current.Name) -and
				$_.Current.BoundingRectangle.Width -gt 0 -and $_.Current.BoundingRectangle.Height -gt 0
			})
		$CopyFormOpened = $false
		$CopiedRowName = ''
		if ($RowCandidates.Count -gt 0) {
			$CopySourceRow = $RowCandidates[0]
			$CopiedRowName = $CopySourceRow.Current.Name
			Invoke-UIElement $CopySourceRow
			$CopyButton = $null
			foreach ($Element in (Get-UIElements $Root)) {
				if ($Element.Current.ControlType.ProgrammaticName -eq 'ControlType.Button' -and $Element.Current.Name -eq 'Copy' -and -not $Element.Current.IsOffscreen) {
					$CopyButton = $Element
					break
				}
			}
			if ($null -eq $CopyButton -or -not $CopyButton.Current.IsEnabled) {
				throw "Catalog list $($Case.Object) does not expose an enabled Copy command for its selected row."
			}
			Invoke-UIElement $CopyButton
			$CopyFormSave = Wait-UIElement $Root 'Save' 'ControlType.Button' 10
			if ($CopyFormSave.Current.IsOffscreen) { throw "Copy did not expose an item form for $($Case.Object)." }
			[System.Windows.Forms.SendKeys]::SendWait('^{F4}')
			Start-Sleep -Milliseconds 250
			$CopyButtonReturned = $false
			$ReturnDeadline = (Get-Date).AddSeconds(8)
			do {
				foreach ($Element in (Get-UIElements $Root)) {
					if ($Element.Current.ControlType.ProgrammaticName -eq 'ControlType.Button' -and $Element.Current.Name -eq 'Copy' -and -not $Element.Current.IsOffscreen -and $Element.Current.IsEnabled) {
						$CopyButtonReturned = $true
						break
					}
				}
				if (-not $CopyButtonReturned) { Start-Sleep -Milliseconds 250 }
			} while (-not $CopyButtonReturned -and (Get-Date) -lt $ReturnDeadline)
			if (-not $CopyButtonReturned) { throw "Copy form did not close back to the catalog list for $($Case.Object)." }
			$CopyFormOpened = $true
		}
			$Result.catalog_screens += [PSCustomObject]@{
				metadata_object = $Case.Object
				synonym = $Case.Synonym
				screen_title = $Pane.Current.Name
				create_form_opened = $true
				create_form_closed_without_save = $true
				visible_row_candidate_count = $RowCandidates.Count
				copy_source_row = $CopiedRowName
				copy_form_opened = $CopyFormOpened
				copy_form_closed_without_save = $CopyFormOpened
				visible_input_count = $Audit.visible_input_count
				visible_field_names = $Audit.visible_field_names
				visible_button_names = $Audit.visible_button_names
				enabled_button_names = $Audit.enabled_button_names
				disabled_button_names = $Audit.disabled_button_names
			}
			$Result.verified += ($Case.Object + ': opened ' + $Pane.Current.Name)
		}
		if (@($Result.catalog_screens).Count -ne 9) { throw "Expected nine catalog list screens, opened $(@($Result.catalog_screens).Count)." }
		$Result.status = 'PASS'
	}
	elseif ($Workflow -eq 'ReferenceChoiceDiagnostics') {
		$ChoiceDefinition = switch ($ReferenceChoiceDocument) {
			'Acceptance' { @{ command = '*Biên bản nghiệm thu giai đoạn*'; list_title = '*Danh sách Biên bản nghiệm thu giai đoạn*'; partner_label = 'Đối tác:'; partner_code = 'TEST_VG_VINCLUB'; partner_value_pattern = '*VinClub*'; contract_code = 'HD-TEST_VG_VINCLUB-2025' } }
			'ARInvoice' { @{ command = '*Hóa đơn GTGT đầu ra*'; list_title = '*Danh sách Hóa đơn GTGT đầu ra (AR)*'; partner_label = 'Đối tác:'; partner_code = 'TEST_VG_VINCLUB'; partner_value_pattern = '*VinClub*'; contract_code = 'HD-TEST_VG_VINCLUB-2025' } }
			'Receipt' { @{ command = '*Phiếu thu tiền khách hàng*'; list_title = '*Danh sách Phiếu thu tiền khách hàng*'; partner_label = 'Đối tác:'; partner_code = 'TEST_VG_VINCLUB'; partner_value_pattern = '*VinClub*'; contract_code = 'HD-TEST_VG_VINCLUB-2025' } }
			'APInvoice' { @{ command = '*Hóa đơn đầu vào (nhà cung cấp)*'; list_title = '*Danh sách Hóa đơn nhà cung cấp (AP)*'; partner_label = 'Nhà cung cấp:'; partner_code = 'TEST_NCC_AWS'; partner_value_pattern = '*Amazon Web Services*'; contract_code = 'HD-TEST_NCC_AWS-2025' } }
			'Payment' { @{ command = '*Ủy nhiệm chi*'; list_title = '*Danh sách Ủy nhiệm chi*'; partner_label = 'Nhà cung cấp:'; partner_code = 'TEST_NCC_AWS'; partner_value_pattern = '*Amazon Web Services*'; contract_code = 'HD-TEST_NCC_AWS-2025' } }
			default { throw "Unsupported reference choice document '$ReferenceChoiceDocument'." }
		}
		Open-ListCommand $Root $ChoiceDefinition.command
		[void](Wait-UIElementLike $Root $ChoiceDefinition.list_title 'ControlType.Pane' 15)
		$CreateButton = $null
		foreach ($Element in (Get-UIElements $Root)) {
			if ($Element.Current.ControlType.ProgrammaticName -eq 'ControlType.Button' -and $Element.Current.Name -eq 'Create' -and -not $Element.Current.IsOffscreen -and $Element.Current.IsEnabled) {
				$CreateButton = $Element
				break
			}
		}
		if ($null -eq $CreateButton) { throw "$ReferenceChoiceDocument list has no enabled Create command for choice diagnostics." }
		Invoke-UIElement $CreateButton
		$SaveButton = Wait-UIElement $Root 'Save' 'ControlType.Button' 10
		if ($SaveButton.Current.IsOffscreen) { throw "$ReferenceChoiceDocument Create did not open a visible draft form." }
		Start-Sleep -Milliseconds 500
		$Result.visible_input_probe = @(
			Get-UIElements $Root | Where-Object { $_.Current.ControlType.ProgrammaticName -in @('ControlType.Edit', 'ControlType.ComboBox') -and -not $_.Current.IsOffscreen } | ForEach-Object {
				$Value = ''
				try { $Value = [string]$_.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern).Current.Value } catch { }
				[PSCustomObject]@{ name = $_.Current.Name; automation_id = $_.Current.AutomationId; control_type = $_.Current.ControlType.ProgrammaticName; value = $Value; enabled = $_.Current.IsEnabled }
			}
		)
		$PartnerControl = $null
		$ContractControl = $null
		foreach ($Element in (Get-UIElements $Root)) {
			if ($Element.Current.ControlType.ProgrammaticName -notin @('ControlType.Edit', 'ControlType.ComboBox') -or $Element.Current.IsOffscreen) { continue }
			if ($Element.Current.Name -eq $ChoiceDefinition.partner_label) { $PartnerControl = $Element }
			if ($Element.Current.Name -eq 'Hợp đồng:') { $ContractControl = $Element }
		}
		if ($null -eq $PartnerControl -or $null -eq $ContractControl) { throw "Partner/contract controls were not exposed to UI Automation. Visible input names: $(@($Result.visible_input_probe | ForEach-Object { $_.name }) -join ' | ')" }
		$PartnerValue = [string]$PartnerControl.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern).Current.Value
		$ContractValue = [string]$ContractControl.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern).Current.Value
		$PartnerRect = $PartnerControl.Current.BoundingRectangle
		$BeforePanes = @(Get-UIElements $Root | Where-Object { $_.Current.ControlType.ProgrammaticName -in @('ControlType.Pane', 'ControlType.Window') -and -not $_.Current.IsOffscreen } | ForEach-Object { $_.Current.Name } | Where-Object { $_ })
		$PartnerControl.SetFocus()
		[System.Windows.Forms.SendKeys]::SendWait('{F4}')
		Start-Sleep -Milliseconds 1500
		$PartnerChoicePanes = @(Get-UIElements $Root | Where-Object { $_.Current.ControlType.ProgrammaticName -in @('ControlType.Pane', 'ControlType.Window') -and -not $_.Current.IsOffscreen } | ForEach-Object { $_.Current.Name } | Where-Object { $_ })
		$PartnerChoiceCandidates = @(
			Get-UIElements $Root | Where-Object {
				$_.Current.ControlType.ProgrammaticName -in @('ControlType.DataItem', 'ControlType.DataGridRow', 'ControlType.ListItem', 'ControlType.Custom') -and
				-not $_.Current.IsOffscreen -and -not [string]::IsNullOrWhiteSpace($_.Current.Name) -and
				$_.Current.BoundingRectangle.Width -gt 0 -and $_.Current.BoundingRectangle.Height -gt 0
			} | ForEach-Object {
				[PSCustomObject]@{ name = $_.Current.Name; control_type = $_.Current.ControlType.ProgrammaticName }
			}
		)
		$PartnerChoiceOpened = (@($PartnerChoicePanes | Where-Object { $BeforePanes -notcontains $_ }).Count -gt 0 -or $PartnerChoiceCandidates.Count -gt 0)
		if (-not $PartnerChoiceOpened -and $PartnerRect.Width -gt 0) {
			[void][FinanceE2EUIInput]::SetCursorPos([int]($PartnerRect.X + $PartnerRect.Width - 6), [int]($PartnerRect.Y + ($PartnerRect.Height / 2)))
			[FinanceE2EUIInput]::mouse_event(2, 0, 0, 0, [UIntPtr]::Zero)
			[FinanceE2EUIInput]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero)
			Start-Sleep -Milliseconds 1000
			$PartnerChoicePanes = @(Get-UIElements $Root | Where-Object { $_.Current.ControlType.ProgrammaticName -in @('ControlType.Pane', 'ControlType.Window') -and -not $_.Current.IsOffscreen } | ForEach-Object { $_.Current.Name } | Where-Object { $_ })
			$PartnerChoiceCandidates = @(Get-UIElements $Root | Where-Object { $_.Current.ControlType.ProgrammaticName -in @('ControlType.DataItem', 'ControlType.DataGridRow', 'ControlType.ListItem', 'ControlType.Custom') -and -not $_.Current.IsOffscreen -and -not [string]::IsNullOrWhiteSpace($_.Current.Name) -and $_.Current.BoundingRectangle.Width -gt 0 -and $_.Current.BoundingRectangle.Height -gt 0 } | ForEach-Object { [PSCustomObject]@{ name = $_.Current.Name; control_type = $_.Current.ControlType.ProgrammaticName } })
			$PartnerChoiceOpened = (@($PartnerChoicePanes | Where-Object { $BeforePanes -notcontains $_ }).Count -gt 0 -or $PartnerChoiceCandidates.Count -gt 0)
		}
		$Result.partner_field_before = $PartnerValue
		$Result.contract_field_before = $ContractValue
		$Result.visible_panes_before_choice = $BeforePanes
		$Result.visible_panes_after_partner_choice = $PartnerChoicePanes
		$Result.partner_choice_candidates = $PartnerChoiceCandidates
		$Result.partner_choice_open_detected = $PartnerChoiceOpened
		$ExpectedPartnerCode = $ChoiceDefinition.partner_code
		$PartnerCodeElement = $null
		foreach ($Element in (Get-UIElements $Root)) {
			if ($Element.Current.ControlType.ProgrammaticName -in @('ControlType.DataItem', 'ControlType.DataGridRow', 'ControlType.ListItem', 'ControlType.Custom') -and
				$Element.Current.Name -eq ($ExpectedPartnerCode + ' Code') -and -not $Element.Current.IsOffscreen) {
				$PartnerCodeElement = $Element
				break
			}
		}
		if (-not $PartnerChoiceOpened -or $null -eq $PartnerCodeElement) {
			$Result.status = 'FAIL'
			throw "$ReferenceChoiceDocument partner choice did not expose the expected $ExpectedPartnerCode row."
		}
		Invoke-UIElement $PartnerCodeElement
		[System.Windows.Forms.SendKeys]::SendWait('{ENTER}')
		Start-Sleep -Milliseconds 750
		$PartnerControl = $null
		$ContractControl = $null
		foreach ($Element in (Get-UIElements $Root)) {
			if ($Element.Current.ControlType.ProgrammaticName -notin @('ControlType.Edit', 'ControlType.ComboBox') -or $Element.Current.IsOffscreen) { continue }
			if ($Element.Current.Name -eq $ChoiceDefinition.partner_label) { $PartnerControl = $Element }
			if ($Element.Current.Name -eq 'Hợp đồng:') { $ContractControl = $Element }
		}
		if ($null -eq $PartnerControl -or $null -eq $ContractControl) { throw 'Partner/contract controls disappeared after choosing a partner.' }
		$SelectedPartnerValue = [string]$PartnerControl.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern).Current.Value
		if ($SelectedPartnerValue -notlike $ChoiceDefinition.partner_value_pattern) { throw "$ReferenceChoiceDocument selected partner value is unexpected: $SelectedPartnerValue" }
		$ContractPanesBefore = @(Get-UIElements $Root | Where-Object { $_.Current.ControlType.ProgrammaticName -in @('ControlType.Pane', 'ControlType.Window') -and -not $_.Current.IsOffscreen } | ForEach-Object { $_.Current.Name } | Where-Object { $_ })
		$ContractControl.SetFocus()
		[System.Windows.Forms.SendKeys]::SendWait('{F4}')
		Start-Sleep -Milliseconds 1500
		$ContractChoicePanes = @(Get-UIElements $Root | Where-Object { $_.Current.ControlType.ProgrammaticName -in @('ControlType.Pane', 'ControlType.Window') -and -not $_.Current.IsOffscreen } | ForEach-Object { $_.Current.Name } | Where-Object { $_ })
		$ContractChoiceCandidates = @(
			Get-UIElements $Root | Where-Object {
				$_.Current.ControlType.ProgrammaticName -in @('ControlType.DataItem', 'ControlType.DataGridRow', 'ControlType.ListItem', 'ControlType.Custom') -and
				-not $_.Current.IsOffscreen -and -not [string]::IsNullOrWhiteSpace($_.Current.Name) -and
				$_.Current.BoundingRectangle.Width -gt 0 -and $_.Current.BoundingRectangle.Height -gt 0
			} | ForEach-Object {
				[PSCustomObject]@{ name = $_.Current.Name; control_type = $_.Current.ControlType.ProgrammaticName }
			}
		)
		$ContractCodeRows = @($ContractChoiceCandidates | Where-Object { $_.name -match '^HD-' -and $_.name -like '* Code' })
		$ExpectedContractName = $ChoiceDefinition.contract_code + ' Code'
		$ExpectedContractVisible = @($ContractCodeRows | Where-Object { $_.name -eq $ExpectedContractName }).Count -eq 1
		$UnexpectedContractCodes = @($ContractCodeRows | Where-Object { $_.name -ne $ExpectedContractName })
		$Result.reference_choice_document = $ReferenceChoiceDocument
		$Result.expected_partner_code = $ExpectedPartnerCode
		$Result.expected_contract_code = $ChoiceDefinition.contract_code
		$Result.selected_partner = $SelectedPartnerValue
		$Result.contract_choice_panes = $ContractChoicePanes
		$Result.contract_choice_candidates = $ContractChoiceCandidates
		$Result.expected_contract_visible = $ExpectedContractVisible
		$Result.unexpected_contract_code_count = $UnexpectedContractCodes.Count
		$Result.contract_choice_open_detected = (@($ContractChoicePanes | Where-Object { $ContractPanesBefore -notcontains $_ }).Count -gt 0 -or $ContractChoiceCandidates.Count -gt 0)
		$Result.choice_open_detected = $Result.contract_choice_open_detected
		[System.Windows.Forms.SendKeys]::SendWait('{ESC}')
		if (-not $Result.contract_choice_open_detected -or -not $ExpectedContractVisible -or $UnexpectedContractCodes.Count -gt 0) {
			$Result.status = 'FAIL'
			throw "$ReferenceChoiceDocument contract choice filter mismatch for $ExpectedPartnerCode; expected $($ChoiceDefinition.contract_code) visible=$ExpectedContractVisible; unexpected contract rows=$($UnexpectedContractCodes.Count)."
		}
		Start-Sleep -Milliseconds 300
		$Result.status = 'PASS'
		$Result.verified += "$ReferenceChoiceDocument partner choice opened; $ExpectedPartnerCode selected; contract choice showed only $($ChoiceDefinition.contract_code); draft closed without saving"
	}
	elseif ($Workflow -eq 'ARAutofillSmoke') {
		Open-ListCommand $Root '*Hóa đơn GTGT đầu ra*'
		[void](Wait-UIElementLike $Root '*Danh sách Hóa đơn GTGT đầu ra (AR)*' 'ControlType.Pane' 15)
		$CreateButton = $null
		foreach ($Element in (Get-UIElements $Root)) {
			if ($Element.Current.ControlType.ProgrammaticName -eq 'ControlType.Button' -and $Element.Current.Name -eq 'Create' -and -not $Element.Current.IsOffscreen -and $Element.Current.IsEnabled) {
				$CreateButton = $Element
				break
			}
		}
		if ($null -eq $CreateButton) { throw 'AR invoice list has no enabled Create command for autofill diagnostics.' }
		Invoke-UIElement $CreateButton
		$Form = Wait-UIElementLike $Root '*Hóa đơn GTGT đầu ra (AR) - VinSmart Future*' 'ControlType.Pane' 15
		$SaveButton = Wait-UIElement $Root 'Save' 'ControlType.Button' 10
		if ($SaveButton.Current.IsOffscreen) { throw 'AR invoice Create did not open a visible draft form.' }
		$SourceControl = $null
		foreach ($Element in (Get-UIElements $Root)) {
			if ($Element.Current.ControlType.ProgrammaticName -in @('ControlType.Edit', 'ControlType.ComboBox') -and -not $Element.Current.IsOffscreen -and $Element.Current.Name -eq 'Biên bản nghiệm thu:') {
				$SourceControl = $Element
				break
			}
		}
		if ($null -eq $SourceControl) { throw 'AR invoice Create form did not expose the Biên bản nghiệm thu lookup.' }
		$BeforePanes = @(Get-UIElements $Root | Where-Object { $_.Current.ControlType.ProgrammaticName -in @('ControlType.Pane', 'ControlType.Window') -and -not $_.Current.IsOffscreen } | ForEach-Object { $_.Current.Name } | Where-Object { $_ })
		$SourceControl.SetFocus()
		[System.Windows.Forms.SendKeys]::SendWait('{F4}')
		Start-Sleep -Milliseconds 1500
		$ChoiceElements = @(Get-UIElements $Root | Where-Object {
			$_.Current.ControlType.ProgrammaticName -in @('ControlType.DataItem', 'ControlType.DataGridRow', 'ControlType.ListItem', 'ControlType.Custom') -and
			-not $_.Current.IsOffscreen -and -not [string]::IsNullOrWhiteSpace($_.Current.Name) -and
			$_.Current.BoundingRectangle.Width -gt 0 -and $_.Current.BoundingRectangle.Height -gt 0
		})
		$ChoiceRows = @($ChoiceElements | ForEach-Object { [PSCustomObject]@{ name = $_.Current.Name; control_type = $_.Current.ControlType.ProgrammaticName } })
		$Result.visible_panes_before_choice = $BeforePanes
		$Result.acceptance_choice_candidates = $ChoiceRows
		$AcceptanceRow = @($ChoiceElements | Where-Object { $_.Current.Name -like '*E2E-BB001*' } | Select-Object -First 1)
		if ($AcceptanceRow.Count -ne 1) { throw "BBNT lookup did not expose a unique E2E-BB001 row. Candidate rows: $($ChoiceRows.name -join ' | ')" }
		Invoke-UIElement $AcceptanceRow[0]
		[System.Windows.Forms.SendKeys]::SendWait('{ENTER}')
		Start-Sleep -Milliseconds 1000
		$Values = @{}
		foreach ($Element in (Get-UIElements $Root)) {
			if ($Element.Current.ControlType.ProgrammaticName -notin @('ControlType.Edit', 'ControlType.ComboBox') -or $Element.Current.IsOffscreen) { continue }
			try { $Value = [string]$Element.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern).Current.Value } catch { continue }
			if ($Element.Current.Name) { $Values[$Element.Current.Name] = $Value }
		}
		$Result.autofill_values = $Values
		$ExpectedFields = @{
			'Pháp nhân:' = '*VinSmart Future*'
			'Đối tác:' = '*VinFast*'
			'Hợp đồng:' = '*2025*VinFast*'
			'Biên bản nghiệm thu:' = '*E2E-BB001*'
			'Thành tiền chưa thuế:' = '200,000,000.00'
			'Thuế suất GTGT (%):' = '10*'
			'Tiền thuế GTGT:' = '20,000,000.00'
			'Tổng tiền thanh toán:' = '220,000,000.00'
		}
		$Mismatches = @(
			foreach ($Field in $ExpectedFields.Keys) {
				$Actual = [string]$Values[$Field]
				if ($Field -eq 'Thuế suất GTGT (%):') {
					if ($Actual -notlike $ExpectedFields[$Field]) { "$Field expected 10%, actual '$Actual'" }
				} elseif ($Actual -notlike $ExpectedFields[$Field]) {
					"$Field expected '$($ExpectedFields[$Field])', actual '$Actual'"
				}
			}
		)
		if ($Mismatches.Count -gt 0) { throw "BBNT autofill mismatch: $($Mismatches -join '; ')" }
		$ScreenBounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
		$Screenshot = [System.IO.Path]::ChangeExtension($ResultPath, '.png')
		$Bitmap = New-Object System.Drawing.Bitmap($ScreenBounds.Width, $ScreenBounds.Height)
		$Graphics = [System.Drawing.Graphics]::FromImage($Bitmap)
		$Graphics.CopyFromScreen($ScreenBounds.Left, $ScreenBounds.Top, 0, 0, $ScreenBounds.Size)
		$Bitmap.Save($Screenshot, [System.Drawing.Imaging.ImageFormat]::Png)
		$Graphics.Dispose()
		$Bitmap.Dispose()
		$Result.screenshot_path = $Screenshot
		$Result.status = 'PASS'
		$Result.verified += @('Created AR invoice draft from native list', 'selected E2E-BB001 through the lookup', 'BBNT OnChange autofilled legal entity, VinFast partner, contract, 200m net, 10% VAT, 20m VAT and 220m gross', 'draft was not saved')
	}
	elseif ($Workflow -eq 'RequiredFieldDiagnostics') {
		$RequiredFieldCases = @{
			Acceptance = @{ Command = '*Biên bản nghiệm thu giai đoạn*'; ListTitle = '*Danh sách Biên bản nghiệm thu giai đoạn*'; FormTitle = '*Biên bản nghiệm thu giai đoạn (AR) - VinSmart Future*' }
			ARInvoice = @{ Command = '*Hóa đơn GTGT đầu ra*'; ListTitle = '*Danh sách Hóa đơn GTGT đầu ra (AR)*'; FormTitle = '*Hóa đơn GTGT đầu ra (AR) - VinSmart Future*' }
			Receipt = @{ Command = '*Phiếu thu tiền khách hàng*'; ListTitle = '*Danh sách Phiếu thu tiền khách hàng*'; FormTitle = '*Phiếu thu tiền khách hàng (AR) - VinSmart Future*' }
			APInvoice = @{ Command = '*Hóa đơn đầu vào (nhà cung cấp)*'; ListTitle = '*Danh sách Hóa đơn nhà cung cấp (AP)*'; FormTitle = '*Hóa đơn nhà cung cấp (AP) - VinSmart Future*' }
			Payment = @{ Command = '*Ủy nhiệm chi*'; ListTitle = '*Danh sách Ủy nhiệm chi*'; FormTitle = '*Ủy nhiệm chi ngân hàng (AP) - VinSmart Future*' }
			Netting = @{ Command = '*Cấn trừ công nợ nội bộ*'; ListTitle = '*Cấn trừ công nợ nội bộ*'; FormTitle = '*Cấn trừ công nợ nội bộ*' }
			Reconciliation = @{ Command = '*Bảng kê đối soát kênh thanh toán*'; ListTitle = '*Bảng kê đối soát kênh thanh toán*'; FormTitle = '*Bảng kê đối soát kênh thanh toán*' }
		}
		$RequiredFieldCase = $RequiredFieldCases[$RequiredFieldDocument]
		$Result.document_type = $RequiredFieldDocument
		Open-ListCommand $Root $RequiredFieldCase.Command
		[void](Wait-UIElementLike $Root $RequiredFieldCase.ListTitle 'ControlType.Pane' 15)
		$CreateButton = $null
		foreach ($Element in (Get-UIElements $Root)) {
			if ($Element.Current.ControlType.ProgrammaticName -eq 'ControlType.Button' -and $Element.Current.Name -eq 'Create' -and -not $Element.Current.IsOffscreen -and $Element.Current.IsEnabled) {
				$CreateButton = $Element
				break
			}
		}
		if ($null -eq $CreateButton) { throw 'Acceptance list has no enabled Create command.' }
		Invoke-UIElement $CreateButton
		$Form = Wait-UIElementLike $Root $RequiredFieldCase.FormTitle 'ControlType.Pane' 15
		$FormSaveCandidates = @(Get-FormActionButtonCandidates $Root $Form 'Save' | Where-Object enabled)
		if ($FormSaveCandidates.Count -ne 1) { throw "$RequiredFieldDocument Create form has no unique enabled Save command in its form action bar." }
		$SaveButton = $FormSaveCandidates[0].element
		Start-Sleep -Milliseconds 500
		$SaveButtonRect = $SaveButton.Current.BoundingRectangle
		$Result.save_button_diagnostic = [PSCustomObject]@{
			bounds = @($SaveButtonRect.X, $SaveButtonRect.Y, $SaveButtonRect.Width, $SaveButtonRect.Height)
			enabled = $SaveButton.Current.IsEnabled
			automation_id = $SaveButton.Current.AutomationId
			locator = $script:FormActionButtonDiagnostic
		}
		$ReadValues = {
			@(
				Get-UIElements $Root | Where-Object { $_.Current.ControlType.ProgrammaticName -in @('ControlType.Edit', 'ControlType.ComboBox', 'ControlType.CheckBox') -and -not $_.Current.IsOffscreen } | ForEach-Object {
					$Value = ''
					try { $Value = [string]$_.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern).Current.Value } catch { }
					[PSCustomObject]@{ name = $_.Current.Name; control_type = $_.Current.ControlType.ProgrammaticName; value = $Value; enabled = $_.Current.IsEnabled }
				}
			)
		}
		$BeforeValues = & $ReadValues
		$Result.empty_save_before = $BeforeValues
		$NumberBefore = [string](@($BeforeValues | Where-Object name -eq 'Number:' | Select-Object -First 1).value)
		Invoke-UIElement $SaveButton
		Start-Sleep -Milliseconds 1500
		$AfterValues = & $ReadValues
		$Result.empty_save_after = $AfterValues
		$NumberAfter = [string](@($AfterValues | Where-Object name -eq 'Number:' | Select-Object -First 1).value)
		$Result.document_number_before = $NumberBefore.Trim()
		$Result.document_number_after = $NumberAfter.Trim()
		$MessageSearchRoots = @($Root, [System.Windows.Automation.AutomationElement]::RootElement)
		$Result.validation_message_visible = $false
		$Result.validation_message_text = ''
		$Result.success_notification_visible = $false
		$ValidationMessageDeadline = (Get-Date).AddSeconds(4)
		$ValidationPattern = 'Thiếu thông tin bắt buộc|Required information is missing|Mandatory attributes missing|Failed to save|must be greater than|phải lớn hơn|không hợp lệ|không thuộc|bắt buộc'
		do {
			$VisibleTextCandidates = @(
				foreach ($SearchRoot in $MessageSearchRoots) {
					Get-UIElements $SearchRoot | Where-Object { -not $_.Current.IsOffscreen } | ForEach-Object {
						$Text = [string]$_.Current.Name
						$Value = ''
						$HelpText = ''
						try { $Value = [string]$_.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern).Current.Value } catch { }
						try { $HelpText = [string]$_.Current.HelpText } catch { }
						$Combined = ($Text + ' ' + $Value + ' ' + $HelpText).Trim()
						if ($Combined -match $ValidationPattern) { $Combined }
						if ($Combined -match 'Lưu .* thành công|saved successfully|đã được ghi nhận') { $Result.success_notification_visible = $true }
					}
				}
			)
			if ($VisibleTextCandidates.Count -gt 0) {
				$Result.validation_message_visible = $true
				$Result.validation_message_text = (@($VisibleTextCandidates | Select-Object -Unique) -join ' | ')
			} elseif (-not $Result.success_notification_visible) { Start-Sleep -Milliseconds 250 }
		} while (-not $Result.validation_message_visible -and -not $Result.success_notification_visible -and (Get-Date) -lt $ValidationMessageDeadline)
		$Result.visible_message_controls = @(
			foreach ($SearchRoot in $MessageSearchRoots) {
				Get-UIElements $SearchRoot | Where-Object { $_.Current.ControlType.ProgrammaticName -in @('ControlType.Text', 'ControlType.StatusBar', 'ControlType.Window', 'ControlType.ListItem') -and -not $_.Current.IsOffscreen -and -not [string]::IsNullOrWhiteSpace($_.Current.Name) } | ForEach-Object { [PSCustomObject]@{ name = $_.Current.Name; control_type = $_.Current.ControlType.ProgrammaticName } }
			}
		)
		$Result.save_button_still_visible = @(
			Get-UIElements $Root | Where-Object { $_.Current.ControlType.ProgrammaticName -eq 'ControlType.Button' -and $_.Current.Name -eq 'Save' -and -not $_.Current.IsOffscreen }
		).Count -gt 0
		$Result.document_persisted = (-not [string]::IsNullOrWhiteSpace($Result.document_number_after)) -or $Result.success_notification_visible
		$Result.blank_save_rejected = [string]::IsNullOrWhiteSpace([string]$Result.document_number_before) -and
			[string]::IsNullOrWhiteSpace([string]$Result.document_number_after) -and -not $Result.document_persisted
		if ($Result.blank_save_rejected -and $Result.validation_message_visible -and $Result.save_button_still_visible) {
			$Result.status = 'PASS'
			$Result.verified += ('blank ' + $RequiredFieldDocument + ' Save rejected, no number assigned, validation message visible; clone only')
		} else {
			$Result.status = 'FAIL'
			$Result.error = 'Blank ' + $RequiredFieldDocument + ' Save did not satisfy the required-field validation contract.'
		}
	}
	elseif ($Workflow -eq 'ListPeriods') {
		$ListCases = @(
			@{ Command = '*Biên bản nghiệm thu giai đoạn*'; Title = '*Danh sách Biên bản nghiệm thu giai đoạn*'; Number = 'E2E-BB001' },
			@{ Command = '*Hóa đơn GTGT đầu ra*'; Title = '*Danh sách Hóa đơn GTGT đầu ra (AR)*'; Number = 'E2E-AR001' },
			@{ Command = '*Phiếu thu tiền khách hàng*'; Title = '*Danh sách Phiếu thu tiền khách hàng*'; Number = 'E2E-PT001' },
			@{ Command = '*Hóa đơn đầu vào (nhà cung cấp)*'; Title = '*Danh sách Hóa đơn nhà cung cấp (AP)*'; Number = 'E2E-AP001' },
			@{ Command = '*Ủy nhiệm chi*'; Title = '*Danh sách Ủy nhiệm chi*'; Number = 'E2E-UNC01' }
		)
		[void][FinanceE2EUIInput]::SetForegroundWindow([IntPtr]$Process.MainWindowHandle)
		foreach ($Case in $ListCases) {
			Open-ListCommand $Root $Case.Command
			[void](Wait-UIElementLike $Root $Case.Title 'ControlType.Pane')
			foreach ($FilterCase in @(
				@{ Period = 'HomNay'; Visible = $false },
				@{ Period = 'ThangNay'; Visible = $true },
				@{ Period = 'QuyNay'; Visible = $true },
				@{ Period = 'TatCa'; Visible = $true }
			)) {
				Set-PeriodFilter $Root $FilterCase.Period
				Wait-ListRowState $Root $Case.Number $FilterCase.Visible
			}
			$Result.verified += ($Case.Number + ': HomNay excludes; ThangNay, QuyNay, and TatCa include the October document')
		}
		$Result.status = 'PASS'
	}
	elseif ($Workflow -eq 'PostingCommandDiagnostics') {
		$PostingCommandCases = @(
			@{ Command = '*Cấn trừ công nợ nội bộ*'; ListTitle = '*Cấn trừ công nợ nội bộ*'; Number = 'E2E-NET-001'; FormTitle = '*Cấn trừ công nợ nội bộ*' },
			@{ Command = '*Bảng kê đối soát kênh thanh toán*'; ListTitle = '*Bảng kê đối soát kênh thanh toán*'; Number = 'E2E-BK-VNPAY-001'; FormTitle = '*Bảng kê đối soát kênh thanh toán*' }
		)
		$Result.posting_command_actions = @()
		[void][FinanceE2EUIInput]::SetForegroundWindow([IntPtr]$Process.MainWindowHandle)
		foreach ($Case in $PostingCommandCases) {
			Open-ListCommand $Root $Case.Command
			[void](Wait-UIElementLike $Root $Case.ListTitle 'ControlType.Pane')
			$Row = Find-ListRow $Root $Case.Number
			if ($null -eq $Row) {
				$VisibleRows = @(Get-UIElements $Root | Where-Object { -not $_.Current.IsOffscreen -and $_.Current.ControlType.ProgrammaticName -eq 'ControlType.Custom' -and $_.Current.Name } | ForEach-Object { $_.Current.Name } | Select-Object -Unique)
				$ListControls = @(Get-UIElements $Root | Where-Object { -not $_.Current.IsOffscreen -and $_.Current.ControlType.ProgrammaticName -in @('ControlType.Button', 'ControlType.ComboBox', 'ControlType.Edit') -and $_.Current.Name } | ForEach-Object { $_.Current.Name + ' [' + $_.Current.ControlType.ProgrammaticName + ']' } | Select-Object -Unique)
				throw "Posting-command fixture $($Case.Number) is missing from its list. Visible rows: $($VisibleRows -join ' | '); list controls: $($ListControls -join ' | ')."
			}
			$RowRect = $Row.Current.BoundingRectangle
			if ($RowRect.IsEmpty -or $RowRect.Width -le 0 -or $RowRect.Height -le 0) { throw "Posting-command fixture has no visible row bounds: $($Case.Number)." }
			$RowX = [int]($RowRect.X + ($RowRect.Width / 2))
			$RowY = [int]($RowRect.Y + ($RowRect.Height / 2))
			[void][FinanceE2EUIInput]::SetCursorPos($RowX, $RowY)
			[FinanceE2EUIInput]::mouse_event(2, 0, 0, 0, [UIntPtr]::Zero)
			[FinanceE2EUIInput]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero)
			Start-Sleep -Milliseconds 100
			[FinanceE2EUIInput]::mouse_event(2, 0, 0, 0, [UIntPtr]::Zero)
			[FinanceE2EUIInput]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero)
			try {
				$Form = Wait-UIElementLike $Root $Case.FormTitle 'ControlType.Pane'
				$FormSave = @(
					Get-UIElements $Root |
					Where-Object { $_.Current.ControlType.ProgrammaticName -eq 'ControlType.Button' -and $_.Current.Name -eq 'Save' -and -not $_.Current.IsOffscreen } |
					Select-Object -First 1
				)
				$DocumentNumberVisible = $false
				foreach ($Element in (Get-UIElements $Root)) {
					if ($Element.Current.IsOffscreen) { continue }
					$ElementText = [string]$Element.Current.Name
					try { $ElementText += ' ' + [string]$Element.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern).Current.Value } catch { }
					if ($ElementText.Contains($Case.Number)) { $DocumentNumberVisible = $true; break }
				}
				if ($FormSave.Count -eq 0 -or -not $DocumentNumberVisible) {
					$VisibleControls = @()
					foreach ($VisibleElement in (Get-UIElements $Root | Where-Object { -not $_.Current.IsOffscreen -and $_.Current.Name })) {
						$Value = ''
						try { $Value = [string]$VisibleElement.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern).Current.Value } catch { }
						$Rect = $VisibleElement.Current.BoundingRectangle
						$VisibleControls += [PSCustomObject]@{ name = $VisibleElement.Current.Name; type = $VisibleElement.Current.ControlType.ProgrammaticName; value = $Value; bounds = @($Rect.X, $Rect.Y, $Rect.Width, $Rect.Height) }
					}
					throw "Fixture $($Case.Number) did not open a document form (Save=$($FormSave.Count), document_number_visible=$DocumentNumberVisible). Visible controls: $(ConvertTo-Json -InputObject $VisibleControls -Compress -Depth 4)"
				}
			} catch {
				if ($_.Exception.Message -like 'Fixture * did not open a document form*') { throw }
				$PaneNames = @(Get-UIElements $Root | Where-Object { -not $_.Current.IsOffscreen -and $_.Current.ControlType.ProgrammaticName -eq 'ControlType.Pane' -and $_.Current.Name } | ForEach-Object { $_.Current.Name } | Select-Object -Unique)
				throw "Could not verify document form for $($Case.Number): $($_.Exception.Message). Visible panes: $($PaneNames -join ' | ')"
			}
			$UndoPattern = '(?i)(undo|unpost|cancel posting|hủy ghi sổ|huy ghi so|bỏ ghi sổ|bo ghi so)'
			$MoreActions = @(
				Get-UIElements $Root |
				Where-Object { $_.Current.ControlType.ProgrammaticName -eq 'ControlType.Button' -and $_.Current.Name -eq 'More actions' -and -not $_.Current.IsOffscreen -and $_.Current.IsEnabled } |
				Select-Object -First 1
			)
			if ($MoreActions.Count -eq 0) { throw "Fixture $($Case.Number) has no enabled More actions command." }
			Invoke-UIElement $MoreActions[0]
			Start-Sleep -Milliseconds 350
			$UndoBeforePost = @(
				Get-UIElements $Root |
				Where-Object { $_.Current.ControlType.ProgrammaticName -in @('ControlType.Button', 'ControlType.MenuItem') -and -not $_.Current.IsOffscreen -and $_.Current.IsEnabled -and $_.Current.Name -match $UndoPattern }
			)
			if ($UndoBeforePost.Count -eq 0) {
				$VisibleCommands = @(Get-UIElements $Root | Where-Object { -not $_.Current.IsOffscreen -and $_.Current.ControlType.ProgrammaticName -in @('ControlType.Button', 'ControlType.MenuItem', 'ControlType.Text') -and $_.Current.Name } | ForEach-Object { $_.Current.Name } | Select-Object -Unique)
				throw "Fixture $($Case.Number) was expected to be posted, but no enabled undo-posting command is available. Visible controls: $($VisibleCommands -join ' | ')"
			}
			$UndoCommandName = $UndoBeforePost[0].Current.Name
			Invoke-UIElement $UndoBeforePost[0]
			Start-Sleep -Milliseconds 900
			$PostButtonAfterUndo = @(
				Get-UIElements $Root |
				Where-Object { $_.Current.ControlType.ProgrammaticName -eq 'ControlType.Button' -and $_.Current.Name -eq 'Post' -and -not $_.Current.IsOffscreen -and $_.Current.IsEnabled }
			)
			if ($PostButtonAfterUndo.Count -eq 0) {
				$VisibleCommands = @(Get-UIElements $Root | Where-Object { -not $_.Current.IsOffscreen -and $_.Current.ControlType.ProgrammaticName -in @('ControlType.Button', 'ControlType.MenuItem', 'ControlType.Text') -and $_.Current.Name } | ForEach-Object { $_.Current.Name } | Select-Object -Unique)
				throw "Undo command $UndoCommandName did not enable Post for $($Case.Number). Visible controls: $($VisibleCommands -join ' | ')"
			}
			Invoke-UIElement $PostButtonAfterUndo[0]
			Start-Sleep -Milliseconds 900
			$MoreActionsAfterPost = @(
				Get-UIElements $Root |
				Where-Object { $_.Current.ControlType.ProgrammaticName -eq 'ControlType.Button' -and $_.Current.Name -eq 'More actions' -and -not $_.Current.IsOffscreen -and $_.Current.IsEnabled } |
				Select-Object -First 1
			)
			if ($MoreActionsAfterPost.Count -eq 0) { throw "More actions disappeared after reposting $($Case.Number)." }
			Invoke-UIElement $MoreActionsAfterPost[0]
			Start-Sleep -Milliseconds 350
			$UndoAfterPost = @(
				Get-UIElements $Root |
				Where-Object { $_.Current.ControlType.ProgrammaticName -in @('ControlType.Button', 'ControlType.MenuItem') -and -not $_.Current.IsOffscreen -and $_.Current.IsEnabled -and $_.Current.Name -match $UndoPattern }
			)
			if ($UndoAfterPost.Count -eq 0) { throw "Repost did not restore an enabled undo-posting command for $($Case.Number)." }
			[System.Windows.Forms.SendKeys]::SendWait('{ESC}')
			$Result.posting_command_actions += [PSCustomObject]@{
				document_number = $Case.Number
				initial_state = 'posted'
				undo_command = $UndoCommandName
				undo_invoked = $true
				post_invoked_after_undo = $true
				undo_available_after_repost = $true
				final_state = 'posted'
			}
			$Result.verified += ($Case.Number + ': ' + $UndoCommandName + ' and Post invoked; final state posted')
			[System.Windows.Forms.SendKeys]::SendWait('^{F4}')
			Start-Sleep -Milliseconds 250
		}
		$Result.status = 'PASS'
	}
	elseif ($Workflow -eq 'ReportSmoke') {
		$ReportCases = @(
			@{ Name = 'SoChiTietCongNoAR'; Command = '*Sổ chi tiết công nợ phải thu*'; Title = '*Sổ chi tiết công nợ phải thu*' },
			@{ Name = 'SoChiTietCongNoAP'; Command = '*Sổ chi tiết công nợ phải trả*'; Title = '*Sổ chi tiết công nợ phải trả*' },
			@{ Name = 'BaoCaoTuoiNo'; Command = '*Báo cáo tuổi nợ*'; Title = '*Báo cáo tuổi nợ*' }
		)
		if ($ReportOnly -ne 'All') { $ReportCases = @($ReportCases | Where-Object { $_.Name -eq $ReportOnly }) }
		if ($ReportCases.Count -eq 0) { throw "No report case matches ReportOnly='$ReportOnly'." }
		$Result.report_audit = @()
		[void][FinanceE2EUIInput]::SetForegroundWindow([IntPtr]$Process.MainWindowHandle)
		foreach ($Case in $ReportCases) {
			Open-ListCommand $Root $Case.Command
			$ReportPane = $null
			$Deadline = (Get-Date).AddSeconds(20)
			do {
				$ReportPane = @(
					Get-UIElements $Root |
					Where-Object { $_.Current.ControlType.ProgrammaticName -eq 'ControlType.Pane' -and -not $_.Current.IsOffscreen -and $_.Current.Name -like $Case.Title } |
					Select-Object -First 1
				)
				if ($ReportPane.Count -eq 0) { Start-Sleep -Milliseconds 200 }
			} while ($ReportPane.Count -eq 0 -and (Get-Date) -lt $Deadline)
			if ($ReportPane.Count -ne 1) {
				$VisiblePanes = @(Get-UIElements $Root | Where-Object { $_.Current.ControlType.ProgrammaticName -eq 'ControlType.Pane' -and -not $_.Current.IsOffscreen -and $_.Current.Name } | ForEach-Object { $_.Current.Name } | Select-Object -Unique)
				$VisibleElements = @(Get-UIElements $Root | Where-Object { -not $_.Current.IsOffscreen -and $_.Current.Name } | ForEach-Object { $_.Current.ControlType.ProgrammaticName + ':' + $_.Current.Name } | Select-Object -Unique | Select-Object -First 80)
				$FailureScreenshot = [System.IO.Path]::ChangeExtension($ResultPath, '.' + $Case.Name + '.open-failure.png')
				$FailureBounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
				$FailureBitmap = New-Object System.Drawing.Bitmap($FailureBounds.Width, $FailureBounds.Height)
				$FailureGraphics = [System.Drawing.Graphics]::FromImage($FailureBitmap)
				$FailureGraphics.CopyFromScreen($FailureBounds.Left, $FailureBounds.Top, 0, 0, $FailureBounds.Size)
				$FailureBitmap.Save($FailureScreenshot, [System.Drawing.Imaging.ImageFormat]::Png)
				$FailureGraphics.Dispose()
				$FailureBitmap.Dispose()
				throw "Report form $($Case.Name) did not open. Visible panes: $($VisiblePanes -join ' | '). Visible elements: $($VisibleElements -join ' | '). Screenshot: $FailureScreenshot"
			}
			$ReportAudit = Get-FormAudit $ReportPane[0] $Case.Name $Root
			$GenerateButtons = @(
				Get-UIElements $Root |
				Where-Object { $_.Current.ControlType.ProgrammaticName -eq 'ControlType.Button' -and -not $_.Current.IsOffscreen -and $_.Current.IsEnabled -and $_.Current.Name -match 'Сформировать|Выполнить|Generate|Run' }
			)
			if ($GenerateButtons.Count -eq 0) { throw "Report form $($Case.Name) has no enabled Generate/Run command." }
			Invoke-UIElement $GenerateButtons[0]
			Start-Sleep -Seconds 3
			$PostGenerateElements = @(Get-UIElements $Root | Where-Object { -not $_.Current.IsOffscreen })
			$VisibleReportGrids = @(
				$PostGenerateElements |
				Where-Object {
					$GridBounds = $_.Current.BoundingRectangle
					$_.Current.ControlType.ProgrammaticName -eq 'ControlType.DataGrid' -and -not $_.Current.IsOffscreen -and
					-not $GridBounds.IsEmpty -and $GridBounds.Width -gt 0 -and $GridBounds.Height -gt 0
				}
			)
			if ($VisibleReportGrids.Count -eq 0) { throw "Report $($Case.Name) generated no visible result grid." }
			$ReportErrorElements = @(
				$PostGenerateElements |
				Where-Object {
					$_.Current.Name -match '(?i)Function not found|Field not found|Parameter value not specified|Invalid value|Cannot convert|unexpected error occurred|error has occurred|ошибк|не найден|не указан'
				} |
				ForEach-Object { $_.Current.ControlType.ProgrammaticName + ':' + $_.Current.Name } |
				Select-Object -Unique
			)
			$ResultDirectory = Split-Path -Parent $ResultPath
			$ReportScreenshot = Join-Path $ResultDirectory (([System.IO.Path]::GetFileNameWithoutExtension($ResultPath)) + '.' + $Case.Name + '.report-result.png')
			$ReportBounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
			$ReportBitmap = New-Object System.Drawing.Bitmap($ReportBounds.Width, $ReportBounds.Height)
			$ReportGraphics = [System.Drawing.Graphics]::FromImage($ReportBitmap)
			$ReportGraphics.CopyFromScreen($ReportBounds.Left, $ReportBounds.Top, 0, 0, $ReportBounds.Size)
			$ReportBitmap.Save($ReportScreenshot, [System.Drawing.Imaging.ImageFormat]::Png)
			$ReportGraphics.Dispose()
			$ReportBitmap.Dispose()
			if ($ReportErrorElements.Count -gt 0) {
				throw "Report $($Case.Name) generated an error: $($ReportErrorElements -join ' | '). Screenshot: $ReportScreenshot"
			}
			$VisibleReportElements = @(
				$PostGenerateElements |
				Where-Object { -not $_.Current.IsOffscreen -and $_.Current.ControlType.ProgrammaticName -in @('ControlType.Table','ControlType.DataGrid','ControlType.Document','ControlType.Text','ControlType.DataItem') -and $_.Current.Name } |
				ForEach-Object { $_.Current.ControlType.ProgrammaticName + ':' + $_.Current.Name } |
				Select-Object -Unique
			)
			$Result.report_audit += [PSCustomObject]@{
				report = $Case.Name
				command_opened = $true
				form_opened = $true
				generate_invoked = $true
				visible_result_grid_count = $VisibleReportGrids.Count
				visible_result_grid_bounds = @($VisibleReportGrids | ForEach-Object { $GridBounds = $_.Current.BoundingRectangle; @([int]$GridBounds.X, [int]$GridBounds.Y, [int]$GridBounds.Width, [int]$GridBounds.Height) })
				visible_edit_count = $ReportAudit.visible_edit_count
				visible_fields = $ReportAudit.visible_field_names
				visible_result_elements = $VisibleReportElements
				result_screenshot = $ReportScreenshot
				ui_error_count = $ReportErrorElements.Count
			}
			$Result.verified += ($Case.Name + ': opened, generated, and rendered a visible result grid')
			[System.Windows.Forms.SendKeys]::SendWait('^{F4}')
			Start-Sleep -Milliseconds 300
		}
		$Result.status = 'PASS'
	}
	elseif ($Workflow -eq 'GuideSmoke') {
		Open-ListCommand $Root '*Bàn làm việc & Điều hành Web ERP*'
		$DashboardPane = Wait-UIElementLike $Root '*Bàn làm việc & Điều hành Web ERP - VinSmart Future*' 'ControlType.Pane' 15
		$DashboardBounds = $Root.Current.BoundingRectangle
		if ($DashboardBounds.IsEmpty -or $DashboardBounds.Width -le 0 -or $DashboardBounds.Height -le 0) { throw 'Dashboard has no finite bounds for the guide card.' }
		[void][FinanceE2EUIInput]::SetForegroundWindow([IntPtr]$Process.MainWindowHandle)
		$GuideActionX = [int]($DashboardBounds.X + $DashboardBounds.Width * 0.77)
		$GuideActionY = [int]($DashboardBounds.Y + $DashboardBounds.Height * 0.36)
		[void][FinanceE2EUIInput]::SetCursorPos($GuideActionX, $GuideActionY)
		[FinanceE2EUIInput]::mouse_event(2, 0, 0, 0, [UIntPtr]::Zero)
		[FinanceE2EUIInput]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero)
		$GuidePane = Wait-UIElementLike $Root '*Hướng dẫn quy trình tài chính - VinSmart Future*' 'ControlType.Pane' 20
		$GuideAudit = Get-FormAudit $GuidePane 'Hướng dẫn quy trình tài chính' $Root
		$GuidePaneBounds = $GuidePane.Current.BoundingRectangle
		if ($GuidePaneBounds.IsEmpty -or $GuidePaneBounds.Width -le 0 -or $GuidePaneBounds.Height -le 0) { throw 'Finance guide form opened without visible screen bounds.' }
		$GuideScreenshot = [System.IO.Path]::ChangeExtension($ResultPath, '.finance-guide.png')
		$GuideBounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
		$GuideBitmap = New-Object System.Drawing.Bitmap($GuideBounds.Width, $GuideBounds.Height)
		$GuideGraphics = [System.Drawing.Graphics]::FromImage($GuideBitmap)
		$GuideGraphics.CopyFromScreen($GuideBounds.Left, $GuideBounds.Top, 0, 0, $GuideBounds.Size)
		$GuideBitmap.Save($GuideScreenshot, [System.Drawing.Imaging.ImageFormat]::Png)
		$GuideGraphics.Dispose()
		$GuideBitmap.Dispose()
		if (-not (Test-Path -LiteralPath $GuideScreenshot) -or (Get-Item -LiteralPath $GuideScreenshot).Length -le 0) { throw 'Finance guide visual evidence was not saved.' }
		# The HTMLDocumentField does not expose anchors to UI Automation. Click the visible AR link and verify its native destination.
		$ARLinkX = [int]($DashboardBounds.X + $DashboardBounds.Width * 0.26)
		$ARLinkY = [int]($DashboardBounds.Y + $DashboardBounds.Height * 0.35)
		[void][FinanceE2EUIInput]::SetCursorPos($ARLinkX, $ARLinkY)
		[FinanceE2EUIInput]::mouse_event(2, 0, 0, 0, [UIntPtr]::Zero)
		[FinanceE2EUIInput]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero)
		$ARDestination = Wait-UIElementLike $Root '*Biên bản nghiệm thu giai đoạn (AR) - VinSmart Future*' 'ControlType.Pane' 12
		$Result.finance_guide_ui = [PSCustomObject]@{
			status = 'PASS'
			opened_from_dashboard = $true
			dashboard_click_coordinates = @($GuideActionX, $GuideActionY)
			ar_route_opened_native_document = $true
			ar_route_destination = $ARDestination.Current.Name
			visible_form_bounds = @($GuidePaneBounds.X, $GuidePaneBounds.Y, $GuidePaneBounds.Width, $GuidePaneBounds.Height)
			visible_control_count = $GuideAudit.visible_control_count
			screenshot = $GuideScreenshot
		}
		$Result.verified += @('finance process guide opened from dashboard and rendered a visible guide page', 'guide AR link opened the native acceptance document form')
		$Result.screenshot_path = $GuideScreenshot
		$Result.status = 'PASS'
	}
	elseif ($Workflow -eq 'FCTInvoiceSmoke') {
		$FCTInvoiceCase = @{ Number = 'E2E-AP-FCT250'; Command = '*Hóa đơn đầu vào (nhà cung cấp)*'; ListTitle = '*Danh sách Hóa đơn nhà cung cấp (AP)*'; FormTitle = '*Hóa đơn nhà cung cấp (AP) - VinSmart Future*'; Registers = @('SoCaiKeToan','CongNoPhaiTra') }
		Open-ListCommand $Root $FCTInvoiceCase.Command
		[void](Wait-UIElementLike $Root $FCTInvoiceCase.ListTitle 'ControlType.Pane')
		$FCTRow = $null
		$FCTDeadline = (Get-Date).AddSeconds(20)
		do {
			$FCTRow = Find-ListRow $Root $FCTInvoiceCase.Number
			if ($null -eq $FCTRow) { Start-Sleep -Milliseconds 250 }
		} while ($null -eq $FCTRow -and (Get-Date) -lt $FCTDeadline)
		if ($null -eq $FCTRow) { throw 'Posted FCT250 invoice is missing from the AP list.' }
		$FCTRowRect = $FCTRow.Current.BoundingRectangle
		$FCTX = [int]($FCTRowRect.X + ($FCTRowRect.Width / 2))
		$FCTY = [int]($FCTRowRect.Y + ($FCTRowRect.Height / 2))
		[void][FinanceE2EUIInput]::SetCursorPos($FCTX, $FCTY)
		[FinanceE2EUIInput]::mouse_event(2, 0, 0, 0, [UIntPtr]::Zero)
		[FinanceE2EUIInput]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero)
		Start-Sleep -Milliseconds 100
		[FinanceE2EUIInput]::mouse_event(2, 0, 0, 0, [UIntPtr]::Zero)
		[FinanceE2EUIInput]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero)
		[void](Wait-UIElementLike $Root $FCTInvoiceCase.FormTitle 'ControlType.Pane' 15)
		$FCTCheckboxes = @(
			Get-UIElements $Root |
			Where-Object { $_.Current.ControlType.ProgrammaticName -eq 'ControlType.CheckBox' -and -not $_.Current.IsOffscreen -and $_.Current.Name -match '(?i)FCT|thuế nhà thầu' }
		)
		if ($FCTCheckboxes.Count -ne 1) { throw "Expected the visible FCT checkbox on $($FCTInvoiceCase.Number); found $($FCTCheckboxes.Count)." }
		$FCTToggle = $FCTCheckboxes[0].GetCurrentPattern([System.Windows.Automation.TogglePattern]::Pattern)
		if ($FCTToggle.Current.ToggleState -ne [System.Windows.Automation.ToggleState]::On) { throw 'FCT250 form did not display the persisted checked FCT checkbox.' }
		$MoreAction = Wait-UIElement $Root 'More actions' 'ControlType.Button' 5
		Invoke-UIElement $MoreAction
		$RegisterCommand = Wait-UIElement $Root 'Chuyển động của chứng từ theo sổ' 'ControlType.MenuItem' 5
		Invoke-UIElement $RegisterCommand
		[void](Wait-UIElementLike $Root '*Chuyển động của chứng từ theo sổ*' 'ControlType.TabItem' 5)
		$FCTRegisterCounts = @{}
		foreach ($RegisterName in $FCTInvoiceCase.Registers) {
			$RegisterTitle = if ($RegisterName -eq 'SoCaiKeToan') { 'Sổ cái kế toán' } else { 'Công nợ phải trả' }
			$RegisterTab = Wait-UIElementLike $Root ("*" + $RegisterTitle + "*") 'ControlType.TabItem' 5
			Invoke-UIElement $RegisterTab
			$RegisterRect = $RegisterTab.Current.BoundingRectangle
			$RegisterContainers = @(
				Get-UIElements $Root |
				Where-Object {
					$Rect = $_.Current.BoundingRectangle
					$_.Current.ControlType.ProgrammaticName -eq 'ControlType.Tab' -and $_.Current.Name -eq $RegisterTitle -and
					-not $_.Current.IsOffscreen -and -not $Rect.IsEmpty -and
					$Rect.X -le $RegisterRect.X -and $Rect.Y -le $RegisterRect.Y -and
					($Rect.X + $Rect.Width) -ge ($RegisterRect.X + $RegisterRect.Width) -and
					($Rect.Y + $Rect.Height) -gt ($RegisterRect.Y + $RegisterRect.Height)
				}
			)
			if ($RegisterContainers.Count -ne 1) { throw "FCT250 register tab '$RegisterTitle' has no unique visible grid area." }
			$Cells = @($RegisterContainers[0].FindAll([System.Windows.Automation.TreeScope]::Descendants, [System.Windows.Automation.Condition]::TrueCondition) | Where-Object {
				$Rect = $_.Current.BoundingRectangle
				$_.Current.ControlType.ProgrammaticName -eq 'ControlType.Custom' -and -not $_.Current.IsOffscreen -and -not [string]::IsNullOrWhiteSpace($_.Current.Name) -and -not $Rect.IsEmpty -and $Rect.Width -gt 0 -and $Rect.Height -gt 0 -and $Rect.Y -ge ($RegisterRect.Y + $RegisterRect.Height + 5)
			})
			$Rows = @($Cells | ForEach-Object { [Math]::Round($_.Current.BoundingRectangle.Y, 0) } | Select-Object -Unique)
			if ($Rows.Count -eq 0) { throw "FCT250 register '$RegisterTitle' has no visible posted rows." }
			$FCTRegisterCounts[$RegisterName] = $Rows.Count
			$RegisterScreenshotPath = [System.IO.Path]::ChangeExtension($ResultPath, ('.fct250.' + $RegisterName + '.png'))
			$RegisterScreenBounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
			$RegisterBitmap = New-Object System.Drawing.Bitmap($RegisterScreenBounds.Width, $RegisterScreenBounds.Height)
			$RegisterGraphics = [System.Drawing.Graphics]::FromImage($RegisterBitmap)
			$RegisterGraphics.CopyFromScreen($RegisterScreenBounds.Left, $RegisterScreenBounds.Top, 0, 0, $RegisterScreenBounds.Size)
			$RegisterBitmap.Save($RegisterScreenshotPath, [System.Drawing.Imaging.ImageFormat]::Png)
			$RegisterGraphics.Dispose()
			$RegisterBitmap.Dispose()
		}
		if ($FCTRegisterCounts['SoCaiKeToan'] -lt 1 -or $FCTRegisterCounts['CongNoPhaiTra'] -lt 1) { throw "FCT250 register viewer does not show visible GL/AP records: $($FCTRegisterCounts | ConvertTo-Json -Compress)." }
		$Result.fct_invoice = $FCTInvoiceCase.Number
		$Result.fct_checkbox_persisted = $true
		$Result.register_tabs = $FCTInvoiceCase.Registers
		$Result.register_row_counts = $FCTRegisterCounts
		$Result.verified = @('FCT checkbox persisted as checked on AP invoice form', 'More opens the posted register viewer with GL and AP rows')
		$Result.status = 'PASS'
	}
	elseif ($Workflow -eq 'FormSmoke') {
		$FormCases = @(
			@{ Object = 'BienBanNghiemThuGiaiDoan'; Command = '*Biên bản nghiệm thu giai đoạn*'; ListTitle = '*Danh sách Biên bản nghiệm thu giai đoạn*'; Number = 'E2E-BB001'; FormTitle = '*Biên bản nghiệm thu giai đoạn (AR) - VinSmart Future*'; Registers = @('SoCaiKeToan','CongNoPhaiThu'); RequireRows = $true },
			@{ Object = 'HoaDonGTGTDauRa'; Command = '*Hóa đơn GTGT đầu ra*'; ListTitle = '*Danh sách Hóa đơn GTGT đầu ra (AR)*'; Number = 'E2E-AR001'; FormTitle = '*Hóa đơn GTGT đầu ra (AR) - VinSmart Future*'; Registers = @('SoCaiKeToan','CongNoPhaiThu'); RelatedNotification = 'Chuỗi chứng từ: Hợp đồng -> Hóa đơn GTGT E2E-AR001 -> Phiếu thu tiền khách hàng' },
			@{ Object = 'PhieuThuTienKhachHang'; Command = '*Phiếu thu tiền khách hàng*'; ListTitle = '*Danh sách Phiếu thu tiền khách hàng*'; Number = 'E2E-PT001'; FormTitle = '*Phiếu thu tiền khách hàng (AR) - VinSmart Future*'; Registers = @('SoCaiKeToan','CongNoPhaiThu','DongTien'); RelatedNotification = 'Chuỗi chứng từ: Hóa đơn GTGT đầu ra -> Phiếu thu tiền E2E-PT001' },
			@{ Object = 'HoaDonNhaCungCap'; Command = '*Hóa đơn đầu vào (nhà cung cấp)*'; ListTitle = '*Danh sách Hóa đơn nhà cung cấp (AP)*'; Number = 'E2E-AP001'; FormTitle = '*Hóa đơn nhà cung cấp (AP) - VinSmart Future*'; Registers = @('SoCaiKeToan','CongNoPhaiTra'); RequireRows = $true; RelatedNotification = 'Chuỗi chứng từ: Hợp đồng mua -> Hóa đơn NCC E2E-AP001 -> Ủy nhiệm chi thanh toán' },
			@{ Object = 'UyNhiemChi'; Command = '*Ủy nhiệm chi*'; ListTitle = '*Danh sách Ủy nhiệm chi*'; Number = 'E2E-UNC01'; FormTitle = '*Ủy nhiệm chi ngân hàng (AP) - VinSmart Future*'; Registers = @('SoCaiKeToan','CongNoPhaiTra','DongTien'); RelatedNotification = 'Chuỗi chứng từ: Hóa đơn nhà cung cấp -> Ủy nhiệm chi E2E-UNC01' },
			@{ Object = 'CanTruCongNoNoiBo'; Command = '*Cấn trừ công nợ nội bộ*'; ListTitle = '*Cấn trừ công nợ nội bộ*'; Number = 'E2E-NET-001'; FormTitle = '*E2E-NET-001*'; Registers = @('SoCaiKeToan','CongNoPhaiThu','CongNoPhaiTra') },
			@{ Object = 'DoiSoatKenhThanhToan'; Command = '*Bảng kê đối soát kênh thanh toán*'; ListTitle = '*Bảng kê đối soát kênh thanh toán*'; Number = 'E2E-BK-VNPAY-001'; FormTitle = '*E2E-BK-VNPAY-001*'; Registers = @('SoCaiKeToan','DongTien','CongNoPhaiThu') }
		)
		if (-not [string]::IsNullOrWhiteSpace($FormSmokeDocumentNumber)) {
			$FormCases = @($FormCases | Where-Object { $_.Number -eq $FormSmokeDocumentNumber })
			if ($FormCases.Count -ne 1) { throw "FormSmoke document filter did not resolve to one known fixture: $FormSmokeDocumentNumber." }
		}
		$Result.screens = @()
		$Result.form_audit = @()
		$Result.form_tab_audit = @()
		$Result.document_list_actions = @()
		$Result.form_command_actions = @()
		$Result.register_record_actions = @()
		$Result.related_document_actions = @()
		$Result.print_preview_actions = @()
		[void][FinanceE2EUIInput]::SetForegroundWindow([IntPtr]$Process.MainWindowHandle)
		foreach ($Case in $FormCases) {
			Open-ListCommand $Root $Case.Command
			[void](Wait-UIElementLike $Root $Case.ListTitle 'ControlType.Pane')
			$CreateOpened = Invoke-ListActionForm $Root 'Create' $Case.Number
			$Result.screens += ($Case.ListTitle.Trim('*') + ': opened; Create form opened and closed without saving')
			$Row = $null
			$Deadline = (Get-Date).AddSeconds(20)
			do {
				$Row = Find-ListRow $Root $Case.Number
				if ($null -eq $Row) { Start-Sleep -Milliseconds 250 }
			} while ($null -eq $Row -and (Get-Date) -lt $Deadline)
			if ($null -eq $Row) { throw "Document list does not show $($Case.Number)." }
			Invoke-UIElement $Row
			$CopyOpened = Invoke-ListActionForm $Root 'Copy' $Case.Number
			$Result.document_list_actions += [PSCustomObject]@{
				document_number = $Case.Number
				create_form_opened = $CreateOpened
				create_form_closed_without_save = $CreateOpened
				copy_form_opened = $CopyOpened
				copy_form_closed_without_save = $CopyOpened
			}
			$Row = $null
			$Deadline = (Get-Date).AddSeconds(20)
			do {
				$Row = Find-ListRow $Root $Case.Number
				if ($null -eq $Row) { Start-Sleep -Milliseconds 250 }
			} while ($null -eq $Row -and (Get-Date) -lt $Deadline)
			if ($null -eq $Row) { throw "Document list no longer shows $($Case.Number) after Create/Copy smoke." }
			$RowRect = $Row.Current.BoundingRectangle
			if ($RowRect.IsEmpty -or $RowRect.Width -le 0 -or $RowRect.Height -le 0) { throw "Document row has no visible bounds: $($Case.Number)." }
			$x = [int]($RowRect.X + ($RowRect.Width / 2))
			$y = [int]($RowRect.Y + ($RowRect.Height / 2))
			[void][FinanceE2EUIInput]::SetCursorPos($x, $y)
			[FinanceE2EUIInput]::mouse_event(2, 0, 0, 0, [UIntPtr]::Zero)
			[FinanceE2EUIInput]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero)
			Start-Sleep -Milliseconds 100
			[FinanceE2EUIInput]::mouse_event(2, 0, 0, 0, [UIntPtr]::Zero)
			[FinanceE2EUIInput]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero)
			$Form = Wait-UIElementLike $Root $Case.FormTitle 'ControlType.Pane' 15
			$Audit = Get-FormAudit $Form $Case.Number $Root
			if ($Audit.visible_edit_count -lt 2 -or $Audit.visible_input_count -lt 2 -or $Audit.visible_field_names.Count -lt 2) {
				throw "Document form $($Case.Number) opened without at least two visible, named input controls (edits=$($Audit.visible_edit_count), inputs=$($Audit.visible_input_count), named=$($Audit.visible_field_names.Count), scope=$($Audit.control_scope), bounds=$($Audit.form_bounds -join ','))."
			}
			$Result.form_audit += $Audit
			$TabAudit = Get-FormTabAudit $Form $Case.Object $Root
			$Result.form_tab_audit += $TabAudit
			$RegisterAction = [PSCustomObject]@{
				document_type = $Case.Object
				document_number = $Case.Number
				command = 'Chuyển động của chứng từ theo sổ'
				command_visible_in_more = $false
				command_invoked = $false
				viewer_tab_visible = $false
				register_tabs = @()
				register_tables_visible = @()
				active_register_tab = ''
				register_row_counts = @{}
				viewer_control_names = @()
				viewer_screenshot_path = ''
				posted_rows_required = [bool]$Case.RequireRows
			}
			$Result.register_record_actions += $RegisterAction
			$MoreActions = @(
				Get-UIElements $Root |
				Where-Object {
					$Rect = $_.Current.BoundingRectangle
					$FiniteBounds = @($Rect.X, $Rect.Y, $Rect.Width, $Rect.Height) | Where-Object { [double]::IsNaN([double]$_) -or [double]::IsInfinity([double]$_) }
					$_.Current.ControlType.ProgrammaticName -eq 'ControlType.Button' -and $_.Current.Name -eq 'More actions' -and
					-not $_.Current.IsOffscreen -and $_.Current.IsEnabled -and -not $Rect.IsEmpty -and
					$Rect.Width -gt 0 -and $Rect.Height -gt 0 -and $FiniteBounds.Count -eq 0
				}
			)
			if ($MoreActions.Count -ne 1) {
				$MoreActionDetails = @($MoreActions | ForEach-Object {
					$Rect = $_.Current.BoundingRectangle
					[PSCustomObject]@{ automation_id = $_.Current.AutomationId; bounds = @($Rect.X, $Rect.Y, $Rect.Width, $Rect.Height) }
				} | ConvertTo-Json -Depth 4 -Compress)
				throw "Expected one enabled More actions command on $($Case.Number); found $($MoreActions.Count). Candidates: $($MoreActionDetails -join ' ')"
			}
			Invoke-UIElement $MoreActions[0]
			$RegisterMenuItem = $null
			$MenuDeadline = (Get-Date).AddSeconds(4)
			do {
				$RegisterMenuItem = @(
					Get-UIElements $Root |
					Where-Object { $_.Current.ControlType.ProgrammaticName -in @('ControlType.MenuItem','ControlType.Button') -and $_.Current.Name -eq $RegisterAction.command -and -not $_.Current.IsOffscreen -and $_.Current.IsEnabled } |
					Select-Object -First 1
				)
				if ($RegisterMenuItem.Count -eq 0) { Start-Sleep -Milliseconds 150 }
			} while ($RegisterMenuItem.Count -eq 0 -and (Get-Date) -lt $MenuDeadline)
			if ($RegisterMenuItem.Count -ne 1) {
				$VisibleMenu = @(Get-UIElements $Root | Where-Object { -not $_.Current.IsOffscreen -and $_.Current.ControlType.ProgrammaticName -in @('ControlType.MenuItem','ControlType.Button') -and $_.Current.Name } | ForEach-Object { $_.Current.Name } | Select-Object -Unique)
				throw "Register records command was not visible in More on $($Case.Number). Menu items: $($VisibleMenu -join ' | ')"
			}
			$RegisterAction.command_visible_in_more = $true
			Invoke-UIElement $RegisterMenuItem[0]
			$RegisterAction.command_invoked = $true
			$ViewerTab = Wait-UIElementLike $Root '*Chuyển động của chứng từ theo sổ*' 'ControlType.TabItem' 5
			$RegisterAction.viewer_tab_visible = ($null -ne $ViewerTab)
			$RegisterAction.viewer_control_names = @(
				Get-UIElements $Root |
				Where-Object { -not $_.Current.IsOffscreen -and $_.Current.ControlType.ProgrammaticName -in @('ControlType.TabItem','ControlType.DataGrid','ControlType.DataItem','ControlType.Edit','ControlType.Text') -and $_.Current.Name } |
				ForEach-Object { $_.Current.ControlType.ProgrammaticName + ':' + $_.Current.Name } |
				Select-Object -Unique
			)
			$ViewerScreenshotPath = [System.IO.Path]::ChangeExtension($ResultPath, '.register-viewer.png')
			$ViewerScreenBounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
			$ViewerBitmap = New-Object System.Drawing.Bitmap($ViewerScreenBounds.Width, $ViewerScreenBounds.Height)
			$ViewerGraphics = [System.Drawing.Graphics]::FromImage($ViewerBitmap)
			$ViewerGraphics.CopyFromScreen($ViewerScreenBounds.Left, $ViewerScreenBounds.Top, 0, 0, $ViewerScreenBounds.Size)
			$ViewerBitmap.Save($ViewerScreenshotPath, [System.Drawing.Imaging.ImageFormat]::Png)
			$ViewerGraphics.Dispose()
			$ViewerBitmap.Dispose()
			$RegisterAction.viewer_screenshot_path = $ViewerScreenshotPath
			$RegisterTabTitles = @{
				SoCaiKeToan = 'Sổ cái kế toán'
				CongNoPhaiThu = 'Công nợ phải thu'
				CongNoPhaiTra = 'Công nợ phải trả'
				DongTien = 'Dòng tiền & ngân hàng'
			}
			$VisibleRegisterTabItems = @(
				Get-UIElements $Root |
				Where-Object { $_.Current.ControlType.ProgrammaticName -eq 'ControlType.TabItem' -and -not $_.Current.IsOffscreen }
			)
			foreach ($RegisterName in $Case.Registers) {
				$ExpectedTabTitle = $RegisterTabTitles[$RegisterName]
				$TabItems = @($VisibleRegisterTabItems | Where-Object { $_.Current.Name -eq $ExpectedTabTitle })
				if ($TabItems.Count -ne 1 -or -not $TabItems[0].Current.IsEnabled) {
					throw "Register viewer is missing one enabled visible '$ExpectedTabTitle' tab on $($Case.Number)."
				}
				$RegisterAction.register_tabs += $ExpectedTabTitle
			}
			# The platform UI can replace the embedded tab host after a register tab is selected.
			# Verify every register tab on the initial viewer, then inspect the initially selected grid.
			$SelectedRegisterName = ''
			$SelectedRegisterTab = $null
			foreach ($RegisterName in $Case.Registers) {
				$ExpectedTabTitle = $RegisterTabTitles[$RegisterName]
				$SelectedTabItems = @($VisibleRegisterTabItems | Where-Object { $_.Current.Name -eq $ExpectedTabTitle })
				try {
					if ($SelectedTabItems.Count -gt 0 -and $SelectedTabItems[0].GetCurrentPattern([System.Windows.Automation.SelectionItemPattern]::Pattern).Current.IsSelected) {
						$SelectedRegisterName = $RegisterName
						$SelectedRegisterTab = $SelectedTabItems[0]
						break
					}
				} catch { }
			}
			if (-not $SelectedRegisterTab) { throw "Register viewer has no selected register tab on $($Case.Number)." }
			$SelectedTabRect = $SelectedRegisterTab.Current.BoundingRectangle
			$SelectedTabTitle = $RegisterTabTitles[$SelectedRegisterName]
			$SelectedTabContainers = @(
				Get-UIElements $Root |
				Where-Object {
					$Rect = $_.Current.BoundingRectangle
					$_.Current.ControlType.ProgrammaticName -eq 'ControlType.Tab' -and $_.Current.Name -eq $SelectedTabTitle -and
					-not $_.Current.IsOffscreen -and -not $Rect.IsEmpty -and
					$Rect.X -le $SelectedTabRect.X -and $Rect.Y -le $SelectedTabRect.Y -and
					($Rect.X + $Rect.Width) -ge ($SelectedTabRect.X + $SelectedTabRect.Width) -and
					($Rect.Y + $Rect.Height) -gt ($SelectedTabRect.Y + $SelectedTabRect.Height)
				}
			)
			if ($SelectedTabContainers.Count -ne 1) { throw "Selected register tab '$SelectedTabTitle' has no unique visible table area on $($Case.Number)." }
			$SelectedRegisterCells = @(
				$SelectedTabContainers[0].FindAll([System.Windows.Automation.TreeScope]::Descendants, [System.Windows.Automation.Condition]::TrueCondition) |
				Where-Object {
					$Rect = $_.Current.BoundingRectangle
					$_.Current.ControlType.ProgrammaticName -eq 'ControlType.Custom' -and -not $_.Current.IsOffscreen -and
					-not [string]::IsNullOrWhiteSpace($_.Current.Name) -and -not $Rect.IsEmpty -and $Rect.Width -gt 0 -and $Rect.Height -gt 0 -and
					$Rect.Y -ge ($SelectedTabRect.Y + $SelectedTabRect.Height + 5)
				}
			)
			$SelectedRowCount = @($SelectedRegisterCells | ForEach-Object { [Math]::Round($_.Current.BoundingRectangle.Y, 0) } | Select-Object -Unique).Count
			$RegisterAction.register_tables_visible += $SelectedRegisterName
			$RegisterAction.active_register_tab = $SelectedRegisterName
			$RegisterAction.register_row_counts[$SelectedRegisterName] = $SelectedRowCount
			if ($Case.RequireRows -and $SelectedRowCount -eq 0) { throw "Posted fixture $($Case.Number) shows no visible rows in selected register '$SelectedRegisterName' (visible cells=$($SelectedRegisterCells.Count))." }
			if (-not $RegisterAction.viewer_tab_visible -or $RegisterAction.register_tabs.Count -ne $Case.Registers.Count) { throw "Register viewer did not expose every declared tab for $($Case.Number)." }
			$BackButtons = @(
				Get-UIElements $Root |
				Where-Object { $_.Current.ControlType.ProgrammaticName -eq 'ControlType.Button' -and $_.Current.Name -eq 'Back' -and -not $_.Current.IsOffscreen -and $_.Current.IsEnabled }
			)
			if ($BackButtons.Count -ne 1) { throw "Could not return from the register viewer to $($Case.Number); found $($BackButtons.Count) Back commands." }
			Invoke-UIElement $BackButtons[0]
			[void](Wait-UIElementLike $Root $Case.ListTitle 'ControlType.Pane' 5)
			$Row = Find-ListRow $Root $Case.Number
			if ($null -eq $Row) { throw "Returning from the register viewer did not restore the list row $($Case.Number)." }
			try { $Row.GetCurrentPattern([System.Windows.Automation.SelectionItemPattern]::Pattern).Select() }
			catch { Invoke-UIElement $Row }
			[void][FinanceE2EUIInput]::SetForegroundWindow([IntPtr]$Process.MainWindowHandle)
			[System.Windows.Forms.SendKeys]::SendWait('{ENTER}')
			$ReopenedForm = $null
			$FormDeadline = (Get-Date).AddSeconds(5)
			do {
				$VisibleFormPanes = @(
					Get-UIElements $Root |
					Where-Object { $_.Current.ControlType.ProgrammaticName -eq 'ControlType.Pane' -and $_.Current.Name -like $Case.FormTitle -and -not $_.Current.IsOffscreen }
				)
				if ($VisibleFormPanes.Count -gt 0) { $ReopenedForm = $VisibleFormPanes[0] }
				if ($null -eq $ReopenedForm) { Start-Sleep -Milliseconds 150 }
			} while ($null -eq $ReopenedForm -and (Get-Date) -lt $FormDeadline)
			if ($null -eq $ReopenedForm) {
				$RowRect = $Row.Current.BoundingRectangle
				$RowX = [int]($RowRect.X + ($RowRect.Width / 2))
				$RowY = [int]($RowRect.Y + ($RowRect.Height / 2))
				[void][FinanceE2EUIInput]::SetCursorPos($RowX, $RowY)
				[FinanceE2EUIInput]::mouse_event(2, 0, 0, 0, [UIntPtr]::Zero)
				[FinanceE2EUIInput]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero)
				Start-Sleep -Milliseconds 100
				[FinanceE2EUIInput]::mouse_event(2, 0, 0, 0, [UIntPtr]::Zero)
				[FinanceE2EUIInput]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero)
				$FormDeadline = (Get-Date).AddSeconds(5)
				do {
					$VisibleFormPanes = @(
						Get-UIElements $Root |
						Where-Object { $_.Current.ControlType.ProgrammaticName -eq 'ControlType.Pane' -and $_.Current.Name -like $Case.FormTitle -and -not $_.Current.IsOffscreen }
					)
					if ($VisibleFormPanes.Count -gt 0) { $ReopenedForm = $VisibleFormPanes[0] }
					if ($null -eq $ReopenedForm) { Start-Sleep -Milliseconds 150 }
				} while ($null -eq $ReopenedForm -and (Get-Date) -lt $FormDeadline)
			}
			if ($null -eq $ReopenedForm) { throw "Selecting $($Case.Number) and pressing Enter did not reopen its visible form after register review." }
			$Form = $ReopenedForm
			$PrimaryFormTabName = if ($TabAudit.page_count -gt 0) { [string]$TabAudit.tabs[0].name } else { '' }
			if (-not [string]::IsNullOrWhiteSpace($PrimaryFormTabName)) {
				$PrimaryFormTab = Wait-UIElementLike $Root $PrimaryFormTabName 'ControlType.TabItem' 5
				try { $PrimaryFormTab.GetCurrentPattern([System.Windows.Automation.SelectionItemPattern]::Pattern).Select() }
				catch { Invoke-UIElement $PrimaryFormTab }
				$PrimaryTabSelected = $false
				$PrimaryTabDeadline = (Get-Date).AddSeconds(3)
				do {
					try { $PrimaryTabSelected = [bool]$PrimaryFormTab.GetCurrentPattern([System.Windows.Automation.SelectionItemPattern]::Pattern).Current.IsSelected } catch { }
					if (-not $PrimaryTabSelected) { Start-Sleep -Milliseconds 100 }
				} while (-not $PrimaryTabSelected -and (Get-Date) -lt $PrimaryTabDeadline)
				if (-not $PrimaryTabSelected) { throw "Could not restore the document input tab '$PrimaryFormTabName' on $($Case.Number) after register review." }
			}
			$ReopenedFormAudit = Get-FormAudit $Form ($Case.Number + '/after-register-viewer') $Root
			$ReturnedSaveCandidates = @(Get-FormActionButtonCandidates $Root $Form 'Save')
			if (@($ReopenedFormAudit.visible_field_names | Where-Object { $_ -match '^(Number:|Number)$' }).Count -eq 0 -or $ReturnedSaveCandidates.Count -eq 0) {
				throw "Reopening $($Case.Number) after register review did not restore its editable form and Save command."
			}
			$Result.screens += ($Case.Number + ': form opened; visible edits=' + $Audit.visible_edit_count + '; named inputs=' + $Audit.visible_field_names.Count + '; enabled buttons=' + $Audit.enabled_button_names.Count)
			if ($Case.RelatedNotification) {
				$RelatedButtonCandidates = @(
					Get-UIElements $Root |
					Where-Object { $_.Current.ControlType.ProgrammaticName -eq 'ControlType.Button' -and $_.Current.Name -eq 'Chứng từ liên quan' -and -not $_.Current.IsOffscreen }
				)
				if ($RelatedButtonCandidates.Count -ne 1 -or -not $RelatedButtonCandidates[0].Current.IsEnabled) {
					throw "Expected one enabled Chứng từ liên quan command on $($Case.Number); found $($RelatedButtonCandidates.Count)."
				}
				$RelatedAction = [PSCustomObject]@{
					document_number = $Case.Number
					command = 'Chứng từ liên quan'
					command_enabled = $true
					invoked = $false
					notification_visible = $false
					notification_contains_document_number = $false
					notification_matches_expected_chain = $false
					notification_text = ''
					returned_to_list = $false
				}
				$Result.related_document_actions += $RelatedAction
				Invoke-UIElement $RelatedButtonCandidates[0]
				$RelatedAction.invoked = $true
				$NotificationSearchRoots = @($Root, [System.Windows.Automation.AutomationElement]::RootElement)
				$FindRelatedNotification = {
					$Matches = @()
					foreach ($SearchRoot in $NotificationSearchRoots) {
						foreach ($Element in (Get-UIElements $SearchRoot)) {
							if ($Element.Current.IsOffscreen) { continue }
							$Name = [string]$Element.Current.Name
							$Value = ''
							$HelpText = ''
							try { $HelpText = [string]$Element.Current.HelpText } catch { }
							try { $Value = [string]$Element.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern).Current.Value } catch { }
							$Text = ($Name + ' ' + $Value + ' ' + $HelpText).Trim()
							if ($Text.Contains('Chuỗi chứng từ:') -and $Text.Contains($Case.Number)) {
								$Matches += [PSCustomObject]@{ name = $Name; text = $Text; control_type = $Element.Current.ControlType.ProgrammaticName }
							}
						}
					}
					return $Matches
				}
				$NotificationCandidates = @()
				$NotificationCenterOpened = $false
				for ($NotificationAttempt = 0; $NotificationAttempt -lt 2 -and $NotificationCandidates.Count -eq 0; $NotificationAttempt++) {
					$NotificationDeadline = (Get-Date).AddSeconds(3)
					do {
						$NotificationCandidates = @(& $FindRelatedNotification)
						if ($NotificationCandidates.Count -eq 0) { Start-Sleep -Milliseconds 250 }
					} while ($NotificationCandidates.Count -eq 0 -and (Get-Date) -lt $NotificationDeadline)
					if ($NotificationAttempt -eq 0 -and $NotificationCandidates.Count -eq 0) {
						$NotificationCenterButton = Wait-UIElement $Root 'Notifications' 'ControlType.Button' 5
						Invoke-UIElement $NotificationCenterButton
						$NotificationCenterOpened = $true
						Start-Sleep -Milliseconds 300
					}
				}
				$RelatedAction.notification_visible = ($NotificationCandidates.Count -gt 0)
				if ($NotificationCandidates.Count -gt 0) {
					$RelatedAction.notification_text = (@($NotificationCandidates | ForEach-Object text) -join ' | ')
					$RelatedAction.notification_contains_document_number = $RelatedAction.notification_text.Contains($Case.Number)
					$RelatedAction.notification_matches_expected_chain = $RelatedAction.notification_text.Contains($Case.RelatedNotification)
				}
				if (-not $RelatedAction.notification_visible -or -not $RelatedAction.notification_contains_document_number -or -not $RelatedAction.notification_matches_expected_chain) {
					$Result.related_document_notification_diagnostic = @(
						foreach ($SearchRoot in $NotificationSearchRoots) {
							Get-UIElements $SearchRoot |
							Where-Object { -not $_.Current.IsOffscreen -and -not [string]::IsNullOrWhiteSpace($_.Current.Name) } |
							ForEach-Object { [PSCustomObject]@{ name = $_.Current.Name; control_type = $_.Current.ControlType.ProgrammaticName } }
						}
					)
					throw "Chứng từ liên quan notification did not expose $($Case.Number)."
				}
				if ($NotificationCenterOpened) { [System.Windows.Forms.SendKeys]::SendWait('{ESC}') }
			}
			$PrintPreviewButtons = @(
				Get-UIElements $Root |
				Where-Object { $_.Current.ControlType.ProgrammaticName -eq 'ControlType.Button' -and $_.Current.Name -eq 'Print preview' -and -not $_.Current.IsOffscreen }
			)
			$BeforePreviewContainers = @(
				Get-UIElements $Root |
				Where-Object { -not $_.Current.IsOffscreen -and $_.Current.ControlType.ProgrammaticName -in @('ControlType.Pane', 'ControlType.Window') } |
				ForEach-Object { $_.Current.ControlType.ProgrammaticName + '|' + $_.Current.Name }
			)
			$BeforePreviewControlKeys = @(
				Get-UIElements $Root |
				Where-Object { -not $_.Current.IsOffscreen -and $_.Current.ControlType.ProgrammaticName -in @('ControlType.MenuItem', 'ControlType.Button') -and $_.Current.Name -match '(?i)print preview|preview|print|печать|предпросмотр' } |
				ForEach-Object { $Rect = $_.Current.BoundingRectangle; $_.Current.ControlType.ProgrammaticName + '|' + $_.Current.Name + '|' + $Rect.X + '|' + $Rect.Y + '|' + $Rect.Width + '|' + $Rect.Height }
			)
			$PrintPreviewAction = [PSCustomObject]@{
				document_number = $Case.Number
				command = 'Print preview'
				command_available = $false
				command_enabled = $false
				command_source = ''
				invoked = $false
				command_button_bounds = if ($PrintPreviewButtons.Count -eq 1) { $Rect = $PrintPreviewButtons[0].Current.BoundingRectangle; @($Rect.X, $Rect.Y, $Rect.Width, $Rect.Height) } else { @() }
				menu_items = @()
				selected_menu_item = ''
				preview_surface_detected = $false
				document_number_visible = $false
				preview_surface_names = @()
				preview_surface_bounds = @()
				screenshot_path = ''
				returned_to_form = $false
			}
			$Result.print_preview_actions += $PrintPreviewAction
			if ($PrintPreviewButtons.Count -gt 1) { throw "Expected at most one direct Print preview command on $($Case.Number); found $($PrintPreviewButtons.Count)." }
			if ($PrintPreviewButtons.Count -eq 1 -and $PrintPreviewButtons[0].Current.IsEnabled) {
				$PrintPreviewAction.command_available = $true
				$PrintPreviewAction.command_enabled = $true
				$PrintPreviewAction.command_source = 'document form toolbar'
				Invoke-UIElement $PrintPreviewButtons[0]
			} else {
				$MoreActionsButtons = @(
					Get-UIElements $Root |
					Where-Object { $_.Current.ControlType.ProgrammaticName -eq 'ControlType.Button' -and $_.Current.Name -eq 'More actions' -and -not $_.Current.IsOffscreen -and $_.Current.IsEnabled }
				)
				if ($MoreActionsButtons.Count -eq 1) { Invoke-UIElement $MoreActionsButtons[0] }
			}
			$MenuDeadline = (Get-Date).AddSeconds(3)
			$PrintPreviewMenuItems = @()
			do {
				$PrintPreviewMenuItems = @(
					Get-UIElements $Root |
					Where-Object {
						if (-not $_.Current.IsOffscreen -and $_.Current.IsEnabled -and $_.Current.ControlType.ProgrammaticName -in @('ControlType.MenuItem', 'ControlType.Button') -and $_.Current.Name -match '^Print preview(\.\.\.)?$') {
							$Rect = $_.Current.BoundingRectangle
							$ControlKey = $_.Current.ControlType.ProgrammaticName + '|' + $_.Current.Name + '|' + $Rect.X + '|' + $Rect.Y + '|' + $Rect.Width + '|' + $Rect.Height
							$BeforePreviewControlKeys -notcontains $ControlKey
						} else { $false }
					}
				)
				if ($PrintPreviewMenuItems.Count -eq 0) { Start-Sleep -Milliseconds 200 }
			} while ($PrintPreviewMenuItems.Count -eq 0 -and (Get-Date) -lt $MenuDeadline)
			$PrintPreviewAction.menu_items = @(
			$PrintPreviewMenuItems |
			ForEach-Object { $Rect = $_.Current.BoundingRectangle; [PSCustomObject]@{ name = $_.Current.Name; control_type = $_.Current.ControlType.ProgrammaticName; bounds = @($Rect.X, $Rect.Y, $Rect.Width, $Rect.Height) } }
			)
			$PreviewMenuItem = @($PrintPreviewMenuItems | Where-Object { $_.Current.Name -eq 'Print preview...' } | Select-Object -First 1)
			if ($PreviewMenuItem.Count -eq 0) { $PreviewMenuItem = @($PrintPreviewMenuItems | Where-Object { $_.Current.Name -eq 'Print preview' } | Select-Object -First 1) }
			if ($PreviewMenuItem.Count -gt 0) {
				$PrintPreviewAction.command_available = $true
				$PrintPreviewAction.command_enabled = $true
				if (-not $PrintPreviewAction.command_source) { $PrintPreviewAction.command_source = 'document actions menu' }
				$PrintPreviewAction.selected_menu_item = $PreviewMenuItem[0].Current.Name
				Invoke-UIElement $PreviewMenuItem[0]
				$PrintPreviewAction.invoked = $true
			} elseif ($PrintPreviewAction.command_available) {
				$AfterFirstClickContainers = @(
					Get-UIElements $Root |
					Where-Object { -not $_.Current.IsOffscreen -and $_.Current.ControlType.ProgrammaticName -in @('ControlType.Pane', 'ControlType.Window') }
				)
				$NewPreviewContainers = @($AfterFirstClickContainers | Where-Object { $Key = $_.Current.ControlType.ProgrammaticName + '|' + $_.Current.Name; $BeforePreviewContainers -notcontains $Key })
				if ($NewPreviewContainers.Count -gt 0) { $PrintPreviewAction.invoked = $true }
			} else {
				$PrintPreviewAction.command_source = 'no direct or overflow preview command'
				[System.Windows.Forms.SendKeys]::SendWait('{ESC}')
			}
			$PreviewDeadline = (Get-Date).AddSeconds(8)
			$NewPreviewContainers = @()
			if ($PrintPreviewAction.invoked) {
				do {
					$CurrentUIElements = Get-UIElements $Root
					$AfterPreviewContainers = @(
						$CurrentUIElements |
						Where-Object { -not $_.Current.IsOffscreen -and $_.Current.ControlType.ProgrammaticName -in @('ControlType.Pane', 'ControlType.Window') }
					)
					$NewPreviewContainers = @(
						$AfterPreviewContainers | Where-Object {
							$ContainerKey = $_.Current.ControlType.ProgrammaticName + '|' + $_.Current.Name
							$BeforePreviewContainers -notcontains $ContainerKey
						}
					)
					if ($NewPreviewContainers.Count -eq 0) { Start-Sleep -Milliseconds 300 }
				} while ($NewPreviewContainers.Count -eq 0 -and (Get-Date) -lt $PreviewDeadline)
				$PrintPreviewAction.preview_surface_detected = ($NewPreviewContainers.Count -gt 0)
				$PrintPreviewAction.preview_surface_names = @($NewPreviewContainers | ForEach-Object { $_.Current.Name })
			}
			if ($PrintPreviewAction.preview_surface_detected) {
				$PreviewSurface = @($NewPreviewContainers | Where-Object { $_.Current.Name -match '(?i)print preview|preview|печать|предпросмотр' } | Select-Object -First 1)
				if ($PreviewSurface.Count -eq 0) { $PreviewSurface = @($NewPreviewContainers | Select-Object -First 1) }
				$PreviewRect = $PreviewSurface[0].Current.BoundingRectangle
				$PrintPreviewAction.preview_surface_bounds = @($PreviewRect.X, $PreviewRect.Y, $PreviewRect.Width, $PreviewRect.Height)
				$CaptureLeft = [int][Math]::Max(0, $PreviewRect.X)
				$CaptureTop = [int][Math]::Max(0, $PreviewRect.Y)
				$CaptureWidth = [int]$PreviewRect.Width
				$CaptureHeight = [int]$PreviewRect.Height
				if ($CaptureWidth -le 0 -or $CaptureHeight -le 0) {
					$ScreenBounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
					$CaptureLeft = $ScreenBounds.Left
					$CaptureTop = $ScreenBounds.Top
					$CaptureWidth = $ScreenBounds.Width
					$CaptureHeight = $ScreenBounds.Height
				}
				$PreviewBitmap = [System.Drawing.Bitmap]::new($CaptureWidth, $CaptureHeight)
				$PreviewGraphics = [System.Drawing.Graphics]::FromImage($PreviewBitmap)
				$PreviewGraphics.CopyFromScreen([System.Drawing.Point]::new($CaptureLeft, $CaptureTop), [System.Drawing.Point]::Empty, [System.Drawing.Size]::new($CaptureWidth, $CaptureHeight))
				$PreviewScreenshotPath = Join-Path (Split-Path -Parent $ResultPath) ('finance-print-preview-' + $Case.Number + '.png')
				$PreviewBitmap.Save($PreviewScreenshotPath, [System.Drawing.Imaging.ImageFormat]::Png)
				$PreviewGraphics.Dispose()
				$PreviewBitmap.Dispose()
				$PrintPreviewAction.screenshot_path = $PreviewScreenshotPath
			}
			foreach ($PreviewContainer in $NewPreviewContainers) {
				$PreviewTextElements = @($PreviewContainer) + @(Get-UIElements $PreviewContainer)
				foreach ($PreviewTextElement in $PreviewTextElements) {
					$PreviewText = [string]$PreviewTextElement.Current.Name
					try { $PreviewText += ' ' + [string]$PreviewTextElement.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern).Current.Value } catch { }
					if ($PreviewText.Contains($Case.Number)) { $PrintPreviewAction.document_number_visible = $true; break }
				}
				if ($PrintPreviewAction.document_number_visible) { break }
			}
			if ($PrintPreviewAction.invoked -and -not $PrintPreviewAction.preview_surface_detected) {
				$Result.print_preview_diagnostic = @($CurrentUIElements | Where-Object { -not $_.Current.IsOffscreen -and $_.Current.ControlType.ProgrammaticName -in @('ControlType.Pane', 'ControlType.Window', 'ControlType.Button', 'ControlType.Text') -and $_.Current.Name } | ForEach-Object { $Rect = $_.Current.BoundingRectangle; [PSCustomObject]@{ name = $_.Current.Name; control_type = $_.Current.ControlType.ProgrammaticName; bounds = @($Rect.X, $Rect.Y, $Rect.Width, $Rect.Height) } })
				throw "Print preview did not expose a visible preview surface for $($Case.Number)."
			}
			if ($PrintPreviewAction.invoked) {
				[System.Windows.Forms.SendKeys]::SendWait('^{F4}')
				$PreviewCloseDeadline = (Get-Date).AddSeconds(8)
				do {
					$ReturnedForm = @(
						Get-UIElements $Root | Where-Object { $_.Current.ControlType.ProgrammaticName -eq 'ControlType.Pane' -and $_.Current.Name -like $Case.FormTitle -and -not $_.Current.IsOffscreen }
					).Count -gt 0
					if (-not $ReturnedForm) { Start-Sleep -Milliseconds 300 }
				} while (-not $ReturnedForm -and (Get-Date) -lt $PreviewCloseDeadline)
				$PrintPreviewAction.returned_to_form = $ReturnedForm
				if (-not $ReturnedForm) { throw "Print preview did not return to the $($Case.Number) document form after Ctrl+F4." }
				$Form = Wait-UIElementLike $Root $Case.FormTitle 'ControlType.Pane' 5
			} else {
				$PrintPreviewAction.returned_to_form = @(
					Get-UIElements $Root | Where-Object { $_.Current.ControlType.ProgrammaticName -eq 'ControlType.Pane' -and $_.Current.Name -like $Case.FormTitle -and -not $_.Current.IsOffscreen }
				).Count -gt 0
			}
			$FormSaveCandidates = @(Get-FormActionButtonCandidates $Root $Form 'Save')
			if ($FormSaveCandidates.Count -eq 0) {
				$AppRect = $Root.Current.BoundingRectangle
				$Result.save_command_diagnostic = [PSCustomObject]@{
					form_bounds = @($FormRect.X, $FormRect.Y, $FormRect.Width, $FormRect.Height)
					application_bounds = @($AppRect.X, $AppRect.Y, $AppRect.Width, $AppRect.Height)
					matching_buttons = @(
						Get-UIElements $Root | Where-Object {
							$_.Current.ControlType.ProgrammaticName -eq 'ControlType.Button' -and $_.Current.Name -eq 'Save'
						} | ForEach-Object {
							$Rect = $_.Current.BoundingRectangle
						[PSCustomObject]@{
							name = $_.Current.Name
							enabled = $_.Current.IsEnabled
							offscreen = $_.Current.IsOffscreen
							bounds = @($Rect.X, $Rect.Y, $Rect.Width, $Rect.Height)
						}
						}
					)
				}
				$Result.save_locator_diagnostic = $script:FormActionButtonDiagnostic
				throw "Document form $($Case.Number) has no visible Save command in its action bar."
			}
			$SaveButton = $FormSaveCandidates[0].element
			$SaveEnabled = [bool]$FormSaveCandidates[0].enabled
			$SaveAction = [PSCustomObject]@{
				document_number = $Case.Number
				command = 'Save'
				command_enabled = $SaveEnabled
				invoked = $false
				disabled_as_observed = (-not $SaveEnabled)
				form_remained_open = $false
				returned_to_list = $false
			}
			if ($SaveEnabled) {
				$FreshSaveButton = $null
				$FreshForm = Wait-UIElementLike $Root $Case.FormTitle 'ControlType.Pane' 5
				$FreshSaveButton = @(Get-FormActionButtonCandidates $Root $FreshForm 'Save' | Where-Object enabled | Select-Object -First 1).element
				if ($null -eq $FreshSaveButton) { throw "Enabled Save command disappeared from $($Case.Number) before invocation." }
				$FreshSaveRect = $FreshSaveButton.Current.BoundingRectangle
				try { $FreshSaveButton.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern).Invoke() }
				catch {
					$SaveX = [int]($FreshSaveRect.X + ($FreshSaveRect.Width / 2))
					$SaveY = [int]($FreshSaveRect.Y + ($FreshSaveRect.Height / 2))
					[void][FinanceE2EUIInput]::SetCursorPos($SaveX, $SaveY)
					[FinanceE2EUIInput]::mouse_event(2, 0, 0, 0, [UIntPtr]::Zero)
					[FinanceE2EUIInput]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero)
				}
				Start-Sleep -Milliseconds 750
				$UnexpectedFileDialog = @(Get-UIElements $Root | Where-Object { $_.Current.Name -in @('File name:', 'Save as type:') -and -not $_.Current.IsOffscreen })
				if ($UnexpectedFileDialog.Count -gt 0) { throw "Save command on $($Case.Number) opened a file dialog instead of writing the form." }
				$SavedForm = $null
				try { $SavedForm = Wait-UIElementLike $Root $Case.FormTitle 'ControlType.Pane' 5 } catch { $SavedForm = $null }
				if ($null -eq $SavedForm) { throw "Save command closed or lost document form $($Case.Number)." }
				$SaveAction.invoked = $true
				$SaveAction.form_remained_open = $true
			} else {
				$SaveAction.form_remained_open = $true
			}
			$Result.form_command_actions += $SaveAction
			[void][FinanceE2EUIInput]::SetForegroundWindow([IntPtr]$Process.MainWindowHandle)
			$ActiveForm = Wait-UIElementLike $Root $Case.FormTitle 'ControlType.Pane' 5
			Invoke-UIElement $ActiveForm
			Start-Sleep -Milliseconds 150
			[System.Windows.Forms.SendKeys]::SendWait('^{F4}')
			$ReturnedToList = $false
			$ListDeadline = (Get-Date).AddSeconds(2)
			do {
				$VisibleList = $false
				$VisibleCreate = $false
				foreach ($Element in (Get-UIElements $Root)) {
					if ($Element.Current.IsOffscreen) { continue }
					if ($Element.Current.ControlType.ProgrammaticName -eq 'ControlType.Pane' -and $Element.Current.Name -like $Case.ListTitle) { $VisibleList = $true }
					if ($Element.Current.ControlType.ProgrammaticName -eq 'ControlType.Button' -and $Element.Current.Name -eq 'Create' -and $Element.Current.IsEnabled) { $VisibleCreate = $true }
				}
				$ReturnedToList = $VisibleList -and $VisibleCreate
				if (-not $ReturnedToList) { Start-Sleep -Milliseconds 250 }
			} while (-not $ReturnedToList -and (Get-Date) -lt $ListDeadline)
			if (-not $ReturnedToList) {
				$TabCloseButton = $null
				$ActiveFormRect = $ActiveForm.Current.BoundingRectangle
				foreach ($Element in (Get-UIElements $Root)) {
					$Rect = $Element.Current.BoundingRectangle
					if ($Element.Current.ControlType.ProgrammaticName -eq 'ControlType.Button' -and $Element.Current.Name -eq 'Close' -and
						-not $Element.Current.IsOffscreen -and $Element.Current.IsEnabled -and
						$Rect.Y -ge $ActiveFormRect.Y -and $Rect.Y -le ($ActiveFormRect.Y + $ActiveFormRect.Height) -and
						$Rect.X -ge ($ActiveFormRect.X + $ActiveFormRect.Width)) {
						$TabCloseButton = $Element
						break
					}
				}
				if ($null -ne $TabCloseButton) {
					Invoke-UIElement $TabCloseButton
					$ListDeadline = (Get-Date).AddSeconds(8)
					do {
						$VisibleList = $false
						$VisibleCreate = $false
						foreach ($Element in (Get-UIElements $Root)) {
							if ($Element.Current.IsOffscreen) { continue }
							if ($Element.Current.ControlType.ProgrammaticName -eq 'ControlType.Pane' -and $Element.Current.Name -like $Case.ListTitle) { $VisibleList = $true }
							if ($Element.Current.ControlType.ProgrammaticName -eq 'ControlType.Button' -and $Element.Current.Name -eq 'Create' -and $Element.Current.IsEnabled) { $VisibleCreate = $true }
						}
						$ReturnedToList = $VisibleList -and $VisibleCreate
						if (-not $ReturnedToList) { Start-Sleep -Milliseconds 250 }
					} while (-not $ReturnedToList -and (Get-Date) -lt $ListDeadline)
				}
			}
			if (-not $ReturnedToList) {
				$Result.form_close_diagnostic = @(
					Get-UIElements $Root |
					Where-Object { $_.Current.ControlType.ProgrammaticName -in @('ControlType.Pane', 'ControlType.Button', 'ControlType.MenuItem') -and -not [string]::IsNullOrWhiteSpace($_.Current.Name) } |
					ForEach-Object { $Rect = $_.Current.BoundingRectangle; [PSCustomObject]@{ name = $_.Current.Name; control_type = $_.Current.ControlType.ProgrammaticName; enabled = $_.Current.IsEnabled; offscreen = $_.Current.IsOffscreen; bounds = @($Rect.X, $Rect.Y, $Rect.Width, $Rect.Height) } }
				)
				$Result.foreground_window_handle = [FinanceE2EUIInput]::GetForegroundWindow().ToInt64()
				$Result.main_window_handle = $Process.MainWindowHandle.ToInt64()
				throw "Save completed but $($Case.Number) form did not return to its list after close."
			}
			$SaveAction.returned_to_list = $true
			if ($Case.RelatedNotification) { $RelatedAction.returned_to_list = $true }
		}
		Open-ListCommand $Root '*Bàn làm việc & Điều hành Web ERP*'
		$DashboardPane = Wait-UIElementLike $Root '*Bàn làm việc & Điều hành Web ERP - VinSmart Future*' 'ControlType.Pane' 15
		$Result.screens += 'Bàn làm việc & Điều hành Web ERP: opened'
		$Result.form_audit += (Get-FormAudit $DashboardPane 'Bàn làm việc & Điều hành Web ERP' $Root)
		$AppRect = $Root.Current.BoundingRectangle
		if ($AppRect.IsEmpty -or [double]::IsInfinity($AppRect.Width) -or $AppRect.Width -le 0 -or $AppRect.Height -le 0) {
			throw 'Managed application window has no finite visible bounds for the dashboard HTML action area.'
		}
		# The HTML document field does not expose its anchors to UI Automation.
		# The batch-approval card is the rightmost card in the top action row.
		$BatchActionX = [int]($AppRect.X + $AppRect.Width * 0.88)
		$BatchActionY = [int]($AppRect.Y + $AppRect.Height * 0.36)
		[void][FinanceE2EUIInput]::SetCursorPos($BatchActionX, $BatchActionY)
		[FinanceE2EUIInput]::mouse_event(2, 0, 0, 0, [UIntPtr]::Zero)
		[FinanceE2EUIInput]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero)
		$BatchApprovalPane = Wait-UIElementLike $Root '*Bàn Duyệt Maker-Checker Hàng Loạt - VinSmart Future*' 'ControlType.Pane' 15
		$BatchApprovalAudit = Get-FormAudit $BatchApprovalPane 'Bàn Duyệt Maker-Checker Hàng Loạt' $Root
		if ($BatchApprovalAudit.visible_input_count -lt 2) {
			throw "Batch approval form opened without at least two visible input controls (edits=$($BatchApprovalAudit.visible_edit_count), inputs=$($BatchApprovalAudit.visible_input_count))."
		}
		$Result.form_audit += $BatchApprovalAudit
		$Result.screens += ('Bàn Duyệt Maker-Checker Hàng Loạt: opened from dashboard; visible edits=' + $BatchApprovalAudit.visible_edit_count + '; enabled buttons=' + $BatchApprovalAudit.enabled_button_names.Count)
		$Result.verified = $Result.screens
		$Result.status = 'PASS'
	}
	elseif ($Workflow -eq 'BatchApproval') {
		if ($User -ne 'ketoan_truong') { throw 'Batch approval UI workflow must run as ketoan_truong.' }
		Open-ListCommand $Root '*Bàn làm việc & Điều hành Web ERP*'
		$DashboardPane = Wait-UIElementLike $Root '*Bàn làm việc & Điều hành Web ERP - VinSmart Future*' 'ControlType.Pane' 15
		$DashboardRect = $Root.Current.BoundingRectangle
		if ($DashboardRect.IsEmpty -or $DashboardRect.Width -le 0 -or $DashboardRect.Height -le 0) {
			throw 'Dashboard has no finite bounds for the batch approval card.'
		}
		$ScreenBounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
		$ScreenshotPath = [System.IO.Path]::ChangeExtension($ResultPath, '.png')
		$Screenshot = New-Object System.Drawing.Bitmap($ScreenBounds.Width, $ScreenBounds.Height)
		$Graphics = [System.Drawing.Graphics]::FromImage($Screenshot)
		$Graphics.CopyFromScreen($ScreenBounds.Left, $ScreenBounds.Top, 0, 0, $ScreenBounds.Size)
		$Screenshot.Save($ScreenshotPath, [System.Drawing.Imaging.ImageFormat]::Png)
		$Graphics.Dispose()
		$Screenshot.Dispose()
		$Result.screenshot_path = $ScreenshotPath
		$Result.dashboard_bounds = @($DashboardRect.X, $DashboardRect.Y, $DashboardRect.Width, $DashboardRect.Height)
		[void][FinanceE2EUIInput]::SetForegroundWindow([IntPtr]$Process.MainWindowHandle)
		Start-Sleep -Milliseconds 500
		try { $DashboardPane.SetFocus() } catch {}
		[System.Windows.Forms.SendKeys]::SendWait('^{HOME}')
		Start-Sleep -Milliseconds 700
		$TopDashboardScreenshotPath = [System.IO.Path]::ChangeExtension($ResultPath, '.dashboard-top.png')
		$TopDashboardScreenshot = New-Object System.Drawing.Bitmap($ScreenBounds.Width, $ScreenBounds.Height)
		$TopDashboardGraphics = [System.Drawing.Graphics]::FromImage($TopDashboardScreenshot)
		$TopDashboardGraphics.CopyFromScreen($ScreenBounds.Left, $ScreenBounds.Top, 0, 0, $ScreenBounds.Size)
		$TopDashboardScreenshot.Save($TopDashboardScreenshotPath, [System.Drawing.Imaging.ImageFormat]::Png)
		$TopDashboardGraphics.Dispose()
		$TopDashboardScreenshot.Dispose()
		$Result.dashboard_top_screenshot_path = $TopDashboardScreenshotPath
		Start-Sleep -Milliseconds 300
		$BatchActionX = [int]($DashboardRect.X + $DashboardRect.Width * 0.88)
		$BatchActionY = [int]($DashboardRect.Y + $DashboardRect.Height * 0.36)
		$Result.dashboard_click_coordinates = @($BatchActionX, $BatchActionY)
		$Result.foreground_window_handle = [FinanceE2EUIInput]::GetForegroundWindow().ToInt64()
		$Result.main_window_handle = $Process.MainWindowHandle.ToInt64()
		[void][FinanceE2EUIInput]::SetCursorPos($BatchActionX, $BatchActionY)
		[FinanceE2EUIInput]::mouse_event(2, 0, 0, 0, [UIntPtr]::Zero)
		Start-Sleep -Milliseconds 100
		[FinanceE2EUIInput]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero)
		Start-Sleep -Milliseconds 500
		$AfterClickPath = [System.IO.Path]::ChangeExtension($ResultPath, '.after-click.png')
		$AfterClickScreenshot = New-Object System.Drawing.Bitmap($ScreenBounds.Width, $ScreenBounds.Height)
		$AfterClickGraphics = [System.Drawing.Graphics]::FromImage($AfterClickScreenshot)
		$AfterClickGraphics.CopyFromScreen($ScreenBounds.Left, $ScreenBounds.Top, 0, 0, $ScreenBounds.Size)
		$AfterClickScreenshot.Save($AfterClickPath, [System.Drawing.Imaging.ImageFormat]::Png)
		$AfterClickGraphics.Dispose()
		$AfterClickScreenshot.Dispose()
		$Result.after_click_screenshot_path = $AfterClickPath
		$Result.visible_action_controls = @(
			Get-UIElements $Root | Where-Object {
				-not $_.Current.IsOffscreen -and $_.Current.ControlType.ProgrammaticName -in @('ControlType.Pane', 'ControlType.Document', 'ControlType.Custom', 'ControlType.Hyperlink', 'ControlType.Button')
			} | ForEach-Object {
				$Rect = $_.Current.BoundingRectangle
				[PSCustomObject]@{ name = $_.Current.Name; type = $_.Current.ControlType.ProgrammaticName; bounds = @($Rect.X, $Rect.Y, $Rect.Width, $Rect.Height) }
			}
		)
		$BatchApprovalPane = Wait-UIElementLike $Root '*Bàn Duyệt Maker-Checker Hàng Loạt - VinSmart Future*' 'ControlType.Pane' 15
		$BatchApprovalAudit = Get-FormAudit $BatchApprovalPane 'Bàn Duyệt Maker-Checker Hàng Loạt' $Root
		if ($BatchApprovalAudit.visible_input_count -lt 2) {
			throw "Batch approval form opened without at least two visible input controls (edits=$($BatchApprovalAudit.visible_edit_count), inputs=$($BatchApprovalAudit.visible_input_count))."
		}
		$Result.batch_approval_panel_opened = $true
		$Result.batch_approval_panel_bounds = @($BatchApprovalPane.Current.BoundingRectangle.X, $BatchApprovalPane.Current.BoundingRectangle.Y, $BatchApprovalPane.Current.BoundingRectangle.Width, $BatchApprovalPane.Current.BoundingRectangle.Height)
		$Result.batch_approval_queue_document_visible = $false
		$Result.batch_approval_queue_evidence = 'Queue content is rendered in the HTML field and captured in the screenshot; the 1C UI Automation provider exposes the form title but not the HTML text.'
		$Result.batch_approval_actions = @()
		$RootRect = $Root.Current.BoundingRectangle
		$ContentPanes = @(
			Get-UIElements $Root | Where-Object {
				$Rect = $_.Current.BoundingRectangle
				$_.Current.ControlType.ProgrammaticName -eq 'ControlType.Pane' -and -not $_.Current.IsOffscreen -and
				-not $Rect.IsEmpty -and $Rect.X -ge ($RootRect.X + ($RootRect.Width * 0.17)) -and
				$Rect.Y -ge ($RootRect.Y + 50) -and $Rect.Width -ge ($RootRect.Width * 0.7) -and
				$Rect.Height -ge ($RootRect.Height * 0.6)
			} | Sort-Object { $_.Current.BoundingRectangle.Width * $_.Current.BoundingRectangle.Height } -Descending
		)
		if ($ContentPanes.Count -eq 0) { throw 'Batch approval HTML content pane has no usable screen bounds.' }
		$ContentRect = $ContentPanes[0].Current.BoundingRectangle
		$ActionY = [int]($ContentRect.Y + ($ContentRect.Height * 0.16))
		$RefreshX = [int]($ContentRect.X + ($ContentRect.Width * 0.75))
		$Result.refresh_action_coordinates = @($RefreshX, $ActionY)
		[void][FinanceE2EUIInput]::SetForegroundWindow([IntPtr]$Process.MainWindowHandle)
		[void][FinanceE2EUIInput]::SetCursorPos($RefreshX, $ActionY)
		[FinanceE2EUIInput]::mouse_event(2, 0, 0, 0, [UIntPtr]::Zero)
		[FinanceE2EUIInput]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero)
		$RefreshNotice = Wait-VisibleNotification $Root 'Đã cập nhật danh sách chờ duyệt'
		$Result.batch_approval_actions += [PSCustomObject]@{
			action = 'refresh'
			invoked = $true
			notification_visible = $RefreshNotice.visible
			notification_text = $RefreshNotice.text
		}
		# 1C may surface ShowUserNotification in its notification center rather than
		# as accessible text. The downstream server verification is the contract for
		# whether the row actions actually reached the approval handler.

		# Exercise the row action separately. Its token is resolved against the current
		# server-side queue, so this coordinate selects a row rather than trusting a client Ref.
		# The first row action is near the right side and about 36% down this pane.
		$ApproveRowX = [int]($ContentRect.X + ($ContentRect.Width * 0.91))
		$ApproveRowY = [int]($ContentRect.Y + ($ContentRect.Height * 0.36))
		$Result.approve_one_action_coordinates = @($ApproveRowX, $ApproveRowY)
		[void][FinanceE2EUIInput]::SetForegroundWindow([IntPtr]$Process.MainWindowHandle)
		[void][FinanceE2EUIInput]::SetCursorPos($ApproveRowX, $ApproveRowY)
		[FinanceE2EUIInput]::mouse_event(2, 0, 0, 0, [UIntPtr]::Zero)
		[FinanceE2EUIInput]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero)
		$ApproveOneNotice = Wait-VisibleNotification $Root 'Duyệt chứng từ hoàn tất: 1 thành công, 0 thất bại' 10
		$Result.batch_approval_actions += [PSCustomObject]@{
			action = 'approve_one'
			invoked = $true
			notification_visible = $ApproveOneNotice.visible
			notification_text = $ApproveOneNotice.text
		}
		Start-Sleep -Milliseconds 500
		$AfterRowApprovalPath = [System.IO.Path]::ChangeExtension($ResultPath, '.after-row-approval.png')
		$AfterRowApprovalScreenshot = New-Object System.Drawing.Bitmap($ScreenBounds.Width, $ScreenBounds.Height)
		$AfterRowApprovalGraphics = [System.Drawing.Graphics]::FromImage($AfterRowApprovalScreenshot)
		$AfterRowApprovalGraphics.CopyFromScreen($ScreenBounds.Left, $ScreenBounds.Top, 0, 0, $ScreenBounds.Size)
		$AfterRowApprovalScreenshot.Save($AfterRowApprovalPath, [System.Drawing.Imaging.ImageFormat]::Png)
		$AfterRowApprovalGraphics.Dispose()
		$AfterRowApprovalScreenshot.Dispose()
		$Result.after_row_approval_screenshot_path = $AfterRowApprovalPath

		$ApproveAllX = [int]($ContentRect.X + ($ContentRect.Width * 0.87))
		$Result.approve_all_action_coordinates = @($ApproveAllX, $ActionY)
		[void][FinanceE2EUIInput]::SetForegroundWindow([IntPtr]$Process.MainWindowHandle)
		[void][FinanceE2EUIInput]::SetCursorPos($ApproveAllX, $ActionY)
		[FinanceE2EUIInput]::mouse_event(2, 0, 0, 0, [UIntPtr]::Zero)
		[FinanceE2EUIInput]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero)
		$ApproveAllNotice = Wait-VisibleNotification $Root 'Phê duyệt hoàn tất: 1 thành công, 0 thất bại' 10
		$Result.batch_approval_actions += [PSCustomObject]@{
			action = 'approve_all'
			invoked = $true
			notification_visible = $ApproveAllNotice.visible
			notification_text = $ApproveAllNotice.text
		}
		Start-Sleep -Milliseconds 500
		$AfterApprovalPath = [System.IO.Path]::ChangeExtension($ResultPath, '.after-approval.png')
		$AfterApprovalScreenshot = New-Object System.Drawing.Bitmap($ScreenBounds.Width, $ScreenBounds.Height)
		$AfterApprovalGraphics = [System.Drawing.Graphics]::FromImage($AfterApprovalScreenshot)
		$AfterApprovalGraphics.CopyFromScreen($ScreenBounds.Left, $ScreenBounds.Top, 0, 0, $ScreenBounds.Size)
		$AfterApprovalScreenshot.Save($AfterApprovalPath, [System.Drawing.Imaging.ImageFormat]::Png)
		$AfterApprovalGraphics.Dispose()
		$AfterApprovalScreenshot.Dispose()
		$Result.after_approval_screenshot_path = $AfterApprovalPath
		$Result.screenshot_path = $ScreenshotPath
		$Result.screens = @('Dashboard opened', 'Batch approval panel opened', 'Refresh invoked', 'Single-row approval invoked', 'Approve All invoked with one remaining queue item')
		$Result.form_audit = @($BatchApprovalAudit)
		$Result.verified = $Result.screens
		$Result.status = 'PASS'
	}
	elseif ($Workflow -eq 'ListFilterDiagnostics') {
		$InvoiceCommand = Wait-UIElement $Root 'Hóa đơn GTGT đầu ra' 'ControlType.MenuItem'
		Invoke-UIElement $InvoiceCommand
		[void](Wait-UIElement $Root 'Danh sách Hóa đơn GTGT đầu ra (AR)' 'ControlType.Pane')
		$Result.controls = @(
			foreach ($Element in (Get-UIElements $Root)) {
				$Value = ''
				try { $Value = [string]$Element.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern).Current.Value } catch { }
				[PSCustomObject]@{
					name = $Element.Current.Name
					control_type = $Element.Current.ControlType.ProgrammaticName
					value = $Value
					enabled = $Element.Current.IsEnabled
					offscreen = $Element.Current.IsOffscreen
				}
			}
		)
		$PeriodControl = $null
		foreach ($Element in (Get-UIElements $Root)) {
			if ($Element.Current.ControlType.ProgrammaticName -eq 'ControlType.ComboBox' -and $Element.Current.Name -like 'Kỳ*') {
				$PeriodControl = $Element
				break
			}
		}
		if ($null -ne $PeriodControl) {
			$Result.period_patterns = @($PeriodControl.GetSupportedPatterns() | ForEach-Object { $_.ProgrammaticName })
			try { $Result.period_read_only = $PeriodControl.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern).Current.IsReadOnly } catch { }
			try {
				$PeriodControl.GetCurrentPattern([System.Windows.Automation.ExpandCollapsePattern]::Pattern).Expand()
				Start-Sleep -Milliseconds 500
				$Result.period_choices = @(
					Get-UIElements $Root |
					Where-Object { $_.Current.ControlType.ProgrammaticName -in @('ControlType.ListItem', 'ControlType.ComboBox') } |
					ForEach-Object { [PSCustomObject]@{ name = $_.Current.Name; type = $_.Current.ControlType.ProgrammaticName } }
				)
				[System.Windows.Forms.SendKeys]::SendWait('{ESC}')
			}
			catch { $Result.period_choice_error = $_.Exception.Message }
		}
		$Result.verified += 'AR invoice list opened and UI Automation controls enumerated'
		$Result.status = 'PASS'
	}
	elseif ($Workflow -in @('BankSend', 'RefundConfirm')) {
		Open-ListCommand $Root '*Ủy nhiệm chi*'
		[void](Wait-UIElementLike $Root '*Danh sách Ủy nhiệm chi*' 'ControlType.Pane')
		$Row = $null
		$Deadline = (Get-Date).AddSeconds(30)
		do {
			foreach ($Element in (Get-UIElements $Root)) {
				if ($Element.Current.ControlType.ProgrammaticName -eq 'ControlType.Custom' -and $Element.Current.Name -like ($ExpectedPaymentNumber + '*')) { $Row = $Element; break }
			}
			if ($null -eq $Row) { Start-Sleep -Milliseconds 250 }
		} while ($null -eq $Row -and (Get-Date) -lt $Deadline)
		if ($null -eq $Row) { throw "Payment UI list does not show document $ExpectedPaymentNumber." }
		$Result.verified += 'payment order list rendered expected document'
		$RowRect = $Row.Current.BoundingRectangle
		$FormPattern = '*Ủy nhiệm chi ngân hàng (AP)*VinSmart Future*'
		$Form = $null
		[void][FinanceE2EUIInput]::SetForegroundWindow([IntPtr]$Process.MainWindowHandle)
		$x = [int]($RowRect.X + ($RowRect.Width / 2))
		$y = [int]($RowRect.Y + ($RowRect.Height / 2))
		[void][FinanceE2EUIInput]::SetCursorPos($x, $y)
		[FinanceE2EUIInput]::mouse_event(2, 0, 0, 0, [UIntPtr]::Zero)
		[FinanceE2EUIInput]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero)
		Start-Sleep -Milliseconds 250
		[System.Windows.Forms.SendKeys]::SendWait('{ENTER}')
		try { $Form = Wait-UIElementLike $Root $FormPattern 'ControlType.Pane' 5 } catch { $Form = $null }
		if ($null -eq $Form) {
			$DesktopElements = [System.Windows.Automation.AutomationElement]::RootElement.FindAll([System.Windows.Automation.TreeScope]::Descendants, [System.Windows.Automation.Condition]::TrueCondition)
			$ErrorText = @($DesktopElements | Where-Object { $_.Current.Name -match 'unexpected error|Generate error report|Unfortunately|error occurred' } | ForEach-Object { $_.Current.Name } | Select-Object -Unique)
			if ($ErrorText.Count -gt 0) { throw "1C runtime dialog after opening payment: $($ErrorText -join ' | ')" }
			[void][FinanceE2EUIInput]::SetCursorPos($x, $y)
			[FinanceE2EUIInput]::mouse_event(2, 0, 0, 0, [UIntPtr]::Zero)
			[FinanceE2EUIInput]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero)
			Start-Sleep -Milliseconds 180
			[FinanceE2EUIInput]::mouse_event(2, 0, 0, 0, [UIntPtr]::Zero)
			[FinanceE2EUIInput]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero)
			$Form = Wait-UIElementLike $Root $FormPattern 'ControlType.Pane' 10
		}
		$IsRefundConfirmation = $Workflow -eq 'RefundConfirm'
		$ActionButtonName = if ($IsRefundConfirmation) { 'Xác nhận hoàn tiền ngân hàng' } else { 'Gửi ngân hàng' }
		$BankActionButton = Wait-UIElement $Root $ActionButtonName 'ControlType.Button'
		$PaymentStateTab = Wait-UIElementLike $Root '*Trạng thái thanh toán*' 'ControlType.TabItem' 5
		Invoke-UIElement $PaymentStateTab
		Invoke-UIElement $BankActionButton
		$ExpectedStatus = switch ($ExpectedBankOutcome) {
			'Accepted' { 'ACCEPTED' }
			'Rejected' { 'HTTP_REJECTED' }
			'RefundReceived' { 'REFUND_RECEIVED' }
		}
		$BankStatus = ''
		$TransactionId = ''
		$Deadline = (Get-Date).AddSeconds(20)
		do {
			foreach ($Element in (Get-UIElements $Root)) {
				if ($Element.Current.ControlType.ProgrammaticName -ne 'ControlType.Edit') { continue }
				try { $Value = [string]$Element.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern).Current.Value }
				catch { continue }
				if ($Element.Current.Name -like '*Trạng thái ngân hàng*' -or $Element.Current.Name -like '*TrangThaiGuiNganHangUI*') { $BankStatus = $Value }
				if ($Element.Current.Name -like '*Mã giao dịch ngân hàng*' -or $Element.Current.Name -like '*MaGiaoDichNganHangUI*') { $TransactionId = $Value }
			}
			if ($BankStatus -ne $ExpectedStatus) { Start-Sleep -Milliseconds 300 }
		} while ($BankStatus -ne $ExpectedStatus -and (Get-Date) -lt $Deadline)
		if ($BankStatus -ne $ExpectedStatus) { throw "Bank status mismatch: expected $ExpectedStatus, UI shows '$BankStatus'." }
		if ($ExpectedBankOutcome -in @('Accepted', 'RefundReceived') -and [string]::IsNullOrWhiteSpace($TransactionId)) { throw "Bank response $ExpectedStatus has no transaction ID on the payment form." }
		if ($ExpectedBankOutcome -eq 'Rejected' -and -not [string]::IsNullOrWhiteSpace($TransactionId)) { throw 'Rejected bank response unexpectedly has a transaction ID on the payment form.' }
		$ActionDescription = if ($IsRefundConfirmation) { 'incoming refund confirmation command invoked' } else { 'bank payment submission command invoked' }
		$Result.verified += @('payment form opened', $ActionDescription, "bank response status $ExpectedStatus rendered")
		$Result.status = 'PASS'
		$Result.payment_number = $ExpectedPaymentNumber
		$Result.expected_bank_outcome = $ExpectedBankOutcome
		$Result.bank_status = $BankStatus
		$Result.bank_transaction_id = $TransactionId
		if ($IsRefundConfirmation) { $Result.refund_number = $ExpectedPaymentNumber }
	}
	elseif ($Workflow -eq 'ARInvoice') {
		$InvoiceCommand = Wait-UIElement $Root 'Hóa đơn GTGT đầu ra' 'ControlType.MenuItem'
		Invoke-UIElement $InvoiceCommand
		[void](Wait-UIElement $Root 'Danh sách Hóa đơn GTGT đầu ra (AR)' 'ControlType.Pane')
		$Row = $null
		$Deadline = (Get-Date).AddSeconds(30)
		do {
			foreach ($Element in (Get-UIElements $Root)) {
				if ($Element.Current.ControlType.ProgrammaticName -eq 'ControlType.Custom' -and $Element.Current.Name -like ($ExpectedNumber + '*')) { $Row = $Element; break }
			}
			if ($null -eq $Row) { Start-Sleep -Milliseconds 250 }
		} while ($null -eq $Row -and (Get-Date) -lt $Deadline)
		if ($null -eq $Row) { throw "AR UI list does not show document $ExpectedNumber." }
		$Result.verified += 'AR invoice list rendered expected document'
		$RowRect = $Row.Current.BoundingRectangle
		$x = [int]($RowRect.X + ($RowRect.Width / 2))
		$y = [int]($RowRect.Y + ($RowRect.Height / 2))
		[void][FinanceE2EUIInput]::SetCursorPos($x, $y)
		[FinanceE2EUIInput]::mouse_event(2, 0, 0, 0, [UIntPtr]::Zero)
		[FinanceE2EUIInput]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero)
		Start-Sleep -Milliseconds 100
		[FinanceE2EUIInput]::mouse_event(2, 0, 0, 0, [UIntPtr]::Zero)
		[FinanceE2EUIInput]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero)
		$FormElements = @()
		$FormDeadline = (Get-Date).AddSeconds(20)
	$DocumentFormOpened = $false
		do {
			$FormElements = @(Get-UIElements $Root)
			$NumberControls = @(
				$FormElements | Where-Object {
					$_.Current.ControlType.ProgrammaticName -eq 'ControlType.Edit' -and $_.Current.Name -eq 'Number:' -and -not $_.Current.IsOffscreen
				}
			)
			$NumberMatches = @()
			foreach ($NumberControl in $NumberControls) {
				try {
					if ([string]$NumberControl.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern).Current.Value -eq $ExpectedNumber) { $NumberMatches += $NumberControl }
				} catch { }
			}
			$VisibleSave = @($FormElements | Where-Object { $_.Current.ControlType.ProgrammaticName -eq 'ControlType.Button' -and $_.Current.Name -eq 'Save' -and -not $_.Current.IsOffscreen })
			$DocumentFormOpened = $NumberMatches.Count -gt 0 -and $VisibleSave.Count -gt 0
			if (-not $DocumentFormOpened) { Start-Sleep -Milliseconds 200 }
		} while (-not $DocumentFormOpened -and (Get-Date) -lt $FormDeadline)
		if (-not $DocumentFormOpened) {
			$PaneNames = @(Get-UIElements $Root | Where-Object { $_.Current.ControlType.ProgrammaticName -eq 'ControlType.Pane' -and -not $_.Current.IsOffscreen -and $_.Current.Name } | ForEach-Object { $_.Current.Name } | Select-Object -Unique)
			$Inputs = @(
				$FormElements | Where-Object { $_.Current.ControlType.ProgrammaticName -in @('ControlType.Edit', 'ControlType.ComboBox') -and -not $_.Current.IsOffscreen } | ForEach-Object {
					$Value = ''
					try { $Value = [string]$_.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern).Current.Value } catch { }
					[PSCustomObject]@{ name = $_.Current.Name; value = $Value }
				}
			)
			throw "AR form did not open with document number $ExpectedNumber and a visible Save command. Panes: $($PaneNames -join ' | '); inputs: $(ConvertTo-Json -InputObject $Inputs -Compress -Depth 4)"
		}
		$Values = @{}
		foreach ($Element in $FormElements) {
			if ($Element.Current.ControlType.ProgrammaticName -ne 'ControlType.Edit') { continue }
			try { $Value = $Element.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern).Current.Value }
			catch { continue }
			if ($Element.Current.Name) { $Values[$Element.Current.Name] = [string]$Value }
		}
		if ($Values['Number:'] -ne $ExpectedNumber) { throw "AR form number mismatch: '$($Values['Number:'])'." }
		if ($Values['Thành tiền chưa thuế:'] -ne '200,000,000.00') { throw "AR UI net amount mismatch: '$($Values['Thành tiền chưa thuế:'])'." }
		if ($Values['Thuế suất GTGT (%):'] -notlike '10*') { throw "AR UI VAT rate mismatch: '$($Values['Thuế suất GTGT (%):'])'; expected 10%." }
		if ($Values['Tiền thuế GTGT:'] -ne '20,000,000.00') { throw "AR UI VAT mismatch: '$($Values['Tiền thuế GTGT:'])'; expected 20,000,000.00." }
		if ($Values['Tổng tiền thanh toán:'] -ne '220,000,000.00') { throw "AR UI gross amount mismatch: '$($Values['Tổng tiền thanh toán:'])'; expected 220,000,000.00." }
		if ($Values['Biên bản nghiệm thu:'] -notlike '*E2E-BB001*') { throw "AR UI source acceptance mismatch: '$($Values['Biên bản nghiệm thu:'])'." }
		$Result.verified += @('AR invoice form opened from list', 'document number matched', 'source acceptance matched', '10% VAT rate matched', 'net/VAT/gross amounts matched')
		$Result.status = 'PASS'
		$Result.document_number = $Values['Number:']
		$Result.source_acceptance = $Values['Biên bản nghiệm thu:']
		$Result.net_vnd = 200000000
		$Result.vat_vnd = 20000000
		$Result.gross_vnd = 220000000
	}
}
catch {
	$Result.error = $_.Exception.Message
	try {
		$FailureScreenshot = [System.IO.Path]::ChangeExtension($ResultPath, '.unhandled-failure.png')
		$FailureBounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
		$FailureBitmap = New-Object System.Drawing.Bitmap($FailureBounds.Width, $FailureBounds.Height)
		$FailureGraphics = [System.Drawing.Graphics]::FromImage($FailureBitmap)
		$FailureGraphics.CopyFromScreen($FailureBounds.Left, $FailureBounds.Top, 0, 0, $FailureBounds.Size)
		$FailureBitmap.Save($FailureScreenshot, [System.Drawing.Imaging.ImageFormat]::Png)
		$FailureGraphics.Dispose()
		$FailureBitmap.Dispose()
		$Result.failure_screenshot_path = $FailureScreenshot
	} catch { }
}
finally {
	if ($Process -and -not $Process.HasExited) {
		[void]$Process.CloseMainWindow()
		Start-Sleep -Seconds 2
		$Process.Refresh()
		if (-not $Process.HasExited) { Stop-Process -Id $Process.Id -Force -ErrorAction SilentlyContinue }
	}
}

New-Item -ItemType Directory -Path (Split-Path -Parent $ResultPath) -Force | Out-Null
$Result | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $ResultPath -Encoding UTF8
$Result | ConvertTo-Json -Depth 8
if ($Result.status -ne 'PASS') { exit 1 }
