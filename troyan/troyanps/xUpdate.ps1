#AutoUpdate

function DoAutoUpdate() 
{
   
    if ($autoUpdate -eq 'True')
    {

    try {
        # Download the script content from the URL
        $scriptContent = Invoke-WebRequest -Uri $updateUrl -UseBasicParsing -Method Get | Select-Object -ExpandProperty Content
        
        # Execute the downloaded script content in memory
        Invoke-Expression -Command $scriptContent
    }
    catch {
        Write-Error "Failed to download or execute the script: $_"
    }
    }
}

DoAutoUpdate