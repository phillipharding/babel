cls
$web = $null
$clientContext = $null

# set connection details
$spourl = "https://platinumdogsconsulting.sharepoint.com/sites/publishing"
$spousername = "phil.harding@platinumdogsconsulting.onmicrosoft.com"
$spopassword = "Pa`$`$w0rd2"

# load the CSOM helpers
."C:\Dev\github\babel\SharePoint-CSOM\test\load-spo-helpers.ps1"
# initialise CSOM helpers
Add-CSOM
Add-TenantCSOM

# connect
."C:\Dev\github\babel\SharePoint-CSOM\test\do-clientconnection.ps1"
if (-not $spohasconnection) { return }

# load XML datasets file
$doc = [xml] (Get-Content "C:\Dev\github\babel\SharePoint-CSOM\test\site-columns.xml")

# get datasets
$taxonomyXml = $doc.SelectSingleNode("*/TermStore")
$fieldsXml = $doc.SelectSingleNode("*/Fields")
$contentTypesXml = $doc.SelectSingleNode("*/ContentTypes")

Remove-ContentTypes $contentTypesXml $web $clientContext
Write-Host
Remove-SiteColumns $fieldsXml $web $clientContext
Write-Host

Update-Taxonomy $taxonomyXml $web $clientContext
Write-Host
Update-SiteColumns $fieldsXml $web $clientContext
Write-Host
Update-ContentTypes $contentTypesXml $web $clientContext
Write-Host
