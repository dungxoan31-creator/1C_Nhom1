[CmdletBinding()]
param(
	[string]$ResultPath
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$Configuration = Join-Path $ProjectRoot 'Configuration'
$Failures = [System.Collections.Generic.List[string]]::new()
$ChoiceRows = [System.Collections.Generic.List[object]]::new()

function Get-PropertyNode([System.Xml.XmlNode]$Node, [string]$Name) {
	return $Node.SelectSingleNode("./*[local-name()='Properties']/*[local-name()='$Name']")
}

function Get-ValueTypes([System.Xml.XmlNode]$PropertyNode) {
	if ($null -eq $PropertyNode) { return @() }
	return @($PropertyNode.SelectNodes(".//*[local-name()='Type']") | ForEach-Object { $_.InnerText })
}

$DocumentFiles = @(Get-ChildItem -LiteralPath (Join-Path $Configuration 'Documents') -Filter '*.xml' -File)
foreach ($DocumentFile in $DocumentFiles) {
	[xml]$Document = [System.IO.File]::ReadAllText($DocumentFile.FullName, [System.Text.Encoding]::UTF8)
	$HopDongAttributes = @(
		$Document.SelectNodes("//*[local-name()='Attribute']") | Where-Object {
			$NameNode = Get-PropertyNode $_ 'Name'
			$null -ne $NameNode -and $NameNode.InnerText -eq 'HopDong'
		}
	)
	foreach ($Attribute in $HopDongAttributes) {
		$TypeNode = Get-PropertyNode $Attribute 'Type'
		$TypeNames = @(Get-ValueTypes $TypeNode)
		if ($TypeNames -notcontains 'cfg:CatalogRef.HopDong') {
			$Failures.Add("$($DocumentFile.BaseName).HopDong is not a CatalogRef.HopDong field.")
			continue
		}

		$ChoiceLinksNode = Get-PropertyNode $Attribute 'ChoiceParameterLinks'
		$Links = if ($null -eq $ChoiceLinksNode) { @() } else { @($ChoiceLinksNode.SelectNodes("./*[local-name()='Link']")) }
		$PartnerLink = @($Links | Where-Object {
			$LinkName = $_.SelectSingleNode("./*[local-name()='Name']")
			$null -ne $LinkName -and $LinkName.InnerText -eq 'Filter.ChuSoHuu'
		})
		$ExpectedPath = "Document.$($DocumentFile.BaseName).Attribute.DoiTac"
		if ($PartnerLink.Count -ne 1) {
			$Failures.Add("$($DocumentFile.BaseName).HopDong must have exactly one Filter.ChuSoHuu choice link.")
			continue
		}
		$DataPath = $PartnerLink[0].SelectSingleNode("./*[local-name()='DataPath']")
		$ValueChange = $PartnerLink[0].SelectSingleNode("./*[local-name()='ValueChange']")
		if ($null -eq $DataPath -or $DataPath.InnerText -ne $ExpectedPath) {
			$Failures.Add("$($DocumentFile.BaseName).HopDong choice link must use $ExpectedPath.")
		}
		if ($null -eq $ValueChange -or $ValueChange.InnerText -ne 'Clear') {
			$Failures.Add("$($DocumentFile.BaseName).HopDong must clear its value when the partner changes.")
		}

		$FormPath = Join-Path (Join-Path $Configuration 'Documents') (Join-Path $DocumentFile.BaseName 'Forms\FormChungTu\Ext\Form.xml')
		if (-not (Test-Path -LiteralPath $FormPath)) {
			$Failures.Add("$($DocumentFile.BaseName) has no custom detail form for its linked fields.")
		}
		else {
			[xml]$Form = [System.IO.File]::ReadAllText($FormPath, [System.Text.Encoding]::UTF8)
			foreach ($FieldName in @('DoiTac', 'HopDong')) {
				$Field = $Form.SelectSingleNode("//*[local-name()='InputField' and @name='$FieldName']")
				if ($null -eq $Field) { $Failures.Add("$($DocumentFile.BaseName) detail form has no $FieldName input.") }
			}
		}

		$ChoiceRows.Add([PSCustomObject]@{
			document = $DocumentFile.BaseName
			partner_field = 'DoiTac'
			contract_field = 'HopDong'
			choice_parameter = 'Filter.ChuSoHuu'
			choice_data_path = if ($DataPath) { $DataPath.InnerText } else { '' }
			partner_change = if ($ValueChange) { $ValueChange.InnerText } else { '' }
			form_fields_present = (Test-Path -LiteralPath $FormPath)
		})
	}
}

if ($ChoiceRows.Count -ne 5) {
	$Failures.Add("Expected five document types with partner-filtered contracts, found $($ChoiceRows.Count).")
}

$ContractCatalogPath = Join-Path $Configuration 'Catalogs\HopDong.xml'
[xml]$ContractCatalog = [System.IO.File]::ReadAllText($ContractCatalogPath, [System.Text.Encoding]::UTF8)
$PartnerOwnerAttribute = @(
	$ContractCatalog.SelectNodes("//*[local-name()='Attribute']") | Where-Object {
		$NameNode = Get-PropertyNode $_ 'Name'
		$null -ne $NameNode -and $NameNode.InnerText -eq 'ChuSoHuu'
	}
)
if ($PartnerOwnerAttribute.Count -ne 1) {
	$Failures.Add('Catalog.HopDong must declare one ChuSoHuu attribute.')
}
else {
	$OwnerTypes = @(Get-ValueTypes (Get-PropertyNode $PartnerOwnerAttribute[0] 'Type'))
	if ($OwnerTypes -notcontains 'cfg:CatalogRef.DoiTac') {
		$Failures.Add('Catalog.HopDong.ChuSoHuu must reference Catalog.DoiTac.')
	}
}

$Result = [PSCustomObject]@{
	status = if ($Failures.Count -eq 0) { 'PASS' } else { 'FAIL' }
	choice_filter_count = $ChoiceRows.Count
	choice_filters = @($ChoiceRows)
	failures = @($Failures)
}
if ($ResultPath) {
	$Parent = Split-Path -Parent $ResultPath
	if (-not (Test-Path -LiteralPath $Parent)) { New-Item -ItemType Directory -Path $Parent -Force | Out-Null }
	[System.IO.File]::WriteAllText($ResultPath, ($Result | ConvertTo-Json -Depth 8), [System.Text.UTF8Encoding]::new($false))
}
if ($Failures.Count -gt 0) {
	$Failures | ForEach-Object { Write-Error $_ -ErrorAction Continue }
	Write-Output ("FAIL partner-contract choice filter metadata: {0} issue(s)." -f $Failures.Count)
	exit 1
}

Write-Output ("PASS partner-contract choice filter metadata: {0} document forms link HopDong to DoiTac and clear contract on partner change." -f $ChoiceRows.Count)
