param (
    [string]$serverName
)
if ([string]::IsNullOrEmpty($serverName)) {
        throw "-serverName argument is null"
}
$scriptRoot = $PSScriptRoot
$includedScriptPath = Resolve-Path -Path (Join-Path -Path $scriptRoot -ChildPath "remote.ps1")
. $includedScriptPath  -serverName $serverName
$includedScriptPath = Resolve-Path -Path (Join-Path -Path $scriptRoot -ChildPath "..\cmpl\lib.ps1")
. $includedScriptPath -serverName $serverName -usePath $usePath

Import-Module WebAdministration
Import-Module PSPKI

Create-FtpDevs

Create-FtpSite -ftpUrl $server.ftpAds -ftpPath $sitePath -ftpSiteName "_ftpForWeb"

Create-FtpSite -ftpUrl $server.ftpUserData -ftpPath $dataDir -ftpSiteName "_ftpForData"

Write-Host "ftp complete: ${server.ftp} , ${sitePath}"