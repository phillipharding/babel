cls
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

# load XML datasets file
$configXml = Get-XMLFile "site-columns.xml" "C:\Dev\github\babel\SharePoint-CSOM\test" 

# get datasets
$modulesXml = $configXml.SelectSingleNode("*/Modules")
$siteFeaturesXml = $configXml.SelectSingleNode("*/SiteFeatures")
$removeSiteFeaturesXml = $configXml.SelectSingleNode("*/RemoveSiteFeatures")
$webFeaturesXml = $configXml.SelectSingleNode("*/WebFeatures")
$removeWebFeaturesXml = $configXml.SelectSingleNode("*/RemoveWebFeatures")
$taxonomyXml = $configXml.SelectSingleNode("*/TermStore")
$fieldsXml = $configXml.SelectSingleNode("*/Fields")
$contentTypesXml = $configXml.SelectSingleNode("*/ContentTypes")
$listsXml = $configXml.SelectSingleNode("*/Lists")

Update-Taxonomy $taxonomyXml $connection.RootWeb $connection.Context

Remove-Features -FeaturesXml $removeSiteFeaturesXml -site $connection.Site -ClientContext $connection.Context
Add-Features -FeaturesXml $siteFeaturesXml -site $connection.Site -ClientContext $connection.Context

Remove-Features -FeaturesXml $removeWebFeaturesXml -web $connection.Web -ClientContext $connection.Context
Add-Features -FeaturesXml $webFeaturesXml -web $connection.Web -ClientContext $connection.Context

Remove-ContentTypes $contentTypesXml $connection.RootWeb $connection.Context
Remove-SiteColumns $fieldsXml $connection.RootWeb $connection.Context

Update-SiteColumns $fieldsXml $connection.RootWeb $connection.Context
Update-ContentTypes $contentTypesXml $connection.RootWeb $connection.Context

Update-Lists $listsXml $connection.Site $connection.Web $connection.Context
Update-Folders $modulesXml $connection.Site $connection.Web $connection.Context


