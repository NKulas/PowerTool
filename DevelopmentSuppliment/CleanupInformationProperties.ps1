$Files = Get-ChildItem -Path "..\Configuration\InformationProperties"

foreach ($file in $Files) {
    $Content = Get-Content -Path ("..\Configuration\InformationProperties\" + $file.Name)
    $Content = $Content.Replace("uint8","").Replace("uint16","").Replace("sint16","").Replace("uint32","").Replace("sint32","").Replace("uint64","").Replace("string","").Replace("boolean","").Replace("datetime","")
        
    $NewContent = ""
    foreach ($line in $Content) {
        $line = $line.Trim()
        $line = $line.Replace("[]","").Replace(";",",")
        $NewContent += "$line`n"
    }
    Set-Content -Path ("..\Configuration\InformationProperties\" + $file.Name) -Value $NewContent
}