[CmdletBinding()]
param(
	[Parameter(Mandatory = $true)][string]$RuntimeMatrixPath,
	[Parameter(Mandatory = $true)][string]$UIResultPath,
	[Parameter(Mandatory = $true)][string]$OutputPath,
	[string]$ConfigurationPath
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($ConfigurationPath)) {
	$ConfigurationPath = Join-Path $ProjectRoot 'Configuration'
}
foreach ($Path in @($RuntimeMatrixPath, $UIResultPath, $ConfigurationPath)) {
	if (-not (Test-Path -LiteralPath $Path)) { throw "Required inventory input was not found: $Path" }
}

$Runtime = Get-Content -LiteralPath $RuntimeMatrixPath -Raw -Encoding UTF8 | ConvertFrom-Json
$UI = Get-Content -LiteralPath $UIResultPath -Raw -Encoding UTF8 | ConvertFrom-Json
if ($Runtime.status -ne 'PASS' -or $Runtime.data.status -ne 'PASS') { throw 'Runtime field matrix is not PASS.' }
if ($UI.status -ne 'PASS') { throw 'Runtime document form audit is not PASS.' }

$RuntimeCases = @($Runtime.data.cases)
$AutoCases = @($Runtime.data.auto_cases)
$FieldProbeCases = @($Runtime.data.field_probe_cases)
$BoundaryCases = @($Runtime.data.boundary_cases) + @($Runtime.data.ap_boundary_cases)
$Rows = [System.Collections.Generic.List[object]]::new()
$AllPageDetails = [System.Collections.Generic.List[object]]::new()
$FormAuditFailures = [System.Collections.Generic.List[string]]::new()
$MetadataDocuments = @(Get-ChildItem -LiteralPath (Join-Path $ConfigurationPath 'Documents') -File -Filter '*.xml')
$CustomFormCount = 0

foreach ($DocumentFile in $MetadataDocuments) {
	[xml]$DocumentXml = [System.IO.File]::ReadAllText($DocumentFile.FullName, [System.Text.Encoding]::UTF8)
	$Attributes = @($DocumentXml.SelectNodes('//*[local-name()="ChildObjects"]/*[local-name()="Attribute"]'))
	$FormPath = Join-Path $ConfigurationPath (Join-Path (Join-Path (Join-Path (Join-Path 'Documents' $DocumentFile.BaseName) 'Forms') 'FormChungTu') 'Ext\Form.xml')
	$FormBindings = @{}
	$PageDetails = @()
	$FormAudit = @($UI.form_tab_audit | Where-Object { $_.document_type -eq $DocumentFile.BaseName }) | Select-Object -First 1

	if (Test-Path -LiteralPath $FormPath) {
		$CustomFormCount++
		[xml]$FormXml = [System.IO.File]::ReadAllText($FormPath, [System.Text.Encoding]::UTF8)
		$RootPages = @($FormXml.SelectNodes('/*[local-name()="Form"]/*[local-name()="ChildItems"]/*[local-name()="Pages"]/*[local-name()="ChildItems"]/*[local-name()="Page"]'))
		$Pages = @($RootPages | Where-Object {
			$_.GetAttribute('name') -ne 'RegisterRecordsTab' -and
			@($_.SelectNodes('.//*[local-name()="InputField" or local-name()="CheckBoxField" or local-name()="RadioButtonField" or local-name()="Table"]')).Count -gt 0
		})
		$RegisterAction = @($UI.register_record_actions | Where-Object { $_.document_type -eq $DocumentFile.BaseName }) | Select-Object -First 1
		$DocumentFormAudit = if ($RegisterAction) { @($UI.form_audit | Where-Object { $_.screen -eq $RegisterAction.document_number }) | Select-Object -First 1 } else { $null }
		foreach ($Page in $Pages) {
			$PageTitleNode = $Page.SelectSingleNode('./*[local-name()="Title"]//*[local-name()="content"]')
			$PageTitle = if ($PageTitleNode) { $PageTitleNode.InnerText } else { [string]$Page.GetAttribute('name') }
			$InputNodes = @($Page.SelectNodes('.//*[local-name()="InputField" or local-name()="CheckBoxField" or local-name()="RadioButtonField" or local-name()="Table"]'))
			$TabAudit = if ($FormAudit) { @($FormAudit.tabs | Where-Object { $_.name -eq $PageTitle }) | Select-Object -First 1 } else { $null }
			$RuntimeInputCount = if ($TabAudit) { @($TabAudit.visible_control_details).Count } else { 0 }
			$PageVisited = $false
			if ($Page.GetAttribute('name') -eq 'SaoKeCSV') {
				$CsvInputNodes = @($Page.SelectNodes('.//*[local-name()="InputField" or local-name()="CheckBoxField" or local-name()="RadioButtonField"]') | Where-Object {
					$Ancestor = $_.ParentNode
					$InTable = $false
					while ($null -ne $Ancestor -and $Ancestor -ne $Page) {
						if ($Ancestor.LocalName -eq 'Table') { $InTable = $true; break }
						$Ancestor = $Ancestor.ParentNode
					}
					-not $InTable
				})
				$VisibleNames = @($DocumentFormAudit.visible_field_names)
				$MissingCsvControls = @($CsvInputNodes | Where-Object {
					$ControlName = [string]$_.GetAttribute('name')
					$ControlName -notin $VisibleNames -and ($ControlName + ':') -notin $VisibleNames
				})
				$VisibleCsvTables = @($DocumentFormAudit.visible_table_controls | Where-Object {
					$Bounds = @($_.bounds)
					$_.control_type -in @('ControlType.DataGrid', 'ControlType.Table') -and $Bounds.Count -eq 4 -and $Bounds[2] -gt 0 -and $Bounds[3] -gt 0
				})
				$PageVisited = $null -ne $DocumentFormAudit -and $MissingCsvControls.Count -eq 0 -and $VisibleCsvTables.Count -eq 1
				$RuntimeInputCount = $CsvInputNodes.Count + $VisibleCsvTables.Count
				if (-not $PageVisited) {
					$FormAuditFailures.Add("$($DocumentFile.BaseName) page '$PageTitle' did not expose all CSV inputs and its transaction table in the runtime form.")
				}
			} else {
				$PageVisited = $null -ne $TabAudit -and $TabAudit.visited -and $TabAudit.selected -and @($TabAudit.visible_control_details).Count -eq $InputNodes.Count
				if (-not $PageVisited) {
					$FormAuditFailures.Add("$($DocumentFile.BaseName) page '$PageTitle' has no matching runtime tab audit or the visible control count differs from metadata.")
				}
			}
			$PageAuditDetail = [PSCustomObject]@{
				name = $PageTitle
				metadata_input_count = $InputNodes.Count
				runtime_input_count = $RuntimeInputCount
				visited = [bool]$PageVisited
			}
			$PageDetails += $PageAuditDetail
			$AllPageDetails.Add($PageAuditDetail)
			foreach ($InputNode in $InputNodes) {
				$DataPathNode = $InputNode.SelectSingleNode('./*[local-name()="DataPath"]')
				if ($null -eq $DataPathNode) { continue }
				$DataPath = [string]$DataPathNode.InnerText
				if ($DataPath -notmatch '^Object\.') { continue }
				$AttributeName = (($DataPath -replace '^Object\.', '').Split('.')[0])
				$Binding = [PSCustomObject]@{
					control_name = [string]$InputNode.GetAttribute('name')
					control_type = [string]$InputNode.LocalName
					data_path = $DataPath
					page = $PageTitle
					read_only = [bool]($InputNode.SelectSingleNode('./*[local-name()="ReadOnly"]') -and $InputNode.SelectSingleNode('./*[local-name()="ReadOnly"]').InnerText -eq 'true')
				}
				if (-not $FormBindings.ContainsKey($AttributeName)) { $FormBindings[$AttributeName] = [System.Collections.Generic.List[object]]::new() }
				$FormBindings[$AttributeName].Add($Binding)
			}
		}
	} elseif ($null -ne $FormAudit -and $FormAudit.page_count -gt 0) {
		$FormAuditFailures.Add("$($DocumentFile.BaseName) runtime tab audit exists but no FormChungTu metadata file was found.")
	}

	foreach ($Attribute in $Attributes) {
		$Properties = $Attribute.SelectSingleNode('./*[local-name()="Properties"]')
		$NameNode = $Properties.SelectSingleNode('./*[local-name()="Name"]')
		if ($null -eq $NameNode) { continue }
		$FieldName = [string]$NameNode.InnerText
		$FillNode = $Properties.SelectSingleNode('./*[local-name()="FillChecking"]')
		$TypeNames = @($Properties.SelectNodes('./*[local-name()="Type"]/*[local-name()="Type"]') | ForEach-Object { $_.InnerText })
		$RequiredCase = @($RuntimeCases | Where-Object { $_.document_type -eq $DocumentFile.BaseName -and $_.field -eq $FieldName })
		$AutoCase = @($AutoCases | Where-Object { $_.document_type -eq $DocumentFile.BaseName -and $_.field -eq $FieldName })
		$FieldProbeCase = @($FieldProbeCases | Where-Object { $_.document_type -eq $DocumentFile.BaseName -and $_.field -eq $FieldName })
		$DirectBoundaryCases = @($BoundaryCases | Where-Object {
			$Parts = ([string]$_.key).Split('|')
			$Parts.Count -ge 2 -and $Parts[0] -eq $DocumentFile.BaseName -and $Parts[1] -eq $FieldName
		})
		$Bindings = if ($FormBindings.ContainsKey($FieldName)) { @($FormBindings[$FieldName].ToArray()) } else { @() }
		$RuntimeClassification = if ($RequiredCase.Count -gt 0) { 'required-empty-write' } elseif ($AutoCase.Count -gt 0) { 'system-autofill-or-calculation' } elseif ($DirectBoundaryCases.Count -gt 0 -and $FieldProbeCase.Count -gt 0) { 'field-boundary-and-roundtrip' } elseif ($DirectBoundaryCases.Count -gt 0) { 'field-boundary' } elseif ($FieldProbeCase.Count -gt 0) { 'field-write-readback' } else { 'no-dedicated-field-case' }
		$Rows.Add([PSCustomObject]@{
			document = $DocumentFile.BaseName
			field = $FieldName
			types = $TypeNames -join '|'
			fill_checking = if ($FillNode) { $FillNode.InnerText } else { '' }
			is_metadata_required = [bool]($FillNode -and $FillNode.InnerText -eq 'ShowError')
			runtime_classification = $RuntimeClassification
			required_write_cases = $RequiredCase.Count
			autofill_cases = $AutoCase.Count
			field_probe_cases = $FieldProbeCase.Count
		direct_boundary_cases = $DirectBoundaryCases.Count
			custom_form_binding_count = @($Bindings).Count
			custom_form_pages = (@($Bindings | ForEach-Object { $_.page } | Select-Object -Unique) -join '; ')
			custom_form_read_only = [bool](@($Bindings | Where-Object read_only).Count -gt 0)
			custom_form_tab_audited = [bool](@($PageDetails | Where-Object { $_.name -in @($Bindings | ForEach-Object { $_.page }) -and $_.visited }).Count -gt 0)
		})
	}
}

$ExpectedUserRequired = @($Rows | Where-Object { $_.is_metadata_required -and $_.runtime_classification -eq 'required-empty-write' }).Count
$ExpectedSystemManaged = @($Rows | Where-Object { $_.is_metadata_required -and $_.runtime_classification -eq 'system-autofill-or-calculation' }).Count
$ExpectedFieldProbes = @($Rows | Where-Object { $_.field_probe_cases -gt 0 }).Count
$UncoveredMetadataRequired = @($Rows | Where-Object { $_.is_metadata_required -and $_.runtime_classification -notin @('required-empty-write', 'system-autofill-or-calculation') })
$UncoveredAttributes = @($Rows | Where-Object { $_.runtime_classification -eq 'no-dedicated-field-case' })
$OutputDirectory = Split-Path -Parent $OutputPath
if (-not (Test-Path -LiteralPath $OutputDirectory)) { New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null }
$Rows | Sort-Object document, field | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding UTF8

$Summary = [ordered]@{
	status = if ($FormAuditFailures.Count -eq 0 -and $UncoveredMetadataRequired.Count -eq 0 -and $UncoveredAttributes.Count -eq 0 -and $ExpectedUserRequired -eq 41 -and $ExpectedSystemManaged -eq 7 -and $ExpectedFieldProbes -eq 79) { 'PASS' } else { 'FAIL' }
	document_count = @($MetadataDocuments).Count
	attribute_count = $Rows.Count
	show_error_attribute_count = @($Rows | Where-Object is_metadata_required).Count
	runtime_required_write_count = $ExpectedUserRequired
	runtime_system_managed_count = $ExpectedSystemManaged
	runtime_field_probe_count = $ExpectedFieldProbes
	attributes_without_dedicated_field_case = $UncoveredAttributes.Count
	attributes_with_runtime_classification = $Rows.Count - $UncoveredAttributes.Count
	custom_form_count = $CustomFormCount
	custom_form_page_audit_count = @($AllPageDetails | Where-Object visited).Count
	form_audit_failures = $FormAuditFailures.ToArray()
	uncovered_metadata_required_fields = @($UncoveredMetadataRequired | ForEach-Object { $_.document + '.' + $_.field })
	output_csv = [System.IO.Path]::GetFullPath($OutputPath)
}
$SummaryPath = [System.IO.Path]::ChangeExtension($OutputPath, '.summary.json')
[System.IO.File]::WriteAllText($SummaryPath, ($Summary | ConvertTo-Json -Depth 8), [System.Text.UTF8Encoding]::new($false))
$Summary | ConvertTo-Json -Depth 8
if ($Summary.status -ne 'PASS') { exit 1 }
