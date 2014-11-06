function Add-Web {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][System.Xml.XmlElement]$xml,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Site]$Site,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web]$Web,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        Write-Host "Create Web '$($xml.Title)' [$($xml.WebTemplate)] $($xml.Url)" -ForegroundColor Green
        $newWeb = $null
        try {
            $newWebUrl = "$($Web.ServerRelativeUrl)/$($xml.Url)"
            $newWeb = $site.OpenWeb($newWebUrl)
            $ClientContext.Load($newWeb)
            $ClientContext.ExecuteQuery()
            Write-Host "`t..Web already exists" -ForegroundColor Green

            $delete = $false
            if ($xml.AlwaysDeleteWeb -and $xml.AlwaysDeleteWeb -ne "") { $delete = [bool]::Parse($xml.AlwaysDeleteWeb) }
            if ($delete) {
                Write-Host "`t..Deleting existing Web" -ForegroundColor Green
                $newWeb.DeleteObject();
                $ClientContext.ExecuteQuery()
                $newWeb = $null
                Write-Host "`t..Deleted" -ForegroundColor Green
            }
        }
        catch {
            if ($_.Exception.InnerException.ServerErrorTypeName -ne "System.IO.FileNotFoundException") {
                throw $_
            } else {
                # the web doesn't exist
                Write-Host "`t..Web doesn't exist" -ForegroundColor Green
                $newWeb = $null
            }
        }

        if ($newWeb -eq $null) {
            $webCreationInfo = New-Object Microsoft.SharePoint.Client.WebCreationInformation

            $webCreationInfo.Url = $xml.Url
            $webCreationInfo.Title = $xml.Title
            $webCreationInfo.Description = $xml.Description
            $webCreationInfo.WebTemplate = $xml.WebTemplate
            $webCreationInfo.Language = 1033

            $newWeb = $Web.Webs.Add($webCreationInfo)
            $ClientContext.ExecuteQuery()
            $ClientContext.Load($newWeb)
            $ClientContext.ExecuteQuery()
            Write-Host "`t..Created Web '$($newWeb.Title)' [$($newWeb.WebTemplate)] $($newWeb.ServerRelativeUrl)" -ForegroundColor Green
        }

        Write-Host "`t..Update web '$($newWeb.Title)' [$($newWeb.WebTemplate)] $($newWeb.ServerRelativeUrl)" -ForegroundColor Green
        Update-Web -xml $xml -site $site -web $newWeb -ClientContext $ClientContext
        Write-Host "Created Web '$($newWeb.Title)' [$($newWeb.WebTemplate)] $($newWeb.ServerRelativeUrl)" -ForegroundColor Green
        $newWeb
    }
    end {} 
}
function Add-Webs {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][System.Xml.XmlElement]$xml,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Site]$Site,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web]$web,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        foreach ($webInfo in $xml.Web) {
            $newweb = Add-Web -xml $webInfo -site $site -web $web -ClientContext $ClientContext 
        }
    }
    end {} 
}
function Set-WelcomePage {
    param (
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true)][string]$WelcomePageUrl,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web]$Web,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $rootFolder = $Web.RootFolder
        $ClientContext.Load($rootFolder)
        $ClientContext.ExecuteQuery()

        $newWelcomPageUrl = $WelcomePageUrl -replace "^$($rootFolder.ServerRelativeUrl)", ""
        if($rootFolder.WelcomePage -ne $newWelcomPageUrl) {
            $rootFolder.WelcomePage = $newWelcomPageUrl
            $rootFolder.Update()
            $ClientContext.Load($rootFolder)
            $ClientContext.ExecuteQuery()
            Write-Host "`t`tUpdated WelcomePage settings" -ForegroundColor Green
        } else {
            Write-Host "`t`tDid not need to update WelcomePage settings" -ForegroundColor White
        }
    }
    end {}
}

function Set-MasterPage {
    param (
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][string]$CustomMasterUrl,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][string]$MasterUrl,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web]$Web,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $rootWeb = $ClientContext.Site.RootWeb
        $ClientContext.Load($rootWeb)
        $ClientContext.ExecuteQuery()

        $oldCustomMasterUrl = $Web.CustomMasterUrl
        $oldMasterUrl = $Web.MasterUrl
        $serverRelativeUrl = $rootWeb.ServerRelativeUrl -replace "/$", ""

        $performUpdate = $false
        if($CustomMasterUrl) {
            $NewCustomMasterUrl = "$serverRelativeUrl/$CustomMasterUrl"
            if($oldCustomMasterUrl -ne $NewCustomMasterUrl) {
                $Web.CustomMasterUrl = $NewCustomMasterUrl
                $performUpdate = $true
            }
        }

        if($MasterUrl) {
            $NewMasterUrl = "$serverRelativeUrl/$MasterUrl"
            if($oldMasterUrl -ne $NewMasterUrl) {
                $Web.MasterUrl = $NewMasterUrl
                $performUpdate = $true
            }
        }
        
        if($performUpdate) {
            $Web.Update()
            $ClientContext.ExecuteQuery()
            Write-Host "`t`tUpdated MasterPage settings" -ForegroundColor Green
        } else {
            Write-Host "`t`tDid not need to update MasterPage settings" -ForegroundColor Blue
        }
    }
    end {}
}
function Set-Theme {
    param (
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true )][alias("ColorPaletteUrl")][string]$ThemeUrl = "_catalogs/theme/15/palette001.spcolor",
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][alias("BackgroundImageUrl")][string]$ImageUrl = $null,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][string]$FontSchemeUrl = "_catalogs/theme/15/SharePointPersonality.spfont",
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][bool]$shareGenerated = $true,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web]$Web,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $rootWeb = $ClientContext.Site.RootWeb
        $ClientContext.Load($rootWeb)
        $ClientContext.ExecuteQuery()

        $ServerRelativeUrl = $rootWeb.ServerRelativeUrl -replace "/$", ""
        $newThemeUrl = "$ServerRelativeUrl/$ThemeUrl"
        
        $newFontSchemeUrl = "$ServerRelativeUrl/_catalogs/theme/15/SharePointPersonality.spfont"
        if($FontSchemeUrl -and $FontSchemeUrl -ne "") {
            $newFontSchemeUrl = "$ServerRelativeUrl/$FontSchemeUrl"
        }

        $newImageUrl = $null
        if($ImageUrl -and $ImageUrl -ne "") {
            $newImageUrl = "$ServerRelativeUrl/$ImageUrl"
        }

        Write-Host "`t`tApplying Theme" -ForegroundColor Green
        if($newImageUrl) {
            $web.ApplyTheme($newThemeUrl, $newFontSchemeUrl, $newImageUrl, $shareGenerated)
        } else {
            # need to pass in a null string value for the image url and $null is not the same thing
            $web.ApplyTheme($newThemeUrl, $newFontSchemeUrl, [System.Management.Automation.Language.NullString]::Value, $shareGenerated)
        }
        $Web.Update()
        $ClientContext.Load($web)
        $ClientContext.ExecuteQuery()
    }
    end {}
}
function Add-ComposedLook {
    param (
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true)][string]$Name,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][string]$MasterPageUrl = "_catalogs/masterpage/seattle.master",
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][string]$ThemeUrl = "_catalogs/theme/15/palette001.spcolor",
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][string]$ImageUrl = "",
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][string]$FontSchemeUrl = "",
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][int]$DisplayOrder = 100,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$ComposedLooksList,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web]$Web,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        
        $rootWeb = $ClientContext.Site.RootWeb
        $ClientContext.Load($rootWeb)
        $ClientContext.ExecuteQuery()
        $serverRelativeUrl = $rootWeb.ServerRelativeUrl -replace "/$", ""

        $listItemCreationInformation = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation
        $composedLooksListItem = $ComposedLooksList.addItem($listItemCreationInformation)
    
        $composedLooksListItem.Set_Item("Title", $Name)
        $composedLooksListItem.Set_Item("Name", $Name)
        $composedLooksListItem.Set_Item("MasterPageUrl", "$serverRelativeUrl/$MasterPageUrl")
        $composedLooksListItem.Set_Item("ThemeUrl", "$serverRelativeUrl/$ThemeUrl")
        if($ImageUrl -and $ImageUrl -ne "") {
            $composedLooksListItem.Set_Item("ImageUrl", "$serverRelativeUrl/$ImageUrl")
        }
        if($FontSchemeUrl -and $FontSchemeUrl -ne "") {
            $composedLooksListItem.Set_Item("FontSchemeUrl", "$serverRelativeUrl/$FontSchemeUrl")
        }
        $composedLooksListItem.Set_Item("DisplayOrder", "$DisplayOrder")
        $composedLooksListItem.Update()

        $ClientContext.Load($composedLooksListItem) 
        $ClientContext.ExecuteQuery()
    }
    end {}
}
function Get-ComposedLook {
    param (
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true)][string]$Name,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$ComposedLooksList,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web]$Web,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $camlQuery = New-Object Microsoft.SharePoint.Client.CamlQuery
        $camlQuery.ViewXml = "<View><Query><Where><Eq><FieldRef Name='Title' /><Value Type='Text'>$Name</Value></Eq></Where></Query></View>"
        $composedLookListItems = $ComposedLooksList.GetItems($camlQuery)
        
        $ClientContext.Load($composedLookListItems)
        $ClientContext.ExecuteQuery()

        if($composedLookListItems.Count -eq 0) {
            return $null
        }
        $composedLookItem = $composedLookListItems[0]
        $ClientContext.Load($composedLookItem)
        $ClientContext.ExecuteQuery()
        return $composedLookItem
    }
    end {}
}
function Update-ComposedLook {
    param (
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true)][string]$Name,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][string]$MasterPageUrl,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][string]$ThemeUrl,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][string]$ImageUrl,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][string]$FontSchemeUrl,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][int]$DisplayOrder,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ListItem]$ComposedLook,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        throw NotImplementedException

        $rootWeb = $ClientContext.Site.RootWeb.ServerRelativeUrl
        $ClientContext.Load($rootWeb)
        $ClientContext.ExecuteQuery()
        $serverRelativeUrl = $rootWeb.ServerRelativeUrl -replace "/$", ""

        $needsUpdate = $false

        if($Name -and ($ComposedLook["Title"] -ne $Name -or $ComposedLook["Name"] -ne $Name)) {
            $ComposedLook.
            $ComposedLook.Set_Item("Title", $Name)
            $ComposedLook.Set_Item("Name", $Name)
            $needsUpdate = $true
        }

        $newMasterPageUrl = "$serverRelativeUrl/$MasterPageUrl"
        if($MasterPageUrl -and ($ComposedLook["MasterPageUrl"] -ne $newMasterPageUrl)) {
            $ComposedLook["MasterPageUrl"] = $newMasterPageUrl
            $needsUpdate = $true
        }
        if($ThemeUrl) {
            $ComposedLook.Set_Item("ThemeUrl", "$serverRelativeUrl/$ThemeUrl")
            $needsUpdate = $true
        }
        if($ImageUrl) {
            $ComposedLook.Set_Item("ImageUrl", "$serverRelativeUrl/$ImageUrl")
             $needsUpdate = $true
        }
        if($FontSchemeUrl) {
            $ComposedLook.Set_Item("FontSchemeUrl", "$serverRelativeUrl/$FontSchemeUrl")
             $needsUpdate = $true
        }
        if($DisplayOrder) {
            $ComposedLook.Set_Item("DisplayOrder", "$DisplayOrder")
            $needsUpdate = $true
        }
        if($needsUpdate) {
            $ComposedLook.Update()

            $ClientContext.Load($ComposedLook) 
            $ClientContext.ExecuteQuery()
        }
        return $ComposedLook
    }
    end {}
}

function Update-Web {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][System.Xml.XmlElement]$xml,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Site]$Site,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web]$Web,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        if ($site -eq $null) {
            $site = $ClientContext.Site
            if ($site.ServerObjectIsNull.HasValue -and $site.ServerObjectIsNull.Value) {
                $ClientContent.Load($site)
                $ClientContext.ExecuteQuery()
            }
        }
        if ($site.RootWeb.ServerObjectIsNull.HasValue -and $site.RootWeb.ServerObjectIsNull.Value) {
            $ClientContent.Load($site.RootWeb)
            $ClientContext.ExecuteQuery()
        }

        if ($xml.RemoveUserCustomActions) {
             Remove-CustomActions -CustomActionsXml $xml.RemoveUserCustomActions -Site $site -Web $web -ClientContext $ClientContext
        }
        if ($xml.Pages) {
            Remove-PublishingPages -PageXml $xml.Pages -Site $site -Web $web -ClientContext $ClientContext
        }

        if ($xml.Lists) {
            Remove-Lists $xml.Lists $site $web $ClientContext
        }

        if($xml.ContentTypes) {
            Remove-ContentTypes -contentTypesXml $xml.ContentTypes -web $site.RootWeb -ClientContext $ClientContext
        }
        if($xml.Fields) {
            Remove-SiteColumns -fieldsXml $xml.Fields -web $site.RootWeb -ClientContext $ClientContext
        }

        if($xml.Features) {
            if($xml.Features.WebFeatures -and $xml.Features.WebFeatures.DeactivateFeatures) {
                Remove-Features -FeaturesXml $xml.Features.WebFeatures.DeactivateFeatures -web $web -ClientContext $ClientContext
            }
            if($xml.Features.SiteFeatures -and $xml.Features.SiteFeatures.DeactivateFeatures) {
                Remove-Features -FeaturesXml $xml.Features.SiteFeatures.DeactivateFeatures -site $site -ClientContext $ClientContext
            }
        }

        # Done removing stuff, now to add/update
        if($xml.Features) {
            if($xml.Features.SiteFeatures -and $xml.Features.SiteFeatures.ActivateFeatures) {
                Add-Features -FeaturesXml $xml.Features.SiteFeatures.ActivateFeatures -site $site -ClientContext $ClientContext
            }
            if($xml.Features.WebFeatures -and $xml.Features.WebFeatures.ActivateFeatures) {
                Add-Features -FeaturesXml $xml.Features.WebFeatures.ActivateFeatures -web $web -ClientContext $ClientContext
            }
        }

        # add role definitions
        if ($xml.Roles) {
            Add-RoleDefintions -RolesXml $xml.Roles -Web $web -ClientContext $ClientContext
        }

        # add Site Groups
        if ($xml.Groups) {
            Add-SiteGroups -GroupsXml $xml.Groups -Web $site.RootWeb -ClientContext $ClientContext
        }

        if($xml.Fields) {
            Update-SiteColumns -fieldsXml $xml.Fields -web $site.RootWeb -ClientContext $ClientContext
        }

        if($xml.ContentTypes) {
            Update-ContentTypes -contentTypesXml $xml.ContentTypes -web $site.RootWeb -ClientContext $ClientContext
        }

        if ($xml.Catalogs) {
            Update-Catalogs -CatalogsXml $xml.Catalogs -site $site -Web $web -ClientContext $ClientContext
        }

        foreach ($listXml in $xml.Lists.RenameList) {
            Rename-List -OldTitle $listXml.OldTitle -NewTitle $listXml.NewTitle -Web $web -ClientContext $ClientContext
        }
        if ($xml.Lists) {
            Update-Lists $xml.Lists $site $web $ClientContext
        }

        if ($xml.Pages) {
            Update-PublishingPages -PageXml $xml.Pages -Site $site -Web $web -ClientContext $ClientContext
        }

        if ($xml.UserCustomActions) {
             Add-CustomActions -CustomActionsXml $xml.UserCustomActions -Site $site -Web $web -ClientContext $ClientContext
        }

        foreach ($ProperyBagValue in $xml.PropertyBag.PropertyBagValue) {
            $Indexable = $false
            if($PropertyBagValue.Indexable) {
                $Indexable = [bool]::Parse($PropertyBagValue.Indexable)
            }

            Set-PropertyBagValue -Key $ProperyBagValue.Key -Value $ProperyBagValue.Value -Indexable $Indexable -Web $web -ClientContext $ClientContext
        }
        
        if($xml.WelcomePage) {
            Set-WelcomePage -WelcomePageUrl $xml.WelcomePage -Web $web -ClientContext $ClientContext
        }

        if($xml.CustomMasterUrl -or $xml.MasterUrl) {
            Set-MasterPage -CustomMasterUrl $xml.CustomMasterUrl -MasterUrl $xml.MasterUrl -Web $web -ClientContext $ClientContext
        }

        if($xml.NoCrawl) {
            $noCrawl = [bool]$xml.NoCrawl
            Update-NoCrawl -NoCrawl $noCrawl -Web $web -ClientContext $ClientContext
        }

        if($xml.ColorPaletteUrl) {
            $FontSchemeUrl = $null
            if($xml.FontSchemeUrl) {
                $FontSchemeUrl = $xml.FontSchemeUrl
            }
            $BackgroundImageUrl = $null
            if($xml.BackgroundImageUrl) {
                $BackgroundImageUrl = $xml.BackgroundImageUrl
            }

            Set-Theme -ColorPaletteUrl $xml.ColorPaletteUrl -FontSchemeUrl $FontSchemeUrl -BackgroundImageUrl $BackgroundImageUrl -Web $web -ClientContext $ClientContext
        }

        if($xml.Webs) {
            Add-Webs -Xml $xml.Webs -Site $site -Web $web -ClientContext $ClientContext
        }

        if ($xml.Comments) {
            Write-Host "`nAUTHOR COMMENTS:"
            foreach($comment in $xml.Comments) {
                Write-Host "`t- $comment" -ForegroundColor White
            }
            Write-Host ""
        }
    }
    end {}
}

function Remove-RecentNavigationItem {
    param(
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$Title,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web, 
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $nodes = $ClientContext.Web.Navigation.QuickLaunch;
        $ClientContext.Load($nodes);
        $ClientContext.ExecuteQuery();

        $recent = $nodes | Where {$_.Title -eq "Recent"}
        if($recent -ne $null) {
            $ClientContext.Load($recent.Children);
            $ClientContext.ExecuteQuery();
            $recentNode = $recent.Children | Where {$_.Title -eq $Title}
            if ($recentNode -ne $null) {
                $recentNode.DeleteObject();
                $ClientContext.ExecuteQuery();
            }
        }
    }
    end {}
}

function Update-NoCrawl {
    param(
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][bool]$NoCrawl,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web, 
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $noCrawlPropName = "NoCrawl"
        $searchVersionPropName = "vti_searchversion"
        $oldValue = Get-PropertyBagValue -Key $noCrawlPropName -Web $Web -ClientContext $ClientContext
        if ([bool]$oldValue -ne $NoCrawl) {
            Set-PropertyBagValue -Key $noCrawlPropName -Value $NoCrawl -Web $Web -ClientContext $clientContext
            $searchVersionOld = Get-PropertyBagValue -Key $searchVersionPropName -Web $Web -ClientContext $ClientContext
            if ($searchVersionOld) {
                $searchVersionNew = [int]$searchVersionOld + 1
            } else {
                $searchVersionNew = 1
            }
            Set-PropertyBagValue -Key $searchVersionPropName -Value $searchVersionNew -Web $Web -ClientContext $clientContext
        }
    }
    end {}
}

<#
function UnSetup-Web {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web]$web,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][System.Xml.XmlElement]$xml,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        foreach ($List in $xml.Lists.List) {
            Remove-List -ListName $ContentType.Title -Web $web -ClientContext $ClientContext
        }
        foreach ($ContentType in $xml.ContentTypes.ContentType) {
            Remove-ContentType -ContentTypeName $ContentType.Name -Web $web -ClientContext $ClientContext
        }
        foreach ($Field in $xml.Fields.Field) {
            Remove-SiteColumn -FieldId $Field.ID -Web $web -ClientContext $ClientContext
        }
    }
}
#>