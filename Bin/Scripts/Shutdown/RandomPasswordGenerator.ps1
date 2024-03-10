# Logon script
if ($env:USERNAME -ne "SYSTEM") {
    # Generate a random password
    $randomPassword = New-Guid
    $securePassword = ConvertTo-SecureString -String $randomPassword -AsPlainText -Force

    # Set the password for the current user
    Set-LocalUser -Name $env:USERNAME -Password $securePassword
}

# Logoff script
if ($env:USERNAME -ne "SYSTEM") {
    # Reset password to blank
    $nullPassword = ConvertTo-SecureString "" -AsPlainText -Force
    Set-LocalUser -Name $env:USERNAME -Password $nullPassword
}
