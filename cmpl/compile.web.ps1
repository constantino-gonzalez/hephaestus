param (
    [string]$serverName
)
if ([string]::IsNullOrEmpty($serverName)) {
        throw "-serverName argument is null"
}
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -Path $scriptDir
. ".\current.ps1" -serverName $serverName
. ".\lib.ps1"



Clear-Folder -FolderPath "C:\xyz"
Copy-Folder -SourceFolder $server.adsDir -TargetFolder "C:\xyz\localdata\"
Copy-Folder -SourceFolder $server.certDir -TargetFolder "C:\xyz\localdata\"
Copy-Folder -SourceFolder $server.updDir -TargetFolder "C:\xyz\localdata\"
Copy-Folder -SourceFolder $server.sysDir -TargetFolder "C:\xyz\localdata\"
Copy-Folder -SourceFolder $server.cmplDir -TargetFolder "C:\xyz\localdata\"
Copy-Folder -SourceFolder $server.userDataDir -TargetFolder "C:\xyz\localdata\data"
Compress-FolderToZip -SourceFolder "C:\xyz\localdata" -targetZipFile "C:\xyz\xyz.zip"

$credentialObject = New-Object System.Management.Automation.PSCredential ($server.login, (ConvertTo-SecureString -String $server.password -AsPlainText -Force))
$session = New-PSSession -ComputerName $server.server -Credential $credentialObject

Copy-Item -Path  "C:\xyz\xyz.zip" -Destination  "C:\xyz\xyz2.zip" -ToSession $session -Recurse 

    Invoke-Command -Session $session -ScriptBlock {

        function Extract-ZipFile {
            param (
                [string]$zipFilePath,
                [string]$destinationPath
            )
        
            # Ensure the destination path exists
            if (-not (Test-Path -Path $destinationPath)) {
                Write-Output "Destination path does not exist. Creating: $destinationPath"
                New-Item -ItemType Directory -Path $destinationPath -Force
            }
        
            # Load the required assembly for ZIP operations
            try {
                [System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null
                Write-Output "Assembly System.IO.Compression.FileSystem loaded successfully."
            } catch {
                Write-Error "Failed to load the required assembly."
                return
            }
        
            # Perform the extraction
            try {
                $zipArchive = [System.IO.Compression.ZipFile]::OpenRead($zipFilePath)
        
                foreach ($entry in $zipArchive.Entries) {
                    $entryDestinationPath = Join-Path -Path $destinationPath -ChildPath $entry.FullName
        
                    if ($entry.FullName.EndsWith('/')) {
                        # Create directory if it doesn't exist
                        if (-not (Test-Path -Path $entryDestinationPath)) {
                            Write-Output "Creating directory: $entryDestinationPath"
                            New-Item -ItemType Directory -Path $entryDestinationPath -Force
                        }
                    } else {
                        # Ensure directory exists for file extraction
                        $entryDir = [System.IO.Path]::GetDirectoryName($entryDestinationPath)
                        if (-not (Test-Path -Path $entryDir)) {
                            Write-Output "Creating directory: $entryDir"
                            New-Item -ItemType Directory -Path $entryDir -Force
                        }
        
                        # Extract file, overwrite if exists
                        Write-Output "Extracting file: $($entry.FullName) to $entryDestinationPath"
                        $entryStream = $entry.Open()
                        
                        try {
                            $fileStream = [System.IO.File]::Create($entryDestinationPath)
                            $entryStream.CopyTo($fileStream)
                            $fileStream.Close()  # Close the file stream explicitly
                            Write-Output "File extracted: $entryDestinationPath"
                        } catch {
                            Write-Error "Failed to extract file: $entryDestinationPath. $_"
                        } finally {
                            $entryStream.Close()  # Close the entry stream explicitly
                        }
                    }
                }
        
                Write-Output "Extraction completed successfully. Files extracted to $destinationPath"
            } catch {
                Write-Error "An error occurred during extraction: $_"
            } finally {
                if ($zipArchive) {
                    $zipArchive.Dispose()
                }
            }
        }
        

        function Clear-Folder {
            param(
                [Parameter(Mandatory=$true)]
                [string]$FolderPath
            )
        
            # Create the folder if it doesn't exist
            if (-not (Test-Path -Path $FolderPath -PathType Container)) {
                New-Item -Path $FolderPath -ItemType Directory -Force | Out-Null
                Write-Output "Created folder '$FolderPath'."
            }
        
            try {
                # Get all items (files and folders) in the folder
                $items = Get-ChildItem -Path $FolderPath -Force
        
                # Remove each item
                foreach ($item in $items) {
                    if ($item.PSIsContainer) {
                        Remove-Item -Path $item.FullName -Recurse -Force
                    } else {
                        Remove-Item -Path $item.FullName -Force
                    }
                }
        
                Write-Output "Folder '$FolderPath' cleaned successfully."
            } catch {
                Write-Error "Failed to clean folder '$FolderPath'. $_"
            }
        }

        Clear-Folder -FolderPath "C:\localdata"
        Write-Host "remotes- $servername"
        try {
            Extract-ZipFile -zipFilePath "C:\xyz\xyz2.zip" -destinationPath "C:\"
   
        }
        catch {
            Write-Output "exception extract $_"
        }

        Clear-Folder "C:\inetpub\wwwroot\ads"
        Copy-Item -Path "C:\localdata\ads" -Destination "C:\inetpub\wwwroot" -Recurse -Force 
    }


$scriptBlock = {
    param (
        $serverName,
        $scriptPath,
        $ipAddress,
        $ftp = ""
    )
    $tempFile = [System.IO.Path]::GetTempFileName()
    $completeFile = "$tempFile.complete"
    $isElevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $isElevated) {
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\elevatedScript.ps1`" -serverName $serverName -scriptPath $scriptPath -ipAddress "$ipaAddress" -tempFile $tempFile" -Verb RunAs
        while (-not (Test-Path $completeFile)) {
            Start-Sleep -Seconds 1
        }
        $output = Get-Content $tempFile
        Remove-Item $tempFile, $completeFile
        $output
        exit
    }
    & $scriptPath -serverName $serverName -ipAddress $ipAddress, -ftp $ftp
}

Invoke-Command -Session $session -ScriptBlock $scriptBlock -ArgumentList $serverName, (Join-Path -Path "C:\localdata\sys" -ChildPath "dns.ps1")

Invoke-Command -Session $session -ScriptBlock $scriptBlock -ArgumentList $serverName, (Join-Path -Path "C:\localdata\sys" -ChildPath "iis.ps1")

Invoke-Command -Session $session -ScriptBlock $scriptBlock -ArgumentList $serverName, (Join-Path -Path "C:\localdata\sys" -ChildPath "ftp.ps1")

Write-Host "Compile Web complete"