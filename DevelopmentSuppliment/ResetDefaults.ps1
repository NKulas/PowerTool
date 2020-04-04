Set-Content -Path "..\Configuration\DomainName.txt" -Value "example.com"

Set-Content -Path "..\Configuration\NetworkLayout.txt" -Value (Get-Content -Path "Defaults\DefaultNetworkLayout.txt")

Remove-Item -Path "..\Dataset\*"
Set-Content -Path "..\Dataset\COR.txt" -Value (Get-Content -Path "Defaults\DefaultMacAddresses.txt")