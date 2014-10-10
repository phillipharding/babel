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
        
        foreach($propertyXml in $listItemXml.Property) {
            if($propertyXml.Type -and $propertyXml.Type -eq "TaxonomyField") {
                Write-Host "`t`t`tSetting TaxonomyField $($propertyXml.Name) to $($propertyXml.Value)" -ForegroundColor Green
                $field = $list.Fields.GetByInternalNameOrTitle($propertyXml.Name)
                $taxField  = [SharePointClient.PSClientContext]::CastToTaxonomyField($clientContext, $field)

                if ($taxField.AllowMultipleValues) {
                    $taxFieldValueCol = New-Object Microsoft.SharePoint.Client.Taxonomy.TaxonomyFieldValueCollection($clientContext, "", $taxField)
                    $taxFieldValueCol.PopulateFromLabelGuidPairs($propertyXml.Value)

                    $taxField.SetFieldValueByValueCollection($newItem, $taxFieldValueCol);
                } else {
                    $newItem[$propertyXml.Name] = $propertyXml.Value
                }

            } else {
                Write-Host "`t`t`tSetting Field $($propertyXml.Name) to $($propertyXml.Value)" -ForegroundColor Green
                $newItem[$propertyXml.Name] = $propertyXml.Value
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
        $listItemCreationInformation = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation 
        $newItem = $list.AddItem($listItemCreationInformation);
        Write-Host "Creating List Item"
        foreach($propertyXml in $listItemXml.Property) {
            if($propertyXml.Type -and $propertyXml.Type -eq "TaxonomyField") {
                Write-Host "Setting TaxonomyField property $($propertyXml.Name) to $($propertyXml.Value)" -ForegroundColor Green
                $field = $list.Fields.GetByInternalNameOrTitle($propertyXml.Name)
                $taxField  = [SharePointClient.PSClientContext]::CastToTaxonomyField($clientContext, $field)
                $taxFieldValueCol = New-Object Microsoft.SharePoint.Client.Taxonomy.TaxonomyFieldValueCollection($clientContext, "", $taxField)
                $taxFieldValueCol.PopulateFromLabelGuidPairs($propertyXml.Value)
                $taxField.SetFieldValueByValueCollection($newItem, $taxFieldValueCol);
            } else {
                Write-Host "Setting field property $($propertyXml.Name) to $($propertyXml.Value)" -ForegroundColor Green
                $newItem[$propertyXml.Name] = $propertyXml.Value
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
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$itemUrl,
        [parameter(Mandatory=$false, ValueFromPipeline=$true)][string]$folder = $null,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$list,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$clientContext
    )
    process {
        $camlQuery = New-Object Microsoft.SharePoint.Client.CamlQuery
        $camlQuery.ViewXml = "<View><Query><Where><Eq><FieldRef Name='FileLeafRef' /><Value Type='Text'>$($itemUrl)</Value></Eq></Where></Query></View>"
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

        $camlQuery = New-Object Microsoft.SharePoint.Client.CamlQuery
        $camlQuery.ViewXml = "<View><Query><Where><Eq><FieldRef Name='FileLeafRef' /><Value Type='Text'>$($listItemXml.Url)</Value></Eq></Where></Query></View>"
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

                $file.CheckIn("Checkin file", [Microsoft.SharePoint.Client.CheckinType]::MajorCheckIn)
                Write-Host "`t..Checkin uploaded file" -ForegroundColor Green
                if ($List.EnableVersioning -and $List.EnableMinorVersions) {
                    $file.Publish("Publish file")
                    Write-Host "`t..Published uploaded file" -ForegroundColor Green
                }
                if ($List.EnableModeration) {
                    $file.Approve("Approve file")
                    Write-Host "`t..Approved uploaded file" -ForegroundColor Green
                }
                $ClientContext.Load($item)
                $ClientContext.ExecuteQuery()
            }
            catch {
                if ($file -ne $null -and $file.Exists) {
                    if($file.CheckOutType -ne [Microsoft.SharePoint.Client.CheckOutType]::None) {
                        Write-Host "`t..Undoing Checkout because an exception occured!" -ForegroundColor Red
                        # undo any checkout
                        $file.UndoCheckOut()
                        $ClientContext.Load($item)
                        $ClientContext.ExecuteQuery()
                    }
                }
                $file = $null
                Write-Host "`t..Exception updating document item $fileServerRelativeUrl, `n$($_.Exception.Message)`n" -ForegroundColor Red
            }
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