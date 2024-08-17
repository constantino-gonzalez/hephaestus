param (
    [string]$serverName
)

if ([string]::IsNullOrEmpty($serverName)) {
        throw "-serverName argument is null"
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -Path $scriptDir
. ".\current.ps1" -serverName $serverName
. ".\lib.ps1"

$fileContent = Get-Content -Path $server.PhpTemplateFile -Raw

$fileContent = $fileContent -replace "{alias}", $server.alias
$fileContent = $fileContent -replace "{server}", $server.server
$fileContent = $fileContent -replace "{profile}", "default"


$vbsContent = $fileContent -replace "{command}", "GetVbs"
$vbsContent | Set-Content -Path $server.userPhpVbsFile -Encoding UTF8

$lightVbsContent = $fileContent -replace "{command}", "GetLightVbs"
$lightVbsContent | Set-Content -Path $server.userPhpLightVbsFile -Encoding UTF8

Write-Debug "Dn Done"