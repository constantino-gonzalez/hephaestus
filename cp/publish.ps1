Import-Module WebAdministration

# Define paths
$ipAddress = "185.247.141.76"
$siteName = "_rootCp"
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$destinationDirectory = "C:\inetpub\wwwroot\$siteName"



IISReset
try 
{
$iisSite = Get-Website -Name $siteName -ErrorAction SilentlyContinue
if ($null -ne $iisSite)
{
    Stop-Website -Name $siteName -ErrorAction SilentlyContinue
    Remove-WebSite -Name $siteName -ErrorAction SilentlyContinue
}

}
catch {
    Write-Error "Erro deleting rootCp site: $siteName, $_"
}
Stop-Service -Name W3SVC


if (-Not (Test-Path -Path $destinationDirectory)) {
    New-Item -Path $destinationDirectory -ItemType Directory | Out-Null
}



Get-ChildItem -Path $destinationDirectory | Remove-Item -Recurse -Force


dotnet build
dotnet publish $scriptDirectory -o $destinationDirectory


$websiteDirectory = $destinationDirectory
if (-not (Test-Path -Path $websiteDirectory -PathType Container)) {
    Write-Error "Website directory does not exist: $websiteDirectory"
    exit
}
$aclPath = "$websiteDirectory\*"
$permissions = "IIS AppPool\DefaultAppPool","(OI)(CI)RXW"
try {
    icacls $aclPath /grant ("{0}:{1}" -f $permissions) /T /C /Q
    Write-Output "Permissions granted successfully to $($permissions[0]) on $websiteDirectory"
}
catch {
    Write-Error "Error occurred: $_"
}
Start-Service -Name W3SVC


$iisSite = Get-Website -Name $siteName -ErrorAction SilentlyContinue
if ($null -eq $iisSite) {
    New-Website -Name $siteName -PhysicalPath $destinationDirectory -Port 80 -IPAddress $ipAddress
    Write-Output "Created new IIS website: $siteName"
}
Start-Website -Name $siteName -ErrorAction SilentlyContinue
Write-Output "Started/restarted IIS website: $siteName"

Write-Host "Publish RootCp complete"