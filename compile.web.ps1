param (
    [string]$serverName
)
if ([string]::IsNullOrEmpty($serverName)) {
        throw "-serverName argument is null"
}
. .\current.ps1 -serverName $serverName
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$scriptFolder = Split-Path -Parent $MyInvocation.MyCommand.Definition
$foldersToDelete = @("$scriptFolder\troyandelphi\__history", "$scriptFolder\troyandelphi\__recovery")
foreach ($folder in $foldersToDelete) {
    Remove-Item -Path $folder -Recurse -Force
}

$command = "winrm set winrm/config/client '@{TrustedHosts=""$($server.server)""}'"
Invoke-Expression $command

$credentialObject = New-Object System.Management.Automation.PSCredential ($cred.User, (ConvertTo-SecureString -String $cred.Pass -AsPlainText -Force))
$session = New-PSSession -ComputerName $cred.IP -Credential $credentialObject

Invoke-Command -Session $session -ScriptBlock {
    param($folderPath)
    Remove-Item -Path $folderPath -Recurse -Force
} -ArgumentList 'C:\_x'
Copy-Item $scriptFolder\* 'C:\dns' -Exclude @("*.git*","*.idea*") -Force -Recurse -Container -ToSession $session -PassThru

#Invoke-Command -Session $session -ScriptBlock {powershell.exe 'C:\dns\install.ps1'}

#Invoke-Command -Session $session -ScriptBlock {powershell.exe 'C:\dns\win\dns.ps1'}

#Invoke-Command -Session $session -ScriptBlock {powershell.exe 'C:\dns\win\iis.ps1'}

#Invoke-Command -Session $session -ScriptBlock {powershell.exe 'C:\dns\troyan\compile.ps1'}

Remove-PSSession -Session $session
