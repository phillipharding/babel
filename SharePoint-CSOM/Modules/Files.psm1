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
            Write-Host "`tTARGET FILE [$fileServerRelativeUrl]" -ForegroundColor White
    
            $webUrl = ""
            $siteUrl = ""
            $clientContext.Load($List.ParentWeb)
            $ClientContext.Load($List.ParentWeb.SiteUserInfoList)
            $ClientContext.Load($List.ParentWeb.SiteUserInfoList.ParentWeb)
            $ClientContext.Load($List.ParentWeb.SiteUserInfoList.ParentWeb.RootFolder)
            $ClientContext.ExecuteQuery()
            $siteUrl = $($list.ParentWeb.SiteUserInfoList.ParentWeb.RootFolder.ServerRelativeUrl) -replace "/$",""
            $webUrl = $($list.ParentWeb.ServerRelativeUrl) -replace "/$",""

            $fileContent = Get-ResourceFile -FilePath $FileXml.Path -ResourcesPath $ResourcesPath -RemoteContext $RemoteContext
            if ($FileXml.ReplaceContentTokens -and $FileXml.ReplaceContentTokens -ne "") {
                $replaceTokens = [bool]::Parse($FileXml.ReplaceContentTokens)
                if ($replaceTokens) {
                    $strContent = [System.Text.Encoding]::UTF8.GetString($fileContent)
                    $strContent = $strContent -replace "{{~sitecollection}}",$siteUrl
                    $strContent = $strContent -replace "{{~site}}",$webUrl
                    $fileContent = [System.Text.Encoding]::UTF8.GetBytes($strContent)
                }
            }

            $fileCreationInformation = New-Object Microsoft.SharePoint.Client.FileCreationInformation
            $fileCreationInformation.Url = "$fileServerRelativeUrl"
            $fileCreationInformation.Content = $fileContent
            if($FileXml.ReplaceContent) {
                $replaceContent = $false
                $replaceContent = [bool]::Parse($FileXml.ReplaceContent)
                $fileCreationInformation.Overwrite = $replaceContent
            }

            # existing file? get and checkout
            $file = Get-File $fileServerRelativeUrl $List.ParentWeb $ClientContext
            if ($file -ne $null -and $file.Exists) {
                if ($FileXml.ReplaceFile -and ($FileXml.ReplaceFile -match "true")) {
                    Write-Host "`t..Deleting existing file" -ForegroundColor Green
                    if($file.CheckOutType -eq [Microsoft.SharePoint.Client.CheckOutType]::None) {
                        $file.CheckOut()
                        Write-Host "`t`t..Checkout existing file for delete" -ForegroundColor Green
                    }
                    $file.DeleteObject()
                    $ClientContext.ExecuteQuery()
                    $file = $null
                } else {
                    if($file.CheckOutType -eq [Microsoft.SharePoint.Client.CheckOutType]::None) {
                        $file.Checkout()
                        Write-Host "`t..Checkout existing file" -ForegroundColor Green
                    } else {
                        Write-Host "`t..Existing file already checked-out" -ForegroundColor Green
                    }
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

            $propCount = 0
            $updateItem = $false
            foreach($propertyXml in $FileXml.Property) {
                $propertyXml.Value = $propertyXml.Value -replace "~folderUrl", $folderServerRelativeUrl
                $propertyXml.Value = $propertyXml.Value -replace "~sitecollection", $ClientContext.Site.ServerRelativeUrl
                $propertyXml.Value = $propertyXml.Value -replace "~site", $ClientContext.Web.ServerRelativeUrl
                
                if($propertyXml.Type -and $propertyXml.Type -eq "TaxonomyField") {
                    Write-Host "`t..Setting TaxonomyField property $($propertyXml.Name) to $($propertyXml.Value)" -ForegroundColor Green
                    $field = $list.Fields.GetByInternalNameOrTitle($propertyXml.Name)
                    $taxField  = [SharePointClient.PSClientContext]::CastToTaxonomyField($clientContext, $field)
                    $taxFieldValueCol = New-Object Microsoft.SharePoint.Client.Taxonomy.TaxonomyFieldValueCollection($clientContext, "", $taxField)
                    $taxFieldValueCol.PopulateFromLabelGuidPairs($propertyXml.Value)
                    $taxField.SetFieldValueByValueCollection($item, $taxFieldValueCol)
                    $updateItem = $true
                } elseif ($propertyXml.Type -and ($propertyXml.Type -eq "LookupId" -or $propertyXml.Type -eq "LookupValue")) {
                    if ($propCount -eq 0) {
                        $lfv = Get-LookupFieldValue -propertyXml $propertyXml -Web $list.ParentWeb -ClientContext $ClientContext
                        if ($lfv -ne $null) {
                            $item[$propertyXml.Name] = $lfv
                            $updateItem = $true
                            Write-Host "`t..Setting LOOKUP property: $($propertyXml.Name) = $($lfv.LookupId):" -ForegroundColor Green
                        }
                    } else {
                        Write-Host "`t..Ignoring LOOKUP property: $($propertyXml.Name), LookupId or LookupValue type properties must be the first property set!" -ForegroundColor Red
                    }
                } elseif ($propertyXml.Type -and $propertyXml.Type -match "image") {
                    if ($propertyXml.Value -and $propertyXml.Value -ne "") {
                        $pval = "<img alt='' src='$(($propertyXml.Value -replace `"~sitecollection`",$siteUrl) -replace `"~site`",$webUrl)' style='border: 0px solid;'>"
                    } else {
                        $pval = ""
                    }
                    $item[$propertyXml.Name] = $pval
                    Write-Host "`t..Setting IMAGE property: $($propertyXml.Name) = $pval" -ForegroundColor Green
                    $updateItem = $true
                } else {
                    if($propertyXml.Name -ne "ContentType") {
                        Write-Host "`t..Setting field property $($propertyXml.Name) to $($propertyXml.Value)" -ForegroundColor Green
                        $item[$propertyXml.Name] = $propertyXml.Value
                        $updateItem = $true
                    }
                }
                $propCount += 1
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
                Write-Host "`t..About to Approve uploaded file" -ForegroundColor Green
                $file.Approve("Approve file")
                Write-Host "`t..Approved uploaded file" -ForegroundColor Green
            }
            $ClientContext.Load($item)
            $ClientContext.ExecuteQuery()

            if($FileXml.WelcomePage -and ($FileXml.Url -match ".aspx")) {
                $isWelcomePage = $false
                $isWelcomePage = [bool]::Parse($FileXml.WelcomePage)
                if($isWelcomePage) {
                    $web = $List.ParentWeb
                    Set-WelcomePage -WelcomePageUrl $file.ServerRelativeUrl -Web $web -ClientContext $ClientContext
                    Write-Host "`t..ASPX page set as Welcome page" -ForegroundColor Green
                }
            }
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
        Write-Host "START FOLDERS.." -ForegroundColor Green
        foreach($folderXml in $FoldersXml.Folder) {
            if ($folderXml.Url -and $folderXml.Url -ne "") {
                $folderPath = ""
                $resourcesPath = $($folderXml.SelectSingleNode("ancestor::*[@ResourcesPath][1]/@ResourcesPath")).Value

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
        Write-Host "FINISH FOLDERS..`n" -ForegroundColor Green
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

        $ClientContext.Load($List.ParentWeb)
        $ClientContext.ExecuteQuery()

        Write-Host "`tFOLDER [$($Folder.ServerRelativeUrl)]" -ForegroundColor Green
        foreach($fileXml in $FolderXml.File) {
            if ($fileXml.Path -and $fileXml.Path -ne "") {
                Write-Host "`tSOURCE FILE [$($fileXml.Path)]"
                $file = Upload-File -List $List -Folder $Folder -FileXml $fileXml -ResourcesPath $ResourcesPath -ClientContext $clientContext -RemoteContext $RemoteContext

                Update-WebParts -PageXml $fileXml -List $List -Web $List.ParentWeb -ClientContext $ClientContext
            } elseif ($fileXml.Url -and $fileXml.Url -ne "") {
                Write-Host "`tSOURCE FILE [$($fileXml.Url)]"
                $file = Get-File "$($Folder.ServerRelativeUrl)/$($fileXml.Url)" $List.ParentWeb $ClientContext
                if ($file -ne $null -and $file.Exists) {
                    Update-WebParts -PageXml $fileXml -List $List -Web $List.ParentWeb -ClientContext $ClientContext
                }
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