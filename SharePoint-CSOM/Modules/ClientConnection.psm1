function Init-CSOMConnection {
    process {
        return @{ `
            csomUrl = $null; `
            csomUsername = $null; `
            csomPassword = $null; `
            csomCredentials = $null `
        }
    }
    end {}
}
function Get-CSOMConnection {
    param (
        [parameter(Mandatory=$true)]$conn
    )
    process {
        # set connection details
        $csomSite = $null
        $csomRootweb = $null
        $csomWeb = $null
        $clientContext = $null
        $csomHasconnection = $false
        $credentials = $null

        if ($conn.csomUrl -eq $null -or $conn.csomUrl -eq "") { Throw "Specify the connection URL using `$conn.csomUrl" }

        if ($conn.csomUrl -match "sharepoint.com") {
            # SPO
            if ($conn.csomCredentials -eq $null) {
                if ($conn.csomUsername -eq $null -or $conn.csomUsername -eq "") { Throw "Specify the connection username using `$conn.csomUsername" }
                if ($conn.csomPassword -eq $null -or $conn.csomPassword -eq "") { Throw "Specify the connection password using `$conn.csomPassword" }
        
                $securePassword = ConvertTo-SecureString $conn.csomPassword -AsPlainText -Force
            } else {
                $conn.csomUsername = $conn.csomCredentials.UserName
                $securePassword = $conn.csomCredentials.Password
            }
        } else {
            # On-Premises
            if (($conn.csomUsername -ne $null -and $conn.csomUsername -ne "") -and ($conn.csomPassword -ne $null -and $conn.csomPassword -ne "")) {
                $securePassword = $conn.csomPassword
            }
        }

        try {
            # connect/authenticate to SharePoint and get ClientContext object.. 
            $clientContext = New-Object SharePointClient.PSClientContext($conn.csomUrl) 
     
            if ($conn.csomUrl -match "sharepoint.com") {
                $credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($conn.csomUsername, $securePassword) 
                Write-Host "Using SharePointOnlineCredentials..." -ForegroundColor Green
            } else {
                if (($conn.csomUsername -eq $null -or $conn.csomUsername -eq "") -or ($conn.csomPassword -eq $null -or $conn.csomPassword -eq "")) {
                    Write-Host "Using On-Premises current user Credentials..." -ForegroundColor Green
                } else {
                    $credentials = New-Object System.Net.NetworkCredential($conn.csomUsername, $securePassword)
                    Write-Host "Using On-Premises NetworkCredentials..." -ForegroundColor Green
                }
            }
            if ($credentials -ne $null) {
                $clientContext.Credentials = $credentials
            }
      
            if (!$clientContext.ServerObjectIsNull.Value) { 
                Write-Host "Connected to SharePoint '$($conn.csomUrl)'`nLoading Context..." -ForegroundColor Green 
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
            if ($conn.csomUrl -match "sharepoint.com") {
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
        return @{ HasConnection=$csomHasConnection; Context=$clientContext; Site=$csomSite; RootWeb=$csomRootweb; Web=$csomWeb; Connections=@() }
    }
    end {}
}

