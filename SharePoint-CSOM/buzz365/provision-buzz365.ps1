cls
# load and init the CSOM modules
."..\modules\load-spo-modules.ps1"

# init an empty connector
$connector = Init-CSOMConnector

# set connection url, set credentials using Windows Credential Manager
#$connector.csomUrl = "https://camconsultancyltd.sharepoint.com"
#$connector.csomCredentialLabel = "CAM SPO"
$connector.csomUrl = "https://rbcom.sharepoint.com/sites/dev-pah"
$connector.csomCredentialLabel = "RB.COM SPO"
#$connector.csomUrl = "https://platinumdogsconsulting.sharepoint.com/sites/publishing"
#$connector.csomCredentialLabel = "SPO"
#$connector.csomUrl = "http://pub.pdogs.local/"
#$connector.csomCredentialLabel = "OnPrem"

# connect...
$connection = Get-CSOMConnection $connector
if (-not $connection.HasConnection) { return }
Write-Host "Connected.`n"

$configurationName = "Masterpage"
$configurationId = "1" # use 1 for the full provisioning and 0 for minimal provisioning
$configurationPath = "C:\Dev\github\babel\SharePoint-CSOM\buzz365"
$configurationFiles = @("buzz365")

$configurationFiles | ? { $_ -match ".*" } | % {
    $configXml = Get-XMLFile "$_.xml" "$configurationPath" 

    # get configuration
    $configurationXml = $configXml.selectSingleNode("*/Configuration[@Name='$configurationName' and @ID='$configurationId']")
    if ($configurationXml -eq $null) {
        Write-Host "Could not find configuration [$configurationName#$configurationId]`n" -ForegroundColor Red
        return
    }
    Write-Host "Applying Configuration [$configurationName#$configurationId]`n$($configurationXml.Description)`n" -ForegroundColor Yellow
    Write-Host "Press any key to continue..." -ForegroundColor Yellow
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")

    if (-not (($x.VirtualKeyCode -eq 17) -and ($x.ControlKeyState -match "LeftCtrlPressed"))) {
        Update-Taxonomy $taxonomyXml $connection.RootWeb $connection.Context
        Update-Web -Xml $configurationXml -Site $connection.Site -Web $connection.Web -ClientContext $connection.Context
    }
}
"Done."