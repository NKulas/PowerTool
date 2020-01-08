#Name: Rename
#Description: Renames the given remote computer
#Created by: Noah Kulas
#Created date: Aug. 4, 2019

param([string]$Target)

try {
    Write-Output "Enter new name: "
    $NewName = Read-Host
    Rename-Computer -ComputerName $Target -NewName $NewName -DomainCredential "$env:UserDomain\$env:UserName" -Restart
    return "Success"
}
catch{
    return "Failure"
}