#Name: IsIpAddress
#Description: A function that determines if a given string is an ip address
#Created by: Noah Kulas
#Created date: May 26, 2020

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

    #[System.Net.IpAddress]::TryParse(
}