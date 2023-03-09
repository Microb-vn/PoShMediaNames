<#
.SYNOPSIS
 This script provides you with an easy method to standarize your Photo and Video
 filenames.
.DESCRIPTION
 The script will make an attempt to analyze photo and video files in a given
 folder, and update the names of these files to include a standardized date and
 time stamp. After running the script, all will ideally will look like:

 {formatted_date&time} - {original_or_desired_new_filename}

 The way the date and time is determined is:
 - For Photo file, the EXIF (EXchangeable Image File) data will be used
 - When no EXIF date can be detected (so, also for Video files) the filename
   is analyzed
 - When that fails, the file creation data is used
 
 The date and time format that can be expected in the media files can be configured
 in a json configuration file (default file is settings.json). Most digital camera's
 create filename that include this information in a specific format.

 The desired new date format, and a preference for composing a new filename, can also 
 be specified in the settingsfile
.EXAMPLE
 See markdown document that is included in this project.
#>

param ( 
    [switch]$Help = $False,
    [String]$SettingsFile="settings.json"
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
$SettingsFileName = "$ScriptPath\$SettingsFile"

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

Write-Message "INFO" "Read the settingsfile $SettingsFileName"
$config = Read_Config $SettingsFileName $ScriptPath 
if ($config.GetType().Name -eq "String") {
    Write-Message "FATAL" "$config"
    & $ErrorStop
    Return
}

# Find and collect all files from the ProcessFolder (RECURSIVELLY!)
Write-Message "INFO" "Collect all media filenames from folder $($config.ProcessFolder)"

$AllFiles = Get-ChildItem -Path $config.ProcessFolder -Recurse | Where-Object { $_.PSIsContainer -ne $true } | Select-Object FullName, Name, Extension, Directory

# Go thru all the files one by one to determine what type of file it is
Write-Message "INFO" "Examine all media files"
foreach ($file in $AllFiles) {
    $FileObject = $null
    Write-Message "INFO" "------------------------------------------------"
    foreach ($Object in $config.objects) {
        if ($Object.Identifiers -contains $file.Extension) {
            $FileObject = $Object
            Break # ( the object loop)
        }
    }
    if ($FileObject) {
        if ($FileObject.Type -eq "Photo") {
            Write-Message "INFO" "File $($file.fullname) is a PHOTO file; will process it as such"
            Process_Photo $file $FileObject $config
        }
        Else {
            Write-Message "INFO" "File $($file.FullName) is a VIDEO file; will process it as such"
            Process_Video $file $FileObject $config
        }
    }
    Else {
        Write-Message "WARNING" "File $($file.Fullname) is of an unknow file type ($($file.Extension)); will skip the file"
    }
}
Write-Message "INFO" "------------------------------------------------"
Write-Message "INFO" "Done..."