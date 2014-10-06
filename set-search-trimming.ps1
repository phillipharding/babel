# Author: Mikael Svenson - @mikaelsvenson
# Company: Puzzlepart
# Date: December, 2013
# Reference: http://www.sharepointnutsandbolts.com/2013/12/Using-CSOM-in-PowerShell-scripts-with-Office365.html
cls

# replace these details (also consider using Get-Credential to enter password securely as script runs).. 
$username = "phil.harding@platinumdogsconsulting.onmicrosoft.com"
$password = "Pa`$`$w0rd2"
$password

$url = "https://platinumdogsconsulting.sharepoint.com/search"
# the path to the SharePoint Client dlls' 
$dllPath = "C:\Dev\github\MyPnP\Assemblies\16\"
  
$securePassword = ConvertTo-SecureString $Password -AsPlainText -Force
  
Add-Type -Path "$($dllPath)Microsoft.SharePoint.Client.dll"
Add-Type -Path "$($dllPath)Microsoft.SharePoint.Client.Runtime.dll"
Add-Type -Path "$($dllPath)Microsoft.SharePoint.Client.Publishing.dll"
Add-Type -Path "$($dllPath)Microsoft.SharePoint.Client.Taxonomy.dll"
  
# connect/authenticate to SharePoint Online and get ClientContext object.. 
$clientContext = New-Object Microsoft.SharePoint.Client.ClientContext($url) 
 
#$credentials = New-Object System.Net.NetworkCredential($username, $securePassword) 
$credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($username, $securePassword) 
$clientContext.Credentials = $credentials
  
if (!$clientContext.ServerObjectIsNull.Value) 
{ 
    Write-Host "Connected to SharePoint site: '$Url'" -ForegroundColor Green 
} 
 
$web = $clientContext.Web
$clientContext.Load($web.AllProperties)
$clientContext.ExecuteQuery()
# get guid of the default Pages library to cater for localization
$pagesGuid = $web.AllProperties.FieldValues["__PagesListId"]
$clientContext.ExecuteQuery()
$clientContext.Load($web.Lists)
$list = $web.Lists.GetById($pagesGuid)
$clientContext.Load($list)
$clientContext.Load($list.RootFolder)
$clientContext.ExecuteQuery()
# get localized server relative url
$url = $list.RootFolder.ServerRelativeUrl
 
$page = $web.GetFileByServerRelativeUrl($url +"/results.aspx");
 
try{
$page.CheckOut()
$clientContext.ExecuteQuery()
Write-Host "Checking out page" -ForegroundColor Green 
}
catch{ Write-Host "Page already checked out" -ForegroundColor Yellow}
$wpm = $page.GetLimitedWebPartManager([Microsoft.SharePoint.Client.WebParts.PersonalizationScope]::Shared) 
$clientContext.Load($wpm.WebParts)
$clientContext.ExecuteQuery()
for ($i=0; $i -lt $wpm.WebParts.Count; $i++)
{
    $item = $wpm.WebParts.Item($i)
    $clientContext.Load($item.WebPart)
    $clientContext.ExecuteQuery()
    if( $item.WebPart.Title -eq "Search Results" ) {
        Write-Host "Found result web part" -ForegroundColor Green 
        break;
    }
}
 
$clientContext.Load($item.WebPart.Properties)
$clientContext.ExecuteQuery()
Write-Host "Turning off trimming of duplicates" -ForegroundColor Green
# Read JSON properties and convert to an object
$dataProvider = ConvertFrom-Json $item.WebPart.Properties["DataProviderJSON"]
$dataProvider.TrimDuplicates = $false
# Convert the object back to a JSON string
$item.WebPart.Properties["DataProviderJSON"] = ConvertTo-Json $dataProvider -Compress
$item.SaveWebPartChanges()
$clientContext.ExecuteQuery()
Write-Host "Checking in and publishing page" -ForegroundColor Green 
$page.CheckIn("Modified Search Core Results web part", [Microsoft.SharePoint.Client.CheckinType]::MajorCheckIn)
$page.Publish("Modified Search Core Results web part")
$clientContext.ExecuteQuery()