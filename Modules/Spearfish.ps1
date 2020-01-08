#Name: Spearfish
#Description: Allows for running an executable on the given remote computer
#Created by: Noah Kulas
#Created date: Nov. 1, 2019

param([string]$Target, [string]$Action, [string]$Arguments = "", [bool]$AsSystem = $false)

try {
    $Session = New-CimSession -ComputerName $Target
    $Minute = (Get-Date).Minute.ToString()
    $Second = (Get-Date).Second.ToString()
    $Millisecond = (Get-Date).Millisecond.ToString()
    $Name = "Spearfish" + $Minute + $Second + $Millisecond

    if ($Arguments -ne "") {
        $A = New-ScheduledTaskAction -Execute $Action -Argument $Arguments
    }
    else {
        $A = New-ScheduledTaskAction -Execute $Action
    }

    $T = New-ScheduledTaskTrigger -At (Get-Date).AddSeconds(2) -Once

    if ($AsSystem) {
        $P = New-ScheduledTaskPrincipal -Id "NT AUTHORITY\SYSTEM" -RunLevel Highest
    }
    else {
        $P = New-ScheduledTaskPrincipal -GroupId "Users" -RunLevel Highest
    }

    $S = New-ScheduledTaskSettingsSet -DisallowHardTerminate -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Compatibility V1
    $D = New-ScheduledTask -Action $A -Principal $P -Trigger $T -Settings $S
    Register-ScheduledTask -TaskName $Name -InputObject $D -CimSession $Session

    Start-Sleep -Seconds 3

    Unregister-ScheduledTask -TaskName $Name -CimSession $Session -Confirm:$false
    Remove-CimSession -CimSession $Session
    return "Success"
}
catch {
    Remove-CimSession -CimSession $Session
    return "Failure"
}