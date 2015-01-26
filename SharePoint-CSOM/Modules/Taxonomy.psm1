
# The taxonomy code is untested

function Get-TaxonomySession {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $taxonomySession = [Microsoft.SharePoint.Client.Taxonomy.TaxonomySession]::GetTaxonomySession($ClientContext)
        $taxonomySession.UpdateCache();
        $ClientContext.Load($taxonomySession);
        $ClientContext.ExecuteQuery();

        $taxonomySession
    }
}
function Get-DefaultSiteCollectionTermStore {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Taxonomy.TaxonomySession]$TaxonomySession,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $termStore = $TaxonomySession.GetDefaultSiteCollectionTermStore()
        $ClientContext.Load($termStore)
        $ClientContext.ExecuteQuery()
        $termStore
    }
}

function Get-TermGroup {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$GroupName,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Taxonomy.TermStore]$TermStore,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        try {
            $groups = $TermStore.Groups
            $ClientContext.Load($groups)
            $ClientContext.ExecuteQuery()

            $group = $groups.GetByName($GroupName)
            $ClientContext.Load($group)
            $ClientContext.ExecuteQuery()
            $group
        }
        catch {
            $null
        }
    }
}
function Add-TermGroup {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$Name,
        [parameter(ValueFromPipelineByPropertyName = $true)][guid]$Id = [guid]::NewGuid(),
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Taxonomy.TermStore]$TermStore,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $group = $TermStore.CreateGroup($Name,$Id)
        #$TermStore.CommitAll()
        $ClientContext.Load($group)
        $ClientContext.ExecuteQuery()
        $group
    }
}

function Get-TermSet {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$SetName,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Taxonomy.TermGroup]$TermGroup,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        try {
            $termSets = $TermGroup.TermSets
            $ClientContext.Load($termSets)
            $ClientContext.ExecuteQuery()

            $termSet = $TermGroup.TermSets.GetByName($SetName)
            $ClientContext.Load($termSet)
            $ClientContext.Load($termSet.TermStore)
            $ClientContext.ExecuteQuery()
            $termSet
        }
        catch {
            $null
        }
    }
}
function Add-TermSet {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$Name,
        [parameter(ValueFromPipelineByPropertyName = $true)][int]$Language = 1033,
        [parameter(ValueFromPipelineByPropertyName = $true)][guid]$Id = [guid]::NewGuid(),
        [parameter(ValueFromPipelineByPropertyName = $true)][bool]$Tagging = $true,
        [parameter(ValueFromPipelineByPropertyName = $true)][bool]$Navigation = $false,
        [parameter(ValueFromPipelineByPropertyName = $true)][bool]$Open = $false,
        [parameter(ValueFromPipelineByPropertyName = $true)][string]$Desc = "",
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Taxonomy.TermGroup]$TermGroup,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $termSet = $TermGroup.CreateTermSet($Name, $Id, $Language)
        $termSet.IsAvailableForTagging = $Tagging
        if ($Navigation) {
            $termSet.SetCustomProperty("_Sys_Nav_IsNavigationTermSet", "True")
        }        
        $termSet.IsOpenForTermCreation = $Open
        $termSet.Description = $Desc
        
        $TermGroup.TermStore.CommitAll()
        $ClientContext.Load($termSet)
        $ClientContext.ExecuteQuery()
        $termSet
    }
}
function Add-Term {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$Name,
        [parameter(ValueFromPipelineByPropertyName = $true)][int]$Language = 1033,
        [parameter(ValueFromPipelineByPropertyName = $true)][guid]$Id = [guid]::NewGuid(),
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Taxonomy.TermSet]$TermSet,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $terms = $TermSet.Terms
        $ClientContext.Load($terms)
        $ClientContext.ExecuteQuery()

        $term = $TermSet.CreateTerm($Name, $Language, $Id)

        $TermSet.TermStore.CommitAll()
        $ClientContext.Load($term)
        $ClientContext.ExecuteQuery()
        $term
    }
}
function Get-Term {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][guid]$Id,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Taxonomy.TermSet]$TermSet,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        try {
            $terms = $TermSet.Terms
            $ClientContext.Load($terms)
            $ClientContext.ExecuteQuery()

            $term = $TermSet.GetTerm($Id)
            $ClientContext.Load($term)
            $ClientContext.ExecuteQuery()
            $term
        }
        catch {
            $null
        }
    }
}
function Get-Terms {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Taxonomy.TermSet]$TermSet,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $terms = $TermSet.Terms
        $ClientContext.Load($terms)
        $ClientContext.ExecuteQuery()
        $terms
    }
}
function Get-ChildTerms {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Taxonomy.Term]$Term,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $terms = $Term.Terms
        $ClientContext.Load($terms)
        $ClientContext.ExecuteQuery()
        $terms
    }
}

function Get-TermsByName {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$Name,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Taxonomy.TermSet]$TermSet,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        try {
            $LabelMatchInformation = New-Object Microsoft.SharePoint.Client.Taxonomy.LabelMatchInformation($ClientContext);
            $LabelMatchInformation.Lcid = 1033
            $LabelMatchInformation.TrimUnavailable = $false         
            $LabelMatchInformation.TermLabel = $Name

            $terms = $TermSet.GetTerms($LabelMatchInformation)
            $ClientContext.Load($terms)
            $ClientContext.ExecuteQuery()
            $terms
        }
        catch {
            $null
        }
    }
}

function Add-ChildTerm {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$Name,
        [parameter(ValueFromPipelineByPropertyName = $true)][int]$Language = 1033,
        [parameter(ValueFromPipelineByPropertyName = $true)][guid]$Id = [guid]::NewGuid(),
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Taxonomy.Term]$parentTerm,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $term = $parentTerm.CreateTerm($Name, $Language, $Id)

        $parentTerm.TermStore.CommitAll()
        $ClientContext.Load($term)
        $ClientContext.ExecuteQuery()
        $term
    }
}

function Update-Term {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][System.Xml.XmlElement]$termXml,
        [parameter(ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Taxonomy.Term]$ParentTerm,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Taxonomy.TermSet]$TermSet,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $cso = $($termXml.SelectSingleNode("ancestor::*[@EnableCustomSortOrder][1]/@EnableCustomSortOrder")).Value
        if (($cso -ne $null) -and (($cso -match "true") -or ($cso -match "yes"))) { $cso = $true }
        else { $cso = $false }

        $term = $null
        $termName = $termXml.Name
        $termId = $(if ($termXml.ID -eq $null -or $termXml.ID -eq "") { "" } else { [guid]($termXml.ID) })
        $termLCID = $(if ($termXml.Language -eq $null -or $termXml.Language -eq "") { $TermSet.TermStore.DefaultLanguage } else { [int]($termXml.Language) })
        $termUrl = $(if ($termXml.NavigateUrl -eq $null) { $null } else { $termXml.NavigateUrl })
        $termDesc = $(if ($termXml.Description -eq $null -or $termXml.Description -eq "") { "" } else { $termXml.Description })
        $tagging = $(if ($termXml.Tagging -eq $null -or $termXml.Tagging -eq "") { $true } else { [bool]::Parse($termXml.Tagging) })
        
        if ($ParentTerm -eq $null) {
            $terms = Get-Terms $TermSet $ClientContext
        } else {
            $termName = $termName -replace "{ParentTermName}", $ParentTerm.Name
            $terms = Get-ChildTerms $ParentTerm $ClientContext
        }

        $term = $terms | Where-Object { $_.ID -eq $termId }
        if ($term -eq $null) {
            $term = $terms | Where-Object { $_.Name -eq $termName }
        }
        if ($term -ne $null) { $termId = $term.Id }
        else { $termId = [guid]::NewGuid() }

        if ($ParentTerm -eq $null) {
            Write-Host "`t`tStart> Term '$termName', Language: $termLCID, ID: $termId" -ForegroundColor Green
        } else {
            Write-Host "`t`tStart> Term '$($ParentTerm.Name) -> $termName', Language: $termLCID, ID: $termId" -ForegroundColor Green
        }

        if ($term -eq $null) {
            if ($ParentTerm -eq $null) {
                Write-Host "`t`tCreating Term '$termName' ID: $termId" -ForegroundColor Green
                $term = Add-Term $termName $termLCID $termId $TermSet $ClientContext
            } else {
                Write-Host "`t`t`tCreating Term '$($ParentTerm.Name) -> $termName' ID: $termId" -ForegroundColor Green
                $term = Add-ChildTerm $termName $termLCID $termId $ParentTerm $ClientContext
            }
        } else {
            Write-Host "`t`tUpdating Term '$termName' ID: $termId" -ForegroundColor Green
        }
        if ($term -ne $null) {
            if ($termUrl -ne $null) {
                Write-Host "`t`t..Set _Sys_Nav_SimpleLinkUrl '$termUrl'" -ForegroundColor Green
                $term.SetLocalCustomProperty("_Sys_Nav_SimpleLinkUrl", $termUrl)
                #$term.SetLocalCustomProperty("_Sys_Nav_SimpleLinkUrlDisabled", "")
            }
            if ($termDesc -ne $null -and $termDesc -ne "") {
                Write-Host "`t`t..Set description '$termDesc'" -ForegroundColor Green
                $term.SetDescription($termDesc, $termLCID)
            }
            Write-Host "`t`t..Set IsAvailableForTagging '$tagging'" -ForegroundColor Green
            $term.IsAvailableForTagging = $tagging
        }

        if ($term -ne $null) {
            foreach($termPropertyXml in $termXml.Property) {
                $pname = $termPropertyXml.Name
                $pvalue = $termPropertyXml.Value
                if ($pname -ne $null -and $pname -ne "") {
                    if ($pvalue -eq $null) { $pvalue = "" }
                    if ($termPropertyXml.Type -ne $null -and ($termPropertyXml.Type -match "shared")) {
                        Write-Host "`t`t..Unable to set shared custom property, setting local instead '$pname' to '$pvalue'" -ForegroundColor Blue
                        $term.SetLocalCustomProperty($pname, $pvalue)
                    }
                    else {
                        Write-Host "`t`t..Set local custom property '$pname' to '$pvalue'" -ForegroundColor Green
                        $term.SetLocalCustomProperty($pname, $pvalue)
                    }
                }
            }

            $customSortOrder = @()
            foreach($termChildXml in $termXml.Term) {
                $childTermId = Update-Term $termChildXml $term $TermSet $ClientContext
                $customSortOrder += $childTermId
            }
            if ($cso -eq $true -and ($customSortOrder.length -gt 0)) {
                $customSortOrder = $($customSortOrder -join ":")
                Write-Host "`t`tApplying Custom Sort Order for Term $($term.Name) : $customSortOrder"
                $term.CustomSortOrder = $customSortOrder
            } else {
                $term.CustomSortOrder = ""
            }
        }

        $TermSet.TermStore.CommitAll()
        $ClientContext.ExecuteQuery()
        Write-Host "`t`tFinish> Term '$termName'..." -ForegroundColor Green
        $termId
    }
    end {}
}

function Update-Taxonomy {
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$false, ValueFromPipeline=$true)][System.Xml.XmlElement]$taxonomyXml,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web, 
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        if ($taxonomyXml -eq $null -or $taxonomyXml -eq "") { return }
        Write-Host "Updating Taxonomy..." -ForegroundColor Green
        $taxonomySession = Get-TaxonomySession -ClientContext $ClientContext
        $defaultSiteCollectionTermStore = Get-DefaultSiteCollectionTermStore -TaxonomySession $taxonomySession -ClientContext $ClientContext
        #$ClientContext.Load($web.Fields)
        $ClientContext.ExecuteQuery()
        Write-Host "Got Default Site Collection TermStore..." -ForegroundColor Green

        foreach($termGroupXml in $taxonomyXml.TermGroup) {
            $termGroup = Get-TermGroup -GroupName $termGroupXml.Name -TermStore $defaultSiteCollectionTermStore -ClientContext $ClientContext
            if ($termGroup -eq $null) {
                # add term group
                $tgid = $(if ($termGroupXml.ID -eq $null -or $termGroupXml.ID -eq "") { [guid]::NewGuid() } else { [guid] ($termGroupXml.ID) })
                $termGroup = Add-TermGroup $termGroupXml.Name $tgid $defaultSiteCollectionTermStore $ClientContext
                Write-Host "Created TermGroup: $($termGroup.Name)..." -ForegroundColor Green
            }
            if ($termGroupXml.Description) {
                $termGroup.Description = $termGroupXml.Description
                $defaultSiteCollectionTermStore.CommitAll()
                $ClientContext.ExecuteQuery()
            }
            Write-Host "Updating TermGroup: $($termGroup.Name)..." -ForegroundColor Green

            foreach($termSetXml in $termGroupXml.TermSet) {
                $cso = $($termSetXml.SelectSingleNode("ancestor::*[@EnableCustomSortOrder][1]/@EnableCustomSortOrder")).Value
                if (($cso -ne $null) -and (($cso -match "true") -or ($cso -match "yes"))) { $cso = $true }
                else { $cso = $false }

                $termSet = Get-TermSet $termSetXml.Name $termGroup $ClientContext
                if ($termSet -eq $null) {
                    # add termset
                    $tsid = $(if ($termSetXml.ID -eq $null -or $termSetXml.ID -eq "") { [guid]::NewGuid() } else { [guid]($termSetXml.ID) })
                    $tslcid = $(if ($termSetXml.Language -eq $null -or $termSetXml.Language -eq "") { $defaultSiteCollectionTermStore.DefaultLanguage } else { [int]($termSetXml.Language) })
                    $tagging = $(if ($termSetXml.Tagging -eq $null -or $termSetXml.Tagging -eq "") { $true } else { [bool]::Parse($termSetXml.Tagging) })
                    $navigation = $(if ($termSetXml.Navigation -eq $null -or $termSetXml.Navigation -eq "") { $false } else { [bool]::Parse($termSetXml.Navigation) })
                    $open = $(if ($termSetXml.Open -eq $null -or $termSetXml.Open -eq "") { $false } else { [bool]::Parse($termSetXml.Open) })
                    $desc = $(if ($termSetXml.Description -eq $null -or $termSetXml.Description -eq "") { "" } else { $termSetXml.Description })
                    $termSet = Add-TermSet $termSetXml.Name $tslcid $tsid $tagging $navigation $open $desc $termGroup $ClientContext
                    Write-Host "Created TermSet: $($termSet.Name)... Language: $tslcid, ID: $tsid" -ForegroundColor Green
                    $termSet = Get-TermSet $termSetXml.Name $termGroup $ClientContext
                } else {
                    $tagging = $(if ($termSetXml.Tagging -eq $null -or $termSetXml.Tagging -eq "") { $true } else { [bool]::Parse($termSetXml.Tagging) })
                    $navigation = $(if ($termSetXml.Navigation -eq $null -or $termSetXml.Navigation -eq "") { $false } else { [bool]::Parse($termSetXml.Navigation) })
                    $open = $(if ($termSetXml.Open -eq $null -or $termSetXml.Open -eq "") { $false } else { [bool]::Parse($termSetXml.Open) })
                    $desc = $(if ($termSetXml.Description -eq $null -or $termSetXml.Description -eq "") { "" } else { $termSetXml.Description })

                    $termSet.IsAvailableForTagging = $tagging
                    if ($navigation) {
                        $termSet.SetCustomProperty("_Sys_Nav_IsNavigationTermSet", "True")
                    } else {
                        $termSet.SetCustomProperty("_Sys_Nav_IsNavigationTermSet", "False")
                    }        
                    $termSet.IsOpenForTermCreation = $open
                    $termSet.Description = $desc
                    $defaultSiteCollectionTermStore.CommitAll()
                    $ClientContext.ExecuteQuery()
                }
                Write-Host "Updating TermSet: $($termSet.Name)..." -ForegroundColor Green

                # remove terms
                foreach($removeTermXml in $termSetXml.RemoveTerm) {
                }

                # add terms
                $customSortOrder = @()
                foreach($termXml in $termSetXml.Term) {
                    $childTermId = Update-Term $termXml $null $termSet $ClientContext
                    $customSortOrder += $childTermId
                }
                if ($cso -eq $true -and ($customSortOrder.length -gt 0)) {
                    $customSortOrder = $($customSortOrder -join ":")
                    Write-Host "`tApplying Custom Sort Order for Termset $($termSet.Name) : $customSortOrder"
                    $termSet.CustomSortOrder = $customSortOrder
                } else {
                    $termSet.CustomSortOrder = ""
                }

                $defaultSiteCollectionTermStore.CommitAll()
                $ClientContext.ExecuteQuery()
            }
        }
        Write-Host "Updated Taxonomy..." -ForegroundColor Green
    }
}

function Remove-Taxonomy {
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$false, ValueFromPipeline=$true)][System.Xml.XmlElement]$taxonomyXml,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web, 
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        if ($taxonomyXml -eq $null -or $taxonomyXml -eq "") { return }
        Write-Host "Remove Taxonomy Objects..." -ForegroundColor Green
        $taxonomySession = Get-TaxonomySession -ClientContext $ClientContext
        $defaultSiteCollectionTermStore = Get-DefaultSiteCollectionTermStore -TaxonomySession $taxonomySession -ClientContext $ClientContext
        $ClientContext.Load($web.Fields)
        $ClientContext.ExecuteQuery()
        Write-Host "Got Default Site Collection TermStore..." -ForegroundColor Green

        foreach($termGroupXml in $taxonomyXml.TermGroup) {
            $termGroup = Get-TermGroup -GroupName $termGroupXml.Name $defaultSiteCollectionTermStore $ClientContext
            if ($termGroup -ne $null) {
                Write-Host "Updating TermGroup $($termGroup.Name)..." -ForegroundColor Green
                
                foreach($termSetXml in $termGroupXml.TermSet) {
                    $termSet = Get-TermSet $termSetXml.Name $termGroup $ClientContext
                    if ($termSet -ne $null) {
                        Write-Host "Updating TermSet $($termSet.Name)..." -ForegroundColor Green

                        # remove terms
                        foreach($removeTermXml in $termSetXml.RemoveTerm) {
                        }
                    }
                }
            }
        }

        $defaultSiteCollectionTermStore.CommitAll()
        Write-Host "Removed Taxonomy Objects..." -ForegroundColor Green
    }
}

