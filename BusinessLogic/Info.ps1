#Name: Info
#Description: Gets information about the given remote computer
#Created by: Noah Kulas
#Created date: Apr. 2, 2019

param([string]$Target)

try {
    $Categories = Get-ChildItem -Path "..\Configuration\InformationProperties"
    $CommonNames = @()

    $MainLoop = $true
    while ($MainLoop) {

        Write-Host "1)General " -NoNewline
        $i = 2
        foreach ($File in $Categories) {
            $CommonName = $File.Name.Replace("Win32_","").Replace(".txt","")
            $CommonNames += $CommonName

            Write-Host "$i)$CommonName " -NoNewLine
            if (($i % 10) -eq 0) {
                Write-Host "`n" -NoNewline
            }
            $i++
        }
        Write-Output "$i)Exit`n"
        Write-Host ">>" -NoNewline

        $Choice = Read-Host

        if ($Choice -match "^[0-9]+$") {
            $Choice = [Int]$Choice

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
            } #End if ($Choice -eq 1)
            elseif ($Choice -lt $i) {
                $Properties = Get-Content -Path ("..\Configuration\InformationProperties\" + $Categories[$Choice - 2].Name)

                $Session = New-CimSession -ComputerName $Target
                $CimInstance = (Get-CimInstance -Class ("Win32_" + $CommonNames[$Choice - 2]) -CimSession $Session)

                $j = 1;
                foreach ($Device in $CimInstance) {
                    Write-Output "`nDevice $j"
                    Write-Output "----------`n"

                    foreach ($Property in $Properties) {
                        $Property = $Property.Replace(",","")
                        Write-Output ("$Property" + ": " + $Device.$Property)
                    }
                    $j++
                } #End foreach ($Device in $CimInstance)

                if ($j -eq 1) {
                    Write-Output "=>No devices could be found for this category"
                }

                Remove-CimSession -CimSession $Session
                Write-Host "`n" -NoNewLine
            } #End elseif ($Choice -lt $i)
            elseif ($Choice -eq $i) {
                $MainLoop = $false
            }
            else {
                Write-Output "`n=>Choice is out of range`n"
            }
        } #End if ($Choice -match "^[0-9]+$")
        else {
            Write-Output "`n=>Unrecognized command`n"
        }
    } #End while ($MainLoop)

    return $true
}
catch {
    Remove-CimSession -CimSession $Session
    return $false
}