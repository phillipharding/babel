cls
$configurationName = "Default"
$configurationPath = "C:\Dev\github\babel\SharePoint-CSOM\test"
$scriptPath = Split-Path -Parent  $MyInvocation.MyCommand.Definition

# load and init the CSOM helpers
."$scriptPath\load-spo-helpers.ps1"
cls
Add-CSOM
Add-TenantCSOM

# init a blank connector
$connector = Init-CSOMConnection

# set connection url
$connector.csomUrl = "https://platinumdogsconsulting.sharepoint.com/sites/publishing"
#$connector.csomUrl = "http://pub.pdogs.local"

# set credentials with username/password
$connector.csomUsername = ""
$connector.csomPassword = ""

# set credentials using Windows Credential Manager
$connector.csomCredentialLabel = "SPO"

# set credentials with Get-Credentials (prompts for creds)
#$connector.csomCredentials = (Get-Credential | Out-Null)

# connect...
$connection = Get-CSOMConnection $connector
if (-not $connection.HasConnection) { return }
Write-Host

$configFiles = @("taxonomy","features","columns-and-contenttypes","lists","masterpages-pagelayouts","pages","customactions")

$configFiles | ? { $_ -eq "customactions" } | % {
    $configXml = Get-XMLFile "$_.xml" "$configurationPath" 

    # get configuration
    $configurationXml = $configXml.selectSingleNode("*/Configuration[@Name='$configurationName']")

    # get configuration datasets
    $customActionsXml = $configurationXml.CustomActions
    $removeCustomActionsXml = $configurationXml.RemoveCustomActions
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

    Remove-PublishingPages $pagesXml $connection.Site $connection.Web $connection.Context
    Remove-Lists  $listsXml $connection.Site $connection.Web $connection.Context
    Remove-ContentTypes $contentTypesXml $connection.RootWeb $connection.Context
    Remove-SiteColumns $fieldsXml $connection.RootWeb $connection.Context
    Remove-Features -FeaturesXml $removeWebFeaturesXml -web $connection.Web -ClientContext $connection.Context
    Remove-Features -FeaturesXml $removeSiteFeaturesXml -site $connection.Site -ClientContext $connection.Context

    Add-Features -FeaturesXml $siteFeaturesXml -site $connection.Site -ClientContext $connection.Context
    Add-Features -FeaturesXml $webFeaturesXml -web $connection.Web -ClientContext $connection.Context
    Update-SiteColumns $fieldsXml $connection.RootWeb $connection.Context
    Update-ContentTypes $contentTypesXml $connection.RootWeb $connection.Context
    Update-Catalogs $catalogsXml $connection.Site $connection.Web $connection.Context
    Update-Lists $listsXml $connection.Site $connection.Web $connection.Context
    Update-PublishingPages  $pagesXml $connection.Site $connection.Web $connection.Context
    Add-CustomActions $customActionsXml $connection.Site $connection.Web $connection.Context

    Write-Host
}

