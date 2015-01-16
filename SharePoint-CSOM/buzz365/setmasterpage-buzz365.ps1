<#
    Example command lines

    .\setmasterpage-buzz365.ps1 -URL "https://rbcom.sharepoint.com/sites/O365" -CredentialLabel "RB.COM SPO" -Configuration "0"
    .\setmasterpage-buzz365.ps1 -URL "https://rbcom.sharepoint.com/sites/cccdev1" -CredentialLabel "RB.COM SPO" -Configuration "0"
    .\setmasterpage-buzz365.ps1 -URL "https://rbcom.sharepoint.com/sites/dev-pah/news" -CredentialLabel "RB.COM SPO" -Configuration "0"
    .\setmasterpage-buzz365.ps1 -URL "https://rbcom.sharepoint.com/sites/dev-pah/corpcomms" -CredentialLabel "RB.COM SPO" -Configuration "0"
    .\setmasterpage-buzz365.ps1 -URL "https://rbcom.sharepoint.com/sites/dev-pah" -CredentialLabel "RB.COM SPO" -Configuration "0"
    .\setmasterpage-buzz365.ps1 -URL "https://rbcom.sharepoint.com/" -CredentialLabel "RB.COM SPO" -Configuration "0"

    .\setmasterpage-buzz365.ps1 -URL "https://platinumdogsconsulting.sharepoint.com/sites/publishing/corpcomms" -CredentialLabel "SPO" -Configuration "0"
    .\setmasterpage-buzz365.ps1 -URL "https://platinumdogsconsulting.sharepoint.com/sites/publishing/news" -CredentialLabel "SPO" -Configuration "0"
    .\setmasterpage-buzz365.ps1 -URL "https://platinumdogsconsulting.sharepoint.com/sites/publishing" -CredentialLabel "SPO" -Configuration "0"
    .\setmasterpage-buzz365.ps1 -URL "https://platinumdogsconsulting.sharepoint.com/" -CredentialLabel "SPO" -Configuration "0"

    -Configuration;
        "0" for V1 masterpage
        "1" for V2 masterpage
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

$configurationName = "SetMasterpage"
$configurationId = $Configuration
$configurationPath = $cwd
$configurationFiles = @("setmasterpage-buzz365")

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