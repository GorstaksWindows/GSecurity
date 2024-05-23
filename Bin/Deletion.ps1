# Ensure the script runs with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "You need to run this script as an administrator."
    exit
}

# Define the paths
$paths = @(
    "C:\Program Files (x86)\WindowsPowerShell\Modules\Pester",
    "C:\Program Files\WindowsPowerShell\Modules\Pester",
    [System.Environment]::GetFolderPath("CommonProgramFiles"),
    [System.Environment]::GetFolderPath("CommonProgramW6432")
)

# Process each path
foreach ($path in $paths) {
    if (Test-Path $path) {
        Write-Host "Processing path: $path"

        # Get the current ACL
        $acl = Get-Acl $path

        # Clear existing permissions
        $acl.Access | ForEach-Object {
            $acl.RemoveAccessRule($_)
        }

        # Allow current user full control
        $username = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
        $permission = New-Object System.Security.AccessControl.FileSystemAccessRule($username, "FullControl", "Allow")
        $acl.SetAccessRule($permission)

        # Apply the new ACL
        Set-Acl -Path $path -AclObject $acl
        Write-Host "File permissions set for $path"

        # Remove the directory
        Remove-Item -Path $path -Recurse -Force
        Write-Host "$path directory removed"
    } else {
        Write-Host "$path does not exist"
    }
}
