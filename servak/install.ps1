# POWERSHELL OLD
function Update-FirewallRule {
    param (
        [string]$Name,
        [string]$DisplayName,
        [string]$Description,
        [int]$LocalPort,
        [string]$Protocol,
        [string]$Profile = 'Any',
        [string]$RemoteAddress = 'Any',
        [string]$Program = 'Any'
    )
    try {
        $existingRule = Get-NetFirewallRule -Name $Name -ErrorAction Stop
        Set-NetFirewallRule -Name $Name -Profile $Profile -RemoteAddress $RemoteAddress -Program $Program
        Enable-NetFirewallRule -Name $Name
        Write-Output "Rule '$Name' updated."
    }
    catch {
        New-NetFirewallRule -Name $Name -DisplayName $DisplayName -Description $Description -Protocol $Protocol -LocalPort $LocalPort -Action Allow -Profile $Profile -RemoteAddress $RemoteAddress -Program $Program
        Write-Output "Rule '$Name' created."
    }
}
Update-FirewallRule -Name "WinRM-HTTP-In-TCP" -DisplayName "WinRM (HTTP-In)" -Description "Inbound rule for WinRM (HTTP-In)" -Protocol TCP -LocalPort 5985
Update-FirewallRule -Name "WinRM-HTTPS-In-TCP" -DisplayName "WinRM (HTTPS-In)" -Description "Inbound rule for WinRM (HTTPS-In)" -Protocol TCP -LocalPort 5986
Stop-Service WinRM
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "LocalAccountTokenFilterPolicy" -Value 1 -Type DWORD -Force
Start-Service WinRM
try
{
Enable-PSRemoting -Force
}
catch{}
Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value $true
Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value $true
if (-not (Get-NetFirewallRule -Name "WinRM-HTTP-In-TCP" -ErrorAction SilentlyContinue)) { New-NetFirewallRule -Name "WinRM-HTTP-In-TCP" -DisplayName "WinRM (HTTP-In)" -Description "Inbound rule for WinRM (HTTP-In)" -Protocol TCP -LocalPort 5985 -Action Allow } else { Enable-NetFirewallRule -Name "WinRM-HTTP-In-TCP" }
if (-not (Get-NetFirewallRule -Name "WinRM-HTTPS-In-TCP" -ErrorAction SilentlyContinue)) { New-NetFirewallRule -Name "WinRM-HTTPS-In-TCP" -DisplayName "WinRM (HTTPS-In)" -Description "Inbound rule for WinRM (HTTPS-In)" -Protocol TCP -LocalPort 5986 -Action Allow } else { Enable-NetFirewallRule -Name "WinRM-HTTPS-In-TCP" }
Stop-Service WinRM
Start-Service WinRM
Get-Service WinRM



#POWESHELL 7
$version = "7.4.3"
$url = "https://github.com/PowerShell/PowerShell/releases/download/v$version/PowerShell-$version-win-x64.msi"
$outputDir = "C:\Temp"
$outputFile = "$outputDir\PowerShell-$version-win-x64.msi"
if (!(Test-Path -Path $outputDir -PathType Container)) {
    New-Item -Path $outputDir -ItemType Directory | Out-Null
}
Invoke-WebRequest -Uri $url -OutFile $outputFile
Start-Process msiexec.exe -ArgumentList "/i $outputFile /quiet /norestart" -Wait

# Enable PowerShell remoting
$pwshPath = "C:\Program Files\PowerShell\7\pwsh.exe"
& $pwshPath -Command "Enable-PSRemoting -Force"


#SSH
try {
    $existingRule = Get-NetFirewallRule -Name 'sshd' -ErrorAction SilentlyContinue
    if ($existingRule) {
        Set-NetFirewallRule -Name 'sshd' -RemoteAddress Any -Profile Any -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 -ErrorAction Stop
        Write-Output "Updated firewall rule 'sshd' to allow SSH (port 22) for any profile, any IP, and any program."
    } else {
        New-NetFirewallRule -Name 'sshd' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 -RemoteAddress Any -Profile Any -ErrorAction Stop
        Write-Output "Created firewall rule 'sshd' to allow SSH (port 22) for any profile, any IP, and any program."
    }
} catch {
    Write-Error "Failed to create/update firewall rule for SSH:`n$_"
}
Add-WindowsCapability -Online -Name OpenSSH.Server
Add-WindowsCapability -Online -Name OpenSSH.Client
Set-Service -Name sshd -StartupType 'Automatic'
Start-Service sshd


#set powershel 7 default
$ErrorActionPreference = 'Stop'
$newDefaultConfigSource = 'PowerShell.7'
$defaultConfigName = 'Microsoft.PowerShell'
$configXmlValueName = 'ConfigXml'
$configRootKey = 'registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Plugin'
Rename-ItemProperty $configRootKey\$defaultConfigName $configXmlValueName -NewName "$configXmlValueName.OLD"
$xmlText = (Get-ItemPropertyValue $configRootKey\$newDefaultConfigSource $configXmlValueName) -replace 
             ('\b{0}\b' -f [regex]::Escape($newDefaultConfigSource)), $defaultConfigName
Set-ItemProperty $configRootKey\$defaultConfigName $configXmlValueName $xmlText
Restart-Service WinRM