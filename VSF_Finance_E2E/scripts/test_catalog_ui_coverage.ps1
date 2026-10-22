[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$UIScriptPath = Join-Path $PSScriptRoot 'run_finance_ui_e2e.ps1'
$RunnerPath = Join-Path $PSScriptRoot 'run_finance_e2e.ps1'
$UISource = [System.IO.File]::ReadAllText($UIScriptPath, [System.Text.Encoding]::UTF8)
$RunnerSource = [System.IO.File]::ReadAllText($RunnerPath, [System.Text.Encoding]::UTF8)
$CommandInterfacePath = Join-Path $ProjectRoot 'Configuration\Ext\MainSectionCommandInterface.xml'
$CommandInterfaceSource = [System.IO.File]::ReadAllText($CommandInterfacePath, [System.Text.Encoding]::UTF8)
$CatalogFiles = @(Get-ChildItem -Path (Join-Path $ProjectRoot 'Configuration\Catalogs') -Filter '*.xml' -File)
$Failures = [System.Collections.Generic.List[string]]::new()

if ($CatalogFiles.Count -ne 9) { $Failures.Add("Expected nine catalog metadata objects, found $($CatalogFiles.Count).") }
if ($UISource -notmatch "CatalogSmoke") { $Failures.Add('UI automation has no CatalogSmoke workflow.') }
if ($UISource -notmatch 'catalog_screens') { $Failures.Add('CatalogSmoke does not return catalog screen evidence.') }
if ($UISource -notmatch 'create_form_opened') { $Failures.Add('CatalogSmoke does not exercise the standard Create command.') }
if ($UISource -notmatch 'copy_form_opened') { $Failures.Add('CatalogSmoke does not exercise the standard Copy command.') }
if ($RunnerSource -notmatch 'Invoke-FinanceCatalogUI') { $Failures.Add('Full E2E runner does not invoke catalog UI coverage.') }
if ($RunnerSource -notmatch 'catalog_list_ui_e2e') { $Failures.Add('Full E2E summary omits catalog list UI results.') }
foreach ($CatalogFile in $CatalogFiles) {
	if ($UISource -notmatch [regex]::Escape($CatalogFile.BaseName)) {
		$Failures.Add("CatalogSmoke has no case for $($CatalogFile.BaseName).")
	}
	$CommandName = 'Catalog.' + $CatalogFile.BaseName + '.StandardCommand.OpenList'
	$CommandCount = [regex]::Matches($CommandInterfaceSource, [regex]::Escape($CommandName)).Count
	if ($CommandCount -lt 3) {
		$Failures.Add("$CommandName must be declared in visibility, placement, and order; found $CommandCount declaration(s).")
	}
}

if ($Failures.Count -gt 0) {
	$Failures | ForEach-Object { Write-Error $_ -ErrorAction Continue }
	Write-Output ("FAIL catalog UI coverage contract: {0} issue(s)." -f $Failures.Count)
	exit 1
}
Write-Output ("PASS catalog UI coverage contract: all {0} metadata catalogs are included." -f $CatalogFiles.Count)
