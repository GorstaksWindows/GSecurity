# Get all fixed drives
$drives = Get-Volume

foreach ($drive in $drives) {
    $drivePath = $drive.Path
    try {
        # Get current ACL
        $acl = Get-Acl -Path $drivePath

        # Create NETWORK SID and DENY rule
        $networkSid = New-Object System.Security.Principal.SecurityIdentifier([System.Security.Principal.WellKnownSidType]::NetworkSid, $null)
        $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($networkSid, "FullControl", "ContainerInherit, ObjectInherit", "None", "Deny")

        # Add DENY rule to the current ACL
        $acl.AddAccessRule($accessRule)

        # Apply the new ACL
        Set-Acl -Path $drivePath -AclObject $acl

        Write-Host "Successfully denied NETWORK access to $drivePath" -ForegroundColor Green
    } catch {
        Write-Host "Failed to deny NETWORK access on $drivePath. Error: $_" -ForegroundColor Red
    }
}
