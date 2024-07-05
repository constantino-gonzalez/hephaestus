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

Create-FtpSite -ftpUrl $server.ftpAds -ftpPath $sitePath -ftpSiteName "_ftpForWeb" -ApplicationPool $appPoolName

Create-FtpSite -ftpUrl $server.ftpUserData -ftpPath $dataDir -ftpSiteName "_ftpForData" -ApplicationPool $appPoolName

Write-Host "ftp complete: ${server.ftpAds}, ${server.ftpUserData} , ${sitePath}"