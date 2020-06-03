#Name: Logoff
#Description: Logs off the user on the given remote computer
#Created by: Noah Kulas
#Created date: Jan. 22, 2019

param([string]$Target)

try {
    logoff console /Server $Target
    return $true
}
catch {
    return $false
}