# Function to remove shortcut overlay icons
function Remove-ShortcutOverlay {
    $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons"
    $name = "29"

    try {
        if (!(Test-Path $keyPath)) {
            New-Item -Path $keyPath -Force
        }
        Set-ItemProperty -Path $keyPath -Name $name -Value "%SystemRoot%\System32\shell32.dll,-50"
        Write-Output "Shortcut overlay icons have been removed. Please restart your computer to apply changes."
    } catch {
        Write-Output "An error occurred while removing shortcut overlay icons: $_"
    }
}

# Execute functions
Remove-ShortcutOverlay
Hide-SystemTrayIcons

# Function to restart Windows Explorer
function Restart-Explorer {
    Stop-Process -Name explorer -Force
    Start-Process explorer
}

