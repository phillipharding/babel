<#
    Example command line

    .\rbcom-buzz365.ps1 -CredentialLabel "RB.COM SPO" -Configuration "2"

    -Configuration(s);
        "0" for minimal provisioning (Masterpage/pagelayout, CSS & JS)
        "1" for full provisioning
        "2" for Masterpage/pagelayout files only
        "3" for Masterpage Resource files only
#>
param (
    [parameter(Mandatory=$false)][string]$CredentialLabel = "RB.COM SPO",
    [parameter(Mandatory=$false)][string]$Configuration = "2"
)
cls
# load and init the CSOM modules
."..\modules\load-spo-modules.ps1"

$cwd = Split-Path -Parent $MyInvocation.MyCommand.Definition

$configurationName = "Masterpage"
$configurationId = $Configuration
$configurationPath = $cwd
$configXml = Get-XMLFile "buzz365.xml" "$configurationPath" 

$connections = @(
                    @{ csomUrl="https://rbcom.sharepoint.com/"; csomCredentialLabel=$CredentialLabel; csomConfiguration = $Configuration }, 
                    @{ csomUrl="https://rbcom.sharepoint.com/sites/dev-pah"; csomCredentialLabel=$CredentialLabel; csomConfiguration = $Configuration }, 
                    @{ csomUrl="https://rbcom.sharepoint.com/sites/cccdev1"; csomCredentialLabel=$CredentialLabel; csomConfiguration = $Configuration }, 
                    @{ csomUrl="https://rbcom.sharepoint.com/sites/O365"; csomCredentialLabel=$CredentialLabel; csomConfiguration = $Configuration }, 
                    @{ csomUrl="https://rbcom.sharepoint.com/sites/fn"; csomCredentialLabel=$CredentialLabel; csomConfiguration = $Configuration }, 
                    @{ csomUrl="https://rbcom.sharepoint.com/sites/cat"; csomCredentialLabel=$CredentialLabel; csomConfiguration = $Configuration } 
                )

Write-Host "`nApplying Configuration [$configurationName#$configurationId] from '$configurationPath\$_.xml'`n$($configurationXml.Description) " -ForegroundColor Yellow
Write-Host "`t$($($connections | % {$_.csomUrl}) -join `"`n`t`")"
Write-Host "`nPress any key to continue or CTRL+C to exit..." -ForegroundColor Yellow
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")
if ((($x.VirtualKeyCode -eq 17) -and ($x.ControlKeyState -match "LeftCtrlPressed"))) {
    Write-Host "`nStopped.`n" -ForegroundColor Red
    return
}

Write-Host "`nStarting...." -ForegroundColor Yellow
$connections | % {
    Write-Host "`n`n"

    # init an empty connector
    $connector = Init-CSOMConnector
    $connector.csomUrl = $_.csomUrl
    $connector.csomCredentialLabel = $_.csomCredentialLabel
    $configurationId = $_.csomConfiguration

    # connect...
    $connection = Get-CSOMConnection $connector
    if (-not $connection.HasConnection) { continue }
    Write-Host "Connected.`n"

    # get configuration
    $configurationXml = $configXml.selectSingleNode("*/Configuration[@Name='$configurationName' and @ID='$configurationId']")
    if ($configurationXml -eq $null) {
        Write-Host "Could not find configuration [$configurationName#$configurationId]`n" -ForegroundColor Red
        return
    }

    Write-Host "`nApplying Configuration [$configurationName#$configurationId] from '$configurationPath\$_.xml'`n$($configurationXml.Description) " -ForegroundColor Yellow

    Update-Taxonomy $taxonomyXml $connection.RootWeb $connection.Context
    Update-Web -Xml $configurationXml -Site $connection.Site -Web $connection.Web -ClientContext $connection.Context
}
Write-Host "`nDone.`n"
