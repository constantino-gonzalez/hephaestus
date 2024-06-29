param (
    [string]$serverName, [string]$usePath = "", [string]$ipAddress=""
)
#$serverName = "185.247.141.76"
#$usePath = ""
#$ipAddress = "185.247.141.50"
if ([string]::IsNullOrEmpty($ipAddress)) {
    throw "Ip address for servachok is not provided"
}

Import-Module WebAdministration

# Stop Servachok
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


# publish
if (-Not (Test-Path -Path $destinationDirectory)) {
    New-Item -Path $destinationDirectory -ItemType Directory | Out-Null
}
Get-ChildItem -Path $destinationDirectory | Remove-Item -Recurse -Force
dotnet build $scriptDirectory
dotnet publish $scriptDirectory -o $destinationDirectory
New-Website -Name $siteName -PhysicalPath $destinationDirectory -Port 80 -IPAddress $ipAddress
Start-Website -Name $siteName -ErrorAction SilentlyContinue