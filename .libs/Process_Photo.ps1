function Process_Photo {
    param (
        $filename,
        $fileobject,
        $config 
    )

    $file = $filename
    $InputYearPos = $fileobject.InputYearPos
    $InputMonthPos = $fileobject.InputMonthPos
    $InputDayPos = $fileobject.InputDayPos
    $InputHourPos = $fileobject.InputHourPos
    $InputMinutePos = $fileobject.InputMinutePos
    $InputSecondPos = $fileobject.InputSecondPos
    $DesiredOutputMask = $config.DesiredOutputMask
    
    # Try to extract the Exif data
    $ExifData = Extract_ExifData $file.FullName

    if ($ExifData.GetType().name -eq "String") {
        Write-Message "WARNING" "Cannot extract exif data from $($file.FullName); $ExifData"
        Return
    }

    # Pull all data from the Exif 
    Write-Message "INFO" "Found EXIF data in photo file ($($File.Name)). Capturing current values"
    Try {
        $imageDescription = $ExifData.Title
    }
    Catch {
        $imageDescription = $null
    }
    Try {
        $ExifMake = $ExifData.Make
    }
    Catch {
        $ExifMake = $null
    }
    Try {
        $ExifModel = $ExifData.Model
    }
    Catch {
        $ExifModel = $null
    }
    Try {
        $exifDate = $ExifData.Date
        $yyyy = $exifDate.Substring(0, 4)
        $mm = $exifDate.Substring(5, 2)
        $dd = $exifDate.Substring(8, 2)
        $hour = $exifDate.Substring(11, 2)
        $minute = $exifDate.Substring(14, 2)
        $second = $exifDate.Substring(17, 2)
        $FileNameDate = Get-Date -Year $yyyy -Month $mm -Day $dd -Hour $hour -Minute $minute -Second $Second
    }
    Catch {
        $exifDate = $null
    }

    if ($config.NewDateTime -eq "FromFileDetails") {
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
        }
        Else {
            # We already have a valid date pulled from the ExifData
        }

        if (!$FileNameDate) {
            Write-Message "INFO" "Could not compose a valid date from Photo Filname ($($File.Name)); will use the file creation date"
            $FileDetails = Get-Item -LiteralPath "$($File.FullName)" | Select-Object Name, CreationTime, LastWriteTime
            # CreationTime is not the creationtime, LastWriteTime is the creation time :-S
            $FileNameDate = $FileDetails.LastWriteTime
        }
    }
    Else {
        fileNameDate = $config.NewDateTime | get-date
    }
    # Do we need to change the file name?
    $fileNameNoExt = $file.Name.replace($file.Extension, "")
    if ($config.NewFileName -eq "PreserveCurrent") {
        $desiredNewFileName = "[$fileNameNoExt]"
    }
    ElseIf ($config.NewFileName -eq "FromParentFolder") {
        $desiredNewFileName = $file.Directory.Name
    }
    Else {
        $desiredNewFileName = $config.NewFileName
    }

    # Change the date/time in the desired format
    $DateInDesiredFormat = get-date -Date $FileNameDate -f $DesiredOutputMask

    # Do we need to change the filename?
    if (($config.NewFileName -eq "PreserveCurrent") -and ($File.Name.StartsWith($DateInDesiredFormat))) {
        Write-Message "INFO" "Found desired date ($DateInDesiredFormat) and NewFileName parameter to preserve old filename; filename ($($File.Name)) already has this format, no action required"
        $ExifFileName = $File.FullName
    }
    ElseIf (($File.Name.StartsWith($DateInDesiredFormat)) -and ($fileNameNoExt.replace("$DateInDesiredFormat - ", "") -eq $desiredNewFileName)) {
        Write-Message "INFO" "Found desired date ($DateInDesiredFormat) and possible new filename ($desiredNewFileName); filename ($($File.Name)) already has this format, no action required"
    }
    Else {
        $NewFileName = "$DateInDesiredFormat - {0}{1}" -f $desiredNewFileName, $File.Extension
        Write-Message "INFO" "Found desired date ($DateInDesiredFormat )and possible new filename ($desiredNewFileName). Will change filename of -$($File.Name)- to -$NewFileName-"
        Rename-Item -path $file.FullName -NewName $NewFileName
        $ExifFileName = $File.Fullname.REplace($File.Name, $NewFileName)
    }

    # See if we need to make exif updates
    Write-Message "INFO" "See if we need to make EXIF updates"
    <#
    The EXIF fields that are not the "date' field will get a special treatment. When NO valid date was found AND
    when the field is blank, the script fill fill the EXIF data with "dummy" data to indicate that the 
    EXIF data was blank at first access
    #>
    
    $NewObsjFields = "PropertyNr", "PropertyValue"
    $ExifObjects = @()

    # ImageDescription
    if ("$($config.imageDescription)" -ne "") {
        Write-Message "INFO" "Will set EXIF ImageDescription to value found in the SettingsFile ($($config.ImageDescription))"
        $NewObj = "" | Select-Object $NewObsjFields
        $NewObj.PropertyNr = 270
        $NewObj.PropertyValue = $config.ImageDescription
        $ExifObjects += $NewObj
    }
    else {
        if ( !$imageDescription -and !$exifDate) {
            $text = "DESCRIPTION IS AUTO ADDED BY MEDIA ORGANIZER SCRIPT"
            Write-Message "INFO" "Will set EXIF ImageDescription to $text"
            $NewObj = "" | Select-Object $NewObsjFields
            $NewObj.PropertyNr = 270
            $NewObj.PropertyValue = $text
            $ExifObjects += $NewObj
        }
    }
    # Make
    if ("$($config.ExifDeviceMake)" -ne "") {
        Write-Message "INFO" "Will set EXIF DeviceMake to value found in the SettingsFile ($($config.ExifDeviceMake))"
        $NewObj = "" | Select-Object $NewObsjFields
        $NewObj.PropertyNr = 271
        $NewObj.PropertyValue = $config.ExifDeviceMake
        $ExifObjects += $NewObj
    }
    else {
        if ( !$ExifMake -and !$exifDate) {
            $text = "SCRIPT"
            Write-Message "INFO" "Will set EXIF Make to $text"
            $NewObj = "" | Select-Object $NewObsjFields
            $NewObj.PropertyNr = 271
            $NewObj.PropertyValue = $text
            $ExifObjects += $NewObj
        }
    }
    #Model
    if ("$($config.ExifDeviceModel)" -ne "") {
        Write-Message "INFO" "Will set EXIF DeviceModel to value found in the SettingsFile ($($config.ExifDeviceModel))"
        $NewObj = "" | Select-Object $NewObsjFields
        $NewObj.PropertyNr = 272
        $NewObj.PropertyValue = $config.ExifDeviceModel
        $ExifObjects += $NewObj
    }
    else {
        if ( !$ExifModel -and !$exifDate) {
            $text = "PoShMediaNames_V1.0"
            Write-Message "INFO" "Will set EXIF Model to $text"
            $NewObj = "" | Select-Object $NewObsjFields
            $NewObj.PropertyNr = 272
            $NewObj.PropertyValue = $text
            $ExifObjects += $NewObj
        }
    }
    # Date
    $NewExifDate = "{0:0000}:{1:00}:{2:00} {3:00}:{4:00}:{5:00}" -f `
        $FileNameDate.Year, `
        $FileNameDate.Month, `
        $FileNameDate.Day, `
        $FileNameDate.Hour, `
        $FileNameDate.Minute, `
        $FileNameDate.Second
    if ($ExifDate -ne $NewExifDate) {
        $NewObj = "" | Select-Object $NewObsjFields
        $NewObj.PropertyNr = 306
        $NewObj.PropertyValue = $NewExifDate
        $ExifObjects += $NewObj
        $NewObj = "" | Select-Object $NewObsjFields
        $NewObj.PropertyNr = 36868
        $NewObj.PropertyValue = $NewExifDate
        $ExifObjects += $NewObj
    }
    if ($ExifObjects.count -ne 0) {
        $Return = Update_ExifData  $ExifFileName $ExifObjects
        If ($REturn -ne "Ok") {
            Write-Message "WARNING" $Return
        }
        Write-Message "INFO" "Exif Updates Done"
    }
    Else {
        write-message "INFO" "No Exif updates to be done"
    }
    Return
}


