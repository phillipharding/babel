cls

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
#$connector.csomUrl = "http://pub.pdogs.local/"
#$connector.csomCredentialLabel = "OnPrem"

# create an array of connector objects using the csomUrl and csomCredentialLabel properties
$connections = @(  @{ csomUrl="http://pub.pdogs.local/"; csomCredentialLabel="OnPrem" }, 
                                    @{ csomUrl="https://platinumdogsconsulting.sharepoint.com/sites/publishing"; csomCredentialLabel="SPO" }
                                 )
# iterate the connectors and connect to each...
$connections | % {
    $connection = $null
    $connection = Get-CSOMConnection $_
    if (-not $connection.HasConnection) { continue }
    Write-Host "Connected.`n"

    $web = $connection.SIte.OpenWeb("news")
    $connection.Context.Load($web)
    $connection.Context.ExecuteQuery()

    $version = Get-WebVersion -Web $connection.Web -ClientContext $connection.Context
    $wversion = Get-WebVersion -Web $web -ClientContext $connection.Context

    Write-Host "The Web at [$($Web.Url)] is version [$wversion] "
    Write-Host "The Web at [$($connection.Web.Url)] is version [$version]`n"
}
