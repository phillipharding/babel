cls
$configurationName = "News"
$configurationPath = "C:\Dev\github\babel\SharePoint-CSOM\news"

# load and init the CSOM modules
$modulesPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
."..\test\load-spo-modules.ps1"
cls
Add-CSOM
Add-TenantCSOM

# init an empty connector
$connector = Init-CSOMConnection

# set connection url, set credentials using Windows Credential Manager
$connector.csomUrl = "https://platinumdogsconsulting.sharepoint.com/sites/publishing"
$connector.csomCredentialLabel = "SPO"

# connect...
$connection = Get-CSOMConnection $connector
if (-not $connection.HasConnection) { return }
Write-Host "Connected.`n"

$configFiles = @("news")
$configFiles | ? { $_ -eq "news" } | % {
    $configXml = Get-XMLFile "$_.xml" "$configurationPath" 

    # get configuration
    $configurationXml = $configXml.selectSingleNode("*/Configuration[@Name='$configurationName']")

    Update-Taxonomy $taxonomyXml $connection.RootWeb $connection.Context
    Update-Web -Xml $configurationXml -Site $connection.Site -Web $connection.Web -ClientContext $connection.Context

    Write-Host
    Get-CustomAction -Site $connection.Site -ClientContext $connection.Context | % { Write-Host "Name: $($_.Name)`nLocation: $($_.Location)`nSequence: $($_.Sequence)`n" }
}

"Done."