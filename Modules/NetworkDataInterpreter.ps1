#Name: NetworkDataInterpreter
#Description: Reads and formats data from the network configuration file
#Created by: Noah Kulas
#Created date: Feb. 1, 2020

#Modes:
#0: Get data from this computer's network -not functional
#1: Make data queries from the file

#Input formats:
#1: Subnet name
#2: Subnet abbeviation
#6: First address (Numbered stangely for uniformity with output formats)

#Output formats:
#1: Subnet name
#2: Subnet abbreviation
#3: Network address
#4: Broadcast address
#5: Subnet mask
#6: First address
#7: Last address

param(<#[int]$Mode,#> [int]$InputFormat, [string]$InputData, [int]$OutputFormat)

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
    param([int]$DecimalNumber, [int]$Bits = 8)

    $BinaryNumber= @()
    for ($i = 0; $i -lt $Bits; $i++) {
        $BinaryNumber += 0
    }

    for ($i = $BinaryNumber.length - 1; $i -ge 0; $i--) {
        $TwoMultiple = [Math]::Pow(2, $i)
        
        $BinaryNumber[$BinaryNumber.length - 1 - $i] = [Math]::Floor($DecimalNumber / $TwoMultiple)
        $DecimalNumber = $DecimalNumber % $TwoMultiple
    }
    return $BinaryNumber
}

function ConvertBinaryToDecimal {
    param([array]$BinaryNumber)

    $DecimalNumber = 0

    for ($i = 7; $i -ge 0; $i--) {
        $Value = ($BinaryNumber[7 - $i] * [Math]::Pow(2, $i))
        $DecimalNumber += $Value
    }
    return $DecimalNumber
}

function AddToIpAddress {
    param([string]$Address, [int]$Increase)

    $ItemizedAddress = $Address.Split(".")

    for ($i = 3; $i -ge 0; $i--) {
        [int]$ItemizedAddress[$i] += ($Increase % 256)
        $Increase = [Math]::Floor($Increase / 256)

        if ($Increase -eq 0) {
            break
        }
    }

    #Turn back into a string
    $ReturnString = ""
    $FirstOctet = $true
    foreach ($Octet in $ItemizedAddress) {
        if (-not($FirstOctet)) {
            $ReturnString += [string]".$Octet"
        }
        else {
            $ReturnString += [string]$Octet
            $FirstOctet = $false
        }
    }
    return $ReturnString
}

function GetNetworkRange {
    param([string]$Address, [string]$Netmask)

    #Convert everything to binary
    $NetmaskItemized = $Netmask.Split(".")
    $BinaryNetmaskItemized = @()

    foreach ($Octet in $NetmaskItemized) {
        $BinaryNetmaskItemized += ConvertDecimalToBinary -DecimalNumber $Octet
    }

    $AddressItemized = $Address.Split(".")
    $BinaryAddressItemized = @()

    foreach ($Octet in $AddressItemized) {
        $BinaryAddressItemized += ConvertDecimalToBinary -DecimalNumber $Octet
    }

    #Create the network address
    $NetworkAddressBinary = @();
    for ($i = 0; $i -lt 32; $i++) {
        if ($BinaryNetmaskItemized[$i] -eq 1) {
            $NetworkAddressBinary += $BinaryAddressItemized[$i]
        }
    }

    $NumberOfHostBits = 32 - $NetworkAddressBinary.length
    $Maximum = [Math]::Pow(2, $NumberOfHostBits) - 1

    while ($NetworkAddressBinary.length -lt 32) {
        $NetworkAddressBinary += 0
    }

    $NetworkAddressString = ""
    $FirstOctet = $true
    for ($i = 0; $i -lt 32; $i += 8) {
        if (-not($FirstOctet)) {
            $NetworkAddressString += "."
        }
        else {
            $FirstOctet = $false
        }

        $NetworkAddressString += [string](ConvertBinaryToDecimal -BinaryNumber $NetworkAddressBinary[$i..($i + 7)])
    }

    return @($NetworkAddressString, $Maximum)
}

function FirstAddress {
    param($Range)

    return AddToIpAddress -Address $Range[0] -Increase 1
}

function LastAddress {
    param($Range)

    return AddToIpAddress -Address $Range[0] -Increase ($Range[1] - 1)
}

function BroadcastAddress {
    param($Range)

    return AddToIpAddress -Address $Range[0] -Increase $Range[1]
}

<#if ($Mode -eq 0) {
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
}#>

<#if ($Mode -eq 1) {#>
    $DataFile = Get-Content -Path (PathAdjust -Path "..\Configuration\NetworkLayout.txt")

    foreach ($Row in $DataFile) {
        if ($Row -notlike "#*" -and $Row -notlike "") {
        $RowItemized = $Row.Split(";")

        switch ($InputFormat) {
            1 { $Comparison = $RowItemized[1] } #Subnet name
            2 { $Comparison = $RowItemized[0] } #Subnet abbreviation
            6 { $Comparison = $RowItemized[2] } #Fist address
        }

        if ($Comparison.Trim() -match $InputData) {
            $RangeObject = GetNetworkRange -Address $RowItemized[2] -Netmask $RowItemized[3]
        
            switch ($OutputFormat) {
                1 { return $RowItemized[1].Trim() } #Subnet name
                2 { return $RowItemized[0].Trim() } #Subnet abbreviation
                3 { return ($RangeObject[0]) } #Network address
                4 { return BroadcastAddress -Range $RangeObject } #Broadcast address
                5 { return $RowItemized[3].Trim() } #Netmask
                6 { return FirstAddress -Range $RangeObject } #First address
                7 { return LastAddress -Range $RangeObject } #Last address
            }
            break
        }
    }
    }
#}