# Function to disable extensions in Chromium-based browsers
function Disable-ChromiumExtensions {
    param (
        [string]$browserName,
        [string]$profilePath
    )

    $preferencesPath = "$profilePath\Preferences"
    $extensionsPath = "$profilePath\Extensions"

    if (Test-Path $preferencesPath) {
        # Backup the Preferences file
        Copy-Item -Path $preferencesPath -Destination "$preferencesPath.bak"

        # Load the Preferences file
        $preferences = Get-Content -Path $preferencesPath -Raw | ConvertFrom-Json

        # Disable all extensions
        foreach ($extension in $preferences.extensions.settings.PSObject.Properties) {
            $preferences.extensions.settings[$extension.Name].state = 0
        }

        # Save the updated Preferences file
        $preferences | ConvertTo-Json -Compress | Set-Content -Path $preferencesPath -Force

        Write-Output "All extensions in $browserName have been disabled."

        # Optionally remove all extension directories
        # Remove-Item -Path "$extensionsPath\*" -Recurse -Force
    } else {
        Write-Output "$browserName is not installed or the profile path does not exist."
    }
}

# Function to disable Firefox extensions
function Disable-FirefoxExtensions {
    $firefoxProfilePath = "$env:APPDATA\Mozilla\Firefox\Profiles"
    $firefoxExtensionsFiles = Get-ChildItem -Path $firefoxProfilePath -Filter "extensions.json" -Recurse

    if ($firefoxExtensionsFiles) {
        foreach ($firefoxExtensionsFile in $firefoxExtensionsFiles) {
            # Backup the extensions.json file
            Copy-Item -Path $firefoxExtensionsFile.FullName -Destination "$($firefoxExtensionsFile.FullName).bak"

            # Load the extensions.json file
            $extensions = Get-Content -Path $firefoxExtensionsFile.FullName -Raw | ConvertFrom-Json

            # Disable all extensions
            foreach ($extension in $extensions.addons) {
                $extension.active = $false
            }

            # Save the updated extensions.json file
            $extensions | ConvertTo-Json -Compress | Set-Content -Path $firefoxExtensionsFile.FullName -Force

            Write-Output "All Firefox extensions have been disabled in profile: $($firefoxExtensionsFile.DirectoryName)."
        }
    } else {
        Write-Output "Mozilla Firefox is not installed or no profiles with extensions.json found."
    }
}

# Detect and disable extensions in installed browsers
if (Get-Command -Name chrome.exe -ErrorAction SilentlyContinue) {
    Disable-ChromiumExtensions -browserName "Google Chrome" -profilePath "$env:LOCALAPPDATA\Google\Chrome\User Data\Default"
} else {
    Write-Output "Google Chrome is not installed."
}

if (Get-Command -Name msedge.exe -ErrorAction SilentlyContinue) {
    Disable-ChromiumExtensions -browserName "Microsoft Edge" -profilePath "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default"
} else {
    Write-Output "Microsoft Edge is not installed."
}

if (Get-Command -Name brave.exe -ErrorAction SilentlyContinue) {
    Disable-ChromiumExtensions -browserName "Brave" -profilePath "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default"
} else {
    Write-Output "Brave Browser is not installed."
}

if (Get-Command -Name vivaldi.exe -ErrorAction SilentlyContinue) {
    Disable-ChromiumExtensions -browserName "Vivaldi" -profilePath "$env:LOCALAPPDATA\Vivaldi\User Data\Default"
} else {
    Write-Output "Vivaldi Browser is not installed."
}

if (Get-Command -Name firefox.exe -ErrorAction SilentlyContinue) {
    Disable-FirefoxExtensions
} else {
    Write-Output "Mozilla Firefox is not installed."
}

# Add additional browser detection and handling as needed
