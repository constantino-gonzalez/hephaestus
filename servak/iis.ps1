param (
    [string]$serverName, [string]$usePath = ""
)
if ([string]::IsNullOrEmpty($serverName)) {
        throw "-serverName argument is null"
}
$scriptRoot = $PSScriptRoot
$includedScriptPath = Resolve-Path -Path (Join-Path -Path $scriptRoot -ChildPath "..\current.ps1")
. $includedScriptPath   -serverName $serverName -usePath $usePath

Import-Module WebAdministration
Import-Module PSPKI


$portHttp = 80
$portHttps = 443

$ConfirmPreference = 'None'

# CLEAR SITES
function Remove-AllIISWebsites {
    $websites = Get-Website
    foreach ($website in $websites) {
        $siteName = $website.Name
        if ($siteName -eq "_rootCp" -or $siteName -eq "_servachok")
        {
            continue;
        }
        Write-Host "Removing website $siteName..."
        Stop-WebSite -Name $siteName -ErrorAction SilentlyContinue
        Get-WebBinding -Name $siteName | ForEach-Object {
            Remove-WebBinding -Name $siteName -BindingInformation $_.BindingInformation
        }
        Remove-Website -Name $siteName
    }
    Write-Host "All websites and bindings have been removed."
}
Remove-AllIISWebsites


# REMOVE SERTS
function Remove-CertificatesByFriendlyName {
    # List of certificate stores to search
    $stores = @(
        "CurrentUser\My",
        "LocalMachine\My",
        "CurrentUser\Root",
        "LocalMachine\Root",
        "CurrentUser\CA",
        "LocalMachine\CA",
        "CurrentUser\AuthRoot",
        "LocalMachine\AuthRoot"
    )
    foreach ($storeLocation in $stores) {
        $certs = Get-ChildItem -Path "cert:\$storeLocation" | Where-Object { $_.FriendlyName -like "*$friendlyName*" }

        $certs | %{Remove-Item -path $_.PSPath -recurse -Force}

    }
}
Remove-CertificatesByFriendlyName 


function PrepareFolder{ param ([string] $folder, [string] $sourceFolder,  [string] $user)

    $rootPath = "C:\Inetpub\wwwroot"

    if (-not (Test-Path -Path $folder -PathType Container)) {
        New-Item -Path $folder -ItemType Directory -Force | Out-Null
    }
    Get-ChildItem -Path $sourceFolder | ForEach-Object {
        $destinationFile = Join-Path -Path $folder -ChildPath $_.Name
        Copy-Item -Path $_.FullName -Destination $folder -Force

    }
    $acl = Get-Acl -Path $rootPath
    Set-Acl -Path $folder -AclObject $acl

    $acl = Get-Acl -Path $folder
    $permission = "FullControl"
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($user, $permission, "ContainerInherit,ObjectInherit", "None", "Allow")
    $acl.SetAccessRule($accessRule)
    Set-Acl -Path $folder -AclObject $acl

    $acl = Get-Acl -Path $folder
    $permission = "Read, Write, ListDirectory"
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("IUSR", $permission, "ContainerInherit,ObjectInherit", "None", "Allow")
    $acl.SetAccessRule($accessRule)
    Set-Acl -Path $folder -AclObject $acl

    $acl = Get-Acl -Path $folder
    $permission = "Read, Write, ListDirectory"
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("IIS_IUSRS", $permission, "ContainerInherit,ObjectInherit", "None", "Allow")
    $acl.SetAccessRule($accessRule)
    Set-Acl -Path $folder -AclObject $acl
}

function MakeUser{param ([string] $user)    

    if (-not (Get-LocalUser -Name $user -ErrorAction SilentlyContinue)) {
        $password = ConvertTo-SecureString "Abc12345!" -AsPlainText -Force
        $usr = New-LocalUser -Name $user -Password $password -PasswordNeverExpires
    }
}

function CreateWebsite {
    param (
        [string]$domain,
        [string]$ip
    )
    
    $hostHeader = $domain
    $siteName = $domain

    $path = $sitePath

    New-Website -Name $siteName -HostHeader $hostHeader -PhysicalPath $path -Port $portHttp
       
    $httpsBinding = Get-WebBinding -Port $portHttps -Name $siteName -HostHeader $hostHeader -Protocol "https" -ErrorAction SilentlyContinue

    if ($httpsBinding) {
        Remove-WebBinding -Name $siteName -Protocol "https" -Port $portHttps --HostHeader $hostHeader
    }

    $pathPfx = pfxFile($domain)
    $cert = Import-PfxCertificate -FilePath $pathPfx -CertStoreLocation Cert:\LocalMachine\Root -Password $certPassword -Exportable
    $cert = Import-PfxCertificate -FilePath $pathPfx -CertStoreLocation Cert:\LocalMachine\My -Password $certPassword -Exportable

    New-WebBinding -Name $siteName -IPAddress $ip -Port $portHttps -HostHeader $hostHeader -Protocol "https"
    $httpsBinding = Get-WebBinding -Port $portHttps -Name $siteName -HostHeader $hostHeader -Protocol "https"

    $httpsBinding.AddSslCertificate($cert.Thumbprint, "My")
}

function CreateFtpSite {
    $ftpPort = 21
    $ftpSiteName = "_WebFTP"
    $path = $sitePath
    $user = $siteUser

    New-WebFtpSite -Name $ftpSiteName -IPAddress $server.server -Port $ftpPort -PhysicalPath $path

    Set-ItemProperty "IIS:\Sites\$ftpSiteName" -Name ftpServer.security.ssl.controlChannelPolicy -Value 0
    Set-ItemProperty "IIS:\Sites\$ftpSiteName" -Name ftpServer.security.ssl.dataChannelPolicy -Value 0

    Set-ItemProperty "IIS:\Sites\$ftpSiteName" -Name ftpServer.security.authentication.basicAuthentication.enabled -Value $true
    Set-WebConfigurationProperty -Filter '/system.webServer/security/authentication/windowsAuthentication' -Name 'enabled' -Value 'true' -PSPath 'IIS:\' -Location "$ftpSiteName"
    Set-ItemProperty "IIS:\Sites\$ftpSiteName" -Name ftpserver.userisolation.mode -Value "DoNotIsolate"

    Add-WebConfiguration "/system.ftpServer/security/authorization" -value @{accessType="Allow";roles="";permissions="Read,Write";users="$user"} -PSPath IIS:\ -location $ftpSiteName

}


# BURN

MakeUser -user $siteUser
PrepareFolder -folder $sitePath -sourceFolder $servakDirWeb -user $siteUser

$filePath =  (Join-Path -Path $dataDir -ChildPath "../result.iis.txt")
Set-Content -Path $filePath -Value $null
for ($i = 0; $i -lt $server.domains.Length; $i++) {
    $domain = $server.domains[$i]
    $ip = $server.interfaces[$i]
    CreateWebsite -domain $domain $ip
    $line = "$domain - $ip, $path"
    Write-Host $line
    Add-Content -Path $filePath -Value "$line"
}
CreateFtpsite
$user = $siteUser
$path = $sitePath
$ip = $server.server
$line = "ftp://${user}:Abc12345!@${ip}"
Write-Host $line
Add-Content -Path $filePath -Value "$line"

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

FtpDefs
Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled False
Write-Host "Done"
