#Name: NetworkDataInterpreter
#Description: Reads and formats data from the network configuration file
#Created by: Noah Kulas
#Created date: Feb. 1, 2020

#Modes:
#0: Get data from this computer's network
#1: Make data queries from the file

#Output formats:
#1: Subnet name -only available in mode 1
#2: Subnet abbreviation -only availalbe in mode 1
#3: Network address -not yet available
#4: Broadcast address -not yet available
#5: Subnet mask -not yet available
#6: First address
#7: Last address

#Input data currently must be the subnet abbreviation
param([int]$Mode, [string]$InputData, [int]$OutputFormat)

#Define functions
#This allows the path to be different in testing and launch from interface
function PathAdjust {
    param ([string] $Path)

    if (Test-Path $Path) {
        return $Path
    }
    elseif (Test-Path -Path $Path.Replace("..\","")) {
        return $Path.Replace("..\","")
    }
    else {
        return $Path
    }
}

function ConvertDecimalToBinary {
    param([int]$DecimalNumber)

    $BinaryNumber = @(0,0,0,0,0,0,0,0)

    for ($i = 7; $i -ge 0; $i--) {
        $TwoMultiple = [Math]::Pow(2, $i)
        
        $BinaryNumber[7 - $i] = [Math]::Floor($DecimalNumber / $TwoMultiple)
        $DecimalNumber = $DecimalNumber % $TwoMultiple
    }
    return $BinaryNumber
}

function ConvertBinaryToDeciaml {
    param([array]$BinaryNumber)

    $DecimalNumber = 0

    for ($i = 7; $i -ge 0; $i--) {
        $Value = ($BinaryNumber[7 - $i] * [Math]::Pow(2, $i))
        $DecimalNumber += $Value
    }
    return $DecimalNumber
}

#Start body
if ($Mode -eq 0) {
    $Data = Get-WmiObject -Class win32_NetworkAdapterConfiguration
    
    $Netmask = ""
    $ThisAddress = ""
    foreach ($Adapter in $Data) {
        if ($Adapter.Description -eq $InputData) {
            $Netmask = ($Adapter.IpSubnet)[0]
            $ThisAddress = ($Adapter.IpAddress)[0]
            break
        }
    }

    if (-not($Netmask -eq "")) {
        $ReturnAddress = ""

        $SplitAddress = $ThisAddress.Split(".")
        $SplitNetmask = $Netmask.Split(".")

        for ($j = 0; $j -lt 4; $j++) {
            $BinaryAddressOctet = ConvertDecimalToBinary($SplitAddress[$j])
            $BinaryNetmaskOctet = ConvertDecimalToBinary($SplitNetmask[$j])

            $DecimalResult = 0
            for ($k = 0; $k -lt 8; $k++) {
                if ($BinaryNetmaskOctet[$k] -eq 1) {
                    $DecimalResult += ($BinaryAddressOctet[$k] * [Math]::Pow(2, 7 - $k))
                }
                else {
                    if ($OutputFormat -eq 7) {
                        $DecimalResult += (1 * [Math]::Pow(2, 7 - $k))
                    }
                }
            }

            $ReturnAddress += [string]$DecimalResult
            if ($j -lt 3) {$ReturnAddress += "."}
        }
        return $ReturnAddress
    }
    else {
        return 0
    }
}

if ($Mode -eq 1) {
    $DataFile = Get-Content -Path (PathAdjust -Path "..\Configuration\NetworkLayout.txt")

    foreach ($Row in $DataFile) {
        $RowItemized = $Row.Split(";")

        if ($RowItemized -contains $InputData) {
        
            switch ($OutputFormat) {
                1 { return $RowItemized[1].Trim() } #Subnet name
                2 { return $RowItemized[0].Trim() } #Subnet abbreviation
                #3 {} #Network address
                #4 {} #Broadcast address
                #5 {} #Subnet mask
                6 { return $RowItemized[2].Trim() } #First address
                7 { return $RowItemized[3].Trim() } #Last address
            }
        }
    }
}


<#function IsNetMask {
    param([string]$DottedDecimal)

    $BlockS = $DottedDecimal.Split(".")

    if ($BlockS.Count -eq 4) {
        $NumberTwoMultiples = 0
        for ($i = 0; $i -le 8; $i++) {
            foreach ($Block in $BlockS) {
                if ([int]$Block -eq [math]::Pow(2,$i)) {
                    $NumberTwoMultiples += 1
                }
            }
        }

        if ($NumberTwoMultiples -eq 4) {
            return $true
        }
        else {
            return $false
        }
    }
    else {
        throw
    }
}#>