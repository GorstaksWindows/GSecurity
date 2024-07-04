:: System failure watch off
wmic recoveros set WriteToSystemLog = False
wmic recoveros set SendAdminAlert = False
wmic recoveros set AutoReboot = False
wmic recoveros set DebugInfoType = 0