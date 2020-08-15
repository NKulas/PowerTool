#Name: BlockUser
#Description: Creates a task to prevent a user from logging on to the given computer
#Created by: Noah Kulas
#Created date: Aug. 15 2020

#Important note: This can not yet be undone using PowerTool

param([string]$Target, [string]$User)

try {
    $Session = New-CimSession -ComputerName $Target
    $TaskName = "BlockUser" + (New-Guid).Guid

    #Action
    $A = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "shutdown -l -f -t 0"

    #Security principal
    $P = New-ScheduledTaskPrincipal -GroupId "Users" -RunLevel Highest

    #Trigger
    $T = New-ScheduledTaskTrigger -AtLogOn -User $User

    #Settings
    $S = New-ScheduledTaskSettingsSet -DisallowHardTerminate -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Compatibility V1

    #Create task
    $D = New-ScheduledTask -Action $A -Principal $P -Trigger $T -Settings $S
    Register-ScheduledTask -TaskName $TaskName -InputObject $D -CimSession $Session

    Remove-CimSession -CimSession $Session
    return $true
}
catch {
    Remove-CimSession -CimSession $Session
    return $false
}