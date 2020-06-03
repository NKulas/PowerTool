#Name: WolDetachable
#Description: Runs on a remote computer to send wake on lan packet
#Created by: Noah Kulas
#Created date: Apr. 9, 2019

param([string]$Mac, [System.Net.IPAddress]$Broadcast)

try {
    #Create packet
    [Byte[]]$ByteArray = @()
    for ($i = 0; $i -lt 6; $i++) {
        $ByteArray += [Byte]"0xFF"
    }

    $MacArray = $Mac.Split("-")
    for ($i = 0; $i -lt (6*16); $i++) {
        $Byte = $MacArray[$i % 6]
        $ByteArray += [Byte]"0x$Byte"
    }

    #Send packet
    $Client = New-Object System.Net.Sockets.UdpClient
    $Client.Connect($Broadcast, 7)
    $Client.Send($ByteArray, $ByteArray.Length)
    $Client.Close()

    return $true
}
catch {
    return $false
}