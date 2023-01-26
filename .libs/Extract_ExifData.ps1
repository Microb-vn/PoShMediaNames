# With courtesy of -Unknown-
# I did not write this code myself. Found it in a knowledge article. I changed the code into a funciton that 
# returns (most of the) Exif data in a Powershell Structured Object.
# Unfortunatelly I did not capture the Avatar or name of the original script developer.
# 
# At the time gave him some kudos though!
# -----------------------------------------------------------------
# Load this file in your script with this command:
# . <(full-)path-to-whatever-you-call-this-file>
# and use the function call
# Extract_ExifData <(full-)path-to-your-photo-file>
#
# If all goes wel, a custom object is returned with the EXIF details
# When errors are found, a variable of type String is returned

function ReadAttribute {
    $DWGAttr = $Null
    Try { $DWGAttr = $photo.GetPropertyItem($Args[0]) }
    Catch { $DWGAttr = $Null; }
    Finally { Write-Output $DWGAttr }
}

function ConvertToString {
    Try { $DWGstr = (new-object System.Text.UTF8Encoding).GetString($Args[0]) }
    Catch { $DWGstr = $null; }
	
    Finally {
        # Trim of trailing zero:
        if ($DWGstr) {
            $TidyString = $DWGstr.Substring(0, ($DWGstr.Length - 1))
        }
        Else { $TidyString = "" }
        Write-Output ($TidyString)
    }
}

function ConvertToNumber {
    $First = $Args[0].value[0] + 256 * $Args[0].value[1] + 65536 * $Args[0].value[2] + 16777216 * $Args[0].value[3] ; $Second = $Args[0].value[4] + 256 * $Args[0].value[5] + 65536 * $Args[0].value[6] + 16777216 * $Args[0].value[7] ; 
    if ($first -gt 2147483648) { $first = $first - 4294967296 } ; if ($Second -gt 2147483648) { $Second = $Second - 4294967296 } ; if ($Second -eq 0) { $Second = 1 } ; 
    if (($first -eq 1) -and ($Second -ne 1)) { write-output ("1/" + $Second) } else { write-output ($first / $second) }
}

Function Extract_ExifData {
    param (
        $FileName
    )

    If ($FileName -eq $null) {
        return "Function Extract_ExifData - Usage: Extract_ExifData [image path]"
    }
    If ((Test-Path -LiteralPath $FileName) -ne $true) {
        return "Function Extract_ExifData - File -$FileName- not found"
    }

    #_Build return object
    $Return_Object = "" | Select `
        "Pixel_X_Dimension", `
        "Pixel_Y_Dimension", `
        "X_Resolution", `
        "Y_Resolution", `
        "Color_Space", `
        "Data", `
        "Title", `
        "Author", `
        "File_Source", `
        "Maker", `
        "Model", `
        "Lens_Maker", `
        "Lens_Model", `
        "F_Number", `
        "Shutter_Speed", `
        "ISO", `
        "Focal_Lenght", `
        "Focal_Lenght_35mm", `
        "Subject_Distance_Range", `
        "Subject_Distance", `
        "Flash", `
        "Orientation", `
        "Contrast", `
        "Saturation", `
        "Sharpness", `
        "Brightness", `
        "White_Balance", `
        "Metering_Mode", `
        "Exposure_Mode", `
        "Exposure_Program", `
        "Exposure_Bias", `
        "Scene_Type", `
        "Gain_Control", `
        "Light_Source"

    # Load theß System.Drawing DLL before doing any operations
    [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") > $null
    # And System.Text if reading any of the string fields
    [System.Reflection.Assembly]::LoadWithPartialName("System.Text") > $null

    # Create an Image object
    $photo = [System.Drawing.Image]::FromFile($filename)

    # Read out the date taken (string)
    $dateProperty = ReadAttribute(0x9003)
    $dateTaken = ConvertToString($dateProperty.Value)

    # ISO (unsigned short integer)
    $isoProperty = ReadAttribute(0x8827)
    if ($isoProperty -eq $null) {
        $iso = $null
    }
    Else {
        $iso = [System.BitConverter]::ToUInt16($isoProperty.Value, 0)
    }

    # Title
    $TitleProperty = ReadAttribute(0x010e)
    $Title = ConvertToString($TitleProperty.Value)

    # Author
    $AuthorProperty = ReadAttribute(0x013b)
    $Author = ConvertToString($AuthorProperty.Value)

    # Maker
    $makerProperty = ReadAttribute(0x010f)
    $maker = ConvertToString($makerProperty.Value)

    # Model
    $modelProperty = ReadAttribute(0x0110)
    $model = ConvertToString($modelProperty.Value)

    # Orientation
    $orientationProperty = ReadAttribute(0x0112)
    if ($orientationProperty -eq $null) {
        $orientation = $null
    }
    Else {
        $orientation = [System.BitConverter]::ToUInt16($orientationProperty.Value, 0)
    }

    # Width resolution
    $xResProperty = ReadAttribute(0x011a)
    if ($xResProperty -eq $null) {
        $xRes = $null
    }
    Else {
        $xRes = [System.BitConverter]::ToUInt16($xResProperty.Value, 0)
    }

    # Height resolution
    $yResProperty = ReadAttribute(0x011b)
    if ($yResProperty -eq $null) {
        $yRes = $null
    }
    Else {
        $yRes = [System.BitConverter]::ToUInt16($yResProperty.Value, 0)
    }

    # Resolution unit
    $resUnitProperty = ReadAttribute(0x0128)
    if ($resUnitProperty -eq $null) {
        $resUnit = $null
    }
    Else {
        $resUnit = [System.BitConverter]::ToUInt16($resUnitProperty.Value, 0)
    }

    # Exposure time
    $exposureTimeProperty = ReadAttribute(0x829a)
    if ($exposureTimeProperty -eq $null) {
        $exposureTime = $null
    }
    Else {
        $exposureTime = ConvertToNumber($exposureTimeProperty)
    }

    # F-Number
    $fNumberProperty = ReadAttribute(0x829d)
    if ($fNumberProperty -eq $null) {
        $fNumber = $null
    }
    Else {
        $fNumber = ConvertToNumber($fNumberProperty)
    }

    # Exposure compensation
    $expCompProperty = ReadAttribute(0x9204)
    if ($expCompProperty -eq $null) {
        $expComp = $null
    }
    Else {
        $expComp = ConvertToNumber($expCompProperty)
    }

    # Metering mode
    $meteringProperty = ReadAttribute(0x9207)
    if ($meteringProperty -eq $null) {
        $metering = $null
    }
    Else {
        $metering = [System.BitConverter]::ToUInt16($meteringProperty.Value, 0)
    }

    # Flash mode
    $flashProperty = ReadAttribute(0x9209)
    if ($flashProperty -eq $null) {
        $flash = $null
    }
    Else {
        $flash = [System.BitConverter]::ToUInt16($flashProperty.Value, 0)
    }

    # Focal lenght
    $focalProperty = ReadAttribute(0x920a)
    if ($focalProperty -eq $null) {
        $focal = $null
    }
    Else {
        $focal = ConvertToNumber($focalProperty)
    }

    # Color space
    $colorProperty = ReadAttribute(0xa001)
    if ($colorProperty -eq $null) {
        $color = $null
    }
    Else {
        $color = [System.BitConverter]::ToUInt16($colorProperty.Value, 0)
    }

    # Width
    $xPixelProperty = ReadAttribute(0xa002)
    if ($xPixelProperty -eq $null) {
        $xPixel = $null
    }
    Else {
        $xPixel = [System.BitConverter]::ToUInt16($xPixelProperty.Value, 0)
    }

    # Height
    $yPixelProperty = ReadAttribute(0xa003)
    if ($yPixelProperty -eq $null) {
        $yPixel = $null
    }
    Else {
        $yPixel = [System.BitConverter]::ToUInt16($yPixelProperty.Value, 0)
    }

    # Source
    $sourceFileProperty = ReadAttribute(0xa300)
    if ($sourceFileProperty -eq $null) {
        $sourceFile = $null
    }
    Else {
        $sourceFile = $sourceFileProperty.Value
    }

    # Exposure Mode
    $expModeProperty = ReadAttribute(0xa402)
    if ($expModeProperty -eq $null) {
        $expMode = $null
    }
    Else {
        $expMode = [System.BitConverter]::ToUInt16($expModeProperty.Value, 0)
    }

    # White Balance
    $whiteBalanceProperty = ReadAttribute(0xa403)
    if ($whiteBalanceProperty -eq $null) {
        $whiteBalance = $null
    }
    Else {
        $whiteBalance = [System.BitConverter]::ToUInt16($whiteBalanceProperty.Value, 0)
    }

    # Gain control
    $gainCtrProperty = ReadAttribute(0xa407)
    if ($gainCtrProperty -eq $null) {
        $gainCtr = $null
    }
    Else {
        $gainCtr = [System.BitConverter]::ToUInt16($gainCtrProperty.Value, 0)
    }

    # Contrast
    $contrastProperty = ReadAttribute(0xa408)
    if ($contrastProperty -eq $null) {
        $contrast = $null
    }
    Else {
        $contrast = [System.BitConverter]::ToUInt16($contrastProperty.Value, 0)
    }

    # Saturation
    $saturationProperty = ReadAttribute(0xa409)
    if ($saturationProperty -eq $null) {
        $saturation = $null
    }
    Else {
        $saturation = [System.BitConverter]::ToUInt16($saturationProperty.Value, 0)
    }

    # Sharpness
    $sharpnessProperty = ReadAttribute(0xa40a)
    if ($sharpnessProperty -eq $null) {
        $sharpness = $null
    }
    Else {
        $sharpness = [System.BitConverter]::ToUInt16($sharpnessProperty.Value, 0)
    }

    # Subject distance mode
    $subjectDistProperty = ReadAttribute(0xa40c)
    if ($subjectDistProperty -eq $null) {
        $subjectDist = $null
    }
    Else {
        $subjectDist = [System.BitConverter]::ToUInt16($subjectDistProperty.Value, 0)
    }

    # Exposure program
    $ExpProgProperty = ReadAttribute(0x8822)
    if ($ExpProgProperty -eq $null) {
        $ExpProg = $null
    }
    Else {
        $ExpProg = [System.BitConverter]::ToUInt16($ExpProgProperty.Value, 0)
    }

    # Subject distance
    $SubjDistProperty = ReadAttribute(0x9206)
    if ($SubjDistProperty -eq $null) {
        $SubjDist = $null
    }
    Else {
        $SubjDist = [System.BitConverter]::ToUInt16($SubjDistProperty.Value, 0)
    }

    # Light source
    $LightSourceProperty = ReadAttribute(0x9208)
    if ($LightSourceProperty -eq $null) {
        $LightSource = $null
    }
    Else {
        $LightSource = [System.BitConverter]::ToUInt16($LightSourceProperty.Value, 0)
    }

    # Scene type
    $SceneTypeProperty = ReadAttribute(0xa407)
    if ($SceneTypeProperty -eq $null) {
        $SceneType = $null
    }
    Else {
        $SceneType = [System.BitConverter]::ToUInt16($SceneTypeProperty.Value, 0)
    }

    # Focal Lenght 35mm eq
    $Focal35Property = ReadAttribute(0xa405)
    if ($Focal35Property -eq $null) {
        $Focal35 = $null
    }
    Else {
        $Focal35 = [System.BitConverter]::ToUInt16($Focal35Property.Value, 0)
    }

    # Brightness
    $BrightnessProperty = ReadAttribute(0x9203)
    if ($BrightnessProperty -eq $null) {
        $Brightness = $null
    }
    Else {
        $Brightness = ConvertToNumber($BrightnessProperty)
    }

    # Lens maker
    $LensMakerProperty = ReadAttribute(0xa433)
    $LensMaker = ConvertToString($LensMakerProperty.Value)

    # Lens model
    $LensModelProperty = ReadAttribute(0xa434)
    $LensModel = ConvertToString($LensModelProperty.Value)

    # Dispose of the Image once we're done using it
    $photo.Dispose()

    # Display attibute
    $Return_Object.Pixel_X_Dimension = $xPixel
    $Return_Object.Pixel_Y_Dimension = $yPixel
    $Return_Object.X_Resolution = "$xRes dpi"
    $Return_Object.Y_Resolution = "$yRes dpi"
    #Switch ($resUnit){
    #    1 {"Resolution Unit = None"}
    #    2 {"Resolution Unit = Inches"}
    #    3 {"Resolution Unit = Centimeters"}
    #}

    Switch ($color) {
        1 { $Return_Object.Color_Space = "sRGB" }
        2 { $Return_Object.Color_Space = "Adobe RGB" }
        default { $Return_Object.Color_Space = "" }
    }

    $Return_Object.Data = $dateTaken
    $Return_Object.Title = $Title
    $Return_Object.Author = $Author

    Switch ($sourceFile) {
        1 { $Return_Object.File_Source = "Film Scanner" }
        2 { $Return_Object.File_Source = "Reflection print Scanner" }
        3 { $Return_Object.File_Source = "Digital Camera" }
        default { $Return_Object.File_Source = "" }
    }

    $Return_Object.Maker = $maker
    $Return_Object.Model = $model
    $Return_Object.Lens_Maker = $LensMaker
    $Return_Object.Lens_Model = $LensModel

    If ($fNumberProperty -eq $null) {
        $Return_Object.F_Number = ""
    }
    Else {
        $Return_Object.F_Number = "f/{0:N1}" -f $fNumber
    }

    If ($exposureTimeProperty -eq $null) {
        $Return_Object.Shutter_Speed = ""
    }
    Else {
        $Return_Object.Shutter_Speed = "$exposureTime Sec."
    }

    If ($iso -eq 0) {
        $Return_Object.ISO = ""
    }
    Else {
        $Return_Object.ISO = "ISO-$iso"
    }

    $Return_Object.Focal_Lenght = "{0:N0} mm" -f $focal
    $Return_Object.Focal_Lenght_35mm = $Focal35

    Switch ($subjectDist) {
        0 { $Return_Object.Subject_Distance_Range = "Unknown" }
        1 { $Return_Object.Subject_Distance_Range = "Macro" }
        2 { $Return_Object.Subject_Distance_Range = "Close" }
        3 { $Return_Object.Subject_Distance_Range = "Distant" }
        default { $Return_Object.Subject_Distance_Range = "" }
    }

    $Return_Object.Subject_Distance = $SubjDist

    $hexflash = "{0:X0}" -f $flash
    switch ($hexflash) {
        0 { $Return_Object.Flash = "No Flash" }
        1 { $Return_Object.Flash = "Fired" }
        5 { $Return_Object.Flash = "Fired, Return not detected" }
        7 { $Return_Object.Flash = "Fired, Return detected" }
        8 { $Return_Object.Flash = "On, Did not fire" }
        9 { $Return_Object.Flash = "On, Fired" }
        D { $Return_Object.Flash = "On, Return not detected" }
        F { $Return_Object.Flash = "On, Return detected" }
        10 { $Return_Object.Flash = "Off, Did not fire" }
        14 { $Return_Object.Flash = "Off, Did not fire, Return not detected" }
        18 { $Return_Object.Flash = "Auto, Did not fire" }
        19 { $Return_Object.Flash = "Auto, Fired" }
        1D { $Return_Object.Flash = "Auto, Fired, Return not detected" }
        1F { $Return_Object.Flash = "Auto, Fired, Return detected" }
        20 { $Return_Object.Flash = "No flash function" }
        30 { $Return_Object.Flash = "Off, No flash function" }
        41 { $Return_Object.Flash = "Fired, Red-eye reduction" }
        45 { $Return_Object.Flash = "Fired, Red-eye reduction, Return not detected" }
        47 { $Return_Object.Flash = "Fired, Red-eye reduction, Return detected" }
        49 { $Return_Object.Flash = "On, Red-eye reduction" }
        4D { $Return_Object.Flash = "On, Red-eye reduction, Return not detected" }
        4F { $Return_Object.Flash = "On, Red-eye reduction, Return detected" }
        50 { $Return_Object.Flash = "Off, Red-eye reduction" }
        58 { $Return_Object.Flash = "Auto, Did not fire, Red-eye reduction" }
        59 { $Return_Object.Flash = "Auto, Fired, Red-eye reduction" }
        5D { $Return_Object.Flash = "Auto, Fired, Red-eye reduction, Return not detected" }
        5F { $Return_Object.Flash = "Auto, Fired, Red-eye reduction, Return detected" }
        default { $Return_Object.Flash = "" }
    }

    Switch ($orientation) {
        1 { $Return_Object.Orientation = "Horizontal" }
        2 { $Return_Object.Orientation = "Mirror Horizontal" }
        3 { $Return_Object.Orientation = "Rotate 180°" }
        4 { $Return_Object.Orientation = "Mirror Vertical" }
        5 { $Return_Object.Orientation = "Mirror Horizontal & Rotate 180°" }
        6 { $Return_Object.Orientation = "Rotate 90°clockwise" }
        7 { $Return_Object.Orientation = "Mirror Horizontal & Rotate 90°clockwise" }
        8 { $Return_Object.Orientation = "Rotate 270°clockwise" }
        default { $Return_Object.Orientation = "" }
    }

    Switch ($contrast) {
        0 { $Return_Object.Contrast = "Normal" }
        1 { $Return_Object.Contrast = "Low" }
        2 { $Return_Object.Contrast = "High" }
        default { $Return_Object.Contrast = "" }
    }

    Switch ($saturation) {
        0 { $Return_Object.Saturation = "Normal" }
        1 { $Return_Object.Saturation = "Low" }
        2 { $Return_Object.Saturation = "High" }
        default { $Return_Object.Saturation = "" }
    }

    Switch ($sharpness) {
        0 { $Return_Object.Sharpness = "Normal" }
        1 { $Return_Object.Sharpness = "Soft" }
        2 { $Return_Object.Sharpness = "Hard" }
        default { $Return_Object.Sharpness = "" }
    }

    $Return_Object.Brightness = $Brightness

    Switch ($whiteBalance) {
        0 { $Return_Object.White_Balance = "Auto" }
        1 { $Return_Object.White_Balance = "Manual" }
        default { $Return_Object.White_Balance = "" }
    }

    Switch ($metering) {
        0 { $Return_Object.Metering_Mode = "Unknow" }
        1 { $Return_Object.Metering_Mode = "Avarage" }
        2 { $Return_Object.Metering_Mode = "Center-weighted Avarage" }
        3 { $Return_Object.Metering_Mode = "Spot" }
        4 { $Return_Object.Metering_Mode = "Multi-spot" }
        5 { $Return_Object.Metering_Mode = "Multi-segment" }
        6 { $Return_Object.Metering_Mode = "Partial" }
        255 { $Return_Object.Metering_Mode = "Other" }
        defaul { $Return_Object.Metering_Mode = "" }
    }

    Switch ($expMode) {
        0 { $Return_Object.Exposure_Mode = "Auto" }
        1 { $Return_Object.Exposure_Mode = "Manual" }
        2 { $Return_Object.Exposure_Mode = "Auto Bracket" }
        default { $Return_Object.Exposure_Mode = "" }
    }

    Switch ($ExpProg) {
        1 { $Return_Object.Exposure_Program = "Manual" }
        2 { $Return_Object.Exposure_Program = "Program AE" }
        3 { $Return_Object.Exposure_Program = "Aperture-priority AE" }
        4 { $Return_Object.Exposure_Program = "Shutter-priority AE" }
        5 { $Return_Object.Exposure_Program = "Creative" }
        6 { $Return_Object.Exposure_Program = "Action" }
        7 { $Return_Object.Exposure_Program = "Portrait" }
        8 { $Return_Object.Exposure_Program = "Landscape" }
        9 { $Return_Object.Exposure_Program = "Bulb" }
        default { $Return_Object.Exposure_Program = "" }
    }

    $Return_Object.Exposure_Bias =  "{0:N0}-step" -f $expComp

    Switch ($SceneType) {
        0 { $Return_Object.Scene_Type = "Standard" }
        1 { $Return_Object.Scene_Type = "Landscape" }
        2 { $Return_Object.Scene_Type = "Portrait" }
        3 { $Return_Object.Scene_Type = "Night" }
        default { $Return_Object.Scene_Type = "" }
    }

    Switch ($gainCtr) {
        0 { $Return_Object.Gain_Control = "None" }
        1 { $Return_Object.Gain_Control = "Low gain up" }
        2 { $Return_Object.Gain_Control = "Hight gain up" }
        3 { $Return_Object.Gain_Control = "low gain down" }
        4 { $Return_Object.Gain_Control = "Hight gain down" }
        default { $Return_Object.Gain_Control = "" }
    }

    Switch ($LightSource) {
        1 { $Return_Object.Light_Source = "Daylight" }
        2 { $Return_Object.Light_Source = "Fluorescent" }
        3 { $Return_Object.Light_Source = "Tungsten" }
        4 { $Return_Object.Light_Source = "Flash" }
        9 { $Return_Object.Light_Source = "Fine Weather" }
        10 { $Return_Object.Light_Source = "Cloudy" }
        11 { $Return_Object.Light_Source = "Shade" }
        12 { $Return_Object.Light_Source = "Daylight Fluorescent" }
        13 { $Return_Object.Light_Source = "Day White Fluorescent" }
        14 { $Return_Object.Light_Source = "Cool White Fluorescent" }
        15 { $Return_Object.Light_Source = "White Fluorescent" }
        16 { $Return_Object.Light_Source = "Warm White Fluorescent" }
        255 { $Return_Object.Light_Source = "Other" }
        default { $Return_Object.Light_Source = "" }
    }
    Return $Return_Object
}
