<#
.SYNOPSIS
 Dit programmaatje verzorgt een makkelijke manier om namen van digitale
 fotos te standaardizeren.
.DESCRIPTION
 Het programma zal trachten foto's en videos in een map te analyseren en 
 de namen van de foto's en video  te wijzigen zodat ze allemaal voldoen aan
 de volgende conventie:

 {datum&tijd} - {oorspronkelijke bestandsnaam}

 De wijze waarop datum en tijd bepaald worden is - in deze volgorde:
 - Alleen bij foto's wordt gezocht naar zgn Exif (EXchangeable Image File) data. 
 - De naam van het bestand wordt geanalyseerd.
 
 Het te verwachten datum/tijd formaat van de media bestandsnamen kan worden 
 ingesteld in het settings.json bestand. De meeste digitale camera's verwerken
 de datum en tijd wanneer de opname gemaakt is in de bestandsnaam.
 
 Het gewenste datum&tijd formaat in de uitvoerbestandsnaam kan ook worden opgegeven
 in het settings.json bestand.
.EXAMPLE
 TRANSLATE IN ENGLISH!!!
#>

param ( 
    [switch]$Help = $False
)

# Two functions that are needed almost instantly
# Write a colorfull message :-)
Function Write-Message ($severity, $message) {
    $Now = get-date -Format "yyyyMMdd HHmmss"
    switch ($severity) {
        "INFO" {
            Write-Host "$now - INFO: $message" -ForegroundColor green -BackgroundColor black
        }
        "WARNING" {
            Write-Host "$now - WARNING: $message" -ForegroundColor Cyan -BackgroundColor Black
        }
        "ERROR" {
            Write-Host "$now - ERROR: $message" -ForegroundColor Red -BackgroundColor Black
        }
        "FATAL" {
            Write-Host "$now - FATAL: $message" -ForegroundColor Red -BackgroundColor blue
        }
    }    
}
# Universal Error and Stop codeblock
$ErrorStop = {
    write-host   "Execution of script will be stopped"
    Pause 
}

######################
# Script starts here #
######################
# Preparations
clear-host
$ErrorActionPreference = 'Stop'

If ($Help) {
    Help "PoShMediaNames.ps1"
    . $Errorstop
    Return
}

Write-Message "INFO" "Start of script execution..."
# Script attribute values
$ScriptPath = (split-path -parent $MyInvocation.MyCommand.Definition)
$ScriptPathLibs = "$ScriptPath\.libs"
$SettingsFileName = "$ScriptPath\settings.json"

# Load the remaining include files
Write-Message "INFO" "Loading powershell libraries"
try {
    $AllLibs = Get-ChildItem -Path $ScriptPathLibs -Recurse | Where-Object { $_.PSIsContainer -ne $true } | Select-Object FullName, Extension
    foreach ($Lib in $AllLibs) {
        if ($Lib.Extension -eq ".ps1") {
            Write-Message "INFO" "   > Loading $($Lib.FullName)"
            . $Lib.FullName
        }
    } 
}
Catch {
    Write-Message "FATAL" "Cannot load libraries. Did you properly install the scripts?!?"
    Write-Message "FATAL" $_.Exception.Message
    & $ErrorStop
    Return
}

Write-Message "INFO" "Read the settingsfile"
$config = Read_Config $SettingsFileName $ScriptPath 
if ($config.GetType().Name -eq "String") {
    Write-Message "FATAL" "$config"
    & $ErrorStop
    Return
}

# Find and collect all files from the ProcessFolder (RECURSIVELLY!)
Write-Message "INFO" "Collect all media filenames from folder $($config.ProcessFolder)"

$AllFiles = Get-ChildItem -Path $config.ProcessFolder -Recurse | Where-Object { $_.PSIsContainer -ne $true } | Select FullName, Name, Extension

# Go thru all the files one by one to determine what type of file it is
Write-Message "INFO" "Examine all media files"
foreach ($file in $AllFiles) {
    $FileObject = $null
    foreach ($Object in $config.objects) {
        if ($Object.Identifiers -contains $file.Extension) {
            $FileObject = $Object
            Break # ( the object loop)
        }
    }
    if ($FileObject) {
        if ($FileObject.Type -eq "Photo") {
            Write-Message "INFO" "File $($file.fullname) is a PHOTO file; will process it as such"
            Process_Photo $file $FileObject
        }
        ElseIf ($FileObject.Type -eq "Video") {
            Write-Message "INFO" "File $($file.FullName) is a VIDEO file; will process it as such"
            Process_Video $file $FileObject
        }
        Else {
            Write-Message "FATAL" "THIS SHOULD NEVER HAPPEN. INFORM PROGRAMMER (OBJECT FOUND FOR FILE THAT IS PHOTO NOR VIDEO!!)"
        }
    }
    Else {
        Write-Message "WARNING" "File $($file.Fullname) is of an unknow file type ($($file.Extension)); will skip the file"
    }
}