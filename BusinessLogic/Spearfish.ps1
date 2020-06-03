#Name: Spearfish
#Description: Allows for running an executable on the given remote computer
#Created by: Noah Kulas
#Created date: Nov. 1, 2019

param([string]$Target, [string]$Action, [string]$Arguments = "", [switch]$AsSystem)

try {
    $Session = New-CimSession -ComputerName $Target
    $TaskName = (New-Guid).Guid

    #Action
    if ($Arguments -ne "") {
        $A = New-ScheduledTaskAction -Execute $Action -Argument $Arguments
    }
    else {
        $A = New-ScheduledTaskAction -Execute $Action
    }

    #Security principal
    if ($AsSystem) {
        $P = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -RunLevel Highest
    }
    else {
        $P = New-ScheduledTaskPrincipal -GroupId "Users" -RunLevel Highest
    }

    #Settings
    $S = New-ScheduledTaskSettingsSet -DisallowHardTerminate -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Compatibility V1

    #Create task
    $D = New-ScheduledTask -Action $A -Principal $P -Settings $S
    Register-ScheduledTask -TaskName $TaskName -InputObject $D -CimSession $Session

    $TaskLoop = $true
    $Counter = 0
    while ($TaskLoop) {
        $Task = Get-ScheduledTaskInfo -TaskName $TaskName -CimSession $Session -ErrorAction SilentlyContinue

        if ($Task -ne $null) {
            if ($Task.LastTaskResult -ne 0) {
                Start-ScheduledTask -TaskName $TaskName -CimSession $Session
            }
            else {
                Unregister-ScheduledTask -TaskName $TaskName -CimSession $Session -Confirm:$false
                $TaskLoop = $false
                break
            }
        }

        if ($Counter -ge 9) {
            $TaskLoop = $false
        }
        else {
            $Counter++
            Start-Sleep -Seconds 1
        }
    }

    Remove-CimSession -CimSession $Session
    return $true
}
catch {
    Remove-CimSession -CimSession $Session
    return $false
}