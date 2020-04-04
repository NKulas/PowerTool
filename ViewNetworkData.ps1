#Name: ViewNetworkData
#Description: Reads data from the network data files
#Created by: Noah Kulas
#Created date: Apr. 4 2020

Write-Host "Enter subnet abbreviation: " -NoNewline
$Subnet = Read-Host

if (Test-Path -Path "Dataset\$Subnet.txt") {
    $Content = Get-Content -Path "Dataset\$Subnet.txt"
    Write-Output $Content
}
else {
    Write-Output "No data is recorded for this subnet"
}

Read-Host