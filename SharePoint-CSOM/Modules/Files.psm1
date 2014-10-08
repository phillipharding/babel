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
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Folder]$Folder,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][System.Xml.XmlElement]$FileXml,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ResourcesPath,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext,
        [parameter(Mandatory=$false, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$RemoteContext,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][bool] $MinorVersionsEnabled = $false,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][bool] $MajorVersionsEnabled = $false,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][bool] $ContentApprovalEnabled = $false
    )
    process {
        
        $folderServerRelativeUrl = $Folder.ServerRelativeUrl
        Write-Host "`tFile: $folderServerRelativeUrl/$($FileXml.Url)" -ForegroundColor Green

        $fileCreationInformation = New-Object Microsoft.SharePoint.Client.FileCreationInformation
        $fileCreationInformation.Url = "$folderServerRelativeUrl/$($FileXml.Url)"
        $fileCreationInformation.Content = Get-ResourceFile -FilePath $FileXml.Path -ResourcesPath $ResourcesPath -RemoteContext $RemoteContext
        if($FileXml.ReplaceContent) {
            $replaceContent = $false
            $replaceContent = [bool]::Parse($FileXml.ReplaceContent)
            $fileCreationInformation.Overwrite = $replaceContent
        }
        
        $file = $Folder.Files.Add($fileCreationInformation)
        $ClientContext.Load($file)
        $ClientContext.ExecuteQuery()

        $item = $file.ListItemAllFields

        if($file.CheckOutType -eq [Microsoft.SharePoint.Client.CheckOutType]::None) {
            $file.CheckOut()
            Write-Host "`t..Checkedout" -ForegroundColor Green
        }

        $updateItem = $false
        foreach($property in $FileXml.Property) {
            $property.Value = $property.Value -replace "~folderUrl", $folderServerRelativeUrl
            $property.Value = $property.Value -replace "~sitecollection", $ClientContext.Site.ServerRelativeUrl
            $property.Value = $property.Value -replace "~site", $ClientContext.Web.ServerRelativeUrl
            if($property.Name -ne "ContentType") {
                $item[$property.Name] = $property.Value
                $updateItem = $true
            }
            Write-Host "`t`tSet File Property: $($property.Name) = $($property.Value)" 
        }
        if ($updateItem) {
            $item.Update()
        }

        $file.CheckIn("Check-in file", [Microsoft.SharePoint.Client.CheckinType]::MajorCheckIn)
        $item.File.Publish("Publishing file")
        $ClientContext.Load($item)
        $ClientContext.ExecuteQuery()

        if($file.CheckOutType -ne [Microsoft.SharePoint.Client.CheckOutType]::None) {
        }

        if($file.Level -eq "Draft" -and $MinorVersionsEnabled -and $MajorVersionsEnabled) {
        }

        if($file.Level -eq "Pending" -and $ContentApprovalEnabled) {
        }
        
        $file
    }
}
function Add-Files {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Folder]$Folder,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][System.Xml.XmlElement]$FolderXml,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$ResourcesPath,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext,
        [parameter(Mandatory=$false, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$RemoteContext,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][bool] $MinorVersionsEnabled = $false,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][bool] $MajorVersionsEnabled = $false,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName = $true)][bool] $ContentApprovalEnabled = $false
    )
    process {
        if ($ResourcesPath -eq "" -or ($FolderXml.ResourcesPath -and ($FolderXml.ResourcesPath -ne "") )) {
            $ResourcesPath = $FolderXml.ResourcesPath
        }
        Write-Host "Folder: $($FolderXml.Url) << $ResourcesPath" -ForegroundColor Green
        foreach($fileXml in $FolderXml.File) {
            if ($fileXml.Path -and $fileXml.Path -ne "") {
                Write-Verbose "$($fileXml.Path)"
                $file = Upload-File -Folder $Folder -FileXml $fileXml -ResourcesPath $ResourcesPath `
                            -MinorVersionsEnabled $MinorVersionsEnabled -MajorVersionsEnabled $MajorVersionsEnabled -ContentApprovalEnabled $ContentApprovalEnabled `
                            -ClientContext $clientContext -RemoteContext $RemoteContext
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
                Add-Files -Folder $childFolder -FolderXml $childfolderXml -ResourcesPath $childfolderResourcesPath `
                    -MinorVersionsEnabled $MinorVersionsEnabled -MajorVersionsEnabled $MajorVersionsEnabled -ContentApprovalEnabled $ContentApprovalEnabled `
                    -ClientContext $clientContext -RemoteContext $RemoteContext 
            }
        }
    }
}

function Get-RootFolder {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$List,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $ClientContext.Load($List.RootFolder)
        $ClientContext.ExecuteQuery()
        $List.RootFolder
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