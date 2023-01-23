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
#>

param ( 
    [switch]$Help = $False
)

# Preparations
######################
# Script begint hier #
######################
clear-host
$ErrorActionPreference = 'Stop'

If ($Help) {
    Get-Help ".\.Progs\Verbindmappen.ps1"
    & $ErrorStop
    Return
}

# Script omgevings waarden
$ScriptPath = (split-path -parent $MyInvocation.MyCommand.Definition)
$ScriptPathroot = $ScriptPath.replace("\.Progs", "")
$AccountBestandnaamTemplate = "{0}\.Cache\AccountInfo.##HOSTNAME##.$MappenBestand" -f $ScriptPathroot
$VerbindMappenBestandNaam = "{0}\VerbindMappen.$MappenBestand.csv" -f $ScriptPathroot

# Vraag af wat er ingevoerd is
if ("$MappenBestand" -eq "") {
    "Parameter -Mappenbestand heeft geen waarde toegewezen gekregen." | Out-Host
    & $ErrorStop
    Return
}
