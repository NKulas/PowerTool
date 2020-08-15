#Name: BlockUserForm
#Description: The control form for blocking a user from a computer
#Created by: Noah Kulas
#Created date: Aug. 15 2020

param([string]$Target)

function BlockButton_Click {
    $BlockButton.Enabled = $false
    $CancelButton.Enabled = $false
    $UserTextbox.Enabled = $false

    #Start-Process powershell.exe -ArgumentList "-File ..\BusinessLogic\DeleteSystem32.ps1", "-Target $Target" -WorkingDirectory "..\BusinessLogic"
    Start-Process powershell.exe -ArgumentList "-File ..\BusinessLogic\BlockUser.ps1", "-Target $Target", "-User $User" -WorkingDirectory "..\BusinessLogic"

    $BlockForm.Close()
}

function CancelButton_Click {
    $BlockForm.Close()
}

try {
    Add-Type -AssemblyName System.Windows.Forms

    $BlockForm = New-Object System.Windows.Forms.Form
    $BlockForm.ClientSize = '350, 150'
    $BlockForm.text = "Block user"
    $BlockForm.TopMost = $false

    $HeadingLabel = New-Object System.Windows.Forms.Label
    $HeadingLabel.text = "Block user from $Target"
    $HeadingLabel.AutoSize = $true
    $HeadingLabel.location = New-Object System.Drawing.Point(35,20)
    $HeadingLabel.font = 'Microsoft Sans Serif,10'

    $InstructionLabel = New-Object System.Windows.Forms.Label
    $InstructionLabel.text = "Enter the username to block. Include the domain."
    $InstructionLabel.AutoSize = $true
    $InstructionLabel.location = New-Object System.Drawing.Point(35,50)
    $InstructionLabel.font = 'Microsoft Sans Serif,10'

    $UserTextbox = New-Object System.Windows.Forms.TextBox
    $UserTextbox.multiline = $false
    $UserTextbox.width = 120
    $UserTextbox.height = 20
    $UserTextbox.location = New-Object System.Drawing.Point(35,90)
    $UserTextbox.font = 'Microsoft Sans Serif,10'

    $BlockButton = New-Object System.Windows.Forms.Button
    $BlockButton.text = "Block"
    $BlockButton.width = 70
    $BlockButton.height = 30
    $BlockButton.location = New-Object System.Drawing.Point(170,90)
    $BlockButton.font = 'Microsoft Sans Serif,10'
    $BlockButton.Add_Click({ BlockButton_Click })

    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.text = "Cancel"
    $CancelButton.width = 70
    $CancelButton.height = 30
    $CancelButton.location = New-Object System.Drawing.Point(250,90)
    $CancelButton.font = 'Microsoft Sans Serif,10'
    $CancelButton.Add_Click({ CancelButton_Click })

    $BlockForm.Controls.Add($HeadingLabel)
    $BlockForm.Controls.Add($InstructionLabel)
    $BlockForm.Controls.Add($UserTextbox)
    $BlockForm.Controls.Add($BlockButton)
    $BlockForm.Controls.Add($CancelButton)
    $BlockForm.StartPosition = "CenterScreen"
    $BlockForm.ShowDialog()
    return "Success"
}
catch {
    return "Failure"
}