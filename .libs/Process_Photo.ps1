function Process_Photo {
    param (
        $filename,
        $fileobject 
    )

    # For single-module testing:
    if (!$Filename -and !$fileobject) {
        $TESTMODE = $true
        $filex = "Z:\Documenten\GitHub\PoShMediaNames\ProcessFolder\20221006_151358.mp4"
        $file = Get-ChildItem -Path $filex
        $InputYearPos = "0"
        $InputMonthPos = "4"
        $InputDayPos = "6"
        $InputHourPos = "9"
        $InputMinutePos = "11"
        $InputSecondPos = "13"
        $DesiredOutputMask = "YYYY-mmdd HHMMSS"
    }
    Else {
        $TESTMODE = $false
        $file = $filename
        $InputYearPos = $fileobject.InputYearPos
        $InputMonthPos = $fileobject.InputMonthPos
        $InputDayPos = $fileobject.InputDayPos
        $InputHourPos = $fileobject.InputHourPos
        $InputMinutePos = $fileobject.InputMinutePos
        $InputSecondPos = $fileobject.InputSecondPos
        $DesiredOutputMask = $fileobject.DesiredOutputMask
    }
    
    # Try to convert the data of the current filename into a proper date
    $dd = $mm = $yyyy = $null
    if ($File.Name.Length -ge [int]$InputDayPos + 2) {
        $dd = $file.Name.Substring($InputDayPos, 2)
    }
    if ($File.Name.Length -ge [int]$InputMonthPos + 2) {
        $mm = $file.Name.Substring($InputMonthPos, 2)
    }
    if ($File.Name.Length -ge [int]$InputYearPos + 4) {
        $yyyy = $file.Name.Substring($InputYearPos, 4)
    }

    Return "Ok"
}

Process_Photo