function Get-File {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$FileServerRelativeUrl,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web, 
        [parameter(Mandatory=$false, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $file = $null

        if ($web.ServerObjectIsNull.HasValue -and $web.ServerObjectIsNull.Value) {
            $ClientContext.Load($web)
            $ClientContext.ExecuteQuery()
        }

        try {
            $file = $web.GetFileByServerRelativeUrl($FileServerRelativeUrl)
            $ClientContext.Load($file)
            $ClientContext.ExecuteQuery()
            if ($file -eq $null -or (-not $file.Exists)) {
                $file = $null
            }
        }
        catch { 
            $file = $null 
        }
        $file
    }
}
function Get-ResourceFile {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$FilePath,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ResourcesPath,
        [parameter(Mandatory=$false, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$RemoteContext
    )
    process {
        $file = $null
        if ($RemoteContext) {
            $fileURL = $resourcesPath+"/"+$filePath.Replace('\', '/')
            $web = $RemoteContext.Web
            $file = $web.GetFileByServerRelativeUrl($fileURL)

            $data = $file.OpenBinaryStream();
            $RemoteContext.Load($file)
            $RemoteContext.ExecuteQuery()
            
            $memStream = New-Object System.IO.MemoryStream
            $data.Value.CopyTo($memStream)
            $file = $memStream.ToArray()

        } else {
             $file = Get-Content -Encoding byte -Path "$resourcesPath\$filePath"
        }
        $file
    }
}
function Get-XMLFile {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$FilePath,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ConfigPath,
        [parameter(Mandatory=$false, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$RemoteContext
    )
    process {
        $xml = New-Object XML
        if ($RemoteContext) {
            $fileURL = $configPath+"/"+$filePath.Replace('\', '/')
            $web = $RemoteContext.Web
            $file = $web.GetFileByServerRelativeUrl($fileURL)

            $data = $file.OpenBinaryStream();
            $RemoteContext.Load($file)
            $RemoteContext.ExecuteQuery()

            [System.IO.Stream]$stream = $data.Value

            $xml.load($stream);
        } else {
            $xml.load("$configPath\$filePath");
        }
        $xml

    }
}
function Upload-File {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$List,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Folder]$Folder,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][System.Xml.XmlElement]$FileXml,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ResourcesPath,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext,
        [parameter(Mandatory=$false, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$RemoteContext
    )
    process {
        $file = $null

        try {
            $folderServerRelativeUrl = $Folder.ServerRelativeUrl
            $fileServerRelativeUrl = "$folderServerRelativeUrl/$($FileXml.Url)"
            Write-Host "`tFile: $fileServerRelativeUrl" -ForegroundColor Green

            $fileCreationInformation = New-Object Microsoft.SharePoint.Client.FileCreationInformation
            $fileCreationInformation.Url = "$fileServerRelativeUrl"
            $fileCreationInformation.Content = Get-ResourceFile -FilePath $FileXml.Path -ResourcesPath $ResourcesPath -RemoteContext $RemoteContext
            if($FileXml.ReplaceContent) {
                $replaceContent = $false
                $replaceContent = [bool]::Parse($FileXml.ReplaceContent)
                $fileCreationInformation.Overwrite = $replaceContent
            }

            # existing file? get and checkout
            $file = Get-File $fileServerRelativeUrl $List.ParentWeb $ClientContext
            if ($file -ne $null -and $file.Exists) {
                if($file.CheckOutType -eq [Microsoft.SharePoint.Client.CheckOutType]::None) {
                    $file.Checkout()
                    Write-Host "`t..Checkout existing file" -ForegroundColor Green
                } else {
                    Write-Host "`t..Existing file already checked-out" -ForegroundColor Green
                }
            }
            
            $file = $Folder.Files.Add($fileCreationInformation)
            $ClientContext.Load($file)
            $ClientContext.ExecuteQuery()

            $item = $file.ListItemAllFields

            if($file.CheckOutType -eq [Microsoft.SharePoint.Client.CheckOutType]::None) {
                $file.CheckOut()
                Write-Host "`t..Checkout uploaded file" -ForegroundColor Green
            }

            $updateItem = $false
            foreach($propertyXml in $FileXml.Property) {
                $propertyXml.Value = $propertyXml.Value -replace "~folderUrl", $folderServerRelativeUrl
                $propertyXml.Value = $propertyXml.Value -replace "~sitecollection", $ClientContext.Site.ServerRelativeUrl
                $propertyXml.Value = $propertyXml.Value -replace "~site", $ClientContext.Web.ServerRelativeUrl
                
                if($propertyXml.Type -and $propertyXml.Type -eq "TaxonomyField") {
                    Write-Host "`t`t..Set file TaxonomyField property $($propertyXml.Name) = $($propertyXml.Value)" -ForegroundColor Green
                    $field = $List.Fields.GetByInternalNameOrTitle($propertyXml.Name)
                    $taxField  = [SharePointClient.PSClientContext]::CastToTaxonomyField($ClientContext, $field)
                    $taxFieldValueCol = New-Object Microsoft.SharePoint.Client.Taxonomy.TaxonomyFieldValueCollection($ClientContext, "", $taxField)
                    $taxFieldValueCol.PopulateFromLabelGuidPairs($propertyXml.Value)
                    $taxField.SetFieldValueByValueCollection($item, $taxFieldValueCol)
                    $updateItem = $true
                } else {
                    if($propertyXml.Name -ne "ContentType") {
                        $item[$propertyXml.Name] = $propertyXml.Value
                        $updateItem = $true
                    }
                    Write-Host "`t`tSet file property: $($propertyXml.Name) = $($propertyXml.Value)" -ForegroundColor Green
                }
            }
            if ($updateItem) {
                $item.Update()
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
            Write-Host "`t..Exception uploading $fileServerRelativeUrl, `n$($_.Exception.Message)`n" -ForegroundColor Red
        }
        $file
    }
    end {}
}
function Update-Folders {
    param (
        [parameter(Mandatory=$false, ValueFromPipeline=$true)][System.Xml.XmlElement]$FoldersXml,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Site] $site, 
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web, 
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        if ($FoldersXml -eq $null -or $FoldersXml -eq "") { return }
        Write-Host "Start Folders.." -ForegroundColor Green
        foreach($folderXml in $FoldersXml.Folder) {
            if ($folderXml.Url -and $folderXml.Url -ne "") {
                $folderPath = ""
                $resourcesPath = ""
                if ($folderXml.SubFolder -and $folderXml.SubFolder -ne "") { $folderPath = $folderXml.SubFolder }
                if ($folderXml.ResourcesPath -and $folderXml.ResourcesPath -ne "") { $resourcesPath = $folderXml.ResourcesPath }

                if ((-not $folderXml.Scope) -or ($folderXml.Scope -match "web")) {
                    $list = Get-List $folderXml.Url $web $ClientContext
                } else {
                    $list = Get-List $folderXml.Url $site.RootWeb $ClientContext
                }
                if ($list -eq $null) { Throw "List '$($folderXml.Url)' was not found!" }
                $folder = Get-RootFolder $list $ClientContext

                if ($folderPath -ne $null -and $folderPath -ne "") {
                    $folderPaths = $folderPath -split "/"
                    foreach($path in $folderPaths) {
                        $childfolder = Get-Folder -Folder $folder -Name $path -ClientContext $ClientContext
                        if($childfolder -eq $null) {
                            $childfolder = $folder.Folders.Add($path)
                            $ClientContext.Load($childfolder)
                            $ClientContext.ExecuteQuery()
                            $folder = $childfolder
                        } else {
                            $folder = $childfolder
                        }
                    }
                }

                Add-Files $list $folder $folderXml $resourcesPath $ClientContext $null
            }
        }
        Write-Host "Finish Folders.." -ForegroundColor Green
    }
    end {}
}
function Add-Files {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$List,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Folder]$Folder,
        [parameter(Mandatory=$false, ValueFromPipeline=$true)][System.Xml.XmlElement]$FolderXml,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ResourcesPath,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext,
        [parameter(Mandatory=$false, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$RemoteContext
    )
    process {
        if ($FolderXml -eq $null -or $FolderXml -eq "") { return }
        if ($ResourcesPath -eq "" -or ($FolderXml.ResourcesPath -and ($FolderXml.ResourcesPath -ne "") )) {
            $ResourcesPath = $FolderXml.ResourcesPath
        }
        Write-Host "`t`tFolder: $($Folder.ServerRelativeUrl)" -ForegroundColor Green
        foreach($fileXml in $FolderXml.File) {
            if ($fileXml.Path -and $fileXml.Path -ne "") {
                Write-Host "$($fileXml.Path)"
                $file = Upload-File -List $List -Folder $Folder -FileXml $fileXml -ResourcesPath $ResourcesPath -ClientContext $clientContext -RemoteContext $RemoteContext
            }
        }

        foreach ($ProperyBagValue in $folderXml.PropertyBag.PropertyBagValue) {
            if ($ProperyBagValue.Key -and $ProperyBagValue.Key -ne "") {
                $Indexable = $false
                if($PropertyBagValue.Indexable) {
                    $Indexable = [bool]::Parse($PropertyBagValue.Indexable)
                }

                Set-PropertyBagValue -Key $ProperyBagValue.Key -Value $ProperyBagValue.Value -Indexable $Indexable -Folder $Folder -ClientContext $ClientContext
            }
        }

        foreach($childfolderXml in $FolderXml.Folder) {
            if ($childfolderXml.Url -and $childfolderXml.Url -ne "") {
                $childFolder = Get-Folder -Folder $Folder -Name $childfolderXml.Url -ClientContext $clientContext
                if($childFolder -eq $null) {
                    $childFolder = $Folder.Folders.Add($childfolderXml.Url)
                    $ClientContext.Load($childFolder)
                    $ClientContext.ExecuteQuery()
                }
                $childfolderResourcesPath = $ResourcesPath
                if ($childfolderXml.ResourcesPath -and ($childfolderXml.ResourcesPath -ne "") ) {
                    $childfolderResourcesPath = $childfolderXml.ResourcesPath
                }
                Add-Files -List $List -Folder $childFolder -FolderXml $childfolderXml -ResourcesPath $childfolderResourcesPath -ClientContext $clientContext -RemoteContext $RemoteContext 
            }
        }
    }
}

function Get-RootFolder {
    param (
        [parameter(Mandatory=$false, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$List,
        [parameter(Mandatory=$false, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web]$Web,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        if ($List) {
            $ClientContext.Load($List.RootFolder)
            $ClientContext.ExecuteQuery()
            $List.RootFolder
        } elseif ($Web) {
            $ClientContext.Load($Web.RootFolder)
            $ClientContext.ExecuteQuery()
            $Web.RootFolder
        }
    }
}
function Get-Folder {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Folder]$Folder,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$Name,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $folderToReturn = $null
        $ClientContext.Load($Folder.Folders)
        $ClientContext.ExecuteQuery()
        $folderToReturn = $Folder.Folders | Where {$_.Name -eq $Name}

        if($folderToReturn -ne $null) {
            $ClientContext.Load($folderToReturn)
            $ClientContext.ExecuteQuery()
        }

        $folderToReturn
    }
}