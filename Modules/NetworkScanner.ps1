#Name: NetworkScanner
#Description: Scans and gathers data about all computers on a subnet
#Created by: Noah Kulas
#Created date: Jan. 22, 2020

Set-Variable -Name "NUMBERS" -Value "0","1","2","3","4","5","6","7","8","9" -Option Constant

#Functions
#Allows path to be different in testing and launch from interface
function PathAdjust {
    param([string] $Path)

    if (Test-Path -Path $Path) {
        return $Path
    }
    elseif (Test-Path $Path.Replace(".\","Modules\")) {
        return $Path.Replace(".\","Modules\")
    }
    elseif (Test-Path $Path.Replace("..\","")) {
        return $Path.Replace("..\","")
    }
    else {
        return $Path
    }
}

function IsIpAddress {
    param ([string]$StringInQuestion)
    return $StringInQuestion -match "^[0-255]\.[0-255]\.[0-255]\.[0-255]$"
}

function GetNextAddress {
    param([string]$LastAddress)

    $AddressParts = $LastAddress.Split(".")
    for ($i = 3; $i -ge 0; $i--) {
        [int]$AddressParts[$i] += 1

        if ([int]$AddressParts[$i] -le 255) {
            #End the loop if the current octet does not pass the modulus
            break
        }
        else {
            $AddressParts[$i] = 0
        }
    }

    #Turn the list of octets back into a string
    $NextAddress = ""
    for ($j = 0; $j -le 3; $j++) {
        $NextAddress += $AddressParts[$j]
        
        if (-not($j -eq 3)) {
            $NextAddress += "."
        }
    }
    return $NextAddress
}

function FindProxy {
    param([string]$StartingPoint, [string]$Exclude)
    $ProxyFoundFlag = $false
    $CurrentAddress = $StartingPoint

    while (-not($ProxyFoundFlag)) {
        $CurrentAddress = GetNextAddress -LastAddress $CurrentAddress

        if (-not($CurrentAddress -eq $Exclude)) {
            #Check that it is on
            if (Test-Connection -ComputerName $CurrentAddress -Count 2 -TimeToLive 8 -Quiet) {
                #Check that it allows Windows RPC
                if ((Test-NetConnection $CurrentAddress -Port 135).TcpTestSucceeded) {
                    #Check that the ip has an associated DNS name
                    if (-not(IsIpAddress -StringInQuestion ([System.Net.Dns]::Resolve($CurrentAddress).HostName))) {
                        $ProxyFoundFlag = $true

                        #The spearfish module has problems using an ip address as the proxy
                        return ([System.Net.Dns]::Resolve($CurrentAddress).HostName)
                    }
                }
            }
        }

        if ((-not($ProxyFoundFlag)) -and $CurrentAddress -eq $EndAddress) {
            throw
        }
    }
}

#Main body
Write-Host "Enter subnet abbreviation: " -NoNewline
$SubnetAbbreviation = Read-Host

$StartAddress = & (PathAdjust -Path ".\NetworkDataInterpreter.ps1") -Mode 1 -InputData $SubnetAbbreviation -OutputFormat 6
$EndAddress = & (PathAdjust -Path ".\NetworkDataInterpreter.ps1") -Mode 1 -InputData $SubnetAbbreviation -OutputFormat 7

if (Test-Path -Path (PathAdjust -Path "..\Dataset\$SubnetAbbreviation.txt")) {
    Remove-Item -Path (PathAdjust -Path "..\Dataset\$SubnetAbbreviation.txt")
}

New-Item -Path (PathAdjust -Path "..\Dataset") -Name "$SubnetAbbreviation.txt" -ItemType File

$ThisComputer = [System.Net.Dns]::Resolve($ENV:COMPUTERNAME).AddressList
$Primary = FindProxy -StartingPoint $StartAddress
$PrimaryIp = [System.Net.Dns]::Resolve($Primary).AddressList[0].IpAddressToString
$Secondary = FindProxy -StartingPoint (GetNextAddress -LastAddress $PrimaryIp) -Exclude $Primary

$CurrentAddress = $StartAddress
while (-not($CurrentAddress -eq $EndAddress)) {
    #Skip this computer's address
    if ($ThisComputer -contains $CurrentAddres) {
        $CurrentAddress = GetNextAddress -Address $CurrentAddress
    }

    $HasName, $PingFlag, $MacFlag = $false, $false, $false
    $Result = ""

    $Name = [System.Net.Dns]::Resolve($CurrentAddress).HostName
    $HasName = -not(IsIpAddress -StringInQuestion $Name)

    $PingFlag = Test-Connection -ComputerName $CurrentAddress -Count 2 -TimeToLive 8 -Quiet
        
    if ($PingFlag) {
        if (-not($CurrentAddress -eq $Primary)) {
            $Proxy = $Primary
        }
        else {
            $Proxy = $Secondary
        }

        .\Spearfish.ps1 -Target $Proxy -Action "cmd.exe" -Arguments "/C ping $CurrentAddress"
        .\Spearfish.ps1 -Target $Proxy -Action "cmd.exe" -Arguments "/C arp -a > C:\arp.txt"

        $ArpFile = Get-Content -Path ("\\" + $Proxy + "\c$\arp.txt")
        Remove-Item -Path ("\\" + $Proxy + "\c$\arp.txt")

        foreach ($Line in $ArpFile) {
            $Line = $Line.TrimStart()
            if ($NUMBERS -contains $Line[0]) {
                $NormalizedLine = ""

                $NoMoreSpace = $false
                for ($i = 0; $i -lt $Line.Length; $i++) {
                    $Character = $Line[$i]

                    if ($Character -eq " ") {
                        if (-not($NoMoreSpace)) {
                            $NormalizedLine += $Character
                            $NoMoreSpace = $true
                        }
                    }
                    else {
                        $NormalizedLine += $Character
                        $NoMoreSpace = $false
                    }
                } #End for ($i = 0; $i -lt $Line.Length; $i++)
                    
                $Ip, $Mac, $Type = $NormalizedLine.Split(" ")

                if ($Ip -eq $CurrentAddress) {
                    $MacFlag = $true
                    break
                }
            } #End if ($NUMBERS -contains Line[0])
        } #End foreach ($Line in $ArpFile)

        if ($HasName) {
            $Result = "$Name : "
        }
        else {
            $Result = "($Name) : "
        }

        if ($MacFlag) {
            $Result += $Mac.ToUpper()
        }
        else {
            $Result += "~"
        }

        Add-Content -Value $Result -Path (PathAdjust -Path "..\Dataset\$SubnetAbbreviation.txt")
    } #End if ($PingFlag)

    $CurrentAddress = GetNextAddress -LastAddress $CurrentAddress
}