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
    
    if ($StringInQuestion -match "\.") {
        $ItemizedString = $StringInQuestion.Split(".")

        if ($ItemizedString.Count -eq 4) {
            foreach ($PossibleOctet in $ItemizedString) {
                [Int]$Number = $null
                if ([Int]::TryParse($PossibleOctet, [ref]$Number)) {
                    if (-not(($Number -ge 0) -and ($Number -le 255))) {
                        return $false
                    }
                }
                else {
                    return $false
                }
            }
            return $true
        }
        else {
            return $false
        }
    }
    else {
        return $false
    }
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

$StartAddress = & (PathAdjust -Path ".\NetworkDataInterpreter.ps1") -InputFormat 2 -InputData $SubnetAbbreviation -OutputFormat 6
$EndAddress = & (PathAdjust -Path ".\NetworkDataInterpreter.ps1") -InputFormat 2 -InputData $SubnetAbbreviation -OutputFormat 7

$ThisComputer = [System.Net.Dns]::Resolve($ENV:COMPUTERNAME).AddressList
$Primary = FindProxy -StartingPoint $StartAddress
$PrimaryIp = [System.Net.Dns]::Resolve($Primary).AddressList[0].IpAddressToString
$Secondary = FindProxy -StartingPoint (GetNextAddress -LastAddress $PrimaryIp) -Exclude $Primary

$CurrentAddress = $StartAddress
while (-not($CurrentAddress -eq $EndAddress)) {
    #Skip this computer's address
    if ($ThisComputer -contains $CurrentAddres) {
        $CurrentAddress = GetNextAddress -LastAddress $CurrentAddress
    }

    $NameFlag, $PingFlag, $MacFlag = $false, $false, $false
    $Mac = ""

    $Identity = [System.Net.Dns]::Resolve($CurrentAddress).HostName
    if (-not(IsIpAddress -StringInQuestion $Identity)) {
        $NameFlag = $true
    }

    if (Test-Connection -ComputerName $CurrentAddress -TimeToLive 8 -Quiet) {
        $PingFlag = $true
    }

    if ($PingFlag) {
        if ($CurrentAddress -eq $PrimaryIp) {
            $Proxy = $Secondary
        }
        else {
            $Proxy = $Primary
        }

        #Get the mac
        .\Spearfish.ps1 -Target $Proxy -Action "cmd.exe" -Arguments "/C ping $CurrentAddress" -AsSystem
        .\Spearfish.ps1 -Target $Proxy -Action "cmd.exe" -Arguments "/C arp -a > C:\arp.txt" -AsSystem

        $ArpFile = Get-Content -Path ("\\" + $Proxy + "\c$\arp.txt")
        Remove-Item -Path ("\\" + $Proxy + "\c$\arp.txt")

        foreach ($Line in $ArpFile) {
            $Line = $Line.TrimStart()

            if ($NUMBERS -contains $Line[0]) {
                $NormalizedLine = ""

                $NoMoreSpace = $false
                for ($i = 0; $i -lt $Line.length; $i++) {
                    $Character = $Line[$i]

                    if ($Character -eq " ") {
                        if (-not($NoMoreSpace)) {
                            $NormalizedLine += $Character
                            $NoMoreSpace = $true
                        }
                    } #End if ($Character -eq " ")
                    else {
                        $NormalizedLine += $Character
                        $NoMoreSpace = $false
                    }
                } #End for ($i = 0; $i -lt $Line.length; $i++)
                    
                $Ip, $Mac, $Type = $NormalizedLine.Split(" ")

                if ($Ip -eq $CurrentAddress) {
                    $MacFlag = $true
                    break
                }
            } #End if ($NUMBERS -contains $Line[0])
        } #End foreach ($Line in $ArpFile)
    } #End if ($PingFlag)

    if ($NameFlag -or $PingFlag) {
        $FileEntry = "$Identity : "

        if ($MacFlag) {
            $FileEntry += $Mac
        }
        else {
            $FileEntry += "~"
        }

        if (-not(Test-Path -Path (PathAdjust -Path "..\Dataset\$SubnetAbbreviation.txt"))) {
            New-Item -Path (PathAdjust -Path "..\Dataset\$SubnetAbbreviation.txt") -ItemType "File"
        }

        $Files = Get-ChildItem -Path (PathAdjust -Path "..\Dataset")
        $CurrentSubnetFile = $false

        foreach ($File in $Files) {
            if ($File.Name.Replace(".txt","") -eq $SubnetAbbreviation) {
                $CurrentSubnetFile = $true
            }
            else {
                $CurrentSubnetFile = $false
            }

            $NameFound = $false
            $Content = Get-Content -Path (PathAdjust -Path ("..\Dataset\" + $File.Name))

            foreach ($Line in $Content) {
                $RecordName, $RecordMac = $Line.Split(":")
                $RecordName = $RecordName.Trim()
                $RecordMac = $RecordMac.Trim()

                if ($RecordName -eq $Identity) {
                    if ($CurrentSubnetFile) {
                        if ($MacFlag -and ($RecordMac -ne $Mac)) {
                            #Recorded mac does not match what was found in the scan, so replace the entry
                            Set-Content -Path (PathAdjust -Path ("..\Dataset\" + $File.Name)) -Value ($Content -replace $Line, $FileEntry)
                        }
                        $NameFound = $true
                    } #End if ($CurrentSubnetFile)
                    else {
                        #Computer is recorded in a different subnet file than the scan found, so remove the entry
                        Set-Content -Path (PathAdjust -Path ("..\Dataset\" + $File.Name)) -Value (Select-String -InputObject $Content -NotMatch $Line)
                    }
                } #End if ($RecordName -eq $Identity)
                elseif ($RecordMac -eq $Mac) {
                    #The mac was found associated with a different computer name, so remove the mac from the entry
                    Set-Content -Path (PathAdjust -Path ("..\Dataset\" + $File.Name)) -Value ($Content -replace $Line, "$RecordName : ~")
                } #End elseif ($RecordMac -eq $Mac)
            } #End foreach ($Line in $Content) {

            if ($CurrentSubnetFile -and (-not($NameFound))) {
                #The computer is not recorded in the subnet file, so add an entry
                Add-Content -Path (PathAdjust -Path "..\Dataset\$SubnetAbbreviation.txt") -Value $FileEntry
            }
        } #End foreach ($File in $Files)
    } #End if ($NameFlag -or $PingFlag)

    $CurrentAddress = GetNextAddress -LastAddress $CurrentAddress
}