#Name: NetworkDataInterpreter
#Description: Reads and formats data from the network configuration file
#Created by: Noah Kulas
#Created date: Feb. 1, 2020

#Modes:
#0: Get current network data
#1: Make data queries from the file - Not available yet

#Output formats: -Only start and end available
#0: Subnet name
#1: Subnet abbreviations
#2: Network address
#3: Broadcast address
#4: Subnet mask
#5: First address
#6: Last address

#Input data currently must be the subnet abbreviation
param([int]$Mode, [string]$InputData, [int]$OutputFormat)

#Define functions
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
                    if ($OutputFormat -eq 6) {
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


#try {
    <#$Content = Get-Content -Path "..\Configuration\NetworkLayout.txt" -Raw
    foreach ($Line in $Content.Split("`n")) {

        if (-not($Line[0] -eq "#")) {
            $LineParts = $Line.Split(";")
            $FullName = $LineParts[0]
            $ShortName = $LineParts[1]
            $StartAddress = $LineParts[2]
            $EndAddress = $LineParts[3]

            if ($ShortName -eq $InputData) {
                switch ($OutputFormat) {
                    0 {return $FullName}
                    1 {return $ShortName}
                    #2 {return $NetworkAddress}
                    #3 {return $BroadcastAddress}
                    #4 {return $NetMask}
                    5 {return $FirstAddress}
                    6 {return $LastAddress}
                }
            }

            if (IsNetMask $LineParts[3]) {
                $NetworkAddress = $LineParts[2]
                $NetMask = $LineParts[3]
            }
            else {
                $StartAddress = $LineParts[2]
                $EndAddress = $LineParts[3]
            }
        }
    }#>

<#}
catch {

}#>