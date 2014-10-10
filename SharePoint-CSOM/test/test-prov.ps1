cls
$configurationName = "Default"
$scriptPath = Split-Path -Parent  $MyInvocation.MyCommand.Definition

# load and init the CSOM helpers
."$scriptPath\load-spo-helpers.ps1"
cls

Add-CSOM
Add-TenantCSOM

# init connector
$connector = Init-CSOMConnection
$connector.csomUrl = "https://platinumdogsconsulting.sharepoint.com/sites/publishing"
#$connector.csomUrl = "http://pub.pdogs.local"
$connector.csomUsername = "phil.harding@platinumdogsconsulting.onmicrosoft.com"
$connector.csomPassword = "Pa`$`$w0rd2"
#$connector.csomCredentials = (Get-Credential | Out-Null)

$connection = Get-CSOMConnection $connector
if (-not $connection.HasConnection) { return }
Write-Host

# load XML datasets file
#$configXml = Get-XMLFile "taxonomy.xml" "C:\Dev\github\babel\SharePoint-CSOM\test" 
#$configXml = Get-XMLFile "features.xml" "C:\Dev\github\babel\SharePoint-CSOM\test" 
#$configXml = Get-XMLFile "columns-and-contenttypes.xml" "C:\Dev\github\babel\SharePoint-CSOM\test" 
#$configXml = Get-XMLFile "lists.xml" "C:\Dev\github\babel\SharePoint-CSOM\test" 
#$configXml = Get-XMLFile "masterpages-pagelayouts.xml" "C:\Dev\github\babel\SharePoint-CSOM\test" 

$configFiles = @("taxonomy.xml","features.xml","columns-and-contenttypes.xml","lists.xml","masterpages-pagelayouts.xml")
$configFiles | ? { $_ -eq "lists.xml" } | % {
    $configXml = Get-XMLFile $_ "C:\Dev\github\babel\SharePoint-CSOM\test" 

    # get configuration
    $configurationXml = $configXml.selectSingleNode("*/Configuration[@Name='$configurationName']")

    # get configuration datasets
    $pagesXml = $configurationXml.Pages
    $siteFeaturesXml = $configurationXml.Features.SiteFeatures.ActivateFeatures
    $removeSiteFeaturesXml = $configurationXml.Features.SiteFeatures.DeactivateFeatures
    $webFeaturesXml = $configurationXml.Features.WebFeatures.ActivateFeatures
    $removeWebFeaturesXml = $configurationXml.Features.WebFeatures.DeactivateFeatures
    $taxonomyXml = $configurationXml.TermStore
    $fieldsXml = $configurationXml.Fields
    $contentTypesXml = $configurationXml.ContentTypes
    $listsXml = $configurationXml.Lists
    $catalogsXml = $configurationXml.Catalogs

    Update-Taxonomy $taxonomyXml $connection.RootWeb $connection.Context

    Remove-Lists  $listsXml $connection.Site $connection.Web $connection.Context
    Remove-ContentTypes $contentTypesXml $connection.RootWeb $connection.Context
    Remove-SiteColumns $fieldsXml $connection.RootWeb $connection.Context
    Remove-Features -FeaturesXml $removeSiteFeaturesXml -site $connection.Site -ClientContext $connection.Context
    Remove-Features -FeaturesXml $removeWebFeaturesXml -web $connection.Web -ClientContext $connection.Context

    Add-Features -FeaturesXml $siteFeaturesXml -site $connection.Site -ClientContext $connection.Context
    Add-Features -FeaturesXml $webFeaturesXml -web $connection.Web -ClientContext $connection.Context
    Update-SiteColumns $fieldsXml $connection.RootWeb $connection.Context
    Update-ContentTypes $contentTypesXml $connection.RootWeb $connection.Context
    Update-Catalogs $catalogsXml $connection.Site $connection.Web $connection.Context
    Update-Lists $listsXml $connection.Site $connection.Web $connection.Context

    Write-Host
}

