Write-Host "lib"


$scriptBlock = {
    param (
        $serverName,
        $scriptPath
    )
    $scriptPath = (Join-Path -Path "C:\localdata\sys" -ChildPath $scriptPath)
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
    & $scriptPath -serverName $serverName
}

function Invoke-RemoteSysScript {
    param (
        [Parameter(Mandatory=$true)]
        $Session,
                
        [Parameter(Mandatory=$false)]
        [Array]$ArgumentList)
        Invoke-Command -Session $Session -ScriptBlock $scriptBlock -ArgumentList $ArgumentList

}

# function Invoke-RemoteScript {
#     param (
#         [Parameter(Mandatory=$true)]
#         [Microsoft.PowerShell.Commands.PSSession]$Session,
        
#         [Parameter(Mandatory=$true)]
#         [string]$ScriptPath,
        
#         [Parameter(Mandatory=$false)]
#         [Array]$Arguments
#     )
#     $scriptBlock = {
#         param (
#             $path,
#             $argsX
#         )
#         & $path @argsX
#     }
#     Invoke-Command -Session $Session -ScriptBlock $scriptBlock -ArgumentList $ScriptPath, $Arguments
# }


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

function Compress-FolderToZip {
    param(
        [Parameter(Mandatory=$true)]
        [string]$SourceFolder,

        [Parameter(Mandatory=$true)]
        [string]$TargetZipFile
    )

    # Create the directory for the target ZIP file if it doesn't exist
    $targetDirectory = Split-Path -Path $TargetZipFile -Parent
    if (-not (Test-Path -Path $targetDirectory -PathType Container)) {
        New-Item -Path $targetDirectory -ItemType Directory -Force
    }

    # Check if the source folder exists
    if (Test-Path -Path $SourceFolder -PathType Container) {
        # Create or overwrite the ZIP file
        [System.IO.Compression.ZipFile]::CreateFromDirectory($SourceFolder, $TargetZipFile, [System.IO.Compression.CompressionLevel]::Optimal, $true)

        Write-Output "Folder '$SourceFolder' compressed to '$TargetZipFile'."
    } else {
        Write-Error "Source folder '$SourceFolder' not found."
    }
}

function Create-FtpDevs {
    & netsh advfirewall set global StatefulFtp enable
    Set-WebConfiguration "/system.ftpServer/firewallSupport" -PSPath "IIS:\" -Value @{lowDataChannelPort="5000";highDataChannelPort="6000";}
    Add-WebConfiguration -Filter "/system.ftpServer/serverRuntime" -PSPath "IIS:\Sites\" -Value @{name='dataChannelMaximumPassiveConnections'; value=100; attributes=@{override='True'}}
    Get-IISConfigSection -SectionPath "system.ftpServer/firewallSupport"
    $existingRule = Get-NetFirewallRule -DisplayName "FTP Server Port" -ErrorAction SilentlyContinue
    if ($existingRule) {
        Remove-NetFirewallRule -DisplayName "FTP Server Port"
    }
    New-NetFirewallRule `
    -Name "FTP Server Port" `
    -DisplayName "FTP Server Port" `
    -Description 'Allow FTP Server Ports' `
    -Profile Any `
    -Direction Inbound `
    -Action Allow `
    -Protocol TCP `
    -Program Any `
    -LocalAddress Any `
    -LocalPort 20,21,5000-6000

    Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled False
}


function Create-FtpSite {
    param (
        [string] $ftpUrl,
        [string] $ftpPath,
        [string] $ftpSiteName
    )

    $pattern = '^ftp://(?<user>[^:]+):(?<password>[^@]+)@(?<host>.+)$'

    if ($ftpUrl -match $pattern) {
        $user = $matches['user']
        $pass = $matches['password']
        $ipAddress = $matches['host']

        Write-Output "User: $user"
        Write-Output "Password: $password"
        Write-Output "Host: $host"
    } else {
        Write-Output "Invalid FTP URL format."
        exit
    }

    # FTP configuration variables
    $ftpPort = 21
    
    # Function to create or update local user
    function CreateOrUpdateLocalUser {
        param (
            [string] $username,
            [string] $password
        )

        if (Get-LocalUser -Name $username -ErrorAction SilentlyContinue) {
            # User exists, delete and recreate
            Remove-LocalUser -Name $username
        }

        # Create new user
        $securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
        New-LocalUser -Name $username -Password $securePassword -PasswordNeverExpires
    }

    # Create or update local user
    CreateOrUpdateLocalUser -username $user -password $pass



    # Remove existing FTP site if it exists
    $existingSite = Get-Website -Name $ftpSiteName -ErrorAction SilentlyContinue
    if ($existingSite -ne $null) {
        Stop-Website -Name $ftpSiteName -ErrorAction SilentlyContinue
        Remove-WebSite -Name $ftpSiteName -ErrorAction SilentlyContinue
    }

    # Create new FTP site
    New-WebFtpSite -Name $ftpSiteName -IPAddress $ipAddress -Port $ftpPort -PhysicalPath $ftpPath -Force

    # Configure FTP site settings
    Set-ItemProperty "IIS:\Sites\$ftpSiteName" -Name ftpServer.security.ssl.controlChannelPolicy -Value 0
    Set-ItemProperty "IIS:\Sites\$ftpSiteName" -Name ftpServer.security.ssl.dataChannelPolicy -Value 0
    Set-ItemProperty "IIS:\Sites\$ftpSiteName" -Name ftpServer.security.authentication.basicAuthentication.enabled -Value $true
    Set-ItemProperty "IIS:\Sites\$ftpSiteName" -Name ftpserver.userisolation.mode -Value "None"

    # Set file system permissions
    $acl = Get-Acl -Path $ftpPath
    $permissions = [System.Security.AccessControl.FileSystemRights]::FullControl
    $inheritanceFlags = [System.Security.AccessControl.InheritanceFlags]::ContainerInherit -bor [System.Security.AccessControl.InheritanceFlags]::ObjectInherit
    $propagationFlags = [System.Security.AccessControl.PropagationFlags]::None
    $accessControlType = [System.Security.AccessControl.AccessControlType]::Allow
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($user, $permissions, $inheritanceFlags, $propagationFlags, $accessControlType)
    $acl.SetAccessRule($accessRule)
    Set-Acl -Path $ftpPath -AclObject $acl

    # Configure web configuration for authorization
    Add-WebConfiguration "/system.ftpServer/security/authorization" `
        -value @{accessType="Allow";roles="";permissions="Read,Write";users="$user"} `
        -PSPath IIS:\ -location "$ftpSiteName"

        Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.applicationHost/sites/site[@name='$ftpSiteName']/ftpServer/security/authentication/anonymousAuthentication" -name "enabled" -value "False"
        Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.applicationHost/sites/site[@name='$ftpSiteName']/ftpServer/security/authentication/basicAuthentication" -name "enabled" -value "True"

    # Restart the FTP site
    Restart-WebItem "IIS:\Sites\$ftpSiteName"
}

