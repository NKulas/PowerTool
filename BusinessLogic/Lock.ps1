#Name: Lock
#Description: Locks the given remote computer
#Created by: Noah Kulas
#Created date: Apr. 9, 2019

param([string]$Target)

try {
    .\Spearfish.ps1 -Target $Target -Action "cmd.exe" -Arguments "/C rundll32.exe user32.dll,LockWorkStation"
    return $true
}
catch {
    return $false
}