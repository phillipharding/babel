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
            Write-Verbose "`tActivating Feature $FeatureId" -Verbose
            $f = $Features.Add($FeatureId, $force, $FeatureDefinitionScope)
            try {
                $ClientContext.ExecuteQuery()
                Write-Verbose "`t..Activated Feature $FeatureId" -Verbose
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
            Write-Verbose "`tDeactivating Feature $FeatureId" -Verbose
            $features.Remove($featureId, $force)
            try {
                $ClientContext.ExecuteQuery()
                Write-Verbose "`t..Deactivated Feature $FeatureId" -Verbose
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
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][System.Xml.XmlElement]$FeaturesXml,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Site] $site, 
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        if($web) {
            Write-Verbose "Adding Web Features..." -Verbose
            $features = $web.Features
        } elseif($site) {
            Write-Verbose "Adding Site Features..." -Verbose
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
        Write-Verbose "Done" -Verbose
    }
}
function Remove-Features {
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][System.Xml.XmlElement]$FeaturesXml,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Site] $site, 
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        if($web) {
            Write-Verbose "Removing Web Features..." -Verbose
            $features = $web.Features
        } elseif($site) {
            Write-Verbose "Removing Site Features..." -Verbose
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
        Write-Verbose "Done" -Verbose
    }
}