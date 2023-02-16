Function Read_Config {
    Param (
        $SettingsFilename,
        $ScriptPath
    )

    # Find and read the settingsfile
    if (! (Test-Path $SettingsFileName)) {
        Return "Configuration file ($settingsFileName) cannot be found"
    }

    Try {
        $config = Get-Content $SettingsFileName  | ConvertFrom-Json
    }
    Catch {
        Return "Cannot read the settingsfile ($SettingsFileName); last seen error: $($_.Exception.Message)"
    }

    # Screen the JSON file content
    # ProcessingMode
    if (@("Standard", "ExifFullUpdate") -notcontains $config.mode) {
        Return "Mode ($($config.mode)) in the settingsfile ($settingsFileName) is not Standard or ExifFullUpdate"
    }
    if ($config.mode -eq "ExifFullUpdate") {
        # Test for required attributes
        Try {
            $dummy = $config.ExifDeviceMake
            $dummy = $config.ExifDeviceModel
            $dummy = $config.ExifDateTime
            $dummy = $config.FileTitle
        }
        Catch {
            Return "When mode is ExifFullUpdate, attributes ExifDeviceMake, ExifDeviceModel, ExifDateTime, and FileTitle must also be defined"
        }
        If ($config.ExifDateTime -ne "FromFileDetails") {
            try{
                $Dummy = $Config.ExifDateTime | Get-Date
            }
            Catch {
                Return "The specified ExifDateTime ($($Config.ExifDateTime)) in the settingsfile ($settingsFileName) is not a valid date; use your localized data format, or specify 'FromFileDetails'!"
            }
        }
    
    }
    # Field: ProcessFolder
    if ($config.ProcessFolder[0] -eq ".") {
        $config.ProcessFolder = $config.ProcessFolder.Replace(".", "$ScriptPath")
    }
    if (! (Test-Path $config.ProcessFolder)) {
        Return "Processfolder ($($config.ProcessFolder)) specified in the settingsfile ($settingsFileName) cannot be found"
    }
    # Number of Objects
    if ($config.Objects.Count -ne 2) {
        Return "The number of 'Objects' found in settingsfile ($settingsFileName) is $($config.Objects.Count); this should be 2"
    }
    $PhotoCount = 0
    $VideoCount = 0
    ForEach ($Object in $config.Objects) {
        # Check Type
        if ($Object.Type -eq "Photo") {
            $PhotoCount++
        }
        Elseif ($Object.Type -eq "Video") {
            $VideoCount++
        }
        Else {
            Return "Invalid Object Type found ($($Object.Type)) in settingsfile ($settingsFileName)"
        }
        # Are all numbers numbers?
        $TestValue = "$($Object.InputYearPos)$($Object.InputMonthPos)$($Object.InputDayPos)$($Object.InputHourPos)$($Object.InputMinutePos)$($Object.InputSecondPos)"
        if ($TestValue -notmatch "^[\d\.]+$") {
            Return "One of the DateTime positions of object $($Object.Type) in settingsfile ($settingsFileName) is not numeric; please check!"
        }
        # Is the mask valid?
        $FormattedDate = Get-Date -F $Object.DesiredOutputMask
        if ($FormattedDate -match "(?=.*[a-z])(?=.*[A-Z])") {
            Return "The DesiredOutputMask of object $($Object.Type) in settingsfile ($settingsFileName) is invalid."
        }    
    }
    If (($PhotoCount -ne 1) -or ($VideoCount -ne 1)) {
        Return "Mismatch in number of Video ($VideoCount) and/or Photo ($PhotoCount) objects in settingsfile ($settingsFileName); these should both be 1"
    }
    Return $Config   
}

