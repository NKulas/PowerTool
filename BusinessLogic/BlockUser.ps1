#Name: BlockUser
#Description: Creates or removes a task that prevents a user from logging on to the given computer
#Created by: Noah Kulas
#Created date: Aug. 15 2020

param([string]$Target, [string]$User)

try {
    $Session = New-CimSession -ComputerName $Target

    $User = $User.
    $AllTasks = Get-ScheduledTask -CimSession $Session
    $TaskFound = $false

    foreach ($Task in $AllTasks) {
        if ($Task.TaskName -like "$User*") {
            Unregister-ScheduledTask -TaskName $Task.TaskName

            $TaskFound = $true
            break
        }
    }

    if (-not($TaskFound)) {
        $TaskName = $User + (New-Guid).Guid

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
    }

    Remove-CimSession -CimSession $Session
    return $true
}
catch {
    Remove-CimSession -CimSession $Session
    return $false
}