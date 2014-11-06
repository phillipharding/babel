
$cwd = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
Write-Host "Base folder for PoSH+CSOM Provisioning: $cwd" -ForegroundColor White
$modulesPath = "$cwd\..\Modules"
$assemblyPath = "$cwd\..\Modules\assemblies"

Import-Module "$modulesPath\Load-CSOM.psm1"
Add-InternalDlls -assemblyPath $assemblyPath

Import-Module "$modulesPath\ClientConnection.psm1"
Import-Module "$modulesPath\Columns.psm1"
Import-Module "$modulesPath\ContentTypes.psm1"
Import-Module "$modulesPath\Files.psm1"
Import-Module "$modulesPath\Features.psm1"
Import-Module "$modulesPath\Items.psm1"
Import-Module "$modulesPath\Lists.psm1"
Import-Module "$modulesPath\ManagedProperties.psm1"
Import-Module "$modulesPath\Permissions.psm1"
Import-Module "$modulesPath\PropertyBag.psm1"
Import-Module "$modulesPath\Publishing.psm1"
Import-Module "$modulesPath\Sites.psm1"
Import-Module "$modulesPath\Taxonomy.psm1"
Import-Module "$modulesPath\CustomActions.psm1"
Import-Module "$modulesPath\Webs.psm1"
Import-Module "$modulesPath\SearchCenter.psm1"

# now load the binaries
Add-CSOM
Add-TenantCSOM
