#Name: LandingForm
#Description: The main user interface for the Power Tool utility
#Created by: Noah Kulas
#Created date: Apr. 2, 2019

$global:Target = ""

#Declare functions
function GoButton_Click {
    foreach ($Button in $AllActionButtons) {$Button.Enabled = $false}
    $StatusLabel.Text = "Please wait"

    $PlainName = $NameTextbox.Text
    $Domain = Get-Content -Path "..\Configuration\DomainName.txt"

    if (-not($PlainName -like "*$Domain")) {
        $global:Target = $PlainName + ".$Domain"
    }
    else {
        $global:Target = $PlainName
    }

    $NameTextbox.Text = $global:Target
    $Status = ""

    #Check for it in nslookup
    $Junk1, $Junk2, $Junk3, $LongName, $Junk4, $Junk5 = nslookup $global:Target
    if ($LongName -like "Name:*") {
        $DnsFlag = $true
        $Status += "Found in dns, "
    }
    else {
        $DnsFlag = $false
        $Status += "Not found in dns, "
    }

    #Try pinging it
    if (Test-Connection -ComputerName $global:Target -Count 2 -TimeToLive 8 -Quiet) {
        $PingFlag = $true
        $Status += "currently on"
        foreach ($Button in $AllActionButtons) {$Button.Enabled = $true}
    }
    else {
        $Status += "currently off"
    }

    $StatusLabel.Text = $Status
}

Add-Type -AssemblyName System.Windows.Forms

#Create fixed controls
function GenerateButton {
    param([string]$Text, [EventHandler]$Action, [ref]$AddToList)

    $Button = New-Object System.Windows.Forms.Button
    $Button.Name = ($Text + "Button")
    $Button.Text = $Text
    $Button.AutoSize = $true
    $Button.Font = "Microsoft Sans Serif, 10"

    $Button.Add_Click($Action)
    $AddToList.Value += $Button
}

$MainForm = New-Object System.Windows.Forms.Form
$MainForm.ClientSize = '465,215'
$MainForm.text = "Power Tool"
$MainForm.TopMost = $false

$NameLabel = New-Object System.Windows.Forms.Label
$NameLabel.text = "Enter computer name:"
$NameLabel.AutoSize = $true
$NameLabel.width = 25
$NameLabel.height = 10
$NameLabel.location = New-Object System.Drawing.Point(15,20)
$NameLabel.font = "Microsoft Sans Serif, 10"

$NameTextbox = New-Object System.Windows.Forms.TextBox
$NameTextbox.multiline = $false
$NameTextbox.width = 157
$NameTextbox.height = 20
$NameTextbox.location = New-Object System.Drawing.Point(161,20)
$NameTextbox.font = "Microsoft Sans Serif, 10"

$GoButton = New-Object System.Windows.Forms.Button
$GoButton.text = "Go"
$GoButton.width = 60
$GoButton.height = 30
$GoButton.location = New-Object System.Drawing.Point(343,15)
$GoButton.font = "Microsoft Sans Serif, 10"
$GoButton.Add_Click({ GoButton_Click })

$StatusLabel = New-Object System.Windows.Forms.Label
$StatusLabel.text = ""
$StatusLabel.AutoSize = $true
$StatusLabel.width = 25
$StatusLabel.height = 10
$StatusLabel.location = New-Object System.Drawing.Point(15,55)
$StatusLabel.font = "Microsoft Sans Serif, 10"

$FixedControls = @($NameLabel, $NameTextbox, $GoButton, $StatusLabel)

#Create dynamic controls
$LayoutPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$LayoutPanel.Width = 450
$LayoutPanel.Height = 100
$LayoutPanel.Location = New-Object System.Drawing.Point(8, 85)
$LayoutPanel.AutoScroll = $true

$DynamicControls = @()

#Restart
function RestartButton_Click {
    Start-Process powershell.exe -ArgumentList "-File ..\BusinessLogic\Restart.ps1", "-Target $global:Target" -WorkingDirectory "..\BusinessLogic"
}
GenerateButton -Text "Restart" -Action {RestartButton_Click} -AddToList ([ref]$DynamicControls)

#Shutdown
function ShutdownButton_Click {
    Start-Process powershell.exe -ArgumentList "-File ..\BusinessLogic\Shutdown.ps1", "-Target $global:Target" -WorkingDirectory "..\BusinessLogic"
}
GenerateButton -Text "Shutdown" -Action {ShutdownButton_Click} -AddToList ([ref]$DynamicControls)

#Logoff
function LogoffButton_Click {
    Start-Process powershell.exe -ArgumentList "-File ..\BusinessLogic\Logoff.ps1", "-Target $global:Target" -WorkingDirectory "..\BusinessLogic"
}
GenerateButton -Text "Logoff" -Action {LogoffButton_Click} -AddToList ([ref]$DynamicControls)

#Message
function MessageButton_Click {
    Start-Process powershell.exe -ArgumentList "-File ..\BusinessLogic\Message.ps1", "-Target $global:Target" -WorkingDirectory "..\BusinessLogic"
}
GenerateButton -Text "Message" -Action {MessageButton_Click} -AddToList ([ref]$DynamicControls)

#Rename
function RenameButton_Click {
    Start-Process powershell.exe -ArgumentList "-File ..\BusinessLogic\Rename.ps1", "-Target $global:Target" -WorkingDirectory "..\BusinessLogic"
}
GenerateButton -Text "Rename" -Action {RenameButton_Click} -AddToList ([ref]$DynamicControls)

#WhoAreYou
function WhoAreYouButton_Click {
    Start-Process powershell.exe -ArgumentList "-File ..\BusinessLogic\Info.ps1", "-Target $global:Target" -WorkingDirectory "..\BusinessLogic"
}
GenerateButton -Text "WhoAreYou" -Action {WhoAreYouButton_Click} -AddToList ([ref]$DynamicControls)

#Lock
function LockButton_Click {
    Start-Process powershell.exe -ArgumentList "-File ..\BusinessLogic\Lock.ps1", "-Target $global:Target" -WorkingDirectory "..\BusinessLogic"
}
GenerateButton -Text "Lock" -Action {LockButton_Click} -AddToList ([ref]$DynamicControls)

#DeleteSystem32
function DeleteSystem32Button_Click {
    .\DeleteSystem32Form.ps1 -Target $global:Target
}
GenerateButton -Text "DeleteSystem32" -Action {DeleteSystem32Button_Click} -AddToList ([ref]$DynamicControls)

#WakeOnLan
function WakeOnLanButton_Click {
    Start-Process powershell.exe -ArgumentList "-File ..\BusinessLogic\WakeOnLan.ps1", "-Target $global:Target" -WorkingDirectory "..\BusinessLogic"
}
GenerateButton -Text "WakeOnLan" -Action {WakeOnLanButton_Click} -AddToList ([ref]$DynamicControls)

#BlockUser
function BlockUserButton_Click {
    .\BlockUserForm.ps1 -Target $global:Target
}
GenerateButton -Text "BlockUser" -Action {BlockUserButton_Click} -AddToList ([ref]$DynamicControls)

#StartNetworkScan
function StartNetworkScanButton_Click {
    Start-Process powershell.exe -ArgumentList "-File ..\BusinessLogic\NetworkScanner.ps1" -WorkingDirectory "..\BusinessLogic"
}
GenerateButton -Text "StartNetworkScan" -Action {StartNetworkScanButton_Click} -AddToList ([ref]$DynamicControls)

#ViewNetworkData
function ViewNetworkDataButton_Click {
    Start-Process powershell.exe -ArgumentList "-File ..\BusinessLogic\ViewNetworkData.ps1" -WorkingDirectory "..\BusinessLogic"
}
GenerateButton -Text "ViewNetworkData" -Action {ViewNetworkDataButton_Click} -AddToList ([ref]$DynamicControls)

$LayoutPanel.Controls.AddRange($DynamicControls)

$MainForm.Controls.AddRange($FixedControls)
$MainForm.Controls.Add($LayoutPanel)

$MainForm.AcceptButton = $GoButton
$MainForm.ShowDialog()