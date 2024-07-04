param (
    [string]$serverName
)
if ([string]::IsNullOrEmpty($serverName))
{
    throw "compile.ps1 -serverName argument is null"
}
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$refinerDll= (Join-Path -Path $scriptDir -ChildPath "../model/bin/debug/net7.0/model.dll")
Add-Type -Path $refinerDll

$myObject = New-Object model.ServerService

$myObject.GetServer($serverName)
