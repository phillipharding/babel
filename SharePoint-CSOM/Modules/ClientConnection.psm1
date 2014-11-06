function Get-WindowsCredentialManagerCredentials {
    param(
        [Parameter(Mandatory=$true)][string]$TargetName
    )
    process {
        $sig = @"
[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
public struct NativeCredential
{
    public UInt32 Flags;
    public CRED_TYPE Type;
    public IntPtr TargetName;
    public IntPtr Comment;
    public System.Runtime.InteropServices.ComTypes.FILETIME LastWritten;
    public UInt32 CredentialBlobSize;
    public IntPtr CredentialBlob;
    public UInt32 Persist;
    public UInt32 AttributeCount;
    public IntPtr Attributes;
    public IntPtr TargetAlias;
    public IntPtr UserName;
 
    internal static NativeCredential GetNativeCredential(Credential cred)
    {
        NativeCredential ncred = new NativeCredential();
        ncred.AttributeCount = 0;
        ncred.Attributes = IntPtr.Zero;
        ncred.Comment = IntPtr.Zero;
        ncred.TargetAlias = IntPtr.Zero;
        ncred.Type = CRED_TYPE.GENERIC;
        ncred.Persist = (UInt32)1;
        ncred.CredentialBlobSize = (UInt32)cred.CredentialBlobSize;
        ncred.TargetName = Marshal.StringToCoTaskMemUni(cred.TargetName);
        ncred.CredentialBlob = Marshal.StringToCoTaskMemUni(cred.CredentialBlob);
        ncred.UserName = Marshal.StringToCoTaskMemUni(System.Environment.UserName);
        return ncred;
    }
}
 
[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
public struct Credential
{
    public UInt32 Flags;
    public CRED_TYPE Type;
    public string TargetName;
    public string Comment;
    public System.Runtime.InteropServices.ComTypes.FILETIME LastWritten;
    public UInt32 CredentialBlobSize;
    public string CredentialBlob;
    public UInt32 Persist;
    public UInt32 AttributeCount;
    public IntPtr Attributes;
    public string TargetAlias;
    public string UserName;
}
 
public enum CRED_TYPE : uint
    {
        GENERIC = 1,
        DOMAIN_PASSWORD = 2,
        DOMAIN_CERTIFICATE = 3,
        DOMAIN_VISIBLE_PASSWORD = 4,
        GENERIC_CERTIFICATE = 5,
        DOMAIN_EXTENDED = 6,
        MAXIMUM = 7,      // Maximum supported cred type
        MAXIMUM_EX = (MAXIMUM + 1000),  // Allow new applications to run on old OSes
    }
 
public class CriticalCredentialHandle : Microsoft.Win32.SafeHandles.CriticalHandleZeroOrMinusOneIsInvalid
{
    public CriticalCredentialHandle(IntPtr preexistingHandle)
    {
        SetHandle(preexistingHandle);
    }
 
    public Credential GetCredential()
    {
        if (!IsInvalid)
        {
            NativeCredential ncred = (NativeCredential)Marshal.PtrToStructure(handle,
                  typeof(NativeCredential));
            Credential cred = new Credential();
            cred.CredentialBlobSize = ncred.CredentialBlobSize;
            cred.CredentialBlob = Marshal.PtrToStringUni(ncred.CredentialBlob,
                  (int)ncred.CredentialBlobSize / 2);
            cred.UserName = Marshal.PtrToStringUni(ncred.UserName);
            cred.TargetName = Marshal.PtrToStringUni(ncred.TargetName);
            cred.TargetAlias = Marshal.PtrToStringUni(ncred.TargetAlias);
            cred.Type = ncred.Type;
            cred.Flags = ncred.Flags;
            cred.Persist = ncred.Persist;
            return cred;
        }
        else
        {
            throw new InvalidOperationException("Invalid CriticalHandle!");
        }
    }
 
    override protected bool ReleaseHandle()
    {
        if (!IsInvalid)
        {
            CredFree(handle);
            SetHandleAsInvalid();
            return true;
        }
        return false;
    }
}
 
[DllImport("Advapi32.dll", EntryPoint = "CredReadW", CharSet = CharSet.Unicode, SetLastError = true)]
public static extern bool CredRead(string target, CRED_TYPE type, int reservedFlag, out IntPtr CredentialPtr);
 
[DllImport("Advapi32.dll", EntryPoint = "CredFree", SetLastError = true)]
public static extern bool CredFree([In] IntPtr cred);
"@
        Add-Type -MemberDefinition $sig -Namespace "ADVAPI32" -Name 'Util'

        try {         
            $nCredPtr= New-Object IntPtr
            $success = [ADVAPI32.Util]::CredRead($TargetName,1,0,[ref] $nCredPtr)
            if ($success) {
                $critCred = New-Object ADVAPI32.Util+CriticalCredentialHandle $nCredPtr
                $cred = $critCred.GetCredential()
                $username = $cred.UserName
                $securePassword = $cred.CredentialBlob | ConvertTo-SecureString -AsPlainText -Force
                $cred = $null
                return new-object System.Management.Automation.PSCredential $username, $securePassword
            } else {
                Write-Error "No credentials were found in Windows Credential Manager for TargetName: $TargetName"
                return $null
            }
        }
        catch {
            Write-Error "No credentials were found in Windows Credential Manager for TargetName: $TargetName"
            return $null
        }
    }
    end {}
}
function Init-CSOMConnector {
    process {
        return @{ `
            csomUrl = $null; `
            csomUsername = $null; `
            csomPassword = $null; `
            csomCredentials = $null; `
            csomCredentialLabel = $null; `
        }
    }
    end {}
}
function Get-CSOMConnection {
    param (
        [parameter(Mandatory=$true)]$conn
    )
    process {
        # set connection details
        $csomSite = $null
        $csomRootweb = $null
        $csomWeb = $null
        $clientContext = $null
        $csomHasconnection = $false
        $credentials = $null

        if ($conn.csomUrl -eq $null -or $conn.csomUrl -eq "") { Throw "Specify the connection URL using `$conn.csomUrl" }

        if ($conn.csomUrl -match "sharepoint.com") {
            # SPO
            if ($conn.csomCredentialLabel -ne $null -and $conn.csomCredentialLabel -ne "") {
                # get credentials from windows credential manager
                $c = Get-WindowsCredentialManagerCredentials $conn.csomCredentialLabel
                if ($c -eq $null) { return }
                $conn.csomUsername = $c.UserName
                $securePassword = $c.Password
            } elseif ($conn.csomCredentials -ne $null) {
                # get credentials from supplied PSCredential object
                $conn.csomUsername = $conn.csomCredentials.UserName
                $securePassword = $conn.csomCredentials.Password
            } else {
                # use supplied UserName/Password
                if ($conn.csomUsername -eq $null -or $conn.csomUsername -eq "") { Throw "Specify the connection username using `$conn.csomUsername" }
                if ($conn.csomPassword -eq $null -or $conn.csomPassword -eq "") { Throw "Specify the connection password using `$conn.csomPassword" }
        
                $securePassword = ConvertTo-SecureString $conn.csomPassword -AsPlainText -Force
            }
        } else {
            # On-Premises
            if ($conn.csomCredentialLabel -ne $null -and $conn.csomCredentialLabel -ne "") {
                # get credentials from windows credential manager
                $c = Get-WindowsCredentialManagerCredentials $conn.csomCredentialLabel
                if ($c -eq $null) { return }
                $conn.csomUsername = $c.UserName
                $securePassword = $c.Password
            } elseif ($conn.csomCredentials -ne $null) {
                # get credentials from supplied PSCredential object
                $conn.csomUsername = $conn.csomCredentials.UserName
                $securePassword = $conn.csomCredentials.Password
            } elseif (($conn.csomUsername -ne $null -and $conn.csomUsername -ne "") -and ($conn.csomPassword -ne $null -and $conn.csomPassword -ne "")) {
                $securePassword = $conn.csomPassword
            }
        }

        try {
            # connect/authenticate to SharePoint and get ClientContext object.. 
            $clientContext = New-Object SharePointClient.PSClientContext($conn.csomUrl) 
     
            if ($conn.csomUrl -match "sharepoint.com") {
                $credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($conn.csomUsername, $securePassword) 
                Write-Host "Using SharePointOnlineCredentials..." -ForegroundColor Green
            } else {
                if (($conn.csomUsername -eq $null -or $conn.csomUsername -eq "") -or ($conn.csomPassword -eq $null -or $conn.csomPassword -eq "")) {
                    Write-Host "Using On-Premises current user Credentials..." -ForegroundColor Green
                } else {
                    $credentials = New-Object System.Net.NetworkCredential($conn.csomUsername, $securePassword)
                    Write-Host "Using On-Premises NetworkCredentials..." -ForegroundColor Green
                }
            }
            if ($credentials -ne $null) {
                $clientContext.Credentials = $credentials
            }
      
            if (!$clientContext.ServerObjectIsNull.Value) { 
                Write-Host "Connected to SharePoint '$($conn.csomUrl)'`nLoading Context..." -ForegroundColor Green 
            }
        
            $csomSite = $clientContext.Site
            $csomRootweb = $clientContext.Site.RootWeb
            $csomWeb = $clientContext.Web
            $clientContext.Load($csomSite)
            $clientContext.Load($csomWeb)
            $clientContext.Load($csomRootweb)
            $clientContext.Load($csomRootweb.AllProperties)
            $clientContext.Load($csomWeb.AllProperties)
            $clientContext.ExecuteQuery()
            $csomHasconnection = $true
        }
        catch { 
            Write-Host "*Exception while connecting: $($_.Exception.Message)" -ForegroundColor Red 
            $csomHasconnection = $false
        }

        if ($csomHasconnection) {
            if ($conn.csomUrl -match "sharepoint.com") {
                Write-Host "Loaded SPO site  $($csomSite.Url)" -ForegroundColor Green
                Write-Host "Loaded SPO rootweb  $($csomRootweb.Url)" -ForegroundColor Green
                Write-Host "Loaded SPO web $($csomWeb.Url)" -ForegroundColor Green
             } else {
                Write-Host "Loaded On-Premises site $($csomSite.Url)" -ForegroundColor Green
                Write-Host "Loaded On-Premises rootweb $($csomRootweb.Url)" -ForegroundColor Green
                Write-Host "Loaded On-Premises web $($csomWeb.Url)" -ForegroundColor Green
            }
        } else {
            # no connection!!
        }
        return @{ HasConnection=$csomHasConnection; Context=$clientContext; Site=$csomSite; RootWeb=$csomRootweb; Web=$csomWeb; Connections=@() }
    }
    end {}
}

