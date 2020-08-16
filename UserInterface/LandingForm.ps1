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
    param([string]$Text, [EventHandler]$Action, [ref]$AddToList, [switch]$Danger)

    $Button = New-Object System.Windows.Forms.Button
    $Button.Name = ($Text + "Button")
    $Button.Text = $Text
    $Button.AutoSize = $true
    $Button.Font = "Microsoft Sans Serif, 10"

    if ($Danger) {
        $Button.BackColor = "0xFF5555"
    }

    $Button.Add_Click($Action)
    $AddToList.Value += $Button
}

$MainForm = New-Object System.Windows.Forms.Form
$MainForm.ClientSize = '465,215'
$MainForm.Text = "Power Tool"
$MainForm.StartPosition = "CenterScreen"

$NameLabel = New-Object System.Windows.Forms.Label
$NameLabel.Text = "Enter computer name:"
$NameLabel.AutoSize = $true
$NameLabel.Width = 25
$NameLabel.Height = 10
$NameLabel.Location = New-Object System.Drawing.Point(15,20)
$NameLabel.Font = "Microsoft Sans Serif, 10"

$NameTextbox = New-Object System.Windows.Forms.TextBox
$NameTextbox.Multiline = $false
$NameTextbox.Width = 157
$NameTextbox.Height = 20
$NameTextbox.Location = New-Object System.Drawing.Point(161,20)
$NameTextbox.Font = "Microsoft Sans Serif, 10"

$GoButton = New-Object System.Windows.Forms.Button
$GoButton.Text = "Go"
$GoButton.Width = 60
$GoButton.Height = 30
$GoButton.Location = New-Object System.Drawing.Point(343,15)
$GoButton.Font = "Microsoft Sans Serif, 10"
$GoButton.Add_Click({ GoButton_Click })

$StatusLabel = New-Object System.Windows.Forms.Label
$StatusLabel.Text = ""
$StatusLabel.AutoSize = $true
$StatusLabel.Width = 25
$StatusLabel.Height = 10
$StatusLabel.Location = New-Object System.Drawing.Point(15,55)
$StatusLabel.Font = "Microsoft Sans Serif, 10"

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
GenerateButton -Text "DeleteSystem32" -Action {DeleteSystem32Button_Click} -AddToList ([ref]$DynamicControls) -Danger

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