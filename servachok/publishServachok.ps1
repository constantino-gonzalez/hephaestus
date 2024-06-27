param (
    [string]$serverName, [string]$usePath = "", [string]$ipAddress=""
)
if ([string]::IsNullOrEmpty($ipAddress)) {
    throw "Ip address for servachok is not provided"
}


Import-Module WebAdministration

# Define paths
$siteName = "_servachok"
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$destinationDirectory = "C:\inetpub\wwwroot\$siteName"

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
    Write-Error "Erro deleting servachok site: $siteName, $_"
}



if (-Not (Test-Path -Path $destinationDirectory)) {
    New-Item -Path $destinationDirectory -ItemType Directory | Out-Null
}


Get-ChildItem -Path $destinationDirectory | Remove-Item -Recurse -Force


dotnet build
dotnet publish $scriptDirectory -o $destinationDirectory


$websiteDirectory = $destinationDirectory
$aclPath = "$websiteDirectory\*"
$permissions = "IIS AppPool\DefaultAppPool","(OI)(CI)RXW"
try {
    icacls $aclPath /grant ("{0}:{1}" -f $permissions) /T /C /Q
    Write-Output "Permissions granted successfully to $($permissions[0]) on $websiteDirectory"
}
catch {
    Write-Error "Error occurred: $_"
}


try 
{
    New-Website -Name $siteName -PhysicalPath $destinationDirectory -Port 80 -IPAddress $ipAddress

}

catch {
    Write-Error "Erro creating servachok site: $siteName, $_"
}

Start-Website -Name $siteName -ErrorAction SilentlyContinue
Write-Output "Started/restarted IIS website: $siteName"

Write-Host "Publish Servachok complete"