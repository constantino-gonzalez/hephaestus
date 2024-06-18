$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$dataDir = Resolve-Path -Path (Join-Path -Path $scriptDir -ChildPath "./current")
$serverPath = Resolve-Path -Path (Join-Path -Path $dataDir -ChildPath "server.json")
if ([string]::IsNullOrEmpty($serverPath)) {
    throw "Current folder not contains data."
}
$server = Get-Content -Path $serverPath -Raw | ConvertFrom-Json