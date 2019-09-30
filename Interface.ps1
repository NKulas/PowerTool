#Name: Interface
#Description: The main user interface for the Power Tool utility
#Created by: Noah Kulas
#Created date: Apr. 2, 2019
#Last updated: Sep. 28, 2019

#Declare variables
    $DnsFlag = $false
    $PingFlag = $false

function Logo {
Write-Output "     ------------ "
             "    |            \ "
             "    |              --- "
             "    |            / "
             "    |   --------- "
             "    |  | "
             "    |  | "
             "    ---- "

Write-Output "POWER TOOL`n"
}

function Main {
    param ([bool]$Refresh = $false)

    if (-not($Refresh)) {
        Write-Output "`n>>Enter the target computer:"
        Write-Host "> " -NoNewline
        $PlainName = Read-Host
        $Domain = Get-Content -Path "Configuration\DomainName.txt"

        if (-not($PlainName -like "*$Domain")) {
            $Target = $PlainName + ".$Domain"
        }
        else {
            $Target = $PlainName
        }
    }
    
    #Check for it in nslookup
    $Junk1, $Junk2, $Junk3, $LongName, $Junk4, $Junk5 = nslookup $Target
    if ($LongName -like "Name:*") {
        $DnsFlag = $true
    }
    else {
        $DnsFlag = $false
    }

    #Try pinging it
    if (Test-Connection -ComputerName $Target -Count 2 -TimeToLive 8 -Quiet) {
        $PingFlag = $true
    }
    else {
        $PingFlag = $false
    }
    TopLevel
}

function TopLevel {
    $TopLevelFlag = $false
    while (-not($TopLevelFlag)) {
        Write-Output "`n=============================="
        Write-Output "Computer: $Target"
        Write-Output "------------------------------"
        if ($DnsFlag) {Write-Host "Found in dns, " -nonewline} else {Write-Host "Not found in dns, " -nonewline}
        if ($PingFlag) {Write-Host "currently on" -nonewline} else {Write-Host "currently off" -nonewline}
        Write-Output "`n=============================="
        Write-Output ">>Options: 1)Actions 2)Who are you 3)Refresh 4)Change computer"
        Write-Host "> " -NoNewline
        $Option = Read-Host

        Switch ($Option) {
            1 {<#$TopLevelFlag = $true;#> Actions}
            2 {<#$TopLevelFlag = $true;#> WhoAreYou}
            3 {$TopLevelFlag = $true; Main -Refresh $true}
            4 {$TopLevelFlag = $true; Main}
            default {Write-Output ">>Unrecognized command"}
        }
    }
}

function Actions {
    $ActionsFlag = $false
    while (-not($ActionsFlag)) {
        Write-Output "`n------------------------------"
        Write-Output "Actions for: $Target"
        Write-Output "------------------------------"
        Write-Output ">>Options: 1)Restart 2)Shutdown 3)Logoff 4)Rename 5)Back"
        Write-Host "> " -NoNewline
        $ActionOption = Read-Host

        switch ($ActionOption) {
            1 {powershell.exe -File "Modules\Restart.ps1" -Target $Target}
            2 {powershell.exe -File "Modules\Shutdown.ps1" -Target $Target}
            3 {powershell.exe -File "Modules\Logoff.ps1" -Target $Target}
            4 {powershell.exe -File "Modules\Rename.ps1" -Target $Target}
            5 {$ActionsFlag = $true}
            default {Write-Output ">>Unrecognized command"}
        }
    }
}

function WhoAreYou {
    if ($PingFlag) {
        Write-Output "`n------------------------------"
        Write-Output "Info for: $Target"
        Write-Output "------------------------------"

        #Get the ip address from nslookup
        $Junk1, $Junk2, $Junk3, $Junk4, $LongAddress, $Junk5 = nslookup $Target
        $Junk6, $MidAddress = $LongAddress -split "  "
        $Address = $MidAddress.Trim(" ")
        
        #Get the mac address from getmac
        $Junk7, $Junk8, $Junk9, $LongMac = getmac /s $Target 
        $Mac, $Junk10 = $LongMac -split "   "
        
        Write-Output ("Serial number: " + (Get-WmiObject -ComputerName $Target -Class "Win32_Bios").SerialNumber)
        Write-Output ("Manufacturer: " + (Get-WmiObject -ComputerName $Target -Class "Win32_ComputerSystem").Manufacturer)
        Write-Output ("Model: " + (Get-WmiObject -ComputerName $Target -Class "Win32_ComputerSystem").Model)
        Write-Output ("Current user: " + (Get-WmiObject -ComputerName $Target -Class "Win32_ComputerSystem").UserName)
        Write-Output ("Last boot: " + (Get-WmiObject -ComputerName $Target -Class "Win32_OperatingSystem").LastBootUpTime)
        Write-Output ("Install date: " + (Get-WmiObject -ComputerName $Target -Class "Win32_OperatingSystem").InstallDate)
        Write-Output ("Logical processors: " + (Get-WmiObject -ComputerName $Target -Class "Win32_ComputerSystem").NumberOfLogicalProcessors)
        Write-Output ("Total memory: " + ((Get-WmiObject -ComputerName $Target -Class "Win32_ComputerSystem").TotalPhysicalMemory)/1000000000)
        Write-Output ("Ip address: " + $Address)
        Write-Output ("Mac address: " + $Mac)
    }
    else {
        Write-Output "No data could be retrieved because the computer is not on"
    }
}
Logo
Main