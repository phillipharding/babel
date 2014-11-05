function New-ListItem {
    [cmdletbinding()]
    param (
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][System.Xml.XmlElement]$listItemXml,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List] $list,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    begin {
    }
    process {
        $listItemCreationInformation = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation 
        $newItem = $list.AddItem($listItemCreationInformation);
        Write-Host "`t`tCreating List Item.." -ForegroundColor Green
        
        $webUrl = ""
        $siteUrl = ""
        $clientContext.Load($list.ParentWeb)
        $ClientContext.Load($list.ParentWeb.SiteUserInfoList)
        $ClientContext.Load($list.ParentWeb.SiteUserInfoList.ParentWeb)
        $ClientContext.Load($list.ParentWeb.SiteUserInfoList.ParentWeb.RootFolder)
        $ClientContext.ExecuteQuery()
        $siteUrl = $($list.ParentWeb.SiteUserInfoList.ParentWeb.RootFolder.ServerRelativeUrl) -replace "/$",""
        $webUrl = $($list.ParentWeb.ServerRelativeUrl) -replace "/$",""

        foreach($propertyXml in $listItemXml.Property) {
            if($propertyXml.Type -and $propertyXml.Type -eq "TaxonomyField") {
                Write-Host "`t..Setting TaxonomyField property $($propertyXml.Name) to $($propertyXml.Value)" -ForegroundColor Green
                $field = $list.Fields.GetByInternalNameOrTitle($propertyXml.Name)
                $taxField  = [SharePointClient.PSClientContext]::CastToTaxonomyField($clientContext, $field)
                $taxFieldValueCol = New-Object Microsoft.SharePoint.Client.Taxonomy.TaxonomyFieldValueCollection($clientContext, "", $taxField)
                $taxFieldValueCol.PopulateFromLabelGuidPairs($propertyXml.Value)
                $taxField.SetFieldValueByValueCollection($newItem, $taxFieldValueCol)
            } elseif ($propertyXml.Type -and ($propertyXml.Type -eq "LookupId" -or $propertyXml.Type -eq "LookupValue")) {
                if ($propertyXml.Type -eq "LookupId") {
                    $li = Get-LookupListItem -id $propertyXml.Value -ListName $propertyXml.LookupListName -Web $list.ParentWeb -ClientContext $ClientContext
                } elseif ($propertyXml.Type -eq "LookupValue") {
                    $li = Get-LookupListItem -title $propertyXml.Value -ListName $propertyXml.LookupListName -Web $list.ParentWeb -ClientContext $ClientContext
                }
                if ($li -ne $null) {
                    $lv = New-Object Microsoft.SharePoint.Client.FieldLookupValue
                    $lv.LookupId = $li["ID"]
                    
                    $newItem[$propertyXml.Name] = $lv
                    Write-Host "`t`tSet page LOOKUP property: $($propertyXml.Name) = $($li["ID"]):$($li["Title"])" -ForegroundColor Green
                }
            } elseif ($propertyXml.Type -and $propertyXml.Type -match "image") {
                $pval = "<img alt='' src='$(($propertyXml.Value -replace `"~sitecollection`",$siteUrl) -replace `"~site`",$webUrl)' style='border: 0px solid;'>"
                $newItem[$propertyXml.Name] = $pval
                Write-Host "`t`tSet page IMAGE property: $($propertyXml.Name) = $pval" -ForegroundColor Green
            } else {
                if($propertyXml.Name -ne "ContentType") {
                    Write-Host "`t..Setting field property $($propertyXml.Name) to $($propertyXml.Value)" -ForegroundColor Green
                    $newItem[$propertyXml.Name] = $propertyXml.Value
                }
            }
        }

        $newItem.Update();
        $clientContext.Load($newItem)
        $clientContext.ExecuteQuery()
        Write-Host "`t`t..Created List Item" -ForegroundColor Green
        $newItem
    }
    end {
    }
}
function Add-ListItems {
[cmdletbinding()]
    param (
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][System.Xml.XmlElement]$ItemsXml,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List] $list,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    begin {
    }
    process {
        $webUrl = ""
        $siteUrl = ""
        $clientContext.Load($list.ParentWeb)
        $ClientContext.Load($list.ParentWeb.SiteUserInfoList)
        $ClientContext.Load($list.ParentWeb.SiteUserInfoList.ParentWeb)
        $ClientContext.Load($list.ParentWeb.SiteUserInfoList.ParentWeb.RootFolder)
        $ClientContext.ExecuteQuery()
        $siteUrl = $($list.ParentWeb.SiteUserInfoList.ParentWeb.RootFolder.ServerRelativeUrl) -replace "/$",""
        $webUrl = $($list.ParentWeb.ServerRelativeUrl) -replace "/$",""

        $listItemCreationInformation = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation 
        $newItem = $list.AddItem($listItemCreationInformation);
        Write-Host "Creating List Item"
        foreach($propertyXml in $listItemXml.Property) {
            if($propertyXml.Type -and $propertyXml.Type -eq "TaxonomyField") {
                Write-Host "`t..Setting TaxonomyField property $($propertyXml.Name) to $($propertyXml.Value)" -ForegroundColor Green
                $field = $list.Fields.GetByInternalNameOrTitle($propertyXml.Name)
                $taxField  = [SharePointClient.PSClientContext]::CastToTaxonomyField($clientContext, $field)
                $taxFieldValueCol = New-Object Microsoft.SharePoint.Client.Taxonomy.TaxonomyFieldValueCollection($clientContext, "", $taxField)
                $taxFieldValueCol.PopulateFromLabelGuidPairs($propertyXml.Value)
                $taxField.SetFieldValueByValueCollection($newItem, $taxFieldValueCol)
            } elseif ($propertyXml.Type -and ($propertyXml.Type -eq "LookupId" -or $propertyXml.Type -eq "LookupValue")) {
                if ($propertyXml.Type -eq "LookupId") {
                    $li = Get-LookupListItem -id $propertyXml.Value -ListName $propertyXml.LookupListName -Web $list.ParentWeb -ClientContext $ClientContext
                } elseif ($propertyXml.Type -eq "LookupValue") {
                    $li = Get-LookupListItem -title $propertyXml.Value -ListName $propertyXml.LookupListName -Web $list.ParentWeb -ClientContext $ClientContext
                }
                if ($li -ne $null) {
                    $lv = New-Object Microsoft.SharePoint.Client.FieldLookupValue
                    $lv.LookupId = $li["ID"]
                    
                    $newItem[$propertyXml.Name] = $lv
                    Write-Host "`t`tSet page LOOKUP property: $($propertyXml.Name) = $($li["ID"]):$($li["Title"])" -ForegroundColor Green
                }
            } elseif ($propertyXml.Type -and $propertyXml.Type -match "image") {
                $pval = "<img alt='' src='$(($propertyXml.Value -replace `"~sitecollection`",$siteUrl) -replace `"~site`",$webUrl)' style='border: 0px solid;'>"
                $newItem[$propertyXml.Name] = $pval
                Write-Host "`t`tSet page IMAGE property: $($propertyXml.Name) = $pval" -ForegroundColor Green
            } else {
                if($propertyXml.Name -ne "ContentType") {
                    Write-Host "`t..Setting field property $($propertyXml.Name) to $($propertyXml.Value)" -ForegroundColor Green
                    $newItem[$propertyXml.Name] = $propertyXml.Value
                }
            }
        }
        $newItem.Update();
        $clientContext.Load($newItem)
        $clientContext.ExecuteQuery()
        Write-Host "Created List Item"
        $newItem
    }
    end {
    }
}
function Get-ListItem {
    param (
        [parameter(Mandatory=$false, ValueFromPipeline=$true)][string]$itemUrl,
        [parameter(Mandatory=$false, ValueFromPipeline=$true)][string]$title,
        [parameter(Mandatory=$false, ValueFromPipeline=$true)][string]$id,
        [parameter(Mandatory=$false, ValueFromPipeline=$true)][string]$folder = $null,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$list,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$clientContext
    )
    process {
        $camlQuery = New-Object Microsoft.SharePoint.Client.CamlQuery
        if ($itemUrl) {
            $camlQuery.ViewXml = "<View><Query><Where><Eq><FieldRef Name='FileLeafRef' /><Value Type='Text'>$($itemUrl)</Value></Eq></Where></Query></View>"
        } elseif ($title) {
            $camlQuery.ViewXml = "<View><Query><Where><Eq><FieldRef Name='Title' /><Value Type='Text'>$($title)</Value></Eq></Where></Query></View>"
        } elseif ($id) {
            $camlQuery.ViewXml = "<View><Query><Where><Eq><FieldRef Name='ID' /><Value Type='Counter'>$($id)</Value></Eq></Where></Query></View>"
        }
        
        if($folder) {
            $clientContext.Load($list.RootFolder)
            $clientContext.ExecuteQuery()
            $camlQuery.FolderServerRelativeUrl = "$($list.RootFolder.ServerRelativeUrl)/$($folder)"
            Write-Host "`tCamlQuery FolderServerRelativeUrl: $($camlQuery.FolderServerRelativeUrl)" -ForegroundColor Green
        }
        $items = $list.GetItems($camlQuery)
        $clientContext.Load($items)
        $clientContext.ExecuteQuery()
        
        $item = $null
        if($items.Count -gt 0) {
            $item = $items[0]
            $clientContext.Load($item)
            $clientContext.ExecuteQuery()
        }
        $item
    }
    end {
    }
}
function Get-LookupListItem {
    param (
        [parameter(Mandatory=$false, ValueFromPipeline=$true)][string]$title,
        [parameter(Mandatory=$false, ValueFromPipeline=$true)][string]$id,
        [parameter(Mandatory=$false, ValueFromPipeline=$true)][string]$listName,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web]$Web,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $list = Get-List -ListName $listName -Web $Web -ClientContext $ClientContext
        if ($list -eq $null) {
            Write-Host "`t..Lookup list $listName not found!" -ForegroundColor Red
            return $null
        }

        $camlQuery = New-Object Microsoft.SharePoint.Client.CamlQuery
        if ($title) {
            $camlQuery.ViewXml = "<View><Query><Where><Eq><FieldRef Name='Title' /><Value Type='Text'>$title</Value></Eq></Where></Query></View>"
        } elseif ($id) {
            $camlQuery.ViewXml = "<View><Query><Where><Eq><FieldRef Name='ID' /><Value Type='Counter'>$id</Value></Eq></Where></Query></View>"
        }
        if ((-not $camlQuery.ViewXml) -or ($camlQuery.ViewXml -eq "")) {
            return $null
        }
        $items = $list.GetItems($camlQuery)
        $ClientContext.Load($items)
        $ClientContext.ExecuteQuery()

        $item = $null
        if($items.Count -gt 0) {
            $item = $items[0]
            $clientContext.Load($list)
            $clientContext.Load($item)
            $clientContext.Load($item.File)
            $clientContext.Load($list.Fields)
            $clientContext.ExecuteQuery()
        }
        $item
    }
    end {}
}
function Update-ListItem {
    param (
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][System.Xml.XmlElement]$listItemXml,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$list,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$clientContext
    )
    process {
        $clientContext.Load($list.RootFolder)
        $clientContext.ExecuteQuery()
        $fileServerRelativeUrl = "$($list.RootFolder.ServerRelativeUrl)"
        if ($listItemXml.folder -ne $null -and $listItemXml.folder -ne "") {
            $fileServerRelativeUrl += "/$($listItemXml.folder)"
        }
        $fileServerRelativeUrl += "/$($listItemXml.Url)"
        $webUrl = ""
        $siteUrl = ""
        $clientContext.Load($list.ParentWeb)
        $ClientContext.Load($list.ParentWeb.SiteUserInfoList)
        $ClientContext.Load($list.ParentWeb.SiteUserInfoList.ParentWeb)
        $ClientContext.Load($list.ParentWeb.SiteUserInfoList.ParentWeb.RootFolder)
        $ClientContext.ExecuteQuery()
        $siteUrl = $($list.ParentWeb.SiteUserInfoList.ParentWeb.RootFolder.ServerRelativeUrl) -replace "/$",""
        $webUrl = $($list.ParentWeb.ServerRelativeUrl) -replace "/$",""
        
        $clientContext.ExecuteQuery()

        $camlQuery = New-Object Microsoft.SharePoint.Client.CamlQuery
        if ($listItemXml.Url) {
            $camlQuery.ViewXml = "<View><Query><Where><Eq><FieldRef Name='FileLeafRef' /><Value Type='Text'>$($listItemXml.Url)</Value></Eq></Where></Query></View>"
        } elseif ($listItemXml.Title) {
            $camlQuery.ViewXml = "<View><Query><Where><Eq><FieldRef Name='Title' /><Value Type='Text'>$($listItemXml.Title)</Value></Eq></Where></Query></View>"
        } elseif ($listItemXml.Id) {
            $camlQuery.ViewXml = "<View><Query><Where><Eq><FieldRef Name='ID' /><Value Type='Counter'>$($listItemXml.Id)</Value></Eq></Where></Query></View>"
        }
        if ((-not $camlQuery.ViewXml) -or ($camlQuery.ViewXml -eq "")) {
            return
        }
        if($listItemXml.folder) {
            $camlQuery.FolderServerRelativeUrl = "$($list.RootFolder.ServerRelativeUrl)/$($listItemXml.folder)"
            Write-Host "CamlQuery FolderServerRelativeUrl: $($camlQuery.FolderServerRelativeUrl)" -ForegroundColor Green
        }
        $items = $list.GetItems($camlQuery)
        $clientContext.Load($items)
        $clientContext.ExecuteQuery()
        
        $item = $null
        if($items.Count -gt 0) {
            $item = $items[0]
            $clientContext.Load($list)
            $clientContext.Load($item)
            $clientContext.Load($item.File)
            $clientContext.Load($list.Fields)
            $clientContext.ExecuteQuery()
        }
        if($item -ne $null) {
            try {
                if ($item.File -ne $null -and $item.File.Exists) {
                    if ($item.File.CheckOutType -eq [Microsoft.SharePoint.Client.CheckOutType]::None) {
                        $item.File.Checkout()
                        Write-Host "`t..Checkout existing file" -ForegroundColor Green
                    } else {
                        Write-Host "`t..Existing file already checked-out" -ForegroundColor Green
                    }
                }

                $updateItem = $false
                foreach($propertyXml in $listItemXml.Property) {
                    if($propertyXml.Type -and $propertyXml.Type -eq "TaxonomyField") {
                        Write-Host "`t..Setting TaxonomyField property $($propertyXml.Name) to $($propertyXml.Value)" -ForegroundColor Green
                        $field = $list.Fields.GetByInternalNameOrTitle($propertyXml.Name)
                        $taxField  = [SharePointClient.PSClientContext]::CastToTaxonomyField($clientContext, $field)
                        $taxFieldValueCol = New-Object Microsoft.SharePoint.Client.Taxonomy.TaxonomyFieldValueCollection($clientContext, "", $taxField)
                        $taxFieldValueCol.PopulateFromLabelGuidPairs($propertyXml.Value)
                        $taxField.SetFieldValueByValueCollection($item, $taxFieldValueCol)
                        $updateItem = $true
                    } elseif ($propertyXml.Type -and ($propertyXml.Type -eq "LookupId" -or $propertyXml.Type -eq "LookupValue")) {
                        if ($propertyXml.Type -eq "LookupId") {
                            $li = Get-LookupListItem -id $propertyXml.Value -ListName $propertyXml.LookupListName -Web $list.ParentWeb -ClientContext $ClientContext
                        } elseif ($propertyXml.Type -eq "LookupValue") {
                            $li = Get-LookupListItem -title $propertyXml.Value -ListName $propertyXml.LookupListName -Web $list.ParentWeb -ClientContext $ClientContext
                        }
                        if ($li -ne $null) {
                            $lv = New-Object Microsoft.SharePoint.Client.FieldLookupValue
                            $lv.LookupId = $li["ID"]
                            
                            $item[$propertyXml.Name] = $lv
                            $updateItem = $true
                            Write-Host "`t`tSet page LOOKUP property: $($propertyXml.Name) = $($li["ID"]):$($li["Title"])" -ForegroundColor Green
                        }
                    } elseif ($propertyXml.Type -and $propertyXml.Type -match "image") {
                        $pval = "<img alt='' src='$(($propertyXml.Value -replace `"~sitecollection`",$siteUrl) -replace `"~site`",$webUrl)' style='border: 0px solid;'>"
                        $item[$propertyXml.Name] = $pval
                        Write-Host "`t`tSet page IMAGE property: $($propertyXml.Name) = $pval" -ForegroundColor Green
                        $updateItem = $true
                    } else {
                        if($propertyXml.Name -ne "ContentType") {
                            Write-Host "`t..Setting field property $($propertyXml.Name) to $($propertyXml.Value)" -ForegroundColor Green
                            $item[$propertyXml.Name] = $propertyXml.Value
                            $updateItem = $true
                        }
                    }
                }

                if ($updateItem) {
                    $item.Update()
                    $ClientContext.Load($item)
                    $ClientContext.Load($item.File)
                    $ClientContext.ExecuteQuery()
                }

                if ($item.File -ne $null -and $item.File.Exists) {
                    $item.File.CheckIn("Checkin file", [Microsoft.SharePoint.Client.CheckinType]::MajorCheckIn)
                    Write-Host "`t..Checkin uploaded file" -ForegroundColor Green
                    if ($List.EnableVersioning -and $List.EnableMinorVersions) {
                        $item.File.Publish("Publish file")
                        Write-Host "`t..Published uploaded file" -ForegroundColor Green
                    }
                    if ($List.EnableModeration) {
                        $item.File.Approve("Approve file")
                        Write-Host "`t..Approved uploaded file" -ForegroundColor Green
                    }
                }
                $ClientContext.Load($item)
                $ClientContext.ExecuteQuery()
            }
            catch {
                if ($item.File -ne $null -and $item.File.Exists) {
                    if($item.File.CheckOutType -ne [Microsoft.SharePoint.Client.CheckOutType]::None) {
                        Write-Host "`t..Undoing Checkout because an exception occured!" -ForegroundColor Red
                        # undo any checkout
                        $item.File.UndoCheckOut()
                        $ClientContext.Load($item)
                        $ClientContext.ExecuteQuery()
                    }
                }
                Write-Host "`t..Exception updating document item $fileServerRelativeUrl, `n$($_.Exception.Message)`n" -ForegroundColor Red
            }
        } else {
            New-ListItem -listItemXml $listItemXml -List $list -ClientContext $ClientContext
        }
    }
    end {}
}
function Remove-ListItem {
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ListItem] $listItem, 
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext] $ClientContext
    )
    process {
        if($listItem -ne $null) {
            $listItem.DeleteObject()
            $ClientContext.ExecuteQuery()
            Write-Host "Deleted List Item"
        }
    }
}