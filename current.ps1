param (
    [string]$serverName
)
if ([string]::IsNullOrEmpty($serverName)) {
        throw "-serverName argument is null"
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = $scriptDir
$dataDir = Resolve-Path -Path (Join-Path -Path $scriptDir -ChildPath "data/$serverName")
$serverPath = Resolve-Path -Path (Join-Path -Path $dataDir -ChildPath "server.json")
if ([string]::IsNullOrEmpty($serverPath)) {
    throw "Current folder not contains data."
}
$server = Get-Content -Path $serverPath -Raw | ConvertFrom-Json