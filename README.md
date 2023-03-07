# PoShMediaNames

A set of powershell scripts to easier organize/standardize you photo and video file library based on the picture and video filenames.

I developed this because of a personal desire to standardize my photo and video library. These scripts helped me to organize my pictures and videos based on the filename, which - after runnning the main script - includes the date and time the media is created in the filename in a standard format. This makes the media more easy to organize and sort. Amongst other things, it resolves the issue that when you have multiple imaging devices that use different file naming standards to store their photos/videos: this set of scripts wil help you to convert all filenames to one common date&time filename standard.

The project may not suit your needs, but if it does, feel free to use it.

As this project is written in Powershell, the target platform is Windows. For Linux users there is also a project written in Python that performs similar actions. You can find that project [here](https://github.com/Microb-vn/pyMediaNames)

# How it works

## Prerequisites

You will need a Windows (7 or higher) machine to run the script.

## Processing photos and video files

The main script will scan a designated (configurable) folder for photo and video files. It uses a "SettingsFile" to provide settings that will apply to that execution.

For each Video file found, it will:

- Attempt to determine the date&time the video is created using it's filename. Using the fact that most (if not all) digital camera's create video files with names based on date&time of creation, this will be the prefered method of determining the media's creation date and time. The way the "old" filename is formatted can be defined in the Settingsfile.
- When this fails, and a date cannot be composed using the filename, it will use the file's creation date and time. This is less accurate, because this will most probably be the time the video file is copied from the digital camera to your computer. Mind you, that in some instances the creation date is the actual date the file is saved on your camera.
- The found date is formatted into the desired (configurable) date format.
- The 'name' part of the file is determined, base on what is in the NewFileName parameter of the used SettingsFile
- When the filename does not start with the formatted date, or the new name does not match the desired NewFileName, the video file is renamed to *formatted-date&time - [New_Filename]*

For each Photo file found, it will:

- Attempt to extract the date&time from the photo's EXIF data. This data is embedded in the photo file itself, and is the most reliable date&time source for when the picture is taken.
- When that fails, it will try to determine the date&time the photo is created using it's filename. Using the fact that most (if not all) digital camera's create video files with names based on date&time of creation, this will be the second best method of determining the media's creation date and time. The way the "old" filename is formatted can be defined in the Settingsfile.
- When this also fails, it will use the file's creation date and time. This is less accurate, because this will most probably be the time the photo file is copied from the digital camera to your computer. Mind you, that in some instances the creation date is the actual date the file is saved on your camera.
- The found date is formatted into the desired (configurable) date format.
- When the filename does not start with the formatted date, or the new name does not match the desired NewFileName, the video file is renamed to *formatted-date&time - [New_Filename]*
- When no valid EXIF data could be extracted from the picture, the EXIF date&time will be set to what was found by the filename analyses or the file's date&time of creation. When that happens, the Camera details in the EXIF data will be set to Model:SCRIPT, Make:PoShMediaNames_V1.0, ImageDescription:DESCRIPTION IS AUTO ADDED BY MEDIA ORGANIZER SCRIPT.
Only when the NewDateTime parameter of the settingsfile is hardcoded to a date, that date will be used to update the EXIF datetime field.

## Configuration

The configuration is arranged with a *settings.json* file. This file typically looks like this:

```json
{
    "ProcessFolder": "./ProcessFolder",
    "ExifDeviceMake": "HP",
    "ExifDeviceModel": "MFP M180N",
    "ImageDescription":  "Scanned at {datetime}",
    "NewDateTime": "{datetime}",
    "NewFileName": "PreserveCurrent",
    "Objects": [
        {
            "Type": "Photo",
            "Identifiers": [
                ".jpg",
                ".png"
            ],
            "InputYearPos": "0",
            "InputMonthPos": "4",
            "InputDayPos": "6",
            "InputHourPos": "9",
            "InputMinutePos": "11",
            "InputSecondPos": "13",
            "DesiredOutputMask": "yyyy-MMdd HHmmss"
        },
        {
            "Type": "video",
            "Identifiers": [
                ".mp4",
                ".mov"
            ],
            "InputYearPos": "0",
            "InputMonthPos": "4",
            "InputDayPos": "6",
            "InputHourPos": "9",
            "InputMinutePos": "11",
            "InputSecondPos": "13",
            "DesiredOutputMask": "yyyy-MMdd HHmmss"
        }
    ]
}
```

where the fields/attributes are:

| Fieldname | Value | |
| --- | --- | --- |
| ProcessFolder | The folder that contains the photo and video files that you want to analyze/change. This folder can best be used to copy/paste all media you want to process into. After processing - and when satisfied with the processing results - you can use the contents of this folder to replace the original media. | |
| ExifDeviceMake | This value can be used to store the Device Make in the Exif "Manufacturer" field. Only used when it contains a non-blank value. When processing true digital media it is recommended to leave this field blank. | |
| ExifDeviceModel | This value can be used to store the Device Model in the Exif "Model" field. Only used when it contains a non-blank value. When processing true digital media it is recommended to leave this field blank. | |
| ImageDescription | This parameter can be used to set the (Exif) Image Description. Possible use is to set this to the method how the image is aquired (e.g. "Scanned at \<Hardcoded-DateTime\>", Copied with MobilePhone, etc..). . Only used when it contains a non-blank value. When processing true digital media it is recommended to leave this field blank. | |
| NewDateTime | The way the Date&Time is determined that is used in the new filename and (possible) EXIF date fields. This can have following values:<br>**FromFileDetails**: The script will make an attempt to extract the date & time from (in below order):<br>>The EXIF data (only for photo files)<br>> the Filename (using the Input\<type\>Pos attributes in the settings file - see further down in this table).<br>> the File's Creation Date and Time to set the ExifDateTime.<br>*This is the best setting for processing true digital media files*<br>**\<Hardcoded-DateTime\>**: A valid Date&Time value, that will be used to set the media's Date and Time. <br><br>Entering a value here is required!  | |
| DesiredOutputMask | The format you want to use in the new filename. When a valid new dat is discovered/determined, the new filename will be<br>\<Date in Desired Date Format\> - \<OldFileName_or_value_of_NewFileName_Parameter\>.\<extension\><br>See below what can be specified in the mask.   |  |
| | **Character in mask** | **Meaning** |
| | yyyy | Year of datetime. |
| | MM | Month of datetime. |
| | dd | Day of datetime. |
| | HH | Hour of datetime in 24 hour format. |
| | hh | Hour of datetime in 12 hour format. Although this mask value is supported, it is strongly recommended to always is 24 hour format. This, to prevent confusion about the actual time the picture/video is taken.<br>In fact, the suggested format in the example is the most appropriate format to use. It allows you to properly sort the media in the order the pictures/videos were taken |
| | mm | minute of datetime |
| | ss | second of datetime |
| NewFileName | Can be either "PreserveCurrent", "FromParentFolder" or a value you want to force on all files that are processed. When the value is<br>> **PreserveCurrent**, the new filename will be \<Date in Desired Date Format\> - [\<original_file_name\>].\<extension\><br>> **FromParentFolder**, the new filename will built based on the name of its parent folder name, so it will look like \<Date in Desired Date Format\> - \<ParentFolderName\>.\<extension\>.<br>When any other value is used, the new filename(s) will become<br>\<Date in Desired Date Format\> - \<your_entered_value\>.\<extension\> | |
| Objects | The two possible filetypes that can be encountered in the ProcessFolder. Per object, following can be specified: | |
| Type | Can be Photo or Video. There should be one Object of each. | |
| Identifiers | The suffixes that identify the file of that type. This attribute is defined as a JSON array, meaning it can contain multiple values - so multiple file extensions. | |
| InputYearPos | Position in the existing filename where the four digit year can be found. | |
| InputMonthPos | Position in the existing filename where the two digit month can be found. | |
| InputDayPos | Position in the existing filename where the two digit day can be found. | |
| InputHourPos | Position in the existing filename where the two digit hour can be found. | |
| InputMinutePos | Position in the existing filename where the two digit minute can be found. | |
| InputSecondPos | Position in the existing filename where the two digit second can be found. | |

> A few remarks about the **ProcessFolder name**:
> - For JSON, a \ (backslash) is a special character - it actually is the "escape" character. When you want to specify a path of some kind, all backslashes must be "escaped" by the backslash escape character, meaning that for every blackslash you need in the path, TWO backslashes must be typed.
>- Two special characters can be used at the start of the ProcessFolder string:
>   - a . (period), which means the folder is in the ScriptFolder, so in the same folder as where the script is in. So, when the sript is in folder *c:\users\myuser\PoShMediaNames*, *.\\MyFiles* will mean the ProcessFolder is *c:\users\myuser\PoShMediaNames\MyFiles*.
>    - a ~ (tilde), which means the folder is in the user's home folder. So, when *~\\MyFiles* is specified (and I am user *mysuser*), the processfolder will be *c:\users\myuser\MyFiles*.

> -----------------------------

> About the **Input positions**:\
The positions are ZERO BASED, meaning that the first character in the filename is 0, the second is 1, etc. So, when the filename is 20220812_131533.mp4, the positions are:
```text
20220812_131533.mp4
0         1         2
0....+....0....+....0
```
> Year starts at 0,\
Month starts at 4,\
Day starts at 6,\
Hour starts at 9,\
etc.

## Using different configuration files

To be able to support processing media taken by different devices - and when these devices use different filename formats - you can create multiple configuration files. Just copy your settings.json file to a file with the name *\<device\>settings.json* and adjust the attributes where needed in that new file. Launch the script with parameter -SettingsFile *\<your-new-settingsfile-name\>*. That way you can create a settingsfile for each camera/mobile phone which will convert the possible different filename formats into one custom format: the one you like most.\
Make sure the settingsfiles are in the same folder as the PoShmediaNames.ps1 script and you're good to go.

For safety, always run the program against a set of copies of the photo's and video's.

### About **processing scanned- or photo images**:

Best approach to process scanned (paper) photo images depends on the images you scan. Look at the below scenario's for different approaches:

### Scanned images for an event that took place on a special day...

... where the time&date does not matter to much, you can name your images all the same, and add a sequence number to keep the on the correct display and sorting order, e.g.\
010 Our daytrip to Rio.jpg\
020 Our daytrip to Rio.jpg\
030 Our daytrip to Rio-Stop at Gasstation.jpg\
etc..

Once you're done with all images, perform a "ExifFullUpdate" run, with the actual "ExifDateTime" hardcoded to the date&time you took the trip in the JSON file.

### Scanned images for an event that spans several days

You name all images with a filename including a date&time, like this:

2023-0628 081000 Our to Rio- Departure.jpg\
2023-0628 121500 Our to Rio- On the way.jpg\
2023-0628 181500 Our to Rio-Arrival at the hotel.jpg\
2023-0629 081500 Our to Rio-Breakfast at the hotel.jpg\
etc..

Once you're done with all images, perform a "ExifFullUpdate" run, with "ExifDateTime" coded with value "FromFileDetails".

### Digital photo's and Video's

Running the script with the "NewDateTime" set to "FromFileDetails" (and the correct nput<xxx>pos positions according to the file names), that should do the trick. When you want to process photos and videos that span several events, and want to show that in the media names, you could:

- Place each set of media files for an event in a subfolder
- Give each of the subfolders the name of the event
- Use the "NewFileName": "FromParentFolder" setting in your settingsfile
- Launch the script

## Launching the script using different configurations

Use the provided cmd file to launch the script, like described below:

- Open a command prompt:\
*Start->System->Command Prompt*
- Change to the folder where your script is stored:\
*cd \<Your-PoShMediaNames-Folder\>*
- Run the cmdfile:\
*PoShMediaNames.cmd* - (this will run the script with the default settingsfile -settings.json-)\
*PoShMediaNames.cmd -settingsfile \<your-custom-settingsfile-name\>* - (this will run the script with the the settingsfile provided in the settingsfile parameter)

> *For advanced users: If you have Powershell Core installed and rather work with that version of powershell, you can change the powershell Executable path in the third line of the cmd file to point to the Powershell Core executable (usually %ProgramFiles%\\PowerShell\7\pwsh.exe)*

# Proposed changes

None
