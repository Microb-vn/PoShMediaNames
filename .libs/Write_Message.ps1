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
