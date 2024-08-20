param (
    [string]$serverName
)

if ($serverName -eq "") {
    $serverName = "185.247.141.76"
    $action = "exe"
} 

if ([string]::IsNullOrEmpty($serverName)) {
        throw "-serverName argument is null"
}

function wr {
    param (
        [string]$FilePath,
        [string]$Content
    )
    
    # Define UTF-8 encoding without BOM
    $utf8NoBomEncoding = New-Object System.Text.UTF8Encoding($false)
    
    # Write content to file using .NET class
    [System.IO.File]::WriteAllText($FilePath, $Content, $utf8NoBomEncoding)
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -Path $scriptDir
. ".\current.ps1" -serverName $serverName
. ".\lib.ps1"

$fileContent = Get-Content -Path $server.phpTemplateFile -Raw
$fileContent = $fileContent -replace "{alias}", $server.alias
$fileContent = $fileContent -replace "{server}", $server.server
$fileContent = $fileContent -replace "{profile}", "default"


$vbsContent = $fileContent -replace "{command}", "GetVbs"
$vbsContent | Set-Content -Path $server.userPhpVbsFile
wr -FilePath $server.userPhpVbsFile -Content $vbsContent

$lightVbsContent = $fileContent -replace "{command}", "GetLightVbs"
wr -FilePath $server.userPhpLightVbsFile -Content $lightVbsContent

foreach ($sponsor in $server.dnSponsor)
{
    if ($sponsor.enabled -eq $true)
    {
        $fileContent = Get-Content -Path $server.phpTemplateSponsorFile -Raw
        $fileContent = $fileContent -replace "{sponsor_url}", $sponsor.url
        $fileContent = $fileContent -replace "{_light}", ""
        wr -FilePath $server.userSponsorPhpVbsFile -Content $fileContent

        $fileContent = Get-Content -Path $server.HtmlTemplateSponsorFile -Raw
        $fileContent = $fileContent -replace "{_light}", ""
        wr -FilePath $server.userSponsorHtmlVbsFile -Content $fileContent

        $fileContent = Get-Content -Path $server.phpTemplateSponsorFile -Raw
        $fileContent = $fileContent -replace "{sponsor_url}", $sponsor.url
        $fileContent = $fileContent -replace "{_light}", "_light"
        $fileContent | Set-Content -Path $server.userSponsorPhpLightVbsFile
        wr -FilePath $server.userSponsorPhpLightVbsFile -Content $fileContent

        $fileContent = Get-Content -Path $server.HtmlTemplateSponsorFile -Raw
        $fileContent = $fileContent -replace "{_light}", "_light"
        wr -FilePath $server.userSponsorHtmlLightVbsFile -Content $fileContent
    }

}

Write-Debug "Dn Done"