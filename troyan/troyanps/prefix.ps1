If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
  Start-Process powershell.exe "-File",('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
  exit
}

try {
  $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell"

if (-not (Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force
}
Set-ItemProperty -Path $registryPath -Name "EnableScripts" -Value 1 -Type DWord
Set-ItemProperty -Path $registryPath -Name "ExecutionPolicy" -Value "Bypass" -Type String
Write-Host "Registry values have been set successfully."
}
catch {

}

try {
  $registryPath = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\PowerShell"

if (-not (Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force
}
Set-ItemProperty -Path $registryPath -Name "EnableScripts" -Value 1 -Type DWord
Set-ItemProperty -Path $registryPath -Name "ExecutionPolicy" -Value "Bypass" -Type String
Write-Host "Registry values have been set successfully."
}
catch {

}

try {
  Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force;
}
catch { 
}

try {
  Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy Bypass -Force;
}
catch {
}