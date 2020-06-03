#Name: Restart
#Description: Restarts the given remote computer
#Created by: Noah Kulas
#Created date: Jan. 22, 2019

param([string]$Target)

try {
    shutdown -r -f -t 0 -m $Target

    return $true
}
catch {
    return $false
}