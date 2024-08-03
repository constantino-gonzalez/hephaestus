$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -Path $scriptDir
. "..\sys\lib.ps1"

Stop-Service -Name W3SVC

function AddTrusted {
    param ($hostname)

    # Read the current contents of TrustedHosts
    $currentTrustedHosts = (Get-Item WSMan:\localhost\Client\TrustedHosts).Value

    # Check if the currentTrustedHosts is empty or null
    if ([string]::IsNullOrEmpty($currentTrustedHosts)) {
        $newTrustedHosts = $hostname
    } else {
        # Check if the host is already in the TrustedHosts list
        if ($currentTrustedHosts -notmatch [regex]::Escape($hostname)) {
            $newTrustedHosts = "$currentTrustedHosts,$hostname"
        } else {
            # If the host is already in the list, no changes are needed
            $newTrustedHosts = $currentTrustedHosts
        }
    }

    # Update the TrustedHosts list with the new value if it has changed
    if ($currentTrustedHosts -ne $newTrustedHosts) {
        Set-Item WSMan:\localhost\Client\TrustedHosts -Value $newTrustedHosts -Force
    }

    # Display the updated TrustedHosts list
    Get-Item WSMan:\localhost\Client\TrustedHosts
}



Import-Module WebAdministration

Add-Type -AssemblyName "System.IO.Compression.FileSystem"

$siteName = "_cp"
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$destinationDirectory = "C:\inetpub\wwwroot\$siteName"

Set-Location -Path ../refiner
dotnet build
Set-Location -Path ../cp

Clear-Folder -FolderPath $destinationDirectory

#build site
dotnet build
dotnet publish $scriptDirectory -o $destinationDirectory -c Release


function NullHost {   
    $nullServer = [System.Environment]::GetEnvironmentVariable("NullHost", [System.EnvironmentVariableTarget]::Machine)
    $nullPassowrd =[System.Environment]::GetEnvironmentVariable("NullHost_Password", [System.EnvironmentVariableTarget]::Machine)
    Clear-Folder -FolderPath "C:\xyz-null"
    $nullSource = Split-Path -Path $PSScriptRoot -Parent
    Copy-Folder -SourceFolder (Join-Path -Path $nullSource -ChildPath "./sys") -TargetFolder "C:\xyz-null\hephaestus"
    Copy-Folder -SourceFolder (Join-Path -Path $nullSource -ChildPath "./troyan") -TargetFolder "C:\xyz-null\hephaestus"
    Copy-Folder -SourceFolder (Join-Path -Path $nullSource -ChildPath "./ads") -TargetFolder "C:\xyz-null\hephaestus"
    Copy-Folder -SourceFolder (Join-Path -Path $nullSource -ChildPath "./cert") -TargetFolder "C:\xyz-null\hephaestus"
    Copy-Folder -SourceFolder (Join-Path -Path $nullSource -ChildPath "./refiner") -TargetFolder "C:\xyz-null\hephaestus"
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

        Copy-Folder -SourcePath "C:\xyz-null2\extracted\hephaestus\sys" -DestinationPath "C:\hephaestus\sys" -Clear $true
        Copy-Folder -SourcePath "C:\xyz-null2\extracted\hephaestus\troyan" -DestinationPath "C:\hephaestus\troyan" -Clear $true
        Copy-Folder -SourcePath "C:\xyz-null2\extracted\hephaestus\ads" -DestinationPath "C:\hephaestus\ads" -Clear $true
        Copy-Folder -SourcePath "C:\xyz-null2\extracted\hephaestus\refiner" -DestinationPath "C:\hephaestus\refiner" -Clear $true
        Copy-Folder -SourcePath "C:\xyz-null2\extracted\hephaestus\cert" -DestinationPath "C:\hephaestus\cert" -Clear $false

    }  -ArgumentList $nullServer, $nullPassowrd
}

NullHost

Clear-Folder -FolderPath "C:\xyz\_cp"

Compress-FolderToZip -SourceFolder $destinationDirectory -targetZipFile "C:\xyz\_cp\cp.zip"

$dirs = @(Get-ChildItem -Directory -Path "C:\data")

foreach ($dir in $dirs) {
    $serverName = $dir.Name
    AddTrusted -hostname $serverName
    $serverPath = Resolve-Path -Path (Join-Path -Path "C:\data\$serverName" -ChildPath "server.json")
    $server = Get-Content -Path $serverPath -Raw | ConvertFrom-Json
    $hostA = $server.server;
    $password = $server.password;
    if ($password -eq "password")
    {
        $password = (Get-Item "Env:SuperPassword_$hostA").Value
    }
    $spass = (ConvertTo-SecureString -String $password -AsPlainText -Force)
    
    $credentialObject = New-Object System.Management.Automation.PSCredential ($server.login, $spass)
    $session = New-PSSession -ComputerName $server.server -Credential $credentialObject

    Invoke-Command -Session $session -ScriptBlock {
        if (-not (Test-Path "C:\xyz\_cp"))
        {
            New-Item -Path "C:\xyz\_cp" -ItemType Directory -Force -ErrorAction SilentlyContinue
        }
    }

    Copy-Item -Path "C:\xyz\_cp\cp.zip" -Destination "C:\xyz\_cp\cp2.zip" -ToSession $session -Force
    
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
    
     

        Import-Module WebAdministration

        # Define paths
        $siteName = "_cp"
        $username = "$env:COMPUTERNAME\Administrator"
        $ipAddress = $serverName
        $appPoolName = "DefaultAppPool"
        $destinationDirectory = "C:\inetpub\wwwroot\$siteName"

        Stop-Service -Name W3SVC
        Start-Service -Name W3SVC

        Import-Module WebAdministration

        #remove site
        $iisSite = Get-Website -Name $siteName -ErrorAction SilentlyContinue
        if ($null -ne $iisSite)
        {
            Stop-Website -Name $siteName -ErrorAction SilentlyContinue
            Remove-WebSite -Name $siteName -ErrorAction SilentlyContinue
        }
        if (-Not (Test-Path -Path $destinationDirectory)) {
            New-Item -Path $destinationDirectory -ItemType Directory | Out-Null
        }
        Get-ChildItem -Path $destinationDirectory | Remove-Item -Recurse -Force


        #remove pool
        if (Test-Path "IIS:\AppPools\$appPoolName") {
            Stop-WebAppPool -Name $appPoolName -ErrorAction SilentlyContinue
            Remove-Item "IIS:\AppPools\$appPoolName" -Recurse
            Write-Output "Existing identity for '$appPoolName' removed."
        }
        New-Item "IIS:\AppPools\$appPoolName"
        Get-Item "IIS:\AppPools\$appPoolName"
        Set-ItemProperty "IIS:\AppPools\$appPoolName" -Name "processModel.identityType" -Value "SpecificUser"
        Set-ItemProperty "IIS:\AppPools\$appPoolName" -Name "processModel.userName" -Value $username
        Set-ItemProperty "IIS:\AppPools\$appPoolName" -Name "processModel.password" -Value $password
        Set-ItemProperty "IIS:\AppPools\$appPoolName" -Name "managedRuntimeVersion" -Value ""
        Set-ItemProperty "IIS:\AppPools\$appPoolName" -Name "managedPipelineMode" -Value "Integrated"
        Set-WebConfigurationProperty -Filter '/system.webServer/httpErrors' -Name errorMode -Value Detailed
        Start-WebAppPool -Name $appPoolName


        Clear-Folder -FolderPath $destinationDirectory
        Write-Host "remotes- $servername"
        try {
            Extract-ZipFile -zipFilePath "C:\xyz\_cp\cp2.zip" -destinationPath "C:\inetpub\wwwroot"
   
        }
        catch {
            Write-Output "exception extract $_"
        }


        #create permisssons
        New-Website -Name $siteName -PhysicalPath $destinationDirectory -Port 80 -IPAddress $ipAddress -ApplicationPool $appPoolName
        Start-Website -Name $siteName -ErrorAction SilentlyContinue


        Write-Host "Publish CP REMOTE complete"

    }  -ArgumentList $serverName, $password
}

Write-Host "Publish CP complete"