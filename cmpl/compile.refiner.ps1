param (
    [string]$serverName
)
if ([string]::IsNullOrEmpty($serverName))
{
    throw "compile.ps1 -serverName argument is null"
}
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Start-Process -FilePath (Join-Path -Path $scriptDir -ChildPath "../refiner/bin/debug/net7.0/refiner.exe") -ArgumentList $serverName -Wait -PassThru
