#Name: Logoff
#Description: Logs off the user on the given remote computer
#Created by: Noah Kulas
#Created date: Jan. 22, 2019

param([string]$Target)

try {
    shutdown -l -f -t 0 -m $Target

    return $true
}
catch {
    return $false
}