# Function to start App-V virtualization for a process
function Start-AppV {
    param(
        [string]$ExecutablePath
    )

    # Start the process through App-V
    $appvProcess = Start-Process -FilePath $ExecutablePath -PassThru -Wait
    if ($appvProcess.ExitCode -eq 0) {
        Write-Output "Process virtualized successfully: $($ExecutablePath)"
    } else {
        Write-Error "Failed to virtualize process: $($ExecutablePath)"
    }
}

# Function to monitor for new processes started by the user and virtualize them
function Monitor-Processes {
    $processes = @{}
    $username = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

    # Monitor for new processes
    $filter = "SessionId = $($pid) AND ProcessName != 'powershell.exe'"
    $events = Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4688} -MaxEvents 1 -ErrorAction SilentlyContinue | 
        Where-Object {$_.Properties[8].Value -eq $username -and $_.Properties[5].Value -ne 'powershell.exe'}

    if ($events) {
        $processName = $events.Properties[5].Value
        $processPath = $events.Properties[8].Value
        if (-not $processes.ContainsKey($processPath)) {
            Start-AppV -ExecutablePath $processPath
            $processes[$processPath] = $true
        }
    }
}

# Function to add the script to startup
function Add-ToStartup {
    $scriptPath = $MyInvocation.MyCommand.Path
    $startupFolderPath = [System.IO.Path]::Combine($env:APPDATA, 'Microsoft\Windows\Start Menu\Programs\Startup')
    $shortcutPath = [System.IO.Path]::Combine($startupFolderPath, [System.IO.Path]::GetFileNameWithoutExtension($scriptPath) + ".lnk")

    # Create a shortcut to the script in the Startup folder
    $shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $scriptPath
    $shortcut.Save()
}

# Add the script to startup
Add-ToStartup

# Main loop to continuously monitor for new processes
while ($true) {
    Monitor-Processes
    Start-Sleep -Seconds 5
}
