param (
    [string]$serverName,
    [string]$usePath,
    [string]$scriptPath,
    [string]$ipAddress,
    [string]$tempFile
)

# Run the provided script path with the given parameters
& $scriptPath -serverName $serverName -usePath $usePath -ipAddress $ipAddress | Out-File -FilePath $tempFile

# Signal completion
"Completed" | Out-File -FilePath "$tempFile.complete"