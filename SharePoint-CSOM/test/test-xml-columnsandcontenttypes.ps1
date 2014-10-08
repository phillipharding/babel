cls
$scriptPath = Split-Path -Parent  $MyInvocation.MyCommand.Definition

# load and init the CSOM helpers
."$scriptPath\load-spo-helpers.ps1"
cls
# load and init connection helpers
."$scriptPath\do-clientconnection.ps1"

Add-CSOM
Add-TenantCSOM

# connect
$csomUrl = "https://platinumdogsconsulting.sharepoint.com/sites/publishing"
#$csomUrl = "http://pub.pdogs.local"

$csomUsername = "phil.harding@platinumdogsconsulting.onmicrosoft.com"
$csomPassword = "Pa`$`$w0rd2"
#$csomCredentials = (Get-Credential | Out-Null)
$con = Get-CSOMConnection
if (-not $con.HasConnection) { return }

# load XML datasets file
$configXml = Get-XMLFile "site-columns.xml" "C:\Dev\github\babel\SharePoint-CSOM\test" $null
#[xml] (Get-Content "C:\Dev\github\babel\SharePoint-CSOM\test\site-columns.xml")

# get datasets
$modulesXml = $configXml.SelectSingleNode("*/Modules")
$siteFeaturesXml = $configXml.SelectSingleNode("*/SiteFeatures")
$removeSiteFeaturesXml = $configXml.SelectSingleNode("*/RemoveSiteFeatures")
$webFeaturesXml = $configXml.SelectSingleNode("*/WebFeatures")
$removeWebFeaturesXml = $configXml.SelectSingleNode("*/RemoveWebFeatures")
$taxonomyXml = $configXml.SelectSingleNode("*/TermStore")
$fieldsXml = $configXml.SelectSingleNode("*/Fields")
$contentTypesXml = $configXml.SelectSingleNode("*/ContentTypes")

#Remove-Features -FeaturesXml $removeSiteFeaturesXml -site $con.Site -ClientContext $con.Context
Write-Host
#Add-Features -FeaturesXml $siteFeaturesXml -site $con.Site -ClientContext $con.Context
Write-Host

#Remove-Features -FeaturesXml $removeWebFeaturesXml -web $con.Web -ClientContext $con.Context
Write-Host
#Add-Features -FeaturesXml $webFeaturesXml -web $con.Web -ClientContext $con.Context
Write-Host

#Remove-ContentTypes $contentTypesXml $con.RootWeb $con.Context
Write-Host
#Remove-SiteColumns $fieldsXml $con.RootWeb $con.Context
Write-Host

#Update-Taxonomy $taxonomyXml $con.RootWeb $con.Context
Write-Host

#Update-SiteColumns $fieldsXml $con.RootWeb $con.Context
Write-Host
#Update-ContentTypes $contentTypesXml $con.RootWeb $con.Context
Write-Host

foreach($folderXml in $modulesXml.Folder) {
    if ($folderXml.Url -and $folderXml.Url -ne "") {
        Write-Host "Module: $($folderXml.Path)..."
        if ((-not $folderXml.Scope) -or ($folderXml.Scope -match "site")) {
            $list = Get-List $folderXml.Url $con.RootWeb $con.Context
        } elseif ($folderXml.Scope -match "web") {
            $list = Get-List $folderXml.Url $con.Web $con.Context
        }
        $folder = Get-RootFolder $list $con.Context

        $minvEnabled = $list.EnableMinorVersions
        $majvEnabled = $list.EnableVersioning
        $approval = $list.EnableModeration
        $resourcesPath = $folderXml.ResourcesPath
        
        Add-Files $folder $folderXml $resourcesPath $con.Context $null -MinorVersionsEnabled $minvEnabled -MajorVersionsEnabled $majvEnabled -ContentApprovalEnabled $approval
    }
}
