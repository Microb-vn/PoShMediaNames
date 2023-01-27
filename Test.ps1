$ErrorActionPreference = "Stop"
. .\.libs\Update_ExifData.ps1

$FileName = "Z:\Documenten\GitHub\PoShMediaNames\ProcessFolder\Gescand document.jpg"


$NewObsjFields = "PropertyNr", "PropertyValue"
$ExifObjects = @()

$NewObj = "" | Select-Object $NewObsjFields
$NewObj.PropertyNr=271
$NewObj.PropertyValue="MyOwn"
$ExifObjects += $NewObj

$NewObj = "" | Select-Object $NewObsjFields
$NewObj.PropertyNr=36868
$NewObj.PropertyValue="2023:01:01 12:13:14"
$ExifObjects += $NewObj

Update_ExifData $Filename $ExifObjects