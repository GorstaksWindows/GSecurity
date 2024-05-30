:: Perms
# Get TrustedInstaller SID
$trustedInstallerSID = "NT SERVICE\TrustedInstaller"

# Get current user's SID and name
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$currentUserSID = $currentUser.User
$currentUserName = $currentUser.Name

# Set TrustedInstaller as owner of root of all local drives
$drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -match "^[A-Z]:\\$" }
foreach ($drive in $drives) {
    $rootPath = $drive.Root
    Write-Host "Setting TrustedInstaller as owner of $rootPath"
    $acl = Get-Acl $rootPath
    $acl.SetOwner([System.Security.Principal.NTAccount] $trustedInstallerSID)
    Set-Acl -Path $rootPath -AclObject $acl
    Write-Host "TrustedInstaller is now owner of $rootPath"
}

# Set current user as sole owner of %USERPROFILE%
$userProfilePath = [System.Environment]::GetFolderPath("UserProfile")
Write-Host "Setting $currentUserName as sole owner of $userProfilePath"

# Remove all existing access rules
$acl = Get-Acl $userProfilePath
$acl.Access | ForEach-Object {
    $acl.RemoveAccessRule($_)
}

# Set the current user as the sole owner
$acl.SetOwner([System.Security.Principal.NTAccount] $currentUserName)
Set-Acl -Path $userProfilePath -AclObject $acl
Write-Host "$currentUserName is now sole owner of $userProfilePath"


# Take ownership and set permissions on specific files and directories
$files = @("logonui.exe", "winlogon.exe")
foreach ($file in $files) {
    takeown /f "$env:windir\System32\$file"
    icacls "$env:windir\System32\$file" /reset
    icacls "$env:windir\System32\$file" /inheritance:r
    icacls "$env:windir\System32\$file" /deny "NETWORK:F"
    icacls "$env:windir\System32\$file" /grant "SYSTEM:RX"
    icacls "$env:windir\System32\$file" /grant "Administrator:RX"
    icacls "$env:windir\System32\$file" /deny "Users:F"
}