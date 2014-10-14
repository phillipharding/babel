function Update-PublishingPages {
param (
    [parameter(Mandatory=$false, ValueFromPipeline=$true)][System.Xml.XmlElement]$PagesXml,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Site] $site, 
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web, 
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
)
    process {
        if ($PagesXml -eq $null -or $PagesXml -eq "") { return }
        Write-Host "Start Update Pages.." -ForegroundColor Green
        foreach($PageXml in $PagesXml.Page) {
            if ($PageXml.Url -and $PageXml.Url -ne "") {
                Write-Host "`tUpdating page '$($PageXml.Url)'" -ForegroundColor Green
                try {
                    New-PublishingPage $PageXml $web $ClientContext
                }
                catch {
                    Write-Host "`t..Exception updating page '$($PageXml.Url)', `n$($_)`n" -ForegroundColor Red
                }
            }
        }
        Write-Host "Finish Update Pages.." -ForegroundColor Green
    }
    end {}
}
function Remove-PublishingPages {
param (
    [parameter(Mandatory=$false, ValueFromPipeline=$true)][System.Xml.XmlElement]$PagesXml,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Site] $site, 
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web, 
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
)
    process {
        if ($PagesXml -eq $null -or $PagesXml -eq "") { return }
        Write-Host "Start Remove Pages.." -ForegroundColor Green
        foreach($PageXml in $PagesXml.RemovePage) {
            if ($PageXml.Url -and $PageXml.Url -ne "") {
                Write-Host "`tRemove page '$($PageXml.Url)'" -ForegroundColor Green
                $publishingPage = Get-PublishingPage $PageXml.Url $web $ClientContext
                try {
                    if ($publishingPage -ne $null) {
                        Remove-PublishingPage $publishingPage $web $ClientContext
                        Write-Host "`t..Removed" -ForegroundColor Red
                    } else {
                        Write-Host "`t..Page '$($PageXml.Url)' not found" -ForegroundColor Red
                    }
                }
                catch {
                    Write-Host "`t..Exception removing page '$($PageXml.Url)', `n$($_.Exception.Message)`n" -ForegroundColor Red
                }
            }
        }
        Write-Host "Finish Remove Pages.." -ForegroundColor Green
    }
    end {}
}
function Get-PublishingPage {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$pageUrl,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web]$web,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$clientContext
    )
    process {
        #Write-Host "`tGetting page $($pageUrl)" -ForegroundColor Green
        $pagesLibrary = $web.Lists.GetByTitle("Pages")
        $camlQuery = New-Object Microsoft.SharePoint.Client.CamlQuery
        $camlQuery.ViewXml = "<View><Query><Where><Eq><FieldRef Name='FileLeafRef' /><Value Type='Text'>$($pageUrl)</Value></Eq></Where></Query></View>"
        $items = $pagesLibrary.GetItems($camlQuery)
        $ClientContext.Load($items)
        $ClientContext.ExecuteQuery()
        
        $page = $null
        if($items.Count -gt 0) {
            $page = $items[0]
            $ClientContext.Load($page)
            $ClientContext.ExecuteQuery()
        }
        $page
    }
    end {
    }
}

function Remove-PublishingPage {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ListItem]$PublishingPage,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web]$Web,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        $PublishingPage.DeleteObject()
        $ClientContext.ExecuteQuery()
    }
    end{}
}

function New-PublishingPage {
    [cmdletbinding()]
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][System.Xml.XmlElement]$PageXml,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web]$Web,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        
        Write-Host "`t`tNew Page $($PageXml.Url)" -ForegroundColor Green
        $pageAlreadyExists = $false
        $replaceContent = $false
        if($PageXml.ReplaceContent) {
            $replaceContent = [bool]::Parse($PageXml.ReplaceContent)
        }

        # Get List information
        $pagesList = $Web.Lists.GetByTitle("Pages")
		$clientContext.Load($pagesList)

        # Check for existing Page
        $existingPageFile = Get-File "$($web.ServerRelativeUrl)/Pages/$($PageXml.Url)" $web $ClientContext

        # Get Page Layout
        Write-Host "`t`tGetting Page Layout $($PageXml.PageLayout)" -ForegroundColor Green
        $rootWeb = $ClientContext.Site.RootWeb
        $masterPageCatalog = $rootWeb.GetCatalog([Microsoft.SharePoint.Client.ListTemplateType]::MasterPageCatalog)
        $pageLayoutCamlQuery = New-Object Microsoft.SharePoint.Client.CamlQuery
        $pageLayoutCamlQuery.ViewXml = "<View><Query><Where><Eq><FieldRef Name='FileLeafRef' /><Value Type='Text'>$($PageXml.PageLayout)</Value></Eq></Where></Query></View>"
        $pageLayoutItems = $masterPageCatalog.GetItems($pageLayoutCamlQuery)
        $ClientContext.Load($pageLayoutItems)
        $clientContext.ExecuteQuery()

        # Get Publishing Web
        $publishingWeb = [Microsoft.SharePoint.Client.Publishing.PublishingWeb]::GetPublishingWeb($ClientContext, $Web)
        $ClientContext.Load($publishingWeb)

        # Setup Complete, call server
		$clientContext.ExecuteQuery()

        $MajorVersionsEnabled = $pagesList.EnableVersioning
        $MinorVersionsEnabled = $pagesList.EnableMinorVersions
        $ContentApprovalEnabled = $pagesList.EnableModeration
        $CheckOutRequired = $pagesList.ForceCheckout
		
        if ($existingPageFile -ne $null -and $existingPageFile.Exists)
		{
			Write-Host "`t`t..Page $($PageXml.Url) already exists"
			$pageAlreadyExists = $true
		}
        
        if($pageAlreadyExists -and $replaceContent -eq $false) {
            Write-Host "`t`t..Page $($PageXml.Url) already Exists and ReplaceContent is set to false" -ForegroundColor Blue
            return
        }
        
        # Load Page Layout Item if avilable
        if ($pageLayoutItems.Count -lt 1) {
			Write-Host "`t`tMissing Page Layout $($PageXml.PageLayout), Can not create $($PageXml.Url)" -ForegroundColor Red
            return
		} else {
            $pageLayout = $pageLayoutItems[0]
            $ClientContext.Load($pageLayout)
            $ClientContext.ExecuteQuery()
        }

        # Rename existing page if needed
        if($pageAlreadyExists) {
            $tempPageUrl = $($PageXml.Url -replace ".aspx","-temp.aspx") #$PageXml.Url.Replace(".aspx", "-$(Get-Date -Format "yyyyMMdd-HHmmss").aspx")
            Write-Host "`t`t..Renaming existing page to $($tempPageUrl)"

            if($existingPageFile.CheckOutType -eq [Microsoft.SharePoint.Client.CheckOutType]::None) {
                Write-Host "`t`t..Checking-out existing page"
                $existingPageFile.CheckOut()
            }

            $item = $existingPageFile.ListItemAllFields
			$item["Title"] = $tempPageUrl
            $item["FileLeafRef"] = $tempPageUrl
			$item.Update()
            $ClientContext.ExecuteQuery()
            
            $existingPageFile = Get-File "$($web.ServerRelativeUrl)/Pages/$tempPageUrl" $web $ClientContext

            Write-Host "`t`t..Checking-in existing page"
            $existingPageFile.CheckIn("Checkin", [Microsoft.SharePoint.Client.CheckinType]::MajorCheckIn)
            $ClientContext.ExecuteQuery()
            Write-Host "`t`t..Checked-in existing page"
        }       

        Write-Host "`t`tCreating page $($PageXml.Url) using layout $($PageXml.PageLayout)" -ForegroundColor Green
        
        $publishingPageInformation = New-Object Microsoft.SharePoint.Client.Publishing.PublishingPageInformation
        $publishingPageInformation.Name = $PageXml.Url;
        $publishingPageInformation.PageLayoutListItem = $pageLayout

        $publishingPage = $publishingWeb.AddPublishingPage($publishingPageInformation)
        foreach($propertyXml in $PageXml.Property) {
            if($propertyXml.Type -and $propertyXml.Type -eq "TaxonomyField") {
                Write-Host "`t`t..Setting page TaxonomyField property $($propertyXml.Name) to $($propertyXml.Value)" -ForegroundColor Green
                $field = $pagesList.Fields.GetByInternalNameOrTitle($propertyXml.Name)
                $taxField  = [SharePointClient.PSClientContext]::CastToTaxonomyField($clientContext, $field)

                if ($taxField.AllowMultipleValues) {
                    $taxFieldValueCol = New-Object Microsoft.SharePoint.Client.Taxonomy.TaxonomyFieldValueCollection($clientContext, "", $taxField)
                    $taxFieldValueCol.PopulateFromLabelGuidPairs($propertyXml.Value)

                    $taxField.SetFieldValueByValueCollection($publishingPage.ListItem, $taxFieldValueCol);
                } else {
                    $publishingPage.ListItem[$propertyXml.Name] = $propertyXml.Value
                }

            } elseif ($propertyXml.Name -eq "ContentType") {
                # Do Nothing, use ContentTypeId to set content type
            } elseif($propertyXml.Type -and $propertyXml.Type -match "image") {
                $pval = "<img alt='' src='$(($propertyXml.Value -replace `"~sitecollection`",$site.RootWeb.ServerRelativeUrl) -replace `"~site`",$web.ServerRelativeUrl)' style='border: 0px solid;'>"
                $publishingPage.ListItem[$propertyXml.Name] = $pval
                Write-Host "`t`tSet page IMAGE property: $($propertyXml.Name) = $pval" -ForegroundColor Green
            } elseif($propertyXml.Type -and $propertyXml.Type -match "html") {
                $pval = (($propertyXml.InnerXml -replace "~sitecollection",$site.RootWeb.ServerRelativeUrl) -replace "~site",$web.ServerRelativeUrl)
                $publishingPage.ListItem[$propertyXml.Name] = $pval
                Write-Host "`t`tSet page HTML property: $($propertyXml.Name) = $pval" -ForegroundColor Green
            } else {
                $pval = (($propertyXml.Value -replace "~sitecollection",$site.RootWeb.ServerRelativeUrl) -replace "~site",$web.ServerRelativeUrl)
                $publishingPage.ListItem[$propertyXml.Name] = $pval
                Write-Host "`t`tSet page property: $($propertyXml.Name) = $($pval)" -ForegroundColor Green
            }
        }
        $publishingPage.ListItem.Update()
        $publishingPageFile = $publishingPage.ListItem.File
        $ClientContext.Load($publishingPage)
        $ClientContext.Load($publishingPageFile)
        $ClientContext.ExecuteQuery()

        $publishingPageFile.CheckIn("Draft Check-in", [Microsoft.SharePoint.Client.CheckinType]::MajorCheckIn)
        Write-Host "`t`t..Checkin page" -ForegroundColor Green

        if($MinorVersionsEnabled -and $MajorVersionsEnabled) {
            $publishingPageFile.Publish("Publishing Page")
            Write-Host "`t`t..Published page" -ForegroundColor Green
        }

        if($PageXml.Approval -eq "Approved" -and $ContentApprovalEnabled) {
            $publishingPageFile.Approve("Approving Page")
            Write-Host "`t`t..Approved page" -ForegroundColor Green
        }

        $ClientContext.Load($publishingPageFile)
        $ClientContext.ExecuteQuery()
                
        if($PageXml.WelcomePage) {
            $isWelcomePage = $false
            $isWelcomePage = [bool]::Parse($PageXml.WelcomePage)
            if($isWelcomePage) {
                Set-WelcomePage -WelcomePageUrl $publishingPageFile.ServerRelativeUrl -Web $Web -ClientContext $ClientContext
                Write-Host "`t`t..Set as Welcome page" -ForegroundColor Green
            }
        }

        # Delete orginal page
		if ($pageAlreadyExists)
		{
			$existingPageFile.DeleteObject()
			$ClientContext.ExecuteQuery()
		}        
    }
}

function Delete-PublishingPage {
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][System.Xml.XmlElement]$PageXml,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web]$Web,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {

		$pagesList = $Web.Lists.GetByTitle("Pages");
		$clientContext.Load($pagesList)
		$clientContext.ExecuteQuery()

		$camlQuery = New-Object Microsoft.SharePoint.Client.CamlQuery;
		$camlQuery.ViewXml = "<View><Query><Where><Eq><FieldRef Name='FileLeafRef' /><Value Type='Text'>{0}</Value></Eq></Where></Query></View>" -f $PageXml.Url

		$listItems = $pagesList.GetItems($camlQuery);

		$clientContext.Load($listItems)
		$clientContext.ExecuteQuery()

		if ($listItems.Count -ne 0)
		{
			$item = $listItems[0]
			$item.DeleteObject()
			$clientContext.ExecuteQuery()
		}
    }
}
