﻿cls
$scriptRoot = "C:\Dev\github\babel\SharePoint-CSOM"
$modulesPath = "$scriptRoot\Modules"
$assemblyPath = "$scriptRoot\Assemblies"

Remove-Module "Load-CSOM"

Remove-Module "Columns"
Remove-Module "ContentTypes"
Remove-Module "Files"
Remove-Module "Features"
Remove-Module "Items"
Remove-Module "Lists"
Remove-Module "ManagedProperties"
Remove-Module "Permissions"
Remove-Module "PropertyBag"
Remove-Module "Publishing"
Remove-Module "Sites"
Remove-Module "Taxonomy"
Remove-Module "Webs"
Remove-Module "SearchCenter"
