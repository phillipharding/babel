
$cwd = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
Write-Host "`nBase folder for POSH+CSOM Provisioning: $cwd" -ForegroundColor White
$modulesPath = "$cwd\..\Modules"
$assemblyPath = "$cwd\..\Modules\assemblies"

Import-Module "$modulesPath\Load-CSOM.psm1"
Add-InternalDlls -assemblyPath $assemblyPath -excludeDlls "*.HttpCommands.dll"
#Add-InternalDlls -assemblyPath $assemblyPath 

Write-Host "Import Modules: " -ForegroundColor White -NoNewLine
$modules = @("ClientConnection.psm1","Columns.psm1","ContentTypes.psm1","Files.psm1","Features.psm1","Items.psm1","Lists.psm1","Permissions.psm1","PropertyBag.psm1","Publishing.psm1","Sites.psm1","Taxonomy.psm1","CustomActions.psm1","Webs.psm1","SearchCenter.psm1")
$modules | % {
   Write-Host "$($_ -replace `".psm1$`",`"`") " -ForegroundColor Yellow -NoNewLine
   Import-Module "$modulesPath\$_" -DisableNameChecking
}
Write-Host 
<#
   Excluding the ManagedProperties extensions since this is probably 
   better managed via the Search Schema Import/Export functionality
#>
##  Import-Module "$modulesPath\ManagedProperties.psm1"

# now load the binaries
Add-CSOM
Add-TenantCSOM
