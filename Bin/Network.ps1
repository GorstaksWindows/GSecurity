# Get the list of installed programs
$installedPrograms = Get-WmiObject -Query "SELECT * FROM Win32_Product"

# Filter for Chromium browsers
$chromiumBrowsers = $installedPrograms | Where-Object { $_.Name -like "*Chromium*" }

foreach ($browser in $chromiumBrowsers) {
    Write-Output "Found Chromium browser: $($browser.Name)"

    # Path to the preferences file may vary
    $prefsPath = Join-Path $browser.InstallLocation 'User Data\Default\Preferences'

    if (Test-Path $prefsPath) {
        # Load existing preferences
        $prefs = Get-Content $prefsPath | ConvertFrom-Json

        # Modify preferences to block WebRTC and Chrome Remote Desktop
        $prefs.webrtc.ip_handling_policy = "disable_non_proxied_udp"
        $prefs.RemoteAccessHost.client = $false

        # Save modified preferences
        $prefs | ConvertTo-Json | Set-Content $prefsPath
    }
}

# Function to check if a program is installed
function Check-ProgramInstalled {
    param (
        [string]$programName
    )
    
    $programKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
    $programs = Get-ChildItem $programKey | Get-ItemProperty
    
    foreach ($program in $programs) {
        if ($program.DisplayName -eq $programName) {
            return $true
        }
    }
    
    return $false
}

# List of common browser executables
$browsers = @(
    "chrome.exe",
    "firefox.exe",
    "iexplore.exe",
    "brave.exe",
    "edge.exe",
    "msedge.exe",
    # Add more browsers as needed
)

# Check if each browser is installed and block its internet access
foreach ($browser in $browsers) {
    if (Check-ProgramInstalled $browser) {
        Write-Host "Blocking internet access for $browser"
        New-NetFirewallRule -DisplayName "Block $browser internet access" -Direction Outbound -Program "C:\Program Files\Internet Browsers\$browser" -Action Block
    }
}

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