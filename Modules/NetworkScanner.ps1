#Name: NetworkScanner
#Description: Scans and gathers data about all computers on a subnet
#Created by: Noah Kulas
#Created date: Jan. 22, 2020

#Not yet in use
#param([string]$SubnetAbbreviation)

Set-Variable -Name "NUMBERS" -Value "0","1","2","3","4","5","6","7","8","9" -Option Constant

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
        #throw "No valid paths can be found"
        return $Path
    }
}

<#$StartAddress = .\NetworkDataInterpreter.ps1 -Mode 1 -InputData $SubnetAbbreviation -OutputFormat 5
$EndAddress = .\NetworkDataInterpreter.ps1 -Mode 1 -InputData $SubnetAbbreviation -OutputFormat 6#>
$StartAddress = ""
$EndAddress = ""

$AllAdapters = Get-WmiObject -Class win32_NetworkAdapterConfiguration

$LoopFlag = $true
while ($LoopFlag) {
    Write-Output "Choose a network adapter:"
    for ($i = 1; $i -le $AllAdapters.Length; $i++) {
        Write-Output ("$i) " + ($AllAdapters[$i - 1]).Description)
    }
    Write-Host "> " -NoNewline
    $SelectedAdapter = Read-Host

    if (([int]$SelectedAdapter -ge 1) -and ([int]$SelectedAdapter -le $AllAdapters.Length)) {
        $StartAddress = & (PathAdjust -Path ".\NetworkDataInterpreter.ps1") -Mode 0 -InputData (($AllAdapters[$SelectedAdapter - 1]).Description) -OutputFormat 5
        Write-Output (($AllAdapters[$SelectedAdapter - 1]).Description)
        $EndAddress = & (PathAdjust -Path ".\NetworkDataInterpreter.ps1") -Mode 0 -InputData (($AllAdapters[$SelectedAdapter - 1]).Description) -OutputFormat 6
        $LoopFlag = $false
    }
    else {
        Write-Output "`n>>Invalid choice`n"
    }
}

function GetNextAddress {
    $AddressParts = $CurrentAddress.Split(".")
    for ($i = 3; $i -ge 0; $i--) {
        [int]$AddressParts[$i] += 1

        if ([int]$AddressParts[$i] -le 255) {
            break
        }
        else {
            $AddressParts[$i] = 0
        }
    }

    $NewAddress = ""
    for ($j = 0; $j -le 3; $j++) {
        $NewAddress += $AddressParts[$j]
        
        if (-not($j -eq 3)) {
            $NewAddress += "."
        }
    }
    return $NewAddress
}

function IsIpAddress {
    param ([string]$StringInQuestion)
    return $StringInQuestion -match "[0-9].[0-9].[0-9].[0-9]"
}

Remove-Item -Path (PathAdjust -Path "..\Dataset\Network.txt")
New-Item -Path (PathAdjust -Path "..\Dataset") -Name "Network.txt" -ItemType File
$ThisComputer = [System.Net.Dns]::Resolve($ENV:COMPUTERNAME).AddressList

$CurrentAddress = $StartAddress
while (-not($CurrentAddress -eq $EndAddress)) {
    if ($ThisComputer -contains $CurrentAddres) {
        $CurrentAddress = GetNextAddress
    }

    $HasName, $PingFlag, $MacFlag = $false, $false, $false
    $Result = ""

    $Name = [System.Net.Dns]::Resolve($CurrentAddress).HostName
    if (IsIpAddress -StringInQuestion $Name) {
        $HasName = $false
    }
    else {
        $HasName = $true
    }

    $PingFlag = Test-Connection -ComputerName $CurrentAddress -Count 2 -TimeToLive 8 -Quiet
        
    if ($PingFlag) {
        #.\Spearfish.ps1 -Target $Proxy -Action "cmd.exe" -Arguments "/C ping $CurrentAddress"
        #.\Spearfish.ps1 -Target $Proxy -Action "cmd.exe" -Arguments "arp -a > C:\arp.txt"

        #$ArpFile = Get-Content -Path ($CurrentAddress + "\c$\arp.txt")
        $ArpFile = arp -a

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
                }
                    
                $Ip, $Mac, $Type = $NormalizedLine.Split(" ")

                if ($Ip -eq $CurrentAddress) {
                    $MacFlag = $true
                    break
                }
            } #End if (NUMBERS -contains Line[0]
        } #End foreach (line in ArpFile)

        if ($HasName) {
            $Result = ($Name + ":")
        }
        else {
            $Result = "($Name):"
        }

        if ($MacFlag) {
            $Result += $Mac
        }

        Add-Content -Value $Result -Path (PathAdjust -Path "..\Dataset\Network.txt")
    } #End if (PingFlag)

    $CurrentAddress = GetNextAddress
}