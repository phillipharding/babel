cls

Remove-Module "Load-CSOM"

Remove-Module "ClientConnection"
Remove-Module "Columns"
Remove-Module "ContentTypes"
Remove-Module "Files"
Remove-Module "Features"
Remove-Module "Items"
Remove-Module "Lists"
<#
   Excluding the ManagedProperties extensions since this is probably 
   better managed via the Search Schema Import/Export functionality
#>
## Remove-Module "ManagedProperties"

Remove-Module "Permissions"
Remove-Module "PropertyBag"
Remove-Module "Publishing"
Remove-Module "Sites"
Remove-Module "Taxonomy"
Remove-Module "CustomActions"
Remove-Module "Webs"
Remove-Module "SearchCenter"
