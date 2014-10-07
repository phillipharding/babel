
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
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Taxonomy.TermGroup]$TermGroup,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $termSet = $TermGroup.CreateTermSet($Name, $Id, $Language)
        if ($Navigation) {
            $termSet.IsAvailableForTagging = $false
            $termSet.IsOpenForTermCreation = $Open
            $termSet.SetCustomProperty("_Sys_Nav_IsNavigationTermSet", "True")
        } else {
            $termSet.IsAvailableForTagging = $Tagging
            $termSet.IsOpenForTermCreation = $Open
        }

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
        $term = $null
        $termName = $termXml.Name
        $tid = $(if ($termXml.ID -eq $null -or $termXml.ID -eq "") { [guid]::NewGuid() } else { [guid]($termXml.ID) })
        $tlcid = $(if ($termXml.Language -eq $null -or $termXml.Language -eq "") { $TermSet.TermStore.DefaultLanguage } else { [int]($termXml.Language) })
        $turl = $(if ($termXml.NavigateUrl -eq $null -or $termXml.NavigateUrl -eq "") { $null } else { $termXml.NavigateUrl })
        $tdesc = $(if ($termXml.Description -eq $null -or $termXml.Description -eq "") { "" } else { $termXml.Description })
        
        if ($ParentTerm -eq $null) {
            Write-Host "Start> Term '$termName', Language: $tlcid, ID: $tid" -ForegroundColor Green
            $terms = Get-Terms $TermSet $ClientContext
        } else {
            Write-Host "Start> Term '$($ParentTerm.Name) -> $termName', Language: $tlcid, ID: $tid" -ForegroundColor Green
            $terms = Get-ChildTerms $ParentTerm $ClientContext
        }
        
        $term = $terms | Where-Object { $_.ID -eq $tid }
        if ($term -eq $null) {
            $term = $terms | Where-Object { $_.Name -eq $termName }
        }

        if ($term -eq $null) {
            if ($ParentTerm -eq $null) {
                Write-Host "Creating Term '$termName' ID: $tid" -ForegroundColor Green
                $term = Add-Term $termName $tlcid $tid $TermSet $ClientContext
            } else {
                Write-Host "Creating Term '$($ParentTerm.Name) -> $termName' ID: $tid" -ForegroundColor Green
                $term = Add-ChildTerm $termName $tlcid $tid $ParentTerm $ClientContext
            }
        } else {
            Write-Host "Updating Term '$termName' ID: $tid" -ForegroundColor Green
        }
        if ($term -ne $null) {
            if ($turl -ne $null) {
                $term.SetLocalCustomProperty("_Sys_Nav_SimpleLinkUrl", $turl);
            }
            if ($tdesc -ne $null -and $tdesc -ne "") {
                $term.SetDescription($tdesc, $tlcid)
            }
        }

        if ($term -ne $null) {
            foreach($termChildXml in $termXml.Term) {
                Update-Term $termChildXml $term $TermSet $ClientContext
            }
        }

        $TermSet.TermStore.CommitAll()
        Write-Host "Finish> Term '$termName'..." -ForegroundColor Green
        #return $term
    }
    end {}
}

function Update-Taxonomy {
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][System.Xml.XmlElement]$taxonomyXml,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web, 
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        Write-Verbose "Updating Taxonomy..." -Verbose
        $taxonomySession = Get-TaxonomySession -ClientContext $ClientContext
        $defaultSiteCollectionTermStore = Get-DefaultSiteCollectionTermStore -TaxonomySession $taxonomySession -ClientContext $ClientContext
        $ClientContext.Load($web.Fields)
        $ClientContext.ExecuteQuery()
        Write-Verbose "Got Default Site Collection TermStore..." -Verbose

        foreach($termGroupXml in $taxonomyXml.TermGroup) {
            $termGroup = Get-TermGroup $termGroupXml.Name $defaultSiteCollectionTermStore $ClientContext
            if ($termGroup -eq $null) {
                # add term group
                $tgid = $(if ($termGroupXml.ID -eq $null -or $termGroupXml.ID -eq "") { [guid]::NewGuid() } else { [guid] ($termGroupXml.ID) })
                $termGroup = Add-TermGroup $termGroupXml.Name $tgid $defaultSiteCollectionTermStore $ClientContext
                Write-Verbose "Created TermGroup $($termGroup.Name)..." -Verbose
            }
            Write-Verbose "Updating TermGroup $($termGroup.Name)..." -Verbose

            foreach($termSetXml in $termGroupXml.TermSet) {
                $termSet = Get-TermSet $termSetXml.Name $termGroup $ClientContext
                if ($termSet -eq $null) {
                    # add termset
                    $tsid = $(if ($termSetXml.ID -eq $null -or $termSetXml.ID -eq "") { [guid]::NewGuid() } else { [guid]($termSetXml.ID) })
                    $tslcid = $(if ($termSetXml.Language -eq $null -or $termSetXml.Language -eq "") { $defaultSiteCollectionTermStore.DefaultLanguage } else { [int]($termSetXml.Language) })
                    $tagging = $(if ($termSetXml.Tagging -eq $null -or $termSetXml.Tagging -eq "") { $true } else { [bool]::Parse($termSetXml.Tagging) })
                    $navigation = $(if ($termSetXml.Navigation -eq $null -or $termSetXml.Navigation -eq "") { $false } else { [bool]::Parse($termSetXml.Navigation) })
                    $open = $(if ($termSetXml.Open -eq $null -or $termSetXml.Open -eq "") { $false } else { [bool]::Parse($termSetXml.Open) })
                    $termSet = Add-TermSet $termSetXml.Name $tslcid $tsid $tagging $navigation $open $termGroup $ClientContext
                    Write-Verbose "Created TermSet $($termSet.Name)... Language: $tslcid, ID: $tsid" -Verbose
                }
                Write-Verbose "Updating TermSet $($termSet.Name)..." -Verbose

                # remove terms
                foreach($removeTermXml in $termSetXml.RemoveTerm) {
                }

                # add terms
                foreach($termXml in $termSetXml.Term) {
                    Update-Term $termXml $null $termSet $ClientContext
                }

            }
        }
        $defaultSiteCollectionTermStore.CommitAll()
        Write-Verbose "Updated Taxonomy..." -Verbose
    }
}

function Remove-Taxonomy {
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][System.Xml.XmlElement]$taxonomyXml,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web, 
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        Write-Verbose "Remove Taxonomy Objects..." -Verbose
        $taxonomySession = Get-TaxonomySession -ClientContext $ClientContext
        $defaultSiteCollectionTermStore = Get-DefaultSiteCollectionTermStore -TaxonomySession $taxonomySession -ClientContext $ClientContext
        $ClientContext.Load($web.Fields)
        $ClientContext.ExecuteQuery()
        Write-Verbose "Got Default Site Collection TermStore..." -Verbose

        foreach($termGroupXml in $taxonomyXml.TermGroup) {
            $termGroup = Get-TermGroup $termGroupXml.Name $defaultSiteCollectionTermStore $ClientContext
            if ($termGroup -ne $null) {
                Write-Verbose "Updating TermGroup $($termGroup.Name)..." -Verbose
                
                foreach($termSetXml in $termGroupXml.TermSet) {
                    $termSet = Get-TermSet $termSetXml.Name $termGroup $ClientContext
                    if ($termSet -ne $null) {
                        Write-Verbose "Updating TermSet $($termSet.Name)..." -Verbose

                        # remove terms
                        foreach($removeTermXml in $termSetXml.RemoveTerm) {
                        }
                    }
                }
            }
        }

        $defaultSiteCollectionTermStore.CommitAll()
        Write-Verbose "Removed Taxonomy Objects..." -Verbose
    }
}

