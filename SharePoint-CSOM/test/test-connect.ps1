cls
# dostource the helpers
."C:\Dev\github\babel\SharePoint-CSOM\test\load-spo-helpers.ps1"

# load the helpers
Add-CSOM
Add-TenantCSOM

# set connection details
$url = "https://platinumdogsconsulting.sharepoint.com/sites/publishing"
$username = "phil.harding@platinumdogsconsulting.onmicrosoft.com"
$password = "Pa`$`$w0rd2"
$securePassword = ConvertTo-SecureString $Password -AsPlainText -Force
    
# connect/authenticate to SharePoint Online and get ClientContext object.. 
$clientContext = New-Object SharePointClient.PSClientContext($url) 
 
#$credentials = New-Object System.Net.NetworkCredential($username, $securePassword) 
$credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($username, $securePassword) 
$clientContext.Credentials = $credentials
  
if (!$clientContext.ServerObjectIsNull.Value) { 
    Write-Host "Connected to SharePoint site: '$url'`nLoading SPWeb properties..." -ForegroundColor Green 
} 
 
$web = $clientContext.Web
$clientContext.Load($web)
$clientContext.Load($web.AllProperties)
$clientContext.ExecuteQuery()

Write-Host "Loaded SPO Site Properties from $($web.Url)" -ForegroundColor Green
