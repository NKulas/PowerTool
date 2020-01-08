#Name: Restart
#Description: Shuts down the given remote computer
#Created by: Noah Kulas
#Created date: Jan. 22, 2019

param([string]$Target)

try {
    shutdown -s -f -t 0 -m $Target
    return "Success"
}
catch {
    return "Failure"
}