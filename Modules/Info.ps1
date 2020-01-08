#Name: Info
#Description: Gets information about the given remote computer
#Created by: Noah Kulas
#Created date: Apr. 2, 2019

param([string]$Target)

#This function helps with the fact that opening this script in a new instance of Powershell with start process does not change the working directory
#It allows the script to be developed and tested in the correct directory, and also launched from the interface without the correct directory
function PathAdjust {
    param([string] $Path)

    if (Test-Path -Path $Path) {
        return $path
    }
    elseif (Test-Path $Path.Replace("..\","")) {
        return $Path.Replace("..\","")
    }
    else {
        throw "No valid paths can be found"
    }
}

try {
    $Categories = Get-Content -Path (PathAdjust -Path "..\Configuration\InformationClasses.txt")

    $TerminateMainLoop = $false
    while (-not($TerminateMainLoop)) {

        Write-Host "1)General " -NoNewline
        $i = 2
        foreach ($line in $Categories) {
            $CimName, $DisplayName = $line.Split(",")
            Write-Host "$i)$DisplayName " -NoNewLine
            if (($i % 10) -eq 0) {
                Write-Host "`n" -NoNewline
            }
            $i++
        }
        Write-Output "$i)Exit`n"
        Write-Host ">>" -NoNewline

        $Choice = Read-Host

        if ($Choice -eq 1) {
            #Get the ip address from nslookup
            $Junk1, $Junk2, $Junk3, $Junk4, $LongAddress, $Junk5 = nslookup $Target
            $Junk6, $MidAddress = $LongAddress -split "  "
            $Address = $MidAddress.Trim(" ")
            
            #Get the mac address from getmac
            $Junk7, $Junk8, $Junk9, $LongMac = getmac /s $Target
            $Mac, $Junk10 = $LongMac -split "   "

            $Session = New-CimSession -ComputerName $Target
            
            Write-Output ("Serial number: " + (Get-CimInstance -Class "Win32_Bios" -CimSession $Session).SerialNumber)
            Write-Output ("Manufacturer: " + (Get-CimInstance -Class "Win32_ComputerSystem" -CimSession $Session).Manufacturer)
            Write-Output ("Model: " + (Get-CimInstance -Class "Win32_ComputerSystem" -CimSession $Session).Model)
            Write-Output ("Current user: " + (Get-CimInstance -Class "Win32_ComputerSystem" -CimSession $Session).UserName)
            Write-Output ("Last boot: " + (Get-CimInstance -Class "Win32_OperatingSystem" -CimSession $Session).LastBootUpTime)
            Write-Output ("Install date: " + (Get-CimInstance -Class "Win32_OperatingSystem" -CimSession $Session).InstallDate)
            Write-Output ("Logical processors: " + (Get-CimInstance -Class "Win32_ComputerSystem" -CimSession $Session).NumberOfLogicalProcessors)
            Write-Output ("Total memory: " + ((Get-CimInstance -Class "Win32_ComputerSystem" -CimSession $Session).TotalPhysicalMemory)/1000000000)
            Write-Output ("Ip address: " + $Address)
            Write-Output ("Mac address: " + $Mac)
            Write-Host "`n" -NoNewline
        }
        else {
            $j = 2
            $FoundMatch = $false
            foreach ($line in $Categories) {
                if ($j -eq $Choice) {
                    $CimName, $DisplayName = $line.Split(",")
                    $Properties = Get-Content -Path (PathAdjust -Path "..\Configuration\InformationProperties\$CimName.txt")

                    $Session = New-CimSession -ComputerName $Target
                    $CimInstance = (Get-CimInstance -Class $CimName -CimSession $Session)

                    $k = 1;
                    foreach ($device in $CimInstance) {
                        Write-Output "`nDevice $k"
                        Write-Output "----------`n"

                        foreach ($property in $Properties) {
                            $property = $property.Replace(",","")
                            Write-Output ("$property" + ": " + $device.$property)
                        }
                        $k++
                    }

                    if ($k -eq 1) {
                        Write-Output "=>No devices could be found for this category"
                    }
                    $FoundMatch = $true
                    Remove-CimSession -CimSession $Session
                    Write-Host "`n" -NoNewLine
                    break
                }
                else {
                    $j++
                }
            }
            if (-not($FoundMatch)) {
                if ($Choice -eq $j) {
                    $TerminateMainLoop = $true
                }
                else {
                    Write-Output "`n=>Unrecognized command`n"
                }
            }
        }
    }
    return "Success"
}
catch {
    Remove-CimSession -CimSession $Session
    return "Failure"
}