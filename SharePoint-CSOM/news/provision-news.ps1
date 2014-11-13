cls
$configurationName = "News"
$configurationId = "1"
$configurationPath = "C:\Dev\github\babel\SharePoint-CSOM\news"

# load and init the CSOM modules
."..\modules\load-spo-modules.ps1"

# init an empty connector
$connector = Init-CSOMConnector

# set connection url, set credentials using Windows Credential Manager
#$connector.csomUrl = "https://camconsultancyltd.sharepoint.com"
#$connector.csomCredentialLabel = "CAM SPO"
#$connector.csomUrl = "https://rbcom.sharepoint.com/sites/dev-pah"
#$connector.csomCredentialLabel = "RB.COM SPO"
#$connector.csomUrl = "https://platinumdogsconsulting.sharepoint.com/sites/publishing"
#$connector.csomCredentialLabel = "SPO"
$connector.csomUrl = "http://pub.pdogs.local/"
$connector.csomCredentialLabel = "OnPrem"

# connect...
$connection = Get-CSOMConnection $connector
if (-not $connection.HasConnection) { return }
Write-Host "Connected.`n"

$configFiles = @("news")
$configFiles | ? { $_ -eq "news" } | % {
    $configXml = Get-XMLFile "$_.xml" "$configurationPath" 

    # get configuration
    $configurationXml = $configXml.selectSingleNode("*/Configuration[@Name='$configurationName' and @ID='$configurationId']")
    if ($configurationXml -eq $null) {
        Write-Host "Could not find configuration $configurationName#$configurationId`n" -ForegroundColor Red
        return
    }
    Write-Host "Applying Configuration $configurationName#$configurationId - $($configurationXml.Description)`n" -ForegroundColor Yellow
    
    Update-Taxonomy $taxonomyXml $connection.RootWeb $connection.Context
    Update-Web -Xml $configurationXml -Site $connection.Site -Web $connection.Web -ClientContext $connection.Context

}
"Done."