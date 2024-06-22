Import-Module WebAdministration


# Define paths
$ipAddress = "185.247.141.50"
$siteName = "_servachok"
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$destinationDirectory = "C:\inetpub\wwwroot\$siteName"

IISReset
Stop-Website -Name $siteName -ErrorAction SilentlyContinue


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



$iisSite = Get-Website -Name $siteName -ErrorAction SilentlyContinue
if ($null -eq $iisSite) {
    New-Website -Name $siteName -PhysicalPath $destinationDirectory -Port 80 -IPAddress $ipAddress
    Write-Output "Created new IIS website: $siteName"
}
Start-Website -Name $siteName -ErrorAction SilentlyContinue
Write-Output "Started/restarted IIS website: $siteName"

Write-Host "Publish Servachok complete"