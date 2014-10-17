cls
$configurationName = "Default"
$configurationPath = "C:\Dev\github\babel\SharePoint-CSOM\test"
$scriptPath = Split-Path -Parent  $MyInvocation.MyCommand.Definition

# load and init the CSOM helpers
."$scriptPath\load-spo-helpers.ps1"
cls
Add-CSOM
Add-TenantCSOM

# init a blank connector
$connector = Init-CSOMConnection

# set connection url
$connector.csomUrl = "https://platinumdogsconsulting.sharepoint.com/sites/publishing"
#$connector.csomUrl = "http://pub.pdogs.local"

# set credentials with username/password
$connector.csomUsername = ""
$connector.csomPassword = ""

# set credentials using Windows Credential Manager
$connector.csomCredentialLabel = "SPO"

# set credentials with Get-Credentials (prompts for creds)
#$connector.csomCredentials = (Get-Credential | Out-Null)

# connect...
$connection = Get-CSOMConnection $connector
if (-not $connection.HasConnection) { return }
Write-Host "Connected."

