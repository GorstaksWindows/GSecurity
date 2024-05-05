# Set the integrity level to Low for common temporary folders

$tempFolders = @(
    [System.IO.Path]::GetTempPath(),
    [System.IO.Path]::Combine($env:USERPROFILE, 'AppData\Local\Temp')
)

foreach ($folder in $tempFolders) {
    icacls $folder /setintegritylevel Low
}

# Set the integrity level to Low for popular browsers' cache folders

$browsers = @(
    @{ Name = "Google Chrome"; Path = [System.IO.Path]::Combine($env:USERPROFILE, 'AppData\Local\Google\Chrome\User Data\Default\Cache') },
    @{ Name = "Mozilla Firefox"; Path = [System.IO.Path]::Combine($env:USERPROFILE, 'AppData\Local\Mozilla\Firefox\Profiles') },
    @{ Name = "Microsoft Edge"; Path = [System.IO.Path]::Combine($env:USERPROFILE, 'AppData\Local\Microsoft\Edge\User Data\Default\Cache') },
    @{ Name = "Opera"; Path = [System.IO.Path]::Combine($env:USERPROFILE, 'AppData\Roaming\Opera Software\Opera Stable\Cache') },
    # Add additional browsers as needed
)

foreach ($browser in $browsers) {
    if (Test-Path $browser.Path) {
        icacls $browser.Path /setintegritylevel Low
    }
}
