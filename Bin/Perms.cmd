:: Perms
for %%d in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    takeown /F %%d:\
    icacls %%d:\ /remove "Administrators"
    icacls %%d:\ /grant "Administrators":RX
    icacls %%d:\ /remove "Authenticated Users"
    icacls %%d:\ /remove "Users"
    icacls %%d:\ /remove "System"
    icacls %%d:\ /grant "*S-1-2-1":M
    icacls %%d:\ /deny "Network":F
)
    icacls C:\ /grant "System":M