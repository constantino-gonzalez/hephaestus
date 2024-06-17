param (
    [switch]$force
)

Import-Module WebAdministration
Import-Module IISAdministration
Import-Module PSPKI

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$commonPath = Join-Path -Path $scriptDir -ChildPath "..\common.ps1"
$commonOutput = & $commonPath
$domainArray = $commonOutput.domainArray
$domainPairs = $commonOutput.domainPairs
$domainsKeyed = $commonOutput.domainsKeyed
$networkInterfaces = $commonOutput.networkInterfaces;
$valid = $commonOutput.valid;
if (-not $valid) {
    Write-Host "Exiting iis.ps1 script with an error." -ForegroundColor Red
    throw "An error occurred."
}

$certLocation="cert:\LocalMachine\Root"
$certPassword = ConvertTo-SecureString -String "123" -Force -AsPlainText

$rootPath = "C:\Inetpub\wwwroot"
$portHttp = 80
$portHttps = 443
$friendlyName="IIS Root Authority"

$sourceFolder = Join-Path $scriptDir "..\web"

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

        foreach ($cert in $certs) {
            Remove-Item -LiteralPath $cert.PSPath -Force
            Write-Host "Certificate with FriendlyName containing '$friendlyName' removed from $storeLocation store."
        }
    }
}
Remove-CertificatesByFriendlyName 


# CLEAR SITES
function Remove-AllIISWebsites {
    $websites = Get-Website
    foreach ($website in $websites) {
        $siteName = $website.Name
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

function CreateCertificate {
    param (
        [string]$domain
    )

    $friendlyName = "$domain $friendlyName"
    $expiryDate = (Get-Date).AddYears(25)
    
    $path = Join-Path -Path $scriptDir -ChildPath "..\cert\$domain.cer"
    $pathPfx = Join-Path -Path $scriptDir -ChildPath "..\cert\$domain.pfx"

    if (-not (Test-Path $path)) {
        Write-Host "Certificate creating... $path"
  
        $cert = New-SelfSignedCertificate -DnsName $domain -CertStoreLocation "cert:\LocalMachine\My" -KeySpec KeyExchange -NotAfter $expiryDate -Subject "CN=$domain" -KeyExportPolicy Exportable -FriendlyName $friendlyName
    
        Move-Item -Path "Cert:\LocalMachine\My\$($cert.Thumbprint)" -Destination "Cert:\LocalMachine\Root" -Force:$force
    
        Write-Host $pathPfx
        Export-PfxCertificate -Cert $cert -FilePath $pathPfx -NoClobber -Force -Password $certPassword
    
        Export-Certificate -Cert $cert -FilePath $path -Force
    } else {
        Write-Host "Certificate exists. $pathPfx"
        $certificatePassword = ConvertTo-SecureString -String "123" -Force -AsPlainText
        $certificate = Import-PfxCertificate -FilePath $pathPfx -CertStoreLocation Cert:\LocalMachine\My -Password $certificatePassword -Exportable
        $certificate = Import-PfxCertificate -FilePath $pathPfx -CertStoreLocation Cert:\LocalMachine\Root -Password $certificatePassword -Exportable
        $certificate | Out-Null
    }
}

function SiteInfo {
    param (
        [string]$domain, [int] $idx
    )
    $userName = "anysite"
    $aliasContent = Get-Content (Join-Path -Path $scriptDir -ChildPath "..\aliases.txt")
    $aliases = $aliasContent -split '\r?\n'
    $resolvedPath = $rootPath.Trim()

    foreach ($alias in $aliases) {
        $aliasParts = $alias.Trim() -split '='
        if ($aliasParts.Count -ge 2) {
            $aliasName = $aliasParts[0].Trim()
            $aliasValues = $aliasParts[1].Trim() -split ',' | ForEach-Object { $_.Trim() }
            foreach ($aliasValue in $aliasValues) 
            {
                if ($domain -eq $aliasValue) {
                    $resolvedPath = Join-Path -Path $rootPath -ChildPath "$aliasName"
                    $userName = $aliasName        
                    break
                }
            }
        }
    }
    if ($idx -eq 0){
        return $resolvedPath;
    } elseif ($idx -eq 1) {
        return $userName
    }
}

function SitePath($domain)
{
    return SiteInfo -domain $domain -idx 0
}

function SiteUser($domain)
{
    return SiteInfo -domain $domain -idx 1
}

function PrepareFolder{ param ([string] $folder, [string] $user)

    if (-not (Test-Path -Path $folder -PathType Container)) {
        New-Item -Path $folder -ItemType Directory -Force | Out-Null
    }
    Get-ChildItem -Path $sourceFolder | ForEach-Object {
        $destinationFile = Join-Path -Path $folder -ChildPath $_.Name
#        if (-not (Test-Path -Path $destinationFile -PathType Leaf)) {
            Copy-Item -Path $_.FullName -Destination $folder -Force
#        }
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

    $path = SitePath($domain)
    $user = SiteUser($domain)

    MakeUser -user $user

    PrepareFolder -folder $path -user $user

    New-Website -Name $siteName -HostHeader $hostHeader -PhysicalPath $path -Port $portHttp
       
    $httpsBinding = Get-WebBinding -Port $portHttps -Name $siteName -HostHeader $hostHeader -Protocol "https" -ErrorAction SilentlyContinue

    if ($httpsBinding) {
        Remove-WebBinding -Name $siteName -Protocol "https" -Port $portHttps --HostHeader $hostHeader
    }
        
    $cert = Get-ChildItem -Path $certLocation | Where-Object {
        ($_.DnsNameList -contains $domain) -and
        ($_.FriendlyName -like "*$friendlyName*")
    }

    $pathPfx = Join-Path -Path $scriptDir -ChildPath "..\cert\$domain.pfx"
    $cert = Import-PfxCertificate -FilePath $pathPfx -CertStoreLocation Cert:\LocalMachine\My -Password $certPassword

    New-WebBinding -Name $siteName -IPAddress $ip -Port $portHttps -HostHeader $hostHeader -Protocol "https"
    $httpsBinding = Get-WebBinding -Port $portHttps -Name $siteName -HostHeader $hostHeader -Protocol "https"

    $httpsBinding.AddSslCertificate($cert.Thumbprint, "My")
}

function CreateFtpSite {
    param (
    [string]$domain,
    [string]$ip)

    $ftpPort = 21
    $ftpSiteName = "$domain FTP"
    $path = SitePath($domain)
    $user = SiteUser($domain)
    New-WebFtpSite -Name $ftpSiteName -IPAddress $ip -Port $ftpPort -PhysicalPath $path

    Set-ItemProperty "IIS:\Sites\$ftpSiteName" -Name ftpServer.security.ssl.controlChannelPolicy -Value 0
    Set-ItemProperty "IIS:\Sites\$ftpSiteName" -Name ftpServer.security.ssl.dataChannelPolicy -Value 0

    Set-ItemProperty "IIS:\Sites\$ftpSiteName" -Name ftpServer.security.authentication.basicAuthentication.enabled -Value $true
    Set-WebConfigurationProperty -Filter '/system.webServer/security/authentication/windowsAuthentication' -Name 'enabled' -Value 'true' -PSPath 'IIS:\' -Location "$ftpSiteName"
    Set-ItemProperty "IIS:\Sites\$ftpSiteName" -Name ftpserver.userisolation.mode -Value "DoNotIsolate"

    Add-WebConfiguration "/system.ftpServer/security/authorization" -value @{accessType="Allow";roles="";permissions="Read,Write";users="$user"} -PSPath IIS:\ -location $ftpSiteName

}


# BURN
$filePath =  (Join-Path -Path $scriptDir -ChildPath "../result.iis.txt")
Set-Content -Path $filePath -Value $null
for ($i = 0; $i -lt $domainArray.Length; $i++) {
    $domain = $domainArray[$i]

    if (-not $domainsKeyed) {
        if ($networkInterfaces.Length-1 -lt $i) {
            Write-Host "!!! NE HVATAET IP {$domain} !!!"
            break
        }
        $ip = $networkInterfaces[$i]
    }
    else 
    {
        $ip = $domainPairs[$domain];
    }

    if (-not $domainsKeyed -or $networkInterfaces.Contains($ip)) {

        CreateCertificate -domain $domain
        CreateWebsite -domain $domain $ip
        CreateFtpsite -domain $domain $ip

        $user = SiteUser -domain $domain
        $path = SitePath -domain $domain

        $line = "$domain - $ip, $path, ftp://${user}:Abc12345!@$ip"
        Write-Host $line
        Add-Content -Path $filePath -Value "$line"
    } 
    else 
    {
        Write-Host "Skipping IIS site for $domain - $ip"
    }
}

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
IISReset
Write-Host "Done"
