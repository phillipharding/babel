cls
."C:\Dev\github\babel\SharePoint-CSOM\test\test-connect.ps1"
Write-Host 

$doc = [xml] (Get-Content "C:\Dev\github\babel\SharePoint-CSOM\test\site-columns.xml")
$fieldsXml = $doc.SelectSingleNode("*/Fields")
$contentTypesXml = $doc.SelectSingleNode("*/ContentTypes")

foreach ($fieldXml in $fieldsXml.RemoveField) {
    Write-Host "Remove Field $($fieldXml.ID), $($fieldXml.Name)"
}
foreach ($fieldXml in $fieldsXml.Field) {
    Write-Host "Update Field $($fieldXml.ID), $($fieldXml.Name)"
}

foreach ($contentTypeXml in $contentTypesXml.RemoveContentType) {
    Write-Host "Remove ContentType $($contentTypeXml.ID), $($contentTypeXml.Name)"
}
foreach ($contentTypeXml in $contentTypesXml.ContentType) {
    Write-Host "Update ContentType $($contentTypeXml.ID), $($contentTypeXml.Name)"
}
Write-Host

Remove-SiteColumns $fieldsXml $web $clientContext
Write-Host
Update-SiteColumns $fieldsXml $web $clientContext
Write-Host
Update-ContentTypes $contentTypesXml $web $clientContext
