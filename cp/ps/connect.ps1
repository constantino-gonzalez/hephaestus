# winrm quickconfig -transport:https
# winrm quickconfig
# if (-not (Get-NetFirewallRule -Name "WinRM-HTTP-In-TCP" -ErrorAction SilentlyContinue)) { New-NetFirewallRule -Name "WinRM-HTTP-In-TCP" -DisplayName "WinRM (HTTP-In)" -Description "Inbound rule for WinRM (HTTP-In)" -Protocol TCP -LocalPort 5985 -Action Allow } else { Enable-NetFirewallRule -Name "WinRM-HTTP-In-TCP" }
# if (-not (Get-NetFirewallRule -Name "WinRM-HTTPS-In-TCP" -ErrorAction SilentlyContinue)) { New-NetFirewallRule -Name "WinRM-HTTPS-In-TCP" -DisplayName "WinRM (HTTPS-In)" -Description "Inbound rule for WinRM (HTTPS-In)" -Protocol TCP -LocalPort 5986 -Action Allow } else { Enable-NetFirewallRule -Name "WinRM-HTTPS-In-TCP" }
# Start-Service WinRM
# Get-Service WinRM
# Invoke-Expression "& { $(Invoke-RestMethod 'https://aka.ms/install-powershell.ps1') } -useMSI -Quiet -EnablePSRemoting"

$source = Resolve-Path -Path (Join-Path -Path (Split-Path -Parent $MyInvocation.MyCommand.Definition) -ChildPath "../../win")
$dest = 'C:\_x'

$credentials = @(
    [PSCustomObject]@{
        IP = "185.247.141.76"
        User = "Administrator"
        Pass = "remHo9ZLisq4"
    }
)

foreach ($cred in $credentials) {
    winrm quickconfig -transport:http

    #$command = "winrm set winrm/config/client '@{TrustedHosts=""$($cred.IP)""}'"
    #Invoke-Expression $command

    $credentialObject = New-Object System.Management.Automation.PSCredential ($cred.User, (ConvertTo-SecureString -String $cred.Pass -AsPlainText -Force))
    $session = New-PSSession -ComputerName $cred.IP -Credential $credentialObject

    Invoke-Command -Session $session -ScriptBlock {
        param($source, $destination)
        if (Test-Path $destination) {
            Remove-Item -Recurse -Force $destination
        }
    } -ArgumentList $source, $dest
    Copy-Item -Path $source -Destination $dest -Recurse -Force -ToSession $session

    # Invoke-Command -Session $session -ScriptBlock {powershell.exe 'C:\dns\install.ps1'}

    # Invoke-Command -Session $session -ScriptBlock {powershell.exe 'C:\dns\win\dns.ps1'}

    # Invoke-Command -Session $session -ScriptBlock {powershell.exe 'C:\dns\win\iis.ps1'}

    # Invoke-Command -Session $session -ScriptBlock {powershell.exe 'C:\dns\troyan\compile.ps1'}

    Remove-PSSession -Session $session
}

Write-Host "done"