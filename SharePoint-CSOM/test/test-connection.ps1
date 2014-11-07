<#
   Demonstrates how to create a CSOM connection to a SharePoint Server/SharePoint Online site and web
#>
cls
$cwd = Split-Path -Parent $MyInvocation.MyCommand.Definition

# load and init the CSOM modules
."..\modules\load-spo-modules.ps1"

# create a blank connector
$connector = Init-CSOMConnector

<# set the connection url #>
$connector.csomUrl = "https://platinumdogsconsulting.sharepoint.com/sites/publishing"
#$connector.csomUrl = "https://rbcom.sharepoint.com/sites/dev-pah"
#$connector.csomUrl = "http://pub.pdogs.local"

<# set credentials with username/password #>
$connector.csomUsername = ""
$connector.csomPassword = ""

<# set credentials using Windows Credential Manager #>
#$connector.csomCredentialLabel = "RB.COM SPO"
$connector.csomCredentialLabel = "SPO"

<# set credentials with Get-Credentials (prompts for creds) #>
#$connector.csomCredentials = (Get-Credential | Out-Null)

# connect...
$connection = Get-CSOMConnection $connector
if (-not $connection.HasConnection) { return }
Write-Host "Connected."

Write-Host "AllProperties @ $($connection.RootWeb.ServerRelativeUrl)"
$connection.RootWeb.AllProperties.FieldValues|%{ $_ }|ft 
Write-Host ""
Write-Host "AllProperties @ $($connection.Web.ServerRelativeUrl)"
$connection.Web.AllProperties.FieldValues|%{ $_ }|ft 
