param (
    [string]$serverName, [string]$usePath = ""
)
if ([string]::IsNullOrEmpty($serverName)) {
        throw "-serverName argument is null"
}

$ver = $PSVersionTable.PSVersion.Major
Write-Host "PowerShell v: $ver"

$sitePath = "C:\inetpub\wwwroot\_web"
$siteUser = "ftpMan"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not[string]::IsNullOrEmpty($usePath))
{
    $rootDatDir =  Resolve-Path -Path (Join-Path -Path $usePath -ChildPath "data")
    $certDir = Resolve-Path -Path (Join-Path -Path $usePath -ChildPath "cert")
    $dataDir = $rootDatDir
    $serverPath = Resolve-Path -Path (Join-Path -Path $dataDir -ChildPath "server.json")
    $servakDir = Join-Path -Path $usePath -ChildPath "servak"
    $servachokDir = Join-Path -Path $usePath -ChildPath "servachok"
    $servakDirWeb = Join-Path $servakDir -ChildPath "web"
}
else 
{
    $rootDatDir = "C:\data"
    $certDir = Resolve-Path -Path (Join-Path -Path $scriptDir -ChildPath "cert")
    $dataDir = Resolve-Path -Path (Join-Path -Path $rootDatDir -ChildPath "$serverName")
    $serverPath = Resolve-Path -Path (Join-Path -Path $dataDir -ChildPath "server.json")
    $servakDir = Join-Path -Path $scriptDir -ChildPath "servak"
    $servachokDir = Join-Path -Path $scriptDir -ChildPath "servachok"
    $servakDirWeb = Join-Path $scriptDir -ChildPath "..\web"
}



if ([string]::IsNullOrEmpty($serverPath)) {
    throw "Current folder not contains data."
}
$server = Get-Content -Path $serverPath -Raw | ConvertFrom-Json
$certPassword = ConvertTo-SecureString -String "123" -Force -AsPlainText
$friendlyName="IIS Root Authority"
$certLocation="cert:\LocalMachine\Root"
if ([string]::IsNullOrEmpty($server.password) -or $server.password -eq "password") {
    $server.password = [System.Environment]::GetEnvironmentVariable('SuperPassword', [System.EnvironmentVariableTarget]::Machine)
}


function pfxFile {
    param (
        [string]$domain
    )
    return (Join-Path -Path $certDir -ChildPath "$domain.pfx")
}

function certFile {
    param (
        [string]$domain
    )
    return (Join-Path -Path $certDir -ChildPath "$domain.cer")
}