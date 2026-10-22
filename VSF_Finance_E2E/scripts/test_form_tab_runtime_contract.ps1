[CmdletBinding()]
param(
	[Parameter(Mandatory = $true)][string]$ResultPath,
	[string]$ConfigurationPath,
	[switch]$AllowPartial
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($ConfigurationPath)) {
	$ConfigurationPath = Join-Path $PSScriptRoot '..\Configuration'
}

if (-not (Test-Path -LiteralPath $ResultPath)) {
	throw "UI form result was not found: $ResultPath"
}
if (-not (Test-Path -LiteralPath $ConfigurationPath)) {
	throw "Configuration directory was not found: $ConfigurationPath"
}

$Result = Get-Content -LiteralPath $ResultPath -Raw -Encoding UTF8 | ConvertFrom-Json
if ($Result.status -ne 'PASS') {
	throw "UI form workflow did not pass: $($Result.status). $($Result.error)"
}
if (-not $Result.PSObject.Properties['form_tab_audit']) {
	throw 'UI form result has no runtime tab audit.'
}
if (-not $Result.PSObject.Properties['register_record_actions']) {
	throw 'UI form result has no document register action audit.'
}

$FormFiles = @(
	Get-ChildItem -LiteralPath (Join-Path $ConfigurationPath 'Documents') -Recurse -File -Filter 'Form.xml' |
	Where-Object { $_.FullName -match '[\\/]Forms[\\/]FormChungTu[\\/]Ext[\\/]Form\.xml$' }
)
if ($FormFiles.Count -eq 0) {
	throw 'No custom document forms were found in Configuration/Documents.'
}

$Failures = [System.Collections.Generic.List[string]]::new()
$AuditedPrimaryPageCount = 0
$ExpectedRegisterFormCount = 0
$AuditedDocumentTypes = @($Result.form_tab_audit | ForEach-Object { [string]$_.document_type } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
foreach ($FormFile in $FormFiles) {
	[xml]$FormXml = Get-Content -LiteralPath $FormFile.FullName -Raw -Encoding UTF8
	$DocumentType = Split-Path -Leaf (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $FormFile.DirectoryName)))
	$RootPages = @($FormXml.SelectNodes('/*[local-name()="Form"]/*[local-name()="ChildItems"]/*[local-name()="Pages"]/*[local-name()="ChildItems"]/*[local-name()="Page"]'))
	$PrimaryPages = @($RootPages | Where-Object {
		$_.GetAttribute('name') -ne 'RegisterRecordsTab' -and
		@($_.SelectNodes('.//*[local-name()="InputField" or local-name()="CheckBoxField" or local-name()="RadioButtonField" or local-name()="Table"]')).Count -gt 0
	})
	if ($AllowPartial -and $DocumentType -notin $AuditedDocumentTypes) { continue }
	$AuditEntries = @($Result.form_tab_audit | Where-Object { $_.document_type -eq $DocumentType })
	if ($AuditEntries.Count -ne 1) {
		if ($AllowPartial -and $AuditEntries.Count -eq 0) { continue }
		$Failures.Add("$DocumentType has $($AuditEntries.Count) runtime tab audit entries; expected exactly one.")
		continue
	}

	$Entry = $AuditEntries[0]
	$Tabs = @($Entry.tabs)
	if ($PrimaryPages.Count -eq 1 -and $PrimaryPages[0].GetAttribute('name') -eq 'SaoKeCSV' -and $Entry.page_count -eq 0) {
		$RegisterAction = @($Result.register_record_actions | Where-Object { $_.document_type -eq $DocumentType }) | Select-Object -First 1
		$FormAudit = if ($RegisterAction) { @($Result.form_audit | Where-Object { $_.screen -eq $RegisterAction.document_number }) | Select-Object -First 1 } else { $null }
		$CsvPage = $PrimaryPages[0]
		$CsvControls = @($CsvPage.SelectNodes('.//*[local-name()="InputField" or local-name()="CheckBoxField" or local-name()="RadioButtonField"]') | Where-Object {
			$Ancestor = $_.ParentNode
			$InTable = $false
			while ($null -ne $Ancestor -and $Ancestor -ne $CsvPage) {
				if ($Ancestor.LocalName -eq 'Table') { $InTable = $true; break }
				$Ancestor = $Ancestor.ParentNode
			}
			-not $InTable
		})
		$MissingCsvControls = @($CsvControls | Where-Object {
			$ControlName = [string]$_.GetAttribute('name')
			$ControlName -notin @($FormAudit.visible_field_names) -and ($ControlName + ':') -notin @($FormAudit.visible_field_names)
		})
		$CsvTable = @($FormAudit.visible_table_controls | Where-Object {
			$Bounds = @($_.bounds)
			$_.control_type -in @('ControlType.DataGrid', 'ControlType.Table') -and
			$Bounds.Count -eq 4 -and $Bounds[2] -gt 0 -and $Bounds[3] -gt 0
		})
		if ($null -eq $FormAudit -or $Entry.page_count -ne 0 -or $MissingCsvControls.Count -gt 0 -or $CsvTable.Count -ne 1) {
			$Failures.Add("$DocumentType CSV page is not exposed as the default form surface with all $($CsvControls.Count) fields and its visible transaction table.")
		} else {
			$AuditedPrimaryPageCount++
		}
	} elseif ($Entry.page_count -ne $PrimaryPages.Count -or $Tabs.Count -ne $PrimaryPages.Count) {
		$Failures.Add("$DocumentType audited $($Tabs.Count) primary tabs; metadata declares $($PrimaryPages.Count) primary pages with controls.")
	} else {
		for ($PageIndex = 0; $PageIndex -lt $PrimaryPages.Count; $PageIndex++) {
		$Page = $PrimaryPages[$PageIndex]
		$TitleNode = $Page.SelectSingleNode('./*[local-name()="Title"]//*[local-name()="content"]')
		$PageTitle = if ($TitleNode) { [string]$TitleNode.InnerText } else { [string]$Page.GetAttribute('name') }
		$Tab = @($Tabs | Where-Object { $_.name -eq $PageTitle }) | Select-Object -First 1
		$MetadataInputItems = @($Page.SelectNodes('.//*[local-name()="InputField" or local-name()="CheckBoxField" or local-name()="RadioButtonField" or local-name()="Table"]'))
		if ($null -eq $Tab) {
			$Failures.Add("$DocumentType metadata page '$PageTitle' has no matching runtime tab audit.")
			continue
		}
		$TabBounds = @($Tab.tab_bounds)
		$Details = @($Tab.visible_control_details)
		$FieldNames = @($Tab.visible_field_names)
		$MissingNames = @($Details | Where-Object { [string]$_.name -notin $FieldNames })
		$InvalidDetails = @($Details | Where-Object {
			$Bounds = @($_.bounds)
			$_.control_type -notin @('ControlType.Edit', 'ControlType.ComboBox', 'ControlType.CheckBox', 'ControlType.RadioButton', 'ControlType.DataGrid') -or
			[string]::IsNullOrWhiteSpace([string]$_.name) -or
			$Bounds.Count -ne 4 -or $Bounds[1] -lt $TabBounds[1] -or $Bounds[2] -le 0 -or $Bounds[3] -le 0
		})
		if (-not $Tab.visited -or -not $Tab.selected -or
			$TabBounds.Count -ne 4 -or $TabBounds[2] -le 0 -or $TabBounds[3] -le 0 -or
			$Tab.visible_input_count -ne $Details.Count -or $Details.Count -ne $MetadataInputItems.Count -or
			$FieldNames.Count -ne $MetadataInputItems.Count -or $MissingNames.Count -gt 0 -or $InvalidDetails.Count -gt 0) {
			$Failures.Add("$DocumentType tab '$PageTitle' did not expose all $($MetadataInputItems.Count) configured input controls with visible names and bounds.")
		}
		$AuditedPrimaryPageCount++
	}
	}

	$RegisterPage = @($RootPages | Where-Object { $_.GetAttribute('name') -eq 'RegisterRecordsTab' }) | Select-Object -First 1
	if ($null -ne $RegisterPage) {
		$ExpectedRegisterFormCount++
		$RegisterPages = @($RegisterPage.SelectNodes('./*[local-name()="ChildItems"]/*[local-name()="Pages"]/*[local-name()="ChildItems"]/*[local-name()="Page"]'))
		$ExpectedRegisterTitles = @($RegisterPages | ForEach-Object {
			$TitleNode = $_.SelectSingleNode('./*[local-name()="Title"]//*[local-name()="content"]')
			if ($TitleNode) { [string]$TitleNode.InnerText } else { [string]$_.GetAttribute('name') }
		})
		$RegisterAction = @($Result.register_record_actions | Where-Object { $_.document_type -eq $DocumentType }) | Select-Object -First 1
		if ($null -eq $RegisterAction) {
			$Failures.Add("$DocumentType has no runtime register action result.")
			continue
		}
		$ActualRegisterTitles = @($RegisterAction.register_tabs)
		$MissingRegisterTitles = @($ExpectedRegisterTitles | Where-Object { $_ -notin $ActualRegisterTitles })
		if (-not $RegisterAction.command_visible_in_more -or -not $RegisterAction.command_invoked -or -not $RegisterAction.viewer_tab_visible -or $MissingRegisterTitles.Count -gt 0) {
			$Failures.Add("$DocumentType More command did not open its register viewer with all metadata register pages: $($MissingRegisterTitles -join ', ').")
		}
	}
}

$AuditedRegisterFormCount = @($Result.register_record_actions | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_.document_type) }).Count
if ($AuditedRegisterFormCount -ne $ExpectedRegisterFormCount) {
	$Failures.Add("Runtime register audit identifies $AuditedRegisterFormCount document types; expected $ExpectedRegisterFormCount.")
}

if ($Failures.Count -gt 0) {
	throw ($Failures -join [Environment]::NewLine)
}

Write-Output ("PASS: runtime UI audited {0} primary pages and register movement viewers across {1} of {2} custom document forms." -f $AuditedPrimaryPageCount, $AuditedDocumentTypes.Count, $FormFiles.Count)
