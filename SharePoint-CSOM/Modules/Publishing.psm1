<#
    var importingWebPart = mgr.ImportWebPart(webPartXml).WebPart; 
    var wpDefinition = mgr.AddWebPart(importingWebPart, "Top", 1);
    mgr.Context.Load(wpDefinition, d => d.Id); // need the Id of the hidden view which gets automatically created
    mgr.Context.ExecuteQuery();
    var viewId = wpDefinition.Id;

    List list = web.Lists.GetByTitle("Library Title");
    View view = list.Views.GetById(viewId);
    view.ViewFields.RemoveAll();
    view.ViewFields.Add("Title");
    view.ViewQuery = "<Where><Eq><FieldRef Name=\"Title\" /><Value Type=\"Text\">Something Here</Value></Eq></Where>";
    view.RowLimit = 10;
    view.Update();
    web.Context.ExecuteQuery();
#>
function Update-WebParts {
    [cmdletbinding()]
    param (
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][System.Xml.XmlElement]$PageXml,
        [parameter(Mandatory=$false, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.List]$List,
        [parameter(Mandatory=$false, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Site] $Site, 
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web]$Web,
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
    )
    process {
        if (-not ($PageXml.Url -match ".aspx$")) {
            Write-Host "`t`t$($PageXml.Url) is not a publishing or webpart page" -ForegroundColor Green
            return
        }
        Write-Host "`t`tUpdate WebParts on $($PageXml.Url)" -ForegroundColor Green
        $pageAlreadyExists = $false
        $siteUrl = ""
        if ($Site -eq $null) {
            $ClientContext.Load($Web.SiteUserInfoList)
            $ClientContext.Load($Web.SiteUserInfoList.ParentWeb)
            $ClientContext.Load($Web.SiteUserInfoList.ParentWeb.RootFolder)
            $ClientContext.ExecuteQuery()
            $siteUrl = $($Web.SiteUserInfoList.ParentWeb.RootFolder.ServerRelativeUrl) -replace "/$",""
        } else {
            $siteUrl = $($site.ServerRelativeUrl) -replace "/$",""
        }

        # get list information
        $pagesList = $(if ($List -ne $null) { $List } else { $Web.Lists.GetByTitle("Pages") })
        
        $ClientContext.Load($pagesList)
        $ClientContext.Load($pagesList.RootFolder)
        $ClientContext.ExecuteQuery()

        $MajorVersionsEnabled = $pagesList.EnableVersioning
        $MinorVersionsEnabled = $pagesList.EnableMinorVersions
        $ContentApprovalEnabled = $pagesList.EnableModeration
        $CheckOutRequired = $pagesList.ForceCheckout

        # get page
        $pageFile = Get-File "$($pagesList.RootFolder.ServerRelativeUrl)/$($PageXml.Url)" $web $ClientContext
        if ($pageFile -eq $null) {
            Write-Host "`t..Page '$($PageXml.Url)' was not found" -ForegroundColor Red
            return
        }

        if($pageFile.CheckOutType -eq [Microsoft.SharePoint.Client.CheckOutType]::None) {
            Write-Host "`t`t..Checking-out existing page"
            $pageFile.CheckOut()
        }

        # add web parts
        Write-Host "`t`t..Adding WebParts"
        $updatePage = $false
        $limitedWebPartManager = $pageFile.GetLimitedWebPartManager([Microsoft.SharePoint.Client.WebParts.PersonalizationScope]::Shared);
        foreach($wpDefXml in $PageXml.AllUsersWebPart) {
            $wpZoneID = $wpDefXml.WebPartZoneID
            $wpZoneOrder = $wpDefXml.WebPartOrder
            
            $xml = $($wpDefXml.WebPart."#cdata-section")
            if ($xml -eq $null -or $xml -eq "") { $xml = $wpDefXml.WebPart.InnerXml }
            if ($xml -eq $null -or $xml -eq "") { $xml = $wpDefXml.WebPart.InnerText }
            if ($xml -eq $null -or $xml -eq "") { continue }
            $wpXml = $(($xml -replace "~sitecollection",$siteUrl) -replace "~site",$web.ServerRelativeUrl)            
            if ($wpDefXml.ListTitle) {
                Write-Host "`t`t..Add webpart to '$wpZoneID':$wpZoneOrder for list '$($wpDefXml.ListTitle)'" -ForegroundColor Green
            } else {
                Write-Host "`t`t..Add webpart to '$wpZoneID':$wpZoneOrder" -ForegroundColor Green
            }

            Write-Host "`t`t....Importing" -ForegroundColor Green
            $wpD = $limitedWebPartManager.ImportWebPart($wpXml)
            Write-Host "`t`t....Adding" -ForegroundColor Green
            $wpInstDef = $limitedWebPartManager.AddWebPart($wpD.WebPart, $wpZoneID, $wpZoneOrder)
            Write-Host "`t`t....Loading" -ForegroundColor Green
            $ClientContext.Load($wpInstDef)
            $updatePage = $true

            if ($wpDefXml.ListTitle) {
                $wpList = Get-List $wpDefXml.ListTitle $web $ClientContext
                if ($wpList -ne $null) {
                    # update the hidden list view for the list view webpart
                    $view = Get-ListViewById $wpList $wpInstDef.Id $ClientContext
                    Write-Host "`t`t....Update Webpart ListView: $($view.Id)"

                    $DefaultView = $view.DefaultView
                    $ViewJslink = $(if ($wpDefXml.JSLink) {$wpDefXml.JSLink} else { $view.JSLink })
                    $Paged = $(if ($wpDefXml.RowLimit.Paged) { [bool]::Parse($wpDefXml.RowLimit.Paged) } else { $view.Paged })
                    $RowLimit = $(if ($wpDefXml.RowLimit) { $wpDefXml.RowLimit.InnerText } else { "$($view.RowLimit)" })
                    $RowLimit = $(if ($RowLimit -eq $null -or $RowLimit -eq "") { "30" } else { $RowLimit })
                    $Query = $(if ($wpDefXml.Query) { $wpDefXml.Query.InnerXml.Replace(" xmlns=`"http://schemas.microsoft.com/sharepoint/`"", "") } else { $view.ViewQuery })
                    $Query = $(if ($Query -eq $null -or $Query -eq "") { "<OrderBy><FieldRef Name=`"Modified`" Ascending=`"FALSE`" /></OrderBy>" } else { $Query })
                    if ($wpDefXml.ViewFields.FieldRef) { 
                        $ViewFields = $wpDefXml.ViewFields.FieldRef | Select -ExpandProperty Name 
                    } else {
                        if ($wpDefXml.ViewFields) {
                            if ($pagesList.BaseType -eq [Microsoft.SharePoint.Client.BaseType]::DocumentLibrary) {
                                $ViewFields = @("DocIcon","LinkFilename","Modified")
                            } elseif ($pagesList.BaseType -eq [Microsoft.SharePoint.Client.BaseType]::GenericList) {
                                $ViewFields = @("Title","Modified","ModifiedBy")
                            }
                        } else {
                            $ViewFields = @()
                        }
                    }

                    $spView = Update-ListView -List $wpList -ViewNameOrId $wpInstDef.Id -Paged $Paged -Query $Query -RowLimit $RowLimit -DefaultView $DefaultView -ViewFields $ViewFields -ViewJslink $ViewJslink -ClientContext $ClientContext
                    Write-Host "`t`t......Updated Webpart ListView: $($view.Id)"

                }
            }
        }
        if ($updatePage) {
            $ClientContext.ExecuteQuery()
            Write-Host "`t`t..Finished adding webparts"
        }

        # now save/checkin/publish/approve
        $pageFile.CheckIn("Draft Check-in", [Microsoft.SharePoint.Client.CheckinType]::MajorCheckIn)
        Write-Host "`t`t..Checked-in page" -ForegroundColor Green

        if($MinorVersionsEnabled -and $MajorVersionsEnabled) {
            $pageFile.Publish("Publish Page")
            Write-Host "`t`t..Published page" -ForegroundColor Green
        }

        if($ContentApprovalEnabled) {
            $pageFile.Approve("Approve Page")
            Write-Host "`t`t..Approved page" -ForegroundColor Green
        }

        $ClientContext.Load($pageFile)
        $ClientContext.ExecuteQuery()
    }
    end {}
}

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
                    New-PublishingPage $PageXml $site $web $ClientContext
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
        [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Site] $site, 
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

        if($ContentApprovalEnabled) {
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

        Update-WebParts -PageXml $PageXml -List $pagesList -Site $site -Web $web -ClientContext $ClientContext
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
