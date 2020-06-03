#Name: Message
#Description: Displays a message on the given remote computer
#Created by: Noah Kulas
#Created date: Jan. 22, 2019

param([string]$Target)

try {
    Write-Output "Enter your message:"
    $Message = Read-Host
	
    Write-Output "Enter seconds for the message to be shown:`n(This will deault to 60 seconds if nothing is entered)"
    $Timeout = Read-Host
    if ($Timeout -eq "") {$Timeout = 60}

    msg * /Server $Target /Time $Timeout /V $Message

    return $true
}
catch {
    return $false
}