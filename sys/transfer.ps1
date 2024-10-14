param (
    [string]$serverName, [object]$session
)
if ([string]::IsNullOrEmpty($serverName)) {
        throw "-serverName argument is null"
}
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -Path $scriptDir
. ".\current.ps1" -serverName $serverName
. ".\lib.ps1"


Add-Type -AssemblyName "System.IO.Compression.FileSystem"
Clear-Folder -FolderPath "C:\_publish\"
Copy-Folder -SourcePath $server.certDir -DestinationPath "C:\_publish\local\cert"
Copy-Folder -SourcePath $server.userDataDir -DestinationPath "C:\_publish\local\data\$serverName"
Compress-FolderToZip -SourceFolder "C:\_publish\local" -targetZipFile "C:\_publish\local.zip"
Copy-Item -Path "C:\_publish\local.zip" -Destination "C:\_publish\local2.zip" -ToSession $session -Force 
Invoke-Command -Session $session -ScriptBlock {
    param ([string]$serverName)
    
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
                try 
                {
            
                    $entryDestinationPath = Join-Path -Path $destinationPath -ChildPath $entry.FullName
        
                    if ($entry.FullName.EndsWith('/')) {
                        # Create directory if it doesn't exist
                        if (-not (Test-Path -Path $entryDestinationPath)) {
                            Write-Output "Creating directory: $entryDestinationPath"
                            New-Item -ItemType Directory -Path $entryDestinationPath -Force -ErrorAction SilentlyContinue 
                        }
                    } else {
                        # Ensure directory exists
                        $entryDir = [System.IO.Path]::GetDirectoryName($entryDestinationPath)
                        if (-not (Test-Path -Path $entryDir)) {
                            Write-Output "Creating directory: $entryDir"
                            New-Item -ItemType Directory -Path $entryDir -Force -ErrorAction SilentlyContinue 
                        }
        
                        
                        try {
                    
                            # Extract file, overwrite if exists
                            Write-Output "Extracting file: $($entry.FullName) to $entryDestinationPath"
                            $entryStream = $entry.Open()
                            $fileStream = [System.IO.File]::Create($entryDestinationPath)
            
                            try {
                                $entryStream.CopyTo($fileStream)
                                $fileStream.Close()  # Close the file stream explicitly
                                Write-Output "File extracted: $entryDestinationPath"
                            } catch {
                                Write-Error "Failed to extract file: $entryDestinationPath. $_"
                            } finally {
                                $entryStream.Close()  # Close the entry stream explicitly
                            }
                        } catch {

                        }
                    }
                 } 
                 catch 
                 {
                    Write-Error "An error occurred during extraction: $_"
                 }                
            }                    
            Write-Output "Extraction completed successfully. Files extracted to $destinationPath"
        } 
        catch {
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

    
    Write-Host "remotes- $serverName"
    try {
        Add-Type -AssemblyName "System.IO.Compression.FileSystem"
    }
    catch {
    }

    Clear-Folder "C:\_publish\extracted"
    Extract-ZipFile -zipFilePath "C:\_publish\local2.zip" -destinationPath "C:\_publish\extracted"

    Copy-Item -Path "C:\_publish\extracted\local\cert" -Destination "C:\inetpub\wwwroot" -Recurse -Force 
    Copy-Item -Path "C:\_publish\extracted\local\data\$serverName" -Destination "C:\data\" -Recurse -Force 

} -ArgumentList $serverName

