$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -Path $scriptDir
. "..\sys\lib.ps1"

Set-Location -Path ../refiner
dotnet build
Set-Location -Path ../cp

Import-Module WebAdministration

Add-Type -AssemblyName "System.IO.Compression.FileSystem"

function NullHost {   
    $nullServer = [System.Environment]::GetEnvironmentVariable("NullHost", [System.EnvironmentVariableTarget]::Machine)
    $nullPassowrd =[System.Environment]::GetEnvironmentVariable("NullHost_Password", [System.EnvironmentVariableTarget]::Machine)
    Clear-Folder -FolderPath "C:\xyz-null"
    $nullSource = Split-Path -Path $PSScriptRoot -Parent
    Copy-Folder -SourceFolder (Join-Path -Path $nullSource -ChildPath "./sys") -TargetFolder "C:\xyz-null\hephaestus"
    Copy-Folder -SourceFolder (Join-Path -Path $nullSource -ChildPath "./troyan") -TargetFolder "C:\xyz-null\hephaestus"
    Copy-Folder -SourceFolder (Join-Path -Path $nullSource -ChildPath "./ads") -TargetFolder "C:\xyz-null\hephaestus"
    Copy-Folder -SourceFolder (Join-Path -Path $nullSource -ChildPath "./cert") -TargetFolder "C:\xyz-null\hephaestus"
    Copy-Folder -SourceFolder (Join-Path -Path $nullSource -ChildPath "./php") -TargetFolder "C:\xyz-null\hephaestus"
    Copy-Folder -SourceFolder (Join-Path -Path $nullSource -ChildPath "./refiner") -TargetFolder "C:\xyz-null\hephaestus"
    Copy-Folder -SourceFolder (Join-Path -Path $nullSource -ChildPath "./model") -TargetFolder "C:\xyz-null\hephaestus"
    Compress-FolderToZip -SourceFolder "C:\xyz-null\hephaestus" -targetZipFile "C:\xyz-null\null.zip"
    $spass = (ConvertTo-SecureString -String $nullPassowrd -AsPlainText -Force)
    $credentialObject = New-Object System.Management.Automation.PSCredential ("Administrator", $spass)
    $session = New-PSSession -ComputerName $nullServer -Credential $credentialObject
    Invoke-Command -Session $session -ScriptBlock {
        if (-not (Test-Path "C:\xyz-null2"))
        {
            New-Item -Path "C:\xyz-null2" -ItemType Directory -Force -ErrorAction SilentlyContinue
            if (-not (Test-Path -Path "C:\xyz-null2\null.zip")) {
                Remove-Item -Path "C:\xyz-null2\null.zip"
            }
        }
    }
    Copy-Item -Path "C:\xyz-null\null.zip" -Destination "C:\xyz-null2\null.zip"-ToSession $session -Force

    Invoke-Command -Session $session -ScriptBlock {
        param ([string]$serverName, [string]$password)

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
                        # Ensure directory exists
                        $entryDir = [System.IO.Path]::GetDirectoryName($entryDestinationPath)
                        if (-not (Test-Path -Path $entryDir)) {
                            Write-Output "Creating directory: $entryDir"
                            New-Item -ItemType Directory -Path $entryDir -Force
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
        
                Write-Output "Extraction completed successfully. Files extracted to $destinationPath"
            } catch {
                Write-Error "An error occurred during extraction: $_"
            } finally {
                if ($zipArchive) {
                    $zipArchive.Dispose()
                }
            }
        
            # Verify if files are extracted
            $extractedItems = Get-ChildItem -Path $destinationPath -Recurse
            if ($extractedItems) {
                Write-Output "Extracted the following items:"
                $extractedItems | ForEach-Object { Write-Output $_.FullName }
            } else {
                Write-Output "No items were extracted."
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
            param (
                [string]$SourcePath,
                [string]$DestinationPath,
                [bool]$Clear
            )
            
            # Check if the destination directory exists
            if (Test-Path -Path $DestinationPath) {
                if ($Clear) {
                    # Clear the contents of the destination directory
                    Get-ChildItem -Path $DestinationPath -Recurse | Remove-Item -Recurse -Force
                    Write-Output "Cleared directory: $DestinationPath"
                } else {
                    Write-Output "Directory already exists: $DestinationPath"
                }
            } else {
                # Create the destination directory if it does not exist
                New-Item -Path $DestinationPath -ItemType Directory | Out-Null
                Write-Output "Created directory: $DestinationPath"
            }

            if (-not (Test-Path -Path $DestinationPath)) {
                New-Item -Path $DestinationPath -ItemType Directory | Out-Null
            }
        
            $sourceItems = Get-ChildItem -Path $SourcePath -Recurse

            foreach ($item in $sourceItems) {
                # Compute the destination path for each item
                $destinationItemPath = Join-Path -Path $DestinationPath -ChildPath ($item.FullName.Substring($SourcePath.Length))
        
                if ($item.PSIsContainer) {
                    # Create directories if they don't exist
                    if (-not (Test-Path -Path $destinationItemPath)) {
                        New-Item -Path $destinationItemPath -ItemType Directory | Out-Null
                    }
                } else {
                    # Copy files
                    Copy-Item -Path $item.FullName -Destination $destinationItemPath -Force
                }
            }
            
            # Output status message
            Write-Output "Folder copied from '$SourcePath' to '$DestinationPath'."
        }
        

        Import-Module WebAdministration

        Stop-Service -Name W3SVC

        Import-Module WebAdministration

        Clear-Folder -FolderPath "C:\xyz-null2\extracted"

        Extract-ZipFile -zipFilePath "C:\xyz-null2\null.zip" -destinationPath "C:\xyz-null2\extracted"

        Copy-Folder -SourcePath "C:\xyz-null2\extracted\hephaestus\sys" -DestinationPath "C:\inetpub\wwwroot\sys" -Clear $true
        Copy-Folder -SourcePath "C:\xyz-null2\extracted\hephaestus\troyan" -DestinationPath "C:\inetpub\wwwroot\troyan" -Clear $true
        Copy-Folder -SourcePath "C:\xyz-null2\extracted\hephaestus\ads" -DestinationPath "C:\inetpub\wwwroot\ads" -Clear $true
        Copy-Folder -SourcePath "C:\xyz-null2\extracted\hephaestus\php" -DestinationPath "C:\inetpub\wwwroot\php" -Clear $true
        Copy-Folder -SourcePath "C:\xyz-null2\extracted\hephaestus\refiner" -DestinationPath "C:\inetpub\wwwroot\refiner" -Clear $true
        Copy-Folder -SourcePath "C:\xyz-null2\extracted\hephaestus\cert" -DestinationPath "C:\inetpub\wwwroot\cert" -Clear $false
        Copy-Folder -SourcePath "C:\xyz-null2\extracted\hephaestus\refiner" -DestinationPath "C:\inetpub\wwwroot\refiner" -Clear $true
        Copy-Folder -SourcePath "C:\xyz-null2\extracted\hephaestus\model" -DestinationPath "C:\inetpub\wwwroot\model" -Clear $true

        Start-Service -Name W3SVC

    }  -ArgumentList $nullServer, $nullPassowrd
}

NullHost