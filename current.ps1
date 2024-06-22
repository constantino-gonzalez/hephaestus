param (
    [string]$serverName
)
if ([string]::IsNullOrEmpty($serverName)) {
        throw "-serverName argument is null"
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDatDir = "C:\data"
$certDir = Resolve-Path -Path (Join-Path -Path $scriptDir -ChildPath "cert")
$dataDir = Resolve-Path -Path (Join-Path -Path $rootDatDir -ChildPath "$serverName")
$serverPath = Resolve-Path -Path (Join-Path -Path $dataDir -ChildPath "server.json")
if ([string]::IsNullOrEmpty($serverPath)) {
    throw "Current folder not contains data."
}
$server = Get-Content -Path $serverPath -Raw | ConvertFrom-Json

if ([string]::IsNullOrEmpty($server.password) -or $server.password -eq "password") {
    $server.password = [System.Environment]::GetEnvironmentVariable('SuperPassword', [System.EnvironmentVariableTarget]::Machine)
}

$servakDir = Join-Path -Path $scriptDir -ChildPath "servak"
$servachokDir = Join-Path -Path $scriptDir -ChildPath "servachok"

$certPassword = ConvertTo-SecureString -String "123" -Force -AsPlainText
$friendlyName="IIS Root Authority"
$certLocation="cert:\LocalMachine\Root"


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