function Process_Video {
    param (
        $filename,
        $fileobject
    )

    $file = $filename
    $InputYearPos = $fileobject.InputYearPos
    $InputMonthPos = $fileobject.InputMonthPos
    $InputDayPos = $fileobject.InputDayPos
    $InputHourPos = $fileobject.InputHourPos
    $InputMinutePos = $fileobject.InputMinutePos
    $InputSecondPos = $fileobject.InputSecondPos
    $DesiredOutputMask = $fileobject.DesiredOutputMask
    
    # Try to convert the data of the current filename into a proper date
    $dd = $mm = $yyyy = $hour = $minute = $second = $null
    if ($File.Name.Length -ge [int]$InputDayPos + 2) {
        $dd = $file.Name.Substring($InputDayPos, 2)
    }
    if ($File.Name.Length -ge [int]$InputMonthPos + 2) {
        $mm = $file.Name.Substring($InputMonthPos, 2)
    }
    if ($File.Name.Length -ge [int]$InputYearPos + 4) {
        $yyyy = $file.Name.Substring($InputYearPos, 4)
    }
    if ($File.Name.Length -ge [int]$InputHourPos + 2) {
        $hour = $file.Name.Substring($InputHourPos, 2)
    }
    if ($File.Name.Length -ge [int]$InputMinutePos + 2) {
        $minute = $file.Name.Substring($InputMinutePos, 2)
    }
    if ($File.Name.Length -ge [int]$InputSecondPos + 2) {
        $second = $file.Name.Substring($InputSecondPos, 2)
    }
    Try {
        Write-Message "INFO" "Will attempt to create a valid date from Video Filename ($($File.Name))."
        $FileNameDate = Get-date -Year $yyyy -Month $mm -Day $dd -Hour $hour -Minute $minute -Second $Second
    }
    Catch {
        $FileNameDate = $null
    }

    if (!$FileNameDate) {
        Write-Message "INFO" "Could not compose a valid date from Video Filname ($($File.Name)); will use the file creation date"
        $FileDetails = Get-ChildItem -Path $File.FullName | Select-Object Name, CreationTime
        $FileNameDate = $FileDetails.CreationTime
    }
    # Change the date/time in the desired format
    $DateInDesiredFormat = get-date -Date $FileNameDate -f "$($FileObject.DesiredOutputMask)"
    if ($File.Name.StartsWith($DateInDesiredFormat)) {
        Write-Message "INFO" "Found desired date ($DateInDesiredFormat); filename ($($File.Name)) already has this format, no action required"
    }
    Else {
        $NewFileName = "$DateInDesiredFormat - [{0}]{1}" -f $File.Name.replace($File.Extension, ""), $File.Extension
        Write-Message "INFO" "Found desired date ($DateInDesiredFormat). Will change filename of -$($File.Name)- to -$NewFileName-"
        Rename-Item -path $file.FullName -NewName $NewFileName
    }
    Return
}