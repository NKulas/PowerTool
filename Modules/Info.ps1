#Name: Info
#Description: Gets information about the given remote computer
#Created by: Noah Kulas
#Created date: Apr. 2, 2019
#Last updated: Oct. 30, 2019

param([string]$Target)

try {
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

    Write-Output "`nPress enter to exit"
    Read-Host
}
catch {
    return "Failure"
}