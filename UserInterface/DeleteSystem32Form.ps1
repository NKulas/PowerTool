#Name: DeleteSystem32Form
#Description: The confirmation for deleting system32
#Created by: Noah Kulas
#Created date: Jun. 1, 2020

param([string]$Target)

function ConfirmTextbox_Changed {
    if ($ConfirmTextbox.Text -eq "yes") {
        $ConfirmButton.Enabled = $true
    }
    else {
        $ConfirmButton.Enabled = $false
    }
}

function ConfirmButton_Click {
    $ConfirmButton.Enabled = $false
    $CancelButton.Enabled = $false
    $ConfirmTextbox.Enabled = $false

    Start-Process powershell.exe -ArgumentList "-File ..\BusinessLogic\DeleteSystem32.ps1", "-Target $Target" -WorkingDirectory "..\BusinessLogic"

    $ConfirmForm.Close()
}

function CancelButton_Click {
    $ConfirmForm.Close()
}

try {
    #Confirmation message
    Add-Type -AssemblyName System.Windows.Forms

    $ConfirmForm = New-Object System.Windows.Forms.Form
    $ConfirmForm.ClientSize = '350, 150'
    $ConfirmForm.text = "Delete sytem32"
    $COnfirmForm.StartPosition = "CenterScreen"

    $WarningLabel = New-Object System.Windows.Forms.Label
    $WarningLabel.text = "WARNING! THIS WILL ACTUALLY DO IT!"
    $WarningLabel.AutoSize = $true
    $WarningLabel.location = New-Object System.Drawing.Point(35,20)
    $WarningLabel.font = 'Microsoft Sans Serif,10'

    $InstructionLabel = New-Object System.Windows.Forms.Label
    $InstructionLabel.text = "To continue, enter `"yes`" below.`nTo cancel, click cancel."
    $InstructionLabel.AutoSize = $true
    $InstructionLabel.location = New-Object System.Drawing.Point(35,50)
    $InstructionLabel.font = 'Microsoft Sans Serif,10'

    $ConfirmTextbox = New-Object System.Windows.Forms.TextBox
    $ConfirmTextbox.multiline = $false
    $ConfirmTextbox.width = 120
    $ConfirmTextbox.height = 20
    $ConfirmTextbox.location = New-Object System.Drawing.Point(35,90)
    $ConfirmTextbox.font = 'Microsoft Sans Serif,10'
    $ConfirmTextbox.Add_TextChanged({ ConfirmTextbox_Changed})

    $ConfirmButton = New-Object System.Windows.Forms.Button
    $ConfirmButton.text = "Confirm"
    $ConfirmButton.width = 70
    $ConfirmButton.height = 30
    $ConfirmButton.location = New-Object System.Drawing.Point(170,90)
    $ConfirmButton.font = 'Microsoft Sans Serif,10'
    $ConfirmButton.Enabled = $false
    $ConfirmButton.Add_Click({ ConfirmButton_Click })

    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.text = "Cancel"
    $CancelButton.width = 70
    $CancelButton.height = 30
    $CancelButton.location = New-Object System.Drawing.Point(250,90)
    $CancelButton.font = 'Microsoft Sans Serif,10'
    $CancelButton.Add_Click({ CancelButton_Click })

    $ConfirmForm.Controls.Add($WarningLabel)
    $ConfirmForm.Controls.Add($InstructionLabel)
    $ConfirmForm.Controls.Add($ConfirmTextbox)
    $ConfirmForm.Controls.Add($ConfirmButton)
    $ConfirmForm.Controls.Add($CancelButton)
    $ConfirmForm.ShowDialog()
    return "Success"
}
catch {
    return "Failure"
}