param (
    [string]$serverName, [string]$usePath = ""
)
#$serverName="185.247.141.76"
#$usePath="C:\_x"
if ([string]::IsNullOrEmpty($serverName)) {
        throw "-serverName argument is null"
}
$scriptRoot = $PSScriptRoot
$includedScriptPath = Resolve-Path -Path (Join-Path -Path $scriptRoot -ChildPath "..\current.ps1")
. $includedScriptPath -serverName $serverName -usePath $usePath
$includedScriptPath = Resolve-Path -Path (Join-Path -Path $scriptRoot -ChildPath "..\lib.ps1")
. $includedScriptPath -serverName $serverName -usePath $usePath

Import-Module WebAdministration
Import-Module PSPKI
function PrepareFolder{ 
    param ([string] $folder, [string] $sourceFolder,  [string] $user)

    if (-not (Test-Path -Path $folder -PathType Container)) {
        New-Item -Path $folder -ItemType Directory -Force | Out-Null
    }
    Get-ChildItem -Path $sourceFolder | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination $folder -Force
    }
}

PrepareFolder -folder $sitePath -sourceFolder $servakDirWeb -user $siteUser

Create-FtpSite -ftpUrl $server.ftp -ftpPath $sitePath -ftpSiteName "_webFTP"

Write-Host "ftp complete: ${server.ftp} , ${sitePath}"