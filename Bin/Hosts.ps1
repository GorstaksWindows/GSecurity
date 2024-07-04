[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
Invoke-WebRequest "https://scripttiger.github.io/alts/compressed/blacklist-fg.txt" -OutFile "C:\Windows\System32\drivers\etc\hosts"
ipconfig /flushdns
reg add "HKLM\SYSTEM\CurrentControlSet\services\Dnscache\Parameters" /v "MaxNegativeCacheTtl" /t "REG_DWORD" /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\services\Dnscache\Parameters" /v "MaxCacheTtl" /t "REG_DWORD" /d "1" /f