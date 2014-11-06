function Add-Feature {
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][guid]$FeatureId,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)][bool]$fromSandboxSolution = $false,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)][bool]$force = $false,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.FeatureCollection] $Features,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $FeatureDefinitionScope = [Microsoft.SharePoint.Client.FeatureDefinitionScope]::None
        if($fromSandboxSolution) {
            $FeatureDefinitionScope = [Microsoft.SharePoint.Client.FeatureDefinitionScope]::Site
        }
        $feature = $Features | Where {$_.DefinitionId -eq $FeatureId}
        if($feature -eq $null) {
            Write-Host "`tActivating Feature $FeatureId" -ForegroundColor Green
            $f = $Features.Add($FeatureId, $force, $FeatureDefinitionScope)
            try {
                $ClientContext.ExecuteQuery()
                Write-Host "`t..Activated Feature $FeatureId" -ForegroundColor Green
            }
            catch {
                Write-Error "An error occurred whilst Activating feature $FeatureId. Error detail: $($_)"
            }
        }
    }
}
function Remove-Feature {
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][guid]$FeatureId,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)][bool]$force = $false,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.FeatureCollection] $Features,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $feature = $features | Where {$_.DefinitionId -eq $FeatureId}
        if($feature) {
            Write-Host "`tDeactivating Feature $FeatureId" -ForegroundColor Green
            $features.Remove($featureId, $force)
            try {
                $ClientContext.ExecuteQuery()
                Write-Host "`t..Deactivated Feature $FeatureId" -ForegroundColor Green
            }
            catch {
                Write-Error "An error occurred whilst Deactivating feature $FeatureId. Error detail: $($_)"
            }
        }
    }
}
function Add-Features {
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][System.Xml.XmlElement]$FeaturesXml,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Site] $site, 
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        if ($FeaturesXml -eq $null -or $FeaturesXml -eq "") { return }
        if($web) {
            Write-Host "Adding Web Features..." -ForegroundColor Green
            $features = $web.Features
        } elseif($site) {
            Write-Host "Adding Site Features..." -ForegroundColor Green
            $features = $site.Features
        }
        $ClientContext.Load($features)
        $ClientContext.ExecuteQuery()
        foreach($featureXml in $FeaturesXml.Feature) {
            $ignore = $false
            if($featureXml.Ignore) {
                $ignore = [bool]::Parse($featureXml.Ignore)
            }
            if (-not $ignore) {
                $featureId = [guid] $featureXml.FeatureID
                $force = $false
                if($featureXml.Force) {
                    $force = [bool]::Parse($featureXml.Force)
                }
                $SandboxSolution = $false
                if($featureXml.SandboxSolution) {
                    $SandboxSolution = [bool]::Parse($featureXml.SandboxSolution)
                }
                Add-Feature -featureId $featureId -force $force -fromSandboxSolution $SandboxSolution -features $features -ClientContext $ClientContext
            }
        }
        Write-Host "Done" -ForegroundColor Green
    }
}
function Remove-Features {
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][System.Xml.XmlElement]$FeaturesXml,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Site] $site, 
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        if ($FeaturesXml -eq $null -or $FeaturesXml -eq "") { return }
        if($web) {
            Write-Host "Removing Web Features..." -ForegroundColor Green
            $features = $web.Features
        } elseif($site) {
            Write-Host "Removing Site Features..." -ForegroundColor Green
            $features = $site.Features
        }
        $ClientContext.Load($features)
        $ClientContext.ExecuteQuery()

        foreach($featureXml in $FeaturesXml.Feature) {
            $ignore = $false
            if($featureXml.Ignore) {
                $ignore = [bool]::Parse($featureXml.Ignore)
            }
            if (-not $ignore) {
                $featureId = [guid] $featureXml.FeatureID
                $force = $false
                if($featureXml.Force) {
                    $force = [bool]::Parse($featureXml.Force)
                }
                Remove-Feature -featureId $featureId -force $force -features $features -ClientContext $ClientContext
            }
        }
        Write-Host "Done" -ForegroundColor Green
    }
}