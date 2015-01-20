<#
    Example command lines

    .\provision-megamenu.ps1 -URL "https://rbcom.sharepoint.com/" -CredentialLabel "RB.COM SPO" -Configuration "0"
    .\provision-megamenu.ps1 -URL "https://platinumdogsconsulting.sharepoint.com/" -CredentialLabel "SPO" -Configuration "0"
    .\provision-megamenu.ps1 -URL "http://pub.pdogs.local/" -CredentialLabel "OnPrem" -Configuration "0"


    -Configuration;
        "0" for provisioning Taxonomy Termset

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

$configurationPath = $cwd
$configurationName = "MegaMenu"
$configurationId = $Configuration
$configurationFiles = @("megamenu")

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
        Update-Taxonomy $configurationXml.TermStore $connection.RootWeb $connection.Context
        Update-Web -Xml $configurationXml -Site $connection.Site -Web $connection.Web -ClientContext $connection.Context
    }
}
"Done."