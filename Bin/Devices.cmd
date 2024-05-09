:: Disable devices
Echo A | @powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-PnpDevice | where {$_.name -like '*Management*'} | Disable-PnpDevice"
Echo A | @powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-PnpDevice | where {$_.name -like '*Debug*'} | Disable-PnpDevice"
Echo A | @powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-PnpDevice | where {$_.name -like '*bth*'} | Disable-PnpDevice"
