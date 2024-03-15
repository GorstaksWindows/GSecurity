$ActivePolicyPath = "SOFTWARE\Policies\Microsoft\Windows\IPSEC\Policy\Local"
$ActivePolicyName = "ipsecPolicy{6c93294e-713e-4127-83e9-1f9884d8dd76}"
$IPSecOperationModePath = "System\ControlSet001\Services\IPSec"
$PolicyAgentPath = "System\ControlSet001\Services\PolicyAgent"

function Monitor-RegistryChanges {
    $key = "HKLM\$ActivePolicyPath"
    $key2 = "HKLM\$IPSecOperationModePath"
    $key3 = "HKLM\$PolicyAgentPath"
    
    $prevActivePolicy = ""
    $prevOperationMode = 0
    $prevPolicyAgentStart = 0

    while ($true) {
        $currentActivePolicy = (Get-ItemProperty -Path $key -Name "ActivePolicy").ActivePolicy
        $currentOperationMode = (Get-ItemProperty -Path $key2 -Name "OperationMode").OperationMode
        $currentPolicyAgentStart = (Get-ItemProperty -Path $key3 -Name "Start").Start

        if ($currentActivePolicy -ne $prevActivePolicy) {
            Write-Host "IPSec ActivePolicy has changed. Resetting..."
            New-ItemProperty -Path $key -Name "ActivePolicy" -Value $ActivePolicyName -Force | Out-Null
            $prevActivePolicy = $currentActivePolicy
        }

        if ($currentOperationMode -ne $prevOperationMode) {
            Write-Host "IPSec OperationMode has changed. Resetting..."
            New-ItemProperty -Path $key2 -Name "OperationMode" -Value 1 -Force | Out-Null
            $prevOperationMode = $currentOperationMode
        }

        if ($currentPolicyAgentStart -ne $prevPolicyAgentStart) {
            Write-Host "PolicyAgent Start has changed. Resetting..."
            New-ItemProperty -Path $key3 -Name "Start" -Value 1 -Force | Out-Null
            $prevPolicyAgentStart = $currentPolicyAgentStart
        }

        Start-Sleep -Seconds 5  # Check every 5 seconds, adjust as needed
    }
}

# Start monitoring
Monitor-RegistryChanges

# Function to add the script to Windows startup folder
function AddToStartup {
    $scriptPath = $MyInvocation.MyCommand.Definition
    $startupFolderPath = [Environment]::GetFolderPath("Startup")
    $shortcutPath = Join-Path $startupFolderPath "SimpleAntivirus.lnk"

    if (-Not (Test-Path $shortcutPath)) {
        $WScriptShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WScriptShell.CreateShortcut($shortcutPath)
        $Shortcut.TargetPath = $scriptPath
        $Shortcut.Save()
        Write-Host "Script added to startup."
    }
}

# Check if the script is already added to startup
function IsInStartup {
    $scriptPath = $MyInvocation.MyCommand.Definition
    $startupFolderPath = [Environment]::GetFolderPath("Startup")
    $shortcutPath = Join-Path $startupFolderPath "SimpleAntivirus.lnk"

    return (Test-Path $shortcutPath)
}

# Check if the script is already added to startup
if (-Not (IsInStartup)) {
    AddToStartup
}


