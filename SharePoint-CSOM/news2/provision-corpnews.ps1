<#
    Example command lines

    .\provision-corpnews.ps1 -URL "https://rbcom.sharepoint.com/sites/dev-pah" -CredentialLabel "RB.COM SPO" -Configuration "0"
    .\provision-corpnews.ps1 -URL "https://platinumdogsconsulting.sharepoint.com/sites/publishing" -CredentialLabel "SPO" -Configuration "0"
    .\provision-corpnews.ps1 -URL "http://pub.pdogs.local/" -CredentialLabel "OnPrem" -Configuration "1"


    -Configuration;
        "0" for provisioning to SPO w/Buzz365 Masterpage
        "1" for provisioning to On-Prem wo/Masterpage or with Dev Masterpage
        "2" for Global Corporate News webpart
        "99" for Dev Debugging
#>
param (
    [parameter(Mandatory=$false)][string]$URL = $null,
    [parameter(Mandatory=$false)][string]$CredentialLabel = $null,
    [parameter(Mandatory=$false)][string]$Configuration = "0"
)
cls
# load and init the CSOM modules
."..\modules\load-spo-modules.ps1"

$cwd = Split-Path -Parent $MyInvocation.MyCommand.Definition

# init an empty connector
$connector = Init-CSOMConnector

if (($URL -ne $null -and $URL -ne "") -and ($CredentialLabel -ne $null -and $CredentialLabel -ne "")) {
    $connector.csomUrl = $URL
    $connector.csomCredentialLabel = $CredentialLabel
} else {
    # set connection url, set credentials using Windows Credential Manager
}

# connect...
$connection = Get-CSOMConnection $connector
if (-not $connection.HasConnection) { return }
Write-Host "Connected.`n"

$configurationPath = $cwd       #"C:\Dev\github\babel\SharePoint-CSOM\news2"
$configurationName = "News"
$configurationId = $Configuration
$configurationFiles = @("corpnews")

$configurationFiles | ? { $_ -match ".*" } | % {
    $configXml = Get-XMLFile "$_.xml" "$configurationPath" 

    # get configuration
    $configurationXml = $configXml.selectSingleNode("*/Configuration[@Name='$configurationName' and @ID='$configurationId']")
    if ($configurationXml -eq $null) {
        Write-Host "Could not find configuration [$configurationName#$configurationId]`n" -ForegroundColor Red
        return
    }
    Write-Host "Applying Configuration [$configurationName#$configurationId] from '$configurationPath\$_.xml'`n$($configurationXml.Description) `n" -ForegroundColor Yellow
    Write-Host "Press any key to continue..." -ForegroundColor Yellow
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")

    if (-not (($x.VirtualKeyCode -eq 17) -and ($x.ControlKeyState -match "LeftCtrlPressed"))) {
        Update-Taxonomy $taxonomyXml $connection.RootWeb $connection.Context
        Update-Web -Xml $configurationXml -Site $connection.Site -Web $connection.Web -ClientContext $connection.Context
    }
}
"Done."