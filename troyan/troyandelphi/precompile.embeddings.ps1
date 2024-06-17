$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
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

    $iconFile = Join-Path -Path $scriptDir -ChildPath "_icon.ico"


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
        if ($name -eq "front")
        {
            if ($iconFile -ne ""){
                ExtractIcon -filePath $file.FullName -outPath $iconFile
                $iconFile=""
            }
        }
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

    $number = $files.Length-1
    if ($number1 -lt 0) {
        $number = 0
    }
    $content = ($delphiArray -join ', ')
    if ($content -eq ""){
        $content="''"
    }

    $template  = $template -replace "CONTENT", $content
    $template  = $template -replace "NAME", $unitName
    $template  = $template -replace "NUMBER", $number.ToString()

    Set-Content -Path $delphiFile -Value $template -Encoding UTF8NoBOM
}

Create-EmbeddingFiles -name "front" -startIndex 8000
Create-EmbeddingFiles -name "embeddings" -startIndex 9000
