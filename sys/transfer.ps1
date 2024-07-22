param (
    [string]$serverName, [object]$session
)
if ([string]::IsNullOrEmpty($serverName)) {
        throw "-serverName argument is null"
}


Add-Type -AssemblyName "System.IO.Compression.FileSystem"
Clear-Folder -FolderPath "C:\xyz"
Copy-Folder -SourceFolder $server.adsDir -TargetFolder "C:\xyz\localdata\"
Copy-Folder -SourceFolder $server.certDir -TargetFolder "C:\xyz\localdata\"
Copy-Folder -SourceFolder $server.sysDir -TargetFolder "C:\xyz\localdata\"
Copy-Folder -SourceFolder $server.userDataDir -TargetFolder "C:\xyz\localdata\data"
Compress-FolderToZip -SourceFolder "C:\xyz\localdata" -targetZipFile "C:\xyz\xyz.zip"
Copy-Item -Path  "C:\xyz\xyz.zip" -Destination  "C:\xyz\xyz2.zip" -ToSession $session -Recurse 
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
                            if (-not (Test-Path -Path $entryDir) -and $entryDir -ne ".") {
                                Write-Output "Creating directory: $entryDir"
                                New-Item -ItemType Directory -Path $entryDir -Force -ErrorAction SilentlyContinue 
                            }
            
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
        
        function Copy-Folder {
            param(
                [Parameter(Mandatory=$true)]
                [string]$SourceFolder,
        
                [Parameter(Mandatory=$true)]
                [string]$TargetFolder
            )
        
            # Check if source folder exists
            if (-not (Test-Path -Path $SourceFolder -PathType Container)) {
                Write-Error "Source folder '$SourceFolder' not found."
                return
            }
        
            # Create the target folder if it doesn't exist
            if (-not (Test-Path -Path $TargetFolder -PathType Container)) {
                New-Item -Path $TargetFolder -ItemType Directory -Force | Out-Null
                Write-Output "Created folder '$TargetFolder'."
            }
        
            try {
                # Copy the source folder and its contents recursively to the target folder
                Copy-Item -Path $SourceFolder -Destination $TargetFolder -Recurse -Force -ErrorAction Stop
        
                Write-Output "Copied '$SourceFolder' to '$TargetFolder'."
            } catch {
                Write-Error "Failed to copy folder '$SourceFolder' to '$TargetFolder'. $_"
            }
        }

        Clear-Folder -FolderPath "C:\localdata"
        Write-Host "remotes- $serverName"
        try {
            Add-Type -AssemblyName "System.IO.Compression.FileSystem"
            Extract-ZipFile -zipFilePath "C:\xyz\xyz2.zip" -destinationPath "C:\"

        }
        catch {
            Write-Output "exception extract $_"
        }

        Clear-Folder "C:\inetpub\wwwroot\ads"
        Copy-Item -Path "C:\localdata\ads" -Destination "C:\inetpub\wwwroot" -Recurse -Force 

        if (-not (Test-Path -Path "C:\inetpub\wwwroot\ads\d-data" -PathType Container)) {
            New-Item -Path "C:\inetpub\wwwroot\ads\d-data" -ItemType Directory -Force | Out-Null
        }
        Copy-Item -Path "C:\localdata\data\$serverName\troyan.txt" -Destination "C:\inetpub\wwwroot\ads\d-data" -Force
} -ArgumentList $serverName

