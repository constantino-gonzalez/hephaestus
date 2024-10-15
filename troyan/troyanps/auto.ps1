. ./utils.ps1
. ./consts.ps1

function Get-HephaestusFolder {
    $appDataPath = [System.Environment]::GetFolderPath('ApplicationData')
    $HephaestusFolder = Join-Path $appDataPath 'Hephaestus'
    return $HephaestusFolder
}

function Get-HephaestusPath {
    $HephaestusFolder = Get-HephaestusFolder
    $HephaestusPath = Join-Path $HephaestusFolder 'Hephaestus.ps1'
    return $HephaestusPath
}

function Is-HephaestusScript {
    $currentScriptPath = $MyInvocation.MyCommand.Path
    $HephaestusPath = Get-HephaestusPath

    return $currentScriptPath -eq $HephaestusPath
}

function Add-HephaestusToStartup {
    $registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    $keyName = "Hephaestus"
    
    $HephaestusPath = Get-HephaestusPath
    $powershellCommand = "powershell.exe -ExecutionPolicy Bypass -File `"$HephaestusPath`""

    try {
        if (Test-Path -Path $registryPath) {
            $currentValue = Get-ItemProperty -Path $registryPath -Name $keyName -ErrorAction SilentlyContinue

            if ($currentValue.$keyName -eq $powershellCommand) {
                Write-Host "The 'Hephaestus' key is already set with the correct value." -ForegroundColor Green
            } else {
                Set-ItemProperty -Path $registryPath -Name $keyName -Value $powershellCommand
                Write-Host "'Hephaestus' key updated with the correct value." -ForegroundColor Green
            }
        } else {
            New-Item -Path $registryPath -Force | Out-Null
            New-ItemProperty -Path $registryPath -Name $keyName -Value $powershellCommand -PropertyType String -Force | Out-Null
            Write-Host "'Hephaestus' key added to startup." -ForegroundColor Green
        }
    } catch {
        Write-Host "Error while adding/updating the 'Hephaestus' key: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Copy-ToHephaestusPath {
    $currentScriptPath = $PSCommandPath
    if (-not $currentScriptPath) {
        Write-Host "This is not being run from a script file." -ForegroundColor Yellow
        return
    }

    $HephaestusPath = Get-HephaestusPath
    $HephaestusFolder = Get-HephaestusFolder

    try {
        if (-not (Test-Path $HephaestusFolder)) {
            New-Item -Path $HephaestusFolder -ItemType Directory | Out-Null
        }

        Copy-Item -Path $currentScriptPath -Destination $HephaestusPath -Force
        Write-Host "Script successfully copied to: $HephaestusPath"
    } catch {
        Write-Host "Error copying script to Hephaestus path: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function DoAuto {
    if ($server.autoStart)
    {
        $isAuto = Is-HephaestusScript
        Write-Host "isAuto: $isAuto"
        if (-not $isAuto)
        {
            Copy-ToHephaestusPath
        }
        Add-HephaestusToStartup
    }
}

DoAuto