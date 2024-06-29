Write-Host "lib"

function FtpDefs {
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

    FtpDefs
    Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled False

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

    # Output result
    Get-Website -Name $ftpSiteName
}

