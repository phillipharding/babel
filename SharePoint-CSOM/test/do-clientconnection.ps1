$csomUrl = $null
$csomUsername = $null
$csomPassword = $null
$csomCredentials = $null

function Get-CSOMConnection {
process {
    # set connection details
    $csomSite = $null
    $csomRootweb = $null
    $csomWeb = $null
    $clientContext = $null
    $csomHasconnection = $false
    $credentials = $null

    if ($csomUrl -eq $null -or $csomUrl -eq "") { Throw "Specify the connection URL using `$csomUrl" }

    if ($csomUrl -match "sharepoint.com") {
        # SPO
        if ($csomCredentials -eq $null) {
            if ($csomUsername -eq $null -or $csomUsername -eq "") { Throw "Specify the connection username using `$csomUsername" }
            if ($csomPassword -eq $null -or $csomPassword -eq "") { Throw "Specify the connection password using `$csomPassword" }
        
            $securePassword = ConvertTo-SecureString $csomPassword -AsPlainText -Force
        } else {
            $csomUsername = $csomCredentials.UserName
            $securePassword = $csomCredentials.Password
        }
    } else {
        # On-Premises
    }

    try {
        # connect/authenticate to SharePoint and get ClientContext object.. 
        $clientContext = New-Object SharePointClient.PSClientContext($csomUrl) 
     
        if ($csomUrl -match "sharepoint.com") {
            $credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($csomUsername, $securePassword) 
            Write-Host "Using SharePointOnlineCredentials..." -ForegroundColor Green
        } else {
            if (($csomUsername -eq $null -or $csomUsername -eq "") -or ($csomPassword -eq $null -or $csomPassword -eq "")) {
                Write-Host "Using On-Premises current user Credentials..." -ForegroundColor Green
            } else {
                $credentials = New-Object System.Net.NetworkCredential($csomUsername, $securePassword)
                Write-Host "Using On-Premises NetworkCredentials..." -ForegroundColor Green
            }
        }
        if ($credentials -ne $null) {
            $clientContext.Credentials = $credentials
        }
      
        if (!$clientContext.ServerObjectIsNull.Value) { 
            Write-Host "Connected to SharePoint '$csomUrl'`nLoading Context..." -ForegroundColor Green 
        }
        
        $csomSite = $clientContext.Site
        $csomRootweb = $clientContext.Site.RootWeb
        $csomWeb = $clientContext.Web
        $clientContext.Load($csomSite)
        $clientContext.Load($csomWeb)
        $clientContext.Load($csomRootweb)
        $clientContext.Load($csomRootweb.AllProperties)
        $clientContext.Load($csomWeb.AllProperties)
        $clientContext.ExecuteQuery()
        $csomHasconnection = $true
    }
    catch { 
        Write-Host "*Exception while connecting: $($_.Exception.Message)" -ForegroundColor Red 
        $csomHasconnection = $false
    }

    if ($csomHasconnection) {
        if ($csomUrl -match "sharepoint.com") {
            Write-Host "Loaded SPO site  $($csomSite.Url)" -ForegroundColor Green
            Write-Host "Loaded SPO rootweb  $($csomRootweb.Url)" -ForegroundColor Green
            Write-Host "Loaded SPO web $($csomWeb.Url)" -ForegroundColor Green
         } else {
            Write-Host "Loaded On-Premises site $($csomSite.Url)" -ForegroundColor Green
            Write-Host "Loaded On-Premises rootweb $($csomRootweb.Url)" -ForegroundColor Green
            Write-Host "Loaded On-Premises web $($csomWeb.Url)" -ForegroundColor Green
        }
    } else {
        # no connection!!
    }
    return @{ HasConnection=$csomHasConnection; Context=$clientContext; Site=$csomSite; RootWeb=$csomRootweb; Web=$csomWeb }
}
end {}
}

