# Set your VirusTotal public API key here
$VirusTotalApiKey = "0393b0784dba04ea0c6f5c1e45cac1c35ba83b1fc09e1d792d270dcc159d53d8"

# Function to check a file on VirusTotal
function Get-VirusTotalScan {
    param (
        [string]$FilePath
    )

    $VirusTotalUrl = "https://www.virustotal.com/api/v3/files/$((Get-FileHash -Algorithm SHA256 $FilePath).Hash)/analyse"

    $Headers = @{
        "x-apikey" = $VirusTotalApiKey
    }

    $response = Invoke-RestMethod -Uri $VirusTotalUrl -Headers $Headers -Method Post

    # Wait for the scan to complete (adjust this as needed)
    Start-Sleep -Seconds 60

    $reportUrl = "https://www.virustotal.com/gui/file/$($response.data.id)/detection"
    Write-Host "Scan results available at: $reportUrl"

    return $response
}

# Function to block execution
function Block-Execution {
    param (
        [string]$Reason
    )

    Write-Host "Blocked Execution: $Reason"
    # Add your blocking logic here, such as killing the process or quarantining the file.
}

# Function to monitor file creations
function Monitor-FileCreations {
    $fileWatcher = New-Object System.IO.FileSystemWatcher
    $fileWatcher.Path = "C:\Users"  # Specify the path to monitor here
    $fileWatcher.IncludeSubdirectories = $true
    $fileWatcher.EnableRaisingEvents = $true

    Register-ObjectEvent $fileWatcher "Created" -Action {
        $filePath = $Event.SourceEventArgs.FullPath
        Write-Host "New file created: $filePath"

        $scanResults = Get-VirusTotalScan -FilePath $filePath

        # Check if the file is detected as malware on VirusTotal
        if ($scanResults.data.attributes.last_analysis_stats.malicious -gt 0) {
            Block-Execution -Reason "File detected as malware on VirusTotal"
        }
    } | Out-Null
}

# Function to add the script to Windows startup folder
function AddToStartup {
    $scriptPath = $MyInvocation.MyCommand.Definition
    $startupFolderPath = [Environment]::GetFolderPath("Startup")
    $shortcutPath = Join-Path $startupFolderPath "SimpleAntivirus.lnk"

    if (-Not (Test-Path $shortcutPath)) {
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = $scriptPath
        $shortcut.Save()
        Write-Host "Script added to startup."
    }
}

# Check if the script is already added to startup
function IsInStartup {
    $scriptPath = $MyInvocation.MyCommand.Definition
    $startupFolderPath = [Environment]::GetFolderPath("Startup")
    $shortcutPath = Join-Path $startupFolderPath "SimpleAntivirus.lnk"

    return (Test-Path $shortcutPath) -and (Resolve-Path $shortcutPath).Path -eq (Resolve-Path $scriptPath).Path
}

# Check if the script is already added to startup
if (-Not (IsInStartup)) {
    AddToStartup
}

# Start monitoring file creations
Monitor-FileCreations
