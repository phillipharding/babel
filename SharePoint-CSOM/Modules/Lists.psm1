function New-List {
param (
    [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true)][string]$ListName,
    [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true)][string]$Type,
    [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true)][string]$Url,
    [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][guid]$TemplateFeatureId,           
    [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web,
    [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
)
    process {
        $listCreationInformation = New-Object Microsoft.SharePoint.Client.ListCreationInformation
        $listCreationInformation.Title = $ListName
        $listCreationInformation.TemplateType = $Type
        $listCreationInformation.Url = $Url
        
        if($TemplateFeatureId) {
            $listCreationInformation.TemplateFeatureId = $TemplateFeatureId
        }

        New-ListWithListCreationInformation -listCreationInformation $listCreationInformation -web $web -ClientContext $ClientContext
    }
    end {}
}
function New-ListFromXml {
param (
    [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][System.Xml.XmlElement]$listxml,
    [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web,
    [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
)
    process {
        $listCreationInformation = New-Object Microsoft.SharePoint.Client.ListCreationInformation
        if($listxml.Description) {
            $listCreationInformation.Description = $listxml.Description
        }
        if($listxml.OnQuickLaunchBar) {
            $onQuickLaunchBar = [bool]::Parse($listxml.OnQuickLaunchBar)
            if($onQuickLaunchBar){
                $listCreationInformation.QuickLaunchOption = [Microsoft.SharePoint.Client.QuickLaunchOptions]::On
            } elseif(!$onQuickLaunchBar) {
                $listCreationInformation.QuickLaunchOption = [Microsoft.SharePoint.Client.QuickLaunchOptions]::Off
            }
        }
        if($listxml.QuickLaunchOption) {
            $listCreationInformation.QuickLaunchOption = [Microsoft.SharePoint.Client.QuickLaunchOptions]::$($listxml.QuickLaunchOption)
        }
        if($listxml.TemplateFeatureId) {
            $listCreationInformation.TemplateFeatureId = $listxml.TemplateFeatureId
        }
        if($listxml.Type) {
            $listCreationInformation.TemplateType = $listxml.Type
        }
        if($listxml.Title) {
            $listCreationInformation.Title = $listxml.Title
        }
        if($listxml.Url) {
            $listCreationInformation.Url = $listxml.Url
        }

        New-ListWithListCreationInformation -listCreationInformation $listCreationInformation -web $web -ClientContext $ClientContext
    }
    end {}
}
function New-ListWithListCreationInformation {
param (
    [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ListCreationInformation]$listCreationInformation,           
    [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web,
    [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
)
    process {
        $list = $web.Lists.Add($listCreationInformation)

        $ClientContext.Load($list)
        $ClientContext.ExecuteQuery()

        $list
    }
    end {}
}
function Get-List {
param (
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ListName,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
)
    process {
        $lists = $web.Lists
        $ClientContext.Load($lists)
        $ClientContext.ExecuteQuery()
        
        $list = $null
        $list = $lists | Where {$_.Title -eq $ListName}
        if($list -ne $null) {
            $ClientContext.Load($list)
            $ClientContext.ExecuteQuery()
        }
        $list
    }
}
function Remove-List {
param(
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ListName,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web, 
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
)
    process {
        $list = Get-List -ListName $ListName -Web $web -ClientContext $ClientContext
        if($list -ne $null) {
            $list.DeleteObject()
            $ClientContext.ExecuteQuery()
        }
    }
}

function Get-ListView {
param (
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$List,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ViewName,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
)
    process {
        $views = $list.Views
        $ClientContext.load($views)
        $ClientContext.ExecuteQuery()
        
        $view = $null
        $view = $views | Where {$_.Title -eq $ViewName}
        if($view -ne $null) {
            $ClientContext.load($view)
            $ClientContext.ExecuteQuery()
        }
        $view
    }
}
function Get-ListViewById {
param (
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$List,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ViewId,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
)
    process {
        $views = $list.Views
        $ClientContext.Load($views)
        $ClientContext.ExecuteQuery()
        
        $view = $null
        $view = $views | Where {$_.Id -eq $ViewId}
        if($view -ne $null) {
            $ClientContext.Load($view)
            $ClientContext.ExecuteQuery()
        }
        $view
    }
}
function Get-ListViewByServerRelativeUrl {
param (
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$List,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ServerRelativeUrl,
    [parameter(Mandatory=$false, ValueFromPipeline=$true)][string]$BaseViewId,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
)
    process {
        $views = $list.Views
        $ClientContext.Load($views)
        $ClientContext.ExecuteQuery()
        
        $view = $null
        if ($BaseViewId -and $BaseViewId -ne "") {
            $view = $views | Where { ($_.ServerRelativeUrl -match "$ServerRelativeUrl$") -and ($_.BaseViewId -eq $BaseViewId) }
        } else {
            $view = $views | Where { $_.ServerRelativeUrl -match "$ServerRelativeUrl$" }
        }
        if($view -ne $null) {
            if ($view.GetType().BaseType.Name -match "Array") {
                for ($v=0; $v -lt $view.length; $v++) {
                    $ClientContext.Load($view[$v])
                    $ClientContext.ExecuteQuery()
                }
            } else {
                $ClientContext.Load($view)
                $ClientContext.ExecuteQuery()
            }
        }
        $view
    }
}
function New-ListView {
param (
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$List,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ViewName,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][bool]$DefaultView,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][bool]$Paged,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][bool]$PersonalView,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$Query,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][int]$RowLimit,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][string[]]$ViewFields,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ViewType,
    [parameter(Mandatory=$false, ValueFromPipeline=$true)][string]$ViewJslink,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
)
    process {
        $ViewTypeKind
        switch($ViewType) {
            "none"{$ViewTypeKind = [Microsoft.SharePoint.Client.ViewType]::None}
            "html"{$ViewTypeKind = [Microsoft.SharePoint.Client.ViewType]::Html}
            "grid"{$ViewTypeKind = [Microsoft.SharePoint.Client.ViewType]::Grid}
            "calendar"{$ViewTypeKind = [Microsoft.SharePoint.Client.ViewType]::Calendar}
            "recurrence"{$ViewTypeKind = [Microsoft.SharePoint.Client.ViewType]::Recurrence}
            "chart"{$ViewTypeKind = [Microsoft.SharePoint.Client.ViewType]::Chart}
            "gantt"{$ViewTypeKind = [Microsoft.SharePoint.Client.ViewType]::Gantt}
        }
        $vCreation = New-Object Microsoft.SharePoint.Client.ViewCreationInformation
        $vCreation.Paged = $Paged
        $vCreation.PersonalView = $PersonalView
        $vCreation.Query = $Query
        $vCreation.RowLimit = $RowLimit
        $vCreation.SetAsDefaultView = $DefaultView
        $vCreation.Title = $ViewName
        $vCreation.ViewFields = $ViewFields
        $vCreation.ViewTypeKind = $ViewTypeKind

        $view = $list.Views.Add($vCreation)
        $list.Update()
        $ClientContext.ExecuteQuery()
        $view
    }
}
function Update-ListView {
param (
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$List,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ViewNameOrId,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][bool]$DefaultView,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][bool]$Paged,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$Query,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][int]$RowLimit,
    [parameter(Mandatory=$false, ValueFromPipeline=$true)][string[]]$ViewFields,
    [parameter(Mandatory=$false, ValueFromPipeline=$true)][string]$ViewJslink,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
)
    process {
        $view = Get-ListView -List $List -ViewName $ViewNameOrId -ClientContext $ClientContext
        if ($view -eq $null) {
            $view = Get-ListViewById -List $List -ViewId $ViewNameOrId -ClientContext $ClientContext
        }
        if($view -ne $null) {
            $view.Paged = $Paged
            $view.ViewQuery = $Query
            $view.RowLimit = $RowLimit
            $view.DefaultView = $DefaultView
            if ($ViewJslink -ne $null -and $ViewJslink -ne "") {
                $view.JSLink = $ViewJslink
                Write-Host "`t`t`t..Add JSLink $ViewJslink" -ForegroundColor Green
            }

            if (($ViewFields -ne $null) -and ($ViewFields.Count -gt 0)) {
                $view.ViewFields.RemoveAll()
                ForEach ($vf in $ViewFields) {
                    $view.ViewFields.Add($vf)
                    Write-Host "`t`t`t..Add column $vf" -ForegroundColor Green
                }
            }

            $view.Update()
            $List.Update()
            $ClientContext.ExecuteQuery()
        }
        $view
    }
}

function Get-ListContentType {
param (
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$List,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ContentTypeName,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
)
    process {
        $contentTypes = $List.ContentTypes
        $ClientContext.load($contentTypes)
        $ClientContext.ExecuteQuery()
        
        $contentType = $null
        $contentType = $contentTypes | Where {$_.Name -eq $ContentTypeName}
        if($contentType -ne $null) {
            $ClientContext.load($contentType)
            $ClientContext.ExecuteQuery()
        }
        $contentType
    }
}
function Add-ListContentType {
param (
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$List,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ContentTypeName,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext

)
    process {
        $contentTypes = $web.AvailableContentTypes
        $ClientContext.Load($contentTypes)
        $ClientContext.ExecuteQuery()

        $contentType = $contentTypes | Where {$_.Name -eq $ContentTypeName}
        if($contentType -ne $null) {
            if(!$List.ContentTypesEnabled) {
                $List.ContentTypesEnabled = $true
            }
            $ct = $List.ContentTypes.AddExistingContentType($contentType);
            $List.Update()
            $ClientContext.ExecuteQuery()
        } else {
            $ct = $null
        }
        $ct
    }
    end {}
}
function Remove-ListContentType {
param (
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$List,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ContentTypeName,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
)
    process {
        $contentTypeToDelete = Get-ListContentType $List $ClientContext -ContentTypeName $ContentTypeName
        if($contentTypeToDelete -ne $null) {
            if($contentTypeToDelete.Sealed) {
                $contentTypeToDelete.Sealed = $false
            }
            $contentTypeToDelete.DeleteObject()
            $List.Update()
            $ClientContext.ExecuteQuery()
        }
    }
}

function New-ListField {
param (
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$FieldXml,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$List,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
)
    process {
        $field = $list.Fields.AddFieldAsXml($FieldXml, $true, ([Microsoft.SharePoint.Client.AddFieldOptions]::DefaultValue))
        $ClientContext.Load($field)
        $ClientContext.ExecuteQuery()
        $field
    }
    end {}
}
function Get-ListField {
param (
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$FieldName,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$List,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
)
    process {
        $Fields = $List.Fields
        $ClientContext.Load($Fields)
        $ClientContext.ExecuteQuery()
        
        $Field = $null
        $Field = $Fields | Where {$_.InternalName -eq $FieldName}
        $Field
    }
}
function Remove-ListField {
param (
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$FieldName,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$List,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
)
    process {
        $Fields = $List.Fields
        $ClientContext.Load($Fields)
        $ClientContext.ExecuteQuery()
        
        $Field = $null
        $Field = $Fields | Where {$_.InternalName -eq $FieldName}
        if($Field -ne $null) {
            $Field.DeleteObject()
            $List.Update()
            $ClientContext.ExecuteQuery()
            Write-Host "`t`tDeleted List Field: $FieldName" -ForegroundColor Green
        } else {
            Write-Host "`t`tField not found in list: $FieldName"
        }
    }
}
function Update-Catalogs {
param (
    [parameter(Mandatory=$false, ValueFromPipeline=$true)][System.Xml.XmlElement]$CatalogsXml,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Site] $site, 
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web, 
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
)
    process {
        if ($CatalogsXml -eq $null -or $CatalogsXml -eq "") { return }
        Write-Host "START CATALOGS.." -ForegroundColor Green
        foreach($catalogXml in $CatalogsXml.Catalog) {
            if ($catalogXml.Type -eq "MasterPageCatalog") {
                $SPList = $site.RootWeb.GetCatalog([Microsoft.SharePoint.Client.ListTemplateType]::$($catalogXml.Type))
            } else {
                $SPList = $web.GetCatalog([Microsoft.SharePoint.Client.ListTemplateType]::$($catalogXml.Type))
            }
            $ClientContext.Load($SPList)
            $ClientContext.ExecuteQuery()

            if($SPList -eq $null) {
                Throw "Catalog not found: $($catalogXml.Title) for ListTemplateType: $($catalogXml.Type)"
            } else {
                Write-Host "`tCatalog loaded: $($catalogXml.Title)" -ForegroundColor Green
            }

            Write-Host "`tDELETE ITEMS" -ForegroundColor Green
            if($catalogXml.DeleteItems) {
                foreach($itemXml in $catalogXml.DeleteItems.Item) {
                    $item = Get-ListItem -itemUrl $itemXml.Url -Folder $itemXml.Folder -List $SPList -ClientContext $clientContext
                    if($item -ne $null) {
                        Remove-ListItem -listItem $item -ClientContext $clientContext
                    }
                }
            }
            Write-Host "`tUPDATE ITEMS" -ForegroundColor Green
            if($catalogXml.UpdateItems) {
                foreach($itemXml in $catalogXml.UpdateItems.Item) {
                    Update-ListItem -listItemXml $itemXml -List $SPList -ClientContext $clientContext
                }
            }

            Write-Host "`tFILES AND FOLDERS" -ForegroundColor Green
            foreach($folderXml in $catalogXml.Folder) {
            #    Write-Host "`t`t$(if ($folderXml.Url) { $folderXml.Url } else { `"{root folder}`" })" -ForegroundColor Green
                $resourcesPath = $($folderXml.SelectSingleNode("ancestor::*[@ResourcesPath][1]/@ResourcesPath")).Value
                if ($folderXml.ResourcesPath -and $folderXml.ResourcesPath -ne "") { $resourcesPath = $folderXml.ResourcesPath }
                $spFolder = Get-RootFolder -List $SPList -ClientContext $ClientContext
                Add-Files -List $SPList -Folder $spFolder -FolderXml $folderXml -ResourcesPath $resourcesPath -ClientContext $ClientContext -RemoteContext $null
            }

            if($catalogXml.Type -eq "DesignCatalog") {
                Write-Host "`t..COMPOSEDLOOKS" -ForegroundColor Green
                foreach($composedLookXml in $catalogXml.ComposedLook) {
                    if ($composedLookXml.Title -ne $null -and $composedLookXml.Title -ne "") {
                        $composedLookListItem = Get-ComposedLook -Name $composedLookXml.Title -ComposedLooksList $SPList -Web $web -ClientContext $ClientContext
                        if($composedLookListItem -eq $null) {
                            $composedLookListItem = Add-ComposedLook -Name $composedLookXml.Title -MasterPageUrl $composedLookXml.MasterPageUrl -ThemeUrl $composedLookXml.ThemeUrl -ImageUrl $composedLookXml.ImageUrl -FontSchemeUrl $composedLookXml.FontSchemeUrl -DisplayOrder $composedLookXml.DisplayOrder -ComposedLooksList $SPList -Web $web -ClientContext  $ClientContext
                        }
                    }
                }
            }
        }
        Write-Host "FINISH CATALOGS.." -ForegroundColor Green
    }
    end {}
}
function Remove-Lists {
param (
    [parameter(Mandatory=$false, ValueFromPipeline=$true)][System.Xml.XmlElement]$ListsXml,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Site] $site, 
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web, 
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
)
    process {
        if ($ListsXml -eq $null -or $ListsXml -eq "") { return }
        Write-Host "START REMOVE LISTS.." -ForegroundColor Green
        foreach($listXml in $ListsXml.RemoveList) {
            if ($listXml.Title -and $listXml.Title -ne "") {
                Write-Host "`tRemoving list '$($listXml.Title)'" -ForegroundColor Green
                try {
                    if ((-not $ListsXml.Scope) -or ($ListsXml.Scope -match "web")) {
                        Remove-List -ListName $listXml.Title -Web $web -ClientContext $ClientContext
                    } else {
                        Remove-List -ListName $listXml.Title -Web $site.Rootweb -ClientContext $ClientContext
                    }
                    Write-Host "`t..Removed" -ForegroundColor Green
                }
                catch {
                    Write-Host "`t..Exception removing list '$($listXml.Title)', `n$($_.Exception.Message)`n" -ForegroundColor Red
                }
            }
        }
        Write-Host "FINISH REMOVE LISTS.." -ForegroundColor Green
    }
    end {}
}
function Update-Lists {
param (
    [parameter(Mandatory=$false, ValueFromPipeline=$true)][System.Xml.XmlElement]$ListsXml,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Site] $site, 
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web, 
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
)
    process {
        if ($ListsXml -eq $null -or $ListsXml -eq "") { return }
        Write-Host "START LISTS.." -ForegroundColor Green
        foreach($listXml in $ListsXml.List) {
            if ($listXml.Title -and $listXml.Title -ne "") {
                if ((-not $ListsXml.Scope) -or ($ListsXml.Scope -match "web")) {
                    $splist = Update-List -ListXml $listXml -Web $web -ClientContext $ClientContext
                } else {
                    $splist = Update-List -ListXml $listXml -Web $site.RootWeb -ClientContext $ClientContext
                }
            }
        }
        Write-Host "FINISH LISTS.." -ForegroundColor Green
    }
    end {}
}
function Update-List {
param(
    [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][System.Xml.XmlElement]$listxml,
    [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web,
    [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
)
    process {
        $SPList = Get-List -ListName $listxml.Title -Web $web -ClientContext $ClientContext
        if($SPList -eq $null) {
            $SPList = New-ListFromXml -listxml $listxml -Web $web -ClientContext $ClientContext
            Write-Host "LIST CREATED [$($listxml.Title)]" -ForegroundColor White
        } else {
            Write-Host "LIST ALREADY EXISTS [$($listxml.Title)]" -ForegroundColor White
        }

        Write-Host "`tContent Types" -ForegroundColor Green
	    foreach ($ct in $listxml.ContentType) {
            if ($ct.Name -and $ct.Name -ne "") {
                $spContentType = Get-ListContentType -List $SPList -ContentTypeName $ct.Name -ClientContext $ClientContext
    		    if($spContentType -eq $null) {
                    $spContentType = Add-ListContentType -List $SPList -ContentTypeName $ct.Name -Web $web -ClientContext $ClientContext
                    if($spContentType -eq $null) {
                        Write-Error "`t`tContent Type could not be added: $($ct.Name)"
                    } else {
                        Write-Host "`t`tContent Type added: $($ct.Name)" -ForegroundColor Green
                    }
                } else {
                    Write-Host "`t`tContent Type already added: $($ct.Name)" -ForegroundColor Yellow
                }

                if($spContentType -ne $null -and $ct.Default -and [bool]::Parse($ct.Default)) {
                    $newDefaultContentType = $spContentType.Id
                    $folder = [SharePointClient.PSClientContext]::loadContentTypeOrderForFolder($SPList.RootFolder, $ClientContext)
                    $currentContentTypeOrder = $folder.ContentTypeOrder
                    $newDefaultContentTypeId = $null
                    foreach($contentTypeId in $currentContentTypeOrder) {
                        if($($contentTypeId.StringValue).StartsWith($newDefaultContentType)) {
                            $newDefaultContentTypeId = $contentTypeId
                            break;
                        }
                    }
                    if($newDefaultContentTypeId) {
                        $currentContentTypeOrder.remove($newDefaultContentTypeId)
                        $currentContentTypeOrder.Insert(0, $newDefaultContentTypeId)
                        $folder.UniqueContentTypeOrder = $currentContentTypeOrder
                        $folder.Update()
                        $ClientContext.ExecuteQuery()
                        Write-Host "`t`t..Set as default content type" -ForegroundColor Yellow
                    }
                }
            }
	    }
        foreach ($ct in $listxml.RemoveContentType) {
            if ($ct.Name -and $ct.Name -ne "") {
                $spContentType = Get-ListContentType -List $SPList -ContentTypeName $ct.Name -ClientContext $ClientContext
    		    if($spContentType -ne $null) {
                    Remove-ListContentType -List $SPList -ContentTypeName $ct.Name -ClientContext $ClientContext
                    Write-Host "`t`tContent Type deleted: $($ct.Name)" -ForegroundColor Green
                } else {
                    Write-Host "`t`tContent Type already deleted: $($ct.Name)" -ForegroundColor Yellow
                }
            }
        }

        
        Write-Host "`tFields" -ForegroundColor Green
        foreach($field in $listxml.Fields.Field) {
            if ($Field.Name -and $Field.Name -ne "") {
                $spField = Get-ListField -List $SPList -FieldName $Field.Name -ClientContext $ClientContext
                if($spField -eq $null) {
                    $fieldStr = $field.OuterXml.Replace(" xmlns=`"http://schemas.microsoft.com/sharepoint/`"", "")
                    $spField = New-ListField -FieldXml $fieldStr -List $splist -ClientContext $ClientContext
                    Write-Host "`t`tCreated Field: $($Field.DisplayName)" -ForegroundColor Green
                } else {
                    Write-Host "`t`tField already added: $($Field.DisplayName)"
                }
            }
        }
        foreach($Field in $listxml.Fields.UpdateField) {
            if ($Field.Name -and $Field.Name -ne "") {
                $spField = Get-ListField -List $SPList -FieldName $Field.Name -ClientContext $ClientContext
                $needsUpdate = $false
                if($Field.ValidationFormula) {
                    $ValidationFormula = $Field.ValidationFormula
                    $ValidationFormula = $ValidationFormula -replace "&lt;","<"
                    $ValidationFormula = $ValidationFormula -replace "&gt;",">"
                    $ValidationFormula = $ValidationFormula -replace "&amp;","&"
                    if($spField.ValidationFormula -ne $ValidationFormula) {
                        $spField.ValidationFormula = $ValidationFormula
                        $needsUpdate = $true
                    }
                }

                if($Field.ValidationMessage) {
                    if($spField.ValidationMessage -ne $Field.ValidationMessage) {
                        $spField.ValidationMessage = $Field.ValidationMessage
                        $needsUpdate = $true
                    }
                }

                if($needsUpdate -eq $true) {
                    $spField.Update()
                    $ClientContext.ExecuteQuery()
                    Write-Host "`t`tUpdated Field: $($Field.DisplayName)" -ForegroundColor Green
                } else {
                    Write-Host "`t`tDid not need to update Field: $($Field.DisplayName)"
                }
            }
        }
        foreach($Field in $listxml.Fields.RemoveField) {
            if ($Field.Name -and $Field.Name -ne "") {
                Remove-ListField -List $SPList -FieldName $Field.Name -ClientContext $ClientContext
            }
        }

        Write-Host "`tViews" -ForegroundColor Green
        foreach ($view in $listxml.Views.View) {
            $spViews = $null
            if ($view.DisplayName) {
                $spViews = Get-ListView -List $SPList -ViewName $view.DisplayName -ClientContext $ClientContext
            }
            if ($spViews -eq $null -and $view.ServerRelativeUrl -ne "") {
                $spViews = Get-ListViewByServerRelativeUrl -List $SPList -ServerRelativeUrl $view.ServerRelativeUrl -BaseViewId $view.BaseViewID -ClientContext $ClientContext
            }

            foreach($spView in $spViews) {
                if($spView -ne $null) {
                    $viewid = $spView.Id
                    if ($view.DisplayName) {
                        Write-Host "`t`tUpdating List View ($($spView.Id)): $($view.DisplayName)" -ForegroundColor Green
                    } else {
                        Write-Host "`t`tUpdating List View ($($spView.Id)): $($view.ServerRelativeUrl) BaseViewID ($($view.BaseViewID))" -ForegroundColor Green
                    }

                    $DefaultView = $(if ($view.DefaultView) { [bool]::Parse($view.DefaultView) } else {$spView.DefaultView})
                    $ViewJslink = $(if ($view.JSLink) {$view.JSLink} else { $spView.JSLink })
                    $Paged = $(if ($view.RowLimit.Paged) { [bool]::Parse($view.RowLimit.Paged) } else { $spView.Paged })
                    $RowLimit = $(if ($view.RowLimit) { $view.RowLimit.InnerText } else { "$($spView.RowLimit)" })
                    $RowLimit = $(if ($RowLimit -eq $null -or $RowLimit -eq "") { "30" } else { $RowLimit })
                    $Query = $(if ($view.Query) { $view.Query.InnerXml.Replace(" xmlns=`"http://schemas.microsoft.com/sharepoint/`"", "") } else { $spView.ViewQuery })
                    $Query = $(if ($Query -eq $null -or $Query -eq "") { "<OrderBy><FieldRef Name=`"Modified`" Ascending=`"FALSE`" /></OrderBy>" } else { $Query })
                    if ($view.ViewFields.FieldRef) { 
                        $ViewFields = $view.ViewFields.FieldRef | Select -ExpandProperty Name 
                    } else {
                        if ($view.ViewFields) {
                            if ($SPList.BaseType -eq [Microsoft.SharePoint.Client.BaseType]::DocumentLibrary) {
                                $ViewFields = @("DocIcon","LinkFilename","Modified")
                            } elseif ($SPList.BaseType -eq [Microsoft.SharePoint.Client.BaseType]::GenericList) {
                                $ViewFields = @("Title","Modified","ModifiedBy")
                            }
                        } else {
                            $ViewFields = @()
                        }
                    }

                    $spView = Update-ListView -List $SPList -ViewNameOrId $viewid -Paged $Paged -Query $Query -RowLimit $RowLimit -DefaultView $DefaultView -ViewFields $ViewFields -ViewJslink $ViewJslink -ClientContext $ClientContext
                    if ($view.DisplayName) {
                        Write-Host "`t`tUpdated List View: $($view.DisplayName)" -ForegroundColor Green
                    } else {
                        Write-Host "`t`tUpdated List View: $($view.ServerRelativeUrl) BaseViewID ($($view.BaseViewID))" -ForegroundColor Green
                    }
                } else {
                    ## ensure that a view can only be created if the xml config has a displayname
                    if ($view.DisplayName -and $view.DisplayName -ne "") {
                        Write-Host "`t`tCreating List View: $($view.DisplayName)" -ForegroundColor Green
                        $Paged = [bool]::Parse($view.RowLimit.Paged)
                        $PersonalView = [bool]::Parse($view.PersonalView)
                        $DefaultView = [bool]::Parse($view.DefaultView)
                        $RowLimit = $view.RowLimit.InnerText
                        $Query = $view.Query.InnerXml.Replace(" xmlns=`"http://schemas.microsoft.com/sharepoint/`"", "")
                        if ($view.ViewFields.FieldRef) { 
                            $ViewFields = $view.ViewFields.FieldRef | Select -ExpandProperty Name 
                        } else {
                            if ($view.ViewFields) {
                                if ($SPList.BaseType -eq [Microsoft.SharePoint.Client.BaseType]::DocumentLibrary) {
                                    $ViewFields = @("DocIcon","LinkFilename","Modified")
                                } elseif ($SPList.BaseType -eq [Microsoft.SharePoint.Client.BaseType]::GenericList) {
                                    $ViewFields = @("Title","Modified","ModifiedBy")
                                }
                            } else {
                                $ViewFields = @()
                            }
                        }
                        $ViewType = $view.Type
                        $ViewJslink = $(if ($view.JSLink) {$view.JSLink} else {""})
                        $spView = New-ListView -List $SPList -ViewName $view.DisplayName -Paged $Paged -PersonalView $PersonalView -Query $Query -RowLimit $RowLimit -DefaultView $DefaultView -ViewFields $ViewFields -ViewType $ViewType -ViewJslink $ViewJslink -ClientContext $ClientContext
                        Write-Host "`t`tCreated List View: $($view.DisplayName)" -ForegroundColor Green
                        if ($ViewJslink -ne "") {
                            $spView = Update-ListView -List $splist -ViewNameOrId $view.DisplayName -Paged $Paged -Query $Query -RowLimit $RowLimit -DefaultView $DefaultView -ViewFields $ViewFields -ViewJslink $ViewJslink -ClientContext $ClientContext
                            Write-Host "`t`t..Updated List View for JSLink: $($view.DisplayName)" -ForegroundColor Green
                        }
                    }
                }
            }
            # end of view update code
        }

        Write-Host "`tItems" -ForegroundColor Green
        if ($listxml.DeleteItems) {
            foreach($itemXml in $listxml.DeleteItems.Item) {
                if ($itemXml.Url) {
                    $item = Get-ListItem -itemUrl $itemXml.Url -Folder $itemXml.Folder -List $SPList -ClientContext $clientContext
                } elseif ($itemXml.Title) {
                    $item = Get-ListItem -title $itemXml.Title -Folder $itemXml.Folder -List $SPList -ClientContext $clientContext
                } elseif ($itemXml.Id) {
                    $item = Get-ListItem -id $itemXml.Id -Folder $itemXml.Folder -List $SPList -ClientContext $clientContext
                }
                if($item -ne $null) {
                    Remove-ListItem -listItem $item -ClientContext $clientContext
                }
            }
        }
        if ($listxml.UpdateItems) {
            foreach($itemXml in $listxml.UpdateItems.Item) {
                if (($itemXml.Url -and $itemXml.Url -ne "") -or ($itemXml.Title -and $itemXml.Title -ne "") -or ($itemXml.Id -and $itemXml.Id -ne "")) {
                    Update-ListItem -listItemXml $itemXml -List $SPList -ClientContext $clientContext 
                }
            }
        }
        if ($listxml.Items -and ($SPList.BaseType -ne [Microsoft.SharePoint.Client.BaseType]::DocumentLibrary)) {
            foreach($itemXml in $listxml.Items.Item) {
                if ($itemXml.Property) {
                    New-ListItem -listItemXml $itemXml -List $SPList -ClientContext $clientContext 
                }
            }
        }

        Write-Host "`tFILES AND FOLDERS" -ForegroundColor White
        foreach($folderXml in $listxml.Folder) {
        #    Write-Host "`t`t$(if ($folderXml.Url) { $folderXml.Url } else { `"{root folder}`" })" -ForegroundColor Green
            $resourcesPath = $($folderXml.SelectSingleNode("ancestor::*[@ResourcesPath][1]/@ResourcesPath")).Value
            if ($folderXml.ResourcesPath -and $folderXml.ResourcesPath -ne "") { $resourcesPath = $folderXml.ResourcesPath }

            $spFolder = Get-RootFolder -List $SPList -ClientContext $ClientContext
            Add-Files $SPList $spFolder $folderXml $resourcesPath $ClientContext $null
        }

        Write-Host "`tPROPERTYBAG VALUES" -ForegroundColor Green
        foreach ($ProperyBagValueXml in $listxml.PropertyBag.PropertyBagValue) {
            if ($ProperyBagValueXml.Key -and $ProperyBagValueXml.Key -ne "") {
                $Indexable = $false
                if($ProperyBagValueXml.Indexable) {
                    $Indexable = [bool]::Parse($ProperyBagValueXml.Indexable)
                }

                Set-PropertyBagValue -Key $ProperyBagValueXml.Key -Value $ProperyBagValueXml.Value -Indexable $Indexable -List $SPList -ClientContext $ClientContext
            }
        }
        
        Write-Host "`tUPDATING OTHER LIST SETTINGS" -ForegroundColor Green
        $listNeedsUpdate = $false
        
        if($listxml.ContentTypesEnabled -and $listxml.ContentTypesEnabled -ne "") {
            $contentTypesEnabled = [bool]::Parse($listxml.ContentTypesEnabled )
            if($SPList.ContentTypesEnabled -ne $contentTypesEnabled) {
                $SPList.ContentTypesEnabled = $contentTypesEnabled
                Write-Host "`t`tUpdating ContentTypesEnabled"
                $listNeedsUpdate = $true
            }
        }
        if($listxml.Description) {
            $description = $listxml.Description
            if($SPList.Description -ne $description) {
                $SPList.Description = $description
                Write-Host "`t`tUpdating Description"
                $listNeedsUpdate = $true
            }
        }
        if($listxml.EnableAttachments -and $listxml.EnableAttachments -ne "") {
            $enableAttachments = [bool]::Parse($listxml.EnableAttachments  )
            if($SPList.EnableAttachments -ne $enableAttachments) {
                $SPList.EnableAttachments = $enableAttachments
                Write-Host "`t`tUpdating EnableAttachments"
                $listNeedsUpdate = $true
            }
        }
        if($listxml.EnableFolderCreation -and $listxml.EnableFolderCreation -ne "") {
            $enableFolderCreation = [bool]::Parse($listxml.EnableFolderCreation  )
            if($SPList.EnableFolderCreation -ne $enableFolderCreation) {
                $SPList.EnableFolderCreation = $enableFolderCreation
                Write-Host "`t`tUpdating EnableFolderCreation"
                $listNeedsUpdate = $true
            }
        }
        if($listxml.EnableMinorVersions -and $listxml.EnableMinorVersions -ne "") {
            $enableMinorVersions = [bool]::Parse($listxml.EnableMinorVersions)
            if($SPList.EnableMinorVersions -ne $enableMinorVersions) {
                $SPList.EnableMinorVersions = $enableMinorVersions
                Write-Host "`t`tUpdating EnableMinorVersions"
                $listNeedsUpdate = $true
            }
        }
        if($listxml.EnableModeration -and $listxml.EnableModeration -ne "") {
            $enableModeration = [bool]::Parse($listxml.EnableModeration)
            if($SPList.EnableModeration -ne $enableModeration) {
                $SPList.EnableModeration = $enableModeration
                Write-Host "`t`tUpdating EnableModeration"
                $listNeedsUpdate = $true
            }
        }
        if($listxml.EnableVersioning -and $listxml.EnableVersioning -ne "") {
            $enableVersioning = [bool]::Parse($listxml.EnableVersioning)
            if($SPList.EnableVersioning -ne $enableVersioning) {
                $SPList.EnableVersioning = $enableVersioning
                Write-Host "`t`tUpdating EnableVersioning"
                $listNeedsUpdate = $true
            }
        }
        if($listxml.ForceCheckout -and $listxml.ForceCheckout -ne "") {
            $forceCheckout = [bool]::Parse($listxml.ForceCheckout)
            if($SPList.ForceCheckout -ne $forceCheckout) {
                $SPList.ForceCheckout = $forceCheckout
                Write-Host "`t`tUpdating ForceCheckout"
                $listNeedsUpdate = $true
            }
        }
        if($listxml.Hidden -and $listxml.Hidden -ne "") {
            $hidden = [bool]::Parse($listxml.Hidden)
            if($SPList.Hidden -ne $hidden) {
                $SPList.Hidden = $hidden
                Write-Host "`t`tUpdating Hidden"
                $listNeedsUpdate = $true
            }
        }
        if($listxml.OnQuickLaunchBar) {
            $onQuickLaunchBar = [bool]::Parse($listxml.OnQuickLaunchBar)
            if($SPList.OnQuickLaunch -ne $onQuickLaunchBar) {
                $SPList.OnQuickLaunch = $onQuickLaunchBar
                Write-Host "`t`tUpdating OnQuickLaunch"
                $listNeedsUpdate = $true
            }
        }
        if($listxml.NoCrawl -and $listxml.NoCrawl -ne "") {
            $noCrawl = [bool]::Parse($listxml.NoCrawl)
            if($SPList.NoCrawl -ne $noCrawl) {
                $SPList.NoCrawl = $noCrawl
                Write-Host "`t`tUpdating NoCrawl"
                $listNeedsUpdate = $true
            }
        }

        if($listNeedsUpdate) {
            Write-Host "`t`tUpdating List Settings..." -ForegroundColor Green
            $SPList.Update()
            $ClientContext.Load($SPList)
            $ClientContext.ExecuteQuery()
            Write-Host "`t`tUpdated List Settings" -ForegroundColor Green
        }
        $SPList        
    }
    end {}
}
