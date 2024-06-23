param (
    [string]$serverName
)
if ([string]::IsNullOrEmpty($serverName)) {
        throw "-serverName argument is null"
}
. .\current.ps1 -serverName $serverName
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$command = "winrm set winrm/config/client '@{TrustedHosts=""$($server.server)""}'"
Invoke-Expression $command

$credentialObject = New-Object System.Management.Automation.PSCredential ($server.login, (ConvertTo-SecureString -String $server.password -AsPlainText -Force))
$session = New-PSSession -ComputerName $server.server -Credential $credentialObject

Invoke-Command -Session $session -ScriptBlock {
    param($serverName)
    if (Test-Path 'C:\_x')
    {
        Remove-Item -Path 'C:\_x' -Recurse -Force
    }

    if (-not (Test-Path "C:\_x\data"))
    {
        New-Item -Path "C:\_x\data" -ItemType Directory -Force
    }
}  -ArgumentList $serverName

Copy-Item -Path $servakDir -Destination 'C:\_x\servak' -ToSession $session -Recurse -Force

Copy-Item -Path $servachokDir -Destination 'C:\_x\servachok' -ToSession $session -Recurse -Force

Copy-Item -Path $certDir -Destination 'C:\_x\cert' -ToSession $session -Recurse -Force

Copy-Item -Path $serverPath -Destination "C:\_x\data\server.json" -ToSession $session -Force

Copy-Item -Path (Resolve-Path -Path (Join-Path -Path $scriptDir -ChildPath "current.ps1")) -Destination "C:\_x\current.ps1" -ToSession $session -Force

#Invoke-Command -Session $session -ScriptBlock {powershell.exe 'C:\dns\win\dns.ps1'}

#Invoke-Command -Session $session -ScriptBlock {powershell.exe 'C:\dns\win\iis.ps1'}


Remove-PSSession -Session $session
