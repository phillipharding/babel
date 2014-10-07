cls

# set connection details
$spohasconnection = $false
if ($spourl -eq $null -or $spourl -eq "") { $spourl = "https://platinumdogsconsulting.sharepoint.com/sites/publishing" }
if ($spousername -eq $null -or $spousername -eq "") { $spousername = "phil.harding@platinumdogsconsulting.onmicrosoft.com" }
if ($spopassword -eq $null -or $spopassword -eq "") { $spopassword = "Pa`$`$w0rd2" }

$securePassword = ConvertTo-SecureString $spopassword -AsPlainText -Force

try {
    # connect/authenticate to SharePoint Online and get ClientContext object.. 
    $clientContext = New-Object SharePointClient.PSClientContext($spourl) 
 
     if ($spourl -match "sharepoint.com") {
        $credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($spousername, $securePassword) 
        Write-Host "Using SharePointOnlineCredentials..." -ForegroundColor Green
    } else {
        $credentials = New-Object System.Net.NetworkCredential($spousername, $securePassword)
        Write-Host "Using NetworkCredentials..." -ForegroundColor Green
    }
    $clientContext.Credentials = $credentials
  
    if (!$clientContext.ServerObjectIsNull.Value) { 
        Write-Host "Connected to SharePoint site: '$spourl'`nLoading SPWeb properties..." -ForegroundColor Green 
    }

    $web = $clientContext.Web
    $clientContext.Load($web)
    $clientContext.Load($web.AllProperties)
    $clientContext.ExecuteQuery()
    $spohasconnection = $true
}
catch { 
    Write-Host "*Exception while connecting: $($_.Exception.Message)" -ForegroundColor Red 
    $spohasconnection = $false
}

if ($spohasconnection) {
    if ($spourl -match "sharepoint.com") {
        Write-Host "Loaded SPO Properties from $($web.Url)" -ForegroundColor Green
     } else {
        Write-Host "Loaded On-Premise Site Properties from $($web.Url)" -ForegroundColor Green
    }
} else {
}
