function Set-BreakRoleInheritance  {
<#
http://msdn.microsoft.com/en-us/library/office/microsoft.sharepoint.client.securableobject.breakroleinheritance(v=office.15).aspx
#>
param (
    [parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)][bool] $copyRoleAssignments = $true,
    [parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)][bool] $clearSubscopes = $true,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.SecurableObject] $securableObject,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
)
    process {
        $securableObject.BreakRoleInheritance($copyRoleAssignments, $clearSubscopes)
        $clientContext.ExecuteQuery();
    }
    end {} 
}
function Reset-RoleInheritance  {
<#
http://msdn.microsoft.com/en-us/library/office/microsoft.sharepoint.client.securableobject.resetroleinheritance(v=office.15).aspx
#>
param (
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.SecurableObject] $securableObject,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
)
    process {
        $securableObject.ResetRoleInheritance()
        $clientContext.ExecuteQuery();
    }
    end {} 
}

function Get-SiteGroup {
param (
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$GroupName,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $web,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
)
    process {
        $groups = $web.SiteGroups
        $ClientContext.Load($groups);
        $ClientContext.ExecuteQuery();
        $group = $groups | Where {$_.Title -eq $GroupName}
        $group
    }
    end {}
}

function Add-SiteGroups {
param (
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][System.Xml.XmlElement]$GroupsXml,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $Web,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
)
    process {
        if ($GroupsXml -eq $null -or $GroupsXml -eq "") { return }
        Write-Host "Start Group Definitions.." -ForegroundColor Green
        foreach($groupXml in $GroupsXml.Group) {
            $g = Add-SiteGroup -GroupXml $groupXml -Web $Web -ClientContext $ClientContext
        }
        Write-Host "Finish Group Definitions.." -ForegroundColor Green
    }
    end {}
}
function Add-SiteGroup {
param (
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][System.Xml.XmlElement]$GroupXml,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $Web,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
)
    process {
        $ClientContext.Load($Web.SiteGroups)
        $ClientContext.ExecuteQuery()

        $GroupName = $GroupXml.Title
        $GroupDescription = $(if ($GroupXml.Description) {$GroupXml.Description} else {""})
        $GroupOnlyAllowMembersViewMembership = $(if ($GroupXml.GroupOnlyAllowMembersViewMembership) {[bool]::Parse($GroupXml.GroupOnlyAllowMembersViewMembership)} else {$false})
        #$RolePermissions = $(if ($RoleXml.Permissions) {$RoleXml.Permissions} else {""})

        $group = $Web.SiteGroups | Where {$_.Title -eq $GroupName}
        if ($group -eq $null) {
            Write-Host "`tCreate SiteGroup '$GroupName'" -ForegroundColor Green
            try {
                $groupCreationInformation = New-Object Microsoft.SharePoint.Client.GroupCreationInformation
                $groupCreationInformation.Title = $GroupName
                $groupCreationInformation.Description = $GroupDescription

                $group = $Web.SiteGroups.Add($groupCreationInformation)
                $group.OnlyAllowMembersViewMembership = $GroupOnlyAllowMembersViewMembership
                $group.Update();
                $ClientContext.Load($group);
                $ClientContext.ExecuteQuery();

            }
            catch {
                Write-Host "`tError creating SiteGroup '$GroupName' : Error details $($_.Exception.Message)" -ForegroundColor Red
                $group = $null
            }
        } else {
            Write-Host "`tUpdate SiteGroup '$GroupName'" -ForegroundColor Green
            try {
                $group.Title = $GroupName
                $group.Description = $GroupDescription
                $group.OnlyAllowMembersViewMembership = $GroupOnlyAllowMembersViewMembership
                $group.Update();
                $ClientContext.Load($group);
                $ClientContext.ExecuteQuery();
            }
            catch {
                Write-Host "`tError updating SiteGroup '$GroupName' : Error details $($_.Exception.Message)" -ForegroundColor Red
                $group = $null
            }
        }
        # update the group role definition bindings here
        
        $group
    }
    end {}
}

<#
  public enum PermissionKind
  {
    EmptyMask = 0,
    ViewListItems = 1,
    AddListItems = 2,
    EditListItems = 3,
    DeleteListItems = 4,
    ApproveItems = 5,
    OpenItems = 6,
    ViewVersions = 7,
    DeleteVersions = 8,
    CancelCheckout = 9,
    ManagePersonalViews = 10,
    ManageLists = 12,
    ViewFormPages = 13,
    AnonymousSearchAccessList = 14,
    Open = 17,
    ViewPages = 18,
    AddAndCustomizePages = 19,
    ApplyThemeAndBorder = 20,
    ApplyStyleSheets = 21,
    ViewUsageData = 22,
    CreateSSCSite = 23,
    ManageSubwebs = 24,
    CreateGroups = 25,
    ManagePermissions = 26,
    BrowseDirectories = 27,
    BrowseUserInfo = 28,
    AddDelPrivateWebParts = 29,
    UpdatePersonalWebParts = 30,
    ManageWeb = 31,
    AnonymousSearchAccessWebLists = 32,
    UseClientIntegration = 37,
    UseRemoteAPIs = 38,
    ManageAlerts = 39,
    CreateAlerts = 40,
    EditMyUserInfo = 41,
    EnumeratePermissions = 63,
    FullMask = 65,
  }
#>
function Add-RoleDefintions {
param (
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][System.Xml.XmlElement]$RolesXml,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $Web,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
)
    process {
        if ($RolesXml -eq $null -or $RolesXml -eq "") { return }
        Write-Host "Start Role Definitions.." -ForegroundColor Green
        foreach($roleXml in $RolesXml.Role) {
            $r = Add-RoleDefintion -RoleXml $roleXml -Web $Web -ClientContext $ClientContext
        }
        Write-Host "Finish Role Definitions.." -ForegroundColor Green
    }
    end {}
}
function Add-RoleDefintion {
param (
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][System.Xml.XmlElement]$RoleXml,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.Web] $Web,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][Microsoft.SharePoint.Client.ClientContext]$ClientContext
)
    process {
        $roleDefinitions = $web.RoleDefinitions
        $ClientContext.Load($roleDefinitions)
        $ClientContext.ExecuteQuery()

        $RoleName = $RoleXml.Name
        $RoleDescription = $(if ($RoleXml.Description) {$RoleXml.Description} else {""})
        $RolePermissions = $(if ($RoleXml.Permissions) {$RoleXml.Permissions} else {""})

        $role = $roleDefinitions | Where {$_.Name -eq $RoleName}
        if ($role -eq $null) {
            Write-Host "`tCreate Permission level '$RoleName'" -ForegroundColor Green
            try {
                $role = New-Object Microsoft.SharePoint.Client.RoleDefinitionCreationInformation
                $spBasePerm = New-Object Microsoft.SharePoint.Client.BasePermissions
                $permissions = $RolePermissions -Split ","
                foreach($perm in $permissions) {
                    Write-Host "`t..Set $perm"
                    $spBasePerm.Set($perm)
                }
                 
                $role.Name = $RoleName
                $role.Description = $RoleDescription
                $role.BasePermissions = $spBasePerm
                
                $role = $web.RoleDefinitions.Add($role)
                $ClientContext.ExecuteQuery()
                 
                Write-Host "`tPermission level '$RoleName' created" -ForegroundColor Green
            }
            catch {
                Write-Host "`tError creating Permission level '$RoleName' : Error details $($_.Exception.Message)" -ForegroundColor Red
                $role = $null
            }
        } else {
            Write-Host "`tUpdate Permission level '$RoleName'" -ForegroundColor Green
            try {
                $spBasePerm = $role.BasePermissions
                $permissions = $RolePermissions.split(",");
                foreach($perm in $permissions) {
                    Write-Host "`t..Set $perm"
                    $spBasePerm.Set($perm)
                }

                $role.Description = $RoleDescription
                $role.BasePermissions = $spBasePerm
                $role.Update()
                $ClientContext.ExecuteQuery()
                 
                Write-Host "`tPermission level '$RoleName' updated" -ForegroundColor Green
            }
            catch {
                Write-Host "`tError updating Permission level '$RoleName' : Error details $($_.Exception.Message)" -ForegroundColor Red
                $role = $null
            }
        }
        $role
    }
    end {}
}

