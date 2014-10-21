function Get-CustomAction {
param (
    [parameter(Mandatory=$false, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Site] $Site, 
    [parameter(Mandatory=$false, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $Web, 
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
)
    process {
        $existingActions = $null
        if ($Web -ne $null) {
            $ClientContext.Load($Web.UserCustomActions)
            $ClientContext.ExecuteQuery()
            $existingActions = $Web.UserCustomActions
        } else { 
            $ClientContext.Load($Site.UserCustomActions)
            $ClientContext.ExecuteQuery()
            $existingActions = $Site.UserCustomActions
        }

        $actions = @()
        # get existing custom actions
        $existingActions | % {
            $location = $_.Location
            $description = $_.Description
            $sequence = $_.Sequence
            if ($location -match "ScriptLink") {
                $scriptblock = $_.ScriptBlock
                $obj = @{ Location = $location; Name = $description; Sequence = $sequence; ScriptBlock = $scriptblock }
                $actions += $obj
            } else {
                $url = $_.Url
                $group = $_.Group
                $title = $_.Title
                $imageurl = $_.ImageUrl
                $rights = $_.Rights
                $obj = @{ Location = $location; Name = $description; Sequence = $sequence; Url = $url; Group = $group; Title = $title; ImageUrl = $imageurl; Rights = $rights; }
                $actions += $obj
            }
        }
        $actions
    }
    end {}
}
function Add-CustomAction {
param (
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$Location,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$Description,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][bool]$RemoveOnly,
    [parameter(Mandatory=$false, ValueFromPipeline=$true)][string]$ScriptBlock,
    [parameter(Mandatory=$false, ValueFromPipeline=$true)][int]$Sequence,
    [parameter(Mandatory=$false, ValueFromPipeline=$true)][string]$Url,
    [parameter(Mandatory=$false, ValueFromPipeline=$true)][string]$Group,
    [parameter(Mandatory=$false, ValueFromPipeline=$true)][string]$Title,
    [parameter(Mandatory=$false, ValueFromPipeline=$true)][string]$ImageUrl,
    [parameter(Mandatory=$false, ValueFromPipeline=$true)][string]$Rights,
    [parameter(Mandatory=$false, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Site] $Site, 
    [parameter(Mandatory=$false, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $Web, 
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
)
    process {
        $existingActions = $null
        if ($Web -ne $null) {
            $ClientContext.Load($Web.UserCustomActions)
            $ClientContext.ExecuteQuery()
            $existingActions = $Web.UserCustomActions
        } else { 
            $ClientContext.Load($Site.UserCustomActions)
            $ClientContext.ExecuteQuery()
            $existingActions = $Site.UserCustomActions
        }

        # remove existing custom action
        $added = $false
        $actionsToDelete = @()
        $existingActions | ? {
            ($_.Description -eq $Description) -and ($_.Location -eq $Location)
        } | % {
            $actionsToDelete += $_
        }
        $actionsToDelete | % {
            Write-Host "`t`t..Removing Existing CustomAction: $($_.Location) : $($_.Description) : $($_.Sequence)"
            $added = $true
            $_.DeleteObject()
            $ClientContext.ExecuteQuery()
        }
        if (-not $RemoveOnly) { 
            # add new custom action
            $newAction = $existingActions.Add()
            $newAction.Description = $Description
            $newAction.Location = $Location
            if ($Location -match "ScriptLink") {
                $newAction.ScriptBlock = $ScriptBlock
                $newAction.Sequence = $Sequence
            } else {
                $newAction.Sequence = $Sequence
                $newAction.Url = $Url
                $newAction.Group = $Group
                $newAction.Title = $Title
                $newAction.ImageUrl = $ImageUrl
                $newAction.Rights = $Rights
            }
            $newAction.Update();
            if ($Web -ne $null) {
                $ClientContext.Load($Web)
                $ClientContext.Load($Web.UserCustomActions)
            } else {
                $ClientContext.Load($Site)
                $ClientContext.Load($Site.UserCustomActions)
            }
            $ClientContext.ExecuteQuery();

            $added = $true
        }
        $added
    }
    end {}
}
function Add-CustomActions {
param (
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][System.Xml.XmlElement]$CustomActionsXml,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Site] $Site, 
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $Web, 
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
)
    process {
        if ($CustomActionsXml -eq $null -or $CustomActionsXml -eq "") { return }
        Write-Host "Start Adding Custom Actions" -ForegroundColor Green

        foreach($customActionXml in $CustomActionsXml.UserCustomAction) {
            # create cache-busting url version hashes
            $uid = [Guid]::NewGuid().ToString("N")

            $dom = $(if ($customActionXml.DOMElement) { $customActionXml.DOMElement } else { "head" })
            $scope = $(if ($customActionXml.Scope) { $customActionXml.Scope } else { "Web" })

            $name = $customActionXml.Name
            $location = $customActionXml.Location
            $sequence = $customActionXml.Sequence
            if ($name -eq $null -or $name -eq "" -or $location -eq $null -or $location -eq "") { continue }

            if ($location -match "ScriptLink") {
                $scriptBody = ""
                if ($customActionXml.ScriptBlock -ne $null -and $customActionXml.ScriptBlock -ne "") {
                    $code = $customActionXml.ScriptBlock.InnerXml
                    $code = $code -replace "\r\n"," "
                    $code = $code -replace "`"","\`""
                    $code = $code -replace "~sitecollection", $Site.ServerRelativeUrl
                    $code = $code -replace "~site", $Web.ServerRelativeUrl
                    
                    $scriptBody = @"
/* PROVISION [ScriptLink]: [$name] -- [$location] -- [$sequence] */
(function(window) {
    var domTarget = document.getElementsByTagName('$dom')[0];
    var newScript = document.createElement('script');
    newScript.type = 'text/javascript';
    var code = "$code";
    try {
        newScript.text = code;
        domTarget.appendChild(newScript);
    } catch (e) {
        newScript.appendChild(document.createTextNode(code));
        domTarget.appendChild(newScript);
    }
})(window);`n
"@
                    #$scriptBody = $code
                } elseif ($customActionXml.ScriptLinks -ne $null -and $customActionXml.ScriptLinks -ne "") {
                    $scriptBody = @"
(function(window) {
/* PROVISION: ScriptLink: [$name] -- [$location] -- [$sequence] */`n
"@
                    $scriptBody += "var domTarget = document.getElementsByTagName('$dom')[0];`nvar newLink = null, newScript = null;`n"
                    $scriptLinks = $customActionXml.ScriptLinks -split ";"
                    foreach($scriptlink in $scriptLinks) {
                        $scriptlink = $scriptlink -replace "~sitecollection", $Site.ServerRelativeUrl
                        $scriptlink = $scriptlink -replace "~site", $Web.ServerRelativeUrl

                        if ($scriptlink -match ".css") {
                            $text = @"
newLink = document.createElement('link');
newLink.type = 'text/css';
newLink.href = '$($scriptLink)?ver=$($uid)';
newLink.rel = 'stylesheet'
domTarget.appendChild(newLink);`n
"@
                        } elseif ($scriptlink -match ".js") {
                            $text = @"
newScript = document.createElement('script');
newScript.async = false;
newScript.type = 'text/javascript';
newScript.src = '$($scriptLink)?ver=$($uid)';
domTarget.appendChild(newScript);`n
"@
                        }
                        $scriptBody += $text
                    }
                    # close the scriptBody IIFE
                    $scriptBody += "})(window);`n"
                }

                # call Add-CustomAction
                if ($scriptBody -ne "") {
                    #Write-Host "Add CustomAction [ScriptLink]: [$scope] -- [$name] -- [$location] -- [$sequence]`n$scriptBody`n"
                    Write-Host "`tAdd CustomAction [ScriptLink]: [$scope] -- [$name] -- [$location] -- [$sequence]"
                    $done = $false
                    if ($scope -match "site") {
                        $done = Add-CustomAction -Location $location -Description $name -RemoveOnly $false -ScriptBlock $scriptBody -Sequence $sequence `
                                            -Site $site -ClientContext $ClientContext
                    } else {
                        $done = Add-CustomAction -Location $location -Description $name -RemoveOnly $false -ScriptBlock $scriptBody -Sequence $sequence `
                                            -Web $web -ClientContext $ClientContext
                    }
                    Write-Host "`t..$(if ($done) {`"Done`"} else {`"Not Done`"})"
                }
            } else {
                Write-Host "`tAdd CustomAction: [$scope] -- [$name] -- [$location] -- [$sequence]"
                $url = $customActionXml.Url
                $group = $customActionXml.Group
                $title = $customActionXml.Title
                $imageurl = $customActionXml.ImageUrl
                $rights = $customActionXml.Rights

                $done = $false
                if ($scope -match "site") {
                    $done = Add-CustomAction -Location $location -Description $name -RemoveOnly $false -Sequence $sequence -Url $url -Group $group -Title $title -ImageUrl $imageurl -Rights $rights `
                                        -Site $site -ClientContext $ClientContext
                } else {
                    $done = Add-CustomAction -Location $location -Description $name -RemoveOnly $false -Sequence $sequence -Url $url -Group $group -Title $title -ImageUrl $imageurl -Rights $rights `
                                        -Web $web -ClientContext $ClientContext
                }
                Write-Host "`t..$(if ($done) {`"Done`"} else {`"Not Done`"})"
            }
        }

        Write-Host "Finished Adding Custom Actions" -ForegroundColor Green
    }
    end {}
}
function Remove-CustomActions {
param (
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][System.Xml.XmlElement]$CustomActionsXml,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Site] $Site, 
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $Web, 
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
)
    process {
        if ($CustomActionsXml -eq $null -or $CustomActionsXml -eq "") { return }
        Write-Host "Start Removing Custom Actions" -ForegroundColor Green

        foreach($customActionXml in $CustomActionsXml.UserCustomAction) {
            $scope = $(if ($customActionXml.Scope) { $customActionXml.Scope } else { "Web" })

            $name = $customActionXml.Name
            $location = $customActionXml.Location
            if ($name -eq $null -or $name -eq "" -or $location -eq $null -or $location -eq "") { continue }

            if ($location -match "ScriptLink") {
                Write-Host "`tRemove CustomAction [ScriptLink]: [$scope] -- [$name] -- [$location]"
                $done = $false
                if ($scope -match "site") {
                    $done = Add-CustomAction -Location $location -Description $name -RemoveOnly $true `
                                        -Site $site -ClientContext $ClientContext
                } else {
                    $done = Add-CustomAction -Location $location -Description $name -RemoveOnly $true `
                                        -Web $web -ClientContext $ClientContext
                }
                Write-Host "`t..$(if ($done) {`"Done`"} else {`"Not Done`"})"
            } else {
                Write-Host "`tRemove CustomAction: [$scope] -- [$name] -- [$location]"

                $done = $false
                if ($scope -match "site") {
                    $done = Add-CustomAction -Location $location -Description $name -RemoveOnly $true `
                                        -Site $site -ClientContext $ClientContext
                } else {
                    $done = Add-CustomAction -Location $location -Description $name -RemoveOnly $true `
                                        -Web $web -ClientContext $ClientContext
                }
                Write-Host "`t..$(if ($done) {`"Done`"} else {`"Not Done`"})"
            }
        }

        Write-Host "Finished Removing Custom Actions" -ForegroundColor Green
    }
    end {}
}
