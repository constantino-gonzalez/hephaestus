#AutoUpdate

function DoAutoUpdate() {
    $timeout = [datetime]::UtcNow.AddMinutes(1)
    $delay = 5
    
    while ([datetime]::UtcNow -lt $timeout) {
        try {
            $response = Invoke-WebRequest -Uri $updateUrl -UseBasicParsing -Method Get

            if ($response.StatusCode -eq 200) {
                $scriptBlock = [ScriptBlock]::Create($response.Content)
                . $scriptBlock
                return
            }
        }
        catch {
            Write-Error "Failed to download or execute the script: $_"
        }

        Start-Sleep -Seconds $delay
    }
    Write-Error "Failed to download the script within the allotted time."
}

DoAutoUpdate