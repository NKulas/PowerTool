#Name: BlockUserForm
#Description: The control form for blocking or unblocking a user from a computer
#Created by: Noah Kulas
#Created date: Aug. 15 2020

param([string]$Target)

function BlockButton_Click {
    $BlockButton.Enabled = $false
    $CancelButton.Enabled = $false
    $UserTextbox.Enabled = $false

    Start-Process powershell.exe -ArgumentList "-File ..\BusinessLogic\BlockUser.ps1", "-Target $Target", "-User $User" -WorkingDirectory "..\BusinessLogic"

    $BlockForm.Close()
}

function CancelButton_Click {
    $BlockForm.Close()
}

try {
    Add-Type -AssemblyName System.Windows.Forms

    $BlockForm = New-Object System.Windows.Forms.Form
    $BlockForm.ClientSize = "350, 150"
    $BlockForm.Text = "Control user blocking"
    $BlockForm.StartPosition = "CenterScreen"

    $HeadingLabel = New-Object System.Windows.Forms.Label
    $HeadingLabel.Text = "Control user blocking on $Target"
    $HeadingLabel.AutoSize = $true
    $HeadingLabel.Location = New-Object System.Drawing.Point(35,20)
    $HeadingLabel.Font = "Microsoft Sans Serif, 10"

    $InstructionLabel = New-Object System.Windows.Forms.Label
    $InstructionLabel.Text = "Enter the username to block or unblock.`nInclude the domain."
    $InstructionLabel.AutoSize = $true
    $InstructionLabel.Location = New-Object System.Drawing.Point(35,50)
    $InstructionLabel.Font = "Microsoft Sans Serif, 10"

    $UserTextbox = New-Object System.Windows.Forms.TextBox
    $UserTextbox.Multiline = $false
    $UserTextbox.Width = 120
    $UserTextbox.Height = 20
    $UserTextbox.Location = New-Object System.Drawing.Point(35,90)
    $UserTextbox.Font = "Microsoft Sans Serif, 10"

    $BlockButton = New-Object System.Windows.Forms.Button
    $BlockButton.Text = "Block or unblock"
    $BlockButton.Width = 90
    $BlockButton.Height = 40
    $BlockButton.Location = New-Object System.Drawing.Point(170,90)
    $BlockButton.Font = "Microsoft Sans Serif, 10"
    $BlockButton.Add_Click({ BlockButton_Click })

    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Text = "Cancel"
    $CancelButton.Width = 70
    $CancelButton.Height = 30
    $CancelButton.Location = New-Object System.Drawing.Point(270,90)
    $CancelButton.Font = "Microsoft Sans Serif, 10"
    $CancelButton.Add_Click({ CancelButton_Click })

    $BlockForm.Controls.Add($HeadingLabel)
    $BlockForm.Controls.Add($InstructionLabel)
    $BlockForm.Controls.Add($UserTextbox)
    $BlockForm.Controls.Add($BlockButton)
    $BlockForm.Controls.Add($CancelButton)
    $BlockForm.ShowDialog()

    return "Success"
}
catch {
    return "Failure"
}