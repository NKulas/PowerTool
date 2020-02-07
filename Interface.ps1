#Name: Interface
#Description: The main user interface for the Power Tool utility
#Created by: Noah Kulas
#Created date: Apr. 2, 2019

$global:Target = ""

#Declare functions
function GoButton_Click {
    foreach ($Button in $AllActionButtons) {$Button.Enabled = $false}
    $StatusLabel.Text = "Please wait"

    $PlainName = $NameTextbox.Text
    $Domain = Get-Content -Path "Configuration\DomainName.txt"

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

function RestartButton_Click {
    Start-Process powershell.exe -ArgumentList "-File Modules\Restart.ps1", "-Target $global:Target"
}

function ShutdownButton_Click {
    Start-Process powershell.exe -ArgumentList "-File Modules\Shutdown.ps1", "-Target $global:Target"
}

function LogoffButton_Click {
    Start-Process powershell.exe -ArgumentList "-File Modules\Logoff.ps1", "-Target $global:Target"
}

function MessageButton_Click {
    Start-Process powershell.exe -ArgumentList "-File Modules\Message.ps1", "-Target $global:Target"
}

function RenameButton_Click {
    Start-Process powershell.exe -ArgumentList "-File Modules\Rename.ps1", "-Target $global:Target"
}

function InfoButton_Click {
    Start-Process powershell.exe -ArgumentList "-File Modules\Info.ps1", "-Target $global:Target"
}

function LockButton_Click {
    Start-Process powershell.exe -ArgumentList "-File Modules\Lock.ps1", "-Target $global:Target"
}

function System32Button_Click {
    Start-Process powershell.exe -ArgumentList "-File Modules\DeleteSystem32.ps1", "-Target $global:Target"
}

#Create the form
Add-Type -AssemblyName System.Windows.Forms

$MainForm = New-Object System.Windows.Forms.Form
$MainForm.ClientSize = '465,170'
$MainForm.text = "Power Tool"
$MainForm.TopMost = $false

$NameLabel = New-Object System.Windows.Forms.Label
$NameLabel.text = "Enter computer name:"
$NameLabel.AutoSize = $true
$NameLabel.width = 25
$NameLabel.height = 10
$NameLabel.location = New-Object System.Drawing.Point(15,20)
$NameLabel.font = 'Microsoft Sans Serif,10'

$NameTextbox = New-Object System.Windows.Forms.TextBox
$NameTextbox.multiline = $false
$NameTextbox.width = 157
$NameTextbox.height = 20
$NameTextbox.location = New-Object System.Drawing.Point(161,20)
$NameTextbox.font = 'Microsoft Sans Serif,10'

$GoButton = New-Object System.Windows.Forms.Button
$GoButton.text = "Go"
$GoButton.width = 60
$GoButton.height = 30
$GoButton.location = New-Object System.Drawing.Point(343,15)
$GoButton.font = 'Microsoft Sans Serif,10'
$GoButton.Add_Click({ GoButton_Click })

$StatusLabel = New-Object System.Windows.Forms.Label
$StatusLabel.text = ""
$StatusLabel.AutoSize = $true
$StatusLabel.width = 25
$StatusLabel.height = 10
$StatusLabel.location = New-Object System.Drawing.Point(15,55)
$StatusLabel.font = 'Microsoft Sans Serif,10'

$RestartButton = New-Object System.Windows.Forms.Button
$RestartButton.text = "Restart"
$RestartButton.width = 60
$RestartButton.height = 30
$RestartButton.location = New-Object System.Drawing.Point(16,90)
$RestartButton.font = 'Microsoft Sans Serif,10'
$RestartButton.Add_Click({ RestartButton_Click })

$ShutdownButton = New-Object System.Windows.Forms.Button
$ShutdownButton.text = "Shutdown"
$ShutdownButton.width = 75
$ShutdownButton.height = 30
$ShutdownButton.location = New-Object System.Drawing.Point(85,90)
$ShutdownButton.font = 'Microsoft Sans Serif,10'
$ShutdownButton.Add_Click({ ShutdownButton_Click })

$LogoffButton = New-Object System.Windows.Forms.Button
$LogoffButton.text = "Logoff"
$LogoffButton.width = 60
$LogoffButton.height = 30
$LogoffButton.location = New-Object System.Drawing.Point(170,90)
$LogoffButton.font = 'Microsoft Sans Serif,10'
$LogoffButton.Add_Click({ LogoffButton_Click })

$MessageButton = New-Object System.Windows.Forms.Button
$MessageButton.text = "Send message"
$MessageButton.width = 113
$MessageButton.height = 30
$MessageButton.location = New-Object System.Drawing.Point(240,90)
$MessageButton.font = 'Microsoft Sans Serif,10'
$MessageButton.Add_Click({ MessageButton_Click })

$RenameButton = New-Object System.Windows.Forms.Button
$RenameButton.text = "Rename"
$RenameButton.width = 65
$RenameButton.height = 30
$RenameButton.location = New-Object System.Drawing.Point(363,90)
$RenameButton.font = 'Microsoft Sans Serif,10'
$RenameButton.Add_Click({ RenameButton_Click })

$InfoButton = New-Object System.Windows.Forms.Button
$InfoButton.text = "Who are you"
$InfoButton.width = 100
$InfoButton.height = 30
$InfoButton.location = New-Object System.Drawing.Point(15, 130)
$InfoButton.font = 'Microsoft Sans Serif,10'
$InfoButton.Add_Click({ InfoButton_Click })

$LockButton = New-Object System.Windows.Forms.Button
$LockButton.text = "Lock"
$LockButton.width = 50
$LockButton.height = 30
$LockButton.location = New-Object System.Drawing.Point(125, 130)
$LockButton.font = 'Microsoft Sans Serif,10'
$LockButton.Add_Click({ LockButton_Click })

$System32Button = New-Object System.Windows.Forms.Button
$System32Button.text = "Delete System32"
$System32Button.width = 120
$System32Button.height = 30
$System32Button.location = New-Object System.Drawing.Point(185, 130)
$System32Button.font = 'Microsoft Sans Serif,10'
$System32Button.BackColor = "#ffcccb"
$System32Button.Add_Click({ System32Button_Click })

$AllControls = @($NameLabel,$NameTextbox,$GoButton,$StatusLabel,$RestartButton,$ShutdownButton,$LogoffButton,$MessageButton,$RenameButton,$InfoButton,$LockButton,$System32Button)
$AllActionButtons = @($RestartButton,$ShutdownButton,$LogoffButton,$MessageButton,$RenameButton,$InfoButton,$LockButton,$System32Button)

foreach ($Button in $AllActionButtons) {$Button.Enabled = $false}

$MainForm.controls.AddRange($AllControls)
$MainForm.ShowDialog()