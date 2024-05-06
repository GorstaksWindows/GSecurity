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
