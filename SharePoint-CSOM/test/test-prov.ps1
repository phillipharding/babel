cls
$configurationName = "Default"
$configurationPath = "C:\Dev\github\babel\SharePoint-CSOM\test"

# load and init the CSOM modules
$cwd = Split-Path -Parent $MyInvocation.MyCommand.Definition
# load and init the CSOM modules
."..\modules\load-spo-modules.ps1"

# init an empty connector
$connector = Init-CSOMConnector

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
Write-Host "Connected.`n"

$configFiles = @("taxonomy","features","columns-and-contenttypes","lists","masterpages-pagelayouts","pages","customactions","webparts-catalog","security","webs")

$configFiles | ? { $_ -eq "security" } | % {
    $configXml = Get-XMLFile "$_.xml" "$configurationPath" 

    # get configuration
    $configurationXml = $configXml.selectSingleNode("*/Configuration[@Name='$configurationName']")

    Update-Taxonomy $taxonomyXml $connection.RootWeb $connection.Context
    Update-Web -Xml $configurationXml -Site $connection.Site -Web $connection.Web -ClientContext $connection.Context

    Write-Host
    Get-CustomAction -Site $connection.Site -ClientContext $connection.Context | % { Write-Host "Name: $($_.Name)`nLocation: $($_.Location)`nSequence: $($_.Sequence)`n" }
}

"Done."