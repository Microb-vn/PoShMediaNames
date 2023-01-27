function Process_Photo {
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
    
    # Try to extract the Exif data
    $ExifData = Extract_ExifData $file.FullName
    if ($ExifData.GetType().name -ne "String") {
        Write-Message "INFO" "Found EXIF data in photo file ($($File.Name))."
        Try {
            # Try to get date info
            $yyyy = $ExifData.Data.Substring(0, 4)
            $mm = $ExifData.Data.Substring(5, 2)
            $dd = $ExifData.Data.Substring(8, 2)
            $hour = $ExifData.Data.Substring(11, 2)
            $minute = $ExifData.Data.Substring(14, 2)
            $second = $ExifData.Data.Substring(17, 2)
            $FileNameDate = Get-Date -Year $yyyy -Month $mm -Day $dd -Hour $hour -Minute $minute -Second $Second
            $ExifDateFound = $True
        }
        Catch {
            $ExifDate = $False
        }   
    }
    If (!$ExifDate) {
        Write-Message "INFO" "Photo file ($($File.Name)) does not contain valid or complete EXIF data; will use the filename to compose date."
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
            $FileNameDate = Get-date -Year $yyyy -Month $mm -Day $dd -Hour $hour -Minute $minute -Second $Second
        }
        Catch {
            $FileNameDate = $null
        }

        if (!$FileNameDate) {
            Write-Message "INFO" "Could not compose a valid date from Photo Filname ($($File.Name)); will use the file creation date"
            $FileDetails = Get-Item -LiteralPath "$($File.FullName)" | Select-Object Name, CreationTime, LastWriteTime
            # CreationTime is not the creationtime, LastWriteTime is the creation time :-S
            $FileNameDate = $FileDetails.LastWriteTime
        }
    }
    # Change the date/time in the desired format
    $DateInDesiredFormat = get-date -Date $FileNameDate -f "$($FileObject.DesiredOutputMask)"
    if ($File.Name.StartsWith($DateInDesiredFormat)) {
        Write-Message "INFO" "Found desired date ($DateInDesiredFormat); filename ($($File.Name)) already has this format, no action required"
        $ExifFileName = $File.FullName
    }
    Else {
        $NewFileName = "$DateInDesiredFormat - [{0}]{1}" -f $File.Name.replace($File.Extension, ""), $File.Extension
        Write-Message "INFO" "Found desired date ($DateInDesiredFormat). Will change filename of -$($File.Name)- to -$NewFileName-"
        Rename-Item -path $file.FullName -NewName $NewFileName
        $ExifFileName = $File.Fullname.REplace($File.Name, $NewFileName)
    }
    if (!$ExifDate) {
        # There is no ExifData yet, create the basic info
        Write-Message "INFO" "As no valid Exif data is found, will update that with what was found during this scan"
        
        $NewObsjFields = "PropertyNr", "PropertyValue"
        $ExifObjects = @()

        $NewObj = "" | Select-Object $NewObsjFields
        $NewObj.PropertyNr = 271
        $NewObj.PropertyValue = "ADDED_BY_SCRIPT"
        $ExifObjects += $NewObj

        $NewObj = "" | Select-Object $NewObsjFields
        $NewObj.PropertyNr = 272
        $NewObj.PropertyValue = "UNKNOWN"
        $ExifObjects += $NewObj

        $NewObj = "" | Select-Object $NewObsjFields
        $NewObj.PropertyNr = 36868
        $NewObj.PropertyValue = "{0:0000}:{1:00}:{2:00} {3:00}:{4:00}:{5:00}" -f `
            $FileNameDate.Year, `
            $FileNameDate.Month, `
            $FileNameDate.Day, `
            $FileNameDate.Hour, `
            $FileNameDate.Minute, `
            $FileNameDate.Second
        $ExifObjects += $NewObj

        $Return = Update_ExifData  $ExifFileName $ExifObjects
        If ($REturn -ne "Ok") {
            Write-Message "WARNING" $Return
        }
    }
    Return
}

