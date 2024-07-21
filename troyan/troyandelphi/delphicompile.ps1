param (
    [string]$serverName
)
if ([string]::IsNullOrEmpty($serverName)) {
        throw "-serverName argument is null"
}
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
& (Join-Path -Path $scriptDir -ChildPath "../../sys/current.ps1") -serverName $serverName

Write-Host "delphiCompile"


#clean
if (Test-Path -Path $server.userDelphiExe)
{
    Remove-Item -Path $server.userDelphiExe
}
$extensions = @(".dcu", ".res", ".exe",".~pas","*.~dpr")
foreach ($ext in $extensions) {
    Get-ChildItem -Path $server.troyanDelphiDir -Filter "*$ext" | Remove-Item -Force
}
Get-ChildItem -Path $server.troyanDelphiDir -Filter "_*" | Remove-Item -Force

#embeds
& (Join-Path -Path $scriptDir -ChildPath "./delphicompile.embeddings.ps1") -serverName $serverName   

#compile manifest
$manifestFile = Join-Path -Path $scriptDir -ChildPath "dns.manifest.rc"
& "C:\Program Files (x86)\Borland\Delphi7\Bin\brcc32.exe" "$manifestFile"


#compile
$dprOpts = "NO_AUTOSTART"
if ($server.autoStart)
{
    $dprOpts = "USE_AUTOSTART"
}
$dcc32Path = "C:\Program Files (x86)\Borland\Delphi7\Bin\dcc32.exe"
$dprFile = $server.troyanDelphiProj
$dprArgs = "-D`"$dprOpts`" `"$dprFile`""
Set-Location -Path $server.troyanDelphiDir
Start-Process -FilePath "`"$dcc32Path`"" -ArgumentList $dprArgs -Wait
Set-Location -Path $scriptDir
Copy-Item -Path $server.troyanDelphiExe -Destination $server.userDelphiExe -Force

Write-Host "Delphi сomplete"