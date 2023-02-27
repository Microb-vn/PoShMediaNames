# PoShMediaNames

A set of powershell scripts to easier organize/standardize you photo and video file library based on the picture and video filenames.

I developed this because of a personal desire to standardize my photo and video library. This script helped me to organize my pictures and videos based on the filename, which - after runnning this script - includes the date and time the media is created in a standard format. This makes the media more easy to organize and sort, even if you have multiple imaging devices that use different file naming standards to store their photos/videos.

The project may not suit your needs, but if it does, feel free to use it.

As this project is written in Powershell, the target platform is Windows. For Linux users there is also a project that perform similar actions written in Python. You can find that project [here](https://github.com/Microb-vn/pyMediaNames)

# How it works

## Processing photos and video files

The main script will scan a designated (configurable) folder for photo and video files.

For each Video file found, it will:

- Attempt to determine the date&time the video is created using it's filename. Using the fact that most (if not all) digital camera's create video files with names based on date&time of creation, this will be the prefered method of determining the media's creation date and time.
- When this fails, and a date cannot be composed using the filename, it will use the file's creation date and time. This is less accurate, because this will most probably be the time the video file is copied from the digital camera to your computer. Mind you, that in some instances the creation date is the actual date the file is saved on your camera.
- The found date is formatted into the desired (configurable) date format.
- The formatted date is compared to the filename. When the filename already starts with the formatted date, no action is taken to change the filename.
- When the filename does not start with the formatted date, the video file is renamed to *formatted-date&time - [old-filename]*

For each Photo file found, it will:

- Attempt to extract the date&time from the photo's EXIF data. This data is embedded in the photo file itself, and is the most reliable date&time source for when the picture is taken.
- When that fails, it will try to determine the date&time the photo is created using it's filename. Using the fact that most (if not all) digital camera's create video files with names based on date&time of creation, this will be the second best method of determining the media's creation date and time.
- When this also fails, it will use the file's creation date and time. This is less accurate, because this will most probably be the time the photo file is copied from the digital camera to your computer. Mind you, that in some instances the creation date is the actual date the file is saved on your camera.
- The found date is formatted into the desired (configurable) date format.
- The formatted date is compared to the filename. When the filename already starts with the formatted date, no action is taken to change the filename.
- When the filename does not start with the formatted date, the photo file is renamed to *formatted-date&time - [old-filename]*
- Also, when no valid EXIF data could be extracted from the picture, the EXIF date&time will be set as well. The Camera details in the EXIF data will be set to "ADDED BY SCRIPT" and "UNKNOW"

## Configuration

The configuration is arranged with a *settings.json* file. This file typically looks like this:

```json
{
    "Mode": "Standard",
    "ProcessFolder": ".\\ProcessFolder",
    "ExifDeviceMake": "HP",
    "ExifDeviceModel": "MFP M180N",
    "ExifDateTime": "{datetime}",
    "FileTitle": "ScannedImage",
    "FileComment": "Scanned at {datetime}",
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

| Fieldname | Value |
| --- | --- |
| Mode | Processing Mode. This can be one of following values:<br>**Standard:** The media files are analyzed, data is taken from the file and/or Exif details and the filenames are updated<br>**ExifFullUpdate:** The media files are analyzed, and only Photos are processed differently (Video's will be treated according the 'Standard' method). Photo data is taken from the settingsfile (see next settings attributes), and the Exif data is updated with that information. Usefull for updating photo images that are scanned or copied using a scanner/camera.<br>*Note: Whichever method is used, the script will always attempt to keep the desired filename date and the Exif Date the same!* | 
| ExifDeviceMake | When mode is ExifFullUpdate, this value can be used to store the Device Make in the Exif "Manufacturer" field. Only used when it contains a non-blank value |
| ExifDeviceModel | When mode is ExifFullUpdate, this value can be used to store the Device Model in the Exif "Model" field. Only used when it contains a non-blank value |
| ExifDateTime | When mode is ExifFullUpdate, this can have following values:<br>**FromFileDetails**: The script will make an attempt to extract the date & time from either the Filename (using the Input\<type\>Pos attributes in the settings file. When that fails, it will use the File's Creation Date and Time to set the ExifDateTime.<br>**\<Hardcoded-DateTime\>**: A valid Date&Time value, that will be used to set the ExifDateTime. Entering a value here is required!  |
| ExifTitle | When mode is ExifFullUpdate, can be used to set the Title. Possible use is to set this to the method how the image is aquired (e.g. "Scanned at \<Hardcoded-DateTime\>", Copied with MobilePhone, etc..). . Only used when it contains a non-blank value |
| ProcessFolder | The folder that contains the photo and video files that you want to analyze/change. This folder can best be used to copy/paste all media you want to process into. After processing - and when satisfied with the processing results - you can use the contents of this folder to replace the original media. |
| Objects | The two possible filetypes that can be encountered in the ProcessFolder. Per object, following can be specified: |
| Type | Can be Photo or Video. There should be one Object of each. |
| Identifiers | The suffixes that identify the file of that type. This attribute is defined as a JSON array, meaning it can contain multiple values - so multiple file extensions. |
| InputYearPos | Position in the existing filename where the four digit year can be found. |
| InputMonthPos | Position in the existing filename where the two digit month can be found. |
| InputDayPos | Position in the existing filename where the two digit day can be found. |
| InputHourPos | Position in the existing filename where the two digit hour can be found. |
| InputMinutePos | Position in the existing filename where the two digit minute can be found. |
| InputSecondPos | Position in the existing filename where the two digit second can be found. |
| DesiredOutputMask | The format you want to use in the new filename. When a valid new dat is discovered/determined, the new filename will be<br>*Formatted_Date - [original_file_name]*<br>See below what can be specified in the mask.   |
| **Character in mask** | **Meaning** |
| yyyy | Year of datetime. |
| MM | Month of datetime. |
| dd | Day of datetime. |
| HH | Hour of datetime in 24 hour format. |
| hh | Hour of datetime in 12 hour format. Although this mask value is supported, it is strongly recommended to always is 24 hour format. This, to prevent confusion about the actual time the picture/video is taken.<br>In fact, the suggested format in the example is the most appropriate format to use. It allows you to properly sort the media in the order the pictures/videos were taken |
| mm | minute of datetime |
| ss | second of datetime |

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

To be able to support processing media taken by different devices - and when these devices use different filename formats - you can create multiple configuration files. Just copy your settings.json file to a file with the name *\<device\>settings.json* and adjust the attributes where needed in that new file. Launch the script with parameter -SettingsFile *\<your-new-settingsfile-name\>*. Make sure the settingsfiles are in the same folder as the PoShmediaNames.ps1 script and you're good to go.

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

Just run a "Standard" run, that should do the trick.

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
