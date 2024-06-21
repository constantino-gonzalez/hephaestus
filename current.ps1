param (
    [string]$serverName
)
if ([string]::IsNullOrEmpty($serverName)) {
        throw "-serverName argument is null"
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = $scriptDir
$certDir = Resolve-Path -Path (Join-Path -Path $scriptDir -ChildPath "cert")
$dataDir = Resolve-Path -Path (Join-Path -Path $scriptDir -ChildPath "data/$serverName")
$serverPath = Resolve-Path -Path (Join-Path -Path $dataDir -ChildPath "server.json")
if ([string]::IsNullOrEmpty($serverPath)) {
    throw "Current folder not contains data."
}
$server = Get-Content -Path $serverPath -Raw | ConvertFrom-Json

$servakDir = Join-Path -Path $rootDir -ChildPath "servak"
$servachokDir = Join-Path -Path $rootDir -ChildPath "servachok"

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