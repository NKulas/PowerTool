#Name: WakeOnLan
#Description: Send WOL magic packet to the given computer
#Created by: Noah Kulas
#Created date: Apr. 5, 2020

param([string]$Target)

. ".\ModularFunctions\IsIpAddress.ps1"

try {
    $TargetFound = $false
    $SubnetFiles = Get-ChildItem -Path "..\Dataset"

    :l1 foreach ($File in $SubnetFiles) {
        $Content = Get-Content -Path ("..\Dataset\" + $File.Name)
    
        :l2 foreach ($Line in $Content) {
            $CandidateName, $CandidateMac = $Line.Split(" : ")

            if ($CandidateName.Trim() -eq $Target) {
                if ($CandidateMac.Trim() -ne "~") {
                    $TargetFound = $true
                    break l1
                    break l2
                }
            }
        }
    }

    if ($TargetFound) {
        #Because the loops break, this will be the correct file
        foreach ($Line in $Content) {
            $TargetName, $TargetMac = $Line.Split(" : ")
            $TargetName = $TargetName.Trim()

            if (Test-Connection -ComputerName $TargetName -Count 2 -TimeToLive 8 -Quiet) {
                #Check that it allows Windows RPC
                if ((Test-NetConnection $TargetName -Port 135).TcpTestSucceeded) {
                    #Check that the ip has an associated DNS name
                    if (-not(IsIpAddress -StringInQuestion ([System.Net.Dns]::Resolve($TargetName).HostName))) {

                        #The spearfish module has problems using an ip address as the proxy
                        $Proxy = ([System.Net.Dns]::Resolve($TargetName).HostName)
                    
                        Copy-Item -Path "..\Detachables\WolDetachable.ps1" -Destination "\\$Proxy\c$"
                        .\Spearfish.ps1 -Target $Proxy -Action "Powershell.exe" -Arguments "-File `"C:\WolDetachable.ps1`" -Mac `"$CandidateMac`" -Broadcast `"255.255.255.255`"" -AsSystem
                        Remove-Item -Path "\\$Proxy\c$\WolDetachable.ps1"

                        return $true
                    }
                }
            }
        }
    }
    else {
        return $false
    }
}
catch {
    return $false
}